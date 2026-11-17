#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ReactivePowerPI <: ReactivePowerControl
        Kp_q::Float64
        Ki_q::Float64
        reactive_power_filter_frequency::Float64
        V_ref::Float64
        Q_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of a Proportional-Integral Reactive Power controller for a specified power reference

# Arguments
- `Kp_q::Float64`: Proportional Gain, validation range: `(0, nothing)`
- `Ki_q::Float64`: Integral Gain, validation range: `(0, nothing)`
- `reactive_power_filter_frequency::Float64`: Filter cutoff frequency, in natural units in Hz, validation range: `(0, nothing)`
- `V_ref::Float64`: (default: `1.0`) Voltage Set-point (pu), validation range: `(0, nothing)`
- `Q_ref::Float64`: (default: `1.0`) Reactive Power Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the ReactivePowerPI model are:
	σq_oc: Integrator state of the PI Controller,
	q_oc: Measured reactive power of the inverter model
- `n_states::Int`: (**Do not modify.**) ReactivePowerPI has two states
"""
mutable struct ReactivePowerPI <: ReactivePowerControl
    "Proportional Gain"
    Kp_q::Float64
    "Integral Gain"
    Ki_q::Float64
    "Filter cutoff frequency, in natural units in Hz"
    reactive_power_filter_frequency::Float64
    "Voltage Set-point (pu)"
    V_ref::Float64
    "Reactive Power Set-point (pu)"
    Q_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the ReactivePowerPI model are:
	σq_oc: Integrator state of the PI Controller,
	q_oc: Measured reactive power of the inverter model"
    states::Vector{Symbol}
    "(**Do not modify.**) ReactivePowerPI has two states"
    n_states::Int
end

function ReactivePowerPI(Kp_q, Ki_q, reactive_power_filter_frequency, V_ref=1.0, Q_ref=1.0, ext=Dict{String, Any}(), )
    ReactivePowerPI(Kp_q, Ki_q, reactive_power_filter_frequency, V_ref, Q_ref, ext, [:σq_oc, :q_oc], 2, )
end

function ReactivePowerPI(; Kp_q, Ki_q, reactive_power_filter_frequency, V_ref=1.0, Q_ref=1.0, ext=Dict{String, Any}(), states=[:σq_oc, :q_oc], n_states=2, )
    ReactivePowerPI(Kp_q, Ki_q, reactive_power_filter_frequency, V_ref, Q_ref, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function ReactivePowerPI(::Nothing)
    ReactivePowerPI(;
        Kp_q=0,
        Ki_q=0,
        reactive_power_filter_frequency=0,
        V_ref=0,
        Q_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ReactivePowerPI`](@ref) `Kp_q`."""
get_Kp_q(value::ReactivePowerPI) = value.Kp_q
"""Get [`ReactivePowerPI`](@ref) `Ki_q`."""
get_Ki_q(value::ReactivePowerPI) = value.Ki_q
"""Get [`ReactivePowerPI`](@ref) `reactive_power_filter_frequency`."""
get_reactive_power_filter_frequency(value::ReactivePowerPI) = value.reactive_power_filter_frequency
"""Get [`ReactivePowerPI`](@ref) `V_ref`."""
get_V_ref(value::ReactivePowerPI) = value.V_ref
"""Get [`ReactivePowerPI`](@ref) `Q_ref`."""
get_Q_ref(value::ReactivePowerPI) = value.Q_ref
"""Get [`ReactivePowerPI`](@ref) `ext`."""
get_ext(value::ReactivePowerPI) = value.ext
"""Get [`ReactivePowerPI`](@ref) `states`."""
get_states(value::ReactivePowerPI) = value.states
"""Get [`ReactivePowerPI`](@ref) `n_states`."""
get_n_states(value::ReactivePowerPI) = value.n_states

"""Set [`ReactivePowerPI`](@ref) `Kp_q`."""
set_Kp_q!(value::ReactivePowerPI, val) = value.Kp_q = val
"""Set [`ReactivePowerPI`](@ref) `Ki_q`."""
set_Ki_q!(value::ReactivePowerPI, val) = value.Ki_q = val
"""Set [`ReactivePowerPI`](@ref) `reactive_power_filter_frequency`."""
set_reactive_power_filter_frequency!(value::ReactivePowerPI, val) = value.reactive_power_filter_frequency = val
"""Set [`ReactivePowerPI`](@ref) `V_ref`."""
set_V_ref!(value::ReactivePowerPI, val) = value.V_ref = val
"""Set [`ReactivePowerPI`](@ref) `Q_ref`."""
set_Q_ref!(value::ReactivePowerPI, val) = value.Q_ref = val
"""Set [`ReactivePowerPI`](@ref) `ext`."""
set_ext!(value::ReactivePowerPI, val) = value.ext = val



function from_openapi(po::PD.ReactivePowerPI, refs::OpenAPIRefs)
    return ReactivePowerPI(;
        Kp_q = _wire_required(po.kp_q, "ReactivePowerPI", "Kp_q"),
        Ki_q = _wire_required(po.ki_q, "ReactivePowerPI", "Ki_q"),
        reactive_power_filter_frequency = _wire_required(po.reactive_power_filter_frequency, "ReactivePowerPI", "reactive_power_filter_frequency"),
        V_ref = _or_default(po.v_ref, 1.0),
        Q_ref = _or_default(po.q_ref, 1.0),
    )
end

function to_openapi(value::ReactivePowerPI, refs::OpenAPIRefs)
    return PD.ReactivePowerPI(;
        id = component_id(refs, value),
        kp_q = get_Kp_q(value),
        ki_q = get_Ki_q(value),
        reactive_power_filter_frequency = get_reactive_power_filter_frequency(value),
        v_ref = get_V_ref(value),
        q_ref = get_Q_ref(value),
    )
end
