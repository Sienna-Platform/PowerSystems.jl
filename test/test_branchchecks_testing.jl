import TimeSeries: TimeArray

@testset "Time resolution" begin
    twomins = TimeArray([DateTime(today()) + Dates.Minute(i * 2) for i in 1:5], ones(5))
    oneday = TimeArray([DateTime(today()) + Dates.Day(i) for i in 1:5], ones(5))
    onesec = TimeArray([DateTime(today()) + Dates.Second(i) for i in 1:5], ones(5))
    onehour = TimeArray([DateTime(today()) + Dates.Hour(i) for i in 1:5], ones(5))

    @test PowerSystems.get_resolution(twomins) == Dates.Minute(2)
    @test PowerSystems.get_resolution(oneday) == Dates.Day(1)
    @test PowerSystems.get_resolution(onesec) == Dates.Second(1)
    @test PowerSystems.get_resolution(onehour) == Dates.Hour(1)
end

@testset "Angle limits" begin
    nodes5 = [
        ACBus(
            1,
            "nodeA",
            true,
            PowerSystems.ACBusTypes.PV,
            0,
            1.0,
            (min = 0.9, max = 1.05),
            230,
            nothing,
            nothing,
        ),
        ACBus(
            2,
            "nodeB",
            true,
            PowerSystems.ACBusTypes.PQ,
            0,
            1.0,
            (min = 0.9, max = 1.05),
            230,
            nothing,
            nothing,
        ),
        ACBus(
            3,
            "nodeC",
            true,
            PowerSystems.ACBusTypes.PV,
            0,
            1.0,
            (min = 0.9, max = 1.05),
            230,
            nothing,
            nothing,
        ),
        ACBus(
            4,
            "nodeD",
            true,
            PowerSystems.ACBusTypes.REF,
            0,
            1.0,
            (min = 0.9, max = 1.05),
            230,
            nothing,
            nothing,
        ),
        ACBus(
            5,
            "nodeE",
            true,
            PowerSystems.ACBusTypes.PV,
            0,
            1.0,
            (min = 0.9, max = 1.05),
            230,
            nothing,
            nothing,
        ),
    ]

    branches_test = [
        Line(
            "1",
            true,
            0.0,
            0.0,
            Arc(; from = nodes5[1], to = nodes5[2]),
            0.00281,
            0.0281,
            (from = 0.00356, to = 0.00356),
            400.0,
            (min = -360.0, max = 360.0),
        ),
        Line(
            "2",
            true,
            0.0,
            0.0,
            Arc(; from = nodes5[1], to = nodes5[4]),
            0.00304,
            0.0304,
            (from = 0.00329, to = 0.00329),
            3960.0,
            (min = -360.0, max = 75.0),
        ),
        Line(
            "3",
            true,
            0.0,
            0.0,
            Arc(; from = nodes5[1], to = nodes5[5]),
            0.00064,
            0.0064,
            (from = 0.01563, to = 0.01563),
            18812.0,
            (min = -75.0, max = 360.0),
        ),
        Line(
            "4",
            true,
            0.0,
            0.0,
            Arc(; from = nodes5[2], to = nodes5[3]),
            0.00108,
            0.0108,
            (from = 0.00926, to = 0.00926),
            11148.0,
            (min = 0.0, max = 0.0),
        ),
        Line(
            "5",
            true,
            0.0,
            0.0,
            Arc(; from = nodes5[3], to = nodes5[4]),
            0.00297,
            0.0297,
            (from = 0.00337, to = 0.00337),
            4053.0,
            (min = -1.2, max = 60.0),
        ),
        Line(
            "6",
            true,
            0.0,
            0.0,
            Arc(; from = nodes5[4], to = nodes5[5]),
            0.00297,
            0.0297,
            (from = 0.00337, to = 00.00337),
            240.0,
            (min = -1.17, max = 1.17),
        ),
    ]

    foreach(x -> PowerSystems.sanitize_angle_limits!(x), branches_test)

    @test branches_test[1].angle_limits == (min = -pi / 2, max = pi / 2)
    @test branches_test[2].angle_limits == (min = -pi / 2, max = 75.0 * (π / 180))
    @test branches_test[3].angle_limits == (min = -75.0 * (π / 180), max = pi / 2)
    @test branches_test[4].angle_limits == (min = -pi / 2, max = pi / 2)
    @test branches_test[5].angle_limits == (min = -1.2, max = 60.0 * (π / 180))
    @test branches_test[6].angle_limits == (min = -1.17, max = 1.17)

    bad_angle_limits = Line(
        "1",
        true,
        0.0,
        0.0,
        Arc(; from = nodes5[1], to = nodes5[2]),
        0.00281,
        0.0281,
        (from = 0.00356, to = 0.00356),
        400.0,
        (min = 360.0, max = -360.0),
    )

    @test_throws(
        PowerSystems.DataFormatError,
        PowerSystems.sanitize_angle_limits!(bad_angle_limits)
    )
end

@testset "Negative branch rating fails validation cleanly" begin
    # Two buses at equal base voltage so the endpoint-voltage check passes and
    # validation reaches correct_rate_limits!.
    bus_from = ACBus(
        1, "from", true, ACBusTypes.REF, 0, 1.0, (min = 0.9, max = 1.05), 230,
        nothing, nothing,
    )
    bus_to = ACBus(
        2, "to", true, ACBusTypes.PQ, 0, 1.0, (min = 0.9, max = 1.05), 230,
        nothing, nothing,
    )
    sys = System(100.0; runchecks = false)
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    neg_line = Line(
        "negline",
        true,
        0.0,
        0.0,
        Arc(; from = bus_from, to = bus_to),
        0.01,
        0.1,
        (from = 0.00356, to = 0.00356),
        -1.0,                       # negative rating
        (min = -pi / 2, max = pi / 2),
    )
    add_component!(sys, neg_line)

    # An IS.MultiLogger is enabled at Error and rethrows log-record-generation
    # errors (catch_exceptions(::MultiLogger) == false), exactly like the loggers
    # Sienna test suites install. Under such a logger the previous `$(rating)`
    # typo raised UndefVarError instead of the intended IS.InvalidValue. A
    # NullLogger would *not* catch this regression because Julia never evaluates a
    # disabled log message.
    test_logger = IS.MultiLogger([ConsoleLogger(devnull, Logging.Error)])
    Logging.with_logger(test_logger) do
        @test_throws IS.InvalidValue PowerSystems.check_component(sys, neg_line)
    end
end

@testset "line_rating_calculation uses to-side minimum voltage" begin
    # Asymmetric endpoint voltage limits expose whether the to-side minimum
    # voltage is read from the correct bus.
    bus_from = ACBus(
        1, "from", true, ACBusTypes.REF, 0, 1.0, (min = 0.9, max = 1.05), 230,
        nothing, nothing,
    )
    bus_to = ACBus(
        2, "to", true, ACBusTypes.PQ, 0, 1.0, (min = 0.5, max = 1.05), 230,
        nothing, nothing,
    )
    line = Line(
        "l",
        true,
        0.0,
        0.0,
        Arc(; from = bus_from, to = bus_to),
        0.01,
        0.1,
        (from = 0.00356, to = 0.00356),
        100.0,
        (min = -0.2, max = 0.3),
    )

    r, x = 0.01, 0.1
    g = r / (r^2 + x^2)
    b = -x / (r^2 + x^2)
    y_mag = sqrt(g^2 + b^2)
    fr_vmin, to_vmin = 0.9, 0.5
    theta_max = 0.3
    c_max = sqrt(fr_vmin^2 + to_vmin^2 - 2 * fr_vmin * to_vmin * cos(theta_max))
    expected = y_mag * max(fr_vmin, to_vmin) * c_max

    @test PowerSystems.line_rating_calculation(line) ≈ expected
end

@testset "Negative transformer rating fails validation cleanly" begin
    bus_from = ACBus(
        1, "from", true, ACBusTypes.REF, 0, 1.0, (min = 0.9, max = 1.05), 230,
        nothing, nothing,
    )
    bus_to = ACBus(
        2, "to", true, ACBusTypes.PQ, 0, 1.0, (min = 0.9, max = 1.05), 230,
        nothing, nothing,
    )
    sys = System(100.0; runchecks = false)
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    # rating_b has no descriptor valid_range, so only the PSY-level guard can
    # reject a negative secondary rating.
    circuit = TransformerCircuit(;
        arc = Arc(; from = bus_from, to = bus_to),
        available = true,
        active_power_flow = 0.0,
        reactive_power_flow = 0.0,
        rating = 1.0,
        rating_b = -1.0,            # negative secondary rating
        base_power = 100.0,
        r = 0.01,
        x = 0.1,
    )
    xfrm = TwoWindingTransformer(;
        name = "negxfrm",
        circuit = circuit,
    )
    add_component!(sys, xfrm)

    test_logger = IS.MultiLogger([ConsoleLogger(devnull, Logging.Error)])
    Logging.with_logger(test_logger) do
        @test_throws IS.InvalidValue PowerSystems.check_component(sys, xfrm)
    end
end

function _circuit_check_buses()
    bus_from = ACBus(
        1, "wcfrom", true, ACBusTypes.REF, 0, 1.0, (min = 0.9, max = 1.05), 230,
        nothing, nothing,
    )
    bus_to = ACBus(
        2, "wcto", true, ACBusTypes.PQ, 0, 1.0, (min = 0.9, max = 1.05), 138,
        nothing, nothing,
    )
    return bus_from, bus_to
end

function _circuit_check_xfrm(name, bus_from, bus_to)
    xfrm = TwoWindingTransformer(nothing)
    set_name!(xfrm, name)
    w = get_circuit(xfrm)
    set_arc!(w, Arc(; from = bus_from, to = bus_to))
    set_rating!(w, 1.0 * CU)
    set_x!(xfrm, 0.1 * CU)
    return xfrm
end

@testset "Circuit tap outside [0, 2] throws on add_component!" begin
    sys = System(100.0)
    bus_from, bus_to = _circuit_check_buses()
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    xfrm = _circuit_check_xfrm("badtap", bus_from, bus_to)
    set_tap!(get_circuit(xfrm), 2.5)   # outside [0, 2]

    test_logger = IS.MultiLogger([ConsoleLogger(devnull, Logging.Error)])
    Logging.with_logger(test_logger) do
        @test_throws IS.InvalidValue add_component!(sys, xfrm)
    end
    @test get_component(TwoWindingTransformer, sys, "badtap") === nothing
end

@testset "Circuit α outside typical range warns but adds" begin
    sys = System(100.0)
    bus_from, bus_to = _circuit_check_buses()
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    xfrm = _circuit_check_xfrm("badalpha", bus_from, bus_to)
    set_α!(get_circuit(xfrm), 2.0)   # outside [-1.571, 1.571]

    @test_logs (:warn, r"phase shift") match_mode = :any add_component!(sys, xfrm)
    @test get_component(TwoWindingTransformer, sys, "badalpha") !== nothing
end

@testset "Circuit base_voltage_primary <= 0 throws on add_component!" begin
    sys = System(100.0)
    bus_from, bus_to = _circuit_check_buses()
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    xfrm = _circuit_check_xfrm("badbasevoltage", bus_from, bus_to)
    set_base_voltage_primary!(get_circuit(xfrm), -10.0)

    test_logger = IS.MultiLogger([ConsoleLogger(devnull, Logging.Error)])
    Logging.with_logger(test_logger) do
        @test_throws IS.InvalidValue add_component!(sys, xfrm)
    end
    @test get_component(TwoWindingTransformer, sys, "badbasevoltage") === nothing
end

@testset "Circuit base_voltage_secondary <= 0 throws on add_component!" begin
    sys = System(100.0)
    bus_from, bus_to = _circuit_check_buses()
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    xfrm = _circuit_check_xfrm("badbasevoltage2", bus_from, bus_to)
    set_base_voltage_secondary!(get_circuit(xfrm), -10.0)

    test_logger = IS.MultiLogger([ConsoleLogger(devnull, Logging.Error)])
    Logging.with_logger(test_logger) do
        @test_throws IS.InvalidValue add_component!(sys, xfrm)
    end
    @test get_component(TwoWindingTransformer, sys, "badbasevoltage2") === nothing
end

@testset "Circuit control_limits.min > max throws on add_component!" begin
    sys = System(100.0)
    bus_from, bus_to = _circuit_check_buses()
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    xfrm = _circuit_check_xfrm("badcontrollimits", bus_from, bus_to)
    set_control_limits!(get_circuit(xfrm), (min = 1.1, max = 0.9))   # inverted

    test_logger = IS.MultiLogger([ConsoleLogger(devnull, Logging.Error)])
    Logging.with_logger(test_logger) do
        @test_throws IS.InvalidValue add_component!(sys, xfrm)
    end
    @test get_component(TwoWindingTransformer, sys, "badcontrollimits") === nothing
end

@testset "Circuit controlled_quantity_limits.min > max throws on add_component!" begin
    sys = System(100.0)
    bus_from, bus_to = _circuit_check_buses()
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    xfrm = _circuit_check_xfrm("badcql", bus_from, bus_to)
    set_controlled_quantity_limits!(get_circuit(xfrm), (min = 1.05, max = 0.95))

    test_logger = IS.MultiLogger([ConsoleLogger(devnull, Logging.Error)])
    Logging.with_logger(test_logger) do
        @test_throws IS.InvalidValue add_component!(sys, xfrm)
    end
    @test get_component(TwoWindingTransformer, sys, "badcql") === nothing
end

@testset "Circuit number_of_tap_positions < 0 throws on add_component!" begin
    sys = System(100.0)
    bus_from, bus_to = _circuit_check_buses()
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    xfrm = _circuit_check_xfrm("badntp", bus_from, bus_to)
    set_number_of_tap_positions!(get_circuit(xfrm), -1)

    test_logger = IS.MultiLogger([ConsoleLogger(devnull, Logging.Error)])
    Logging.with_logger(test_logger) do
        @test_throws IS.InvalidValue add_component!(sys, xfrm)
    end
    @test get_component(TwoWindingTransformer, sys, "badntp") === nothing
end
