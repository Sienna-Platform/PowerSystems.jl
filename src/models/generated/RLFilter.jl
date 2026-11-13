#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct RLFilter <: Filter
        rf::Float64
        lf::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of RL series filter in algebraic representation

# Arguments
- `rf::Float64`: Series resistance in p.u. of converter filter to the grid, validation range: `(0, nothing)`
- `lf::Float64`: Series inductance in p.u. of converter filter to the grid, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) RLFilter has zero [states](@ref S)
- `n_states::Int`: (**Do not modify.**) RLFilter has zero states
"""
mutable struct RLFilter <: Filter
    "Series resistance in p.u. of converter filter to the grid"
    rf::Float64
    "Series inductance in p.u. of converter filter to the grid"
    lf::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) RLFilter has zero [states](@ref S)"
    states::Vector{Symbol}
    "(**Do not modify.**) RLFilter has zero states"
    n_states::Int
end

function RLFilter(rf, lf, ext=Dict{String, Any}(), )
    RLFilter(rf, lf, ext, Vector{Symbol}(), 0, )
end

function RLFilter(; rf, lf, ext=Dict{String, Any}(), states=Vector{Symbol}(), n_states=0, )
    RLFilter(rf, lf, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function RLFilter(::Nothing)
    RLFilter(;
        rf=0,
        lf=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`RLFilter`](@ref) `rf`."""
get_rf(value::RLFilter) = value.rf
"""Get [`RLFilter`](@ref) `lf`."""
get_lf(value::RLFilter) = value.lf
"""Get [`RLFilter`](@ref) `ext`."""
get_ext(value::RLFilter) = value.ext
"""Get [`RLFilter`](@ref) `states`."""
get_states(value::RLFilter) = value.states
"""Get [`RLFilter`](@ref) `n_states`."""
get_n_states(value::RLFilter) = value.n_states

"""Set [`RLFilter`](@ref) `rf`."""
set_rf!(value::RLFilter, val) = value.rf = val
"""Set [`RLFilter`](@ref) `lf`."""
set_lf!(value::RLFilter, val) = value.lf = val
"""Set [`RLFilter`](@ref) `ext`."""
set_ext!(value::RLFilter, val) = value.ext = val



function from_openapi(po::PD.RLFilter, refs::OpenAPIRefs)
    return RLFilter(;
        rf = _wire_required(po.rf, "RLFilter", "rf"),
        lf = _wire_required(po.lf, "RLFilter", "lf"),
    )
end

function to_openapi(value::RLFilter, refs::OpenAPIRefs)
    return PD.RLFilter(;
        id = component_id(refs, value),
        rf = get_rf(value),
        lf = get_lf(value),
    )
end
