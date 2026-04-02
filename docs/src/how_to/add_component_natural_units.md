# Add a Component in Natural Units

```@setup add_in_nu
using PowerSystems; #hide
using PowerSystemCaseBuilder #hide
system = build_system(PSISystems, "modified_RTS_GMLC_DA_sys"); #hide
```

`PowerSystems.jl` has [three per-unitization options](@ref per_unit) for getting, setting
and displaying data.

Currently, only one of these options -- `"DEVICE_BASE"` -- is supported when using a
constructor function define a component. You can see
[an example of the default capabilities using `"DEVICE_BASE"` here](@ref "Adding Loads and Generators").

We hope to add capability to define components in
`"NATURAL_UNITS"` with constructors in the future, but for now, below is a workaround
for users who prefer to define data using `"NATURAL_UNITS"` (e.g., MW, MVA, MVAR, or MW/min):

### Step 1: Set Units Base

Set your (previously-defined) `System`'s units base to `"NATURAL_UNITS"`:

```@repl add_in_nu
set_units_base_system!(system, "NATURAL_UNITS")
```

Now, the "setter" functions have been switched to define data using natural units (MW, MVA,
etc.), taking care of the necessary data conversions behind the scenes.

### Step 2: Define Empty Component

Define an empty component with `0.0` or `nothing` for all the power-related fields except
`base_power`, which is always in MVA.

For example:

```@repl add_in_nu
gas1 = ThermalStandard(;
    name = "gas1",
    available = true,
    status = true,
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
    must_run = false,
    prime_mover_type = PrimeMovers.CC,
    fuel = ThermalFuels.NATURAL_GAS,
);
```

### Step 3: Attach the Component

Attach the component to your `System`:

```@repl add_in_nu
add_component!(system, gas1)
```

### Step 4: Add Data with "setter" Functions

Use individual "setter" functions to set each the value of each numeric field in natural
units:

```@repl add_in_nu
set_rating!(gas1, 30.0) #MVA
set_active_power_limits!(gas1, (min = 6.0, max = 30.0)) # MW
set_reactive_power_limits!(gas1, (min = 6.0, max = 30.0)) # MVAR
set_ramp_limits!(gas1, (up = 6.0, down = 6.0)) #MW/min
```

Notice the return values are divided by the `base_power` of 30 MW, showing the setters have
done the per-unit conversion into `"DEVICE_BASE"` behind the scenes.

!!! tip

    Steps 2-4 can be called within a `for` loop to define many components at once (or step 3
    can be replaced with [`add_components!`](@ref) to add all components at once).

#### See Also

  - [Read more to understand per-unitization in PowerSystems.jl](@ref per_unit)
  - Learn how to use the default constructors and explore the per-unitization settings in
    [Create and Explore a Power `System`](@ref)
