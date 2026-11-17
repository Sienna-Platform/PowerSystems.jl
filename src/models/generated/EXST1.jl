#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct EXST1 <: ExcitationSystemDynamics
        Tr::Float64
        Vi_lim::MinMax
        Tc::Float64
        Tb::Float64
        Ka::Float64
        Ta::Float64
        Vr_lim::MinMax
        Kc::Float64
        Kf::Float64
        Tf::Float64
        V_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

IEEE Type ST1 Excitation System (PTI version)

# Arguments
- `Tr::Float64`: Voltage Measurement Time Constant in s, validation range: `(0, nothing)`
- `Vi_lim::MinMax`: Voltage input limits (Vi_min, Vi_max)
- `Tc::Float64`: Numerator lead-lag (lead) time constant in s, validation range: `(0, nothing)`
- `Tb::Float64`: Denominator lead-lag (lag) time constant in s, validation range: `(0, nothing)`
- `Ka::Float64`: Amplifier Gain, validation range: `(0, nothing)`
- `Ta::Float64`: Amplifier Time Constant in s, validation range: `(0, nothing)`
- `Vr_lim::MinMax`: Voltage regulator limits (regulator output) (Vr_min, Vr_max)
- `Kc::Float64`: Current field constant limiter multiplier, validation range: `(0, nothing)`
- `Kf::Float64`: Excitation control system stabilizer gain, validation range: `(0.0001, 0.3)`
- `Tf::Float64`: Excitation control system stabilizer time constant, validation range: `(0.0001, nothing)`
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed Terminal Voltage,
	Vrll: Lead-Lag state,
	Vr: Regulator Output, 
	Vfb: Feedback state
- `n_states::Int`: (**Do not modify.**) The EXST1 has 4 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct EXST1 <: ExcitationSystemDynamics
    "Voltage Measurement Time Constant in s"
    Tr::Float64
    "Voltage input limits (Vi_min, Vi_max)"
    Vi_lim::MinMax
    "Numerator lead-lag (lead) time constant in s"
    Tc::Float64
    "Denominator lead-lag (lag) time constant in s"
    Tb::Float64
    "Amplifier Gain"
    Ka::Float64
    "Amplifier Time Constant in s"
    Ta::Float64
    "Voltage regulator limits (regulator output) (Vr_min, Vr_max)"
    Vr_lim::MinMax
    "Current field constant limiter multiplier"
    Kc::Float64
    "Excitation control system stabilizer gain"
    Kf::Float64
    "Excitation control system stabilizer time constant"
    Tf::Float64
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed Terminal Voltage,
	Vrll: Lead-Lag state,
	Vr: Regulator Output, 
	Vfb: Feedback state"
    states::Vector{Symbol}
    "(**Do not modify.**) The EXST1 has 4 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function EXST1(Tr, Vi_lim, Tc, Tb, Ka, Ta, Vr_lim, Kc, Kf, Tf, V_ref=1.0, ext=Dict{String, Any}(), )
    EXST1(Tr, Vi_lim, Tc, Tb, Ka, Ta, Vr_lim, Kc, Kf, Tf, V_ref, ext, [:Vm, :Vrll, :Vr, :Vfb], 4, InfrastructureSystemsInternal(), )
end

function EXST1(; Tr, Vi_lim, Tc, Tb, Ka, Ta, Vr_lim, Kc, Kf, Tf, V_ref=1.0, ext=Dict{String, Any}(), states=[:Vm, :Vrll, :Vr, :Vfb], n_states=4, internal=InfrastructureSystemsInternal(), )
    EXST1(Tr, Vi_lim, Tc, Tb, Ka, Ta, Vr_lim, Kc, Kf, Tf, V_ref, ext, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function EXST1(::Nothing)
    EXST1(;
        Tr=0,
        Vi_lim=(min=0.0, max=0.0),
        Tc=0,
        Tb=0,
        Ka=0,
        Ta=0,
        Vr_lim=(min=0.0, max=0.0),
        Kc=0,
        Kf=0,
        Tf=0,
        V_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`EXST1`](@ref) `Tr`."""
get_Tr(value::EXST1) = value.Tr
"""Get [`EXST1`](@ref) `Vi_lim`."""
get_Vi_lim(value::EXST1) = value.Vi_lim
"""Get [`EXST1`](@ref) `Tc`."""
get_Tc(value::EXST1) = value.Tc
"""Get [`EXST1`](@ref) `Tb`."""
get_Tb(value::EXST1) = value.Tb
"""Get [`EXST1`](@ref) `Ka`."""
get_Ka(value::EXST1) = value.Ka
"""Get [`EXST1`](@ref) `Ta`."""
get_Ta(value::EXST1) = value.Ta
"""Get [`EXST1`](@ref) `Vr_lim`."""
get_Vr_lim(value::EXST1) = value.Vr_lim
"""Get [`EXST1`](@ref) `Kc`."""
get_Kc(value::EXST1) = value.Kc
"""Get [`EXST1`](@ref) `Kf`."""
get_Kf(value::EXST1) = value.Kf
"""Get [`EXST1`](@ref) `Tf`."""
get_Tf(value::EXST1) = value.Tf
"""Get [`EXST1`](@ref) `V_ref`."""
get_V_ref(value::EXST1) = value.V_ref
"""Get [`EXST1`](@ref) `ext`."""
get_ext(value::EXST1) = value.ext
"""Get [`EXST1`](@ref) `states`."""
get_states(value::EXST1) = value.states
"""Get [`EXST1`](@ref) `n_states`."""
get_n_states(value::EXST1) = value.n_states
"""Get [`EXST1`](@ref) `internal`."""
get_internal(value::EXST1) = value.internal

"""Set [`EXST1`](@ref) `Tr`."""
set_Tr!(value::EXST1, val) = value.Tr = val
"""Set [`EXST1`](@ref) `Vi_lim`."""
set_Vi_lim!(value::EXST1, val) = value.Vi_lim = val
"""Set [`EXST1`](@ref) `Tc`."""
set_Tc!(value::EXST1, val) = value.Tc = val
"""Set [`EXST1`](@ref) `Tb`."""
set_Tb!(value::EXST1, val) = value.Tb = val
"""Set [`EXST1`](@ref) `Ka`."""
set_Ka!(value::EXST1, val) = value.Ka = val
"""Set [`EXST1`](@ref) `Ta`."""
set_Ta!(value::EXST1, val) = value.Ta = val
"""Set [`EXST1`](@ref) `Vr_lim`."""
set_Vr_lim!(value::EXST1, val) = value.Vr_lim = val
"""Set [`EXST1`](@ref) `Kc`."""
set_Kc!(value::EXST1, val) = value.Kc = val
"""Set [`EXST1`](@ref) `Kf`."""
set_Kf!(value::EXST1, val) = value.Kf = val
"""Set [`EXST1`](@ref) `Tf`."""
set_Tf!(value::EXST1, val) = value.Tf = val
"""Set [`EXST1`](@ref) `V_ref`."""
set_V_ref!(value::EXST1, val) = value.V_ref = val
"""Set [`EXST1`](@ref) `ext`."""
set_ext!(value::EXST1, val) = value.ext = val



function from_openapi(po::PD.EXST1, refs::OpenAPIRefs)
    return EXST1(;
        Tr = _wire_required(po.tr, "EXST1", "Tr"),
        Vi_lim = _or_default(po.vi_lim, nothing),
        Tc = _wire_required(po.tc, "EXST1", "Tc"),
        Tb = _wire_required(po.tb, "EXST1", "Tb"),
        Ka = _wire_required(po.ka, "EXST1", "Ka"),
        Ta = _wire_required(po.ta, "EXST1", "Ta"),
        Vr_lim = _or_default(po.vr_lim, nothing),
        Kc = _wire_required(po.kc, "EXST1", "Kc"),
        Kf = _wire_required(po.kf, "EXST1", "Kf"),
        Tf = _wire_required(po.tf, "EXST1", "Tf"),
        V_ref = _or_default(po.v_ref, 1.0),
    )
end

function to_openapi(value::EXST1, refs::OpenAPIRefs)
    return PD.EXST1(;
        id = component_id(refs, value),
        tr = get_Tr(value),
        vi_lim = _minmax_po(get_Vi_lim(value)),
        tc = get_Tc(value),
        tb = get_Tb(value),
        ka = get_Ka(value),
        ta = get_Ta(value),
        vr_lim = _minmax_po(get_Vr_lim(value)),
        kc = get_Kc(value),
        kf = get_Kf(value),
        tf = get_Tf(value),
        v_ref = get_V_ref(value),
    )
end
