#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TapTransformer <: TwoWindingTransformer
        name::String
        available::Bool
        active_power_flow::Float64
        reactive_power_flow::Float64
        arc::Arc
        r::Float64
        x::Float64
        primary_shunt::Complex{Float64}
        tap::Float64
        rating::Union{Nothing, Float64}
        base_power::Float64
        base_voltage_primary::Union{Nothing, Float64}
        base_voltage_secondary::Union{Nothing, Float64}
        rating_b::Union{Nothing, Float64}
        rating_c::Union{Nothing, Float64}
        winding_group_number::WindingGroupNumber
        control_objective::TransformerControlObjective
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A 2-winding transformer, with a tap changer for variable turns ratio.

The model uses an equivalent circuit assuming the impedance is on the High Voltage Side of the transformer. The model allocates the iron losses and magnetizing susceptance to the primary side

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `active_power_flow::Float64`: Initial condition of active power flow through the transformer (MW)
- `reactive_power_flow::Float64`: Initial condition of reactive power flow through the transformer (MVAR)
- `arc::Arc`: An [`Arc`](@ref) defining this transformer `from` a bus `to` another bus
- `r::Float64`: Resistance in p.u. ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(-2, 2)`
- `x::Float64`: Reactance in p.u. ([`SYSTEM_BASE`](@ref per_unit)), validation range: `(-2, 4)`
- `primary_shunt::Complex{Float64}`: Primary shunt admittance in pu ([`SYSTEM_BASE`](@ref per_unit))
- `tap::Float64`: Normalized tap changer position for voltage control, varying between 0 and 2, with 1 centered at the nominal voltage, validation range: `(0, 2)`
- `rating::Union{Nothing, Float64}`: Thermal rating (MVA). Flow through the transformer must be between -`rating`. When defining a transformer before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to, validation range: `(0, nothing)`
- `base_power::Float64`: Base power (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `base_voltage_primary::Union{Nothing, Float64}`: (default: `get_base_voltage(get_from(arc))`) Primary base voltage in kV, validation range: `(0, nothing)`
- `base_voltage_secondary::Union{Nothing, Float64}`: (default: `get_base_voltage(get_to(arc))`) Secondary base voltage in kV, validation range: `(0, nothing)`
- `rating_b::Union{Nothing, Float64}`: (default: `nothing`) Second current rating; entered in MVA.
- `rating_c::Union{Nothing, Float64}`: (default: `nothing`) Third current rating; entered in MVA.
- `winding_group_number::WindingGroupNumber`: (default: `WindingGroupNumber.UNDEFINED`) Vector group number ('clock number') indicating fixed phase shift (radians) between the `from` and `to` buses due to the connection group configuration
- `control_objective::TransformerControlObjective`: (default: `TransformerControlObjective.UNDEFINED`) Control objective for the tap changer for power flow calculations. See [`TransformerControlObjective`](@ref xtf_crtl)
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct TapTransformer <: TwoWindingTransformer
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
    "Resistance in p.u. ([`SYSTEM_BASE`](@ref per_unit))"
    r::Float64
    "Reactance in p.u. ([`SYSTEM_BASE`](@ref per_unit))"
    x::Float64
    "Primary shunt admittance in pu ([`SYSTEM_BASE`](@ref per_unit))"
    primary_shunt::Complex{Float64}
    "Normalized tap changer position for voltage control, varying between 0 and 2, with 1 centered at the nominal voltage"
    tap::Float64
    "Thermal rating (MVA). Flow through the transformer must be between -`rating`. When defining a transformer before it is attached to a `System`, `rating` must be in pu ([`SYSTEM_BASE`](@ref per_unit)) using the base power of the `System` it will be attached to"
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
    "Vector group number ('clock number') indicating fixed phase shift (radians) between the `from` and `to` buses due to the connection group configuration"
    winding_group_number::WindingGroupNumber
    "Control objective for the tap changer for power flow calculations. See [`TransformerControlObjective`](@ref xtf_crtl)"
    control_objective::TransformerControlObjective
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TapTransformer(name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, tap, rating, base_power, base_voltage_primary=get_base_voltage(get_from(arc)), base_voltage_secondary=get_base_voltage(get_to(arc)), rating_b=nothing, rating_c=nothing, winding_group_number=WindingGroupNumber.UNDEFINED, control_objective=TransformerControlObjective.UNDEFINED, services=Device[], ext=Dict{String, Any}(), )
    TapTransformer(name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, tap, rating, base_power, base_voltage_primary, base_voltage_secondary, rating_b, rating_c, winding_group_number, control_objective, services, ext, InfrastructureSystemsInternal(), )
end

function TapTransformer(; name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, tap, rating, base_power, base_voltage_primary=get_base_voltage(get_from(arc)), base_voltage_secondary=get_base_voltage(get_to(arc)), rating_b=nothing, rating_c=nothing, winding_group_number=WindingGroupNumber.UNDEFINED, control_objective=TransformerControlObjective.UNDEFINED, services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    TapTransformer(name, available, active_power_flow, reactive_power_flow, arc, r, x, primary_shunt, tap, rating, base_power, base_voltage_primary, base_voltage_secondary, rating_b, rating_c, winding_group_number, control_objective, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function TapTransformer(::Nothing)
    TapTransformer(;
        name="init",
        available=false,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        r=0.0,
        x=0.0,
        primary_shunt=0.0,
        tap=1.0,
        rating=0.0,
        base_power=100.0,
        base_voltage_primary=nothing,
        base_voltage_secondary=nothing,
        rating_b=0.0,
        rating_c=0.0,
        winding_group_number=WindingGroupNumber.UNDEFINED,
        control_objective=TransformerControlObjective.UNDEFINED,
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`TapTransformer`](@ref) `name`."""
get_name(value::TapTransformer) = value.name
"""Get [`TapTransformer`](@ref) `available`."""
get_available(value::TapTransformer) = value.available
"""Get [`TapTransformer`](@ref) `active_power_flow`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_active_power_flow(value::TapTransformer, units) = get_value(value, Val(:active_power_flow), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{ TapTransformer }) = InfrastructureSystems.SU
"""Get [`TapTransformer`](@ref) `reactive_power_flow`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_reactive_power_flow(value::TapTransformer, units) = get_value(value, Val(:reactive_power_flow), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_flow), ::Type{ TapTransformer }) = InfrastructureSystems.SU
"""Get [`TapTransformer`](@ref) `arc`."""
get_arc(value::TapTransformer) = value.arc
"""Get [`TapTransformer`](@ref) `r`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_r(value::TapTransformer, units) = get_value(value, Val(:r), Val(:ohm), units)
InfrastructureSystems.display_units_arg(::typeof(get_r), ::Type{ TapTransformer }) = InfrastructureSystems.SU
"""Get [`TapTransformer`](@ref) `x`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_x(value::TapTransformer, units) = get_value(value, Val(:x), Val(:ohm), units)
InfrastructureSystems.display_units_arg(::typeof(get_x), ::Type{ TapTransformer }) = InfrastructureSystems.SU
"""Get [`TapTransformer`](@ref) `primary_shunt`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_primary_shunt(value::TapTransformer, units) = get_value(value, Val(:primary_shunt), Val(:siemens), units)
InfrastructureSystems.display_units_arg(::typeof(get_primary_shunt), ::Type{ TapTransformer }) = InfrastructureSystems.SU
"""Get [`TapTransformer`](@ref) `tap`."""
get_tap(value::TapTransformer) = value.tap
"""Get [`TapTransformer`](@ref) `rating`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_rating(value::TapTransformer, units) = get_value(value, Val(:rating), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{ TapTransformer }) = InfrastructureSystems.SU
"""Get [`TapTransformer`](@ref) `base_power`."""
get_base_power(value::TapTransformer) = value.base_power
"""Get [`TapTransformer`](@ref) `base_voltage_primary`."""
get_base_voltage_primary(value::TapTransformer) = value.base_voltage_primary
"""Get [`TapTransformer`](@ref) `base_voltage_secondary`."""
get_base_voltage_secondary(value::TapTransformer) = value.base_voltage_secondary
"""Get [`TapTransformer`](@ref) `rating_b`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_rating_b(value::TapTransformer, units) = get_value(value, Val(:rating_b), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_rating_b), ::Type{ TapTransformer }) = InfrastructureSystems.SU
"""Get [`TapTransformer`](@ref) `rating_c`. The `units` argument is required (e.g. `SU`, `DU`, `MW`, or `Float64`)."""
get_rating_c(value::TapTransformer, units) = get_value(value, Val(:rating_c), Val(:mva), units)
InfrastructureSystems.display_units_arg(::typeof(get_rating_c), ::Type{ TapTransformer }) = InfrastructureSystems.SU
"""Get [`TapTransformer`](@ref) `winding_group_number`."""
get_winding_group_number(value::TapTransformer) = value.winding_group_number
"""Get [`TapTransformer`](@ref) `control_objective`."""
get_control_objective(value::TapTransformer) = value.control_objective
"""Get [`TapTransformer`](@ref) `services`."""
get_services(value::TapTransformer) = value.services
"""Get [`TapTransformer`](@ref) `ext`."""
get_ext(value::TapTransformer) = value.ext
"""Get [`TapTransformer`](@ref) `internal`."""
get_internal(value::TapTransformer) = value.internal

"""Set [`TapTransformer`](@ref) `available`."""
set_available!(value::TapTransformer, val) = value.available = val
"""Set [`TapTransformer`](@ref) `active_power_flow`."""
set_active_power_flow!(value::TapTransformer, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mva))
"""Set [`TapTransformer`](@ref) `reactive_power_flow`."""
set_reactive_power_flow!(value::TapTransformer, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mva))
"""Set [`TapTransformer`](@ref) `arc`."""
set_arc!(value::TapTransformer, val) = value.arc = val
"""Set [`TapTransformer`](@ref) `r`."""
set_r!(value::TapTransformer, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
"""Set [`TapTransformer`](@ref) `x`."""
set_x!(value::TapTransformer, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
"""Set [`TapTransformer`](@ref) `primary_shunt`."""
set_primary_shunt!(value::TapTransformer, val) = value.primary_shunt = set_value(value, Val(:primary_shunt), val, Val(:siemens))
"""Set [`TapTransformer`](@ref) `tap`."""
set_tap!(value::TapTransformer, val) = value.tap = val
"""Set [`TapTransformer`](@ref) `rating`."""
set_rating!(value::TapTransformer, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`TapTransformer`](@ref) `base_power`."""
set_base_power!(value::TapTransformer, val) = value.base_power = val
"""Set [`TapTransformer`](@ref) `base_voltage_primary`."""
set_base_voltage_primary!(value::TapTransformer, val) = value.base_voltage_primary = val
"""Set [`TapTransformer`](@ref) `base_voltage_secondary`."""
set_base_voltage_secondary!(value::TapTransformer, val) = value.base_voltage_secondary = val
"""Set [`TapTransformer`](@ref) `rating_b`."""
set_rating_b!(value::TapTransformer, val) = value.rating_b = set_value(value, Val(:rating_b), val, Val(:mva))
"""Set [`TapTransformer`](@ref) `rating_c`."""
set_rating_c!(value::TapTransformer, val) = value.rating_c = set_value(value, Val(:rating_c), val, Val(:mva))
"""Set [`TapTransformer`](@ref) `winding_group_number`."""
set_winding_group_number!(value::TapTransformer, val) = value.winding_group_number = val
"""Set [`TapTransformer`](@ref) `control_objective`."""
set_control_objective!(value::TapTransformer, val) = value.control_objective = val
"""Set [`TapTransformer`](@ref) `services`."""
set_services!(value::TapTransformer, val) = value.services = val
"""Set [`TapTransformer`](@ref) `ext`."""
set_ext!(value::TapTransformer, val) = value.ext = val
