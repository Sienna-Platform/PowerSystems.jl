"""
This function add a service to the component without checking if the component and the service are attached to the same system
"""
function add_service_internal!(device::Device, service::Service)
    services = get_services(device)
    for _service in services
        if IS.get_uuid(service) == IS.get_uuid(_service)
            throw(
                ArgumentError(
                    "service $(get_name(service)) is already attached to $(get_name(device))",
                ),
            )
        end
    end

    push!(services, service)
    @debug "Add $service to $(get_name(device))" _group = IS.LOG_GROUP_SYSTEM
end

function add_service_internal!(device::AGC, service::Service)
    reserves = get_reserves(device)
    for _reserve in reserves
        if IS.get_uuid(service) == IS.get_uuid(_reserve)
            throw(
                ArgumentError(
                    "service $(get_name(service)) is already attached to $(get_name(device))",
                ),
            )
        end
    end

    push!(reserves, service)
    @debug "Add $service to $(get_name(device))" _group = IS.LOG_GROUP_SYSTEM
end

"""
Remove a service from a device.

Throws ArgumentError if the service is not attached to the device.
"""
function remove_service!(device::Device, service::Service)
    if !_remove_service!(device, service)
        throw(
            ArgumentError(
                "service $(get_name(service)) was not attached to $(get_name(device))",
            ),
        )
    end
end

"""
Return true if the service is attached to the device.
"""
function has_service(device::Device, service::Service)
    for _service in get_services(device)
        if IS.get_uuid(_service) == IS.get_uuid(service)
            return true
        end
    end

    return false
end

"""
Return true if a service with type T is attached to the device.
"""
function has_service(device::Device, ::Type{T}) where {T <: Service}
    if !supports_services(device)
        return false
    end
    for _service in get_services(device)
        if isa(_service, T)
            return true
        end
    end

    return false
end

has_service(T::Type{<:Service}, device::Device) = has_service(device, T)

"""
Remove service from device if it is attached.
"""
function _remove_service!(device::Device, service::Service)
    removed = false
    services = get_services(device)

    # The expectation is that there won't be many services in each device, and so
    # a faster lookup method is not needed.
    for (i, _service) in enumerate(services)
        if IS.get_uuid(_service) == IS.get_uuid(service)
            deleteat!(services, i)
            removed = true
            @debug "Removed service $(get_name(service)) from $(get_name(device))" _group =
                IS.LOG_GROUP_SYSTEM
            break
        end
    end

    return removed
end

"""
Remove all services attached to the device.
"""
function clear_services!(device::Device)
    if !supports_services(device)
        return
    end
    @debug "Clearing all services from $(get_name(device))" _group = IS.LOG_GROUP_SYSTEM
    services = get_services(device)
    empty!(services)
    return
end

""" Ensures that reservoirs cannot provide services """
supports_services(::HydroReservoir) = false

"""
Remove a hydro turbine from a hydro reservoir.

Throws ArgumentError if the hydro turbine is not attached to the reservoir.
"""
function remove_turbine!(reservoir::HydroReservoir, device::HydroUnit)
    if !_remove_turbine!(reservoir, device)
        throw(
            ArgumentError(
                "turbine $(get_name(device)) was not attached to $(get_name(reservoir))",
            ),
        )
    end
end

"""
Return true if the reservoir has attached the upstream turbine.
"""
function has_upstream_turbine(reservoir::HydroReservoir, turbine::HydroUnit)
    for _turbine in get_upstream_turbines(reservoir)
        if IS.get_uuid(_turbine) == IS.get_uuid(turbine)
            return true
        end
    end

    return false
end

"""
Return true if the reservoir has attached the upstream turbine.
"""
function has_downstream_turbine(reservoir::HydroReservoir, turbine::HydroUnit)
    for _turbine in get_downstream_turbines(reservoir)
        if IS.get_uuid(_turbine) == IS.get_uuid(turbine)
            return true
        end
    end

    return false
end

"""
Return true if any upstream hydro unit is attached to the reservoir.
"""
function has_upstream_turbine(reservoir::HydroReservoir)
    return !isempty(get_upstream_turbines(reservoir))
end

"""
Return true if any downstream hydro unit is attached to the reservoir.
"""
function has_downstream_turbine(reservoir::HydroReservoir)
    return !isempty(get_downstream_turbines(reservoir))
end

"""
Remove turbine from reservoir if it is attached.
"""
function _remove_turbine!(reservoir::HydroReservoir, device::HydroUnit)
    removed = false
    up_turbines = get_upstream_turbines(reservoir)
    down_turbines = get_downstream_turbines(reservoir)

    # The expectation is that there won't be many services in each device, and so
    # a faster lookup method is not needed.
    for (i, _turbine) in enumerate(down_turbines)
        if IS.get_uuid(_turbine) == IS.get_uuid(device)
            deleteat!(down_turbines, i)
            removed = true
            @debug "Removed turbine $(get_name(_turbine)) from $(get_name(reservoir))" _group =
                IS.LOG_GROUP_SYSTEM
            break
        end
    end

    if !removed
        for (i, _turbine) in enumerate(up_turbines)
            if IS.get_uuid(_turbine) == IS.get_uuid(device)
                deleteat!(up_turbines, i)
                removed = true
                @debug "Removed turbine $(get_name(_turbine)) from $(get_name(reservoir))" _group =
                    IS.LOG_GROUP_SYSTEM
                break
            end
        end
    end

    return removed
end

"""
Remove all turbines attached to the reservoir.
"""
function clear_turbines!(device::HydroReservoir)
    turbines = get_upstream_turbines(device)
    empty!(turbines)
    turbines = get_downstream_turbines(device)
    empty!(turbines)
    return
end
