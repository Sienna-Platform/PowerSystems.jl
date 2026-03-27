#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct PhaseShiftingTransformer3W <: ThreeWindingTransformer
        name::String
        available::Bool
        primary_star_arc::Arc
        secondary_star_arc::Arc
        tertiary_star_arc::Arc
        star_bus::ACBus
        active_power_flow_primary::Float64
        reactive_power_flow_primary::Float64
        active_power_flow_secondary::Float64
        reactive_power_flow_secondary::Float64
        active_power_flow_tertiary::Float64
        reactive_power_flow_tertiary::Float64
        r_primary::Float64
        x_primary::Float64
        r_secondary::Float64
        x_secondary::Float64
        r_tertiary::Float64
        x_tertiary::Float64
        rating::Union{Nothing, Float64}
        r_12::Float64
        x_12::Float64
        r_23::Float64
        x_23::Float64
        r_13::Float64
        x_13::Float64
        α_primary::Float64
        α_secondary::Float64
        α_tertiary::Float64
        base_power_12::Float64
        base_power_23::Float64
        base_power_13::Float64
        base_voltage_primary::Union{Nothing, Float64}
        base_voltage_secondary::Union{Nothing, Float64}
        base_voltage_tertiary::Union{Nothing, Float64}
        g::Float64
        b::Float64
        primary_turns_ratio::Float64
        secondary_turns_ratio::Float64
        tertiary_turns_ratio::Float64
        available_primary::Bool
        available_secondary::Bool
        available_tertiary::Bool
        rating_primary::Float64
        rating_secondary::Float64
        rating_tertiary::Float64
        phase_angle_limits::MinMax
        control_objective_primary::TransformerControlObjective
        control_objective_secondary::TransformerControlObjective
        control_objective_tertiary::TransformerControlObjective
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A 3-winding phase-shifting transformer.

. Phase shifts are specified in radians for primary, secondary, and tertiary windings.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `primary_star_arc::Arc`: An [`Arc`](@ref) defining this transformer `from` a primary bus `to` the star bus
- `secondary_star_arc::Arc`: An [`Arc`](@ref) defining this transformer `from` a secondary bus `to` the star bus
- `tertiary_star_arc::Arc`: An [`Arc`](@ref) defining this transformer `from` a tertiary bus `to` the star bus
- `star_bus::ACBus`: Star (hidden) Bus that this component (equivalent model) is connected to
- `active_power_flow_primary::Float64`: Initial condition of active power flow through the transformer primary side to star (hidden) bus (MW)
- `reactive_power_flow_primary::Float64`: Initial condition of reactive power flow through the transformer primary side to star (hidden) bus (MW)
- `active_power_flow_secondary::Float64`: Initial condition of active power flow through the transformer secondary side to star (hidden) bus (MW)
- `reactive_power_flow_secondary::Float64`: Initial condition of reactive power flow through the transformer secondary side to star (hidden) bus (MW)
- `active_power_flow_tertiary::Float64`: Initial condition of active power flow through the transformer tertiary side to star (hidden) bus (MW)
- `reactive_power_flow_tertiary::Float64`: Initial condition of reactive power flow through the transformer tertiary side to star (hidden) bus (MW)
- `r_primary::Float64`: Equivalent resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to star (hidden) bus., validation range: `(-2, 4)`
- `x_primary::Float64`: Equivalent reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to star (hidden) bus., validation range: `(-2, 4)`
- `r_secondary::Float64`: Equivalent resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from secondary to star (hidden) bus., validation range: `(-2, 4)`
- `x_secondary::Float64`: Equivalent reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from secondary to star (hidden) bus., validation range: `(-2, 4)`
- `r_tertiary::Float64`: Equivalent resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from tertiary to star (hidden) bus., validation range: `(-2, 4)`
- `x_tertiary::Float64`: Equivalent reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from tertiary to star (hidden) bus., validation range: `(-2, 4)`
- `rating::Union{Nothing, Float64}`: Thermal rating (MVA). Flow through the transformer must be between -`rating` and `rating`. When defining a transformer before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to, validation range: `(0, nothing)`
- `r_12::Float64`: Measured resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to secondary windings (R1-2 with CZ = 1 in PSS/E)., validation range: `(0, 4)`
- `x_12::Float64`: Measured reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to secondary windings (X1-2 with CZ = 1 in PSS/E)., validation range: `(0, 4)`
- `r_23::Float64`: Measured resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from secondary to tertiary windings (R2-3 with CZ = 1 in PSS/E)., validation range: `(0, 4)`
- `x_23::Float64`: Measured reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from secondary to tertiary windings (X2-3 with CZ = 1 in PSS/E)., validation range: `(0, 4)`
- `r_13::Float64`: Measured resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to tertiary windings (R1-3 with CZ = 1 in PSS/E)., validation range: `(0, 4)`
- `x_13::Float64`: Measured reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to tertiary windings (X1-3 with CZ = 1 in PSS/E)., validation range: `(0, 4)`
- `α_primary::Float64`: Initial condition of primary phase shift (radians) between the `from` and `to` buses , validation range: `(-1.571, 1.571)`
- `α_secondary::Float64`: Initial condition of secondary phase shift (radians) between the `from` and `to` buses , validation range: `(-1.571, 1.571)`
- `α_tertiary::Float64`: Initial condition of tertiary phase shift (radians) between the `from` and `to` buses , validation range: `(-1.571, 1.571)`
- `base_power_12::Float64`: Base power (MVA) for [per unitization](@ref per_unit) for primary-secondary windings., validation range: `(0, nothing)`
- `base_power_23::Float64`: Base power (MVA) for [per unitization](@ref per_unit) for secondary-tertiary windings., validation range: `(0, nothing)`
- `base_power_13::Float64`: Base power (MVA) for [per unitization](@ref per_unit) for primary-tertiary windings., validation range: `(0, nothing)`
- `base_voltage_primary::Union{Nothing, Float64}`: (default: `get_base_voltage(get_from(primary_star_arc))`) Primary base voltage in kV, validation range: `(0, nothing)`
- `base_voltage_secondary::Union{Nothing, Float64}`: (default: `get_base_voltage(get_from(secondary_star_arc))`) Secondary base voltage in kV, validation range: `(0, nothing)`
- `base_voltage_tertiary::Union{Nothing, Float64}`: (default: `get_base_voltage(get_from(tertiary_star_arc))`) Tertiary base voltage in kV, validation range: `(0, nothing)`
- `g::Float64`: (default: `0.0`) Shunt conductance in pu ([`SYSTEM_BASE`](@ref per_unit)) from star (hidden) bus to ground (MAG1 in PSS/E).
- `b::Float64`: (default: `0.0`) Shunt susceptance in pu ([`SYSTEM_BASE`](@ref per_unit)) from star (hidden) bus to ground (MAG2 in PSS/E).
- `primary_turns_ratio::Float64`: (default: `1.0`) Primary side off-nominal turns ratio in p.u. with respect to connected primary bus (WINDV1 with CW = 1 in PSS/E).
- `secondary_turns_ratio::Float64`: (default: `1.0`) Secondary side off-nominal turns ratio in p.u. with respect to connected secondary bus (WINDV2 with CW = 1 in PSS/E).
- `tertiary_turns_ratio::Float64`: (default: `1.0`) Tertiary side off-nominal turns ratio in p.u. with respect to connected tertiary bus (WINDV3 with CW = 1 in PSS/E).
- `available_primary::Bool`: (default: `true`) Status if primary winding is available or not.
- `available_secondary::Bool`: (default: `true`) Status if primary winding is available or not.
- `available_tertiary::Bool`: (default: `true`) Status if primary winding is available or not.
- `rating_primary::Float64`: (default: `0.0`) Rating (in MVA) for primary winding.
- `rating_secondary::Float64`: (default: `0.0`) Rating (in MVA) for secondary winding.
- `rating_tertiary::Float64`: (default: `0.0`) Rating (in MVA) for tertiary winding.
- `phase_angle_limits::MinMax`: (default: `(min=-3.1416, max=3.1416)`) Minimum and maximum phase angle limits (radians)
- `control_objective_primary::TransformerControlObjective`: (default: `TransformerControlObjective.UNDEFINED`) Control objective for the tap changer for winding 1. See [`TransformerControlObjective`](@ref xtf_crtl)
- `control_objective_secondary::TransformerControlObjective`: (default: `TransformerControlObjective.UNDEFINED`) Control objective for the tap changer for winding 2. See [`TransformerControlObjective`](@ref xtf_crtl)
- `control_objective_tertiary::TransformerControlObjective`: (default: `TransformerControlObjective.UNDEFINED`) Control objective for the tap changer for winding 3. See [`TransformerControlObjective`](@ref xtf_crtl)
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct PhaseShiftingTransformer3W <: ThreeWindingTransformer
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "An [`Arc`](@ref) defining this transformer `from` a primary bus `to` the star bus"
    primary_star_arc::Arc
    "An [`Arc`](@ref) defining this transformer `from` a secondary bus `to` the star bus"
    secondary_star_arc::Arc
    "An [`Arc`](@ref) defining this transformer `from` a tertiary bus `to` the star bus"
    tertiary_star_arc::Arc
    "Star (hidden) Bus that this component (equivalent model) is connected to"
    star_bus::ACBus
    "Initial condition of active power flow through the transformer primary side to star (hidden) bus (MW)"
    active_power_flow_primary::Float64
    "Initial condition of reactive power flow through the transformer primary side to star (hidden) bus (MW)"
    reactive_power_flow_primary::Float64
    "Initial condition of active power flow through the transformer secondary side to star (hidden) bus (MW)"
    active_power_flow_secondary::Float64
    "Initial condition of reactive power flow through the transformer secondary side to star (hidden) bus (MW)"
    reactive_power_flow_secondary::Float64
    "Initial condition of active power flow through the transformer tertiary side to star (hidden) bus (MW)"
    active_power_flow_tertiary::Float64
    "Initial condition of reactive power flow through the transformer tertiary side to star (hidden) bus (MW)"
    reactive_power_flow_tertiary::Float64
    "Equivalent resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to star (hidden) bus."
    r_primary::Float64
    "Equivalent reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to star (hidden) bus."
    x_primary::Float64
    "Equivalent resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from secondary to star (hidden) bus."
    r_secondary::Float64
    "Equivalent reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from secondary to star (hidden) bus."
    x_secondary::Float64
    "Equivalent resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from tertiary to star (hidden) bus."
    r_tertiary::Float64
    "Equivalent reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from tertiary to star (hidden) bus."
    x_tertiary::Float64
    "Thermal rating (MVA). Flow through the transformer must be between -`rating` and `rating`. When defining a transformer before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to"
    rating::Union{Nothing, Float64}
    "Measured resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to secondary windings (R1-2 with CZ = 1 in PSS/E)."
    r_12::Float64
    "Measured reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to secondary windings (X1-2 with CZ = 1 in PSS/E)."
    x_12::Float64
    "Measured resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from secondary to tertiary windings (R2-3 with CZ = 1 in PSS/E)."
    r_23::Float64
    "Measured reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from secondary to tertiary windings (X2-3 with CZ = 1 in PSS/E)."
    x_23::Float64
    "Measured resistance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to tertiary windings (R1-3 with CZ = 1 in PSS/E)."
    r_13::Float64
    "Measured reactance in pu ([`SYSTEM_BASE`](@ref per_unit)) from primary to tertiary windings (X1-3 with CZ = 1 in PSS/E)."
    x_13::Float64
    "Initial condition of primary phase shift (radians) between the `from` and `to` buses "
    α_primary::Float64
    "Initial condition of secondary phase shift (radians) between the `from` and `to` buses "
    α_secondary::Float64
    "Initial condition of tertiary phase shift (radians) between the `from` and `to` buses "
    α_tertiary::Float64
    "Base power (MVA) for [per unitization](@ref per_unit) for primary-secondary windings."
    base_power_12::Float64
    "Base power (MVA) for [per unitization](@ref per_unit) for secondary-tertiary windings."
    base_power_23::Float64
    "Base power (MVA) for [per unitization](@ref per_unit) for primary-tertiary windings."
    base_power_13::Float64
    "Primary base voltage in kV"
    base_voltage_primary::Union{Nothing, Float64}
    "Secondary base voltage in kV"
    base_voltage_secondary::Union{Nothing, Float64}
    "Tertiary base voltage in kV"
    base_voltage_tertiary::Union{Nothing, Float64}
    "Shunt conductance in pu ([`SYSTEM_BASE`](@ref per_unit)) from star (hidden) bus to ground (MAG1 in PSS/E)."
    g::Float64
    "Shunt susceptance in pu ([`SYSTEM_BASE`](@ref per_unit)) from star (hidden) bus to ground (MAG2 in PSS/E)."
    b::Float64
    "Primary side off-nominal turns ratio in p.u. with respect to connected primary bus (WINDV1 with CW = 1 in PSS/E)."
    primary_turns_ratio::Float64
    "Secondary side off-nominal turns ratio in p.u. with respect to connected secondary bus (WINDV2 with CW = 1 in PSS/E)."
    secondary_turns_ratio::Float64
    "Tertiary side off-nominal turns ratio in p.u. with respect to connected tertiary bus (WINDV3 with CW = 1 in PSS/E)."
    tertiary_turns_ratio::Float64
    "Status if primary winding is available or not."
    available_primary::Bool
    "Status if primary winding is available or not."
    available_secondary::Bool
    "Status if primary winding is available or not."
    available_tertiary::Bool
    "Rating (in MVA) for primary winding."
    rating_primary::Float64
    "Rating (in MVA) for secondary winding."
    rating_secondary::Float64
    "Rating (in MVA) for tertiary winding."
    rating_tertiary::Float64
    "Minimum and maximum phase angle limits (radians)"
    phase_angle_limits::MinMax
    "Control objective for the tap changer for winding 1. See [`TransformerControlObjective`](@ref xtf_crtl)"
    control_objective_primary::TransformerControlObjective
    "Control objective for the tap changer for winding 2. See [`TransformerControlObjective`](@ref xtf_crtl)"
    control_objective_secondary::TransformerControlObjective
    "Control objective for the tap changer for winding 3. See [`TransformerControlObjective`](@ref xtf_crtl)"
    control_objective_tertiary::TransformerControlObjective
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function PhaseShiftingTransformer3W(name, available, primary_star_arc, secondary_star_arc, tertiary_star_arc, star_bus, active_power_flow_primary, reactive_power_flow_primary, active_power_flow_secondary, reactive_power_flow_secondary, active_power_flow_tertiary, reactive_power_flow_tertiary, r_primary, x_primary, r_secondary, x_secondary, r_tertiary, x_tertiary, rating, r_12, x_12, r_23, x_23, r_13, x_13, α_primary, α_secondary, α_tertiary, base_power_12, base_power_23, base_power_13, base_voltage_primary=get_base_voltage(get_from(primary_star_arc)), base_voltage_secondary=get_base_voltage(get_from(secondary_star_arc)), base_voltage_tertiary=get_base_voltage(get_from(tertiary_star_arc)), g=0.0, b=0.0, primary_turns_ratio=1.0, secondary_turns_ratio=1.0, tertiary_turns_ratio=1.0, available_primary=true, available_secondary=true, available_tertiary=true, rating_primary=0.0, rating_secondary=0.0, rating_tertiary=0.0, phase_angle_limits=(min=-3.1416, max=3.1416), control_objective_primary=TransformerControlObjective.UNDEFINED, control_objective_secondary=TransformerControlObjective.UNDEFINED, control_objective_tertiary=TransformerControlObjective.UNDEFINED, services=Device[], ext=Dict{String, Any}(), )
    PhaseShiftingTransformer3W(name, available, primary_star_arc, secondary_star_arc, tertiary_star_arc, star_bus, active_power_flow_primary, reactive_power_flow_primary, active_power_flow_secondary, reactive_power_flow_secondary, active_power_flow_tertiary, reactive_power_flow_tertiary, r_primary, x_primary, r_secondary, x_secondary, r_tertiary, x_tertiary, rating, r_12, x_12, r_23, x_23, r_13, x_13, α_primary, α_secondary, α_tertiary, base_power_12, base_power_23, base_power_13, base_voltage_primary, base_voltage_secondary, base_voltage_tertiary, g, b, primary_turns_ratio, secondary_turns_ratio, tertiary_turns_ratio, available_primary, available_secondary, available_tertiary, rating_primary, rating_secondary, rating_tertiary, phase_angle_limits, control_objective_primary, control_objective_secondary, control_objective_tertiary, services, ext, InfrastructureSystemsInternal(), )
end

function PhaseShiftingTransformer3W(; name, available, primary_star_arc, secondary_star_arc, tertiary_star_arc, star_bus, active_power_flow_primary, reactive_power_flow_primary, active_power_flow_secondary, reactive_power_flow_secondary, active_power_flow_tertiary, reactive_power_flow_tertiary, r_primary, x_primary, r_secondary, x_secondary, r_tertiary, x_tertiary, rating, r_12, x_12, r_23, x_23, r_13, x_13, α_primary, α_secondary, α_tertiary, base_power_12, base_power_23, base_power_13, base_voltage_primary=get_base_voltage(get_from(primary_star_arc)), base_voltage_secondary=get_base_voltage(get_from(secondary_star_arc)), base_voltage_tertiary=get_base_voltage(get_from(tertiary_star_arc)), g=0.0, b=0.0, primary_turns_ratio=1.0, secondary_turns_ratio=1.0, tertiary_turns_ratio=1.0, available_primary=true, available_secondary=true, available_tertiary=true, rating_primary=0.0, rating_secondary=0.0, rating_tertiary=0.0, phase_angle_limits=(min=-3.1416, max=3.1416), control_objective_primary=TransformerControlObjective.UNDEFINED, control_objective_secondary=TransformerControlObjective.UNDEFINED, control_objective_tertiary=TransformerControlObjective.UNDEFINED, services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    PhaseShiftingTransformer3W(name, available, primary_star_arc, secondary_star_arc, tertiary_star_arc, star_bus, active_power_flow_primary, reactive_power_flow_primary, active_power_flow_secondary, reactive_power_flow_secondary, active_power_flow_tertiary, reactive_power_flow_tertiary, r_primary, x_primary, r_secondary, x_secondary, r_tertiary, x_tertiary, rating, r_12, x_12, r_23, x_23, r_13, x_13, α_primary, α_secondary, α_tertiary, base_power_12, base_power_23, base_power_13, base_voltage_primary, base_voltage_secondary, base_voltage_tertiary, g, b, primary_turns_ratio, secondary_turns_ratio, tertiary_turns_ratio, available_primary, available_secondary, available_tertiary, rating_primary, rating_secondary, rating_tertiary, phase_angle_limits, control_objective_primary, control_objective_secondary, control_objective_tertiary, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function PhaseShiftingTransformer3W(::Nothing)
    PhaseShiftingTransformer3W(;
        name="init",
        available=false,
        primary_star_arc=Arc(ACBus(nothing), ACBus(nothing)),
        secondary_star_arc=Arc(ACBus(nothing), ACBus(nothing)),
        tertiary_star_arc=Arc(ACBus(nothing), ACBus(nothing)),
        star_bus=ACBus(nothing),
        active_power_flow_primary=0.0,
        reactive_power_flow_primary=0.0,
        active_power_flow_secondary=0.0,
        reactive_power_flow_secondary=0.0,
        active_power_flow_tertiary=0.0,
        reactive_power_flow_tertiary=0.0,
        r_primary=0.0,
        x_primary=0.0,
        r_secondary=0.0,
        x_secondary=0.0,
        r_tertiary=0.0,
        x_tertiary=0.0,
        rating=nothing,
        r_12=0.0,
        x_12=0.0,
        r_23=0.0,
        x_23=0.0,
        r_13=0.0,
        x_13=0.0,
        α_primary=0.0,
        α_secondary=0.0,
        α_tertiary=0.0,
        base_power_12=0.0,
        base_power_23=0.0,
        base_power_13=0.0,
        base_voltage_primary=nothing,
        base_voltage_secondary=nothing,
        base_voltage_tertiary=nothing,
        g=0.0,
        b=0.0,
        primary_turns_ratio=0.0,
        secondary_turns_ratio=0.0,
        tertiary_turns_ratio=0.0,
        available_primary=false,
        available_secondary=false,
        available_tertiary=false,
        rating_primary=0.0,
        rating_secondary=0.0,
        rating_tertiary=0.0,
        phase_angle_limits=(min=-3.1416, max=3.1416),
        control_objective_primary=TransformerControlObjective.UNDEFINED,
        control_objective_secondary=TransformerControlObjective.UNDEFINED,
        control_objective_tertiary=TransformerControlObjective.UNDEFINED,
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`PhaseShiftingTransformer3W`](@ref) `name`."""
get_name(value::PhaseShiftingTransformer3W) = value.name
"""Get [`PhaseShiftingTransformer3W`](@ref) `available`."""
get_available(value::PhaseShiftingTransformer3W) = value.available
"""Get [`PhaseShiftingTransformer3W`](@ref) `primary_star_arc`."""
get_primary_star_arc(value::PhaseShiftingTransformer3W) = value.primary_star_arc
"""Get [`PhaseShiftingTransformer3W`](@ref) `secondary_star_arc`."""
get_secondary_star_arc(value::PhaseShiftingTransformer3W) = value.secondary_star_arc
"""Get [`PhaseShiftingTransformer3W`](@ref) `tertiary_star_arc`."""
get_tertiary_star_arc(value::PhaseShiftingTransformer3W) = value.tertiary_star_arc
"""Get [`PhaseShiftingTransformer3W`](@ref) `star_bus`."""
get_star_bus(value::PhaseShiftingTransformer3W) = value.star_bus
"""Get [`PhaseShiftingTransformer3W`](@ref) `active_power_flow_primary`. Returns value in the system's unit setting (natural units by default)."""
get_active_power_flow_primary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:active_power_flow_primary), Val(:mva), _get_system_units(value, Val(:mva)))
get_active_power_flow_primary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:active_power_flow_primary), Val(:mva), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `reactive_power_flow_primary`. Returns value in the system's unit setting (natural units by default)."""
get_reactive_power_flow_primary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:reactive_power_flow_primary), Val(:mva), _get_system_units(value, Val(:mva)))
get_reactive_power_flow_primary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:reactive_power_flow_primary), Val(:mva), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `active_power_flow_secondary`. Returns value in the system's unit setting (natural units by default)."""
get_active_power_flow_secondary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:active_power_flow_secondary), Val(:mva), _get_system_units(value, Val(:mva)))
get_active_power_flow_secondary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:active_power_flow_secondary), Val(:mva), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `reactive_power_flow_secondary`. Returns value in the system's unit setting (natural units by default)."""
get_reactive_power_flow_secondary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:reactive_power_flow_secondary), Val(:mva), _get_system_units(value, Val(:mva)))
get_reactive_power_flow_secondary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:reactive_power_flow_secondary), Val(:mva), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `active_power_flow_tertiary`. Returns value in the system's unit setting (natural units by default)."""
get_active_power_flow_tertiary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:active_power_flow_tertiary), Val(:mva), _get_system_units(value, Val(:mva)))
get_active_power_flow_tertiary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:active_power_flow_tertiary), Val(:mva), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `reactive_power_flow_tertiary`. Returns value in the system's unit setting (natural units by default)."""
get_reactive_power_flow_tertiary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:reactive_power_flow_tertiary), Val(:mva), _get_system_units(value, Val(:mva)))
get_reactive_power_flow_tertiary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:reactive_power_flow_tertiary), Val(:mva), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `r_primary`. Returns value in the system's unit setting (natural units by default)."""
get_r_primary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:r_primary), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_r_primary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:r_primary), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `x_primary`. Returns value in the system's unit setting (natural units by default)."""
get_x_primary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:x_primary), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_x_primary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:x_primary), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `r_secondary`. Returns value in the system's unit setting (natural units by default)."""
get_r_secondary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:r_secondary), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_r_secondary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:r_secondary), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `x_secondary`. Returns value in the system's unit setting (natural units by default)."""
get_x_secondary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:x_secondary), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_x_secondary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:x_secondary), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `r_tertiary`. Returns value in the system's unit setting (natural units by default)."""
get_r_tertiary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:r_tertiary), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_r_tertiary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:r_tertiary), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `x_tertiary`. Returns value in the system's unit setting (natural units by default)."""
get_x_tertiary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:x_tertiary), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_x_tertiary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:x_tertiary), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `rating`. Returns value in the system's unit setting (natural units by default)."""
get_rating(value::PhaseShiftingTransformer3W) = get_value(value, Val(:rating), Val(:mva), _get_system_units(value, Val(:mva)))
get_rating(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:rating), Val(:mva), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `r_12`. Returns value in the system's unit setting (natural units by default)."""
get_r_12(value::PhaseShiftingTransformer3W) = get_value(value, Val(:r_12), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_r_12(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:r_12), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `x_12`. Returns value in the system's unit setting (natural units by default)."""
get_x_12(value::PhaseShiftingTransformer3W) = get_value(value, Val(:x_12), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_x_12(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:x_12), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `r_23`. Returns value in the system's unit setting (natural units by default)."""
get_r_23(value::PhaseShiftingTransformer3W) = get_value(value, Val(:r_23), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_r_23(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:r_23), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `x_23`. Returns value in the system's unit setting (natural units by default)."""
get_x_23(value::PhaseShiftingTransformer3W) = get_value(value, Val(:x_23), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_x_23(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:x_23), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `r_13`. Returns value in the system's unit setting (natural units by default)."""
get_r_13(value::PhaseShiftingTransformer3W) = get_value(value, Val(:r_13), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_r_13(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:r_13), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `x_13`. Returns value in the system's unit setting (natural units by default)."""
get_x_13(value::PhaseShiftingTransformer3W) = get_value(value, Val(:x_13), Val(:ohm), _get_system_units(value, Val(:ohm)))
get_x_13(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:x_13), Val(:ohm), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `α_primary`."""
get_α_primary(value::PhaseShiftingTransformer3W) = value.α_primary
"""Get [`PhaseShiftingTransformer3W`](@ref) `α_secondary`."""
get_α_secondary(value::PhaseShiftingTransformer3W) = value.α_secondary
"""Get [`PhaseShiftingTransformer3W`](@ref) `α_tertiary`."""
get_α_tertiary(value::PhaseShiftingTransformer3W) = value.α_tertiary

_get_base_power_12(value::PhaseShiftingTransformer3W) = value.base_power_12

_get_base_power_23(value::PhaseShiftingTransformer3W) = value.base_power_23

_get_base_power_13(value::PhaseShiftingTransformer3W) = value.base_power_13
"""Get [`PhaseShiftingTransformer3W`](@ref) `base_voltage_primary`."""
get_base_voltage_primary(value::PhaseShiftingTransformer3W) = value.base_voltage_primary
"""Get [`PhaseShiftingTransformer3W`](@ref) `base_voltage_secondary`."""
get_base_voltage_secondary(value::PhaseShiftingTransformer3W) = value.base_voltage_secondary
"""Get [`PhaseShiftingTransformer3W`](@ref) `base_voltage_tertiary`."""
get_base_voltage_tertiary(value::PhaseShiftingTransformer3W) = value.base_voltage_tertiary
"""Get [`PhaseShiftingTransformer3W`](@ref) `g`. Returns value in the system's unit setting (natural units by default)."""
get_g(value::PhaseShiftingTransformer3W) = get_value(value, Val(:g), Val(:siemens), _get_system_units(value, Val(:siemens)))
get_g(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:g), Val(:siemens), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `b`. Returns value in the system's unit setting (natural units by default)."""
get_b(value::PhaseShiftingTransformer3W) = get_value(value, Val(:b), Val(:siemens), _get_system_units(value, Val(:siemens)))
get_b(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:b), Val(:siemens), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `primary_turns_ratio`."""
get_primary_turns_ratio(value::PhaseShiftingTransformer3W) = value.primary_turns_ratio
"""Get [`PhaseShiftingTransformer3W`](@ref) `secondary_turns_ratio`."""
get_secondary_turns_ratio(value::PhaseShiftingTransformer3W) = value.secondary_turns_ratio
"""Get [`PhaseShiftingTransformer3W`](@ref) `tertiary_turns_ratio`."""
get_tertiary_turns_ratio(value::PhaseShiftingTransformer3W) = value.tertiary_turns_ratio
"""Get [`PhaseShiftingTransformer3W`](@ref) `available_primary`."""
get_available_primary(value::PhaseShiftingTransformer3W) = value.available_primary
"""Get [`PhaseShiftingTransformer3W`](@ref) `available_secondary`."""
get_available_secondary(value::PhaseShiftingTransformer3W) = value.available_secondary
"""Get [`PhaseShiftingTransformer3W`](@ref) `available_tertiary`."""
get_available_tertiary(value::PhaseShiftingTransformer3W) = value.available_tertiary
"""Get [`PhaseShiftingTransformer3W`](@ref) `rating_primary`. Returns value in the system's unit setting (natural units by default)."""
get_rating_primary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:rating_primary), Val(:mva), _get_system_units(value, Val(:mva)))
get_rating_primary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:rating_primary), Val(:mva), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `rating_secondary`. Returns value in the system's unit setting (natural units by default)."""
get_rating_secondary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:rating_secondary), Val(:mva), _get_system_units(value, Val(:mva)))
get_rating_secondary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:rating_secondary), Val(:mva), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `rating_tertiary`. Returns value in the system's unit setting (natural units by default)."""
get_rating_tertiary(value::PhaseShiftingTransformer3W) = get_value(value, Val(:rating_tertiary), Val(:mva), _get_system_units(value, Val(:mva)))
get_rating_tertiary(value::PhaseShiftingTransformer3W, units) = get_value(value, Val(:rating_tertiary), Val(:mva), units)
"""Get [`PhaseShiftingTransformer3W`](@ref) `phase_angle_limits`."""
get_phase_angle_limits(value::PhaseShiftingTransformer3W) = value.phase_angle_limits
"""Get [`PhaseShiftingTransformer3W`](@ref) `control_objective_primary`."""
get_control_objective_primary(value::PhaseShiftingTransformer3W) = value.control_objective_primary
"""Get [`PhaseShiftingTransformer3W`](@ref) `control_objective_secondary`."""
get_control_objective_secondary(value::PhaseShiftingTransformer3W) = value.control_objective_secondary
"""Get [`PhaseShiftingTransformer3W`](@ref) `control_objective_tertiary`."""
get_control_objective_tertiary(value::PhaseShiftingTransformer3W) = value.control_objective_tertiary
"""Get [`PhaseShiftingTransformer3W`](@ref) `services`."""
get_services(value::PhaseShiftingTransformer3W) = value.services
"""Get [`PhaseShiftingTransformer3W`](@ref) `ext`."""
get_ext(value::PhaseShiftingTransformer3W) = value.ext
"""Get [`PhaseShiftingTransformer3W`](@ref) `internal`."""
get_internal(value::PhaseShiftingTransformer3W) = value.internal

"""Set [`PhaseShiftingTransformer3W`](@ref) `available`."""
set_available!(value::PhaseShiftingTransformer3W, val) = value.available = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `primary_star_arc`."""
set_primary_star_arc!(value::PhaseShiftingTransformer3W, val) = value.primary_star_arc = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `secondary_star_arc`."""
set_secondary_star_arc!(value::PhaseShiftingTransformer3W, val) = value.secondary_star_arc = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `tertiary_star_arc`."""
set_tertiary_star_arc!(value::PhaseShiftingTransformer3W, val) = value.tertiary_star_arc = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `star_bus`."""
set_star_bus!(value::PhaseShiftingTransformer3W, val) = value.star_bus = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `active_power_flow_primary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_flow_primary!(value::PhaseShiftingTransformer3W, val) = value.active_power_flow_primary = set_value(value, Val(:active_power_flow_primary), val, Val(:mva))
"""Set [`PhaseShiftingTransformer3W`](@ref) `reactive_power_flow_primary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power_flow_primary!(value::PhaseShiftingTransformer3W, val) = value.reactive_power_flow_primary = set_value(value, Val(:reactive_power_flow_primary), val, Val(:mva))
"""Set [`PhaseShiftingTransformer3W`](@ref) `active_power_flow_secondary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_flow_secondary!(value::PhaseShiftingTransformer3W, val) = value.active_power_flow_secondary = set_value(value, Val(:active_power_flow_secondary), val, Val(:mva))
"""Set [`PhaseShiftingTransformer3W`](@ref) `reactive_power_flow_secondary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power_flow_secondary!(value::PhaseShiftingTransformer3W, val) = value.reactive_power_flow_secondary = set_value(value, Val(:reactive_power_flow_secondary), val, Val(:mva))
"""Set [`PhaseShiftingTransformer3W`](@ref) `active_power_flow_tertiary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_flow_tertiary!(value::PhaseShiftingTransformer3W, val) = value.active_power_flow_tertiary = set_value(value, Val(:active_power_flow_tertiary), val, Val(:mva))
"""Set [`PhaseShiftingTransformer3W`](@ref) `reactive_power_flow_tertiary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power_flow_tertiary!(value::PhaseShiftingTransformer3W, val) = value.reactive_power_flow_tertiary = set_value(value, Val(:reactive_power_flow_tertiary), val, Val(:mva))
"""Set [`PhaseShiftingTransformer3W`](@ref) `r_primary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_r_primary!(value::PhaseShiftingTransformer3W, val) = value.r_primary = set_value(value, Val(:r_primary), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `x_primary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_x_primary!(value::PhaseShiftingTransformer3W, val) = value.x_primary = set_value(value, Val(:x_primary), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `r_secondary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_r_secondary!(value::PhaseShiftingTransformer3W, val) = value.r_secondary = set_value(value, Val(:r_secondary), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `x_secondary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_x_secondary!(value::PhaseShiftingTransformer3W, val) = value.x_secondary = set_value(value, Val(:x_secondary), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `r_tertiary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_r_tertiary!(value::PhaseShiftingTransformer3W, val) = value.r_tertiary = set_value(value, Val(:r_tertiary), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `x_tertiary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_x_tertiary!(value::PhaseShiftingTransformer3W, val) = value.x_tertiary = set_value(value, Val(:x_tertiary), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `rating`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating!(value::PhaseShiftingTransformer3W, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`PhaseShiftingTransformer3W`](@ref) `r_12`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_r_12!(value::PhaseShiftingTransformer3W, val) = value.r_12 = set_value(value, Val(:r_12), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `x_12`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_x_12!(value::PhaseShiftingTransformer3W, val) = value.x_12 = set_value(value, Val(:x_12), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `r_23`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_r_23!(value::PhaseShiftingTransformer3W, val) = value.r_23 = set_value(value, Val(:r_23), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `x_23`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_x_23!(value::PhaseShiftingTransformer3W, val) = value.x_23 = set_value(value, Val(:x_23), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `r_13`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_r_13!(value::PhaseShiftingTransformer3W, val) = value.r_13 = set_value(value, Val(:r_13), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `x_13`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_x_13!(value::PhaseShiftingTransformer3W, val) = value.x_13 = set_value(value, Val(:x_13), val, Val(:ohm))
"""Set [`PhaseShiftingTransformer3W`](@ref) `α_primary`."""
set_α_primary!(value::PhaseShiftingTransformer3W, val) = value.α_primary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `α_secondary`."""
set_α_secondary!(value::PhaseShiftingTransformer3W, val) = value.α_secondary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `α_tertiary`."""
set_α_tertiary!(value::PhaseShiftingTransformer3W, val) = value.α_tertiary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `base_voltage_primary`."""
set_base_voltage_primary!(value::PhaseShiftingTransformer3W, val) = value.base_voltage_primary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `base_voltage_secondary`."""
set_base_voltage_secondary!(value::PhaseShiftingTransformer3W, val) = value.base_voltage_secondary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `base_voltage_tertiary`."""
set_base_voltage_tertiary!(value::PhaseShiftingTransformer3W, val) = value.base_voltage_tertiary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `g`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_g!(value::PhaseShiftingTransformer3W, val) = value.g = set_value(value, Val(:g), val, Val(:siemens))
"""Set [`PhaseShiftingTransformer3W`](@ref) `b`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_b!(value::PhaseShiftingTransformer3W, val) = value.b = set_value(value, Val(:b), val, Val(:siemens))
"""Set [`PhaseShiftingTransformer3W`](@ref) `primary_turns_ratio`."""
set_primary_turns_ratio!(value::PhaseShiftingTransformer3W, val) = value.primary_turns_ratio = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `secondary_turns_ratio`."""
set_secondary_turns_ratio!(value::PhaseShiftingTransformer3W, val) = value.secondary_turns_ratio = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `tertiary_turns_ratio`."""
set_tertiary_turns_ratio!(value::PhaseShiftingTransformer3W, val) = value.tertiary_turns_ratio = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `available_primary`."""
set_available_primary!(value::PhaseShiftingTransformer3W, val) = value.available_primary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `available_secondary`."""
set_available_secondary!(value::PhaseShiftingTransformer3W, val) = value.available_secondary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `available_tertiary`."""
set_available_tertiary!(value::PhaseShiftingTransformer3W, val) = value.available_tertiary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `rating_primary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating_primary!(value::PhaseShiftingTransformer3W, val) = value.rating_primary = set_value(value, Val(:rating_primary), val, Val(:mva))
"""Set [`PhaseShiftingTransformer3W`](@ref) `rating_secondary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating_secondary!(value::PhaseShiftingTransformer3W, val) = value.rating_secondary = set_value(value, Val(:rating_secondary), val, Val(:mva))
"""Set [`PhaseShiftingTransformer3W`](@ref) `rating_tertiary`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_rating_tertiary!(value::PhaseShiftingTransformer3W, val) = value.rating_tertiary = set_value(value, Val(:rating_tertiary), val, Val(:mva))
"""Set [`PhaseShiftingTransformer3W`](@ref) `phase_angle_limits`."""
set_phase_angle_limits!(value::PhaseShiftingTransformer3W, val) = value.phase_angle_limits = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `control_objective_primary`."""
set_control_objective_primary!(value::PhaseShiftingTransformer3W, val) = value.control_objective_primary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `control_objective_secondary`."""
set_control_objective_secondary!(value::PhaseShiftingTransformer3W, val) = value.control_objective_secondary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `control_objective_tertiary`."""
set_control_objective_tertiary!(value::PhaseShiftingTransformer3W, val) = value.control_objective_tertiary = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `services`."""
set_services!(value::PhaseShiftingTransformer3W, val) = value.services = val
"""Set [`PhaseShiftingTransformer3W`](@ref) `ext`."""
set_ext!(value::PhaseShiftingTransformer3W, val) = value.ext = val
