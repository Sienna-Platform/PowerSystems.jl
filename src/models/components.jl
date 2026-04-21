@inline function _get_system_base_power(c::Component)
    units_info = get_internal(c).units_info
    isnothing(units_info) && error("Component $(get_name(c)) is not attached to a system.")
    # Assert concrete type; units_info field is typed as abstract UnitsData.
    return (units_info::IS.SystemUnitsSettings).base_value
end

"""
Unitless device-base power (MVA). Fallback for components with no `base_power`
field: the device base equals the system base.
"""
_get_base_power(c::Component) = _get_system_base_power(c)

"""
Unit-aware `base_power` accessor. Unlike most field accessors, storage is in
MVA (natural units), not device-base per-unit — so conversion is bespoke.
"""
get_base_power(c::Component, ::NaturalUnit) = _get_base_power(c) * MVA
get_base_power(c::Component, u::Unitful.Units) =
    Unitful.uconvert(u, _get_base_power(c) * MVA)
get_base_power(c::Component, ::SystemBaseUnit) =
    (_get_base_power(c) / _get_system_base_power(c)) * SU
get_base_power(c::Component, ::DeviceBaseUnit) = 1.0 * DU
get_base_power(c::Component, ::Type{Float64})::Float64 =
    _get_base_power(c) / _get_system_base_power(c)

IS.display_units_arg(::typeof(get_base_power), ::Type{<:Component}) = NU

#######################################################
# Units-aware get_value / set_value
#
# Fields are stored internally in device base (DU). The 4-arg `get_value`
# converts from DU to a requested target (e.g., MW, SU, Float64). The 3-arg
# form delegates to the 4-arg with DEFAULT_UNITS (= SU, a RelativeQuantity
# carrying its unit in its type).
#######################################################

"""
    get_value(c::Component, field::Val, conversion_unit::Val, units) -> value

Get `c`'s field value, converting from device-base storage to `units`.
Returns a `RelativeQuantity` (for DU/SU targets), a `Unitful.Quantity` (for
natural units like MW), or a bare `Float64` (when `units === Float64`).
"""
function get_value(c::Component, ::Val{T}, conversion_unit, units) where {T}
    value = Base.getproperty(c, T)
    return _convert_from_device_base(c, value, conversion_unit, units)
end

# ---- DU → natural power units ----
_convert_from_device_base(c::Component, value::Float64, ::Val{:mva}, ::typeof(MW)) =
    value * _get_base_power(c) * u"MW"

_convert_from_device_base(c::Component, value::Float64, ::Val{:mva}, ::typeof(Mvar)) =
    value * _get_base_power(c) * Mvar

function _convert_from_device_base(
    c::T, value::Number, ::Val{:ohm}, ::typeof(OHMS),
) where {T <: Branch}
    base_voltage = get_base_voltage(get_arc(c).from)
    isnothing(base_voltage) && error("Base voltage is not defined for $(summary(c)).")
    return value * (base_voltage^2 / _get_base_power(c)) * u"Ω"
end

function _convert_from_device_base(
    c::T, value::Number, ::Val{:ohm}, ::typeof(OHMS),
) where {T <: TwoWindingTransformer}
    base_voltage = get_base_voltage_primary(c)
    isnothing(base_voltage) && error("Base voltage is not defined for $(summary(c)).")
    return value * (base_voltage^2 / _get_base_power(c)) * u"Ω"
end

function _convert_from_device_base(
    c::T, value::Number, ::Val{:siemens}, ::typeof(SIEMENS),
) where {T <: Branch}
    base_voltage = get_base_voltage(get_arc(c).from)
    if isnothing(base_voltage)
        @warn "Base voltage is not set for $(c.name). Returning in device base units."
        return value * DU
    end
    return value * (_get_base_power(c) / base_voltage^2) * u"S"
end

function _convert_from_device_base(
    c::T, value::Number, ::Val{:siemens}, ::typeof(SIEMENS),
) where {T <: TwoWindingTransformer}
    base_voltage = get_base_voltage_primary(c)
    if isnothing(base_voltage)
        @warn "Base voltage is not set for $(c.name). Returning in device base units."
        return value * DU
    end
    return value * (_get_base_power(c) / base_voltage^2) * u"S"
end

# ---- DU → DU (identity; no system info needed) ----
_convert_from_device_base(::Component, value::Number, ::Val, ::DeviceBaseUnit) =
    value * DU

# ---- DU → SU (RelativeQuantity{Float64, SystemBaseUnit}) ----
function _convert_from_device_base(
    c::Component, value::Float64, ::Val{:mva}, ::SystemBaseUnit,
)
    return (value * (_get_base_power(c) / _get_system_base_power(c))) * SU
end

function _convert_from_device_base(
    c::T, value::Number, ::Val{:ohm}, ::SystemBaseUnit,
) where {T <: Branch}
    return (value * (_get_system_base_power(c) / _get_base_power(c))) * SU
end

function _convert_from_device_base(
    c::T, value::Number, ::Val{:siemens}, ::SystemBaseUnit,
) where {T <: Branch}
    return (value * (_get_base_power(c) / _get_system_base_power(c))) * SU
end

# ---- DU → Float64 (fast path: raw SU-scaled number, no unit wrapper) ----
# Use when callers know they want system-base and will form Vector{Float64}.
function _convert_from_device_base(
    c::Component, value::Float64, ::Val{:mva}, ::Type{Float64},
)::Float64
    return value * (_get_base_power(c) / _get_system_base_power(c))
end

function _convert_from_device_base(
    c::T, value::Float64, ::Val{:ohm}, ::Type{Float64},
)::Float64 where {T <: Branch}
    return value * (_get_system_base_power(c) / _get_base_power(c))
end

function _convert_from_device_base(
    c::T, value::Float64, ::Val{:siemens}, ::Type{Float64},
)::Float64 where {T <: Branch}
    return value * (_get_base_power(c) / _get_system_base_power(c))
end

# ---- Generic fallback: any Unitful target for :mva ----
function _convert_from_device_base(
    c::Component, value::Float64, ::Val{:mva}, units::Unitful.Units,
)
    return Unitful.uconvert(units, value * _get_base_power(c) * u"MW")
end

# ---- Nothing passthrough ----
_convert_from_device_base(::Component, ::Nothing, ::Val, ::Any) = nothing

# ---- Compound field types ----
_convert_from_device_base(c::Component, v::MinMax, cu, u) = (
    min = _convert_from_device_base(c, v.min, cu, u),
    max = _convert_from_device_base(c, v.max, cu, u),
)

_convert_from_device_base(c::Component, v::UpDown, cu, u) = (
    up = _convert_from_device_base(c, v.up, cu, u),
    down = _convert_from_device_base(c, v.down, cu, u),
)

_convert_from_device_base(c::Component, v::FromTo_ToFrom, cu, u) = (
    from_to = _convert_from_device_base(c, v.from_to, cu, u),
    to_from = _convert_from_device_base(c, v.to_from, cu, u),
)

_convert_from_device_base(c::Component, v::FromTo, cu, u) = (
    from = _convert_from_device_base(c, v.from, cu, u),
    to = _convert_from_device_base(c, v.to, cu, u),
)

_convert_from_device_base(c::Component, v::StartUpShutDown, cu, u) = (
    startup = _convert_from_device_base(c, v.startup, cu, u),
    shutdown = _convert_from_device_base(c, v.shutdown, cu, u),
)

#######################################################
# set_value: accept Unitful.Quantity or RelativeQuantity; return DU scalar
#######################################################

# ---- From Unitful.Quantity (natural units) ----
function set_value(c::Component, field, val::Quantity, ::Val{:mva})
    return Unitful.ustrip(u"MW", val) / _get_base_power(c)
end

function set_value(
    c::T, field, val::Quantity, ::Val{:ohm},
) where {T <: Branch}
    base_voltage = get_base_voltage(get_arc(c).from)
    isnothing(base_voltage) && error("Base voltage is not defined for $(summary(c)).")
    return Unitful.ustrip(u"Ω", val) / (base_voltage^2 / _get_base_power(c))
end

function set_value(
    c::T, field, val::Quantity, ::Val{:siemens},
) where {T <: Branch}
    base_voltage = get_base_voltage(get_arc(c).from)
    isnothing(base_voltage) && error("Base voltage is not defined for $(summary(c)).")
    return Unitful.ustrip(u"S", val) / (_get_base_power(c) / base_voltage^2)
end

# ---- From RelativeQuantity in DU (trivial) ----
set_value(::Component, field, val::RelativeQuantity{<:Any, DeviceBaseUnit}, ::Val) =
    ustrip(val)

# ---- From RelativeQuantity in SU ----
function set_value(
    c::Component, field, val::RelativeQuantity{<:Any, SystemBaseUnit}, ::Val{:mva},
)
    return ustrip(val) / (_get_base_power(c) / _get_system_base_power(c))
end

function set_value(
    c::T, field, val::RelativeQuantity{<:Any, SystemBaseUnit}, ::Val{:ohm},
) where {T <: Branch}
    return ustrip(val) / (_get_system_base_power(c) / _get_base_power(c))
end

function set_value(
    c::T, field, val::RelativeQuantity{<:Any, SystemBaseUnit}, ::Val{:siemens},
) where {T <: Branch}
    return ustrip(val) / (_get_base_power(c) / _get_system_base_power(c))
end

# ---- Bare Float64 is rejected: callers must attach units explicitly ----
set_value(::Component, ::Any, ::Float64, ::Val) = throw(
    ArgumentError(
        "setter requires explicit units (e.g. `val * SU`, `val * DU`, `val * MW`)",
    ),
)

# ---- Compound field types for setters ----
_to_device_base(c::Component, val, cu) = set_value(c, nothing, val, cu)

set_value(c::Component, field, val::NamedTuple{(:min, :max)}, cu::Val) = (
    min = _to_device_base(c, val.min, cu),
    max = _to_device_base(c, val.max, cu),
)

set_value(c::Component, field, val::NamedTuple{(:up, :down)}, cu::Val) = (
    up = _to_device_base(c, val.up, cu),
    down = _to_device_base(c, val.down, cu),
)

set_value(c::Component, field, val::NamedTuple{(:from_to, :to_from)}, cu::Val) = (
    from_to = _to_device_base(c, val.from_to, cu),
    to_from = _to_device_base(c, val.to_from, cu),
)

set_value(c::Component, field, val::NamedTuple{(:from, :to)}, cu::Val) = (
    from = _to_device_base(c, val.from, cu),
    to = _to_device_base(c, val.to, cu),
)

set_value(c::Component, field, val::NamedTuple{(:startup, :shutdown)}, cu::Val) = (
    startup = _to_device_base(c, val.startup, cu),
    shutdown = _to_device_base(c, val.shutdown, cu),
)

# ---- Nothing passthrough ----
set_value(::Component, _, ::Nothing, ::Val) = nothing

######################################
########### Transformer 3W ###########
######################################

PrimaryImpedances = Union{
    Val{:r_primary},
    Val{:x_primary},
    Val{:r_12},
    Val{:x_12},
}

PrimaryAdmittances = Union{
    Val{:g},
    Val{:b},
}

PrimaryPower = Union{
    Val{:active_power_flow_primary},
    Val{:reactive_power_flow_primary},
    Val{:rating},
    Val{:rating_primary},
}

SecondaryImpedances = Union{
    Val{:r_secondary},
    Val{:x_secondary},
    Val{:r_23},
    Val{:x_23},
}

SecondaryPower = Union{
    Val{:active_power_flow_secondary},
    Val{:reactive_power_flow_secondary},
    Val{:rating_secondary},
}

TertiaryImpedances = Union{
    Val{:r_tertiary},
    Val{:x_tertiary},
    Val{:r_13},
    Val{:x_13},
}

TertiaryPower = Union{
    Val{:active_power_flow_tertiary},
    Val{:reactive_power_flow_tertiary},
    Val{:rating_tertiary},
}

###### Multipliers ######

_get_winding_base_power(
    c::ThreeWindingTransformer,
    ::Union{PrimaryImpedances, PrimaryAdmittances, PrimaryPower},
) = _get_base_power_12(c)
_get_winding_base_power(
    c::ThreeWindingTransformer,
    ::Union{SecondaryImpedances, SecondaryPower},
) =
    _get_base_power_23(c)
_get_winding_base_power(
    c::ThreeWindingTransformer,
    ::Union{TertiaryImpedances, TertiaryPower},
) =
    _get_base_power_13(c)

# Public unit-aware winding base_power accessors for ThreeWindingTransformer.
for (pub, priv) in (
    (:get_base_power_12, :_get_base_power_12),
    (:get_base_power_23, :_get_base_power_23),
    (:get_base_power_13, :_get_base_power_13),
)
    @eval begin
        $pub(c::ThreeWindingTransformer, ::NaturalUnit) = $priv(c) * MVA
        $pub(c::ThreeWindingTransformer, u::Unitful.Units) =
            Unitful.uconvert(u, $priv(c) * MVA)
        $pub(c::ThreeWindingTransformer, ::SystemBaseUnit) =
            ($priv(c) / _get_system_base_power(c)) * SU
        $pub(c::ThreeWindingTransformer, ::DeviceBaseUnit) = 1.0 * DU
        $pub(c::ThreeWindingTransformer, ::Type{Float64})::Float64 =
            $priv(c) / _get_system_base_power(c)
        IS.display_units_arg(::typeof($pub), ::Type{<:ThreeWindingTransformer}) = NU
    end
end

function _get_winding_base_voltage(
    c::ThreeWindingTransformer,
    ::Union{PrimaryImpedances, PrimaryAdmittances},
)
    base_voltage = get_base_voltage_primary(c)
    if isnothing(base_voltage)
        error("Base voltage is not defined for $(summary(c)).")
    end
    return base_voltage
end

function _get_winding_base_voltage(
    c::ThreeWindingTransformer,
    ::SecondaryImpedances,
)
    base_voltage = get_base_voltage_secondary(c)
    if isnothing(base_voltage)
        error("Base voltage is not defined for $(summary(c)).")
    end
    return base_voltage
end

function _get_winding_base_voltage(
    c::ThreeWindingTransformer,
    ::TertiaryImpedances,
)
    base_voltage = get_base_voltage_tertiary(c)
    if isnothing(base_voltage)
        error("Base voltage is not defined for $(summary(c)).")
    end
    return base_voltage
end

# DEVICE_BASE
function _get_multiplier(
    ::ThreeWindingTransformer,
    ::Any,
    ::Val{IS.UnitSystem.DEVICE_BASE},
    ::Float64,
    ::Any,
)
    return 1.0
end

###########
## Power ##
###########

# SYSTEM_BASE
function _get_multiplier(
    c::ThreeWindingTransformer,
    field::Any,
    ::Val{IS.UnitSystem.SYSTEM_BASE},
    base_mva::Float64,
    ::Val{:mva},
)
    return _get_winding_base_power(c, field) / base_mva
end

# NATURAL_UNITS
function _get_multiplier(
    c::ThreeWindingTransformer,
    field::Any,
    ::Val{IS.UnitSystem.NATURAL_UNITS},
    base_mva::Float64,
    ::Val{:mva},
)
    return _get_winding_base_power(c, field)
end

############
### Ohms ###
############

# SYSTEM_BASE
function _get_multiplier(
    c::ThreeWindingTransformer,
    field::Any,
    ::Val{IS.UnitSystem.SYSTEM_BASE},
    base_mva::Float64,
    ::Val{:ohm},
)
    return base_mva / _get_winding_base_power(c, field)
end

# NATURAL_UNITS
function _get_multiplier(
    c::ThreeWindingTransformer,
    field::Any,
    ::Val{IS.UnitSystem.NATURAL_UNITS},
    base_mva::Float64,
    ::Val{:ohm},
)
    return _get_winding_base_voltage(c, field)^2 / _get_winding_base_power(c, field)
end

#############
## Siemens ##
#############

# SYSTEM_BASE
function _get_multiplier(
    c::ThreeWindingTransformer,
    field::Any,
    ::Val{IS.UnitSystem.SYSTEM_BASE},
    base_mva::Float64,
    ::Val{:siemens},
)
    return _get_winding_base_power(c, field) / base_mva
end

# NATURAL_UNITS
function _get_multiplier(
    c::ThreeWindingTransformer,
    field::Any,
    ::Val{IS.UnitSystem.NATURAL_UNITS},
    base_mva::Float64,
    ::Val{:siemens},
)
    return _get_winding_base_power(c, field) / _get_winding_base_voltage(c, field)^2
end

function _t3w_get_value(
    c::ThreeWindingTransformer,
    field::Val{T},
    conversion_unit,
) where {T}
    value = Base.getproperty(c, T)
    if isnothing(value)
        return nothing
    end
    settings = get_internal(c).units_info
    if isnothing(settings)
        return value
    end
    unit_system = settings.unit_system
    base_mva = settings.base_value
    multiplier = _get_multiplier(c, field, Val(unit_system), base_mva, conversion_unit)
    return value * multiplier
end

get_value(c::ThreeWindingTransformer, field::Val{T}, conversion_unit::Val) where {T} =
    _t3w_get_value(c, field, conversion_unit)

function _t3w_set_value(
    c::ThreeWindingTransformer,
    field,
    val::Float64,
    conversion_unit,
)
    settings = get_internal(c).units_info
    if isnothing(settings)
        return val
    end
    unit_system = settings.unit_system
    base_mva = settings.base_value
    multiplier = _get_multiplier(c, field, Val(unit_system), base_mva, conversion_unit)
    return val / multiplier
end

set_value(c::ThreeWindingTransformer, field, val::Float64, cu::Val{:mva}) =
    _t3w_set_value(c, field, val, cu)
set_value(c::ThreeWindingTransformer, field, val::Float64, cu::Val{:ohm}) =
    _t3w_set_value(c, field, val, cu)
set_value(c::ThreeWindingTransformer, field, val::Float64, cu::Val{:siemens}) =
    _t3w_set_value(c, field, val, cu)
