# Hand-written (not generated): the document-level OpenAPI import path. Builds a `System`
# from an already-`JSON.parsefile`'d document by driving the per-component `from_openapi`
# methods (generated in `src/models/generated/`, hand-written in `src/openapi/import_handwritten.jl`)
# in dependency order, then attaches reserve membership, time series, and (where a
# converter exists) supplemental attributes.
#
# The export direction (`to_openapi(sys; ...)`) mirrors this file in src/openapi/export_document.jl.

# ── Dependency-ordered component pass ───────────────────────────────────────────
# Topology first, then arcs and branches, then injectors, then reserves. `TransformerCircuit` is the one
# `addable = false` entry — a `DeviceParameter` embedded in `TwoWindingTransformer.circuit`
# or one of `ThreeWindingTransformer.{primary,secondary,tertiary}_circuit`, never a
# standalone System component, but still registered in `OpenAPIRefs` so the transformer
# that references it can resolve it. `TransmissionInterface` (a `Service`, membership
# carried by a `service_associations` row like the reserves) is placed after them for that
# reason, though it has no forward references of its own.
const DOCUMENT_PLAN = [
    (po_type = PO.Area, psy_type = Area, key = "Area", addable = true),
    (po_type = PO.LoadZone, psy_type = LoadZone, key = "LoadZone", addable = true),
    (po_type = PO.ACBus, psy_type = ACBus, key = "ACBus", addable = true),
    (po_type = PO.DCBus, psy_type = DCBus, key = "DCBus", addable = true),
    (po_type = PO.Arc, psy_type = Arc, key = "Arc", addable = true),
    (po_type = PO.Line, psy_type = Line, key = "Line", addable = true),
    (
        po_type = PO.MonitoredLine, psy_type = MonitoredLine, key = "MonitoredLine",
        addable = true,
    ),
    (
        po_type = PO.GenericArcImpedance, psy_type = GenericArcImpedance,
        key = "GenericArcImpedance", addable = true,
    ),
    (
        po_type = PO.DiscreteControlledACBranch, psy_type = DiscreteControlledACBranch,
        key = "DiscreteControlledACBranch", addable = true,
    ),
    (
        po_type = PO.TransformerCircuit, psy_type = TransformerCircuit,
        key = "TransformerCircuit", addable = false,
    ),
    (
        po_type = PO.TwoWindingTransformer, psy_type = TwoWindingTransformer,
        key = "TwoWindingTransformer", addable = true,
    ),
    (
        po_type = PO.ThreeWindingTransformer, psy_type = ThreeWindingTransformer,
        key = "ThreeWindingTransformer", addable = true,
    ),
    # After Area: its only references are `from_area`/`to_area`.
    (
        po_type = PO.AreaInterchange, psy_type = AreaInterchange,
        key = "AreaInterchange",
        addable = true,
    ),
    (
        po_type = PO.ThermalStandard, psy_type = ThermalStandard,
        key = "ThermalStandard",
        addable = true,
    ),
    (
        po_type = PO.ThermalMultiStart, psy_type = ThermalMultiStart,
        key = "ThermalMultiStart",
        addable = true,
    ),
    (po_type = PO.PowerLoad, psy_type = PowerLoad, key = "PowerLoad", addable = true),
    (
        po_type = PO.StandardLoad,
        psy_type = StandardLoad,
        key = "StandardLoad",
        addable = true,
    ),
    (
        po_type = PO.InterruptiblePowerLoad, psy_type = InterruptiblePowerLoad,
        key = "InterruptiblePowerLoad", addable = true,
    ),
    (
        po_type = PO.InterruptibleStandardLoad, psy_type = InterruptibleStandardLoad,
        key = "InterruptibleStandardLoad", addable = true,
    ),
    (
        po_type = PO.ShiftablePowerLoad, psy_type = ShiftablePowerLoad,
        key = "ShiftablePowerLoad", addable = true,
    ),
    (po_type = PO.MotorLoad, psy_type = MotorLoad, key = "MotorLoad", addable = true),
    (po_type = PO.Source, psy_type = Source, key = "Source", addable = true),
    (
        po_type = PO.InterconnectingConverter, psy_type = InterconnectingConverter,
        key = "InterconnectingConverter", addable = true,
    ),
    (
        po_type = PO.ExponentialLoad, psy_type = ExponentialLoad,
        key = "ExponentialLoad", addable = true,
    ),
    (
        po_type = PO.FixedAdmittance, psy_type = FixedAdmittance,
        key = "FixedAdmittance",
        addable = true,
    ),
    (
        po_type = PO.SwitchedAdmittance, psy_type = SwitchedAdmittance,
        key = "SwitchedAdmittance",
        addable = true,
    ),
    (
        po_type = PO.FACTSControlDevice, psy_type = FACTSControlDevice,
        key = "FACTSControlDevice",
        addable = true,
    ),
    (
        po_type = PO.HydroTurbine, psy_type = HydroTurbine, key = "HydroTurbine",
        addable = true,
    ),
    (
        po_type = PO.HydroDispatch, psy_type = HydroDispatch, key = "HydroDispatch",
        addable = true,
    ),
    (
        po_type = PO.HydroPumpTurbine, psy_type = HydroPumpTurbine,
        key = "HydroPumpTurbine", addable = true,
    ),
    # After BOTH `HydroUnit` subtypes: `upstream_turbines`/`downstream_turbines` resolve
    # through `_hydro_units`, so a reservoir pointing at a pump turbine cannot be converted
    # before `HydroPumpTurbine` is registered.
    (
        po_type = PO.HydroReservoir, psy_type = HydroReservoir, key = "HydroReservoir",
        addable = true,
    ),
    (
        po_type = PO.RenewableDispatch, psy_type = RenewableDispatch,
        key = "RenewableDispatch", addable = true,
    ),
    (
        po_type = PO.RenewableNonDispatch, psy_type = RenewableNonDispatch,
        key = "RenewableNonDispatch", addable = true,
    ),
    (
        po_type = PO.SynchronousCondenser, psy_type = SynchronousCondenser,
        key = "SynchronousCondenser", addable = true,
    ),
    (
        po_type = PO.EnergyReservoirStorage, psy_type = EnergyReservoirStorage,
        key = "EnergyReservoirStorage", addable = true,
    ),
    (
        po_type = PO.TwoTerminalGenericHVDCLine, psy_type = TwoTerminalGenericHVDCLine,
        key = "TwoTerminalGenericHVDCLine", addable = true,
    ),
    (
        po_type = PO.TModelHVDCLine, psy_type = TModelHVDCLine, key = "TModelHVDCLine",
        addable = true,
    ),
    (
        po_type = PO.TwoTerminalLCCLine, psy_type = TwoTerminalLCCLine,
        key = "TwoTerminalLCCLine", addable = true,
    ),
    (
        po_type = PO.TwoTerminalVSCLine, psy_type = TwoTerminalVSCLine,
        key = "TwoTerminalVSCLine", addable = true,
    ),
    (
        po_type = PO.OnlineReserve, psy_type = OnlineReserve, key = "OnlineReserve",
        addable = true,
    ),
    (
        po_type = PO.OfflineReserve, psy_type = OfflineReserve, key = "OfflineReserve",
        addable = true,
    ),
    (
        po_type = PO.GroupReserve, psy_type = GroupReserve, key = "GroupReserve",
        addable = true,
    ),
    # After every subcomponent it can reference (thermal, load, storage, renewable).
    (
        po_type = PO.HybridSystem, psy_type = HybridSystem, key = "HybridSystem",
        addable = true,
    ),
    (
        po_type = PO.TransmissionInterface, psy_type = TransmissionInterface,
        key = "TransmissionInterface", addable = true,
    ),
    # After the reserves it regulates; membership arrives as service_associations rows.
    (po_type = PO.AGC, psy_type = AGC, key = "AGC", addable = true),
    # Hub membership (member buses) arrives as trading_hub_associations rows, the same
    # shape as service membership above.
    (po_type = PO.TradingHub, psy_type = TradingHub, key = "TradingHub", addable = true),
    # After every settlement-point candidate (Area, LoadZone, ACBus) and TradingHub: a
    # VirtualParticipant's `settlement_point` and hub membership both resolve by reference.
    (
        po_type = PO.VirtualParticipant, psy_type = VirtualParticipant,
        key = "VirtualParticipant", addable = true,
    ),
    # After every Topology candidate (Area, LoadZone, ACBus, DCBus, Arc) and TradingHub: a
    # PointToPointBid's `from`/`to` terminals resolve by reference to either.
    (
        po_type = PO.PointToPointBid, psy_type = PointToPointBid,
        key = "PointToPointBid", addable = true,
    ),
]

"""
`DOCUMENT_PLAN`'s document-facing key must be unique — two entries sharing a key would make
[`_check_no_unconverted_component_types`](@ref)'s membership test and the dependency-ordered
component pass ambiguous about which converter owns that key. Checked with `allunique` before
being wrapped in a `Set` (rather than letting the `Set` construction silently collapse a
duplicate) so a future entry that copy-pastes an existing key errors, naming the offender,
instead of quietly losing one type's converter.
"""
function _document_plan_keys(plan)
    keys_in_order = [p.key for p in plan]
    if !allunique(keys_in_order)
        duplicate = first(k for k in keys_in_order if count(==(k), keys_in_order) > 1)
        error(
            "DOCUMENT_PLAN: duplicate key \"$duplicate\" — every entry must have a unique " *
            "document-facing key",
        )
    end
    return Set(keys_in_order)
end

const DOCUMENT_PLAN_KEYS = _document_plan_keys(DOCUMENT_PLAN)

# `from_openapi` dispatches on the PO type alone, so `psy_type` no longer reaches the
# import call — its only remaining consumer is the `is_document_exportable` loop below.
# Nothing at run time would notice an entry naming the wrong one, so the pairing is checked
# in `test_openapi_document.jl` ("DOCUMENT_PLAN: converters match the declared pair"): both
# that the converters exist in both directions and that `from_openapi` on the `po_type`
# actually returns the `psy_type`.
#
# That check is deliberately a test rather than a load-time assertion. `generate_structs`
# runs inside `PowerSystems`, so an assertion that fires on stale generated code would make
# the module unloadable and take regeneration — the only way to fix it — down with it.

"""
Whether a component type can be written to an OpenAPI document.

`false` for everything by default, and `true` only for the types [`DOCUMENT_PLAN`](@ref) names —
the methods below are generated from that list, so adding a converter there is the single edit
that makes a type exportable.

A trait rather than a membership test against a list of types, so the check dispatches and stays
extensible: a package adding its own converter adds its own method.

Used by [`warn_unexportable_components`](@ref) on the export path. Dynamic components are the
main `false` case today (dynamics is deferred, so no dynamic type has a converter) and their loss
on export is accepted for now — but it is reported rather than silent.
"""
is_document_exportable(::Component) = false

for (_po_type, psy_type, _key, _addable) in DOCUMENT_PLAN
    @eval is_document_exportable(::$psy_type) = true
end

"""Error, naming every offending type, when the document declares a component type with
no registered `from_openapi` converter — psy6 forbids silently skipping unconverted
types."""
function _check_no_unconverted_component_types(components::AbstractDict)
    unconverted = sort([k for k in keys(components) if !(k in DOCUMENT_PLAN_KEYS)])
    isempty(unconverted) || error(
        "from_openapi(System, doc): document declares component type(s) with no " *
        "registered from_openapi converter: $(join(unconverted, ", ")) — every " *
        "component type present in the document must be converted, not skipped",
    )
    return nothing
end

# ── document `ext` ──────────────────────────────────────────────────────────────
# `doc.ext[component_id]` is a producer-side escape hatch for source columns no schema field
# claims. It is merged onto the constructed component's own `ext` dict rather than validated
# against an allow-list — the data survives the import, and whether a column deserves a real
# schema field is a producer-side/schema question, not an import-time error.
#
# `Arc`/`TransformerCircuit`/`TransmissionInterface` carry no `ext` field at all (mirroring the
# same exception on the export side, `_collect_dropped_ext!` in export_document.jl) — nothing
# to merge into, so those overloads are no-ops rather than an error about a missing getter.

_merge_doc_ext!(::Arc, ::AbstractDict) = nothing
_merge_doc_ext!(::TransformerCircuit, ::AbstractDict) = nothing
_merge_doc_ext!(::TransmissionInterface, ::AbstractDict) = nothing
function _merge_doc_ext!(component, extras::AbstractDict)
    ext = get_ext(component)
    for (k, v) in extras
        ext[k] = v
    end
    return nothing
end

# ── service membership dispatch ─────────────────────────────────────────────────
# (device-first `add_service!`, not re-adding the service). Service membership is a row in
# its own `service_associations` table; `load_supplemental_attribute_associations!` in
# `sqlite_load.jl` is what routes a row here. The membership dispatch itself stays dispatch
# rather than an `attribute_type` string comparison.

"""Device contributing to a (non-group) reserve or `TransmissionInterface`: attach via
the System-aware 3-arg `add_service!`, which validates both sides are already attached."""
_attach_service_membership!(entity::Device, service::Service, sys::System) =
    add_service!(entity, service, sys)

"""Service (e.g. an `OnlineReserve`) contributing to a `GroupReserve`: `add_service!` has
no overload for `GroupReserve`, so membership is recorded by pushing onto
`contributing_services` directly, mirroring the reference prototype."""
function _attach_service_membership!(entity::Service, group::GroupReserve, ::System)
    push!(get_contributing_services(group), entity)
    return nothing
end

"""Reserve regulated by an `AGC`: same shape as `GroupReserve` above — `add_service!` has no
overload for it either, and `AGC.reserves` has no schema field precisely because this
membership is a `service_associations` row rather than an inline array."""
function _attach_service_membership!(entity::Reserve, agc::AGC, ::System)
    push!(get_reserves(agc), entity)
    return nothing
end

function _attach_service_membership!(entity, service, ::System)
    error(
        "from_openapi(System, doc): unmapped service membership pair — entity=" *
        "$(typeof(entity)) service=$(typeof(service))",
    )
end

# ── trading hub membership dispatch ─────────────────────────────────────────────
# Hub membership arrives as rows in the document's own `trading_hub_associations` table
# rather than an inline array on `TradingHub`, so each `entity_id` is attached by type here.

"""Attach a member bus to `hub`."""
function _attach_trading_hub_membership!(entity::ACBus, hub::TradingHub, sys::System)
    throw_if_not_attached(entity, sys)
    throw_if_not_attached(hub, sys)
    add_hub_bus_internal!(hub, entity)
    return nothing
end

"""Record `entity` as settling at `hub`."""
function _attach_trading_hub_membership!(
    entity::VirtualParticipant,
    hub::TradingHub,
    ::System,
)
    add_trading_hub_internal!(entity, hub)
    return nothing
end

function _attach_trading_hub_membership!(entity, hub, ::System)
    error(
        "from_openapi(System, doc): unmapped trading hub membership pair — entity=" *
        "$(typeof(entity)) hub=$(typeof(hub))",
    )
end

# ── Supplemental attributes ─────────────────────────────────────────────────────
# Per-type converters below exist for every attribute PSY hand-writes a constructor for
# AND that has a PO analogue: EmissionsData, GeometricDistributionForcedOutage,
# FixedForcedOutage, PlannedOutage, ThermalPowerPlant, HydroPowerPlant,
# RenewablePowerPlant, CombinedCycleBlock, CombinedCycleFractional, ImpedanceCorrectionData,
# and the Core GeographicInfo. `Substation`'s converter pair lives next to its hand-written
# struct in `src/substation.jl`.
#
# Same shape as the generated converters: dispatch on the concrete PO value, not on a target
# `::Type` or an `attribute_type` string — the document's flat `supplemental_attributes`
# array carries no per-row type, but `PowerCoreOpenAPIModels` has already resolved each row
# through `SupplementalAttributeAssociation.attribute_type` and its type registry, so the
# type is known here and Julia's dispatch replaces what used to be a parallel string table
# in this file. None of these embed unit-converted fields, so unlike the per-component
# converters they take no `::DeviceBaseUnit`/`::NaturalUnit` marker argument. Every method
# takes `refs` so the attribute walk (`load_supplemental_attribute_associations!` in
# sqlite_load.jl) can call one
# signature uniformly; only the three `Outage` types read it, to resolve document-id
# `monitored_components` into the UUIDs PSY stores.

"""Resolve document ids to UUIDs for an `Outage`'s `monitored_components`; `nothing`
means none declared and maps to an empty vector, matching the PSY constructors' own
default — not an error to guard against."""
function _monitored_component_uuids(refs::OpenAPIRefs, ids)
    if isnothing(ids)
        return Int[]
    end
    return Int[IS.get_id(refs[Int(id)]) for id in ids]
end

function from_openapi(po::PO.EmissionsData, ::OpenAPIRefs)
    return EmissionsData(;
        name = po.name,
        pollutant = PollutantType(po.pollutant),
        emission_rate = convert_cost(po.emission_rate),
        basis = EmissionBasis(po.basis),
        start_up_adder = po.start_up_adder,
        mass_unit = MassUnit(po.mass_unit),
        energy_unit = EnergyUnit(po.energy_unit),
        gwp = po.gwp,
        available = po.available,
    )
end

function from_openapi(po::PO.GeometricDistributionForcedOutage, refs::OpenAPIRefs)
    return GeometricDistributionForcedOutage(;
        mean_time_to_recovery = po.mean_time_to_recovery,
        outage_transition_probability = po.outage_transition_probability,
        monitored_components = _monitored_component_uuids(refs, po.monitored_components),
    )
end

function from_openapi(po::PO.PlannedOutage, refs::OpenAPIRefs)
    return PlannedOutage(;
        outage_schedule = po.outage_schedule,
        monitored_components = _monitored_component_uuids(refs, po.monitored_components),
    )
end

function from_openapi(po::PO.FixedForcedOutage, refs::OpenAPIRefs)
    return FixedForcedOutage(;
        outage_status = po.outage_status,
        monitored_components = _monitored_component_uuids(refs, po.monitored_components),
    )
end

from_openapi(po::PO.ThermalPowerPlant, ::OpenAPIRefs) =
    ThermalPowerPlant(; name = po.name)
from_openapi(po::PO.HydroPowerPlant, ::OpenAPIRefs) =
    HydroPowerPlant(; name = po.name)
from_openapi(po::PO.RenewablePowerPlant, ::OpenAPIRefs) =
    RenewablePowerPlant(; name = po.name)

function from_openapi(po::PO.CombinedCycleBlock, ::OpenAPIRefs)
    return CombinedCycleBlock(;
        name = po.name,
        configuration = CombinedCycleConfiguration(po.configuration),
        heat_recovery_to_steam_factor = po.heat_recovery_to_steam_factor,
    )
end

function from_openapi(po::PO.CombinedCycleFractional, ::OpenAPIRefs)
    return CombinedCycleFractional(;
        name = po.name,
        configuration = CombinedCycleConfiguration(po.configuration),
    )
end

# `GeographicInfo` and `DataSource` are InfrastructureSystems types and their converters live
# there, taking no `OpenAPIRefs` — that registry carries the System's computational
# `base_power`, which IS has no notion of. These two methods only reconcile the arity the
# attribute walk calls with, so IS stays the single owner of the field mapping.
from_openapi(po::IC.GeographicInfo, ::OpenAPIRefs) = from_openapi(po)
from_openapi(po::IC.DataSource, ::OpenAPIRefs) = from_openapi(po)

"""`table_number`/`transformer_winding`/`transformer_control_mode` carry no unit-bearing
fields — a row number and two enum discriminators. `impedance_correction_curve` reuses
`convert_cost`, the same PO->PSY `PiecewiseLinearData` converter cost curves use."""
from_openapi(po::PO.ImpedanceCorrectionData, ::OpenAPIRefs) =
    ImpedanceCorrectionData(;
        table_number = po.table_number,
        impedance_correction_curve = convert_cost(po.impedance_correction_curve),
        transformer_winding = WindingCategory(po.transformer_winding),
        transformer_control_mode = ImpedanceCorrectionTransformerControlMode(
            po.transformer_control_mode,
        ),
    )

"""Loud fallback for the 2-arg supplemental-attribute shape: a PO attribute type with no
converter is a gap to close, not a row to skip."""
function from_openapi(po, ::OpenAPIRefs)
    error(
        "from_openapi(System, doc): no supplemental attribute converter for " *
        "$(nameof(typeof(po))) — every attribute in the document must be converted, " *
        "not skipped",
    )
end

# ── attribute attach ────────────────────────────────────────────────────────────
# An adopted sidecar already carries every association row the document names, so those pairs
# only need attaching; a hand-built document (or one augmented with an attribute the sidecar
# never saw) carries none, so those pairs need writing. Which case a row falls in is read
# from `stored_pairs` rather than from a caller-supplied mode flag.

"""No group index: the plain attribute path needs no map update."""
_push_group_indices!(component, attribute, ::Nothing) =
    _push_group_index!(component, attribute, nothing)

"""One or more group indices: record each on whichever forward map the attribute's type
carries."""
function _push_group_indices!(component, attribute, group_indices::Vector{Int})
    for group_index in group_indices
        _push_group_index!(component, attribute, group_index)
    end
    return nothing
end

"""
Attach `attribute` to `component`, recording `group_indices` on whichever forward map the
attribute's type carries (a no-op for the plain attribute types, whose `group_indices` is
`nothing`). A plant-family attribute can carry several indices for one `(component, attribute)`
pair — a CT/CA feeding more than one HRSG group, for instance — so every index in
`group_indices` is pushed.

`stored_pairs` holds the `(component_id, attribute_id)` pairs the store already has; a pair
written here is added to it.
"""
function _attach_attribute!(
    sys::System,
    stored_pairs::Set{Tuple{Int, Int}},
    component,
    attribute,
    group_indices,
)
    pair = (IS.get_id(component), IS.get_id(attribute))
    if pair in stored_pairs
        IS.attach_supplemental_attribute!(
            sys.data, component, attribute; allow_existing_time_series = true,
        )
    else
        IS.add_supplemental_attribute!(sys.data, component, attribute)
        push!(stored_pairs, pair)
    end
    _push_group_indices!(component, attribute, group_indices)
    return nothing
end

# ── Document-level entry point ──────────────────────────────────────────────────

"""Apply one optional document metadata field, dispatching on presence rather than
branching: a field the document omits leaves `System`'s own value untouched."""
_apply_metadata_field!(::Any, ::System, ::Nothing) = nothing
_apply_metadata_field!(setter, sys::System, value) = setter(sys, value)

"""
Carry the document's system-level metadata onto `sys`.

Only `name` and `description` are applied here (`base_power` is a `from_openapi` kwarg, not a
document field). `frequency` cannot be — `System` is immutable and takes it at construction —
so [`_system_with_sidecar`](@ref) applies it there, via [`_frequency_kwarg`](@ref).

`supplied` is the set of keywords the caller passed, and a field named in it is left alone: a
caller who writes `name = ...` meant it, and overwriting that with the document's value would
discard it silently. This is the same precedence `frequency` already has, where the caller's
keyword is merged after the document's — the three document-owned keywords now agree instead
of splitting on which one happens to be applied after construction.
"""
function _apply_document_metadata!(sys::System, doc::PD.SystemDocument, supplied)
    :name in supplied || _apply_metadata_field!(set_name!, sys, PD.get_name(doc))
    :description in supplied ||
        _apply_metadata_field!(set_description!, sys, PD.get_description(doc))
    return nothing
end

"""
The `frequency = ...` keyword the document asks for, as a `NamedTuple` to splat into
`System`'s constructor — empty when the document names none.

`frequency` is an optional field of the document and a construction-time keyword of an
immutable `System`, so it can only be applied here, not assigned afterwards. Empty-when-absent
is what keeps the original guarantee intact: a document that predates the field cannot
silently reset a 50 Hz system to the 60 Hz default. A caller's own `frequency` in
`system_kwargs` wins, since it is merged after this one.
"""
_frequency_kwarg(::Nothing) = (;)
_frequency_kwarg(value) = (; frequency = Float64(value))

"""
$(TYPEDSIGNATURES)

Build a `System` from a `PowerCoreOpenAPIModels.SystemDocument`.

Takes the typed container, not JSON: reading a file belongs to
`PowerCoreOpenAPIModels.read_document`, which [`from_file`](@ref) drives.

Converts every component in dependency order ([`DOCUMENT_PLAN`](@ref), verified against
dependency order), then runs [`resolve_deferred_refs!`](@ref) once to patch in any
component→component reference a converter deferred rather than resolve on that first pass (a
forward or same-type reference — e.g. a cascading `HydroReservoir` chain — see
[`OpenAPIRefs`](@ref)). It then attaches supplemental attributes from
`supplemental_attribute_associations`
(plus `plant_associations`/`combined_cycle_associations` for the plant-family ones) and
reserve membership from `service_associations`, and — when `time_series_storage_path` is
given — adopts the HDF5 sidecar as the System's own time series store.

What happens to `doc.time_series_associations` depends on what the sidecar brought. The
bundle [`to_file`](@ref) writes is arrays only, so its catalog arrives empty and the
document's rows *are* the catalog: they are replayed into it, ids included. A sidecar that
came with its own `.sqlite` is authoritative instead, and the rows are cross-checked against
it rather than written. See [`_load_time_series_associations!`](@ref).

Errors loudly (naming the offending type, id, or field) rather than silently skipping:
a component type with no registered converter, an unresolved attribute/plant/service
association or entity reference, or time-series owner reference, an unmapped time-series
type, scaling-factor multiplier, or supplemental `attribute_type` (see
[`load_supplemental_attribute_associations!`](@ref)), a document that declares time series
but supplies no `time_series_storage_path`, and any drift this validation catches.

`base_power` is the `System`'s own computational base (MVA); every component blob is
self-interpretable via its own `power_units`/`base_power`. It defaults to the same `100.0`
`System`'s own constructor defaults to.

A caller's `name`, `description` or `frequency` outranks the document's; every other
document field is applied unconditionally.

`system_kwargs` pass straight through to the fresh `System(base_power; system_kwargs...)`
this builds (e.g. `time_series_in_memory`, `time_series_directory`, `time_series_read_only`,
`runchecks` — `System`'s own `SYSTEM_KWARGS`); an unsupported key still errors, from
`System`'s own constructor.
"""
function from_openapi(
    ::Type{System},
    doc::PD.SystemDocument;
    base_power::Float64 = 100.0,
    time_series_storage_path = nothing,
    system_kwargs...,
)
    _check_no_unconverted_component_types(doc.components)

    sys = _system_with_sidecar(base_power, doc, time_series_storage_path; system_kwargs...)
    _apply_document_metadata!(sys, doc, keys(system_kwargs))

    store = if isnothing(time_series_storage_path)
        nothing
    else
        sys.data.time_series_manager.data_store
    end
    _load_time_series_associations!(sys, doc, store)
    refs = OpenAPIRefs(base_power; store = store)

    # Bound for the whole component pass: a `MarketBidTimeSeriesCost`/time-series-backed
    # `FuelCurve` reaches `convert_cost` several frames below a GENERATED per-device
    # `from_openapi` method (`src/generate_structs.jl`'s `expr = "convert_cost(po.$po_name)::$bare"`),
    # whose call site is fixed at one positional argument — regenerating every device
    # converter to thread a store through is out of scope here. `_with_import_store` makes
    # the adopted store reachable from there via `_current_import_store()` instead. Hand-written
    # converters that DO receive `refs` (e.g. `Source`) resolve the store from `get_store(refs)`
    # directly and never need this ambient path.
    _with_import_store(store) do
        for (_po_type, psy_type, key, addable) in DOCUMENT_PLAN
            for po in PD.get_components(doc, key)
                component = from_openapi(po, refs)
                extras = get(doc.ext, Int(po.id), nothing)
                isnothing(extras) || _merge_doc_ext!(component, extras)
                if addable
                    # Before adding, not after: `IS.assign_id!` keeps an id that is already set
                    # and only draws from the counter for an unassigned one. This is what makes
                    # the adopted sidecar's owner ids resolve — they are these same document ids.
                    IS.set_id!(component, Int(po.id))
                    add_component!(sys, component)
                end
                refs[Int(po.id)] = component
            end
        end

        resolve_deferred_refs!(refs)

        _load_market_bid_service_offers!(refs, doc)
    end

    load_supplemental_attribute_associations!(sys, refs, doc)

    return sys
end

"""
Put the document's `time_series_associations` rows into `store`, or cross-check them against
the rows it already has.

Which one depends on what the bundle carried, not on which format wrote it — `from_openapi`
is public and does not know its producer. An arrays-only sidecar arrives with a freshly
minted, empty catalog, so the document's rows are replayed, ids included; that is what keeps
a cost's `association_id` resolving to the series it named. A sidecar that brought its own
`.sqlite` is authoritative instead and the rows are only validated against it — the path a
`.sn` archive, an older bundle, and a PowerSystemCaseBuilder cache all take.

Runs before the component pass, not after it: a `MarketBidTimeSeriesCost` or time-series
`FuelCurve` resolves its `association_id` against the store while its owner is being built,
so the rows have to be there first.
"""
_load_time_series_associations!(::System, ::PD.SystemDocument, ::Nothing) = nothing

function _load_time_series_associations!(sys::System, doc::PD.SystemDocument, store)
    isempty(doc.time_series_associations) && return nothing
    if _catalog_is_authoritative(store)
        return _validate_time_series_associations!(sys, doc)
    end
    IS.import_time_series_association_rows!(
        store, JSON.json(doc.time_series_associations),
    )
    return nothing
end

"""Whether the adopted store brought its own association rows, in which case they outrank the
document's. A count, not a listing: the answer is a yes/no and the catalog can be large."""
_catalog_is_authoritative(store) = !iszero(IS.get_num_time_series(store))

"""
A `System` whose time series store is the document's InfraStore sidecar, adopted rather than
replayed. Without a sidecar this is just `System(base_power; system_kwargs...)`.

`time_series_read_only` and `time_series_directory` are read from `system_kwargs` (and left in
place for `System` itself) because they govern how the store is opened: a read-only open
attaches the file directly, while a writable one takes a working copy so adding series cannot
corrupt the document's sidecar. The adopted store's `supplemental_attribute_associations` rows
are left as they are — `load_supplemental_attribute_associations!` reads them.
"""
function _system_with_sidecar(
    base_power,
    doc::PD.SystemDocument,
    time_series_storage_path;
    system_kwargs...,
)
    # The document's own frequency first, the caller's keywords second, so an explicit
    # `frequency =` still wins. This is the only place it can be applied: `System` is
    # immutable and takes it at construction.
    kwargs = (; _frequency_kwarg(PD.get_frequency(doc))..., system_kwargs...)
    isnothing(time_series_storage_path) && return System(base_power; kwargs...)
    isfile(time_series_storage_path) || error(
        "from_openapi(System, doc): time_series_storage_path " *
        "\"$time_series_storage_path\" does not exist",
    )
    read_only = get(kwargs, :time_series_read_only, false)
    directory = get(kwargs, :time_series_directory, nothing)
    store = IS.open_deserialized_infrastore_store(
        String(time_series_storage_path), directory, read_only,
    )
    attribute_manager = IS.SupplementalAttributeManager(store)
    # Positional: IS's keyword `SystemData` constructor opens its own store and cannot adopt
    # one. `1` is `next_id`; every id in the document is set explicitly, and `assign_id!`
    # advances the counter past each one as components and attributes are adopted.
    data = IS.SystemData(
        IS.read_validation_descriptor(POWER_SYSTEM_STRUCT_DESCRIPTOR_FILE),
        IS.TimeSeriesManager(; data_store = store, read_only = read_only),
        1,
        Dict{String, Set{Int}}(),
        attribute_manager,
        IS.InfrastructureSystemsInternal(),
    )
    return System(data, base_power; kwargs...)
end

"""
Cross-check the document's own `time_series_associations` rows against the adopted sidecar's
catalog. A no-op when there is no sidecar or the document names no rows.

The sidecar is authoritative, so this never writes: every document row must match a sidecar
row, identified by `(owner_id, owner_category, time_series_type, name, resolution, interval,
features)` — the same identity tuple the store's own uniqueness index keys on (`owner_type`
is a denormalized label excluded from identity); a type that carries no `resolution`/
`interval` field at all (e.g. `NonSequentialTimeSeries`) treats it as `nothing`. A matched row
must then agree with its counterpart field-for-field — compared as canonical OpenAPI JSON,
excluding `uri`/`data_hash` (informational: a document assembled from a different store may
legitimately carry different values for either, so neither participates in identity or
drift). A document row with no sidecar counterpart, or one that drifts from its match, means
the bundle is corrupt and throws `IS.DataFormatError` naming the row and, for drift, the
differing fields. Sidecar rows the document does not mention are tolerated (`@debug`-logged)
— a document only ever names the owners it carries.
"""
function _validate_time_series_associations!(sys::System, doc::PD.SystemDocument)
    store_rows = [
        _unwrap_oneof(row) for row in IS.openapi_time_series_association_rows(sys.data)
    ]
    store_by_identity = Dict(_ts_row_identity(row) => row for row in store_rows)
    referenced = Set{keytype(store_by_identity)}()

    for assoc in doc.time_series_associations
        row = _unwrap_oneof(assoc)
        identity = _ts_row_identity(row)
        store_row = get(store_by_identity, identity, nothing)
        if isnothing(store_row)
            throw(
                IS.DataFormatError(
                    "from_openapi(System, doc): time series association " *
                    "$(_ts_row_label(identity)) has no matching row in the adopted " *
                    "sidecar's catalog",
                ),
            )
        end
        push!(referenced, identity)
        # Checked explicitly, ahead of the generic field-drift comparison below: a mismatched
        # `association_id` means every key built from it during this import points at the
        # wrong association altogether, not just a stale metadata field, so it gets its own
        # named error carrying both values rather than surfacing as one entry in a
        # `drifted on: ...` list. A `nothing` document value is not treated as "unset and
        # therefore skip" — the schema marks `association_id` required, so a document row
        # missing it is malformed and must error loudly rather than compare vacuously equal
        # to another `nothing`.
        isnothing(row.association_id) && throw(
            IS.DataFormatError(
                "from_openapi(System, doc): time series association " *
                "$(_ts_row_label(identity)) has no association_id in the document, but " *
                "the schema marks it required",
            ),
        )
        row.association_id == store_row.association_id || throw(
            IS.DataFormatError(
                "from_openapi(System, doc): time series association " *
                "$(_ts_row_label(identity)) has association_id=$(row.association_id) in " *
                "the document but association_id=$(store_row.association_id) in the " *
                "adopted sidecar's catalog",
            ),
        )
        drift = _ts_row_drift(row, store_row)
        isempty(drift) || throw(
            IS.DataFormatError(
                "from_openapi(System, doc): time series association " *
                "$(_ts_row_label(identity)) drifted from the sidecar's catalog on: " *
                "$(join(drift, ", "))",
            ),
        )
    end

    unmatched = setdiff(keys(store_by_identity), referenced)
    isempty(unmatched) ||
        @debug "from_openapi(System, doc): sidecar catalog rows the document does not mention" unmatched

    return nothing
end

"""The wire field value of `field` on `row`, or `nothing` when `row`'s type does not carry
that field at all (e.g. `NonSequentialTimeSeries` has no `resolution`/`interval`) — as
opposed to carrying it unset, which is also `nothing`. Either way, absent and unset compare
equal for identity purposes."""
function _ts_field(row, field::Symbol)
    hasproperty(row, field) && return getproperty(row, field)
    return nothing
end

"""The `(owner_id, owner_category, time_series_type, name, resolution, interval, features)`
named tuple a time series association row is matched by — the same identity the store's own
uniqueness index keys on. See [`_validate_time_series_associations!`](@ref).

Features are compared by value: the wire type wraps each value in a mutable
`TimeSeriesFeatureValue`, which compares by object identity, so a document row and its store
counterpart would never match on the wrappers themselves."""
_ts_row_identity(row) = (
    owner_id = row.owner_id, owner_category = row.owner_category,
    time_series_type = row.time_series_type, name = row.name,
    resolution = _ts_field(row, :resolution), interval = _ts_field(row, :interval),
    features = _ts_feature_values(row.features),
)

_ts_feature_values(::Nothing) = nothing
_ts_feature_values(features::AbstractDict) =
    Dict{String, Any}(String(k) => _ts_feature_value(v) for (k, v) in features)
_ts_feature_value(v::InfrastructureTimeSeriesOpenAPIModels.TimeSeriesFeatureValue) = v.value
_ts_feature_value(v) = v

"""Human-readable label for a time series association identity, for error messages."""
function _ts_row_label(identity)
    return "$(identity.time_series_type) owner $(identity.owner_id) \"$(identity.name)\""
end

"""Wire field names on which `doc_row` and `store_row` differ, comparing canonical OpenAPI
JSON and excluding `uri`/`data_hash`."""
function _ts_row_drift(doc_row, store_row)
    doc_json = _ts_row_wire_dict(doc_row)
    store_json = _ts_row_wire_dict(store_row)
    fields = union(keys(doc_json), keys(store_json))
    return sort!(
        [f for f in fields if get(doc_json, f, nothing) != get(store_json, f, nothing)],
    )
end

function _ts_row_wire_dict(row)
    dict = JSON.parse(JSON.json(row))
    delete!(dict, "uri")
    delete!(dict, "data_hash")
    return dict
end

"""`ancillary_service_offers` ids off an ALREADY-UNWRAPPED wire operation cost that
carries them (`MarketBidCost`, `MarketBidTimeSeriesCost`), or `nothing` for any other cost —
dispatch rather than an `isa` chain, so a cost type this document names but that carries no
such field (everything else) is a one-line no-op instead of a branch to maintain."""
_ancillary_service_offer_ids(po_cost::PC.MarketBidCost) = po_cost.ancillary_service_offers
_ancillary_service_offer_ids(po_cost::PC.MarketBidTimeSeriesCost) =
    po_cost.ancillary_service_offers
_ancillary_service_offer_ids(po_cost) = nothing

"""
Resolve each imported `MarketBidCost`/`MarketBidTimeSeriesCost`'s `ancillary_service_offers`
ids to the now-imported `Service` objects. `convert_cost(::PC.MarketBidCost)` and
`convert_cost(::PC.MarketBidTimeSeriesCost, store)` both leave the vector empty because
services may not exist yet when the carrying device converts; this runs after the full
component pass. Errors on an unresolved id rather than dropping the offer.

`po.operation_cost` is `_unwrap_oneof`'d first: a document read straight off JSON (any real
`from_file` call) carries the oneOf WRAPPER (e.g. `PO.ThermalStandardOperationCost`) here,
not the bare concrete cost `to_openapi`'s own in-memory construction path hands back — the
same reason every other oneOf field in this file is unwrapped before use.
"""
function _load_market_bid_service_offers!(refs::OpenAPIRefs, doc::PD.SystemDocument)
    for po_components in values(doc.components), po in po_components
        hasproperty(po, :operation_cost) || continue
        po_cost = _unwrap_oneof(po.operation_cost)
        ids = _ancillary_service_offer_ids(po_cost)
        (isnothing(ids) || isempty(ids)) && continue
        component = refs.by_id[Int(po.id)]
        offers = get_ancillary_service_offers(get_operation_cost(component))
        for id in ids
            service = get(refs.by_id, Int(id), nothing)
            isnothing(service) && throw(
                IS.DataFormatError(
                    "$(nameof(typeof(po_cost))) on component id=$(po.id) " *
                    "offers into unresolved component id=$id",
                ),
            )
            push!(offers, service)
        end
    end
    return nothing
end
