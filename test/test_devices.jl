@testset "Test special accessors" begin
    cdmsys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    th = first(get_components(ThermalStandard, cdmsys))
    re = first(get_components(RenewableDispatch, cdmsys))

    @test get_max_active_power(th) == get_active_power_limits(th).max
    @test get_max_active_power(re) <= get_rating(re)
    @test isa(get_max_reactive_power(re), Float64)

    @test_throws MethodError get_max_active_power(TestDevice("foo"))
    @test_throws ArgumentError get_max_active_power(TestInjector("foo"))
    @test_throws ArgumentError get_max_active_power(TestRenDevice("foo"))
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
    dir_path = mktempdir()
    to_json(sys, joinpath(dir_path, "test_RTS_GMLC_sys.json"))
    sys2 = System(joinpath(dir_path, "test_RTS_GMLC_sys.json"))
    @test get_active_power(get_component(ShiftablePowerLoad, sys2, "ShiftableLoadBus4")) ==
          0.10
    @test get_active_power(get_component(InterruptiblePowerLoad, sys2, "IloadBus")) == 0.10
    @test get_active_power_limits(
        get_component(ShiftablePowerLoad, sys2, "ShiftableLoadBus4"),
    ).min == 0.03
    @test get_active_power_limits(
        get_component(ShiftablePowerLoad, sys2, "ShiftableLoadBus4"),
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
    @test supports_active_power(FixedAdmittance(nothing)) == false
    @test supports_active_power(SwitchedAdmittance(nothing)) == false

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
    @test supports_reactive_power(FixedAdmittance(nothing)) == false
    @test supports_reactive_power(SwitchedAdmittance(nothing)) == true

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
