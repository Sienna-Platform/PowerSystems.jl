###############################
# Power-domain unit types.
#
# Relative-unit markers (`CU`, `SU`, `NU`, `AbstractRelativeUnit`,
# `RelativeQuantity`) live in InfrastructureSystems and are re-exported from
# this package. This file adds the power-domain Unitful units and the
# `UnitArg` convenience union.
#
# Natural units are spelled with Unitful's `u"..."` string macro only — there
# are no `MW`/`kV`/`OHMS`/`SIEMENS` constants to export. One notation, and it is
# Unitful's own, so `u"kW"`, `u"mΩ"` and every other Unitful spelling work the
# same way the handful of aliases used to.
###############################

# Power-system-specific natural units (same dimension as MW, different display).
# `Unitful.register(PowerSystems)` in `__init__` makes these reachable from the
# `u"..."` string macro downstream (`u"MVA"`, `u"MVAr"`). Registration happens at
# load time, though, so PSY's own source cannot spell them that way during its
# precompile — internal call sites use the bare constants these define.
@unit MVAr "MVAr" MVAr 1u"MW" false
@unit MVA "MVA" MVA 1u"MW" false

"""
Accepted target-unit argument for unit-aware getters/setters: a Unitful unit
(e.g. `u"MW"`, `u"kV"`) or a relative per-unit marker (`CU`, `SU`, `NU`).
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
