# [Convert Transformer Impedances Between Per-Unit Bases](@id convert_transformer_impedance)

Transformer impedance data is typically given on the transformer's own nameplate ratings
(its rated MVA and rated voltages). When building a power system model you usually need
that impedance expressed on the system-wide base instead. This guide walks through the
manual calculation and explains how `PowerSystems.jl` handles it automatically through
getter functions.

For the underlying theory, see
[Transformer per unit transformations](@ref transformers_pu_per_unit) in the Per-unit Conventions explanation.

## Step 1: Establish base values for each voltage zone

Every voltage zone in the network needs a consistent pair of base values: a base power
$S_{base, 3\phi}$ (system-wide, in MVA) and a base voltage $V_{base, LL}$ (zone-specific,
in kV).

The base voltage on the secondary side of a transformer follows from its turns ratio:

$$V_{base,\,\text{secondary}} = V_{base,\,\text{primary}} \times \frac{V_{\text{rated,\,secondary}}}{V_{\text{rated,\,primary}}}$$

where $V_{\text{rated,\,primary}}$ and $V_{\text{rated,\,secondary}}$ are the transformer's
nameplate line-to-line voltages.

Once both base quantities are known for a zone, the base impedance is:

$$Z_{base} = \frac{(V_{base,\,LL})^2}{S_{base,\,3\phi}}$$

with $V_{base,\,LL}$ in kV and $S_{base,\,3\phi}$ in MVA, giving $Z_{base}$ in Ohms.

## Step 2: Convert the transformer impedance to the new base

If the transformer's nameplate ratings differ from the system base values, convert the
per-unit impedance using:

$$Z_{pu,\,\text{new}} = Z_{pu,\,\text{old}} \times \frac{S_{base,\,\text{new}}}{S_{rated,\,\text{old}}} \times \left(\frac{V_{rated,\,\text{old}}}{V_{base,\,\text{new}}}\right)^2$$

where:

  - $S_{base,\,\text{new}}$ — your chosen system-wide base MVA.
  - $S_{rated,\,\text{old}}$ — the transformer's nameplate rated MVA.
  - $V_{rated,\,\text{old}}$ — the transformer's nameplate rated voltage on the side being
    considered.
  - $V_{base,\,\text{new}}$ — the system base voltage for that same side.

This calculation only needs to be done once per transformer. Because the per-unit
impedance of a transformer is identical when referred from either side (provided base
voltages are chosen consistently with the turns ratio), the result applies to the
transformer as a whole.

**Example:** a transformer rated 50 MVA, 115/13.8 kV with $X_{pu} = 0.10$ on its own
base, on a system with $S_{base} = 100\,\text{MVA}$ and $V_{base} = 115\,\text{kV}$ on
the primary side:

$$X_{pu,\,\text{new}} = 0.10 \times \frac{100}{50} \times \left(\frac{115}{115}\right)^2 = 0.20\,\text{p.u.}$$

## Step 3: Read impedance values in PowerSystems.jl

`PowerSystems.jl` stores transformer impedance on the **device base** internally.
Getter functions such as [`get_x`](@ref) automatically apply the base conversion and
return the value on whichever base the [`System`](@ref) is currently set to, following the
conventions described in [Per-unit Conventions](@ref per_unit).

The example below builds the same transformer used in Step 2 (50 MVA, 115/13.8 kV,
$X_{pu} = 0.10$ on its own nameplate base):

```@repl transformer_pu
using PowerSystems

# Two buses — primary at 115 kV, secondary at 13.8 kV.
bus_primary = ACBus(;
    number = 1,
    name = "primary",
    available = true,
    bustype = ACBusTypes.REF,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.9, max = 1.05),
    base_voltage = 115.0,   # kV
)

bus_secondary = ACBus(;
    number = 2,
    name = "secondary",
    available = true,
    bustype = ACBusTypes.PQ,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.9, max = 1.05),
    base_voltage = 13.8,    # kV
)

arc = Arc(; from = bus_primary, to = bus_secondary)

xfmr = Transformer2W(;
    name = "xfmr_50MVA",
    available = true,
    active_power_flow = 0.0,
    reactive_power_flow = 0.0,
    arc = arc,
    r = 0.0,
    x = 0.10,               # p.u. on device base (nameplate: 50 MVA, 115/13.8 kV)
    primary_shunt = 0.0 + 0.0im,
    rating = 0.5,           # MVA rating in SYSTEM_BASE p.u.: 50 MVA / 100 MVA system base
    base_power = 50.0,      # MVA — transformer nameplate rating
)

# System base power = 100 MVA (matches the Step 2 example).
sys = System(100.0)
add_component!(sys, bus_primary)
add_component!(sys, bus_secondary)
add_component!(sys, arc)
add_component!(sys, xfmr)

# get_x returns the reactance on the current unit base (SYSTEM_BASE by default).
# Expected: 0.10 × (100/50) × (115/115)² = 0.20 p.u.
x_system_base = get_x(xfmr)
```

To inspect the raw device-base value, switch the unit system first:

```@repl transformer_pu
set_units_base_system!(sys, "DEVICE_BASE")
x_device_base = get_x(xfmr)   # returns 0.10 — the original nameplate value

set_units_base_system!(sys, "SYSTEM_BASE")  # restore
```

See [Read Component Values in Different Unit Systems](@ref convert_unit_systems) for a full description of
the available unit system settings.
