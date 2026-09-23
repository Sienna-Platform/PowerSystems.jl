# Add a Component in Natural Units

```@setup add_in_nu
using PowerSystems; #hide
using PowerSystemCaseBuilder #hide
system = build_system(PSISystems, "modified_RTS_GMLC_DA_sys"); #hide
```

`PowerSystems.jl` has [three per-unitization options](@ref per_unit) for getting and setting
data, selected explicitly at each call site by a units argument.

Every keyword constructor for a component with unit-bearing fields takes a required
`input_basis` keyword, which says how to read the **bare numbers** you pass it:

  - `input_basis = NU`: each bare number is in its field's natural unit (MW, MVAr, MVA, Ω,
    S, MW/min).
  - `input_basis = CU`: each bare number is per-unit on the component's own `base_power`.

A value that carries its own units (`30.0u"MW"`, `0.5CU`) is always read in those units,
whatever `input_basis` says, so you can mix the two. `input_basis` only affects construction:
the component always stores its data in component base, and nothing records how it was
built.

### Step 1: Define the Component in Natural Units

```@repl add_in_nu
gas1 = ThermalStandard(;
    name = "gas1",
    available = true,
    status = OperationalStates.ONLINE,
    bus = get_component(ACBus, system, "Cobb"), # Attach to a previously-defined bus named Cobb
    active_power = 0.0,
    reactive_power = 0.0,
    rating = 30.0, # MVA
    active_power_limits = (min = 6.0, max = 30.0), # MW
    reactive_power_limits = (min = 6.0, max = 30.0), # MVAr
    ramp_limits = (up = 6.0, down = 6.0), # MW/min
    operation_cost = ThermalGenerationCost(nothing),
    base_power = 30.0, # MVA, always
    time_limits = (up = 8.0, down = 8.0), # Hours, unaffected by per-unitization
    prime_mover_type = PrimeMovers.CC,
    fuel = ThermalFuels.NATURAL_GAS,
    input_basis = NU,
);
```

Reading the values back in component base (`get_rating(gas1, CU)`) shows them divided by the
`base_power` of 30 MVA.

`ramp_limits` is a **rate**, so its unit carries a time as well as a power. Under
`input_basis = NU` a bare number is MW/min. To give another time, tag it:
`(up = 360.0u"MW/hr", down = 360.0u"MW/hr")`. Only the power axis is per-unitized (there is
no time base), so a relative value names its time too: `0.2CU/u"minute"`.

`input_basis = SU` is rejected: a component that is not yet attached to a `System` has no
system base to convert from.

### Step 2: Attach the Component

```@repl add_in_nu
add_component!(system, gas1)
```

### Changing Values Later

Setters take the same unit-tagged values. A bare number is rejected with an
`ArgumentError`, because a setter has no `input_basis` to read it in:

```@repl add_in_nu
set_active_power_limits!(gas1, (min = 3.0u"MW", max = 30.0u"MW"))
```

!!! tip

    Steps 1-2 can be called within a `for` loop to define many components at once (or step 2
    can be replaced with [`add_components!`](@ref) to add all components at once).

#### See Also

  - [Read more to understand per-unitization in PowerSystems.jl](@ref per_unit)
  - Learn how to use the default constructors and explore the per-unitization settings in
    [Create and Explore a Power `System`](@ref)
