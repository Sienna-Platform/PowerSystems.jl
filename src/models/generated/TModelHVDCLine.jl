#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TModelHVDCLine <: DCBranch
        name::String
        available::Bool
        active_power_flow::Float64
        arc::Arc
        r::Float64
        l::Float64
        c::Float64
        base_current::Float64
        services::Vector{Service}
        operational_flow_limit::Union{Nothing, OperationalFlowLimit}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A High Voltage DC transmission line for modeling DC transmission networks.

This line must be connected to a [`DCBus`](@ref) on each end. It uses a T-Model of the line impedance. This is suitable for operational simulations with a multi-terminal DC network

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow on the line (MW)
- `arc::Arc`: An [`Arc`](@ref) defining this line `from` a bus `to` another bus
- `r::Float64`: Total series resistance in ohm, split equally on both sides of the shunt capacitance
- `l::Float64`: Total series inductance in H, split equally on both sides of the shunt capacitance
- `c::Float64`: Shunt capacitance in F
- `base_current::Float64`: Base current of the line as recorded by the source data (A). No field of this component is per-unit on it, validation range: `(0.0001, nothing)`
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `operational_flow_limit::Union{Nothing, OperationalFlowLimit}`: (default: `nothing`) Operator-set minimum and maximum flow (MW) in each direction, `from_to` and `to_from`, applied in addition to `rating`. `nothing` means no operational limit
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
- `input_basis`: (keyword constructor only, required) `u"CU"` or `u"NU"`, the units of bare numbers on unit-bearing fields. Tagged values (`50.0u"MW"`) keep their own units
"""
mutable struct TModelHVDCLine <: DCBranch
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Initial condition of active power flow on the line (MW)"
    active_power_flow::Float64
    "An [`Arc`](@ref) defining this line `from` a bus `to` another bus"
    arc::Arc
    "Total series resistance in ohm, split equally on both sides of the shunt capacitance"
    r::Float64
    "Total series inductance in H, split equally on both sides of the shunt capacitance"
    l::Float64
    "Shunt capacitance in F"
    c::Float64
    "Base current of the line as recorded by the source data (A). No field of this component is per-unit on it"
    base_current::Float64
    "Services that this device contributes to"
    services::Vector{Service}
    "Operator-set minimum and maximum flow (MW) in each direction, `from_to` and `to_from`, applied in addition to `rating`. `nothing` means no operational limit"
    operational_flow_limit::Union{Nothing, OperationalFlowLimit}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TModelHVDCLine(name, available, active_power_flow, arc, r, l, c, base_current, services=Device[], operational_flow_limit=nothing, ext=Dict{String, Any}(), )
    TModelHVDCLine(name, available, active_power_flow, arc, r, l, c, base_current, services, operational_flow_limit, ext, InfrastructureSystemsInternal(), )
end

function TModelHVDCLine(; name, available, active_power_flow, arc, r, l, c, base_current, services=Device[], operational_flow_limit=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), input_basis::Unitful.Units, )
    value = TModelHVDCLine(name, available, _placeholder(active_power_flow), arc, r, l, c, base_current, services, _placeholder(operational_flow_limit), ext, internal, )
    set_active_power_flow!(value, _tag(active_power_flow, input_basis, Val(:mw)))
    set_operational_flow_limit!(value, _tag(operational_flow_limit, input_basis, Val(:mw)))
    return value
end
_takes_input_basis(::Type{<:TModelHVDCLine}) = true

# Constructor for demo purposes; non-functional.
function TModelHVDCLine(::Nothing)
    TModelHVDCLine(;
        name="init",
        available=false,
        active_power_flow=0.0,
        arc=Arc(DCBus(nothing), DCBus(nothing)),
        r=0.0,
        l=0.0,
        c=0.0,
        base_current=100.0,
        services=Device[],
        operational_flow_limit=nothing,
        ext=Dict{String, Any}(),
        input_basis=u"CU",
    )
end

"""Get [`TModelHVDCLine`](@ref) `name`."""
get_name(value::TModelHVDCLine) = value.name
"""Get [`TModelHVDCLine`](@ref) `available`."""
get_available(value::TModelHVDCLine) = value.available
"""Get [`TModelHVDCLine`](@ref) `active_power_flow` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_active_power_flow_unitful`](@ref)."""
get_active_power_flow(value::TModelHVDCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_flow), Val(:mw), units))
"""Get [`TModelHVDCLine`](@ref) `active_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_active_power_flow`](@ref)."""
get_active_power_flow_unitful(value::TModelHVDCLine, units) = get_value(value, Val(:active_power_flow), Val(:mw), units)
get_active_power_flow(value::TModelHVDCLine) = _units_arg_required(get_active_power_flow, value, :active_power_flow, Val(:mw))
get_active_power_flow_unitful(value::TModelHVDCLine) = _units_arg_required(get_active_power_flow_unitful, value, :active_power_flow, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{TModelHVDCLine}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_unitful), ::Type{TModelHVDCLine}) = u"SU"
"""Get [`TModelHVDCLine`](@ref) `arc`."""
get_arc(value::TModelHVDCLine) = value.arc
"""Get [`TModelHVDCLine`](@ref) `r`."""
get_r(value::TModelHVDCLine) = value.r
"""Get [`TModelHVDCLine`](@ref) `l`."""
get_l(value::TModelHVDCLine) = value.l
"""Get [`TModelHVDCLine`](@ref) `c`."""
get_c(value::TModelHVDCLine) = value.c
"""Get [`TModelHVDCLine`](@ref) `base_current`."""
get_base_current(value::TModelHVDCLine) = value.base_current
"""Get [`TModelHVDCLine`](@ref) `services`."""
get_services(value::TModelHVDCLine) = value.services
"""Get [`TModelHVDCLine`](@ref) `operational_flow_limit` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_operational_flow_limit_unitful`](@ref)."""
get_operational_flow_limit(value::TModelHVDCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:operational_flow_limit), Val(:mw), units))
"""Get [`TModelHVDCLine`](@ref) `operational_flow_limit` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_operational_flow_limit`](@ref)."""
get_operational_flow_limit_unitful(value::TModelHVDCLine, units) = get_value(value, Val(:operational_flow_limit), Val(:mw), units)
get_operational_flow_limit(value::TModelHVDCLine) = _units_arg_required(get_operational_flow_limit, value, :operational_flow_limit, Val(:mw))
get_operational_flow_limit_unitful(value::TModelHVDCLine) = _units_arg_required(get_operational_flow_limit_unitful, value, :operational_flow_limit, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_operational_flow_limit), ::Type{TModelHVDCLine}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_operational_flow_limit_unitful), ::Type{TModelHVDCLine}) = u"SU"
"""Get [`TModelHVDCLine`](@ref) `ext`."""
get_ext(value::TModelHVDCLine) = value.ext
"""Get [`TModelHVDCLine`](@ref) `internal`."""
get_internal(value::TModelHVDCLine) = value.internal

"""Set [`TModelHVDCLine`](@ref) `available`."""
set_available!(value::TModelHVDCLine, val) = value.available = val
"""Set [`TModelHVDCLine`](@ref) `active_power_flow`."""
set_active_power_flow!(value::TModelHVDCLine, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mw))
set_active_power_flow!(value::TModelHVDCLine, val::_UntaggedNumber) = _units_tag_required(set_active_power_flow!, value, :active_power_flow, Val(:mw), val)
"""Set [`TModelHVDCLine`](@ref) `arc`."""
set_arc!(value::TModelHVDCLine, val) = value.arc = val
"""Set [`TModelHVDCLine`](@ref) `r`."""
set_r!(value::TModelHVDCLine, val) = value.r = val
"""Set [`TModelHVDCLine`](@ref) `l`."""
set_l!(value::TModelHVDCLine, val) = value.l = val
"""Set [`TModelHVDCLine`](@ref) `c`."""
set_c!(value::TModelHVDCLine, val) = value.c = val
"""Set [`TModelHVDCLine`](@ref) `base_current`."""
set_base_current!(value::TModelHVDCLine, val) = value.base_current = val
"""Set [`TModelHVDCLine`](@ref) `services`."""
set_services!(value::TModelHVDCLine, val) = value.services = val
"""Set [`TModelHVDCLine`](@ref) `operational_flow_limit`."""
set_operational_flow_limit!(value::TModelHVDCLine, val) = value.operational_flow_limit = set_value(value, Val(:operational_flow_limit), val, Val(:mw))
set_operational_flow_limit!(value::TModelHVDCLine, val::_UntaggedNumber) = _units_tag_required(set_operational_flow_limit!, value, :operational_flow_limit, Val(:mw), val)
"""Set [`TModelHVDCLine`](@ref) `ext`."""
set_ext!(value::TModelHVDCLine, val) = value.ext = val
