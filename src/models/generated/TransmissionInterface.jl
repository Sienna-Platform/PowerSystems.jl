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
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TransmissionInterface(name, available, active_power_flow_limits, violation_penalty=INFINITE_COST, direction_mapping=Dict{String, Int}(), )
    TransmissionInterface(name, available, active_power_flow_limits, violation_penalty, direction_mapping, InfrastructureSystemsInternal(), )
end

function TransmissionInterface(; name, available, active_power_flow_limits, violation_penalty=INFINITE_COST, direction_mapping=Dict{String, Int}(), internal=InfrastructureSystemsInternal(), )
    TransmissionInterface(name, available, active_power_flow_limits, violation_penalty, direction_mapping, internal, )
end

# Constructor for demo purposes; non-functional.
function TransmissionInterface(::Nothing)
    TransmissionInterface(;
        name="init",
        available=false,
        active_power_flow_limits=(min=0.0, max=0.0),
        violation_penalty=0.0,
        direction_mapping=Dict{String, Int}(),
    )
end

"""Get [`TransmissionInterface`](@ref) `name`."""
get_name(value::TransmissionInterface) = value.name
"""Get [`TransmissionInterface`](@ref) `available`."""
get_available(value::TransmissionInterface) = value.available
"""Get [`TransmissionInterface`](@ref) `active_power_flow_limits`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_active_power_flow_limits(value::TransmissionInterface) = get_value(value, Val(:active_power_flow_limits), Val(:mva), DEFAULT_UNITS)
get_active_power_flow_limits(value::TransmissionInterface, units) = get_value(value, Val(:active_power_flow_limits), Val(:mva), units)
"""Get [`TransmissionInterface`](@ref) `violation_penalty`."""
get_violation_penalty(value::TransmissionInterface) = value.violation_penalty
"""Get [`TransmissionInterface`](@ref) `direction_mapping`."""
get_direction_mapping(value::TransmissionInterface) = value.direction_mapping
"""Get [`TransmissionInterface`](@ref) `internal`."""
get_internal(value::TransmissionInterface) = value.internal

"""Set [`TransmissionInterface`](@ref) `available`."""
set_available!(value::TransmissionInterface, val) = value.available = val
"""Set [`TransmissionInterface`](@ref) `active_power_flow_limits`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_flow_limits!(value::TransmissionInterface, val) = value.active_power_flow_limits = set_value(value, Val(:active_power_flow_limits), val, Val(:mva))
"""Set [`TransmissionInterface`](@ref) `violation_penalty`."""
set_violation_penalty!(value::TransmissionInterface, val) = value.violation_penalty = val
"""Set [`TransmissionInterface`](@ref) `direction_mapping`."""
set_direction_mapping!(value::TransmissionInterface, val) = value.direction_mapping = val
