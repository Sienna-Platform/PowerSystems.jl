@testset "Test scope-sensitive printing of IS cost functions" begin
    # Make sure the aliases get registered properly
    @test sprint(show, "text/plain", QuadraticCurve) ==
          "QuadraticCurve (alias for InputOutputCurve{QuadraticFunctionData})"

    # Make sure there are no IS-related prefixes in the printouts
    fc = FuelCurve(InputOutputCurve(IS.QuadraticFunctionData(1, 2, 3)), 4.0)
    @test sprint(show, "text/plain", fc) ==
          sprint(show, "text/plain", fc; context = :compact => false) ==
          "FuelCurve:\n  value_curve: QuadraticCurve (a type of InputOutputCurve) where function is: f(x) = 1.0 x^2 + 2.0 x + 3.0\n  power_units: UnitSystem.NATURAL_UNITS = 2\n  fuel_cost: 4.0\n  startup_fuel_offtake: LinearCurve (a type of InputOutputCurve) where function is: f(x) = 0.0 x + 0.0\n  vom_cost: LinearCurve (a type of InputOutputCurve) where function is: f(x) = 0.0 x + 0.0"
    @test sprint(show, "text/plain", fc; context = :compact => true) ==
          "FuelCurve with power_units UnitSystem.NATURAL_UNITS = 2, fuel_cost 4.0, startup_fuel_offtake LinearCurve(0.0, 0.0), vom_cost LinearCurve(0.0, 0.0), and value_curve:\n  QuadraticCurve (a type of InputOutputCurve) where function is: f(x) = 1.0 x^2 + 2.0 x + 3.0"
end

@testset "Test MarketBidCost direct struct creation and some scalar cost_function_timeseries interface" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    #Update generator cost to MarketBidCost using Natural Units
    powers = [22.0, 33.0, 44.0, 55.0] # MW
    marginal_costs = [25.0, 26.0, 28.0] # $/MWh
    initial_input = 50.0 # $/h
    cc = CostCurve(
        PiecewiseIncrementalCurve(
            initial_input,
            powers,
            marginal_costs,
        ),
    )
    mbc = MarketBidCost(;
        start_up = (hot = 0.0, warm = 0.0, cold = 0.0),
        shut_down = LinearCurve(0.0),
        incremental_offer_curves = cc,
    )
    set_operation_cost!(generator, mbc)
    @test get_operation_cost(generator) isa MarketBidCost

    @test get_incremental_offer_curves(mbc) == cc
    @test get_decremental_offer_curves(mbc) == PSY.ZERO_OFFER_CURVE

    @test get_variable_cost(generator, mbc) == cc
    @test get_incremental_variable_cost(generator, mbc) == cc
    @test get_decremental_variable_cost(generator, mbc) == PSY.ZERO_OFFER_CURVE

    cc2 = CostCurve(
        PiecewiseIncrementalCurve(
            initial_input,
            powers,
            marginal_costs .* 1.5,
        ),
    )
    set_incremental_variable_cost!(sys, generator, cc2, UnitSystem.NATURAL_UNITS)
    @test get_incremental_variable_cost(generator, mbc) == cc2

    set_decremental_variable_cost!(sys, generator, cc2, UnitSystem.NATURAL_UNITS)
    @test get_decremental_offer_curves(mbc) == cc2
end

@testset "Test Make market bid curve interface" begin
    mbc = make_market_bid_curve(
        [0.0, 100.0, 105.0, 120.0, 130.0],
        [25.0, 26.0, 28.0, 30.0],
        10.0,
    )
    @test is_market_bid_curve(mbc)
    @test is_market_bid_curve(
        make_market_bid_curve(get_function_data(mbc), get_initial_input(mbc)),
    )
    @test_throws ArgumentError make_market_bid_curve(
        [100.0, 105.0, 120.0, 130.0], [26.0, 28.0, 30.0, 40.0], 10.0)

    mbc2 = make_market_bid_curve([1.0, 2.0, 3.0], [4.0, 6.0], 10.0; input_at_zero = 2.0)
    @test is_market_bid_curve(mbc2)
    @test is_market_bid_curve(
        make_market_bid_curve(get_function_data(mbc2), get_initial_input(mbc2)),
    )

    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    market_bid = MarketBidCost(nothing)
    mbc3 = make_market_bid_curve([22.0, 33.0, 44.0, 55.0], [25.0, 26.0, 28.0], 50.0)
    set_incremental_offer_curves!(market_bid, mbc3)
    set_start_up!(market_bid, 0.0)
    set_operation_cost!(generator, market_bid)
    @test get_operation_cost(generator) isa MarketBidCost
end

test_costs = Dict(
    CostCurve{QuadraticCurve} =>
        repeat([CostCurve(QuadraticCurve(999.0, 2.0, 1.0))], 24),
    PiecewiseStepData =>
        repeat(
            [
                PSY._make_market_bid_curve(
                    PiecewiseStepData([0.0, 2.0, 3.0], [4.0, 6.0]),
                ),
            ],
            24,
        ),
    PiecewiseIncrementalCurve =>
        repeat(
            [
                make_market_bid_curve(
                    [1.0, 2.0, 3.0],
                    [4.0, 6.0],
                    18.0;
                    input_at_zero = 20.0,
                ),
            ],
            24,
        ),
    Float64 =>
        collect(11.0:34.0),
    PSY.StartUpStages =>
        repeat([(hot = PSY.START_COST, warm = PSY.START_COST, cold = PSY.START_COST)], 24),
)

@testset "Test MarketBidCost defaults and nothing constructor" begin
    mbc = MarketBidCost(nothing)
    @test get_no_load_cost(mbc) == LinearCurve(0.0)
    @test get_start_up(mbc) ==
          (hot = PSY.START_COST, warm = PSY.START_COST, cold = PSY.START_COST)
    @test get_shut_down(mbc) == LinearCurve(0.0)
    @test get_incremental_offer_curves(mbc) == PSY.ZERO_OFFER_CURVE
    @test get_decremental_offer_curves(mbc) == PSY.ZERO_OFFER_CURVE
end

@testset "Test static ReserveDemandCurve" begin
    sys = System(100.0)

    cc = CostCurve(
        PiecewiseIncrementalCurve(0.0, [0.0, 100.0, 200.0], [25.0, 30.0]),
    )
    reserve = ReserveDemandCurve{ReserveUp}(;
        variable = cc,
        name = "TestReserve",
        available = true,
        time_frame = 10.0,
    )
    add_component!(sys, reserve)
    @test get_variable_cost(reserve) == cc
    @test get_variable(reserve) isa CostCurve{PiecewiseIncrementalCurve}

    # Test set_variable_cost! with validation
    cc2 = CostCurve(
        PiecewiseIncrementalCurve(0.0, [0.0, 50.0, 150.0], [20.0, 18.0]),
    )
    set_variable_cost!(sys, reserve, cc2)
    @test get_variable_cost(reserve) == cc2

    # Nothing constructor
    reserve_nil = ReserveDemandCurve{ReserveUp}(nothing)
    @test get_name(reserve_nil) == "init"
    @test get_available(reserve_nil) == false
    @test get_variable(reserve_nil) == PSY.ZERO_OFFER_CURVE
end

function build_iec_sys()
    sys = PSB.build_system(PSITestSystems, "c_sys5_uc")

    source = Source(;
        name = "source",
        available = true,
        bus = get_component(ACBus, sys, "nodeC"),
        active_power = 0.0,
        reactive_power = 0.0,
        active_power_limits = (min = -2.0, max = 2.0),
        reactive_power_limits = (min = -2.0, max = 2.0),
        R_th = 0.01,
        X_th = 0.02,
        internal_voltage = 1.0,
        internal_angle = 0.0,
        base_power = 100.0,
    )

    source2 = Source(;
        name = "source2",
        available = true,
        bus = get_component(ACBus, sys, "nodeD"),
        active_power = 0.0,
        reactive_power = 0.0,
        active_power_limits = (min = -2.0, max = 2.0),
        reactive_power_limits = (min = -2.0, max = 2.0),
        R_th = 0.01,
        X_th = 0.02,
        internal_voltage = 1.0,
        internal_angle = 0.0,
        base_power = 100.0,
    )

    import_curve = make_import_curve(
        [0.0, 100.0, 105.0, 120.0, 200.0],
        [5.0, 10.0, 20.0, 40.0],
    )

    import_curve2 = make_import_curve([0.0, 200.0], [25.0])

    export_curve = make_export_curve(
        [0.0, 100.0, 105.0, 120.0, 200.0],
        [40.0, 20.0, 10.0, 5.0],
    )

    export_curve2 = make_export_curve([0.0, 200.0], [45.0])

    ie_cost = ImportExportCost(;
        import_offer_curves = import_curve,
        export_offer_curves = export_curve,
    )

    ie_cost2 = ImportExportCost(;
        import_offer_curves = import_curve2,
        export_offer_curves = export_curve2,
    )

    set_operation_cost!(source, ie_cost)
    set_operation_cost!(source2, ie_cost2)
    add_component!(sys, source)
    add_component!(sys, source2)

    return sys,
    source,
    source2,
    import_curve,
    import_curve2,
    export_curve,
    export_curve2,
    ie_cost,
    ie_cost2
end

@testset "ImportExportCost basic methods" begin
    sys,
    source,
    source2,
    import_curve,
    import_curve2,
    export_curve,
    export_curve2,
    ie_cost,
    ie_cost2 =
        build_iec_sys()

    @test PowerSystems.is_import_export_curve(import_curve)
    @test PowerSystems.is_import_export_curve(import_curve2)
    @test PowerSystems.is_import_export_curve(export_curve)
    @test PowerSystems.is_import_export_curve(export_curve2)

    @test get_operation_cost(source) isa ImportExportCost
    @test get_operation_cost(source2) isa ImportExportCost
end

@testset "ImportExportCost cost_function_timeseries scalar" begin
    sys,
    source,
    source2,
    import_curve,
    import_curve2,
    export_curve,
    export_curve2,
    ie_cost,
    ie_cost2 =
        build_iec_sys()

    @test get_import_offer_curves(ie_cost) == import_curve
    @test get_export_offer_curves(ie_cost) == export_curve

    @test get_import_variable_cost(source, ie_cost) == import_curve
    @test get_export_variable_cost(source, ie_cost) == export_curve
end

@testset "ImportExportCost static setters" begin
    sys,
    source,
    source2,
    import_curve,
    import_curve2,
    export_curve,
    export_curve2,
    ie_cost,
    ie_cost2 =
        build_iec_sys()

    new_import = make_import_curve([0.0, 50.0, 100.0], [10.0, 20.0])
    set_import_variable_cost!(sys, source, new_import, UnitSystem.NATURAL_UNITS)
    @test get_import_offer_curves(ie_cost) == new_import

    new_export = make_export_curve([0.0, 50.0, 100.0], [20.0, 10.0])
    set_export_variable_cost!(sys, source, new_export, UnitSystem.NATURAL_UNITS)
    @test get_export_offer_curves(ie_cost) == new_export

    # Test unit mismatch throws
    @test_throws ArgumentError set_import_variable_cost!(
        sys, source, new_import, UnitSystem.SYSTEM_BASE)
    @test_throws ArgumentError set_export_variable_cost!(
        sys, source, new_export, UnitSystem.SYSTEM_BASE)
end

@testset "Test HydroReservoirCost getters and setters" begin
    cost = HydroReservoirCost(;
        level_shortage_cost = 1.0,
        level_surplus_cost = 2.0,
        spillage_cost = 3.0,
    )
    @test get_level_shortage_cost(cost) == 1.0
    @test get_level_surplus_cost(cost) == 2.0
    @test get_spillage_cost(cost) == 3.0

    set_level_shortage_cost!(cost, 10.0)
    @test get_level_shortage_cost(cost) == 10.0
    @test get_level_surplus_cost(cost) == 2.0
    @test get_spillage_cost(cost) == 3.0

    set_level_surplus_cost!(cost, 20.0)
    @test get_level_surplus_cost(cost) == 20.0
    @test get_level_shortage_cost(cost) == 10.0
    @test get_spillage_cost(cost) == 3.0

    set_spillage_cost!(cost, 30.0)
    @test get_spillage_cost(cost) == 30.0
    @test get_level_shortage_cost(cost) == 10.0
    @test get_level_surplus_cost(cost) == 20.0
end

# Helpers shared by the time-series cost-resolution tests below.
# Each timestamp gets a *distinct* PiecewiseStepData so that resolving at a known
# `start_time` produces an unambiguous expected slice.
const _TS_RESOLVE_INITIAL_TIME = Dates.DateTime("2020-01-01")
const _TS_RESOLVE_RESOLUTION = Dates.Hour(1)
# Match RTS_GMLC's 24h forecast horizon. First step is distinct so the resolution
# at `_TS_RESOLVE_INITIAL_TIME` is unambiguously identifiable.
const _TS_RESOLVE_PWL_DATA = vcat(
    [PiecewiseStepData([1.0, 3.0, 5.0], [2.0, 4.0])],
    fill(PiecewiseStepData([2.0, 4.0, 6.0], [3.0, 5.0]), 23),
)

function _attach_pwl_forecast(sys, component, name)
    fcst = IS.Deterministic(;
        data = SortedDict(_TS_RESOLVE_INITIAL_TIME => _TS_RESOLVE_PWL_DATA),
        name = name,
        resolution = _TS_RESOLVE_RESOLUTION,
    )
    return add_time_series!(sys, component, fcst)
end

function _attach_linear_forecast(sys, component, name)
    fcst = IS.Deterministic(;
        data = SortedDict(
            _TS_RESOLVE_INITIAL_TIME => fill(IS.LinearFunctionData(1.0, 0.0), 24),
        ),
        name = name,
        resolution = _TS_RESOLVE_RESOLUTION,
    )
    return add_time_series!(sys, component, fcst)
end

@testset "MarketBidTimeSeriesCost resolves variable cost at start_time" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")

    inc_key = _attach_pwl_forecast(sys, generator, "inc_offer")
    dec_key = _attach_pwl_forecast(sys, generator, "dec_offer")
    nl_key = _attach_linear_forecast(sys, generator, "no_load")
    sd_key = _attach_linear_forecast(sys, generator, "shut_down")

    timestamps = range(_TS_RESOLVE_INITIAL_TIME; step = _TS_RESOLVE_RESOLUTION, length = 24)
    su_ta = TimeSeries.TimeArray(
        collect(timestamps),
        fill((0.0, 0.0, 0.0), 24),
    )
    su_key = add_time_series!(
        sys, generator,
        IS.SingleTimeSeries(; name = "start_up_stages_var", data = su_ta),
    )

    mbtc = MarketBidTimeSeriesCost(;
        no_load_cost = IS.TimeSeriesLinearCurve(nl_key),
        start_up = TupleTimeSeries{PSY.StartUpStages}(su_key),
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
    )
    # NOTE: not calling set_operation_cost! because ThermalStandard.operation_cost
    # is typed Union{MarketBidCost, ThermalGenerationCost} and does not yet accept
    # MarketBidTimeSeriesCost. See PR follow-up about wiring TS cost types into
    # device unions.

    inc_resolved = get_variable_cost(generator, mbtc; start_time = _TS_RESOLVE_INITIAL_TIME)
    @test get_function_data(get_value_curve(inc_resolved)) == _TS_RESOLVE_PWL_DATA[1]

    dec_resolved =
        get_decremental_variable_cost(
            generator,
            mbtc;
            start_time = _TS_RESOLVE_INITIAL_TIME,
        )
    @test get_function_data(get_value_curve(dec_resolved)) == _TS_RESOLVE_PWL_DATA[1]

    @test_throws ArgumentError get_variable_cost(generator, mbtc)
    @test_throws ArgumentError get_decremental_variable_cost(generator, mbtc)
end

@testset "MarketBidTimeSeriesCost resolves start_up via TupleTimeSeries" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")

    inc_key = _attach_pwl_forecast(sys, generator, "inc_offer")
    dec_key = _attach_pwl_forecast(sys, generator, "dec_offer")
    nl_key = _attach_linear_forecast(sys, generator, "no_load")
    sd_key = _attach_linear_forecast(sys, generator, "shut_down")

    # Build a SingleTimeSeries of NTuple{3, Float64} distinct per timestamp so that
    # the resolved value at a chosen start_time is unambiguous.
    timestamps = range(_TS_RESOLVE_INITIAL_TIME; step = _TS_RESOLVE_RESOLUTION, length = 24)
    su_values = [(Float64(i), Float64(i) + 10.0, Float64(i) + 20.0) for i in 1:24]
    su_ta = TimeSeries.TimeArray(collect(timestamps), su_values)
    su_sts = IS.SingleTimeSeries(; name = "start_up_stages", data = su_ta)
    su_key = add_time_series!(sys, generator, su_sts)

    mbtc = MarketBidTimeSeriesCost(;
        no_load_cost = IS.TimeSeriesLinearCurve(nl_key),
        start_up = TupleTimeSeries{PSY.StartUpStages}(su_key),
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
    )

    @test get_start_up(mbtc) isa TupleTimeSeries{PSY.StartUpStages}

    resolved_first =
        get_start_up(generator, mbtc; start_time = _TS_RESOLVE_INITIAL_TIME)
    @test resolved_first isa PSY.StartUpStages
    @test resolved_first == (hot = 1.0, warm = 11.0, cold = 21.0)

    resolved_fifth = get_start_up(
        generator, mbtc;
        start_time = _TS_RESOLVE_INITIAL_TIME + Dates.Hour(4),
    )
    @test resolved_fifth == (hot = 5.0, warm = 15.0, cold = 25.0)

    @test_throws ArgumentError get_start_up(generator, mbtc)
end

@testset "ImportExportTimeSeriesCost resolves import/export costs at start_time" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")

    imp_key = _attach_pwl_forecast(sys, generator, "import_offer")
    exp_key = _attach_pwl_forecast(sys, generator, "export_offer")

    iec = ImportExportTimeSeriesCost(;
        import_offer_curves = make_import_export_ts_curve(imp_key),
        export_offer_curves = make_import_export_ts_curve(exp_key),
    )
    # NOTE: not calling set_operation_cost! — see comment above.

    imp_resolved =
        get_import_variable_cost(generator, iec; start_time = _TS_RESOLVE_INITIAL_TIME)
    @test get_function_data(get_value_curve(imp_resolved)) == _TS_RESOLVE_PWL_DATA[1]

    exp_resolved =
        get_export_variable_cost(generator, iec; start_time = _TS_RESOLVE_INITIAL_TIME)
    @test get_function_data(get_value_curve(exp_resolved)) == _TS_RESOLVE_PWL_DATA[1]

    @test_throws ArgumentError get_import_variable_cost(generator, iec)
    @test_throws ArgumentError get_export_variable_cost(generator, iec)
end

@testset "ReserveDemandTimeSeriesCurve resolves variable cost at start_time" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    # `ForecastKey` identifies a time series by name/type/timing — it does not
    # bind to a specific component, so we can bootstrap a key from a throwaway
    # generator and reuse it after attaching the same forecast to the reserve.
    bootstrap = get_component(ThermalStandard, sys, "322_CT_6")
    ts_key = _attach_pwl_forecast(sys, bootstrap, "ordc")

    curve = CostCurve(TimeSeriesPiecewiseIncrementalCurve(ts_key, nothing, nothing))
    reserve = ReserveDemandTimeSeriesCurve{ReserveUp}(;
        variable = curve,
        name = "TestOrdc",
        available = true,
        time_frame = 10.0,
    )
    add_component!(sys, reserve)
    _attach_pwl_forecast(sys, reserve, "ordc")

    resolved = get_variable_cost(reserve; start_time = _TS_RESOLVE_INITIAL_TIME)
    @test get_function_data(get_value_curve(resolved)) == _TS_RESOLVE_PWL_DATA[1]

    @test_throws ArgumentError get_variable_cost(reserve)
end
