#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct DiscreteControlledACBranch <: ACTransmission
        name::String
        available::Bool
        active_power_flow::Float64
        reactive_power_flow::Float64
        arc::Arc
        r::Float64
        x::Float64
        rating::Float64
        discrete_branch_type::DiscreteControlledBranchType
        branch_status::DiscreteControlledBranchStatus
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

Used to represent switches and breakers connecting AC Buses

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow on the line (MW)
- `reactive_power_flow::Float64`: Initial condition of reactive power flow on the line (MVAR)
- `arc::Arc`: An [`Arc`](@ref) defining this line `from` a bus `to` another bus
- `r::Float64`: Resistance in pu ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(0, 4)`
- `x::Float64`: Reactance in pu ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(0, 4)`
- `rating::Float64`: Thermal rating (MVA). Flow on the branch must be between -`rating` and `rating`. When defining a line before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to
- `discrete_branch_type::DiscreteControlledBranchType`: (default: `DiscreteControlledBranchType.OTHER`) Type of discrete control
- `branch_status::DiscreteControlledBranchStatus`: (default: `DiscreteControlledBranchStatus.CLOSED`) Open or Close status
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct DiscreteControlledACBranch <: ACTransmission
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Initial condition of active power flow on the line (MW)"
    active_power_flow::Float64
    "Initial condition of reactive power flow on the line (MVAR)"
    reactive_power_flow::Float64
    "An [`Arc`](@ref) defining this line `from` a bus `to` another bus"
    arc::Arc
    "Resistance in pu ([`SYSTEM_BASE`](@ref per_unit))"
    r::Float64
    "Reactance in pu ([`SYSTEM_BASE`](@ref per_unit))"
    x::Float64
    "Thermal rating (MVA). Flow on the branch must be between -`rating` and `rating`. When defining a line before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to"
    rating::Float64
    "Type of discrete control"
    discrete_branch_type::DiscreteControlledBranchType
    "Open or Close status"
    branch_status::DiscreteControlledBranchStatus
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function DiscreteControlledACBranch(name, available, active_power_flow, reactive_power_flow, arc, r, x, rating, discrete_branch_type=DiscreteControlledBranchType.OTHER, branch_status=DiscreteControlledBranchStatus.CLOSED, ext=Dict{String, Any}(), )
    DiscreteControlledACBranch(name, available, active_power_flow, reactive_power_flow, arc, r, x, rating, discrete_branch_type, branch_status, ext, InfrastructureSystemsInternal(), )
end

function DiscreteControlledACBranch(; name, available, active_power_flow, reactive_power_flow, arc, r, x, rating, discrete_branch_type=DiscreteControlledBranchType.OTHER, branch_status=DiscreteControlledBranchStatus.CLOSED, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    DiscreteControlledACBranch(name, available, active_power_flow, reactive_power_flow, arc, r, x, rating, discrete_branch_type, branch_status, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function DiscreteControlledACBranch(::Nothing)
    DiscreteControlledACBranch(;
        name="init",
        available=false,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        r=0.0,
        x=0.0,
        rating=0.0,
        discrete_branch_type=DiscreteControlledBranchType.BREAKER,
        branch_status=DiscreteControlledBranchStatus.CLOSED,
        ext=Dict{String, Any}(),
    )
end

"""Get [`DiscreteControlledACBranch`](@ref) `name`."""
get_name(value::DiscreteControlledACBranch) = value.name
"""Get [`DiscreteControlledACBranch`](@ref) `available`."""
get_available(value::DiscreteControlledACBranch) = value.available
"""Get [`DiscreteControlledACBranch`](@ref) `active_power_flow`."""
get_active_power_flow(value::DiscreteControlledACBranch) = get_value(value, Val(:active_power_flow), Val(:mva))
get_active_power_flow(value::DiscreteControlledACBranch, units) = get_value(value, Val(:active_power_flow), Val(:mva), units)
"""Get [`DiscreteControlledACBranch`](@ref) `reactive_power_flow`."""
get_reactive_power_flow(value::DiscreteControlledACBranch) = get_value(value, Val(:reactive_power_flow), Val(:mva))
get_reactive_power_flow(value::DiscreteControlledACBranch, units) = get_value(value, Val(:reactive_power_flow), Val(:mva), units)
"""Get [`DiscreteControlledACBranch`](@ref) `arc`."""
get_arc(value::DiscreteControlledACBranch) = value.arc
"""Get [`DiscreteControlledACBranch`](@ref) `r`."""
get_r(value::DiscreteControlledACBranch) = get_value(value, Val(:r), Val(:ohm))
get_r(value::DiscreteControlledACBranch, units) = get_value(value, Val(:r), Val(:ohm), units)
"""Get [`DiscreteControlledACBranch`](@ref) `x`."""
get_x(value::DiscreteControlledACBranch) = get_value(value, Val(:x), Val(:ohm))
get_x(value::DiscreteControlledACBranch, units) = get_value(value, Val(:x), Val(:ohm), units)
"""Get [`DiscreteControlledACBranch`](@ref) `rating`."""
get_rating(value::DiscreteControlledACBranch) = get_value(value, Val(:rating), Val(:mva))
get_rating(value::DiscreteControlledACBranch, units) = get_value(value, Val(:rating), Val(:mva), units)
"""Get [`DiscreteControlledACBranch`](@ref) `discrete_branch_type`."""
get_discrete_branch_type(value::DiscreteControlledACBranch) = value.discrete_branch_type
"""Get [`DiscreteControlledACBranch`](@ref) `branch_status`."""
get_branch_status(value::DiscreteControlledACBranch) = value.branch_status
"""Get [`DiscreteControlledACBranch`](@ref) `ext`."""
get_ext(value::DiscreteControlledACBranch) = value.ext
"""Get [`DiscreteControlledACBranch`](@ref) `internal`."""
get_internal(value::DiscreteControlledACBranch) = value.internal

"""Set [`DiscreteControlledACBranch`](@ref) `available`."""
set_available!(value::DiscreteControlledACBranch, val) = value.available = val
"""Set [`DiscreteControlledACBranch`](@ref) `active_power_flow`."""
set_active_power_flow!(value::DiscreteControlledACBranch, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mva))
"""Set [`DiscreteControlledACBranch`](@ref) `reactive_power_flow`."""
set_reactive_power_flow!(value::DiscreteControlledACBranch, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mva))
"""Set [`DiscreteControlledACBranch`](@ref) `arc`."""
set_arc!(value::DiscreteControlledACBranch, val) = value.arc = val
"""Set [`DiscreteControlledACBranch`](@ref) `r`."""
set_r!(value::DiscreteControlledACBranch, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
"""Set [`DiscreteControlledACBranch`](@ref) `x`."""
set_x!(value::DiscreteControlledACBranch, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
"""Set [`DiscreteControlledACBranch`](@ref) `rating`."""
set_rating!(value::DiscreteControlledACBranch, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`DiscreteControlledACBranch`](@ref) `discrete_branch_type`."""
set_discrete_branch_type!(value::DiscreteControlledACBranch, val) = value.discrete_branch_type = val
"""Set [`DiscreteControlledACBranch`](@ref) `branch_status`."""
set_branch_status!(value::DiscreteControlledACBranch, val) = value.branch_status = val
"""Set [`DiscreteControlledACBranch`](@ref) `ext`."""
set_ext!(value::DiscreteControlledACBranch, val) = value.ext = val
