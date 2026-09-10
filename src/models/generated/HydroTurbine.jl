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
        status::OperationalStates
        time_at_status::Float64
        commitment_mode::CommitmentModes
        operation_cost::OperationalCost
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
- `status::OperationalStates`: (default: `OperationalStates.OFFLINE`) Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)
- `time_at_status::Float64`: (default: `INFINITE_TIME`) Time (e.g., `Minutes(360)`) the generator has been in its current `status`
- `commitment_mode::CommitmentModes`: (default: `CommitmentModes.COMMITTED`) Commitment mode of the unit. Options are listed [here](@ref commit_list)
- `operation_cost::OperationalCost`: (default: `HydroGenerationCost(nothing)`) [`OperationalCost`](@ref) of generation
- `powerhouse_elevation::Float64`: (default: `0.0`) Height level in meters above the sea level of the powerhouse on which the turbine is installed., validation range: `(0, nothing)`
- `ramp_limits::Union{Nothing, UpDown}`: (default: `nothing`) ramp up and ramp down limits in MW/min, validation range: `(0, nothing)`
- `time_limits::Union{Nothing, UpDown}`: (default: `nothing`) Minimum up and Minimum down time limits in minutes, validation range: `(0, nothing)`
- `outflow_limits::Union{Nothing, MinMax}`: (default: `nothing`) Turbine outflow limits in m3/s. Set to `Nothing` if not applicable
- `efficiency::Float64`: (default: `1.0`) Turbine efficiency [0, 1.0], validation range: `(0, 1)`
- `turbine_type::HydroTurbineType`: (default: `HydroTurbineType.UNKNOWN`) Type of the turbine
- `conversion_factor::Float64`: (default: `1.0`) Conversion factor from flow/volume to energy: m^3 -> p.u-hr
- `prime_mover_type::PrimeMovers`: (default: `PrimeMovers.HY`) Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
- `travel_time::Union{Nothing, Float64}`: (default: `nothing`) Downstream (from reservoir into turbine) travel time in minutes.
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
    "Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)"
    status::OperationalStates
    "Time (e.g., `Minutes(360)`) the generator has been in its current `status`"
    time_at_status::Float64
    "Commitment mode of the unit. Options are listed [here](@ref commit_list)"
    commitment_mode::CommitmentModes
    "[`OperationalCost`](@ref) of generation"
    operation_cost::OperationalCost
    "Height level in meters above the sea level of the powerhouse on which the turbine is installed."
    powerhouse_elevation::Float64
    "ramp up and ramp down limits in MW/min"
    ramp_limits::Union{Nothing, UpDown}
    "Minimum up and Minimum down time limits in minutes"
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
    "Downstream (from reservoir into turbine) travel time in minutes."
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

function HydroTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, base_power, status=OperationalStates.OFFLINE, time_at_status=INFINITE_TIME, commitment_mode=CommitmentModes.COMMITTED, operation_cost=HydroGenerationCost(nothing), powerhouse_elevation=0.0, ramp_limits=nothing, time_limits=nothing, outflow_limits=nothing, efficiency=1.0, turbine_type=HydroTurbineType.UNKNOWN, conversion_factor=1.0, prime_mover_type=PrimeMovers.HY, travel_time=nothing, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    HydroTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, base_power, status, time_at_status, commitment_mode, operation_cost, powerhouse_elevation, ramp_limits, time_limits, outflow_limits, efficiency, turbine_type, conversion_factor, prime_mover_type, travel_time, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function HydroTurbine(; name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, base_power, status=OperationalStates.OFFLINE, time_at_status=INFINITE_TIME, commitment_mode=CommitmentModes.COMMITTED, operation_cost=HydroGenerationCost(nothing), powerhouse_elevation=0.0, ramp_limits=nothing, time_limits=nothing, outflow_limits=nothing, efficiency=1.0, turbine_type=HydroTurbineType.UNKNOWN, conversion_factor=1.0, prime_mover_type=PrimeMovers.HY, travel_time=nothing, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    HydroTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, base_power, status, time_at_status, commitment_mode, operation_cost, powerhouse_elevation, ramp_limits, time_limits, outflow_limits, efficiency, turbine_type, conversion_factor, prime_mover_type, travel_time, services, dynamic_injector, ext, internal, )
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
        status=OperationalStates.OFFLINE,
        time_at_status=INFINITE_TIME,
        commitment_mode=CommitmentModes.UNCOMMITTED,
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
"""Get [`HydroTurbine`](@ref) `active_power` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::HydroTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`HydroTurbine`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::HydroTurbine, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::HydroTurbine) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::HydroTurbine) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{HydroTurbine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{HydroTurbine}) = InfrastructureSystems.SU
"""Get [`HydroTurbine`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::HydroTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`HydroTurbine`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::HydroTurbine, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::HydroTurbine) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::HydroTurbine) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{HydroTurbine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{HydroTurbine}) = InfrastructureSystems.SU
"""Get [`HydroTurbine`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::HydroTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`HydroTurbine`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::HydroTurbine, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::HydroTurbine) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::HydroTurbine) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{HydroTurbine}) = InfrastructureSystems.CU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{HydroTurbine}) = InfrastructureSystems.CU
"""Get [`HydroTurbine`](@ref) `active_power_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_limits_unitful`](@ref)."""
get_active_power_limits(value::HydroTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits), Val(:mw), units))
"""Get [`HydroTurbine`](@ref) `active_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_active_power_limits`](@ref)."""
get_active_power_limits_unitful(value::HydroTurbine, units) = get_value(value, Val(:active_power_limits), Val(:mw), units)
get_active_power_limits(value::HydroTurbine) = _units_arg_required(get_active_power_limits, value, :active_power_limits, Val(:mw))
get_active_power_limits_unitful(value::HydroTurbine) = _units_arg_required(get_active_power_limits_unitful, value, :active_power_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits), ::Type{HydroTurbine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_unitful), ::Type{HydroTurbine}) = InfrastructureSystems.SU
"""Get [`HydroTurbine`](@ref) `reactive_power_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_unitful`](@ref)."""
get_reactive_power_limits(value::HydroTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits), Val(:mvar), units))
"""Get [`HydroTurbine`](@ref) `reactive_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_reactive_power_limits`](@ref)."""
get_reactive_power_limits_unitful(value::HydroTurbine, units) = get_value(value, Val(:reactive_power_limits), Val(:mvar), units)
get_reactive_power_limits(value::HydroTurbine) = _units_arg_required(get_reactive_power_limits, value, :reactive_power_limits, Val(:mvar))
get_reactive_power_limits_unitful(value::HydroTurbine) = _units_arg_required(get_reactive_power_limits_unitful, value, :reactive_power_limits, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits), ::Type{HydroTurbine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_unitful), ::Type{HydroTurbine}) = InfrastructureSystems.SU

_get_base_power(value::HydroTurbine) = value.base_power
"""Get [`HydroTurbine`](@ref) `status`."""
get_status(value::HydroTurbine) = value.status
"""Get [`HydroTurbine`](@ref) `time_at_status`."""
get_time_at_status(value::HydroTurbine) = value.time_at_status
"""Get [`HydroTurbine`](@ref) `commitment_mode`."""
get_commitment_mode(value::HydroTurbine) = value.commitment_mode
"""Get [`HydroTurbine`](@ref) `operation_cost`."""
get_operation_cost(value::HydroTurbine) = value.operation_cost
"""Get [`HydroTurbine`](@ref) `powerhouse_elevation`."""
get_powerhouse_elevation(value::HydroTurbine) = value.powerhouse_elevation
"""Get [`HydroTurbine`](@ref) `ramp_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_ramp_limits_unitful`](@ref)."""
get_ramp_limits(value::HydroTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:ramp_limits), Val(:mw), units))
"""Get [`HydroTurbine`](@ref) `ramp_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_ramp_limits`](@ref)."""
get_ramp_limits_unitful(value::HydroTurbine, units) = get_value(value, Val(:ramp_limits), Val(:mw), units)
get_ramp_limits(value::HydroTurbine) = _units_arg_required(get_ramp_limits, value, :ramp_limits, Val(:mw))
get_ramp_limits_unitful(value::HydroTurbine) = _units_arg_required(get_ramp_limits_unitful, value, :ramp_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits), ::Type{HydroTurbine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits_unitful), ::Type{HydroTurbine}) = InfrastructureSystems.SU
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
"""Set [`HydroTurbine`](@ref) `active_power`."""
set_active_power!(value::HydroTurbine, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::HydroTurbine, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`HydroTurbine`](@ref) `reactive_power`."""
set_reactive_power!(value::HydroTurbine, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::HydroTurbine, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`HydroTurbine`](@ref) `rating`."""
set_rating!(value::HydroTurbine, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::HydroTurbine, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`HydroTurbine`](@ref) `active_power_limits`."""
set_active_power_limits!(value::HydroTurbine, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mw))
set_active_power_limits!(value::HydroTurbine, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
set_active_power_limits!(value::HydroTurbine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
"""Set [`HydroTurbine`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::HydroTurbine, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mvar))
set_reactive_power_limits!(value::HydroTurbine, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
set_reactive_power_limits!(value::HydroTurbine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
"""Set [`HydroTurbine`](@ref) `status`."""
set_status!(value::HydroTurbine, val) = value.status = val
"""Set [`HydroTurbine`](@ref) `time_at_status`."""
set_time_at_status!(value::HydroTurbine, val) = value.time_at_status = val
"""Set [`HydroTurbine`](@ref) `commitment_mode`."""
set_commitment_mode!(value::HydroTurbine, val) = value.commitment_mode = val
"""Set [`HydroTurbine`](@ref) `operation_cost`."""
set_operation_cost!(value::HydroTurbine, val) = value.operation_cost = val
"""Set [`HydroTurbine`](@ref) `powerhouse_elevation`."""
set_powerhouse_elevation!(value::HydroTurbine, val) = value.powerhouse_elevation = val
"""Set [`HydroTurbine`](@ref) `ramp_limits`."""
set_ramp_limits!(value::HydroTurbine, val) = value.ramp_limits = set_value(value, Val(:ramp_limits), val, Val(:mw))
set_ramp_limits!(value::HydroTurbine, val::_UntaggedNumber) = _units_tag_required(set_ramp_limits!, value, :ramp_limits, Val(:mw), val)
set_ramp_limits!(value::HydroTurbine, val::NamedTuple{(:up, :down), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_ramp_limits!, value, :ramp_limits, Val(:mw), val)
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


function from_openapi(po::PO.HydroTurbine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return HydroTurbine(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power,
        reactive_power = po.reactive_power,
        rating = po.rating,
        active_power_limits = _minmax_from_po(po.active_power_limits),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits),
        base_power = po.base_power,
        status = OperationalStates(po.status.value),
        time_at_status = po.time_at_status,
        commitment_mode = CommitmentModes(po.commitment_mode.value),
        operation_cost = convert_cost(po.operation_cost)::OperationalCost,
        powerhouse_elevation = po.powerhouse_elevation,
        ramp_limits = _updown_from_po(po.ramp_limits),
        time_limits = _updown_from_po(po.time_limits),
        outflow_limits = _minmax_from_po(po.outflow_limits),
        efficiency = po.efficiency,
        turbine_type = HydroTurbineType(po.turbine_type.value),
        conversion_factor = po.conversion_factor,
        prime_mover_type = PrimeMovers(po.prime_mover_type.value),
        travel_time = po.travel_time,
    )
end

function from_openapi(po::PO.HydroTurbine, refs::OpenAPIRefs, ::NaturalUnit)
    return HydroTurbine(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power / po.base_power,
        reactive_power = po.reactive_power / po.base_power,
        rating = po.rating / po.base_power,
        active_power_limits = _minmax_from_po(po.active_power_limits, (/), po.base_power),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits, (/), po.base_power),
        base_power = po.base_power,
        status = OperationalStates(po.status.value),
        time_at_status = po.time_at_status,
        commitment_mode = CommitmentModes(po.commitment_mode.value),
        operation_cost = convert_cost(po.operation_cost)::OperationalCost,
        powerhouse_elevation = po.powerhouse_elevation,
        ramp_limits = _updown_from_po(po.ramp_limits, (/), po.base_power),
        time_limits = _updown_from_po(po.time_limits),
        outflow_limits = _minmax_from_po(po.outflow_limits),
        efficiency = po.efficiency,
        turbine_type = HydroTurbineType(po.turbine_type.value),
        conversion_factor = po.conversion_factor,
        prime_mover_type = PrimeMovers(po.prime_mover_type.value),
        travel_time = po.travel_time,
    )
end

function from_openapi(po::PO.HydroTurbine, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("HydroTurbine", po.id, po.power_units))
end

function to_openapi(value::HydroTurbine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.HydroTurbine(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, CU),
        reactive_power = get_reactive_power(value, CU),
        rating = get_rating(value, CU),
        active_power_limits = _minmax_po(get_active_power_limits(value, CU)),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(value, CU)),
        base_power = _get_base_power(value),
        status = PO.OperationalStates(string(get_status(value))),
        time_at_status = get_time_at_status(value),
        commitment_mode = PO.CommitmentModes(string(get_commitment_mode(value))),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
        powerhouse_elevation = get_powerhouse_elevation(value),
        ramp_limits = _updown_po_optional(get_ramp_limits(value, CU)),
        time_limits = _updown_po_optional(get_time_limits(value)),
        outflow_limits = _minmax_po_optional(get_outflow_limits(value)),
        efficiency = get_efficiency(value),
        turbine_type = PO.HydroTurbineTurbineType(string(get_turbine_type(value))),
        conversion_factor = get_conversion_factor(value),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(value))),
        travel_time = get_travel_time(value),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(value::HydroTurbine, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.HydroTurbine(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, CU) * _get_base_power(value),
        reactive_power = get_reactive_power(value, CU) * _get_base_power(value),
        rating = get_rating(value, CU) * _get_base_power(value),
        active_power_limits = _minmax_po_scaled(get_active_power_limits(value, CU), _get_base_power(value)),
        reactive_power_limits = _minmax_po_scaled_optional(get_reactive_power_limits(value, CU), _get_base_power(value)),
        base_power = _get_base_power(value),
        status = PO.OperationalStates(string(get_status(value))),
        time_at_status = get_time_at_status(value),
        commitment_mode = PO.CommitmentModes(string(get_commitment_mode(value))),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
        powerhouse_elevation = get_powerhouse_elevation(value),
        ramp_limits = _updown_po_scaled_optional(get_ramp_limits(value, CU), _get_base_power(value)),
        time_limits = _updown_po_optional(get_time_limits(value)),
        outflow_limits = _minmax_po_optional(get_outflow_limits(value)),
        efficiency = get_efficiency(value),
        turbine_type = PO.HydroTurbineTurbineType(string(get_turbine_type(value))),
        conversion_factor = get_conversion_factor(value),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(value))),
        travel_time = get_travel_time(value),
        power_units = _power_units_string(NU),
    )
end
