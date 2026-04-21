# TODO: re-enable once PowerSystemCaseBuilder no longer relies on PSY parsers
# (PSB.build_system uses PSY.PowerSystemTableData internally). The entire file
# is wrapped in a `false` block so it loads without invoking the parser.
if false
    test_sys = PSB.build_system(PSB.PSITestSystems, "c_sys5_all_components")
    gen_solitude = PSY.get_component(ThermalStandard, test_sys, "Solitude")::Component  # Error if `nothing`
    gen_sundance = get_component(ThermalStandard, test_sys, "Sundance")::Component
    set_available!(gen_sundance, false)
    gen_wind = get_component(RenewableDispatch, test_sys, "WindBusA")::Component

    test_sys2 = PSB.build_system(PSB.PSISystems, "5_bus_hydro_uc_sys")
    gen_sundance2 = get_component(ThermalStandard, test_sys2, "Sundance")::Component
    set_available!(gen_sundance2, false)

    sort_name!(x) = sort!(collect(x); by = get_name)

    # NOTE we are not constraining the second type parameter
    GCReturnType = IS.FlattenIteratorWrapper{<:IS.InfrastructureSystemsComponent, <:Any}

    "Helper function to test the return type of `get_components` whenever we call it"
    function get_components_rt(args...; kwargs...)
        result = get_components(args...; kwargs...)
        @test result isa GCReturnType
        return result
    end

    @testset "Test helper functions" begin
        @test subtype_to_string(ThermalStandard) == "ThermalStandard"
        @test component_to_qualified_string(ThermalStandard, "Solitude") ==
              "ThermalStandard__Solitude"
        @test component_to_qualified_string(gen_solitude) == "ThermalStandard__Solitude"
    end

    @testset "Test NameComponentSelector" begin
        test_gen_ent = PSY.NameComponentSelector(ThermalStandard, "Solitude", nothing)
        named_test_gen_ent =
            PSY.NameComponentSelector(ThermalStandard, "Solitude", "SolGen")

        # Equality
        @test PSY.NameComponentSelector(ThermalStandard, "Solitude", nothing) ==
              test_gen_ent
        @test PSY.NameComponentSelector(ThermalStandard, "Solitude", "SolGen") ==
              named_test_gen_ent

        # Construction
        @test make_selector(ThermalStandard, "Solitude") == test_gen_ent
        @test make_selector(ThermalStandard, "Solitude"; name = "SolGen") ==
              named_test_gen_ent
        @test make_selector(gen_solitude) == test_gen_ent

        # Naming
        @test get_name(test_gen_ent) == "ThermalStandard__Solitude"
        @test get_name(named_test_gen_ent) == "SolGen"

        # Contents
        @test collect(
            get_components_rt(make_selector(NonexistentComponent, ""), test_sys),
        ) ==
              Vector{Component}()
        the_components = collect(get_components_rt(test_gen_ent, test_sys))
        @test length(the_components) == 1
        @test typeof(first(the_components)) == ThermalStandard
        @test get_name(first(the_components)) == "Solitude"
        @test collect(
            get_components_rt(
                get_available,
                make_selector(gen_sundance),
                test_sys,
            ),
        ) ==
              Vector{Component}()
        @test collect(get_available_components(make_selector(gen_sundance), test_sys)) ==
              Vector{Component}()
        @test get_component(x -> true, test_gen_ent, test_sys) ==
              first(the_components)
        @test isnothing(get_component(x -> false, test_gen_ent, test_sys))
        @test isnothing(get_available_component(make_selector(gen_sundance), test_sys))

        @test only(get_groups(test_gen_ent, test_sys)) == test_gen_ent
    end

    @testset "Test ListComponentSelector" begin
        comp_ent_1 = make_selector(ThermalStandard, "Sundance")
        comp_ent_2 = make_selector(RenewableDispatch, "WindBusA")
        test_list_ent = PSY.ListComponentSelector((comp_ent_1, comp_ent_2), nothing)
        named_test_list_ent =
            PSY.ListComponentSelector((comp_ent_1, comp_ent_2), "TwoComps")

        # Equality
        @test PSY.ListComponentSelector((comp_ent_1, comp_ent_2), nothing) == test_list_ent
        @test PSY.ListComponentSelector((comp_ent_1, comp_ent_2), "TwoComps") ==
              named_test_list_ent

        # Construction
        @test make_selector(comp_ent_1, comp_ent_2;) == test_list_ent
        @test make_selector(comp_ent_1, comp_ent_2; name = "TwoComps") ==
              named_test_list_ent

        # Naming
        @test get_name(test_list_ent) ==
              "[ThermalStandard__Sundance, RenewableDispatch__WindBusA]"
        @test get_name(named_test_list_ent) == "TwoComps"

        # Contents
        @test collect(get_components_rt(make_selector(), test_sys)) == Vector{Component}()
        the_components = collect(get_components_rt(test_list_ent, test_sys))
        @test length(the_components) == 2

        @test collect(get_groups(make_selector(), test_sys)) ==
              Vector{ComponentSelector}()
        the_groups = collect(get_groups(test_list_ent, test_sys))
        @test length(the_groups) == 2
    end

    @testset "Test TypeComponentSelector" begin
        test_sub_ent = PSY.TypeComponentSelector(ThermalStandard, :all, nothing)
        named_test_sub_ent = PSY.TypeComponentSelector(ThermalStandard, :all, "Thermals")

        # Equality
        @test PSY.TypeComponentSelector(ThermalStandard, :all, nothing) == test_sub_ent
        @test PSY.TypeComponentSelector(ThermalStandard, :all, "Thermals") ==
              named_test_sub_ent

        # Construction
        @test make_selector(ThermalStandard) ==
              make_selector(ThermalStandard; groupby = :each)
        @test make_selector(ThermalStandard; groupby = :all) == test_sub_ent
        @test make_selector(ThermalStandard; groupby = :all, name = "Thermals") ==
              named_test_sub_ent
        @test make_selector(ThermalStandard; groupby = string) isa PSY.TypeComponentSelector

        # Naming
        @test get_name(test_sub_ent) == "ThermalStandard"
        @test get_name(named_test_sub_ent) == "Thermals"

        # Contents
        answer = sort_name!(get_components_rt(ThermalStandard, test_sys))

        @test collect(get_components_rt(make_selector(NonexistentComponent), test_sys)) ==
              Vector{Component}()
        the_components = sort_name!(get_components_rt(test_sub_ent, test_sys))
        @test all(the_components .== answer)
        @test !(
            gen_sundance in
            collect(get_components_rt(get_available, test_sub_ent, test_sys)))
        @test !(gen_sundance in collect(get_available_components(test_sub_ent, test_sys)))

        # Grouping inherits from `DynamicallyGroupedComponentSelector` and is tested elsewhere
    end

    @testset "Test TopologyComponentSelector" begin
        topo1 = get_component(Area, test_sys2, "1")
        topo2 = get_component(LoadZone, test_sys2, "2")
        @assert !isnothing(topo1) && !isnothing(topo2) "Relies on an out-of-date `5_bus_hydro_uc_sys` definition"
        test_topo_ent1 =
            PSY.TopologyComponentSelector(ThermalStandard, Area, "1", :all, nothing)
        test_topo_ent2 =
            PSY.TopologyComponentSelector(StaticInjection, LoadZone, "2", :all, "Zone_2")

        # Equality
        @test PSY.TopologyComponentSelector(ThermalStandard, Area, "1", :all, nothing) ==
              test_topo_ent1
        @test PSY.TopologyComponentSelector(
            StaticInjection,
            LoadZone,
            "2",
            :all,
            "Zone_2",
        ) ==
              test_topo_ent2

        # Construction
        @test make_selector(ThermalStandard, Area, "1") ==
              make_selector(ThermalStandard, Area, "1"; groupby = :each)
        @test make_selector(ThermalStandard, Area, "1"; groupby = :all) == test_topo_ent1
        @test make_selector(
            StaticInjection,
            LoadZone,
            "2";
            groupby = :all,
            name = "Zone_2",
        ) ==
              test_topo_ent2
        @test make_selector(StaticInjection, LoadZone, "2"; groupby = string) isa
              PSY.TopologyComponentSelector

        # Naming
        @test get_name(test_topo_ent1) == "Area__1__ThermalStandard"
        @test get_name(test_topo_ent2) == "Zone_2"

        # Contents
        empty_topo_ent = make_selector(NonexistentComponent, Area, "1")
        @test collect(get_components_rt(empty_topo_ent, test_sys2)) == Vector{Component}()

        nonexistent_topo_ent = make_selector(ThermalStandard, Area, "NonexistentArea")
        @test collect(get_components_rt(nonexistent_topo_ent, test_sys2)) ==
              Vector{Component}()

        answers =
            sort_name!.((
                get_components_in_aggregation_topology(
                    ThermalStandard,
                    test_sys2,
                    get_component(Area, test_sys2, "1"),
                ),
                get_components_in_aggregation_topology(
                    StaticInjection,
                    test_sys2,
                    get_component(LoadZone, test_sys2, "2"),
                )))
        for (ent, ans) in zip((test_topo_ent1, test_topo_ent2), answers)
            @assert length(ans) > 0 "Relies on an out-of-date `5_bus_hydro_uc_sys` definition"

            the_components = get_components_rt(ent, test_sys2)
            @test all(sort_name!(the_components) .== ans)
            @test Set(collect(get_components_rt(x -> true, ent, test_sys2))) ==
                  Set(the_components)
            @test length(
                collect(get_components_rt(x -> false, ent, test_sys2)),
            ) ==
                  0
        end
    end

    @testset "Test FilterComponentSelector" begin
        starts_with_s(x) = lowercase(first(get_name(x))) == 's'
        test_filter_ent =
            PSY.FilterComponentSelector(ThermalStandard, starts_with_s, :all, nothing)
        named_test_filter_ent = PSY.FilterComponentSelector(
            ThermalStandard, starts_with_s, :all, "ThermStartsWithS")

        # Equality
        @test PSY.FilterComponentSelector(ThermalStandard, starts_with_s, :all, nothing) ==
              test_filter_ent
        @test PSY.FilterComponentSelector(
            ThermalStandard, starts_with_s, :all, "ThermStartsWithS") == named_test_filter_ent

        # Construction
        @test make_selector(starts_with_s, ThermalStandard) ==
              make_selector(starts_with_s, ThermalStandard; groupby = :each)
        @test make_selector(starts_with_s, ThermalStandard; groupby = :all) ==
              test_filter_ent
        @test make_selector(
            starts_with_s,
            ThermalStandard;
            groupby = :all,
            name = "ThermStartsWithS",
        ) == named_test_filter_ent
        @test make_selector(starts_with_s, ThermalStandard; groupby = string) isa
              PSY.FilterComponentSelector

        # Naming
        @test get_name(test_filter_ent) == "starts_with_s__ThermalStandard"
        @test get_name(named_test_filter_ent) == "ThermStartsWithS"

        # Contents
        answer =
            filter(starts_with_s, collect(get_components_rt(ThermalStandard, test_sys)))

        @test collect(
            get_components_rt(make_selector(x -> true, NonexistentComponent), test_sys),
        ) ==
              Vector{Component}()
        @test collect(get_components_rt(make_selector(x -> false, Component), test_sys)) ==
              Vector{Component}()
        @test all(collect(get_components_rt(test_filter_ent, test_sys)) .== answer)
        @test !(
            gen_sundance in
            collect(
                get_components_rt(get_available, test_filter_ent, test_sys),
            ))
        @test !(
            gen_sundance in collect(get_available_components(test_filter_ent, test_sys))
        )
    end

    @testset "Test RegroupedComponentSelector" begin
        comp_ent_1 = make_selector(ThermalStandard, "Sundance")
        comp_ent_2 = make_selector(RenewableDispatch, "WindBusA")
        test_list_ent = PSY.ListComponentSelector((comp_ent_1, comp_ent_2), nothing)
        test_sel = PSY.RegroupedComponentSelector(test_list_ent, :all)

        # Equality
        @test PSY.RegroupedComponentSelector(test_list_ent, :all) == test_sel

        # Naming
        @test get_name(test_sel) == get_name(test_list_ent)

        # Contents
        @test Set(collect(get_components_rt(test_sel, test_sys))) ==
              Set(collect(get_components_rt(test_list_ent, test_sys)))
    end

    @testset "Test DynamicallyGroupedComponentSelector grouping" begin
        # We'll use TopologyComponentSelector as the token example
        @assert PSY.TopologyComponentSelector <: DynamicallyGroupedComponentSelector

        all_selector = make_selector(ThermalStandard, Area, "1"; groupby = :all)
        each_selector = make_selector(ThermalStandard, Area, "1"; groupby = :each)
        @test make_selector(ThermalStandard, Area, "1") == each_selector
        @test_throws ArgumentError make_selector(
            ThermalStandard,
            Area,
            "1";
            groupby = :other,
        )
        # @show get_name.(get_components_rt(all_selector, test_sys2))
        partition_selector = make_selector(ThermalStandard, Area, "1";
            groupby = x -> occursin(" ", get_name(x)))

        @test only(get_groups(all_selector, test_sys2)) == all_selector
        @test Set(get_name.(get_groups(each_selector, test_sys2))) ==
              Set((
            component_to_qualified_string.(Ref(ThermalStandard),
            get_name.(get_components_rt(each_selector, test_sys2)))
        ))
        @test length(
            collect(
                get_groups(x -> length(get_name(x)) == 8, each_selector, test_sys2),
            ),
        ) == 2
        @test Set(get_name.(get_groups(partition_selector, test_sys2))) ==
              Set(["true", "false"])
        @test length(
            collect(
                get_groups(x -> length(get_name(x)) == 8, partition_selector, test_sys2),
            ),
        ) == 1

        # Also test briefly with something from IS
        @assert PSY.TypeComponentSelector <: DynamicallyGroupedComponentSelector
        @test length(
            collect(
                get_groups(
                    make_selector(ThermalStandard;
                        groupby = x -> length(get_name(x))), test_sys),
            ),
        ) == 3

        # Test proper handling of availability
        sel = make_selector(ThermalStandard; groupby = :each)
        @test length(get_groups(sel, test_sys2)) >
              length(get_available_groups(sel, test_sys2)) ==
              length(get_available_components(sel, test_sys2)) ==
              length(get_available_components(ThermalStandard, test_sys2)) ==
              length(get_components(get_available, ThermalStandard, test_sys2))
    end

    @testset "Test rebuild_selector" begin
        @assert !(PSY.NameComponentSelector <: PSY.DynamicallyGroupedComponentSelector)
        @assert PSY.TopologyComponentSelector <: PSY.DynamicallyGroupedComponentSelector

        sel1::PSY.NameComponentSelector =
            make_selector(ThermalStandard, "Component1"; name = "oldname")
        sel2::PSY.TypeComponentSelector =
            make_selector(ThermalStandard; groupby = :all)
        sel3::PSY.TopologyComponentSelector =
            make_selector(ThermalStandard, Area, "1"; groupby = :all)
        # TODO include sel3 when get_components is fixed -- see below
        sel4::IS.ListComponentSelector = make_selector(sel1, sel2; name = "oldname")

        @test rebuild_selector(sel1; name = "newname") ==
              make_selector(ThermalStandard, "Component1"; name = "newname")
        @test_throws Exception rebuild_selector(sel1; groupby = :each)

        @test rebuild_selector(sel2; name = "newname") ==
              make_selector(ThermalStandard; name = "newname", groupby = :all)
        @test rebuild_selector(sel2; name = "newname", groupby = :each) ==
              make_selector(ThermalStandard; name = "newname", groupby = :each)

        @test rebuild_selector(sel3; name = "newname") ==
              make_selector(ThermalStandard, Area, "1"; name = "newname", groupby = :all)
        @test rebuild_selector(sel3; name = "newname", groupby = :each) ==
              make_selector(ThermalStandard, Area, "1"; name = "newname", groupby = :each)

        @test rebuild_selector(sel4; name = "newname") ==
              make_selector(sel1, sel2; name = "newname")
        regrouped = rebuild_selector(sel4; name = "newname", groupby = :all)
        @test Set(collect(get_components_rt(regrouped, test_sys))) ==
              Set(collect(get_components_rt(sel4, test_sys)))
        @test length(get_groups(regrouped, test_sys)) == 1
    end

    @testset "Test special cases" begin
        # Can error if the `PSY.get_components` vs. `IS.get_components` stuff is not functioning correctly
        agg_selectors = [make_selector(ThermalStandard, Area, "1"),
            make_selector(ThermalStandard, Area, "1")]
        get_components_rt(make_selector(agg_selectors...), test_sys)
    end
end  # if false (parsing-dependent tests disabled)
