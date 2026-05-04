# [Add Supplemental Attributes to a System](@id add_supplemental_attributes)

This how-to shows how to attach supplemental attributes to components in a [`System`](@ref).
It uses [`FixedForcedOutage`](@ref) as the example attribute type.

## Prerequisites

```@example add_supplemental_attributes
using PowerSystems
using PowerSystemCaseBuilder

sys = build_system(PSISystems, "c_sys5_pjm")
```

## Add a single supplemental attribute

Retrieve the target component, construct the attribute, then attach it with
[`add_supplemental_attribute!`](@ref):

```@example add_supplemental_attributes
gen = first(get_components(ThermalStandard, sys))
outage = FixedForcedOutage(; outage_status = 0.0)  # 0.0 = available, 1.0 = outaged
add_supplemental_attribute!(sys, gen, outage)
```

## Add supplemental attributes in bulk

For adding many attributes at once, use [`begin_supplemental_attributes_update`](@ref)
to batch the operations. This reduces index update overhead and automatically reverts
all changes if an error occurs:

```@example add_supplemental_attributes
gens = collect(get_components(ThermalStandard, sys))
gen1 = gens[1]
gen2 = gens[2]
outage1 = FixedForcedOutage(; outage_status = 0.0)
outage2 = FixedForcedOutage(; outage_status = 1.0)

begin_supplemental_attributes_update(sys) do
    add_supplemental_attribute!(sys, gen1, outage1)
    add_supplemental_attribute!(sys, gen2, outage2)
end
```

## Share one attribute across multiple components

Attach the same attribute instance to more than one component to model shared properties:

```@example add_supplemental_attributes
outage = FixedForcedOutage(; outage_status = 1.0)
gens = collect(get_components(ThermalStandard, sys))
gen1 = gens[1]
gen2 = gens[2]

begin_supplemental_attributes_update(sys) do
    add_supplemental_attribute!(sys, gen1, outage)
    add_supplemental_attribute!(sys, gen2, outage)
end
```

## Next steps

See [How to use supplemental attributes](@ref use_supplemental_attributes_how_to) to query
and filter the attributes you have added.
