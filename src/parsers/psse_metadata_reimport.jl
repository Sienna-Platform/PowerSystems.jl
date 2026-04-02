# Parse the `<name>_export_metadata.json` file written alongside PSS/E files by PowerFlows.jl

# Currently the following mappings are used here:
#   area_mapping: maps Sienna name to PSS/E number for all areas
#   zone_mapping: maps Sienna name to PSS/E number for all load zones
#   bus_name_mapping: maps Sienna name to PSS/E name for all buses
#   bus_number_mapping: maps Sienna number to PSS/E number for all buses
#   load_name_mapping: maps (Sienna bus, Sienna name) to PSS/E name for all loads
#   shunt_name_mapping: maps (Sienna bus, Sienna name) to PSS/E name for all shunts
#   switched_shunt_name_mapping: maps (Sienna bus, Sienna name) to PSS/E name for all switched shunts
#   generator_name_mapping: maps (Sienna bus 1, Sienna bus 2, Sienna name) to PSS/E name for all generators
#   xfrm_3w_name_formatter: maps (Sienna bus 1, Sienna bus 2, Sienna bus 3, Sienna name) to PSS/E name for all 3W transformers 
#   dcline_name_formatter: maps (Sienna bus 1, Sienna bus 2, Sienna name) to PSS/E name for all DC lines
#   vscline_name_formatter: maps (Sienna bus 1, Sienna bus 2, Sienna name) to PSS/E name for all VSC lines
#   branch_name_mapping: maps (Sienna bus 1, Sienna bus 2, Sienna name) to PSS/E name for all non-transformer branches
#   transformer_ckt_mapping: maps (Sienna bus1, Sienna bus2, Sienna name) to PSS/E CKT field for all transformers

# Mappings are stored in the file in the Sienna -> PSS/E direction, so they need to be
# reversed for use here. Wherever a tuple is indicated above, the presentation in the file
# is of the elements joined with underscores to form a single string.

# NOTE for the moment, this feature is mostly tested in the PowerFlows.jl unit tests.

const PSSE_EXPORT_METADATA_EXTENSION = "_export_metadata.json"

reverse_dict(d::Dict) = Dict(map(reverse, collect(d)))

function split_first_rest(s::AbstractString; delim = "_")
    splitted = split(s, delim)
    return first(splitted), join(splitted[2:end], delim)
end

"Convert a s_bus_n_s_name => p_name dictionary to a (p_bus_n, p_name) => s_name dictionary"
deserialize_reverse_component_ids(
    mapping,
    bus_number_mapping,
    ::T,
) where {T <: Type{Int64}} =
    Dict(
        let
            (s_bus_n, s_name) = split_first_rest(s_bus_n_s_name)
            p_bus_n = bus_number_mapping[s_bus_n]
            (p_bus_n, p_name) => s_name
        end
        for (s_bus_n_s_name, p_name) in mapping)
deserialize_reverse_component_ids(
    mapping,
    bus_number_mapping,
    ::T,
) where {T <: Type{Tuple{Int64, Int64}}} =
    Dict(
        let
            (s_buses, s_name) = split_first_rest(s_buses_s_name)
            (s_bus_1, s_bus_2) = split(s_buses, "-")
            (p_bus_1, p_bus_2) = bus_number_mapping[s_bus_1], bus_number_mapping[s_bus_2]
            ((p_bus_1, p_bus_2), p_name) => s_name
        end
        for (s_buses_s_name, p_name) in mapping)

"""
Use PSS/E exporter metadata to build a function that maps component names back to their
original Sienna values.
"""
function name_formatter_from_component_ids(raw_name_mapping, bus_number_mapping, sig)
    reversed_name_mapping =
        deserialize_reverse_component_ids(raw_name_mapping, bus_number_mapping, sig)
    function component_id_formatter(device_dict)
        (p_bus_n, p_name) = device_dict["source_id"][2:3]
        (p_bus_n isa Integer) || (p_bus_n = parse(Int64, p_bus_n))
        new_name = reversed_name_mapping[(p_bus_n, p_name)]
        return new_name
    end
    return component_id_formatter
end

# Assumes bus_number_mapping is 1-to-1, given by its coming from reverse_dict
function remap_bus_numbers!(sys::System, bus_number_mapping)
    for bus in collect(get_components(Bus, sys))
        old_number = get_number(bus)
        new_number_str = get(bus_number_mapping, old_number, string(old_number))
        new_number = parse(Int, new_number_str)
        if new_number != old_number
            # This will throw an exception if one bus's PSS/E number is another bus's
            # Sienna number. That never happens because _psse_bus_numbers on the
            # exporting side guarantees that bus numbers that are already compliant with
            # the PSS/E spec will not be changed.
            set_bus_number!(sys, bus, new_number)
        end
    end
end

"""
Parse an export_metadata dictionary, returning the kwargs that should be passed to the
System constructor and the bus number remapping that should be used to effect the
retransformation.
"""
function parse_export_metadata_dict(md::Dict)
    bus_name_map = reverse_dict(md["bus_name_mapping"])  # PSS/E bus name -> Sienna bus name
    all_branch_name_map = deserialize_reverse_component_ids(
        merge(
            md["branch_name_mapping"],
            md["transformer_ckt_mapping"],
        ),
        md["bus_number_mapping"],
        Tuple{Int64, Int64},
    )
    bus_name_formatter = device_dict -> begin
        bus_name = device_dict["name"]
        get(bus_name_map, bus_name, bus_name)
    end

    gen_name_formatter = name_formatter_from_component_ids(
        md["generator_name_mapping"],
        md["bus_number_mapping"],
        Int64,
    )
    load_name_formatter = name_formatter_from_component_ids(
        md["load_name_mapping"],
        md["bus_number_mapping"],
        Int64,
    )

    function branch_name_formatter(
        device_dict::Dict,
        bus_f::ACBus,
        bus_t::ACBus,
    )::String
        sid = device_dict["source_id"]

        (p_bus_1, p_bus_2, p_name) =
            (length(sid) == 6) ? [sid[2], sid[3], sid[5]] : last(sid, 3)

        if sid[1] in ["switch", "breaker"]
            p_name = replace(p_name, r"[@*]" => "_")
        end
        bus_f_name = get_name(bus_f)
        bus_t_name = get_name(bus_t)
        key = ((p_bus_1, p_bus_2), p_name)
        def_name = "$(bus_f_name)-$(bus_t_name)-i_$(p_name)"
        new_name = get(all_branch_name_map, key, def_name)
        return new_name
    end

    function xfrm_3w_name_formatter(
        device_dict::Dict,
        p_bus::ACBus,
        s_bus::ACBus,
        t_bus::ACBus,
    )::String
        bus_primary = get_name(p_bus)
        bus_secondary = get_name(s_bus)
        bus_tertiary = get_name(t_bus)
        ckt = device_dict["circuit"]

        return "$(bus_primary)-$(bus_secondary)-$(bus_tertiary)-i_$(ckt)"
    end

    function make_switched_shunt_name_formatter(mapping, bus_number_mapping)
        reversed_name_mapping = Dict{Tuple{Int, String}, String}()
        for (s_bus_n_s_name, p_name) in mapping
            parts = split(s_bus_n_s_name, "_")
            s_bus_n = parts[1]
            s_shunt_name = join(parts[2:end], "_")
            p_bus_n = bus_number_mapping[s_bus_n]
            reversed_name_mapping[(p_bus_n, s_shunt_name)] = p_name
        end
        return function (device_dict)
            sid = device_dict["source_id"]
            p_bus_n = sid[2]
            p_name = sid[3]
            get(reversed_name_mapping, (p_bus_n, p_name), "$(p_bus_n)-$(p_name)")
        end
    end

    function make_hvdc_name_formatter(mapping)
        reversed_mapping = reverse_dict(mapping)
        return function (device_dict, bus_f::ACBus, bus_t::ACBus)
            bus_f_name = get_name(bus_f)
            bus_t_name = get_name(bus_t)
            name = device_dict["name"]
            key = string(bus_f_name, "-", bus_t_name, "-i_", name)
            new_name = get(reversed_mapping, key, key)
            return new_name
        end
    end

    shunt_name_formatter = name_formatter_from_component_ids(
        md["shunt_name_mapping"],
        md["bus_number_mapping"],
        Int64,
    )
    switched_shunt_name_formatter = make_switched_shunt_name_formatter(
        md["switched_shunt_name_mapping"],
        md["bus_number_mapping"],
    )
    dcline_name_formatter = make_hvdc_name_formatter(
        md["dcline_name_mapping"],
    )
    vscline_name_formatter = make_hvdc_name_formatter(
        md["vsc_line_name_mapping"],
    )
    loadzone_name_map = reverse_dict(md["zone_mapping"])
    get!(loadzone_name_map, 1, "1")
    loadzone_name_formatter = name -> loadzone_name_map[name]
    area_name_map = reverse_dict(md["area_mapping"])
    get!(area_name_map, 1, "1")
    area_name_formatter = name -> area_name_map[name]
    transformer_control_objective_map = md["transformer_control_objective_mapping"]
    transformer_control_objective_formatter =
        name -> get(transformer_control_objective_map, name, nothing)
    sys_kwargs = Dict(
        :area_name_formatter => area_name_formatter,
        :loadzone_name_formatter => loadzone_name_formatter,
        :bus_name_formatter => bus_name_formatter,
        :load_name_formatter => load_name_formatter,
        :shunt_name_formatter => shunt_name_formatter,
        :gen_name_formatter => gen_name_formatter,
        :branch_name_formatter => branch_name_formatter,
        :xfrm_3w_name_formatter => xfrm_3w_name_formatter,
        :switched_shunt_name_formatter => switched_shunt_name_formatter,
        :transformer_control_objective_formatter =>
            transformer_control_objective_formatter,
        :dcline_name_formatter => dcline_name_formatter,
        :vscline_name_formatter => vscline_name_formatter,
    )
    bus_number_mapping = reverse_dict(md["bus_number_mapping"])  # PSS/E bus name -> Sienna bus name

    return sys_kwargs, bus_number_mapping
end

"Construct a System from a `.raw` file and a dictionary corresponding to the `<name>_export_metadata.json` file"
function System(file_path::AbstractString, md::Dict; kwargs...)
    sys_kwargs, bus_number_mapping = parse_export_metadata_dict(md)
    sys = system_via_power_models(file_path; merge(sys_kwargs, kwargs)...)
    # Remap bus numbers last because everything has been added to the system using PSS/E bus numbers
    remap_bus_numbers!(sys, bus_number_mapping)
    return sys
end

function system_from_psse_reimport(file_path::AbstractString; kwargs...)
    md_path = joinpath(
        dirname(file_path),
        splitext(basename(file_path))[1] * PSSE_EXPORT_METADATA_EXTENSION,
    )
    if isfile(md_path)
        @info "Found a PowerFlows.jl PSS/E export metadata file at $md_path, will use it to perform remapping for round trip"
        md = JSON3.read(md_path, Dict)
        return System(file_path, md; kwargs...)
    else
        @info "Did not find a PowerFlows.jl PSS/E export metadata file at $md_path, will not do any remapping"
        return system_via_power_models(file_path; kwargs...)
    end
end
