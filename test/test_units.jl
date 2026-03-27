@testset "Unit system invariants" begin
    sys = System(100.0)  # 100 MVA system base
    bus = ACBus(nothing)
    bus.name = "Bus1"
    bus.number = 1
    bus.base_voltage = 230.0
    add_component!(sys, bus)

    gen = ThermalStandard(nothing)
    gen.name = "Gen1"
    gen.base_power = 50.0  # 50 MVA, different from system base
    gen.active_power = 0.6  # device-base p.u.
    gen.reactive_power = 0.4
    gen.bus = bus
    add_component!(sys, gen)

    @testset "Internal storage is device-base per-unit" begin
        # Raw field access gives device-base p.u. values
        @test gen.active_power == 0.6
        @test gen.reactive_power == 0.4
    end

    @testset "base_power returns unitful MW" begin
        @test get_base_power(gen) == 50.0u"MW"
        @test gen.base_power == 50.0  # raw field is still Float64
        @test get_base_power(gen) isa Unitful.Quantity

        # With explicit unit requests
        @test get_base_power(gen, MW) == 50.0u"MW"
        @test PSY.ustrip(get_base_power(gen, DU)) ≈ 1.0  # always 1.0 by definition
        @test PSY.ustrip(get_base_power(gen, SU)) ≈ 50.0 / 100.0  # 50MW / 100MVA system

        # Setter accepts unitful
        set_base_power!(gen, 75.0u"MW")
        @test gen.base_power == 75.0
        # Setter also accepts raw Float64 for backward compat
        set_base_power!(gen, 50.0)
        @test gen.base_power == 50.0
    end

    @testset "Explicit unit requests return correct values" begin
        device_base = PSY._get_base_power(gen)  # raw Float64
        system_base = PSY._get_base_power(sys)

        # DU returns the raw stored value with DU tag
        @test PSY.ustrip(get_active_power(gen, DU)) ≈ 0.6

        # MW converts from device-base p.u. to natural units
        @test Unitful.ustrip(get_active_power(gen, MW)) ≈ 0.6 * device_base

        # SU converts from device-base p.u. to system-base p.u.
        @test PSY.ustrip(get_active_power(gen, SU)) ≈ 0.6 * device_base / system_base
    end

    @testset "Setters convert back to device-base per-unit" begin
        device_base = PSY._get_base_power(gen)
        system_base = PSY._get_base_power(sys)

        # Setting with MW converts to device-base p.u. for storage
        set_active_power!(gen, 30.0MW)
        @test gen.active_power ≈ 30.0 / device_base

        # Setting with DU stores the value directly
        set_active_power!(gen, 0.6DU)
        @test gen.active_power ≈ 0.6

        # Setting with SU converts from system-base to device-base for storage
        set_active_power!(gen, 0.3SU)
        @test gen.active_power ≈ 0.3 * system_base / device_base

        # Restore
        set_active_power!(gen, 0.6DU)
    end

    @testset "Round-trip: get then set preserves value" begin
        original = gen.active_power

        for units in (MW, DU, SU)
            val = get_active_power(gen, units)
            set_active_power!(gen, val)
            @test gen.active_power ≈ original atol = 1e-12
        end
    end
end

@testset "Unit conversion tables" begin
    sys = System(100.0)
    bus1 = ACBus(nothing)
    bus1.name = "Bus1"
    bus1.number = 1
    bus1.base_voltage = 230.0
    add_component!(sys, bus1)

    bus2 = ACBus(nothing)
    bus2.name = "Bus2"
    bus2.number = 2
    bus2.base_voltage = 230.0
    add_component!(sys, bus2)

    arc = Arc(; from = bus1, to = bus2)
    add_component!(sys, arc)

    line = Line(nothing)
    line.name = "Line1"
    line.arc = arc
    line.r = 0.01    # device-base p.u.
    line.x = 0.1     # device-base p.u.
    line.rating = 2.0 # device-base p.u.
    add_component!(sys, line)

    base_power = PSY._get_base_power(sys)  # raw Float64
    base_voltage = bus1.base_voltage
    z_base = base_voltage^2 / base_power  # Ω

    @testset "Impedance: ohm category" begin
        # DU is raw stored value
        @test PSY.ustrip(get_r(line, DU)) ≈ 0.01

        # Natural units: multiply by Z_base
        r_ohm = get_r(line, OHMS)
        @test Unitful.ustrip(r_ohm) ≈ 0.01 * z_base
    end

    @testset "Power: mva category" begin
        # rating in DU
        @test PSY.ustrip(get_rating(line, DU)) ≈ 2.0

        # rating in MW
        @test Unitful.ustrip(get_rating(line, MW)) ≈ 2.0 * base_power
    end
end
