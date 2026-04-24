"""
$(TYPEDEF)
$(TYPEDFIELDS)

    ImportExportCost(import_offer_curves, export_offer_curves, energy_import_weekly_limit, energy_export_weekly_limit, ancillary_service_offers)
    ImportExportCost(; import_offer_curves, export_offer_curves, energy_import_weekly_limit, energy_export_weekly_limit, ancillary_service_offers)

An operating cost for static (non-time-varying) imports/exports and ancillary services
from neighboring areas. The data model employs a `CostCurve{PiecewiseIncrementalCurve}`
with an implied zero cost at zero power. The type parameter `U <: AbstractUnitSystem`
is the shared unit system of the two offer curves (propagated from
`CostCurve`'s `U` parameter); `ImportExportCost{NaturalUnit}` is the default.
For time-varying bids, use [`ImportExportTimeSeriesCost`](@ref).
"""
mutable struct ImportExportCost{U <: IS.AbstractUnitSystem} <: OfferCurveCost
    "Buy Price Curves data to import power"
    import_offer_curves::CostCurve{PiecewiseIncrementalCurve, U}
    "Sell Price Curves data to export power"
    export_offer_curves::CostCurve{PiecewiseIncrementalCurve, U}
    "Weekly limit on the amount of energy that can be imported, defined in system base p.u-hours."
    energy_import_weekly_limit::Float64
    "Weekly limit on the amount of energy that can be exported, defined in system base p.u-hours."
    energy_export_weekly_limit::Float64
    "Bids to buy or sell ancillary services in the interconnection"
    ancillary_service_offers::Vector{Service}
end

function ImportExportCost(;
    import_offer_curves = ZERO_OFFER_CURVE,
    export_offer_curves = ZERO_OFFER_CURVE,
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
    return ImportExportCost{U_imp}(
        import_offer_curves,
        export_offer_curves,
        energy_import_weekly_limit,
        energy_export_weekly_limit,
        ancillary_service_offers,
    )
end

# Constructor for demo purposes; non-functional.
function ImportExportCost(::Nothing)
    ImportExportCost()
end

# Claude:
# Deserialization compatibility: import_offer_curves and export_offer_curves were
# serialized as Nothing in older PSY versions. Substitute ZERO_OFFER_CURVE for each
# Nothing field so that stale JSON files can still be loaded under PSY6.
function ImportExportCost(
    import_offer_curves::Union{Nothing, CostCurve{PiecewiseIncrementalCurve}},
    export_offer_curves::Union{Nothing, CostCurve{PiecewiseIncrementalCurve}},
    energy_import_weekly_limit::Float64,
    energy_export_weekly_limit::Float64,
    ancillary_service_offers::Vector{<:Service},
)
    ImportExportCost(
        something(import_offer_curves, ZERO_OFFER_CURVE),
        something(export_offer_curves, ZERO_OFFER_CURVE),
        energy_import_weekly_limit,
        energy_export_weekly_limit,
        ancillary_service_offers,
    )
end

"""Get [`ImportExportCost`](@ref) `import_offer_curves`."""
get_import_offer_curves(value::ImportExportCost) = value.import_offer_curves
"""Get [`ImportExportCost`](@ref) `export_offer_curves`."""
get_export_offer_curves(value::ImportExportCost) = value.export_offer_curves
"""Get [`ImportExportCost`](@ref) `ancillary_service_offers`."""
get_ancillary_service_offers(value::ImportExportCost) = value.ancillary_service_offers
"""Get [`ImportExportCost`](@ref) `energy_import_weekly_limit`."""
get_energy_import_weekly_limit(value::ImportExportCost) = value.energy_import_weekly_limit
"""Get [`ImportExportCost`](@ref) `energy_export_weekly_limit`."""
get_energy_export_weekly_limit(value::ImportExportCost) = value.energy_export_weekly_limit

"""Set [`ImportExportCost`](@ref) `import_offer_curves`."""
set_import_offer_curves!(value::ImportExportCost, val) =
    value.import_offer_curves = val
"""Set [`ImportExportCost`](@ref) `export_offer_curves`."""
set_export_offer_curves!(value::ImportExportCost, val) =
    value.export_offer_curves = val
"""Set [`ImportExportCost`](@ref) `ancillary_service_offers`."""
set_ancillary_service_offers!(value::ImportExportCost, val) =
    value.ancillary_service_offers = val
"""Set [`ImportExportCost`](@ref) `energy_import_weekly_limit`."""
set_energy_import_weekly_limit!(value::ImportExportCost, val) =
    value.energy_import_weekly_limit = val
"""Set [`ImportExportCost`](@ref) `energy_export_weekly_limit`."""
set_energy_export_weekly_limit!(value::ImportExportCost, val) =
    value.energy_export_weekly_limit = val

function is_import_export_curve(curve::ProductionVariableCostCurve)
    return (curve isa IS.AnyCostCurve{PiecewiseIncrementalCurve}) &&
           iszero(get_initial_input(get_value_curve(curve))) &&
           iszero(get_input_at_zero(get_value_curve(curve))) &&
           iszero(first(get_x_coords(get_value_curve(curve))))
end

# Internal helper: build a static import/export `CostCurve` from validated step data.
function make_import_export_curve(
    curve::PiecewiseStepData,
    power_units::IS.AbstractUnitSystem = IS.NaturalUnit(),
)
    cc = CostCurve(
        PiecewiseIncrementalCurve(curve, 0.0, 0.0),
        power_units,
    )
    @assert is_import_export_curve(cc)
    return cc
end

"""
Make a static `CostCurve{PiecewiseIncrementalCurve}` suitable for the
`import_offer_curves` field of an [`ImportExportCost`](@ref) from vectors of power
breakpoints and prices. `power` must have one more element than `price`, and the resulting
curve must have incremental (convex) slopes.

# Examples
```julia
import_curve = make_import_curve([0.0, 100.0, 105.0, 120.0, 200.0], [5.0, 10.0, 20.0, 40.0])
```
"""
function make_import_curve(
    power::Vector{Float64},
    price::Vector{Float64},
    power_units::IS.AbstractUnitSystem = IS.NaturalUnit(),
)
    curve = PiecewiseStepData(power, price)
    is_convex(curve) ||
        throw(ArgumentError("Import Curve does not have incremental slopes. Check slopes."))
    return make_import_export_curve(curve, power_units)
end

"""
Make a static `CostCurve{PiecewiseIncrementalCurve}` suitable for the
`export_offer_curves` field of an [`ImportExportCost`](@ref) from vectors of power
breakpoints and prices. `power` must have one more element than `price`, and the resulting
curve must have decremental (concave) slopes.

# Examples
```julia
export_curve = make_export_curve([0.0, 100.0, 105.0, 120.0, 200.0], [40.0, 20.0, 10.0, 5.0])
```
"""
function make_export_curve(
    power::Vector{Float64},
    price::Vector{Float64},
    power_units::IS.AbstractUnitSystem = IS.NaturalUnit(),
)
    curve = PiecewiseStepData(power, price)
    is_concave(curve) ||
        throw(ArgumentError("Export Curve does not have decremental slopes. Check slopes."))
    return make_import_export_curve(curve, power_units)
end
