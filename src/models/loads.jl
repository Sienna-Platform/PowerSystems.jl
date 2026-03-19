"""
    ElectricLoad

Supertype for all electric loads.

Electric loads consume power from the grid. Abstract subtypes include
[`StaticLoad`](@ref) (fixed consumption) and [`ControllableLoad`](@ref) (adjustable
consumption). The concrete subtype [`FixedAdmittance`](@ref) and
[`SwitchedAdmittance`](@ref) also inherit directly from `ElectricLoad`.

See also: [`StaticInjection`](@ref), [`StaticLoad`](@ref), [`ControllableLoad`](@ref)
"""
abstract type ElectricLoad <: StaticInjection end

"""
    StaticLoad

Supertype for all static electric loads.

Static loads have fixed consumption that cannot be controlled or curtailed. Concrete
subtypes include [`PowerLoad`](@ref), [`StandardLoad`](@ref), [`ExponentialLoad`](@ref),
and [`MotorLoad`](@ref).

See also: [`ElectricLoad`](@ref), [`ControllableLoad`](@ref)
"""
abstract type StaticLoad <: ElectricLoad end

"""
    ControllableLoad

Supertype for all controllable electric loads.

Controllable loads can have their consumption adjusted in response to system conditions
or operator dispatch. Concrete subtypes include [`InterruptiblePowerLoad`](@ref),
[`InterruptibleStandardLoad`](@ref), and [`ShiftablePowerLoad`](@ref).

See also: [`StaticLoad`](@ref), [`ElectricLoad`](@ref)
"""
abstract type ControllableLoad <: StaticLoad end
