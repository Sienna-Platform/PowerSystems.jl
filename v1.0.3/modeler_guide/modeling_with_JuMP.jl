# # [Modeling with JuMP](@id modeling_with_jump)
#
# This page shows a minimal example of `PowerSystems.jl` used to develop and Economic Dispatch
# model. The code  shows the stages to develop modeling code
#
# 1. Make the data set from power flow and time series data,
# 2. Serialize the data,
# 3. Pass the data and algorithm to the model.
#
# One of the main uses of ``PowerSystems.jl` is not having re-run the data generation for every
# model execution. The model code shows an example of populating the constraints and cost
# functions using accessor functions inside the model function. The example concludes by
# reading the data created earlier and passing the algorithm with the data.

using PowerSystems
const PSY = PowerSystems
using JuMP
using Ipopt

DATA_DIR = "../../../data" #hide
system_data = System(joinpath(DATA_DIR, "matpower/case5_re.m"))
add_time_series!(system_data, joinpath(DATA_DIR,"forecasts/5bus_ts/timeseries_pointers_da.json"))
to_json(system_data, "system_data.json")


function ed_model(system::System, optimizer)
    ed_m = Model(optimizer)
    time_periods = 24
    thermal_gens_names = get_name.(get_components(ThermalStandard, system))
    @variable(ed_m, pg[g in thermal_gens_names, t in time_periods] >= 0)

    for g in get_components(ThermalStandard, system), t in time_periods
        name = get_name(g)
        @constraint(ed_m, pg[name, t] >= get_active_power_limits(g).min)
        @constraint(ed_m, pg[name, t] <= get_active_power_limits(g).max)
    end

    net_load = zeros(time_periods)
    for g in get_components(RenewableGen, system)
        net_load -= get_time_series_values(SingleTimeSeries, g, "max_active_power")
    end

    for g in get_components(StaticLoad, system)
        net_load += get_time_series_values(SingleTimeSeries, g, "max_active_power")
    end

    for t in time_periods
        @constraint(ed_m, sum(pg[g, t] for g in thermal_gens_names) == net_load[t])
    end

    @objective(ed_m, Min, sum(
            pg[get_name(g), t]^2*get_cost(get_variable(get_operation_cost(g)))[1] +
            pg[get_name(g), t]*get_cost(get_variable(get_operation_cost(g)))[2]
            for g in get_components(ThermalGen, system), t in time_periods
                )
            )

    return optimize!(ed_m)
end

system_data = System("system_data.json")
results = ed_model(system_data, Ipopt.Optimizer)
