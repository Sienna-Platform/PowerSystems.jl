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
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function GenericArcImpedance(name, available, active_power_flow, reactive_power_flow, max_flow, arc, r, x, ext=Dict{String, Any}(), )
    GenericArcImpedance(name, available, active_power_flow, reactive_power_flow, max_flow, arc, r, x, ext, InfrastructureSystemsInternal(), )
end

function GenericArcImpedance(; name, available, active_power_flow, reactive_power_flow, max_flow, arc, r, x, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    GenericArcImpedance(name, available, active_power_flow, reactive_power_flow, max_flow, arc, r, x, ext, internal, )
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
        ext=Dict{String, Any}(),
    )
end

"""Get [`GenericArcImpedance`](@ref) `name`."""
get_name(value::GenericArcImpedance) = value.name
"""Get [`GenericArcImpedance`](@ref) `available`."""
get_available(value::GenericArcImpedance) = value.available
"""Get [`GenericArcImpedance`](@ref) `active_power_flow`."""
get_active_power_flow(value::GenericArcImpedance) = get_value(value, Val(:active_power_flow), Val(:mva))
"""Get [`GenericArcImpedance`](@ref) `reactive_power_flow`."""
get_reactive_power_flow(value::GenericArcImpedance) = get_value(value, Val(:reactive_power_flow), Val(:mva))
"""Get [`GenericArcImpedance`](@ref) `max_flow`."""
get_max_flow(value::GenericArcImpedance) = get_value(value, Val(:max_flow), Val(:mva))
"""Get [`GenericArcImpedance`](@ref) `arc`."""
get_arc(value::GenericArcImpedance) = value.arc
"""Get [`GenericArcImpedance`](@ref) `r`."""
get_r(value::GenericArcImpedance) = get_value(value, Val(:r), Val(:ohm))
"""Get [`GenericArcImpedance`](@ref) `x`."""
get_x(value::GenericArcImpedance) = get_value(value, Val(:x), Val(:ohm))
"""Get [`GenericArcImpedance`](@ref) `ext`."""
get_ext(value::GenericArcImpedance) = value.ext
"""Get [`GenericArcImpedance`](@ref) `internal`."""
get_internal(value::GenericArcImpedance) = value.internal

"""Set [`GenericArcImpedance`](@ref) `available`."""
set_available!(value::GenericArcImpedance, val) = value.available = val
"""Set [`GenericArcImpedance`](@ref) `active_power_flow`."""
set_active_power_flow!(value::GenericArcImpedance, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mva))
"""Set [`GenericArcImpedance`](@ref) `reactive_power_flow`."""
set_reactive_power_flow!(value::GenericArcImpedance, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mva))
"""Set [`GenericArcImpedance`](@ref) `max_flow`."""
set_max_flow!(value::GenericArcImpedance, val) = value.max_flow = set_value(value, Val(:max_flow), val, Val(:mva))
"""Set [`GenericArcImpedance`](@ref) `arc`."""
set_arc!(value::GenericArcImpedance, val) = value.arc = val
"""Set [`GenericArcImpedance`](@ref) `r`."""
set_r!(value::GenericArcImpedance, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
"""Set [`GenericArcImpedance`](@ref) `x`."""
set_x!(value::GenericArcImpedance, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
"""Set [`GenericArcImpedance`](@ref) `ext`."""
set_ext!(value::GenericArcImpedance, val) = value.ext = val
