#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ThermalMultiStart <: ThermalGen
        name::String
        available::Bool
        status::OperationalStates
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
        operation_cost::OperationalCost
        base_power::Float64
        services::Vector{Service}
        time_at_status::Float64
        commitment_mode::CommitmentModes
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A thermal generator, such as a fossil fuel or nuclear generator, that can start-up again from a *hot*, *warm*, or *cold* state.

`ThermalMultiStart` has a detailed representation of the start-up process based on the time elapsed since the last shut down, as well as a detailed shut-down process. The model is based on ["Tight and Compact MILP Formulation for the Thermal Unit Commitment Problem."](https://doi.org/10.1109/TPWRS.2013.2251373). For a simplified representation of the start-up and shut-down processes, see [`ThermalStandard`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `status::OperationalStates`: Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)
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
- `time_limits::Union{Nothing, UpDown}`: Minimum up and Minimum down time limits in minutes, validation range: `(0, nothing)`
- `start_time_limits::Union{Nothing, StartUpStages}`: Time limits for start-up based on turbine temperature in minutes
- `start_types::Int`: Number of start-up based on turbine temperature, where `1` = *hot*, `2` = *warm*, and `3` = *cold*, validation range: `(1, 3)`
- `operation_cost::OperationalCost`: [`OperationalCost`](@ref) of generation
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `time_at_status::Float64`: (default: `INFINITE_TIME`) Time (e.g., `Minutes(360)`) the generator has been in its current `status`
- `commitment_mode::CommitmentModes`: (default: `CommitmentModes.COMMITTED`) Commitment mode of the unit. Options are listed [here](@ref commit_list)
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ThermalMultiStart <: ThermalGen
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)"
    status::OperationalStates
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
    "Minimum up and Minimum down time limits in minutes"
    time_limits::Union{Nothing, UpDown}
    "Time limits for start-up based on turbine temperature in minutes"
    start_time_limits::Union{Nothing, StartUpStages}
    "Number of start-up based on turbine temperature, where `1` = *hot*, `2` = *warm*, and `3` = *cold*"
    start_types::Int
    "[`OperationalCost`](@ref) of generation"
    operation_cost::OperationalCost
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Services that this device contributes to"
    services::Vector{Service}
    "Time (e.g., `Minutes(360)`) the generator has been in its current `status`"
    time_at_status::Float64
    "Commitment mode of the unit. Options are listed [here](@ref commit_list)"
    commitment_mode::CommitmentModes
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ThermalMultiStart(name, available, status, bus, active_power, reactive_power, rating, prime_mover_type, fuel, active_power_limits, reactive_power_limits, ramp_limits, power_trajectory, time_limits, start_time_limits, start_types, operation_cost, base_power, services=Device[], time_at_status=INFINITE_TIME, commitment_mode=CommitmentModes.COMMITTED, dynamic_injector=nothing, ext=Dict{String, Any}(), )
    ThermalMultiStart(name, available, status, bus, active_power, reactive_power, rating, prime_mover_type, fuel, active_power_limits, reactive_power_limits, ramp_limits, power_trajectory, time_limits, start_time_limits, start_types, operation_cost, base_power, services, time_at_status, commitment_mode, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function ThermalMultiStart(; name, available, status, bus, active_power, reactive_power, rating, prime_mover_type, fuel, active_power_limits, reactive_power_limits, ramp_limits, power_trajectory, time_limits, start_time_limits, start_types, operation_cost, base_power, services=Device[], time_at_status=INFINITE_TIME, commitment_mode=CommitmentModes.COMMITTED, dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    ThermalMultiStart(name, available, status, bus, active_power, reactive_power, rating, prime_mover_type, fuel, active_power_limits, reactive_power_limits, ramp_limits, power_trajectory, time_limits, start_time_limits, start_types, operation_cost, base_power, services, time_at_status, commitment_mode, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function ThermalMultiStart(::Nothing)
    ThermalMultiStart(;
        name="init",
        available=false,
        status=OperationalStates.OFFLINE,
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
        commitment_mode=CommitmentModes.UNCOMMITTED,
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
"""Get [`ThermalMultiStart`](@ref) `active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::ThermalMultiStart, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`ThermalMultiStart`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::ThermalMultiStart, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::ThermalMultiStart) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::ThermalMultiStart) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
"""Get [`ThermalMultiStart`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::ThermalMultiStart, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`ThermalMultiStart`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::ThermalMultiStart, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::ThermalMultiStart) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::ThermalMultiStart) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
"""Get [`ThermalMultiStart`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::ThermalMultiStart, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`ThermalMultiStart`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::ThermalMultiStart, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::ThermalMultiStart) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::ThermalMultiStart) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{ThermalMultiStart}) = InfrastructureSystems.DU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{ThermalMultiStart}) = InfrastructureSystems.DU
"""Get [`ThermalMultiStart`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::ThermalMultiStart) = value.prime_mover_type
"""Get [`ThermalMultiStart`](@ref) `fuel`."""
get_fuel(value::ThermalMultiStart) = value.fuel
"""Get [`ThermalMultiStart`](@ref) `active_power_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_limits_unitful`](@ref)."""
get_active_power_limits(value::ThermalMultiStart, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits), Val(:mw), units))
"""Get [`ThermalMultiStart`](@ref) `active_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_limits`](@ref)."""
get_active_power_limits_unitful(value::ThermalMultiStart, units) = get_value(value, Val(:active_power_limits), Val(:mw), units)
get_active_power_limits(value::ThermalMultiStart) = _units_arg_required(get_active_power_limits, value, :active_power_limits, Val(:mw))
get_active_power_limits_unitful(value::ThermalMultiStart) = _units_arg_required(get_active_power_limits_unitful, value, :active_power_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_unitful), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
"""Get [`ThermalMultiStart`](@ref) `reactive_power_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_unitful`](@ref)."""
get_reactive_power_limits(value::ThermalMultiStart, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits), Val(:mvar), units))
"""Get [`ThermalMultiStart`](@ref) `reactive_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_limits`](@ref)."""
get_reactive_power_limits_unitful(value::ThermalMultiStart, units) = get_value(value, Val(:reactive_power_limits), Val(:mvar), units)
get_reactive_power_limits(value::ThermalMultiStart) = _units_arg_required(get_reactive_power_limits, value, :reactive_power_limits, Val(:mvar))
get_reactive_power_limits_unitful(value::ThermalMultiStart) = _units_arg_required(get_reactive_power_limits_unitful, value, :reactive_power_limits, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_unitful), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
"""Get [`ThermalMultiStart`](@ref) `ramp_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_ramp_limits_unitful`](@ref)."""
get_ramp_limits(value::ThermalMultiStart, units) = InfrastructureSystems._strip_units(get_value(value, Val(:ramp_limits), Val(:mw), units))
"""Get [`ThermalMultiStart`](@ref) `ramp_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_ramp_limits`](@ref)."""
get_ramp_limits_unitful(value::ThermalMultiStart, units) = get_value(value, Val(:ramp_limits), Val(:mw), units)
get_ramp_limits(value::ThermalMultiStart) = _units_arg_required(get_ramp_limits, value, :ramp_limits, Val(:mw))
get_ramp_limits_unitful(value::ThermalMultiStart) = _units_arg_required(get_ramp_limits_unitful, value, :ramp_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits_unitful), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
"""Get [`ThermalMultiStart`](@ref) `power_trajectory` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_power_trajectory_unitful`](@ref)."""
get_power_trajectory(value::ThermalMultiStart, units) = InfrastructureSystems._strip_units(get_value(value, Val(:power_trajectory), Val(:mw), units))
"""Get [`ThermalMultiStart`](@ref) `power_trajectory` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_power_trajectory`](@ref)."""
get_power_trajectory_unitful(value::ThermalMultiStart, units) = get_value(value, Val(:power_trajectory), Val(:mw), units)
get_power_trajectory(value::ThermalMultiStart) = _units_arg_required(get_power_trajectory, value, :power_trajectory, Val(:mw))
get_power_trajectory_unitful(value::ThermalMultiStart) = _units_arg_required(get_power_trajectory_unitful, value, :power_trajectory, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_power_trajectory), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_power_trajectory_unitful), ::Type{ThermalMultiStart}) = InfrastructureSystems.SU
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
"""Get [`ThermalMultiStart`](@ref) `commitment_mode`."""
get_commitment_mode(value::ThermalMultiStart) = value.commitment_mode
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
"""Set [`ThermalMultiStart`](@ref) `active_power`."""
set_active_power!(value::ThermalMultiStart, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::ThermalMultiStart, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`ThermalMultiStart`](@ref) `reactive_power`."""
set_reactive_power!(value::ThermalMultiStart, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::ThermalMultiStart, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`ThermalMultiStart`](@ref) `rating`."""
set_rating!(value::ThermalMultiStart, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::ThermalMultiStart, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`ThermalMultiStart`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::ThermalMultiStart, val) = value.prime_mover_type = val
"""Set [`ThermalMultiStart`](@ref) `fuel`."""
set_fuel!(value::ThermalMultiStart, val) = value.fuel = val
"""Set [`ThermalMultiStart`](@ref) `active_power_limits`."""
set_active_power_limits!(value::ThermalMultiStart, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mw))
set_active_power_limits!(value::ThermalMultiStart, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
set_active_power_limits!(value::ThermalMultiStart, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
"""Set [`ThermalMultiStart`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::ThermalMultiStart, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mvar))
set_reactive_power_limits!(value::ThermalMultiStart, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
set_reactive_power_limits!(value::ThermalMultiStart, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
"""Set [`ThermalMultiStart`](@ref) `ramp_limits`."""
set_ramp_limits!(value::ThermalMultiStart, val) = value.ramp_limits = set_value(value, Val(:ramp_limits), val, Val(:mw))
set_ramp_limits!(value::ThermalMultiStart, val::_UntaggedNumber) = _units_tag_required(set_ramp_limits!, value, :ramp_limits, Val(:mw), val)
set_ramp_limits!(value::ThermalMultiStart, val::NamedTuple{(:up, :down), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_ramp_limits!, value, :ramp_limits, Val(:mw), val)
"""Set [`ThermalMultiStart`](@ref) `power_trajectory`."""
set_power_trajectory!(value::ThermalMultiStart, val) = value.power_trajectory = set_value(value, Val(:power_trajectory), val, Val(:mw))
set_power_trajectory!(value::ThermalMultiStart, val::_UntaggedNumber) = _units_tag_required(set_power_trajectory!, value, :power_trajectory, Val(:mw), val)
set_power_trajectory!(value::ThermalMultiStart, val::NamedTuple{(:startup, :shutdown), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_power_trajectory!, value, :power_trajectory, Val(:mw), val)
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
"""Set [`ThermalMultiStart`](@ref) `commitment_mode`."""
set_commitment_mode!(value::ThermalMultiStart, val) = value.commitment_mode = val
"""Set [`ThermalMultiStart`](@ref) `ext`."""
set_ext!(value::ThermalMultiStart, val) = value.ext = val


function from_openapi(po::PO.ThermalMultiStart, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return ThermalMultiStart(;
        name = po.name,
        available = po.available,
        status = OperationalStates(po.status),
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power,
        reactive_power = po.reactive_power,
        rating = po.rating,
        prime_mover_type = PrimeMovers(po.prime_mover_type),
        fuel = ThermalFuels(po.fuel),
        active_power_limits = _minmax_from_po(po.active_power_limits),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits),
        ramp_limits = _updown_from_po(po.ramp_limits),
        power_trajectory = _startup_shutdown_from_po(po.power_trajectory),
        time_limits = _updown_from_po(po.time_limits),
        start_time_limits = _startup_stages_from_po(po.start_time_limits),
        start_types = po.start_types,
        operation_cost = convert_cost(po.operation_cost)::OperationalCost,
        base_power = po.base_power,
        time_at_status = po.time_at_status,
        commitment_mode = CommitmentModes(po.commitment_mode),
    )
end

function from_openapi(po::PO.ThermalMultiStart, refs::OpenAPIRefs, ::NaturalUnit)
    return ThermalMultiStart(;
        name = po.name,
        available = po.available,
        status = OperationalStates(po.status),
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power / po.base_power,
        reactive_power = po.reactive_power / po.base_power,
        rating = po.rating / po.base_power,
        prime_mover_type = PrimeMovers(po.prime_mover_type),
        fuel = ThermalFuels(po.fuel),
        active_power_limits = _minmax_from_po(po.active_power_limits, (/), po.base_power),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits, (/), po.base_power),
        ramp_limits = _updown_from_po(po.ramp_limits, (/), po.base_power),
        power_trajectory = _startup_shutdown_from_po(po.power_trajectory, (/), po.base_power),
        time_limits = _updown_from_po(po.time_limits),
        start_time_limits = _startup_stages_from_po(po.start_time_limits),
        start_types = po.start_types,
        operation_cost = convert_cost(po.operation_cost)::OperationalCost,
        base_power = po.base_power,
        time_at_status = po.time_at_status,
        commitment_mode = CommitmentModes(po.commitment_mode),
    )
end

function from_openapi(po::PO.ThermalMultiStart, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("ThermalMultiStart", po.id, po.power_units))
end

function to_openapi(value::ThermalMultiStart, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PO.ThermalMultiStart(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        status = string(get_status(value)),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, DU),
        reactive_power = get_reactive_power(value, DU),
        rating = get_rating(value, DU),
        prime_mover_type = string(get_prime_mover_type(value)),
        fuel = string(get_fuel(value)),
        active_power_limits = _minmax_po(get_active_power_limits(value, DU)),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(value, DU)),
        ramp_limits = _updown_po_optional(get_ramp_limits(value, DU)),
        power_trajectory = _startup_shutdown_po_optional(get_power_trajectory(value, DU)),
        time_limits = _updown_po_optional(get_time_limits(value)),
        start_time_limits = _startup_stages_po_optional(get_start_time_limits(value)),
        start_types = get_start_types(value),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
        base_power = _get_base_power(value),
        time_at_status = get_time_at_status(value),
        commitment_mode = string(get_commitment_mode(value)),
        power_units = _power_units_string(DU),
    )
end

function to_openapi(value::ThermalMultiStart, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.ThermalMultiStart(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        status = string(get_status(value)),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, DU) * _get_base_power(value),
        reactive_power = get_reactive_power(value, DU) * _get_base_power(value),
        rating = get_rating(value, DU) * _get_base_power(value),
        prime_mover_type = string(get_prime_mover_type(value)),
        fuel = string(get_fuel(value)),
        active_power_limits = _minmax_po_scaled(get_active_power_limits(value, DU), _get_base_power(value)),
        reactive_power_limits = _minmax_po_scaled_optional(get_reactive_power_limits(value, DU), _get_base_power(value)),
        ramp_limits = _updown_po_scaled_optional(get_ramp_limits(value, DU), _get_base_power(value)),
        power_trajectory = _startup_shutdown_po_scaled_optional(get_power_trajectory(value, DU), _get_base_power(value)),
        time_limits = _updown_po_optional(get_time_limits(value)),
        start_time_limits = _startup_stages_po_optional(get_start_time_limits(value)),
        start_types = get_start_types(value),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
        base_power = _get_base_power(value),
        time_at_status = get_time_at_status(value),
        commitment_mode = string(get_commitment_mode(value)),
        power_units = _power_units_string(NU),
    )
end
