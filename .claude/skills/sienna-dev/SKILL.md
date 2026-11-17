---
name: sienna-dev
description: Context for the Sienna psy6 / Sienna 1.0 development line — what each package owns, how the packages and the data/schema pipeline connect, the platform vocabulary, and the psy5 → psy6 translation map. Use when working in any Sienna psy6 repository (InfrastructureSystems, PowerSystems, PowerNetworkMatrices, PowerFlows, InfrastructureOptimizationModels, PowerOperationsModels, PowerSimulations, the parsers, PowerSystemCaseBuilder, PowerSystemsUpdater, SiennaSchemas, SiennaGridDB, PowerOpenAPIModels), before a change that crosses packages, when a units (SU/CU/NU) question comes up, or when you port code or knowledge from the psy5 line, PowerSimulations.jl PRs, or older docs.
---

# Sienna psy6 context

This skill is the reference layer. The rules are in `.claude/Sienna.md`, which every psy6 repository
guide imports; package specifics are in that repository's `.claude/CLAUDE.md`. Read this skill for
the parts of the platform outside the repository you are in.

**Porting from psy5, PSI PRs, or older docs?** Read `references/psy5-migration.md` first. Many psy5
API and package facts are wrong here; numerics and domain knowledge transfer.

Test runners per repository, environment wiring, and troubleshooting: `references/environments.md`.

## What each package owns

| Layer | Package | Owns |
|---|---|---|
| 0 | InfrastructureSystems (IS) | SystemData, component containers, time series (InfraStore backend), serialization, struct codegen, the Sienna archive container, units markers (SU/CU/NU) and `PerUnit` |
| 0 | InfrastructureOptimizationModels (IOM) | Domain-neutral optimization: `OptimizationContainer`, Decision/Emulation models, stores, settings, objective-function builders. A library for POM today and investment models tomorrow |
| 1 | PowerSystems (PSY) | The power data model: `System`, generated component types, explicit-units getters, System ⇄ OpenAPI conversion and `to_file`/`from_file`. No parsers |
| 2 | PowerNetworkMatrices (PNM) | Ybus, PTDF, LODF, MODF, `ContingencySpec`, linear-solver caches (through PowerMatricesCore), and all network reductions |
| 2 | PowerFlowFileParser (PFFP) | Matpower and PSS/E (`.raw`, `.dyr`, `.con`, `.mon`, `.sub`) → PowerModels dict → OpenAPI document. Depends on IS only |
| 2 | PowerTableDataParser (PTDP) | The CSV/tabular parser that left PSY |
| 3 | PowerFlows (PF) | AC/DC power flow, `PowerFlowData`, PSS/E export |
| 3 | PowerOperationsModels (POM) | Power optimization formulations on IOM + PNM + PSY + PF |
| 3 | PowerSystemsInvestmentsPortfolios (PSIP) | `Portfolio`, investment schedules, financial data |
| 4 | PowerSimulations (PSI) | Simulation orchestration on IOM + POM; re-exports their public API. Base branch `psy6` |
| 4 | PowerAnalytics (PA), PowerGraphics (PG) | Metrics over results; plotting on PA |
| 4 | PowerTransmissionSecurityAnalysis (PTSA) | N-1/N-k security analysis on PF (AC) and PNM (DC) |
| — | PowerSystemCaseBuilder (PSB) | Test-system registry and serialized cache |
| — | PowerSystemsUpdater (PSU) | Upgrades serialized psy5 `System` JSON to a psy6 OpenAPI document |

Base branches: IS uses `IS4`; IOM and PSU use `main`; most others use `psy6`. Read the branch, do
not assume it.

Known seams:

- POM implements IOM's extension stubs and calls non-exported `IOM._*` helpers.
- POM wraps PF models in `PowerFlowEvaluator <: IOM.AbstractEvaluator` (`ext/PowerFlowsExt`), so
  IOM stays PF-agnostic.
- IOM keeps only `AbstractBranchReductionTracker`; the concrete tracker is in POM.
- PSB builds every Matpower, PSS/E, and tabular case through the OpenAPI document:
  parser → document → `PSY.from_file`.

## The data/schema pipeline

```
SiennaSchemas (hand-written draft-07 JSON Schemas + Core/units.json unit vocabulary)
  ├─ datamodel-codegen           ──▶ power-openapi-models   (Python / pydantic v2)
  ├─ openapi-generator           ──▶ PowerOpenAPIModels     (6 Julia subpackages)
  └─ generate_unit_registry.py   ──▶ SiennaGridDB           (SQLite schema + sealed unit registry)
```

- SiennaSchemas is the single source of truth; everything downstream of it is generated.
- Schemas mirror PSY component types field for field, in natural units with integer-id references.
  `x-unit` annotations validate against `Core/units.json`.
- PSY `src/openapi/` converts System ⇄ OpenAPI; `to_file`/`from_file` are PSY's only file I/O
  (directory, `.json`, or `.sns` archive). The OpenAPI ⇄ GridDB bridge is not built.
- Validators hold consistency (`validate_units.py`, the GridDB registry generator, the schema ↔
  GridDB ↔ PSY-descriptor sync checks). Treat schema/PSY field drift as a defect to report.

## Glossary

- **SU / CU / NU** — system base / component base / natural units. Per-unit values are Unitful
  quantities (`0.9u"SU"`). "Device base" is the psy5 name for component base.
- **System / Component** — PSY's container and its typed contents. Mutate through `add_component!`
  and setters; read through `get_*`.
- **Arc** — a directed (from, to) bus pair under a branch. Orientation carries sign meaning in Ybus,
  PTDF, and flows.
- **Ybus / PTDF / LODF / MODF** — admittance matrix; power-transfer, line-outage, and
  modified-outage distribution factors. `Virtual*` variants compute rows lazily with an LRU cache.
- **ContingencySpec** — PNM's N-1 modification descriptor; it feeds POM's branch-side security
  constraints through `VirtualMODF`.
- **Network reduction** — PNM-owned topology simplification (radial, degree-2, Ward,
  zero-impedance, parallel/series merge). `NetworkReductionData` is the consumer-facing map set;
  consumers never re-derive it.
- **Formulation** — a model variant selected by type: POM `DeviceModel{Device,Formulation}` and
  `NetworkModel{F}`; PF formulation × solver type parameters.
- **Two-stage construction** — POM `construct_device!` runs `ArgumentConstructStage` (variables,
  parameters, expressions), then `ModelConstructStage` (constraints, objective).
- **ProblemTemplate / DecisionModel / EmulationModel** — IOM's problem description and model
  wrappers. POM's `AbstractPowerOperationProblem` chain hangs off `IOM.AbstractOptimizationProblem`.
- **Result key** — `"VariableType__ComponentType"` (for example `"FlowActivePowerVariable__Line"`),
  read from `IOM.OptimizationProblemOutputs` with `read_variable(res, key; table_format=TableFormat.WIDE)`.
- **PSB fixture** — a named test system from `build_system(Category, "name")`, cached under
  `data/serialized_system/` with no version-aware invalidation.
- **`[sources]`** — `Project.toml` git or path pins. They select the psy6 line; compat entries do
  not. A dev'd dependency's own `[sources]` are ignored by the parent environment.
- **no-shims** — the breaking-release policy: fix callers, regenerate data, add no compat layers.
