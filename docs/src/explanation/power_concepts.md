# [Power Concepts: Base Power, Rating, and Max Active Power](@id power_concepts)

When working with generators in PowerSystems.jl, it's important to understand the distinction between three key power concepts: base power, rating, and maximum active power. These concepts serve different purposes and are stored using different unit conventions.

## Base Power

**Base power** is the reference power value used for per-unitization of a specific device.

  - **Purpose**: Serves as the denominator when converting device parameters to per-unit values
  - **Units**: Always stored in **natural units** (MVA)
  - **Typical value**: The nameplate capacity of the device
  - **Access**: Retrieved using `get_base_power(device)`

Base power is a fundamental parameter for the per-unit system and represents the natural scale of the device. For more details on per-unitization, see the [Per-unit Conventions](@ref per_unit) page.

## Rating

**Rating** represents the maximum AC side output power rating of the synchronous machine or generator.

  - **Purpose**: Defines the maximum apparent power (MVA) that the generator's electrical components can safely handle

  - **Units**: Stored in per-unit using **device base** (i.e., divided by the device's `base_power`)

  - **Physical meaning**: The maximum MVA output considering electrical constraints such as:

      + Stator winding thermal limits
      + Rotor field winding limits
      + Cooling system capacity

  - **Access**: Retrieved using `get_rating(device, units)` (the `units` argument is required, e.g. `get_rating(device, DU)`)

The rating is typically determined by the electrical design and thermal limits of the synchronous machine itself. It represents the maximum capability of the electrical generator, independent of the prime mover.

## Maximum Active Power

**Maximum active power** represents the maximum real power output of the prime mover.

  - **Purpose**: Defines the maximum real power (MW) that the prime mover can deliver

  - **Units**: Stored in per-unit using **device base** (i.e., divided by the device's `base_power`)

  - **Physical meaning**: The maximum MW output considering prime mover constraints such as:

      + Turbine capacity (for steam, gas, or hydro turbines)
      + Combustion chamber limits (for gas turbines)
      + Boiler capacity (for steam generators)
      + Fuel flow limitations

  - **Access**: Retrieved using `get_max_active_power(device, units)` (the `units` argument is required, e.g. `get_max_active_power(device, DU)`)

The maximum active power is determined by the mechanical system that drives the generator. This is often less than the rating when considering only real power production.

## Key Distinctions

### Storage Convention Summary

| Concept          | Storage Units       | Accessor Function                     |
|:---------------- |:------------------- |:------------------------------------- |
| Base Power       | Natural units (MVA) | `get_base_power(device)`              |
| Rating           | Device base (p.u.)  | `get_rating(device, units)`           |
| Max Active Power | Device base (p.u.)  | `get_max_active_power(device, units)` |

### Physical Interpretation

The relationship between these three quantities can be understood as follows:

  - **Base Power**: "What is the natural scale of this device?"
  - **Rating**: "What is the maximum apparent power the electrical generator can produce?"
  - **Max Active Power**: "What is the maximum real power the prime mover can deliver?"

### Example

Consider a thermal generator with:

  - `base_power = 100.0` MVA (stored in natural units)
  - `rating = 1.0` p.u. (equals 100 MVA when converted to natural units)
  - `max_active_power = 0.95` p.u. (equals 95 MW when converted to natural units)

In this example:

  - The generator's electrical components can handle up to 100 MVA
  - The prime mover (e.g., steam turbine) can deliver up to 95 MW of real power
  - The difference accounts for the fact that the turbine's mechanical power limit is slightly below the generator's electrical rating

### Unit System Conversions

As of PowerSystems 6, unit conversion is **explicit at every call site**: each unit-bearing
accessor takes a `units` argument (`SU`, `DU`, `NU`, or an explicit `Unitful` unit such as
`u"MW"`), and the value is converted accordingly. There is no system-wide mutable setting that
changes what accessors return. `base_power` is the exception — it is always in natural units
(MVA) and rejects per-unit (`SU`/`DU`) targets.

```julia
# Assuming base_power = 100 MVA, rating = 1.0 p.u. (device base), max_active_power = 0.95 p.u. (device base)
sys = System(100.0)  # System base power = 100 MVA
gen = get_component(ThermalStandard, sys, "gen1")

# Base power is always natural units (MVA); it accepts only `NU` / power-Unitful targets
get_base_power(gen)                    # Returns: 100.0   (MVA, always natural units)
get_base_power(gen, NU)                # Returns: 100.0   (MVA)
# get_base_power(gen, DU)              # ERROR: per-unit bases are not valid for base_power

# Device base (`DU`)
get_rating(gen, DU)                    # Returns: 1.0     (p.u. on device base)
get_max_active_power(gen, DU)          # Returns: 0.95    (p.u. on device base)

# Natural units (`NU`)
get_rating(gen, NU)                    # Returns: 100.0   (MVA)
get_max_active_power(gen, NU)          # Returns: 95.0    (MW)

# System base (`SU`) — here the system base equals the device base
get_rating(gen, SU)                    # Returns: 1.0     (p.u. on system base)
get_max_active_power(gen, SU)          # Returns: 0.95    (p.u. on system base)
```

!!! note

    `base_power` is **always** in natural units (MVA) and rejects `SU`/`DU` targets — it is the
    anchor that every other field's per-unitization is defined against. Rating and maximum active
    power are stored in device base and converted to whatever `units` you request at the call site.

## See Also

  - [Per-unit Conventions](@ref per_unit) - Detailed explanation of unit systems in PowerSystems.jl
  - [`ThermalStandard`](@ref) - Generator type with these power parameters
