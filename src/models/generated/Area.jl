#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct Area <: AggregationTopology
        name::String
        peak_active_power::Float64
        peak_reactive_power::Float64
        load_response::Float64
        base_power::Float64
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A collection of buses for control purposes.

The `Area` can be specified when defining each [`ACBus`](@ref) or [`DCBus`](@ref) in the area

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `peak_active_power::Float64`: (default: `0.0`) Peak active power in the area
- `peak_reactive_power::Float64`: (default: `0.0`) Peak reactive power in the area
- `load_response::Float64`: (default: `0.0`) Load-frequency damping parameter modeling how much the load in the area changes due to changes in frequency (MW/Hz). [Example here.](https://doi.org/10.1109/NAPS50074.2021.9449687)
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct Area <: AggregationTopology
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Peak active power in the area"
    peak_active_power::Float64
    "Peak reactive power in the area"
    peak_reactive_power::Float64
    "Load-frequency damping parameter modeling how much the load in the area changes due to changes in frequency (MW/Hz). [Example here.](https://doi.org/10.1109/NAPS50074.2021.9449687)"
    load_response::Float64
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function Area(name, peak_active_power=0.0, peak_reactive_power=0.0, load_response=0.0, base_power=100.0, ext=Dict{String, Any}(), )
    Area(name, peak_active_power, peak_reactive_power, load_response, base_power, ext, InfrastructureSystemsInternal(), )
end

function Area(; name, peak_active_power=0.0, peak_reactive_power=0.0, load_response=0.0, base_power=100.0, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    Area(name, peak_active_power, peak_reactive_power, load_response, base_power, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function Area(::Nothing)
    Area(;
        name="init",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        load_response=0.0,
        base_power=100.0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`Area`](@ref) `name`."""
get_name(value::Area) = value.name
"""Get [`Area`](@ref) `peak_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_peak_active_power_unitful`](@ref)."""
get_peak_active_power(value::Area, units) = InfrastructureSystems._strip_units(get_value(value, Val(:peak_active_power), Val(:mw), units))
"""Get [`Area`](@ref) `peak_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_peak_active_power`](@ref)."""
get_peak_active_power_unitful(value::Area, units) = get_value(value, Val(:peak_active_power), Val(:mw), units)
get_peak_active_power(value::Area) = _units_arg_required(get_peak_active_power, value, :peak_active_power, Val(:mw))
get_peak_active_power_unitful(value::Area) = _units_arg_required(get_peak_active_power_unitful, value, :peak_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_peak_active_power), ::Type{Area}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_peak_active_power_unitful), ::Type{Area}) = InfrastructureSystems.SU
"""Get [`Area`](@ref) `peak_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_peak_reactive_power_unitful`](@ref)."""
get_peak_reactive_power(value::Area, units) = InfrastructureSystems._strip_units(get_value(value, Val(:peak_reactive_power), Val(:mvar), units))
"""Get [`Area`](@ref) `peak_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_peak_reactive_power`](@ref)."""
get_peak_reactive_power_unitful(value::Area, units) = get_value(value, Val(:peak_reactive_power), Val(:mvar), units)
get_peak_reactive_power(value::Area) = _units_arg_required(get_peak_reactive_power, value, :peak_reactive_power, Val(:mvar))
get_peak_reactive_power_unitful(value::Area) = _units_arg_required(get_peak_reactive_power_unitful, value, :peak_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_peak_reactive_power), ::Type{Area}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_peak_reactive_power_unitful), ::Type{Area}) = InfrastructureSystems.SU
"""Get [`Area`](@ref) `load_response`."""
get_load_response(value::Area) = value.load_response

_get_base_power(value::Area) = value.base_power
"""Get [`Area`](@ref) `ext`."""
get_ext(value::Area) = value.ext
"""Get [`Area`](@ref) `internal`."""
get_internal(value::Area) = value.internal

"""Set [`Area`](@ref) `peak_active_power`."""
set_peak_active_power!(value::Area, val) = value.peak_active_power = set_value(value, Val(:peak_active_power), val, Val(:mw))
set_peak_active_power!(value::Area, val::_UntaggedNumber) = _units_tag_required(set_peak_active_power!, value, :peak_active_power, Val(:mw), val)
"""Set [`Area`](@ref) `peak_reactive_power`."""
set_peak_reactive_power!(value::Area, val) = value.peak_reactive_power = set_value(value, Val(:peak_reactive_power), val, Val(:mvar))
set_peak_reactive_power!(value::Area, val::_UntaggedNumber) = _units_tag_required(set_peak_reactive_power!, value, :peak_reactive_power, Val(:mvar), val)
"""Set [`Area`](@ref) `load_response`."""
set_load_response!(value::Area, val) = value.load_response = val
"""Set [`Area`](@ref) `ext`."""
set_ext!(value::Area, val) = value.ext = val
