# "smart" summary and REPL printing

# Getters for unit-bearing fields declare their display-units choice via the
# `IS.display_units_arg` trait (set by the struct-generator template, default
# `missing` for plain getters). Prefer the trait's unit (typically `SU`),
# falling back to `DU` if the component isn't system-attached.
function _show_accessor_value(getter_func::Function, ist::Component)
    arg = IS.display_units_arg(getter_func, typeof(ist))
    ismissing(arg) && return getter_func(ist)
    try
        return getter_func(ist, arg)
    catch err
        err isa ErrorException && occursin("not attached", err.msg) || rethrow()
        return getter_func(ist, DU)
    end
end

function Base.summary(sys::System)
    return "System (base power $(get_base_power(sys)))"
end

function Base.show(io::IO, sys::System)
    show_system_table(io, sys; backend = :auto)

    if IS.get_num_components(sys) > 0
        show_components_table(io, sys; backend = :auto)
    end

    println(io)
    IS.show_time_series_data(io, sys.data; backend = :auto)
    return
end

Base.show(io::IO, ::MIME"text/plain", sys::System) = show(io, sys)

function Base.summary(io::IO, tech::DeviceParameter)
    print(io, "$(typeof(tech))")
end

function Base.summary(io::IO, data::OperationalCost)
    field_msgs = []
    for field_name in fieldnames(typeof(data))
        val = getproperty(data, field_name)
        # Only the most important fields
        (val isa ProductionVariableCostCurve) &&
            push!(field_msgs, "$(field_name): $(typeof(val))")
        (val isa TimeSeriesKey) &&
            push!(field_msgs, "$(field_name): time series \"$(get_name(val))\"")
    end
    isempty(field_msgs) && return
    print(io, "$(typeof(data)) composed of ")
    join(io, field_msgs, ", ")
end

function Base.show(io::IO, ::MIME"text/plain", data::OperationalCost)
    print(io, "$(typeof(data)): ")
    for field_name in fieldnames(typeof(data))
        val = getproperty(data, field_name)
        val_printout =
            replace(sprint(show, "text/plain", val; context = io), "\n" => "\n  ")
        print(io, "\n  $(field_name): $val_printout")
    end
end

function Base.show(io::IO, ist::Component)
    print(io, IS.strip_module_name(typeof(ist)), "(")
    is_first = true
    for (name, field_type) in zip(fieldnames(typeof(ist)), fieldtypes(typeof(ist)))
        getter_name = Symbol("get_$name")
        if field_type <: InfrastructureSystemsInternal
            continue
        elseif hasproperty(PowerSystems, getter_name)
            getter_func = getproperty(PowerSystems, getter_name)
            val = _show_accessor_value(getter_func, ist)
        else
            val = getproperty(ist, name)
        end
        if is_first
            is_first = false
        else
            print(io, ", ")
        end
        print(io, val)
    end
    print(io, ")")
    return
end

function Base.show(io::IO, ::MIME"text/plain", ist::Component)
    default_units = false
    if !has_units_setting(ist)
        print(io, "\n")
        @warn(
            "SystemUnitSetting not defined, using NATURAL_UNITS for displaying device specification."
        )
        set_units_setting!(
            ist,
            SystemUnitsSettings(100.0, UNIT_SYSTEM_MAPPING["NATURAL_UNITS"]),
        )
        default_units = true
    end
    try
        print(io, summary(ist), ":")
        for name in fieldnames(typeof(ist))
            obj = getproperty(ist, name)
            getter_name = Symbol("get_$name")
            if (obj isa InfrastructureSystemsInternal) && !default_units
                print(io, "\n   ")
                show(io, MIME"text/plain"(), obj.units_info)
                continue
            elseif obj isa InfrastructureSystemsType ||
                   obj isa Vector{<:InfrastructureSystemsComponent}
                val = summary(getproperty(ist, name))
            elseif hasproperty(PowerSystems, getter_name)
                getter_func = getproperty(PowerSystems, getter_name)
                val = _show_accessor_value(getter_func, ist)
            else
                val = getproperty(ist, name)
            end
            print(io, "\n   ", name, ": ", val)
        end
        print(
            io,
            "\n   ",
            "has_supplemental_attributes",
            ": ",
            string(has_supplemental_attributes(ist)),
        )
        print(io, "\n   ", "has_time_series", ": ", string(has_time_series(ist)))
    finally
        if default_units
            set_units_setting!(ist, nothing)
        end
    end
    return
end

"""
Show all components of the given type in a table.

# Arguments
- `sys::System`: System containing the components.
- `component_type::Type{<:Component}`: Type to display. Must be a concrete type.
- `additional_columns::Union{Dict, Vector}`: Additional columns to display.
  The Dict option is a mapping of column name to function. The function must accept
  a component.
  The Vector option is an array of field names for the `component_type`.

Extra keyword arguments are forwarded to PrettyTables.pretty_table.

# Examples
```julia
show_components(sys, ThermalStandard)
show_components(sys, ThermalStandard, Dict("has_time_series" => x -> has_time_series(x)))
show_components(sys, ThermalStandard, [:active_power, :reactive_power])
```
"""
function show_components(
    sys::System,
    component_type::Type{<:Component},
    additional_columns::Union{Dict, Vector} = Dict();
    kwargs...,
)
    show_components(stdout, sys, component_type, additional_columns; kwargs...)
    return
end

function show_components(
    io::IO,
    sys::System,
    component_type::Type{<:Component},
    additional_columns::Union{Dict, Vector} = Dict();
    kwargs...,
)
    IS.show_components(
        io,
        sys.data.components,
        component_type,
        additional_columns;
        kwargs...,
    )
    return
end

# The placement of the type in the argument list has been confusing for people. Support
# it both before and after the system.

show_components(
    component_type::Type{<:Component},
    sys::System,
    additional_columns::Union{Dict, Vector} = Dict();
    kwargs...,
) = show_components(sys, component_type, additional_columns; kwargs...)

show_components(
    io::IO,
    component_type::Type{<:Component},
    sys::System,
    additional_columns::Union{Dict, Vector} = Dict();
    kwargs...,
) = show_components(io, sys, component_type, additional_columns; kwargs...)

"""
Show a table with the summary of time series attached to the system.
"""
function show_time_series(sys::System)
    IS.show_time_series_data(stdout, sys.data)
end
