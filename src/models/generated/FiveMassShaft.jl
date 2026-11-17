#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct FiveMassShaft <: Shaft
        H::Float64
        H_hp::Float64
        H_ip::Float64
        H_lp::Float64
        H_ex::Float64
        D::Float64
        D_hp::Float64
        D_ip::Float64
        D_lp::Float64
        D_ex::Float64
        D_12::Float64
        D_23::Float64
        D_34::Float64
        D_45::Float64
        K_hp::Float64
        K_ip::Float64
        K_lp::Float64
        K_ex::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of 5 mass-spring shaft model.
 It contains a High-Pressure (HP) steam turbine, Intermediate-Pressure (IP)
 steam turbine, Low-Pressure (LP) steam turbine, the Rotor and an Exciter (EX) mover

# Arguments
- `H::Float64`: Rotor inertia constant in MWs/MVA, validation range: `(0, nothing)`
- `H_hp::Float64`: High pressure turbine inertia constant in MWs/MVA, validation range: `(0, nothing)`
- `H_ip::Float64`: Intermediate pressure turbine inertia constant in MWs/MVA, validation range: `(0, nothing)`
- `H_lp::Float64`: Low pressure turbine inertia constant in MWs/MVA, validation range: `(0, nothing)`
- `H_ex::Float64`:  Exciter inertia constant in MWs/MVA, validation range: `(0, nothing)`
- `D::Float64`: Rotor natural damping in pu, validation range: `(0, nothing)`
- `D_hp::Float64`: High pressure turbine natural damping in pu, validation range: `(0, nothing)`
- `D_ip::Float64`: Intermediate pressure turbine natural damping in pu, validation range: `(0, nothing)`
- `D_lp::Float64`: Low pressure turbine natural damping in pu, validation range: `(0, nothing)`
- `D_ex::Float64`: Exciter natural damping in pu, validation range: `(0, nothing)`
- `D_12::Float64`: High-Intermediate pressure turbine damping, validation range: `(0, nothing)`
- `D_23::Float64`: Intermediate-Low pressure turbine damping, validation range: `(0, nothing)`
- `D_34::Float64`: Low pressure turbine-Rotor damping, validation range: `(0, nothing)`
- `D_45::Float64`: Rotor-Exciter damping, validation range: `(0, nothing)`
- `K_hp::Float64`: High pressure turbine angle coefficient, validation range: `(0, nothing)`
- `K_ip::Float64`: Intermediate pressure turbine angle coefficient, validation range: `(0, nothing)`
- `K_lp::Float64`: Low pressure turbine angle coefficient, validation range: `(0, nothing)`
- `K_ex::Float64`: Exciter angle coefficient, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	δ: rotor angle,
	ω: rotor speed,
	δ_hp: rotor angle of high pressure turbine,
	ω_hp: rotor speed of high pressure turbine,
	δ_ip: rotor angle of intermediate pressure turbine,
	ω_ip: rotor speed of intermediate pressure turbine,
	δ_lp: rotor angle of low pressure turbine,
	ω_lp: rotor speed of low pressure turbine,
	δ_ex: rotor angle of exciter,
	ω_lp: rotor speed of exciter
- `n_states::Int`: (**Do not modify.**) FiveMassShaft has 10 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct FiveMassShaft <: Shaft
    "Rotor inertia constant in MWs/MVA"
    H::Float64
    "High pressure turbine inertia constant in MWs/MVA"
    H_hp::Float64
    "Intermediate pressure turbine inertia constant in MWs/MVA"
    H_ip::Float64
    "Low pressure turbine inertia constant in MWs/MVA"
    H_lp::Float64
    " Exciter inertia constant in MWs/MVA"
    H_ex::Float64
    "Rotor natural damping in pu"
    D::Float64
    "High pressure turbine natural damping in pu"
    D_hp::Float64
    "Intermediate pressure turbine natural damping in pu"
    D_ip::Float64
    "Low pressure turbine natural damping in pu"
    D_lp::Float64
    "Exciter natural damping in pu"
    D_ex::Float64
    "High-Intermediate pressure turbine damping"
    D_12::Float64
    "Intermediate-Low pressure turbine damping"
    D_23::Float64
    "Low pressure turbine-Rotor damping"
    D_34::Float64
    "Rotor-Exciter damping"
    D_45::Float64
    "High pressure turbine angle coefficient"
    K_hp::Float64
    "Intermediate pressure turbine angle coefficient"
    K_ip::Float64
    "Low pressure turbine angle coefficient"
    K_lp::Float64
    "Exciter angle coefficient"
    K_ex::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	δ: rotor angle,
	ω: rotor speed,
	δ_hp: rotor angle of high pressure turbine,
	ω_hp: rotor speed of high pressure turbine,
	δ_ip: rotor angle of intermediate pressure turbine,
	ω_ip: rotor speed of intermediate pressure turbine,
	δ_lp: rotor angle of low pressure turbine,
	ω_lp: rotor speed of low pressure turbine,
	δ_ex: rotor angle of exciter,
	ω_lp: rotor speed of exciter"
    states::Vector{Symbol}
    "(**Do not modify.**) FiveMassShaft has 10 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function FiveMassShaft(H, H_hp, H_ip, H_lp, H_ex, D, D_hp, D_ip, D_lp, D_ex, D_12, D_23, D_34, D_45, K_hp, K_ip, K_lp, K_ex, ext=Dict{String, Any}(), )
    FiveMassShaft(H, H_hp, H_ip, H_lp, H_ex, D, D_hp, D_ip, D_lp, D_ex, D_12, D_23, D_34, D_45, K_hp, K_ip, K_lp, K_ex, ext, [:δ, :ω, :δ_hp, :ω_hp, :δ_ip, :ω_ip, :δ_lp, :ω_lp, :δ_ex, :ω_ex], 10, InfrastructureSystemsInternal(), )
end

function FiveMassShaft(; H, H_hp, H_ip, H_lp, H_ex, D, D_hp, D_ip, D_lp, D_ex, D_12, D_23, D_34, D_45, K_hp, K_ip, K_lp, K_ex, ext=Dict{String, Any}(), states=[:δ, :ω, :δ_hp, :ω_hp, :δ_ip, :ω_ip, :δ_lp, :ω_lp, :δ_ex, :ω_ex], n_states=10, internal=InfrastructureSystemsInternal(), )
    FiveMassShaft(H, H_hp, H_ip, H_lp, H_ex, D, D_hp, D_ip, D_lp, D_ex, D_12, D_23, D_34, D_45, K_hp, K_ip, K_lp, K_ex, ext, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function FiveMassShaft(::Nothing)
    FiveMassShaft(;
        H=0,
        H_hp=0,
        H_ip=0,
        H_lp=0,
        H_ex=0,
        D=0,
        D_hp=0,
        D_ip=0,
        D_lp=0,
        D_ex=0,
        D_12=0,
        D_23=0,
        D_34=0,
        D_45=0,
        K_hp=0,
        K_ip=0,
        K_lp=0,
        K_ex=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`FiveMassShaft`](@ref) `H`."""
get_H(value::FiveMassShaft) = value.H
"""Get [`FiveMassShaft`](@ref) `H_hp`."""
get_H_hp(value::FiveMassShaft) = value.H_hp
"""Get [`FiveMassShaft`](@ref) `H_ip`."""
get_H_ip(value::FiveMassShaft) = value.H_ip
"""Get [`FiveMassShaft`](@ref) `H_lp`."""
get_H_lp(value::FiveMassShaft) = value.H_lp
"""Get [`FiveMassShaft`](@ref) `H_ex`."""
get_H_ex(value::FiveMassShaft) = value.H_ex
"""Get [`FiveMassShaft`](@ref) `D`."""
get_D(value::FiveMassShaft) = value.D
"""Get [`FiveMassShaft`](@ref) `D_hp`."""
get_D_hp(value::FiveMassShaft) = value.D_hp
"""Get [`FiveMassShaft`](@ref) `D_ip`."""
get_D_ip(value::FiveMassShaft) = value.D_ip
"""Get [`FiveMassShaft`](@ref) `D_lp`."""
get_D_lp(value::FiveMassShaft) = value.D_lp
"""Get [`FiveMassShaft`](@ref) `D_ex`."""
get_D_ex(value::FiveMassShaft) = value.D_ex
"""Get [`FiveMassShaft`](@ref) `D_12`."""
get_D_12(value::FiveMassShaft) = value.D_12
"""Get [`FiveMassShaft`](@ref) `D_23`."""
get_D_23(value::FiveMassShaft) = value.D_23
"""Get [`FiveMassShaft`](@ref) `D_34`."""
get_D_34(value::FiveMassShaft) = value.D_34
"""Get [`FiveMassShaft`](@ref) `D_45`."""
get_D_45(value::FiveMassShaft) = value.D_45
"""Get [`FiveMassShaft`](@ref) `K_hp`."""
get_K_hp(value::FiveMassShaft) = value.K_hp
"""Get [`FiveMassShaft`](@ref) `K_ip`."""
get_K_ip(value::FiveMassShaft) = value.K_ip
"""Get [`FiveMassShaft`](@ref) `K_lp`."""
get_K_lp(value::FiveMassShaft) = value.K_lp
"""Get [`FiveMassShaft`](@ref) `K_ex`."""
get_K_ex(value::FiveMassShaft) = value.K_ex
"""Get [`FiveMassShaft`](@ref) `ext`."""
get_ext(value::FiveMassShaft) = value.ext
"""Get [`FiveMassShaft`](@ref) `states`."""
get_states(value::FiveMassShaft) = value.states
"""Get [`FiveMassShaft`](@ref) `n_states`."""
get_n_states(value::FiveMassShaft) = value.n_states
"""Get [`FiveMassShaft`](@ref) `internal`."""
get_internal(value::FiveMassShaft) = value.internal

"""Set [`FiveMassShaft`](@ref) `H`."""
set_H!(value::FiveMassShaft, val) = value.H = val
"""Set [`FiveMassShaft`](@ref) `H_hp`."""
set_H_hp!(value::FiveMassShaft, val) = value.H_hp = val
"""Set [`FiveMassShaft`](@ref) `H_ip`."""
set_H_ip!(value::FiveMassShaft, val) = value.H_ip = val
"""Set [`FiveMassShaft`](@ref) `H_lp`."""
set_H_lp!(value::FiveMassShaft, val) = value.H_lp = val
"""Set [`FiveMassShaft`](@ref) `H_ex`."""
set_H_ex!(value::FiveMassShaft, val) = value.H_ex = val
"""Set [`FiveMassShaft`](@ref) `D`."""
set_D!(value::FiveMassShaft, val) = value.D = val
"""Set [`FiveMassShaft`](@ref) `D_hp`."""
set_D_hp!(value::FiveMassShaft, val) = value.D_hp = val
"""Set [`FiveMassShaft`](@ref) `D_ip`."""
set_D_ip!(value::FiveMassShaft, val) = value.D_ip = val
"""Set [`FiveMassShaft`](@ref) `D_lp`."""
set_D_lp!(value::FiveMassShaft, val) = value.D_lp = val
"""Set [`FiveMassShaft`](@ref) `D_ex`."""
set_D_ex!(value::FiveMassShaft, val) = value.D_ex = val
"""Set [`FiveMassShaft`](@ref) `D_12`."""
set_D_12!(value::FiveMassShaft, val) = value.D_12 = val
"""Set [`FiveMassShaft`](@ref) `D_23`."""
set_D_23!(value::FiveMassShaft, val) = value.D_23 = val
"""Set [`FiveMassShaft`](@ref) `D_34`."""
set_D_34!(value::FiveMassShaft, val) = value.D_34 = val
"""Set [`FiveMassShaft`](@ref) `D_45`."""
set_D_45!(value::FiveMassShaft, val) = value.D_45 = val
"""Set [`FiveMassShaft`](@ref) `K_hp`."""
set_K_hp!(value::FiveMassShaft, val) = value.K_hp = val
"""Set [`FiveMassShaft`](@ref) `K_ip`."""
set_K_ip!(value::FiveMassShaft, val) = value.K_ip = val
"""Set [`FiveMassShaft`](@ref) `K_lp`."""
set_K_lp!(value::FiveMassShaft, val) = value.K_lp = val
"""Set [`FiveMassShaft`](@ref) `K_ex`."""
set_K_ex!(value::FiveMassShaft, val) = value.K_ex = val
"""Set [`FiveMassShaft`](@ref) `ext`."""
set_ext!(value::FiveMassShaft, val) = value.ext = val



function from_openapi(po::PD.FiveMassShaft, refs::OpenAPIRefs)
    return FiveMassShaft(;
        H = _wire_required(po.h, "FiveMassShaft", "H"),
        H_hp = _wire_required(po.h_hp, "FiveMassShaft", "H_hp"),
        H_ip = _wire_required(po.h_ip, "FiveMassShaft", "H_ip"),
        H_lp = _wire_required(po.h_lp, "FiveMassShaft", "H_lp"),
        H_ex = _wire_required(po.h_ex, "FiveMassShaft", "H_ex"),
        D = _wire_required(po.d, "FiveMassShaft", "D"),
        D_hp = _wire_required(po.d_hp, "FiveMassShaft", "D_hp"),
        D_ip = _wire_required(po.d_ip, "FiveMassShaft", "D_ip"),
        D_lp = _wire_required(po.d_lp, "FiveMassShaft", "D_lp"),
        D_ex = _wire_required(po.d_ex, "FiveMassShaft", "D_ex"),
        D_12 = _wire_required(po.d_12, "FiveMassShaft", "D_12"),
        D_23 = _wire_required(po.d_23, "FiveMassShaft", "D_23"),
        D_34 = _wire_required(po.d_34, "FiveMassShaft", "D_34"),
        D_45 = _wire_required(po.d_45, "FiveMassShaft", "D_45"),
        K_hp = _wire_required(po.k_hp, "FiveMassShaft", "K_hp"),
        K_ip = _wire_required(po.k_ip, "FiveMassShaft", "K_ip"),
        K_lp = _wire_required(po.k_lp, "FiveMassShaft", "K_lp"),
        K_ex = _wire_required(po.k_ex, "FiveMassShaft", "K_ex"),
    )
end

function to_openapi(value::FiveMassShaft, refs::OpenAPIRefs)
    return PD.FiveMassShaft(;
        id = component_id(refs, value),
        h = get_H(value),
        h_hp = get_H_hp(value),
        h_ip = get_H_ip(value),
        h_lp = get_H_lp(value),
        h_ex = get_H_ex(value),
        d = get_D(value),
        d_hp = get_D_hp(value),
        d_ip = get_D_ip(value),
        d_lp = get_D_lp(value),
        d_ex = get_D_ex(value),
        d_12 = get_D_12(value),
        d_23 = get_D_23(value),
        d_34 = get_D_34(value),
        d_45 = get_D_45(value),
        k_hp = get_K_hp(value),
        k_ip = get_K_ip(value),
        k_lp = get_K_lp(value),
        k_ex = get_K_ex(value),
    )
end
