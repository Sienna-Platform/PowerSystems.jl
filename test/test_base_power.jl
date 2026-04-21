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

@testset "Test unit-aware get_base_power" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys"; add_forecasts = false)
    gen = get_component(ThermalStandard, sys, "322_CT_6")
    # Force a distinct device base so DU/SU ratio tests are non-trivial.
    set_base_power!(gen, 250.0)
    device_base = PSY._get_base_power(gen)
    system_base = PSY._get_base_power(sys)
    @test device_base != system_base

    # 1-arg form is gone — public getter requires explicit units.
    @test_throws MethodError get_base_power(gen)

    bp_nu = get_base_power(gen, NU)
    @test bp_nu isa Unitful.Quantity
    @test Unitful.ustrip(bp_nu) ≈ device_base
    # Not double-wrapped: no `device_base * MVA * MVA`.
    @test Unitful.unit(bp_nu) == Unitful.unit(1.0 * MVA)

    bp_mw = get_base_power(gen, MW)
    @test bp_mw isa Unitful.Quantity
    @test Unitful.ustrip(MW, bp_mw) ≈ device_base

    bp_su = get_base_power(gen, SU)
    @test bp_su isa RelativeQuantity
    @test ustrip(bp_su) ≈ device_base / system_base

    # DU is self-referential: base_power in device-base pu is always 1.
    bp_du = get_base_power(gen, DU)
    @test bp_du isa RelativeQuantity
    @test ustrip(bp_du) == 1.0

    # Float64 fast path returns bare Float64 in system base (like other getters).
    bp_f64 = get_base_power(gen, Float64)
    @test bp_f64 isa Float64
    @test bp_f64 ≈ device_base / system_base

    # Components with no base_power field fall back to system base, so DU == SU == 1.
    bus = first(get_components(ACBus, sys))
    @test ustrip(get_base_power(bus, SU)) ≈ 1.0
    @test Unitful.ustrip(get_base_power(bus, NU)) ≈ system_base

    # System-level unitful getter mirrors the component version.
    @test_throws MethodError get_base_power(sys)
    @test Unitful.ustrip(get_base_power(sys, NU)) ≈ system_base
    @test ustrip(get_base_power(sys, SU)) == 1.0
    @test get_base_power(sys, Float64) ≈ system_base
end

# TODO: re-enable once PowerSystemCaseBuilder no longer relies on PSY parsers
# (PSB.build_system uses PSY.PowerSystemTableData internally).
# @testset "Test adding component with zero base power" begin
#     sys = build_system(PSISystems, "RTS_GMLC_DA_sys")
#     bus = first(get_components(PSY.Bus, sys))
#     gen = thermal_with_base_power(bus, "Test Gen with Zero Base Power", 0.0)
#     @test_logs (:warn, "Invalid range") match_mode = :any add_component!(sys, gen)
#     gen2 = thermal_with_base_power(bus, "Test Gen with Non-Zero Base Power", 100.0)
#     @test_nowarn add_component!(sys, gen2)
#     # uncomment if we correct to non-zero base power.
#     #=
#     with_units_base(sys, "SYSTEM_BASE") do
#         gen_added = PSY.get_component(PSY.ThermalStandard, sys, "Test Gen with Zero Base Power")
#         PSY.set_reactive_power!(gen_added, 0.0)
#         @test !isnan(PSY.get_reactive_power(gen_added))
#     end
#     =#
# end
