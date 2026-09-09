#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct LoadZone <: AggregationTopology
        name::String
        peak_active_power::Float64
        peak_reactive_power::Float64
        base_power::Float64
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A load zone for electricity price analysis.

The load zone can be specified when defining each [`ACBus`](@ref) or [`DCBus`](@ref) in the zone

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `peak_active_power::Float64`: Peak active power in the zone (MW)
- `peak_reactive_power::Float64`: Peak reactive power in the zone (MVAR)
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
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
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function LoadZone(name, peak_active_power, peak_reactive_power, base_power=100.0, ext=Dict{String, Any}(), )
    LoadZone(name, peak_active_power, peak_reactive_power, base_power, ext, InfrastructureSystemsInternal(), )
end

function LoadZone(; name, peak_active_power, peak_reactive_power, base_power=100.0, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    LoadZone(name, peak_active_power, peak_reactive_power, base_power, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function LoadZone(::Nothing)
    LoadZone(;
        name="init",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        base_power=100.0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`LoadZone`](@ref) `name`."""
get_name(value::LoadZone) = value.name
"""Get [`LoadZone`](@ref) `peak_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_peak_active_power_unitful`](@ref)."""
get_peak_active_power(value::LoadZone, units) = InfrastructureSystems._strip_units(get_value(value, Val(:peak_active_power), Val(:mw), units))
"""Get [`LoadZone`](@ref) `peak_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_peak_active_power`](@ref)."""
get_peak_active_power_unitful(value::LoadZone, units) = get_value(value, Val(:peak_active_power), Val(:mw), units)
get_peak_active_power(value::LoadZone) = _units_arg_required(get_peak_active_power, value, :peak_active_power, Val(:mw))
get_peak_active_power_unitful(value::LoadZone) = _units_arg_required(get_peak_active_power_unitful, value, :peak_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_peak_active_power), ::Type{LoadZone}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_peak_active_power_unitful), ::Type{LoadZone}) = InfrastructureSystems.SU
"""Get [`LoadZone`](@ref) `peak_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_peak_reactive_power_unitful`](@ref)."""
get_peak_reactive_power(value::LoadZone, units) = InfrastructureSystems._strip_units(get_value(value, Val(:peak_reactive_power), Val(:mvar), units))
"""Get [`LoadZone`](@ref) `peak_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_peak_reactive_power`](@ref)."""
get_peak_reactive_power_unitful(value::LoadZone, units) = get_value(value, Val(:peak_reactive_power), Val(:mvar), units)
get_peak_reactive_power(value::LoadZone) = _units_arg_required(get_peak_reactive_power, value, :peak_reactive_power, Val(:mvar))
get_peak_reactive_power_unitful(value::LoadZone) = _units_arg_required(get_peak_reactive_power_unitful, value, :peak_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_peak_reactive_power), ::Type{LoadZone}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_peak_reactive_power_unitful), ::Type{LoadZone}) = InfrastructureSystems.SU

_get_base_power(value::LoadZone) = value.base_power
"""Get [`LoadZone`](@ref) `ext`."""
get_ext(value::LoadZone) = value.ext
"""Get [`LoadZone`](@ref) `internal`."""
get_internal(value::LoadZone) = value.internal

"""Set [`LoadZone`](@ref) `peak_active_power`."""
set_peak_active_power!(value::LoadZone, val) = value.peak_active_power = set_value(value, Val(:peak_active_power), val, Val(:mw))
set_peak_active_power!(value::LoadZone, val::_UntaggedNumber) = _units_tag_required(set_peak_active_power!, value, :peak_active_power, Val(:mw), val)
"""Set [`LoadZone`](@ref) `peak_reactive_power`."""
set_peak_reactive_power!(value::LoadZone, val) = value.peak_reactive_power = set_value(value, Val(:peak_reactive_power), val, Val(:mvar))
set_peak_reactive_power!(value::LoadZone, val::_UntaggedNumber) = _units_tag_required(set_peak_reactive_power!, value, :peak_reactive_power, Val(:mvar), val)
"""Set [`LoadZone`](@ref) `ext`."""
set_ext!(value::LoadZone, val) = value.ext = val
