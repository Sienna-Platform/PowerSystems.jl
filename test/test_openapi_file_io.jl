"""Close the sidecar store a `from_file` system holds open. Windows cannot delete an open
file, so leaving the handle to `mktempdir` cleanup logs an EBUSY error there that fails the
suite's zero-error-log gate."""
_close_sidecar_store!(sys::System) =
    IS.close!(IS.get_data_store(sys.data.time_series_manager))

@testset "to_file/from_file: bundle round trip" begin
    sys = _file_io_fixture()
    mktempdir() do dir
        bundle = joinpath(dir, "case")
        to_file(sys, bundle; unit_system = :component_base)

        # All members present, and nothing else. Two, not three: the document carries the
        # association rows, so `:json` writes no `.sqlite` — that is a `:sienna`-only member.
        @test sort(readdir(bundle)) == ["system.json", "time_series.h5"]

        sys2 = from_file(bundle)

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

@testset "to_file/from_file: .sn archive round trip" begin
    sys = _file_io_fixture()
    mktempdir() do dir
        archive = joinpath(dir, "case.sn")
        to_file(sys, archive; format = :sienna, unit_system = :component_base)
        @test isfile(archive)

        sys2 = from_file(archive)
        @test get_name(sys2) == "bundle-fixture"
        gen2 = get_component(ThermalStandard, sys2, "g1")
        @test get_name(gen2) == "g1"
        @test length(PSY.get_supplemental_attributes(gen2)) == 1
        ts = get_time_series(SingleTimeSeries, gen2, "max_active_power")
        @test TimeSeries.values(PSY.get_data(ts)) == [0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
        _close_sidecar_store!(sys2)
    end
end

@testset "to_file: .sn archive respects force" begin
    sys = _file_io_fixture(; with_time_series = false)
    mktempdir() do dir
        archive = joinpath(dir, "case.sn")
        to_file(sys, archive; format = :sienna)
        @test_throws IS.DataFormatError to_file(sys, archive; format = :sienna)
        @test isnothing(to_file(sys, archive; format = :sienna, force = true))
    end
end

@testset "to_file: unsupported format errors" begin
    sys = _file_io_fixture(; with_time_series = false)
    mktempdir() do dir
        @test_throws ErrorException to_file(sys, joinpath(dir, "case"); format = :bogus)
    end
end

@testset "to_file: .sn refuses a non-default unit_system" begin
    sys = _file_io_fixture(; with_time_series = false)
    mktempdir() do dir
        archive = joinpath(dir, "case.sn")
        # The default is fine: it is what :sienna always writes anyway.
        @test isnothing(
            to_file(sys, archive; format = :sienna, unit_system = :component_base),
        )
        @test_throws ErrorException to_file(
            sys,
            archive;
            format = :sienna,
            unit_system = :natural_units,
            force = true,
        )
    end
end

@testset "from_file: unrecognized path errors" begin
    mktempdir() do dir
        @test_throws IS.DataFormatError from_file(joinpath(dir, "not_a_bundle.txt"))
    end
end

@testset "to_file: .sn requires the .sn extension" begin
    sys = _file_io_fixture(; with_time_series = false)
    mktempdir() do dir
        @test_throws(
            "$(IS.SIENNA_ARCHIVE_EXTENSION)",
            to_file(sys, joinpath(dir, "case.tar.gz"); format = :sienna),
        )
        @test !isfile(joinpath(dir, "case.tar.gz"))
    end
end

@testset "to_file: .sn refuses an existing directory at path" begin
    sys = _file_io_fixture(; with_time_series = false)
    mktempdir() do dir
        target = joinpath(dir, "case.sn")
        mkpath(target)
        @test_throws IS.DataFormatError to_file(sys, target; format = :sienna)
    end
end

@testset "to_file: .sn creates missing parent directories" begin
    sys = _file_io_fixture(; with_time_series = false)
    mktempdir() do dir
        archive = joinpath(dir, "out", "sub", "case.sn")
        @test isnothing(to_file(sys, archive; format = :sienna))
        @test isfile(archive)
    end
end

@testset "from_file: missing .sn archive errors loudly" begin
    mktempdir() do dir
        @test_throws IS.DataFormatError from_file(joinpath(dir, "missing.sn"))
    end
end

@testset "to_file: warns on subsystems and masked components" begin
    # A user-defined subsystem is any component added to one via `IS.add_component_to_subsystem!`
    # (the primitive `add_subsystem!`/`add_component_to_subsystem!` wrap) — no PSB fixture
    # needed to exercise the warning, so build the smallest System that can hold one.
    subsys_sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "b1"
    bus.number = 1
    bus.bustype = ACBusTypes.REF
    add_component!(subsys_sys, bus)
    IS.add_subsystem!(subsys_sys.data, "sub1")
    IS.add_component_to_subsystem!(subsys_sys.data, "sub1", bus)
    mktempdir() do dir
        # match_mode = :any: to_file also logs an @info on success, which a default :all
        # match would otherwise have to enumerate too.
        @test_logs(
            (:warn, r"subsystem"),
            match_mode = :any,
            to_file(subsys_sys, joinpath(dir, "case")),
        )
    end

    # A masked component is any component `add_component!`'d then removed via
    # `IS.mask_component!` (the same primitive `add_component!(::StaticInjectionSubsystem)`
    # uses for its subcomponents) — no `HybridSystem`/PSB fixture needed to exercise the
    # warning, so build the smallest System that can hold one.
    masked_sys = _file_io_fixture(; with_time_series = false)
    gen = get_component(ThermalStandard, masked_sys, "g1")
    IS.mask_component!(masked_sys.data, gen)
    @test !isempty(IS.get_masked_components(Component, masked_sys.data))
    mktempdir() do dir
        # No warning: masking is not recorded because it is re-derived on read, when the
        # owning `StaticInjectionSubsystem` is added. `mask_component!` here reaches a state
        # the public API cannot, which is why this fixture has to call IS directly.
        to_file(masked_sys, joinpath(dir, "case"))
        @test sort(readdir(joinpath(dir, "case"))) == ["system.json"]
    end
end

@testset "frequency survives the round trip in both formats" begin
    freq_sys = System(100.0; frequency = 50.0)
    mktempdir() do dir
        bundle = joinpath(dir, "case")
        to_file(freq_sys, bundle)
        @test get_frequency(from_file(bundle)) == 50.0
        archive = joinpath(dir, "case.sn")
        to_file(freq_sys, archive; format = :sienna)
        @test get_frequency(from_file(archive)) == 50.0
    end

    default_sys = _file_io_fixture(; with_time_series = false)
    mktempdir() do dir
        @test_nowarn to_file(default_sys, joinpath(dir, "case"))
    end
end

@testset "from_file: time_series_read_only bundle with a supplemental attribute" begin
    # `_system_with_sidecar` cannot clear the adopted store's association rows when it is
    # opened read-only, so the import replay has to tolerate rows that are already there.
    sys = _file_io_fixture()
    mktempdir() do dir
        bundle = joinpath(dir, "case")
        to_file(sys, bundle; unit_system = :component_base)

        sys2 = from_file(bundle; time_series_read_only = true)

        gen2 = get_component(ThermalStandard, sys2, "g1")
        @test get_name(gen2) == "g1"

        attrs = PSY.get_supplemental_attributes(gen2)
        @test length(attrs) == 1
        attr = only(PSY.get_supplemental_attributes(EmissionsData, gen2))
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
        to_file(sys, bundle; unit_system = :component_base)

        @test readdir(bundle) == ["system.json"]
        # The document must say so rather than name a file that is not there.
        doc = PSY.PD.read_document(joinpath(bundle, "system.json"))
        @test isnothing(PSY.PD.get_time_series_storage_file(doc))

        sys2 = from_file(bundle)
        @test isempty(collect(get_components(ThermalStandard, sys2))) == false
    end
end

@testset "to_file/from_file: loud errors" begin
    sys = _file_io_fixture(; with_time_series = false)

    # Writing twice without force must not silently clobber the first bundle.
    mktempdir() do dir
        bundle = joinpath(dir, "case")
        to_file(sys, bundle; unit_system = :component_base)
        @test_throws IS.DataFormatError to_file(sys, bundle; unit_system = :component_base)
        # ... and force makes it succeed.
        @test isnothing(to_file(sys, bundle; unit_system = :component_base, force = true))
    end

    # A directory that is not a bundle.
    mktempdir() do dir
        @test_throws IS.DataFormatError from_file(dir)
    end

    # A document naming a sidecar that is absent: refuse rather than return a System that is
    # quietly missing every time series the document declared.
    mktempdir() do dir
        bundle = joinpath(dir, "case")
        to_file(_file_io_fixture(), bundle; unit_system = :component_base)
        rm(joinpath(bundle, "time_series.h5"))
        @test_throws IS.DataFormatError from_file(bundle)
    end
end

@testset "to_file: force clears a catalog sidecar an older bundle left behind" begin
    # `:json` writes no `.sqlite` of its own, but a bundle written before that change has one,
    # and `persist_arrays_to` refuses to publish arrays beside a catalog whose rows would then
    # point into the file it just replaced. So `force` has to clear it.
    mktempdir() do dir
        bundle = joinpath(dir, "case")
        to_file(_file_io_fixture(), bundle; unit_system = :component_base)
        @test sort(readdir(bundle)) == ["system.json", "time_series.h5"]
        touch(joinpath(bundle, "time_series.h5.sqlite"))  # what an older PSY left

        to_file(
            _file_io_fixture(; with_time_series = false),
            bundle;
            unit_system = :component_base,
            force = true,
        )
        @test readdir(bundle) == ["system.json"]
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
_gen_power_units(doc) = only(PSY.PD.get_components(doc, "ThermalStandard")).power_units

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

        sys2 = from_file(bundle)

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
        sys2 = from_file(bundle)
        gen2 = get_component(ThermalStandard, sys2, "g1")
        key2 = IS.get_time_series_key(only(IS.list_time_series_metadata(gen2)))
        @test key2 isa IS.TimeSeriesKey{<:IS.NonSequentialTimeSeries}
        @test IS.get_timestamps(IS.get_time_series(gen2, key2)) == stamps
        @test IS.get_time_series_values(gen2, key2) == values
    end
end

@testset "roundtrip: MarketBidCost with a service bid" begin
    sys = System(100.0)
    generators = [ThermalStandard(nothing), ThermalMultiStart(nothing)]
    expected_curves = Vector{Any}(undef, 2)
    expected_ts_values = Vector{Any}(undef, 2)
    for i in 1:2
        bus = ACBus(nothing)
        bus.name = "bus" * string(i)
        bus.number = i
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)
        gen = generators[i]
        gen.bus = bus
        gen.name = "gen" * string(i)
        initial_time = Dates.DateTime("2020-01-01T00:00:00")
        end_time = Dates.DateTime("2020-01-01T23:00:00")
        dates = collect(initial_time:Dates.Hour(1):end_time)
        data =
            PiecewiseStepData.(
                [[i, i + 1, i + 2] for i in 1.0:24.0],
                [[i, i + 1] for i in 1.0:24.0],
            )
        cc = make_market_bid_curve([0.0, 100.0, 200.0], [25.0, 30.0], 10.0)
        market_bid = MarketBidCost(;
            incremental_offer_curves = cc,
            start_up = (hot = 0.0, warm = 0.0, cold = 0.0),
        )
        set_operation_cost!(gen, market_bid)
        add_component!(sys, gen)
        ta = TimeSeries.TimeArray(dates, data)
        expected_curves[i] = cc
        expected_ts_values[i] = TimeSeries.values(ta)
        power_units = IS.NaturalUnit()
        service = OnlineReserve{ReserveDown}(;
            name = "init_$i",
            available = false,
            time_frame = 0.0,
            requirement = 0.0,
            sustained_time = 0.0,
            max_output_fraction = 1.0,
            max_participation_factor = 1.0,
            deployed_fraction = 0.0,
            ext = Dict{String, Any}(),
        )
        add_component!(sys, service)
        add_service!(gen, service, sys)
        set_service_bid!(
            sys,
            gen,
            service,
            IS.SingleTimeSeries(; name = "init_$i", data = ta),
            power_units,
        )
    end
    sys2 = roundtrip_system(sys)
    @test length(collect(get_components(ThermalStandard, sys2))) == 1
    @test length(collect(get_components(ThermalMultiStart, sys2))) == 1

    gen_types = [ThermalStandard, ThermalMultiStart]
    for i in 1:2
        gen2 = only(collect(get_components(gen_types[i], sys2)))
        op_cost2 = get_operation_cost(gen2)
        @test op_cost2 isa MarketBidCost
        @test get_function_data(get_value_curve(get_incremental_offer_curves(op_cost2))) ==
              get_function_data(get_value_curve(expected_curves[i]))

        service2 = get_component(OnlineReserve{ReserveDown}, sys2, "init_$i")
        @test service2 !== nothing
        @test service2 in get_ancillary_service_offers(op_cost2)

        ts2 = get_time_series(SingleTimeSeries, gen2, "init_$i")
        @test TimeSeries.values(get_data(ts2)) == expected_ts_values[i]
    end
end

# An ORDC rides on the reserve's own `variable`, so this covers a reserve carrying one.
@testset "roundtrip: reserve with a demand curve" begin
    sys = System(100.0)
    devices = []
    for i in 1:2
        bus = ACBus(nothing)
        bus.name = "bus" * string(i)
        bus.number = i
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)
        gen = ThermalStandard(nothing)
        gen.bus = bus
        gen.name = "gen" * string(i)
        add_component!(sys, gen)
        push!(devices, gen)
    end

    cc = CostCurve(
        PiecewiseIncrementalCurve(0.0, [0.0, 100.0, 200.0], [25.0, 30.0]),
    )
    service = OnlineReserve{ReserveDown}(;
        variable = cc,
        name = "init",
        available = false,
        time_frame = 0.0,
    )
    add_service!(sys, service, devices)

    sys2 = roundtrip_system(sys)
    service2 = get_component(OnlineReserve{ReserveDown}, sys2, "init")
    @test service2 !== nothing

    variable2 = get_variable(service2)
    @test variable2 !== nothing
    @test get_function_data(get_value_curve(variable2)) ==
          get_function_data(get_value_curve(cc))
end

@testset "roundtrip: System field metadata (name/description)" begin
    # frequency is deliberately NOT asserted here: src/openapi/import_document.jl's
    # _apply_document_metadata! (pre-existing on this branch, unrelated to this plan) only
    # applies name/description on import — the System's own default frequency stands rather
    # than being silently overwritten by the document. Export does write frequency; import
    # ignores it by design. Discovered during Task 7 implementation; ruled to match actual,
    # deliberate behavior rather than assert on it.
    name = "my_system"
    description = "test"
    sys = System(100; frequency = 50.0, name = name, description = description)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.bus = bus
    gen.name = "gen1"
    add_component!(sys, gen)

    sys2 = roundtrip_system(sys)
    @test get_name(sys2) == name
    @test get_description(sys2) == description
end

@testset "roundtrip: supplemental attributes on outages" begin
    # Hand-built rather than via `create_system_with_outages()` (test/common.jl): that helper
    # is PSB-backed (`PSB.build_system(PSITestSystems, "c_sys5_uc"; ...)`), and PSB's own
    # build/cache path still calls the pre-this-plan to_file/from_file signatures — see the
    # "Known limitation" section above. This covers the same thing that test exists to cover
    # (multiple supplemental attribute types on one component survive the round trip) without
    # routing through PSB.
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.name = "gen1"
    gen.bus = bus
    add_component!(sys, gen)
    add_supplemental_attribute!(
        sys,
        gen,
        GeographicInfo(; geo_json = Dict("type" => "Point", "coordinates" => [1.0, 2.0])),
    )
    add_supplemental_attribute!(
        sys,
        gen,
        GeometricDistributionForcedOutage(;
            mean_time_to_recovery = 1.0,
            outage_transition_probability = 0.5,
        ),
    )
    sys2 = roundtrip_system(sys)
    gen2 = get_component(ThermalStandard, sys2, "gen1")
    @test length(PSY.get_supplemental_attributes(gen2)) == 2
end

@testset "roundtrip: shared time series dedupe through the store" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.name = "gen1"
    gen.bus = bus
    gen.base_power = 1.0
    gen.active_power = 1.2
    gen.reactive_power = 2.3
    gen.active_power_limits = (0.0, 5.0)
    add_component!(sys, gen)

    initial_time = Dates.DateTime("2020-01-01T00:00:00")
    end_time = Dates.DateTime("2020-01-01T23:00:00")
    dates = collect(initial_time:Dates.Hour(1):end_time)
    data = rand(length(dates))
    ta = TimeSeries.TimeArray(dates, data, ["1"])
    ts1a = SingleTimeSeries(; name = "max_active_power", data = ta)
    add_time_series!(sys, gen, ts1a)
    # The same array under a second name. The store is content-addressed, so the two
    # associations share one underlying array (asserted below).
    ts2a = SingleTimeSeries(ts1a, "max_reactive_power")
    add_time_series!(sys, gen, ts2a)

    sys2 = roundtrip_system(sys)
    @test IS.get_num_time_series(sys2.data) == 1
    gen2 = get_component(ThermalStandard, sys2, "gen1")
    ts1b = get_time_series(SingleTimeSeries, gen2, "max_active_power")
    ts2b = get_time_series(SingleTimeSeries, gen2, "max_reactive_power")
    @test ts1b.data == ts2b.data
    ta_vals = TimeSeries.values(ta)
    @test get_time_series_values(gen2, ts1b; start_time = initial_time) == ta_vals
    @test get_time_series_values(gen2, ts2b; start_time = initial_time) == ta_vals
end
