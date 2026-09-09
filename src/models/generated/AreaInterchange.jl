#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct AreaInterchange <: Branch
        name::String
        available::Bool
        active_power_flow::Float64
        from_area::Area
        to_area::Area
        flow_limits::FromTo_ToFrom
        base_power::Float64
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

Flow exchanged between Areas. This Interchange is agnostic to the lines connecting the areas. It does not substitute Interface which is the total flow across a group of lines

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow on the line (MW)
- `from_area::Area`: Area from which the power is extracted
- `to_area::Area`: Area to which the power is injected
- `flow_limits::FromTo_ToFrom`: Max flow between the areas. It ignores lines and other branches totals
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
- `services::Vector{Service}`: (default: `Service[]`) Service interfaces that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct AreaInterchange <: Branch
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Initial condition of active power flow on the line (MW)"
    active_power_flow::Float64
    "Area from which the power is extracted"
    from_area::Area
    "Area to which the power is injected"
    to_area::Area
    "Max flow between the areas. It ignores lines and other branches totals"
    flow_limits::FromTo_ToFrom
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "Service interfaces that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function AreaInterchange(name, available, active_power_flow, from_area, to_area, flow_limits, base_power=100.0, services=Service[], ext=Dict{String, Any}(), )
    AreaInterchange(name, available, active_power_flow, from_area, to_area, flow_limits, base_power, services, ext, InfrastructureSystemsInternal(), )
end

function AreaInterchange(; name, available, active_power_flow, from_area, to_area, flow_limits, base_power=100.0, services=Service[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    AreaInterchange(name, available, active_power_flow, from_area, to_area, flow_limits, base_power, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function AreaInterchange(::Nothing)
    AreaInterchange(;
        name="init",
        available=false,
        active_power_flow=0.0,
        from_area=Area(nothing),
        to_area=Area(nothing),
        flow_limits=(from_to=0.0, to_from=0.0),
        base_power=100.0,
        services=Service[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`AreaInterchange`](@ref) `name`."""
get_name(value::AreaInterchange) = value.name
"""Get [`AreaInterchange`](@ref) `available`."""
get_available(value::AreaInterchange) = value.available
"""Get [`AreaInterchange`](@ref) `active_power_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_flow_unitful`](@ref)."""
get_active_power_flow(value::AreaInterchange, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_flow), Val(:mw), units))
"""Get [`AreaInterchange`](@ref) `active_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_flow`](@ref)."""
get_active_power_flow_unitful(value::AreaInterchange, units) = get_value(value, Val(:active_power_flow), Val(:mw), units)
get_active_power_flow(value::AreaInterchange) = _units_arg_required(get_active_power_flow, value, :active_power_flow, Val(:mw))
get_active_power_flow_unitful(value::AreaInterchange) = _units_arg_required(get_active_power_flow_unitful, value, :active_power_flow, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{AreaInterchange}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_unitful), ::Type{AreaInterchange}) = InfrastructureSystems.SU
"""Get [`AreaInterchange`](@ref) `from_area`."""
get_from_area(value::AreaInterchange) = value.from_area
"""Get [`AreaInterchange`](@ref) `to_area`."""
get_to_area(value::AreaInterchange) = value.to_area
"""Get [`AreaInterchange`](@ref) `flow_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_flow_limits_unitful`](@ref)."""
get_flow_limits(value::AreaInterchange, units) = InfrastructureSystems._strip_units(get_value(value, Val(:flow_limits), Val(:mw), units))
"""Get [`AreaInterchange`](@ref) `flow_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_flow_limits`](@ref)."""
get_flow_limits_unitful(value::AreaInterchange, units) = get_value(value, Val(:flow_limits), Val(:mw), units)
get_flow_limits(value::AreaInterchange) = _units_arg_required(get_flow_limits, value, :flow_limits, Val(:mw))
get_flow_limits_unitful(value::AreaInterchange) = _units_arg_required(get_flow_limits_unitful, value, :flow_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_flow_limits), ::Type{AreaInterchange}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_flow_limits_unitful), ::Type{AreaInterchange}) = InfrastructureSystems.SU

_get_base_power(value::AreaInterchange) = value.base_power
"""Get [`AreaInterchange`](@ref) `services`."""
get_services(value::AreaInterchange) = value.services
"""Get [`AreaInterchange`](@ref) `ext`."""
get_ext(value::AreaInterchange) = value.ext
"""Get [`AreaInterchange`](@ref) `internal`."""
get_internal(value::AreaInterchange) = value.internal

"""Set [`AreaInterchange`](@ref) `available`."""
set_available!(value::AreaInterchange, val) = value.available = val
"""Set [`AreaInterchange`](@ref) `active_power_flow`."""
set_active_power_flow!(value::AreaInterchange, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mw))
set_active_power_flow!(value::AreaInterchange, val::_UntaggedNumber) = _units_tag_required(set_active_power_flow!, value, :active_power_flow, Val(:mw), val)
"""Set [`AreaInterchange`](@ref) `from_area`."""
set_from_area!(value::AreaInterchange, val) = value.from_area = val
"""Set [`AreaInterchange`](@ref) `to_area`."""
set_to_area!(value::AreaInterchange, val) = value.to_area = val
"""Set [`AreaInterchange`](@ref) `flow_limits`."""
set_flow_limits!(value::AreaInterchange, val) = value.flow_limits = set_value(value, Val(:flow_limits), val, Val(:mw))
set_flow_limits!(value::AreaInterchange, val::_UntaggedNumber) = _units_tag_required(set_flow_limits!, value, :flow_limits, Val(:mw), val)
set_flow_limits!(value::AreaInterchange, val::NamedTuple{(:from_to, :to_from), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_flow_limits!, value, :flow_limits, Val(:mw), val)
"""Set [`AreaInterchange`](@ref) `services`."""
set_services!(value::AreaInterchange, val) = value.services = val
"""Set [`AreaInterchange`](@ref) `ext`."""
set_ext!(value::AreaInterchange, val) = value.ext = val


function from_openapi(po::PO.AreaInterchange, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return AreaInterchange(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow,
        from_area = resolve_ref(refs, po.from_area, Area),
        to_area = resolve_ref(refs, po.to_area, Area),
        flow_limits = _fromto_tofrom_from_po(po.flow_limits),
        base_power = po.base_power,
    )
end

function from_openapi(po::PO.AreaInterchange, refs::OpenAPIRefs, ::NaturalUnit)
    return AreaInterchange(;
        name = po.name,
        available = po.available,
        active_power_flow = po.active_power_flow / po.base_power,
        from_area = resolve_ref(refs, po.from_area, Area),
        to_area = resolve_ref(refs, po.to_area, Area),
        flow_limits = _fromto_tofrom_from_po(po.flow_limits, (/), po.base_power),
        base_power = po.base_power,
    )
end

function from_openapi(po::PO.AreaInterchange, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("AreaInterchange", po.id, po.power_units))
end

function to_openapi(value::AreaInterchange, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PO.AreaInterchange(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        active_power_flow = get_active_power_flow(value, SU),
        from_area = component_id(refs, get_from_area(value)),
        to_area = component_id(refs, get_to_area(value)),
        flow_limits = _fromto_tofrom_po(get_flow_limits(value, SU)),
        base_power = get_base_power(refs),
        power_units = _power_units_string(DU),
    )
end

function to_openapi(value::AreaInterchange, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.AreaInterchange(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        active_power_flow = get_active_power_flow(value, SU) * get_base_power(refs),
        from_area = component_id(refs, get_from_area(value)),
        to_area = component_id(refs, get_to_area(value)),
        flow_limits = _fromto_tofrom_po_scaled(get_flow_limits(value, SU), get_base_power(refs)),
        base_power = get_base_power(refs),
        power_units = _power_units_string(NU),
    )
end
