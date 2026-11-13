@testset "Inverter Components" begin
    converter = AverageConverter(690.0, 2750000.0) #S_rated goes in Watts
    dc_source = FixedDCSource(600.0) #Not in the original data, guessed.
    filter = LCLFilter(0.08, 0.003, 0.074, 0.2, 0.01)
    pll = KauraPLL(500.0, 0.084, 4.69)
    reduced_pll = ReducedOrderPLL(500.0, 0.084, 4.69)
    virtual_H = VirtualInertia(2.0, 400.0, 20.0, 2 * pi * 50.0)
    P_control = ActivePowerDroop(0.2, 1000.0)
    P_control_PI = ActivePowerPI(2.0, 20.0, 50.0)
    P_VOC = ActiveVirtualOscillator(0.0033, pi / 4)
    Q_control = ReactivePowerDroop(0.2, 1000.0)
    Q_control_PI = ReactivePowerPI(2.0, 20.0, 50.0)
    Q_VOC = ReactiveVirtualOscillator(0.0796)
    for block in (
        virtual_H,
        P_control,
        P_control_PI,
        P_VOC,
        Q_control,
        Q_control_PI,
        Q_VOC,
    )
        test_accessors(block)
    end
    vsc = VoltageModeControl(0.59, 736.0, 0.0, 0.0, 0.2, 1.27, 14.3, 0.0, 50.0, 0.2)
    vsc3 = CurrentModeControl(1.27, 14.3, 0.0)
    BESS_source = ZeroOrderBESS(
        (sqrt(8) / sqrt(3)) * 690.0,
        (sqrt(3) / sqrt(8)) * 2750000.0,
        370.0,
        0.001,
        4.63,
        3200.0,
        0.6,
        4.0,
        0.39,
        10.34,
        1.08,
    )
end

@testset "Dynamic Inverter" begin
    sys = PSB.build_system(PSB.PSYTestSystems, "dynamic_inverter_sys")
    inverters = collect(get_components(DynamicInverter, sys))
    @test length(inverters) == 1
    test_inverter = inverters[1]
    test_accessors(test_inverter)
end

@testset "Dynamic Inverter Limiters" begin
    converter = AverageConverter(690.0, 2750000.0) #S_rated goes in Watts
    dc_source = FixedDCSource(600.0) #Not in the original data, guessed.
    filt = LCLFilter(0.08, 0.003, 0.074, 0.2, 0.01)
    pll = KauraPLL(500.0, 0.084, 4.69)
    virtual_H = VirtualInertia(2.0, 400.0, 20.0, 2 * pi * 50.0)
    Q_control = ReactivePowerDroop(0.2, 1000.0)
    vsc = VoltageModeControl(0.59, 736.0, 0.0, 0.0, 0.2, 1.27, 14.3, 0.0, 50.0, 0.2)
    inverter = DynamicInverter(
        "TestInverter",
        60.0,
        converter,
        virtual_H,
        Q_control,
        vsc,
        dc_source,
        pll,
        filt,
    )
    test_accessors(inverter)
    inv_magnitude = DynamicInverter(;
        name = "TestInverter",
        frequency_ref = 60.0,
        converter = converter,
        active_power_control = virtual_H,
        reactive_power_control = Q_control,
        inner_control = vsc,
        dc_source = dc_source,
        reference_frame_rotation = pll,
        filter = filt,
        current_limitation = MagnitudeOutputCurrentLimiter(; I_max = 1.0),
    )
    test_accessors(inv_magnitude)
    inv_inst = DynamicInverter(;
        name = "TestInverter",
        frequency_ref = 60.0,
        converter = converter,
        active_power_control = virtual_H,
        reactive_power_control = Q_control,
        inner_control = vsc,
        dc_source = dc_source,
        reference_frame_rotation = pll,
        filter = filt,
        current_limitation = InstantaneousOutputCurrentLimiter(;
            Id_max = 1.0 / sqrt(2),
            Iq_max = 1.0 / sqrt(2),
        ),
    )
    test_accessors(inv_inst)
    inv_priority = DynamicInverter(;
        name = "TestInverter",
        frequency_ref = 60.0,
        converter = converter,
        active_power_control = virtual_H,
        reactive_power_control = Q_control,
        inner_control = vsc,
        dc_source = dc_source,
        reference_frame_rotation = pll,
        filter = filt,
        current_limitation = PriorityOutputCurrentLimiter(; I_max = 1.0, phi_I = 0.1),
    )
    test_accessors(inv_priority)
end

@testset "Generic Renewable Models" begin
    converter_regca1 = RenewableEnergyConverterTypeA(;
        T_g = 0.02,
        Rrpwr = 10.0,
        Brkpt = 0.9,
        Zerox = 0.4,
        Lvpl1 = 1.22,
        Vo_lim = 1.2,
        Lv_pnts = (0.5, 0.9),
        Io_lim = -1.3,
        T_fltr = 0.2,
        K_hv = 0.0,
        Iqr_lims = (-100.0, 100.0),
        Accel = 0.7,
        Lvpl_sw = 0,
    )
    filt_current = RLFilter(; rf = 0.0, lf = 0.1)
    inner_ctrl_typeB = RECurrentControlB(;
        Q_Flag = false,
        PQ_Flag = false,
        Vdip_lim = (-99.0, 99.0),
        T_rv = 0.02,
        dbd_pnts = (-1.0, 1.0),
        K_qv = 0.0,
        Iqinj_lim = (-1.1, 1.1),
        V_ref0 = 0.0,
        K_vp = 10.0,
        K_vi = 60.0,
        T_iq = 0.02,
        I_max = 1.11,
    )
    # Creates 2^5 = 32 combinations of flags for an outer control
    for (F_flag, VC_flag, R_flag, PF_flag, V_flag) in
        reverse.(Iterators.product(fill((false, true), 5)...))[:]
        P_control_typeAB = ActiveRenewableControllerAB(;
            bus_control = 0,
            from_branch_control = 0,
            to_branch_control = 0,
            branch_id_control = 0,
            Freq_Flag = F_flag,
            K_pg = 1.0,
            K_ig = 0.05,
            T_p = 0.25,
            fdbd_pnts = (-1.0, 1.0),
            fe_lim = (-99.0, 99.0),
            P_lim = (0.0, 1.2),
            T_g = 0.1,
            D_dn = 0.0,
            D_up = 0.0,
            dP_lim = (-99.0, 99.0),
            P_lim_inner = (0.0, 1.2),
            T_pord = 0.02,
        )
        Q_control_typeAB = ReactiveRenewableControllerAB(;
            bus_control = 0,
            from_branch_control = 0,
            to_branch_control = 0,
            branch_id_control = "0",
            VC_Flag = VC_flag,
            Ref_Flag = R_flag,
            PF_Flag = PF_flag,
            V_Flag = V_flag,
            T_fltr = 0.02,
            K_p = 18.0,
            K_i = 5.0,
            T_ft = 0.0,
            T_fv = 0.05,
            V_frz = 0.0,
            R_c = 0.0,
            X_c = 0.0,
            K_c = 0.0,
            e_lim = (-0.1, 0.1),
            dbd_pnts = (-1.0, 1.0),
            Q_lim = (-0.43, 0.43),
            T_p = 0.0,
            Q_lim_inner = (-0.44, 0.44),
            V_lim = (0.9, 1.05),
            K_qp = 0.0,
            K_qi = 0.01,
        )
        test_accessors(P_control_typeAB)
        test_accessors(Q_control_typeAB)
    end
end
