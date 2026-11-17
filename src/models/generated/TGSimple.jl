#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TGSimple <: TurbineGovernorDynamics
        d_t::Float64
        Tm::Float64
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of a Simple one-state Turbine Governor

# Arguments
- `d_t::Float64`: Inverse Droop parameter, validation range: `(0, nothing)`
- `Tm::Float64`: Turbine Governor Low-Pass Time Constant [s], validation range: `(0, nothing)`
- `P_ref::Float64`: (default: `1.0`) Reference Power Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the TGSimple model are:
	τm: mechanical torque
- `n_states::Int`: (**Do not modify.**) TGSimple has 1 state
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct TGSimple <: TurbineGovernorDynamics
    "Inverse Droop parameter"
    d_t::Float64
    "Turbine Governor Low-Pass Time Constant [s]"
    Tm::Float64
    "Reference Power Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the TGSimple model are:
	τm: mechanical torque"
    states::Vector{Symbol}
    "(**Do not modify.**) TGSimple has 1 state"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TGSimple(d_t, Tm, P_ref=1.0, ext=Dict{String, Any}(), )
    TGSimple(d_t, Tm, P_ref, ext, [:τm], 1, InfrastructureSystemsInternal(), )
end

function TGSimple(; d_t, Tm, P_ref=1.0, ext=Dict{String, Any}(), states=[:τm], n_states=1, internal=InfrastructureSystemsInternal(), )
    TGSimple(d_t, Tm, P_ref, ext, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function TGSimple(::Nothing)
    TGSimple(;
        d_t=0,
        Tm=0,
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`TGSimple`](@ref) `d_t`."""
get_d_t(value::TGSimple) = value.d_t
"""Get [`TGSimple`](@ref) `Tm`."""
get_Tm(value::TGSimple) = value.Tm
"""Get [`TGSimple`](@ref) `P_ref`."""
get_P_ref(value::TGSimple) = value.P_ref
"""Get [`TGSimple`](@ref) `ext`."""
get_ext(value::TGSimple) = value.ext
"""Get [`TGSimple`](@ref) `states`."""
get_states(value::TGSimple) = value.states
"""Get [`TGSimple`](@ref) `n_states`."""
get_n_states(value::TGSimple) = value.n_states
"""Get [`TGSimple`](@ref) `internal`."""
get_internal(value::TGSimple) = value.internal

"""Set [`TGSimple`](@ref) `d_t`."""
set_d_t!(value::TGSimple, val) = value.d_t = val
"""Set [`TGSimple`](@ref) `Tm`."""
set_Tm!(value::TGSimple, val) = value.Tm = val
"""Set [`TGSimple`](@ref) `P_ref`."""
set_P_ref!(value::TGSimple, val) = value.P_ref = val
"""Set [`TGSimple`](@ref) `ext`."""
set_ext!(value::TGSimple, val) = value.ext = val



function from_openapi(po::PD.TGSimple, refs::OpenAPIRefs)
    return TGSimple(;
        d_t = _wire_required(po.d_t, "TGSimple", "d_t"),
        Tm = _wire_required(po.tm, "TGSimple", "Tm"),
        P_ref = _or_default(po.p_ref, 1.0),
    )
end

function to_openapi(value::TGSimple, refs::OpenAPIRefs)
    return PD.TGSimple(;
        id = component_id(refs, value),
        d_t = get_d_t(value),
        tm = get_Tm(value),
        p_ref = get_P_ref(value),
    )
end
