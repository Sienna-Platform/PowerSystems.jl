"""
$(TYPEDEF)
$(TYPEDFIELDS)

    MarketBidTimeSeriesCost(minimum_energy_offer, start_up, shut_down, incremental_offer_curves, decremental_offer_curves, ancillary_service_offers, incremental_slope, decremental_slope, curve_style, curve_multistep)
    MarketBidTimeSeriesCost(; minimum_energy_offer, start_up, shut_down, incremental_offer_curves, decremental_offer_curves, ancillary_service_offers, incremental_slope, decremental_slope, curve_style, curve_multistep)

An operating cost for time-varying market bids of energy and ancillary services.
All cost curve fields are backed by time series data via IS.jl's time-series ValueCurve types.
For static (non-time-varying) bids, use [`MarketBidCost`](@ref).
"""
mutable struct MarketBidTimeSeriesCost{U <: IS.AbstractUnitSystem} <: OfferCurveCost
    "Minimum-energy offer: cost to operate at minimum stable level, in \$/MWh at the curve's minimum power, stored as submitted. \$/h sources convert at parse (MEO = no-load cost / P_min)."
    minimum_energy_offer::TimeSeriesLinearCurve
    "Key of a time series of `NTuple{3, Float64}` start-up cost stages, resolved to a
    `StartUpStages` at a chosen timestep by `get_start_up(device, cost; start_time)`.
    The element type is in the key's parameter, so a key naming a series of anything but
    3-stage tuples is rejected here rather than at the read."
    start_up::StartUpStagesKey
    "Shut-down cost (time series)"
    shut_down::TimeSeriesLinearCurve
    "Sell Offer Curves data (time series)"
    incremental_offer_curves::CostCurve{<:TimeSeriesPiecewiseIncrementalCurve, U}
    "Buy Offer Curves data (time series)"
    decremental_offer_curves::CostCurve{<:TimeSeriesPiecewiseIncrementalCurve, U}
    "Bids for the ancillary services"
    ancillary_service_offers::Vector{Service}
    "Linear-interpolation flag for the corresponding offer curve; false (default) is the step interpretation. Mutually exclusive with block groups on the same curve."
    incremental_slope::Bool
    "Linear-interpolation flag for the corresponding offer curve; false (default) is the step interpretation. Mutually exclusive with block groups on the same curve."
    decremental_slope::Bool
    "Curve-clearing style for the bid ([`CurveStyles`](@ref)); VARIABLE (default) is a continuous curve with one or more segments, FIXED an all-or-nothing block with a single segment. FIXED is mutually exclusive with linear interpolation (`incremental_slope`/`decremental_slope`). The offer curves are time series keys, so the single-segment rule for FIXED is not checked at construction; it is enforced when the curves are resolved against their data (`get_variable_cost`/`get_decremental_variable_cost` with a `start_time`)."
    curve_style::CurveStyles.T
    "Multi-step block indicator for the bid ([`CurveMultiStep`](@ref)); SINGLE_STEP (default) clears each step independently, MULTI_STEP must be awarded as one block across every step the bid covers. Independent of `curve_style`."
    curve_multistep::CurveMultiStep.T
end

function MarketBidTimeSeriesCost(;
    minimum_energy_offer,
    start_up,
    shut_down,
    incremental_offer_curves,
    decremental_offer_curves,
    ancillary_service_offers = Vector{Service}(),
    incremental_slope = false,
    decremental_slope = false,
    curve_style = CurveStyles.VARIABLE,
    curve_multistep = CurveMultiStep.SINGLE_STEP,
)
    U_inc = typeof(get_power_units(incremental_offer_curves))
    U_dec = typeof(get_power_units(decremental_offer_curves))
    U_inc === U_dec || throw(
        ArgumentError(
            "incremental_offer_curves and decremental_offer_curves must share a unit system (got $(U_inc()) vs $(U_dec()))",
        ),
    )
    check_curve_style_exclusivity(curve_style, incremental_slope, decremental_slope)
    return MarketBidTimeSeriesCost{U_inc}(
        minimum_energy_offer, start_up, shut_down,
        incremental_offer_curves, decremental_offer_curves,
        ancillary_service_offers,
        incremental_slope, decremental_slope, curve_style, curve_multistep,
    )
end

"""Get [`MarketBidTimeSeriesCost`](@ref) `minimum_energy_offer`."""
get_minimum_energy_offer(value::MarketBidTimeSeriesCost) = value.minimum_energy_offer
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
"""Get [`MarketBidTimeSeriesCost`](@ref) `incremental_slope`."""
get_incremental_slope(value::MarketBidTimeSeriesCost) = value.incremental_slope
"""Get [`MarketBidTimeSeriesCost`](@ref) `decremental_slope`."""
get_decremental_slope(value::MarketBidTimeSeriesCost) = value.decremental_slope
"""Get [`MarketBidTimeSeriesCost`](@ref) `curve_style`."""
get_curve_style(value::MarketBidTimeSeriesCost) = value.curve_style
"""Get [`MarketBidTimeSeriesCost`](@ref) `curve_multistep`."""
get_curve_multistep(value::MarketBidTimeSeriesCost) = value.curve_multistep

"""Set [`MarketBidTimeSeriesCost`](@ref) `minimum_energy_offer`."""
set_minimum_energy_offer!(value::MarketBidTimeSeriesCost, val) =
    value.minimum_energy_offer = val
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
"""Set [`MarketBidTimeSeriesCost`](@ref) `incremental_slope`."""
set_incremental_slope!(value::MarketBidTimeSeriesCost, val) =
    value.incremental_slope = val
"""Set [`MarketBidTimeSeriesCost`](@ref) `decremental_slope`."""
set_decremental_slope!(value::MarketBidTimeSeriesCost, val) =
    value.decremental_slope = val
"""Set [`MarketBidTimeSeriesCost`](@ref) `curve_style`."""
set_curve_style!(value::MarketBidTimeSeriesCost, val) =
    value.curve_style = val
"""Set [`MarketBidTimeSeriesCost`](@ref) `curve_multistep`."""
set_curve_multistep!(value::MarketBidTimeSeriesCost, val) =
    value.curve_multistep = val

"""
Make a time-series-backed `CostCurve{<:TimeSeriesPiecewiseIncrementalCurve}` from
`TimeSeriesKey` references, suitable for the `incremental_offer_curves` or
`decremental_offer_curves` field of a [`MarketBidTimeSeriesCost`](@ref).
"""
function make_market_bid_ts_curve(
    ts_key::TimeSeriesKey,
    initial_input_key::Union{Nothing, TimeSeriesKey} = nothing,
    power_units::IS.AbstractUnitSystem = IS.NaturalUnit();
    input_at_zero_key::Union{Nothing, TimeSeriesKey} = nothing,
)
    vc = TimeSeriesPiecewiseIncrementalCurve(ts_key, initial_input_key, input_at_zero_key)
    return CostCurve(vc, power_units)
end
