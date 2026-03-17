"""
    mutable struct OuterControl{
        A <: ActivePowerControl,
        R <: ReactivePowerControl
    } <: DynamicInverterComponent
        active_power_control::A
        reactive_power_control::R
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end
Parameters of a Outer-Loop controller using a active power controller and a reactive power droop controller.

# Arguments
$(TYPEDFIELDS)
"""
mutable struct OuterControl{A <: ActivePowerControl, R <: ReactivePowerControl} <:
               DynamicInverterComponent
    "Active power controller (a subtype of [`ActivePowerControl`](@ref), typically droop or virtual inertia)"
    active_power_control::A
    "Reactive power controller (a subtype of [`ReactivePowerControl`](@ref), typically droop)"
    reactive_power_control::R
    "(optional) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation"
    ext::Dict{String, Any}
    "(**Do not modify.**) Vector of states (will depend on the active and reactive power control components)"
    states::Vector{Symbol}
    "(**Do not modify.**) Number of states (will depend on the active and reactive power control components)"
    n_states::Int
end

function OuterControl(
    active_power_control::A,
    reactive_power_control::R,
    ext = Dict{String, Any}(),
) where {A <: ActivePowerControl, R <: ReactivePowerControl}
    return OuterControl(
        active_power_control,
        reactive_power_control,
        ext,
        vcat(active_power_control.states, reactive_power_control.states),
        active_power_control.n_states + reactive_power_control.n_states,
    )
end

function OuterControl(;
    active_power_control,
    reactive_power_control,
    ext = Dict{String, Any}(),
    states = nothing,
    n_states = nothing,
)
    if states === nothing
        @assert n_states === nothing
        return OuterControl(active_power_control, reactive_power_control, ext)
    end
    @assert n_states !== nothing
    return OuterControl(active_power_control, reactive_power_control, ext, states, n_states)
end

"""Get `active_power_control` from [`OuterControl`](@ref)."""
get_active_power_control(value::OuterControl) = value.active_power_control
"""Get `reactive_power_control` from [`OuterControl`](@ref)."""
get_reactive_power_control(value::OuterControl) = value.reactive_power_control
"""Get `ext` from [`OuterControl`](@ref)."""
get_ext(value::OuterControl) = value.ext
"""Get `states` from [`OuterControl`](@ref)."""
get_states(value::OuterControl) = value.states
"""Get `n_states` from [`OuterControl`](@ref)."""
get_n_states(value::OuterControl) = value.n_states
"""Set [`OuterControl`](@ref) `active_power_control`."""
set_active_power_control!(value::OuterControl, val) =
    value.active_power_control = val
"""Set [`OuterControl`](@ref) `reactive_power_control`."""
set_reactive_power_control!(value::OuterControl, val) =
    value.reactive_power_control = val
"""Set [`OuterControl`](@ref) `ext`."""
set_ext!(value::OuterControl, val) = value.ext = val
