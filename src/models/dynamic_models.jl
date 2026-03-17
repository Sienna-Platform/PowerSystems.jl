"""
Abstract type for all components used to compose a [`DynamicInjection`](@ref) device
"""
abstract type DynamicComponent <: DeviceParameter end

"""
Abstract type for all [Dynamic Devices](@ref)

A [dynamic](@ref D) [injection](@ref I) is the continuous time response of a generator,
typically modeled with differential equations. 
    
`DynamicInjection` components can added on to [`StaticInjection`](@ref) components,
which together define all the information needed to model the device in a dynamic
simulation.
"""
abstract type DynamicInjection <: Device end

"""
Return all the dynamic components of a [`DynamicInjection`](@ref) device.

# Arguments
- `device::DynamicInjection`: The dynamic injection device.
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
Default implementation of `get_states_types` for dynamic components.
Assumes all states are [`StateTypes.Differential`](@ref).

# Arguments
- `d::DynamicComponent`: The dynamic component.
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
