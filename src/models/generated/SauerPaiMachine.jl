#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SauerPaiMachine <: SynchronousMachineDynamics
        R::Float64
        Xd::Float64
        Xq::Float64
        Xd_p::Float64
        Xq_p::Float64
        Xd_pp::Float64
        Xq_pp::Float64
        Xl::Float64
        Td0_p::Float64
        Tq0_p::Float64
        Td0_pp::Float64
        Tq0_pp::Float64
        ext::Dict{String, Any}
        γ_d1::Float64
        γ_q1::Float64
        γ_d2::Float64
        γ_q2::Float64
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of synchronous machine: Sauer Pai model

# Arguments
- `R::Float64`: Resistance after EMF in machine per unit, validation range: `(0, nothing)`
- `Xd::Float64`: Reactance after EMF in d-axis per unit, validation range: `(0, nothing)`
- `Xq::Float64`: Reactance after EMF in q-axis per unit, validation range: `(0, nothing)`
- `Xd_p::Float64`: Transient reactance after EMF in d-axis per unit, validation range: `(0, nothing)`
- `Xq_p::Float64`: Transient reactance after EMF in q-axis per unit, validation range: `(0, nothing)`
- `Xd_pp::Float64`: Sub-Transient reactance after EMF in d-axis per unit, validation range: `(0, nothing)`
- `Xq_pp::Float64`: Sub-Transient reactance after EMF in q-axis per unit, validation range: `(0, nothing)`
- `Xl::Float64`: Stator Leakage Reactance, validation range: `(0, nothing)`
- `Td0_p::Float64`: Time constant of transient d-axis voltage, validation range: `(0, nothing)`
- `Tq0_p::Float64`: Time constant of transient q-axis voltage, validation range: `(0, nothing)`
- `Td0_pp::Float64`: Time constant of sub-transient d-axis voltage, validation range: `(0, nothing)`
- `Tq0_pp::Float64`: Time constant of sub-transient q-axis voltage, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `γ_d1::Float64`: (**Do not modify.**) Internal equation
- `γ_q1::Float64`: (**Do not modify.**) Internal equation
- `γ_d2::Float64`: (**Do not modify.**) Internal equation
- `γ_q2::Float64`: (**Do not modify.**) Internal equation
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	ψq: q-axis stator flux,
	ψd: d-axis stator flux,
	eq_p: q-axis transient voltage,
	ed_p: d-axis transient voltage
	ψd_pp: subtransient flux linkage in the d-axis
	ψq_pp: subtransient flux linkage in the q-axis
- `n_states::Int`: (**Do not modify.**) SauerPaiMachine has 6 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct SauerPaiMachine <: SynchronousMachineDynamics
    "Resistance after EMF in machine per unit"
    R::Float64
    "Reactance after EMF in d-axis per unit"
    Xd::Float64
    "Reactance after EMF in q-axis per unit"
    Xq::Float64
    "Transient reactance after EMF in d-axis per unit"
    Xd_p::Float64
    "Transient reactance after EMF in q-axis per unit"
    Xq_p::Float64
    "Sub-Transient reactance after EMF in d-axis per unit"
    Xd_pp::Float64
    "Sub-Transient reactance after EMF in q-axis per unit"
    Xq_pp::Float64
    "Stator Leakage Reactance"
    Xl::Float64
    "Time constant of transient d-axis voltage"
    Td0_p::Float64
    "Time constant of transient q-axis voltage"
    Tq0_p::Float64
    "Time constant of sub-transient d-axis voltage"
    Td0_pp::Float64
    "Time constant of sub-transient q-axis voltage"
    Tq0_pp::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) Internal equation"
    γ_d1::Float64
    "(**Do not modify.**) Internal equation"
    γ_q1::Float64
    "(**Do not modify.**) Internal equation"
    γ_d2::Float64
    "(**Do not modify.**) Internal equation"
    γ_q2::Float64
    "(**Do not modify.**) The [states](@ref S) are:
	ψq: q-axis stator flux,
	ψd: d-axis stator flux,
	eq_p: q-axis transient voltage,
	ed_p: d-axis transient voltage
	ψd_pp: subtransient flux linkage in the d-axis
	ψq_pp: subtransient flux linkage in the q-axis"
    states::Vector{Symbol}
    "(**Do not modify.**) SauerPaiMachine has 6 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function SauerPaiMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Xl, Td0_p, Tq0_p, Td0_pp, Tq0_pp, ext=Dict{String, Any}(), )
    SauerPaiMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Xl, Td0_p, Tq0_p, Td0_pp, Tq0_pp, ext, (Xd_pp-Xl)/(Xd_p-Xl), (Xq_pp-Xl)/(Xq_p-Xl), (Xd_p - Xd_pp) / (Xd_p - Xl)^2, (Xq_p - Xq_pp) / (Xq_p - Xl)^2, [:ψq, :ψd, :eq_p, :ed_p, :ψd_pp, :ψq_pp], 6, InfrastructureSystemsInternal(), )
end

function SauerPaiMachine(; R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Xl, Td0_p, Tq0_p, Td0_pp, Tq0_pp, ext=Dict{String, Any}(), γ_d1=(Xd_pp-Xl)/(Xd_p-Xl), γ_q1=(Xq_pp-Xl)/(Xq_p-Xl), γ_d2=(Xd_p - Xd_pp) / (Xd_p - Xl)^2, γ_q2=(Xq_p - Xq_pp) / (Xq_p - Xl)^2, states=[:ψq, :ψd, :eq_p, :ed_p, :ψd_pp, :ψq_pp], n_states=6, internal=InfrastructureSystemsInternal(), )
    SauerPaiMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Xl, Td0_p, Tq0_p, Td0_pp, Tq0_pp, ext, γ_d1, γ_q1, γ_d2, γ_q2, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function SauerPaiMachine(::Nothing)
    SauerPaiMachine(;
        R=0,
        Xd=0,
        Xq=0,
        Xd_p=0,
        Xq_p=0,
        Xd_pp=0,
        Xq_pp=0,
        Xl=0,
        Td0_p=0,
        Tq0_p=0,
        Td0_pp=0,
        Tq0_pp=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`SauerPaiMachine`](@ref) `R`."""
get_R(value::SauerPaiMachine) = value.R
"""Get [`SauerPaiMachine`](@ref) `Xd`."""
get_Xd(value::SauerPaiMachine) = value.Xd
"""Get [`SauerPaiMachine`](@ref) `Xq`."""
get_Xq(value::SauerPaiMachine) = value.Xq
"""Get [`SauerPaiMachine`](@ref) `Xd_p`."""
get_Xd_p(value::SauerPaiMachine) = value.Xd_p
"""Get [`SauerPaiMachine`](@ref) `Xq_p`."""
get_Xq_p(value::SauerPaiMachine) = value.Xq_p
"""Get [`SauerPaiMachine`](@ref) `Xd_pp`."""
get_Xd_pp(value::SauerPaiMachine) = value.Xd_pp
"""Get [`SauerPaiMachine`](@ref) `Xq_pp`."""
get_Xq_pp(value::SauerPaiMachine) = value.Xq_pp
"""Get [`SauerPaiMachine`](@ref) `Xl`."""
get_Xl(value::SauerPaiMachine) = value.Xl
"""Get [`SauerPaiMachine`](@ref) `Td0_p`."""
get_Td0_p(value::SauerPaiMachine) = value.Td0_p
"""Get [`SauerPaiMachine`](@ref) `Tq0_p`."""
get_Tq0_p(value::SauerPaiMachine) = value.Tq0_p
"""Get [`SauerPaiMachine`](@ref) `Td0_pp`."""
get_Td0_pp(value::SauerPaiMachine) = value.Td0_pp
"""Get [`SauerPaiMachine`](@ref) `Tq0_pp`."""
get_Tq0_pp(value::SauerPaiMachine) = value.Tq0_pp
"""Get [`SauerPaiMachine`](@ref) `ext`."""
get_ext(value::SauerPaiMachine) = value.ext
"""Get [`SauerPaiMachine`](@ref) `γ_d1`."""
get_γ_d1(value::SauerPaiMachine) = value.γ_d1
"""Get [`SauerPaiMachine`](@ref) `γ_q1`."""
get_γ_q1(value::SauerPaiMachine) = value.γ_q1
"""Get [`SauerPaiMachine`](@ref) `γ_d2`."""
get_γ_d2(value::SauerPaiMachine) = value.γ_d2
"""Get [`SauerPaiMachine`](@ref) `γ_q2`."""
get_γ_q2(value::SauerPaiMachine) = value.γ_q2
"""Get [`SauerPaiMachine`](@ref) `states`."""
get_states(value::SauerPaiMachine) = value.states
"""Get [`SauerPaiMachine`](@ref) `n_states`."""
get_n_states(value::SauerPaiMachine) = value.n_states
"""Get [`SauerPaiMachine`](@ref) `internal`."""
get_internal(value::SauerPaiMachine) = value.internal

"""Set [`SauerPaiMachine`](@ref) `R`."""
set_R!(value::SauerPaiMachine, val) = value.R = val
"""Set [`SauerPaiMachine`](@ref) `Xd`."""
set_Xd!(value::SauerPaiMachine, val) = value.Xd = val
"""Set [`SauerPaiMachine`](@ref) `Xq`."""
set_Xq!(value::SauerPaiMachine, val) = value.Xq = val
"""Set [`SauerPaiMachine`](@ref) `Xd_p`."""
set_Xd_p!(value::SauerPaiMachine, val) = value.Xd_p = val
"""Set [`SauerPaiMachine`](@ref) `Xq_p`."""
set_Xq_p!(value::SauerPaiMachine, val) = value.Xq_p = val
"""Set [`SauerPaiMachine`](@ref) `Xd_pp`."""
set_Xd_pp!(value::SauerPaiMachine, val) = value.Xd_pp = val
"""Set [`SauerPaiMachine`](@ref) `Xq_pp`."""
set_Xq_pp!(value::SauerPaiMachine, val) = value.Xq_pp = val
"""Set [`SauerPaiMachine`](@ref) `Xl`."""
set_Xl!(value::SauerPaiMachine, val) = value.Xl = val
"""Set [`SauerPaiMachine`](@ref) `Td0_p`."""
set_Td0_p!(value::SauerPaiMachine, val) = value.Td0_p = val
"""Set [`SauerPaiMachine`](@ref) `Tq0_p`."""
set_Tq0_p!(value::SauerPaiMachine, val) = value.Tq0_p = val
"""Set [`SauerPaiMachine`](@ref) `Td0_pp`."""
set_Td0_pp!(value::SauerPaiMachine, val) = value.Td0_pp = val
"""Set [`SauerPaiMachine`](@ref) `Tq0_pp`."""
set_Tq0_pp!(value::SauerPaiMachine, val) = value.Tq0_pp = val
"""Set [`SauerPaiMachine`](@ref) `ext`."""
set_ext!(value::SauerPaiMachine, val) = value.ext = val
"""Set [`SauerPaiMachine`](@ref) `γ_d1`."""
set_γ_d1!(value::SauerPaiMachine, val) = value.γ_d1 = val
"""Set [`SauerPaiMachine`](@ref) `γ_q1`."""
set_γ_q1!(value::SauerPaiMachine, val) = value.γ_q1 = val
"""Set [`SauerPaiMachine`](@ref) `γ_d2`."""
set_γ_d2!(value::SauerPaiMachine, val) = value.γ_d2 = val
"""Set [`SauerPaiMachine`](@ref) `γ_q2`."""
set_γ_q2!(value::SauerPaiMachine, val) = value.γ_q2 = val



function from_openapi(po::PD.SauerPaiMachine, refs::OpenAPIRefs)
    return SauerPaiMachine(;
        R = _wire_required(po.r, "SauerPaiMachine", "R"),
        Xd = _wire_required(po.xd, "SauerPaiMachine", "Xd"),
        Xq = _wire_required(po.xq, "SauerPaiMachine", "Xq"),
        Xd_p = _wire_required(po.xd_p, "SauerPaiMachine", "Xd_p"),
        Xq_p = _wire_required(po.xq_p, "SauerPaiMachine", "Xq_p"),
        Xd_pp = _wire_required(po.xd_pp, "SauerPaiMachine", "Xd_pp"),
        Xq_pp = _wire_required(po.xq_pp, "SauerPaiMachine", "Xq_pp"),
        Xl = _wire_required(po.xl, "SauerPaiMachine", "Xl"),
        Td0_p = _wire_required(po.td0_p, "SauerPaiMachine", "Td0_p"),
        Tq0_p = _wire_required(po.tq0_p, "SauerPaiMachine", "Tq0_p"),
        Td0_pp = _wire_required(po.td0_pp, "SauerPaiMachine", "Td0_pp"),
        Tq0_pp = _wire_required(po.tq0_pp, "SauerPaiMachine", "Tq0_pp"),
    )
end

function to_openapi(value::SauerPaiMachine, refs::OpenAPIRefs)
    return PD.SauerPaiMachine(;
        id = component_id(refs, value),
        r = get_R(value),
        xd = get_Xd(value),
        xq = get_Xq(value),
        xd_p = get_Xd_p(value),
        xq_p = get_Xq_p(value),
        xd_pp = get_Xd_pp(value),
        xq_pp = get_Xq_pp(value),
        xl = get_Xl(value),
        td0_p = get_Td0_p(value),
        tq0_p = get_Tq0_p(value),
        td0_pp = get_Td0_pp(value),
        tq0_pp = get_Tq0_pp(value),
    )
end
