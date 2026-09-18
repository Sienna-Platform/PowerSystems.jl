# Hand-written (not generated): the reverse of src/openapi/cost_conversion.jl — PSY cost/curve
# types → PO (OpenAPI model) structs. One `convert_cost_to_openapi` overloaded per PSY
# cost/curve type, inverting every case `convert_cost` (src/openapi/cost_conversion.jl) handles.
#
# Dispatch mirrors the PSY type hierarchy directly (abstract `ValueCurve`/`FunctionData`
# supertypes, `AbstractReserve`) rather than an enumerated `isa`/`Union` chain — the same style
# already used throughout this package. PO structs are built with kwargs; oneOf wrappers
# (`PC.ValueCurve`, `IC.FunctionData`, `PC.ProductionVariableCostCurve`, ...) take their concrete
# value positionally, matching how `PowerOperationsOpenAPIModels`/`PowerCoreOpenAPIModels`
# generate them.

_power_units_to_string(::NaturalUnit, ::ProductionVariableCostCurve) =
    IC.UnitSystem("NATURAL_UNITS")
_power_units_to_string(
    ::ComponentBaseUnit,
    ::ProductionVariableCostCurve,
) = IC.UnitSystem("COMPONENT_BASE")

"""`CostCurve.power_units`/`FuelCurve.power_units` carry no system-base member — a curve whose
per-unit data is on the system base is expected to record that base in the owning component's
`base_power` and ride as `COMPONENT_BASE`. This converter is handed the curve alone (see the
`convert_cost_to_openapi(get_operation_cost(gen))` call sites), so it can neither check that the
component's `base_power` really is the system base nor rescale the curve's x-coordinates by
`system_base / component_base` if it is not. Relabelling would silently corrupt magnitudes, so fail
loudly instead (psy6 rule)."""
function _power_units_to_string(::SystemBaseUnit, cost::ProductionVariableCostCurve)
    error(
        "cannot export $(typeof(cost)) with power_units = SystemBaseUnit(): the OpenAPI " *
        "power_units enum accepts only COMPONENT_BASE and NATURAL_UNITS, and this converter " *
        "has no access to the owning component's base_power to rescale the curve. Rebuild " *
        "the curve on the component's own base (ComponentBaseUnit) or in natural units first.",
    )
end

# ── FunctionData ────────────────────────────────────────────────────────────────

function convert_cost_to_openapi(fd::LinearFunctionData)
    return IC.LinearFunctionData(;
        proportional_term = get_proportional_term(fd),
        constant_term = get_constant_term(fd),
    )
end

function convert_cost_to_openapi(fd::QuadraticFunctionData)
    return IC.QuadraticFunctionData(;
        quadratic_term = get_quadratic_term(fd),
        proportional_term = get_proportional_term(fd),
        constant_term = get_constant_term(fd),
    )
end

function convert_cost_to_openapi(fd::PiecewiseLinearData)
    return IC.PiecewiseLinearData(;
        points = [IC.XYCoords(; x = p.x, y = p.y) for p in get_points(fd)],
    )
end

function convert_cost_to_openapi(fd::PiecewiseStepData)
    return IC.PiecewiseStepData(; x_coords = get_x_coords(fd), y_coords = get_y_coords(fd))
end

# ── ValueCurve ──────────────────────────────────────────────────────────────────
# Returns the bare PO curve struct (not the `PC.ValueCurve` oneOf wrapper) — callers wrap it
# where the field's spec type is the wrapper (`CostCurve.value_curve`) and use it bare where
# the spec type is the concrete curve directly (`vom_cost`, `TwoTerminalLoss`).

"""`initial_input`/`input_at_zero` are optional-by-omission on the wire (not nullable) —
`nothing` fails schema validation on encode, so a missing PSY-side value emits `IC.ABSENT`."""
_optional_to_wire(::Nothing) = IC.ABSENT
_optional_to_wire(v) = v

function convert_cost_to_openapi(curve::InputOutputCurve)
    return PC.InputOutputCurve(;
        function_data = PC.InputOutputCurveFunctionData(
            convert_cost_to_openapi(get_function_data(curve)),
        ),
        input_at_zero = _optional_to_wire(get_input_at_zero(curve)),
    )
end

function convert_cost_to_openapi(curve::IncrementalCurve)
    return PC.IncrementalCurve(;
        function_data = PC.IncrementalCurveFunctionData(
            convert_cost_to_openapi(get_function_data(curve)),
        ),
        initial_input = _optional_to_wire(get_initial_input(curve)),
        input_at_zero = _optional_to_wire(get_input_at_zero(curve)),
    )
end

function convert_cost_to_openapi(curve::AverageRateCurve)
    return PC.AverageRateCurve(;
        function_data = PC.AverageRateCurveFunctionData(
            convert_cost_to_openapi(get_function_data(curve)),
        ),
        initial_input = _optional_to_wire(get_initial_input(curve)),
        input_at_zero = _optional_to_wire(get_input_at_zero(curve)),
    )
end

# ── Time-series FunctionData/ValueCurve — export reads association ids straight off the
# PSY key, needs no store ──────────────────────────────────────────────────────

_ts_function_data_wire_type(::Type{LinearFunctionData}) = IC.TimeSeriesLinearFunctionData
_ts_function_data_wire_type(::Type{QuadraticFunctionData}) =
    IC.TimeSeriesQuadraticFunctionData
_ts_function_data_wire_type(::Type{PiecewiseLinearData}) = IC.TimeSeriesPiecewiseLinearData
_ts_function_data_wire_type(::Type{PiecewiseStepData}) = IC.TimeSeriesPiecewiseStepData

function convert_cost_to_openapi(fd::TimeSeriesFunctionData{T}) where {T}
    WireType = _ts_function_data_wire_type(T)
    return WireType(;
        association_id = _key_association_id(IS.get_time_series_key(fd)),
    )
end

# Every association id the document emits passes through here.
#
# A cost may reference a series owned by a different component, and that owner may
# be one the document cannot describe -- a dynamic component today, since none has
# a converter yet. `_export_all_time_series` then skips the series' association row
# and the document ships a cost pointing at a series it never declares. Importing
# that against another sidecar resolves the bare id against whatever holds it
# there, silently binding the cost to the wrong series.
#
# Recording each id as it is emitted lets `_check_costs_reference_declared_series!`
# catch that before the document exists, and it stays correct for cost shapes added
# later: a new emit point routes through here or it does not emit an id at all.
const _EMITTED_ASSOCIATION_IDS_KEY = :psy_openapi_export_emitted_association_ids

function _record_emitted_association_id(id::Int)
    ids = get(task_local_storage(), _EMITTED_ASSOCIATION_IDS_KEY, nothing)
    isnothing(ids) || push!(ids, id)
    return id
end

"""`nothing` stays `nothing`; a present key emits its `association_id`."""
_key_association_id(::Nothing) = nothing
_key_association_id(key::IS.TimeSeriesKey) =
    _record_emitted_association_id(IS.get_association_id(key))

"""Wire representation of [`CurveStyles`](@ref): a plain integer (0/1) - see
`cost_conversion.jl`'s `_curve_style_from_wire` for the import-direction counterpart."""
_curve_style_to_wire(style::CurveStyles.Value) = Integer(style)
"""Wire representation of [`CurveMultiStep`](@ref): a plain integer (0/1), mirroring
`_curve_style_to_wire`."""
_curve_multistep_to_wire(flag::CurveMultiStep.Value) = Integer(flag)

function convert_cost_to_openapi(curve::TimeSeriesInputOutputCurve)
    return PC.TimeSeriesInputOutputCurve(;
        function_data = IC.FunctionData(convert_cost_to_openapi(get_function_data(curve))),
        input_at_zero = get_input_at_zero(curve),
    )
end

function convert_cost_to_openapi(curve::TimeSeriesIncrementalCurve)
    return PC.TimeSeriesIncrementalCurve(;
        function_data = IC.FunctionData(convert_cost_to_openapi(get_function_data(curve))),
        initial_input_association_id = _key_association_id(get_initial_input(curve)),
        input_at_zero_association_id = _key_association_id(get_input_at_zero(curve)),
    )
end

function convert_cost_to_openapi(curve::TimeSeriesAverageRateCurve)
    return PC.TimeSeriesAverageRateCurve(;
        function_data = IC.FunctionData(convert_cost_to_openapi(get_function_data(curve))),
        initial_input_association_id = _key_association_id(get_initial_input(curve)),
        input_at_zero_association_id = _key_association_id(get_input_at_zero(curve)),
    )
end

# ── fuel_cost: PSY splits it into `fuel_cost`/`fuel_cost_time_series` — exactly one set ──

_fuel_cost_time_series_id(fuel_cost) = _key_association_id(fuel_cost)

# ── ProductionVariableCostCurve: CostCurve / FuelCurve ─────────────────────────

function convert_cost_to_openapi(cost::CostCurve)
    return PC.CostCurve(;
        power_units = _power_units_to_string(get_power_units(cost), cost),
        value_curve = PC.ValueCurve(convert_cost_to_openapi(get_value_curve(cost))),
        vom_cost = convert_cost_to_openapi(get_vom_cost(cost)),
    )
end

function convert_cost_to_openapi(cost::FuelCurve)
    return PC.FuelCurve(;
        power_units = _power_units_to_string(get_power_units(cost), cost),
        value_curve = PC.ValueCurve(convert_cost_to_openapi(get_value_curve(cost))),
        fuel_cost = get_fuel_cost(cost),
        fuel_cost_time_series = _fuel_cost_time_series_id(
            IS.get_fuel_cost_time_series(cost),
        ),
        vom_cost = convert_cost_to_openapi(get_vom_cost(cost)),
    )
end

"""`zero(CostCurve)` is the sentinel `_optional_cost_curve` maps `Absent`/`nothing` to on
import (curtailment_cost, storage charge/discharge_variable_cost); reverse it back to
`IC.ABSENT` rather than `nothing` — these fields are declared optional-by-omission, not
nullable, so `nothing` fails schema validation on encode."""
function _optional_cost_curve_to_openapi(cost::CostCurve)
    if cost == zero(CostCurve)
        return IC.ABSENT
    end
    return convert_cost_to_openapi(cost)
end

# ── start_up: a bare number, or a multi-stage / charge-discharge breakdown ────

_thermal_start_up_to_openapi(x::Real) = PC.ThermalGenerationCostStartUp(Float64(x))
function _thermal_start_up_to_openapi(x::NamedTuple)
    return PC.ThermalGenerationCostStartUp(
        PC.StartUpStages(;
            startup_stages_type = "STAGES",
            hot = x.hot,
            warm = x.warm,
            cold = x.cold,
        ),
    )
end

_storage_start_up_to_openapi(x::Real) = PC.StorageCostStartUp(Float64(x))
function _storage_start_up_to_openapi(x::NamedTuple)
    return PC.StorageCostStartUp(
        PC.ChargeDischarge(; charge = x.charge, discharge = x.discharge),
    )
end

# ── Operation-cost containers ─────────────────────────────────────────────────

function convert_cost_to_openapi(cost::ThermalGenerationCost)
    return PC.ThermalGenerationCost(;
        cost_type = "THERMAL",
        fixed = get_fixed(cost),
        shut_down = get_shut_down(cost),
        start_up = _thermal_start_up_to_openapi(get_start_up(cost)),
        variable_operation_cost = PC.ProductionVariableCostCurve(
            convert_cost_to_openapi(get_variable_operation_cost(cost)),
        ),
    )
end

function convert_cost_to_openapi(cost::RenewableGenerationCost)
    return PC.RenewableGenerationCost(;
        cost_type = "RENEWABLE",
        variable_operation_cost = convert_cost_to_openapi(
            get_variable_operation_cost(cost),
        ),
        curtailment_cost = _optional_cost_curve_to_openapi(get_curtailment_cost(cost)),
        fixed = get_fixed(cost),
    )
end

function convert_cost_to_openapi(cost::HydroGenerationCost)
    return PC.HydroGenerationCost(;
        cost_type = "HYDRO_GEN",
        fixed = get_fixed(cost),
        variable_operation_cost = PC.ProductionVariableCostCurve(
            convert_cost_to_openapi(get_variable_operation_cost(cost)),
        ),
    )
end

function convert_cost_to_openapi(cost::LoadCost)
    return PC.LoadCost(;
        cost_type = "LOAD",
        variable_operation_cost = convert_cost_to_openapi(
            get_variable_operation_cost(cost),
        ),
        fixed = get_fixed(cost),
    )
end

"""
Static market bid. `ancillary_service_offers` holds `Service` objects but the document
stores component ids, and this converter has no id registry, so it exports the list empty;
`_export_market_bid_service_offers!` fills the ids in a document-level pass.
"""
function convert_cost_to_openapi(cost::MarketBidCost)
    start_up = get_start_up(cost)
    return PC.MarketBidCost(;
        cost_type = "MARKET_BID",
        minimum_energy_offer = convert_cost_to_openapi(get_minimum_energy_offer(cost)),
        start_up = PC.StartUpStages(;
            startup_stages_type = "STAGES",
            hot = start_up.hot,
            warm = start_up.warm,
            cold = start_up.cold,
        ),
        shut_down = convert_cost_to_openapi(get_shut_down(cost)),
        incremental_offer_curves = convert_cost_to_openapi(
            get_incremental_offer_curves(cost),
        ),
        decremental_offer_curves = convert_cost_to_openapi(
            get_decremental_offer_curves(cost),
        ),
        ancillary_service_offers = Int64[],
        incremental_slope = get_incremental_slope(cost),
        decremental_slope = get_decremental_slope(cost),
        curve_style = PC.CurveStyles(_curve_style_to_wire(get_curve_style(cost))),
        curve_multistep = PC.CurveMultiStep(
            _curve_multistep_to_wire(get_curve_multistep(cost)),
        ),
    )
end

function convert_cost_to_openapi(cost::HydroReservoirCost)
    return PC.HydroReservoirCost(;
        cost_type = "HYDRO_RES",
        level_shortage_cost = get_level_shortage_cost(cost),
        level_surplus_cost = get_level_surplus_cost(cost),
        spillage_cost = get_spillage_cost(cost),
    )
end

function convert_cost_to_openapi(cost::StorageCost)
    return PC.StorageCost(;
        cost_type = "STORAGE",
        charge_variable_cost = _optional_cost_curve_to_openapi(
            get_charge_variable_cost(cost),
        ),
        discharge_variable_cost = _optional_cost_curve_to_openapi(
            get_discharge_variable_cost(cost),
        ),
        fixed = get_fixed(cost),
        shut_down = get_shut_down(cost),
        start_up = _storage_start_up_to_openapi(get_start_up(cost)),
        energy_shortage_cost = get_energy_shortage_cost(cost),
        energy_surplus_cost = get_energy_surplus_cost(cost),
    )
end

"""`ancillary_service_offers` has no counterpart in the `PC.ImportExportCost` schema (unlike
`MarketBidCost`, which resolves its `Service` ids in a document-level pass), so it is dropped
here rather than exported."""
function convert_cost_to_openapi(cost::ImportExportCost)
    return PC.ImportExportCost(;
        cost_type = "IMPORTEXPORT",
        import_offer_curves = convert_cost_to_openapi(get_import_offer_curves(cost)),
        export_offer_curves = convert_cost_to_openapi(get_export_offer_curves(cost)),
        energy_import_weekly_limit = get_energy_import_weekly_limit(cost),
        energy_export_weekly_limit = get_energy_export_weekly_limit(cost),
    )
end

"""
Time-varying market bid. Unlike `convert_cost_to_openapi(::MarketBidCost)`, whose
`ancillary_service_offers` the document-level `_export_market_bid_service_offers!`
(`export_document.jl`) fills in after every component has an id, this cost type's ids are
NOT filled by that pass — it gates on `PC.MarketBidCost` only, and extending it is blocked:
`export_document.jl` is out of this task's edit scope. Rather than silently emitting an
empty list and dropping real offers, this errors loudly on a non-empty
`ancillary_service_offers` so the gap is visible instead of a silent data loss on export.
"""
function convert_cost_to_openapi(cost::MarketBidTimeSeriesCost)
    offers = get_ancillary_service_offers(cost)
    if !isempty(offers)
        error(
            "convert_cost_to_openapi(MarketBidTimeSeriesCost): $(length(offers)) " *
            "ancillary_service_offers cannot be exported — the document-level id-filling " *
            "pass (_export_market_bid_service_offers!, export_document.jl) only resolves " *
            "them for the static MarketBidCost, not this time-series variant. Remove the " *
            "ancillary service offers before exporting, or resolve them another way.",
        )
    end
    return PC.MarketBidTimeSeriesCost(;
        minimum_energy_offer = convert_cost_to_openapi(get_minimum_energy_offer(cost)),
        start_up_association_id = _key_association_id(get_start_up(cost)),
        shut_down = convert_cost_to_openapi(get_shut_down(cost)),
        incremental_offer_curves = convert_cost_to_openapi(
            get_incremental_offer_curves(cost),
        ),
        decremental_offer_curves = convert_cost_to_openapi(
            get_decremental_offer_curves(cost),
        ),
        ancillary_service_offers = Int64[],
        incremental_slope = get_incremental_slope(cost),
        decremental_slope = get_decremental_slope(cost),
        curve_style = PC.CurveStyles(_curve_style_to_wire(get_curve_style(cost))),
        curve_multistep = PC.CurveMultiStep(
            _curve_multistep_to_wire(get_curve_multistep(cost)),
        ),
    )
end

"""
Time-varying import/export bids. Mirrors `convert_cost_to_openapi(::ImportExportCost)`:
`energy_import_weekly_limit`/`energy_export_weekly_limit` are MWh on both sides of the wire, so
no scaling and no `base_power` argument.
"""
function convert_cost_to_openapi(cost::ImportExportTimeSeriesCost)
    offers = get_ancillary_service_offers(cost)
    if !isempty(offers)
        error(
            "convert_cost_to_openapi(ImportExportTimeSeriesCost): $(length(offers)) " *
            "ancillary_service_offers cannot be exported — the document-level id-filling " *
            "pass (_export_market_bid_service_offers!, export_document.jl) only resolves " *
            "them for the static MarketBidCost, not this time-series variant. Remove the " *
            "ancillary service offers before exporting, or resolve them another way.",
        )
    end
    return PC.ImportExportTimeSeriesCost(;
        import_offer_curves = convert_cost_to_openapi(get_import_offer_curves(cost)),
        export_offer_curves = convert_cost_to_openapi(get_export_offer_curves(cost)),
        energy_import_weekly_limit = get_energy_import_weekly_limit(cost),
        energy_export_weekly_limit = get_energy_export_weekly_limit(cost),
        # Always empty: reaching here means the cost carries no offers (guarded above),
        # and unlike the static `ImportExportCost` this schema does have the field, so it
        # has to be emitted rather than omitted.
        ancillary_service_offers = Int64[],
    )
end

# ── Reserve Operating Reserve Demand Curve ─────────────────────────────────────

"""Convert a reserve's `variable` (Operating Reserve Demand Curve) to its PO representation:
`ZERO_OFFER_CURVE` (no curve defined, per `has_demand_curve`) maps to `nothing`; a present
curve reduces to `PC.CostCurve`. Reuses `has_demand_curve` rather than reimplementing the
zero-detection logic (`_is_zero_offer_curve`, models/reserves.jl)."""
function convert_reserve_variable_to_openapi(reserve::AbstractReserve)
    if !has_demand_curve(reserve)
        return IC.ABSENT
    end
    return convert_cost_to_openapi(get_variable(reserve))
end
