#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct OneDOneQMachine <: SynchronousMachineDynamics
        R::Float64
        Xd::Float64
        Xq::Float64
        Xd_p::Float64
        Xq_p::Float64
        Td0_p::Float64
        Tq0_p::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of 4-[states](@ref S) synchronous machine: Simplified Marconato model
 The derivative of stator fluxes (ψd and ψq) is neglected and ωψd = ψd and
 ωψq = ψq is assumed (i.e. ω=1.0). This is standard when
 transmission network dynamics is neglected

# Arguments
- `R::Float64`: Resistance after EMF in machine per unit, validation range: `(0, nothing)`
- `Xd::Float64`: Reactance after EMF in d-axis per unit, validation range: `(0, nothing)`
- `Xq::Float64`: Reactance after EMF in q-axis per unit, validation range: `(0, nothing)`
- `Xd_p::Float64`: Transient reactance after EMF in d-axis per unit, validation range: `(0, nothing)`
- `Xq_p::Float64`: Transient reactance after EMF in q-axis per unit, validation range: `(0, nothing)`
- `Td0_p::Float64`: Time constant of transient d-axis voltage, validation range: `(0, nothing)`
- `Tq0_p::Float64`: Time constant of transient q-axis voltage, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	eq_p: q-axis transient voltage,
	ed_p: d-axis transient voltage
- `n_states::Int`: (**Do not modify.**) OneDOneQMachine has 2 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct OneDOneQMachine <: SynchronousMachineDynamics
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
    "Time constant of transient d-axis voltage"
    Td0_p::Float64
    "Time constant of transient q-axis voltage"
    Tq0_p::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	eq_p: q-axis transient voltage,
	ed_p: d-axis transient voltage"
    states::Vector{Symbol}
    "(**Do not modify.**) OneDOneQMachine has 2 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function OneDOneQMachine(R, Xd, Xq, Xd_p, Xq_p, Td0_p, Tq0_p, ext=Dict{String, Any}(), )
    OneDOneQMachine(R, Xd, Xq, Xd_p, Xq_p, Td0_p, Tq0_p, ext, [:eq_p, :ed_p], 2, InfrastructureSystemsInternal(), )
end

function OneDOneQMachine(; R, Xd, Xq, Xd_p, Xq_p, Td0_p, Tq0_p, ext=Dict{String, Any}(), states=[:eq_p, :ed_p], n_states=2, internal=InfrastructureSystemsInternal(), )
    OneDOneQMachine(R, Xd, Xq, Xd_p, Xq_p, Td0_p, Tq0_p, ext, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function OneDOneQMachine(::Nothing)
    OneDOneQMachine(;
        R=0,
        Xd=0,
        Xq=0,
        Xd_p=0,
        Xq_p=0,
        Td0_p=0,
        Tq0_p=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`OneDOneQMachine`](@ref) `R`."""
get_R(value::OneDOneQMachine) = value.R
"""Get [`OneDOneQMachine`](@ref) `Xd`."""
get_Xd(value::OneDOneQMachine) = value.Xd
"""Get [`OneDOneQMachine`](@ref) `Xq`."""
get_Xq(value::OneDOneQMachine) = value.Xq
"""Get [`OneDOneQMachine`](@ref) `Xd_p`."""
get_Xd_p(value::OneDOneQMachine) = value.Xd_p
"""Get [`OneDOneQMachine`](@ref) `Xq_p`."""
get_Xq_p(value::OneDOneQMachine) = value.Xq_p
"""Get [`OneDOneQMachine`](@ref) `Td0_p`."""
get_Td0_p(value::OneDOneQMachine) = value.Td0_p
"""Get [`OneDOneQMachine`](@ref) `Tq0_p`."""
get_Tq0_p(value::OneDOneQMachine) = value.Tq0_p
"""Get [`OneDOneQMachine`](@ref) `ext`."""
get_ext(value::OneDOneQMachine) = value.ext
"""Get [`OneDOneQMachine`](@ref) `states`."""
get_states(value::OneDOneQMachine) = value.states
"""Get [`OneDOneQMachine`](@ref) `n_states`."""
get_n_states(value::OneDOneQMachine) = value.n_states
"""Get [`OneDOneQMachine`](@ref) `internal`."""
get_internal(value::OneDOneQMachine) = value.internal

"""Set [`OneDOneQMachine`](@ref) `R`."""
set_R!(value::OneDOneQMachine, val) = value.R = val
"""Set [`OneDOneQMachine`](@ref) `Xd`."""
set_Xd!(value::OneDOneQMachine, val) = value.Xd = val
"""Set [`OneDOneQMachine`](@ref) `Xq`."""
set_Xq!(value::OneDOneQMachine, val) = value.Xq = val
"""Set [`OneDOneQMachine`](@ref) `Xd_p`."""
set_Xd_p!(value::OneDOneQMachine, val) = value.Xd_p = val
"""Set [`OneDOneQMachine`](@ref) `Xq_p`."""
set_Xq_p!(value::OneDOneQMachine, val) = value.Xq_p = val
"""Set [`OneDOneQMachine`](@ref) `Td0_p`."""
set_Td0_p!(value::OneDOneQMachine, val) = value.Td0_p = val
"""Set [`OneDOneQMachine`](@ref) `Tq0_p`."""
set_Tq0_p!(value::OneDOneQMachine, val) = value.Tq0_p = val
"""Set [`OneDOneQMachine`](@ref) `ext`."""
set_ext!(value::OneDOneQMachine, val) = value.ext = val



function from_openapi(po::PD.OneDOneQMachine, refs::OpenAPIRefs)
    return OneDOneQMachine(;
        R = _wire_required(po.r, "OneDOneQMachine", "R"),
        Xd = _wire_required(po.xd, "OneDOneQMachine", "Xd"),
        Xq = _wire_required(po.xq, "OneDOneQMachine", "Xq"),
        Xd_p = _wire_required(po.xd_p, "OneDOneQMachine", "Xd_p"),
        Xq_p = _wire_required(po.xq_p, "OneDOneQMachine", "Xq_p"),
        Td0_p = _wire_required(po.td0_p, "OneDOneQMachine", "Td0_p"),
        Tq0_p = _wire_required(po.tq0_p, "OneDOneQMachine", "Tq0_p"),
    )
end

function to_openapi(value::OneDOneQMachine, refs::OpenAPIRefs)
    return PD.OneDOneQMachine(;
        id = component_id(refs, value),
        r = get_R(value),
        xd = get_Xd(value),
        xq = get_Xq(value),
        xd_p = get_Xd_p(value),
        xq_p = get_Xq_p(value),
        td0_p = get_Td0_p(value),
        tq0_p = get_Tq0_p(value),
    )
end
