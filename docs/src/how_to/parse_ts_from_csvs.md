# [Parse Time Series Data from .csv's](@id parsing_time_series)

This example shows how to parse time series data from .csv files to add to a `System`.
For example, a `System` created by [parsing a MATPOWER file](@ref pm_data) doesn't contain
any time series data, so a user may want to add time series to be able to run a production
cost model.

```@setup forecasts
using PowerSystems
using JSON3

file_dir = joinpath(pkgdir(PowerSystems), "docs", "src", "tutorials", "tutorials_data"); #hide
sys = System(joinpath(file_dir, "case5_re.m"));
```

Let's use a predefined 5-bus [`System`](@ref) with some renewable generators and loads that
we want to add time-series data to:

```@repl forecasts
sys
```

## Define pointers to time series files

`PowerSystems` requires a metadata file that maps components to their time series
data in order to be able to automatically construct time_series from .csv data
files.

For example, if we want to add a bunch of time series files, say one for each load and one
for each renewable generator, we need to define *pointers* to each time series .csv file
with the following fields:

  - `simulation`:  User description of simulation
  - `resolution`:  Resolution of time series in seconds
  - `module`:  Module that defines the abstract type of the component
  - `category`:  Type of component. Must map to abstract types defined by the "module"
    entry (Bus, ElectricLoad, Generator, LoadZone, Reserve)
  - `component_name`:  Name of component
  - `name`:  User-defined name for the time series data.
  - `normalization_factor`:  Controls normalization of the data. Use 1.0 for
    pre-normalized data. Use 'Max' to divide the time series by the max value in the
    column. Use any float for a custom scaling factor.
  - `scaling_factor_multiplier_module`:  Module that defines the accessor function for the
    scaling factor
  - `scaling_factor_multiplier`:  Accessor function of the scaling factor
  - `data_file`:  Path to the time series data file

Notes:

  - The `module`, `category`, and `component_name` entries must be valid arguments to retrieve
    a component using `get_component(${module}.${category}, sys, $name)`.
  - The `scaling_factor_multiplier_module` and the `scaling_factor_multiplier` entries must
    be sufficient to return the scaling factor data using
    `${scaling_factor_multiplier_module}.${scaling_factor_multiplier}(component)`.

`PowerSystems` supports this metadata in either CSV or JSON formats.

In this example, we will use the JSON format. The example file can be found
[here](https://github.com/Sienna-Platform/PowerSystemsTestData/blob/master/5-Bus/5bus_ts/timeseries_pointers_da.json),
and this is what its pointers look like in the required format:

```@repl forecasts
using PowerSystemCaseBuilder #hide
DATA_DIR = PowerSystemCaseBuilder.DATA_DIR #hide
FORECASTS_DIR = joinpath(DATA_DIR, "5-Bus", "5bus_ts"); #hide
fname = joinpath(FORECASTS_DIR, "timeseries_pointers_da.json"); # hide
open(fname, "r") do f # hide
    JSON3.@pretty JSON3.read(f) # hide
end #hide
```

## Read and assign time series to `System` using these parameters.

```@repl forecasts
fname = joinpath(FORECASTS_DIR, "timeseries_pointers_da.json")
add_time_series!(sys, fname)
```

You can print the `System` to see a new table summarizing the time series data that has been
added:

```@repl forecasts
sys
```

### See also:

  - [Improve Performance with Time Series Data](@ref)
  - Parsing [Matpower or PSS/e RAW Files](@ref pm_data)
  - Parsing [PSS/e DYR Files](@ref dyr_data)
  - [Build a `System` from CSV files](@ref system_from_csv)
