# [Modeling with JuMP](@id modeling_with_jump)

This guide is for users who are interested in writing custom optimization problems directly in [JuMP](https://jump.dev/JuMP.jl/stable/), using data formatted with `PowerSystems.jl`. Check out [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/stable/) for developing reusable templates for optimization problems within the Sienna platform.

This page shows a minimal example to develop a Economic Dispatch model. The code shows the stages to develop modeling code:

 1. Make the data set from power flow and time series data,
 2. Serialize the system data,
 3. Pass the data and algorithm to the model.

One of the main uses of `PowerSystems.jl` is not having re-run the data generation for every model execution. The model code shows an example of populating the constraints and cost functions using getter functions inside the model function. The example concludes by reading the data created earlier and passing the algorithm with the data.

Start by loading required packages:

```@example using_jump
using PowerSystems
using JuMP
using Ipopt
using PowerSystemCaseBuilder
using Dates
```

For this example, we'll load an existing data set using
[`PowerSystemCaseBuilder.jl`](https://nrel-sienna.github.io/PowerSystemCaseBuilder.jl/stable),
which is a helper library that makes it easier to reproduce examples.
Normally you would pass your local files to create the system data instead of calling the function `build_system`.
We also use [`transform_single_time_series!`](@ref) to format time-series data as forecasts for
this problem:

```@example using_jump
system_data = build_system(PSISystems, "c_sys5_pjm")
transform_single_time_series!(system_data, Hour(24), Hour(24))
```

Next, we define the custom optimization problem using [`JuMP`](https://jump.dev/JuMP.jl/stable/)'s syntax.
The constraints include each generator's minimum and maximum active power output as well as the system power balance equation, minimizing the operating cost for each step in the 24-hour horizon:

```@example using_jump
function ed_model(system::System, optimizer, load_scaling_factor::Float64 = 1.0)
    ed_m = Model(optimizer)
    time_periods = 1:24
    thermal_gens_names = get_name.(get_components(ThermalStandard, system))
    @variable(ed_m, pg[g in thermal_gens_names, t in time_periods] >= 0)

    for g in get_components(ThermalStandard, system), t in time_periods
        name = get_name(g)
        @constraint(ed_m, pg[name, t] >= get_active_power_limits(g).min)
        @constraint(ed_m, pg[name, t] <= get_active_power_limits(g).max)
    end

    net_load = zeros(length(time_periods))
    for g in get_components(RenewableGen, system)
        net_load -=
            get_time_series_values(SingleTimeSeries, g, "max_active_power")[time_periods]
    end

    for g in get_components(StaticLoad, system)
        net_load +=
            get_time_series_values(SingleTimeSeries, g, "max_active_power")[time_periods]
    end

    for t in time_periods
        @constraint(
            ed_m,
            sum(pg[g, t] for g in thermal_gens_names) == load_scaling_factor * net_load[t]
        )
    end

    @objective(
        ed_m,
        Min,
        sum(
            pg[get_name(g), t] *
            get_proportional_term(get_function_data(get_variable(get_operation_cost(g))))
            for g in get_components(ThermalGen, system), t in time_periods
        )
    )
    optimize!(ed_m)
    return ed_m
end
```

Finally, the `PowerSystems.jl` data is combined with this economic dispatch model and solved with the open-source [`Ipopt`](https://github.com/jump-dev/Ipopt.jl) solver:

```@example using_jump
results = ed_model(system_data, Ipopt.Optimizer)
```
