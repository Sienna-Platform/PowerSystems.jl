#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SimpleFullMachine <: SynchronousMachineDynamics
        R::Float64
        R_f::Float64
        R_1d::Float64
        R_1q::Float64
        L_d::Float64
        L_q::Float64
        L_ad::Float64
        L_aq::Float64
        L_f1d::Float64
        L_ff::Float64
        L_1d::Float64
        L_1q::Float64
        ext::Dict{String, Any}
        inv_d_fluxlink::Array{Float64,2}
        inv_q_fluxlink::Array{Float64,2}
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameter of a full order flux stator-rotor model without zero sequence flux in the stator.
 The derivative of stator fluxes (ψd and ψq) is neglected. This is standard when
 transmission network dynamics is neglected. Only one q-axis damping circuit
 is considered. All per unit are in machine per unit.
 Refer to Chapter 3 of Power System Stability and Control by P. Kundur or Chapter 11 of Power System Dynamics: Stability and Control, by J. Machowski, J. Bialek and J. Bumby, for more details.
 Note that the models are somewhat different (but equivalent) due to the different Park Transformation used in both books

# Arguments
- `R::Float64`: Resistance after EMF in machine per unit, validation range: `(0, nothing)`
- `R_f::Float64`: Field rotor winding resistance in per unit, validation range: `(0, nothing)`
- `R_1d::Float64`:  Damping rotor winding resistance on d-axis in per unit. This value is denoted as RD in Machowski, validation range: `(0, nothing)`
- `R_1q::Float64`: Damping rotor winding resistance on q-axis in per unit. This value is denoted as RQ in Machowski, validation range: `(0, nothing)`
- `L_d::Float64`: Inductance of fictitious damping that represent the effect of the three-phase stator winding in the d-axis of the rotor, in per unit. This value is denoted as L_ad + L_l in Kundur (and Ld in Machowski), validation range: `(0, nothing)`
- `L_q::Float64`: Inductance of fictitious damping that represent the effect of the three-phase stator winding in the q-axis of the rotor, in per unit. This value is denoted as L_aq + L_l in Kundur, validation range: `(0, nothing)`
- `L_ad::Float64`: Mutual inductance between stator winding and rotor field (and damping) winding inductance on d-axis, in per unit, validation range: `(0, nothing)`
- `L_aq::Float64`: Mutual inductance between stator winding and rotor damping winding inductance on q-axis, in per unit, validation range: `(0, nothing)`
- `L_f1d::Float64`: Mutual inductance between rotor field winding and rotor damping winding inductance on d-axis, in per unit, validation range: `(0, nothing)`
- `L_ff::Float64`: Field rotor winding inductance, in per unit, validation range: `(0, nothing)`
- `L_1d::Float64`: Inductance of the d-axis rotor damping circuit, in per unit, validation range: `(0, nothing)`
- `L_1q::Float64`: Inductance of the q-axis rotor damping circuit, in per unit, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `inv_d_fluxlink::Array{Float64,2}`: (**Do not modify.**) Equations 3.127, 3.130, 3.131 From Kundur
- `inv_q_fluxlink::Array{Float64,2}`: (**Do not modify.**) Equations 3.128, 3.132 From Kundur
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	ψf: field rotor flux,
	ψ1d: d-axis rotor damping flux,
	ψ1q: q-axis rotor damping flux
- `n_states::Int`: (**Do not modify.**) SimpleFullMachine has 3 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct SimpleFullMachine <: SynchronousMachineDynamics
    "Resistance after EMF in machine per unit"
    R::Float64
    "Field rotor winding resistance in per unit"
    R_f::Float64
    " Damping rotor winding resistance on d-axis in per unit. This value is denoted as RD in Machowski"
    R_1d::Float64
    "Damping rotor winding resistance on q-axis in per unit. This value is denoted as RQ in Machowski"
    R_1q::Float64
    "Inductance of fictitious damping that represent the effect of the three-phase stator winding in the d-axis of the rotor, in per unit. This value is denoted as L_ad + L_l in Kundur (and Ld in Machowski)"
    L_d::Float64
    "Inductance of fictitious damping that represent the effect of the three-phase stator winding in the q-axis of the rotor, in per unit. This value is denoted as L_aq + L_l in Kundur"
    L_q::Float64
    "Mutual inductance between stator winding and rotor field (and damping) winding inductance on d-axis, in per unit"
    L_ad::Float64
    "Mutual inductance between stator winding and rotor damping winding inductance on q-axis, in per unit"
    L_aq::Float64
    "Mutual inductance between rotor field winding and rotor damping winding inductance on d-axis, in per unit"
    L_f1d::Float64
    "Field rotor winding inductance, in per unit"
    L_ff::Float64
    "Inductance of the d-axis rotor damping circuit, in per unit"
    L_1d::Float64
    "Inductance of the q-axis rotor damping circuit, in per unit"
    L_1q::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) Equations 3.127, 3.130, 3.131 From Kundur"
    inv_d_fluxlink::Array{Float64,2}
    "(**Do not modify.**) Equations 3.128, 3.132 From Kundur"
    inv_q_fluxlink::Array{Float64,2}
    "(**Do not modify.**) The [states](@ref S) are:
	ψf: field rotor flux,
	ψ1d: d-axis rotor damping flux,
	ψ1q: q-axis rotor damping flux"
    states::Vector{Symbol}
    "(**Do not modify.**) SimpleFullMachine has 3 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function SimpleFullMachine(R, R_f, R_1d, R_1q, L_d, L_q, L_ad, L_aq, L_f1d, L_ff, L_1d, L_1q, ext=Dict{String, Any}(), )
    SimpleFullMachine(R, R_f, R_1d, R_1q, L_d, L_q, L_ad, L_aq, L_f1d, L_ff, L_1d, L_1q, ext, inv([[-L_d L_ad L_ad]; [-L_ad L_ff L_f1d]; [-L_ad L_f1d L_1d]]), inv([[-L_q L_aq]; [-L_aq L_1q]]), [:ψf, :ψ1d, :ψ1q], 3, InfrastructureSystemsInternal(), )
end

function SimpleFullMachine(; R, R_f, R_1d, R_1q, L_d, L_q, L_ad, L_aq, L_f1d, L_ff, L_1d, L_1q, ext=Dict{String, Any}(), inv_d_fluxlink=inv([[-L_d L_ad L_ad]; [-L_ad L_ff L_f1d]; [-L_ad L_f1d L_1d]]), inv_q_fluxlink=inv([[-L_q L_aq]; [-L_aq L_1q]]), states=[:ψf, :ψ1d, :ψ1q], n_states=3, internal=InfrastructureSystemsInternal(), )
    SimpleFullMachine(R, R_f, R_1d, R_1q, L_d, L_q, L_ad, L_aq, L_f1d, L_ff, L_1d, L_1q, ext, inv_d_fluxlink, inv_q_fluxlink, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function SimpleFullMachine(::Nothing)
    SimpleFullMachine(;
        R=0,
        R_f=0,
        R_1d=0,
        R_1q=0,
        L_d=1,
        L_q=1,
        L_ad=2,
        L_aq=1,
        L_f1d=1,
        L_ff=2,
        L_1d=1,
        L_1q=2,
        ext=Dict{String, Any}(),
    )
end

"""Get [`SimpleFullMachine`](@ref) `R`."""
get_R(value::SimpleFullMachine) = value.R
"""Get [`SimpleFullMachine`](@ref) `R_f`."""
get_R_f(value::SimpleFullMachine) = value.R_f
"""Get [`SimpleFullMachine`](@ref) `R_1d`."""
get_R_1d(value::SimpleFullMachine) = value.R_1d
"""Get [`SimpleFullMachine`](@ref) `R_1q`."""
get_R_1q(value::SimpleFullMachine) = value.R_1q
"""Get [`SimpleFullMachine`](@ref) `L_d`."""
get_L_d(value::SimpleFullMachine) = value.L_d
"""Get [`SimpleFullMachine`](@ref) `L_q`."""
get_L_q(value::SimpleFullMachine) = value.L_q
"""Get [`SimpleFullMachine`](@ref) `L_ad`."""
get_L_ad(value::SimpleFullMachine) = value.L_ad
"""Get [`SimpleFullMachine`](@ref) `L_aq`."""
get_L_aq(value::SimpleFullMachine) = value.L_aq
"""Get [`SimpleFullMachine`](@ref) `L_f1d`."""
get_L_f1d(value::SimpleFullMachine) = value.L_f1d
"""Get [`SimpleFullMachine`](@ref) `L_ff`."""
get_L_ff(value::SimpleFullMachine) = value.L_ff
"""Get [`SimpleFullMachine`](@ref) `L_1d`."""
get_L_1d(value::SimpleFullMachine) = value.L_1d
"""Get [`SimpleFullMachine`](@ref) `L_1q`."""
get_L_1q(value::SimpleFullMachine) = value.L_1q
"""Get [`SimpleFullMachine`](@ref) `ext`."""
get_ext(value::SimpleFullMachine) = value.ext
"""Get [`SimpleFullMachine`](@ref) `inv_d_fluxlink`."""
get_inv_d_fluxlink(value::SimpleFullMachine) = value.inv_d_fluxlink
"""Get [`SimpleFullMachine`](@ref) `inv_q_fluxlink`."""
get_inv_q_fluxlink(value::SimpleFullMachine) = value.inv_q_fluxlink
"""Get [`SimpleFullMachine`](@ref) `states`."""
get_states(value::SimpleFullMachine) = value.states
"""Get [`SimpleFullMachine`](@ref) `n_states`."""
get_n_states(value::SimpleFullMachine) = value.n_states
"""Get [`SimpleFullMachine`](@ref) `internal`."""
get_internal(value::SimpleFullMachine) = value.internal

"""Set [`SimpleFullMachine`](@ref) `R`."""
set_R!(value::SimpleFullMachine, val) = value.R = val
"""Set [`SimpleFullMachine`](@ref) `R_f`."""
set_R_f!(value::SimpleFullMachine, val) = value.R_f = val
"""Set [`SimpleFullMachine`](@ref) `R_1d`."""
set_R_1d!(value::SimpleFullMachine, val) = value.R_1d = val
"""Set [`SimpleFullMachine`](@ref) `R_1q`."""
set_R_1q!(value::SimpleFullMachine, val) = value.R_1q = val
"""Set [`SimpleFullMachine`](@ref) `L_d`."""
set_L_d!(value::SimpleFullMachine, val) = value.L_d = val
"""Set [`SimpleFullMachine`](@ref) `L_q`."""
set_L_q!(value::SimpleFullMachine, val) = value.L_q = val
"""Set [`SimpleFullMachine`](@ref) `L_ad`."""
set_L_ad!(value::SimpleFullMachine, val) = value.L_ad = val
"""Set [`SimpleFullMachine`](@ref) `L_aq`."""
set_L_aq!(value::SimpleFullMachine, val) = value.L_aq = val
"""Set [`SimpleFullMachine`](@ref) `L_f1d`."""
set_L_f1d!(value::SimpleFullMachine, val) = value.L_f1d = val
"""Set [`SimpleFullMachine`](@ref) `L_ff`."""
set_L_ff!(value::SimpleFullMachine, val) = value.L_ff = val
"""Set [`SimpleFullMachine`](@ref) `L_1d`."""
set_L_1d!(value::SimpleFullMachine, val) = value.L_1d = val
"""Set [`SimpleFullMachine`](@ref) `L_1q`."""
set_L_1q!(value::SimpleFullMachine, val) = value.L_1q = val
"""Set [`SimpleFullMachine`](@ref) `ext`."""
set_ext!(value::SimpleFullMachine, val) = value.ext = val
"""Set [`SimpleFullMachine`](@ref) `inv_d_fluxlink`."""
set_inv_d_fluxlink!(value::SimpleFullMachine, val) = value.inv_d_fluxlink = val
"""Set [`SimpleFullMachine`](@ref) `inv_q_fluxlink`."""
set_inv_q_fluxlink!(value::SimpleFullMachine, val) = value.inv_q_fluxlink = val



function from_openapi(po::PD.SimpleFullMachine, refs::OpenAPIRefs)
    return SimpleFullMachine(;
        R = _wire_required(po.r, "SimpleFullMachine", "R"),
        R_f = _wire_required(po.r_f, "SimpleFullMachine", "R_f"),
        R_1d = _wire_required(po.r_1d, "SimpleFullMachine", "R_1d"),
        R_1q = _wire_required(po.r_1q, "SimpleFullMachine", "R_1q"),
        L_d = _wire_required(po.l_d, "SimpleFullMachine", "L_d"),
        L_q = _wire_required(po.l_q, "SimpleFullMachine", "L_q"),
        L_ad = _wire_required(po.l_ad, "SimpleFullMachine", "L_ad"),
        L_aq = _wire_required(po.l_aq, "SimpleFullMachine", "L_aq"),
        L_f1d = _wire_required(po.l_f1d, "SimpleFullMachine", "L_f1d"),
        L_ff = _wire_required(po.l_ff, "SimpleFullMachine", "L_ff"),
        L_1d = _wire_required(po.l_1d, "SimpleFullMachine", "L_1d"),
        L_1q = _wire_required(po.l_1q, "SimpleFullMachine", "L_1q"),
    )
end

function to_openapi(value::SimpleFullMachine, refs::OpenAPIRefs)
    return PD.SimpleFullMachine(;
        id = component_id(refs, value),
        r = get_R(value),
        r_f = get_R_f(value),
        r_1d = get_R_1d(value),
        r_1q = get_R_1q(value),
        l_d = get_L_d(value),
        l_q = get_L_q(value),
        l_ad = get_L_ad(value),
        l_aq = get_L_aq(value),
        l_f1d = get_L_f1d(value),
        l_ff = get_L_ff(value),
        l_1d = get_L_1d(value),
        l_1q = get_L_1q(value),
    )
end
