#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SingleCageInductionMachine <: DynamicInjection
        name::String
        R_s::Float64
        R_r::Float64
        X_ls::Float64
        X_lr::Float64
        X_m::Float64
        H::Float64
        A::Float64
        B::Float64
        base_power::Float64
        ext::Dict{String, Any}
        C::Float64
        τ_ref::Float64
        B_shunt::Float64
        X_ad::Float64
        X_aq::Float64
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of 5-states three-phase single cage induction machine with quadratic torque-speed relationship

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `R_s::Float64`: Armature stator resistance, validation range: `(0, nothing)`
- `R_r::Float64`: Rotor resistance, validation range: `(0, nothing)`
- `X_ls::Float64`: Stator Leakage Reactance, validation range: `(0, nothing)`
- `X_lr::Float64`: Rotor Leakage Reactance, validation range: `(0, nothing)`
- `X_m::Float64`: Stator-Rotor Mutual Reactance, validation range: `(0, nothing)`
- `H::Float64`: Motor Inertia Constant [s], validation range: `(0, nothing)`
- `A::Float64`: Torque-Speed Quadratic Term, validation range: `(0, 1)`
- `B::Float64`: Torque-Speed Linear Term, validation range: `(0, 1)`
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `C::Float64`: (**Do not modify.**) Torque-Speed Constant Term
- `τ_ref::Float64`: Reference torque parameter
- `B_shunt::Float64`: Susceptance Initialization Corrector Term
- `X_ad::Float64`: (**Do not modify.**) Equivalent d-axis reactance
- `X_aq::Float64`: (**Do not modify.**) Equivalent q-axis reactance
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	ψ_qs: stator flux in the q-axis,
	ψ_ds: stator flux in the d-axis,
	ψ_qr: rotor flux in the q-axis,
	ψ_dr: rotor flux in the d-axis, 
	ωr: Rotor speed [pu],
- `n_states::Int`: (**Do not modify.**) SingleCageInductionMachine has 5 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct SingleCageInductionMachine <: DynamicInjection
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Armature stator resistance"
    R_s::Float64
    "Rotor resistance"
    R_r::Float64
    "Stator Leakage Reactance"
    X_ls::Float64
    "Rotor Leakage Reactance"
    X_lr::Float64
    "Stator-Rotor Mutual Reactance"
    X_m::Float64
    "Motor Inertia Constant [s]"
    H::Float64
    "Torque-Speed Quadratic Term"
    A::Float64
    "Torque-Speed Linear Term"
    B::Float64
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) Torque-Speed Constant Term"
    C::Float64
    "Reference torque parameter"
    τ_ref::Float64
    "Susceptance Initialization Corrector Term"
    B_shunt::Float64
    "(**Do not modify.**) Equivalent d-axis reactance"
    X_ad::Float64
    "(**Do not modify.**) Equivalent q-axis reactance"
    X_aq::Float64
    "(**Do not modify.**) The [states](@ref S) are:
	ψ_qs: stator flux in the q-axis,
	ψ_ds: stator flux in the d-axis,
	ψ_qr: rotor flux in the q-axis,
	ψ_dr: rotor flux in the d-axis, 
	ωr: Rotor speed [pu],"
    states::Vector{Symbol}
    "(**Do not modify.**) SingleCageInductionMachine has 5 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function SingleCageInductionMachine(name, R_s, R_r, X_ls, X_lr, X_m, H, A, B, base_power, ext=Dict{String, Any}(), )
    SingleCageInductionMachine(name, R_s, R_r, X_ls, X_lr, X_m, H, A, B, base_power, ext, PowerSystems.calculate_IM_torque_params(A, B), 1.0, 0.0, (1.0 / X_m + 1.0 / X_ls + 1.0 / X_lr)^(-1), X_ad, [:ψ_qs, :ψ_ds, :ψ_qr, :ψ_dr, :ωr], 5, InfrastructureSystemsInternal(), )
end

function SingleCageInductionMachine(; name, R_s, R_r, X_ls, X_lr, X_m, H, A, B, base_power, ext=Dict{String, Any}(), C=PowerSystems.calculate_IM_torque_params(A, B), τ_ref=1.0, B_shunt=0.0, X_ad=(1.0 / X_m + 1.0 / X_ls + 1.0 / X_lr)^(-1), X_aq=X_ad, states=[:ψ_qs, :ψ_ds, :ψ_qr, :ψ_dr, :ωr], n_states=5, internal=InfrastructureSystemsInternal(), )
    SingleCageInductionMachine(name, R_s, R_r, X_ls, X_lr, X_m, H, A, B, base_power, ext, C, τ_ref, B_shunt, X_ad, X_aq, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function SingleCageInductionMachine(::Nothing)
    SingleCageInductionMachine(;
        name="init",
        R_s=0,
        R_r=0,
        X_ls=0,
        X_lr=0,
        X_m=0,
        H=0,
        A=0.0,
        B=0.0,
        base_power=100,
        ext=Dict{String, Any}(),
    )
end

"""Get [`SingleCageInductionMachine`](@ref) `name`."""
get_name(value::SingleCageInductionMachine) = value.name
"""Get [`SingleCageInductionMachine`](@ref) `R_s`."""
get_R_s(value::SingleCageInductionMachine) = value.R_s
"""Get [`SingleCageInductionMachine`](@ref) `R_r`."""
get_R_r(value::SingleCageInductionMachine) = value.R_r
"""Get [`SingleCageInductionMachine`](@ref) `X_ls`."""
get_X_ls(value::SingleCageInductionMachine) = value.X_ls
"""Get [`SingleCageInductionMachine`](@ref) `X_lr`."""
get_X_lr(value::SingleCageInductionMachine) = value.X_lr
"""Get [`SingleCageInductionMachine`](@ref) `X_m`."""
get_X_m(value::SingleCageInductionMachine) = value.X_m
"""Get [`SingleCageInductionMachine`](@ref) `H`."""
get_H(value::SingleCageInductionMachine) = value.H
"""Get [`SingleCageInductionMachine`](@ref) `A`."""
get_A(value::SingleCageInductionMachine) = value.A
"""Get [`SingleCageInductionMachine`](@ref) `B`."""
get_B(value::SingleCageInductionMachine) = value.B

_get_base_power(value::SingleCageInductionMachine) = value.base_power
"""Get [`SingleCageInductionMachine`](@ref) `ext`."""
get_ext(value::SingleCageInductionMachine) = value.ext
"""Get [`SingleCageInductionMachine`](@ref) `C`."""
get_C(value::SingleCageInductionMachine) = value.C
"""Get [`SingleCageInductionMachine`](@ref) `τ_ref`."""
get_τ_ref(value::SingleCageInductionMachine) = value.τ_ref
"""Get [`SingleCageInductionMachine`](@ref) `B_shunt`."""
get_B_shunt(value::SingleCageInductionMachine) = value.B_shunt
"""Get [`SingleCageInductionMachine`](@ref) `X_ad`."""
get_X_ad(value::SingleCageInductionMachine) = value.X_ad
"""Get [`SingleCageInductionMachine`](@ref) `X_aq`."""
get_X_aq(value::SingleCageInductionMachine) = value.X_aq
"""Get [`SingleCageInductionMachine`](@ref) `states`."""
get_states(value::SingleCageInductionMachine) = value.states
"""Get [`SingleCageInductionMachine`](@ref) `n_states`."""
get_n_states(value::SingleCageInductionMachine) = value.n_states
"""Get [`SingleCageInductionMachine`](@ref) `internal`."""
get_internal(value::SingleCageInductionMachine) = value.internal

"""Set [`SingleCageInductionMachine`](@ref) `R_s`."""
set_R_s!(value::SingleCageInductionMachine, val) = value.R_s = val
"""Set [`SingleCageInductionMachine`](@ref) `R_r`."""
set_R_r!(value::SingleCageInductionMachine, val) = value.R_r = val
"""Set [`SingleCageInductionMachine`](@ref) `X_ls`."""
set_X_ls!(value::SingleCageInductionMachine, val) = value.X_ls = val
"""Set [`SingleCageInductionMachine`](@ref) `X_lr`."""
set_X_lr!(value::SingleCageInductionMachine, val) = value.X_lr = val
"""Set [`SingleCageInductionMachine`](@ref) `X_m`."""
set_X_m!(value::SingleCageInductionMachine, val) = value.X_m = val
"""Set [`SingleCageInductionMachine`](@ref) `H`."""
set_H!(value::SingleCageInductionMachine, val) = value.H = val
"""Set [`SingleCageInductionMachine`](@ref) `A`."""
set_A!(value::SingleCageInductionMachine, val) = value.A = val
"""Set [`SingleCageInductionMachine`](@ref) `B`."""
set_B!(value::SingleCageInductionMachine, val) = value.B = val
"""Set [`SingleCageInductionMachine`](@ref) `ext`."""
set_ext!(value::SingleCageInductionMachine, val) = value.ext = val
"""Set [`SingleCageInductionMachine`](@ref) `C`."""
set_C!(value::SingleCageInductionMachine, val) = value.C = val
"""Set [`SingleCageInductionMachine`](@ref) `τ_ref`."""
set_τ_ref!(value::SingleCageInductionMachine, val) = value.τ_ref = val
"""Set [`SingleCageInductionMachine`](@ref) `B_shunt`."""
set_B_shunt!(value::SingleCageInductionMachine, val) = value.B_shunt = val
"""Set [`SingleCageInductionMachine`](@ref) `X_ad`."""
set_X_ad!(value::SingleCageInductionMachine, val) = value.X_ad = val
"""Set [`SingleCageInductionMachine`](@ref) `X_aq`."""
set_X_aq!(value::SingleCageInductionMachine, val) = value.X_aq = val
