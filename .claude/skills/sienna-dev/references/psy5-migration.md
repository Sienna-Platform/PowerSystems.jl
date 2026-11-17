# psy5 → psy6 translation map

Anything read from psy5 repos, PSI PRs, or older docs must be translated before you act on it.
The psy5 repos remain the richer source for *numerics and domain* knowledge (PNM solver rules, PF
solver design, PSB cache semantics) — that transfers. The *API and package* facts below do not.

| psy5 concept | psy6 equivalent |
|---|---|
| PowerSimulations.jl (PSI) | operations layer split into IOM (domain-neutral core) + POM (power formulations); simulation orchestration lives in psy6 PSI (branch `psy6`, layer 4, on IOM + POM) |
| `set_units_base_system!` stateful global units | explicit-unit getters/setters (`get_x(c, u"SU")`, tagged setters). In PSY the three stateful entry points (`with_units_base`, `set_units_base_system!`, `get_units_base`) do not exist |
| `PM.AbstractPowerModel` / PowerModels re-exports | POM-native `*NetworkModel` structs in `core/network_formulations.jl`, built directly against JuMP with no PowerModels.jl dependency |
| PSY `src/parsers/` (Matpower/PSSE/tabular) | PowerFlowFileParser.jl (raw files) and PowerTableDataParser.jl (tabular). Do not re-add parsing to PSY |
| `OptimizationProblemResults`, `RunStatus.SUCCESSFULLY_FINISHED` | `IOM.OptimizationProblemOutputs`, `RunStatus.SUCCESSFULLY_FINALIZED` |
| "never modify PSI `src/core/optimization_container.jl`" | same rule, now IOM `src/core/optimization_container.jl` |
| LODF-based security constraints; generator-side G-1 | branch-side MODF (`VirtualMODF` / `ContingencySpec`); gen-side G-1 removed — do not reintroduce |
| `IS.UnitSystem` enum (cost curves, serialization) | unit marker as a type parameter: `CostCurve{T,U}` with `SystemBaseUnit()` etc. The legacy enum is not accepted anywhere in the cost-curve API |
| PSY native JSON serialization | removed; `to_file`/`from_file` write and read the OpenAPI document (directory, `.json`, `.sns`). The OpenAPI ⇄ GridDB bridge is not built |
| `Transformer2W` / `TapTransformer` / `PhaseShiftingTransformer` | `TwoWindingTransformer` — the name was an abstract supertype in psy5 and is a concrete struct in psy6, so old code changes meaning instead of failing |
| `Transformer3W` / `PhaseShiftingTransformer3W` | `ThreeWindingTransformer` — same abstract→concrete hazard |
| "PSI PR #NNNN added X" | check POM `.claude/pom_port_plan.md` before assuming X exists in POM |

## Porting rules

- Formulation-specific code → POM; generic optimization core → IOM. Adapt to POM's type-based
  dispatch; do not copy PSI code verbatim.
- Simulation orchestration is PSI's, not IOM's or POM's. Do not port it into IOM or POM.
- Do not copy PSI `Project.toml` version or compat bumps when porting a PR.
- When a symbol seems "not defined in IOM", check whether PR #104 ("Redistribute operation models")
  moved it to POM. Define or dispatch on the POM chain; do not re-add it to IOM.
