# [Per-unit Conventions](@id per_unit)

It is often useful to express power systems data in relative terms using per-unit conventions.
`PowerSystems.jl` supports conversion of data between three different unit systems:

 1. `u"NU"` (natural units): The naturally defined units of each parameter (see
    [Natural units by quantity](@ref natural_units_by_quantity) below).
 2. `u"SU"` (system base): Parameter values are divided by the system `base_power`.
 3. `u"CU"` (component base): Parameter values are divided by the device `base_power`.

`PowerSystems.jl` supports these unit systems because different power system tools and data
sets use different units systems by convention, such as:

  - Dynamics data is often defined in component base
  - Network data (e.g., reactance, resistance) is often defined in system base
  - Production cost modeling data is often gathered from variety of data sources,
    which are typically defined in natural units

## [Natural units by quantity](@id natural_units_by_quantity)

`u"NU"` resolves to the unit that fits the physical quantity the field holds, so active,
reactive, and apparent power read back distinctly even though all three share one
per-unit base:

| Quantity       | Natural unit | Example fields                                    |
|:-------------- |:------------ |:------------------------------------------------- |
| Active power   | `u"MW"`      | `active_power`, `active_power_limits`, `max_flow` |
| Reactive power | `u"MVAr"`    | `reactive_power`, `reactive_power_limits`         |
| Apparent power | `u"MVA"`     | `rating`, `rating_b`, `base_power`                |
| Impedance      | `u"Ω"`       | `r`, `x`                                          |
| Admittance     | `u"S"`       | `b`, `g`                                          |
| Voltage        | `u"kV"`      | `base_voltage`                                    |

Natural units are written with Unitful's `u"..."` string macro, which `PowerSystems`
re-exports — `using PowerSystems` is enough, no `using Unitful` needed. There are no
`MW`/`kV` constants: one notation, and it is Unitful's own, so every Unitful spelling
(`u"kW"`, `u"mΩ"`, `u"GW"`) works wherever a unit of the right dimension is expected.
`u"MVA"` and `u"MVAr"` are defined by PowerSystems itself and resolve the same way.

```julia
get_active_power(gen, u"NU")            # 125.0 (MW)
get_reactive_power_unitful(gen, u"NU")  # 25.0 MVAr
get_rating_unitful(gen, u"NU")          # 250.0 MVA
```

Because the three power units share a dimension, any of them is accepted wherever a
power-dimensioned unit is expected — `get_rating(gen, u"MW")` and
`set_reactive_power!(gen, 25.0 * u"MW")` both work, and `uconvert` handles the relabeling.

## Explicit units in accessors

As of PowerSystems 6, unit conversion is **explicit at every call site**: each unit-bearing
accessor takes a units argument, and each setter takes a unit-tagged value. There is no
system-wide mutable unit setting that changes what accessors return.

```julia
get_active_power(gen, u"SU")       # bare Float64, system-base per-unit
get_active_power(gen, u"CU")       # bare Float64, component-base per-unit
get_active_power(gen, u"NU")       # bare Float64, natural units (MW)
get_active_power(gen, u"MW")       # bare Float64 in an explicit Unitful unit
get_active_power_unitful(gen, u"SU")  # unit-bearing value: 0.9 SUp

set_active_power!(gen, 0.9 * u"SU")    # values must carry their units
set_active_power!(gen, 90.0 * u"MW")
set_rating!(line, 1.2 * u"CU")
set_x!(transformer, 105.8 * u"Ω")   # impedance/admittance fields accept Ω / S
```

Conversion between unit systems does not change the stored parameter values — storage is
in component base for most fields. Conversions happen when accessing parameters
through the accessor functions, making it imperative to use the accessors instead of "dot"
field access. The units of the stored values for each struct are defined in
`src/descriptors/power_system_structs.json`.

Bare `Float64` arguments to converted setters are rejected with an `ArgumentError`: the
caller must say what units the number is in (`val * u"SU"`, `val * u"CU"`, `val * u"MW"`, …).

A rate names its time too: `get_ramp_limits(gen, u"SU/minute")`, `set_ramp_limits!(gen, (up = 6.0u"CU/hr", down = 6.0u"CU/hr"))`. A bare `u"CU"` on a rate is an error, since it
does not say per what time.

### What a per-unit value is per-unit of

`u"CU"`, `u"SU"` and `u"NU"` say which base a value is on, not what it measures; each field
resolves them. A per-unit value then carries units that say both, one dimension per
per-unitized base:

| Quantity   | Component base     | System base        |
|:---------- |:------------------ |:------------------ |
| Power      | `CUp`              | `SUp`              |
| Voltage    | `CUv`              | `CUv`              |
| Impedance  | `CUz` (`CUv²/CUp`) | `SUz` (`CUv²/SUp`) |
| Admittance | `CUy` (`CUp/CUv²`) | `SUy` (`SUp/CUv²`) |
| Current    | `CUi` (`CUp/CUv`)  | `SUi` (`SUp/CUv`)  |

There is no system voltage base — voltage is always referenced to a component — so system-base
quantities use the component's `CUv`. Because the units differ by kind, per-unit values of
different kinds do not add, just as `MW` and `Ω` do not:

```julia
x = get_x_unitful(line, u"SU")            # 0.05 SUz
p = get_active_power_unitful(gen, u"SU")  # 0.4 SUp
x + p                                      # DimensionError
```

Per-unit physics still composes: `i^2 * x` of a per-unit current and impedance is a per-unit
power. The units tell kinds of base apart, not instances: `CUp` values of two components with
different `base_power`s still add, and so do system-base impedances at different voltage
levels. Only system-base power is comparable system-wide.

A value returned by a getter can be passed straight back to a setter of the same kind.
A hand-typed `0.1u"CU"` works in a setter (the field says what it is per-unit of) but not in
arithmetic with a getter's value, since on its own it does not say what it is per-unit of.

## Migration guide: stateful → explicit units

Code written against PowerSystems 5 used a mutable system-wide unit setting. That entire
stateful-override mechanism (`set_units_base_system!`, `with_units_base`, `get_units_base`)
has been removed — it caused real bugs and, once units became explicit at every call
site, had no effect on any conversion result to begin with.

| PowerSystems 5 (stateful)                                                       | PowerSystems 6 (explicit)                                                                 |
|:------------------------------------------------------------------------------- |:----------------------------------------------------------------------------------------- |
| `set_units_base_system!(sys, "SYSTEM_BASE"); get_active_power(gen)`             | `get_active_power(gen, u"SU")`                                                            |
| `with_units_base(sys, UnitSystem.NATURAL_UNITS) do; get_active_power(gen); end` | `get_active_power(gen, u"NU")`                                                            |
| `set_active_power!(gen, 0.9)` (interpreted via system setting)                  | `set_active_power!(gen, 0.9 * u"SU")`                                                     |
| `get_rating(line)`                                                              | `get_rating(line, u"SU")`                                                                 |
| `scaling_factor_multiplier = get_max_active_power` (1-arg)                      | removed; store actual per-device quantities in the series instead of a normalized profile |

Notes:

  - Time-series retrieval passes a units argument to two-argument scaling-factor
    multipliers; the default for PowerSystems components is the `SU` marker. One-argument multipliers
    (custom closures) are still invoked with the owner only.
  - `CostCurve`/`FuelCurve` take the marker instances (`NaturalUnit()`,
    `SystemBaseUnit()`, `ComponentBaseUnit()`) for `power_units`.

## Defining components

Keyword constructors take a required `input_basis` (`u"CU"` or `u"NU"`) that says how to read
the bare numbers passed to unit-bearing fields. A unit-tagged value (`90.0u"MW"`, `0.5u"CU"`)
is always read in its own units, so the two can be mixed. `u"SU"` is rejected, since an
unattached component has no system base. Either way the component stores component base, and
nothing records which basis it was built in. See
[Add a Component in Natural Units](@ref).

Some components, such as [`Line`](@ref)s, have no rating of their own: their `base_power`
records the system base. Their per-unit values are converted against that `base_power`
(100 MVA unless given), and `add_component!` throws if it differs from the system's base
power, rather than silently giving the stored values a new meaning.

By default, downstream optimization packages work in system base because many optimization
problems won't converge when using natural units (for example in
[`PowerSimulations.jl`](https://sienna-platform.github.io/PowerSimulations.jl/stable/)).

## Detachment

Unit-aware getters require the component to be attached to a `System`. The system base power
is resolved at call time through the component's internal `base_value` slot, which is
populated by `add_component!` and cleared by `remove_component!`. Calling a unit-aware
getter on a detached component raises an error:

```julia
gen = ThermalStandard(...)          # not yet in any system
get_active_power(gen, u"SU")           # ERROR: Component gen_name is not attached to a system.

remove_component!(sys, gen)
get_active_power(gen, u"SU")           # same error — remove_component! clears the slot
```

The same check applies to the display path: printing a detached component issues a warning
and falls back to natural units for display. The error is intentional — a per-unit value is
meaningless without a known base.

Verbose displays spell the per-unit units out — `active_power: 1.25 p.u. in system base`,
`rating: 1.0 p.u. in component base` — since `SUp`/`CUp` are this package's shorthand rather
than standard terminology. A compound field whose elements share one base states it once, after
the tuple: `active_power_limits: (min = 0.0 p.u., max = 2.5 p.u.) in system base`. Terse
contexts (the one-line `show`, table cells) keep the short tags.
Dynamic models are not wired into the units engine; their parameters are per-unitized on the
component base, and both `show_component` on a `DynamicInjection` and the display of a single
parameter block (a machine, AVR, shaft, ...) say so in a footer.

## The system base is immutable

`System.base_power` is set once at construction (from the `base_power` argument) and
cannot be changed afterward — there is no `set_base_power!(::System, ...)`. Each attached
component's knowledge of that value is a plain `Float64`, kept up to date by
`add_component!`/`remove_component!`; there is no mutable, system-wide unit setting that
could change what a getter returns.

## Converting values directly

`convert_units` converts a quantity for a given component and category, outside any field:

```julia
# gen.base_power = 50 MVA, system base = 100 MVA
convert_units(gen, 30.0u"MW", ACTIVE_POWER, u"CU")   # → 0.6 CUp
convert_units(gen, 0.6u"CU", ACTIVE_POWER, u"SU")    # → 0.3 SUp
```

Two mistakes raise an `ArgumentError`: a per-unit target with the wrong residual for the
category (a bare `u"CU"` on a rate, or `u"CU/hr"` on a power), and more than one generic unit in
one target (`u"CU*SU"`). A natural unit of the wrong dimension raises Unitful's own
`DimensionError`.

!!! note

    Check the [`Transformers per unit explanation`](@ref transformers_pu) for details on how
    the per-unit is managed
