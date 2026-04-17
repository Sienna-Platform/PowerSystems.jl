#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ThermalStandard <: ThermalGen
        name::String
        available::Bool
        status::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        rating::Float64
        active_power_limits::MinMax
        reactive_power_limits::Union{Nothing, MinMax}
        ramp_limits::Union{Nothing, UpDown}
        operation_cost::OperationalCost
        base_power::Float64
        time_limits::Union{Nothing, UpDown}
        must_run::Bool
        prime_mover_type::PrimeMovers
        fuel::ThermalFuels
        services::Vector{Service}
        time_at_status::Float64
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A thermal generator, such as a fossil fuel and nuclear generator.

This is a standard representation with options to include a minimum up time, minimum down time, and ramp limits. For a more detailed representation the start-up and shut-down processes, including hot starts, see [`ThermalMultiStart`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `status::Bool`: Initial commitment condition at the start of a simulation (`true` = on or `false` = off)
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used, validation range: `active_power_limits`
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR), validation range: `reactive_power_limits`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power, validation range: `(0, nothing)`
- `active_power_limits::MinMax`: Minimum and maximum stable active power levels (MW), validation range: `(0, nothing)`
- `reactive_power_limits::Union{Nothing, MinMax}`: Minimum and maximum reactive power limits. Set to `Nothing` if not applicable
- `ramp_limits::Union{Nothing, UpDown}`: ramp up and ramp down limits in MW/min, validation range: `(0, nothing)`
- `operation_cost::OperationalCost`: [`OperationalCost`](@ref) of generation
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `time_limits::Union{Nothing, UpDown}`: (default: `nothing`) Minimum up and Minimum down time limits in hours, validation range: `(0, nothing)`
- `must_run::Bool`: (default: `false`) Set to `true` if the unit is must run
- `prime_mover_type::PrimeMovers`: (default: `PrimeMovers.OT`) Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
- `fuel::ThermalFuels`: (default: `ThermalFuels.OTHER`) Prime mover fuel according to EIA 923. Options are listed [here](@ref tf_list)
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `time_at_status::Float64`: (default: `INFINITE_TIME`) Time (e.g., `Hours(6)`) the generator has been on or off, as indicated by `status`
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ThermalStandard <: ThermalGen
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
    "Minimum and maximum stable active power levels (MW)"
    active_power_limits::MinMax
    "Minimum and maximum reactive power limits. Set to `Nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "ramp up and ramp down limits in MW/min"
    ramp_limits::Union{Nothing, UpDown}
    "[`OperationalCost`](@ref) of generation"
    operation_cost::OperationalCost
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Minimum up and Minimum down time limits in hours"
    time_limits::Union{Nothing, UpDown}
    "Set to `true` if the unit is must run"
    must_run::Bool
    "Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)"
    prime_mover_type::PrimeMovers
    "Prime mover fuel according to EIA 923. Options are listed [here](@ref tf_list)"
    fuel::ThermalFuels
    "Services that this device contributes to"
    services::Vector{Service}
    "Time (e.g., `Hours(6)`) the generator has been on or off, as indicated by `status`"
    time_at_status::Float64
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ThermalStandard(name, available, status, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, ramp_limits, operation_cost, base_power, time_limits=nothing, must_run=false, prime_mover_type=PrimeMovers.OT, fuel=ThermalFuels.OTHER, services=Device[], time_at_status=INFINITE_TIME, dynamic_injector=nothing, ext=Dict{String, Any}(), )
    ThermalStandard(name, available, status, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, ramp_limits, operation_cost, base_power, time_limits, must_run, prime_mover_type, fuel, services, time_at_status, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function ThermalStandard(; name, available, status, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, ramp_limits, operation_cost, base_power, time_limits=nothing, must_run=false, prime_mover_type=PrimeMovers.OT, fuel=ThermalFuels.OTHER, services=Device[], time_at_status=INFINITE_TIME, dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    ThermalStandard(name, available, status, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, ramp_limits, operation_cost, base_power, time_limits, must_run, prime_mover_type, fuel, services, time_at_status, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function ThermalStandard(::Nothing)
    ThermalStandard(;
        name="init",
        available=false,
        status=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        rating=0.0,
        active_power_limits=(min=0.0, max=0.0),
        reactive_power_limits=nothing,
        ramp_limits=nothing,
        operation_cost=ThermalGenerationCost(nothing),
        base_power=100.0,
        time_limits=nothing,
        must_run=false,
        prime_mover_type=PrimeMovers.OT,
        fuel=ThermalFuels.OTHER,
        services=Device[],
        time_at_status=INFINITE_TIME,
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ThermalStandard`](@ref) `name`."""
get_name(value::ThermalStandard) = value.name
"""Get [`ThermalStandard`](@ref) `available`."""
get_available(value::ThermalStandard) = value.available
"""Get [`ThermalStandard`](@ref) `status`."""
get_status(value::ThermalStandard) = value.status
"""Get [`ThermalStandard`](@ref) `bus`."""
get_bus(value::ThermalStandard) = value.bus
"""Get [`ThermalStandard`](@ref) `active_power`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_active_power(value::ThermalStandard, units) = get_value(value, Val(:active_power), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{ ThermalStandard }) = InfrastructureSystems.SU
"""Get [`ThermalStandard`](@ref) `reactive_power`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_reactive_power(value::ThermalStandard, units) = get_value(value, Val(:reactive_power), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{ ThermalStandard }) = InfrastructureSystems.SU
"""Get [`ThermalStandard`](@ref) `rating`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_rating(value::ThermalStandard, units) = get_value(value, Val(:rating), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{ ThermalStandard }) = InfrastructureSystems.SU
"""Get [`ThermalStandard`](@ref) `active_power_limits`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_active_power_limits(value::ThermalStandard, units) = get_value(value, Val(:active_power_limits), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits), ::Type{ ThermalStandard }) = InfrastructureSystems.SU
"""Get [`ThermalStandard`](@ref) `reactive_power_limits`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_reactive_power_limits(value::ThermalStandard, units) = get_value(value, Val(:reactive_power_limits), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits), ::Type{ ThermalStandard }) = InfrastructureSystems.SU
"""Get [`ThermalStandard`](@ref) `ramp_limits`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_ramp_limits(value::ThermalStandard, units) = get_value(value, Val(:ramp_limits), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits), ::Type{ ThermalStandard }) = InfrastructureSystems.SU
"""Get [`ThermalStandard`](@ref) `operation_cost`."""
get_operation_cost(value::ThermalStandard) = value.operation_cost
"""Get [`ThermalStandard`](@ref) `base_power`."""
get_base_power(value::ThermalStandard) = value.base_power
"""Get [`ThermalStandard`](@ref) `time_limits`."""
get_time_limits(value::ThermalStandard) = value.time_limits
"""Get [`ThermalStandard`](@ref) `must_run`."""
get_must_run(value::ThermalStandard) = value.must_run
"""Get [`ThermalStandard`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::ThermalStandard) = value.prime_mover_type
"""Get [`ThermalStandard`](@ref) `fuel`."""
get_fuel(value::ThermalStandard) = value.fuel
"""Get [`ThermalStandard`](@ref) `services`."""
get_services(value::ThermalStandard) = value.services
"""Get [`ThermalStandard`](@ref) `time_at_status`."""
get_time_at_status(value::ThermalStandard) = value.time_at_status
"""Get [`ThermalStandard`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::ThermalStandard) = value.dynamic_injector
"""Get [`ThermalStandard`](@ref) `ext`."""
get_ext(value::ThermalStandard) = value.ext
"""Get [`ThermalStandard`](@ref) `internal`."""
get_internal(value::ThermalStandard) = value.internal

"""Set [`ThermalStandard`](@ref) `available`."""
set_available!(value::ThermalStandard, val) = value.available = val
"""Set [`ThermalStandard`](@ref) `status`."""
set_status!(value::ThermalStandard, val) = value.status = val
"""Set [`ThermalStandard`](@ref) `bus`."""
set_bus!(value::ThermalStandard, val) = value.bus = val
"""Set [`ThermalStandard`](@ref) `active_power`."""
set_active_power!(value::ThermalStandard, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`ThermalStandard`](@ref) `reactive_power`."""
set_reactive_power!(value::ThermalStandard, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mva))
"""Set [`ThermalStandard`](@ref) `rating`."""
set_rating!(value::ThermalStandard, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`ThermalStandard`](@ref) `active_power_limits`."""
set_active_power_limits!(value::ThermalStandard, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mva))
"""Set [`ThermalStandard`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::ThermalStandard, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mva))
"""Set [`ThermalStandard`](@ref) `ramp_limits`."""
set_ramp_limits!(value::ThermalStandard, val) = value.ramp_limits = set_value(value, Val(:ramp_limits), val, Val(:mva))
"""Set [`ThermalStandard`](@ref) `operation_cost`."""
set_operation_cost!(value::ThermalStandard, val) = value.operation_cost = val
"""Set [`ThermalStandard`](@ref) `base_power`."""
set_base_power!(value::ThermalStandard, val) = value.base_power = val
"""Set [`ThermalStandard`](@ref) `time_limits`."""
set_time_limits!(value::ThermalStandard, val) = value.time_limits = val
"""Set [`ThermalStandard`](@ref) `must_run`."""
set_must_run!(value::ThermalStandard, val) = value.must_run = val
"""Set [`ThermalStandard`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::ThermalStandard, val) = value.prime_mover_type = val
"""Set [`ThermalStandard`](@ref) `fuel`."""
set_fuel!(value::ThermalStandard, val) = value.fuel = val
"""Set [`ThermalStandard`](@ref) `services`."""
set_services!(value::ThermalStandard, val) = value.services = val
"""Set [`ThermalStandard`](@ref) `time_at_status`."""
set_time_at_status!(value::ThermalStandard, val) = value.time_at_status = val
"""Set [`ThermalStandard`](@ref) `ext`."""
set_ext!(value::ThermalStandard, val) = value.ext = val
