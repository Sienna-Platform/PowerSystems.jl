#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ST6B <: AVR
        OEL_Flag::Int
        Tr::Float64
        K_pa::Float64
        K_ia::Float64
        K_da::Float64
        T_da::Float64
        Va_lim::MinMax
        K_ff::Float64
        K_m::Float64
        K_ci::Float64
        K_lr::Float64
        I_lr::Float64
        Vr_lim::MinMax
        Kg::Float64
        Tg::Float64
        V_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

In these excitation systems, voltage (and also current in compounded systems) is transformed to an appropriate level. Rectifiers, either controlled or non-controlled, provide the necessary direct current for the generator field.
Parameters of IEEE Std 421.5 Type ST6B Excitacion System. ST6B in PSSE and PSLF

# Arguments
- `OEL_Flag::Int`: OEL Flag for ST6B: 1: before HV gate, 2: after HV gate, validation range: `(0, 2)`
- `Tr::Float64`: Regulator input filter time constant in s, validation range: `(0, nothing)`
- `K_pa::Float64`: Regulator proportional gain, validation range: `(0, nothing)`
- `K_ia::Float64`: Regulator integral gain, validation range: `(0, nothing)`
- `K_da::Float64`: Regulator derivative gain, validation range: `(0, nothing)`
- `T_da::Float64`: Voltage regulator derivative channel time constant in s, validation range: `(0, nothing)`
- `Va_lim::MinMax`: Regulator output limits (Vi_min, Vi_max)
- `K_ff::Float64`: Pre-control gain of the inner loop field regulator, validation range: `(0, nothing)`
- `K_m::Float64`: Forward gain of the inner loop field regulator, validation range: `(0, nothing)`
- `K_ci::Float64`: Exciter output current limit adjustment gain, validation range: `(0, nothing)`
- `K_lr::Float64`: Exciter output current limiter gain, validation range: `(0, nothing)`
- `I_lr::Float64`: Exciter current limiter reference, validation range: `(0, nothing)`
- `Vr_lim::MinMax`: Voltage regulator limits (Vi_min, Vi_max)
- `Kg::Float64`: Feedback gain constant of the inner loop field regulator, validation range: `(0, nothing)`
- `Tg::Float64`: Feedback time constant of the inner loop field voltage regulator in s, validation range: `(0, nothing)`
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	x_i: Regulator Integrator,
	x_d: Regulator Derivative,
	Vg: Regulator Feedback
- `n_states::Int`: (**Do not modify.**) ST6B has 4 states
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) ST6B has 4 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ST6B <: AVR
    "OEL Flag for ST6B: 1: before HV gate, 2: after HV gate"
    OEL_Flag::Int
    "Regulator input filter time constant in s"
    Tr::Float64
    "Regulator proportional gain"
    K_pa::Float64
    "Regulator integral gain"
    K_ia::Float64
    "Regulator derivative gain"
    K_da::Float64
    "Voltage regulator derivative channel time constant in s"
    T_da::Float64
    "Regulator output limits (Vi_min, Vi_max)"
    Va_lim::MinMax
    "Pre-control gain of the inner loop field regulator"
    K_ff::Float64
    "Forward gain of the inner loop field regulator"
    K_m::Float64
    "Exciter output current limit adjustment gain"
    K_ci::Float64
    "Exciter output current limiter gain"
    K_lr::Float64
    "Exciter current limiter reference"
    I_lr::Float64
    "Voltage regulator limits (Vi_min, Vi_max)"
    Vr_lim::MinMax
    "Feedback gain constant of the inner loop field regulator"
    Kg::Float64
    "Feedback time constant of the inner loop field voltage regulator in s"
    Tg::Float64
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	x_i: Regulator Integrator,
	x_d: Regulator Derivative,
	Vg: Regulator Feedback"
    states::Vector{Symbol}
    "(**Do not modify.**) ST6B has 4 states"
    n_states::Int
    "(**Do not modify.**) ST6B has 4 states"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ST6B(OEL_Flag, Tr, K_pa, K_ia, K_da, T_da, Va_lim, K_ff, K_m, K_ci, K_lr, I_lr, Vr_lim, Kg, Tg, V_ref=1.0, ext=Dict{String, Any}(), )
    ST6B(OEL_Flag, Tr, K_pa, K_ia, K_da, T_da, Va_lim, K_ff, K_m, K_ci, K_lr, I_lr, Vr_lim, Kg, Tg, V_ref, ext, [:Vm, :x_i, :x_d, :Vg], 4, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], InfrastructureSystemsInternal(), )
end

function ST6B(; OEL_Flag, Tr, K_pa, K_ia, K_da, T_da, Va_lim, K_ff, K_m, K_ci, K_lr, I_lr, Vr_lim, Kg, Tg, V_ref=1.0, ext=Dict{String, Any}(), states=[:Vm, :x_i, :x_d, :Vg], n_states=4, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], internal=InfrastructureSystemsInternal(), )
    ST6B(OEL_Flag, Tr, K_pa, K_ia, K_da, T_da, Va_lim, K_ff, K_m, K_ci, K_lr, I_lr, Vr_lim, Kg, Tg, V_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function ST6B(::Nothing)
    ST6B(;
        OEL_Flag=0,
        Tr=0,
        K_pa=0,
        K_ia=0,
        K_da=0,
        T_da=0,
        Va_lim=(min=0.0, max=0.0),
        K_ff=0,
        K_m=0,
        K_ci=0,
        K_lr=0,
        I_lr=0,
        Vr_lim=(min=0.0, max=0.0),
        Kg=0,
        Tg=0,
        V_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ST6B`](@ref) `OEL_Flag`."""
get_OEL_Flag(value::ST6B) = value.OEL_Flag
"""Get [`ST6B`](@ref) `Tr`."""
get_Tr(value::ST6B) = value.Tr
"""Get [`ST6B`](@ref) `K_pa`."""
get_K_pa(value::ST6B) = value.K_pa
"""Get [`ST6B`](@ref) `K_ia`."""
get_K_ia(value::ST6B) = value.K_ia
"""Get [`ST6B`](@ref) `K_da`."""
get_K_da(value::ST6B) = value.K_da
"""Get [`ST6B`](@ref) `T_da`."""
get_T_da(value::ST6B) = value.T_da
"""Get [`ST6B`](@ref) `Va_lim`."""
get_Va_lim(value::ST6B) = value.Va_lim
"""Get [`ST6B`](@ref) `K_ff`."""
get_K_ff(value::ST6B) = value.K_ff
"""Get [`ST6B`](@ref) `K_m`."""
get_K_m(value::ST6B) = value.K_m
"""Get [`ST6B`](@ref) `K_ci`."""
get_K_ci(value::ST6B) = value.K_ci
"""Get [`ST6B`](@ref) `K_lr`."""
get_K_lr(value::ST6B) = value.K_lr
"""Get [`ST6B`](@ref) `I_lr`."""
get_I_lr(value::ST6B) = value.I_lr
"""Get [`ST6B`](@ref) `Vr_lim`."""
get_Vr_lim(value::ST6B) = value.Vr_lim
"""Get [`ST6B`](@ref) `Kg`."""
get_Kg(value::ST6B) = value.Kg
"""Get [`ST6B`](@ref) `Tg`."""
get_Tg(value::ST6B) = value.Tg
"""Get [`ST6B`](@ref) `V_ref`."""
get_V_ref(value::ST6B) = value.V_ref
"""Get [`ST6B`](@ref) `ext`."""
get_ext(value::ST6B) = value.ext
"""Get [`ST6B`](@ref) `states`."""
get_states(value::ST6B) = value.states
"""Get [`ST6B`](@ref) `n_states`."""
get_n_states(value::ST6B) = value.n_states
"""Get [`ST6B`](@ref) `states_types`."""
get_states_types(value::ST6B) = value.states_types
"""Get [`ST6B`](@ref) `internal`."""
get_internal(value::ST6B) = value.internal

"""Set [`ST6B`](@ref) `OEL_Flag`."""
set_OEL_Flag!(value::ST6B, val) = value.OEL_Flag = val
"""Set [`ST6B`](@ref) `Tr`."""
set_Tr!(value::ST6B, val) = value.Tr = val
"""Set [`ST6B`](@ref) `K_pa`."""
set_K_pa!(value::ST6B, val) = value.K_pa = val
"""Set [`ST6B`](@ref) `K_ia`."""
set_K_ia!(value::ST6B, val) = value.K_ia = val
"""Set [`ST6B`](@ref) `K_da`."""
set_K_da!(value::ST6B, val) = value.K_da = val
"""Set [`ST6B`](@ref) `T_da`."""
set_T_da!(value::ST6B, val) = value.T_da = val
"""Set [`ST6B`](@ref) `Va_lim`."""
set_Va_lim!(value::ST6B, val) = value.Va_lim = val
"""Set [`ST6B`](@ref) `K_ff`."""
set_K_ff!(value::ST6B, val) = value.K_ff = val
"""Set [`ST6B`](@ref) `K_m`."""
set_K_m!(value::ST6B, val) = value.K_m = val
"""Set [`ST6B`](@ref) `K_ci`."""
set_K_ci!(value::ST6B, val) = value.K_ci = val
"""Set [`ST6B`](@ref) `K_lr`."""
set_K_lr!(value::ST6B, val) = value.K_lr = val
"""Set [`ST6B`](@ref) `I_lr`."""
set_I_lr!(value::ST6B, val) = value.I_lr = val
"""Set [`ST6B`](@ref) `Vr_lim`."""
set_Vr_lim!(value::ST6B, val) = value.Vr_lim = val
"""Set [`ST6B`](@ref) `Kg`."""
set_Kg!(value::ST6B, val) = value.Kg = val
"""Set [`ST6B`](@ref) `Tg`."""
set_Tg!(value::ST6B, val) = value.Tg = val
"""Set [`ST6B`](@ref) `V_ref`."""
set_V_ref!(value::ST6B, val) = value.V_ref = val
"""Set [`ST6B`](@ref) `ext`."""
set_ext!(value::ST6B, val) = value.ext = val
"""Set [`ST6B`](@ref) `states_types`."""
set_states_types!(value::ST6B, val) = value.states_types = val
