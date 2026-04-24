"""
$(TYPEDEF)
$(TYPEDFIELDS)

    ReserveDemandCurve{T}(variable, name, available, time_frame, sustained_time, max_participation_factor, deployed_fraction, ext, internal)
    ReserveDemandCurve{T}(; variable, name, available, time_frame, sustained_time, max_participation_factor, deployed_fraction, ext)

A reserve product with a static [Operating Reserve Demand Curve (ORDC)](https://hepg.hks.harvard.edu/files/hepg/files/ordcupdate-final.pdf)
for operational simulations.

The ORDC is modeled as a discretized set of `(Reserve capacity (MW), Price (\$/MWh))` steps.
For time-varying ORDCs, use [`ReserveDemandTimeSeriesCurve`](@ref).

When defining the reserve, the `ReserveDirection` must be specified to define this as a
[`ReserveUp`](@ref), [`ReserveDown`](@ref), or [`ReserveSymmetric`](@ref).
"""
mutable struct ReserveDemandCurve{T <: ReserveDirection, U <: IS.AbstractUnitSystem} <:
               Reserve{T}
    "Operating reserve demand curve"
    variable::CostCurve{PiecewiseIncrementalCurve, U}
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

function ReserveDemandCurve{T}(
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
    ReserveDemandCurve{T, U}(
        variable, name, available, time_frame, sustained_time,
        max_participation_factor, deployed_fraction, ext,
        InfrastructureSystemsInternal(),
    )
end

function ReserveDemandCurve{T}(;
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
    ReserveDemandCurve{T, U}(
        variable, name, available, time_frame, sustained_time,
        max_participation_factor, deployed_fraction, ext, internal,
    )
end

# Kwarg constructor on the fully-parameterized type — needed by deserialization,
# which resolves `ReserveDemandCurve{T, U}` from metadata and calls it with kwargs.
function ReserveDemandCurve{T, U}(;
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
    ReserveDemandCurve{T, U}(
        variable, name, available, time_frame, sustained_time,
        max_participation_factor, deployed_fraction, ext, internal,
    )
end

# Constructor for demo purposes; non-functional.
function ReserveDemandCurve{T}(::Nothing) where {T <: ReserveDirection}
    ReserveDemandCurve{T}(;
        variable = ZERO_OFFER_CURVE,
        name = "init",
        available = false,
        time_frame = 0.0,
        sustained_time = 0.0,
        max_participation_factor = 1.0,
        deployed_fraction = 0.0,
    )
end

"""Get [`ReserveDemandCurve`](@ref) `variable`."""
get_variable(value::ReserveDemandCurve) = value.variable
"""Get [`ReserveDemandCurve`](@ref) `name`."""
get_name(value::ReserveDemandCurve) = value.name
"""Get [`ReserveDemandCurve`](@ref) `available`."""
get_available(value::ReserveDemandCurve) = value.available
"""Get [`ReserveDemandCurve`](@ref) `time_frame`."""
get_time_frame(value::ReserveDemandCurve) = value.time_frame
"""Get [`ReserveDemandCurve`](@ref) `sustained_time`."""
get_sustained_time(value::ReserveDemandCurve) = value.sustained_time
"""Get [`ReserveDemandCurve`](@ref) `max_participation_factor`."""
get_max_participation_factor(value::ReserveDemandCurve) = value.max_participation_factor
"""Get [`ReserveDemandCurve`](@ref) `deployed_fraction`."""
get_deployed_fraction(value::ReserveDemandCurve) = value.deployed_fraction
"""Get [`ReserveDemandCurve`](@ref) `ext`."""
get_ext(value::ReserveDemandCurve) = value.ext
"""Get [`ReserveDemandCurve`](@ref) `internal`."""
get_internal(value::ReserveDemandCurve) = value.internal

"""Set [`ReserveDemandCurve`](@ref) `variable`."""
set_variable!(value::ReserveDemandCurve, val) = value.variable = val
"""Set [`ReserveDemandCurve`](@ref) `available`."""
set_available!(value::ReserveDemandCurve, val) = value.available = val
"""Set [`ReserveDemandCurve`](@ref) `time_frame`."""
set_time_frame!(value::ReserveDemandCurve, val) = value.time_frame = val
"""Set [`ReserveDemandCurve`](@ref) `sustained_time`."""
set_sustained_time!(value::ReserveDemandCurve, val) = value.sustained_time = val
"""Set [`ReserveDemandCurve`](@ref) `max_participation_factor`."""
set_max_participation_factor!(value::ReserveDemandCurve, val) =
    value.max_participation_factor = val
"""Set [`ReserveDemandCurve`](@ref) `deployed_fraction`."""
set_deployed_fraction!(value::ReserveDemandCurve, val) = value.deployed_fraction = val
"""Set [`ReserveDemandCurve`](@ref) `ext`."""
set_ext!(value::ReserveDemandCurve, val) = value.ext = val
