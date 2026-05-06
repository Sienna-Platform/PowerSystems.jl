@testset "Test outages" begin
    sys = create_system_with_outages()
    gens = collect(get_components(ThermalStandard, sys))
    gen1 = gens[1]
    gen2 = gens[2]
    @test length(get_supplemental_attributes(Outage, sys)) == 4
    forced_outages =
        collect(get_supplemental_attributes(GeometricDistributionForcedOutage, sys))
    @test length(forced_outages) == 2
    @test get_supplemental_attribute(sys, IS.get_uuid(forced_outages[1])) ==
          forced_outages[1]
    planned_outages = collect(get_supplemental_attributes(PlannedOutage, sys))
    @test length(planned_outages) == 2
    @test get_supplemental_attribute(sys, IS.get_uuid(planned_outages[1])) ==
          planned_outages[1]

    geos = get_supplemental_attributes(GeographicInfo, sys)
    for geo in geos
        @test length(get_associated_components(sys, geo)) == 2
        @test length(
            get_associated_components(sys, geo; component_type = ThermalStandard),
        ) == 1
        # This method is deprecated for now...will be deleted later.
        @test length(get_components(sys, geo)) == 2
    end

    associated_components = get_associated_components(sys, GeographicInfo)
    @test length(associated_components) == 4
    @test Set([typeof(x) for x in associated_components]) == Set([ACBus, ThermalStandard])

    associated_components =
        get_associated_components(sys, GeographicInfo; component_type = ThermalGen)
    @test length(associated_components) == 2

    for gen in (gen1, gen2)
        for type in (GeometricDistributionForcedOutage, PlannedOutage, GeographicInfo)
            attributes = get_supplemental_attributes(type, gen)
            @test length(attributes) == 1
            uuid = IS.get_uuid(attributes[1])
            get_supplemental_attribute(sys, uuid)
            get_supplemental_attribute(gen, uuid)
            @test get_supplemental_attribute(gen, uuid) ==
                  get_supplemental_attribute(sys, uuid)
        end
    end

    @test length(
        get_supplemental_attributes(
            x -> get_mean_time_to_recovery(x) == 2.0,
            GeometricDistributionForcedOutage,
            sys,
        ),
    ) == 1
    @test length(
        get_supplemental_attributes(
            x -> get_mean_time_to_recovery(x) == 2.0,
            GeometricDistributionForcedOutage,
            gen1,
        ),
    ) == 0
    @test length(
        get_supplemental_attributes(
            x -> get_mean_time_to_recovery(x) == 2.0,
            GeometricDistributionForcedOutage,
            gen2,
        ),
    ) == 1
    @test length(
        get_supplemental_attributes(x -> get_outage_schedule(x) == "1", PlannedOutage, sys),
    ) == 1
    @test length(
        get_supplemental_attributes(
            x -> get_outage_schedule(x) == "1",
            PlannedOutage,
            gen1,
        ),
    ) == 1
    @test length(
        get_supplemental_attributes(
            x -> get_outage_schedule(x) == "1",
            PlannedOutage,
            gen2,
        ),
    ) == 0
    planned_outages = collect(get_supplemental_attributes(PlannedOutage, gen2))
    @test !isempty(planned_outages)
    for outage in planned_outages
        ts_keys = get_time_series_keys(outage)
        @test !isempty(ts_keys)
        for key in ts_keys
            remove_time_series!(sys, key.time_series_type, outage, key.name)
        end
        @test isempty(get_time_series_keys(outage))
    end
end

@testset "Test get_component_supplemental_attribute_pairs" begin
    sys = create_system_with_outages()
    # This function is properly tested in InfrastructureSystems.
    for (gen, outage) in get_component_supplemental_attribute_pairs(
        ThermalStandard,
        GeometricDistributionForcedOutage,
        sys,
    )
        @test gen isa ThermalStandard
        @test outage isa GeometricDistributionForcedOutage
    end
end

@testset "Test get_supplemental_attributes with component type" begin
    # the create_system_with_outages function creates a system with only ThermalStandard
    # components, so we need a different system for this test.
    c_sys5_bat = PSB.build_system(PSITestSystems, "c_sys5_bat")
    renewables = collect(get_components(PSY.RenewableDispatch, c_sys5_bat))
    thermals = collect(get_components(PSY.ThermalStandard, c_sys5_bat))

    attr1 = IS.TestSupplemental(; value = 1.0)
    attr2 = IS.TestSupplemental(; value = 2.0)
    geo_attr1 = IS.GeographicInfo()
    geo_attr2 = IS.GeographicInfo(; geo_json = Dict{String, Any}("foo" => 5))

    comp_to_attributes = Dict{PSY.Component, Vector{IS.SupplementalAttribute}}(
        renewables[1] => [geo_attr1],
        renewables[2] => [geo_attr1, attr1],
        thermals[1] => [geo_attr2],
        thermals[2] => [geo_attr2, attr2],
        thermals[3] => [geo_attr1],
    )
    for (comp, attrs) in comp_to_attributes
        for attr in attrs
            add_supplemental_attribute!(c_sys5_bat, comp, attr)
        end
    end

    renewable_attrs =
        get_associated_supplemental_attributes(c_sys5_bat, PSY.RenewableDispatch)
    @test length(renewable_attrs) == 2 && geo_attr1 in renewable_attrs &&
          attr1 in renewable_attrs

    thermal_attrs = get_associated_supplemental_attributes(c_sys5_bat, PSY.ThermalStandard)
    @test length(thermal_attrs) == 3 && geo_attr2 in thermal_attrs &&
          attr2 in thermal_attrs && geo_attr1 in thermal_attrs

    thermal_geo_attrs = get_associated_supplemental_attributes(
        c_sys5_bat,
        PSY.ThermalStandard;
        attribute_type = IS.GeographicInfo,
    )
    @test length(thermal_geo_attrs) == 2 && geo_attr1 in thermal_geo_attrs &&
          geo_attr2 in thermal_geo_attrs
end

@testset "Test monitored_components on Outage subtypes" begin
    sys = create_system_with_outages()
    gens = collect(get_components(ThermalStandard, sys))
    gen1, gen2 = gens[1], gens[2]
    uuid1 = IS.get_uuid(gen1)
    uuid2 = IS.get_uuid(gen2)

    # Default is empty for all three concrete types
    @test isempty(
        get_monitored_components(
            GeometricDistributionForcedOutage(;
                mean_time_to_recovery = 1.0, outage_transition_probability = 0.5,
            ),
        ),
    )
    @test isempty(get_monitored_components(PlannedOutage(; outage_schedule = "x")))
    @test isempty(get_monitored_components(FixedForcedOutage(; outage_status = 0.0)))

    # Construct with UUIDs
    fo_uuid = GeometricDistributionForcedOutage(;
        mean_time_to_recovery = 1.0,
        outage_transition_probability = 0.5,
        monitored_components = [uuid1, uuid2],
    )
    @test get_monitored_components(fo_uuid) == Set([uuid1, uuid2])

    # Construct with Device references
    fo_dev = GeometricDistributionForcedOutage(;
        mean_time_to_recovery = 1.0,
        outage_transition_probability = 0.5,
        monitored_components = [gen1, gen2],
    )
    @test get_monitored_components(fo_dev) == Set([uuid1, uuid2])

    # Construct with the FlattenIteratorWrapper returned by get_components
    fo_iter = GeometricDistributionForcedOutage(;
        mean_time_to_recovery = 1.0,
        outage_transition_probability = 0.5,
        monitored_components = get_components(ThermalStandard, sys),
    )
    @test get_monitored_components(fo_iter) == Set(IS.get_uuid.(gens))

    # Construction silently dedups duplicate UUIDs
    fo_dup = GeometricDistributionForcedOutage(;
        mean_time_to_recovery = 1.0,
        outage_transition_probability = 0.5,
        monitored_components = [uuid1, uuid1, uuid2],
    )
    @test get_monitored_components(fo_dup) == Set([uuid1, uuid2])

    # Same for PlannedOutage and FixedForcedOutage
    po = PlannedOutage(; outage_schedule = "1", monitored_components = [gen1])
    @test get_monitored_components(po) == Set([uuid1])
    ff = FixedForcedOutage(; outage_status = 1.0, monitored_components = [uuid2])
    @test get_monitored_components(ff) == Set([uuid2])

    # set_monitored_components! accepts UUID and Device iterables
    o = FixedForcedOutage(; outage_status = 0.0)
    set_monitored_components!(o, [uuid1])
    @test get_monitored_components(o) == Set([uuid1])
    set_monitored_components!(o, [gen2])
    @test get_monitored_components(o) == Set([uuid2])
    set_monitored_components!(o, Base.UUID[])
    @test isempty(get_monitored_components(o))
    # set_ also accepts a FlattenIteratorWrapper from get_components
    set_monitored_components!(o, get_components(ThermalStandard, sys))
    @test get_monitored_components(o) == Set(IS.get_uuid.(gens))
    set_monitored_components!(o, Base.UUID[])

    # add_monitored_component! with single UUID or Device, including dedup
    add_monitored_component!(o, uuid1)
    add_monitored_component!(o, gen2)
    @test get_monitored_components(o) == Set([uuid1, uuid2])
    add_monitored_component!(o, gen1)  # duplicate, should no-op
    @test get_monitored_components(o) == Set([uuid1, uuid2])
    @test length(get_monitored_components(o)) == 2

    # add_monitored_components! with iterables: Vector, generator, FlattenIteratorWrapper
    o2 = FixedForcedOutage(; outage_status = 0.0)
    add_monitored_components!(o2, [uuid1, gen2])  # mixed UUID + Device
    @test get_monitored_components(o2) == Set([uuid1, uuid2])
    add_monitored_components!(o2, (g for g in gens[1:2]))  # generator, all already present
    @test get_monitored_components(o2) == Set([uuid1, uuid2])
    o3 = FixedForcedOutage(; outage_status = 0.0)
    add_monitored_components!(o3, get_components(ThermalStandard, sys))
    @test get_monitored_components(o3) == Set(IS.get_uuid.(gens))

    # remove_monitored_component! with single UUID or Device
    remove_monitored_component!(o, uuid1)
    @test get_monitored_components(o) == Set([uuid2])
    remove_monitored_component!(o, gen2)
    @test isempty(get_monitored_components(o))
    # Removing absent UUID is a no-op
    remove_monitored_component!(o, uuid1)
    @test isempty(get_monitored_components(o))

    # remove_monitored_components! with an iterable
    remove_monitored_components!(o3, get_components(ThermalStandard, sys))
    @test isempty(get_monitored_components(o3))

    # Validation under runchecks=true: a bogus UUID at attach time raises
    bogus_uuid = Base.UUID("00000000-0000-0000-0000-000000000000")
    bad_outage = FixedForcedOutage(;
        outage_status = 0.0,
        monitored_components = [bogus_uuid],
    )
    @test_throws ArgumentError add_supplemental_attribute!(sys, gen1, bad_outage)

    # Validation under runchecks=false: same attach succeeds silently
    sys_nocheck = create_system_with_outages()
    set_runchecks!(sys_nocheck, false)
    gen_nc = first(get_components(ThermalStandard, sys_nocheck))
    bad_outage2 = FixedForcedOutage(;
        outage_status = 0.0,
        monitored_components = [bogus_uuid],
    )
    add_supplemental_attribute!(sys_nocheck, gen_nc, bad_outage2)
    @test bogus_uuid in get_monitored_components(bad_outage2)

    # A non-Device UUID is rejected under runchecks=true
    sys2 = create_system_with_outages()
    bus = first(get_components(ACBus, sys2))
    bus_uuid = IS.get_uuid(bus)
    bad_kind = FixedForcedOutage(;
        outage_status = 0.0,
        monitored_components = [bus_uuid],
    )
    gen_for_attach = first(get_components(ThermalStandard, sys2))
    @test_throws ArgumentError add_supplemental_attribute!(sys2, gen_for_attach, bad_kind)
end

@testset "Test JSON round-trip of monitored_components" begin
    sys = create_system_with_outages()
    gens = collect(get_components(ThermalStandard, sys))
    # Tag each existing outage with a non-empty monitored_components list so the
    # field has values to round-trip.
    for outage in get_supplemental_attributes(Outage, sys)
        set_monitored_components!(outage, gens)
    end

    # Round-trip via to_json/from_json, preserving UUIDs.
    test_dir = mktempdir()
    path = joinpath(test_dir, "sys_with_monitored.json")
    to_json(sys, path; force = true)
    sys2 = System(path)

    # Every outage must come back with the same monitored UUIDs (set semantics —
    # order is not preserved), and each UUID must still resolve to a Device in
    # the new system.
    expected_uuids = Set(IS.get_uuid.(gens))
    outages2 = collect(get_supplemental_attributes(Outage, sys2))
    @test length(outages2) == 4
    for outage in outages2
        uuids = get_monitored_components(outage)
        @test uuids isa Set{Base.UUID}
        @test uuids == expected_uuids
        for uuid in uuids
            comp = IS.get_component(sys2, uuid)
            @test comp isa ThermalStandard
        end
    end

    # Default (empty) monitored_components also round-trips without error.
    sys_empty = create_system_with_outages()
    sys_empty2, ok = validate_serialization(sys_empty)
    @test ok
    for outage in get_supplemental_attributes(Outage, sys_empty2)
        @test isempty(get_monitored_components(outage))
    end
end

@testset "Test remove_supplemental_attributes! by type" begin
    sys = create_system_with_outages()
    # Verify initial state
    @test length(get_supplemental_attributes(GeometricDistributionForcedOutage, sys)) == 2
    @test length(get_supplemental_attributes(PlannedOutage, sys)) == 2
    @test length(get_supplemental_attributes(GeographicInfo, sys)) == 2

    # Remove all GeometricDistributionForcedOutage attributes
    remove_supplemental_attributes!(GeometricDistributionForcedOutage, sys)
    @test length(get_supplemental_attributes(GeometricDistributionForcedOutage, sys)) == 0
    # Other types should be unaffected
    @test length(get_supplemental_attributes(PlannedOutage, sys)) == 2
    @test length(get_supplemental_attributes(GeographicInfo, sys)) == 2

    # Remove all PlannedOutage attributes
    remove_supplemental_attributes!(PlannedOutage, sys)
    @test length(get_supplemental_attributes(PlannedOutage, sys)) == 0
    @test length(get_supplemental_attributes(GeographicInfo, sys)) == 2

    # Remove all GeographicInfo attributes
    remove_supplemental_attributes!(GeographicInfo, sys)
    @test length(get_supplemental_attributes(GeographicInfo, sys)) == 0
end
