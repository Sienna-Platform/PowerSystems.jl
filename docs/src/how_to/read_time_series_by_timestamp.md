# [Read Time Series Data by Timestamp](@id read_ts_by_timestamp)

Suppose you are stepping a simulation through time and need every component's value at the
current timestamp, then the next one. The rest of the time series API is *series-oriented*:
[`get_time_series_array`](@ref) hands back one component's whole array. Driving a stepping
loop with it leaves two bad options — hold every array in memory, or re-read each
component's series on every step.

PowerSystems provides two *cross-sectional* readers built for exactly this. You build one
once against a filter, then drive it forward through time; each read touches only the values
for the requested timestamp.

| Reader             | Build with                                | Drive with                                | Read one value with                    |
|:------------------ |:----------------------------------------- |:----------------------------------------- |:-------------------------------------- |
| `SingleTimeSeries` | [`build_static_time_series_reader`](@ref) | [`read_static_time_series_values!`](@ref) | [`get_static_time_series_value`](@ref) |
| Forecasts          | [`build_forecast_reader`](@ref)           | [`read_forecast_window!`](@ref)           | [`get_forecast_window`](@ref)          |

## Stepping through `SingleTimeSeries`

Build a system with three generators, each carrying its own 24-hour profile:

```julia
using PowerSystems
using Dates
using TimeSeries

sys = System(100.0)
bus = ACBus(;
    available = true,
    number = 1,
    name = "bus1",
    bustype = ACBusTypes.REF,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.9, max = 1.1),
    base_voltage = 230.0,
)
add_component!(sys, bus)

gens = [
    ThermalStandard(;
        name = "gen$i",
        available = true,
        status = OperationalStates.ONLINE,
        bus = bus,
        active_power = 1.0,
        reactive_power = 0.0,
        rating = 1.2,
        active_power_limits = (min = 0.0, max = 1.2),
        reactive_power_limits = nothing,
        ramp_limits = nothing,
        operation_cost = ThermalGenerationCost(nothing),
        base_power = 100.0,
        time_limits = nothing,
        prime_mover_type = PrimeMovers.CT,
        fuel = ThermalFuels.NATURAL_GAS,
    ) for i in 1:3
]
for g in gens
    add_component!(sys, g)
end

initial_time = DateTime("2024-01-01T00:00:00")
resolution = Hour(1)
timestamps = range(initial_time; length = 24, step = resolution)

time_series_transaction(sys) do txn
    for (i, g) in enumerate(gens)
        data = TimeArray(timestamps, collect(0.0:23.0) .+ (i - 1) * 100)
        add_time_series!(txn, g, SingleTimeSeries("load", data))
    end
end
```

The adds are batched into one write here — see
[Use Context Managers for Efficient Bulk Operations](@ref).

Now build a reader and step it:

```julia
reader = build_static_time_series_reader(sys; resolution = resolution, name = "load")
entries = get_static_time_series_reader_entries(reader)

for ts in first(timestamps, 3)
    read_static_time_series_values!(reader, ts)
    values = [get_static_time_series_value(reader, i) for i in eachindex(entries)]
    println(ts, "  ", values)
end
```

```
2024-01-01T00:00:00  [0.0, 100.0, 200.0]
2024-01-01T01:00:00  [1.0, 101.0, 201.0]
2024-01-01T02:00:00  [2.0, 102.0, 202.0]
```

The two-step read is deliberate: `read_static_time_series_values!` performs the storage read
for **all** entries at that timestamp, and `get_static_time_series_value` then pulls each
already-materialized value out. Calling the getter before the reader has read throws an
`ArgumentError` rather than returning stale data.

!!! warning

    Both getters take an **entry index**, not the entry itself. Index into
    `eachindex(entries)` and use the same index for both the entry and its value.

## What a reader covers

Each entry binds a stored series to its owning component, so you never have to track
iteration order yourself:

```julia
entry = entries[1]
println(get_name(entry.owner), "  ", get_name(entry.key), "  group=", entry.group)
```

```
gen1  load  group=1
```

The reader also reports the grid its series share:

```julia
println(get_static_time_series_reader_grid(reader))
```

```
StaticGrid(initial_timestamp=DateTime("2024-01-01T00:00:00"), resolution=Millisecond(3600000), length=24)
```

`resolution` is required and pins the reader to one resolution; `name` and a `features`
dictionary narrow the match further:

```julia
build_static_time_series_reader(sys; resolution = resolution, name = "load")
build_static_time_series_reader(
    sys;
    resolution = resolution,
    name = "load",
    features = Dict("scenario" => "high"),
)
```

A reader is a **snapshot** of the associations that matched when it was built. Adding or
removing time series afterwards does not change what a live reader covers — build a new one.

## Why it is faster: columnar groups

Series with the same element type are packed into one columnar group, and a group is served
by a single storage read per timestamp. [`get_num_static_time_series_groups`](@ref) reports
how many physical reads each step costs:

```julia
println(
    length(entries),
    " entries, ",
    get_num_static_time_series_groups(reader),
    " group(s)",
)
```

```
3 entries, 1 group(s)
```

Three components, one read per timestamp — and that stays one read as the fleet grows.

## Stepping through forecasts

[`build_forecast_reader`](@ref) is the forecast counterpart. `read_forecast_window!` reads
the window starting at a timestamp, and `get_forecast_window` returns each entry's window
array:

```julia
transform_single_time_series!(sys, Hour(4), Hour(1))

freader = build_forecast_reader(sys, Deterministic; resolution = resolution, name = "load")
fentries = get_forecast_reader_entries(freader)

timeline = get_forecast_reader_timeline(freader)
read_forecast_window!(freader, timeline.initial_timestamp)
for i in eachindex(fentries)
    println(get_name(fentries[i].owner), " -> ", get_forecast_window(freader, i))
end
```

```
gen1 -> [0.0, 1.0, 2.0, 3.0]
gen2 -> [100.0, 101.0, 102.0, 103.0]
gen3 -> [200.0, 201.0, 202.0, 203.0]
```

[`get_forecast_reader_timeline`](@ref) returns a *descriptor* of the valid window
timestamps, not a vector of them:

```julia
println(timeline)
```

```
ForecastTimeline(initial_timestamp=DateTime("2024-01-01T00:00:00"), resolution=Millisecond(3600000), interval=Millisecond(3600000), count=21)
```

Valid timestamps are `initial_timestamp + k * interval` for `k in 0:(count - 1)`, so
materialize them only if you need them:

```julia
window_times = [timeline.initial_timestamp + k * timeline.interval
 for k in 0:(timeline.count - 1)]
```

Reading a timestamp that is off the timeline throws.

## Shared profiles collapse to slots

Components whose forecasts are backed by the same array collapse to a single **slot**. The
store performs one physical read per slot rather than one per component, so a fleet sharing
one profile materializes one window, not N. This matters after
`transform_single_time_series!` and anywhere many components were given the same profile.

Build the same system with five generators, but give every one of them the *same* profile:

```julia
shared_profile = TimeArray(timestamps, collect(0.0:23.0))

time_series_transaction(sys2) do txn
    for g in gens2   # five ThermalStandard, constructed as above
        add_time_series!(txn, g, SingleTimeSeries("load", shared_profile))
    end
end
transform_single_time_series!(sys2, Hour(4), Hour(1))

freader2 =
    build_forecast_reader(sys2, Deterministic; resolution = resolution, name = "load")
println(length(get_forecast_reader_entries(freader2)), " entries, ",
    get_num_forecast_slots(freader2), " slot(s)")
```

```
5 entries, 1 slot(s)
```

The deduplication is exposed rather than hidden. Each entry's `slot` field tells you which
components share a read, and [`get_num_forecast_slots`](@ref) is the per-timestamp read
count.

!!! warning

    Entries in the same slot get back the **same array object**, not a copy. Treat the
    returned windows as read-only — mutating one mutates what every component in that slot
    sees.

    ```julia
    read_forecast_window!(freader2, get_forecast_reader_timeline(freader2).initial_timestamp)
    get_forecast_window(freader2, 1) === get_forecast_window(freader2, 2)  # true
    ```

## See Also

  - [Use Context Managers for Efficient Bulk Operations](@ref) — batching the adds that
    populate a system before you read it back
  - [Improve Performance with Time Series Data](@ref) — storage location, compression, and
    caching
  - [Time Series Data](@ref ts_data) — the categories of time series and how they are stored
