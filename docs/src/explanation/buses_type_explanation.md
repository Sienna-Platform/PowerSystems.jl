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

      + **Known:** Voltage magnitude ($|V|$) and voltage angle ($\delta$) *only when the
        slack and the reference coincide*; otherwise both are unknown.
      + **Unknown:** Real power ($P$) and reactive power ($Q$), which are calculated as
        residuals after the power flow solution converges. Losses and generation-load
        imbalances are distributed across slack buses using participation factors.
      + A system can have multiple slack buses. In large interconnected cases, distributing
        the power mismatch across several buses is more physically realistic than
        concentrating it at one.

  - `REF`:

      + **Known:** Voltage magnitude ($|V|$) and voltage angle ($\delta$). By convention
        the angle is set to 0 radians and the voltage to a fixed per-unit value, providing
        the angular reference against which all other bus angles are measured.
      + **Unknown:** Real power ($P$) and reactive power ($Q$) when the reference bus is
        also the sole slack bus.
      + In systems that span multiple asynchronous AC networks connected through HVDC,
        each island needs its own reference bus.

`PowerSystems.jl` treats `SLACK` and `REF` as distinct designations, leaving it to the
application developer to decide whether a reference bus should also absorb power mismatch.
Because not all modeling workflows require a properly configured reference bus — zonal
production cost models, for example, do not — **`PowerSystems.jl` does not verify that
the system buses are adequately set. That validation is implemented in
[`PowerNetworkMatrices.jl`](https://nrel-sienna.github.io/PowerNetworkMatrices.jl/stable/).**

For worked examples of constructing reference and slack buses and adding them to a system,
see the [Create and Explore a Power System](@ref "Create and Explore a Power `System`") tutorial.

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
