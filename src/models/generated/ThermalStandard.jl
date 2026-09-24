#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ThermalStandard <: ThermalGen
        name::String
        available::Bool
        status::OperationalStates.Value
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
        commitment_mode::CommitmentModes.Value
        prime_mover_type::PrimeMovers.Value
        fuel::ThermalFuels.Value
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
- `status::OperationalStates.Value`: Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used, validation range: `active_power_limits`
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR), validation range: `reactive_power_limits`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power, validation range: `(0, nothing)`
- `active_power_limits::MinMax`: Minimum and maximum stable active power levels (MW), validation range: `(0, nothing)`
- `reactive_power_limits::Union{Nothing, MinMax}`: Minimum and maximum reactive power limits. Set to `Nothing` if not applicable
- `ramp_limits::Union{Nothing, UpDown}`: Ramp up and ramp down limits (MW/min), validation range: `(0, nothing)`
- `operation_cost::OperationalCost`: [`OperationalCost`](@ref) of generation
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `time_limits::Union{Nothing, UpDown}`: (default: `nothing`) Minimum up and Minimum down time limits in minutes, validation range: `(0, nothing)`
- `commitment_mode::CommitmentModes.Value`: (default: `CommitmentModes.COMMITTED`) Commitment mode of the unit. Options are listed [here](@ref commit_list)
- `prime_mover_type::PrimeMovers.Value`: (default: `PrimeMovers.OT`) Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
- `fuel::ThermalFuels.Value`: (default: `ThermalFuels.OTHER`) Prime mover fuel according to EIA 923. Options are listed [here](@ref tf_list)
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `time_at_status::Float64`: (default: `INFINITE_TIME`) Time (e.g., `Minutes(360)`) the generator has been in its current `status`
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
- `input_basis`: (keyword constructor only, required) `u"CU"` or `u"NU"`, the units of bare numbers on unit-bearing fields. Tagged values (`50.0u"MW"`) keep their own units
"""
mutable struct ThermalStandard <: ThermalGen
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)"
    status::OperationalStates.Value
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
    "Ramp up and ramp down limits (MW/min)"
    ramp_limits::Union{Nothing, UpDown}
    "[`OperationalCost`](@ref) of generation"
    operation_cost::OperationalCost
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Minimum up and Minimum down time limits in minutes"
    time_limits::Union{Nothing, UpDown}
    "Commitment mode of the unit. Options are listed [here](@ref commit_list)"
    commitment_mode::CommitmentModes.Value
    "Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)"
    prime_mover_type::PrimeMovers.Value
    "Prime mover fuel according to EIA 923. Options are listed [here](@ref tf_list)"
    fuel::ThermalFuels.Value
    "Services that this device contributes to"
    services::Vector{Service}
    "Time (e.g., `Minutes(360)`) the generator has been in its current `status`"
    time_at_status::Float64
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ThermalStandard(name, available, status, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, ramp_limits, operation_cost, base_power, time_limits=nothing, commitment_mode=CommitmentModes.COMMITTED, prime_mover_type=PrimeMovers.OT, fuel=ThermalFuels.OTHER, services=Device[], time_at_status=INFINITE_TIME, dynamic_injector=nothing, ext=Dict{String, Any}(), )
    ThermalStandard(name, available, status, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, ramp_limits, operation_cost, base_power, time_limits, commitment_mode, prime_mover_type, fuel, services, time_at_status, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function ThermalStandard(; name, available, status, bus, active_power, reactive_power, rating, active_power_limits, reactive_power_limits, ramp_limits, operation_cost, base_power, time_limits=nothing, commitment_mode=CommitmentModes.COMMITTED, prime_mover_type=PrimeMovers.OT, fuel=ThermalFuels.OTHER, services=Device[], time_at_status=INFINITE_TIME, dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), input_basis::Unitful.Units, )
    value = ThermalStandard(name, available, status, bus, _placeholder(active_power), _placeholder(reactive_power), _placeholder(rating), _placeholder(active_power_limits), _placeholder(reactive_power_limits), _placeholder(ramp_limits), operation_cost, base_power, time_limits, commitment_mode, prime_mover_type, fuel, services, time_at_status, dynamic_injector, ext, internal, )
    set_active_power!(value, _tag(active_power, input_basis, Val(:mw)))
    set_reactive_power!(value, _tag(reactive_power, input_basis, Val(:mvar)))
    set_rating!(value, _tag(rating, input_basis, Val(:mva)))
    set_active_power_limits!(value, _tag(active_power_limits, input_basis, Val(:mw)))
    set_reactive_power_limits!(value, _tag(reactive_power_limits, input_basis, Val(:mvar)))
    set_ramp_limits!(value, _tag(ramp_limits, input_basis, Val(:mw_per_minute)))
    return value
end
_takes_input_basis(::Type{<:ThermalStandard}) = true

# Constructor for demo purposes; non-functional.
function ThermalStandard(::Nothing)
    ThermalStandard(;
        name="init",
        available=false,
        status=OperationalStates.OFFLINE,
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
        commitment_mode=CommitmentModes.UNCOMMITTED,
        prime_mover_type=PrimeMovers.OT,
        fuel=ThermalFuels.OTHER,
        services=Device[],
        time_at_status=INFINITE_TIME,
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
        input_basis=u"CU",
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
"""Get [`ThermalStandard`](@ref) `active_power` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::ThermalStandard, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`ThermalStandard`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::ThermalStandard, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::ThermalStandard) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::ThermalStandard) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{ThermalStandard}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{ThermalStandard}) = u"SU"
"""Get [`ThermalStandard`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::ThermalStandard, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`ThermalStandard`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::ThermalStandard, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::ThermalStandard) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::ThermalStandard) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{ThermalStandard}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{ThermalStandard}) = u"SU"
"""Get [`ThermalStandard`](@ref) `rating` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::ThermalStandard, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`ThermalStandard`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::ThermalStandard, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::ThermalStandard) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::ThermalStandard) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{ThermalStandard}) = u"CU"
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{ThermalStandard}) = u"CU"
"""Get [`ThermalStandard`](@ref) `active_power_limits` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_active_power_limits_unitful`](@ref)."""
get_active_power_limits(value::ThermalStandard, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits), Val(:mw), units))
"""Get [`ThermalStandard`](@ref) `active_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_active_power_limits`](@ref)."""
get_active_power_limits_unitful(value::ThermalStandard, units) = get_value(value, Val(:active_power_limits), Val(:mw), units)
get_active_power_limits(value::ThermalStandard) = _units_arg_required(get_active_power_limits, value, :active_power_limits, Val(:mw))
get_active_power_limits_unitful(value::ThermalStandard) = _units_arg_required(get_active_power_limits_unitful, value, :active_power_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits), ::Type{ThermalStandard}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_unitful), ::Type{ThermalStandard}) = u"SU"
"""Get [`ThermalStandard`](@ref) `reactive_power_limits` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_reactive_power_limits_unitful`](@ref)."""
get_reactive_power_limits(value::ThermalStandard, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits), Val(:mvar), units))
"""Get [`ThermalStandard`](@ref) `reactive_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_reactive_power_limits`](@ref)."""
get_reactive_power_limits_unitful(value::ThermalStandard, units) = get_value(value, Val(:reactive_power_limits), Val(:mvar), units)
get_reactive_power_limits(value::ThermalStandard) = _units_arg_required(get_reactive_power_limits, value, :reactive_power_limits, Val(:mvar))
get_reactive_power_limits_unitful(value::ThermalStandard) = _units_arg_required(get_reactive_power_limits_unitful, value, :reactive_power_limits, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits), ::Type{ThermalStandard}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_unitful), ::Type{ThermalStandard}) = u"SU"
"""Get [`ThermalStandard`](@ref) `ramp_limits` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_ramp_limits_unitful`](@ref)."""
get_ramp_limits(value::ThermalStandard, units) = InfrastructureSystems._strip_units(get_value(value, Val(:ramp_limits), Val(:mw_per_minute), units))
"""Get [`ThermalStandard`](@ref) `ramp_limits` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_ramp_limits`](@ref)."""
get_ramp_limits_unitful(value::ThermalStandard, units) = get_value(value, Val(:ramp_limits), Val(:mw_per_minute), units)
get_ramp_limits(value::ThermalStandard) = _units_arg_required(get_ramp_limits, value, :ramp_limits, Val(:mw_per_minute))
get_ramp_limits_unitful(value::ThermalStandard) = _units_arg_required(get_ramp_limits_unitful, value, :ramp_limits, Val(:mw_per_minute))
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits), ::Type{ThermalStandard}) = u"SU/minute"
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits_unitful), ::Type{ThermalStandard}) = u"SU/minute"
"""Get [`ThermalStandard`](@ref) `operation_cost`."""
get_operation_cost(value::ThermalStandard) = value.operation_cost

_get_base_power(value::ThermalStandard) = value.base_power
"""Get [`ThermalStandard`](@ref) `time_limits`."""
get_time_limits(value::ThermalStandard) = value.time_limits
"""Get [`ThermalStandard`](@ref) `commitment_mode`."""
get_commitment_mode(value::ThermalStandard) = value.commitment_mode
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
set_active_power!(value::ThermalStandard, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::ThermalStandard, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`ThermalStandard`](@ref) `reactive_power`."""
set_reactive_power!(value::ThermalStandard, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::ThermalStandard, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`ThermalStandard`](@ref) `rating`."""
set_rating!(value::ThermalStandard, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::ThermalStandard, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`ThermalStandard`](@ref) `active_power_limits`."""
set_active_power_limits!(value::ThermalStandard, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mw))
set_active_power_limits!(value::ThermalStandard, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
set_active_power_limits!(value::ThermalStandard, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
"""Set [`ThermalStandard`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::ThermalStandard, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mvar))
set_reactive_power_limits!(value::ThermalStandard, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
set_reactive_power_limits!(value::ThermalStandard, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
"""Set [`ThermalStandard`](@ref) `ramp_limits`."""
set_ramp_limits!(value::ThermalStandard, val) = value.ramp_limits = set_value(value, Val(:ramp_limits), val, Val(:mw_per_minute))
set_ramp_limits!(value::ThermalStandard, val::_UntaggedNumber) = _units_tag_required(set_ramp_limits!, value, :ramp_limits, Val(:mw_per_minute), val)
set_ramp_limits!(value::ThermalStandard, val::NamedTuple{(:up, :down), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_ramp_limits!, value, :ramp_limits, Val(:mw_per_minute), val)
"""Set [`ThermalStandard`](@ref) `operation_cost`."""
set_operation_cost!(value::ThermalStandard, val) = value.operation_cost = val
"""Set [`ThermalStandard`](@ref) `time_limits`."""
set_time_limits!(value::ThermalStandard, val) = value.time_limits = val
"""Set [`ThermalStandard`](@ref) `commitment_mode`."""
set_commitment_mode!(value::ThermalStandard, val) = value.commitment_mode = val
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


function from_openapi(po::PO.ThermalStandard, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return ThermalStandard(;
        name = po.name,
        available = po.available,
        status = OperationalStates.Value(po.status.value),
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power,
        reactive_power = po.reactive_power,
        rating = po.rating,
        active_power_limits = _minmax_from_po(po.active_power_limits),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits),
        ramp_limits = _updown_from_po(po.ramp_limits),
        operation_cost = convert_cost(po.operation_cost.value)::OperationalCost,
        base_power = po.base_power,
        time_limits = _updown_from_po(po.time_limits),
        commitment_mode = _or_default_enum(po.commitment_mode, CommitmentModes.COMMITTED),
        prime_mover_type = _or_default_enum(po.prime_mover_type, PrimeMovers.OT),
        fuel = _or_default_enum(po.fuel, ThermalFuels.OTHER),
        time_at_status = _or_default(po.time_at_status, INFINITE_TIME),
        input_basis = u"CU",
    )
end

function from_openapi(po::PO.ThermalStandard, refs::OpenAPIRefs, ::NaturalUnit)
    return ThermalStandard(;
        name = po.name,
        available = po.available,
        status = OperationalStates.Value(po.status.value),
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power / po.base_power,
        reactive_power = po.reactive_power / po.base_power,
        rating = po.rating / po.base_power,
        active_power_limits = _minmax_from_po(po.active_power_limits, (/), po.base_power),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits, (/), po.base_power),
        ramp_limits = _updown_from_po(po.ramp_limits, (/), po.base_power),
        operation_cost = convert_cost(po.operation_cost.value)::OperationalCost,
        base_power = po.base_power,
        time_limits = _updown_from_po(po.time_limits),
        commitment_mode = _or_default_enum(po.commitment_mode, CommitmentModes.COMMITTED),
        prime_mover_type = _or_default_enum(po.prime_mover_type, PrimeMovers.OT),
        fuel = _or_default_enum(po.fuel, ThermalFuels.OTHER),
        time_at_status = _or_default(po.time_at_status, INFINITE_TIME),
        input_basis = u"CU",
    )
end

function from_openapi(po::PO.ThermalStandard, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("ThermalStandard", po.id, po.power_units))
end

function to_openapi(value::ThermalStandard, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.ThermalStandard(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        status = PO.OperationalStates(string(get_status(value))),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, u"CU"),
        reactive_power = get_reactive_power(value, u"CU"),
        rating = get_rating(value, u"CU"),
        active_power_limits = _minmax_po(get_active_power_limits(value, u"CU")),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(value, u"CU")),
        ramp_limits = _updown_po_optional(get_ramp_limits(value, u"CU/minute")),
        operation_cost = PO.ThermalStandardOperationCost(convert_cost_to_openapi(get_operation_cost(value))),
        base_power = _get_base_power(value),
        time_limits = _updown_po_optional(get_time_limits(value)),
        commitment_mode = PO.CommitmentModes(string(get_commitment_mode(value))),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(value))),
        fuel = PO.ThermalFuels(string(get_fuel(value))),
        time_at_status = get_time_at_status(value),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(value::ThermalStandard, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.ThermalStandard(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        status = PO.OperationalStates(string(get_status(value))),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, u"CU") * _get_base_power(value),
        reactive_power = get_reactive_power(value, u"CU") * _get_base_power(value),
        rating = get_rating(value, u"CU") * _get_base_power(value),
        active_power_limits = _minmax_po_scaled(get_active_power_limits(value, u"CU"), _get_base_power(value)),
        reactive_power_limits = _minmax_po_scaled_optional(get_reactive_power_limits(value, u"CU"), _get_base_power(value)),
        ramp_limits = _updown_po_scaled_optional(get_ramp_limits(value, u"CU/minute"), _get_base_power(value)),
        operation_cost = PO.ThermalStandardOperationCost(convert_cost_to_openapi(get_operation_cost(value))),
        base_power = _get_base_power(value),
        time_limits = _updown_po_optional(get_time_limits(value)),
        commitment_mode = PO.CommitmentModes(string(get_commitment_mode(value))),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(value))),
        fuel = PO.ThermalFuels(string(get_fuel(value))),
        time_at_status = get_time_at_status(value),
        power_units = _power_units_string(NU),
    )
end
