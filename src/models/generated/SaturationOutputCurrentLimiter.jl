#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SaturationOutputCurrentLimiter <: OutputCurrentLimiter
        I_max::Float64
        kw::Float64
        ext::Dict{String, Any}
    end

Parameters of Saturation Current Controller Limiter. Regulates the magnitude of the inverter output current, and applies a closed loop feedback regulated by a static gain which provides ant-windup

# Arguments
- `I_max::Float64`: Maximum limit on current controller input current (component base), validation range: `(0, nothing)`
- `kw::Float64`: Defined feedback gain, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`)
"""
mutable struct SaturationOutputCurrentLimiter <: OutputCurrentLimiter
    "Maximum limit on current controller input current (component base)"
    I_max::Float64
    "Defined feedback gain"
    kw::Float64
    ext::Dict{String, Any}
end


function SaturationOutputCurrentLimiter(; I_max, kw, ext=Dict{String, Any}(), )
    SaturationOutputCurrentLimiter(I_max, kw, ext, )
end

# Constructor for demo purposes; non-functional.
function SaturationOutputCurrentLimiter(::Nothing)
    SaturationOutputCurrentLimiter(;
        I_max=0,
        kw=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`SaturationOutputCurrentLimiter`](@ref) `I_max`."""
get_I_max(value::SaturationOutputCurrentLimiter) = value.I_max
"""Get [`SaturationOutputCurrentLimiter`](@ref) `kw`."""
get_kw(value::SaturationOutputCurrentLimiter) = value.kw
"""Get [`SaturationOutputCurrentLimiter`](@ref) `ext`."""
get_ext(value::SaturationOutputCurrentLimiter) = value.ext

"""Set [`SaturationOutputCurrentLimiter`](@ref) `I_max`."""
set_I_max!(value::SaturationOutputCurrentLimiter, val) = value.I_max = val
"""Set [`SaturationOutputCurrentLimiter`](@ref) `kw`."""
set_kw!(value::SaturationOutputCurrentLimiter, val) = value.kw = val
"""Set [`SaturationOutputCurrentLimiter`](@ref) `ext`."""
set_ext!(value::SaturationOutputCurrentLimiter, val) = value.ext = val
