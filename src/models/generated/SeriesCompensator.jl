#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SeriesCompensator <: ACTransmission
        name::String
        available::Bool
        active_power_flow::Float64
        reactive_power_flow::Float64
        arc::Arc
        r::Float64
        x::Float64
        rating::Float64
        control_mode::SeriesCompensatorControlMode.Value
        reactance_limits::Union{Nothing, MinMax}
        active_power_flow_setpoint::Union{Nothing, Float64}
        rating_b::Union{Nothing, Float64}
        rating_c::Union{Nothing, Float64}
        services::Vector{Service}
        base_power::Float64
        operational_flow_limit::Union{Nothing, OperationalFlowLimit}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A series compensator: a series capacitor or reactor, or a thyristor-controlled or static synchronous series compensator, with one series reactance on an [`Arc`](@ref). Out of service is `available = false`; a bypassed compensator is `control_mode = BYPASSED`

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow through the compensator (MW)
- `reactive_power_flow::Float64`: Initial condition of reactive power flow through the compensator (MVAR)
- `arc::Arc`: An [`Arc`](@ref) defining this compensator `from` a bus `to` another bus
- `r::Float64`: Resistance in pu ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(0, 4)`
- `x::Float64`: Series reactance in pu ([`SYSTEM_BASE`](@ref per_unit)); negative for a capacitor. Under `DISPATCHABLE` and `ACTIVE_POWER_FLOW`, the present value, validation range: `(-4, 4)`
- `rating::Float64`: Thermal rating (MVA). Flow through the compensator must be between -`rating` and `rating`. When defining a compensator before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to. Displays in component base ([`DEVICE_BASE`](@ref per_unit)) by default, unlike most converted fields which default to system base
- `control_mode::SeriesCompensatorControlMode.Value`: (default: `SeriesCompensatorControlMode.FIXED`) How the series reactance is set; see [`SeriesCompensatorControlMode`](@ref). `DISPATCHABLE` and `ACTIVE_POWER_FLOW` use `reactance_limits`; `ACTIVE_POWER_FLOW` also uses `active_power_flow_setpoint`
- `reactance_limits::Union{Nothing, MinMax}`: (default: `nothing`) Minimum and maximum series reactance in pu ([`SYSTEM_BASE`](@ref per_unit)), for `DISPATCHABLE` and `ACTIVE_POWER_FLOW`. `nothing` if not applicable
- `active_power_flow_setpoint::Union{Nothing, Float64}`: (default: `nothing`) Active power flow (MW), from the `from` bus to the `to` bus, held under `ACTIVE_POWER_FLOW`. `nothing` if not applicable
- `rating_b::Union{Nothing, Float64}`: (default: `nothing`) Second current rating; entered in MVA.
- `rating_c::Union{Nothing, Float64}`: (default: `nothing`) Third current rating; entered in MVA.
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
- `operational_flow_limit::Union{Nothing, OperationalFlowLimit}`: (default: `nothing`) Operator-set minimum and maximum flow (MW) in each direction, `from_to` and `to_from`, applied in addition to `rating`. `nothing` means no operational limit
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
- `input_basis`: (keyword constructor only, required) `u"CU"` or `u"NU"`, the units of bare numbers on unit-bearing fields. Tagged values (`50.0u"MW"`) keep their own units
"""
mutable struct SeriesCompensator <: ACTransmission
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Initial condition of active power flow through the compensator (MW)"
    active_power_flow::Float64
    "Initial condition of reactive power flow through the compensator (MVAR)"
    reactive_power_flow::Float64
    "An [`Arc`](@ref) defining this compensator `from` a bus `to` another bus"
    arc::Arc
    "Resistance in pu ([`SYSTEM_BASE`](@ref per_unit))"
    r::Float64
    "Series reactance in pu ([`SYSTEM_BASE`](@ref per_unit)); negative for a capacitor. Under `DISPATCHABLE` and `ACTIVE_POWER_FLOW`, the present value"
    x::Float64
    "Thermal rating (MVA). Flow through the compensator must be between -`rating` and `rating`. When defining a compensator before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to. Displays in component base ([`DEVICE_BASE`](@ref per_unit)) by default, unlike most converted fields which default to system base"
    rating::Float64
    "How the series reactance is set; see [`SeriesCompensatorControlMode`](@ref). `DISPATCHABLE` and `ACTIVE_POWER_FLOW` use `reactance_limits`; `ACTIVE_POWER_FLOW` also uses `active_power_flow_setpoint`"
    control_mode::SeriesCompensatorControlMode.Value
    "Minimum and maximum series reactance in pu ([`SYSTEM_BASE`](@ref per_unit)), for `DISPATCHABLE` and `ACTIVE_POWER_FLOW`. `nothing` if not applicable"
    reactance_limits::Union{Nothing, MinMax}
    "Active power flow (MW), from the `from` bus to the `to` bus, held under `ACTIVE_POWER_FLOW`. `nothing` if not applicable"
    active_power_flow_setpoint::Union{Nothing, Float64}
    "Second current rating; entered in MVA."
    rating_b::Union{Nothing, Float64}
    "Third current rating; entered in MVA."
    rating_c::Union{Nothing, Float64}
    "Services that this device contributes to"
    services::Vector{Service}
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "Operator-set minimum and maximum flow (MW) in each direction, `from_to` and `to_from`, applied in addition to `rating`. `nothing` means no operational limit"
    operational_flow_limit::Union{Nothing, OperationalFlowLimit}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function SeriesCompensator(name, available, active_power_flow, reactive_power_flow, arc, r, x, rating, control_mode=SeriesCompensatorControlMode.FIXED, reactance_limits=nothing, active_power_flow_setpoint=nothing, rating_b=nothing, rating_c=nothing, services=Device[], base_power=100.0, operational_flow_limit=nothing, ext=Dict{String, Any}(), )
    SeriesCompensator(name, available, active_power_flow, reactive_power_flow, arc, r, x, rating, control_mode, reactance_limits, active_power_flow_setpoint, rating_b, rating_c, services, base_power, operational_flow_limit, ext, InfrastructureSystemsInternal(), )
end

function SeriesCompensator(; name, available, active_power_flow, reactive_power_flow, arc, r, x, rating, control_mode=SeriesCompensatorControlMode.FIXED, reactance_limits=nothing, active_power_flow_setpoint=nothing, rating_b=nothing, rating_c=nothing, services=Device[], base_power=100.0, operational_flow_limit=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), input_basis::Unitful.Units, )
    value = SeriesCompensator(name, available, _placeholder(active_power_flow), _placeholder(reactive_power_flow), arc, _placeholder(r), _placeholder(x), _placeholder(rating), control_mode, _placeholder(reactance_limits), _placeholder(active_power_flow_setpoint), _placeholder(rating_b), _placeholder(rating_c), services, base_power, _placeholder(operational_flow_limit), ext, internal, )
    set_active_power_flow!(value, _tag(active_power_flow, input_basis, Val(:mw)))
    set_reactive_power_flow!(value, _tag(reactive_power_flow, input_basis, Val(:mvar)))
    set_r!(value, _tag(r, input_basis, Val(:ohm)))
    set_x!(value, _tag(x, input_basis, Val(:ohm)))
    set_rating!(value, _tag(rating, input_basis, Val(:mva)))
    set_reactance_limits!(value, _tag(reactance_limits, input_basis, Val(:ohm)))
    set_active_power_flow_setpoint!(value, _tag(active_power_flow_setpoint, input_basis, Val(:mw)))
    set_rating_b!(value, _tag(rating_b, input_basis, Val(:mva)))
    set_rating_c!(value, _tag(rating_c, input_basis, Val(:mva)))
    set_operational_flow_limit!(value, _tag(operational_flow_limit, input_basis, Val(:mw)))
    return value
end
_takes_input_basis(::Type{<:SeriesCompensator}) = true

# Constructor for demo purposes; non-functional.
function SeriesCompensator(::Nothing)
    SeriesCompensator(;
        name="init",
        available=false,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        r=0.0,
        x=0.0,
        rating=0.0,
        control_mode=SeriesCompensatorControlMode.FIXED,
        reactance_limits=nothing,
        active_power_flow_setpoint=nothing,
        rating_b=0.0,
        rating_c=0.0,
        services=Device[],
        base_power=100.0,
        operational_flow_limit=nothing,
        ext=Dict{String, Any}(),
        input_basis=u"CU",
    )
end

"""Get [`SeriesCompensator`](@ref) `name`."""
get_name(value::SeriesCompensator) = value.name
"""Get [`SeriesCompensator`](@ref) `available`."""
get_available(value::SeriesCompensator) = value.available
"""Get [`SeriesCompensator`](@ref) `active_power_flow` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_active_power_flow_unitful`](@ref)."""
get_active_power_flow(value::SeriesCompensator, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_flow), Val(:mw), units))
"""Get [`SeriesCompensator`](@ref) `active_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_active_power_flow`](@ref)."""
get_active_power_flow_unitful(value::SeriesCompensator, units) = get_value(value, Val(:active_power_flow), Val(:mw), units)
get_active_power_flow(value::SeriesCompensator) = _units_arg_required(get_active_power_flow, value, :active_power_flow, Val(:mw))
get_active_power_flow_unitful(value::SeriesCompensator) = _units_arg_required(get_active_power_flow_unitful, value, :active_power_flow, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{SeriesCompensator}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_unitful), ::Type{SeriesCompensator}) = u"SU"
"""Get [`SeriesCompensator`](@ref) `reactive_power_flow` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_reactive_power_flow_unitful`](@ref)."""
get_reactive_power_flow(value::SeriesCompensator, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_flow), Val(:mvar), units))
"""Get [`SeriesCompensator`](@ref) `reactive_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_reactive_power_flow`](@ref)."""
get_reactive_power_flow_unitful(value::SeriesCompensator, units) = get_value(value, Val(:reactive_power_flow), Val(:mvar), units)
get_reactive_power_flow(value::SeriesCompensator) = _units_arg_required(get_reactive_power_flow, value, :reactive_power_flow, Val(:mvar))
get_reactive_power_flow_unitful(value::SeriesCompensator) = _units_arg_required(get_reactive_power_flow_unitful, value, :reactive_power_flow, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_flow), ::Type{SeriesCompensator}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_flow_unitful), ::Type{SeriesCompensator}) = u"SU"
"""Get [`SeriesCompensator`](@ref) `arc`."""
get_arc(value::SeriesCompensator) = value.arc
"""Get [`SeriesCompensator`](@ref) `r` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_r_unitful`](@ref)."""
get_r(value::SeriesCompensator, units) = InfrastructureSystems._strip_units(get_value(value, Val(:r), Val(:ohm), units))
"""Get [`SeriesCompensator`](@ref) `r` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_r`](@ref)."""
get_r_unitful(value::SeriesCompensator, units) = get_value(value, Val(:r), Val(:ohm), units)
get_r(value::SeriesCompensator) = _units_arg_required(get_r, value, :r, Val(:ohm))
get_r_unitful(value::SeriesCompensator) = _units_arg_required(get_r_unitful, value, :r, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_r), ::Type{SeriesCompensator}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_r_unitful), ::Type{SeriesCompensator}) = u"SU"
"""Get [`SeriesCompensator`](@ref) `x` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_x_unitful`](@ref)."""
get_x(value::SeriesCompensator, units) = InfrastructureSystems._strip_units(get_value(value, Val(:x), Val(:ohm), units))
"""Get [`SeriesCompensator`](@ref) `x` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_x`](@ref)."""
get_x_unitful(value::SeriesCompensator, units) = get_value(value, Val(:x), Val(:ohm), units)
get_x(value::SeriesCompensator) = _units_arg_required(get_x, value, :x, Val(:ohm))
get_x_unitful(value::SeriesCompensator) = _units_arg_required(get_x_unitful, value, :x, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_x), ::Type{SeriesCompensator}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_x_unitful), ::Type{SeriesCompensator}) = u"SU"
"""Get [`SeriesCompensator`](@ref) `rating` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::SeriesCompensator, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`SeriesCompensator`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::SeriesCompensator, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::SeriesCompensator) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::SeriesCompensator) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{SeriesCompensator}) = u"CU"
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{SeriesCompensator}) = u"CU"
"""Get [`SeriesCompensator`](@ref) `control_mode`."""
get_control_mode(value::SeriesCompensator) = value.control_mode
"""Get [`SeriesCompensator`](@ref) `reactance_limits` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_reactance_limits_unitful`](@ref)."""
get_reactance_limits(value::SeriesCompensator, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactance_limits), Val(:ohm), units))
"""Get [`SeriesCompensator`](@ref) `reactance_limits` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_reactance_limits`](@ref)."""
get_reactance_limits_unitful(value::SeriesCompensator, units) = get_value(value, Val(:reactance_limits), Val(:ohm), units)
get_reactance_limits(value::SeriesCompensator) = _units_arg_required(get_reactance_limits, value, :reactance_limits, Val(:ohm))
get_reactance_limits_unitful(value::SeriesCompensator) = _units_arg_required(get_reactance_limits_unitful, value, :reactance_limits, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_reactance_limits), ::Type{SeriesCompensator}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_reactance_limits_unitful), ::Type{SeriesCompensator}) = u"SU"
"""Get [`SeriesCompensator`](@ref) `active_power_flow_setpoint` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_active_power_flow_setpoint_unitful`](@ref)."""
get_active_power_flow_setpoint(value::SeriesCompensator, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_flow_setpoint), Val(:mw), units))
"""Get [`SeriesCompensator`](@ref) `active_power_flow_setpoint` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_active_power_flow_setpoint`](@ref)."""
get_active_power_flow_setpoint_unitful(value::SeriesCompensator, units) = get_value(value, Val(:active_power_flow_setpoint), Val(:mw), units)
get_active_power_flow_setpoint(value::SeriesCompensator) = _units_arg_required(get_active_power_flow_setpoint, value, :active_power_flow_setpoint, Val(:mw))
get_active_power_flow_setpoint_unitful(value::SeriesCompensator) = _units_arg_required(get_active_power_flow_setpoint_unitful, value, :active_power_flow_setpoint, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_setpoint), ::Type{SeriesCompensator}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_setpoint_unitful), ::Type{SeriesCompensator}) = u"SU"
"""Get [`SeriesCompensator`](@ref) `rating_b` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_rating_b_unitful`](@ref)."""
get_rating_b(value::SeriesCompensator, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating_b), Val(:mva), units))
"""Get [`SeriesCompensator`](@ref) `rating_b` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_rating_b`](@ref)."""
get_rating_b_unitful(value::SeriesCompensator, units) = get_value(value, Val(:rating_b), Val(:mva), units)
get_rating_b(value::SeriesCompensator) = _units_arg_required(get_rating_b, value, :rating_b, Val(:mva))
get_rating_b_unitful(value::SeriesCompensator) = _units_arg_required(get_rating_b_unitful, value, :rating_b, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating_b), ::Type{SeriesCompensator}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_rating_b_unitful), ::Type{SeriesCompensator}) = u"SU"
"""Get [`SeriesCompensator`](@ref) `rating_c` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_rating_c_unitful`](@ref)."""
get_rating_c(value::SeriesCompensator, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating_c), Val(:mva), units))
"""Get [`SeriesCompensator`](@ref) `rating_c` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_rating_c`](@ref)."""
get_rating_c_unitful(value::SeriesCompensator, units) = get_value(value, Val(:rating_c), Val(:mva), units)
get_rating_c(value::SeriesCompensator) = _units_arg_required(get_rating_c, value, :rating_c, Val(:mva))
get_rating_c_unitful(value::SeriesCompensator) = _units_arg_required(get_rating_c_unitful, value, :rating_c, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating_c), ::Type{SeriesCompensator}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_rating_c_unitful), ::Type{SeriesCompensator}) = u"SU"
"""Get [`SeriesCompensator`](@ref) `services`."""
get_services(value::SeriesCompensator) = value.services

_get_base_power(value::SeriesCompensator) = value.base_power
"""Get [`SeriesCompensator`](@ref) `operational_flow_limit` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_operational_flow_limit_unitful`](@ref)."""
get_operational_flow_limit(value::SeriesCompensator, units) = InfrastructureSystems._strip_units(get_value(value, Val(:operational_flow_limit), Val(:mw), units))
"""Get [`SeriesCompensator`](@ref) `operational_flow_limit` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_operational_flow_limit`](@ref)."""
get_operational_flow_limit_unitful(value::SeriesCompensator, units) = get_value(value, Val(:operational_flow_limit), Val(:mw), units)
get_operational_flow_limit(value::SeriesCompensator) = _units_arg_required(get_operational_flow_limit, value, :operational_flow_limit, Val(:mw))
get_operational_flow_limit_unitful(value::SeriesCompensator) = _units_arg_required(get_operational_flow_limit_unitful, value, :operational_flow_limit, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_operational_flow_limit), ::Type{SeriesCompensator}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_operational_flow_limit_unitful), ::Type{SeriesCompensator}) = u"SU"
"""Get [`SeriesCompensator`](@ref) `ext`."""
get_ext(value::SeriesCompensator) = value.ext
"""Get [`SeriesCompensator`](@ref) `internal`."""
get_internal(value::SeriesCompensator) = value.internal

"""Set [`SeriesCompensator`](@ref) `available`."""
set_available!(value::SeriesCompensator, val) = value.available = val
"""Set [`SeriesCompensator`](@ref) `active_power_flow`."""
set_active_power_flow!(value::SeriesCompensator, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mw))
set_active_power_flow!(value::SeriesCompensator, val::_UntaggedNumber) = _units_tag_required(set_active_power_flow!, value, :active_power_flow, Val(:mw), val)
"""Set [`SeriesCompensator`](@ref) `reactive_power_flow`."""
set_reactive_power_flow!(value::SeriesCompensator, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mvar))
set_reactive_power_flow!(value::SeriesCompensator, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_flow!, value, :reactive_power_flow, Val(:mvar), val)
"""Set [`SeriesCompensator`](@ref) `arc`."""
set_arc!(value::SeriesCompensator, val) = value.arc = val
"""Set [`SeriesCompensator`](@ref) `r`."""
set_r!(value::SeriesCompensator, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
set_r!(value::SeriesCompensator, val::_UntaggedNumber) = _units_tag_required(set_r!, value, :r, Val(:ohm), val)
"""Set [`SeriesCompensator`](@ref) `x`."""
set_x!(value::SeriesCompensator, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
set_x!(value::SeriesCompensator, val::_UntaggedNumber) = _units_tag_required(set_x!, value, :x, Val(:ohm), val)
"""Set [`SeriesCompensator`](@ref) `rating`."""
set_rating!(value::SeriesCompensator, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::SeriesCompensator, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`SeriesCompensator`](@ref) `control_mode`."""
set_control_mode!(value::SeriesCompensator, val) = value.control_mode = val
"""Set [`SeriesCompensator`](@ref) `reactance_limits`."""
set_reactance_limits!(value::SeriesCompensator, val) = value.reactance_limits = set_value(value, Val(:reactance_limits), val, Val(:ohm))
set_reactance_limits!(value::SeriesCompensator, val::_UntaggedNumber) = _units_tag_required(set_reactance_limits!, value, :reactance_limits, Val(:ohm), val)
set_reactance_limits!(value::SeriesCompensator, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactance_limits!, value, :reactance_limits, Val(:ohm), val)
"""Set [`SeriesCompensator`](@ref) `active_power_flow_setpoint`."""
set_active_power_flow_setpoint!(value::SeriesCompensator, val) = value.active_power_flow_setpoint = set_value(value, Val(:active_power_flow_setpoint), val, Val(:mw))
set_active_power_flow_setpoint!(value::SeriesCompensator, val::_UntaggedNumber) = _units_tag_required(set_active_power_flow_setpoint!, value, :active_power_flow_setpoint, Val(:mw), val)
"""Set [`SeriesCompensator`](@ref) `rating_b`."""
set_rating_b!(value::SeriesCompensator, val) = value.rating_b = set_value(value, Val(:rating_b), val, Val(:mva))
set_rating_b!(value::SeriesCompensator, val::_UntaggedNumber) = _units_tag_required(set_rating_b!, value, :rating_b, Val(:mva), val)
"""Set [`SeriesCompensator`](@ref) `rating_c`."""
set_rating_c!(value::SeriesCompensator, val) = value.rating_c = set_value(value, Val(:rating_c), val, Val(:mva))
set_rating_c!(value::SeriesCompensator, val::_UntaggedNumber) = _units_tag_required(set_rating_c!, value, :rating_c, Val(:mva), val)
"""Set [`SeriesCompensator`](@ref) `services`."""
set_services!(value::SeriesCompensator, val) = value.services = val
"""Set [`SeriesCompensator`](@ref) `operational_flow_limit`."""
set_operational_flow_limit!(value::SeriesCompensator, val) = value.operational_flow_limit = set_value(value, Val(:operational_flow_limit), val, Val(:mw))
set_operational_flow_limit!(value::SeriesCompensator, val::_UntaggedNumber) = _units_tag_required(set_operational_flow_limit!, value, :operational_flow_limit, Val(:mw), val)
"""Set [`SeriesCompensator`](@ref) `ext`."""
set_ext!(value::SeriesCompensator, val) = value.ext = val
