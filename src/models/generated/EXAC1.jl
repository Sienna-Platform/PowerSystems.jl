#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct EXAC1 <: AVR
        Tr::Float64
        Tb::Float64
        Tc::Float64
        Ka::Float64
        Ta::Float64
        Vr_lim::MinMax
        Te::Float64
        Kf::Float64
        Tf::Float64
        Kc::Float64
        Kd::Float64
        Ke::Float64
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

Modified ESAC1A. This excitation systems consists of an alternator main exciter feeding its output via non-controlled rectifiers.
The exciter does not employ self-excitation, and the voltage regulator power is taken from a source that is not affected by external transients.
Parameters of IEEE Std 421.5 Type AC1A.  EXAC1 in PSSE and PSLF

# Arguments
- `Tr::Float64`: Regulator input filter time constant in s, validation range: `(0, 0.5)`
- `Tb::Float64`: Regulator denominator (lag) time constant in s, validation range: `(0, 20)`
- `Tc::Float64`: Regulator numerator (lead) time constant in s, validation range: `(0, 20)`
- `Ka::Float64`: Regulator output gain, validation range: `(0, 1000)`
- `Ta::Float64`: Regulator output time constant in s, validation range: `(0, 10)`
- `Vr_lim::MinMax`: Limits for regulator output `(Vr_min, Vr_max)`
- `Te::Float64`: Exciter field time constant in s, validation range: `(eps(), 2)`
- `Kf::Float64`: Rate feedback excitation system stabilizer gain, validation range: `(0, 0.3)`
- `Tf::Float64`: Rate feedback time constant, validation range: `(eps(), 1.5)`
- `Kc::Float64`: Rectifier loading factor proportional to commutating reactance, validation range: `(0, 1)`
- `Kd::Float64`: Demagnetizing factor, function of exciter alternator reactances, validation range: `(0, 1)`
- `Ke::Float64`: Exciter field proportional constant, validation range: `(0, 1)`
- `E_sat::Tuple{Float64, Float64}`: Exciter output voltage for saturation factor: (E1, E2)
- `Se::Tuple{Float64, Float64}`: Exciter saturation factor at exciter output voltage: (Se(E1), Se(E2))
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `saturation_coeffs::Tuple{Float64, Float64}`: (default: `PowerSystems.get_avr_saturation(E_sat, Se)`) (**Do not modify.**) Coefficients (A,B) of the function: Se(V) = B(V - A)^2/V
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	Vr1: Lead-lag state,
	Vr2: Regulator output state,
	Ve: Integrator output state,
	Vr3: Feedback output state
- `n_states::Int`: (**Do not modify.**) EXAC1 has 5 states
- `states_types::Vector{StateTypes.T}`: (**Do not modify.**) EXAC1 has 5 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct EXAC1 <: AVR
    "Regulator input filter time constant in s"
    Tr::Float64
    "Regulator denominator (lag) time constant in s"
    Tb::Float64
    "Regulator numerator (lead) time constant in s"
    Tc::Float64
    "Regulator output gain"
    Ka::Float64
    "Regulator output time constant in s"
    Ta::Float64
    "Limits for regulator output `(Vr_min, Vr_max)`"
    Vr_lim::MinMax
    "Exciter field time constant in s"
    Te::Float64
    "Rate feedback excitation system stabilizer gain"
    Kf::Float64
    "Rate feedback time constant"
    Tf::Float64
    "Rectifier loading factor proportional to commutating reactance"
    Kc::Float64
    "Demagnetizing factor, function of exciter alternator reactances"
    Kd::Float64
    "Exciter field proportional constant"
    Ke::Float64
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
	Vm: Sensed terminal voltage,
	Vr1: Lead-lag state,
	Vr2: Regulator output state,
	Ve: Integrator output state,
	Vr3: Feedback output state"
    states::Vector{Symbol}
    "(**Do not modify.**) EXAC1 has 5 states"
    n_states::Int
    "(**Do not modify.**) EXAC1 has 5 states"
    states_types::Vector{StateTypes.T}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function EXAC1(Tr, Tb, Tc, Ka, Ta, Vr_lim, Te, Kf, Tf, Kc, Kd, Ke, E_sat, Se, V_ref=1.0, saturation_coeffs=PowerSystems.get_avr_saturation(E_sat, Se), ext=Dict{String, Any}(), )
    EXAC1(Tr, Tb, Tc, Ka, Ta, Vr_lim, Te, Kf, Tf, Kc, Kd, Ke, E_sat, Se, V_ref, saturation_coeffs, ext, [:Vm, :Vr1, :Vr2, :Ve, :Vr3], 5, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function EXAC1(; Tr, Tb, Tc, Ka, Ta, Vr_lim, Te, Kf, Tf, Kc, Kd, Ke, E_sat, Se, V_ref=1.0, saturation_coeffs=PowerSystems.get_avr_saturation(E_sat, Se), ext=Dict{String, Any}(), states=[:Vm, :Vr1, :Vr2, :Ve, :Vr3], n_states=5, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    EXAC1(Tr, Tb, Tc, Ka, Ta, Vr_lim, Te, Kf, Tf, Kc, Kd, Ke, E_sat, Se, V_ref, saturation_coeffs, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function EXAC1(::Nothing)
    EXAC1(;
        Tr=0,
        Tb=0,
        Tc=0,
        Ka=0,
        Ta=0,
        Vr_lim=(min=0.0, max=0.0),
        Te=0,
        Kf=0,
        Tf=0,
        Kc=0,
        Kd=0,
        Ke=0,
        E_sat=(0.0, 0.0),
        Se=(0.0, 0.0),
        V_ref=0,
        saturation_coeffs=(0.0, 0.0),
        ext=Dict{String, Any}(),
    )
end

"""Get [`EXAC1`](@ref) `Tr`."""
get_Tr(value::EXAC1) = value.Tr
"""Get [`EXAC1`](@ref) `Tb`."""
get_Tb(value::EXAC1) = value.Tb
"""Get [`EXAC1`](@ref) `Tc`."""
get_Tc(value::EXAC1) = value.Tc
"""Get [`EXAC1`](@ref) `Ka`."""
get_Ka(value::EXAC1) = value.Ka
"""Get [`EXAC1`](@ref) `Ta`."""
get_Ta(value::EXAC1) = value.Ta
"""Get [`EXAC1`](@ref) `Vr_lim`."""
get_Vr_lim(value::EXAC1) = value.Vr_lim
"""Get [`EXAC1`](@ref) `Te`."""
get_Te(value::EXAC1) = value.Te
"""Get [`EXAC1`](@ref) `Kf`."""
get_Kf(value::EXAC1) = value.Kf
"""Get [`EXAC1`](@ref) `Tf`."""
get_Tf(value::EXAC1) = value.Tf
"""Get [`EXAC1`](@ref) `Kc`."""
get_Kc(value::EXAC1) = value.Kc
"""Get [`EXAC1`](@ref) `Kd`."""
get_Kd(value::EXAC1) = value.Kd
"""Get [`EXAC1`](@ref) `Ke`."""
get_Ke(value::EXAC1) = value.Ke
"""Get [`EXAC1`](@ref) `E_sat`."""
get_E_sat(value::EXAC1) = value.E_sat
"""Get [`EXAC1`](@ref) `Se`."""
get_Se(value::EXAC1) = value.Se
"""Get [`EXAC1`](@ref) `V_ref`."""
get_V_ref(value::EXAC1) = value.V_ref
"""Get [`EXAC1`](@ref) `saturation_coeffs`."""
get_saturation_coeffs(value::EXAC1) = value.saturation_coeffs
"""Get [`EXAC1`](@ref) `ext`."""
get_ext(value::EXAC1) = value.ext
"""Get [`EXAC1`](@ref) `states`."""
get_states(value::EXAC1) = value.states
"""Get [`EXAC1`](@ref) `n_states`."""
get_n_states(value::EXAC1) = value.n_states
"""Get [`EXAC1`](@ref) `states_types`."""
get_states_types(value::EXAC1) = value.states_types
"""Get [`EXAC1`](@ref) `internal`."""
get_internal(value::EXAC1) = value.internal

"""Set [`EXAC1`](@ref) `Tr`."""
set_Tr!(value::EXAC1, val) = value.Tr = val
"""Set [`EXAC1`](@ref) `Tb`."""
set_Tb!(value::EXAC1, val) = value.Tb = val
"""Set [`EXAC1`](@ref) `Tc`."""
set_Tc!(value::EXAC1, val) = value.Tc = val
"""Set [`EXAC1`](@ref) `Ka`."""
set_Ka!(value::EXAC1, val) = value.Ka = val
"""Set [`EXAC1`](@ref) `Ta`."""
set_Ta!(value::EXAC1, val) = value.Ta = val
"""Set [`EXAC1`](@ref) `Vr_lim`."""
set_Vr_lim!(value::EXAC1, val) = value.Vr_lim = val
"""Set [`EXAC1`](@ref) `Te`."""
set_Te!(value::EXAC1, val) = value.Te = val
"""Set [`EXAC1`](@ref) `Kf`."""
set_Kf!(value::EXAC1, val) = value.Kf = val
"""Set [`EXAC1`](@ref) `Tf`."""
set_Tf!(value::EXAC1, val) = value.Tf = val
"""Set [`EXAC1`](@ref) `Kc`."""
set_Kc!(value::EXAC1, val) = value.Kc = val
"""Set [`EXAC1`](@ref) `Kd`."""
set_Kd!(value::EXAC1, val) = value.Kd = val
"""Set [`EXAC1`](@ref) `Ke`."""
set_Ke!(value::EXAC1, val) = value.Ke = val
"""Set [`EXAC1`](@ref) `E_sat`."""
set_E_sat!(value::EXAC1, val) = value.E_sat = val
"""Set [`EXAC1`](@ref) `Se`."""
set_Se!(value::EXAC1, val) = value.Se = val
"""Set [`EXAC1`](@ref) `V_ref`."""
set_V_ref!(value::EXAC1, val) = value.V_ref = val
"""Set [`EXAC1`](@ref) `saturation_coeffs`."""
set_saturation_coeffs!(value::EXAC1, val) = value.saturation_coeffs = val
"""Set [`EXAC1`](@ref) `ext`."""
set_ext!(value::EXAC1, val) = value.ext = val
"""Set [`EXAC1`](@ref) `states_types`."""
set_states_types!(value::EXAC1, val) = value.states_types = val
