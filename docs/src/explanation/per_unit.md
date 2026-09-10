# [Per-unit Conventions](@id per_unit)

It is often useful to express power systems data in relative terms using per-unit conventions.
`PowerSystems.jl` supports conversion of data between three different unit systems:

 1. `NU` (natural units): The naturally defined units of each parameter (see
    [Natural units by quantity](@ref natural_units_by_quantity) below).
 2. `SU` (system base): Parameter values are divided by the system `base_power`.
 3. `DU` (device base): Parameter values are divided by the device `base_power`.

`PowerSystems.jl` supports these unit systems because different power system tools and data
sets use different units systems by convention, such as:

  - Dynamics data is often defined in device base
  - Network data (e.g., reactance, resistance) is often defined in system base
  - Production cost modeling data is often gathered from variety of data sources,
    which are typically defined in natural units

## [Natural units by quantity](@id natural_units_by_quantity)

`NU` resolves to the unit that fits the physical quantity the field holds, so active,
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
get_active_power(gen, NU)            # 125.0 (MW)
get_reactive_power_unitful(gen, NU)  # 25.0 MVAr
get_rating_unitful(gen, NU)          # 250.0 MVA
```

Because the three power units share a dimension, any of them is accepted wherever a
power-dimensioned unit is expected — `get_rating(gen, u"MW")` and
`set_reactive_power!(gen, 25.0 * u"MW")` both work, and `uconvert` handles the relabeling.

## Explicit units in accessors

As of PowerSystems 6, unit conversion is **explicit at every call site**: each unit-bearing
accessor takes a units argument, and each setter takes a unit-tagged value. There is no
system-wide mutable unit setting that changes what accessors return.

```julia
get_active_power(gen, SU)       # bare Float64, system-base per-unit
get_active_power(gen, DU)       # bare Float64, device-base per-unit
get_active_power(gen, NU)       # bare Float64, natural units (MW)
get_active_power(gen, u"MW")       # bare Float64 in an explicit Unitful unit
get_active_power_unitful(gen, SU)  # unit-bearing value (RelativeQuantity / Unitful.Quantity)

set_active_power!(gen, 0.9 * SU)    # values must carry their units
set_active_power!(gen, 90.0 * u"MW")
set_rating!(line, 1.2 * DU)
set_x!(transformer, 105.8 * u"Ω")   # impedance/admittance fields accept Ω / S
```

Conversion between unit systems does not change the stored parameter values — storage is
in device base (`DU`) for most fields. Conversions happen when accessing parameters
through the accessor functions, making it imperative to use the accessors instead of "dot"
field access. The units of the stored values for each struct are defined in
`src/descriptors/power_system_structs.json`.

Bare `Float64` arguments to converted setters are rejected with an `ArgumentError`: the
caller must say what units the number is in (`val * SU`, `val * DU`, `val * u"MW"`, …). The
unit-tagged per-unit values are [`RelativeQuantity`](@ref)s, whose unit marker is carried
in the type; mixing `DU`- and `SU`-tagged values in arithmetic or comparisons raises a
clear error instead of producing a silently wrong number.

## Migration guide: stateful → explicit units

Code written against PowerSystems 5 used a mutable system-wide unit setting. That entire
stateful-override mechanism (`set_units_base_system!`, `with_units_base`, `get_units_base`)
has been removed — it caused real bugs and, once units became explicit at every call
site, had no effect on any conversion result to begin with.

| PowerSystems 5 (stateful)                                                       | PowerSystems 6 (explicit)                                                                 |
|:------------------------------------------------------------------------------- |:----------------------------------------------------------------------------------------- |
| `set_units_base_system!(sys, "SYSTEM_BASE"); get_active_power(gen)`             | `get_active_power(gen, SU)`                                                               |
| `with_units_base(sys, UnitSystem.NATURAL_UNITS) do; get_active_power(gen); end` | `get_active_power(gen, NU)`                                                               |
| `set_active_power!(gen, 0.9)` (interpreted via system setting)                  | `set_active_power!(gen, 0.9 * SU)`                                                        |
| `get_rating(line)`                                                              | `get_rating(line, SU)`                                                                    |
| `scaling_factor_multiplier = get_max_active_power` (1-arg)                      | removed; store actual per-device quantities in the series instead of a normalized profile |

Notes:

  - Time-series retrieval passes a units argument to two-argument scaling-factor
    multipliers; the default for PowerSystems components is `SU`. One-argument multipliers
    (custom closures) are still invoked with the owner only.
  - `CostCurve`/`FuelCurve` take the marker instances (`NaturalUnit()`,
    `SystemBaseUnit()`, `DeviceBaseUnit()`) for `power_units`.

## Defining components

When you define components that aren't attached to a `System`, field values are stored as
given, in device base (`DU`), except for certain components that don't have their own
`base_power` rating, such as [`Line`](@ref)s, where values are relative to the system base
once attached. To define data in natural units, construct the component and then use the
explicit-units setters (e.g. `set_active_power!(gen, 90.0 * u"MW")`); the accessor does the
conversion to per-unit storage.

By default, downstream optimization packages work in `SU` because many optimization
problems won't converge when using natural units (for example in
[`PowerSimulations.jl`](https://sienna-platform.github.io/PowerSimulations.jl/stable/)).

## Detachment

Unit-aware getters require the component to be attached to a `System`. The system base power
is resolved at call time through the component's internal `base_value` slot, which is
populated by `add_component!` and cleared by `remove_component!`. Calling a unit-aware
getter on a detached component raises an error:

```julia
gen = ThermalStandard(...)          # not yet in any system
get_active_power(gen, SU)           # ERROR: Component gen_name is not attached to a system.

remove_component!(sys, gen)
get_active_power(gen, SU)           # same error — remove_component! clears the slot
```

The same check applies to the display path: printing a detached component issues a warning
and falls back to natural units for display. The error is intentional — a per-unit value is
meaningless without a known base.

Verbose displays spell the per-unit markers out — `active_power: 1.25 p.u. in system base`,
`rating: 1.0 p.u. in device base` — since `SU`/`DU` are this package's shorthand rather than
standard terminology. A compound field whose elements share one base states it once, after
the tuple: `active_power_limits: (min = 0.0 p.u., max = 2.5 p.u.) in system base`. Terse
contexts (the one-line `show`, table cells) keep the short tags.
Dynamic models are not wired into the units engine; their parameters are per-unitized on the
device base, and both `show_component` on a `DynamicInjection` and the display of a single
parameter block (a machine, AVR, shaft, ...) say so in a footer.

## The system base is immutable

`System.base_power` is set once at construction (from the `base_power` argument) and
cannot be changed afterward — there is no `set_base_power!(::System, ...)`. Each attached
component's knowledge of that value is a plain `Float64`, kept up to date by
`add_component!`/`remove_component!`; there is no mutable, system-wide unit setting that
could change what a getter returns.

## Conversion errors

`convert_units` enforces consistency between the value type and the `from` marker. Three
mismatch patterns raise `ArgumentError`:

**Unitful value with a relative `from` marker.** A `Quantity` carries its own physical units;
claiming a relative base as `from` contradicts them:

```julia
# gen.base_power = 50 MVA, system base = 100 MVA
convert_units(gen, 30.0u"MW", ACTIVE_POWER, SU, DU)
# ArgumentError: value 30.0 MW carries physical units but `from = SU` claims a relative
# base; pass the value's own units (or NU) as `from`
```

Pass `NU` (or the Unitful unit directly) as `from` instead:

```julia
convert_units(gen, 30.0u"MW", ACTIVE_POWER, NU, DU)   # → 0.6 DU
```

**`RelativeQuantity` tag disagrees with `from`.** A `RelativeQuantity` encodes its base in
its type; `from` must match:

```julia
val = 0.3 * SU                               # RelativeQuantity{Float64, SystemBaseUnit}
convert_units(gen, val, ACTIVE_POWER, DU, SU)
# ArgumentError: value is tagged SU but `from = DU`; the tag and the `from` marker must agree
```

**Unsupported combination.** Any value/from/to triple not covered by the dispatch table hits
a catch-all:

```julia
convert_units(gen, "0.5", ACTIVE_POWER, SU, DU)
# ArgumentError: unsupported unit conversion for String from SU to DU
```

!!! note

    Check the [`Transformers per unit explanation`](@ref transformers_pu) for details on how
    the per-unit is managed
