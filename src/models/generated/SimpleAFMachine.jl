#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SimpleAFMachine <: SynchronousMachineDynamics
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
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of 4-[states](@ref S) simplified Anderson-Fouad (SimpleAFMachine) model.
 The derivative of stator fluxes (ψd and ψq) is neglected and ωψd = ψd and
 ωψq = ψq is assumed (i.e. ω=1.0). This is standard when transmission network
 dynamics is neglected.
 If transmission dynamics is considered use the full order Anderson Fouad model

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
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	eq_p: q-axis transient voltage,
	ed_p: d-axis transient voltage,
	eq_pp: q-axis subtransient voltage,
	ed_pp: d-axis subtransient voltage
- `n_states::Int`: (**Do not modify.**) SimpleAFMachine has 4 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct SimpleAFMachine <: SynchronousMachineDynamics
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
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	eq_p: q-axis transient voltage,
	ed_p: d-axis transient voltage,
	eq_pp: q-axis subtransient voltage,
	ed_pp: d-axis subtransient voltage"
    states::Vector{Symbol}
    "(**Do not modify.**) SimpleAFMachine has 4 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function SimpleAFMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, ext=Dict{String, Any}(), )
    SimpleAFMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, ext, [:eq_p, :ed_p, :eq_pp, :ed_pp], 4, InfrastructureSystemsInternal(), )
end

function SimpleAFMachine(; R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, ext=Dict{String, Any}(), states=[:eq_p, :ed_p, :eq_pp, :ed_pp], n_states=4, internal=InfrastructureSystemsInternal(), )
    SimpleAFMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, ext, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function SimpleAFMachine(::Nothing)
    SimpleAFMachine(;
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
        ext=Dict{String, Any}(),
    )
end

"""Get [`SimpleAFMachine`](@ref) `R`."""
get_R(value::SimpleAFMachine) = value.R
"""Get [`SimpleAFMachine`](@ref) `Xd`."""
get_Xd(value::SimpleAFMachine) = value.Xd
"""Get [`SimpleAFMachine`](@ref) `Xq`."""
get_Xq(value::SimpleAFMachine) = value.Xq
"""Get [`SimpleAFMachine`](@ref) `Xd_p`."""
get_Xd_p(value::SimpleAFMachine) = value.Xd_p
"""Get [`SimpleAFMachine`](@ref) `Xq_p`."""
get_Xq_p(value::SimpleAFMachine) = value.Xq_p
"""Get [`SimpleAFMachine`](@ref) `Xd_pp`."""
get_Xd_pp(value::SimpleAFMachine) = value.Xd_pp
"""Get [`SimpleAFMachine`](@ref) `Xq_pp`."""
get_Xq_pp(value::SimpleAFMachine) = value.Xq_pp
"""Get [`SimpleAFMachine`](@ref) `Td0_p`."""
get_Td0_p(value::SimpleAFMachine) = value.Td0_p
"""Get [`SimpleAFMachine`](@ref) `Tq0_p`."""
get_Tq0_p(value::SimpleAFMachine) = value.Tq0_p
"""Get [`SimpleAFMachine`](@ref) `Td0_pp`."""
get_Td0_pp(value::SimpleAFMachine) = value.Td0_pp
"""Get [`SimpleAFMachine`](@ref) `Tq0_pp`."""
get_Tq0_pp(value::SimpleAFMachine) = value.Tq0_pp
"""Get [`SimpleAFMachine`](@ref) `ext`."""
get_ext(value::SimpleAFMachine) = value.ext
"""Get [`SimpleAFMachine`](@ref) `states`."""
get_states(value::SimpleAFMachine) = value.states
"""Get [`SimpleAFMachine`](@ref) `n_states`."""
get_n_states(value::SimpleAFMachine) = value.n_states
"""Get [`SimpleAFMachine`](@ref) `internal`."""
get_internal(value::SimpleAFMachine) = value.internal

"""Set [`SimpleAFMachine`](@ref) `R`."""
set_R!(value::SimpleAFMachine, val) = value.R = val
"""Set [`SimpleAFMachine`](@ref) `Xd`."""
set_Xd!(value::SimpleAFMachine, val) = value.Xd = val
"""Set [`SimpleAFMachine`](@ref) `Xq`."""
set_Xq!(value::SimpleAFMachine, val) = value.Xq = val
"""Set [`SimpleAFMachine`](@ref) `Xd_p`."""
set_Xd_p!(value::SimpleAFMachine, val) = value.Xd_p = val
"""Set [`SimpleAFMachine`](@ref) `Xq_p`."""
set_Xq_p!(value::SimpleAFMachine, val) = value.Xq_p = val
"""Set [`SimpleAFMachine`](@ref) `Xd_pp`."""
set_Xd_pp!(value::SimpleAFMachine, val) = value.Xd_pp = val
"""Set [`SimpleAFMachine`](@ref) `Xq_pp`."""
set_Xq_pp!(value::SimpleAFMachine, val) = value.Xq_pp = val
"""Set [`SimpleAFMachine`](@ref) `Td0_p`."""
set_Td0_p!(value::SimpleAFMachine, val) = value.Td0_p = val
"""Set [`SimpleAFMachine`](@ref) `Tq0_p`."""
set_Tq0_p!(value::SimpleAFMachine, val) = value.Tq0_p = val
"""Set [`SimpleAFMachine`](@ref) `Td0_pp`."""
set_Td0_pp!(value::SimpleAFMachine, val) = value.Td0_pp = val
"""Set [`SimpleAFMachine`](@ref) `Tq0_pp`."""
set_Tq0_pp!(value::SimpleAFMachine, val) = value.Tq0_pp = val
"""Set [`SimpleAFMachine`](@ref) `ext`."""
set_ext!(value::SimpleAFMachine, val) = value.ext = val



function from_openapi(po::PD.SimpleAFMachine, refs::OpenAPIRefs)
    return SimpleAFMachine(;
        R = _wire_required(po.r, "SimpleAFMachine", "R"),
        Xd = _wire_required(po.xd, "SimpleAFMachine", "Xd"),
        Xq = _wire_required(po.xq, "SimpleAFMachine", "Xq"),
        Xd_p = _wire_required(po.xd_p, "SimpleAFMachine", "Xd_p"),
        Xq_p = _wire_required(po.xq_p, "SimpleAFMachine", "Xq_p"),
        Xd_pp = _wire_required(po.xd_pp, "SimpleAFMachine", "Xd_pp"),
        Xq_pp = _wire_required(po.xq_pp, "SimpleAFMachine", "Xq_pp"),
        Td0_p = _wire_required(po.td0_p, "SimpleAFMachine", "Td0_p"),
        Tq0_p = _wire_required(po.tq0_p, "SimpleAFMachine", "Tq0_p"),
        Td0_pp = _wire_required(po.td0_pp, "SimpleAFMachine", "Td0_pp"),
        Tq0_pp = _wire_required(po.tq0_pp, "SimpleAFMachine", "Tq0_pp"),
    )
end

function to_openapi(value::SimpleAFMachine, refs::OpenAPIRefs)
    return PD.SimpleAFMachine(;
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
    )
end
