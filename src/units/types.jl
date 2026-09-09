###############################
# Power-domain unit types.
#
# Relative-unit markers (`DU`, `SU`, `NU`, `AbstractRelativeUnit`,
# `RelativeQuantity`) live in InfrastructureSystems and are re-exported from
# this package. This file adds the power-domain Unitful units and the
# `UnitArg` convenience union.
###############################

# Power-system-specific natural units (same dimension as MW, different display)
@unit MVAr "MVAr" MVAr 1u"MW" false
@unit MVA "MVA" MVA 1u"MW" false

# Re-export common Unitful units for power systems
const MW = u"MW"
const kV = u"kV"
const OHMS = u"Ω"
const SIEMENS = u"S"

"""
Accepted target-unit argument for unit-aware getters/setters: a Unitful unit
(e.g. `MW`, `kV`) or a relative per-unit marker (`DU`, `SU`, `NU`).
"""
const UnitArg = Union{Unitful.Units, IS.AbstractUnitSystem}

"""
A number carrying no units: what a unit-aware setter must reject. Both quantity
wrappers are `Number`s but neither is a `Real` (nor a `Complex`), so this alias
selects exactly the untagged values. Convertible fields are `Float64` or
`Complex{Float64}`, so both are covered.
"""
const _UntaggedNumber = Union{Real, Complex{<:Real}}

# One public strip generic for both quantity kinds: Unitful's `ustrip` works on
# `RelativeQuantity` too (IS deliberately does not define its own `ustrip`).
Unitful.ustrip(q::IS.RelativeQuantity) = IS._strip_units(q)
