# [Per-unit Conventions](@id per_unit)

It is often useful to express power systems data in relative terms using per-unit (p.u.) conventions.
`PowerSystems.jl` supports the automatic conversion of data between three different unit systems:

 1. `"NATURAL_UNITS"`: The naturally defined units of each parameter (typically MW).
 2. `"SYSTEM_BASE"`: Parameter values are divided by the system `base_power`.
 3. `"DEVICE_BASE"`: Parameter values are divided by the device `base_power`.

`PowerSystems.jl` supports these unit systems because different power system tools and data
sets use different units systems by convention, such as:

  - Dynamics data is often defined in device base
  - Network data (e.g., reactance, resistance) is often defined in system base
  - Production cost modeling data is often gathered from variety of data sources,
    which are typically defined in natural units

These three unit bases allow easy conversion between unit systems.
This allows `PowerSystems.jl` users to input data in the formats they have available,
as well as view data in the unit system that is most intuitive to them.

You can get and set the unit system setting of a `System` with [`get_units_base`](@ref) and
[`set_units_base_system!`](@ref). To support a less stateful style of programming,
`PowerSystems.jl` provides the `Logging.with_logger`-inspired "context manager"-type
function [`with_units_base`](@ref), which sets the unit system to a particular value,
performs some action, then automatically sets the unit system back to its previous value.
For a worked example of switching unit systems and reading component values, see
[Read Component Values in Different Unit Systems](@ref).

Conversion between unit systems does not change
the stored parameter values. Instead, unit system conversions are made when accessing
parameters using the [getter functions](@ref dot_access), thus making it
imperative to utilize the getter functions instead of the "dot" accessor methods to
ensure the return of the correct values. The units of the parameter values stored in each
struct are defined in `src/descriptors/power_system_structs.json`.

There are some unit system conventions in `PowerSystems.jl` when defining new components.
Currently, when you define components that aren't attached to a `System`,
you must define all fields in `"DEVICE_BASE"`, except for certain components that don't
have their own `base_power` rating, such as [`Line`](@ref)s, where the `rating` must be
defined in `"SYSTEM_BASE"`.

In the future, `PowerSystems.jl` hopes to support defining components in natural units.
For now, if you want to define data in natural units, you must first
set the system units to `"NATURAL_UNITS"`, define an empty component, and then use the
[getter functions](@ref dot_access) (e.g., getters and setters), to define each field
within the component. The getter functions will then do the data conversion from your
input data in natural units (e.g., MW or MVA) to per-unit.

By default, `PowerSystems.jl` uses `"SYSTEM_BASE"` because many optimization problems won't
converge when using natural units. If you change the unit setting, it's suggested that you
switch back to `"SYSTEM_BASE"` before solving an optimization problem (for example in
[`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/stable/)).

## [Transformer per unit transformations](@id transformers_pu)

Per-unit conventions with transformers simplify calculations by normalizing all quantities
(voltage, current, power, impedance) to a common base. This effectively "retains" the
ideal transformer from the circuit diagram because the per-unit impedance of a transformer
remains the same when referred from one side to the other. A more in-depth explanation can
be found in [this link](https://en.wikipedia.org/wiki/Per-unit_system) or basic power
systems literature.

Transformer impedance (usually reactive impedance, $X_{pu}$) is typically given on the
transformer's own nameplate ratings (rated MVA and rated voltages). **The data in
`PowerSystems.jl` is stored on the device base** and converted to the system base when
using the getter functions.

The key quantity needed for that conversion is the base impedance of each voltage zone:

$$Z_{base} = \frac{(V_{base,\,LL})^2}{S_{base,\,3\phi}}$$

with $V_{base,\,LL}$ in kV and $S_{base,\,3\phi}$ in MVA. The zone base voltage is
propagated from the primary side using the transformer's turns ratio:

$$V_{base,\,\text{secondary}} = V_{base,\,\text{primary}} \times \frac{V_{\text{rated,\,secondary}}}{V_{\text{rated,\,primary}}}$$

Note that this value can differ slightly from the attached bus voltage set point. As of
`PowerSystems.jl` v5, transformer components carry an explicit field for their base
voltage to make this relationship unambiguous.

For a step-by-step guide to establishing base values and performing the impedance base
change manually, see
[Convert Transformer Impedances Between Per-Unit Bases](@ref).

!!! note

    The return value of the getter functions, e.g., [`get_x`](@ref) for the transformer
    impedances will perform these transformations automatically, following the convention
    described on this page.
