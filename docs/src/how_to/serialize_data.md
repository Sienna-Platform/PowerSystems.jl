# Write, View, and Load Data as a Bundle or Archive

`PowerSystems.jl` provides [`to_file`](@ref)/[`from_file`](@ref) to serialize an entire
[`System`](@ref) and deserialize it back. The main benefit is that deserializing is
significantly faster than reconstructing the `System` from raw data files.

There are two formats:

  - `format = :json` (default) — a directory holding `system.json` (an OpenAPI document) plus,
    when the system has time series, `time_series.h5` and its `time_series.h5.sqlite` catalog.
  - `format = :sienna` — the same three members, tar+gzip'd into one file (conventionally named
    `*.sn`).

!!! warning

    There is no migration path from the old single-file native JSON format (written by the
    removed `IS.to_json`/`System(path)` constructor) or from a `to_file`/`from_file` bundle
    written before this format. A `System` serialized in either old shape must be rebuilt from
    source and re-serialized with the current `to_file`.

    A round trip through `to_file`/`from_file` also does not yet preserve a `System`'s
    user-defined subsystems or masked components (for example, some internal use of
    `HybridSystem` subcomponents). `to_file` warns when it detects either, but does not error.

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

Write it as a `:json` bundle:

```@repl serialize_data
bundle = mkdir("mysystem")
to_file(sys, bundle)
readdir(bundle)
```

Or as a single `:sienna` archive:

```@repl serialize_data
to_file(sys, "mysystem.sn"; format = :sienna)
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

## Read a bundle or archive back into a `System`

`from_file` infers the format from `path` — a directory reads as a `:json` bundle, a `.sn`
file reads as a `:sienna` archive:

```@repl serialize_data
sys2 = from_file(bundle)
sys3 = from_file("mysystem.sn")
rm(bundle; recursive = true); #hide
rm("mysystem.sn"); #hide
```
