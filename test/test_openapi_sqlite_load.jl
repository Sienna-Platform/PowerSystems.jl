# Standalone exercise of `load_supplemental_attribute_associations!`/
# `load_supplemental_attribute_associations!` (`src/openapi/sqlite_load.jl`), independent of
# `from_openapi(::Type{System}, doc)` — that entry point does not call these yet.
#
# `PowerCoreOpenAPIModels.document_from_json` validates referential integrity on its own
# (every `entity_id`/`attribute_id`/`owner_id` must name a row declared *somewhere* in the
# document) before this file's loaders ever run, so every document below is built on top of
# `make_openapi_test_doc()` (common.jl's shared fixture: Area=1, LoadZone=2, bus1=3, bus2=4,
# Arc=5, gen1=6, load1=7, spin_up reserve=8, shunt1=9) rather than a from-scratch minimal
# document — that keeps every id used here declared, while this file's own System/refs are
# still built directly (not via `from_openapi(System, doc)`), so it runs standalone.

"""A System/refs pair with bus1(3), bus2(4), gen1(6), and the spin_up reserve(8) — the
subset of `make_openapi_test_doc()`'s components these tests attach attributes/time series
to or use for service membership — registered under the SAME ids the document declares."""
function _sqlite_load_fixture()
    sys = System(100.0)
    refs = PSY.OpenAPIRefs(100.0)

    bus1 = ACBus(;
        number = 1, name = "bus1", available = true, bustype = ACBusTypes.REF,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 138.0,
    )
    add_component!(sys, bus1)
    refs[3] = bus1

    bus2 = ACBus(;
        number = 2, name = "bus2", available = true, bustype = ACBusTypes.PQ,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 138.0,
    )
    add_component!(sys, bus2)
    refs[4] = bus2

    gen = ThermalStandard(nothing)
    gen.bus = bus2
    gen.name = "gen1"
    add_component!(sys, gen)
    refs[6] = gen

    reserve = OnlineReserve{ReserveUp}(nothing)
    reserve.name = "spin_up"
    add_component!(sys, reserve)
    refs[8] = reserve

    return (sys = sys, refs = refs, bus1 = bus1, bus2 = bus2, gen = gen, reserve = reserve)
end

"""`make_openapi_test_doc()` with `supplemental_attributes`/`_associations`/
`service_associations` overridden — every id these tests reference (including the
`entity_id = 100`-style attribute ids) must be declared under one of those three, or
`document_from_json` rejects the document before this file's loaders run at all.
`plant_associations`/`combined_cycle_associations` are always emptied: none of these tests
exercises a plant-family attribute."""
function _sqlite_load_doc(;
    supplemental_attributes = [],
    associations = [],
    service_associations = [],
)
    raw = make_openapi_test_doc()
    raw["supplemental_attributes"] = supplemental_attributes
    raw["supplemental_attribute_associations"] = associations
    raw["plant_associations"] = []
    raw["combined_cycle_associations"] = []
    raw["service_associations"] = service_associations
    return to_test_document(raw)
end

@testset "load_supplemental_attribute_associations!: shared attribute is one object" begin
    f = _sqlite_load_fixture()

    geo_po = PSY.IC.GeographicInfo(;
        id = 100,
        geo_json = PSY.IC.GeographicInfoGeoJson(;
            additional_properties = Dict{String, Any}(
                "type" => "Point",
                "coordinates" => [1.0, 2.0],
            ),
        ),
    )
    doc = _sqlite_load_doc(;
        supplemental_attributes = [openapi_raw(geo_po)],
        associations = [
            Dict{String, Any}(
                "attribute_id" => 100, "component_id" => 3,
                "component_type" => "ACBus", "attribute_type" => "GeographicInfo",
            ),
            Dict{String, Any}(
                "attribute_id" => 100, "component_id" => 4,
                "component_type" => "ACBus", "attribute_type" => "GeographicInfo",
            ),
        ],
    )

    PSY.load_supplemental_attribute_associations!(f.sys, f.refs, doc)

    attrs1 = collect(get_supplemental_attributes(GeographicInfo, f.bus1))
    attrs2 = collect(get_supplemental_attributes(GeographicInfo, f.bus2))
    @test length(attrs1) == 1
    @test length(attrs2) == 1
    @test only(attrs1) === only(attrs2)

    # The newly-built attribute is resolvable by document id, exactly like a component from
    # the dependency-ordered component pass.
    @test f.refs[100] === only(attrs1)

    # At the SQLite level: two rows (one per component), one distinct attribute.
    mgr = f.sys.data.supplemental_attribute_manager
    @test IS.get_num_attributes(mgr.associations) == 1
    summary = IS.get_attribute_summary_table(mgr.associations)
    row = only(filter(r -> r.attribute_type == "GeographicInfo", eachrow(summary)))
    @test row.component_type == "ACBus"
    @test row.count == 2
end

@testset "load_supplemental_attribute_associations!: service membership, no SQLite row" begin
    f = _sqlite_load_fixture()

    doc = _sqlite_load_doc(;
        service_associations = [
            Dict{String, Any}("service_id" => 8, "entity_id" => 6),
        ],
    )

    PSY.load_supplemental_attribute_associations!(f.sys, f.refs, doc)

    @test has_service(f.gen, f.reserve)
    # No supplemental-attribute association resulted: a Service is a Component.
    mgr = f.sys.data.supplemental_attribute_manager
    @test IS.get_num_attributes(mgr.associations) == 0
end

@testset "load_supplemental_attribute_associations!: loud errors" begin
    geo_po = PSY.IC.GeographicInfo(;
        id = 100,
        geo_json = PSY.IC.GeographicInfoGeoJson(;
            additional_properties = Dict{String, Any}(
                "type" => "Point",
                "coordinates" => [1.0, 2.0],
            ),
        ),
    )

    # Unresolved entity_id: id=7 (load1) is a real component id in the document, but this
    # file's own `refs` never registered it — a `refs`/document mismatch, not a malformed
    # document, and exactly the case `document_from_json`'s own validation cannot catch.
    f = _sqlite_load_fixture()
    doc = _sqlite_load_doc(;
        supplemental_attributes = [openapi_raw(geo_po)],
        associations = [
            Dict{String, Any}(
                "attribute_id" => 100, "component_id" => 7,
                "component_type" => "PowerLoad", "attribute_type" => "GeographicInfo",
            ),
        ],
    )
    @test_throws ErrorException PSY.load_supplemental_attribute_associations!(
        f.sys, f.refs, doc,
    )

    # An unresolved attribute_id (naming a component, or nothing at all) is no longer
    # reachable at the loader: `attribute_id` only ever means a supplemental attribute now
    # that service membership has its own table, so `document_from_json`'s own validation
    # (checked against the same `supplemental_attributes` list the loader indexes) rejects
    # it before a document with one can even be constructed.

    # attribute_type mismatch: declares "EmissionsData" but the row builds a GeographicInfo.
    # Under OpenAPI.jl 1.x, `document_from_json` decodes each attribute against its declared
    # `attribute_type` eagerly (schema-validated), so a GeographicInfo row mislabeled
    # "EmissionsData" (missing every EmissionsData-required field) is now rejected at
    # document construction rather than surfacing later as a `MethodError` from IS's enum
    # constructor inside the loader.
    f = _sqlite_load_fixture()
    @test_throws "schema validation failed while decoding EmissionsData" _sqlite_load_doc(;
        supplemental_attributes = [openapi_raw(geo_po)],
        associations = [
            Dict{String, Any}(
                "attribute_id" => 100, "component_id" => 3,
                "component_type" => "ACBus", "attribute_type" => "EmissionsData",
            ),
        ],
    )

    # Missing attribute_type: `document_from_json` itself requires the field on every
    # association row (it resolves each raw `supplemental_attributes` dict's own type from
    # it). Under OpenAPI.jl 1.x, `SupplementalAttributeAssociation.attribute_type` is a plain
    # required `String` with no `Nothing`/`Absent` variant, so an in-memory row with a
    # missing `attribute_type` is no longer constructible at all (not even by rebuilding an
    # already-valid row with the field cleared) — the old test reached this case by mutating
    # an already-valid document's row in place, bypassing `document_from_json`'s validation
    # entirely; there is no equivalent bypass left since every PO struct is immutable now.
    f = _sqlite_load_fixture()
    doc = _sqlite_load_doc(;
        supplemental_attributes = [openapi_raw(geo_po)],
        associations = [
            Dict{String, Any}(
                "attribute_id" => 100, "component_id" => 3,
                "component_type" => "ACBus", "attribute_type" => "GeographicInfo",
            ),
        ],
    )
    @test_throws MethodError PSY._po_with(
        doc.supplemental_attribute_associations[1]; attribute_type = nothing,
    )
end
