"""
    OfferCurveCost

Abstract type for representing cost curves used in market bidding and offer mechanisms.

This serves as the base type for various cost curve implementations including:
- [`MarketBidCost`](@ref)
- [`ImportExportCost`](@ref)

All concrete subtypes must implement the required interface methods for cost calculation
and curve evaluation in power system market operations.
"""
abstract type OfferCurveCost <: OperationalCost end

"""
Throws ArgumentError if a `FIXED` `curve_style` is combined with linear interpolation on
either offer curve: an all-or-nothing block has no curve to interpolate. Shared by the
[`MarketBidCost`](@ref) and [`MarketBidTimeSeriesCost`](@ref) constructors.
"""
function check_curve_style_exclusivity(
    curve_style::CurveStyles.Value,
    incremental_slope::Bool,
    decremental_slope::Bool,
)
    if curve_style == CurveStyles.FIXED && (incremental_slope || decremental_slope)
        throw(
            ArgumentError(
                "curve_style FIXED is mutually exclusive with incremental_slope/decremental_slope: an all-or-nothing block has no curve to interpolate",
            ),
        )
    end
    return nothing
end

"""Number of price segments in a static market-bid offer curve."""
_offer_curve_segment_count(curve::CostCurve{PiecewiseIncrementalCurve}) =
    length(get_y_coords(get_function_data(get_value_curve(curve))))

"""
Throws ArgumentError if `curve_style` is `FIXED` and any of `curves` has more than one
segment. A fixed block is all-or-nothing, one quantity at one price, so a multi-segment
offer curve has no meaning for it. `field` names the offer curve in the message and
`context` locates the curve for the time-series case, where the check runs at resolution
rather than construction (see [`MarketBidTimeSeriesCost`](@ref)).
"""
function check_fixed_single_segment(
    curve_style::CurveStyles.Value,
    curves,
    field::AbstractString;
    context::AbstractString = "",
)
    curve_style == CurveStyles.FIXED || return nothing
    for (i, curve) in enumerate(curves)
        n = _offer_curve_segment_count(curve)
        n == 1 && continue
        location = isempty(context) ? "" : " (step $i of the window starting $context)"
        throw(
            ArgumentError(
                "curve_style FIXED requires a single-segment $field, got $n segments$location: " *
                "a fixed block is all-or-nothing over one quantity at one price",
            ),
        )
    end
    return nothing
end

check_fixed_single_segment(
    curve_style::CurveStyles.Value,
    curve::CostCurve{PiecewiseIncrementalCurve},
    field::AbstractString;
    context::AbstractString = "",
) = check_fixed_single_segment(curve_style, (curve,), field; context = context)
