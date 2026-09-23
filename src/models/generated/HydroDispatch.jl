#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct HydroDispatch <: HydroGen
        name::String
        available::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        rating::Float64
        prime_mover_type::PrimeMovers.Value
        active_power_limits::MinMax
        reactive_power_limits::Union{Nothing, MinMax}
        ramp_limits::Union{Nothing, UpDown}
        time_limits::Union{Nothing, UpDown}
        base_power::Float64
        status::OperationalStates.Value
        time_at_status::Float64
        operation_cost::OperationalCost
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A hydropower generator without a reservoir, suitable for modeling run-of-river hydropower.

For hydro generators with an upper reservoir, see [`HydroReservoir`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR), validation range: `reactive_power_limits`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power, validation range: `(0, nothing)`
- `prime_mover_type::PrimeMovers.Value`: Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
- `active_power_limits::MinMax`: Minimum and maximum stable active power levels (MW), validation range: `(0, nothing)`
- `reactive_power_limits::Union{Nothing, MinMax}`: Minimum and maximum reactive power limits. Set to `Nothing` if not applicable
- `ramp_limits::Union{Nothing, UpDown}`: Ramp up and ramp down limits (MW/min), validation range: `(0, nothing)`
- `time_limits::Union{Nothing, UpDown}`: Minimum up and Minimum down time limits in minutes, validation range: `(0, nothing)`
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `status::OperationalStates.Value`: (default: `OperationalStates.OFFLINE`) Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)
- `time_at_status::Float64`: (default: `INFINITE_TIME`) Time (e.g., `Minutes(360)`) the generator has been on or off, as indicated by `status`
- `operation_cost::OperationalCost`: (default: `HydroGenerationCost(nothing)`) [`OperationalCost`](@ref) of generation
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
- `input_basis`: (keyword constructor only, required) `CU` or `NU`, the units of bare numbers on unit-bearing fields. Tagged values (`50.0u"MW"`) keep their own units
"""
mutable struct HydroDispatch <: HydroGen
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
    "Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)"
    prime_mover_type::PrimeMovers.Value
    "Minimum and maximum stable active power levels (MW)"
    active_power_limits::MinMax
    "Minimum and maximum reactive power limits. Set to `Nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "Ramp up and ramp down limits (MW/min)"
    ramp_limits::Union{Nothing, UpDown}
    "Minimum up and Minimum down time limits in minutes"
    time_limits::Union{Nothing, UpDown}
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)"
    status::OperationalStates.Value
    "Time (e.g., `Minutes(360)`) the generator has been on or off, as indicated by `status`"
    time_at_status::Float64
    "[`OperationalCost`](@ref) of generation"
    operation_cost::OperationalCost
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function HydroDispatch(name, available, bus, active_power, reactive_power, rating, prime_mover_type, active_power_limits, reactive_power_limits, ramp_limits, time_limits, base_power, status=OperationalStates.OFFLINE, time_at_status=INFINITE_TIME, operation_cost=HydroGenerationCost(nothing), services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    HydroDispatch(name, available, bus, active_power, reactive_power, rating, prime_mover_type, active_power_limits, reactive_power_limits, ramp_limits, time_limits, base_power, status, time_at_status, operation_cost, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function HydroDispatch(; name, available, bus, active_power, reactive_power, rating, prime_mover_type, active_power_limits, reactive_power_limits, ramp_limits, time_limits, base_power, status=OperationalStates.OFFLINE, time_at_status=INFINITE_TIME, operation_cost=HydroGenerationCost(nothing), services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), input_basis::Union{ComponentBaseUnit, NaturalUnit}, )
    value = HydroDispatch(name, available, bus, _placeholder(active_power), _placeholder(reactive_power), _placeholder(rating), prime_mover_type, _placeholder(active_power_limits), _placeholder(reactive_power_limits), _placeholder(ramp_limits), time_limits, base_power, status, time_at_status, operation_cost, services, dynamic_injector, ext, internal, )
    set_active_power!(value, _tag(active_power, input_basis, Val(:mw)))
    set_reactive_power!(value, _tag(reactive_power, input_basis, Val(:mvar)))
    set_rating!(value, _tag(rating, input_basis, Val(:mva)))
    set_active_power_limits!(value, _tag(active_power_limits, input_basis, Val(:mw)))
    set_reactive_power_limits!(value, _tag(reactive_power_limits, input_basis, Val(:mvar)))
    set_ramp_limits!(value, _tag(ramp_limits, input_basis, Val(:mw_per_minute)))
    return value
end
_takes_input_basis(::Type{<:HydroDispatch}) = true

# Constructor for demo purposes; non-functional.
function HydroDispatch(::Nothing)
    HydroDispatch(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        rating=0.0,
        prime_mover_type=PrimeMovers.HY,
        active_power_limits=(min=0.0, max=0.0),
        reactive_power_limits=nothing,
        ramp_limits=nothing,
        time_limits=nothing,
        base_power=100.0,
        status=OperationalStates.OFFLINE,
        time_at_status=INFINITE_TIME,
        operation_cost=HydroGenerationCost(nothing),
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
        input_basis=CU,
    )
end

"""Get [`HydroDispatch`](@ref) `name`."""
get_name(value::HydroDispatch) = value.name
"""Get [`HydroDispatch`](@ref) `available`."""
get_available(value::HydroDispatch) = value.available
"""Get [`HydroDispatch`](@ref) `bus`."""
get_bus(value::HydroDispatch) = value.bus
"""Get [`HydroDispatch`](@ref) `active_power` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::HydroDispatch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`HydroDispatch`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::HydroDispatch, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::HydroDispatch) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::HydroDispatch) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{HydroDispatch}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{HydroDispatch}) = InfrastructureSystems.SU
"""Get [`HydroDispatch`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::HydroDispatch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`HydroDispatch`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::HydroDispatch, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::HydroDispatch) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::HydroDispatch) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{HydroDispatch}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{HydroDispatch}) = InfrastructureSystems.SU
"""Get [`HydroDispatch`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::HydroDispatch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`HydroDispatch`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::HydroDispatch, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::HydroDispatch) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::HydroDispatch) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{HydroDispatch}) = InfrastructureSystems.CU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{HydroDispatch}) = InfrastructureSystems.CU
"""Get [`HydroDispatch`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::HydroDispatch) = value.prime_mover_type
"""Get [`HydroDispatch`](@ref) `active_power_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_limits_unitful`](@ref)."""
get_active_power_limits(value::HydroDispatch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits), Val(:mw), units))
"""Get [`HydroDispatch`](@ref) `active_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_active_power_limits`](@ref)."""
get_active_power_limits_unitful(value::HydroDispatch, units) = get_value(value, Val(:active_power_limits), Val(:mw), units)
get_active_power_limits(value::HydroDispatch) = _units_arg_required(get_active_power_limits, value, :active_power_limits, Val(:mw))
get_active_power_limits_unitful(value::HydroDispatch) = _units_arg_required(get_active_power_limits_unitful, value, :active_power_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits), ::Type{HydroDispatch}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_unitful), ::Type{HydroDispatch}) = InfrastructureSystems.SU
"""Get [`HydroDispatch`](@ref) `reactive_power_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_unitful`](@ref)."""
get_reactive_power_limits(value::HydroDispatch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits), Val(:mvar), units))
"""Get [`HydroDispatch`](@ref) `reactive_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_reactive_power_limits`](@ref)."""
get_reactive_power_limits_unitful(value::HydroDispatch, units) = get_value(value, Val(:reactive_power_limits), Val(:mvar), units)
get_reactive_power_limits(value::HydroDispatch) = _units_arg_required(get_reactive_power_limits, value, :reactive_power_limits, Val(:mvar))
get_reactive_power_limits_unitful(value::HydroDispatch) = _units_arg_required(get_reactive_power_limits_unitful, value, :reactive_power_limits, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits), ::Type{HydroDispatch}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_unitful), ::Type{HydroDispatch}) = InfrastructureSystems.SU
"""Get [`HydroDispatch`](@ref) `ramp_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_ramp_limits_unitful`](@ref)."""
get_ramp_limits(value::HydroDispatch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:ramp_limits), Val(:mw_per_minute), units))
"""Get [`HydroDispatch`](@ref) `ramp_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_ramp_limits`](@ref)."""
get_ramp_limits_unitful(value::HydroDispatch, units) = get_value(value, Val(:ramp_limits), Val(:mw_per_minute), units)
get_ramp_limits(value::HydroDispatch) = _units_arg_required(get_ramp_limits, value, :ramp_limits, Val(:mw_per_minute))
get_ramp_limits_unitful(value::HydroDispatch) = _units_arg_required(get_ramp_limits_unitful, value, :ramp_limits, Val(:mw_per_minute))
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits), ::Type{HydroDispatch}) = SU / u"minute"
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits_unitful), ::Type{HydroDispatch}) = SU / u"minute"
"""Get [`HydroDispatch`](@ref) `time_limits`."""
get_time_limits(value::HydroDispatch) = value.time_limits

_get_base_power(value::HydroDispatch) = value.base_power
"""Get [`HydroDispatch`](@ref) `status`."""
get_status(value::HydroDispatch) = value.status
"""Get [`HydroDispatch`](@ref) `time_at_status`."""
get_time_at_status(value::HydroDispatch) = value.time_at_status
"""Get [`HydroDispatch`](@ref) `operation_cost`."""
get_operation_cost(value::HydroDispatch) = value.operation_cost
"""Get [`HydroDispatch`](@ref) `services`."""
get_services(value::HydroDispatch) = value.services
"""Get [`HydroDispatch`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::HydroDispatch) = value.dynamic_injector
"""Get [`HydroDispatch`](@ref) `ext`."""
get_ext(value::HydroDispatch) = value.ext
"""Get [`HydroDispatch`](@ref) `internal`."""
get_internal(value::HydroDispatch) = value.internal

"""Set [`HydroDispatch`](@ref) `available`."""
set_available!(value::HydroDispatch, val) = value.available = val
"""Set [`HydroDispatch`](@ref) `bus`."""
set_bus!(value::HydroDispatch, val) = value.bus = val
"""Set [`HydroDispatch`](@ref) `active_power`."""
set_active_power!(value::HydroDispatch, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::HydroDispatch, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`HydroDispatch`](@ref) `reactive_power`."""
set_reactive_power!(value::HydroDispatch, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::HydroDispatch, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`HydroDispatch`](@ref) `rating`."""
set_rating!(value::HydroDispatch, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::HydroDispatch, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`HydroDispatch`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::HydroDispatch, val) = value.prime_mover_type = val
"""Set [`HydroDispatch`](@ref) `active_power_limits`."""
set_active_power_limits!(value::HydroDispatch, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mw))
set_active_power_limits!(value::HydroDispatch, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
set_active_power_limits!(value::HydroDispatch, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
"""Set [`HydroDispatch`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::HydroDispatch, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mvar))
set_reactive_power_limits!(value::HydroDispatch, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
set_reactive_power_limits!(value::HydroDispatch, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
"""Set [`HydroDispatch`](@ref) `ramp_limits`."""
set_ramp_limits!(value::HydroDispatch, val) = value.ramp_limits = set_value(value, Val(:ramp_limits), val, Val(:mw_per_minute))
set_ramp_limits!(value::HydroDispatch, val::_UntaggedNumber) = _units_tag_required(set_ramp_limits!, value, :ramp_limits, Val(:mw_per_minute), val)
set_ramp_limits!(value::HydroDispatch, val::NamedTuple{(:up, :down), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_ramp_limits!, value, :ramp_limits, Val(:mw_per_minute), val)
"""Set [`HydroDispatch`](@ref) `time_limits`."""
set_time_limits!(value::HydroDispatch, val) = value.time_limits = val
"""Set [`HydroDispatch`](@ref) `status`."""
set_status!(value::HydroDispatch, val) = value.status = val
"""Set [`HydroDispatch`](@ref) `time_at_status`."""
set_time_at_status!(value::HydroDispatch, val) = value.time_at_status = val
"""Set [`HydroDispatch`](@ref) `operation_cost`."""
set_operation_cost!(value::HydroDispatch, val) = value.operation_cost = val
"""Set [`HydroDispatch`](@ref) `services`."""
set_services!(value::HydroDispatch, val) = value.services = val
"""Set [`HydroDispatch`](@ref) `ext`."""
set_ext!(value::HydroDispatch, val) = value.ext = val


function from_openapi(po::PO.HydroDispatch, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return HydroDispatch(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power,
        reactive_power = po.reactive_power,
        rating = po.rating,
        prime_mover_type = PrimeMovers.Value(po.prime_mover_type.value),
        active_power_limits = _minmax_from_po(po.active_power_limits),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits),
        ramp_limits = _updown_from_po(po.ramp_limits),
        time_limits = _updown_from_po(po.time_limits),
        base_power = po.base_power,
        status = _or_default_enum(po.status, OperationalStates.OFFLINE),
        time_at_status = _or_default(po.time_at_status, INFINITE_TIME),
        operation_cost = convert_cost(po.operation_cost.value)::OperationalCost,
        input_basis = CU,
    )
end

function from_openapi(po::PO.HydroDispatch, refs::OpenAPIRefs, ::NaturalUnit)
    return HydroDispatch(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power / po.base_power,
        reactive_power = po.reactive_power / po.base_power,
        rating = po.rating / po.base_power,
        prime_mover_type = PrimeMovers.Value(po.prime_mover_type.value),
        active_power_limits = _minmax_from_po(po.active_power_limits, (/), po.base_power),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits, (/), po.base_power),
        ramp_limits = _updown_from_po(po.ramp_limits, (/), po.base_power),
        time_limits = _updown_from_po(po.time_limits),
        base_power = po.base_power,
        status = _or_default_enum(po.status, OperationalStates.OFFLINE),
        time_at_status = _or_default(po.time_at_status, INFINITE_TIME),
        operation_cost = convert_cost(po.operation_cost.value)::OperationalCost,
        input_basis = CU,
    )
end

function from_openapi(po::PO.HydroDispatch, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("HydroDispatch", po.id, po.power_units))
end

function to_openapi(value::HydroDispatch, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.HydroDispatch(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, CU),
        reactive_power = get_reactive_power(value, CU),
        rating = get_rating(value, CU),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(value))),
        active_power_limits = _minmax_po(get_active_power_limits(value, CU)),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(value, CU)),
        ramp_limits = _updown_po_optional(get_ramp_limits(value, CU / u"minute")),
        time_limits = _updown_po_optional(get_time_limits(value)),
        base_power = _get_base_power(value),
        status = PO.OperationalStates(string(get_status(value))),
        time_at_status = get_time_at_status(value),
        operation_cost = PO.HydroDispatchOperationCost(convert_cost_to_openapi(get_operation_cost(value))),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(value::HydroDispatch, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.HydroDispatch(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, CU) * _get_base_power(value),
        reactive_power = get_reactive_power(value, CU) * _get_base_power(value),
        rating = get_rating(value, CU) * _get_base_power(value),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(value))),
        active_power_limits = _minmax_po_scaled(get_active_power_limits(value, CU), _get_base_power(value)),
        reactive_power_limits = _minmax_po_scaled_optional(get_reactive_power_limits(value, CU), _get_base_power(value)),
        ramp_limits = _updown_po_scaled_optional(get_ramp_limits(value, CU / u"minute"), _get_base_power(value)),
        time_limits = _updown_po_optional(get_time_limits(value)),
        base_power = _get_base_power(value),
        status = PO.OperationalStates(string(get_status(value))),
        time_at_status = get_time_at_status(value),
        operation_cost = PO.HydroDispatchOperationCost(convert_cost_to_openapi(get_operation_cost(value))),
        power_units = _power_units_string(NU),
    )
end
