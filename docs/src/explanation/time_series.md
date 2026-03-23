# [Time Series Data](@id ts_data)

## Categories of Time Series

The bulk of the data in many power system models is time series data. Given the potential
complexity, `PowerSystems.jl` has a set of definitions to organize this data and
enable consistent modeling.

`PowerSystems.jl` supports two categories of time series data depending on the
process to obtain the data and its interpretation:

  - [Static Time Series Data](@ref)
  - [Forecasts](@ref)

These categories are are all subtypes of [`TimeSeriesData`](@ref) and fall within this time series
[type hierarchy](@ref type_structure):

```@repl
using PowerSystems #hide
import TypeTree: tt #hide
docs_dir = joinpath(pkgdir(PowerSystems), "docs", "src", "tutorials", "utils"); #hide
include(joinpath(docs_dir, "docs_utils.jl")); #hide
print(join(tt(TimeSeriesData), "")) #hide
```

### Static Time Series Data

A static time series data is a single column of data where each time period has a single
value assigned to a component field, such as its [maximum active power](@ref power_concepts). This data commonly
is obtained from historical information or the realization of a time-varying quantity.

Static time series usually comes in the following format, with a set [resolution](@ref R)
between the time-stamps:

| DateTime            | Value |
|:------------------- |:-----:|
| 2020-09-01T00:00:00 | 100.0 |
| 2020-09-01T01:00:00 | 101.0 |
| 2020-09-01T02:00:00 | 99.0  |

This example is a 1-hour resolution static time-series.

In `PowerSystems.jl`, a static time series is represented using [`SingleTimeSeries`](@ref).

### Forecasts

A forecast time series includes predicted values of a time-varying quantity that commonly
includes a look-ahead window and can have multiple data values representing each time
period. This data is used in simulation with receding horizons or data generated from
forecasting algorithms.

Key forecast format parameters are the forecast [resolution](@ref R), the
[interval](@ref I) of time between forecast [initial times](@ref I), and the number of
[forecast windows](@ref F) (or forecasted values) in the forecast [horizon](@ref H).

Forecast data usually comes in the following format, where a column represents the time
stamp associated with the [initial time](@ref I) of the forecast, and the remaining columns
represent the forecasted values at each step in the forecast [horizon](@ref H).

| DateTime            | 0     | 1     | 2     | 3    | 4     | 5     | 6     | 7     |
|:------------------- |:-----:|:-----:|:-----:|:----:|:-----:|:-----:|:-----:|:----- |
| 2020-09-01T00:00:00 | 100.0 | 101.0 | 101.3 | 90.0 | 98.0  | 87.0  | 88.0  | 67.0  |
| 2020-09-01T01:00:00 | 101.0 | 101.3 | 99.0  | 98.0 | 88.9  | 88.3  | 67.1  | 89.4  |
| 2020-09-01T02:00:00 | 99.0  | 67.0  | 89.0  | 99.9 | 100.0 | 101.0 | 112.0 | 101.3 |

This example forecast has a [interval](@ref I) of 1 hour and a [horizon](@ref H) of 8.

`PowerSystems.jl` defines the following Julia [structs](@ref S) to represent forecasts:

  - [`Deterministic`](@ref): Point forecast without any uncertainty representation.
  - [`Probabilistic`](@ref): Stores a discretized cumulative distribution functions
    (CDFs) or probability distribution functions (PDFs) at each time step in the
    look-ahead window.
  - [`Scenarios`](@ref): Stores a set of probable trajectories for forecasted quantity
    with equal probability.

## Data Storage

### Why Sienna Stores Time Series as Scaling Factors

In power system models, many components share the same *shape* of time-varying behavior
but differ only in their rated capacity. For example, ten wind turbines at the same site
may all follow the same hourly generation profile, but each has a different nameplate
maximum power output. Storing ten separate time series of absolute MW values wastes
memory and makes the data harder to maintain.

`PowerSystems.jl` addresses this with **scaling factors** — normalized time series whose
values represent a fraction of a component's rated capacity at each time step rather than
an absolute physical quantity. The actual value at any time is obtained by multiplying:

```math
\text{actual value}(t) = \text{scaling factor}(t) \times \text{multiplier}
```

For example, a wind generator with a maximum active power of 100 MW and a scaling factor
of 0.73 at a given hour is producing 73 MW.

Scaling factors are worth the added complexity for two key reasons:

  - **Reusability:** A single time series profile can be shared by many components. If
    ten turbines at the same site follow the same normalized wind profile, only one copy
    of the data needs to be stored; each turbine supplies its own multiplier (its rated
    capacity) at retrieval time. This also means that updating a profile — say, after
    a better forecast becomes available — automatically affects every component that
    references it.

  - **Memory efficiency:** By default, PowerSystems stores time series data in an
    [HDF5 file](https://nrel-sienna.github.io/InfrastructureSystems.jl/stable/dev_guide/time_series/#Data-Format)
    to prevent large datasets from overwhelming system memory. Scaling factors amplify
    this benefit: one normalized profile replaces many absolute-value duplicates, keeping
    both on-disk and in-memory footprints small.

### How Scaling Factors Work in `PowerSystems.jl`

Every time series object has two relevant fields: `data` (the stored values) and
`scaling_factor_multiplier` (a getter function that identifies which component field
provides the multiplier). By default, if no multiplier is specified, `PowerSystems.jl` treats
the stored values as physical units directly.

To store a time series as scaling factors, pass the appropriate getter function when
constructing the time series. For example, to represent a renewable generator's output
as a fraction of its maximum active power:

```@repl time_series
ts = SingleTimeSeries(
    "max_active_power",
    ta;
    scaling_factor_multiplier = get_max_active_power,
)
add_time_series!(sys, gen, ts)
```

When you later retrieve values using [`get_time_series_array`](@ref), `PowerSystems.jl`
automatically multiplies the stored scaling factors by the current value returned by
[`get_max_active_power`](@ref) on the component, returning physical MW values transparently.

Examples of how to create and add time series to a system can be found in the
[Working with Time Series Data](https://nrel-sienna.github.io/PowerSystems.jl/stable/tutorials/generated_working_with_time_series/)
tutorial.
