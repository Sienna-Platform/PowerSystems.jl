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
        loss::Union{LinearCurve, PiecewiseIncrementalCurve}
        services::Vector{Service}
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
- `loss::Union{LinearCurve, PiecewiseIncrementalCurve}`: (default: `LinearCurve(0.0)`) Loss model coefficients. It accepts a linear model with a constant loss (MW) and a proportional loss rate (MW of loss per MW of flow). It also accepts a Piecewise loss, with N segments to specify different proportional losses for different segments.
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
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
    loss::Union{LinearCurve, PiecewiseIncrementalCurve}
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TwoTerminalGenericHVDCLine(name, available, active_power_flow, arc, active_power_limits_from, active_power_limits_to, reactive_power_limits_from, reactive_power_limits_to, loss=LinearCurve(0.0), services=Device[], ext=Dict{String, Any}(), )
    TwoTerminalGenericHVDCLine(name, available, active_power_flow, arc, active_power_limits_from, active_power_limits_to, reactive_power_limits_from, reactive_power_limits_to, loss, services, ext, InfrastructureSystemsInternal(), )
end

function TwoTerminalGenericHVDCLine(; name, available, active_power_flow, arc, active_power_limits_from, active_power_limits_to, reactive_power_limits_from, reactive_power_limits_to, loss=LinearCurve(0.0), services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    TwoTerminalGenericHVDCLine(name, available, active_power_flow, arc, active_power_limits_from, active_power_limits_to, reactive_power_limits_from, reactive_power_limits_to, loss, services, ext, internal, )
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
        loss=LinearCurve(0.0),
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`TwoTerminalGenericHVDCLine`](@ref) `name`."""
get_name(value::TwoTerminalGenericHVDCLine) = value.name
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `available`."""
get_available(value::TwoTerminalGenericHVDCLine) = value.available
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `active_power_flow`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_active_power_flow(value::TwoTerminalGenericHVDCLine, units) = get_value(value, Val(:active_power_flow), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{ TwoTerminalGenericHVDCLine }) = InfrastructureSystems.SU
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `arc`."""
get_arc(value::TwoTerminalGenericHVDCLine) = value.arc
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `active_power_limits_from`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_active_power_limits_from(value::TwoTerminalGenericHVDCLine, units) = get_value(value, Val(:active_power_limits_from), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_from), ::Type{ TwoTerminalGenericHVDCLine }) = InfrastructureSystems.SU
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `active_power_limits_to`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_active_power_limits_to(value::TwoTerminalGenericHVDCLine, units) = get_value(value, Val(:active_power_limits_to), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_to), ::Type{ TwoTerminalGenericHVDCLine }) = InfrastructureSystems.SU
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `reactive_power_limits_from`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_reactive_power_limits_from(value::TwoTerminalGenericHVDCLine, units) = get_value(value, Val(:reactive_power_limits_from), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_from), ::Type{ TwoTerminalGenericHVDCLine }) = InfrastructureSystems.SU
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `reactive_power_limits_to`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_reactive_power_limits_to(value::TwoTerminalGenericHVDCLine, units) = get_value(value, Val(:reactive_power_limits_to), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_to), ::Type{ TwoTerminalGenericHVDCLine }) = InfrastructureSystems.SU
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `loss`."""
get_loss(value::TwoTerminalGenericHVDCLine) = value.loss
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `services`."""
get_services(value::TwoTerminalGenericHVDCLine) = value.services
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `ext`."""
get_ext(value::TwoTerminalGenericHVDCLine) = value.ext
"""Get [`TwoTerminalGenericHVDCLine`](@ref) `internal`."""
get_internal(value::TwoTerminalGenericHVDCLine) = value.internal

"""Set [`TwoTerminalGenericHVDCLine`](@ref) `available`."""
set_available!(value::TwoTerminalGenericHVDCLine, val) = value.available = val
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `active_power_flow`."""
set_active_power_flow!(value::TwoTerminalGenericHVDCLine, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mva))
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `arc`."""
set_arc!(value::TwoTerminalGenericHVDCLine, val) = value.arc = val
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `active_power_limits_from`."""
set_active_power_limits_from!(value::TwoTerminalGenericHVDCLine, val) = value.active_power_limits_from = set_value(value, Val(:active_power_limits_from), val, Val(:mva))
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `active_power_limits_to`."""
set_active_power_limits_to!(value::TwoTerminalGenericHVDCLine, val) = value.active_power_limits_to = set_value(value, Val(:active_power_limits_to), val, Val(:mva))
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `reactive_power_limits_from`."""
set_reactive_power_limits_from!(value::TwoTerminalGenericHVDCLine, val) = value.reactive_power_limits_from = set_value(value, Val(:reactive_power_limits_from), val, Val(:mva))
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `reactive_power_limits_to`."""
set_reactive_power_limits_to!(value::TwoTerminalGenericHVDCLine, val) = value.reactive_power_limits_to = set_value(value, Val(:reactive_power_limits_to), val, Val(:mva))
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `loss`."""
set_loss!(value::TwoTerminalGenericHVDCLine, val) = value.loss = val
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `services`."""
set_services!(value::TwoTerminalGenericHVDCLine, val) = value.services = val
"""Set [`TwoTerminalGenericHVDCLine`](@ref) `ext`."""
set_ext!(value::TwoTerminalGenericHVDCLine, val) = value.ext = val
