# Hand-written (not generated): the document-level OpenAPI export path. Mirrors
# src/openapi/import_document.jl's structure in reverse: same `DOCUMENT_PLAN` type enumeration,
# same supplemental-attribute / service-membership / time-series machinery, inverted.
#
# Export (`to_openapi(sys; ...)`) assembles a `PowerCoreOpenAPIModels.SystemDocument`. Writing
# it to disk is `write_document`'s job, driven by `to_file` in src/openapi/file_io.jl.

# ── Supplemental attribute reverse converters ───────────────────────────────────
# Dispatches on the PSY attribute's concrete type rather than a runtime string → function
# table: export already knows the type. Only the emitted `attribute_type` string, read by
# `add_supplemental_attribute!` on the way back in, is derived from it.
#
# Same shape as the generated component exporters: `to_openapi(attr, refs)`, with the id
# read back via `component_id(refs, attr)` — the attribute walk registers each attribute
# under its document id before converting, exactly as the import direction does in
# sqlite_load.jl. None of these embed unit-converted fields, so unlike the per-component
# exporters they take no unit-system argument.

"""Resolve monitored-component ids to document ids; empty reverses to `nothing`."""
function _monitored_component_ids(refs::OpenAPIRefs, ids)
    if isempty(ids)
        return nothing
    end
    document_ids = Int[]
    for id in ids
        has_ref(refs, Int(id)) ||
            error("to_openapi: an outage monitors id $id, absent from the document")
        push!(document_ids, Int(id))
    end
    return document_ids
end

function to_openapi(attr::EmissionsData, refs::OpenAPIRefs)
    return PO.EmissionsData(;
        id = component_id(refs, attr),
        name = get_name(attr),
        pollutant = string(get_pollutant(attr)),
        emission_rate = PC.ValueCurve(convert_cost_to_openapi(get_emission_rate(attr))),
        basis = string(get_basis(attr)),
        start_up_adder = get_start_up_adder(attr),
        mass_unit = string(get_mass_unit(attr)),
        energy_unit = string(get_energy_unit(attr)),
        gwp = get_gwp(attr),
        available = get_available(attr),
    )
end

function to_openapi(outage::GeometricDistributionForcedOutage, refs::OpenAPIRefs)
    return PO.GeometricDistributionForcedOutage(;
        id = component_id(refs, outage),
        mean_time_to_recovery = get_mean_time_to_recovery(outage),
        outage_transition_probability = get_outage_transition_probability(outage),
        monitored_components = _monitored_component_ids(
            refs, get_monitored_components(outage),
        ),
    )
end

function to_openapi(outage::PlannedOutage, refs::OpenAPIRefs)
    return PO.PlannedOutage(;
        id = component_id(refs, outage),
        outage_schedule = get_outage_schedule(outage),
        monitored_components = _monitored_component_ids(
            refs, get_monitored_components(outage),
        ),
    )
end

function to_openapi(outage::FixedForcedOutage, refs::OpenAPIRefs)
    return PO.FixedForcedOutage(;
        id = component_id(refs, outage),
        outage_status = get_outage_status(outage),
        monitored_components = _monitored_component_ids(
            refs, get_monitored_components(outage),
        ),
    )
end

to_openapi(plant::ThermalPowerPlant, refs::OpenAPIRefs) =
    PO.ThermalPowerPlant(; id = component_id(refs, plant), name = get_name(plant))
to_openapi(plant::HydroPowerPlant, refs::OpenAPIRefs) =
    PO.HydroPowerPlant(; id = component_id(refs, plant), name = get_name(plant))
to_openapi(plant::RenewablePowerPlant, refs::OpenAPIRefs) =
    PO.RenewablePowerPlant(; id = component_id(refs, plant), name = get_name(plant))

function to_openapi(block::CombinedCycleBlock, refs::OpenAPIRefs)
    return PO.CombinedCycleBlock(;
        id = component_id(refs, block),
        name = get_name(block),
        configuration = string(get_configuration(block)),
        heat_recovery_to_steam_factor = get_heat_recovery_to_steam_factor(block),
    )
end

function to_openapi(frac::CombinedCycleFractional, refs::OpenAPIRefs)
    return PO.CombinedCycleFractional(;
        id = component_id(refs, frac),
        name = get_name(frac),
        configuration = string(get_configuration(frac)),
    )
end

# The InfrastructureSystems-owned attributes: IS holds the field mapping and takes the id
# directly, so these resolve it from `refs` and delegate.
to_openapi(geo::GeographicInfo, refs::OpenAPIRefs) =
    to_openapi(geo, component_id(refs, geo))
to_openapi(ds::DataSource, refs::OpenAPIRefs) =
    to_openapi(ds, component_id(refs, ds))

function to_openapi(attr::ImpedanceCorrectionData, refs::OpenAPIRefs)
    return PO.ImpedanceCorrectionData(;
        id = component_id(refs, attr),
        table_number = get_table_number(attr),
        impedance_correction_curve = convert_cost_to_openapi(
            get_impedance_correction_curve(attr),
        ),
        transformer_winding = string(get_transformer_winding(attr)),
        transformer_control_mode = string(get_transformer_control_mode(attr)),
    )
end

# ── component `ext` ──────────────────────────────────────────────────────────────
# Written through to `doc.ext[component_id]` verbatim, the reverse of `_merge_doc_ext!` in
# import_document.jl. `ext` is producer-side passthrough: PowerSystems stores it and never
# reads it, so it is neither validated nor mapped onto fields in either direction.
#
# `Arc`/`TransformerCircuit`/`TransmissionInterface` carry no `ext` field at all — nothing to
# write, so those overloads are no-ops rather than an error about a missing getter.

_export_ext!(::PD.SystemDocument, ::Int, ::Arc) = nothing
_export_ext!(::PD.SystemDocument, ::Int, ::TransformerCircuit) = nothing
_export_ext!(::PD.SystemDocument, ::Int, ::TransmissionInterface) = nothing

function _export_ext!(doc::PD.SystemDocument, id::Int, component)
    PD.set_ext!(doc, id, get_ext(component))
    return nothing
end

# ── unexportable components ─────────────────────────────────────────────────────

"""
Warn, naming each type and how many of it, when `sys` holds components no converter covers.

Those components are omitted from the document. This is accepted for now since dynamics is
deferred, so no dynamic type has a converter and a dynamics-bearing system cannot round-trip
through a document — but it is reported on every export rather than left silent, so a consumer
of the document knows what is not in it.

Warns rather than errors: blocking would make the document unusable as a cache format for
systems that carry dynamics, and dynamics is not going to production on this line yet. When a
converter is added to [`DOCUMENT_PLAN`](@ref), its type drops out of this warning automatically.
"""
function warn_unexportable_components(sys::System)
    counts = Dict{Symbol, Int}()
    for component in get_components(Component, sys)
        if !is_document_exportable(component)
            name = nameof(typeof(component))
            counts[name] = get(counts, name, 0) + 1
        end
    end
    isempty(counts) && return nothing
    listed = join(("$k ($(counts[k]))" for k in sort(collect(keys(counts)))), ", ")
    @warn "to_openapi: omitting component type(s) with no OpenAPI converter — they will not " *
          "be in the document and will not survive a round trip: $listed"
    return nothing
end

# ── power_units resolution ───────────────────────────────────────────────────────

"""Resolve the `power_units` kwarg to the `DU`/`NU` marker every exported component blob is
stamped with — a uniform stamp per export, since PSY does not record a per-component creation
basis."""
function _resolve_export_power_units(power_units::Symbol)
    if power_units === :component_base
        return DU
    elseif power_units === :natural_units
        return NU
    else
        error(
            "to_openapi(sys; power_units=$power_units): unmapped — expected " *
            ":component_base or :natural_units",
        )
    end
end

# ── id assignment ────────────────────────────────────────────────────────────────
# Builds an `OpenAPIRefs` and populates it via `refs[id] = component`, walking components in
# `DOCUMENT_PLAN` order (buses before the branches that reference them, etc. — the same order
# import uses; export does not need the ordering for resolution, since ids already exist or are
# assigned fresh, but keeping it identical simplifies testing and mirrors import 1:1).
#
# A component's document id IS its IS component id. That keeps the document and the
# InfraStore sidecar consistent by construction: the sidecar's catalog keys every series by
# component id, and import resolves a series' owner by looking that id up as a document id.
# A `from_openapi`-built System reproduces its original document ids for free, since import
# sets each component's id to its document id.
#
# `TransformerCircuit` has no id of its own (`_has_own_id` false — it is embedded in its
# owning transformer), so it draws from a counter that starts above every component id.

"""Enumerate the live instances of a `DOCUMENT_PLAN` type. `TransformerCircuit` is a
`DeviceParameter` embedded in its owning transformer, never a standalone System component,
so it enumerates through the owners — both `TwoWindingTransformer` (one circuit) and
`ThreeWindingTransformer` (three, via `get_circuits`). A `HybridSystem`'s subcomponents are
masked out of the System's own enumeration but are still exported by id, so the masked
container is walked alongside the live one."""
_plan_components(sys::System, ::Type{T}) where {T} = Iterators.flatten((
    get_components(T, sys),
    IS.get_masked_components(T, sys.data),
))
function _plan_components(sys::System, ::Type{TransformerCircuit})
    two_winding = (get_circuit(twt) for twt in get_components(TwoWindingTransformer, sys))
    three_winding = (
        c for t3w in get_components(ThreeWindingTransformer, sys) for
        c in get_circuits(t3w)
    )
    return Iterators.flatten((two_winding, three_winding))
end

"""
Whether `x` carries an id of its own, and so can supply the document id it is exported under.

`TransformerCircuit` is embedded in its owning transformer and has no `internal` field, so no
id — but it is still registered in [`OpenAPIRefs`](@ref), and must be skipped rather than error.
"""
_has_own_id(::Any) = true
_has_own_id(::TransformerCircuit) = false

function _build_export_refs(sys::System)
    refs = OpenAPIRefs(get_base_power(sys))
    # Components and supplemental attributes share one id stream, so a fresh
    # `TransformerCircuit` id must clear the highest of both kinds.
    highest = 0
    circuits = TransformerCircuit[]
    for (_po_type, psy_type, _key, _addable) in DOCUMENT_PLAN
        for c in _plan_components(sys, psy_type)
            if _has_own_id(c)
                id = IS.get_id(c)
                highest = max(highest, id)
                refs[id] = c
            else
                push!(circuits, c)
            end
        end
    end
    for attr in IS.iterate_supplemental_attributes(sys.data)
        highest = max(highest, IS.get_id(attr))
    end
    next_id = highest + 1
    for circuit in circuits
        refs[next_id] = circuit
        next_id += 1
    end
    return refs
end

# ── component pass ───────────────────────────────────────────────────────────────

"""
Convert every component in [`DOCUMENT_PLAN`](@ref) order and add it to `doc`.

`add_component!` buckets by the PO type's own name and keeps each bucket concretely typed, so
the document's `components` map needs no key bookkeeping here.
"""
function _export_components!(
    doc::PD.SystemDocument,
    refs::OpenAPIRefs,
    sys::System,
    val::IS.AbstractUnitSystem,
)
    for (_po_type, psy_type, key, addable) in DOCUMENT_PLAN
        for c in _plan_components(sys, psy_type)
            PD.add_component!(doc, to_openapi(c, refs, val))
            _export_ext!(doc, component_id(refs, c), c)
        end
    end
    return nothing
end

# ── service membership (reverse of the service-membership branch in
# _attach_supplemental_attribute_associations!) ───────────────────────────────────
# Service membership is a row in its own `ServiceAssociation` table: `service_id` and
# `entity_id` both name components, so no `attribute_type` discriminator is needed.

function _export_service_associations(refs::OpenAPIRefs, sys::System)
    rows = PO.ServiceAssociation[]
    for device in get_components(Device, sys)
        supports_services(device) || continue
        for service in get_services(device)
            push!(
                rows,
                PO.ServiceAssociation(;
                    service_id = component_id(refs, service),
                    entity_id = component_id(refs, device),
                ),
            )
        end
    end
    for group in get_components(GroupReserve, sys)
        for contributing in get_contributing_services(group)
            push!(
                rows,
                PO.ServiceAssociation(;
                    service_id = component_id(refs, group),
                    entity_id = component_id(refs, contributing),
                ),
            )
        end
    end
    # `AGC.reserves` is the same membership shape as `GroupReserve.contributing_services`
    # above: no schema field on either side, carried by these rows instead.
    for agc in get_components(AGC, sys)
        for reserve in get_reserves(agc)
            push!(
                rows,
                PO.ServiceAssociation(;
                    service_id = component_id(refs, agc),
                    entity_id = component_id(refs, reserve),
                ),
            )
        end
    end
    return rows
end

# ── trading hub membership (reverse of the trading-hub-membership branch in
# load_supplemental_attribute_associations!) ──────────────────────────────────────
function _export_trading_hub_associations(refs::OpenAPIRefs, sys::System)
    rows = PO.TradingHubAssociation[]
    for hub in get_components(TradingHub, sys)
        for bus in get_associated_buses(hub)
            push!(
                rows,
                PO.TradingHubAssociation(;
                    trading_hub_id = component_id(refs, hub),
                    entity_id = component_id(refs, bus),
                ),
            )
        end
    end
    for vp in get_components(VirtualParticipant, sys)
        for hub in get_trading_hubs(vp)
            push!(
                rows,
                PO.TradingHubAssociation(;
                    trading_hub_id = component_id(refs, hub),
                    entity_id = component_id(refs, vp),
                ),
            )
        end
    end
    return rows
end

# ── supplemental attributes (reverse of _attach_supplemental_attribute_associations!) ──

# A plant-family attribute (`ThermalPowerPlant`, `HydroPowerPlant`, `RenewablePowerPlant`,
# `CombinedCycleFractional`, `CombinedCycleBlock`) gets both a plain
# `SupplementalAttributeAssociation` row (for type resolution, like any other attribute) and
# an additional `PlantAssociation`/`CombinedCycleAssociation` row recording the group: the
# reverse of the plant-family `_attach_attribute!` dispatch on import. A plain attribute
# (`EmissionsData`, `GeographicInfo`, the `Outage` types) gets no group row at all, which is
# why this dispatches on the attribute type rather than on some separate "has a group" flag.
# `_group_indices` is used rather than the public reverse-map getters, which build a whole
# dict per call and would make this walk quadratic.
_group_association!(::Vector, ::Vector, ::SupplementalAttribute, ::Any, ::Int, ::Int) =
    nothing
function _group_association!(
    plant_rows::Vector{PO.PlantAssociation},
    ::Vector,
    attr::ThermalPowerPlant,
    entity,
    attr_id::Int,
    entity_id::Int,
)
    _push_plant_association!(plant_rows, get_shaft_map(attr), entity, attr_id, entity_id)
    return nothing
end
function _group_association!(
    plant_rows::Vector{PO.PlantAssociation},
    ::Vector,
    attr::HydroPowerPlant,
    entity,
    attr_id::Int,
    entity_id::Int,
)
    _push_plant_association!(plant_rows, get_penstock_map(attr), entity, attr_id, entity_id)
    return nothing
end
function _group_association!(
    plant_rows::Vector{PO.PlantAssociation},
    ::Vector,
    attr::RenewablePowerPlant,
    entity,
    attr_id::Int,
    entity_id::Int,
)
    _push_plant_association!(plant_rows, get_pcc_map(attr), entity, attr_id, entity_id)
    return nothing
end
function _group_association!(
    plant_rows::Vector{PO.PlantAssociation},
    ::Vector,
    attr::CombinedCycleFractional,
    entity,
    attr_id::Int,
    entity_id::Int,
)
    _push_plant_association!(
        plant_rows,
        get_operation_exclusion_map(attr),
        entity,
        attr_id,
        entity_id,
    )
    return nothing
end

"""Push a `PlantAssociation` row for `entity`'s single group in `group_map`, or nothing when
it holds none — the shape `group_index` takes in the document."""
function _push_plant_association!(
    plant_rows,
    group_map,
    entity,
    attr_id::Int,
    entity_id::Int,
)
    indices = _group_indices(group_map, IS.get_id(entity))
    isempty(indices) && return nothing
    push!(
        plant_rows,
        PO.PlantAssociation(;
            plant_id = attr_id,
            entity_id = entity_id,
            group_index = only(indices),
        ),
    )
    return nothing
end

"""Push one `CombinedCycleAssociation` row per index in `hrsgs` for `role`."""
function _push_cc_associations!(
    cc_rows,
    hrsgs,
    attr_id::Int,
    entity_id::Int,
    role::AbstractString,
)
    for hrsg_index in hrsgs
        push!(
            cc_rows,
            PO.CombinedCycleAssociation(;
                plant_id = attr_id,
                entity_id = entity_id,
                role = role,
                hrsg_index = hrsg_index,
            ),
        )
    end
    return nothing
end

"""A CT/CA can feed more than one HRSG. The document records the n-to-m relation as one
`CombinedCycleAssociation` row per HRSG membership, matching the schema's multi-row contract,
even though IS attaches the `CombinedCycleBlock` to the component only once."""
function _group_association!(
    ::Vector,
    cc_rows::Vector{PO.CombinedCycleAssociation},
    attr::CombinedCycleBlock,
    entity,
    attr_id::Int,
    entity_id::Int,
)
    id = IS.get_id(entity)
    ct_hrsgs = _group_indices(get_hrsg_ct_map(attr), id)
    if isempty(ct_hrsgs)
        _push_cc_associations!(
            cc_rows,
            _group_indices(get_hrsg_ca_map(attr), id),
            attr_id,
            entity_id,
            "CA",
        )
    else
        _push_cc_associations!(cc_rows, ct_hrsgs, attr_id, entity_id, "CT")
    end
    return nothing
end

"""
Emit the attribute rows and their associations from the store's own OpenAPI export
([`IS.openapi_supplemental_attribute_association_rows`](@ref)) rather than converting each
association row by hand: the rows already carry `component_id`/`attribute_id` in the
document's id space and their `attribute_type`/`component_type` labels.

Only rows whose component has a document id are kept, mirroring
[`warn_unexportable_components`](@ref): a dynamics component's attribute is dropped along
with the component itself. Each distinct attribute is registered into `refs` under its own id
before `to_openapi(attr, refs)` reads that id back. The store's rows already arrive sorted by
`(component_id, attribute_id)`, so document order tracks component order with no local sort.
"""
function _export_supplemental_attributes(refs::OpenAPIRefs, sys::System)
    attribute_rows = OpenAPI.APIModel[]
    association_rows = IC.SupplementalAttributeAssociation[]
    plant_association_rows = PO.PlantAssociation[]
    combined_cycle_association_rows = PO.CombinedCycleAssociation[]
    attributes_by_id = Dict{Int, SupplementalAttribute}(
        IS.get_id(attr) => attr for attr in IS.iterate_supplemental_attributes(sys.data)
    )
    for row in IS.openapi_supplemental_attribute_association_rows(sys.data)
        entity_id = Int(row.component_id)
        has_ref(refs, entity_id) || continue
        attr_id = Int(row.attribute_id)
        haskey(attributes_by_id, attr_id) || error(
            "to_openapi: supplemental attribute association (attribute id $attr_id, " *
            "entity id $entity_id) references an attribute absent from the attribute " *
            "manager — the store and the attribute manager disagree about what exists",
        )
        attr = attributes_by_id[attr_id]
        if !has_ref(refs, attr_id)
            refs[attr_id] = attr
            push!(attribute_rows, to_openapi(attr, refs))
        end
        push!(association_rows, row)
        _group_association!(
            plant_association_rows,
            combined_cycle_association_rows,
            attr,
            refs[entity_id],
            attr_id,
            entity_id,
        )
    end
    return attribute_rows,
    association_rows,
    plant_association_rows,
    combined_cycle_association_rows
end

# ── time series ────────────────────────────────────────────────────────────────
#
# The mirror of import's store adoption: the System's InfraStore *is* the sidecar, so export
# serializes it and describes it via the store's own OpenAPI export
# (`IS.openapi_time_series_association_rows`) rather than walking series and converting each
# metadata row by hand. The catalog's owner ids are already document ids for both owner
# kinds, so a row's `owner_category` is read only to pick the right failure mode.

"""Whether a time series owner absent from the document is a tolerated loss or a hard error.

A component owner may be absent because it has no converter — the same reported loss
[`warn_unexportable_components`](@ref) already flags. An absent supplemental-attribute owner
means the sidecar and the attribute manager disagree about what exists: every attribute the
document can describe was registered into `refs` by `_export_supplemental_attributes` before
this runs."""
function _absent_owner_is_tolerated(row)
    row.owner_category == "Component" && return true
    row.owner_category == "SupplementalAttribute" && return false
    error(
        "to_openapi: time series \"$(row.name)\" (owner id $(row.owner_id)) has " *
        "unrecognized owner_category $(row.owner_category)",
    )
end

"""
Refuse to emit a document whose costs reference series it does not describe.

A cost may reference a series owned by another component, and `_export_all_time_series`
skips the association rows of owners the document cannot describe (see
[`_absent_owner_is_tolerated`](@ref)). The two together produce a document carrying a bare
`association_id` with no declared identity beside it, and an import has then nothing to
check that id against: resolved against a different sidecar it binds the cost to whichever
series happens to hold that id there, silently.

A dataset in that state has a broken relationship -- a cost pointing at something the
document does not contain -- so this errors rather than dropping the reference. Dropping it
would change the model on the way out, and quietly.
"""
function _check_costs_reference_declared_series!(doc::PD.SystemDocument, emitted::Set{Int})
    isempty(emitted) && return nothing
    declared = Set{Int}(
        _unwrap_oneof(row).association_id for row in doc.time_series_associations
    )
    dangling = sort!(collect(setdiff(emitted, declared)))
    isempty(dangling) && return nothing
    throw(
        IS.DataFormatError(
            "to_openapi: $(length(dangling)) time-series-backed cost(s) reference " *
            "association id(s) $(join(dangling, ", ")) that the document does not " *
            "describe. A cost may reference a series owned by another component, and a " *
            "series whose owner has no OpenAPI converter is omitted from the document " *
            "(see the omission warnings above) -- so the reference cannot survive a " *
            "round trip and would resolve against an unrelated series in another " *
            "sidecar. Give the owning component a converter, or remove the reference.",
        ),
    )
end

function _export_all_time_series(
    sys::System,
    refs::OpenAPIRefs,
    time_series_storage_path,
    write_catalog::Bool,
)
    rows = PTS.TimeSeriesAssociation[]
    # Counted, not `isempty(store)`: one store holds the supplemental attribute associations
    # as well, so a System with attributes and no series has a non-empty store and would
    # otherwise demand a sidecar it has nothing to put in.
    num_time_series = IS.get_num_time_series(sys.data)
    iszero(num_time_series) && return rows
    isnothing(time_series_storage_path) && error(
        "to_openapi: $num_time_series time series are attached but no " *
        "time_series_storage_path was given — cannot write the sidecar",
    )
    skipped_counts = Dict{String, Int}()
    for assoc in IS.openapi_time_series_association_rows(sys.data)
        row = assoc.value
        owner_id = Int(row.owner_id)
        if !has_ref(refs, owner_id)
            _absent_owner_is_tolerated(row) || error(
                "to_openapi: supplemental attribute (owner id $owner_id, type " *
                "$(row.owner_type)) owns time series \"$(row.name)\", but is not " *
                "registered in the exported document — the sidecar and the attribute " *
                "manager disagree about what exists",
            )
            skipped_counts[row.owner_type] = get(skipped_counts, row.owner_type, 0) + 1
            continue
        end
        push!(rows, assoc)
    end
    if !isempty(skipped_counts)
        total = sum(values(skipped_counts))
        types = join(sort(collect(keys(skipped_counts))), ", ")
        @warn "to_openapi: omitting $total time series row(s) whose owning component has " *
              "no OpenAPI converter ($types) — they remain in the sidecar but are not " *
              "described in the document and will not survive a round trip"
    end
    # The rows above go into the document either way; `write_catalog` decides only whether
    # InfraStore's own `.sqlite` is written beside the arrays as well. See `to_file`.
    store = IS.get_data_store(sys.data)
    path = String(time_series_storage_path)
    if write_catalog
        IS.serialize(store, path)
    else
        IS.serialize_arrays(store, path)
    end
    return rows
end

# ── document-level entry point ──────────────────────────────────────────────────

"""
$(TYPEDSIGNATURES)

Build a `PowerCoreOpenAPIModels.SystemDocument` from `sys`, the reverse of
`from_openapi(::Type{System}, doc)`.

Returns the typed container, not JSON: writing it to disk belongs to
`PowerCoreOpenAPIModels.write_document`, which [`to_file`](@ref) drives. Every id in the result
— components and supplemental attributes alike — comes from the document's single counter, since
consumers key a row by id without its type.

`power_units` selects the basis every value is written on, and the stamp each blob carries:

  - `:component_base` (default) stamps every power-bearing blob `"COMPONENT_BASE"` and writes
    each component's values on its own `base_power` — what PSY stores natively, so no
    conversion runs and the numbers on disk are the numbers in memory.
  - `:natural_units` stamps `"NATURAL_UNITS"` and converts to physical units (MW, MVAr, MVA).

Anything else errors: the mapping to the internal `DU`/`NU` markers is explicit, so an
unrecognized symbol is refused rather than defaulted.

The stamp is uniform across an export because PSY records no per-component creation basis.
Reading is not uniform: `from_openapi` honors the `power_units` on each individual blob, so a
document written elsewhere with a mixed basis loads correctly, and a blob that omits the field
is an error — `OpenAPI.from_json` does not enforce the schema's `required`, so the check is
made explicitly rather than defaulting to a basis and silently rescaling the value.

Any `System` is exportable either way, however it was built.

Walks components in [`DOCUMENT_PLAN`](@ref) order (symmetry with import, not a resolution
requirement — every id already exists or is assigned fresh before it is ever read). Emits
`PO.Line.base_power` (and the equivalent on every system-base-denormalized type) as
`get_base_power(sys)` exactly — not reconstructed.

Component `ext` is written through verbatim to `doc.ext`. Errors loudly rather than silently
dropping data: a time series with no `time_series_storage_path` given.

`write_catalog` decides whether InfraStore's `<sidecar>.sqlite` is written beside the arrays:
`false` (default) writes the arrays alone, `true` keeps the catalog too and makes it
authoritative on read. Either way the rows appear in `doc.time_series_associations` — the
keyword adds a file, it does not move them. The format notes at the top of
`src/openapi/file_io.jl` say which bundle uses which and why.
"""
function to_openapi(
    sys::System;
    power_units::Symbol = :component_base,
    time_series_storage_path = nothing,
    write_catalog::Bool = false,
)
    warn_unexportable_components(sys)
    val = _resolve_export_power_units(power_units)
    refs = _build_export_refs(sys)

    doc = PD.SystemDocument(;
        name = get_name(sys),
        description = get_description(sys),
        frequency = sys.frequency,
        time_series_storage_file = _sidecar_basename(time_series_storage_path),
    )
    emitted = Set{Int}()
    task_local_storage(_EMITTED_ASSOCIATION_IDS_KEY, emitted) do
        _export_components!(doc, refs, sys, val)
        _export_market_bid_service_offers!(doc, refs)
        supplemental_attributes,
        supplemental_attribute_associations,
        plant_associations,
        combined_cycle_associations =
            _export_supplemental_attributes(refs, sys)
        append!(doc.supplemental_attributes, supplemental_attributes)
        append!(
            doc.supplemental_attribute_associations,
            supplemental_attribute_associations,
        )
        append!(doc.plant_associations, plant_associations)
        append!(doc.combined_cycle_associations, combined_cycle_associations)
        append!(doc.service_associations, _export_service_associations(refs, sys))
        append!(
            doc.trading_hub_associations,
            _export_trading_hub_associations(refs, sys),
        )
        append!(
            doc.time_series_associations,
            _export_all_time_series(sys, refs, time_series_storage_path, write_catalog),
        )
        _reserve_ids!(doc, refs)
    end

    _check_costs_reference_declared_series!(doc, emitted)
    PD.validate_document(doc)
    return doc
end

_sidecar_basename(::Nothing) = nothing
_sidecar_basename(path) = basename(String(path))

"""
Fill each exported `MarketBidCost`'s `ancillary_service_offers` with the ids of the offered
services. Runs after `_export_components!` so every service already has an id;
`convert_cost_to_openapi(::MarketBidCost)` exports the list empty because the per-cost
converter has no id registry.
"""
function _export_market_bid_service_offers!(doc::PD.SystemDocument, refs::OpenAPIRefs)
    for po_components in values(doc.components), po in po_components
        hasproperty(po, :operation_cost) || continue
        _fill_service_offers!(po.operation_cost, po, refs)
    end
    return nothing
end

_fill_service_offers!(::Any, ::Any, ::OpenAPIRefs) = nothing
function _fill_service_offers!(po_cost::PC.MarketBidCost, po, refs::OpenAPIRefs)
    component = refs[Int(po.id)]
    offers = get_ancillary_service_offers(get_operation_cost(component))
    isempty(offers) && return nothing
    po_cost.ancillary_service_offers =
        Int64[component_id(refs, service) for service in offers]
    return nothing
end

"""Reserve `doc`'s own id counter above every id already assigned, so it cannot reissue one
that collides. Components and supplemental attributes share one id stream, and `refs`
registers both kinds by the time this runs."""
function _reserve_ids!(doc::PD.SystemDocument, refs::OpenAPIRefs)
    if isempty(refs.by_id)
        return nothing
    end
    PD.reserve_ids!(doc, maximum(keys(refs.by_id)))
    return nothing
end
