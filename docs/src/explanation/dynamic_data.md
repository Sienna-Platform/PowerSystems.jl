# Dynamic Devices

## Static and Dynamic Data Layers

`PowerSystems.jl` uses two categories to define data for dynamic simulations:

 1. [Static](@ref S) components, which includes the data needed to run a power flow problem
 2. [Dynamic](@ref D) components are those that define differential equations to run a transient simulation. These dynamic
    data are attached to the static components.

Although `PowerSystems.jl` is not constrained to only PSS/e files, commonly the data for a
dynamic simulation comes in a pair of files: One for the static data power flow case (e.g.,
`.raw` file) and a second one with the dynamic components information (e.g., `.dyr` file).
However, `PowerSystems.jl` is able to take any power flow case and specify dynamic
components to it. The two data layers in `PowerSystems.jl` are similar to the data
division between those two files.

### Layer 1: Static Components

The first data layer contains all the information necessary to run a power flow problem:

  - Vector of `Bus` elements, that define all the buses in the network.
  - Vector of `Branch` elements, that define all the branches elements (that connect two buses) in the network.
  - Vector of `StaticInjection` elements, that define all the devices connected to buses that can inject (or withdraw) power. These static devices, typically generators, in `PowerSimulationsDynamics` are used to solve the Power Flow problem that determines the active and reactive power provided for each device.
  - Vector of `PowerLoad` elements, that define all the loads connected to buses that can withdraw current. These are also used to solve the Power Flow.
  - Vector of `Source` elements, that define source components behind a reactance that can inject or withdraw current.
  - The base of power used to define per unit values, in MVA as a `Float64` value.
  - The base frequency used in the system, in Hz as a `Float64` value.

### Layer 2: Dynamic Components

The second data layer contains the *additional* information describing the dynamic response
of certain components in the `System`. This data is all attached to components defined in
the static data layer:

  - (Optional) Selecting which of the `Lines` (of the `Branch` vector) elements must be modeled of `DynamicLines` elements, that can be used to model lines with differential equations.
  - Vector of `DynamicInjection` elements. These components must be attached to a `StaticInjection` that connects the power flow solution to the dynamic formulation of such device.

`DynamicInjection` can be `DynamicGenerator` or `DynamicInverter`, and its specific formulation (i.e. differential equations) will depend on the specific components that define each device (see the sections below). As
a result, it is possible to flexibly define dynamic data models and methods according to
the analysis requirements. [`DynamicInjection`](@ref) components use a parametric
type pattern to materialize the full specification of the dynamic injection model with
parameters. This design enable the use of parametric methods to specify the mathematical
model of the dynamic components separately.

[`DynamicInjection`](@ref) components also implement some additional information useful for
the modeling, like the usual states assumed by the model and the number of states. These values are
derived from the documentation associated with the model, for instance PSS/e models provide
parameters, states and variables. Although `PowerSystems.jl` doesn't assume a specific
mathematical model for the components, the default values for these parameters are derived
directly from the data model source.

## Dynamic Generator Structure

Each generator is a data structure that is defined by the following components:

  - [Synchronous Machine](@ref SynchronousMachineDynamics): That defines the stator electro-magnetic dynamics.
  - [Shaft](@ref Shaft): That describes the rotor electro-mechanical dynamics.
  - [Excitation System](@ref ExcitationSystemDynamics): Electromotive dynamics to model an AVR controller.
  - [Power System Stabilizer](@ref PowerSystemStabilizerDynamics): Control dynamics to define a stabilization signal for the AVR.
  - [Turbine Governor](@ref TurbineGovernorDynamics): Thermo-mechanical dynamics and associated controllers.

```@raw html
<img src="../../assets/gen_metamodel.png" width="75%"/>
```

## Dynamic Inverter Structure

Each inverter is a data structure that is defined by the following components:

  - [DC Source](@ref DCSource): Defines the dynamics of the DC side of the converter.
  - [Reference Frame Rotation](@ref ReferenceFrameRotation): That describes how the frequency of the grid
    can be estimated using the grid voltages. Typically a phase-locked loop (PLL).
  - [Active Power Control](@ref ActivePowerControl) and
    [Reactive Power Control](@ref ReactivePowerControl): That describe the outer-loop
    active and reactive power control dynamics.
  - [Inner Loop Control](@ref InnerControl): That can describe virtual impedance,
    voltage control and current control dynamics.
  - [Converter](@ref Converter): That describes the dynamics of the pulse width modulation (PWM)
    or space vector modulation (SVM).
  - [Filter](@ref Filter): Used to connect the converter output to the grid.
  - [Current Limitation](@ref CurrentLimitation): Optional. Limits the output current.

```@raw html
<img src="../../assets/inv_metamodel.png" width="75%"/>
``` ⠀
```
