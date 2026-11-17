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
Supertype for all reference frame rotation (frequency estimator) models for
[`DynamicInverter`](@ref) components.

Concrete subtypes include [`KauraPLL`](@ref), [`ReducedOrderPLL`](@ref), and
[`FixedFrequency`](@ref).
"""
abstract type ReferenceFrameRotation <: DynamicInverterComponent end

"""
Supertype for all inner control loop models for
[`DynamicInverter`](@ref) components.

Concrete subtypes include [`VoltageModeControl`](@ref), [`CurrentModeControl`](@ref),
and [`RECurrentControlB`](@ref).
"""
abstract type InnerControl <: DynamicInverterComponent end

"""
Supertype for all current limitation models for
[`DynamicInverter`](@ref) components.

Concrete subtypes include [`MagnitudeOutputCurrentLimiter`](@ref),
[`InstantaneousOutputCurrentLimiter`](@ref), [`PriorityOutputCurrentLimiter`](@ref),
[`SaturationOutputCurrentLimiter`](@ref), and [`HybridOutputCurrentLimiter`](@ref).
"""
abstract type CurrentLimitation <: DynamicInverterComponent end

"""
Supertype for all outer-loop active power control models for
[`DynamicInverter`](@ref) components.

Concrete subtypes include [`ActivePowerDroop`](@ref), [`ActivePowerPI`](@ref),
[`ActiveRenewableControllerAB`](@ref), [`ActiveVirtualOscillator`](@ref), and
[`VirtualInertia`](@ref).
"""
abstract type ActivePowerControl <: DynamicInverterComponent end

"""
Supertype for all outer-loop reactive power control models for
[`DynamicInverter`](@ref) components.

Concrete subtypes include [`ReactivePowerDroop`](@ref), [`ReactivePowerPI`](@ref),
[`ReactiveRenewableControllerAB`](@ref), and [`ReactiveVirtualOscillator`](@ref).
"""
abstract type ReactivePowerControl <: DynamicInverterComponent end
