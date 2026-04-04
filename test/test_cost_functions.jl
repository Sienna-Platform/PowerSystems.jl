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

@testset "Test MarketBidCost static setters for incremental and decremental curves" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    powers = [22.0, 33.0, 44.0, 55.0]
    marginal_costs = [25.0, 26.0, 28.0]
    initial_input = 50.0
    power_units = UnitSystem.NATURAL_UNITS

    cc = CostCurve(
        PiecewiseIncrementalCurve(initial_input, powers, marginal_costs),
    )
    market_bid = MarketBidCost(;
        incremental_offer_curves = cc,
    )
    set_operation_cost!(generator, market_bid)

    # Test setting incremental variable cost
    cc2 = CostCurve(
        PiecewiseIncrementalCurve(initial_input, powers, marginal_costs .* 1.5),
    )
    set_incremental_variable_cost!(sys, generator, cc2, power_units)
    @test get_incremental_offer_curves(market_bid) == cc2

    # Test setting decremental variable cost
    cc3 = CostCurve(
        PiecewiseIncrementalCurve(initial_input, powers, marginal_costs .* 0.8),
    )
    set_decremental_variable_cost!(sys, generator, cc3, power_units)
    @test get_decremental_offer_curves(market_bid) == cc3
    @test get_decremental_variable_cost(generator, market_bid) == cc3

    # Test unit mismatch throws
    cc_system = CostCurve(
        PiecewiseIncrementalCurve(initial_input, powers, marginal_costs),
        UnitSystem.SYSTEM_BASE,
    )
    @test_throws ArgumentError set_variable_cost!(
        sys, generator, cc_system, UnitSystem.NATURAL_UNITS)
end

@testset "Test `MarketBidCost` with single `start_up` value" begin
    cost = MarketBidCost(LinearCurve(0.0), 1.0, LinearCurve(2.0))
    @test get_start_up(cost) == (hot = 1.0, warm = 0.0, cold = 0.0)

    set_start_up!(cost, 2.0)
    @test get_start_up(cost) == (hot = 2.0, warm = 0.0, cold = 0.0)
end

@testset "Test MarketBidCost defaults and nothing constructor" begin
    mbc = MarketBidCost(nothing)
    @test get_no_load_cost(mbc) == LinearCurve(0.0)
    @test get_start_up(mbc) == (hot = PSY.START_COST, warm = PSY.START_COST, cold = PSY.START_COST)
    @test get_shut_down(mbc) == LinearCurve(0.0)
    @test get_incremental_offer_curves(mbc) == PSY.ZERO_OFFER_CURVE
    @test get_decremental_offer_curves(mbc) == PSY.ZERO_OFFER_CURVE

    mbc2 = MarketBidCost()
    @test get_no_load_cost(mbc2) == LinearCurve(0.0)
    @test get_start_up(mbc2) == (hot = 0.0, warm = 0.0, cold = 0.0)
    @test get_shut_down(mbc2) == LinearCurve(0.0)
end

@testset "Test MarketBidCost no_load_cost and shut_down are LinearCurve" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    market_bid = MarketBidCost(;
        no_load_cost = LinearCurve(1.23),
        shut_down = LinearCurve(3.14),
    )
    set_operation_cost!(generator, market_bid)

    op_cost = get_operation_cost(generator)
    @test get_no_load_cost(op_cost) == LinearCurve(1.23)
    @test get_shut_down(op_cost) == LinearCurve(3.14)

    set_no_load_cost!(op_cost, LinearCurve(5.0))
    @test get_no_load_cost(op_cost) == LinearCurve(5.0)

    set_shut_down!(op_cost, LinearCurve(7.0))
    @test get_shut_down(op_cost) == LinearCurve(7.0)
end

@testset "Test MarketBidCost start_up setters" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    market_bid = MarketBidCost(nothing)
    set_operation_cost!(generator, market_bid)

    op_cost = get_operation_cost(generator)
    @test get_start_up(op_cost) ==
          (hot = PSY.START_COST, warm = PSY.START_COST, cold = PSY.START_COST)

    set_start_up!(op_cost, 3.14)
    @test get_start_up(op_cost) == (hot = 3.14, warm = 0.0, cold = 0.0)

    set_start_up!(op_cost, (hot = 1.23, warm = 2.34, cold = 3.45))
    @test get_start_up(op_cost) == (hot = 1.23, warm = 2.34, cold = 3.45)
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
end

@testset "Test ReserveDemandCurve nothing constructor" begin
    reserve = ReserveDemandCurve{ReserveUp}(nothing)
    @test get_name(reserve) == "init"
    @test get_available(reserve) == false
    @test get_variable(reserve) == PSY.ZERO_OFFER_CURVE
end

@testset "Test fuel cost (scalar and time series)" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generators = collect(get_components(ThermalStandard, sys))
    generator = get_component(ThermalStandard, sys, "322_CT_6")

    op_cost = get_operation_cost(generator)
    value_curve = get_value_curve(get_variable(op_cost))
    set_variable!(op_cost, FuelCurve(value_curve, 0.0))
    @test get_fuel_cost(generator) == 0.0
    @test_throws ArgumentError get_fuel_cost(generator; len = 2)

    set_fuel_cost!(sys, generator, 1.23)
    @test get_fuel_cost(generator) == 1.23

    initial_time = Dates.DateTime("2020-01-01")
    resolution = Dates.Hour(1)
    horizon = 24
    data_float = SortedDict(initial_time => test_costs[Float64])
    forecast_fd = IS.Deterministic("fuel_cost", data_float, resolution)
    set_fuel_cost!(sys, generator, forecast_fd)
    fuel_forecast = get_fuel_cost(generator; start_time = initial_time)
    @test first(TimeSeries.values(fuel_forecast)) == first(data_float[initial_time])
    fuel_forecast = get_fuel_cost(generator)  # missing start_time filled in with initial time
    @test first(TimeSeries.values(fuel_forecast)) == first(data_float[initial_time])
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

    import_curve = make_import_curve(;
        power = [0.0, 100.0, 105.0, 120.0, 200.0],
        price = [5.0, 10.0, 20.0, 40.0],
    )

    import_curve2 = make_import_curve(;
        power = 200.0,
        price = 25.0,
    )

    export_curve = make_export_curve(;
        power = [0.0, 100.0, 105.0, 120.0, 200.0],
        price = [40.0, 20.0, 10.0, 5.0],
    )

    export_curve2 = make_export_curve(;
        power = 200.0,
        price = 45.0,
    )

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

    new_import = make_import_curve(;
        power = [0.0, 50.0, 100.0],
        price = [10.0, 20.0],
    )
    set_import_variable_cost!(sys, source, new_import, UnitSystem.NATURAL_UNITS)
    @test get_import_offer_curves(ie_cost) == new_import

    new_export = make_export_curve(;
        power = [0.0, 50.0, 100.0],
        price = [20.0, 10.0],
    )
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
