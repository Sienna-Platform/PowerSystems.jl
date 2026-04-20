@testset "Test zero base power correction" begin
    sys = @test_logs(
        (:warn, r".*changing device base power to match system base power.*"),
        match_mode = :any,
        build_system(PSISystems, "RTS_GMLC_DA_sys"; force_build = true)
    )
    for comp in get_components(PSY.SynchronousCondenser, sys)
        @test abs(get_base_power(comp)) > eps()
    end
end

function thermal_with_base_power(bus::PSY.Bus, name::String, base_power::Float64)
    return ThermalStandard(;
        name = name,
        available = true,
        status = true,
        bus = bus,
        active_power = 1.0,
        reactive_power = 0.0,
        rating = 2.0,
        active_power_limits = (min = 0, max = 2),
        reactive_power_limits = (min = -2, max = 2),
        ramp_limits = nothing,
        operation_cost = ThermalGenerationCost(nothing),
        base_power = base_power,
        time_limits = nothing,
        prime_mover_type = PrimeMovers.OT,
        fuel = ThermalFuels.OTHER,
        services = Device[],
        dynamic_injector = nothing,
        ext = Dict{String, Any}(),
    )
end

@testset "Test adding component with zero base power" begin
    sys = build_system(PSISystems, "RTS_GMLC_DA_sys")
    bus = first(get_components(PSY.Bus, sys))
    gen = thermal_with_base_power(bus, "Test Gen with Zero Base Power", 0.0)
    @test_logs (:warn, "Invalid range") match_mode = :any add_component!(sys, gen)
    gen2 = thermal_with_base_power(bus, "Test Gen with Non-Zero Base Power", 100.0)
    @test_nowarn add_component!(sys, gen2)
    # uncomment if we correct to non-zero base power.
    #=
    with_units_base(sys, "SYSTEM_BASE") do
        gen_added = PSY.get_component(PSY.ThermalStandard, sys, "Test Gen with Zero Base Power")
        PSY.set_reactive_power!(gen_added, 0.0)
        @test !isnan(PSY.get_reactive_power(gen_added))
    end
    =#
end
