# TODO: re-enable once PowerSystemCaseBuilder no longer relies on PSY parsers
# (PSB.build_system uses PSY.PowerSystemTableData internally).
# @testset "Test JSON serialization of RTS data with immutable time series" begin
#     sys =
#         PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys"; time_series_read_only = true)
#     sys2, result = validate_serialization(sys; time_series_read_only = true)
#     @test result
#     @test_throws ArgumentError clear_time_series!(sys2)
#     # Full error checking is done in IS.
# end

@testset "Test JSON serialization of matpower data" begin
    sys = PSB.build_system(PSB.MatpowerTestSystems, "matpower_case5_re_sys")

    # Add a Probabilistic time_series to get coverage serializing it.
    bus = ACBus(nothing)
    bus.name = "Bus1234"
    add_component!(sys, bus)
    tg = RenewableNonDispatch(nothing)
    tg.bus = bus
    add_component!(sys, tg)
    # TODO 1.0
    #ts = PSY.Probabilistic("scalingfactor", Hour(1), DateTime("01-01-01"), [0.5, 0.5], 24)
    #add_time_series!(sys, tg, ts)

    _, result = validate_serialization(sys)
    @test result
end

@testset "Test JSON serialization of dynamic inverter" begin
    sys = PSB.build_system(PSB.PSYTestSystems, "dynamic_inverter_sys")

    # Add a dynamic branch to test that code.
    branch = collect(get_components(Branch, sys))[1]
    dynamic_branch = DynamicBranch(branch)
    add_component!(sys, dynamic_branch)
    _, result = validate_serialization(sys)
    @test result

    test_accessors(dynamic_branch)
end

@testset "Test JSON serialization of StaticGroupReserve" begin
    sys = System(100.0)
    devices = []
    for i in 1:2
        bus = ACBus(nothing)
        bus.name = "bus" * string(i)
        bus.number = i
        # This prevents an error log message.
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)
        gen = ThermalStandard(nothing)
        gen.bus = bus
        gen.name = "gen" * string(i)
        add_component!(sys, gen)
        push!(devices, gen)
    end

    service = ConstantReserve{ReserveDown}(nothing)
    add_service!(sys, service, devices)

    groupservice = ConstantReserveGroup{ReserveDown}(nothing)
    add_service!(sys, groupservice)
    members = Vector{Service}()
    push!(members, service)
    set_contributing_services!(sys, groupservice, members)
    _, result = validate_serialization(sys)
    @test result
end

@testset "Test deepcopy of a system" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    sys2 = deepcopy(sys)
    clear_time_series!(sys2)
    @test !isempty(collect(get_time_series_multiple(sys)))
end

@testset "Test JSON serialization of MarketBidCost" begin
    sys = System(100.0)
    generators = [ThermalStandard(nothing), ThermalMultiStart(nothing)]
    for i in 1:2
        bus = ACBus(nothing)
        bus.name = "bus" * string(i)
        bus.number = i
        # This prevents an error log message.
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)
        gen = generators[i]
        gen.bus = bus
        gen.name = "gen" * string(i)
        initial_time = Dates.DateTime("2020-01-01T00:00:00")
        end_time = Dates.DateTime("2020-01-01T23:00:00")
        dates = collect(initial_time:Dates.Hour(1):end_time)
        data =
            PiecewiseStepData.(
                [[i, i + 1, i + 2] for i in 1.0:24.0],
                [[i, i + 1] for i in 1.0:24.0],
            )
        cc = make_market_bid_curve([0.0, 100.0, 200.0], [25.0, 30.0], 10.0)
        market_bid = MarketBidCost(;
            incremental_offer_curves = cc,
            start_up = (hot = 0.0, warm = 0.0, cold = 0.0),
        )
        set_operation_cost!(gen, market_bid)
        add_component!(sys, gen)
        ta = TimeSeries.TimeArray(dates, data)
        power_units = UnitSystem.NATURAL_UNITS
        service = ConstantReserve{ReserveDown}(;
            name = "init_$i",
            available = false,
            time_frame = 0.0,
            requirement = 0.0,
            sustained_time = 0.0,
            max_output_fraction = 1.0,
            max_participation_factor = 1.0,
            deployed_fraction = 0.0,
            ext = Dict{String, Any}(),
        )
        add_component!(sys, service)
        add_service!(gen, service, sys)
        set_service_bid!(
            sys,
            gen,
            service,
            IS.SingleTimeSeries(; name = "init_$i", data = ta),
            power_units,
        )
    end
    _, result = validate_serialization(sys)
    @test result
end

@testset "Test JSON serialization of ReserveDemandCurve" begin
    sys = System(100.0)
    devices = []
    for i in 1:2
        bus = ACBus(nothing)
        bus.name = "bus" * string(i)
        bus.number = i
        # This prevents an error log message.
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)
        gen = ThermalStandard(nothing)
        gen.bus = bus
        gen.name = "gen" * string(i)
        add_component!(sys, gen)
        push!(devices, gen)
    end

    cc = CostCurve(
        PiecewiseIncrementalCurve(0.0, [0.0, 100.0, 200.0], [25.0, 30.0]),
    )
    service = ReserveDemandCurve{ReserveDown}(;
        variable = cc,
        name = "init",
        available = false,
        time_frame = 0.0,
    )
    add_service!(sys, service, devices)

    _, result = validate_serialization(sys)
    @test result
end

# TODO: re-enable once PowerSystemCaseBuilder no longer relies on PSY parsers
# (PSB.build_system uses PSY.PowerSystemTableData internally).
# @testset "Test JSON serialization of HybridSystem" begin
#     sys = PSB.build_system(
#         PSB.PSITestSystems,
#         "test_RTS_GMLC_sys_with_hybrid";
#         add_forecasts = true,
#         force_build = true,
#     )
#     h_sys = first(get_components(HybridSystem, sys))
#     subcomponents = collect(get_subcomponents(h_sys))
#     @test length(subcomponents) == 4
#     sys2, result = validate_serialization(sys)
#     @test result
#     subcomponent = subcomponents[1]
#     @test IS.get_masked_component(
#         typeof(subcomponent),
#         sys2.data,
#         get_name(subcomponent),
#     ) !== nothing
# end

@testset "Test deserialization with new UUIDs" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    sys2, result = validate_serialization(sys; assign_new_uuids = true)
    @test result
    @test IS.get_uuid(sys) != IS.get_uuid(sys2)
    for component1 in get_components(Component, sys)
        component2 = get_component(typeof(component1), sys2, get_name(component1))
        @test IS.get_uuid(component1) != IS.get_uuid(component2)
    end
end

@testset "Test serialization of supplemental attributes" begin
    sys = create_system_with_outages()
    sys2, result = validate_serialization(sys; assign_new_uuids = true)
    @test result
end

@testset "Test verification of invalid ext fields" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys"; add_forecasts = false)
    gen = first(get_components(ThermalStandard, sys))
    ext = get_ext(gen)

    struct MyType
        func::Function
    end
    val = MyType(println)
    ext["val"] = val

    tmpdir = mktempdir()
    filename = joinpath(tmpdir, "invalid_sys.json")
    @test_logs(
        (:error, r"only basic types are allowed"),
        match_mode = :any,
        @test_throws(
            ErrorException,
            to_json(sys, filename, force = true),
        ),
    )
end

@testset "Test serialization of System fields" begin
    frequency = 50.0
    name = "my_system"
    description = "test"
    sys = System(100; frequency = frequency, name = name, description = description)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    # This prevents an error log message.
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.bus = bus
    gen.name = "gen1"
    add_component!(sys, gen)

    sys2, result = validate_serialization(sys)
    @test result
    @test sys2.frequency == frequency
    @test sys2.metadata.name == name
    @test sys2.metadata.description == description
end

# TODO: re-enable once PowerSystemCaseBuilder no longer relies on PSY parsers
# (create_system_with_subsystems -> PSB.build_system uses PSY.PowerSystemTableData internally).
# @testset "Test serialization of subsystems" begin
#     sys = create_system_with_subsystems()
#     sys2, result = validate_serialization(sys)
#     @test result
#     @test sort!(collect(get_subsystems(sys))) == ["subsystem_1"]
# end

@testset "Test serialization to JSON string" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    set_name!(sys, "test_RTS_GMLC_sys")
    set_description!(sys, "test description")
    @test !isempty(collect(IS.iterate_components_with_time_series(sys.data)))
    text = to_json(sys)
    sys2 = from_json(text, System)
    exclude = Set([:time_series_manager])
    @test PSY.compare_values(sys2, sys, exclude = exclude)
    @test isempty(collect(IS.iterate_components_with_time_series(sys2.data)))
end

@testset "Test serialization of component with shared time series" begin
    for use_scaling_factor in (true, false)
        for in_memory in (true, false)
            sys = System(100.0)
            bus = ACBus(nothing)
            bus.bustype = ACBusTypes.REF
            add_component!(sys, bus)
            gen = ThermalStandard(nothing)
            gen.name = "gen1"
            gen.bus = bus
            gen.base_power = 1.0
            gen.active_power = 1.2
            gen.reactive_power = 2.3
            gen.active_power_limits = (0.0, 5.0)
            add_component!(sys, gen)

            initial_time = Dates.DateTime("2020-01-01T00:00:00")
            end_time = Dates.DateTime("2020-01-01T23:00:00")
            dates = collect(initial_time:Dates.Hour(1):end_time)
            data = rand(length(dates))
            ta = TimeSeries.TimeArray(dates, data, ["1"])
            sfm1 = use_scaling_factor ? get_max_active_power : nothing
            sfm2 = use_scaling_factor ? get_max_reactive_power : nothing
            ts1a = SingleTimeSeries(;
                name = "max_active_power",
                data = ta,
                scaling_factor_multiplier = sfm1,
            )
            add_time_series!(sys, gen, ts1a)
            ts2a = SingleTimeSeries(
                ts1a,
                "max_reactive_power";
                scaling_factor_multiplier = sfm2,
            )
            add_time_series!(sys, gen, ts2a)

            sys2, result = validate_serialization(sys)
            @test result

            @test IS.get_num_time_series(sys2.data) == 1
            gen2 = get_component(ThermalStandard, sys2, "gen1")
            ts1b = get_time_series(SingleTimeSeries, gen2, "max_active_power")
            ts2b = get_time_series(SingleTimeSeries, gen2, "max_reactive_power")
            @test ts1b.data == ts2b.data
            ta_vals = TimeSeries.values(ta)
            expected1 =
                use_scaling_factor ? ta_vals * get_max_active_power(gen, SU) :
                ta_vals
            expected2 =
                use_scaling_factor ? ta_vals * get_max_reactive_power(gen, SU) : ta_vals
            @test get_time_series_values(
                gen2,
                ts1b,
                start_time = initial_time;
            ) == expected1
            @test get_time_series_values(
                gen2,
                ts2b,
                start_time = initial_time,
            ) == expected2
        end
    end
end

@testset "Test serialization of GenericArcImpedance" begin
    sys = PSB.build_system(PSB.PSITestSystems, "c_sys5")
    arc = first(get_components(Arc, sys))
    generic_arc_impedance = GenericArcImpedance(;
        name = "test_impedance",
        available = true,
        active_power_flow = 0.0,
        reactive_power_flow = 0.0,
        max_flow = 0.0,
        arc = arc,
        r = 0.01,
        x = 0.1,
    )
    add_component!(sys, generic_arc_impedance)
    _, result = validate_serialization(sys)
    @test result
end
