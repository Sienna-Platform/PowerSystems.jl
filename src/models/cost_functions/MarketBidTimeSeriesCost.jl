"""
$(TYPEDEF)
$(TYPEDFIELDS)

    MarketBidTimeSeriesCost(no_load_cost, start_up, shut_down, incremental_offer_curves, decremental_offer_curves, ancillary_service_offers)
    MarketBidTimeSeriesCost(; no_load_cost, start_up, shut_down, incremental_offer_curves, decremental_offer_curves, ancillary_service_offers)

An operating cost for time-varying market bids of energy and ancillary services.
All cost curve fields are backed by time series data via IS.jl's time-series ValueCurve types.
For static (non-time-varying) bids, use [`MarketBidCost`](@ref).
"""
mutable struct MarketBidTimeSeriesCost <: OfferCurveCost
    "No load cost (time series)"
    no_load_cost::TimeSeriesLinearCurve
    "Start-up cost stages"
    # TODO: future IS object will replace this Union{TimeSeriesKey, StartUpStages}
    start_up::Union{TimeSeriesKey, StartUpStages}
    "Shut-down cost (time series)"
    shut_down::TimeSeriesLinearCurve
    "Sell Offer Curves data (time series)"
    incremental_offer_curves::CostCurve{TimeSeriesPiecewiseIncrementalCurve}
    "Buy Offer Curves data (time series)"
    decremental_offer_curves::CostCurve{TimeSeriesPiecewiseIncrementalCurve}
    "Bids for the ancillary services"
    ancillary_service_offers::Vector{Service}
end

MarketBidTimeSeriesCost(;
    no_load_cost,
    start_up,
    shut_down,
    incremental_offer_curves,
    decremental_offer_curves,
    ancillary_service_offers = Vector{Service}(),
) = MarketBidTimeSeriesCost(
    no_load_cost, start_up, shut_down,
    incremental_offer_curves, decremental_offer_curves,
    ancillary_service_offers,
)

"""Get [`MarketBidTimeSeriesCost`](@ref) `no_load_cost`."""
get_no_load_cost(value::MarketBidTimeSeriesCost) = value.no_load_cost
"""Get [`MarketBidTimeSeriesCost`](@ref) `start_up`."""
get_start_up(value::MarketBidTimeSeriesCost) = value.start_up
"""Get [`MarketBidTimeSeriesCost`](@ref) `shut_down`."""
get_shut_down(value::MarketBidTimeSeriesCost) = value.shut_down
"""Get [`MarketBidTimeSeriesCost`](@ref) `incremental_offer_curves`."""
get_incremental_offer_curves(value::MarketBidTimeSeriesCost) =
    value.incremental_offer_curves
"""Get [`MarketBidTimeSeriesCost`](@ref) `decremental_offer_curves`."""
get_decremental_offer_curves(value::MarketBidTimeSeriesCost) =
    value.decremental_offer_curves
"""Get [`MarketBidTimeSeriesCost`](@ref) `ancillary_service_offers`."""
get_ancillary_service_offers(value::MarketBidTimeSeriesCost) =
    value.ancillary_service_offers

"""Set [`MarketBidTimeSeriesCost`](@ref) `no_load_cost`."""
set_no_load_cost!(value::MarketBidTimeSeriesCost, val) = value.no_load_cost = val
"""Set [`MarketBidTimeSeriesCost`](@ref) `start_up`."""
set_start_up!(value::MarketBidTimeSeriesCost, val) = value.start_up = val
"""Set [`MarketBidTimeSeriesCost`](@ref) `shut_down`."""
set_shut_down!(value::MarketBidTimeSeriesCost, val) = value.shut_down = val
"""Set [`MarketBidTimeSeriesCost`](@ref) `incremental_offer_curves`."""
set_incremental_offer_curves!(value::MarketBidTimeSeriesCost, val) =
    value.incremental_offer_curves = val
"""Set [`MarketBidTimeSeriesCost`](@ref) `decremental_offer_curves`."""
set_decremental_offer_curves!(value::MarketBidTimeSeriesCost, val) =
    value.decremental_offer_curves = val
"""Set [`MarketBidTimeSeriesCost`](@ref) `ancillary_service_offers`."""
set_ancillary_service_offers!(value::MarketBidTimeSeriesCost, val) =
    value.ancillary_service_offers = val

"""
Make a time-series-backed `CostCurve{TimeSeriesPiecewiseIncrementalCurve}` from
`TimeSeriesKey` references, suitable for the `incremental_offer_curves` or
`decremental_offer_curves` field of a [`MarketBidTimeSeriesCost`](@ref).
"""
function make_market_bid_ts_curve(
    ts_key::TimeSeriesKey,
    initial_input_key::Union{Nothing, TimeSeriesKey} = nothing,
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS;
    input_at_zero_key::Union{Nothing, TimeSeriesKey} = nothing,
)
    vc = TimeSeriesPiecewiseIncrementalCurve(ts_key, initial_input_key, input_at_zero_key)
    return CostCurve(vc, power_units)
end
