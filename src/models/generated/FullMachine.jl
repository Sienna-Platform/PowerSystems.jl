#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct FullMachine <: SynchronousMachineDynamics
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
 The derivative of stator fluxes (ψd and ψq) is NOT neglected. Only one q-axis damping circuit is considered. All parameters are in machine per unit.
 Refer to Chapter 3 of [Power System Stability and Control by P. Kundur](https://www.accessengineeringlibrary.com/content/book/9781260473544) or Chapter 11 of [Power System Dynamics: Stability and Control, by J. Machowski, J. Bialek and J. Bumby](https://www.wiley.com/en-us/Power+System+Dynamics%3A+Stability+and+Control%2C+3rd+Edition-p-9781119526360), for more details.
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
	ψd: d-axis stator flux,
	ψq: q-axis stator flux,
	ψf: field rotor flux,
	ψ1d: d-axis rotor damping flux,
	ψ1q: q-axis rotor damping flux
- `n_states::Int`: (**Do not modify.**) FullMachine has 5 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct FullMachine <: SynchronousMachineDynamics
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
	ψd: d-axis stator flux,
	ψq: q-axis stator flux,
	ψf: field rotor flux,
	ψ1d: d-axis rotor damping flux,
	ψ1q: q-axis rotor damping flux"
    states::Vector{Symbol}
    "(**Do not modify.**) FullMachine has 5 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function FullMachine(R, R_f, R_1d, R_1q, L_d, L_q, L_ad, L_aq, L_f1d, L_ff, L_1d, L_1q, ext=Dict{String, Any}(), )
    FullMachine(R, R_f, R_1d, R_1q, L_d, L_q, L_ad, L_aq, L_f1d, L_ff, L_1d, L_1q, ext, inv([[-L_d L_ad L_ad]; [-L_ad L_ff L_f1d]; [-L_ad L_f1d L_1d]]), inv([[-L_q L_aq]; [-L_aq L_1q]]), [:ψd, :ψq, :ψf, :ψ1d, :ψ1q], 5, InfrastructureSystemsInternal(), )
end

function FullMachine(; R, R_f, R_1d, R_1q, L_d, L_q, L_ad, L_aq, L_f1d, L_ff, L_1d, L_1q, ext=Dict{String, Any}(), inv_d_fluxlink=inv([[-L_d L_ad L_ad]; [-L_ad L_ff L_f1d]; [-L_ad L_f1d L_1d]]), inv_q_fluxlink=inv([[-L_q L_aq]; [-L_aq L_1q]]), states=[:ψd, :ψq, :ψf, :ψ1d, :ψ1q], n_states=5, internal=InfrastructureSystemsInternal(), )
    FullMachine(R, R_f, R_1d, R_1q, L_d, L_q, L_ad, L_aq, L_f1d, L_ff, L_1d, L_1q, ext, inv_d_fluxlink, inv_q_fluxlink, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function FullMachine(::Nothing)
    FullMachine(;
        R=0,
        R_f=0,
        R_1d=0,
        R_1q=0,
        L_d=1,
        L_q=1,
        L_ad=2,
        L_aq=2,
        L_f1d=1,
        L_ff=2,
        L_1d=1,
        L_1q=1,
        ext=Dict{String, Any}(),
    )
end

"""Get [`FullMachine`](@ref) `R`."""
get_R(value::FullMachine) = value.R
"""Get [`FullMachine`](@ref) `R_f`."""
get_R_f(value::FullMachine) = value.R_f
"""Get [`FullMachine`](@ref) `R_1d`."""
get_R_1d(value::FullMachine) = value.R_1d
"""Get [`FullMachine`](@ref) `R_1q`."""
get_R_1q(value::FullMachine) = value.R_1q
"""Get [`FullMachine`](@ref) `L_d`."""
get_L_d(value::FullMachine) = value.L_d
"""Get [`FullMachine`](@ref) `L_q`."""
get_L_q(value::FullMachine) = value.L_q
"""Get [`FullMachine`](@ref) `L_ad`."""
get_L_ad(value::FullMachine) = value.L_ad
"""Get [`FullMachine`](@ref) `L_aq`."""
get_L_aq(value::FullMachine) = value.L_aq
"""Get [`FullMachine`](@ref) `L_f1d`."""
get_L_f1d(value::FullMachine) = value.L_f1d
"""Get [`FullMachine`](@ref) `L_ff`."""
get_L_ff(value::FullMachine) = value.L_ff
"""Get [`FullMachine`](@ref) `L_1d`."""
get_L_1d(value::FullMachine) = value.L_1d
"""Get [`FullMachine`](@ref) `L_1q`."""
get_L_1q(value::FullMachine) = value.L_1q
"""Get [`FullMachine`](@ref) `ext`."""
get_ext(value::FullMachine) = value.ext
"""Get [`FullMachine`](@ref) `inv_d_fluxlink`."""
get_inv_d_fluxlink(value::FullMachine) = value.inv_d_fluxlink
"""Get [`FullMachine`](@ref) `inv_q_fluxlink`."""
get_inv_q_fluxlink(value::FullMachine) = value.inv_q_fluxlink
"""Get [`FullMachine`](@ref) `states`."""
get_states(value::FullMachine) = value.states
"""Get [`FullMachine`](@ref) `n_states`."""
get_n_states(value::FullMachine) = value.n_states
"""Get [`FullMachine`](@ref) `internal`."""
get_internal(value::FullMachine) = value.internal

"""Set [`FullMachine`](@ref) `R`."""
set_R!(value::FullMachine, val) = value.R = val
"""Set [`FullMachine`](@ref) `R_f`."""
set_R_f!(value::FullMachine, val) = value.R_f = val
"""Set [`FullMachine`](@ref) `R_1d`."""
set_R_1d!(value::FullMachine, val) = value.R_1d = val
"""Set [`FullMachine`](@ref) `R_1q`."""
set_R_1q!(value::FullMachine, val) = value.R_1q = val
"""Set [`FullMachine`](@ref) `L_d`."""
set_L_d!(value::FullMachine, val) = value.L_d = val
"""Set [`FullMachine`](@ref) `L_q`."""
set_L_q!(value::FullMachine, val) = value.L_q = val
"""Set [`FullMachine`](@ref) `L_ad`."""
set_L_ad!(value::FullMachine, val) = value.L_ad = val
"""Set [`FullMachine`](@ref) `L_aq`."""
set_L_aq!(value::FullMachine, val) = value.L_aq = val
"""Set [`FullMachine`](@ref) `L_f1d`."""
set_L_f1d!(value::FullMachine, val) = value.L_f1d = val
"""Set [`FullMachine`](@ref) `L_ff`."""
set_L_ff!(value::FullMachine, val) = value.L_ff = val
"""Set [`FullMachine`](@ref) `L_1d`."""
set_L_1d!(value::FullMachine, val) = value.L_1d = val
"""Set [`FullMachine`](@ref) `L_1q`."""
set_L_1q!(value::FullMachine, val) = value.L_1q = val
"""Set [`FullMachine`](@ref) `ext`."""
set_ext!(value::FullMachine, val) = value.ext = val
"""Set [`FullMachine`](@ref) `inv_d_fluxlink`."""
set_inv_d_fluxlink!(value::FullMachine, val) = value.inv_d_fluxlink = val
"""Set [`FullMachine`](@ref) `inv_q_fluxlink`."""
set_inv_q_fluxlink!(value::FullMachine, val) = value.inv_q_fluxlink = val



function from_openapi(po::PD.FullMachine, refs::OpenAPIRefs)
    return FullMachine(;
        R = _wire_required(po.r, "FullMachine", "R"),
        R_f = _wire_required(po.r_f, "FullMachine", "R_f"),
        R_1d = _wire_required(po.r_1d, "FullMachine", "R_1d"),
        R_1q = _wire_required(po.r_1q, "FullMachine", "R_1q"),
        L_d = _wire_required(po.l_d, "FullMachine", "L_d"),
        L_q = _wire_required(po.l_q, "FullMachine", "L_q"),
        L_ad = _wire_required(po.l_ad, "FullMachine", "L_ad"),
        L_aq = _wire_required(po.l_aq, "FullMachine", "L_aq"),
        L_f1d = _wire_required(po.l_f1d, "FullMachine", "L_f1d"),
        L_ff = _wire_required(po.l_ff, "FullMachine", "L_ff"),
        L_1d = _wire_required(po.l_1d, "FullMachine", "L_1d"),
        L_1q = _wire_required(po.l_1q, "FullMachine", "L_1q"),
    )
end

function to_openapi(value::FullMachine, refs::OpenAPIRefs)
    return PD.FullMachine(;
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
