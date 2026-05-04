"""
$(TYPEDEF)
$(TYPEDFIELDS)

    ImportExportCost(import_offer_curves, export_offer_curves, energy_import_weekly_limit, energy_export_weekly_limits, ancillary_service_offers)
    ImportExportCost(; import_offer_curves, export_offer_curves, energy_export_weekly_limits, ancillary_service_offers)

An operating cost for imports/exports and ancillary services from neighboring areas. The data model
employs a CostCurve{PiecewiseIncrementalCurve} with an implied zero cost at zero power.
"""
mutable struct ImportExportCost <: OfferCurveCost
    "Buy Price Curves data to import power, which can be a time series of [`PiecewiseStepData`] or a
    [`CostCurve`](@ref) of [`PiecewiseIncrementalCurve`](@ref)"
    import_offer_curves::Union{
        Nothing,
        TimeSeriesKey,  # piecewise step data
        CostCurve{PiecewiseIncrementalCurve},
    }
    "Sell Price Curves data to export power, which can be a time series of `PiecewiseStepData` or a
    [`CostCurve`](@ref) of [`PiecewiseIncrementalCurve`](@ref)"
    export_offer_curves::Union{
        Nothing,
        TimeSeriesKey,
        CostCurve{PiecewiseIncrementalCurve},
    }
    "Weekly limit on the amount of energy that can be imported, defined in system base p.u-hours."
    energy_import_weekly_limit::Float64
    "Weekly limit on the amount of energy that can be exported, defined in system base p.u-hours."
    energy_export_weekly_limit::Float64
    "Bids to buy or sell ancillary services in the interconnection"
    ancillary_service_offers::Vector{Service}
end

ImportExportCost(;
    import_offer_curves = nothing,
    export_offer_curves = nothing,
    energy_import_weekly_limit = INFINITE_BOUND,
    energy_export_weekly_limit = INFINITE_BOUND,
    ancillary_service_offers = Vector{Service}(),
) = ImportExportCost(
    import_offer_curves,
    export_offer_curves,
    energy_import_weekly_limit,
    energy_export_weekly_limit,
    ancillary_service_offers,
)

# Constructor for demo purposes; non-functional.
function ImportExportCost(::Nothing)
    ImportExportCost()
end

"""Return the `import_offer_curves` field of [`ImportExportCost`](@ref)."""
get_import_offer_curves(value::ImportExportCost) = value.import_offer_curves
"""Return the `export_offer_curves` field of [`ImportExportCost`](@ref)."""
get_export_offer_curves(value::ImportExportCost) = value.export_offer_curves
"""Return the `ancillary_service_offers` field of [`ImportExportCost`](@ref)."""
get_ancillary_service_offers(value::ImportExportCost) = value.ancillary_service_offers
"""Return the `energy_import_weekly_limit` field of [`ImportExportCost`](@ref)."""
get_energy_import_weekly_limit(value::ImportExportCost) = value.energy_import_weekly_limit
"""Return the `energy_export_weekly_limits` field of [`ImportExportCost`](@ref)."""
get_energy_export_weekly_limit(value::ImportExportCost) = value.energy_export_weekly_limit

"""Set the `import_offer_curves` field of [`ImportExportCost`](@ref)."""
set_import_offer_curves!(value::ImportExportCost, val) =
    value.import_offer_curves = val
"""Set the `export_offer_curves` field of [`ImportExportCost`](@ref)."""
set_export_offer_curves!(value::ImportExportCost, val) =
    value.export_offer_curves = val
"""Set the `ancillary_service_offers` field of [`ImportExportCost`](@ref)."""
set_ancillary_service_offers!(value::ImportExportCost, val) =
    value.ancillary_service_offers = val
"""Set the `energy_import_weekly_limit` field of [`ImportExportCost`](@ref)."""
set_energy_import_weekly_limit!(value::ImportExportCost, val) =
    value.energy_import_weekly_limit = val
"""Set the `energy_export_weekly_limits` field of [`ImportExportCost`](@ref)."""
set_energy_export_weekly_limit!(value::ImportExportCost, val) =
    value.energy_export_weekly_limit = val

function is_import_export_curve(curve::ProductionVariableCostCurve)
    return (curve isa CostCurve{PiecewiseIncrementalCurve}) &&
           iszero(get_initial_input(get_value_curve(curve))) &&
           iszero(get_input_at_zero(get_value_curve(curve))) &&
           iszero(first(get_x_coords(get_value_curve(curve))))
end

"""
Make a CostCurve{PiecewiseIncrementalCurve} suitable for inclusion in a ImportExportCost from
the FunctionData that might be used to store such a cost curve in a time series.
"""
function make_import_export_curve(
    curve::PiecewiseStepData,
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS,
)
    cc = CostCurve(
        PiecewiseIncrementalCurve(curve, 0.0, 0.0),
        power_units,
    )
    @assert is_import_export_curve(cc)
    return cc
end

"""
Make a CostCurve{PiecewiseIncrementalCurve} suitable for inclusion in an ImportExportCost from a
vector of power values, a vector of costs, and an optional units system.

# Examples
```julia
iec = make_import_export_curve([0.0, 100.0, 105.0, 120.0, 130.0], [25.0, 26.0, 28.0, 30.0])
iec1 = make_import_export_curve([0.0, 100.0, 105.0, 120.0, 130.0], [25.0, 26.0, 28.0, 30.0]; power_units = UnitSystem.NATURAL_UNITS)
```
"""
function make_import_export_curve(
    powers::Vector{Float64},
    prices::Vector{Float64},
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS,
)
    valid_data = (length(powers) == length(prices) + 1)
    if valid_data
        curve = PiecewiseStepData(powers, prices)
        return make_import_export_curve(
            curve,
            power_units,
        )
    else
        throw(
            ArgumentError(
                "Must specify exactly one more number of powers points than prices",
            ),
        )
    end
end

function make_import_export_curve(
    max_power::Float64,
    price::Float64,
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS,
)
    return make_import_export_curve(
        [0.0, max_power],
        [price],
        power_units,
    )
end

function make_import_export_curve(;
    powers,
    prices,
    power_units = UnitSystem.NATURAL_UNITS,
)
    return make_import_export_curve(
        powers,
        prices,
        power_units,
    )
end

"""
Make an import CostCurve{PiecewiseIncrementalCurve} suitable for inclusion in an ImportExportCost from a
vector of power values, a vector of costs, and an optional units system.

# Examples
```julia
ic = make_import_curve([0.0, 100.0, 105.0, 120.0, 130.0], [25.0, 26.0, 28.0, 30.0])
ic1 = make_import_curve(power = [0.0, 100.0, 105.0, 120.0, 130.0], price = [25.0, 26.0, 28.0, 30.0], power_units = UnitSystem.NATURAL_UNITS)
```
"""
function make_import_curve(
    power::Vector{Float64},
    price::Vector{Float64},
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS,
)
    curve = PiecewiseStepData(power, price)
    convex = is_convex(curve)
    if convex
        return make_import_export_curve(
            power,
            price,
            power_units,
        )
    else
        throw(
            ArgumentError(
                "Import Curve does not have incremental slopes. Check slopes.",
            ),
        )
    end
end

"""
Make a CostCurve{PiecewiseIncrementalCurve} from suitable for inclusion in an ImportExportCost from
a max import power, a single price and an optional units system. Assume the minimum import is 0.0

# Examples
```julia
ic = make_import_curve(power = 100.0, price = 25.0)
ic1 = make_import_curve(power = 100.0, price = 25.0, power_units = UnitSystem.NATURAL_UNITS)
```
"""
function make_import_curve(
    power::Float64,
    price::Float64,
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS,
)
    return make_import_export_curve(
        power,
        price,
        power_units,
    )
end

function make_import_curve(;
    power,
    price,
    power_units = UnitSystem.NATURAL_UNITS,
)
    return make_import_curve(
        power,
        price,
        power_units,
    )
end

"""
Make an export CostCurve{PiecewiseIncrementalCurve} suitable for inclusion in an ImportExportCost from a
vector of power values, a vector of costs, and an optional units system.

# Examples
```julia
ec = make_export_curve([0.0, 100.0, 105.0, 120.0, 130.0], [30.0, 28.0, 26.0, 25.0])
ec1 = make_export_curve(power = [0.0, 100.0, 105.0, 120.0, 130.0], price = [30.0, 28.0, 26.0, 25.0], power_units = UnitSystem.NATURAL_UNITS)
```
"""
function make_export_curve(
    power::Vector{Float64},
    price::Vector{Float64},
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS,
)
    curve = PiecewiseStepData(power, price)
    concave = is_concave(curve)
    if concave
        return make_import_export_curve(
            power,
            price,
            power_units,
        )
    else
        throw(
            ArgumentError(
                "Export Curve does not have decremental slopes. Check slopes.",
            ),
        )
    end
end

"""
Make a CostCurve{PiecewiseIncrementalCurve} from suitable for inclusion in an ImportExportCost from a
a max export power, a single price and an optional units system. Assume the minimum export is 0.0.

# Examples
```julia
ec = make_export_curve(power = 100.0, price = 30.0)
ec1 = make_export_curve(power = 100.0, price = 30.0, power_units = UnitSystem.NATURAL_UNITS)
```
"""
function make_export_curve(
    power::Float64,
    price::Float64,
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS,
)
    return make_import_export_curve(
        power,
        price,
        power_units,
    )
end

function make_export_curve(;
    power,
    price,
    power_units = UnitSystem.NATURAL_UNITS,
)
    return make_export_curve(
        power,
        price,
        power_units,
    )
end
