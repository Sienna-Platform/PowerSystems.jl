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
        prime_mover_type::PrimeMovers.Value
        reactive_power_limits::Union{Nothing, MinMax}
        power_factor::Float64
        operation_cost::OperationalCost
        base_power::Float64
        remote_regulated_bus::Union{Nothing, ACBus}
        voltage_setpoint::Float64
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A renewable (e.g., wind or solar) generator whose output can be curtailed to satisfy power system constraints.

These generators can also participate in reserves markets, including upwards reserves by proactively curtailing some available power (based on its [`max_active_power` time series](@ref ts_data)). Example uses include: a utility-scale wind or solar generator whose PPA allows curtailment. For non-curtailable or must-take renewables, see [`RenewableNonDispatch`](@ref).

Renewable generators do not have a `max_active_power` parameter, which is instead calculated when calling [`get_max_active_power()`](@ref get_max_active_power(d::T) where {T <: RenewableGen})

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR), used in some production cost modeling simulations. To set the reactive power in a load flow, use `power_factor`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power, validation range: `(0, nothing)`
- `prime_mover_type::PrimeMovers.Value`: Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
- `reactive_power_limits::Union{Nothing, MinMax}`: Minimum and maximum reactive power limits, used in some production cost model simulations and in power flow if the unit is connected to a [`PV`](@ref acbustypes_list) bus. Set to `nothing` if not applicable
- `power_factor::Float64`: Power factor [0, 1] set-point, used in some production cost modeling and in load flow if the unit is connected to a [`PQ`](@ref acbustypes_list) bus, validation range: `(0, 1)`
- `operation_cost::OperationalCost`: [`OperationalCost`](@ref) of generation
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `remote_regulated_bus::Union{Nothing, ACBus}`: (default: `nothing`) Bus whose voltage this unit regulates when it is not its own `bus`; `nothing` means the unit regulates `bus`, and a value equal to `bus` is invalid. An available [`VoltageDroopControl`](@ref) the unit belongs to overrides this target; [`get_regulated_bus`](@ref) resolves it
- `voltage_setpoint::Float64`: (default: `1.0`) Voltage magnitude the unit holds at the bus it regulates, in per-unit of that bus's `base_voltage`, while the type of its own bus marks it as voltage regulating. Ignored while the unit belongs to an available [`VoltageDroopControl`](@ref), validation range: `(0, nothing)`
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
- `input_basis`: (keyword constructor only, required) `CU` or `NU`, the units of bare numbers on unit-bearing fields. Tagged values (`50.0u"MW"`) keep their own units
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
    prime_mover_type::PrimeMovers.Value
    "Minimum and maximum reactive power limits, used in some production cost model simulations and in power flow if the unit is connected to a [`PV`](@ref acbustypes_list) bus. Set to `nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "Power factor [0, 1] set-point, used in some production cost modeling and in load flow if the unit is connected to a [`PQ`](@ref acbustypes_list) bus"
    power_factor::Float64
    "[`OperationalCost`](@ref) of generation"
    operation_cost::OperationalCost
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Bus whose voltage this unit regulates when it is not its own `bus`; `nothing` means the unit regulates `bus`, and a value equal to `bus` is invalid. An available [`VoltageDroopControl`](@ref) the unit belongs to overrides this target; [`get_regulated_bus`](@ref) resolves it"
    remote_regulated_bus::Union{Nothing, ACBus}
    "Voltage magnitude the unit holds at the bus it regulates, in per-unit of that bus's `base_voltage`, while the type of its own bus marks it as voltage regulating. Ignored while the unit belongs to an available [`VoltageDroopControl`](@ref)"
    voltage_setpoint::Float64
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function RenewableDispatch(name, available, bus, active_power, reactive_power, rating, prime_mover_type, reactive_power_limits, power_factor, operation_cost, base_power, remote_regulated_bus=nothing, voltage_setpoint=1.0, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    RenewableDispatch(name, available, bus, active_power, reactive_power, rating, prime_mover_type, reactive_power_limits, power_factor, operation_cost, base_power, remote_regulated_bus, voltage_setpoint, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function RenewableDispatch(; name, available, bus, active_power, reactive_power, rating, prime_mover_type, reactive_power_limits, power_factor, operation_cost, base_power, remote_regulated_bus=nothing, voltage_setpoint=1.0, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), input_basis::Union{ComponentBaseUnit, NaturalUnit}, )
    value = RenewableDispatch(name, available, bus, _placeholder(active_power), _placeholder(reactive_power), _placeholder(rating), prime_mover_type, _placeholder(reactive_power_limits), power_factor, operation_cost, base_power, remote_regulated_bus, voltage_setpoint, services, dynamic_injector, ext, internal, )
    set_active_power!(value, _tag(active_power, input_basis, Val(:mw)))
    set_reactive_power!(value, _tag(reactive_power, input_basis, Val(:mvar)))
    set_rating!(value, _tag(rating, input_basis, Val(:mva)))
    set_reactive_power_limits!(value, _tag(reactive_power_limits, input_basis, Val(:mvar)))
    return value
end
_takes_input_basis(::Type{<:RenewableDispatch}) = true

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
        remote_regulated_bus=nothing,
        voltage_setpoint=1.0,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
        input_basis=CU,
    )
end

"""Get [`RenewableDispatch`](@ref) `name`."""
get_name(value::RenewableDispatch) = value.name
"""Get [`RenewableDispatch`](@ref) `available`."""
get_available(value::RenewableDispatch) = value.available
"""Get [`RenewableDispatch`](@ref) `bus`."""
get_bus(value::RenewableDispatch) = value.bus
"""Get [`RenewableDispatch`](@ref) `active_power` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::RenewableDispatch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`RenewableDispatch`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::RenewableDispatch, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::RenewableDispatch) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::RenewableDispatch) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{RenewableDispatch}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{RenewableDispatch}) = InfrastructureSystems.SU
"""Get [`RenewableDispatch`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::RenewableDispatch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`RenewableDispatch`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::RenewableDispatch, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::RenewableDispatch) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::RenewableDispatch) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{RenewableDispatch}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{RenewableDispatch}) = InfrastructureSystems.SU
"""Get [`RenewableDispatch`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::RenewableDispatch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`RenewableDispatch`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::RenewableDispatch, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::RenewableDispatch) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::RenewableDispatch) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{RenewableDispatch}) = InfrastructureSystems.CU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{RenewableDispatch}) = InfrastructureSystems.CU
"""Get [`RenewableDispatch`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::RenewableDispatch) = value.prime_mover_type
"""Get [`RenewableDispatch`](@ref) `reactive_power_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_unitful`](@ref)."""
get_reactive_power_limits(value::RenewableDispatch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits), Val(:mvar), units))
"""Get [`RenewableDispatch`](@ref) `reactive_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_reactive_power_limits`](@ref)."""
get_reactive_power_limits_unitful(value::RenewableDispatch, units) = get_value(value, Val(:reactive_power_limits), Val(:mvar), units)
get_reactive_power_limits(value::RenewableDispatch) = _units_arg_required(get_reactive_power_limits, value, :reactive_power_limits, Val(:mvar))
get_reactive_power_limits_unitful(value::RenewableDispatch) = _units_arg_required(get_reactive_power_limits_unitful, value, :reactive_power_limits, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits), ::Type{RenewableDispatch}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_unitful), ::Type{RenewableDispatch}) = InfrastructureSystems.SU
"""Get [`RenewableDispatch`](@ref) `power_factor`."""
get_power_factor(value::RenewableDispatch) = value.power_factor
"""Get [`RenewableDispatch`](@ref) `operation_cost`."""
get_operation_cost(value::RenewableDispatch) = value.operation_cost

_get_base_power(value::RenewableDispatch) = value.base_power
"""Get [`RenewableDispatch`](@ref) `remote_regulated_bus`."""
get_remote_regulated_bus(value::RenewableDispatch) = value.remote_regulated_bus
"""Get [`RenewableDispatch`](@ref) `voltage_setpoint`."""
get_voltage_setpoint(value::RenewableDispatch) = value.voltage_setpoint
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
set_active_power!(value::RenewableDispatch, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::RenewableDispatch, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`RenewableDispatch`](@ref) `reactive_power`."""
set_reactive_power!(value::RenewableDispatch, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::RenewableDispatch, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`RenewableDispatch`](@ref) `rating`."""
set_rating!(value::RenewableDispatch, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::RenewableDispatch, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`RenewableDispatch`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::RenewableDispatch, val) = value.prime_mover_type = val
"""Set [`RenewableDispatch`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::RenewableDispatch, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mvar))
set_reactive_power_limits!(value::RenewableDispatch, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
set_reactive_power_limits!(value::RenewableDispatch, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
"""Set [`RenewableDispatch`](@ref) `power_factor`."""
set_power_factor!(value::RenewableDispatch, val) = value.power_factor = val
"""Set [`RenewableDispatch`](@ref) `operation_cost`."""
set_operation_cost!(value::RenewableDispatch, val) = value.operation_cost = val
"""Set [`RenewableDispatch`](@ref) `remote_regulated_bus`."""
set_remote_regulated_bus!(value::RenewableDispatch, val) = value.remote_regulated_bus = val
"""Set [`RenewableDispatch`](@ref) `voltage_setpoint`."""
set_voltage_setpoint!(value::RenewableDispatch, val) = value.voltage_setpoint = val
"""Set [`RenewableDispatch`](@ref) `services`."""
set_services!(value::RenewableDispatch, val) = value.services = val
"""Set [`RenewableDispatch`](@ref) `ext`."""
set_ext!(value::RenewableDispatch, val) = value.ext = val


function from_openapi(po::PO.RenewableDispatch, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return RenewableDispatch(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power,
        reactive_power = po.reactive_power,
        rating = po.rating,
        prime_mover_type = PrimeMovers.Value(po.prime_mover_type.value),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits),
        power_factor = po.power_factor,
        operation_cost = convert_cost(po.operation_cost.value)::OperationalCost,
        base_power = po.base_power,
        remote_regulated_bus = resolve_ref(refs, po.remote_regulated_bus_id, ACBus),
        voltage_setpoint = (_require_unit_basis(po.voltage_setpoint_units, "COMPONENT_BASE", "RenewableDispatch.voltage_setpoint_units", po.id); _or_default(po.voltage_setpoint, 1.0)),
        input_basis = CU,
    )
end

function from_openapi(po::PO.RenewableDispatch, refs::OpenAPIRefs, ::NaturalUnit)
    return RenewableDispatch(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = po.active_power / po.base_power,
        reactive_power = po.reactive_power / po.base_power,
        rating = po.rating / po.base_power,
        prime_mover_type = PrimeMovers.Value(po.prime_mover_type.value),
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits, (/), po.base_power),
        power_factor = po.power_factor,
        operation_cost = convert_cost(po.operation_cost.value)::OperationalCost,
        base_power = po.base_power,
        remote_regulated_bus = resolve_ref(refs, po.remote_regulated_bus_id, ACBus),
        voltage_setpoint = (_require_unit_basis(po.voltage_setpoint_units, "COMPONENT_BASE", "RenewableDispatch.voltage_setpoint_units", po.id); _or_default(po.voltage_setpoint, 1.0)),
        input_basis = CU,
    )
end

function from_openapi(po::PO.RenewableDispatch, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("RenewableDispatch", po.id, po.power_units))
end

function to_openapi(value::RenewableDispatch, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.RenewableDispatch(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, CU),
        reactive_power = get_reactive_power(value, CU),
        rating = get_rating(value, CU),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(value))),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(value, CU)),
        power_factor = get_power_factor(value),
        operation_cost = PO.RenewableDispatchOperationCost(convert_cost_to_openapi(get_operation_cost(value))),
        base_power = _get_base_power(value),
        remote_regulated_bus_id = _component_id_optional(refs, get_remote_regulated_bus(value)),
        voltage_setpoint_units = PO.VoltageUnitBasis("COMPONENT_BASE"),
        voltage_setpoint = get_voltage_setpoint(value),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(value::RenewableDispatch, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.RenewableDispatch(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        active_power = get_active_power(value, CU) * _get_base_power(value),
        reactive_power = get_reactive_power(value, CU) * _get_base_power(value),
        rating = get_rating(value, CU) * _get_base_power(value),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(value))),
        reactive_power_limits = _minmax_po_scaled_optional(get_reactive_power_limits(value, CU), _get_base_power(value)),
        power_factor = get_power_factor(value),
        operation_cost = PO.RenewableDispatchOperationCost(convert_cost_to_openapi(get_operation_cost(value))),
        base_power = _get_base_power(value),
        remote_regulated_bus_id = _component_id_optional(refs, get_remote_regulated_bus(value)),
        voltage_setpoint_units = PO.VoltageUnitBasis("COMPONENT_BASE"),
        voltage_setpoint = get_voltage_setpoint(value),
        power_units = _power_units_string(NU),
    )
end
