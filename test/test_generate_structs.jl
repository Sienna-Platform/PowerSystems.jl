@testset "Test generated structs" begin
    descriptor_file =
        joinpath(@__DIR__, "..", "src", "descriptors", "power_system_structs.json")
    existing_dir = joinpath(@__DIR__, "..", "src", "models", "generated")
    @test IS.test_generated_structs(descriptor_file, existing_dir)
end

@testset "Test generated structs from StructDefinition" begin
    orig_descriptor_file =
        joinpath(@__DIR__, "..", "src", "descriptors", "power_system_structs.json")
    output_directory = mktempdir()
    descriptor_file = joinpath(output_directory, "power_system_structs.json")
    cp(orig_descriptor_file, descriptor_file)
    # This is necessary in cases where the package has been added through a GitHub branch
    # where all source files are read-only.
    chmod(descriptor_file, 0o644)
    new_struct = StructDefinition(;
        struct_name = "MyThermalStandard",
        docstring = "Custom ThermalStandard",
        supertype = "ThermalGen",
        is_component = true,
        fields = [
            StructField(; name = "name", data_type = String, comment = "name"),
            StructField(;
                name = "active_power",
                data_type = Float64,
                valid_range = "active_power_limits",
                validation_action = "warn",
                null_value = 0.0,
                comment = "active power",
                needs_conversion = true,
            ),
            StructField(;
                name = "active_power_limits",
                needs_conversion = true,
                data_type = "NamedTuple{(:min, :max), Tuple{Float64, Float64}}",
                null_value = "(min=0.0, max=0.0)",
            ),
            StructField(;
                name = "rating",
                data_type = Float64,
                valid_range = Dict("min" => 0.0, "max" => nothing),
                validation_action = "error",
                comment = "Thermal limited MVA Power Output of the unit. <= Capacity",
            ),
        ],
    )
    redirect_stdout(devnull) do
        generate_struct_file(
            new_struct;
            filename = descriptor_file,
            output_directory = output_directory,
        )
    end
    data = open(descriptor_file, "r") do io
        JSON.parse(io; dicttype = Dict{String, Any})
    end

    @test data["auto_generated_structs"][end]["struct_name"] == "MyThermalStandard"
    @test isfile(joinpath(output_directory, "MyThermalStandard.jl"))
end
