@testset "Test special accessors" begin
    cdmsys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    th = first(get_components(ThermalStandard, cdmsys))
    re = first(get_components(RenewableDispatch, cdmsys))

    @test get_max_active_power(th, SU) == get_active_power_limits(th, SU).max
    @test get_max_active_power(re, SU) <= get_rating(re, SU)
    @test isa(get_max_reactive_power(re, SU), Float64)

    @test_throws MethodError get_max_active_power(TestDevice("foo"), SU)
    @test_throws ArgumentError get_max_active_power(TestInjector("foo"), SU)
    @test_throws ArgumentError get_max_active_power(TestRenDevice("foo"), SU)
end

@testset "Test Remove Area with Interchanges" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    area1 = get_component(Area, sys, "1")
    area2 = get_component(Area, sys, "2")
    area3 = get_component(Area, sys, "3")
    area_interchange12 = AreaInterchange(;
        name = "interchange_a1_a2",
        available = true,
        active_power_flow = 0.0,
        from_area = area1,
        to_area = area2,
        flow_limits = (from_to = 100.0, to_from = 100.0),
    )
    area_interchange13 = AreaInterchange(;
        name = "interchange_a1_a3",
        available = true,
        active_power_flow = 0.0,
        from_area = area1,
        to_area = area3,
        flow_limits = (from_to = 100.0, to_from = 100.0),
    )
    add_component!(sys, area_interchange12)
    add_component!(sys, area_interchange13)
    @test_throws ArgumentError remove_component!(sys, area1)
    remove_component!(sys, area_interchange12)
    remove_component!(sys, area_interchange13)
    remove_component!(sys, area1)
    @test get_component(Area, sys, "1") === nothing
end

@testset "Test Shiftable Power Loads and Interruptible PowerLoads" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    buses = collect(get_components(ACBus, sys))
    add_component!(
        sys,
        InterruptiblePowerLoad(
            "IloadBus",
            true,
            buses[1],
            0.10,
            0.0,
            0.10,
            0.0,
            100.0,
            LoadCost(CostCurve(LinearCurve(150.0)), 2400.0),
        ),
    )
    add_component!(
        sys,
        ShiftablePowerLoad(
            "ShiftableLoadBus4",
            true,
            buses[2],
            0.10,
            (min = 0.03, max = 0.10),
            0.0,
            0.10,
            0.0,
            100.0,
            24,
            LoadCost(CostCurve(LinearCurve(150.0)), 2400.0),
        ),
    )
    # Round-trip through a document: both `ShiftablePowerLoad` and `InterruptiblePowerLoad`
    # are now in `DOCUMENT_PLAN`. COMPONENT_BASE is an exact pass-through, so the DU values
    # below survive unchanged.
    sys2 = roundtrip_system(sys)
    @test get_active_power(
        get_component(ShiftablePowerLoad, sys2, "ShiftableLoadBus4"), DU) == 0.10
    @test get_active_power(
        get_component(InterruptiblePowerLoad, sys2, "IloadBus"), DU) == 0.10
    @test get_active_power_limits(
        get_component(ShiftablePowerLoad, sys2, "ShiftableLoadBus4"), DU,
    ).min == 0.03
    @test get_active_power_limits(
        get_component(ShiftablePowerLoad, sys2, "ShiftableLoadBus4"), DU,
    ).max == 0.10
end

@testset "Test static injection traits" begin
    # supports_active_power
    @test supports_active_power(ThermalStandard(nothing)) == true
    @test supports_active_power(ThermalMultiStart(nothing)) == true
    @test supports_active_power(RenewableDispatch(nothing)) == true
    @test supports_active_power(RenewableNonDispatch(nothing)) == true
    @test supports_active_power(HydroDispatch(nothing)) == true
    @test supports_active_power(HydroTurbine(nothing)) == true
    @test supports_active_power(HydroPumpTurbine(nothing)) == true
    @test supports_active_power(Source(nothing)) == true
    @test supports_active_power(InterconnectingConverter(nothing)) == true
    @test supports_active_power(EnergyReservoirStorage(nothing)) == true
    @test supports_active_power(PowerLoad(nothing)) == true
    @test supports_active_power(StandardLoad(nothing)) == true
    @test supports_active_power(ExponentialLoad(nothing)) == true
    @test supports_active_power(InterruptiblePowerLoad(nothing)) == true
    @test supports_active_power(ShiftablePowerLoad(nothing)) == true
    @test supports_active_power(HybridSystem(nothing)) == true
    @test supports_active_power(SynchronousCondenser(nothing)) == false
    @test supports_active_power(FixedAdmittance(nothing)) == false  # Y = 0
    @test supports_active_power(
        FixedAdmittance(; name = "fa_g", available = true, bus = ACBus(nothing),
            Y = 1.0 + 0.0im),
    ) == true
    @test supports_active_power(
        FixedAdmittance(; name = "fa_b", available = true, bus = ACBus(nothing),
            Y = 0.0 + 1.0im),
    ) == false
    # Below ZERO_ADMITTANCE_THRESHOLD (1e-4): treated as no support.
    @test supports_active_power(
        FixedAdmittance(; name = "fa_tiny", available = true, bus = ACBus(nothing),
            Y = 1e-6 + 1e-6im),
    ) == false
    @test supports_active_power(SwitchedAdmittance(nothing)) == false  # Y = 0, no blocks
    @test supports_active_power(
        SwitchedAdmittance(; name = "sa_g", available = true, bus = ACBus(nothing),
            Y = 1.0 + 0.0im),
    ) == true
    # Zero base Y, but a switchable block adds real (active) admittance.
    @test supports_active_power(
        SwitchedAdmittance(; name = "sa_gstep", available = true, bus = ACBus(nothing),
            Y = 0.0 + 0.0im, number_of_steps = [2], Y_increase = [1.0 + 0.0im]),
    ) == true
    @test supports_active_power(
        SwitchedAdmittance(; name = "sa_bstep", available = true, bus = ACBus(nothing),
            Y = 0.0 + 0.0im, number_of_steps = [2], Y_increase = [0.0 + 1.0im]),
    ) == false

    # FACTSControlDevice active power depends on control_mode (true only for NML)
    @test supports_active_power(FACTSControlDevice(nothing)) == false
    facts_nml = FACTSControlDevice(nothing)
    set_control_mode!(facts_nml, FACTSOperationModes.NML)
    @test supports_active_power(facts_nml) == true
    facts_byp = FACTSControlDevice(nothing)
    set_control_mode!(facts_byp, FACTSOperationModes.BYP)
    @test supports_active_power(facts_byp) == false
    facts_oos = FACTSControlDevice(nothing)
    set_control_mode!(facts_oos, FACTSOperationModes.OOS)
    @test supports_active_power(facts_oos) == false

    # supports_reactive_power
    @test supports_reactive_power(ThermalStandard(nothing)) == true
    @test supports_reactive_power(RenewableDispatch(nothing)) == true
    @test supports_reactive_power(Source(nothing)) == true
    @test supports_reactive_power(SynchronousCondenser(nothing)) == true
    @test supports_reactive_power(PowerLoad(nothing)) == true
    @test supports_reactive_power(EnergyReservoirStorage(nothing)) == true
    @test supports_reactive_power(HybridSystem(nothing)) == true
    @test supports_reactive_power(InterconnectingConverter(nothing)) == false
    @test supports_reactive_power(FixedAdmittance(nothing)) == false  # Y = 0
    @test supports_reactive_power(
        FixedAdmittance(; name = "fa_b2", available = true, bus = ACBus(nothing),
            Y = 0.0 + 1.0im),
    ) == true
    @test supports_reactive_power(
        FixedAdmittance(; name = "fa_g2", available = true, bus = ACBus(nothing),
            Y = 1.0 + 0.0im),
    ) == false
    @test supports_reactive_power(
        FixedAdmittance(; name = "fa_tiny2", available = true, bus = ACBus(nothing),
            Y = 1e-6 + 1e-6im),
    ) == false
    @test supports_reactive_power(SwitchedAdmittance(nothing)) == false  # Y = 0, no blocks
    @test supports_reactive_power(
        SwitchedAdmittance(; name = "sa_b", available = true, bus = ACBus(nothing),
            Y = 0.0 + 1.0im),
    ) == true
    # Zero base Y, but a switchable block adds susceptance (reactive).
    @test supports_reactive_power(
        SwitchedAdmittance(; name = "sa_bstep2", available = true, bus = ACBus(nothing),
            Y = 0.0 + 0.0im, number_of_steps = [2], Y_increase = [0.0 + 1.0im]),
    ) == true
    # A block with steps but a below-threshold increment does not count.
    @test supports_reactive_power(
        SwitchedAdmittance(; name = "sa_tinystep", available = true, bus = ACBus(nothing),
            Y = 0.0 + 0.0im, number_of_steps = [2], Y_increase = [0.0 + 1e-6im]),
    ) == false

    # FACTSControlDevice reactive power depends on control_mode
    @test supports_reactive_power(FACTSControlDevice(nothing)) == false
    facts_nml = FACTSControlDevice(nothing)
    set_control_mode!(facts_nml, FACTSOperationModes.NML)
    @test supports_reactive_power(facts_nml) == true
    facts_byp = FACTSControlDevice(nothing)
    set_control_mode!(facts_byp, FACTSOperationModes.BYP)
    @test supports_reactive_power(facts_byp) == true
    facts_oos = FACTSControlDevice(nothing)
    set_control_mode!(facts_oos, FACTSOperationModes.OOS)
    @test supports_reactive_power(facts_oos) == false

    # supports_voltage_control
    @test supports_voltage_control(ThermalStandard(nothing)) == true
    @test supports_voltage_control(ThermalMultiStart(nothing)) == true
    @test supports_voltage_control(RenewableDispatch(nothing)) == true
    @test supports_voltage_control(RenewableNonDispatch(nothing)) == true
    @test supports_voltage_control(HydroDispatch(nothing)) == true
    @test supports_voltage_control(Source(nothing)) == true
    @test supports_voltage_control(EnergyReservoirStorage(nothing)) == true
    @test supports_voltage_control(HybridSystem(nothing)) == true
    @test supports_voltage_control(PowerLoad(nothing)) == false
    @test supports_voltage_control(StandardLoad(nothing)) == false
    @test supports_voltage_control(ExponentialLoad(nothing)) == false
    @test supports_voltage_control(InterruptiblePowerLoad(nothing)) == false
    @test supports_voltage_control(ShiftablePowerLoad(nothing)) == false
    @test supports_voltage_control(InterconnectingConverter(nothing)) == false
    @test supports_voltage_control(FixedAdmittance(nothing)) == false
    @test supports_voltage_control(SwitchedAdmittance(nothing)) == false

    # FACTSControlDevice voltage control depends on control_mode
    @test supports_voltage_control(FACTSControlDevice(nothing)) == false
    @test supports_voltage_control(facts_nml) == true
    @test supports_voltage_control(facts_byp) == true
    @test supports_voltage_control(facts_oos) == false

    # SynchronousCondenser voltage control depends on bus type
    sc_pv = SynchronousCondenser(nothing)
    sc_pv.bus = ACBus(;
        number = 1, name = "pv_bus", available = true, bustype = ACBusTypes.PV,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 230.0,
    )
    @test supports_voltage_control(sc_pv) == true
    sc_ref = SynchronousCondenser(nothing)
    sc_ref.bus = ACBus(;
        number = 2, name = "ref_bus", available = true, bustype = ACBusTypes.REF,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 230.0,
    )
    @test supports_voltage_control(sc_ref) == true
    sc_pq = SynchronousCondenser(nothing)
    sc_pq.bus = ACBus(;
        number = 2, name = "pq_bus", available = true, bustype = ACBusTypes.PQ,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 230.0,
    )
    @test supports_voltage_control(sc_pq) == false
end

@testset "Test FACTS/SwitchedShunt interop fields (psy5 sync)" begin
    # FACTSControlDevice: new shunt-control fields ported from main
    fd = FACTSControlDevice(nothing)
    @test ustrip(get_max_reactive_power(fd, DU)) == 0.0  # demo constructor => 0.0
    @test get_shunt_control_type(fd) == FACTSShuntControlType.STATCOM
    @test get_regulated_bus_number(fd) == 0
    @test get_reactive_power_required(fd) == 0.0

    fd_kw = FACTSControlDevice(;
        name = "F1", available = true, bus = ACBus(nothing),
        control_mode = FACTSOperationModes.NML,
    )
    @test ustrip(get_max_reactive_power(fd_kw, DU)) == 9999.0  # kwarg default
    @test ustrip(get_max_shunt_current(fd_kw, DU)) == 9999.0
    @test get_voltage_setpoint(fd_kw) == 1.0
    @test get_shunt_control_type(fd_kw) == FACTSShuntControlType.STATCOM

    set_shunt_control_type!(fd_kw, FACTSShuntControlType.SVC)
    set_regulated_bus_number!(fd_kw, 42)
    set_max_reactive_power!(fd_kw, 150.0 * DU)
    @test get_shunt_control_type(fd_kw) == FACTSShuntControlType.SVC
    @test get_regulated_bus_number(fd_kw) == 42
    @test ustrip(get_max_reactive_power(fd_kw, DU)) == 150.0

    # Positional constructor now threads the reworked scalar fields
    fd_pos = FACTSControlDevice("F2", true, ACBus(nothing), FACTSOperationModes.NML, 1.05)
    @test get_voltage_setpoint(fd_pos) == 1.05
    @test ustrip(get_max_shunt_current(fd_pos, DU)) == 9999.0
    @test ustrip(get_max_reactive_power(fd_pos, DU)) == 9999.0

    # SwitchedAdmittance: new control_mode + regulated_bus_number
    sa = SwitchedAdmittance(nothing)
    @test get_control_mode(sa) == SwitchedAdmittanceControlMode.FIXED
    @test get_regulated_bus_number(sa) == 0

    sa_kw = SwitchedAdmittance(;
        name = "sa1", available = true, bus = ACBus(nothing), Y = 1.0 + 0.0im,
        control_mode = SwitchedAdmittanceControlMode.DISCRETE_VOLTAGE,
        regulated_bus_number = 7,
    )
    @test get_control_mode(sa_kw) == SwitchedAdmittanceControlMode.DISCRETE_VOLTAGE
    @test get_regulated_bus_number(sa_kw) == 7
    set_control_mode!(sa_kw, SwitchedAdmittanceControlMode.CONTINUOUS_VOLTAGE)
    @test get_control_mode(sa_kw) == SwitchedAdmittanceControlMode.CONTINUOUS_VOLTAGE

    # SwitchedAdmittance: number_engaged (PSS/E Si) and solved_admittance (PSS/E BINIT).
    # Both default to their unset values, and power flow writes back to each.
    @test get_number_engaged(sa) == Int[]
    @test isnothing(get_solved_admittance(sa))

    sa_solved = SwitchedAdmittance(;
        name = "sa2", available = true, bus = ACBus(nothing), Y = 1.0 + 0.0im,
        number_engaged = [2, 1],
        number_of_steps = [4, 3],
        Y_increase = [0.0 + 0.1im, 0.0 + 0.2im],
        solved_admittance = 0.35,
    )
    @test get_number_engaged(sa_solved) == [2, 1]
    @test get_solved_admittance(sa_solved) == 0.35
    # Both fields are written back by the power flow solve, so both stay settable.
    set_number_engaged!(sa_solved, [3, 0])
    @test get_number_engaged(sa_solved) == [3, 0]
    set_solved_admittance!(sa_solved, nothing)
    @test isnothing(get_solved_admittance(sa_solved))
end
