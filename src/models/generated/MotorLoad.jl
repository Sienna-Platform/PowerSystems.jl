#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct MotorLoad <: StaticLoad
        name::String
        available::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        base_power::Float64
        rating::Float64
        max_active_power::Float64
        reactive_power_limits::Union{Nothing, MinMax}
        motor_technology::MotorLoadTechnology
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A [static](@ref S) power load, most commonly used for operational models such as power flow and operational optimizations.

This load consumes a set amount of power (set by `active_power` for a power flow simulation or a `max_active_power` time series for an operational simulation). For loads that can be compensated for load interruptions through demand response programs, see [`InterruptiblePowerLoad`](@ref). For voltage-dependent loads used in [dynamics](@ref D) modeling, see [`StandardLoad`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `MotorLoad`) must have unique names, but components of different types (e.g., `MotorLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial steady-state active power demand (MW). A positive value indicates power consumption.
- `reactive_power::Float64`: Initial steady-state reactive power demand (MVAR). A positive value indicates reactive power consumption.
- `base_power::Float64`: Base power (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power, validation range: `(0, nothing)`
- `max_active_power::Float64`: Maximum active power (MW) that this load can demand
- `reactive_power_limits::Union{Nothing, MinMax}`: (default: `nothing`) Minimum and maximum reactive power limits. Set to `Nothing` if not applicable
- `motor_technology::MotorLoadTechnology`: (default: `MotorLoadTechnology.UNDETERMINED`) AC Motor type. Options are listed [here](@ref motor_list)
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct MotorLoad <: StaticLoad
    "Name of the component. Components of the same type (e.g., `MotorLoad`) must have unique names, but components of different types (e.g., `MotorLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Initial steady-state active power demand (MW). A positive value indicates power consumption."
    active_power::Float64
    "Initial steady-state reactive power demand (MVAR). A positive value indicates reactive power consumption."
    reactive_power::Float64
    "Base power (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power"
    rating::Float64
    "Maximum active power (MW) that this load can demand"
    max_active_power::Float64
    "Minimum and maximum reactive power limits. Set to `Nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "AC Motor type. Options are listed [here](@ref motor_list)"
    motor_technology::MotorLoadTechnology
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function MotorLoad(name, available, bus, active_power, reactive_power, base_power, rating, max_active_power, reactive_power_limits=nothing, motor_technology=MotorLoadTechnology.UNDETERMINED, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    MotorLoad(name, available, bus, active_power, reactive_power, base_power, rating, max_active_power, reactive_power_limits, motor_technology, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function MotorLoad(; name, available, bus, active_power, reactive_power, base_power, rating, max_active_power, reactive_power_limits=nothing, motor_technology=MotorLoadTechnology.UNDETERMINED, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    MotorLoad(name, available, bus, active_power, reactive_power, base_power, rating, max_active_power, reactive_power_limits, motor_technology, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function MotorLoad(::Nothing)
    MotorLoad(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        base_power=100.0,
        rating=0.0,
        max_active_power=0.0,
        reactive_power_limits=nothing,
        motor_technology=MotorLoadTechnology.UNDETERMINED,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`MotorLoad`](@ref) `name`."""
get_name(value::MotorLoad) = value.name
"""Get [`MotorLoad`](@ref) `available`."""
get_available(value::MotorLoad) = value.available
"""Get [`MotorLoad`](@ref) `bus`."""
get_bus(value::MotorLoad) = value.bus
"""Get [`MotorLoad`](@ref) `active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::MotorLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`MotorLoad`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::MotorLoad, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::MotorLoad) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::MotorLoad) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{MotorLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{MotorLoad}) = InfrastructureSystems.SU
"""Get [`MotorLoad`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::MotorLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`MotorLoad`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::MotorLoad, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::MotorLoad) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::MotorLoad) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{MotorLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{MotorLoad}) = InfrastructureSystems.SU

_get_base_power(value::MotorLoad) = value.base_power
"""Get [`MotorLoad`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::MotorLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`MotorLoad`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::MotorLoad, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::MotorLoad) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::MotorLoad) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{MotorLoad}) = InfrastructureSystems.DU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{MotorLoad}) = InfrastructureSystems.DU
"""Get [`MotorLoad`](@ref) `max_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_active_power_unitful`](@ref)."""
get_max_active_power(value::MotorLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_active_power), Val(:mw), units))
"""Get [`MotorLoad`](@ref) `max_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_active_power`](@ref)."""
get_max_active_power_unitful(value::MotorLoad, units) = get_value(value, Val(:max_active_power), Val(:mw), units)
get_max_active_power(value::MotorLoad) = _units_arg_required(get_max_active_power, value, :max_active_power, Val(:mw))
get_max_active_power_unitful(value::MotorLoad) = _units_arg_required(get_max_active_power_unitful, value, :max_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_max_active_power), ::Type{MotorLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_active_power_unitful), ::Type{MotorLoad}) = InfrastructureSystems.SU
"""Get [`MotorLoad`](@ref) `reactive_power_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_unitful`](@ref)."""
get_reactive_power_limits(value::MotorLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits), Val(:mvar), units))
"""Get [`MotorLoad`](@ref) `reactive_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_limits`](@ref)."""
get_reactive_power_limits_unitful(value::MotorLoad, units) = get_value(value, Val(:reactive_power_limits), Val(:mvar), units)
get_reactive_power_limits(value::MotorLoad) = _units_arg_required(get_reactive_power_limits, value, :reactive_power_limits, Val(:mvar))
get_reactive_power_limits_unitful(value::MotorLoad) = _units_arg_required(get_reactive_power_limits_unitful, value, :reactive_power_limits, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits), ::Type{MotorLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_unitful), ::Type{MotorLoad}) = InfrastructureSystems.SU
"""Get [`MotorLoad`](@ref) `motor_technology`."""
get_motor_technology(value::MotorLoad) = value.motor_technology
"""Get [`MotorLoad`](@ref) `services`."""
get_services(value::MotorLoad) = value.services
"""Get [`MotorLoad`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::MotorLoad) = value.dynamic_injector
"""Get [`MotorLoad`](@ref) `ext`."""
get_ext(value::MotorLoad) = value.ext
"""Get [`MotorLoad`](@ref) `internal`."""
get_internal(value::MotorLoad) = value.internal

"""Set [`MotorLoad`](@ref) `available`."""
set_available!(value::MotorLoad, val) = value.available = val
"""Set [`MotorLoad`](@ref) `bus`."""
set_bus!(value::MotorLoad, val) = value.bus = val
"""Set [`MotorLoad`](@ref) `active_power`."""
set_active_power!(value::MotorLoad, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::MotorLoad, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`MotorLoad`](@ref) `reactive_power`."""
set_reactive_power!(value::MotorLoad, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::MotorLoad, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`MotorLoad`](@ref) `rating`."""
set_rating!(value::MotorLoad, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::MotorLoad, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`MotorLoad`](@ref) `max_active_power`."""
set_max_active_power!(value::MotorLoad, val) = value.max_active_power = set_value(value, Val(:max_active_power), val, Val(:mw))
set_max_active_power!(value::MotorLoad, val::_UntaggedNumber) = _units_tag_required(set_max_active_power!, value, :max_active_power, Val(:mw), val)
"""Set [`MotorLoad`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::MotorLoad, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mvar))
set_reactive_power_limits!(value::MotorLoad, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
set_reactive_power_limits!(value::MotorLoad, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
"""Set [`MotorLoad`](@ref) `motor_technology`."""
set_motor_technology!(value::MotorLoad, val) = value.motor_technology = val
"""Set [`MotorLoad`](@ref) `services`."""
set_services!(value::MotorLoad, val) = value.services = val
"""Set [`MotorLoad`](@ref) `ext`."""
set_ext!(value::MotorLoad, val) = value.ext = val


function from_openapi(po::PO.MotorLoad, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return MotorLoad(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power,
        reactive_power = po.reactive_power,
        base_power = po.base_power,
        rating = po.rating,
        max_active_power = po.max_active_power,
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits),
        motor_technology = MotorLoadTechnology(po.motor_technology),
    )
end

function from_openapi(po::PO.MotorLoad, refs::OpenAPIRefs, ::NaturalUnit)
    return MotorLoad(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power / po.base_power,
        reactive_power = po.reactive_power / po.base_power,
        base_power = po.base_power,
        rating = po.rating / po.base_power,
        max_active_power = po.max_active_power / po.base_power,
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits, (/), po.base_power),
        motor_technology = MotorLoadTechnology(po.motor_technology),
    )
end

function from_openapi(po::PO.MotorLoad, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("MotorLoad", po.id, po.power_units))
end

function to_openapi(value::MotorLoad, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PO.MotorLoad(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, DU),
        reactive_power = get_reactive_power(value, DU),
        base_power = _get_base_power(value),
        rating = get_rating(value, DU),
        max_active_power = get_max_active_power(value, DU),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(value, DU)),
        motor_technology = string(get_motor_technology(value)),
        power_units = _power_units_string(DU),
    )
end

function to_openapi(value::MotorLoad, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.MotorLoad(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, DU) * _get_base_power(value),
        reactive_power = get_reactive_power(value, DU) * _get_base_power(value),
        base_power = _get_base_power(value),
        rating = get_rating(value, DU) * _get_base_power(value),
        max_active_power = get_max_active_power(value, DU) * _get_base_power(value),
        reactive_power_limits = _minmax_po_scaled_optional(get_reactive_power_limits(value, DU), _get_base_power(value)),
        motor_technology = string(get_motor_technology(value)),
        power_units = _power_units_string(NU),
    )
end
