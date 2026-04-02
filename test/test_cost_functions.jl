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
        shut_down = 0.0,
        incremental_offer_curves = cc,
    )
    set_operation_cost!(generator, mbc)
    @test get_operation_cost(generator) isa MarketBidCost

    @test get_incremental_offer_curves(generator, mbc) == cc
    @test isnothing(get_decremental_offer_curves(generator, mbc))

    @test get_variable_cost(generator, mbc) == cc
    @test get_incremental_variable_cost(generator, mbc) == cc
    @test isnothing(get_decremental_variable_cost(generator, mbc))

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

@testset "Test MarketBidCost with Quadratic Cost Timeseries" begin
    # Will throw TypeErrors because market bids must be piecewise, not quadratic and service
    # bids must be piecewise, not scalar
    initial_time = Dates.DateTime("2020-01-01")
    resolution = Dates.Hour(1)
    name = "test"
    horizon = 24
    service_data = Dict(initial_time => rand(horizon))
    data_quadratic =
        SortedDict(initial_time => test_costs[CostCurve{QuadraticCurve}])
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    market_bid = MarketBidCost(nothing)
    set_operation_cost!(generator, market_bid)
    forecast_fd = IS.Deterministic(
        "variable_cost",
        Dict(k => get_function_data.(v) for (k, v) in pairs(data_quadratic)),
        resolution,
    )
    power_units = UnitSystem.NATURAL_UNITS
    @test_throws TypeError set_variable_cost!(sys, generator, forecast_fd, power_units)
    for s in generator.services
        forecast_fd = IS.Deterministic(get_name(s), service_data, resolution)
        @test_throws TypeError set_service_bid!(sys, generator, s, forecast_fd, power_units)
    end
end

@testset "Test MarketBidCost with PiecewiseLinearData Cost Timeseries with Service Bid Forecast" begin
    initial_time = Dates.DateTime("2020-01-01")
    resolution = Dates.Hour(1)
    name = "test"
    horizon = 24
    power_units = UnitSystem.NATURAL_UNITS
    data_pwl = SortedDict(initial_time => test_costs[PiecewiseStepData])
    service_data = data_pwl
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    market_bid = MarketBidCost(nothing)
    set_operation_cost!(generator, market_bid)
    forecast_fd = Deterministic(
        "variable_cost",
        Dict(k => get_function_data.(v) for (k, v) in pairs(data_pwl)),
        resolution,
    )
    @test_throws ArgumentError set_variable_cost!(
        sys,
        generator,
        forecast_fd,
        UnitSystem.SYSTEM_BASE,
    )
    set_variable_cost!(sys, generator, forecast_fd, power_units)

    for s in generator.services
        forecast_fd = Deterministic(
            get_name(s),
            Dict(k => get_function_data.(v) for (k, v) in pairs(service_data)),
            resolution,
        )
        @test_throws ArgumentError set_service_bid!(
            sys,
            generator,
            s,
            forecast_fd,
            UnitSystem.SYSTEM_BASE,
        )
        set_service_bid!(sys, generator, s, forecast_fd, power_units)
    end

    iocs = get_incremental_offer_curves(generator, market_bid)
    @test isequal(
        first(TimeSeries.values(iocs)),
        get_function_data(first(data_pwl[initial_time])),
    )
    cost_forecast = get_variable_cost(generator, market_bid; start_time = initial_time)
    @test isequal(first(TimeSeries.values(cost_forecast)), first(data_pwl[initial_time]))

    for s in generator.services
        service_cost = get_services_bid(generator, market_bid, s; start_time = initial_time)
        @test isequal(
            first(TimeSeries.values(service_cost)),
            first(service_data[initial_time]),
        )
    end
end

@testset "Test MarketBidCost with PiecewiseLinearData Cost Timeseries, initial_input, and no_load_cost" begin
    initial_time = Dates.DateTime("2020-01-01")
    resolution = Dates.Hour(1)
    name = "test"
    horizon = 24
    power_units = UnitSystem.NATURAL_UNITS
    data_pwl = SortedDict(initial_time => test_costs[PiecewiseIncrementalCurve])
    service_data = data_pwl
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    market_bid = MarketBidCost(nothing)
    set_operation_cost!(generator, market_bid)
    forecast_fd = IS.Deterministic(
        "variable_cost_function_data",
        Dict(k => get_function_data.(v) for (k, v) in pairs(data_pwl)),
        resolution,
    )
    set_variable_cost!(sys, generator, forecast_fd, power_units)

    forecast_ii = IS.Deterministic(
        "variable_cost_initial_input",
        Dict(k => get_initial_input.(get_value_curve.(v)) for (k, v) in pairs(data_pwl)),
        resolution,
    )
    PSY.set_incremental_initial_input!(sys, generator, forecast_ii)

    forecast_iaz = IS.Deterministic(
        "variable_cost_input_at_zero",
        Dict(k => get_input_at_zero.(get_value_curve.(v)) for (k, v) in pairs(data_pwl)),
        resolution,
    )
    set_no_load_cost!(sys, generator, forecast_iaz)

    iocs = get_incremental_offer_curves(generator, market_bid)
    @test isequal(
        first(TimeSeries.values(iocs)),
        get_function_data(first(data_pwl[initial_time])),
    )
    cost_forecast = get_variable_cost(generator, market_bid; start_time = initial_time)
    @test isequal(first(TimeSeries.values(cost_forecast)), first(data_pwl[initial_time]))
end

@testset "Test MarketBidCost with Decremental PiecewiseLinearData Cost Timeseries, initial_input, and no_load_cost" begin
    initial_time = Dates.DateTime("2020-01-01")
    resolution = Dates.Hour(1)
    name = "test"
    horizon = 24
    power_units = UnitSystem.NATURAL_UNITS
    data_pwl = SortedDict(initial_time => test_costs[PiecewiseIncrementalCurve])
    service_data = data_pwl
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    market_bid = MarketBidCost(nothing)
    set_operation_cost!(generator, market_bid)
    forecast_fd = IS.Deterministic(
        "decremental_variable_cost_function_data",
        Dict(k => get_function_data.(v) for (k, v) in pairs(data_pwl)),
        resolution,
    )
    set_decremental_variable_cost!(sys, generator, forecast_fd, power_units)

    forecast_ii = IS.Deterministic(
        "decremental_variable_cost_initial_input",
        Dict(k => get_initial_input.(get_value_curve.(v)) for (k, v) in pairs(data_pwl)),
        resolution,
    )
    PSY.set_decremental_initial_input!(sys, generator, forecast_ii)

    forecast_iaz = IS.Deterministic(
        "variable_cost_input_at_zero",
        Dict(k => get_input_at_zero.(get_value_curve.(v)) for (k, v) in pairs(data_pwl)),
        resolution,
    )
    set_no_load_cost!(sys, generator, forecast_iaz)

    iocs = get_decremental_offer_curves(generator, market_bid)
    isequal(first(TimeSeries.values(iocs)), first(data_pwl[initial_time]))
    cost_forecast =
        get_decremental_variable_cost(generator, market_bid; start_time = initial_time)
    @test isequal(first(TimeSeries.values(cost_forecast)), first(data_pwl[initial_time]))
end

@testset "Test `MarketBidCost` with single `start_up` value" begin
    cost = MarketBidCost(0.0, 1.0, 2.0)
    @test get_start_up(cost) == (hot = 1.0, warm = 0.0, cold = 0.0)

    set_start_up!(cost, 2.0)
    @test get_start_up(cost) == (hot = 2.0, warm = 0.0, cold = 0.0)
end

@testset "Test ReserveDemandCurve with Cost Timeseries" begin
    initial_time = Dates.DateTime("2020-01-01")
    resolution = Dates.Hour(1)
    other_time = initial_time + resolution
    name = "test"
    horizon = 24
    data_pwl = SortedDict(initial_time => test_costs[PiecewiseStepData],
        other_time => test_costs[PiecewiseStepData])
    sys = System(100.0)
    reserve = ReserveDemandCurve{ReserveUp}(nothing)
    add_component!(sys, reserve)
    forecast_fd = IS.Deterministic(
        "variable_cost",
        Dict(k => get_function_data.(v) for (k, v) in pairs(data_pwl)),
        resolution,
    )
    set_variable_cost!(sys, reserve, forecast_fd)
    cost_forecast = get_variable_cost(reserve; start_time = initial_time)
    @test isequal(first(TimeSeries.values(cost_forecast)), first(data_pwl[initial_time]))
end

@testset "Test ReserveDemandCurve with Time Varying PWL Cost" begin
    initial_time = Dates.DateTime("2020-01-01")
    resolution = Dates.Hour(1)
    other_time = initial_time + resolution

    # Create time varying PWL cost data using PiecewiseIncrementalCurve
    data_pwl_incremental = SortedDict(
        initial_time => test_costs[PiecewiseIncrementalCurve],
        other_time => test_costs[PiecewiseIncrementalCurve],
    )

    # Create system and reserve product
    sys = System(100.0)
    reserve = ReserveDemandCurve{ReserveUp}(
        nothing,  # variable - will be set via set_variable_cost!
        "TestReserveProduct",
        true,
        10.0,  # time_frame
        3600.0,  # sustained_time
        1.0,  # max_participation_factor
        0.0,  # deployed_fraction
    )
    add_component!(sys, reserve)

    # Attach time varying cost to the reserve product
    forecast_fd = IS.Deterministic(
        "variable_cost",
        Dict(k => get_function_data.(v) for (k, v) in pairs(data_pwl_incremental)),
        resolution,
    )
    set_variable_cost!(sys, reserve, forecast_fd)

    # Retrieve and verify the time varying cost data
    cost_forecast = get_variable_cost(reserve; start_time = initial_time)
    retrieved_curve = first(TimeSeries.values(cost_forecast))
    original_curve = first(data_pwl_incremental[initial_time])

    # Compare function data (x and y coordinates)
    @test get_function_data(retrieved_curve) == get_function_data(original_curve)

    # Verify we can retrieve cost at the second time point
    cost_forecast_second = get_variable_cost(reserve; start_time = other_time)
    retrieved_curve_second = first(TimeSeries.values(cost_forecast_second))
    original_curve_second = first(data_pwl_incremental[other_time])

    # Compare function data
    @test get_function_data(retrieved_curve_second) ==
          get_function_data(original_curve_second)

    # Verify the reserve has the time series attached
    @test has_time_series(reserve)
    @test length(get_time_series_keys(reserve)) == 1
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
@testset "Test MarketBidCost no-load cost (single number and time series)" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generators = collect(get_components(ThermalStandard, sys))
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    market_bid = MarketBidCost(nothing)
    set_operation_cost!(generator, market_bid)

    op_cost = get_operation_cost(generator)
    @test get_no_load_cost(generator, op_cost) === nothing

    set_no_load_cost!(sys, generator, 1.23)
    @test get_no_load_cost(generator, op_cost) == 1.23

    initial_time = Dates.DateTime("2020-01-01")
    resolution = Dates.Hour(1)
    horizon = 24
    data_float = SortedDict(initial_time => test_costs[Float64])
    forecast_fd = IS.Deterministic("no_load_cost", data_float, resolution)

    set_no_load_cost!(sys, generator, forecast_fd)
    @test first(TimeSeries.values(get_no_load_cost(generator, op_cost))) ==
          first(data_float[initial_time])
end

@testset "Test MarketBidCost startup cost (single number, tuple, and time series)" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generators = collect(get_components(ThermalStandard, sys))
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    market_bid = MarketBidCost(nothing)
    set_operation_cost!(generator, market_bid)

    op_cost = get_operation_cost(generator)
    @test get_start_up(op_cost) ==
          (hot = PSY.START_COST, warm = PSY.START_COST, cold = PSY.START_COST)
    @test get_start_up(generator, op_cost) ==
          (hot = PSY.START_COST, warm = PSY.START_COST, cold = PSY.START_COST)

    set_start_up!(sys, generator, 3.14)
    @test get_start_up(op_cost) == (hot = 3.14, warm = 0.0, cold = 0.0)
    @test get_start_up(generator, op_cost) == (hot = 3.14, warm = 0.0, cold = 0.0)

    set_start_up!(sys, generator, (hot = 1.23, warm = 2.34, cold = 3.45))
    @test get_start_up(op_cost) == (hot = 1.23, warm = 2.34, cold = 3.45)
    @test get_start_up(generator, op_cost) == (hot = 1.23, warm = 2.34, cold = 3.45)

    initial_time = Dates.DateTime("2020-01-01")
    resolution = Dates.Hour(1)
    horizon = 24
    data_sus = SortedDict(initial_time => test_costs[PSY.StartUpStages])
    forecast_fd = IS.Deterministic(
        "start_up",
        Dict(k => Tuple.(v) for (k, v) in pairs(data_sus)),
        resolution,
    )

    set_start_up!(sys, generator, forecast_fd)
    @test first(TimeSeries.values(get_start_up(generator, op_cost))) ==
          first(data_sus[initial_time])
end

@testset "Test MarketBidCost shutdown cost (single number and time series)" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generators = collect(get_components(ThermalStandard, sys))
    generator = get_component(ThermalStandard, sys, "322_CT_6")
    market_bid = MarketBidCost(nothing)
    set_operation_cost!(generator, market_bid)

    op_cost = get_operation_cost(generator)
    @test get_shut_down(op_cost) == 0.0
    @test get_shut_down(generator, op_cost) == 0.0

    set_shut_down!(sys, generator, 3.14)
    @test get_shut_down(op_cost) == 3.14
    @test get_shut_down(generator, op_cost) == 3.14

    initial_time = Dates.DateTime("2020-01-01")
    resolution = Dates.Hour(1)
    horizon = 24
    data_float = SortedDict(initial_time => test_costs[Float64])
    forecast_fd = IS.Deterministic("fuel_cost", data_float, resolution)

    set_shut_down!(sys, generator, forecast_fd)
    @test first(TimeSeries.values(get_shut_down(generator, op_cost))) ==
          first(data_float[initial_time])
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

    @test get_import_offer_curves(source, ie_cost) == import_curve
    @test get_export_offer_curves(source, ie_cost) == export_curve

    @test get_import_variable_cost(source, ie_cost) == import_curve
    @test get_export_variable_cost(source, ie_cost) == export_curve
end

@testset "ImportExportCost cost_function_timeseries time series" begin
    initial_time = Dates.DateTime("2024-01-01")
    resolution = Dates.Hour(1)
    other_time = initial_time + resolution
    name = "test"
    horizon = 24

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

    import_fd_array = repeat(
        [
            make_import_curve(;
                power = [0.0, 100.0, 105.0, 120.0, 200.0],
                price = [5.0, 10.0, 20.0, 40.0])], 24)

    export_fd_array = repeat(
        [
            make_export_curve(;
                power = [0.0, 100.0, 105.0, 120.0, 200.0],
                price = [40.0, 20.0, 10.0, 5.0])], 24)

    import_sd = SortedDict(initial_time => import_fd_array,
        other_time => import_fd_array)
    export_sd = SortedDict(initial_time => export_fd_array,
        other_time => export_fd_array)

    import_curve = IS.Deterministic(
        "import_variable_cost",
        Dict(k => get_function_data.(v) for (k, v) in pairs(import_sd)),
        resolution,
    )
    export_curve = IS.Deterministic(
        "export_variable_cost",
        Dict(k => get_function_data.(v) for (k, v) in pairs(export_sd)),
        resolution,
    )

    set_import_variable_cost!(sys, source, import_curve, UnitSystem.NATURAL_UNITS)
    set_export_variable_cost!(sys, source, export_curve, UnitSystem.NATURAL_UNITS)

    iocs = get_import_offer_curves(source, ie_cost)
    @test isequal(
        first(TimeSeries.values(iocs)),
        get_function_data(first(import_sd[initial_time])),
    )
    cost_forecast_i = get_import_variable_cost(source, ie_cost; start_time = initial_time)
    @test isequal(first(TimeSeries.values(cost_forecast_i)), first(import_sd[initial_time]))

    eocs = get_export_offer_curves(source, ie_cost)
    @test isequal(
        first(TimeSeries.values(eocs)),
        get_function_data(first(export_sd[initial_time])),
    )
    cost_forecast_e = get_export_variable_cost(source, ie_cost; start_time = initial_time)
    @test isequal(first(TimeSeries.values(cost_forecast_e)), first(export_sd[initial_time]))
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
