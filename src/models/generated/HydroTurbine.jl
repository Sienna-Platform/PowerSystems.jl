#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct HydroTurbine <: HydroUnit
        name::String
        available::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        rating::Float64
        active_power_limits::MinMax
        reactive_power_limits::Union{Nothing, MinMax}
        base_power::Float64
        operation_cost::Union{HydroGenerationCost, MarketBidCost}
        powerhouse_elevation::Float64
        ramp_limits::Union{Nothing, UpDown}
        time_limits::Union{Nothing, UpDown}
        outflow_limits::Union{Nothing, MinMax}
        efficiency::Float64
        turbine_type::HydroTurbineType
        conversion_factor::Float64
        prime_mover_type::PrimeMovers
        travel_time::Union{Nothing, Float64}
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A hydropower generator that must have a [`HydroReservoir`](@ref) attached, suitable for modeling independent turbines and reservoirs.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR), validation range: `reactive_power_limits`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power, validation range: `(0, nothing)`
- `active_power_limits::MinMax`: Minimum and maximum stable active power levels (MW), validation range: `(0, nothing)`
- `reactive_power_limits::Union{Nothing, MinMax}`: Minimum and maximum reactive power limits. Set to `Nothing` if not applicable
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `operation_cost::Union{HydroGenerationCost, MarketBidCost}`: (default: `HydroGenerationCost(nothing)`) [`OperationalCost`](@ref) of generation
- `powerhouse_elevation::Float64`: (default: `0.0`) Height level in meters above the sea level of the powerhouse on which the turbine is installed., validation range: `(0, nothing)`
- `ramp_limits::Union{Nothing, UpDown}`: (default: `nothing`) ramp up and ramp down limits in MW/min, validation range: `(0, nothing)`
- `time_limits::Union{Nothing, UpDown}`: (default: `nothing`) Minimum up and Minimum down time limits in hours, validation range: `(0, nothing)`
- `outflow_limits::Union{Nothing, MinMax}`: (default: `nothing`) Turbine outflow limits in m3/s. Set to `Nothing` if not applicable
- `efficiency::Float64`: (default: `1.0`) Turbine efficiency [0, 1.0], validation range: `(0, 1)`
- `turbine_type::HydroTurbineType`: (default: `HydroTurbineType.UNKNOWN`) Type of the turbine
- `conversion_factor::Float64`: (default: `1.0`) Conversion factor from flow/volume to energy: m^3 -> p.u-hr
- `prime_mover_type::PrimeMovers`: (default: `PrimeMovers.HY`) Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
- `travel_time::Union{Nothing, Float64}`: (default: `nothing`) Downstream (from reservoir into turbine) travel time in hours.
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct HydroTurbine <: HydroUnit
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used"
    active_power::Float64
    "Initial reactive power set point of the unit (MVAR)"
    reactive_power::Float64
    "Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power"
    rating::Float64
    "Minimum and maximum stable active power levels (MW)"
    active_power_limits::MinMax
    "Minimum and maximum reactive power limits. Set to `Nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "[`OperationalCost`](@ref) of generation"
    operation_cost::Union{HydroGenerationCost, MarketBidCost}
    "Height level in meters above the sea level of the powerhouse on which the turbine is installed."
    powerhouse_elevation::Float64
    "ramp up and ramp down limits in MW/min"
    ramp_limits::Union{Nothing, UpDown}
    "Minimum up and Minimum down time limits in hours"
    time_limits::Union{Nothing, UpDown}
    "Turbine outflow limits in m3/s. Set to `Nothing` if not applicable"
    outflow_limits::Union{Nothing, MinMax}
    "Turbine efficiency [0, 1.0]"
    efficiency::Float64
    "Type of the turbine"
    turbine_type::HydroTurbineType
    "Conversion factor from flow/volume to energy: m^3 -> p.u-hr"
    conversion_factor::Float64
    "Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)"
    prime_mover_type::PrimeMovers
    "Downstream (from reservoir into turbine) travel time in hours."
    travel_time::Union{Nothing, Float64}
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function HydroTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, base_power, operation_cost=HydroGenerationCost(nothing), powerhouse_elevation=0.0, ramp_limits=nothing, time_limits=nothing, outflow_limits=nothing, efficiency=1.0, turbine_type=HydroTurbineType.UNKNOWN, conversion_factor=1.0, prime_mover_type=PrimeMovers.HY, travel_time=nothing, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    HydroTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, base_power, operation_cost, powerhouse_elevation, ramp_limits, time_limits, outflow_limits, efficiency, turbine_type, conversion_factor, prime_mover_type, travel_time, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function HydroTurbine(; name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, base_power, operation_cost=HydroGenerationCost(nothing), powerhouse_elevation=0.0, ramp_limits=nothing, time_limits=nothing, outflow_limits=nothing, efficiency=1.0, turbine_type=HydroTurbineType.UNKNOWN, conversion_factor=1.0, prime_mover_type=PrimeMovers.HY, travel_time=nothing, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    HydroTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, base_power, operation_cost, powerhouse_elevation, ramp_limits, time_limits, outflow_limits, efficiency, turbine_type, conversion_factor, prime_mover_type, travel_time, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function HydroTurbine(::Nothing)
    HydroTurbine(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        rating=0.0,
        active_power_limits=(min=0.0, max=0.0),
        reactive_power_limits=nothing,
        base_power=100.0,
        operation_cost=HydroGenerationCost(nothing),
        powerhouse_elevation=0.0,
        ramp_limits=nothing,
        time_limits=nothing,
        outflow_limits=nothing,
        efficiency=1.0,
        turbine_type=HydroTurbineType.UNKNOWN,
        conversion_factor=1.0,
        prime_mover_type=PrimeMovers.OT,
        travel_time=nothing,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`HydroTurbine`](@ref) `name`."""
get_name(value::HydroTurbine) = value.name
"""Get [`HydroTurbine`](@ref) `available`."""
get_available(value::HydroTurbine) = value.available
"""Get [`HydroTurbine`](@ref) `bus`."""
get_bus(value::HydroTurbine) = value.bus
"""Get [`HydroTurbine`](@ref) `active_power`. Returns value in the system's unit setting (natural units by default)."""
get_active_power(value::HydroTurbine) = get_value(value, Val(:active_power), Val(:mva), _get_system_units(value, Val(:mva)))
get_active_power(value::HydroTurbine, units) = get_value(value, Val(:active_power), Val(:mva), units)
"""Get [`HydroTurbine`](@ref) `reactive_power`. Returns value in the system's unit setting (natural units by default)."""
get_reactive_power(value::HydroTurbine) = get_value(value, Val(:reactive_power), Val(:mva), _get_system_units(value, Val(:mva)))
get_reactive_power(value::HydroTurbine, units) = get_value(value, Val(:reactive_power), Val(:mva), units)
"""Get [`HydroTurbine`](@ref) `rating`. Returns value in the system's unit setting (natural units by default)."""
get_rating(value::HydroTurbine) = get_value(value, Val(:rating), Val(:mva), _get_system_units(value, Val(:mva)))
get_rating(value::HydroTurbine, units) = get_value(value, Val(:rating), Val(:mva), units)
"""Get [`HydroTurbine`](@ref) `active_power_limits`. Returns value in the system's unit setting (natural units by default)."""
get_active_power_limits(value::HydroTurbine) = get_value(value, Val(:active_power_limits), Val(:mva), _get_system_units(value, Val(:mva)))
get_active_power_limits(value::HydroTurbine, units) = get_value(value, Val(:active_power_limits), Val(:mva), units)
"""Get [`HydroTurbine`](@ref) `reactive_power_limits`. Returns value in the system's unit setting (natural units by default)."""
get_reactive_power_limits(value::HydroTurbine) = get_value(value, Val(:reactive_power_limits), Val(:mva), _get_system_units(value, Val(:mva)))
get_reactive_power_limits(value::HydroTurbine, units) = get_value(value, Val(:reactive_power_limits), Val(:mva), units)

_get_base_power(value::HydroTurbine) = value.base_power
"""Get [`HydroTurbine`](@ref) `operation_cost`."""
get_operation_cost(value::HydroTurbine) = value.operation_cost
"""Get [`HydroTurbine`](@ref) `powerhouse_elevation`."""
get_powerhouse_elevation(value::HydroTurbine) = value.powerhouse_elevation
"""Get [`HydroTurbine`](@ref) `ramp_limits`. Returns value in the system's unit setting (natural units by default)."""
get_ramp_limits(value::HydroTurbine) = get_value(value, Val(:ramp_limits), Val(:mva), _get_system_units(value, Val(:mva)))
get_ramp_limits(value::HydroTurbine, units) = get_value(value, Val(:ramp_limits), Val(:mva), units)
"""Get [`HydroTurbine`](@ref) `time_limits`."""
get_time_limits(value::HydroTurbine) = value.time_limits
"""Get [`HydroTurbine`](@ref) `outflow_limits`."""
get_outflow_limits(value::HydroTurbine) = value.outflow_limits
"""Get [`HydroTurbine`](@ref) `efficiency`."""
get_efficiency(value::HydroTurbine) = value.efficiency
"""Get [`HydroTurbine`](@ref) `turbine_type`."""
get_turbine_type(value::HydroTurbine) = value.turbine_type
"""Get [`HydroTurbine`](@ref) `conversion_factor`."""
get_conversion_factor(value::HydroTurbine) = value.conversion_factor
"""Get [`HydroTurbine`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::HydroTurbine) = value.prime_mover_type
"""Get [`HydroTurbine`](@ref) `travel_time`."""
get_travel_time(value::HydroTurbine) = value.travel_time
"""Get [`HydroTurbine`](@ref) `services`."""
get_services(value::HydroTurbine) = value.services
"""Get [`HydroTurbine`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::HydroTurbine) = value.dynamic_injector
"""Get [`HydroTurbine`](@ref) `ext`."""
get_ext(value::HydroTurbine) = value.ext
"""Get [`HydroTurbine`](@ref) `internal`."""
get_internal(value::HydroTurbine) = value.internal

"""Set [`HydroTurbine`](@ref) `available`."""
set_available!(value::HydroTurbine, val) = value.available = val
"""Set [`HydroTurbine`](@ref) `bus`."""
set_bus!(value::HydroTurbine, val) = value.bus = val
"""Set [`HydroTurbine`](@ref) `active_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power!(value::HydroTurbine, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`HydroTurbine`](@ref) `reactive_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power!(value::HydroTurbine, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mva))
"""Set [`HydroTurbine`](@ref) `rating`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating!(value::HydroTurbine, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`HydroTurbine`](@ref) `active_power_limits`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_limits!(value::HydroTurbine, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mva))
"""Set [`HydroTurbine`](@ref) `reactive_power_limits`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power_limits!(value::HydroTurbine, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mva))
"""Set [`HydroTurbine`](@ref) `operation_cost`."""
set_operation_cost!(value::HydroTurbine, val) = value.operation_cost = val
"""Set [`HydroTurbine`](@ref) `powerhouse_elevation`."""
set_powerhouse_elevation!(value::HydroTurbine, val) = value.powerhouse_elevation = val
"""Set [`HydroTurbine`](@ref) `ramp_limits`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_ramp_limits!(value::HydroTurbine, val) = value.ramp_limits = set_value(value, Val(:ramp_limits), val, Val(:mva))
"""Set [`HydroTurbine`](@ref) `time_limits`."""
set_time_limits!(value::HydroTurbine, val) = value.time_limits = val
"""Set [`HydroTurbine`](@ref) `outflow_limits`."""
set_outflow_limits!(value::HydroTurbine, val) = value.outflow_limits = val
"""Set [`HydroTurbine`](@ref) `efficiency`."""
set_efficiency!(value::HydroTurbine, val) = value.efficiency = val
"""Set [`HydroTurbine`](@ref) `turbine_type`."""
set_turbine_type!(value::HydroTurbine, val) = value.turbine_type = val
"""Set [`HydroTurbine`](@ref) `conversion_factor`."""
set_conversion_factor!(value::HydroTurbine, val) = value.conversion_factor = val
"""Set [`HydroTurbine`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::HydroTurbine, val) = value.prime_mover_type = val
"""Set [`HydroTurbine`](@ref) `travel_time`."""
set_travel_time!(value::HydroTurbine, val) = value.travel_time = val
"""Set [`HydroTurbine`](@ref) `services`."""
set_services!(value::HydroTurbine, val) = value.services = val
"""Set [`HydroTurbine`](@ref) `ext`."""
set_ext!(value::HydroTurbine, val) = value.ext = val
