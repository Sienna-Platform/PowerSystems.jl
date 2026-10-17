# # Working with Time Series Data
# In this tutorial, we will manually add, retrieve, and inspect time-series data in
# different formats, including identifying which components in a power [`System`](@ref) have time
# series data. Along the way, we will also use workarounds for missing forecast data and
# reuse identical time series profiles to avoid unnecessary memory usage.
# For a conceptual overview of how time series data is structured in `PowerSystems.jl`,
# see [Time Series Data](@ref ts_data).

# ## Example Data and Setup
# We will make an example [`System`](@ref) with a wind generator, a gas [`ThermalStandard`](@ref),
# and two loads, then add the time series needed to model, for example, wind forecast
# uncertainty, time-varying fuel prices, and a planned generator outage.
# Here is the available data:
# ```@raw html
# <img src="../../assets/time_series_tutorial.png" width="100%"/>
# ```
# For the wind generator, we have the historical point (deterministic) forecasts of power
# output. The forecasts were generated every 30 minutes with a 5-minute [resolution](@ref R)
# and 1-hour [horizon](@ref H). We also have
# measurements of what actually happened at 5-minute resolution over the 2 hours.
# For the gas generator, we have natural-gas fuel prices ($/GJ) at 5-minute resolution (for illustrative purposes only) over
# the same 2-hour window. Later we will add a planned-outage schedule that takes the unit
# out of service during the second hour.
# For the loads, note that the forecast data is missing. We only have the historical
# measurements of total load for the system, which is normalized to the system's peak load.
# Load the `PowerSystems`, `Dates`, and `TimeSeries` packages to get started:

using PowerSystems
using Dates
using TimeSeries

# As usual, we need to define a power [`System`](@ref) that holds all our data. Let's define
# a simple system with a bus, a wind generator, a gas thermal unit with a time-invariant
# cost (see [Adding an Operating Cost](@ref cost_how_to)), and two loads:

system = System(100.0); # 100 MVA base power
bus1 = ACBus(;
    number = 1,
    name = "bus1",
    available = true,
    bustype = ACBusTypes.REF,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.9, max = 1.05),
    base_voltage = 230.0,
);
wind1 = RenewableDispatch(;
    name = "wind1",
    available = true,
    bus = bus1,
    active_power = 0.0, # Per-unitized by device base_power
    reactive_power = 0.0, # Per-unitized by device base_power
    rating = 1.0, # 10 MW per-unitized by device base_power
    prime_mover_type = PrimeMovers.WT,
    reactive_power_limits = (min = 0.0, max = 0.0), # per-unitized by device base_power
    power_factor = 1.0,
    operation_cost = RenewableGenerationCost(nothing),
    base_power = 10.0, # MVA
);
load1 = PowerLoad(;
    name = "load1",
    available = true,
    bus = bus1,
    active_power = 0.0, # Per-unitized by device base_power
    reactive_power = 0.0, # Per-unitized by device base_power
    base_power = 10.0, # MVA
    max_active_power = 1.0, # 10 MW per-unitized by device base_power
    max_reactive_power = 0.0,
);
load2 = PowerLoad(;
    name = "load2",
    available = true,
    bus = bus1,
    active_power = 0.0, # Per-unitized by device base_power
    reactive_power = 0.0, # Per-unitized by device base_power
    base_power = 30.0, # MVA
    max_active_power = 1.0, # 30 MW per-unitized by device base_power
    max_reactive_power = 0.0,
);
heat_rate_curve = PiecewisePointCurve([
    (5.0, 7.0),
    (15.0, 8.0),
    (25.0, 9.0),
])
fuel_curve = FuelCurve(; value_curve = heat_rate_curve, fuel_cost = 5.0)
thermal_cost = ThermalGenerationCost(;
    variable = fuel_curve,
    fixed = 0.0,
    start_up = 0.0,
    shut_down = 0.0,
)
gas1 = ThermalStandard(;
    name = "gas1",
    available = true,
    status = true,
    bus = bus1,
    active_power = 0.0,
    reactive_power = 0.0,
    rating = 1.0,
    active_power_limits = (min = 0.2, max = 1.0),
    reactive_power_limits = nothing,
    ramp_limits = (up = 0.2, down = 0.2),
    operation_cost = thermal_cost,
    base_power = 25.0,
    time_limits = (up = 1.0, down = 1.0),
    must_run = false,
    prime_mover_type = PrimeMovers.CC,
    fuel = ThermalFuels.NATURAL_GAS,
)
add_components!(system, [bus1, wind1, gas1, load1, load2])

# Recall that we can also set the [`System`](@ref)'s unit base to natural units (MW)
# to make it easier to inspect results:

set_units_base_system!(system, "NATURAL_UNITS")

# Before we get started, recall that we also can see a summary of the system by printing it:

system

# Observe that there is no mention of time series data in the system yet.
# # Add and Retrieve a Single Time Series

# Define shared time stamps with 5-minute
# [resolution](@ref R) for the 2-hour window, which will be reused across our time series:

resolution = Dates.Minute(5)
timestamps = range(DateTime("2020-01-01T08:00:00"); step = resolution, length = 24)

# ### Fuel cost (cost-specific API)
# Start with fuel prices for `gas1`. Build the [`SingleTimeSeries`](@ref) using
# a `TimeSeries.TimeArray` of input data:

fuel_cost_values = [
    4.5, 4.6, 4.7, 4.8, 5.0, 5.2, 5.5, 5.8, 6.0, 6.2, 6.5, 6.8,
    7.0, 7.0, 6.8, 6.5, 6.2, 6.0, 5.8, 5.5, 5.2, 5.0, 4.8, 4.6,
]
fuel_cost_timearray = TimeArray(timestamps, fuel_cost_values)
fuel_cost_ts = SingleTimeSeries(; name = "gas_price", data = fuel_cost_timearray)

# !!! tip
#     This 2-hour window illustrates the API. Production cost models typically use longer
#     horizons (for example, hourly fuel prices over a full day).

# So far, this time series has been defined, but not attached to our [`System`](@ref) in any way.
# Attach with [`set_fuel_cost!`](@ref) because `gas1` uses a [`FuelCurve`](@ref) in its
# [`ThermalGenerationCost`](@ref):

set_fuel_cost!(system, gas1, fuel_cost_ts)

# Notice that `fuel_cost` now points to a key with the same name we defined above: "gas_price".

# Retrieve the profile with [`get_fuel_cost`](@ref) (values are in \$/GJ; multiply by the heat rate for \$/MWh):

get_fuel_cost(gas1; start_time = DateTime("2020-01-01T08:00:00"))

# ### Wind measurements (component-field API)
# A single time-varying profile is always built the same way. What differs is *where* and
# *how* you attach the data. We just attached one to a cost structure, and now we'll attach
# one to a component field.

# First, print `wind1` to see its data:

wind1

# See the `has_time_series` field at the bottom is `false`.
# Now, use same construction pattern above to define the wind output measurements:

wind_values = [6.0, 7, 7, 6, 7, 9, 9, 9, 8, 8, 7, 6, 5, 5, 5, 5, 5, 6, 6, 6, 7, 6, 7, 7]
wind_timearray = TimeArray(timestamps, wind_values)
wind_time_series = SingleTimeSeries(;
    name = "max_active_power",
    data = wind_timearray,
)

# Note that we've chosen the name `max_active_power`, which is the default time series profile
# name when using
# [PowerSimulations.jl](https://sienna-platform.github.io/PowerSimulations.jl/stable/formulation_library/RenewableGen/)
# for simulations.
# Attach to `wind1` with [`add_time_series!`](@ref add_time_series!(sys::System, component::Component, time_series::TimeSeriesData; features...)):

add_time_series!(system, wind1, wind_time_series)

# Let's double-check this worked by calling [`show_time_series`](@ref):

show_time_series(wind1)

# Now `wind1` has its first time-series data set. Recall that you can also print `wind1` and
# check the `has_time_series` field like we did above.
# Finally, let's retrieve and inspect the new timeseries, using [`get_time_series_array`](@ref get_time_series_array(time_series_type::Type{<:TimeSeriesData}, component::Component, time_series_name::String; kwargs...)):

get_time_series_array(SingleTimeSeries, wind1, "max_active_power")

# Verify this matches your expectation based on the input data.
# # Add and Retrieve a Forecast
# Next, let's add the wind power forecasts. We will use a [`Deterministic`](@ref) format for
# the point forecasts.
# Because we have forecasts with at different [initial times](@ref I), the input data must be
# a dictionary where the keys are the initial times and the values are vectors or
# `TimeSeries.TimeArray`s of the forecast data.
# Set up the example input data:

wind_forecast_data = Dict(
    DateTime("2020-01-01T08:00:00") => [5.0, 6, 7, 7, 7, 8, 9, 10, 10, 9, 7, 5],
    DateTime("2020-01-01T08:30:00") => [9.0, 9, 9, 9, 8, 7, 6, 5, 4, 5, 4, 4],
    DateTime("2020-01-01T09:00:00") => [6.0, 6, 5, 5, 4, 5, 6, 7, 7, 7, 6, 6],
);

# Define the [`Deterministic`](@ref) forecast and attach it to `wind1`:

wind_forecast = Deterministic("max_active_power", wind_forecast_data, resolution);
add_time_series!(system, wind1, wind_forecast);

# Let's call `show_time_series` once again:

show_time_series(wind1)

# Notice that we now have two types of time series listed -- the single time series and
# the forecasts.
# Finally, let's retrieve the forecast data to double check it was added properly, specifying
# the initial time to get the 2nd forecast window starting at 8:30:

get_time_series_array(
    Deterministic,
    wind1,
    "max_active_power";
    start_time = DateTime("2020-01-01T08:30:00"),
)

# # Add A Time Series Using Scaling Factors
# Let's add the load time series. Recall that this data is normalized to the peak system
# power, so we'll use it to scale both of our loads. We call normalized time series data
# *scaling factors*.
# First, let's create our input data `TimeSeries.TimeArray` with the example data and the same
# time stamps we used in the wind time series:

load_values = [0.3, 0.3, 0.3, 0.3, 0.4, 0.4, 0.4, 0.4, 0.5, 0.5, 0.6, 0.6,
    0.7, 0.8, 0.8, 0.8, 0.8, 0.8, 0.9, 0.8, 0.8, 0.8, 0.8, 0.8];
load_timearray = TimeArray(timestamps, load_values);

# Again, define a [`SingleTimeSeries`](@ref), but this time use the
# `scaling_factor_multiplier` parameter to scale this time series from
# normalized values to power values:

load_time_series = SingleTimeSeries(;
    name = "max_active_power",
    data = load_timearray,
    scaling_factor_multiplier = get_max_active_power,
);

# Notice that we assigned the
# [`get_max_active_power`](@ref get_max_active_power(value::PowerLoad)) *function*
# to scale the time series, rather than a value, making the time series reusable for multiple
# components or multiple fields in a component. Note that the values are normalized using
# each device's `max_active_power` parameter, not the system-wide `base_power`.
# Now, add the scaling factor time series to both loads to save memory and avoid data
# duplication:

add_time_series!(system, [load1, load2], load_time_series);

# Let's take a look at `load1`, including printing its parameters...

load1

# ...as well as its time series:

show_time_series(load1)

# !!! tip "Important"
#     Notice that each load now has two references to `max_active_power`. This is intentional.
#     There is the parameter, `max_active_power`, which is  the
#     maximum demand of each load at any time (10 MW or 30 MW). There is also
#     `max_active_power` the time series, which is the time varying demand over the 2-hour
#     window, calculated using the scaling factors and the `max_active_power` parameter.
#     This means that if we change the `max_active_power` parameter, the time series will
#     also change when we retrieve it! This is also true when we apply the same scaling factors
#     to multiple components or parameters.
# Let's check the impact that these two `max_active_power` data sources have on the times
# series data when we retrieve it. Get the `max_active_power` time series for `load1`:

get_time_series_array(SingleTimeSeries, load1, "max_active_power") # in MW

# See that the normalized values have been scaled up by 10 MW.
# Now let's look at `load2`. First check its `max_active_power` parameter:

get_max_active_power(load2)

# This has a higher peak maximum demand of 30 MW.
# Next, retrieve its `max_active_power` time series:

get_time_series_array(SingleTimeSeries, load2, "max_active_power") # in MW

# Observe the difference compared to `load1`'s time series.
# Finally, retrieve the underlying time series data with no scaling factor multiplier
# applied:

get_time_series_array(SingleTimeSeries,
    load2,
    "max_active_power";
    ignore_scaling_factors = true,
)

# Notice that this is the normalized input data, which is still being stored underneath. Each
# load is using a reference to that data when we call `get_time_series_array` to avoid
# unnecessary data duplication.
# # Transform a [`SingleTimeSeries`](@ref) into a Forecast
# Finally, let's use a workaround to handle the missing load forecast data. We will assume a
# perfect forecast where the forecast is based on the [`SingleTimeSeries`](@ref) we just added.
# Rather than unnecessarily duplicating and reformatting data, use PowerSystems.jl's dedicated
# [`transform_single_time_series!`](@ref) function to generate a [`DeterministicSingleTimeSeries`](@ref),
# which saves memory while behaving just like a [`Deterministic`](@ref) forecast.
# Before we call `transform_single_time_series!`, we need to remove the [`SingleTimeSeries`](@ref) from
# the wind component. This is because the wind component already has a [`Deterministic`](@ref) forecast
# with the name `"max_active_power"`, and having both a [`Deterministic`](@ref) and a
# [`DeterministicSingleTimeSeries`](@ref) with the same name is not allowed. If we tried to keep both,
# functions like `get_time_series` wouldn't know which forecast to retrieve when you request
# `"max_active_power"`. Let's remove the [`SingleTimeSeries`](@ref) to avoid this conflict:

remove_time_series!(system, SingleTimeSeries, wind1, "max_active_power");

# Now we can transform the remaining [`SingleTimeSeries`](@ref) (the ones attached to the loads):

transform_single_time_series!(
    system,
    Dates.Hour(1), # horizon
    Dates.Minute(30), # interval
);

# Let's see the results for `load1`'s time series summary:

show_time_series(load1)

# Notice we now have a load forecast data set with the resolution, horizon, and, interval
# matching our wind forecasts.
# Retrieve the first forecast window:

get_time_series_array(
    DeterministicSingleTimeSeries,
    load1,
    "max_active_power";
    start_time = DateTime("2020-01-01T08:00:00"),
)

# See that `load1`'s scaling factor multiplier is still being applied as expected.
# # Transform with Multiple Intervals
# PowerSystems supports creating multiple forecast transforms from the same
# [`SingleTimeSeries`](@ref), each with a different [interval](@ref I). This is useful when
# a component needs forecasts updated at different frequencies.
# Use `delete_existing = false` to preserve the existing transform and add a second one
# with a different interval:

transform_single_time_series!(
    system,
    Dates.Hour(1), # horizon
    Dates.Hour(1); # a longer interval
    delete_existing = false,
);

# Now `load1` has two [`DeterministicSingleTimeSeries`](@ref) forecasts with different
# intervals. Let's verify:

show_time_series(load1)

# When multiple intervals exist for the same name, you must specify `interval` to
# disambiguate retrieval:

get_time_series_array(
    DeterministicSingleTimeSeries,
    load1,
    "max_active_power";
    start_time = DateTime("2020-01-01T08:00:00"),
    interval = Dates.Minute(30),
)

# You can also query forecast parameters for a specific interval:

get_forecast_horizon(system; interval = Dates.Hour(1))

#

get_forecast_interval(system; interval = Dates.Minute(30))

# To selectively remove one interval's forecasts while keeping the other:

remove_time_series!(
    system,
    DeterministicSingleTimeSeries,
    load1,
    "max_active_power";
    interval = Dates.Hour(1),
)

# You can also query the system-wide forecast parameters:

get_forecast_horizon(system)

#

get_forecast_interval(system)

# # Add Time Series to Supplemental Attributes
# So far, we attached time series to **component fields** (`wind1`, loads) or **cost data**.
# Now we'll attach time series to a [`SupplementalAttribute`](@ref), which is
# contextual metadata linked to components but stored outside their electrical definitions.

# Here we add a [`PlannedOutage`](@ref) schedule on `gas1`. Create the attribute and attach it
# to the generator with [`add_supplemental_attribute!`](@ref add_supplemental_attribute!(sys::System, component::Component, attribute::IS.SupplementalAttribute)):

planned = PlannedOutage(; outage_schedule = "outage_schedule")
add_supplemental_attribute!(system, gas1, planned)

# Now we can attach the time series to the **outage attribute** (not to `gas1`) with
# [`add_time_series!`](@ref add_time_series!(sys::System, component::Component, time_series::TimeSeriesData; features...)):

outage_values = vcat(zeros(12), ones(12))  # in service first hour, outaged second hour
outage_timearray = TimeArray(timestamps, outage_values)
outage_ts = SingleTimeSeries(; name = "outage_schedule", data = outage_timearray)
add_time_series!(system, planned, outage_ts)

# Retrieve from the outage attribute with [`get_time_series_array`](@ref get_time_series_array(time_series_type::Type{<:TimeSeriesData}, component::Component, time_series_name::String; kwargs...)) -- 
# values are `0.0` (in service) or `1.0` (outaged):

get_time_series_array(SingleTimeSeries, planned, "outage_schedule")

# See [Supplemental attributes](@ref supplemental_attributes_explanation) and
# [Manipulating Data Sets](@ref "Manipulating Datasets") for general attach and query patterns.

# # Finding, Retrieving, and Inspecting Time Series
# Now, let's complete this tutorial by doing a few sanity checks on the data that we've added,
# where are we will also examine components with time series and retrieve
# the time series data in a few more ways.
# Recall we can print the [`System`](@ref) to summarize the data in our system:

system

# Notice that new tables have been added, showing the count of
# each Type of component that has a given time series type. As expected from the earlier
# removal, `wind1` has only its [`Deterministic`](@ref) forecast and no
# [`DeterministicSingleTimeSeries`](@ref).
# Finally, let's do a last data sanity check on the forecasts. Since we defined the wind
# time series in MW instead of scaling factors, let's make sure none of our forecasts exceeds
# the `max_active_power` parameter.
# Instead of using `get_time_series_array` where we need to remember some details of
# the time series we're looking up, let's use [`get_time_series_keys`](@ref) to refresh our
# memories:

keys = get_time_series_keys(wind1)

# See the forecast key is first, so let's retrieve it using [`get_time_series`](@ref):

forecast = get_time_series(wind1, keys[1])

# See that unlike when we used `get_time_series_array`, this returns an object we can
# manipulate.
# Use [`iterate_windows`](@ref) to cycle through the 3 forecast windows and inspect the peak
# value:

for window in iterate_windows(forecast)
    @show values(maximum(window))
end

# Finally, use [`get_max_active_power`](@ref get_max_active_power(d::RenewableGen)) to
# check the expected maximum:

get_max_active_power(wind1)

# See that the forecasts are not exceeding this maximum -- sanity check complete.
# !!! tip
#     Unlike [`PowerLoad`](@ref) components, [`RenewableDispatch`](@ref) components do not have a
#     `max_active_power` field, so check
#     [`get_max_active_power`](@ref get_max_active_power(d::RenewableGen))
#     to see how its calculated.
# ## Getting Timestamps and Values Separately
# When working with a retrieved time series object, you can extract the timestamps and
# values independently rather than always working with the combined `TimeArray`.
# Use [`get_time_series_timestamps`](@ref) to get just the timestamps for a time series:

get_time_series_timestamps(SingleTimeSeries, load1, "max_active_power")

# Use [`get_time_series_values`](@ref) to get just the numeric values. Note the
# scaling factor multiplier is still applied:

get_time_series_values(SingleTimeSeries, load1, "max_active_power")

# The same functions work for forecasts -- just pass a `start_time` to select the window:

get_time_series_timestamps(
    Deterministic,
    wind1,
    "max_active_power";
    start_time = DateTime("2020-01-01T08:00:00"),
)

get_time_series_values(
    Deterministic,
    wind1,
    "max_active_power";
    start_time = DateTime("2020-01-01T08:00:00"),
)

# ## Inspecting Time Series Metadata
# Rather than retrieving the full data, you can inspect the structural metadata of a time
# series object returned by [`get_time_series`](@ref).
# Let's retrieve the wind forecast object again and inspect its properties:

forecast = get_time_series(wind1, keys[1])

# Get the [resolution](@ref R) (time step between values):

get_resolution(forecast)

# Get the [horizon](@ref H) (total duration of one forecast window):

get_horizon(forecast)

# Similarly, for the load [`SingleTimeSeries`](@ref):

sts = get_time_series(SingleTimeSeries, load1, "max_active_power")
get_resolution(sts)

# # Next Steps
# In this tutorial, you defined, added, and retrieved time series on component fields,
# cost data, and supplemental attributes, including deterministic forecasts. Along the way,
# we reduced data duplication using normalized scaling factors and
# [`transform_single_time_series!`](@ref) to address missing load forecast data.
# Next you might like to:
#   - [Parse many timeseries data sets from CSV's](@ref parsing_time_series)
#   - [See how to improve performance efficiency with your own time series data](@ref improve_ts_performance)
#   - [Review the available time series data formats](@ref ts_data)
#   - [Learn more about how times series data is stored](@ref "Data Storage")
#   - [Add Time Series Fuel Cost Data](@ref fuel_curve_timeseries) — fuel curves in depth
