@testset "Test Hydro Turbine constructors" begin
    turbine = HydroTurbine(; name = "TestTurbine",
        available = true,
        bus = ACBus(nothing),
        active_power = 0.0,
        reactive_power = 0.0,
        rating = 1,
        base_power = 100,
        active_power_limits = (min = 0, max = 1),
        reactive_power_limits = nothing,
        outflow_limits = nothing,
        powerhouse_elevation = 0.0,
        ramp_limits = nothing,
        time_limits = nothing,
        input_basis = u"CU",
    )

    set_powerhouse_elevation!(turbine, 10.0)
    @test get_powerhouse_elevation(turbine) == 10.0
end

@testset "Test Hydro Reservoir constructors and getters" begin
    reservoir = HydroReservoir(;
        name = "init",
        available = false,
        initial_level = 1.0,
        storage_level_limits = (min = 0.0, max = 1.0),
        spillage_limits = nothing,
        inflow = 0.0,
        outflow = 0.0,
        level_targets = 0.0,
        intake_elevation = 0.0,
        head_to_volume_factor = LinearFunctionData(0.0),
    )
    @test get_storage_level_limits(reservoir) == (min = 0.0, max = 1.0)
    @test get_initial_level(reservoir) == 1.0
    @test get_level_data_type(reservoir) == ReservoirDataType.USABLE_VOLUME
    @test get_inflow(reservoir) == 0.0
    @test get_outflow(reservoir) == 0.0
    @test get_intake_elevation(reservoir) == 0.0
    @test get_head_to_volume_factor(reservoir) == LinearFunctionData(0.0)
    @test get_evaporative_loss(reservoir) == 0.0
    set_intake_elevation!(reservoir, 10.0)
    @test get_intake_elevation(reservoir) == 10.0
end

@testset "Test Hydro Reservoir constructors and setters" begin
    reservoir = HydroReservoir(nothing)
    @test set_storage_level_limits!(reservoir, (min = 0.0, max = 0.0)) ==
          (min = 0.0, max = 0.0)
    @test set_level_data_type!(reservoir, ReservoirDataType.HEAD) == ReservoirDataType.HEAD
    @test set_inflow!(reservoir, 10.0) == 10.0
    @test set_outflow!(reservoir, 10.0) == 10.0
    @test get_evaporative_loss(reservoir) == 0.0
    @test set_evaporative_loss!(reservoir, 0.01) == 0.01
    @test get_evaporative_loss(reservoir) == 0.01
end

@testset "Test single `HydroTurbine` with single `HydroReservoir`" begin
    sys = System(100.0)

    bus = nodes5()[4]
    bus.name = "bus1"
    bus.number = 1
    add_component!(sys, bus)

    reservoir = HydroReservoir(nothing)
    add_component!(sys, reservoir)
    turbine = HydroTurbine(nothing)
    turbine.bus = bus
    add_component!(sys, turbine)
    set_downstream_turbine!(reservoir, turbine)

    @test !has_upstream_turbine(reservoir)
    @test has_downstream_turbine(reservoir)
    @test !has_upstream_turbine(reservoir, turbine)
    @test has_downstream_turbine(reservoir, turbine)
    @test length(get_components(HydroTurbine, sys)) == 1
    @test length(get_connected_head_reservoirs(sys, turbine)) == 1

    remove_turbine!(reservoir, turbine)
    @test_throws ArgumentError remove_turbine!(reservoir, turbine)
    @test !has_downstream_turbine(reservoir)
    @test !has_downstream_turbine(reservoir, turbine)
    @test length(get_connected_head_reservoirs(sys, turbine)) == 0

    remove_component!(sys, turbine)
    @test_throws ArgumentError get_connected_head_reservoirs(sys, turbine)
end

@testset "Test multiple `HydroTurbine` with single `HydroReservoir`" begin
    sys = System(100.0)

    bus = nodes5()[4]
    bus.name = "bus1"
    bus.number = 1
    add_component!(sys, bus)

    hydro_reservoir = HydroReservoir(nothing)
    add_component!(sys, hydro_reservoir)
    turbines = []
    for i in 1:5
        turbine = HydroTurbine(nothing)
        turbine.name = "Turbine" * string(i)
        turbine.bus = bus
        add_component!(sys, turbine)
        push!(turbines, turbine)
    end
    set_downstream_turbines!(hydro_reservoir, turbines)

    collected_turbines = collect(get_components(HydroTurbine, sys))
    @test length(turbines) == length(collected_turbines)
    @test !has_upstream_turbine(hydro_reservoir)
    @test has_downstream_turbine(hydro_reservoir)
    @test length(get_downstream_turbines(hydro_reservoir)) == 5
    @test isempty(get_upstream_turbines(hydro_reservoir))

    get_turbine_head_reservoirs_mapping(sys)
    @test length(get_connected_head_reservoirs(sys, turbines[1])) == 1

    remove_turbine!(hydro_reservoir, turbines[1])
    @test length(get_downstream_turbines(hydro_reservoir)) == 4
    clear_turbines!(hydro_reservoir)
    @test isempty(get_downstream_turbines(hydro_reservoir))
end

@testset "Test single `HydroTurbine` with multiple `HydroReservoir`" begin
    sys = System(100.0)

    bus = nodes5()[4]
    bus.name = "bus1"
    bus.number = 1
    add_component!(sys, bus)

    hydro_reservoir_01 = HydroReservoir(nothing)
    hydro_reservoir_02 = HydroReservoir(nothing)
    hydro_reservoir_02.name = "reservoir02"
    add_component!(sys, hydro_reservoir_01)
    add_component!(sys, hydro_reservoir_02)
    turbine = HydroTurbine(nothing)
    turbine.bus = bus
    add_component!(sys, turbine)
    set_downstream_turbine!(hydro_reservoir_01, turbine)
    set_downstream_turbine!(hydro_reservoir_02, turbine)
    @test length(get_connected_head_reservoirs(sys, turbine)) == 2
    @test isempty(get_connected_tail_reservoirs(sys, turbine))
end
