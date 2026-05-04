# [Conforming and Non-Conforming Loads](@id conf_loads)

At its core, the distinction between conforming and non-conforming loads is about
forecastability. The definitions and practical criteria used here draw from the
[CAISO EIM's "Non-Conforming Load FAQ"](https://www.westerneim.com/Documents/EIM-Non-Conforming-Load-FAQ.pdf).

**Conforming loads** are typically residential and commercial loads that, in aggregate,
follow a predictable daily and seasonal pattern influenced by time of day, day of the week,
and weather conditions. This predictability allows modelers to use aggregate forecasts of
the total area load with a high degree of accuracy and then disaggregate the curve using
participation factors.

**Non-conforming loads** have consumption patterns that don't follow the aggregate system
behavior and can fluctuate independently of the total system load. These are often large
industrial processes with unique operational cycles, for example:

  - **Electric Arc Furnaces:** Used in steel manufacturing, electric arc furnaces cause
    massive, sudden spikes in power demand when in operation. Depending on the time-scale
    of modeling, these loads can require a consumption pattern that matches the underlying
    industrial process.

  - **Large Data Centers:** While having a relatively constant base load, the computational
    demands of large data centers almost never change with the patterns of the rest of the
    system. These loads tend to be flat and in some advanced models include the behavior of
    compute load dispatch algorithms that conduct geographic price arbitrage.

  - **Traction Loads for Railways:** The movement of electric trains results in fluctuating
    power demand along railway lines based on transportation demand.

  - **Pumping Loads:** Pumping loads can change according to water or gas demand and supply
    needs rather than system-level behavior. [WECC](@ref W) specifies in its data collection manuals
    that pumping loads are typically modeled as non-conforming in power flow cases.

## Modeling using PowerSystems.jl

In practice — following conventions established by markets such as
[CAISO's EIM](https://www.westerneim.com/Documents/EIM-Non-Conforming-Load-FAQ.pdf) —
non-conforming loads are handled differently from conforming ones in three key ways:
their historical data is segregated from the aggregate load before training forecast models;
they are forecasted or scheduled independently rather than by disaggregating an area
forecast; and in some market contexts they are represented as dispatchable negative
generation rather than passive demand. This is also known as "Dispatchable Demand Response" (DDR) in the CAISO market.

In `PowerSystems.jl`, these distinctions surface in two places:

 1. **The `conformity` field.** Concrete subtypes of [`StaticLoad`](@ref) carry a
    `conformity` field that records whether a load is conforming or non-conforming (see the
    [options listed here](@ref loadconform_list)). This field exists for monitoring and
    bookkeeping purposes — it allows downstream tools and analysts to identify which loads
    were treated as non-conforming without needing to inspect the time series data directly.

 2. **Time series assignment.** The behavioral difference between conforming and
    non-conforming loads is expressed through time series. A conforming load typically
    shares an aggregate area forecast that is then scaled by a participation factor; a
    non-conforming load carries its own individual time series. `PowerSystems.jl` supports
    both patterns equally — the `conformity` flag declares the intent, while the time series
    assignment carries it out.

This design means that modeling the distinction requires no special data structures or
separate code paths: assigning a distinct time series to a non-conforming load is
sufficient to capture its independent behavior.

### See also

  - [Parsing time series](@ref parsing_time_series)
