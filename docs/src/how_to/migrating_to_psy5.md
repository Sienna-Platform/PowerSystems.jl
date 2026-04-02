# [Migrating from version 4.0 to 5.0](@id psy5_migration)

This guide outlines the code updates required to upgrade from PowerSystems.jl version 4.0
to 5.0, which was released in July 2025 and includes breaking changes. Most the changes are related
to modeling in more detail AC transmission technologies.

!!! warning

    ***PowerSystems v5 is not backwards compatible with PowerSystems v4. The datasets created in PowerSystems v4 need to be converted using a separate script to be loaded
    in version 5***

The changes are:

```@contents
Pages = ["migrating_to_psy5.md"]
Depth = 2
```

## AC Branches Type Hierarchy Change

New abstract type [`ACTransmission`](@ref) and was created to better distinguish between AC transmission objects connected between [`ACBus`](@ref) the new added [`TwoTerminalHVDC`](@ref) abstract type to caputre HVDC links connected between [`ACBus`](@ref).

## Renamed Types and Parameters

Some `Types` and fields were renamed, which should require a trivial search and replace:

Renamed `Types`:

  - [`TwoTerminalHVDCLine`](@ref) is now named [`TwoTerminalGenericHVDCLine`](@ref) and a method has been included to read old `TwoTerminalHVDCLine` data. See [Deprecated Methods](@ref deprecated)
  - `TimeSeriesForcedOutage` is now named [`FixedForcedOutage`](@ref) and the method has been removed but the functionality remains.

New parameters:

  - The [`ACTransmission`](@ref) objects now have rating fields for `b` and `c` ratings to enable modeling security constrained problems. These components now also include a `base_power` field, in situations where the base power for the transformer is not available (e.g., when parsing Matpower), the default behavior is to use the [system base for per-unitization](@ref per_unit).

Affected Types are:

  - [`Line`](@ref)
  - [`MonitoredLine`](@ref)
  - [`PhaseShiftingTransformer`](@ref)
  - [`TapTransformer`](@ref)
  - [`Transformer2W`](@ref)
  - [`FuelCurve`](@ref) now has a new field for fuel offtake at the start of a thermal unit. This field defaults to a `LinearCurve(0.0)` value.

## New and Eliminated Types

  - [`Transformer3W`](@ref) (see [Handle 3-winding transformer data](@ref 3wtdata))
  - [`TwoTerminalLCCLine`](@ref)
  - [`TwoTerminalVSCLine`](@ref)
  - [`HydroReservoir`](@ref)
  - [`HydroTurbine`](@ref)
  - [`HydroPumpTurbine`](@ref)
  - [`ShiftablePowerLoad`](@ref)
  - [`DiscreteControlledACBranch`](@ref)
  - [`FACTSControlDevice`](@ref)
  - [`ImpedanceCorrectionData`](@ref)
  - [`ImportExportCost`](@ref)
  - [`SynchronousCondenser`](@ref)
  - [`InterruptibleStandardLoad`](@ref)

These types are no longer part of PowerSystems.jl:

  - `TwoTerminalVSDCLine`
  - `HydroPumpedStorage` (see [Updates to Hydro Storage related devices](@ref Hyd_updates))
  - `HydroEnergyReservoir` (see [Updates to Hydro Storage related devices](@ref Hyd_updates))

## [Updates to hydro storage related devices](@id Hyd_updates)

In previous versions of `PowerSystems.jl`, hydropower connected to reservoirs was modeled as a single plant connected to a single reservoir. Further, the model just kept track of the total energy in the reservoir. In this version of `PowerSystems.jl`, new structs [`HydroTurbine`](@ref) and [`HydroReservoir`](@ref) have been included to enable individual unit dispatch modeling as well as a shared reservoir.

The new [`HydroReservoir`](@ref) is also used by the new [`HydroPumpTurbine`](@ref) to model the head and tail reservoirs for Hydro Pump Storage facilities. Check the section [Define Hydro Generators with Reservoirs](@ref hydro_resv)

## Updates to fuel categories

The fuel categories available in form EIA-923 have been expanded, the old categories are still
valid and the expanded list can be explored in the documentation [`ThermalFuels`](@ref tf_list)

## Updates to Transformers

Most of the transformer changes are included to bring PowerSystems.jl closer to the data model employed in PSSe RAW files which tend to be the industry standard. The two notable changes are:

  - All transformers now have additional fields for base quantities needed for the calculation of the impedances in adequate bases. See [`Transformer per unit transformations`](@ref transformers_pu) for more details.
  - The shunt branch in the transformer now uses a `Complex{Float64}` to model core losses as well as the core inductance.
  - Shunt allocation in the transformer between the primary and secondary. We now allocate the shunt to the primary following PSSe's convention. See [`this issue`](https://github.com/NREL-Sienna/PowerSystems.jl/issues/1411) for a description of the discrepancy with Matpower. Note that this mostly affect the results reporting between Matpower and PSSe.

We also added support for [`Transformer3W`](@ref). See [`Handle 3-winding transformer data`](@ref 3wtdata) for more details.

These changes now provide the capability to obtain the impedance values for the transformer's
depending on the [`Per-unit Conventions`](@ref per_unit).

## Updates to ACBuses

[`ACBus`](@ref) has a new field `available` to match the behavior of setting a bus to "isolated" in other simulation applications. A detailed explanation on how to handle this new field has been documented in [`Understanding ACBusTypes`](@ref bustypes)

## Updates to parsing PSSe files

We have implemented new conventions to parsing PSSe files as well as the capability to load PSSe v35 files. See the details in the new documentation section [`Conventions when parsing MATPOWER or PSS/e Files`](@ref parse_conventions)
