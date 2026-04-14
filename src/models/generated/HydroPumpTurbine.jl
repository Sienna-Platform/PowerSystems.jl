#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct HydroPumpTurbine <: HydroUnit
        name::String
        available::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        rating::Float64
        active_power_limits::MinMax
        reactive_power_limits::Union{Nothing, MinMax}
        active_power_limits_pump::MinMax
        outflow_limits::Union{Nothing, MinMax}
        powerhouse_elevation::Float64
        ramp_limits::Union{Nothing, UpDown}
        time_limits::Union{Nothing, UpDown}
        base_power::Float64
        status::PumpHydroStatus
        time_at_status::Float64
        operation_cost::OperationalCost
        active_power_pump::Float64
        efficiency::TurbinePump
        transition_time::TurbinePump
        minimum_time::TurbinePump
        travel_time::Union{Nothing, Float64}
        conversion_factor::Float64
        must_run::Bool
        prime_mover_type::PrimeMovers
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A hydropower pumped turbine that needs to have two [`HydroReservoir`](@ref)s attached, suitable for modeling independent pumped hydro with reservoirs.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial active power set point of the turbine unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR), validation range: `reactive_power_limits`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power, validation range: `(0, nothing)`
- `active_power_limits::MinMax`: Minimum and maximum stable active power levels (MW) for the turbine, validation range: `(0, nothing)`
- `reactive_power_limits::Union{Nothing, MinMax}`: Minimum and maximum reactive power limits. Set to `Nothing` if not applicable
- `active_power_limits_pump::MinMax`: Minimum and maximum stable active power levels (MW) for the pump, validation range: `(0, nothing)`
- `outflow_limits::Union{Nothing, MinMax}`: Turbine/Pump outflow limits in m3/s. Set to `Nothing` if not applicable
- `powerhouse_elevation::Float64`: Height level in meters above the sea level of the powerhouse on which the turbine is installed., validation range: `(0, nothing)`
- `ramp_limits::Union{Nothing, UpDown}`: ramp up and ramp down limits in MW/min, validation range: `(0, nothing)`
- `time_limits::Union{Nothing, UpDown}`: Minimum up and Minimum down time limits in hours, validation range: `(0, nothing)`
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `status::PumpHydroStatus`: (default: `PumpHydroStatus.OFF`) Initial Operating status of a pumped‑storage hydro unit. See [PumpHydroStatus](@ref) for reference
- `time_at_status::Float64`: (default: `INFINITE_TIME`) Time (e.g., `Hours(6)`) the generator has been on or off, as indicated by `status`
- `operation_cost::OperationalCost`: (default: `HydroGenerationCost(nothing)`) [`OperationalCost`](@ref) of generation
- `active_power_pump::Float64`: (default: `0.0`) Initial active power set point of the pump unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `efficiency::TurbinePump`: (default: `(turbine = 1.0, pump = 1.0)`) Turbine/Pump efficiency [0, 1.0]
- `transition_time::TurbinePump`: (default: `(turbine = 0.0, pump = 0.0)`) Transition time in hours to switch into the specific mode.
- `minimum_time::TurbinePump`: (default: `(turbine = 0.0, pump = 0.0)`) Minimum operating time in hours for the specific mode.
- `travel_time::Union{Nothing, Float64}`: (default: `nothing`) Downstream (from reservoir into turbine) travel time in hours.
- `conversion_factor::Float64`: (default: `1.0`) Conversion factor from flow/volume to energy: m^3 -> p.u-hr
- `must_run::Bool`: (default: `false`) Whether the unit must run (i.e., cannot be curtailed)
- `prime_mover_type::PrimeMovers`: (default: `PrimeMovers.PS`) Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct HydroPumpTurbine <: HydroUnit
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Initial active power set point of the turbine unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used"
    active_power::Float64
    "Initial reactive power set point of the unit (MVAR)"
    reactive_power::Float64
    "Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power"
    rating::Float64
    "Minimum and maximum stable active power levels (MW) for the turbine"
    active_power_limits::MinMax
    "Minimum and maximum reactive power limits. Set to `Nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "Minimum and maximum stable active power levels (MW) for the pump"
    active_power_limits_pump::MinMax
    "Turbine/Pump outflow limits in m3/s. Set to `Nothing` if not applicable"
    outflow_limits::Union{Nothing, MinMax}
    "Height level in meters above the sea level of the powerhouse on which the turbine is installed."
    powerhouse_elevation::Float64
    "ramp up and ramp down limits in MW/min"
    ramp_limits::Union{Nothing, UpDown}
    "Minimum up and Minimum down time limits in hours"
    time_limits::Union{Nothing, UpDown}
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Initial Operating status of a pumped‑storage hydro unit. See [PumpHydroStatus](@ref) for reference"
    status::PumpHydroStatus
    "Time (e.g., `Hours(6)`) the generator has been on or off, as indicated by `status`"
    time_at_status::Float64
    "[`OperationalCost`](@ref) of generation"
    operation_cost::OperationalCost
    "Initial active power set point of the pump unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used"
    active_power_pump::Float64
    "Turbine/Pump efficiency [0, 1.0]"
    efficiency::TurbinePump
    "Transition time in hours to switch into the specific mode."
    transition_time::TurbinePump
    "Minimum operating time in hours for the specific mode."
    minimum_time::TurbinePump
    "Downstream (from reservoir into turbine) travel time in hours."
    travel_time::Union{Nothing, Float64}
    "Conversion factor from flow/volume to energy: m^3 -> p.u-hr"
    conversion_factor::Float64
    "Whether the unit must run (i.e., cannot be curtailed)"
    must_run::Bool
    "Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)"
    prime_mover_type::PrimeMovers
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function HydroPumpTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, active_power_limits_pump, outflow_limits, powerhouse_elevation, ramp_limits, time_limits, base_power, status=PumpHydroStatus.OFF, time_at_status=INFINITE_TIME, operation_cost=HydroGenerationCost(nothing), active_power_pump=0.0, efficiency=(turbine = 1.0, pump = 1.0), transition_time=(turbine = 0.0, pump = 0.0), minimum_time=(turbine = 0.0, pump = 0.0), travel_time=nothing, conversion_factor=1.0, must_run=false, prime_mover_type=PrimeMovers.PS, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    HydroPumpTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, active_power_limits_pump, outflow_limits, powerhouse_elevation, ramp_limits, time_limits, base_power, status, time_at_status, operation_cost, active_power_pump, efficiency, transition_time, minimum_time, travel_time, conversion_factor, must_run, prime_mover_type, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function HydroPumpTurbine(; name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, active_power_limits_pump, outflow_limits, powerhouse_elevation, ramp_limits, time_limits, base_power, status=PumpHydroStatus.OFF, time_at_status=INFINITE_TIME, operation_cost=HydroGenerationCost(nothing), active_power_pump=0.0, efficiency=(turbine = 1.0, pump = 1.0), transition_time=(turbine = 0.0, pump = 0.0), minimum_time=(turbine = 0.0, pump = 0.0), travel_time=nothing, conversion_factor=1.0, must_run=false, prime_mover_type=PrimeMovers.PS, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    HydroPumpTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, active_power_limits_pump, outflow_limits, powerhouse_elevation, ramp_limits, time_limits, base_power, status, time_at_status, operation_cost, active_power_pump, efficiency, transition_time, minimum_time, travel_time, conversion_factor, must_run, prime_mover_type, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function HydroPumpTurbine(::Nothing)
    HydroPumpTurbine(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        rating=0.0,
        active_power_limits=(min=0.0, max=0.0),
        reactive_power_limits=nothing,
        active_power_limits_pump=(min=0.0, max=0.0),
        outflow_limits=nothing,
        powerhouse_elevation=0.0,
        ramp_limits=nothing,
        time_limits=nothing,
        base_power=100.0,
        status=PumpHydroStatus.OFF,
        time_at_status=INFINITE_TIME,
        operation_cost=HydroGenerationCost(nothing),
        active_power_pump=0.0,
        efficiency=(turbine = 1.0, pump = 1.0),
        transition_time=(turbine = 0.0, pump = 0.0),
        minimum_time=(turbine = 0.0, pump = 0.0),
        travel_time=nothing,
        conversion_factor=1.0,
        must_run=false,
        prime_mover_type=PrimeMovers.OT,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`HydroPumpTurbine`](@ref) `name`."""
get_name(value::HydroPumpTurbine) = value.name
"""Get [`HydroPumpTurbine`](@ref) `available`."""
get_available(value::HydroPumpTurbine) = value.available
"""Get [`HydroPumpTurbine`](@ref) `bus`."""
get_bus(value::HydroPumpTurbine) = value.bus
"""Get [`HydroPumpTurbine`](@ref) `active_power`."""
get_active_power(value::HydroPumpTurbine) = get_value(value, Val(:active_power), Val(:mva))
"""Get [`HydroPumpTurbine`](@ref) `reactive_power`."""
get_reactive_power(value::HydroPumpTurbine) = get_value(value, Val(:reactive_power), Val(:mva))
"""Get [`HydroPumpTurbine`](@ref) `rating`."""
get_rating(value::HydroPumpTurbine) = get_value(value, Val(:rating), Val(:mva))
"""Get [`HydroPumpTurbine`](@ref) `active_power_limits`."""
get_active_power_limits(value::HydroPumpTurbine) = get_value(value, Val(:active_power_limits), Val(:mva))
"""Get [`HydroPumpTurbine`](@ref) `reactive_power_limits`."""
get_reactive_power_limits(value::HydroPumpTurbine) = get_value(value, Val(:reactive_power_limits), Val(:mva))
"""Get [`HydroPumpTurbine`](@ref) `active_power_limits_pump`."""
get_active_power_limits_pump(value::HydroPumpTurbine) = get_value(value, Val(:active_power_limits_pump), Val(:mva))
"""Get [`HydroPumpTurbine`](@ref) `outflow_limits`."""
get_outflow_limits(value::HydroPumpTurbine) = value.outflow_limits
"""Get [`HydroPumpTurbine`](@ref) `powerhouse_elevation`."""
get_powerhouse_elevation(value::HydroPumpTurbine) = value.powerhouse_elevation
"""Get [`HydroPumpTurbine`](@ref) `ramp_limits`."""
get_ramp_limits(value::HydroPumpTurbine) = get_value(value, Val(:ramp_limits), Val(:mva))
"""Get [`HydroPumpTurbine`](@ref) `time_limits`."""
get_time_limits(value::HydroPumpTurbine) = value.time_limits
"""Get [`HydroPumpTurbine`](@ref) `base_power`."""
get_base_power(value::HydroPumpTurbine) = value.base_power
"""Get [`HydroPumpTurbine`](@ref) `status`."""
get_status(value::HydroPumpTurbine) = value.status
"""Get [`HydroPumpTurbine`](@ref) `time_at_status`."""
get_time_at_status(value::HydroPumpTurbine) = value.time_at_status
"""Get [`HydroPumpTurbine`](@ref) `operation_cost`."""
get_operation_cost(value::HydroPumpTurbine) = value.operation_cost
"""Get [`HydroPumpTurbine`](@ref) `active_power_pump`."""
get_active_power_pump(value::HydroPumpTurbine) = get_value(value, Val(:active_power_pump), Val(:mva))
"""Get [`HydroPumpTurbine`](@ref) `efficiency`."""
get_efficiency(value::HydroPumpTurbine) = value.efficiency
"""Get [`HydroPumpTurbine`](@ref) `transition_time`."""
get_transition_time(value::HydroPumpTurbine) = value.transition_time
"""Get [`HydroPumpTurbine`](@ref) `minimum_time`."""
get_minimum_time(value::HydroPumpTurbine) = value.minimum_time
"""Get [`HydroPumpTurbine`](@ref) `travel_time`."""
get_travel_time(value::HydroPumpTurbine) = value.travel_time
"""Get [`HydroPumpTurbine`](@ref) `conversion_factor`."""
get_conversion_factor(value::HydroPumpTurbine) = value.conversion_factor
"""Get [`HydroPumpTurbine`](@ref) `must_run`."""
get_must_run(value::HydroPumpTurbine) = value.must_run
"""Get [`HydroPumpTurbine`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::HydroPumpTurbine) = value.prime_mover_type
"""Get [`HydroPumpTurbine`](@ref) `services`."""
get_services(value::HydroPumpTurbine) = value.services
"""Get [`HydroPumpTurbine`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::HydroPumpTurbine) = value.dynamic_injector
"""Get [`HydroPumpTurbine`](@ref) `ext`."""
get_ext(value::HydroPumpTurbine) = value.ext
"""Get [`HydroPumpTurbine`](@ref) `internal`."""
get_internal(value::HydroPumpTurbine) = value.internal

"""Set [`HydroPumpTurbine`](@ref) `available`."""
set_available!(value::HydroPumpTurbine, val) = value.available = val
"""Set [`HydroPumpTurbine`](@ref) `bus`."""
set_bus!(value::HydroPumpTurbine, val) = value.bus = val
"""Set [`HydroPumpTurbine`](@ref) `active_power`."""
set_active_power!(value::HydroPumpTurbine, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`HydroPumpTurbine`](@ref) `reactive_power`."""
set_reactive_power!(value::HydroPumpTurbine, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mva))
"""Set [`HydroPumpTurbine`](@ref) `rating`."""
set_rating!(value::HydroPumpTurbine, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`HydroPumpTurbine`](@ref) `active_power_limits`."""
set_active_power_limits!(value::HydroPumpTurbine, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mva))
"""Set [`HydroPumpTurbine`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::HydroPumpTurbine, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mva))
"""Set [`HydroPumpTurbine`](@ref) `active_power_limits_pump`."""
set_active_power_limits_pump!(value::HydroPumpTurbine, val) = value.active_power_limits_pump = set_value(value, Val(:active_power_limits_pump), val, Val(:mva))
"""Set [`HydroPumpTurbine`](@ref) `outflow_limits`."""
set_outflow_limits!(value::HydroPumpTurbine, val) = value.outflow_limits = val
"""Set [`HydroPumpTurbine`](@ref) `powerhouse_elevation`."""
set_powerhouse_elevation!(value::HydroPumpTurbine, val) = value.powerhouse_elevation = val
"""Set [`HydroPumpTurbine`](@ref) `ramp_limits`."""
set_ramp_limits!(value::HydroPumpTurbine, val) = value.ramp_limits = set_value(value, Val(:ramp_limits), val, Val(:mva))
"""Set [`HydroPumpTurbine`](@ref) `time_limits`."""
set_time_limits!(value::HydroPumpTurbine, val) = value.time_limits = val
"""Set [`HydroPumpTurbine`](@ref) `base_power`."""
set_base_power!(value::HydroPumpTurbine, val) = value.base_power = val
"""Set [`HydroPumpTurbine`](@ref) `status`."""
set_status!(value::HydroPumpTurbine, val) = value.status = val
"""Set [`HydroPumpTurbine`](@ref) `time_at_status`."""
set_time_at_status!(value::HydroPumpTurbine, val) = value.time_at_status = val
"""Set [`HydroPumpTurbine`](@ref) `operation_cost`."""
set_operation_cost!(value::HydroPumpTurbine, val) = value.operation_cost = val
"""Set [`HydroPumpTurbine`](@ref) `active_power_pump`."""
set_active_power_pump!(value::HydroPumpTurbine, val) = value.active_power_pump = set_value(value, Val(:active_power_pump), val, Val(:mva))
"""Set [`HydroPumpTurbine`](@ref) `efficiency`."""
set_efficiency!(value::HydroPumpTurbine, val) = value.efficiency = val
"""Set [`HydroPumpTurbine`](@ref) `transition_time`."""
set_transition_time!(value::HydroPumpTurbine, val) = value.transition_time = val
"""Set [`HydroPumpTurbine`](@ref) `minimum_time`."""
set_minimum_time!(value::HydroPumpTurbine, val) = value.minimum_time = val
"""Set [`HydroPumpTurbine`](@ref) `travel_time`."""
set_travel_time!(value::HydroPumpTurbine, val) = value.travel_time = val
"""Set [`HydroPumpTurbine`](@ref) `conversion_factor`."""
set_conversion_factor!(value::HydroPumpTurbine, val) = value.conversion_factor = val
"""Set [`HydroPumpTurbine`](@ref) `must_run`."""
set_must_run!(value::HydroPumpTurbine, val) = value.must_run = val
"""Set [`HydroPumpTurbine`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::HydroPumpTurbine, val) = value.prime_mover_type = val
"""Set [`HydroPumpTurbine`](@ref) `services`."""
set_services!(value::HydroPumpTurbine, val) = value.services = val
"""Set [`HydroPumpTurbine`](@ref) `ext`."""
set_ext!(value::HydroPumpTurbine, val) = value.ext = val
