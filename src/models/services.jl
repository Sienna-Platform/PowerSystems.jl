"""
Supertype for all system services

Services (or ancillary services) include additional requirements and support
to ensure reliable electricity service to customers. Common services are
reserve products to be able to respond quickly to unexpected disturbances,
such as the sudden loss of a transmission line or generator.
"""
abstract type Service <: Component end

"""
Return true since all services support time series data.

# Arguments
- `service::Service`: The service.
"""
supports_time_series(::Service) = true

"""
Return true since all services support supplemental attributes.

# Arguments
- `service::Service`: The service.
"""
supports_supplemental_attributes(::Service) = true
