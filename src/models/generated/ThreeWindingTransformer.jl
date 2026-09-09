#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ThreeWindingTransformer <: ACTransmission
        name::String
        primary_circuit::TransformerCircuit
        secondary_circuit::TransformerCircuit
        tertiary_circuit::TransformerCircuit
        star_bus::ACBus
        r_12::Union{Nothing, Float64}
        x_12::Union{Nothing, Float64}
        r_23::Union{Nothing, Float64}
        x_23::Union{Nothing, Float64}
        r_31::Union{Nothing, Float64}
        x_31::Union{Nothing, Float64}
        base_power_12::Union{Nothing, Float64}
        base_power_23::Union{Nothing, Float64}
        base_power_31::Union{Nothing, Float64}
        magnetizing_shunt::Complex{Float64}
        shunt_location::ThreeWindingTransformerShuntLocation
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A three-winding transformer.

The model uses an equivalent star model with a star (hidden) bus. Each of the three [`TransformerCircuit`](@ref) objects ([`get_primary_circuit`](@ref), [`get_secondary_circuit`](@ref), [`get_tertiary_circuit`](@ref)) connects a terminal bus to the star bus and carries its own arc, tap, phase shift, star-leg impedance, ratings, per-winding base power/voltages, availability, and control. The `magnetizing_shunt` admittance and its `shunt_location` are transformer-level. The pairwise measured impedances `r_12`/`x_12`, `r_23`/`x_23`, `r_31`/`x_31` are one representation of the transformer impedance; the individual star-leg impedances stored on each circuit are derived from them at parse time. Each pairwise impedance is in pu (device base) on the corresponding `base_power_12`/`base_power_23`/`base_power_31`, referenced to the FIRST-INDEX circuit's base voltage: `r_12`/`x_12` to the primary circuit's base voltage, `r_23`/`x_23` to the secondary circuit's base voltage, and `r_31`/`x_31` to the tertiary circuit's base voltage. Mutating either representation after construction does not update the other. Power-flow and Ybus assembly read the per-circuit star-leg impedances, not the pairwise fields. Availability is circuit-level (see [`get_available`](@ref)). The model is described in Chapter 3.6 of J.D. Glover, M.S. Sarma and T. Overbye: Power Systems Analysis and Design.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `primary_circuit::TransformerCircuit`: The primary [`TransformerCircuit`](@ref) connecting the primary bus to the star bus
- `secondary_circuit::TransformerCircuit`: The secondary [`TransformerCircuit`](@ref) connecting the secondary bus to the star bus
- `tertiary_circuit::TransformerCircuit`: The tertiary [`TransformerCircuit`](@ref) connecting the tertiary bus to the star bus
- `star_bus::ACBus`: Star (hidden) Bus that this component (equivalent model) is connected to
- `r_12::Union{Nothing, Float64}`: (default: `nothing`) Measured resistance in pu (device base on `base_power_12`), referenced to the primary winding's base voltage, from primary to secondary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`., validation range: `(0, 4)`
- `x_12::Union{Nothing, Float64}`: (default: `nothing`) Measured reactance in pu (device base on `base_power_12`), referenced to the primary winding's base voltage, from primary to secondary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`., validation range: `(0, 4)`
- `r_23::Union{Nothing, Float64}`: (default: `nothing`) Measured resistance in pu (device base on `base_power_23`), referenced to the secondary winding's base voltage, from secondary to tertiary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`., validation range: `(0, 4)`
- `x_23::Union{Nothing, Float64}`: (default: `nothing`) Measured reactance in pu (device base on `base_power_23`), referenced to the secondary winding's base voltage, from secondary to tertiary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`., validation range: `(0, 4)`
- `r_31::Union{Nothing, Float64}`: (default: `nothing`) Measured resistance in pu (device base on `base_power_31`), referenced to the tertiary winding's base voltage, from tertiary to primary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`., validation range: `(0, 4)`
- `x_31::Union{Nothing, Float64}`: (default: `nothing`) Measured reactance in pu (device base on `base_power_31`), referenced to the tertiary winding's base voltage, from tertiary to primary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`., validation range: `(0, 4)`
- `base_power_12::Union{Nothing, Float64}`: (default: `nothing`) Base power (MVA) for [per unitization](@ref per_unit) for primary-secondary windings. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`., validation range: `(0.0001, nothing)`
- `base_power_23::Union{Nothing, Float64}`: (default: `nothing`) Base power (MVA) for [per unitization](@ref per_unit) for secondary-tertiary windings. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`., validation range: `(0.0001, nothing)`
- `base_power_31::Union{Nothing, Float64}`: (default: `nothing`) Base power (MVA) for [per unitization](@ref per_unit) for tertiary-primary windings. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`., validation range: `(0.0001, nothing)`
- `magnetizing_shunt::Complex{Float64}`: (default: `0.0`) Magnetizing shunt admittance in pu (device base on the primary circuit's `base_power`) referenced to the primary circuit's base voltage
- `shunt_location::ThreeWindingTransformerShuntLocation`: (default: `ThreeWindingTransformerShuntLocation.PRIMARY`) Placement of `magnetizing_shunt` in the equivalent star model. See [`ThreeWindingTransformerShuntLocation`](@ref)
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ThreeWindingTransformer <: ACTransmission
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "The primary [`TransformerCircuit`](@ref) connecting the primary bus to the star bus"
    primary_circuit::TransformerCircuit
    "The secondary [`TransformerCircuit`](@ref) connecting the secondary bus to the star bus"
    secondary_circuit::TransformerCircuit
    "The tertiary [`TransformerCircuit`](@ref) connecting the tertiary bus to the star bus"
    tertiary_circuit::TransformerCircuit
    "Star (hidden) Bus that this component (equivalent model) is connected to"
    star_bus::ACBus
    "Measured resistance in pu (device base on `base_power_12`), referenced to the primary winding's base voltage, from primary to secondary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`."
    r_12::Union{Nothing, Float64}
    "Measured reactance in pu (device base on `base_power_12`), referenced to the primary winding's base voltage, from primary to secondary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`."
    x_12::Union{Nothing, Float64}
    "Measured resistance in pu (device base on `base_power_23`), referenced to the secondary winding's base voltage, from secondary to tertiary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`."
    r_23::Union{Nothing, Float64}
    "Measured reactance in pu (device base on `base_power_23`), referenced to the secondary winding's base voltage, from secondary to tertiary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`."
    x_23::Union{Nothing, Float64}
    "Measured resistance in pu (device base on `base_power_31`), referenced to the tertiary winding's base voltage, from tertiary to primary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`."
    r_31::Union{Nothing, Float64}
    "Measured reactance in pu (device base on `base_power_31`), referenced to the tertiary winding's base voltage, from tertiary to primary windings. Not synced with the star-leg values after construction; see struct docstring. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`."
    x_31::Union{Nothing, Float64}
    "Base power (MVA) for [per unitization](@ref per_unit) for primary-secondary windings. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`."
    base_power_12::Union{Nothing, Float64}
    "Base power (MVA) for [per unitization](@ref per_unit) for secondary-tertiary windings. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`."
    base_power_23::Union{Nothing, Float64}
    "Base power (MVA) for [per unitization](@ref per_unit) for tertiary-primary windings. Optional; all pairwise measured-impedance fields must be set together or all be `nothing`."
    base_power_31::Union{Nothing, Float64}
    "Magnetizing shunt admittance in pu (device base on the primary circuit's `base_power`) referenced to the primary circuit's base voltage"
    magnetizing_shunt::Complex{Float64}
    "Placement of `magnetizing_shunt` in the equivalent star model. See [`ThreeWindingTransformerShuntLocation`](@ref)"
    shunt_location::ThreeWindingTransformerShuntLocation
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ThreeWindingTransformer(name, primary_circuit, secondary_circuit, tertiary_circuit, star_bus, r_12=nothing, x_12=nothing, r_23=nothing, x_23=nothing, r_31=nothing, x_31=nothing, base_power_12=nothing, base_power_23=nothing, base_power_31=nothing, magnetizing_shunt=0.0, shunt_location=ThreeWindingTransformerShuntLocation.PRIMARY, services=Device[], ext=Dict{String, Any}(), )
    ThreeWindingTransformer(name, primary_circuit, secondary_circuit, tertiary_circuit, star_bus, r_12, x_12, r_23, x_23, r_31, x_31, base_power_12, base_power_23, base_power_31, magnetizing_shunt, shunt_location, services, ext, InfrastructureSystemsInternal(), )
end

function ThreeWindingTransformer(; name, primary_circuit, secondary_circuit, tertiary_circuit, star_bus, r_12=nothing, x_12=nothing, r_23=nothing, x_23=nothing, r_31=nothing, x_31=nothing, base_power_12=nothing, base_power_23=nothing, base_power_31=nothing, magnetizing_shunt=0.0, shunt_location=ThreeWindingTransformerShuntLocation.PRIMARY, services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    ThreeWindingTransformer(name, primary_circuit, secondary_circuit, tertiary_circuit, star_bus, r_12, x_12, r_23, x_23, r_31, x_31, base_power_12, base_power_23, base_power_31, magnetizing_shunt, shunt_location, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function ThreeWindingTransformer(::Nothing)
    ThreeWindingTransformer(;
        name="init",
        primary_circuit=TransformerCircuit(nothing),
        secondary_circuit=TransformerCircuit(nothing),
        tertiary_circuit=TransformerCircuit(nothing),
        star_bus=ACBus(nothing),
        r_12=nothing,
        x_12=nothing,
        r_23=nothing,
        x_23=nothing,
        r_31=nothing,
        x_31=nothing,
        base_power_12=nothing,
        base_power_23=nothing,
        base_power_31=nothing,
        magnetizing_shunt=0.0,
        shunt_location=ThreeWindingTransformerShuntLocation.PRIMARY,
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`ThreeWindingTransformer`](@ref) `name`."""
get_name(value::ThreeWindingTransformer) = value.name
"""Get [`ThreeWindingTransformer`](@ref) `primary_circuit`."""
get_primary_circuit(value::ThreeWindingTransformer) = value.primary_circuit
"""Get [`ThreeWindingTransformer`](@ref) `secondary_circuit`."""
get_secondary_circuit(value::ThreeWindingTransformer) = value.secondary_circuit
"""Get [`ThreeWindingTransformer`](@ref) `tertiary_circuit`."""
get_tertiary_circuit(value::ThreeWindingTransformer) = value.tertiary_circuit
"""Get [`ThreeWindingTransformer`](@ref) `star_bus`."""
get_star_bus(value::ThreeWindingTransformer) = value.star_bus
"""Get [`ThreeWindingTransformer`](@ref) `r_12` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_r_12_unitful`](@ref)."""
get_r_12(value::ThreeWindingTransformer, units) = InfrastructureSystems._strip_units(get_value(value, Val(:r_12), Val(:ohm), units))
"""Get [`ThreeWindingTransformer`](@ref) `r_12` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_r_12`](@ref)."""
get_r_12_unitful(value::ThreeWindingTransformer, units) = get_value(value, Val(:r_12), Val(:ohm), units)
get_r_12(value::ThreeWindingTransformer) = _units_arg_required(get_r_12, value, :r_12, Val(:ohm))
get_r_12_unitful(value::ThreeWindingTransformer) = _units_arg_required(get_r_12_unitful, value, :r_12, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_r_12), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_r_12_unitful), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
"""Get [`ThreeWindingTransformer`](@ref) `x_12` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_x_12_unitful`](@ref)."""
get_x_12(value::ThreeWindingTransformer, units) = InfrastructureSystems._strip_units(get_value(value, Val(:x_12), Val(:ohm), units))
"""Get [`ThreeWindingTransformer`](@ref) `x_12` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_x_12`](@ref)."""
get_x_12_unitful(value::ThreeWindingTransformer, units) = get_value(value, Val(:x_12), Val(:ohm), units)
get_x_12(value::ThreeWindingTransformer) = _units_arg_required(get_x_12, value, :x_12, Val(:ohm))
get_x_12_unitful(value::ThreeWindingTransformer) = _units_arg_required(get_x_12_unitful, value, :x_12, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_x_12), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_x_12_unitful), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
"""Get [`ThreeWindingTransformer`](@ref) `r_23` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_r_23_unitful`](@ref)."""
get_r_23(value::ThreeWindingTransformer, units) = InfrastructureSystems._strip_units(get_value(value, Val(:r_23), Val(:ohm), units))
"""Get [`ThreeWindingTransformer`](@ref) `r_23` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_r_23`](@ref)."""
get_r_23_unitful(value::ThreeWindingTransformer, units) = get_value(value, Val(:r_23), Val(:ohm), units)
get_r_23(value::ThreeWindingTransformer) = _units_arg_required(get_r_23, value, :r_23, Val(:ohm))
get_r_23_unitful(value::ThreeWindingTransformer) = _units_arg_required(get_r_23_unitful, value, :r_23, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_r_23), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_r_23_unitful), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
"""Get [`ThreeWindingTransformer`](@ref) `x_23` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_x_23_unitful`](@ref)."""
get_x_23(value::ThreeWindingTransformer, units) = InfrastructureSystems._strip_units(get_value(value, Val(:x_23), Val(:ohm), units))
"""Get [`ThreeWindingTransformer`](@ref) `x_23` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_x_23`](@ref)."""
get_x_23_unitful(value::ThreeWindingTransformer, units) = get_value(value, Val(:x_23), Val(:ohm), units)
get_x_23(value::ThreeWindingTransformer) = _units_arg_required(get_x_23, value, :x_23, Val(:ohm))
get_x_23_unitful(value::ThreeWindingTransformer) = _units_arg_required(get_x_23_unitful, value, :x_23, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_x_23), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_x_23_unitful), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
"""Get [`ThreeWindingTransformer`](@ref) `r_31` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_r_31_unitful`](@ref)."""
get_r_31(value::ThreeWindingTransformer, units) = InfrastructureSystems._strip_units(get_value(value, Val(:r_31), Val(:ohm), units))
"""Get [`ThreeWindingTransformer`](@ref) `r_31` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_r_31`](@ref)."""
get_r_31_unitful(value::ThreeWindingTransformer, units) = get_value(value, Val(:r_31), Val(:ohm), units)
get_r_31(value::ThreeWindingTransformer) = _units_arg_required(get_r_31, value, :r_31, Val(:ohm))
get_r_31_unitful(value::ThreeWindingTransformer) = _units_arg_required(get_r_31_unitful, value, :r_31, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_r_31), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_r_31_unitful), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
"""Get [`ThreeWindingTransformer`](@ref) `x_31` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_x_31_unitful`](@ref)."""
get_x_31(value::ThreeWindingTransformer, units) = InfrastructureSystems._strip_units(get_value(value, Val(:x_31), Val(:ohm), units))
"""Get [`ThreeWindingTransformer`](@ref) `x_31` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_x_31`](@ref)."""
get_x_31_unitful(value::ThreeWindingTransformer, units) = get_value(value, Val(:x_31), Val(:ohm), units)
get_x_31(value::ThreeWindingTransformer) = _units_arg_required(get_x_31, value, :x_31, Val(:ohm))
get_x_31_unitful(value::ThreeWindingTransformer) = _units_arg_required(get_x_31_unitful, value, :x_31, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_x_31), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_x_31_unitful), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU

_get_base_power_12(value::ThreeWindingTransformer) = value.base_power_12

_get_base_power_23(value::ThreeWindingTransformer) = value.base_power_23

_get_base_power_31(value::ThreeWindingTransformer) = value.base_power_31
"""Get [`ThreeWindingTransformer`](@ref) `magnetizing_shunt` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_magnetizing_shunt_unitful`](@ref)."""
get_magnetizing_shunt(value::ThreeWindingTransformer, units) = InfrastructureSystems._strip_units(get_value(value, Val(:magnetizing_shunt), Val(:siemens), units))
"""Get [`ThreeWindingTransformer`](@ref) `magnetizing_shunt` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_magnetizing_shunt`](@ref)."""
get_magnetizing_shunt_unitful(value::ThreeWindingTransformer, units) = get_value(value, Val(:magnetizing_shunt), Val(:siemens), units)
get_magnetizing_shunt(value::ThreeWindingTransformer) = _units_arg_required(get_magnetizing_shunt, value, :magnetizing_shunt, Val(:siemens))
get_magnetizing_shunt_unitful(value::ThreeWindingTransformer) = _units_arg_required(get_magnetizing_shunt_unitful, value, :magnetizing_shunt, Val(:siemens))
InfrastructureSystems.display_units_arg(::typeof(get_magnetizing_shunt), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_magnetizing_shunt_unitful), ::Type{ThreeWindingTransformer}) = InfrastructureSystems.SU
"""Get [`ThreeWindingTransformer`](@ref) `shunt_location`."""
get_shunt_location(value::ThreeWindingTransformer) = value.shunt_location
"""Get [`ThreeWindingTransformer`](@ref) `services`."""
get_services(value::ThreeWindingTransformer) = value.services
"""Get [`ThreeWindingTransformer`](@ref) `ext`."""
get_ext(value::ThreeWindingTransformer) = value.ext
"""Get [`ThreeWindingTransformer`](@ref) `internal`."""
get_internal(value::ThreeWindingTransformer) = value.internal

"""Set [`ThreeWindingTransformer`](@ref) `star_bus`."""
set_star_bus!(value::ThreeWindingTransformer, val) = value.star_bus = val
"""Set [`ThreeWindingTransformer`](@ref) `r_12`."""
set_r_12!(value::ThreeWindingTransformer, val) = value.r_12 = set_value(value, Val(:r_12), val, Val(:ohm))
set_r_12!(value::ThreeWindingTransformer, val::_UntaggedNumber) = _units_tag_required(set_r_12!, value, :r_12, Val(:ohm), val)
"""Set [`ThreeWindingTransformer`](@ref) `x_12`."""
set_x_12!(value::ThreeWindingTransformer, val) = value.x_12 = set_value(value, Val(:x_12), val, Val(:ohm))
set_x_12!(value::ThreeWindingTransformer, val::_UntaggedNumber) = _units_tag_required(set_x_12!, value, :x_12, Val(:ohm), val)
"""Set [`ThreeWindingTransformer`](@ref) `r_23`."""
set_r_23!(value::ThreeWindingTransformer, val) = value.r_23 = set_value(value, Val(:r_23), val, Val(:ohm))
set_r_23!(value::ThreeWindingTransformer, val::_UntaggedNumber) = _units_tag_required(set_r_23!, value, :r_23, Val(:ohm), val)
"""Set [`ThreeWindingTransformer`](@ref) `x_23`."""
set_x_23!(value::ThreeWindingTransformer, val) = value.x_23 = set_value(value, Val(:x_23), val, Val(:ohm))
set_x_23!(value::ThreeWindingTransformer, val::_UntaggedNumber) = _units_tag_required(set_x_23!, value, :x_23, Val(:ohm), val)
"""Set [`ThreeWindingTransformer`](@ref) `r_31`."""
set_r_31!(value::ThreeWindingTransformer, val) = value.r_31 = set_value(value, Val(:r_31), val, Val(:ohm))
set_r_31!(value::ThreeWindingTransformer, val::_UntaggedNumber) = _units_tag_required(set_r_31!, value, :r_31, Val(:ohm), val)
"""Set [`ThreeWindingTransformer`](@ref) `x_31`."""
set_x_31!(value::ThreeWindingTransformer, val) = value.x_31 = set_value(value, Val(:x_31), val, Val(:ohm))
set_x_31!(value::ThreeWindingTransformer, val::_UntaggedNumber) = _units_tag_required(set_x_31!, value, :x_31, Val(:ohm), val)
"""Set [`ThreeWindingTransformer`](@ref) `magnetizing_shunt`."""
set_magnetizing_shunt!(value::ThreeWindingTransformer, val) = value.magnetizing_shunt = set_value(value, Val(:magnetizing_shunt), val, Val(:siemens))
set_magnetizing_shunt!(value::ThreeWindingTransformer, val::_UntaggedNumber) = _units_tag_required(set_magnetizing_shunt!, value, :magnetizing_shunt, Val(:siemens), val)
"""Set [`ThreeWindingTransformer`](@ref) `shunt_location`."""
set_shunt_location!(value::ThreeWindingTransformer, val) = value.shunt_location = val
"""Set [`ThreeWindingTransformer`](@ref) `services`."""
set_services!(value::ThreeWindingTransformer, val) = value.services = val
"""Set [`ThreeWindingTransformer`](@ref) `ext`."""
set_ext!(value::ThreeWindingTransformer, val) = value.ext = val
