#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ActivePowerPI <: ActivePowerControl
        Kp_p::Float64
        Ki_p::Float64
        active_power_filter_frequency::Float64
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of a Proportional-Integral Active Power controller for a specified power reference

# Arguments
- `Kp_p::Float64`: Proportional Gain, validation range: `(0, nothing)`
- `Ki_p::Float64`: Integral Gain, validation range: `(0, nothing)`
- `active_power_filter_frequency::Float64`: Filter cutoff frequency, in natural units in Hz, validation range: `(0, nothing)`
- `P_ref::Float64`: (default: `1.0`) Reference Power Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the ActivePowerPI model are:
	σp_oc: Integrator state of the PI Controller,
	p_oc: Measured active power of the inverter model
- `n_states::Int`: (**Do not modify.**) ActivePowerPI has two states
"""
mutable struct ActivePowerPI <: ActivePowerControl
    "Proportional Gain"
    Kp_p::Float64
    "Integral Gain"
    Ki_p::Float64
    "Filter cutoff frequency, in natural units in Hz"
    active_power_filter_frequency::Float64
    "Reference Power Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the ActivePowerPI model are:
	σp_oc: Integrator state of the PI Controller,
	p_oc: Measured active power of the inverter model"
    states::Vector{Symbol}
    "(**Do not modify.**) ActivePowerPI has two states"
    n_states::Int
end

function ActivePowerPI(Kp_p, Ki_p, active_power_filter_frequency, P_ref=1.0, ext=Dict{String, Any}(), )
    ActivePowerPI(Kp_p, Ki_p, active_power_filter_frequency, P_ref, ext, [:σp_oc, :p_oc], 2, )
end

function ActivePowerPI(; Kp_p, Ki_p, active_power_filter_frequency, P_ref=1.0, ext=Dict{String, Any}(), states=[:σp_oc, :p_oc], n_states=2, )
    ActivePowerPI(Kp_p, Ki_p, active_power_filter_frequency, P_ref, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function ActivePowerPI(::Nothing)
    ActivePowerPI(;
        Kp_p=0,
        Ki_p=0,
        active_power_filter_frequency=0,
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ActivePowerPI`](@ref) `Kp_p`."""
get_Kp_p(value::ActivePowerPI) = value.Kp_p
"""Get [`ActivePowerPI`](@ref) `Ki_p`."""
get_Ki_p(value::ActivePowerPI) = value.Ki_p
"""Get [`ActivePowerPI`](@ref) `active_power_filter_frequency`."""
get_active_power_filter_frequency(value::ActivePowerPI) = value.active_power_filter_frequency
"""Get [`ActivePowerPI`](@ref) `P_ref`."""
get_P_ref(value::ActivePowerPI) = value.P_ref
"""Get [`ActivePowerPI`](@ref) `ext`."""
get_ext(value::ActivePowerPI) = value.ext
"""Get [`ActivePowerPI`](@ref) `states`."""
get_states(value::ActivePowerPI) = value.states
"""Get [`ActivePowerPI`](@ref) `n_states`."""
get_n_states(value::ActivePowerPI) = value.n_states

"""Set [`ActivePowerPI`](@ref) `Kp_p`."""
set_Kp_p!(value::ActivePowerPI, val) = value.Kp_p = val
"""Set [`ActivePowerPI`](@ref) `Ki_p`."""
set_Ki_p!(value::ActivePowerPI, val) = value.Ki_p = val
"""Set [`ActivePowerPI`](@ref) `active_power_filter_frequency`."""
set_active_power_filter_frequency!(value::ActivePowerPI, val) = value.active_power_filter_frequency = val
"""Set [`ActivePowerPI`](@ref) `P_ref`."""
set_P_ref!(value::ActivePowerPI, val) = value.P_ref = val
"""Set [`ActivePowerPI`](@ref) `ext`."""
set_ext!(value::ActivePowerPI, val) = value.ext = val



function from_openapi(po::PD.ActivePowerPI, refs::OpenAPIRefs)
    return ActivePowerPI(;
        Kp_p = _wire_required(po.kp_p, "ActivePowerPI", "Kp_p"),
        Ki_p = _wire_required(po.ki_p, "ActivePowerPI", "Ki_p"),
        active_power_filter_frequency = _wire_required(po.active_power_filter_frequency, "ActivePowerPI", "active_power_filter_frequency"),
        P_ref = _or_default(po.p_ref, 1.0),
    )
end

function to_openapi(value::ActivePowerPI, refs::OpenAPIRefs)
    return PD.ActivePowerPI(;
        id = component_id(refs, value),
        kp_p = get_Kp_p(value),
        ki_p = get_Ki_p(value),
        active_power_filter_frequency = get_active_power_filter_frequency(value),
        p_ref = get_P_ref(value),
    )
end
