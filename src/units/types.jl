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

# Currency is its own base dimension, so unlike `MVAr`/`MVA` there is no existing unit
# to scale from. USD is functionally "a fixed currency," could change to generic "dollars."
@dimension 𝐂 "𝐂" Currency
@refunit USD "USD" USD 𝐂 false

###############################
# Relative units per unit time
#
# A rate field (e.g. `ramp_limits`, MW/min) per-unitizes only its power axis --
# there is no time base -- so a relative marker alone does not say what the value
# is a rate *of* per unit time. `SU/u"minute"` says it; bare `SU` is rejected.
###############################

"""
Target-unit argument for a rate field: a relative per-unit base per unit time,
written `CU/u"minute"` or `SU/u"hr"`.

Deliberately **not** `<: AbstractRelativeUnit`: `IS`'s
`Base.:*(::Number, ::AbstractRelativeUnit)` would otherwise consume it and produce a
plain `RelativeQuantity`, silently dropping the time.
"""
struct RateUnit{U <: IS.AbstractRelativeUnit, TU <: Unitful.Units} end

Base.:/(::U, ::TU) where {U <: IS.AbstractRelativeUnit, TU <: Unitful.Units} =
    RateUnit{U, TU}()

# Print as it is written, not as its raw type parameters.
Base.show(io::IO, r::RateUnit) = print(io, relative_unit(r), "/", time_basis(r))

"The relative base of a rate unit (`CU`/`SU`)."
relative_unit(::RateUnit{U}) where {U} = U()

"""
    time_basis(x) → Unitful.Units

The time unit a per-time quantity is denominated in -- always a time (`u"minute"`,
`u"hr"`), never its reciprocal. Asked of the three things that can answer: a rate
unit marker, a tagged rate value, and a rate category (whose answer is the basis its
stored number is in). `_time_factor` converts between any two of them.
"""
function time_basis end

time_basis(::RateUnit{<:Any, TU}) where {TU} = TU()

"""
A value tagged with a relative base per unit time, e.g. `0.1 * CU / u"hr"`.

`RelativeQuantity <: Number`, so Unitful's own `Quantity` wraps it and does the time
arithmetic: this is an ordinary `Unitful.Quantity` whose numeric payload carries the
per-unit marker, not a bespoke type.
"""
const RelativeRate{T, U, D, TU} = Unitful.Quantity{IS.RelativeQuantity{T, U}, D, TU}

# A per-time quantity's Unitful parameter is the *inverse* time unit (`minute^-1`), so
# the basis is its reciprocal.
time_basis(::RelativeRate{T, U, D, TU}) where {T, U, D, TU} = inv(TU())

# `0.1 * (CU/u"hr")` and `0.1 * CU / u"hr"` must produce the identical value.
Base.:*(v::Real, r::RateUnit) = (v * relative_unit(r)) / time_basis(r)
Base.:*(r::RateUnit, v::Real) = v * r

# The reverse nesting is reachable -- `IS`'s `*(::Number, ::AbstractRelativeUnit)` takes
# a `Number`, and a `Unitful.Quantity` is one -- and yields
# `RelativeQuantity{Quantity}`, which prints as `0.1 hr^-1 CU` and dispatches nowhere
# useful. Reject it and name the spelling that works.
_rate_nesting_error(q, u) = throw(
    ArgumentError(
        "cannot tag the unit-bearing value $q with the per-unit marker $u; a rate is " *
        "written base-first, e.g. `0.1 * $u / u\"minute\"`",
    ),
)
Base.:*(q::Unitful.Quantity, u::IS.AbstractRelativeUnit) = _rate_nesting_error(q, u)
Base.:*(u::IS.AbstractRelativeUnit, q::Unitful.Quantity) = _rate_nesting_error(q, u)

"""
Accepted target-unit argument for unit-aware getters/setters: a Unitful unit
(e.g. `u"MW"`, `u"kV"`, `u"MW/minute"`), a relative per-unit marker (`CU`, `SU`, `NU`),
or a relative marker per unit time (`CU/u"minute"`).
"""
const UnitArg = Union{Unitful.Units, IS.AbstractUnitSystem, RateUnit}

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

# A `RelativeRate` strips in two steps: Unitful's `ustrip` drops the time unit and
# hands back the `RelativeQuantity` payload, which still needs its own marker removed.
IS._strip_units(q::RelativeRate) = IS._strip_units(Unitful.ustrip(q))
