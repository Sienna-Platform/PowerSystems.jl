# [Read Component Values in Different Unit Systems](@id convert_unit_systems)

`PowerSystems.jl` stores component parameters internally in per-unit on the device base,
but getter functions automatically convert values to whatever unit system the [`System`](@ref) is
currently set to. This page shows how to switch unit systems and interpret the results.

For background on why `PowerSystems.jl` uses per-unit conventions and what each unit system
means, see [Per-unit Conventions](@ref per_unit).

## Step 1: Check or change the unit system

Use [`get_units_base`](@ref) to check the current setting and
[`set_units_base_system!`](@ref) to change it:

```@repl convert_unit_systems
using PowerSystems

# Build a minimal system with one bus and one generator.
bus = ACBus(;
    number = 1,
    name = "bus1",
    available = true,
    bustype = ACBusTypes.REF,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.9, max = 1.05),
    base_voltage = 230.0,
)

sys = System(100.0)  # System base power = 100 MVA
add_component!(sys, bus)

get_units_base(sys)  # Returns the current unit system, e.g. "SYSTEM_BASE"

set_units_base_system!(sys, "NATURAL_UNITS")
```

The three supported options are:

| Setting           | Meaning                                             |
|:----------------- |:--------------------------------------------------- |
| `"SYSTEM_BASE"`   | Values divided by the system `base_power` (default) |
| `"DEVICE_BASE"`   | Values divided by the device's own `base_power`     |
| `"NATURAL_UNITS"` | Values in physical units (MW, MVA, etc.)            |

## Step 2: Read values with getter functions

Once the unit system is set, all getter functions return values in the corresponding units:

```@repl convert_unit_systems
# Add a 100 MVA thermal generator to the system created in Step 1.
gen = ThermalStandard(;
    name = "gen1",
    available = true,
    status = true,
    bus = bus,
    active_power = 0.0,
    reactive_power = 0.0,
    rating = 1.0,                                   # 1.0 p.u. on device base = 100 MVA
    active_power_limits = (min = 0.2, max = 1.0),   # p.u. on device base
    reactive_power_limits = nothing,
    ramp_limits = nothing,
    operation_cost = ThermalGenerationCost(nothing),
    base_power = 100.0,                             # MVA — always stored in natural units
    prime_mover_type = PrimeMovers.CC,
    fuel = ThermalFuels.NATURAL_GAS,
)
add_component!(sys, gen)

# In DEVICE_BASE
set_units_base_system!(sys, "DEVICE_BASE")
get_base_power(gen)           # Returns: 100.0 MVA (always natural units)
get_rating(gen)               # Returns: 1.0 p.u. (on device base)
get_max_active_power(gen)     # Returns: 1.0 p.u. (on device base)

# In NATURAL_UNITS
set_units_base_system!(sys, "NATURAL_UNITS")
get_base_power(gen)           # Returns: 100.0 MVA (always natural units)
get_rating(gen)               # Returns: 100.0 MVA (converted from device p.u.)
get_max_active_power(gen)     # Returns: 100.0 MW (converted from device p.u.)

# In SYSTEM_BASE
set_units_base_system!(sys, "SYSTEM_BASE")
get_base_power(gen)           # Returns: 100.0 MVA (always natural units)
get_rating(gen)               # Returns: 1.0 p.u. (on system base, when system base = device base)
get_max_active_power(gen)     # Returns: 1.0 p.u. (on system base)
```

!!! note

    `get_base_power` always returns a value in natural units (MVA) regardless of the unit
    system setting. Only parameters such as `rating` and `max_active_power` are affected
    by the unit system.

## Using a context manager to avoid permanent changes

If you only need values in a particular unit system temporarily, use
[`with_units_base`](@ref) instead of `set_units_base_system!`. It restores the original
unit system automatically after the block completes, even if an error occurs:

```@repl convert_unit_systems
mw_value = with_units_base(sys, "NATURAL_UNITS") do
    get_max_active_power(gen)
end
# Unit system is restored to its previous value here
```

See [Use Context Managers for Efficient Bulk Operations](@ref use_context_managers) for more examples.

## See Also

  - [Per-unit Conventions](@ref per_unit) — explanation of all three unit systems
  - [Create and Explore a Power System](@ref "Create and Explore a Power `System`") — tutorial that
    constructs components in device base and demonstrates unit system conversions in practice
  - [Add a Component in Natural Units](@ref add_component_natural_units) — how to define component data in MW/MVA
  - [`with_units_base`](@ref), [`get_units_base`](@ref), [`set_units_base_system!`](@ref)
