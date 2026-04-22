"""
$(TYPEDEF)
$(TYPEDFIELDS)

    HydroGenerationCost(variable, fixed)
    HydroGenerationCost(; variable, fixed)

An operational cost of a hydropower generator which includes fixed and
variable cost. Variable costs can be used to represent the cost of curtailment if negative
values are used or the opportunity cost of water if the costs are positive. It also supports
fuel curves to model specific water intake. 

The `variable` cost is a required parameter, but `zero(CostCurve)` can be used to set it to 0.
"""
@kwdef mutable struct HydroGenerationCost <: OperationalCost
    "Production variable cost represented by a `FuelCurve`, where the fuel is water,
    or a `CostCurve` in currency."
    variable::ProductionVariableCostCurve
    "(default: 0) Fixed cost of keeping the unit online. For some cost represenations this
    field can be duplicative"
    fixed::Float64
end

# Constructor for demo purposes; non-functional.
HydroGenerationCost(::Nothing) = HydroGenerationCost(zero(CostCurve), 0.0)

"""Return the `variable` field of [`HydroGenerationCost`](@ref)."""
get_variable(value::HydroGenerationCost) = value.variable
"""Return the `fixed` field of [`HydroGenerationCost`](@ref)."""
get_fixed(value::HydroGenerationCost) = value.fixed

"""Set the `variable` field of [`HydroGenerationCost`](@ref)."""
set_variable!(value::HydroGenerationCost, val) = value.variable = val
"""Set the `fixed` field of [`HydroGenerationCost`](@ref)."""
set_fixed!(value::HydroGenerationCost, val) = value.fixed = val
