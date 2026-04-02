# Write, View, and Load Data with a JSON

`PowerSystems.jl` provides functionality to serialize an entire [`System`](@ref) to a JSON
file and then deserialize it back to a `System`. The main benefit is that
deserializing is significantly faster than reconstructing the `System` from raw
data files.

The sections below show how to write data to a JSON, explore the data while it is in
JSON format, and load Data saved in a JSON back into `PowerSystems.jl`.

## Write data to a JSON

You can do this to save your own custom `System`, but we'll use an existing
dataset from
[`PowerSystemCaseBuilder.jl`](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl),
simply to illustrate the process.

First, load the dependencies and a `System` from `PowerSystemCaseBuilder`:

```@repl serialize_data
using PowerSystems
using PowerSystemCaseBuilder
sys = build_system(PSISystems, "c_sys5_pjm")
```

Set up your target path, for example in a "mysystems" subfolder:

```@repl serialize_data
folder = mkdir("mysystems");
path = joinpath(folder, "system.json")
```

Now write the system to JSON:

```@repl serialize_data
to_json(sys, path)
```

Notice in the `Info` statements that the serialization process stores 3 files:

 1. System data file (`*.json` file)
 2. Validation data file (`*.json` file)
 3. Time Series data file (`*.h5` file)

## Viewing `PowerSystems` Data in JSON Format

Some users prefer to view and filter the `PowerSystems.jl` data while it is in JSON format.
There are many tools available to browse JSON data.

Here is an example [GUI tool](http://jsonviewer.stack.hu) that is available
online in a browser.

The command line utility [jq](https://stedolan.github.io/jq/) offers even more
features. Below are some example commands, called from the command line within the
"mysystems" subfolder:

View the entire file pretty-printed:

```zsh
jq . system.json
```

View the `PowerSystems` component types:

```zsh
jq '.data.components | .[] | .__metadata__ | .type' system.json | sort | uniq
```

View specific components:

```zsh
jq '.data.components | .[] | select(.__metadata__.type == "ThermalStandard")' system.json
```

Get the count of a component type:

```zsh
# There is almost certainly a better way.
jq '.data.components | .[] | select(.__metadata__.type == "ThermalStandard")' system.json | grep -c ThermalStandard
```

View specific component by name:

```zsh
jq '.data.components | .[] | select(.__metadata__.type == "ThermalStandard" and .name == "107_CC_1")' system.json
```

Filter on a field value:

```zsh
jq '.data.components | .[] | select(.__metadata__.type == "ThermalStandard" and .active_power > 2.3)' system.json
```

## Read the JSON file and create a new `System`

Finally, you can read the file back in, and verify the new system has the same data as above:

```@repl serialize_data
sys2 = System(path)
rm(folder; recursive = true); #hide
```

!!! tip

    PowerSystems generates UUIDs for the `System` and all components in order to have
    a way to uniquely identify objects. During deserialization it restores the same
    UUIDs.  If you will modify the `System` or components after deserialization then
    it is recommended that you set this flag to generate new UUIDs.

    ```julia
    system2 = System(path; assign_new_uuids = true)
    ```
