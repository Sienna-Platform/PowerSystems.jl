import Unitful
using Unitful: Quantity, Units, @u_str, uconvert

# ============================================================
# Internal base-quantity accessors (raw Float64, implied natural units).
# These are used by the conversion machinery. The public get_base_power /
# get_base_voltage go through the conversion path and return unitful values.
# ============================================================

@inline function _get_system_base_power(c::Component)::Float64
    units_info = get_internal(c).units_info
    if isnothing(units_info)
        error(
            "Component $(get_name(c)) is not attached to a system. Cannot determine system base power.",
        )
    end
    # Type assertion needed because units_info is Union{Nothing, UnitsData} where
    # UnitsData is abstract. If IS changes the field type on InfrastructureSystemsInternal
    # to Union{Nothing, SystemUnitsSettings}, this assertion can be removed.
    return (units_info::IS.SystemUnitsSettings).base_value
end

"""
Internal: raw Float64 base power in MVA. For components without a base_power field,
falls back to the system base power.
"""
@inline function _get_base_power(c::Component)::Float64
    units_info = get_internal(c).units_info
    if isnothing(units_info)
        error(
            "Component $(get_name(c)) is not attached to a system. Cannot determine base power.",
        )
    end
    return units_info.base_value
end

# For components that have a base_power field, the generated getter/setter are excluded
# (via exclude_getter/exclude_setter in power_system_structs.json). Instead we define:
#   _get_base_power(c) — raw Float64, used internally by conversion machinery
#   get_base_power(c) — returns unitful MW, the public API
#   set_base_power!(c, val) — accepts unitful or raw Float64
#
# The _get_base_power fallback above returns system base for components without the field.
# Components with the field get an override via the generated _get_base_power methods
# (not yet generated — for now we rely on the fact that the generated get_base_power
# was the only caller, and it's been removed).

# Public unitful getter: base_power is stored in natural units (MW), so just attach unit.
# This is defined on Component — it works for both the field-access case and the
# system-base fallback, since _get_base_power handles the dispatch.
get_base_power(c::Component) = _get_base_power(c) * u"MW"

# With explicit unit request:
get_base_power(c::Component, ::typeof(u"MW")) = _get_base_power(c) * u"MW"
get_base_power(c::Component, ::IS.DeviceBaseUnit) = 1.0 * IS.DU  # always 1.0 by definition
function get_base_power(c::Component, ::IS.SystemBaseUnit)
    return (_get_base_power(c) / _get_system_base_power(c)) * IS.SU
end

# Public setter: accepts unitful MW or raw Float64 (for backward compat).
set_base_power!(c::Component, val::Quantity) = (c.base_power = Unitful.ustrip(u"MW", val))
set_base_power!(c::Component, val::Float64) = (c.base_power = val)
function set_base_power!(c::Component, val::IS.RelativeQuantity{<:Any, IS.SystemBaseUnit})
    c.base_power = IS.ustrip(val) * _get_system_base_power(c)
end

# 3WT per-winding base powers — same pattern as base_power.
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

# PERF: line → arc → from_bus → base_voltage chain slows things down a bit.
_get_base_voltage(c::Branch) = get_base_voltage(get_arc(c).from)
_get_base_voltage(c::TwoWindingTransformer) = get_base_voltage_primary(c)
_get_base_voltage(c::StaticInjection) = get_base_voltage(get_bus(c))

# ============================================================
# Table-driven unit conversion system
#
# Two lookup tables per unit category, plus one per-family dispatch
# for base voltage. Everything else is generic.
# ============================================================

# Device-base-to-natural conversion factor, per unit category.
# :natural_mw is for fields already stored in natural units (e.g. base_power).
# Conversion factor is 1.0 — just attach the unit.
_conversion_base(c, ::Val{:natural_mw}) = 1.0
_conversion_base(c, ::Val{:mva}) = _get_base_power(c)
_conversion_base(c, ::Val{:ohm}) = _get_base_voltage(c)^2 / _get_base_power(c)
_conversion_base(c, ::Val{:siemens}) = _get_base_power(c) / _get_base_voltage(c)^2
_conversion_base(c, ::Val{:kv}) = _get_base_voltage(c)
_conversion_base(c, ::Val{:ka}) = _get_base_power(c) / _get_base_voltage(c)  # unused currently

# The natural Unitful unit for each category.
_natural_unit(::Val{:natural_mw}) = u"MW"
_natural_unit(::Val{:mva}) = u"MW"
_natural_unit(::Val{:ohm}) = u"Ω"
_natural_unit(::Val{:siemens}) = u"S"
_natural_unit(::Val{:kv}) = u"kV"
_natural_unit(::Val{:ka}) = u"kA"

# System-base-to-natural conversion factor, per unit category.
_system_conversion_base(c, ::Val{:mva}) = _get_system_base_power(c)
_system_conversion_base(c, ::Val{:ohm}) = _get_base_voltage(c)^2 / _get_system_base_power(c)
_system_conversion_base(c, ::Val{:siemens}) =
    _get_system_base_power(c) / _get_base_voltage(c)^2
# Voltage base is per-bus, not system-wide (unlike power, which has both a per-device
# and a system-wide base). So the "system" voltage base is the same as the device one.
_system_conversion_base(c, ::Val{:kv}) = _get_base_voltage(c)
_system_conversion_base(c, ::Val{:ka}) = _get_system_base_power(c) / _get_base_voltage(c)

# ============================================================
# Default units for 1-arg getters
# ============================================================

# The default units returned by 1-arg getters (e.g., get_active_power(gen)).
# SU (system base per-unit) matches the common downstream use case (PSI).
# Change to MW / OHMS / etc. for natural units if preferred.
const DEFAULT_UNITS = IS.SU

# ============================================================
# Stateful unit system (reads the system's current setting)
# Kept for backward compat of set_units_base_system! / with_units_base.
# No longer used by default 1-arg getters.
# ============================================================

function _get_system_units(c::Component, cat::Val)
    units_info = get_internal(c).units_info
    if isnothing(units_info)
        return _natural_unit(cat)  # Default to natural units if not set
    end
    unit_system = units_info.unit_system
    if unit_system == IS.UnitSystem.NATURAL_UNITS
        return _natural_unit(cat)
    elseif unit_system == IS.UnitSystem.DEVICE_BASE
        return IS.DU
    else  # SYSTEM_BASE
        return IS.SU
    end
end

# ============================================================
# get_value: read field + convert from device-base p.u.
# ============================================================

function get_value(c::Component, field::Val{T}, cat, units) where {T}
    value = Base.getproperty(c, T)
    return _convert_from_device_base(c, value, cat, units)
end

# → Natural units (MW, Ω, S, or any Unitful unit via uconvert)
function _convert_from_device_base(c::Component, value::Number, cat::Val, units::Units)
    natural = value * _conversion_base(c, cat) * _natural_unit(cat)
    return uconvert(units, natural)
end

# → Device base (DU) — identity on the numeric value
function _convert_from_device_base(::Component, value::Number, ::Val, ::IS.DeviceBaseUnit)
    return value * IS.DU
end

# → System base (SU)
function _convert_from_device_base(
    c::Component,
    value::Number,
    cat::Val,
    ::IS.SystemBaseUnit,
)
    ratio = _conversion_base(c, cat) / _system_conversion_base(c, cat)
    return (value * ratio) * IS.SU
end

# → Raw Float64 in DEFAULT_UNITS (skips unit wrapper).
# Convenience for downstream packages (e.g. PNM) that work in system-base p.u.
# and don't need the Unitful wrapper.
function _convert_from_device_base(
    c::Component,
    value::Number,
    cat::Val,
    ::Type{Float64},
)
    ratio = _conversion_base(c, cat) / _system_conversion_base(c, cat)
    return (value * ratio)::Float64
end

# nothing passthrough
_convert_from_device_base(::Component, ::Nothing, ::Val, ::Any) = nothing

# Compound types — recurse into elements
function _convert_from_device_base(c::Component, value::MinMax, cat, units)
    return (
        min = _convert_from_device_base(c, value.min, cat, units),
        max = _convert_from_device_base(c, value.max, cat, units),
    )
end

function _convert_from_device_base(c::Component, value::UpDown, cat, units)
    return (
        up = _convert_from_device_base(c, value.up, cat, units),
        down = _convert_from_device_base(c, value.down, cat, units),
    )
end

function _convert_from_device_base(c::Component, value::FromTo_ToFrom, cat, units)
    return (
        from_to = _convert_from_device_base(c, value.from_to, cat, units),
        to_from = _convert_from_device_base(c, value.to_from, cat, units),
    )
end

function _convert_from_device_base(c::Component, value::FromTo, cat, units)
    return (
        from = _convert_from_device_base(c, value.from, cat, units),
        to = _convert_from_device_base(c, value.to, cat, units),
    )
end

function _convert_from_device_base(c::Component, value::StartUpShutDown, cat, units)
    return (
        startup = _convert_from_device_base(c, value.startup, cat, units),
        shutdown = _convert_from_device_base(c, value.shutdown, cat, units),
    )
end

# ============================================================
# set_value: convert unitful input → device-base p.u.
# ============================================================

# From Unitful quantity (e.g., 30.0u"MW")
function set_value(c::Component, field, val::Quantity, cat::Val)
    natural_val = Unitful.ustrip(_natural_unit(cat), val)
    return natural_val / _conversion_base(c, cat)
end

# From DU — identity
function set_value(
    ::Component,
    field,
    val::IS.RelativeQuantity{<:Any, IS.DeviceBaseUnit},
    ::Val,
)
    return IS.ustrip(val)
end

# From SU
function set_value(
    c::Component,
    field,
    val::IS.RelativeQuantity{<:Any, IS.SystemBaseUnit},
    cat::Val,
)
    ratio = _conversion_base(c, cat) / _system_conversion_base(c, cat)
    return IS.ustrip(val) / ratio
end

# Compound type setters — recurse into elements
function _to_device_base(c::Component, val, cat)
    return set_value(c, nothing, val, cat)
end

function set_value(c::Component, field, val::NamedTuple{(:min, :max)}, cat::Val)
    return (min = _to_device_base(c, val.min, cat), max = _to_device_base(c, val.max, cat))
end

function set_value(c::Component, field, val::NamedTuple{(:up, :down)}, cat::Val)
    return (up = _to_device_base(c, val.up, cat), down = _to_device_base(c, val.down, cat))
end

function set_value(c::Component, field, val::NamedTuple{(:from_to, :to_from)}, cat::Val)
    return (
        from_to = _to_device_base(c, val.from_to, cat),
        to_from = _to_device_base(c, val.to_from, cat),
    )
end

function set_value(c::Component, field, val::NamedTuple{(:from, :to)}, cat::Val)
    return (from = _to_device_base(c, val.from, cat), to = _to_device_base(c, val.to, cat))
end

function set_value(c::Component, field, val::NamedTuple{(:startup, :shutdown)}, cat::Val)
    return (
        startup = _to_device_base(c, val.startup, cat),
        shutdown = _to_device_base(c, val.shutdown, cat),
    )
end

# ============================================================
# Legacy get_value/set_value (stateful unit system, backwards compat)
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

function get_value(c::Component, ::Val{T}, conversion_unit) where {T}
    value = Base.getproperty(c, T)
    return _get_value(c, value, conversion_unit)
end

_get_value(c::Component, value::Float64, cu)::Float64 = _get_multiplier(c, cu) * value
_get_value(c::Component, value::ComplexF64, cu)::ComplexF64 = _get_multiplier(c, cu) * value
_get_value(c::Component, value::MinMax, cu)::MinMax =
    (m = _get_multiplier(c, cu); (min = value.min * m, max = value.max * m))
_get_value(c::Component, value::StartUpShutDown, cu)::StartUpShutDown = (
    m = _get_multiplier(c, cu);
    (startup = value.startup * m, shutdown = value.shutdown * m)
)
_get_value(c::Component, value::UpDown, cu)::UpDown =
    (m = _get_multiplier(c, cu); (up = value.up * m, down = value.down * m))
_get_value(c::Component, value::FromTo_ToFrom, cu)::FromTo_ToFrom =
    (m = _get_multiplier(c, cu); (from_to = value.from_to * m, to_from = value.to_from * m))
_get_value(c::Component, value::FromTo, cu)::FromTo =
    (m = _get_multiplier(c, cu); (from = value.from * m, to = value.to * m))
_get_value(::Component, ::Nothing, _) = nothing
_get_value(::T, value::V, _) where {T <: Component, V} =
    (@warn("conversion not implemented for $(V) in component $(T)"); value::V)
_get_value(::Nothing, _, _) = nothing

function set_value(c::Component, _, val, conversion_unit)
    return _set_value(c, val, conversion_unit)
end

_set_value(c::Component, value::Float64, cu)::Float64 = value / _get_multiplier(c, cu)
_set_value(c::Component, value::MinMax, cu)::MinMax =
    (m = 1 / _get_multiplier(c, cu); (min = value.min * m, max = value.max * m))
_set_value(c::Component, value::StartUpShutDown, cu)::StartUpShutDown = (
    m = 1 / _get_multiplier(c, cu);
    (startup = value.startup * m, shutdown = value.shutdown * m)
)
_set_value(c::Component, value::UpDown, cu)::UpDown =
    (m = 1 / _get_multiplier(c, cu); (up = value.up * m, down = value.down * m))
_set_value(c::Component, value::FromTo_ToFrom, cu)::FromTo_ToFrom = (
    m = 1 / _get_multiplier(c, cu);
    (from_to = value.from_to * m, to_from = value.to_from * m)
)
_set_value(c::Component, value::FromTo, cu)::FromTo =
    (m = 1 / _get_multiplier(c, cu); (from = value.from * m, to = value.to * m))
_set_value(::Component, ::Nothing, _) = nothing
_set_value(::T, value::V, _) where {T <: Component, V} =
    (@warn("conversion not implemented for $(V) in component $(T)"); value::V)
_set_value(::Nothing, _, _) = nothing

# ============================================================
# ThreeWindingTransformer — per-winding base power/voltage dispatch
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
        c,
        field,
        Val(settings.unit_system),
        settings.base_value,
        conversion_unit,
    )
    return value * multiplier
end

# 3WT 4-arg path (explicit units) — route through winding-aware multipliers.
# The generic _convert_from_device_base can't handle 3WT because base voltage
# depends on which winding, and that info is in the field Val, not the unit category.
function get_value(c::ThreeWindingTransformer, field::Val{T}, cat, units::Units) where {T}
    value = Base.getproperty(c, T)
    isnothing(value) && return nothing
    nat_multiplier = _get_multiplier(c, field, Val(IS.UnitSystem.NATURAL_UNITS), 0.0, cat)
    return uconvert(units, value * nat_multiplier * _natural_unit(cat))
end

function get_value(
    c::ThreeWindingTransformer,
    field::Val{T},
    cat,
    ::IS.DeviceBaseUnit,
) where {T}
    value = Base.getproperty(c, T)
    isnothing(value) && return nothing
    return value * IS.DU
end

function get_value(
    c::ThreeWindingTransformer,
    field::Val{T},
    cat,
    ::IS.SystemBaseUnit,
) where {T}
    value = Base.getproperty(c, T)
    isnothing(value) && return nothing
    settings = get_internal(c).units_info
    isnothing(settings) && return value * IS.SU
    su_multiplier =
        _get_multiplier(c, field, Val(IS.UnitSystem.SYSTEM_BASE), settings.base_value, cat)
    return (value * su_multiplier) * IS.SU
end

function set_value(c::ThreeWindingTransformer, field, val::Float64, conversion_unit)
    settings = get_internal(c).units_info
    isnothing(settings) && return val
    multiplier = _get_multiplier(
        c,
        field,
        Val(settings.unit_system),
        settings.base_value,
        conversion_unit,
    )
    return val / multiplier
end
