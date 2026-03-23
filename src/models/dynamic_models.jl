"""
Abstract type for all sub-components used to compose a [`DynamicInjection`](@ref) device.

Examples include machine models ([`BaseMachine`](@ref)), AVR models ([`AVRFixed`](@ref)),
and turbine governor models ([`TGFixed`](@ref)).

See also: [`DynamicInjection`](@ref)
"""
abstract type DynamicComponent <: DeviceParameter end

"""
Abstract type for all [Dynamic Devices](@ref dynamic_data).

A [dynamic](@ref D) [injection](@ref I) is the continuous time response of a generator,
typically modeled with differential equations.

`DynamicInjection` models are attached to [`StaticInjection`](@ref) components,
which together define all the information needed to model the device in a dynamic
simulation.

See also: [`DynamicComponent`](@ref), [`StaticInjection`](@ref)
"""
abstract type DynamicInjection <: Device end

"""
Return an iterator of all [`DynamicComponent`](@ref) fields of a [`DynamicInjection`](@ref) device.
"""
function get_dynamic_components(device::T) where {T <: DynamicInjection}
    return (
        getfield(device, x) for
        (x, y) in zip(fieldnames(T), fieldtypes(T)) if y <: DynamicComponent
    )
end

"""
Return false since dynamic injection devices do not support services.

See also [`supports_services` for `Device`](@ref supports_services(::Device)),
[`supports_services` for `StaticInjection`](@ref supports_services(::StaticInjection)),
[`supports_services` for `ACBranch`](@ref supports_services(::ACBranch)),
[`supports_services` for `HydroReservoir`](@ref supports_services(::HydroReservoir)).
"""
supports_services(::DynamicInjection) = false

"""
Return an empty vector of states for a [`DynamicInjection`](@ref) device.
"""
get_states(::DynamicInjection) = Vector{Symbol}()

"""
Return the [`StateTypes`](@ref) for each state of a [`DynamicComponent`](@ref).

The default implementation returns `StateTypes.Differential` for all states.
Subtypes may override this method to specify different state types.
"""
function get_states_types(d::DynamicComponent)
    return fill(StateTypes.Differential, get_n_states(d))
end

"""
Return the frequency droop of a [`DynamicInjection`](@ref) device.

Throws `ArgumentError` if not implemented for the specific subtype.

See also [`get_frequency_droop` for `StaticInjection`](@ref get_frequency_droop(::StaticInjection)),
[`get_frequency_droop` for `DynamicGenerator`](@ref get_frequency_droop(::DynamicGenerator)).
"""
function get_frequency_droop(::V) where {V <: DynamicInjection}
    throw(
        ArgumentError(
            "get_frequency_droop not implemented for type $V.",
        ),
    )
end
