# Write, View, and Load Data as a Bundle or Archive

`PowerSystems.jl` provides [`to_file`](@ref)/[`from_file`](@ref) to serialize an entire
[`System`](@ref) and deserialize it back. The main benefit is that deserializing is
significantly faster than reconstructing the `System` from raw data files.

There are three forms, chosen by the extension of the path you pass to `to_file`:

  - **a directory** (no extension) — holds `system.json`, an OpenAPI document, plus
    `time_series.h5` when the system has time series.
  - **a `.json` file** — the same two members, with the sidecar named after the document
    (`mysystem.json` and `mysystem.h5`) and sitting beside it, so several systems can share one
    directory.
  - **a `.sns` file** — those two plus InfraStore's own `time_series.h5.sqlite` catalog and
    `sienna_extras.json`, zipped into a single file. This is the lossless form.

The two document forms are readable by any client that can read the OpenAPI schema; the archive
is Sienna-only, because reading it means reading InfraStore's catalog.

!!! warning

    Only the `.sns` archive preserves a `System`'s user-defined subsystems; the two document
    forms warn (they do not error) when the system has any, because the document has no
    representation for them. Masked components — for example some internal uses of
    `HybridSystem` subcomponents — survive every form, being re-masked on read when their owning
    `StaticInjectionSubsystem` is added.

## Write data

Build (or load) the `System` you want to save. Here's a small hand-built one to illustrate
the process:

```@repl serialize_data
using PowerSystems
sys = System(100.0)
bus = ACBus(;
    number = 1, name = "bus1", available = true, bustype = ACBusTypes.REF,
    angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
    base_voltage = 230.0,
)
add_component!(sys, bus)
gen = ThermalStandard(;
    name = "107_CC_1", available = true, status = true, bus = bus,
    active_power = 1.0, reactive_power = 0.0, rating = 2.5,
    active_power_limits = (min = 0.0, max = 2.5),
    reactive_power_limits = (min = -1.0, max = 1.0),
    ramp_limits = nothing, operation_cost = ThermalGenerationCost(nothing),
    base_power = 100.0,
)
add_component!(sys, gen)
```

`to_file` picks the form from the extension of the path you give it — there is no `format`
keyword. Write it as a directory:

```@repl serialize_data
bundle = "mysystem"
to_file(sys, bundle)
readdir(bundle)
```

Or as a single `.json` document, whose sidecar takes the document's stem and sits beside it —
so several systems can share one directory:

```@repl serialize_data
to_file(sys, "mysystem.json")
```

Or as a single lossless `.sns` archive, the only form that keeps subsystems:

```@repl serialize_data
to_file(sys, "mysystem.sns")
```

## Viewing the document in JSON format

Some users prefer to view and filter the data while it is in JSON format. There are many
tools available to browse JSON data — for example the command line utility
[jq](https://stedolan.github.io/jq/). Below are some example commands, called from the command
line within the `mysystem` directory. Components are grouped by type name:

View the component types present:

```zsh
jq '.components | keys' system.json
```

View all components of one type:

```zsh
jq '.components.ThermalStandard' system.json
```

View one component by name:

```zsh
jq '.components.ThermalStandard[] | select(.name == "107_CC_1")' system.json
```

Filter on a field value:

```zsh
jq '.components.ThermalStandard[] | select(.active_power > 2.3)' system.json
```

## Read a bundle, document or archive back into a `System`

`from_file` infers the form from `path` the same way `to_file` does — a directory, a `.json`
document, or a `.sns` archive:

```@repl serialize_data
sys2 = from_file(bundle)
sys3 = from_file("mysystem.json")
sys4 = from_file("mysystem.sns")
rm(bundle; recursive = true); #hide
rm("mysystem.json");
rm("mysystem.h5"; force = true); #hide
rm("mysystem.sns"); #hide
```
