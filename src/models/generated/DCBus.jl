#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct DCBus <: Bus
        number::Int
        name::String
        available::Bool
        magnitude::Union{Nothing, Float64}
        voltage_limits::Union{Nothing, MinMax}
        base_voltage::Union{Nothing, Float64}
        area::Union{Nothing, Area}
        load_zone::Union{Nothing, LoadZone}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A DC bus

# Arguments
- `number::Int`: A unique bus identification number (positive integer)
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations.
- `magnitude::Union{Nothing, Float64}`: voltage as a multiple of `base_voltage`, validation range: `voltage_limits`
- `voltage_limits::Union{Nothing, MinMax}`: limits on the voltage variation as multiples of `base_voltage`
- `base_voltage::Union{Nothing, Float64}`: the base voltage in kV, validation range: `(0, nothing)`
- `area::Union{Nothing, Area}`: (default: `nothing`) the area containing the DC bus
- `load_zone::Union{Nothing, LoadZone}`: (default: `nothing`) the load zone containing the DC bus
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
- `input_basis`: (keyword constructor only, required) `CU` or `NU`, the units of bare numbers on unit-bearing fields. Tagged values (`50.0u"MW"`) keep their own units
"""
mutable struct DCBus <: Bus
    "A unique bus identification number (positive integer)"
    number::Int
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations."
    available::Bool
    "voltage as a multiple of `base_voltage`"
    magnitude::Union{Nothing, Float64}
    "limits on the voltage variation as multiples of `base_voltage`"
    voltage_limits::Union{Nothing, MinMax}
    "the base voltage in kV"
    base_voltage::Union{Nothing, Float64}
    "the area containing the DC bus"
    area::Union{Nothing, Area}
    "the load zone containing the DC bus"
    load_zone::Union{Nothing, LoadZone}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function DCBus(number, name, available, magnitude, voltage_limits, base_voltage, area=nothing, load_zone=nothing, ext=Dict{String, Any}(), )
    DCBus(number, name, available, magnitude, voltage_limits, base_voltage, area, load_zone, ext, InfrastructureSystemsInternal(), )
end

function DCBus(; number, name, available, magnitude, voltage_limits, base_voltage, area=nothing, load_zone=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), input_basis::Union{ComponentBaseUnit, NaturalUnit}, )
    value = DCBus(number, name, available, _placeholder(magnitude), _placeholder(voltage_limits), base_voltage, area, load_zone, ext, internal, )
    set_magnitude!(value, _tag(magnitude, input_basis, Val(:kv)))
    set_voltage_limits!(value, _tag(voltage_limits, input_basis, Val(:kv)))
    return value
end
_takes_input_basis(::Type{<:DCBus}) = true

# Constructor for demo purposes; non-functional.
function DCBus(::Nothing)
    DCBus(;
        number=0,
        name="init",
        available=false,
        magnitude=0.0,
        voltage_limits=(min=0.0, max=0.0),
        base_voltage=nothing,
        area=nothing,
        load_zone=nothing,
        ext=Dict{String, Any}(),
        input_basis=CU,
    )
end

"""Get [`DCBus`](@ref) `number`."""
get_number(value::DCBus) = value.number
"""Get [`DCBus`](@ref) `name`."""
get_name(value::DCBus) = value.name
"""Get [`DCBus`](@ref) `available`."""
get_available(value::DCBus) = value.available
"""Get [`DCBus`](@ref) `magnitude` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_magnitude_unitful`](@ref)."""
get_magnitude(value::DCBus, units) = InfrastructureSystems._strip_units(get_value(value, Val(:magnitude), Val(:kv), units))
"""Get [`DCBus`](@ref) `magnitude` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_magnitude`](@ref)."""
get_magnitude_unitful(value::DCBus, units) = get_value(value, Val(:magnitude), Val(:kv), units)
get_magnitude(value::DCBus) = _units_arg_required(get_magnitude, value, :magnitude, Val(:kv))
get_magnitude_unitful(value::DCBus) = _units_arg_required(get_magnitude_unitful, value, :magnitude, Val(:kv))
InfrastructureSystems.display_units_arg(::typeof(get_magnitude), ::Type{DCBus}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_magnitude_unitful), ::Type{DCBus}) = InfrastructureSystems.SU
"""Get [`DCBus`](@ref) `voltage_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `u"MW"` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_voltage_limits_unitful`](@ref)."""
get_voltage_limits(value::DCBus, units) = InfrastructureSystems._strip_units(get_value(value, Val(:voltage_limits), Val(:kv), units))
"""Get [`DCBus`](@ref) `voltage_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `u"MW"`). For a bare number see [`get_voltage_limits`](@ref)."""
get_voltage_limits_unitful(value::DCBus, units) = get_value(value, Val(:voltage_limits), Val(:kv), units)
get_voltage_limits(value::DCBus) = _units_arg_required(get_voltage_limits, value, :voltage_limits, Val(:kv))
get_voltage_limits_unitful(value::DCBus) = _units_arg_required(get_voltage_limits_unitful, value, :voltage_limits, Val(:kv))
InfrastructureSystems.display_units_arg(::typeof(get_voltage_limits), ::Type{DCBus}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_voltage_limits_unitful), ::Type{DCBus}) = InfrastructureSystems.SU
"""Get [`DCBus`](@ref) `base_voltage`."""
get_base_voltage(value::DCBus) = value.base_voltage
"""Get [`DCBus`](@ref) `area`."""
get_area(value::DCBus) = value.area
"""Get [`DCBus`](@ref) `load_zone`."""
get_load_zone(value::DCBus) = value.load_zone
"""Get [`DCBus`](@ref) `ext`."""
get_ext(value::DCBus) = value.ext
"""Get [`DCBus`](@ref) `internal`."""
get_internal(value::DCBus) = value.internal

"""Set [`DCBus`](@ref) `number`."""
set_number!(value::DCBus, val) = value.number = val
"""Set [`DCBus`](@ref) `available`."""
set_available!(value::DCBus, val) = value.available = val
"""Set [`DCBus`](@ref) `magnitude`."""
set_magnitude!(value::DCBus, val) = value.magnitude = set_value(value, Val(:magnitude), val, Val(:kv))
set_magnitude!(value::DCBus, val::_UntaggedNumber) = _units_tag_required(set_magnitude!, value, :magnitude, Val(:kv), val)
"""Set [`DCBus`](@ref) `voltage_limits`."""
set_voltage_limits!(value::DCBus, val) = value.voltage_limits = set_value(value, Val(:voltage_limits), val, Val(:kv))
set_voltage_limits!(value::DCBus, val::_UntaggedNumber) = _units_tag_required(set_voltage_limits!, value, :voltage_limits, Val(:kv), val)
set_voltage_limits!(value::DCBus, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_voltage_limits!, value, :voltage_limits, Val(:kv), val)
"""Set [`DCBus`](@ref) `area`."""
set_area!(value::DCBus, val) = value.area = val
"""Set [`DCBus`](@ref) `load_zone`."""
set_load_zone!(value::DCBus, val) = value.load_zone = val
"""Set [`DCBus`](@ref) `ext`."""
set_ext!(value::DCBus, val) = value.ext = val


function from_openapi(po::PO.DCBus, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return DCBus(;
        number = po.number,
        name = po.name,
        available = po.available,
        magnitude = _or_default(po.magnitude, nothing),
        voltage_limits = _minmax_from_po(po.voltage_limits),
        base_voltage = _or_default(po.base_voltage, nothing),
        area = resolve_ref(refs, po.area, Area),
        load_zone = resolve_ref(refs, po.load_zone, LoadZone),
        input_basis = CU,
    )
end

function from_openapi(po::PO.DCBus, refs::OpenAPIRefs, ::NaturalUnit)
    return DCBus(;
        number = po.number,
        name = po.name,
        available = po.available,
        magnitude = _or_default(po.magnitude, nothing),
        voltage_limits = _minmax_from_po(po.voltage_limits),
        base_voltage = _or_default(po.base_voltage, nothing),
        area = resolve_ref(refs, po.area, Area),
        load_zone = resolve_ref(refs, po.load_zone, LoadZone),
        input_basis = CU,
    )
end

function from_openapi(po::PO.DCBus, refs::OpenAPIRefs)
    return from_openapi(po, refs, CU)
end

function to_openapi(value::DCBus, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.DCBus(;
        id = component_id(refs, value),
        number = get_number(value),
        name = get_name(value),
        available = get_available(value),
        magnitude = _optional_to_wire(get_magnitude(value, CU)),
        voltage_limits = _minmax_po_optional(get_voltage_limits(value, CU)),
        base_voltage = _optional_to_wire(get_base_voltage(value)),
        area = _component_id_optional(refs, get_area(value)),
        load_zone = _component_id_optional(refs, get_load_zone(value)),
    )
end

function to_openapi(value::DCBus, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.DCBus(;
        id = component_id(refs, value),
        number = get_number(value),
        name = get_name(value),
        available = get_available(value),
        magnitude = _optional_to_wire(get_magnitude(value, CU)),
        voltage_limits = _minmax_po_optional(get_voltage_limits(value, CU)),
        base_voltage = _optional_to_wire(get_base_voltage(value)),
        area = _component_id_optional(refs, get_area(value)),
        load_zone = _component_id_optional(refs, get_load_zone(value)),
    )
end
