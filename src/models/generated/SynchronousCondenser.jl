#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SynchronousCondenser <: StaticInjection
        name::String
        available::Bool
        bus::ACBus
        reactive_power::Float64
        rating::Float64
        reactive_power_limits::Union{Nothing, MinMax}
        base_power::Float64
        active_power_losses::Float64
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A Synchronous Machine connected to the system to provide inertia or reactive power support

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR), validation range: `reactive_power_limits`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power, validation range: `(0, nothing)`
- `reactive_power_limits::Union{Nothing, MinMax}`: Minimum and maximum reactive power limits. Set to `Nothing` if not applicable
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `active_power_losses::Float64`: (default: `0.0`) Active Power Loss incurred by having the unit online., validation range: `(0, nothing)`
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct SynchronousCondenser <: StaticInjection
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Initial reactive power set point of the unit (MVAR)"
    reactive_power::Float64
    "Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power"
    rating::Float64
    "Minimum and maximum reactive power limits. Set to `Nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Active Power Loss incurred by having the unit online."
    active_power_losses::Float64
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function SynchronousCondenser(name, available, bus, reactive_power, rating, reactive_power_limits, base_power, active_power_losses=0.0, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    SynchronousCondenser(name, available, bus, reactive_power, rating, reactive_power_limits, base_power, active_power_losses, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function SynchronousCondenser(; name, available, bus, reactive_power, rating, reactive_power_limits, base_power, active_power_losses=0.0, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    SynchronousCondenser(name, available, bus, reactive_power, rating, reactive_power_limits, base_power, active_power_losses, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function SynchronousCondenser(::Nothing)
    SynchronousCondenser(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        reactive_power=0.0,
        rating=0.0,
        reactive_power_limits=nothing,
        base_power=100.0,
        active_power_losses=0.0,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`SynchronousCondenser`](@ref) `name`."""
get_name(value::SynchronousCondenser) = value.name
"""Get [`SynchronousCondenser`](@ref) `available`."""
get_available(value::SynchronousCondenser) = value.available
"""Get [`SynchronousCondenser`](@ref) `bus`."""
get_bus(value::SynchronousCondenser) = value.bus
"""Get [`SynchronousCondenser`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::SynchronousCondenser, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`SynchronousCondenser`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::SynchronousCondenser, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::SynchronousCondenser) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::SynchronousCondenser) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{SynchronousCondenser}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{SynchronousCondenser}) = InfrastructureSystems.SU
"""Get [`SynchronousCondenser`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::SynchronousCondenser, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`SynchronousCondenser`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::SynchronousCondenser, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::SynchronousCondenser) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::SynchronousCondenser) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{SynchronousCondenser}) = InfrastructureSystems.DU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{SynchronousCondenser}) = InfrastructureSystems.DU
"""Get [`SynchronousCondenser`](@ref) `reactive_power_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_unitful`](@ref)."""
get_reactive_power_limits(value::SynchronousCondenser, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits), Val(:mvar), units))
"""Get [`SynchronousCondenser`](@ref) `reactive_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_limits`](@ref)."""
get_reactive_power_limits_unitful(value::SynchronousCondenser, units) = get_value(value, Val(:reactive_power_limits), Val(:mvar), units)
get_reactive_power_limits(value::SynchronousCondenser) = _units_arg_required(get_reactive_power_limits, value, :reactive_power_limits, Val(:mvar))
get_reactive_power_limits_unitful(value::SynchronousCondenser) = _units_arg_required(get_reactive_power_limits_unitful, value, :reactive_power_limits, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits), ::Type{SynchronousCondenser}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_unitful), ::Type{SynchronousCondenser}) = InfrastructureSystems.SU

_get_base_power(value::SynchronousCondenser) = value.base_power
"""Get [`SynchronousCondenser`](@ref) `active_power_losses` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_losses_unitful`](@ref)."""
get_active_power_losses(value::SynchronousCondenser, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_losses), Val(:mw), units))
"""Get [`SynchronousCondenser`](@ref) `active_power_losses` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_losses`](@ref)."""
get_active_power_losses_unitful(value::SynchronousCondenser, units) = get_value(value, Val(:active_power_losses), Val(:mw), units)
get_active_power_losses(value::SynchronousCondenser) = _units_arg_required(get_active_power_losses, value, :active_power_losses, Val(:mw))
get_active_power_losses_unitful(value::SynchronousCondenser) = _units_arg_required(get_active_power_losses_unitful, value, :active_power_losses, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_losses), ::Type{SynchronousCondenser}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_losses_unitful), ::Type{SynchronousCondenser}) = InfrastructureSystems.SU
"""Get [`SynchronousCondenser`](@ref) `services`."""
get_services(value::SynchronousCondenser) = value.services
"""Get [`SynchronousCondenser`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::SynchronousCondenser) = value.dynamic_injector
"""Get [`SynchronousCondenser`](@ref) `ext`."""
get_ext(value::SynchronousCondenser) = value.ext
"""Get [`SynchronousCondenser`](@ref) `internal`."""
get_internal(value::SynchronousCondenser) = value.internal

"""Set [`SynchronousCondenser`](@ref) `available`."""
set_available!(value::SynchronousCondenser, val) = value.available = val
"""Set [`SynchronousCondenser`](@ref) `bus`."""
set_bus!(value::SynchronousCondenser, val) = value.bus = val
"""Set [`SynchronousCondenser`](@ref) `reactive_power`."""
set_reactive_power!(value::SynchronousCondenser, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::SynchronousCondenser, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`SynchronousCondenser`](@ref) `rating`."""
set_rating!(value::SynchronousCondenser, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::SynchronousCondenser, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`SynchronousCondenser`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::SynchronousCondenser, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mvar))
set_reactive_power_limits!(value::SynchronousCondenser, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
set_reactive_power_limits!(value::SynchronousCondenser, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
"""Set [`SynchronousCondenser`](@ref) `active_power_losses`."""
set_active_power_losses!(value::SynchronousCondenser, val) = value.active_power_losses = set_value(value, Val(:active_power_losses), val, Val(:mw))
set_active_power_losses!(value::SynchronousCondenser, val::_UntaggedNumber) = _units_tag_required(set_active_power_losses!, value, :active_power_losses, Val(:mw), val)
"""Set [`SynchronousCondenser`](@ref) `services`."""
set_services!(value::SynchronousCondenser, val) = value.services = val
"""Set [`SynchronousCondenser`](@ref) `ext`."""
set_ext!(value::SynchronousCondenser, val) = value.ext = val


function from_openapi(po::PO.SynchronousCondenser, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return SynchronousCondenser(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        reactive_power = po.reactive_power,
        rating = po.rating,
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits),
        base_power = po.base_power,
        active_power_losses = po.active_power_losses,
    )
end

function from_openapi(po::PO.SynchronousCondenser, refs::OpenAPIRefs, ::NaturalUnit)
    return SynchronousCondenser(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        reactive_power = po.reactive_power / po.base_power,
        rating = po.rating / po.base_power,
        reactive_power_limits = _minmax_from_po(po.reactive_power_limits, (/), po.base_power),
        base_power = po.base_power,
        active_power_losses = po.active_power_losses / po.base_power,
    )
end

function from_openapi(po::PO.SynchronousCondenser, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("SynchronousCondenser", po.id, po.power_units))
end

function to_openapi(value::SynchronousCondenser, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PO.SynchronousCondenser(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        reactive_power = get_reactive_power(value, DU),
        rating = get_rating(value, DU),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(value, DU)),
        base_power = _get_base_power(value),
        active_power_losses = get_active_power_losses(value, DU),
        power_units = _power_units_string(DU),
    )
end

function to_openapi(value::SynchronousCondenser, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.SynchronousCondenser(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        reactive_power = get_reactive_power(value, DU) * _get_base_power(value),
        rating = get_rating(value, DU) * _get_base_power(value),
        reactive_power_limits = _minmax_po_scaled_optional(get_reactive_power_limits(value, DU), _get_base_power(value)),
        base_power = _get_base_power(value),
        active_power_losses = get_active_power_losses(value, DU) * _get_base_power(value),
        power_units = _power_units_string(NU),
    )
end
