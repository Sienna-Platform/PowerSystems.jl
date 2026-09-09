#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TwoWindingTransformer <: ACTransmission
        name::String
        circuit::TransformerCircuit
        magnetizing_shunt::Complex{Float64}
        shunt_location::TwoWindingTransformerShuntLocation
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A two-winding transformer connecting two buses.

All series electrical data — the modeled arc, tap, phase shift, series impedance `r`/`x`, ratings, per-winding base power, base voltages, and control — lives on the single [`TransformerCircuit`](@ref) obtained with [`get_circuit`](@ref); availability is circuit-level (see [`get_available`](@ref)). The `magnetizing_shunt` admittance and its `shunt_location` are transformer-level. The model uses an equivalent circuit assuming the impedance is on the high-voltage side and allocates iron losses and magnetizing susceptance according to `shunt_location`. The transformer's device base is the circuit's `base_power`.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `circuit::TransformerCircuit`: The [`TransformerCircuit`](@ref) carrying this transformer's arc, tap, phase shift, series impedance, ratings, per-winding base power/voltages, availability, and control
- `magnetizing_shunt::Complex{Float64}`: (default: `0.0`) Magnetizing shunt admittance in pu (device base on the circuit's `base_power`) referenced to the circuit's `base_voltage_primary`
- `shunt_location::TwoWindingTransformerShuntLocation`: (default: `TwoWindingTransformerShuntLocation.PRIMARY`) Placement of `magnetizing_shunt` on the two sides of the circuit arc. See [`TwoWindingTransformerShuntLocation`](@ref)
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct TwoWindingTransformer <: ACTransmission
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "The [`TransformerCircuit`](@ref) carrying this transformer's arc, tap, phase shift, series impedance, ratings, per-winding base power/voltages, availability, and control"
    circuit::TransformerCircuit
    "Magnetizing shunt admittance in pu (device base on the circuit's `base_power`) referenced to the circuit's `base_voltage_primary`"
    magnetizing_shunt::Complex{Float64}
    "Placement of `magnetizing_shunt` on the two sides of the circuit arc. See [`TwoWindingTransformerShuntLocation`](@ref)"
    shunt_location::TwoWindingTransformerShuntLocation
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TwoWindingTransformer(name, circuit, magnetizing_shunt=0.0, shunt_location=TwoWindingTransformerShuntLocation.PRIMARY, services=Device[], ext=Dict{String, Any}(), )
    TwoWindingTransformer(name, circuit, magnetizing_shunt, shunt_location, services, ext, InfrastructureSystemsInternal(), )
end

function TwoWindingTransformer(; name, circuit, magnetizing_shunt=0.0, shunt_location=TwoWindingTransformerShuntLocation.PRIMARY, services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    TwoWindingTransformer(name, circuit, magnetizing_shunt, shunt_location, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function TwoWindingTransformer(::Nothing)
    TwoWindingTransformer(;
        name="init",
        circuit=TransformerCircuit(nothing),
        magnetizing_shunt=0.0,
        shunt_location=TwoWindingTransformerShuntLocation.PRIMARY,
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`TwoWindingTransformer`](@ref) `name`."""
get_name(value::TwoWindingTransformer) = value.name
"""Get [`TwoWindingTransformer`](@ref) `circuit`."""
get_circuit(value::TwoWindingTransformer) = value.circuit
"""Get [`TwoWindingTransformer`](@ref) `magnetizing_shunt` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_magnetizing_shunt_unitful`](@ref)."""
get_magnetizing_shunt(value::TwoWindingTransformer, units) = InfrastructureSystems._strip_units(get_value(value, Val(:magnetizing_shunt), Val(:siemens), units))
"""Get [`TwoWindingTransformer`](@ref) `magnetizing_shunt` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_magnetizing_shunt`](@ref)."""
get_magnetizing_shunt_unitful(value::TwoWindingTransformer, units) = get_value(value, Val(:magnetizing_shunt), Val(:siemens), units)
get_magnetizing_shunt(value::TwoWindingTransformer) = _units_arg_required(get_magnetizing_shunt, value, :magnetizing_shunt, Val(:siemens))
get_magnetizing_shunt_unitful(value::TwoWindingTransformer) = _units_arg_required(get_magnetizing_shunt_unitful, value, :magnetizing_shunt, Val(:siemens))
InfrastructureSystems.display_units_arg(::typeof(get_magnetizing_shunt), ::Type{TwoWindingTransformer}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_magnetizing_shunt_unitful), ::Type{TwoWindingTransformer}) = InfrastructureSystems.SU
"""Get [`TwoWindingTransformer`](@ref) `shunt_location`."""
get_shunt_location(value::TwoWindingTransformer) = value.shunt_location
"""Get [`TwoWindingTransformer`](@ref) `services`."""
get_services(value::TwoWindingTransformer) = value.services
"""Get [`TwoWindingTransformer`](@ref) `ext`."""
get_ext(value::TwoWindingTransformer) = value.ext
"""Get [`TwoWindingTransformer`](@ref) `internal`."""
get_internal(value::TwoWindingTransformer) = value.internal

"""Set [`TwoWindingTransformer`](@ref) `magnetizing_shunt`."""
set_magnetizing_shunt!(value::TwoWindingTransformer, val) = value.magnetizing_shunt = set_value(value, Val(:magnetizing_shunt), val, Val(:siemens))
set_magnetizing_shunt!(value::TwoWindingTransformer, val::_UntaggedNumber) = _units_tag_required(set_magnetizing_shunt!, value, :magnetizing_shunt, Val(:siemens), val)
"""Set [`TwoWindingTransformer`](@ref) `shunt_location`."""
set_shunt_location!(value::TwoWindingTransformer, val) = value.shunt_location = val
"""Set [`TwoWindingTransformer`](@ref) `services`."""
set_services!(value::TwoWindingTransformer, val) = value.services = val
"""Set [`TwoWindingTransformer`](@ref) `ext`."""
set_ext!(value::TwoWindingTransformer, val) = value.ext = val
