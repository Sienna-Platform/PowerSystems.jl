#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct PriorityOutputCurrentLimiter <: CurrentLimitation
        I_max::Float64
        phi_I::Float64
        ext::Dict{String, Any}
    end

Parameters of Priority-Based Current Controller Limiter. Regulates the magnitude of the inverter output current and prioritizes a specific angle for the resultant current signal

# Arguments
- `I_max::Float64`: Maximum limit on current controller input current in pu ([`DEVICE_BASE`](@ref per_unit)), validation range: `(0, nothing)`
- `phi_I::Float64`: Pre-defined angle (measured against the d-axis) for I_ref once limit I_max is hit, validation range: `(-1.571, 1.571)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
"""
mutable struct PriorityOutputCurrentLimiter <: CurrentLimitation
    "Maximum limit on current controller input current in pu ([`DEVICE_BASE`](@ref per_unit))"
    I_max::Float64
    "Pre-defined angle (measured against the d-axis) for I_ref once limit I_max is hit"
    phi_I::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
end


function PriorityOutputCurrentLimiter(; I_max, phi_I, ext=Dict{String, Any}(), )
    PriorityOutputCurrentLimiter(I_max, phi_I, ext, )
end

# Constructor for demo purposes; non-functional.
function PriorityOutputCurrentLimiter(::Nothing)
    PriorityOutputCurrentLimiter(;
        I_max=0,
        phi_I=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`PriorityOutputCurrentLimiter`](@ref) `I_max`."""
get_I_max(value::PriorityOutputCurrentLimiter) = value.I_max
"""Get [`PriorityOutputCurrentLimiter`](@ref) `phi_I`."""
get_phi_I(value::PriorityOutputCurrentLimiter) = value.phi_I
"""Get [`PriorityOutputCurrentLimiter`](@ref) `ext`."""
get_ext(value::PriorityOutputCurrentLimiter) = value.ext

"""Set [`PriorityOutputCurrentLimiter`](@ref) `I_max`."""
set_I_max!(value::PriorityOutputCurrentLimiter, val) = value.I_max = val
"""Set [`PriorityOutputCurrentLimiter`](@ref) `phi_I`."""
set_phi_I!(value::PriorityOutputCurrentLimiter, val) = value.phi_I = val
"""Set [`PriorityOutputCurrentLimiter`](@ref) `ext`."""
set_ext!(value::PriorityOutputCurrentLimiter, val) = value.ext = val



function from_openapi(po::PD.PriorityOutputCurrentLimiter, refs::OpenAPIRefs)
    return PriorityOutputCurrentLimiter(;
        I_max = _wire_required(po.i_max, "PriorityOutputCurrentLimiter", "I_max"),
        phi_I = _wire_required(po.phi_i, "PriorityOutputCurrentLimiter", "phi_I"),
    )
end

function to_openapi(value::PriorityOutputCurrentLimiter, refs::OpenAPIRefs)
    return PD.PriorityOutputCurrentLimiter(;
        id = component_id(refs, value),
        i_max = get_I_max(value),
        phi_i = get_phi_I(value),
    )
end
