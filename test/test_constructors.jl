@testset "Bus Constructors" begin
    bus = ACBus(
        1,
        "test",
        true,
        ACBusTypes.SLACK,
        0.0,
        0.0,
        (min = 0.0, max = 0.0),
        nothing,
        nothing,
        nothing,
    )

    # SLACK is preserved as an explicit area-slack marker distinct from the system REF bus.
    @test PowerSystems.get_bustype(bus) == ACBusTypes.SLACK
end

@testset "OperationalCost demo constructors" begin
    for T in InteractiveUtils.subtypes(PSY.OperationalCost)
        isabstracttype(T) || (@test T(nothing) isa IS.InfrastructureSystemsType)
    end
    # TODO add concrete subtypes of ProductionVariableCostCurve?
end

@testset "TwoTerminalVSCLine remote-regulated-bus / rated-DC-voltage fields" begin
    # Defaults come from the `::Nothing` demo constructor.
    default_vsc = TwoTerminalVSCLine(nothing)
    @test get_rated_dc_voltage(default_vsc) == 0.0
    @test get_rated_ac_voltage_from(default_vsc) == 0.0
    @test get_rated_ac_voltage_to(default_vsc) == 0.0
    @test isnothing(get_remote_regulated_bus_from(default_vsc))
    @test isnothing(get_remote_regulated_bus_to(default_vsc))

    arc = Arc(ACBus(nothing), ACBus(nothing))
    remote_bus_a = ACBus(nothing)
    remote_bus_b = ACBus(nothing)
    vsc = TwoTerminalVSCLine(;
        name = "vsc",
        available = true,
        arc = arc,
        active_power_flow = 0.1,
        rating = 2.0,
        dc_control_from = VSCDCControlModes.DC_POWER,
        ac_control_from = VSCACControlModes.AC_REACTIVE_POWER,
        dc_control_to = VSCDCControlModes.DC_VOLTAGE,
        ac_control_to = VSCACControlModes.AC_VOLTAGE,
        dc_power_setpoint_from = 0.1,
        power_factor_setpoint_from = 0.98,
        dc_voltage_setpoint_to = 1.0,
        rated_dc_voltage = 320.0,
        rated_ac_voltage_from = 230.0,
        rated_ac_voltage_to = 138.0,
        remote_regulated_bus_from = remote_bus_a,
        remote_regulated_bus_to = remote_bus_b,
        input_basis = u"CU",
    )
    @test get_rated_dc_voltage(vsc) == 320.0
    @test get_rated_ac_voltage_from(vsc) == 230.0
    @test get_rated_ac_voltage_to(vsc) == 138.0
    @test get_remote_regulated_bus_from(vsc) === remote_bus_a
    @test get_remote_regulated_bus_to(vsc) === remote_bus_b

    set_rated_dc_voltage!(vsc, 500.0)
    set_rated_ac_voltage_from!(vsc, 345.0)
    set_rated_ac_voltage_to!(vsc, 161.0)
    set_remote_regulated_bus_from!(vsc, remote_bus_b)
    set_remote_regulated_bus_to!(vsc, nothing)
    @test get_rated_dc_voltage(vsc) == 500.0
    @test get_rated_ac_voltage_from(vsc) == 345.0
    @test get_rated_ac_voltage_to(vsc) == 161.0
    @test get_remote_regulated_bus_from(vsc) === remote_bus_b
    @test isnothing(get_remote_regulated_bus_to(vsc))

    # Each mode selects one setpoint field; the other one of the pair is nothing.
    @test get_dc_power_setpoint_from(vsc, u"CU") == 0.1
    @test isnothing(get_dc_voltage_setpoint_from(vsc))
    @test get_dc_voltage_setpoint_to(vsc) == 1.0
    @test isnothing(get_dc_power_setpoint_to(vsc, u"CU"))
    @test get_power_factor_setpoint_from(vsc) == 0.98
    @test isnothing(get_power_factor_setpoint_to(vsc))
end

@testset "TwoTerminalVSCLine and InterconnectingConverter control modes have no default" begin
    arc = Arc(ACBus(nothing), ACBus(nothing))
    @test_throws UndefKeywordError TwoTerminalVSCLine(;
        name = "vsc", available = true, arc = arc, active_power_flow = 0.1, rating = 2.0,
        input_basis = u"CU",
    )
    @test_throws UndefKeywordError InterconnectingConverter(;
        name = "ipc", available = true, bus = ACBus(nothing), dc_bus = DCBus(nothing),
        active_power = 0.0, rating = 1.0, active_power_limits = (min = -1.0, max = 1.0),
        base_power = 100.0, input_basis = u"CU",
    )
end

@testset "InterconnectingConverter VSC remote-regulated-bus / voltage-limit fields" begin
    default_ic = InterconnectingConverter(nothing)
    @test isnothing(get_remote_regulated_bus(default_ic))
    @test get_rated_ac_voltage(default_ic) == 0.0
    @test get_rated_dc_voltage(default_ic) == 0.0

    remote_bus = ACBus(nothing)
    ic = InterconnectingConverter(;
        name = "ipc",
        available = true,
        bus = ACBus(nothing),
        dc_bus = DCBus(nothing),
        active_power = 0.0,
        rating = 1.0,
        active_power_limits = (min = -1.0, max = 1.0),
        base_power = 100.0,
        dc_control = VSCDCControlModes.DC_VOLTAGE,
        ac_control = VSCACControlModes.AC_REACTIVE_POWER,
        dc_voltage_setpoint = 1.0,
        power_factor_setpoint = 1.0,
        remote_regulated_bus = remote_bus,
        power_factor_weighting_fraction = 0.25,
        voltage_limits = (min = 0.9, max = 1.1),
        rated_ac_voltage = 230.0,
        rated_dc_voltage = 320.0,
        input_basis = u"CU",
    )
    @test get_remote_regulated_bus(ic) === remote_bus
    @test get_rated_ac_voltage(ic) == 230.0
    @test get_rated_dc_voltage(ic) == 320.0
    @test get_power_factor_weighting_fraction(ic) == 0.25
    @test get_voltage_limits(ic) == (min = 0.9, max = 1.1)

    set_remote_regulated_bus!(ic, nothing)
    set_power_factor_weighting_fraction!(ic, 0.75)
    set_voltage_limits!(ic, (min = 0.95, max = 1.05))
    @test isnothing(get_remote_regulated_bus(ic))
    @test get_power_factor_weighting_fraction(ic) == 0.75
    @test get_voltage_limits(ic) == (min = 0.95, max = 1.05)
end

# Smoke: every time-series type must keep accepting both its positional and its keyword
# constructor form. Construction is the assertion; a signature change throws here.
@testset "TimeSeriesData Constructors" begin
    data = PowerSystems.TimeSeries.TimeArray(
        [DateTime("01-01-01"), DateTime("01-01-01") + Hour(1)],
        [1.0, 1.0],
    )
    SingleTimeSeries("scalingfactor", Hour(1), DateTime("01-01-01"), 24)
    SingleTimeSeries(; name = "scalingfactor", data = data)

    data = SortedDict(
        DateTime("01-01-01") => [1.0 1.0; 2.0 2.0],
        DateTime("01-01-01") + Hour(1) => [1.0 1.0; 2.0 2.0],
    )
    Probabilistic("scalingfactor", data, [0.5, 0.5], Hour(1))
    Probabilistic(;
        name = "scalingfactor",
        percentiles = [1.0, 1.0],
        data = data,
        resolution = Hour(1),
    )
    Scenarios("scalingfactor", data, Hour(1))
end
