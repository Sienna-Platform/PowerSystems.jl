#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ReducedOrderPLL <: ReferenceFrameRotation
        frequency_lp::Float64
        kp_pll::Float64
        ki_pll::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of a Phase-Locked Loop (PLL) based on ["Reduced-order Structure-preserving Model for Parallel-connected Three-phase Grid-tied Inverters."](https://doi.org/10.1109/COMPEL.2017.8013389)

# Arguments
- `frequency_lp::Float64`: PLL low-pass filter cutoff frequency, in natural units in Hz, validation range: `(0, nothing)`
- `kp_pll::Float64`: PLL proportional gain, validation range: `(0, nothing)`
- `ki_pll::Float64`: PLL integral gain, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the ReducedOrderPLL model are:
	vq_pll: q-axis of the measured voltage in the PLL synchronous reference frame (SRF),
	ε_pll: Integrator state of the PI controller,
	θ_pll: Phase angle displacement in the PLL SRF
- `n_states::Int`: (**Do not modify.**) ReducedOrderPLL has 3 states
"""
mutable struct ReducedOrderPLL <: ReferenceFrameRotation
    "PLL low-pass filter cutoff frequency, in natural units in Hz"
    frequency_lp::Float64
    "PLL proportional gain"
    kp_pll::Float64
    "PLL integral gain"
    ki_pll::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the ReducedOrderPLL model are:
	vq_pll: q-axis of the measured voltage in the PLL synchronous reference frame (SRF),
	ε_pll: Integrator state of the PI controller,
	θ_pll: Phase angle displacement in the PLL SRF"
    states::Vector{Symbol}
    "(**Do not modify.**) ReducedOrderPLL has 3 states"
    n_states::Int
end

function ReducedOrderPLL(frequency_lp, kp_pll, ki_pll, ext=Dict{String, Any}(), )
    ReducedOrderPLL(frequency_lp, kp_pll, ki_pll, ext, [:vq_pll, :ε_pll, :θ_pll], 3, )
end

function ReducedOrderPLL(; frequency_lp, kp_pll, ki_pll, ext=Dict{String, Any}(), states=[:vq_pll, :ε_pll, :θ_pll], n_states=3, )
    ReducedOrderPLL(frequency_lp, kp_pll, ki_pll, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function ReducedOrderPLL(::Nothing)
    ReducedOrderPLL(;
        frequency_lp=0,
        kp_pll=0,
        ki_pll=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ReducedOrderPLL`](@ref) `frequency_lp`."""
get_frequency_lp(value::ReducedOrderPLL) = value.frequency_lp
"""Get [`ReducedOrderPLL`](@ref) `kp_pll`."""
get_kp_pll(value::ReducedOrderPLL) = value.kp_pll
"""Get [`ReducedOrderPLL`](@ref) `ki_pll`."""
get_ki_pll(value::ReducedOrderPLL) = value.ki_pll
"""Get [`ReducedOrderPLL`](@ref) `ext`."""
get_ext(value::ReducedOrderPLL) = value.ext
"""Get [`ReducedOrderPLL`](@ref) `states`."""
get_states(value::ReducedOrderPLL) = value.states
"""Get [`ReducedOrderPLL`](@ref) `n_states`."""
get_n_states(value::ReducedOrderPLL) = value.n_states

"""Set [`ReducedOrderPLL`](@ref) `frequency_lp`."""
set_frequency_lp!(value::ReducedOrderPLL, val) = value.frequency_lp = val
"""Set [`ReducedOrderPLL`](@ref) `kp_pll`."""
set_kp_pll!(value::ReducedOrderPLL, val) = value.kp_pll = val
"""Set [`ReducedOrderPLL`](@ref) `ki_pll`."""
set_ki_pll!(value::ReducedOrderPLL, val) = value.ki_pll = val
"""Set [`ReducedOrderPLL`](@ref) `ext`."""
set_ext!(value::ReducedOrderPLL, val) = value.ext = val



function from_openapi(po::PD.ReducedOrderPLL, refs::OpenAPIRefs)
    return ReducedOrderPLL(;
        frequency_lp = _wire_required(po.frequency_lp, "ReducedOrderPLL", "frequency_lp"),
        kp_pll = _wire_required(po.kp_pll, "ReducedOrderPLL", "kp_pll"),
        ki_pll = _wire_required(po.ki_pll, "ReducedOrderPLL", "ki_pll"),
    )
end

function to_openapi(value::ReducedOrderPLL, refs::OpenAPIRefs)
    return PD.ReducedOrderPLL(;
        id = component_id(refs, value),
        frequency_lp = get_frequency_lp(value),
        kp_pll = get_kp_pll(value),
        ki_pll = get_ki_pll(value),
    )
end
