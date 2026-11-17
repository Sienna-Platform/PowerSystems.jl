#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct LCLFilter <: Filter
        lf::Float64
        rf::Float64
        cf::Float64
        lg::Float64
        rg::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of a LCL filter outside the converter, the [states](@ref S) are in the grid's reference frame

# Arguments
- `lf::Float64`: Series inductance in p.u. of converter filter, validation range: `(0, nothing)`
- `rf::Float64`: Series resistance in p.u. of converter filter, validation range: `(0, nothing)`
- `cf::Float64`: Shunt capacitance in p.u. of converter filter, validation range: `(0, nothing)`
- `lg::Float64`: Series inductance in p.u. of converter filter to the grid, validation range: `(0, nothing)`
- `rg::Float64`: Series resistance in p.u. of converter filter to the grid, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the LCLFilter model are:
	ir_cnv: Real current out of the converter,
	ii_cnv: Imaginary current out of the converter,
	vr_filter: Real voltage at the filter's capacitor,
	vi_filter: Imaginary voltage at the filter's capacitor,
	ir_filter: Real current out of the filter,
	ii_filter: Imaginary current out of the filter
- `n_states::Int`: (**Do not modify.**) LCLFilter has 6 states
"""
mutable struct LCLFilter <: Filter
    "Series inductance in p.u. of converter filter"
    lf::Float64
    "Series resistance in p.u. of converter filter"
    rf::Float64
    "Shunt capacitance in p.u. of converter filter"
    cf::Float64
    "Series inductance in p.u. of converter filter to the grid"
    lg::Float64
    "Series resistance in p.u. of converter filter to the grid"
    rg::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the LCLFilter model are:
	ir_cnv: Real current out of the converter,
	ii_cnv: Imaginary current out of the converter,
	vr_filter: Real voltage at the filter's capacitor,
	vi_filter: Imaginary voltage at the filter's capacitor,
	ir_filter: Real current out of the filter,
	ii_filter: Imaginary current out of the filter"
    states::Vector{Symbol}
    "(**Do not modify.**) LCLFilter has 6 states"
    n_states::Int
end

function LCLFilter(lf, rf, cf, lg, rg, ext=Dict{String, Any}(), )
    LCLFilter(lf, rf, cf, lg, rg, ext, [:ir_cnv, :ii_cnv, :vr_filter, :vi_filter, :ir_filter, :ii_filter], 6, )
end

function LCLFilter(; lf, rf, cf, lg, rg, ext=Dict{String, Any}(), states=[:ir_cnv, :ii_cnv, :vr_filter, :vi_filter, :ir_filter, :ii_filter], n_states=6, )
    LCLFilter(lf, rf, cf, lg, rg, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function LCLFilter(::Nothing)
    LCLFilter(;
        lf=0,
        rf=0,
        cf=0,
        lg=0,
        rg=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`LCLFilter`](@ref) `lf`."""
get_lf(value::LCLFilter) = value.lf
"""Get [`LCLFilter`](@ref) `rf`."""
get_rf(value::LCLFilter) = value.rf
"""Get [`LCLFilter`](@ref) `cf`."""
get_cf(value::LCLFilter) = value.cf
"""Get [`LCLFilter`](@ref) `lg`."""
get_lg(value::LCLFilter) = value.lg
"""Get [`LCLFilter`](@ref) `rg`."""
get_rg(value::LCLFilter) = value.rg
"""Get [`LCLFilter`](@ref) `ext`."""
get_ext(value::LCLFilter) = value.ext
"""Get [`LCLFilter`](@ref) `states`."""
get_states(value::LCLFilter) = value.states
"""Get [`LCLFilter`](@ref) `n_states`."""
get_n_states(value::LCLFilter) = value.n_states

"""Set [`LCLFilter`](@ref) `lf`."""
set_lf!(value::LCLFilter, val) = value.lf = val
"""Set [`LCLFilter`](@ref) `rf`."""
set_rf!(value::LCLFilter, val) = value.rf = val
"""Set [`LCLFilter`](@ref) `cf`."""
set_cf!(value::LCLFilter, val) = value.cf = val
"""Set [`LCLFilter`](@ref) `lg`."""
set_lg!(value::LCLFilter, val) = value.lg = val
"""Set [`LCLFilter`](@ref) `rg`."""
set_rg!(value::LCLFilter, val) = value.rg = val
"""Set [`LCLFilter`](@ref) `ext`."""
set_ext!(value::LCLFilter, val) = value.ext = val



function from_openapi(po::PD.LCLFilter, refs::OpenAPIRefs)
    return LCLFilter(;
        lf = _wire_required(po.lf, "LCLFilter", "lf"),
        rf = _wire_required(po.rf, "LCLFilter", "rf"),
        cf = _wire_required(po.cf, "LCLFilter", "cf"),
        lg = _wire_required(po.lg, "LCLFilter", "lg"),
        rg = _wire_required(po.rg, "LCLFilter", "rg"),
    )
end

function to_openapi(value::LCLFilter, refs::OpenAPIRefs)
    return PD.LCLFilter(;
        id = component_id(refs, value),
        lf = get_lf(value),
        rf = get_rf(value),
        cf = get_cf(value),
        lg = get_lg(value),
        rg = get_rg(value),
    )
end
