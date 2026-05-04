# [Understanding ACBusTypes](@id bustypes)

In AC power flow analysis, every bus in the network has four associated quantities: real
power injection ($P$), reactive power injection ($Q$), voltage magnitude ($|V|$), and
voltage angle ($\delta$). The power flow problem is solvable only when exactly two of
these four quantities are specified at each bus — the other two are determined by the
solver. The [`ACBusTypes`](@ref) of a bus declares which two quantities are known, and therefore
shapes how the power flow problem is formulated across the whole network.

`PowerSystems.jl` supports five [`ACBusTypes`](@ref)s, [listed here](@ref acbustypes_list). The
choice of bus type for each bus in a dataset has a direct effect on solver behavior,
convergence, and the interpretation of results.

## [Voltage Control Types](https://en.wikipedia.org/wiki/Voltage_control_and_reactive_power_management)

Most buses in a network fall into one of two voltage control categories, depending on
whether the equipment connected can actively regulate its terminal voltage.

  - `PQ`:

      + **Known:** Real power injection ($P$) and reactive power injection ($Q$). These
        are typically fixed loads or generators operating at a fixed power factor.
      + **Unknown:** Voltage magnitude ($|V|$) and voltage angle ($\delta$), which are
        determined by the power flow solution.
      + This is the most common bus type. Because $|V|$ is unconstrained, the voltage at
        a `PQ` bus reflects the state of the surrounding network rather than any local
        control action.

  - `PV`:

      + **Known:** Real power injection ($P$) and voltage magnitude ($|V|$).
      + **Unknown:** Reactive power injection ($Q$) and voltage angle ($\delta$).
      + Represents a bus with a generator or other device actively regulating its
        terminal voltage to a setpoint. The reactive power output floats to whatever
        value is needed to hold that voltage. This is the typical representation of a
        synchronous generator with an automatic voltage regulator (AVR).

The distinction matters because placing a generator on a `PV` bus rather than a `PQ` bus
allows the power flow solver to use the voltage setpoint as a constraint, which is closer
to how real generators operate and tends to produce more physically meaningful results.

## Reference and Slack Buses

Every power flow problem also requires buses that handle system-wide power balance and
provide an angular reference. `PowerSystems.jl` distinguishes between these two roles,
because conflating them — as many textbooks and smaller test systems do — can produce
misleading results in large or radially structured networks.

  - `SLACK`:

      + Known: Voltage Magnitude ($|V|$) and Voltage Angle ($\delta$) **when the slack and the reference are the same bus, otherwise is unknown**.
      + Unknown: Real Power ($P$) and Reactive Power ($Q$). These values are calculated as residuals after the power flow solution converges to account for system losses and imbalances and are allocated using participation factors in the model formulation.
      + This kind of bus absorbs or supplies the difference between the total generation and total load plus losses in the system. There can be several slack buses in a system.

  - Ref:

      + Known: Voltage Magnitude ($|V|$) and Voltage Angle ($\delta$). Typically, the angle is set to 0 degrees for simplicity, and the voltage is set to a fixed value per unit.0 degrees for simplicity and the voltage is set to a fixed value per unit.
      + Unknown: Real Power ($P$) and Reactive Power ($Q$). These values are calculated as residuals after the power flow solution converges to account for system losses and imbalances when there is a single slack bus that matches the reference bus.
      + Serves as the "reference" for all other bus voltage angles in the AC interconnected system.

For the study of large interconnected areas that include different asynchronous AC networks connected through HVDC, the system can contain multiple reference buses. Since not all modeling efforts require a properly set reference bus, e.g., Zonal Modeling, **PowerSystems.jl does not perform a verification that the system buses are adequately set. This feature is implemented in [`PowerNetworkMatrices.jl`](https://sienna-platform.github.io/PowerNetworkMatrices.jl/stable/).**

## Isolated Buses and the `available` field

Many power flow tools use an "isolated" designation to signal that a bus is temporarily
disconnected from the network. `PowerSystems.jl` keeps this concept but separates it from
the question of whether a component participates in a given analysis.

In `PowerSystems.jl`, `ISOLATED` means precisely that the bus is structurally
disconnected from the network — it has no active connections. This is distinct from
*excluding* a bus from a particular analysis, which is handled by setting the `available`
field to `false` via `set_available!(bus, false)`. Setting `available = false` removes the
bus and its attached components from consideration without altering the underlying network
topology, which is important when the same dataset is used across multiple modeling
contexts.

This design supports resource analysis workflows where isolated subsystems exist in the
data — perhaps representing planned expansions or decommissioned equipment — and must be
represented precisely while being excluded from active power flow or optimization runs.
`ISOLATED` buses can additionally be made unavailable, which propagates the exclusion to
all components attached to them.
