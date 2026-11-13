#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ReactivePowerDroop <: ReactivePowerControl
        kq::Float64
        reactive_power_filter_frequency::Float64
        V_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of a Reactive Power droop controller

# Arguments
- `kq::Float64`: frequency droop gain, validation range: `(0, nothing)`
- `reactive_power_filter_frequency::Float64`: Filter cutoff frequency, in natural units in Hz, validation range: `(0, nothing)`
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the ReactivePowerDroop model are:
	q_oc: Filtered reactive output power
- `n_states::Int`: (**Do not modify.**) ReactivePowerDroop has 1 state
"""
mutable struct ReactivePowerDroop <: ReactivePowerControl
    "frequency droop gain"
    kq::Float64
    "Filter cutoff frequency, in natural units in Hz"
    reactive_power_filter_frequency::Float64
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the ReactivePowerDroop model are:
	q_oc: Filtered reactive output power"
    states::Vector{Symbol}
    "(**Do not modify.**) ReactivePowerDroop has 1 state"
    n_states::Int
end

function ReactivePowerDroop(kq, reactive_power_filter_frequency, V_ref=1.0, ext=Dict{String, Any}(), )
    ReactivePowerDroop(kq, reactive_power_filter_frequency, V_ref, ext, [:q_oc], 1, )
end

function ReactivePowerDroop(; kq, reactive_power_filter_frequency, V_ref=1.0, ext=Dict{String, Any}(), states=[:q_oc], n_states=1, )
    ReactivePowerDroop(kq, reactive_power_filter_frequency, V_ref, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function ReactivePowerDroop(::Nothing)
    ReactivePowerDroop(;
        kq=0,
        reactive_power_filter_frequency=0,
        V_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ReactivePowerDroop`](@ref) `kq`."""
get_kq(value::ReactivePowerDroop) = value.kq
"""Get [`ReactivePowerDroop`](@ref) `reactive_power_filter_frequency`."""
get_reactive_power_filter_frequency(value::ReactivePowerDroop) = value.reactive_power_filter_frequency
"""Get [`ReactivePowerDroop`](@ref) `V_ref`."""
get_V_ref(value::ReactivePowerDroop) = value.V_ref
"""Get [`ReactivePowerDroop`](@ref) `ext`."""
get_ext(value::ReactivePowerDroop) = value.ext
"""Get [`ReactivePowerDroop`](@ref) `states`."""
get_states(value::ReactivePowerDroop) = value.states
"""Get [`ReactivePowerDroop`](@ref) `n_states`."""
get_n_states(value::ReactivePowerDroop) = value.n_states

"""Set [`ReactivePowerDroop`](@ref) `kq`."""
set_kq!(value::ReactivePowerDroop, val) = value.kq = val
"""Set [`ReactivePowerDroop`](@ref) `reactive_power_filter_frequency`."""
set_reactive_power_filter_frequency!(value::ReactivePowerDroop, val) = value.reactive_power_filter_frequency = val
"""Set [`ReactivePowerDroop`](@ref) `V_ref`."""
set_V_ref!(value::ReactivePowerDroop, val) = value.V_ref = val
"""Set [`ReactivePowerDroop`](@ref) `ext`."""
set_ext!(value::ReactivePowerDroop, val) = value.ext = val



function from_openapi(po::PD.ReactivePowerDroop, refs::OpenAPIRefs)
    return ReactivePowerDroop(;
        kq = _wire_required(po.kq, "ReactivePowerDroop", "kq"),
        reactive_power_filter_frequency = _wire_required(po.reactive_power_filter_frequency, "ReactivePowerDroop", "reactive_power_filter_frequency"),
        V_ref = _or_default(po.v_ref, 1.0),
    )
end

function to_openapi(value::ReactivePowerDroop, refs::OpenAPIRefs)
    return PD.ReactivePowerDroop(;
        id = component_id(refs, value),
        kq = get_kq(value),
        reactive_power_filter_frequency = get_reactive_power_filter_frequency(value),
        v_ref = get_V_ref(value),
    )
end
