#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct EXPIC1 <: AVR
        Tr::Float64
        Ka::Float64
        Ta::Float64
        Va_lim::MinMax
        Ta_2::Float64
        Ta_3::Float64
        Ta_4::Float64
        Vr_lim::MinMax
        Kf::Float64
        Tf_1::Float64
        Tf_2::Float64
        Efd_lim::MinMax
        Ke::Float64
        Te::Float64
        E_sat::Tuple{Float64, Float64}
        Se::Tuple{Float64, Float64}
        Kp::Float64
        Ki::Float64
        Kc::Float64
        V_ref::Float64
        saturation_coeffs::Tuple{Float64, Float64}
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.T}
        internal::InfrastructureSystemsInternal
    end

Generic Proportional/Integral Excitation System

# Arguments
- `Tr::Float64`: Regulator input filter time constant in s, validation range: `(0, 0.5)`
- `Ka::Float64`: Voltage regulator gain, validation range: `(1, 500)`
- `Ta::Float64`: Voltage regulator time constant in s, validation range: `(0, 10)`
- `Va_lim::MinMax`: Limits for pi controler `(Vr_min, Vr_max)`
- `Ta_2::Float64`: Voltage regulator time constant in s, validation range: `(0, nothing)`
- `Ta_3::Float64`: Voltage regulator time constant in s, validation range: `(0, nothing)`
- `Ta_4::Float64`: Voltage regulator time constant in s, validation range: `(0, nothing)`
- `Vr_lim::MinMax`: Voltage regulator limits (regulator output) (Vi_min, Vi_max)
- `Kf::Float64`: Rate feedback gain, validation range: `(0, 0.3)`
- `Tf_1::Float64`: Rate Feedback time constant in s, validation range: `(eps(), 15)`
- `Tf_2::Float64`: Rate Feedback time constant in s, validation range: `(0, 5)`
- `Efd_lim::MinMax`: Field Voltage regulator limits (regulator output) (Efd_min, Efd_max)
- `Ke::Float64`: Exciter constant, validation range: `(0, 1)`
- `Te::Float64`: Exciter time constant, validation range: `(0, 2)`
- `E_sat::Tuple{Float64, Float64}`: Exciter output voltage for saturation factor: (E1, E2)
- `Se::Tuple{Float64, Float64}`: Exciter saturation factor at exciter output voltage: (Se(E1), Se(E2))
- `Kp::Float64`: Potential source gain, validation range: `(0, 5)`
- `Ki::Float64`: current source gain, validation range: `(0, 1.1)`
- `Kc::Float64`: Exciter regulation factor, validation range: `(0, 2)`
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `saturation_coeffs::Tuple{Float64, Float64}`: (default: `PowerSystems.get_avr_saturation(E_sat, Se)`) (**Do not modify.**) Coefficients (A,B) of the function: Se(V) = B(V - A)^2/V
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	Vr1: First Lead-lag state,
	Vr2: Second regulator lead-lag state,
	Vr2: Third regulator lead-lag state 
	Vf: Exciter output 
	Vr3: First feedback integrator,
	Vr4: second feedback integrator
- `n_states::Int`: (**Do not modify.**) EXPIC1 has 6 states
- `states_types::Vector{StateTypes.T}`: (**Do not modify.**) EXPIC has 6 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct EXPIC1 <: AVR
    "Regulator input filter time constant in s"
    Tr::Float64
    "Voltage regulator gain"
    Ka::Float64
    "Voltage regulator time constant in s"
    Ta::Float64
    "Limits for pi controler `(Vr_min, Vr_max)`"
    Va_lim::MinMax
    "Voltage regulator time constant in s"
    Ta_2::Float64
    "Voltage regulator time constant in s"
    Ta_3::Float64
    "Voltage regulator time constant in s"
    Ta_4::Float64
    "Voltage regulator limits (regulator output) (Vi_min, Vi_max)"
    Vr_lim::MinMax
    "Rate feedback gain"
    Kf::Float64
    "Rate Feedback time constant in s"
    Tf_1::Float64
    "Rate Feedback time constant in s"
    Tf_2::Float64
    "Field Voltage regulator limits (regulator output) (Efd_min, Efd_max)"
    Efd_lim::MinMax
    "Exciter constant"
    Ke::Float64
    "Exciter time constant"
    Te::Float64
    "Exciter output voltage for saturation factor: (E1, E2)"
    E_sat::Tuple{Float64, Float64}
    "Exciter saturation factor at exciter output voltage: (Se(E1), Se(E2))"
    Se::Tuple{Float64, Float64}
    "Potential source gain"
    Kp::Float64
    "current source gain"
    Ki::Float64
    "Exciter regulation factor"
    Kc::Float64
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "(**Do not modify.**) Coefficients (A,B) of the function: Se(V) = B(V - A)^2/V"
    saturation_coeffs::Tuple{Float64, Float64}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	Vr1: First Lead-lag state,
	Vr2: Second regulator lead-lag state,
	Vr2: Third regulator lead-lag state 
	Vf: Exciter output 
	Vr3: First feedback integrator,
	Vr4: second feedback integrator"
    states::Vector{Symbol}
    "(**Do not modify.**) EXPIC1 has 6 states"
    n_states::Int
    "(**Do not modify.**) EXPIC has 6 states"
    states_types::Vector{StateTypes.T}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function EXPIC1(Tr, Ka, Ta, Va_lim, Ta_2, Ta_3, Ta_4, Vr_lim, Kf, Tf_1, Tf_2, Efd_lim, Ke, Te, E_sat, Se, Kp, Ki, Kc, V_ref=1.0, saturation_coeffs=PowerSystems.get_avr_saturation(E_sat, Se), ext=Dict{String, Any}(), )
    EXPIC1(Tr, Ka, Ta, Va_lim, Ta_2, Ta_3, Ta_4, Vr_lim, Kf, Tf_1, Tf_2, Efd_lim, Ke, Te, E_sat, Se, Kp, Ki, Kc, V_ref, saturation_coeffs, ext, [:Vm, :Vr1, :Vr2, :Vf, :Vr3, :Vr4], 6, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential, StateTypes.Hybrid], InfrastructureSystemsInternal(), )
end

function EXPIC1(; Tr, Ka, Ta, Va_lim, Ta_2, Ta_3, Ta_4, Vr_lim, Kf, Tf_1, Tf_2, Efd_lim, Ke, Te, E_sat, Se, Kp, Ki, Kc, V_ref=1.0, saturation_coeffs=PowerSystems.get_avr_saturation(E_sat, Se), ext=Dict{String, Any}(), states=[:Vm, :Vr1, :Vr2, :Vf, :Vr3, :Vr4], n_states=6, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential, StateTypes.Hybrid], internal=InfrastructureSystemsInternal(), )
    EXPIC1(Tr, Ka, Ta, Va_lim, Ta_2, Ta_3, Ta_4, Vr_lim, Kf, Tf_1, Tf_2, Efd_lim, Ke, Te, E_sat, Se, Kp, Ki, Kc, V_ref, saturation_coeffs, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function EXPIC1(::Nothing)
    EXPIC1(;
        Tr=0,
        Ka=0,
        Ta=0,
        Va_lim=(min=0.0, max=0.0),
        Ta_2=0,
        Ta_3=0,
        Ta_4=0,
        Vr_lim=(min=0.0, max=0.0),
        Kf=0,
        Tf_1=0,
        Tf_2=0,
        Efd_lim=(min=0.0, max=0.0),
        Ke=0,
        Te=0,
        E_sat=(0.0, 0.0),
        Se=(0.0, 0.0),
        Kp=0,
        Ki=0,
        Kc=0,
        V_ref=0,
        saturation_coeffs=(0.0, 0.0),
        ext=Dict{String, Any}(),
    )
end

"""Get [`EXPIC1`](@ref) `Tr`."""
get_Tr(value::EXPIC1) = value.Tr
"""Get [`EXPIC1`](@ref) `Ka`."""
get_Ka(value::EXPIC1) = value.Ka
"""Get [`EXPIC1`](@ref) `Ta`."""
get_Ta(value::EXPIC1) = value.Ta
"""Get [`EXPIC1`](@ref) `Va_lim`."""
get_Va_lim(value::EXPIC1) = value.Va_lim
"""Get [`EXPIC1`](@ref) `Ta_2`."""
get_Ta_2(value::EXPIC1) = value.Ta_2
"""Get [`EXPIC1`](@ref) `Ta_3`."""
get_Ta_3(value::EXPIC1) = value.Ta_3
"""Get [`EXPIC1`](@ref) `Ta_4`."""
get_Ta_4(value::EXPIC1) = value.Ta_4
"""Get [`EXPIC1`](@ref) `Vr_lim`."""
get_Vr_lim(value::EXPIC1) = value.Vr_lim
"""Get [`EXPIC1`](@ref) `Kf`."""
get_Kf(value::EXPIC1) = value.Kf
"""Get [`EXPIC1`](@ref) `Tf_1`."""
get_Tf_1(value::EXPIC1) = value.Tf_1
"""Get [`EXPIC1`](@ref) `Tf_2`."""
get_Tf_2(value::EXPIC1) = value.Tf_2
"""Get [`EXPIC1`](@ref) `Efd_lim`."""
get_Efd_lim(value::EXPIC1) = value.Efd_lim
"""Get [`EXPIC1`](@ref) `Ke`."""
get_Ke(value::EXPIC1) = value.Ke
"""Get [`EXPIC1`](@ref) `Te`."""
get_Te(value::EXPIC1) = value.Te
"""Get [`EXPIC1`](@ref) `E_sat`."""
get_E_sat(value::EXPIC1) = value.E_sat
"""Get [`EXPIC1`](@ref) `Se`."""
get_Se(value::EXPIC1) = value.Se
"""Get [`EXPIC1`](@ref) `Kp`."""
get_Kp(value::EXPIC1) = value.Kp
"""Get [`EXPIC1`](@ref) `Ki`."""
get_Ki(value::EXPIC1) = value.Ki
"""Get [`EXPIC1`](@ref) `Kc`."""
get_Kc(value::EXPIC1) = value.Kc
"""Get [`EXPIC1`](@ref) `V_ref`."""
get_V_ref(value::EXPIC1) = value.V_ref
"""Get [`EXPIC1`](@ref) `saturation_coeffs`."""
get_saturation_coeffs(value::EXPIC1) = value.saturation_coeffs
"""Get [`EXPIC1`](@ref) `ext`."""
get_ext(value::EXPIC1) = value.ext
"""Get [`EXPIC1`](@ref) `states`."""
get_states(value::EXPIC1) = value.states
"""Get [`EXPIC1`](@ref) `n_states`."""
get_n_states(value::EXPIC1) = value.n_states
"""Get [`EXPIC1`](@ref) `states_types`."""
get_states_types(value::EXPIC1) = value.states_types
"""Get [`EXPIC1`](@ref) `internal`."""
get_internal(value::EXPIC1) = value.internal

"""Set [`EXPIC1`](@ref) `Tr`."""
set_Tr!(value::EXPIC1, val) = value.Tr = val
"""Set [`EXPIC1`](@ref) `Ka`."""
set_Ka!(value::EXPIC1, val) = value.Ka = val
"""Set [`EXPIC1`](@ref) `Ta`."""
set_Ta!(value::EXPIC1, val) = value.Ta = val
"""Set [`EXPIC1`](@ref) `Va_lim`."""
set_Va_lim!(value::EXPIC1, val) = value.Va_lim = val
"""Set [`EXPIC1`](@ref) `Ta_2`."""
set_Ta_2!(value::EXPIC1, val) = value.Ta_2 = val
"""Set [`EXPIC1`](@ref) `Ta_3`."""
set_Ta_3!(value::EXPIC1, val) = value.Ta_3 = val
"""Set [`EXPIC1`](@ref) `Ta_4`."""
set_Ta_4!(value::EXPIC1, val) = value.Ta_4 = val
"""Set [`EXPIC1`](@ref) `Vr_lim`."""
set_Vr_lim!(value::EXPIC1, val) = value.Vr_lim = val
"""Set [`EXPIC1`](@ref) `Kf`."""
set_Kf!(value::EXPIC1, val) = value.Kf = val
"""Set [`EXPIC1`](@ref) `Tf_1`."""
set_Tf_1!(value::EXPIC1, val) = value.Tf_1 = val
"""Set [`EXPIC1`](@ref) `Tf_2`."""
set_Tf_2!(value::EXPIC1, val) = value.Tf_2 = val
"""Set [`EXPIC1`](@ref) `Efd_lim`."""
set_Efd_lim!(value::EXPIC1, val) = value.Efd_lim = val
"""Set [`EXPIC1`](@ref) `Ke`."""
set_Ke!(value::EXPIC1, val) = value.Ke = val
"""Set [`EXPIC1`](@ref) `Te`."""
set_Te!(value::EXPIC1, val) = value.Te = val
"""Set [`EXPIC1`](@ref) `E_sat`."""
set_E_sat!(value::EXPIC1, val) = value.E_sat = val
"""Set [`EXPIC1`](@ref) `Se`."""
set_Se!(value::EXPIC1, val) = value.Se = val
"""Set [`EXPIC1`](@ref) `Kp`."""
set_Kp!(value::EXPIC1, val) = value.Kp = val
"""Set [`EXPIC1`](@ref) `Ki`."""
set_Ki!(value::EXPIC1, val) = value.Ki = val
"""Set [`EXPIC1`](@ref) `Kc`."""
set_Kc!(value::EXPIC1, val) = value.Kc = val
"""Set [`EXPIC1`](@ref) `V_ref`."""
set_V_ref!(value::EXPIC1, val) = value.V_ref = val
"""Set [`EXPIC1`](@ref) `saturation_coeffs`."""
set_saturation_coeffs!(value::EXPIC1, val) = value.saturation_coeffs = val
"""Set [`EXPIC1`](@ref) `ext`."""
set_ext!(value::EXPIC1, val) = value.ext = val
"""Set [`EXPIC1`](@ref) `states_types`."""
set_states_types!(value::EXPIC1, val) = value.states_types = val
