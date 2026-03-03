# [System](@id system_doc)

## What is a `System`?

The [`System`](@ref) is the central data container in `PowerSystems.jl`. It holds all
[`Component`](@ref)s — the objects that describe the physical and logical elements of a
power network — together with references to any associated time series data. For the most
basic walkthrough of creating a system from scratch, see the
[Create and Explore a Power System](@ref "Create and Explore a Power `System`") tutorial.

`PowerSystems.jl` uses a hybrid approach to data storage: component data and time series
references are stored in volatile memory, while the actual time series data is stored in
an HDF5 file. This design loads only the portions of the data that are relevant at the
time of the query, avoiding unnecessary memory overhead for large datasets.

```@raw html
<img src="../../assets/System.png" style="zoom: 150%;"/>
```

## What is a `Component`?

A [`Component`](@ref) is any element of a power system model — generators, loads, buses,
transmission lines, services, and more. Every component in `PowerSystems.jl` belongs to an
abstract type hierarchy that organizes components by their role in the system (see
[Type Structure](@ref type_structure) for details).

A key constraint of the data model is that **a component instance can belong to at most
one `System` at a time**. Adding a component to a second `System` without first removing
it from the first will raise an error. This ensures that ownership of component data is
unambiguous and prevents silent aliasing between systems.

## Accessing components stored in the `System`

`PowerSystems.jl` implements a wide variety of methods to search for components to
aid in data manipulation. Most of these use the [Type Structure](@ref type_structure) to
retrieve all components of a certain `Type`.

The most common retrieval function is [`get_components`](@ref), which accepts a concrete or
abstract component `Type` and returns all matching components from the `System`. It also
accepts filter functions for more refined searches.

Because a system can contain a large number of components, `PowerSystems.jl` returns
Julia iterators rather than materialized collections, avoiding unnecessary memory
allocations. The container is internally optimized for iteration over both abstract and
concrete component types.

## [Accessing data stored in a component](@id dot_access)

__Using the "dot" access to get a parameter value from a component is actively discouraged, use getter functions instead__

Using code autogeneration, `PowerSystems.jl` implements getter functions to
enable the retrieval of parameters defined in the component struct fields. Julia syntax enables
access to this data using the "dot" access (e.g. `component.field`), however
_this is actively discouraged_ for two reasons:

 1. We make no guarantees on the stability of component structure definitions. We will maintain version stability on the getter methods.
 2. Per-unit conversions are made in the return of data from the getter functions. (see the [per-unit section](@ref per_unit) for more details)

## Subsystems

The `System` also supports partitioning components into named *subsystems*, which is
useful for decomposition approaches or dispatch coordination workflows. For a hands-on walkthrough of working with a `System`, its components, and the accessor functions, see the
[Manipulating Datasets](@ref "Manipulating Datasets") tutorial. For a step-by-step guide, see [Use subsystems](@ref use_subsystems).
