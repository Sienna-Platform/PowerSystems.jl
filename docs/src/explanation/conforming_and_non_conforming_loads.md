# [Conforming and Non-Conforming Loads](@id conf_loads)

The difference between conforming and non-conforming loads is not particularly significant for how PowerSystems.jl manages data, as loads can be assigned either aggregate or individual time series.

## Definitions and use cases

At its core, the distinction is about forecastability. The De Facto-Criteria and Practical Uses of this distinction comes from CAISO's Energy Imbalance Market (EIM) definitions. This section draws from the [CAISO EIM's "Non-Conforming Load FAQ"](https://www.westerneim.com/Documents/EIM-Non-Conforming-Load-FAQ.pdf) document.

Conforming loads are the typically residential and commercial loads that, in aggregate, follow a predictable daily and seasonal pattern influenced by factors like time of day, day of the week, and weather conditions. This predictability allows modelers to use aggregate forecasts of the total area load with a high degree of accuracy and then desagregate the curve using participation factors.

Non-conforming loads, on the other hand have patterns of consumption that don't follow the aggregate behavior. Their consumption does not follow typical patterns and can fluctuate with different rates as the total system load. These are often large industrial processes with unique operational cycles. For example:

  - Electric Arc Furnaces: Used in steel manufacturing, electric arc furnaces cause massive, sudden spikes in power demand when they are in operation. Depending on the time-scale of modeling these loads can require a consumption pattern that mathches the underlying industrial process.

  - Large Data Centers: While having a relatively constant base load, the computational demands of large data centers almost never change with the patterns from the rest of the system. These loads tend to be flat and in some advanced models include the behavior of compute load dispatch algorithms that conduct geographic price arbitrage.

  - Traction Loads for Railways: The movement of electric trains results in fluctuating power demand along the railway lines based on the transportation demand.

  - Pumping Loads: Similarly to tranction loads, pumping loads can change according to water or gas demand and supply needs and not system level behavior. In its data collection manuals, WECC specifies that pumping loads are typically modeled as non-conforming in power flow cases.

## Modeling using PowerSystems.jl

Drawing again from CAISO's EIM procedures, the management of non-conforming loads involves:

 1. **Segregated Data Submission**: The historical consumption data for the non-conforming load must be separated from the general, or "conforming," load data. This "cleanses" the historical data used to train weather-based load forecasting models, thereby improving their accuracy for the bulk of the system's load.

 2. **Independent Forecasting**: While the system operator forecasts the aggregate conforming load, the entity responsible for the non-conforming load is often required to submit its own forecast or schedule.

 3. **Specialized Modeling**: In market and operational models, non-conforming loads are often treated as a type of resource. For instance, in the CAISO market, they are represented as "Dispatchable Demand Response" (DDR) resources, which are essentially modeled as negative generation. This allows their behavior to be explicitly accounted for in market clearing and dispatch instructions.

If a modeler wants to account for the differences in behavior between various loads, they only need to assign a distinct time series to each load. In `PowerSystems.jl`, we keep track of data related to "conformity" for monitoring purposes. This data is defined in the `conformity` field for concrete subtypes of [`StaticLoad`](@ref) and has the [options listed here](@ref loadconform_list). However, the behavioral variations described in the literature are already taken into consideration through the ways modelers can manage these time series assignments.

### See also:

  - Parsing [time series](@ref parsing_time_series)
