#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct HybridOutputCurrentLimiter <: OutputCurrentLimiter
        I_max::Float64
        rv::Float64
        lv::Float64
        ext::Dict{String, Any}
    end

Parameters of Hybrid Current Controller Limiter. Regulates the magnitude of the inverter output current, but with a closed loop feedback regulated by a virtual impedance which provides ant-windup. Described in: Novel Hybrid Current Limiter for Grid-Forming Inverter Control During Unbalanced Faults by Baeckland and Seo, 2023 

# Arguments
- `I_max::Float64`: Maximum limit on current controller input current (component base), validation range: `(0, nothing)`
- `rv::Float64`: Real part of the virtual impedance, validation range: `(0, nothing)`
- `lv::Float64`: Imaginary part of the virtual impedance, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`)
"""
mutable struct HybridOutputCurrentLimiter <: OutputCurrentLimiter
    "Maximum limit on current controller input current (component base)"
    I_max::Float64
    "Real part of the virtual impedance"
    rv::Float64
    "Imaginary part of the virtual impedance"
    lv::Float64
    ext::Dict{String, Any}
end


function HybridOutputCurrentLimiter(; I_max, rv, lv, ext=Dict{String, Any}(), )
    HybridOutputCurrentLimiter(I_max, rv, lv, ext, )
end

# Constructor for demo purposes; non-functional.
function HybridOutputCurrentLimiter(::Nothing)
    HybridOutputCurrentLimiter(;
        I_max=0,
        rv=0,
        lv=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`HybridOutputCurrentLimiter`](@ref) `I_max`."""
get_I_max(value::HybridOutputCurrentLimiter) = value.I_max
"""Get [`HybridOutputCurrentLimiter`](@ref) `rv`."""
get_rv(value::HybridOutputCurrentLimiter) = value.rv
"""Get [`HybridOutputCurrentLimiter`](@ref) `lv`."""
get_lv(value::HybridOutputCurrentLimiter) = value.lv
"""Get [`HybridOutputCurrentLimiter`](@ref) `ext`."""
get_ext(value::HybridOutputCurrentLimiter) = value.ext

"""Set [`HybridOutputCurrentLimiter`](@ref) `I_max`."""
set_I_max!(value::HybridOutputCurrentLimiter, val) = value.I_max = val
"""Set [`HybridOutputCurrentLimiter`](@ref) `rv`."""
set_rv!(value::HybridOutputCurrentLimiter, val) = value.rv = val
"""Set [`HybridOutputCurrentLimiter`](@ref) `lv`."""
set_lv!(value::HybridOutputCurrentLimiter, val) = value.lv = val
"""Set [`HybridOutputCurrentLimiter`](@ref) `ext`."""
set_ext!(value::HybridOutputCurrentLimiter, val) = value.ext = val
