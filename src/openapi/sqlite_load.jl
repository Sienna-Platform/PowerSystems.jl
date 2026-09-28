# Hand-written (not generated): the loader that carries the document's supplemental
# attribute, plant, combined-cycle, and service association rows into IS. Called by
# `from_openapi(::Type{System}, doc)` in `src/openapi/import_document.jl`. Time series are
# not loaded here — the sidecar store is adopted whole.
#
# Reuses import_document.jl's per-type attribute conversion (the 2-arg
# `from_openapi(po, refs)` methods), attach dispatch (`_attach_attribute!`), and
# service-membership dispatch (`_attach_service_membership!`); this file is `include`d into
# the same `PowerSystems` module.

"""
Every group index a (plant_id, entity_id) pair carries, from `doc.plant_associations` and
`doc.combined_cycle_associations` (whose `hrsg_index` fills the same role) — a pair can carry
several indices, one `CombinedCycleAssociation` row per HRSG membership. The two tables never
name the same pair — a plant is either a `PlantAssociation`-shaped plant or a
`CombinedCycleBlock`, never both — and a unit's prime mover fixes its CT/CA role so the two
roles never mix within one pair either, so one merged map stays unambiguous.
"""
function _group_index_by_pair(doc::PD.SystemDocument)
    indices = Dict{Tuple{Int, Int}, Vector{Int}}()
    for a in doc.plant_associations
        key = (Int(a.plant_id), Int(a.entity_id))
        haskey(indices, key) && error(
            "load_supplemental_attribute_associations!: plant_id=$(key[1]) " *
            "entity_id=$(key[2]) has a duplicate plant association row",
        )
        indices[key] = Int[Int(a.group_index)]
    end
    plant_pairs = Set(keys(indices))
    for a in doc.combined_cycle_associations
        key = (Int(a.plant_id), Int(a.entity_id))
        key in plant_pairs && error(
            "load_supplemental_attribute_associations!: plant_id=$(key[1]) " *
            "entity_id=$(key[2]) appears in both plant_associations and " *
            "combined_cycle_associations",
        )
        hrsg_index = Int(a.hrsg_index)
        group = get!(indices, key, Int[])
        hrsg_index in group && error(
            "load_supplemental_attribute_associations!: plant_id=$(key[1]) " *
            "entity_id=$(key[2]) hrsg_index=$hrsg_index has a duplicate " *
            "combined_cycle_associations row",
        )
        push!(group, hrsg_index)
    end
    return indices
end

"""
Weight and terminal of every `(control_id, entity_id)` pair in `doc.voltage_control_associations`.
A two-terminal member appears once per group, so one pair holds one row; a second row for the
same pair is malformed.
"""
function _voltage_control_membership_by_pair(doc::PD.SystemDocument)
    memberships = Dict{
        Tuple{Int, Int},
        NamedTuple{
            (:weight, :terminal),
            Tuple{Float64, Union{Nothing, VoltageControlTerminal.Value}},
        },
    }()
    for a in doc.voltage_control_associations
        key = (Int(a.control_id), Int(a.entity_id))
        haskey(memberships, key) && error(
            "load_supplemental_attribute_associations!: control_id=$(key[1]) " *
            "entity_id=$(key[2]) has a duplicate voltage_control_associations row",
        )
        memberships[key] = (
            weight = _or_default(a.weight, 1.0),
            terminal = _optional_enum(a.terminal, VoltageControlTerminal.Value),
        )
    end
    return memberships
end

"""Loud error naming `id` when the document's declared `attribute_type` is absent or does
not match `nameof(typeof(resolved))`."""
function _check_resolved_type_matches(resolved, declared_type, id)
    isnothing(declared_type) && error(
        "load_supplemental_attribute_associations!: association referencing id=$id has " *
        "no attribute_type",
    )
    actual = string(nameof(typeof(resolved)))
    declared_type == actual || error(
        "load_supplemental_attribute_associations!: id=$id declares attribute_type=" *
        "\"$declared_type\" but resolved to a $actual",
    )
    return nothing
end

"""
$(TYPEDSIGNATURES)

Attach every row of `doc.supplemental_attribute_associations` and `doc.service_associations`
into `sys`.

One PSY attribute object per `attribute_id`, memoized in `converted`: the first time an
`attribute_id` is seen, its document id is set onto the built object with `IS.set_id!`
before it is ever attached — mirroring how a component is set to its document id before
`add_component!` in `import_document.jl`. Components and supplemental attributes share one
id stream, so an attribute's document id can never collide with a component's. The object is
then registered into `refs` under that id, so `refs[id]` covers supplemental attributes the
way it already covers components.

Every attach goes through [`_attach_attribute!`](@ref) (`import_document.jl`), which writes
an association row only for pairs the store does not already hold. A plant-family attribute's
group numbers for a given entity come from the matching
`plant_associations`/`combined_cycle_associations` rows (there is always at least one — see
[`_group_index_by_pair`](@ref)); every other attribute passes `nothing`.

Errors, naming the id, when: an association's `entity_id`/`attribute_id`/`service_id` does
not resolve, or an attribute's `attribute_type` is absent or does not match what the id
actually resolved to. No silent skip.
"""
function load_supplemental_attribute_associations!(
    sys::System,
    refs::OpenAPIRefs,
    doc::PD.SystemDocument,
)
    attribute_rows = Dict{Int, Any}(
        Int(getproperty(attr, :id)) => attr for attr in doc.supplemental_attributes
    )
    converted = Dict{Int, SupplementalAttribute}()
    group_index_by_pair = _group_index_by_pair(doc)
    voltage_control_by_pair = _voltage_control_membership_by_pair(doc)
    # One store read for the whole table instead of a probe per row; rows written below are
    # folded back in so a document that repeats a pair still attaches rather than re-adds.
    stored_pairs = Set{Tuple{Int, Int}}(
        (Int(row.component_id), Int(row.attribute_id)) for
        row in IS.list_supplemental_attribute_association_rows(sys.data)
    )
    IS.begin_association_batch(sys.data) do
        for assoc in doc.supplemental_attribute_associations
            attribute_id = Int(assoc.attribute_id)
            component_id = Int(assoc.component_id)
            has_ref(refs, component_id) || error(
                "load_supplemental_attribute_associations!: association references " *
                "unresolved component_id=$component_id (attribute_id=$attribute_id)",
            )
            haskey(attribute_rows, attribute_id) || error(
                "load_supplemental_attribute_associations!: association references " *
                "unresolved attribute_id=$attribute_id (component_id=$component_id)",
            )
            attribute = get!(converted, attribute_id) do
                built = from_openapi(attribute_rows[attribute_id], refs)
                _check_resolved_type_matches(built, assoc.attribute_type, attribute_id)
                IS.set_id!(built, attribute_id)
                refs[attribute_id] = built
                return built
            end
            pair = (attribute_id, component_id)
            membership = get(group_index_by_pair, pair, nothing)
            if isnothing(membership)
                membership = get(voltage_control_by_pair, pair, nothing)
            end
            _attach_attribute!(sys, stored_pairs, refs[component_id], attribute, membership)
        end
    end
    for assoc in doc.service_associations
        service_id = Int(assoc.service_id)
        entity_id = Int(assoc.entity_id)
        has_ref(refs, service_id) || error(
            "load_supplemental_attribute_associations!: service_associations row " *
            "references unresolved service_id=$service_id (entity_id=$entity_id)",
        )
        has_ref(refs, entity_id) || error(
            "load_supplemental_attribute_associations!: service_associations row " *
            "references unresolved entity_id=$entity_id (service_id=$service_id)",
        )
        _attach_service_membership!(refs[entity_id], refs[service_id], sys)
    end
    for assoc in doc.trading_hub_associations
        trading_hub_id = Int(assoc.trading_hub_id)
        entity_id = Int(assoc.entity_id)
        has_ref(refs, trading_hub_id) || error(
            "load_supplemental_attribute_associations!: trading_hub_associations row " *
            "references unresolved trading_hub_id=$trading_hub_id (entity_id=$entity_id)",
        )
        has_ref(refs, entity_id) || error(
            "load_supplemental_attribute_associations!: trading_hub_associations row " *
            "references unresolved entity_id=$entity_id (trading_hub_id=$trading_hub_id)",
        )
        _attach_trading_hub_membership!(refs[entity_id], refs[trading_hub_id], sys)
    end
    return nothing
end
