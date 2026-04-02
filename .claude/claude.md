# PowerSystems.jl

Data model library for power system simulation and optimization. Julia compat: `^1.10`.

> **General Sienna Programming Practices:** For information on performance requirements, code conventions, documentation practices, and contribution workflows that apply across all Sienna packages, see [Sienna.md](Sienna.md).

## Design Objectives

**Primary goal:** Performance and expressiveness.

Comprehensive data model library for power system simulation, optimization, and dynamics analysis. Provides the `System` container and all component types (generators, loads, branches, storage, dynamic models). Consumed by PowerSimulations.jl, PowerFlows.jl, PowerNetworkMatrices.jl, and other Sienna packages. All code must be written with performance in mind.

## File Structure

### `src/`

Key files:

- `PowerSystems.jl` -- main module, exports, and includes
- `base.jl` -- `System` type definition and core methods
- `definitions.jl` -- core type definitions and enums
- `deprecated.jl` -- deprecated function warnings
- `subsystems.jl` -- subsystem management
- `contingencies.jl` -- contingency definitions
- `outages.jl` -- outage modeling
- `component_selector.jl` -- component selection utilities
- `data_format_conversions.jl` -- format conversion methods

#### `models/`

Core component models and definitions:

- `components.jl` -- base component methods
- `devices.jl` -- device implementations
- `branches.jl` -- branch/transmission line definitions
- `topological_elements.jl` -- buses and topology
- `generation.jl` -- generation component definitions
- `storage.jl` -- storage/battery definitions
- `loads.jl` -- load component definitions
- `reserves.jl` -- reserve ancillary services
- `services.jl` -- all kinds of ancillary services (supertype to reserves)
- `static_models.jl` -- static component definitions
- `dynamic_generator.jl` -- dynamic generator models
- `dynamic_inverter.jl` -- dynamic inverter models
- `dynamic_branch.jl` -- dynamic branch models
- `dynamic_loads.jl` -- dynamic load models
- `HybridSystem.jl` -- hybrid renewable + storage systems
- `serialization.jl` -- component serialization
- `supplemental_constructors.jl` -- additional constructors
- `supplemental_accessors.jl` -- getter methods
- `supplemental_setters.jl` -- setter methods
- `generated/` -- auto-generated component type files (**DO NOT EDIT directly**)
- `cost_functions/` -- operational cost types (ThermalGenerationCost, StorageCost, etc.)

#### `parsers/`

Data parsing and import functionality:

- `common.jl` -- shared parsing utilities
- `power_system_table_data.jl` -- CSV/table-based data parsing
- `power_models_data.jl` -- PowerModels.jl format support
- `psse_dynamic_data.jl` -- PSS/E dynamic data parsing
- `pm_io/` -- PowerModels I/O (matpower.jl, psse.jl, pti.jl)
- `im_io/` -- InteractiveModels I/O (matlab.jl)

#### `utils/`

Utility functions:

- `print.jl` -- enhanced console display
- `generate_struct_files.jl` -- generate component definitions
- `logging.jl` -- logging configuration
- `conversion.jl` -- unit and format conversions
- `IO/` -- data validation (system_checks.jl, branchdata_checks.jl, base_checks.jl)

#### `descriptors/`

JSON schema and metadata:

- `power_system_structs.json` -- component structure definitions
- `power_system_inputs.json` -- input specifications

### Other top-level directories

- `test/` -- test suite
- `docs/` -- documentation source
- `scripts/` -- utility scripts (formatter)

## Auto-Generation

Component structs are auto-generated from JSON descriptors (`src/descriptors/power_system_structs.json`). Generated files are in `src/models/generated/` and should **NOT** be edited directly. Over 140 component types are auto-generated.

Generator: `src/utils/generate_struct_files.jl`

Workflow:

1. Edit `src/descriptors/power_system_structs.json` to define/modify struct fields
2. Run the generation script
3. Generated files include docstrings, constructors, and accessors automatically

## Downstream Packages

- **PowerSimulations.jl** -- production cost modeling and unit commitment
- **PowerFlows.jl** -- power flow analysis
- **PowerNetworkMatrices.jl** -- network matrix calculations
- **PowerSystemsInvestmentsPortfolios.jl** -- capacity expansion portfolios

## Dependencies

- **InfrastructureSystems.jl** -- base types, system data management, time series
- **PowerFlowData.jl** -- power flow data handling
- **DataFrames.jl** -- tabular data processing
- **TimeSeries.jl** -- time series data management
- **PrettyTables.jl** -- enhanced console output

## Core Abstractions

### System

Main container for power system data. Defined in `src/base.jl`.

Fields:

- `data` -- `IS.SystemData` for storing components and time series
- `frequency` -- system frequency (Hz)
- `bus_numbers` -- set of bus numbers for validation
- `runchecks` -- flag for data validation
- `units_settings` -- unit system settings (`SYSTEM_BASE`, `DEVICE_BASE`, `NATURAL_UNITS`)

Key methods: `add_component!`, `remove_component!`, `get_component`, `get_components`, `get_bus`, `set_units_base_system!`

### Component

Abstract base type for all power system elements.

Hierarchy:

- **Topology** -- network topology elements: `Bus` (`ACBus`, `DCBus`), `Arc`, `Area`, `LoadZone`
- **Device** -- physical equipment: `StaticInjection` (generators, loads, storage), `Branch` (lines, transformers)
- **Service** -- ancillary services (reserves, AGC)
- **DynamicComponent** -- dynamic models for stability analysis

### StaticInjection

Static injection devices (generators, loads, storage).

- **Generator:** `ThermalStandard`, `ThermalMultiStart`, `HydroDispatch`, `RenewableDispatch`, `RenewableNonDispatch`
- **Storage:** `EnergyReservoirStorage`, `HybridSystem`
- **ElectricLoad:** `PowerLoad`, `StandardLoad`, `InterruptiblePowerLoad`, `ControllableLoad`
- **StaticInjectionSubsystem:** grouped injection components

### Branch

Transmission elements connecting buses. Branches that contain Arcs with ACBuses are AC Branches and branches with DCBuses are DC Branches.

- **ACBranch:** `Line`, `TwoWindingTransformer`, `PhaseShiftingTransformer`, `TapTransformer`, `TwoTerminalHVDCLine`, `MonitoredLine`
- **DCBranch:** `TModelHVDCLine`
- **ControlledBranch:** `DiscreteControlledACBranch`

### DynamicInjection

Dynamic models for transient stability.

- **DynamicGenerator** -- synchronous machines with AVR, PSS, TurbineGovernor
- **DynamicInverter** -- inverter-based resources with converter, filter, controls

### Service

Ancillary services and system requirements.

- **Reserve:** `ConstantReserve`, `VariableReserve`, `ReserveDemandCurve`
- **AGC** -- automatic generation control
- **TransmissionInterface** -- interface flow limits

### OperationalCost

Cost structures for component operations.

- **ThermalGenerationCost** -- thermal unit costs with fuel, startup, variable O&M
- **HydroGenerationCost** -- hydro unit costs
- **RenewableGenerationCost** -- renewable unit costs
- **StorageCost** -- storage operation costs
- **MarketBidCost** -- market bid/offer curves

### TimeSeriesData

Time-varying data attached to components.

- **SingleTimeSeries** -- single scenario time series
- **Deterministic** -- deterministic forecast
- **Probabilistic** -- probabilistic forecast with scenarios

## Common Tasks

```sh
# Dev local copy
julia --project=test -e 'using Pkg; Pkg.develop(path = ".")'

# Run all tests
julia --project=test test/runtests.jl

# Run specific tests (without extension)
julia --project=test test/runtests.jl <test_file_name_without_extension>
# Example:
julia --project=test test/runtests.jl test_plant_attributes

# Build docs
julia --project=docs docs/make.jl

# Format code
julia -e 'include("scripts/formatter/formatter_code.jl")'

# Check formatting
git diff --exit-code

# Instantiate test environment
julia --project=test -e 'using Pkg; Pkg.instantiate()'

# Generate structs
julia --project=test -e "using InfrastructureSystems; InfrastructureSystems.generate_structs(\"./src/descriptors/power_system_structs.json\", \"./src/models/generated\")"
```

## PowerSystems.jl Specific Guidelines

### Julia Environment

**Always use `julia --project=test`** when running Julia code in this repository. See [Sienna.md](Sienna.md) for general Julia environment best practices. The `test/Project.toml` defines all required dependencies including PowerSystems, PowerSystemCaseBuilder, and InfrastructureSystems.

### Working with Auto-Generated Code

Component structs are auto-generated from `src/descriptors/power_system_structs.json`. Over 140 component types are auto-generated.

**DO NOT** edit files in `src/models/generated/` directly. Instead:

1. Edit `src/descriptors/power_system_structs.json` to define/modify struct fields
2. Run the generation script: `julia --project=test -e "using InfrastructureSystems; InfrastructureSystems.generate_structs(\"./src/descriptors/power_system_structs.json\", \"./src/models/generated\")"`
3. Generated files include docstrings, constructors, and accessors automatically

### PowerSystems-Specific Patterns

- **Component addition:** Use `add_component!(sys, component)` not direct insertion
- **Component retrieval:** Use `get_component(Type, sys, name)` or `get_components(Type, sys)`
- **Time series:** Always attach to components, never store standalone
- **Units:** Be mindful of `SYSTEM_BASE`, `DEVICE_BASE`, `NATURAL_UNITS` settings
- **Validation:** Use `runchecks=true` during development to catch issues early
- **Bus numbers:** Must be unique across system; validated on add
