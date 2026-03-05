# [Type Structure](@id type_structure)

`PowerSystems.jl` organizes power system data through a type hierarchy built around the
**behavior and role** of each component in the network. Understanding this hierarchy
explains how to retrieve components effectively and how to write code that works across
many different component types without modification.

## Why a type hierarchy?

Power systems contain a wide variety of physical equipment — generators, loads, buses,
transmission lines, transformers, storage devices, and more — each with different data
requirements and modeling roles. Rather than treating all components as untyped records,
`PowerSystems.jl` places them into an abstract type hierarchy. This design provides two
key benefits:

1. **Categorization by behavior:** Components that serve the same modeling role share a
   common abstract supertype. Code can retrieve all components of a given category — all
   generators, all transmission branches — without enumerating every specific technology
   type.

2. **Generic and extensible model logic:** Downstream packages such as
   [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/stable/)
   define optimization formulations against abstract types. A new concrete component type
   slots into existing model formulations automatically, as long as it implements the
   expected interface. This means users can define technologies not yet in the package and
   have them work with existing tools.

## How components are stored

Each infrastructure component is represented as a [`struct`](@ref S) — a composite data
type that bundles together the fields needed to describe that component. For example, an
[`ACBus`](@ref) carries fields for its bus number, nominal voltage, bus type, and more:

```@repl types
using PowerSystems #hide
import TypeTree: tt #hide
docs_dir = joinpath(pkgdir(PowerSystems), "docs", "src", "tutorials", "utils"); #hide
include(joinpath(docs_dir, "docs_utils.jl")); #hide
print_struct(ACBus) #hide
```

Getter and setter functions are generated for every field (e.g., `get_name`,
`get_base_voltage`). Using these functions rather than direct field access is important:
they apply [per-unit conversions](@ref per_unit) automatically and provide a stable
interface across package versions. See the [System](@ref system_doc) explanation for more
details on why direct field access is discouraged.

## The abstract type hierarchy

The hierarchy is rooted at `InfrastructureSystemsType`. The subtypes most relevant to
`PowerSystems.jl` users are:

  - [`System`](@ref): the top-level data container that holds all [`Component`](@ref)s
    and their associated time series data. See the [System](@ref system_doc) explanation
    for a full description.

  - [`Component`](@ref): the abstract supertype for all power system elements:

      + [`Topology`](@ref): non-physical elements that describe network connectivity,
        including [`ACBus`](@ref), [`Arc`](@ref), [`Area`](@ref), and
        [`LoadZone`](@ref). Topology is kept separate from physical devices so that
        network structure can be defined and manipulated independently of the equipment
        attached to it.

      + [`Device`](@ref): physical equipment installed in the network, including
        generators, loads, storage, and transmission branches.

      + [`Service`](@ref): system-level requirements beyond energy balance, such as
        operating reserves, [`AGC`](@ref), and transmission interface limits. Separating
        services from devices reflects the fact that a service is a requirement that
        *devices contribute to*, rather than a physical component itself.

  - [`InfrastructureSystems.DeviceParameter`](@ref): [`struct`](@ref S)s that carry data describing
    the dynamic or economic characteristics of a `Device`, such as cost function curves or
    dynamic machine parameters. Decoupling these from the device [`struct`](@ref S) itself allows the
    same physical device to carry different parameter sets depending on the modeling
    context.

  - [`TimeSeriesData`](@ref): the abstract supertype for all time-varying data associated
    with components:

      + [`Forecast`](@ref): time series where multiple values can represent each time
        stamp, for look-ahead or scenario-based modeling.
      + [`StaticTimeSeries`](@ref): time series with a single value per time stamp, for
        historical or deterministic data.

## How the generation hierarchy illustrates the design

Generation is a useful example of how the hierarchy reflects real modeling distinctions.
Generators are grouped into three abstract super types based on their dispatch behavior and
data requirements:

  - [`ThermalGen`](@ref): dispatchable units with fuel-based costs and startup/shutdown
    characteristics.
  - [`RenewableGen`](@ref): generation driven by a variable resource, with limited or no
    direct dispatch control.
  - [`HydroGen`](@ref): hydro units, which share properties of both dispatchable and
    resource-constrained generation but have unique reservoir and hydrology constraints.

An optimization formulation written against [`ThermalGen`](@ref) applies to `ThermalStandard`,
`ThermalMultiStart`, and any user-defined thermal subtype without modification. This is
the intended extension mechanism: new technologies are introduced by defining a concrete
type under the appropriate abstract supertype.

## What this means for developers

The `PowerSystems.jl` type hierarchy deliberately provides **abstractions without
encoding a specific mathematical model** for any component. The [`struct`](@ref S) for a
`ThermalStandard` generator holds the data describing that unit; it does not prescribe
how the unit should be represented in a particular simulation. The mathematical
formulation is entirely the responsibility of the downstream tool.

This separation allows the same data model to simultaneously support power flow analysis,
production cost modeling, and transient stability simulation through different downstream
packages, without any modification to the underlying data.

For a hands-on introduction to navigating the type hierarchy, see the
[Create and Explore a Power System](@ref "Create and Explore a Power `System`") tutorial.
```
