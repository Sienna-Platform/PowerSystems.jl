#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct AVRTypeI <: AVR
        Ka::Float64
        Ke::Float64
        Kf::Float64
        Ta::Float64
        Te::Float64
        Tf::Float64
        Tr::Float64
        Va_lim::MinMax
        Ae::Float64
        Be::Float64
        V_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.T}
        internal::InfrastructureSystemsInternal
    end

Parameters of an Automatic Voltage Regulator Type I - Resembles IEEE Type DC1

# Arguments
- `Ka::Float64`: Amplifier Gain, validation range: `(0, nothing)`
- `Ke::Float64`: Field circuit integral deviation, validation range: `(0, nothing)`
- `Kf::Float64`: Stabilizer Gain in s * pu/pu, validation range: `(0, nothing)`
- `Ta::Float64`: Amplifier Time Constant in s, validation range: `(0, nothing)`
- `Te::Float64`: Field Circuit Time Constant in s, validation range: `(0, nothing)`
- `Tf::Float64`: Stabilizer Time Constant in s, validation range: `(0, nothing)`
- `Tr::Float64`: Voltage Measurement Time Constant in s, validation range: `(0, nothing)`
- `Va_lim::MinMax`: Limits for pi controler `(Va_min, Va_max)`
- `Ae::Float64`: 1st ceiling coefficient, validation range: `(0, nothing)`
- `Be::Float64`: 2nd ceiling coefficient, validation range: `(0, nothing)`
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vf: Voltage field,
	Vr1: Amplifier State,
	Vr2: Stabilizing Feedback State,
	Vm: Measured voltage
- `n_states::Int`: (**Do not modify.**) The AVR Type I has 4 states
- `states_types::Vector{StateTypes.T}`: (**Do not modify.**) AVR Type I has 4 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct AVRTypeI <: AVR
    "Amplifier Gain"
    Ka::Float64
    "Field circuit integral deviation"
    Ke::Float64
    "Stabilizer Gain in s * pu/pu"
    Kf::Float64
    "Amplifier Time Constant in s"
    Ta::Float64
    "Field Circuit Time Constant in s"
    Te::Float64
    "Stabilizer Time Constant in s"
    Tf::Float64
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
	Vr1: Amplifier State,
	Vr2: Stabilizing Feedback State,
	Vm: Measured voltage"
    states::Vector{Symbol}
    "(**Do not modify.**) The AVR Type I has 4 states"
    n_states::Int
    "(**Do not modify.**) AVR Type I has 4 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.T}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function AVRTypeI(Ka, Ke, Kf, Ta, Te, Tf, Tr, Va_lim, Ae, Be, V_ref=1.0, ext=Dict{String, Any}(), )
    AVRTypeI(Ka, Ke, Kf, Ta, Te, Tf, Tr, Va_lim, Ae, Be, V_ref, ext, [:Vf, :Vr1, :Vr2, :Vm], 4, [StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function AVRTypeI(; Ka, Ke, Kf, Ta, Te, Tf, Tr, Va_lim, Ae, Be, V_ref=1.0, ext=Dict{String, Any}(), states=[:Vf, :Vr1, :Vr2, :Vm], n_states=4, states_types=[StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    AVRTypeI(Ka, Ke, Kf, Ta, Te, Tf, Tr, Va_lim, Ae, Be, V_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function AVRTypeI(::Nothing)
    AVRTypeI(;
        Ka=0,
        Ke=0,
        Kf=0,
        Ta=0,
        Te=0,
        Tf=0,
        Tr=0,
        Va_lim=(min=0.0, max=0.0),
        Ae=0,
        Be=0,
        V_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`AVRTypeI`](@ref) `Ka`."""
get_Ka(value::AVRTypeI) = value.Ka
"""Get [`AVRTypeI`](@ref) `Ke`."""
get_Ke(value::AVRTypeI) = value.Ke
"""Get [`AVRTypeI`](@ref) `Kf`."""
get_Kf(value::AVRTypeI) = value.Kf
"""Get [`AVRTypeI`](@ref) `Ta`."""
get_Ta(value::AVRTypeI) = value.Ta
"""Get [`AVRTypeI`](@ref) `Te`."""
get_Te(value::AVRTypeI) = value.Te
"""Get [`AVRTypeI`](@ref) `Tf`."""
get_Tf(value::AVRTypeI) = value.Tf
"""Get [`AVRTypeI`](@ref) `Tr`."""
get_Tr(value::AVRTypeI) = value.Tr
"""Get [`AVRTypeI`](@ref) `Va_lim`."""
get_Va_lim(value::AVRTypeI) = value.Va_lim
"""Get [`AVRTypeI`](@ref) `Ae`."""
get_Ae(value::AVRTypeI) = value.Ae
"""Get [`AVRTypeI`](@ref) `Be`."""
get_Be(value::AVRTypeI) = value.Be
"""Get [`AVRTypeI`](@ref) `V_ref`."""
get_V_ref(value::AVRTypeI) = value.V_ref
"""Get [`AVRTypeI`](@ref) `ext`."""
get_ext(value::AVRTypeI) = value.ext
"""Get [`AVRTypeI`](@ref) `states`."""
get_states(value::AVRTypeI) = value.states
"""Get [`AVRTypeI`](@ref) `n_states`."""
get_n_states(value::AVRTypeI) = value.n_states
"""Get [`AVRTypeI`](@ref) `states_types`."""
get_states_types(value::AVRTypeI) = value.states_types
"""Get [`AVRTypeI`](@ref) `internal`."""
get_internal(value::AVRTypeI) = value.internal

"""Set [`AVRTypeI`](@ref) `Ka`."""
set_Ka!(value::AVRTypeI, val) = value.Ka = val
"""Set [`AVRTypeI`](@ref) `Ke`."""
set_Ke!(value::AVRTypeI, val) = value.Ke = val
"""Set [`AVRTypeI`](@ref) `Kf`."""
set_Kf!(value::AVRTypeI, val) = value.Kf = val
"""Set [`AVRTypeI`](@ref) `Ta`."""
set_Ta!(value::AVRTypeI, val) = value.Ta = val
"""Set [`AVRTypeI`](@ref) `Te`."""
set_Te!(value::AVRTypeI, val) = value.Te = val
"""Set [`AVRTypeI`](@ref) `Tf`."""
set_Tf!(value::AVRTypeI, val) = value.Tf = val
"""Set [`AVRTypeI`](@ref) `Tr`."""
set_Tr!(value::AVRTypeI, val) = value.Tr = val
"""Set [`AVRTypeI`](@ref) `Va_lim`."""
set_Va_lim!(value::AVRTypeI, val) = value.Va_lim = val
"""Set [`AVRTypeI`](@ref) `Ae`."""
set_Ae!(value::AVRTypeI, val) = value.Ae = val
"""Set [`AVRTypeI`](@ref) `Be`."""
set_Be!(value::AVRTypeI, val) = value.Be = val
"""Set [`AVRTypeI`](@ref) `V_ref`."""
set_V_ref!(value::AVRTypeI, val) = value.V_ref = val
"""Set [`AVRTypeI`](@ref) `ext`."""
set_ext!(value::AVRTypeI, val) = value.ext = val
"""Set [`AVRTypeI`](@ref) `states_types`."""
set_states_types!(value::AVRTypeI, val) = value.states_types = val
