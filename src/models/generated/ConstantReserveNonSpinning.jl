#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ConstantReserveNonSpinning <: ReserveNonSpinning
        name::String
        available::Bool
        time_frame::Float64
        requirement::Float64
        sustained_time::Float64
        max_output_fraction::Float64
        max_participation_factor::Float64
        deployed_fraction::Float64
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A non-spinning reserve product with a constant procurement requirement, such as 3% of the system base power at all times.

This reserve product includes back-up generators that might not be currently synchronized with the power system, but can come online quickly after an unexpected contingency, such as a transmission line or generator outage. This is only an upwards reserve. For faster-responding upwards or downwards reserves from components already synchronized with the system, see [`ConstantReserve`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `time_frame::Float64`: the saturation time frame in minutes that a participating device must provide its reserve contribution, validation range: `(0, nothing)`
- `requirement::Float64`: the value of required reserves in p.u. ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(0, nothing)`
- `sustained_time::Float64`: (default: `3600.0`) the time in seconds reserve contribution must sustained at a specified level, validation range: `(0, nothing)`
- `max_output_fraction::Float64`: (default: `1.0`) the maximum fraction of each device's output that can be assigned to the service, validation range: `(0, 1)`
- `max_participation_factor::Float64`: (default: `1.0`) the maximum portion [0, 1.0] of the reserve that can be contributed per device, validation range: `(0, 1)`
- `deployed_fraction::Float64`: (default: `0.0`) Fraction of service procurement that is assumed to be actually deployed. Most commonly, this is assumed to be either 0.0 or 1.0, validation range: `(0, 1)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ConstantReserveNonSpinning <: ReserveNonSpinning
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "the saturation time frame in minutes that a participating device must provide its reserve contribution"
    time_frame::Float64
    "the value of required reserves in p.u. ([`SYSTEM_BASE`](@ref per_unit))"
    requirement::Float64
    "the time in seconds reserve contribution must sustained at a specified level"
    sustained_time::Float64
    "the maximum fraction of each device's output that can be assigned to the service"
    max_output_fraction::Float64
    "the maximum portion [0, 1.0] of the reserve that can be contributed per device"
    max_participation_factor::Float64
    "Fraction of service procurement that is assumed to be actually deployed. Most commonly, this is assumed to be either 0.0 or 1.0"
    deployed_fraction::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ConstantReserveNonSpinning(name, available, time_frame, requirement, sustained_time=3600.0, max_output_fraction=1.0, max_participation_factor=1.0, deployed_fraction=0.0, ext=Dict{String, Any}(), )
    ConstantReserveNonSpinning(name, available, time_frame, requirement, sustained_time, max_output_fraction, max_participation_factor, deployed_fraction, ext, InfrastructureSystemsInternal(), )
end

function ConstantReserveNonSpinning(; name, available, time_frame, requirement, sustained_time=3600.0, max_output_fraction=1.0, max_participation_factor=1.0, deployed_fraction=0.0, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    ConstantReserveNonSpinning(name, available, time_frame, requirement, sustained_time, max_output_fraction, max_participation_factor, deployed_fraction, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function ConstantReserveNonSpinning(::Nothing)
    ConstantReserveNonSpinning(;
        name="init",
        available=false,
        time_frame=0.0,
        requirement=0.0,
        sustained_time=0.0,
        max_output_fraction=1.0,
        max_participation_factor=1.0,
        deployed_fraction=0.0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ConstantReserveNonSpinning`](@ref) `name`."""
get_name(value::ConstantReserveNonSpinning) = value.name
"""Get [`ConstantReserveNonSpinning`](@ref) `available`."""
get_available(value::ConstantReserveNonSpinning) = value.available
"""Get [`ConstantReserveNonSpinning`](@ref) `time_frame`."""
get_time_frame(value::ConstantReserveNonSpinning) = value.time_frame
"""Get [`ConstantReserveNonSpinning`](@ref) `requirement`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_requirement(value::ConstantReserveNonSpinning) = get_value(value, Val(:requirement), Val(:mva), DEFAULT_UNITS)
get_requirement(value::ConstantReserveNonSpinning, units) = get_value(value, Val(:requirement), Val(:mva), units)
"""Get [`ConstantReserveNonSpinning`](@ref) `sustained_time`."""
get_sustained_time(value::ConstantReserveNonSpinning) = value.sustained_time
"""Get [`ConstantReserveNonSpinning`](@ref) `max_output_fraction`."""
get_max_output_fraction(value::ConstantReserveNonSpinning) = value.max_output_fraction
"""Get [`ConstantReserveNonSpinning`](@ref) `max_participation_factor`."""
get_max_participation_factor(value::ConstantReserveNonSpinning) = value.max_participation_factor
"""Get [`ConstantReserveNonSpinning`](@ref) `deployed_fraction`."""
get_deployed_fraction(value::ConstantReserveNonSpinning) = value.deployed_fraction
"""Get [`ConstantReserveNonSpinning`](@ref) `ext`."""
get_ext(value::ConstantReserveNonSpinning) = value.ext
"""Get [`ConstantReserveNonSpinning`](@ref) `internal`."""
get_internal(value::ConstantReserveNonSpinning) = value.internal

"""Set [`ConstantReserveNonSpinning`](@ref) `available`."""
set_available!(value::ConstantReserveNonSpinning, val) = value.available = val
"""Set [`ConstantReserveNonSpinning`](@ref) `time_frame`."""
set_time_frame!(value::ConstantReserveNonSpinning, val) = value.time_frame = val
"""Set [`ConstantReserveNonSpinning`](@ref) `requirement`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_requirement!(value::ConstantReserveNonSpinning, val) = value.requirement = set_value(value, Val(:requirement), val, Val(:mva))
"""Set [`ConstantReserveNonSpinning`](@ref) `sustained_time`."""
set_sustained_time!(value::ConstantReserveNonSpinning, val) = value.sustained_time = val
"""Set [`ConstantReserveNonSpinning`](@ref) `max_output_fraction`."""
set_max_output_fraction!(value::ConstantReserveNonSpinning, val) = value.max_output_fraction = val
"""Set [`ConstantReserveNonSpinning`](@ref) `max_participation_factor`."""
set_max_participation_factor!(value::ConstantReserveNonSpinning, val) = value.max_participation_factor = val
"""Set [`ConstantReserveNonSpinning`](@ref) `deployed_fraction`."""
set_deployed_fraction!(value::ConstantReserveNonSpinning, val) = value.deployed_fraction = val
"""Set [`ConstantReserveNonSpinning`](@ref) `ext`."""
set_ext!(value::ConstantReserveNonSpinning, val) = value.ext = val
