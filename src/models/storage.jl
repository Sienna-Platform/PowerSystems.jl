"""
    Storage

Abstract supertype for energy storage technologies.

Storage devices can both inject and absorb power from the grid. Concrete subtypes
include [`EnergyReservoirStorage`](@ref) and [`HybridSystem`](@ref).

See also: [`StaticInjection`](@ref)
"""
abstract type Storage <: StaticInjection end
