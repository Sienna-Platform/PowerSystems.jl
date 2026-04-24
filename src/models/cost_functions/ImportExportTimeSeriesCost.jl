"""
$(TYPEDEF)
$(TYPEDFIELDS)

    ImportExportTimeSeriesCost(import_offer_curves, export_offer_curves, energy_import_weekly_limit, energy_export_weekly_limit, ancillary_service_offers)
    ImportExportTimeSeriesCost(; import_offer_curves, export_offer_curves, energy_import_weekly_limit, energy_export_weekly_limit, ancillary_service_offers)

An operating cost for time-varying imports/exports and ancillary services from neighboring
areas. All offer curve fields are backed by time series data via IS.jl's time-series
ValueCurve types.
For static (non-time-varying) bids, use [`ImportExportCost`](@ref).
"""
mutable struct ImportExportTimeSeriesCost{U <: IS.AbstractUnitSystem} <: OfferCurveCost
    "Import price curves (time series)"
    import_offer_curves::CostCurve{TimeSeriesPiecewiseIncrementalCurve, U}
    "Export price curves (time series)"
    export_offer_curves::CostCurve{TimeSeriesPiecewiseIncrementalCurve, U}
    "Weekly limit on the amount of energy that can be imported, defined in system base p.u-hours."
    energy_import_weekly_limit::Float64
    "Weekly limit on the amount of energy that can be exported, defined in system base p.u-hours."
    energy_export_weekly_limit::Float64
    "Bids to buy or sell ancillary services in the interconnection"
    ancillary_service_offers::Vector{Service}
end

function ImportExportTimeSeriesCost(;
    import_offer_curves,
    export_offer_curves,
    energy_import_weekly_limit = INFINITE_BOUND,
    energy_export_weekly_limit = INFINITE_BOUND,
    ancillary_service_offers = Vector{Service}(),
)
    U_imp = typeof(get_power_units(import_offer_curves))
    U_exp = typeof(get_power_units(export_offer_curves))
    U_imp === U_exp || throw(
        ArgumentError(
            "import_offer_curves and export_offer_curves must share a unit system (got $(U_imp()) vs $(U_exp()))",
        ),
    )
    return ImportExportTimeSeriesCost{U_imp}(
        import_offer_curves,
        export_offer_curves,
        energy_import_weekly_limit,
        energy_export_weekly_limit,
        ancillary_service_offers,
    )
end

"""Get [`ImportExportTimeSeriesCost`](@ref) `import_offer_curves`."""
get_import_offer_curves(value::ImportExportTimeSeriesCost) = value.import_offer_curves
"""Get [`ImportExportTimeSeriesCost`](@ref) `export_offer_curves`."""
get_export_offer_curves(value::ImportExportTimeSeriesCost) = value.export_offer_curves
"""Get [`ImportExportTimeSeriesCost`](@ref) `ancillary_service_offers`."""
get_ancillary_service_offers(value::ImportExportTimeSeriesCost) =
    value.ancillary_service_offers
"""Get [`ImportExportTimeSeriesCost`](@ref) `energy_import_weekly_limit`."""
get_energy_import_weekly_limit(value::ImportExportTimeSeriesCost) =
    value.energy_import_weekly_limit
"""Get [`ImportExportTimeSeriesCost`](@ref) `energy_export_weekly_limit`."""
get_energy_export_weekly_limit(value::ImportExportTimeSeriesCost) =
    value.energy_export_weekly_limit

"""Set [`ImportExportTimeSeriesCost`](@ref) `import_offer_curves`."""
set_import_offer_curves!(value::ImportExportTimeSeriesCost, val) =
    value.import_offer_curves = val
"""Set [`ImportExportTimeSeriesCost`](@ref) `export_offer_curves`."""
set_export_offer_curves!(value::ImportExportTimeSeriesCost, val) =
    value.export_offer_curves = val
"""Set [`ImportExportTimeSeriesCost`](@ref) `ancillary_service_offers`."""
set_ancillary_service_offers!(value::ImportExportTimeSeriesCost, val) =
    value.ancillary_service_offers = val
"""Set [`ImportExportTimeSeriesCost`](@ref) `energy_import_weekly_limit`."""
set_energy_import_weekly_limit!(value::ImportExportTimeSeriesCost, val) =
    value.energy_import_weekly_limit = val
"""Set [`ImportExportTimeSeriesCost`](@ref) `energy_export_weekly_limit`."""
set_energy_export_weekly_limit!(value::ImportExportTimeSeriesCost, val) =
    value.energy_export_weekly_limit = val

"""
Make a time-series-backed `CostCurve{TimeSeriesPiecewiseIncrementalCurve}` from a
`TimeSeriesKey`, suitable for the `import_offer_curves` or `export_offer_curves` field of
an [`ImportExportTimeSeriesCost`](@ref).
"""
function make_import_export_ts_curve(
    ts_key::TimeSeriesKey,
    power_units::IS.AbstractUnitSystem = IS.NaturalUnit(),
)
    vc = TimeSeriesPiecewiseIncrementalCurve(ts_key, nothing, nothing)
    return CostCurve(vc, power_units)
end
