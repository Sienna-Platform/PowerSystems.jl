#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TwoTerminalGenericHVDCLine <: TwoTerminalHVDC
        name::String
        available::Bool
        active_power_flow::Float64
        arc::Arc
        active_power_limits_from::MinMax
        active_power_limits_to::MinMax
        reactive_power_limits_from::MinMax
        reactive_power_limits_to::MinMax
        loss::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{PiecewiseIncrementalCurve}}
        services::Vector{Service}
        base_power::Float64
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A High Voltage DC line, which must be connected to an [`ACBus`](@ref) on each end.

This model is appropriate for operational simulations with a linearized DC power flow approximation with losses proportional to the power flow. For modeling a DC network, see [`TModelHVDCLine`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow on the line (MW)
- `arc::Arc`: An [`Arc`](@ref) defining this line `from` a bus `to` another bus
- `active_power_limits_from::MinMax`: Minimum and maximum active power flows to the FROM node (MW)
- `active_power_limits_to::MinMax`: Minimum and maximum active power flows to the TO node (MW)
- `reactive_power_limits_from::MinMax`: Minimum and maximum reactive power limits to the FROM node (MVAR)
- `reactive_power_limits_to::MinMax`: Minimum and maximum reactive power limits to the TO node (MVAR)
- `loss::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{PiecewiseIncrementalCurve}}`: (default: `LossCurve(LinearCurve(0.0), NaturalUnit())`) Loss model coefficients. It accepts a linear model with a constant loss (MW) and a proportional loss rate (MW of loss per MW of flow). It also accepts a Piecewise loss, with N segments to specify different proportional losses for different segments.
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct TwoTerminalGenericHVDCLine <: TwoTerminalHVDC
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Initial condition of active power flow on the line (MW)"
    active_power_flow::Float64
    "An [`Arc`](@ref) defining this line `from` a bus `to` another bus"
    arc::Arc
    "Minimum and maximum active power flows to the FROM node (MW)"
    active_power_limits_from::MinMax
    "Minimum and maximum active power flows to the TO node (MW)"
    active_power_limits_to::MinMax
    "Minimum and maximum reactive power limits to the FROM node (MVAR)"
    reactive_power_limits_from::MinMax
    "Minimum and maximum reactive power limits to the TO node (MVAR)"
    reactive_power_limits_to::MinMax
    "Loss model coefficients. It accepts a linear model with a constant loss (MW) and a proportional loss rate (MW of loss per MW of flow). It also accepts a Piecewise loss, with N segments to specify different proportional losses for different segments."
    loss::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{PiecewiseIncrementalCurve}}
    "Services that this device contributes to"
    services::Vector{Service}
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TwoTerminalGenericHVDCLine(name, available, active_power_flow, arc, active_power_limits_from, active_power_limits_to, reactive_power_limits_from, reactive_power_limits_to, loss=LossCurve(LinearCurve(0.0), NaturalUnit()), services=Device[], base_power=100.0, ext=Dict{String, Any}(), )
    TwoTerminalGenericHVDCLine(name, available, active_power_flow, arc, active_power_limits_from, active_power_limits_to, reactive_power_limits_from, reactive_power_limits_to, loss, services, base_power, ext, InfrastructureSystemsInternal(), )
end

function TwoTerminalGenericHVDCLine(; name, available, active_power_flow, arc, active_power_limits_from, active_power_limits_to, reactive_power_limits_from, reactive_power_limits_to, loss=LossCurve(LinearCurve(0.0), NaturalUnit()), services=Device[], base_power=100.0, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    TwoTerminalGenericHVDCLine(name, available, active_power_flow, arc, active_power_limits_from, active_power_limits_to, reactive_power_limits_from, reactive_power_limits_to, loss, services, base_power, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function TwoTerminalGenericHVDCLine(::Nothing)
    TwoTerminalGenericHVDCLine(;
        name="init",
        available=false,
        active_power_flow=0.0,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        active_power_limits_from=(min=0.0, max=0.0),
        active_power_limits_to=(min=0.0, max=0.0),
        reactive_power_limits_from=(min=0.0, max=0.0),
        reactive_power_limits_to=(min=0.0, max=0.0),
        loss=LossCurve(LinearCurve(0.0), NaturalUnit()),
        services=Device[],
        base_power=100.0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`TwoTerminalGenericHVDCLine`](@ref) `name`."""
get_name(value::TwoTerminalGenericHVDCLine) = value.name
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `available`."""
get_available(value::TwoTerminalGenericHVDCLine) = value.available
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `active_power_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_flow_unitful`](@ref)."""
get_active_power_flow(value::TwoTerminalGenericHVDCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_flow), Val(:mw), units))
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `active_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_flow`](@ref)."""
get_active_power_flow_unitful(value::TwoTerminalGenericHVDCLine, units) = get_value(value, Val(:active_power_flow), Val(:mw), units)
get_active_power_flow(value::TwoTerminalGenericHVDCLine) = _units_arg_required(get_active_power_flow, value, :active_power_flow, Val(:mw))
get_active_power_flow_unitful(value::TwoTerminalGenericHVDCLine) = _units_arg_required(get_active_power_flow_unitful, value, :active_power_flow, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{TwoTerminalGenericHVDCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_unitful), ::Type{TwoTerminalGenericHVDCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `arc`."""
get_arc(value::TwoTerminalGenericHVDCLine) = value.arc
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `active_power_limits_from` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_limits_from_unitful`](@ref)."""
get_active_power_limits_from(value::TwoTerminalGenericHVDCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits_from), Val(:mw), units))
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `active_power_limits_from` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_limits_from`](@ref)."""
get_active_power_limits_from_unitful(value::TwoTerminalGenericHVDCLine, units) = get_value(value, Val(:active_power_limits_from), Val(:mw), units)
get_active_power_limits_from(value::TwoTerminalGenericHVDCLine) = _units_arg_required(get_active_power_limits_from, value, :active_power_limits_from, Val(:mw))
get_active_power_limits_from_unitful(value::TwoTerminalGenericHVDCLine) = _units_arg_required(get_active_power_limits_from_unitful, value, :active_power_limits_from, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_from), ::Type{TwoTerminalGenericHVDCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_from_unitful), ::Type{TwoTerminalGenericHVDCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `active_power_limits_to` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_limits_to_unitful`](@ref)."""
get_active_power_limits_to(value::TwoTerminalGenericHVDCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits_to), Val(:mw), units))
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `active_power_limits_to` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_limits_to`](@ref)."""
get_active_power_limits_to_unitful(value::TwoTerminalGenericHVDCLine, units) = get_value(value, Val(:active_power_limits_to), Val(:mw), units)
get_active_power_limits_to(value::TwoTerminalGenericHVDCLine) = _units_arg_required(get_active_power_limits_to, value, :active_power_limits_to, Val(:mw))
get_active_power_limits_to_unitful(value::TwoTerminalGenericHVDCLine) = _units_arg_required(get_active_power_limits_to_unitful, value, :active_power_limits_to, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_to), ::Type{TwoTerminalGenericHVDCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_to_unitful), ::Type{TwoTerminalGenericHVDCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `reactive_power_limits_from` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_from_unitful`](@ref)."""
get_reactive_power_limits_from(value::TwoTerminalGenericHVDCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits_from), Val(:mvar), units))
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `reactive_power_limits_from` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_limits_from`](@ref)."""
get_reactive_power_limits_from_unitful(value::TwoTerminalGenericHVDCLine, units) = get_value(value, Val(:reactive_power_limits_from), Val(:mvar), units)
get_reactive_power_limits_from(value::TwoTerminalGenericHVDCLine) = _units_arg_required(get_reactive_power_limits_from, value, :reactive_power_limits_from, Val(:mvar))
get_reactive_power_limits_from_unitful(value::TwoTerminalGenericHVDCLine) = _units_arg_required(get_reactive_power_limits_from_unitful, value, :reactive_power_limits_from, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_from), ::Type{TwoTerminalGenericHVDCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_from_unitful), ::Type{TwoTerminalGenericHVDCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `reactive_power_limits_to` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_to_unitful`](@ref)."""
get_reactive_power_limits_to(value::TwoTerminalGenericHVDCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits_to), Val(:mvar), units))
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `reactive_power_limits_to` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_limits_to`](@ref)."""
get_reactive_power_limits_to_unitful(value::TwoTerminalGenericHVDCLine, units) = get_value(value, Val(:reactive_power_limits_to), Val(:mvar), units)
get_reactive_power_limits_to(value::TwoTerminalGenericHVDCLine) = _units_arg_required(get_reactive_power_limits_to, value, :reactive_power_limits_to, Val(:mvar))
get_reactive_power_limits_to_unitful(value::TwoTerminalGenericHVDCLine) = _units_arg_required(get_reactive_power_limits_to_unitful, value, :reactive_power_limits_to, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_to), ::Type{TwoTerminalGenericHVDCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_to_unitful), ::Type{TwoTerminalGenericHVDCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `loss`."""
get_loss(value::TwoTerminalGenericHVDCLine) = value.loss
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `services`."""
get_services(value::TwoTerminalGenericHVDCLine) = value.services

_get_base_power(value::TwoTerminalGenericHVDCLine) = value.base_power
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `ext`."""
get_ext(value::TwoTerminalGenericHVDCLine) = value.ext
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `internal`."""
get_internal(value::TwoTerminalGenericHVDCLine) = value.internal

"""Set [`TwoTerminalGenericHVDCLine`](@ref) `available`."""
set_available!(value::TwoTerminalGenericHVDCLine, val) = value.available = val
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `active_power_flow`."""
set_active_power_flow!(value::TwoTerminalGenericHVDCLine, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mw))
set_active_power_flow!(value::TwoTerminalGenericHVDCLine, val::_UntaggedNumber) = _units_tag_required(set_active_power_flow!, value, :active_power_flow, Val(:mw), val)
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `arc`."""
set_arc!(value::TwoTerminalGenericHVDCLine, val) = value.arc = val
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `active_power_limits_from`."""
set_active_power_limits_from!(value::TwoTerminalGenericHVDCLine, val) = value.active_power_limits_from = set_value(value, Val(:active_power_limits_from), val, Val(:mw))
set_active_power_limits_from!(value::TwoTerminalGenericHVDCLine, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits_from!, value, :active_power_limits_from, Val(:mw), val)
set_active_power_limits_from!(value::TwoTerminalGenericHVDCLine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits_from!, value, :active_power_limits_from, Val(:mw), val)
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `active_power_limits_to`."""
set_active_power_limits_to!(value::TwoTerminalGenericHVDCLine, val) = value.active_power_limits_to = set_value(value, Val(:active_power_limits_to), val, Val(:mw))
set_active_power_limits_to!(value::TwoTerminalGenericHVDCLine, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits_to!, value, :active_power_limits_to, Val(:mw), val)
set_active_power_limits_to!(value::TwoTerminalGenericHVDCLine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits_to!, value, :active_power_limits_to, Val(:mw), val)
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `reactive_power_limits_from`."""
set_reactive_power_limits_from!(value::TwoTerminalGenericHVDCLine, val) = value.reactive_power_limits_from = set_value(value, Val(:reactive_power_limits_from), val, Val(:mvar))
set_reactive_power_limits_from!(value::TwoTerminalGenericHVDCLine, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits_from!, value, :reactive_power_limits_from, Val(:mvar), val)
set_reactive_power_limits_from!(value::TwoTerminalGenericHVDCLine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits_from!, value, :reactive_power_limits_from, Val(:mvar), val)
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `reactive_power_limits_to`."""
set_reactive_power_limits_to!(value::TwoTerminalGenericHVDCLine, val) = value.reactive_power_limits_to = set_value(value, Val(:reactive_power_limits_to), val, Val(:mvar))
set_reactive_power_limits_to!(value::TwoTerminalGenericHVDCLine, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits_to!, value, :reactive_power_limits_to, Val(:mvar), val)
set_reactive_power_limits_to!(value::TwoTerminalGenericHVDCLine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits_to!, value, :reactive_power_limits_to, Val(:mvar), val)
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `loss`."""
set_loss!(value::TwoTerminalGenericHVDCLine, val) = value.loss = val
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `services`."""
set_services!(value::TwoTerminalGenericHVDCLine, val) = value.services = val
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `ext`."""
set_ext!(value::TwoTerminalGenericHVDCLine, val) = value.ext = val
