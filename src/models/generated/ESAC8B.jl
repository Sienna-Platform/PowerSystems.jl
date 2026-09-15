#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ESAC8B <: AVR
        Tr::Float64
        Kp::Float64
        Ki::Float64
        Kd::Float64
        Td::Float64
        Ka::Float64
        Ta::Float64
        Vr_lim::MinMax
        Te::Float64
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

Excitation System AC8B. Used to represent the Basler Digital Excitation Control System (DECS) with PID controller in PSSE.

# Arguments
- `Tr::Float64`: Regulator input filter time constant in s, validation range: `(0, nothing)`
- `Kp::Float64`: Regulator proportional PID gain, validation range: `(0, nothing)`
- `Ki::Float64`: Regulator integral PID gain, validation range: `(0, nothing)`
- `Kd::Float64`: Regulator derivative PID gain, validation range: `(0, nothing)`
- `Td::Float64`: Regulator derivative PID time constant., validation range: `(0, 10)`
- `Ka::Float64`: Regulator output gain, validation range: `(0, 1000)`
- `Ta::Float64`: Regulator output lag time constant in s, validation range: `(0, 10)`
- `Vr_lim::MinMax`: Limits for exciter field voltage `(Vr_min, Vr_max)`
- `Te::Float64`: Exciter field time constant, validation range: `(eps(), 2)`
- `Ke::Float64`: Exciter field proportional constant, validation range: `(0, 2)`
- `E_sat::Tuple{Float64, Float64}`: Exciter output voltage for saturation factor: (E1, E2)
- `Se::Tuple{Float64, Float64}`: Exciter saturation factor at exciter output voltage: (Se(E1), Se(E2))
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `saturation_coeffs::Tuple{Float64, Float64}`: (default: `PowerSystems.get_avr_saturation(E_sat, Se)`) (**Do not modify.**) Coefficients (A,B) of the function: Se(V) = B(V - A)^2/V
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	x_i: Internal PI-block state,
	x_d: Internal Derivative-block state,
	Vr: Voltage regulator state,
	Efd: Exciter output state
- `n_states::Int`: (**Do not modify.**) ESAC8B has 5 states
- `states_types::Vector{StateTypes.T}`: (**Do not modify.**) ESAC8B has 5 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ESAC8B <: AVR
    "Regulator input filter time constant in s"
    Tr::Float64
    "Regulator proportional PID gain"
    Kp::Float64
    "Regulator integral PID gain"
    Ki::Float64
    "Regulator derivative PID gain"
    Kd::Float64
    "Regulator derivative PID time constant."
    Td::Float64
    "Regulator output gain"
    Ka::Float64
    "Regulator output lag time constant in s"
    Ta::Float64
    "Limits for exciter field voltage `(Vr_min, Vr_max)`"
    Vr_lim::MinMax
    "Exciter field time constant"
    Te::Float64
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
	x_i: Internal PI-block state,
	x_d: Internal Derivative-block state,
	Vr: Voltage regulator state,
	Efd: Exciter output state"
    states::Vector{Symbol}
    "(**Do not modify.**) ESAC8B has 5 states"
    n_states::Int
    "(**Do not modify.**) ESAC8B has 5 states"
    states_types::Vector{StateTypes.T}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ESAC8B(Tr, Kp, Ki, Kd, Td, Ka, Ta, Vr_lim, Te, Ke, E_sat, Se, V_ref=1.0, saturation_coeffs=PowerSystems.get_avr_saturation(E_sat, Se), ext=Dict{String, Any}(), )
    ESAC8B(Tr, Kp, Ki, Kd, Td, Ka, Ta, Vr_lim, Te, Ke, E_sat, Se, V_ref, saturation_coeffs, ext, [:Vm, :x_i, :x_d, :Vr, :Efd], 5, [StateTypes.Hybrid, StateTypes.Differential, StateTypes.Differential, StateTypes.Hybrid, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function ESAC8B(; Tr, Kp, Ki, Kd, Td, Ka, Ta, Vr_lim, Te, Ke, E_sat, Se, V_ref=1.0, saturation_coeffs=PowerSystems.get_avr_saturation(E_sat, Se), ext=Dict{String, Any}(), states=[:Vm, :x_i, :x_d, :Vr, :Efd], n_states=5, states_types=[StateTypes.Hybrid, StateTypes.Differential, StateTypes.Differential, StateTypes.Hybrid, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    ESAC8B(Tr, Kp, Ki, Kd, Td, Ka, Ta, Vr_lim, Te, Ke, E_sat, Se, V_ref, saturation_coeffs, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function ESAC8B(::Nothing)
    ESAC8B(;
        Tr=0,
        Kp=0,
        Ki=0,
        Kd=0,
        Td=0,
        Ka=0,
        Ta=0,
        Vr_lim=(min=0.0, max=0.0),
        Te=0,
        Ke=0,
        E_sat=(0.0, 0.0),
        Se=(0.0, 0.0),
        V_ref=0,
        saturation_coeffs=(0.0, 0.0),
        ext=Dict{String, Any}(),
    )
end

"""Get [`ESAC8B`](@ref) `Tr`."""
get_Tr(value::ESAC8B) = value.Tr
"""Get [`ESAC8B`](@ref) `Kp`."""
get_Kp(value::ESAC8B) = value.Kp
"""Get [`ESAC8B`](@ref) `Ki`."""
get_Ki(value::ESAC8B) = value.Ki
"""Get [`ESAC8B`](@ref) `Kd`."""
get_Kd(value::ESAC8B) = value.Kd
"""Get [`ESAC8B`](@ref) `Td`."""
get_Td(value::ESAC8B) = value.Td
"""Get [`ESAC8B`](@ref) `Ka`."""
get_Ka(value::ESAC8B) = value.Ka
"""Get [`ESAC8B`](@ref) `Ta`."""
get_Ta(value::ESAC8B) = value.Ta
"""Get [`ESAC8B`](@ref) `Vr_lim`."""
get_Vr_lim(value::ESAC8B) = value.Vr_lim
"""Get [`ESAC8B`](@ref) `Te`."""
get_Te(value::ESAC8B) = value.Te
"""Get [`ESAC8B`](@ref) `Ke`."""
get_Ke(value::ESAC8B) = value.Ke
"""Get [`ESAC8B`](@ref) `E_sat`."""
get_E_sat(value::ESAC8B) = value.E_sat
"""Get [`ESAC8B`](@ref) `Se`."""
get_Se(value::ESAC8B) = value.Se
"""Get [`ESAC8B`](@ref) `V_ref`."""
get_V_ref(value::ESAC8B) = value.V_ref
"""Get [`ESAC8B`](@ref) `saturation_coeffs`."""
get_saturation_coeffs(value::ESAC8B) = value.saturation_coeffs
"""Get [`ESAC8B`](@ref) `ext`."""
get_ext(value::ESAC8B) = value.ext
"""Get [`ESAC8B`](@ref) `states`."""
get_states(value::ESAC8B) = value.states
"""Get [`ESAC8B`](@ref) `n_states`."""
get_n_states(value::ESAC8B) = value.n_states
"""Get [`ESAC8B`](@ref) `states_types`."""
get_states_types(value::ESAC8B) = value.states_types
"""Get [`ESAC8B`](@ref) `internal`."""
get_internal(value::ESAC8B) = value.internal

"""Set [`ESAC8B`](@ref) `Tr`."""
set_Tr!(value::ESAC8B, val) = value.Tr = val
"""Set [`ESAC8B`](@ref) `Kp`."""
set_Kp!(value::ESAC8B, val) = value.Kp = val
"""Set [`ESAC8B`](@ref) `Ki`."""
set_Ki!(value::ESAC8B, val) = value.Ki = val
"""Set [`ESAC8B`](@ref) `Kd`."""
set_Kd!(value::ESAC8B, val) = value.Kd = val
"""Set [`ESAC8B`](@ref) `Td`."""
set_Td!(value::ESAC8B, val) = value.Td = val
"""Set [`ESAC8B`](@ref) `Ka`."""
set_Ka!(value::ESAC8B, val) = value.Ka = val
"""Set [`ESAC8B`](@ref) `Ta`."""
set_Ta!(value::ESAC8B, val) = value.Ta = val
"""Set [`ESAC8B`](@ref) `Vr_lim`."""
set_Vr_lim!(value::ESAC8B, val) = value.Vr_lim = val
"""Set [`ESAC8B`](@ref) `Te`."""
set_Te!(value::ESAC8B, val) = value.Te = val
"""Set [`ESAC8B`](@ref) `Ke`."""
set_Ke!(value::ESAC8B, val) = value.Ke = val
"""Set [`ESAC8B`](@ref) `E_sat`."""
set_E_sat!(value::ESAC8B, val) = value.E_sat = val
"""Set [`ESAC8B`](@ref) `Se`."""
set_Se!(value::ESAC8B, val) = value.Se = val
"""Set [`ESAC8B`](@ref) `V_ref`."""
set_V_ref!(value::ESAC8B, val) = value.V_ref = val
"""Set [`ESAC8B`](@ref) `saturation_coeffs`."""
set_saturation_coeffs!(value::ESAC8B, val) = value.saturation_coeffs = val
"""Set [`ESAC8B`](@ref) `ext`."""
set_ext!(value::ESAC8B, val) = value.ext = val
"""Set [`ESAC8B`](@ref) `states_types`."""
set_states_types!(value::ESAC8B, val) = value.states_types = val
