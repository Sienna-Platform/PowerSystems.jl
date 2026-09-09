#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TransmissionInterface <: Service
        name::String
        available::Bool
        active_power_flow_limits::MinMax
        violation_penalty::Float64
        direction_mapping::Dict{String, Int}
        base_power::Float64
        internal::InfrastructureSystemsInternal
    end

A collection of branches that make up an interface or corridor for the transfer of power, such as between different [`Areas`](@ref Area) or [`LoadZones`](@ref LoadZone).

The interface can be used to constrain the power flow across it

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow_limits::MinMax`: Minimum and maximum active power flow limits on the interface (MW)
- `violation_penalty::Float64`: (default: `INFINITE_COST`) Penalty cost for violating the flow limits in the interface
- `direction_mapping::Dict{String, Int}`: (default: `Dict{String, Int}()`) Dictionary of the line `name`s in the interface and their direction of flow (1 or -1) relative to the flow of the interface
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct TransmissionInterface <: Service
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Minimum and maximum active power flow limits on the interface (MW)"
    active_power_flow_limits::MinMax
    "Penalty cost for violating the flow limits in the interface"
    violation_penalty::Float64
    "Dictionary of the line `name`s in the interface and their direction of flow (1 or -1) relative to the flow of the interface"
    direction_mapping::Dict{String, Int}
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TransmissionInterface(name, available, active_power_flow_limits, violation_penalty=INFINITE_COST, direction_mapping=Dict{String, Int}(), base_power=100.0, )
    TransmissionInterface(name, available, active_power_flow_limits, violation_penalty, direction_mapping, base_power, InfrastructureSystemsInternal(), )
end

function TransmissionInterface(; name, available, active_power_flow_limits, violation_penalty=INFINITE_COST, direction_mapping=Dict{String, Int}(), base_power=100.0, internal=InfrastructureSystemsInternal(), )
    TransmissionInterface(name, available, active_power_flow_limits, violation_penalty, direction_mapping, base_power, internal, )
end

# Constructor for demo purposes; non-functional.
function TransmissionInterface(::Nothing)
    TransmissionInterface(;
        name="init",
        available=false,
        active_power_flow_limits=(min=0.0, max=0.0),
        violation_penalty=0.0,
        direction_mapping=Dict{String, Int}(),
        base_power=100.0,
    )
end

"""Get [`TransmissionInterface`](@ref) `name`."""
get_name(value::TransmissionInterface) = value.name
"""Get [`TransmissionInterface`](@ref) `available`."""
get_available(value::TransmissionInterface) = value.available
"""Get [`TransmissionInterface`](@ref) `active_power_flow_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_flow_limits_unitful`](@ref)."""
get_active_power_flow_limits(value::TransmissionInterface, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_flow_limits), Val(:mw), units))
"""Get [`TransmissionInterface`](@ref) `active_power_flow_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_flow_limits`](@ref)."""
get_active_power_flow_limits_unitful(value::TransmissionInterface, units) = get_value(value, Val(:active_power_flow_limits), Val(:mw), units)
get_active_power_flow_limits(value::TransmissionInterface) = _units_arg_required(get_active_power_flow_limits, value, :active_power_flow_limits, Val(:mw))
get_active_power_flow_limits_unitful(value::TransmissionInterface) = _units_arg_required(get_active_power_flow_limits_unitful, value, :active_power_flow_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_limits), ::Type{TransmissionInterface}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_limits_unitful), ::Type{TransmissionInterface}) = InfrastructureSystems.SU
"""Get [`TransmissionInterface`](@ref) `violation_penalty`."""
get_violation_penalty(value::TransmissionInterface) = value.violation_penalty
"""Get [`TransmissionInterface`](@ref) `direction_mapping`."""
get_direction_mapping(value::TransmissionInterface) = value.direction_mapping

_get_base_power(value::TransmissionInterface) = value.base_power
"""Get [`TransmissionInterface`](@ref) `internal`."""
get_internal(value::TransmissionInterface) = value.internal

"""Set [`TransmissionInterface`](@ref) `available`."""
set_available!(value::TransmissionInterface, val) = value.available = val
"""Set [`TransmissionInterface`](@ref) `active_power_flow_limits`."""
set_active_power_flow_limits!(value::TransmissionInterface, val) = value.active_power_flow_limits = set_value(value, Val(:active_power_flow_limits), val, Val(:mw))
set_active_power_flow_limits!(value::TransmissionInterface, val::_UntaggedNumber) = _units_tag_required(set_active_power_flow_limits!, value, :active_power_flow_limits, Val(:mw), val)
set_active_power_flow_limits!(value::TransmissionInterface, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_flow_limits!, value, :active_power_flow_limits, Val(:mw), val)
"""Set [`TransmissionInterface`](@ref) `violation_penalty`."""
set_violation_penalty!(value::TransmissionInterface, val) = value.violation_penalty = val
"""Set [`TransmissionInterface`](@ref) `direction_mapping`."""
set_direction_mapping!(value::TransmissionInterface, val) = value.direction_mapping = val
