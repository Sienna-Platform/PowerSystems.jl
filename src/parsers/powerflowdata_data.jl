"""
Constructs a System from PowerModelsData.

# Arguments
- `pfd_data::Union{PowerFlowDataNetwork, Union{String, IO}}`: PowerModels data object or supported
load flow case (*.m, *.raw)

# Keyword arguments
- `ext::Dict`: Contains user-defined parameters. Should only contain standard types.
- `runchecks::Bool`: Run available checks on input fields and when add_component! is called.
  Throws InvalidValue if an error is found.
- `time_series_in_memory::Bool=false`: Store time series data in memory instead of HDF5.
- `config_path::String`: specify path to validation config file
- `pm_data_corrections::Bool=true` : Run the PowerModels data corrections (aka :validate in PowerModels)
- `import_all:Bool=false` : Import all fields from PTI files

# Examples
```julia
sys = System(
    pm_data, config_path = "ACTIVSg25k_validation.json",
    bus_name_formatter = x->string(x["name"]*"-"*string(x["index"])),
    load_name_formatter = x->strip(join(x["source_id"], "_"))
)
```
"""
function System(net_data::PowerFlowFileParser.PowerFlowDataNetwork; kwargs...)
    runchecks = get(kwargs, :runchecks, true)
    data = net_data.data
    if length(data.buses) < 1
        throw(DataFormatError("There are no buses in this file."))
    end

    @info "Constructing System from PowerFlowData version v$(data.caseid.rev)"

    if isa(data.caseid.sbase, Missing)
        error("Base power not specified in .raw file. Data parsing can not continue")
    end

    if isa(data.caseid.basfrq, Missing)
        @warn "Frequency value missing from .raw file. Using default 60 Hz"
        frequency = 60.0
    else
        frequency = data.caseid.basfrq
    end

    sys = System(data.caseid.sbase; frequency = frequency, kwargs...)
    bus_number_to_bus = read_bus!(sys, data.buses, data; kwargs...)
    read_loads!(sys, data.loads, data.caseid.sbase, bus_number_to_bus; kwargs...)
    read_gen!(sys, data.generators, data.caseid.sbase, bus_number_to_bus; kwargs...)
    read_branch!(
        sys,
        data.branches,
        data.caseid.sbase,
        bus_number_to_bus;
        kwargs...,
    )
    read_branch!(sys, data.transformers, data.caseid.sbase, bus_number_to_bus; kwargs...)
    read_shunt!(sys, data.fixed_shunts, data.caseid.sbase, bus_number_to_bus; kwargs...)
    read_switched_shunt!(
        sys,
        data.switched_shunts,
        data.caseid.sbase,
        bus_number_to_bus;
        kwargs...,
    )
    read_dcline!(
        sys,
        data.two_terminal_dc,
        data.caseid.sbase,
        bus_number_to_bus;
        kwargs...,
    )
    read_dcline!(
        sys,
        data.multi_terminal_dc,
        data.caseid.sbase,
        bus_number_to_bus;
        kwargs...,
    )

    read_dcline!(
        sys,
        data.vsc_dc,
        data.caseid.sbase,
        bus_number_to_bus;
        kwargs...,
    )

    if runchecks
        check(sys)
    end
    return sys
end

function read_bus!(
    sys::System,
    buses::PowerFlowData.Buses33,
    data::PowerFlowData.Network;
    kwargs...,
)
    bus_number_to_bus = Dict{Int, ACBus}()
    bus_types = instances(ACBusTypes)

    for ix in eachindex(buses.i)
        # d id the data dict for each bus
        # d_key is bus key
        bus_name = strip(buses.name[ix]) * "_$(buses.i[ix])" * "_$(buses.ide[ix])"
        has_component(ACBus, sys, bus_name) && throw(
            DataFormatError(
                "Found duplicate bus names of $bus_name, consider formatting names with `bus_name_formatter` kwarg",
            ),
        )
        bus_number = buses.i[ix]
        if isempty(data.area_interchanges)
            area_name = string(buses.area[ix])
            @debug "File doesn't contain area names"
        else
            area_ix = findfirst(data.area_interchanges.i .== buses.area[ix])
            area_name = data.area_interchanges.arname[area_ix]
        end

        area = get_component(Area, sys, area_name)
        if isnothing(area)
            area = Area(area_name)
            add_component!(sys, area; skip_validation = SKIP_PM_VALIDATION)
        end

        # TODO: LoadZones need to be created and populated here
        if isempty(data.zones)
            zone_name = string(buses.zone[ix])
            @debug "File doesn't contain load zones"
        else
            zone_ix = findfirst(data.zones.i .== buses.zone[ix])
            zone_name = "$(data.zones.zoname[zone_ix])_$(data.zones.i[zone_ix])"
        end
        zone = get_component(LoadZone, sys, zone_name)
        if isnothing(zone)
            zone = LoadZone(zone_name, 0.0, 0.0)
            add_component!(sys, zone; skip_validation = SKIP_PM_VALIDATION)
        end

        zone = get_component(LoadZone, sys, zone_name)
        if isnothing(zone)
            zone = LoadZone(zone_name, 0.0, 0.0)
            add_component!(sys, zone; skip_validation = SKIP_PM_VALIDATION)
        end

        bus = ACBus(
            bus_number,
            bus_name,
            true,
            bus_types[buses.ide[ix]],
            clamp(buses.va[ix] * (π / 180), -π / 2, π / 2),
            buses.vm[ix],
            (min = buses.nvlo[ix], max = buses.nvhi[ix]),
            buses.basekv[ix],
            area,
            zone,
        )

        bus_number_to_bus[bus_number] = bus

        add_component!(sys, bus; skip_validation = SKIP_PM_VALIDATION)
    end
    # TODO: Checking for surplus Areas or LoadZones in the data which don't get populated in the sys above
    # but are available in the raw file
    if ~isempty(data.area_interchanges)
        for area_name in data.area_interchanges.arname
            area = get_component(Area, sys, area_name)
            if isnothing(area)
                area = Area(area_name)
                add_component!(sys, area; skip_validation = SKIP_PM_VALIDATION)
            end
        end
    end

    if ~isempty(data.zones)
        for (i, name) in zip(data.zones.i, data.zones.zoname)
            zone_name = "$(name)_$(i)"
            zone = get_component(LoadZone, sys, zone_name)
            if isnothing(zone)
                zone = LoadZone(zone_name, 0.0, 0.0)
                add_component!(sys, zone; skip_validation = SKIP_PM_VALIDATION)
            end
        end
    end
    return bus_number_to_bus
end

function read_bus!(
    sys::System,
    buses::PowerFlowData.Buses30,
    data::PowerFlowData.Network;
    kwargs...,
)
    bus_number_to_bus = Dict{Int, ACBus}()

    bus_types = instances(ACBusTypes)

    for ix in 1:length(buses)
        # d id the data dict for each bus
        # d_key is bus key
        bus_name = strip(buses.name[ix]) * "_$(buses.i[ix])" * "_$(buses.ide[ix])"
        has_component(ACBus, sys, bus_name) && throw(
            DataFormatError(
                "Found duplicate bus names of $bus_name, consider formatting names with `bus_name_formatter` kwarg",
            ),
        )
        bus_number = buses.i[ix]
        if isempty(data.area_interchanges)
            area_name = string(buses.area[ix])
            @debug "File doesn't contain area names"
        else
            area_ix = data.area_interchanges.i .== buses.area[ix]
            if all(.!area_ix)
                error("Area numbering is incorrectly specified in PSSe file")
            end
            area_name = first(data.area_interchanges.arname[area_ix])
        end
        area = get_component(Area, sys, area_name)
        if isnothing(area)
            area = Area(area_name)
            add_component!(sys, area; skip_validation = SKIP_PM_VALIDATION)
        end

        # TODO: LoadZones need to be created and populated here

        bus = ACBus(
            bus_number,
            bus_name,
            true,
            bus_types[buses.ide[ix]],
            clamp(buses.va[ix] * (π / 180), -π / 2, π / 2),
            buses.vm[ix],
            nothing, # PSSe 30 data doesn't have magnitude limits
            buses.basekv[ix],
            area,
        )

        bus_number_to_bus[bus_number] = bus

        add_component!(sys, bus; skip_validation = SKIP_PM_VALIDATION)

        if buses.bl[ix] > 0 || buses.gl[ix] > 0
            shunt = FixedAdmittance(bus_name, true, bus, buses.gl[ix] + 1im * buses.bl[ix])
            add_component!(sys, shunt; skip_validation = SKIP_PM_VALIDATION)
        end
    end

    return bus_number_to_bus
end

function read_loads!(
    sys::System,
    loads::PowerFlowData.Loads,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    if isempty(loads)
        @error "There are no loads in this file"
        return
    end
    for ix in eachindex(loads.i)
        bus = bus_number_to_bus[loads.i[ix]]
        load_name = "load-$(get_name(bus))~$(loads.id[ix])"
        if has_component(StandardLoad, sys, load_name)
            throw(DataFormatError("Found duplicate load names of $(load_name)"))
        end

        load = StandardLoad(;
            name = load_name,
            available = loads.status[ix],
            bus = bus,
            constant_active_power = loads.pl[ix] / sys_mbase,
            constant_reactive_power = loads.ql[ix] / sys_mbase,
            impedance_active_power = loads.yp[ix] / sys_mbase,
            impedance_reactive_power = loads.yq[ix] / sys_mbase,
            current_active_power = loads.ip[ix] / sys_mbase,
            current_reactive_power = loads.iq[ix] / sys_mbase,
            max_constant_active_power = loads.pl[ix] / sys_mbase,
            max_constant_reactive_power = loads.ql[ix] / sys_mbase,
            max_impedance_active_power = loads.yp[ix] / sys_mbase,
            max_impedance_reactive_power = loads.yq[ix] / sys_mbase,
            max_current_active_power = loads.ip[ix] / sys_mbase,
            max_current_reactive_power = loads.iq[ix] / sys_mbase,
            base_power = sys_mbase,
        )

        add_component!(sys, load; skip_validation = SKIP_PM_VALIDATION)
    end
    # Populate Areas and LoadZones with peak active and reactive power
    areas = get_components(Area, sys)
    if ~isnothing(areas)
        for area in areas
            area_comps = get_components_in_aggregation_topology(StandardLoad, sys, area)
            if (isempty(area_comps))
                set_peak_active_power!(area, 0.0)
                set_peak_reactive_power!(area, 0.0)
            else
                set_peak_active_power!(
                    area,
                    sum(get.(get_ext.(area_comps), "active_power_load", 0.0)),
                )
                set_peak_reactive_power!(
                    area,
                    sum(get.(get_ext.(area_comps), "reactive_power_load", 0.0)),
                )
            end
        end
    end
    zones = get_components(LoadZone, sys)
    if ~isnothing(zones)
        for zone in zones
            zone_comps = get_components_in_aggregation_topology(StandardLoad, sys, zone)
            if (isempty(zone_comps))
                set_peak_active_power!(zone, 0.0)
                set_peak_reactive_power!(zone, 0.0)
            else
                set_peak_active_power!(
                    zone,
                    sum(get.(get_ext.(zone_comps), "active_power_load", 0.0)),
                )
                set_peak_reactive_power!(
                    zone,
                    sum(get.(get_ext.(zone_comps), "reactive_power_load", 0.0)),
                )
            end
        end
    end
    return nothing
end

function _get_active_power_limits(
    pt::Float64,
    pb::Float64,
    machine_base::Float64,
    system_base::Float64,
)
    min_p = 0.0
    if pb < 0.0
        @info "Min power in dataset is negative, active_power_limits minimum set to 0.0"
    else
        min_p = pb
    end

    if machine_base != system_base && pt >= machine_base
        @info "Max active power limit is $(pt/machine_base) than the generator base. Check the data"
    end

    return (min = min_p / machine_base, max = pt / machine_base)
end

function read_gen!(
    sys::System,
    gens::PowerFlowData.Generators,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @info "Reading generator data"

    if isempty(gens)
        @error "There are no generators in this file"
        return
    end

    for ix in eachindex(gens.i)
        bus = get(bus_number_to_bus, gens.i[ix], nothing)
        if isnothing(bus)
            error("Incorrect bus id for generator $(gens.i[ix])-$(gens.id[ix])")
        end

        gen_name = "gen-$(get_name(bus))~$(gens.id[ix])"
        if has_component(ThermalStandard, sys, gen_name)
            throw(DataFormatError("Found duplicate load names of $(gen_name)"))
        end
        ireg_bus_num = gens.ireg[ix] == 0 ? gens.i[ix] : gens.ireg[ix]

        thermal_gen = ThermalStandard(;
            name = gen_name,
            available = gens.stat[ix] > 0 ? true : false,
            status = gens.stat[ix] > 0 ? true : false,
            bus = bus,
            active_power = gens.pg[ix] / gens.mbase[ix],
            reactive_power = gens.qg[ix] / gens.mbase[ix],
            active_power_limits = _get_active_power_limits(
                gens.pt[ix],
                gens.pb[ix],
                gens.mbase[ix],
                sys_mbase,
            ),
            reactive_power_limits = (
                min = gens.qb[ix] / sys_mbase,
                max = gens.qt[ix] / sys_mbase,
            ),
            base_power = gens.mbase[ix],
            rating = gens.mbase[ix],
            ramp_limits = nothing,
            time_limits = nothing,
            operation_cost = ThermalGenerationCost(nothing),
            ext = Dict(
                "IREG" => ireg_bus_num,
                "WMOD" => gens.wmod[ix],
                "WPF" => gens.wpf[ix],
            ),
        )

        add_component!(sys, thermal_gen; skip_validation = SKIP_PM_VALIDATION)
    end
    return nothing
end

function read_branch!(
    sys::System,
    branches::PowerFlowData.Branches30,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @info "Reading line data"

    if isempty(branches)
        @error "There are no lines in this file"
        return
    end

    for ix in eachindex(branches.i)
        if branches.i[ix] < 0
            i_ix = abs(branches.i[ix])
            @warn "Branch index $(branches.i[ix]) corrected to $i_ix"
        end

        if branches.j[ix] < 0
            j_ix = abs(branches.i[ix])
            @warn "Branch index $(branches.j[ix]) corrected to $j_ix"
        end

        bus_from = bus_number_to_bus[abs(branches.i[ix])]
        bus_to = bus_number_to_bus[abs(branches.j[ix])]
        branch_name = "line-$(get_name(bus_from))-$(get_name(bus_to))-$(branches.ckt[ix])"
        max_rate = max(branches.rate_a[ix], branches.rate_b[ix], branches.rate_c[ix])
        if max_rate == 0.0
            max_rate = abs(1 / (branches.r[ix] + 1im * branches.x[ix])) * sys_mbase
        end
        branch = Line(;
            name = branch_name,
            available = branches.st[ix] > 0 ? true : false,
            active_power_flow = 0.0,
            reactive_power_flow = 0.0,
            arc = Arc(bus_from, bus_to),
            r = branches.r[ix],
            x = branches.x[ix],
            b = (from = branches.bi[ix], to = branches.bj[ix]),
            angle_limits = (min = -π / 2, max = π / 2),
            rating = max_rate,
        )

        add_component!(sys, branch; skip_validation = SKIP_PM_VALIDATION)
    end

    return nothing
end

function read_branch!(
    sys::System,
    branches::PowerFlowData.Branches33,
    sys_mbase::Float64,
    rating_flag::Int8,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @info "Reading line data"

    if isempty(branches)
        @error "There are no lines in this file"
        return
    end

    for ix in eachindex(branches.i)
        bus_from = bus_number_to_bus[branches.i[ix]]
        bus_to = bus_number_to_bus[branches.j[ix]]
        branch_name = "line-$(get_name(bus_from))-$(get_name(bus_to))~$(branches.ckt[ix])"

        max_rate = max(branches.rate_a[ix], branches.rate_b[ix], branches.rate_c[ix])

        if get_base_voltage(bus_from) != get_base_voltage(bus_to)
            @warn("bad line data $branch_name. Transforming this Line to Transformer2W.")
            # Method needed for NTPS to make this data into a transformer
            transformer_name = "transformer-$(get_name(bus_from))-$(get_name(bus_to))~$(branches.ckt[ix])"
            transformer = Transformer2W(;
                name = transformer_name,
                available = branches.st[ix] > 0 ? true : false,
                active_power_flow = 0.0,
                reactive_power_flow = 0.0,
                arc = Arc(bus_from, bus_to),
                r = branches.r[ix],
                x = branches.x[ix],
                primary_shunt = 0.0,
                winding_group_number = WindingGroupNumber(0),
                rating = max_rate,
                base_power = get_base_power(sys), # add system base power
                ext = Dict(
                    "line_to_xfr" => true,
                ),
            )
            add_component!(sys, transformer; skip_validation = SKIP_PM_VALIDATION)

            continue
        end

        rated_current = 0.0
        if (rating_flag > 0)
            rated_current = (max_rate / (sqrt(3) * get_base_voltage(bus_from))) * 10^3
        end

        branch = Line(;
            name = branch_name,
            available = branches.st[ix] > 0 ? true : false,
            active_power_flow = 0.0,
            reactive_power_flow = 0.0,
            arc = Arc(bus_from, bus_to),
            r = branches.r[ix],
            x = branches.x[ix],
            b = (from = branches.bi[ix], to = branches.bj[ix]),
            angle_limits = (min = -π / 2, max = π / 2),
            rating = max_rate,
            ext = Dict(
                "length" => branches.len[ix],
                "rated_current(A)" => rated_current,
            ),
        )

        add_component!(sys, branch; skip_validation = SKIP_PM_VALIDATION)
    end

    return nothing
end

function read_branch!(
    sys::System,
    transformers::PowerFlowData.Transformers,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @info "Reading transformer data"

    if isempty(transformers)
        @error "There are no transformers in this file"
        return
    end

    for ix in eachindex(transformers.i)
        bus_i = bus_number_to_bus[transformers.i[ix]]
        bus_j = bus_number_to_bus[transformers.j[ix]]
        if transformers.k[ix] > 0
            @error "Three-winding transformer from PowerFlowData inputs not implemented. Data will be ignored"
            continue
        else
            to_from_name = "$(get_name(bus_i))-$(get_name(bus_j))"
        end

        if transformers.ang1[ix] != 0
            @error "Phase Shifting transformer from PowerFlowData inputs not implemented. Data will be ignored"
            continue
        end

        transformer_name = "transformer-$to_from_name-$(transformers.ckt[ix])"

        if !(transformers.cz[ix] in [1, 2, 3])
            @warn(
                "transformer CZ value outside of valid bounds assuming the default value of 1.  Given $(transformer["CZ"]), should be 1, 2 or 3",
            )
            transformers.cz[ix] = 1
        end

        if !(transformers.cw[ix] in [1, 2, 3])
            @warn(
                "transformer CW value outside of valid bounds assuming the default value of 1.  Given $(transformer["CW"]), should be 1, 2 or 3",
            )
            transformers.cw[ix] = 1
        end

        if !(transformers.cm[ix] in [1, 2])
            @warn(
                "transformer CM value outside of valid bounds assuming the default value of 1.  Given $(transformer["CM"]), should be 1 or 2",
            )
            transformers.cm[ix] = 1
        end

        # Unit Transformations
        if transformers.cz[ix] == 1  # "for resistance and reactance in pu on system MVA base and winding voltage base"
            br_r, br_x = transformers.r1_2[ix], transformers.x1_2[ix]
        else  # NOT "for resistance and reactance in pu on system MVA base and winding voltage base"
            if transformers.cz[ix] == 3  # "for transformer load loss in watts and impedance magnitude in pu on a specified MVA base and winding voltage base."
                br_r = 1e-6 * transformers.r1_2[ix] / transformers.sbase1_2[ix]
                br_x = sqrt(transformers.x1_2[ix]^2 - br_r^2)
            else
                br_r, br_x = transformers.r1_2[ix], transformers.x1_2[ix]
            end
            per_unit_factor =
                (
                    transformers.nomv1[ix]^2 /
                    get_base_voltage(bus_i)^2
                ) * (sys_mbase / transformers.sbase1_2[ix])
            if per_unit_factor == 0
                @warn "Per unit conversion for transformer $to_from_name couldn't be done, assuming system base instead. Check field NOMV1 is valid"
                per_unit_factor = 1
            end
            br_r *= per_unit_factor
            br_x *= per_unit_factor
        end

        # Zeq scaling for tap2 (see eq (4.21b) in PROGRAM APPLICATION GUIDE 1 in PSSE installation folder)
        # Unit Transformations
        if transformers.cw[ix] == 1  # "for off-nominal turns ratio in pu of winding bus base voltage"
            br_r *= transformers.windv2[ix]^2
            br_x *= transformers.windv2[ix]^2
        else  # NOT "for off-nominal turns ratio in pu of winding bus base voltage"
            if transformers.cw[ix] == 2  # "for winding voltage in kV"
                br_r *=
                    (
                        transformers.windv2[ix] /
                        get_base_voltage(bus_j)
                    )^2
                br_x *=
                    (
                        transformers.windv2[ix] /
                        get_base_voltage(bus_j)
                    )^2
            else  # "for off-nominal turns ratio in pu of nominal winding voltage, NOMV1, NOMV2 and NOMV3."
                br_r *=
                    (
                        transformers.windv2[ix] * (
                            transformers.nomv2[ix] /
                            get_base_voltage(bus_j)
                        )
                    )^2
                br_x *=
                    (
                        transformers.windv2[ix] * (
                            transformers.nomv2[ix] /
                            get_base_voltage(bus_j)
                        )
                    )^2
            end
        end

        max_rate =
            max(transformers.rata1[ix], transformers.ratb1[ix], transformers.ratc1[ix])

        tap_value = transformers.windv1[ix] / transformers.windv2[ix]

        # Unit Transformations
        if transformers.cw[ix] != 1  # NOT "for off-nominal turns ratio in pu of winding bus base voltage"
            tap_value *= get_base_voltage(bus_j) / get_base_voltage(bus_i)
            if transformers.cw[ix] == 3  # "for off-nominal turns ratio in pu of nominal winding voltage, NOMV1, NOMV2 and NOMV3."
                tap_value *= transformers.nomv1[ix] / transformers.nomv2[ix]
            end
        end

        transformer = TapTransformer(;
            name = transformer_name,
            available = transformers.stat[ix] > 0 ? true : false,
            active_power_flow = 0.0,
            reactive_power_flow = 0.0,
            arc = Arc(bus_i, bus_j),
            r = br_r,
            x = br_x,
            tap = tap_value,
            primary_shunt = transformers.mag2[ix],
            winding_group_number = WindingGroupNumber(0),
            base_power = get_base_power(sys),
            rating = max_rate,
        )
        add_component!(sys, transformer; skip_validation = SKIP_PM_VALIDATION)
    end

    return nothing
end

function read_shunt!(
    ::System,
    ::Nothing,
    ::Float64,
    ::Dict{Int, ACBus};
    kwargs...,
)
    @debug "No data for Fixed Shunts"
    return
end

function read_shunt!(
    sys::System,
    data::PowerFlowData.FixedShunts,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @error "FixedShunts parsing from PowerFlowData inputs not implemented. Data will be ignored"
    return
end

function read_switched_shunt!(
    sys::System,
    ::Nothing,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @debug "No data for Switched Shunts"
    return
end

function read_switched_shunt!(
    sys::System,
    ::PowerFlowData.SwitchedShunts30,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @error "SwitchedShunts parsing from PSS/e v30 files not implemented. Data will be ignored"
    return
end

function read_switched_shunt!(
    sys::System,
    data::PowerFlowData.SwitchedShunts33,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @info "Reading line data"
    @warn "All switched shunts will be converted to fixed shunts"

    if isempty(data)
        @error "There are no lines in this file"
        return
    end

    @error "SwitchedShunts parsing from PSS/e v33 files not implemented. Data will be ignored"
    return
end

function read_dcline!(
    sys::System,
    ::Nothing,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @debug "No data for HVDC Line"
    return
end

function read_dcline!(
    sys::System,
    data::PowerFlowData.TwoTerminalDCLines30,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @error "TwoTerminalDCLines parsing from PSS/e v30 files not implemented. Data will be ignored"
    return
end

function read_dcline!(
    sys::System,
    data::PowerFlowData.TwoTerminalDCLines33,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    return
end

function read_dcline!(
    sys::System,
    data::PowerFlowData.VSCDCLines,
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @error "VSCDCLines parsing from PSS/e files not implemented. Data will be ignored"
    return
end

function read_dcline!(
    sys::System,
    data::PowerFlowData.MultiTerminalDCLines{PowerFlowData.DCLineID30},
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @error "MultiTerminalDCLines parsing from PSS/e files v30 not implemented. Data will be ignored"
    return
end

function read_dcline!(
    sys::System,
    data::PowerFlowData.MultiTerminalDCLines{PowerFlowData.DCLineID33},
    sys_mbase::Float64,
    bus_number_to_bus::Dict{Int, ACBus};
    kwargs...,
)
    @error "MultiTerminalDCLines parsing from PSS/e files v30 not implemented. Data will be ignored"
    return
end
