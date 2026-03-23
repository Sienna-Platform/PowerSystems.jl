#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct RenewableDispatch <: RenewableGen
        name::String
        available::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        rating::Float64
        prime_mover_type::PrimeMovers
        reactive_power_limits::Union{Nothing, MinMax}
        power_factor::Float64
        operation_cost::Union{RenewableGenerationCost, MarketBidCost}
        base_power::Float64
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A renewable (e.g., wind or solar) generator whose output can be curtailed to satisfy power system constraints.

These generators can also participate in reserves markets, including upwards reserves by proactively curtailing some available power (based on its [`max_active_power` time series](@ref ts_data)). Example uses include: a utility-scale wind or solar generator whose PPA allows curtailment. For non-curtailable or must-take renewables, see [`RenewableNonDispatch`](@ref).

Renewable generators do not have a `max_active_power` parameter, which is instead calculated when calling [`get_max_active_power()`](@ref get_max_active_power(d::RenewableGen))

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR), used in some production cost modeling simulations. To set the reactive power in a load flow, use `power_factor`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power, validation range: `(0, nothing)`
- `prime_mover_type::PrimeMovers`: Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
- `reactive_power_limits::Union{Nothing, MinMax}`: Minimum and maximum reactive power limits, used in some production cost model simulations and in power flow if the unit is connected to a [`PV`](@ref acbustypes_list) bus. Set to `nothing` if not applicable
- `power_factor::Float64`: Power factor [0, 1] set-point, used in some production cost modeling and in load flow if the unit is connected to a [`PQ`](@ref acbustypes_list) bus, validation range: `(0, 1)`
- `operation_cost::Union{RenewableGenerationCost, MarketBidCost}`: [`OperationalCost`](@ref) of generation
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct RenewableDispatch <: RenewableGen
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
    "Minimum and maximum reactive power limits, used in some production cost model simulations and in power flow if the unit is connected to a [`PV`](@ref acbustypes_list) bus. Set to `nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "Power factor [0, 1] set-point, used in some production cost modeling and in load flow if the unit is connected to a [`PQ`](@ref acbustypes_list) bus"
    power_factor::Float64
    "[`OperationalCost`](@ref) of generation"
    operation_cost::Union{RenewableGenerationCost, MarketBidCost}
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

function RenewableDispatch(name, available, bus, active_power, reactive_power, rating, prime_mover_type, reactive_power_limits, power_factor, operation_cost, base_power, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    RenewableDispatch(name, available, bus, active_power, reactive_power, rating, prime_mover_type, reactive_power_limits, power_factor, operation_cost, base_power, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function RenewableDispatch(; name, available, bus, active_power, reactive_power, rating, prime_mover_type, reactive_power_limits, power_factor, operation_cost, base_power, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    RenewableDispatch(name, available, bus, active_power, reactive_power, rating, prime_mover_type, reactive_power_limits, power_factor, operation_cost, base_power, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function RenewableDispatch(::Nothing)
    RenewableDispatch(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        rating=0.0,
        prime_mover_type=PrimeMovers.OT,
        reactive_power_limits=nothing,
        power_factor=1.0,
        operation_cost=RenewableGenerationCost(nothing),
        base_power=100.0,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`RenewableDispatch`](@ref) `name`."""
get_name(value::RenewableDispatch) = value.name
"""Get [`RenewableDispatch`](@ref) `available`."""
get_available(value::RenewableDispatch) = value.available
"""Get [`RenewableDispatch`](@ref) `bus`."""
get_bus(value::RenewableDispatch) = value.bus
"""Get [`RenewableDispatch`](@ref) `active_power`."""
get_active_power(value::RenewableDispatch) = get_value(value, Val(:active_power), Val(:mva))
"""Get [`RenewableDispatch`](@ref) `reactive_power`."""
get_reactive_power(value::RenewableDispatch) = get_value(value, Val(:reactive_power), Val(:mva))
"""Get [`RenewableDispatch`](@ref) `rating`."""
get_rating(value::RenewableDispatch) = get_value(value, Val(:rating), Val(:mva))
"""Get [`RenewableDispatch`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::RenewableDispatch) = value.prime_mover_type
"""Get [`RenewableDispatch`](@ref) `reactive_power_limits`."""
get_reactive_power_limits(value::RenewableDispatch) = get_value(value, Val(:reactive_power_limits), Val(:mva))
"""Get [`RenewableDispatch`](@ref) `power_factor`."""
get_power_factor(value::RenewableDispatch) = value.power_factor
"""Get [`RenewableDispatch`](@ref) `operation_cost`."""
get_operation_cost(value::RenewableDispatch) = value.operation_cost
"""Get [`RenewableDispatch`](@ref) `base_power`."""
get_base_power(value::RenewableDispatch) = value.base_power
"""Get [`RenewableDispatch`](@ref) `services`."""
get_services(value::RenewableDispatch) = value.services
"""Get [`RenewableDispatch`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::RenewableDispatch) = value.dynamic_injector
"""Get [`RenewableDispatch`](@ref) `ext`."""
get_ext(value::RenewableDispatch) = value.ext
"""Get [`RenewableDispatch`](@ref) `internal`."""
get_internal(value::RenewableDispatch) = value.internal

"""Set [`RenewableDispatch`](@ref) `available`."""
set_available!(value::RenewableDispatch, val) = value.available = val
"""Set [`RenewableDispatch`](@ref) `bus`."""
set_bus!(value::RenewableDispatch, val) = value.bus = val
"""Set [`RenewableDispatch`](@ref) `active_power`."""
set_active_power!(value::RenewableDispatch, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`RenewableDispatch`](@ref) `reactive_power`."""
set_reactive_power!(value::RenewableDispatch, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mva))
"""Set [`RenewableDispatch`](@ref) `rating`."""
set_rating!(value::RenewableDispatch, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`RenewableDispatch`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::RenewableDispatch, val) = value.prime_mover_type = val
"""Set [`RenewableDispatch`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::RenewableDispatch, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mva))
"""Set [`RenewableDispatch`](@ref) `power_factor`."""
set_power_factor!(value::RenewableDispatch, val) = value.power_factor = val
"""Set [`RenewableDispatch`](@ref) `operation_cost`."""
set_operation_cost!(value::RenewableDispatch, val) = value.operation_cost = val
"""Set [`RenewableDispatch`](@ref) `base_power`."""
set_base_power!(value::RenewableDispatch, val) = value.base_power = val
"""Set [`RenewableDispatch`](@ref) `services`."""
set_services!(value::RenewableDispatch, val) = value.services = val
"""Set [`RenewableDispatch`](@ref) `ext`."""
set_ext!(value::RenewableDispatch, val) = value.ext = val
