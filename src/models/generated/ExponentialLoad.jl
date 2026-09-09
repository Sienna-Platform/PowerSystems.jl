#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ExponentialLoad <: StaticLoad
        name::String
        available::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        α::Float64
        β::Float64
        base_power::Float64
        max_active_power::Float64
        max_reactive_power::Float64
        conformity::LoadConformity
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A voltage-dependent [ZIP load](@ref Z), most commonly used for dynamics modeling.

An `ExponentialLoad` models active power as P = P0 * V^α and reactive power as Q = Q0 * V^β, where the exponents α and β select govern the voltage dependency. For an alternative three-part formulation of the ZIP model, see [`StandardLoad`](@ref). For a simpler load model with no voltage dependency, see [`PowerLoad`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Active power coefficient, P0 (MW)
- `reactive_power::Float64`: Reactive power coefficient, Q0 (MVAR)
- `α::Float64`: Exponent relating voltage dependency for active power. 0 = constant power only, 1 = constant current only, and 2 = constant impedance only, validation range: `(0, nothing)`
- `β::Float64`: Exponent relating voltage dependency for reactive power. 0 = constant power only, 1 = constant current only, and 2 = constant impedance only, validation range: `(0, nothing)`
- `base_power::Float64`: Base power (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `max_active_power::Float64`: Maximum active power (MW) that this load can demand
- `max_reactive_power::Float64`: Maximum reactive power (MVAR) that this load can demand
- `conformity::LoadConformity`: (default: `LoadConformity.UNDEFINED`) Indicates whether the specified load is conforming or non-conforming. Options are [listed here](@ref loadconform_list).
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ExponentialLoad <: StaticLoad
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Active power coefficient, P0 (MW)"
    active_power::Float64
    "Reactive power coefficient, Q0 (MVAR)"
    reactive_power::Float64
    "Exponent relating voltage dependency for active power. 0 = constant power only, 1 = constant current only, and 2 = constant impedance only"
    α::Float64
    "Exponent relating voltage dependency for reactive power. 0 = constant power only, 1 = constant current only, and 2 = constant impedance only"
    β::Float64
    "Base power (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Maximum active power (MW) that this load can demand"
    max_active_power::Float64
    "Maximum reactive power (MVAR) that this load can demand"
    max_reactive_power::Float64
    "Indicates whether the specified load is conforming or non-conforming. Options are [listed here](@ref loadconform_list)."
    conformity::LoadConformity
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ExponentialLoad(name, available, bus, active_power, reactive_power, α, β, base_power, max_active_power, max_reactive_power, conformity=LoadConformity.UNDEFINED, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    ExponentialLoad(name, available, bus, active_power, reactive_power, α, β, base_power, max_active_power, max_reactive_power, conformity, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function ExponentialLoad(; name, available, bus, active_power, reactive_power, α, β, base_power, max_active_power, max_reactive_power, conformity=LoadConformity.UNDEFINED, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    ExponentialLoad(name, available, bus, active_power, reactive_power, α, β, base_power, max_active_power, max_reactive_power, conformity, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function ExponentialLoad(::Nothing)
    ExponentialLoad(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        α=0.0,
        β=0.0,
        base_power=100.0,
        max_active_power=0.0,
        max_reactive_power=0.0,
        conformity=LoadConformity.UNDEFINED,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ExponentialLoad`](@ref) `name`."""
get_name(value::ExponentialLoad) = value.name
"""Get [`ExponentialLoad`](@ref) `available`."""
get_available(value::ExponentialLoad) = value.available
"""Get [`ExponentialLoad`](@ref) `bus`."""
get_bus(value::ExponentialLoad) = value.bus
"""Get [`ExponentialLoad`](@ref) `active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::ExponentialLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`ExponentialLoad`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::ExponentialLoad, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::ExponentialLoad) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::ExponentialLoad) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{ExponentialLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{ExponentialLoad}) = InfrastructureSystems.SU
"""Get [`ExponentialLoad`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::ExponentialLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`ExponentialLoad`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::ExponentialLoad, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::ExponentialLoad) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::ExponentialLoad) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{ExponentialLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{ExponentialLoad}) = InfrastructureSystems.SU
"""Get [`ExponentialLoad`](@ref) `α`."""
get_α(value::ExponentialLoad) = value.α
"""Get [`ExponentialLoad`](@ref) `β`."""
get_β(value::ExponentialLoad) = value.β

_get_base_power(value::ExponentialLoad) = value.base_power
"""Get [`ExponentialLoad`](@ref) `max_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_active_power_unitful`](@ref)."""
get_max_active_power(value::ExponentialLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_active_power), Val(:mw), units))
"""Get [`ExponentialLoad`](@ref) `max_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_active_power`](@ref)."""
get_max_active_power_unitful(value::ExponentialLoad, units) = get_value(value, Val(:max_active_power), Val(:mw), units)
get_max_active_power(value::ExponentialLoad) = _units_arg_required(get_max_active_power, value, :max_active_power, Val(:mw))
get_max_active_power_unitful(value::ExponentialLoad) = _units_arg_required(get_max_active_power_unitful, value, :max_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_max_active_power), ::Type{ExponentialLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_active_power_unitful), ::Type{ExponentialLoad}) = InfrastructureSystems.SU
"""Get [`ExponentialLoad`](@ref) `max_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_reactive_power_unitful`](@ref)."""
get_max_reactive_power(value::ExponentialLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_reactive_power), Val(:mvar), units))
"""Get [`ExponentialLoad`](@ref) `max_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_reactive_power`](@ref)."""
get_max_reactive_power_unitful(value::ExponentialLoad, units) = get_value(value, Val(:max_reactive_power), Val(:mvar), units)
get_max_reactive_power(value::ExponentialLoad) = _units_arg_required(get_max_reactive_power, value, :max_reactive_power, Val(:mvar))
get_max_reactive_power_unitful(value::ExponentialLoad) = _units_arg_required(get_max_reactive_power_unitful, value, :max_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_max_reactive_power), ::Type{ExponentialLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_reactive_power_unitful), ::Type{ExponentialLoad}) = InfrastructureSystems.SU
"""Get [`ExponentialLoad`](@ref) `conformity`."""
get_conformity(value::ExponentialLoad) = value.conformity
"""Get [`ExponentialLoad`](@ref) `services`."""
get_services(value::ExponentialLoad) = value.services
"""Get [`ExponentialLoad`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::ExponentialLoad) = value.dynamic_injector
"""Get [`ExponentialLoad`](@ref) `ext`."""
get_ext(value::ExponentialLoad) = value.ext
"""Get [`ExponentialLoad`](@ref) `internal`."""
get_internal(value::ExponentialLoad) = value.internal

"""Set [`ExponentialLoad`](@ref) `available`."""
set_available!(value::ExponentialLoad, val) = value.available = val
"""Set [`ExponentialLoad`](@ref) `bus`."""
set_bus!(value::ExponentialLoad, val) = value.bus = val
"""Set [`ExponentialLoad`](@ref) `active_power`."""
set_active_power!(value::ExponentialLoad, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::ExponentialLoad, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`ExponentialLoad`](@ref) `reactive_power`."""
set_reactive_power!(value::ExponentialLoad, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::ExponentialLoad, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`ExponentialLoad`](@ref) `α`."""
set_α!(value::ExponentialLoad, val) = value.α = val
"""Set [`ExponentialLoad`](@ref) `β`."""
set_β!(value::ExponentialLoad, val) = value.β = val
"""Set [`ExponentialLoad`](@ref) `max_active_power`."""
set_max_active_power!(value::ExponentialLoad, val) = value.max_active_power = set_value(value, Val(:max_active_power), val, Val(:mw))
set_max_active_power!(value::ExponentialLoad, val::_UntaggedNumber) = _units_tag_required(set_max_active_power!, value, :max_active_power, Val(:mw), val)
"""Set [`ExponentialLoad`](@ref) `max_reactive_power`."""
set_max_reactive_power!(value::ExponentialLoad, val) = value.max_reactive_power = set_value(value, Val(:max_reactive_power), val, Val(:mvar))
set_max_reactive_power!(value::ExponentialLoad, val::_UntaggedNumber) = _units_tag_required(set_max_reactive_power!, value, :max_reactive_power, Val(:mvar), val)
"""Set [`ExponentialLoad`](@ref) `conformity`."""
set_conformity!(value::ExponentialLoad, val) = value.conformity = val
"""Set [`ExponentialLoad`](@ref) `services`."""
set_services!(value::ExponentialLoad, val) = value.services = val
"""Set [`ExponentialLoad`](@ref) `ext`."""
set_ext!(value::ExponentialLoad, val) = value.ext = val


function from_openapi(po::PO.ExponentialLoad, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return ExponentialLoad(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power,
        reactive_power = po.reactive_power,
        α = po.alpha,
        β = po.beta,
        base_power = po.base_power,
        max_active_power = po.max_active_power,
        max_reactive_power = po.max_reactive_power,
        conformity = LoadConformity(po.conformity),
    )
end

function from_openapi(po::PO.ExponentialLoad, refs::OpenAPIRefs, ::NaturalUnit)
    return ExponentialLoad(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power / po.base_power,
        reactive_power = po.reactive_power / po.base_power,
        α = po.alpha,
        β = po.beta,
        base_power = po.base_power,
        max_active_power = po.max_active_power / po.base_power,
        max_reactive_power = po.max_reactive_power / po.base_power,
        conformity = LoadConformity(po.conformity),
    )
end

function from_openapi(po::PO.ExponentialLoad, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("ExponentialLoad", po.id, po.power_units))
end

function to_openapi(value::ExponentialLoad, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PO.ExponentialLoad(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, DU),
        reactive_power = get_reactive_power(value, DU),
        alpha = get_α(value),
        beta = get_β(value),
        base_power = _get_base_power(value),
        max_active_power = get_max_active_power(value, DU),
        max_reactive_power = get_max_reactive_power(value, DU),
        conformity = string(get_conformity(value)),
        power_units = _power_units_string(DU),
    )
end

function to_openapi(value::ExponentialLoad, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.ExponentialLoad(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, DU) * _get_base_power(value),
        reactive_power = get_reactive_power(value, DU) * _get_base_power(value),
        alpha = get_α(value),
        beta = get_β(value),
        base_power = _get_base_power(value),
        max_active_power = get_max_active_power(value, DU) * _get_base_power(value),
        max_reactive_power = get_max_reactive_power(value, DU) * _get_base_power(value),
        conformity = string(get_conformity(value)),
        power_units = _power_units_string(NU),
    )
end
