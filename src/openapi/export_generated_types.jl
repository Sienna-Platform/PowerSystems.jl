# Export-direction helpers shared by the generated `to_openapi` methods (emitted by
# `compute_openapi_export_converter!` in src/generate_structs.jl) and by export_handwritten.jl.

# ── Compound-field helpers (component-base pu) ──
#
# Every optional field below is schema-optional-by-omission, not nullable (a bare `$ref`/type
# with no `null` member, absent from `required`) — encoding `nothing` into one fails schema
# validation on write. The `_optional`/`_scaled_optional` helpers therefore emit `IC.ABSENT`
# for a missing PSY-side value, matching `_component_id_optional` (below) and
# `_optional_cost_curve_to_openapi` (export_cost_conversion.jl).

_minmax_po(nt) = IC.MinMax(; min = nt.min, max = nt.max)
_minmax_po_optional(::Nothing) = IC.ABSENT
_minmax_po_optional(nt) = _minmax_po(nt)
_minmax_po_scaled(nt, base) = IC.MinMax(; min = nt.min * base, max = nt.max * base)
_minmax_po_scaled_optional(::Nothing, base) = IC.ABSENT
_minmax_po_scaled_optional(nt, base) = _minmax_po_scaled(nt, base)

_updown_po_optional(::Nothing) = IC.ABSENT
_updown_po_optional(nt) = IC.UpDown(; up = nt.up, down = nt.down)
_updown_po_scaled_optional(::Nothing, base) = IC.ABSENT
_updown_po_scaled_optional(nt, base) = IC.UpDown(; up = nt.up * base, down = nt.down * base)

_startup_shutdown_po_optional(::Nothing) = IC.ABSENT
_startup_shutdown_po_optional(nt) =
    PC.StartUpShutDown(; startup = nt.startup, shutdown = nt.shutdown)
_startup_shutdown_po_scaled_optional(::Nothing, base) = IC.ABSENT
_startup_shutdown_po_scaled_optional(nt, base) =
    PC.StartUpShutDown(; startup = nt.startup * base, shutdown = nt.shutdown * base)

_startup_stages_po_optional(::Nothing) = IC.ABSENT
_startup_stages_po_optional(nt) =
    PC.StartUpStages(; hot = nt.hot, warm = nt.warm, cold = nt.cold)

_turbinepump_po(nt) = PC.TurbinePump(; turbine = nt.turbine, pump = nt.pump)

_fromto_po(nt) = IC.FromTo(; from = nt.from, to = nt.to)
_fromto_tofrom_po(nt) = IC.FromToToFrom(; from_to = nt.from_to, to_from = nt.to_from)
_fromto_tofrom_po_scaled(nt, base) =
    IC.FromToToFrom(; from_to = nt.from_to * base, to_from = nt.to_from * base)
_inout_po(nt) = IC.InOut(; in = nt.in, out = nt.out)
_inout_po_optional(::Nothing) = IC.ABSENT
_inout_po_optional(nt) = _inout_po(nt)
# Inverse of the import side's `_complex_number` (import_handwritten.jl).
_complex_number_po(c) = IC.ComplexNumber(; real = real(c), imag = imag(c))

_scale_optional_po(::Nothing, base) = IC.ABSENT
_scale_optional_po(v, base) = v * base

"""`component_id`, but tolerant of a `nothing` field (e.g. `ACBus.area`/`load_zone`, which are
`Union{Nothing, T}` on the PSY side). The schema declares these `integer`-only and not
`required` — optional means the key is omitted, not `null` — so a missing reference emits
`IC.ABSENT` rather than `nothing`, which would fail schema validation on encode."""
_component_id_optional(::OpenAPIRefs, ::Nothing) = IC.ABSENT
_component_id_optional(refs::OpenAPIRefs, component) = component_id(refs, component)

# Scoped enums convert directly (`EnumType(s)` in, `string(e)` out — see `@scoped_enum` in
# IS), so no enum tables exist anywhere in the converters. `_invert` remains for the
# genuinely non-enum string maps (`RESERVE_DIRECTION`, a string → type-parameter table),
# whose reverse direction is derived from the forward table rather than hand-written again,
# so the two cannot drift.
_invert(d) = Dict(v => k for (k, v) in d)
