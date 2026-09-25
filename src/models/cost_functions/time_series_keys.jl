"""
Every `TimeSeriesKey` this cost holds: a `FuelCurve`'s fuel cost, a time-series value curve's
inputs, and a `MarketBidTimeSeriesCost`'s offer, start-up and shut-down series. This is the
set of series a copy of the cost's owner needs to carry for the cost to resolve.
"""
function get_time_series_keys(cost::OperationalCost)
    keys = IS.TimeSeriesKey[]
    _collect_time_series_keys!(keys, cost)
    return keys
end

# Each cost type names the fields that can hold a key. The `Any` fallback covers static
# values (scalars, start-up tuples, static curves), so nothing outside those fields is walked.
_collect_time_series_keys!(::Vector{IS.TimeSeriesKey}, ::Any) = nothing
_collect_time_series_keys!(keys::Vector{IS.TimeSeriesKey}, key::IS.TimeSeriesKey) =
    push!(keys, key)

function _collect_time_series_keys!(keys::Vector{IS.TimeSeriesKey}, curve::IS.CostCurve)
    _collect_time_series_keys!(keys, IS.get_value_curve(curve))
    return nothing
end

function _collect_time_series_keys!(keys::Vector{IS.TimeSeriesKey}, curve::IS.FuelCurve)
    _collect_time_series_keys!(keys, IS.get_value_curve(curve))
    _collect_time_series_keys!(keys, IS.get_fuel_cost_time_series(curve))
    return nothing
end

function _collect_time_series_keys!(
    keys::Vector{IS.TimeSeriesKey},
    curve::IS.TimeSeriesInputOutputCurve,
)
    push!(keys, IS.get_time_series_key(IS.get_function_data(curve)))
    return nothing
end

function _collect_time_series_keys!(
    keys::Vector{IS.TimeSeriesKey},
    curve::Union{IS.TimeSeriesIncrementalCurve, IS.TimeSeriesAverageRateCurve},
)
    push!(keys, IS.get_time_series_key(IS.get_function_data(curve)))
    _collect_time_series_keys!(keys, IS.get_initial_input(curve))
    _collect_time_series_keys!(keys, IS.get_input_at_zero(curve))
    return nothing
end

function _collect_time_series_keys!(
    keys::Vector{IS.TimeSeriesKey},
    cost::Union{ThermalGenerationCost, HydroGenerationCost, LoadCost},
)
    _collect_time_series_keys!(keys, get_variable_operation_cost(cost))
    return nothing
end

function _collect_time_series_keys!(
    keys::Vector{IS.TimeSeriesKey},
    cost::RenewableGenerationCost,
)
    _collect_time_series_keys!(keys, get_variable_operation_cost(cost))
    _collect_time_series_keys!(keys, get_curtailment_cost(cost))
    return nothing
end

function _collect_time_series_keys!(keys::Vector{IS.TimeSeriesKey}, cost::StorageCost)
    _collect_time_series_keys!(keys, get_charge_variable_cost(cost))
    _collect_time_series_keys!(keys, get_discharge_variable_cost(cost))
    return nothing
end

function _collect_time_series_keys!(
    keys::Vector{IS.TimeSeriesKey},
    cost::MarketBidTimeSeriesCost,
)
    _collect_time_series_keys!(keys, get_minimum_energy_offer(cost))
    _collect_time_series_keys!(keys, get_start_up(cost))
    _collect_time_series_keys!(keys, get_shut_down(cost))
    _collect_time_series_keys!(keys, get_incremental_offer_curves(cost))
    _collect_time_series_keys!(keys, get_decremental_offer_curves(cost))
    return nothing
end

function _collect_time_series_keys!(
    keys::Vector{IS.TimeSeriesKey},
    cost::ImportExportTimeSeriesCost,
)
    _collect_time_series_keys!(keys, get_import_offer_curves(cost))
    _collect_time_series_keys!(keys, get_export_offer_curves(cost))
    return nothing
end

# Static-only costs, listed so every cost type has its own method rather than the fallback.
_collect_time_series_keys!(
    ::Vector{IS.TimeSeriesKey},
    ::Union{HydroReservoirCost, MarketBidCost, ImportExportCost},
) = nothing
