import Unitful
using Unitful: Quantity, Units, @u_str, uconvert

# ============================================================
# Implement PowerSystemsUnits interface for PSY components
# ============================================================

@inline function IS.get_system_base_power(c::Component)::Float64
    units_info = get_internal(c).units_info
    if isnothing(units_info)
        error(
            "Component $(get_name(c)) is not attached to a system. Cannot determine system base power.",
        )
    end
    return (units_info::IS.SystemUnitsSettings).base_value
end

# Bridge to PowerSystemsUnits: delegates to _get_base_power, which has
# generated per-type methods (e.g. _get_base_power(c::ThermalStandard) = c.base_power)
# and a Component fallback below (returns system base for types without base_power field).
@inline IS.get_device_base_power(c::Component)::Float64 = _get_base_power(c)

IS.get_base_voltage(c::Branch) = get_base_voltage(get_arc(c).from)
IS.get_base_voltage(c::TwoWindingTransformer) = get_base_voltage_primary(c)
IS.get_base_voltage(c::StaticInjection) = get_base_voltage(get_bus(c))

# Fallback for components without a base_power field (e.g. Area):
# uses the system base power.
@inline function _get_base_power(c::Component)::Float64
    units_info = get_internal(c).units_info
    if isnothing(units_info)
        error(
            "Component $(get_name(c)) is not attached to a system. Cannot determine base power.",
        )
    end
    return (units_info::IS.SystemUnitsSettings).base_value
end

# Internal aliases
const _get_system_base_power = IS.get_system_base_power
const _get_base_voltage = IS.get_base_voltage

# ============================================================
# Hand-written base_power getters/setters
# (base_power defines the per-unit system, so it can't go through
# the generic device-base conversion path)
# ============================================================

get_base_power(c::Component) = _get_base_power(c) * u"MW"
get_base_power(c::Component, ::typeof(u"MW")) = _get_base_power(c) * u"MW"
get_base_power(c::Component, ::IS.DeviceBaseUnit) = 1.0 * IS.DU
get_base_power(c::Component, ::IS.NaturalUnit) = _get_base_power(c) * u"MW"
function get_base_power(c::Component, ::IS.SystemBaseUnit)
    return (_get_base_power(c) / _get_system_base_power(c)) * IS.SU
end

set_base_power!(c::Component, val::Quantity) = (c.base_power = Unitful.ustrip(u"MW", val))
set_base_power!(c::Component, val::Float64) = (c.base_power = val)
function set_base_power!(c::Component, val::IS.RelativeQuantity{<:Any, IS.SystemBaseUnit})
    c.base_power = IS.ustrip(val) * _get_system_base_power(c)
end

# 3WT per-winding base powers
get_base_power_12(c::Component) = _get_base_power_12(c) * u"MW"
get_base_power_12(c::Component, ::typeof(u"MW")) = _get_base_power_12(c) * u"MW"
get_base_power_12(c::Component, ::IS.DeviceBaseUnit) = 1.0 * IS.DU
get_base_power_12(c::Component, ::IS.SystemBaseUnit) =
    (_get_base_power_12(c) / _get_system_base_power(c)) * IS.SU
set_base_power_12!(c::Component, val::Quantity) =
    (c.base_power_12 = Unitful.ustrip(u"MW", val))
set_base_power_12!(c::Component, val::Float64) = (c.base_power_12 = val)

get_base_power_23(c::Component) = _get_base_power_23(c) * u"MW"
get_base_power_23(c::Component, ::typeof(u"MW")) = _get_base_power_23(c) * u"MW"
get_base_power_23(c::Component, ::IS.DeviceBaseUnit) = 1.0 * IS.DU
get_base_power_23(c::Component, ::IS.SystemBaseUnit) =
    (_get_base_power_23(c) / _get_system_base_power(c)) * IS.SU
set_base_power_23!(c::Component, val::Quantity) =
    (c.base_power_23 = Unitful.ustrip(u"MW", val))
set_base_power_23!(c::Component, val::Float64) = (c.base_power_23 = val)

get_base_power_13(c::Component) = _get_base_power_13(c) * u"MW"
get_base_power_13(c::Component, ::typeof(u"MW")) = _get_base_power_13(c) * u"MW"
get_base_power_13(c::Component, ::IS.DeviceBaseUnit) = 1.0 * IS.DU
get_base_power_13(c::Component, ::IS.SystemBaseUnit) =
    (_get_base_power_13(c) / _get_system_base_power(c)) * IS.SU
set_base_power_13!(c::Component, val::Quantity) =
    (c.base_power_13 = Unitful.ustrip(u"MW", val))
set_base_power_13!(c::Component, val::Float64) = (c.base_power_13 = val)

# ============================================================
# Val → UnitCategory mapping (bridges generated code to PowerSystemsUnits)
# ============================================================

_to_category(::Val{:mva}) = IS.POWER
_to_category(::Val{:ohm}) = IS.IMPEDANCE
_to_category(::Val{:siemens}) = IS.ADMITTANCE
_to_category(::Val{:kv}) = IS.VOLTAGE
_to_category(::Val{:ka}) = IS.CURRENT

# ============================================================
# get_value: read field + convert via PowerSystemsUnits
# ============================================================

function get_value(c::Component, ::Val{T}, cat::Val, units) where {T}
    value = Base.getproperty(c, T)
    return _convert_value(c, value, _to_category(cat), units)
end

# Float64 path — unattached component fallback
function get_value(c::Component, ::Val{T}, cat::Val, ::Type{Float64}) where {T}
    value = Base.getproperty(c, T)
    units_info = get_internal(c).units_info
    isnothing(units_info) && return value
    return _convert_value(c, value, _to_category(cat), Float64)
end

# Scalar values → delegate to PowerSystemsUnits
_convert_value(c, value::Number, cat::IS.UnitCategory, units) =
    IS.convert_units(c, value, cat, IS.DU, units)
_convert_value(::Any, ::Nothing, ::IS.UnitCategory, ::Any) = nothing

# Compound types (NamedTuple) — map over elements
_convert_value(c, value::NamedTuple, cat, units) =
    map(v -> _convert_value(c, v, cat, units), value)

# ============================================================
# set_value: convert unitful input → device-base p.u.
# ============================================================

function set_value(c::Component, field, val::Quantity, cat::Val)
    return IS.ustrip(IS.convert_units(c, val, _to_category(cat), IS.NU, IS.DU))
end

function set_value(
    ::Component,
    field,
    val::IS.RelativeQuantity{<:Any, IS.DeviceBaseUnit},
    ::Val,
)
    return IS.ustrip(val)
end

function set_value(
    c::Component,
    field,
    val::IS.RelativeQuantity{<:Any, IS.SystemBaseUnit},
    cat::Val,
)
    return IS.ustrip(IS.convert_units(c, IS.ustrip(val), _to_category(cat), IS.SU, IS.DU))
end

# Compound type setters — map over elements
function set_value(c::Component, field, val::NamedTuple, cat::Val)
    return map(v -> set_value(c, nothing, v, cat), val)
end

# ============================================================
# LEGACY: Stateful unit system (set_units_base_system! / with_units_base)
#
# Everything below this line uses the old _get_multiplier approach that
# reads the system's runtime unit setting. Kept for:
#   - HybridSystem.jl (hand-written 3-arg get_value calls)
#   - ThreeWindingTransformer stateful path
#   - with_units_base / set_units_base_system! in base.jl
# TODO: migrate HybridSystem to 4-arg getters, then remove all of this.
# ============================================================

_get_multiplier(c::T, conversion_unit) where {T <: Component} =
    _get_multiplier(c, get_internal(c).units_info, conversion_unit)

_get_multiplier(::T, ::Nothing, conversion_unit) where {T <: Component} = 1.0

_get_multiplier(
    c::T,
    setting::IS.SystemUnitsSettings,
    conversion_unit,
) where {T <: Component} =
    _get_multiplier(c, setting, Val(setting.unit_system), conversion_unit)

_get_multiplier(
    ::T,
    ::IS.SystemUnitsSettings,
    ::Val{IS.UnitSystem.DEVICE_BASE},
    ::Any,
) where {T <: Component} = 1.0

# Power
_get_multiplier(
    c::T,
    setting::IS.SystemUnitsSettings,
    ::Val{IS.UnitSystem.SYSTEM_BASE},
    ::Val{:mva},
) where {T <: Component} =
    _get_base_power(c) / setting.base_value
_get_multiplier(
    c::T,
    ::IS.SystemUnitsSettings,
    ::Val{IS.UnitSystem.NATURAL_UNITS},
    ::Val{:mva},
) where {T <: Component} =
    _get_base_power(c)

# Ohms
_get_multiplier(
    c::T,
    setting::IS.SystemUnitsSettings,
    ::Val{IS.UnitSystem.SYSTEM_BASE},
    ::Val{:ohm},
) where {T <: Branch} =
    setting.base_value / _get_base_power(c)
function _get_multiplier(
    c::T,
    ::IS.SystemUnitsSettings,
    ::Val{IS.UnitSystem.NATURAL_UNITS},
    ::Val{:ohm},
) where {T <: Branch}
    return _get_base_voltage(c)^2 / _get_base_power(c)
end
function _get_multiplier(
    c::T,
    ::IS.SystemUnitsSettings,
    ::Val{IS.UnitSystem.NATURAL_UNITS},
    ::Val{:ohm},
) where {T <: TwoWindingTransformer}
    return get_base_voltage_primary(c)^2 / _get_base_power(c)
end

# Siemens
_get_multiplier(
    c::T,
    setting::IS.SystemUnitsSettings,
    ::Val{IS.UnitSystem.SYSTEM_BASE},
    ::Val{:siemens},
) where {T <: Branch} =
    _get_base_power(c) / setting.base_value
function _get_multiplier(
    c::T,
    ::IS.SystemUnitsSettings,
    ::Val{IS.UnitSystem.NATURAL_UNITS},
    ::Val{:siemens},
) where {T <: Branch}
    bv = _get_base_voltage(c)
    isnothing(bv) && return 1.0
    return _get_base_power(c) / bv^2
end
function _get_multiplier(
    c::T,
    ::IS.SystemUnitsSettings,
    ::Val{IS.UnitSystem.NATURAL_UNITS},
    ::Val{:siemens},
) where {T <: TwoWindingTransformer}
    bv = get_base_voltage_primary(c)
    isnothing(bv) && return 1.0
    return _get_base_power(c) / bv^2
end

_get_multiplier(::T, ::IS.SystemUnitsSettings, _, _) where {T <: Component} =
    error("Undefined Conditional")

# LEGACY: 3-arg get_value (stateful). Only called by HybridSystem.jl and 3WT.
function get_value(c::Component, ::Val{T}, conversion_unit) where {T}
    value = Base.getproperty(c, T)
    return _get_value(c, value, conversion_unit)
end

# LEGACY: _get_value/_set_value helpers for the stateful 3-arg path.
_get_value(c::Component, value::Float64, cu)::Float64 = _get_multiplier(c, cu) * value
_get_value(c::Component, value::ComplexF64, cu)::ComplexF64 = _get_multiplier(c, cu) * value
_get_value(c::Component, value::NamedTuple, cu) =
    map(v -> _get_value(c, v, cu), value)
_get_value(::Component, ::Nothing, _) = nothing
_get_value(::T, value::V, _) where {T <: Component, V} =
    (@warn("conversion not implemented for $(V) in component $(T)"); value::V)
_get_value(::Nothing, _, _) = nothing

# LEGACY: 3-arg set_value (stateful).
function set_value(c::Component, _, val, conversion_unit)
    return _set_value(c, val, conversion_unit)
end

_set_value(c::Component, value::Float64, cu)::Float64 = value / _get_multiplier(c, cu)
_set_value(c::Component, value::NamedTuple, cu) =
    map(v -> _set_value(c, v, cu), value)
_set_value(::Component, ::Nothing, _) = nothing
_set_value(::T, value::V, _) where {T <: Component, V} =
    (@warn("conversion not implemented for $(V) in component $(T)"); value::V)
_set_value(::Nothing, _, _) = nothing

# ============================================================
# LEGACY: ThreeWindingTransformer — per-winding base power/voltage dispatch
#
# 3WT can't use the generic conversion path because base voltage/power
# depend on which winding (field). The winding-aware dispatch uses
# the legacy _get_multiplier approach.
# TODO: refactor when 3WT windings become their own struct types.
# ============================================================

PrimaryImpedances = Union{Val{:r_primary}, Val{:x_primary}, Val{:r_12}, Val{:x_12}}
PrimaryAdmittances = Union{Val{:g}, Val{:b}}
PrimaryPower = Union{
    Val{:active_power_flow_primary},
    Val{:reactive_power_flow_primary},
    Val{:rating},
    Val{:rating_primary},
}
SecondaryImpedances = Union{Val{:r_secondary}, Val{:x_secondary}, Val{:r_23}, Val{:x_23}}
SecondaryPower = Union{
    Val{:active_power_flow_secondary},
    Val{:reactive_power_flow_secondary},
    Val{:rating_secondary},
}
TertiaryImpedances = Union{Val{:r_tertiary}, Val{:x_tertiary}, Val{:r_13}, Val{:x_13}}
TertiaryPower = Union{
    Val{:active_power_flow_tertiary},
    Val{:reactive_power_flow_tertiary},
    Val{:rating_tertiary},
}

_get_winding_base_power(
    c::ThreeWindingTransformer,
    ::Union{PrimaryImpedances, PrimaryAdmittances, PrimaryPower},
) = _get_base_power_12(c)
_get_winding_base_power(
    c::ThreeWindingTransformer,
    ::Union{SecondaryImpedances, SecondaryPower},
) = _get_base_power_23(c)
_get_winding_base_power(
    c::ThreeWindingTransformer,
    ::Union{TertiaryImpedances, TertiaryPower},
) = _get_base_power_13(c)

function _get_winding_base_voltage(
    c::ThreeWindingTransformer,
    ::Union{PrimaryImpedances, PrimaryAdmittances},
)
    bv = get_base_voltage_primary(c)
    isnothing(bv) && error("Base voltage is not defined for $(summary(c)).")
    return bv
end
function _get_winding_base_voltage(c::ThreeWindingTransformer, ::SecondaryImpedances)
    bv = get_base_voltage_secondary(c)
    isnothing(bv) && error("Base voltage is not defined for $(summary(c)).")
    return bv
end
function _get_winding_base_voltage(c::ThreeWindingTransformer, ::TertiaryImpedances)
    bv = get_base_voltage_tertiary(c)
    isnothing(bv) && error("Base voltage is not defined for $(summary(c)).")
    return bv
end

# Legacy multipliers for 3WT
_get_multiplier(
    ::ThreeWindingTransformer,
    ::Any,
    ::Val{IS.UnitSystem.DEVICE_BASE},
    ::Float64,
    ::Any,
) = 1.0
_get_multiplier(
    c::ThreeWindingTransformer,
    field,
    ::Val{IS.UnitSystem.SYSTEM_BASE},
    base_mva::Float64,
    ::Val{:mva},
) = _get_winding_base_power(c, field) / base_mva
_get_multiplier(
    c::ThreeWindingTransformer,
    field,
    ::Val{IS.UnitSystem.NATURAL_UNITS},
    ::Float64,
    ::Val{:mva},
) = _get_winding_base_power(c, field)
_get_multiplier(
    c::ThreeWindingTransformer,
    field,
    ::Val{IS.UnitSystem.SYSTEM_BASE},
    base_mva::Float64,
    ::Val{:ohm},
) = base_mva / _get_winding_base_power(c, field)
_get_multiplier(
    c::ThreeWindingTransformer,
    field,
    ::Val{IS.UnitSystem.NATURAL_UNITS},
    ::Float64,
    ::Val{:ohm},
) = _get_winding_base_voltage(c, field)^2 / _get_winding_base_power(c, field)
_get_multiplier(
    c::ThreeWindingTransformer,
    field,
    ::Val{IS.UnitSystem.SYSTEM_BASE},
    base_mva::Float64,
    ::Val{:siemens},
) = _get_winding_base_power(c, field) / base_mva
_get_multiplier(
    c::ThreeWindingTransformer,
    field,
    ::Val{IS.UnitSystem.NATURAL_UNITS},
    ::Float64,
    ::Val{:siemens},
) = _get_winding_base_power(c, field) / _get_winding_base_voltage(c, field)^2

# 3WT legacy 3-arg path (stateful unit system)
function get_value(c::ThreeWindingTransformer, field::Val{T}, conversion_unit) where {T}
    value = Base.getproperty(c, T)
    isnothing(value) && return nothing
    settings = get_internal(c).units_info
    isnothing(settings) && return value
    multiplier = _get_multiplier(
        c, field, Val(settings.unit_system), settings.base_value, conversion_unit,
    )
    return value * multiplier
end

# 3WT 4-arg path (explicit units) — route through winding-aware multipliers.
function get_value(
    c::ThreeWindingTransformer,
    field::Val{T},
    cat::Val,
    units::Units,
) where {T}
    value = Base.getproperty(c, T)
    isnothing(value) && return nothing
    nat_multiplier = _get_multiplier(c, field, Val(IS.UnitSystem.NATURAL_UNITS), 0.0, cat)
    return uconvert(units, value * nat_multiplier * IS.natural_unit(_to_category(cat)))
end

function get_value(
    c::ThreeWindingTransformer,
    field::Val{T},
    cat::Val,
    ::IS.DeviceBaseUnit,
) where {T}
    value = Base.getproperty(c, T)
    isnothing(value) && return nothing
    return value * IS.DU
end

function get_value(
    c::ThreeWindingTransformer,
    field::Val{T},
    cat::Val,
    ::IS.SystemBaseUnit,
) where {T}
    value = Base.getproperty(c, T)
    isnothing(value) && return nothing
    settings = get_internal(c).units_info
    isnothing(settings) && return value * IS.SU
    su_multiplier = _get_multiplier(
        c, field, Val(IS.UnitSystem.SYSTEM_BASE), settings.base_value, cat,
    )
    return (value * su_multiplier) * IS.SU
end

# 3WT Float64 path
function get_value(
    c::ThreeWindingTransformer,
    field::Val{T},
    cat::Val,
    ::Type{Float64},
) where {T}
    value = Base.getproperty(c, T)
    isnothing(value) && return nothing
    settings = get_internal(c).units_info
    isnothing(settings) && return value
    su_multiplier = _get_multiplier(
        c, field, Val(IS.UnitSystem.SYSTEM_BASE), settings.base_value, cat,
    )
    return value * su_multiplier
end

function set_value(c::ThreeWindingTransformer, field, val::Float64, conversion_unit)
    settings = get_internal(c).units_info
    isnothing(settings) && return val
    multiplier = _get_multiplier(
        c, field, Val(settings.unit_system), settings.base_value, conversion_unit,
    )
    return val / multiplier
end
