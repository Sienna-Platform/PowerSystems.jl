#=
JSON serialization/deserialization for unit-bearing quantities.

Format:
  {"value": 0.6, "unit": "CUp"}
  {"value": 30.0, "unit": "MW"}
  {"value": 529.0, "unit": "Ω"}

For complex values:
  {"value": {"re": 0.01, "im": 0.1}, "unit": "SUz"}
=#

import JSON

# ============================================================
# Unit string ↔ type mapping
# ============================================================

# All known unit strings → Unitful units.
# Canonical names come from unit_to_string; aliases provide lenient parsing.
const STRING_TO_UNIT = Dict{String, Any}(
    # Per-unit units; `u"..."` can't reach PSY's own during its precompile.
    "CUp" => CUp,
    "SUp" => SUp,
    "CUv" => CUv,
    "CUz" => CUz,
    "CUy" => CUy,
    "CUi" => CUi,
    "SUz" => SUz,
    "SUy" => SUy,
    "SUi" => SUi,
    "CUp minute^-1" => CUp / u"minute",
    "SUp minute^-1" => SUp / u"minute",
    "CUp hr^-1" => CUp / u"hr",
    "SUp hr^-1" => SUp / u"hr",
    # Canonical Unitful (matches output of `string(unit)`)
    "MW" => u"MW",
    # PSY's own `@unit` definitions; `u"MVA"`/`u"MVAr"` resolve downstream but not
    # here, since `Unitful.register(PowerSystems)` runs after this file precompiles.
    "MVAr" => MVAr,
    "MVA" => MVA,
    "kV" => u"kV",
    "Ω" => u"Ω",
    "S" => u"S",
    "kA" => u"kA",
    # Compound (rate) units. The canonical spelling is the ASCII exponent form emitted
    # by `unit_to_string`; the Unicode and slashed forms are lenient aliases. The
    # Unicode one is not hypothetical: it is what Unitful prints by default on macOS.
    "MW minute^-1" => u"MW" / u"minute",
    "MW minute⁻¹" => u"MW" / u"minute",
    "MW/minute" => u"MW" / u"minute",
    "MW/min" => u"MW" / u"minute",
    # Aliases
    "ohm" => u"Ω",
    "siemens" => u"S",
)

"""
    unit_to_string(unit) → String

Convert a unit type to its string representation for serialization.
"""
# `string(u)` is *not* stable across platforms: Unitful renders exponents with Unicode
# superscripts or ASCII carets depending on `ENV["UNITFUL_FANCY_EXPONENTS"]`, which
# defaults to true on macOS and false everywhere else. A serialized system has to read
# back on the machine that did not write it, so pin the spelling instead of inheriting
# the platform's. Units without an exponent are unaffected either way.
unit_to_string(u::Unitful.Units) =
    sprint(show, u; context = :fancy_exponent => false)

"""
    string_to_unit(s::String) → unit

Parse a unit string back to its type for deserialization.
Returns a `Unitful.Units`.
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
    deserialize_quantity(d::Dict) → Unitful.Quantity

Deserialize from a Dict (parsed JSON).
Note: inherently type-unstable (return type depends on the "unit" string).
This is expected for deserialization, which is not a hot path.
"""
function deserialize_quantity(d::AbstractDict)
    value = _parse_value(d["value"])
    unit = string_to_unit(d["unit"])
    return value * unit
end

"""
    deserialize_quantity(s::AbstractString) → Unitful.Quantity

Deserialize from a JSON string.
"""
deserialize_quantity(s::AbstractString) =
    deserialize_quantity(JSON.parse(s; dicttype = Dict{String, Any}))

# Parse a JSON value into a numeric type
_parse_value(v::AbstractDict) = Complex(v["re"], v["im"])
_parse_value(v) = Float64(v)
