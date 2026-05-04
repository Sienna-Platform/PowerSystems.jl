"""
$(TYPEDEF)
$(TYPEDFIELDS)

    LoadCost(variable, fixed)
    LoadCost(; variable, fixed)

An operational cost for controllable loads (e.g., InterruptiblePowerLoad), including
fixed and variable cost components.

The `variable` cost is a required parameter, but `zero(CostCurve)` can be used to set it to 0.
"""
@kwdef mutable struct LoadCost <: OperationalCost
    "Variable cost represented as a [`CostCurve`](@ref)"
    variable::CostCurve
    "(default: 0) Fixed cost. For some cost represenations this field can be
    duplicative"
    fixed::Float64
end

# Constructor for demo purposes; non-functional.
LoadCost(::Nothing) = LoadCost(zero(CostCurve), 0.0)

"""Return the `variable` field of [`LoadCost`](@ref)."""
get_variable(value::LoadCost) = value.variable
"""Return the `fixed` field of [`LoadCost`](@ref)."""
get_fixed(value::LoadCost) = value.fixed

"""Set the `variable` field of [`LoadCost`](@ref)."""
set_variable!(value::LoadCost, val) = value.variable = val
"""Set the `fixed` field of [`LoadCost`](@ref)."""
set_fixed!(value::LoadCost, val) = value.fixed = val
