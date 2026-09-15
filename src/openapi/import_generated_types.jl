# Typed extraction at the PO boundary, for the generated `from_openapi` methods.
#
# `PowerOperationsOpenAPIModels`' generated structs declare every `$ref`ed field as bare
# `Any` — 7 of the 22 fields on `PO.ThermalMultiStart` — so `po.active_power_limits.min`
# is a dynamic `getproperty` chain that annotating `po` cannot recover: the type is
# genuinely absent from the struct definition, not merely unstated at the call. These
# helpers restore it by dispatching on the `PC` compound struct once, at the boundary,
# after which every member access is a concrete field load.
#
# One name per alias, not the four the export side needs
# (`OPENAPI_EXPORT_COMPOUND_CTORS`): the required/optional split is dispatch on
# `::Nothing`, and the natural-units split is the `op`/`base` arity. That also lets the
# generator drop the `if isnothing(po.x)` wrapper it used to emit around every nullable
# compound.
#
# `op` is passed as a function rather than baked into separate `_scaled`/`_unscaled`
# helpers so the emitted arithmetic stays exactly what it was — `/` for power and
# impedance, `*` for admittance. Rewriting `x / base` as `x * inv(base)` would change the
# last bits of every converted value.

"""Rebuild a `MinMax` from its PO struct; `nothing` in means `nothing` out."""
@inline _minmax_from_po(x::IC.MinMax) = (min = x.min, max = x.max)
@inline _minmax_from_po(::Union{Nothing, IC.Absent}) = nothing
@inline _minmax_from_po(x::IC.MinMax, op::F, base) where {F} =
    (min = op(x.min, base), max = op(x.max, base))
@inline _minmax_from_po(::Union{Nothing, IC.Absent}, ::Any, ::Any) = nothing

"""Rebuild an `UpDown` from its PO struct; `nothing` in means `nothing` out."""
@inline _updown_from_po(x::IC.UpDown) = (up = x.up, down = x.down)
@inline _updown_from_po(::Union{Nothing, IC.Absent}) = nothing
@inline _updown_from_po(x::IC.UpDown, op::F, base) where {F} =
    (up = op(x.up, base), down = op(x.down, base))
@inline _updown_from_po(::Union{Nothing, IC.Absent}, ::Any, ::Any) = nothing

"""Rebuild a `FromTo` from its PO struct; `nothing` in means `nothing` out."""
@inline _fromto_from_po(x::IC.FromTo) = (from = x.from, to = x.to)
@inline _fromto_from_po(::Union{Nothing, IC.Absent}) = nothing
@inline _fromto_from_po(x::IC.FromTo, op::F, base) where {F} =
    (from = op(x.from, base), to = op(x.to, base))
@inline _fromto_from_po(::Union{Nothing, IC.Absent}, ::Any, ::Any) = nothing

"""Rebuild an `InOut` from its PO struct; `nothing` in means `nothing` out."""
@inline _inout_from_po(x::IC.InOut) = (in = x.in, out = x.out)
@inline _inout_from_po(::Union{Nothing, IC.Absent}) = nothing
@inline _inout_from_po(x::IC.InOut, op::F, base) where {F} =
    (in = op(x.in, base), out = op(x.out, base))
@inline _inout_from_po(::Union{Nothing, IC.Absent}, ::Any, ::Any) = nothing

"""Rebuild a `FromTo_ToFrom` from its PO struct (`IC.FromToToFrom` — the schema drops the
underscore PSY's alias keeps); `nothing` in means `nothing` out."""
@inline _fromto_tofrom_from_po(x::IC.FromToToFrom) =
    (from_to = x.from_to, to_from = x.to_from)
@inline _fromto_tofrom_from_po(::Union{Nothing, IC.Absent}) = nothing
@inline _fromto_tofrom_from_po(x::IC.FromToToFrom, op::F, base) where {F} =
    (from_to = op(x.from_to, base), to_from = op(x.to_from, base))
@inline _fromto_tofrom_from_po(::Union{Nothing, IC.Absent}, ::Any, ::Any) = nothing

"""Rebuild a `StartUpShutDown` from its PO struct; `nothing` in means `nothing` out."""
@inline _startup_shutdown_from_po(x::PC.StartUpShutDown) =
    (startup = x.startup, shutdown = x.shutdown)
@inline _startup_shutdown_from_po(::Union{Nothing, IC.Absent}) = nothing
@inline _startup_shutdown_from_po(x::PC.StartUpShutDown, op::F, base) where {F} =
    (startup = op(x.startup, base), shutdown = op(x.shutdown, base))
@inline _startup_shutdown_from_po(::Union{Nothing, IC.Absent}, ::Any, ::Any) = nothing

"""Rebuild a `TurbinePump` from its PO struct; `nothing` in means `nothing` out."""
@inline _turbinepump_from_po(x::PC.TurbinePump) = (turbine = x.turbine, pump = x.pump)
@inline _turbinepump_from_po(::Union{Nothing, IC.Absent}) = nothing
@inline _turbinepump_from_po(x::PC.TurbinePump, op::F, base) where {F} =
    (turbine = op(x.turbine, base), pump = op(x.pump, base))
@inline _turbinepump_from_po(::Union{Nothing, IC.Absent}, ::Any, ::Any) = nothing

"""Rebuild a `StartUpStages` from its PO struct; `nothing` in means `nothing` out."""
@inline _startup_stages_from_po(x::PC.StartUpStages) =
    (hot = x.hot, warm = x.warm, cold = x.cold)
@inline _startup_stages_from_po(::Union{Nothing, IC.Absent}) = nothing
@inline _startup_stages_from_po(x::PC.StartUpStages, op::F, base) where {F} =
    (hot = op(x.hot, base), warm = op(x.warm, base), cold = op(x.cold, base))
@inline _startup_stages_from_po(::Union{Nothing, IC.Absent}, ::Any, ::Any) = nothing
