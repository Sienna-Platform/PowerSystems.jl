
@testset "total_load_rating: sums StaticLoad and admittance loads as Float64 MW" begin
    sys = System(100.0)
    bus = ACBus(;
        number = 1, name = "b1", available = true,
        bustype = ACBusTypes.REF, angle = 0.0, magnitude = 1.0,
        voltage_limits = (min = 0.9, max = 1.1), base_voltage = 138.0,
    )
    add_component!(sys, bus)

    # Empty system: returns 0.0 (Float64), not unitful.
    @test PowerSystems.total_load_rating(sys) === 0.0

    load = PowerLoad(;
        name = "load1", available = true, bus = bus,
        active_power = 0.5, reactive_power = 0.0,
        base_power = 100.0,
        max_active_power = 0.5, max_reactive_power = 0.0,
        input_basis = CU,
    )
    add_component!(sys, load)

    fa = FixedAdmittance(;
        name = "fa1", available = true, bus = bus, Y = 0.3 + 0.1im,
    )
    add_component!(sys, fa)

    # 50 MW from PowerLoad (0.5 pu * 100 MVA) + 30 MW from FixedAdmittance
    # (Re(Y)=0.3 pu * 100 MVA system base, with assumed |V|=1.0).
    total = PowerSystems.total_load_rating(sys)
    @test total isa Float64
    @test total ≈ 80.0
end
