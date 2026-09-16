@testset "Test scope-sensitive printing of IS cost functions" begin
    # Make sure the aliases get registered properly
    @test sprint(show, "text/plain", QuadraticCurve) ==
          "QuadraticCurve (alias for InputOutputCurve{QuadraticFunctionData})"

    # Make sure there are no IS-related prefixes in the printouts
    fc = FuelCurve(InputOutputCurve(IS.QuadraticFunctionData(1, 2, 3)), 4.0)
    @test sprint(show, "text/plain", fc) ==
          sprint(show, "text/plain", fc; context = :compact => false) ==
          "FuelCurve:\n  value_curve: QuadraticCurve (a type of InputOutputCurve) where function is: f(x) = 1.0 x^2 + 2.0 x + 3.0\n  fuel_cost: 4.0\n  fuel_cost_time_series: nothing\n  startup_fuel_offtake: LinearCurve (a type of InputOutputCurve) where function is: f(x) = 0.0 x + 0.0\n  vom_cost: LinearCurve (a type of InputOutputCurve) where function is: f(x) = 0.0 x + 0.0\n  power_units: NU"
    @test sprint(show, "text/plain", fc; context = :compact => true) ==
          "FuelCurve with power_units NU, fuel_cost 4.0, fuel_cost_time_series nothing, startup_fuel_offtake LinearCurve(0.0, 0.0), vom_cost LinearCurve(0.0, 0.0), and value_curve:\n  QuadraticCurve (a type of InputOutputCurve) where function is: f(x) = 1.0 x^2 + 2.0 x + 3.0"
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
    # Setters take the explicit unit-system marker and rebuild the cost object,
    # so assertions read the component's current cost.
    set_incremental_variable_cost!(sys, generator, cc2, IS.NaturalUnit())
    @test get_incremental_variable_cost(generator, get_operation_cost(generator)) == cc2

    set_decremental_variable_cost!(sys, generator, cc2, IS.NaturalUnit())
    @test get_decremental_offer_curves(get_operation_cost(generator)) == cc2
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
    IS.AnyCostCurve{QuadraticCurve} =>
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
    @test get_minimum_energy_offer(mbc) == LinearCurve(0.0)
    @test get_start_up(mbc) ==
          (hot = PSY.START_COST, warm = PSY.START_COST, cold = PSY.START_COST)
    @test get_shut_down(mbc) == LinearCurve(0.0)
    @test get_incremental_offer_curves(mbc) == PSY.ZERO_OFFER_CURVE
    @test get_decremental_offer_curves(mbc) == PSY.ZERO_OFFER_CURVE
end

@testset "Test static ORDC on OnlineReserve" begin
    sys = System(100.0)

    cc = CostCurve(
        PiecewiseIncrementalCurve(0.0, [0.0, 100.0, 200.0], [25.0, 30.0]),
    )
    reserve = OnlineReserve{ReserveUp}(;
        variable = cc,
        name = "TestReserve",
        available = true,
        time_frame = 10.0,
    )
    add_component!(sys, reserve)
    @test has_demand_curve(reserve)
    @test get_variable_cost(reserve) == cc
    @test get_variable(reserve) isa IS.AnyCostCurve{PiecewiseIncrementalCurve}

    # Test set_variable_cost! with validation
    cc2 = CostCurve(
        PiecewiseIncrementalCurve(0.0, [0.0, 50.0, 150.0], [20.0, 18.0]),
    )
    set_variable_cost!(sys, reserve, cc2)
    @test get_variable_cost(reserve) == cc2

    # Nothing constructor carries the zero-offer sentinel: no demand curve.
    reserve_nil = OnlineReserve{ReserveUp}(nothing)
    @test get_name(reserve_nil) == "init"
    @test get_available(reserve_nil) == false
    @test get_variable(reserve_nil) == PSY.ZERO_OFFER_CURVE
    @test !has_demand_curve(reserve_nil)
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

    # Setters rebuild the cost object (the unit system is a type parameter),
    # so assertions read the component's current cost.
    new_import = make_import_curve([0.0, 50.0, 100.0], [10.0, 20.0])
    set_import_variable_cost!(sys, source, new_import, IS.NaturalUnit())
    @test get_import_offer_curves(get_operation_cost(source)) == new_import

    new_export = make_export_curve([0.0, 50.0, 100.0], [20.0, 10.0])
    set_export_variable_cost!(sys, source, new_export, IS.NaturalUnit())
    @test get_export_offer_curves(get_operation_cost(source)) == new_export

    # Test unit mismatch throws
    @test_throws ArgumentError set_import_variable_cost!(
        sys, source, new_import, IS.SystemBaseUnit())
    @test_throws ArgumentError set_export_variable_cost!(
        sys, source, new_export, IS.SystemBaseUnit())
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
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
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

@testset "MarketBidTimeSeriesCost resolves start_up at start_time" begin
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
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
    )

    # The field is typed by element, so the key that lands in it is one naming a
    # 3-tuple-valued series and nothing else.
    @test get_start_up(mbtc) isa PSY.StartUpStagesKey
    @test get_start_up(mbtc) === su_key

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

@testset "get_fuel_cost resolves a time-series-backed FuelCurve at start_time" begin
    # `FuelCurve` keeps the fixed value and the time series key in separate fields, so
    # `get_fuel_cost(::StaticInjection)` has to read whichever one is set. A fixed cost
    # ignores `start_time`; a keyed one reads the series through it.
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")

    timestamps = range(_TS_RESOLVE_INITIAL_TIME; step = _TS_RESOLVE_RESOLUTION, length = 24)
    prices = collect(1.0:24.0)
    fuel_key = add_time_series!(
        sys,
        generator,
        IS.SingleTimeSeries(;
            name = "fuel_price",
            data = TimeSeries.TimeArray(collect(timestamps), prices),
        ),
    )

    old_cost = get_operation_cost(generator)
    old_variable = get_variable_operation_cost(old_cost)
    set_operation_cost!(
        generator,
        ThermalGenerationCost(;
            fixed = get_fixed(old_cost),
            shut_down = get_shut_down(old_cost),
            start_up = get_start_up(old_cost),
            variable_operation_cost = FuelCurve(;
                value_curve = get_value_curve(old_variable),
                power_units = get_power_units(old_variable),
                fuel_cost_time_series = fuel_key,
            ),
        ),
    )

    resolved = get_fuel_cost(generator; start_time = _TS_RESOLVE_INITIAL_TIME, len = 3)
    @test TimeSeries.values(resolved) == prices[1:3]
    @test TimeSeries.timestamp(resolved) == collect(timestamps)[1:3]
end

@testset "set_fuel_cost! round-trips a fixed value and a time-series key" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")

    old_cost = get_operation_cost(generator)
    old_variable = get_variable_operation_cost(old_cost)
    set_operation_cost!(
        generator,
        ThermalGenerationCost(;
            fixed = get_fixed(old_cost),
            shut_down = get_shut_down(old_cost),
            start_up = get_start_up(old_cost),
            variable_operation_cost = FuelCurve(;
                value_curve = get_value_curve(old_variable),
                power_units = get_power_units(old_variable),
                fuel_cost = 2.0,
            ),
        ),
    )

    set_fuel_cost!(sys, generator, 9.5)
    updated_variable = get_variable_operation_cost(get_operation_cost(generator))
    @test get_fuel_cost(updated_variable) == 9.5
    @test isnothing(get_fuel_cost_time_series(updated_variable))

    timestamps = range(_TS_RESOLVE_INITIAL_TIME; step = _TS_RESOLVE_RESOLUTION, length = 24)
    prices = collect(1.0:24.0)
    ts = IS.SingleTimeSeries(;
        name = "fuel_price",
        data = TimeSeries.TimeArray(collect(timestamps), prices),
    )
    set_fuel_cost!(sys, generator, ts)
    resolved = get_fuel_cost(generator; start_time = _TS_RESOLVE_INITIAL_TIME, len = 3)
    @test TimeSeries.values(resolved) == prices[1:3]
    @test TimeSeries.timestamp(resolved) == collect(timestamps)[1:3]
end

@testset "Time-series ORDC resolves variable cost at start_time" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    # A key names one stored association, which belongs to one owner — so the reserve's
    # curve has to be built from the key for the forecast attached to the reserve itself.
    # (It used to be legal to bootstrap a key off another component and reuse it, back when
    # a key was name/type/timing and bound to no owner.)
    reserve = OnlineReserve{ReserveUp}(;
        name = "TestOrdc",
        available = true,
        time_frame = 10.0,
    )
    add_component!(sys, reserve)
    ts_key = _attach_pwl_forecast(sys, reserve, "ordc")
    set_variable!(
        reserve,
        CostCurve(TimeSeriesPiecewiseIncrementalCurve(ts_key, nothing, nothing)),
    )

    resolved = get_variable_cost(reserve; start_time = _TS_RESOLVE_INITIAL_TIME)
    @test get_function_data(get_value_curve(resolved)) == _TS_RESOLVE_PWL_DATA[1]

    @test_throws ArgumentError get_variable_cost(reserve)
end

@testset "ImportExportCost positional compat constructor terminates" begin
    iec = ImportExportCost(nothing, nothing, 1.0, 2.0, OnlineReserve{ReserveUp}[])
    @test iec isa ImportExportCost
    @test get_import_offer_curves(iec) == PSY.ZERO_OFFER_CURVE
    @test get_export_offer_curves(iec) == PSY.ZERO_OFFER_CURVE
    @test get_energy_import_weekly_limit(iec) == 1.0
    @test get_energy_export_weekly_limit(iec) == 2.0

    iec2 = ImportExportCost(nothing, nothing, 1.0, 2.0, Service[])
    @test iec2 isa ImportExportCost
end

@testset "is_import_export_curve tolerates nothing offsets" begin
    # ZERO_OFFER_CURVE is built with the 3-arg PiecewiseIncrementalCurve form,
    # which leaves input_at_zero = nothing
    @test PowerSystems.is_import_export_curve(PSY.ZERO_OFFER_CURVE)
    # explicit nonzero offsets disqualify a curve without throwing
    nonzero = CostCurve(PiecewiseIncrementalCurve(5.0, 1.0, [0.0, 100.0], [10.0]))
    @test !PowerSystems.is_import_export_curve(nonzero)
end

# Minimal MarketBidTimeSeriesCost backed by forecasts attached to `component`.
function _build_min_mbtc(sys, component)
    inc_key = _attach_pwl_forecast(sys, component, "inc_offer_len")
    dec_key = _attach_pwl_forecast(sys, component, "dec_offer_len")
    nl_key = _attach_linear_forecast(sys, component, "no_load_len")
    sd_key = _attach_linear_forecast(sys, component, "shut_down_len")
    timestamps =
        range(_TS_RESOLVE_INITIAL_TIME; step = _TS_RESOLVE_RESOLUTION, length = 24)
    su_ta = TimeSeries.TimeArray(collect(timestamps), fill((0.0, 0.0, 0.0), 24))
    su_key = add_time_series!(
        sys, component,
        IS.SingleTimeSeries(; name = "start_up_stages_len", data = su_ta),
    )
    return MarketBidTimeSeriesCost(;
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
    )
end

@testset "TS cost getters resolve single timesteps and windows" begin
    sys = PSB.build_system(PSITestSystems, "c_sys5_uc")
    gen = first(get_components(ThermalStandard, sys))
    mbtc = _build_min_mbtc(sys, gen)
    t0 = _TS_RESOLVE_INITIAL_TIME

    # len = nothing resolves a single static curve
    resolved = get_variable_cost(gen, mbtc; start_time = t0)
    @test get_function_data(get_value_curve(resolved)) == _TS_RESOLVE_PWL_DATA[1]

    # len resolves the whole window with one read per time-series-backed field
    window = get_variable_cost(gen, mbtc; start_time = t0, len = 24)
    @test window isa Vector
    @test length(window) == 24
    @test get_function_data(get_value_curve(window[1])) == _TS_RESOLVE_PWL_DATA[1]
    @test get_function_data(get_value_curve(window[2])) == _TS_RESOLVE_PWL_DATA[2]
    @test only(get_variable_cost(gen, mbtc; start_time = t0, len = 1)) == resolved

    nl_window = get_minimum_energy_offer(gen, mbtc; start_time = t0, len = 24)
    @test nl_window isa Vector
    @test length(nl_window) == 24

    # static-curve setters refuse time-series-backed costs (the setter path is
    # not reachable through set_operation_cost! yet — device cost unions do not
    # accept TS cost types — so exercise the chokepoint directly)
    @test_throws ArgumentError PSY._replace_offer_curve(
        mbtc, :incremental, PSY.ZERO_OFFER_CURVE)
end

@testset "set_variable_cost! rebuilds MarketBidCost with the data units" begin
    sys = System(100.0)
    gen = ThermalStandard(nothing)
    set_operation_cost!(gen, MarketBidCost(nothing))  # MarketBidCost{NaturalUnit}
    @test get_operation_cost(gen) isa MarketBidCost{IS.NaturalUnit}

    data = CostCurve(
        PiecewiseIncrementalCurve(0.0, [0.0, 1.0], [10.0]),
        IS.SystemBaseUnit(),
    )
    set_variable_cost!(sys, gen, data, IS.SystemBaseUnit())
    new_cost = get_operation_cost(gen)
    @test new_cost isa MarketBidCost{IS.SystemBaseUnit}
    @test get_incremental_offer_curves(new_cost) == data
    # untouched fields carry over
    @test get_start_up(new_cost) ==
          (hot = PSY.START_COST, warm = PSY.START_COST, cold = PSY.START_COST)
end

@testset "set_import/export_variable_cost! rebuild ImportExportCost units" begin
    sys = System(100.0)
    source = Source(nothing)
    set_operation_cost!(source, ImportExportCost())  # both placeholders, NaturalUnit
    new_import = make_import_curve([0.0, 0.5, 1.0], [10.0, 20.0], IS.SystemBaseUnit())
    set_import_variable_cost!(sys, source, new_import, IS.SystemBaseUnit())
    cost = get_operation_cost(source)
    @test cost isa ImportExportCost{IS.SystemBaseUnit}
    @test get_import_offer_curves(cost) == new_import

    # a real (non-placeholder) opposite-side curve in a different unit system
    # cannot be silently re-tagged and is rejected
    sysb, sourceb, = build_iec_sys()
    @test_throws ArgumentError set_import_variable_cost!(
        sysb, sourceb, new_import, IS.SystemBaseUnit())
end
