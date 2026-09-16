#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TradingHub <: MarketComponent
        name::String
        buses::Vector{ACBus}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A market trading hub: a named set of member buses at which hub-settled bids are priced. Member buses are unweighted.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `buses::Vector{ACBus}`: (default: `ACBus[]`) Member buses of the hub
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct TradingHub <: MarketComponent
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Member buses of the hub"
    buses::Vector{ACBus}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TradingHub(name, buses=ACBus[], ext=Dict{String, Any}(), )
    TradingHub(name, buses, ext, InfrastructureSystemsInternal(), )
end

function TradingHub(; name, buses=ACBus[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    TradingHub(name, buses, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function TradingHub(::Nothing)
    TradingHub(;
        name="init",
        buses=ACBus[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`TradingHub`](@ref) `name`."""
get_name(value::TradingHub) = value.name
"""Get [`TradingHub`](@ref) `buses`."""
get_buses(value::TradingHub) = value.buses
"""Get [`TradingHub`](@ref) `ext`."""
get_ext(value::TradingHub) = value.ext
"""Get [`TradingHub`](@ref) `internal`."""
get_internal(value::TradingHub) = value.internal

"""Set [`TradingHub`](@ref) `buses`."""
set_buses!(value::TradingHub, val) = value.buses = val
"""Set [`TradingHub`](@ref) `ext`."""
set_ext!(value::TradingHub, val) = value.ext = val


function from_openapi(po::PO.TradingHub, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return TradingHub(;
        name = po.name,
    )
end

function from_openapi(po::PO.TradingHub, refs::OpenAPIRefs, ::NaturalUnit)
    return TradingHub(;
        name = po.name,
    )
end


function to_openapi(value::TradingHub, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.TradingHub(;
        id = component_id(refs, value),
        name = get_name(value),
    )
end

function to_openapi(value::TradingHub, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.TradingHub(;
        id = component_id(refs, value),
        name = get_name(value),
    )
end
