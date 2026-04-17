#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct PhaseShiftingTransformer <: TwoWindingTransformer
        name::String
        available::Bool
        active_power_flow::Float64
        reactive_power_flow::Float64
        arc::Arc
        r::Float64
        x::Float64
        primary_shunt::Complex{Float64}
        tap::Float64
        α::Float64
        rating::Union{Nothing, Float64}
        base_power::Float64
        base_voltage_primary::Union{Nothing, Float64}
        base_voltage_secondary::Union{Nothing, Float64}
        rating_b::Union{Nothing, Float64}
        rating_c::Union{Nothing, Float64}
        phase_angle_limits::MinMax
        control_objective::TransformerControlObjective
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A phase-shifting transformer regulating the phase angle between two buses to control active power flow in the system.

The model uses an equivalent circuit assuming the impedance is on the High Voltage Side of the transformer. The model allocates the iron losses and magnetizing susceptance to the primary side

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow through the transformer (MW)
- `reactive_power_flow::Float64`: Initial condition of reactive power flow through the transformer (MVAR)
- `arc::Arc`: An [`Arc`](@ref) defining this transformer `from` a bus `to` another bus
- `r::Float64`: Resistance in pu ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(0, 4)`
- `x::Float64`: Reactance in pu ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(-2, 4)`
- `primary_shunt::Complex{Float64}`: Primary shunt admittance in pu ([`SYSTEM_BASE`](@ref per_unit))
- `tap::Float64`: Normalized tap changer position for voltage control, varying between 0 and 2, with 1 centered at the nominal voltage, validation range: `(0, 2)`
- `α::Float64`: Initial condition of phase shift (radians) between the `from` and `to` buses , validation range: `(-1.571, 1.571)`
- `rating::Union{Nothing, Float64}`: Thermal rating (MVA). Flow through the transformer must be between -`rating` and `rating`. When defining a transformer before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to, validation range: `(0, nothing)`
- `base_power::Float64`: Base power (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `base_voltage_primary::Union{Nothing, Float64}`: (default: `get_base_voltage(get_from(arc))`) Primary base voltage in kV, validation range: `(0, nothing)`
- `base_voltage_secondary::Union{Nothing, Float64}`: (default: `get_base_voltage(get_to(arc))`) Secondary base voltage in kV, validation range: `(0, nothing)`
- `rating_b::Union{Nothing, Float64}`: (default: `nothing`) Second current rating; entered in MVA.
- `rating_c::Union{Nothing, Float64}`: (default: `nothing`) Third current rating; entered in MVA.
- `phase_angle_limits::MinMax`: (default: `(min=-3.1416, max=3.1416)`) Minimum and maximum phase angle limits (radians)
- `control_objective::TransformerControlObjective`: (default: `TransformerControlObjective.UNDEFINED`) Control objective for the tap changer for power flow calculations. See [`TransformerControlObjective`](@ref xtf_crtl)
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct PhaseShiftingTransformer <: TwoWindingTransformer
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
    "Normalized tap changer position for voltage control, varying between 0 and 2, with 1 centered at the nominal voltage"
    tap::Float64
    "Initial condition of phase shift (radians) between the `from` and `to` buses "
    α::Float64
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
    "Minimum and maximum phase angle limits (radians)"
    phase_angle_limits::MinMax
    "Control objective for the tap changer for power flow calculations. See [`TransformerControlObjective`](@ref xtf_crtl)"
    control_objective::TransformerControlObjective
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function PhaseShiftingTransformer(name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, tap, α, rating, base_power, base_voltage_primary=get_base_voltage(get_from(arc)), base_voltage_secondary=get_base_voltage(get_to(arc)), rating_b=nothing, rating_c=nothing, phase_angle_limits=(min=-3.1416, max=3.1416), control_objective=TransformerControlObjective.UNDEFINED, services=Device[], ext=Dict{String, Any}(), )
    PhaseShiftingTransformer(name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, tap, α, rating, base_power, base_voltage_primary, base_voltage_secondary, rating_b, rating_c, phase_angle_limits, control_objective, services, ext, InfrastructureSystemsInternal(), )
end

function PhaseShiftingTransformer(; name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, tap, α, rating, base_power, base_voltage_primary=get_base_voltage(get_from(arc)), base_voltage_secondary=get_base_voltage(get_to(arc)), rating_b=nothing, rating_c=nothing, phase_angle_limits=(min=-3.1416, max=3.1416), control_objective=TransformerControlObjective.UNDEFINED, services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    PhaseShiftingTransformer(name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, tap, α, rating, base_power, base_voltage_primary, base_voltage_secondary, rating_b, rating_c, phase_angle_limits, control_objective, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function PhaseShiftingTransformer(::Nothing)
    PhaseShiftingTransformer(;
        name="init",
        available=false,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        r=0.0,
        x=0.0,
        primary_shunt=0.0,
        tap=1.0,
        α=0.0,
        rating=0.0,
        base_power=100.0,
        base_voltage_primary=nothing,
        base_voltage_secondary=nothing,
        rating_b=0.0,
        rating_c=0.0,
        phase_angle_limits=(min=-3.1416, max=3.1416),
        control_objective=TransformerControlObjective.UNDEFINED,
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`PhaseShiftingTransformer`](@ref) `name`."""
get_name(value::PhaseShiftingTransformer) = value.name
"""Get [`PhaseShiftingTransformer`](@ref) `available`."""
get_available(value::PhaseShiftingTransformer) = value.available
"""Get [`PhaseShiftingTransformer`](@ref) `active_power_flow`."""
get_active_power_flow(value::PhaseShiftingTransformer) = get_value(value, Val(:active_power_flow), Val(:mva))
get_active_power_flow(value::PhaseShiftingTransformer, units) = get_value(value, Val(:active_power_flow), Val(:mva), units)
"""Get [`PhaseShiftingTransformer`](@ref) `reactive_power_flow`."""
get_reactive_power_flow(value::PhaseShiftingTransformer) = get_value(value, Val(:reactive_power_flow), Val(:mva))
get_reactive_power_flow(value::PhaseShiftingTransformer, units) = get_value(value, Val(:reactive_power_flow), Val(:mva), units)
"""Get [`PhaseShiftingTransformer`](@ref) `arc`."""
get_arc(value::PhaseShiftingTransformer) = value.arc
"""Get [`PhaseShiftingTransformer`](@ref) `r`."""
get_r(value::PhaseShiftingTransformer) = get_value(value, Val(:r), Val(:ohm))
get_r(value::PhaseShiftingTransformer, units) = get_value(value, Val(:r), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer`](@ref) `x`."""
get_x(value::PhaseShiftingTransformer) = get_value(value, Val(:x), Val(:ohm))
get_x(value::PhaseShiftingTransformer, units) = get_value(value, Val(:x), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer`](@ref) `primary_shunt`."""
get_primary_shunt(value::PhaseShiftingTransformer) = get_value(value, Val(:primary_shunt), Val(:siemens))
get_primary_shunt(value::PhaseShiftingTransformer, units) = get_value(value, Val(:primary_shunt), Val(:siemens), units)
"""Get [`PhaseShiftingTransformer`](@ref) `tap`."""
get_tap(value::PhaseShiftingTransformer) = value.tap
"""Get [`PhaseShiftingTransformer`](@ref) `α`."""
get_α(value::PhaseShiftingTransformer) = value.α
"""Get [`PhaseShiftingTransformer`](@ref) `rating`."""
get_rating(value::PhaseShiftingTransformer) = get_value(value, Val(:rating), Val(:mva))
get_rating(value::PhaseShiftingTransformer, units) = get_value(value, Val(:rating), Val(:mva), units)
"""Get [`PhaseShiftingTransformer`](@ref) `base_power`."""
get_base_power(value::PhaseShiftingTransformer) = value.base_power
"""Get [`PhaseShiftingTransformer`](@ref) `base_voltage_primary`."""
get_base_voltage_primary(value::PhaseShiftingTransformer) = value.base_voltage_primary
"""Get [`PhaseShiftingTransformer`](@ref) `base_voltage_secondary`."""
get_base_voltage_secondary(value::PhaseShiftingTransformer) = value.base_voltage_secondary
"""Get [`PhaseShiftingTransformer`](@ref) `rating_b`."""
get_rating_b(value::PhaseShiftingTransformer) = get_value(value, Val(:rating_b), Val(:mva))
get_rating_b(value::PhaseShiftingTransformer, units) = get_value(value, Val(:rating_b), Val(:mva), units)
"""Get [`PhaseShiftingTransformer`](@ref) `rating_c`."""
get_rating_c(value::PhaseShiftingTransformer) = get_value(value, Val(:rating_c), Val(:mva))
get_rating_c(value::PhaseShiftingTransformer, units) = get_value(value, Val(:rating_c), Val(:mva), units)
"""Get [`PhaseShiftingTransformer`](@ref) `phase_angle_limits`."""
get_phase_angle_limits(value::PhaseShiftingTransformer) = value.phase_angle_limits
"""Get [`PhaseShiftingTransformer`](@ref) `control_objective`."""
get_control_objective(value::PhaseShiftingTransformer) = value.control_objective
"""Get [`PhaseShiftingTransformer`](@ref) `services`."""
get_services(value::PhaseShiftingTransformer) = value.services
"""Get [`PhaseShiftingTransformer`](@ref) `ext`."""
get_ext(value::PhaseShiftingTransformer) = value.ext
"""Get [`PhaseShiftingTransformer`](@ref) `internal`."""
get_internal(value::PhaseShiftingTransformer) = value.internal

"""Set [`PhaseShiftingTransformer`](@ref) `available`."""
set_available!(value::PhaseShiftingTransformer, val) = value.available = val
"""Set [`PhaseShiftingTransformer`](@ref) `active_power_flow`."""
set_active_power_flow!(value::PhaseShiftingTransformer, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mva))
"""Set [`PhaseShiftingTransformer`](@ref) `reactive_power_flow`."""
set_reactive_power_flow!(value::PhaseShiftingTransformer, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mva))
"""Set [`PhaseShiftingTransformer`](@ref) `arc`."""
set_arc!(value::PhaseShiftingTransformer, val) = value.arc = val
"""Set [`PhaseShiftingTransformer`](@ref) `r`."""
set_r!(value::PhaseShiftingTransformer, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer`](@ref) `x`."""
set_x!(value::PhaseShiftingTransformer, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer`](@ref) `primary_shunt`."""
set_primary_shunt!(value::PhaseShiftingTransformer, val) = value.primary_shunt = set_value(value, Val(:primary_shunt), val, Val(:siemens))
"""Set [`PhaseShiftingTransformer`](@ref) `tap`."""
set_tap!(value::PhaseShiftingTransformer, val) = value.tap = val
"""Set [`PhaseShiftingTransformer`](@ref) `α`."""
set_α!(value::PhaseShiftingTransformer, val) = value.α = val
"""Set [`PhaseShiftingTransformer`](@ref) `rating`."""
set_rating!(value::PhaseShiftingTransformer, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`PhaseShiftingTransformer`](@ref) `base_power`."""
set_base_power!(value::PhaseShiftingTransformer, val) = value.base_power = val
"""Set [`PhaseShiftingTransformer`](@ref) `base_voltage_primary`."""
set_base_voltage_primary!(value::PhaseShiftingTransformer, val) = value.base_voltage_primary = val
"""Set [`PhaseShiftingTransformer`](@ref) `base_voltage_secondary`."""
set_base_voltage_secondary!(value::PhaseShiftingTransformer, val) = value.base_voltage_secondary = val
"""Set [`PhaseShiftingTransformer`](@ref) `rating_b`."""
set_rating_b!(value::PhaseShiftingTransformer, val) = value.rating_b = set_value(value, Val(:rating_b), val, Val(:mva))
"""Set [`PhaseShiftingTransformer`](@ref) `rating_c`."""
set_rating_c!(value::PhaseShiftingTransformer, val) = value.rating_c = set_value(value, Val(:rating_c), val, Val(:mva))
"""Set [`PhaseShiftingTransformer`](@ref) `phase_angle_limits`."""
set_phase_angle_limits!(value::PhaseShiftingTransformer, val) = value.phase_angle_limits = val
"""Set [`PhaseShiftingTransformer`](@ref) `control_objective`."""
set_control_objective!(value::PhaseShiftingTransformer, val) = value.control_objective = val
"""Set [`PhaseShiftingTransformer`](@ref) `services`."""
set_services!(value::PhaseShiftingTransformer, val) = value.services = val
"""Set [`PhaseShiftingTransformer`](@ref) `ext`."""
set_ext!(value::PhaseShiftingTransformer, val) = value.ext = val
