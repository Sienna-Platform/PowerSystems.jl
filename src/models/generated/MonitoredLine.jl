#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct MonitoredLine <: ACTransmission
        name::String
        available::Bool
        active_power_flow::Float64
        reactive_power_flow::Float64
        arc::Arc
        r::Float64
        x::Float64
        b::FromTo
        flow_limits::FromTo_ToFrom
        rating::Float64
        angle_limits::MinMax
        rating_b::Union{Nothing, Float64}
        rating_c::Union{Nothing, Float64}
        g::FromTo
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

An AC transmission line with additional power flow constraints specified by the system operator, more restrictive than the line's thermal limits.

For example, monitored lines can be used to restrict line flow following a contingency elsewhere in the network. See the `flow_limits` parameter. If monitoring is not needed, see [`Line`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow on the line (MW)
- `reactive_power_flow::Float64`: Initial condition of reactive power flow on the line (MVAR)
- `arc::Arc`: An [`Arc`](@ref) defining this line `from` a bus `to` another bus
- `r::Float64`: Resistance in pu ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(0, 4)`
- `x::Float64`: Reactance in pu ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(0, 4)`
- `b::FromTo`: Shunt susceptance in pu ([`SYSTEM_BASE`](@ref per_unit)), specified both on the `from` and `to` ends of the line. These are commonly modeled with the same value, validation range: `(0, 2)`
- `flow_limits::FromTo_ToFrom`: Minimum and maximum permissable flow on the line (MVA), if different from the thermal rating defined in `rating`
- `rating::Float64`: Thermal rating (MVA). Flow through the transformer must be between -`rating` and `rating`. When defining a line before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to
- `angle_limits::MinMax`: Minimum and maximum angle limits (radians)
- `rating_b::Union{Nothing, Float64}`: (default: `nothing`) Second current rating; entered in MVA.
- `rating_c::Union{Nothing, Float64}`: (default: `nothing`) Third current rating; entered in MVA.
- `g::FromTo`: (default: `(from=0.0, to=0.0)`) Shunt conductance in pu ([`SYSTEM_BASE`](@ref per_unit)), specified both on the `from` and `to` ends of the line. These are commonly modeled with the same value, validation range: `(0, 100)`
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct MonitoredLine <: ACTransmission
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Initial condition of active power flow on the line (MW)"
    active_power_flow::Float64
    "Initial condition of reactive power flow on the line (MVAR)"
    reactive_power_flow::Float64
    "An [`Arc`](@ref) defining this line `from` a bus `to` another bus"
    arc::Arc
    "Resistance in pu ([`SYSTEM_BASE`](@ref per_unit))"
    r::Float64
    "Reactance in pu ([`SYSTEM_BASE`](@ref per_unit))"
    x::Float64
    "Shunt susceptance in pu ([`SYSTEM_BASE`](@ref per_unit)), specified both on the `from` and `to` ends of the line. These are commonly modeled with the same value"
    b::FromTo
    "Minimum and maximum permissable flow on the line (MVA), if different from the thermal rating defined in `rating`"
    flow_limits::FromTo_ToFrom
    "Thermal rating (MVA). Flow through the transformer must be between -`rating` and `rating`. When defining a line before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to"
    rating::Float64
    "Minimum and maximum angle limits (radians)"
    angle_limits::MinMax
    "Second current rating; entered in MVA."
    rating_b::Union{Nothing, Float64}
    "Third current rating; entered in MVA."
    rating_c::Union{Nothing, Float64}
    "Shunt conductance in pu ([`SYSTEM_BASE`](@ref per_unit)), specified both on the `from` and `to` ends of the line. These are commonly modeled with the same value"
    g::FromTo
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function MonitoredLine(name, available, active_power_flow, reactive_power_flow, arc, r, x, b, flow_limits, rating, angle_limits, rating_b=nothing, rating_c=nothing, g=(from=0.0, to=0.0), services=Device[], ext=Dict{String, Any}(), )
    MonitoredLine(name, available, active_power_flow, reactive_power_flow, arc, r, x, b, flow_limits, rating, angle_limits, rating_b, rating_c, g, services, ext, InfrastructureSystemsInternal(), )
end

function MonitoredLine(; name, available, active_power_flow, reactive_power_flow, arc, r, x, b, flow_limits, rating, angle_limits, rating_b=nothing, rating_c=nothing, g=(from=0.0, to=0.0), services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    MonitoredLine(name, available, active_power_flow, reactive_power_flow, arc, r, x, b, flow_limits, rating, angle_limits, rating_b, rating_c, g, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function MonitoredLine(::Nothing)
    MonitoredLine(;
        name="init",
        available=false,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        r=0.0,
        x=0.0,
        b=(from=0.0, to=0.0),
        flow_limits=(from_to=0.0, to_from=0.0),
        rating=0.0,
        angle_limits=(min=-3.1416, max=3.1416),
        rating_b=0.0,
        rating_c=0.0,
        g=(from=0.0, to=0.0),
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`MonitoredLine`](@ref) `name`."""
get_name(value::MonitoredLine) = value.name
"""Get [`MonitoredLine`](@ref) `available`."""
get_available(value::MonitoredLine) = value.available
"""Get [`MonitoredLine`](@ref) `active_power_flow`."""
get_active_power_flow(value::MonitoredLine) = get_value(value, Val(:active_power_flow), Val(:mva))
get_active_power_flow(value::MonitoredLine, units) = get_value(value, Val(:active_power_flow), Val(:mva), units)
"""Get [`MonitoredLine`](@ref) `reactive_power_flow`."""
get_reactive_power_flow(value::MonitoredLine) = get_value(value, Val(:reactive_power_flow), Val(:mva))
get_reactive_power_flow(value::MonitoredLine, units) = get_value(value, Val(:reactive_power_flow), Val(:mva), units)
"""Get [`MonitoredLine`](@ref) `arc`."""
get_arc(value::MonitoredLine) = value.arc
"""Get [`MonitoredLine`](@ref) `r`."""
get_r(value::MonitoredLine) = get_value(value, Val(:r), Val(:ohm))
get_r(value::MonitoredLine, units) = get_value(value, Val(:r), Val(:ohm), units)
"""Get [`MonitoredLine`](@ref) `x`."""
get_x(value::MonitoredLine) = get_value(value, Val(:x), Val(:ohm))
get_x(value::MonitoredLine, units) = get_value(value, Val(:x), Val(:ohm), units)
"""Get [`MonitoredLine`](@ref) `b`."""
get_b(value::MonitoredLine) = get_value(value, Val(:b), Val(:siemens))
get_b(value::MonitoredLine, units) = get_value(value, Val(:b), Val(:siemens), units)
"""Get [`MonitoredLine`](@ref) `flow_limits`."""
get_flow_limits(value::MonitoredLine) = get_value(value, Val(:flow_limits), Val(:mva))
get_flow_limits(value::MonitoredLine, units) = get_value(value, Val(:flow_limits), Val(:mva), units)
"""Get [`MonitoredLine`](@ref) `rating`."""
get_rating(value::MonitoredLine) = get_value(value, Val(:rating), Val(:mva))
get_rating(value::MonitoredLine, units) = get_value(value, Val(:rating), Val(:mva), units)
"""Get [`MonitoredLine`](@ref) `angle_limits`."""
get_angle_limits(value::MonitoredLine) = value.angle_limits
"""Get [`MonitoredLine`](@ref) `rating_b`."""
get_rating_b(value::MonitoredLine) = get_value(value, Val(:rating_b), Val(:mva))
get_rating_b(value::MonitoredLine, units) = get_value(value, Val(:rating_b), Val(:mva), units)
"""Get [`MonitoredLine`](@ref) `rating_c`."""
get_rating_c(value::MonitoredLine) = get_value(value, Val(:rating_c), Val(:mva))
get_rating_c(value::MonitoredLine, units) = get_value(value, Val(:rating_c), Val(:mva), units)
"""Get [`MonitoredLine`](@ref) `g`."""
get_g(value::MonitoredLine) = get_value(value, Val(:g), Val(:siemens))
get_g(value::MonitoredLine, units) = get_value(value, Val(:g), Val(:siemens), units)
"""Get [`MonitoredLine`](@ref) `services`."""
get_services(value::MonitoredLine) = value.services
"""Get [`MonitoredLine`](@ref) `ext`."""
get_ext(value::MonitoredLine) = value.ext
"""Get [`MonitoredLine`](@ref) `internal`."""
get_internal(value::MonitoredLine) = value.internal

"""Set [`MonitoredLine`](@ref) `available`."""
set_available!(value::MonitoredLine, val) = value.available = val
"""Set [`MonitoredLine`](@ref) `active_power_flow`."""
set_active_power_flow!(value::MonitoredLine, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mva))
"""Set [`MonitoredLine`](@ref) `reactive_power_flow`."""
set_reactive_power_flow!(value::MonitoredLine, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mva))
"""Set [`MonitoredLine`](@ref) `arc`."""
set_arc!(value::MonitoredLine, val) = value.arc = val
"""Set [`MonitoredLine`](@ref) `r`."""
set_r!(value::MonitoredLine, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
"""Set [`MonitoredLine`](@ref) `x`."""
set_x!(value::MonitoredLine, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
"""Set [`MonitoredLine`](@ref) `b`."""
set_b!(value::MonitoredLine, val) = value.b = set_value(value, Val(:b), val, Val(:siemens))
"""Set [`MonitoredLine`](@ref) `flow_limits`."""
set_flow_limits!(value::MonitoredLine, val) = value.flow_limits = set_value(value, Val(:flow_limits), val, Val(:mva))
"""Set [`MonitoredLine`](@ref) `rating`."""
set_rating!(value::MonitoredLine, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`MonitoredLine`](@ref) `angle_limits`."""
set_angle_limits!(value::MonitoredLine, val) = value.angle_limits = val
"""Set [`MonitoredLine`](@ref) `rating_b`."""
set_rating_b!(value::MonitoredLine, val) = value.rating_b = set_value(value, Val(:rating_b), val, Val(:mva))
"""Set [`MonitoredLine`](@ref) `rating_c`."""
set_rating_c!(value::MonitoredLine, val) = value.rating_c = set_value(value, Val(:rating_c), val, Val(:mva))
"""Set [`MonitoredLine`](@ref) `g`."""
set_g!(value::MonitoredLine, val) = value.g = set_value(value, Val(:g), val, Val(:siemens))
"""Set [`MonitoredLine`](@ref) `services`."""
set_services!(value::MonitoredLine, val) = value.services = val
"""Set [`MonitoredLine`](@ref) `ext`."""
set_ext!(value::MonitoredLine, val) = value.ext = val
