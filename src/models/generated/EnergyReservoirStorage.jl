#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct EnergyReservoirStorage <: Storage
        name::String
        available::Bool
        bus::ACBus
        prime_mover_type::PrimeMovers
        storage_technology_type::StorageTech
        storage_capacity::Float64
        storage_level_limits::MinMax
        initial_storage_capacity_level::Float64
        rating::Float64
        active_power::Float64
        input_active_power_limits::MinMax
        output_active_power_limits::MinMax
        efficiency::NamedTuple{(:in, :out), Tuple{Float64, Float64}}
        reactive_power::Float64
        reactive_power_limits::Union{Nothing, MinMax}
        base_power::Float64
        operation_cost::OperationalCost
        conversion_factor::Float64
        storage_target::Float64
        cycle_limits::Int
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

An energy storage device, modeled as a generic energy reservoir.

This is suitable for modeling storage charging and discharging with average efficiency losses, ignoring the physical dynamics of the storage unit. A variety of energy storage types and chemistries can be modeled with this approach. For pumped hydro storage, alternatively see [`HydroPumpTurbine`](@ref) and [`HydroReservoir`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `prime_mover_type::PrimeMovers`: Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)
- `storage_technology_type::StorageTech`: Storage Technology Complementary to EIA 923. Options are listed [here](@ref storagetech_list)
- `storage_capacity::Float64`: Maximum storage capacity (can be in units of, e.g., MWh for batteries or liters for hydrogen). When in MWh, this value divided by base_power (MVA) gives an approximate duration in hours, assuming unity power factor. For understanding this relationship, see [per unitization](@ref per_unit), validation range: `(0, nothing)`
- `storage_level_limits::MinMax`: Minimum and maximum allowable storage levels [0, 1], which can be used to model derates or other restrictions, such as state-of-charge restrictions on battery cycling, validation range: `(0, 1)`
- `initial_storage_capacity_level::Float64`: Initial storage capacity level as a ratio [0, 1.0] of `storage_capacity`, validation range: `(0, 1)`
- `rating::Float64`: Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power
- `active_power::Float64`: Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `input_active_power_limits::MinMax`: Minimum and maximum limits on the input active power (i.e., charging), validation range: `(0, nothing)`
- `output_active_power_limits::MinMax`: Minimum and maximum limits on the output active power (i.e., discharging), validation range: `(0, nothing)`
- `efficiency::NamedTuple{(:in, :out), Tuple{Float64, Float64}}`: Average efficiency [0, 1] `in` (charging/filling) and `out` (discharging/consuming) of the storage system, validation range: `(0, 1)`
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR), validation range: `reactive_power_limits`
- `reactive_power_limits::Union{Nothing, MinMax}`: Minimum and maximum reactive power limits. Set to `Nothing` if not applicable
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `operation_cost::OperationalCost`: (default: `StorageCost(nothing)`) [`OperationalCost`](@ref) of storage
- `conversion_factor::Float64`: (default: `1.0`) Conversion factor of `storage_capacity` to MWh, if different than 1.0. For example, X MWh/liter hydrogen
- `storage_target::Float64`: (default: `0.0`) Storage target at the end of simulation as ratio of storage capacity
- `cycle_limits::Int`: (default: `1e4`) Storage Maximum number of cycles per year
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct EnergyReservoirStorage <: Storage
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Prime mover technology according to EIA 923. Options are listed [here](@ref pm_list)"
    prime_mover_type::PrimeMovers
    "Storage Technology Complementary to EIA 923. Options are listed [here](@ref storagetech_list)"
    storage_technology_type::StorageTech
    "Maximum storage capacity (can be in units of, e.g., MWh for batteries or liters for hydrogen). When in MWh, this value divided by base_power (MVA) gives an approximate duration in hours, assuming unity power factor. For understanding this relationship, see [per unitization](@ref per_unit)"
    storage_capacity::Float64
    "Minimum and maximum allowable storage levels [0, 1], which can be used to model derates or other restrictions, such as state-of-charge restrictions on battery cycling"
    storage_level_limits::MinMax
    "Initial storage capacity level as a ratio [0, 1.0] of `storage_capacity`"
    initial_storage_capacity_level::Float64
    "Maximum AC side output power rating of the unit. Stored in per unit of the device and not to be confused with base_power"
    rating::Float64
    "Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used"
    active_power::Float64
    "Minimum and maximum limits on the input active power (i.e., charging)"
    input_active_power_limits::MinMax
    "Minimum and maximum limits on the output active power (i.e., discharging)"
    output_active_power_limits::MinMax
    "Average efficiency [0, 1] `in` (charging/filling) and `out` (discharging/consuming) of the storage system"
    efficiency::NamedTuple{(:in, :out), Tuple{Float64, Float64}}
    "Initial reactive power set point of the unit (MVAR)"
    reactive_power::Float64
    "Minimum and maximum reactive power limits. Set to `Nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "[`OperationalCost`](@ref) of storage"
    operation_cost::OperationalCost
    "Conversion factor of `storage_capacity` to MWh, if different than 1.0. For example, X MWh/liter hydrogen"
    conversion_factor::Float64
    "Storage target at the end of simulation as ratio of storage capacity"
    storage_target::Float64
    "Storage Maximum number of cycles per year"
    cycle_limits::Int
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function EnergyReservoirStorage(name, available, bus, prime_mover_type, storage_technology_type, storage_capacity, storage_level_limits, initial_storage_capacity_level, rating, active_power, input_active_power_limits, output_active_power_limits, efficiency, reactive_power, reactive_power_limits, base_power, operation_cost=StorageCost(nothing), conversion_factor=1.0, storage_target=0.0, cycle_limits=1e4, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    EnergyReservoirStorage(name, available, bus, prime_mover_type, storage_technology_type, storage_capacity, storage_level_limits, initial_storage_capacity_level, rating, active_power, input_active_power_limits, output_active_power_limits, efficiency, reactive_power, reactive_power_limits, base_power, operation_cost, conversion_factor, storage_target, cycle_limits, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function EnergyReservoirStorage(; name, available, bus, prime_mover_type, storage_technology_type, storage_capacity, storage_level_limits, initial_storage_capacity_level, rating, active_power, input_active_power_limits, output_active_power_limits, efficiency, reactive_power, reactive_power_limits, base_power, operation_cost=StorageCost(nothing), conversion_factor=1.0, storage_target=0.0, cycle_limits=1e4, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    EnergyReservoirStorage(name, available, bus, prime_mover_type, storage_technology_type, storage_capacity, storage_level_limits, initial_storage_capacity_level, rating, active_power, input_active_power_limits, output_active_power_limits, efficiency, reactive_power, reactive_power_limits, base_power, operation_cost, conversion_factor, storage_target, cycle_limits, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function EnergyReservoirStorage(::Nothing)
    EnergyReservoirStorage(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        prime_mover_type=PrimeMovers.BA,
        storage_technology_type=StorageTech.OTHER_CHEM,
        storage_capacity=0.0,
        storage_level_limits=(min=0.0, max=0.0),
        initial_storage_capacity_level=0.0,
        rating=0.0,
        active_power=0.0,
        input_active_power_limits=(min=0.0, max=0.0),
        output_active_power_limits=(min=0.0, max=0.0),
        efficiency=(in=0.0, out=0.0),
        reactive_power=0.0,
        reactive_power_limits=(min=0.0, max=0.0),
        base_power=100.0,
        operation_cost=StorageCost(nothing),
        conversion_factor=0.0,
        storage_target=0.0,
        cycle_limits=0,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`EnergyReservoirStorage`](@ref) `name`."""
get_name(value::EnergyReservoirStorage) = value.name
"""Get [`EnergyReservoirStorage`](@ref) `available`."""
get_available(value::EnergyReservoirStorage) = value.available
"""Get [`EnergyReservoirStorage`](@ref) `bus`."""
get_bus(value::EnergyReservoirStorage) = value.bus
"""Get [`EnergyReservoirStorage`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::EnergyReservoirStorage) = value.prime_mover_type
"""Get [`EnergyReservoirStorage`](@ref) `storage_technology_type`."""
get_storage_technology_type(value::EnergyReservoirStorage) = value.storage_technology_type
"""Get [`EnergyReservoirStorage`](@ref) `storage_capacity`."""
get_storage_capacity(value::EnergyReservoirStorage) = get_value(value, Val(:storage_capacity), Val(:mva))
"""Get [`EnergyReservoirStorage`](@ref) `storage_level_limits`."""
get_storage_level_limits(value::EnergyReservoirStorage) = value.storage_level_limits
"""Get [`EnergyReservoirStorage`](@ref) `initial_storage_capacity_level`."""
get_initial_storage_capacity_level(value::EnergyReservoirStorage) = value.initial_storage_capacity_level
"""Get [`EnergyReservoirStorage`](@ref) `rating`."""
get_rating(value::EnergyReservoirStorage) = get_value(value, Val(:rating), Val(:mva))
"""Get [`EnergyReservoirStorage`](@ref) `active_power`."""
get_active_power(value::EnergyReservoirStorage) = get_value(value, Val(:active_power), Val(:mva))
"""Get [`EnergyReservoirStorage`](@ref) `input_active_power_limits`."""
get_input_active_power_limits(value::EnergyReservoirStorage) = get_value(value, Val(:input_active_power_limits), Val(:mva))
"""Get [`EnergyReservoirStorage`](@ref) `output_active_power_limits`."""
get_output_active_power_limits(value::EnergyReservoirStorage) = get_value(value, Val(:output_active_power_limits), Val(:mva))
"""Get [`EnergyReservoirStorage`](@ref) `efficiency`."""
get_efficiency(value::EnergyReservoirStorage) = value.efficiency
"""Get [`EnergyReservoirStorage`](@ref) `reactive_power`."""
get_reactive_power(value::EnergyReservoirStorage) = get_value(value, Val(:reactive_power), Val(:mva))
"""Get [`EnergyReservoirStorage`](@ref) `reactive_power_limits`."""
get_reactive_power_limits(value::EnergyReservoirStorage) = get_value(value, Val(:reactive_power_limits), Val(:mva))
"""Get [`EnergyReservoirStorage`](@ref) `base_power`."""
get_base_power(value::EnergyReservoirStorage) = value.base_power
"""Get [`EnergyReservoirStorage`](@ref) `operation_cost`."""
get_operation_cost(value::EnergyReservoirStorage) = value.operation_cost
"""Get [`EnergyReservoirStorage`](@ref) `conversion_factor`."""
get_conversion_factor(value::EnergyReservoirStorage) = value.conversion_factor
"""Get [`EnergyReservoirStorage`](@ref) `storage_target`."""
get_storage_target(value::EnergyReservoirStorage) = value.storage_target
"""Get [`EnergyReservoirStorage`](@ref) `cycle_limits`."""
get_cycle_limits(value::EnergyReservoirStorage) = value.cycle_limits
"""Get [`EnergyReservoirStorage`](@ref) `services`."""
get_services(value::EnergyReservoirStorage) = value.services
"""Get [`EnergyReservoirStorage`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::EnergyReservoirStorage) = value.dynamic_injector
"""Get [`EnergyReservoirStorage`](@ref) `ext`."""
get_ext(value::EnergyReservoirStorage) = value.ext
"""Get [`EnergyReservoirStorage`](@ref) `internal`."""
get_internal(value::EnergyReservoirStorage) = value.internal

"""Set [`EnergyReservoirStorage`](@ref) `available`."""
set_available!(value::EnergyReservoirStorage, val) = value.available = val
"""Set [`EnergyReservoirStorage`](@ref) `bus`."""
set_bus!(value::EnergyReservoirStorage, val) = value.bus = val
"""Set [`EnergyReservoirStorage`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::EnergyReservoirStorage, val) = value.prime_mover_type = val
"""Set [`EnergyReservoirStorage`](@ref) `storage_technology_type`."""
set_storage_technology_type!(value::EnergyReservoirStorage, val) = value.storage_technology_type = val
"""Set [`EnergyReservoirStorage`](@ref) `storage_capacity`."""
set_storage_capacity!(value::EnergyReservoirStorage, val) = value.storage_capacity = set_value(value, Val(:storage_capacity), val, Val(:mva))
"""Set [`EnergyReservoirStorage`](@ref) `storage_level_limits`."""
set_storage_level_limits!(value::EnergyReservoirStorage, val) = value.storage_level_limits = val
"""Set [`EnergyReservoirStorage`](@ref) `initial_storage_capacity_level`."""
set_initial_storage_capacity_level!(value::EnergyReservoirStorage, val) = value.initial_storage_capacity_level = val
"""Set [`EnergyReservoirStorage`](@ref) `rating`."""
set_rating!(value::EnergyReservoirStorage, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
"""Set [`EnergyReservoirStorage`](@ref) `active_power`."""
set_active_power!(value::EnergyReservoirStorage, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`EnergyReservoirStorage`](@ref) `input_active_power_limits`."""
set_input_active_power_limits!(value::EnergyReservoirStorage, val) = value.input_active_power_limits = set_value(value, Val(:input_active_power_limits), val, Val(:mva))
"""Set [`EnergyReservoirStorage`](@ref) `output_active_power_limits`."""
set_output_active_power_limits!(value::EnergyReservoirStorage, val) = value.output_active_power_limits = set_value(value, Val(:output_active_power_limits), val, Val(:mva))
"""Set [`EnergyReservoirStorage`](@ref) `efficiency`."""
set_efficiency!(value::EnergyReservoirStorage, val) = value.efficiency = val
"""Set [`EnergyReservoirStorage`](@ref) `reactive_power`."""
set_reactive_power!(value::EnergyReservoirStorage, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mva))
"""Set [`EnergyReservoirStorage`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::EnergyReservoirStorage, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mva))
"""Set [`EnergyReservoirStorage`](@ref) `base_power`."""
set_base_power!(value::EnergyReservoirStorage, val) = value.base_power = val
"""Set [`EnergyReservoirStorage`](@ref) `operation_cost`."""
set_operation_cost!(value::EnergyReservoirStorage, val) = value.operation_cost = val
"""Set [`EnergyReservoirStorage`](@ref) `conversion_factor`."""
set_conversion_factor!(value::EnergyReservoirStorage, val) = value.conversion_factor = val
"""Set [`EnergyReservoirStorage`](@ref) `storage_target`."""
set_storage_target!(value::EnergyReservoirStorage, val) = value.storage_target = val
"""Set [`EnergyReservoirStorage`](@ref) `cycle_limits`."""
set_cycle_limits!(value::EnergyReservoirStorage, val) = value.cycle_limits = val
"""Set [`EnergyReservoirStorage`](@ref) `services`."""
set_services!(value::EnergyReservoirStorage, val) = value.services = val
"""Set [`EnergyReservoirStorage`](@ref) `ext`."""
set_ext!(value::EnergyReservoirStorage, val) = value.ext = val
