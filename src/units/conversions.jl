#=
Unit conversion system for power systems components.

Core abstraction: a UnitCategory defines a physical quantity (power, impedance, etc.)
with a natural unit and a way to compute the per-unit base value for any component.

Downstream packages implement the interface functions:
  - _get_component_base_power(c) → Float64 (MVA)
  - _get_system_base_power(c) → Float64 (MVA)
  - get_base_voltage(c) → Float64 (kV)
=#

# ============================================================
# Interface functions — implemented by downstream packages
# ============================================================

"""
    _get_component_base_power(component) → Float64

Return the device's base power in MVA as a raw Float64.
"""
function _get_component_base_power end

"""
    _get_system_base_power(component) → Float64

Return the system's base power in MVA as a raw Float64.
"""
function _get_system_base_power end

"""
    get_base_voltage(component) → Float64

Return the base voltage in kV as a raw Float64.
"""
function get_base_voltage end

# ============================================================
# Unit categories
# ============================================================

"""
    UnitCategory{NU, P, V}

A physical quantity the conversion engine knows how to per-unitize, described by two
things and nothing else:

  - `NU`: the natural (physical) unit, as a `Unitful.Units` *type*. Compound units are
    ordinary Unitful units, so a rate (`u"MW"/u"minute"`) or a cost rate
    (`USD/u"hr"`) needs no special case here.
  - `P`, `V`: the exponents of the component's base power and base voltage in this
    quantity's per-unit base. Only those two bases are ever per-unitized; time,
    currency and fuel ride along inside `NU` and are untouched by a change of base.

Every base rule in this file is then one formula, `S^P * V^V`, instead of a hand-written
case per category:

| category   | `NU`  |  P |  V | `base_value` |
|:-----------|:------|---:|---:|:-------------|
| power      | `MW`  |  1 |  0 | `S`          |
| voltage    | `kV`  |  0 |  1 | `V`          |
| impedance  | `Ω`   | -1 |  2 | `V^2/S`      |
| admittance | `S`   |  1 | -2 | `S/V^2`      |
| current    | `kA`  |  1 | -1 | `S/V`        |

Both parameters are part of the type, so `natural_unit`, `base_value` and
`_cu_to_su_ratio` resolve at compile time and fold to a multiply or a divide.
"""
struct UnitCategory{NU <: Unitful.Units, P, V} end

# The three power categories share a dimension and a base and differ only in the unit
# they print as. `MVAr`/`MVA` are PSY's own `@unit` definitions, reachable as bare
# constants here but not through `u"..."` until `Unitful.register` runs in `__init__`.
const ActivePowerCategory = UnitCategory{typeof(u"MW"), 1, 0}
const ReactivePowerCategory = UnitCategory{typeof(MVAr), 1, 0}
const ApparentPowerCategory = UnitCategory{typeof(MVA), 1, 0}
const ImpedanceCategory = UnitCategory{typeof(u"Ω"), -1, 2}
const AdmittanceCategory = UnitCategory{typeof(u"S"), 1, -2}
const VoltageCategory = UnitCategory{typeof(u"kV"), 0, 1}
const CurrentCategory = UnitCategory{typeof(u"kA"), 1, -1}

# A rate per-unitizes only its power axis -- there is no time base -- so its exponents
# are the power category's and only the natural unit gains the time dimension. The
# schema vocabulary calls this quantity `ActivePowerChangeRate` (Core/units.json), with
# default unit MW/min.
const ActivePowerChangeRateCategory = UnitCategory{typeof(u"MW" / u"minute"), 1, 0}

"""
The power categories, which share one per-unit base. Formerly an abstract supertype;
now a `Union`, so `isa` checks and dispatch on it keep working.
"""
const AbstractPowerCategory =
    Union{ActivePowerCategory, ReactivePowerCategory, ApparentPowerCategory}

const ACTIVE_POWER = ActivePowerCategory()
const REACTIVE_POWER = ReactivePowerCategory()
const APPARENT_POWER = ApparentPowerCategory()
const IMPEDANCE = ImpedanceCategory()
const ADMITTANCE = AdmittanceCategory()
const VOLTAGE = VoltageCategory()
const CURRENT = CurrentCategory()
const ACTIVE_POWER_CHANGE_RATE = ActivePowerChangeRateCategory()

"""
The categories denominated per unit time. A bare relative marker is rejected for these
(it does not say per what time); they take `CU/u"minute"`, `SU/u"hr"`, or a natural
compound unit like `u"MW/hr"`. Extend this `Union` when adding a rate category.
"""
const RateCategory = Union{ActivePowerChangeRateCategory}

"""
    storage_time(category) → Unitful.Units

The time unit a rate category's stored per-unit value is denominated in: a stored
`ramp_limits` of 0.1 means 0.1 pu **per minute**.

Declared per rate category rather than recovered from `natural_unit`, which would mean
picking the time factor out of a compound `FreeUnits`' internals.
"""
storage_time(::ActivePowerChangeRateCategory) = u"minute"

# Categories compose, so a derived quantity's base and natural unit follow from its
# parts rather than being declared: `VOLTAGE^Val(2) / POWER` *is* `IMPEDANCE`. The
# exponents add and Unitful composes the natural unit, both at the type level.
Base.:*(
    ::UnitCategory{N1, P1, V1},
    ::UnitCategory{N2, P2, V2},
) where {N1, P1, V1, N2, P2, V2} =
    UnitCategory{typeof(N1() * N2()), P1 + P2, V1 + V2}()
Base.:/(
    ::UnitCategory{N1, P1, V1},
    ::UnitCategory{N2, P2, V2},
) where {N1, P1, V1, N2, P2, V2} =
    UnitCategory{typeof(N1() / N2()), P1 - P2, V1 - V2}()
# The exponent is a `Val` so it is part of the type and the result stays a singleton.
Base.:^(::UnitCategory{N, P, V}, ::Val{n}) where {N, P, V, n} =
    UnitCategory{typeof(N()^n), P * n, V * n}()

# A generated alias prints as its bare `UnitCategory{...}` parameters otherwise, which
# is unreadable in an error message or at the REPL.
const _CATEGORY_NAMES = (
    (ACTIVE_POWER, "ACTIVE_POWER"),
    (REACTIVE_POWER, "REACTIVE_POWER"),
    (APPARENT_POWER, "APPARENT_POWER"),
    (IMPEDANCE, "IMPEDANCE"),
    (ADMITTANCE, "ADMITTANCE"),
    (VOLTAGE, "VOLTAGE"),
    (CURRENT, "CURRENT"),
    (ACTIVE_POWER_CHANGE_RATE, "ACTIVE_POWER_CHANGE_RATE"),
)

function Base.show(io::IO, cat::UnitCategory{NU, P, V}) where {NU, P, V}
    for (known, name) in _CATEGORY_NAMES
        cat === known && return print(io, name)
    end
    return print(io, "UnitCategory($(NU()), S^$P V^$V)")
end

# ============================================================
# natural_unit, base_value, system_base_value
# ============================================================

"""
    natural_unit(category) → Unitful.Units

The natural (physical) unit for this category.
"""
natural_unit(::UnitCategory{NU}) where {NU} = NU()

# Raise a base to a category exponent. The base is reached through `getter` rather than
# passed by value so that an exponent of zero never calls it: `_checked_base_voltage`
# errors when the base voltage is unset, and a quantity with `V == 0` must not care.
# One method per exponent that actually occurs, so `^` (a libm `pow` call) never
# appears in the generated code -- the same reason `_convert_curve_axes` in
# InfrastructureSystems is written one method per `Val`.
@inline _base_factor(::Val{0}, getter, c) = 1.0
@inline _base_factor(::Val{1}, getter, c) = getter(c)
@inline _base_factor(::Val{-1}, getter, c) = inv(getter(c))
@inline _base_factor(::Val{2}, getter, c) = (v = getter(c); v * v)
@inline _base_factor(::Val{-2}, getter, c) = (v = getter(c); inv(v * v))
@inline _base_factor(::Val{N}, getter, c) where {N} = getter(c)^N

# Voltage-dependent base values must fail loudly when the base voltage is
# unset; a silent fallback would mislabel the returned number.
function _checked_base_voltage(c)
    base_voltage = get_base_voltage(c)
    isnothing(base_voltage) && error("Base voltage is not defined for $(summary(c)).")
    return base_voltage
end

"""
    base_value(component, category) → Float64

1.0 CU of this category = `base_value(c, cat)` natural units.
"""
base_value(c, ::UnitCategory{NU, P, V}) where {NU, P, V} =
    _base_factor(Val(P), _get_component_base_power, c) *
    _base_factor(Val(V), _checked_base_voltage, c)

"""
    system_base_value(component, category) → Float64

1.0 SU of this category = `system_base_value(c, cat)` natural units.
"""
system_base_value(c, ::UnitCategory{NU, P, V}) where {NU, P, V} =
    _base_factor(Val(P), _get_system_base_power, c) *
    _base_factor(Val(V), _checked_base_voltage, c)

# CU→SU ratio. Only the power base differs between the two systems -- the base voltage
# is the same in both and cancels -- so the ratio is the power ratio raised to the
# category's power exponent, and a category with `P == 0` (voltage) needs no base at all.
_cu_su_power_ratio(c) = _get_component_base_power(c) / _get_system_base_power(c)
_cu_to_su_ratio(c, ::UnitCategory{NU, P, V}) where {NU, P, V} =
    _base_factor(Val(P), _cu_su_power_ratio, c)

# ============================================================
# convert_units: value from one unit system to another
# ============================================================

"""
    convert_units(component, value, category, from, to)

Convert a value between unit systems.

# Examples
```julia
convert_units(gen, 0.6, ACTIVE_POWER, CU, u"MW")       # → 30.0 MW
convert_units(gen, 30.0u"MW", ACTIVE_POWER, u"MW", CU) # → 0.6 CU
convert_units(gen, 0.6, ACTIVE_POWER, CU, SU)       # → 0.3 SU
```
"""
function convert_units end

# Excludes `Quantity`/`RelativeQuantity`, which are `<: Number` but neither `<: Real` nor
# `<: Complex`, and must fall through to the marker guards below. Widening this to `Number`
# makes those guards ambiguous.
const _BareNumber = Union{Real, Complex}

# --- From CU ---

function convert_units(
    c,
    value::_BareNumber,
    cat::UnitCategory,
    ::ComponentBaseUnit,
    units::Units,
)
    natural = value * base_value(c, cat) * natural_unit(cat)
    return uconvert(units, natural)
end

# Relative↔relative conversions go through the power-only ratio: the voltage
# terms in base_value/system_base_value cancel exactly, so fetching them would
# be wasted work (and would wrongly require a base voltage to be defined).
function convert_units(
    c,
    value::_BareNumber,
    cat::UnitCategory,
    ::ComponentBaseUnit,
    ::SystemBaseUnit,
)
    return (value * _cu_to_su_ratio(c, cat)) * SU
end

convert_units(
    ::Any,
    value::_BareNumber,
    ::UnitCategory,
    ::ComponentBaseUnit,
    ::ComponentBaseUnit,
) =
    value * CU

# --- From SU ---

function convert_units(
    c,
    value::_BareNumber,
    cat::UnitCategory,
    ::SystemBaseUnit,
    units::Units,
)
    natural = value * system_base_value(c, cat) * natural_unit(cat)
    return uconvert(units, natural)
end

function convert_units(
    c,
    value::_BareNumber,
    cat::UnitCategory,
    ::SystemBaseUnit,
    ::ComponentBaseUnit,
)
    return (value / _cu_to_su_ratio(c, cat)) * CU
end

convert_units(
    ::Any,
    value::_BareNumber,
    ::UnitCategory,
    ::SystemBaseUnit,
    ::SystemBaseUnit,
) =
    value * SU

# --- From natural units ---

function convert_units(c, val::Quantity, cat::UnitCategory, ::Units, ::ComponentBaseUnit)
    natural_val = Unitful.ustrip(natural_unit(cat), val)
    return RelativeQuantity(natural_val / base_value(c, cat), CU)
end

function convert_units(c, val::Quantity, cat::UnitCategory, ::Units, ::SystemBaseUnit)
    natural_val = Unitful.ustrip(natural_unit(cat), val)
    return RelativeQuantity(natural_val / system_base_value(c, cat), SU)
end

# --- To NU (natural units) — delegate to the category's natural unit ---

function convert_units(c, value::_BareNumber, cat::UnitCategory, from, ::NaturalUnit)
    return convert_units(c, value, cat, from, natural_unit(cat))
end

# --- From NU — delegate from the category's natural unit ---

function convert_units(c, val::Quantity, cat::UnitCategory, ::NaturalUnit, to)
    return convert_units(c, val, cat, natural_unit(cat), to)
end

# NU → NU (identity, attach the natural unit)
function convert_units(c, val::Quantity, cat::UnitCategory, ::NaturalUnit, ::NaturalUnit)
    return uconvert(natural_unit(cat), val)
end

# --- nothing passthrough ---
convert_units(::Any, ::Nothing, ::UnitCategory, ::Any, ::Any) = nothing

# --- rate categories: relative base per unit time ---

# A value expressed per `FROM` becomes `value * _time_factor(FROM, TO)` per `TO`
# (1/minute → 1/hr multiplies by hr/minute = 60). Both units are singleton types, so
# this folds to a literal.
_time_factor(::FROM, ::TO) where {FROM <: Unitful.Units, TO <: Unitful.Units} =
    Unitful.ustrip(Unitful.uconvert(Unitful.NoUnits, 1.0 * (TO() / FROM())))

# Re-base a bare relative value between CU and SU. Written out rather than delegated to
# `convert_units`, because for a rate category that would land on the bare-marker
# rejection below: the rejection is about an incomplete *target*, not about the power
# arithmetic, which is the same as for any other category.
_relative_rebase(::Any, v, ::UnitCategory, ::ComponentBaseUnit, ::ComponentBaseUnit) = v
_relative_rebase(::Any, v, ::UnitCategory, ::SystemBaseUnit, ::SystemBaseUnit) = v
_relative_rebase(c, v, cat::UnitCategory, ::ComponentBaseUnit, ::SystemBaseUnit) =
    v * _cu_to_su_ratio(c, cat)
_relative_rebase(c, v, cat::UnitCategory, ::SystemBaseUnit, ::ComponentBaseUnit) =
    v / _cu_to_su_ratio(c, cat)

# Storage (CU/SU at the category's storage time) → a relative rate marker: re-base the
# power axis, rescale the time axis, then re-attach both markers.
function convert_units(
    c,
    value::_BareNumber,
    cat::RateCategory,
    from::AbstractRelativeUnit,
    to::RateUnit,
)
    base = relative_unit(to)
    v = _relative_rebase(c, value, cat, from, base)
    return RelativeQuantity(v * _time_factor(storage_time(cat), time_unit(to)), base) /
           time_unit(to)
end

# A tagged rate value → anywhere: drop to the category's storage time, then re-enter the
# engine as an ordinary relative value. Mirrors the `RelativeQuantity` unwrap guard below.
# A `RelativeRate`'s Unitful parameter is the *inverse* time unit (`minute^-1`), since
# the quantity is a per-time one; the time unit itself is its reciprocal.
_rate_time(::RelativeRate{T, U, D, TU}) where {T, U, D, TU} = inv(TU())

# `from` is matched as `AbstractRelativeUnit` and the tag checked in the body rather
# than tied to `U` in the signature: tying it leaves these ambiguous against the
# "Unitful value carries a relative `from`" guard below, which they must beat.
function convert_units(
    c,
    val::RelativeRate{T, U, D, TU},
    cat::RateCategory,
    from::AbstractRelativeUnit,
    to::AbstractRelativeUnit,
) where {T, U, D, TU}
    _check_rate_tag(val, U(), from)
    v = IS._strip_units(val) * _time_factor(_rate_time(val), storage_time(cat))
    return RelativeQuantity(_relative_rebase(c, v, cat, from, to), to)
end

# …and to a rate marker, where the time axis moves again rather than collapsing.
function convert_units(
    c,
    val::RelativeRate{T, U, D, TU},
    cat::RateCategory,
    from::AbstractRelativeUnit,
    to::RateUnit,
) where {T, U, D, TU}
    _check_rate_tag(val, U(), from)
    v = IS._strip_units(val) * _time_factor(_rate_time(val), storage_time(cat))
    return convert_units(c, v, cat, from, to)
end

# Mirrors the `RelativeQuantity` tag/marker guard below: the value's own tag is
# authoritative, so a contradicting `from` is a caller error, not something to coerce.
@inline function _check_rate_tag(val, tag, from)
    tag === from || throw(
        ArgumentError(
            "value $val is tagged $tag but `from = $from`; the tag and the `from` " *
            "marker must agree",
        ),
    )
    return nothing
end

# A bare relative marker does not name a time, so it is not a complete target for a rate.
# One method per `(from, to)` marker pair, matching the specificity of the generic
# methods above -- narrowing only the category would be an ambiguity, not an override.
for FROM in (:ComponentBaseUnit, :SystemBaseUnit),
    TO in (:ComponentBaseUnit, :SystemBaseUnit)

    @eval function convert_units(
        ::Any,
        ::_BareNumber,
        cat::RateCategory,
        ::$FROM,
        to::$TO,
    )
        throw(
            ArgumentError(
                "$(cat) is a rate; `$(to)` alone does not say per what time. Pass a " *
                "relative base per unit time (e.g. `$(to)/u\"minute\"`, `$(to)/u\"hr\"`) " *
                "or a natural unit such as `u\"MW/minute\"`.",
            ),
        )
    end
end

# A rate marker is meaningless for a quantity that is not a rate.
convert_units(
    ::Any,
    ::_BareNumber,
    cat::UnitCategory,
    ::AbstractRelativeUnit,
    to::RateUnit,
) =
    throw(
        ArgumentError(
            "$(cat) is not a rate, so `$(relative_unit(to))/$(time_unit(to))` is not a " *
            "valid target; pass `$(relative_unit(to))` on its own.",
        ),
    )

# --- marker/value-type guards ---

# A Unitful value's units are authoritative; a relative "from" marker contradicts them.
function convert_units(
    ::Any,
    value::Quantity,
    ::UnitCategory,
    from::AbstractRelativeUnit,
    ::Any,
)
    throw(
        ArgumentError(
            "value $value carries physical units but `from = $from` claims a relative " *
            "base; pass the value's own units (or NU) as `from`",
        ),
    )
end

# A RelativeQuantity's marker is authoritative; it must match `from`.
function convert_units(
    c,
    value::RelativeQuantity{<:Any, U},
    cat::UnitCategory,
    ::U,
    to,
) where {U <: AbstractRelativeUnit}
    return convert_units(c, ustrip(value), cat, U(), to)
end

function convert_units(
    ::Any,
    value::RelativeQuantity{<:Any, V},
    ::UnitCategory,
    from::IS.AbstractUnitSystem,
    ::Any,
) where {V <: AbstractRelativeUnit}
    throw(
        ArgumentError(
            "value is tagged $(IS.RelativeUnits.unit(value)) but `from = $from`; " *
            "the tag and the `from` marker must agree",
        ),
    )
end

# Catch-all: any combination not defined above is unsupported — say so clearly.
function convert_units(::Any, value, ::UnitCategory, from, to)
    throw(
        ArgumentError(
            "unsupported unit conversion for $(typeof(value)) from $from to $to",
        ),
    )
end

# Multi-circuit components (e.g. three-winding transformers) do not need a
# separate conversion family: a per-pair *base provider* view (see
# `PairBase` in `src/models/components.jl`) implements the same three
# interface functions, so the full engine above works per pair.
