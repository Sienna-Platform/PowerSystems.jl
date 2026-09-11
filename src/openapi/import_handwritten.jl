# `from_openapi` methods for the PO/PSY type pairs the IS generator cannot emit. Each was tried
# through the generator first; what blocks each one:
#
#   Arc                          abstract `Bus` field type; PO names `from_id`/`to_id` differ
#   Area, LoadZone               no `openapi_type` annotation in the descriptor
#   TransmissionInterface        `direction_mapping::Dict{String, Int}` unclassifiable
#   Line                         `r`/`x`/`b`/`g` need a `base_voltage` the struct does not carry
#   TwoTerminalGenericHVDCLine   `loss` is a Union of two curve types, not `Union{Nothing, X}`
#   TransformerCircuit           PSY field `α` vs PO field `alpha`
#   TwoWindingTransformer        `magnetizing_shunt::Complex{Float64}` unclassifiable
#   ThreeWindingTransformer      same, plus three `TransformerCircuit` references
#   FixedAdmittance              `Y::Complex{Float64}` unclassifiable
#   HydroReservoir               `Vector{HydroUnit}`/`Vector{Device}` fields; fraction conversion
#   EnergyReservoirStorage       `efficiency` spelled out instead of the `InOut` alias
#   Online/Offline/GroupReserve  parametric structs, which the generator rejects outright
#
# A hand-written type with a `power_units` member joins the first loop below; every other
# hand-written type joins the second. The generated types get the analogous 2-arg selector
# from the generator itself (`compute_openapi_converter!` in generate_structs.jl).
#
# TradingHub, VirtualParticipant, PointToPointBid are different again: the generator DID emit
# their 3-arg `from_openapi(po, refs, ::ComponentBaseUnit/::NaturalUnit)` pair (their MW fields
# are all `needs_conversion=false`, so both branches read `po.max_supply`/`max_active_power`/…
# unconverted — "All MW values are natural units" per their docstrings), but it emitted no
# plain 2-arg selector alongside them, so nothing ever calls those pairs. They join a third
# loop below rather than either existing one: `_power_units_marker` has no wire field to read
# (no `power_units` member — see `openapi_has_power_units` in generate_structs.jl), and `NU`
# rather than the second loop's `CU` names which branch actually runs, matching the
# always-natural-units contract even though the two branches are behaviorally identical.

for T in (
    :Area, :LoadZone, :TransmissionInterface, :Line, :MonitoredLine, :GenericArcImpedance,
    :DiscreteControlledACBranch, :TransformerCircuit, :EnergyReservoirStorage,
    :TwoTerminalGenericHVDCLine, :TwoTerminalLCCLine, :TwoTerminalVSCLine, :Source,
    :InterconnectingConverter, :HybridSystem, :FACTSControlDevice,
)
    @eval function from_openapi(po::PO.$T, refs::OpenAPIRefs)
        return from_openapi(
            po,
            refs,
            _power_units_marker($(string(T)), po.id, po.power_units),
        )
    end
end

for T in (
    :Arc, :TwoWindingTransformer, :ThreeWindingTransformer, :FixedAdmittance,
    :SwitchedAdmittance, :HydroReservoir, :TModelHVDCLine, :OnlineReserve, :OfflineReserve,
    :GroupReserve,
)
    @eval from_openapi(po::PO.$T, refs::OpenAPIRefs) = from_openapi(po, refs, CU)
end

# The market components' wire values are natural units ("All MW values are natural
# units" in their own docstrings), not the component base the generated selector would
# default to for a struct with no `power_units` discriminator. Their descriptor entries
# therefore set `exclude_openapi_import_selector`, which suppresses that generated
# selector so these definitions are the only ones — without it the two collide, and
# method overwriting is an error during precompilation.
for T in (:TradingHub, :VirtualParticipant, :PointToPointBid)
    @eval from_openapi(po::PO.$T, refs::OpenAPIRefs) = from_openapi(po, refs, NU)
end

"""Named tuple of `(min, max)` from a PO `MinMax`-shaped struct, or `default` (the PSY
descriptor default) when the field is absent from the wire."""
_minmax(m) = (min = Float64(m.min), max = Float64(m.max))
_minmax(::Union{Nothing, IC.Absent}, default) = default
_minmax(m, ::Any) = _minmax(m)

"""Named tuple of `(from, to)` from a PO `FromTo`-shaped struct, or `default` (the PSY
descriptor default) when the field is absent from the wire."""
_fromto(m) = (from = Float64(m.from), to = Float64(m.to))
_fromto(::Union{Nothing, IC.Absent}, default) = default
_fromto(m, ::Any) = _fromto(m)

"""A field the PSY descriptor declares required-with-a-default (e.g. `Area.load_response`,
`TransformerCircuit.α`/`regulated_bus_number`) but the wire declares optional-by-omission:
`Absent`/`nothing` falls back to that same descriptor default rather than failing to build the
component at all."""
_or_default(::Union{Nothing, IC.Absent}, default) = default
_or_default(v, ::Any) = v

"""Same as `_or_default`, for a wire enum field: unwraps `.value` when the field is present,
returns `default` (already the bare PSY-side value) when it is absent."""
_or_default_enum(::Union{Nothing, IC.Absent}, default) = default
_or_default_enum(v, default) = typeof(default)(v.value)

# Optional PO fields map nothing/Absent -> nothing (the PSY kwargs accept it), as
# `::Union{Nothing, IC.Absent}` method pairs, the same idiom cost_conversion.jl uses.

"""`(min, max)` passed through unconverted, or `nothing` when absent."""
_opt_minmax(::Union{Nothing, IC.Absent}) = nothing
_opt_minmax(m) = _minmax(m)

"""`(min, max)` divided by `base`, or `nothing` when absent."""
_minmax_cu(::Union{Nothing, IC.Absent}, base) = nothing
_minmax_cu(m, base) = (min = Float64(m.min) / base, max = Float64(m.max) / base)

"""`(min, max)` divided by `base`, or `default` (already in the target unit — zero scales to
itself, which is the only default this pairs with today) when absent."""
_minmax_cu(::Union{Nothing, IC.Absent}, default, base) = default
_minmax_cu(m, ::Any, base) = _minmax_cu(m, base)

"""`(up, down)` divided by `base`, or `nothing` when absent."""
_updown_cu(::Union{Nothing, IC.Absent}, base) = nothing
_updown_cu(m, base) = (up = Float64(m.up) / base, down = Float64(m.down) / base)

"""`(up, down)` passed through unconverted, or `nothing` when absent."""
_opt_updown(::Union{Nothing, IC.Absent}) = nothing
_opt_updown(m) = (up = Float64(m.up), down = Float64(m.down))

"""`v` divided by `base`, or `nothing` when absent."""
_scale_optional(::Union{Nothing, IC.Absent}, base) = nothing
_scale_optional(v, base) = Float64(v) / base

"""Reservoir level fields arrive absolute (per `level_data_type`'s units); PSY wants them
as a fraction of `storage_level_limits.max`. Semantic, not a unit conversion — same in
both `ComponentBaseUnit`/`NaturalUnit` methods."""
_level_fraction(::Union{Nothing, IC.Absent}, max_level, name, field) = nothing

function _level_fraction(v, max_level, name, field)
    if iszero(max_level)
        iszero(v) || error(
            "HydroReservoir $name: $field is $v but storage_level_limits.max is 0, so the " *
            "fraction PSY stores it as is undefined. A reservoir with no capacity cannot " *
            "hold a level — emit a nonzero max, or a zero $field.",
        )
        # Zero capacity and zero level: no fraction is meaningful, and 0 is the value that
        # survives the inverse (export multiplies the fraction by this same zero max).
        # Placeholder reservoirs are built this way, so this must not error.
        return 0.0
    end
    return v / max_level
end

"""`Complex(real, imag)` from a PO `ComplexNumber`-shaped struct, or `default` (the PSY
descriptor default) when the field is absent from the wire."""
_complex_number(c) = Complex(c.real, c.imag)
_complex_number(::Union{Nothing, IC.Absent}, default) = default
_complex_number(c, ::Any) = _complex_number(c)

"""`(in, out)` from a PO `InOut`-shaped struct, or `default` (the PSY descriptor default)
when the field is absent from the wire. Inverse of export's `_inout_po`."""
_inout(m) = (in = m.in, out = m.out)
_inout(::Union{Nothing, IC.Absent}, default) = default
_inout(m, ::Any) = _inout(m)

"""Resolve upstream/downstream `HydroUnit` ids to components; `nothing` means no
association (a reservoir can legitimately have zero upstream/downstream turbines) and
maps to an empty vector, matching `HydroReservoir`'s own `upstream_turbines`/
`downstream_turbines` default — not an error to guard against.

Called from the `defer_ref!` closure `from_openapi(::PO.HydroReservoir, ...)` queues, not
from that function directly — see it for why."""
_hydro_units(::OpenAPIRefs, ::Union{Nothing, IC.Absent}) = HydroUnit[]
_hydro_units(refs::OpenAPIRefs, ids) = HydroUnit[refs[id] for id in ids]

"""Resolve upstream reservoir ids to components; `nothing` means no association and maps
to an empty vector, matching `HydroReservoir.upstream_reservoirs`'s own default. Same
deferred caller as [`_hydro_units`](@ref)."""
_reservoir_devices(::OpenAPIRefs, ::Union{Nothing, IC.Absent}) = Device[]
_reservoir_devices(refs::OpenAPIRefs, ids) = Device[refs[id] for id in ids]

"""`ReserveDirection` is a type parameter, not an enum instance, so this is a literal table
(mirrors the reference) rather than an `instances(...)`-derived one."""
const RESERVE_DIRECTION = Dict(
    "UP" => ReserveUp,
    "DOWN" => ReserveDown,
    "SYMMETRIC" => ReserveSymmetric,
)

function _resolve_reserve_direction(reserve_direction, name)
    direction = get(RESERVE_DIRECTION, reserve_direction, nothing)
    if isnothing(direction)
        error("unmapped reserve_direction=$reserve_direction on reserve $name")
    end
    return direction
end

# ── Arc ─────────────────────────────────────────────────────────────────────────
# PO field names (`from_id`/`to_id`) differ from PSY's (`from`/`to`); no unit-converted
# fields, so both unit-system methods are identical.

function from_openapi(po::PO.Arc, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return Arc(; from = refs[po.from_id], to = refs[po.to_id])
end

function from_openapi(po::PO.Arc, refs::OpenAPIRefs, ::NaturalUnit)
    return from_openapi(po, refs, CU)
end

# ── Area / LoadZone ─────────────────────────────────────────────────────────────
# `peak_active_power`/`peak_reactive_power` are discriminated by the blob's own `power_units`,
# like every other power-family field: COMPONENT_BASE passes through pu, NATURAL_UNITS divides
# by the blob's own (required) `base_power` — `_require_base_power` errors naming the type/id
# when a blob omits it. `Area.load_response` (x-unit MW/Hz) has no `conversion_unit` in the PSY
# descriptor and passes through unconverted in both methods. `direction_mapping::Dict{String,
# Int}` (TransmissionInterface, below) is unclassifiable to the generator, which is what keeps
# these hand-written rather than generated.

"""`load_response`'s own PSY descriptor default is `0.0`; a document that omits it (optional-
by-omission, not nullable) gets that default rather than failing to build `Area` at all."""
_load_response(::Union{Nothing, IC.Absent}) = 0.0
_load_response(v::Real) = Float64(v)

function from_openapi(po::PO.Area, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return Area(;
        name = po.name,
        peak_active_power = _or_default(po.peak_active_power, 0.0),
        peak_reactive_power = _or_default(po.peak_reactive_power, 0.0),
        load_response = _load_response(po.load_response),
        base_power = _require_base_power("Area", po.id, po.base_power),
    )
end

function from_openapi(po::PO.Area, refs::OpenAPIRefs, ::NaturalUnit)
    bp = _require_base_power("Area", po.id, po.base_power)
    return Area(;
        name = po.name,
        peak_active_power = _or_default(po.peak_active_power, 0.0) / bp,
        peak_reactive_power = _or_default(po.peak_reactive_power, 0.0) / bp,
        load_response = _load_response(po.load_response),
        base_power = bp,
    )
end

function from_openapi(po::PO.LoadZone, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return LoadZone(;
        name = po.name,
        peak_active_power = po.peak_active_power,
        peak_reactive_power = po.peak_reactive_power,
        base_power = _require_base_power("LoadZone", po.id, po.base_power),
    )
end

function from_openapi(po::PO.LoadZone, refs::OpenAPIRefs, ::NaturalUnit)
    bp = _require_base_power("LoadZone", po.id, po.base_power)
    return LoadZone(;
        name = po.name,
        peak_active_power = po.peak_active_power / bp,
        peak_reactive_power = po.peak_reactive_power / bp,
        base_power = bp,
    )
end

# ── TransmissionInterface ───────────────────────────────────────────────────────
# `active_power_flow_limits` (x-unit MW) is discriminated by `power_units` like every other
# power-family field, mirroring Area/LoadZone's peak fields above. `direction_mapping::
# Dict{String, Int}` is unclassifiable to the generator (not scalar/compound/reference/enum),
# which is what keeps this hand-written. `violation_penalty` has no `conversion_unit` and
# passes through unconverted in both methods.

function from_openapi(
    po::PO.TransmissionInterface,
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
)
    return TransmissionInterface(;
        name = po.name,
        available = po.available,
        active_power_flow_limits = _minmax(po.active_power_flow_limits),
        violation_penalty = _or_default(po.violation_penalty, INFINITE_COST),
        direction_mapping = po.direction_mapping.additional_properties,
        base_power = _require_base_power("TransmissionInterface", po.id, po.base_power),
    )
end

function from_openapi(
    po::PO.TransmissionInterface,
    refs::OpenAPIRefs,
    ::NaturalUnit,
)
    bp = _require_base_power("TransmissionInterface", po.id, po.base_power)
    return TransmissionInterface(;
        name = po.name,
        available = po.available,
        active_power_flow_limits = _minmax_cu(po.active_power_flow_limits, bp),
        violation_penalty = _or_default(po.violation_penalty, INFINITE_COST),
        direction_mapping = po.direction_mapping.additional_properties,
        base_power = bp,
    )
end

# ── Line ────────────────────────────────────────────────────────────────────────
# `r`/`x`/`b`/`g` are pu on system base in the document already (identity in both methods,
# matching every other schema-declared-pu field) — they need `base_voltage` for an
# impedance/admittance conversion, which `Line` does not carry (`TransformerCircuit` is the
# pattern for a device that does), and that is what keeps this hand-written.
# `rating`/`rating_b`/`rating_c`/`active_power_flow`/`reactive_power_flow` are natural MVA/MW
# divided by the line's own (required) `base_power` only under `NaturalUnit`; `_require_base_power`
# errors, naming the type/id, when a blob omits it.

function from_openapi(po::PO.Line, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return Line(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow,
        reactive_power_flow = po.reactive_power_flow,
        arc = refs[po.arc],
        r = po.r,
        x = po.x,
        b = _fromto(po.b, (from = 0.0, to = 0.0)),
        rating = po.rating,
        angle_limits = _minmax(po.angle_limits),
        rating_b = _scale_optional(po.rating_b, 1.0),
        rating_c = _scale_optional(po.rating_c, 1.0),
        g = _fromto(po.g, (from = 0.0, to = 0.0)),
        base_power = _require_base_power("Line", po.id, po.base_power),
    )
end

function from_openapi(po::PO.Line, refs::OpenAPIRefs, ::NaturalUnit)
    sbp = _require_base_power("Line", po.id, po.base_power)
    return Line(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow / sbp,
        reactive_power_flow = po.reactive_power_flow / sbp,
        arc = refs[po.arc],
        r = po.r,
        x = po.x,
        b = _fromto(po.b, (from = 0.0, to = 0.0)),
        rating = po.rating / sbp,
        angle_limits = _minmax(po.angle_limits),
        rating_b = _scale_optional(po.rating_b, sbp),
        rating_c = _scale_optional(po.rating_c, sbp),
        g = _fromto(po.g, (from = 0.0, to = 0.0)),
        base_power = sbp,
    )
end

# ── MonitoredLine ───────────────────────────────────────────────────────────────
# Same posture as `Line` directly above, field for field, plus `flow_limits`: `r`/`x`/`b`/`g`
# are already pu on the line's base and pass through in both methods (no `base_voltage` to
# build Zbase from), the MVA/MW fields divide by `_require_base_power`'s result, and
# `angle_limits` is radians with no conversion. `flow_limits` is the one field `Line` does not
# have — a `FromTo_ToFrom` of natural MVA, so it scales with the same base as `rating`.

_fromto_toframe(m) = (from_to = Float64(m.from_to), to_from = Float64(m.to_from))
_fromto_toframe(::Union{Nothing, IC.Absent}, default) = default
_fromto_toframe(m, ::Any) = _fromto_toframe(m)
_fromto_toframe_cu(m, base) =
    (from_to = Float64(m.from_to) / base, to_from = Float64(m.to_from) / base)
_fromto_toframe_cu(::Union{Nothing, IC.Absent}, default, base) = default
_fromto_toframe_cu(m, ::Any, base) = _fromto_toframe_cu(m, base)

function from_openapi(po::PO.MonitoredLine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return MonitoredLine(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow,
        reactive_power_flow = po.reactive_power_flow,
        arc = refs[po.arc],
        r = po.r,
        x = po.x,
        b = _fromto(po.b),
        flow_limits = _fromto_toframe(po.flow_limits),
        rating = po.rating,
        angle_limits = _minmax(po.angle_limits),
        rating_b = _scale_optional(po.rating_b, 1.0),
        rating_c = _scale_optional(po.rating_c, 1.0),
        g = _fromto(po.g, (from = 0.0, to = 0.0)),
        base_power = _require_base_power("MonitoredLine", po.id, po.base_power),
    )
end

function from_openapi(po::PO.MonitoredLine, refs::OpenAPIRefs, ::NaturalUnit)
    sbp = _require_base_power("MonitoredLine", po.id, po.base_power)
    return MonitoredLine(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow / sbp,
        reactive_power_flow = po.reactive_power_flow / sbp,
        arc = refs[po.arc],
        r = po.r,
        x = po.x,
        b = _fromto(po.b),
        flow_limits = _fromto_toframe_cu(po.flow_limits, sbp),
        rating = po.rating / sbp,
        angle_limits = _minmax(po.angle_limits),
        rating_b = _scale_optional(po.rating_b, sbp),
        rating_c = _scale_optional(po.rating_c, sbp),
        g = _fromto(po.g, (from = 0.0, to = 0.0)),
        base_power = sbp,
    )
end

# ── GenericArcImpedance ─────────────────────────────────────────────────────────
# `r`/`x` pass through for the same reason as `Line`'s: the descriptor tags them `:ohm` for
# the general getter/setter machinery, but the type carries no `base_voltage` to build Zbase
# from. Unlike `Line`, this type states the basis it was written in rather than leaving it
# implicit, so the discriminator is checked instead of assumed — "COMPONENT_BASE" is the only
# basis with arithmetic here, and any other value errors rather than being silently treated
# as pu.

const GENERIC_ARC_PARAM_UNITS_IMPLEMENTED = Set(["COMPONENT_BASE"])

_check_generic_arc_param_units(po) = _check_unit_basis(
    po.parameter_units,
    GENERIC_ARC_PARAM_UNITS_IMPLEMENTED,
    "GenericArcImpedance.parameter_units",
    " for $(po.name)",
    "COMPONENT_BASE",
)

function from_openapi(po::PO.GenericArcImpedance, refs::OpenAPIRefs, ::ComponentBaseUnit)
    _check_generic_arc_param_units(po)
    return GenericArcImpedance(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow,
        reactive_power_flow = po.reactive_power_flow,
        max_flow = po.max_flow,
        arc = refs[po.arc],
        r = po.r,
        x = po.x,
        base_power = _require_base_power("GenericArcImpedance", po.id, po.base_power),
    )
end

function from_openapi(po::PO.GenericArcImpedance, refs::OpenAPIRefs, ::NaturalUnit)
    _check_generic_arc_param_units(po)
    sbp = _require_base_power("GenericArcImpedance", po.id, po.base_power)
    return GenericArcImpedance(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow / sbp,
        reactive_power_flow = po.reactive_power_flow / sbp,
        max_flow = po.max_flow / sbp,
        arc = refs[po.arc],
        r = po.r,
        x = po.x,
        base_power = sbp,
    )
end

# ── DiscreteControlledACBranch ───────────────────────────────────────────────────
# Same posture as `Line`: the PSY descriptor tags `r`/`x` `needs_conversion`/`:ohm` for the
# general SU/CU/NU getter/setter machinery, but neither the struct nor the document carries a
# companion `base_voltage` to compute Zbase from — the PO field's own docstring says `r`/`x`
# are already "per-unit on base_power" — so, like `Line`, both pass through unconverted in
# both methods. `base_power` on this type is documented as "System base power ... recorded per
# component in lieu of a system-level table" — the same schema pattern as `Line`/`Area`/
# `LoadZone`/`TwoTerminalGenericHVDCLine`, not a genuine per-device rating — so
# `active_power_flow`/`reactive_power_flow`/`rating` divide by `_require_base_power`'s result
# exactly like Line.

function from_openapi(
    po::PO.DiscreteControlledACBranch,
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
)
    return DiscreteControlledACBranch(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow,
        reactive_power_flow = po.reactive_power_flow,
        arc = refs[po.arc],
        r = po.r,
        x = po.x,
        rating = po.rating,
        discrete_branch_type = _or_default_enum(
            po.discrete_branch_type,
            DiscreteControlledBranchType.OTHER,
        ),
        branch_status = _or_default_enum(
            po.branch_status,
            DiscreteControlledBranchStatus.CLOSED,
        ),
        normal_branch_status = _or_default_enum(
            po.normal_branch_status,
            DiscreteControlledBranchStatus.CLOSED,
        ),
        base_power = _require_base_power(
            "DiscreteControlledACBranch",
            po.id,
            po.base_power,
        ),
    )
end

function from_openapi(
    po::PO.DiscreteControlledACBranch,
    refs::OpenAPIRefs,
    ::NaturalUnit,
)
    bp = _require_base_power("DiscreteControlledACBranch", po.id, po.base_power)
    return DiscreteControlledACBranch(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow / bp,
        reactive_power_flow = po.reactive_power_flow / bp,
        arc = refs[po.arc],
        r = po.r,
        x = po.x,
        rating = po.rating / bp,
        discrete_branch_type = _or_default_enum(
            po.discrete_branch_type,
            DiscreteControlledBranchType.OTHER,
        ),
        branch_status = _or_default_enum(
            po.branch_status,
            DiscreteControlledBranchStatus.CLOSED,
        ),
        normal_branch_status = _or_default_enum(
            po.normal_branch_status,
            DiscreteControlledBranchStatus.CLOSED,
        ),
        base_power = bp,
    )
end

# ── TransformerCircuit ──────────────────────────────────────────────────────────
# `r`/`x` are pu on `base_power` when `parameter_units == "COMPONENT_BASE"` — the only basis
# implemented; `NATURAL_UNITS` errors loudly rather than silently guessing at ohms-to-pu
# arithmetic. `rating`/`rating_b`/`rating_c`/`active_power_flow`/`reactive_power_flow` divide
# by the circuit's own `base_power` only under `NaturalUnit`, as for every other component-based
# type.
const CIRCUIT_PARAM_UNITS_IMPLEMENTED = Set(["COMPONENT_BASE"])

"""Each unit-basis discriminator is its own wrapper struct (`ImpedanceUnitBasis`,
`VoltageUnitBasis`, `ShuntAdmittanceUnitBasis`, `AdmittanceUnitBasis`, `EnergyUnitBasis`) —
one method per type, dispatched, rather than a bare string."""
_unit_basis_string(value::PC.ImpedanceUnitBasis) = value.value
_unit_basis_string(value::PO.VoltageUnitBasis) = value.value
_unit_basis_string(value::PC.ShuntAdmittanceUnitBasis) = value.value
_unit_basis_string(value::PC.AdmittanceUnitBasis) = value.value
_unit_basis_string(value::PC.EnergyUnitBasis) = value.value
_unit_basis_string(value) = value

"""An omitted basis selector takes `default`, the schema's declared default for that property."""
_unit_basis_string(::Union{Nothing, IC.Absent}, default::AbstractString) = default
_unit_basis_string(value, ::AbstractString) = _unit_basis_string(value)

"""One guard for every per-field unit-basis discriminator with no implemented arithmetic:
error loudly naming the field, value, and the implemented set, rather than silently guessing
(psy6 rule). `owner` is `" for <name>"` where the PO type has a name. An omitted value takes
`default` before the check, so an unimplemented default errors like an explicit one."""
function _check_unit_basis(
    value,
    implemented,
    field::AbstractString,
    owner::AbstractString,
    default::AbstractString,
)
    str = _unit_basis_string(value, default)
    if str in implemented
        return nothing
    end
    error(
        "unmapped $field=$str$owner — only " *
        "$(join(sort!(collect(implemented)), " and ")) implemented",
    )
end

_check_circuit_param_units(po) = _check_unit_basis(
    po.parameter_units,
    CIRCUIT_PARAM_UNITS_IMPLEMENTED,
    "TransformerCircuit.parameter_units",
    "",
    "COMPONENT_BASE",
)

function from_openapi(
    po::PO.TransformerCircuit,
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
)
    _check_circuit_param_units(po)
    return TransformerCircuit(;
        available = po.available,
        arc = refs[po.arc],
        tap = _or_default(po.tap, 1.0),
        α = _or_default(po.alpha, 0.0),
        r = _or_default(po.r, 0.0),
        x = _or_default(po.x, 0.0),
        control_objective = _or_default_enum(
            po.control_objective,
            TransformerControlObjective.UNDEFINED,
        ),
        regulated_bus_number = _or_default(po.regulated_bus_number, 0),
        control_limits = _minmax(po.control_limits, (min = 0.9, max = 1.1)),
        controlled_quantity_limits =
        _minmax(po.controlled_quantity_limits, (min = 0.9, max = 1.1)),
        number_of_tap_positions = _or_default(po.number_of_tap_positions, 33),
        rating = _scale_optional(po.rating, 1.0),
        rating_b = _scale_optional(po.rating_b, 1.0),
        rating_c = _scale_optional(po.rating_c, 1.0),
        active_power_flow = _or_default(po.active_power_flow, 0.0),
        reactive_power_flow = _or_default(po.reactive_power_flow, 0.0),
        base_power = po.base_power,
        base_voltage_primary = _or_default(po.base_voltage_primary, nothing),
        base_voltage_secondary = _or_default(po.base_voltage_secondary, nothing),
    )
end

function from_openapi(
    po::PO.TransformerCircuit,
    refs::OpenAPIRefs,
    ::NaturalUnit,
)
    _check_circuit_param_units(po)
    dbp = po.base_power
    return TransformerCircuit(;
        available = po.available,
        arc = refs[po.arc],
        tap = _or_default(po.tap, 1.0),
        α = _or_default(po.alpha, 0.0),
        r = _or_default(po.r, 0.0),
        x = _or_default(po.x, 0.0),
        control_objective = _or_default_enum(
            po.control_objective,
            TransformerControlObjective.UNDEFINED,
        ),
        regulated_bus_number = _or_default(po.regulated_bus_number, 0),
        control_limits = _minmax(po.control_limits, (min = 0.9, max = 1.1)),
        controlled_quantity_limits =
        _minmax(po.controlled_quantity_limits, (min = 0.9, max = 1.1)),
        number_of_tap_positions = _or_default(po.number_of_tap_positions, 33),
        rating = _scale_optional(po.rating, dbp),
        rating_b = _scale_optional(po.rating_b, dbp),
        rating_c = _scale_optional(po.rating_c, dbp),
        active_power_flow = _or_default(po.active_power_flow, 0.0) / dbp,
        reactive_power_flow = _or_default(po.reactive_power_flow, 0.0) / dbp,
        base_power = dbp,
        base_voltage_primary = _or_default(po.base_voltage_primary, nothing),
        base_voltage_secondary = _or_default(po.base_voltage_secondary, nothing),
    )
end

# ── TwoWindingTransformer ───────────────────────────────────────────────────────
# `magnetizing_shunt` is pu on the circuit's `base_power` when
# `admittance_units == "COMPONENT_BASE"` — the only basis implemented, independent of the
# document's overall unit system (mirrors the reference and `TransformerCircuit`'s
# `parameter_units` guard above).
const SHUNT_ADMITTANCE_UNITS_IMPLEMENTED = Set(["COMPONENT_BASE"])

_check_shunt_admittance_units(po) = _check_unit_basis(
    po.admittance_units,
    SHUNT_ADMITTANCE_UNITS_IMPLEMENTED,
    "TwoWindingTransformer.admittance_units",
    " for $(po.name)",
    "COMPONENT_BASE",
)

function from_openapi(
    po::PO.TwoWindingTransformer,
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
)
    _check_shunt_admittance_units(po)
    return TwoWindingTransformer(;
        name = po.name,
        circuit = refs[po.circuit],
        magnetizing_shunt = _complex_number(po.magnetizing_shunt, Complex(0.0, 0.0)),
        shunt_location = _or_default_enum(
            po.shunt_location,
            TwoWindingTransformerShuntLocation.PRIMARY,
        ),
    )
end

function from_openapi(
    po::PO.TwoWindingTransformer,
    refs::OpenAPIRefs,
    ::NaturalUnit,
)
    return from_openapi(po, refs, CU)
end

# ── ThreeWindingTransformer ──────────────────────────────────────────────────────
# `magnetizing_shunt` follows TwoWindingTransformer's pattern exactly (pu on the primary
# circuit's `base_power`, `admittance_units` discriminator restricted to "COMPONENT_BASE",
# identity in both document unit systems). The pairwise impedances r_12/x_12/r_23/x_23/
# r_31/x_31 have their own `parameter_units` discriminator (mirrors TransformerCircuit's) —
# also restricted to "COMPONENT_BASE", under which PSY stores them exactly as pu, so they pass
# through unconverted; `base_power_12`/`_23`/`_31` are base values themselves, not
# unit-converted quantities, and also pass through directly. All are nullable together
# (`check_pairwise_impedance_block`) and `Absent`-by-omission on the wire — COMPONENT_BASE
# performs no arithmetic on them, but PSY's `Union{Nothing, Float64}` default is `nothing`, not
# `Absent`, so each still goes through `_or_default(po.field, nothing)`.
# `primary_circuit`/`secondary_circuit`/`tertiary_circuit`/`star_bus`
# resolve through `refs`, matching `TwoWindingTransformer.circuit`.

const THREEWINDING_PARAM_UNITS_IMPLEMENTED = Set(["COMPONENT_BASE"])
_check_three_winding_param_units(po) = _check_unit_basis(
    po.parameter_units,
    THREEWINDING_PARAM_UNITS_IMPLEMENTED,
    "ThreeWindingTransformer.parameter_units",
    " for $(po.name)",
    "COMPONENT_BASE",
)

const THREEWINDING_SHUNT_ADMITTANCE_UNITS_IMPLEMENTED = Set(["COMPONENT_BASE"])
_check_three_winding_shunt_admittance_units(po) = _check_unit_basis(
    po.admittance_units,
    THREEWINDING_SHUNT_ADMITTANCE_UNITS_IMPLEMENTED,
    "ThreeWindingTransformer.admittance_units",
    " for $(po.name)",
    "COMPONENT_BASE",
)

function from_openapi(
    po::PO.ThreeWindingTransformer,
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
)
    _check_three_winding_param_units(po)
    _check_three_winding_shunt_admittance_units(po)
    return ThreeWindingTransformer(;
        name = po.name,
        primary_circuit = refs[po.primary_circuit],
        secondary_circuit = refs[po.secondary_circuit],
        tertiary_circuit = refs[po.tertiary_circuit],
        star_bus = refs[po.star_bus],
        r_12 = _or_default(po.r_12, nothing),
        x_12 = _or_default(po.x_12, nothing),
        r_23 = _or_default(po.r_23, nothing),
        x_23 = _or_default(po.x_23, nothing),
        r_31 = _or_default(po.r_31, nothing),
        x_31 = _or_default(po.x_31, nothing),
        base_power_12 = _or_default(po.base_power_12, nothing),
        base_power_23 = _or_default(po.base_power_23, nothing),
        base_power_31 = _or_default(po.base_power_31, nothing),
        magnetizing_shunt = _complex_number(po.magnetizing_shunt, Complex(0.0, 0.0)),
        shunt_location = _or_default_enum(
            po.shunt_location,
            ThreeWindingTransformerShuntLocation.PRIMARY,
        ),
    )
end

function from_openapi(
    po::PO.ThreeWindingTransformer,
    refs::OpenAPIRefs,
    ::NaturalUnit,
)
    return from_openapi(po, refs, CU)
end

# ── FixedAdmittance ───────────────────────────────────────────────────────────────
# `Y`'s basis is the per-field `admittance_units` discriminator — same pattern as
# TwoWindingTransformer.magnetizing_shunt above. A shunt has no device MVA rating of its own,
# so `ShuntAdmittanceUnitBasis` is `NATURAL_UNITS`/`COMPONENT_MVAR` only. `COMPONENT_MVAR` is
# MVAr at unity voltage and divides by `refs.base_power` (the System's own computational base),
# the same anchor reserve requirements use, to land on PSY's system-base pu storage.
# `NATURAL_UNITS` (physical siemens, needing the bus's own `Z_base`) is not implemented, same
# posture as
# `SHUNT_ADMITTANCE_UNITS_IMPLEMENTED` above.
const FIXED_ADMITTANCE_UNITS_IMPLEMENTED = Set(["COMPONENT_MVAR"])

_check_fixed_admittance_units(po) = _check_unit_basis(
    po.admittance_units,
    FIXED_ADMITTANCE_UNITS_IMPLEMENTED,
    "FixedAdmittance.admittance_units",
    " for $(po.name)",
    "COMPONENT_MVAR",
)

_fixed_admittance_pu(po, refs::OpenAPIRefs) =
    _complex_number(po.y) / get_base_power(refs)

function from_openapi(po::PO.FixedAdmittance, refs::OpenAPIRefs, ::ComponentBaseUnit)
    _check_fixed_admittance_units(po)
    return FixedAdmittance(;
        name = po.name,
        available = po.available,
        bus = refs[po.bus],
        Y = _fixed_admittance_pu(po, refs),
    )
end

function from_openapi(
    po::PO.FixedAdmittance,
    refs::OpenAPIRefs,
    ::NaturalUnit,
)
    return from_openapi(po, refs, CU)
end

# ── SwitchedAdmittance ────────────────────────────────────────────────────────────
# `Y_increase` is the same fixed-natural COMPONENT_MVAR-on-system-base quantity as
# `FixedAdmittance.Y` (component_base.jl's `_DEVICEBASE_INSTANCE_DISPATCHED` lists both
# `:skip`, identical treatment) — divided by `refs.base_power` in both methods, so the
# `NaturalUnit` method delegates to `ComponentBaseUnit` exactly like `FixedAdmittance`.
# `admittance_limits` is a dimensionless multiplier bound on the total admittance
# (default `(min=1, max=1)`), not a raw admittance, and `number_engaged`/`number_of_steps`
# are per-block integer counts — none of the three need a unit conversion.
# `solved_admittance` (PSS/E `BINIT`) is the solved-case susceptance in the same
# COMPONENT_MVAR-on-system-base quantity as `Y_increase`, so it takes the same
# `base_power` division; `nothing` (the field is optional in the schema) passes through
# unscaled.
const SWITCHED_ADMITTANCE_UNITS_IMPLEMENTED = Set(["COMPONENT_MVAR"])

_check_switched_admittance_units(po) = _check_unit_basis(
    po.admittance_units,
    SWITCHED_ADMITTANCE_UNITS_IMPLEMENTED,
    "SwitchedAdmittance.admittance_units",
    " for $(po.name)",
    "COMPONENT_MVAR",
)

_switched_admittance_y_increase(::Union{Nothing, IC.Absent}, base_power) =
    Complex{Float64}[]
_switched_admittance_y_increase(values, base_power) =
    [_complex_number(v) / base_power for v in values]

_switched_admittance_solved(::Union{Nothing, IC.Absent}, base_power) = nothing
_switched_admittance_solved(value, base_power) = value / base_power

function from_openapi(po::PO.SwitchedAdmittance, refs::OpenAPIRefs, ::ComponentBaseUnit)
    _check_switched_admittance_units(po)
    base_power = get_base_power(refs)
    return SwitchedAdmittance(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus),
        number_engaged = _or_default(po.number_engaged, Int[]),
        number_of_steps = _or_default(po.number_of_steps, Int[]),
        Y_increase = _switched_admittance_y_increase(po.y_increase, base_power),
        solved_admittance = _switched_admittance_solved(po.solved_admittance, base_power),
        admittance_limits = _minmax(po.admittance_limits, (min = 1.0, max = 1.0)),
        control_mode = _or_default_enum(
            po.control_mode,
            SwitchedAdmittanceControlMode.FIXED,
        ),
        regulated_bus_number = _or_default(po.regulated_bus_number, 0),
    )
end

function from_openapi(
    po::PO.SwitchedAdmittance,
    refs::OpenAPIRefs,
    ::NaturalUnit,
)
    return from_openapi(po, refs, CU)
end

# ── FACTSControlDevice ────────────────────────────────────────────────────────────
# `max_shunt_current`/`max_reactive_power` (both MVA, declared `SU` on the PSY side) are
# discriminated by `power_units` like every other power-family field: COMPONENT_BASE passes
# through pu, NATURAL_UNITS divides by the blob's own (required) `base_power`. `voltage_setpoint`
# is pu on system base per PSY's own docstring; only `voltage_setpoint_units == "COMPONENT_BASE"`
# is implemented — `NATURAL_UNITS` (kV) would need a bus base-voltage conversion no current
# producer exercises, so it errors loudly rather than guessing. `reactive_power_required` (a
# dimensionless 0-1 fraction per the PO schema) and `control_mode`/`shunt_control_type` (enums)
# pass through / map without scaling.

const FACTS_VOLTAGE_SETPOINT_UNITS_IMPLEMENTED = Set(["COMPONENT_BASE"])

_check_facts_voltage_setpoint_units(po) = _check_unit_basis(
    po.voltage_setpoint_units,
    FACTS_VOLTAGE_SETPOINT_UNITS_IMPLEMENTED,
    "FACTSControlDevice.voltage_setpoint_units",
    " for $(po.name)",
    "COMPONENT_BASE",
)

function from_openapi(po::PO.FACTSControlDevice, refs::OpenAPIRefs, ::ComponentBaseUnit)
    _check_facts_voltage_setpoint_units(po)
    return FACTSControlDevice(;
        name = po.name,
        available = po.available,
        bus = refs[po.bus],
        control_mode = if isnothing(po.control_mode)
            nothing
        else
            FACTSOperationModes(po.control_mode.value)
        end,
        voltage_setpoint = _or_default(po.voltage_setpoint, 1.0),
        max_shunt_current = _or_default(po.max_shunt_current, 9999.0),
        max_reactive_power = _or_default(po.max_reactive_power, 9999.0),
        shunt_control_type = _or_default_enum(
            po.shunt_control_type,
            FACTSShuntControlType.STATCOM,
        ),
        regulated_bus_number = _or_default(po.regulated_bus_number, 0),
        reactive_power_required = _or_default(po.reactive_power_required, 0.0),
        base_power = _require_base_power("FACTSControlDevice", po.id, po.base_power),
    )
end

function from_openapi(po::PO.FACTSControlDevice, refs::OpenAPIRefs, ::NaturalUnit)
    _check_facts_voltage_setpoint_units(po)
    bp = _require_base_power("FACTSControlDevice", po.id, po.base_power)
    return FACTSControlDevice(;
        name = po.name,
        available = po.available,
        bus = refs[po.bus],
        control_mode = if isnothing(po.control_mode)
            nothing
        else
            FACTSOperationModes(po.control_mode.value)
        end,
        voltage_setpoint = _or_default(po.voltage_setpoint, 1.0),
        max_shunt_current = _or_default(po.max_shunt_current, 9999.0) / bp,
        max_reactive_power = _or_default(po.max_reactive_power, 9999.0) / bp,
        shunt_control_type = _or_default_enum(
            po.shunt_control_type,
            FACTSShuntControlType.STATCOM,
        ),
        regulated_bus_number = _or_default(po.regulated_bus_number, 0),
        reactive_power_required = _or_default(po.reactive_power_required, 0.0),
        base_power = bp,
    )
end

# ── HydroReservoir ──────────────────────────────────────────────────────────────
# Volumetric/energy fields (`inflow`, `outflow`, `storage_level_limits`) have no
# `display_units_arg`/`get_value` machinery on the PSY side and pass through in whatever
# unit `level_data_type` declares — identical in both unit-system methods.
# `initial_level`/`level_targets` are the one real conversion: absolute on that same basis
# in the document, fraction-of-`storage_level_limits.max` in PSY — semantic, not a unit
# conversion, so also identical in both methods.
# `operation_cost` is converted via `convert_cost`, rather than fabricated as a placeholder
# when missing.
#
# `upstream_turbines`/`downstream_turbines`/`upstream_reservoirs` are NOT resolved
# eagerly. `DOCUMENT_PLAN` converts `HydroReservoir` before `HydroPumpTurbine` (a valid
# `HydroUnit`), so a reservoir's own turbine references can be forward references; and
# `upstream_reservoirs` points at other `HydroReservoir`s converted in the same document-key
# pass, so a cascading reservoir chain is a same-type reference no `DOCUMENT_PLAN` reordering
# can express. Both are constructed at their empty defaults and patched in via
# `defer_ref!` (see [`OpenAPIRefs`](@ref)), which runs once every component in the document
# has converted and registered.

function from_openapi(po::PO.HydroReservoir, refs::OpenAPIRefs, ::ComponentBaseUnit)
    max_level = po.storage_level_limits.max
    reservoir = HydroReservoir(;
        name = po.name,
        available = po.available,
        storage_level_limits = _minmax(po.storage_level_limits),
        initial_level = _level_fraction(
            po.initial_level,
            max_level,
            po.name,
            "initial_level",
        ),
        spillage_limits = _opt_minmax(po.spillage_limits),
        inflow = po.inflow,
        outflow = po.outflow,
        level_targets = _level_fraction(
            po.level_targets,
            max_level,
            po.name,
            "level_targets",
        ),
        intake_elevation = po.intake_elevation,
        head_to_volume_factor = convert_cost(po.head_to_volume_factor),
        evaporative_loss = _or_default(po.evaporative_loss, 0.0),
        upstream_turbines = HydroUnit[],
        downstream_turbines = HydroUnit[],
        upstream_reservoirs = Device[],
        operation_cost = convert_cost(po.operation_cost),
        level_data_type = ReservoirDataType(po.level_data_type.value),
    )
    defer_ref!(
        refs,
        () -> begin
            set_upstream_turbines!(reservoir, _hydro_units(refs, po.upstream_turbines))
            set_downstream_turbines!(reservoir, _hydro_units(refs, po.downstream_turbines))
            set_upstream_reservoirs!(
                reservoir, _reservoir_devices(refs, po.upstream_reservoirs),
            )
        end,
    )
    return reservoir
end

function from_openapi(po::PO.HydroReservoir, refs::OpenAPIRefs, ::NaturalUnit)
    return from_openapi(po, refs, CU)
end

# ── EnergyReservoirStorage ──────────────────────────────────────────────────────
# `storage_capacity` is energy (MWh when `energy_units == "MWH"`, the only basis
# implemented) but still divides by `base_power` under `NaturalUnit` — the
# duration-in-hours convention PSY documents for this field, same rule as every other
# `:mva`-tagged field. `storage_level_limits`, `initial_storage_capacity_level`,
# `efficiency`, `conversion_factor`, `storage_target`, `self_discharge` are dimensionless
# ratios and pass through in both methods.
const ENERGY_UNITS_IMPLEMENTED = Set(["MWH"])

_check_energy_units(po) = _check_unit_basis(
    po.energy_units,
    ENERGY_UNITS_IMPLEMENTED,
    "EnergyReservoirStorage.energy_units",
    " for $(po.name)",
    "MWH",
)

function from_openapi(
    po::PO.EnergyReservoirStorage,
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
)
    _check_energy_units(po)
    return EnergyReservoirStorage(;
        name = po.name,
        available = po.available,
        bus = refs[po.bus],
        prime_mover_type = PrimeMovers(po.prime_mover_type.value),
        storage_technology_type = StorageTech(po.storage_technology_type.value),
        storage_capacity = po.storage_capacity,
        storage_level_limits = _minmax(po.storage_level_limits),
        initial_storage_capacity_level = po.initial_storage_capacity_level,
        rating = po.rating,
        active_power = po.active_power,
        input_active_power_limits = _minmax(po.input_active_power_limits),
        output_active_power_limits = _minmax(po.output_active_power_limits),
        efficiency = _inout(po.efficiency),
        reactive_power = po.reactive_power,
        reactive_power_limits = _opt_minmax(po.reactive_power_limits),
        base_power = _require_base_power("EnergyReservoirStorage", po.id, po.base_power),
        operation_cost = convert_cost(po.operation_cost),
        conversion_factor = _or_default(po.conversion_factor, 1.0),
        storage_target = _or_default(po.storage_target, 0.0),
        cycle_limits = _or_default(po.cycle_limits, 1e4),
        ramp_limits = _opt_updown(po.ramp_limits),
        self_discharge = _or_default(po.self_discharge, 0.0),
        standing_loss = _or_default(po.standing_loss, 0.0),
    )
end

function from_openapi(
    po::PO.EnergyReservoirStorage,
    refs::OpenAPIRefs,
    ::NaturalUnit,
)
    _check_energy_units(po)
    dbp = _require_base_power("EnergyReservoirStorage", po.id, po.base_power)
    return EnergyReservoirStorage(;
        name = po.name,
        available = po.available,
        bus = refs[po.bus],
        prime_mover_type = PrimeMovers(po.prime_mover_type.value),
        storage_technology_type = StorageTech(po.storage_technology_type.value),
        storage_capacity = po.storage_capacity / dbp,
        storage_level_limits = _minmax(po.storage_level_limits),
        initial_storage_capacity_level = po.initial_storage_capacity_level,
        rating = po.rating / dbp,
        active_power = po.active_power / dbp,
        input_active_power_limits = _minmax_cu(po.input_active_power_limits, dbp),
        output_active_power_limits = _minmax_cu(po.output_active_power_limits, dbp),
        efficiency = _inout(po.efficiency),
        reactive_power = po.reactive_power / dbp,
        reactive_power_limits = _minmax_cu(po.reactive_power_limits, dbp),
        base_power = dbp,
        operation_cost = convert_cost(po.operation_cost),
        conversion_factor = _or_default(po.conversion_factor, 1.0),
        storage_target = _or_default(po.storage_target, 0.0),
        cycle_limits = _or_default(po.cycle_limits, 1e4),
        ramp_limits = _updown_cu(po.ramp_limits, dbp),
        self_discharge = _or_default(po.self_discharge, 0.0),
        standing_loss = _or_default(po.standing_loss, 0.0) / dbp,
    )
end

# ── TwoTerminalGenericHVDCLine ──────────────────────────────────────────────────
# `loss::Union{LinearCurve, PiecewiseIncrementalCurve}` is a Union of two concrete curve
# types, not the generator's `Union{Nothing, X}` nullable pattern — unclassifiable, and what
# keeps this hand-written. The struct's own `base_power` field is required — `_require_base_power`
# errors, naming the type/id, when a producer omits it, same as Area/LoadZone/
# TransmissionInterface/Line above. `loss` has no `display_units_arg`/`get_value` machinery
# on the PSY side (its docstring gives the constant term in physical MW directly) and passes
# through unconverted in both methods.

# A `oneOf` field holds its member wrapped only after deserialization; a document built in
# memory assigns the member directly. Unwrap by dispatch, the way `convert_cost` does
# (`cost_conversion.jl`), so both shapes read the same.
_unwrap_oneof(x::IC.OneOfAPIModel) = _unwrap_oneof(x.value)
_unwrap_oneof(x) = x

_linear_curve_from_function_data(fd::IC.LinearFunctionData) =
    LinearCurve(fd.proportional_term, fd.constant_term)
_linear_curve_from_function_data(fd) =
    error("unmapped LossCurve FunctionData variant: $(typeof(fd))")

_hvdc_loss_curve(c::PC.InputOutputCurve) =
    _linear_curve_from_function_data(_unwrap_oneof(c.function_data))
_hvdc_loss_curve(c) = error("unmapped LossCurve value_curve variant: $(typeof(c))")

# `LossCurve` replaced `TwoTerminalLoss` and records its own basis, so read it rather than
# assuming: a `COMPONENT_BASE` curve would otherwise be reconstructed as natural units and
# silently change meaning. Export refuses to write that basis today
# (`loss_curve_to_openapi`), so a document carrying one did not come from here.
function _hvdc_loss(l::PC.LossCurve)
    units = _power_units_marker("LossCurve", "", l.power_units.value)
    units isa NaturalUnit || error(
        "from_openapi: LossCurve power_units=\"$(l.power_units.value)\" is not supported — " *
        "only NATURAL_UNITS loss curves are converted, so a relative basis would be " *
        "reinterpreted rather than rescaled",
    )
    return loss_curve_from_openapi(_hvdc_loss_curve(_unwrap_oneof(l.value_curve)))
end

function from_openapi(
    po::PO.TwoTerminalGenericHVDCLine,
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
)
    return TwoTerminalGenericHVDCLine(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow,
        arc = refs[po.arc],
        active_power_limits_from = _minmax(po.active_power_limits_from),
        active_power_limits_to = _minmax(po.active_power_limits_to),
        reactive_power_limits_from = _minmax(po.reactive_power_limits_from),
        reactive_power_limits_to = _minmax(po.reactive_power_limits_to),
        loss = _hvdc_loss(po.loss),
        base_power = _require_base_power(
            "TwoTerminalGenericHVDCLine",
            po.id,
            po.base_power,
        ),
    )
end

function from_openapi(
    po::PO.TwoTerminalGenericHVDCLine,
    refs::OpenAPIRefs,
    ::NaturalUnit,
)
    sbp = _require_base_power("TwoTerminalGenericHVDCLine", po.id, po.base_power)
    return TwoTerminalGenericHVDCLine(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow / sbp,
        arc = refs[po.arc],
        active_power_limits_from = _minmax_cu(po.active_power_limits_from, sbp),
        active_power_limits_to = _minmax_cu(po.active_power_limits_to, sbp),
        reactive_power_limits_from = _minmax_cu(po.reactive_power_limits_from, sbp),
        reactive_power_limits_to = _minmax_cu(po.reactive_power_limits_to, sbp),
        loss = _hvdc_loss(po.loss),
        base_power = sbp,
    )
end

# ── TwoTerminalLCCLine ────────────────────────────────────────────────────────────
# `parameter_units`/`dc_voltage_units` are always "NATURAL_UNITS" for every current producer
# (fixed ohm/kV, the mirror image of TwoWindingTransformer's always-"COMPONENT_BASE" fields) —
# only
# that basis is implemented; "COMPONENT_BASE" errors loudly rather than guessing. Because that
# representation is fixed, `r`/`rectifier_rc`/`rectifier_xc`/`rectifier_capacitor_reactance`/
# `inverter_rc`/`inverter_xc`/`inverter_capacitor_reactance`/`compounding_resistance` need the
# SAME ohm-to-pu conversion in BOTH `ComponentBaseUnit`/`NaturalUnit` methods (the Area/LoadZone
# pattern above) — only the genuinely document-unit-system-governed power fields
# (`active_power_flow`, `active_power_limits_*`, `reactive_power_limits_*`, and
# `transfer_setpoint` when `power_mode` selects its `ActivePower` branch) differ between them.
#
# PROVISIONAL, per explicit direction (2026-08-10) — may need revision: `r` and
# `compounding_resistance` are DC-line quantities with no dedicated DC base voltage field to
# compute Zbase from (unlike the rectifier/inverter AC-side trios, which clearly belong to
# `rectifier_base_voltage`/`inverter_base_voltage`). The schema carries
# `scheduled_dc_voltage` (kV) and `r` (ohms) with no documented transformation between them;
# this uses `Zbase = scheduled_dc_voltage^2 / base_power` as the best available convention.
# Revisit if a canonical formula for this specific pair surfaces later.
#
# `scheduled_dc_voltage`/`switch_mode_voltage`/`min_compounding_voltage`/
# `rectifier_base_voltage`/`inverter_base_voltage` are stored as physical kV on the PSY side
# (docstrings say "in kV" directly, no pu machinery) and pass through unconverted. Angles,
# bridge counts, tap ratios/settings/limits/steps, and `power_mode` are dimensionless/radians
# and pass through in both methods. `loss` reuses `TwoTerminalGenericHVDCLine`'s helper — same
# PSY field type.

const TWO_TERMINAL_LCC_PARAMETER_UNITS_IMPLEMENTED = Set(["NATURAL_UNITS"])
const TWO_TERMINAL_LCC_DC_VOLTAGE_UNITS_IMPLEMENTED = Set(["NATURAL_UNITS"])

_check_lcc_parameter_units(po) = _check_unit_basis(
    po.parameter_units,
    TWO_TERMINAL_LCC_PARAMETER_UNITS_IMPLEMENTED,
    "TwoTerminalLCCLine.parameter_units",
    " for $(po.name)",
    "NATURAL_UNITS",
)

_check_lcc_dc_voltage_units(po) = _check_unit_basis(
    po.dc_voltage_units,
    TWO_TERMINAL_LCC_DC_VOLTAGE_UNITS_IMPLEMENTED,
    "TwoTerminalLCCLine.dc_voltage_units",
    " for $(po.name)",
    "NATURAL_UNITS",
)

"""Ohms → pu via `Zbase = base_voltage^2 / base_power` (`base_voltage` in kV, `base_power` in
MVA)."""
_lcc_ohm_to_pu(ohms, base_voltage, base_power) = ohms / (base_voltage^2 / base_power)

"""`transfer_setpoint` follows `power_mode`: MW (`ActivePower`, divides like every sibling
power field) when `true`, Amperes (`CurrentFlow`, no power-base conversion exists) when
`false`."""
_lcc_transfer_setpoint(transfer_setpoint, ::Val{true}, base_power) =
    transfer_setpoint / base_power
_lcc_transfer_setpoint(transfer_setpoint, ::Val{false}, _base_power) = transfer_setpoint

function from_openapi(po::PO.TwoTerminalLCCLine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    _check_lcc_parameter_units(po)
    _check_lcc_dc_voltage_units(po)
    base_power = _require_base_power("TwoTerminalLCCLine", po.id, po.base_power)
    return TwoTerminalLCCLine(;
        name = po.name,
        available = po.available,
        arc = refs[po.arc],
        active_power_flow = po.active_power_flow,
        r = _lcc_ohm_to_pu(po.r, po.scheduled_dc_voltage, base_power),
        transfer_setpoint = po.transfer_setpoint,
        scheduled_dc_voltage = po.scheduled_dc_voltage,
        rectifier_bridges = po.rectifier_bridges,
        rectifier_delay_angle_limits = _minmax(po.rectifier_delay_angle_limits),
        rectifier_rc = _lcc_ohm_to_pu(
            po.rectifier_rc,
            po.rectifier_base_voltage,
            base_power,
        ),
        rectifier_xc = _lcc_ohm_to_pu(
            po.rectifier_xc,
            po.rectifier_base_voltage,
            base_power,
        ),
        rectifier_base_voltage = po.rectifier_base_voltage,
        inverter_bridges = po.inverter_bridges,
        inverter_extinction_angle_limits = _minmax(po.inverter_extinction_angle_limits),
        inverter_rc = _lcc_ohm_to_pu(po.inverter_rc, po.inverter_base_voltage, base_power),
        inverter_xc = _lcc_ohm_to_pu(po.inverter_xc, po.inverter_base_voltage, base_power),
        inverter_base_voltage = po.inverter_base_voltage,
        power_mode = _or_default(po.power_mode, true),
        switch_mode_voltage = _or_default(po.switch_mode_voltage, 0.0),
        compounding_resistance = _lcc_ohm_to_pu(
            _or_default(po.compounding_resistance, 0.0), po.scheduled_dc_voltage, base_power,
        ),
        min_compounding_voltage = _or_default(po.min_compounding_voltage, 0.0),
        rectifier_transformer_ratio = _or_default(po.rectifier_transformer_ratio, 1.0),
        rectifier_tap_setting = _or_default(po.rectifier_tap_setting, 1.0),
        rectifier_tap_limits = _minmax(po.rectifier_tap_limits, (min = 0.51, max = 1.5)),
        rectifier_tap_step = _or_default(po.rectifier_tap_step, 0.00625),
        rectifier_delay_angle = _or_default(po.rectifier_delay_angle, 0.0),
        rectifier_capacitor_reactance = _lcc_ohm_to_pu(
            _or_default(po.rectifier_capacitor_reactance, 0.0),
            po.rectifier_base_voltage,
            base_power,
        ),
        inverter_transformer_ratio = _or_default(po.inverter_transformer_ratio, 1.0),
        inverter_tap_setting = _or_default(po.inverter_tap_setting, 1.0),
        inverter_tap_limits = _minmax(po.inverter_tap_limits, (min = 0.51, max = 1.5)),
        inverter_tap_step = _or_default(po.inverter_tap_step, 0.00625),
        inverter_extinction_angle = _or_default(po.inverter_extinction_angle, 0.0),
        inverter_capacitor_reactance = _lcc_ohm_to_pu(
            _or_default(po.inverter_capacitor_reactance, 0.0),
            po.inverter_base_voltage,
            base_power,
        ),
        active_power_limits_from =
        _minmax(po.active_power_limits_from, (min = 0.0, max = 0.0)),
        active_power_limits_to = _minmax(po.active_power_limits_to, (min = 0.0, max = 0.0)),
        reactive_power_limits_from =
        _minmax(po.reactive_power_limits_from, (min = 0.0, max = 0.0)),
        reactive_power_limits_to =
        _minmax(po.reactive_power_limits_to, (min = 0.0, max = 0.0)),
        loss = _hvdc_loss(po.loss),
        base_power = base_power,
    )
end

function from_openapi(po::PO.TwoTerminalLCCLine, refs::OpenAPIRefs, ::NaturalUnit)
    _check_lcc_parameter_units(po)
    _check_lcc_dc_voltage_units(po)
    base_power = _require_base_power("TwoTerminalLCCLine", po.id, po.base_power)
    return TwoTerminalLCCLine(;
        name = po.name,
        available = po.available,
        arc = refs[po.arc],
        active_power_flow = po.active_power_flow / base_power,
        r = _lcc_ohm_to_pu(po.r, po.scheduled_dc_voltage, base_power),
        transfer_setpoint = _lcc_transfer_setpoint(
            po.transfer_setpoint, Val(_or_default(po.power_mode, true)), base_power,
        ),
        scheduled_dc_voltage = po.scheduled_dc_voltage,
        rectifier_bridges = po.rectifier_bridges,
        rectifier_delay_angle_limits = _minmax(po.rectifier_delay_angle_limits),
        rectifier_rc = _lcc_ohm_to_pu(
            po.rectifier_rc,
            po.rectifier_base_voltage,
            base_power,
        ),
        rectifier_xc = _lcc_ohm_to_pu(
            po.rectifier_xc,
            po.rectifier_base_voltage,
            base_power,
        ),
        rectifier_base_voltage = po.rectifier_base_voltage,
        inverter_bridges = po.inverter_bridges,
        inverter_extinction_angle_limits = _minmax(po.inverter_extinction_angle_limits),
        inverter_rc = _lcc_ohm_to_pu(po.inverter_rc, po.inverter_base_voltage, base_power),
        inverter_xc = _lcc_ohm_to_pu(po.inverter_xc, po.inverter_base_voltage, base_power),
        inverter_base_voltage = po.inverter_base_voltage,
        power_mode = _or_default(po.power_mode, true),
        switch_mode_voltage = _or_default(po.switch_mode_voltage, 0.0),
        compounding_resistance = _lcc_ohm_to_pu(
            _or_default(po.compounding_resistance, 0.0), po.scheduled_dc_voltage, base_power,
        ),
        min_compounding_voltage = _or_default(po.min_compounding_voltage, 0.0),
        rectifier_transformer_ratio = _or_default(po.rectifier_transformer_ratio, 1.0),
        rectifier_tap_setting = _or_default(po.rectifier_tap_setting, 1.0),
        rectifier_tap_limits = _minmax(po.rectifier_tap_limits, (min = 0.51, max = 1.5)),
        rectifier_tap_step = _or_default(po.rectifier_tap_step, 0.00625),
        rectifier_delay_angle = _or_default(po.rectifier_delay_angle, 0.0),
        rectifier_capacitor_reactance = _lcc_ohm_to_pu(
            _or_default(po.rectifier_capacitor_reactance, 0.0),
            po.rectifier_base_voltage,
            base_power,
        ),
        inverter_transformer_ratio = _or_default(po.inverter_transformer_ratio, 1.0),
        inverter_tap_setting = _or_default(po.inverter_tap_setting, 1.0),
        inverter_tap_limits = _minmax(po.inverter_tap_limits, (min = 0.51, max = 1.5)),
        inverter_tap_step = _or_default(po.inverter_tap_step, 0.00625),
        inverter_extinction_angle = _or_default(po.inverter_extinction_angle, 0.0),
        inverter_capacitor_reactance = _lcc_ohm_to_pu(
            _or_default(po.inverter_capacitor_reactance, 0.0),
            po.inverter_base_voltage,
            base_power,
        ),
        active_power_limits_from = _minmax_cu(
            po.active_power_limits_from,
            (min = 0.0, max = 0.0),
            base_power,
        ),
        active_power_limits_to = _minmax_cu(
            po.active_power_limits_to,
            (min = 0.0, max = 0.0),
            base_power,
        ),
        reactive_power_limits_from = _minmax_cu(
            po.reactive_power_limits_from,
            (min = 0.0, max = 0.0),
            base_power,
        ),
        reactive_power_limits_to = _minmax_cu(
            po.reactive_power_limits_to,
            (min = 0.0, max = 0.0),
            base_power,
        ),
        loss = _hvdc_loss(po.loss),
        base_power = base_power,
    )
end

# ── TwoTerminalVSCLine ──────────────────────────────────────────────────────────
# `converter_loss_from`/`converter_loss_to::Union{LinearCurve, QuadraticCurve}` is the same
# Union-of-two-concrete-curves shape that keeps `TwoTerminalGenericHVDCLine`/`TwoTerminalLCCLine`
# hand-written, and `dc_setpoint_*`/`ac_setpoint_*` change meaning with a sibling enum field,
# which no generator rule expresses.
#
# `admittance_units`/`voltage_units` follow `TwoTerminalLCCLine`'s posture: only "NATURAL_UNITS"
# (every current producer's value, and the schema default) is implemented, and anything else
# errors rather than being guessed at. Because that basis is fixed, `g` needs the SAME siemens →
# pu conversion in BOTH methods; only the document-unit-system-governed power fields
# (`active_power_flow`, `rating`, `rating_from`/`to`, `reactive_power_from`/`to`,
# `active_power_limits_*`, `reactive_power_limits_*`, and `dc_setpoint_*` when `dc_control_*`
# selects its `DC_POWER` branch) differ between them — the `transfer_setpoint` rule LCC already
# sets for a mode-switched power field.
#
# `rated_dc_voltage` is the DC-side base its own docstring declares it to be, so it is the base
# for `g` and for the DC-voltage `dc_setpoint_*` branches. `0.0` means "unspecified", which is
# fine while nothing needs the base and unrecoverable once something does — hence
# `_vsc_dc_base_voltage`, which errors only when a non-zero value actually has to be converted
# rather than quietly producing a `0`/`Inf`.
#
# Deliberately NOT converted, each for a stated reason rather than by omission:
#   voltage_limits_*      the descriptor does not mark it convertible, the PSY `to`-side
#                         docstring states no unit at all, and its `(0.0, 999.9)` default is a
#                         no-limit sentinel that a kV → pu division would turn into noise —
#                         the `Line.r`/`DiscreteControlledACBranch.r` passthrough precedent.
#   dc_voltage_droop_*    pu on both sides.
#   dc_current,           amperes on both sides; no power base applies.
#   max_dc_current_*
#   rmpct_*,              dimensionless on both sides.
#   power_factor_weighting_fraction_*
#   rated_dc_voltage,     kV on both sides.
#   rated_ac_voltage_*
#
# `rated_ac_voltage_from`/`rated_ac_voltage_to` are the AC-side counterparts of
# `rated_dc_voltage` — real wire-row fields now (PowerFlowFileParser's `make_vscline!` writes
# each from the terminal's own RAW bus base voltage), read straight through as kV, same as
# `rated_dc_voltage`. `ac_setpoint_*`'s `AC_VOLTAGE` branch reads `setpoint_voltage_units` to
# decide whether it can convert: `COMPONENT_BASE` is already per-unit of the converter's own AC
# base voltage — PSY's own convention — so it passes through unscaled; `NATURAL_UNITS` is kV
# and converts through `rated_ac_voltage_from`/`rated_ac_voltage_to`, exactly like
# `dc_setpoint_*`'s DC-voltage branches convert through `rated_dc_voltage` — see
# `_vsc_import_ac_base_voltage`, the same `0.0`-is-unspecified guard as `_vsc_dc_base_voltage`.

const TWO_TERMINAL_VSC_ADMITTANCE_UNITS_IMPLEMENTED = Set(["NATURAL_UNITS"])
const TWO_TERMINAL_VSC_VOLTAGE_UNITS_IMPLEMENTED = Set(["NATURAL_UNITS"])

_check_vsc_admittance_units(po) = _check_unit_basis(
    po.admittance_units,
    TWO_TERMINAL_VSC_ADMITTANCE_UNITS_IMPLEMENTED,
    "TwoTerminalVSCLine.admittance_units",
    " for $(po.name)",
    "NATURAL_UNITS",
)

_check_vsc_voltage_units(po) = _check_unit_basis(
    po.voltage_units,
    TWO_TERMINAL_VSC_VOLTAGE_UNITS_IMPLEMENTED,
    "TwoTerminalVSCLine.voltage_units",
    " for $(po.name)",
    "NATURAL_UNITS",
)

# Both bases are implemented: PSY stores these setpoints per-unit, and each kV one has a base to
# divide by — `rated_dc_voltage` on the DC side, `rated_ac_voltage_from`/`rated_ac_voltage_to`
# on the AC side. Unlike `voltage_units`, which tags `voltage_limits_*` only.
const TWO_TERMINAL_VSC_SETPOINT_VOLTAGE_UNITS_IMPLEMENTED =
    Set(["NATURAL_UNITS", "COMPONENT_BASE"])

_check_vsc_setpoint_voltage_units(po) = _check_unit_basis(
    po.setpoint_voltage_units,
    TWO_TERMINAL_VSC_SETPOINT_VOLTAGE_UNITS_IMPLEMENTED,
    "TwoTerminalVSCLine.setpoint_voltage_units",
    " for $(po.name)",
    "NATURAL_UNITS",
)

"""
`rated_dc_voltage` when it can serve as a base, erroring when `value` needs a base the
document declined to give. `0.0` is the schema's "unspecified", not a usable base.
"""
function _vsc_dc_base_voltage(po, value, field::AbstractString)
    rated = po.rated_dc_voltage
    if !iszero(rated)
        return rated
    end
    if iszero(value)
        return one(rated)
    end
    return error(
        "TwoTerminalVSCLine \"$(po.name)\": $field is $value but rated_dc_voltage is 0.0, " *
        "so there is no DC voltage base to convert it against — set rated_dc_voltage",
    )
end

"""Siemens → pu via `Ybase = base_power / rated_dc_voltage^2` (kV, MVA)."""
function _vsc_siemens_to_pu(po, base_power)
    base_voltage = _vsc_dc_base_voltage(po, po.g, "g")
    return po.g * (base_voltage^2 / base_power)
end

"""
`converter_loss_*` restricted to the two curve shapes the PSY field's Union admits, so a
piecewise document curve is named here rather than surfacing as a `MethodError` from the
`TwoTerminalVSCLine` constructor.
"""
_vsc_converter_loss(curve::InputOutputCurve{LinearFunctionData}) =
    loss_curve_from_openapi(curve)
_vsc_converter_loss(curve::InputOutputCurve{QuadraticFunctionData}) =
    loss_curve_from_openapi(curve)
_vsc_converter_loss(curve) = error(
    "TwoTerminalVSCLine converter_loss must be a LINEAR or QUADRATIC InputOutputCurve, got " *
    "InputOutputCurve{$(typeof(get_function_data(curve)))}",
)

"""
Unwrap a `converter_loss_*`/`loss_function` `LossCurve` the same way `_hvdc_loss` does (only
`NATURAL_UNITS` is supported), then hand the bare curve to `_vsc_converter_loss`; absent on
the wire falls back to the shared PSY descriptor default (a zero linear loss curve).
"""
_vsc_loss(::Union{Nothing, IC.Absent}) = LossCurve(LinearCurve(0.0), NaturalUnit())
function _vsc_loss(l::PC.LossCurve)
    units = _power_units_marker("LossCurve", "", l.power_units.value)
    units isa NaturalUnit || error(
        "from_openapi: LossCurve power_units=\"$(l.power_units.value)\" is not supported — " *
        "only NATURAL_UNITS loss curves are converted, so a relative basis would be " *
        "reinterpreted rather than rescaled",
    )
    return _vsc_converter_loss(convert_cost(_unwrap_oneof(l.value_curve)))
end

"""
`dc_setpoint_*` follows `dc_control_*`: MW under `DC_POWER` (a power field, so it divides
with its siblings only under `NaturalUnit`), and per-unit under either DC-voltage-regulating
mode — `setpoint_voltage_units` is checked to be `COMPONENT_BASE`, so no base is applied.
"""
_vsc_dc_setpoint(
    po,
    setpoint,
    ::Val{VSCDCControlModes.DC_POWER},
    base_power,
    ::NaturalUnit,
) =
    setpoint / base_power
_vsc_dc_setpoint(
    _po, setpoint, ::Val{VSCDCControlModes.DC_POWER}, _base_power, ::ComponentBaseUnit,
) = setpoint
function _vsc_dc_setpoint(po, setpoint, ::Val{VSCDCControlModes.DC_VOLTAGE}, _bp, _unit)
    return _vsc_dc_voltage_setpoint(po, setpoint, _vsc_setpoint_basis(po))
end
function _vsc_dc_setpoint(
    po, setpoint, ::Val{VSCDCControlModes.DC_VOLTAGE_DROOP}, _bp, _unit,
)
    return _vsc_dc_voltage_setpoint(po, setpoint, _vsc_setpoint_basis(po))
end

"""Errors when an `ac_setpoint_*` value needs an AC voltage base under `AC_VOLTAGE`/
`NATURAL_UNITS` but the matching `rated_ac_voltage_from`/`rated_ac_voltage_to` is `0.0`
(unspecified). `0.0` is only usable while nothing actually needs the base, same posture as
`_vsc_dc_base_voltage`."""
function _vsc_import_ac_base_voltage(po, rated, value, field::AbstractString)
    if !iszero(rated)
        return rated
    end
    if iszero(value)
        return one(rated)
    end
    return error(
        "TwoTerminalVSCLine \"$(po.name)\": $field is $value but its rated AC voltage " *
        "base is 0.0, so there is no AC voltage base to convert it against — set " *
        "rated_ac_voltage_from/rated_ac_voltage_to",
    )
end

"""
The basis `setpoint_voltage_units` declares for the voltage-regulating setpoints. PSY stores
them per-unit, so `COMPONENT_BASE` passes through and only `NATURAL_UNITS` divides by a base.
"""
_vsc_setpoint_basis(po) =
    Val(Symbol(_unit_basis_string(po.setpoint_voltage_units, "NATURAL_UNITS")))

_vsc_dc_voltage_setpoint(_po, setpoint, ::Val{:COMPONENT_BASE}) = setpoint
_vsc_dc_voltage_setpoint(po, setpoint, ::Val{:NATURAL_UNITS}) =
    setpoint / _vsc_dc_base_voltage(po, setpoint, "dc_setpoint")

"""
`ac_setpoint_*` follows `ac_control_*`: a dimensionless power factor under
`AC_REACTIVE_POWER`, and an AC-side voltage under `AC_VOLTAGE`, whose basis
`setpoint_voltage_units` names. `COMPONENT_BASE` is already per-unit of the converter's own AC
base voltage — PSY's own `ac_setpoint_*` convention — so it passes through unscaled.
`NATURAL_UNITS` is kV, converted through `rated` — the caller's matching
`rated_ac_voltage_from`/`rated_ac_voltage_to` — via `_vsc_import_ac_base_voltage`.
"""
_vsc_ac_setpoint(_po, setpoint, ::Val{VSCACControlModes.AC_REACTIVE_POWER}, _rated) =
    setpoint
function _vsc_ac_setpoint(po, setpoint, ::Val{VSCACControlModes.AC_VOLTAGE}, rated)
    return _vsc_ac_voltage_setpoint(po, setpoint, rated, _vsc_setpoint_basis(po))
end

_vsc_ac_voltage_setpoint(_po, setpoint, _rated, ::Val{:COMPONENT_BASE}) = setpoint
_vsc_ac_voltage_setpoint(po, setpoint, rated, ::Val{:NATURAL_UNITS}) =
    setpoint / _vsc_import_ac_base_voltage(po, rated, setpoint, "ac_setpoint")

"""The shared body of both unit-system methods; only `unit` and `base_power` differ."""
function _two_terminal_vsc_line(po, refs::OpenAPIRefs, base_power, unit)
    _check_vsc_admittance_units(po)
    _check_vsc_voltage_units(po)
    _check_vsc_setpoint_voltage_units(po)
    dc_control_from = _or_default_enum(po.dc_control_from, VSCDCControlModes.DC_VOLTAGE)
    dc_control_to = _or_default_enum(po.dc_control_to, VSCDCControlModes.DC_VOLTAGE)
    ac_control_from = _or_default_enum(po.ac_control_from, VSCACControlModes.AC_VOLTAGE)
    ac_control_to = _or_default_enum(po.ac_control_to, VSCACControlModes.AC_VOLTAGE)
    rated_ac_voltage_from = _or_default(po.rated_ac_voltage_from, 0.0)
    rated_ac_voltage_to = _or_default(po.rated_ac_voltage_to, 0.0)
    arc = refs[po.arc]
    return TwoTerminalVSCLine(;
        name = po.name,
        available = po.available,
        arc = arc,
        active_power_flow = _vsc_power(po.active_power_flow, base_power, unit),
        rating = _vsc_power(po.rating, base_power, unit),
        active_power_limits_from = _vsc_minmax(
            po.active_power_limits_from,
            base_power,
            unit,
        ),
        active_power_limits_to = _vsc_minmax(po.active_power_limits_to, base_power, unit),
        g = _vsc_siemens_to_pu(po, base_power),
        dc_current = _or_default(po.dc_current, 0.0),
        reactive_power_from = _vsc_power(po.reactive_power_from, base_power, unit),
        dc_control_from = dc_control_from,
        ac_control_from = ac_control_from,
        dc_setpoint_from = _vsc_dc_setpoint(
            po, po.dc_setpoint_from, Val(dc_control_from), base_power, unit,
        ),
        ac_setpoint_from = _vsc_ac_setpoint(
            po, po.ac_setpoint_from, Val(ac_control_from), rated_ac_voltage_from,
        ),
        rated_ac_voltage_from = rated_ac_voltage_from,
        converter_loss_from = _vsc_loss(po.converter_loss_from),
        max_dc_current_from = _or_default(po.max_dc_current_from, 1e8),
        rating_from = _vsc_power(po.rating_from, base_power, unit),
        reactive_power_limits_from = _vsc_minmax(
            po.reactive_power_limits_from, (min = 0.0, max = 0.0), base_power, unit,
        ),
        power_factor_weighting_fraction_from = _or_default(
            po.power_factor_weighting_fraction_from,
            1.0,
        ),
        voltage_limits_from = _minmax(po.voltage_limits_from, (min = 0.0, max = 999.9)),
        dc_voltage_droop_from = _or_default(po.dc_voltage_droop_from, 0.0),
        reactive_power_to = _vsc_power(po.reactive_power_to, base_power, unit),
        dc_control_to = dc_control_to,
        ac_control_to = ac_control_to,
        dc_setpoint_to = _vsc_dc_setpoint(
            po, po.dc_setpoint_to, Val(dc_control_to), base_power, unit,
        ),
        ac_setpoint_to = _vsc_ac_setpoint(
            po, po.ac_setpoint_to, Val(ac_control_to), rated_ac_voltage_to,
        ),
        rated_ac_voltage_to = rated_ac_voltage_to,
        converter_loss_to = _vsc_loss(po.converter_loss_to),
        max_dc_current_to = _or_default(po.max_dc_current_to, 1e8),
        rating_to = _vsc_power(po.rating_to, base_power, unit),
        reactive_power_limits_to = _vsc_minmax(
            po.reactive_power_limits_to,
            (min = 0.0, max = 0.0),
            base_power,
            unit,
        ),
        power_factor_weighting_fraction_to = _or_default(
            po.power_factor_weighting_fraction_to,
            1.0,
        ),
        voltage_limits_to = _minmax(po.voltage_limits_to, (min = 0.0, max = 999.9)),
        dc_voltage_droop_to = _or_default(po.dc_voltage_droop_to, 0.0),
        rated_dc_voltage = _or_default(po.rated_dc_voltage, 0.0),
        remote_bus_control_from = po.remote_bus_control_from,
        remote_bus_control_to = po.remote_bus_control_to,
        rmpct_from = _or_default(po.rmpct_from, 100.0),
        rmpct_to = _or_default(po.rmpct_to, 100.0),
        base_power = base_power,
    )
end

"""MVA/MW/MVAr divided by the system base only when the document declares natural units."""
_vsc_power(value, base_power, ::NaturalUnit) = value / base_power
_vsc_power(value, _base_power, ::ComponentBaseUnit) = value

_vsc_minmax(m, base_power, ::NaturalUnit) = _minmax_cu(m, base_power)
_vsc_minmax(m, _base_power, ::ComponentBaseUnit) = _minmax(m)

"""Same as [`_vsc_minmax`](@ref), for a field the PSY descriptor gives a default rather
than requiring."""
_vsc_minmax(m, default, base_power, ::NaturalUnit) = _minmax_cu(m, default, base_power)
_vsc_minmax(m, default, _base_power, ::ComponentBaseUnit) = _minmax(m, default)

function from_openapi(
    po::PO.TwoTerminalVSCLine,
    refs::OpenAPIRefs,
    unit::ComponentBaseUnit,
)
    bp = _require_base_power("TwoTerminalVSCLine", po.id, po.base_power)
    return _two_terminal_vsc_line(po, refs, bp, unit)
end

function from_openapi(po::PO.TwoTerminalVSCLine, refs::OpenAPIRefs, unit::NaturalUnit)
    bp = _require_base_power("TwoTerminalVSCLine", po.id, po.base_power)
    return _two_terminal_vsc_line(po, refs, bp, unit)
end

# ── Source ──────────────────────────────────────────────────────────────────────
# A genuine component base: `base_power` is the unit's own (required) rating, not the System's
# computational base, so the MVA/MW fields divide by `_require_base_power`'s result directly.
# `R_th`/`X_th` carry no `needs_conversion` in the descriptor — they are pu on the source's
# own base already — but the document states which basis it wrote them in, so the
# discriminator is checked rather than assumed. `base_voltage` is a plain kV passthrough.

const SOURCE_PARAM_UNITS_IMPLEMENTED = Set(["COMPONENT_BASE"])

_check_source_param_units(po) = _check_unit_basis(
    po.parameter_units,
    SOURCE_PARAM_UNITS_IMPLEMENTED,
    "Source.parameter_units",
    " for $(po.name)",
    "COMPONENT_BASE",
)

function from_openapi(po::PO.Source, refs::OpenAPIRefs, ::ComponentBaseUnit)
    _check_source_param_units(po)
    return Source(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = _or_default(po.active_power, 0.0),
        reactive_power = _or_default(po.reactive_power, 0.0),
        active_power_limits = _minmax(po.active_power_limits, (min = 0.0, max = 0.0)),
        reactive_power_limits = _opt_minmax(po.reactive_power_limits),
        R_th = _or_default(po.r_th, 0.0),
        X_th = _or_default(po.x_th, 0.0),
        internal_voltage = _or_default(po.internal_voltage, 1.0),
        internal_angle = _or_default(po.internal_angle, 0.0),
        base_power = _require_base_power("Source", po.id, po.base_power),
        base_voltage = _or_default(po.base_voltage, nothing),
        operation_cost = _convert_source_operation_cost(
            po.operation_cost, get_store(refs), get_base_power(refs),
        )::OperationalCost,
    )
end

function from_openapi(po::PO.Source, refs::OpenAPIRefs, ::NaturalUnit)
    _check_source_param_units(po)
    dbp = _require_base_power("Source", po.id, po.base_power)
    return Source(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = _or_default(po.active_power, 0.0) / dbp,
        reactive_power = _or_default(po.reactive_power, 0.0) / dbp,
        active_power_limits =
        _minmax_cu(po.active_power_limits, (min = 0.0, max = 0.0), dbp),
        reactive_power_limits = _minmax_cu(po.reactive_power_limits, dbp),
        R_th = _or_default(po.r_th, 0.0),
        X_th = _or_default(po.x_th, 0.0),
        internal_voltage = _or_default(po.internal_voltage, 1.0),
        internal_angle = _or_default(po.internal_angle, 0.0),
        base_power = dbp,
        base_voltage = _or_default(po.base_voltage, nothing),
        operation_cost = _convert_source_operation_cost(
            po.operation_cost, get_store(refs), get_base_power(refs),
        )::OperationalCost,
    )
end

# ── TModelHVDCLine ──────────────────────────────────────────────────────────────
# The cable exception. This type carries no `base_power` at all — its anchor is
# `base_current` (A), which per-unitizes `l`/`c` and, under "COMPONENT_BASE", `r`. The MW
# fields have no `power_units` discriminator either (see the schema): they declare x-unit
# "MW" outright, fixed natural units, same posture as reserves' `requirement` field (see
# that header). So they always divide by `get_base_power(refs)` (the System's own
# computational base — this type has no base of its own for power fields) in both marker
# methods; both are therefore identical, hence the trivial `CU` delegate below.

const TMODEL_PARAM_UNITS_IMPLEMENTED = Set(["COMPONENT_BASE"])

_check_tmodel_param_units(po) = _check_unit_basis(
    po.parameter_units,
    TMODEL_PARAM_UNITS_IMPLEMENTED,
    "TModelHVDCLine.parameter_units",
    " for $(po.name)",
    "NATURAL_UNITS",
)

function from_openapi(po::PO.TModelHVDCLine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    _check_tmodel_param_units(po)
    sbp = get_base_power(refs)
    return TModelHVDCLine(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow / sbp,
        arc = resolve_ref(refs, po.arc, Arc),
        r = po.r,
        l = po.l,
        c = po.c,
        active_power_limits_from = _minmax_cu(po.active_power_limits_from, sbp),
        active_power_limits_to = _minmax_cu(po.active_power_limits_to, sbp),
        base_current = po.base_current,
    )
end

function from_openapi(po::PO.TModelHVDCLine, refs::OpenAPIRefs, ::NaturalUnit)
    return from_openapi(po, refs, CU)
end

# ── InterconnectingConverter ────────────────────────────────────────────────────
# Another genuine component base: every MVA/MW/A-rated field divides by the converter's own
# `base_power`, including `dc_current`/`max_dc_current`, which the descriptor tags `:mva`
# rather than a current unit. `remote_bus_control` is a bus *number*, not a component
# reference — `Union{Nothing, Int}` in PSY — so it passes through rather than resolving.
# `loss_function` reuses the `TwoTerminalVSCLine` guard: the PSY field admits only the linear
# and quadratic shapes, so a piecewise document curve is named here rather than surfacing as
# a constructor `MethodError`.

const IC_VOLTAGE_SETPOINT_UNITS_IMPLEMENTED = Set(["COMPONENT_BASE"])

_check_ic_voltage_setpoint_units(po) = _check_unit_basis(
    po.voltage_setpoint_units,
    IC_VOLTAGE_SETPOINT_UNITS_IMPLEMENTED,
    "InterconnectingConverter.voltage_setpoint_units",
    " for $(po.name)",
    "COMPONENT_BASE",
)

function from_openapi(
    po::PO.InterconnectingConverter,
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
)
    _check_ic_voltage_setpoint_units(po)
    return InterconnectingConverter(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        dc_bus = resolve_ref(refs, po.dc_bus, DCBus),
        active_power = po.active_power,
        rating = po.rating,
        active_power_limits = _minmax(po.active_power_limits),
        base_power = _require_base_power("InterconnectingConverter", po.id, po.base_power),
        reactive_power_limits = _opt_minmax(po.reactive_power_limits),
        dc_current = _or_default(po.dc_current, 0.0),
        max_dc_current = _or_default(po.max_dc_current, 1e8),
        loss_function = _vsc_loss(po.loss_function),
        dc_control = _or_default_enum(po.dc_control, VSCDCControlModes.DC_VOLTAGE),
        ac_control = _or_default_enum(po.ac_control, VSCACControlModes.AC_REACTIVE_POWER),
        dc_setpoint = _or_default(po.dc_setpoint, 0.0),
        ac_setpoint = _or_default(po.ac_setpoint, 1.0),
        dc_voltage_droop = _or_default(po.dc_voltage_droop, 0.0),
        remote_bus_control = _or_default(po.remote_bus_control, nothing),
        rmpct = _or_default(po.rmpct, 100.0),
        power_factor_weighting_fraction = _or_default(
            po.power_factor_weighting_fraction,
            1.0,
        ),
        voltage_limits = _minmax(po.voltage_limits, (min = 0.0, max = 999.9)),
    )
end

function from_openapi(po::PO.InterconnectingConverter, refs::OpenAPIRefs, ::NaturalUnit)
    _check_ic_voltage_setpoint_units(po)
    dbp = _require_base_power("InterconnectingConverter", po.id, po.base_power)
    return InterconnectingConverter(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        dc_bus = resolve_ref(refs, po.dc_bus, DCBus),
        active_power = po.active_power / dbp,
        rating = po.rating / dbp,
        active_power_limits = _minmax_cu(po.active_power_limits, dbp),
        base_power = dbp,
        reactive_power_limits = _minmax_cu(po.reactive_power_limits, dbp),
        dc_current = _or_default(po.dc_current, 0.0) / dbp,
        max_dc_current = _or_default(po.max_dc_current, 1e8) / dbp,
        loss_function = _vsc_loss(po.loss_function),
        dc_control = _or_default_enum(po.dc_control, VSCDCControlModes.DC_VOLTAGE),
        ac_control = _or_default_enum(po.ac_control, VSCACControlModes.AC_REACTIVE_POWER),
        dc_setpoint = _or_default(po.dc_setpoint, 0.0),
        ac_setpoint = _or_default(po.ac_setpoint, 1.0),
        dc_voltage_droop = _or_default(po.dc_voltage_droop, 0.0),
        remote_bus_control = _or_default(po.remote_bus_control, nothing),
        rmpct = _or_default(po.rmpct, 100.0),
        power_factor_weighting_fraction = _or_default(
            po.power_factor_weighting_fraction,
            1.0,
        ),
        voltage_limits = _minmax(po.voltage_limits, (min = 0.0, max = 999.9)),
    )
end

# ── HybridSystem ────────────────────────────────────────────────────────────────
# Four of its fields reference *abstract* PSY types — `ThermalGen`, `ElectricLoad`,
# `Storage`, `RenewableGen` — which is what keeps this hand-written: the generator's
# `:reference` kind resolves a concrete struct name, and these name a supertype whose
# concrete member is whatever the document registered under that id. `resolve_ref`'s type
# argument still applies, an abstract bound being a perfectly good assert.
#
# `base_power` is required rather than derived. The schema calls it "commonly the same as
# `interconnection_rating`", and *commonly* is not *always* — silently substituting the PCC
# rating for a missing base would rescale every other field on the device against a number
# the producer never stated. A document that omits it is malformed, and says so.
#
# `interconnection_impedance` is pu and passes through; `interconnection_efficiency` is a
# dimensionless `InOut` fraction, likewise.

function _hybrid_base_power(po)
    isnothing(po.base_power) && error(
        "HybridSystem $(po.name): base_power is required and the document omits it. It is " *
        "commonly equal to interconnection_rating but is not derived from it — every " *
        "per-unit field on this device resolves against it, so substituting the PCC rating " *
        "would rescale them against a value the producer never stated.",
    )
    return Float64(po.base_power)
end

"""`(in, out)` passed through unconverted, or `nothing` when absent."""
_opt_inout(::Union{Nothing, IC.Absent}) = nothing
_opt_inout(m) = _inout(m)

function from_openapi(po::PO.HybridSystem, refs::OpenAPIRefs, ::ComponentBaseUnit)
    _hybrid_base_power(po)
    return HybridSystem(;
        name = po.name,
        available = po.available,
        status = OperationalStates(po.status.value),
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = _or_default(po.active_power, 0.0),
        reactive_power = _or_default(po.reactive_power, 0.0),
        base_power = po.base_power,
        operation_cost = convert_cost(po.operation_cost)::MarketBidCost,
        thermal_unit = resolve_ref(refs, po.thermal_unit, ThermalGen),
        electric_load = resolve_ref(refs, po.electric_load, ElectricLoad),
        storage = resolve_ref(refs, po.storage, Storage),
        renewable_unit = resolve_ref(refs, po.renewable_unit, RenewableGen),
        interconnection_impedance =
        _complex_number(po.interconnection_impedance, Complex(0.0, 0.0)),
        interconnection_rating = po.interconnection_rating,
        input_active_power_limits = _opt_minmax(po.input_active_power_limits),
        output_active_power_limits = _opt_minmax(po.output_active_power_limits),
        reactive_power_limits = _opt_minmax(po.reactive_power_limits),
        interconnection_efficiency = _opt_inout(po.interconnection_efficiency),
    )
end

function from_openapi(po::PO.HybridSystem, refs::OpenAPIRefs, ::NaturalUnit)
    dbp = _hybrid_base_power(po)
    return HybridSystem(;
        name = po.name,
        available = po.available,
        status = OperationalStates(po.status.value),
        bus = resolve_ref(refs, po.bus, ACBus),
        active_power = _or_default(po.active_power, 0.0) / dbp,
        reactive_power = _or_default(po.reactive_power, 0.0) / dbp,
        base_power = dbp,
        operation_cost = convert_cost(po.operation_cost)::MarketBidCost,
        thermal_unit = resolve_ref(refs, po.thermal_unit, ThermalGen),
        electric_load = resolve_ref(refs, po.electric_load, ElectricLoad),
        storage = resolve_ref(refs, po.storage, Storage),
        renewable_unit = resolve_ref(refs, po.renewable_unit, RenewableGen),
        interconnection_impedance =
        _complex_number(po.interconnection_impedance, Complex(0.0, 0.0)),
        interconnection_rating = _scale_optional(po.interconnection_rating, dbp),
        input_active_power_limits = _minmax_cu(po.input_active_power_limits, dbp),
        output_active_power_limits = _minmax_cu(po.output_active_power_limits, dbp),
        reactive_power_limits = _minmax_cu(po.reactive_power_limits, dbp),
        interconnection_efficiency = _opt_inout(po.interconnection_efficiency),
    )
end

# ── Reserves: OnlineReserve, OfflineReserve, GroupReserve ───────────────────────
# The parametric case: `reserve_direction` is a document enum property while PSY encodes it
# as a type parameter, resolved through a literal table (direction is not a codegen case).
# `requirement`'s schema (`Operations/Service/{OnlineReserve,OfflineReserve,GroupReserve}.json`)
# declares x-unit "MW" outright — fixed natural units, with no `power_units` discriminator field
# on these PO structs — so it divides by `get_base_power(refs)` (the System's own computational
# base; a reserve has no base of its own) in BOTH marker methods. Both methods are therefore
# identical, so the 2-arg selector below is the trivial `CU` delegate like every other
# non-power-family type. `variable` (the Operating Reserve Demand Curve) goes through
# `convert_reserve_variable` (already handles the `nothing` → `ZERO_OFFER_CURVE` default).

function from_openapi(po::PO.OnlineReserve, refs::OpenAPIRefs, ::ComponentBaseUnit)
    direction = _resolve_reserve_direction(po.reserve_direction.value, po.name)
    return OnlineReserve{direction}(;
        name = po.name,
        available = po.available,
        time_frame = po.time_frame,
        requirement = po.requirement / get_base_power(refs),
        variable = convert_reserve_variable(po.variable),
        sustained_time = _or_default(po.sustained_time, 60.0),
        max_output_fraction = _or_default(po.max_output_fraction, 1.0),
        max_participation_factor = _or_default(po.max_participation_factor, 1.0),
        deployed_fraction = _or_default(po.deployed_fraction, 0.0),
    )
end

function from_openapi(po::PO.OnlineReserve, refs::OpenAPIRefs, ::NaturalUnit)
    return from_openapi(po, refs, CU)
end

function from_openapi(po::PO.OfflineReserve, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return OfflineReserve(;
        name = po.name,
        available = po.available,
        time_frame = po.time_frame,
        requirement = po.requirement / get_base_power(refs),
        variable = convert_reserve_variable(po.variable),
        sustained_time = _or_default(po.sustained_time, 60.0),
        max_output_fraction = _or_default(po.max_output_fraction, 1.0),
        max_participation_factor = _or_default(po.max_participation_factor, 1.0),
        deployed_fraction = _or_default(po.deployed_fraction, 0.0),
    )
end

function from_openapi(po::PO.OfflineReserve, refs::OpenAPIRefs, ::NaturalUnit)
    return from_openapi(po, refs, CU)
end

function from_openapi(po::PO.GroupReserve, refs::OpenAPIRefs, ::ComponentBaseUnit)
    direction = _resolve_reserve_direction(po.reserve_direction.value, po.name)
    return GroupReserve{direction}(;
        name = po.name,
        available = po.available,
        requirement = po.requirement / get_base_power(refs),
    )
end

function from_openapi(po::PO.GroupReserve, refs::OpenAPIRefs, ::NaturalUnit)
    return from_openapi(po, refs, CU)
end
