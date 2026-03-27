#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ThermalMultiStart <: ThermalGen
        name::String
        available::Bool
        status::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        rating::Float64
        prime_mover_type::PrimeMovers
        fuel::ThermalFuels
        active_power_limits::MinMax
        reactive_power_limits::Union{Nothing, MinMax}
        ramp_limits::Union{Nothing, UpDown}
        power_trajectory::Union{Nothing, StartUpShutDown}
        time_limits::Union{Nothing, UpDown}
        start_time_limits::Union{Nothing, StartUpStages}
        start_types::Int
        operation_cost::Union{ThermalGenerationCost, MarketBidCost}
        base_power::Float64
        services::Vector{Service}
        time_at_status::Float64
        must_run::Bool
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A thermal generator, such as a fossil fuel or nuclear generator, that can start-up again from a *hot*, *warm*, or *cold* state.

`ThermalMultiStart` has a detailed representation of the start-up process based on the time elapsed since the last shut down, as well as a detailed shut-down process. The model is based on ["Tight and Compact MILP Formulation for the Thermal Unit Commitment Problem."](https://doi.org/10.1109/TPWRS.2013.2251373). For a simplified representation of the start-up and shut-down processes, see [`ThermalStandard`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `status::Bool`: Initial commitment condition at the start of a simulation (`true` = on or `false` = off)
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used, validation range: `active_power_limits`
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR), validation range: `reactive_power_limits`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power, validation range: `(0, nothing)`
- `prime_mover_type::PrimeMovers`: Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
- `fuel::ThermalFuels`: Prime mover fuel according to EIA 923. Options are listed [here](@ref tf_list)
- `active_power_limits::MinMax`: Minimum and maximum stable active power levels (MW)
- `reactive_power_limits::Union{Nothing, MinMax}`: Minimum and maximum reactive power limits. Set to `Nothing` if not applicable
- `ramp_limits::Union{Nothing, UpDown}`:, validation range: `(0, nothing)`
- `power_trajectory::Union{Nothing, StartUpShutDown}`: Power trajectory the unit will take during the start-up and shut-down ramp process, validation range: `(0, nothing)`
- `time_limits::Union{Nothing, UpDown}`: Minimum up and Minimum down time limits in hours, validation range: `(0, nothing)`
- `start_time_limits::Union{Nothing, StartUpStages}`: Time limits for start-up based on turbine temperature in hours
- `start_types::Int`: Number of start-up based on turbine temperature, where `1` = *hot*, `2` = *warm*, and `3` = *cold*, validation range: `(1, 3)`
- `operation_cost::Union{ThermalGenerationCost, MarketBidCost}`: [`OperationalCost`](@ref) of generation
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `time_at_status::Float64`: (default: `INFINITE_TIME`) Time (e.g., `Hours(6)`) the generator has been on or off, as indicated by `status`
- `must_run::Bool`: (default: `false`) Set to `true` if the unit is must run
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ThermalMultiStart <: ThermalGen
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Initial commitment condition at the start of a simulation (`true` = on or `false` = off)"
    status::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used"
    active_power::Float64
    "Initial reactive power set point of the unit (MVAR)"
    reactive_power::Float64
    "Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power"
    rating::Float64
    "Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)"
    prime_mover_type::PrimeMovers
    "Prime mover fuel according to EIA 923. Options are listed [here](@ref tf_list)"
    fuel::ThermalFuels
    "Minimum and maximum stable active power levels (MW)"
    active_power_limits::MinMax
    "Minimum and maximum reactive power limits. Set to `Nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    ramp_limits::Union{Nothing, UpDown}
    "Power trajectory the unit will take during the start-up and shut-down ramp process"
    power_trajectory::Union{Nothing, StartUpShutDown}
    "Minimum up and Minimum down time limits in hours"
    time_limits::Union{Nothing, UpDown}
    "Time limits for start-up based on turbine temperature in hours"
    start_time_limits::Union{Nothing, StartUpStages}
    "Number of start-up based on turbine temperature, where `1` = *hot*, `2` = *warm*, and `3` = *cold*"
    start_types::Int
    "[`OperationalCost`](@ref) of generation"
    operation_cost::Union{ThermalGenerationCost, MarketBidCost}
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Services that this device contributes to"
    services::Vector{Service}
    "Time (e.g., `Hours(6)`) the generator has been on or off, as indicated by `status`"
    time_at_status::Float64
    "Set to `true` if the unit is must run"
    must_run::Bool
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ThermalMultiStart(name, available, status, bus, active_power, reactive_power, rating, prime_mover_type, fuel, active_power_limits, reactive_power_limits, ramp_limits, power_trajectory, time_limits, start_time_limits, start_types, operation_cost, base_power, services=Device[], time_at_status=INFINITE_TIME, must_run=false, dynamic_injector=nothing, ext=Dict{String, Any}(), )
    ThermalMultiStart(name, available, status, bus, active_power, reactive_power, rating, prime_mover_type, fuel, active_power_limits, reactive_power_limits, ramp_limits, power_trajectory, time_limits, start_time_limits, start_types, operation_cost, base_power, services, time_at_status, must_run, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function ThermalMultiStart(; name, available, status, bus, active_power, reactive_power, rating, prime_mover_type, fuel, active_power_limits, reactive_power_limits, ramp_limits, power_trajectory, time_limits, start_time_limits, start_types, operation_cost, base_power, services=Device[], time_at_status=INFINITE_TIME, must_run=false, dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    ThermalMultiStart(name, available, status, bus, active_power, reactive_power, rating, prime_mover_type, fuel, active_power_limits, reactive_power_limits, ramp_limits, power_trajectory, time_limits, start_time_limits, start_types, operation_cost, base_power, services, time_at_status, must_run, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function ThermalMultiStart(::Nothing)
    ThermalMultiStart(;
        name="init",
        available=false,
        status=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        rating=0.0,
        prime_mover_type=PrimeMovers.OT,
        fuel=ThermalFuels.OTHER,
        active_power_limits=(min=0.0, max=0.0),
        reactive_power_limits=nothing,
        ramp_limits=nothing,
        power_trajectory=nothing,
        time_limits=nothing,
        start_time_limits=nothing,
        start_types=1,
        operation_cost=ThermalGenerationCost(nothing),
        base_power=100.0,
        services=Device[],
        time_at_status=INFINITE_TIME,
        must_run=false,
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ThermalMultiStart`](@ref) `name`."""
get_name(value::ThermalMultiStart) = value.name
"""Get [`ThermalMultiStart`](@ref) `available`."""
get_available(value::ThermalMultiStart) = value.available
"""Get [`ThermalMultiStart`](@ref) `status`."""
get_status(value::ThermalMultiStart) = value.status
"""Get [`ThermalMultiStart`](@ref) `bus`."""
get_bus(value::ThermalMultiStart) = value.bus
"""Get [`ThermalMultiStart`](@ref) `active_power`. Returns value in the system's unit setting (natural units by default)."""
get_active_power(value::ThermalMultiStart) = get_value(value, Val(:active_power), Val(:mva), _get_system_units(value, Val(:mva)))
get_active_power(value::ThermalMultiStart, units) = get_value(value, Val(:active_power), Val(:mva), units)
"""Get [`ThermalMultiStart`](@ref) `reactive_power`. Returns value in the system's unit setting (natural units by default)."""
get_reactive_power(value::ThermalMultiStart) = get_value(value, Val(:reactive_power), Val(:mva), _get_system_units(value, Val(:mva)))
get_reactive_power(value::ThermalMultiStart, units) = get_value(value, Val(:reactive_power), Val(:mva), units)
"""Get [`ThermalMultiStart`](@ref) `rating`. Returns value in the system's unit setting (natural units by default)."""
get_rating(value::ThermalMultiStart) = get_value(value, Val(:rating), Val(:mva), _get_system_units(value, Val(:mva)))
get_rating(value::ThermalMultiStart, units) = get_value(value, Val(:rating), Val(:mva), units)
"""Get [`ThermalMultiStart`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::ThermalMultiStart) = value.prime_mover_type
"""Get [`ThermalMultiStart`](@ref) `fuel`."""
get_fuel(value::ThermalMultiStart) = value.fuel
"""Get [`ThermalMultiStart`](@ref) `active_power_limits`. Returns value in the system's unit setting (natural units by default)."""
get_active_power_limits(value::ThermalMultiStart) = get_value(value, Val(:active_power_limits), Val(:mva), _get_system_units(value, Val(:mva)))
get_active_power_limits(value::ThermalMultiStart, units) = get_value(value, Val(:active_power_limits), Val(:mva), units)
"""Get [`ThermalMultiStart`](@ref) `reactive_power_limits`. Returns value in the system's unit setting (natural units by default)."""
get_reactive_power_limits(value::ThermalMultiStart) = get_value(value, Val(:reactive_power_limits), Val(:mva), _get_system_units(value, Val(:mva)))
get_reactive_power_limits(value::ThermalMultiStart, units) = get_value(value, Val(:reactive_power_limits), Val(:mva), units)
"""Get [`ThermalMultiStart`](@ref) `ramp_limits`. Returns value in the system's unit setting (natural units by default)."""
get_ramp_limits(value::ThermalMultiStart) = get_value(value, Val(:ramp_limits), Val(:mva), _get_system_units(value, Val(:mva)))
get_ramp_limits(value::ThermalMultiStart, units) = get_value(value, Val(:ramp_limits), Val(:mva), units)
"""Get [`ThermalMultiStart`](@ref) `power_trajectory`. Returns value in the system's unit setting (natural units by default)."""
get_power_trajectory(value::ThermalMultiStart) = get_value(value, Val(:power_trajectory), Val(:mva), _get_system_units(value, Val(:mva)))
get_power_trajectory(value::ThermalMultiStart, units) = get_value(value, Val(:power_trajectory), Val(:mva), units)
"""Get [`ThermalMultiStart`](@ref) `time_limits`."""
get_time_limits(value::ThermalMultiStart) = value.time_limits
"""Get [`ThermalMultiStart`](@ref) `start_time_limits`."""
get_start_time_limits(value::ThermalMultiStart) = value.start_time_limits
"""Get [`ThermalMultiStart`](@ref) `start_types`."""
get_start_types(value::ThermalMultiStart) = value.start_types
"""Get [`ThermalMultiStart`](@ref) `operation_cost`."""
get_operation_cost(value::ThermalMultiStart) = value.operation_cost

_get_base_power(value::ThermalMultiStart) = value.base_power
"""Get [`ThermalMultiStart`](@ref) `services`."""
get_services(value::ThermalMultiStart) = value.services
"""Get [`ThermalMultiStart`](@ref) `time_at_status`."""
get_time_at_status(value::ThermalMultiStart) = value.time_at_status
"""Get [`ThermalMultiStart`](@ref) `must_run`."""
get_must_run(value::ThermalMultiStart) = value.must_run
"""Get [`ThermalMultiStart`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::ThermalMultiStart) = value.dynamic_injector
"""Get [`ThermalMultiStart`](@ref) `ext`."""
get_ext(value::ThermalMultiStart) = value.ext
"""Get [`ThermalMultiStart`](@ref) `internal`."""
get_internal(value::ThermalMultiStart) = value.internal

"""Set [`ThermalMultiStart`](@ref) `available`."""
set_available!(value::ThermalMultiStart, val) = value.available = val
"""Set [`ThermalMultiStart`](@ref) `status`."""
set_status!(value::ThermalMultiStart, val) = value.status = val
"""Set [`ThermalMultiStart`](@ref) `bus`."""
set_bus!(value::ThermalMultiStart, val) = value.bus = val
"""Set [`ThermalMultiStart`](@ref) `active_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power!(value::ThermalMultiStart, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`ThermalMultiStart`](@ref) `reactive_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power!(value::ThermalMultiStart, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mva))
"""Set [`ThermalMultiStart`](@ref) `rating`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating!(value::ThermalMultiStart, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`ThermalMultiStart`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::ThermalMultiStart, val) = value.prime_mover_type = val
"""Set [`ThermalMultiStart`](@ref) `fuel`."""
set_fuel!(value::ThermalMultiStart, val) = value.fuel = val
"""Set [`ThermalMultiStart`](@ref) `active_power_limits`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_limits!(value::ThermalMultiStart, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mva))
"""Set [`ThermalMultiStart`](@ref) `reactive_power_limits`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power_limits!(value::ThermalMultiStart, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mva))
"""Set [`ThermalMultiStart`](@ref) `ramp_limits`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_ramp_limits!(value::ThermalMultiStart, val) = value.ramp_limits = set_value(value, Val(:ramp_limits), val, Val(:mva))
"""Set [`ThermalMultiStart`](@ref) `power_trajectory`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_power_trajectory!(value::ThermalMultiStart, val) = value.power_trajectory = set_value(value, Val(:power_trajectory), val, Val(:mva))
"""Set [`ThermalMultiStart`](@ref) `time_limits`."""
set_time_limits!(value::ThermalMultiStart, val) = value.time_limits = val
"""Set [`ThermalMultiStart`](@ref) `start_time_limits`."""
set_start_time_limits!(value::ThermalMultiStart, val) = value.start_time_limits = val
"""Set [`ThermalMultiStart`](@ref) `start_types`."""
set_start_types!(value::ThermalMultiStart, val) = value.start_types = val
"""Set [`ThermalMultiStart`](@ref) `operation_cost`."""
set_operation_cost!(value::ThermalMultiStart, val) = value.operation_cost = val
"""Set [`ThermalMultiStart`](@ref) `services`."""
set_services!(value::ThermalMultiStart, val) = value.services = val
"""Set [`ThermalMultiStart`](@ref) `time_at_status`."""
set_time_at_status!(value::ThermalMultiStart, val) = value.time_at_status = val
"""Set [`ThermalMultiStart`](@ref) `must_run`."""
set_must_run!(value::ThermalMultiStart, val) = value.must_run = val
"""Set [`ThermalMultiStart`](@ref) `ext`."""
set_ext!(value::ThermalMultiStart, val) = value.ext = val
