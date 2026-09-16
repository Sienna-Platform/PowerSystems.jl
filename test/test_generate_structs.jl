# No descriptor-to-generated consistency check runs here: `StructGeneration.test_generated_structs`
# pairs files and lines with `zip`, which truncates, so appended generated content is never
# compared. Inspect regeneration diffs by hand until it is rewritten.

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
        IS.generate_struct_file(
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

@testset "OpenAPI converter codegen: absent openapi_type is untouched" begin
    # Hard invariant: a descriptor entry without `openapi_type` must never gain a converter,
    # even when another entry in the same generation call is annotated (proven below by
    # generating both together, not this struct alone).
    outdir = mktempdir()
    data = [
        Dict{String, Any}(
            "struct_name" => "OATestPlainBus",
            "supertype" => "InfrastructureSystemsComponent",
            "fields" => [
                Dict{String, Any}("name" => "name", "data_type" => "String"),
            ],
        ),
        Dict{String, Any}(
            "struct_name" => "OATestPlainDevice",
            "supertype" => "InfrastructureSystemsComponent",
            "openapi_type" => "OATestPlainDevice",
            "fields" => [
                Dict{String, Any}("name" => "name", "data_type" => "String"),
                Dict{String, Any}("name" => "bus", "data_type" => "OATestPlainBus"),
            ],
        ),
    ]
    PowerSystems.StructGeneration.generate_structs(outdir, data; print_results = false)

    plain_bus = read(joinpath(outdir, "OATestPlainBus.jl"), String)
    @test !occursin("from_openapi", plain_bus)
    @test !occursin("_FROM_STRING", plain_bus)

    annotated = read(joinpath(outdir, "OATestPlainDevice.jl"), String)
    @test occursin("from_openapi", annotated)
end

@testset "OpenAPI converter codegen: annotated struct emits both Val methods" begin
    outdir = mktempdir()
    data = [
        Dict{String, Any}(
            "struct_name" => "OATestBus",
            "supertype" => "InfrastructureSystemsComponent",
            "fields" => [
                Dict{String, Any}("name" => "name", "data_type" => "String"),
            ],
        ),
        Dict{String, Any}(
            "struct_name" => "OATestDevice",
            "docstring" => "Toy device exercising every OpenAPI converter field kind.",
            "supertype" => "InfrastructureSystemsComponent",
            "openapi_type" => "OATestDevice",
            "fields" => [
                Dict{String, Any}("name" => "name", "data_type" => "String"),
                Dict{String, Any}("name" => "bus", "data_type" => "OATestBus"),
                Dict{String, Any}(
                    "name" => "active_power",
                    "data_type" => "Float64",
                    "needs_conversion" => true,
                    "conversion_unit" => ":mva",
                ),
                Dict{String, Any}(
                    "name" => "rating_b",
                    "data_type" => "Union{Nothing, Float64}",
                    "needs_conversion" => true,
                    "conversion_unit" => ":mva",
                    "default" => "nothing",
                ),
                Dict{String, Any}("name" => "base_power", "data_type" => "Float64"),
                Dict{String, Any}("name" => "base_voltage", "data_type" => "Float64"),
                Dict{String, Any}(
                    "name" => "impedance_limits",
                    "data_type" => "MinMax",
                    "needs_conversion" => true,
                    "conversion_unit" => ":ohm",
                ),
                Dict{String, Any}(
                    "name" => "optional_limits",
                    "data_type" => "Union{Nothing, MinMax}",
                    "needs_conversion" => true,
                    "conversion_unit" => ":mva",
                    "default" => "nothing",
                ),
                Dict{String, Any}("name" => "status", "data_type" => "OATestStatus"),
                Dict{String, Any}(
                    "name" => "operation_cost",
                    "data_type" => "OperationalCost",
                ),
                Dict{String, Any}(
                    "name" => "ext",
                    "data_type" => "Dict{String, Any}",
                    "null_value" => "Dict{String, Any}()",
                    "default" => "Dict{String, Any}()",
                ),
                Dict{String, Any}(
                    "name" => "internal",
                    "data_type" => "InfrastructureSystemsInternal",
                    "internal_default" => "InfrastructureSystemsInternal()",
                ),
            ],
        ),
    ]
    PowerSystems.StructGeneration.generate_structs(outdir, data; print_results = false)
    gen = read(joinpath(outdir, "OATestDevice.jl"), String)

    # The generated code must parse as valid Julia syntax.
    @test Meta.parse("begin\n" * gen * "\nend") isa Expr

    device_start = findfirst("ComponentBaseUnit", gen)
    natural_start = findfirst("NaturalUnit", gen)
    @test !isnothing(device_start)
    @test !isnothing(natural_start)
    device_body = gen[first(device_start):(first(natural_start) - 1)]
    natural_body = gen[first(natural_start):end]

    # Enum: converted through the scoped enum's own string constructor — no per-enum
    # lookup table is emitted anywhere in the generated file.
    @test !occursin("_FROM_STRING", gen)
    @test !occursin("_TO_STRING", gen)
    @test occursin("status = OATestStatus(po.status.value),", device_body)
    @test occursin("status = OATestStatus(po.status.value),", natural_body)
    # ... and the export direction is the inverse: wraps `string` on the enum value in the
    # PO enum's own validating wrapper type.
    @test occursin("status = PO.OATestStatus(string(get_status(value))),", gen)

    # Reference: `resolve_ref(refs, po.<name>, <PSY type>)`, identical in both methods. Not
    # `refs[po.<name>]` — a schema-optional reference the document omits arrives as
    # `nothing`, and `refs[nothing]` is a MethodError. The third argument is the type the
    # descriptor declares, which `refs`' `Dict{Int, Any}` cannot supply.
    @test occursin("bus = resolve_ref(refs, po.bus, OATestBus),", device_body)
    @test occursin("bus = resolve_ref(refs, po.bus, OATestBus),", natural_body)

    # Cost hook: identical in both methods, asserting the declared field type — the call
    # itself infers as `Any`. `operation_cost::OperationalCost` (abstract) is a `oneOf`
    # wrapper on the wire, unwrapped via `.value` before the cast.
    @test occursin(
        "operation_cost = convert_cost(po.operation_cost.value)::OperationalCost,",
        device_body,
    )
    @test occursin(
        "operation_cost = convert_cost(po.operation_cost.value)::OperationalCost,",
        natural_body,
    )

    # skip fields never appear as constructor kwargs inside either method.
    @test !occursin("ext =", device_body)
    @test !occursin("internal =", device_body)
    @test !occursin("ext =", natural_body)
    @test !occursin("internal =", natural_body)

    # Scalar power conversion: component-base is pass-through; natural-units divides by
    # the component's own base_power (S_base).
    @test occursin("active_power = po.active_power,", device_body)
    @test occursin("active_power = po.active_power / po.base_power,", natural_body)

    # Nullable scalar power conversion with a descriptor default: both methods fall back to
    # that default through `_or_default`, which dispatches on `Union{Nothing, IC.Absent}` —
    # an omitted wire value is distinct from `Nothing`, so a `nothing`-only guard misses it.
    # The natural-units method passes `(/)` and the base so the division runs only on a
    # value that is present.
    @test occursin("rating_b = _or_default(po.rating_b, nothing),", device_body)
    @test occursin(
        "rating_b = _or_default(po.rating_b, nothing, (/), po.base_power),",
        natural_body,
    )

    # Compound IMPEDANCE conversion: both methods rebuild through the alias' extraction
    # helper (the PO type is never PSY's NamedTuple alias, and it declares the field `Any`,
    # so inline member access would be a dynamic getproperty chain); natural-units divides
    # each member by Z_base = V_base^2/S_base, passing `/` so the arithmetic stays division.
    @test occursin("impedance_limits = _minmax_from_po(po.impedance_limits),", device_body)
    @test occursin(
        "impedance_limits = _minmax_from_po(po.impedance_limits, (/), (po.base_voltage^2 / po.base_power)),",
        natural_body,
    )

    # Nullable compound power conversion: no emitted nothing-guard in either method — the
    # helper's ::Nothing method is the guard, so nullability no longer changes the
    # expression.
    @test occursin("optional_limits = _minmax_from_po(po.optional_limits),", device_body)
    @test occursin(
        "optional_limits = _minmax_from_po(po.optional_limits, (/), po.base_power),",
        natural_body,
    )
end

@testset "OpenAPI converter codegen: openapi_unit pu override" begin
    # No base_power/base_voltage field on this struct at all — proving the override
    # skips S_base/Z_base resolution entirely rather than merely skipping the arithmetic
    # (a plain :none conversion would still be free of base fields, but a real :ohm/:mva
    # conversion_unit would normally demand them; see openapi_base_exprs).
    outdir = mktempdir()
    data = [
        Dict{String, Any}(
            "struct_name" => "OATestPuDevice",
            "supertype" => "InfrastructureSystemsComponent",
            "openapi_type" => "OATestPuDevice",
            "fields" => [
                Dict{String, Any}("name" => "name", "data_type" => "String"),
                Dict{String, Any}(
                    "name" => "r",
                    "data_type" => "Float64",
                    "needs_conversion" => true,
                    "conversion_unit" => ":ohm",
                    "openapi_unit" => "pu",
                ),
                Dict{String, Any}(
                    "name" => "impedance_limits",
                    "data_type" => "MinMax",
                    "needs_conversion" => true,
                    "conversion_unit" => ":siemens",
                    "openapi_unit" => "pu",
                ),
            ],
        ),
    ]
    PowerSystems.StructGeneration.generate_structs(outdir, data; print_results = false)
    gen = read(joinpath(outdir, "OATestPuDevice.jl"), String)
    @test Meta.parse("begin\n" * gen * "\nend") isa Expr

    device_start = findfirst("ComponentBaseUnit", gen)
    natural_start = findfirst("NaturalUnit", gen)
    device_body = gen[first(device_start):(first(natural_start) - 1)]
    natural_body = gen[first(natural_start):end]

    # Scalar pu-override: identity in both methods, no division by Z_base.
    @test occursin("r = po.r,", device_body)
    @test occursin("r = po.r,", natural_body)

    # Compound pu-override: still rebuilt through the extraction helper (PO type isn't
    # PSY's NamedTuple alias) but never scaled — no `op`/`base` arguments in either method.
    @test occursin("impedance_limits = _minmax_from_po(po.impedance_limits),", device_body)
    @test occursin("impedance_limits = _minmax_from_po(po.impedance_limits),", natural_body)

    # An unmapped openapi_unit value must error rather than be silently ignored.
    bad_value = [
        Dict{String, Any}(
            "struct_name" => "OATestBadUnitValue",
            "supertype" => "InfrastructureSystemsComponent",
            "openapi_type" => "OATestBadUnitValue",
            "fields" => [
                Dict{String, Any}("name" => "name", "data_type" => "String"),
                Dict{String, Any}(
                    "name" => "z",
                    "data_type" => "Float64",
                    "needs_conversion" => true,
                    "conversion_unit" => ":mva",
                    "openapi_unit" => "mva",
                ),
            ],
        ),
    ]
    @test_throws IS.DataFormatError PowerSystems.StructGeneration.generate_structs(
        mktempdir(),
        bad_value;
        print_results = false,
    )

    # openapi_unit on a struct without openapi_type is descriptor noise, not a no-op.
    orphan = [
        Dict{String, Any}(
            "struct_name" => "OATestOrphanUnit",
            "supertype" => "InfrastructureSystemsComponent",
            "fields" => [
                Dict{String, Any}("name" => "name", "data_type" => "String"),
                Dict{String, Any}(
                    "name" => "z",
                    "data_type" => "Float64",
                    "openapi_unit" => "pu",
                ),
            ],
        ),
    ]
    @test_throws IS.DataFormatError PowerSystems.StructGeneration.generate_structs(
        mktempdir(),
        orphan;
        print_results = false,
    )
end

@testset "OpenAPI converter codegen: generation-time errors, never partial output" begin
    base_fields = () -> [Dict{String, Any}("name" => "name", "data_type" => "String")]

    # An indeterminate field kind (not scalar/compound/reference/plausible-enum) must
    # error rather than silently guess.
    indeterminate = [
        Dict{String, Any}(
            "struct_name" => "OATestBadKind",
            "supertype" => "InfrastructureSystemsComponent",
            "openapi_type" => "OATestBadKind",
            "fields" => vcat(
                base_fields(),
                [Dict{String, Any}("name" => "z", "data_type" => "Complex{Float64}")],
            ),
        ),
    ]
    @test_throws IS.DataFormatError PowerSystems.StructGeneration.generate_structs(
        mktempdir(),
        indeterminate;
        print_results = false,
    )

    # An unmapped conversion_unit on a needs_conversion field must error.
    bad_conversion_unit = [
        Dict{String, Any}(
            "struct_name" => "OATestBadConversionUnit",
            "supertype" => "InfrastructureSystemsComponent",
            "openapi_type" => "OATestBadConversionUnit",
            "fields" => vcat(
                base_fields(),
                [
                    Dict{String, Any}(
                        "name" => "z",
                        "data_type" => "Float64",
                        "needs_conversion" => true,
                        "conversion_unit" => ":unknown_unit",
                    ),
                ],
            ),
        ),
    ]
    @test_throws IS.DataFormatError PowerSystems.StructGeneration.generate_structs(
        mktempdir(),
        bad_conversion_unit;
        print_results = false,
    )

    # An IMPEDANCE/ADMITTANCE conversion needs the struct's own base_voltage field to
    # resolve V_base; without it (and no reference-chain resolution implemented), error.
    missing_base_voltage = [
        Dict{String, Any}(
            "struct_name" => "OATestMissingVBase",
            "supertype" => "InfrastructureSystemsComponent",
            "openapi_type" => "OATestMissingVBase",
            "fields" => vcat(
                base_fields(),
                [
                    Dict{String, Any}("name" => "base_power", "data_type" => "Float64"),
                    Dict{String, Any}(
                        "name" => "z",
                        "data_type" => "MinMax",
                        "needs_conversion" => true,
                        "conversion_unit" => ":ohm",
                    ),
                ],
            ),
        ),
    ]
    @test_throws IS.DataFormatError PowerSystems.StructGeneration.generate_structs(
        mktempdir(),
        missing_base_voltage;
        print_results = false,
    )

    # A parametric + openapi_type combination is out of scope — refuse rather than emit a
    # converter for the wrong (UnionAll) type.
    parametric_openapi = [
        Dict{String, Any}(
            "struct_name" => "OATestParametric",
            "supertype" => "InfrastructureSystemsComponent",
            "openapi_type" => "OATestParametric",
            "parametric" => "ReserveDirection",
            "fields" => base_fields(),
        ),
    ]
    @test_throws IS.DataFormatError PowerSystems.StructGeneration.generate_structs(
        mktempdir(),
        parametric_openapi;
        print_results = false,
    )
end
