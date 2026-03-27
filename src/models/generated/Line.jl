#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct Line <: ACTransmission
        name::String
        available::Bool
        active_power_flow::Float64
        reactive_power_flow::Float64
        arc::Arc
        r::Float64
        x::Float64
        b::FromTo
        rating::Float64
        angle_limits::MinMax
        rating_b::Union{Nothing, Float64}
        rating_c::Union{Nothing, Float64}
        g::FromTo
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

An AC transmission line

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow on the line (MW)
- `reactive_power_flow::Float64`: Initial condition of reactive power flow on the line (MVAR)
- `arc::Arc`: An [`Arc`](@ref) defining this line `from` a bus `to` another bus
- `r::Float64`: Resistance in pu ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(0, 4)`
- `x::Float64`: Reactance in pu ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(0, 4)`
- `b::FromTo`: Shunt susceptance in pu ([`SYSTEM_BASE`](@ref per_unit)), specified both on the `from` and `to` ends of the line. These are commonly modeled with the same value, validation range: `(0, 100)`
- `rating::Float64`: Thermal rating (MVA). Flow on the line must be between -`rating` and `rating`. When defining a line before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to
- `angle_limits::MinMax`: Minimum and maximum angle limits (radians)
- `rating_b::Union{Nothing, Float64}`: (default: `nothing`) Second current rating; entered in MVA.
- `rating_c::Union{Nothing, Float64}`: (default: `nothing`) Third current rating; entered in MVA.
- `g::FromTo`: (default: `(from=0.0, to=0.0)`) Shunt conductance in pu ([`SYSTEM_BASE`](@ref per_unit)), specified both on the `from` and `to` ends of the line. These are commonly modeled with the same value, validation range: `(0, 100)`
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct Line <: ACTransmission
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
    "Thermal rating (MVA). Flow on the line must be between -`rating` and `rating`. When defining a line before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to"
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

function Line(name, available, active_power_flow, reactive_power_flow, arc, r, x, b, rating, angle_limits, rating_b=nothing, rating_c=nothing, g=(from=0.0, to=0.0), services=Device[], ext=Dict{String, Any}(), )
    Line(name, available, active_power_flow, reactive_power_flow, arc, r, x, b, rating, angle_limits, rating_b, rating_c, g, services, ext, InfrastructureSystemsInternal(), )
end

function Line(; name, available, active_power_flow, reactive_power_flow, arc, r, x, b, rating, angle_limits, rating_b=nothing, rating_c=nothing, g=(from=0.0, to=0.0), services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    Line(name, available, active_power_flow, reactive_power_flow, arc, r, x, b, rating, angle_limits, rating_b, rating_c, g, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function Line(::Nothing)
    Line(;
        name="init",
        available=false,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        r=0.0,
        x=0.0,
        b=(from=0.0, to=0.0),
        rating=0.0,
        angle_limits=(min=-3.1416, max=3.1416),
        rating_b=0.0,
        rating_c=0.0,
        g=(from=0.0, to=0.0),
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`Line`](@ref) `name`."""
get_name(value::Line) = value.name
"""Get [`Line`](@ref) `available`."""
get_available(value::Line) = value.available
"""Get [`Line`](@ref) `active_power_flow`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_active_power_flow(value::Line) = get_value(value, Val(:active_power_flow), Val(:mva), DEFAULT_UNITS)
get_active_power_flow(value::Line, units) = get_value(value, Val(:active_power_flow), Val(:mva), units)
"""Get [`Line`](@ref) `reactive_power_flow`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_reactive_power_flow(value::Line) = get_value(value, Val(:reactive_power_flow), Val(:mva), DEFAULT_UNITS)
get_reactive_power_flow(value::Line, units) = get_value(value, Val(:reactive_power_flow), Val(:mva), units)
"""Get [`Line`](@ref) `arc`."""
get_arc(value::Line) = value.arc
"""Get [`Line`](@ref) `r`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_r(value::Line) = get_value(value, Val(:r), Val(:ohm), DEFAULT_UNITS)
get_r(value::Line, units) = get_value(value, Val(:r), Val(:ohm), units)
"""Get [`Line`](@ref) `x`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_x(value::Line) = get_value(value, Val(:x), Val(:ohm), DEFAULT_UNITS)
get_x(value::Line, units) = get_value(value, Val(:x), Val(:ohm), units)
"""Get [`Line`](@ref) `b`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_b(value::Line) = get_value(value, Val(:b), Val(:siemens), DEFAULT_UNITS)
get_b(value::Line, units) = get_value(value, Val(:b), Val(:siemens), units)
"""Get [`Line`](@ref) `rating`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_rating(value::Line) = get_value(value, Val(:rating), Val(:mva), DEFAULT_UNITS)
get_rating(value::Line, units) = get_value(value, Val(:rating), Val(:mva), units)
"""Get [`Line`](@ref) `angle_limits`."""
get_angle_limits(value::Line) = value.angle_limits
"""Get [`Line`](@ref) `rating_b`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_rating_b(value::Line) = get_value(value, Val(:rating_b), Val(:mva), DEFAULT_UNITS)
get_rating_b(value::Line, units) = get_value(value, Val(:rating_b), Val(:mva), units)
"""Get [`Line`](@ref) `rating_c`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_rating_c(value::Line) = get_value(value, Val(:rating_c), Val(:mva), DEFAULT_UNITS)
get_rating_c(value::Line, units) = get_value(value, Val(:rating_c), Val(:mva), units)
"""Get [`Line`](@ref) `g`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_g(value::Line) = get_value(value, Val(:g), Val(:siemens), DEFAULT_UNITS)
get_g(value::Line, units) = get_value(value, Val(:g), Val(:siemens), units)
"""Get [`Line`](@ref) `services`."""
get_services(value::Line) = value.services
"""Get [`Line`](@ref) `ext`."""
get_ext(value::Line) = value.ext
"""Get [`Line`](@ref) `internal`."""
get_internal(value::Line) = value.internal

"""Set [`Line`](@ref) `available`."""
set_available!(value::Line, val) = value.available = val
"""Set [`Line`](@ref) `active_power_flow`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_flow!(value::Line, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mva))
"""Set [`Line`](@ref) `reactive_power_flow`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power_flow!(value::Line, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mva))
"""Set [`Line`](@ref) `arc`."""
set_arc!(value::Line, val) = value.arc = val
"""Set [`Line`](@ref) `r`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_r!(value::Line, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
"""Set [`Line`](@ref) `x`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_x!(value::Line, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
"""Set [`Line`](@ref) `b`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_b!(value::Line, val) = value.b = set_value(value, Val(:b), val, Val(:siemens))
"""Set [`Line`](@ref) `rating`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating!(value::Line, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`Line`](@ref) `angle_limits`."""
set_angle_limits!(value::Line, val) = value.angle_limits = val
"""Set [`Line`](@ref) `rating_b`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating_b!(value::Line, val) = value.rating_b = set_value(value, Val(:rating_b), val, Val(:mva))
"""Set [`Line`](@ref) `rating_c`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating_c!(value::Line, val) = value.rating_c = set_value(value, Val(:rating_c), val, Val(:mva))
"""Set [`Line`](@ref) `g`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_g!(value::Line, val) = value.g = set_value(value, Val(:g), val, Val(:siemens))
"""Set [`Line`](@ref) `services`."""
set_services!(value::Line, val) = value.services = val
"""Set [`Line`](@ref) `ext`."""
set_ext!(value::Line, val) = value.ext = val
