"""
Abstract supertype for supplemental attributes representing physical power plants,
grouping generators that share physical infrastructure (e.g., a common shaft, penstock,
or point of common coupling).

Concrete subtypes include [`ThermalPowerPlant`](@ref), [`HydroPowerPlant`](@ref),
[`RenewablePowerPlant`](@ref), [`CombinedCycleBlock`](@ref), and
[`CombinedCycleFractional`](@ref).
"""
abstract type PowerPlant <: SupplementalAttribute end

"""Get `internal`."""
get_internal(x::PowerPlant) = x.internal

"""
    struct ThermalPowerPlant <: PowerPlant
        name::String
        shaft_map::Dict{Int, Vector{Base.UUID}}
        reverse_shaft_map::Dict{Base.UUID, Int}
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute representing a [`ThermalGen`](@ref) power plant where multiple
generator units share mechanical shafts. The shaft maps capture the unit ↔ shaft topology
for multi-shaft dispatch and synchronous condensing configurations.

# Arguments
- `name::String`: Name of the power plant.
- `shaft_map::Dict{Int, Vector{Base.UUID}}`: Mapping from shaft index to the UUIDs of
    units connected to that shaft (multiple units may share one shaft).
- `reverse_shaft_map::Dict{Base.UUID, Int}`: Reverse mapping from a unit's UUID to the
    index of its shaft.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal
    reference.

# See Also
- [`CombinedCycleBlock`](@ref): Plant attribute for combined cycle block-level
    representations.
- [`ThermalGen`](@ref): Abstract type for thermal generating units.
"""
struct ThermalPowerPlant <: PowerPlant
    name::String
    shaft_map::Dict{Int, Vector{Base.UUID}}
    reverse_shaft_map::Dict{Base.UUID, Int}
    internal::InfrastructureSystemsInternal
end

# Deserialization variant: converts string-keyed dicts from JSON
function ThermalPowerPlant(
    name::String,
    shaft_map::Dict{String, <:Any},
    reverse_shaft_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return ThermalPowerPlant(
        name,
        Dict{Int, Vector{Base.UUID}}(
            parse(Int, k) => Base.UUID.(v) for (k, v) in shaft_map
        ),
        Dict{Base.UUID, Int}(Base.UUID(k) => v for (k, v) in reverse_shaft_map),
        internal,
    )
end

"""
    ThermalPowerPlant(; name, shaft_map, reverse_shaft_map, internal)

Construct a [`ThermalPowerPlant`](@ref).

# Arguments
- `name::String`: Name of the power plant.
- `shaft_map::Dict{Int, Vector{Base.UUID}}`: (default: empty dict) Mapping from shaft
    index to the UUIDs of units connected to that shaft.
- `reverse_shaft_map::Dict{Base.UUID, Int}`: (default: empty dict) Reverse mapping from
    a unit's UUID to its shaft index.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`)
    (**Do not modify.**) PowerSystems.jl internal reference.
"""
function ThermalPowerPlant(;
    name::String,
    shaft_map::AbstractDict = Dict{Int, Vector{Base.UUID}}(),
    reverse_shaft_map::AbstractDict = Dict{Base.UUID, Int}(),
    internal::InfrastructureSystemsInternal = InfrastructureSystemsInternal(),
)
    return ThermalPowerPlant(name, shaft_map, reverse_shaft_map, internal)
end

"""Get [`ThermalPowerPlant`](@ref) `name`."""
get_name(value::ThermalPowerPlant) = value.name
"""Get [`ThermalPowerPlant`](@ref) `shaft_map`: mapping from shaft index to the UUIDs of generators connected to that shaft."""
get_shaft_map(value::ThermalPowerPlant) = value.shaft_map
"""Get [`ThermalPowerPlant`](@ref) `reverse_shaft_map`: reverse mapping from a generator's UUID to its shaft index."""
get_reverse_shaft_map(value::ThermalPowerPlant) = value.reverse_shaft_map

"""
    struct CombinedCycleBlock <: PowerPlant
        name::String
        configuration::CombinedCycleConfiguration
        heat_recovery_to_steam_factor::Float64
        hrsg_ct_map::Dict{Int, Vector{Base.UUID}}
        hrsg_ca_map::Dict{Int, Vector{Base.UUID}}
        ct_hrsg_map::Dict{Base.UUID, Vector{Int}}
        ca_hrsg_map::Dict{Base.UUID, Vector{Int}}
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute representing a combined cycle plant modeled at the block level,
where combustion turbines (CTs) feed heat recovery steam generators (HRSGs) that drive
combined-cycle steam turbines (CAs). The internal maps capture the CT→HRSG→CA topology.

# Arguments
- `name::String`: Name of the combined cycle block.
- `configuration::`[`CombinedCycleConfiguration`](@ref): Configuration type of the
    combined cycle plant.
- `heat_recovery_to_steam_factor::Float64`: Fraction of CT exhaust heat recovered by the
    HRSG for steam generation.
- `hrsg_ct_map::Dict{Int, Vector{Base.UUID}}`: Mapping from HRSG index to the UUIDs of
    CTs feeding that HRSG.
- `hrsg_ca_map::Dict{Int, Vector{Base.UUID}}`: Mapping from HRSG index to the UUIDs of
    CAs driven by that HRSG.
- `ct_hrsg_map::Dict{Base.UUID, Vector{Int}}`: Reverse mapping from a CT's UUID to the
    indices of HRSGs it feeds (a CT can feed multiple HRSGs).
- `ca_hrsg_map::Dict{Base.UUID, Vector{Int}}`: Reverse mapping from a CA's UUID to the
    indices of HRSGs that supply it (a CA can receive from multiple HRSGs).
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal
    reference.

# See Also
- [`CombinedCycleFractional`](@ref): Combined cycle attribute for aggregate fractional
    representations.
- [`CombinedCycleConfiguration`](@ref): Enumeration of combined cycle plant configurations.
"""
struct CombinedCycleBlock <: PowerPlant
    name::String
    configuration::CombinedCycleConfiguration
    heat_recovery_to_steam_factor::Float64
    hrsg_ct_map::Dict{Int, Vector{Base.UUID}}
    hrsg_ca_map::Dict{Int, Vector{Base.UUID}}
    ct_hrsg_map::Dict{Base.UUID, Vector{Int}}
    ca_hrsg_map::Dict{Base.UUID, Vector{Int}}
    internal::InfrastructureSystemsInternal
end

# Deserialization variant: converts string-keyed dicts from JSON
function CombinedCycleBlock(
    name::String,
    configuration::CombinedCycleConfiguration,
    heat_recovery_to_steam_factor::Float64,
    hrsg_ct_map::Dict{String, <:Any},
    hrsg_ca_map::Dict{String, <:Any},
    ct_hrsg_map::Dict{String, <:Any},
    ca_hrsg_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return CombinedCycleBlock(
        name,
        configuration,
        heat_recovery_to_steam_factor,
        Dict{Int, Vector{Base.UUID}}(
            parse(Int, k) => Base.UUID.(v) for (k, v) in hrsg_ct_map
        ),
        Dict{Int, Vector{Base.UUID}}(
            parse(Int, k) => Base.UUID.(v) for (k, v) in hrsg_ca_map
        ),
        Dict{Base.UUID, Vector{Int}}(Base.UUID(k) => v for (k, v) in ct_hrsg_map),
        Dict{Base.UUID, Vector{Int}}(Base.UUID(k) => v for (k, v) in ca_hrsg_map),
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
    ct_hrsg_map::Dict{String, <:Any},
    ca_hrsg_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return CombinedCycleBlock(
        name,
        IS.deserialize(CombinedCycleConfiguration, configuration),
        heat_recovery_to_steam_factor,
        hrsg_ct_map,
        hrsg_ca_map,
        ct_hrsg_map,
        ca_hrsg_map,
        internal,
    )
end

"""
    CombinedCycleBlock(; name, configuration, heat_recovery_to_steam_factor, hrsg_ct_map, hrsg_ca_map, ct_hrsg_map, ca_hrsg_map, internal)

Construct a [`CombinedCycleBlock`](@ref).

# Arguments
- `name::String`: Name of the combined cycle block
- `configuration::CombinedCycleConfiguration`: Configuration type of the combined cycle
- `heat_recovery_to_steam_factor::Float64`: (default: `0.0`) Factor for heat recovery to steam conversion
- `hrsg_ct_map::AbstractDict`: (default: empty dict) Mapping of HRSG numbers to CT unit UUIDs (CTs as HRSG inputs)
- `hrsg_ca_map::AbstractDict`: (default: empty dict) Mapping of HRSG numbers to CA unit UUIDs (CAs as HRSG outputs)
- `ct_hrsg_map::AbstractDict`: (default: empty dict) Reverse mapping from CT unit UUID to HRSG numbers
- `ca_hrsg_map::AbstractDict`: (default: empty dict) Reverse mapping from CA unit UUID to HRSG numbers
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`)
    (**Do not modify.**) PowerSystems.jl internal reference.
"""
function CombinedCycleBlock(;
    name,
    configuration,
    heat_recovery_to_steam_factor = 0.0,
    hrsg_ct_map::AbstractDict = Dict{Int, Vector{Base.UUID}}(),
    hrsg_ca_map::AbstractDict = Dict{Int, Vector{Base.UUID}}(),
    ct_hrsg_map::AbstractDict = Dict{Base.UUID, Vector{Int}}(),
    ca_hrsg_map::AbstractDict = Dict{Base.UUID, Vector{Int}}(),
    internal = InfrastructureSystemsInternal(),
)
    return CombinedCycleBlock(
        name,
        configuration,
        heat_recovery_to_steam_factor,
        hrsg_ct_map,
        hrsg_ca_map,
        ct_hrsg_map,
        ca_hrsg_map,
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
"""Get [`CombinedCycleBlock`](@ref) `hrsg_ct_map`: mapping from HRSG index to the UUIDs of combustion turbines (CT) feeding that HRSG."""
get_hrsg_ct_map(value::CombinedCycleBlock) = value.hrsg_ct_map
"""Get [`CombinedCycleBlock`](@ref) `hrsg_ca_map`: mapping from HRSG index to the UUIDs of combined-cycle steam turbines (CA) driven by that HRSG."""
get_hrsg_ca_map(value::CombinedCycleBlock) = value.hrsg_ca_map
"""Get [`CombinedCycleBlock`](@ref) `ct_hrsg_map`: reverse mapping from a combustion turbine's (CT) UUID to the indices of HRSGs it feeds."""
get_ct_hrsg_map(value::CombinedCycleBlock) = value.ct_hrsg_map
"""Get [`CombinedCycleBlock`](@ref) `ca_hrsg_map`: reverse mapping from a combined-cycle steam turbine's (CA) UUID to the indices of HRSGs that supply it."""
get_ca_hrsg_map(value::CombinedCycleBlock) = value.ca_hrsg_map

"""
    struct CombinedCycleFractional <: PowerPlant
        name::String
        configuration::CombinedCycleConfiguration
        operation_exclusion_map::Dict{Int, Vector{Base.UUID}}
        inverse_operation_exclusion_map::Dict{Base.UUID, Int}
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute representing a combined cycle plant modeled at the aggregate
(fractional) level, where each generator unit represents a specific plant configuration
with an aggregate heat rate. Mutually exclusive operating groups are tracked via the
operation exclusion maps.

# Arguments
- `name::String`: Name of the combined cycle fractional plant.
- `configuration::`[`CombinedCycleConfiguration`](@ref): Configuration type of the
    combined cycle plant.
- `operation_exclusion_map::Dict{Int, Vector{Base.UUID}}`: Mapping from exclusion group
    index to the UUIDs of units in that group; only one unit per group may operate
    simultaneously.
- `inverse_operation_exclusion_map::Dict{Base.UUID, Int}`: Reverse mapping from a unit's
    UUID to its exclusion group index.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal
    reference.

# See Also
- [`CombinedCycleBlock`](@ref): Combined cycle attribute for detailed block-level
    representations.
- [`CombinedCycleConfiguration`](@ref): Enumeration of combined cycle plant configurations.
"""
struct CombinedCycleFractional <: PowerPlant
    name::String
    configuration::CombinedCycleConfiguration
    operation_exclusion_map::Dict{Int, Vector{Base.UUID}}
    inverse_operation_exclusion_map::Dict{Base.UUID, Int}
    internal::InfrastructureSystemsInternal
end

# Deserialization variant: converts string-keyed dicts from JSON
function CombinedCycleFractional(
    name::String,
    configuration::CombinedCycleConfiguration,
    operation_exclusion_map::Dict{String, <:Any},
    inverse_operation_exclusion_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return CombinedCycleFractional(
        name,
        configuration,
        Dict{Int, Vector{Base.UUID}}(
            parse(Int, k) => Base.UUID.(v) for (k, v) in operation_exclusion_map
        ),
        Dict{Base.UUID, Int}(
            Base.UUID(k) => v for (k, v) in inverse_operation_exclusion_map
        ),
        internal,
    )
end

# Deserialization variant: configuration is also serialized as a string
function CombinedCycleFractional(
    name::String,
    configuration::String,
    operation_exclusion_map::Dict{String, <:Any},
    inverse_operation_exclusion_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return CombinedCycleFractional(
        name,
        IS.deserialize(CombinedCycleConfiguration, configuration),
        operation_exclusion_map,
        inverse_operation_exclusion_map,
        internal,
    )
end

"""
    CombinedCycleFractional(; name, configuration, operation_exclusion_map, inverse_operation_exclusion_map, internal)

Construct a [`CombinedCycleFractional`](@ref).

# Arguments
- `name::String`: Name of the combined cycle fractional plant
- `configuration::CombinedCycleConfiguration`: Configuration type of the combined cycle
- `operation_exclusion_map::AbstractDict`: (default: empty dict) Mapping of operation exclusion group numbers to unit UUIDs
- `inverse_operation_exclusion_map::AbstractDict`: (default: empty dict) Reverse mapping from unit UUID to exclusion group number
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`)
    (**Do not modify.**) PowerSystems.jl internal reference.
"""
function CombinedCycleFractional(;
    name,
    configuration,
    operation_exclusion_map::AbstractDict = Dict{Int, Vector{Base.UUID}}(),
    inverse_operation_exclusion_map::AbstractDict = Dict{Base.UUID, Int}(),
    internal = InfrastructureSystemsInternal(),
)
    return CombinedCycleFractional(
        name,
        configuration,
        operation_exclusion_map,
        inverse_operation_exclusion_map,
        internal,
    )
end

"""Get [`CombinedCycleFractional`](@ref) `name`."""
get_name(value::CombinedCycleFractional) = value.name
"""Get [`CombinedCycleFractional`](@ref) `configuration`."""
get_configuration(value::CombinedCycleFractional) = value.configuration
"""Get [`CombinedCycleFractional`](@ref) `operation_exclusion_map`: mapping from exclusion group index to the UUIDs of units in that group; only one unit per group may operate simultaneously."""
get_operation_exclusion_map(value::CombinedCycleFractional) =
    value.operation_exclusion_map
"""Get [`CombinedCycleFractional`](@ref) `inverse_operation_exclusion_map`: reverse mapping from a unit's UUID to its exclusion group index."""
get_inverse_operation_exclusion_map(value::CombinedCycleFractional) =
    value.inverse_operation_exclusion_map

"""
    struct HydroPowerPlant <: PowerPlant
        name::String
        penstock_map::Dict{Int, Vector{Base.UUID}}
        reverse_penstock_map::Dict{Base.UUID, Int}
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute representing a [`HydroGen`](@ref) power plant where multiple
generating units share penstocks. The penstock maps capture the unit ↔ penstock topology
for hydraulic coupling constraints.

# Arguments
- `name::String`: Name of the hydro power plant.
- `penstock_map::Dict{Int, Vector{Base.UUID}}`: Mapping from penstock index to the UUIDs
    of units connected to that penstock (multiple units may share one penstock).
- `reverse_penstock_map::Dict{Base.UUID, Int}`: Reverse mapping from a unit's UUID to the
    index of its penstock.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal
    reference.

# See Also
- [`HydroGen`](@ref): Abstract type for hydroelectric generating units.
"""
struct HydroPowerPlant <: PowerPlant
    name::String
    penstock_map::Dict{Int, Vector{Base.UUID}}
    reverse_penstock_map::Dict{Base.UUID, Int}
    internal::InfrastructureSystemsInternal
end

# Deserialization variant: converts string-keyed dicts from JSON
function HydroPowerPlant(
    name::String,
    penstock_map::Dict{String, <:Any},
    reverse_penstock_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return HydroPowerPlant(
        name,
        Dict{Int, Vector{Base.UUID}}(
            parse(Int, k) => Base.UUID.(v) for (k, v) in penstock_map
        ),
        Dict{Base.UUID, Int}(Base.UUID(k) => v for (k, v) in reverse_penstock_map),
        internal,
    )
end

"""
    HydroPowerPlant(; name, penstock_map, reverse_penstock_map, internal)

Construct a [`HydroPowerPlant`](@ref).

# Arguments
- `name::String`: Name of the hydro power plant.
- `penstock_map::Dict{Int, Vector{Base.UUID}}`: (default: empty dict) Mapping from
    penstock index to the UUIDs of units connected to that penstock.
- `reverse_penstock_map::Dict{Base.UUID, Int}`: (default: empty dict) Reverse mapping
    from a unit's UUID to its penstock index.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`)
    (**Do not modify.**) PowerSystems.jl internal reference.
"""
function HydroPowerPlant(;
    name::String,
    penstock_map::AbstractDict = Dict{Int, Vector{Base.UUID}}(),
    reverse_penstock_map::AbstractDict = Dict{Base.UUID, Int}(),
    internal::InfrastructureSystemsInternal = InfrastructureSystemsInternal(),
)
    return HydroPowerPlant(name, penstock_map, reverse_penstock_map, internal)
end

"""Get [`HydroPowerPlant`](@ref) `name`."""
get_name(value::HydroPowerPlant) = value.name
"""Get [`HydroPowerPlant`](@ref) `penstock_map`: mapping from penstock index to the UUIDs of generators connected to that penstock."""
get_penstock_map(value::HydroPowerPlant) = value.penstock_map
"""Get [`HydroPowerPlant`](@ref) `reverse_penstock_map`: reverse mapping from a generator's UUID to its penstock index."""
get_reverse_penstock_map(value::HydroPowerPlant) = value.reverse_penstock_map

"""
    struct RenewablePowerPlant <: PowerPlant
        name::String
        pcc_map::Dict{Int, Vector{Base.UUID}}
        reverse_pcc_map::Dict{Base.UUID, Int}
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute representing a [`RenewableGen`](@ref) power plant where multiple
generating units share a point of common coupling (PCC). The PCC maps capture the
unit ↔ PCC topology for grid connection constraints.

# Arguments
- `name::String`: Name of the renewable power plant.
- `pcc_map::Dict{Int, Vector{Base.UUID}}`: Mapping from PCC index to the UUIDs of units
    connected to that PCC (multiple units may share one PCC).
- `reverse_pcc_map::Dict{Base.UUID, Int}`: Reverse mapping from a unit's UUID to the
    index of its PCC.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal
    reference.

# See Also
- [`RenewableGen`](@ref): Abstract type for renewable generating units.
"""
struct RenewablePowerPlant <: PowerPlant
    name::String
    pcc_map::Dict{Int, Vector{Base.UUID}}
    reverse_pcc_map::Dict{Base.UUID, Int}
    internal::InfrastructureSystemsInternal
end

# Deserialization variant: converts string-keyed dicts from JSON
function RenewablePowerPlant(
    name::String,
    pcc_map::Dict{String, <:Any},
    reverse_pcc_map::Dict{String, <:Any},
    internal::InfrastructureSystemsInternal,
)
    return RenewablePowerPlant(
        name,
        Dict{Int, Vector{Base.UUID}}(
            parse(Int, k) => Base.UUID.(v) for (k, v) in pcc_map
        ),
        Dict{Base.UUID, Int}(Base.UUID(k) => v for (k, v) in reverse_pcc_map),
        internal,
    )
end

"""
    RenewablePowerPlant(; name, pcc_map, reverse_pcc_map, internal)

Construct a [`RenewablePowerPlant`](@ref).

# Arguments
- `name::String`: Name of the renewable power plant.
- `pcc_map::Dict{Int, Vector{Base.UUID}}`: (default: empty dict) Mapping from PCC index
    to the UUIDs of units connected to that PCC.
- `reverse_pcc_map::Dict{Base.UUID, Int}`: (default: empty dict) Reverse mapping from a
    unit's UUID to its PCC index.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`)
    (**Do not modify.**) PowerSystems.jl internal reference.
"""
function RenewablePowerPlant(;
    name::String,
    pcc_map::AbstractDict = Dict{Int, Vector{Base.UUID}}(),
    reverse_pcc_map::AbstractDict = Dict{Base.UUID, Int}(),
    internal::InfrastructureSystemsInternal = InfrastructureSystemsInternal(),
)
    return RenewablePowerPlant(name, pcc_map, reverse_pcc_map, internal)
end

"""Get [`RenewablePowerPlant`](@ref) `name`."""
get_name(value::RenewablePowerPlant) = value.name
"""Get [`RenewablePowerPlant`](@ref) `pcc_map`: mapping from PCC (point of common coupling) index to the UUIDs of generators and storage devices connected to that PCC."""
get_pcc_map(value::RenewablePowerPlant) = value.pcc_map
"""Get [`RenewablePowerPlant`](@ref) `reverse_pcc_map`: reverse mapping from a component's UUID to its PCC index."""
get_reverse_pcc_map(value::RenewablePowerPlant) = value.reverse_pcc_map

"""
    get_components_in_shaft(sys::System, plant::ThermalPowerPlant, shaft_number::Int)

Return all thermal generators connected to shaft `shaft_number` in a
[`ThermalPowerPlant`](@ref).

# Arguments
- `sys::System`: The system containing the components.
- `plant::ThermalPowerPlant`: The thermal power plant.
- `shaft_number::Int`: The shaft number to query.

# Throws
- `ArgumentError`: if `shaft_number` does not exist in the plant.

See also: [`add_supplemental_attribute!`](@ref), [`get_shaft_map`](@ref)
"""
function get_components_in_shaft(
    sys::System,
    plant::ThermalPowerPlant,
    shaft_number::Int,
)
    shaft_map = get_shaft_map(plant)
    if !haskey(shaft_map, shaft_number)
        throw(
            IS.ArgumentError(
                "Shaft number $shaft_number does not exist in plant $(get_name(plant))",
            ),
        )
    end

    uuids = shaft_map[shaft_number]
    all_components = get_associated_components(sys, plant; component_type = ThermalGen)
    # Filter to only include components on this shaft
    return filter(c -> IS.get_uuid(c) in uuids, all_components)
end

"""
    get_components_in_penstock(sys::System, plant::HydroPowerPlant, penstock_number::Int)

Return all hydro generators connected to penstock `penstock_number` in a
[`HydroPowerPlant`](@ref).

# Arguments
- `sys::System`: The system containing the components.
- `plant::HydroPowerPlant`: The hydro power plant.
- `penstock_number::Int`: The penstock number to query.

# Throws
- `ArgumentError`: if `penstock_number` does not exist in the plant.

See also: [`add_supplemental_attribute!`](@ref), [`get_penstock_map`](@ref)
"""
function get_components_in_penstock(
    sys::System,
    plant::HydroPowerPlant,
    penstock_number::Int,
)
    penstock_map = get_penstock_map(plant)
    if !haskey(penstock_map, penstock_number)
        throw(
            IS.ArgumentError(
                "Penstock number $penstock_number does not exist in plant $(get_name(plant))",
            ),
        )
    end

    uuids = penstock_map[penstock_number]
    all_components = get_associated_components(sys, plant; component_type = HydroGen)
    # Filter to only include components on this penstock
    return filter(c -> IS.get_uuid(c) in uuids, all_components)
end

"""
    get_components_in_pcc(sys::System, plant::RenewablePowerPlant, pcc_number::Int)

Return all renewable generators and storage devices connected to PCC `pcc_number`
(point of common coupling) in a [`RenewablePowerPlant`](@ref).

# Arguments
- `sys::System`: The system containing the components.
- `plant::RenewablePowerPlant`: The renewable power plant.
- `pcc_number::Int`: The PCC number to query.

# Throws
- `ArgumentError`: if `pcc_number` does not exist in the plant.

See also: [`add_supplemental_attribute!`](@ref), [`get_pcc_map`](@ref)
"""
function get_components_in_pcc(
    sys::System,
    plant::RenewablePowerPlant,
    pcc_number::Int,
)
    pcc_map = get_pcc_map(plant)
    if !haskey(pcc_map, pcc_number)
        throw(
            IS.ArgumentError(
                "PCC number $pcc_number does not exist in plant $(get_name(plant))",
            ),
        )
    end

    uuids = pcc_map[pcc_number]
    all_components = get_associated_components(sys, plant)
    # Filter to only include components on this PCC
    return filter(c -> IS.get_uuid(c) in uuids, all_components)
end

"""
    add_supplemental_attribute!(sys::System, component::ThermalGen, attribute::ThermalPowerPlant; shaft_number::Int)

Add a thermal generator to a [`ThermalPowerPlant`](@ref) by associating it with a shaft number.
This attaches the plant as a supplemental attribute to the generator and records the
generator's UUID in the plant's shaft map.

# Arguments
- `sys::System`: The system containing the generator.
- `component::ThermalGen`: The thermal generator to add to the plant.
- `attribute::ThermalPowerPlant`: The thermal power plant.
- `shaft_number::Int`: The shaft number to associate with the generator.

# Throws
- `ArgumentError`: if the generator is already associated with this plant.

See also: [`remove_supplemental_attribute!`](@ref), [`begin_supplemental_attributes_update`](@ref)
"""
function add_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::ThermalPowerPlant;
    shaft_number::Int,
)
    uuid = IS.get_uuid(component)
    if haskey(attribute.reverse_shaft_map, uuid)
        throw(
            IS.ArgumentError(
                "Generator $(get_name(component)) is already part of plant $(get_name(attribute))",
            ),
        )
    end
    IS.add_supplemental_attribute!(sys.data, component, attribute)
    if haskey(attribute.shaft_map, shaft_number)
        push!(attribute.shaft_map[shaft_number], uuid)
    else
        attribute.shaft_map[shaft_number] = [uuid]
    end
    attribute.reverse_shaft_map[uuid] = shaft_number
    return
end

"""
    add_supplemental_attribute!(sys::System, component::Union{HydroPumpTurbine, HydroTurbine}, attribute::HydroPowerPlant, penstock_number::Int)

Add a hydro generator to a [`HydroPowerPlant`](@ref) by associating it with a penstock number.
This attaches the plant as a supplemental attribute to the generator and records the
generator's UUID in the plant's penstock map.

!!! note
    `penstock_number` is a positional argument, unlike the keyword `shaft_number` in the
    [`ThermalPowerPlant`](@ref) overload. This inconsistency is a known API issue.

# Arguments
- `sys::System`: The system containing the generator.
- `component::Union{HydroPumpTurbine, HydroTurbine}`: The hydro generator to add to the plant.
- `attribute::HydroPowerPlant`: The hydro power plant.
- `penstock_number::Int`: The penstock number to associate with the generator.

# Throws
- `ArgumentError`: if the generator is already associated with this plant.
- `ArgumentError`: if `component` is a [`HydroDispatch`](@ref) — use [`HydroTurbine`](@ref) instead.

See also: [`remove_supplemental_attribute!`](@ref), [`begin_supplemental_attributes_update`](@ref)
"""
function add_supplemental_attribute!(
    sys::System,
    component::Union{HydroPumpTurbine, HydroTurbine},
    attribute::HydroPowerPlant,
    penstock_number::Int,
)
    uuid = IS.get_uuid(component)
    if haskey(attribute.reverse_penstock_map, uuid)
        throw(
            IS.ArgumentError(
                "Generator $(get_name(component)) is already part of plant $(get_name(attribute))",
            ),
        )
    end
    IS.add_supplemental_attribute!(sys.data, component, attribute)
    if haskey(attribute.penstock_map, penstock_number)
        push!(attribute.penstock_map[penstock_number], uuid)
    else
        attribute.penstock_map[penstock_number] = [uuid]
    end
    attribute.reverse_penstock_map[uuid] = penstock_number
    return
end

# Error guard: HydroDispatch is not supported in a HydroPowerPlant.
# Included to produce a clear error instead of silently succeeding via the generic overload.
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
    add_supplemental_attribute!(sys::System, component::Union{RenewableGen, EnergyReservoirStorage}, attribute::RenewablePowerPlant, pcc_number::Int)

Add a renewable generator or storage to a [`RenewablePowerPlant`](@ref) by associating it with a PCC number.
This attaches the plant as a supplemental attribute to the generator and records the
generator's UUID in the plant's PCC map.

!!! note
    `pcc_number` is a positional argument, unlike the keyword `shaft_number` in the
    [`ThermalPowerPlant`](@ref) overload. This inconsistency is a known API issue.

# Arguments
- `sys::System`: The system containing the generator.
- `component::Union{RenewableGen, EnergyReservoirStorage}`: The renewable generator or storage to add to the plant.
- `attribute::RenewablePowerPlant`: The renewable power plant.
- `pcc_number::Int`: The PCC (point of common coupling) number to associate with the generator.

# Throws
- `ArgumentError`: if the component is already associated with this plant.

See also: [`remove_supplemental_attribute!`](@ref), [`begin_supplemental_attributes_update`](@ref)
"""
function add_supplemental_attribute!(
    sys::System,
    component::Union{RenewableGen, EnergyReservoirStorage},
    attribute::RenewablePowerPlant,
    pcc_number::Int,
)
    uuid = IS.get_uuid(component)
    if haskey(attribute.reverse_pcc_map, uuid)
        throw(
            IS.ArgumentError(
                "Component $(get_name(component)) is already part of plant $(get_name(attribute))",
            ),
        )
    end
    IS.add_supplemental_attribute!(sys.data, component, attribute)
    if haskey(attribute.pcc_map, pcc_number)
        push!(attribute.pcc_map[pcc_number], uuid)
    else
        attribute.pcc_map[pcc_number] = [uuid]
    end
    attribute.reverse_pcc_map[uuid] = pcc_number
    return
end

"""
    remove_supplemental_attribute!(sys::System, component::ThermalGen, attribute::ThermalPowerPlant)

Remove a thermal generator from a [`ThermalPowerPlant`](@ref).

# Arguments
- `sys::System`: The system containing the generator.
- `component::ThermalGen`: The thermal generator to remove from the plant.
- `attribute::ThermalPowerPlant`: The thermal power plant.

# Throws
- `ArgumentError`: if the generator is not associated with this plant.

See also: [`add_supplemental_attribute!`](@ref), [`begin_supplemental_attributes_update`](@ref)
"""
function remove_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::ThermalPowerPlant,
)
    uuid = IS.get_uuid(component)
    if !haskey(attribute.reverse_shaft_map, uuid)
        throw(
            IS.ArgumentError(
                "Generator $(get_name(component)) is not part of plant $(get_name(attribute))",
            ),
        )
    end
    shaft_number = attribute.reverse_shaft_map[uuid]
    filter!(x -> x != uuid, attribute.shaft_map[shaft_number])
    if isempty(attribute.shaft_map[shaft_number])
        delete!(attribute.shaft_map, shaft_number)
    end
    delete!(attribute.reverse_shaft_map, uuid)
    IS.remove_supplemental_attribute!(sys.data, component, attribute)
    return
end

"""
    remove_supplemental_attribute!(sys::System, component::Union{HydroPumpTurbine, HydroTurbine}, attribute::HydroPowerPlant)

Remove a hydro generator from a [`HydroPowerPlant`](@ref).

# Arguments
- `sys::System`: The system containing the generator.
- `component::Union{HydroPumpTurbine, HydroTurbine}`: The hydro generator to remove from the plant.
- `attribute::HydroPowerPlant`: The hydro power plant.

# Throws
- `ArgumentError`: if the generator is not associated with this plant.

See also: [`add_supplemental_attribute!`](@ref), [`begin_supplemental_attributes_update`](@ref)
"""
function remove_supplemental_attribute!(
    sys::System,
    component::Union{HydroPumpTurbine, HydroTurbine},
    attribute::HydroPowerPlant,
)
    uuid = IS.get_uuid(component)
    if !haskey(attribute.reverse_penstock_map, uuid)
        throw(
            IS.ArgumentError(
                "Generator $(get_name(component)) is not part of plant $(get_name(attribute))",
            ),
        )
    end
    penstock_number = attribute.reverse_penstock_map[uuid]
    filter!(x -> x != uuid, attribute.penstock_map[penstock_number])
    if isempty(attribute.penstock_map[penstock_number])
        delete!(attribute.penstock_map, penstock_number)
    end
    delete!(attribute.reverse_penstock_map, uuid)
    IS.remove_supplemental_attribute!(sys.data, component, attribute)
    return
end

"""
    remove_supplemental_attribute!(sys::System, component::Union{RenewableGen, EnergyReservoirStorage}, attribute::RenewablePowerPlant)

Remove a renewable generator or storage device from a [`RenewablePowerPlant`](@ref).

# Arguments
- `sys::System`: The system containing the component.
- `component::Union{RenewableGen, EnergyReservoirStorage}`: The renewable generator or storage device to remove from the plant.
- `attribute::RenewablePowerPlant`: The renewable power plant.

# Throws
- `ArgumentError`: if the component is not associated with this plant.

See also: [`add_supplemental_attribute!`](@ref), [`begin_supplemental_attributes_update`](@ref)
"""
function remove_supplemental_attribute!(
    sys::System,
    component::Union{RenewableGen, EnergyReservoirStorage},
    attribute::RenewablePowerPlant,
)
    uuid = IS.get_uuid(component)
    if !haskey(attribute.reverse_pcc_map, uuid)
        throw(
            IS.ArgumentError(
                "Generator $(get_name(component)) is not part of plant $(get_name(attribute))",
            ),
        )
    end
    pcc_number = attribute.reverse_pcc_map[uuid]
    filter!(x -> x != uuid, attribute.pcc_map[pcc_number])
    if isempty(attribute.pcc_map[pcc_number])
        delete!(attribute.pcc_map, pcc_number)
    end
    delete!(attribute.reverse_pcc_map, uuid)
    IS.remove_supplemental_attribute!(sys.data, component, attribute)
    return
end

"""
    add_supplemental_attribute!(sys::System, component::ThermalGen, attribute::CombinedCycleBlock; hrsg_number::Int)

Add a thermal generator to a [`CombinedCycleBlock`](@ref) by associating it with an HRSG number.
Only generators with `CT` (combustion turbine as HRSG input) or `CA` (combined cycle steam part
as HRSG output) prime mover types can be added.

# Arguments
- `sys::System`: The system containing the generator.
- `component::ThermalGen`: The thermal generator to add to the block.
- `attribute::CombinedCycleBlock`: The combined cycle block.
- `hrsg_number::Int`: The HRSG number to associate with the generator.

# Throws
- `ArgumentError`: if the generator is already associated with this block.
- `ArgumentError`: if the generator's prime mover type is not `CT` or `CA`.

See also: [`remove_supplemental_attribute!`](@ref), [`begin_supplemental_attributes_update`](@ref)
"""
function add_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::CombinedCycleBlock;
    hrsg_number::Int,
)
    uuid = IS.get_uuid(component)
    if haskey(attribute.ct_hrsg_map, uuid) || haskey(attribute.ca_hrsg_map, uuid)
        throw(
            IS.ArgumentError(
                "Generator $(get_name(component)) is already part of block $(get_name(attribute))",
            ),
        )
    end
    prime_mover = get_prime_mover_type(component)
    if prime_mover == PrimeMovers.CT
        IS.add_supplemental_attribute!(sys.data, component, attribute)
        if haskey(attribute.hrsg_ct_map, hrsg_number)
            push!(attribute.hrsg_ct_map[hrsg_number], uuid)
        else
            attribute.hrsg_ct_map[hrsg_number] = [uuid]
        end
        attribute.ct_hrsg_map[uuid] = [hrsg_number]
    elseif prime_mover == PrimeMovers.CA
        IS.add_supplemental_attribute!(sys.data, component, attribute)
        if haskey(attribute.hrsg_ca_map, hrsg_number)
            push!(attribute.hrsg_ca_map[hrsg_number], uuid)
        else
            attribute.hrsg_ca_map[hrsg_number] = [uuid]
        end
        attribute.ca_hrsg_map[uuid] = [hrsg_number]
    else
        throw(
            IS.ArgumentError(
                "Invalid prime mover type $prime_mover for generator $(get_name(component)). Only CT and CA generators can be added to a CombinedCycleBlock.",
            ),
        )
    end
    return
end

"""
    remove_supplemental_attribute!(sys::System, component::ThermalGen, attribute::CombinedCycleBlock)

Remove a thermal generator from a [`CombinedCycleBlock`](@ref). The generator is removed
from whichever HRSG map corresponds to its prime mover type (`CT` or `CA`).

# Arguments
- `sys::System`: The system containing the generator.
- `component::ThermalGen`: The thermal generator to remove from the block.
- `attribute::CombinedCycleBlock`: The combined cycle block.

# Throws
- `ArgumentError`: if the generator is not associated with this block.

See also: [`add_supplemental_attribute!`](@ref), [`begin_supplemental_attributes_update`](@ref)
"""
function remove_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::CombinedCycleBlock,
)
    uuid = IS.get_uuid(component)
    # Check if this is a CT (HRSG input)
    if haskey(attribute.ct_hrsg_map, uuid)
        hrsg_numbers = attribute.ct_hrsg_map[uuid]
        for hrsg_number in hrsg_numbers
            filter!(x -> x != uuid, attribute.hrsg_ct_map[hrsg_number])
            if isempty(attribute.hrsg_ct_map[hrsg_number])
                delete!(attribute.hrsg_ct_map, hrsg_number)
            end
        end
        delete!(attribute.ct_hrsg_map, uuid)
        # Check if this is a CA (HRSG output)
    elseif haskey(attribute.ca_hrsg_map, uuid)
        hrsg_numbers = attribute.ca_hrsg_map[uuid]
        for hrsg_number in hrsg_numbers
            filter!(x -> x != uuid, attribute.hrsg_ca_map[hrsg_number])
            if isempty(attribute.hrsg_ca_map[hrsg_number])
                delete!(attribute.hrsg_ca_map, hrsg_number)
            end
        end
        delete!(attribute.ca_hrsg_map, uuid)
    else
        throw(
            IS.ArgumentError(
                "Generator $(get_name(component)) is not part of block $(get_name(attribute))",
            ),
        )
    end
    IS.remove_supplemental_attribute!(sys.data, component, attribute)
    return
end

"""
    add_supplemental_attribute!(sys::System, component::ThermalGen, attribute::CombinedCycleFractional; exclusion_group::Int)

Add a thermal generator to a [`CombinedCycleFractional`](@ref) by associating it with an
exclusion group number. Only generators with `CC` (combined cycle) prime mover type can be added.

# Arguments
- `sys::System`: The system containing the generator.
- `component::ThermalGen`: The thermal generator to add to the plant.
- `attribute::CombinedCycleFractional`: The combined cycle fractional plant.
- `exclusion_group::Int`: The exclusion group number to associate with the generator.

# Throws
- `ArgumentError`: if the generator is already associated with this plant.
- `ArgumentError`: if the generator's prime mover type is not `CC`.

See also: [`remove_supplemental_attribute!`](@ref), [`begin_supplemental_attributes_update`](@ref)
"""
function add_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::CombinedCycleFractional;
    exclusion_group::Int,
)
    uuid = IS.get_uuid(component)
    # Check if already in any exclusion group
    for (_, uuids) in attribute.operation_exclusion_map
        if uuid in uuids
            throw(
                IS.ArgumentError(
                    "Generator $(get_name(component)) is already part of plant $(get_name(attribute))",
                ),
            )
        end
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
    if haskey(attribute.operation_exclusion_map, exclusion_group)
        push!(attribute.operation_exclusion_map[exclusion_group], uuid)
    else
        attribute.operation_exclusion_map[exclusion_group] = [uuid]
    end
    attribute.inverse_operation_exclusion_map[uuid] = exclusion_group
    return
end

"""
    remove_supplemental_attribute!(sys::System, component::ThermalGen, attribute::CombinedCycleFractional)

Remove a thermal generator from a [`CombinedCycleFractional`](@ref).

# Arguments
- `sys::System`: The system containing the generator.
- `component::ThermalGen`: The thermal generator to remove from the plant.
- `attribute::CombinedCycleFractional`: The combined cycle fractional plant.

# Throws
- `ArgumentError`: if the generator is not associated with this plant.

See also: [`add_supplemental_attribute!`](@ref), [`begin_supplemental_attributes_update`](@ref)
"""
function remove_supplemental_attribute!(
    sys::System,
    component::ThermalGen,
    attribute::CombinedCycleFractional,
)
    uuid = IS.get_uuid(component)
    found = false
    for (group, _) in attribute.operation_exclusion_map
        if uuid in attribute.operation_exclusion_map[group]
            filter!(x -> x != uuid, attribute.operation_exclusion_map[group])
            if isempty(attribute.operation_exclusion_map[group])
                delete!(attribute.operation_exclusion_map, group)
            end
            found = true
            break
        end
    end
    if !found
        throw(
            IS.ArgumentError(
                "Generator $(get_name(component)) is not part of plant $(get_name(attribute))",
            ),
        )
    end
    delete!(attribute.inverse_operation_exclusion_map, uuid)
    IS.remove_supplemental_attribute!(sys.data, component, attribute)
    return
end

"""
    get_components_in_exclusion_group(sys::System, plant::CombinedCycleFractional, exclusion_group::Int)

Return all thermal generators in exclusion group `exclusion_group` of a
[`CombinedCycleFractional`](@ref). Only one generator per exclusion group may operate
simultaneously.

# Arguments
- `sys::System`: The system containing the components.
- `plant::CombinedCycleFractional`: The combined cycle fractional plant.
- `exclusion_group::Int`: The exclusion group number to query.

# Throws
- `ArgumentError`: if `exclusion_group` does not exist in the plant.

See also: [`add_supplemental_attribute!`](@ref), [`get_operation_exclusion_map`](@ref)
"""
function get_components_in_exclusion_group(
    sys::System,
    plant::CombinedCycleFractional,
    exclusion_group::Int,
)
    exclusion_map = get_operation_exclusion_map(plant)
    if !haskey(exclusion_map, exclusion_group)
        throw(
            IS.ArgumentError(
                "Exclusion group $exclusion_group does not exist in plant $(get_name(plant))",
            ),
        )
    end

    uuids = exclusion_map[exclusion_group]
    all_components = get_associated_components(sys, plant; component_type = ThermalGen)
    # Filter to only include components in this exclusion group
    return filter(c -> IS.get_uuid(c) in uuids, all_components)
end
