abstract type DynamicInverterComponent <: DynamicComponent end

"""
Supertype for all power electronic converter models for
[`DynamicInverter`](@ref) components.

Concrete subtypes include [`AverageConverter`](@ref),
[`RenewableEnergyConverterTypeA`](@ref), and
[`RenewableEnergyVoltageConverterTypeA`](@ref).
"""
abstract type Converter <: DynamicInverterComponent end

"""
Supertype for all DC source models for [`DynamicInverter`](@ref) components.

Concrete subtypes include [`FixedDCSource`](@ref) and [`ZeroOrderBESS`](@ref).
"""
abstract type DCSource <: DynamicInverterComponent end

"""
Supertype for all output filter models for [`DynamicInverter`](@ref) components.

Concrete subtypes include [`LCLFilter`](@ref), [`LCFilter`](@ref), and [`RLFilter`](@ref).
"""
abstract type Filter <: DynamicInverterComponent end

"""
Supertype for all frequency estimator models for
[`DynamicInverter`](@ref) components.

Concrete subtypes include [`KauraPLL`](@ref), [`ReducedOrderPLL`](@ref), and
[`FixedFrequency`](@ref).
"""
abstract type FrequencyEstimator <: DynamicInverterComponent end

"""
Supertype for all inner control loop models for
[`DynamicInverter`](@ref) components.

Concrete subtypes include [`VoltageModeControl`](@ref), [`CurrentModeControl`](@ref),
and [`RECurrentControlB`](@ref).
"""
abstract type InnerControl <: DynamicInverterComponent end

"""
Supertype for all output current limiter models for
[`DynamicInverter`](@ref) components.

Concrete subtypes include [`MagnitudeOutputCurrentLimiter`](@ref),
[`InstantaneousOutputCurrentLimiter`](@ref), [`PriorityOutputCurrentLimiter`](@ref),
[`SaturationOutputCurrentLimiter`](@ref), and [`HybridOutputCurrentLimiter`](@ref).
"""
abstract type OutputCurrentLimiter <: DynamicInverterComponent end

abstract type ActivePowerControl <: DeviceParameter end
abstract type ReactivePowerControl <: DeviceParameter end
