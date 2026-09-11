#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct AGC <: Service
        name::String
        available::Bool
        bias::Float64
        K_p::Float64
        K_i::Float64
        K_d::Float64
        delta_t::Float64
        area::Union{Nothing, Area}
        initial_ace::Float64
        reserves::Vector{Reserve}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

Automatic generation control (AGC) for the system or a certain `Area` within the system.

This model uses a proportional–integral–derivative (PID) control to simulate a "smooth" response of the AGC to the area control error (ACE). Refer to ["AGC Simulation Model for Large Renewable Energy Penetration Studies."](https://doi.org/10.1109/NAPS50074.2021.9449687)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bias::Float64`: Area frequency bias in MW/Hz
- `K_p::Float64`: PID Proportional Constant
- `K_i::Float64`: PID Integral Constant
- `K_d::Float64`: PID Derivative Constant
- `delta_t::Float64`: PID Discretization period [Seconds]
- `area::Union{Nothing, Area}`: (default: `nothing`) the area controlled by the AGC
- `initial_ace::Float64`: (default: `0.0`) Initial condition for ACE
- `reserves::Vector{Reserve}`: (default: `Device[]`) Reserves that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct AGC <: Service
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Area frequency bias in MW/Hz"
    bias::Float64
    "PID Proportional Constant"
    K_p::Float64
    "PID Integral Constant"
    K_i::Float64
    "PID Derivative Constant"
    K_d::Float64
    "PID Discretization period [Seconds]"
    delta_t::Float64
    "the area controlled by the AGC"
    area::Union{Nothing, Area}
    "Initial condition for ACE"
    initial_ace::Float64
    "Reserves that this device contributes to"
    reserves::Vector{Reserve}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function AGC(name, available, bias, K_p, K_i, K_d, delta_t, area=nothing, initial_ace=0.0, reserves=Device[], ext=Dict{String, Any}(), )
    AGC(name, available, bias, K_p, K_i, K_d, delta_t, area, initial_ace, reserves, ext, InfrastructureSystemsInternal(), )
end

function AGC(; name, available, bias, K_p, K_i, K_d, delta_t, area=nothing, initial_ace=0.0, reserves=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    AGC(name, available, bias, K_p, K_i, K_d, delta_t, area, initial_ace, reserves, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function AGC(::Nothing)
    AGC(;
        name="init",
        available=false,
        bias=0.0,
        K_p=0.0,
        K_i=0.0,
        K_d=0.0,
        delta_t=0.0,
        area=Area(nothing),
        initial_ace=0.0,
        reserves=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`AGC`](@ref) `name`."""
get_name(value::AGC) = value.name
"""Get [`AGC`](@ref) `available`."""
get_available(value::AGC) = value.available
"""Get [`AGC`](@ref) `bias`."""
get_bias(value::AGC) = value.bias
"""Get [`AGC`](@ref) `K_p`."""
get_K_p(value::AGC) = value.K_p
"""Get [`AGC`](@ref) `K_i`."""
get_K_i(value::AGC) = value.K_i
"""Get [`AGC`](@ref) `K_d`."""
get_K_d(value::AGC) = value.K_d
"""Get [`AGC`](@ref) `delta_t`."""
get_delta_t(value::AGC) = value.delta_t
"""Get [`AGC`](@ref) `area`."""
get_area(value::AGC) = value.area
"""Get [`AGC`](@ref) `initial_ace`."""
get_initial_ace(value::AGC) = value.initial_ace
"""Get [`AGC`](@ref) `reserves`."""
get_reserves(value::AGC) = value.reserves
"""Get [`AGC`](@ref) `ext`."""
get_ext(value::AGC) = value.ext
"""Get [`AGC`](@ref) `internal`."""
get_internal(value::AGC) = value.internal

"""Set [`AGC`](@ref) `available`."""
set_available!(value::AGC, val) = value.available = val
"""Set [`AGC`](@ref) `bias`."""
set_bias!(value::AGC, val) = value.bias = val
"""Set [`AGC`](@ref) `K_p`."""
set_K_p!(value::AGC, val) = value.K_p = val
"""Set [`AGC`](@ref) `K_i`."""
set_K_i!(value::AGC, val) = value.K_i = val
"""Set [`AGC`](@ref) `K_d`."""
set_K_d!(value::AGC, val) = value.K_d = val
"""Set [`AGC`](@ref) `delta_t`."""
set_delta_t!(value::AGC, val) = value.delta_t = val
"""Set [`AGC`](@ref) `area`."""
set_area!(value::AGC, val) = value.area = val
"""Set [`AGC`](@ref) `initial_ace`."""
set_initial_ace!(value::AGC, val) = value.initial_ace = val
"""Set [`AGC`](@ref) `reserves`."""
set_reserves!(value::AGC, val) = value.reserves = val
"""Set [`AGC`](@ref) `ext`."""
set_ext!(value::AGC, val) = value.ext = val


function from_openapi(po::PO.AGC, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return AGC(;
        name = po.name,
        available = po.available,
        bias = po.bias,
        K_p = po.K_p,
        K_i = po.K_i,
        K_d = po.K_d,
        delta_t = po.delta_t,
        area = resolve_ref(refs, po.area, Area),
        initial_ace = (if po.initial_ace isa Union{Nothing, IC.Absent}; 0.0; else; po.initial_ace; end),
    )
end

function from_openapi(po::PO.AGC, refs::OpenAPIRefs, ::NaturalUnit)
    return AGC(;
        name = po.name,
        available = po.available,
        bias = po.bias,
        K_p = po.K_p,
        K_i = po.K_i,
        K_d = po.K_d,
        delta_t = po.delta_t,
        area = resolve_ref(refs, po.area, Area),
        initial_ace = (if po.initial_ace isa Union{Nothing, IC.Absent}; 0.0; else; po.initial_ace; end),
    )
end

function from_openapi(po::PO.AGC, refs::OpenAPIRefs)
    return from_openapi(po, refs, CU)
end

function to_openapi(value::AGC, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.AGC(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bias = get_bias(value),
        K_p = get_K_p(value),
        K_i = get_K_i(value),
        K_d = get_K_d(value),
        delta_t = get_delta_t(value),
        area = _component_id_optional(refs, get_area(value)),
        initial_ace = get_initial_ace(value),
    )
end

function to_openapi(value::AGC, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.AGC(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bias = get_bias(value),
        K_p = get_K_p(value),
        K_i = get_K_i(value),
        K_d = get_K_d(value),
        delta_t = get_delta_t(value),
        area = _component_id_optional(refs, get_area(value)),
        initial_ace = get_initial_ace(value),
    )
end
