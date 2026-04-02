abstract type PowerPlant <: SupplementalAttribute end

"""Get `internal`."""
get_internal(x::PowerPlant) = x.internal

"""
Attribute to represent [`ThermalGen`](@ref) power plants with synchronous generation.
For Combined Cycle plants consider using [`CombinedCycleBlock`](@ref).

The shaft map field is used to represent shared shafts between units.

# Arguments
- `name::String`: Name of the power plant
- `shaft_map::Dict{Int, Vector{Base.UUID}}`: Mapping of shaft numbers to unit UUIDs (multiple units can share a shaft)
- `reverse_shaft_map::Dict{Base.UUID, Int}`: Reverse mapping from unit UUID to shaft number
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
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
- `name::String`: Name of the power plant
- `shaft_map::Dict{Int, Vector{Base.UUID}}`: (default: empty dict) Mapping of shaft numbers to unit UUIDs
- `reverse_shaft_map::Dict{Base.UUID, Int}`: (default: empty dict) Reverse mapping from unit UUID to shaft number
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
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
"""Get [`ThermalPowerPlant`](@ref) `shaft_map`."""
get_shaft_map(value::ThermalPowerPlant) = value.shaft_map
"""Get [`ThermalPowerPlant`](@ref) `reverse_shaft_map`."""
get_reverse_shaft_map(value::ThermalPowerPlant) = value.reverse_shaft_map

"""
Attribute to represent combined cycle generation by block configuration that shares heat recovery converstions.
For aggregate representations consider using [`CombinedCycleFractional`](@ref).

# Arguments
- `name::String`: Name of the combined cycle block
- `configuration::CombinedCycleConfiguration`: Configuration type of the combined cycle
- `heat_recovery_to_steam_factor::Float64`: Factor for heat recovery to steam conversion
- `hrsg_ct_map::Dict{Int, Vector{Base.UUID}}`: Mapping of HRSG numbers to CT unit UUIDs (CTs as HRSG inputs)
- `hrsg_ca_map::Dict{Int, Vector{Base.UUID}}`: Mapping of HRSG numbers to CA unit UUIDs (CAs as HRSG outputs)
- `ct_hrsg_map::Dict{Base.UUID, Vector{Int}}`: Reverse mapping from CT unit UUID to HRSG numbers (a CT can feed multiple HRSGs)
- `ca_hrsg_map::Dict{Base.UUID, Vector{Int}}`: Reverse mapping from CA unit UUID to HRSG numbers (a CA can receive from multiple HRSGs)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
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
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
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
"""Get [`CombinedCycleBlock`](@ref) `hrsg_ct_map`."""
get_hrsg_ct_map(value::CombinedCycleBlock) = value.hrsg_ct_map
"""Get [`CombinedCycleBlock`](@ref) `hrsg_ca_map`."""
get_hrsg_ca_map(value::CombinedCycleBlock) = value.hrsg_ca_map
"""Get [`CombinedCycleBlock`](@ref) `ct_hrsg_map`."""
get_ct_hrsg_map(value::CombinedCycleBlock) = value.ct_hrsg_map
"""Get [`CombinedCycleBlock`](@ref) `ca_hrsg_map`."""
get_ca_hrsg_map(value::CombinedCycleBlock) = value.ca_hrsg_map

"""
Attribute to represent combined cycle generation when each unit represents a specific configuration and aggregate heat rate.
For block-level representations consider using [`CombinedCycleBlock`](@ref).

# Arguments
- `name::String`: Name of the combined cycle fractional plant
- `configuration::CombinedCycleConfiguration`: Configuration type of the combined cycle
- `operation_exclusion_map::Dict{Int, Vector{Base.UUID}}`: Mapping of operation exclusion group numbers to unit UUIDs (only units in the same group can operate simultaneously)
- `inverse_operation_exclusion_map::Dict{Base.UUID, Int}`: Reverse mapping from unit UUID to exclusion group number
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
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
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
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
"""Get [`CombinedCycleFractional`](@ref) `operation_exclusion_map`."""
get_operation_exclusion_map(value::CombinedCycleFractional) =
    value.operation_exclusion_map
"""Get [`CombinedCycleFractional`](@ref) `inverse_operation_exclusion_map`."""
get_inverse_operation_exclusion_map(value::CombinedCycleFractional) =
    value.inverse_operation_exclusion_map

"""
Attribute to represent hydro power plants with shared penstocks.

# Arguments
- `name::String`: Name of the hydro power plant
- `penstock_map::Dict{Int, Vector{Base.UUID}}`: Mapping of penstock numbers to unit UUIDs (multiple units can share a penstock)
- `reverse_penstock_map::Dict{Base.UUID, Int}`: Reverse mapping from unit UUID to penstock number
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
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
- `name::String`: Name of the hydro power plant
- `penstock_map::Dict{Int, Vector{Base.UUID}}`: (default: empty dict) Mapping of penstock numbers to unit UUIDs
- `reverse_penstock_map::Dict{Base.UUID, Int}`: (default: empty dict) Reverse mapping from unit UUID to penstock number
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
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
"""Get [`HydroPowerPlant`](@ref) `penstock_map`."""
get_penstock_map(value::HydroPowerPlant) = value.penstock_map
"""Get [`HydroPowerPlant`](@ref) `reverse_penstock_map`."""
get_reverse_penstock_map(value::HydroPowerPlant) = value.reverse_penstock_map

"""
Attribute to represent renewable power plants.

# Arguments
- `name::String`: Name of the renewable power plant
- `pcc_map::Dict{Int, Vector{Base.UUID}}`: Mapping of PCC numbers to unit UUIDs (multiple units can share a PCC)
- `reverse_pcc_map::Dict{Base.UUID, Int}`: Reverse mapping from unit UUID to PCC number
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
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

Construct a [`RenewablePowerPlant`](@ref). This supports multiple point of common coupling (PCC) connections.

# Arguments
- `name::String`: Name of the renewable power plant
- `pcc_map::Dict{Int, Vector{Base.UUID}}`: (default: empty dict) Mapping of PCC numbers to unit UUIDs
- `reverse_pcc_map::Dict{Base.UUID, Int}`: (default: empty dict) Reverse mapping from unit UUID to PCC number
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
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
"""Get [`RenewablePowerPlant`](@ref) `pcc_map`."""
get_pcc_map(value::RenewablePowerPlant) = value.pcc_map
"""Get [`RenewablePowerPlant`](@ref) `reverse_pcc_map`."""
get_reverse_pcc_map(value::RenewablePowerPlant) = value.reverse_pcc_map

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
- `sys::System`: The system containing the generator
- `component::ThermalGen`: The thermal generator to add to the plant
- `attribute::ThermalPowerPlant`: The thermal power plant
- `shaft_number::Int`: The shaft number to associate with the generator
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
    add_supplemental_attribute!(sys::System, component::Union{HydroPumpTurbine, HydroTurbine}, attribute::HydroPowerPlant; penstock_number::Int)

Add a hydro generator to a [`HydroPowerPlant`](@ref) by associating it with a penstock number.
This attaches the plant as a supplemental attribute to the generator and records the
generator's UUID in the plant's penstock map.

# Arguments
- `sys::System`: The system containing the generator
- `component::Union{HydroPumpTurbine, HydroTurbine}`: The hydro generator to add to the plant
- `attribute::HydroPowerPlant`: The hydro power plant
- `penstock_number::Int`: The penstock number to associate with the generator
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
generator's UUID in the plant's PCC map.

# Arguments
- `sys::System`: The system containing the generator
- `component::Union{RenewableGen, EnergyReservoirStorage}`: The renewable generator or storage to add to the plant
- `attribute::RenewablePowerPlant`: The renewable power plant
- `pcc_number::Int`: (default: 1) The PCC (point of common coupling) number to associate with the generator
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
This removes the plant as a supplemental attribute from the generator and removes the
generator's UUID from the plant's shaft map.

# Arguments
- `sys::System`: The system containing the generator
- `component::ThermalGen`: The thermal generator to remove from the plant
- `attribute::ThermalPowerPlant`: The thermal power plant
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
This removes the plant as a supplemental attribute from the generator and removes the
generator's UUID from the plant's penstock map.

# Arguments
- `sys::System`: The system containing the generator
- `component::Union{HydroPumpTurbine, HydroTurbine}`: The hydro generator to remove from the plant
- `attribute::HydroPowerPlant`: The hydro power plant
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

Remove a renewable generator or storage from a [`RenewablePowerPlant`](@ref).
This removes the plant as a supplemental attribute from the generator and removes the
generator's UUID from the plant's PCC map.

# Arguments
- `sys::System`: The system containing the generator
- `component::Union{RenewableGen, EnergyReservoirStorage}`: The renewable generator or storage to remove from the plant
- `attribute::RenewablePowerPlant`: The renewable power plant
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

Remove a thermal generator from a [`CombinedCycleBlock`](@ref).
This removes the block as a supplemental attribute from the generator and removes the
generator's UUID from the block's HRSG maps.

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
This removes the plant as a supplemental attribute from the generator and removes the
generator's UUID from the plant's exclusion maps.

# Arguments
- `sys::System`: The system containing the generator
- `component::ThermalGen`: The thermal generator to remove from the plant
- `attribute::CombinedCycleFractional`: The combined cycle fractional plant
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
