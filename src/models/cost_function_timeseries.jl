# VALIDATORS
function _validate_market_bid_cost(cost, context)
    (cost isa MarketBidCost || cost isa MarketBidTimeSeriesCost) || throw(
        ArgumentError("Expected MarketBidCost or MarketBidTimeSeriesCost for $context, got $(typeof(cost))"))
end

function _validate_import_export_cost(cost, context)
    (cost isa ImportExportCost || cost isa ImportExportTimeSeriesCost) || throw(
        ArgumentError("Expected ImportExportCost or ImportExportTimeSeriesCost for $context, got $(typeof(cost))"))
end

function _validate_reserve_demand_curve(
    cost::CostCurve{PiecewiseIncrementalCurve},
    name::String,
)
    value_curve = get_value_curve(cost)
    function_data = get_function_data(value_curve)
    x_coords = get_x_coords(function_data)
    slopes = get_y_coords(function_data)
    if first(x_coords) != 0
        error(
            "Reserve demand curve from $name is starting at $(first(x_coords)) and must start at zero.",
        )
    end
    for ix in 1:(length(slopes) - 1)
        if slopes[ix + 1] > slopes[ix]
            error(
                "Reserve demand curve from $name has increasing derivatives and should be non-increasing.",
            )
        end
    end
end

function _validate_reserve_demand_curve(cost::T, name::String) where {T <: CostCurve}
    throw(
        ArgumentError(
            "Reserve curve of type $(typeof(cost)) on $name cannot represent an ORDC curve, use CostCurve{PiecewiseIncrementalCurve} instead",
        ),
    )
end

function _validate_fuel_curve(component::Component)
    op_cost = get_operation_cost(component)
    var_cost = get_variable(op_cost)
    !(var_cost isa FuelCurve) && throw(
        ArgumentError(
            "Variable cost of type $(typeof(var_cost)) cannot represent a fuel cost, use FuelCurve instead",
        ),
    )
    return var_cost
end

"""
Validates if a device is eligible to contribute to a service.
"""
function verify_device_eligibility(
    sys::System,
    component::StaticInjection,
    service::Service,
)
    if !has_service(component, service)
        error(
            "Device $(get_name(component)) isn't eligible to contribute to service $(get_name(service)).",
        )
    end
    return
end

# ── STATIC MarketBidCost GETTERS ────────────────────────────────────────────

"""
Retrieve the variable cost for a `StaticInjection` device with a static `MarketBidCost`.
Returns the `CostCurve{PiecewiseIncrementalCurve}` directly.
"""
get_variable_cost(::StaticInjection, cost::MarketBidCost; kwargs...) =
    get_incremental_offer_curves(cost)

get_incremental_variable_cost(device::StaticInjection, cost::MarketBidCost; kwargs...) =
    get_variable_cost(device, cost)

get_decremental_variable_cost(::StaticInjection, cost::MarketBidCost; kwargs...) =
    get_decremental_offer_curves(cost)

# ── TIME-SERIES MarketBidTimeSeriesCost GETTERS ─────────────────────────────

"""
Resolve a time-series-backed `CostCurve` to a static `CostCurve{PiecewiseIncrementalCurve}`
at the given `start_time`.
"""
function _resolve_ts_cost_curve(
    component::Component,
    curve::CostCurve{TimeSeriesPiecewiseIncrementalCurve},
    start_time::Dates.DateTime,
)
    static_vc = IS.build_static_curve(get_value_curve(curve), component, start_time)
    return CostCurve(static_vc, get_power_units(curve), get_vom_cost(curve))
end

"""
Retrieve the variable cost for a `StaticInjection` device with a
`MarketBidTimeSeriesCost`. Resolves time series at `start_time`.
"""
function get_variable_cost(
    device::StaticInjection,
    cost::MarketBidTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    isnothing(start_time) &&
        throw(ArgumentError("start_time is required for MarketBidTimeSeriesCost"))
    return _resolve_ts_cost_curve(
        device, get_incremental_offer_curves(cost), start_time)
end

get_incremental_variable_cost(
    device::StaticInjection,
    cost::MarketBidTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
) = get_variable_cost(device, cost; start_time = start_time, len = len)

function get_decremental_variable_cost(
    device::StaticInjection,
    cost::MarketBidTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    isnothing(start_time) &&
        throw(ArgumentError("start_time is required for MarketBidTimeSeriesCost"))
    return _resolve_ts_cost_curve(
        device, get_decremental_offer_curves(cost), start_time)
end

# ── STATIC ImportExportCost GETTERS ─────────────────────────────────────────

get_import_variable_cost(::StaticInjection, cost::ImportExportCost; kwargs...) =
    get_import_offer_curves(cost)

get_export_variable_cost(::StaticInjection, cost::ImportExportCost; kwargs...) =
    get_export_offer_curves(cost)

# ── TIME-SERIES ImportExportTimeSeriesCost GETTERS ──────────────────────────

function get_import_variable_cost(
    device::StaticInjection,
    cost::ImportExportTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    isnothing(start_time) &&
        throw(ArgumentError("start_time is required for ImportExportTimeSeriesCost"))
    return _resolve_ts_cost_curve(
        device, get_import_offer_curves(cost), start_time)
end

function get_export_variable_cost(
    device::StaticInjection,
    cost::ImportExportTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    isnothing(start_time) &&
        throw(ArgumentError("start_time is required for ImportExportTimeSeriesCost"))
    return _resolve_ts_cost_curve(
        device, get_export_offer_curves(cost), start_time)
end

# ── START-UP / SHUT-DOWN / NO-LOAD GETTERS (time-series variants) ──────────

function get_no_load_cost(
    device::StaticInjection,
    cost::MarketBidTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    isnothing(start_time) &&
        throw(ArgumentError("start_time is required for MarketBidTimeSeriesCost"))
    return IS.build_static_curve(get_no_load_cost(cost), device, start_time)
end

function get_shut_down(
    device::StaticInjection,
    cost::MarketBidTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    isnothing(start_time) &&
        throw(ArgumentError("start_time is required for MarketBidTimeSeriesCost"))
    return IS.build_static_curve(get_shut_down(cost), device, start_time)
end

function get_start_up(
    device::StaticInjection,
    cost::MarketBidTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    su = get_start_up(cost)
    su isa StartUpStages && return su
    # TimeSeriesKey case -- resolve via time series
    ts = get_time_series(device, su; start_time = start_time, len = len, count = 1)
    data = IS.get_time_series_array(device, ts; start_time = start_time, len = len)
    return StartUpStages(first(TimeSeries.values(data)))
end

# ── STATIC ReserveDemandCurve GETTERS ──────────────────────────────────────

get_variable_cost(service::ReserveDemandCurve; kwargs...) = get_variable(service)

# ── TIME-SERIES ReserveDemandTimeSeriesCurve GETTERS ──────────────────────

function get_variable_cost(
    service::ReserveDemandTimeSeriesCurve;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    isnothing(start_time) &&
        throw(ArgumentError("start_time is required for ReserveDemandTimeSeriesCurve"))
    return _resolve_ts_cost_curve(service, get_variable(service), start_time)
end

# ── Helpers for FuelCurve and service bids (still use _process_get_cost) ──

function _process_get_cost(::Type{T}, _, cost::T, transform_fn,
    start_time::Union{Nothing, Dates.DateTime},
    len::Union{Nothing, Int},
) where {T}
    !isnothing(start_time) &&
        throw(ArgumentError("Got non-nothing start_time but this cost is a scalar"))
    !isnothing(len) &&
        throw(ArgumentError("Got non-nothing len but this cost is a scalar"))
    return cost
end

function _process_get_cost(::Type{T}, component::Component, cost::TimeSeriesKey,
    transform_fn,
    start_time::Union{Nothing, Dates.DateTime},
    len::Union{Nothing, Int},
) where {T}
    ts = get_time_series(component, cost; start_time = start_time, len = len, count = 1)
    converted = read_and_convert_ts(ts, component, start_time, len, transform_fn)
    return converted
end

function read_and_convert_ts(
    ts::IS.TimeSeriesData,
    component::Component,
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
    transform_fn = nothing,
)
    isnothing(start_time) && (start_time = IS.get_initial_timestamp(ts))
    isnothing(transform_fn) && (transform_fn = identity)
    data = IS.get_time_series_array(component, ts; start_time = start_time, len = len)
    time_stamps = TimeSeries.timestamp(data)
    return TimeSeries.TimeArray(
        time_stamps,
        map(transform_fn, TimeSeries.values(data)),
    )
end

"""
Auxiliary make market bid curve for timeseries with nothing inputs.
"""
function _make_market_bid_curve(data::PiecewiseStepData;
    initial_input::Union{Nothing, Float64} = nothing,
    power_units::UnitSystem = UnitSystem.NATURAL_UNITS,
    input_at_zero::Union{Nothing, Float64} = nothing)
    cc = CostCurve(IncrementalCurve(data, initial_input, input_at_zero), power_units)
    @assert is_market_bid_curve(cc)
    return cc
end

# ── FuelCurve (unchanged) ──────────────────────────────────────────────────

"Get the fuel cost of the component's variable cost, which must be a `FuelCurve`."
function get_fuel_cost(component::StaticInjection;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    var_cost = _validate_fuel_curve(component)
    return _process_get_cost(
        Float64,
        component,
        get_fuel_cost(var_cost),
        nothing,
        start_time,
        len,
    )
end

# ── SERVICE BIDS ────────────────────────────────────────────────────────────

"""
Return service bid time series data for a `StaticInjection` device with a market bid cost.
"""
function get_services_bid(
    device::StaticInjection,
    cost::Union{MarketBidCost, MarketBidTimeSeriesCost},
    service::Service;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    offer_curves = get_incremental_offer_curves(cost)
    # For time-series types, the key is embedded in the curve
    if IS.is_time_series_backed(offer_curves)
        ts_key = IS.get_time_series_key(get_value_curve(offer_curves))
        ts = get_time_series(
            ts_key.time_series_type,
            device,
            get_name(service);
            start_time = start_time,
            len = len,
            count = 1,
        )
    else
        # Static cost -- service bids should still be in time series on the component
        ts = get_time_series(
            IS.Deterministic,
            device,
            get_name(service);
            start_time = start_time,
            len = len,
            count = 1,
        )
    end
    converted = read_and_convert_ts(ts, service, start_time, len, _make_market_bid_curve)
    return converted
end

# ── SETTER IMPLEMENTATIONS ──────────────────────────────────────────────────

function _check_power_units(data::ProductionVariableCostCurve, power_units::UnitSystem)
    if get_power_units(data) != power_units
        throw(
            ArgumentError(
                "Units specified in CostCurve data differs from the units specified in the set cost.",
            ),
        )
    end
end

"""
Set the variable cost for a `StaticInjection` device with a `MarketBidCost`.
"""
function set_variable_cost!(
    ::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve},
    power_units::UnitSystem,
)
    market_bid_cost = get_operation_cost(component)
    _validate_market_bid_cost(market_bid_cost, "get_operation_cost(component)")
    _check_power_units(data, power_units)
    set_incremental_offer_curves!(market_bid_cost, data)
    return
end

function set_variable_cost!(
    sys::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve},
)
    @warn "Variable Cost UnitSystem not specified for $(get_name(component)). set_variable_cost! assumes data is in UnitSystem.NATURAL_UNITS"
    set_variable_cost!(sys, component, data, UnitSystem.NATURAL_UNITS)
    return
end

set_incremental_variable_cost!(
    sys::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve},
    power_units::UnitSystem,
) = set_variable_cost!(sys, component, data, power_units)

function set_decremental_variable_cost!(
    ::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve},
    power_units::UnitSystem,
)
    market_bid_cost = get_operation_cost(component)
    _validate_market_bid_cost(market_bid_cost, "get_operation_cost(component)")
    _check_power_units(data, power_units)
    set_decremental_offer_curves!(market_bid_cost, data)
    return
end

function set_import_variable_cost!(
    ::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve},
    power_units::UnitSystem,
)
    import_export_cost = get_operation_cost(component)
    _validate_import_export_cost(import_export_cost, "get_operation_cost(component)")
    _check_power_units(data, power_units)
    set_import_offer_curves!(import_export_cost, data)
    return
end

function set_export_variable_cost!(
    ::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve},
    power_units::UnitSystem,
)
    import_export_cost = get_operation_cost(component)
    _validate_import_export_cost(import_export_cost, "get_operation_cost(component)")
    _check_power_units(data, power_units)
    set_export_offer_curves!(import_export_cost, data)
    return
end

# ── ReserveDemandCurve Setters ─────────────────────────────────────────────

function set_variable_cost!(
    ::System,
    component::ReserveDemandCurve,
    data::CostCurve{PiecewiseIncrementalCurve},
)
    name = get_name(component)
    _validate_reserve_demand_curve(data, name)
    set_variable!(component, data)
end

# ── Helpers for FuelCurve setter (still uses _process_set_cost) ───────────

function _process_set_cost(_, _, _, _, ::Nothing)
    return nothing
end

function _process_set_cost(::Type{T}, _, _, _, cost::T) where {T}
    return cost
end

function _process_set_cost(
    ::Type{_},
    ::Type{T},
    sys::System,
    component::Component,
    cost::IS.TimeSeriesData,
) where {_, T}
    data_type = IS.eltype_data(cost)
    !(data_type <: T) && throw(TypeError(_process_set_cost, T, data_type))
    key = add_time_series!(sys, component, cost)
    return key
end

# ── FuelCurve Setter (unchanged) ───────────────────────────────────────────

"Set the fuel cost of the component's variable cost, which must be a `FuelCurve`."
function set_fuel_cost!(
    sys::System,
    component::StaticInjection,
    data::Union{Float64, IS.TimeSeriesData},
)
    var_cost = _validate_fuel_curve(component)
    to_set = _process_set_cost(Float64, Float64, sys, component, data)
    op_cost = get_operation_cost(component)
    new_var_cost =
        FuelCurve(
            get_value_curve(var_cost),
            get_power_units(var_cost),
            to_set,
            get_startup_fuel_offtake(var_cost),
            get_vom_cost(var_cost),
        )
    set_variable!(op_cost, new_var_cost)
end

# ── Service Bid Setter ──────────────────────────────────────────────────────

"""
Adds service bids time-series data to the cost.

# Arguments
- `sys::System`: PowerSystem System
- `component::StaticInjection`: Static injection device
- `service::Service,`: Service for which the device is eligible to contribute
- `time_series_data::IS.TimeSeriesData`: TimeSeriesData
"""
function set_service_bid!(
    sys::System,
    component::StaticInjection,
    service::Service,
    time_series_data::IS.TimeSeriesData,
    power_units::UnitSystem,
)
    data_type = IS.eltype_data(time_series_data)
    !(data_type <: PiecewiseStepData) &&
        throw(TypeError(set_service_bid!, PiecewiseStepData, data_type))
    cost = get_operation_cost(component)
    (cost isa OfferCurveCost) || throw(
        ArgumentError("Operation cost must be an OfferCurveCost for service bids"),
    )
    if get_name(time_series_data) != get_name(service)
        error(
            "Name provided in the TimeSeries Data $(get_name(time_series_data)), doesn't match the Service $(get_name(service)).",
        )
    end
    if power_units != UnitSystem.NATURAL_UNITS
        throw(
            ArgumentError(
                "Power Unit specified for service market bids must be NATURAL_UNITS",
            ),
        )
    end
    verify_device_eligibility(sys, component, service)
    add_time_series!(sys, component, time_series_data)
    ancillary_service_offers = get_ancillary_service_offers(cost)
    push!(ancillary_service_offers, service)
    return
end
