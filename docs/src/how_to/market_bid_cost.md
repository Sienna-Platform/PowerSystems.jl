# [Add a Market Bid](@id market_bid_cost)

A [`MarketBidCost`](@ref) is an `OperationalCost` data structure that allows the user to run a production
cost model that is very similar to most US electricity market auctions with bids for energy
and ancillary services jointly. This page showcases how to create data for this cost function.

## Adding a Single Incremental Energy bids to MarketBidCost

### Construct directly the MarketBidCost using the `make_market_bid_curve` method.

The `make_market_bid_curve` creates an incremental or decremental offer curve from a vector of `n` power values, a vector of `n-1` marginal costs and single initial input. For example, the following code creates an incremental offer curve:

```@example market_bid_cost
using PowerSystems, Dates
proposed_offer_curve =
    make_market_bid_curve([0.0, 100.0, 105.0, 120.0, 130.0], [25.0, 26.0, 28.0, 30.0], 10.0)
```

Then a device with MarketBidCost can be directly instantiated using:

```@example market_bid_cost
using PowerSystems, Dates
bus = ACBus(1, "nodeE", true, "REF", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing)

generator = ThermalStandard(;
    name = "Brighton",
    available = true,
    status = true,
    bus = bus,
    active_power = 6.0,
    reactive_power = 1.50,
    rating = 0.75,
    prime_mover_type = PrimeMovers.ST,
    fuel = ThermalFuels.COAL,
    active_power_limits = (min = 0.0, max = 6.0),
    reactive_power_limits = (min = -4.50, max = 4.50),
    time_limits = (up = 0.015, down = 0.015),
    ramp_limits = (up = 5.0, down = 3.0),
    operation_cost = MarketBidCost(;
        no_load_cost = 0.0,
        start_up = (hot = 0.0, warm = 0.0, cold = 0.0),
        shut_down = 0.0,
        incremental_offer_curves = proposed_offer_curve,
    ),
    base_power = 100.0,
)
```

Similarly, a decremental offer curve can also be created directly using the same helper method:

```@example market_bid_cost
using PowerSystems, Dates
decremental_offer =
    make_market_bid_curve([0.0, 100.0, 105.0, 120.0, 130.0], [30.0, 28.0, 26.0, 25.0], 50.0)
```

and can be added to a `MarketBidCost` using the field `decremental_offer_curves`.

## Adding Time Series Energy bids to MarketBidCost

### Step 1: Constructing device with MarketBidCost

When using [`MarketBidCost`](@ref), the user can add the cost struct to the device specifying
only certain elements, at this point the actual energy cost bids don't need to be populated/passed.

The code below shows an example how we can create a thermal device with MarketBidCost.

```@example market_bid_cost
using PowerSystems, Dates
bus = ACBus(1, "nodeE", true, "REF", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing)

generator = ThermalStandard(;
    name = "Brighton",
    available = true,
    status = true,
    bus = bus,
    active_power = 6.0,
    reactive_power = 1.50,
    rating = 0.75,
    prime_mover_type = PrimeMovers.ST,
    fuel = ThermalFuels.COAL,
    active_power_limits = (min = 0.0, max = 6.0),
    reactive_power_limits = (min = -4.50, max = 4.50),
    time_limits = (up = 0.015, down = 0.015),
    ramp_limits = (up = 5.0, down = 3.0),
    operation_cost = MarketBidCost(;
        no_load_cost = 0.0,
        start_up = (hot = 0.0, warm = 0.0, cold = 0.0),
        shut_down = 0.0,
    ),
    base_power = 100.0,
)
```

### Step 2: Creating the `TimeSeriesData` for the Market Bid

The user is expected to pass the [`TimeSeriesData`](@ref) that holds the energy bid data which can be
of any type (i.e. [`SingleTimeSeries`](@ref) or [`Deterministic`](@ref D)) and data must be `PiecewiseStepData`.
This data type is created by specifying a vector of `n` powers, and `n-1` marginal costs.
The data must be specified in natural units, that is power in MW and marginal cost in $/MWh
or it will not be accepted when adding to the system.
Code below shows an example of how to build a Deterministic TimeSeries.

```@example market_bid_cost
initial_time = Dates.DateTime("2020-01-01")
psd1 = PiecewiseStepData([5.0, 7.33, 9.67, 12.0], [2.901, 5.8272, 8.941])
psd2 = PiecewiseStepData([5.0, 7.33, 9.67, 12.0], [3.001, 6.0072, 9.001])
data =
    Dict(
        initial_time => [
            psd1,
            psd2,
        ],
    )
time_series_data = Deterministic(;
    name = "variable_cost",
    data = data,
    resolution = Dates.Hour(1),
)
```

### Step 3a: Adding Energy Bid TimeSeriesData to the device

To add energy market bids time-series to the `MarketBidCost`, use [`set_variable_cost!`](@ref). The
arguments for [`set_variable_cost!`](@ref) are:

  - `sys::System`: PowerSystem System
  - `component::StaticInjection`: Static injection device
  - `time_series_data::TimeSeriesData`: TimeSeriesData
  - `power_units::UnitSystem`: UnitSystem

Currently, time series data only supports [natural units](@ref per_unit) for time series data, i.e. MW for power and $/MWh for marginal costs.

```@example market_bid_cost
sys = System(100.0, [bus], [generator])
set_variable_cost!(sys, generator, time_series_data, UnitSystem.NATURAL_UNITS)
```

**Note:** `set_variable_cost!` add curves to the `incremental_offer_curves` in the MarketBidCost.
Similarly, `set_incremental_variable_cost!` can be used to add curves to the `incremental_offer_curves`.
On the other hand, `set_decremental_variable_cost!` must be used to decremental curves (usually for storage or demand).
The creation of the TimeSeriesData is similar to Step 2, using `PiecewiseStepData`

### Step 3b: Adding Service Bid TimeSeriesData to the device

Similar to adding energy market bids, for adding bids for ancillary services, use
`set_service_bid!`.

```@example market_bid_cost
service = VariableReserve{ReserveUp}("example_reserve", true, 0.6, 2.0)
add_service!(sys, service, get_component(ThermalStandard, sys, "Brighton"))

psd3 = PiecewiseStepData([0.0, 10.0], [650.3])
psd4 = PiecewiseStepData([0.0, 10.0], [750.0])
data = Dict(Dates.DateTime("2020-01-01") => [psd3, psd4])
time_series_data = Deterministic(;
    name = get_name(service),
    data = data,
    resolution = Dates.Hour(1),
)
set_service_bid!(sys, generator, service, time_series_data, UnitSystem.NATURAL_UNITS)
```
