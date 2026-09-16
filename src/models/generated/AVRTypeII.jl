#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct AVRTypeII <: AVR
        K0::Float64
        T1::Float64
        T2::Float64
        T3::Float64
        T4::Float64
        Te::Float64
        Tr::Float64
        Va_lim::MinMax
        Ae::Float64
        Be::Float64
        V_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

Parameters of an Automatic Voltage Regulator Type II -  Typical static exciter model

# Arguments
- `K0::Float64`: Regulator Gain, validation range: `(0, nothing)`
- `T1::Float64`: First Pole in s, validation range: `(0, nothing)`
- `T2::Float64`: First zero in s, validation range: `(0, nothing)`
- `T3::Float64`: First Pole in s, validation range: `(0, nothing)`
- `T4::Float64`: First zero in s, validation range: `(0, nothing)`
- `Te::Float64`: Field Circuit Time Constant in s, validation range: `(0, nothing)`
- `Tr::Float64`: Voltage Measurement Time Constant in s, validation range: `(0, nothing)`
- `Va_lim::MinMax`: Limits for pi controler `(Va_min, Va_max)`
- `Ae::Float64`: 1st ceiling coefficient, validation range: `(0, nothing)`
- `Be::Float64`: 2nd ceiling coefficient, validation range: `(0, nothing)`
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vf: Voltage field,
	Vr1: First Lead-Lag state,
	Vr2: Second lead-lag state,
	Vm: Measured voltage
- `n_states::Int`: (**Do not modify.**) AVR Type II has 4 states
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) AVR Type II has 4 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct AVRTypeII <: AVR
    "Regulator Gain"
    K0::Float64
    "First Pole in s"
    T1::Float64
    "First zero in s"
    T2::Float64
    "First Pole in s"
    T3::Float64
    "First zero in s"
    T4::Float64
    "Field Circuit Time Constant in s"
    Te::Float64
    "Voltage Measurement Time Constant in s"
    Tr::Float64
    "Limits for pi controler `(Va_min, Va_max)`"
    Va_lim::MinMax
    "1st ceiling coefficient"
    Ae::Float64
    "2nd ceiling coefficient"
    Be::Float64
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	Vf: Voltage field,
	Vr1: First Lead-Lag state,
	Vr2: Second lead-lag state,
	Vm: Measured voltage"
    states::Vector{Symbol}
    "(**Do not modify.**) AVR Type II has 4 states"
    n_states::Int
    "(**Do not modify.**) AVR Type II has 4 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function AVRTypeII(K0, T1, T2, T3, T4, Te, Tr, Va_lim, Ae, Be, V_ref=1.0, ext=Dict{String, Any}(), )
    AVRTypeII(K0, T1, T2, T3, T4, Te, Tr, Va_lim, Ae, Be, V_ref, ext, [:Vf, :Vr1, :Vr2, :Vm], 4, [StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function AVRTypeII(; K0, T1, T2, T3, T4, Te, Tr, Va_lim, Ae, Be, V_ref=1.0, ext=Dict{String, Any}(), states=[:Vf, :Vr1, :Vr2, :Vm], n_states=4, states_types=[StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    AVRTypeII(K0, T1, T2, T3, T4, Te, Tr, Va_lim, Ae, Be, V_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function AVRTypeII(::Nothing)
    AVRTypeII(;
        K0=0,
        T1=0,
        T2=0,
        T3=0,
        T4=0,
        Te=0,
        Tr=0,
        Va_lim=(min=0.0, max=0.0),
        Ae=0,
        Be=0,
        V_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`AVRTypeII`](@ref) `K0`."""
get_K0(value::AVRTypeII) = value.K0
"""Get [`AVRTypeII`](@ref) `T1`."""
get_T1(value::AVRTypeII) = value.T1
"""Get [`AVRTypeII`](@ref) `T2`."""
get_T2(value::AVRTypeII) = value.T2
"""Get [`AVRTypeII`](@ref) `T3`."""
get_T3(value::AVRTypeII) = value.T3
"""Get [`AVRTypeII`](@ref) `T4`."""
get_T4(value::AVRTypeII) = value.T4
"""Get [`AVRTypeII`](@ref) `Te`."""
get_Te(value::AVRTypeII) = value.Te
"""Get [`AVRTypeII`](@ref) `Tr`."""
get_Tr(value::AVRTypeII) = value.Tr
"""Get [`AVRTypeII`](@ref) `Va_lim`."""
get_Va_lim(value::AVRTypeII) = value.Va_lim
"""Get [`AVRTypeII`](@ref) `Ae`."""
get_Ae(value::AVRTypeII) = value.Ae
"""Get [`AVRTypeII`](@ref) `Be`."""
get_Be(value::AVRTypeII) = value.Be
"""Get [`AVRTypeII`](@ref) `V_ref`."""
get_V_ref(value::AVRTypeII) = value.V_ref
"""Get [`AVRTypeII`](@ref) `ext`."""
get_ext(value::AVRTypeII) = value.ext
"""Get [`AVRTypeII`](@ref) `states`."""
get_states(value::AVRTypeII) = value.states
"""Get [`AVRTypeII`](@ref) `n_states`."""
get_n_states(value::AVRTypeII) = value.n_states
"""Get [`AVRTypeII`](@ref) `states_types`."""
get_states_types(value::AVRTypeII) = value.states_types
"""Get [`AVRTypeII`](@ref) `internal`."""
get_internal(value::AVRTypeII) = value.internal

"""Set [`AVRTypeII`](@ref) `K0`."""
set_K0!(value::AVRTypeII, val) = value.K0 = val
"""Set [`AVRTypeII`](@ref) `T1`."""
set_T1!(value::AVRTypeII, val) = value.T1 = val
"""Set [`AVRTypeII`](@ref) `T2`."""
set_T2!(value::AVRTypeII, val) = value.T2 = val
"""Set [`AVRTypeII`](@ref) `T3`."""
set_T3!(value::AVRTypeII, val) = value.T3 = val
"""Set [`AVRTypeII`](@ref) `T4`."""
set_T4!(value::AVRTypeII, val) = value.T4 = val
"""Set [`AVRTypeII`](@ref) `Te`."""
set_Te!(value::AVRTypeII, val) = value.Te = val
"""Set [`AVRTypeII`](@ref) `Tr`."""
set_Tr!(value::AVRTypeII, val) = value.Tr = val
"""Set [`AVRTypeII`](@ref) `Va_lim`."""
set_Va_lim!(value::AVRTypeII, val) = value.Va_lim = val
"""Set [`AVRTypeII`](@ref) `Ae`."""
set_Ae!(value::AVRTypeII, val) = value.Ae = val
"""Set [`AVRTypeII`](@ref) `Be`."""
set_Be!(value::AVRTypeII, val) = value.Be = val
"""Set [`AVRTypeII`](@ref) `V_ref`."""
set_V_ref!(value::AVRTypeII, val) = value.V_ref = val
"""Set [`AVRTypeII`](@ref) `ext`."""
set_ext!(value::AVRTypeII, val) = value.ext = val
"""Set [`AVRTypeII`](@ref) `states_types`."""
set_states_types!(value::AVRTypeII, val) = value.states_types = val
