#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct KauraPLL <: ReferenceFrameRotation
        frequency_lp::Float64
        kp_pll::Float64
        ki_pll::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of a Phase-Locked Loop (PLL) based on ["Operation of a phase locked loop system under distorted utility conditions"](https://doi.org/10.1109/28.567077) by Vikram Kaura, and Vladimir Blasko

# Arguments
- `frequency_lp::Float64`: PLL low-pass filter cutoff frequency, in natural units in Hz, validation range: `(0, nothing)`
- `kp_pll::Float64`: PLL proportional gain, validation range: `(0, nothing)`
- `ki_pll::Float64`: PLL integral gain, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the KauraPLL model are:
	vd_pll: d-axis of the measured voltage in the PLL synchronous reference frame (SRF),
	vq_pll: q-axis of the measured voltage in the PLL SRF,
	ε_pll: Integrator state of the PI controller,
	θ_pll: Phase angle displacement in the PLL SRF
- `n_states::Int`: (**Do not modify.**) KauraPLL has 4 states
"""
mutable struct KauraPLL <: ReferenceFrameRotation
    "PLL low-pass filter cutoff frequency, in natural units in Hz"
    frequency_lp::Float64
    "PLL proportional gain"
    kp_pll::Float64
    "PLL integral gain"
    ki_pll::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the KauraPLL model are:
	vd_pll: d-axis of the measured voltage in the PLL synchronous reference frame (SRF),
	vq_pll: q-axis of the measured voltage in the PLL SRF,
	ε_pll: Integrator state of the PI controller,
	θ_pll: Phase angle displacement in the PLL SRF"
    states::Vector{Symbol}
    "(**Do not modify.**) KauraPLL has 4 states"
    n_states::Int
end

function KauraPLL(frequency_lp, kp_pll, ki_pll, ext=Dict{String, Any}(), )
    KauraPLL(frequency_lp, kp_pll, ki_pll, ext, [:vd_pll, :vq_pll, :ε_pll, :θ_pll], 4, )
end

function KauraPLL(; frequency_lp, kp_pll, ki_pll, ext=Dict{String, Any}(), states=[:vd_pll, :vq_pll, :ε_pll, :θ_pll], n_states=4, )
    KauraPLL(frequency_lp, kp_pll, ki_pll, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function KauraPLL(::Nothing)
    KauraPLL(;
        frequency_lp=0,
        kp_pll=0,
        ki_pll=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`KauraPLL`](@ref) `frequency_lp`."""
get_frequency_lp(value::KauraPLL) = value.frequency_lp
"""Get [`KauraPLL`](@ref) `kp_pll`."""
get_kp_pll(value::KauraPLL) = value.kp_pll
"""Get [`KauraPLL`](@ref) `ki_pll`."""
get_ki_pll(value::KauraPLL) = value.ki_pll
"""Get [`KauraPLL`](@ref) `ext`."""
get_ext(value::KauraPLL) = value.ext
"""Get [`KauraPLL`](@ref) `states`."""
get_states(value::KauraPLL) = value.states
"""Get [`KauraPLL`](@ref) `n_states`."""
get_n_states(value::KauraPLL) = value.n_states

"""Set [`KauraPLL`](@ref) `frequency_lp`."""
set_frequency_lp!(value::KauraPLL, val) = value.frequency_lp = val
"""Set [`KauraPLL`](@ref) `kp_pll`."""
set_kp_pll!(value::KauraPLL, val) = value.kp_pll = val
"""Set [`KauraPLL`](@ref) `ki_pll`."""
set_ki_pll!(value::KauraPLL, val) = value.ki_pll = val
"""Set [`KauraPLL`](@ref) `ext`."""
set_ext!(value::KauraPLL, val) = value.ext = val



function from_openapi(po::PD.KauraPLL, refs::OpenAPIRefs)
    return KauraPLL(;
        frequency_lp = _wire_required(po.frequency_lp, "KauraPLL", "frequency_lp"),
        kp_pll = _wire_required(po.kp_pll, "KauraPLL", "kp_pll"),
        ki_pll = _wire_required(po.ki_pll, "KauraPLL", "ki_pll"),
    )
end

function to_openapi(value::KauraPLL, refs::OpenAPIRefs)
    return PD.KauraPLL(;
        id = component_id(refs, value),
        frequency_lp = get_frequency_lp(value),
        kp_pll = get_kp_pll(value),
        ki_pll = get_ki_pll(value),
    )
end
