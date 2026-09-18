#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct AVRFixed <: AVR
        Vf::Float64
        V_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

Parameters of a AVR that returns a fixed voltage to the rotor winding

# Arguments
- `Vf::Float64`: Fixed voltage field applied to the rotor winding in pu ([`DEVICE_BASE`](@ref per_unit)), validation range: `(0, nothing)`
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) Fixed AVR has no [states](@ref S)
- `n_states::Int`: (**Do not modify.**) Fixed AVR has no [states](@ref S)
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) Fixed AVR has no [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct AVRFixed <: AVR
    "Fixed voltage field applied to the rotor winding in pu ([`DEVICE_BASE`](@ref per_unit))"
    Vf::Float64
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) Fixed AVR has no [states](@ref S)"
    states::Vector{Symbol}
    "(**Do not modify.**) Fixed AVR has no [states](@ref S)"
    n_states::Int
    "(**Do not modify.**) Fixed AVR has no [states](@ref S)"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function AVRFixed(Vf, V_ref=1.0, ext=Dict{String, Any}(), )
    AVRFixed(Vf, V_ref, ext, Vector{Symbol}(), 0, Vector{StateTypes.Value}(), InfrastructureSystemsInternal(), )
end

function AVRFixed(; Vf, V_ref=1.0, ext=Dict{String, Any}(), states=Vector{Symbol}(), n_states=0, states_types=Vector{StateTypes.Value}(), internal=InfrastructureSystemsInternal(), )
    AVRFixed(Vf, V_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function AVRFixed(::Nothing)
    AVRFixed(;
        Vf=0,
        V_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`AVRFixed`](@ref) `Vf`."""
get_Vf(value::AVRFixed) = value.Vf
"""Get [`AVRFixed`](@ref) `V_ref`."""
get_V_ref(value::AVRFixed) = value.V_ref
"""Get [`AVRFixed`](@ref) `ext`."""
get_ext(value::AVRFixed) = value.ext
"""Get [`AVRFixed`](@ref) `states`."""
get_states(value::AVRFixed) = value.states
"""Get [`AVRFixed`](@ref) `n_states`."""
get_n_states(value::AVRFixed) = value.n_states
"""Get [`AVRFixed`](@ref) `states_types`."""
get_states_types(value::AVRFixed) = value.states_types
"""Get [`AVRFixed`](@ref) `internal`."""
get_internal(value::AVRFixed) = value.internal

"""Set [`AVRFixed`](@ref) `Vf`."""
set_Vf!(value::AVRFixed, val) = value.Vf = val
"""Set [`AVRFixed`](@ref) `V_ref`."""
set_V_ref!(value::AVRFixed, val) = value.V_ref = val
"""Set [`AVRFixed`](@ref) `ext`."""
set_ext!(value::AVRFixed, val) = value.ext = val
"""Set [`AVRFixed`](@ref) `states_types`."""
set_states_types!(value::AVRFixed, val) = value.states_types = val
