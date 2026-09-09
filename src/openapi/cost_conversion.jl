# PO (OpenAPI model) → PSY cost/curve conversion: one recursive `convert_cost` overloaded
# across every PO cost/curve type. Unmapped variants error rather than yielding a placeholder.
#
# PO structs are `OpenAPI.jl`-generated kwarg structs, not PSY components, so they are read
# with dot access — the "getters, not dot access" rule does not apply to them.

"""Unwrap any `OpenAPI.jl` oneOf wrapper, whose sole `value` field holds the resolved
variant chosen by the document's discriminator."""
convert_cost(w::OpenAPI.OneOfAPIModel) = convert_cost(w.value)
convert_cost(w::OpenAPI.OneOfAPIModel, store) = convert_cost(w.value, store)

# ── Ambient import store, for association-id-bearing costs reached below a GENERATED
# per-device `from_openapi` call site ────────────────────────────────────────────────
# A generated `from_openapi(po::PO.<Device>, refs, unit)` (`src/generate_structs.jl`'s
# `expr = "convert_cost(po.$po_name)::$bare"`) calls `convert_cost` with exactly one
# positional argument, several frames above `MarketBidTimeSeriesCost`/a time-series-backed
# `FuelCurve`. Regenerating every device converter to thread a `store` through is out of
# scope, so `from_openapi(::Type{System}, doc)` binds the adopted store here for the
# duration of the component pass (`_with_import_store`), and the 1-arg `convert_cost`
# overloads below pull it back out via `_current_import_store`. A hand-written converter
# that already receives `refs` (e.g. `Source`) should call the explicit-`store` form
# instead — see `_convert_source_operation_cost`.
#
# The scope is PSY's own. IS used to keep one for `TimeSeriesKey` deserialization, but a
# serialized key now carries its time series and element types alongside the id and
# rebuilds itself without a catalog. Only this wire format still names a series by a bare
# `association_id`, so only this import still needs a store to resolve one against.
const _IMPORT_STORE = Base.ScopedValues.ScopedValue{IS.Store}()

"""No sidecar was adopted, so there is nothing to bind; a document that then names a
time-series-backed cost fails in `_current_import_store`."""
_with_import_store(f, ::Nothing) = f()

"""Bind `store` for the duration of `f()`. `ScopedValue`-based, so a nested import and a
task spawned inside one both see the innermost binding."""
_with_import_store(f, store::IS.Store) =
    Base.ScopedValues.with(f, _IMPORT_STORE => store)

function _current_import_store()
    store = Base.ScopedValues.get(_IMPORT_STORE)
    isnothing(store) && error(
        "convert_cost: the document names a time-series-backed cost, but no time series " *
        "store is bound — either this ran outside an active from_openapi(System, doc) " *
        "import, or no time_series_storage_path sidecar was adopted for it",
    )
    return something(store)
end

"""Fallback: a PO type that carries no association id converts identically whether or not a
store is available for this call."""
convert_cost(po, ::Any) = convert_cost(po)

"""A required PO field read as `nothing` is malformed input."""
_require(::Nothing, context::AbstractString) =
    error("convert_cost: $context is required and missing")
_require(x, ::AbstractString) = x

"""
Call `f` with the unit marker the document string `s` names.

Higher-order rather than marker-returning: the marker is a type parameter of
`CostCurve`/`FuelCurve`, so returning it from a runtime string would hand the caller a
`Union{NaturalUnit, DeviceBaseUnit}` and make the construction dynamic. Calling `f` inside each
branch specializes the whole construction on one concrete marker.
"""
_with_power_units(::Any, ::Nothing) =
    error("convert_cost: power_units is required and missing")
function _with_power_units(f, s::AbstractString)
    s == "NATURAL_UNITS" && return f(NaturalUnit())
    s == "COMPONENT_BASE" && return f(DeviceBaseUnit())
    error(
        "convert_cost: unmapped power_units \"$s\" — expected one of " *
        "NATURAL_UNITS, COMPONENT_BASE",
    )
end

# ── FunctionData ────────────────────────────────────────────────────────────────

convert_cost(fd::IC.LinearFunctionData) =
    LinearFunctionData(fd.proportional_term, fd.constant_term)
convert_cost(fd::IC.QuadraticFunctionData) =
    QuadraticFunctionData(fd.quadratic_term, fd.proportional_term, fd.constant_term)
# `points` is generated as a bare `Vector`, so converting once restores inference for the loop.
function convert_cost(fd::IC.PiecewiseLinearData)
    points = convert(Vector{IC.XYCoords}, fd.points)
    return PiecewiseLinearData([(x = p.x, y = p.y) for p in points])
end
convert_cost(fd::IC.PiecewiseStepData) = PiecewiseStepData(fd.x_coords, fd.y_coords)
# Catch-all for every PO type, not just FunctionData: a PO cost type with no converter
# lands here, so the message must not claim to know what kind of variant it got.
convert_cost(fd) = error("convert_cost: unmapped variant $(typeof(fd))")

# ── ValueCurve ──────────────────────────────────────────────────────────────────

convert_cost(vc::PC.InputOutputCurve) =
    InputOutputCurve(convert_cost(vc.function_data), vc.input_at_zero)
convert_cost(vc::PC.IncrementalCurve) =
    IncrementalCurve(convert_cost(vc.function_data), vc.initial_input, vc.input_at_zero)
convert_cost(vc::PC.AverageRateCurve) =
    AverageRateCurve(convert_cost(vc.function_data), vc.initial_input, vc.input_at_zero)

# ── vom_cost / startup_fuel_offtake: always a LINEAR InputOutputCurve ──────────

_as_linear_curve(curve::InputOutputCurve{LinearFunctionData}) = curve
_as_linear_curve(curve) = error(
    "convert_cost: vom_cost must be a LINEAR InputOutputCurve, got " *
    "InputOutputCurve{$(typeof(get_function_data(curve)))}",
)

_vom_cost(::Nothing) = LinearCurve(0.0)
_vom_cost(io::PC.InputOutputCurve) = _as_linear_curve(convert_cost(io))

# ── fuel_cost: a bare number ───────────────────────────────────────────────────

convert_cost(v::Real) = Float64(v)

# ── Time-series FunctionData/ValueCurve — need the adopted store to resolve an
# association_id to a TimeSeriesKey ────────────────────────────────────────────

"""The `TimeSeriesKey` the wire type's required `association_id` names. `what` names the
wire type for the error a missing id raises."""
_function_data_key(fd, store, what::AbstractString) =
    IS.get_time_series_key(store, _require(fd.association_id, "$what.association_id"))

convert_cost(fd::IC.TimeSeriesLinearFunctionData, store) =
    TimeSeriesFunctionData{LinearFunctionData}(
        _function_data_key(fd, store, "TimeSeriesLinearFunctionData"),
    )
convert_cost(fd::IC.TimeSeriesLinearFunctionData) =
    convert_cost(fd, _current_import_store())

convert_cost(fd::IC.TimeSeriesQuadraticFunctionData, store) =
    TimeSeriesFunctionData{QuadraticFunctionData}(
        _function_data_key(fd, store, "TimeSeriesQuadraticFunctionData"),
    )
convert_cost(fd::IC.TimeSeriesQuadraticFunctionData) =
    convert_cost(fd, _current_import_store())

convert_cost(fd::IC.TimeSeriesPiecewiseLinearData, store) =
    TimeSeriesFunctionData{PiecewiseLinearData}(
        _function_data_key(fd, store, "TimeSeriesPiecewiseLinearData"),
    )
convert_cost(fd::IC.TimeSeriesPiecewiseLinearData) =
    convert_cost(fd, _current_import_store())

convert_cost(fd::IC.TimeSeriesPiecewiseStepData, store) =
    TimeSeriesFunctionData{PiecewiseStepData}(
        _function_data_key(fd, store, "TimeSeriesPiecewiseStepData"),
    )
convert_cost(fd::IC.TimeSeriesPiecewiseStepData) = convert_cost(fd, _current_import_store())

"""`nothing` stays `nothing`; a wire association id resolves against `store`."""
_resolve_optional_key(::Any, ::Nothing) = nothing
_resolve_optional_key(store, id::Integer) = IS.get_time_series_key(store, id)

"""Wire representation of [`CurveStyles`](@ref): a plain integer (0/1/2), deliberately not
the string-enum convention used elsewhere in the schemas — see `curve_style` on
`MarketBidCost`/`MarketBidTimeSeriesCost`."""
function _curve_style_from_wire(id::Integer)
    if id ∉ (0, 1, 2)
        throw(
            ArgumentError(
                "convert_cost: curve_style $id is not a valid CurveStyles value; " *
                "expected 0 (CURVE), 1 (FIXED), or 2 (VARIABLE)",
            ),
        )
    end
    return CurveStyles(Int(id))
end

convert_cost(vc::PC.TimeSeriesInputOutputCurve, store) =
    TimeSeriesInputOutputCurve(convert_cost(vc.function_data, store), vc.input_at_zero)
convert_cost(vc::PC.TimeSeriesInputOutputCurve) = convert_cost(vc, _current_import_store())

convert_cost(vc::PC.TimeSeriesIncrementalCurve, store) =
    TimeSeriesIncrementalCurve(
        convert_cost(vc.function_data, store),
        _resolve_optional_key(store, vc.initial_input_association_id),
        _resolve_optional_key(store, vc.input_at_zero_association_id),
    )
convert_cost(vc::PC.TimeSeriesIncrementalCurve) = convert_cost(vc, _current_import_store())

convert_cost(vc::PC.TimeSeriesAverageRateCurve, store) =
    TimeSeriesAverageRateCurve(
        convert_cost(vc.function_data, store),
        _resolve_optional_key(store, vc.initial_input_association_id),
        _resolve_optional_key(store, vc.input_at_zero_association_id),
    )
convert_cost(vc::PC.TimeSeriesAverageRateCurve) = convert_cost(vc, _current_import_store())

# ── ProductionVariableCostCurve: CostCurve / FuelCurve ─────────────────────────

function convert_cost(c::PC.CostCurve)
    value_curve = convert_cost(_require(c.value_curve, "CostCurve.value_curve"))
    vom_cost = _vom_cost(c.vom_cost)
    return _with_power_units(c.power_units) do units
        CostCurve(; value_curve = value_curve, power_units = units, vom_cost = vom_cost)
    end
end

"""Store-aware form: `value_curve` may be time-series-backed (`MarketBidTimeSeriesCost`'s
`incremental_offer_curves`/`decremental_offer_curves`, `ImportExportTimeSeriesCost`'s
`import_offer_curves`/`export_offer_curves`)."""
function convert_cost(c::PC.CostCurve, store)
    value_curve = convert_cost(_require(c.value_curve, "CostCurve.value_curve"), store)
    vom_cost = _vom_cost(c.vom_cost)
    return _with_power_units(c.power_units) do units
        CostCurve(; value_curve = value_curve, power_units = units, vom_cost = vom_cost)
    end
end

"""Resolve `FuelCurve`'s two mutually exclusive fields. `store` is unused on the
scalar branch, so a plain `fuel_cost` converts with no active import at all."""
_fuel_cost_fields(::Any, fuel_cost::Real, ::Nothing) = (Float64(fuel_cost), nothing)
_fuel_cost_fields(store, ::Nothing, fuel_cost_time_series::Integer) =
    (nothing, IS.get_time_series_key(store, fuel_cost_time_series))
_fuel_cost_fields(::Any, ::Nothing, ::Nothing) = error(
    "convert_cost: FuelCurve requires exactly one of fuel_cost or fuel_cost_time_series",
)
_fuel_cost_fields(::Any, ::Real, ::Integer) = error(
    "convert_cost: FuelCurve carries both fuel_cost and fuel_cost_time_series — exactly " *
    "one is expected",
)

function convert_cost(f::PC.FuelCurve, store)
    value_curve = convert_cost(_require(f.value_curve, "FuelCurve.value_curve"), store)
    vom_cost = _vom_cost(f.vom_cost)
    fuel_cost, fuel_cost_time_series =
        _fuel_cost_fields(store, f.fuel_cost, f.fuel_cost_time_series)
    return _with_power_units(f.power_units) do units
        FuelCurve(;
            value_curve = value_curve,
            power_units = units,
            fuel_cost = fuel_cost,
            fuel_cost_time_series = fuel_cost_time_series,
            vom_cost = vom_cost,
        )
    end
end

"""Resolve `FuelCurve`'s two mutually exclusive fields for the ambient 1-arg form: the
store is pulled lazily, only inside the `fuel_cost_time_series` branch, so a plain scalar
`fuel_cost` still needs no active import bound at all."""
_fuel_cost_fields_ambient(fuel_cost::Real, ::Nothing) = (Float64(fuel_cost), nothing)
_fuel_cost_fields_ambient(::Nothing, fuel_cost_time_series::Integer) =
    (nothing, IS.get_time_series_key(_current_import_store(), fuel_cost_time_series))
_fuel_cost_fields_ambient(::Nothing, ::Nothing) = error(
    "convert_cost: FuelCurve requires exactly one of fuel_cost or fuel_cost_time_series",
)
_fuel_cost_fields_ambient(::Real, ::Integer) = error(
    "convert_cost: FuelCurve carries both fuel_cost and fuel_cost_time_series — exactly " *
    "one is expected",
)

"""1-arg ambient form for callers with no `store` in hand (the generated per-device
`from_openapi` methods — see `_current_import_store`). `value_curve` converts through the
plain 1-arg `convert_cost` chain, exactly like `CostCurve`'s 1-arg form — a time-series-backed
variant pulls the ambient store itself via its own 1-arg method, regardless of which form
`fuel_cost` takes. `fuel_cost`/`fuel_cost_time_series` resolve the same way: the store is
only fetched when `fuel_cost_time_series` is actually present, so a scalar `fuel_cost` with a
non-time-series value curve still converts with no active import bound at all."""
function convert_cost(f::PC.FuelCurve)
    value_curve = convert_cost(_require(f.value_curve, "FuelCurve.value_curve"))
    vom_cost = _vom_cost(f.vom_cost)
    fuel_cost, fuel_cost_time_series =
        _fuel_cost_fields_ambient(f.fuel_cost, f.fuel_cost_time_series)
    return _with_power_units(f.power_units) do units
        FuelCurve(;
            value_curve = value_curve,
            power_units = units,
            fuel_cost = fuel_cost,
            fuel_cost_time_series = fuel_cost_time_series,
            vom_cost = vom_cost,
        )
    end
end

_optional_cost_curve(::Nothing) = zero(CostCurve)
_optional_cost_curve(c::PC.CostCurve) = convert_cost(c)

# ── Offer curves: import/export bids and reserve demand curves ─────────────────
# PSY types these fields as `CostCurve{PiecewiseIncrementalCurve}`, so a document carrying
# any other curve shape is malformed. Saying which field is wrong beats the conversion
# error the constructor would raise.

_as_piecewise_incremental(cost::CostCurve{PiecewiseIncrementalCurve}, ::AbstractString) =
    cost
_as_piecewise_incremental(cost::CostCurve, context::AbstractString) = error(
    "convert_cost: $context must be a PiecewiseIncrementalCurve CostCurve, " *
    "got CostCurve{$(typeof(get_value_curve(cost)))}",
)

"""An unoffered side is written as an absent curve; `ZERO_OFFER_CURVE` is how PSY spells it."""
_offer_curve(::Nothing, ::AbstractString) = ZERO_OFFER_CURVE
_offer_curve(c::PC.CostCurve, context::AbstractString) =
    _as_piecewise_incremental(convert_cost(c), context)

# ── start_up: a bare number, or a multi-stage / charge-discharge breakdown ────

convert_cost(s::PC.StartUpStages) = (hot = s.hot, warm = s.warm, cold = s.cold)

convert_cost(s::PC.StorageCostStartUpOneOf) = (charge = s.charge, discharge = s.discharge)

# ── Operation-cost containers emitted by the parser ──────────────────────────

function convert_cost(po::PC.ThermalGenerationCost)
    return ThermalGenerationCost(;
        variable_operation_cost = convert_cost(
            _require(
                po.variable_operation_cost,
                "ThermalGenerationCost.variable_operation_cost",
            ),
        ),
        fixed = po.fixed,
        start_up = convert_cost(_require(po.start_up, "ThermalGenerationCost.start_up")),
        shut_down = po.shut_down,
    )
end

function convert_cost(po::PC.RenewableGenerationCost)
    return RenewableGenerationCost(;
        variable_operation_cost = convert_cost(
            _require(
                po.variable_operation_cost,
                "RenewableGenerationCost.variable_operation_cost",
            ),
        ),
        curtailment_cost = _optional_cost_curve(po.curtailment_cost),
        fixed = po.fixed,
    )
end

function convert_cost(po::PC.HydroGenerationCost)
    return HydroGenerationCost(;
        variable_operation_cost = convert_cost(
            _require(
                po.variable_operation_cost,
                "HydroGenerationCost.variable_operation_cost",
            ),
        ),
        fixed = po.fixed,
    )
end

function convert_cost(po::PC.LoadCost)
    return LoadCost(;
        variable_operation_cost = convert_cost(
            _require(po.variable_operation_cost, "LoadCost.variable_operation_cost"),
        ),
        fixed = po.fixed,
    )
end

"""
Static market bid. The document's `ancillary_service_offers` ids resolve to `Service`
objects only after every service is imported, so this conversion leaves the vector empty;
`_load_market_bid_service_offers!` fills it in a document-level pass.
"""
function convert_cost(po::PC.MarketBidCost)
    return MarketBidCost(;
        minimum_energy_offer = convert_cost(
            _require(po.minimum_energy_offer, "MarketBidCost.minimum_energy_offer"),
        ),
        start_up = convert_cost(_require(po.start_up, "MarketBidCost.start_up")),
        shut_down = convert_cost(_require(po.shut_down, "MarketBidCost.shut_down")),
        incremental_offer_curves = convert_cost(
            _require(po.incremental_offer_curves, "MarketBidCost.incremental_offer_curves"),
        ),
        decremental_offer_curves = convert_cost(
            _require(po.decremental_offer_curves, "MarketBidCost.decremental_offer_curves"),
        ),
        incremental_slope = _require(
            po.incremental_slope,
            "MarketBidCost.incremental_slope",
        ),
        decremental_slope = _require(
            po.decremental_slope,
            "MarketBidCost.decremental_slope",
        ),
        curve_style = _curve_style_from_wire(
            _require(po.curve_style, "MarketBidCost.curve_style"),
        ),
    )
end

"""
Import/export bids from a neighbouring area. `ancillary_service_offers` has no counterpart in
the `PC.ImportExportCost` schema, so the export drops it (see `convert_cost_to_openapi`) and
this returns a cost with none. An absent offer curve means that side is not offered and comes
back as `ZERO_OFFER_CURVE`.
"""
function convert_cost(po::PC.ImportExportCost)
    return ImportExportCost(;
        import_offer_curves = _offer_curve(
            po.import_offer_curves,
            "ImportExportCost.import_offer_curves",
        ),
        export_offer_curves = _offer_curve(
            po.export_offer_curves,
            "ImportExportCost.export_offer_curves",
        ),
        energy_import_weekly_limit = _require(
            po.energy_import_weekly_limit,
            "ImportExportCost.energy_import_weekly_limit",
        ),
        energy_export_weekly_limit = _require(
            po.energy_export_weekly_limit,
            "ImportExportCost.energy_export_weekly_limit",
        ),
    )
end

"""
Time-varying market bid. Mirrors `convert_cost(::PC.MarketBidCost)`: `ancillary_service_offers`
is left empty here too. Needs `store` for `start_up` (a wire association id resolving to the
`TimeSeriesKey` `MarketBidTimeSeriesCost.start_up` carries) and for the time-series-backed
offer curves.
"""
function convert_cost(po::PC.MarketBidTimeSeriesCost, store)
    return MarketBidTimeSeriesCost(;
        minimum_energy_offer = convert_cost(
            _require(
                po.minimum_energy_offer,
                "MarketBidTimeSeriesCost.minimum_energy_offer",
            ), store,
        ),
        start_up = IS.get_time_series_key(
            store,
            Int(
                _require(
                    po.start_up_association_id,
                    "MarketBidTimeSeriesCost.start_up_association_id",
                ),
            ),
        ),
        shut_down = convert_cost(
            _require(po.shut_down, "MarketBidTimeSeriesCost.shut_down"), store,
        ),
        incremental_offer_curves = convert_cost(
            _require(
                po.incremental_offer_curves,
                "MarketBidTimeSeriesCost.incremental_offer_curves",
            ),
            store,
        ),
        decremental_offer_curves = convert_cost(
            _require(
                po.decremental_offer_curves,
                "MarketBidTimeSeriesCost.decremental_offer_curves",
            ),
            store,
        ),
        incremental_slope = _require(
            po.incremental_slope, "MarketBidTimeSeriesCost.incremental_slope",
        ),
        decremental_slope = _require(
            po.decremental_slope, "MarketBidTimeSeriesCost.decremental_slope",
        ),
        curve_style = _curve_style_from_wire(
            _require(po.curve_style, "MarketBidTimeSeriesCost.curve_style"),
        ),
    )
end
convert_cost(po::PC.MarketBidTimeSeriesCost) = convert_cost(po, _current_import_store())

"""
Time-varying import/export bids. Mirrors `convert_cost(::PC.ImportExportCost)`, except the
offer curves are time-series-backed (need `store`). `energy_import_weekly_limit`/
`energy_export_weekly_limit` are MWh on both sides of the wire, so they need no scaling;
`base_power` is accepted only to match `_convert_source_operation_cost`'s uniform dispatch
across every admissible `Source.operation_cost` variant.
"""
function convert_cost(po::PC.ImportExportTimeSeriesCost, store, _base_power::Real)
    return ImportExportTimeSeriesCost(;
        import_offer_curves = convert_cost(
            _require(
                po.import_offer_curves, "ImportExportTimeSeriesCost.import_offer_curves",
            ),
            store,
        ),
        export_offer_curves = convert_cost(
            _require(
                po.export_offer_curves, "ImportExportTimeSeriesCost.export_offer_curves",
            ),
            store,
        ),
        energy_import_weekly_limit = _require(
            po.energy_import_weekly_limit,
            "ImportExportTimeSeriesCost.energy_import_weekly_limit",
        ),
        energy_export_weekly_limit = _require(
            po.energy_export_weekly_limit,
            "ImportExportTimeSeriesCost.energy_export_weekly_limit",
        ),
    )
end

"""
`Source.operation_cost` (`PO.SourceOperationCost`) is the one place `ImportExportCost`,
`ImportExportTimeSeriesCost`, and `MarketBidTimeSeriesCost` are all admissible, and `Source`'s
hand-written `from_openapi` (unlike a generated per-device converter) already receives `refs`,
so it resolves both `store` and `base_power` up front and calls this rather than the ambient
1-arg path.
"""
_convert_source_operation_cost(w::PO.SourceOperationCost, store, base_power::Real) =
    _convert_source_operation_cost(w.value, store, base_power)
_convert_source_operation_cost(po::PC.ImportExportCost, ::Any, ::Real) = convert_cost(po)
_convert_source_operation_cost(po::PC.MarketBidTimeSeriesCost, store, ::Real) =
    convert_cost(po, store)
_convert_source_operation_cost(po::PC.ImportExportTimeSeriesCost, store, base_power::Real) =
    convert_cost(po, store, base_power)

function convert_cost(po::PC.HydroReservoirCost)
    return HydroReservoirCost(;
        level_shortage_cost = po.level_shortage_cost,
        level_surplus_cost = po.level_surplus_cost,
        spillage_cost = po.spillage_cost,
    )
end

function convert_cost(po::PC.StorageCost)
    return StorageCost(;
        charge_variable_cost = _optional_cost_curve(po.charge_variable_cost),
        discharge_variable_cost = _optional_cost_curve(po.discharge_variable_cost),
        fixed = po.fixed,
        start_up = convert_cost(_require(po.start_up, "StorageCost.start_up")),
        shut_down = po.shut_down,
        energy_shortage_cost = po.energy_shortage_cost,
        energy_surplus_cost = po.energy_surplus_cost,
    )
end

# ── Operating Reserve Demand Curve ─────────────────────────────────────────────
# A reserve's `variable` is never a FuelCurve; PSY stores `CostCurve{PiecewiseIncrementalCurve}`.

"""Convert a reserve's `variable` field; `nothing` means no demand curve is defined."""
convert_reserve_variable(po::Union{Nothing, PC.CostCurve}) =
    _offer_curve(po, "a reserve demand curve")

# ── LossCurve ⇄ OpenAPI ────────────────────────────────────────────────────────
# The OpenAPI schemas have no `LossCurve`: a document's loss field is a bare
# `ValueCurve` (`$ref: InputOutputCurve` / `TwoTerminalLoss`) with nowhere to record a
# power basis. PSY's loss fields are `LossCurve`s, which carry one, so the two
# directions are asymmetric until the schemas gain the type.

"""
Wrap a document's bare loss curve as a `LossCurve` on the natural-units basis.

The document carries no basis for a loss field, so one is supplied here rather than
guessed per call site: `NaturalUnit` is what every current producer writes and what the
schema's own `UnitSystem` default names. When the schemas gain a `LossCurve` with an
explicit `power_units`, this reads it instead of synthesizing it.
"""
loss_curve_from_openapi(curve::ValueCurve) = LossCurve(curve, NaturalUnit())

"""
Unwrap a `LossCurve` to the bare curve the document holds, refusing any basis the
document cannot represent.

Export errors on a non-natural basis rather than silently dropping it — the same posture
`admittance_units`/`voltage_units` already take on these HVDC types, where only the
implemented basis passes and anything else is an error rather than a guess. Without the
guard a `LossCurve` on a relative basis would round-trip back as `NaturalUnit`, changing
its meaning with no diagnostic.
"""
function loss_curve_to_openapi(loss::AnyLossCurve)
    units = get_power_units(loss)
    units isa NaturalUnit || error(
        "cannot export a LossCurve in $units: the OpenAPI schemas have no LossCurve, so " *
        "a document records no power basis for a loss field and the unit system would be " *
        "silently dropped. Convert the curve to NaturalUnit before exporting.",
    )
    return get_value_curve(loss)
end
