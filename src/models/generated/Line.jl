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
        base_power::Float64
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
- `rating::Float64`: Thermal rating (MVA). Flow on the line must be between -`rating` and `rating`. When defining a line before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to. Displays in device base ([`DEVICE_BASE`](@ref per_unit)) by default, unlike most converted fields which default to system base
- `angle_limits::MinMax`: Minimum and maximum angle limits (radians)
- `rating_b::Union{Nothing, Float64}`: (default: `nothing`) Second current rating; entered in MVA.
- `rating_c::Union{Nothing, Float64}`: (default: `nothing`) Third current rating; entered in MVA.
- `g::FromTo`: (default: `(from=0.0, to=0.0)`) Shunt conductance in pu ([`SYSTEM_BASE`](@ref per_unit)), specified both on the `from` and `to` ends of the line. These are commonly modeled with the same value, validation range: `(0, 100)`
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
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
    "Thermal rating (MVA). Flow on the line must be between -`rating` and `rating`. When defining a line before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to. Displays in device base ([`DEVICE_BASE`](@ref per_unit)) by default, unlike most converted fields which default to system base"
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
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function Line(name, available, active_power_flow, reactive_power_flow, arc, r, x, b, rating, angle_limits, rating_b=nothing, rating_c=nothing, g=(from=0.0, to=0.0), services=Device[], base_power=100.0, ext=Dict{String, Any}(), )
    Line(name, available, active_power_flow, reactive_power_flow, arc, r, x, b, rating, angle_limits, rating_b, rating_c, g, services, base_power, ext, InfrastructureSystemsInternal(), )
end

function Line(; name, available, active_power_flow, reactive_power_flow, arc, r, x, b, rating, angle_limits, rating_b=nothing, rating_c=nothing, g=(from=0.0, to=0.0), services=Device[], base_power=100.0, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    Line(name, available, active_power_flow, reactive_power_flow, arc, r, x, b, rating, angle_limits, rating_b, rating_c, g, services, base_power, ext, internal, )
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
        base_power=100.0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`Line`](@ref) `name`."""
get_name(value::Line) = value.name
"""Get [`Line`](@ref) `available`."""
get_available(value::Line) = value.available
"""Get [`Line`](@ref) `active_power_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_flow_unitful`](@ref)."""
get_active_power_flow(value::Line, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_flow), Val(:mw), units))
"""Get [`Line`](@ref) `active_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_flow`](@ref)."""
get_active_power_flow_unitful(value::Line, units) = get_value(value, Val(:active_power_flow), Val(:mw), units)
get_active_power_flow(value::Line) = _units_arg_required(get_active_power_flow, value, :active_power_flow, Val(:mw))
get_active_power_flow_unitful(value::Line) = _units_arg_required(get_active_power_flow_unitful, value, :active_power_flow, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{Line}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_unitful), ::Type{Line}) = InfrastructureSystems.SU
"""Get [`Line`](@ref) `reactive_power_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_flow_unitful`](@ref)."""
get_reactive_power_flow(value::Line, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_flow), Val(:mvar), units))
"""Get [`Line`](@ref) `reactive_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_flow`](@ref)."""
get_reactive_power_flow_unitful(value::Line, units) = get_value(value, Val(:reactive_power_flow), Val(:mvar), units)
get_reactive_power_flow(value::Line) = _units_arg_required(get_reactive_power_flow, value, :reactive_power_flow, Val(:mvar))
get_reactive_power_flow_unitful(value::Line) = _units_arg_required(get_reactive_power_flow_unitful, value, :reactive_power_flow, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_flow), ::Type{Line}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_flow_unitful), ::Type{Line}) = InfrastructureSystems.SU
"""Get [`Line`](@ref) `arc`."""
get_arc(value::Line) = value.arc
"""Get [`Line`](@ref) `r` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_r_unitful`](@ref)."""
get_r(value::Line, units) = InfrastructureSystems._strip_units(get_value(value, Val(:r), Val(:ohm), units))
"""Get [`Line`](@ref) `r` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_r`](@ref)."""
get_r_unitful(value::Line, units) = get_value(value, Val(:r), Val(:ohm), units)
get_r(value::Line) = _units_arg_required(get_r, value, :r, Val(:ohm))
get_r_unitful(value::Line) = _units_arg_required(get_r_unitful, value, :r, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_r), ::Type{Line}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_r_unitful), ::Type{Line}) = InfrastructureSystems.SU
"""Get [`Line`](@ref) `x` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_x_unitful`](@ref)."""
get_x(value::Line, units) = InfrastructureSystems._strip_units(get_value(value, Val(:x), Val(:ohm), units))
"""Get [`Line`](@ref) `x` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_x`](@ref)."""
get_x_unitful(value::Line, units) = get_value(value, Val(:x), Val(:ohm), units)
get_x(value::Line) = _units_arg_required(get_x, value, :x, Val(:ohm))
get_x_unitful(value::Line) = _units_arg_required(get_x_unitful, value, :x, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_x), ::Type{Line}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_x_unitful), ::Type{Line}) = InfrastructureSystems.SU
"""Get [`Line`](@ref) `b` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_b_unitful`](@ref)."""
get_b(value::Line, units) = InfrastructureSystems._strip_units(get_value(value, Val(:b), Val(:siemens), units))
"""Get [`Line`](@ref) `b` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_b`](@ref)."""
get_b_unitful(value::Line, units) = get_value(value, Val(:b), Val(:siemens), units)
get_b(value::Line) = _units_arg_required(get_b, value, :b, Val(:siemens))
get_b_unitful(value::Line) = _units_arg_required(get_b_unitful, value, :b, Val(:siemens))
InfrastructureSystems.display_units_arg(::typeof(get_b), ::Type{Line}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_b_unitful), ::Type{Line}) = InfrastructureSystems.SU
"""Get [`Line`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::Line, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`Line`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::Line, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::Line) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::Line) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{Line}) = InfrastructureSystems.DU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{Line}) = InfrastructureSystems.DU
"""Get [`Line`](@ref) `angle_limits`."""
get_angle_limits(value::Line) = value.angle_limits
"""Get [`Line`](@ref) `rating_b` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_b_unitful`](@ref)."""
get_rating_b(value::Line, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating_b), Val(:mva), units))
"""Get [`Line`](@ref) `rating_b` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating_b`](@ref)."""
get_rating_b_unitful(value::Line, units) = get_value(value, Val(:rating_b), Val(:mva), units)
get_rating_b(value::Line) = _units_arg_required(get_rating_b, value, :rating_b, Val(:mva))
get_rating_b_unitful(value::Line) = _units_arg_required(get_rating_b_unitful, value, :rating_b, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating_b), ::Type{Line}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_rating_b_unitful), ::Type{Line}) = InfrastructureSystems.SU
"""Get [`Line`](@ref) `rating_c` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_c_unitful`](@ref)."""
get_rating_c(value::Line, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating_c), Val(:mva), units))
"""Get [`Line`](@ref) `rating_c` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating_c`](@ref)."""
get_rating_c_unitful(value::Line, units) = get_value(value, Val(:rating_c), Val(:mva), units)
get_rating_c(value::Line) = _units_arg_required(get_rating_c, value, :rating_c, Val(:mva))
get_rating_c_unitful(value::Line) = _units_arg_required(get_rating_c_unitful, value, :rating_c, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating_c), ::Type{Line}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_rating_c_unitful), ::Type{Line}) = InfrastructureSystems.SU
"""Get [`Line`](@ref) `g` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_g_unitful`](@ref)."""
get_g(value::Line, units) = InfrastructureSystems._strip_units(get_value(value, Val(:g), Val(:siemens), units))
"""Get [`Line`](@ref) `g` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_g`](@ref)."""
get_g_unitful(value::Line, units) = get_value(value, Val(:g), Val(:siemens), units)
get_g(value::Line) = _units_arg_required(get_g, value, :g, Val(:siemens))
get_g_unitful(value::Line) = _units_arg_required(get_g_unitful, value, :g, Val(:siemens))
InfrastructureSystems.display_units_arg(::typeof(get_g), ::Type{Line}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_g_unitful), ::Type{Line}) = InfrastructureSystems.SU
"""Get [`Line`](@ref) `services`."""
get_services(value::Line) = value.services

_get_base_power(value::Line) = value.base_power
"""Get [`Line`](@ref) `ext`."""
get_ext(value::Line) = value.ext
"""Get [`Line`](@ref) `internal`."""
get_internal(value::Line) = value.internal

"""Set [`Line`](@ref) `available`."""
set_available!(value::Line, val) = value.available = val
"""Set [`Line`](@ref) `active_power_flow`."""
set_active_power_flow!(value::Line, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mw))
set_active_power_flow!(value::Line, val::_UntaggedNumber) = _units_tag_required(set_active_power_flow!, value, :active_power_flow, Val(:mw), val)
"""Set [`Line`](@ref) `reactive_power_flow`."""
set_reactive_power_flow!(value::Line, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mvar))
set_reactive_power_flow!(value::Line, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_flow!, value, :reactive_power_flow, Val(:mvar), val)
"""Set [`Line`](@ref) `arc`."""
set_arc!(value::Line, val) = value.arc = val
"""Set [`Line`](@ref) `r`."""
set_r!(value::Line, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
set_r!(value::Line, val::_UntaggedNumber) = _units_tag_required(set_r!, value, :r, Val(:ohm), val)
"""Set [`Line`](@ref) `x`."""
set_x!(value::Line, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
set_x!(value::Line, val::_UntaggedNumber) = _units_tag_required(set_x!, value, :x, Val(:ohm), val)
"""Set [`Line`](@ref) `b`."""
set_b!(value::Line, val) = value.b = set_value(value, Val(:b), val, Val(:siemens))
set_b!(value::Line, val::_UntaggedNumber) = _units_tag_required(set_b!, value, :b, Val(:siemens), val)
set_b!(value::Line, val::NamedTuple{(:from, :to), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_b!, value, :b, Val(:siemens), val)
"""Set [`Line`](@ref) `rating`."""
set_rating!(value::Line, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::Line, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`Line`](@ref) `angle_limits`."""
set_angle_limits!(value::Line, val) = value.angle_limits = val
"""Set [`Line`](@ref) `rating_b`."""
set_rating_b!(value::Line, val) = value.rating_b = set_value(value, Val(:rating_b), val, Val(:mva))
set_rating_b!(value::Line, val::_UntaggedNumber) = _units_tag_required(set_rating_b!, value, :rating_b, Val(:mva), val)
"""Set [`Line`](@ref) `rating_c`."""
set_rating_c!(value::Line, val) = value.rating_c = set_value(value, Val(:rating_c), val, Val(:mva))
set_rating_c!(value::Line, val::_UntaggedNumber) = _units_tag_required(set_rating_c!, value, :rating_c, Val(:mva), val)
"""Set [`Line`](@ref) `g`."""
set_g!(value::Line, val) = value.g = set_value(value, Val(:g), val, Val(:siemens))
set_g!(value::Line, val::_UntaggedNumber) = _units_tag_required(set_g!, value, :g, Val(:siemens), val)
set_g!(value::Line, val::NamedTuple{(:from, :to), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_g!, value, :g, Val(:siemens), val)
"""Set [`Line`](@ref) `services`."""
set_services!(value::Line, val) = value.services = val
"""Set [`Line`](@ref) `ext`."""
set_ext!(value::Line, val) = value.ext = val
