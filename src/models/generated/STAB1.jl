#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct STAB1 <: PSS
        KT::Float64
        T::Float64
        T1T3::Float64
        T3::Float64
        T2T4::Float64
        T4::Float64
        H_lim::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

Speed-Sensitive Stabilizing Model

# Arguments
- `KT::Float64`: K/T for washout filter, validation range: `(0, nothing)`
- `T::Float64`: Time constant for washout filter, validation range: `(0.01, nothing)`
- `T1T3::Float64`: Time constant division T1/T3, validation range: `(0, nothing)`
- `T3::Float64`: Time constant, validation range: `(0.01, nothing)`
- `T2T4::Float64`: Time constant division T2/T4, validation range: `(0, nothing)`
- `T4::Float64`: Time constant, validation range: `(0.01, nothing)`
- `H_lim::Float64`: PSS output limit, validation range: `(0, 0.5)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	x_p1: washout filter,
	x_p2: T1/T3 lead-lag block, 
	x_p3: T2/T4 lead-lag block,
- `n_states::Int`: (**Do not modify.**) STAB1 has 3 states
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) STAB1 has 3 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct STAB1 <: PSS
    "K/T for washout filter"
    KT::Float64
    "Time constant for washout filter"
    T::Float64
    "Time constant division T1/T3"
    T1T3::Float64
    "Time constant"
    T3::Float64
    "Time constant division T2/T4"
    T2T4::Float64
    "Time constant"
    T4::Float64
    "PSS output limit"
    H_lim::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	x_p1: washout filter,
	x_p2: T1/T3 lead-lag block, 
	x_p3: T2/T4 lead-lag block,"
    states::Vector{Symbol}
    "(**Do not modify.**) STAB1 has 3 states"
    n_states::Int
    "(**Do not modify.**) STAB1 has 3 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function STAB1(KT, T, T1T3, T3, T2T4, T4, H_lim, ext=Dict{String, Any}(), )
    STAB1(KT, T, T1T3, T3, T2T4, T4, H_lim, ext, [:x_p1, :x_p2, :x_p3], 3, [StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function STAB1(; KT, T, T1T3, T3, T2T4, T4, H_lim, ext=Dict{String, Any}(), states=[:x_p1, :x_p2, :x_p3], n_states=3, states_types=[StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    STAB1(KT, T, T1T3, T3, T2T4, T4, H_lim, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function STAB1(::Nothing)
    STAB1(;
        KT=0,
        T=0.01,
        T1T3=0,
        T3=0.01,
        T2T4=0,
        T4=0.01,
        H_lim=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`STAB1`](@ref) `KT`."""
get_KT(value::STAB1) = value.KT
"""Get [`STAB1`](@ref) `T`."""
get_T(value::STAB1) = value.T
"""Get [`STAB1`](@ref) `T1T3`."""
get_T1T3(value::STAB1) = value.T1T3
"""Get [`STAB1`](@ref) `T3`."""
get_T3(value::STAB1) = value.T3
"""Get [`STAB1`](@ref) `T2T4`."""
get_T2T4(value::STAB1) = value.T2T4
"""Get [`STAB1`](@ref) `T4`."""
get_T4(value::STAB1) = value.T4
"""Get [`STAB1`](@ref) `H_lim`."""
get_H_lim(value::STAB1) = value.H_lim
"""Get [`STAB1`](@ref) `ext`."""
get_ext(value::STAB1) = value.ext
"""Get [`STAB1`](@ref) `states`."""
get_states(value::STAB1) = value.states
"""Get [`STAB1`](@ref) `n_states`."""
get_n_states(value::STAB1) = value.n_states
"""Get [`STAB1`](@ref) `states_types`."""
get_states_types(value::STAB1) = value.states_types
"""Get [`STAB1`](@ref) `internal`."""
get_internal(value::STAB1) = value.internal

"""Set [`STAB1`](@ref) `KT`."""
set_KT!(value::STAB1, val) = value.KT = val
"""Set [`STAB1`](@ref) `T`."""
set_T!(value::STAB1, val) = value.T = val
"""Set [`STAB1`](@ref) `T1T3`."""
set_T1T3!(value::STAB1, val) = value.T1T3 = val
"""Set [`STAB1`](@ref) `T3`."""
set_T3!(value::STAB1, val) = value.T3 = val
"""Set [`STAB1`](@ref) `T2T4`."""
set_T2T4!(value::STAB1, val) = value.T2T4 = val
"""Set [`STAB1`](@ref) `T4`."""
set_T4!(value::STAB1, val) = value.T4 = val
"""Set [`STAB1`](@ref) `H_lim`."""
set_H_lim!(value::STAB1, val) = value.H_lim = val
"""Set [`STAB1`](@ref) `ext`."""
set_ext!(value::STAB1, val) = value.ext = val
"""Set [`STAB1`](@ref) `states_types`."""
set_states_types!(value::STAB1, val) = value.states_types = val
