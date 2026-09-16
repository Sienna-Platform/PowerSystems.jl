# PowerSystems.jl (PSY) — psy6 branch

The Sienna power-system **data model**: the `System` container plus ~210 component types (buses, branches, generators, storage, loads, services, dynamic models), operational cost structures, time series, and the **explicit-units engine**. Layer 1 of the psy6 stack, built on InfrastructureSystems (IS4 branch). Platform-wide conventions: the `sienna-psy6` skill. Workspace architecture: the psy6 workspace root `CLAUDE.md`.

**This branch has NO parsers.** `src/parsers/` was removed in the psy6 line; all Matpower/PSSE/table parsing lives in PowerFlowFileParser.jl (and PSB's parser wrappers). Do not re-add parsing here.

**There is also NO native JSON serializer.** `to_file`/`from_file` are the only way a `System` reaches or leaves disk — see "System file I/O" below before touching anything serialization-shaped.

## System file I/O — `to_file` / `from_file` only

`src/openapi/file_io.jl` owns the surface. **Three forms, one path-inferred dispatch, one
serializer** — no `format` keyword, and the archive builds the same bundle a document form does
before archiving it, so there is no second writer to keep in sync.

```julia
to_file(sys, path; units = CU, force = false, pretty = false)
from_file(path; system_kwargs...)   # no type argument — the form is inferred from `path`
```

The extension of `path` chooses the form, and `to_file` refuses an unrecognized one in its own
`else` branch *before* anything dispatches on the form — keep that order, or a typo'd extension
becomes a `MethodError` on an internal helper.

- **directory** (no extension) — `system.json` plus `time_series.h5` when there are time series.
- **`.json`** — the same two, sidecar named from the document's stem (`case.json` → `case.h5`)
  and beside it, so several systems can share a directory.
- **`.sns`** — those two plus `time_series.h5.sqlite` (InfraStore's catalog, authoritative on
  read) and `sienna_extras.json`. **The only lossless form.** Writes on `CU` only and throws
  otherwise — the form exists to avoid a conversion pass.

Neither document form writes a `.sqlite`: the document's `time_series_associations` table
already holds every row, `association_id` and `data_hash` included, and `from_openapi` replays
them into a fresh catalog. `_load_time_series_associations!` dispatches on whether the adopted
store brought its own rows — if it did, it outranks the document and the rows are only
validated. The replay runs **before** the component pass, so a `MarketBidTimeSeriesCost`
resolves its `association_id` while its owner is being built.

**The `units` keyword takes a marker, not a Symbol.** `CU` (default) or `NU`; `SU` throws, the
wire enum having no system-base member. It governs every convertible field (`:mva`, `:ohm`,
`:siemens`). Do not confuse it with the **`power_units` field** on cost curves and power-bearing
blobs — that is per-value data spelled `"COMPONENT_BASE"`/`"NATURAL_UNITS"` on the wire.

The `SU` rejection and the archive's `CU`-only rule (`_check_export_units`,
`_check_archive_units`) are **dispatch, not a `Union{ComponentBaseUnit, NaturalUnit}`
annotation** — a marker added later must land on the error, not match a two-type union.

**The archive container is IS's, the extension is PSY's.** `IS.create_sienna_archive` /
`extract_sienna_archive` / `is_sienna_archive` own the zip and the write guards but take the
extension from the caller, so PowerSystemsInvestmentsPortfolios can use `.snp`. PSY passes
`SYSTEM_ARCHIVE_EXTENSION = ".sns"`. Members are deflated except `.h5`/`.hdf5`, which HDF5
already compresses. Do not add zip or archive dependencies here.

**What the document forms lose:** subsystem membership, which only `sienna_extras.json` carries —
`_warn_on_document_data_loss` warns (never errors) from the document forms only. Frequency
survives both. Masked components survive both but are **derived, not recorded**:
`handle_component_addition!(sys, ::StaticInjectionSubsystem)` re-masks on import. Do not add a
list for them — that would give one truth two writers.

**Deleted, stays deleted:** `src/data_format_conversions.jl`, `DATA_FORMAT_VERSION`,
`_post_deserialize_handling`, `from_dict(::Type{System}, …)`, `deserialize_components!`,
`test/test_serialization.jl`, the `format` keyword, and `_resolve_export_power_units`.
`System(::AbstractString)` throws and names its replacement; `to_json`/`from_json` are no longer
exported for `System` at all. Do not restore any of them, and do not add a shim.

Migration between lines belongs to **PowerSystemsUpdater.jl**, not here. There is no migration
path from pre-cutover files — regenerate them.

**Do not run `Pkg.free("InfrastructureSystems")`** — it discards the `[sources]` pin and resolves
the registered psy5 IS, failing with `UndefVarError: AbstractUnitSystem`. `Pkg.add`/`Pkg.free`
also rewrite `Project.toml`, stripping comments and sometimes `[sources]` itself; check
`git diff Project.toml` after any Pkg operation.
## Downstream blast radius

PNM, PF, POM, and PSB all consume PSY; SiennaSchemas mirrors PSY component fields (JSON schemas), so field renames/retypes create schema drift the sync tooling must catch. After a PSY change:

1. compile-smoke the stack: `julia --project=<psy6-workspace-root> -e 'using PowerNetworkMatrices, PowerFlows, PowerOperationsModels, PowerSystemCaseBuilder'`
2. **clear PSB's `data/serialized_system/` cache** — it has no version-aware invalidation, and stale cached systems produce confusing deserialization failures downstream.
3. if the change touched a component field also present in SiennaSchemas, flag the schema counterpart (example of real drift: `head_to_volume_factor` moved to `FunctionData` in PSY commit `ed30a682` while `SiennaSchemas/Operations/StaticInjection/HydroReservoir.json` still `$ref`s `ValueCurve`).

**Open cross-repo break (as of the `to_file`/`from_file` cutover):** two packages still call the
pre-cutover signatures from their own source and are knowingly left broken until they get their own PRs.
Expect their suites — and anything using PSB fixtures, which is most of the stack — to fail with
`MethodError: no method matching from_file(::Type{System}, ::String)` until then. Neither is PSY's to fix
from this side:

- **PowerSystemCaseBuilder** — `src/build_system.jl:113` and `:139`, `src/parsers/openapi_pipeline.jl:30`.
  Its system cache calls both old signatures, so most `build_system` calls throw. `test_component_selector.jl`
  calls `PSB.build_system` at module top level, which aborts an unfiltered `runtests.jl` before later files load.
- **PowerOperationsModels** — `src/operation/decision_model.jl:235`, `src/operation/emulation_model.jl:293`.
  `to_file(sys, dir; power_units = …)` under IOM's *default* `system_to_file` setting, inside a try/catch
  that reports a successful solve as `FAILED` rather than surfacing the error.

Both need the same two mechanical edits: `power_units = :component_base` → `units = PSY.CU` (a
marker, not a Symbol — the keyword was briefly `unit_system::Symbol` mid-PR and is now `units`), and
drop `System` from `from_file`'s arguments. PSB's `build_system.jl:120` writes a *directory*, which
is still the extensionless form, so only the keyword changes there.

## Source layout — the non-obvious parts

- `src/units/` — **the explicit-units engine** (`types.jl`, `conversions.jl`, `serialization.jl`).
  Conversion entry points *also* live in `src/models/components.jl`, which is easy to miss.
- `src/models/` — hand-written behavior over generated structs; `generated/` is **auto-generated,
  never edit**.
- `src/descriptors/power_system_structs.json` — source of truth for generated structs (top-level
  key `auto_generated_structs`).
- `src/deprecated.jl` — legacy 4.0.0-era constructor deprecations that predate the no-shims policy.
  Do not add to it; psy6 breaking changes get no shims.

## Generated code workflow

PSY owns its own struct generator — `src/generate_structs.jl`, module `PowerSystems.StructGeneration`
(forked from InfrastructureSystems.jl so PSY's OpenAPI-converter emission doesn't live in IS; IS keeps
a trimmed generic copy for its own 3 metadata structs). Edit the descriptor, then regenerate — never
hand-edit `src/models/generated/`:

```sh
julia --project=test -e "using PowerSystems; PowerSystems.StructGeneration.generate_structs(\"./src/descriptors/power_system_structs.json\", \"./src/models/generated\")"
```

- Generated signatures use exact types (`::Type{ExponentialLoad}`), never `Type{<:X}`.
- Hand-written behavior (validation, extra constructors, custom show) goes in non-generated `src/models/*.jl`.
- **Nothing currently checks descriptor↔generated consistency.** `test/test_generate_structs.jl`'s
  byte-compare testset is disabled: its helper paired files and lines with `zip`, which truncates,
  so appended content was never compared. Until it is rewritten, **inspect the regenerated diff by
  hand** for intent. The rewrite should check generated output against both the descriptor's struct
  definitions and SiennaSchemas' field data.
- `StructGeneration` is not exported from `PowerSystems`; it is a dev-tool entry point, always called
  module-qualified.

### Recipe: add or change a component field (end-to-end)

The canonical example of psy6 cross-repo propagation — a PSY field change touches up to six repos:

1. **Descriptor**: edit `power_system_structs.json` (set `needs_conversion`/`conversion_unit` if unit-bearing) → regenerate → formatter.
2. **Hand-written layer**: validation/supplemental accessors in `src/models/*.jl` if needed; `exclude_getter` fields need their public getter written by hand.
3. **Verify locally**: `test_units` filter if convertible; full suite; **docs must build**.
4. **PSB**: clear `data/serialized_system/` (cached fixtures embed the old shape); check whether any builder in `src/library/` sets the field.
5. **SiennaSchemas**: mirror the field in the matching `Operations/...json` with an `x-unit` annotation; run `validate_units.py`. Skipping this creates the drift the sync check exists to catch.
6. **GridDB**: if the field maps to a DB column, update `column_conventions.json` and regenerate the sealed registry.
7. **Downstream smoke**: `julia --project=<psy6-workspace-root> -e 'using PowerNetworkMatrices, PowerFlows, PowerOperationsModels, PowerSystemCaseBuilder'`; consumers reading the field must pass an explicit unit system.

## Transformer architecture (PR #1714, `d19f3244f`)

Five concrete transformer types became two, and series data moved onto a nested struct. `Transformer2W`, `TapTransformer`, `PhaseShiftingTransformer` → **`TwoWindingTransformer`**; `Transformer3W`, `PhaseShiftingTransformer3W` → **`ThreeWindingTransformer`**. Both names were previously *abstract supertypes* in `src/models/branches.jl` and are now concrete generated structs — code written against the old hierarchy changes meaning instead of failing.

- **`TransformerCircuit <: DeviceParameter`** (generated; hand-written behavior in `src/models/transformer_circuits.jl`) holds the arc, tap, α, `r`/`x`, ratings, flows, `base_power`, both terminal base voltages, the flat control block, and `available`. 2W owns one (`get_circuit`); 3W owns three plus `star_bus`. `get_circuits(t)` returns the tuple for either arity.
- **It is not a `Component`.** That drives three consequences worth knowing before touching it: it stores its units anchor directly in `base_value` (no `InfrastructureSystemsInternal`), so it extends `IS.get_base_value`/`IS.set_base_value!` concretely; it needs hand-written `IS.serialize`/`IS.deserialize` and membership in `_CONTAINS_SHOULD_ENCODE` (`src/models/serialization.jl`) so `arc` is UUID-encoded rather than inlined — the generic `InfrastructureSystemsType` path would inline `Arc`, and `Arc`'s abstract `Bus` fields make `fieldnames` error outright on read-back; and `base_value` must never serialize, being runtime state repopulated by `add_component!`.
- **`circuit`/`primary_circuit`/`secondary_circuit`/`tertiary_circuit` are `exclude_setter: true`** in the descriptor. The hand-written `set_circuit!`/`set_*_circuit!` in `transformer_circuits.jl` assign the field *and* copy the parent's anchor onto the new circuit. Codegen's plain `value.circuit = val` would leave a stale or missing `base_value` and silently wrong explicit-units getters — do not let a regeneration reintroduce it.
- **Availability is derived**: `get_available(t) = any(get_available, get_circuits(t))`; `set_available!(t, val)` cascades to all circuits, including ones individually out beforehand (PSS/E STAT semantics). Read-then-write is lossy.
- `is_phase_shifting` is the **canonical** predicate — true when `α ≠ 0` or the control objective is one of four active-power objectives. Downstream must not re-derive it from raw fields. `has_control(w)` is `control_objective != UNDEFINED`.
- 3W pairwise impedance fields are `Union{Nothing,Float64}`, validated **all-or-none** by `check_pairwise_impedance_block`; a partial block is always a data error (impedances without their base have no defined conversion). `base_power_13` → `base_power_31`.
- **Deleted, now owned by PowerNetworkMatrices**: `get_series_susceptance(s)`, `get_series_admittance(s)`, and the winding-group `get_α`/`get_α_primary`/`_secondary`/`_tertiary` derivations. Do not re-add them here — `get_α` is a plain circuit field now.
- `get_arc` is defined for `TwoWindingTransformer` only (`components.jl:45`, delegating to the circuit); 3W has three arcs and no single-arc accessor.

## The explicit-units engine (the defining psy6 feature)

- Descriptor fields carry `needs_conversion: true` + `conversion_unit` (`:mva` / `:ohm` / `:siemens`) — **247 fields** across the descriptor. Codegen (IS-side) emits `get_X(comp, units)`, `get_X_unitful(comp, units)`, and `set_X!(comp, tagged_value)`.
- Getters require the unit system explicitly: `get_rating(br, PSY.SU)`. `SU`/`CU`/`NU` markers come from `IS.RelativeUnits`; PSY gives them domain meaning (`base_power` is the component base, MVA).
- Setters take **tagged** values and reject bare floats: `set_rating_b!(line, 0.9 * PSY.SU)`.
- PSY extends `IS._strip_units` (required by the IS codegen contract) and overrides `IS.default_units(::Component)` to return `SU` for time-series multipliers.
- **`with_units_base` / `set_units_base_system!` / `get_units_base` are GONE** (verified against `origin/psy6`: all three `isdefined(PowerSystems, …) == false`). The stateful units system was fully removed in the psy6 line — see `7ffbbdf8d` "remove last pieces of stateful units system". Every value is read with an explicit unit argument instead. The `UnitSystem` enum still exists as display metadata, but there is no setter. Downstream code calling any of the three must migrate to explicit unit args, not look for a replacement setter.
- Serialization writes on whichever basis `to_file`'s `units` keyword names — `CU` (component base, the representation PSY stores, no conversion) or `NU` (MW/MVAr/MVA, what a reader outside Sienna generally wants). A write is *uniform*: PSY tracks no per-component basis, so the choice stamps every power-bearing blob in the document. A read is *per component*: each blob converts according to the basis it carries, and a blob missing the field errors rather than guessing. The `.sns` archive is `CU` only.
- Cost curves default to `power_units = IS.NaturalUnit()`; `CostCurve{T,U}`/`FuelCurve{T,U}` carry the unit as a type parameter (IS4).
- Units test filter: `julia --project=test test/runtests.jl test_units` (fast, ~22 s).

### Known audit items (do not silently "fix"; coordinate)

- **Resolved**: `check_rating_values(::Union{Line,MonitoredLine}, ::Float64)` at `src/utils/IO/branchdata_checks.jl` now mirrors its transformer sibling — it reads `component_base_power = _get_base_power(line)` and scales the raw CU rating fields through that, ignoring the passed `basemva`, instead of dividing the MW thresholds by a caller-supplied base. This closed the latent trap the previous note warned about: `base_power` was added to `Line`/`MonitoredLine` (and 10 other types whose base *is* the system base — see `base_power_kind`/`BasePowerKind` trait in `src/models/components.jl`), and `add_component!` now keeps that field synced to the system's base power on attachment.
- `_set_units_base!` at `src/base.jl:574` — `IS.get_units_info` is nothing-unguarded for detached components on the display path; wants the `isnothing(...) && error(...)` guard matching `_get_system_base_power` (`src/models/components.jl`).
- `src/base.jl:~3290` — copy-paste bug: `old_load.max_active_power` copied into `max_constant_reactive_power`. Known, pending a separate fix.
- Setters bypass validation and `set_bus!` does not maintain `sys.bus_numbers` — mutation after `add_component!` is convention-trusted.
- Sweep artifacts live in `.claude/`: `convertible_fields.txt` (72 convertible field names), `units_sweep_hits.txt`, `units_sweep_report.md`.

## Commands

```sh
julia --project=test -e 'using Pkg; Pkg.instantiate()'            # first time
julia --project=test -e 'using Pkg; Pkg.develop(path = ".")'      # once per clone: test env must dev the working tree
julia --project=test test/runtests.jl                             # full suite
julia --project=test test/runtests.jl test_plant_attributes       # single file (stem, no .jl)
julia --project=docs docs/make.jl                                 # docs must build cleanly
julia --project=scripts/formatter -e 'include("scripts/formatter/formatter_code.jl")'   # always before done
```

Compile-check after each edit: `julia --project=<psy6-workspace-root> -e 'using PowerSystems'`.

## Working with the data model

- Add components via `add_component!(sys, comp)`, never direct container insertion; retrieve via `get_component(Type, sys, name)` / `get_components(Type, sys)`.
- Time series always attach to components, never standalone.
- Bus numbers must be unique (validated when `runchecks=true`; keep it on during development).
- Public API is `get_*`/`set_*` accessors — no dot field access in user-facing code (tutorials/docs/tests included).
- Tests that mutate a PSB-built system must `deepcopy` first; read-only tests must not.

## Line policy reminders

- No version/compat bumps (stays 5.10.0 until release); local `[sources]` path pins for co-dev are fine but restore git pins before finishing.
- No shims, no deserialization aliases, no changelog edits. Regenerate old serialized systems instead of bridging.
- IS is pinned to the `IS4` branch via `[sources]`; a precompile `UndefVarError` usually means the IS checkout is on the wrong branch.
