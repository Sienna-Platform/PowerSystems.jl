###############################
# Power-domain unit types.
#
# Callers write the generic `u"CU"`, `u"SU"` and `u"NU"` from InfrastructureSystems'
# `PerUnit`; each field resolves them to the units below (see `conversions.jl`). The
# `CU`/`SU`/`NU` *markers* also come from IS and survive only as type parameters, e.g.
# the `U` in `CostCurve{T, U}`.
#
# Natural units are spelled with Unitful's `u"..."` string macro only — there
# are no `MW`/`kV`/`OHMS`/`SIEMENS` constants to export.
###############################

# Power-system-specific natural units (same dimension as MW, different display).
# `Unitful.register(PowerSystems)` in `__init__` makes these, and the per-unit units
# below, reachable from `u"..."` downstream. Registration happens at load time, so PSY's
# own source uses the bare constants.
@unit MVAr "MVAr" MVAr 1u"MW" false
@unit MVA "MVA" MVA 1u"MW" false

###############################
# Per-unit bases as dimensions
#
# One dimension per per-unitized base, so a per-unit value's dimension says what it is
# per-unit of: per-unit impedance (`CUv²/CUp`) and per-unit power (`CUp`) do not add.
# There is no system voltage base -- voltage is always referenced to a component -- so SU
# quantities use the component's `CUv`. Dimensions tell kinds of base apart, not instances:
# `CUp` values of two components with different `base_power` still add.
###############################

@dimension 𝐂𝐩 "𝐂𝐩" ComponentBasePower
@dimension 𝐒𝐩 "𝐒𝐩" SystemBasePower
@dimension 𝐂𝐯 "𝐂𝐯" ComponentBaseVoltage
@refunit CUp "CUp" CUp 𝐂𝐩 false
@refunit SUp "SUp" SUp 𝐒𝐩 false
@refunit CUv "CUv" CUv 𝐂𝐯 false

# Named aliases so compound per-unit values print as one unit (`0.01 CUz`, not
# `0.01 CUv² CUp⁻¹`). Same dimensions, so they add no checking of their own.
@unit CUz "CUz" CUz 1CUv^2 / CUp false
@unit CUy "CUy" CUy 1CUp / CUv^2 false
@unit CUi "CUi" CUi 1CUp / CUv false
@unit SUz "SUz" SUz 1CUv^2 / SUp false
@unit SUy "SUy" SUy 1SUp / CUv^2 false
@unit SUi "SUi" SUi 1SUp / CUv false

# Promotions recorded during precompilation don't persist; restored in `__init__`.
const _LOCAL_UNIT_PROMOTION = copy(Unitful.promotion)

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
