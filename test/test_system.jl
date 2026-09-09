@testset "Test functionality of System" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys"; add_forecasts = false)
    summary(devnull, sys)
    @test get_frequency(sys) == PSY.DEFAULT_SYSTEM_FREQUENCY

    generators = collect(get_components(ThermalStandard, sys))
    generator = get_component(ThermalStandard, sys, get_name(generators[1]))
    @test IS.get_id(generator) == IS.get_id(generators[1])
    @test_throws(IS.ArgumentError, add_component!(sys, generator))
    @test get_available_component(ThermalStandard, sys, get_name(generators[1])) ===
          generator
    set_available!(generator, false)
    @test isnothing(get_available_component(ThermalStandard, sys, get_name(generators[1])))
    set_available!(generator, true)

    generators2 = get_components_by_name(ThermalGen, sys, get_name(generators[1]))
    @test length(generators2) == 1
    @test IS.get_id(generators2[1]) == IS.get_id(generators[1])
    @test !has_time_series(generators2[1])

    @test isnothing(get_component(ThermalStandard, sys, "not-a-name"))
    @test isempty(get_components_by_name(ThermalGen, sys, "not-a-name"))
    @test_throws(
        IS.ArgumentError,
        get_components_by_name(ThermalStandard, sys, "not-a-name")
    )
    @test isempty(get_components(x -> (!get_available(x)), ThermalStandard, sys))
    @test !isempty(get_available_components(ThermalStandard, sys))
    @test !isempty(get_available_components(x -> true, ThermalStandard, sys))
    # Test get_bus* functionality.
    bus_numbers = Vector{Int}()
    for bus in get_components(ACBus, sys)
        push!(bus_numbers, bus.number)
        if length(bus_numbers) >= 2
            break
        end
    end

    bus = PowerSystems.get_bus(sys, bus_numbers[1])
    @test bus.number == bus_numbers[1]

    buses = PowerSystems.get_buses(sys, Set(bus_numbers))
    sort!(bus_numbers)
    sort!(buses; by = x -> x.number)
    @test length(bus_numbers) == length(buses)
    for (bus_number, bus) in zip(bus_numbers, buses)
        @test bus_number == bus.number
    end

    @test get_forecast_initial_times(sys) == []
    @test get_time_series_resolutions(sys)[1] == Dates.Hour(1)

    # Get time_series with a name and without.
    components = collect(get_components(HydroTurbine, sys))
    @test !isempty(components)
    component = components[1]
    ts = get_time_series(SingleTimeSeries, component, "max_active_power")
    @test ts isa SingleTimeSeries

    components = collect(get_components(HydroReservoir, sys))
    @test !isempty(components)

    returned_it, returned_len = check_time_series_consistency(sys, SingleTimeSeries)
    @test returned_it == first(TimeSeries.timestamp(get_data(ts)))
    @test returned_len == length(get_data(ts))

    # Test all versions of get_time_series_[array|timestamps|values]
    values1 = get_time_series_array(component, ts)
    values2 = get_time_series_array(SingleTimeSeries, component, "max_active_power")
    @test values1 == values2
    values3 = get_time_series_array(SingleTimeSeries, component, "max_active_power")
    @test values1 == values3

    val = get_time_series_array(SingleTimeSeries, component, "max_active_power")
    @test val isa TimeSeries.TimeArray
    val = get_time_series_timestamps(SingleTimeSeries, component, "max_active_power")
    @test val isa Array
    @test val[1] isa Dates.DateTime
    val = get_time_series_values(SingleTimeSeries, component, "max_active_power")
    @test val isa Array
    @test val[1] isa AbstractFloat

    val = get_time_series_array(component, ts)
    @test val isa TimeSeries.TimeArray
    val = get_time_series_timestamps(component, ts)
    @test val isa Array
    @test val[1] isa Dates.DateTime
    val = get_time_series_values(component, ts)
    @test val isa Array
    @test val[1] isa AbstractFloat

    clear_time_series!(sys)
    @test length(collect(get_time_series_multiple(sys))) == 0
    @test IS.get_internal(sys) isa IS.InfrastructureSystemsInternal
end

@testset "Test get_componets filter_func" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys"; add_forecasts = false)
    gen = first(get_components(ThermalStandard, sys))
    name = get_name(gen)
    generators = get_components(ThermalStandard, sys) do gen
        get_name(gen) == name && get_available(gen)
    end

    @test length(generators) == 1 && get_name(first(generators)) == name
end

@testset "Test handling of bus_numbers" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")

    @test length(sys.bus_numbers) > 0
    buses = get_components(ACBus, sys)
    bus_numbers = sort!([get_number(bus) for bus in buses])
    @test bus_numbers == get_bus_numbers(sys)

    # Remove some components
    remove_components!(x -> get_number(x) ∈ [101, 201], sys, ACBus)
    @test length(sys.bus_numbers) == length(bus_numbers) - 2

    # Remove entire type
    remove_components!(sys, ACBus)
    @test length(sys.bus_numbers) == 0

    # Remove individually.
    for bus in buses
        add_component!(sys, bus)
    end
    @test length(sys.bus_numbers) > 0
    for bus in buses
        remove_component!(sys, bus)
    end
    @test length(sys.bus_numbers) == 0

    # Remove by name.
    for bus in buses
        add_component!(sys, bus)
    end
    @test length(sys.bus_numbers) > 0
    for bus in buses
        remove_component!(ACBus, sys, get_name(bus))
    end
    @test length(sys.bus_numbers) == 0
end

@testset "Test System iterators" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")

    i = 0
    for component in iterate_components(sys)
        i += 1
    end

    components = get_components(Component, sys)
    @test i == length(components)

    # Test debugging functions.
    component = first(components)
    id = IS.get_id(component)
    @test get_name(get_component(sys, id)) == get_name(component)
end

@testset "Test remove_component" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    generators = get_components(ThermalStandard, sys)
    initial_length = length(generators)
    @assert initial_length > 0
    gen = collect(generators)[1]

    remove_component!(sys, gen)

    @test isnothing(get_component(typeof(gen), sys, get_name(gen)))
    generators = get_components(typeof(gen), sys)
    @test length(generators) == initial_length - 1

    @test_throws(IS.ArgumentError, remove_component!(sys, gen))

    add_component!(sys, gen)
    remove_component!(typeof(gen), sys, get_name(gen))
    @test isnothing(get_component(typeof(gen), sys, get_name(gen)))

    @assert length(get_components(typeof(gen), sys)) > 0
    remove_components!(sys, typeof(gen))
    @test_throws(IS.ArgumentError, remove_components!(sys, typeof(gen)))

    remove_components!(sys, Area)
    @test isempty(get_components(Area, sys))
    @test isnothing(get_area(collect(get_components(ACBus, sys))[1]))
end

@testset "Test missing Arc bus" begin
    sys = System(100.0)
    line = Line(nothing)
    @test_throws(IS.ArgumentError, add_component!(sys, line))
end

@testset "Test frequency set" begin
    sys = System(100; frequency = 50.0)
    @test get_frequency(sys) == 50.0
end

@testset "Test exported names" begin
    @test IS.validate_exported_names(PowerSystems)
end

@testset "Test system ext" begin
    sys = System(100.0)
    ext = get_ext(sys)
    ext["data"] = 2
    @test get_ext(sys)["data"] == 2
    clear_ext!(sys)
    @test isempty(get_ext(sys))
end

@testset "Test system checks" begin
    sys = System(100.0)
    @test_logs (:warn, r"There are no .* Components in the System") match_mode = :any check(
        sys,
    )
end

@testset "Test explicit units API" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)
    device_base = PSY._get_base_power(gen)
    system_base = PSY._get_base_power(sys)
    raw_active = gen.active_power

    P_mw = get_active_power(gen, MW)
    @test P_mw isa Float64
    @test P_mw ≈ raw_active * device_base
    @test get_active_power_unitful(gen, MW) isa Unitful.Quantity
    @test Unitful.ustrip(get_active_power_unitful(gen, MW)) ≈ raw_active * device_base

    P_du = get_active_power(gen, DU)
    @test P_du isa Float64
    @test P_du ≈ raw_active
    @test get_active_power_unitful(gen, DU) isa RelativeQuantity

    P_su = get_active_power(gen, SU)
    @test P_su isa Float64
    @test P_su ≈ raw_active * device_base / system_base
    @test get_active_power_unitful(gen, SU) isa RelativeQuantity
end

@testset "Test explicit units setters" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)
    device_base = PSY._get_base_power(gen)

    set_active_power!(gen, 50.0 * MW)
    @test gen.active_power ≈ 50.0 / device_base

    set_active_power!(gen, 0.6 * DU)
    @test gen.active_power ≈ 0.6
end

@testset "Test add_time_series multiple components" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    components = []
    len = 2
    for i in 1:len
        gen = ThermalStandard(nothing)
        gen.name = string(i)
        gen.bus = bus
        add_component!(sys, gen)
        push!(components, gen)
    end

    initial_time = Dates.DateTime("2020-01-01T00:00:00")
    end_time = Dates.DateTime("2020-01-01T23:00:00")
    dates = collect(initial_time:Dates.Hour(1):end_time)
    data = collect(1:24)
    ta = TimeSeries.TimeArray(dates, data, ["1"])
    name = "max_active_power"
    ts = SingleTimeSeries(; name = name, data = ta)
    res = add_time_series!(sys, components, ts)

    for i in 1:len
        component = get_component(ThermalStandard, sys, string(i))
        ts = get_time_series(SingleTimeSeries, component, name)
        @test ts isa SingleTimeSeries
    end
end

@testset "Test time series sharing accessors" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gens = ThermalStandard[]
    for i in 1:2
        gen = ThermalStandard(nothing)
        gen.name = string(i)
        gen.bus = bus
        add_component!(sys, gen)
        push!(gens, gen)
    end

    initial_time = Dates.DateTime("2020-01-01T00:00:00")
    resolution = Dates.Hour(1)
    dates = collect(range(initial_time; step = resolution, length = 24))
    make_sts(name, data) =
        SingleTimeSeries(; name = name, data = TimeSeries.TimeArray(dates, data))

    # One array shared by both generators, one array owned by the first alone.
    add_time_series!(sys, gens, make_sts("max_active_power", collect(1.0:24.0)))
    add_time_series!(sys, gens[1], make_sts("solo", collect(25.0:48.0)))

    shared_keys = [
        IS.get_time_series_key(
            only(list_time_series_metadata(g; name = "max_active_power")),
        )
        for g in gens
    ]
    solo_key =
        IS.get_time_series_key(only(list_time_series_metadata(gens[1]; name = "solo")))
    shared_hash = get_time_series_hash(gens[1], shared_keys[1])
    @test get_time_series_hash(gens[2], shared_keys[2]) == shared_hash
    @test get_time_series_hash(gens[1], solo_key) != shared_hash

    # By default only the shared array is reported.
    groups = get_time_series_array_groups(sys)
    @test collect(keys(groups)) == [shared_hash]
    @test Set(get_name(o) for (o, _) in groups[shared_hash]) == Set(["1", "2"])

    all_groups = get_time_series_array_groups(sys; only_shared = false)
    @test length(all_groups) == 2
    @test Set(get_name(o) for (o, _) in all_groups[shared_hash]) == Set(["1", "2"])
    @test only(
        get_name(o) for (o, _) in all_groups[get_time_series_hash(gens[1],
            solo_key)]
    ) == "1"
end

@testset "Test forecast reader over shared forecasts" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gens = ThermalStandard[]
    for i in 1:2
        gen = ThermalStandard(nothing)
        gen.name = string(i)
        gen.bus = bus
        add_component!(sys, gen)
        push!(gens, gen)
    end

    initial_time = Dates.DateTime("2020-01-01T00:00:00")
    resolution = Dates.Hour(1)
    interval = Dates.Hour(24)
    horizon = 24
    initial_times = [initial_time, initial_time + interval]
    data = Dict(it => collect(1.0:horizon) for it in initial_times)
    add_time_series!(sys, gens, Deterministic("max_active_power", data, resolution))

    reader = build_forecast_reader(sys, Deterministic; resolution = resolution)
    @test reader isa ForecastReader
    @test length(reader) == 2
    # Both entries resolve to the one shared array, so one read serves both.
    @test get_num_forecast_slots(reader) == 1
    @test Set(get_name(e.owner) for e in get_forecast_reader_entries(reader)) ==
          Set(["1", "2"])

    timeline = get_forecast_reader_timeline(reader)
    @test timeline.initial_timestamp == initial_time
    @test timeline.count == length(initial_times)

    read_forecast_window!(reader, initial_time)
    @test get_forecast_window(reader, 1) == collect(1.0:horizon)
    @test get_forecast_window(reader, 2) == get_forecast_window(reader, 1)
end

@testset "Test static time series reader" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gens = ThermalStandard[]
    for i in 1:2
        gen = ThermalStandard(nothing)
        gen.name = string(i)
        gen.bus = bus
        add_component!(sys, gen)
        push!(gens, gen)
    end

    initial_time = Dates.DateTime("2020-01-01T00:00:00")
    resolution = Dates.Hour(1)
    len = 24
    timestamps = range(initial_time; length = len, step = resolution)
    arrays = [collect(1.0:len) .* i for i in 1:2]
    for (gen, vals) in zip(gens, arrays)
        add_time_series!(
            sys,
            gen,
            SingleTimeSeries(;
                data = TimeSeries.TimeArray(timestamps, vals),
                name = "max_active_power",
            ),
        )
    end

    reader = build_static_time_series_reader(sys; resolution = resolution)
    @test reader isa StaticTimeSeriesReader
    @test length(reader) == 2
    # Both scalar series pack into one columnar group: one read per timestamp.
    @test get_num_static_time_series_groups(reader) == 1
    entries = get_static_time_series_reader_entries(reader)
    @test Set(get_name(e.owner) for e in entries) == Set(["1", "2"])

    grid = get_static_time_series_reader_grid(reader)
    @test grid.initial_timestamp == initial_time
    @test grid.length == len

    by_name = Dict(get_name(e.owner) => i for (i, e) in enumerate(entries))
    for (k, timestamp) in enumerate(timestamps)
        read_static_time_series_values!(reader, timestamp)
        for i in 1:2
            @test get_static_time_series_value(reader, by_name["$i"]) == arrays[i][k]
        end
    end
end

@testset "Test bulk add of time series" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    components = []
    len = 2
    component = ThermalStandard(nothing)
    component.name = "gen"
    component.bus = bus
    add_component!(sys, component)
    initial_time = Dates.DateTime("2020-09-01")
    resolution = Dates.Hour(1)
    len = 24
    timestamps = range(initial_time; length = len, step = resolution)
    arrays = [TimeSeries.TimeArray(timestamps, rand(len)) for _ in 1:5]
    ts_name = "test"

    time_series_transaction(sys) do txn
        for (i, ta) in enumerate(arrays)
            ts = SingleTimeSeries(; data = ta, name = "$(ts_name)_$(i)")
            add_time_series!(txn, component, ts)
        end
    end

    for (i, expected_array) in enumerate(arrays)
        # `SingleTimeSeries.data` is a raw Array now; go through
        # `get_time_series_array` to compare timestamps as well as values.
        ta = IS.get_time_series_array(IS.SingleTimeSeries, component, "$(ts_name)_$(i)")
        @test ta == expected_array
    end
end

@testset "Test time_series_transaction" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    components = []
    len = 2
    component = ThermalStandard(nothing)
    component.name = "gen"
    component.bus = bus
    add_component!(sys, component)
    initial_time = Dates.DateTime("2020-09-01")
    resolution = Dates.Hour(1)
    len = 24
    timestamps = range(initial_time; length = len, step = resolution)
    arrays = [TimeSeries.TimeArray(timestamps, rand(len)) for _ in 1:5]
    ts_name = "test"

    time_series_transaction(sys) do txn
        for (i, ta) in enumerate(arrays)
            ts = SingleTimeSeries(; data = ta, name = "$(ts_name)_$(i)")
            add_time_series!(txn, component, ts)
        end
    end

    for (i, expected_array) in enumerate(arrays)
        ta = IS.get_time_series_array(IS.SingleTimeSeries, component, "$(ts_name)_$(i)")
        @test ta == expected_array
    end

    # A throw inside the block rolls back everything it buffered.
    @test_throws ErrorException time_series_transaction(sys) do txn
        ts = SingleTimeSeries(;
            data = TimeSeries.TimeArray(timestamps, rand(len)),
            name = "rolled_back",
        )
        add_time_series!(txn, component, ts)
        error("abort the transaction")
    end
    @test isempty(
        IS.list_time_series_metadata(component; name = "rolled_back"),
    )
end

@testset "Test set_name! of system component" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    set_name!(sys, bus, "new_name")
    @test get_component(ACBus, sys, "new_name") === bus

    @test_throws ErrorException set_name!(bus, "new_name2")
    remove_component!(sys, bus)
    set_name!(bus, "new_name2")
    @test get_name(bus) == "new_name2"
end

@testset "Test forecast parameters" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.name = "gen"
    gen.bus = bus
    add_component!(sys, gen)

    resolution = Dates.Hour(1)
    initial_time = Dates.DateTime("2020-09-01")
    second_time = initial_time + resolution
    name = "test"
    horizon = Hour(24)
    horizon_count = 24
    data =
        SortedDict(initial_time => ones(horizon_count), second_time => ones(horizon_count))

    forecast = Deterministic(; data = data, name = name, resolution = resolution)
    add_time_series!(sys, gen, forecast)

    @test get_time_series_resolutions(sys)[1] == resolution
    @test get_forecast_horizon(sys) == horizon
    @test get_forecast_initial_timestamp(sys) == initial_time
    @test get_forecast_interval(sys) == Dates.Millisecond(second_time - initial_time)
    @test get_forecast_window_count(sys) == 2
    @test get_forecast_initial_times(sys) == [initial_time, second_time]

    remove_time_series!(sys, typeof(forecast), gen, get_name(forecast))
    @test_throws ArgumentError get_time_series(typeof(forecast), gen, get_name(forecast))
end

@testset "Test multi-interval DeterministicSingleTimeSeries" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.name = "gen"
    gen.bus = bus
    add_component!(sys, gen)

    initial_time = Dates.DateTime("2020-09-01")
    resolution = Dates.Minute(5)
    sts_length = 288  # 24 hours at 5-min resolution
    data = TimeSeries.TimeArray(
        range(initial_time; length = sts_length, step = resolution),
        rand(sts_length),
    )
    sts_name = "max_active_power"
    sts = SingleTimeSeries(; data = data, name = sts_name)
    add_time_series!(sys, gen, sts)

    horizon = Dates.Hour(1)
    interval1 = Dates.Minute(30)
    interval2 = Dates.Hour(1)

    transform_single_time_series!(
        sys,
        horizon,
        interval1;
        delete_existing = false,
    )
    transform_single_time_series!(
        sys,
        horizon,
        interval2;
        delete_existing = false,
    )

    @test has_time_series(
        gen,
        DeterministicSingleTimeSeries,
        sts_name;
        interval = interval1,
    )
    @test has_time_series(
        gen,
        DeterministicSingleTimeSeries,
        sts_name;
        interval = interval2,
    )

    ts1 = get_time_series(
        DeterministicSingleTimeSeries,
        gen,
        sts_name;
        interval = interval1,
    )
    # Stored as a DeterministicSingleTimeSeries; a read materializes it into a regular
    # Deterministic (the DST form is a storage-side optimization only).
    @test ts1 isa Deterministic
    @test IS.get_interval(ts1) == interval1

    ts2 = get_time_series(
        DeterministicSingleTimeSeries,
        gen,
        sts_name;
        interval = interval2,
    )
    @test ts2 isa Deterministic
    @test IS.get_interval(ts2) == interval2

    @test_throws ArgumentError get_time_series(
        DeterministicSingleTimeSeries,
        gen,
        sts_name,
    )

    @test get_forecast_interval(sys; interval = interval1) == interval1
    @test get_forecast_interval(sys; interval = interval2) == interval2
    @test get_forecast_horizon(sys; interval = interval1) == horizon
    @test get_forecast_window_count(sys; interval = interval1) > 0
    @test get_forecast_window_count(sys; interval = interval2) > 0

    ts_interval1 = collect(
        get_time_series_multiple(
            sys;
            type = DeterministicSingleTimeSeries,
            interval = interval1,
        ),
    )
    @test length(ts_interval1) > 0
    for ts in ts_interval1
        @test IS.get_interval(ts) == interval1
    end

    remove_time_series!(
        sys,
        DeterministicSingleTimeSeries,
        gen,
        sts_name;
        interval = interval1,
    )
    @test !has_time_series(
        gen,
        DeterministicSingleTimeSeries,
        sts_name;
        interval = interval1,
    )
    @test has_time_series(
        gen,
        DeterministicSingleTimeSeries,
        sts_name;
        interval = interval2,
    )

    @test has_time_series(gen, SingleTimeSeries, sts_name)
end

@testset "Invalid constructor" begin
    # Unrecognized extension: generic error.
    @test_throws DataFormatError System("data.invalid")

    # .json: point at from_file.
    @test_throws "from_file" System("sys.json")

    # .raw / .m: point at PowerFlowFileParser.jl, not this package.
    for ext in (".raw", ".m")
        @test_throws "PowerFlowFileParser" System("case$ext")
    end
end

@testset "to_json/from_json are not part of the System API" begin
    # PSY no longer exports them: a System reaches disk only through to_file/from_file.
    @test !(:to_json in names(PowerSystems))
    @test !(:from_json in names(PowerSystems))
end

@testset "Test deepcopy with runchecks" begin
    sys = System(100.0)
    @test get_runchecks(sys)
    @test get_runchecks(deepcopy(sys))
end

@testset "Test deepcopy with runchecks disabled" begin
    sys = System(100.0; runchecks = false)
    @test !get_runchecks(sys)
    sys2 = deepcopy(sys)
    @test sys2 isa System
    @test !get_runchecks(sys)
end

@testset "Test deepcopy with custom time_series_directory" begin
    ts_dir = mktempdir()
    sys = System(100.0; time_series_directory = ts_dir)
    sys2 = deepcopy(sys)
    @test dirname(IS._store_path(sys2.data.time_series_manager.data_store)) == ts_dir
end

@testset "Test time series counts" begin
    # The system has both single and deterministic forecasts time series
    c_sys5 = PSB.build_system(
        PSITestSystems,
        "c_sys5_uc";
        add_forecasts = true,
        skip_serialization = true,
    )
    counts = get_time_series_counts(c_sys5)
    @test counts.static_time_series_count == 0
    @test counts.forecast_count == 3

    # The system has both single and deterministic forecasts time series
    c_sys5 = PSB.build_system(
        PSITestSystems,
        "c_sys5_uc";
        add_single_time_series = true,
        skip_serialization = true,
    )
    counts = get_time_series_counts(c_sys5)
    @test counts.static_time_series_count == 3
    @test counts.forecast_count == 0
end

@testset "Test deepcopy with time series options" begin
    sys = PSB.build_system(
        PSITestSystems,
        "test_RTS_GMLC_sys";
        time_series_in_memory = true,
        force_build = true,
    )
    @test sys.data.time_series_manager.data_store isa IS.Store
    sys2 = deepcopy(sys)
    @test sys2.data.time_series_manager.data_store isa IS.Store
    @test IS.compare_values(sys, sys2)
    # Ensure that the storage references got updated correctly.
    for component in get_components(x -> has_time_series(x), Component, sys2)
        @test component.internal.shared_system_references.time_series_manager ===
              sys2.data.time_series_manager
    end

    sys = PSB.build_system(
        PSITestSystems,
        "test_RTS_GMLC_sys";
        time_series_in_memory = false,
        force_build = true,
    )
    @test sys.data.time_series_manager.data_store isa IS.Store
    sys2 = deepcopy(sys)
    @test sys2.data.time_series_manager.data_store isa IS.Store
    @test IS.compare_values(sys, sys2)
    for component in get_components(x -> has_time_series(x), Component, sys2)
        @test component.internal.shared_system_references.time_series_manager ===
              sys2.data.time_series_manager
    end
end

@testset "Test fast deepcopy of system" begin
    systems = Dict(
        in_memory => PSB.build_system(
            PSITestSystems,
            "test_RTS_GMLC_sys";
            time_series_in_memory = in_memory,
            force_build = true,
        ) for in_memory in (true, false)
    )
    @testset for (in_memory, skip_ts, skip_sa) in  # Iterate over all permutations
                 Iterators.product(repeat([(true, false)], 3)...)
        sys = systems[in_memory]

        sys2 = IS.fast_deepcopy_system(sys;
            skip_time_series = skip_ts, skip_supplemental_attributes = skip_sa)
        @test IS.compare_values(
            sys,
            sys2;
            exclude = Set(
                [:time_series_manager, :supplemental_attribute_manager][[skip_ts, skip_sa]],
            ),
        )

        # base_power is a plain Float64 now (not a shared mutable object), so equality
        # rather than identity is the correct check here.
        generator = get_component(ThermalStandard, sys2, "322_CT_6")
        @test sys2.base_power == generator.internal.base_value
    end
end

@testset "Test with compression enabled" begin
    @test get_compression_settings(System(100.0)) == CompressionSettings(; enabled = false)

    # The Rust/HDF5 time-series backend supports DEFLATE only; BLOSC came from the
    # older HDF5.jl-based store.
    settings = CompressionSettings(; enabled = true, type = CompressionTypes.DEFLATE)
    @test get_compression_settings(System(100.0; compression = settings)) == settings
    @test get_compression_settings(System(100.0; enable_compression = true)) ==
          CompressionSettings(; enabled = true)
end

@testset "Test compare_values" begin
    sys1 = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    sys2 = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    gen1 = first(get_components(ThermalStandard, sys1))
    gen2 = first(get_components(ThermalStandard, sys2))
    @test IS.compare_values(gen1, gen2)
    # Two independent builds mint their own UUIDs, so only field-by-field comparison is
    # meaningful here, not whole-system equality.

    set_active_power!(gen1, (get_active_power(gen1, SU) + 0.1) * SU)
    @test(
        @test_logs(
            (:error, r"not match"),
            match_mode = :any,
            !IS.compare_values(gen1, gen2),
        )
    )
    @test(
        @test_logs(
            (:error, r"not match"),
            match_mode = :any,
            !IS.compare_values(sys1, sys2)
        )
    )

    my_match_fn(a::Float64, b::Float64) =
        isapprox(a, b; atol = 0.2) || IS.isequivalent(a, b)
    my_match_fn(a, b) = IS.isequivalent(a, b)
    @test IS.compare_values(my_match_fn, gen1, gen2)
end

@testset "Test check_components" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys"; add_forecasts = false)
    check_components(sys)
    check_components(sys, Component)
    check_components(sys, Generator)
    check_components(sys, ThermalStandard)
    check_components(sys, get_components(ThermalStandard, sys))
    components = get_components(ThermalStandard, sys)
    gen = first(components)
    check_components(sys, components)
    check_component(sys, gen)

    # Invalid Bus base_voltage values throw errors.
    # Invalid ThermalStandard active_power logs warning messages.

    bus = first(get_components(ACBus, sys))
    check_component(sys, bus)
    orig = get_base_voltage(bus)
    set_base_voltage!(bus, -1.0)
    try
        @test_logs(
            (:error, "Invalid range"),
            match_mode = :any,
            @test_throws IS.InvalidValue check_component(sys, bus)
        )
    finally
        set_base_voltage!(bus, orig)
    end

    gen.active_power = 100.0
    @test_logs :warn, "Invalid range" match_mode = :any check_component(sys, gen)
    @test_logs :warn, "Invalid range" match_mode = :any check_components(
        sys,
        ThermalStandard,
    )

    # @test !(@test_logs :warn, r"is larger than the max expected in the" match_mode = :any check_ac_transmission_rate_values(
    #     sys,
    # ))
    @test check_ac_transmission_rate_values(sys)
end

@testset "Test system name and description" begin
    name = "test_system"
    description = "a system description"
    sys = System(100.0)
    @test isnothing(get_name(sys))
    @test isnothing(get_description(sys))

    sys = System(100.0; name = name, description = description)
    @test get_name(sys) == name
    @test get_description(sys) == description
end

@testset "Test system metadata" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    name = "test_system"
    description = "a system description"
    set_name!(sys, name)
    set_description!(sys, description)

    # `user_data` is not carried: richer provenance in the document is deferred until the serde
    # itself is settled, so only name and description round-trip today.
    sys2 = roundtrip_system(sys)
    @test get_name(sys2) == name
    @test get_description(sys2) == description
end

@testset "Test addition of service to the wrong system" begin
    sys1 = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    sys2 = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    service1 = first(get_components(OnlineReserve{ReserveDown}, sys1))
    device2 = first(get_components(ThermalStandard, sys2))
    @test_throws ArgumentError add_service!(device2, service1, sys2)
end

@testset "Test has_components" begin
    sys1 = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    @test has_components(sys1, ThermalStandard)
    @test !has_components(sys1, TransmissionInterface)
end

@testset "Test set_bus_number!" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    buses = collect(get_components(ACBus, sys))
    bus1 = buses[1]
    bus2 = buses[2]
    orig = get_number(bus1)
    new_number = 9999999
    @test orig != new_number
    set_bus_number!(sys, bus1, new_number)
    @test get_number(bus1) == new_number
    bus_numbers = get_bus_numbers(sys)
    @test new_number in bus_numbers
    @test !(orig in bus_numbers)

    # Ensure that the no-op case works.
    set_bus_number!(sys, bus1, new_number)
    @test get_number(bus1) == new_number
    @test new_number in get_bus_numbers(sys)

    # Ensure that duplicate numbers are blocked.
    @test_throws ArgumentError set_bus_number!(sys, bus1, get_number(bus2))

    # Ensure that you can't change an unattached bus.
    remove_component!(sys, bus1)
    @test_throws ArgumentError set_bus_number!(sys, bus1, new_number + 1)
end
