@testset "Test reading in config data" begin
    data = IS.read_validation_descriptor(PSY.POWER_SYSTEM_STRUCT_DESCRIPTOR_FILE)
    @test data isa Vector
    @test !isempty(data)
    function find_struct()
        for item in data
            if item["struct_name"] == "ThermalStandard"
                return true
            end
        end
        return false
    end
    @test find_struct()
    @test_throws(ErrorException, IS.read_validation_descriptor("badfile.toml"))
end

@testset "Test adding custom validation YAML file to System" begin
    nodes = nodes5()
    sys_no_config =
        System(100.0, nodes, thermal_generators5(nodes), loads5(nodes); runchecks = true)
    @test !isempty(sys_no_config.data.validation_descriptors)

    nodes = nodes5()
    sys_no_runchecks =
        System(100.0, nodes, thermal_generators5(nodes), loads5(nodes); runchecks = false)
    @test !isempty(sys_no_runchecks.data.validation_descriptors)
end

@testset "Test extracting struct info from validation_descriptor vector" begin
    data = [
        Dict(
            "fields" => Dict{Any, Any}[
                Dict(
                    "name" => "curtailpenalty",
                    "valid_range" => Dict{Any, Any}("max" => nothing, "min" => 0.0),
                ),
                Dict(
                    "name" => "variablecost",
                    "valid_range" => Dict{Any, Any}("max" => nothing, "min" => 0.0),
                ),
                Dict("name" => "internal"),
            ],
            "struct_name" => "EconHydro",
        ),
        Dict(
            "fields" => Dict{Any, Any}[
                Dict(
                    "name" => "curtailpenalty",
                    "valid_range" => Dict{Any, Any}("max" => nothing, "min" => 0.0),
                ),
                Dict(
                    "name" => "variablecost",
                    "valid_range" => Dict{Any, Any}("max" => nothing, "min" => 0.0),
                ),
                Dict("name" => "internal"),
            ],
            "struct_name" => "EconLoad",
        ),
    ]
    struct_name = "EconHydro"
    descriptor = IS.get_config_descriptor(data, struct_name)
    @test descriptor isa Dict{String, Any}
    @test haskey(descriptor, "struct_name")
    @test haskey(descriptor, "fields")
    @test descriptor["struct_name"] == struct_name
end

@testset "Test extracting field info from struct descriptor dictionary" begin
    config = Dict{Any, Any}(
        "fields" => Dict{Any, Any}[
            Dict("name" => "name", "data_type" => "String"),
            Dict("name" => "available", "data_type" => "Bool"),
            Dict("name" => "bus", "data_type" => "ACBus"),
            Dict("name" => "tech", "data_type" => "Union{Nothing, TechThermal}"),
            Dict("name" => "econ", "data_type" => "Union{Nothing, EconThermal}"),
            Dict("name" => "internal", "data_type" => "IS.InfrastructureSystemsInternal"),
        ],
        "struct_name" => "ThermalStandard",
    )
    field_name = "econ"
    field_descriptor = IS.get_field_descriptor(config, field_name)
    @test field_descriptor isa Dict{Any, Any}
    @test haskey(field_descriptor, "name")
    @test field_descriptor["name"] == field_name
end

@testset "Test retrieving validation action" begin
    warn_descriptor = Dict{Any, Any}(
        "name" => "ramp_limits",
        "valid_range" => Dict{Any, Any}("max" => 5, "min" => 0),
        "validation_action" => "warn",
    )
    error_descriptor = Dict{Any, Any}(
        "name" => "ramp_limits",
        "valid_range" => Dict{Any, Any}("max" => 5, "min" => 0),
        "validation_action" => "error",
    )
    typo_descriptor = Dict{Any, Any}(
        "name" => "ramp_limits",
        "valid_range" => Dict{Any, Any}("max" => 5, "min" => 0),
        "validation_action" => "asdfasdfsd",
    )
    @test IS.get_validation_action(warn_descriptor) == IS.validation_warning
    @test IS.get_validation_action(error_descriptor) == IS.validation_error
    @test_throws(ErrorException, IS.get_validation_action(typo_descriptor))
end

@testset "Test field validation" begin
    #test recursive call of validate_fields and a regular valid range
    nodes = nodes5()
    bad_therm_gen_rating = thermal_generators5(nodes)
    bad_therm_gen_rating[1].rating = -10
    @test_logs(
        (:error, r"Invalid range"),
        @test_throws(
            PSY.InvalidValue,
            System(100.0, nodes, bad_therm_gen_rating, loads5(nodes); runchecks = true)
        )
    )

    #test custom range (active_power and active_power_limits)
    nodes = nodes5()
    bad_therm_gen_act_power = thermal_generators5(nodes)
    bad_therm_gen_act_power[1].active_power = 10
    # This is an explicit check for one error message.
    @test_logs (:warn, r"Invalid range") System(
        100.0,
        nodes,
        bad_therm_gen_act_power,
        loads5(nodes);
        runchecks = true,
    )

    #test validating named tuple
    nodes = nodes5()
    bad_therm_gen_ramp_lim = thermal_generators5(nodes)
    bad_therm_gen_ramp_lim[1].ramp_limits = (up = -10, down = -3)
    @test_logs(
        (:error, r"Invalid range"),
        match_mode = :any,
        @test_throws(
            PSY.InvalidValue,
            System(100.0, nodes, bad_therm_gen_ramp_lim, loads5(nodes); runchecks = true)
        )
    )
end

@testset "Test field validation" begin
    nodes = nodes5()
    sys = System(100.0, nodes, thermal_generators5(nodes), loads5(nodes); runchecks = true)

    add_component!(
        sys,
        ACBus(
            11,
            "11",
            true,
            ACBusTypes.PQ,
            1,
            1,
            (min = 0.9, max = 1.1),
            123,
            nothing,
            nothing,
        ),
    )
    B = collect(get_components(ACBus, sys))
    sort!(B, by = get_number)
    a = Arc(B[1], B[6])
    badline = Line(
        "badline",
        true,
        0.01,
        0.01,
        a,
        0.002,
        0.014,
        (from = 0.015, to = 0.015),
        5.0,
        (min = -1, max = 1),
    )
    @test_logs(
        (:error, r"cannot create Line"),
        match_mode = :any,
        @test_throws(PSY.InvalidValue, add_component!(sys, badline))
    )
end

# disabled until serialization is updated
@testset "Test field validation after deserialization" begin
    nodes = nodes5()
    sys = System(100.0, nodes, thermal_generators5(nodes), loads5(nodes))

    add_component!(
        sys,
        ACBus(
            11,
            "11",
            true,
            ACBusTypes.PQ,
            1,
            1,
            (min = 0.9, max = 1.1),
            123,
            nothing,
            nothing,
        ),
    )
    path = joinpath(mktempdir(), "test_validation.json")
    try
        PSY.to_json(sys, path)
    catch
        rm(path)
        rethrow()
    end

    try
        sys2 = PSY.System(path)

        B = collect(get_components(ACBus, sys2))
        sort!(B, by = get_number)
        a = Arc(B[1], B[6])
        badline = Line(
            "badline",
            true,
            0.01,
            0.01,
            a,
            0.002,
            0.014,
            (from = 0.015, to = 0.015),
            5.0,
            (min = -1, max = 1),
        )
        @test_logs(
            (:error, r"cannot create Line"),
            match_mode = :any,
            @test_throws(PSY.InvalidValue, add_component!(sys2, badline))
        )
    finally
        rm(path)
    end
end

function _make_bus()
    return ACBus(;
        number = 1,
        name = "bus1",
        available = true,
        bustype = ACBusTypes.REF,
        angle = 0.0,
        magnitude = 0.0,
        voltage_limits = (min = 0.0, max = 0.0),
        base_voltage = nothing,
        area = nothing,
        load_zone = nothing,
    )
end

@testset "Test add_component with runchecks enabled" begin
    sys = System(100.0; runchecks = true)
    @test get_runchecks(sys)
    bus = _make_bus()
    add_component!(sys, bus)
    remove_component!(sys, bus)

    # Make the bus invalid.
    set_base_voltage!(bus, -1000.0)
    @test_logs(
        (:error, r"Invalid range"),
        match_mode = :any,
        @test_throws IS.InvalidValue add_component!(sys, bus)
    )

    # Allowed with skip_validation.
    add_component!(sys, bus; skip_validation = true)
    @test !get_runchecks(sys)
end

@testset "Test add_component with runchecks disabled" begin
    sys = System(100.0; runchecks = false)
    bus = _make_bus()

    # Make the bus invalid.
    set_base_voltage!(bus, -1000.0)
    add_component!(sys, bus)
end

@testset "Test serialization and range checks" begin
    sys = System(100.0; runchecks = false)
    bus = _make_bus()

    # Make the bus invalid.
    set_base_voltage!(bus, -1000.0)
    add_component!(sys, bus)

    @test_logs(
        (:error, r"Invalid range"),
        match_mode = :any,
        @test_throws(IS.InvalidValue, validate_serialization(sys, runchecks = true)),
    )
end

@testset "Test serialization and system checks" begin
    # Serialize/deserialize an invalid system.
    sys = System(100.0; runchecks = false)
    @test !get_runchecks(sys)
    bus = _make_bus()
    set_bustype!(bus, ACBusTypes.PQ)
    add_component!(sys, bus)

    @test_logs(
        (:error, r"Model doesn't contain a slack bus"),
        match_mode = :any,
        validate_serialization(sys, runchecks = true)
    )

    sys, result = validate_serialization(sys; runchecks = false)
    @test result
    @test !get_runchecks(sys)
end

@testset "Test runchecks" begin
    sys = System(100.0)
    @test get_runchecks(sys)
    sys = System(100.0; runchecks = false)
    @test !get_runchecks(sys)
    set_runchecks!(sys, true)
    @test get_runchecks(sys)
    set_runchecks!(sys, false)
    @test !get_runchecks(sys)
end

@testset "Test check_component" begin
    sys = System(100.0; runchecks = false)
    bus = _make_bus()

    # Make the bus invalid.
    set_base_voltage!(bus, -1000.0)
    add_component!(sys, bus)

    @test_logs(
        (:error, r"Invalid range"),
        match_mode = :any,
        @test_throws(IS.InvalidValue, check_component(sys, bus)),
    )
    @test_logs(
        (:error, r"Invalid range"),
        match_mode = :any,
        @test_throws(IS.InvalidValue, check_components(sys)),
    )
end

@testset "Test check at serialization" begin
    nodes = nodes5()
    bad_therm_gen_rating = thermal_generators5(nodes)
    bad_therm_gen_rating[1].rating = -10
    sys = System(100.0, nodes, bad_therm_gen_rating, loads5(nodes); runchecks = false)
    @test_logs(
        (:error, r"Invalid range"),
        (:warn, r"exceeds total capacity capability"),
        match_mode = :any,
        @test_throws(
            IS.InvalidValue,
            to_json(sys, "sys.json", force = true, runchecks = true)
        ),
    )
end
