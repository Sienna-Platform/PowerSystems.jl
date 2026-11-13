#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ActiveVirtualOscillator <: ActivePowerControl
        k1::Float64
        psi::Float64
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of an Active Virtual Oscillator controller. Model is based on ["Model Reduction for Inverters with Current Limiting and Dispatchable Virtual Oscillator Control."](https://doi.org/10.1109/TEC.2021.3083488)

# Arguments
- `k1::Float64`: VOC Synchronization Gain, validation range: `(0, nothing)`
- `psi::Float64`: Rotation angle of the controller, validation range: `(0, nothing)`
- `P_ref::Float64`: (default: `1.0`) Reference Power Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the ActiveVirtualOscillator model are:
	θ_oc: Phase angle displacement of the inverter model
- `n_states::Int`: (**Do not modify.**) ActiveVirtualOscillator has one state
"""
mutable struct ActiveVirtualOscillator <: ActivePowerControl
    "VOC Synchronization Gain"
    k1::Float64
    "Rotation angle of the controller"
    psi::Float64
    "Reference Power Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the ActiveVirtualOscillator model are:
	θ_oc: Phase angle displacement of the inverter model"
    states::Vector{Symbol}
    "(**Do not modify.**) ActiveVirtualOscillator has one state"
    n_states::Int
end

function ActiveVirtualOscillator(k1, psi, P_ref=1.0, ext=Dict{String, Any}(), )
    ActiveVirtualOscillator(k1, psi, P_ref, ext, [:θ_oc], 1, )
end

function ActiveVirtualOscillator(; k1, psi, P_ref=1.0, ext=Dict{String, Any}(), states=[:θ_oc], n_states=1, )
    ActiveVirtualOscillator(k1, psi, P_ref, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function ActiveVirtualOscillator(::Nothing)
    ActiveVirtualOscillator(;
        k1=0,
        psi=0,
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ActiveVirtualOscillator`](@ref) `k1`."""
get_k1(value::ActiveVirtualOscillator) = value.k1
"""Get [`ActiveVirtualOscillator`](@ref) `psi`."""
get_psi(value::ActiveVirtualOscillator) = value.psi
"""Get [`ActiveVirtualOscillator`](@ref) `P_ref`."""
get_P_ref(value::ActiveVirtualOscillator) = value.P_ref
"""Get [`ActiveVirtualOscillator`](@ref) `ext`."""
get_ext(value::ActiveVirtualOscillator) = value.ext
"""Get [`ActiveVirtualOscillator`](@ref) `states`."""
get_states(value::ActiveVirtualOscillator) = value.states
"""Get [`ActiveVirtualOscillator`](@ref) `n_states`."""
get_n_states(value::ActiveVirtualOscillator) = value.n_states

"""Set [`ActiveVirtualOscillator`](@ref) `k1`."""
set_k1!(value::ActiveVirtualOscillator, val) = value.k1 = val
"""Set [`ActiveVirtualOscillator`](@ref) `psi`."""
set_psi!(value::ActiveVirtualOscillator, val) = value.psi = val
"""Set [`ActiveVirtualOscillator`](@ref) `P_ref`."""
set_P_ref!(value::ActiveVirtualOscillator, val) = value.P_ref = val
"""Set [`ActiveVirtualOscillator`](@ref) `ext`."""
set_ext!(value::ActiveVirtualOscillator, val) = value.ext = val



function from_openapi(po::PD.ActiveVirtualOscillator, refs::OpenAPIRefs)
    return ActiveVirtualOscillator(;
        k1 = _wire_required(po.k1, "ActiveVirtualOscillator", "k1"),
        psi = _wire_required(po.psi, "ActiveVirtualOscillator", "psi"),
        P_ref = _or_default(po.p_ref, 1.0),
    )
end

function to_openapi(value::ActiveVirtualOscillator, refs::OpenAPIRefs)
    return PD.ActiveVirtualOscillator(;
        id = component_id(refs, value),
        k1 = get_k1(value),
        psi = get_psi(value),
        p_ref = get_P_ref(value),
    )
end
