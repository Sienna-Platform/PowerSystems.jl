# [Dynamic Devices](@id dynamic_data)

A **dynamic device** is a power system component whose behavior is described by differential equations that evolve over time, rather than by a single steady-state operating point. Dynamic devices capture the [transient response](https://en.wikipedia.org/wiki/Transient_response) of equipment — such as how a generator's rotor speed, voltage, or current changes in the milliseconds to seconds following a disturbance. In `PowerSystems.jl`, every dynamic device is attached to a corresponding [static](@ref S) component that provides the power flow
solution, while the dynamic component adds the differential equations needed for transient stability and electromagnetic simulation.

A dynamic device has two data layers, the static data layer with static components, and the dynamic data layer with dynamic components.

## Static and Dynamic Data Layers

`PowerSystems.jl` uses two categories to define data for dynamic simulations:

 1. [Static](@ref S) components, which includes the data needed to run a power flow problem
 2. [Dynamic](@ref D) components are those that define differential equations to run a transient simulation. **These dynamic data are attached to the static components.**

Although `PowerSystems.jl` is not constrained to only PSS/e files, commonly the data for a dynamic simulation comes in a pair of files: One for the static data power flow case (e.g.,`.raw` file) and a second one with the dynamic components information (e.g., `.dyr` file). However, `PowerSystems.jl` is able to take any power flow case and specify dynamic components to it. The two data layers in `PowerSystems.jl`, static components and dynamic components, are similar to the data division between the static and dynamic data layers.

### Layer 1: Static Components

The first data layer contains all the information necessary to run a power flow problem or dynamic simulations:

  - Vector of `Bus` elements, that define all the buses in the network.
  - Vector of `Branch` elements, that define all the branches elements (that connect two buses) in the network.
  - Vector of [`StaticInjection`](@ref) elements, that define all the devices connected to buses that can inject (or withdraw) power. These static devices, typically generators, in [`PowerSimulationsDynamics`](https://nrel-sienna.github.io/PowerSimulationsDynamics.jl/stable/) are used to solve the power flow problem that determines the active and reactive power provided for each device.
  - Vector of [`PowerLoad`](@ref) elements, that define all the loads connected to buses that can withdraw current. These are also used to solve power flow.
  - Vector of `Source` elements, that define source components behind a reactance that can inject or withdraw current.
  - The base of power used to define per unit values, in MVA as a `Float64` value. See [Per-unit Conventions](@ref per_unit).
  - The base frequency used in the system, in Hz as a `Float64` value.

For a hands-on example of building a system with static components, see the [Creating a System](../tutorials/generated_creating_system.md) tutorial.

Once the static layer establishes the network topology and the power flow equilibrium, the dynamic layer can be overlaid on top of it — adding the differential equations that describe how each device behaves when that equilibrium is disturbed.

### Layer 2: Dynamic Components

The second data layer contains the *additional* information describing the dynamic response of certain components in the `System`. This data is all attached to components defined in the static data layer:

  - (Optional) Selecting which of the `Lines` (of the `Branch` vector) elements must be modeled of `DynamicLines` elements, that can be used to model lines with differential equations.
  - Vector of [`DynamicInjection`](@ref) elements. These components must be attached to a [`StaticInjection`](@ref) that connects the power flow solution to the dynamic formulation of such device.

[`DynamicInjection`](@ref) can be [`DynamicGenerator`](@ref) or [`DynamicInverter`](@ref), and its specific formulation (i.e. differential equations) will depend on the specific components that define each device (see the sections below). As
a result, it is possible to flexibly define dynamic data models and methods according to the analysis requirements. [`DynamicInjection`](@ref) components use a parametric type pattern to materialize the full specification of the dynamic injection model with parameters. This design enables the use of parametric methods to specify the mathematical
model of the dynamic components separately.

[`DynamicInjection`](@ref) components also implement some additional information useful for the modeling, like the usual states assumed by the model and the number of states. These values are derived from the documentation associated with the model, for instance PSS/e models provide parameters, states and variables. Although `PowerSystems.jl` doesn't assume a specific mathematical model for the components, the default values for these parameters are derived directly from the data model source.

The two concrete forms of [`DynamicInjection`](@ref) — [`DynamicGenerator`](@ref) and [`DynamicInverter`](@ref) — reflect the two fundamentally different physical mechanisms by which machines couple to the grid: rotating synchronous machines and power-electronics-based converters. Each has its own set of sub-components corresponding to the physical and control processes that govern its dynamic behavior.

## Dynamic Generator Structure

Each generator is a data structure that is defined by the following components:

  - [Machine](@ref Machine): That defines the stator electro-magnetic dynamics.
  - [Shaft](@ref Shaft): That describes the rotor electro-mechanical dynamics.
  - [Automatic Voltage Regulator](@ref AVR): Electromotive dynamics to model an AVR controller.
  - [Power System Stabilizer](@ref PSS): Control dynamics to define an stabilization signal for the AVR.
  - [Prime Mover and Turbine Governor](@ref TurbineGov): Thermo-mechanical dynamics and associated controllers.

Where a synchronous generator's dynamics are rooted in the physics of a rotating mass and magnetic flux, an inverter-based resource has no rotating components — its dynamic behavior is instead shaped entirely by its control algorithms and power electronics. This calls for a different set of sub-components.

## Dynamic Inverter Structure

Each inverter is a data structure that is defined by the following components:

  - [DC Source](@ref DCSource): Defines the dynamics of the DC side of the converter.
  - [Frequency Estimator](@ref FrequencyEstimator): That describes how the frequency of the grid can be estimated using the grid voltages. Typically a phase-locked loop (PLL).
  - [Outer Loop Control](@ref OuterControl): That describes the active and reactive power control dynamics.
  - [Inner Loop Control](@ref InnerControl): That can describe virtual impedance, voltage control, and current control dynamics.
  - [Converter](@ref Converter): That describes the dynamics of the pulse width modulation (PWM) or space vector modulation (SVM).
  - [Filter](@ref Filter): Used to connect the converter output to the grid.⠀

For a hands-on example of constructing and attaching dynamic generator and inverter components to a system, see the [Adding Dynamic Data](../tutorials/generated_add_dynamic_data.md) tutorial.

```
```
