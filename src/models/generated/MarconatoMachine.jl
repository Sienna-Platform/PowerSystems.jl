#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct MarconatoMachine <: SynchronousMachineDynamics
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

Parameters of 6-[states](@ref S) synchronous machine: Marconato model

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
	ψq: q-axis stator flux,
	ψd: d-axis stator flux,
	eq_p: q-axis transient voltage,
	ed_p: d-axis transient voltage,
	eq_pp: q-axis subtransient voltage,
	ed_pp: d-axis subtransient voltage
- `n_states::Int`: (**Do not modify.**) MarconatoMachine has 6 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct MarconatoMachine <: SynchronousMachineDynamics
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
	ψq: q-axis stator flux,
	ψd: d-axis stator flux,
	eq_p: q-axis transient voltage,
	ed_p: d-axis transient voltage,
	eq_pp: q-axis subtransient voltage,
	ed_pp: d-axis subtransient voltage"
    states::Vector{Symbol}
    "(**Do not modify.**) MarconatoMachine has 6 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function MarconatoMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, T_AA, ext=Dict{String, Any}(), )
    MarconatoMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, T_AA, ext, ((Td0_pp*Xd_pp)/(Td0_p*Xd_p) )*(Xd-Xd_p), ((Tq0_pp*Xq_pp)/(Tq0_p*Xq_p) )*(Xq-Xq_p), [:ψq, :ψd, :eq_p, :ed_p, :eq_pp, :ed_pp], 6, InfrastructureSystemsInternal(), )
end

function MarconatoMachine(; R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, T_AA, ext=Dict{String, Any}(), γd=((Td0_pp*Xd_pp)/(Td0_p*Xd_p) )*(Xd-Xd_p), γq=((Tq0_pp*Xq_pp)/(Tq0_p*Xq_p) )*(Xq-Xq_p), states=[:ψq, :ψd, :eq_p, :ed_p, :eq_pp, :ed_pp], n_states=6, internal=InfrastructureSystemsInternal(), )
    MarconatoMachine(R, Xd, Xq, Xd_p, Xq_p, Xd_pp, Xq_pp, Td0_p, Tq0_p, Td0_pp, Tq0_pp, T_AA, ext, γd, γq, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function MarconatoMachine(::Nothing)
    MarconatoMachine(;
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

"""Get [`MarconatoMachine`](@ref) `R`."""
get_R(value::MarconatoMachine) = value.R
"""Get [`MarconatoMachine`](@ref) `Xd`."""
get_Xd(value::MarconatoMachine) = value.Xd
"""Get [`MarconatoMachine`](@ref) `Xq`."""
get_Xq(value::MarconatoMachine) = value.Xq
"""Get [`MarconatoMachine`](@ref) `Xd_p`."""
get_Xd_p(value::MarconatoMachine) = value.Xd_p
"""Get [`MarconatoMachine`](@ref) `Xq_p`."""
get_Xq_p(value::MarconatoMachine) = value.Xq_p
"""Get [`MarconatoMachine`](@ref) `Xd_pp`."""
get_Xd_pp(value::MarconatoMachine) = value.Xd_pp
"""Get [`MarconatoMachine`](@ref) `Xq_pp`."""
get_Xq_pp(value::MarconatoMachine) = value.Xq_pp
"""Get [`MarconatoMachine`](@ref) `Td0_p`."""
get_Td0_p(value::MarconatoMachine) = value.Td0_p
"""Get [`MarconatoMachine`](@ref) `Tq0_p`."""
get_Tq0_p(value::MarconatoMachine) = value.Tq0_p
"""Get [`MarconatoMachine`](@ref) `Td0_pp`."""
get_Td0_pp(value::MarconatoMachine) = value.Td0_pp
"""Get [`MarconatoMachine`](@ref) `Tq0_pp`."""
get_Tq0_pp(value::MarconatoMachine) = value.Tq0_pp
"""Get [`MarconatoMachine`](@ref) `T_AA`."""
get_T_AA(value::MarconatoMachine) = value.T_AA
"""Get [`MarconatoMachine`](@ref) `ext`."""
get_ext(value::MarconatoMachine) = value.ext
"""Get [`MarconatoMachine`](@ref) `γd`."""
get_γd(value::MarconatoMachine) = value.γd
"""Get [`MarconatoMachine`](@ref) `γq`."""
get_γq(value::MarconatoMachine) = value.γq
"""Get [`MarconatoMachine`](@ref) `states`."""
get_states(value::MarconatoMachine) = value.states
"""Get [`MarconatoMachine`](@ref) `n_states`."""
get_n_states(value::MarconatoMachine) = value.n_states
"""Get [`MarconatoMachine`](@ref) `internal`."""
get_internal(value::MarconatoMachine) = value.internal

"""Set [`MarconatoMachine`](@ref) `R`."""
set_R!(value::MarconatoMachine, val) = value.R = val
"""Set [`MarconatoMachine`](@ref) `Xd`."""
set_Xd!(value::MarconatoMachine, val) = value.Xd = val
"""Set [`MarconatoMachine`](@ref) `Xq`."""
set_Xq!(value::MarconatoMachine, val) = value.Xq = val
"""Set [`MarconatoMachine`](@ref) `Xd_p`."""
set_Xd_p!(value::MarconatoMachine, val) = value.Xd_p = val
"""Set [`MarconatoMachine`](@ref) `Xq_p`."""
set_Xq_p!(value::MarconatoMachine, val) = value.Xq_p = val
"""Set [`MarconatoMachine`](@ref) `Xd_pp`."""
set_Xd_pp!(value::MarconatoMachine, val) = value.Xd_pp = val
"""Set [`MarconatoMachine`](@ref) `Xq_pp`."""
set_Xq_pp!(value::MarconatoMachine, val) = value.Xq_pp = val
"""Set [`MarconatoMachine`](@ref) `Td0_p`."""
set_Td0_p!(value::MarconatoMachine, val) = value.Td0_p = val
"""Set [`MarconatoMachine`](@ref) `Tq0_p`."""
set_Tq0_p!(value::MarconatoMachine, val) = value.Tq0_p = val
"""Set [`MarconatoMachine`](@ref) `Td0_pp`."""
set_Td0_pp!(value::MarconatoMachine, val) = value.Td0_pp = val
"""Set [`MarconatoMachine`](@ref) `Tq0_pp`."""
set_Tq0_pp!(value::MarconatoMachine, val) = value.Tq0_pp = val
"""Set [`MarconatoMachine`](@ref) `T_AA`."""
set_T_AA!(value::MarconatoMachine, val) = value.T_AA = val
"""Set [`MarconatoMachine`](@ref) `ext`."""
set_ext!(value::MarconatoMachine, val) = value.ext = val
"""Set [`MarconatoMachine`](@ref) `γd`."""
set_γd!(value::MarconatoMachine, val) = value.γd = val
"""Set [`MarconatoMachine`](@ref) `γq`."""
set_γq!(value::MarconatoMachine, val) = value.γq = val



function from_openapi(po::PD.MarconatoMachine, refs::OpenAPIRefs)
    return MarconatoMachine(;
        R = _wire_required(po.r, "MarconatoMachine", "R"),
        Xd = _wire_required(po.xd, "MarconatoMachine", "Xd"),
        Xq = _wire_required(po.xq, "MarconatoMachine", "Xq"),
        Xd_p = _wire_required(po.xd_p, "MarconatoMachine", "Xd_p"),
        Xq_p = _wire_required(po.xq_p, "MarconatoMachine", "Xq_p"),
        Xd_pp = _wire_required(po.xd_pp, "MarconatoMachine", "Xd_pp"),
        Xq_pp = _wire_required(po.xq_pp, "MarconatoMachine", "Xq_pp"),
        Td0_p = _wire_required(po.td0_p, "MarconatoMachine", "Td0_p"),
        Tq0_p = _wire_required(po.tq0_p, "MarconatoMachine", "Tq0_p"),
        Td0_pp = _wire_required(po.td0_pp, "MarconatoMachine", "Td0_pp"),
        Tq0_pp = _wire_required(po.tq0_pp, "MarconatoMachine", "Tq0_pp"),
        T_AA = _wire_required(po.t_aa, "MarconatoMachine", "T_AA"),
    )
end

function to_openapi(value::MarconatoMachine, refs::OpenAPIRefs)
    return PD.MarconatoMachine(;
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
