# [Add Time Series Fuel Cost Data](@id fuel_curve_timeseries)

This how-to guide demonstrates how to add time-varying fuel costs to a thermal generator
that uses a [`ThermalGenerationCost`](@ref) with a [`FuelCurve`](@ref). This is useful when
fuel prices vary over time, such as with natural gas prices that change throughout the day
or across seasons.

```@setup fuelcosts
using PowerSystems
using Dates
using TimeSeries
using DataStructures: SortedDict

# Create a bus
bus = ACBus(;
    number = 1,
    name = "bus1",
    available = true,
    bustype = ACBusTypes.REF,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.9, max = 1.1),
    base_voltage = 230.0,
)

# Define the heat rate curve
heat_rate_curve = PiecewisePointCurve([
    (100.0, 7.0),   # At 100 MW: 7 GJ/MWh
    (200.0, 8.0),   # At 200 MW: 8 GJ/MWh
    (300.0, 9.5),   # At 300 MW: 9.5 GJ/MWh
])

# Create a FuelCurve with an initial scalar fuel cost
fuel_curve = FuelCurve(;
    value_curve = heat_rate_curve,
    fuel_cost = 5.0,  # Initial fuel cost: $5.0/GJ
)

# Create the ThermalGenerationCost
thermal_cost = ThermalGenerationCost(;
    variable = fuel_curve,
    fixed = 10.0,
    start_up = 5000.0,
    shut_down = 2000.0,
)

# Create the thermal generator
generator = ThermalStandard(;
    name = "generator1",
    available = true,
    status = true,
    bus = bus,
    active_power = 250.0,
    reactive_power = 50.0,
    rating = 300.0,
    prime_mover_type = PrimeMovers.ST,
    fuel = ThermalFuels.NATURAL_GAS,
    active_power_limits = (min = 50.0, max = 300.0),
    reactive_power_limits = (min = -50.0, max = 100.0),
    ramp_limits = (up = 5.0, down = 5.0),
    time_limits = (up = 2.0, down = 1.0),
    operation_cost = thermal_cost,
    base_power = 100.0,
)

# Create the system and add components
sys = System(100.0)
add_component!(sys, bus)
add_component!(sys, generator)
```

## Overview

This guide assumes you have already defined a [`System`](@ref) with a thermal generator (e.g., [`ThermalStandard`](@ref)) that has a
[`ThermalGenerationCost`](@ref) containing a [`FuelCurve`](@ref). The generator's
`FuelCurve` must specify a heat rate curve (fuel consumption at different power outputs)
and an initial scalar fuel cost value, which will be replaced with time series data.

To add time-varying fuel costs, you need to:

 1. **Create time series fuel cost data**: Prepare your fuel price data as either
    [`SingleTimeSeries`](@ref) (for simple time-varying data like historical prices) or
    [`Deterministic`](@ref) (for forecast windows used in day-ahead scheduling with rolling
    horizons).

 2. **Attach the time series to the generator**: Use the [`set_fuel_cost!`](@ref) function
    to attach the time series data to the generator component. The component must already
    be added to the system before attaching time series.

 3. **Verify and retrieve the data**: Use [`get_fuel_cost`](@ref) to retrieve the time
    series data and verify it was attached correctly.

**Key requirements:**

  - The generator must use a [`FuelCurve`](@ref) (not a [`CostCurve`](@ref)) in its
    [`ThermalGenerationCost`](@ref) to enable time series fuel costs
  - Time series resolution should match your simulation resolution (e.g., Hour(1) for
    hourly simulations)
  - Fuel cost units should be in \$/GJ (or \$/MBtu, etc.) and heat rate in GJ/MWh (or
    MBtu/MWh); their product gives the effective cost in \$/MWh

## Step 1: Create Time Series Fuel Cost Data

Create time series data representing fuel costs that vary throughout the day. This example
uses hourly natural gas prices with [`SingleTimeSeries`](@ref):

```@repl fuelcosts
# Define the initial time and resolution
initial_time = DateTime("2024-01-01T00:00:00")
resolution = Hour(1)

# Create hourly fuel cost data for 24 hours
# Prices are higher during peak hours (midday to early evening) and lower at night
fuel_cost_data = [
    4.5, 4.3, 4.2, 4.1, 4.2, 4.5,  # 00:00 - 05:00 (low overnight prices)
    5.0, 5.5, 6.0, 6.5, 7.0, 7.5,  # 06:00 - 11:00 (morning ramp)
    8.0, 8.0, 7.8, 7.8, 7.5, 7.0,  # 12:00 - 17:00 (afternoon peak)
    6.5, 6.0, 5.5, 5.0, 4.8, 4.6,  # 18:00 - 23:00 (evening decline)
]

# Create timestamps for each data point
timestamps =
    collect(initial_time:resolution:(initial_time + Hour(length(fuel_cost_data) - 1)))

# Create a TimeArray with timestamps and data
time_array = TimeArray(timestamps, fuel_cost_data)

# Create a SingleTimeSeries from the TimeArray
fuel_cost_timeseries = SingleTimeSeries(;
    name = "fuel_cost",
    data = time_array,
)
```

## Step 2: Attach Time Series to the Generator

Use the [`set_fuel_cost!`](@ref) function to attach the time series data to your
previously defined [`System`](@ref) and generator (e.g., [`ThermalStandard`](@ref)):

```@repl fuelcosts
# Add the time series fuel cost to the generator
set_fuel_cost!(sys, generator, fuel_cost_timeseries)
```

## Step 3: Verify and Retrieve Time Series Data

Now the generator has time-varying fuel costs. You can retrieve the time series data:

```@repl fuelcosts
# Get the fuel cost time series starting at the initial time
fuel_forecast = get_fuel_cost(generator; start_time = initial_time)

# Display the first few values
first(TimeSeries.values(fuel_forecast), 6)
```

You can also query for a specific time window:

```@repl fuelcosts
# Get fuel costs for a specific 12-hour period starting at 6 AM
morning_time = DateTime("2024-01-01T06:00:00")
fuel_forecast_morning = get_fuel_cost(generator; start_time = morning_time, len = 12)

# Display these values
TimeSeries.values(fuel_forecast_morning)
```

## See Also

  - [Add an Operating Cost](@ref cost_how_to) - General guide for adding operational costs
  - [Parse Time Series Data from .csv files](@ref parsing_time_series) - How to load time series from CSV files
  - [Working with Time Series Data](@ref tutorial_time_series) - Tutorial on time series data in PowerSystems
  - [`ThermalGenerationCost`](@ref) - API reference for thermal generation costs
  - [`FuelCurve`](@ref) - API reference for fuel curves
