#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct PSSFixed <: PowerSystemStabilizerDynamics
        V_pss::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of a PSS that returns a fixed voltage to add to the reference for the AVR

# Arguments
- `V_pss::Float64`: Fixed voltage stabilization signal in pu ([`DEVICE_BASE`](@ref per_unit)), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) PSSFixed has no [states](@ref S)
- `n_states::Int`: (**Do not modify.**) PSSFixed has no states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct PSSFixed <: PowerSystemStabilizerDynamics
    "Fixed voltage stabilization signal in pu ([`DEVICE_BASE`](@ref per_unit))"
    V_pss::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PSSFixed has no [states](@ref S)"
    states::Vector{Symbol}
    "(**Do not modify.**) PSSFixed has no states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function PSSFixed(V_pss, ext=Dict{String, Any}(), )
    PSSFixed(V_pss, ext, Vector{Symbol}(), 0, InfrastructureSystemsInternal(), )
end

function PSSFixed(; V_pss, ext=Dict{String, Any}(), states=Vector{Symbol}(), n_states=0, internal=InfrastructureSystemsInternal(), )
    PSSFixed(V_pss, ext, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function PSSFixed(::Nothing)
    PSSFixed(;
        V_pss=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`PSSFixed`](@ref) `V_pss`."""
get_V_pss(value::PSSFixed) = value.V_pss
"""Get [`PSSFixed`](@ref) `ext`."""
get_ext(value::PSSFixed) = value.ext
"""Get [`PSSFixed`](@ref) `states`."""
get_states(value::PSSFixed) = value.states
"""Get [`PSSFixed`](@ref) `n_states`."""
get_n_states(value::PSSFixed) = value.n_states
"""Get [`PSSFixed`](@ref) `internal`."""
get_internal(value::PSSFixed) = value.internal

"""Set [`PSSFixed`](@ref) `V_pss`."""
set_V_pss!(value::PSSFixed, val) = value.V_pss = val
"""Set [`PSSFixed`](@ref) `ext`."""
set_ext!(value::PSSFixed, val) = value.ext = val



function from_openapi(po::PD.PSSFixed, refs::OpenAPIRefs)
    return PSSFixed(;
        V_pss = _wire_required(po.v_pss, "PSSFixed", "V_pss"),
    )
end

function to_openapi(value::PSSFixed, refs::OpenAPIRefs)
    return PD.PSSFixed(;
        id = component_id(refs, value),
        v_pss = get_V_pss(value),
    )
end
