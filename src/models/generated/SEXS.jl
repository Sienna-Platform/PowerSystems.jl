#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SEXS <: AVR
        Ta_Tb::Float64
        Tb::Float64
        K::Float64
        Te::Float64
        V_lim::MinMax
        V_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes}
        internal::InfrastructureSystemsInternal
    end

Parameters of Simplified Excitation System Model - SEXS in PSSE

# Arguments
- `Ta_Tb::Float64`: Ratio of lead and lag time constants, validation range: `(0, nothing)`
- `Tb::Float64`: Lag time constant, validation range: `(eps(), nothing)`
- `K::Float64`: Gain, validation range: `(0, nothing)`
- `Te::Float64`: Field circuit time constant in s, validation range: `(0, nothing)`
- `V_lim::MinMax`: Field voltage limits
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vf: Voltage field,
	Vr: Lead-lag state
- `n_states::Int`: (**Do not modify.**) SEXS has 2 states
- `states_types::Vector{StateTypes}`: (**Do not modify.**) SEXS has 2 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct SEXS <: AVR
    "Ratio of lead and lag time constants"
    Ta_Tb::Float64
    "Lag time constant"
    Tb::Float64
    "Gain"
    K::Float64
    "Field circuit time constant in s"
    Te::Float64
    "Field voltage limits"
    V_lim::MinMax
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	Vf: Voltage field,
	Vr: Lead-lag state"
    states::Vector{Symbol}
    "(**Do not modify.**) SEXS has 2 states"
    n_states::Int
    "(**Do not modify.**) SEXS has 2 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function SEXS(Ta_Tb, Tb, K, Te, V_lim, V_ref=1.0, ext=Dict{String, Any}(), )
    SEXS(Ta_Tb, Tb, K, Te, V_lim, V_ref, ext, [:Vf, :Vr], 2, [StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function SEXS(; Ta_Tb, Tb, K, Te, V_lim, V_ref=1.0, ext=Dict{String, Any}(), states=[:Vf, :Vr], n_states=2, states_types=[StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    SEXS(Ta_Tb, Tb, K, Te, V_lim, V_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function SEXS(::Nothing)
    SEXS(;
        Ta_Tb=0,
        Tb=0,
        K=0,
        Te=0,
        V_lim=(min=0.0, max=0.0),
        V_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`SEXS`](@ref) `Ta_Tb`."""
get_Ta_Tb(value::SEXS) = value.Ta_Tb
"""Get [`SEXS`](@ref) `Tb`."""
get_Tb(value::SEXS) = value.Tb
"""Get [`SEXS`](@ref) `K`."""
get_K(value::SEXS) = value.K
"""Get [`SEXS`](@ref) `Te`."""
get_Te(value::SEXS) = value.Te
"""Get [`SEXS`](@ref) `V_lim`."""
get_V_lim(value::SEXS) = value.V_lim
"""Get [`SEXS`](@ref) `V_ref`."""
get_V_ref(value::SEXS) = value.V_ref
"""Get [`SEXS`](@ref) `ext`."""
get_ext(value::SEXS) = value.ext
"""Get [`SEXS`](@ref) `states`."""
get_states(value::SEXS) = value.states
"""Get [`SEXS`](@ref) `n_states`."""
get_n_states(value::SEXS) = value.n_states
"""Get [`SEXS`](@ref) `states_types`."""
get_states_types(value::SEXS) = value.states_types
"""Get [`SEXS`](@ref) `internal`."""
get_internal(value::SEXS) = value.internal

"""Set [`SEXS`](@ref) `Ta_Tb`."""
set_Ta_Tb!(value::SEXS, val) = value.Ta_Tb = val
"""Set [`SEXS`](@ref) `Tb`."""
set_Tb!(value::SEXS, val) = value.Tb = val
"""Set [`SEXS`](@ref) `K`."""
set_K!(value::SEXS, val) = value.K = val
"""Set [`SEXS`](@ref) `Te`."""
set_Te!(value::SEXS, val) = value.Te = val
"""Set [`SEXS`](@ref) `V_lim`."""
set_V_lim!(value::SEXS, val) = value.V_lim = val
"""Set [`SEXS`](@ref) `V_ref`."""
set_V_ref!(value::SEXS, val) = value.V_ref = val
"""Set [`SEXS`](@ref) `ext`."""
set_ext!(value::SEXS, val) = value.ext = val
"""Set [`SEXS`](@ref) `states_types`."""
set_states_types!(value::SEXS, val) = value.states_types = val
