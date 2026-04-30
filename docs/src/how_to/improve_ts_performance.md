# [Improve Performance with Time Series Data](@id improve_ts_performance)

```@setup improve_ts_performance
using PowerSystems
```

Use the steps here to improve performance with small or large data sets, but
particularly large data sets. These improvements can help handle adding
large numbers of data sets or reduce overhead when accessing time series data
multiple times.

## Choosing the Storage Location

By default, time series data is stored in an HDF5 file in the tmp file system to prevent
large datasets from overwhelming system memory. However, you can change its location.

### Small data sets

If your dataset will fit in your computer's memory, then you can increase
performance by storing it in memory:

```@example improve_ts_performance
sys = System(100.0; time_series_in_memory = true)
```

### Large data sets

If the system's time series data will be larger than the amount of tmp space available, use
the `time_series_directory` parameter to change its location.

```@example improve_ts_performance
sys = System(100.0; time_series_directory = mktempdir())
```

You can also override the location by setting the environment
variable `SIENNA_TIME_SERIES_DIRECTORY` to another directory.

HDF5 compression is not enabled by default, but you can enable
it with `enable_compression` to get significant storage savings at the cost of CPU time.
[`CompressionSettings`](@ref) can be used to customize the HDF5 compression.

```@example improve_ts_performance
sys = System(100.0; enable_compression = true)
sys = System(
    100.0;
    compression = CompressionSettings(;
        enabled = true,
        type = CompressionTypes.DEFLATE,  # BLOSC is also supported
        level = 3,
        shuffle = true,
    ),
)
```

## Adding Timeseries To The System

In order to optimize the storage of time series data, time series can be shared
across devices to avoid duplication. If the same [forecast](@ref "Forecasts") applies to multiple
components then can call `add_time_series!`, passing the collection of
components that share the time series data.
Time series data can also be shared on a component level. Suppose a time series array applies to
both the `max_active_power` and `max_reactive_power` attributes of a generator. You can share the
data.

```julia
resolution = Dates.Hour(1)
data = Dict(
    DateTime("2020-01-01T00:00:00") => ones(24),
    DateTime("2020-01-01T01:00:00") => ones(24),
)
# Define a Deterministic for the first attribute
forecast_max_active_power = Deterministic(
    "max_active_power",
    data,
    resolution;
    scaling_factor_multiplier = get_max_active_power,
)
add_time_series!(sys, generator, forecast_max_active_power)
# Reuse time series for second attribute
forecast_max_reactive_power = Deterministic(
    forecast_max_active_power,
    "max_reactive_power";
    scaling_factor_multiplier = get_max_reactive_power,
)
add_time_series!(sys, generator, forecast_max_reactive_power)
```

By default, the call to [`add_time_series!`](@ref) will open the HDF5 file, write the data to the file,
and close the file. It will also add a row to an SQLite database. These operations have overhead.
If you will add thousands of time series arrays, consider using [`begin_time_series_update`](@ref).
All arrays will be written with one file handle. The bulk SQLite operations are much more
efficient.

```julia
begin_time_series_update(sys) do
    add_time_series!(sys, component1, time_series1)
    add_time_series!(sys, component2, time_series2)
    add_time_series!(sys, component3, time_series3)
end
```

## Using Forecast Caches for Simulations

Each retrieval of a forecast window from the HDF5 file will involve a small disk read.
In the case of production cost modeling or other analyses that access
forecast windows repeatedly, this can slow down processes significantly, especially if the
underlying storage uses spinning disks.

`PowerSystems.jl` provides an alternate interface -- the forecast cache -- that pre-fetches data
into the system memory with large reads in order to mitigate this potential problem.
It is highly recommended that you use this interface for modeling implementations. This is
particularly relevant for models using large datasets.
For example:

```julia
cache = ForecastCache(Deterministic, component, "max_active_power")
window1 = get_next_time_series_array!(cache)
window2 = get_next_time_series_array!(cache)
# or
for window in cache
    @show window
end
```

Each iteration of on the cache object will deliver the next forecast window (see
[`get_next_time_series_array!`](@ref)).
