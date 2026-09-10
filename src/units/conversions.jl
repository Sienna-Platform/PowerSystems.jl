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

abstract type UnitCategory end

"""
Supertype of the three power categories. Active, reactive, and apparent power share
one dimension and one per-unit base (the device/system base power), so every base and
ratio rule below is written once against this supertype; the categories differ only in
which natural unit they print as (`u"MW"` / `u"MVAr"` / `u"MVA"`).
"""
abstract type AbstractPowerCategory <: UnitCategory end

struct ActivePowerCategory <: AbstractPowerCategory end
struct ReactivePowerCategory <: AbstractPowerCategory end
struct ApparentPowerCategory <: AbstractPowerCategory end
struct ImpedanceCategory <: UnitCategory end
struct AdmittanceCategory <: UnitCategory end
struct VoltageCategory <: UnitCategory end
struct CurrentCategory <: UnitCategory end

const ACTIVE_POWER = ActivePowerCategory()
const REACTIVE_POWER = ReactivePowerCategory()
const APPARENT_POWER = ApparentPowerCategory()
const IMPEDANCE = ImpedanceCategory()
const ADMITTANCE = AdmittanceCategory()
const VOLTAGE = VoltageCategory()
const CURRENT = CurrentCategory()

# ============================================================
# natural_unit, base_value, system_base_value
# ============================================================

"""
    natural_unit(category) → Unitful.Units

The natural (physical) unit for this category.
"""
# `MVAr`/`MVA` are PSY's own `@unit` definitions, reachable downstream as
# `u"MVAr"`/`u"MVA"` but not from `u"..."` inside PSY itself — registration with
# Unitful happens in `__init__`, after this file has been precompiled.
natural_unit(::ActivePowerCategory) = u"MW"
natural_unit(::ReactivePowerCategory) = MVAr
natural_unit(::ApparentPowerCategory) = MVA
natural_unit(::ImpedanceCategory) = u"Ω"
natural_unit(::AdmittanceCategory) = u"S"
natural_unit(::VoltageCategory) = u"kV"
natural_unit(::CurrentCategory) = u"kA"

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
base_value(c, ::AbstractPowerCategory) = _get_component_base_power(c)
base_value(c, ::ImpedanceCategory) =
    _checked_base_voltage(c)^2 / _get_component_base_power(c)
base_value(c, ::AdmittanceCategory) =
    _get_component_base_power(c) / _checked_base_voltage(c)^2
base_value(c, ::VoltageCategory) = _checked_base_voltage(c)
base_value(c, ::CurrentCategory) = _get_component_base_power(c) / _checked_base_voltage(c)

"""
    system_base_value(component, category) → Float64

1.0 SU of this category = `system_base_value(c, cat)` natural units.
"""
system_base_value(c, ::AbstractPowerCategory) = _get_system_base_power(c)
system_base_value(c, ::ImpedanceCategory) =
    _checked_base_voltage(c)^2 / _get_system_base_power(c)
system_base_value(c, ::AdmittanceCategory) =
    _get_system_base_power(c) / _checked_base_voltage(c)^2
system_base_value(c, ::VoltageCategory) = _checked_base_voltage(c)
system_base_value(c, ::CurrentCategory) =
    _get_system_base_power(c) / _checked_base_voltage(c)

# CU→SU ratio (voltage cancels, only power bases needed)
_cu_to_su_ratio(c, ::Union{AbstractPowerCategory, AdmittanceCategory, CurrentCategory}) =
    _get_component_base_power(c) / _get_system_base_power(c)
_cu_to_su_ratio(c, ::ImpedanceCategory) =
    _get_system_base_power(c) / _get_component_base_power(c)
_cu_to_su_ratio(::Any, ::VoltageCategory) = 1.0

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
