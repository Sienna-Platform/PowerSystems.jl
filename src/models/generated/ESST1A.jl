#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ESST1A <: AVR
        UEL_flags::Int
        PSS_flags::Int
        Tr::Float64
        Vi_lim::Tuple{Float64, Float64}
        Tc::Float64
        Tb::Float64
        Tc1::Float64
        Tb1::Float64
        Ka::Float64
        Ta::Float64
        Va_lim::MinMax
        Vr_lim::MinMax
        Kc::Float64
        Kf::Float64
        Tf::Float64
        K_lr::Float64
        I_lr::Float64
        V_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

This excitation system supplies power through a transformer from the generator terminals and its regulated by a controlled rectifier (via thyristors).
Parameters of IEEE Std 421.5 Type ST1A Excitacion System. ESST1A in PSSE and PSLF

# Arguments
- `UEL_flags::Int`: Code input for Underexcitization limiter (UEL) entry. Not supported, validation range: `(1, 3)`
- `PSS_flags::Int`: Code input for Power System Stabilizer (PSS) or (VOS) entry, validation range: `(1, 2)`
- `Tr::Float64`: Regulator input filter time constant in s, validation range: `(0, 0.1)`
- `Vi_lim::Tuple{Float64, Float64}`: Voltage error limits (regulator input) (Vi_min, Vi_max)
- `Tc::Float64`: First regulator denominator (lead) time constant in s, validation range: `(0, 10)`
- `Tb::Float64`: First regulator denominator (lag) time constant in s, validation range: `(0, 20)`
- `Tc1::Float64`: Second regulator denominator (lead) time constant in s, validation range: `(0, 10)`
- `Tb1::Float64`: Second regulator denominator (lead) time constant in s, validation range: `(0, 20)`
- `Ka::Float64`: Voltage regulator gain, validation range: `(50, 1000)`
- `Ta::Float64`: Voltage regulator time constant in s, validation range: `(0, 0.5)`
- `Va_lim::MinMax`: Limits for regulator output `(Va_min, Va_max)`
- `Vr_lim::MinMax`: Limits for exciter output `(Vr_min, Vr_max)`
- `Kc::Float64`: Rectifier loading factor proportional to commutating reactance, validation range: `(0, 0.3)`
- `Kf::Float64`: Rate feedback gain, validation range: `(0, 0.3)`
- `Tf::Float64`: Rate feedback time constant in s, validation range: `(eps(), 1.5)`
- `K_lr::Float64`: Exciter output current limiter gain, validation range: `(0, 5)`
- `I_lr::Float64`: Exciter output current limit reference, validation range: `(0, 5)`
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	Vr1: First Lead-lag state,
	Vr2: Second lead-lag state,
	Va: Regulator output state,
	Vr3: Feedback output state
- `n_states::Int`: (**Do not modify.**) ST1A has 5 states
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) ST1A has 5 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ESST1A <: AVR
    "Code input for Underexcitization limiter (UEL) entry. Not supported"
    UEL_flags::Int
    "Code input for Power System Stabilizer (PSS) or (VOS) entry"
    PSS_flags::Int
    "Regulator input filter time constant in s"
    Tr::Float64
    "Voltage error limits (regulator input) (Vi_min, Vi_max)"
    Vi_lim::Tuple{Float64, Float64}
    "First regulator denominator (lead) time constant in s"
    Tc::Float64
    "First regulator denominator (lag) time constant in s"
    Tb::Float64
    "Second regulator denominator (lead) time constant in s"
    Tc1::Float64
    "Second regulator denominator (lead) time constant in s"
    Tb1::Float64
    "Voltage regulator gain"
    Ka::Float64
    "Voltage regulator time constant in s"
    Ta::Float64
    "Limits for regulator output `(Va_min, Va_max)`"
    Va_lim::MinMax
    "Limits for exciter output `(Vr_min, Vr_max)`"
    Vr_lim::MinMax
    "Rectifier loading factor proportional to commutating reactance"
    Kc::Float64
    "Rate feedback gain"
    Kf::Float64
    "Rate feedback time constant in s"
    Tf::Float64
    "Exciter output current limiter gain"
    K_lr::Float64
    "Exciter output current limit reference"
    I_lr::Float64
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	Vr1: First Lead-lag state,
	Vr2: Second lead-lag state,
	Va: Regulator output state,
	Vr3: Feedback output state"
    states::Vector{Symbol}
    "(**Do not modify.**) ST1A has 5 states"
    n_states::Int
    "(**Do not modify.**) ST1A has 5 states"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ESST1A(UEL_flags, PSS_flags, Tr, Vi_lim, Tc, Tb, Tc1, Tb1, Ka, Ta, Va_lim, Vr_lim, Kc, Kf, Tf, K_lr, I_lr, V_ref=1.0, ext=Dict{String, Any}(), )
    ESST1A(UEL_flags, PSS_flags, Tr, Vi_lim, Tc, Tb, Tc1, Tb1, Ka, Ta, Va_lim, Vr_lim, Kc, Kf, Tf, K_lr, I_lr, V_ref, ext, [:Vm, :Vr1, :Vr2, :Va, :Vr3], 5, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function ESST1A(; UEL_flags, PSS_flags, Tr, Vi_lim, Tc, Tb, Tc1, Tb1, Ka, Ta, Va_lim, Vr_lim, Kc, Kf, Tf, K_lr, I_lr, V_ref=1.0, ext=Dict{String, Any}(), states=[:Vm, :Vr1, :Vr2, :Va, :Vr3], n_states=5, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    ESST1A(UEL_flags, PSS_flags, Tr, Vi_lim, Tc, Tb, Tc1, Tb1, Ka, Ta, Va_lim, Vr_lim, Kc, Kf, Tf, K_lr, I_lr, V_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function ESST1A(::Nothing)
    ESST1A(;
        UEL_flags=1,
        PSS_flags=1,
        Tr=0,
        Vi_lim=(0.0, 0.0),
        Tc=0,
        Tb=0,
        Tc1=0,
        Tb1=0,
        Ka=0,
        Ta=0,
        Va_lim=(min=0.0, max=0.0),
        Vr_lim=(min=0.0, max=0.0),
        Kc=0,
        Kf=0,
        Tf=0,
        K_lr=0,
        I_lr=0,
        V_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ESST1A`](@ref) `UEL_flags`."""
get_UEL_flags(value::ESST1A) = value.UEL_flags
"""Get [`ESST1A`](@ref) `PSS_flags`."""
get_PSS_flags(value::ESST1A) = value.PSS_flags
"""Get [`ESST1A`](@ref) `Tr`."""
get_Tr(value::ESST1A) = value.Tr
"""Get [`ESST1A`](@ref) `Vi_lim`."""
get_Vi_lim(value::ESST1A) = value.Vi_lim
"""Get [`ESST1A`](@ref) `Tc`."""
get_Tc(value::ESST1A) = value.Tc
"""Get [`ESST1A`](@ref) `Tb`."""
get_Tb(value::ESST1A) = value.Tb
"""Get [`ESST1A`](@ref) `Tc1`."""
get_Tc1(value::ESST1A) = value.Tc1
"""Get [`ESST1A`](@ref) `Tb1`."""
get_Tb1(value::ESST1A) = value.Tb1
"""Get [`ESST1A`](@ref) `Ka`."""
get_Ka(value::ESST1A) = value.Ka
"""Get [`ESST1A`](@ref) `Ta`."""
get_Ta(value::ESST1A) = value.Ta
"""Get [`ESST1A`](@ref) `Va_lim`."""
get_Va_lim(value::ESST1A) = value.Va_lim
"""Get [`ESST1A`](@ref) `Vr_lim`."""
get_Vr_lim(value::ESST1A) = value.Vr_lim
"""Get [`ESST1A`](@ref) `Kc`."""
get_Kc(value::ESST1A) = value.Kc
"""Get [`ESST1A`](@ref) `Kf`."""
get_Kf(value::ESST1A) = value.Kf
"""Get [`ESST1A`](@ref) `Tf`."""
get_Tf(value::ESST1A) = value.Tf
"""Get [`ESST1A`](@ref) `K_lr`."""
get_K_lr(value::ESST1A) = value.K_lr
"""Get [`ESST1A`](@ref) `I_lr`."""
get_I_lr(value::ESST1A) = value.I_lr
"""Get [`ESST1A`](@ref) `V_ref`."""
get_V_ref(value::ESST1A) = value.V_ref
"""Get [`ESST1A`](@ref) `ext`."""
get_ext(value::ESST1A) = value.ext
"""Get [`ESST1A`](@ref) `states`."""
get_states(value::ESST1A) = value.states
"""Get [`ESST1A`](@ref) `n_states`."""
get_n_states(value::ESST1A) = value.n_states
"""Get [`ESST1A`](@ref) `states_types`."""
get_states_types(value::ESST1A) = value.states_types
"""Get [`ESST1A`](@ref) `internal`."""
get_internal(value::ESST1A) = value.internal

"""Set [`ESST1A`](@ref) `UEL_flags`."""
set_UEL_flags!(value::ESST1A, val) = value.UEL_flags = val
"""Set [`ESST1A`](@ref) `PSS_flags`."""
set_PSS_flags!(value::ESST1A, val) = value.PSS_flags = val
"""Set [`ESST1A`](@ref) `Tr`."""
set_Tr!(value::ESST1A, val) = value.Tr = val
"""Set [`ESST1A`](@ref) `Vi_lim`."""
set_Vi_lim!(value::ESST1A, val) = value.Vi_lim = val
"""Set [`ESST1A`](@ref) `Tc`."""
set_Tc!(value::ESST1A, val) = value.Tc = val
"""Set [`ESST1A`](@ref) `Tb`."""
set_Tb!(value::ESST1A, val) = value.Tb = val
"""Set [`ESST1A`](@ref) `Tc1`."""
set_Tc1!(value::ESST1A, val) = value.Tc1 = val
"""Set [`ESST1A`](@ref) `Tb1`."""
set_Tb1!(value::ESST1A, val) = value.Tb1 = val
"""Set [`ESST1A`](@ref) `Ka`."""
set_Ka!(value::ESST1A, val) = value.Ka = val
"""Set [`ESST1A`](@ref) `Ta`."""
set_Ta!(value::ESST1A, val) = value.Ta = val
"""Set [`ESST1A`](@ref) `Va_lim`."""
set_Va_lim!(value::ESST1A, val) = value.Va_lim = val
"""Set [`ESST1A`](@ref) `Vr_lim`."""
set_Vr_lim!(value::ESST1A, val) = value.Vr_lim = val
"""Set [`ESST1A`](@ref) `Kc`."""
set_Kc!(value::ESST1A, val) = value.Kc = val
"""Set [`ESST1A`](@ref) `Kf`."""
set_Kf!(value::ESST1A, val) = value.Kf = val
"""Set [`ESST1A`](@ref) `Tf`."""
set_Tf!(value::ESST1A, val) = value.Tf = val
"""Set [`ESST1A`](@ref) `K_lr`."""
set_K_lr!(value::ESST1A, val) = value.K_lr = val
"""Set [`ESST1A`](@ref) `I_lr`."""
set_I_lr!(value::ESST1A, val) = value.I_lr = val
"""Set [`ESST1A`](@ref) `V_ref`."""
set_V_ref!(value::ESST1A, val) = value.V_ref = val
"""Set [`ESST1A`](@ref) `ext`."""
set_ext!(value::ESST1A, val) = value.ext = val
"""Set [`ESST1A`](@ref) `states_types`."""
set_states_types!(value::ESST1A, val) = value.states_types = val
