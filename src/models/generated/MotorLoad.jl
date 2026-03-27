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
"""Get [`MotorLoad`](@ref) `active_power`. Returns value in the system's unit setting (natural units by default)."""
get_active_power(value::MotorLoad) = get_value(value, Val(:active_power), Val(:mva), _get_system_units(value, Val(:mva)))
get_active_power(value::MotorLoad, units) = get_value(value, Val(:active_power), Val(:mva), units)
"""Get [`MotorLoad`](@ref) `reactive_power`. Returns value in the system's unit setting (natural units by default)."""
get_reactive_power(value::MotorLoad) = get_value(value, Val(:reactive_power), Val(:mva), _get_system_units(value, Val(:mva)))
get_reactive_power(value::MotorLoad, units) = get_value(value, Val(:reactive_power), Val(:mva), units)

_get_base_power(value::MotorLoad) = value.base_power
"""Get [`MotorLoad`](@ref) `rating`. Returns value in the system's unit setting (natural units by default)."""
get_rating(value::MotorLoad) = get_value(value, Val(:rating), Val(:mva), _get_system_units(value, Val(:mva)))
get_rating(value::MotorLoad, units) = get_value(value, Val(:rating), Val(:mva), units)
"""Get [`MotorLoad`](@ref) `max_active_power`. Returns value in the system's unit setting (natural units by default)."""
get_max_active_power(value::MotorLoad) = get_value(value, Val(:max_active_power), Val(:mva), _get_system_units(value, Val(:mva)))
get_max_active_power(value::MotorLoad, units) = get_value(value, Val(:max_active_power), Val(:mva), units)
"""Get [`MotorLoad`](@ref) `reactive_power_limits`. Returns value in the system's unit setting (natural units by default)."""
get_reactive_power_limits(value::MotorLoad) = get_value(value, Val(:reactive_power_limits), Val(:mva), _get_system_units(value, Val(:mva)))
get_reactive_power_limits(value::MotorLoad, units) = get_value(value, Val(:reactive_power_limits), Val(:mva), units)
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
"""Set [`MotorLoad`](@ref) `active_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power!(value::MotorLoad, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`MotorLoad`](@ref) `reactive_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power!(value::MotorLoad, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mva))
"""Set [`MotorLoad`](@ref) `rating`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating!(value::MotorLoad, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`MotorLoad`](@ref) `max_active_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_max_active_power!(value::MotorLoad, val) = value.max_active_power = set_value(value, Val(:max_active_power), val, Val(:mva))
"""Set [`MotorLoad`](@ref) `reactive_power_limits`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power_limits!(value::MotorLoad, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mva))
"""Set [`MotorLoad`](@ref) `motor_technology`."""
set_motor_technology!(value::MotorLoad, val) = value.motor_technology = val
"""Set [`MotorLoad`](@ref) `services`."""
set_services!(value::MotorLoad, val) = value.services = val
"""Set [`MotorLoad`](@ref) `ext`."""
set_ext!(value::MotorLoad, val) = value.ext = val
