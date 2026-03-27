#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct LoadZone <: AggregationTopology
        name::String
        peak_active_power::Float64
        peak_reactive_power::Float64
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A load zone for electricity price analysis.

The load zone can be specified when defining each [`ACBus`](@ref) or [`DCBus`](@ref) in the zone

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `peak_active_power::Float64`: Peak active power in the zone (MW)
- `peak_reactive_power::Float64`: Peak reactive power in the zone (MVAR)
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct LoadZone <: AggregationTopology
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Peak active power in the zone (MW)"
    peak_active_power::Float64
    "Peak reactive power in the zone (MVAR)"
    peak_reactive_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function LoadZone(name, peak_active_power, peak_reactive_power, ext=Dict{String, Any}(), )
    LoadZone(name, peak_active_power, peak_reactive_power, ext, InfrastructureSystemsInternal(), )
end

function LoadZone(; name, peak_active_power, peak_reactive_power, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    LoadZone(name, peak_active_power, peak_reactive_power, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function LoadZone(::Nothing)
    LoadZone(;
        name="init",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`LoadZone`](@ref) `name`."""
get_name(value::LoadZone) = value.name
"""Get [`LoadZone`](@ref) `peak_active_power`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_peak_active_power(value::LoadZone) = get_value(value, Val(:peak_active_power), Val(:mva), DEFAULT_UNITS)
get_peak_active_power(value::LoadZone, units) = get_value(value, Val(:peak_active_power), Val(:mva), units)
"""Get [`LoadZone`](@ref) `peak_reactive_power`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_peak_reactive_power(value::LoadZone) = get_value(value, Val(:peak_reactive_power), Val(:mva), DEFAULT_UNITS)
get_peak_reactive_power(value::LoadZone, units) = get_value(value, Val(:peak_reactive_power), Val(:mva), units)
"""Get [`LoadZone`](@ref) `ext`."""
get_ext(value::LoadZone) = value.ext
"""Get [`LoadZone`](@ref) `internal`."""
get_internal(value::LoadZone) = value.internal

"""Set [`LoadZone`](@ref) `peak_active_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_peak_active_power!(value::LoadZone, val) = value.peak_active_power = set_value(value, Val(:peak_active_power), val, Val(:mva))
"""Set [`LoadZone`](@ref) `peak_reactive_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_peak_reactive_power!(value::LoadZone, val) = value.peak_reactive_power = set_value(value, Val(:peak_reactive_power), val, Val(:mva))
"""Set [`LoadZone`](@ref) `ext`."""
set_ext!(value::LoadZone, val) = value.ext = val
