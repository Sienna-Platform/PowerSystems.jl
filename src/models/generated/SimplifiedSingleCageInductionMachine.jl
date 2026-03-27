#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SimplifiedSingleCageInductionMachine <: DynamicInjection
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
        X_ss::Float64
        X_rr::Float64
        X_p::Float64
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of 3-states three-phase single cage induction machine with quadratic torque-speed relationship

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
- `X_ss::Float64`: (**Do not modify.**) Stator self reactance
- `X_rr::Float64`: (**Do not modify.**) Rotor self reactance
- `X_p::Float64`: (**Do not modify.**) Transient reactance
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	ψ_qr: rotor flux in the q-axis,
	ψ_dr: rotor flux in the d-axis, 
	ωr: Rotor speed [pu],
- `n_states::Int`: (**Do not modify.**) SimplifiedSingleCageInductionMachine has 3 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct SimplifiedSingleCageInductionMachine <: DynamicInjection
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
    "(**Do not modify.**) Stator self reactance"
    X_ss::Float64
    "(**Do not modify.**) Rotor self reactance"
    X_rr::Float64
    "(**Do not modify.**) Transient reactance"
    X_p::Float64
    "(**Do not modify.**) The [states](@ref S) are:
	ψ_qr: rotor flux in the q-axis,
	ψ_dr: rotor flux in the d-axis, 
	ωr: Rotor speed [pu],"
    states::Vector{Symbol}
    "(**Do not modify.**) SimplifiedSingleCageInductionMachine has 3 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function SimplifiedSingleCageInductionMachine(name, R_s, R_r, X_ls, X_lr, X_m, H, A, B, base_power, ext=Dict{String, Any}(), )
    SimplifiedSingleCageInductionMachine(name, R_s, R_r, X_ls, X_lr, X_m, H, A, B, base_power, ext, PowerSystems.calculate_IM_torque_params(A, B), 1.0, 0.0, X_ls + X_m, X_lr + X_m, X_ss - X_m^2 / X_rr, [:ψ_qr, :ψ_dr, :ωr], 3, InfrastructureSystemsInternal(), )
end

function SimplifiedSingleCageInductionMachine(; name, R_s, R_r, X_ls, X_lr, X_m, H, A, B, base_power, ext=Dict{String, Any}(), C=PowerSystems.calculate_IM_torque_params(A, B), τ_ref=1.0, B_shunt=0.0, X_ss=X_ls + X_m, X_rr=X_lr + X_m, X_p=X_ss - X_m^2 / X_rr, states=[:ψ_qr, :ψ_dr, :ωr], n_states=3, internal=InfrastructureSystemsInternal(), )
    SimplifiedSingleCageInductionMachine(name, R_s, R_r, X_ls, X_lr, X_m, H, A, B, base_power, ext, C, τ_ref, B_shunt, X_ss, X_rr, X_p, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function SimplifiedSingleCageInductionMachine(::Nothing)
    SimplifiedSingleCageInductionMachine(;
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

"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `name`."""
get_name(value::SimplifiedSingleCageInductionMachine) = value.name
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `R_s`."""
get_R_s(value::SimplifiedSingleCageInductionMachine) = value.R_s
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `R_r`."""
get_R_r(value::SimplifiedSingleCageInductionMachine) = value.R_r
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `X_ls`."""
get_X_ls(value::SimplifiedSingleCageInductionMachine) = value.X_ls
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `X_lr`."""
get_X_lr(value::SimplifiedSingleCageInductionMachine) = value.X_lr
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `X_m`."""
get_X_m(value::SimplifiedSingleCageInductionMachine) = value.X_m
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `H`."""
get_H(value::SimplifiedSingleCageInductionMachine) = value.H
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `A`."""
get_A(value::SimplifiedSingleCageInductionMachine) = value.A
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `B`."""
get_B(value::SimplifiedSingleCageInductionMachine) = value.B

_get_base_power(value::SimplifiedSingleCageInductionMachine) = value.base_power
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `ext`."""
get_ext(value::SimplifiedSingleCageInductionMachine) = value.ext
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `C`."""
get_C(value::SimplifiedSingleCageInductionMachine) = value.C
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `τ_ref`."""
get_τ_ref(value::SimplifiedSingleCageInductionMachine) = value.τ_ref
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `B_shunt`."""
get_B_shunt(value::SimplifiedSingleCageInductionMachine) = value.B_shunt
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `X_ss`."""
get_X_ss(value::SimplifiedSingleCageInductionMachine) = value.X_ss
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `X_rr`."""
get_X_rr(value::SimplifiedSingleCageInductionMachine) = value.X_rr
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `X_p`."""
get_X_p(value::SimplifiedSingleCageInductionMachine) = value.X_p
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `states`."""
get_states(value::SimplifiedSingleCageInductionMachine) = value.states
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `n_states`."""
get_n_states(value::SimplifiedSingleCageInductionMachine) = value.n_states
"""Get [`SimplifiedSingleCageInductionMachine`](@ref) `internal`."""
get_internal(value::SimplifiedSingleCageInductionMachine) = value.internal

"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `R_s`."""
set_R_s!(value::SimplifiedSingleCageInductionMachine, val) = value.R_s = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `R_r`."""
set_R_r!(value::SimplifiedSingleCageInductionMachine, val) = value.R_r = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `X_ls`."""
set_X_ls!(value::SimplifiedSingleCageInductionMachine, val) = value.X_ls = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `X_lr`."""
set_X_lr!(value::SimplifiedSingleCageInductionMachine, val) = value.X_lr = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `X_m`."""
set_X_m!(value::SimplifiedSingleCageInductionMachine, val) = value.X_m = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `H`."""
set_H!(value::SimplifiedSingleCageInductionMachine, val) = value.H = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `A`."""
set_A!(value::SimplifiedSingleCageInductionMachine, val) = value.A = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `B`."""
set_B!(value::SimplifiedSingleCageInductionMachine, val) = value.B = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `ext`."""
set_ext!(value::SimplifiedSingleCageInductionMachine, val) = value.ext = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `C`."""
set_C!(value::SimplifiedSingleCageInductionMachine, val) = value.C = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `τ_ref`."""
set_τ_ref!(value::SimplifiedSingleCageInductionMachine, val) = value.τ_ref = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `B_shunt`."""
set_B_shunt!(value::SimplifiedSingleCageInductionMachine, val) = value.B_shunt = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `X_ss`."""
set_X_ss!(value::SimplifiedSingleCageInductionMachine, val) = value.X_ss = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `X_rr`."""
set_X_rr!(value::SimplifiedSingleCageInductionMachine, val) = value.X_rr = val
"""Set [`SimplifiedSingleCageInductionMachine`](@ref) `X_p`."""
set_X_p!(value::SimplifiedSingleCageInductionMachine, val) = value.X_p = val
