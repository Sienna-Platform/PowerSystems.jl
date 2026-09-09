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

_get_base_power(value::InterruptibleStandardLoad) = value.base_power
"""Get [`InterruptibleStandardLoad`](@ref) `operation_cost`."""
get_operation_cost(value::InterruptibleStandardLoad) = value.operation_cost
"""Get [`InterruptibleStandardLoad`](@ref) `conformity`."""
get_conformity(value::InterruptibleStandardLoad) = value.conformity
"""Get [`InterruptibleStandardLoad`](@ref) `constant_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_constant_active_power_unitful`](@ref)."""
get_constant_active_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:constant_active_power), Val(:mw), units))
"""Get [`InterruptibleStandardLoad`](@ref) `constant_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_constant_active_power`](@ref)."""
get_constant_active_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:constant_active_power), Val(:mw), units)
get_constant_active_power(value::InterruptibleStandardLoad) = _units_arg_required(get_constant_active_power, value, :constant_active_power, Val(:mw))
get_constant_active_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_constant_active_power_unitful, value, :constant_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_constant_active_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_constant_active_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
"""Get [`InterruptibleStandardLoad`](@ref) `constant_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_constant_reactive_power_unitful`](@ref)."""
get_constant_reactive_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:constant_reactive_power), Val(:mvar), units))
"""Get [`InterruptibleStandardLoad`](@ref) `constant_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_constant_reactive_power`](@ref)."""
get_constant_reactive_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:constant_reactive_power), Val(:mvar), units)
get_constant_reactive_power(value::InterruptibleStandardLoad) = _units_arg_required(get_constant_reactive_power, value, :constant_reactive_power, Val(:mvar))
get_constant_reactive_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_constant_reactive_power_unitful, value, :constant_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_constant_reactive_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_constant_reactive_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
"""Get [`InterruptibleStandardLoad`](@ref) `impedance_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_impedance_active_power_unitful`](@ref)."""
get_impedance_active_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:impedance_active_power), Val(:mw), units))
"""Get [`InterruptibleStandardLoad`](@ref) `impedance_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_impedance_active_power`](@ref)."""
get_impedance_active_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:impedance_active_power), Val(:mw), units)
get_impedance_active_power(value::InterruptibleStandardLoad) = _units_arg_required(get_impedance_active_power, value, :impedance_active_power, Val(:mw))
get_impedance_active_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_impedance_active_power_unitful, value, :impedance_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_impedance_active_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_impedance_active_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
"""Get [`InterruptibleStandardLoad`](@ref) `impedance_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_impedance_reactive_power_unitful`](@ref)."""
get_impedance_reactive_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:impedance_reactive_power), Val(:mvar), units))
"""Get [`InterruptibleStandardLoad`](@ref) `impedance_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_impedance_reactive_power`](@ref)."""
get_impedance_reactive_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:impedance_reactive_power), Val(:mvar), units)
get_impedance_reactive_power(value::InterruptibleStandardLoad) = _units_arg_required(get_impedance_reactive_power, value, :impedance_reactive_power, Val(:mvar))
get_impedance_reactive_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_impedance_reactive_power_unitful, value, :impedance_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_impedance_reactive_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_impedance_reactive_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
"""Get [`InterruptibleStandardLoad`](@ref) `current_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_current_active_power_unitful`](@ref)."""
get_current_active_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:current_active_power), Val(:mw), units))
"""Get [`InterruptibleStandardLoad`](@ref) `current_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_current_active_power`](@ref)."""
get_current_active_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:current_active_power), Val(:mw), units)
get_current_active_power(value::InterruptibleStandardLoad) = _units_arg_required(get_current_active_power, value, :current_active_power, Val(:mw))
get_current_active_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_current_active_power_unitful, value, :current_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_current_active_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_current_active_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
"""Get [`InterruptibleStandardLoad`](@ref) `current_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_current_reactive_power_unitful`](@ref)."""
get_current_reactive_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:current_reactive_power), Val(:mvar), units))
"""Get [`InterruptibleStandardLoad`](@ref) `current_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_current_reactive_power`](@ref)."""
get_current_reactive_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:current_reactive_power), Val(:mvar), units)
get_current_reactive_power(value::InterruptibleStandardLoad) = _units_arg_required(get_current_reactive_power, value, :current_reactive_power, Val(:mvar))
get_current_reactive_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_current_reactive_power_unitful, value, :current_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_current_reactive_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_current_reactive_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
"""Get [`InterruptibleStandardLoad`](@ref) `max_constant_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_constant_active_power_unitful`](@ref)."""
get_max_constant_active_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_constant_active_power), Val(:mw), units))
"""Get [`InterruptibleStandardLoad`](@ref) `max_constant_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_constant_active_power`](@ref)."""
get_max_constant_active_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:max_constant_active_power), Val(:mw), units)
get_max_constant_active_power(value::InterruptibleStandardLoad) = _units_arg_required(get_max_constant_active_power, value, :max_constant_active_power, Val(:mw))
get_max_constant_active_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_max_constant_active_power_unitful, value, :max_constant_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_max_constant_active_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_constant_active_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
"""Get [`InterruptibleStandardLoad`](@ref) `max_constant_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_constant_reactive_power_unitful`](@ref)."""
get_max_constant_reactive_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_constant_reactive_power), Val(:mvar), units))
"""Get [`InterruptibleStandardLoad`](@ref) `max_constant_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_constant_reactive_power`](@ref)."""
get_max_constant_reactive_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:max_constant_reactive_power), Val(:mvar), units)
get_max_constant_reactive_power(value::InterruptibleStandardLoad) = _units_arg_required(get_max_constant_reactive_power, value, :max_constant_reactive_power, Val(:mvar))
get_max_constant_reactive_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_max_constant_reactive_power_unitful, value, :max_constant_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_max_constant_reactive_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_constant_reactive_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
"""Get [`InterruptibleStandardLoad`](@ref) `max_impedance_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_impedance_active_power_unitful`](@ref)."""
get_max_impedance_active_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_impedance_active_power), Val(:mw), units))
"""Get [`InterruptibleStandardLoad`](@ref) `max_impedance_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_impedance_active_power`](@ref)."""
get_max_impedance_active_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:max_impedance_active_power), Val(:mw), units)
get_max_impedance_active_power(value::InterruptibleStandardLoad) = _units_arg_required(get_max_impedance_active_power, value, :max_impedance_active_power, Val(:mw))
get_max_impedance_active_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_max_impedance_active_power_unitful, value, :max_impedance_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_max_impedance_active_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_impedance_active_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
"""Get [`InterruptibleStandardLoad`](@ref) `max_impedance_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_impedance_reactive_power_unitful`](@ref)."""
get_max_impedance_reactive_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_impedance_reactive_power), Val(:mvar), units))
"""Get [`InterruptibleStandardLoad`](@ref) `max_impedance_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_impedance_reactive_power`](@ref)."""
get_max_impedance_reactive_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:max_impedance_reactive_power), Val(:mvar), units)
get_max_impedance_reactive_power(value::InterruptibleStandardLoad) = _units_arg_required(get_max_impedance_reactive_power, value, :max_impedance_reactive_power, Val(:mvar))
get_max_impedance_reactive_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_max_impedance_reactive_power_unitful, value, :max_impedance_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_max_impedance_reactive_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_impedance_reactive_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
"""Get [`InterruptibleStandardLoad`](@ref) `max_current_active_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_current_active_power_unitful`](@ref)."""
get_max_current_active_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_current_active_power), Val(:mw), units))
"""Get [`InterruptibleStandardLoad`](@ref) `max_current_active_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_current_active_power`](@ref)."""
get_max_current_active_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:max_current_active_power), Val(:mw), units)
get_max_current_active_power(value::InterruptibleStandardLoad) = _units_arg_required(get_max_current_active_power, value, :max_current_active_power, Val(:mw))
get_max_current_active_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_max_current_active_power_unitful, value, :max_current_active_power, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_max_current_active_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_current_active_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
"""Get [`InterruptibleStandardLoad`](@ref) `max_current_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_current_reactive_power_unitful`](@ref)."""
get_max_current_reactive_power(value::InterruptibleStandardLoad, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_current_reactive_power), Val(:mvar), units))
"""Get [`InterruptibleStandardLoad`](@ref) `max_current_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_current_reactive_power`](@ref)."""
get_max_current_reactive_power_unitful(value::InterruptibleStandardLoad, units) = get_value(value, Val(:max_current_reactive_power), Val(:mvar), units)
get_max_current_reactive_power(value::InterruptibleStandardLoad) = _units_arg_required(get_max_current_reactive_power, value, :max_current_reactive_power, Val(:mvar))
get_max_current_reactive_power_unitful(value::InterruptibleStandardLoad) = _units_arg_required(get_max_current_reactive_power_unitful, value, :max_current_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_max_current_reactive_power), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_current_reactive_power_unitful), ::Type{InterruptibleStandardLoad}) = InfrastructureSystems.SU
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
"""Set [`InterruptibleStandardLoad`](@ref) `operation_cost`."""
set_operation_cost!(value::InterruptibleStandardLoad, val) = value.operation_cost = val
"""Set [`InterruptibleStandardLoad`](@ref) `conformity`."""
set_conformity!(value::InterruptibleStandardLoad, val) = value.conformity = val
"""Set [`InterruptibleStandardLoad`](@ref) `constant_active_power`."""
set_constant_active_power!(value::InterruptibleStandardLoad, val) = value.constant_active_power = set_value(value, Val(:constant_active_power), val, Val(:mw))
set_constant_active_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_constant_active_power!, value, :constant_active_power, Val(:mw), val)
"""Set [`InterruptibleStandardLoad`](@ref) `constant_reactive_power`."""
set_constant_reactive_power!(value::InterruptibleStandardLoad, val) = value.constant_reactive_power = set_value(value, Val(:constant_reactive_power), val, Val(:mvar))
set_constant_reactive_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_constant_reactive_power!, value, :constant_reactive_power, Val(:mvar), val)
"""Set [`InterruptibleStandardLoad`](@ref) `impedance_active_power`."""
set_impedance_active_power!(value::InterruptibleStandardLoad, val) = value.impedance_active_power = set_value(value, Val(:impedance_active_power), val, Val(:mw))
set_impedance_active_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_impedance_active_power!, value, :impedance_active_power, Val(:mw), val)
"""Set [`InterruptibleStandardLoad`](@ref) `impedance_reactive_power`."""
set_impedance_reactive_power!(value::InterruptibleStandardLoad, val) = value.impedance_reactive_power = set_value(value, Val(:impedance_reactive_power), val, Val(:mvar))
set_impedance_reactive_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_impedance_reactive_power!, value, :impedance_reactive_power, Val(:mvar), val)
"""Set [`InterruptibleStandardLoad`](@ref) `current_active_power`."""
set_current_active_power!(value::InterruptibleStandardLoad, val) = value.current_active_power = set_value(value, Val(:current_active_power), val, Val(:mw))
set_current_active_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_current_active_power!, value, :current_active_power, Val(:mw), val)
"""Set [`InterruptibleStandardLoad`](@ref) `current_reactive_power`."""
set_current_reactive_power!(value::InterruptibleStandardLoad, val) = value.current_reactive_power = set_value(value, Val(:current_reactive_power), val, Val(:mvar))
set_current_reactive_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_current_reactive_power!, value, :current_reactive_power, Val(:mvar), val)
"""Set [`InterruptibleStandardLoad`](@ref) `max_constant_active_power`."""
set_max_constant_active_power!(value::InterruptibleStandardLoad, val) = value.max_constant_active_power = set_value(value, Val(:max_constant_active_power), val, Val(:mw))
set_max_constant_active_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_max_constant_active_power!, value, :max_constant_active_power, Val(:mw), val)
"""Set [`InterruptibleStandardLoad`](@ref) `max_constant_reactive_power`."""
set_max_constant_reactive_power!(value::InterruptibleStandardLoad, val) = value.max_constant_reactive_power = set_value(value, Val(:max_constant_reactive_power), val, Val(:mvar))
set_max_constant_reactive_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_max_constant_reactive_power!, value, :max_constant_reactive_power, Val(:mvar), val)
"""Set [`InterruptibleStandardLoad`](@ref) `max_impedance_active_power`."""
set_max_impedance_active_power!(value::InterruptibleStandardLoad, val) = value.max_impedance_active_power = set_value(value, Val(:max_impedance_active_power), val, Val(:mw))
set_max_impedance_active_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_max_impedance_active_power!, value, :max_impedance_active_power, Val(:mw), val)
"""Set [`InterruptibleStandardLoad`](@ref) `max_impedance_reactive_power`."""
set_max_impedance_reactive_power!(value::InterruptibleStandardLoad, val) = value.max_impedance_reactive_power = set_value(value, Val(:max_impedance_reactive_power), val, Val(:mvar))
set_max_impedance_reactive_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_max_impedance_reactive_power!, value, :max_impedance_reactive_power, Val(:mvar), val)
"""Set [`InterruptibleStandardLoad`](@ref) `max_current_active_power`."""
set_max_current_active_power!(value::InterruptibleStandardLoad, val) = value.max_current_active_power = set_value(value, Val(:max_current_active_power), val, Val(:mw))
set_max_current_active_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_max_current_active_power!, value, :max_current_active_power, Val(:mw), val)
"""Set [`InterruptibleStandardLoad`](@ref) `max_current_reactive_power`."""
set_max_current_reactive_power!(value::InterruptibleStandardLoad, val) = value.max_current_reactive_power = set_value(value, Val(:max_current_reactive_power), val, Val(:mvar))
set_max_current_reactive_power!(value::InterruptibleStandardLoad, val::_UntaggedNumber) = _units_tag_required(set_max_current_reactive_power!, value, :max_current_reactive_power, Val(:mvar), val)
"""Set [`InterruptibleStandardLoad`](@ref) `services`."""
set_services!(value::InterruptibleStandardLoad, val) = value.services = val
"""Set [`InterruptibleStandardLoad`](@ref) `ext`."""
set_ext!(value::InterruptibleStandardLoad, val) = value.ext = val


function from_openapi(po::PO.InterruptibleStandardLoad, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return InterruptibleStandardLoad(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        base_power = po.base_power,
        operation_cost = convert_cost(po.operation_cost)::OperationalCost,
        conformity = LoadConformity(po.conformity),
        constant_active_power = po.constant_active_power,
        constant_reactive_power = po.constant_reactive_power,
        impedance_active_power = po.impedance_active_power,
        impedance_reactive_power = po.impedance_reactive_power,
        current_active_power = po.current_active_power,
        current_reactive_power = po.current_reactive_power,
        max_constant_active_power = po.max_constant_active_power,
        max_constant_reactive_power = po.max_constant_reactive_power,
        max_impedance_active_power = po.max_impedance_active_power,
        max_impedance_reactive_power = po.max_impedance_reactive_power,
        max_current_active_power = po.max_current_active_power,
        max_current_reactive_power = po.max_current_reactive_power,
    )
end

function from_openapi(po::PO.InterruptibleStandardLoad, refs::OpenAPIRefs, ::NaturalUnit)
    return InterruptibleStandardLoad(;
        name = po.name,
        available = po.available,
        bus = resolve_ref(refs, po.bus, ACBus),
        base_power = po.base_power,
        operation_cost = convert_cost(po.operation_cost)::OperationalCost,
        conformity = LoadConformity(po.conformity),
        constant_active_power = po.constant_active_power / po.base_power,
        constant_reactive_power = po.constant_reactive_power / po.base_power,
        impedance_active_power = po.impedance_active_power / po.base_power,
        impedance_reactive_power = po.impedance_reactive_power / po.base_power,
        current_active_power = po.current_active_power / po.base_power,
        current_reactive_power = po.current_reactive_power / po.base_power,
        max_constant_active_power = po.max_constant_active_power / po.base_power,
        max_constant_reactive_power = po.max_constant_reactive_power / po.base_power,
        max_impedance_active_power = po.max_impedance_active_power / po.base_power,
        max_impedance_reactive_power = po.max_impedance_reactive_power / po.base_power,
        max_current_active_power = po.max_current_active_power / po.base_power,
        max_current_reactive_power = po.max_current_reactive_power / po.base_power,
    )
end

function from_openapi(po::PO.InterruptibleStandardLoad, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("InterruptibleStandardLoad", po.id, po.power_units))
end

function to_openapi(value::InterruptibleStandardLoad, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PO.InterruptibleStandardLoad(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        base_power = _get_base_power(value),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
        conformity = string(get_conformity(value)),
        constant_active_power = get_constant_active_power(value, DU),
        constant_reactive_power = get_constant_reactive_power(value, DU),
        impedance_active_power = get_impedance_active_power(value, DU),
        impedance_reactive_power = get_impedance_reactive_power(value, DU),
        current_active_power = get_current_active_power(value, DU),
        current_reactive_power = get_current_reactive_power(value, DU),
        max_constant_active_power = get_max_constant_active_power(value, DU),
        max_constant_reactive_power = get_max_constant_reactive_power(value, DU),
        max_impedance_active_power = get_max_impedance_active_power(value, DU),
        max_impedance_reactive_power = get_max_impedance_reactive_power(value, DU),
        max_current_active_power = get_max_current_active_power(value, DU),
        max_current_reactive_power = get_max_current_reactive_power(value, DU),
        power_units = _power_units_string(DU),
    )
end

function to_openapi(value::InterruptibleStandardLoad, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.InterruptibleStandardLoad(;
        id = component_id(refs, value),
        name = get_name(value),
        available = get_available(value),
        bus = component_id(refs, get_bus(value)),
        base_power = _get_base_power(value),
        operation_cost = convert_cost_to_openapi(get_operation_cost(value)),
        conformity = string(get_conformity(value)),
        constant_active_power = get_constant_active_power(value, DU) * _get_base_power(value),
        constant_reactive_power = get_constant_reactive_power(value, DU) * _get_base_power(value),
        impedance_active_power = get_impedance_active_power(value, DU) * _get_base_power(value),
        impedance_reactive_power = get_impedance_reactive_power(value, DU) * _get_base_power(value),
        current_active_power = get_current_active_power(value, DU) * _get_base_power(value),
        current_reactive_power = get_current_reactive_power(value, DU) * _get_base_power(value),
        max_constant_active_power = get_max_constant_active_power(value, DU) * _get_base_power(value),
        max_constant_reactive_power = get_max_constant_reactive_power(value, DU) * _get_base_power(value),
        max_impedance_active_power = get_max_impedance_active_power(value, DU) * _get_base_power(value),
        max_impedance_reactive_power = get_max_impedance_reactive_power(value, DU) * _get_base_power(value),
        max_current_active_power = get_max_current_active_power(value, DU) * _get_base_power(value),
        max_current_reactive_power = get_max_current_reactive_power(value, DU) * _get_base_power(value),
        power_units = _power_units_string(NU),
    )
end
