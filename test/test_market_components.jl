@testset "Market component abstract hierarchy" begin
    @test PSY.MarketComponent <: PSY.Component
    @test PSY.MarketTransaction <: PSY.MarketComponent
    @test IS.supports_time_series(TradingHub(nothing))
end

@testset "TradingHub membership and round-trip" begin
    sys, b1, b2, hub = _market_hub_fixture()
    @test get_associated_buses(get_component(TradingHub, sys, "western_hub")) == [b1, b2]

    # a hub with a detached bus must be rejected loudly
    b3 = ACBus(; number = 3, name = "b3", available = true, bustype = ACBusTypes.PQ,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 230.0)
    bad = TradingHub(; name = "bad_hub", buses = [b3])
    @test_throws ArgumentError add_component!(sys, bad)

    # serialization round-trip: buses encode as ids, resolve on read-back
    sys2 = roundtrip_system(sys)
    hub2 = get_component(TradingHub, sys2, "western_hub")
    @test get_name.(get_associated_buses(hub2)) == ["b1", "b2"]
end

@testset "CurveStyles numeric contract" begin
    # The wire representation (SiennaSchemas' `curve_style` field) is a plain integer,
    # not the string-enum convention used elsewhere in the schemas; pin the mapping.
    @test CurveStyles.CURVE.value == 0
    @test CurveStyles.FIXED.value == 1
    @test CurveStyles.VARIABLE.value == 2
end

@testset "MarketBidCost extensions" begin
    c = MarketBidCost(; incremental_slope = true)
    @test get_incremental_slope(c)
    @test !get_decremental_slope(c)
    @test !get_incremental_slope(MarketBidCost(nothing))
    @test get_curve_style(MarketBidCost(nothing)) == CurveStyles.CURVE

    c2 = MarketBidCost(; curve_style = CurveStyles.FIXED)
    @test get_curve_style(c2) == CurveStyles.FIXED

    @test_throws ArgumentError MarketBidCost(;
        incremental_slope = true,
        curve_style = CurveStyles.FIXED,
    )
    @test_throws ArgumentError MarketBidCost(;
        decremental_slope = true,
        curve_style = CurveStyles.VARIABLE,
    )
end

@testset "MarketBidTimeSeriesCost extensions" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    generator = ThermalStandard(nothing)
    generator.name = "market_gen_ext"
    generator.bus = bus
    add_component!(sys, generator)

    inc_key = _attach_pwl_forecast(sys, generator, "inc_offer_ext")
    dec_key = _attach_pwl_forecast(sys, generator, "dec_offer_ext")
    nl_key = _attach_linear_forecast(sys, generator, "no_load_ext")
    sd_key = _attach_linear_forecast(sys, generator, "shut_down_ext")
    timestamps =
        range(_TS_RESOLVE_INITIAL_TIME; step = _TS_RESOLVE_RESOLUTION, length = 24)

    su_ta = TimeSeries.TimeArray(collect(timestamps), fill((0.0, 0.0, 0.0), 24))
    su_key = add_time_series!(
        sys, generator,
        IS.SingleTimeSeries(; name = "start_up_stages_ext", data = su_ta),
    )

    mbtc = MarketBidTimeSeriesCost(;
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
    )
    @test !get_incremental_slope(mbtc)
    @test !get_decremental_slope(mbtc)
    @test get_curve_style(mbtc) == CurveStyles.CURVE

    mbtc_slope = MarketBidTimeSeriesCost(;
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
        incremental_slope = true,
    )
    @test get_incremental_slope(mbtc_slope)

    mbtc_fixed = MarketBidTimeSeriesCost(;
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
        curve_style = CurveStyles.FIXED,
    )
    @test get_curve_style(mbtc_fixed) == CurveStyles.FIXED

    @test_throws ArgumentError MarketBidTimeSeriesCost(;
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
        incremental_slope = true,
        curve_style = CurveStyles.FIXED,
    )
    @test_throws ArgumentError MarketBidTimeSeriesCost(;
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
        decremental_slope = true,
        curve_style = CurveStyles.VARIABLE,
    )
end

@testset "CurveStyles round-trips through JSON serialization" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.name = "curve_style_gen"
    gen.bus = bus
    add_component!(sys, gen)
    mbc = MarketBidCost(;
        start_up = (hot = 0.0, warm = 0.0, cold = 0.0),
        curve_style = CurveStyles.FIXED,
    )
    set_operation_cost!(gen, mbc)

    sys2 = roundtrip_system(sys)
    gen2 = get_component(ThermalStandard, sys2, "curve_style_gen")
    @test get_curve_style(get_operation_cost(gen2)) == CurveStyles.FIXED
end

@testset "MarketBidTimeSeriesCost keys survive JSON round trip as association ids" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.name = "market_gen"
    gen.bus = bus
    add_component!(sys, gen)

    inc_key = _attach_pwl_forecast(sys, gen, "inc_offer_rt")
    dec_key = _attach_pwl_forecast(sys, gen, "dec_offer_rt")
    nl_key = _attach_linear_forecast(sys, gen, "no_load_rt")
    sd_key = _attach_linear_forecast(sys, gen, "shut_down_rt")
    timestamps =
        range(_TS_RESOLVE_INITIAL_TIME; step = _TS_RESOLVE_RESOLUTION, length = 24)
    su_ta = TimeSeries.TimeArray(collect(timestamps), fill((1.5, 2.5, 3.5), 24))
    su_key = add_time_series!(
        sys, gen,
        IS.SingleTimeSeries(; name = "start_up_stages_rt", data = su_ta),
    )
    mbtc = MarketBidTimeSeriesCost(;
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
    )
    set_operation_cost!(gen, mbtc)
    original_su_values = get_time_series_values(gen, su_key)

    sys2 = roundtrip_system(sys)
    gen2 = get_component(ThermalStandard, sys2, "market_gen")
    cost2 = get_operation_cost(gen2)
    su_key2 = get_start_up(cost2)
    @test su_key2 == su_key
    for field in fieldnames(typeof(su_key))
        @test getproperty(su_key2, field) == getproperty(su_key, field)
    end
    @test get_time_series_values(gen2, su_key2) == original_su_values

    inc_fd = get_function_data(get_value_curve(get_incremental_offer_curves(cost2)))
    @test IS.get_time_series_key(inc_fd) == inc_key
end

@testset "VirtualParticipant location modes and hub bids" begin
    sys, b1, b2, hub = _market_hub_fixture()

    vp = VirtualParticipant(; name = "vp1", available = true,
        max_supply = 100.0, max_demand = 50.0, operation_cost = MarketBidCost(nothing))
    add_component!(sys, vp)
    add_trading_hub!(sys, vp, hub)
    @test has_trading_hub(vp, hub)
    @test get_contributing_virtuals(sys, hub) == [vp]

    # both location modes set at once is rejected on add
    vp2 = VirtualParticipant(; name = "vp2", available = true, settlement_point = b1,
        trading_hubs = [hub], max_supply = 10.0, max_demand = 0.0,
        operation_cost = MarketBidCost(nothing))
    @test_throws ArgumentError add_component!(sys, vp2)

    # hub bid: name-keyed series, hub association required first
    dates = collect(DateTime("2026-01-01T00:00:00"):Hour(1):DateTime("2026-01-01T01:00:00"))
    data = PiecewiseStepData.(
        [[0.0, 50.0, 100.0], [0.0, 50.0, 100.0]],
        [[25.0, 30.0], [26.0, 31.0]],
    )
    ta = TimeSeries.TimeArray(dates, data)
    ts = SingleTimeSeries(; name = get_name(hub), data = ta)

    vp_noassoc = VirtualParticipant(; name = "vp_noassoc", available = true,
        max_supply = 5.0, max_demand = 5.0, operation_cost = MarketBidCost(nothing))
    add_component!(sys, vp_noassoc)
    @test_throws ErrorException set_hub_bid!(sys, vp_noassoc, hub, ts, IS.NaturalUnit())

    set_hub_bid!(sys, vp, hub, ts, IS.NaturalUnit())
    @test get_time_series(SingleTimeSeries, vp, get_name(hub)) isa SingleTimeSeries

    # duplicate hub bid is rejected loudly, not silently overwritten
    @test_throws ErrorException set_hub_bid!(sys, vp, hub, ts, IS.NaturalUnit())

    # wrong-eltype time series is rejected with an actionable error
    bad_ta = TimeSeries.TimeArray(dates, [1.0, 2.0])
    bad_ts = SingleTimeSeries(; name = get_name(hub), data = bad_ta)
    vp_bad = VirtualParticipant(; name = "vp_bad", available = true,
        max_supply = 5.0, max_demand = 5.0, operation_cost = MarketBidCost(nothing))
    add_component!(sys, vp_bad)
    add_trading_hub!(sys, vp_bad, hub)
    @test_throws TypeError set_hub_bid!(sys, vp_bad, hub, bad_ts, IS.NaturalUnit())

    # remove_trading_hub! / clear_trading_hubs!
    remove_trading_hub!(vp_bad, hub)
    @test !has_trading_hub(vp_bad, hub)
    add_trading_hub!(sys, vp_bad, hub)
    clear_trading_hubs!(vp_bad)
    @test !has_trading_hub(vp_bad, hub)

    # removing a hub strips it from every contributing virtual participant
    hub2 = TradingHub(; name = "removable_hub", buses = [b1])
    add_component!(sys, hub2)
    add_trading_hub!(sys, vp_bad, hub2)
    @test has_trading_hub(vp_bad, hub2)
    remove_component!(sys, hub2)
    @test !has_trading_hub(vp_bad, hub2)

    # nodal round-trip: settlement_point encodes as id
    vp3 = VirtualParticipant(; name = "vp3", available = true, settlement_point = b2,
        max_supply = 10.0, max_demand = 10.0, operation_cost = MarketBidCost(nothing))
    add_component!(sys, vp3)
    sys2 = roundtrip_system(sys)
    @test get_name(get_settlement_point(get_component(VirtualParticipant, sys2, "vp3"))) ==
          "b2"
    @test get_name.(get_trading_hubs(get_component(VirtualParticipant, sys2, "vp1"))) ==
          ["western_hub"]
end

@testset "VirtualParticipant detached settlement point rejected on add" begin
    sys = System(100.0)
    detached_bus = ACBus(; number = 99, name = "detached", available = true,
        bustype = ACBusTypes.PQ, angle = 0.0, magnitude = 1.0,
        voltage_limits = (min = 0.9, max = 1.1), base_voltage = 230.0)
    vp = VirtualParticipant(; name = "vp_detached", available = true,
        settlement_point = detached_bus, max_supply = 10.0, max_demand = 10.0,
        operation_cost = MarketBidCost(nothing))
    @test_throws ArgumentError add_component!(sys, vp)
end

@testset "add_trading_hub! rejects a VP with settlement_point set" begin
    sys, b1, b2, hub = _market_hub_fixture()
    vp = VirtualParticipant(; name = "vp_settled", available = true, settlement_point = b1,
        max_supply = 10.0, max_demand = 0.0, operation_cost = MarketBidCost(nothing))
    add_component!(sys, vp)
    @test_throws ArgumentError add_trading_hub!(sys, vp, hub)
end

@testset "add_component! rejects a VP carrying a detached trading hub" begin
    sys, b1, b2, hub = _market_hub_fixture()
    detached_hub = TradingHub(; name = "detached_hub", buses = [b1])
    vp = VirtualParticipant(; name = "vp_detached_hub", available = true,
        trading_hubs = [detached_hub], max_supply = 10.0, max_demand = 0.0,
        operation_cost = MarketBidCost(nothing))
    @test_throws ArgumentError add_component!(sys, vp)
end

@testset "TradingHub removal is refused while a PointToPointBid terminates on it" begin
    sys, b1, b2, hub = _market_hub_fixture()
    ptp = PointToPointBid(; name = "ptp_hub_term", available = true, from = b1, to = hub,
        max_active_power = 10.0, spread_bid = MarketBidCost(nothing),
        price_limits = (min = 0.0, max = 1.0))
    add_component!(sys, ptp)
    @test_throws ArgumentError remove_component!(sys, hub)
    remove_component!(sys, ptp)
    remove_component!(sys, hub)
    @test !PSY.is_attached(hub, sys)
end

@testset "ACBus removal is refused while a TradingHub lists it as a member" begin
    sys, b1, b2, hub = _market_hub_fixture()
    @test_throws ArgumentError remove_component!(sys, b1)
    set_buses!(hub, [b2])
    remove_component!(sys, b1)
    @test !PSY.is_attached(b1, sys)
end

@testset "Topology removal is refused while a VirtualParticipant settles there" begin
    sys, b1, b2, hub = _market_hub_fixture()
    b3 = ACBus(; number = 3, name = "b3", available = true, bustype = ACBusTypes.PQ,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 230.0)
    add_component!(sys, b3)
    vp =
        VirtualParticipant(; name = "vp_settled2", available = true, settlement_point = b3,
            max_supply = 10.0, max_demand = 0.0, operation_cost = MarketBidCost(nothing))
    add_component!(sys, vp)
    @test_throws ArgumentError remove_component!(sys, b3)
    set_settlement_point!(vp, nothing)
    remove_component!(sys, b3)
    @test !PSY.is_attached(b3, sys)
end

@testset "PointToPointBid terminals" begin
    sys, b1, b2, hub = _market_hub_fixture()

    ptp = PointToPointBid(; name = "utc1", available = true, from = b1, to = hub,
        max_active_power = 50.0, spread_bid = MarketBidCost(nothing),
        price_limits = (min = -50.0, max = 50.0))
    add_component!(sys, ptp)
    @test get_name(get_from(ptp)) == "b1"

    @test_throws ArgumentError add_component!(sys,
        PointToPointBid(; name = "bad_same", available = true, from = b1, to = b1,
            max_active_power = 1.0, spread_bid = MarketBidCost(nothing),
            price_limits = (min = 0.0, max = 1.0)))

    # a Device terminal is inadmissible
    some_generator = ThermalStandard(nothing)
    some_generator.name = "some_generator"
    some_generator.bus = b1
    add_component!(sys, some_generator)

    @test_throws ArgumentError add_component!(sys,
        PointToPointBid(; name = "bad_dev", available = true, from = some_generator,
            to = b2,
            max_active_power = 1.0, spread_bid = MarketBidCost(nothing),
            price_limits = (min = 0.0, max = 1.0)))

    # round-trip
    sys2 = roundtrip_system(sys)
    ptp2 = get_component(PointToPointBid, sys2, "utc1")
    @test get_name(get_from(ptp2)) == "b1"
    @test get_name(get_to(ptp2)) == "western_hub"
end
