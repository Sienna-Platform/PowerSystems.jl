###############################
# Power-domain unit types.
#
# Per-unit values carry InfrastructureSystems' generic `u"CU"` and `u"SU"`; `u"NU"` resolves
# to each field's natural unit (see `conversions.jl`). The `CU`/`SU`/`NU` *markers* also come
# from IS and survive only as type parameters, e.g. the `U` in `CostCurve{T, U}`.
#
# Natural units are spelled with Unitful's `u"..."` string macro only — there
# are no `MW`/`kV`/`OHMS`/`SIEMENS` constants to export.
###############################

# Power-system-specific natural units (same dimension as MW, different display).
# `Unitful.register(PowerSystems)` in `__init__` makes these reachable from `u"..."`
# downstream. Registration happens at load time, so PSY's
# own source uses the bare constants.
@unit MVAr "MVAr" MVAr 1u"MW" false
@unit MVA "MVA" MVA 1u"MW" false

"""
Accepted target-unit argument for unit-aware getters: a Unitful unit, either natural
(`u"MW"`, `u"MW/minute"`) or built from the generic `u"CU"`, `u"SU"`, `u"NU"`
(`u"CU"`, `u"SU/hr"`).
"""
const UnitArg = Unitful.Units

"""
A number carrying no units: what a unit-aware setter must reject. A `Unitful.Quantity`
is a `Number` but neither a `Real` nor a `Complex`, so this alias selects exactly the
untagged values. Convertible fields are `Float64` or `Complex{Float64}`, so both are covered.
"""
const _UntaggedNumber = Union{Real, Complex{<:Real}}
