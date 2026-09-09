#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct GenericArcImpedance <: ACTransmission
        name::String
        available::Bool
        active_power_flow::Float64
        reactive_power_flow::Float64
        max_flow::Float64
        arc::Arc
        r::Float64
        x::Float64
        base_power::Float64
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A virtual impedance between two buses that does not correspond to a physical component. This can be used to model the effects of network reductions (e.g. Ward reduction).

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow on the line (MW)
- `reactive_power_flow::Float64`: Initial condition of reactive power flow on the line (MVAR)
- `max_flow::Float64`: Maximum allowable flow on the generic impedance. When defining a GenericArcImpedance before it is attached to a `System`, `max_flow` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to
- `arc::Arc`: An [`Arc`](@ref) defining this line `from` a bus `to` another bus
- `r::Float64`: Resistance in pu ([`SYSTEM_BASE`](@ref per_unit))
- `x::Float64`: Reactance in pu ([`SYSTEM_BASE`](@ref per_unit))
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct GenericArcImpedance <: ACTransmission
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Initial condition of active power flow on the line (MW)"
    active_power_flow::Float64
    "Initial condition of reactive power flow on the line (MVAR)"
    reactive_power_flow::Float64
    "Maximum allowable flow on the generic impedance. When defining a GenericArcImpedance before it is attached to a `System`, `max_flow` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to"
    max_flow::Float64
    "An [`Arc`](@ref) defining this line `from` a bus `to` another bus"
    arc::Arc
    "Resistance in pu ([`SYSTEM_BASE`](@ref per_unit))"
    r::Float64
    "Reactance in pu ([`SYSTEM_BASE`](@ref per_unit))"
    x::Float64
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function GenericArcImpedance(name, available, active_power_flow, reactive_power_flow, max_flow, arc, r, x, base_power=100.0, ext=Dict{String, Any}(), )
    GenericArcImpedance(name, available, active_power_flow, reactive_power_flow, max_flow, arc, r, x, base_power, ext, InfrastructureSystemsInternal(), )
end

function GenericArcImpedance(; name, available, active_power_flow, reactive_power_flow, max_flow, arc, r, x, base_power=100.0, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    GenericArcImpedance(name, available, active_power_flow, reactive_power_flow, max_flow, arc, r, x, base_power, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function GenericArcImpedance(::Nothing)
    GenericArcImpedance(;
        name="init",
        available=false,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        max_flow=0.0,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        r=0.0,
        x=0.0,
        base_power=100.0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`GenericArcImpedance`](@ref) `name`."""
get_name(value::GenericArcImpedance) = value.name
"""Get [`GenericArcImpedance`](@ref) `available`."""
get_available(value::GenericArcImpedance) = value.available
"""Get [`GenericArcImpedance`](@ref) `active_power_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_flow_unitful`](@ref)."""
get_active_power_flow(value::GenericArcImpedance, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_flow), Val(:mw), units))
"""Get [`GenericArcImpedance`](@ref) `active_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_flow`](@ref)."""
get_active_power_flow_unitful(value::GenericArcImpedance, units) = get_value(value, Val(:active_power_flow), Val(:mw), units)
get_active_power_flow(value::GenericArcImpedance) = _units_arg_required(get_active_power_flow, value, :active_power_flow, Val(:mw))
get_active_power_flow_unitful(value::GenericArcImpedance) = _units_arg_required(get_active_power_flow_unitful, value, :active_power_flow, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{GenericArcImpedance}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_unitful), ::Type{GenericArcImpedance}) = InfrastructureSystems.SU
"""Get [`GenericArcImpedance`](@ref) `reactive_power_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_flow_unitful`](@ref)."""
get_reactive_power_flow(value::GenericArcImpedance, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_flow), Val(:mvar), units))
"""Get [`GenericArcImpedance`](@ref) `reactive_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_flow`](@ref)."""
get_reactive_power_flow_unitful(value::GenericArcImpedance, units) = get_value(value, Val(:reactive_power_flow), Val(:mvar), units)
get_reactive_power_flow(value::GenericArcImpedance) = _units_arg_required(get_reactive_power_flow, value, :reactive_power_flow, Val(:mvar))
get_reactive_power_flow_unitful(value::GenericArcImpedance) = _units_arg_required(get_reactive_power_flow_unitful, value, :reactive_power_flow, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_flow), ::Type{GenericArcImpedance}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_flow_unitful), ::Type{GenericArcImpedance}) = InfrastructureSystems.SU
"""Get [`GenericArcImpedance`](@ref) `max_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_flow_unitful`](@ref)."""
get_max_flow(value::GenericArcImpedance, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_flow), Val(:mw), units))
"""Get [`GenericArcImpedance`](@ref) `max_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_flow`](@ref)."""
get_max_flow_unitful(value::GenericArcImpedance, units) = get_value(value, Val(:max_flow), Val(:mw), units)
get_max_flow(value::GenericArcImpedance) = _units_arg_required(get_max_flow, value, :max_flow, Val(:mw))
get_max_flow_unitful(value::GenericArcImpedance) = _units_arg_required(get_max_flow_unitful, value, :max_flow, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_max_flow), ::Type{GenericArcImpedance}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_flow_unitful), ::Type{GenericArcImpedance}) = InfrastructureSystems.SU
"""Get [`GenericArcImpedance`](@ref) `arc`."""
get_arc(value::GenericArcImpedance) = value.arc
"""Get [`GenericArcImpedance`](@ref) `r` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_r_unitful`](@ref)."""
get_r(value::GenericArcImpedance, units) = InfrastructureSystems._strip_units(get_value(value, Val(:r), Val(:ohm), units))
"""Get [`GenericArcImpedance`](@ref) `r` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_r`](@ref)."""
get_r_unitful(value::GenericArcImpedance, units) = get_value(value, Val(:r), Val(:ohm), units)
get_r(value::GenericArcImpedance) = _units_arg_required(get_r, value, :r, Val(:ohm))
get_r_unitful(value::GenericArcImpedance) = _units_arg_required(get_r_unitful, value, :r, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_r), ::Type{GenericArcImpedance}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_r_unitful), ::Type{GenericArcImpedance}) = InfrastructureSystems.SU
"""Get [`GenericArcImpedance`](@ref) `x` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_x_unitful`](@ref)."""
get_x(value::GenericArcImpedance, units) = InfrastructureSystems._strip_units(get_value(value, Val(:x), Val(:ohm), units))
"""Get [`GenericArcImpedance`](@ref) `x` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_x`](@ref)."""
get_x_unitful(value::GenericArcImpedance, units) = get_value(value, Val(:x), Val(:ohm), units)
get_x(value::GenericArcImpedance) = _units_arg_required(get_x, value, :x, Val(:ohm))
get_x_unitful(value::GenericArcImpedance) = _units_arg_required(get_x_unitful, value, :x, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_x), ::Type{GenericArcImpedance}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_x_unitful), ::Type{GenericArcImpedance}) = InfrastructureSystems.SU

_get_base_power(value::GenericArcImpedance) = value.base_power
"""Get [`GenericArcImpedance`](@ref) `ext`."""
get_ext(value::GenericArcImpedance) = value.ext
"""Get [`GenericArcImpedance`](@ref) `internal`."""
get_internal(value::GenericArcImpedance) = value.internal

"""Set [`GenericArcImpedance`](@ref) `available`."""
set_available!(value::GenericArcImpedance, val) = value.available = val
"""Set [`GenericArcImpedance`](@ref) `active_power_flow`."""
set_active_power_flow!(value::GenericArcImpedance, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mw))
set_active_power_flow!(value::GenericArcImpedance, val::_UntaggedNumber) = _units_tag_required(set_active_power_flow!, value, :active_power_flow, Val(:mw), val)
"""Set [`GenericArcImpedance`](@ref) `reactive_power_flow`."""
set_reactive_power_flow!(value::GenericArcImpedance, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mvar))
set_reactive_power_flow!(value::GenericArcImpedance, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_flow!, value, :reactive_power_flow, Val(:mvar), val)
"""Set [`GenericArcImpedance`](@ref) `max_flow`."""
set_max_flow!(value::GenericArcImpedance, val) = value.max_flow = set_value(value, Val(:max_flow), val, Val(:mw))
set_max_flow!(value::GenericArcImpedance, val::_UntaggedNumber) = _units_tag_required(set_max_flow!, value, :max_flow, Val(:mw), val)
"""Set [`GenericArcImpedance`](@ref) `arc`."""
set_arc!(value::GenericArcImpedance, val) = value.arc = val
"""Set [`GenericArcImpedance`](@ref) `r`."""
set_r!(value::GenericArcImpedance, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
set_r!(value::GenericArcImpedance, val::_UntaggedNumber) = _units_tag_required(set_r!, value, :r, Val(:ohm), val)
"""Set [`GenericArcImpedance`](@ref) `x`."""
set_x!(value::GenericArcImpedance, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
set_x!(value::GenericArcImpedance, val::_UntaggedNumber) = _units_tag_required(set_x!, value, :x, Val(:ohm), val)
"""Set [`GenericArcImpedance`](@ref) `ext`."""
set_ext!(value::GenericArcImpedance, val) = value.ext = val
