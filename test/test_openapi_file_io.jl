"""Close the sidecar store a `from_file` system holds open. Windows cannot delete an open
file, so leaving the handle to `mktempdir` cleanup logs an EBUSY error there that fails the
suite's zero-error-log gate."""
_close_sidecar_store!(sys::System) =
    IS.close!(IS.get_data_store(sys.data.time_series_manager))

@testset "to_file/from_file: bundle round trip" begin
    sys = _file_io_fixture()
    mktempdir() do dir
        bundle = joinpath(dir, "case")
        to_file(sys, bundle; power_units = :component_base)

        # All members present, and nothing else. The InfraStore sidecar is a pair: the
        # arrays in `.h5` and its catalog in the `.sqlite` sibling.
        @test sort(readdir(bundle)) ==
              ["system.json", "time_series.h5", "time_series.h5.sqlite"]

        sys2 = from_file(System, bundle)

        # System-level metadata, which the pre-OpenAPI path carried in a _metadata.json
        # sidecar and the first cut of to_openapi dropped entirely.
        @test get_name(sys2) == "bundle-fixture"
        @test get_description(sys2) == "round-trip check"
        @test get_base_power(sys2) == get_base_power(sys)

        @test length(collect(get_components(Component, sys2))) ==
              length(collect(get_components(Component, sys)))

        gen2 = get_component(ThermalStandard, sys2, "g1")
        @test get_name(gen2) == "g1"

        @test length(PSY.get_supplemental_attributes(gen2)) == 1
        emissions = only(get_supplemental_attributes(EmissionsData, gen2))
        @test get_name(emissions) == "g1_CO2"

        ts = get_time_series(SingleTimeSeries, gen2, "max_active_power")
        @test length(ts) == 6
        @test TimeSeries.values(PSY.get_data(ts)) == [0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
        _close_sidecar_store!(sys2)
    end
end

@testset "from_file: time_series_read_only bundle with a supplemental attribute" begin
    # `_system_with_sidecar` cannot clear the adopted store's association rows when it is
    # opened read-only, so the import replay has to tolerate rows that are already there.
    sys = _file_io_fixture()
    mktempdir() do dir
        bundle = joinpath(dir, "case")
        to_file(sys, bundle; power_units = :component_base)

        sys2 = from_file(System, bundle; time_series_read_only = true)

        gen2 = get_component(ThermalStandard, sys2, "g1")
        @test get_name(gen2) == "g1"

        attrs = PSY.get_supplemental_attributes(gen2)
        @test length(attrs) == 1
        attr = first(attrs)
        @test attr isa EmissionsData
        @test get_name(attr) == "g1_CO2"

        ts = get_time_series(SingleTimeSeries, gen2, "max_active_power")
        @test length(ts) == 6
        @test TimeSeries.values(PSY.get_data(ts)) == [0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
        _close_sidecar_store!(sys2)
    end
end

@testset "to_file: a system with no time series gets no sidecar" begin
    sys = _file_io_fixture(; with_time_series = false)
    mktempdir() do dir
        bundle = joinpath(dir, "case")
        to_file(sys, bundle; power_units = :component_base)

        @test readdir(bundle) == ["system.json"]
        # The document must say so rather than name a file that is not there.
        doc = PSY.PD.read_document(joinpath(bundle, "system.json"))
        @test isnothing(PSY.PD.get_time_series_storage_file(doc))

        sys2 = from_file(System, bundle)
        @test isempty(collect(get_components(ThermalStandard, sys2))) == false
    end
end

@testset "to_file/from_file: loud errors" begin
    sys = _file_io_fixture(; with_time_series = false)

    # Writing twice without force must not silently clobber the first bundle.
    mktempdir() do dir
        bundle = joinpath(dir, "case")
        to_file(sys, bundle; power_units = :component_base)
        @test_throws IS.DataFormatError to_file(sys, bundle; power_units = :component_base)
        # ... and force makes it succeed.
        @test isnothing(to_file(sys, bundle; power_units = :component_base, force = true))
    end

    # A directory that is not a bundle.
    mktempdir() do dir
        @test_throws IS.DataFormatError from_file(System, dir)
    end

    # A document naming a sidecar that is absent: refuse rather than return a System that is
    # quietly missing every time series the document declared.
    mktempdir() do dir
        bundle = joinpath(dir, "case")
        to_file(_file_io_fixture(), bundle; power_units = :component_base)
        rm(joinpath(bundle, "time_series.h5"))
        @test_throws IS.DataFormatError from_file(System, bundle)
    end
end

@testset "to_openapi: one id space for components and supplemental attributes" begin
    # SiennaGridDB's entities table keys a row by id without its type, so an id must mean
    # exactly one thing. A private attribute counter previously issued attribute id 1
    # alongside component id 1.
    sys = _file_io_fixture(; with_time_series = false)
    doc = to_openapi(sys; power_units = :component_base)

    component_ids = Int[]
    for type_name in PSY.PD.component_type_names(doc)
        for row in PSY.PD.get_components(doc, type_name)
            push!(component_ids, Int(row.id))
        end
    end
    attribute_ids = Int[Int(a.id) for a in doc.supplemental_attributes]

    @test !isempty(attribute_ids)
    @test isempty(intersect(Set(component_ids), Set(attribute_ids)))
    @test length(unique(component_ids)) == length(component_ids)
end

@testset "ext is passthrough: any key survives a document round trip" begin
    doc_dict = make_openapi_test_doc()

    empty_ext = copy(doc_dict)
    empty_ext["ext"] = Dict{String, Any}()
    @test isempty(
        get_ext(
            get_component(ACBus, PSY.from_openapi(System, to_test_document(empty_ext)),
                "bus1"),
        ),
    )

    # Id 3 is bus1. No key is privileged: PowerSystems stores whatever the producer emitted
    # and never reads it, so an arbitrary name and a mix of value types must both survive.
    extras = Dict{String, Any}("Whatsit MW" => 1.0, "Source Label" => "zone-a", "Tol" => 3)
    with_ext = copy(doc_dict)
    with_ext["ext"] = Dict{String, Any}("3" => extras)

    sys = PSY.from_openapi(System, to_test_document(with_ext))
    @test get_ext(get_component(ACBus, sys, "bus1")) == extras
    @test isempty(get_ext(get_component(ACBus, sys, "bus2")))

    # And back out again, unchanged. A component's document id is its IS component id, which
    # import set from the document, so bus1 is id 3 on the way out as well.
    exported = to_openapi(sys; power_units = :natural_units)
    @test PSY.PD.get_ext(exported, 3) == extras
    @test isempty(PSY.PD.get_ext(exported, 4))
end

"""The `power_units` stamp on the sole exported `ThermalStandard` blob, the regression guard
for [`to_openapi`](@ref)'s uniform per-export stamp (no document-level `unit_system` exists to
assert against instead)."""
_gen_power_units(doc) =
    only(PSY.PD.get_components(doc, "ThermalStandard")).power_units.value

@testset "export needs no ledger: a hand-built System serializes" begin
    # The unit-system assertions use the time-series-free fixture so that `to_openapi` needs
    # no sidecar path; the bundle round trip below covers the time-series case.
    sys = _file_io_fixture(; with_time_series = false)

    # No ledger is written, and nothing is stashed in `ext` on the way out.
    @test isempty(get_ext(sys))
    @test !haskey(get_ext(sys), "_openapi_ledger")

    # The default path works with no ledger present. This is the regression guard.
    @test _gen_power_units(to_openapi(sys)) == "COMPONENT_BASE"
    @test isempty(get_ext(sys))

    # Both remaining conventions are reachable on the same ledger-free System, and they are
    # exactly the document schema's two legal values.
    for (sym, declared) in
        ((:component_base, "COMPONENT_BASE"), (:natural_units, "NATURAL_UNITS"))
        @test _gen_power_units(to_openapi(sys; power_units = sym)) == declared
    end

    # `:original` is gone rather than quietly reinterpreted: a System records no unit system
    # of its own, so there is nothing left to reproduce it from.
    @test_throws ErrorException to_openapi(sys; power_units = :original)

    # A hand-built System with time series writes a bundle, reads back, and re-exports.
    with_ts = _file_io_fixture()
    mktempdir() do dir
        bundle = joinpath(dir, "handbuilt")
        to_file(with_ts, bundle)

        sys2 = from_file(System, bundle)

        # Import writes no ledger either, so `ext` is clean on a document-built System too.
        @test isempty(get_ext(sys2))
        @test !haskey(get_ext(sys2), "_openapi_ledger")

        gen2 = get_component(ThermalStandard, sys2, "g1")
        @test get_name(gen2) == "g1"
        ts = get_time_series(SingleTimeSeries, gen2, "max_active_power")
        @test TimeSeries.values(PSY.get_data(ts)) == [0.1, 0.2, 0.3, 0.4, 0.5, 0.6]

        # And the imported System re-exports. Under the ledger this was the only System that
        # could use `:original`; now it takes the same path as any other.
        again = joinpath(dir, "handbuilt2")
        to_file(sys2, again)
        @test isfile(joinpath(again, "system.json"))
        @test _gen_power_units(PSY.PD.read_document(joinpath(again, "system.json"))) ==
              "COMPONENT_BASE"
    end
end

@testset "NonSequentialTimeSeries round trips with no grid columns" begin
    # An irregular series has no `initial + k * resolution` grid, and the schema says so by
    # giving `NonSequentialTimeSeries` its own document type that simply has no
    # `initial_timestamp` / `resolution` / forecast fields — rather than one row type
    # carrying them all as nullable. This guards the whole irregular path.
    sys = _file_io_fixture(; with_time_series = false)
    gen = get_component(ThermalStandard, sys, "g1")
    stamps = [
        Dates.DateTime(2024, 1, 1),
        Dates.DateTime(2024, 1, 1, 3),
        Dates.DateTime(2024, 1, 2),
    ]
    values = [1.0, 2.0, 3.0]
    add_time_series!(
        sys, gen,
        IS.NonSequentialTimeSeries("irregular", TimeSeries.TimeArray(stamps, values)),
    )
    # The kind is in the key's type parameter now, not in a separate key type.
    @test IS.get_time_series_type(first(IS.list_time_series_metadata(gen))) <:
          IS.NonSequentialTimeSeries

    mktempdir() do dir
        bundle = joinpath(dir, "irregular")
        to_file(sys, bundle)

        assoc = only(
            PSY.PD.read_document(joinpath(bundle, "system.json")).time_series_associations,
        )
        # `TimeSeriesAssociation` is the oneOf wrapper; the discriminator picks the concrete
        # row type on read, so getting the right type back is itself the assertion that the
        # discriminator round-tripped.
        row = assoc.value
        @test row isa PSY.PTS.NonSequentialTimeSeries
        @test row.time_series_type == "NonSequentialTimeSeries"

        # The grid columns are ABSENT, not null: the type does not declare them. `length` and
        # `name` are what identify the row, because that is all an irregular series holds.
        for absent in (:initial_timestamp, :resolution, :horizon, :interval, :count)
            @test !hasfield(typeof(row), absent)
        end
        @test row.length == length(values)
        @test row.name == "irregular"
        @test row.owner_id == IS.get_id(gen)

        # Element typing comes off the catalog, which is the only thing that knows how the
        # array was laid out; a scalar-valued series has an empty per-step shape.
        @test row.element_type == "f64"
        @test isempty(row.element_shape)
        # `uri`/`data_hash` are the store's own content hash, never a caller-supplied
        # locator.
        @test occursin(r"^[0-9a-f]{64}$", row.uri)
        @test row.data_hash == row.uri

        # The timestamp vector lives in the store, not the document, so it must come back
        # from the adopted sidecar exactly.
        sys2 = from_file(System, bundle)
        gen2 = get_component(ThermalStandard, sys2, "g1")
        key2 = IS.get_time_series_key(only(IS.list_time_series_metadata(gen2)))
        @test key2 isa IS.TimeSeriesKey{<:IS.NonSequentialTimeSeries}
        @test IS.get_timestamps(IS.get_time_series(gen2, key2)) == stamps
        @test IS.get_time_series_values(gen2, key2) == values
    end
end
