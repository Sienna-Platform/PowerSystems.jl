#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct InterruptibleStandardLoad <: ControllableLoad
        name::String
        available::Bool
        bus::ACBus
        base_power::Float64
        operation_cost::OperationalCost
        conformity::LoadConformity
        constant_active_power::Float64
        constant_reactive_power::Float64
        impedance_active_power::Float64
        impedance_reactive_power::Float64
        current_active_power::Float64
        current_reactive_power::Float64
        max_constant_active_power::Float64
        max_constant_reactive_power::Float64
        max_impedance_active_power::Float64
        max_impedance_reactive_power::Float64
        max_current_active_power::Float64
        max_current_reactive_power::Float64
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A voltage-dependent [ZIP load](@ref Z), most commonly used for dynamics modeling.

A `StandardLoad` breaks the ZIP into three pieces: Z (constant impedance), I (constant current), and P (constant power), according to `P = P_P * V^0 + P_I * V^1 + P_Z * V^2` for active power and `Q = Q_P * V^0 + Q_I * V^1 + Q_Z * V^2` for reactive power. (Voltage V is in per unit.)

For an alternative exponential formulation of the ZIP model, see [`ExponentialLoad`](@ref). For a simpler load model with no voltage dependency, see [`PowerLoad`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `base_power::Float64`: Base power of the load (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `operation_cost::OperationalCost`: [`OperationalCost`](@ref) of interrupting load
- `conformity::LoadConformity`: (default: `LoadConformity.UNDEFINED`) Indicates whether the specified load is conforming or non-conforming. Options are [listed here](@ref loadconform_list).
- `constant_active_power::Float64`: (default: `0.0`) Constant active power demand in MW (P_P)
- `constant_reactive_power::Float64`: (default: `0.0`) Constant reactive power demand in MVAR (Q_P)
- `impedance_active_power::Float64`: (default: `0.0`) Active power coefficient in MW for constant impedance load (P_Z)
- `impedance_reactive_power::Float64`: (default: `0.0`) Reactive power coefficient in MVAR for constant impedance load (Q_Z)
- `current_active_power::Float64`: (default: `0.0`) Active power coefficient in MW for constant current load (P_I)
- `current_reactive_power::Float64`: (default: `0.0`) Reactive power coefficient in MVAR for constant current load (Q_I)
- `max_constant_active_power::Float64`: (default: `0.0`) Maximum active power (MW) drawn by constant power load
- `max_constant_reactive_power::Float64`: (default: `0.0`) Maximum reactive power (MVAR) drawn by constant power load
- `max_impedance_active_power::Float64`: (default: `0.0`) Maximum active power (MW) drawn by constant impedance load
- `max_impedance_reactive_power::Float64`: (default: `0.0`) Maximum reactive power (MVAR) drawn by constant impedance load
- `max_current_active_power::Float64`: (default: `0.0`) Maximum active power (MW) drawn by constant current load
- `max_current_reactive_power::Float64`: (default: `0.0`) Maximum reactive power (MVAR) drawn by constant current load
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct InterruptibleStandardLoad <: ControllableLoad
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Base power of the load (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "[`OperationalCost`](@ref) of interrupting load"
    operation_cost::OperationalCost
    "Indicates whether the specified load is conforming or non-conforming. Options are [listed here](@ref loadconform_list)."
    conformity::LoadConformity
    "Constant active power demand in MW (P_P)"
    constant_active_power::Float64
    "Constant reactive power demand in MVAR (Q_P)"
    constant_reactive_power::Float64
    "Active power coefficient in MW for constant impedance load (P_Z)"
    impedance_active_power::Float64
    "Reactive power coefficient in MVAR for constant impedance load (Q_Z)"
    impedance_reactive_power::Float64
    "Active power coefficient in MW for constant current load (P_I)"
    current_active_power::Float64
    "Reactive power coefficient in MVAR for constant current load (Q_I)"
    current_reactive_power::Float64
    "Maximum active power (MW) drawn by constant power load"
    max_constant_active_power::Float64
    "Maximum reactive power (MVAR) drawn by constant power load"
    max_constant_reactive_power::Float64
    "Maximum active power (MW) drawn by constant impedance load"
    max_impedance_active_power::Float64
    "Maximum reactive power (MVAR) drawn by constant impedance load"
    max_impedance_reactive_power::Float64
    "Maximum active power (MW) drawn by constant current load"
    max_current_active_power::Float64
    "Maximum reactive power (MVAR) drawn by constant current load"
    max_current_reactive_power::Float64
    "Services that this device contributes to"
    services::Vector{Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function InterruptibleStandardLoad(name, available, bus, base_power, operation_cost, conformity=LoadConformity.UNDEFINED, constant_active_power=0.0, constant_reactive_power=0.0, impedance_active_power=0.0, impedance_reactive_power=0.0, current_active_power=0.0, current_reactive_power=0.0, max_constant_active_power=0.0, max_constant_reactive_power=0.0, max_impedance_active_power=0.0, max_impedance_reactive_power=0.0, max_current_active_power=0.0, max_current_reactive_power=0.0, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    InterruptibleStandardLoad(name, available, bus, base_power, operation_cost, conformity, constant_active_power, constant_reactive_power, impedance_active_power, impedance_reactive_power, current_active_power, current_reactive_power, max_constant_active_power, max_constant_reactive_power, max_impedance_active_power, max_impedance_reactive_power, max_current_active_power, max_current_reactive_power, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function InterruptibleStandardLoad(; name, available, bus, base_power, operation_cost, conformity=LoadConformity.UNDEFINED, constant_active_power=0.0, constant_reactive_power=0.0, impedance_active_power=0.0, impedance_reactive_power=0.0, current_active_power=0.0, current_reactive_power=0.0, max_constant_active_power=0.0, max_constant_reactive_power=0.0, max_impedance_active_power=0.0, max_impedance_reactive_power=0.0, max_current_active_power=0.0, max_current_reactive_power=0.0, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    InterruptibleStandardLoad(name, available, bus, base_power, operation_cost, conformity, constant_active_power, constant_reactive_power, impedance_active_power, impedance_reactive_power, current_active_power, current_reactive_power, max_constant_active_power, max_constant_reactive_power, max_impedance_active_power, max_impedance_reactive_power, max_current_active_power, max_current_reactive_power, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function InterruptibleStandardLoad(::Nothing)
    InterruptibleStandardLoad(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        base_power=100.0,
        operation_cost=LoadCost(nothing),
        conformity=LoadConformity.UNDEFINED,
        constant_active_power=0.0,
        constant_reactive_power=0.0,
        impedance_active_power=0.0,
        impedance_reactive_power=0.0,
        current_active_power=0.0,
        current_reactive_power=0.0,
        max_constant_active_power=0.0,
        max_constant_reactive_power=0.0,
        max_impedance_active_power=0.0,
        max_impedance_reactive_power=0.0,
        max_current_active_power=0.0,
        max_current_reactive_power=0.0,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`InterruptibleStandardLoad`](@ref) `name`."""
get_name(value::InterruptibleStandardLoad) = value.name
"""Get [`InterruptibleStandardLoad`](@ref) `available`."""
get_available(value::InterruptibleStandardLoad) = value.available
"""Get [`InterruptibleStandardLoad`](@ref) `bus`."""
get_bus(value::InterruptibleStandardLoad) = value.bus
"""Get [`InterruptibleStandardLoad`](@ref) `base_power`."""
get_base_power(value::InterruptibleStandardLoad) = value.base_power
"""Get [`InterruptibleStandardLoad`](@ref) `operation_cost`."""
get_operation_cost(value::InterruptibleStandardLoad) = value.operation_cost
"""Get [`InterruptibleStandardLoad`](@ref) `conformity`."""
get_conformity(value::InterruptibleStandardLoad) = value.conformity
"""Get [`InterruptibleStandardLoad`](@ref) `constant_active_power`."""
get_constant_active_power(value::InterruptibleStandardLoad) = get_value(value, Val(:constant_active_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `constant_reactive_power`."""
get_constant_reactive_power(value::InterruptibleStandardLoad) = get_value(value, Val(:constant_reactive_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `impedance_active_power`."""
get_impedance_active_power(value::InterruptibleStandardLoad) = get_value(value, Val(:impedance_active_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `impedance_reactive_power`."""
get_impedance_reactive_power(value::InterruptibleStandardLoad) = get_value(value, Val(:impedance_reactive_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `current_active_power`."""
get_current_active_power(value::InterruptibleStandardLoad) = get_value(value, Val(:current_active_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `current_reactive_power`."""
get_current_reactive_power(value::InterruptibleStandardLoad) = get_value(value, Val(:current_reactive_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `max_constant_active_power`."""
get_max_constant_active_power(value::InterruptibleStandardLoad) = get_value(value, Val(:max_constant_active_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `max_constant_reactive_power`."""
get_max_constant_reactive_power(value::InterruptibleStandardLoad) = get_value(value, Val(:max_constant_reactive_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `max_impedance_active_power`."""
get_max_impedance_active_power(value::InterruptibleStandardLoad) = get_value(value, Val(:max_impedance_active_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `max_impedance_reactive_power`."""
get_max_impedance_reactive_power(value::InterruptibleStandardLoad) = get_value(value, Val(:max_impedance_reactive_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `max_current_active_power`."""
get_max_current_active_power(value::InterruptibleStandardLoad) = get_value(value, Val(:max_current_active_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `max_current_reactive_power`."""
get_max_current_reactive_power(value::InterruptibleStandardLoad) = get_value(value, Val(:max_current_reactive_power), Val(:mva))
"""Get [`InterruptibleStandardLoad`](@ref) `services`."""
get_services(value::InterruptibleStandardLoad) = value.services
"""Get [`InterruptibleStandardLoad`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::InterruptibleStandardLoad) = value.dynamic_injector
"""Get [`InterruptibleStandardLoad`](@ref) `ext`."""
get_ext(value::InterruptibleStandardLoad) = value.ext
"""Get [`InterruptibleStandardLoad`](@ref) `internal`."""
get_internal(value::InterruptibleStandardLoad) = value.internal

"""Set [`InterruptibleStandardLoad`](@ref) `available`."""
set_available!(value::InterruptibleStandardLoad, val) = value.available = val
"""Set [`InterruptibleStandardLoad`](@ref) `bus`."""
set_bus!(value::InterruptibleStandardLoad, val) = value.bus = val
"""Set [`InterruptibleStandardLoad`](@ref) `base_power`."""
set_base_power!(value::InterruptibleStandardLoad, val) = value.base_power = val
"""Set [`InterruptibleStandardLoad`](@ref) `operation_cost`."""
set_operation_cost!(value::InterruptibleStandardLoad, val) = value.operation_cost = val
"""Set [`InterruptibleStandardLoad`](@ref) `conformity`."""
set_conformity!(value::InterruptibleStandardLoad, val) = value.conformity = val
"""Set [`InterruptibleStandardLoad`](@ref) `constant_active_power`."""
set_constant_active_power!(value::InterruptibleStandardLoad, val) = value.constant_active_power = set_value(value, Val(:constant_active_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `constant_reactive_power`."""
set_constant_reactive_power!(value::InterruptibleStandardLoad, val) = value.constant_reactive_power = set_value(value, Val(:constant_reactive_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `impedance_active_power`."""
set_impedance_active_power!(value::InterruptibleStandardLoad, val) = value.impedance_active_power = set_value(value, Val(:impedance_active_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `impedance_reactive_power`."""
set_impedance_reactive_power!(value::InterruptibleStandardLoad, val) = value.impedance_reactive_power = set_value(value, Val(:impedance_reactive_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `current_active_power`."""
set_current_active_power!(value::InterruptibleStandardLoad, val) = value.current_active_power = set_value(value, Val(:current_active_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `current_reactive_power`."""
set_current_reactive_power!(value::InterruptibleStandardLoad, val) = value.current_reactive_power = set_value(value, Val(:current_reactive_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `max_constant_active_power`."""
set_max_constant_active_power!(value::InterruptibleStandardLoad, val) = value.max_constant_active_power = set_value(value, Val(:max_constant_active_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `max_constant_reactive_power`."""
set_max_constant_reactive_power!(value::InterruptibleStandardLoad, val) = value.max_constant_reactive_power = set_value(value, Val(:max_constant_reactive_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `max_impedance_active_power`."""
set_max_impedance_active_power!(value::InterruptibleStandardLoad, val) = value.max_impedance_active_power = set_value(value, Val(:max_impedance_active_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `max_impedance_reactive_power`."""
set_max_impedance_reactive_power!(value::InterruptibleStandardLoad, val) = value.max_impedance_reactive_power = set_value(value, Val(:max_impedance_reactive_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `max_current_active_power`."""
set_max_current_active_power!(value::InterruptibleStandardLoad, val) = value.max_current_active_power = set_value(value, Val(:max_current_active_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `max_current_reactive_power`."""
set_max_current_reactive_power!(value::InterruptibleStandardLoad, val) = value.max_current_reactive_power = set_value(value, Val(:max_current_reactive_power), val, Val(:mva))
"""Set [`InterruptibleStandardLoad`](@ref) `services`."""
set_services!(value::InterruptibleStandardLoad, val) = value.services = val
"""Set [`InterruptibleStandardLoad`](@ref) `ext`."""
set_ext!(value::InterruptibleStandardLoad, val) = value.ext = val
