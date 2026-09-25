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
        input_basis = CU,
    )
    xfrm = TwoWindingTransformer(;
        name = "negxfrm",
        circuit = circuit,
        input_basis = CU,
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

"""A circuit with `objective` and the given bands set; convertible bands take tagged values."""
function _controlled_xfrm(name, bus_from, bus_to, objective; bands...)
    xfrm = _circuit_check_xfrm(name, bus_from, bus_to)
    w = get_circuit(xfrm)
    set_control_objective!(w, objective)
    for (field, band) in pairs(bands)
        getfield(PowerSystems, Symbol("set_", field, "!"))(w, band)
    end
    return xfrm
end

function _expect_invalid_circuit(xfrm, bus_from, bus_to)
    sys = System(100.0)
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    test_logger = IS.MultiLogger([ConsoleLogger(devnull, Logging.Error)])
    Logging.with_logger(test_logger) do
        @test_throws IS.InvalidValue add_component!(sys, xfrm)
    end
    @test get_component(TwoWindingTransformer, sys, get_name(xfrm)) === nothing
end

# One inverted band per fixed-quantity field, each under an objective that selects it.
@testset "Circuit tap_ratio_limits.min > max throws on add_component!" begin
    bus_from, bus_to = _circuit_check_buses()
    _expect_invalid_circuit(
        _controlled_xfrm(
            "badtap", bus_from, bus_to, TransformerControlObjective.VOLTAGE;
            tap_ratio_limits = (min = 1.1, max = 0.9),
            controlled_voltage_limits = (min = 0.95, max = 1.05),
        ),
        bus_from, bus_to,
    )
end

@testset "Circuit phase_angle_limits.min > max throws on add_component!" begin
    bus_from, bus_to = _circuit_check_buses()
    _expect_invalid_circuit(
        _controlled_xfrm(
            "badangle", bus_from, bus_to, TransformerControlObjective.ACTIVE_POWER_FLOW;
            phase_angle_limits = (min = 0.5, max = -0.5),
            controlled_active_power_flow_limits = (min = -1.0 * CU, max = 1.0 * CU),
        ),
        bus_from, bus_to,
    )
end

@testset "Circuit controlled_voltage_limits.min > max throws on add_component!" begin
    bus_from, bus_to = _circuit_check_buses()
    _expect_invalid_circuit(
        _controlled_xfrm(
            "badcvl", bus_from, bus_to, TransformerControlObjective.VOLTAGE;
            tap_ratio_limits = (min = 0.9, max = 1.1),
            controlled_voltage_limits = (min = 1.05, max = 0.95),
        ),
        bus_from, bus_to,
    )
end

@testset "Circuit controlled_reactive_power_flow_limits.min > max throws on add_component!" begin
    bus_from, bus_to = _circuit_check_buses()
    _expect_invalid_circuit(
        _controlled_xfrm(
            "badcq", bus_from, bus_to, TransformerControlObjective.REACTIVE_POWER_FLOW;
            tap_ratio_limits = (min = 0.9, max = 1.1),
            controlled_reactive_power_flow_limits = (min = 0.5 * CU, max = -0.5 * CU),
        ),
        bus_from, bus_to,
    )
end

@testset "Circuit controlled_active_power_flow_limits.min > max throws on add_component!" begin
    bus_from, bus_to = _circuit_check_buses()
    _expect_invalid_circuit(
        _controlled_xfrm(
            "badcp", bus_from, bus_to, TransformerControlObjective.ACTIVE_POWER_FLOW;
            phase_angle_limits = (min = -0.5, max = 0.5),
            controlled_active_power_flow_limits = (min = 1.0 * CU, max = -1.0 * CU),
        ),
        bus_from, bus_to,
    )
end

@testset "Circuit missing the band its control_objective selects throws on add_component!" begin
    bus_from, bus_to = _circuit_check_buses()
    # VOLTAGE selects the tap band and the voltage band; only the tap band is set.
    _expect_invalid_circuit(
        _controlled_xfrm(
            "missingband", bus_from, bus_to, TransformerControlObjective.VOLTAGE;
            tap_ratio_limits = (min = 0.9, max = 1.1),
        ),
        bus_from, bus_to,
    )
end

@testset "Circuit band its control_objective does not use warns but adds" begin
    sys = System(100.0)
    bus_from, bus_to = _circuit_check_buses()
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    xfrm = _controlled_xfrm(
        "strayband", bus_from, bus_to, TransformerControlObjective.VOLTAGE;
        tap_ratio_limits = (min = 0.9, max = 1.1),
        controlled_voltage_limits = (min = 0.95, max = 1.05),
        controlled_active_power_flow_limits = (min = -1.0 * CU, max = 1.0 * CU),
    )
    @test_logs (:warn, r"does not use it") match_mode = :any add_component!(sys, xfrm)
    @test get_component(TwoWindingTransformer, sys, "strayband") !== nothing
end

function _switched_shunt(name, bus, mode; bands...)
    shunt = SwitchedAdmittance(nothing)
    set_name!(shunt, name)
    set_bus!(shunt, bus)
    set_available!(shunt, true)
    set_control_mode!(shunt, mode)
    for (field, band) in pairs(bands)
        getfield(PowerSystems, Symbol("set_", field, "!"))(shunt, band)
    end
    return shunt
end

@testset "SwitchedAdmittance control_mode selects its band on add_component!" begin
    bus_from, _ = _circuit_check_buses()
    sys = System(100.0)
    add_component!(sys, bus_from)
    band = (min = 0.95, max = 1.05)
    add_component!(
        sys,
        _switched_shunt("fixed", bus_from, SwitchedAdmittanceControlMode.FIXED),
    )
    add_component!(
        sys,
        _switched_shunt(
            "voltage", bus_from, SwitchedAdmittanceControlMode.DISCRETE_VOLTAGE;
            voltage_limits = band,
        ),
    )
    add_component!(
        sys,
        _switched_shunt(
            "reactive", bus_from, SwitchedAdmittanceControlMode.DISCRETE_REACTIVE_FACTS;
            reactive_power_range_limits = (min = 0.2, max = 0.8),
        ),
    )
    @test length(collect(get_components(SwitchedAdmittance, sys))) == 3

    test_logger = IS.MultiLogger([ConsoleLogger(devnull, Logging.Error)])
    Logging.with_logger(test_logger) do
        # the selected band missing, and the selected band inverted
        @test_throws IS.InvalidValue add_component!(
            sys,
            _switched_shunt(
                "missing",
                bus_from,
                SwitchedAdmittanceControlMode.CONTINUOUS_VOLTAGE,
            ),
        )
        @test_throws IS.InvalidValue add_component!(
            sys,
            _switched_shunt(
                "inverted", bus_from, SwitchedAdmittanceControlMode.DISCRETE_REACTIVE_VSC;
                reactive_power_range_limits = (min = 0.8, max = 0.2),
            ),
        )
    end
    # an unselected band populated warns but adds
    @test_logs (:warn, r"does not use it") match_mode = :any add_component!(
        sys,
        _switched_shunt(
            "stray", bus_from, SwitchedAdmittanceControlMode.DISCRETE_VOLTAGE;
            voltage_limits = band, reactive_power_range_limits = (min = 0.2, max = 0.8),
        ),
    )
    @test get_component(SwitchedAdmittance, sys, "stray") !== nothing
end

@testset "Circuit UNDEFINED objective with every band nothing adds" begin
    sys = System(100.0)
    bus_from, bus_to = _circuit_check_buses()
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    xfrm = _circuit_check_xfrm("uncontrolled", bus_from, bus_to)
    add_component!(sys, xfrm)
    w = get_circuit(get_component(TwoWindingTransformer, sys, "uncontrolled"))
    @test get_control_objective(w) == TransformerControlObjective.UNDEFINED
    @test all(isnothing(getfield(w, f)) for f in PSY.CONTROL_BAND_FIELDS)
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
