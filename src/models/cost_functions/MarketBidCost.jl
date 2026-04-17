"""
$(TYPEDEF)
$(TYPEDFIELDS)

    MarketBidCost(no_load_cost, start_up, shut_down, incremental_offer_curves, decremental_offer_curves, ancillary_service_offers)
    MarketBidCost(; no_load_cost, start_up, shut_down, incremental_offer_curves, decremental_offer_curves, ancillary_service_offers)
    MarketBidCost(no_load_cost, start_up::Real, shut_down, incremental_offer_curves, decremental_offer_curves, ancillary_service_offers)

An operating cost for market bids of energy and ancilliary services for any asset.
Compatible with most US Market bidding mechanisms that support demand and generation side.
"""
mutable struct MarketBidCost <: OfferCurveCost
    "No load cost"
    no_load_cost::Union{TimeSeriesKey, Nothing, Float64}
    "Start-up cost at different stages of the thermal cycle as the unit cools after a
    shutdown (e.g., *hot*, *warm*, or *cold* starts). Warm is also referred to as
    intermediate in some markets. Can also accept a single value if there is only one
    start-up cost"
    start_up::Union{TimeSeriesKey, StartUpStages}
    "Shut-down cost"
    shut_down::Union{TimeSeriesKey, Float64}
    "Sell Offer Curves data, which can be a time series of `PiecewiseStepData` or a
    [`CostCurve`](@ref) of [`PiecewiseIncrementalCurve`](@ref)"
    incremental_offer_curves::Union{
        Nothing,
        TimeSeriesKey,  # piecewise step data
        CostCurve{PiecewiseIncrementalCurve},
    }
    "Buy Offer Curves data, which can be a time series of `PiecewiseStepData` or a
    [`CostCurve`](@ref) of [`PiecewiseIncrementalCurve`](@ref)"
    decremental_offer_curves::Union{
        Nothing,
        TimeSeriesKey,
        CostCurve{PiecewiseIncrementalCurve},
    }
    "If using a time series for incremental_offer_curves, this is a time series of `Float64` representing the `initial_input`"
    incremental_initial_input::Union{Nothing, TimeSeriesKey}
    "If using a time series for decremental_offer_curves, this is a time series of `Float64` representing the `initial_input`"
    decremental_initial_input::Union{Nothing, TimeSeriesKey}
    "Bids for the ancillary services"
    ancillary_service_offers::Vector{Service}
end

"Auxiliary constructor for shut_down::Integer"
MarketBidCost(
    no_load_cost::Union{TimeSeriesKey, Nothing, Float64},
    start_up::Union{TimeSeriesKey, StartUpStages},
    shut_down::Integer,
    incremental_offer_curves,
    decremental_offer_curves,
    incremental_initial_input,
    decremental_initial_input,
    ancillary_service_offers,
) = MarketBidCost(
    no_load_cost,
    start_up,
    Float64(shut_down),
    incremental_offer_curves,
    decremental_offer_curves,
    incremental_initial_input,
    decremental_initial_input,
    ancillary_service_offers,
)

"Auxiliary constructor for no_load_cost::Integer"
MarketBidCost(
    no_load_cost::Integer,
    start_up::Union{TimeSeriesKey, StartUpStages},
    shut_down::Union{TimeSeriesKey, Float64},
    incremental_offer_curves,
    decremental_offer_curves,
    incremental_initial_input,
    decremental_initial_input,
    ancillary_service_offers,
) =
    MarketBidCost(
        Float64(no_load_cost),
        start_up,
        shut_down,
        incremental_offer_curves,
        decremental_offer_curves,
        incremental_initial_input,
        decremental_initial_input,
        ancillary_service_offers,
    )

"""Auxiliary Constructor for TestData"""
MarketBidCost(
    no_load_cost::Float64,
    start_up::Union{TimeSeriesKey, StartUpStages},
    shut_down::Union{TimeSeriesKey, Float64},
    incremental_offer_curves,
    decremental_offer_curves,
    ancillary_service_offers,
) =
    MarketBidCost(
        Float64(no_load_cost),
        start_up,
        shut_down,
        incremental_offer_curves,
        decremental_offer_curves,
        nothing,
        nothing,
        ancillary_service_offers,
    )

# Constructor that sets the startup cost to a small constant and the rest to 0.0.
function MarketBidCost(::Nothing)
    MarketBidCost(;
        no_load_cost = nothing,
        start_up = (hot = START_COST, warm = START_COST, cold = START_COST),
        shut_down = 0.0,
    )
end

MarketBidCost(;
    no_load_cost = nothing,
    start_up,
    shut_down,
    incremental_offer_curves = nothing,
    decremental_offer_curves = nothing,
    incremental_initial_input = nothing,
    decremental_initial_input = nothing,
    ancillary_service_offers = Vector{Service}(),
) = MarketBidCost(
    no_load_cost, start_up, shut_down, incremental_offer_curves,
    decremental_offer_curves, incremental_initial_input, decremental_initial_input,
    ancillary_service_offers,
)

"""
Accepts a single `start_up` value to use as the `hot` value, with `warm` and `cold` set to
`0.0`.
"""
function MarketBidCost(
    no_load_cost,
    start_up::Real,
    shut_down;
    incremental_offer_curves = nothing,
    decremental_offer_curves = nothing,
    incremental_initial_input = nothing,
    decremental_initial_input = nothing,
    ancillary_service_offers = Vector{Service}(),
)
    # Intended for use with generators that are not multi-start (e.g. ThermalStandard).
    # Operators use `hot` when they don’t have multiple stages.
    start_up_multi = single_start_up_to_stages(start_up)
    return MarketBidCost(;
        no_load_cost = no_load_cost,
        start_up = start_up_multi,
        shut_down = shut_down,
        incremental_offer_curves = incremental_offer_curves,
        decremental_offer_curves = decremental_offer_curves,
        incremental_initial_input = incremental_initial_input,
        decremental_initial_input = decremental_initial_input,
        ancillary_service_offers = ancillary_service_offers,
    )
end

"""Get [`MarketBidCost`](@ref) `no_load_cost`."""
get_no_load_cost(value::MarketBidCost) = value.no_load_cost
"""Get [`MarketBidCost`](@ref) `start_up`."""
get_start_up(value::MarketBidCost) = value.start_up
"""Get [`MarketBidCost`](@ref) `shut_down`."""
get_shut_down(value::MarketBidCost) = value.shut_down
"""Get [`MarketBidCost`](@ref) `incremental_offer_curves`."""
get_incremental_offer_curves(value::MarketBidCost) = value.incremental_offer_curves
"""Get [`MarketBidCost`](@ref) `decremental_offer_curves`."""
get_decremental_offer_curves(value::MarketBidCost) = value.decremental_offer_curves
"""Get [`MarketBidCost`](@ref) `incremental_initial_input`."""
get_incremental_initial_input(value::MarketBidCost) = value.incremental_initial_input
"""Get [`MarketBidCost`](@ref) `decremental_initial_input`."""
get_decremental_initial_input(value::MarketBidCost) = value.decremental_initial_input
"""Get [`MarketBidCost`](@ref) `ancillary_service_offers`."""
get_ancillary_service_offers(value::MarketBidCost) = value.ancillary_service_offers

"""Set [`MarketBidCost`](@ref) `no_load_cost`."""
set_no_load_cost!(value::MarketBidCost, val) = value.no_load_cost = val
"""Set [`MarketBidCost`](@ref) `start_up`."""
set_start_up!(value::MarketBidCost, val) = value.start_up = val
"""Set [`MarketBidCost`](@ref) `shut_down`."""
set_shut_down!(value::MarketBidCost, val) = value.shut_down = val
"""Set [`MarketBidCost`](@ref) `incremental_offer_curves`."""
set_incremental_offer_curves!(value::MarketBidCost, val) =
    value.incremental_offer_curves = val
"""Set [`MarketBidCost`](@ref) `incremental_initial_input`."""
set_incremental_initial_input!(value::MarketBidCost, val) =
    value.incremental_initial_input = val
"""Set [`MarketBidCost`](@ref) `incremental_offer_curves`."""
set_decremental_offer_curves!(value::MarketBidCost, val) =
    value.decremental_offer_curves = val
"""Set [`MarketBidCost`](@ref) `decremental_initial_input`."""
set_decremental_initial_input!(value::MarketBidCost, val) =
    value.decremental_initial_input = val
"""Set [`MarketBidCost`](@ref) `ancillary_service_offers`."""
set_ancillary_service_offers!(value::MarketBidCost, val) =
    value.ancillary_service_offers = val

"""Auxiliary Method for setting up start up that are not multi-start"""
function set_start_up!(value::MarketBidCost, val::Real)
    start_up_multi = single_start_up_to_stages(val)
    set_start_up!(value, start_up_multi)
end

"""
Return `true` if the given [`ProductionVariableCostCurve`](@ref) is a market bid curve
(a `CostCurve{PiecewiseIncrementalCurve}` as used in [`MarketBidCost`](@ref)).
"""
function is_market_bid_curve(curve::ProductionVariableCostCurve)
    return (curve isa CostCurve{PiecewiseIncrementalCurve})
end

"""
Make a CostCurve{PiecewiseIncrementalCurve} suitable for inclusion in a MarketBidCost from a
vector of power values, a vector of marginal costs, a float of initial input, and an optional units system and input at zero.

# Examples
```julia
mbc = make_market_bid_curve([0.0, 100.0, 105.0, 120.0, 130.0], [25.0, 26.0, 28.0, 30.0], 10.0)
mbc2 = make_market_bid_curve([0.0, 100.0, 105.0, 120.0, 130.0], [25.0, 26.0, 28.0, 30.0], 10.0; input_at_zero = 10.0)
mbc3 = make_market_bid_curve([0.0, 100.0, 105.0, 120.0, 130.0], [25.0, 26.0, 28.0, 30.0], 10.0; power_inputs = UnitSystem.NATURAL_UNITS)
```
"""
function make_market_bid_curve(powers::Vector{Float64},
    marginal_costs::Vector{Float64},
    initial_input::Float64;
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS,
    input_at_zero::Union{Nothing, Float64} = nothing)
    if length(powers) == length(marginal_costs) + 1
        fd = PiecewiseStepData(powers, marginal_costs)
        return make_market_bid_curve(
            fd,
            initial_input;
            power_units = power_units,
            input_at_zero,
        )
    else
        throw(
            ArgumentError(
                "Must specify exactly one more number of powers ($(length(powers))) than marginal_costs ($(length(marginal_costs)))",
            ),
        )
    end
end

"""
Make a CostCurve{PiecewiseIncrementalCurve} suitable for inclusion in a MarketBidCost from
the FunctionData that might be used to store such a cost curve in a time series.
"""
function make_market_bid_curve(data::PiecewiseStepData,
    initial_input::Float64;
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS,
    input_at_zero::Union{Nothing, Float64} = nothing)
    cc = CostCurve(IncrementalCurve(data, initial_input, input_at_zero), power_units)
    @assert is_market_bid_curve(cc)
    return cc
end

"""
Auxiliary make market bid curve for timeseries with nothing inputs.
"""
function _make_market_bid_curve(data::PiecewiseStepData;
    initial_input::Union{Nothing, Float64} = nothing,
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS,
    input_at_zero::Union{Nothing, Float64} = nothing)
    cc = CostCurve(IncrementalCurve(data, initial_input, input_at_zero), power_units)
    @assert is_market_bid_curve(cc)
    return cc
end
