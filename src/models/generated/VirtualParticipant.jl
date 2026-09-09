#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct VirtualParticipant <: MarketTransaction
        name::String
        available::Bool
        max_supply::Float64
        max_demand::Float64
        settlement_point::Union{Nothing, Topology}
        trading_hubs::Vector{TradingHub}
        operation_cost::Union{MarketBidCost, MarketBidTimeSeriesCost}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A virtual (convergence) market participant. Supply offers map to the operating cost's incremental_offer_curves; demand bids to decremental_offer_curves. Settles either at a settlement point or at associated trading hubs (per-hub bids attach as hub-named time series). All MW values are natural units.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is available for market clearing (`true`) or not (`false`)
- `max_supply::Float64`: MW envelope for the incremental (supply) side (MW), validation range: `(0.0, nothing)`
- `max_demand::Float64`: MW envelope for the decremental (demand) side (MW), validation range: `(0.0, nothing)`
- `settlement_point::Union{Nothing, Topology}`: (default: `nothing`) Settlement location (a bus, area, or load zone); `nothing` when the participant settles at trading hubs instead
- `trading_hubs::Vector{TradingHub}`: (default: `TradingHub[]`) Trading hubs this participant settles at; mutually exclusive with `settlement_point`
- `operation_cost::Union{MarketBidCost, MarketBidTimeSeriesCost}`: (default: `MarketBidCost(nothing)`) Bid curves as an offer-curve operating cost
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct VirtualParticipant <: MarketTransaction
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is available for market clearing (`true`) or not (`false`)"
    available::Bool
    "MW envelope for the incremental (supply) side (MW)"
    max_supply::Float64
    "MW envelope for the decremental (demand) side (MW)"
    max_demand::Float64
    "Settlement location (a bus, area, or load zone); `nothing` when the participant settles at trading hubs instead"
    settlement_point::Union{Nothing, Topology}
    "Trading hubs this participant settles at; mutually exclusive with `settlement_point`"
    trading_hubs::Vector{TradingHub}
    "Bid curves as an offer-curve operating cost"
    operation_cost::Union{MarketBidCost, MarketBidTimeSeriesCost}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function VirtualParticipant(name, available, max_supply, max_demand, settlement_point=nothing, trading_hubs=TradingHub[], operation_cost=MarketBidCost(nothing), ext=Dict{String, Any}(), )
    VirtualParticipant(name, available, max_supply, max_demand, settlement_point, trading_hubs, operation_cost, ext, InfrastructureSystemsInternal(), )
end

function VirtualParticipant(; name, available, max_supply, max_demand, settlement_point=nothing, trading_hubs=TradingHub[], operation_cost=MarketBidCost(nothing), ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    VirtualParticipant(name, available, max_supply, max_demand, settlement_point, trading_hubs, operation_cost, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function VirtualParticipant(::Nothing)
    VirtualParticipant(;
        name="init",
        available=false,
        max_supply=0.0,
        max_demand=0.0,
        settlement_point=nothing,
        trading_hubs=TradingHub[],
        operation_cost=MarketBidCost(nothing),
        ext=Dict{String, Any}(),
    )
end

"""Get [`VirtualParticipant`](@ref) `name`."""
get_name(value::VirtualParticipant) = value.name
"""Get [`VirtualParticipant`](@ref) `available`."""
get_available(value::VirtualParticipant) = value.available
"""Get [`VirtualParticipant`](@ref) `max_supply`."""
get_max_supply(value::VirtualParticipant) = value.max_supply
"""Get [`VirtualParticipant`](@ref) `max_demand`."""
get_max_demand(value::VirtualParticipant) = value.max_demand
"""Get [`VirtualParticipant`](@ref) `settlement_point`."""
get_settlement_point(value::VirtualParticipant) = value.settlement_point
"""Get [`VirtualParticipant`](@ref) `trading_hubs`."""
get_trading_hubs(value::VirtualParticipant) = value.trading_hubs
"""Get [`VirtualParticipant`](@ref) `operation_cost`."""
get_operation_cost(value::VirtualParticipant) = value.operation_cost
"""Get [`VirtualParticipant`](@ref) `ext`."""
get_ext(value::VirtualParticipant) = value.ext
"""Get [`VirtualParticipant`](@ref) `internal`."""
get_internal(value::VirtualParticipant) = value.internal

"""Set [`VirtualParticipant`](@ref) `available`."""
set_available!(value::VirtualParticipant, val) = value.available = val
"""Set [`VirtualParticipant`](@ref) `max_supply`."""
set_max_supply!(value::VirtualParticipant, val) = value.max_supply = val
"""Set [`VirtualParticipant`](@ref) `max_demand`."""
set_max_demand!(value::VirtualParticipant, val) = value.max_demand = val
"""Set [`VirtualParticipant`](@ref) `settlement_point`."""
set_settlement_point!(value::VirtualParticipant, val) = value.settlement_point = val
"""Set [`VirtualParticipant`](@ref) `trading_hubs`."""
set_trading_hubs!(value::VirtualParticipant, val) = value.trading_hubs = val
"""Set [`VirtualParticipant`](@ref) `operation_cost`."""
set_operation_cost!(value::VirtualParticipant, val) = value.operation_cost = val
"""Set [`VirtualParticipant`](@ref) `ext`."""
set_ext!(value::VirtualParticipant, val) = value.ext = val


function from_openapi(po::PO.VirtualParticipant, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return VirtualParticipant(;
        name = po.name,
        available = po.available,
        max_supply = po.max_supply,
        max_demand = po.max_demand,
        settlement_point = resolve_ref(refs, po.settlement_point_id, Topology),
        operation_cost = convert_cost(po.operation_cost)::Union{MarketBidCost, MarketBidTimeSeriesCost},
    )
end

function from_openapi(po::PO.VirtualParticipant, refs::OpenAPIRefs, ::NaturalUnit)
    return VirtualParticipant(;
        name = po.name,
        available = po.available,
        max_supply = po.max_supply,
        max_demand = po.max_demand,
        settlement_point = resolve_ref(refs, po.settlement_point_id, Topology),
        operation_cost = convert_cost(po.operation_cost)::Union{MarketBidCost, MarketBidTimeSeriesCost},
    )
end


function to_openapi(value::VirtualParticipant, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PO.VirtualParticipant(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        max_supply = get_max_supply(value),
        max_demand = get_max_demand(value),
        settlement_point_id = _component_id_optional(refs, get_settlement_point(value)),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
    )
end

function to_openapi(value::VirtualParticipant, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.VirtualParticipant(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        max_supply = get_max_supply(value),
        max_demand = get_max_demand(value),
        settlement_point_id = _component_id_optional(refs, get_settlement_point(value)),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
    )
end
