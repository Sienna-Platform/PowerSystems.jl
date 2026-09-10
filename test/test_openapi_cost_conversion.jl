# Cost/curve shapes constructed directly from PowerCoreOpenAPIModels kwargs (PC = PSY.PC),

_po_linear_io(prop, const_) = PSY.PC.InputOutputCurve(;
    function_data = PSY.PC.InputOutputCurveFunctionData(
        PSY.IC.LinearFunctionData(; proportional_term = prop, constant_term = const_),
    ),
)

_po_cost_curve(; power_units = "NATURAL_UNITS", vom_cost = nothing) = PSY.PC.CostCurve(;
    power_units = power_units,
    value_curve = PSY.PC.ValueCurve(_po_linear_io(10.0, 5.0)),
    vom_cost = vom_cost,
)

@testset "convert_cost: FunctionData variants" begin
    @test PSY.convert_cost(
        PSY.IC.LinearFunctionData(; proportional_term = 2.0, constant_term = 3.0),
    ) == LinearFunctionData(2.0, 3.0)

    @test PSY.convert_cost(
        PSY.IC.QuadraticFunctionData(;
            quadratic_term = 1.0,
            proportional_term = 2.0,
            constant_term = 3.0,
        ),
    ) == QuadraticFunctionData(1.0, 2.0, 3.0)

    @test PSY.convert_cost(
        PSY.IC.PiecewiseLinearData(;
            points = [
                PSY.IC.XYCoords(; x = 0.0, y = 0.0),
                PSY.IC.XYCoords(; x = 10.0, y = 100.0),
            ],
        ),
    ) == PiecewiseLinearData([(x = 0.0, y = 0.0), (x = 10.0, y = 100.0)])

    @test PSY.convert_cost(
        PSY.IC.PiecewiseStepData(; x_coords = [0.0, 10.0, 20.0], y_coords = [5.0, 6.0]),
    ) == PiecewiseStepData([0.0, 10.0, 20.0], [5.0, 6.0])

    @test_throws ErrorException PSY.convert_cost(nothing)
end

@testset "convert_cost: ValueCurve variants" begin
    io = PSY.convert_cost(_po_linear_io(10.0, 5.0))
    @test io == InputOutputCurve(LinearFunctionData(10.0, 5.0))

    inc = PSY.convert_cost(
        PSY.PC.IncrementalCurve(;
            function_data = PSY.PC.IncrementalCurveFunctionData(
                PSY.IC.PiecewiseStepData(; x_coords = [0.0, 10.0], y_coords = [5.0]),
            ),
            initial_input = 50.0,
        ),
    )
    @test inc == IncrementalCurve(PiecewiseStepData([0.0, 10.0], [5.0]), 50.0)

    avg = PSY.convert_cost(
        PSY.PC.AverageRateCurve(;
            function_data = PSY.PC.IncrementalCurveFunctionData(
                PSY.IC.LinearFunctionData(; proportional_term = 1.0, constant_term = 0.0),
            ),
            initial_input = 20.0,
        ),
    )
    @test avg == AverageRateCurve(LinearFunctionData(1.0, 0.0), 20.0)
end

@testset "convert_cost: power_units marker mapping" begin
    # The wire enum is COMPONENT_BASE/NATURAL_UNITS only — there is no system-base member.
    for (str, marker) in (
        ("NATURAL_UNITS", NaturalUnit()),
        ("COMPONENT_BASE", DeviceBaseUnit()),
    )
        curve = PSY.convert_cost(_po_cost_curve(; power_units = str))
        @test get_power_units(curve) == marker
        @test PSY._power_units_to_string(marker, curve) == str
    end
    # Tested directly against the barrier: PC.CostCurve's own OpenAPI-generated enum
    # validator would reject "BOGUS"/"SYSTEM_BASE" at construction time, before
    # convert_cost ever runs.
    @test_throws ErrorException PSY._with_power_units(identity, "BOGUS")
    @test_throws ErrorException PSY._with_power_units(identity, "SYSTEM_BASE")
    @test_throws ErrorException PSY._with_power_units(identity, nothing)

    # The barrier hands `f` a CONCRETE marker, never a Union — that is the whole point of
    # its being higher-order, since the marker is a type parameter of the curve it builds.
    for (str, marker) in
        (("NATURAL_UNITS", NaturalUnit()), ("COMPONENT_BASE", DeviceBaseUnit()))
        @test PSY._with_power_units(typeof, str) === typeof(marker)
    end

    # A SystemBaseUnit curve has no valid wire value and no reachable base_power to
    # rescale against, so export errors rather than silently relabelling it COMPONENT_BASE.
    sb_curve = CostCurve(LinearCurve(10.0, 5.0), SystemBaseUnit())
    @test_throws ErrorException PSY.convert_cost_to_openapi(sb_curve)
end

@testset "convert_cost: CostCurve and FuelCurve" begin
    cc = PSY.convert_cost(_po_cost_curve())
    @test cc isa CostCurve{LinearCurve, NaturalUnit}
    @test get_function_data(get_value_curve(cc)) == LinearFunctionData(10.0, 5.0)
    @test get_vom_cost(cc) == LinearCurve(0.0)

    cc_with_vom = PSY.convert_cost(_po_cost_curve(; vom_cost = _po_linear_io(2.0, 0.0)))
    @test get_vom_cost(cc_with_vom) == LinearCurve(2.0, 0.0)

    fc = PSY.convert_cost(
        PSY.PC.FuelCurve(;
            power_units = "NATURAL_UNITS",
            value_curve = PSY.PC.ValueCurve(
                PSY.PC.IncrementalCurve(;
                    function_data = PSY.PC.IncrementalCurveFunctionData(
                        PSY.IC.PiecewiseStepData(;
                            x_coords = [0.0, 10.0, 20.0],
                            y_coords = [5.0, 6.0],
                        ),
                    ),
                    initial_input = 50.0,
                ),
            ),
            fuel_cost = 3.5,
        ),
    )
    @test fc isa FuelCurve
    @test get_fuel_cost(fc) == 3.5
    @test get_vom_cost(fc) == LinearCurve(0.0)
end

@testset "convert_cost: vom_cost must be LINEAR" begin
    bad = _po_cost_curve(;
        vom_cost = PSY.PC.InputOutputCurve(;
            function_data = PSY.PC.InputOutputCurveFunctionData(
                PSY.IC.QuadraticFunctionData(;
                    quadratic_term = 1.0,
                    proportional_term = 1.0,
                    constant_term = 1.0,
                ),
            ),
        ),
    )
    @test_throws ErrorException PSY.convert_cost(bad)
end

@testset "convert_cost: ThermalGenerationCost" begin
    po = PSY.PC.ThermalGenerationCost(;
        fixed = 100.0,
        shut_down = 50.0,
        start_up = 200.0,
        variable_operation_cost = PSY.PC.ProductionVariableCostCurve(_po_cost_curve()),
    )
    cost = PSY.convert_cost(po)
    @test cost isa ThermalGenerationCost
    @test get_fixed(cost) == 100.0
    @test get_shut_down(cost) == 50.0
    @test get_start_up(cost) == 200.0
    @test get_function_data(get_value_curve(get_variable_operation_cost(cost))) ==
          LinearFunctionData(10.0, 5.0)

    po_stages = PSY.PC.ThermalGenerationCost(;
        fixed = 0.0,
        shut_down = 0.0,
        start_up = PSY.PC.ThermalGenerationCostStartUp(
            PSY.PC.StartUpStages(; hot = 1.0, warm = 2.0, cold = 3.0),
        ),
        variable_operation_cost = PSY.PC.ProductionVariableCostCurve(_po_cost_curve()),
    )
    cost_stages = PSY.convert_cost(po_stages)
    @test get_start_up(cost_stages) == (hot = 1.0, warm = 2.0, cold = 3.0)

    po_missing_variable = PSY.PC.ThermalGenerationCost(;
        fixed = 0.0,
        shut_down = 0.0,
        start_up = 0.0,
        variable_operation_cost = nothing,
    )
    @test_throws ErrorException PSY.convert_cost(po_missing_variable)
end

@testset "convert_cost: RenewableGenerationCost" begin
    po = PSY.PC.RenewableGenerationCost(;
        variable_operation_cost = _po_cost_curve(), fixed = 10.0,
    )
    cost = PSY.convert_cost(po)
    @test cost isa RenewableGenerationCost
    @test get_fixed(cost) == 10.0
    @test get_curtailment_cost(cost) == zero(CostCurve)
    @test get_function_data(get_value_curve(get_variable_operation_cost(cost))) ==
          LinearFunctionData(10.0, 5.0)
end

@testset "convert_cost: HydroGenerationCost" begin
    po = PSY.PC.HydroGenerationCost(;
        fixed = 1.0,
        variable_operation_cost = PSY.PC.ProductionVariableCostCurve(_po_cost_curve()),
    )
    cost = PSY.convert_cost(po)
    @test cost isa HydroGenerationCost
    @test get_fixed(cost) == 1.0
end

@testset "convert_cost: HydroReservoirCost" begin
    po = PSY.PC.HydroReservoirCost(;
        level_shortage_cost = 1.0,
        level_surplus_cost = 2.0,
        spillage_cost = 3.0,
    )
    cost = PSY.convert_cost(po)
    @test cost isa HydroReservoirCost
    @test get_level_shortage_cost(cost) == 1.0
    @test get_level_surplus_cost(cost) == 2.0
    @test get_spillage_cost(cost) == 3.0
end

@testset "convert_cost: StorageCost" begin
    po = PSY.PC.StorageCost(;
        charge_variable_cost = nothing,
        discharge_variable_cost = _po_cost_curve(),
        fixed = 5.0,
        shut_down = 0.0,
        start_up = PSY.PC.StorageCostStartUp(
            PSY.PC.StorageCostStartUpOneOf(; charge = 1.0, discharge = 2.0),
        ),
        energy_shortage_cost = 3.0,
        energy_surplus_cost = 4.0,
    )
    cost = PSY.convert_cost(po)
    @test cost isa StorageCost
    @test get_charge_variable_cost(cost) == zero(CostCurve)
    @test get_function_data(get_value_curve(get_discharge_variable_cost(cost))) ==
          LinearFunctionData(10.0, 5.0)
    @test get_start_up(cost) == (charge = 1.0, discharge = 2.0)
    @test get_energy_shortage_cost(cost) == 3.0
    @test get_energy_surplus_cost(cost) == 4.0
end

_po_offer_curve(x_coords, y_coords; power_units = "NATURAL_UNITS") = PSY.PC.CostCurve(;
    power_units = power_units,
    value_curve = PSY.PC.ValueCurve(
        PSY.PC.IncrementalCurve(;
            function_data = PSY.PC.IncrementalCurveFunctionData(
                PSY.IC.PiecewiseStepData(; x_coords = x_coords, y_coords = y_coords),
            ),
            initial_input = 0.0,
        ),
    ),
)

@testset "convert_cost: ImportExportCost" begin
    po = PSY.PC.ImportExportCost(;
        import_offer_curves = _po_offer_curve([0.0, 100.0, 200.0], [10.0, 20.0]),
        export_offer_curves = _po_offer_curve([0.0, 50.0], [8.0]),
        energy_import_weekly_limit = 1000.0,
        energy_export_weekly_limit = 2000.0,
    )
    cost = PSY.convert_cost(po)
    @test cost isa ImportExportCost
    import_curve = get_import_offer_curves(cost)
    @test import_curve isa CostCurve{PiecewiseIncrementalCurve}
    @test get_function_data(get_value_curve(import_curve)) ==
          PiecewiseStepData([0.0, 100.0, 200.0], [10.0, 20.0])
    @test get_function_data(get_value_curve(get_export_offer_curves(cost))) ==
          PiecewiseStepData([0.0, 50.0], [8.0])
    @test get_energy_import_weekly_limit(cost) == 1000.0
    @test get_energy_export_weekly_limit(cost) == 2000.0
    # The schema has no `ancillary_service_offers`, so the export drops it and the import
    # cannot invent one.
    @test isempty(get_ancillary_service_offers(cost))
end

@testset "convert_cost: ImportExportCost with an unoffered side" begin
    po = PSY.PC.ImportExportCost(;
        import_offer_curves = _po_offer_curve([0.0, 100.0], [10.0]),
        export_offer_curves = nothing,
        energy_import_weekly_limit = 1000.0,
        energy_export_weekly_limit = 2000.0,
    )
    cost = PSY.convert_cost(po)
    @test get_export_offer_curves(cost) === PSY.ZERO_OFFER_CURVE
end

@testset "convert_cost: ImportExportCost offer curves must be piecewise incremental" begin
    po = PSY.PC.ImportExportCost(;
        import_offer_curves = _po_cost_curve(),
        export_offer_curves = nothing,
        energy_import_weekly_limit = 1000.0,
        energy_export_weekly_limit = 2000.0,
    )
    @test_throws ErrorException PSY.convert_cost(po)
end

@testset "convert_cost: ImportExportCost round trip" begin
    cost = ImportExportCost(;
        import_offer_curves = make_import_curve([0.0, 100.0, 200.0], [10.0, 20.0]),
        export_offer_curves = make_export_curve([0.0, 50.0], [8.0]),
        energy_import_weekly_limit = 1000.0,
        energy_export_weekly_limit = 2000.0,
    )
    # `ImportExportCost` has no `==`, so compare the fields the conversion carries.
    round_tripped = PSY.convert_cost(PSY.convert_cost_to_openapi(cost))
    @test get_import_offer_curves(round_tripped) == get_import_offer_curves(cost)
    @test get_export_offer_curves(round_tripped) == get_export_offer_curves(cost)
    @test get_energy_import_weekly_limit(round_tripped) ==
          get_energy_import_weekly_limit(cost)
    @test get_energy_export_weekly_limit(round_tripped) ==
          get_energy_export_weekly_limit(cost)
end

@testset "convert_reserve_variable: reserve Operating Reserve Demand Curve" begin
    @test PSY.convert_reserve_variable(nothing) === PSY.ZERO_OFFER_CURVE

    po_ordc = PSY.PC.CostCurve(;
        power_units = "NATURAL_UNITS",
        value_curve = PSY.PC.ValueCurve(
            PSY.PC.IncrementalCurve(;
                function_data = PSY.PC.IncrementalCurveFunctionData(
                    PSY.IC.PiecewiseStepData(; x_coords = [0.0, 100.0], y_coords = [10.0]),
                ),
                initial_input = 0.0,
            ),
        ),
    )
    ordc = PSY.convert_reserve_variable(po_ordc)
    @test ordc isa CostCurve{PiecewiseIncrementalCurve}

    @test_throws ErrorException PSY.convert_reserve_variable(_po_cost_curve())
end

@testset "convert_cost: FuelCurve fuel_cost/fuel_cost_time_series are mutually exclusive" begin
    # Neither set.
    @test_throws ErrorException PSY.convert_cost(
        PSY.PC.FuelCurve(;
            power_units = "NATURAL_UNITS",
            value_curve = PSY.PC.ValueCurve(_po_linear_io(1.0, 0.0)),
        ),
    )
    # Both set — a document naming both is malformed regardless of whether either id
    # resolves, so this errors before ever touching a store.
    @test_throws ErrorException PSY.convert_cost(
        PSY.PC.FuelCurve(;
            power_units = "NATURAL_UNITS",
            value_curve = PSY.PC.ValueCurve(_po_linear_io(1.0, 0.0)),
            fuel_cost = 3.5,
            fuel_cost_time_series = 7,
        ),
    )
end

@testset "convert_cost: FuelCurve with a time-series value curve and a fixed fuel_cost" begin
    # A doubly-TS-backed shape only in the sense that the store binding is exercised twice
    # over: `value_curve` is a TIME_SERIES_INCREMENTAL curve (needs the store) while
    # `fuel_cost` is a plain scalar (does not). The 1-arg ambient form must resolve the
    # store for the value curve regardless of which form `fuel_cost` takes.
    store = IS.Store(; in_memory = true)
    try
        # `LinearFunctionData` values, not bare floats: the wire type below is a
        # `TimeSeriesLinearFunctionData`, and a key naming a `Float64`-valued series
        # cannot back one — the element type is part of the key's type now.
        series = SingleTimeSeries(;
            name = "heat_rate",
            data = TimeSeries.TimeArray(
                [
                    Dates.DateTime(2024, 1, 1, 0),
                    Dates.DateTime(2024, 1, 1, 1),
                    Dates.DateTime(2024, 1, 1, 2),
                ],
                [
                    IS.LinearFunctionData(8.0, 0.0),
                    IS.LinearFunctionData(8.5, 0.0),
                    IS.LinearFunctionData(9.0, 0.0),
                ],
            ),
        )
        batch = IS.make_add_batch()
        IS.serialize_single!(
            batch,
            1,
            "ThermalStandard",
            IS.get_owner_category(IS.InfrastructureSystemsComponent),
            IS.get_name(series),
            series,
        )
        IS.commit_batch!(store, batch)
        assoc_id = IS.get_association_id(only(IS.list_time_series_metadata(store)))

        fc = PSY._with_import_store(store) do
            PSY.convert_cost(
                PSY.PC.FuelCurve(;
                    power_units = "NATURAL_UNITS",
                    value_curve = PSY.PC.ValueCurve(
                        PSY.PC.TimeSeriesIncrementalCurve(;
                            function_data = PSY.IC.FunctionData(
                                PSY.IC.TimeSeriesLinearFunctionData(;
                                    association_id = assoc_id,
                                ),
                            ),
                            initial_input_association_id = nothing,
                        ),
                    ),
                    fuel_cost = 3.5,
                ),
            )
        end
        @test fc isa FuelCurve
        @test get_fuel_cost(fc) == 3.5
        @test get_fuel_cost_time_series(fc) === nothing
        @test get_function_data(get_value_curve(fc)) isa PSY.TimeSeriesFunctionData
    finally
        IS.close!(store)
    end
end

@testset "convert_cost: FuelCurve/MarketBidTimeSeriesCost need a bound import store" begin
    # `fuel_cost_time_series` present but no active `from_openapi(System, doc)` import bound:
    # the 1-arg ambient form errors rather than silently treating it as absent.
    @test_throws ErrorException PSY.convert_cost(
        PSY.PC.FuelCurve(;
            power_units = "NATURAL_UNITS",
            value_curve = PSY.PC.ValueCurve(_po_linear_io(1.0, 0.0)),
            fuel_cost_time_series = 7,
        ),
    )
    @test_throws ErrorException PSY.convert_cost(
        PSY.PC.MarketBidTimeSeriesCost(;
            minimum_energy_offer = PSY.PC.TimeSeriesInputOutputCurve(;
                function_data = PSY.IC.FunctionData(
                    PSY.IC.TimeSeriesLinearFunctionData(; association_id = 1),
                ),
            ),
            start_up_association_id = 2,
            shut_down = PSY.PC.TimeSeriesInputOutputCurve(;
                function_data = PSY.IC.FunctionData(
                    PSY.IC.TimeSeriesLinearFunctionData(; association_id = 3),
                ),
            ),
            incremental_offer_curves = PSY.PC.CostCurve(;
                power_units = "NATURAL_UNITS",
                value_curve = PSY.PC.ValueCurve(
                    PSY.PC.TimeSeriesIncrementalCurve(;
                        function_data = PSY.IC.FunctionData(
                            PSY.IC.TimeSeriesPiecewiseStepData(; association_id = 4),
                        ),
                    ),
                ),
            ),
            decremental_offer_curves = PSY.PC.CostCurve(;
                power_units = "NATURAL_UNITS",
                value_curve = PSY.PC.ValueCurve(
                    PSY.PC.TimeSeriesIncrementalCurve(;
                        function_data = PSY.IC.FunctionData(
                            PSY.IC.TimeSeriesPiecewiseStepData(; association_id = 5),
                        ),
                    ),
                ),
            ),
        ),
    )
end

@testset "weekly limits are MWh, unscaled, in both directions" begin
    # `INFINITE_BOUND` is a real value on the wire now, not a sentinel a scaling step has
    # to dodge — it rides across every conversion identically to any other MWh value.
    cost = ImportExportCost(;
        import_offer_curves = make_import_curve([0.0, 100.0], [10.0]),
        export_offer_curves = make_export_curve([0.0, 50.0], [8.0]),
        energy_import_weekly_limit = PSY.INFINITE_BOUND,
        energy_export_weekly_limit = 4321.0,
    )
    wire = PSY.convert_cost_to_openapi(cost)
    @test wire.energy_import_weekly_limit == PSY.INFINITE_BOUND
    @test wire.energy_export_weekly_limit == 4321.0
    round_tripped = PSY.convert_cost(wire)
    @test get_energy_import_weekly_limit(round_tripped) == PSY.INFINITE_BOUND
    @test get_energy_export_weekly_limit(round_tripped) == 4321.0
end

@testset "convert_cost_to_openapi(ImportExportTimeSeriesCost): no base_power argument" begin
    # The 2-arg fallback and base_power threading this converter used to need for scaling
    # are gone now that the field is MWh; it takes the cost alone.
    @test !hasmethod(
        PSY.convert_cost_to_openapi, Tuple{ImportExportTimeSeriesCost, Real},
    )
    @test !hasmethod(PSY.convert_cost_to_openapi, Tuple{OperationalCost, Real})
end

@testset "convert_cost: ImportExportCost and ImportExportTimeSeriesCost weekly limits round trip identically" begin
    # Regression test for the fixed asymmetry: a static `ImportExportCost` and a
    # time-series-backed `ImportExportTimeSeriesCost` carrying the same weekly limit value
    # must produce the same wire value and round-trip back to the same PSY value —
    # previously the time-series cost alone divided/multiplied by `base_power`, so a
    # non-1.0 base_power made the two diverge.
    store = IS.Store(; in_memory = true)
    try
        # An import/export offer curve is backed by `PiecewiseStepData` values; a
        # `Float64`-valued series' key no longer types as one.
        series = SingleTimeSeries(;
            name = "import_price",
            data = TimeSeries.TimeArray(
                [Dates.DateTime(2024, 1, 1, 0), Dates.DateTime(2024, 1, 1, 1)],
                [
                    PiecewiseStepData([0.0, 100.0], [10.0]),
                    PiecewiseStepData([0.0, 100.0], [12.0]),
                ],
            ),
        )
        batch = IS.make_add_batch()
        IS.serialize_single!(
            batch,
            1,
            "Source",
            IS.get_owner_category(IS.InfrastructureSystemsComponent),
            IS.get_name(series),
            series,
        )
        IS.commit_batch!(store, batch)
        assoc_id = IS.get_association_id(only(IS.list_time_series_metadata(store)))
        ts_key = IS.get_time_series_key(store, Int(assoc_id))

        static_cost = ImportExportCost(;
            import_offer_curves = make_import_curve([0.0, 100.0], [10.0]),
            export_offer_curves = make_export_curve([0.0, 50.0], [8.0]),
            energy_import_weekly_limit = 1000.0,
            energy_export_weekly_limit = 2000.0,
        )
        ts_cost = ImportExportTimeSeriesCost(;
            import_offer_curves = make_import_export_ts_curve(ts_key),
            export_offer_curves = make_import_export_ts_curve(ts_key),
            energy_import_weekly_limit = 1000.0,
            energy_export_weekly_limit = 2000.0,
        )

        static_wire = PSY.convert_cost_to_openapi(static_cost)
        ts_wire = PSY.convert_cost_to_openapi(ts_cost)
        @test static_wire.energy_import_weekly_limit == ts_wire.energy_import_weekly_limit
        @test static_wire.energy_export_weekly_limit == ts_wire.energy_export_weekly_limit

        # A wildly non-1.0 base_power must not perturb the round trip.
        ts_round_tripped = PSY.convert_cost(ts_wire, store, 250.0)
        @test get_energy_import_weekly_limit(ts_round_tripped) ==
              get_energy_import_weekly_limit(ts_cost)
        @test get_energy_export_weekly_limit(ts_round_tripped) ==
              get_energy_export_weekly_limit(ts_cost)
    finally
        IS.close!(store)
    end
end

@testset "to_openapi refuses a cost referencing a series the document omits" begin
    # A cost may reference a series owned by a *different* component, and a component with
    # no OpenAPI converter is omitted from the document along with its association rows.
    # The document would then carry a bare association id with no declared identity beside
    # it, and importing that against another sidecar binds the cost to whichever series
    # holds that id there — silently, since the identity cross-check has nothing to match.
    sys = System(100.0)
    bus = ACBus(;
        number = 1, name = "b", available = true, bustype = ACBusTypes.REF,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 230.0,
    )
    add_component!(sys, bus)

    gen = ThermalStandard(;
        name = "A", available = true, status = OperationalStates.ONLINE, bus = bus,
        active_power = 1.0, reactive_power = 0.0, rating = 2.0,
        active_power_limits = (min = 0.0, max = 2.0), reactive_power_limits = nothing,
        ramp_limits = nothing, operation_cost = ThermalGenerationCost(nothing),
        base_power = 100.0, time_limits = nothing,
        prime_mover_type = PrimeMovers.OT, fuel = ThermalFuels.OTHER,
    )
    add_component!(sys, gen)

    src = Source(;
        name = "S", available = true, bus = bus, active_power = 0.0,
        reactive_power = 0.0, R_th = 0.0, X_th = 1.0, internal_voltage = 1.0,
        internal_angle = 0.0,
    )
    add_component!(sys, src)

    # No dynamic type has a converter yet, so this owner cannot be described.
    dyn = PeriodicVariableSource(; name = "S", R_th = 0.0, X_th = 1.0)
    add_component!(sys, dyn, src)
    @test !PowerSystems.is_document_exportable(dyn)

    series = SingleTimeSeries(;
        name = "fuel_price",
        data = TimeSeries.TimeArray(
            [Dates.DateTime(2030, 1, 1, 0), Dates.DateTime(2030, 1, 1, 1)],
            [10.0, 12.0],
        ),
    )
    key = add_time_series!(sys, dyn, series)
    set_operation_cost!(
        gen,
        ThermalGenerationCost(;
            variable_operation_cost = FuelCurve(LinearCurve(1.0), key),
            fixed = 0.0, start_up = 0.0, shut_down = 0.0,
        ),
    )

    dir = mktempdir()
    @test_throws IS.DataFormatError to_openapi(
        sys; time_series_storage_path = joinpath(dir, "sidecar.h5"),
    )
end
