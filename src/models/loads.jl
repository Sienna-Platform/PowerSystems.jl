"""
Supertype for all electric loads

Electric loads consume power from the grid. Subtypes are categorized by whether
they are static or controllable.
"""
abstract type ElectricLoad <: StaticInjection end

"""
Supertype for all [static](@ref S) electric loads

Static loads have fixed consumption that cannot be controlled or curtailed.
"""
abstract type StaticLoad <: ElectricLoad end

"""
Supertype for all controllable loads

Controllable loads can have their consumption adjusted in response to system
conditions or operator dispatch.
"""
abstract type ControllableLoad <: StaticLoad end
