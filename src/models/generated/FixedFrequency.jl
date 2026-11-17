#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct FixedFrequency <: ReferenceFrameRotation
        frequency::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of a Fixed Frequency Estimator (i.e. no PLL)

# Arguments
- `frequency::Float64`: (default: `1.0`) Reference Frequency (pu)
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) FixedFrequency has no [states](@ref S)
- `n_states::Int`: (**Do not modify.**) FixedFrequency has no states
"""
mutable struct FixedFrequency <: ReferenceFrameRotation
    "Reference Frequency (pu)"
    frequency::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) FixedFrequency has no [states](@ref S)"
    states::Vector{Symbol}
    "(**Do not modify.**) FixedFrequency has no states"
    n_states::Int
end


function FixedFrequency(; frequency=1.0, ext=Dict{String, Any}(), states=Vector{Symbol}(), n_states=0, )
    FixedFrequency(frequency, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function FixedFrequency(::Nothing)
    FixedFrequency(;
        frequency=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`FixedFrequency`](@ref) `frequency`."""
get_frequency(value::FixedFrequency) = value.frequency
"""Get [`FixedFrequency`](@ref) `ext`."""
get_ext(value::FixedFrequency) = value.ext
"""Get [`FixedFrequency`](@ref) `states`."""
get_states(value::FixedFrequency) = value.states
"""Get [`FixedFrequency`](@ref) `n_states`."""
get_n_states(value::FixedFrequency) = value.n_states

"""Set [`FixedFrequency`](@ref) `frequency`."""
set_frequency!(value::FixedFrequency, val) = value.frequency = val
"""Set [`FixedFrequency`](@ref) `ext`."""
set_ext!(value::FixedFrequency, val) = value.ext = val



function from_openapi(po::PD.FixedFrequency, refs::OpenAPIRefs)
    return FixedFrequency(;
        frequency = _or_default(po.frequency, 1.0),
    )
end

function to_openapi(value::FixedFrequency, refs::OpenAPIRefs)
    return PD.FixedFrequency(;
        id = component_id(refs, value),
        frequency = get_frequency(value),
    )
end
