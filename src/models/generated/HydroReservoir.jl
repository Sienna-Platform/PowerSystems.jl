#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct HydroReservoir <: Device
        name::String
        available::Bool
        storage_level_limits::MinMax
        initial_level::Float64
        spillage_limits::Union{Nothing, MinMax}
        inflow::Float64
        outflow::Float64
        level_targets::Union{Nothing, Float64}
        intake_elevation::Float64
        head_to_volume_factor::ValueCurve
        upstream_turbines::Vector{HydroUnit}
        downstream_turbines::Vector{HydroUnit}
        upstream_reservoirs::Vector{Device}
        operation_cost::OperationalCost
        level_data_type::ReservoirDataType
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A hydropower reservoir that have attached [`HydroTurbine`](@ref)(s) or [`HydroPumpTurbine`](@ref)(s) used to generate power.
See [How to Define Hydro Generators with Reservoirs](@ref hydro_resv) for supported configurations.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `storage_level_limits::MinMax`: Storage level limits for the reservoir in m^3, m, or MWh, based on the [`ReservoirDataType`](@ref  hydroreservoir_list) selected for `level_data_type`
- `initial_level::Float64`: Initial level of the reservoir relative to the `storage_level_limits.max`.
- `spillage_limits::Union{Nothing, MinMax}`: Amount of water allowed to be spilled from the reservoir. If nothing, infinite spillage is allowed.
- `inflow::Float64`: Amount of water refilling the reservoir in m^3/h or MW (if `level_data_type` is [`ReservoirDataType`](@ref hydroreservoir_list)`.ENERGY`).
- `outflow::Float64`: Amount of water naturally going out of the reservoir in m^3/h or MW (if `level_data_type` is [`ReservoirDataType`](@ref hydroreservoir_list)`.ENERGY`).
- `level_targets::Union{Nothing, Float64}`: Reservoir level targets at the end of a simulation as a fraction of the `storage_level_limits.max`.
- `intake_elevation::Float64`: Height of the intake of the reservoir, towards the downstream turbines, in meters above the sea level.
- `head_to_volume_factor::ValueCurve`: Head to volume relationship for the reservoir.
- `upstream_turbines::Vector{HydroUnit}`: (default: `Device[]`) Vector of [HydroUnit](@ref)(s) that are immediately upstream of this reservoir. This reservoir is the tail reservoir for these units, and their flow goes into this reservoir.
- `downstream_turbines::Vector{HydroUnit}`: (default: `Device[]`) Vector of [HydroUnit](@ref)(s) that are immediately downstream of this reservoir. This reservoir is the head reservoir for these units, and its feed flow into these units.
- `upstream_reservoirs::Vector{Device}`: (default: `Device[]`) Vector of [Device](@ref)(s) reservoirs that are immediately upstream of this reservoir. This reservoir receives the spillage flow from upstream_reservoirs.
- `operation_cost::OperationalCost`: (default: `HydroReservoirCost(nothing)`) [`OperationalCost`](@ref) of reservoir.
- `level_data_type::ReservoirDataType`: (default: `ReservoirDataType.USABLE_VOLUME`) Reservoir level data type. See [ReservoirDataType](@ref) for reference.
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct HydroReservoir <: Device
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Storage level limits for the reservoir in m^3, m, or MWh, based on the [`ReservoirDataType`](@ref  hydroreservoir_list) selected for `level_data_type`"
    storage_level_limits::MinMax
    "Initial level of the reservoir relative to the `storage_level_limits.max`."
    initial_level::Float64
    "Amount of water allowed to be spilled from the reservoir. If nothing, infinite spillage is allowed."
    spillage_limits::Union{Nothing, MinMax}
    "Amount of water refilling the reservoir in m^3/h or MW (if `level_data_type` is [`ReservoirDataType`](@ref hydroreservoir_list)`.ENERGY`)."
    inflow::Float64
    "Amount of water naturally going out of the reservoir in m^3/h or MW (if `level_data_type` is [`ReservoirDataType`](@ref hydroreservoir_list)`.ENERGY`)."
    outflow::Float64
    "Reservoir level targets at the end of a simulation as a fraction of the `storage_level_limits.max`."
    level_targets::Union{Nothing, Float64}
    "Height of the intake of the reservoir, towards the downstream turbines, in meters above the sea level."
    intake_elevation::Float64
    "Head to volume relationship for the reservoir."
    head_to_volume_factor::ValueCurve
    "Vector of [HydroUnit](@ref)(s) that are immediately upstream of this reservoir. This reservoir is the tail reservoir for these units, and their flow goes into this reservoir."
    upstream_turbines::Vector{HydroUnit}
    "Vector of [HydroUnit](@ref)(s) that are immediately downstream of this reservoir. This reservoir is the head reservoir for these units, and its feed flow into these units."
    downstream_turbines::Vector{HydroUnit}
    "Vector of [Device](@ref)(s) reservoirs that are immediately upstream of this reservoir. This reservoir receives the spillage flow from upstream_reservoirs."
    upstream_reservoirs::Vector{Device}
    "[`OperationalCost`](@ref) of reservoir."
    operation_cost::OperationalCost
    "Reservoir level data type. See [ReservoirDataType](@ref) for reference."
    level_data_type::ReservoirDataType
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function HydroReservoir(name, available, storage_level_limits, initial_level, spillage_limits, inflow, outflow, level_targets, intake_elevation, head_to_volume_factor, upstream_turbines=Device[], downstream_turbines=Device[], upstream_reservoirs=Device[], operation_cost=HydroReservoirCost(nothing), level_data_type=ReservoirDataType.USABLE_VOLUME, ext=Dict{String, Any}(), )
    HydroReservoir(name, available, storage_level_limits, initial_level, spillage_limits, inflow, outflow, level_targets, intake_elevation, head_to_volume_factor, upstream_turbines, downstream_turbines, upstream_reservoirs, operation_cost, level_data_type, ext, InfrastructureSystemsInternal(), )
end

function HydroReservoir(; name, available, storage_level_limits, initial_level, spillage_limits, inflow, outflow, level_targets, intake_elevation, head_to_volume_factor, upstream_turbines=Device[], downstream_turbines=Device[], upstream_reservoirs=Device[], operation_cost=HydroReservoirCost(nothing), level_data_type=ReservoirDataType.USABLE_VOLUME, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    HydroReservoir(name, available, storage_level_limits, initial_level, spillage_limits, inflow, outflow, level_targets, intake_elevation, head_to_volume_factor, upstream_turbines, downstream_turbines, upstream_reservoirs, operation_cost, level_data_type, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function HydroReservoir(::Nothing)
    HydroReservoir(;
        name="init",
        available=false,
        storage_level_limits=(min=0.0, max=0.0),
        initial_level=0.0,
        spillage_limits=nothing,
        inflow=0.0,
        outflow=0.0,
        level_targets=nothing,
        intake_elevation=0.0,
        head_to_volume_factor=LinearCurve(0.0),
        upstream_turbines=Device[],
        downstream_turbines=Device[],
        upstream_reservoirs=Device[],
        operation_cost=HydroReservoirCost(nothing),
        level_data_type=ReservoirDataType.USABLE_VOLUME,
        ext=Dict{String, Any}(),
    )
end

"""Get [`HydroReservoir`](@ref) `name`."""
get_name(value::HydroReservoir) = value.name
"""Get [`HydroReservoir`](@ref) `available`."""
get_available(value::HydroReservoir) = value.available
"""Get [`HydroReservoir`](@ref) `storage_level_limits`."""
get_storage_level_limits(value::HydroReservoir) = value.storage_level_limits
"""Get [`HydroReservoir`](@ref) `initial_level`."""
get_initial_level(value::HydroReservoir) = value.initial_level
"""Get [`HydroReservoir`](@ref) `spillage_limits`."""
get_spillage_limits(value::HydroReservoir) = value.spillage_limits
"""Get [`HydroReservoir`](@ref) `inflow`."""
get_inflow(value::HydroReservoir) = value.inflow
"""Get [`HydroReservoir`](@ref) `outflow`."""
get_outflow(value::HydroReservoir) = value.outflow
"""Get [`HydroReservoir`](@ref) `level_targets`."""
get_level_targets(value::HydroReservoir) = value.level_targets
"""Get [`HydroReservoir`](@ref) `intake_elevation`."""
get_intake_elevation(value::HydroReservoir) = value.intake_elevation
"""Get [`HydroReservoir`](@ref) `head_to_volume_factor`."""
get_head_to_volume_factor(value::HydroReservoir) = value.head_to_volume_factor
"""Get [`HydroReservoir`](@ref) `upstream_turbines`."""
get_upstream_turbines(value::HydroReservoir) = value.upstream_turbines
"""Get [`HydroReservoir`](@ref) `downstream_turbines`."""
get_downstream_turbines(value::HydroReservoir) = value.downstream_turbines
"""Get [`HydroReservoir`](@ref) `upstream_reservoirs`."""
get_upstream_reservoirs(value::HydroReservoir) = value.upstream_reservoirs
"""Get [`HydroReservoir`](@ref) `operation_cost`."""
get_operation_cost(value::HydroReservoir) = value.operation_cost
"""Get [`HydroReservoir`](@ref) `level_data_type`."""
get_level_data_type(value::HydroReservoir) = value.level_data_type
"""Get [`HydroReservoir`](@ref) `ext`."""
get_ext(value::HydroReservoir) = value.ext
"""Get [`HydroReservoir`](@ref) `internal`."""
get_internal(value::HydroReservoir) = value.internal

"""Set [`HydroReservoir`](@ref) `available`."""
set_available!(value::HydroReservoir, val) = value.available = val
"""Set [`HydroReservoir`](@ref) `storage_level_limits`."""
set_storage_level_limits!(value::HydroReservoir, val) = value.storage_level_limits = val
"""Set [`HydroReservoir`](@ref) `initial_level`."""
set_initial_level!(value::HydroReservoir, val) = value.initial_level = val
"""Set [`HydroReservoir`](@ref) `spillage_limits`."""
set_spillage_limits!(value::HydroReservoir, val) = value.spillage_limits = val
"""Set [`HydroReservoir`](@ref) `inflow`."""
set_inflow!(value::HydroReservoir, val) = value.inflow = val
"""Set [`HydroReservoir`](@ref) `outflow`."""
set_outflow!(value::HydroReservoir, val) = value.outflow = val
"""Set [`HydroReservoir`](@ref) `level_targets`."""
set_level_targets!(value::HydroReservoir, val) = value.level_targets = val
"""Set [`HydroReservoir`](@ref) `intake_elevation`."""
set_intake_elevation!(value::HydroReservoir, val) = value.intake_elevation = val
"""Set [`HydroReservoir`](@ref) `head_to_volume_factor`."""
set_head_to_volume_factor!(value::HydroReservoir, val) = value.head_to_volume_factor = val
"""Set [`HydroReservoir`](@ref) `upstream_turbines`."""
set_upstream_turbines!(value::HydroReservoir, val) = value.upstream_turbines = val
"""Set [`HydroReservoir`](@ref) `downstream_turbines`."""
set_downstream_turbines!(value::HydroReservoir, val) = value.downstream_turbines = val
"""Set [`HydroReservoir`](@ref) `upstream_reservoirs`."""
set_upstream_reservoirs!(value::HydroReservoir, val) = value.upstream_reservoirs = val
"""Set [`HydroReservoir`](@ref) `operation_cost`."""
set_operation_cost!(value::HydroReservoir, val) = value.operation_cost = val
"""Set [`HydroReservoir`](@ref) `level_data_type`."""
set_level_data_type!(value::HydroReservoir, val) = value.level_data_type = val
"""Set [`HydroReservoir`](@ref) `ext`."""
set_ext!(value::HydroReservoir, val) = value.ext = val
