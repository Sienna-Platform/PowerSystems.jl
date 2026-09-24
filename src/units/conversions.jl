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
# Per-unit units of a category
# ============================================================

# One per-unit of a category with base exponents `(P, V)`, on the component and the system
# base: `CUp^P·CUv^V`, or its alias where one exists. Called only from `per_unit_table`'s
# generator.
_per_unit_units(::Val{P}, ::Val{V}) where {P, V} = (CUp^P * CUv^V, SUp^P * CUv^V)
_per_unit_units(::Val{-1}, ::Val{2}) = (CUz, SUz)
_per_unit_units(::Val{1}, ::Val{-2}) = (CUy, SUy)
_per_unit_units(::Val{1}, ::Val{-1}) = (CUi, SUi)

"""
    per_unit_table(category) -> (component, system, natural, residual)

The units `category`'s values take on each basis: one per-unit on the component base
(`CUp`, `CUz`, …), one on the system base (`SUp`, `SUz`, …), and the natural unit without
the residual (`u"MW"`, `u"Ω"`), plus the residual itself: what is left of the natural
unit once the per-unitized base is divided out (`u"minute^-1"` for a ramp, `NoUnits` for
a plain quantity). A stored value is `component * residual`.

Computed from the category's type in the generator, so every use is a constant.
"""
@generated function per_unit_table(::UnitCategory{N, P, V}) where {N, P, V}
    natural = N()
    residual = natural / (u"MW"^P * u"kV"^V)
    if Unitful.dimension(residual) == Unitful.NoDims
        # The natural units (MW, MVAr, MVA, kV, Ω, S, kA) are mutually consistent, so a
        # dimensionless residual is exactly 1.
        Unitful.uconvert(Unitful.NoUnits, 1.0 * residual) ≈ 1.0 ||
            error("inconsistent natural unit $natural for per-unit exponents ($P, $V)")
        residual = Unitful.NoUnits
    end
    component, system = _per_unit_units(Val(P), Val(V))
    return :(($component, $system, $(natural / residual), $residual))
end

# Which basis resolved units `t` are on: `:component`, `:system`, `:natural`, or
# `:mismatch` for per-unit units whose residual is wrong for the category (a bare `u"CU"`
# on a ramp). Called only from `_conversion_plan`'s generator.
function _basis_of(t, component, system, residual)
    dims = Unitful.dimension(t)
    dims == Unitful.dimension(component * residual) && return :component
    dims == Unitful.dimension(system * residual) && return :system
    names = map(d -> typeof(d).parameters[1], typeof(dims).parameters[1])
    per_unit =
        any(
            in((:PerUnitComponentPower, :PerUnitSystemPower, :PerUnitComponentVoltage)),
            names,
        )
    return per_unit ? :mismatch : :natural
end

"""
    _conversion_plan(category, units) -> (Val(basis), resolved_units)

How to convert `category`'s values to or from `units`: `units` with any generic
`u"CU"`/`u"SU"`/`u"NU"` resolved to the category's own, and which basis they are on. Both
come from the argument types in the generator, once per (category, units) pair, so a getter
compiles to the arithmetic alone.
"""
@generated function _conversion_plan(cat::UnitCategory, units::Unitful.Units)
    component, system, natural, residual = per_unit_table(cat.instance)
    t = IS.resolve_per_unit(units.instance, component, system, natural)
    return :(($(Val(_basis_of(t, component, system, residual))), $t))
end

"""
    convert_units(component, value::Quantity, category, to) -> Quantity

Convert `value` to the units `to`, resolving per-unit bases against `component`. Either
side may be natural (`u"MW"`) or per-unit, written with the generic `u"CU"`/`u"SU"`/`u"NU"`
or the resolved units (`CUp`, `SUz`, …).

# Examples
```julia
convert_units(gen, 0.6u"CU", ACTIVE_POWER, u"MW")   # → 30.0 MW
convert_units(gen, 30.0u"MW", ACTIVE_POWER, u"CU")  # → 0.6 CUp
convert_units(gen, 0.6u"CU", ACTIVE_POWER, u"SU")   # → 0.3 SUp
```
"""
convert_units(c, value::Quantity, cat::UnitCategory, to::Units) =
    _from_stored(c, _to_stored(c, value, cat), cat, to)
convert_units(::Any, ::Nothing, ::UnitCategory, ::Units) = nothing

# Stored (a bare component-base number, in the category's residual) → `to`.
function _from_stored(c, v::Number, cat::UnitCategory, to::Units)
    basis, t = _conversion_plan(cat, to)
    return _from_stored(basis, c, v, cat, t, to)
end
_from_stored(::Any, ::Nothing, ::UnitCategory, ::Units) = nothing

_from_stored(::Val{:component}, _, v, cat, t, _) =
    uconvert(t, v * _stored_unit(Val(:component), cat))
_from_stored(::Val{:system}, c, v, cat, t, _) =
    uconvert(t, (v * _cu_to_su_ratio(c, cat)) * _stored_unit(Val(:system), cat))
_from_stored(::Val{:natural}, c, v, cat, t, _) =
    uconvert(t, (v * base_value(c, cat)) * natural_unit(cat))
_from_stored(::Val{:mismatch}, _, _, cat, _, to) = _residual_error(cat, to)

# A quantity → the bare stored number. A value tagged with the generic `u"CU"` is read
# as this category's per-unit base.
function _to_stored(c, q::Quantity, cat::UnitCategory)
    basis, t = _conversion_plan(cat, Unitful.unit(q))
    return _to_stored(basis, c, ustrip(q) * t, cat)
end

_to_stored(::Val{:component}, _, q, cat) = ustrip(_stored_unit(Val(:component), cat), q)
_to_stored(::Val{:system}, c, q, cat) =
    ustrip(_stored_unit(Val(:system), cat), q) / _cu_to_su_ratio(c, cat)
_to_stored(::Val{:natural}, c, q, cat) =
    ustrip(natural_unit(cat), q) / base_value(c, cat)
_to_stored(::Val{:mismatch}, _, q, cat) = _residual_error(cat, Unitful.unit(q))

_stored_unit(::Val{:component}, cat) = (t = per_unit_table(cat); t[1] * t[4])
_stored_unit(::Val{:system}, cat) = (t = per_unit_table(cat); t[2] * t[4])

@noinline _residual_error(cat, t) = throw(
    ArgumentError(
        "$(cat) values per unit are in $(_stored_unit(Val(:component), cat)) on the " *
        "component base; `$t` does not match. Write the rest of the unit too, e.g. " *
        "`u\"CU$(_residual_suffix(per_unit_table(cat)[4]))\"`.",
    ),
)
_residual_suffix(::typeof(Unitful.NoUnits)) = ""
_residual_suffix(r) = "*" * unit_to_string(r)

# Multi-circuit components (e.g. three-winding transformers) do not need a
# separate conversion family: a per-pair *base provider* view (see
# `PairBase` in `src/models/components.jl`) implements the same three
# interface functions, so the full engine above works per pair.
