"""
Supertype for operational cost representations

Current abstract type for representing operational costs associated with power system devices.
- [`OfferCurveCost`](@ref)

Current concrete types include:
- [`ThermalGenerationCost`](@ref)
- [`HydroGenerationCost`](@ref)
- [`RenewableGenerationCost`](@ref)
- [`StorageCost`](@ref)
- [`LoadCost`](@ref)
- [`ImportExportCost`](@ref)
- [`MarketBidCost`](@ref)
"""
abstract type OperationalCost <: DeviceParameter end

IS.serialize(val::OperationalCost) = IS.serialize_struct(val)
IS.deserialize(T::Type{<:OperationalCost}, val::Dict) = IS.deserialize_struct(T, val)
# NOTE MarketBidCost serialization is handled in serialization.jl

"""
Every `TimeSeriesKey` this cost holds, wherever it sits in the cost's fields — a `FuelCurve`'s
fuel cost, a `MarketBidTimeSeriesCost`'s offer, start-up and shut-down series, a time-series
value curve's inputs. This is the set of series a copy of the cost's owner needs to carry for
the cost to resolve.
"""
function get_time_series_keys(cost::OperationalCost)
    keys = IS.TimeSeriesKey[]
    _collect_time_series_keys!(keys, cost)
    return keys
end

_collect_time_series_keys!(keys::Vector{IS.TimeSeriesKey}, key::IS.TimeSeriesKey) =
    push!(keys, key)
_collect_time_series_keys!(::Vector{IS.TimeSeriesKey}, ::Nothing) = nothing
_collect_time_series_keys!(::Vector{IS.TimeSeriesKey}, ::Number) = nothing
_collect_time_series_keys!(::Vector{IS.TimeSeriesKey}, ::AbstractString) = nothing
# A referenced component (e.g. `ancillary_service_offers::Vector{Service}`) is not part of
# the cost's own data: walking into it would reach its `SharedSystemReferences`, including a
# live `time_series_manager`, and leak that component's unrelated time series.
function _collect_time_series_keys!(
    ::Vector{IS.TimeSeriesKey},
    ::IS.InfrastructureSystemsComponent,
)
    return nothing
end

function _collect_time_series_keys!(keys::Vector{IS.TimeSeriesKey}, d::AbstractDict)
    for v in values(d)
        _collect_time_series_keys!(keys, v)
    end
    return nothing
end

function _collect_time_series_keys!(
    keys::Vector{IS.TimeSeriesKey},
    xs::Union{Tuple, AbstractArray},
)
    for x in xs
        _collect_time_series_keys!(keys, x)
    end
    return nothing
end

function _collect_time_series_keys!(keys::Vector{IS.TimeSeriesKey}, x)
    for name in fieldnames(typeof(x))
        _collect_time_series_keys!(keys, getfield(x, name))
    end
    return nothing
end
