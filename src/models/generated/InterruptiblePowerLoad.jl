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
"""Get [`InterruptiblePowerLoad`](@ref) `active_power`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_active_power(value::InterruptiblePowerLoad, units) = get_value(value, Val(:active_power), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{ InterruptiblePowerLoad }) = InfrastructureSystems.SU
"""Get [`InterruptiblePowerLoad`](@ref) `reactive_power`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_reactive_power(value::InterruptiblePowerLoad, units) = get_value(value, Val(:reactive_power), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{ InterruptiblePowerLoad }) = InfrastructureSystems.SU
"""Get [`InterruptiblePowerLoad`](@ref) `max_active_power`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_max_active_power(value::InterruptiblePowerLoad, units) = get_value(value, Val(:max_active_power), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_max_active_power), ::Type{ InterruptiblePowerLoad }) = InfrastructureSystems.SU
"""Get [`InterruptiblePowerLoad`](@ref) `max_reactive_power`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_max_reactive_power(value::InterruptiblePowerLoad, units) = get_value(value, Val(:max_reactive_power), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_max_reactive_power), ::Type{ InterruptiblePowerLoad }) = InfrastructureSystems.SU

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
set_active_power!(value::InterruptiblePowerLoad, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`InterruptiblePowerLoad`](@ref) `reactive_power`."""
set_reactive_power!(value::InterruptiblePowerLoad, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mva))
"""Set [`InterruptiblePowerLoad`](@ref) `max_active_power`."""
set_max_active_power!(value::InterruptiblePowerLoad, val) = value.max_active_power = set_value(value, Val(:max_active_power), val, Val(:mva))
"""Set [`InterruptiblePowerLoad`](@ref) `max_reactive_power`."""
set_max_reactive_power!(value::InterruptiblePowerLoad, val) = value.max_reactive_power = set_value(value, Val(:max_reactive_power), val, Val(:mva))
"""Set [`InterruptiblePowerLoad`](@ref) `base_power`."""
set_base_power!(value::InterruptiblePowerLoad, val) = value.base_power = val
"""Set [`InterruptiblePowerLoad`](@ref) `operation_cost`."""
set_operation_cost!(value::InterruptiblePowerLoad, val) = value.operation_cost = val
"""Set [`InterruptiblePowerLoad`](@ref) `conformity`."""
set_conformity!(value::InterruptiblePowerLoad, val) = value.conformity = val
"""Set [`InterruptiblePowerLoad`](@ref) `services`."""
set_services!(value::InterruptiblePowerLoad, val) = value.services = val
"""Set [`InterruptiblePowerLoad`](@ref) `ext`."""
set_ext!(value::InterruptiblePowerLoad, val) = value.ext = val
