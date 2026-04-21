# VALIDATORS
function _validate_market_bid_cost(cost, context)
    (cost isa MarketBidCost) || throw(TypeError(
        StackTraces.stacktrace()[2].func, context, MarketBidCost, cost))
end

function _validate_import_export_cost(cost, context)
    (cost isa ImportExportCost) || throw(TypeError(
        StackTraces.stacktrace()[2].func, context, ImportExportCost, cost))
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

function _validate_reserve_demand_curve(cost::CostCurve, name::String)
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

# Arguments
- `sys::System`: PowerSystem System
- `component::StaticInjection`: Static injection device
- `service::Service,`: Service for which the device is eligible to contribute
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

# GETTER HELPER FUNCTIONS
"""
Call get_time_series_array on the given time series and return a TimeArray of the results,
values mapped by `transform_fn` if it is not nothing
"""
function read_and_convert_ts(
    ts::IS.TimeSeriesData,
    component::Component,
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
    transform_fn = nothing,
)
    isnothing(start_time) && (start_time = IS.get_initial_timestamp(ts))
    isnothing(transform_fn) && (transform_fn = (x -> x))
    data = IS.get_time_series_array(component, ts; start_time = start_time, len = len)
    time_stamps = TimeSeries.timestamp(data)
    return TimeSeries.TimeArray(
        time_stamps,
        map(transform_fn, TimeSeries.values(data)),
    )
end

"""
Helper function for cost getters.

# Arguments
- `T`: type/eltype we expect
- `component::Component`: the component
- `cost`: the data: either a single element of type `T` or a `TimeSeriesKey`
- `transform_fn`: a function to apply to the elements of the time series
- `start_time`: as in `get_time_series`
- `len`: as in `get_time_series`
"""
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

# GETTER IMPLEMENTATIONS
"""
Retrieve the variable cost bid for a [`StaticInjection`](@ref) device with a [`MarketBidCost`](@ref).

If any of the relevant fields (`incremental_offer_curves`, `incremental_initial_input`,
`no_load_cost`) are time series, `start_time` and `len` may be specified and a
`TimeArray` of `CostCurve{PiecewiseIncrementalCurve}` values is returned; otherwise
returns a single `CostCurve{PiecewiseIncrementalCurve}`.

See also: [`get_variable_cost` for `ReserveDemandCurve`](@ref get_variable_cost(::ReserveDemandCurve)),
[`get_incremental_variable_cost`](@ref), [`get_decremental_variable_cost`](@ref)
"""
function get_variable_cost(
    device::StaticInjection,
    cost::MarketBidCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    if typeof(get_incremental_offer_curves(cost)) <: CostCurve
        return get_incremental_offer_curves(cost)
    end
    function_data = if (get_incremental_offer_curves(cost) isa TimeSeriesKey)
        get_incremental_offer_curves(device, cost; start_time = start_time, len = len)
    else
        get_incremental_offer_curves(device, cost)
    end
    initial_input = if (get_incremental_initial_input(cost) isa TimeSeriesKey)
        get_incremental_initial_input(device, cost; start_time = start_time, len = len)
    else
        get_incremental_initial_input(device, cost)
    end
    input_at_zero = if (get_no_load_cost(cost) isa TimeSeriesKey)
        get_no_load_cost(device, cost; start_time = start_time, len = len)
    else
        get_no_load_cost(device, cost)
    end
    params::Vector{Any} = [function_data, initial_input, input_at_zero]
    all(isnothing.(params)) && return nothing
    first_time_series = findfirst(isa.(params, TimeSeries.TimeArray))
    if !isnothing(first_time_series)
        timestamps = TimeSeries.timestamp(params[first_time_series])
        for (i, param) in enumerate(params)
            if !(param isa TimeSeries.TimeArray)
                params[i] =
                    TimeSeries.TimeArray(timestamps, fill(param, length(timestamps)))
            end
        end
        !allequal(TimeSeries.timestamp.(params)) &&
            throw(
                ArgumentError(
                    "Time series mismatch between incremental_offer_curves, incremental_initial_input, and no_load_cost",
                ),
            )
        #@show collect(zip(collect.(TimeSeries.values.(params))...)) |> length
        #@show first(collect(zip(collect.(TimeSeries.values.(params))...)))
        return TimeSeries.TimeArray(TimeSeries.timestamp(function_data),
            [
                _make_market_bid_curve(fd; initial_input = ii, input_at_zero = iaz) for
                (fd, ii, iaz) in collect(zip(collect.(TimeSeries.values.(params))...))
            ])
    end
    return make_market_bid_curve(
        function_data,
        initial_input;
        input_at_zero = input_at_zero,
    )
end

"""
Retrieve the incremental variable cost bid for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref). If any of the relevant fields (`incremental_offer_curves`,
`incremental_initial_input`, `no_load_cost`) are time series, `start_time` and `len` may
be specified and a `TimeArray` of `CostCurve{PiecewiseIncrementalCurve}` values is
returned; otherwise returns a single `CostCurve{PiecewiseIncrementalCurve}`.

See also: [`get_variable_cost`](@ref), [`get_decremental_variable_cost`](@ref)
"""
function get_incremental_variable_cost(
    device::StaticInjection,
    cost::MarketBidCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    return get_variable_cost(
        device,
        cost;
        start_time = start_time,
        len = len,
    )
end

"""
Retrieve the decremental variable cost bid for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref). If any of the relevant fields (`decremental_offer_curves`,
`decremental_initial_input`, `no_load_cost`) are time series, `start_time` and `len` may
be specified and a `TimeArray` of `CostCurve{PiecewiseIncrementalCurve}` values is
returned; otherwise returns a single `CostCurve{PiecewiseIncrementalCurve}` or `nothing`.

See also: [`get_variable_cost`](@ref), [`get_incremental_variable_cost`](@ref)
"""
function get_decremental_variable_cost(
    device::StaticInjection,
    cost::MarketBidCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    if typeof(get_decremental_offer_curves(cost)) <: CostCurve
        return get_decremental_offer_curves(cost)
    end
    function_data = if (get_decremental_offer_curves(cost) isa TimeSeriesKey)
        get_decremental_offer_curves(device, cost; start_time = start_time, len = len)
    else
        get_decremental_offer_curves(device, cost)
    end
    initial_input = if (get_decremental_initial_input(cost) isa TimeSeriesKey)
        get_decremental_initial_input(device, cost; start_time = start_time, len = len)
    else
        get_decremental_initial_input(device, cost)
    end
    input_at_zero = if (get_no_load_cost(cost) isa TimeSeriesKey)
        get_no_load_cost(device, cost; start_time = start_time, len = len)
    else
        get_no_load_cost(device, cost)
    end
    params::Vector{Any} = [function_data, initial_input, input_at_zero]
    all(isnothing.(params)) && return nothing
    first_time_series = findfirst(isa.(params, TimeSeries.TimeArray))
    if !isnothing(first_time_series)
        timestamps = TimeSeries.timestamp(params[first_time_series])
        for (i, param) in enumerate(params)
            if !(param isa TimeSeries.TimeArray)
                params[i] =
                    TimeSeries.TimeArray(timestamps, fill(param, length(timestamps)))
            end
        end
        !allequal(TimeSeries.timestamp.(params)) &&
            throw(
                ArgumentError(
                    "Time series mismatch between incremental_offer_curves, incremental_initial_input, and no_load_cost",
                ),
            )
        #@show collect(zip(collect.(TimeSeries.values.(params))...)) |> length
        #@show first(collect(zip(collect.(TimeSeries.values.(params))...)))
        return TimeSeries.TimeArray(TimeSeries.timestamp(function_data),
            [
                _make_market_bid_curve(fd; initial_input = ii, input_at_zero = iaz) for
                (fd, ii, iaz) in collect(zip(collect.(TimeSeries.values.(params))...))
            ])
    end

    return make_market_bid_curve(
        function_data,
        initial_input;
        input_at_zero = input_at_zero,
    )
end

"""
Retrieve the import variable cost bid for a [`StaticInjection`](@ref) device with an
[`ImportExportCost`](@ref). If `import_offer_curves` is a time series, `start_time` and
`len` may be specified and a `TimeArray` of `CostCurve{PiecewiseIncrementalCurve}` values
is returned; otherwise returns a single `CostCurve{PiecewiseIncrementalCurve}` or `nothing`.

See also: [`get_export_variable_cost`](@ref), [`get_import_offer_curves`](@ref)
"""
function get_import_variable_cost(
    device::StaticInjection,
    cost::ImportExportCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    get_import_offer_curves(cost) isa CostCurve &&
        return get_import_offer_curves(cost)
    function_data =
        get_import_offer_curves(device, cost; start_time = start_time, len = len)
    return TimeSeries.TimeArray(TimeSeries.timestamp(function_data),
        [make_import_export_curve(fd) for fd in TimeSeries.values(function_data)])
end

"""
Retrieve the export variable cost bid for a [`StaticInjection`](@ref) device with an
[`ImportExportCost`](@ref). If `export_offer_curves` is a time series, `start_time` and
`len` may be specified and a `TimeArray` of `CostCurve{PiecewiseIncrementalCurve}` values
is returned; otherwise returns a single `CostCurve{PiecewiseIncrementalCurve}` or `nothing`.

See also: [`get_import_variable_cost`](@ref), [`get_export_offer_curves`](@ref)
"""
function get_export_variable_cost(
    device::StaticInjection,
    cost::ImportExportCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    get_export_offer_curves(cost) isa CostCurve &&
        return get_export_offer_curves(cost)
    function_data =
        get_export_offer_curves(device, cost; start_time = start_time, len = len)
    return TimeSeries.TimeArray(TimeSeries.timestamp(function_data),
        [make_import_export_curve(fd) for fd in TimeSeries.values(function_data)])
end

"""
Retrieve the variable cost data for a [`ReserveDemandCurve`](@ref).

`start_time` and `len` may be specified and the function returns a `TimeArray` of
`CostCurve` values.

See also: [`get_variable_cost` for `StaticInjection` with `MarketBidCost`](@ref get_variable_cost(::StaticInjection, ::MarketBidCost))
"""
get_variable_cost(
    service::ReserveDemandCurve;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
) = _process_get_cost(CostCurve{PiecewiseIncrementalCurve}, service, get_variable(service),
    _make_market_bid_curve, start_time, len)

"""
Return service bid time series data for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref). `start_time` and `len` may be specified and a `TimeArray` of
`CostCurve` values is returned.

See also: [`get_variable_cost`](@ref), [`get_incremental_offer_curves`](@ref)
"""
function get_services_bid(
    device::StaticInjection,
    cost::MarketBidCost,
    service::Service;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    variable_ts_key = get_incremental_offer_curves(cost)
    ts = get_time_series(
        variable_ts_key.time_series_type,
        device,
        get_name(service);
        start_time = start_time,
        len = len,
        count = 1,
    )
    converted = read_and_convert_ts(ts, service, start_time, len, _make_market_bid_curve)
    return converted
end

"""
Get the fuel cost of a [`HybridSystem`](@ref)'s thermal subunit.

[`HybridSystem`](@ref) is a [`StaticInjectionSubsystem`](@ref) that aggregates subunits; fuel cost
for thermal power comes from the [`ThermalGen`](@ref) subcomponent, not the hybrid's top-level
[`MarketBidCost`](@ref). This method delegates to [`get_fuel_cost`](@ref get_fuel_cost(component::StaticInjection))
on the thermal subunit when present.

# Arguments
- `component::HybridSystem`: The hybrid system
- `start_time`: Optional start time for time series lookup
- `len`: Optional length for time series lookup

# Returns
The fuel cost from the thermal subunit (scalar or time series per [`get_fuel_cost`](@ref get_fuel_cost(component::StaticInjection))).

# Throws
- `ArgumentError` if the hybrid has no thermal unit (`get_thermal_unit(component) === nothing`).
"""
function get_fuel_cost(component::HybridSystem;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    thermal = get_thermal_unit(component)
    if isnothing(thermal)
        throw(
            ArgumentError(
                "HybridSystem $(get_name(component)) has no thermal unit; fuel cost is undefined.",
            ),
        )
    end
    return get_fuel_cost(thermal; start_time = start_time, len = len)
end

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

"""
Retrieve the `incremental_offer_curves` for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref). If this field is a time series, `start_time` and `len` may be
specified and a `TimeArray` of `PiecewiseStepData` values is returned; otherwise returns
a single `CostCurve{PiecewiseIncrementalCurve}` or `nothing`.

See also: [`get_decremental_offer_curves`](@ref), [`get_incremental_variable_cost`](@ref)
"""
get_incremental_offer_curves(
    device::StaticInjection,
    cost::MarketBidCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
) = _process_get_cost(
    Union{PiecewiseStepData, CostCurve{PiecewiseIncrementalCurve}, Nothing},
    device, get_incremental_offer_curves(cost), nothing, start_time, len)

"""
Retrieve the `decremental_offer_curves` for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref). If this field is a time series, `start_time` and `len` may be
specified and a `TimeArray` of `PiecewiseStepData` values is returned; otherwise returns
a single `CostCurve{PiecewiseIncrementalCurve}` or `nothing`.

See also: [`get_incremental_offer_curves`](@ref), [`get_decremental_variable_cost`](@ref)
"""
get_decremental_offer_curves(
    device::StaticInjection,
    cost::MarketBidCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
) = _process_get_cost(
    Union{PiecewiseStepData, CostCurve{PiecewiseIncrementalCurve}, Nothing},
    device, get_decremental_offer_curves(cost), nothing, start_time, len)

"""
Retrieve the `import_offer_curves` for a [`StaticInjection`](@ref) device with an
[`ImportExportCost`](@ref). If this field is a time series, `start_time` and `len` may be
specified and a `TimeArray` of `PiecewiseStepData` values is returned; otherwise returns
a single `CostCurve{PiecewiseIncrementalCurve}` or `nothing`.

See also: [`get_export_offer_curves`](@ref), [`get_import_variable_cost`](@ref)
"""
get_import_offer_curves(
    device::StaticInjection,
    cost::ImportExportCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
) = _process_get_cost(Union{PiecewiseStepData, CostCurve{PiecewiseIncrementalCurve}},
    device, get_import_offer_curves(cost), nothing, start_time, len)

"""
Retrieve the `export_offer_curves` for a [`StaticInjection`](@ref) device with an
[`ImportExportCost`](@ref). If this field is a time series, `start_time` and `len` may be
specified and a `TimeArray` of `PiecewiseStepData` values is returned; otherwise returns
a single `CostCurve{PiecewiseIncrementalCurve}` or `nothing`.

See also: [`get_import_offer_curves`](@ref), [`get_export_variable_cost`](@ref)
"""
get_export_offer_curves(
    device::StaticInjection,
    cost::ImportExportCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
) = _process_get_cost(Union{PiecewiseStepData, CostCurve{PiecewiseIncrementalCurve}},
    device, get_export_offer_curves(cost), nothing, start_time, len)

"""
Retrieve the no-load cost data for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref). If this field is a time series, `start_time` and `len` may be
specified and a `TimeArray` of `Float64` values is returned; otherwise returns a single
`Float64` or `nothing`.

See also: [`get_start_up`](@ref), [`get_variable_cost`](@ref)
"""
get_no_load_cost(
    device::StaticInjection,
    cost::MarketBidCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
) = _process_get_cost(Union{Nothing, Float64}, device,
    get_no_load_cost(cost), nothing, start_time, len)

"""
Retrieve the `incremental_initial_input` for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref). If this field is a time series, `start_time` and `len` may be
specified and a `TimeArray` of `Float64` values is returned; otherwise returns a single
`Float64` or `nothing`.

See also: [`get_decremental_initial_input`](@ref), [`get_incremental_offer_curves`](@ref)
"""
get_incremental_initial_input(
    device::StaticInjection,
    cost::MarketBidCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
) = _process_get_cost(Union{Nothing, Float64}, device,
    get_incremental_initial_input(cost), nothing, start_time, len)

"""
Retrieve the `decremental_initial_input` for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref). If this field is a time series, `start_time` and `len` may be
specified and a `TimeArray` of `Float64` values is returned; otherwise returns a single
`Float64` or `nothing`.

See also: [`get_incremental_initial_input`](@ref), [`get_decremental_offer_curves`](@ref)
"""
get_decremental_initial_input(
    device::StaticInjection,
    cost::MarketBidCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
) = _process_get_cost(Union{Nothing, Float64}, device,
    get_decremental_initial_input(cost), nothing, start_time, len)

"""
Retrieve the startup cost data for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref). If this field is a time series, `start_time` and `len` may be
specified and a `TimeArray` of `StartUpStages` values is returned; otherwise returns a
single `StartUpStages`.

See also: [`get_shut_down`](@ref), [`get_no_load_cost`](@ref)
"""
get_start_up(
    device::StaticInjection,
    cost::MarketBidCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
) = _process_get_cost(StartUpStages, device,
    get_start_up(cost), StartUpStages, start_time, len)

"""
Retrieve the shutdown cost data for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref). If this field is a time series, `start_time` and `len` may be
specified and a `TimeArray` of `Float64` values is returned; otherwise returns a single
`Float64`.

See also: [`get_start_up`](@ref), [`get_no_load_cost`](@ref)
"""
get_shut_down(
    device::StaticInjection,
    cost::MarketBidCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
) = _process_get_cost(Float64, device,
    get_shut_down(cost), Float64, start_time, len)

# SETTER HELPER FUNCTIONS
"""
Helper function for cost setters.

# Arguments
- `T1`: type we expect if it's not a time series
- `T2`: eltype we expect if it is a time series
- `sys::System`: the system
- `component::Component`: the component
- `cost`: the data: either a single element of type `T1` or a `IS.TimeSeriesData` of eltype `T2`
"""
_process_set_cost(_, _, _, _, ::Nothing) = nothing

_process_set_cost(::Type{T}, _, _, _, cost::T) where {T} = cost

function _process_set_cost(
    ::Type,
    ::Type{T},
    sys::System,
    component::Component,
    cost::IS.TimeSeriesData,
) where {T}
    data_type = IS.eltype_data(cost)
    !(data_type <: T) && throw(TypeError(_process_set_cost, T, data_type))
    key = add_time_series!(sys, component, cost)
    return key
end

# SETTER IMPLEMENTATIONS
"""
Set the incremental variable cost bid for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref).

`data` may be a single `CostCurve{PiecewiseIncrementalCurve}` or a time series of
`PiecewiseStepData`. When using a time series, `power_units` must be
`UnitSystem.NATURAL_UNITS`.

See also: [`set_variable_cost!` for `ReserveDemandCurve` with time series](@ref set_variable_cost!(::System, ::ReserveDemandCurve, ::Union{Nothing, IS.TimeSeriesData})),
[`set_variable_cost!` for `ReserveDemandCurve` with scalar](@ref set_variable_cost!(::System, ::ReserveDemandCurve, ::CostCurve{PiecewiseIncrementalCurve})),
[`get_variable_cost`](@ref)
"""
function set_variable_cost!(
    sys::System,
    component::StaticInjection,
    data::Union{Nothing, IS.TimeSeriesData, CostCurve{PiecewiseIncrementalCurve}},
    power_units::UnitSystem,
)
    # See also: set_variable_cost! for ReserveDemandCurve
    market_bid_cost = get_operation_cost(component)
    _validate_market_bid_cost(market_bid_cost, "get_operation_cost(component)")
    if (typeof(data) <: CostCurve{PiecewiseIncrementalCurve}) &&
       (data.power_units != power_units)
        throw(
            ArgumentError(
                "Units specified in CostCurve data differs from the units specified in the set cost.",
            ),
        )
    end
    if (typeof(data) <: IS.TimeSeriesData) && (power_units != UnitSystem.NATURAL_UNITS)
        throw(ArgumentError("Time Series data for MarketBidCost must be in NATURAL_UNITS."))
    end
    to_set = _process_set_cost(
        CostCurve{PiecewiseIncrementalCurve},
        PiecewiseStepData,
        sys,
        component,
        data,
    )

    set_incremental_offer_curves!(market_bid_cost, to_set)
    return
end

function set_variable_cost!(
    sys::System,
    component::StaticInjection,
    data::Union{Nothing, IS.TimeSeriesData, CostCurve{PiecewiseIncrementalCurve}},
)
    @warn "Variable Cost UnitSystem not specificied for $(get_name(component)). set_variable_cost! assumes data is in UnitSystem.NATURAL_UNITS"
    set_variable_cost!(sys, component, data, UnitSystem.NATURAL_UNITS)
    return
end

"""
Set the incremental variable cost bid for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref).

`data` may be a single `CostCurve{PiecewiseIncrementalCurve}` or a time series of
`PiecewiseStepData`.

See also: [`set_decremental_variable_cost!`](@ref), [`get_incremental_variable_cost`](@ref)
"""
function set_incremental_variable_cost!(
    sys::System,
    component::StaticInjection,
    data::Union{Nothing, IS.TimeSeriesData, CostCurve{PiecewiseIncrementalCurve}},
    power_units::UnitSystem,
)
    set_variable_cost!(sys, component, data, power_units)
    return
end

"""
Set the decremental variable cost bid for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref).

`data` may be a single `CostCurve{PiecewiseIncrementalCurve}` or a time series of
`PiecewiseStepData`.

See also: [`set_incremental_variable_cost!`](@ref), [`get_decremental_variable_cost`](@ref)
"""
function set_decremental_variable_cost!(
    sys::System,
    component::StaticInjection,
    data::Union{Nothing, IS.TimeSeriesData, CostCurve{PiecewiseIncrementalCurve}},
    power_units::UnitSystem,
)
    market_bid_cost = get_operation_cost(component)
    _validate_market_bid_cost(market_bid_cost, "get_operation_cost(component)")

    if (typeof(data) <: CostCurve{PiecewiseIncrementalCurve}) &&
       (data.power_units != power_units)
        throw(
            ArgumentError(
                "Units specified in CostCurve data differs from the units specified in the set cost.",
            ),
        )
    end
    if (typeof(data) <: IS.TimeSeriesData) && (power_units != UnitSystem.NATURAL_UNITS)
        throw(ArgumentError("Time Series data for MarketBidCost must be in NATURAL_UNITS."))
    end
    to_set = _process_set_cost(
        CostCurve{PiecewiseIncrementalCurve},
        PiecewiseStepData,
        sys,
        component,
        data,
    )

    set_decremental_offer_curves!(market_bid_cost, to_set)
    return
end

"""
Set the import variable cost bid for a [`StaticInjection`](@ref) device with an
[`ImportExportCost`](@ref).

`data` may be a single `CostCurve{PiecewiseIncrementalCurve}` or a time series of
`PiecewiseStepData`. When using a time series, `power_units` must be
`UnitSystem.NATURAL_UNITS`.

See also: [`set_export_variable_cost!`](@ref), [`get_import_variable_cost`](@ref)
"""
function set_import_variable_cost!(
    sys::System,
    component::StaticInjection,
    data::Union{Nothing, IS.TimeSeriesData, CostCurve{PiecewiseIncrementalCurve}},
    power_units::UnitSystem,
)
    import_export_cost = get_operation_cost(component)
    _validate_import_export_cost(import_export_cost, "get_operation_cost(component)")

    if (typeof(data) <: CostCurve{PiecewiseIncrementalCurve}) &&
       (data.power_units != power_units)
        throw(
            ArgumentError(
                "Units specified in CostCurve data differs from the units specified in the set cost.",
            ),
        )
    end
    if (typeof(data) <: IS.TimeSeriesData) && (power_units != UnitSystem.NATURAL_UNITS)
        throw(
            ArgumentError(
                "Time Series data for ImportExportCost must be in NATURAL_UNITS.",
            ),
        )
    end
    to_set = _process_set_cost(
        CostCurve{PiecewiseIncrementalCurve},
        PiecewiseStepData,
        sys,
        component,
        data,
    )

    set_import_offer_curves!(import_export_cost, to_set)
    return
end

"""
Set the export variable cost bid for a [`StaticInjection`](@ref) device with an
[`ImportExportCost`](@ref).

`data` may be a single `CostCurve{PiecewiseIncrementalCurve}` or a time series of
`PiecewiseStepData`. When using a time series, `power_units` must be
`UnitSystem.NATURAL_UNITS`.

See also: [`set_import_variable_cost!`](@ref), [`get_export_variable_cost`](@ref)
"""
function set_export_variable_cost!(
    sys::System,
    component::StaticInjection,
    data::Union{Nothing, IS.TimeSeriesData, CostCurve{PiecewiseIncrementalCurve}},
    power_units::UnitSystem,
)
    import_export_cost = get_operation_cost(component)
    _validate_import_export_cost(import_export_cost, "get_operation_cost(component)")

    if (typeof(data) <: CostCurve{PiecewiseIncrementalCurve}) &&
       (data.power_units != power_units)
        throw(
            ArgumentError(
                "Units specified in CostCurve data differs from the units specified in the set cost.",
            ),
        )
    end
    if (typeof(data) <: IS.TimeSeriesData) && (power_units != UnitSystem.NATURAL_UNITS)
        throw(
            ArgumentError(
                "Time Series data for ImportExportCost must be in NATURAL_UNITS.",
            ),
        )
    end
    to_set = _process_set_cost(
        CostCurve{PiecewiseIncrementalCurve},
        PiecewiseStepData,
        sys,
        component,
        data,
    )

    set_export_offer_curves!(import_export_cost, to_set)
    return
end

"""
Set the variable cost for a [`ReserveDemandCurve`](@ref) using a time series.

See also: [`set_variable_cost!` for `StaticInjection`](@ref set_variable_cost!(::System, ::StaticInjection, ::Union{Nothing, IS.TimeSeriesData, CostCurve{PiecewiseIncrementalCurve}}, ::UnitSystem)),
[`set_variable_cost!` for `ReserveDemandCurve` with scalar](@ref set_variable_cost!(::System, ::ReserveDemandCurve, ::CostCurve{PiecewiseIncrementalCurve})),
[`get_variable_cost`](@ref)
"""
function set_variable_cost!(
    sys::System,
    component::ReserveDemandCurve,
    data::Union{Nothing, IS.TimeSeriesData},
)
    # TODO what type checking should be enforced on this time series?
    to_set = _process_set_cost(Any, Any, sys, component, data)
    set_variable!(component, to_set)
end

"""
Set the variable cost for a [`ReserveDemandCurve`](@ref) using a scalar
`CostCurve{PiecewiseIncrementalCurve}`.

See also: [`set_variable_cost!` for `StaticInjection`](@ref set_variable_cost!(::System, ::StaticInjection, ::Union{Nothing, IS.TimeSeriesData, CostCurve{PiecewiseIncrementalCurve}}, ::UnitSystem)),
[`set_variable_cost!` for `ReserveDemandCurve` with time series](@ref set_variable_cost!(::System, ::ReserveDemandCurve, ::Union{Nothing, IS.TimeSeriesData})),
[`get_variable_cost`](@ref)
"""
function set_variable_cost!(
    ::System,
    component::ReserveDemandCurve,
    data::CostCurve{PiecewiseIncrementalCurve},
)
    name = get_name(component)
    _validate_reserve_demand_curve(data, name)
    set_variable!(component, data)
end

"""
Set the fuel cost of a [`StaticInjection`](@ref) component's variable cost, which must be
a [`FuelCurve`](@ref). `data` may be a scalar `Float64` or a time series of `Float64` values.

Throws `ArgumentError` if the variable cost is not a [`FuelCurve`](@ref).

See also: [`get_fuel_cost`](@ref), [`set_variable_cost!`](@ref)
"""
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

"""
Set the no-load cost for a [`StaticInjection`](@ref) device with a [`MarketBidCost`](@ref).

`data` may be a scalar `Float64` or a time series of `Float64` values.

See also: [`get_no_load_cost`](@ref), [`set_start_up!`](@ref)
"""
function set_no_load_cost!(
    sys::System,
    component::StaticInjection,
    data::Union{Float64, IS.TimeSeriesData},
)
    market_bid_cost = get_operation_cost(component)
    _validate_market_bid_cost(market_bid_cost, "get_operation_cost(component)")
    to_set = _process_set_cost(Union{Float64, Nothing}, Float64, sys, component, data)
    set_no_load_cost!(market_bid_cost, to_set)
end

"""
Set the `incremental_initial_input` for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref).

`data` may be a scalar `Float64` or a time series of `Float64` values.

See also: [`set_decremental_initial_input!`](@ref), [`get_incremental_initial_input`](@ref)
"""
function set_incremental_initial_input!(
    sys::System,
    component::StaticInjection,
    data::Union{Float64, IS.TimeSeriesData},
)
    market_bid_cost = get_operation_cost(component)
    _validate_market_bid_cost(market_bid_cost, "get_operation_cost(component)")
    to_set = _process_set_cost(Union{Float64, Nothing}, Float64, sys, component, data)
    set_incremental_initial_input!(market_bid_cost, to_set)
end

"""
Set the `decremental_initial_input` for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref).

`data` may be a scalar `Float64` or a time series of `Float64` values.

See also: [`set_incremental_initial_input!`](@ref), [`get_decremental_initial_input`](@ref)
"""
function set_decremental_initial_input!(
    sys::System,
    component::StaticInjection,
    data::Union{Float64, IS.TimeSeriesData},
)
    market_bid_cost = get_operation_cost(component)
    _validate_market_bid_cost(market_bid_cost, "get_operation_cost(component)")
    to_set = _process_set_cost(Union{Float64, Nothing}, Float64, sys, component, data)
    set_decremental_initial_input!(market_bid_cost, to_set)
end

"""
Set the startup cost for a [`StaticInjection`](@ref) device with a [`MarketBidCost`](@ref).

`data` may be a scalar `Float64`, a single [`StartUpStages`](@ref), or a time series of
`NTuple{3, Float64}`. To represent a single value in a time series, use `(value, 0.0, 0.0)`.

See also: [`set_shut_down!`](@ref), [`set_no_load_cost!`](@ref), [`get_start_up`](@ref)
"""
function set_start_up!(
    sys::System,
    component::StaticInjection,
    data::Union{Float64, StartUpStages, IS.TimeSeriesData},
)
    market_bid_cost = get_operation_cost(component)
    _validate_market_bid_cost(market_bid_cost, "get_operation_cost(component)")
    to_set = _process_set_cost(
        Union{Float64, StartUpStages},
        NTuple{3, Float64},
        sys,
        component,
        data,
    )
    set_start_up!(market_bid_cost, to_set)
end

"""
Set the shutdown cost for a [`StaticInjection`](@ref) device with a [`MarketBidCost`](@ref).

`data` may be a scalar `Float64` or a time series of `Float64` values.

See also: [`set_start_up!`](@ref), [`get_shut_down`](@ref)
"""
function set_shut_down!(
    sys::System,
    component::StaticInjection,
    data::Union{Float64, IS.TimeSeriesData},
)
    market_bid_cost = get_operation_cost(component)
    _validate_market_bid_cost(market_bid_cost, "get_operation_cost(component)")
    to_set = _process_set_cost(
        Float64,
        Float64,
        sys,
        component,
        data,
    )
    set_shut_down!(market_bid_cost, to_set)
end

"""
Set service bid time series data for a [`StaticInjection`](@ref) device with a
[`MarketBidCost`](@ref) for a specific [`Service`](@ref).

`time_series_data` must be of eltype `PiecewiseStepData` and `power_units` must be
`UnitSystem.NATURAL_UNITS`. The device must be eligible to contribute to the service.

See also: [`get_services_bid`](@ref), [`set_variable_cost!`](@ref)
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
    _validate_market_bid_cost(
        get_operation_cost(component),
        "get_operation_cost(component)",
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
    ancillary_service_offers = get_ancillary_service_offers(get_operation_cost(component))
    push!(ancillary_service_offers, service)
    return
end
