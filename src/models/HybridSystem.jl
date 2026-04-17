"""
    mutable struct HybridSystem <: StaticInjectionSubsystem
        name::String
        available::Bool
        status::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        base_power::Float64
        operation_cost::MarketBidCost
        thermal_unit::Union{Nothing, ThermalGen}
        electric_load::Union{Nothing, ElectricLoad}
        storage::Union{Nothing, Storage}
        renewable_unit::Union{Nothing, RenewableGen}
        interconnection_impedance::ComplexF64
        interconnection_rating::Union{Nothing, Float64}
        input_active_power_limits::Union{Nothing, MinMax}
        output_active_power_limits::Union{Nothing, MinMax}
        reactive_power_limits::Union{Nothing, MinMax}
        interconnection_efficiency::Union{
            Nothing,
            NamedTuple{(:in, :out), Tuple{Float64, Float64}},
        }
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A Hybrid System that includes a combination of renewable generation, load, thermal
generation and/or energy storage.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `status::Bool`: Initial commitment condition at the start of a simulation (`true` = on or `false` = off)
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `reactive_power::Float64`: Initial reactive power set point of the unit (MVAR)
- `base_power::Float64`: Base power of the unit (MVA) for per unitization, which is commonly the same as `rating`
- `operation_cost::MarketBidCost`: Market bid cost to operate, [`MarketBidCost`](@ref)
- `thermal_unit::Union{Nothing, ThermalGen}`: A thermal generator with supertype [`ThermalGen`](@ref)
- `electric_load::Union{Nothing, ElectricLoad}`: A load with supertype [`ElectricLoad`](@ref)
- `storage::Union{Nothing, Storage}`: An energy storage system with supertype [`Storage`](@ref)
- `renewable_unit::Union{Nothing, RenewableGen}`: A renewable generator with supertype [`RenewableGen`](@ref)
- `interconnection_impedance::ComplexF64`: Impedance (typically in p.u.) between the hybrid system and the grid interconnection
- `interconnection_rating::Union{Nothing, Float64}`: Maximum rating of the hybrid system's interconnection with the transmission network (MVA)
- `input_active_power_limits::MinMax`: Minimum and maximum stable input active power levels (MW)
- `output_active_power_limits::MinMax`: Minimum and maximum stable output active power levels (MW)
- `reactive_power_limits::Union{Nothing, MinMax}`: Minimum and maximum reactive power limits (MVAR). Set to `Nothing` if not applicable.
- `interconnection_efficiency::Union{Nothing, NamedTuple{(:in, :out), Tuple{Float64, Float64}},}`: Efficiency [0, 1.0] at the grid interconnection to model losses `in` and `out` of the common DC-side conversion
- `services::Vector{Service}`: (optional) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (optional) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (optional) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference.
"""
mutable struct HybridSystem <: StaticInjectionSubsystem
    name::String
    available::Bool
    status::Bool
    bus::ACBus
    active_power::Float64
    reactive_power::Float64
    base_power::Float64
    operation_cost::MarketBidCost
    thermal_unit::Union{Nothing, ThermalGen}
    electric_load::Union{Nothing, ElectricLoad}
    storage::Union{Nothing, Storage}
    renewable_unit::Union{Nothing, RenewableGen}
    # interconnection Data
    "Thermal limited MVA Power Output of the unit. <= Capacity"
    interconnection_impedance::ComplexF64
    interconnection_rating::Union{Nothing, Float64}
    input_active_power_limits::Union{Nothing, MinMax}
    output_active_power_limits::Union{Nothing, MinMax}
    reactive_power_limits::Union{Nothing, MinMax}
    interconnection_efficiency::Union{
        Nothing,
        NamedTuple{(:in, :out), Tuple{Float64, Float64}},
    }
    "corresponding dynamic injection device"
    services::Vector{Service}
    dynamic_injector::Union{Nothing, DynamicInjection}
    ext::Dict{String, Any}
    "internal forecast storage"
    "power system internal reference, do not modify"
    internal::InfrastructureSystemsInternal
end

function HybridSystem(;
    name = "init",
    available = false,
    status = false,
    bus = ACBus(nothing),
    active_power = 0.0,
    reactive_power = 0.0,
    base_power = 100.0,
    operation_cost = MarketBidCost(nothing),
    thermal_unit = nothing,
    electric_load = nothing,
    storage = nothing,
    renewable_unit = nothing,
    interconnection_impedance = 0.0,
    interconnection_rating = nothing,
    input_active_power_limits = nothing,
    output_active_power_limits = nothing,
    reactive_power_limits = nothing,
    interconnection_efficiency = nothing,
    services = Service[],
    dynamic_injector = nothing,
    ext = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
)
    return HybridSystem(
        name,
        available,
        status,
        bus,
        active_power,
        reactive_power,
        base_power,
        operation_cost,
        thermal_unit,
        electric_load,
        storage,
        renewable_unit,
        interconnection_impedance,
        interconnection_rating,
        input_active_power_limits,
        output_active_power_limits,
        reactive_power_limits,
        interconnection_efficiency,
        services,
        dynamic_injector,
        ext,
        internal,
    )
end

# Constructor for demo purposes; non-functional.
function HybridSystem(::Nothing)
    return HybridSystem(;
        name = "init",
        available = false,
        status = false,
        bus = ACBus(nothing),
        active_power = 0.0,
        reactive_power = 0.0,
        base_power = 100.0,
        operation_cost = MarketBidCost(nothing),
        thermal_unit = ThermalStandard(nothing),
        electric_load = PowerLoad(nothing),
        storage = EnergyReservoirStorage(nothing),
        renewable_unit = RenewableDispatch(nothing),
        interconnection_impedance = 0.0,
        interconnection_rating = nothing,
        input_active_power_limits = nothing,
        output_active_power_limits = nothing,
        reactive_power_limits = nothing,
        interconnection_efficiency = nothing,
        services = Service[],
        dynamic_injector = nothing,
        ext = Dict{String, Any}(),
        internal = InfrastructureSystemsInternal(),
    )
end

get_name(value::HybridSystem) = value.name

function _get_components(value::HybridSystem)
    components =
        [value.thermal_unit, value.electric_load, value.storage, value.renewable_unit]
    filter!(x -> !isnothing(x), components)
    return components
end

function set_units_setting!(value::HybridSystem, settings::SystemUnitsSettings)
    set_units_info!(get_internal(value), settings)
    for component in _get_components(value)
        set_units_info!(get_internal(component), settings)
    end
    return
end

"""Get [`HybridSystem`](@ref) `available`."""
get_available(value::HybridSystem) = value.available
"""Get [`HybridSystem`](@ref) `status`."""
get_status(value::HybridSystem) = value.status
"""Get [`HybridSystem`](@ref) `bus`."""
get_bus(value::HybridSystem) = value.bus
"""Get [`HybridSystem`](@ref) `active_power`."""
get_active_power(value::HybridSystem, units) =
    get_value(value, Val(:active_power), Val(:mva), units)
"""Get [`HybridSystem`](@ref) `reactive_power`."""
get_reactive_power(value::HybridSystem, units) =
    get_value(value, Val(:reactive_power), Val(:mva), units)
"""Get [`HybridSystem`](@ref) thermal unit"""
get_thermal_unit(value::HybridSystem) = value.thermal_unit
"""Get [`HybridSystem`](@ref) load"""
get_electric_load(value::HybridSystem) = value.electric_load
"""Get [`HybridSystem`](@ref) storage unit"""
get_storage(value::HybridSystem) = value.storage
"""Get [`HybridSystem`](@ref) renewable unit"""
get_renewable_unit(value::HybridSystem) = value.renewable_unit
"""Get [`HybridSystem`](@ref) `interconnection_rating`."""
get_interconnection_rating(value::HybridSystem, units) =
    get_value(value, Val(:interconnection_rating), Val(:mva), units)
"""get [`HybridSystem`](@ref) interconnection impedance"""
get_interconnection_impedance(value::HybridSystem) = value.interconnection_impedance
"""Get [`HybridSystem`](@ref) `input_active_power_limits`."""
get_input_active_power_limits(value::HybridSystem, units) =
    get_value(value, Val(:input_active_power_limits), Val(:mva), units)
"""Get [`HybridSystem`](@ref) `output_active_power_limits`."""
get_output_active_power_limits(value::HybridSystem, units) =
    get_value(value, Val(:output_active_power_limits), Val(:mva), units)
"""Get [`HybridSystem`](@ref) `reactive_power_limits`."""
get_reactive_power_limits(value::HybridSystem, units) =
    get_value(value, Val(:reactive_power_limits), Val(:mva), units)
"""get [`HybridSystem`](@ref) interconnection efficiency"""
get_interconnection_efficiency(value::HybridSystem) = value.interconnection_efficiency
"""Get [`HybridSystem`](@ref) `base_power`."""
get_base_power(value::HybridSystem) = value.base_power
"""Get [`HybridSystem`](@ref) `operation_cost`."""
get_operation_cost(value::HybridSystem) = value.operation_cost
"""Get [`HybridSystem`](@ref) `services`."""
get_services(value::HybridSystem) = value.services
"""Get [`HybridSystem`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::HybridSystem) = value.dynamic_injector
"""Get [`HybridSystem`](@ref) `ext`."""
get_ext(value::HybridSystem) = value.ext

"""Get [`HybridSystem`](@ref) `internal`."""
get_internal(value::HybridSystem) = value.internal

"""Set [`HybridSystem`](@ref) `available`."""
set_available!(value::HybridSystem, val) = value.available = val
"""Get [`HybridSystem`](@ref) `status`."""
set_status!(value::HybridSystem, val) = value.status = val
"""Set [`HybridSystem`](@ref) `bus`."""
set_bus!(value::HybridSystem, val) = value.bus = val
"""Set [`HybridSystem`](@ref) `interconnection_rating`."""
set_interconnection_rating!(value::HybridSystem, val) = value.interconnection_rating = val
"""Set [`HybridSystem`](@ref) `active_power`."""
set_active_power!(value::HybridSystem, val) = value.active_power = val
"""Set [`HybridSystem`](@ref) `reactive_power`."""
set_reactive_power!(value::HybridSystem, val) = value.reactive_power = val
"""set [`HybridSystem`](@ref) interconnection impedance"""
set_interconnection_impedance!(value::HybridSystem, val) =
    value.interconnection_impedance = val
"""Set [`HybridSystem`](@ref) `input_active_power_limits`."""
set_input_active_power_limits!(value::HybridSystem, val) =
    value.input_active_power_limits = val
"""Set [`HybridSystem`](@ref) `output_active_power_limits`."""
set_output_active_power_limits!(value::HybridSystem, val) =
    value.output_active_power_limits = val
"""Set [`HybridSystem`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::HybridSystem, val) = value.reactive_power_limits = val
"""Set [`HybridSystem`](@ref) `interconnection_efficiency`."""
set_interconnection_efficiency!(value::HybridSystem, val) =
    value.interconnection_rating = val
"""Set [`HybridSystem`](@ref) `base_power`."""
set_base_power!(value::HybridSystem, val) = value.base_power = val
"""Set [`HybridSystem`](@ref) `operation_cost`."""
set_operation_cost!(value::HybridSystem, val) = value.operation_cost = val
"""Set [`HybridSystem`](@ref) `services`."""
set_services!(value::HybridSystem, val) = value.services = val
"""Set [`HybridSystem`](@ref) `ext`."""
set_ext!(value::HybridSystem, val) = value.ext = val

"""
Return an iterator over the subcomponents in the HybridSystem.

# Examples
```julia
for subcomponent in get_subcomponents(hybrid_sys)
    @show subcomponent
end
subcomponents = collect(get_subcomponents(hybrid_sys))
```
"""
function get_subcomponents(hybrid::HybridSystem)
    Channel() do channel
        for field in (:thermal_unit, :electric_load, :storage, :renewable_unit)
            subcomponent = getfield(hybrid, field)
            if subcomponent !== nothing
                put!(channel, subcomponent)
            end
        end
    end
end

"""Set [`HybridSystem`](@ref) thermal unit"""
function set_thermal_unit!(hybrid::HybridSystem, val::ThermalGen)
    _raise_if_attached_to_system(hybrid)
    hybrid.thermal_unit = val
    return
end

"""Set [`HybridSystem`](@ref) load"""
function set_electric_load!(hybrid::HybridSystem, val::ElectricLoad)
    _raise_if_attached_to_system(hybrid)
    value.electric_load = val
    return
end

"""Set [`HybridSystem`](@ref) storage unit"""
function set_storage!(hybrid::HybridSystem, val::Storage)
    _raise_if_attached_to_system(hybrid)
    value.storage = val
    return
end

"""Set [`HybridSystem`](@ref) renewable unit"""
function set_renewable_unit!(hybrid::HybridSystem, val::RenewableGen)
    _raise_if_attached_to_system(hybrid)
    value.renewable_unit = val
    return
end

function _raise_if_attached_to_system(hybrid::HybridSystem)
    if !isnothing(IS.get_time_series_manager(hybrid))
        throw(
            ArgumentError(
                "Operation not allowed because the HybridSystem is attached to a system",
            ),
        )
    end
    return
end
