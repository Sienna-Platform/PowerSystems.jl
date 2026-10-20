"""
Supertype for unexpected events that can be attached to components as supplemental
attributes, such as unplanned outages. Events of this type drive runtime event models and
post-contingency (N-1) constraints in downstream packages.

Concrete subtypes include [`UnplannedOutage`](@ref) and its descendants.
"""
abstract type Contingency <: SupplementalAttribute end
