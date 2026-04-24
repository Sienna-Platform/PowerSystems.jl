"""
$(TYPEDEF)
$(TYPEDFIELDS)

    ReserveDemandTimeSeriesCurve{T}(variable, name, available, time_frame, sustained_time, max_participation_factor, deployed_fraction, ext, internal)
    ReserveDemandTimeSeriesCurve{T}(; variable, name, available, time_frame, sustained_time, max_participation_factor, deployed_fraction, ext)

A reserve product with a time-varying [Operating Reserve Demand Curve (ORDC)](https://hepg.hks.harvard.edu/files/hepg/files/ordcupdate-final.pdf)
for operational simulations.

The ORDC is modeled as a discretized set of `(Reserve capacity (MW), Price (\$/MWh))` steps,
backed by time series data via IS.jl's time-series ValueCurve types.
For static (non-time-varying) ORDCs, use [`ReserveDemandCurve`](@ref).

When defining the reserve, the `ReserveDirection` must be specified to define this as a
[`ReserveUp`](@ref), [`ReserveDown`](@ref), or [`ReserveSymmetric`](@ref).
"""
mutable struct ReserveDemandTimeSeriesCurve{
    T <: ReserveDirection,
    U <: IS.AbstractUnitSystem,
} <: Reserve{T}
    "Operating reserve demand curve (time series)"
    variable::CostCurve{TimeSeriesPiecewiseIncrementalCurve, U}
    "Name of the component"
    name::String
    "Indicator of whether the component is connected and online"
    available::Bool
    "The saturation time_frame in minutes to provide reserve contribution"
    time_frame::Float64
    "The time in seconds that the reserve contribution must be sustained at a specified level"
    sustained_time::Float64
    "The maximum portion [0, 1.0] of the reserve that can be contributed per device"
    max_participation_factor::Float64
    "Fraction of service procurement that is assumed to be actually deployed"
    deployed_fraction::Float64
    "An extra dictionary for users to add metadata that are not used in simulation"
    ext::Dict{String, Any}
    "PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ReserveDemandTimeSeriesCurve{T}(
    variable,
    name,
    available,
    time_frame,
    sustained_time = 3600.0,
    max_participation_factor = 1.0,
    deployed_fraction = 0.0,
    ext = Dict{String, Any}(),
) where {T <: ReserveDirection}
    U = typeof(get_power_units(variable))
    ReserveDemandTimeSeriesCurve{T, U}(
        variable, name, available, time_frame, sustained_time,
        max_participation_factor, deployed_fraction, ext,
        InfrastructureSystemsInternal(),
    )
end

function ReserveDemandTimeSeriesCurve{T}(;
    variable,
    name,
    available,
    time_frame,
    sustained_time = 3600.0,
    max_participation_factor = 1.0,
    deployed_fraction = 0.0,
    ext = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
) where {T <: ReserveDirection}
    U = typeof(get_power_units(variable))
    ReserveDemandTimeSeriesCurve{T, U}(
        variable, name, available, time_frame, sustained_time,
        max_participation_factor, deployed_fraction, ext, internal,
    )
end

# Kwarg constructor on the fully-parameterized type — needed by deserialization.
function ReserveDemandTimeSeriesCurve{T, U}(;
    variable,
    name,
    available,
    time_frame,
    sustained_time = 3600.0,
    max_participation_factor = 1.0,
    deployed_fraction = 0.0,
    ext = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
) where {T <: ReserveDirection, U <: IS.AbstractUnitSystem}
    ReserveDemandTimeSeriesCurve{T, U}(
        variable, name, available, time_frame, sustained_time,
        max_participation_factor, deployed_fraction, ext, internal,
    )
end

"""Get [`ReserveDemandTimeSeriesCurve`](@ref) `variable`."""
get_variable(value::ReserveDemandTimeSeriesCurve) = value.variable
"""Get [`ReserveDemandTimeSeriesCurve`](@ref) `name`."""
get_name(value::ReserveDemandTimeSeriesCurve) = value.name
"""Get [`ReserveDemandTimeSeriesCurve`](@ref) `available`."""
get_available(value::ReserveDemandTimeSeriesCurve) = value.available
"""Get [`ReserveDemandTimeSeriesCurve`](@ref) `time_frame`."""
get_time_frame(value::ReserveDemandTimeSeriesCurve) = value.time_frame
"""Get [`ReserveDemandTimeSeriesCurve`](@ref) `sustained_time`."""
get_sustained_time(value::ReserveDemandTimeSeriesCurve) = value.sustained_time
"""Get [`ReserveDemandTimeSeriesCurve`](@ref) `max_participation_factor`."""
get_max_participation_factor(value::ReserveDemandTimeSeriesCurve) =
    value.max_participation_factor
"""Get [`ReserveDemandTimeSeriesCurve`](@ref) `deployed_fraction`."""
get_deployed_fraction(value::ReserveDemandTimeSeriesCurve) = value.deployed_fraction
"""Get [`ReserveDemandTimeSeriesCurve`](@ref) `ext`."""
get_ext(value::ReserveDemandTimeSeriesCurve) = value.ext
"""Get [`ReserveDemandTimeSeriesCurve`](@ref) `internal`."""
get_internal(value::ReserveDemandTimeSeriesCurve) = value.internal

"""Set [`ReserveDemandTimeSeriesCurve`](@ref) `variable`."""
set_variable!(value::ReserveDemandTimeSeriesCurve, val) = value.variable = val
"""Set [`ReserveDemandTimeSeriesCurve`](@ref) `available`."""
set_available!(value::ReserveDemandTimeSeriesCurve, val) = value.available = val
"""Set [`ReserveDemandTimeSeriesCurve`](@ref) `time_frame`."""
set_time_frame!(value::ReserveDemandTimeSeriesCurve, val) = value.time_frame = val
"""Set [`ReserveDemandTimeSeriesCurve`](@ref) `sustained_time`."""
set_sustained_time!(value::ReserveDemandTimeSeriesCurve, val) =
    value.sustained_time = val
"""Set [`ReserveDemandTimeSeriesCurve`](@ref) `max_participation_factor`."""
set_max_participation_factor!(value::ReserveDemandTimeSeriesCurve, val) =
    value.max_participation_factor = val
"""Set [`ReserveDemandTimeSeriesCurve`](@ref) `deployed_fraction`."""
set_deployed_fraction!(value::ReserveDemandTimeSeriesCurve, val) =
    value.deployed_fraction = val
"""Set [`ReserveDemandTimeSeriesCurve`](@ref) `ext`."""
set_ext!(value::ReserveDemandTimeSeriesCurve, val) = value.ext = val
