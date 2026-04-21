#=
JSON serialization/deserialization for unit-bearing quantities.

Format:
  {"value": 0.6, "unit": "DU"}
  {"value": 30.0, "unit": "MW"}
  {"value": 529.0, "unit": "Ω"}

For complex values:
  {"value": {"re": 0.01, "im": 0.1}, "unit": "SU"}
=#

import JSON3
import StructTypes

# ============================================================
# Unit string ↔ type mapping
# ============================================================

# All known unit strings → unit objects (both relative and Unitful).
# Canonical names come from unit_to_string; aliases provide lenient parsing.
const STRING_TO_UNIT = Dict{String, Any}(
    # Relative units
    "DU" => DU,
    "SU" => SU,
    # Canonical Unitful (matches output of `string(unit)`)
    "MW" => MW,
    "Mvar" => Mvar,
    "MVA" => MVA,
    "kV" => kV,
    "Ω" => OHMS,
    "S" => SIEMENS,
    "kA" => u"kA",
    # Aliases
    "ohm" => OHMS,
    "siemens" => SIEMENS,
)

"""
    unit_to_string(unit) → String

Convert a unit type to its string representation for serialization.
"""
unit_to_string(::DeviceBaseUnit) = "DU"
unit_to_string(::SystemBaseUnit) = "SU"
unit_to_string(u::Unitful.Units) = string(u)

"""
    string_to_unit(s::String) → unit

Parse a unit string back to its type for deserialization.
Returns a `DeviceBaseUnit`, `SystemBaseUnit`, or `Unitful.Units`.
"""
function string_to_unit(s::String)
    unit = get(STRING_TO_UNIT, s, nothing)
    isnothing(unit) && error("Unknown unit string: \"$s\"")
    return unit
end

# ============================================================
# Serialization
# ============================================================

"""
    serialize_quantity(q::RelativeQuantity) → Dict

Serialize a RelativeQuantity to a Dict suitable for JSON.
"""
function serialize_quantity(q::RelativeQuantity{T, U}) where {T <: Real, U}
    return Dict("value" => q.value, "unit" => unit_to_string(q.unit))
end

function serialize_quantity(q::RelativeQuantity{T, U}) where {T <: Complex, U}
    return Dict(
        "value" => Dict("re" => real(q.value), "im" => imag(q.value)),
        "unit" => unit_to_string(q.unit),
    )
end

"""
    serialize_quantity(q::Unitful.Quantity) → Dict

Serialize a Unitful Quantity to a Dict suitable for JSON.
"""
function serialize_quantity(q::Unitful.Quantity{T}) where {T <: Real}
    return Dict("value" => Unitful.ustrip(q), "unit" => unit_to_string(Unitful.unit(q)))
end

function serialize_quantity(q::Unitful.Quantity{T}) where {T <: Complex}
    v = Unitful.ustrip(q)
    return Dict(
        "value" => Dict("re" => real(v), "im" => imag(v)),
        "unit" => unit_to_string(Unitful.unit(q)),
    )
end

# ============================================================
# Deserialization
# ============================================================

"""
    deserialize_quantity(d::Dict) → RelativeQuantity or Unitful.Quantity

Deserialize from a Dict (parsed JSON).
Note: inherently type-unstable (return type depends on the "unit" string).
This is expected for deserialization, which is not a hot path.
"""
function deserialize_quantity(d::AbstractDict)
    value = _parse_value(d["value"])
    unit = string_to_unit(d["unit"])
    return _attach_unit(value, unit)
end

"""
    deserialize_quantity(s::AbstractString) → RelativeQuantity or Unitful.Quantity

Deserialize from a JSON string.
"""
deserialize_quantity(s::AbstractString) = deserialize_quantity(JSON3.read(s, Dict))

# Parse a JSON value into a numeric type
_parse_value(v::AbstractDict) = Complex(v["re"], v["im"])
_parse_value(v) = Float64(v)

# Attach unit to value via dispatch
_attach_unit(value, unit::AbstractRelativeUnit) = RelativeQuantity(value, unit)
_attach_unit(value, unit::Unitful.Units) = value * unit
