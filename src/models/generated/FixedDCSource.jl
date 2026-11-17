#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct FixedDCSource <: DCSource
        voltage::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of a Fixed DC Source that returns a fixed DC voltage

# Arguments
- `voltage::Float64`: Voltage (V), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) FixedDCSource has no [states](@ref S)
- `n_states::Int`: (**Do not modify.**) FixedDCSource has no states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct FixedDCSource <: DCSource
    "Voltage (V)"
    voltage::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) FixedDCSource has no [states](@ref S)"
    states::Vector{Symbol}
    "(**Do not modify.**) FixedDCSource has no states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function FixedDCSource(voltage, ext=Dict{String, Any}(), )
    FixedDCSource(voltage, ext, Vector{Symbol}(), 0, InfrastructureSystemsInternal(), )
end

function FixedDCSource(; voltage, ext=Dict{String, Any}(), states=Vector{Symbol}(), n_states=0, internal=InfrastructureSystemsInternal(), )
    FixedDCSource(voltage, ext, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function FixedDCSource(::Nothing)
    FixedDCSource(;
        voltage=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`FixedDCSource`](@ref) `voltage`."""
get_voltage(value::FixedDCSource) = value.voltage
"""Get [`FixedDCSource`](@ref) `ext`."""
get_ext(value::FixedDCSource) = value.ext
"""Get [`FixedDCSource`](@ref) `states`."""
get_states(value::FixedDCSource) = value.states
"""Get [`FixedDCSource`](@ref) `n_states`."""
get_n_states(value::FixedDCSource) = value.n_states
"""Get [`FixedDCSource`](@ref) `internal`."""
get_internal(value::FixedDCSource) = value.internal

"""Set [`FixedDCSource`](@ref) `voltage`."""
set_voltage!(value::FixedDCSource, val) = value.voltage = val
"""Set [`FixedDCSource`](@ref) `ext`."""
set_ext!(value::FixedDCSource, val) = value.ext = val



function from_openapi(po::PD.FixedDCSource, refs::OpenAPIRefs)
    return FixedDCSource(;
        voltage = _wire_required(po.voltage, "FixedDCSource", "voltage"),
    )
end

function to_openapi(value::FixedDCSource, refs::OpenAPIRefs)
    return PD.FixedDCSource(;
        id = component_id(refs, value),
        voltage = get_voltage(value),
    )
end
