@testset "Test add/remove services" begin
    @testset "Case: $direction" for direction in [ReserveDown; ReserveUp; ReserveSymmetric]
        sys = System(100.0)
        devices = []
        for i in 1:2
            bus = ACBus(nothing)
            bus.name = "bus" * string(i)
            bus.number = i
            add_component!(sys, bus)
            gen = ThermalStandard(nothing)
            gen.bus = bus
            gen.name = "gen" * string(i)
            add_component!(sys, gen)
            push!(devices, gen)
        end

        service = OnlineReserve{direction}(nothing)
        add_service!(sys, service, devices)

        for device in devices
            services = get_services(device)
            @test length(services) == 1
            @test services[1] == service
        end

        services = collect(get_components(Service, sys))
        @test length(services) == 1
        @test services[1] == service

        remove_component!(sys, service)

        for device in devices
            @test length(get_services(device)) == 0
        end

        sys = System(100.0)
        devices = []
        for i in 1:2
            bus = ACBus(nothing)
            bus.name = "bus" * string(i)
            bus.number = i
            add_component!(sys, bus)
            gen = ThermalStandard(nothing)
            gen.bus = bus
            gen.name = "gen" * string(i)
            add_component!(sys, gen)
            push!(devices, gen)
        end

        service = OnlineReserve{direction}(nothing)
        add_component!(sys, service)
        test_device = get_component(ThermalStandard, sys, "gen1")
        add_service!(test_device, service, sys)
        @test PowerSystems.has_service(test_device, service)
    end
end

@testset "Test add_component Service" begin
    sys = System(100.0)
    static_reserve = OnlineReserve{ReserveDown}(nothing)
    add_component!(sys, static_reserve)
    services = get_components(OnlineReserve{ReserveDown}, sys)
    @test length(services) == 1
    @test iterate(services)[1] == static_reserve
end

@testset "Test add_service errors" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    service = OnlineReserve{ReserveDown}(nothing)
    # Bus is not a Device.
    @test_throws ArgumentError add_service!(sys, service, [bus])

    gen = ThermalStandard(nothing)
    # gen is not in sys.
    @test_throws ArgumentError add_service!(sys, service, [bus])
end

@testset "Test remove service from device" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.bus = bus
    gen.name = "gen"
    add_component!(sys, gen)

    service = OnlineReserve{ReserveDown}(nothing)
    add_service!(sys, service, [gen])
    @test length(get_services(gen)) == 1

    remove_service!(gen, service)
    @test length(get_services(gen)) == 0
end

@testset "Test has service" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.bus = bus
    gen.name = "gen"
    add_component!(sys, gen)

    service = OnlineReserve{ReserveDown}(nothing)
    add_service!(sys, service, [gen])
    @test has_service(gen, service)
    @test has_service(gen, typeof(service))

    remove_service!(gen, service)
    @test !has_service(gen, service)
    @test !has_service(gen, typeof(service))
end

@testset "Test remove device with service" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.bus = bus
    gen.name = "gen"
    add_component!(sys, gen)

    service = OnlineReserve{ReserveDown}(nothing)
    add_service!(sys, service, [gen])
    @test length(get_services(gen)) == 1

    remove_component!(sys, gen)
    @test length(get_services(gen)) == 0
end

@testset "Test clear_services" begin
    gen = ThermalStandard(nothing)
    service = OnlineReserve{ReserveDown}(nothing)
    PSY.add_service_internal!(gen, service)
    @test length(get_services(gen)) == 1

    remove_service!(gen, service)
    @test length(get_services(gen)) == 0
end

@testset "Test add device with service" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    add_component!(sys, bus)

    gen = ThermalStandard(nothing)
    gen.bus = bus
    gen.name = "gen"

    service = OnlineReserve{ReserveDown}(nothing)
    PSY.add_service_internal!(gen, service)
    @test length(get_services(gen)) == 1

    @test_throws ArgumentError add_component!(sys, gen)
end

@testset "Test get_contributing_devices" begin
    sys = System(100.0)
    devices = []
    services = []
    for i in 1:5
        bus = ACBus(nothing)
        bus.name = "bus" * string(i)
        bus.number = i
        add_component!(sys, bus)
        gen = ThermalStandard(nothing)
        gen.bus = bus
        gen.name = "gen" * string(i)
        add_component!(sys, gen)
        push!(devices, gen)

        service = OnlineReserve{ReserveUp}(nothing)
        service.name = "OnlineReserve" * string(i)
        push!(services, service)
        add_component!(sys, service)
    end

    PSY.add_service_internal!(devices[1], services[1])
    PSY.add_service_internal!(devices[2], services[1])
    PSY.add_service_internal!(devices[3], services[2])
    PSY.add_service_internal!(devices[4], services[2])
    PSY.add_service_internal!(devices[5], services[2])

    expected_contributing_devices1 = [devices[1], devices[2]]
    expected_contributing_devices2 = [devices[3], devices[4], devices[5]]

    contributing_devices1 = get_contributing_devices(sys, services[1])
    contributing_devices2 = get_contributing_devices(sys, services[2])

    # Order of contributing_devices isn't guaranteed, sort them to test.
    sort!(contributing_devices1; by = x -> get_name(x))
    sort!(contributing_devices2; by = x -> get_name(x))
    @test contributing_devices1 == expected_contributing_devices1
    @test contributing_devices2 == expected_contributing_devices2

    mapping = get_contributing_device_mapping(sys)
    @test length(mapping) == length(services)
    key1 =
        ServiceContributingDevicesKey((typeof(services[1]), get_name(services[1])))
    key2 =
        ServiceContributingDevicesKey((typeof(services[2]), get_name(services[2])))
    key3 =
        ServiceContributingDevicesKey((typeof(services[3]), get_name(services[3])))
    @test haskey(mapping, key1)
    @test haskey(mapping, key2)
    @test haskey(mapping, key3)
    @test length(mapping[key1].contributing_devices) == 2
    @test length(mapping[key2].contributing_devices) == 3
    @test length(mapping[key3].contributing_devices) == 0

    sort!(mapping[key1].contributing_devices; by = x -> get_name(x))
    sort!(mapping[key2].contributing_devices; by = x -> get_name(x))
    @test mapping[key1].contributing_devices == expected_contributing_devices1
    @test mapping[key2].contributing_devices == expected_contributing_devices2
end

@testset "Test get_component combinations" begin
    sys = System(100.0)
    reserves = (
        OnlineReserve{ReserveUp}(nothing),
        OnlineReserve{ReserveDown}(nothing),
        OfflineReserve(nothing),
        GroupReserve{ReserveUp}(nothing),
    )

    for reserve in reserves
        add_component!(sys, reserve)
    end

    @test length(get_components(Service, sys)) == length(reserves)
    # The whole reserve tree, groups included.
    @test length(get_components(AbstractReserve, sys)) == length(reserves)
    # Direction-parameterized spinning products only.
    @test length(get_components(Reserve, sys)) == 2
    @test length(get_components(OnlineReserve, sys)) == 2
    @test length(get_components(OnlineReserve{ReserveUp}, sys)) == 1
    @test length(get_components(OnlineReserve{ReserveDown}, sys)) == 1
    @test length(get_components(OfflineReserve, sys)) == 1
    @test length(get_components(GroupReserve{ReserveUp}, sys)) == 1
end

@testset "Test struct type collections" begin
    # Lock the reserve tree's shape: membership assertions instead of a count so a
    # failure names the type that moved.
    @test Set(IS.get_all_concrete_subtypes(Service)) == Set([AGC, TransmissionInterface])
    @test Set(InteractiveUtils.subtypes(AbstractReserve)) ==
          Set([Reserve, OfflineReserve, GroupReserve])
    @test InteractiveUtils.subtypes(Reserve) == [OnlineReserve]
    @test Set(InteractiveUtils.subtypes(ReserveDirection)) ==
          Set([ReserveUp, ReserveDown, ReserveSymmetric])
end

@testset "Test GroupReserve" begin
    # create system
    sys = System(100.0)
    # add buses and generators
    devices = []
    for i in 1:2
        bus = ACBus(nothing)
        bus.name = "bus" * string(i)
        bus.number = i
        add_component!(sys, bus)
        gen = ThermalStandard(nothing)
        gen.bus = bus
        gen.name = "gen" * string(i)
        add_component!(sys, gen)
        push!(devices, gen)
    end

    # add OnlineReserve
    service = OnlineReserve{ReserveDown}(nothing)
    add_service!(sys, service, devices)

    # add OnlineReserve
    groupservice = GroupReserve{ReserveDown}(nothing)
    add_service!(sys, groupservice)

    # add GroupReserve
    groupservices = collect(get_components(GroupReserve, sys))
    # test if GroupReserve was added
    @test length(groupservices) == 1
    @test groupservices[1] == groupservice

    # add contributing services
    expected_contributing_services = Vector{Service}()
    push!(expected_contributing_services, service)
    set_contributing_services!(sys, groupservice, expected_contributing_services)
    # get contributing services
    contributing_services = get_contributing_services(groupservice)

    # check if expected contributing services is iqual to contributing services
    sort!(contributing_services; by = x -> get_name(x))
    @test contributing_services == expected_contributing_services
end

@testset "Test GroupReserve JSON round trip resolves member UUIDs" begin
    # GroupReserve references its contributing services by UUID, so deserialization must
    # order it after every other service despite it being an AbstractReserve.
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.bus = bus
    gen.name = "gen1"
    add_component!(sys, gen)

    sub_a = OnlineReserve{ReserveUp}(;
        name = "SUB_A", available = true, time_frame = 10.0, requirement = 0.0)
    sub_b = OnlineReserve{ReserveUp}(;
        name = "SUB_B", available = true, time_frame = 10.0, requirement = 0.0)
    add_service!(sys, sub_a, [gen])
    add_service!(sys, sub_b, [gen])
    group = GroupReserve{ReserveUp}(;
        name = "GROUP", available = true, requirement = 1.0,
        contributing_services = Service[sub_a, sub_b])
    add_service!(sys, group)

    sys2 = roundtrip_system(sys)
    group2 = get_component(GroupReserve{ReserveUp}, sys2, "GROUP")
    @test !isnothing(group2)
    @test sort!(get_name.(get_contributing_services(group2))) == ["SUB_A", "SUB_B"]
end

@testset "Test GroupReserve errors" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    groupservice = GroupReserve{ReserveDown}(nothing)

    # Bus is not a Service.
    @test_throws MethodError set_contributing_services!(sys, groupservice, [bus])

    # Service not in System
    service = OnlineReserve{ReserveDown}(nothing)
    contributing_services = Vector{Service}()
    push!(contributing_services, service)
    @test_throws ArgumentError add_service!(sys, groupservice, contributing_services)

    # Service in a GroupReserve
    devices = []
    for i in 1:2
        bus = ACBus(nothing)
        bus.name = "bus" * string(i)
        bus.number = i
        add_component!(sys, bus)
        gen = ThermalStandard(nothing)
        gen.bus = bus
        gen.name = "gen" * string(i)
        add_component!(sys, gen)
        push!(devices, gen)
    end
    add_service!(sys, service, devices)
    add_service!(sys, groupservice, contributing_services)
    @test_throws ArgumentError remove_component!(sys, service)
end

@testset "Test OfflineReserve" begin
    # create system
    sys = System(100.0)
    # add buses and generators
    devices = []
    for i in 1:2
        bus = ACBus(nothing)
        bus.name = "bus" * string(i)
        bus.number = i
        add_component!(sys, bus)
        gen = ThermalStandard(nothing)
        gen.bus = bus
        gen.name = "gen" * string(i)
        add_component!(sys, gen)
        push!(devices, gen)
    end

    # add OnlineReserve
    service = OfflineReserve(nothing)
    add_service!(sys, service, devices)

    for device in devices
        services = get_services(device)
        @test length(services) == 1
        @test services[1] == service
    end

    services = collect(get_components(Service, sys))
    @test length(services) == 1
    @test services[1] == service

    remove_component!(sys, service)

    for device in devices
        @test length(get_services(device)) == 0
    end
end

@testset "Test Service Removal" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    res_up = PSY.get_component(PSY.OnlineReserve{PSY.ReserveUp}, sys, "Flex_Up")
    res_dn = PSY.get_component(PSY.OnlineReserve{PSY.ReserveDown}, sys, "Flex_Down")
    PSY.remove_component!(sys, res_dn)
    PSY.remove_component!(sys, res_up)
    @test isnothing(PSY.get_component(PSY.OnlineReserve{PSY.ReserveUp}, sys, "Flex_Up"))
    @test isnothing(
        PSY.get_component(PSY.OnlineReserve{PSY.ReserveDown}, sys, "Flex_Down"),
    )
end

@testset "Test TransmissionInterface" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    lines = get_components(Line, sys)
    xfr = get_components(TwoWindingTransformer, sys)
    hvdc = collect(get_components(TwoTerminalGenericHVDCLine, sys))
    some_lines = collect(lines)[1:2]
    other_lines_and_hvdc = vcat(collect(lines)[10:14], hvdc)
    lines_and_transformers = [some_lines; collect(xfr)[1:2]]

    interface1 = TransmissionInterface("foo1", true, (min = -10.0, max = 10.0))
    interface2 = TransmissionInterface("foo2", true, (min = -10.0, max = 10.0))
    interface3 = TransmissionInterface("foo3", true, (min = -10.0, max = 10.0))
    add_service!(sys, interface1, some_lines)
    add_service!(sys, interface2, other_lines_and_hvdc)
    add_service!(sys, interface3, lines_and_transformers)
    for br in get_contributing_devices(sys, interface1)
        @test br ∈ some_lines
    end
    for br in get_contributing_devices(sys, interface2)
        @test br ∈ other_lines_and_hvdc
    end
    for br in get_contributing_devices(sys, interface3)
        @test br ∈ lines_and_transformers
    end
    @test length(get_components(TransmissionInterface, sys)) == 3

    # Round-trip: `TransmissionInterface` is now in `DOCUMENT_PLAN`. Compare by name —
    # a document build mints fresh UUIDs, so identity/`∈` checks against the pre-round-trip
    # objects would not apply.
    sys2 = roundtrip_system(sys)
    @test length(get_components(TransmissionInterface, sys2)) == 3
    for (name, expected_names) in (
        ("foo1", Set(get_name.(some_lines))),
        ("foo2", Set(get_name.(other_lines_and_hvdc))),
        ("foo3", Set(get_name.(lines_and_transformers))),
    )
        iface2 = get_component(TransmissionInterface, sys2, name)
        @test Set(get_name.(get_contributing_devices(sys2, iface2))) == expected_names
    end

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
    line = first(get_components(Line, sys))
    add_component!(sys, area_interchange12)
    add_component!(sys, area_interchange13)
    area_level_interface = TransmissionInterface("foo3", true, (min = -10.0, max = 10.0))
    area_level_mixed = TransmissionInterface("foo4", true, (min = -10.0, max = 10.0))
    add_service!(sys, area_level_interface, [area_interchange12, area_interchange13])
    @test_throws ArgumentError add_service!(
        sys,
        area_level_mixed,
        [area_interchange12, area_interchange13, line],
    )

    # `AreaInterchange` is in `DOCUMENT_PLAN`, so an area-level interface and its
    # contributing interchanges survive a document round trip. Compare by name: a document
    # build mints fresh UUIDs.
    sys3 = roundtrip_system(sys)
    iface3 = get_component(TransmissionInterface, sys3, "foo3")
    @test Set(get_name.(get_contributing_devices(sys3, iface3))) ==
          Set(get_name.([area_interchange12, area_interchange13]))
end

@testset "Test AGC" begin
    sys = PSB.build_system(PSITestSystems, "c_sys5_uc"; add_reserves = true)
    thermals = get_components(ThermalStandard, sys)
    reserves = get_components(OnlineReserve{ReserveUp}, sys)
    agc = AGC(;
        name = "agc",
        available = true,
        bias = 0.0,
        K_p = 1.0,
        K_i = 1.0,
        K_d = 1.0,
        delta_t = 1.0,
    )
    @test_throws ArgumentError add_service!(sys, agc, thermals)
    add_service!(sys, agc, reserves)
    mapping = get_contributing_reserve_mapping(sys)
    @test length(mapping) == 1
    @test_throws ArgumentError add_service!(sys, agc, reserves)

    #Test serialization of system with AGC + contributing reserves
    sys = PSB.build_system(PSITestSystems, "c_sys5_uc"; add_reserves = true)
    reserves = get_components(OnlineReserve{ReserveUp}, sys)
    agc = AGC(;
        name = "agc",
        available = true,
        bias = 0.0,
        K_p = 1.0,
        K_i = 1.0,
        K_d = 1.0,
        delta_t = 1.0,
    )
    add_service!(sys, agc, reserves)
end
