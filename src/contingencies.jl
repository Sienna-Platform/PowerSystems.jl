"""
Supertype for contingency events that can be attached to components as supplemental
attributes.

Concrete subtypes include [`Outage`](@ref) and its descendants.
"""
abstract type Contingency <: SupplementalAttribute end
