#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct RenewableNonDispatch <: RenewableGen
        name::String
        available::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        rating::Float64
        prime_mover_type::PrimeMovers
        power_factor::Float64
        base_power::Float64
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A non-dispatchable (i.e., non-curtailable or must-take) renewable generator.

Its output is equal to its [`max_active_power` time series](@ref ts_data) by default. Example use: an aggregation of behind-the-meter distributed energy resources like rooftop solar. For curtailable or downward dispatachable generation, see [`RenewableDispatch`](@ref).

Renewable generators do not have a `max_active_power` parameter, which is instead calculated when calling [`get_max_active_power()`](@ref get_max_active_power(d::T) where {T <: RenewableGen})

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR), used in some production cost modeling simulations. To set the reactive power in a load flow, use `power_factor`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power, validation range: `(0, nothing)`
- `prime_mover_type::PrimeMovers`: Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
- `power_factor::Float64`: Power factor [0, 1] set-point, used in some production cost modeling and in load flow if the unit is connected to a [`PQ`](@ref acbustypes_list) bus, validation range: `(0, 1)`
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct RenewableNonDispatch <: RenewableGen
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used"
    active_power::Float64
    "Initial reactive power set point of the unit (MVAR), used in some production cost modeling simulations. To set the reactive power in a load flow, use `power_factor`"
    reactive_power::Float64
    "Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power"
    rating::Float64
    "Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)"
    prime_mover_type::PrimeMovers
    "Power factor [0, 1] set-point, used in some production cost modeling and in load flow if the unit is connected to a [`PQ`](@ref acbustypes_list) bus"
    power_factor::Float64
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function RenewableNonDispatch(name, available, bus, active_power, reactive_power, rating, prime_mover_type, power_factor, base_power, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    RenewableNonDispatch(name, available, bus, active_power, reactive_power, rating, prime_mover_type, power_factor, base_power, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function RenewableNonDispatch(; name, available, bus, active_power, reactive_power, rating, prime_mover_type, power_factor, base_power, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    RenewableNonDispatch(name, available, bus, active_power, reactive_power, rating, prime_mover_type, power_factor, base_power, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function RenewableNonDispatch(::Nothing)
    RenewableNonDispatch(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        rating=0.0,
        prime_mover_type=PrimeMovers.OT,
        power_factor=1.0,
        base_power=100.0,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`RenewableNonDispatch`](@ref) `name`."""
get_name(value::RenewableNonDispatch) = value.name
"""Get [`RenewableNonDispatch`](@ref) `available`."""
get_available(value::RenewableNonDispatch) = value.available
"""Get [`RenewableNonDispatch`](@ref) `bus`."""
get_bus(value::RenewableNonDispatch) = value.bus
"""Get [`RenewableNonDispatch`](@ref) `active_power`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_active_power(value::RenewableNonDispatch) = get_value(value, Val(:active_power), Val(:mva), DEFAULT_UNITS)
get_active_power(value::RenewableNonDispatch, units) = get_value(value, Val(:active_power), Val(:mva), units)
"""Get [`RenewableNonDispatch`](@ref) `reactive_power`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_reactive_power(value::RenewableNonDispatch) = get_value(value, Val(:reactive_power), Val(:mva), DEFAULT_UNITS)
get_reactive_power(value::RenewableNonDispatch, units) = get_value(value, Val(:reactive_power), Val(:mva), units)
"""Get [`RenewableNonDispatch`](@ref) `rating`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_rating(value::RenewableNonDispatch) = get_value(value, Val(:rating), Val(:mva), DEFAULT_UNITS)
get_rating(value::RenewableNonDispatch, units) = get_value(value, Val(:rating), Val(:mva), units)
"""Get [`RenewableNonDispatch`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::RenewableNonDispatch) = value.prime_mover_type
"""Get [`RenewableNonDispatch`](@ref) `power_factor`."""
get_power_factor(value::RenewableNonDispatch) = value.power_factor

_get_base_power(value::RenewableNonDispatch) = value.base_power
"""Get [`RenewableNonDispatch`](@ref) `services`."""
get_services(value::RenewableNonDispatch) = value.services
"""Get [`RenewableNonDispatch`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::RenewableNonDispatch) = value.dynamic_injector
"""Get [`RenewableNonDispatch`](@ref) `ext`."""
get_ext(value::RenewableNonDispatch) = value.ext
"""Get [`RenewableNonDispatch`](@ref) `internal`."""
get_internal(value::RenewableNonDispatch) = value.internal

"""Set [`RenewableNonDispatch`](@ref) `available`."""
set_available!(value::RenewableNonDispatch, val) = value.available = val
"""Set [`RenewableNonDispatch`](@ref) `bus`."""
set_bus!(value::RenewableNonDispatch, val) = value.bus = val
"""Set [`RenewableNonDispatch`](@ref) `active_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power!(value::RenewableNonDispatch, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`RenewableNonDispatch`](@ref) `reactive_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power!(value::RenewableNonDispatch, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mva))
"""Set [`RenewableNonDispatch`](@ref) `rating`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating!(value::RenewableNonDispatch, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`RenewableNonDispatch`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::RenewableNonDispatch, val) = value.prime_mover_type = val
"""Set [`RenewableNonDispatch`](@ref) `power_factor`."""
set_power_factor!(value::RenewableNonDispatch, val) = value.power_factor = val
"""Set [`RenewableNonDispatch`](@ref) `services`."""
set_services!(value::RenewableNonDispatch, val) = value.services = val
"""Set [`RenewableNonDispatch`](@ref) `ext`."""
set_ext!(value::RenewableNonDispatch, val) = value.ext = val
