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
All PowerSystems [Service](@ref) types support time series. This can be overridden for custom 
types that do not support time series.
"""
supports_time_series(::Service) = true

"""
All PowerSystems [Service](@ref) types support supplemental attributes. This can be overridden for 
custom service types that do not support supplemental attributes.
"""
supports_supplemental_attributes(::Service) = true
