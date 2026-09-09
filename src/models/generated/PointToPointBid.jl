#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct PointToPointBid <: MarketTransaction
        name::String
        available::Bool
        from::Component
        to::Component
        max_active_power::Float64
        price_limits::MinMax
        spread_bid::Union{MarketBidCost, MarketBidTimeSeriesCost}
        linked_crr::Union{Nothing, String}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A priced point-to-point spread bid (e.g. an up-to-congestion or PTP obligation bid): a willingness-to-pay curve on the price spread between two locations. Clears as a withdrawal at `from` and an injection at `to`. Terminals are validated to be a Topology or a TradingHub. All MW values are natural units.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is available for market clearing (`true`) or not (`false`)
- `from::Component`: Source terminal (withdrawal side): a Topology or a TradingHub
- `to::Component`: Sink terminal (injection side): a Topology or a TradingHub; must differ from `from`
- `max_active_power::Float64`: MW envelope for the bid (MW), validation range: `(0.0, nothing)`
- `price_limits::MinMax`: Tariff bid-price bounds on the spread (\$/MWh)
- `spread_bid::Union{MarketBidCost, MarketBidTimeSeriesCost}`: (default: `MarketBidCost(nothing)`) Willingness-to-pay curve on the to-minus-from price spread, as an offer-curve operating cost (incremental side only)
- `linked_crr::Union{Nothing, String}`: (default: `nothing`) Identifier of a linked congestion-right instrument, when the market couples the bid to one
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct PointToPointBid <: MarketTransaction
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is available for market clearing (`true`) or not (`false`)"
    available::Bool
    "Source terminal (withdrawal side): a Topology or a TradingHub"
    from::Component
    "Sink terminal (injection side): a Topology or a TradingHub; must differ from `from`"
    to::Component
    "MW envelope for the bid (MW)"
    max_active_power::Float64
    "Tariff bid-price bounds on the spread (\$/MWh)"
    price_limits::MinMax
    "Willingness-to-pay curve on the to-minus-from price spread, as an offer-curve operating cost (incremental side only)"
    spread_bid::Union{MarketBidCost, MarketBidTimeSeriesCost}
    "Identifier of a linked congestion-right instrument, when the market couples the bid to one"
    linked_crr::Union{Nothing, String}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function PointToPointBid(name, available, from, to, max_active_power, price_limits, spread_bid=MarketBidCost(nothing), linked_crr=nothing, ext=Dict{String, Any}(), )
    PointToPointBid(name, available, from, to, max_active_power, price_limits, spread_bid, linked_crr, ext, InfrastructureSystemsInternal(), )
end

function PointToPointBid(; name, available, from, to, max_active_power, price_limits, spread_bid=MarketBidCost(nothing), linked_crr=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    PointToPointBid(name, available, from, to, max_active_power, price_limits, spread_bid, linked_crr, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function PointToPointBid(::Nothing)
    PointToPointBid(;
        name="init",
        available=false,
        from=ACBus(nothing),
        to=ACBus(nothing),
        max_active_power=0.0,
        price_limits=(min=0.0, max=0.0),
        spread_bid=MarketBidCost(nothing),
        linked_crr=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`PointToPointBid`](@ref) `name`."""
get_name(value::PointToPointBid) = value.name
"""Get [`PointToPointBid`](@ref) `available`."""
get_available(value::PointToPointBid) = value.available
"""Get [`PointToPointBid`](@ref) `from`."""
get_from(value::PointToPointBid) = value.from
"""Get [`PointToPointBid`](@ref) `to`."""
get_to(value::PointToPointBid) = value.to
"""Get [`PointToPointBid`](@ref) `max_active_power`."""
get_max_active_power(value::PointToPointBid) = value.max_active_power
"""Get [`PointToPointBid`](@ref) `price_limits`."""
get_price_limits(value::PointToPointBid) = value.price_limits
"""Get [`PointToPointBid`](@ref) `spread_bid`."""
get_spread_bid(value::PointToPointBid) = value.spread_bid
"""Get [`PointToPointBid`](@ref) `linked_crr`."""
get_linked_crr(value::PointToPointBid) = value.linked_crr
"""Get [`PointToPointBid`](@ref) `ext`."""
get_ext(value::PointToPointBid) = value.ext
"""Get [`PointToPointBid`](@ref) `internal`."""
get_internal(value::PointToPointBid) = value.internal

"""Set [`PointToPointBid`](@ref) `available`."""
set_available!(value::PointToPointBid, val) = value.available = val
"""Set [`PointToPointBid`](@ref) `from`."""
set_from!(value::PointToPointBid, val) = value.from = val
"""Set [`PointToPointBid`](@ref) `to`."""
set_to!(value::PointToPointBid, val) = value.to = val
"""Set [`PointToPointBid`](@ref) `max_active_power`."""
set_max_active_power!(value::PointToPointBid, val) = value.max_active_power = val
"""Set [`PointToPointBid`](@ref) `price_limits`."""
set_price_limits!(value::PointToPointBid, val) = value.price_limits = val
"""Set [`PointToPointBid`](@ref) `spread_bid`."""
set_spread_bid!(value::PointToPointBid, val) = value.spread_bid = val
"""Set [`PointToPointBid`](@ref) `linked_crr`."""
set_linked_crr!(value::PointToPointBid, val) = value.linked_crr = val
"""Set [`PointToPointBid`](@ref) `ext`."""
set_ext!(value::PointToPointBid, val) = value.ext = val


function from_openapi(po::PO.PointToPointBid, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PointToPointBid(;
        name = po.name,
        available = po.available,
        from = resolve_ref(refs, po.from_id, Component),
        to = resolve_ref(refs, po.to_id, Component),
        max_active_power = po.max_active_power,
        price_limits = _minmax_from_po(po.price_limits),
        spread_bid = convert_cost(po.spread_bid)::Union{MarketBidCost, MarketBidTimeSeriesCost},
        linked_crr = po.linked_crr,
    )
end

function from_openapi(po::PO.PointToPointBid, refs::OpenAPIRefs, ::NaturalUnit)
    return PointToPointBid(;
        name = po.name,
        available = po.available,
        from = resolve_ref(refs, po.from_id, Component),
        to = resolve_ref(refs, po.to_id, Component),
        max_active_power = po.max_active_power,
        price_limits = _minmax_from_po(po.price_limits),
        spread_bid = convert_cost(po.spread_bid)::Union{MarketBidCost, MarketBidTimeSeriesCost},
        linked_crr = po.linked_crr,
    )
end

function from_openapi(po::PO.PointToPointBid, refs::OpenAPIRefs)
    return from_openapi(po, refs, DU)
end

function to_openapi(value::PointToPointBid, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PO.PointToPointBid(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        from_id = component_id(refs, get_from(value)),
        to_id = component_id(refs, get_to(value)),
        max_active_power = get_max_active_power(value),
        price_limits = _minmax_po(get_price_limits(value)),
        spread_bid = convert_cost_to_openapi(get_spread_bid(value)),
        linked_crr = get_linked_crr(value),
    )
end

function to_openapi(value::PointToPointBid, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.PointToPointBid(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        from_id = component_id(refs, get_from(value)),
        to_id = component_id(refs, get_to(value)),
        max_active_power = get_max_active_power(value),
        price_limits = _minmax_po(get_price_limits(value)),
        spread_bid = convert_cost_to_openapi(get_spread_bid(value)),
        linked_crr = get_linked_crr(value),
    )
end
