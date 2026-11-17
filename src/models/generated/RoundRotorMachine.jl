#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct RoundRotorMachine <: SynchronousMachineDynamics
        R::Float64
        Td0_p::Float64
        Td0_pp::Float64
        Tq0_p::Float64
        Tq0_pp::Float64
        Xd::Float64
        Xq::Float64
        Xd_p::Float64
        Xq_p::Float64
        Xd_pp::Float64
        Xl::Float64
        Se::Tuple{Float64, Float64}
        ext::Dict{String, Any}
        γ_d1::Float64
        γ_q1::Float64
        γ_d2::Float64
        γ_q2::Float64
        γ_qd::Float64
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of 4-[states](@ref S) round-rotor synchronous machine with quadratic/exponential saturation:
IEEE Std 1110 §5.3.2 (Model 2.2). GENROU or GENROE model in PSSE and PSLF

# Arguments
- `R::Float64`: Armature resistance, validation range: `(0, nothing)`
- `Td0_p::Float64`: Time constant of transient d-axis voltage, validation range: `(0, nothing)`
- `Td0_pp::Float64`: Time constant of sub-transient d-axis voltage, validation range: `(0, nothing)`
- `Tq0_p::Float64`: Time constant of transient q-axis voltage, validation range: `(0, nothing)`
- `Tq0_pp::Float64`: Time constant of sub-transient q-axis voltage, validation range: `(0, nothing)`
- `Xd::Float64`: Reactance after EMF in d-axis per unit, validation range: `(0, nothing)`
- `Xq::Float64`: Reactance after EMF in q-axis per unit, validation range: `(0, nothing)`
- `Xd_p::Float64`: Transient reactance after EMF in d-axis per unit, validation range: `(0, nothing)`
- `Xq_p::Float64`: Transient reactance after EMF in q-axis per unit, validation range: `(0, nothing)`
- `Xd_pp::Float64`: Sub-Transient reactance after EMF in d-axis per unit. Note: Xd_pp = Xq_pp, validation range: `(0, nothing)`
- `Xl::Float64`: Stator leakage reactance, validation range: `(0, nothing)`
- `Se::Tuple{Float64, Float64}`: Saturation factor at 1 and 1.2 pu flux: S(1.0) = B(|ψ_pp|-A)^2
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `γ_d1::Float64`: (**Do not modify.**) γ_d1 parameter
- `γ_q1::Float64`: (**Do not modify.**) γ_q1 parameter
- `γ_d2::Float64`: (**Do not modify.**) γ_d2 parameter
- `γ_q2::Float64`: (**Do not modify.**) γ_q2 parameter
- `γ_qd::Float64`: (**Do not modify.**) γ_qd parameter
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	eq_p: q-axis generator voltage behind the transient reactance,
	ed_p: d-axis generator voltage behind the transient reactance,
	ψ_kd: flux linkage in the first equivalent damping circuit in the d-axis,
	ψ_kq: flux linkage in the first equivalent damping circuit in the d-axis
- `n_states::Int`: (**Do not modify.**) RoundRotorMachine has 4 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct RoundRotorMachine <: SynchronousMachineDynamics
    "Armature resistance"
    R::Float64
    "Time constant of transient d-axis voltage"
    Td0_p::Float64
    "Time constant of sub-transient d-axis voltage"
    Td0_pp::Float64
    "Time constant of transient q-axis voltage"
    Tq0_p::Float64
    "Time constant of sub-transient q-axis voltage"
    Tq0_pp::Float64
    "Reactance after EMF in d-axis per unit"
    Xd::Float64
    "Reactance after EMF in q-axis per unit"
    Xq::Float64
    "Transient reactance after EMF in d-axis per unit"
    Xd_p::Float64
    "Transient reactance after EMF in q-axis per unit"
    Xq_p::Float64
    "Sub-Transient reactance after EMF in d-axis per unit. Note: Xd_pp = Xq_pp"
    Xd_pp::Float64
    "Stator leakage reactance"
    Xl::Float64
    "Saturation factor at 1 and 1.2 pu flux: S(1.0) = B(|ψ_pp|-A)^2"
    Se::Tuple{Float64, Float64}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) γ_d1 parameter"
    γ_d1::Float64
    "(**Do not modify.**) γ_q1 parameter"
    γ_q1::Float64
    "(**Do not modify.**) γ_d2 parameter"
    γ_d2::Float64
    "(**Do not modify.**) γ_q2 parameter"
    γ_q2::Float64
    "(**Do not modify.**) γ_qd parameter"
    γ_qd::Float64
    "(**Do not modify.**) The [states](@ref S) are:
	eq_p: q-axis generator voltage behind the transient reactance,
	ed_p: d-axis generator voltage behind the transient reactance,
	ψ_kd: flux linkage in the first equivalent damping circuit in the d-axis,
	ψ_kq: flux linkage in the first equivalent damping circuit in the d-axis"
    states::Vector{Symbol}
    "(**Do not modify.**) RoundRotorMachine has 4 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function RoundRotorMachine(R, Td0_p, Td0_pp, Tq0_p, Tq0_pp, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xl, Se, ext=Dict{String, Any}(), )
    RoundRotorMachine(R, Td0_p, Td0_pp, Tq0_p, Tq0_pp, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xl, Se, ext, (Xd_pp - Xl) / (Xd_p - Xl), (Xd_pp - Xl) / (Xq_p - Xl), (Xd_p - Xd_pp) / (Xd_p - Xl)^2, (Xq_p - Xd_pp) / (Xq_p - Xl)^2, (Xq - Xl) / (Xd - Xl), [:eq_p, :ed_p, :ψ_kd, :ψ_kq], 4, InfrastructureSystemsInternal(), )
end

function RoundRotorMachine(; R, Td0_p, Td0_pp, Tq0_p, Tq0_pp, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xl, Se, ext=Dict{String, Any}(), γ_d1=(Xd_pp - Xl) / (Xd_p - Xl), γ_q1=(Xd_pp - Xl) / (Xq_p - Xl), γ_d2=(Xd_p - Xd_pp) / (Xd_p - Xl)^2, γ_q2=(Xq_p - Xd_pp) / (Xq_p - Xl)^2, γ_qd=(Xq - Xl) / (Xd - Xl), states=[:eq_p, :ed_p, :ψ_kd, :ψ_kq], n_states=4, internal=InfrastructureSystemsInternal(), )
    RoundRotorMachine(R, Td0_p, Td0_pp, Tq0_p, Tq0_pp, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xl, Se, ext, γ_d1, γ_q1, γ_d2, γ_q2, γ_qd, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function RoundRotorMachine(::Nothing)
    RoundRotorMachine(;
        R=0,
        Td0_p=0,
        Td0_pp=0,
        Tq0_p=0,
        Tq0_pp=0,
        Xd=0,
        Xq=0,
        Xd_p=0,
        Xq_p=0,
        Xd_pp=0,
        Xl=0,
        Se=(0.0, 0.0),
        ext=Dict{String, Any}(),
    )
end

"""Get [`RoundRotorMachine`](@ref) `R`."""
get_R(value::RoundRotorMachine) = value.R
"""Get [`RoundRotorMachine`](@ref) `Td0_p`."""
get_Td0_p(value::RoundRotorMachine) = value.Td0_p
"""Get [`RoundRotorMachine`](@ref) `Td0_pp`."""
get_Td0_pp(value::RoundRotorMachine) = value.Td0_pp
"""Get [`RoundRotorMachine`](@ref) `Tq0_p`."""
get_Tq0_p(value::RoundRotorMachine) = value.Tq0_p
"""Get [`RoundRotorMachine`](@ref) `Tq0_pp`."""
get_Tq0_pp(value::RoundRotorMachine) = value.Tq0_pp
"""Get [`RoundRotorMachine`](@ref) `Xd`."""
get_Xd(value::RoundRotorMachine) = value.Xd
"""Get [`RoundRotorMachine`](@ref) `Xq`."""
get_Xq(value::RoundRotorMachine) = value.Xq
"""Get [`RoundRotorMachine`](@ref) `Xd_p`."""
get_Xd_p(value::RoundRotorMachine) = value.Xd_p
"""Get [`RoundRotorMachine`](@ref) `Xq_p`."""
get_Xq_p(value::RoundRotorMachine) = value.Xq_p
"""Get [`RoundRotorMachine`](@ref) `Xd_pp`."""
get_Xd_pp(value::RoundRotorMachine) = value.Xd_pp
"""Get [`RoundRotorMachine`](@ref) `Xl`."""
get_Xl(value::RoundRotorMachine) = value.Xl
"""Get [`RoundRotorMachine`](@ref) `Se`."""
get_Se(value::RoundRotorMachine) = value.Se
"""Get [`RoundRotorMachine`](@ref) `ext`."""
get_ext(value::RoundRotorMachine) = value.ext
"""Get [`RoundRotorMachine`](@ref) `γ_d1`."""
get_γ_d1(value::RoundRotorMachine) = value.γ_d1
"""Get [`RoundRotorMachine`](@ref) `γ_q1`."""
get_γ_q1(value::RoundRotorMachine) = value.γ_q1
"""Get [`RoundRotorMachine`](@ref) `γ_d2`."""
get_γ_d2(value::RoundRotorMachine) = value.γ_d2
"""Get [`RoundRotorMachine`](@ref) `γ_q2`."""
get_γ_q2(value::RoundRotorMachine) = value.γ_q2
"""Get [`RoundRotorMachine`](@ref) `γ_qd`."""
get_γ_qd(value::RoundRotorMachine) = value.γ_qd
"""Get [`RoundRotorMachine`](@ref) `states`."""
get_states(value::RoundRotorMachine) = value.states
"""Get [`RoundRotorMachine`](@ref) `n_states`."""
get_n_states(value::RoundRotorMachine) = value.n_states
"""Get [`RoundRotorMachine`](@ref) `internal`."""
get_internal(value::RoundRotorMachine) = value.internal

"""Set [`RoundRotorMachine`](@ref) `R`."""
set_R!(value::RoundRotorMachine, val) = value.R = val
"""Set [`RoundRotorMachine`](@ref) `Td0_p`."""
set_Td0_p!(value::RoundRotorMachine, val) = value.Td0_p = val
"""Set [`RoundRotorMachine`](@ref) `Td0_pp`."""
set_Td0_pp!(value::RoundRotorMachine, val) = value.Td0_pp = val
"""Set [`RoundRotorMachine`](@ref) `Tq0_p`."""
set_Tq0_p!(value::RoundRotorMachine, val) = value.Tq0_p = val
"""Set [`RoundRotorMachine`](@ref) `Tq0_pp`."""
set_Tq0_pp!(value::RoundRotorMachine, val) = value.Tq0_pp = val
"""Set [`RoundRotorMachine`](@ref) `Xd`."""
set_Xd!(value::RoundRotorMachine, val) = value.Xd = val
"""Set [`RoundRotorMachine`](@ref) `Xq`."""
set_Xq!(value::RoundRotorMachine, val) = value.Xq = val
"""Set [`RoundRotorMachine`](@ref) `Xd_p`."""
set_Xd_p!(value::RoundRotorMachine, val) = value.Xd_p = val
"""Set [`RoundRotorMachine`](@ref) `Xq_p`."""
set_Xq_p!(value::RoundRotorMachine, val) = value.Xq_p = val
"""Set [`RoundRotorMachine`](@ref) `Xd_pp`."""
set_Xd_pp!(value::RoundRotorMachine, val) = value.Xd_pp = val
"""Set [`RoundRotorMachine`](@ref) `Xl`."""
set_Xl!(value::RoundRotorMachine, val) = value.Xl = val
"""Set [`RoundRotorMachine`](@ref) `Se`."""
set_Se!(value::RoundRotorMachine, val) = value.Se = val
"""Set [`RoundRotorMachine`](@ref) `ext`."""
set_ext!(value::RoundRotorMachine, val) = value.ext = val
"""Set [`RoundRotorMachine`](@ref) `γ_d1`."""
set_γ_d1!(value::RoundRotorMachine, val) = value.γ_d1 = val
"""Set [`RoundRotorMachine`](@ref) `γ_q1`."""
set_γ_q1!(value::RoundRotorMachine, val) = value.γ_q1 = val
"""Set [`RoundRotorMachine`](@ref) `γ_d2`."""
set_γ_d2!(value::RoundRotorMachine, val) = value.γ_d2 = val
"""Set [`RoundRotorMachine`](@ref) `γ_q2`."""
set_γ_q2!(value::RoundRotorMachine, val) = value.γ_q2 = val
"""Set [`RoundRotorMachine`](@ref) `γ_qd`."""
set_γ_qd!(value::RoundRotorMachine, val) = value.γ_qd = val



function from_openapi(po::PD.RoundRotorMachine, refs::OpenAPIRefs)
    return RoundRotorMachine(;
        R = _wire_required(po.r, "RoundRotorMachine", "R"),
        Td0_p = _wire_required(po.td0_p, "RoundRotorMachine", "Td0_p"),
        Td0_pp = _wire_required(po.td0_pp, "RoundRotorMachine", "Td0_pp"),
        Tq0_p = _wire_required(po.tq0_p, "RoundRotorMachine", "Tq0_p"),
        Tq0_pp = _wire_required(po.tq0_pp, "RoundRotorMachine", "Tq0_pp"),
        Xd = _wire_required(po.xd, "RoundRotorMachine", "Xd"),
        Xq = _wire_required(po.xq, "RoundRotorMachine", "Xq"),
        Xd_p = _wire_required(po.xd_p, "RoundRotorMachine", "Xd_p"),
        Xq_p = _wire_required(po.xq_p, "RoundRotorMachine", "Xq_p"),
        Xd_pp = _wire_required(po.xd_pp, "RoundRotorMachine", "Xd_pp"),
        Xl = _wire_required(po.xl, "RoundRotorMachine", "Xl"),
        Se = _wire_to_psy(Tuple{Float64, Float64}, po.se),
    )
end

function to_openapi(value::RoundRotorMachine, refs::OpenAPIRefs)
    return PD.RoundRotorMachine(;
        id = component_id(refs, value),
        r = get_R(value),
        td0_p = get_Td0_p(value),
        td0_pp = get_Td0_pp(value),
        tq0_p = get_Tq0_p(value),
        tq0_pp = get_Tq0_pp(value),
        xd = get_Xd(value),
        xq = get_Xq(value),
        xd_p = get_Xd_p(value),
        xq_p = get_Xq_p(value),
        xd_pp = get_Xd_pp(value),
        xl = get_Xl(value),
        se = _psy_to_wire(get_Se(value)),
    )
end
