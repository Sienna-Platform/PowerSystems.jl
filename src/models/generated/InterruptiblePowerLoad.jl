#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct InterruptiblePowerLoad <: ControllableLoad
        name::String
        available::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        max_active_power::Float64
        max_reactive_power::Float64
        base_power::Float64
        operation_cost::OperationalCost
        conformity::LoadConformity
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A [static](@ref S) power load that can be compensated for temporary or continuous interruptions to its requested demand.

 These loads are most commonly used for operational optimizations and can be used to model, for example, large commercial and industrial customers enrolled in demand response programs. This load has a target demand profile (set by a [`max_active_power` time series](@ref ts_data) for an operational simulation) that can be reduced to satisfy other system needs. For simpler loads without an operating cost for demand response, see [`PowerLoad`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial steady state active power demand (MW)
- `reactive_power::Float64`: Initial steady state reactive power demand (MVAR)
- `max_active_power::Float64`: Maximum active power (MW) that this load can demand
- `max_reactive_power::Float64`: Maximum reactive power (MVAR) that this load can demand
- `base_power::Float64`: Base power (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `operation_cost::OperationalCost`: [`OperationalCost`](@ref) of interrupting load
- `conformity::LoadConformity`: (default: `LoadConformity.UNDEFINED`) Indicates whether the specified load is conforming or non-conforming. Options are [listed here](@ref loadconform_list).
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct InterruptiblePowerLoad <: ControllableLoad
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Initial steady state active power demand (MW)"
    active_power::Float64
    "Initial steady state reactive power demand (MVAR)"
    reactive_power::Float64
    "Maximum active power (MW) that this load can demand"
    max_active_power::Float64
    "Maximum reactive power (MVAR) that this load can demand"
    max_reactive_power::Float64
    "Base power (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "[`OperationalCost`](@ref) of interrupting load"
    operation_cost::OperationalCost
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

function InterruptiblePowerLoad(name, available, bus, active_power, reactive_power, max_active_power, max_reactive_power, base_power, operation_cost, conformity=LoadConformity.UNDEFINED, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    InterruptiblePowerLoad(name, available, bus, active_power, reactive_power, max_active_power, max_reactive_power, base_power, operation_cost, conformity, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function InterruptiblePowerLoad(; name, available, bus, active_power, reactive_power, max_active_power, max_reactive_power, base_power, operation_cost, conformity=LoadConformity.UNDEFINED, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    InterruptiblePowerLoad(name, available, bus, active_power, reactive_power, max_active_power, max_reactive_power, base_power, operation_cost, conformity, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function InterruptiblePowerLoad(::Nothing)
    InterruptiblePowerLoad(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        max_active_power=0.0,
        max_reactive_power=0.0,
        base_power=100.0,
        operation_cost=LoadCost(nothing),
        conformity=LoadConformity.UNDEFINED,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`InterruptiblePowerLoad`](@ref) `name`."""
get_name(value::InterruptiblePowerLoad) = value.name
"""Get [`InterruptiblePowerLoad`](@ref) `available`."""
get_available(value::InterruptiblePowerLoad) = value.available
"""Get [`InterruptiblePowerLoad`](@ref) `bus`."""
get_bus(value::InterruptiblePowerLoad) = value.bus
"""Get [`InterruptiblePowerLoad`](@ref) `active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::InterruptiblePowerLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`InterruptiblePowerLoad`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::InterruptiblePowerLoad, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::InterruptiblePowerLoad) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::InterruptiblePowerLoad) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{InterruptiblePowerLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{InterruptiblePowerLoad}) = InfrastructureSystems.SU
"""Get [`InterruptiblePowerLoad`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::InterruptiblePowerLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`InterruptiblePowerLoad`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::InterruptiblePowerLoad, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::InterruptiblePowerLoad) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::InterruptiblePowerLoad) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{InterruptiblePowerLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{InterruptiblePowerLoad}) = InfrastructureSystems.SU
"""Get [`InterruptiblePowerLoad`](@ref) `max_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_active_power_unitful`](@ref)."""
get_max_active_power(value::InterruptiblePowerLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_active_power), Val(:mw), units))
"""Get [`InterruptiblePowerLoad`](@ref) `max_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_active_power`](@ref)."""
get_max_active_power_unitful(value::InterruptiblePowerLoad, units) = get_value(value, Val(:max_active_power), Val(:mw), units)
get_max_active_power(value::InterruptiblePowerLoad) = _units_arg_required(get_max_active_power, value, :max_active_power, Val(:mw))
get_max_active_power_unitful(value::InterruptiblePowerLoad) = _units_arg_required(get_max_active_power_unitful, value, :max_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_max_active_power), ::Type{InterruptiblePowerLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_active_power_unitful), ::Type{InterruptiblePowerLoad}) = InfrastructureSystems.SU
"""Get [`InterruptiblePowerLoad`](@ref) `max_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_reactive_power_unitful`](@ref)."""
get_max_reactive_power(value::InterruptiblePowerLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_reactive_power), Val(:mvar), units))
"""Get [`InterruptiblePowerLoad`](@ref) `max_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_reactive_power`](@ref)."""
get_max_reactive_power_unitful(value::InterruptiblePowerLoad, units) = get_value(value, Val(:max_reactive_power), Val(:mvar), units)
get_max_reactive_power(value::InterruptiblePowerLoad) = _units_arg_required(get_max_reactive_power, value, :max_reactive_power, Val(:mvar))
get_max_reactive_power_unitful(value::InterruptiblePowerLoad) = _units_arg_required(get_max_reactive_power_unitful, value, :max_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_max_reactive_power), ::Type{InterruptiblePowerLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_reactive_power_unitful), ::Type{InterruptiblePowerLoad}) = InfrastructureSystems.SU

_get_base_power(value::InterruptiblePowerLoad) = value.base_power
"""Get [`InterruptiblePowerLoad`](@ref) `operation_cost`."""
get_operation_cost(value::InterruptiblePowerLoad) = value.operation_cost
"""Get [`InterruptiblePowerLoad`](@ref) `conformity`."""
get_conformity(value::InterruptiblePowerLoad) = value.conformity
"""Get [`InterruptiblePowerLoad`](@ref) `services`."""
get_services(value::InterruptiblePowerLoad) = value.services
"""Get [`InterruptiblePowerLoad`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::InterruptiblePowerLoad) = value.dynamic_injector
"""Get [`InterruptiblePowerLoad`](@ref) `ext`."""
get_ext(value::InterruptiblePowerLoad) = value.ext
"""Get [`InterruptiblePowerLoad`](@ref) `internal`."""
get_internal(value::InterruptiblePowerLoad) = value.internal

"""Set [`InterruptiblePowerLoad`](@ref) `available`."""
set_available!(value::InterruptiblePowerLoad, val) = value.available = val
"""Set [`InterruptiblePowerLoad`](@ref) `bus`."""
set_bus!(value::InterruptiblePowerLoad, val) = value.bus = val
"""Set [`InterruptiblePowerLoad`](@ref) `active_power`."""
set_active_power!(value::InterruptiblePowerLoad, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::InterruptiblePowerLoad, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`InterruptiblePowerLoad`](@ref) `reactive_power`."""
set_reactive_power!(value::InterruptiblePowerLoad, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::InterruptiblePowerLoad, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`InterruptiblePowerLoad`](@ref) `max_active_power`."""
set_max_active_power!(value::InterruptiblePowerLoad, val) = value.max_active_power = set_value(value, Val(:max_active_power), val, Val(:mw))
set_max_active_power!(value::InterruptiblePowerLoad, val::_UntaggedNumber) = _units_tag_required(set_max_active_power!, value, :max_active_power, Val(:mw), val)
"""Set [`InterruptiblePowerLoad`](@ref) `max_reactive_power`."""
set_max_reactive_power!(value::InterruptiblePowerLoad, val) = value.max_reactive_power = set_value(value, Val(:max_reactive_power), val, Val(:mvar))
set_max_reactive_power!(value::InterruptiblePowerLoad, val::_UntaggedNumber) = _units_tag_required(set_max_reactive_power!, value, :max_reactive_power, Val(:mvar), val)
"""Set [`InterruptiblePowerLoad`](@ref) `operation_cost`."""
set_operation_cost!(value::InterruptiblePowerLoad, val) = value.operation_cost = val
"""Set [`InterruptiblePowerLoad`](@ref) `conformity`."""
set_conformity!(value::InterruptiblePowerLoad, val) = value.conformity = val
"""Set [`InterruptiblePowerLoad`](@ref) `services`."""
set_services!(value::InterruptiblePowerLoad, val) = value.services = val
"""Set [`InterruptiblePowerLoad`](@ref) `ext`."""
set_ext!(value::InterruptiblePowerLoad, val) = value.ext = val


function from_openapi(po::PO.InterruptiblePowerLoad, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return InterruptiblePowerLoad(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power,
        reactive_power = po.reactive_power,
        max_active_power = po.max_active_power,
        max_reactive_power = po.max_reactive_power,
        base_power = po.base_power,
        operation_cost = convert_cost(po.operation_cost)::OperationalCost,
        conformity = LoadConformity(po.conformity),
    )
end

function from_openapi(po::PO.InterruptiblePowerLoad, refs::OpenAPIRefs, ::NaturalUnit)
    return InterruptiblePowerLoad(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power / po.base_power,
        reactive_power = po.reactive_power / po.base_power,
        max_active_power = po.max_active_power / po.base_power,
        max_reactive_power = po.max_reactive_power / po.base_power,
        base_power = po.base_power,
        operation_cost = convert_cost(po.operation_cost)::OperationalCost,
        conformity = LoadConformity(po.conformity),
    )
end

function from_openapi(po::PO.InterruptiblePowerLoad, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("InterruptiblePowerLoad", po.id, po.power_units))
end

function to_openapi(value::InterruptiblePowerLoad, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PO.InterruptiblePowerLoad(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, DU),
        reactive_power = get_reactive_power(value, DU),
        max_active_power = get_max_active_power(value, DU),
        max_reactive_power = get_max_reactive_power(value, DU),
        base_power = _get_base_power(value),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
        conformity = string(get_conformity(value)),
        power_units = _power_units_string(DU),
    )
end

function to_openapi(value::InterruptiblePowerLoad, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.InterruptiblePowerLoad(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, DU) * _get_base_power(value),
        reactive_power = get_reactive_power(value, DU) * _get_base_power(value),
        max_active_power = get_max_active_power(value, DU) * _get_base_power(value),
        max_reactive_power = get_max_reactive_power(value, DU) * _get_base_power(value),
        base_power = _get_base_power(value),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
        conformity = string(get_conformity(value)),
        power_units = _power_units_string(NU),
    )
end
