#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct InterconnectingConverter <: StaticInjection
        name::String
        available::Bool
        bus::ACBus
        dc_bus::DCBus
        active_power::Float64
        rating::Float64
        active_power_limits::MinMax
        base_power::Float64
        dc_current::Float64
        max_dc_current::Float64
        loss_function::Union{LinearCurve, QuadraticCurve}
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

Interconnecting Power Converter (IPC) for transforming power from an ACBus to a DCBus

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus on the AC side of this converter
- `dc_bus::DCBus`: Bus on the DC side of this converter
- `active_power::Float64`: Active power (MW) on the DC side, validation range: `active_power_limits`
- `rating::Float64`: Maximum output power rating of the converter (MVA), validation range: `(0, nothing)`
- `active_power_limits::MinMax`: Minimum and maximum stable active power levels (MW)
- `base_power::Float64`: Base power of the converter in MVA, validation range: `(0.0001, nothing)`
- `dc_current::Float64`: (default: `0.0`) DC current (A) on the converter
- `max_dc_current::Float64`: (default: `1e8`) Maximum stable dc current limits (A)
- `loss_function::Union{LinearCurve, QuadraticCurve}`: (default: `LinearCurve(0.0)`) Linear or quadratic loss function with respect to the converter current
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct InterconnectingConverter <: StaticInjection
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus on the AC side of this converter"
    bus::ACBus
    "Bus on the DC side of this converter"
    dc_bus::DCBus
    "Active power (MW) on the DC side"
    active_power::Float64
    "Maximum output power rating of the converter (MVA)"
    rating::Float64
    "Minimum and maximum stable active power levels (MW)"
    active_power_limits::MinMax
    "Base power of the converter in MVA"
    base_power::Float64
    "DC current (A) on the converter"
    dc_current::Float64
    "Maximum stable dc current limits (A)"
    max_dc_current::Float64
    "Linear or quadratic loss function with respect to the converter current"
    loss_function::Union{LinearCurve, QuadraticCurve}
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function InterconnectingConverter(name, available, bus, dc_bus, active_power, rating, active_power_limits, base_power, dc_current=0.0, max_dc_current=1e8, loss_function=LinearCurve(0.0), services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    InterconnectingConverter(name, available, bus, dc_bus, active_power, rating, active_power_limits, base_power, dc_current, max_dc_current, loss_function, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function InterconnectingConverter(; name, available, bus, dc_bus, active_power, rating, active_power_limits, base_power, dc_current=0.0, max_dc_current=1e8, loss_function=LinearCurve(0.0), services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    InterconnectingConverter(name, available, bus, dc_bus, active_power, rating, active_power_limits, base_power, dc_current, max_dc_current, loss_function, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function InterconnectingConverter(::Nothing)
    InterconnectingConverter(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        dc_bus=DCBus(nothing),
        active_power=0.0,
        rating=0.0,
        active_power_limits=(min=0.0, max=0.0),
        base_power=100,
        dc_current=0.0,
        max_dc_current=0.0,
        loss_function=LinearCurve(0.0),
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`InterconnectingConverter`](@ref) `name`."""
get_name(value::InterconnectingConverter) = value.name
"""Get [`InterconnectingConverter`](@ref) `available`."""
get_available(value::InterconnectingConverter) = value.available
"""Get [`InterconnectingConverter`](@ref) `bus`."""
get_bus(value::InterconnectingConverter) = value.bus
"""Get [`InterconnectingConverter`](@ref) `dc_bus`."""
get_dc_bus(value::InterconnectingConverter) = value.dc_bus
"""Get [`InterconnectingConverter`](@ref) `active_power`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_active_power(value::InterconnectingConverter) = get_value(value, Val(:active_power), Val(:mva), DEFAULT_UNITS)
get_active_power(value::InterconnectingConverter, units) = get_value(value, Val(:active_power), Val(:mva), units)
"""Get [`InterconnectingConverter`](@ref) `rating`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_rating(value::InterconnectingConverter) = get_value(value, Val(:rating), Val(:mva), DEFAULT_UNITS)
get_rating(value::InterconnectingConverter, units) = get_value(value, Val(:rating), Val(:mva), units)
"""Get [`InterconnectingConverter`](@ref) `active_power_limits`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_active_power_limits(value::InterconnectingConverter) = get_value(value, Val(:active_power_limits), Val(:mva), DEFAULT_UNITS)
get_active_power_limits(value::InterconnectingConverter, units) = get_value(value, Val(:active_power_limits), Val(:mva), units)

_get_base_power(value::InterconnectingConverter) = value.base_power
"""Get [`InterconnectingConverter`](@ref) `dc_current`."""
get_dc_current(value::InterconnectingConverter) = value.dc_current
"""Get [`InterconnectingConverter`](@ref) `max_dc_current`."""
get_max_dc_current(value::InterconnectingConverter) = value.max_dc_current
"""Get [`InterconnectingConverter`](@ref) `loss_function`."""
get_loss_function(value::InterconnectingConverter) = value.loss_function
"""Get [`InterconnectingConverter`](@ref) `services`."""
get_services(value::InterconnectingConverter) = value.services
"""Get [`InterconnectingConverter`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::InterconnectingConverter) = value.dynamic_injector
"""Get [`InterconnectingConverter`](@ref) `ext`."""
get_ext(value::InterconnectingConverter) = value.ext
"""Get [`InterconnectingConverter`](@ref) `internal`."""
get_internal(value::InterconnectingConverter) = value.internal

"""Set [`InterconnectingConverter`](@ref) `available`."""
set_available!(value::InterconnectingConverter, val) = value.available = val
"""Set [`InterconnectingConverter`](@ref) `bus`."""
set_bus!(value::InterconnectingConverter, val) = value.bus = val
"""Set [`InterconnectingConverter`](@ref) `dc_bus`."""
set_dc_bus!(value::InterconnectingConverter, val) = value.dc_bus = val
"""Set [`InterconnectingConverter`](@ref) `active_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power!(value::InterconnectingConverter, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`InterconnectingConverter`](@ref) `rating`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating!(value::InterconnectingConverter, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`InterconnectingConverter`](@ref) `active_power_limits`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_limits!(value::InterconnectingConverter, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mva))
"""Set [`InterconnectingConverter`](@ref) `dc_current`."""
set_dc_current!(value::InterconnectingConverter, val) = value.dc_current = val
"""Set [`InterconnectingConverter`](@ref) `max_dc_current`."""
set_max_dc_current!(value::InterconnectingConverter, val) = value.max_dc_current = val
"""Set [`InterconnectingConverter`](@ref) `loss_function`."""
set_loss_function!(value::InterconnectingConverter, val) = value.loss_function = val
"""Set [`InterconnectingConverter`](@ref) `services`."""
set_services!(value::InterconnectingConverter, val) = value.services = val
"""Set [`InterconnectingConverter`](@ref) `ext`."""
set_ext!(value::InterconnectingConverter, val) = value.ext = val
