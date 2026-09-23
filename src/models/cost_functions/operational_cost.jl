"""
Supertype for operational cost representations

Current abstract type for representing operational costs associated with power system devices.
- [`OfferCurveCost`](@ref)

Current concrete types include:
- [`ThermalGenerationCost`](@ref)
- [`HydroGenerationCost`](@ref)
- [`RenewableGenerationCost`](@ref)
- [`StorageCost`](@ref)
- [`LoadCost`](@ref)
- [`ImportExportCost`](@ref)
- [`MarketBidCost`](@ref)
"""
abstract type OperationalCost <: DeviceParameter end

IS.serialize(val::OperationalCost) = IS.serialize_struct(val)
IS.deserialize(T::Type{<:OperationalCost}, val::Dict) = IS.deserialize_struct(T, val)
# NOTE MarketBidCost serialization is handled in serialization.jl
