#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct IEEET1 <: ExcitationSystemDynamics
        Tr::Float64
        Ka::Float64
        Ta::Float64
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
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

1968 IEEE type 1 excitation system model

# Arguments
- `Tr::Float64`: Voltage Measurement Time Constant in s, validation range: `(0, 0.5)`
- `Ka::Float64`: Amplifier Gain, validation range: `(10, 500)`
- `Ta::Float64`: Amplifier Time Constant in s, validation range: `(0, 1)`
- `Vr_lim::MinMax`: Voltage regulator limits (regulator output) (Vi_min, Vi_max)
- `Ke::Float64`: Exciter constant related to self-excited field, validation range: `(-1, 1)`
- `Te::Float64`: Exciter time constant, integration rate associated with exciter control, validation range: `(0.0001, 1)`
- `Kf::Float64`: Excitation control system stabilizer gain, validation range: `(0.0001, 0.3)`
- `Tf::Float64`: Excitation control system stabilizer time constant. Appropiate Data: 5 <= Tf/Kf <= 15, validation range: `(0.0001, nothing)`
- `switch::Int`: Switch, validation range: `(0, 1)`
- `E_sat::Tuple{Float64, Float64}`: Exciter output voltage for saturation factor: (E1, E2)
- `Se::Tuple{Float64, Float64}`: Exciter saturation factor at exciter output voltage: (Se(E1), Se(E2))
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `saturation_coeffs::Tuple{Float64, Float64}`: (**Do not modify.**) Coefficients (A,B) of the function: Se(V) = B(V - A)^2/V
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vt: Terminal Voltage,
	Vr: Regulator Output,
	Vf: Exciter Output, 
	Vr3: Rate feedback integrator
- `n_states::Int`: (**Do not modify.**) The IEEET1 has 4 states
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) IEEET1 I has 4 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct IEEET1 <: ExcitationSystemDynamics
    "Voltage Measurement Time Constant in s"
    Tr::Float64
    "Amplifier Gain"
    Ka::Float64
    "Amplifier Time Constant in s"
    Ta::Float64
    "Voltage regulator limits (regulator output) (Vi_min, Vi_max)"
    Vr_lim::MinMax
    "Exciter constant related to self-excited field"
    Ke::Float64
    "Exciter time constant, integration rate associated with exciter control"
    Te::Float64
    "Excitation control system stabilizer gain"
    Kf::Float64
    "Excitation control system stabilizer time constant. Appropiate Data: 5 <= Tf/Kf <= 15"
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
	Vr: Regulator Output,
	Vf: Exciter Output, 
	Vr3: Rate feedback integrator"
    states::Vector{Symbol}
    "(**Do not modify.**) The IEEET1 has 4 states"
    n_states::Int
    "(**Do not modify.**) IEEET1 I has 4 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function IEEET1(Tr, Ka, Ta, Vr_lim, Ke, Te, Kf, Tf, switch, E_sat, Se, V_ref=1.0, ext=Dict{String, Any}(), )
    IEEET1(Tr, Ka, Ta, Vr_lim, Ke, Te, Kf, Tf, switch, E_sat, Se, V_ref, ext, PowerSystems.get_avr_saturation(E_sat, Se), [:Vt, :Vr1, :Vf, :Vr2], 4, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function IEEET1(; Tr, Ka, Ta, Vr_lim, Ke, Te, Kf, Tf, switch, E_sat, Se, V_ref=1.0, saturation_coeffs=PowerSystems.get_avr_saturation(E_sat, Se), ext=Dict{String, Any}(), states=[:Vt, :Vr1, :Vf, :Vr2], n_states=4, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    IEEET1(Tr, Ka, Ta, Vr_lim, Ke, Te, Kf, Tf, switch, E_sat, Se, V_ref, saturation_coeffs, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function IEEET1(::Nothing)
    IEEET1(;
        Tr=0,
        Ka=0,
        Ta=0,
        Vr_lim=(min=0.0, max=0.0),
        Ke=0,
        Te=0,
        Kf=0,
        Tf=0,
        switch=0,
        E_sat=(0.0, 0.0),
        Se=(0.0, 0.0),
        V_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`IEEET1`](@ref) `Tr`."""
get_Tr(value::IEEET1) = value.Tr
"""Get [`IEEET1`](@ref) `Ka`."""
get_Ka(value::IEEET1) = value.Ka
"""Get [`IEEET1`](@ref) `Ta`."""
get_Ta(value::IEEET1) = value.Ta
"""Get [`IEEET1`](@ref) `Vr_lim`."""
get_Vr_lim(value::IEEET1) = value.Vr_lim
"""Get [`IEEET1`](@ref) `Ke`."""
get_Ke(value::IEEET1) = value.Ke
"""Get [`IEEET1`](@ref) `Te`."""
get_Te(value::IEEET1) = value.Te
"""Get [`IEEET1`](@ref) `Kf`."""
get_Kf(value::IEEET1) = value.Kf
"""Get [`IEEET1`](@ref) `Tf`."""
get_Tf(value::IEEET1) = value.Tf
"""Get [`IEEET1`](@ref) `switch`."""
get_switch(value::IEEET1) = value.switch
"""Get [`IEEET1`](@ref) `E_sat`."""
get_E_sat(value::IEEET1) = value.E_sat
"""Get [`IEEET1`](@ref) `Se`."""
get_Se(value::IEEET1) = value.Se
"""Get [`IEEET1`](@ref) `V_ref`."""
get_V_ref(value::IEEET1) = value.V_ref
"""Get [`IEEET1`](@ref) `saturation_coeffs`."""
get_saturation_coeffs(value::IEEET1) = value.saturation_coeffs
"""Get [`IEEET1`](@ref) `ext`."""
get_ext(value::IEEET1) = value.ext
"""Get [`IEEET1`](@ref) `states`."""
get_states(value::IEEET1) = value.states
"""Get [`IEEET1`](@ref) `n_states`."""
get_n_states(value::IEEET1) = value.n_states
"""Get [`IEEET1`](@ref) `states_types`."""
get_states_types(value::IEEET1) = value.states_types
"""Get [`IEEET1`](@ref) `internal`."""
get_internal(value::IEEET1) = value.internal

"""Set [`IEEET1`](@ref) `Tr`."""
set_Tr!(value::IEEET1, val) = value.Tr = val
"""Set [`IEEET1`](@ref) `Ka`."""
set_Ka!(value::IEEET1, val) = value.Ka = val
"""Set [`IEEET1`](@ref) `Ta`."""
set_Ta!(value::IEEET1, val) = value.Ta = val
"""Set [`IEEET1`](@ref) `Vr_lim`."""
set_Vr_lim!(value::IEEET1, val) = value.Vr_lim = val
"""Set [`IEEET1`](@ref) `Ke`."""
set_Ke!(value::IEEET1, val) = value.Ke = val
"""Set [`IEEET1`](@ref) `Te`."""
set_Te!(value::IEEET1, val) = value.Te = val
"""Set [`IEEET1`](@ref) `Kf`."""
set_Kf!(value::IEEET1, val) = value.Kf = val
"""Set [`IEEET1`](@ref) `Tf`."""
set_Tf!(value::IEEET1, val) = value.Tf = val
"""Set [`IEEET1`](@ref) `switch`."""
set_switch!(value::IEEET1, val) = value.switch = val
"""Set [`IEEET1`](@ref) `E_sat`."""
set_E_sat!(value::IEEET1, val) = value.E_sat = val
"""Set [`IEEET1`](@ref) `Se`."""
set_Se!(value::IEEET1, val) = value.Se = val
"""Set [`IEEET1`](@ref) `V_ref`."""
set_V_ref!(value::IEEET1, val) = value.V_ref = val
"""Set [`IEEET1`](@ref) `saturation_coeffs`."""
set_saturation_coeffs!(value::IEEET1, val) = value.saturation_coeffs = val
"""Set [`IEEET1`](@ref) `ext`."""
set_ext!(value::IEEET1, val) = value.ext = val
"""Set [`IEEET1`](@ref) `states_types`."""
set_states_types!(value::IEEET1, val) = value.states_types = val



function from_openapi(po::PD.IEEET1, refs::OpenAPIRefs)
    return IEEET1(;
        Tr = _wire_required(po.tr, "IEEET1", "Tr"),
        Ka = _wire_required(po.ka, "IEEET1", "Ka"),
        Ta = _wire_required(po.ta, "IEEET1", "Ta"),
        Vr_lim = _or_default(po.vr_lim, nothing),
        Ke = _wire_required(po.ke, "IEEET1", "Ke"),
        Te = _wire_required(po.te, "IEEET1", "Te"),
        Kf = _wire_required(po.kf, "IEEET1", "Kf"),
        Tf = _wire_required(po.tf, "IEEET1", "Tf"),
        switch = _wire_required(po.switch, "IEEET1", "switch"),
        E_sat = _wire_to_psy(Tuple{Float64, Float64}, po.e_sat),
        Se = _wire_to_psy(Tuple{Float64, Float64}, po.se),
        V_ref = _or_default(po.v_ref, 1.0),
    )
end

function to_openapi(value::IEEET1, refs::OpenAPIRefs)
    return PD.IEEET1(;
        id = component_id(refs, value),
        tr = get_Tr(value),
        ka = get_Ka(value),
        ta = get_Ta(value),
        vr_lim = _minmax_po(get_Vr_lim(value)),
        ke = get_Ke(value),
        te = get_Te(value),
        kf = get_Kf(value),
        tf = get_Tf(value),
        switch = get_switch(value),
        e_sat = _psy_to_wire(get_E_sat(value)),
        se = _psy_to_wire(get_Se(value)),
        v_ref = get_V_ref(value),
    )
end
