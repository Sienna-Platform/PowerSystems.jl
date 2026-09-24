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

@testset "TwoTerminalVSCLine remote-control / rated-DC-voltage fields" begin
    # Defaults come from the `::Nothing` demo constructor.
    default_vsc = TwoTerminalVSCLine(nothing)
    @test get_rated_dc_voltage(default_vsc) == 0.0
    @test get_rated_ac_voltage_from(default_vsc) == 0.0
    @test get_rated_ac_voltage_to(default_vsc) == 0.0
    @test isnothing(get_remote_regulated_bus_from(default_vsc))
    @test isnothing(get_remote_regulated_bus_to(default_vsc))

    from_bus = ACBus(nothing)
    to_bus = ACBus(nothing)
    remote_from = ACBus(nothing)
    remote_to = ACBus(nothing)
    arc = Arc(from_bus, to_bus)
    vsc = TwoTerminalVSCLine(;
        name = "vsc",
        available = true,
        arc = arc,
        active_power_flow = 0.1,
        rating = 2.0,
        active_power_limits_from = (min = -2.0, max = 2.0),
        active_power_limits_to = (min = -2.0, max = 2.0),
        rated_dc_voltage = 320.0,
        rated_ac_voltage_from = 230.0,
        rated_ac_voltage_to = 138.0,
        remote_regulated_bus_from = remote_from,
        remote_regulated_bus_to = remote_to,
        input_basis = CU,
    )
    @test get_rated_dc_voltage(vsc) == 320.0
    @test get_rated_ac_voltage_from(vsc) == 230.0
    @test get_rated_ac_voltage_to(vsc) == 138.0
    @test get_remote_regulated_bus_from(vsc) === remote_from
    @test get_remote_regulated_bus_to(vsc) === remote_to
    @test get_regulated_bus_from(vsc) === remote_from
    @test get_regulated_bus_to(vsc) === remote_to

    set_rated_dc_voltage!(vsc, 500.0)
    set_rated_ac_voltage_from!(vsc, 345.0)
    set_rated_ac_voltage_to!(vsc, 161.0)
    set_remote_regulated_bus_from!(vsc, nothing)
    set_remote_regulated_bus_to!(vsc, nothing)
    @test get_rated_dc_voltage(vsc) == 500.0
    @test get_rated_ac_voltage_from(vsc) == 345.0
    @test get_rated_ac_voltage_to(vsc) == 161.0
    @test get_regulated_bus_from(vsc) === from_bus
    @test get_regulated_bus_to(vsc) === to_bus
end

@testset "InterconnectingConverter VSC remote-control / voltage-limit fields" begin
    default_ic = InterconnectingConverter(nothing)
    @test isnothing(get_remote_regulated_bus(default_ic))

    own_bus = ACBus(nothing)
    remote_bus = ACBus(nothing)
    ic = InterconnectingConverter(;
        name = "ipc",
        available = true,
        bus = own_bus,
        dc_bus = DCBus(nothing),
        active_power = 0.0,
        rating = 1.0,
        active_power_limits = (min = -1.0, max = 1.0),
        base_power = 100.0,
        remote_regulated_bus = remote_bus,
        power_factor_weighting_fraction = 0.25,
        voltage_limits = (min = 0.9, max = 1.1),
        input_basis = CU,
    )
    @test get_remote_regulated_bus(ic) === remote_bus
    @test get_regulated_bus(ic) === remote_bus
    @test get_power_factor_weighting_fraction(ic) == 0.25
    @test get_voltage_limits(ic) == (min = 0.9, max = 1.1)

    set_remote_regulated_bus!(ic, nothing)
    set_power_factor_weighting_fraction!(ic, 0.75)
    set_voltage_limits!(ic, (min = 0.95, max = 1.05))
    @test isnothing(get_remote_regulated_bus(ic))
    @test get_regulated_bus(ic) === own_bus
    @test get_power_factor_weighting_fraction(ic) == 0.75
    @test get_voltage_limits(ic) == (min = 0.95, max = 1.05)

    # A remote regulated bus equal to the own bus is invalid.
    sys = System(100.0; runchecks = false)
    bad_ic = InterconnectingConverter(;
        name = "bad_ic",
        available = true,
        bus = own_bus,
        dc_bus = DCBus(nothing),
        active_power = 0.0,
        rating = 1.0,
        active_power_limits = (min = -1.0, max = 1.0),
        base_power = 100.0,
        remote_regulated_bus = own_bus,
        input_basis = CU,
    )
    @test_logs (:error, r"own bus") match_mode = :any @test_throws IS.InvalidValue PowerSystems.check_component(
        sys,
        bad_ic,
    )
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
