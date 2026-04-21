###############################
# Power-domain unit types.
#
# Relative-unit markers (`DU`, `SU`, `NU`, `AbstractRelativeUnit`,
# `RelativeQuantity`) live in InfrastructureSystems and are re-exported from
# this package. This file adds the power-domain Unitful units and the
# `UnitArg` convenience union.
###############################

# Power-system-specific natural units (same dimension as MW, different display)
@unit Mvar "Mvar" Mvar 1u"MW" false
@unit MVA "MVA" MVA 1u"MW" false

# Re-export common Unitful units for power systems
const MW = u"MW"
const kV = u"kV"
const OHMS = u"Ω"
const SIEMENS = u"S"

"""
Accepted target-unit argument for unit-aware getters/setters: a Unitful unit
(e.g. `MW`, `kV`), a relative per-unit marker (`DU`, `SU`, `NU`), or `Float64`
(fast path returning a bare `Float64` in system base).
"""
const UnitArg = Union{Unitful.Units, IS.AbstractRelativeUnit, Type{Float64}}
