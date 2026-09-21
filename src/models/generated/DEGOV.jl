#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct DEGOV <: TurbineGov
        T1::Float64
        T2::Float64
        T3::Float64
        K::Float64
        T4::Float64
        T5::Float64
        T6::Float64
        Td::Float64
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

Parameters Woodward Diesel Governor Model. DEGOV in PowerWorld

# Arguments
- `T1::Float64`: Governor mechanism time constant, validation range: `(eps(), 100.0)`
- `T2::Float64`: Turbine power time constant, validation range: `(eps(), 100.0)`
- `T3::Float64`: Turbine exhaust temperature time constant, validation range: `(eps(), 100.0)`
- `K::Float64`: Governor gain (reciprocal of droop), validation range: `(eps(), 100.0)`
- `T4::Float64`: Governor lead time constant, validation range: `(eps(), 100.0)`
- `T5::Float64`: Governor lag time constant, validation range: `(eps(), 100.0)`
- `T6::Float64`: Actuator time constant, validation range: `(eps(), 100.0)`
- `Td::Float64`: Engine time delay, validation range: `(eps(), 100.0)`
- `P_ref::Float64`: (default: `1.0`) Reference Load Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the DEGOV model are:
	x_ecb1: Electric control box 1,
	x_ecb2: Electric control box 2,
	x_a1: Actuator 1,
	x_a2: Actuator 2,
	x_a3: Actuator 3,
- `n_states::Int`: (**Do not modify.**) DEGOV has 5 states
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) DEGOV has 5 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct DEGOV <: TurbineGov
    "Governor mechanism time constant"
    T1::Float64
    "Turbine power time constant"
    T2::Float64
    "Turbine exhaust temperature time constant"
    T3::Float64
    "Governor gain (reciprocal of droop)"
    K::Float64
    "Governor lead time constant"
    T4::Float64
    "Governor lag time constant"
    T5::Float64
    "Actuator time constant"
    T6::Float64
    "Engine time delay"
    Td::Float64
    "Reference Load Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the DEGOV model are:
	x_ecb1: Electric control box 1,
	x_ecb2: Electric control box 2,
	x_a1: Actuator 1,
	x_a2: Actuator 2,
	x_a3: Actuator 3,"
    states::Vector{Symbol}
    "(**Do not modify.**) DEGOV has 5 states"
    n_states::Int
    "(**Do not modify.**) DEGOV has 5 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function DEGOV(T1, T2, T3, K, T4, T5, T6, Td, P_ref=1.0, ext=Dict{String, Any}(), )
    DEGOV(T1, T2, T3, K, T4, T5, T6, Td, P_ref, ext, [:x_ecb1, :x_ecb2, :x_a1, :x_a2, :x_a3], 5, [StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function DEGOV(; T1, T2, T3, K, T4, T5, T6, Td, P_ref=1.0, ext=Dict{String, Any}(), states=[:x_ecb1, :x_ecb2, :x_a1, :x_a2, :x_a3], n_states=5, states_types=[StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    DEGOV(T1, T2, T3, K, T4, T5, T6, Td, P_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function DEGOV(::Nothing)
    DEGOV(;
        T1=0,
        T2=0,
        T3=0,
        K=0,
        T4=0,
        T5=0,
        T6=0,
        Td=0,
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`DEGOV`](@ref) `T1`."""
get_T1(value::DEGOV) = value.T1
"""Get [`DEGOV`](@ref) `T2`."""
get_T2(value::DEGOV) = value.T2
"""Get [`DEGOV`](@ref) `T3`."""
get_T3(value::DEGOV) = value.T3
"""Get [`DEGOV`](@ref) `K`."""
get_K(value::DEGOV) = value.K
"""Get [`DEGOV`](@ref) `T4`."""
get_T4(value::DEGOV) = value.T4
"""Get [`DEGOV`](@ref) `T5`."""
get_T5(value::DEGOV) = value.T5
"""Get [`DEGOV`](@ref) `T6`."""
get_T6(value::DEGOV) = value.T6
"""Get [`DEGOV`](@ref) `Td`."""
get_Td(value::DEGOV) = value.Td
"""Get [`DEGOV`](@ref) `P_ref`."""
get_P_ref(value::DEGOV) = value.P_ref
"""Get [`DEGOV`](@ref) `ext`."""
get_ext(value::DEGOV) = value.ext
"""Get [`DEGOV`](@ref) `states`."""
get_states(value::DEGOV) = value.states
"""Get [`DEGOV`](@ref) `n_states`."""
get_n_states(value::DEGOV) = value.n_states
"""Get [`DEGOV`](@ref) `states_types`."""
get_states_types(value::DEGOV) = value.states_types
"""Get [`DEGOV`](@ref) `internal`."""
get_internal(value::DEGOV) = value.internal

"""Set [`DEGOV`](@ref) `T1`."""
set_T1!(value::DEGOV, val) = value.T1 = val
"""Set [`DEGOV`](@ref) `T2`."""
set_T2!(value::DEGOV, val) = value.T2 = val
"""Set [`DEGOV`](@ref) `T3`."""
set_T3!(value::DEGOV, val) = value.T3 = val
"""Set [`DEGOV`](@ref) `K`."""
set_K!(value::DEGOV, val) = value.K = val
"""Set [`DEGOV`](@ref) `T4`."""
set_T4!(value::DEGOV, val) = value.T4 = val
"""Set [`DEGOV`](@ref) `T5`."""
set_T5!(value::DEGOV, val) = value.T5 = val
"""Set [`DEGOV`](@ref) `T6`."""
set_T6!(value::DEGOV, val) = value.T6 = val
"""Set [`DEGOV`](@ref) `Td`."""
set_Td!(value::DEGOV, val) = value.Td = val
"""Set [`DEGOV`](@ref) `P_ref`."""
set_P_ref!(value::DEGOV, val) = value.P_ref = val
"""Set [`DEGOV`](@ref) `ext`."""
set_ext!(value::DEGOV, val) = value.ext = val
"""Set [`DEGOV`](@ref) `states_types`."""
set_states_types!(value::DEGOV, val) = value.states_types = val
