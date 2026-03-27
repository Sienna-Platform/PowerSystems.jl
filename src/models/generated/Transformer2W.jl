#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct Transformer2W <: TwoWindingTransformer
        name::String
        available::Bool
        active_power_flow::Float64
        reactive_power_flow::Float64
        arc::Arc
        r::Float64
        x::Float64
        primary_shunt::Complex{Float64}
        rating::Union{Nothing, Float64}
        base_power::Float64
        base_voltage_primary::Union{Nothing, Float64}
        base_voltage_secondary::Union{Nothing, Float64}
        rating_b::Union{Nothing, Float64}
        rating_c::Union{Nothing, Float64}
        winding_group_number::WindingGroupNumber
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A basic 2-winding transformer.

The model uses an equivalent circuit assuming the impedance is on the High Voltage Side of the transformer. The model allocates the iron losses and magnetizing susceptance to the primary side

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow through the transformer (MW)
- `reactive_power_flow::Float64`: Initial condition of reactive power flow through the transformer (MVAR)
- `arc::Arc`: An [`Arc`](@ref) defining this transformer `from` a bus `to` another bus
- `r::Float64`: Resistance in pu ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(-2, 4)`
- `x::Float64`: Reactance in pu ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(-2, 4)`
- `primary_shunt::Complex{Float64}`: Primary shunt admittance in pu ([`SYSTEM_BASE`](@ref per_unit))
- `rating::Union{Nothing, Float64}`: Thermal rating (MVA). Flow through the transformer must be between -`rating` and `rating`. When defining a transformer before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to, validation range: `(0, nothing)`
- `base_power::Float64`: Base power (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `base_voltage_primary::Union{Nothing, Float64}`: (default: `get_base_voltage(get_from(arc))`) Primary base voltage in kV, validation range: `(0, nothing)`
- `base_voltage_secondary::Union{Nothing, Float64}`: (default: `get_base_voltage(get_to(arc))`) Secondary base voltage in kV, validation range: `(0, nothing)`
- `rating_b::Union{Nothing, Float64}`: (default: `nothing`) Second current rating; entered in MVA.
- `rating_c::Union{Nothing, Float64}`: (default: `nothing`) Third current rating; entered in MVA.
- `winding_group_number::WindingGroupNumber`: (default: `WindingGroupNumber.UNDEFINED`) Vector group number ('clock number') indicating phase shift (radians) between the `from` and `to` buses
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct Transformer2W <: TwoWindingTransformer
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Initial condition of active power flow through the transformer (MW)"
    active_power_flow::Float64
    "Initial condition of reactive power flow through the transformer (MVAR)"
    reactive_power_flow::Float64
    "An [`Arc`](@ref) defining this transformer `from` a bus `to` another bus"
    arc::Arc
    "Resistance in pu ([`SYSTEM_BASE`](@ref per_unit))"
    r::Float64
    "Reactance in pu ([`SYSTEM_BASE`](@ref per_unit))"
    x::Float64
    "Primary shunt admittance in pu ([`SYSTEM_BASE`](@ref per_unit))"
    primary_shunt::Complex{Float64}
    "Thermal rating (MVA). Flow through the transformer must be between -`rating` and `rating`. When defining a transformer before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to"
    rating::Union{Nothing, Float64}
    "Base power (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "Primary base voltage in kV"
    base_voltage_primary::Union{Nothing, Float64}
    "Secondary base voltage in kV"
    base_voltage_secondary::Union{Nothing, Float64}
    "Second current rating; entered in MVA."
    rating_b::Union{Nothing, Float64}
    "Third current rating; entered in MVA."
    rating_c::Union{Nothing, Float64}
    "Vector group number ('clock number') indicating phase shift (radians) between the `from` and `to` buses"
    winding_group_number::WindingGroupNumber
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function Transformer2W(name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, rating, base_power, base_voltage_primary=get_base_voltage(get_from(arc)), base_voltage_secondary=get_base_voltage(get_to(arc)), rating_b=nothing, rating_c=nothing, winding_group_number=WindingGroupNumber.UNDEFINED, services=Device[], ext=Dict{String, Any}(), )
    Transformer2W(name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, rating, base_power, base_voltage_primary, base_voltage_secondary, rating_b, rating_c, winding_group_number, services, ext, InfrastructureSystemsInternal(), )
end

function Transformer2W(; name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, rating, base_power, base_voltage_primary=get_base_voltage(get_from(arc)), base_voltage_secondary=get_base_voltage(get_to(arc)), rating_b=nothing, rating_c=nothing, winding_group_number=WindingGroupNumber.UNDEFINED, services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    Transformer2W(name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, rating, base_power, base_voltage_primary, base_voltage_secondary, rating_b, rating_c, winding_group_number, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function Transformer2W(::Nothing)
    Transformer2W(;
        name="init",
        available=false,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        r=0.0,
        x=0.0,
        primary_shunt=0.0,
        rating=nothing,
        base_power=100.0,
        base_voltage_primary=nothing,
        base_voltage_secondary=nothing,
        rating_b=0.0,
        rating_c=0.0,
        winding_group_number=WindingGroupNumber.UNDEFINED,
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`Transformer2W`](@ref) `name`."""
get_name(value::Transformer2W) = value.name
"""Get [`Transformer2W`](@ref) `available`."""
get_available(value::Transformer2W) = value.available
"""Get [`Transformer2W`](@ref) `active_power_flow`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_active_power_flow(value::Transformer2W) = get_value(value, Val(:active_power_flow), Val(:mva), DEFAULT_UNITS)
get_active_power_flow(value::Transformer2W, units) = get_value(value, Val(:active_power_flow), Val(:mva), units)
"""Get [`Transformer2W`](@ref) `reactive_power_flow`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_reactive_power_flow(value::Transformer2W) = get_value(value, Val(:reactive_power_flow), Val(:mva), DEFAULT_UNITS)
get_reactive_power_flow(value::Transformer2W, units) = get_value(value, Val(:reactive_power_flow), Val(:mva), units)
"""Get [`Transformer2W`](@ref) `arc`."""
get_arc(value::Transformer2W) = value.arc
"""Get [`Transformer2W`](@ref) `r`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_r(value::Transformer2W) = get_value(value, Val(:r), Val(:ohm), DEFAULT_UNITS)
get_r(value::Transformer2W, units) = get_value(value, Val(:r), Val(:ohm), units)
"""Get [`Transformer2W`](@ref) `x`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_x(value::Transformer2W) = get_value(value, Val(:x), Val(:ohm), DEFAULT_UNITS)
get_x(value::Transformer2W, units) = get_value(value, Val(:x), Val(:ohm), units)
"""Get [`Transformer2W`](@ref) `primary_shunt`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_primary_shunt(value::Transformer2W) = get_value(value, Val(:primary_shunt), Val(:siemens), DEFAULT_UNITS)
get_primary_shunt(value::Transformer2W, units) = get_value(value, Val(:primary_shunt), Val(:siemens), units)
"""Get [`Transformer2W`](@ref) `rating`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_rating(value::Transformer2W) = get_value(value, Val(:rating), Val(:mva), DEFAULT_UNITS)
get_rating(value::Transformer2W, units) = get_value(value, Val(:rating), Val(:mva), units)

_get_base_power(value::Transformer2W) = value.base_power
"""Get [`Transformer2W`](@ref) `base_voltage_primary`."""
get_base_voltage_primary(value::Transformer2W) = value.base_voltage_primary
"""Get [`Transformer2W`](@ref) `base_voltage_secondary`."""
get_base_voltage_secondary(value::Transformer2W) = value.base_voltage_secondary
"""Get [`Transformer2W`](@ref) `rating_b`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_rating_b(value::Transformer2W) = get_value(value, Val(:rating_b), Val(:mva), DEFAULT_UNITS)
get_rating_b(value::Transformer2W, units) = get_value(value, Val(:rating_b), Val(:mva), units)
"""Get [`Transformer2W`](@ref) `rating_c`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_rating_c(value::Transformer2W) = get_value(value, Val(:rating_c), Val(:mva), DEFAULT_UNITS)
get_rating_c(value::Transformer2W, units) = get_value(value, Val(:rating_c), Val(:mva), units)
"""Get [`Transformer2W`](@ref) `winding_group_number`."""
get_winding_group_number(value::Transformer2W) = value.winding_group_number
"""Get [`Transformer2W`](@ref) `services`."""
get_services(value::Transformer2W) = value.services
"""Get [`Transformer2W`](@ref) `ext`."""
get_ext(value::Transformer2W) = value.ext
"""Get [`Transformer2W`](@ref) `internal`."""
get_internal(value::Transformer2W) = value.internal

"""Set [`Transformer2W`](@ref) `available`."""
set_available!(value::Transformer2W, val) = value.available = val
"""Set [`Transformer2W`](@ref) `active_power_flow`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_flow!(value::Transformer2W, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mva))
"""Set [`Transformer2W`](@ref) `reactive_power_flow`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power_flow!(value::Transformer2W, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mva))
"""Set [`Transformer2W`](@ref) `arc`."""
set_arc!(value::Transformer2W, val) = value.arc = val
"""Set [`Transformer2W`](@ref) `r`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_r!(value::Transformer2W, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
"""Set [`Transformer2W`](@ref) `x`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_x!(value::Transformer2W, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
"""Set [`Transformer2W`](@ref) `primary_shunt`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_primary_shunt!(value::Transformer2W, val) = value.primary_shunt = set_value(value, Val(:primary_shunt), val, Val(:siemens))
"""Set [`Transformer2W`](@ref) `rating`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating!(value::Transformer2W, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`Transformer2W`](@ref) `base_voltage_primary`."""
set_base_voltage_primary!(value::Transformer2W, val) = value.base_voltage_primary = val
"""Set [`Transformer2W`](@ref) `base_voltage_secondary`."""
set_base_voltage_secondary!(value::Transformer2W, val) = value.base_voltage_secondary = val
"""Set [`Transformer2W`](@ref) `rating_b`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating_b!(value::Transformer2W, val) = value.rating_b = set_value(value, Val(:rating_b), val, Val(:mva))
"""Set [`Transformer2W`](@ref) `rating_c`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating_c!(value::Transformer2W, val) = value.rating_c = set_value(value, Val(:rating_c), val, Val(:mva))
"""Set [`Transformer2W`](@ref) `winding_group_number`."""
set_winding_group_number!(value::Transformer2W, val) = value.winding_group_number = val
"""Set [`Transformer2W`](@ref) `services`."""
set_services!(value::Transformer2W, val) = value.services = val
"""Set [`Transformer2W`](@ref) `ext`."""
set_ext!(value::Transformer2W, val) = value.ext = val
