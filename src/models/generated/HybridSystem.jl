#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct HybridSystem <: StaticInjectionSubsystem
        name::String
        available::Bool
        status::OperationalStates
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
        interconnection_efficiency::Union{Nothing, NamedTuple{(:in, :out), Tuple{Float64, Float64}}}
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A hybrid system that combines any of renewable generation, load, thermal generation and/or energy storage behind a single grid interconnection.

The subcomponents (`thermal_unit`, `electric_load`, `storage`, `renewable_unit`) are attached to the `System` as masked components and grouped behind the interconnection.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `status::OperationalStates`: Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: (default: `0.0`) Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `reactive_power::Float64`: (default: `0.0`) Initial reactive power set point of the unit (MVAR)
- `base_power::Float64`: (default: `100.0`) Base power of the unit (MVA) for [per unitization](@ref per_unit), which is commonly the same as `interconnection_rating`, validation range: `(0, nothing)`
- `operation_cost::MarketBidCost`: (default: `MarketBidCost(nothing)`) [`MarketBidCost`](@ref) of operating the hybrid system
- `thermal_unit::Union{Nothing, ThermalGen}`: (default: `nothing`) A thermal generator with supertype [`ThermalGen`](@ref), or `nothing`
- `electric_load::Union{Nothing, ElectricLoad}`: (default: `nothing`) A load with supertype [`ElectricLoad`](@ref), or `nothing`
- `storage::Union{Nothing, Storage}`: (default: `nothing`) An energy storage system with supertype [`Storage`](@ref), or `nothing`
- `renewable_unit::Union{Nothing, RenewableGen}`: (default: `nothing`) A renewable generator with supertype [`RenewableGen`](@ref), or `nothing`
- `interconnection_impedance::ComplexF64`: (default: `0.0`) Impedance (typically in p.u.) between the hybrid system and the grid interconnection
- `interconnection_rating::Union{Nothing, Float64}`: (default: `nothing`) Maximum rating of the hybrid system's interconnection with the transmission network (MVA). Set to `nothing` if not applicable
- `input_active_power_limits::Union{Nothing, MinMax}`: (default: `nothing`) Minimum and maximum stable input active power levels (MW). Set to `nothing` if not applicable
- `output_active_power_limits::Union{Nothing, MinMax}`: (default: `nothing`) Minimum and maximum stable output active power levels (MW). Set to `nothing` if not applicable
- `reactive_power_limits::Union{Nothing, MinMax}`: (default: `nothing`) Minimum and maximum reactive power limits (MVAR). Set to `nothing` if not applicable
- `interconnection_efficiency::Union{Nothing, NamedTuple{(:in, :out), Tuple{Float64, Float64}}}`: (default: `nothing`) Efficiency [0, 1.0] at the grid interconnection to model losses `in` and `out` of the common DC-side conversion. Set to `nothing` if not applicable
- `services::Vector{Service}`: (default: `Service[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct HybridSystem <: StaticInjectionSubsystem
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Operating state of the unit at the start of a simulation. Options are listed [here](@ref opstate_list)"
    status::OperationalStates
    "Bus that this component is connected to"
    bus::ACBus
    "Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used"
    active_power::Float64
    "Initial reactive power set point of the unit (MVAR)"
    reactive_power::Float64
    "Base power of the unit (MVA) for [per unitization](@ref per_unit), which is commonly the same as `interconnection_rating`"
    base_power::Float64
    "[`MarketBidCost`](@ref) of operating the hybrid system"
    operation_cost::MarketBidCost
    "A thermal generator with supertype [`ThermalGen`](@ref), or `nothing`"
    thermal_unit::Union{Nothing, ThermalGen}
    "A load with supertype [`ElectricLoad`](@ref), or `nothing`"
    electric_load::Union{Nothing, ElectricLoad}
    "An energy storage system with supertype [`Storage`](@ref), or `nothing`"
    storage::Union{Nothing, Storage}
    "A renewable generator with supertype [`RenewableGen`](@ref), or `nothing`"
    renewable_unit::Union{Nothing, RenewableGen}
    "Impedance (typically in p.u.) between the hybrid system and the grid interconnection"
    interconnection_impedance::ComplexF64
    "Maximum rating of the hybrid system's interconnection with the transmission network (MVA). Set to `nothing` if not applicable"
    interconnection_rating::Union{Nothing, Float64}
    "Minimum and maximum stable input active power levels (MW). Set to `nothing` if not applicable"
    input_active_power_limits::Union{Nothing, MinMax}
    "Minimum and maximum stable output active power levels (MW). Set to `nothing` if not applicable"
    output_active_power_limits::Union{Nothing, MinMax}
    "Minimum and maximum reactive power limits (MVAR). Set to `nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "Efficiency [0, 1.0] at the grid interconnection to model losses `in` and `out` of the common DC-side conversion. Set to `nothing` if not applicable"
    interconnection_efficiency::Union{Nothing, NamedTuple{(:in, :out), Tuple{Float64, Float64}}}
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function HybridSystem(name, available, status, bus, active_power=0.0, reactive_power=0.0, base_power=100.0, operation_cost=MarketBidCost(nothing), thermal_unit=nothing, electric_load=nothing, storage=nothing, renewable_unit=nothing, interconnection_impedance=0.0, interconnection_rating=nothing, input_active_power_limits=nothing, output_active_power_limits=nothing, reactive_power_limits=nothing, interconnection_efficiency=nothing, services=Service[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    HybridSystem(name, available, status, bus, active_power, reactive_power, base_power, operation_cost, thermal_unit, electric_load, storage, renewable_unit, interconnection_impedance, interconnection_rating, input_active_power_limits, output_active_power_limits, reactive_power_limits, interconnection_efficiency, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function HybridSystem(; name, available, status, bus, active_power=0.0, reactive_power=0.0, base_power=100.0, operation_cost=MarketBidCost(nothing), thermal_unit=nothing, electric_load=nothing, storage=nothing, renewable_unit=nothing, interconnection_impedance=0.0, interconnection_rating=nothing, input_active_power_limits=nothing, output_active_power_limits=nothing, reactive_power_limits=nothing, interconnection_efficiency=nothing, services=Service[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    HybridSystem(name, available, status, bus, active_power, reactive_power, base_power, operation_cost, thermal_unit, electric_load, storage, renewable_unit, interconnection_impedance, interconnection_rating, input_active_power_limits, output_active_power_limits, reactive_power_limits, interconnection_efficiency, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function HybridSystem(::Nothing)
    HybridSystem(;
        name="init",
        available=false,
        status=OperationalStates.OFFLINE,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        base_power=100.0,
        operation_cost=MarketBidCost(nothing),
        thermal_unit=ThermalStandard(nothing),
        electric_load=PowerLoad(nothing),
        storage=EnergyReservoirStorage(nothing),
        renewable_unit=RenewableDispatch(nothing),
        interconnection_impedance=0.0,
        interconnection_rating=nothing,
        input_active_power_limits=nothing,
        output_active_power_limits=nothing,
        reactive_power_limits=nothing,
        interconnection_efficiency=nothing,
        services=Service[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`HybridSystem`](@ref) `name`."""
get_name(value::HybridSystem) = value.name
"""Get [`HybridSystem`](@ref) `available`."""
get_available(value::HybridSystem) = value.available
"""Get [`HybridSystem`](@ref) `status`."""
get_status(value::HybridSystem) = value.status
"""Get [`HybridSystem`](@ref) `bus`."""
get_bus(value::HybridSystem) = value.bus
"""Get [`HybridSystem`](@ref) `active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_unitful`](@ref)."""
get_active_power(value::HybridSystem, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power), Val(:mw), units))
"""Get [`HybridSystem`](@ref) `active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power`](@ref)."""
get_active_power_unitful(value::HybridSystem, units) = get_value(value, Val(:active_power), Val(:mw), units)
get_active_power(value::HybridSystem) = _units_arg_required(get_active_power, value, :active_power, Val(:mw))
get_active_power_unitful(value::HybridSystem) = _units_arg_required(get_active_power_unitful, value, :active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power), ::Type{HybridSystem}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_unitful), ::Type{HybridSystem}) = InfrastructureSystems.SU
"""Get [`HybridSystem`](@ref) `reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_unitful`](@ref)."""
get_reactive_power(value::HybridSystem, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power), Val(:mvar), units))
"""Get [`HybridSystem`](@ref) `reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power`](@ref)."""
get_reactive_power_unitful(value::HybridSystem, units) = get_value(value, Val(:reactive_power), Val(:mvar), units)
get_reactive_power(value::HybridSystem) = _units_arg_required(get_reactive_power, value, :reactive_power, Val(:mvar))
get_reactive_power_unitful(value::HybridSystem) = _units_arg_required(get_reactive_power_unitful, value, :reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power), ::Type{HybridSystem}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_unitful), ::Type{HybridSystem}) = InfrastructureSystems.SU

_get_base_power(value::HybridSystem) = value.base_power
"""Get [`HybridSystem`](@ref) `operation_cost`."""
get_operation_cost(value::HybridSystem) = value.operation_cost
"""Get [`HybridSystem`](@ref) `thermal_unit`."""
get_thermal_unit(value::HybridSystem) = value.thermal_unit
"""Get [`HybridSystem`](@ref) `electric_load`."""
get_electric_load(value::HybridSystem) = value.electric_load
"""Get [`HybridSystem`](@ref) `storage`."""
get_storage(value::HybridSystem) = value.storage
"""Get [`HybridSystem`](@ref) `renewable_unit`."""
get_renewable_unit(value::HybridSystem) = value.renewable_unit
"""Get [`HybridSystem`](@ref) `interconnection_impedance`."""
get_interconnection_impedance(value::HybridSystem) = value.interconnection_impedance
"""Get [`HybridSystem`](@ref) `interconnection_rating` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_interconnection_rating_unitful`](@ref)."""
get_interconnection_rating(value::HybridSystem, units) = InfrastructureSystems._strip_units(get_value(value, Val(:interconnection_rating), Val(:mva), units))
"""Get [`HybridSystem`](@ref) `interconnection_rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_interconnection_rating`](@ref)."""
get_interconnection_rating_unitful(value::HybridSystem, units) = get_value(value, Val(:interconnection_rating), Val(:mva), units)
get_interconnection_rating(value::HybridSystem) = _units_arg_required(get_interconnection_rating, value, :interconnection_rating, Val(:mva))
get_interconnection_rating_unitful(value::HybridSystem) = _units_arg_required(get_interconnection_rating_unitful, value, :interconnection_rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_interconnection_rating), ::Type{HybridSystem}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_interconnection_rating_unitful), ::Type{HybridSystem}) = InfrastructureSystems.SU
"""Get [`HybridSystem`](@ref) `input_active_power_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_input_active_power_limits_unitful`](@ref)."""
get_input_active_power_limits(value::HybridSystem, units) = InfrastructureSystems._strip_units(get_value(value, Val(:input_active_power_limits), Val(:mw), units))
"""Get [`HybridSystem`](@ref) `input_active_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_input_active_power_limits`](@ref)."""
get_input_active_power_limits_unitful(value::HybridSystem, units) = get_value(value, Val(:input_active_power_limits), Val(:mw), units)
get_input_active_power_limits(value::HybridSystem) = _units_arg_required(get_input_active_power_limits, value, :input_active_power_limits, Val(:mw))
get_input_active_power_limits_unitful(value::HybridSystem) = _units_arg_required(get_input_active_power_limits_unitful, value, :input_active_power_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_input_active_power_limits), ::Type{HybridSystem}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_input_active_power_limits_unitful), ::Type{HybridSystem}) = InfrastructureSystems.SU
"""Get [`HybridSystem`](@ref) `output_active_power_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_output_active_power_limits_unitful`](@ref)."""
get_output_active_power_limits(value::HybridSystem, units) = InfrastructureSystems._strip_units(get_value(value, Val(:output_active_power_limits), Val(:mw), units))
"""Get [`HybridSystem`](@ref) `output_active_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_output_active_power_limits`](@ref)."""
get_output_active_power_limits_unitful(value::HybridSystem, units) = get_value(value, Val(:output_active_power_limits), Val(:mw), units)
get_output_active_power_limits(value::HybridSystem) = _units_arg_required(get_output_active_power_limits, value, :output_active_power_limits, Val(:mw))
get_output_active_power_limits_unitful(value::HybridSystem) = _units_arg_required(get_output_active_power_limits_unitful, value, :output_active_power_limits, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_output_active_power_limits), ::Type{HybridSystem}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_output_active_power_limits_unitful), ::Type{HybridSystem}) = InfrastructureSystems.SU
"""Get [`HybridSystem`](@ref) `reactive_power_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_unitful`](@ref)."""
get_reactive_power_limits(value::HybridSystem, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits), Val(:mvar), units))
"""Get [`HybridSystem`](@ref) `reactive_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_limits`](@ref)."""
get_reactive_power_limits_unitful(value::HybridSystem, units) = get_value(value, Val(:reactive_power_limits), Val(:mvar), units)
get_reactive_power_limits(value::HybridSystem) = _units_arg_required(get_reactive_power_limits, value, :reactive_power_limits, Val(:mvar))
get_reactive_power_limits_unitful(value::HybridSystem) = _units_arg_required(get_reactive_power_limits_unitful, value, :reactive_power_limits, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits), ::Type{HybridSystem}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_unitful), ::Type{HybridSystem}) = InfrastructureSystems.SU
"""Get [`HybridSystem`](@ref) `interconnection_efficiency`."""
get_interconnection_efficiency(value::HybridSystem) = value.interconnection_efficiency
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
"""Set [`HybridSystem`](@ref) `status`."""
set_status!(value::HybridSystem, val) = value.status = val
"""Set [`HybridSystem`](@ref) `bus`."""
set_bus!(value::HybridSystem, val) = value.bus = val
"""Set [`HybridSystem`](@ref) `active_power`."""
set_active_power!(value::HybridSystem, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mw))
set_active_power!(value::HybridSystem, val::_UntaggedNumber) = _units_tag_required(set_active_power!, value, :active_power, Val(:mw), val)
"""Set [`HybridSystem`](@ref) `reactive_power`."""
set_reactive_power!(value::HybridSystem, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mvar))
set_reactive_power!(value::HybridSystem, val::_UntaggedNumber) = _units_tag_required(set_reactive_power!, value, :reactive_power, Val(:mvar), val)
"""Set [`HybridSystem`](@ref) `operation_cost`."""
set_operation_cost!(value::HybridSystem, val) = value.operation_cost = val
"""Set [`HybridSystem`](@ref) `interconnection_impedance`."""
set_interconnection_impedance!(value::HybridSystem, val) = value.interconnection_impedance = val
"""Set [`HybridSystem`](@ref) `interconnection_rating`."""
set_interconnection_rating!(value::HybridSystem, val) = value.interconnection_rating = set_value(value, Val(:interconnection_rating), val, Val(:mva))
set_interconnection_rating!(value::HybridSystem, val::_UntaggedNumber) = _units_tag_required(set_interconnection_rating!, value, :interconnection_rating, Val(:mva), val)
"""Set [`HybridSystem`](@ref) `input_active_power_limits`."""
set_input_active_power_limits!(value::HybridSystem, val) = value.input_active_power_limits = set_value(value, Val(:input_active_power_limits), val, Val(:mw))
set_input_active_power_limits!(value::HybridSystem, val::_UntaggedNumber) = _units_tag_required(set_input_active_power_limits!, value, :input_active_power_limits, Val(:mw), val)
set_input_active_power_limits!(value::HybridSystem, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_input_active_power_limits!, value, :input_active_power_limits, Val(:mw), val)
"""Set [`HybridSystem`](@ref) `output_active_power_limits`."""
set_output_active_power_limits!(value::HybridSystem, val) = value.output_active_power_limits = set_value(value, Val(:output_active_power_limits), val, Val(:mw))
set_output_active_power_limits!(value::HybridSystem, val::_UntaggedNumber) = _units_tag_required(set_output_active_power_limits!, value, :output_active_power_limits, Val(:mw), val)
set_output_active_power_limits!(value::HybridSystem, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_output_active_power_limits!, value, :output_active_power_limits, Val(:mw), val)
"""Set [`HybridSystem`](@ref) `reactive_power_limits`."""
set_reactive_power_limits!(value::HybridSystem, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mvar))
set_reactive_power_limits!(value::HybridSystem, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
set_reactive_power_limits!(value::HybridSystem, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits!, value, :reactive_power_limits, Val(:mvar), val)
"""Set [`HybridSystem`](@ref) `interconnection_efficiency`."""
set_interconnection_efficiency!(value::HybridSystem, val) = value.interconnection_efficiency = val
"""Set [`HybridSystem`](@ref) `services`."""
set_services!(value::HybridSystem, val) = value.services = val
"""Set [`HybridSystem`](@ref) `ext`."""
set_ext!(value::HybridSystem, val) = value.ext = val
