# "smart" summary and REPL printing

# Getters for unit-bearing fields declare their display-units choice via the
# `IS.display_units_arg` trait (set by the struct-generator template, default
# `u"SU"` for converted fields unless overridden per field in the descriptor,
# e.g. `rating` fields default to `u"CU"`). Pass `units` to force a specific
# display unit system (e.g. `u"MW"`, `u"SU"`, `u"CU"`, `u"NU"`) instead of resolving the
# trait; an explicit request that fails is an error, not a silent fallback.
# `IS.unitful_variant` resolves the getter's `_unitful` companion (a quantity printing as
# "0.3 SU" or "30.0 MW") instead of a bare number.

# Verbose display spells per-unit units out ("1.25 p.u. in system base"): `SU`/`CU` are
# this package's shorthand, not standard terminology. IS's `display_string` factors a
# shared base out of a compound field.
IS.display_base_label(q::Quantity) = _base_label(_per_unit_basis(Unitful.unit(q)))
IS.display_value(q::Quantity) = replace(string(q), r"\b[CS]U\b" => "p.u."; count = 1)

_base_label(::Val{:component}) = "component base"
_base_label(::Val{:system}) = "system base"
_base_label(::Val{:natural}) = nothing

# Which base a quantity's units are per-unit on, from their dimensions.
@generated function _per_unit_basis(u::Unitful.Units)
    names = map(
        d -> typeof(d).parameters[1],
        typeof(Unitful.dimension(u.instance)).parameters[1],
    )
    :GenericSystemBase in names && return :(Val(:system))
    :GenericComponentBase in names && return :(Val(:component))
    return :(Val(:natural))
end

# The trait's units with its generic unit swapped for `generic`, residual kept: a ramp's
# `u"SU/minute"` falls back to `u"NU/minute"`, then `u"CU/minute"`.
_with_generic(units, generic) = IS.resolve_per_unit(units, generic, generic, generic)

# `getter_func` is deliberately not a type parameter: both callers resolve it through
# `getproperty(PowerSystems, ::Symbol)`, so there is no concrete type to specialize on.
function _show_accessor_value(getter_func::Function, ist::Component; units = nothing)
    trait_arg = IS.display_units_arg(getter_func, typeof(ist))
    # Fields without a units trait (e.g. `get_name`) aren't unit-convertible at
    # all — an explicit `units` override must not force a units argument onto
    # a getter that doesn't accept one.
    ismissing(trait_arg) && return getter_func(ist)
    arg = if isnothing(units)
        trait_arg
    else
        units
    end
    unitful_func = IS.unitful_variant(getter_func)
    try
        return unitful_func(ist, arg)
    catch err
        # An explicit `units` request that fails is a caller error worth
        # surfacing, not something display should paper over — only the
        # trait's own automatic resolution gets the never-error fallback below.
        isnothing(units) || rethrow()
        err isa ErrorException && occursin("not attached", err.msg) || rethrow()
        # NU can also fail (it may need the system base or a base voltage).
        # Automatic resolution must never error: fall back to the raw stored
        # value, which the CU conversion returns without touching any base.
        # Only swallow the engine's own ErrorExceptions — a MethodError here
        # is a bug.
        try
            return unitful_func(ist, _with_generic(trait_arg, u"NU"))
        catch err2
            err2 isa ErrorException || rethrow()
            return unitful_func(ist, _with_generic(trait_arg, u"CU"))
        end
    end
end

function Base.summary(sys::System)
    return "System (base power $(_get_base_power(sys)))"
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
        # A key carries only its association id; the name is a catalog column, and a
        # summary must not query the store to print one.
        (val isa TimeSeriesKey) &&
            push!(
                field_msgs,
                "$(field_name): time series association_id=$(get_association_id(val))",
            )
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

"""
Print `ist` to `io` in the same verbose form as the REPL's `text/plain` display of a
`Component`. Pass `units` (e.g. `u"MW"`, `u"SU"`, `u"CU"`, `u"NU"`) to force every unit-converted
field to display in that unit system instead of resolving each field's own
`display_units_arg` default (system base when attached, natural units otherwise, and
component base for capacity/`rating`-style fields).

# Examples
```julia
show_component(gen)
show_component(gen; units = u"MW")
```
"""
function show_component(io::IO, ist::Component; units = nothing)
    print(io, summary(ist), ":")
    for name in fieldnames(typeof(ist))
        obj = getproperty(ist, name)
        getter_name = Symbol("get_$name")
        if obj isa InfrastructureSystemsInternal
            base_value = IS.get_base_value(obj)
            if !isnothing(base_value)
                print(io, "\n   System base power (MVA): ", base_value)
            end
            continue
        elseif obj isa InfrastructureSystemsType ||
               obj isa Vector{<:InfrastructureSystemsComponent}
            val = summary(getproperty(ist, name))
        elseif hasproperty(PowerSystems, getter_name)
            getter_func = getproperty(PowerSystems, getter_name)
            val = _show_accessor_value(getter_func, ist; units = units)
        else
            val = getproperty(ist, name)
        end
        # `display_string` spells per-unit units out as "p.u. in {component,system} base":
        # the terse tags read as jargon in a component's verbose display, where
        # there is room to be explicit. Terse contexts (the compact one-line
        # `show`, table cells) keep the short tags.
        print(io, "\n   ", name, ": ", IS.display_string(val))
    end
    print(
        io,
        "\n   ",
        "has_supplemental_attributes",
        ": ",
        string(has_supplemental_attributes(ist)),
    )
    print(io, "\n   ", "has_time_series", ": ", string(has_time_series(ist)))
    note = _component_base_note(ist)
    isnothing(note) || print(io, "\n   (", note, ")")
    return
end

show_component(ist::Component; units = nothing) = show_component(stdout, ist; units = units)

# Dynamic models are not wired into the units engine: their parameters are plain
# `Float64`s with no `needs_conversion` descriptor entry, so display cannot tag them
# field by field. They are, by the modeling convention every dynamics parser and
# simulator assumes, per-unitized on the device's own `base_power` — state that once
# as a footer rather than leaving the numbers unlabeled.
_component_base_note(::Component) = nothing
function _component_base_note(d::DynamicInjection)
    # Read the field, not `_get_base_power`: the dynamic injection types that have
    # no `base_power` field of their own fall back to the system base, which errors
    # for a detached component — and display must never error.
    base = hasfield(typeof(d), :base_power) ? " of $(d.base_power) MVA" : ""
    return "parameters of the dynamic components above are in p.u. on the component base$base"
end

# The dynamic-model parameter blocks: machines, shafts, AVRs, turbine governors, PSSs,
# and the inverter-side converters, filters, and controls. `ActivePowerControl` and
# `ReactivePowerControl` sit directly under `DeviceParameter` rather than under
# `DynamicComponent`, so they are named separately.
const DynamicParameterBlock =
    Union{DynamicComponent, ActivePowerControl, ReactivePowerControl}

"""
Print a dynamic-model parameter block (a machine, shaft, AVR, turbine governor, PSS,
converter, filter, control, ...) to `io` field by field, in the same shape as
[`show_component`](@ref). These blocks are [`DeviceParameter`](@ref)s rather than
[`Component`](@ref)s, so without this they fall back to Julia's single-line struct dump.

The footer records that the values are per-unitized on the parent device's `base_power`:
dynamic models are not wired into the explicit-units engine, so there is no per-field unit
to print.

# Examples
```julia
show_device_parameter(get_machine(dyn_gen))
```
"""
function show_device_parameter(io::IO, tech::DynamicParameterBlock)
    print(io, IS.strip_module_name(typeof(tech)), ":")
    for name in fieldnames(typeof(tech))
        obj = getproperty(tech, name)
        obj isa InfrastructureSystemsInternal && continue
        val = obj isa InfrastructureSystemsType ? summary(obj) : IS.display_string(obj)
        print(io, "\n   ", name, ": ", val)
    end
    print(io, "\n   (parameters in p.u. on the parent device's base power)")
    return
end

show_device_parameter(tech::DynamicParameterBlock) = show_device_parameter(stdout, tech)

Base.show(io::IO, ::MIME"text/plain", tech::DynamicParameterBlock) =
    show_device_parameter(io, tech)

function Base.show(io::IO, ::MIME"text/plain", ist::Component)
    if !has_units_setting(ist)
        @warn(
            "Component is not attached to a System; each field displays in its own " *
            "fallback units (natural units, or component base for fields like `rating` " *
            "that default to component-base display)."
        )
    end
    show_component(io, ist)
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
  The Vector option is an array of field names for the `component_type`; unit-converted
  fields are printed with an explicit unit suffix (e.g. `"30.0 MW"`, `"1.0 CU"`).

# Keyword Arguments
- `units`: When `additional_columns` is a `Vector`, force unit-converted columns to
  display in a given unit system (e.g. `u"MW"`, `u"SU"`, `u"CU"`, `u"NU"`) instead of each field's
  own `display_units_arg` default. Pass a single unit to apply it to every column, or a
  column-to-unit mapping (`Dict` or `NamedTuple`) to set units per field; columns absent
  from the mapping keep their own default. Ignored for `Dict`-form `additional_columns`,
  whose functions compute their own values.
- Remaining keyword arguments are forwarded to `PrettyTables.pretty_table`.

# Examples
```julia
show_components(sys, ThermalStandard)
show_components(sys, ThermalStandard, Dict("has_time_series" => x -> has_time_series(x)))
show_components(sys, ThermalStandard, [:active_power, :reactive_power])
show_components(sys, ThermalStandard, [:rating]; units = u"MW")
show_components(sys, ThermalStandard, [:active_power, :rating];
    units = Dict(:active_power => u"MW", :rating => u"CU"))
```
"""
function show_components(
    sys::System,
    component_type::Type{<:Component},
    additional_columns::Union{Dict, Vector} = Dict();
    units = nothing,
    kwargs...,
)
    show_components(
        stdout,
        sys,
        component_type,
        additional_columns;
        units = units,
        kwargs...,
    )
    return
end

function show_components(
    io::IO,
    sys::System,
    component_type::Type{<:Component},
    additional_columns::Union{Dict, Vector} = Dict();
    units = nothing,
    kwargs...,
)
    IS.show_components(
        io,
        sys.data.components,
        component_type,
        additional_columns;
        units = units,
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
