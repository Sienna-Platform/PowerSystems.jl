#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SimpleMarconatoMachine <: SynchronousMachineDynamics
        R::Float64
        Xd::Float64
        Xq::Float64
        Xd_p::Float64
        Xq_p::Float64
        Xd_pp::Float64
        Xq_pp::Float64
        Td0_p::Float64
        Tq0_p::Float64
        Td0_pp::Float64
        Tq0_pp::Float64
        T_AA::Float64
        ext::Dict{String, Any}
        γd::Float64
        γq::Float64
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of 4-[states](@ref S) synchronous machine: Simplified Marconato model
 The derivative of stator fluxes (ψd and ψq) is neglected and ωψd = ψd and
 ωψq = ψq is assumed (i.e. ω=1.0). This is standard when transmission network
 dynamics is neglected

# Arguments
- `R::Float64`: Resistance after EMF in machine per unit, validation range: `(0, nothing)`
- `Xd::Float64`: Reactance after EMF in d-axis per unit, validation range: `(0, nothing)`
- `Xq::Float64`: Reactance after EMF in q-axis per unit, validation range: `(0, nothing)`
- `Xd_p::Float64`: Transient reactance after EMF in d-axis per unit, validation range: `(0, nothing)`
- `Xq_p::Float64`: Transient reactance after EMF in q-axis per unit, validation range: `(0, nothing)`
- `Xd_pp::Float64`: Sub-Transient reactance after EMF in d-axis per unit, validation range: `(0, nothing)`
- `Xq_pp::Float64`: Sub-Transient reactance after EMF in q-axis per unit, validation range: `(0, nothing)`
- `Td0_p::Float64`: Time constant of transient d-axis voltage, validation range: `(0, nothing)`
- `Tq0_p::Float64`: Time constant of transient q-axis voltage, validation range: `(0, nothing)`
- `Td0_pp::Float64`: Time constant of sub-transient d-axis voltage, validation range: `(0, nothing)`
- `Tq0_pp::Float64`: Time constant of sub-transient q-axis voltage, validation range: `(0, nothing)`
- `T_AA::Float64`: Time constant of d-axis additional leakage, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `γd::Float64`: (**Do not modify.**) Internal equation
- `γq::Float64`: (**Do not modify.**) Internal equation
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	eq_p: q-axis transient voltage,
	ed_p: d-axis transient voltage,
	eq_pp: q-axis subtransient voltage,
	ed_pp: d-axis subtransient voltage
- `n_states::Int`: (**Do not modify.**) SimpleMarconatoMachine has 4 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct SimpleMarconatoMachine <: SynchronousMachineDynamics
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
    "Time constant of transient d-axis voltage"
    Td0_p::Float64
    "Time constant of transient q-axis voltage"
    Tq0_p::Float64
    "Time constant of sub-transient d-axis voltage"
    Td0_pp::Float64
    "Time constant of sub-transient q-axis voltage"
    Tq0_pp::Float64
    "Time constant of d-axis additional leakage"
    T_AA::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) Internal equation"
    γd::Float64
    "(**Do not modify.**) Internal equation"
    γq::Float64
    "(**Do not modify.**) The [states](@ref S) are:
	eq_p: q-axis transient voltage,
	ed_p: d-axis transient voltage,
	eq_pp: q-axis subtransient voltage,
	ed_pp: d-axis subtransient voltage"
    states::Vector{Symbol}
    "(**Do not modify.**) SimpleMarconatoMachine has 4 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function SimpleMarconatoMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, T_AA, ext=Dict{String, Any}(), )
    SimpleMarconatoMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, T_AA, ext, ((Td0_pp*Xd_pp)/(Td0_p*Xd_p) )*(Xd-Xd_p), ((Tq0_pp*Xq_pp)/(Tq0_p*Xq_p) )*(Xq-Xq_p), [:eq_p, :ed_p, :eq_pp, :ed_pp], 4, InfrastructureSystemsInternal(), )
end

function SimpleMarconatoMachine(; R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, T_AA, ext=Dict{String, Any}(), γd=((Td0_pp*Xd_pp)/(Td0_p*Xd_p) )*(Xd-Xd_p), γq=((Tq0_pp*Xq_pp)/(Tq0_p*Xq_p) )*(Xq-Xq_p), states=[:eq_p, :ed_p, :eq_pp, :ed_pp], n_states=4, internal=InfrastructureSystemsInternal(), )
    SimpleMarconatoMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, T_AA, ext, γd, γq, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function SimpleMarconatoMachine(::Nothing)
    SimpleMarconatoMachine(;
        R=0,
        Xd=0,
        Xq=0,
        Xd_p=0,
        Xq_p=0,
        Xd_pp=0,
        Xq_pp=0,
        Td0_p=0,
        Tq0_p=0,
        Td0_pp=0,
        Tq0_pp=0,
        T_AA=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`SimpleMarconatoMachine`](@ref) `R`."""
get_R(value::SimpleMarconatoMachine) = value.R
"""Get [`SimpleMarconatoMachine`](@ref) `Xd`."""
get_Xd(value::SimpleMarconatoMachine) = value.Xd
"""Get [`SimpleMarconatoMachine`](@ref) `Xq`."""
get_Xq(value::SimpleMarconatoMachine) = value.Xq
"""Get [`SimpleMarconatoMachine`](@ref) `Xd_p`."""
get_Xd_p(value::SimpleMarconatoMachine) = value.Xd_p
"""Get [`SimpleMarconatoMachine`](@ref) `Xq_p`."""
get_Xq_p(value::SimpleMarconatoMachine) = value.Xq_p
"""Get [`SimpleMarconatoMachine`](@ref) `Xd_pp`."""
get_Xd_pp(value::SimpleMarconatoMachine) = value.Xd_pp
"""Get [`SimpleMarconatoMachine`](@ref) `Xq_pp`."""
get_Xq_pp(value::SimpleMarconatoMachine) = value.Xq_pp
"""Get [`SimpleMarconatoMachine`](@ref) `Td0_p`."""
get_Td0_p(value::SimpleMarconatoMachine) = value.Td0_p
"""Get [`SimpleMarconatoMachine`](@ref) `Tq0_p`."""
get_Tq0_p(value::SimpleMarconatoMachine) = value.Tq0_p
"""Get [`SimpleMarconatoMachine`](@ref) `Td0_pp`."""
get_Td0_pp(value::SimpleMarconatoMachine) = value.Td0_pp
"""Get [`SimpleMarconatoMachine`](@ref) `Tq0_pp`."""
get_Tq0_pp(value::SimpleMarconatoMachine) = value.Tq0_pp
"""Get [`SimpleMarconatoMachine`](@ref) `T_AA`."""
get_T_AA(value::SimpleMarconatoMachine) = value.T_AA
"""Get [`SimpleMarconatoMachine`](@ref) `ext`."""
get_ext(value::SimpleMarconatoMachine) = value.ext
"""Get [`SimpleMarconatoMachine`](@ref) `γd`."""
get_γd(value::SimpleMarconatoMachine) = value.γd
"""Get [`SimpleMarconatoMachine`](@ref) `γq`."""
get_γq(value::SimpleMarconatoMachine) = value.γq
"""Get [`SimpleMarconatoMachine`](@ref) `states`."""
get_states(value::SimpleMarconatoMachine) = value.states
"""Get [`SimpleMarconatoMachine`](@ref) `n_states`."""
get_n_states(value::SimpleMarconatoMachine) = value.n_states
"""Get [`SimpleMarconatoMachine`](@ref) `internal`."""
get_internal(value::SimpleMarconatoMachine) = value.internal

"""Set [`SimpleMarconatoMachine`](@ref) `R`."""
set_R!(value::SimpleMarconatoMachine, val) = value.R = val
"""Set [`SimpleMarconatoMachine`](@ref) `Xd`."""
set_Xd!(value::SimpleMarconatoMachine, val) = value.Xd = val
"""Set [`SimpleMarconatoMachine`](@ref) `Xq`."""
set_Xq!(value::SimpleMarconatoMachine, val) = value.Xq = val
"""Set [`SimpleMarconatoMachine`](@ref) `Xd_p`."""
set_Xd_p!(value::SimpleMarconatoMachine, val) = value.Xd_p = val
"""Set [`SimpleMarconatoMachine`](@ref) `Xq_p`."""
set_Xq_p!(value::SimpleMarconatoMachine, val) = value.Xq_p = val
"""Set [`SimpleMarconatoMachine`](@ref) `Xd_pp`."""
set_Xd_pp!(value::SimpleMarconatoMachine, val) = value.Xd_pp = val
"""Set [`SimpleMarconatoMachine`](@ref) `Xq_pp`."""
set_Xq_pp!(value::SimpleMarconatoMachine, val) = value.Xq_pp = val
"""Set [`SimpleMarconatoMachine`](@ref) `Td0_p`."""
set_Td0_p!(value::SimpleMarconatoMachine, val) = value.Td0_p = val
"""Set [`SimpleMarconatoMachine`](@ref) `Tq0_p`."""
set_Tq0_p!(value::SimpleMarconatoMachine, val) = value.Tq0_p = val
"""Set [`SimpleMarconatoMachine`](@ref) `Td0_pp`."""
set_Td0_pp!(value::SimpleMarconatoMachine, val) = value.Td0_pp = val
"""Set [`SimpleMarconatoMachine`](@ref) `Tq0_pp`."""
set_Tq0_pp!(value::SimpleMarconatoMachine, val) = value.Tq0_pp = val
"""Set [`SimpleMarconatoMachine`](@ref) `T_AA`."""
set_T_AA!(value::SimpleMarconatoMachine, val) = value.T_AA = val
"""Set [`SimpleMarconatoMachine`](@ref) `ext`."""
set_ext!(value::SimpleMarconatoMachine, val) = value.ext = val
"""Set [`SimpleMarconatoMachine`](@ref) `γd`."""
set_γd!(value::SimpleMarconatoMachine, val) = value.γd = val
"""Set [`SimpleMarconatoMachine`](@ref) `γq`."""
set_γq!(value::SimpleMarconatoMachine, val) = value.γq = val



function from_openapi(po::PD.SimpleMarconatoMachine, refs::OpenAPIRefs)
    return SimpleMarconatoMachine(;
        R = _wire_required(po.r, "SimpleMarconatoMachine", "R"),
        Xd = _wire_required(po.xd, "SimpleMarconatoMachine", "Xd"),
        Xq = _wire_required(po.xq, "SimpleMarconatoMachine", "Xq"),
        Xd_p = _wire_required(po.xd_p, "SimpleMarconatoMachine", "Xd_p"),
        Xq_p = _wire_required(po.xq_p, "SimpleMarconatoMachine", "Xq_p"),
        Xd_pp = _wire_required(po.xd_pp, "SimpleMarconatoMachine", "Xd_pp"),
        Xq_pp = _wire_required(po.xq_pp, "SimpleMarconatoMachine", "Xq_pp"),
        Td0_p = _wire_required(po.td0_p, "SimpleMarconatoMachine", "Td0_p"),
        Tq0_p = _wire_required(po.tq0_p, "SimpleMarconatoMachine", "Tq0_p"),
        Td0_pp = _wire_required(po.td0_pp, "SimpleMarconatoMachine", "Td0_pp"),
        Tq0_pp = _wire_required(po.tq0_pp, "SimpleMarconatoMachine", "Tq0_pp"),
        T_AA = _wire_required(po.t_aa, "SimpleMarconatoMachine", "T_AA"),
    )
end

function to_openapi(value::SimpleMarconatoMachine, refs::OpenAPIRefs)
    return PD.SimpleMarconatoMachine(;
        id = component_id(refs, value),
        r = get_R(value),
        xd = get_Xd(value),
        xq = get_Xq(value),
        xd_p = get_Xd_p(value),
        xq_p = get_Xq_p(value),
        xd_pp = get_Xd_pp(value),
        xq_pp = get_Xq_pp(value),
        td0_p = get_Td0_p(value),
        tq0_p = get_Tq0_p(value),
        td0_pp = get_Td0_pp(value),
        tq0_pp = get_Tq0_pp(value),
        t_aa = get_T_AA(value),
    )
end
