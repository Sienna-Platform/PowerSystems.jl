#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SwitchedAdmittance <: ElectricLoad
        name::String
        available::Bool
        bus::ACBus
        Y::Complex{Float64}
        number_engaged::Vector{Int}
        number_of_steps::Vector{Int}
        Y_increase::Vector{Complex{Float64}}
        solved_admittance::Union{Nothing, Float64}
        admittance_limits::MinMax
        control_mode::SwitchedAdmittanceControlMode
        regulated_bus_number::Int
        dynamic_injector::Union{Nothing, DynamicInjection}
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A switched admittance, with discrete steps to adjust the admittance.

Most often used in power flow studies, iterating over the steps to see impacts of admittance on the results. Total admittance is calculated as: `Y` + `number_engaged` * `Y_increase`, unless `solved_admittance` is set, in which case that value is the effective admittance

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `bus::ACBus`: Bus that this component is connected to
- `Y::Complex{Float64}`: Initial admittance at N = 0
- `number_engaged::Vector{Int}`: (default: `Int[]`) Vector with the number of steps currently engaged (switched in) for each adjustable shunt block. For example, `number_engaged[2]` is the number of steps in service at block 2, and cannot exceed `number_of_steps[2]`. Power flow writes the solved-for step count back to this field (PSS/E `Si`).
- `number_of_steps::Vector{Int}`: (default: `Int[]`) Vector with number of steps for each adjustable shunt block. For example, `number_of_steps[2]` are the number of available steps for admittance increment at block 2.
- `Y_increase::Vector{Complex{Float64}}`: (default: `Complex{Float64}[]`) Vector with admittance increment step for each adjustable shunt block. For example, `Y_increase[2]` is the complex admittance increment for each step at block 2.
- `solved_admittance::Union{Nothing, Float64}`: (default: `nothing`) Solved-case switched shunt admittance (PSS/E `BINIT`), or `nothing` when unset. When non-`nothing`, this value is the shunt's effective admittance, used in place of `Y` + `number_engaged` ⋅ `Y_increase`; power flow writes the solved-for admittance back to this field. Set it only when the case is to be treated as solved as read in, or when the device is locked (`control_mode == SwitchedAdmittanceControlMode.FIXED`).
- `admittance_limits::MinMax`: (default: `(min=1.0, max=1.0)`) Shunt admittance limits for switched shunt model
- `control_mode::SwitchedAdmittanceControlMode`: (default: `SwitchedAdmittanceControlMode.FIXED`) Switched-shunt control mode.
- `regulated_bus_number::Int`: (default: `0`) Bus number whose voltage/quantity this shunt regulates; 0 ⇒ local bus.
- `dynamic_injector::Union{Nothing, DynamicInjection}`: (default: `nothing`) corresponding dynamic injection model for admittance
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct SwitchedAdmittance <: ElectricLoad
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "Bus that this component is connected to"
    bus::ACBus
    "Initial admittance at N = 0"
    Y::Complex{Float64}
    "Vector with the number of steps currently engaged (switched in) for each adjustable shunt block. For example, `number_engaged[2]` is the number of steps in service at block 2, and cannot exceed `number_of_steps[2]`. Power flow writes the solved-for step count back to this field (PSS/E `Si`)."
    number_engaged::Vector{Int}
    "Vector with number of steps for each adjustable shunt block. For example, `number_of_steps[2]` are the number of available steps for admittance increment at block 2."
    number_of_steps::Vector{Int}
    "Vector with admittance increment step for each adjustable shunt block. For example, `Y_increase[2]` is the complex admittance increment for each step at block 2."
    Y_increase::Vector{Complex{Float64}}
    "Solved-case switched shunt admittance (PSS/E `BINIT`), or `nothing` when unset. When non-`nothing`, this value is the shunt's effective admittance, used in place of `Y` + `number_engaged` ⋅ `Y_increase`; power flow writes the solved-for admittance back to this field. Set it only when the case is to be treated as solved as read in, or when the device is locked (`control_mode == SwitchedAdmittanceControlMode.FIXED`)."
    solved_admittance::Union{Nothing, Float64}
    "Shunt admittance limits for switched shunt model"
    admittance_limits::MinMax
    "Switched-shunt control mode."
    control_mode::SwitchedAdmittanceControlMode
    "Bus number whose voltage/quantity this shunt regulates; 0 ⇒ local bus."
    regulated_bus_number::Int
    "corresponding dynamic injection model for admittance"
    dynamic_injector::Union{Nothing, DynamicInjection}
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function SwitchedAdmittance(name, available, bus, Y, number_engaged=Int[], number_of_steps=Int[], Y_increase=Complex{Float64}[], solved_admittance=nothing, admittance_limits=(min=1.0, max=1.0), control_mode=SwitchedAdmittanceControlMode.FIXED, regulated_bus_number=0, dynamic_injector=nothing, services=Device[], ext=Dict{String, Any}(), )
    SwitchedAdmittance(name, available, bus, Y, number_engaged, number_of_steps, Y_increase, solved_admittance, admittance_limits, control_mode, regulated_bus_number, dynamic_injector, services, ext, InfrastructureSystemsInternal(), )
end

function SwitchedAdmittance(; name, available, bus, Y, number_engaged=Int[], number_of_steps=Int[], Y_increase=Complex{Float64}[], solved_admittance=nothing, admittance_limits=(min=1.0, max=1.0), control_mode=SwitchedAdmittanceControlMode.FIXED, regulated_bus_number=0, dynamic_injector=nothing, services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    SwitchedAdmittance(name, available, bus, Y, number_engaged, number_of_steps, Y_increase, solved_admittance, admittance_limits, control_mode, regulated_bus_number, dynamic_injector, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function SwitchedAdmittance(::Nothing)
    SwitchedAdmittance(;
        name="init",
        available=false,
        bus=ACBus(nothing),
        Y=0.0 + 0.0im,
        number_engaged=Int[],
        number_of_steps=Int[],
        Y_increase=Complex{Float64}[],
        solved_admittance=nothing,
        admittance_limits=(min=0.0, max=0.0),
        control_mode=SwitchedAdmittanceControlMode.FIXED,
        regulated_bus_number=0,
        dynamic_injector=nothing,
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`SwitchedAdmittance`](@ref) `name`."""
get_name(value::SwitchedAdmittance) = value.name
"""Get [`SwitchedAdmittance`](@ref) `available`."""
get_available(value::SwitchedAdmittance) = value.available
"""Get [`SwitchedAdmittance`](@ref) `bus`."""
get_bus(value::SwitchedAdmittance) = value.bus
"""Get [`SwitchedAdmittance`](@ref) `Y`."""
get_Y(value::SwitchedAdmittance) = value.Y
"""Get [`SwitchedAdmittance`](@ref) `number_engaged`."""
get_number_engaged(value::SwitchedAdmittance) = value.number_engaged
"""Get [`SwitchedAdmittance`](@ref) `number_of_steps`."""
get_number_of_steps(value::SwitchedAdmittance) = value.number_of_steps
"""Get [`SwitchedAdmittance`](@ref) `Y_increase`."""
get_Y_increase(value::SwitchedAdmittance) = value.Y_increase
"""Get [`SwitchedAdmittance`](@ref) `solved_admittance`."""
get_solved_admittance(value::SwitchedAdmittance) = value.solved_admittance
"""Get [`SwitchedAdmittance`](@ref) `admittance_limits`."""
get_admittance_limits(value::SwitchedAdmittance) = value.admittance_limits
"""Get [`SwitchedAdmittance`](@ref) `control_mode`."""
get_control_mode(value::SwitchedAdmittance) = value.control_mode
"""Get [`SwitchedAdmittance`](@ref) `regulated_bus_number`."""
get_regulated_bus_number(value::SwitchedAdmittance) = value.regulated_bus_number
"""Get [`SwitchedAdmittance`](@ref) `dynamic_injector`."""
get_dynamic_injector(value::SwitchedAdmittance) = value.dynamic_injector
"""Get [`SwitchedAdmittance`](@ref) `services`."""
get_services(value::SwitchedAdmittance) = value.services
"""Get [`SwitchedAdmittance`](@ref) `ext`."""
get_ext(value::SwitchedAdmittance) = value.ext
"""Get [`SwitchedAdmittance`](@ref) `internal`."""
get_internal(value::SwitchedAdmittance) = value.internal

"""Set [`SwitchedAdmittance`](@ref) `available`."""
set_available!(value::SwitchedAdmittance, val) = value.available = val
"""Set [`SwitchedAdmittance`](@ref) `bus`."""
set_bus!(value::SwitchedAdmittance, val) = value.bus = val
"""Set [`SwitchedAdmittance`](@ref) `Y`."""
set_Y!(value::SwitchedAdmittance, val) = value.Y = val
"""Set [`SwitchedAdmittance`](@ref) `number_engaged`."""
set_number_engaged!(value::SwitchedAdmittance, val) = value.number_engaged = val
"""Set [`SwitchedAdmittance`](@ref) `number_of_steps`."""
set_number_of_steps!(value::SwitchedAdmittance, val) = value.number_of_steps = val
"""Set [`SwitchedAdmittance`](@ref) `Y_increase`."""
set_Y_increase!(value::SwitchedAdmittance, val) = value.Y_increase = val
"""Set [`SwitchedAdmittance`](@ref) `solved_admittance`."""
set_solved_admittance!(value::SwitchedAdmittance, val) = value.solved_admittance = val
"""Set [`SwitchedAdmittance`](@ref) `admittance_limits`."""
set_admittance_limits!(value::SwitchedAdmittance, val) = value.admittance_limits = val
"""Set [`SwitchedAdmittance`](@ref) `control_mode`."""
set_control_mode!(value::SwitchedAdmittance, val) = value.control_mode = val
"""Set [`SwitchedAdmittance`](@ref) `regulated_bus_number`."""
set_regulated_bus_number!(value::SwitchedAdmittance, val) = value.regulated_bus_number = val
"""Set [`SwitchedAdmittance`](@ref) `services`."""
set_services!(value::SwitchedAdmittance, val) = value.services = val
"""Set [`SwitchedAdmittance`](@ref) `ext`."""
set_ext!(value::SwitchedAdmittance, val) = value.ext = val
