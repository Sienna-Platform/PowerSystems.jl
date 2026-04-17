#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct AreaInterchange <: Branch
        name::String
        available::Bool
        active_power_flow::Float64
        from_area::Area
        to_area::Area
        flow_limits::FromTo_ToFrom
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

Flow exchanged between Areas. This Interchange is agnostic to the lines connecting the areas. It does not substitute Interface which is the total flow across a group of lines

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow on the line (MW)
- `from_area::Area`: Area from which the power is extracted
- `to_area::Area`: Area to which the power is injected
- `flow_limits::FromTo_ToFrom`: Max flow between the areas. It ignores lines and other branches totals
- `services::Vector{Service}`: (default: `Service[]`) Service interfaces that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct AreaInterchange <: Branch
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Initial condition of active power flow on the line (MW)"
    active_power_flow::Float64
    "Area from which the power is extracted"
    from_area::Area
    "Area to which the power is injected"
    to_area::Area
    "Max flow between the areas. It ignores lines and other branches totals"
    flow_limits::FromTo_ToFrom
    "Service interfaces that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function AreaInterchange(name, available, active_power_flow, from_area, to_area, flow_limits, services=Service[], ext=Dict{String, Any}(), )
    AreaInterchange(name, available, active_power_flow, from_area, to_area, flow_limits, services, ext, InfrastructureSystemsInternal(), )
end

function AreaInterchange(; name, available, active_power_flow, from_area, to_area, flow_limits, services=Service[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    AreaInterchange(name, available, active_power_flow, from_area, to_area, flow_limits, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function AreaInterchange(::Nothing)
    AreaInterchange(;
        name="init",
        available=false,
        active_power_flow=0.0,
        from_area=Area(nothing),
        to_area=Area(nothing),
        flow_limits=(from_to=0.0, to_from=0.0),
        services=Service[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`AreaInterchange`](@ref) `name`."""
get_name(value::AreaInterchange) = value.name
"""Get [`AreaInterchange`](@ref) `available`."""
get_available(value::AreaInterchange) = value.available
"""Get [`AreaInterchange`](@ref) `active_power_flow`."""
get_active_power_flow(value::AreaInterchange) = get_value(value, Val(:active_power_flow), Val(:mva))
get_active_power_flow(value::AreaInterchange, units) = get_value(value, Val(:active_power_flow), Val(:mva), units)
"""Get [`AreaInterchange`](@ref) `from_area`."""
get_from_area(value::AreaInterchange) = value.from_area
"""Get [`AreaInterchange`](@ref) `to_area`."""
get_to_area(value::AreaInterchange) = value.to_area
"""Get [`AreaInterchange`](@ref) `flow_limits`."""
get_flow_limits(value::AreaInterchange) = get_value(value, Val(:flow_limits), Val(:mva))
get_flow_limits(value::AreaInterchange, units) = get_value(value, Val(:flow_limits), Val(:mva), units)
"""Get [`AreaInterchange`](@ref) `services`."""
get_services(value::AreaInterchange) = value.services
"""Get [`AreaInterchange`](@ref) `ext`."""
get_ext(value::AreaInterchange) = value.ext
"""Get [`AreaInterchange`](@ref) `internal`."""
get_internal(value::AreaInterchange) = value.internal

"""Set [`AreaInterchange`](@ref) `available`."""
set_available!(value::AreaInterchange, val) = value.available = val
"""Set [`AreaInterchange`](@ref) `active_power_flow`."""
set_active_power_flow!(value::AreaInterchange, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mva))
"""Set [`AreaInterchange`](@ref) `from_area`."""
set_from_area!(value::AreaInterchange, val) = value.from_area = val
"""Set [`AreaInterchange`](@ref) `to_area`."""
set_to_area!(value::AreaInterchange, val) = value.to_area = val
"""Set [`AreaInterchange`](@ref) `flow_limits`."""
set_flow_limits!(value::AreaInterchange, val) = value.flow_limits = set_value(value, Val(:flow_limits), val, Val(:mva))
"""Set [`AreaInterchange`](@ref) `services`."""
set_services!(value::AreaInterchange, val) = value.services = val
"""Set [`AreaInterchange`](@ref) `ext`."""
set_ext!(value::AreaInterchange, val) = value.ext = val
