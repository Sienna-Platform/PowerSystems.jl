@inline function _get_system_base_power(c::Component)
    base_value = IS.get_base_value(c)
    isnothing(base_value) && _not_attached_error(c)
    return base_value
end
# Out of line so the message isn't built inside every getter that reads the system base.
@noinline _not_attached_error(c) =
    error("Component $(get_name(c)) is not attached to a system.")

"""
Unitless component-base power (MVA). Fallback for components with no `base_power`
field: the component base equals the system base. This is also the path
`TModelHVDCLine` resolves through — it has no `base_power` field at all (it
per-unitizes against `base_current` instead), so its power-dimensioned fields
(`active_power_flow`, `active_power_limits_from/to`) anchor on the system base.
"""
_get_base_power(c::Component) = _get_system_base_power(c)

# Holy trait distinguishing components whose `base_power` field is a genuine,
# independently-set component base (generators, loads, storage, ...) from the
# arc/area-ish types below whose `base_power` field only exists because the
# schema records the system base per-component "in lieu of a system-level table"
# (see SiennaSchemas). `add_component!` uses this trait to check that field against
# the system's base power; it must never be set independently.
abstract type BasePowerKind end
struct ComponentBasePower <: BasePowerKind end
struct SystemBasePower <: BasePowerKind end

# Default `ComponentBasePower()` also covers types with no `base_power` field at
# all (e.g. `TModelHVDCLine`, whose anchor is `base_current`): `_sync_base_power!`
# is a no-op for `ComponentBasePower`, so `add_component!` never touches a
# nonexistent field.
base_power_kind(::Component) = ComponentBasePower()
base_power_kind(::Area) = SystemBasePower()
base_power_kind(::AreaInterchange) = SystemBasePower()
base_power_kind(::DiscreteControlledACBranch) = SystemBasePower()
base_power_kind(::FixedAdmittance) = SystemBasePower()
base_power_kind(::GenericArcImpedance) = SystemBasePower()
base_power_kind(::Line) = SystemBasePower()
base_power_kind(::LoadZone) = SystemBasePower()
base_power_kind(::MonitoredLine) = SystemBasePower()
base_power_kind(::TransmissionInterface) = SystemBasePower()
base_power_kind(::TwoTerminalGenericHVDCLine) = SystemBasePower()
base_power_kind(::TwoTerminalLCCLine) = SystemBasePower()
base_power_kind(::TwoTerminalVSCLine) = SystemBasePower()

"""
Called from `add_component!`: a `SystemBasePower` component's stored per-unit values are
relative to its own `base_power`, so it must match the system's.
"""
_sync_base_power!(::ComponentBasePower, component, system_base_power) = nothing
function _sync_base_power!(::SystemBasePower, component, system_base_power)
    base_power = component.base_power
    isapprox(base_power, system_base_power) || throw(
        ArgumentError(
            "$(summary(component)) has base_power = $base_power MVA, but the system " *
            "base is $system_base_power MVA and its per-unit values are relative to " *
            "that. Construct it with `base_power = $system_base_power`.",
        ),
    )
    component.base_power = system_base_power
    return
end

# `_get_base_power` is the single read path for a component's base power, and it reads
# straight from the field for both kinds. A detached component keeps whatever base its
# producer stated, which is real data and must not be discarded; no guard belongs here,
# because the units engine already errors on SU/NU for an unattached component.

# Conversion-engine component interface (see src/units/conversions.jl): the
# engine resolves bases through these three functions, so every getter and
# setter shares one base-power/base-voltage choice per component type.
_get_component_base_power(c::Component) = _get_base_power(c)

# TransformerCircuit is a self-contained explicit-units base provider (defined
# in models/transformer_circuits.jl, included earlier): it carries its own
# base_power/base_voltage_primary/base_value and does not need a component to
# delegate to (Base.summary(w) is defined alongside the struct).
_get_component_base_power(w::TransformerCircuit) = w.base_power
function _get_system_base_power(w::TransformerCircuit)
    base_value = IS.get_base_value(w)
    isnothing(base_value) && error(
        "TransformerCircuit is not attached to a System; cannot convert to/from system base",
    )
    return base_value
end

# The circuit's impedance is per-unit referenced to its primary base voltage, so
# the conversion engine's generic base-voltage resolver reads
# base_voltage_primary.
get_base_voltage(w::TransformerCircuit) = get_base_voltage_primary(w)

const UnitsBearer = Union{Component, TransformerCircuit}

get_base_voltage(c::Branch) = get_base_voltage(get_arc(c).from)

# TwoWindingTransformer has no `arc` field of its own (the arc lives on its
# TransformerCircuit); delegate the generic Branch interface (get_arc, set_arc!)
# to the circuit so that check_component_addition/check_attached_buses/
# _handle_branch_addition_common! and get_from_bus/get_to_bus (all defined
# generically over `Branch` in terms of get_arc) work unmodified.
get_arc(c::TwoWindingTransformer) = get_arc(get_circuit(c))
set_arc!(c::TwoWindingTransformer, arc::Arc) = set_arc!(get_circuit(c), arc)

# 2W: component base voltage is the primary (circuit) side
get_base_voltage(c::TwoWindingTransformer) = get_base_voltage(get_circuit(c))
get_base_voltage(c::ThreeWindingTransformer) = error(
    "Three-winding transformers have per-circuit base voltages; use " *
    "get_base_voltage(get_primary_circuit(t))/get_base_voltage(get_secondary_circuit(t))/" *
    "get_base_voltage(get_tertiary_circuit(t)).",
)

# `base_power` is always stored and reported in natural units (MVA). It is the
# anchor that every other field's per-unitization is defined against, so
# expressing it in a per-unit base (`SU`/`CU`) is circular. Unlike every other
# field accessor, `get_base_power`/`set_base_power!` therefore need *no* units
# argument; an explicit one is accepted only when it denotes natural units —
# `u"NU"`, or a power-dimensioned `Unitful` unit such as `u"MW"`/`u"MVA"`.

"""
Get a component's `base_power` as a bare `Float64` in natural units (MVA).

`get_base_power(c)` returns the stored MVA value. An optional units argument is
accepted but must denote natural units: `u"NU"`, or a power-dimensioned `Unitful`
unit (e.g. `u"MW"`, `u"MVA"`). Per-unit bases (`u"SU"`, `u"CU"`) and non-power units error —
`base_power` is only meaningful in absolute power. See
[`get_base_power_unitful`](@ref) for the unit-bearing value.
"""
get_base_power(c::Component) = _get_base_power(c)
get_base_power(c::Component, u) = IS._strip_units(get_base_power_unitful(c, u))

"""
`base_power` as a unit-bearing quantity (MVA). See [`get_base_power`](@ref).
"""
get_base_power_unitful(c::Component) = _get_base_power(c) * MVA
get_base_power_unitful(c::Component, u::Unitful.Units) =
    _base_power_in(_get_base_power(c), u)

# A base power in natural units `u` (`u"NU"` is MVA). `uconvert` throws a
# `Unitful.DimensionError` for non-power units; per-unit ones are rejected by name.
function _base_power_in(mva::Float64, u::Unitful.Units)
    basis, t = _conversion_plan(APPARENT_POWER, u)
    _require_natural(basis, u)
    return Unitful.uconvert(t, mva * MVA)
end

"""
Set a component's `base_power` (stored as a bare MVA `Float64`).

Accepts a bare `Float64` (interpreted as MVA) or a power-dimensioned
`Unitful.Quantity` (e.g. `80.0u"MW"`, `90.0u"MVA"`). Per-unit inputs (`u"SU"`, `u"CU"`)
and non-power units error: `base_power` is only meaningful in absolute power.
"""
set_base_power!(c::Component, val::Float64) = _set_base_power!(base_power_kind(c), c, val)
set_base_power!(c::Component, val::Unitful.Quantity) =
    _set_base_power!(base_power_kind(c), c, _base_power_mva(val))

# `ustrip(MVA, …)` converts power units and throws for non-power units.
function _base_power_mva(val::Unitful.Quantity)
    basis, t = _conversion_plan(APPARENT_POWER, Unitful.unit(val))
    _require_natural(basis, Unitful.unit(val))
    return Unitful.ustrip(MVA, Unitful.ustrip(val) * t)
end

_require_natural(::Val{:natural}, _) = nothing
@noinline _require_natural(::Val, u) = _base_power_units_error(u)

_set_base_power!(::ComponentBasePower, c, val::Float64) = (c.base_power = val)
function _set_base_power!(::SystemBasePower, c, ::Float64)
    error(
        "$(typeof(c)) has no independent base_power: it always equals the system's " *
        "base power. Change the system's base power instead of setting this field " *
        "directly.",
    )
end

"""
Reject any attempt to read/write `base_power` in non-natural units.
"""
function _base_power_units_error(u)
    throw(
        ArgumentError(
            "base_power is always in natural units (MVA). Pass no units, `u\"NU\"`, " *
            "or a power-dimensioned Unitful unit such as `u\"MW\"` or `u\"MVA\"`; got `$u`. " *
            "Per-unit bases (`u\"SU\"`, `u\"CU\"`) are not valid for base_power.",
        ),
    )
end

IS.display_units_arg(::typeof(get_base_power), ::Type{<:Component}) = u"NU"
IS.display_units_arg(::typeof(get_base_power_unitful), ::Type{<:Component}) = u"NU"
IS.display_units_arg(::typeof(set_base_power!), ::Type{<:Component}) = u"NU"

# IS's hook for a domain package to declare its default unit system.
IS.default_units(::Component) = SU

#######################################################
# Units-aware get_value / set_value
#
# Fields are stored internally in component base (CU); `get_value` converts from
# CU to a requested target (e.g., `u"MW"`, `SU`).
#######################################################

"""
    get_value(c::Component, field::Val, conversion_unit::Val, units) -> value

Get `c`'s field value, converting from component-base storage to `units`.
Returns a `Unitful.Quantity`, per-unit (`u"CU"`, `u"SU/minute"`) or natural (`u"MW"`).
Public getters wrap this in `_strip_units` for the bare-number form, with `_unitful`
companions returning the quantity.
"""
function get_value(c::UnitsBearer, field::Val{T}, conversion_unit, units::UnitArg) where {T}
    value = Base.getproperty(c, T)
    isnothing(value) || _check_residual(c, field, conversion_unit, units)
    return _convert_from_component_base(
        _conversion_base(c, field),
        value,
        conversion_unit,
        units,
    )
end

# Base provider for the conversion engine: which object carries the bases for a
# given field. Components (and `TransformerCircuit`, which is its own base
# provider) are their own provider. Multi-winding transformers delegate to their
# per-circuit `TransformerCircuit` objects, which are themselves `UnitsBearer`s.
_conversion_base(c::UnitsBearer, ::Any) = c

# ---- CU → requested units: one delegation to the conversion engine. The
# field's conversion-unit token picks the physical category; the engine
# resolves bases through the component interface above. ----
_convert_from_component_base(base, value::Number, cu::Val, units::UnitArg) =
    _from_stored(base, value, _unit_category(cu), units)

# ---- Nothing passthrough ----
_convert_from_component_base(base, ::Nothing, ::Val, ::Any) = nothing

# ---- Compound field types ----
_convert_from_component_base(base, v::MinMax, cu, u) = (
    min = _convert_from_component_base(base, v.min, cu, u),
    max = _convert_from_component_base(base, v.max, cu, u),
)

_convert_from_component_base(base, v::UpDown, cu, u) = (
    up = _convert_from_component_base(base, v.up, cu, u),
    down = _convert_from_component_base(base, v.down, cu, u),
)

_convert_from_component_base(base, v::FromTo_ToFrom, cu, u) = (
    from_to = _convert_from_component_base(base, v.from_to, cu, u),
    to_from = _convert_from_component_base(base, v.to_from, cu, u),
)

_convert_from_component_base(base, v::FromTo, cu, u) = (
    from = _convert_from_component_base(base, v.from, cu, u),
    to = _convert_from_component_base(base, v.to, cu, u),
)

_convert_from_component_base(base, v::StartUpShutDown, cu, u) = (
    startup = _convert_from_component_base(base, v.startup, cu, u),
    shutdown = _convert_from_component_base(base, v.shutdown, cu, u),
)

#######################################################
# set_value: accept a Unitful.Quantity; return the CU scalar
#######################################################

# Natural (`u"MW"`) or per-unit (`u"SU"`, `u"CU/hr"`); the engine resolves which.
function set_value(c::UnitsBearer, field, val::Quantity, cu::Val)
    _check_residual(c, field, cu, Unitful.unit(val))
    return _to_stored(_conversion_base(c, field), val, _unit_category(cu))
end

# A per-unit target whose residual is wrong for the field (a bare `u"CU"` on a rate). The
# engine rejects it too, but only here is the field known for the message. The plan is a
# constant, so every other target dispatches to the empty method and compiles away.
_check_residual(c, field, cu::Val, units) =
    _check_residual(first(_conversion_plan(_unit_category(cu), units)), c, field, cu, units)
_check_residual(::Val, _, _, _, _) = nothing
@noinline function _check_residual(::Val{:mismatch}, c, field, cu, units)
    cat = _unit_category(cu)
    throw(
        ArgumentError(
            "$(_field_description(c, field)) does not take `$units`: its per-unit " *
            "values are per $(_residual_name(per_unit_table(cat)[4])). " *
            "Pass $(_units_menu(cu)).",
        ),
    )
end
_residual_name(r) = unit_to_string(inv(r))

# ---- Bare numbers are rejected: callers must attach units explicitly ----
# Generated setters intercept this one level up (`_units_tag_required`) so the
# message can name the setter; this method catches the same mistake inside a
# compound field's elements, where only the field is known. `_UntaggedNumber`
# rather than `Float64` so an integer literal (or a bare complex, on the two
# `Complex` fields) gets the message instead of a `MethodError`.
set_value(c::UnitsBearer, field, ::_UntaggedNumber, cu::Val) = throw(
    ArgumentError(
        "Setting $(_field_description(c, field)) requires a units-tagged value: " *
        "$(_tag_menu(cu)).",
    ),
)

# ---- Compound field types for setters ----
# The field is threaded through so a bare element reports which field it belongs to.
_to_component_base(c::UnitsBearer, field, val, cu) = set_value(c, field, val, cu)

set_value(c::UnitsBearer, field, val::NamedTuple{(:min, :max)}, cu::Val) = (
    min = _to_component_base(c, field, val.min, cu),
    max = _to_component_base(c, field, val.max, cu),
)

set_value(c::UnitsBearer, field, val::NamedTuple{(:up, :down)}, cu::Val) = (
    up = _to_component_base(c, field, val.up, cu),
    down = _to_component_base(c, field, val.down, cu),
)

set_value(c::UnitsBearer, field, val::NamedTuple{(:from_to, :to_from)}, cu::Val) = (
    from_to = _to_component_base(c, field, val.from_to, cu),
    to_from = _to_component_base(c, field, val.to_from, cu),
)

set_value(c::UnitsBearer, field, val::NamedTuple{(:from, :to)}, cu::Val) = (
    from = _to_component_base(c, field, val.from, cu),
    to = _to_component_base(c, field, val.to, cu),
)

set_value(c::UnitsBearer, field, val::NamedTuple{(:startup, :shutdown)}, cu::Val) = (
    startup = _to_component_base(c, field, val.startup, cu),
    shutdown = _to_component_base(c, field, val.shutdown, cu),
)

# ---- Nothing passthrough ----
set_value(::UnitsBearer, _, ::Nothing, ::Val) = nothing

# `input_basis` kwarg constructors build the struct with placeholders in the convertible
# fields, then call each setter: the half-built component supplies its own bases.
_placeholder(::Number) = NaN
_placeholder(v::NamedTuple) = map(_placeholder, v)
_placeholder(::Nothing) = nothing

# A bare number takes `input_basis`, plus the field's residual (a ramp's per minute); a
# tagged value keeps its own units.
_tag(v::_UntaggedNumber, basis, cu::Val) = v * _basis_unit(basis, _unit_category(cu))
_tag(v, basis, cu::Val) = v
_tag(v::NamedTuple, basis, cu::Val) = map(x -> _tag(x, basis, cu), v)

_basis_unit(basis::Unitful.Units, cat::UnitCategory) =
    _checked_input_basis(basis) * per_unit_table(cat)[4]

# SU is rejected: a component under construction has no system base yet.
_checked_input_basis(basis::typeof(u"CU")) = basis
_checked_input_basis(basis::typeof(u"NU")) = basis
@noinline _checked_input_basis(basis) =
    throw(ArgumentError("input_basis must be u\"CU\" or u\"NU\"; got $basis"))

# Generated `true` for types whose kwarg constructor requires `input_basis`.
_takes_input_basis(::Type) = false

######################################
########### Transformer 3W ###########
######################################

# Per-winding base powers for the three-winding transformer. The generator emits
# the private `_get_base_power_XX` field accessors (`base_power_*` are
# exclude_getter fields); these plain public accessors expose them. Circuit-aware
# unit conversion is handled through the per-circuit `TransformerCircuit` objects.
get_base_power_12(t::ThreeWindingTransformer) = t.base_power_12
get_base_power_23(t::ThreeWindingTransformer) = t.base_power_23
get_base_power_31(t::ThreeWindingTransformer) = t.base_power_31
set_base_power_12!(t::ThreeWindingTransformer, v::Union{Float64, Nothing}) =
    t.base_power_12 = v
set_base_power_23!(t::ThreeWindingTransformer, v::Union{Float64, Nothing}) =
    t.base_power_23 = v
set_base_power_31!(t::ThreeWindingTransformer, v::Union{Float64, Nothing}) =
    t.base_power_31 = v

# A TwoWindingTransformer's series electrical data lives entirely on its circuit.
# Forward the base-power accessors to the circuit so the units engine's component-base
# resolution and downstream base-power reads/writes keep working. The value-typed
# setter variants mirror the generic Component ones (natural units only) so no
# ambiguity arises with `set_base_power!(::Component, ...)`.
_get_base_power(t::TwoWindingTransformer) = get_base_power(get_circuit(t))
set_base_power!(t::TwoWindingTransformer, val::Float64) =
    set_base_power!(get_circuit(t), val)
set_base_power!(t::TwoWindingTransformer, val::Unitful.Quantity) =
    set_base_power!(get_circuit(t), _base_power_mva(val))

# The series impedance r/x lives on the circuit. These forwarding accessors keep
# dispatch on the parent working (e.g. PowerNetworkMatrices reads get_r/get_x on
# the TwoWindingTransformer during Ybus assembly) by delegating to the circuit's
# explicit-units accessors. `magnetizing_shunt` is a parent field, so its
# accessors are generated directly on the transformer and need no forwarding.
get_r(t::TwoWindingTransformer, units) = get_r(get_circuit(t), units)
get_r_unitful(t::TwoWindingTransformer, units) = get_r_unitful(get_circuit(t), units)
set_r!(t::TwoWindingTransformer, val) = set_r!(get_circuit(t), val)
get_x(t::TwoWindingTransformer, units) = get_x(get_circuit(t), units)
get_x_unitful(t::TwoWindingTransformer, units) = get_x_unitful(get_circuit(t), units)
set_x!(t::TwoWindingTransformer, val) = set_x!(get_circuit(t), val)
get_r(t::TwoWindingTransformer) = get_r(get_circuit(t))
get_r_unitful(t::TwoWindingTransformer) = get_r_unitful(get_circuit(t))
get_x(t::TwoWindingTransformer) = get_x(get_circuit(t))
get_x_unitful(t::TwoWindingTransformer) = get_x_unitful(get_circuit(t))
set_r!(t::TwoWindingTransformer, val::Real) = set_r!(get_circuit(t), val)
set_x!(t::TwoWindingTransformer, val::Real) = set_x!(get_circuit(t), val)

# Physical category implied by a field's conversion unit. The three power tokens
# share a per-unit base and differ only in the natural unit they print as, so a
# field's token is chosen by what the quantity *is* (`:mw` active, `:mvar`
# reactive, `:mva` apparent), not by how it is per-unitized.
_unit_category(::Val{:mw}) = ACTIVE_POWER
_unit_category(::Val{:mvar}) = REACTIVE_POWER
_unit_category(::Val{:mva}) = APPARENT_POWER
_unit_category(::Val{:ohm}) = IMPEDANCE
_unit_category(::Val{:siemens}) = ADMITTANCE
# A rate. The schema vocabulary calls this quantity `ActivePowerChangeRate`
# (SiennaSchemas Core/units.json), default unit MW/min; the token names the time unit
# the stored per-unit value is denominated in.
_unit_category(::Val{:mw_per_minute}) = ACTIVE_POWER_CHANGE_RATE

#######################################################
# Explicit-units error messages
#
# Every convertible field's accessors are generated in pairs: the working
# `(component, units)` getter and setter, plus a fallback method that lands here
# when the units are missing. The fallbacks exist purely so the failure names the
# accessor, the field and the units that would have worked — Julia's own
# `MethodError` lists signatures but never says what a valid unit argument is.
#######################################################

# Natural unit to suggest for each conversion-unit token.
_natural_unit_example(::Val{:mw}) = "u\"MW\""
_natural_unit_example(::Val{:mvar}) = "u\"MVAr\""
_natural_unit_example(::Val{:mva}) = "u\"MVA\""
_natural_unit_example(::Val{:ohm}) = "u\"Ω\""
_natural_unit_example(::Val{:siemens}) = "u\"S\""
_natural_unit_example(::Val{:mw_per_minute}) = "u\"MW/minute\""

# Which field the message is about. `field` is a `Val` on the generated paths and
# `nothing` where a hand-written caller did not supply one.
_field_description(c, ::Val{T}) where {T} = "`$(nameof(typeof(c)))`'s `$T`"
_field_description(c, ::Any) = "this `$(nameof(typeof(c)))` field"

# The units a getter accepts; setters take the same units on the value.
_units_menu(conversion_unit::Val) =
    "`u\"CU$(_residual_example(conversion_unit))\"` (per unit on the component base), " *
    "`u\"SU$(_residual_example(conversion_unit))\"` (per unit on the system base), " *
    "`u\"NU$(_residual_example(conversion_unit))\"` or the natural unit " *
    "`$(_natural_unit_example(conversion_unit))`"

_tag_menu(conversion_unit::Val) =
    "pass `val * u\"CU$(_residual_example(conversion_unit))\"` (per unit on the component " *
    "base), `val * u\"SU$(_residual_example(conversion_unit))\"` (per unit on the system " *
    "base), or a natural unit such as `val * $(_natural_unit_example(conversion_unit))`"

# A rate's per-unit units must name a time.
_residual_example(::Val) = ""
_residual_example(::Val{:mw_per_minute}) = "/minute"

# The bare and unit-bearing getters point at each other, so the message always
# names the companion the caller did not use.
function _companion_getter_hint(getter)
    name = string(getter)
    endswith(name, "_unitful") && return "For a bare number instead of a unit-bearing " *
           "quantity, use `$(chopsuffix(name, "_unitful"))(component, units)`."
    return "For the unit-bearing value instead of a bare number, use " *
           "`$(name)_unitful(component, units)`."
end

"""
    _units_arg_required(getter, value, field, conversion_unit)

Throw the explanatory error for a unit-bearing getter called without its `units`
argument. Every convertible field's generated accessor has a one-argument method
that lands here, so `get_active_power(gen)` reports what to pass instead of
surfacing a bare `MethodError` that lists the two-argument signatures.
"""
function _units_arg_required(getter, value, field::Symbol, conversion_unit::Val)
    throw(
        ArgumentError(
            "`$getter` requires an explicit units argument: " *
            "`$getter(component, units)`. `$(nameof(typeof(value)))`'s `$field` is a " *
            "per-unit quantity with no default unit system, so the units must be " *
            "named at the call site: $(_units_menu(conversion_unit)). " *
            "$(_companion_getter_hint(getter))",
        ),
    )
end

"""
    _units_tag_required(setter, value, field, conversion_unit, val)

Throw the explanatory error for a unit-bearing setter called with an untagged
number. The getter counterpart is [`_units_arg_required`](@ref); both are reached
from generated fallback methods, here one matching an untagged number — or, on a
compound field only, a `NamedTuple` whose elements are all untagged.
"""
# The tag to show in a compound field's example; a rate's must carry a time.
_example_tag(conversion_unit::Val) = "u\"CU$(_residual_example(conversion_unit))\""

function _units_tag_required(setter, value, field::Symbol, conversion_unit::Val, val)
    compound_hint = if val isa NamedTuple
        " A compound field takes one tagged value per element, e.g. " *
        "`(" *
        join(
            (
                "$k = $(getfield(val, k)) * $(_example_tag(conversion_unit))" for
                k in keys(val)
            ),
            ", ",
        ) * ")`."
    else
        ""
    end
    throw(
        ArgumentError(
            "`$setter` requires a units-tagged value: " *
            "`$setter(component, val * units)`. `$(nameof(typeof(value)))`'s `$field` " *
            "is a per-unit quantity with no default unit system, so the units must be " *
            "named at the call site: $(_tag_menu(conversion_unit)).$compound_hint",
        ),
    )
end

# Base provider for the pairwise impedance fields of a ThreeWindingTransformer.
# Convention: Z_ij is pu on base_power_ij referenced to the first-index circuit's
# base voltage: r_12/x_12 -> primary, r_23/x_23 -> secondary,
# r_31/x_31 -> tertiary. The
# transformer-level `magnetizing_shunt` is pu on the primary circuit's own
# `base_power` referenced to the primary circuit's base voltage (it converts
# directly on the primary `TransformerCircuit`, not through a `PairBase`).
struct PairBase{T <: ThreeWindingTransformer}
    transformer::T
    base_power::Union{Nothing, Float64}
    base_voltage::Union{Nothing, Float64}
end

function _get_component_base_power(p::PairBase)
    isnothing(p.base_power) && error(
        "The pairwise impedance fields (r_12/x_12/r_23/x_23/r_31/x_31 and base_power_12/23/31) " *
        "of $(summary(p.transformer)) are not set; cannot convert pairwise values",
    )
    return p.base_power
end
_get_system_base_power(p::PairBase) = _get_system_base_power(p.transformer)
get_base_voltage(p::PairBase) = p.base_voltage
Base.summary(p::PairBase) = "PairBase($(summary(p.transformer)))"

_conversion_base(c::ThreeWindingTransformer, ::Union{Val{:r_12}, Val{:x_12}}) =
    PairBase(c, get_base_power_12(c), get_base_voltage(get_primary_circuit(c)))
_conversion_base(c::ThreeWindingTransformer, ::Union{Val{:r_23}, Val{:x_23}}) =
    PairBase(c, get_base_power_23(c), get_base_voltage(get_secondary_circuit(c)))
_conversion_base(c::ThreeWindingTransformer, ::Union{Val{:r_31}, Val{:x_31}}) =
    PairBase(c, get_base_power_31(c), get_base_voltage(get_tertiary_circuit(c)))
_conversion_base(c::ThreeWindingTransformer, ::Val{:magnetizing_shunt}) =
    get_primary_circuit(c)
