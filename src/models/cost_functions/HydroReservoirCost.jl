"""
$(TYPEDEF)
$(TYPEDFIELDS)

    HydroReservoirCost(level_shortage_cost, level_surplus_cost, spillage_cost)
    StorageCost(; level_shortage_cost, level_surplus_cost, spillage_cost)

An operational cost for hydro reservoirs including shortage and surplus costs for
reservoir levels and spillage costs.
"""
@kwdef mutable struct HydroReservoirCost <: OperationalCost
    "(default: 0) Cost incurred by the model for being short of the reservoir level target"
    level_shortage_cost::Float64 = 0.0
    "(default: 0) Cost incurred by the model for surplus of the reservoir level target"
    level_surplus_cost::Float64 = 0.0
    "(default: 0) Cost incurred by the model for spillage of the reservoir"
    spillage_cost::Float64 = 0.0
end

# Constructor for demo purposes; non-functional.
function HydroReservoirCost(::Nothing)
    HydroReservoirCost()
end

"""Get [`HydroReservoirCost`](@ref) `level_shortage_cost`."""
get_level_shortage_cost(value::HydroReservoirCost) = value.level_shortage_cost
"""Get [`HydroReservoirCost`](@ref) `level_surplus_cost`."""
get_level_surplus_cost(value::HydroReservoirCost) = value.level_surplus_cost
"""Get [`HydroReservoirCost`](@ref) `spillage_cost`."""
get_spillage_cost(value::HydroReservoirCost) = value.spillage_cost

"""Set [`HydroReservoirCost`](@ref) `level_shortage_cost`."""
set_level_shortage_cost!(value::HydroReservoirCost, val) =
    value.level_shortage_cost = val
"""Set [`HydroReservoirCost`](@ref) `level_surplus_cost`."""
set_level_surplus_cost!(value::HydroReservoirCost, val) =
    value.level_surplus_cost = val
"""Set [`HydroReservoirCost`](@ref) `spillage_cost`."""
set_spillage_cost!(value::HydroReservoirCost, val) =
    value.spillage_cost = val
