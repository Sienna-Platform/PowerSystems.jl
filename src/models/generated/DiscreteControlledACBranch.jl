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
        normal_branch_status::DiscreteControlledBranchStatus
        base_power::Float64
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
- `rating::Float64`: Thermal rating (MVA). Flow on the branch must be between -`rating` and `rating`. When defining a branch before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to. Displays in device base ([`DEVICE_BASE`](@ref per_unit)) by default, unlike most converted fields which default to system base
- `discrete_branch_type::DiscreteControlledBranchType`: (default: `DiscreteControlledBranchType.OTHER`) Type of discrete control
- `branch_status::DiscreteControlledBranchStatus`: (default: `DiscreteControlledBranchStatus.CLOSED`) Open or Close status
- `normal_branch_status::DiscreteControlledBranchStatus`: (default: `DiscreteControlledBranchStatus.CLOSED`) Normal (as-designed) open or close status of the device
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
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
    "Thermal rating (MVA). Flow on the branch must be between -`rating` and `rating`. When defining a branch before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to. Displays in device base ([`DEVICE_BASE`](@ref per_unit)) by default, unlike most converted fields which default to system base"
    rating::Float64
    "Type of discrete control"
    discrete_branch_type::DiscreteControlledBranchType
    "Open or Close status"
    branch_status::DiscreteControlledBranchStatus
    "Normal (as-designed) open or close status of the device"
    normal_branch_status::DiscreteControlledBranchStatus
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function DiscreteControlledACBranch(name, available, active_power_flow, reactive_power_flow, arc, r, x, rating, discrete_branch_type=DiscreteControlledBranchType.OTHER, branch_status=DiscreteControlledBranchStatus.CLOSED, normal_branch_status=DiscreteControlledBranchStatus.CLOSED, base_power=100.0, ext=Dict{String, Any}(), )
    DiscreteControlledACBranch(name, available, active_power_flow, reactive_power_flow, arc, r, x, rating, discrete_branch_type, branch_status, normal_branch_status, base_power, ext, InfrastructureSystemsInternal(), )
end

function DiscreteControlledACBranch(; name, available, active_power_flow, reactive_power_flow, arc, r, x, rating, discrete_branch_type=DiscreteControlledBranchType.OTHER, branch_status=DiscreteControlledBranchStatus.CLOSED, normal_branch_status=DiscreteControlledBranchStatus.CLOSED, base_power=100.0, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    DiscreteControlledACBranch(name, available, active_power_flow, reactive_power_flow, arc, r, x, rating, discrete_branch_type, branch_status, normal_branch_status, base_power, ext, internal, )
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
        normal_branch_status=DiscreteControlledBranchStatus.CLOSED,
        base_power=100.0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`DiscreteControlledACBranch`](@ref) `name`."""
get_name(value::DiscreteControlledACBranch) = value.name
"""Get [`DiscreteControlledACBranch`](@ref) `available`."""
get_available(value::DiscreteControlledACBranch) = value.available
"""Get [`DiscreteControlledACBranch`](@ref) `active_power_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_flow_unitful`](@ref)."""
get_active_power_flow(value::DiscreteControlledACBranch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_flow), Val(:mw), units))
"""Get [`DiscreteControlledACBranch`](@ref) `active_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_flow`](@ref)."""
get_active_power_flow_unitful(value::DiscreteControlledACBranch, units) = get_value(value, Val(:active_power_flow), Val(:mw), units)
get_active_power_flow(value::DiscreteControlledACBranch) = _units_arg_required(get_active_power_flow, value, :active_power_flow, Val(:mw))
get_active_power_flow_unitful(value::DiscreteControlledACBranch) = _units_arg_required(get_active_power_flow_unitful, value, :active_power_flow, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{DiscreteControlledACBranch}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_unitful), ::Type{DiscreteControlledACBranch}) = InfrastructureSystems.SU
"""Get [`DiscreteControlledACBranch`](@ref) `reactive_power_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_flow_unitful`](@ref)."""
get_reactive_power_flow(value::DiscreteControlledACBranch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_flow), Val(:mvar), units))
"""Get [`DiscreteControlledACBranch`](@ref) `reactive_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_flow`](@ref)."""
get_reactive_power_flow_unitful(value::DiscreteControlledACBranch, units) = get_value(value, Val(:reactive_power_flow), Val(:mvar), units)
get_reactive_power_flow(value::DiscreteControlledACBranch) = _units_arg_required(get_reactive_power_flow, value, :reactive_power_flow, Val(:mvar))
get_reactive_power_flow_unitful(value::DiscreteControlledACBranch) = _units_arg_required(get_reactive_power_flow_unitful, value, :reactive_power_flow, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_flow), ::Type{DiscreteControlledACBranch}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_flow_unitful), ::Type{DiscreteControlledACBranch}) = InfrastructureSystems.SU
"""Get [`DiscreteControlledACBranch`](@ref) `arc`."""
get_arc(value::DiscreteControlledACBranch) = value.arc
"""Get [`DiscreteControlledACBranch`](@ref) `r` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_r_unitful`](@ref)."""
get_r(value::DiscreteControlledACBranch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:r), Val(:ohm), units))
"""Get [`DiscreteControlledACBranch`](@ref) `r` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_r`](@ref)."""
get_r_unitful(value::DiscreteControlledACBranch, units) = get_value(value, Val(:r), Val(:ohm), units)
get_r(value::DiscreteControlledACBranch) = _units_arg_required(get_r, value, :r, Val(:ohm))
get_r_unitful(value::DiscreteControlledACBranch) = _units_arg_required(get_r_unitful, value, :r, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_r), ::Type{DiscreteControlledACBranch}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_r_unitful), ::Type{DiscreteControlledACBranch}) = InfrastructureSystems.SU
"""Get [`DiscreteControlledACBranch`](@ref) `x` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_x_unitful`](@ref)."""
get_x(value::DiscreteControlledACBranch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:x), Val(:ohm), units))
"""Get [`DiscreteControlledACBranch`](@ref) `x` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_x`](@ref)."""
get_x_unitful(value::DiscreteControlledACBranch, units) = get_value(value, Val(:x), Val(:ohm), units)
get_x(value::DiscreteControlledACBranch) = _units_arg_required(get_x, value, :x, Val(:ohm))
get_x_unitful(value::DiscreteControlledACBranch) = _units_arg_required(get_x_unitful, value, :x, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_x), ::Type{DiscreteControlledACBranch}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_x_unitful), ::Type{DiscreteControlledACBranch}) = InfrastructureSystems.SU
"""Get [`DiscreteControlledACBranch`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::DiscreteControlledACBranch, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`DiscreteControlledACBranch`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::DiscreteControlledACBranch, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::DiscreteControlledACBranch) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::DiscreteControlledACBranch) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{DiscreteControlledACBranch}) = InfrastructureSystems.DU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{DiscreteControlledACBranch}) = InfrastructureSystems.DU
"""Get [`DiscreteControlledACBranch`](@ref) `discrete_branch_type`."""
get_discrete_branch_type(value::DiscreteControlledACBranch) = value.discrete_branch_type
"""Get [`DiscreteControlledACBranch`](@ref) `branch_status`."""
get_branch_status(value::DiscreteControlledACBranch) = value.branch_status
"""Get [`DiscreteControlledACBranch`](@ref) `normal_branch_status`."""
get_normal_branch_status(value::DiscreteControlledACBranch) = value.normal_branch_status

_get_base_power(value::DiscreteControlledACBranch) = value.base_power
"""Get [`DiscreteControlledACBranch`](@ref) `ext`."""
get_ext(value::DiscreteControlledACBranch) = value.ext
"""Get [`DiscreteControlledACBranch`](@ref) `internal`."""
get_internal(value::DiscreteControlledACBranch) = value.internal

"""Set [`DiscreteControlledACBranch`](@ref) `available`."""
set_available!(value::DiscreteControlledACBranch, val) = value.available = val
"""Set [`DiscreteControlledACBranch`](@ref) `active_power_flow`."""
set_active_power_flow!(value::DiscreteControlledACBranch, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mw))
set_active_power_flow!(value::DiscreteControlledACBranch, val::_UntaggedNumber) = _units_tag_required(set_active_power_flow!, value, :active_power_flow, Val(:mw), val)
"""Set [`DiscreteControlledACBranch`](@ref) `reactive_power_flow`."""
set_reactive_power_flow!(value::DiscreteControlledACBranch, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mvar))
set_reactive_power_flow!(value::DiscreteControlledACBranch, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_flow!, value, :reactive_power_flow, Val(:mvar), val)
"""Set [`DiscreteControlledACBranch`](@ref) `arc`."""
set_arc!(value::DiscreteControlledACBranch, val) = value.arc = val
"""Set [`DiscreteControlledACBranch`](@ref) `r`."""
set_r!(value::DiscreteControlledACBranch, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
set_r!(value::DiscreteControlledACBranch, val::_UntaggedNumber) = _units_tag_required(set_r!, value, :r, Val(:ohm), val)
"""Set [`DiscreteControlledACBranch`](@ref) `x`."""
set_x!(value::DiscreteControlledACBranch, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
set_x!(value::DiscreteControlledACBranch, val::_UntaggedNumber) = _units_tag_required(set_x!, value, :x, Val(:ohm), val)
"""Set [`DiscreteControlledACBranch`](@ref) `rating`."""
set_rating!(value::DiscreteControlledACBranch, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::DiscreteControlledACBranch, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`DiscreteControlledACBranch`](@ref) `discrete_branch_type`."""
set_discrete_branch_type!(value::DiscreteControlledACBranch, val) = value.discrete_branch_type = val
"""Set [`DiscreteControlledACBranch`](@ref) `branch_status`."""
set_branch_status!(value::DiscreteControlledACBranch, val) = value.branch_status = val
"""Set [`DiscreteControlledACBranch`](@ref) `normal_branch_status`."""
set_normal_branch_status!(value::DiscreteControlledACBranch, val) = value.normal_branch_status = val
"""Set [`DiscreteControlledACBranch`](@ref) `ext`."""
set_ext!(value::DiscreteControlledACBranch, val) = value.ext = val
