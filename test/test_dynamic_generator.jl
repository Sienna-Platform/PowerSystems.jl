nodes_OMIB = [
    ACBus(
        1, #number
        "Bus 1", #Name
        true, #available
        "REF", #BusType (REF, PV, PQ)
        0, #Angle in radians
        1.06, #Voltage in pu
        (min = 0.94, max = 1.06), #Voltage limits in pu
        69,
        nothing,
        nothing,
    ), #Base voltage in kV
    ACBus(2, "Bus 2", true, "PV", 0, 1.045, (min = 0.94, max = 1.06), 69, nothing, nothing),
]

static_gen = ThermalStandard(;
    name = "TestGen",
    available = true,
    status = true,
    bus = nodes_OMIB[2],
    active_power = 0.40,
    reactive_power = 0.010,
    rating = 0.5,
    prime_mover_type = PrimeMovers.ST,
    fuel = ThermalFuels.COAL,
    active_power_limits = (min = 0.0, max = 0.40),
    reactive_power_limits = (min = -0.30, max = 0.30),
    time_limits = nothing,
    ramp_limits = nothing,
    operation_cost = ThermalGenerationCost(
        CostCurve(LinearCurve(1400.0)),
        0.0,
        4.0,
        2.0,
    ),
    base_power = 1.0,
)

branch_OMIB = [
    Line(
        "Line1", #name
        true, #available
        0.0, #active power flow initial condition (from-to)
        0.0, #reactive power flow initial condition (from-to)
        Arc(; from = nodes_OMIB[1], to = nodes_OMIB[2]), #Connection between buses
        0.01, #resistance in pu
        0.05, #reactance in pu
        (from = 0.0, to = 0.0), #susceptance in pu
        1.14, #rate in MW
        1.04,
    ),
]  #angle limits (-min and max)

@testset "Dynamic Machines" begin
    Basic = BaseMachine(; R = 0.0, Xd_p = 0.2995, eq_p = 1.05)
    @test Basic isa PowerSystems.DynamicComponent

    GENROU = RoundRotorQuadratic(;
        R = 0.0,
        Td0_p = 7.4,
        Td0_pp = 0.03,
        Tq0_p = 0.06,
        Tq0_pp = 0.033,
        Xd = 0.8979,
        Xq = 0.646,
        Xd_p = 0.2995,
        Xq_p = 0.646,
        Xd_pp = 0.23,
        Xl = 0.1,
        Se = (0.1, 0.5),
    )
    @test GENROU isa PowerSystems.DynamicComponent

    GENROE = RoundRotorExponential(;
        R = 0.0,
        Td0_p = 7.4,
        Td0_pp = 0.03,
        Tq0_p = 0.06,
        Tq0_pp = 0.033,
        Xd = 0.8979,
        Xq = 0.646,
        Xd_p = 0.2995,
        Xq_p = 0.646,
        Xd_pp = 0.23,
        Xl = 0.1,
        Se = (0.1, 0.5),
    )
    @test GENROE isa PowerSystems.DynamicComponent

    GENSAL = SalientPoleQuadratic(;
        R = 0.0,
        Td0_p = 7.4,
        Td0_pp = 0.03,
        Tq0_pp = 0.033,
        Xd = 0.8979,
        Xq = 0.646,
        Xd_p = 0.2995,
        Xd_pp = 0.23,
        Xl = 0.1,
        Se = (0.1, 0.5),
    )
    @test GENSAL isa PowerSystems.DynamicComponent

    GENSAE = SalientPoleExponential(;
        R = 0.0,
        Td0_p = 7.4,
        Td0_pp = 0.03,
        Tq0_pp = 0.033,
        Xd = 0.8979,
        Xq = 0.646,
        Xd_p = 0.2995,
        Xd_pp = 0.23,
        Xl = 0.1,
        Se = (0.1, 0.5),
    )
    @test GENSAE isa PowerSystems.DynamicComponent

    oneDoneQ = OneDOneQMachine(;
        R = 0.0,
        Xd = 0.8979,
        Xq = 0.646,
        Xd_p = 0.2995,
        Xq_p = 0.04,
        Td0_p = 7.4,
        Tq0_p = 0.033,
    )
    @test oneDoneQ isa PowerSystems.DynamicComponent

    SauerPai = SauerPaiMachine(;
        R = 0.0,
        Xd = 0.920,
        Xq = 0.130,
        Xd_p = 0.300,
        Xq_p = 0.228,
        Xd_pp = 0.220,
        Xq_pp = 0.290,
        Xl = 0.1,
        Td0_p = 5.2,
        Tq0_p = 0.85,
        Td0_pp = 0.029,
        Tq0_pp = 0.034,
    )
    @test SauerPai isa PowerSystems.DynamicComponent

    AndersonFouad = AndersonFouadMachine(;
        R = 0.0,
        Xd = 0.8979,
        Xq = 0.646,
        Xd_p = 0.2995,
        Xq_p = 0.646,
        Xd_pp = 0.23,
        Xq_pp = 0.4,
        Td0_p = 7.4,
        Tq0_p = 0.01, #Data not available in Milano: Used 0.01
        Td0_pp = 0.03,
        Tq0_pp = 0.033,
    )
    @test AndersonFouad isa PowerSystems.DynamicComponent

    KundurMachine = SimpleFullMachine(;
        R = 0.003, #Example 3.1 and 4.1 of Kundur
        R_f = 0.0006,
        R_1d = 0.0284, #RD in Machowski
        R_1q = 0.0062, #RQ on Machowski
        L_d = 1.81,
        L_q = 1.76,
        L_ad = 1.66, #k*M_f or k*M_D in Machowski
        L_aq = 1.61, #k*M_Q in Machowski
        L_f1d = 1.66, #L_fD in Machowski. Assumed to be equal to L_ad
        L_ff = 1.825,
        L_1d = 0.1713, #L_D in Machowski
        L_1q = 0.7525, #L_Q in Machowski
    )
    @test KundurMachine isa PowerSystems.DynamicComponent

    KundurFullMachine = FullMachine(;
        R = 0.003, #Example 3.1 and 4.1 of Kundur
        R_f = 0.0006,
        R_1d = 0.0284, #RD in Machowski
        R_1q = 0.0062, #RQ on Machowski
        L_d = 1.81,
        L_q = 1.76,
        L_ad = 1.66, #k*M_f or k*M_D in Machowski
        L_aq = 1.61, #k*M_Q in Machowski
        L_f1d = 1.66, #L_fD in Machowski. Assumed to be equal to L_ad
        L_ff = 1.825,
        L_1d = 0.1713, #L_D in Machowski
        L_1q = 0.7525, #L_Q in Machowski
    )
    @test KundurFullMachine isa PowerSystems.DynamicComponent

    Mach2_benchmark = OneDOneQMachine(;
        R = 0.0,
        Xd = 1.3125,
        Xq = 1.2578,
        Xd_p = 0.1813,
        Xq_p = 0.25,
        Td0_p = 5.89,
        Tq0_p = 0.6,
    )
    @test Mach2_benchmark isa PowerSystems.DynamicComponent
end

################ Shaft Data #####################
@testset "Dynamic Shaft" begin
    BaseShaft = SingleMass(; H = 5.148, D = 2.0)
    @test BaseShaft isa PowerSystems.DynamicComponent

    FiveShaft = FiveMassShaft(;
        H = 5.148,
        H_hp = 0.3348,
        H_ip = 0.7306,
        H_lp = 0.8154,
        H_ex = 0.0452,
        D = 2.0,
        D_hp = 0.5180,
        D_ip = 0.2240,
        D_lp = 0.2240,
        D_ex = 0.1450,
        D_12 = 0.0518,
        D_23 = 0.0224,
        D_34 = 0.0224,
        D_45 = 0.0145,
        K_hp = 33.07,
        K_ip = 28.59,
        K_lp = 44.68,
        K_ex = 21.984,
    )
    @test FiveShaft isa PowerSystems.DynamicComponent
end

################# PSS Data #####################
@testset "Dynamic PSS" begin
    no_pss = PSSFixed(; V_pss = 0.0)
    @test no_pss isa PowerSystems.DynamicComponent
end
################ TG Data #####################
@testset "Dynamic Turbine Governor Constructors" begin
    fixed_tg = TGFixed(; efficiency = 1.0)
    @test fixed_tg isa PowerSystems.DynamicComponent

    typeI_tg = TGTypeI(;
        R = 0.02,
        Ts = 0.1,
        Tc = 0.45,
        T3 = 0.0,
        T4 = 0.0,
        T5 = 50.0,
        valve_position_limits = (min = 0.3, max = 1.2),
    )
    @test typeI_tg isa PowerSystems.DynamicComponent
    @test get_frequency_droop(typeI_tg) == 0.02

    typeII_tg = TGTypeII(; R = 0.05, T1 = 0.3, T2 = 0.1, τ_limits = (min = 0.1, max = 1.0))
    @test typeII_tg isa PowerSystems.DynamicComponent
    @test get_frequency_droop(typeII_tg) == 0.05

    gast_tg = GasTG(;
        R = 0.05,
        T1 = 0.40,
        T2 = 0.10,
        T3 = 2.0,
        AT = 1.0,
        Kt = 2.0,
        V_lim = (0.417, 0.8),
        D_turb = 0.0,
    )
    @test gast_tg isa PowerSystems.DynamicComponent
    @test get_frequency_droop(gast_tg) == 0.05

    degov_tg = PSY.DEGOV(;
        T1 = 0.0,
        T2 = 0.0,
        T3 = 0.0,
        K = 18.0,
        T4 = 12.0,
        T5 = 5.0,
        T6 = 0.2,
        Td = 0.0,
        P_ref = 0.0,
    )
    @test degov_tg isa PowerSystems.DynamicComponent
    @test get_frequency_droop(degov_tg) == (1/18.0)
end

################ AVR Data #####################
@testset "Dynamic AVR Constructors" begin
    proportional_avr = AVRSimple(; Kv = 5000.0)
    @test proportional_avr isa PowerSystems.DynamicComponent

    fixed_avr = AVRFixed(; Vf = 1.05, V_ref = 1.0)
    @test fixed_avr isa PowerSystems.DynamicComponent

    typeI_avr = AVRTypeI(;
        Ka = 200.0,
        Ke = 1.0,
        Kf = 0.0012,
        Ta = 0.02,
        Te = 0.19,
        Tf = 1.0,
        Tr = 0.001,
        Va_lim = (0.0, 0.0),
        Ae = 0.0006,
        Be = 0.9,
    )
    @test typeI_avr isa PowerSystems.DynamicComponent

    ac1a_avr = ESAC1A(;
        Tr = 0.0,
        Tb = 0.0,
        Tc = 0.0,
        Ka = 200,
        Ta = 0.5,
        Va_lim = (-7.0, 7.0),
        Te = 1.333,
        Kf = 0.02,
        Tf = 0.8,
        Kc = 0.0,
        Kd = 0.0,
        Ke = 1.0,
        E_sat = (0.0, 0.0),
        Se = (0.0, 0.0),
        Vr_lim = (-99.0, 99.0),
    )
    @test ac1a_avr isa PowerSystems.DynamicComponent

    mod_ac1a_avr = EXAC1(;
        Tr = 0.0,
        Tb = 0.0,
        Tc = 0.0,
        Ka = 400,
        Ta = 0.5,
        Vr_lim = (-5.2477, 5.2477),
        Te = 1.1,
        Kf = 0.035,
        Tf = 1.0,
        Kc = 0.2469,
        Kd = 0.5,
        Ke = 1.0,
        E_sat = (2.707, 3.6102),
        Se = (0.0366, 0.1831),
    )
    @test mod_ac1a_avr isa PowerSystems.DynamicComponent

    st1a_avr = ESST1A(;
        UEL_flags = 1,
        PSS_flags = 1,
        Tr = 0.0,
        Vi_lim = (-99.0, 99.0),
        Tc = 2.5,
        Tb = 13.25,
        Tc1 = 0.0,
        Tb1 = 0.0,
        Ka = 200.0,
        Ta = 0.1,
        Va_lim = (-9.5, 9.5),
        Vr_lim = (-9.5, 9.5),
        Kc = 0.0,
        Kf = 0.0,
        Tf = 1.0,
        K_lr = 0.0,
        I_lr = 999.0,
    )
    @test st1a_avr isa PowerSystems.DynamicComponent

    gen2_avr_benchmark = AVRTypeII(;
        K0 = 20.0,
        T1 = 0.2,
        T2 = 0.063,
        T3 = 0.35,
        T4 = 0.01,
        Te = 0.314,
        Tr = 0.001,
        Va_lim = (-5.0, 5.0),
        Ae = 0.0039,
        Be = 1.555,
    )
    @test gen2_avr_benchmark isa PowerSystems.DynamicComponent
end
######################### Generators ########################
@testset "Dynamic Generators" begin
    #Components for the test
    Basic = BaseMachine(; R = 0.0, Xd_p = 0.2995, eq_p = 1.05)

    BaseShaft = SingleMass(; H = 5.148, D = 2.0)

    fixed_avr = AVRFixed(; Vf = 1.05, V_ref = 1.0)

    proportional_avr = AVRSimple(; Kv = 5000.0)

    sexs_avr = SEXS(; Ta_Tb = 0.1, Tb = 10.0, K = 100.0, Te = 0.1, V_lim = (-4.0, 5.0))

    fixed_tg = TGFixed(; efficiency = 1.0)
    typeI_tg = TGTypeI(;
        R = 0.02,
        Ts = 0.1,
        Tc = 0.45,
        T3 = 0.0,
        T4 = 0.0,
        T5 = 50.0,
        valve_position_limits = (min = 0.3, max = 1.2),
    )
    no_pss = PSSFixed(; V_pss = 0.0)

    oneDoneQ = OneDOneQMachine(;
        R = 0.0,
        Xd = 0.8979,
        Xq = 0.646,
        Xd_p = 0.2995,
        Xq_p = 0.04,
        Td0_p = 7.4,
        Tq0_p = 0.033,
    )

    Gen1AVR = DynamicGenerator(;
        name = get_name(static_gen),
        ω_ref = 1.0,
        machine = Basic,
        shaft = BaseShaft,
        avr = proportional_avr,
        prime_mover = fixed_tg,
        pss = no_pss,
    )
    @test Gen1AVR isa PowerSystems.Component
    Gen1AVRnoAVR = DynamicGenerator(;
        name = get_name(static_gen),
        ω_ref = 1.0,
        machine = Basic,
        shaft = BaseShaft,
        avr = fixed_avr,
        prime_mover = fixed_tg,
        pss = no_pss,
    )
    @test Gen1AVRnoAVR isa PowerSystems.Component

    Gen2AVRnoAVR = DynamicGenerator(;
        name = get_name(static_gen),
        ω_ref = 1.0,
        machine = oneDoneQ,
        shaft = BaseShaft,
        avr = fixed_avr,
        prime_mover = fixed_tg,
        pss = no_pss,
    )
    @test Gen2AVRnoAVR isa PowerSystems.Component

    Gen2AVR = DynamicGenerator(;
        name = get_name(static_gen),
        ω_ref = 1.0,
        machine = oneDoneQ,
        shaft = BaseShaft,
        avr = proportional_avr,
        prime_mover = fixed_tg,
        pss = no_pss,
    )
    @test Gen2AVR isa PowerSystems.Component

    Gen3AVR = DynamicGenerator(;
        name = get_name(static_gen),
        ω_ref = 1.0,
        machine = oneDoneQ,
        shaft = BaseShaft,
        avr = sexs_avr,
        prime_mover = fixed_tg,
        pss = no_pss,
    )
    @test Gen3AVR isa PowerSystems.Component

    Gen4AVR = DynamicGenerator(;
        name = get_name(static_gen),
        ω_ref = 1.0,
        machine = oneDoneQ,
        shaft = BaseShaft,
        avr = sexs_avr,
        prime_mover = typeI_tg,
        pss = no_pss,
    )
    @test get_frequency_droop(Gen4AVR) == 0.02

    sys = System(100.0)
    for bus in nodes_OMIB
        add_component!(sys, bus)
    end
    for lines in branch_OMIB
        add_component!(sys, lines)
    end

    # Names must be the same.
    Gen1AVR.name = "bad_name"
    @test_throws ArgumentError add_component!(sys, Gen1AVR, static_gen)

    Gen1AVR.name = get_name(static_gen)
    # static_injector must be passed.
    @test_throws ArgumentError add_component!(sys, Gen1AVR)

    # static_injector must be attached to the system.
    @test_throws ArgumentError add_component!(sys, Gen1AVR, static_gen)

    add_component!(sys, static_gen)
    @test isnothing(get_dynamic_injector(static_gen))

    add_component!(sys, Gen1AVR, static_gen)
    dynamics = collect(get_components(DynamicGenerator, sys))
    @test length(dynamics) == 1
    @test dynamics[1] == Gen1AVR
    @test get_dynamic_injector(static_gen) == Gen1AVR
    @test get_base_power(static_gen) == get_base_power(Gen1AVR)
    @test PSY.compare_values(static_gen, deepcopy(static_gen))

    remove_component!(sys, Gen1AVR)
    @test isnothing(get_dynamic_injector(static_gen))
    add_component!(sys, Gen2AVR, static_gen)
    @test get_dynamic_injector(static_gen) === Gen2AVR
    @test get_base_power(static_gen) == get_base_power(Gen2AVR)

    set_base_power!(static_gen, 1234.5)
    @test PSY._get_base_power(static_gen) == 1234.5
    @test PSY._get_system_base_power(static_gen) == PSY._get_base_power(sys)

    # Rule: Can't set the pair injector if the current injector is already set.
    @test_throws ArgumentError set_dynamic_injector!(static_gen, Gen1AVR)

    # Rule: Can't remove a static injector if it is attached to a dynamic injector.
    @test_throws ArgumentError remove_component!(sys, static_gen)

    #Rule: Can't add saturation if Se(1.2) <= Se(1.0)
    @test_throws IS.ConflictingInputsError PSY.get_quadratic_saturation((0.5, 0.1))
    @test_throws IS.ConflictingInputsError PSY.get_quadratic_saturation((0.1, 0.1))
    @test_throws IS.ConflictingInputsError PSY.get_avr_saturation((0.2, 0.1), (0.1, 0.1))

    @test length(collect(get_dynamic_components(Gen2AVR))) == 5

    remove_component!(sys, Gen2AVR)
    @test isnothing(get_dynamic_injector(static_gen))
    add_component!(sys, Gen3AVR, static_gen)

    retrieved_gen = collect(get_components(DynamicGenerator, sys))
    orig_dir = pwd()
    temp_dir = mktempdir()
    cd(temp_dir)
    to_json(sys, "sys.json")
    sys2 = System("sys.json")
    serialized_gen = collect(get_components(DynamicGenerator, sys2))
    @test get_name(retrieved_gen[1]) == get_name(serialized_gen[1])
    cd(orig_dir)
end

@testset "Generic DER (DERD)" begin
    #valid (non-default) Qref_Flag
    derd = GenericDER(;
        name = "init",
        Qref_Flag = 2,
        PQ_Flag = 0,
        Gen_Flag = 0,
        PerOp_Flag = 0,
        Recon_Flag = 0,
        Trv = 0,
        VV_pnts = (V1 = 0.0, V2 = 0.0, V3 = 0.0, V4 = 0.0),
        Q_lim = (min = 0.0, max = 0.0),
        Tp = 0,
        e_lim = (min = 0.0, max = 0.0),
        Kpq = 0,
        Kiq = 0,
        Iqr_lim = (min = 0.0, max = 0.0),
        I_max = 0,
        Tg = 0,
        kWh_Cap = 0,
        SOC_ini = 0,
        SOC_lim = (min = 0.0, max = 0.0),
        Trf = 0,
        fdbd_pnts = (fdbd1 = 0.0, fdbd2 = 0.0),
        D_dn = 0,
        D_up = 0,
        fe_lim = (min = 0.0, max = 0.0),
        Kpp = 0,
        Kip = 0,
        P_lim = (min = 0.0, max = 0.0),
        dP_lim = (min = 0.0, max = 0.0),
        T_pord = 0,
        rrpwr = 0,
        VRT_pnts = (vrt1 = 0.0, vrt2 = 0.0, vrt3 = 0.0, vrt4 = 0.0, vrt5 = 0.0),
        TVRT_pnts = (tvrt1 = 0.0, tvrt2 = 0.0, tvrt3 = 0.0),
        tV_delay = 0,
        VES_lim = (min = 0.0, max = 0.0),
        FRT_pnts = (frt1 = 0.0, frt2 = 0.0, frt3 = 0.0, frt4 = 0.0),
        TFRT_pnts = (tfrt1 = 0.0, tfrt2 = 0.0),
        tF_delay = 0,
        FES_lim = (min = 0.0, max = 0.0),
        Pfa_ref = 0,
        Q_ref = 0,
        P_ref = 0,
        base_power = 0,
        ext = Dict{String, Any}(),
    )
    @test derd isa PowerSystems.Component

    #invalid Qref_Flag
    @test_throws ErrorException GenericDER(
        name = "init",
        Qref_Flag = 4,
        PQ_Flag = 0,
        Gen_Flag = 0,
        PerOp_Flag = 0,
        Recon_Flag = 0,
        Trv = 0,
        VV_pnts = (V1 = 0.0, V2 = 0.0, V3 = 0.0, V4 = 0.0),
        Q_lim = (min = 0.0, max = 0.0),
        Tp = 0,
        e_lim = (min = 0.0, max = 0.0),
        Kpq = 0,
        Kiq = 0,
        Iqr_lim = (min = 0.0, max = 0.0),
        I_max = 0,
        Tg = 0,
        kWh_Cap = 0,
        SOC_ini = 0,
        SOC_lim = (min = 0.0, max = 0.0),
        Trf = 0,
        fdbd_pnts = (fdbd1 = 0.0, fdbd2 = 0.0),
        D_dn = 0,
        D_up = 0,
        fe_lim = (min = 0.0, max = 0.0),
        Kpp = 0,
        Kip = 0,
        P_lim = (min = 0.0, max = 0.0),
        dP_lim = (min = 0.0, max = 0.0),
        T_pord = 0,
        rrpwr = 0,
        VRT_pnts = (vrt1 = 0.0, vrt2 = 0.0, vrt3 = 0.0, vrt4 = 0.0, vrt5 = 0.0),
        TVRT_pnts = (tvrt1 = 0.0, tvrt2 = 0.0, tvrt3 = 0.0),
        tV_delay = 0,
        VES_lim = (min = 0.0, max = 0.0),
        FRT_pnts = (frt1 = 0.0, frt2 = 0.0, frt3 = 0.0, frt4 = 0.0),
        TFRT_pnts = (tfrt1 = 0.0, tfrt2 = 0.0),
        tF_delay = 0,
        FES_lim = (min = 0.0, max = 0.0),
        Pfa_ref = 0,
        Q_ref = 0,
        P_ref = 0,
        base_power = 0,
        ext = Dict{String, Any}(),
    )

    sys = System(100.0)
    bus = ACBus(nothing)
    add_component!(sys, bus)
    static_injector = ThermalStandard(nothing)
    static_injector.bus = bus
    add_component!(sys, static_injector)
    add_component!(sys, derd, static_injector)
    DERDs = collect(get_components(GenericDER, sys))
    @test length(DERDs) == 1
end

@testset "Aggregate Distributed Generation" begin
    #valid (non-default) Freq_Flag
    dera = AggregateDistributedGenerationA(;
        name = "init",
        Pf_Flag = 0,
        Freq_Flag = 1,
        PQ_Flag = 0,
        Gen_Flag = 0,
        Vtrip_Flag = 0,
        Ftrip_Flag = 0,
        T_rv = 0,
        Trf = 0,
        dbd_pnts = (0.0, 0.0),
        K_qv = 0,
        Tp = 0,
        T_iq = 0,
        D_dn = 0,
        D_up = 0,
        fdbd_pnts = (0.0, 0.0),
        fe_lim = (min = 0.0, max = 0.0),
        P_lim = (min = 0.0, max = 0.0),
        dP_lim = (min = 0.0, max = 0.0),
        Tpord = 0,
        Kpg = 0,
        Kig = 0,
        I_max = 0,
        vl_pnts = [(0.0, 0.0), (0.0, 0.0)],
        vh_pnts = [(0.0, 0.0), (0.0, 0.0)],
        Vrfrac = 0,
        fl = 0,
        fh = 0,
        tfl = 0,
        tfh = 0,
        Tg = 0,
        rrpwr = 0,
        Tv = 0,
        Vpr = 0,
        Iq_lim = (min = 0.0, max = 0.0),
        V_ref = 0,
        Pfa_ref = 0,
        Q_ref = 0,
        P_ref = 0,
        base_power = 0,
        ext = Dict{String, Any}(),
    )
    @test dera isa PowerSystems.Component

    #invalid Freq_Flag
    @test_throws ErrorException AggregateDistributedGenerationA(
        name = "init",
        Pf_Flag = 0,
        Freq_Flag = 2,
        PQ_Flag = 0,
        Gen_Flag = 0,
        Vtrip_Flag = 0,
        Ftrip_Flag = 0,
        T_rv = 0,
        Trf = 0,
        dbd_pnts = (0.0, 0.0),
        K_qv = 0,
        Tp = 0,
        T_iq = 0,
        D_dn = 0,
        D_up = 0,
        fdbd_pnts = (0.0, 0.0),
        fe_lim = (min = 0.0, max = 0.0),
        P_lim = (min = 0.0, max = 0.0),
        dP_lim = (min = 0.0, max = 0.0),
        Tpord = 0,
        Kpg = 0,
        Kig = 0,
        I_max = 0,
        vl_pnts = [(0.0, 0.0), (0.0, 0.0)],
        vh_pnts = [(0.0, 0.0), (0.0, 0.0)],
        Vrfrac = 0,
        fl = 0,
        fh = 0,
        tfl = 0,
        tfh = 0,
        Tg = 0,
        rrpwr = 0,
        Tv = 0,
        Vpr = 0,
        Iq_lim = (min = 0.0, max = 0.0),
        V_ref = 0,
        Pfa_ref = 0,
        Q_ref = 0,
        P_ref = 0,
        base_power = 0,
        ext = Dict{String, Any}(),
    )

    sys = System(100.0)
    bus = ACBus(nothing)
    add_component!(sys, bus)
    static_injector = ThermalStandard(nothing)
    static_injector.bus = bus
    add_component!(sys, static_injector)
    add_component!(sys, dera, static_injector)
    DERAs = collect(get_components(AggregateDistributedGenerationA, sys))
    @test length(DERAs) == 1
end

@testset "Forward functions" begin
    GENROU = RoundRotorQuadratic(;
        R = 0.0,
        Td0_p = 7.4,
        Td0_pp = 0.03,
        Tq0_p = 0.06,
        Tq0_pp = 0.033,
        Xd = 0.8979,
        Xq = 0.646,
        Xd_p = 0.2995,
        Xq_p = 0.646,
        Xd_pp = 0.23,
        Xl = 0.1,
        Se = (0.1, 0.5),
    )
    test_accessors(GENROU)

    GENROE = RoundRotorExponential(;
        R = 0.0,
        Td0_p = 7.4,
        Td0_pp = 0.03,
        Tq0_p = 0.06,
        Tq0_pp = 0.033,
        Xd = 0.8979,
        Xq = 0.646,
        Xd_p = 0.2995,
        Xq_p = 0.646,
        Xd_pp = 0.23,
        Xl = 0.1,
        Se = (0.1, 0.5),
    )
    test_accessors(GENROE)

    GENSAL = SalientPoleQuadratic(;
        R = 0.0,
        Td0_p = 7.4,
        Td0_pp = 0.03,
        Tq0_pp = 0.033,
        Xd = 0.8979,
        Xq = 0.646,
        Xd_p = 0.2995,
        Xd_pp = 0.23,
        Xl = 0.1,
        Se = (0.1, 0.5),
    )
    test_accessors(GENSAL)

    GENSAE = SalientPoleExponential(;
        R = 0.0,
        Td0_p = 7.4,
        Td0_pp = 0.03,
        Tq0_pp = 0.033,
        Xd = 0.8979,
        Xq = 0.646,
        Xd_p = 0.2995,
        Xd_pp = 0.23,
        Xl = 0.1,
        Se = (0.1, 0.5),
    )
    test_accessors(GENSAE)

    #Test GENROU
    @test get_R(GENROU) == 0.0
    @test get_Td0_p(GENROU) == 7.4
    @test get_Td0_pp(GENROU) == 0.03
    @test get_Tq0_p(GENROU) == 0.06
    @test get_Tq0_pp(GENROU) == 0.033
    @test get_Xd(GENROU) == 0.8979
    @test get_Xq(GENROU) == 0.646
    @test get_Xd_p(GENROU) == 0.2995
    @test get_Xq_p(GENROU) == 0.646
    @test get_Xd_pp(GENROU) == 0.23
    @test get_Xl(GENROU) == 0.1
    @test get_Se(GENROU) == (0.1, 0.5)
    @test get_states(GENROU) == [:eq_p, :ed_p, :ψ_kd, :ψ_kq]
    @test get_n_states(GENROU) == 4
    @test get_saturation_coeffs(GENROU)[1] == 0.8620204102886728
    @test get_saturation_coeffs(GENROU)[2] == 5.252551286084109

    #Test GENROE
    @test get_R(GENROE) == 0.0
    @test get_Td0_p(GENROE) == 7.4
    @test get_Td0_pp(GENROE) == 0.03
    @test get_Tq0_p(GENROE) == 0.06
    @test get_Tq0_pp(GENROE) == 0.033
    @test get_Xd(GENROE) == 0.8979
    @test get_Xq(GENROE) == 0.646
    @test get_Xd_p(GENROE) == 0.2995
    @test get_Xq_p(GENROE) == 0.646
    @test get_Xd_pp(GENROE) == 0.23
    @test get_Xl(GENROE) == 0.1
    @test get_Se(GENROE) == (0.1, 0.5)
    @test get_states(GENROE) == [:eq_p, :ed_p, :ψ_kd, :ψ_kq]
    @test get_n_states(GENROE) == 4
    @test abs(get_saturation_coeffs(GENROE)[1] - 8.827469119589406) <= 1e-6
    @test abs(get_saturation_coeffs(GENROE)[2] - 0.1) <= 1e-6

    #Test GENSAL
    @test get_R(GENSAL) == 0.0
    @test get_Td0_p(GENSAL) == 7.4
    @test get_Td0_pp(GENSAL) == 0.03
    @test get_Tq0_pp(GENSAL) == 0.033
    @test get_Xd(GENSAL) == 0.8979
    @test get_Xq(GENSAL) == 0.646
    @test get_Xd_p(GENSAL) == 0.2995
    @test get_Xd_pp(GENSAL) == 0.23
    @test get_Xl(GENSAL) == 0.1
    @test get_Se(GENSAL) == (0.1, 0.5)
    @test get_states(GENSAL) == [:eq_p, :ψ_kd, :ψq_pp]
    @test get_n_states(GENSAL) == 3
    @test get_saturation_coeffs(GENSAL)[1] == 0.8620204102886728
    @test get_saturation_coeffs(GENSAL)[2] == 5.252551286084109

    #Test GENSAE
    @test get_R(GENSAE) == 0.0
    @test get_Td0_p(GENSAE) == 7.4
    @test get_Td0_pp(GENSAE) == 0.03
    @test get_Tq0_pp(GENSAE) == 0.033
    @test get_Xd(GENSAE) == 0.8979
    @test get_Xq(GENSAE) == 0.646
    @test get_Xd_p(GENSAE) == 0.2995
    @test get_Xd_pp(GENSAE) == 0.23
    @test get_Xl(GENSAE) == 0.1
    @test get_Se(GENSAE) == (0.1, 0.5)
    @test get_states(GENSAE) == [:eq_p, :ψ_kd, :ψq_pp]
    @test get_n_states(GENSAE) == 3
    @test abs(get_saturation_coeffs(GENSAE)[1] - 8.827469119589406) <= 1e-6
    @test abs(get_saturation_coeffs(GENSAE)[2] - 0.1) <= 1e-6
end
