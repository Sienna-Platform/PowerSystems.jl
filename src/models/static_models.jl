"""
Abstract type for devices that [inject](@ref I) power or current

A [static](@ref S) injection is a steady state injection, such as modeling
the output power of a generator held constant over a five-minute period.

Many `StaticInjection` models can accept a [`DynamicInjection`](@ref) model
as an optional add-on for conducting [dynamic](@ref D) simulations.

Subtypes: [`Generator`](@ref), [`ElectricLoad`](@ref), [`Storage`](@ref),
[`StaticInjectionSubsystem`](@ref)

See also: [`Device`](@ref)
"""
abstract type StaticInjection <: Device end

"""
Return false since most devices do not support services by default.

See also [`supports_services` for `StaticInjection`](@ref supports_services(::StaticInjection)),
[`supports_services` for `ACBranch`](@ref supports_services(::ACBranch)),
[`supports_services` for `HydroReservoir`](@ref supports_services(::HydroReservoir)),
[`supports_services` for `DynamicInjection`](@ref supports_services(::DynamicInjection)).

# Arguments
- `device::Device`: The device.
"""
function supports_services(::Device)
    return false
end

"""
Return true since static injection devices support services.

See also [`supports_services` for `Device`](@ref supports_services(::Device)),
[`supports_services` for `ACBranch`](@ref supports_services(::ACBranch)),
[`supports_services` for `HydroReservoir`](@ref supports_services(::HydroReservoir)),
[`supports_services` for `DynamicInjection`](@ref supports_services(::DynamicInjection)).

# Arguments
- `device::StaticInjection`: The device.
"""
function supports_services(::StaticInjection)
    return true
end

"""
Return the services attached to a device. Returns an empty vector for devices
that do not support services.

# Arguments
- `device::Device`: The device.
"""
function get_services(device::Device)
    if !supports_services(device)
        error(ArgumentError(
            "Device $(get_name(device)) does not support services",
        ))
    end
    return Vector{Service}()
end

"""
Return the [`DynamicInjection`](@ref) component attached to this device,
or `nothing` if none is attached.

# Arguments
- `d::StaticInjection`: The static injection device.
"""
get_dynamic_injector(d::StaticInjection) = nothing

"""
Return the frequency droop of the device's [`DynamicInjection`](@ref) model.

Throws `ArgumentError` if no dynamic injector is attached.

See also [`get_frequency_droop` for `DynamicGenerator`](@ref get_frequency_droop(::DynamicGenerator)),
[`get_frequency_droop` for `DynamicInjection`](@ref get_frequency_droop(::V) where {V <: DynamicInjection}).

# Arguments
- `static_injector::StaticInjection`: The static injection device.
"""
function get_frequency_droop(static_injector::StaticInjection)
    dynamic_injector = get_dynamic_injector(static_injector)
    if isnothing(dynamic_injector)
        throw(
            ArgumentError(
                "cannot get frequency droop for $(summary(static_injector)) because it does not have dynamic data.",
            ),
        )
    end
    return get_frequency_droop(dynamic_injector)
end
