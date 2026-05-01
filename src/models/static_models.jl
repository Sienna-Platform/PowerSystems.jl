"""
Abstract type for devices that [inject](@ref I) power or current

A [static](@ref S) injection is a steady state injection, such as modeling
the output power of a generator held constant over a five-minute period.

Many `StaticInjection` models can accept a [`DynamicInjection`](@ref) model
as an optional add-on for conducting [dynamic](@ref D) simulations.
"""
abstract type StaticInjection <: Device end

function supports_services(::T) where {T <: Device}
    return false
end

function supports_services(::T) where {T <: StaticInjection}
    return true
end

function get_services(device::Device)
    if !supports_services(device)
        error(ArgumentError(
            "Device $(get_name(device)) does not support services",
        ))
    end
    return Vector{Service}()
end

"""
Return `true` if the device has active power as a controllable parameter.
"""
supports_active_power(::StaticInjection) = true

"""
Return `true` if the device has reactive power as a controllable parameter.
"""
supports_reactive_power(::StaticInjection) = true

"""
Return `true` if the device can control voltage at its connected bus.
"""
supports_voltage_control(::StaticInjection) = false

get_dynamic_injector(d::StaticInjection) = nothing

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
