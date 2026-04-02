# Add costs for imported/exported power

This how-to guide explains how to add an [`ImportExportCost`](@ref) to a [`Source`](@ref)
component to model imports and exports with neighboring areas or external grids.

This guide assumes a [`System`](@ref) is already defined.

```@setup source_ie_cost
using PowerSystems
using PowerSystemCaseBuilder
sys = build_system(PSITestSystems, "c_sys5_uc")
```

## Overview

A [`Source`](@ref) component represents an infinite bus with constant voltage output,
commonly used to represent:

  - Very large machines on a single bus in dynamics simulations
  - Import/export connections in operational simulations

The [`ImportExportCost`](@ref) operating cost allows you to specify:

  - Import offer curves (buy prices for importing power)
  - Export offer curves (sell prices for exporting power)
  - Weekly energy limits for imports and exports
  - Ancillary service offers

## Step 1: Define Import and Export Curves

You can define import and export curves in several ways, depending on your data format.

### Option A: Simple Single-Price Curves

For a simple constant price over a power range:

```@repl source_ie_cost
# Import curve: buy power at $25/MWh up to 200 MW
import_curve = make_import_curve(; power = 200.0, price = 25.0)

# Export curve: sell power at $30/MWh up to 200 MW
export_curve = make_export_curve(; power = 200.0, price = 30.0)
```

### Option B: Piecewise Linear Curves

For more complex pricing with multiple segments:

```@repl source_ie_cost
# Import curve with increasing prices as more power is imported
import_curve = make_import_curve(;
    power = [0.0, 100.0, 105.0, 120.0, 200.0],
    price = [5.0, 10.0, 20.0, 40.0],
)

# Export curve with decreasing prices as more power is exported
export_curve = make_export_curve(;
    power = [0.0, 100.0, 105.0, 120.0, 200.0],
    price = [40.0, 20.0, 10.0, 5.0],
)
```

!!! note

      - Import curves must have non-decreasing (convex) slopes
      - Export curves must have non-increasing (concave) slopes
      - Power values must have one more entry than price values

## Step 2: Create the ImportExportCost

Use the curves to create an [`ImportExportCost`](@ref):

```@repl source_ie_cost
ie_cost = ImportExportCost(;
    import_offer_curves = import_curve,
    export_offer_curves = export_curve,
    energy_import_weekly_limit = 10000.0,  # MWh per week (optional)
    energy_export_weekly_limit = 10000.0,  # MWh per week (optional)
)
```

## Step 3: Add the Cost to the Source Component

Define a [`Source`](@ref) component with the import/export cost, or alternatively use
[`set_operation_cost!`](@ref) to add the cost to an existing source:

```@repl source_ie_cost
source = Source(;
    name = "external_grid",
    available = true,
    bus = get_component(ACBus, sys, "nodeC"),
    active_power = 0.0,
    reactive_power = 0.0,
    active_power_limits = (min = -200.0, max = 200.0),  # Negative for export
    reactive_power_limits = (min = -100.0, max = 100.0),
    R_th = 0.01,
    X_th = 0.02,
    internal_voltage = 1.0,
    internal_angle = 0.0,
    base_power = 100.0,
    operation_cost = ie_cost,
)
```

!!! tip

    The `active_power_limits` should span negative (for export) to positive (for import)
    values. Negative power indicates exporting power to the external grid.

## Step 4: Add the Source to the System

Add the source component to your system:

```@repl source_ie_cost
add_component!(sys, source)
```

Verify the source was added correctly:

```@repl source_ie_cost
get_component(Source, sys, "external_grid")
get_operation_cost(get_component(Source, sys, "external_grid"))
```

## See Also

  - [`Source`](@ref) - Documentation for the Source component
  - [`ImportExportCost`](@ref) - Documentation for ImportExportCost
  - [Adding an Operating Cost](@ref cost_how_to) - General guide for operating costs
  - [`make_import_curve`](@ref) - Function to create import curves
  - [`make_export_curve`](@ref) - Function to create export curves
