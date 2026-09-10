# VALIDATORS
function _validate_reserve_demand_curve(
    cost::CostCurve{PiecewiseIncrementalCurve, U},
    name::String,
) where {U <: IS.AbstractUnitSystem}
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
    var_cost = get_variable_operation_cost(op_cost)
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
Resolve a time-series-backed `CostCurve` over a window of `len` timesteps,
returning a `Vector` of static `CostCurve`s (one storage read per
time-series-backed field for the whole window). With `len = nothing`, resolve
a single timestep and return one static `CostCurve`.
"""
function _resolve_ts_cost_curve(
    component::Component,
    curve::CostCurve{<:TimeSeriesPiecewiseIncrementalCurve, U},
    start_time::Dates.DateTime,
    len::Int,
) where {U <: IS.AbstractUnitSystem}
    static_vcs = IS.build_static_curves(get_value_curve(curve), component, start_time, len)
    power_units = get_power_units(curve)
    vom_cost = get_vom_cost(curve)
    return [CostCurve(vc, power_units, vom_cost) for vc in static_vcs]
end

_resolve_ts_cost_curve(component::Component, curve, start_time::Dates.DateTime) =
    only(_resolve_ts_cost_curve(component, curve, start_time, 1))
_resolve_ts_cost_curve(component::Component, curve, start_time::Dates.DateTime, ::Nothing) =
    _resolve_ts_cost_curve(component, curve, start_time)

# Same len-arity dispatch for curves resolved directly through IS.
_build_static(curve, device, start_time, ::Nothing) =
    IS.build_static_curve(curve, device, start_time)
_build_static(curve, device, start_time, len::Int) =
    IS.build_static_curves(curve, device, start_time, len)

"""
Resolve one offer curve of a `MarketBidTimeSeriesCost` at `start_time` and, for a `FIXED`
bid, enforce the single-segment rule its constructor cannot (the curve is a key there, not
data). `field` names the offer curve in the error.
"""
function _resolve_market_bid_offer_curve(
    device::StaticInjection,
    cost::MarketBidTimeSeriesCost,
    curve,
    field::AbstractString,
    start_time::Dates.DateTime,
    len::Union{Nothing, Int},
)
    resolved = _resolve_ts_cost_curve(device, curve, start_time, len)
    check_fixed_single_segment(
        get_curve_style(cost), resolved, field; context = string(start_time),
    )
    return resolved
end

"""
Retrieve the variable cost for a `StaticInjection` device with a
`MarketBidTimeSeriesCost`. Resolves time series at `start_time`. Throws ArgumentError if
the bid is `FIXED` and a resolved curve has more than one segment.
"""
function get_variable_cost(
    device::StaticInjection,
    cost::MarketBidTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    isnothing(start_time) &&
        throw(ArgumentError("start_time is required for MarketBidTimeSeriesCost"))
    return _resolve_market_bid_offer_curve(
        device, cost, get_incremental_offer_curves(cost), "incremental_offer_curves",
        start_time, len,
    )
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
    return _resolve_market_bid_offer_curve(
        device, cost, get_decremental_offer_curves(cost), "decremental_offer_curves",
        start_time, len,
    )
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
        device, get_import_offer_curves(cost), start_time, len)
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
        device, get_export_offer_curves(cost), start_time, len)
end

# ── START-UP / SHUT-DOWN / MINIMUM-ENERGY-OFFER GETTERS (time-series variants) ──────────

function get_minimum_energy_offer(
    device::StaticInjection,
    cost::MarketBidTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    isnothing(start_time) &&
        throw(ArgumentError("start_time is required for MarketBidTimeSeriesCost"))
    return _build_static(get_minimum_energy_offer(cost), device, start_time, len)
end

function get_shut_down(
    device::StaticInjection,
    cost::MarketBidTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    isnothing(start_time) &&
        throw(ArgumentError("start_time is required for MarketBidTimeSeriesCost"))
    return _build_static(get_shut_down(cost), device, start_time, len)
end

function get_start_up(
    device::StaticInjection,
    cost::MarketBidTimeSeriesCost;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
)
    isnothing(start_time) &&
        throw(ArgumentError("start_time is required for MarketBidTimeSeriesCost"))
    raw = only(
        get_time_series_values(
            device,
            get_start_up(cost);
            start_time = start_time,
            len = 1,
        ),
    )
    return StartUpStages(raw)
end

# ── ORDC variable-cost getters (any AbstractReserve, groups included) ────────
# Static curve: return it. Time-series curve: resolve at `start_time`.

function get_variable_cost(
    service::AbstractReserve;
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
)
    return _get_reserve_variable_cost(service, get_variable(service), start_time, len)
end

_get_reserve_variable_cost(
    ::AbstractReserve,
    variable::CostCurve{PiecewiseIncrementalCurve},
    ::Union{Nothing, Dates.DateTime},
    ::Union{Nothing, Int},
) = variable

function _get_reserve_variable_cost(
    service::AbstractReserve,
    variable::CostCurve{<:TimeSeriesPiecewiseIncrementalCurve},
    start_time::Union{Nothing, Dates.DateTime},
    len::Union{Nothing, Int},
)
    isnothing(start_time) &&
        throw(
            ArgumentError(
                "start_time is required for a time-series-backed reserve demand curve",
            ),
        )
    return _resolve_ts_cost_curve(service, variable, start_time, len)
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
    power_units::IS.AbstractUnitSystem = IS.NaturalUnit(),
    input_at_zero::Union{Nothing, Float64} = nothing)
    cc = CostCurve(IncrementalCurve(data, initial_input, input_at_zero), power_units)
    @assert is_market_bid_curve(cc)
    return cc
end

# ── FuelCurve (unchanged) ──────────────────────────────────────────────────

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
    # The fixed value and the time series key are separate fields on `FuelCurve`, and
    # exactly one of them is set. Whichever it is goes to `_process_get_cost`, which
    # dispatches on the scalar/key distinction to read or pass through.
    fixed = get_fuel_cost(var_cost)
    fuel_cost = isnothing(fixed) ? get_fuel_cost_time_series(var_cost) : fixed
    return _process_get_cost(
        Float64,
        component,
        fuel_cost,
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
            IS.get_time_series_type(ts_key),
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
    converted = read_and_convert_ts(ts, device, start_time, len, _make_market_bid_curve)
    return converted
end

# ── SETTER IMPLEMENTATIONS ──────────────────────────────────────────────────

function _check_power_units(
    data::ProductionVariableCostCurve,
    power_units::IS.AbstractUnitSystem,
)
    if get_power_units(data) != power_units
        throw(
            ArgumentError(
                "Units specified in CostCurve data differs from the units specified in the set cost.",
            ),
        )
    end
end

# Offer-curve fields pin the cost's unit-system parameter `U`, so changing
# units requires rebuilding the cost object rather than mutating the field.
# `_replace_offer_curve` is the single chokepoint for the static-curve setters:
# it validates the cost kind and slot, re-tags the sibling placeholder curve,
# and returns the rebuilt cost.

# A placeholder offer curve carries no information (all-zero slopes with
# zero-or-unset offsets), so re-tagging it to a new unit system is lossless.
_is_placeholder_offer(curve::CostCurve) =
    all(iszero, get_slopes(get_value_curve(curve))) &&
    _iszero_or_nothing(get_initial_input(get_value_curve(curve))) &&
    _iszero_or_nothing(get_input_at_zero(get_value_curve(curve)))

_retag_placeholder(curve::CostCurve, ::Type{U}) where {U <: IS.AbstractUnitSystem} =
    if _is_placeholder_offer(curve)
        CostCurve(get_value_curve(curve), U(), get_vom_cost(curve))
    else
        curve
    end

_throw_wrong_offer_slot(cost, slot) = throw(
    ArgumentError("cannot set the $slot offer curve on a $(nameof(typeof(cost)))"),
)

function _replace_offer_curve(
    cost::MarketBidCost,
    slot::Symbol,
    data::CostCurve{PiecewiseIncrementalCurve, U},
) where {U <: IS.AbstractUnitSystem}
    slot in (:incremental, :decremental) || _throw_wrong_offer_slot(cost, slot)
    inc = if slot === :incremental
        data
    else
        _retag_placeholder(get_incremental_offer_curves(cost), U)
    end
    dec = if slot === :decremental
        data
    else
        _retag_placeholder(get_decremental_offer_curves(cost), U)
    end
    return MarketBidCost(;
        minimum_energy_offer = get_minimum_energy_offer(cost),
        start_up = get_start_up(cost),
        shut_down = get_shut_down(cost),
        incremental_offer_curves = inc,
        decremental_offer_curves = dec,
        ancillary_service_offers = get_ancillary_service_offers(cost),
    )
end

function _replace_offer_curve(
    cost::ImportExportCost,
    slot::Symbol,
    data::CostCurve{PiecewiseIncrementalCurve, U},
) where {U <: IS.AbstractUnitSystem}
    slot in (:import, :export) || _throw_wrong_offer_slot(cost, slot)
    imp = slot === :import ? data : _retag_placeholder(get_import_offer_curves(cost), U)
    exp = slot === :export ? data : _retag_placeholder(get_export_offer_curves(cost), U)
    return ImportExportCost(;
        import_offer_curves = imp,
        export_offer_curves = exp,
        energy_import_weekly_limit = get_energy_import_weekly_limit(cost),
        energy_export_weekly_limit = get_energy_export_weekly_limit(cost),
        ancillary_service_offers = get_ancillary_service_offers(cost),
    )
end

_replace_offer_curve(
    cost::Union{MarketBidTimeSeriesCost, ImportExportTimeSeriesCost},
    ::Symbol,
    ::CostCurve,
) = throw(
    ArgumentError(
        "the component's operation cost is $(typeof(cost)); static-curve " *
        "setters cannot modify a time-series-backed cost — replace the " *
        "operation cost instead",
    ),
)

_replace_offer_curve(cost, slot::Symbol, ::CostCurve) = throw(
    ArgumentError(
        "cannot set a $slot offer curve on an operation cost of type $(typeof(cost))",
    ),
)

"""
Set the variable cost for a `StaticInjection` device with a `MarketBidCost`.

The component's `MarketBidCost` is rebuilt with the unit system of `data`;
a placeholder (all-zero) decremental curve is re-tagged to match, while a
real decremental curve in a different unit system raises an `ArgumentError`.
"""
function set_variable_cost!(
    ::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve, U},
    power_units::IS.AbstractUnitSystem,
) where {U <: IS.AbstractUnitSystem}
    _check_power_units(data, power_units)
    set_operation_cost!(
        component,
        _replace_offer_curve(get_operation_cost(component), :incremental, data),
    )
    return
end

function set_variable_cost!(
    sys::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve, U},
) where {U <: IS.AbstractUnitSystem}
    @warn "Variable Cost UnitSystem not specified for $(get_name(component)). set_variable_cost! assumes data is in IS.NaturalUnit()"
    set_variable_cost!(sys, component, data, IS.NaturalUnit())
    return
end

set_incremental_variable_cost!(
    sys::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve, U},
    power_units::IS.AbstractUnitSystem,
) where {U <: IS.AbstractUnitSystem} =
    set_variable_cost!(sys, component, data, power_units)

function set_decremental_variable_cost!(
    ::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve, U},
    power_units::IS.AbstractUnitSystem,
) where {U <: IS.AbstractUnitSystem}
    _check_power_units(data, power_units)
    set_operation_cost!(
        component,
        _replace_offer_curve(get_operation_cost(component), :decremental, data),
    )
    return
end

function set_import_variable_cost!(
    ::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve, U},
    power_units::IS.AbstractUnitSystem,
) where {U <: IS.AbstractUnitSystem}
    _check_power_units(data, power_units)
    set_operation_cost!(
        component,
        _replace_offer_curve(get_operation_cost(component), :import, data),
    )
    return
end

function set_export_variable_cost!(
    ::System,
    component::StaticInjection,
    data::CostCurve{PiecewiseIncrementalCurve, U},
    power_units::IS.AbstractUnitSystem,
) where {U <: IS.AbstractUnitSystem}
    _check_power_units(data, power_units)
    set_operation_cost!(
        component,
        _replace_offer_curve(get_operation_cost(component), :export, data),
    )
    return
end

# ── ORDC Setters (any AbstractReserve, groups included) ────────────────────

function set_variable_cost!(
    ::System,
    component::AbstractReserve,
    data::CostCurve{PiecewiseIncrementalCurve, U},
) where {U <: IS.AbstractUnitSystem}
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

function _reject_ts_eltype(fname::Symbol, expected::Type, ts::IS.TimeSeriesData)
    throw(TypeError(fname, "time series values", expected, eltype(ts)))
end

function _process_set_cost(
    ::Type{_},
    ::Type{T},
    sys::System,
    component::Component,
    cost::IS.TimeSeriesData{<:T},
) where {_, T}
    key = add_time_series!(sys, component, cost)
    return key
end

function _process_set_cost(
    ::Type{_},
    ::Type{T},
    ::System,
    ::Component,
    cost::IS.TimeSeriesData,
) where {_, T}
    return _reject_ts_eltype(:_process_set_cost, T, cost)
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
    set_variable_operation_cost!(op_cost, new_var_cost)
end

# ── Service Bid Setter ──────────────────────────────────────────────────────

"""
Adds service bids time-series data to the cost.

# Arguments
- `sys::System`: PowerSystem System
- `component::StaticInjection`: Static injection device
- `service::Service,`: Service for which the device is eligible to contribute
- `time_series_data::IS.TimeSeriesData{<:PiecewiseStepData}`: TimeSeriesData whose values
  are `PiecewiseStepData`
"""
function set_service_bid!(
    sys::System,
    component::StaticInjection,
    service::Service,
    time_series_data::IS.TimeSeriesData{<:PiecewiseStepData},
    power_units::IS.AbstractUnitSystem,
)
    cost = get_operation_cost(component)
    (cost isa OfferCurveCost) || throw(
        ArgumentError("Operation cost must be an OfferCurveCost for service bids"),
    )
    if get_name(time_series_data) != get_name(service)
        error(
            "Name provided in the TimeSeries Data $(get_name(time_series_data)), doesn't match the Service $(get_name(service)).",
        )
    end
    if power_units != IS.NaturalUnit()
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

# Service bids must be piecewise step data; report the mismatch rather than letting the
# narrowed signature above surface as a bare MethodError.
function set_service_bid!(
    ::System,
    ::StaticInjection,
    ::Service,
    time_series_data::IS.TimeSeriesData,
    ::IS.AbstractUnitSystem,
)
    return _reject_ts_eltype(:set_service_bid!, PiecewiseStepData, time_series_data)
end

# ── Hub Bid Setter ──────────────────────────────────────────────────────────

"""
Adds trading-hub bid time-series data to the cost.

# Arguments
- `sys::System`: PowerSystem System
- `vp::VirtualParticipant`: Virtual participant bidding at the hub
- `hub::TradingHub`: Trading hub the participant settles bids at
- `time_series_data::IS.TimeSeriesData{<:PiecewiseStepData}`: TimeSeriesData whose values
  are `PiecewiseStepData`
"""
function set_hub_bid!(
    sys::System,
    vp::VirtualParticipant,
    hub::TradingHub,
    time_series_data::IS.TimeSeriesData{<:PiecewiseStepData},
    power_units::IS.AbstractUnitSystem,
)
    if get_name(time_series_data) != get_name(hub)
        error(
            "Name provided in the TimeSeries Data $(get_name(time_series_data)), doesn't match the TradingHub $(get_name(hub)).",
        )
    end
    if power_units != IS.NaturalUnit()
        throw(
            ArgumentError(
                "Power Unit specified for hub market bids must be NATURAL_UNITS",
            ),
        )
    end
    if !has_trading_hub(vp, hub)
        error(
            "$(get_name(vp)) is not associated with hub $(get_name(hub)); call add_trading_hub! first.",
        )
    end
    if has_time_series(vp, typeof(time_series_data), get_name(hub))
        error(
            "$(get_name(vp)) already has a hub bid time series named $(get_name(hub)).",
        )
    end
    add_time_series!(sys, vp, time_series_data)
    return
end

# Hub bids must be piecewise step data; report the mismatch rather than letting the
# narrowed signature above surface as a bare MethodError.
function set_hub_bid!(
    ::System,
    ::VirtualParticipant,
    ::TradingHub,
    time_series_data::IS.TimeSeriesData,
    ::IS.AbstractUnitSystem,
)
    return _reject_ts_eltype(:set_hub_bid!, PiecewiseStepData, time_series_data)
end
