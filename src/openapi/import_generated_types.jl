# Typed extraction at the PO boundary, shared by the generated and hand-written
# `from_openapi` methods.
#
# `PowerOperationsOpenAPIModels`' generated structs declare every `$ref`ed field as bare
# `Any` — 7 of the 22 fields on `PO.ThermalMultiStart` — so `po.active_power_limits.min`
# is a dynamic `getproperty` chain that annotating `po` cannot recover: the type is
# genuinely absent from the struct definition, not merely unstated at the call. `_from_wire`
# restores it by dispatching on the compound struct once, at the boundary, after which
# every member access is a concrete field load.
#
# Each field read is three independent choices, one per argument of `_or_default`:
#   - decode, by the wire value's type: `_from_wire` (compound → NamedTuple/Complex; scalar
#     passes through) or, for a wire enum, the PSY enum the default's type names;
#   - absent policy: the `default` argument (`nothing` for an optional field), or
#     `_required_enum` for a discriminator with no default;
#   - rescale: the optional `op`/`base` pair, applied member-wise to a compound.
#
# `op` is passed as a function rather than baked into separate `_scaled`/`_unscaled`
# helpers so the emitted arithmetic stays exactly what it was — `/` for power and
# impedance, `*` for admittance. Rewriting `x / base` as `x * inv(base)` would change the
# last bits of every converted value.

const _WireAbsent = Union{Nothing, IC.Absent}

"""Decode a present wire value into its PSY shape. Compound members are `Float64` on the
PSY side but `Union{Nothing, Absent, Float64}` on the wire, so a member the document
omits fails here rather than reaching the component constructor."""
@inline _from_wire(x::IC.MinMax) = (min = Float64(x.min), max = Float64(x.max))
@inline _from_wire(x::IC.UpDown) = (up = Float64(x.up), down = Float64(x.down))
@inline _from_wire(x::IC.FromTo) = (from = Float64(x.from), to = Float64(x.to))
@inline _from_wire(x::IC.InOut) = (in = Float64(x.in), out = Float64(x.out))
@inline _from_wire(x::IC.ComplexNumber) = Complex(Float64(x.real), Float64(x.imag))
# `IC.FromToToFrom`: the schema drops the underscore PSY's `FromTo_ToFrom` alias keeps.
@inline _from_wire(x::IC.FromToToFrom) =
    (from_to = Float64(x.from_to), to_from = Float64(x.to_from))
@inline _from_wire(x::PC.OperationalFlowLimit) = (
    from_to = (min = Float64(x.from_to_min), max = Float64(x.from_to_max)),
    to_from = (min = Float64(x.to_from_min), max = Float64(x.to_from_max)),
)
@inline _from_wire(x::PC.StartUpShutDown) =
    (startup = Float64(x.startup), shutdown = Float64(x.shutdown))
@inline _from_wire(x::PC.TurbinePump) =
    (turbine = Float64(x.turbine), pump = Float64(x.pump))
@inline _from_wire(x::PC.StartUpStages) =
    (hot = Float64(x.hot), warm = Float64(x.warm), cold = Float64(x.cold))
@inline _from_wire(x) = x
# A required field reached `_from_wire` directly, with no `_or_default` to absorb absence.
_from_wire(::_WireAbsent) = throw(ArgumentError("a required field is absent from the wire"))

"""`op(member, base)` over every member of a decoded compound, or `op(x, base)` on a
scalar."""
@inline _rescale(op::F, x::NamedTuple, base) where {F} = map(m -> _rescale(op, m, base), x)
@inline _rescale(op::F, x, base) where {F} = op(x, base)

"""The decoded wire value, or `default` when the field is absent from the wire. `default`
is the PSY descriptor default for a field the descriptor declares required-with-a-default
but the wire declares optional-by-omission (e.g. `Area.load_response`), and `nothing` for a
field that is optional on both sides. Absent is a distinct sentinel from `nothing`, and
dispatch covers both without a type check at the call site."""
@inline _or_default(::_WireAbsent, default) = default
@inline _or_default(v, ::Any) = _from_wire(v)

"""A wire enum is its own wrapper struct around a `String`; the PSY `@scoped_enum` it
decodes to is the type of the default, and constructs straight from that string."""
@inline _or_default(v::IC.EnumAPIModel, default::Enum) = typeof(default)(v.value)

"""Same as `_or_default` for a field the natural-units method rescales: `op` runs only on
a value that is present, so an absent field takes `default` unscaled and the arithmetic
never touches the sentinel."""
@inline _or_default(::_WireAbsent, default, ::Any, ::Any) = default
@inline _or_default(v, ::Any, op::F, base) where {F} = _rescale(op, _from_wire(v), base)

"""A wire enum with no default: absent is an error naming the row, since no control mode
can be assumed for an in-service converter."""
_required_enum(
    ::_WireAbsent, ::Type{T}, owner::AbstractString, field::AbstractString,
) where {T} = error("$owner: $field is required and has no default")
_required_enum(
    v::IC.EnumAPIModel,
    ::Type{T},
    ::AbstractString,
    ::AbstractString,
) where {T} =
    T(v.value)
