# Document-level OpenAPI import path. A small synthetic document exercises the
# dependency-ordered component pass, reserve membership, time series adoption from a real
# InfraStore sidecar and every loud-error path.

# The shared document fixture lives in common.jl (`make_openapi_test_doc`,
# `openapi_raw`), also used by test_openapi_export.jl.

"""Build a real InfraStore sidecar holding one `SingleTimeSeries` owned by document id
`owner_id`, and return `(path, values, resolution, initial_timestamp)`.

The store's catalog is the association table — it keys the series by owner id, name, type
and resolution — so the document carries no `time_series_associations` row for it. Import
adopts this store wholesale; `owner_id` is a *document* id, which is what the imported
component's id is set to.
"""
function _openapi_test_sidecar(dir; owner_id = 7, owner_type = "PowerLoad")
    timestamps = [
        Dates.DateTime(2024, 1, 1, 0),
        Dates.DateTime(2024, 1, 1, 1),
        Dates.DateTime(2024, 1, 1, 2),
    ]
    values = [0.5, 0.6, 0.7]
    series = SingleTimeSeries(;
        name = "max_active_power",
        data = TimeSeries.TimeArray(timestamps, values),
    )
    path = joinpath(dir, "doc_time_series_storage.h5")
    store = IS.Store(; in_memory = true)
    try
        batch = IS.make_add_batch()
        IS.serialize_single!(
            batch,
            owner_id,
            owner_type,
            IS.get_owner_category(IS.InfrastructureSystemsComponent),
            IS.get_name(series),
            series,
        )
        IS.commit_batch!(store, batch)
        IS.serialize(store, path)
    finally
        IS.close!(store)
    end
    return (
        path = path,
        values = values,
        resolution = Dates.Hour(1),
        initial_timestamp = timestamps[1],
    )
end

@testset "from_openapi(System, doc): end-to-end synthetic document" begin
    mktempdir() do dir
        sidecar = _openapi_test_sidecar(dir)
        doc = make_openapi_test_doc()
        # The sidecar carries the series and its metadata; the document only names the file.
        doc["time_series_storage_file"] = basename(sidecar.path)

        sys = PSY.from_openapi(
            System, to_test_document(doc); time_series_storage_path = sidecar.path,
        )

        # Component counts.
        @test length(collect(get_components(Area, sys))) == 1
        @test length(collect(get_components(LoadZone, sys))) == 1
        @test length(collect(get_components(ACBus, sys))) == 2
        @test length(collect(get_components(Arc, sys))) == 1
        @test length(collect(get_components(ThermalStandard, sys))) == 1
        @test length(collect(get_components(PowerLoad, sys))) == 1
        @test length(collect(get_components(OnlineReserve, sys))) == 1
        @test length(collect(get_components(FixedAdmittance, sys))) == 1

        # A resolved reference: bus2's area/load_zone are the actual objects, not copies.
        bus2 = get_component(ACBus, sys, "bus2")
        @test get_name(get_area(bus2)) == "area1"
        @test get_name(get_load_zone(bus2)) == "lz1"

        # COMPONENT_MVAR divides by the document's system base
        # (100 MVA) to land on PSY's SYSTEM_BASE pu storage: -50 MVAr / 100 MVA.
        shunt = get_component(FixedAdmittance, sys, "shunt1")
        @test get_bus(shunt) === bus2
        @test get_Y(shunt) == Complex(0.0, -0.5)

        # Reserve device membership, from a service_associations row.
        gen = get_component(ThermalStandard, sys, "gen1")
        reserve = get_component(OnlineReserve, sys, "spin_up")
        @test has_service(gen, reserve)

        # Time series, adopted from the InfraStore sidecar.
        load = get_component(PowerLoad, sys, "load1")
        ts = get_time_series(SingleTimeSeries, load, "max_active_power")
        @test get_resolution(ts) == sidecar.resolution
        @test TimeSeries.values(get_data(ts)) == sidecar.values
        @test first(TimeSeries.timestamp(get_data(ts))) == sidecar.initial_timestamp
    end
end

@testset "from_openapi(System, doc): loud errors" begin
    mktempdir() do dir
        sidecar = _openapi_test_sidecar(dir)

        # Unconverted component type: no from_openapi registered for "FooBarType".
        doc = make_openapi_test_doc()
        doc["components"]["FooBarType"] = [Dict{String, Any}("id" => 999)]
        @test_throws DocumentError PSY.from_openapi(System, to_test_document(doc))

        # Unresolved entity_id on a service-membership row: service_id (8) resolves to
        # the real "spin_up" reserve, but no component exists under entity_id 999.
        doc = make_openapi_test_doc()
        doc["service_associations"] = [
            Dict{String, Any}("service_id" => 8, "entity_id" => 999),
        ]
        @test_throws DocumentError PSY.from_openapi(System, to_test_document(doc))

        # A named sidecar that is not on disk. This is the one time-series error path left:
        # the rest — unmapped time_series_type, a mismatched owner_category, series
        # declared with no storage path — all validated a
        # `time_series_associations` row, and the sidecar's own catalog is the association
        # table now, written by the store rather than by a producer filling in columns.
        doc = make_openapi_test_doc()
        doc["time_series_storage_file"] = basename(sidecar.path)
        @test_throws DocumentError PSY.from_openapi(
            System, to_test_document(doc);
            time_series_storage_path = joinpath(dir, "no_such_sidecar.h5"),
        )

        # Unmapped attribute_type: the association resolves to a real row, but no
        # converter is registered for the type it names.
        doc = make_openapi_test_doc()
        doc["supplemental_attributes"] =
            [Dict{String, Any}("id" => 1, "name" => "whatever")]
        doc["supplemental_attribute_associations"] = [
            Dict{String, Any}(
                "attribute_id" => 1, "component_id" => 3, "component_type" => "ACBus",
                "attribute_type" => "BogusType",
            ),
        ]
        @test_throws DocumentError PSY.from_openapi(System, to_test_document(doc))

        # Association references an attribute_id with no matching row.
        doc = make_openapi_test_doc()
        doc["supplemental_attribute_associations"] = [
            Dict{String, Any}(
                "attribute_id" => 999, "component_id" => 3, "component_type" => "ACBus",
                "attribute_type" => "GeographicInfo",
            ),
        ]
        @test_throws DocumentError PSY.from_openapi(System, to_test_document(doc))

        # Association references an unresolved entity_id.
        doc = make_openapi_test_doc()
        doc["supplemental_attributes"] =
            [openapi_raw(PSY.IC.GeographicInfo(; id = 1, geo_json = Dict{String, Any}()))]
        doc["supplemental_attribute_associations"] = [
            Dict{String, Any}(
                "attribute_id" => 1, "component_id" => 999, "component_type" => "ACBus",
                "attribute_type" => "GeographicInfo",
            ),
        ]
        @test_throws DocumentError PSY.from_openapi(System, to_test_document(doc))
    end
end

@testset "from_openapi(System, doc): supplemental attribute real dispatch" begin
    doc = make_openapi_test_doc()
    geo_po = PSY.IC.GeographicInfo(;
        id = 100,
        geo_json = Dict{String, Any}("type" => "Point", "coordinates" => [1.0, 2.0]),
    )
    emissions_po = PSY.PO.EmissionsData(;
        id = 101, name = "gen1_CO2", pollutant = "CO2",
        emission_rate = PSY.PC.ValueCurve(
            PSY.PC.IncrementalCurve(;
                function_data = PSY.PC.IncrementalCurveFunctionData(
                    PSY.IC.LinearFunctionData(;
                        proportional_term = 0.0,
                        constant_term = 1.5,
                    ),
                ),
                initial_input = 0.0,
            ),
        ),
        basis = "FUEL_INPUT", start_up_adder = 0.0, mass_unit = "LB",
        energy_unit = "MMBTU", gwp = 1.0, available = true,
    )
    doc["supplemental_attributes"] = [openapi_raw(geo_po), openapi_raw(emissions_po)]
    doc["supplemental_attribute_associations"] = [
        Dict{String, Any}(
            "attribute_id" => 100,
            "component_id" => 3,
            "component_type" => "ACBus",
            "attribute_type" => "GeographicInfo",
        ),
        Dict{String, Any}(
            "attribute_id" => 101,
            "component_id" => 6,
            "component_type" => "ThermalStandard",
            "attribute_type" => "EmissionsData",
        ),
    ]

    sys = PSY.from_openapi(System, to_test_document(doc))

    bus1 = get_component(ACBus, sys, "bus1")
    geo_attrs = get_supplemental_attributes(GeographicInfo, bus1)
    @test length(geo_attrs) == 1
    @test get_geo_json(only(geo_attrs))["type"] == "Point"

    gen = get_component(ThermalStandard, sys, "gen1")
    emissions_attrs = get_supplemental_attributes(EmissionsData, gen)
    @test length(emissions_attrs) == 1
    @test get_pollutant(only(emissions_attrs)) == PollutantType.CO2
end

@testset "OpenAPI supplemental attribute converters" begin
    refs = PSY.OpenAPIRefs(100.0)
    bus = ACBus(;
        number = 1, name = "bus1", available = true, bustype = ACBusTypes.REF,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 138.0,
    )
    refs[1] = bus

    emissions_po = PSY.PO.EmissionsData(;
        id = 2, name = "gen1_CO2", pollutant = "CO2",
        emission_rate = PSY.PC.ValueCurve(
            PSY.PC.IncrementalCurve(;
                function_data = PSY.PC.IncrementalCurveFunctionData(
                    PSY.IC.LinearFunctionData(;
                        proportional_term = 0.0,
                        constant_term = 1.5,
                    ),
                ),
                initial_input = 0.0,
            ),
        ),
        basis = "FUEL_INPUT", start_up_adder = 0.0, mass_unit = "LB",
        energy_unit = "MMBTU", gwp = 1.0, available = true,
    )
    emissions = PSY.from_openapi(emissions_po, refs)
    @test get_pollutant(emissions) == PollutantType.CO2
    @test get_basis(emissions) == EmissionBasis.FUEL_INPUT
    @test get_mass_unit(emissions) == MassUnit.LB
    @test get_energy_unit(emissions) == EnergyUnit.MMBTU

    outage_po = PSY.PO.GeometricDistributionForcedOutage(;
        id = 3, mean_time_to_recovery = 480, outage_transition_probability = 0.001,
        monitored_components = [1],
    )
    outage = PSY.from_openapi(outage_po, refs)
    @test get_mean_time_to_recovery(outage) == 480.0
    @test get_monitored_components(outage) == Set([IS.get_id(bus)])

    fixed_po = PSY.PO.FixedForcedOutage(;
        id = 4,
        outage_status = 1.0,
        monitored_components = nothing,
    )
    fixed = PSY.from_openapi(fixed_po, refs)
    @test PSY.get_outage_status(fixed) == 1.0
    @test get_monitored_components(fixed) == Set{Base.UUID}()

    planned_po = PSY.PO.PlannedOutage(;
        id = 5, outage_schedule = "maintenance_2024", monitored_components = [1],
    )
    planned = PSY.from_openapi(planned_po, refs)
    @test get_outage_schedule(planned) == "maintenance_2024"

    plant_po = PSY.PO.ThermalPowerPlant(; id = 6, name = "plant1")
    plant = PSY.from_openapi(plant_po, refs)
    @test get_name(plant) == "plant1"

    hydro_plant =
        PSY.from_openapi(PSY.PO.HydroPowerPlant(; id = 7, name = "hp1"), refs)
    @test get_name(hydro_plant) == "hp1"

    renewable_plant =
        PSY.from_openapi(PSY.PO.RenewablePowerPlant(; id = 8, name = "rp1"), refs)
    @test get_name(renewable_plant) == "rp1"

    cc_block_po = PSY.PO.CombinedCycleBlock(;
        id = 9, name = "cc1", configuration = "SingleShaftCombustionSteam",
        heat_recovery_to_steam_factor = 0.5,
    )
    cc_block = PSY.from_openapi(cc_block_po, refs)
    @test get_configuration(cc_block) ==
          CombinedCycleConfiguration.SingleShaftCombustionSteam
    @test get_heat_recovery_to_steam_factor(cc_block) == 0.5

    cc_frac_po =
        PSY.PO.CombinedCycleFractional(; id = 10, name = "cc2", configuration = "Other")
    cc_frac = PSY.from_openapi(cc_frac_po, refs)
    @test get_configuration(cc_frac) == CombinedCycleConfiguration.Other

    geo_po = PSY.IC.GeographicInfo(;
        id = 11,
        geo_json = Dict{String, Any}("type" => "Point", "coordinates" => [1.0, 2.0]),
    )
    geo = PSY.from_openapi(geo_po, refs)
    @test get_geo_json(geo)["type"] == "Point"

    # The PO layer's own OpenAPI-generated enum validation rejects an unmapped
    # pollutant before construction even completes (mirrors the reserve-direction
    # test in test_openapi_converters.jl) — and the scoped-enum constructor the
    # converter uses errors loudly too, exercised directly since a real PO struct can
    # never carry a value outside its own enum whitelist.
    @test_throws Exception PSY.PO.EmissionsData(;
        id = 12, name = "bad", pollutant = "BOGUS",
        emission_rate = emissions_po.emission_rate, basis = "FUEL_INPUT",
        mass_unit = "LB", energy_unit = "MMBTU",
    )
    @test_throws Exception PollutantType("BOGUS")
end

@testset "MarketBidCost round trip: fields and ancillary service offer ids" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.bus = bus
    gen.name = "gen1"
    add_component!(sys, gen)
    svc = OnlineReserve{ReserveUp}(;
        name = "RESERVE", available = true, time_frame = 10.0, requirement = 0.1)
    add_service!(sys, svc, [gen])

    mbc = MarketBidCost(;
        minimum_energy_offer = LinearCurve(5.0),
        start_up = (hot = 100.0, warm = 200.0, cold = 300.0),
        shut_down = LinearCurve(2.0),
        incremental_offer_curves = make_market_bid_curve(
            [0.0, 50.0, 100.0], [10.0, 20.0], 0.0; power_units = IS.NaturalUnit(),
        ),
        incremental_slope = true,
    )
    push!(get_ancillary_service_offers(mbc), svc)
    set_operation_cost!(gen, mbc)

    doc = to_openapi(sys; power_units = :natural_units)
    sys2 = from_openapi(System, doc)

    gen2 = get_component(ThermalStandard, sys2, "gen1")
    mbc2 = get_operation_cost(gen2)
    @test mbc2 isa MarketBidCost
    @test get_minimum_energy_offer(mbc2) == LinearCurve(5.0)
    @test get_start_up(mbc2) == (hot = 100.0, warm = 200.0, cold = 300.0)
    @test get_shut_down(mbc2) == LinearCurve(2.0)
    @test get_incremental_offer_curves(mbc2) == get_incremental_offer_curves(mbc)
    @test get_decremental_offer_curves(mbc2) == get_decremental_offer_curves(mbc)
    @test get_incremental_slope(mbc2)
    @test !get_decremental_slope(mbc2)
    @test get_curve_style(mbc2) == CurveStyles.CURVE
    offers = get_ancillary_service_offers(mbc2)
    @test length(offers) == 1
    @test get_name(only(offers)) == "RESERVE"
    @test only(offers) === get_component(OnlineReserve{ReserveUp}, sys2, "RESERVE")
end

"""Build a `System` with one `ThermalStandard` (`gen1`) carrying a plain `MarketBidCost`.
Returns `(sys, gen)`. Used to reach the wire-level `curve_style`/`incremental_slope` fields
by patching the raw JSON text: patching the parsed `PO.MarketBidCost` in place instead would
go through `OpenAPI.jl`'s own `setproperty!` validation (rejects an out-of-range enum value
immediately) or would drop a `nothing` field entirely on write (turning "explicit null" back
into "key omitted, use the struct default")."""
function _market_bid_cost_fixture()
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.bus = bus
    gen.name = "gen1"
    add_component!(sys, gen)
    mbc = MarketBidCost(;
        minimum_energy_offer = LinearCurve(5.0),
        start_up = (hot = 100.0, warm = 200.0, cold = 300.0),
        shut_down = LinearCurve(2.0),
        incremental_offer_curves = make_market_bid_curve(
            [0.0, 50.0, 100.0], [10.0, 20.0], 0.0; power_units = IS.NaturalUnit(),
        ),
    )
    set_operation_cost!(gen, mbc)
    return (sys, gen)
end

@testset "convert_cost(MarketBidCost): explicit null curve_style errors loudly, not MethodError" begin
    sys, gen = _market_bid_cost_fixture()
    mktempdir() do dir
        to_file(sys, dir; force = true)
        document_path = joinpath(dir, "system.json")
        txt = read(document_path, String)
        @test occursin("\"curve_style\":0", txt)
        write(document_path, replace(txt, "\"curve_style\":0" => "\"curve_style\":null"))
        @test_throws "MarketBidCost.curve_style is required and missing" from_file(dir)
    end
end

@testset "convert_cost(MarketBidCost): explicit null incremental_slope errors loudly" begin
    sys, gen = _market_bid_cost_fixture()
    mktempdir() do dir
        to_file(sys, dir; force = true)
        document_path = joinpath(dir, "system.json")
        txt = read(document_path, String)
        @test occursin("\"incremental_slope\":false", txt)
        write(
            document_path,
            replace(txt, "\"incremental_slope\":false" => "\"incremental_slope\":null"),
        )
        @test_throws "MarketBidCost.incremental_slope is required and missing" from_file(
            dir,
        )
    end
end

@testset "_curve_style_from_wire rejects an out-of-range integer" begin
    sys, gen = _market_bid_cost_fixture()
    mktempdir() do dir
        to_file(sys, dir; force = true)
        document_path = joinpath(dir, "system.json")
        txt = read(document_path, String)
        write(document_path, replace(txt, "\"curve_style\":0" => "\"curve_style\":7"))
        @test_throws "curve_style 7 is not a valid CurveStyles value" from_file(dir)
    end
end

"""Build a `System` with one `ThermalStandard` (`gen1`) carrying a
`MarketBidTimeSeriesCost` and one `OnlineReserve{ReserveUp}` (`RESERVE`) the generator
contributes to. Returns `(sys, gen, svc)`. Shared by the two testsets below: export cannot
carry `ancillary_service_offers` for this cost type (the id-filling pass is gated on
`MarketBidCost`, `export_document.jl`, out of edit scope), so one test proves export errors
loudly instead of dropping them, and the other proves import resolves them correctly when a
document (from any producer, not necessarily PSY's own writer) already carries the ids."""
function _mbtc_service_offer_fixture()
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.bus = bus
    gen.name = "gen1"
    add_component!(sys, gen)
    svc = OnlineReserve{ReserveUp}(;
        name = "RESERVE", available = true, time_frame = 10.0, requirement = 0.1)
    add_service!(sys, svc, [gen])

    timestamps =
        collect(Dates.DateTime(2024, 1, 1):Dates.Hour(1):Dates.DateTime(2024, 1, 1, 23))
    pwl_values = fill(PiecewiseStepData([0.0, 100.0], [10.0]), 24)
    linear_values = fill(LinearFunctionData(1.0, 0.0), 24)
    _mbtc_sts(name, values) =
        IS.SingleTimeSeries(; name = name, data = TimeSeries.TimeArray(timestamps, values))

    inc_key = add_time_series!(sys, gen, _mbtc_sts("inc_offer", pwl_values))
    dec_key = add_time_series!(sys, gen, _mbtc_sts("dec_offer", pwl_values))
    no_load_key = add_time_series!(sys, gen, _mbtc_sts("no_load", linear_values))
    shut_down_key = add_time_series!(sys, gen, _mbtc_sts("shut_down", linear_values))
    start_up_key = add_time_series!(
        sys, gen, _mbtc_sts("start_up", fill((100.0, 200.0, 300.0), 24)),
    )
    mbtc = MarketBidTimeSeriesCost(;
        minimum_energy_offer = TimeSeriesLinearCurve(no_load_key),
        start_up = start_up_key,
        shut_down = TimeSeriesLinearCurve(shut_down_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
    )
    set_operation_cost!(gen, mbtc)
    return (sys, gen, svc)
end

@testset "convert_cost_to_openapi(MarketBidTimeSeriesCost): non-empty ancillary_service_offers errors loudly" begin
    sys, gen, svc = _mbtc_service_offer_fixture()
    push!(get_ancillary_service_offers(get_operation_cost(gen)), svc)
    @test_throws ErrorException PSY.convert_cost_to_openapi(get_operation_cost(gen))
    # The document-level export path hits the same error rather than silently dropping it.
    @test_throws ErrorException to_openapi(sys; power_units = :natural_units)
end

@testset "MarketBidTimeSeriesCost: ancillary_service_offers resolve on import" begin
    # Export cannot produce this document (the test above proves it errors instead), so this
    # builds one the way an external producer's document would arrive: exported with no
    # offers, then hand-patched to carry the id — exactly the shape
    # `_load_market_bid_service_offers!` must resolve.
    sys, gen, svc = _mbtc_service_offer_fixture()
    gen_id = IS.get_id(gen)
    svc_id = IS.get_id(svc)

    mktempdir() do dir
        to_file(sys, dir; force = true)
        document_path = joinpath(dir, "system.json")
        doc = PSY.PD.read_document(document_path)
        gen_row = only(
            row for
            row in PSY.PD.get_components(doc, "ThermalStandard") if Int(row.id) == gen_id
        )
        # `PD.read_document` parses the oneOf wrapper (`PO.ThermalStandardOperationCost`),
        # not the bare cost `to_openapi`'s in-memory path hands back — set the field on the
        # unwrapped `.value`, exactly what `_load_market_bid_service_offers!` reads.
        gen_row.operation_cost.value.ancillary_service_offers = Int64[svc_id]
        PSY.PD.write_document(doc, document_path; force = true)

        sys2 = from_file(dir)
        gen2 = get_component(ThermalStandard, sys2, "gen1")
        mbtc2 = get_operation_cost(gen2)
        @test mbtc2 isa MarketBidTimeSeriesCost
        offers = get_ancillary_service_offers(mbtc2)
        @test length(offers) == 1
        @test get_name(only(offers)) == "RESERVE"
        @test only(offers) === get_component(OnlineReserve{ReserveUp}, sys2, "RESERVE")
    end
end

"""Build a system whose one `ThermalStandard` carries a fully time-series-backed
`MarketBidTimeSeriesCost`, with `slope_kwargs` forwarded to its constructor."""
function _mbtc_extension_fixture(; slope_kwargs...)
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalStandard(nothing)
    gen.bus = bus
    gen.name = "gen1"
    add_component!(sys, gen)

    timestamps =
        collect(Dates.DateTime(2024, 1, 1):Dates.Hour(1):Dates.DateTime(2024, 1, 1, 23))
    pwl_values = fill(PiecewiseStepData([0.0, 100.0], [10.0]), 24)
    linear_values = fill(LinearFunctionData(1.0, 0.0), 24)
    _mbtc_ext_sts(name, values) =
        IS.SingleTimeSeries(; name = name, data = TimeSeries.TimeArray(timestamps, values))

    inc_key = add_time_series!(sys, gen, _mbtc_ext_sts("inc_offer_ext", pwl_values))
    dec_key = add_time_series!(sys, gen, _mbtc_ext_sts("dec_offer_ext", pwl_values))
    no_load_key = add_time_series!(sys, gen, _mbtc_ext_sts("no_load_ext", linear_values))
    shut_down_key =
        add_time_series!(sys, gen, _mbtc_ext_sts("shut_down_ext", linear_values))
    start_up_key = add_time_series!(
        sys, gen, _mbtc_ext_sts("start_up_ext", fill((100.0, 200.0, 300.0), 24)),
    )
    mbtc = MarketBidTimeSeriesCost(;
        minimum_energy_offer = TimeSeriesLinearCurve(no_load_key),
        start_up = start_up_key,
        shut_down = TimeSeriesLinearCurve(shut_down_key),
        incremental_offer_curves = make_market_bid_ts_curve(inc_key),
        decremental_offer_curves = make_market_bid_ts_curve(dec_key),
        slope_kwargs...,
    )
    set_operation_cost!(gen, mbtc)
    return (sys, gen)
end

@testset "MarketBidTimeSeriesCost round trip: slope flags" begin
    sys, gen = _mbtc_extension_fixture(; incremental_slope = true)
    mktempdir() do dir
        to_file(sys, dir; force = true)
        sys2 = from_file(dir)
        gen2 = get_component(ThermalStandard, sys2, "gen1")
        mbtc2 = get_operation_cost(gen2)
        @test mbtc2 isa MarketBidTimeSeriesCost
        @test get_incremental_slope(mbtc2)
        @test !get_decremental_slope(mbtc2)
        @test get_curve_style(mbtc2) == CurveStyles.CURVE
    end
end

@testset "MarketBidTimeSeriesCost round trip: curve_style" begin
    sys, gen = _mbtc_extension_fixture(; curve_style = CurveStyles.FIXED)

    # The wire representation is a plain integer (0/1/2), not a string enum.
    wire = PSY.convert_cost_to_openapi(get_operation_cost(gen))
    @test wire.curve_style == 1

    mktempdir() do dir
        to_file(sys, dir; force = true)
        sys2 = from_file(dir)
        gen2 = get_component(ThermalStandard, sys2, "gen1")
        mbtc2 = get_operation_cost(gen2)
        @test mbtc2 isa MarketBidTimeSeriesCost
        @test !get_incremental_slope(mbtc2)
        @test !get_decremental_slope(mbtc2)
        @test get_curve_style(mbtc2) == CurveStyles.FIXED
    end
end

@testset "ThermalMultiStart round trip: multi-start fields and MarketBidCost" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)
    gen = ThermalMultiStart(nothing)
    gen.bus = bus
    gen.name = "ms1"
    gen.base_power = 50.0
    gen.active_power_limits = (min = 0.2, max = 1.0)
    gen.ramp_limits = (up = 0.1, down = 0.1)
    gen.power_trajectory = (startup = 0.3, shutdown = 0.25)
    gen.time_limits = (up = 2.0, down = 1.0)
    gen.start_time_limits = (hot = 2.0, warm = 4.0, cold = 8.0)
    gen.start_types = 3
    gen.must_run = true
    add_component!(sys, gen)
    svc = OnlineReserve{ReserveUp}(;
        name = "RESERVE", available = true, time_frame = 10.0, requirement = 0.1)
    add_service!(sys, svc, [gen])
    mbc = MarketBidCost(;
        incremental_offer_curves = make_market_bid_curve(
            [0.0, 25.0, 50.0], [12.0, 24.0], 0.0; power_units = IS.NaturalUnit(),
        ),
    )
    push!(get_ancillary_service_offers(mbc), svc)
    set_operation_cost!(gen, mbc)

    for power_units in (:component_base, :natural_units)
        doc = to_openapi(sys; power_units = power_units)
        sys2 = from_openapi(System, doc)
        gen2 = get_component(ThermalMultiStart, sys2, "ms1")
        @test !isnothing(gen2)
        @test get_base_power(gen2) == 50.0
        @test get_active_power_limits(gen2, PSY.DU) == (min = 0.2, max = 1.0)
        @test get_ramp_limits(gen2, PSY.DU) == (up = 0.1, down = 0.1)
        @test get_power_trajectory(gen2, PSY.DU) == (startup = 0.3, shutdown = 0.25)
        @test get_time_limits(gen2) == (up = 2.0, down = 1.0)
        @test get_start_time_limits(gen2) == (hot = 2.0, warm = 4.0, cold = 8.0)
        @test get_start_types(gen2) == 3
        @test get_must_run(gen2)
        mbc2 = get_operation_cost(gen2)
        @test mbc2 isa MarketBidCost
        @test get_incremental_offer_curves(mbc2) == get_incremental_offer_curves(mbc)
        @test get_name(only(get_ancillary_service_offers(mbc2))) == "RESERVE"
    end
end

@testset "HydroReservoir round trip: forward turbine and cascading reservoir references" begin
    sys = System(100.0)
    bus = ACBus(nothing)
    bus.name = "bus1"
    bus.number = 1
    bus.bustype = ACBusTypes.REF
    add_component!(sys, bus)

    # `DOCUMENT_PLAN` now converts both `HydroUnit` subtypes before `HydroReservoir`, so the
    # turbine reference below is no longer a genuine forward reference — the reservoir-to-
    # reservoir reference two components down still is (the cascading case no `DOCUMENT_PLAN`
    # reordering can fix, since a reservoir can reference another reservoir). Both are read
    # through the same [`PSY.defer_ref!`](@ref)/[`PSY.resolve_deferred_refs!`](@ref) queue,
    # which does not care whether the id it resolves was already registered when queued.
    pump = HydroPumpTurbine(nothing)
    pump.bus = bus
    pump.name = "pump1"
    add_component!(sys, pump)

    head = HydroReservoir(;
        name = "head", available = true,
        storage_level_limits = (min = 0.0, max = 1000.0),
        initial_level = 0.5, spillage_limits = nothing,
        inflow = 10.0, outflow = 8.0, level_targets = nothing,
        intake_elevation = 50.0,
        head_to_volume_factor = LinearFunctionData(0.001, 0.0),
        downstream_turbines = PSY.HydroUnit[pump],
    )
    add_component!(sys, head)

    # `tail` references `head` — both `HydroReservoir`s, so this is a same-type reference
    # within HydroReservoir's own document-key pass, the cascading case no `DOCUMENT_PLAN`
    # reordering could fix.
    tail = HydroReservoir(;
        name = "tail", available = true,
        storage_level_limits = (min = 0.0, max = 1000.0),
        initial_level = 0.5, spillage_limits = nothing,
        inflow = 10.0, outflow = 8.0, level_targets = nothing,
        intake_elevation = 40.0,
        head_to_volume_factor = LinearFunctionData(0.001, 0.0),
        upstream_turbines = PSY.HydroUnit[pump],
        upstream_reservoirs = Device[head],
    )
    add_component!(sys, tail)

    for power_units in (:component_base, :natural_units)
        doc = to_openapi(sys; power_units = power_units)
        sys2 = from_openapi(System, doc)

        pump2 = get_component(HydroPumpTurbine, sys2, "pump1")
        head2 = get_component(HydroReservoir, sys2, "head")
        tail2 = get_component(HydroReservoir, sys2, "tail")
        @test !isnothing(pump2)
        @test !isnothing(head2)
        @test !isnothing(tail2)

        @test get_downstream_turbines(head2) == [pump2]
        @test get_upstream_turbines(tail2) == [pump2]
        @test get_upstream_reservoirs(tail2) == [head2]
        @test isempty(get_upstream_reservoirs(head2))
    end
end

@testset "DOCUMENT_PLAN: turbines convert before the reservoirs referencing them" begin
    # No longer load-bearing — the `defer_ref!`/`resolve_deferred_refs!` queue (see the
    # round-trip testset above) resolves a turbine or same-type reservoir reference
    # regardless of plan order. Kept as a harmless extra guard on the plan's declared intent.
    order = [p.key for p in PSY.DOCUMENT_PLAN]
    plan_position(key) = findfirst(==(key), order)
    @test plan_position("HydroTurbine") < plan_position("HydroReservoir")
    @test plan_position("HydroPumpTurbine") < plan_position("HydroReservoir")
end

@testset "DOCUMENT_PLAN: converters match the declared pair" begin
    # `from_openapi` dispatches on the PO type, so `psy_type` no longer reaches the import
    # call and a mis-paired entry would go unnoticed at run time — `is_document_exportable`
    # is generated from it. Assert the pairing here instead: the converters exist in both
    # directions, and `from_openapi` on the `po_type` really does return the `psy_type`.
    #
    # A test rather than a load-time assertion on purpose: `generate_structs` runs inside
    # `PowerSystems`, so an assertion that fired on stale generated code would make the
    # module unloadable and take regeneration down with it.
    for (po_type, psy_type, key, _addable) in PSY.DOCUMENT_PLAN
        for units in (typeof(DU), typeof(NU))
            @test hasmethod(PSY.from_openapi, (po_type, PSY.OpenAPIRefs, units))
            @test hasmethod(PSY.to_openapi, (psy_type, PSY.OpenAPIRefs, units))
            returned = Base.return_types(
                PSY.from_openapi, (po_type, PSY.OpenAPIRefs, units),
            )
            @test length(returned) == 1
            @test only(returned) <: psy_type
        end
    end
end
