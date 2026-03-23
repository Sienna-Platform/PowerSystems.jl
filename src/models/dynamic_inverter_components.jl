abstract type DynamicInverterComponent <: DynamicComponent end
abstract type Converter <: DynamicInverterComponent end
abstract type DCSource <: DynamicInverterComponent end
abstract type Filter <: DynamicInverterComponent end
abstract type FrequencyEstimator <: DynamicInverterComponent end
abstract type InnerControl <: DynamicInverterComponent end
abstract type OutputCurrentLimiter <: DynamicInverterComponent end

"""
    ActivePowerControl

Supertype for all active power control models used in [`OuterControl`](@ref) of a
[`DynamicInverter`](@ref).

Concrete subtypes include [`ActivePowerDroop`](@ref), [`ActivePowerPI`](@ref),
[`VirtualInertia`](@ref), [`ActiveVirtualOscillator`](@ref), and
[`ActiveRenewableControllerAB`](@ref).

See also: [`ReactivePowerControl`](@ref), [`OuterControl`](@ref)
"""
abstract type ActivePowerControl <: DeviceParameter end

"""
    ReactivePowerControl

Supertype for all reactive power control models used in [`OuterControl`](@ref) of a
[`DynamicInverter`](@ref).

Concrete subtypes include [`ReactivePowerDroop`](@ref), [`ReactivePowerPI`](@ref),
[`ReactiveVirtualOscillator`](@ref), and [`ReactiveRenewableControllerAB`](@ref).

See also: [`ActivePowerControl`](@ref), [`OuterControl`](@ref)
"""
abstract type ReactivePowerControl <: DeviceParameter end
