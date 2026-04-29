# [Use Subsystems](@id use_subsystems)

For certain applications, such as those that employ dispatch coordination methods or
decomposition approaches, it is useful to split components into subsystems based on
user-defined criteria. The [`System`](@ref) provides `subsystem` containers for this
purpose. Each subsystem is defined by a name and can hold references to any number of
components. For background on the `System` container, see [System](@ref system_doc).

## Create subsystems and add components

Load a `System`, then call [`add_subsystem!`](@ref) to register named subsystems:

```@example subsystem
using PowerSystems;
using PowerSystemCaseBuilder;
sys = build_system(PSISystems, "c_sys5_pjm")
add_subsystem!(sys, "1")
add_subsystem!(sys, "2")
```

Assign devices to subsystems using [`add_component_to_subsystem!`](@ref):

```@example subsystem
g = get_component(ThermalStandard, sys, "Alta")
add_component_to_subsystem!(sys, "1", g)

g = get_component(ThermalStandard, sys, "Sundance")
add_component_to_subsystem!(sys, "2", g)
```

## Retrieve components from a subsystem

Pass the `subsystem_name` keyword argument to [`get_components`](@ref) to filter by
subsystem:

```@example subsystem
gens_1 = get_components(ThermalStandard, sys; subsystem_name = "1")
get_name.(gens_1)

gens_2 = get_components(ThermalStandard, sys; subsystem_name = "2")
get_name.(gens_2)
```

# !!! tip

# The get_name. command may look like a way to use `.` to access the fields of a component, which is method actively discouraged by the Sienna team, however it is a [broadcast function](https://blog.glcs.io/broadcasting) in Julia.

## Export a subsystem as a new `System`

[`from_subsystem`](@ref) produces a new, standalone [`System`](@ref) from the components
assigned to a subsystem. This requires careful assignment of all dependencies — not just
the devices themselves, but also any topology elements (buses, arcs) they reference.

```@example subsystem
from_subsystem(sys, "1"; runchecks=false)
```

!!! warning

    The system above was created with `runchecks=false` and is technically invalid: the bus
    connected to the Alta generator is not part of subsystem "1". Without `runchecks=false`,
    this call would raise an error. Add the bus first, then re-run [`from_subsystem`](@ref):

A valid exported `System` requires three additional components:

  - **The generator's bus** (`nodeA`) — every device must have its connected bus present in
    the subsystem.
  - **A reference (slack) bus** (`nodeD`) — at least one [`ACBus`](@ref) with
    `bustype = ACBusTypes.REF` must be present for the system to pass validation.
  - **An [`ElectricLoad`](@ref)** — a subsystem with no load components triggers a
    validation warning. Adding the [`PowerLoad`](@ref) connected to the slack bus
    satisfies this requirement.

```@example subsystem
g = get_component(ThermalStandard, sys, "Alta")
b = get_bus(g)
add_component_to_subsystem!(sys, "1", b)
ref_bus = get_component(ACBus, sys, "nodeD")
add_component_to_subsystem!(sys, "1", ref_bus)
load = first(get_components(x -> get_bus(x) === ref_bus, PowerLoad, sys))
add_component_to_subsystem!(sys, "1", load)
from_subsystem(sys, "1")
```

Advanced users can pass `runchecks=false` to skip topological validation. Only do this
if you are confident you can validate the resulting system before using it for modeling.
