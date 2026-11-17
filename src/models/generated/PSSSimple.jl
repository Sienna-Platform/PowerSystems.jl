#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct PSSSimple <: PowerSystemStabilizerDynamics
        K_frequency::Float64
        K_p::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of a PSS that returns a proportional droop voltage to add to the reference for the AVR

# Arguments
- `K_frequency::Float64`: Proportional gain for frequency, validation range: `(0, nothing)`
- `K_p::Float64`: Proportional gain for active power, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) PSSSimple has no [states](@ref S)
- `n_states::Int`: (**Do not modify.**) PSSSimple has no states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct PSSSimple <: PowerSystemStabilizerDynamics
    "Proportional gain for frequency"
    K_frequency::Float64
    "Proportional gain for active power"
    K_p::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PSSSimple has no [states](@ref S)"
    states::Vector{Symbol}
    "(**Do not modify.**) PSSSimple has no states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function PSSSimple(K_frequency, K_p, ext=Dict{String, Any}(), )
    PSSSimple(K_frequency, K_p, ext, Vector{Symbol}(), 0, InfrastructureSystemsInternal(), )
end

function PSSSimple(; K_frequency, K_p, ext=Dict{String, Any}(), states=Vector{Symbol}(), n_states=0, internal=InfrastructureSystemsInternal(), )
    PSSSimple(K_frequency, K_p, ext, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function PSSSimple(::Nothing)
    PSSSimple(;
        K_frequency=0,
        K_p=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`PSSSimple`](@ref) `K_frequency`."""
get_K_frequency(value::PSSSimple) = value.K_frequency
"""Get [`PSSSimple`](@ref) `K_p`."""
get_K_p(value::PSSSimple) = value.K_p
"""Get [`PSSSimple`](@ref) `ext`."""
get_ext(value::PSSSimple) = value.ext
"""Get [`PSSSimple`](@ref) `states`."""
get_states(value::PSSSimple) = value.states
"""Get [`PSSSimple`](@ref) `n_states`."""
get_n_states(value::PSSSimple) = value.n_states
"""Get [`PSSSimple`](@ref) `internal`."""
get_internal(value::PSSSimple) = value.internal

"""Set [`PSSSimple`](@ref) `K_frequency`."""
set_K_frequency!(value::PSSSimple, val) = value.K_frequency = val
"""Set [`PSSSimple`](@ref) `K_p`."""
set_K_p!(value::PSSSimple, val) = value.K_p = val
"""Set [`PSSSimple`](@ref) `ext`."""
set_ext!(value::PSSSimple, val) = value.ext = val



function from_openapi(po::PD.PSSSimple, refs::OpenAPIRefs)
    return PSSSimple(;
        K_frequency = _wire_required(po.k_frequency, "PSSSimple", "K_frequency"),
        K_p = _wire_required(po.k_p, "PSSSimple", "K_p"),
    )
end

function to_openapi(value::PSSSimple, refs::OpenAPIRefs)
    return PD.PSSSimple(;
        id = component_id(refs, value),
        k_frequency = get_K_frequency(value),
        k_p = get_K_p(value),
    )
end
