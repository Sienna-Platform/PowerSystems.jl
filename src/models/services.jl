"""
Abstract supertype for all system services (ancillary services).

Services represent additional requirements and support to ensure reliable electricity
delivery. Examples include reserve products for responding to unexpected disturbances
(such as the sudden loss of a generator or transmission line), automatic generation
control, and transmission interface limits.

Subtypes: [`AbstractReserve`](@ref), [`AGC`](@ref), [`TransmissionInterface`](@ref)
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
