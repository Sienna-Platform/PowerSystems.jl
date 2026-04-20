function create_system_with_test_subsystems()
    sys = PSB.build_system(
        PSITestSystems,
        "c_sys5_uc";
        add_forecasts = false,
        time_series_read_only = false,
    )

    components = collect(get_components(ThermalStandard, sys))
    @test length(components) >= 5

    subsystems = String[]
    for i in 1:3
        name = "subsystem_$i"
        add_subsystem!(sys, name)
        push!(subsystems, name)
    end

    add_component_to_subsystem!(sys, subsystems[1], components[1])
    add_component_to_subsystem!(sys, subsystems[1], components[2])
    add_component_to_subsystem!(sys, subsystems[2], components[2])
    add_component_to_subsystem!(sys, subsystems[2], components[3])
    add_component_to_subsystem!(sys, subsystems[3], components[3])
    add_component_to_subsystem!(sys, subsystems[3], components[4])
    return (sys, components)
end

function create_system_with_2_test_subsystems()
    c_sys5 = PSB.build_system(PSISystems, "2Area 5 Bus System")

    components = collect(get_components(Component, c_sys5))
    #@test length(components) == 52

    subsystems = String[]
    for i in 1:2
        name = "subsystem_$i"
        add_subsystem!(c_sys5, name)
        push!(subsystems, name)
    end

    #name of components solely belonging to subsystem 2 ends with 2
    suffix = "2"

    for component in get_components(Component, c_sys5)
        if (endswith(get_name(component), suffix))
            add_component_to_subsystem!(c_sys5, subsystems[2], component)
        else
            add_component_to_subsystem!(c_sys5, subsystems[1], component)
        end
    end

    #components connecting the subsystems are shared
    add_component_to_subsystem!(
        c_sys5,
        subsystems[1],
        get_component(TwoTerminalGenericHVDCLine, c_sys5, "nodeC-nodeC2"),
    )
    add_component_to_subsystem!(
        c_sys5,
        subsystems[1],
        get_component(Arc, c_sys5, "nodeC -> nodeC2"),
    )
    add_component_to_subsystem!(
        c_sys5,
        subsystems[1],
        get_component(ACBus, c_sys5, "nodeC2"),
    )
    add_component_to_subsystem!(
        c_sys5,
        subsystems[2],
        get_component(ACBus, c_sys5, "nodeC"),
    )
    PSY.check(c_sys5)
    PSY.check_components(c_sys5)
    return (c_sys5, components)
end

@testset "Test get subsystems and components" begin
    sys, components = create_system_with_test_subsystems()
    @test sort!(collect(get_subsystems(sys))) ==
          ["subsystem_1", "subsystem_2", "subsystem_3"]
    @test has_component(sys, "subsystem_1", components[1])
    @test has_component(sys, "subsystem_1", components[2])
    @test has_component(sys, "subsystem_2", components[2])
    @test has_component(sys, "subsystem_2", components[3])
    @test has_component(sys, "subsystem_3", components[3])
    @test has_component(sys, "subsystem_3", components[4])
    @test !has_component(sys, "subsystem_3", components[5])
    @test sort!(get_name.(get_subsystem_components(sys, "subsystem_2"))) ==
          sort!([get_name(components[2]), get_name(components[3])])
    @test get_assigned_subsystems(sys, components[1]) == ["subsystem_1"]
    @test is_assigned_to_subsystem(sys, components[1])
    @test !is_assigned_to_subsystem(sys, components[5])
    @test is_assigned_to_subsystem(sys, components[1], "subsystem_1")
    @test !is_assigned_to_subsystem(sys, components[5], "subsystem_1")
    @test_throws ArgumentError add_subsystem!(sys, "subsystem_1")
end

@testset "Test get_components" begin
    sys, components = create_system_with_test_subsystems()
    @test length(
        get_components(ThermalStandard, sys; subsystem_name = "subsystem_1"),
    ) == 2
    name = get_name(components[1])
    @test collect(
        get_components(
            x -> x.name == name,
            ThermalStandard,
            sys;
            subsystem_name = "subsystem_1",
        ),
    )[1].name == name
end

@testset "Test subsystem after remove_component" begin
    sys, components = create_system_with_test_subsystems()
    remove_component!(sys, components[3])
    @test !has_component(sys, "subsystem_2", components[3])
    @test !has_component(sys, "subsystem_3", components[3])
    @test has_component(sys, "subsystem_2", components[2])
    @test has_component(sys, "subsystem_3", components[4])
end

@testset "Test removal of subsystem" begin
    sys, components = create_system_with_test_subsystems()
    remove_subsystem!(sys, "subsystem_2")
    @test sort!(collect(get_subsystems(sys))) == ["subsystem_1", "subsystem_3"]
    @test get_assigned_subsystems(sys, components[2]) == ["subsystem_1"]
    @test_throws ArgumentError remove_subsystem!(sys, "subsystem_2")
end

@testset "Test removal of subsystem component" begin
    sys, components = create_system_with_test_subsystems()
    remove_component_from_subsystem!(sys, "subsystem_2", components[2])
    @test get_name.(get_subsystem_components(sys, "subsystem_2")) ==
          [get_name(components[3])]
    @test_throws ArgumentError remove_component_from_subsystem!(
        sys,
        "subsystem_2",
        components[2],
    )
end

@testset "Test addition of component to invalid subsystem" begin
    sys, components = create_system_with_test_subsystems()
    @test_throws ArgumentError add_component_to_subsystem!(sys, "invalid", components[1])
end

@testset "Test addition of duplicate component to subsystem" begin
    sys, components = create_system_with_test_subsystems()
    @test_throws ArgumentError add_component_to_subsystem!(
        sys,
        "subsystem_1",
        components[1],
    )
end

@testset "Test addition of non-system component" begin
    sys, components = create_system_with_test_subsystems()
    remove_component!(sys, components[1])
    @test_throws ArgumentError add_component_to_subsystem!(
        sys,
        "subsystem_1",
        components[1],
    )
end

@testset "Test invalid subsystem count" begin
    sys = PSB.build_system(
        PSITestSystems,
        "c_sys5_uc";
        add_forecasts = false,
        time_series_read_only = true,
    )
    num_buses = length(get_components(Bus, sys))
    for i in 1:num_buses
        add_subsystem!(sys, "subsystem_$i")
    end
    @test_throws "cannot exceed the number of buses" add_subsystem!(sys, "subsystem")
end

@testset "Test valid subsystem" begin
    sys = create_system_with_subsystems()
    check_components(sys)
end

@testset "Test inconsistent component-subsystem membership" begin
    sys, components = create_system_with_test_subsystems()
    @test_throws IS.InvalidValue check_components(sys)
end

@testset "Test mismatch component-topological membership" begin
    sys = create_system_with_subsystems()
    add_subsystem!(sys, "incomplete_subsystem")
    gen = first(get_components(ThermalStandard, sys))
    bus = get_bus(gen)
    remove_component_from_subsystem!(sys, "subsystem_1", bus)
    add_component_to_subsystem!(sys, "incomplete_subsystem", bus)
    @test_throws IS.InvalidValue PSY._check_topological_consistency(sys, gen)
end

@testset "Test mismatch branch-arc membership" begin
    sys = create_system_with_subsystems()
    add_subsystem!(sys, "incomplete_subsystem")
    branch = first(get_components(Branch, sys))
    arc = get_arc(branch)
    remove_component_from_subsystem!(sys, "subsystem_1", arc)
    add_component_to_subsystem!(sys, "incomplete_subsystem", arc)
    @test_throws IS.InvalidValue PSY._check_branch_consistency(sys, branch)
end

@testset "Test service-contributing-device consistency" begin
    sys = create_system_with_subsystems()
    add_subsystem!(sys, "incomplete_subsystem")
    device = nothing
    service = nothing
    for dev in get_components(Device, sys)
        if !PSY.supports_services(dev)
            continue
        end
        services = get_services(dev)
        if !isempty(services)
            device = dev
            service = first(services)
            break
        end
    end
    @test !isnothing(device) && !isnothing(service)

    remove_component_from_subsystem!(sys, "subsystem_1", device)
    add_subsystem!(sys, "subsystem_2")
    add_component_to_subsystem!(sys, "subsystem_2", device)

    @test_throws IS.InvalidValue PSY._check_device_service_consistency(sys, device)
end

@testset "Test subsystems with HybridSystem" begin
    sys = PSB.build_system(PSB.PSITestSystems, "test_RTS_GMLC_sys_with_hybrid")
    h_sys = first(get_components(HybridSystem, sys))
    subcomponents = collect(get_subcomponents(h_sys))

    subsystem_name = "subsystem_1"
    add_subsystem!(sys, subsystem_name)
    add_component_to_subsystem!(sys, subsystem_name, h_sys)
    # Ensure that subcomponents get added automatically.
    for subcomponent in subcomponents
        @test is_assigned_to_subsystem(sys, subcomponent, subsystem_name)
    end

    remove_component_from_subsystem!(sys, subsystem_name, subcomponents[1])
    @test_throws IS.InvalidValue PSY._check_subcomponent_consistency(sys, h_sys)

    add_component_to_subsystem!(sys, subsystem_name, subcomponents[1])
    remove_component_from_subsystem!(sys, subsystem_name, h_sys)
    # Ensure that subcomponents get removed automatically.
    for subcomponent in subcomponents
        @test !is_assigned_to_subsystem(sys, subcomponent, subsystem_name)
    end
end

@testset "Test get subsystems and components for c_sys5" begin
    bus_c = ACBus(
        3,
        "nodeC",
        true,
        "PV",
        0,
        1.0,
        (min = 0.9, max = 1.05),
        230,
        nothing,
        nothing,
    )
    bus_d = ACBus(
        4,
        "nodeD",
        true,
        "REF",
        0,
        1.0,
        (min = 0.9, max = 1.05),
        230,
        nothing,
        nothing,
    )
    bus_d2 =
        ACBus(
            9,
            "nodeD2",
            true,
            "REF",
            0,
            1.0,
            (min = 0.9, max = 1.05),
            230,
            nothing,
            nothing,
        )

    d_d2 = Line(
        "nodeD-nodeD2",
        true,
        0.0,
        0.0,
        Arc(; from = bus_d, to = bus_d2),
        0.00108,
        0.0108,
        (from = 0.00926, to = 0.00926),
        11.1480,
        (min = -0.7, max = 0.7),
    )

    c_d2 = Line(
        "nodeC-nodeD2",
        true,
        0.0,
        0.0,
        Arc(; from = bus_c, to = bus_d2),
        0.00297,
        0.0297,
        (from = 0.00337, to = 0.00337),
        40.530,
        (min = -0.7, max = 0.7),
    )

    c_sys5, components = create_system_with_2_test_subsystems()
    @test sort!(collect(get_subsystems(c_sys5))) ==
          ["subsystem_1", "subsystem_2"]

    @test has_component(c_sys5, "subsystem_1", get_component(Arc, c_sys5, "nodeA -> nodeB"))
    @test has_component(c_sys5, "subsystem_1", get_component(Arc, c_sys5, "nodeA -> nodeD"))
    @test has_component(c_sys5, "subsystem_1", get_component(Arc, c_sys5, "nodeA -> nodeE"))
    @test has_component(c_sys5, "subsystem_1", get_component(Arc, c_sys5, "nodeB -> nodeC"))
    @test has_component(c_sys5, "subsystem_1", get_component(Arc, c_sys5, "nodeC -> nodeD"))
    @test has_component(c_sys5, "subsystem_1", get_component(Arc, c_sys5, "nodeD -> nodeE"))
    @test has_component(
        c_sys5,
        "subsystem_1",
        get_component(Arc, c_sys5, "nodeC -> nodeC2"),
    )

    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(Arc, c_sys5, "nodeA2 -> nodeB2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(Arc, c_sys5, "nodeA2 -> nodeD2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(Arc, c_sys5, "nodeA2 -> nodeE2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(Arc, c_sys5, "nodeB2 -> nodeC2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(Arc, c_sys5, "nodeC2 -> nodeD2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(Arc, c_sys5, "nodeD2 -> nodeE2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(Arc, c_sys5, "nodeC -> nodeC2"),
    )

    @test has_component(
        c_sys5,
        "subsystem_1",
        get_component(ThermalStandard, c_sys5, "Solitude"),
    )
    @test has_component(
        c_sys5,
        "subsystem_1",
        get_component(ThermalStandard, c_sys5, "Park City"),
    )
    @test has_component(
        c_sys5,
        "subsystem_1",
        get_component(ThermalStandard, c_sys5, "Alta"),
    )
    @test has_component(
        c_sys5,
        "subsystem_1",
        get_component(ThermalStandard, c_sys5, "Brighton"),
    )
    @test has_component(
        c_sys5,
        "subsystem_1",
        get_component(ThermalStandard, c_sys5, "Sundance"),
    )

    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(ThermalStandard, c_sys5, "Park City-2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(ThermalStandard, c_sys5, "Solitude-2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(ThermalStandard, c_sys5, "Alta-2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(ThermalStandard, c_sys5, "Sundance-2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(ThermalStandard, c_sys5, "Brighton-2"),
    )

    @test has_component(
        c_sys5,
        "subsystem_1",
        get_component(PowerLoad, c_sys5, "Load-nodeB"),
    )
    @test has_component(
        c_sys5,
        "subsystem_1",
        get_component(PowerLoad, c_sys5, "Load-nodeC"),
    )
    @test has_component(
        c_sys5,
        "subsystem_1",
        get_component(PowerLoad, c_sys5, "Load-nodeD"),
    )

    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(PowerLoad, c_sys5, "Load-nodeB2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(PowerLoad, c_sys5, "Load-nodeC2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(PowerLoad, c_sys5, "Load-nodeD2"),
    )

    @test has_component(c_sys5, "subsystem_1", get_component(Line, c_sys5, "nodeA-nodeB"))
    @test has_component(c_sys5, "subsystem_1", get_component(Line, c_sys5, "nodeA-nodeD"))
    @test has_component(c_sys5, "subsystem_1", get_component(Line, c_sys5, "nodeA-nodeE"))
    @test has_component(c_sys5, "subsystem_1", get_component(Line, c_sys5, "nodeB-nodeC"))
    @test has_component(c_sys5, "subsystem_1", get_component(Line, c_sys5, "nodeC-nodeD"))
    @test has_component(c_sys5, "subsystem_1", get_component(Line, c_sys5, "nodeD-nodeE"))

    @test has_component(c_sys5, "subsystem_2", get_component(Line, c_sys5, "nodeA2-nodeB2"))
    @test has_component(c_sys5, "subsystem_2", get_component(Line, c_sys5, "nodeA2-nodeD2"))
    @test has_component(c_sys5, "subsystem_2", get_component(Line, c_sys5, "nodeA2-nodeE2"))
    @test has_component(c_sys5, "subsystem_2", get_component(Line, c_sys5, "nodeB2-nodeC2"))
    @test has_component(c_sys5, "subsystem_2", get_component(Line, c_sys5, "nodeC2-nodeD2"))
    @test has_component(c_sys5, "subsystem_2", get_component(Line, c_sys5, "nodeD2-nodeE2"))

    @test has_component(c_sys5, "subsystem_1", get_component(ACBus, c_sys5, "nodeA"))
    @test has_component(c_sys5, "subsystem_1", get_component(ACBus, c_sys5, "nodeB"))
    @test has_component(c_sys5, "subsystem_1", get_component(ACBus, c_sys5, "nodeC"))
    @test has_component(c_sys5, "subsystem_1", get_component(ACBus, c_sys5, "nodeD"))
    @test has_component(c_sys5, "subsystem_1", get_component(ACBus, c_sys5, "nodeE"))
    @test has_component(c_sys5, "subsystem_1", get_component(ACBus, c_sys5, "nodeC2"))

    @test has_component(c_sys5, "subsystem_2", get_component(ACBus, c_sys5, "nodeA2"))
    @test has_component(c_sys5, "subsystem_2", get_component(ACBus, c_sys5, "nodeB2"))
    @test has_component(c_sys5, "subsystem_2", get_component(ACBus, c_sys5, "nodeC2"))
    @test has_component(c_sys5, "subsystem_2", get_component(ACBus, c_sys5, "nodeD2"))
    @test has_component(c_sys5, "subsystem_2", get_component(ACBus, c_sys5, "nodeE2"))
    @test has_component(c_sys5, "subsystem_2", get_component(ACBus, c_sys5, "nodeC"))

    @test has_component(
        c_sys5,
        "subsystem_1",
        get_component(TwoTerminalGenericHVDCLine, c_sys5, "nodeC-nodeC2"),
    )
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(TwoTerminalGenericHVDCLine, c_sys5, "nodeC-nodeC2"),
    )

    @test sort!(get_name.(get_subsystem_components(c_sys5, "subsystem_1"))) ==
          sort!([
        get_name(get_component(Arc, c_sys5, "nodeA -> nodeB")),
        get_name(get_component(Arc, c_sys5, "nodeA -> nodeD")),
        get_name(get_component(Arc, c_sys5, "nodeA -> nodeE")),
        get_name(get_component(Arc, c_sys5, "nodeB -> nodeC")),
        get_name(get_component(Arc, c_sys5, "nodeC -> nodeD")),
        get_name(get_component(Arc, c_sys5, "nodeD -> nodeE")),
        get_name(get_component(Arc, c_sys5, "nodeC -> nodeC2")),
        get_name(get_component(ThermalStandard, c_sys5, "Solitude")),
        get_name(get_component(ThermalStandard, c_sys5, "Park City")),
        get_name(get_component(ThermalStandard, c_sys5, "Alta")),
        get_name(get_component(ThermalStandard, c_sys5, "Brighton")),
        get_name(get_component(ThermalStandard, c_sys5, "Sundance")),
        get_name(get_component(PowerLoad, c_sys5, "Load-nodeB")),
        get_name(get_component(PowerLoad, c_sys5, "Load-nodeC")),
        get_name(get_component(PowerLoad, c_sys5, "Load-nodeD")),
        get_name(get_component(Line, c_sys5, "nodeA-nodeB")),
        get_name(get_component(Line, c_sys5, "nodeA-nodeD")),
        get_name(get_component(Line, c_sys5, "nodeA-nodeE")),
        get_name(get_component(Line, c_sys5, "nodeB-nodeC")),
        get_name(get_component(Line, c_sys5, "nodeC-nodeD")),
        get_name(get_component(Line, c_sys5, "nodeD-nodeE")),
        get_name(get_component(ACBus, c_sys5, "nodeA")),
        get_name(get_component(ACBus, c_sys5, "nodeB")),
        get_name(get_component(ACBus, c_sys5, "nodeC")),
        get_name(get_component(ACBus, c_sys5, "nodeD")),
        get_name(get_component(ACBus, c_sys5, "nodeE")),
        get_name(get_component(ACBus, c_sys5, "nodeC2")),
        get_name(get_component(TwoTerminalGenericHVDCLine, c_sys5, "nodeC-nodeC2")),
    ])

    @test get_assigned_subsystems(c_sys5, get_component(ACBus, c_sys5, "nodeD")) ==
          ["subsystem_1"]
    @test get_assigned_subsystems(c_sys5, get_component(ACBus, c_sys5, "nodeD2")) ==
          ["subsystem_2"]
    @test sort!(get_assigned_subsystems(c_sys5, get_component(ACBus, c_sys5, "nodeC2"))) ==
          ["subsystem_1", "subsystem_2"]
    @test sort!(get_assigned_subsystems(c_sys5, get_component(ACBus, c_sys5, "nodeC"))) ==
          ["subsystem_1", "subsystem_2"]
    @test is_assigned_to_subsystem(c_sys5, get_component(ACBus, c_sys5, "nodeC"))
    @test !is_assigned_to_subsystem(c_sys5, d_d2)
    @test !is_assigned_to_subsystem(c_sys5, c_d2)
    @test is_assigned_to_subsystem(
        c_sys5,
        get_component(ACBus, c_sys5, "nodeC"),
        "subsystem_1",
    )
    @test is_assigned_to_subsystem(
        c_sys5,
        get_component(ACBus, c_sys5, "nodeC"),
        "subsystem_2",
    )
    @test is_assigned_to_subsystem(
        c_sys5,
        get_component(ACBus, c_sys5, "nodeD"),
        "subsystem_1",
    )
    @test is_assigned_to_subsystem(
        c_sys5,
        get_component(ACBus, c_sys5, "nodeD2"),
        "subsystem_2",
    )
    @test !is_assigned_to_subsystem(
        c_sys5,
        get_component(ACBus, c_sys5, "nodeD2"),
        "subsystem_1",
    )
    @test_throws ArgumentError add_subsystem!(c_sys5, "subsystem_1")
end

@testset "Test get_components for c_sys5" begin
    c_sys5, components = create_system_with_2_test_subsystems()
    @test length(
        get_components(ThermalStandard, c_sys5; subsystem_name = "subsystem_1"),
    ) == 5
    name = get_name(get_component(PowerLoad, c_sys5, "Load-nodeB2"))
    @test collect(
        get_components(
            x -> x.name == name,
            PowerLoad,
            c_sys5;
            subsystem_name = "subsystem_2",
        ),
    )[1].name == name
end

@testset "Test c_sys5 subsystem after remove_component" begin
    c_sys5, components = create_system_with_2_test_subsystems()
    comp = get_component(Arc, c_sys5, "nodeB -> nodeC")
    remove_component!(c_sys5, comp)
    @test !has_component(c_sys5, "subsystem_1", comp)
    @test !has_component(c_sys5, "subsystem_2", comp)
    @test has_component(c_sys5, "subsystem_1", get_component(Arc, c_sys5, "nodeA -> nodeB"))
    @test has_component(
        c_sys5,
        "subsystem_2",
        get_component(Arc, c_sys5, "nodeA2 -> nodeB2"),
    )
end

@testset "Test removal of subsystem from c_sys5" begin
    c_sys5, components = create_system_with_2_test_subsystems()
    remove_subsystem!(c_sys5, "subsystem_2")
    @test sort!(collect(get_subsystems(c_sys5))) == ["subsystem_1"]
    @test get_assigned_subsystems(c_sys5, get_component(Arc, c_sys5, "nodeA -> nodeB")) ==
          ["subsystem_1"]
    @test_throws ArgumentError remove_subsystem!(c_sys5, "subsystem_2")
end

@testset "Test removal of subsystem component" begin
    c_sys5, components = create_system_with_2_test_subsystems()
    comp = get_component(Arc, c_sys5, "nodeA -> nodeB")
    remove_component_from_subsystem!(c_sys5, "subsystem_1", comp)
    @test sort!(get_name.(get_subsystem_components(c_sys5, "subsystem_1"))) ==
          sort!([
        get_name(get_component(Arc, c_sys5, "nodeA -> nodeD")),
        get_name(get_component(Arc, c_sys5, "nodeA -> nodeE")),
        get_name(get_component(Arc, c_sys5, "nodeB -> nodeC")),
        get_name(get_component(Arc, c_sys5, "nodeC -> nodeD")),
        get_name(get_component(Arc, c_sys5, "nodeD -> nodeE")),
        get_name(get_component(Arc, c_sys5, "nodeC -> nodeC2")),
        get_name(get_component(ThermalStandard, c_sys5, "Solitude")),
        get_name(get_component(ThermalStandard, c_sys5, "Park City")),
        get_name(get_component(ThermalStandard, c_sys5, "Alta")),
        get_name(get_component(ThermalStandard, c_sys5, "Brighton")),
        get_name(get_component(ThermalStandard, c_sys5, "Sundance")),
        get_name(get_component(PowerLoad, c_sys5, "Load-nodeB")),
        get_name(get_component(PowerLoad, c_sys5, "Load-nodeC")),
        get_name(get_component(PowerLoad, c_sys5, "Load-nodeD")),
        get_name(get_component(Line, c_sys5, "nodeA-nodeB")),
        get_name(get_component(Line, c_sys5, "nodeA-nodeD")),
        get_name(get_component(Line, c_sys5, "nodeA-nodeE")),
        get_name(get_component(Line, c_sys5, "nodeB-nodeC")),
        get_name(get_component(Line, c_sys5, "nodeC-nodeD")),
        get_name(get_component(Line, c_sys5, "nodeD-nodeE")),
        get_name(get_component(ACBus, c_sys5, "nodeA")),
        get_name(get_component(ACBus, c_sys5, "nodeB")),
        get_name(get_component(ACBus, c_sys5, "nodeC")),
        get_name(get_component(ACBus, c_sys5, "nodeD")),
        get_name(get_component(ACBus, c_sys5, "nodeE")),
        get_name(get_component(ACBus, c_sys5, "nodeC2")),
        get_name(get_component(TwoTerminalGenericHVDCLine, c_sys5, "nodeC-nodeC2")),
    ])
    @test_throws ArgumentError remove_component_from_subsystem!(
        c_sys5,
        "subsystem_1",
        comp,
    )
end

@testset "Test addition of component to invalid subsystem for c_sys5" begin
    c_sys5, components = create_system_with_2_test_subsystems()
    @test_throws ArgumentError add_component_to_subsystem!(c_sys5, "invalid", components[1])
end

@testset "Test addition of duplicate component to subsystem for c_sys5" begin
    c_sys5, components = create_system_with_2_test_subsystems()
    @test_throws ArgumentError add_component_to_subsystem!(
        c_sys5,
        "subsystem_1",
        get_component(ACBus, c_sys5, "nodeD"),
    )
end

@testset "Test addition of non-system component to c_sys5" begin
    c_sys5, components = create_system_with_2_test_subsystems()
    comp = get_component(ACBus, c_sys5, "nodeD")
    remove_component!(c_sys5, comp)
    @test_throws ArgumentError add_component_to_subsystem!(
        c_sys5,
        "subsystem_1",
        comp,
    )
end

@testset "Test invalid subsystem count" begin
    c_sys5, components = create_system_with_2_test_subsystems()
    num_buses = length(get_components(Bus, c_sys5))
    for i in 3:num_buses
        add_subsystem!(c_sys5, "subsystem_$i")
    end
    @test_throws "cannot exceed the number of buses" add_subsystem!(
        c_sys5,
        "subsystem134523",
    )
end

@testset "Test service-contributing-device consistency for c_sys5" begin
    c_sys5, components = create_system_with_2_test_subsystems()
    device = nothing
    service = nothing
    for dev in get_components(Device, c_sys5; subsystem_name = "subsystem_1")
        res = VariableReserve{ReserveUp}("REG1", true, 5.0, 0.1)
        add_service!(c_sys5, res, dev)
        services = get_services(dev)
        if !isempty(services)
            device = dev
            service = first(services)
            break
        end
    end
    @test !isnothing(device) && !isnothing(service)

    remove_component_from_subsystem!(c_sys5, "subsystem_1", device)
    add_subsystem!(c_sys5, "incomplete_subsystem")
    add_component_to_subsystem!(c_sys5, "incomplete_subsystem", device)

    @test_throws IS.InvalidValue PSY._check_device_service_consistency(c_sys5, device)
end

@testset "Test construct system from subsystem" begin
    base_sys = create_system_with_2_test_subsystems()[1]
    ts_counts = get_time_series_counts(base_sys)
    @test ts_counts.components_with_time_series == 6
    @test ts_counts.forecast_count == 6
    subsystem1_uuids = get_component_uuids(base_sys, "subsystem_1")
    subsystem2_uuids = get_component_uuids(base_sys, "subsystem_2")

    sys1 = from_subsystem(base_sys, "subsystem_1")
    sys2 = from_subsystem(base_sys, "subsystem_2")

    base_sys_components = get_components(Component, base_sys)

    sys1_components = get_components(Component, sys1)
    sys2_components = get_components(Component, sys2)
    @test length(sys1_components) < length(base_sys_components)
    @test length(sys2_components) < length(base_sys_components)

    for (components, uuids) in
        ((sys1_components, subsystem1_uuids), (sys2_components, subsystem2_uuids))
        for component in components
            base_component = get_component(typeof(component), base_sys, get_name(component))
            @test IS.get_uuid(base_component) in uuids
        end
    end

    for sys in (sys1, sys2)
        ts_counts = get_time_series_counts(sys)
        @test ts_counts.components_with_time_series == 3
        @test ts_counts.forecast_count == 3
    end
end
