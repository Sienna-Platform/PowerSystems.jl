# End-to-end proof that a document written by another package loads completely.
#
# PowerTableDataParser builds an `OpenAPISystem` from RTS-GMLC table data and writes it as
# `system.json` plus its InfraStore sidecar pair. Nothing in PowerSystems participates in
# that build, so the bundle is an external, fully specified document: hundreds of time series
# at two resolutions, supplemental attributes (bus GeographicInfo, generator emissions and
# outages), and an id space PSY did not assign.
#
# Cycle 1 asserts PSY reads it: per-type component counts, every association row resolving to
# its owner, exact values and timestamps for every staged series, the series' labels, and the
# supplemental attribute augmented into the document by hand. Cycle 2 writes the loaded System
# back out with PSY's own writer and re-reads it, asserting the same things again — what PSY
# read is complete enough to write an equivalent document.
#
# Assumes the usings in runtests.jl (Test, Dates, TimeSeries, JSON, IS, PSY) and imports what
# it adds itself: PowerTableDataParser and the artifact plumbing for its fixture.

import PowerTableDataParser
import Artifacts
import Pkg

const PDP = PowerTableDataParser

"""
The `CaseData` fixture tree pinned by PowerTableDataParser's own test artifact.

Read out of PTDP's `test/Artifacts.toml` rather than hardcoded, so this test follows the
fixture that package's tests are written against.
"""
function _ptdp_e2e_case_data_dir()
    artifacts_toml = joinpath(pkgdir(PowerTableDataParser), "test", "Artifacts.toml")
    isfile(artifacts_toml) ||
        error("PowerTableDataParser ships no test/Artifacts.toml at $artifacts_toml")
    hash = Artifacts.artifact_hash("CaseData", artifacts_toml)
    isnothing(hash) && error("no CaseData artifact declared in $artifacts_toml")
    if !Artifacts.artifact_exists(hash)
        Pkg.Artifacts.ensure_artifact_installed("CaseData", artifacts_toml)
    end
    root = Artifacts.artifact_path(hash)
    return only(filter(isdir, readdir(root; join = true)))
end

const _PTDP_E2E_TS_TYPES = Dict(
    "SingleTimeSeries" => IS.SingleTimeSeries,
    "NonSequentialTimeSeries" => IS.NonSequentialTimeSeries,
    "Deterministic" => IS.Deterministic,
    "DeterministicSingleTimeSeries" => IS.DeterministicSingleTimeSeries,
    "Probabilistic" => IS.Probabilistic,
    "Scenarios" => IS.Scenarios,
)

"""Period for a document row's ISO-8601 `resolution`, the inverse of the store encoder's
unit-style spelling (`PT1H`, `P1D`, `PT0.5S`)."""
function _ptdp_e2e_period(iso::AbstractString)
    m = match(
        r"^P(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$", iso,
    )
    (isnothing(m) || iso == "P") &&
        error("unhandled ISO-8601 duration in a document row: $iso")
    days, hours, minutes, seconds = m.captures
    milliseconds = 0
    isnothing(days) || (milliseconds += 86_400_000 * parse(Int, days))
    isnothing(hours) || (milliseconds += 3_600_000 * parse(Int, hours))
    isnothing(minutes) || (milliseconds += 60_000 * parse(Int, minutes))
    isnothing(seconds) || (milliseconds += round(Int, 1000 * parse(Float64, seconds)))
    return Dates.Millisecond(milliseconds)
end

"""
The staged series keyed by the identity a document row carries.

The key is what the store keys a series by, so a collision would mean two staged rows
describing one stored series — a fixture problem, not something to collapse.
"""
function _ptdp_e2e_staged_index(rows)
    index = Dict{Tuple{Int, String, Dates.Millisecond}, IS.SingleTimeSeries}()
    for row in rows
        key = (
            row.owner_id,
            IS.get_name(row.series),
            Dates.Millisecond(IS.get_resolution(row.series)),
        )
        if haskey(index, key)
            error("two staged series share (owner_id, name, resolution) = $key")
        end
        index[key] = row.series
    end
    return index
end

"""
Resolve a document time-series row's owner in `sys`.

Components and supplemental attributes share one id space, so `owner_id` alone does not say
which kind of owner it names — `owner_category` picks the accessor, the same way PSY's own
export/import code branches on it (`_export_all_time_series` in `export_document.jl`)."""
function _ptdp_e2e_resolve_owner(sys::System, row)
    owner_id = Int(row.owner_id)
    row.owner_category == "Component" && return IS.get_component(sys, owner_id)
    row.owner_category == "SupplementalAttribute" &&
        return PSY.get_supplemental_attribute(sys, owner_id)
    return error(
        "unmapped owner_category on a document time series row: $(row.owner_category)",
    )
end

"""A document's time series rows under the same key, unwrapped from the `oneOf`."""
function _ptdp_e2e_doc_index(doc)
    index = Dict{Tuple{Int, String, Dates.Millisecond}, Any}()
    for assoc in doc.time_series_associations
        row = assoc.value
        key = (Int(row.owner_id), row.name, _ptdp_e2e_period(row.resolution))
        if haskey(index, key)
            error("two document rows share (owner_id, name, resolution) = $key")
        end
        index[key] = row
    end
    return index
end

"""Per-type component counts of a document."""
function _ptdp_e2e_doc_component_counts(doc)
    return Dict(
        type_name => length(PSY.PD.get_components(doc, type_name))
        for type_name in PSY.PD.component_type_names(doc)
    )
end

"""
Per-concrete-type component counts of a System, by the same names the document uses.

`TransformerCircuit` is a `DeviceParameter` embedded in its owning transformer rather than a
standalone System component, so `get_components` cannot see it; it is counted through its
owners, exactly as PSY's own exporter enumerates it (`_plan_components` in
`src/openapi/export_document.jl`).
"""
function _ptdp_e2e_system_component_counts(sys::System)
    # Keyed by `nameof`, which strips type parameters: a document names a parametric service
    # by its bare type name, so `OnlineReserve{ReserveUp, NaturalUnit}` must count as
    # "OnlineReserve". This is why the IS `*_counts_by_type` helpers cannot stand in here —
    # they key by `strip_module_name`, which keeps the parameters.
    counts = Dict{String, Int}()
    for component in get_components(Component, sys)
        name = string(nameof(typeof(component)))
        counts[name] = get(counts, name, 0) + 1
    end
    circuits = length(get_components(TwoWindingTransformer, sys))
    for transformer in get_components(ThreeWindingTransformer, sys)
        circuits += length(get_circuits(transformer))
    end
    if !iszero(circuits)
        counts["TransformerCircuit"] = circuits
    end
    return counts
end

"""
Give one `ThermalStandard` in `sys` a `MarketBidTimeSeriesCost` (`minimum_energy_offer`, `shut_down`,
`start_up`, and both offer curves all time-series-backed, via `make_market_bid_ts_curve`) and
another a `FuelCurve` with `fuel_cost_time_series` set instead of a fixed `fuel_cost`. Both
generators' new series are staged onto `sys`'s own (adopted) time series store, exactly like
any other `add_time_series!` call a user would make.

Every new series is a plain `SingleTimeSeries` — the same time-series type the PTDP fixture's
own staged series use (`_ptdp_e2e_staged_index`) — so `_ptdp_e2e_verify_time_series` can be
extended to cover them too (`IS.get_array`, which that helper calls, is only defined for
`SingleTimeSeries`/`NonSequentialTimeSeries`, not `Deterministic`). Only key round-tripping is
under test here, not time-varying value resolution, so a constant-valued static series suffices.

Returns `(market_bid_gen_name, keys, fuel_gen_name, fuel_key, new_staged)` — the original
`TimeSeriesKey`s (carrying their `association_id`) to compare a round-tripped `System`'s costs
back against, and `new_staged`, a `staged`-shaped `Dict` of the series just added, to merge into
`staged_with_attr` before the next `_ptdp_e2e_verify_time_series` call.
"""
function _ptdp_e2e_attach_ts_costs!(sys::System)
    thermals = collect(get_components(ThermalStandard, sys))
    @test length(thermals) >= 2
    market_bid_gen = thermals[1]
    fuel_gen = thermals[2]
    market_bid_id = IS.get_id(market_bid_gen)
    fuel_id = IS.get_id(fuel_gen)

    timestamps =
        collect(Dates.DateTime(2020, 1, 1):Dates.Hour(1):Dates.DateTime(2020, 1, 1, 23))
    pwl_values = vcat(
        [PiecewiseStepData([1.0, 3.0, 5.0], [2.0, 4.0])],
        fill(PiecewiseStepData([2.0, 4.0, 6.0], [3.0, 5.0]), 23),
    )
    linear_values = fill(LinearFunctionData(1.0, 0.0), 24)
    start_up_values = fill((100.0, 150.0, 200.0), 24)
    fuel_values = fill(3.3, 24)

    _sts(name, values) =
        IS.SingleTimeSeries(; name = name, data = TimeSeries.TimeArray(timestamps, values))

    inc_ts = _sts("inc_offer_mb", pwl_values)
    dec_ts = _sts("dec_offer_mb", pwl_values)
    no_load_ts = _sts("no_load_mb", linear_values)
    shut_down_ts = _sts("shut_down_mb", linear_values)
    start_up_ts = _sts("start_up_mb", start_up_values)
    fuel_ts = _sts("fuel_cost_ts", fuel_values)

    inc_key = add_time_series!(sys, market_bid_gen, inc_ts)
    dec_key = add_time_series!(sys, market_bid_gen, dec_ts)
    no_load_key = add_time_series!(sys, market_bid_gen, no_load_ts)
    shut_down_key = add_time_series!(sys, market_bid_gen, shut_down_ts)
    start_up_key = add_time_series!(sys, market_bid_gen, start_up_ts)
    fuel_key = add_time_series!(sys, fuel_gen, fuel_ts)

    market_bid_cost = MarketBidTimeSeriesCost(;
        minimum_energy_offer = TimeSeriesLinearCurve(no_load_key),
        start_up = start_up_key,
        shut_down = TimeSeriesLinearCurve(shut_down_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
    )
    set_operation_cost!(market_bid_gen, market_bid_cost)

    old_variable = get_variable_operation_cost(get_operation_cost(fuel_gen))
    new_variable = FuelCurve(;
        value_curve = get_value_curve(old_variable),
        power_units = get_power_units(old_variable),
        fuel_cost_time_series = fuel_key,
        startup_fuel_offtake = IS.get_startup_fuel_offtake(old_variable),
        vom_cost = get_vom_cost(old_variable),
    )
    old_cost = get_operation_cost(fuel_gen)
    set_operation_cost!(
        fuel_gen,
        ThermalGenerationCost(;
            fixed = get_fixed(old_cost),
            shut_down = get_shut_down(old_cost),
            start_up = get_start_up(old_cost),
            variable_operation_cost = new_variable,
        ),
    )

    keys = (
        incremental_offer_curves = inc_key, decremental_offer_curves = dec_key,
        minimum_energy_offer = no_load_key, shut_down = shut_down_key,
        start_up = start_up_key,
    )
    resolution = Dates.Millisecond(Dates.Hour(1))
    new_staged = Dict(
        (market_bid_id, "inc_offer_mb", resolution) => inc_ts,
        (market_bid_id, "dec_offer_mb", resolution) => dec_ts,
        (market_bid_id, "no_load_mb", resolution) => no_load_ts,
        (market_bid_id, "shut_down_mb", resolution) => shut_down_ts,
        (market_bid_id, "start_up_mb", resolution) => start_up_ts,
        (fuel_id, "fuel_cost_ts", resolution) => fuel_ts,
    )
    return (get_name(market_bid_gen), keys, get_name(fuel_gen), fuel_key, new_staged)
end

"""Assert `sys`'s market-bid generator and fuel-curve generator carry back exactly the
`TimeSeriesKey`s (association_id included) that `_ptdp_e2e_attach_ts_costs!` originally set."""
function _ptdp_e2e_check_ts_costs(
    sys::System,
    market_bid_gen_name,
    keys,
    fuel_gen_name,
    fuel_key,
)
    market_bid_gen = get_component(ThermalStandard, sys, market_bid_gen_name)
    cost = get_operation_cost(market_bid_gen)
    @test cost isa MarketBidTimeSeriesCost
    @test get_start_up(cost) == keys.start_up
    @test IS.get_time_series_key(get_minimum_energy_offer(cost)) ==
          keys.minimum_energy_offer
    @test IS.get_time_series_key(get_shut_down(cost)) == keys.shut_down
    @test IS.get_time_series_key(get_value_curve(get_incremental_offer_curves(cost))) ==
          keys.incremental_offer_curves
    @test IS.get_time_series_key(get_value_curve(get_decremental_offer_curves(cost))) ==
          keys.decremental_offer_curves

    fuel_gen = get_component(ThermalStandard, sys, fuel_gen_name)
    variable = get_variable_operation_cost(get_operation_cost(fuel_gen))
    @test variable isa FuelCurve
    @test isnothing(get_fuel_cost(variable))
    @test IS.get_fuel_cost_time_series(variable) == fuel_key
    return nothing
end

"""Per-type supplemental attribute counts declared by a document's association rows."""
function _ptdp_e2e_doc_attribute_counts(doc)
    counts = Dict{String, Int}()
    for assoc in doc.supplemental_attribute_associations
        counts[assoc.attribute_type] = get(counts, assoc.attribute_type, 0) + 1
    end
    return counts
end

function _ptdp_e2e_system_attribute_counts(sys::System)
    counts = Dict{String, Int}()
    for attribute in get_supplemental_attributes(IS.SupplementalAttribute, sys)
        name = string(nameof(typeof(attribute)))
        counts[name] = get(counts, name, 0) + 1
    end
    return counts
end

"""
Every time series a document declares, resolved on `sys` and compared value by value with the
staged series it came from.

Returns the `(owner_id, name, time_series_type)` triples the document declared, so two
documents can be compared as sets.
"""
function _ptdp_e2e_verify_time_series(doc, sys::System, staged, label::AbstractString)
    doc_index = _ptdp_e2e_doc_index(doc)
    @test Set(keys(doc_index)) == Set(keys(staged))

    triples = Set{Tuple{Int, String, String}}()
    value_mismatches = Tuple{Int, String, String}[]
    label_mismatches = Tuple{Int, String, String}[]
    for key in sort!(collect(keys(doc_index)))
        owner_id, name, resolution = key
        row = doc_index[key]
        series = staged[key]
        push!(triples, (owner_id, name, row.time_series_type))

        owner = _ptdp_e2e_resolve_owner(sys, row)
        @test string(nameof(typeof(owner))) == row.owner_type
        loaded = IS.get_time_series(
            _PTDP_E2E_TS_TYPES[row.time_series_type],
            owner,
            name;
            resolution = resolution,
        )

        # (b) the row's own columns describe what came back.
        @test length(loaded) == row.length
        @test Dates.Millisecond(IS.get_resolution(loaded)) == resolution
        @test IS.get_initial_timestamp(loaded) == Dates.DateTime(row.initial_timestamp)

        # (c) values and timestamps, exactly, against the series PTDP staged.
        expected_values = IS.get_array(series)
        loaded_array = IS.get_time_array(loaded)
        values_ok = TimeSeries.values(loaded_array) == expected_values
        stamps_ok =
            TimeSeries.timestamp(loaded_array) ==
            TimeSeries.timestamp(IS.get_time_array(series))
        if !values_ok
            push!(value_mismatches, (owner_id, name, "values"))
        end
        if !stamps_ok
            push!(value_mismatches, (owner_id, name, "timestamps"))
        end
        @test values_ok
        @test stamps_ok

        # (d) the labels the store carries as columns, on the document row and the series.
        labels_ok =
            IS.get_units(loaded) == row.units &&
            IS.get_quantity_kind(loaded) == row.quantity_kind &&
            IS.get_units(loaded) == IS.get_units(series) &&
            IS.get_quantity_kind(loaded) == IS.get_quantity_kind(series) &&
            IS.get_unit_system(loaded) == IS.get_unit_system(series)
        if !labels_ok
            push!(label_mismatches, (owner_id, name, "labels"))
        end
        @test labels_ok
    end

    if !isempty(value_mismatches)
        @error "$label: time series data mismatches" value_mismatches
    end
    if !isempty(label_mismatches)
        @error "$label: time series label mismatches" label_mismatches
    end
    return triples
end

@testset "PTDP document loads fully into PowerSystems" begin
    case_data = _ptdp_e2e_case_data_dir()
    rts_dir = joinpath(case_data, "RTS_GMLC")
    descriptors =
        joinpath(pkgdir(PowerTableDataParser), "test", "descriptors",
            "rts_user_descriptors.yaml")
    @test isdir(rts_dir)
    @test isfile(descriptors)

    # (1) BUILD, entirely inside PowerTableDataParser.
    table_data = PDP.PowerSystemTableData(rts_dir, 100.0, descriptors)
    sys_ptdp = PDP.build_openapi_system(table_data)
    staged = _ptdp_e2e_staged_index(sys_ptdp.time_series)
    @test length(staged) == length(sys_ptdp.time_series)
    staged_resolutions =
        Set(Dates.Millisecond(IS.get_resolution(r.series)) for r in sys_ptdp.time_series)
    # The fixture is rich on purpose: two resolutions, hundreds of series.
    @test length(staged_resolutions) == 2
    @test length(staged) > 300

    mktempdir() do dir
        # (2) WRITE. The sidecar is a pair, named after the document.
        document_path = joinpath(dir, "system.json")
        PDP.to_json(sys_ptdp, document_path; force = true)
        sidecar = joinpath(dir, PDP.time_series_filename(document_path))
        @test isfile(document_path)
        @test isfile(sidecar)
        @test isfile(sidecar * ".sqlite")

        # (3) ATTRIBUTES. PTDP already emits GeographicInfo for every bus with coordinates
        # plus generator emissions and outages, so the document arrives with attributes. One
        # more is added by hand onto a component carrying none, which is the shape PSY's
        # import treats as authoritative: an attribute that exists only in the document.
        doc = PSY.PD.read_document(document_path)
        attribute_rows = length(doc.supplemental_attribute_associations)
        attributed =
            Set(Int(a.component_id) for a in doc.supplemental_attribute_associations)
        @test !isempty(attributed)
        # A PowerLoad carries none of the three attributes the tables state (coordinates are
        # a bus's, emissions a generator's, outages a generator's or a branch's), and it does
        # own fanned-out time series — so the augmented attribute is unambiguously the one
        # asserted below.
        candidates = [
            row for row in PSY.PD.get_components(doc, "PowerLoad") if
            !(Int(row.id) in attributed)
        ]
        @test !isempty(candidates)
        target = first(candidates)
        target_id = Int(target.id)
        target_name = target.name
        geo_json = Dict{String, Any}(
            "type" => "Point",
            "coordinates" => [-97.5, 35.25],
        )
        attr_id = PSY.PD.next_id!(doc)
        PSY.PD.add_supplemental_attribute!(
            doc,
            PSY.IC.GeographicInfo(; id = attr_id, geo_json = geo_json),
            target_id,
        )

        # A second hand-added attribute, of a type that actually supports time series
        # (`supports_time_series(::GeographicInfo)` is the `SupplementalAttribute` default,
        # `false` — only `Outage` and its subtypes opt in, `src/outages.jl`), to exercise an
        # attribute-owned series. The attribute is a bare document row here, never
        # round-tripped through a System of its own, so its series is staged straight into
        # the sidecar rather than through `add_time_series!` on a component. This is the
        # producer obligation: a document naming a supplemental-attribute association must
        # also back it with a sidecar row (mirrored below by adding the matching
        # `TimeSeriesAssociation` to `doc` itself, read back off the store rather than
        # hand-built, so it is byte-for-byte what the store would produce on export).
        ts_attr_id = PSY.PD.next_id!(doc)
        PSY.PD.add_supplemental_attribute!(
            doc,
            PSY.PO.FixedForcedOutage(;
                id = ts_attr_id, outage_status = 1.0, monitored_components = Int64[],
            ),
            target_id,
        )
        attr_series_name = "attr_owned_series"
        attr_series_values = [10.0, 20.0, 30.0]
        attr_ts = IS.SingleTimeSeries(;
            name = attr_series_name,
            data = TimeSeries.TimeArray(
                [Dates.DateTime(2020, 1, 1, h) for h in 0:2], attr_series_values,
            ),
        )
        attr_owner = FixedForcedOutage(; outage_status = 1.0)
        IS.set_id!(attr_owner, ts_attr_id)
        attr_store = IS.open_deserialized_infrastore_store(sidecar, nothing, false)
        attr_mgr = IS.TimeSeriesManager(; data_store = attr_store)
        IS.add_time_series!(attr_mgr, attr_owner, attr_ts)
        for row in IS.openapi_time_series_association_rows(
            attr_store; owner_id = ts_attr_id,
        )
            PSY.PD.add_time_series_association!(doc, row)
        end
        IS.serialize(attr_store, sidecar)
        staged_with_attr = merge(
            staged,
            Dict(
                (ts_attr_id, attr_series_name, Dates.Millisecond(Dates.Hour(1))) =>
                    attr_ts,
            ),
        )

        PSY.PD.validate_document(doc)
        PSY.PD.write_document(doc, document_path; force = true)

        doc1 = PSY.PD.read_document(document_path)
        # Two hand-added rows now: the GeographicInfo and the time-series-owning outage.
        @test length(doc1.supplemental_attribute_associations) == attribute_rows + 2

        # (4) LOAD, on the default path: no time_series_read_only.
        sys2 = from_file(dir)

        # Pre-declared here, not inside the testset below: `@testset` bodies are `let`
        # blocks, so a name first assigned inside one is invisible to a sibling `@testset` —
        # only a REassignment of an already-existing outer binding (like `staged_with_attr`
        # below) is visible outside it.
        market_bid_gen_name = ""
        ts_cost_keys = NamedTuple()
        fuel_gen_name = ""
        fuel_ts_key = nothing
        new_staged = Dict{Tuple{Int, String, Dates.Millisecond}, SingleTimeSeries}()

        @testset "cycle 1: PSY reads the PTDP-authored document" begin
            # (a) every type's bucket size.
            @test _ptdp_e2e_system_component_counts(sys2) ==
                  _ptdp_e2e_doc_component_counts(doc1)
            # Attributes are not components, but the document declares them just as fully.
            @test _ptdp_e2e_system_attribute_counts(sys2) ==
                  _ptdp_e2e_doc_attribute_counts(doc1)

            # (b), (c), (d).
            @test length(doc1.time_series_associations) == length(staged_with_attr)
            _ptdp_e2e_verify_time_series(doc1, sys2, staged_with_attr, "cycle 1")

            # (e) the two hand-added attributes, on the component the document named. Each
            # one's id is its own IS id, so both must come back unchanged.
            load2 = IS.get_component(sys2, target_id)
            @test get_name(load2) == target_name
            attributes = collect(PSY.get_supplemental_attributes(load2))
            @test length(attributes) == 2
            geo2 = only(get_supplemental_attributes(GeographicInfo, load2))
            @test IS.get_geo_json(geo2) == geo_json
            @test IS.get_id(geo2) == attr_id
            outage2 = only(get_supplemental_attributes(FixedForcedOutage, load2))
            @test IS.get_id(outage2) == ts_attr_id

            # (f) the series owned by that same attribute, value-for-value.
            attr_ts2 = IS.get_time_series(SingleTimeSeries, outage2, attr_series_name)
            @test TimeSeries.values(IS.get_time_array(attr_ts2)) == attr_series_values

            # (g) one RTS thermal gets a time-series-backed `MarketBidTimeSeriesCost`, another
            # a `FuelCurve` with `fuel_cost_time_series` — proof that the association-id-bearing
            # cost converters round-trip through the full document machinery, not just
            # direct `convert_cost`/`convert_cost_to_openapi` calls.
            market_bid_gen_name, ts_cost_keys, fuel_gen_name, fuel_ts_key, new_staged =
                _ptdp_e2e_attach_ts_costs!(sys2)
            _ptdp_e2e_check_ts_costs(
                sys2, market_bid_gen_name, ts_cost_keys, fuel_gen_name, fuel_ts_key,
            )
            # `sys2`'s next `to_file` (cycle 2) will now emit these six series alongside the
            # PTDP-authored ones, so cycle 2's own `_ptdp_e2e_verify_time_series` needs them
            # in its expected set too.
            staged_with_attr = merge(staged_with_attr, new_staged)
        end

        @testset "cycle 2: write back and reload with PSY's own writer" begin
            dir2 = joinpath(dir, "reexport")
            to_file(sys2, dir2; force = true)
            @test isfile(joinpath(dir2, "system.json"))

            sys3 = from_file(dir2)
            doc2 = PSY.PD.read_document(joinpath(dir2, "system.json"))

            # Same components, same attributes, same series — described by PSY this time.
            @test _ptdp_e2e_doc_component_counts(doc2) ==
                  _ptdp_e2e_doc_component_counts(doc1)
            @test _ptdp_e2e_system_component_counts(sys3) ==
                  _ptdp_e2e_doc_component_counts(doc2)
            @test _ptdp_e2e_doc_attribute_counts(doc2) ==
                  _ptdp_e2e_doc_attribute_counts(doc1)
            @test _ptdp_e2e_system_attribute_counts(sys3) ==
                  _ptdp_e2e_doc_attribute_counts(doc2)

            # `doc1` predates (g)'s six time-series-backed-cost series above, so the expected
            # set for this comparison is `doc1`'s own rows PLUS those six, not `doc1` as-is.
            triples1 = Set(
                (Int(a.value.owner_id), a.value.name, a.value.time_series_type)
                for a in doc1.time_series_associations
            )
            new_triples = Set(
                (owner_id, name, "SingleTimeSeries") for
                (owner_id, name, _) in keys(new_staged)
            )
            triples1 = union(triples1, new_triples)
            triples2 = _ptdp_e2e_verify_time_series(doc2, sys3, staged_with_attr, "cycle 2")
            @test length(doc2.time_series_associations) ==
                  length(doc1.time_series_associations) + length(new_staged)
            @test triples2 == triples1

            # Both attributes survive PSY's export side too, under their own stable ids —
            # a direct equality, not just a content/owner match.
            load3 = IS.get_component(sys3, target_id)
            @test get_name(load3) == target_name
            attributes3 = collect(PSY.get_supplemental_attributes(load3))
            @test length(attributes3) == 2
            geo3 = only(get_supplemental_attributes(GeographicInfo, load3))
            @test IS.get_geo_json(geo3) == geo_json
            @test IS.get_id(geo3) == attr_id
            outage3 = only(get_supplemental_attributes(FixedForcedOutage, load3))
            @test IS.get_id(outage3) == ts_attr_id

            attr_ts3 = IS.get_time_series(SingleTimeSeries, outage3, attr_series_name)
            @test TimeSeries.values(IS.get_time_array(attr_ts3)) == attr_series_values

            # The time-series-backed costs from (g) above, surviving PSY's own
            # to_openapi/from_openapi round trip: every key (`==`, including
            # `association_id`) comes back exactly as set on `sys2`.
            _ptdp_e2e_check_ts_costs(
                sys3, market_bid_gen_name, ts_cost_keys, fuel_gen_name, fuel_ts_key,
            )
        end
    end
end
