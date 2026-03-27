import PowerSystems: LazyDictFromIterator

@testset "PowerSystemTableData parsing" begin
    resolutions = (
        (resolution = Dates.Minute(5), len = 288),
        (resolution = Dates.Minute(60), len = 24),
    )

    for (resolution, len) in resolutions
        sys = create_rts_system(resolution)
        for time_series in get_time_series_multiple(sys)
            @test length(time_series) == len
        end
    end
end

@testset "PowerSystemTableData parsing invalid directory" begin
    @test_throws ErrorException PowerSystemTableData(DATA_DIR, 100.0, DESCRIPTORS)
end

@testset "Consistency between PowerSystemTableData and standardfiles" begin
    # This signature is used to capture expected error logs from parsing matpower
    consistency_test =
        () -> begin
            mpsys = System(joinpath(BAD_DATA, "RTS_GMLC_original.m"))
            cdmsys = PSB.build_system(
                PSB.PSITestSystems,
                "test_RTS_GMLC_sys";
                force_build = true,
            )
            mp_iter = get_components(HydroGen, mpsys)
            mp_generators = LazyDictFromIterator(String, HydroGen, mp_iter, get_name)
            for cdmgen in get_components(HydroGen, cdmsys)
                mpgen = get(mp_generators, uppercase(get_name(cdmgen)))
                if isnothing(mpgen)
                    error("did not find $cdmgen")
                end
                @test cdmgen.available == mpgen.available
                @test lowercase(cdmgen.bus.name) == lowercase(mpgen.bus.name)
                gen_dat = (
                    structname = nothing,
                    fields = (
                        :active_power,
                        :reactive_power,
                        :rating,
                        :active_power_limits,
                        :reactive_power_limits,
                        :ramp_limits,
                    ),
                )
                function check_fields(chk_dat)
                    for field in chk_dat.fields
                        n = get(chk_dat, :structname, nothing)
                        (cdmd, mpd) =
                            if isnothing(n)
                                (cdmgen, mpgen)
                            else
                                (getfield(cdmgen, n), getfield(mpgen, n))
                            end
                        cdmgen_val = getfield(cdmd, field)
                        mpgen_val = getfield(mpd, field)
                        if isnothing(cdmgen_val) || isnothing(mpgen_val)
                            @warn "Skip value with nothing" repr(cdmgen_val) repr(mpgen_val)
                            continue
                        end
                        @test cdmgen_val == mpgen_val
                    end
                end
                check_fields(gen_dat)
            end

            mp_iter = get_components(ThermalGen, mpsys)
            mp_generators = LazyDictFromIterator(String, ThermalGen, mp_iter, get_name)
            for cdmgen in get_components(ThermalGen, cdmsys)
                if isnothing(cdmgen)
                    # Skips generators parsed from Matpower as SynchCondensers in PSY5
                    # The fields are different so those aren't valiated in this loop
                    continue
                end
                mpgen = get(mp_generators, uppercase(get_name(cdmgen)))
                @test cdmgen.available == mpgen.available
                @test lowercase(cdmgen.bus.name) == lowercase(mpgen.bus.name)
                for field in (:active_power_limits, :reactive_power_limits, :ramp_limits)
                    cdmgen_val = getfield(cdmgen, field)
                    mpgen_val = getfield(mpgen, field)
                    if isnothing(cdmgen_val) || isnothing(mpgen_val)
                        @warn "Skip value with nothing" repr(cdmgen_val) repr(mpgen_val)
                        continue
                    end
                    @test cdmgen_val == mpgen_val
                end

                mpgen_cost = get_operation_cost(mpgen)
                # Currently true; this is likely to change in the future and then we'd have to change the test
                @assert get_variable(mpgen_cost) isa
                        CostCurve{InputOutputCurve{PiecewiseLinearData}}
                mp_points = get_points(
                    get_function_data(get_value_curve(
                        get_variable(mpgen_cost))),
                )
                if length(mp_points) == 4
                    cdm_op_cost = get_operation_cost(cdmgen)
                    @test get_fixed(cdm_op_cost) == 0.0
                    fuel_curve = get_variable(cdm_op_cost)
                    fuel_cost = get_fuel_cost(fuel_curve)
                    mp_fixed = get_fixed(mpgen_cost)
                    io_curve = InputOutputCurve(get_value_curve(fuel_curve))
                    cdm_points = get_points(io_curve)
                    @test all(
                        isapprox.(
                            [p.y * fuel_cost for p in cdm_points],
                            [p.y + mp_fixed for p in mp_points],
                            atol = 0.1),
                    )
                    @test all(
                        isapprox.(
                            [p.x for p in cdm_points],
                            [p.x * PSY._get_base_power(mpgen) for p in mp_points],
                            atol = 0.1),
                    )
                end
            end

            mp_iter = get_components(RenewableGen, mpsys)
            mp_generators =
                LazyDictFromIterator(String, RenewableGen, mp_iter, get_name)
            for cdmgen in get_components(RenewableGen, cdmsys)
                mpgen = get(mp_generators, uppercase(get_name(cdmgen)))
                # Disabled since data is inconsisten between sources
                #@test cdmgen.available == mpgen.available
                @test lowercase(cdmgen.bus.name) == lowercase(mpgen.bus.name)
                for field in (:rating, :power_factor)
                    cdmgen_val = getfield(cdmgen, field)
                    mpgen_val = getfield(mpgen, field)
                    if isnothing(cdmgen_val) || isnothing(mpgen_val)
                        @warn "Skip value with nothing" repr(cdmgen_val) repr(mpgen_val)
                        continue
                    end
                    @test cdmgen_val == mpgen_val
                end
                #@test compare_values_without_uuids(cdmgen.operation_cost, mpgen.operation_cost)
            end

            cdm_ac_branches = collect(get_components(ACBranch, cdmsys))
            @test get_rating(cdm_ac_branches[2], SU) ==
                  get_rating(get_branch(mpsys, cdm_ac_branches[2]), SU)
            @test get_rating(cdm_ac_branches[6], SU) ==
                  get_rating(get_branch(mpsys, cdm_ac_branches[6]), SU)
            @test get_rating(cdm_ac_branches[120], SU) ==
                  get_rating(get_branch(mpsys, cdm_ac_branches[120]), SU)

            cdm_dc_branches =
                collect(get_components(TwoTerminalGenericHVDCLine, cdmsys))
            @test get_active_power_limits_from(cdm_dc_branches[1], SU) ==
                  get_active_power_limits_from(get_branch(mpsys, cdm_dc_branches[1]), SU)
        end
    @test_logs (:error,) match_mode = :any min_level = Logging.Error consistency_test()
end

@testset "Test reserve direction" begin
    @test PSY.get_reserve_direction("Up") == ReserveUp
    @test PSY.get_reserve_direction("Down") == ReserveDown
    @test PSY.get_reserve_direction("up") == ReserveUp
    @test PSY.get_reserve_direction("down") == ReserveDown

    for invalid in ("right", "left")
        @test_throws PSY.DataFormatError PSY.get_reserve_direction(invalid)
    end
end

@testset "Test consistency between variable cost and heat rate parsing" begin
    fivebus_dir = joinpath(DATA_DIR, "5-Bus")
    rawsys_hr = PowerSystemTableData(
        fivebus_dir,
        100.0,
        joinpath(fivebus_dir, "user_descriptors_var_cost.yaml");
        generator_mapping_file = joinpath(fivebus_dir, "generator_mapping.yaml"),
    )
    rawsys = PowerSystemTableData(
        fivebus_dir,
        100.0,
        joinpath(fivebus_dir, "user_descriptors_var_cost.yaml");
        generator_mapping_file = joinpath(fivebus_dir, "generator_mapping.yaml"),
    )
    sys_hr = System(rawsys_hr)
    sys = System(rawsys)

    g_hr = get_components(ThermalStandard, sys_hr)
    g = get_components(ThermalStandard, sys)
    @test get_variable.(get_operation_cost.(g)) == get_variable.(get_operation_cost.(g))
end

@testset "Test create_poly_cost function" begin
    cost_colnames = ["heat_rate_a0", "heat_rate_a1", "heat_rate_a2"]

    # Coefficients for a CC using natural gas
    a2 = -0.000531607
    a1 = 0.060554675
    a0 = 8.951100118

    # First test that return quadratic if all coefficients are provided.
    # We convert the coefficients to string to mimic parsing from csv
    example_generator = (
        name = "test-gen",
        heat_rate_a0 = string(a0),
        heat_rate_a1 = string(a1),
        heat_rate_a2 = string(a2),
    )
    cost_curve, fixed_cost = create_poly_cost(example_generator, cost_colnames)
    @assert cost_curve isa QuadraticCurve
    @assert isapprox(get_quadratic_term(cost_curve), a2, atol = 0.01)
    @assert isapprox(get_proportional_term(cost_curve), a1, atol = 0.01)
    @assert isapprox(get_constant_term(cost_curve), a0, atol = 0.01)

    # Test return linear with both proportional and constant term
    example_generator = (
        name = "test-gen",
        heat_rate_a0 = string(a0),
        heat_rate_a1 = string(a1),
        heat_rate_a2 = nothing,
    )
    cost_curve, fixed_cost = create_poly_cost(example_generator, cost_colnames)
    @assert cost_curve isa LinearCurve
    @assert isapprox(get_proportional_term(cost_curve), a1, atol = 0.01)
    @assert isapprox(get_constant_term(cost_curve), a0, atol = 0.01)

    # Test return linear with just proportional term
    example_generator = (
        name = "test-gen",
        heat_rate_a0 = nothing,
        heat_rate_a1 = string(a1),
        heat_rate_a2 = nothing,
    )
    cost_curve, fixed_cost = create_poly_cost(example_generator, cost_colnames)
    @assert cost_curve isa LinearCurve
    @assert isapprox(get_proportional_term(cost_curve), a1, atol = 0.01)

    # Test raises error if a2 is passed but other coefficients are nothing
    example_generator = (
        name = "test-gen",
        heat_rate_a0 = nothing,
        heat_rate_a1 = nothing,
        heat_rate_a2 = string(a2),
    )
    @test_throws IS.DataFormatError create_poly_cost(example_generator, cost_colnames)
    example_generator = (
        name = "test-gen",
        heat_rate_a0 = nothing,
        heat_rate_a1 = string(a1),
        heat_rate_a2 = string(a2),
    )
    @test_throws IS.DataFormatError create_poly_cost(example_generator, cost_colnames)
    example_generator = (
        name = "test-gen",
        heat_rate_a0 = string(a0),
        heat_rate_a1 = nothing,
        heat_rate_a2 = string(a2),
    )
    @test_throws IS.DataFormatError create_poly_cost(example_generator, cost_colnames)

    # Test that it works with zero proportional and constant term
    example_generator = (
        name = "test-gen",
        heat_rate_a0 = string(0.0),
        heat_rate_a1 = string(0.0),
        heat_rate_a2 = string(a2),
    )
    cost_curve, fixed_cost = create_poly_cost(example_generator, cost_colnames)
    @assert cost_curve isa QuadraticCurve
    @assert isapprox(get_quadratic_term(cost_curve), a2, atol = 0.01)
    @assert isapprox(get_proportional_term(cost_curve), 0.0, atol = 0.01)
    @assert isapprox(get_constant_term(cost_curve), 0.0, atol = 0.01)

    # Test that create_poly_cost works with numeric values (not just strings)
    # Some CSV parsers return numeric types directly instead of strings
    example_generator = (
        name = "test-gen",
        heat_rate_a0 = a0,  # Float64
        heat_rate_a1 = a1,  # Float64
        heat_rate_a2 = a2,  # Float64
    )
    cost_curve, fixed_cost = create_poly_cost(example_generator, cost_colnames)
    @assert cost_curve isa QuadraticCurve
    @assert isapprox(get_quadratic_term(cost_curve), a2, atol = 0.01)
    @assert isapprox(get_proportional_term(cost_curve), a1, atol = 0.01)
    @assert isapprox(get_constant_term(cost_curve), a0, atol = 0.01)

    # Test with Int64 values (another common numeric type from CSV parsers)
    example_generator = (
        name = "test-gen",
        heat_rate_a0 = Int64(9),
        heat_rate_a1 = Int64(0),
        heat_rate_a2 = Int64(0),
    )
    cost_curve, fixed_cost = create_poly_cost(example_generator, cost_colnames)
    @assert cost_curve isa QuadraticCurve
    @assert isapprox(get_quadratic_term(cost_curve), 0.0, atol = 0.01)
    @assert isapprox(get_proportional_term(cost_curve), 0.0, atol = 0.01)
    @assert isapprox(get_constant_term(cost_curve), 9.0, atol = 0.01)
end

@testset "Test parsing with ThermalMultiStart generators" begin
    # Test that ThermalMultiStart generators parse correctly with multi-start costs
    # This exercises the multi-start cost fallback logic in make_thermal_generator_multistart
    rawsys = PowerSystemTableData(
        RTS_GMLC_DIR,
        100.0,
        DESCRIPTORS;
        generator_mapping_file = joinpath(
            RTS_GMLC_DIR,
            "generator_mapping_multi_start.yaml",
        ),
    )
    sys = System(rawsys; time_series_resolution = Dates.Hour(1))

    # Verify ThermalMultiStart generators were created
    ms_gens = collect(get_components(ThermalMultiStart, sys))
    @test length(ms_gens) > 0

    # Check that startup costs were parsed correctly
    for gen in ms_gens
        op_cost = get_operation_cost(gen)
        startup_costs = get_start_up(op_cost)
        # Startup costs should be non-negative
        @test startup_costs.hot >= 0.0
        @test startup_costs.warm >= 0.0
        @test startup_costs.cold >= 0.0
    end
end

@testset "Test Reservoirs and Turbines" begin
    cdmsys = PSB.build_system(
        PSB.PSITestSystems,
        "test_RTS_GMLC_sys";
        force_build = true,
    )
    @test !isempty(get_components(HydroTurbine, cdmsys))
    for turbine in get_components(HydroTurbine, cdmsys)
        reservoir = get_connected_head_reservoirs(cdmsys, turbine)
        @test !isempty(reservoir)
        reservoir = get_connected_tail_reservoirs(cdmsys, turbine)
        @test isempty(reservoir)
    end

    @test !isempty(get_components(HydroReservoir, cdmsys))

    for reservoir in get_components(HydroReservoir, cdmsys)
        turbines = get_downstream_turbines(reservoir)
        @test !isempty(turbines)
        @test isempty(get_upstream_turbines(reservoir))
    end
end
