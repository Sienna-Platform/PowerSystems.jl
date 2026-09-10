# Add a Component in Natural Units

```@setup add_in_nu
using PowerSystems; #hide
using PowerSystemCaseBuilder #hide
system = build_system(PSISystems, "modified_RTS_GMLC_DA_sys"); #hide
```

`PowerSystems.jl` has [three per-unitization options](@ref per_unit) for getting and setting
data, selected explicitly at each call site by a units argument.

Constructors define a component's numeric fields in **device base** (`DU`): bare numbers
passed to a constructor are interpreted as per-unit on the device's own `base_power`. You can
see [an example of defining a component this way here](@ref "Adding Loads and Generators").

If you prefer to define data in **natural units** (e.g., MW, MVA, MVAR, or MW/min), pass
unit-tagged values to the "setter" functions after constructing the component — the setters
convert to the stored device-base representation for you. There is no longer a system-wide
unit setting to toggle (see [Per-unit Conventions](@ref per_unit)).

### Step 1: Define Empty Component

Define an empty component with `0.0` or `nothing` for all the power-related fields except
`base_power`, which is always in MVA. (Bare numbers in the constructor are device-base
per-unit; here every power field starts at `0.0`.)

For example:

```@repl add_in_nu
gas1 = ThermalStandard(;
    name = "gas1",
    available = true,
    status = OperationalStates.ONLINE,
    bus = get_component(ACBus, system, "Cobb"), # Attach to a previously-defined bus named Cobb
    active_power = 0.0,
    reactive_power = 0.0,
    rating = 0.0,
    active_power_limits = (min = 0.0, max = 0.0),
    reactive_power_limits = nothing,
    ramp_limits = nothing,
    operation_cost = ThermalGenerationCost(nothing),
    base_power = 30.0, # MVA
    time_limits = (up = 8.0, down = 8.0), # Hours, unaffected by per-unitization
    prime_mover_type = PrimeMovers.CC,
    fuel = ThermalFuels.NATURAL_GAS,
);
```

### Step 2: Attach the Component

Attach the component to your `System`:

```@repl add_in_nu
add_component!(system, gas1)
```

### Step 3: Add Data with "setter" Functions

Use individual "setter" functions, passing **unit-tagged** natural-units values (`MW`,
`MVAr`, etc.). The setters convert each value to device base behind the scenes:

```@repl add_in_nu
set_rating!(gas1, 30.0 * MVA)
set_active_power_limits!(gas1, (min = 6.0 * MW, max = 30.0 * MW))
set_reactive_power_limits!(gas1, (min = 6.0 * MVAr, max = 30.0 * MVAr))
set_ramp_limits!(gas1, (up = 6.0 * MW, down = 6.0 * MW)) # ramp limits per-unitize by base_power
```

A bare number (e.g. `set_rating!(gas1, 30.0)`) is rejected with an `ArgumentError`: setters
require the value to carry its units. Reading the values back in device base
(`get_rating(gas1, DU)`) shows them divided by the `base_power` of 30 MVA — the per-unit
conversion the setters performed.

!!! tip

    Steps 1-3 can be called within a `for` loop to define many components at once (or step 2
    can be replaced with [`add_components!`](@ref) to add all components at once).

#### See Also

  - [Read more to understand per-unitization in PowerSystems.jl](@ref per_unit)
  - Learn how to use the default constructors and explore the per-unitization settings in
    [Create and Explore a Power `System`](@ref)
