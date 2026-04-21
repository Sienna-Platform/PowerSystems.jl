#=
Unit conversion system for power systems components.

Core abstraction: a UnitCategory defines a physical quantity (power, impedance, etc.)
with a natural unit and a way to compute the per-unit base value for any component.

Downstream packages implement the interface functions:
  - get_device_base_power(c) → Float64 (MVA)
  - get_system_base_power(c) → Float64 (MVA)
  - get_base_voltage(c) → Float64 (kV)
=#

# ============================================================
# Interface functions — implemented by downstream packages
# ============================================================

"""
    get_device_base_power(component) → Float64

Return the device's base power in MVA as a raw Float64.
"""
function get_device_base_power end

"""
    get_system_base_power(component) → Float64

Return the system's base power in MVA as a raw Float64.
"""
function get_system_base_power end

"""
    get_base_voltage(component) → Float64

Return the base voltage in kV as a raw Float64.
"""
function get_base_voltage end

# ============================================================
# Unit categories
# ============================================================

abstract type UnitCategory end

struct PowerCategory <: UnitCategory end
struct ImpedanceCategory <: UnitCategory end
struct AdmittanceCategory <: UnitCategory end
struct VoltageCategory <: UnitCategory end
struct CurrentCategory <: UnitCategory end

const POWER = PowerCategory()
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
natural_unit(::PowerCategory) = u"MW"
natural_unit(::ImpedanceCategory) = u"Ω"
natural_unit(::AdmittanceCategory) = u"S"
natural_unit(::VoltageCategory) = u"kV"
natural_unit(::CurrentCategory) = u"kA"

"""
    base_value(component, category) → Float64

1.0 DU of this category = `base_value(c, cat)` natural units.
"""
base_value(c, ::PowerCategory) = get_device_base_power(c)
base_value(c, ::ImpedanceCategory) = get_base_voltage(c)^2 / get_device_base_power(c)
base_value(c, ::AdmittanceCategory) = get_device_base_power(c) / get_base_voltage(c)^2
base_value(c, ::VoltageCategory) = get_base_voltage(c)
base_value(c, ::CurrentCategory) = get_device_base_power(c) / get_base_voltage(c)

"""
    system_base_value(component, category) → Float64

1.0 SU of this category = `system_base_value(c, cat)` natural units.
"""
system_base_value(c, ::PowerCategory) = get_system_base_power(c)
system_base_value(c, ::ImpedanceCategory) = get_base_voltage(c)^2 / get_system_base_power(c)
system_base_value(c, ::AdmittanceCategory) =
    get_system_base_power(c) / get_base_voltage(c)^2
system_base_value(c, ::VoltageCategory) = get_base_voltage(c)
system_base_value(c, ::CurrentCategory) = get_system_base_power(c) / get_base_voltage(c)

# DU→SU ratio (voltage cancels, only power bases needed)
_du_to_su_ratio(c, ::PowerCategory) = get_device_base_power(c) / get_system_base_power(c)
_du_to_su_ratio(c, ::ImpedanceCategory) =
    get_system_base_power(c) / get_device_base_power(c)
_du_to_su_ratio(c, ::AdmittanceCategory) =
    get_device_base_power(c) / get_system_base_power(c)
_du_to_su_ratio(::Any, ::VoltageCategory) = 1.0
_du_to_su_ratio(c, ::CurrentCategory) = get_system_base_power(c) / get_device_base_power(c)

# ============================================================
# Default units for 1-arg getters (downstream convention)
# ============================================================

const DEFAULT_UNITS = SU

# ============================================================
# convert_units: value from one unit system to another
# ============================================================

"""
    convert_units(component, value, category, from, to)

Convert a value between unit systems.

# Examples
```julia
convert_units(gen, 0.6, POWER, DU, MW)       # → 30.0 MW
convert_units(gen, 30.0MW, POWER, MW, DU)    # → 0.6 DU
convert_units(gen, 0.6, POWER, DU, SU)       # → 0.3 SU
convert_units(gen, 0.6, POWER, DU, Float64)  # → 0.3 (raw SU value)
```
"""
function convert_units end

# --- From DU ---

function convert_units(c, value::Number, cat::UnitCategory, ::DeviceBaseUnit, units::Units)
    natural = value * base_value(c, cat) * natural_unit(cat)
    return uconvert(units, natural)
end

function convert_units(
    c,
    value::Number,
    cat::UnitCategory,
    ::DeviceBaseUnit,
    ::SystemBaseUnit,
)
    ratio = base_value(c, cat) / system_base_value(c, cat)
    return (value * ratio) * SU
end

convert_units(::Any, value::Number, ::UnitCategory, ::DeviceBaseUnit, ::DeviceBaseUnit) =
    value * DU

function convert_units(
    c,
    value::Float64,
    cat::UnitCategory,
    ::DeviceBaseUnit,
    ::Type{Float64},
)::Float64
    return value * _du_to_su_ratio(c, cat)
end

function convert_units(
    c,
    value::ComplexF64,
    cat::UnitCategory,
    ::DeviceBaseUnit,
    ::Type{Float64},
)::ComplexF64
    return value * _du_to_su_ratio(c, cat)
end

# --- From SU ---

function convert_units(c, value::Number, cat::UnitCategory, ::SystemBaseUnit, units::Units)
    natural = value * system_base_value(c, cat) * natural_unit(cat)
    return uconvert(units, natural)
end

function convert_units(
    c,
    value::Number,
    cat::UnitCategory,
    ::SystemBaseUnit,
    ::DeviceBaseUnit,
)
    ratio = system_base_value(c, cat) / base_value(c, cat)
    return (value * ratio) * DU
end

convert_units(::Any, value::Number, ::UnitCategory, ::SystemBaseUnit, ::SystemBaseUnit) =
    value * SU

# --- From natural units ---

function convert_units(c, val::Quantity, cat::UnitCategory, ::Units, ::DeviceBaseUnit)
    natural_val = Unitful.ustrip(natural_unit(cat), val)
    return RelativeQuantity(natural_val / base_value(c, cat), DU)
end

function convert_units(c, val::Quantity, cat::UnitCategory, ::Units, ::SystemBaseUnit)
    natural_val = Unitful.ustrip(natural_unit(cat), val)
    return RelativeQuantity(natural_val / system_base_value(c, cat), SU)
end

# --- To NU (natural units) — delegate to the category's natural unit ---

function convert_units(c, value::Number, cat::UnitCategory, from, ::NaturalUnit)
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
