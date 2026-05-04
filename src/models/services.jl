"""
    Service

Abstract supertype for all system services (ancillary services).

Services represent additional requirements and support to ensure reliable electricity
delivery. Examples include reserve products for responding to unexpected disturbances
(such as the sudden loss of a generator or transmission line), automatic generation
control, and transmission interface limits.

Subtypes: [`AbstractReserve`](@ref), [`AGC`](@ref), [`TransmissionInterface`](@ref)
"""
abstract type Service <: Component end

"""
Return true since all [`Service`](@ref) types support time series by default.

Override this method for custom types that do not support time series.
"""
supports_time_series(::Service) = true

"""
Return true since all [`Service`](@ref) types support supplemental attributes by default.

Override this method for custom service types that do not support supplemental attributes.
"""
supports_supplemental_attributes(::Service) = true
