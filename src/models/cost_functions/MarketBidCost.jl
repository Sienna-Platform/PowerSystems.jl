"""
$(TYPEDEF)
$(TYPEDFIELDS)

    MarketBidCost(no_load_cost, start_up, shut_down, incremental_offer_curves, decremental_offer_curves, ancillary_service_offers)
    MarketBidCost(; no_load_cost, start_up, shut_down, incremental_offer_curves, decremental_offer_curves, ancillary_service_offers)
    MarketBidCost(no_load_cost, start_up::Real, shut_down, incremental_offer_curves, decremental_offer_curves, ancillary_service_offers)

An operating cost for static (non-time-varying) market bids of energy and ancillary
services. For time-varying bids, use [`MarketBidTimeSeriesCost`](@ref).
"""
mutable struct MarketBidCost{U <: IS.AbstractUnitSystem} <: OfferCurveCost
    "No load cost"
    no_load_cost::LinearCurve
    "Start-up cost at different stages of the thermal cycle (hot, warm, cold)"
    start_up::StartUpStages
    "Shut-down cost"
    shut_down::LinearCurve
    "Sell Offer Curves data as a [`CostCurve`](@ref) of [`PiecewiseIncrementalCurve`](@ref)"
    incremental_offer_curves::CostCurve{PiecewiseIncrementalCurve, U}
    "Buy Offer Curves data as a [`CostCurve`](@ref) of [`PiecewiseIncrementalCurve`](@ref)"
    decremental_offer_curves::CostCurve{PiecewiseIncrementalCurve, U}
    "Bids for the ancillary services"
    ancillary_service_offers::Vector{Service}
end

const ZERO_OFFER_CURVE = CostCurve(PiecewiseIncrementalCurve(0.0, [0.0, 0.0], [0.0]))

function MarketBidCost(;
    no_load_cost = LinearCurve(0.0),
    start_up = (hot = 0.0, warm = 0.0, cold = 0.0),
    shut_down = LinearCurve(0.0),
    incremental_offer_curves = ZERO_OFFER_CURVE,
    decremental_offer_curves = ZERO_OFFER_CURVE,
    ancillary_service_offers = Vector{Service}(),
)
    U_inc = typeof(get_power_units(incremental_offer_curves))
    U_dec = typeof(get_power_units(decremental_offer_curves))
    U_inc === U_dec || throw(
        ArgumentError(
            "incremental_offer_curves and decremental_offer_curves must share a unit system (got $(U_inc()) vs $(U_dec()))",
        ),
    )
    return MarketBidCost{U_inc}(
        no_load_cost, start_up, shut_down,
        incremental_offer_curves, decremental_offer_curves,
        ancillary_service_offers,
    )
end

# Constructor for demo purposes; non-functional.
function MarketBidCost(::Nothing)
    MarketBidCost(;
        start_up = (hot = START_COST, warm = START_COST, cold = START_COST),
    )
end

"""
Accepts a single `start_up` value to use as the `hot` value, with `warm` and `cold` set to
`0.0`.
"""
function MarketBidCost(
    no_load_cost,
    start_up::Real,
    shut_down;
    incremental_offer_curves = ZERO_OFFER_CURVE,
    decremental_offer_curves = ZERO_OFFER_CURVE,
    ancillary_service_offers = Vector{Service}(),
)
    start_up_multi = single_start_up_to_stages(start_up)
    return MarketBidCost(;
        no_load_cost = no_load_cost,
        start_up = start_up_multi,
        shut_down = shut_down,
        incremental_offer_curves = incremental_offer_curves,
        decremental_offer_curves = decremental_offer_curves,
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
"""Set [`MarketBidCost`](@ref) `decremental_offer_curves`."""
set_decremental_offer_curves!(value::MarketBidCost, val) =
    value.decremental_offer_curves = val
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
    return (curve isa IS.AnyCostCurve{PiecewiseIncrementalCurve})
end

"""
Make a static `CostCurve{PiecewiseIncrementalCurve}` suitable for inclusion in a
`MarketBidCost` from a vector of power values, marginal costs, and initial input.

# Examples
```julia
mbc = make_market_bid_curve([0.0, 100.0, 105.0, 120.0, 130.0], [25.0, 26.0, 28.0, 30.0], 10.0)
```
"""
function make_market_bid_curve(
    powers::Vector{Float64},
    marginal_costs::Vector{Float64},
    initial_input::Float64;
    power_units::IS.AbstractUnitSystem = IS.NaturalUnit(),
    input_at_zero::Union{Nothing, Float64} = nothing,
)
    if length(powers) == length(marginal_costs) + 1
        fd = PiecewiseStepData(powers, marginal_costs)
        return make_market_bid_curve(
            fd,
            initial_input;
            power_units = power_units,
            input_at_zero = input_at_zero,
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
Make a static `CostCurve{PiecewiseIncrementalCurve}` from `PiecewiseStepData`.
"""
function make_market_bid_curve(
    data::PiecewiseStepData,
    initial_input::Float64;
    power_units::IS.AbstractUnitSystem = IS.NaturalUnit(),
    input_at_zero::Union{Nothing, Float64} = nothing,
)
    cc = CostCurve(IncrementalCurve(data, initial_input, input_at_zero), power_units)
    @assert is_market_bid_curve(cc)
    return cc
end
