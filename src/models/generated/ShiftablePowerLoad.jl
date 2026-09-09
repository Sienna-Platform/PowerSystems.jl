#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ShiftablePowerLoad <: ControllableLoad
        name::String
        available::Bool
        bus::ACBus
        active_power::Float64
        active_power_limits::MinMax
        reactive_power::Float64
        max_active_power::Float64
        max_reactive_power::Float64
        base_power::Float64
        load_balance_time_horizon::Int
        operation_cost::OperationalCost
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A [static](@ref S) power load that can be partially or completed shifted to later time periods.

 These loads are used to model demand response. This load has a target demand profile (set by a [`max_active_power` time series](@ref ts_data) for an operational simulation). Load in the profile can be shifted to later time periods to aid in satisfying other system needs; however, any shifted load must be served within a designated time horizon (e.g., 24 hours), which is set by `load_balance_time_horizon`.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial steady state active power demand (MW)
- `active_power_limits::MinMax`: Minimum and maximum stable active power levels (MW)
- `reactive_power::Float64`: Initial steady state reactive power demand (MVAR)
- `max_active_power::Float64`: Maximum active power (MW) that this load can demand
- `max_reactive_power::Float64`: Maximum reactive power (MVAR) that this load can demand
- `base_power::Float64`: Base power (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `load_balance_time_horizon::Int`: Number of time periods over which load must be balanced, validation range: `(1, nothing)`
- `operation_cost::OperationalCost`: [`OperationalCost`](@ref) of interrupting load
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ShiftablePowerLoad <: ControllableLoad
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Initial steady state active power demand (MW)"
    active_power::Float64
    "Minimum and maximum stable active power levels (MW)"
    active_power_limits::MinMax
    "Initial steady state reactive power demand (MVAR)"
    reactive_power::Float64
    "Maximum active power (MW) that this load can demand"
    max_active_power::Float64
    "Maximum reactive power (MVAR) that this load can demand"
    max_reactive_power::Float64
    "Base power (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Number of time periods over which load must be balanced"
    load_balance_time_horizon::Int
    "[`OperationalCost`](@ref) of interrupting load"
    operation_cost::OperationalCost
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ShiftablePowerLoad(name, available, bus, active_power, active_power_limits, reactive_power, max_active_power, max_reactive_power, base_power, load_balance_time_horizon, operation_cost, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    ShiftablePowerLoad(name, available, bus, active_power, active_power_limits, reactive_power, max_active_power, max_reactive_power, base_power, load_balance_time_horizon, operation_cost, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function ShiftablePowerLoad(; name, available, bus, active_power, active_power_limits, reactive_power, max_active_power, max_reactive_power, base_power, load_balance_time_horizon, operation_cost, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    ShiftablePowerLoad(name, available, bus, active_power, active_power_limits, reactive_power, max_active_power, max_reactive_power, base_power, load_balance_time_horizon, operation_cost, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function ShiftablePowerLoad(::Nothing)
    ShiftablePowerLoad(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        active_power=0.0,
        active_power_limits=(min=0.0, max=0.0),
        reactive_power=0.0,
        max_active_power=0.0,
        max_reactive_power=0.0,
        base_power=100.0,
        load_balance_time_horizon=1,
        operation_cost=LoadCost(nothing),
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ShiftablePowerLoad`](@ref) `name`."""
get_name(value::ShiftablePowerLoad) = value.name
"""Get [`ShiftablePowerLoad`](@ref) `available`."""
get_available(value::ShiftablePowerLoad) = value.available
"""Get [`ShiftablePowerLoad`](@ref) `bus`."""
get_bus(value::ShiftablePowerLoad) = value.bus
"""Get [`ShiftablePowerLoad`](@ref) `active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::ShiftablePowerLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`ShiftablePowerLoad`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::ShiftablePowerLoad, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::ShiftablePowerLoad) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::ShiftablePowerLoad) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{ShiftablePowerLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{ShiftablePowerLoad}) = InfrastructureSystems.SU
"""Get [`ShiftablePowerLoad`](@ref) `active_power_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_limits_unitful`](@ref)."""
get_active_power_limits(value::ShiftablePowerLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits), Val(:mw), units))
"""Get [`ShiftablePowerLoad`](@ref) `active_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_limits`](@ref)."""
get_active_power_limits_unitful(value::ShiftablePowerLoad, units) = get_value(value, Val(:active_power_limits), Val(:mw), units)
get_active_power_limits(value::ShiftablePowerLoad) = _units_arg_required(get_active_power_limits, value, :active_power_limits, Val(:mw))
get_active_power_limits_unitful(value::ShiftablePowerLoad) = _units_arg_required(get_active_power_limits_unitful, value, :active_power_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits), ::Type{ShiftablePowerLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_unitful), ::Type{ShiftablePowerLoad}) = InfrastructureSystems.SU
"""Get [`ShiftablePowerLoad`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::ShiftablePowerLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`ShiftablePowerLoad`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::ShiftablePowerLoad, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::ShiftablePowerLoad) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::ShiftablePowerLoad) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{ShiftablePowerLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{ShiftablePowerLoad}) = InfrastructureSystems.SU
"""Get [`ShiftablePowerLoad`](@ref) `max_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_active_power_unitful`](@ref)."""
get_max_active_power(value::ShiftablePowerLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_active_power), Val(:mw), units))
"""Get [`ShiftablePowerLoad`](@ref) `max_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_active_power`](@ref)."""
get_max_active_power_unitful(value::ShiftablePowerLoad, units) = get_value(value, Val(:max_active_power), Val(:mw), units)
get_max_active_power(value::ShiftablePowerLoad) = _units_arg_required(get_max_active_power, value, :max_active_power, Val(:mw))
get_max_active_power_unitful(value::ShiftablePowerLoad) = _units_arg_required(get_max_active_power_unitful, value, :max_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_max_active_power), ::Type{ShiftablePowerLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_active_power_unitful), ::Type{ShiftablePowerLoad}) = InfrastructureSystems.SU
"""Get [`ShiftablePowerLoad`](@ref) `max_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_reactive_power_unitful`](@ref)."""
get_max_reactive_power(value::ShiftablePowerLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_reactive_power), Val(:mvar), units))
"""Get [`ShiftablePowerLoad`](@ref) `max_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_reactive_power`](@ref)."""
get_max_reactive_power_unitful(value::ShiftablePowerLoad, units) = get_value(value, Val(:max_reactive_power), Val(:mvar), units)
get_max_reactive_power(value::ShiftablePowerLoad) = _units_arg_required(get_max_reactive_power, value, :max_reactive_power, Val(:mvar))
get_max_reactive_power_unitful(value::ShiftablePowerLoad) = _units_arg_required(get_max_reactive_power_unitful, value, :max_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_max_reactive_power), ::Type{ShiftablePowerLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_reactive_power_unitful), ::Type{ShiftablePowerLoad}) = InfrastructureSystems.SU

_get_base_power(value::ShiftablePowerLoad) = value.base_power
"""Get [`ShiftablePowerLoad`](@ref) `load_balance_time_horizon`."""
get_load_balance_time_horizon(value::ShiftablePowerLoad) = value.load_balance_time_horizon
"""Get [`ShiftablePowerLoad`](@ref) `operation_cost`."""
get_operation_cost(value::ShiftablePowerLoad) = value.operation_cost
"""Get [`ShiftablePowerLoad`](@ref) `services`."""
get_services(value::ShiftablePowerLoad) = value.services
"""Get [`ShiftablePowerLoad`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::ShiftablePowerLoad) = value.dynamic_injector
"""Get [`ShiftablePowerLoad`](@ref) `ext`."""
get_ext(value::ShiftablePowerLoad) = value.ext
"""Get [`ShiftablePowerLoad`](@ref) `internal`."""
get_internal(value::ShiftablePowerLoad) = value.internal

"""Set [`ShiftablePowerLoad`](@ref) `available`."""
set_available!(value::ShiftablePowerLoad, val) = value.available = val
"""Set [`ShiftablePowerLoad`](@ref) `bus`."""
set_bus!(value::ShiftablePowerLoad, val) = value.bus = val
"""Set [`ShiftablePowerLoad`](@ref) `active_power`."""
set_active_power!(value::ShiftablePowerLoad, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::ShiftablePowerLoad, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`ShiftablePowerLoad`](@ref) `active_power_limits`."""
set_active_power_limits!(value::ShiftablePowerLoad, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mw))
set_active_power_limits!(value::ShiftablePowerLoad, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
set_active_power_limits!(value::ShiftablePowerLoad, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
"""Set [`ShiftablePowerLoad`](@ref) `reactive_power`."""
set_reactive_power!(value::ShiftablePowerLoad, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::ShiftablePowerLoad, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`ShiftablePowerLoad`](@ref) `max_active_power`."""
set_max_active_power!(value::ShiftablePowerLoad, val) = value.max_active_power = set_value(value, Val(:max_active_power), val, Val(:mw))
set_max_active_power!(value::ShiftablePowerLoad, val::_UntaggedNumber) = _units_tag_required(set_max_active_power!, value, :max_active_power, Val(:mw), val)
"""Set [`ShiftablePowerLoad`](@ref) `max_reactive_power`."""
set_max_reactive_power!(value::ShiftablePowerLoad, val) = value.max_reactive_power = set_value(value, Val(:max_reactive_power), val, Val(:mvar))
set_max_reactive_power!(value::ShiftablePowerLoad, val::_UntaggedNumber) = _units_tag_required(set_max_reactive_power!, value, :max_reactive_power, Val(:mvar), val)
"""Set [`ShiftablePowerLoad`](@ref) `load_balance_time_horizon`."""
set_load_balance_time_horizon!(value::ShiftablePowerLoad, val) = value.load_balance_time_horizon = val
"""Set [`ShiftablePowerLoad`](@ref) `operation_cost`."""
set_operation_cost!(value::ShiftablePowerLoad, val) = value.operation_cost = val
"""Set [`ShiftablePowerLoad`](@ref) `services`."""
set_services!(value::ShiftablePowerLoad, val) = value.services = val
"""Set [`ShiftablePowerLoad`](@ref) `ext`."""
set_ext!(value::ShiftablePowerLoad, val) = value.ext = val


function from_openapi(po::PO.ShiftablePowerLoad, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return ShiftablePowerLoad(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power,
        active_power_limits = _minmax_from_po(po.active_power_limits),
        reactive_power = po.reactive_power,
        max_active_power = po.max_active_power,
        max_reactive_power = po.max_reactive_power,
        base_power = po.base_power,
        load_balance_time_horizon = po.load_balance_time_horizon,
        operation_cost = convert_cost(po.operation_cost)::OperationalCost,
    )
end

function from_openapi(po::PO.ShiftablePowerLoad, refs::OpenAPIRefs, ::NaturalUnit)
    return ShiftablePowerLoad(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power / po.base_power,
        active_power_limits = _minmax_from_po(po.active_power_limits, (/), po.base_power),
        reactive_power = po.reactive_power / po.base_power,
        max_active_power = po.max_active_power / po.base_power,
        max_reactive_power = po.max_reactive_power / po.base_power,
        base_power = po.base_power,
        load_balance_time_horizon = po.load_balance_time_horizon,
        operation_cost = convert_cost(po.operation_cost)::OperationalCost,
    )
end

function from_openapi(po::PO.ShiftablePowerLoad, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("ShiftablePowerLoad", po.id, po.power_units))
end

function to_openapi(value::ShiftablePowerLoad, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PO.ShiftablePowerLoad(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, DU),
        active_power_limits = _minmax_po(get_active_power_limits(value, DU)),
        reactive_power = get_reactive_power(value, DU),
        max_active_power = get_max_active_power(value, DU),
        max_reactive_power = get_max_reactive_power(value, DU),
        base_power = _get_base_power(value),
        load_balance_time_horizon = get_load_balance_time_horizon(value),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
        power_units = _power_units_string(DU),
    )
end

function to_openapi(value::ShiftablePowerLoad, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.ShiftablePowerLoad(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, DU) * _get_base_power(value),
        active_power_limits = _minmax_po_scaled(get_active_power_limits(value, DU), _get_base_power(value)),
        reactive_power = get_reactive_power(value, DU) * _get_base_power(value),
        max_active_power = get_max_active_power(value, DU) * _get_base_power(value),
        max_reactive_power = get_max_reactive_power(value, DU) * _get_base_power(value),
        base_power = _get_base_power(value),
        load_balance_time_horizon = get_load_balance_time_horizon(value),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
        power_units = _power_units_string(NU),
    )
end
