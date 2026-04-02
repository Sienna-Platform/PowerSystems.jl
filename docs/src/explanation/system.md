# [System](@id system_doc)

The `System` is the main container of components and the time series data references.
`PowerSystems.jl` uses a hybrid approach to data storage, where the component data and time
series references are stored in volatile memory while the actual time series data is stored
in an HDF5 file. This design loads into memory the portions of the data that are relevant
at time of the query, and so avoids overwhelming the memory resources.

```@raw html
<img src="../../assets/System.png" width="50%"/>
```

## Accessing components stored in the `System`

`PowerSystems.jl` implements a wide variety of methods to search for components to
aid in data manipulation. Most of these use the [Type Structure](@ref type_structure) to
retrieve all components of a certain `Type`.

For example, the most common search function is [`get_components`](@ref), which
takes a desired device `Type` (concrete or abstract) and retrieves all components in that
category from the `System`. It also accepts filter functions for a more
refined search.

Given the potential size of the return,
`PowerSystems.jl` returns Julia iterators in order to avoid unnecessary memory allocations.
The container is optimized for iteration over abstract or concrete component
types as described by the [Type Structure](@ref type_structure).

## [Accessing data stored in a component](@id dot_access)

__Using the "dot" access to get a parameter value from a component is actively discouraged, use "getter" functions instead__

Using code autogeneration, `PowerSystems.jl` implements accessor (or "getter") functions to
enable the retrieval of parameters defined in the component struct fields. Julia syntax enables
access to this data using the "dot" access (e.g. `component.field`), however
_this is actively discouraged_ for two reasons:

 1. We make no guarantees on the stability of component structure definitions. We will maintain version stability on the accessor methods.
 2. Per-unit conversions are made in the return of data from the accessor functions. (see the [per-unit section](@ref per_unit) for more details)

## [Using subsystems](@id subsystems)

For certain applications, such as those that employ dispatch coordination methods or decomposition approaches, it is useful to be able to split components into subsystems based upon user-defined criteria. The  `System` provides `subsystem` containers for this purpose. Each subsystem is defined by a name and can hold references to any number of components.

The following commands demonstrate how to create subsystems and add components.

```@repl subsystem
using PowerSystems;
using PowerSystemCaseBuilder;
sys = build_system(PSISystems, "c_sys5_pjm")
add_subsystem!(sys, "1")
add_subsystem!(sys, "2")
```

Devices in the system can be assigned to the subsystems in the following way using the function [`add_component_to_subsystem!`](@ref)

```@repl subsystem
g = get_component(ThermalStandard, sys, "Alta")
add_component_to_subsystem!(sys, "1", g)

g = get_component(ThermalStandard, sys, "Sundance")
add_component_to_subsystem!(sys, "2", g)
```

To retrieve components assigned to a specific subsystem, add the `subsystem_name` keyword argument to `get_components`.

```@repl subsystem
gens_1 = get_components(ThermalStandard, sys; subsystem_name = "1")
get_name.(gens_1)

gens_2 = get_components(ThermalStandard, sys; subsystem_name = "2")
get_name.(gens_2)
```

One useful feature that requires care when used is generating a new [`System`](@ref) from a `subsystem` assignment.

The function [`from_subsystem`](@ref) will allow the user to produce a new [`System`](@ref) that can be used or exported.
This functionality requires careful subsystem assignemnt of the devices and its dependencies. Following from the example in this document, you can export a system as follows:

```@repl subsystem
from_subsystem(sys, "1")
```

!!! warning

    The system is invalid because the bus connected to the Alta generator is not part of the subsystem. We can add it, and then run [`from_subsystem`](@ref) again

```@repl subsystem
g = get_component(ThermalStandard, sys, "Alta")
b = get_bus(g)
add_component_to_subsystem!(sys, "1", b)
from_subsystem(sys, "1")
```

Advanced users can use the keyword `runchecks=false` and avoid any topological check in the process.
It is highly recommended that users only do this if they clearly understand how to validate the resulting system before using it for modeling.
