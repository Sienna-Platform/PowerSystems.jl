@testset "Test supplemental voltage accessors" begin
    @testset "get_base_voltage for Line - matching voltages" begin
        sys = PSB.build_system(PSB.PSITestSystems, "c_sys5")
        lines = collect(get_components(Line, sys))
        @test !isempty(lines)
        for line in lines
            from_bus = get_from(get_arc(line))
            expected = get_base_voltage(from_bus)
            @test get_base_voltage(line) == expected
            @test get_base_voltage(line) isa Float64
        end
    end

    @testset "get_base_voltage for Line - within tolerance picks rounder value" begin
        bus_from = ACBus(nothing)
        bus_from.name = "bus_from"
        bus_from.number = 1
        bus_from.bustype = ACBusTypes.PV
        bus_from.base_voltage = 230.0

        bus_to = ACBus(nothing)
        bus_to.name = "bus_to"
        bus_to.number = 2
        bus_to.bustype = ACBusTypes.PQ
        bus_to.base_voltage = 229.5  # within 1% of 230.0

        arc = Arc(; from = bus_from, to = bus_to)
        line = Line(
            "test_line",
            true,
            0.0,
            0.0,
            arc,
            0.01,
            0.05,
            (from = 0.0, to = 0.0),
            100.0,
            (min = -0.7, max = 0.7),
        )
        # 230.0 has fewer significant figures than 229.5
        @test get_base_voltage(line) == 230.0

        # Reverse: from has more digits, to has fewer
        bus_from2 = ACBus(nothing)
        bus_from2.name = "bus_from2"
        bus_from2.number = 3
        bus_from2.bustype = ACBusTypes.PV
        bus_from2.base_voltage = 229.5

        bus_to2 = ACBus(nothing)
        bus_to2.name = "bus_to2"
        bus_to2.number = 4
        bus_to2.bustype = ACBusTypes.PQ
        bus_to2.base_voltage = 230.0

        arc2 = Arc(; from = bus_from2, to = bus_to2)
        line2 = Line(
            "test_line2",
            true,
            0.0,
            0.0,
            arc2,
            0.01,
            0.05,
            (from = 0.0, to = 0.0),
            100.0,
            (min = -0.7, max = 0.7),
        )
        @test get_base_voltage(line2) == 230.0
    end

    @testset "get_base_voltage for Line - exceeds tolerance throws error" begin
        bus_from = ACBus(nothing)
        bus_from.name = "bus_hi"
        bus_from.number = 5
        bus_from.bustype = ACBusTypes.PV
        bus_from.base_voltage = 230.0

        bus_to = ACBus(nothing)
        bus_to.name = "bus_lo"
        bus_to.number = 6
        bus_to.bustype = ACBusTypes.PQ
        bus_to.base_voltage = 115.0  # 50% difference

        arc = Arc(; from = bus_from, to = bus_to)
        line = Line(
            "bad_line",
            true,
            0.0,
            0.0,
            arc,
            0.01,
            0.05,
            (from = 0.0, to = 0.0),
            100.0,
            (min = -0.7, max = 0.7),
        )
        @test_throws ErrorException get_base_voltage(line)
    end

    @testset "get_high_voltage and get_low_voltage for TapTransformer" begin
        sys = PSB.build_system(PSB.PSITestSystems, "c_sys14")
        taps = collect(get_components(TapTransformer, sys))
        @test !isempty(taps)
        for t in taps
            v_primary = get_base_voltage_primary(t)
            v_secondary = get_base_voltage_secondary(t)
            @test get_high_voltage(t) == max(v_primary, v_secondary)
            @test get_low_voltage(t) == min(v_primary, v_secondary)
            @test get_high_voltage(t) >= get_low_voltage(t)
            @test get_high_voltage(t) isa Float64
            @test get_low_voltage(t) isa Float64
        end
    end

    @testset "get_high_voltage and get_low_voltage for Transformer2W" begin
        sys = PSB.build_system(PSB.PSITestSystems, "c_sys14")
        t2ws = collect(get_components(Transformer2W, sys))
        @test !isempty(t2ws)
        for t in t2ws
            v_primary = get_base_voltage_primary(t)
            v_secondary = get_base_voltage_secondary(t)
            @test get_high_voltage(t) == max(v_primary, v_secondary)
            @test get_low_voltage(t) == min(v_primary, v_secondary)
            @test get_high_voltage(t) >= get_low_voltage(t)
        end
    end
end
