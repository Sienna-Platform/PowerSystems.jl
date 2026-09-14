"""
Supertype for power plant supplemental attributes that group generating units.

Concrete subtypes include [`ThermalPowerPlant`](@ref), [`HydroPowerPlant`](@ref),
[`RenewablePowerPlant`](@ref), [`CombinedCycleBlock`](@ref), and
[`CombinedCycleFractional`](@ref).
"""
abstract type PowerPlant <: SupplementalAttribute end

"""Get `internal`."""
get_internal(x::PowerPlant) = x.internal

# Every `PowerPlant` stores membership as one forward map, group number -> member ids.
# The reverse direction is derived on demand by the helpers below rather than stored: a
# second stored map is state a caller can contradict, and nothing validated the two against
# each other. The document and SiennaGridDB carry the same relation as association rows
# (`group_index`, plus `role` for a CombinedCycleBlock), never as either map.

"""Group numbers `id` belongs to in `group_map`, ascending. Empty means it is not a
member — a concrete value, so callers never dispatch on `nothing`."""
function _group_indices(group_map::AbstractDict, id::Int)
    return sort!([index for (index, ids) in group_map if id in ids])
end

"""Whether `id` appears anywhere in `group_map`."""
function _in_group_map(group_map::AbstractDict, id::Int)
    return any(ids -> id in ids, values(group_map))
end

"""Derive id -> group number from a forward map in which each member holds exactly one
group (shaft, penstock, PCC, exclusion group)."""
function _reverse_group_map(group_map::AbstractDict)
    return Dict{Int, Int}(
        id => index for (index, ids) in group_map for id in ids
    )
end

"""Derive id -> group numbers from a forward map in which a member may hold several
groups (a CT or CA can feed more than one HRSG)."""
function _reverse_multi_group_map(group_map::AbstractDict)
    reverse_map = Dict{Int, Vector{Int}}()
    for (index, ids) in group_map, id in ids
        push!(get!(reverse_map, id, Int[]), index)
    end
    foreach(sort!, values(reverse_map))
    return reverse_map
end

"""Drop `id` from each listed group of `group_map`, deleting groups left empty."""
function _drop_from_group_map!(group_map::AbstractDict, id::Int, indices)
    for index in indices
        filter!(x -> x != id, group_map[index])
        if isempty(group_map[index])
            delete!(group_map, index)
        end
    end
    return
end

"""Append `id` to `group_map[index]`, creating the group if it is new."""
function _push_to_group_map!(group_map::AbstractDict, id::Int, index::Int)
    push!(get!(group_map, index, Int[]), id)
    return
end

"""
Attribute to represent [`ThermalGen`](@ref) power plants with synchronous generation.
For Combined Cycle plants consider using [`CombinedCycleBlock`](@ref).

The shaft map field is used to represent shared shafts between units.

# Arguments
- `name::String`: Name of the power plant
- `shaft_map::Dict{Int, Vector{Int}}`: Mapping of shaft numbers to unit ids (multiple units can share a shaft)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct ThermalPowerPlant <: PowerPlant
    name::String
    shaft_map::Dict{Int, Vector{Int}}
    internal::InfrastructureSystemsInternal
end

# Deserialization variant: converts string-keyed dicts from JSON
function ThermalPowerPlant(
    name::String,
    shaft_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return ThermalPowerPlant(
        name,
        Dict{Int, Vector{Int}}(
            parse(Int, k) => Int.(v) for (k, v) in shaft_map
        ),
        internal,
    )
end

"""
    ThermalPowerPlant(; name, shaft_map, internal)

Construct a [`ThermalPowerPlant`](@ref).

# Arguments
- `name::String`: Name of the power plant
- `shaft_map::Dict{Int, Vector{Int}}`: (default: empty dict) Mapping of shaft numbers to unit ids
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function ThermalPowerPlant(;
    name::String,
    shaft_map::AbstractDict = Dict{Int, Vector{Int}}(),
    internal::InfrastructureSystemsInternal = InfrastructureSystemsInternal(),
)
    return ThermalPowerPlant(name, shaft_map, internal)
end

"""Get [`ThermalPowerPlant`](@ref) `name`."""
get_name(value::ThermalPowerPlant) = value.name
"""Get [`ThermalPowerPlant`](@ref) `shaft_map`."""
get_shaft_map(value::ThermalPowerPlant) = value.shaft_map
"""Unit id -> shaft number, derived from `shaft_map`."""
get_reverse_shaft_map(value::ThermalPowerPlant) = _reverse_group_map(value.shaft_map)

"""
Attribute to represent combined cycle generation by block configuration that shares heat recovery converstions.
For aggregate representations consider using [`CombinedCycleFractional`](@ref).

# Arguments
- `name::String`: Name of the combined cycle block
- `configuration::CombinedCycleConfiguration`: Configuration type of the combined cycle
- `heat_recovery_to_steam_factor::Float64`: Factor for heat recovery to steam conversion
- `hrsg_ct_map::Dict{Int, Vector{Int}}`: Mapping of HRSG numbers to CT unit ids (CTs as HRSG inputs)
- `hrsg_ca_map::Dict{Int, Vector{Int}}`: Mapping of HRSG numbers to CA unit ids (CAs as HRSG outputs)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct CombinedCycleBlock <: PowerPlant
    name::String
    configuration::CombinedCycleConfiguration
    heat_recovery_to_steam_factor::Float64
    hrsg_ct_map::Dict{Int, Vector{Int}}
    hrsg_ca_map::Dict{Int, Vector{Int}}
    internal::InfrastructureSystemsInternal
end

# Deserialization variant: converts string-keyed dicts from JSON
function CombinedCycleBlock(
    name::String,
    configuration::CombinedCycleConfiguration,
    heat_recovery_to_steam_factor::Float64,
    hrsg_ct_map::Dict{String, <:Any},
    hrsg_ca_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return CombinedCycleBlock(
        name,
        configuration,
        heat_recovery_to_steam_factor,
        Dict{Int, Vector{Int}}(
            parse(Int, k) => Int.(v) for (k, v) in hrsg_ct_map
        ),
        Dict{Int, Vector{Int}}(
            parse(Int, k) => Int.(v) for (k, v) in hrsg_ca_map
        ),
        internal,
    )
end

# Deserialization variant: configuration is also serialized as a string
function CombinedCycleBlock(
    name::String,
    configuration::String,
    heat_recovery_to_steam_factor::Float64,
    hrsg_ct_map::Dict{String, <:Any},
    hrsg_ca_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return CombinedCycleBlock(
        name,
        IS.deserialize(CombinedCycleConfiguration, configuration),
        heat_recovery_to_steam_factor,
        hrsg_ct_map,
        hrsg_ca_map,
        internal,
    )
end

"""
    CombinedCycleBlock(; name, configuration, heat_recovery_to_steam_factor, hrsg_ct_map, hrsg_ca_map, internal)

Construct a [`CombinedCycleBlock`](@ref).

# Arguments
- `name::String`: Name of the combined cycle block
- `configuration::CombinedCycleConfiguration`: Configuration type of the combined cycle
- `heat_recovery_to_steam_factor::Float64`: (default: `0.0`) Factor for heat recovery to steam conversion
- `hrsg_ct_map::AbstractDict`: (default: empty dict) Mapping of HRSG numbers to CT unit ids (CTs as HRSG inputs)
- `hrsg_ca_map::AbstractDict`: (default: empty dict) Mapping of HRSG numbers to CA unit ids (CAs as HRSG outputs)
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function CombinedCycleBlock(;
    name,
    configuration,
    heat_recovery_to_steam_factor = 0.0,
    hrsg_ct_map::AbstractDict = Dict{Int, Vector{Int}}(),
    hrsg_ca_map::AbstractDict = Dict{Int, Vector{Int}}(),
    internal = InfrastructureSystemsInternal(),
)
    return CombinedCycleBlock(
        name,
        configuration,
        heat_recovery_to_steam_factor,
        hrsg_ct_map,
        hrsg_ca_map,
        internal,
    )
end

"""Get [`CombinedCycleBlock`](@ref) `name`."""
get_name(value::CombinedCycleBlock) = value.name
"""Get [`CombinedCycleBlock`](@ref) `configuration`."""
get_configuration(value::CombinedCycleBlock) = value.configuration
"""Get [`CombinedCycleBlock`](@ref) `heat_recovery_to_steam_factor`."""
get_heat_recovery_to_steam_factor(value::CombinedCycleBlock) =
    value.heat_recovery_to_steam_factor
"""Get [`CombinedCycleBlock`](@ref) `hrsg_ct_map`."""
get_hrsg_ct_map(value::CombinedCycleBlock) = value.hrsg_ct_map
"""Get [`CombinedCycleBlock`](@ref) `hrsg_ca_map`."""
get_hrsg_ca_map(value::CombinedCycleBlock) = value.hrsg_ca_map
"""CT unit id -> HRSG numbers, derived from `hrsg_ct_map`. A CT can feed several HRSGs."""
get_ct_hrsg_map(value::CombinedCycleBlock) = _reverse_multi_group_map(value.hrsg_ct_map)
"""CA unit id -> HRSG numbers, derived from `hrsg_ca_map`. A CA can receive from several
HRSGs."""
get_ca_hrsg_map(value::CombinedCycleBlock) = _reverse_multi_group_map(value.hrsg_ca_map)

"""
Attribute to represent combined cycle generation when each unit represents a specific configuration and aggregate heat rate.
For block-level representations consider using [`CombinedCycleBlock`](@ref).

# Arguments
- `name::String`: Name of the combined cycle fractional plant
- `configuration::CombinedCycleConfiguration`: Configuration type of the combined cycle
- `operation_exclusion_map::Dict{Int, Vector{Int}}`: Mapping of operation exclusion group numbers to unit ids (only units in the same group can operate simultaneously)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct CombinedCycleFractional <: PowerPlant
    name::String
    configuration::CombinedCycleConfiguration
    operation_exclusion_map::Dict{Int, Vector{Int}}
    internal::InfrastructureSystemsInternal
end

# Deserialization variant: converts string-keyed dicts from JSON
function CombinedCycleFractional(
    name::String,
    configuration::CombinedCycleConfiguration,
    operation_exclusion_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return CombinedCycleFractional(
        name,
        configuration,
        Dict{Int, Vector{Int}}(
            parse(Int, k) => Int.(v) for (k, v) in operation_exclusion_map
        ),
        internal,
    )
end

# Deserialization variant: configuration is also serialized as a string
function CombinedCycleFractional(
    name::String,
    configuration::String,
    operation_exclusion_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return CombinedCycleFractional(
        name,
        IS.deserialize(CombinedCycleConfiguration, configuration),
        operation_exclusion_map,
        internal,
    )
end

"""
    CombinedCycleFractional(; name, configuration, operation_exclusion_map, internal)

Construct a [`CombinedCycleFractional`](@ref).

# Arguments
- `name::String`: Name of the combined cycle fractional plant
- `configuration::CombinedCycleConfiguration`: Configuration type of the combined cycle
- `operation_exclusion_map::AbstractDict`: (default: empty dict) Mapping of operation exclusion group numbers to unit ids
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function CombinedCycleFractional(;
    name,
    configuration,
    operation_exclusion_map::AbstractDict = Dict{Int, Vector{Int}}(),
    internal = InfrastructureSystemsInternal(),
)
    return CombinedCycleFractional(
        name,
        configuration,
        operation_exclusion_map,
        internal,
    )
end

"""Get [`CombinedCycleFractional`](@ref) `name`."""
get_name(value::CombinedCycleFractional) = value.name
"""Get [`CombinedCycleFractional`](@ref) `configuration`."""
get_configuration(value::CombinedCycleFractional) = value.configuration
"""Get [`CombinedCycleFractional`](@ref) `operation_exclusion_map`."""
get_operation_exclusion_map(value::CombinedCycleFractional) =
    value.operation_exclusion_map
"""Unit id -> exclusion group number, derived from `operation_exclusion_map`."""
get_inverse_operation_exclusion_map(value::CombinedCycleFractional) =
    _reverse_group_map(value.operation_exclusion_map)

"""
Attribute to represent hydro power plants with shared penstocks.

# Arguments
- `name::String`: Name of the hydro power plant
- `penstock_map::Dict{Int, Vector{Int}}`: Mapping of penstock numbers to unit ids (multiple units can share a penstock)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct HydroPowerPlant <: PowerPlant
    name::String
    penstock_map::Dict{Int, Vector{Int}}
    internal::InfrastructureSystemsInternal
end

# Deserialization variant: converts string-keyed dicts from JSON
function HydroPowerPlant(
    name::String,
    penstock_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return HydroPowerPlant(
        name,
        Dict{Int, Vector{Int}}(
            parse(Int, k) => Int.(v) for (k, v) in penstock_map
        ),
        internal,
    )
end

"""
    HydroPowerPlant(; name, penstock_map, internal)

Construct a [`HydroPowerPlant`](@ref).

# Arguments
- `name::String`: Name of the hydro power plant
- `penstock_map::Dict{Int, Vector{Int}}`: (default: empty dict) Mapping of penstock numbers to unit ids
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function HydroPowerPlant(;
    name::String,
    penstock_map::AbstractDict = Dict{Int, Vector{Int}}(),
    internal::InfrastructureSystemsInternal = InfrastructureSystemsInternal(),
)
    return HydroPowerPlant(name, penstock_map, internal)
end

"""Get [`HydroPowerPlant`](@ref) `name`."""
get_name(value::HydroPowerPlant) = value.name
"""Get [`HydroPowerPlant`](@ref) `penstock_map`."""
get_penstock_map(value::HydroPowerPlant) = value.penstock_map
"""Unit id -> penstock number, derived from `penstock_map`."""
get_reverse_penstock_map(value::HydroPowerPlant) = _reverse_group_map(value.penstock_map)

"""
Attribute to represent renewable power plants.

# Arguments
- `name::String`: Name of the renewable power plant
- `pcc_map::Dict{Int, Vector{Int}}`: Mapping of PCC numbers to unit ids (multiple units can share a PCC)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct RenewablePowerPlant <: PowerPlant
    name::String
    pcc_map::Dict{Int, Vector{Int}}
    internal::InfrastructureSystemsInternal
end

# Deserialization variant: converts string-keyed dicts from JSON
function RenewablePowerPlant(
    name::String,
    pcc_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return RenewablePowerPlant(
        name,
        Dict{Int, Vector{Int}}(
            parse(Int, k) => Int.(v) for (k, v) in pcc_map
        ),
        internal,
    )
end

"""
    RenewablePowerPlant(; name, pcc_map, internal)

Construct a [`RenewablePowerPlant`](@ref). This supports multiple point of common coupling (PCC) connections.

# Arguments
- `name::String`: Name of the renewable power plant
- `pcc_map::Dict{Int, Vector{Int}}`: (default: empty dict) Mapping of PCC numbers to unit ids
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function RenewablePowerPlant(;
    name::String,
    pcc_map::AbstractDict = Dict{Int, Vector{Int}}(),
    internal::InfrastructureSystemsInternal = InfrastructureSystemsInternal(),
)
    return RenewablePowerPlant(name, pcc_map, internal)
end

"""Get [`RenewablePowerPlant`](@ref) `name`."""
get_name(value::RenewablePowerPlant) = value.name
"""Get [`RenewablePowerPlant`](@ref) `pcc_map`."""
get_pcc_map(value::RenewablePowerPlant) = value.pcc_map
"""Unit id -> PCC number, derived from `pcc_map`."""
get_reverse_pcc_map(value::RenewablePowerPlant) = _reverse_group_map(value.pcc_map)

# Every plant type below groups its members the same way and differs only in which map
# holds the grouping, what its numbers are called, and which components can be members.
# Those three are stated once per type here; the query/attach/detach bodies are written
# once against them, in the same shape `_push_group_index!` already dispatches.
_group_map(plant::ThermalPowerPlant) = plant.shaft_map
_group_map(plant::HydroPowerPlant) = plant.penstock_map
_group_map(plant::RenewablePowerPlant) = plant.pcc_map
_group_map(plant::CombinedCycleFractional) = plant.operation_exclusion_map

_group_label(::ThermalPowerPlant) = "Shaft number"
_group_label(::HydroPowerPlant) = "Penstock number"
_group_label(::RenewablePowerPlant) = "PCC number"
_group_label(::CombinedCycleFractional) = "Exclusion group"

_group_members(sys::System, plant::ThermalPowerPlant) =
    get_associated_components(sys, plant; component_type = ThermalGen)
_group_members(sys::System, plant::HydroPowerPlant) =
    get_associated_components(sys, plant; component_type = HydroGen)
# A RenewablePowerPlant groups generators and storage alike, so it takes no type filter.
_group_members(sys::System, plant::RenewablePowerPlant) =
    get_associated_components(sys, plant)
_group_members(sys::System, plant::CombinedCycleFractional) =
    get_associated_components(sys, plant; component_type = ThermalGen)

function _get_components_in_group(sys::System, plant::PowerPlant, group_number::Int)
    group_map = _group_map(plant)
    if !haskey(group_map, group_number)
        throw(
            IS.ArgumentError(
                "$(_group_label(plant)) $group_number does not exist in plant $(get_name(plant))",
            ),
        )
    end
    ids = group_map[group_number]
    return filter(c -> IS.get_id(c) in ids, _group_members(sys, plant))
end

function _attach_to_group!(sys::System, component, plant::PowerPlant, group_number::Int)
    id = IS.get_id(component)
    if _in_group_map(_group_map(plant), id)
        throw(
            IS.ArgumentError(
                "$(get_name(component)) is already part of plant $(get_name(plant))",
            ),
        )
    end
    IS.add_supplemental_attribute!(sys.data, component, plant)
    _push_group_index!(component, plant, group_number)
    return
end

function _detach_from_group!(sys::System, component, plant::PowerPlant)
    id = IS.get_id(component)
    groups = _group_indices(_group_map(plant), id)
    if isempty(groups)
        throw(
            IS.ArgumentError(
                "$(get_name(component)) is not part of plant $(get_name(plant))",
            ),
        )
    end
    _drop_from_group_map!(_group_map(plant), id, groups)
    IS.remove_supplemental_attribute!(sys.data, component, plant)
    return
end

"""
    get_components_in_shaft(sys::System, plant::ThermalPowerPlant, shaft_number::Int)

Get all thermal generators connected to a specific shaft in a [`ThermalPowerPlant`](@ref).

# Arguments
- `sys::System`: The system containing the components
- `plant::ThermalPowerPlant`: The thermal power plant
- `shaft_number::Int`: The shaft number to query

# Returns
- `Vector{ThermalGen}`: Vector of thermal generators on the specified shaft

# Throws
- `ArgumentError`: If the shaft number does not exist in the plant
"""
get_components_in_shaft(sys::System, plant::ThermalPowerPlant, shaft_number::Int) =
    _get_components_in_group(sys, plant, shaft_number)

"""
    get_components_in_penstock(sys::System, plant::HydroPowerPlant, penstock_number::Int)

Get all hydro generators connected to a specific penstock in a [`HydroPowerPlant`](@ref).

# Arguments
- `sys::System`: The system containing the components
- `plant::HydroPowerPlant`: The hydro power plant
- `penstock_number::Int`: The penstock number to query

# Returns
- `Vector{Union{HydroTurbine, HydroPumpTurbine}}`: Vector of hydro generators on the specified penstock

# Throws
- `ArgumentError`: If the penstock number does not exist in the plant
"""
get_components_in_penstock(sys::System, plant::HydroPowerPlant, penstock_number::Int) =
    _get_components_in_group(sys, plant, penstock_number)

"""
    get_components_in_pcc(sys::System, plant::RenewablePowerPlant, pcc_number::Int)

Get all renewable generators and storage devices connected to a specific PCC in a [`RenewablePowerPlant`](@ref).

# Arguments
- `sys::System`: The system containing the components
- `plant::RenewablePowerPlant`: The renewable power plant
- `pcc_number::Int`: The PCC (point of common coupling) number to query

# Returns
- `Vector{Union{RenewableGen, EnergyReservoirStorage}}`: Vector of components on the specified PCC

# Throws
- `ArgumentError`: If the PCC number does not exist in the plant
"""
get_components_in_pcc(sys::System, plant::RenewablePowerPlant, pcc_number::Int) =
    _get_components_in_group(sys, plant, pcc_number)

"""No group index: the plain attribute path (`EmissionsData`, `GeographicInfo`, the
`Outage` types, ...) needs no map update."""
_push_group_index!(::Any, ::SupplementalAttribute, ::Nothing) = nothing

_push_group_index!(component, attribute::ThermalPowerPlant, group_index::Integer) =
    _push_to_group_map!(attribute.shaft_map, IS.get_id(component), group_index)
_push_group_index!(component, attribute::HydroPowerPlant, group_index::Integer) =
    _push_to_group_map!(attribute.penstock_map, IS.get_id(component), group_index)
_push_group_index!(component, attribute::RenewablePowerPlant, group_index::Integer) =
    _push_to_group_map!(attribute.pcc_map, IS.get_id(component), group_index)
_push_group_index!(component, attribute::CombinedCycleFractional, group_index::Integer) =
    _push_to_group_map!(
        attribute.operation_exclusion_map,
        IS.get_id(component),
        group_index,
    )

"""A CT/CA's HRSG map is chosen by the component's prime mover type."""
function _push_group_index!(
    component::ThermalGen,
    attribute::CombinedCycleBlock,
    group_index::Integer,
)
    id = IS.get_id(component)
    prime_mover = get_prime_mover_type(component)
    if prime_mover == PrimeMovers.CT
        _push_to_group_map!(attribute.hrsg_ct_map, id, group_index)
    elseif prime_mover == PrimeMovers.CA
        _push_to_group_map!(attribute.hrsg_ca_map, id, group_index)
    else
        throw(
            IS.ArgumentError(
                "Invalid prime mover type $prime_mover for generator $(get_name(component)). Only CT and CA generators can be added to a CombinedCycleBlock.",
            ),
        )
    end
    return nothing
end

"""Loud fallback: a `group_index` on an attribute type with no group-index dispatch is a
caller bug, not something to attach without recording it."""
function _push_group_index!(::Any, attribute::SupplementalAttribute, group_index::Integer)
    error(
        "$(nameof(typeof(attribute))) carries group_index=$group_index but has no " *
        "group-index dispatch — only ThermalPowerPlant, HydroPowerPlant, " *
        "RenewablePowerPlant, CombinedCycleBlock, and CombinedCycleFractional accept one",
    )
end

"""
    add_supplemental_attribute!(sys::System, component::ThermalGen, attribute::ThermalPowerPlant; shaft_number::Int)

Add a thermal generator to a [`ThermalPowerPlant`](@ref) by associating it with a shaft number.
This attaches the plant as a supplemental attribute to the generator and records the
generator's id in the plant's shaft map.

# Arguments
- `sys::System`: The system containing the generator
- `component::ThermalGen`: The thermal generator to add to the plant
- `attribute::ThermalPowerPlant`: The thermal power plant
- `shaft_number::Int`: The shaft number to associate with the generator
"""
add_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::ThermalPowerPlant;
    shaft_number::Int,
) = _attach_to_group!(sys, component, attribute, shaft_number)

"""
    add_supplemental_attribute!(sys::System, component::Union{HydroPumpTurbine, HydroTurbine}, attribute::HydroPowerPlant; penstock_number::Int)

Add a hydro generator to a [`HydroPowerPlant`](@ref) by associating it with a penstock number.
This attaches the plant as a supplemental attribute to the generator and records the
generator's id in the plant's penstock map.

# Arguments
- `sys::System`: The system containing the generator
- `component::Union{HydroPumpTurbine, HydroTurbine}`: The hydro generator to add to the plant
- `attribute::HydroPowerPlant`: The hydro power plant
- `penstock_number::Int`: The penstock number to associate with the generator
"""
add_supplemental_attribute!(
    sys::System,
    component::Union{HydroPumpTurbine, HydroTurbine},
    attribute::HydroPowerPlant,
    penstock_number::Int,
) = _attach_to_group!(sys, component, attribute, penstock_number)

"""
    add_supplemental_attribute!(sys::System, component::HydroDispatch, attribute::HydroPowerPlant, args...; kwargs...)

Error-throwing overload. HydroDispatch is not supported in a HydroPowerPlant.
"""
function add_supplemental_attribute!(
    ::System,
    ::HydroDispatch,
    ::HydroPowerPlant,
    args...;
    kwargs...,
)
    throw(
        IS.ArgumentError(
            "HydroDispatch is not supported in a HydroPowerPlant. Consider using HydroTurbine instead.",
        ),
    )
end

"""
    add_supplemental_attribute!(sys::System, component::Union{RenewableGen, EnergyReservoirStorage}, attribute::RenewablePowerPlant; pcc_number::Int=1)

Add a renewable generator or storage to a [`RenewablePowerPlant`](@ref) by associating it with a PCC number.
This attaches the plant as a supplemental attribute to the generator and records the
generator's id in the plant's PCC map.

# Arguments
- `sys::System`: The system containing the generator
- `component::Union{RenewableGen, EnergyReservoirStorage}`: The renewable generator or storage to add to the plant
- `attribute::RenewablePowerPlant`: The renewable power plant
- `pcc_number::Int`: (default: 1) The PCC (point of common coupling) number to associate with the generator
"""
add_supplemental_attribute!(
    sys::System,
    component::Union{RenewableGen, EnergyReservoirStorage},
    attribute::RenewablePowerPlant,
    pcc_number::Int,
) = _attach_to_group!(sys, component, attribute, pcc_number)

"""
    remove_supplemental_attribute!(sys::System, component::ThermalGen, attribute::ThermalPowerPlant)

Remove a thermal generator from a [`ThermalPowerPlant`](@ref).
This removes the plant as a supplemental attribute from the generator and removes the
generator's id from the plant's shaft map.

# Arguments
- `sys::System`: The system containing the generator
- `component::ThermalGen`: The thermal generator to remove from the plant
- `attribute::ThermalPowerPlant`: The thermal power plant
"""
remove_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::ThermalPowerPlant,
) = _detach_from_group!(sys, component, attribute)

"""
    remove_supplemental_attribute!(sys::System, component::Union{HydroPumpTurbine, HydroTurbine}, attribute::HydroPowerPlant)

Remove a hydro generator from a [`HydroPowerPlant`](@ref).
This removes the plant as a supplemental attribute from the generator and removes the
generator's id from the plant's penstock map.

# Arguments
- `sys::System`: The system containing the generator
- `component::Union{HydroPumpTurbine, HydroTurbine}`: The hydro generator to remove from the plant
- `attribute::HydroPowerPlant`: The hydro power plant
"""
remove_supplemental_attribute!(
    sys::System,
    component::Union{HydroPumpTurbine, HydroTurbine},
    attribute::HydroPowerPlant,
) = _detach_from_group!(sys, component, attribute)

"""
    remove_supplemental_attribute!(sys::System, component::Union{RenewableGen, EnergyReservoirStorage}, attribute::RenewablePowerPlant)

Remove a renewable generator or storage from a [`RenewablePowerPlant`](@ref).
This removes the plant as a supplemental attribute from the generator and removes the
generator's id from the plant's PCC map.

# Arguments
- `sys::System`: The system containing the generator
- `component::Union{RenewableGen, EnergyReservoirStorage}`: The renewable generator or storage to remove from the plant
- `attribute::RenewablePowerPlant`: The renewable power plant
"""
remove_supplemental_attribute!(
    sys::System,
    component::Union{RenewableGen, EnergyReservoirStorage},
    attribute::RenewablePowerPlant,
) = _detach_from_group!(sys, component, attribute)

"""
    add_supplemental_attribute!(sys::System, component::ThermalGen, attribute::CombinedCycleBlock; hrsg_number::Int)

Add a thermal generator to a [`CombinedCycleBlock`](@ref) by associating it with an HRSG number.
Only generators with CT (combustion turbine as HRSG input) or CA (combined cycle steam part as HRSG output)
prime mover types can be added.

# Arguments
- `sys::System`: The system containing the generator
- `component::ThermalGen`: The thermal generator to add to the block (must have prime mover type CT or CA)
- `attribute::CombinedCycleBlock`: The combined cycle block
- `hrsg_number::Int`: The HRSG number to associate with the generator
"""
function add_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::CombinedCycleBlock;
    hrsg_number::Int,
)
    id = IS.get_id(component)
    ct_hrsgs = _group_indices(attribute.hrsg_ct_map, id)
    ca_hrsgs = _group_indices(attribute.hrsg_ca_map, id)
    if hrsg_number in ct_hrsgs || hrsg_number in ca_hrsgs
        throw(
            IS.ArgumentError(
                "Generator $(get_name(component)) is already part of block $(get_name(attribute)) with $(hrsg_number)",
            ),
        )
    end
    # _push_group_index! owns the CT/CA prime-mover validation, so it runs first: a
    # rejected generator must not leave an association behind.
    _push_group_index!(component, attribute, hrsg_number)
    # IS holds a single association per (component, attribute) pair, so a CT or CA
    # already feeding one HRSG must not be attached again when it feeds a second.
    if isempty(ct_hrsgs) && isempty(ca_hrsgs)
        IS.add_supplemental_attribute!(sys.data, component, attribute)
    end
    return
end

"""
    remove_supplemental_attribute!(sys::System, component::ThermalGen, attribute::CombinedCycleBlock)

Remove a thermal generator from a [`CombinedCycleBlock`](@ref).
This removes the block as a supplemental attribute from the generator and removes the
generator's id from the block's HRSG maps.

# Arguments
- `sys::System`: The system containing the generator
- `component::ThermalGen`: The thermal generator to remove from the block
- `attribute::CombinedCycleBlock`: The combined cycle block
"""
function remove_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::CombinedCycleBlock,
)
    id = IS.get_id(component)
    ct_hrsgs = _group_indices(attribute.hrsg_ct_map, id)
    ca_hrsgs = _group_indices(attribute.hrsg_ca_map, id)
    if isempty(ct_hrsgs) && isempty(ca_hrsgs)
        throw(
            IS.ArgumentError(
                "Generator $(get_name(component)) is not part of block $(get_name(attribute))",
            ),
        )
    end
    _drop_from_group_map!(attribute.hrsg_ct_map, id, ct_hrsgs)
    _drop_from_group_map!(attribute.hrsg_ca_map, id, ca_hrsgs)
    IS.remove_supplemental_attribute!(sys.data, component, attribute)
    return
end

"""
    add_supplemental_attribute!(sys::System, component::ThermalGen, attribute::CombinedCycleFractional; exclusion_group::Int)

Add a thermal generator to a [`CombinedCycleFractional`](@ref) by associating it with an exclusion group number.
Only generators with CC (combined cycle) prime mover type can be added.

# Arguments
- `sys::System`: The system containing the generator
- `component::ThermalGen`: The thermal generator to add to the plant (must have prime mover type CC)
- `attribute::CombinedCycleFractional`: The combined cycle fractional plant
- `exclusion_group::Int`: The exclusion group number to associate with the generator
"""
function add_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::CombinedCycleFractional;
    exclusion_group::Int,
)
    id = IS.get_id(component)
    existing_groups = _group_indices(attribute.operation_exclusion_map, id)
    if !isempty(existing_groups)
        throw(
            IS.ArgumentError(
                "Generator $(get_name(component)) is already part of plant $(get_name(attribute)) \
                under exclusion group $(only(existing_groups))",
            ),
        )
    end
    prime_mover = get_prime_mover_type(component)
    if prime_mover != PrimeMovers.CC
        throw(
            IS.ArgumentError(
                "Invalid prime mover type $prime_mover for generator $(get_name(component)). Only CC generators can be added to a CombinedCycleFractional.",
            ),
        )
    end
    IS.add_supplemental_attribute!(sys.data, component, attribute)
    _push_group_index!(component, attribute, exclusion_group)
    return
end

"""
    remove_supplemental_attribute!(sys::System, component::ThermalGen, attribute::CombinedCycleFractional)

Remove a thermal generator from a [`CombinedCycleFractional`](@ref).
This removes the plant as a supplemental attribute from the generator and removes the
generator's id from the plant's exclusion maps.

# Arguments
- `sys::System`: The system containing the generator
- `component::ThermalGen`: The thermal generator to remove from the plant
- `attribute::CombinedCycleFractional`: The combined cycle fractional plant
"""
remove_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::CombinedCycleFractional,
) = _detach_from_group!(sys, component, attribute)

"""
    get_components_in_exclusion_group(sys::System, plant::CombinedCycleFractional, exclusion_group::Int)

Get all thermal generators in a specific exclusion group of a [`CombinedCycleFractional`](@ref).

# Arguments
- `sys::System`: The system containing the components
- `plant::CombinedCycleFractional`: The combined cycle fractional plant
- `exclusion_group::Int`: The exclusion group number to query

# Returns
- `Vector{ThermalGen}`: Vector of thermal generators in the specified exclusion group

# Throws
- `ArgumentError`: If the exclusion group does not exist in the plant
"""
get_components_in_exclusion_group(
    sys::System,
    plant::CombinedCycleFractional,
    exclusion_group::Int,
) = _get_components_in_group(sys, plant, exclusion_group)
