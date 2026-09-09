#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct InterconnectingConverter <: StaticInjection
        name::String
        available::Bool
        bus::ACBus
        dc_bus::DCBus
        active_power::Float64
        rating::Float64
        active_power_limits::MinMax
        base_power::Float64
        reactive_power_limits::Union{Nothing, MinMax}
        dc_current::Float64
        max_dc_current::Float64
        loss_function::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{QuadraticCurve}}
        dc_control::VSCDCControlModes
        ac_control::VSCACControlModes
        dc_setpoint::Float64
        ac_setpoint::Float64
        dc_voltage_droop::Float64
        remote_bus_control::Union{Nothing, Int}
        rmpct::Float64
        power_factor_weighting_fraction::Float64
        voltage_limits::MinMax
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

Interconnecting Power Converter (IPC) for transforming power from an ACBus to a DCBus

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus on the AC side of this converter
- `dc_bus::DCBus`: Bus on the DC side of this converter
- `active_power::Float64`: Active power (MW) on the DC side, validation range: `active_power_limits`
- `rating::Float64`: Maximum output power rating of the converter (MVA), validation range: `(0, nothing)`
- `active_power_limits::MinMax`: Minimum and maximum stable active power levels (MW)
- `base_power::Float64`: Base power of the converter in MVA, validation range: `(0.0001, nothing)`
- `reactive_power_limits::Union{Nothing, MinMax}`: (default: `nothing`) Minimum and maximum reactive power limits. Set to `Nothing` if not applicable
- `dc_current::Float64`: (default: `0.0`) DC current on the converter, in per unit power-equivalent on the converter `base_power` (I is approximately P at 1.0 pu DC voltage)
- `max_dc_current::Float64`: (default: `1e8`) Maximum stable DC current limit, in per unit power-equivalent on the converter `base_power` (I is approximately P at 1.0 pu DC voltage)
- `loss_function::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{QuadraticCurve}}`: (default: `LossCurve(LinearCurve(0.0), NaturalUnit())`) Linear or quadratic loss function with respect to the converter current
- `dc_control::VSCDCControlModes`: (default: `VSCDCControlModes.DC_VOLTAGE`) DC-side control mode of the converter; see [`VSCDCControlModes`](@ref).
- `ac_control::VSCACControlModes`: (default: `VSCACControlModes.AC_REACTIVE_POWER`) AC-side control mode of the converter; see [`VSCACControlModes`](@ref).
- `dc_setpoint::Float64`: (default: `0.0`) DC-voltage target (when dc_voltage_control is true) or active-power order (when false), in per unit.
- `ac_setpoint::Float64`: (default: `1.0`) AC-voltage magnitude target (when ac_voltage_control is true), in per unit.
- `dc_voltage_droop::Float64`: (default: `0.0`) DC-voltage droop gain relating DC voltage to converter active power as V_dc = dc_setpoint - dc_voltage_droop * P_c. A value of 0.0 disables droop.
- `remote_bus_control::Union{Nothing, Int}`: (default: `nothing`) Number of the AC bus whose voltage the converter regulates when `ac_control` is `AC_VOLTAGE`; `nothing` regulates its own terminal bus., validation range: `(1, nothing)`
- `rmpct::Float64`: (default: `100.0`) Percent of the total MVAr required to hold the voltage at the bus regulated by this converter that is contributed by this converter.
- `power_factor_weighting_fraction::Float64`: (default: `1.0`) Power weighting factor fraction used in reducing the active power order and either the reactive power order when the converter rating is violated. When is 0.0, only the active power is reduced; when is 1.0, only the reactive power is reduced; otherwise, a weighted reduction of both active and reactive power is applied., validation range: `(0, 1)`
- `voltage_limits::MinMax`: (default: `(min=0.0, max=999.9)`) Limits on the voltage at the DC bus in [per unit](@ref per_unit).
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct InterconnectingConverter <: StaticInjection
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus on the AC side of this converter"
    bus::ACBus
    "Bus on the DC side of this converter"
    dc_bus::DCBus
    "Active power (MW) on the DC side"
    active_power::Float64
    "Maximum output power rating of the converter (MVA)"
    rating::Float64
    "Minimum and maximum stable active power levels (MW)"
    active_power_limits::MinMax
    "Base power of the converter in MVA"
    base_power::Float64
    "Minimum and maximum reactive power limits. Set to `Nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "DC current on the converter, in per unit power-equivalent on the converter `base_power` (I is approximately P at 1.0 pu DC voltage)"
    dc_current::Float64
    "Maximum stable DC current limit, in per unit power-equivalent on the converter `base_power` (I is approximately P at 1.0 pu DC voltage)"
    max_dc_current::Float64
    "Linear or quadratic loss function with respect to the converter current"
    loss_function::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{QuadraticCurve}}
    "DC-side control mode of the converter; see [`VSCDCControlModes`](@ref)."
    dc_control::VSCDCControlModes
    "AC-side control mode of the converter; see [`VSCACControlModes`](@ref)."
    ac_control::VSCACControlModes
    "DC-voltage target (when dc_voltage_control is true) or active-power order (when false), in per unit."
    dc_setpoint::Float64
    "AC-voltage magnitude target (when ac_voltage_control is true), in per unit."
    ac_setpoint::Float64
    "DC-voltage droop gain relating DC voltage to converter active power as V_dc = dc_setpoint - dc_voltage_droop * P_c. A value of 0.0 disables droop."
    dc_voltage_droop::Float64
    "Number of the AC bus whose voltage the converter regulates when `ac_control` is `AC_VOLTAGE`; `nothing` regulates its own terminal bus."
    remote_bus_control::Union{Nothing, Int}
    "Percent of the total MVAr required to hold the voltage at the bus regulated by this converter that is contributed by this converter."
    rmpct::Float64
    "Power weighting factor fraction used in reducing the active power order and either the reactive power order when the converter rating is violated. When is 0.0, only the active power is reduced; when is 1.0, only the reactive power is reduced; otherwise, a weighted reduction of both active and reactive power is applied."
    power_factor_weighting_fraction::Float64
    "Limits on the voltage at the DC bus in [per unit](@ref per_unit)."
    voltage_limits::MinMax
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function InterconnectingConverter(name, available, bus, dc_bus, active_power, rating, active_power_limits, base_power, reactive_power_limits=nothing, dc_current=0.0, max_dc_current=1e8, loss_function=LossCurve(LinearCurve(0.0), NaturalUnit()), dc_control=VSCDCControlModes.DC_VOLTAGE, ac_control=VSCACControlModes.AC_REACTIVE_POWER, dc_setpoint=0.0, ac_setpoint=1.0, dc_voltage_droop=0.0, remote_bus_control=nothing, rmpct=100.0, power_factor_weighting_fraction=1.0, voltage_limits=(min=0.0, max=999.9), services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    InterconnectingConverter(name, available, bus, dc_bus, active_power, rating, active_power_limits, base_power, reactive_power_limits, dc_current, max_dc_current, loss_function, dc_control, ac_control, dc_setpoint, ac_setpoint, dc_voltage_droop, remote_bus_control, rmpct, power_factor_weighting_fraction, voltage_limits, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function InterconnectingConverter(; name, available, bus, dc_bus, active_power, rating, active_power_limits, base_power, reactive_power_limits=nothing, dc_current=0.0, max_dc_current=1e8, loss_function=LossCurve(LinearCurve(0.0), NaturalUnit()), dc_control=VSCDCControlModes.DC_VOLTAGE, ac_control=VSCACControlModes.AC_REACTIVE_POWER, dc_setpoint=0.0, ac_setpoint=1.0, dc_voltage_droop=0.0, remote_bus_control=nothing, rmpct=100.0, power_factor_weighting_fraction=1.0, voltage_limits=(min=0.0, max=999.9), services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    InterconnectingConverter(name, available, bus, dc_bus, active_power, rating, active_power_limits, base_power, reactive_power_limits, dc_current, max_dc_current, loss_function, dc_control, ac_control, dc_setpoint, ac_setpoint, dc_voltage_droop, remote_bus_control, rmpct, power_factor_weighting_fraction, voltage_limits, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function InterconnectingConverter(::Nothing)
    InterconnectingConverter(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        dc_bus=DCBus(nothing),
        active_power=0.0,
        rating=0.0,
        active_power_limits=(min=0.0, max=0.0),
        base_power=100.0,
        reactive_power_limits=nothing,
        dc_current=0.0,
        max_dc_current=0.0,
        loss_function=LossCurve(LinearCurve(0.0), NaturalUnit()),
        dc_control=VSCDCControlModes.DC_VOLTAGE,
        ac_control=VSCACControlModes.AC_REACTIVE_POWER,
        dc_setpoint=0.0,
        ac_setpoint=0.0,
        dc_voltage_droop=0.0,
        remote_bus_control=nothing,
        rmpct=100.0,
        power_factor_weighting_fraction=0.0,
        voltage_limits=(min=0.0, max=0.0),
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`InterconnectingConverter`](@ref) `name`."""
get_name(value::InterconnectingConverter) = value.name
"""Get [`InterconnectingConverter`](@ref) `available`."""
get_available(value::InterconnectingConverter) = value.available
"""Get [`InterconnectingConverter`](@ref) `bus`."""
get_bus(value::InterconnectingConverter) = value.bus
"""Get [`InterconnectingConverter`](@ref) `dc_bus`."""
get_dc_bus(value::InterconnectingConverter) = value.dc_bus
"""Get [`InterconnectingConverter`](@ref) `active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::InterconnectingConverter, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`InterconnectingConverter`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::InterconnectingConverter, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::InterconnectingConverter) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::InterconnectingConverter) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{InterconnectingConverter}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{InterconnectingConverter}) = InfrastructureSystems.SU
"""Get [`InterconnectingConverter`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::InterconnectingConverter, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`InterconnectingConverter`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::InterconnectingConverter, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::InterconnectingConverter) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::InterconnectingConverter) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{InterconnectingConverter}) = InfrastructureSystems.DU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{InterconnectingConverter}) = InfrastructureSystems.DU
"""Get [`InterconnectingConverter`](@ref) `active_power_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_limits_unitful`](@ref)."""
get_active_power_limits(value::InterconnectingConverter, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits), Val(:mw), units))
"""Get [`InterconnectingConverter`](@ref) `active_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_limits`](@ref)."""
get_active_power_limits_unitful(value::InterconnectingConverter, units) = get_value(value, Val(:active_power_limits), Val(:mw), units)
get_active_power_limits(value::InterconnectingConverter) = _units_arg_required(get_active_power_limits, value, :active_power_limits, Val(:mw))
get_active_power_limits_unitful(value::InterconnectingConverter) = _units_arg_required(get_active_power_limits_unitful, value, :active_power_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits), ::Type{InterconnectingConverter}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_unitful), ::Type{InterconnectingConverter}) = InfrastructureSystems.SU

_get_base_power(value::InterconnectingConverter) = value.base_power
"""Get [`InterconnectingConverter`](@ref) `reactive_power_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_unitful`](@ref)."""
get_reactive_power_limits(value::InterconnectingConverter, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits), Val(:mvar), units))
"""Get [`InterconnectingConverter`](@ref) `reactive_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_limits`](@ref)."""
get_reactive_power_limits_unitful(value::InterconnectingConverter, units) = get_value(value, Val(:reactive_power_limits), Val(:mvar), units)
get_reactive_power_limits(value::InterconnectingConverter) = _units_arg_required(get_reactive_power_limits, value, :reactive_power_limits, Val(:mvar))
get_reactive_power_limits_unitful(value::InterconnectingConverter) = _units_arg_required(get_reactive_power_limits_unitful, value, :reactive_power_limits, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits), ::Type{InterconnectingConverter}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_unitful), ::Type{InterconnectingConverter}) = InfrastructureSystems.SU
"""Get [`InterconnectingConverter`](@ref) `dc_current` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_dc_current_unitful`](@ref)."""
get_dc_current(value::InterconnectingConverter, units) = InfrastructureSystems._strip_units(get_value(value, Val(:dc_current), Val(:mva), units))
"""Get [`InterconnectingConverter`](@ref) `dc_current` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_dc_current`](@ref)."""
get_dc_current_unitful(value::InterconnectingConverter, units) = get_value(value, Val(:dc_current), Val(:mva), units)
get_dc_current(value::InterconnectingConverter) = _units_arg_required(get_dc_current, value, :dc_current, Val(:mva))
get_dc_current_unitful(value::InterconnectingConverter) = _units_arg_required(get_dc_current_unitful, value, :dc_current, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_dc_current), ::Type{InterconnectingConverter}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_dc_current_unitful), ::Type{InterconnectingConverter}) = InfrastructureSystems.SU
"""Get [`InterconnectingConverter`](@ref) `max_dc_current` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_dc_current_unitful`](@ref)."""
get_max_dc_current(value::InterconnectingConverter, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_dc_current), Val(:mva), units))
"""Get [`InterconnectingConverter`](@ref) `max_dc_current` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_dc_current`](@ref)."""
get_max_dc_current_unitful(value::InterconnectingConverter, units) = get_value(value, Val(:max_dc_current), Val(:mva), units)
get_max_dc_current(value::InterconnectingConverter) = _units_arg_required(get_max_dc_current, value, :max_dc_current, Val(:mva))
get_max_dc_current_unitful(value::InterconnectingConverter) = _units_arg_required(get_max_dc_current_unitful, value, :max_dc_current, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_max_dc_current), ::Type{InterconnectingConverter}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_dc_current_unitful), ::Type{InterconnectingConverter}) = InfrastructureSystems.SU
"""Get [`InterconnectingConverter`](@ref) `loss_function`."""
get_loss_function(value::InterconnectingConverter) = value.loss_function
"""Get [`InterconnectingConverter`](@ref) `dc_control`."""
get_dc_control(value::InterconnectingConverter) = value.dc_control
"""Get [`InterconnectingConverter`](@ref) `ac_control`."""
get_ac_control(value::InterconnectingConverter) = value.ac_control
"""Get [`InterconnectingConverter`](@ref) `dc_setpoint`."""
get_dc_setpoint(value::InterconnectingConverter) = value.dc_setpoint
"""Get [`InterconnectingConverter`](@ref) `ac_setpoint`."""
get_ac_setpoint(value::InterconnectingConverter) = value.ac_setpoint
"""Get [`InterconnectingConverter`](@ref) `dc_voltage_droop`."""
get_dc_voltage_droop(value::InterconnectingConverter) = value.dc_voltage_droop
"""Get [`InterconnectingConverter`](@ref) `remote_bus_control`."""
get_remote_bus_control(value::InterconnectingConverter) = value.remote_bus_control
"""Get [`InterconnectingConverter`](@ref) `rmpct`."""
get_rmpct(value::InterconnectingConverter) = value.rmpct
"""Get [`InterconnectingConverter`](@ref) `power_factor_weighting_fraction`."""
get_power_factor_weighting_fraction(value::InterconnectingConverter) = value.power_factor_weighting_fraction
"""Get [`InterconnectingConverter`](@ref) `voltage_limits`."""
get_voltage_limits(value::InterconnectingConverter) = value.voltage_limits
"""Get [`InterconnectingConverter`](@ref) `services`."""
get_services(value::InterconnectingConverter) = value.services
"""Get [`InterconnectingConverter`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::InterconnectingConverter) = value.dynamic_injector
"""Get [`InterconnectingConverter`](@ref) `ext`."""
get_ext(value::InterconnectingConverter) = value.ext
"""Get [`InterconnectingConverter`](@ref) `internal`."""
get_internal(value::InterconnectingConverter) = value.internal

"""Set [`InterconnectingConverter`](@ref) `available`."""
set_available!(value::InterconnectingConverter, val) = value.available = val
"""Set [`InterconnectingConverter`](@ref) `bus`."""
set_bus!(value::InterconnectingConverter, val) = value.bus = val
"""Set [`InterconnectingConverter`](@ref) `dc_bus`."""
set_dc_bus!(value::InterconnectingConverter, val) = value.dc_bus = val
"""Set [`InterconnectingConverter`](@ref) `active_power`."""
set_active_power!(value::InterconnectingConverter, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::InterconnectingConverter, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`InterconnectingConverter`](@ref) `rating`."""
set_rating!(value::InterconnectingConverter, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::InterconnectingConverter, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`InterconnectingConverter`](@ref) `active_power_limits`."""
set_active_power_limits!(value::InterconnectingConverter, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mw))
set_active_power_limits!(value::InterconnectingConverter, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
set_active_power_limits!(value::InterconnectingConverter, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits!, value, :active_power_limits, Val(:mw), val)
"""Set [`InterconnectingConverter`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::InterconnectingConverter, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mvar))
set_reactive_power_limits!(value::InterconnectingConverter, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
set_reactive_power_limits!(value::InterconnectingConverter, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
"""Set [`InterconnectingConverter`](@ref) `dc_current`."""
set_dc_current!(value::InterconnectingConverter, val) = value.dc_current = set_value(value, Val(:dc_current), val, Val(:mva))
set_dc_current!(value::InterconnectingConverter, val::_UntaggedNumber) = _units_tag_required(set_dc_current!, value, :dc_current, Val(:mva), val)
"""Set [`InterconnectingConverter`](@ref) `max_dc_current`."""
set_max_dc_current!(value::InterconnectingConverter, val) = value.max_dc_current = set_value(value, Val(:max_dc_current), val, Val(:mva))
set_max_dc_current!(value::InterconnectingConverter, val::_UntaggedNumber) = _units_tag_required(set_max_dc_current!, value, :max_dc_current, Val(:mva), val)
"""Set [`InterconnectingConverter`](@ref) `loss_function`."""
set_loss_function!(value::InterconnectingConverter, val) = value.loss_function = val
"""Set [`InterconnectingConverter`](@ref) `dc_control`."""
set_dc_control!(value::InterconnectingConverter, val) = value.dc_control = val
"""Set [`InterconnectingConverter`](@ref) `ac_control`."""
set_ac_control!(value::InterconnectingConverter, val) = value.ac_control = val
"""Set [`InterconnectingConverter`](@ref) `dc_setpoint`."""
set_dc_setpoint!(value::InterconnectingConverter, val) = value.dc_setpoint = val
"""Set [`InterconnectingConverter`](@ref) `ac_setpoint`."""
set_ac_setpoint!(value::InterconnectingConverter, val) = value.ac_setpoint = val
"""Set [`InterconnectingConverter`](@ref) `dc_voltage_droop`."""
set_dc_voltage_droop!(value::InterconnectingConverter, val) = value.dc_voltage_droop = val
"""Set [`InterconnectingConverter`](@ref) `remote_bus_control`."""
set_remote_bus_control!(value::InterconnectingConverter, val) = value.remote_bus_control = val
"""Set [`InterconnectingConverter`](@ref) `rmpct`."""
set_rmpct!(value::InterconnectingConverter, val) = value.rmpct = val
"""Set [`InterconnectingConverter`](@ref) `power_factor_weighting_fraction`."""
set_power_factor_weighting_fraction!(value::InterconnectingConverter, val) = value.power_factor_weighting_fraction = val
"""Set [`InterconnectingConverter`](@ref) `voltage_limits`."""
set_voltage_limits!(value::InterconnectingConverter, val) = value.voltage_limits = val
"""Set [`InterconnectingConverter`](@ref) `services`."""
set_services!(value::InterconnectingConverter, val) = value.services = val
"""Set [`InterconnectingConverter`](@ref) `ext`."""
set_ext!(value::InterconnectingConverter, val) = value.ext = val
