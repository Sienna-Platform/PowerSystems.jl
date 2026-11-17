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
        scheduled_net_interchange::Union{Nothing, Float64}
        out_of_area_loads::Vector{ElectricLoad}
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
- `scheduled_net_interchange::Union{Nothing, Float64}`: (default: `nothing`) Scheduled net active power interchange of the area (PSS/E PDES): total export minus total import. Positive means the area exports power. `nothing` if the area has no schedule
- `out_of_area_loads::Vector{ElectricLoad}`: (default: `ElectricLoad[]`) Loads that belong to this area but connect to a bus in another area (PSS/E off-area loads)
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
- `input_basis`: (keyword constructor only, required) `u"CU"` or `u"NU"`, the units of bare numbers on unit-bearing fields. Tagged values (`50.0u"MW"`) keep their own units
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
    "Scheduled net active power interchange of the area (PSS/E PDES): total export minus total import. Positive means the area exports power. `nothing` if the area has no schedule"
    scheduled_net_interchange::Union{Nothing, Float64}
    "Loads that belong to this area but connect to a bus in another area (PSS/E off-area loads)"
    out_of_area_loads::Vector{ElectricLoad}
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function Area(name, peak_active_power=0.0, peak_reactive_power=0.0, load_response=0.0, scheduled_net_interchange=nothing, out_of_area_loads=ElectricLoad[], base_power=100.0, ext=Dict{String, Any}(), )
    Area(name, peak_active_power, peak_reactive_power, load_response, scheduled_net_interchange, out_of_area_loads, base_power, ext, InfrastructureSystemsInternal(), )
end

function Area(; name, peak_active_power=0.0, peak_reactive_power=0.0, load_response=0.0, scheduled_net_interchange=nothing, out_of_area_loads=ElectricLoad[], base_power=100.0, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), input_basis::Unitful.Units, )
    value = Area(name, _placeholder(peak_active_power), _placeholder(peak_reactive_power), load_response, _placeholder(scheduled_net_interchange), out_of_area_loads, base_power, ext, internal, )
    set_peak_active_power!(value, _tag(peak_active_power, input_basis, Val(:mw)))
    set_peak_reactive_power!(value, _tag(peak_reactive_power, input_basis, Val(:mvar)))
    set_scheduled_net_interchange!(value, _tag(scheduled_net_interchange, input_basis, Val(:mw)))
    return value
end
_takes_input_basis(::Type{<:Area}) = true

# Constructor for demo purposes; non-functional.
function Area(::Nothing)
    Area(;
        name="init",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        load_response=0.0,
        scheduled_net_interchange=nothing,
        out_of_area_loads=ElectricLoad[],
        base_power=100.0,
        ext=Dict{String, Any}(),
        input_basis=u"CU",
    )
end

"""Get [`Area`](@ref) `name`."""
get_name(value::Area) = value.name
"""Get [`Area`](@ref) `peak_active_power` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_peak_active_power_unitful`](@ref)."""
get_peak_active_power(value::Area, units) = InfrastructureSystems._strip_units(get_value(value, Val(:peak_active_power), Val(:mw), units))
"""Get [`Area`](@ref) `peak_active_power` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_peak_active_power`](@ref)."""
get_peak_active_power_unitful(value::Area, units) = get_value(value, Val(:peak_active_power), Val(:mw), units)
get_peak_active_power(value::Area) = _units_arg_required(get_peak_active_power, value, :peak_active_power, Val(:mw))
get_peak_active_power_unitful(value::Area) = _units_arg_required(get_peak_active_power_unitful, value, :peak_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_peak_active_power), ::Type{Area}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_peak_active_power_unitful), ::Type{Area}) = u"SU"
"""Get [`Area`](@ref) `peak_reactive_power` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_peak_reactive_power_unitful`](@ref)."""
get_peak_reactive_power(value::Area, units) = InfrastructureSystems._strip_units(get_value(value, Val(:peak_reactive_power), Val(:mvar), units))
"""Get [`Area`](@ref) `peak_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_peak_reactive_power`](@ref)."""
get_peak_reactive_power_unitful(value::Area, units) = get_value(value, Val(:peak_reactive_power), Val(:mvar), units)
get_peak_reactive_power(value::Area) = _units_arg_required(get_peak_reactive_power, value, :peak_reactive_power, Val(:mvar))
get_peak_reactive_power_unitful(value::Area) = _units_arg_required(get_peak_reactive_power_unitful, value, :peak_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_peak_reactive_power), ::Type{Area}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_peak_reactive_power_unitful), ::Type{Area}) = u"SU"
"""Get [`Area`](@ref) `load_response`."""
get_load_response(value::Area) = value.load_response
"""Get [`Area`](@ref) `scheduled_net_interchange` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"NU"`, `u"MW"`). For the unit-bearing value see [`get_scheduled_net_interchange_unitful`](@ref)."""
get_scheduled_net_interchange(value::Area, units) = InfrastructureSystems._strip_units(get_value(value, Val(:scheduled_net_interchange), Val(:mw), units))
"""Get [`Area`](@ref) `scheduled_net_interchange` as a unit-bearing quantity in the requested `units` (e.g. `u"SU"`, `u"CU"`, `u"MW"`). For a bare number see [`get_scheduled_net_interchange`](@ref)."""
get_scheduled_net_interchange_unitful(value::Area, units) = get_value(value, Val(:scheduled_net_interchange), Val(:mw), units)
get_scheduled_net_interchange(value::Area) = _units_arg_required(get_scheduled_net_interchange, value, :scheduled_net_interchange, Val(:mw))
get_scheduled_net_interchange_unitful(value::Area) = _units_arg_required(get_scheduled_net_interchange_unitful, value, :scheduled_net_interchange, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_scheduled_net_interchange), ::Type{Area}) = u"SU"
InfrastructureSystems.display_units_arg(::typeof(get_scheduled_net_interchange_unitful), ::Type{Area}) = u"SU"
"""Get [`Area`](@ref) `out_of_area_loads`."""
get_out_of_area_loads(value::Area) = value.out_of_area_loads

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
"""Set [`Area`](@ref) `scheduled_net_interchange`."""
set_scheduled_net_interchange!(value::Area, val) = value.scheduled_net_interchange = set_value(value, Val(:scheduled_net_interchange), val, Val(:mw))
set_scheduled_net_interchange!(value::Area, val::_UntaggedNumber) = _units_tag_required(set_scheduled_net_interchange!, value, :scheduled_net_interchange, Val(:mw), val)
"""Set [`Area`](@ref) `out_of_area_loads`."""
set_out_of_area_loads!(value::Area, val) = value.out_of_area_loads = val
"""Set [`Area`](@ref) `ext`."""
set_ext!(value::Area, val) = value.ext = val
