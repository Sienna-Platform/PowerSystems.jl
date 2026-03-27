#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct Source <: StaticInjection
        name::String
        available::Bool
        bus::ACBus
        active_power::Float64
        reactive_power::Float64
        active_power_limits::MinMax
        reactive_power_limits::Union{Nothing, MinMax}
        R_th::Float64
        X_th::Float64
        internal_voltage::Float64
        internal_angle::Float64
        base_power::Float64
        operation_cost::ImportExportCost
        dynamic_injector::Union{Nothing, DynamicInjection}
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

An infinite bus with a constant voltage output.

Commonly used in dynamics simulations to represent a very large machine on a single bus or for the representation of import/exports in operational simulations

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `active_power::Float64`: (default: `0.0`) Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used
- `reactive_power::Float64`: (default: `0.0`) Initial reactive power set point of the unit (MVAR)
- `active_power_limits::MinMax`: (default: `(min=0.0, max=0.0)`) Minimum and maximum stable active power levels (MW)
- `reactive_power_limits::Union{Nothing, MinMax}`: (default: `(min=0.0, max=0.0)`) Minimum and maximum reactive power limits. Set to `Nothing` if not applicable
- `R_th::Float64`: (default: `0.0`) Source Thevenin resistance. [See here:](https://en.wikipedia.org/wiki/Thevenins_theorem), validation range: `(0, nothing)`
- `X_th::Float64`: (default: `0.0`) Source Thevenin reactance. [See here:](https://en.wikipedia.org/wiki/Thevenins_theorem), validation range: `(0, nothing)`
- `internal_voltage::Float64`: (default: `1.0`) Internal Voltage (pu), validation range: `(0, nothing)`
- `internal_angle::Float64`: (default: `0.0`) Internal Angle
- `base_power::Float64`: (default: `100.0`) Base Power in MVA
- `operation_cost::ImportExportCost`: (default: `ImportExportCost(nothing)`) [`ImportExportCost`](@ref) of the source.
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection device
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct Source <: StaticInjection
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Initial active power set point of the unit in MW. For power flow, this is the steady state operating point of the system. For production cost modeling, this may or may not be used as the initial starting point for the solver, depending on the solver used"
    active_power::Float64
    "Initial reactive power set point of the unit (MVAR)"
    reactive_power::Float64
    "Minimum and maximum stable active power levels (MW)"
    active_power_limits::MinMax
    "Minimum and maximum reactive power limits. Set to `Nothing` if not applicable"
    reactive_power_limits::Union{Nothing, MinMax}
    "Source Thevenin resistance. [See here:](https://en.wikipedia.org/wiki/Thevenins_theorem)"
    R_th::Float64
    "Source Thevenin reactance. [See here:](https://en.wikipedia.org/wiki/Thevenins_theorem)"
    X_th::Float64
    "Internal Voltage (pu)"
    internal_voltage::Float64
    "Internal Angle"
    internal_angle::Float64
    "Base Power in MVA"
    base_power::Float64
    "[`ImportExportCost`](@ref) of the source."
    operation_cost::ImportExportCost
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function Source(name, available, bus, active_power=0.0, reactive_power=0.0, active_power_limits=(min=0.0, max=0.0), reactive_power_limits=(min=0.0, max=0.0), R_th=0.0, X_th=0.0, internal_voltage=1.0, internal_angle=0.0, base_power=100.0, operation_cost=ImportExportCost(nothing), dynamic_injector=nothing, services=Device[], ext=Dict{String, Any}(), )
    Source(name, available, bus, active_power, reactive_power, active_power_limits, reactive_power_limits, R_th, X_th, internal_voltage, internal_angle, base_power, operation_cost, dynamic_injector, services, ext, InfrastructureSystemsInternal(), )
end

function Source(; name, available, bus, active_power=0.0, reactive_power=0.0, active_power_limits=(min=0.0, max=0.0), reactive_power_limits=(min=0.0, max=0.0), R_th=0.0, X_th=0.0, internal_voltage=1.0, internal_angle=0.0, base_power=100.0, operation_cost=ImportExportCost(nothing), dynamic_injector=nothing, services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    Source(name, available, bus, active_power, reactive_power, active_power_limits, reactive_power_limits, R_th, X_th, internal_voltage, internal_angle, base_power, operation_cost, dynamic_injector, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function Source(::Nothing)
    Source(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        active_power_limits=(min=0.0, max=0.0),
        reactive_power_limits=nothing,
        R_th=0,
        X_th=0,
        internal_voltage=0,
        internal_angle=0,
        base_power=0,
        operation_cost=ImportExportCost(nothing),
        dynamic_injector=nothing,
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`Source`](@ref) `name`."""
get_name(value::Source) = value.name
"""Get [`Source`](@ref) `available`."""
get_available(value::Source) = value.available
"""Get [`Source`](@ref) `bus`."""
get_bus(value::Source) = value.bus
"""Get [`Source`](@ref) `active_power`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_active_power(value::Source) = get_value(value, Val(:active_power), Val(:mva), DEFAULT_UNITS)
get_active_power(value::Source, units) = get_value(value, Val(:active_power), Val(:mva), units)
"""Get [`Source`](@ref) `reactive_power`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_reactive_power(value::Source) = get_value(value, Val(:reactive_power), Val(:mva), DEFAULT_UNITS)
get_reactive_power(value::Source, units) = get_value(value, Val(:reactive_power), Val(:mva), units)
"""Get [`Source`](@ref) `active_power_limits`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_active_power_limits(value::Source) = get_value(value, Val(:active_power_limits), Val(:mva), DEFAULT_UNITS)
get_active_power_limits(value::Source, units) = get_value(value, Val(:active_power_limits), Val(:mva), units)
"""Get [`Source`](@ref) `reactive_power_limits`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_reactive_power_limits(value::Source) = get_value(value, Val(:reactive_power_limits), Val(:mva), DEFAULT_UNITS)
get_reactive_power_limits(value::Source, units) = get_value(value, Val(:reactive_power_limits), Val(:mva), units)
"""Get [`Source`](@ref) `R_th`."""
get_R_th(value::Source) = value.R_th
"""Get [`Source`](@ref) `X_th`."""
get_X_th(value::Source) = value.X_th
"""Get [`Source`](@ref) `internal_voltage`."""
get_internal_voltage(value::Source) = value.internal_voltage
"""Get [`Source`](@ref) `internal_angle`."""
get_internal_angle(value::Source) = value.internal_angle

_get_base_power(value::Source) = value.base_power
"""Get [`Source`](@ref) `operation_cost`."""
get_operation_cost(value::Source) = value.operation_cost
"""Get [`Source`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::Source) = value.dynamic_injector
"""Get [`Source`](@ref) `services`."""
get_services(value::Source) = value.services
"""Get [`Source`](@ref) `ext`."""
get_ext(value::Source) = value.ext
"""Get [`Source`](@ref) `internal`."""
get_internal(value::Source) = value.internal

"""Set [`Source`](@ref) `available`."""
set_available!(value::Source, val) = value.available = val
"""Set [`Source`](@ref) `bus`."""
set_bus!(value::Source, val) = value.bus = val
"""Set [`Source`](@ref) `active_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power!(value::Source, val) = value.active_power = set_value(value, Val(:active_power), val, Val(:mva))
"""Set [`Source`](@ref) `reactive_power`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power!(value::Source, val) = value.reactive_power = set_value(value, Val(:reactive_power), val, Val(:mva))
"""Set [`Source`](@ref) `active_power_limits`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_limits!(value::Source, val) = value.active_power_limits = set_value(value, Val(:active_power_limits), val, Val(:mva))
"""Set [`Source`](@ref) `reactive_power_limits`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power_limits!(value::Source, val) = value.reactive_power_limits = set_value(value, Val(:reactive_power_limits), val, Val(:mva))
"""Set [`Source`](@ref) `R_th`."""
set_R_th!(value::Source, val) = value.R_th = val
"""Set [`Source`](@ref) `X_th`."""
set_X_th!(value::Source, val) = value.X_th = val
"""Set [`Source`](@ref) `internal_voltage`."""
set_internal_voltage!(value::Source, val) = value.internal_voltage = val
"""Set [`Source`](@ref) `internal_angle`."""
set_internal_angle!(value::Source, val) = value.internal_angle = val
"""Set [`Source`](@ref) `operation_cost`."""
set_operation_cost!(value::Source, val) = value.operation_cost = val
"""Set [`Source`](@ref) `services`."""
set_services!(value::Source, val) = value.services = val
"""Set [`Source`](@ref) `ext`."""
set_ext!(value::Source, val) = value.ext = val
