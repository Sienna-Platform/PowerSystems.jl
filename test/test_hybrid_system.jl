@testset "Hybrid System tests" begin
    test_sys = PSB.build_system(PSB.PSITestSystems, "c_sys14"; add_forecasts = false)

    h_sys = HybridSystem(;
        name = "Test H",
        available = true,
        status = true,
        bus = get_component(ACBus, test_sys, "Bus 1"),
        active_power = 1.0,
        reactive_power = 1.0,
        thermal_unit = ThermalStandard(nothing),
        electric_load = PowerLoad(nothing),
        storage = EnergyReservoirStorage(nothing),
        renewable_unit = RenewableDispatch(nothing),
        base_power = 100.0,
        operation_cost = MarketBidCost(nothing),
    )
    add_component!(test_sys, h_sys)

    initial_time = Dates.DateTime("2020-09-01")
    resolution = Dates.Hour(1)
    other_time = initial_time + resolution
    name = "test"
    horizon = 24
    data = Dict(initial_time => ones(horizon), other_time => 5.0 * ones(horizon))
    forecast = Deterministic(name, data, resolution)
    add_time_series!(test_sys, h_sys, forecast)
    ts = get_time_series(Deterministic, h_sys, "test")
    @test isa(ts, Deterministic)
end

@testset "Hybrid System from parsed files" begin
    sys = PSB.build_system(
        PSB.PSITestSystems,
        "test_RTS_GMLC_sys_with_hybrid";
        add_forecasts = true,
    )
    hybrids = collect(get_components(HybridSystem, sys))
    @test length(hybrids) == 1
    h_sys = hybrids[1]

    electric_load = nothing
    thermal_unit = nothing
    subcomponents = collect(get_subcomponents(h_sys))
    @test length(subcomponents) == 4
    expected_time_series_names = Set{String}()
    num_time_series = 0
    for subcomponent in subcomponents
        @test !PSY.is_attached(subcomponent, sys)
        @test IS.is_attached(subcomponent, sys.data.masked_components)
        if subcomponent isa PowerLoad
            electric_load = subcomponent
        elseif subcomponent isa ThermalStandard
            thermal_unit = subcomponent
        end
        for ts in get_time_series_multiple(subcomponent)
            push!(
                expected_time_series_names,
                PSY.make_subsystem_time_series_name(subcomponent, ts),
            )
            num_time_series += 1
        end
    end
    @test electric_load !== nothing
    @test thermal_unit !== nothing

    sts = collect(get_time_series_multiple(h_sys; type = SingleTimeSeries))
    forecasts =
        collect(get_time_series_multiple(h_sys; type = DeterministicSingleTimeSeries))
    @test length(sts) == 2
    @test length(forecasts) == 2
    @test issubset((get_name(x) for x in sts), expected_time_series_names)
    @test issubset((get_name(x) for x in forecasts), expected_time_series_names)

    @test get_time_series(SingleTimeSeries, electric_load, "max_active_power") isa
          SingleTimeSeries
    @test get_time_series(Deterministic, electric_load, "max_active_power") isa
          DeterministicSingleTimeSeries

    @test !has_time_series(thermal_unit)
    @test has_time_series(electric_load)
    remove_time_series!(
        sys,
        DeterministicSingleTimeSeries,
        electric_load,
        "max_active_power",
    )
    @test !has_time_series(electric_load, DeterministicSingleTimeSeries, "max_active_power")

    # Can't set the units when the HybridSystem is attached to system.
    @test_throws ArgumentError PSY.set_thermal_unit!(h_sys, thermal_unit)
end

@testset "Hybrid System from unattached subcomponents" begin
    sys = PSB.build_system(PSB.PSITestSystems, "test_RTS_GMLC_sys"; add_forecasts = false)
    thermal_unit = first(get_components(ThermalStandard, sys))
    bus = get_bus(thermal_unit)
    electric_load = first(get_components(PowerLoad, sys))
    storage = first(get_components(EnergyReservoirStorage, sys))
    renewable_unit = first(get_components(RenewableDispatch, sys))

    for subcomponent in (thermal_unit, electric_load, storage, renewable_unit)
        remove_component!(sys, subcomponent)
    end

    name = "Test H"
    h_sys = HybridSystem(;
        name = name,
        available = true,
        status = true,
        bus = bus,
        active_power = 1.0,
        reactive_power = 1.0,
        thermal_unit = thermal_unit,
        electric_load = electric_load,
        storage = storage,
        renewable_unit = renewable_unit,
        base_power = 100.0,
        operation_cost = MarketBidCost(nothing),
    )
    add_component!(sys, h_sys)

    for subcomponent in (thermal_unit, electric_load, storage, renewable_unit)
        @test !PSY.is_attached(subcomponent, sys)
        @test !has_time_series(subcomponent)
        @test IS.is_attached(subcomponent, sys.data.masked_components)
    end

    @test length(IS.get_masked_components(Component, sys.data)) == 4

    # Add time series for a subcomponent.
    initial_time = Dates.DateTime("2020-09-01")
    resolution = Dates.Hour(1)
    other_time = initial_time + resolution
    name = "test"
    horizon = 24
    data = Dict(initial_time => rand(horizon), other_time => 5.0 * ones(horizon))

    forecast = Deterministic(name, data, resolution)
    add_time_series!(sys, thermal_unit, forecast)
    @test get_time_series(Deterministic, thermal_unit, name) isa Deterministic
    copy_subcomponent_time_series!(h_sys, thermal_unit)
    @test get_time_series(
        Deterministic,
        h_sys,
        PSY.make_subsystem_time_series_name(thermal_unit, forecast),
    ) isa Deterministic
end

@testset "get_fuel_cost for HybridSystem delegates to thermal subunit" begin
    # Hybrid with thermal: get_fuel_cost delegates to thermal subunit
    sys = PSB.build_system(PSB.PSITestSystems, "c_sys5_uc"; add_forecasts = false)
    thermal = first(get_components(ThermalStandard, sys))
    # Ensure thermal has ThermalGenerationCost with FuelCurve
    fc = FuelCurve(InputOutputCurve(IS.QuadraticFunctionData(1, 2, 3)), 2.5)
    set_operation_cost!(thermal, ThermalGenerationCost(fc))
    expected_fuel_cost = get_fuel_cost(thermal)

    bus = get_bus(thermal)
    remove_component!(sys, thermal)
    h_sys = HybridSystem(;
        name = "HybridWithThermal",
        available = true,
        status = true,
        bus = bus,
        active_power = 1.0,
        reactive_power = 0.0,
        thermal_unit = thermal,
        electric_load = nothing,
        storage = nothing,
        renewable_unit = nothing,
        base_power = 100.0,
        operation_cost = MarketBidCost(nothing),
    )
    add_component!(sys, h_sys)
    @test get_fuel_cost(h_sys) == expected_fuel_cost
end

@testset "get_fuel_cost for HybridSystem without thermal throws" begin
    sys = PSB.build_system(PSB.PSITestSystems, "c_sys14"; add_forecasts = false)
    bus = get_component(ACBus, sys, "Bus 1")
    h_sys = HybridSystem(;
        name = "HybridNoThermal",
        available = true,
        status = true,
        bus = bus,
        active_power = 1.0,
        reactive_power = 0.0,
        thermal_unit = nothing,
        electric_load = nothing,
        storage = nothing,
        renewable_unit = nothing,
        base_power = 100.0,
        operation_cost = MarketBidCost(nothing),
    )
    add_component!(sys, h_sys)
    @test_throws ArgumentError get_fuel_cost(h_sys)
end
