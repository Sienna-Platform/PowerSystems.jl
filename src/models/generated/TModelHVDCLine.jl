#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TModelHVDCLine <: DCBranch
        name::String
        available::Bool
        active_power_flow::Float64
        arc::Arc
        r::Float64
        l::Float64
        c::Float64
        active_power_limits_from::MinMax
        active_power_limits_to::MinMax
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A High Voltage DC transmission line for modeling DC transmission networks.

This line must be connected to a [`DCBus`](@ref) on each end. It uses a T-Model of the line impedance. This is suitable for operational simulations with a multi-terminal DC network

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow on the line (MW)
- `arc::Arc`: An [`Arc`](@ref) defining this line `from` a bus `to` another bus
- `r::Float64`: Total series Resistance in p.u. ([`SYSTEM_BASE`](@ref per_unit)), split equally on both sides of the shunt capacitance
- `l::Float64`: Total series Inductance in p.u. ([`SYSTEM_BASE`](@ref per_unit)), split equally on both sides of the shunt capacitance
- `c::Float64`: Shunt capacitance in p.u. ([`SYSTEM_BASE`](@ref per_unit))
- `active_power_limits_from::MinMax`: Minimum and maximum active power flows to the FROM node (MW)
- `active_power_limits_to::MinMax`: Minimum and maximum active power flows to the TO node (MW)
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct TModelHVDCLine <: DCBranch
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Initial condition of active power flow on the line (MW)"
    active_power_flow::Float64
    "An [`Arc`](@ref) defining this line `from` a bus `to` another bus"
    arc::Arc
    "Total series Resistance in p.u. ([`SYSTEM_BASE`](@ref per_unit)), split equally on both sides of the shunt capacitance"
    r::Float64
    "Total series Inductance in p.u. ([`SYSTEM_BASE`](@ref per_unit)), split equally on both sides of the shunt capacitance"
    l::Float64
    "Shunt capacitance in p.u. ([`SYSTEM_BASE`](@ref per_unit))"
    c::Float64
    "Minimum and maximum active power flows to the FROM node (MW)"
    active_power_limits_from::MinMax
    "Minimum and maximum active power flows to the TO node (MW)"
    active_power_limits_to::MinMax
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TModelHVDCLine(name, available, active_power_flow, arc, r, l, c, active_power_limits_from, active_power_limits_to, services=Device[], ext=Dict{String, Any}(), )
    TModelHVDCLine(name, available, active_power_flow, arc, r, l, c, active_power_limits_from, active_power_limits_to, services, ext, InfrastructureSystemsInternal(), )
end

function TModelHVDCLine(; name, available, active_power_flow, arc, r, l, c, active_power_limits_from, active_power_limits_to, services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    TModelHVDCLine(name, available, active_power_flow, arc, r, l, c, active_power_limits_from, active_power_limits_to, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function TModelHVDCLine(::Nothing)
    TModelHVDCLine(;
        name="init",
        available=false,
        active_power_flow=0.0,
        arc=Arc(DCBus(nothing), DCBus(nothing)),
        r=0.0,
        l=0.0,
        c=0.0,
        active_power_limits_from=(min=0.0, max=0.0),
        active_power_limits_to=(min=0.0, max=0.0),
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`TModelHVDCLine`](@ref) `name`."""
get_name(value::TModelHVDCLine) = value.name
"""Get [`TModelHVDCLine`](@ref) `available`."""
get_available(value::TModelHVDCLine) = value.available
"""Get [`TModelHVDCLine`](@ref) `active_power_flow`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_active_power_flow(value::TModelHVDCLine, units) = get_value(value, Val(:active_power_flow), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{ TModelHVDCLine }) = InfrastructureSystems.SU
"""Get [`TModelHVDCLine`](@ref) `arc`."""
get_arc(value::TModelHVDCLine) = value.arc
"""Get [`TModelHVDCLine`](@ref) `r`."""
get_r(value::TModelHVDCLine) = value.r
"""Get [`TModelHVDCLine`](@ref) `l`."""
get_l(value::TModelHVDCLine) = value.l
"""Get [`TModelHVDCLine`](@ref) `c`."""
get_c(value::TModelHVDCLine) = value.c
"""Get [`TModelHVDCLine`](@ref) `active_power_limits_from`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_active_power_limits_from(value::TModelHVDCLine, units) = get_value(value, Val(:active_power_limits_from), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_from), ::Type{ TModelHVDCLine }) = InfrastructureSystems.SU
"""Get [`TModelHVDCLine`](@ref) `active_power_limits_to`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_active_power_limits_to(value::TModelHVDCLine, units) = get_value(value, Val(:active_power_limits_to), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_to), ::Type{ TModelHVDCLine }) = InfrastructureSystems.SU
"""Get [`TModelHVDCLine`](@ref) `services`."""
get_services(value::TModelHVDCLine) = value.services
"""Get [`TModelHVDCLine`](@ref) `ext`."""
get_ext(value::TModelHVDCLine) = value.ext
"""Get [`TModelHVDCLine`](@ref) `internal`."""
get_internal(value::TModelHVDCLine) = value.internal

"""Set [`TModelHVDCLine`](@ref) `available`."""
set_available!(value::TModelHVDCLine, val) = value.available = val
"""Set [`TModelHVDCLine`](@ref) `active_power_flow`."""
set_active_power_flow!(value::TModelHVDCLine, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mva))
"""Set [`TModelHVDCLine`](@ref) `arc`."""
set_arc!(value::TModelHVDCLine, val) = value.arc = val
"""Set [`TModelHVDCLine`](@ref) `r`."""
set_r!(value::TModelHVDCLine, val) = value.r = val
"""Set [`TModelHVDCLine`](@ref) `l`."""
set_l!(value::TModelHVDCLine, val) = value.l = val
"""Set [`TModelHVDCLine`](@ref) `c`."""
set_c!(value::TModelHVDCLine, val) = value.c = val
"""Set [`TModelHVDCLine`](@ref) `active_power_limits_from`."""
set_active_power_limits_from!(value::TModelHVDCLine, val) = value.active_power_limits_from = set_value(value, Val(:active_power_limits_from), val, Val(:mva))
"""Set [`TModelHVDCLine`](@ref) `active_power_limits_to`."""
set_active_power_limits_to!(value::TModelHVDCLine, val) = value.active_power_limits_to = set_value(value, Val(:active_power_limits_to), val, Val(:mva))
"""Set [`TModelHVDCLine`](@ref) `services`."""
set_services!(value::TModelHVDCLine, val) = value.services = val
"""Set [`TModelHVDCLine`](@ref) `ext`."""
set_ext!(value::TModelHVDCLine, val) = value.ext = val
