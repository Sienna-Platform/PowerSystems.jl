#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ESDC2A <: AVR
        Tr::Float64
        Ka::Float64
        Ta::Float64
        Tb::Float64
        Tc::Float64
        Vr_lim::MinMax
        Ke::Float64
        Te::Float64
        Kf::Float64
        Tf::Float64
        switch::Int
        E_sat::Tuple{Float64, Float64}
        Se::Tuple{Float64, Float64}
        V_ref::Float64
        saturation_coeffs::Tuple{Float64, Float64}
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.T}
        internal::InfrastructureSystemsInternal
    end

Is used to represent field-controlled dc commutator exciters with continuously acting voltage regulators having power supplies derived from the generator or auxiliaries bus.
Parameters of IEEE Std 421.5 Type DC2A Excitacion System. This model corresponds to ESDC2A in PSSE and PSLF

# Arguments
- `Tr::Float64`: Voltage Measurement Time Constant in s, validation range: `(0, 0.5)`
- `Ka::Float64`: Amplifier Gain, validation range: `(10, 500)`
- `Ta::Float64`: Amplifier Time Constant in s, validation range: `(0, 1)`
- `Tb::Float64`: Regulator input Time Constant in s, validation range: `(0, nothing)`
- `Tc::Float64`: Regulator input Time Constant in s, validation range: `(0, nothing)`
- `Vr_lim::MinMax`: Voltage regulator limits (regulator output) (Vi_min, Vi_max)
- `Ke::Float64`: Exciter constant related to self-excited field, validation range: `(-1, 1)`
- `Te::Float64`: Exciter time constant, integration rate associated with exciter control, validation range: `(eps(), 2)`
- `Kf::Float64`: Excitation control system stabilizer gain, validation range: `(0, 0.3)`
- `Tf::Float64`: Excitation control system stabilizer time constant. Appropiate Data: 5.0 <= Tf/Kf <= 15.0, validation range: `(eps(), 1.5)`
- `switch::Int`: Switch, validation range: `(0, 1)`
- `E_sat::Tuple{Float64, Float64}`: Exciter output voltage for saturation factor: (E1, E2)
- `Se::Tuple{Float64, Float64}`: Exciter saturation factor at exciter output voltage: (Se(E1), Se(E2))
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `saturation_coeffs::Tuple{Float64, Float64}`: (default: `PowerSystems.get_avr_saturation(E_sat, Se)`) (**Do not modify.**) Coefficients (A,B) of the function: Se(V) = B(V - A)^2/V
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vt: Terminal Voltage,
	Vr1: input lead lag,
	Vr2: Regulator Output,
	Vf: Exciter Output, 
	Vr3: Rate feedback integrator
- `n_states::Int`: (**Do not modify.**) The ESDC2A has 5 states
- `states_types::Vector{StateTypes.T}`: (**Do not modify.**) ESDC2A has 5 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ESDC2A <: AVR
    "Voltage Measurement Time Constant in s"
    Tr::Float64
    "Amplifier Gain"
    Ka::Float64
    "Amplifier Time Constant in s"
    Ta::Float64
    "Regulator input Time Constant in s"
    Tb::Float64
    "Regulator input Time Constant in s"
    Tc::Float64
    "Voltage regulator limits (regulator output) (Vi_min, Vi_max)"
    Vr_lim::MinMax
    "Exciter constant related to self-excited field"
    Ke::Float64
    "Exciter time constant, integration rate associated with exciter control"
    Te::Float64
    "Excitation control system stabilizer gain"
    Kf::Float64
    "Excitation control system stabilizer time constant. Appropiate Data: 5.0 <= Tf/Kf <= 15.0"
    Tf::Float64
    "Switch"
    switch::Int
    "Exciter output voltage for saturation factor: (E1, E2)"
    E_sat::Tuple{Float64, Float64}
    "Exciter saturation factor at exciter output voltage: (Se(E1), Se(E2))"
    Se::Tuple{Float64, Float64}
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "(**Do not modify.**) Coefficients (A,B) of the function: Se(V) = B(V - A)^2/V"
    saturation_coeffs::Tuple{Float64, Float64}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	Vt: Terminal Voltage,
	Vr1: input lead lag,
	Vr2: Regulator Output,
	Vf: Exciter Output, 
	Vr3: Rate feedback integrator"
    states::Vector{Symbol}
    "(**Do not modify.**) The ESDC2A has 5 states"
    n_states::Int
    "(**Do not modify.**) ESDC2A has 5 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.T}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ESDC2A(Tr, Ka, Ta, Tb, Tc, Vr_lim, Ke, Te, Kf, Tf, switch, E_sat, Se, V_ref=1.0, saturation_coeffs=PowerSystems.get_avr_saturation(E_sat, Se), ext=Dict{String, Any}(), )
    ESDC2A(Tr, Ka, Ta, Tb, Tc, Vr_lim, Ke, Te, Kf, Tf, switch, E_sat, Se, V_ref, saturation_coeffs, ext, [:Vt, :Vr1, :Vr2, :Vf, :Vr3], 5, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function ESDC2A(; Tr, Ka, Ta, Tb, Tc, Vr_lim, Ke, Te, Kf, Tf, switch, E_sat, Se, V_ref=1.0, saturation_coeffs=PowerSystems.get_avr_saturation(E_sat, Se), ext=Dict{String, Any}(), states=[:Vt, :Vr1, :Vr2, :Vf, :Vr3], n_states=5, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    ESDC2A(Tr, Ka, Ta, Tb, Tc, Vr_lim, Ke, Te, Kf, Tf, switch, E_sat, Se, V_ref, saturation_coeffs, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function ESDC2A(::Nothing)
    ESDC2A(;
        Tr=0,
        Ka=0,
        Ta=0,
        Tb=0,
        Tc=0,
        Vr_lim=(min=0.0, max=0.0),
        Ke=0,
        Te=0,
        Kf=0,
        Tf=0,
        switch=0,
        E_sat=(0.0, 0.0),
        Se=(0.0, 0.0),
        V_ref=0,
        saturation_coeffs=(0.0, 0.0),
        ext=Dict{String, Any}(),
    )
end

"""Get [`ESDC2A`](@ref) `Tr`."""
get_Tr(value::ESDC2A) = value.Tr
"""Get [`ESDC2A`](@ref) `Ka`."""
get_Ka(value::ESDC2A) = value.Ka
"""Get [`ESDC2A`](@ref) `Ta`."""
get_Ta(value::ESDC2A) = value.Ta
"""Get [`ESDC2A`](@ref) `Tb`."""
get_Tb(value::ESDC2A) = value.Tb
"""Get [`ESDC2A`](@ref) `Tc`."""
get_Tc(value::ESDC2A) = value.Tc
"""Get [`ESDC2A`](@ref) `Vr_lim`."""
get_Vr_lim(value::ESDC2A) = value.Vr_lim
"""Get [`ESDC2A`](@ref) `Ke`."""
get_Ke(value::ESDC2A) = value.Ke
"""Get [`ESDC2A`](@ref) `Te`."""
get_Te(value::ESDC2A) = value.Te
"""Get [`ESDC2A`](@ref) `Kf`."""
get_Kf(value::ESDC2A) = value.Kf
"""Get [`ESDC2A`](@ref) `Tf`."""
get_Tf(value::ESDC2A) = value.Tf
"""Get [`ESDC2A`](@ref) `switch`."""
get_switch(value::ESDC2A) = value.switch
"""Get [`ESDC2A`](@ref) `E_sat`."""
get_E_sat(value::ESDC2A) = value.E_sat
"""Get [`ESDC2A`](@ref) `Se`."""
get_Se(value::ESDC2A) = value.Se
"""Get [`ESDC2A`](@ref) `V_ref`."""
get_V_ref(value::ESDC2A) = value.V_ref
"""Get [`ESDC2A`](@ref) `saturation_coeffs`."""
get_saturation_coeffs(value::ESDC2A) = value.saturation_coeffs
"""Get [`ESDC2A`](@ref) `ext`."""
get_ext(value::ESDC2A) = value.ext
"""Get [`ESDC2A`](@ref) `states`."""
get_states(value::ESDC2A) = value.states
"""Get [`ESDC2A`](@ref) `n_states`."""
get_n_states(value::ESDC2A) = value.n_states
"""Get [`ESDC2A`](@ref) `states_types`."""
get_states_types(value::ESDC2A) = value.states_types
"""Get [`ESDC2A`](@ref) `internal`."""
get_internal(value::ESDC2A) = value.internal

"""Set [`ESDC2A`](@ref) `Tr`."""
set_Tr!(value::ESDC2A, val) = value.Tr = val
"""Set [`ESDC2A`](@ref) `Ka`."""
set_Ka!(value::ESDC2A, val) = value.Ka = val
"""Set [`ESDC2A`](@ref) `Ta`."""
set_Ta!(value::ESDC2A, val) = value.Ta = val
"""Set [`ESDC2A`](@ref) `Tb`."""
set_Tb!(value::ESDC2A, val) = value.Tb = val
"""Set [`ESDC2A`](@ref) `Tc`."""
set_Tc!(value::ESDC2A, val) = value.Tc = val
"""Set [`ESDC2A`](@ref) `Vr_lim`."""
set_Vr_lim!(value::ESDC2A, val) = value.Vr_lim = val
"""Set [`ESDC2A`](@ref) `Ke`."""
set_Ke!(value::ESDC2A, val) = value.Ke = val
"""Set [`ESDC2A`](@ref) `Te`."""
set_Te!(value::ESDC2A, val) = value.Te = val
"""Set [`ESDC2A`](@ref) `Kf`."""
set_Kf!(value::ESDC2A, val) = value.Kf = val
"""Set [`ESDC2A`](@ref) `Tf`."""
set_Tf!(value::ESDC2A, val) = value.Tf = val
"""Set [`ESDC2A`](@ref) `switch`."""
set_switch!(value::ESDC2A, val) = value.switch = val
"""Set [`ESDC2A`](@ref) `E_sat`."""
set_E_sat!(value::ESDC2A, val) = value.E_sat = val
"""Set [`ESDC2A`](@ref) `Se`."""
set_Se!(value::ESDC2A, val) = value.Se = val
"""Set [`ESDC2A`](@ref) `V_ref`."""
set_V_ref!(value::ESDC2A, val) = value.V_ref = val
"""Set [`ESDC2A`](@ref) `saturation_coeffs`."""
set_saturation_coeffs!(value::ESDC2A, val) = value.saturation_coeffs = val
"""Set [`ESDC2A`](@ref) `ext`."""
set_ext!(value::ESDC2A, val) = value.ext = val
"""Set [`ESDC2A`](@ref) `states_types`."""
set_states_types!(value::ESDC2A, val) = value.states_types = val
