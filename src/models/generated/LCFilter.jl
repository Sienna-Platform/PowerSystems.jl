#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct LCFilter <: Filter
        lf::Float64
        rf::Float64
        cf::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of a LCL filter outside the converter

# Arguments
- `lf::Float64`: filter inductance, validation range: `(0, nothing)`
- `rf::Float64`: filter resistance, validation range: `(0, nothing)`
- `cf::Float64`: filter capacitance, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the LCFilter model are:
	ir_filter: Real current out of the filter,
	ii_filter: Imaginary current out of the filter
- `n_states::Int`: (**Do not modify.**) LCFilter has two states
"""
mutable struct LCFilter <: Filter
    "filter inductance"
    lf::Float64
    "filter resistance"
    rf::Float64
    "filter capacitance"
    cf::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the LCFilter model are:
	ir_filter: Real current out of the filter,
	ii_filter: Imaginary current out of the filter"
    states::Vector{Symbol}
    "(**Do not modify.**) LCFilter has two states"
    n_states::Int
end

function LCFilter(lf, rf, cf, ext=Dict{String, Any}(), )
    LCFilter(lf, rf, cf, ext, [:ir_filter, :ii_filter], 2, )
end

function LCFilter(; lf, rf, cf, ext=Dict{String, Any}(), states=[:ir_filter, :ii_filter], n_states=2, )
    LCFilter(lf, rf, cf, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function LCFilter(::Nothing)
    LCFilter(;
        lf=0,
        rf=0,
        cf=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`LCFilter`](@ref) `lf`."""
get_lf(value::LCFilter) = value.lf
"""Get [`LCFilter`](@ref) `rf`."""
get_rf(value::LCFilter) = value.rf
"""Get [`LCFilter`](@ref) `cf`."""
get_cf(value::LCFilter) = value.cf
"""Get [`LCFilter`](@ref) `ext`."""
get_ext(value::LCFilter) = value.ext
"""Get [`LCFilter`](@ref) `states`."""
get_states(value::LCFilter) = value.states
"""Get [`LCFilter`](@ref) `n_states`."""
get_n_states(value::LCFilter) = value.n_states

"""Set [`LCFilter`](@ref) `lf`."""
set_lf!(value::LCFilter, val) = value.lf = val
"""Set [`LCFilter`](@ref) `rf`."""
set_rf!(value::LCFilter, val) = value.rf = val
"""Set [`LCFilter`](@ref) `cf`."""
set_cf!(value::LCFilter, val) = value.cf = val
"""Set [`LCFilter`](@ref) `ext`."""
set_ext!(value::LCFilter, val) = value.ext = val



function from_openapi(po::PD.LCFilter, refs::OpenAPIRefs)
    return LCFilter(;
        lf = _wire_required(po.lf, "LCFilter", "lf"),
        rf = _wire_required(po.rf, "LCFilter", "rf"),
        cf = _wire_required(po.cf, "LCFilter", "cf"),
    )
end

function to_openapi(value::LCFilter, refs::OpenAPIRefs)
    return PD.LCFilter(;
        id = component_id(refs, value),
        lf = get_lf(value),
        rf = get_rf(value),
        cf = get_cf(value),
    )
end
