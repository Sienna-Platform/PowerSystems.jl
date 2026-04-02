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
