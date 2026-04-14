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
