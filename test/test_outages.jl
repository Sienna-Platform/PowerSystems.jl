@testset "Test outages" begin
    sys = create_system_with_outages()
    gens = collect(get_components(ThermalStandard, sys))
    gen1 = gens[1]
    gen2 = gens[2]
    @test length(get_supplemental_attributes(Outage, sys)) == 4
    forced_outages =
        collect(get_supplemental_attributes(GeometricDistributionForcedOutage, sys))
    @test length(forced_outages) == 2
    @test get_supplemental_attribute(sys, IS.get_id(forced_outages[1])) ==
          forced_outages[1]
    planned_outages = collect(get_supplemental_attributes(PlannedOutage, sys))
    @test length(planned_outages) == 2
    @test get_supplemental_attribute(sys, IS.get_id(planned_outages[1])) ==
          planned_outages[1]

    geos = get_supplemental_attributes(GeographicInfo, sys)
    for geo in geos
        @test length(get_associated_components(sys, geo)) == 2
        @test length(
            get_associated_components(sys, geo; component_type = ThermalStandard),
        ) == 1
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
            uuid = IS.get_id(attributes[1])
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
        rows = list_time_series_metadata(outage)
        @test !isempty(rows)
        for md in rows
            remove_time_series!(
                sys, IS.get_time_series_type(md), outage, IS.get_name(md),
            )
        end
        @test isempty(list_time_series_metadata(outage))
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
    geo_attr2 = IS.GeographicInfo(;
        geo_json = Dict{String, Any}("type" => "Point", "coordinates" => [3.0, 4.0]),
    )

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
    uuid1 = IS.get_id(gen1)
    uuid2 = IS.get_id(gen2)

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
    @test get_monitored_components(fo_iter) == Set(IS.get_id.(gens))

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
    set_monitored_components!(o, Int[])
    @test isempty(get_monitored_components(o))
    # set_ also accepts a FlattenIteratorWrapper from get_components
    set_monitored_components!(o, get_components(ThermalStandard, sys))
    @test get_monitored_components(o) == Set(IS.get_id.(gens))
    set_monitored_components!(o, Int[])

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
    @test get_monitored_components(o3) == Set(IS.get_id.(gens))

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
    bogus_id = 999_999_999
    bad_outage = FixedForcedOutage(;
        outage_status = 0.0,
        monitored_components = [bogus_id],
    )
    @test_throws ArgumentError add_supplemental_attribute!(sys, gen1, bad_outage)

    # Validation under runchecks=false: same attach succeeds silently
    sys_nocheck = create_system_with_outages()
    set_runchecks!(sys_nocheck, false)
    gen_nc = first(get_components(ThermalStandard, sys_nocheck))
    bad_outage2 = FixedForcedOutage(;
        outage_status = 0.0,
        monitored_components = [bogus_id],
    )
    add_supplemental_attribute!(sys_nocheck, gen_nc, bad_outage2)
    @test bogus_id in get_monitored_components(bad_outage2)

    # A non-Device UUID is rejected under runchecks=true
    sys2 = create_system_with_outages()
    bus = first(get_components(ACBus, sys2))
    bus_uuid = IS.get_id(bus)
    bad_kind = FixedForcedOutage(;
        outage_status = 0.0,
        monitored_components = [bus_uuid],
    )
    gen_for_attach = first(get_components(ThermalStandard, sys2))
    @test_throws ArgumentError add_supplemental_attribute!(sys2, gen_for_attach, bad_kind)
end

@testset "Test identifier on Outage subtypes" begin
    # Default is nothing for all three concrete types.
    @test isnothing(
        get_identifier(
            GeometricDistributionForcedOutage(;
                mean_time_to_recovery = 1.0, outage_transition_probability = 0.5,
            ),
        ),
    )
    @test isnothing(get_identifier(PlannedOutage(; outage_schedule = "x")))
    @test isnothing(get_identifier(FixedForcedOutage(; outage_status = 0.0)))

    # A user-supplied identifier (a name, a block id) is stored verbatim.
    fo = GeometricDistributionForcedOutage(;
        mean_time_to_recovery = 1.0,
        outage_transition_probability = 0.5,
        identifier = "unit7_forced",
    )
    @test get_identifier(fo) == "unit7_forced"
    @test get_identifier(PlannedOutage(; outage_schedule = "x", identifier = "block_12")) ==
          "block_12"
    @test get_identifier(FixedForcedOutage(; outage_status = 1.0, identifier = "ffo_1")) ==
          "ffo_1"

    # JSON round trip: a set identifier and the nothing default both survive.
    sys = create_system_with_outages()
    gens = collect(get_components(ThermalStandard, sys))
    tagged = PlannedOutage(; outage_schedule = "3", identifier = "block_12")
    add_supplemental_attribute!(sys, gens[1], tagged)
    sys2 = roundtrip_system(sys)
    outages2 = collect(get_supplemental_attributes(Outage, sys2))
    @test length(outages2) == 5
    identifiers = Set(get_identifier(x) for x in outages2)
    @test identifiers == Set(Union{Nothing, String}["block_12", nothing])
    tagged2 = only(
        get_supplemental_attributes(
            x -> get_identifier(x) == "block_12",
            PlannedOutage,
            sys2,
        ),
    )
    @test get_outage_schedule(tagged2) == "3"
end

@testset "Test JSON round-trip of monitored_components" begin
    sys = create_system_with_outages()
    gens = collect(get_components(ThermalStandard, sys))
    # Tag each existing outage with a non-empty monitored_components list so the
    # field has values to round-trip.
    for outage in get_supplemental_attributes(Outage, sys)
        set_monitored_components!(outage, gens)
    end

    # `create_system_with_outages` attaches one `SingleTimeSeries` per outage. An outage's
    # document id is its own IS id, stable across the round trip below, so its series is
    # findable in the rebuilt system under that same id.
    original_series = Dict{Int, Vector{Int}}(
        IS.get_id(outage) =>
            TimeSeries.values(
                PSY.get_data(
                    IS.get_time_series(
                        outage,
                        IS.get_time_series_key(only(IS.list_time_series_metadata(outage))),
                    ),
                ),
            ) for outage in get_supplemental_attributes(Outage, sys)
    )

    sys2 = roundtrip_system(sys)

    # Every outage must come back with the same monitored UUIDs (set semantics —
    # order is not preserved), and each UUID must still resolve to a Device in
    # the new system.
    # The rebuilt system's ids, not the original's: a load mints fresh component ids, so the
    # original `gens` ids do not carry over. What must hold is that each outage still points
    # at the same *set of components*, resolvable in the system it came back in.
    expected_uuids = Set(IS.get_id.(collect(get_components(ThermalStandard, sys2))))
    outages2 = collect(get_supplemental_attributes(Outage, sys2))
    @test length(outages2) == 4
    for outage in outages2
        uuids = get_monitored_components(outage)
        @test uuids isa Set{Int}
        @test uuids == expected_uuids
        for uuid in uuids
            comp = IS.get_component(sys2, uuid)
            @test comp isa ThermalStandard
        end
    end

    # The attribute-owned series survive value-for-value, keyed by the id that stays stable
    # across the round trip.
    for outage in outages2
        key = IS.get_time_series_key(only(IS.list_time_series_metadata(outage)))
        values = TimeSeries.values(PSY.get_data(IS.get_time_series(outage, key)))
        @test values == original_series[IS.get_id(outage)]
    end

    # Default (empty) monitored_components also round-trips without error.
    sys_empty = create_system_with_outages()
    sys_empty2 = roundtrip_system(sys_empty)
    for outage in get_supplemental_attributes(Outage, sys_empty2)
        @test isempty(get_monitored_components(outage))
    end
end

@testset "Test attribute added by hand to a document survives import with no sidecar row" begin
    # Attribute payloads stay document-authoritative: a document may name a supplemental
    # attribute association the adopted sidecar's catalog does not (yet) carry — exactly the
    # shape a hand-augmentation flow needs (see test_openapi_ptdp_end_to_end.jl's ATTRIBUTES
    # phase) — and import writes it fresh rather than rejecting the document over it.
    sys = create_system_with_outages()
    dir = mktempdir()
    to_file(sys, dir; force = true)
    doc = PSY.PD.read_document(joinpath(dir, "system.json"))

    geo_json = Dict{String, Any}("type" => "Point", "coordinates" => [0.0, 0.0])
    geo = PSY.IC.GeographicInfo(; id = PSY.PD.next_id!(doc), geo_json = geo_json)
    # A load carries none of the outage/GeographicInfo attributes the fixture attaches only
    # to the two generators and their buses, so it is unambiguously bare beforehand.
    load_id = Int(first(PSY.PD.get_components(doc, "PowerLoad")).id)
    PSY.PD.add_supplemental_attribute!(doc, geo, load_id)
    PSY.PD.validate_document(doc)

    sys2 = PSY.from_openapi(
        System, doc; time_series_storage_path = joinpath(dir, "time_series.h5"),
    )
    component2 = IS.get_component(sys2, load_id)
    geos2 = get_supplemental_attributes(GeographicInfo, component2)
    @test length(geos2) == 1
    @test IS.get_geo_json(only(geos2)) == geo_json
end

@testset "Test loud error: attribute_type mismatch caught on the full import path" begin
    # `_check_resolved_type_matches` (sqlite_load.jl) fires through `from_openapi` itself,
    # not only through the standalone loader unit tests in test_openapi_sqlite_load.jl.
    sys = create_system_with_outages()
    dir = mktempdir()
    to_file(sys, dir; force = true)
    doc = PSY.PD.read_document(joinpath(dir, "system.json"))
    assoc = first(doc.supplemental_attribute_associations)
    assoc.attribute_type = "EmissionsData"

    @test_throws Exception PSY.from_openapi(
        System, doc; time_series_storage_path = joinpath(dir, "time_series.h5"),
    )
end

@testset "Test loud error: document/sidecar time series row drift caught by validation" begin
    # The document's own `time_series_associations` rows are informational, but a strict
    # validation against the adopted sidecar's catalog still catches drift between the two
    # rather than silently trusting whichever the caller kept.
    sys = create_system_with_outages()
    dir = mktempdir()
    to_file(sys, dir; force = true)
    doc = PSY.PD.read_document(joinpath(dir, "system.json"))
    row = first(doc.time_series_associations).value
    row.name = "not_the_real_series_name"

    @test_throws IS.DataFormatError PSY.from_openapi(
        System, doc; time_series_storage_path = joinpath(dir, "time_series.h5"),
    )
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
