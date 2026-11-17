#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ActivePowerDroop <: ActivePowerControl
        Rp::Float64
        active_power_filter_frequency::Float64
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of an Active Power droop controller

# Arguments
- `Rp::Float64`: Droop Gain, validation range: `(0, nothing)`
- `active_power_filter_frequency::Float64`: Filter cutoff frequency, in natural units in Hz, validation range: `(0, nothing)`
- `P_ref::Float64`: (default: `1.0`) Reference Power Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the ActivePowerDroop model are:
	θ_oc: Phase angle displacement of the inverter model,
	p_oc: Measured active power of the inverter model
- `n_states::Int`: (**Do not modify.**) ActivePowerDroop has two states
"""
mutable struct ActivePowerDroop <: ActivePowerControl
    "Droop Gain"
    Rp::Float64
    "Filter cutoff frequency, in natural units in Hz"
    active_power_filter_frequency::Float64
    "Reference Power Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the ActivePowerDroop model are:
	θ_oc: Phase angle displacement of the inverter model,
	p_oc: Measured active power of the inverter model"
    states::Vector{Symbol}
    "(**Do not modify.**) ActivePowerDroop has two states"
    n_states::Int
end

function ActivePowerDroop(Rp, active_power_filter_frequency, P_ref=1.0, ext=Dict{String, Any}(), )
    ActivePowerDroop(Rp, active_power_filter_frequency, P_ref, ext, [:θ_oc, :p_oc], 2, )
end

function ActivePowerDroop(; Rp, active_power_filter_frequency, P_ref=1.0, ext=Dict{String, Any}(), states=[:θ_oc, :p_oc], n_states=2, )
    ActivePowerDroop(Rp, active_power_filter_frequency, P_ref, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function ActivePowerDroop(::Nothing)
    ActivePowerDroop(;
        Rp=0,
        active_power_filter_frequency=0,
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ActivePowerDroop`](@ref) `Rp`."""
get_Rp(value::ActivePowerDroop) = value.Rp
"""Get [`ActivePowerDroop`](@ref) `active_power_filter_frequency`."""
get_active_power_filter_frequency(value::ActivePowerDroop) = value.active_power_filter_frequency
"""Get [`ActivePowerDroop`](@ref) `P_ref`."""
get_P_ref(value::ActivePowerDroop) = value.P_ref
"""Get [`ActivePowerDroop`](@ref) `ext`."""
get_ext(value::ActivePowerDroop) = value.ext
"""Get [`ActivePowerDroop`](@ref) `states`."""
get_states(value::ActivePowerDroop) = value.states
"""Get [`ActivePowerDroop`](@ref) `n_states`."""
get_n_states(value::ActivePowerDroop) = value.n_states

"""Set [`ActivePowerDroop`](@ref) `Rp`."""
set_Rp!(value::ActivePowerDroop, val) = value.Rp = val
"""Set [`ActivePowerDroop`](@ref) `active_power_filter_frequency`."""
set_active_power_filter_frequency!(value::ActivePowerDroop, val) = value.active_power_filter_frequency = val
"""Set [`ActivePowerDroop`](@ref) `P_ref`."""
set_P_ref!(value::ActivePowerDroop, val) = value.P_ref = val
"""Set [`ActivePowerDroop`](@ref) `ext`."""
set_ext!(value::ActivePowerDroop, val) = value.ext = val



function from_openapi(po::PD.ActivePowerDroop, refs::OpenAPIRefs)
    return ActivePowerDroop(;
        Rp = _wire_required(po.rp, "ActivePowerDroop", "Rp"),
        active_power_filter_frequency = _wire_required(po.active_power_filter_frequency, "ActivePowerDroop", "active_power_filter_frequency"),
        P_ref = _or_default(po.p_ref, 1.0),
    )
end

function to_openapi(value::ActivePowerDroop, refs::OpenAPIRefs)
    return PD.ActivePowerDroop(;
        id = component_id(refs, value),
        rp = get_Rp(value),
        active_power_filter_frequency = get_active_power_filter_frequency(value),
        p_ref = get_P_ref(value),
    )
end
