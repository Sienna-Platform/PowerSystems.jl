
@testset "2-area, 11-bus, 4-generator benchmark system Parsing " begin
    test_dir = mktempdir()
    ger4_raw_file = joinpath(PSSE_RAW_DIR, "Benchmark_4ger_33_2015.RAW")
    ger4_dyr_file = joinpath(PSSE_DYR_DIR, "Benchmark_4ger_33_2015.dyr")
    sys = PSB.build_system(PSYTestSystems, "psse_Benchmark_4ger_33_2015_sys")
    @test_throws PSY.DataFormatError System(ger4_raw_file, ger4_raw_file)
    @test_throws PSY.DataFormatError System(ger4_dyr_file, ger4_raw_file)
    dyn_injectors = get_components(DynamicInjection, sys)
    @test length(dyn_injectors) == 4
    for g in dyn_injectors
        m = PSY.get_machine(g)
        @test typeof(m) <: RoundRotorExponential
    end
    path = joinpath(test_dir, "test_dyn_system_serialization.json")
    to_json(sys, path)
    parsed_sys = System(path)
    dyn_injectors = get_components(DynamicInjection, parsed_sys)
    @test length(dyn_injectors) == 4
    for g in dyn_injectors
        m = PSY.get_machine(g)
        @test typeof(m) <: RoundRotorExponential
    end
end

@testset "2-area, 11-bus, 4-generator with renewables benchmark system Parsing " begin
    test_dir = mktempdir()
    sys = PSB.build_system(PSYTestSystems, "psse_renewable_parsing_1")
    dyn_injectors = get_components(DynamicInjection, sys)
    @test length(dyn_injectors) == 5
    for g in dyn_injectors
        if isa(g, DynamicGenerator)
            m = PSY.get_machine(g)
            @test typeof(m) <: RoundRotorExponential
        elseif isa(g, DynamicInverter)
            ic = PSY.get_inner_control(g)
            @test typeof(ic) <: RECurrentControlB
        else
            @error("Generator $g not supported")
        end
    end
    path = joinpath(test_dir, "test_dyn_system_serialization.json")
    to_json(sys, path)
    parsed_sys = System(path)
    dyn_injectors = get_components(DynamicInjection, parsed_sys)
    @test length(dyn_injectors) == 5
    for g in dyn_injectors
        if isa(g, DynamicGenerator)
            m = PSY.get_machine(g)
            @test typeof(m) <: RoundRotorExponential
        elseif isa(g, DynamicInverter)
            ic = PSY.get_inner_control(g)
            @test typeof(ic) <: RECurrentControlB
        else
            @error("Generator $g not supported")
        end
    end
end

@testset "240 Bus WECC system Parsing " begin
    test_dir = mktempdir()
    sys = PSB.build_system(PSYTestSystems, "psse_240_parsing_sys"; force_build = true)
    dyn_injectors = get_components(DynamicInjection, sys)
    @test length(dyn_injectors) == 146
    for g in dyn_injectors
        if isa(g, DynamicGenerator)
            m = PSY.get_machine(g)
            @test typeof(m) <: RoundRotorQuadratic
        elseif isa(g, DynamicInverter)
            ic = PSY.get_inner_control(g)
            @test typeof(ic) <: RECurrentControlB
        else
            @error("Generator $g not supported")
        end
    end
    path = joinpath(test_dir, "test_dyn_system_serialization.json")
    to_json(sys, path)
    parsed_sys = System(path)
    dyn_injectors = get_components(DynamicInjection, parsed_sys)
    @test length(dyn_injectors) == 146
    for g in dyn_injectors
        if isa(g, DynamicGenerator)
            m = PSY.get_machine(g)
            @test typeof(m) <: RoundRotorQuadratic
        elseif isa(g, DynamicInverter)
            ic = PSY.get_inner_control(g)
            @test typeof(ic) <: RECurrentControlB
        else
            @error("Generator $g not supported")
        end
    end
    all_gens = collect(get_components(ThermalStandard, sys))
    sort!(all_gens, by = get_name)
    static_injector = first(all_gens)
    @test get_frequency_droop(static_injector) ==
          static_injector.dynamic_injector.prime_mover.R
end

@testset "GENCLS dyr parsing" begin
    threebus_raw_file = joinpath(PSSE_TEST_DIR, "ThreeBusNetwork.raw")
    gencls_dyr_file = joinpath(PSSE_TEST_DIR, "TestGENCLS.dyr")
    nogencls_dyr_file = joinpath(PSSE_TEST_DIR, "Test-NoCLS.dyr")
    sexs_dyr_file = joinpath(PSSE_TEST_DIR, "Test_SEXS.dyr")
    sys_gencls = PSB.build_system(PSYTestSystems, "psse_3bus_gen_cls_sys"; force_build = true)
    sys_nogencls = PSB.build_system(PSYTestSystems, "psse_3bus_no_cls_sys"; force_build = true)
    sys_sexs = PSB.build_system(PSYTestSystems, "psse_3bus_SEXS_sys"; force_build = true)

    #Check that generator at bus 102 (H = 0) is a Source, and not ThermalStandard.
    @test isnothing(get_component(ThermalStandard, sys_gencls, "generator-102-1"))
    @test typeof(get_component(StaticInjection, sys_gencls, "generator-102-1")) <: Source
    #Check that generator at bus 102 (not provided in dyr data) is a Source.
    @test isnothing(get_component(ThermalStandard, sys_nogencls, "generator-102-1"))
    @test typeof(get_component(StaticInjection, sys_nogencls, "generator-102-1")) <: Source

    #Check Parameters of GENROE raw file
    genroe_gen = get_component(DynamicInjection, sys_gencls, "generator-101-1")
    m = PSY.get_machine(genroe_gen)
    s = PSY.get_shaft(genroe_gen)
    @test typeof(m) <: RoundRotorExponential

    @test get_R(m) == 0.0
    @test get_Td0_p(m) == 8.0
    @test get_Td0_pp(m) == 0.03
    @test get_Tq0_p(m) == 0.4
    @test get_Tq0_pp(m) == 0.05
    @test get_Xd(m) == 1.8
    @test get_Xq(m) == 1.7
    @test get_Xd_p(m) == 0.3
    @test get_Xd_pp(m) == 0.25
    @test get_Xl(m) == 0.2
    @test get_H(s) == 6.5
    @test get_D(s) == 0.0

    #Check Parameters of other GENCLS file
    gencls_gen = get_component(DynamicInjection, sys_gencls, "generator-103-1")
    m = PSY.get_machine(gencls_gen)
    s = PSY.get_shaft(gencls_gen)
    @test typeof(m) <: BaseMachine

    @test get_R(m) == 0.0
    @test get_Xd_p(m) == 0.2
    @test get_H(s) == 3.1
    @test get_D(s) == 2.0

    #Check Parameters of other GENCLS file
    gencls_gen = get_component(DynamicInjection, sys_nogencls, "generator-103-1")
    m = PSY.get_machine(gencls_gen)
    s = PSY.get_shaft(gencls_gen)
    @test typeof(m) <: BaseMachine

    @test get_R(m) == 0.0
    @test get_Xd_p(m) == 0.2
    @test get_H(s) == 3.1
    @test get_D(s) == 2.0

    #Check Parameters of SEXS file
    genroe_sexs = get_component(DynamicInjection, sys_sexs, "generator-101-1")
    a = PSY.get_avr(genroe_sexs)
    @test typeof(a) <: AVR
    @test get_Ta_Tb(a) == 0.4
    @test get_Tb(a) == 5.0
    @test get_K(a) == 20.0
    @test get_Te(a) == 1.0
    E_min, E_max = get_V_lim(a)
    @test E_min == -50.0
    @test E_max == 50.0
end

@testset "2000-Bus Parsing" begin
    test_dir = mktempdir()
    sys = build_system(PSSEParsingTestSystems, "psse_ACTIVSg2000_sys"; force_build = true)
    for g in get_components(ThermalStandard, sys)
        if isnothing(get_dynamic_injector(g))
            @error "ThermalStandard $(get_name(g)) should have a dynamic injector"
        end
        @test !isnothing(get_dynamic_injector(g))
    end
    for g in get_components(SynchronousCondenser, sys)
        if isnothing(get_dynamic_injector(g))
            @error "SynchronousCondenser $(get_name(g)) should have a dynamic injector"
        end
        @test !isnothing(get_dynamic_injector(g))
    end
    path = joinpath(test_dir, "test_dyn_system_serialization_2000.json")
    to_json(sys, path)
    parsed_sys = System(path)
    dyn_injectors = get_components(DynamicInjection, parsed_sys)
    @test length(dyn_injectors) == 435
    for g in get_components(ThermalStandard, parsed_sys)
        @test !isnothing(get_dynamic_injector(g))
    end
end
