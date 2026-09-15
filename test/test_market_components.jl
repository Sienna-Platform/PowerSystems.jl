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
    path = joinpath(mktempdir(), "hub_sys.json")
    to_json(sys, path)
    sys2 = System(path)
    hub2 = get_component(TradingHub, sys2, "western_hub")
    @test get_name.(get_associated_buses(hub2)) == ["b1", "b2"]
end

@testset "CurveStyles numeric contract" begin
    # The wire representation (SiennaSchemas' `curve_style` field) is a plain integer,
    # not the string-enum convention used elsewhere in the schemas; pin the mapping.
    @test Integer(CurveStyles.VARIABLE) == 0
    @test Integer(CurveStyles.FIXED) == 1
    # The former three-way CURVE / FIXED / VARIABLE split collapsed into these two.
    @test_throws UndefVarError CurveStyles.CURVE
end

@testset "CurveMultiStep numeric contract" begin
    # Same wire convention as `curve_style`: SiennaSchemas' `curve_multistep` is a plain
    # integer (0/1), not a string enum; pin the mapping.
    @test Integer(CurveMultiStep.SINGLE_STEP) == 0
    @test Integer(CurveMultiStep.MULTI_STEP) == 1
end

@testset "MarketBidCost extensions" begin
    c = MarketBidCost(; incremental_slope = true)
    @test get_incremental_slope(c)
    @test !get_decremental_slope(c)
    @test !get_incremental_slope(MarketBidCost(nothing))
    @test get_curve_style(MarketBidCost(nothing)) == CurveStyles.VARIABLE

    c2 = MarketBidCost(; curve_style = CurveStyles.FIXED)
    @test get_curve_style(c2) == CurveStyles.FIXED

    @test get_curve_multistep(MarketBidCost(nothing)) == CurveMultiStep.SINGLE_STEP
    @test get_curve_multistep(c2) == CurveMultiStep.SINGLE_STEP
    c3 = MarketBidCost(; curve_multistep = CurveMultiStep.MULTI_STEP)
    @test get_curve_multistep(c3) == CurveMultiStep.MULTI_STEP
    @test get_curve_style(c3) == CurveStyles.VARIABLE
    set_curve_multistep!(c3, CurveMultiStep.SINGLE_STEP)
    @test get_curve_multistep(c3) == CurveMultiStep.SINGLE_STEP

    # The quantity switch (curve_style) and the time switch (curve_multistep) are independent:
    # every combination constructs, and multi-step does not trip the slope exclusivity check.
    c4 = MarketBidCost(;
        curve_style = CurveStyles.FIXED,
        curve_multistep = CurveMultiStep.MULTI_STEP,
    )
    @test get_curve_style(c4) == CurveStyles.FIXED
    @test get_curve_multistep(c4) == CurveMultiStep.MULTI_STEP
    c5 = MarketBidCost(;
        incremental_slope = true,
        curve_multistep = CurveMultiStep.MULTI_STEP,
    )
    @test get_incremental_slope(c5)
    @test get_curve_multistep(c5) == CurveMultiStep.MULTI_STEP

    # The positional (single start-up value) constructor forwards the kwarg.
    c6 = MarketBidCost(
        LinearCurve(0.0), 10.0, LinearCurve(0.0);
        curve_multistep = CurveMultiStep.MULTI_STEP,
    )
    @test get_curve_multistep(c6) == CurveMultiStep.MULTI_STEP

    # FIXED is all-or-nothing, so linear interpolation has no meaning on it; VARIABLE is
    # the continuous curve and takes either interpretation.
    @test_throws ArgumentError MarketBidCost(;
        incremental_slope = true,
        curve_style = CurveStyles.FIXED,
    )
    @test_throws ArgumentError MarketBidCost(;
        decremental_slope = true,
        curve_style = CurveStyles.FIXED,
    )
    c7 = MarketBidCost(; decremental_slope = true, curve_style = CurveStyles.VARIABLE)
    @test get_decremental_slope(c7)
    @test get_curve_style(c7) == CurveStyles.VARIABLE
end

@testset "MarketBidCost FIXED requires a single segment on both offer curves" begin
    one_segment = make_market_bid_curve([0.0, 100.0], [10.0], 0.0)
    two_segments = make_market_bid_curve([0.0, 50.0, 100.0], [10.0, 20.0], 0.0)

    fixed = MarketBidCost(;
        curve_style = CurveStyles.FIXED,
        incremental_offer_curves = one_segment,
        decremental_offer_curves = one_segment,
    )
    @test get_curve_style(fixed) == CurveStyles.FIXED

    # VARIABLE is the continuous case and takes any number of segments.
    variable = MarketBidCost(;
        curve_style = CurveStyles.VARIABLE,
        incremental_offer_curves = two_segments,
        decremental_offer_curves = two_segments,
    )
    @test get_curve_style(variable) == CurveStyles.VARIABLE

    # FIXED is all-or-nothing: exactly one segment, on either side.
    @test_throws "incremental_offer_curves" MarketBidCost(;
        curve_style = CurveStyles.FIXED,
        incremental_offer_curves = two_segments,
    )
    @test_throws "decremental_offer_curves" MarketBidCost(;
        curve_style = CurveStyles.FIXED,
        decremental_offer_curves = two_segments,
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
    @test get_curve_style(mbtc) == CurveStyles.VARIABLE
    @test get_curve_multistep(mbtc) == CurveMultiStep.SINGLE_STEP

    mbtc_multistep = MarketBidTimeSeriesCost(;
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
        curve_style = CurveStyles.VARIABLE,
        curve_multistep = CurveMultiStep.MULTI_STEP,
    )
    @test get_curve_style(mbtc_multistep) == CurveStyles.VARIABLE
    @test get_curve_multistep(mbtc_multistep) == CurveMultiStep.MULTI_STEP
    set_curve_multistep!(mbtc_multistep, CurveMultiStep.SINGLE_STEP)
    @test get_curve_multistep(mbtc_multistep) == CurveMultiStep.SINGLE_STEP

    mbtc_slope = MarketBidTimeSeriesCost(;
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
        incremental_slope = true,
    )
    @test get_incremental_slope(mbtc_slope)

    # The offer curves are keys, not data, so FIXED constructs even though the forecast
    # behind `inc_key` has two segments; the single-segment rule is enforced at resolution
    # (see the dedicated testset below).
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
        curve_style = CurveStyles.FIXED,
    )
    mbtc_variable_slope = MarketBidTimeSeriesCost(;
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
        decremental_slope = true,
        curve_style = CurveStyles.VARIABLE,
    )
    @test get_decremental_slope(mbtc_variable_slope)
end

@testset "MarketBidTimeSeriesCost FIXED single segment is enforced at resolution" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    generator = ThermalStandard(nothing)
    generator.name = "market_gen_fixed"
    generator.bus = bus
    add_component!(sys, generator)

    # Two segments at every timestep: the time-series analogue of the static curve that
    # `MarketBidCost` rejects at construction.
    two_segment_key = _attach_pwl_forecast(sys, generator, "inc_two_segments")
    one_segment_key = add_time_series!(
        sys, generator,
        IS.Deterministic(;
            data = SortedDict(
                _TS_RESOLVE_INITIAL_TIME =>
                    fill(PiecewiseStepData([0.0, 5.0], [2.0]), 24),
            ),
            name = "inc_one_segment",
            resolution = _TS_RESOLVE_RESOLUTION,
        ),
    )
    nl_key = _attach_linear_forecast(sys, generator, "no_load_fixed")
    sd_key = _attach_linear_forecast(sys, generator, "shut_down_fixed")
    timestamps =
        range(_TS_RESOLVE_INITIAL_TIME; step = _TS_RESOLVE_RESOLUTION, length = 24)
    su_key = add_time_series!(
        sys, generator,
        IS.SingleTimeSeries(;
            name = "start_up_stages_fixed",
            data = TimeSeries.TimeArray(collect(timestamps), fill((0.0, 0.0, 0.0), 24)),
        ),
    )
    _cost(style, inc_key, dec_key) = MarketBidTimeSeriesCost(;
        minimum_energy_offer = IS.TimeSeriesLinearCurve(nl_key),
        start_up = su_key,
        shut_down = IS.TimeSeriesLinearCurve(sd_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
        curve_style = style,
    )
    t0 = _TS_RESOLVE_INITIAL_TIME

    # The constructor holds keys only, so the multi-segment series constructs...
    bad = _cost(CurveStyles.FIXED, two_segment_key, one_segment_key)
    @test get_curve_style(bad) == CurveStyles.FIXED
    # ...and the rule fires where the key meets its data: at resolution.
    @test_throws "FIXED" get_variable_cost(generator, bad; start_time = t0)
    @test_throws "FIXED" get_incremental_variable_cost(
        generator, bad; start_time = t0, len = 24,
    )
    # The decremental side is single-segment, so it resolves on its own.
    @test get_decremental_variable_cost(generator, bad; start_time = t0) isa CostCurve

    good = _cost(CurveStyles.FIXED, one_segment_key, one_segment_key)
    @test get_variable_cost(generator, good; start_time = t0) isa CostCurve
    @test length(get_variable_cost(generator, good; start_time = t0, len = 24)) == 24
    @test get_decremental_variable_cost(generator, good; start_time = t0) isa CostCurve

    # VARIABLE is the continuous case: any number of segments resolves.
    variable = _cost(CurveStyles.VARIABLE, two_segment_key, two_segment_key)
    @test get_variable_cost(generator, variable; start_time = t0) isa CostCurve
    @test get_decremental_variable_cost(generator, variable; start_time = t0) isa CostCurve
end

@testset "CurveStyles and CurveMultiStep round-trip through JSON serialization" begin
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
        curve_multistep = CurveMultiStep.MULTI_STEP,
    )
    set_operation_cost!(gen, mbc)

    path = joinpath(mktempdir(), "curve_style_sys.json")
    to_json(sys, path)
    sys2 = System(path)
    gen2 = get_component(ThermalStandard, sys2, "curve_style_gen")
    @test get_curve_style(get_operation_cost(gen2)) == CurveStyles.FIXED
    @test get_curve_multistep(get_operation_cost(gen2)) == CurveMultiStep.MULTI_STEP
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

    path = joinpath(mktempdir(), "mbtc_round_trip.json")
    to_json(sys, path)

    # The keys cross the wire as an association-id envelope, carrying no time series name.
    raw = open(path) do io
        return JSON.parse(io; dicttype = Dict{String, Any})
    end
    gen_json = only(
        filter(
            c -> get(c, "name", "") == "market_gen",
            raw["data"]["components"],
        ),
    )
    op_json = gen_json["operation_cost"]
    @test op_json["start_up"] isa Dict
    @test Set(keys(op_json["start_up"])) ==
          Set(["association_id", "element_type", "time_series_type"])
    @test op_json["start_up"]["association_id"] == IS.get_association_id(su_key)
    @test op_json["start_up"]["time_series_type"] == "SingleTimeSeries"

    # A regression to field-by-field key serialization would put these back in the JSON.
    json_text = read(path, String)
    @test !occursin("owner_category", json_text)
    @test !occursin("start_up_stages_rt", json_text)
    @test !occursin("inc_offer_rt", json_text)

    sys2 = System(path)
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
    path = joinpath(mktempdir(), "vp_sys.json")
    to_json(sys, path)
    sys2 = System(path)
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
    path = joinpath(mktempdir(), "ptp_sys.json")
    to_json(sys, path)
    sys2 = System(path)
    ptp2 = get_component(PointToPointBid, sys2, "utc1")
    @test get_name(get_from(ptp2)) == "b1"
    @test get_name(get_to(ptp2)) == "western_hub"
end
