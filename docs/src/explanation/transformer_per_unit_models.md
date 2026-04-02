# [Transformer per unit transformations](@id transformers_pu)

The per-unit (p.u.) system is a fundamental tool in power system analysis, especially when dealing with transformers. It simplifies calculations by normalizing all quantities (voltage, current, power, impedance) to a common base. This effectively "retains" the ideal transformer from the circuit diagram because the per-unit impedance of a transformer remains the same when referred from one side to the other. This page is not a comprehensive guide on transformer per-unit calculations, a more in depth explanation can be found in [`this link`](https://en.wikipedia.org/wiki/Per-unit_system) or basic power system literature.

## Establishing Base Values

For a multi-voltage system with transformers, you need to establish consistent base values across different voltage zones.

  - Transformer Voltage Base ($V_{base, LL}$):

      + The voltage base is determined by the transformer's nominal line-to-line voltage ratio:
        $$V_{base, \text{secondary}} = V_{base, \text{primary}} \times \frac{V_{\text{rated, secondary}}}{V_{\text{rated, primary}}}$$
        Where $V_{\text{rated, secondary}}$ and $V_{\text{rated, primary}}$ are the transformer's nominal (rated) line-to-line voltages on its secondary and primary sides, respectively.
      + This value can be slightly different that the attached bus voltage value. In certain low voltage systems, transformers with a higher base voltage can be connected to buses with lower voltage set points. As of PowerSystems v5 transformers now have field for the base voltage.

  - How is the data stored?: Transformer impedance (usually reactive impedance, $X_{pu}$) is typically given on its own nameplate ratings (rated MVA and rated voltages). **The data in PowerSystems.jl is stored in the device base** and transformer to the system base when using the correct getter functions.

  - **Derived Base Impedance ($Z_{base}$):**

      + Once $S_{base, 3\phi}$ and $V_{base, LL}$ are established for each voltage zone, the base impedance can be calculated as follows:

        $$Z_{base} = \frac{(V_{base, LL})^2}{S_{base, 3\phi}}$$
        Where $V_{base, LL}$ is in kV and $S_{base, 3\phi}$ is in MVA, resulting in $Z_{base}$ in Ohms ($\Omega$).

### Transformer Impedance Transformations

The most significant advantage of the per-unit system for transformers is that **the per-unit impedance of a transformer is the same on both sides**, provided the base voltages are chosen according to the transformer's turns ratio and the base power is consistent.

  - Changing Base for Transformer Impedance: If the system-wide base $S_{base, 3\phi}$ and the zone-specific voltage bases ($V_{base, \text{primary zone}}$ and $V_{base, \text{secondary zone}}$) differ from the transformer's ratings, you need to convert the transformer's per-unit impedance to the new system base.

    The formula for changing base of an impedance is:

    $$Z_{pu, \text{new}} = Z_{pu, \text{old}} \times \left(\frac{S_{base, \text{new}}}{S_{rated, \text{old}}}\right) \times \left(\frac{V_{rated, \text{old}}}{V_{base, \text{new}}}\right)^2$$

      + Here, $S_{base, \text{new}}$ is your chosen system-wide base MVA.
      + $S_{rated, \text{old}}$ is the transformer's rated MVA (from nameplate).
      + $V_{rated, \text{old}}$ is the transformer's rated voltage on the side you are considering (e.g., if you're transforming the impedance to the primary side's base, use the primary rated voltage).
      + $V_{base, \text{new}}$ is the *new* system base voltage for that side of the transformer.

    When calculating the transformer's impedance on the system base, you only need to perform this calculation once. Since the per-unit impedance of a transformer is the same when referred from one side to the other (given correct base voltage selection), the $Z_{pu, \text{new}}$ calculated for the transformer will be used regardless of which side you are viewing it from in the per-unit circuit diagram.

!!! note

    The return value of the getter functions, e.g., [`get_x`](@ref) for the transformer impedances will perform the transformations following the convention in [`Per-unit Conventions`](@ref per_unit).
