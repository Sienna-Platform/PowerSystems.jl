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
        operating_mode::HydroPumpTurbineStatus.T
        status::OperationalStates.T
        time_at_status::Float64
        operation_cost::OperationalCost
        active_power_pump::Float64
        efficiency::TurbinePump
        transition_time::TurbinePump
        minimum_time::TurbinePump
        travel_time::Union{Nothing, Float64}
        conversion_factor::Float64
        commitment_mode::CommitmentModes.T
        prime_mover_type::PrimeMovers.T
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
- `ramp_limits::Union{Nothing, UpDown}`: Ramp up and ramp down limits (MW/min), validation range: `(0, nothing)`
- `time_limits::Union{Nothing, UpDown}`: Minimum up and Minimum down time limits in minutes, validation range: `(0, nothing)`
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `operating_mode::HydroPumpTurbineStatus.T`: (default: `HydroPumpTurbineStatus.OFF`) Mode the pumped‑storage unit is operating in: generating, pumping, or idle. See [HydroPumpTurbineStatus](@ref) for reference
- `status::OperationalStates.T`: (default: `OperationalStates.OFFLINE`) Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)
- `time_at_status::Float64`: (default: `INFINITE_TIME`) Time (e.g., `Minutes(360)`) the generator has been in its current `status`
- `operation_cost::OperationalCost`: (default: `HydroGenerationCost(nothing)`) [`OperationalCost`](@ref) of generation
- `active_power_pump::Float64`: (default: `0.0`) Initial active power set point of the pump unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `efficiency::TurbinePump`: (default: `(turbine = 1.0, pump = 1.0)`) Turbine/Pump efficiency [0, 1.0]
- `transition_time::TurbinePump`: (default: `(turbine = 0.0, pump = 0.0)`) Transition time in minutes to switch into the specific mode.
- `minimum_time::TurbinePump`: (default: `(turbine = 0.0, pump = 0.0)`) Minimum operating time in minutes for the specific mode.
- `travel_time::Union{Nothing, Float64}`: (default: `nothing`) Downstream (from reservoir into turbine) travel time in minutes.
- `conversion_factor::Float64`: (default: `1.0`) Conversion factor from flow/volume to energy: m^3 -> p.u-hr
- `commitment_mode::CommitmentModes.T`: (default: `CommitmentModes.COMMITTED`) Commitment mode of the unit. Options are listed [here](@ref commit_list)
- `prime_mover_type::PrimeMovers.T`: (default: `PrimeMovers.PS`) Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
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
    "Ramp up and ramp down limits (MW/min)"
    ramp_limits::Union{Nothing, UpDown}
    "Minimum up and Minimum down time limits in minutes"
    time_limits::Union{Nothing, UpDown}
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Mode the pumped‑storage unit is operating in: generating, pumping, or idle. See [HydroPumpTurbineStatus](@ref) for reference"
    operating_mode::HydroPumpTurbineStatus.T
    "Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)"
    status::OperationalStates.T
    "Time (e.g., `Minutes(360)`) the generator has been in its current `status`"
    time_at_status::Float64
    "[`OperationalCost`](@ref) of generation"
    operation_cost::OperationalCost
    "Initial active power set point of the pump unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used"
    active_power_pump::Float64
    "Turbine/Pump efficiency [0, 1.0]"
    efficiency::TurbinePump
    "Transition time in minutes to switch into the specific mode."
    transition_time::TurbinePump
    "Minimum operating time in minutes for the specific mode."
    minimum_time::TurbinePump
    "Downstream (from reservoir into turbine) travel time in minutes."
    travel_time::Union{Nothing, Float64}
    "Conversion factor from flow/volume to energy: m^3 -> p.u-hr"
    conversion_factor::Float64
    "Commitment mode of the unit. Options are listed [here](@ref commit_list)"
    commitment_mode::CommitmentModes.T
    "Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)"
    prime_mover_type::PrimeMovers.T
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function HydroPumpTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, active_power_limits_pump, outflow_limits, powerhouse_elevation, ramp_limits, time_limits, base_power, operating_mode=HydroPumpTurbineStatus.OFF, status=OperationalStates.OFFLINE, time_at_status=INFINITE_TIME, operation_cost=HydroGenerationCost(nothing), active_power_pump=0.0, efficiency=(turbine = 1.0, pump = 1.0), transition_time=(turbine = 0.0, pump = 0.0), minimum_time=(turbine = 0.0, pump = 0.0), travel_time=nothing, conversion_factor=1.0, commitment_mode=CommitmentModes.COMMITTED, prime_mover_type=PrimeMovers.PS, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    HydroPumpTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, active_power_limits_pump, outflow_limits, powerhouse_elevation, ramp_limits, time_limits, base_power, operating_mode, status, time_at_status, operation_cost, active_power_pump, efficiency, transition_time, minimum_time, travel_time, conversion_factor, commitment_mode, prime_mover_type, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function HydroPumpTurbine(; name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, active_power_limits_pump, outflow_limits, powerhouse_elevation, ramp_limits, time_limits, base_power, operating_mode=HydroPumpTurbineStatus.OFF, status=OperationalStates.OFFLINE, time_at_status=INFINITE_TIME, operation_cost=HydroGenerationCost(nothing), active_power_pump=0.0, efficiency=(turbine = 1.0, pump = 1.0), transition_time=(turbine = 0.0, pump = 0.0), minimum_time=(turbine = 0.0, pump = 0.0), travel_time=nothing, conversion_factor=1.0, commitment_mode=CommitmentModes.COMMITTED, prime_mover_type=PrimeMovers.PS, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    HydroPumpTurbine(name, available, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, active_power_limits_pump, outflow_limits, powerhouse_elevation, ramp_limits, time_limits, base_power, operating_mode, status, time_at_status, operation_cost, active_power_pump, efficiency, transition_time, minimum_time, travel_time, conversion_factor, commitment_mode, prime_mover_type, services, dynamic_injector, ext, internal, )
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
        operating_mode=HydroPumpTurbineStatus.OFF,
        status=OperationalStates.OFFLINE,
        time_at_status=INFINITE_TIME,
        operation_cost=HydroGenerationCost(nothing),
        active_power_pump=0.0,
        efficiency=(turbine = 1.0, pump = 1.0),
        transition_time=(turbine = 0.0, pump = 0.0),
        minimum_time=(turbine = 0.0, pump = 0.0),
        travel_time=nothing,
        conversion_factor=1.0,
        commitment_mode=CommitmentModes.UNCOMMITTED,
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
"""Get [`HydroPumpTurbine`](@ref) `active_power` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::HydroPumpTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`HydroPumpTurbine`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::HydroPumpTurbine, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::HydroPumpTurbine) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::HydroPumpTurbine) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
"""Get [`HydroPumpTurbine`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::HydroPumpTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`HydroPumpTurbine`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::HydroPumpTurbine, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::HydroPumpTurbine) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::HydroPumpTurbine) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
"""Get [`HydroPumpTurbine`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::HydroPumpTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`HydroPumpTurbine`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::HydroPumpTurbine, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::HydroPumpTurbine) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::HydroPumpTurbine) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{HydroPumpTurbine}) = InfrastructureSystems.CU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{HydroPumpTurbine}) = InfrastructureSystems.CU
"""Get [`HydroPumpTurbine`](@ref) `active_power_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_limits_unitful`](@ref)."""
get_active_power_limits(value::HydroPumpTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits), Val(:mw), units))
"""Get [`HydroPumpTurbine`](@ref) `active_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_active_power_limits`](@ref)."""
get_active_power_limits_unitful(value::HydroPumpTurbine, units) = get_value(value, Val(:active_power_limits), Val(:mw), units)
get_active_power_limits(value::HydroPumpTurbine) = _units_arg_required(get_active_power_limits, value, :active_power_limits, Val(:mw))
get_active_power_limits_unitful(value::HydroPumpTurbine) = _units_arg_required(get_active_power_limits_unitful, value, :active_power_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_unitful), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
"""Get [`HydroPumpTurbine`](@ref) `reactive_power_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_unitful`](@ref)."""
get_reactive_power_limits(value::HydroPumpTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits), Val(:mvar), units))
"""Get [`HydroPumpTurbine`](@ref) `reactive_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_reactive_power_limits`](@ref)."""
get_reactive_power_limits_unitful(value::HydroPumpTurbine, units) = get_value(value, Val(:reactive_power_limits), Val(:mvar), units)
get_reactive_power_limits(value::HydroPumpTurbine) = _units_arg_required(get_reactive_power_limits, value, :reactive_power_limits, Val(:mvar))
get_reactive_power_limits_unitful(value::HydroPumpTurbine) = _units_arg_required(get_reactive_power_limits_unitful, value, :reactive_power_limits, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_unitful), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
"""Get [`HydroPumpTurbine`](@ref) `active_power_limits_pump` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_limits_pump_unitful`](@ref)."""
get_active_power_limits_pump(value::HydroPumpTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits_pump), Val(:mw), units))
"""Get [`HydroPumpTurbine`](@ref) `active_power_limits_pump` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_active_power_limits_pump`](@ref)."""
get_active_power_limits_pump_unitful(value::HydroPumpTurbine, units) = get_value(value, Val(:active_power_limits_pump), Val(:mw), units)
get_active_power_limits_pump(value::HydroPumpTurbine) = _units_arg_required(get_active_power_limits_pump, value, :active_power_limits_pump, Val(:mw))
get_active_power_limits_pump_unitful(value::HydroPumpTurbine) = _units_arg_required(get_active_power_limits_pump_unitful, value, :active_power_limits_pump, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_pump), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_pump_unitful), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
"""Get [`HydroPumpTurbine`](@ref) `outflow_limits`."""
get_outflow_limits(value::HydroPumpTurbine) = value.outflow_limits
"""Get [`HydroPumpTurbine`](@ref) `powerhouse_elevation`."""
get_powerhouse_elevation(value::HydroPumpTurbine) = value.powerhouse_elevation
"""Get [`HydroPumpTurbine`](@ref) `ramp_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_ramp_limits_unitful`](@ref)."""
get_ramp_limits(value::HydroPumpTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:ramp_limits), Val(:mw_per_minute), units))
"""Get [`HydroPumpTurbine`](@ref) `ramp_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_ramp_limits`](@ref)."""
get_ramp_limits_unitful(value::HydroPumpTurbine, units) = get_value(value, Val(:ramp_limits), Val(:mw_per_minute), units)
get_ramp_limits(value::HydroPumpTurbine) = _units_arg_required(get_ramp_limits, value, :ramp_limits, Val(:mw_per_minute))
get_ramp_limits_unitful(value::HydroPumpTurbine) = _units_arg_required(get_ramp_limits_unitful, value, :ramp_limits, Val(:mw_per_minute))
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits), ::Type{HydroPumpTurbine}) = SU / u"minute"
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits_unitful), ::Type{HydroPumpTurbine}) = SU / u"minute"
"""Get [`HydroPumpTurbine`](@ref) `time_limits`."""
get_time_limits(value::HydroPumpTurbine) = value.time_limits

_get_base_power(value::HydroPumpTurbine) = value.base_power
"""Get [`HydroPumpTurbine`](@ref) `operating_mode`."""
get_operating_mode(value::HydroPumpTurbine) = value.operating_mode
"""Get [`HydroPumpTurbine`](@ref) `status`."""
get_status(value::HydroPumpTurbine) = value.status
"""Get [`HydroPumpTurbine`](@ref) `time_at_status`."""
get_time_at_status(value::HydroPumpTurbine) = value.time_at_status
"""Get [`HydroPumpTurbine`](@ref) `operation_cost`."""
get_operation_cost(value::HydroPumpTurbine) = value.operation_cost
"""Get [`HydroPumpTurbine`](@ref) `active_power_pump` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_pump_unitful`](@ref)."""
get_active_power_pump(value::HydroPumpTurbine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_pump), Val(:mw), units))
"""Get [`HydroPumpTurbine`](@ref) `active_power_pump` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_active_power_pump`](@ref)."""
get_active_power_pump_unitful(value::HydroPumpTurbine, units) = get_value(value, Val(:active_power_pump), Val(:mw), units)
get_active_power_pump(value::HydroPumpTurbine) = _units_arg_required(get_active_power_pump, value, :active_power_pump, Val(:mw))
get_active_power_pump_unitful(value::HydroPumpTurbine) = _units_arg_required(get_active_power_pump_unitful, value, :active_power_pump, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_pump), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_pump_unitful), ::Type{HydroPumpTurbine}) = InfrastructureSystems.SU
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
"""Get [`HydroPumpTurbine`](@ref) `commitment_mode`."""
get_commitment_mode(value::HydroPumpTurbine) = value.commitment_mode
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
set_active_power!(value::HydroPumpTurbine, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::HydroPumpTurbine, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`HydroPumpTurbine`](@ref) `reactive_power`."""
set_reactive_power!(value::HydroPumpTurbine, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::HydroPumpTurbine, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`HydroPumpTurbine`](@ref) `rating`."""
set_rating!(value::HydroPumpTurbine, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::HydroPumpTurbine, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`HydroPumpTurbine`](@ref) `active_power_limits`."""
set_active_power_limits!(value::HydroPumpTurbine, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mw))
set_active_power_limits!(value::HydroPumpTurbine, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
set_active_power_limits!(value::HydroPumpTurbine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
"""Set [`HydroPumpTurbine`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::HydroPumpTurbine, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mvar))
set_reactive_power_limits!(value::HydroPumpTurbine, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
set_reactive_power_limits!(value::HydroPumpTurbine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
"""Set [`HydroPumpTurbine`](@ref) `active_power_limits_pump`."""
set_active_power_limits_pump!(value::HydroPumpTurbine, val) = value.active_power_limits_pump = set_value(value, Val(:active_power_limits_pump), val, Val(:mw))
set_active_power_limits_pump!(value::HydroPumpTurbine, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits_pump!, value, :active_power_limits_pump, Val(:mw), val)
set_active_power_limits_pump!(value::HydroPumpTurbine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits_pump!, value, :active_power_limits_pump, Val(:mw), val)
"""Set [`HydroPumpTurbine`](@ref) `outflow_limits`."""
set_outflow_limits!(value::HydroPumpTurbine, val) = value.outflow_limits = val
"""Set [`HydroPumpTurbine`](@ref) `powerhouse_elevation`."""
set_powerhouse_elevation!(value::HydroPumpTurbine, val) = value.powerhouse_elevation = val
"""Set [`HydroPumpTurbine`](@ref) `ramp_limits`."""
set_ramp_limits!(value::HydroPumpTurbine, val) = value.ramp_limits = set_value(value, Val(:ramp_limits), val, Val(:mw_per_minute))
set_ramp_limits!(value::HydroPumpTurbine, val::_UntaggedNumber) = _units_tag_required(set_ramp_limits!, value, :ramp_limits, Val(:mw_per_minute), val)
set_ramp_limits!(value::HydroPumpTurbine, val::NamedTuple{(:up, :down), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_ramp_limits!, value, :ramp_limits, Val(:mw_per_minute), val)
"""Set [`HydroPumpTurbine`](@ref) `time_limits`."""
set_time_limits!(value::HydroPumpTurbine, val) = value.time_limits = val
"""Set [`HydroPumpTurbine`](@ref) `operating_mode`."""
set_operating_mode!(value::HydroPumpTurbine, val) = value.operating_mode = val
"""Set [`HydroPumpTurbine`](@ref) `status`."""
set_status!(value::HydroPumpTurbine, val) = value.status = val
"""Set [`HydroPumpTurbine`](@ref) `time_at_status`."""
set_time_at_status!(value::HydroPumpTurbine, val) = value.time_at_status = val
"""Set [`HydroPumpTurbine`](@ref) `operation_cost`."""
set_operation_cost!(value::HydroPumpTurbine, val) = value.operation_cost = val
"""Set [`HydroPumpTurbine`](@ref) `active_power_pump`."""
set_active_power_pump!(value::HydroPumpTurbine, val) = value.active_power_pump = set_value(value, Val(:active_power_pump), val, Val(:mw))
set_active_power_pump!(value::HydroPumpTurbine, val::_UntaggedNumber) = _units_tag_required(set_active_power_pump!, value, :active_power_pump, Val(:mw), val)
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
"""Set [`HydroPumpTurbine`](@ref) `commitment_mode`."""
set_commitment_mode!(value::HydroPumpTurbine, val) = value.commitment_mode = val
"""Set [`HydroPumpTurbine`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::HydroPumpTurbine, val) = value.prime_mover_type = val
"""Set [`HydroPumpTurbine`](@ref) `services`."""
set_services!(value::HydroPumpTurbine, val) = value.services = val
"""Set [`HydroPumpTurbine`](@ref) `ext`."""
set_ext!(value::HydroPumpTurbine, val) = value.ext = val


function from_openapi(po::PO.HydroPumpTurbine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return HydroPumpTurbine(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power,
        reactive_power = po.reactive_power,
        rating = po.rating,
        active_power_limits = _minmax_from_po(po.active_power_limits),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits),
        active_power_limits_pump = _minmax_from_po(po.active_power_limits_pump),
        outflow_limits = _minmax_from_po(po.outflow_limits),
        powerhouse_elevation = po.powerhouse_elevation,
        ramp_limits = _updown_from_po(po.ramp_limits),
        time_limits = _updown_from_po(po.time_limits),
        base_power = po.base_power,
        operating_mode = _or_default_enum(po.operating_mode, HydroPumpTurbineStatus.OFF),
        status = _or_default_enum(po.status, OperationalStates.OFFLINE),
        time_at_status = _or_default(po.time_at_status, INFINITE_TIME),
        operation_cost = convert_cost(po.operation_cost.value)::OperationalCost,
        active_power_pump = _or_default(po.active_power_pump, 0.0),
        efficiency = _turbinepump_from_po(po.efficiency),
        transition_time = _turbinepump_from_po(po.transition_time),
        minimum_time = _turbinepump_from_po(po.minimum_time),
        travel_time = _or_default(po.travel_time, nothing),
        conversion_factor = _or_default(po.conversion_factor, 1.0),
        commitment_mode = _or_default_enum(po.commitment_mode, CommitmentModes.COMMITTED),
        prime_mover_type = _or_default_enum(po.prime_mover_type, PrimeMovers.PS),
    )
end

function from_openapi(po::PO.HydroPumpTurbine, refs::OpenAPIRefs, ::NaturalUnit)
    return HydroPumpTurbine(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power / po.base_power,
        reactive_power = po.reactive_power / po.base_power,
        rating = po.rating / po.base_power,
        active_power_limits = _minmax_from_po(po.active_power_limits, (/), po.base_power),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits, (/), po.base_power),
        active_power_limits_pump = _minmax_from_po(po.active_power_limits_pump, (/), po.base_power),
        outflow_limits = _minmax_from_po(po.outflow_limits),
        powerhouse_elevation = po.powerhouse_elevation,
        ramp_limits = _updown_from_po(po.ramp_limits, (/), po.base_power),
        time_limits = _updown_from_po(po.time_limits),
        base_power = po.base_power,
        operating_mode = _or_default_enum(po.operating_mode, HydroPumpTurbineStatus.OFF),
        status = _or_default_enum(po.status, OperationalStates.OFFLINE),
        time_at_status = _or_default(po.time_at_status, INFINITE_TIME),
        operation_cost = convert_cost(po.operation_cost.value)::OperationalCost,
        active_power_pump = _or_default(po.active_power_pump, 0.0, (/), po.base_power),
        efficiency = _turbinepump_from_po(po.efficiency),
        transition_time = _turbinepump_from_po(po.transition_time),
        minimum_time = _turbinepump_from_po(po.minimum_time),
        travel_time = _or_default(po.travel_time, nothing),
        conversion_factor = _or_default(po.conversion_factor, 1.0),
        commitment_mode = _or_default_enum(po.commitment_mode, CommitmentModes.COMMITTED),
        prime_mover_type = _or_default_enum(po.prime_mover_type, PrimeMovers.PS),
    )
end

function from_openapi(po::PO.HydroPumpTurbine, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("HydroPumpTurbine", po.id, po.power_units))
end

function to_openapi(value::HydroPumpTurbine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.HydroPumpTurbine(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, CU),
        reactive_power = get_reactive_power(value, CU),
        rating = get_rating(value, CU),
        active_power_limits = _minmax_po(get_active_power_limits(value, CU)),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(value, CU)),
        active_power_limits_pump = _minmax_po(get_active_power_limits_pump(value, CU)),
        outflow_limits = _minmax_po_optional(get_outflow_limits(value)),
        powerhouse_elevation = get_powerhouse_elevation(value),
        ramp_limits = _updown_po_optional(get_ramp_limits(value, CU / u"minute")),
        time_limits = _updown_po_optional(get_time_limits(value)),
        base_power = _get_base_power(value),
        operating_mode = PO.HydroPumpTurbineOperatingMode(string(get_operating_mode(value))),
        status = PO.OperationalStates(string(get_status(value))),
        time_at_status = get_time_at_status(value),
        operation_cost = PO.HydroPumpTurbineOperationCost(convert_cost_to_openapi(get_operation_cost(value))),
        active_power_pump = get_active_power_pump(value, CU),
        efficiency = _turbinepump_po(get_efficiency(value)),
        transition_time = _turbinepump_po(get_transition_time(value)),
        minimum_time = _turbinepump_po(get_minimum_time(value)),
        travel_time = _optional_to_wire(get_travel_time(value)),
        conversion_factor = get_conversion_factor(value),
        commitment_mode = PO.CommitmentModes(string(get_commitment_mode(value))),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(value))),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(value::HydroPumpTurbine, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.HydroPumpTurbine(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, CU) * _get_base_power(value),
        reactive_power = get_reactive_power(value, CU) * _get_base_power(value),
        rating = get_rating(value, CU) * _get_base_power(value),
        active_power_limits = _minmax_po_scaled(get_active_power_limits(value, CU), _get_base_power(value)),
        reactive_power_limits = _minmax_po_scaled_optional(get_reactive_power_limits(value, CU), _get_base_power(value)),
        active_power_limits_pump = _minmax_po_scaled(get_active_power_limits_pump(value, CU), _get_base_power(value)),
        outflow_limits = _minmax_po_optional(get_outflow_limits(value)),
        powerhouse_elevation = get_powerhouse_elevation(value),
        ramp_limits = _updown_po_scaled_optional(get_ramp_limits(value, CU / u"minute"), _get_base_power(value)),
        time_limits = _updown_po_optional(get_time_limits(value)),
        base_power = _get_base_power(value),
        operating_mode = PO.HydroPumpTurbineOperatingMode(string(get_operating_mode(value))),
        status = PO.OperationalStates(string(get_status(value))),
        time_at_status = get_time_at_status(value),
        operation_cost = PO.HydroPumpTurbineOperationCost(convert_cost_to_openapi(get_operation_cost(value))),
        active_power_pump = get_active_power_pump(value, CU) * _get_base_power(value),
        efficiency = _turbinepump_po(get_efficiency(value)),
        transition_time = _turbinepump_po(get_transition_time(value)),
        minimum_time = _turbinepump_po(get_minimum_time(value)),
        travel_time = _optional_to_wire(get_travel_time(value)),
        conversion_factor = get_conversion_factor(value),
        commitment_mode = PO.CommitmentModes(string(get_commitment_mode(value))),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(value))),
        power_units = _power_units_string(NU),
    )
end
