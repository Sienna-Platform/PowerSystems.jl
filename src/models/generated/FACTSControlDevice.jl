#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct FACTSControlDevice <: StaticInjection
        name::String
        available::Bool
        bus::ACBus
        control_mode::Union{Nothing, FACTSOperationModes}
        voltage_setpoint::Float64
        max_shunt_current::Float64
        max_reactive_power::Float64
        shunt_control_type::FACTSShuntControlType
        regulated_bus_number::Int
        reactive_power_required::Float64
        base_power::Float64
        services::Vector{Service}
        dynamic_injector::Union{Nothing, DynamicInjection}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

Facts control devices.

Most often used in AC power flow studies as a control of voltage and, active and reactive power.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Sending end bus number
- `control_mode::Union{Nothing, FACTSOperationModes}`: Control mode. Used to describe the behavior of the control device. [Options are listed here.](@ref factsmodes_list)
- `voltage_setpoint::Float64`: (default: `1.0`) Voltage setpoint at the sending end bus, it has to be a [`PV`](@ref ACBusTypes) bus, in p.u. ([`SYSTEM_BASE`](@ref per_unit)).
- `max_shunt_current::Float64`: (default: `9999.0`) Maximum shunt current at unity voltage, MVA; the STATCOM current limit and SVC susceptance base.
- `max_reactive_power::Float64`: (default: `9999.0`) Independent maximum reactive power ceiling (MVA); the device reactive limit is min(the current/susceptance law on max_shunt_current, this value). Non-binding at the 9999.0 default.
- `shunt_control_type::FACTSShuntControlType`: (default: `FACTSShuntControlType.STATCOM`) Device class selecting the reactive-limit law (SVC vs STATCOM)
- `regulated_bus_number::Int`: (default: `0`) Bus whose voltage this device regulates; 0 ⇒ local (sending) bus
- `reactive_power_required::Float64`: (default: `0.0`) Solver-populated: delivered reactive power after solve (output; not parsed from input)
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) Corresponding dynamic injection model for FACTS control device
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct FACTSControlDevice <: StaticInjection
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Sending end bus number"
    bus::ACBus
    "Control mode. Used to describe the behavior of the control device. [Options are listed here.](@ref factsmodes_list)"
    control_mode::Union{Nothing, FACTSOperationModes}
    "Voltage setpoint at the sending end bus, it has to be a [`PV`](@ref ACBusTypes) bus, in p.u. ([`SYSTEM_BASE`](@ref per_unit))."
    voltage_setpoint::Float64
    "Maximum shunt current at unity voltage, MVA; the STATCOM current limit and SVC susceptance base."
    max_shunt_current::Float64
    "Independent maximum reactive power ceiling (MVA); the device reactive limit is min(the current/susceptance law on max_shunt_current, this value). Non-binding at the 9999.0 default."
    max_reactive_power::Float64
    "Device class selecting the reactive-limit law (SVC vs STATCOM)"
    shunt_control_type::FACTSShuntControlType
    "Bus whose voltage this device regulates; 0 ⇒ local (sending) bus"
    regulated_bus_number::Int
    "Solver-populated: delivered reactive power after solve (output; not parsed from input)"
    reactive_power_required::Float64
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "Services that this device contributes to"
    services::Vector{Service}
    "Corresponding dynamic injection model for FACTS control device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function FACTSControlDevice(name, available, bus, control_mode, voltage_setpoint=1.0, max_shunt_current=9999.0, max_reactive_power=9999.0, shunt_control_type=FACTSShuntControlType.STATCOM, regulated_bus_number=0, reactive_power_required=0.0, base_power=100.0, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), )
    FACTSControlDevice(name, available, bus, control_mode, voltage_setpoint, max_shunt_current, max_reactive_power, shunt_control_type, regulated_bus_number, reactive_power_required, base_power, services, dynamic_injector, ext, InfrastructureSystemsInternal(), )
end

function FACTSControlDevice(; name, available, bus, control_mode, voltage_setpoint=1.0, max_shunt_current=9999.0, max_reactive_power=9999.0, shunt_control_type=FACTSShuntControlType.STATCOM, regulated_bus_number=0, reactive_power_required=0.0, base_power=100.0, services=Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    FACTSControlDevice(name, available, bus, control_mode, voltage_setpoint, max_shunt_current, max_reactive_power, shunt_control_type, regulated_bus_number, reactive_power_required, base_power, services, dynamic_injector, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function FACTSControlDevice(::Nothing)
    FACTSControlDevice(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        control_mode=nothing,
        voltage_setpoint=1.0,
        max_shunt_current=0.0,
        max_reactive_power=0.0,
        shunt_control_type=FACTSShuntControlType.STATCOM,
        regulated_bus_number=0,
        reactive_power_required=0.0,
        base_power=100.0,
        services=Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
    )
end

"""Get [`FACTSControlDevice`](@ref) `name`."""
get_name(value::FACTSControlDevice) = value.name
"""Get [`FACTSControlDevice`](@ref) `available`."""
get_available(value::FACTSControlDevice) = value.available
"""Get [`FACTSControlDevice`](@ref) `bus`."""
get_bus(value::FACTSControlDevice) = value.bus
"""Get [`FACTSControlDevice`](@ref) `control_mode`."""
get_control_mode(value::FACTSControlDevice) = value.control_mode
"""Get [`FACTSControlDevice`](@ref) `voltage_setpoint`."""
get_voltage_setpoint(value::FACTSControlDevice) = value.voltage_setpoint
"""Get [`FACTSControlDevice`](@ref) `max_shunt_current` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_shunt_current_unitful`](@ref)."""
get_max_shunt_current(value::FACTSControlDevice, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_shunt_current), Val(:mva), units))
"""Get [`FACTSControlDevice`](@ref) `max_shunt_current` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_shunt_current`](@ref)."""
get_max_shunt_current_unitful(value::FACTSControlDevice, units) = get_value(value, Val(:max_shunt_current), Val(:mva), units)
get_max_shunt_current(value::FACTSControlDevice) = _units_arg_required(get_max_shunt_current, value, :max_shunt_current, Val(:mva))
get_max_shunt_current_unitful(value::FACTSControlDevice) = _units_arg_required(get_max_shunt_current_unitful, value, :max_shunt_current, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_max_shunt_current), ::Type{FACTSControlDevice}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_shunt_current_unitful), ::Type{FACTSControlDevice}) = InfrastructureSystems.SU
"""Get [`FACTSControlDevice`](@ref) `max_reactive_power` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_reactive_power_unitful`](@ref)."""
get_max_reactive_power(value::FACTSControlDevice, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_reactive_power), Val(:mvar), units))
"""Get [`FACTSControlDevice`](@ref) `max_reactive_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_max_reactive_power`](@ref)."""
get_max_reactive_power_unitful(value::FACTSControlDevice, units) = get_value(value, Val(:max_reactive_power), Val(:mvar), units)
get_max_reactive_power(value::FACTSControlDevice) = _units_arg_required(get_max_reactive_power, value, :max_reactive_power, Val(:mvar))
get_max_reactive_power_unitful(value::FACTSControlDevice) = _units_arg_required(get_max_reactive_power_unitful, value, :max_reactive_power, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_max_reactive_power), ::Type{FACTSControlDevice}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_max_reactive_power_unitful), ::Type{FACTSControlDevice}) = InfrastructureSystems.SU
"""Get [`FACTSControlDevice`](@ref) `shunt_control_type`."""
get_shunt_control_type(value::FACTSControlDevice) = value.shunt_control_type
"""Get [`FACTSControlDevice`](@ref) `regulated_bus_number`."""
get_regulated_bus_number(value::FACTSControlDevice) = value.regulated_bus_number
"""Get [`FACTSControlDevice`](@ref) `reactive_power_required`."""
get_reactive_power_required(value::FACTSControlDevice) = value.reactive_power_required

_get_base_power(value::FACTSControlDevice) = value.base_power
"""Get [`FACTSControlDevice`](@ref) `services`."""
get_services(value::FACTSControlDevice) = value.services
"""Get [`FACTSControlDevice`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::FACTSControlDevice) = value.dynamic_injector
"""Get [`FACTSControlDevice`](@ref) `ext`."""
get_ext(value::FACTSControlDevice) = value.ext
"""Get [`FACTSControlDevice`](@ref) `internal`."""
get_internal(value::FACTSControlDevice) = value.internal

"""Set [`FACTSControlDevice`](@ref) `available`."""
set_available!(value::FACTSControlDevice, val) = value.available = val
"""Set [`FACTSControlDevice`](@ref) `bus`."""
set_bus!(value::FACTSControlDevice, val) = value.bus = val
"""Set [`FACTSControlDevice`](@ref) `control_mode`."""
set_control_mode!(value::FACTSControlDevice, val) = value.control_mode = val
"""Set [`FACTSControlDevice`](@ref) `voltage_setpoint`."""
set_voltage_setpoint!(value::FACTSControlDevice, val) = value.voltage_setpoint = val
"""Set [`FACTSControlDevice`](@ref) `max_shunt_current`."""
set_max_shunt_current!(value::FACTSControlDevice, val) = value.max_shunt_current = set_value(value, Val(:max_shunt_current), val, Val(:mva))
set_max_shunt_current!(value::FACTSControlDevice, val::_UntaggedNumber) = _units_tag_required(set_max_shunt_current!, value, :max_shunt_current, Val(:mva), val)
"""Set [`FACTSControlDevice`](@ref) `max_reactive_power`."""
set_max_reactive_power!(value::FACTSControlDevice, val) = value.max_reactive_power = set_value(value, Val(:max_reactive_power), val, Val(:mvar))
set_max_reactive_power!(value::FACTSControlDevice, val::_UntaggedNumber) = _units_tag_required(set_max_reactive_power!, value, :max_reactive_power, Val(:mvar), val)
"""Set [`FACTSControlDevice`](@ref) `shunt_control_type`."""
set_shunt_control_type!(value::FACTSControlDevice, val) = value.shunt_control_type = val
"""Set [`FACTSControlDevice`](@ref) `regulated_bus_number`."""
set_regulated_bus_number!(value::FACTSControlDevice, val) = value.regulated_bus_number = val
"""Set [`FACTSControlDevice`](@ref) `reactive_power_required`."""
set_reactive_power_required!(value::FACTSControlDevice, val) = value.reactive_power_required = val
"""Set [`FACTSControlDevice`](@ref) `services`."""
set_services!(value::FACTSControlDevice, val) = value.services = val
"""Set [`FACTSControlDevice`](@ref) `ext`."""
set_ext!(value::FACTSControlDevice, val) = value.ext = val
