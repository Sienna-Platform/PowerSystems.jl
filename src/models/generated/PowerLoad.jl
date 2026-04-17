#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct PowerLoad <: StaticLoad
        name::String
        available::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        base_power::Float64
        max_active_power::Float64
        max_reactive_power::Float64
        conformity::LoadConformity
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A [static](@ref S) power load, most commonly used for operational models such as power flow and operational optimizations.

This load consumes a set amount of power (set by `active_power` for a power flow simulation or a `max_active_power` time series for an operational simulation). For loads that can be compensated for load interruptions through demand response programs, see [`InterruptiblePowerLoad`](@ref). For voltage-dependent loads used in [dynamics](@ref D) modeling, see [`StandardLoad`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial steady-state active power demand (MW)
- `reactive_power::Float64`: Initial steady-state reactive power demand (MVAR)
- `base_power::Float64`: Base power (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `max_active_power::Float64`: Maximum active power (MW) that this load can demand
- `max_reactive_power::Float64`: Maximum reactive power (MVAR) that this load can demand
- `conformity::LoadConformity`: (default: `LoadConformity.UNDEFINED`) Indicates whether the specified load is conforming or non-conforming. Options are [listed here](@ref loadconform_list).
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct PowerLoad <: StaticLoad
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Initial steady-state active power demand (MW)"
    active_power::Float64
    "Initial steady-state reactive power demand (MVAR)"
    reactive_power::Float64
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

function PowerLoad(name, available, bus, active_power, reactive_power, base_power, max_active_power, max_reactive_power, conformity=LoadConformity.UNDEFINED, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    PowerLoad(name, available, bus, active_power, reactive_power, base_power, max_active_power, max_reactive_power, conformity, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function PowerLoad(; name, available, bus, active_power, reactive_power, base_power, max_active_power, max_reactive_power, conformity=LoadConformity.UNDEFINED, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    PowerLoad(name, available, bus, active_power, reactive_power, base_power, max_active_power, max_reactive_power, conformity, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function PowerLoad(::Nothing)
    PowerLoad(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        base_power=100.0,
        max_active_power=0.0,
        max_reactive_power=0.0,
        conformity=LoadConformity.UNDEFINED,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`PowerLoad`](@ref) `name`."""
get_name(value::PowerLoad) = value.name
"""Get [`PowerLoad`](@ref) `available`."""
get_available(value::PowerLoad) = value.available
"""Get [`PowerLoad`](@ref) `bus`."""
get_bus(value::PowerLoad) = value.bus
"""Get [`PowerLoad`](@ref) `active_power`."""
get_active_power(value::PowerLoad) = get_value(value, Val(:active_power), Val(:mva))
get_active_power(value::PowerLoad, units) = get_value(value, Val(:active_power), Val(:mva), units)
"""Get [`PowerLoad`](@ref) `reactive_power`."""
get_reactive_power(value::PowerLoad) = get_value(value, Val(:reactive_power), Val(:mva))
get_reactive_power(value::PowerLoad, units) = get_value(value, Val(:reactive_power), Val(:mva), units)
"""Get [`PowerLoad`](@ref) `base_power`."""
get_base_power(value::PowerLoad) = value.base_power
"""Get [`PowerLoad`](@ref) `max_active_power`."""
get_max_active_power(value::PowerLoad) = get_value(value, Val(:max_active_power), Val(:mva))
get_max_active_power(value::PowerLoad, units) = get_value(value, Val(:max_active_power), Val(:mva), units)
"""Get [`PowerLoad`](@ref) `max_reactive_power`."""
get_max_reactive_power(value::PowerLoad) = get_value(value, Val(:max_reactive_power), Val(:mva))
get_max_reactive_power(value::PowerLoad, units) = get_value(value, Val(:max_reactive_power), Val(:mva), units)
"""Get [`PowerLoad`](@ref) `conformity`."""
get_conformity(value::PowerLoad) = value.conformity
"""Get [`PowerLoad`](@ref) `services`."""
get_services(value::PowerLoad) = value.services
"""Get [`PowerLoad`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::PowerLoad) = value.dynamic_injector
"""Get [`PowerLoad`](@ref) `ext`."""
get_ext(value::PowerLoad) = value.ext
"""Get [`PowerLoad`](@ref) `internal`."""
get_internal(value::PowerLoad) = value.internal

"""Set [`PowerLoad`](@ref) `available`."""
set_available!(value::PowerLoad, val) = value.available = val
"""Set [`PowerLoad`](@ref) `bus`."""
set_bus!(value::PowerLoad, val) = value.bus = val
"""Set [`PowerLoad`](@ref) `active_power`."""
set_active_power!(value::PowerLoad, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`PowerLoad`](@ref) `reactive_power`."""
set_reactive_power!(value::PowerLoad, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mva))
"""Set [`PowerLoad`](@ref) `base_power`."""
set_base_power!(value::PowerLoad, val) = value.base_power = val
"""Set [`PowerLoad`](@ref) `max_active_power`."""
set_max_active_power!(value::PowerLoad, val) = value.max_active_power = set_value(value, Val(:max_active_power), val, Val(:mva))
"""Set [`PowerLoad`](@ref) `max_reactive_power`."""
set_max_reactive_power!(value::PowerLoad, val) = value.max_reactive_power = set_value(value, Val(:max_reactive_power), val, Val(:mva))
"""Set [`PowerLoad`](@ref) `conformity`."""
set_conformity!(value::PowerLoad, val) = value.conformity = val
"""Set [`PowerLoad`](@ref) `services`."""
set_services!(value::PowerLoad, val) = value.services = val
"""Set [`PowerLoad`](@ref) `ext`."""
set_ext!(value::PowerLoad, val) = value.ext = val
