# [How to use supplemental attributes](@id use_supplemental_attributes_how_to)

This how-to assumes you have a `System` named `sys` with at least one `FixedForcedOutage` supplemental attribute attached to a component. See [Add Supplemental Attributes to a System](@ref add_supplemental_attributes) if you need to set that up first.

## Get the attributes in a system

Use [`get_supplemental_attributes`](@ref) with a supplemental attribute type to retrieve all matching attributes from a system.

```@repl use_supplemental_attributes
using PowerSystems

for outage in get_supplemental_attributes(FixedForcedOutage, sys)
    @show summary(outage)
end
```

The output includes the attribute type name and its [UUID](@ref U) — a unique identifier automatically assigned when the attribute was created.

Pass a filter function as the first argument to narrow results by field values.

```@repl use_supplemental_attributes
using PowerSystems

for outage in get_supplemental_attributes(
    x -> PowerSystems.get_outage_status(x) >= 0.5,
    FixedForcedOutage,
    sys,
)
    @show summary(outage)
end
```

## Get the attributes associated with a component

Use [`get_supplemental_attributes`](@ref) with a component instead of a system to retrieve only the attributes attached to that component.

```@repl use_supplemental_attributes
using PowerSystems

gen1 = first(get_components(ThermalStandard, sys))
for outage in get_supplemental_attributes(FixedForcedOutage, gen1)
    @show summary(outage)
end
```

The output includes the attribute type name and its [UUID](@ref U).

Pass a filter function as the first argument to narrow results by field values.

```@repl use_supplemental_attributes
using PowerSystems

for outage in get_supplemental_attributes(
    x -> PowerSystems.get_outage_status(x) >= 0.5,
    FixedForcedOutage,
    gen1,
)
    @show summary(outage)
end
```

## Get the components associated with an attribute

Use [`get_associated_components`](@ref) to retrieve the components attached to a single supplemental attribute.

 1. Get all components associated with a single supplemental attribute.

    ```@repl use_supplemental_attributes
    using PowerSystems
    
    outage = first(get_supplemental_attributes(FixedForcedOutage, sys))
    for component in get_associated_components(sys, outage)
        @show summary(component)
    end
    ```

    The output is the FixedForceOutage type and name.

 2. Same as the previous, but filter the results by component type.

    ```@repl use_supplemental_attributes
    using PowerSystems
    
    outage = first(get_supplemental_attributes(FixedForcedOutage, sys))
    for component in get_associated_components(sys, outage; component_type = ThermalStandard)
        @show summary(component)
    end
    ```

    In this how-to, both of the FixedForceOutages only have the component_type = ThermalStandard, so no results are filtered out by the component_type filter.

    ## Get component / supplemental attribute pairs

    Use [`get_component_supplemental_attribute_pairs`](@ref) to retrieve component/attribute pairs by type. Prefer this over nested loops iterating over components and their attributes separately.

    ```@repl use_supplemental_attributes
    using PowerSystems
    
    for (gen, outage) in get_component_supplemental_attribute_pairs(
        ThermalStandard,
        FixedForcedOutage,
        sys,
    )
        @show summary(gen) summary(outage)
    end
    ```

    The output is a summary of the component_type and the UUID of the FixedForceOutage.
