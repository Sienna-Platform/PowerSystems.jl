# Sienna Practices — psy6 / Sienna 1.0 line

The rules for every repository of the **psy6 (Sienna 1.0) development line**. This file is identical
in each repository that has it; the master copy is in InfrastructureSystems.jl. Each repository's
`.claude/CLAUDE.md` imports it and adds the package specifics. The `sienna-dev` skill holds the
context: the full stack, the data pipeline, the glossary, and the psy5 → psy6 translation map. Load
the skill before cross-package work, a units question, or any port from psy5 code, PSI PRs, or older
docs — many psy5 facts are wrong here.

psy6 is a breaking rewrite. The released psy5 line has the same package names in other checkouts;
never mix the two lines.

## The stack and the blast radius

Acyclic DAG. Each package owns one concept and depends only on layers below it.

| Layer | Packages |
|---|---|
| 0 | InfrastructureSystems (IS), InfrastructureOptimizationModels (IOM) |
| 1 | PowerSystems (PSY) — the data model; no parsers |
| 2 | PowerNetworkMatrices (PNM), PowerFlowFileParser (PFFP, raw files), PowerTableDataParser (PTDP, tables) |
| 3 | PowerFlows (PF), PowerOperationsModels (POM), PowerSystemsInvestmentsPortfolios (PSIP) |
| 4 | PowerSimulations (PSI), PowerAnalytics (PA), PowerGraphics (PG), PowerTransmissionSecurityAnalysis (PTSA) |
| Support | PowerSystemCaseBuilder (PSB), PowerSystemsUpdater (PSU) |

A change can break every layer above it. Run the downstream suites in dependency order, not only the
suite of the package you edited:

- **IS** → everything. Time-series, serialization, and units changes are highest risk; extend the
  serialization round-trip tests when you touch them.
- **PSY** → PNM, PF, POM, PSB, PA. Also clear PSB's `data/serialized_system/` cache (it has no
  version-aware invalidation) and check SiennaSchemas drift — the schemas mirror PSY fields.
- **PNM** → PF and POM iterate its reduction maps and matrices; breakage is often latent.
- **PF** → POM, through `ext/PowerFlowsExt` and `PowerFlowEvaluator`.
- **IOM** → POM implements its stubs and calls non-exported `IOM._*` helpers, so a `_*` signature
  change is a breaking change. POM and IOM → PSI, which re-exports their public API.
- **SiennaSchemas** → both generated model packages and the GridDB unit registry regenerate from it.

## Before you edit

- State the target first: repository, branch, and checkout path, one line per repository. Read the
  branch with `git rev-parse --abbrev-ref HEAD` and diff against its real base. Never assume `psy6`.
- **A function with no caller in its own package is not dead code.** Every repository here is a
  library for the ones above it. Before you remove, rename, or narrow a function, method, accessor,
  or export — or add a required argument to it — grep for it in every sibling repository's `src/`
  and `test/`. If the sweep is clean and you still want it gone, ask first.
- Do exactly what the task asks. Do not restructure, delete, or "clean up" code the task does not name.

## Non-negotiables

- **No shims.** psy6 is a planned breaking release: no compat aliases, no deprecation paths, no
  defensive deserialization for renamed enums, no changelog entries. Fix the callers; regenerate old
  serialized systems.
- **No version or compat bumps in any `Project.toml` until release.** PSY reads 5.10.0 and IS 3.6.0
  on the 6.0/4.0 lines. A bump can reappear during a session; revert it. The `[sources]` pins, not
  the compat entries, select the psy6 line.
- **Never hand-edit generated code**: IS `src/generated/`, PSY `src/models/generated/`, the OpenAPI
  model packages, GridDB `unit_registry.sql`. Edit the descriptor or schema and regenerate.
- **Never extend a silent-failure pattern.** New code errors loudly with context (type, name,
  expectation). Known patterns, flagged for removal: a missing time series skips the device (POM
  `add_parameters`); a missing validation descriptor passes validation (IS); a non-converged power
  flow fills `PowerFlowData` with NaN (PF). No `isnothing(x) && continue` guards and no
  `Union{Nothing,T}` sentinel returns — use a Bool predicate plus an accessor that always returns a
  concrete value.
- **Never commit, stage, or push unless the user asks.** Leave changes unstaged; use `git add -N`
  for new files so they show in `git diff`. Plan files in `.claude/plans/` are local and never committed.

## Explicit units (SU / CU / NU)

The most important psy6 correctness rule. There is no stateful units mode; every unit-bearing value
goes through an explicit-unit API.

- Units are Unitful: `u"SU"` (system base), `u"CU"` (component base), `u"NU"` (natural, MW/MVA).
  Bring them into scope with `using PowerSystems: @u_str, PerUnit`. Bases do not mix. Say
  "component base"; "device base" is the psy5 name.
- Getters on convertible fields take the unit: `PSY.get_rating(br, u"SU")`. Setters take tagged
  values and reject bare floats: `set_rating_b!(line, 0.9u"SU")`.
- Optimization and power-flow build code passes `u"SU"` to every PSY getter on a convertible field;
  the models are all on the system base. PNM aggregators already return system base. A bare
  `PSY.get_*` on a convertible field in consumer code is a defect.
- The `SU`/`CU`/`NU` markers remain only for the unit parameter of cost curves and for the `units`
  mode of `to_file`.
- Angle limits are radians; do not convert them. An AC apparent-power rating RHS is squared:
  `(rating · factor)^2`.
- Wrong objective, limit, or rating magnitudes after a refactor: suspect units first.

## Environments and commands

No workspace-level Julia environment exists. Each package has its own environments:

```sh
julia --project -e 'using PackageName'                       # compile-check after each edit
julia --project=test -e 'using Pkg; Pkg.instantiate()'       # test env setup
julia --project=test test/runtests.jl                        # full suite
julia --project=docs docs/make.jl                            # docs build
julia --project=scripts/formatter -e 'include("scripts/formatter/formatter_code.jl")'
```

- Run tests with `--project=test`, never bare `julia` or bare `--project`. The test runners differ
  per repository (ReTest name filters, `@includetests` file stems, ParallelTestRunner); the
  repository guide gives the exact filter syntax.
- `Pkg.test()` honors the package's own `[sources]` git pins. To test against local checkouts,
  repoint `test/Project.toml` `[sources]` to local paths and restore the git pins before you finish.
  Do not `Pkg.develop` into an environment that carries `[sources]` git pins.
- PSB fixtures (`build_system(Category, "name")`) are cached with no version-aware invalidation.
  After a PSY change, clear `data/serialized_system/` or pass `force_build=true`. A test that mutates
  a PSB system must `deepcopy` it first; a read-only test must not.
- Python tooling: `python3`, never `python`.

## Definition of done

A change is done when all of these hold, and the report states each one with its evidence:

- It compiles (`julia --project -e 'using PackageName'`) after each file edit.
- The full test suite passes; report the pass count. A failure is acceptable only when you show it
  also fails on the base branch.
- The formatter ran and its output stays.
- The docs build when the change touches docstrings, exports, or public API. Fix Documenter
  `missing_docs` by registering the docstring in `@autodocs`/`@docs`, never with `warnonly`.
- The downstream suites from the blast-radius list pass, when the change touches an API they use.

## Julia code conventions

Style guide: <https://sienna-platform.github.io/InfrastructureSystems.jl/stable/style/>

- Dispatch, not runtime type checks. Do not branch on `isa` or `<:` in a function body; define a
  method per type. Runtime type checks lose type information and block specialization. The only
  accepted `isa` uses: filtering inside a `catch` block, and IS `serialize`/`deserialize` bodies.
- No large `Union{...}` aliases that enumerate concrete types to drive dispatch. Use an abstract
  supertype, or a trait when the grouping cuts across the type tree.
- Type stability: concrete return types (check with `@code_warntype`), concrete or parameterized
  struct fields (`struct Foo{T<:AbstractVector}; data::T; end`), typed containers
  (`Vector{Float64}()`), `const` globals.
- Hot paths: views and in-place `!` functions, pre-allocation instead of `push!` in loops, no
  splatting, no closures that box captured variables, no `try`/`catch`, function barriers around
  unstable code.
- Constructors use `function Foo() ... end`. Non-trivial bodies use `function ... end` with an
  explicit `return`; the assignment form is for genuine one-liners.
- Prefer `InfrastructureSystems.@assert_op` over `@assert`; `if/else` over the ternary operator;
  `iszero(x)` over `x == 0`; `isnothing(x)` over `x === nothing`.
- Cache lookups use the lazy form `get!(dict, key) do ... end`. The 3-argument
  `get!(dict, key, default)` evaluates `default` on every call.
- `UPPER_CASE` for constants. All exports in the main module file.
- User-facing code (tutorials, docs, public APIs, tests) uses `get_*`/`set_*` accessors, not dot
  field access. Accessor bodies may use dot access.
- Comments explain a non-obvious why. Default to no comment; no comments that restate the code or
  narrate a change.
- Mirror the existing structure when you add a parallel implementation (another solver, formulation,
  or backend), so that validation is a direct comparison.

## Tests

Test custom logic, not language guarantees: dispatch and predicates you defined, type-mapping tables
and accessors, serialization round-trips, custom `show` output, validation, error paths, and edge
cases. Do not test that a struct stores its constructor arguments, that inherited `==` works, or that
`obj isa T` holds where the type tree makes it true.

Constraint math and numerics need coefficient-level ground truth: compare the built model's
coefficients with an independently computed reference (the MODF suite asserts JuMP `AffExpr`
coefficients against `VirtualMODF` columns), not only objective values or convergence flags.

## Docs

Framework: [Diataxis](https://diataxis.fr/). Sienna guides:
[explanation](https://sienna-platform.github.io/InfrastructureSystems.jl/stable/docs_best_practices/explanation/) ·
[tutorials](https://sienna-platform.github.io/InfrastructureSystems.jl/stable/docs_best_practices/how-to/write_a_tutorial/) ·
[how-tos](https://sienna-platform.github.io/InfrastructureSystems.jl/stable/docs_best_practices/how-to/write_a_how-to/) ·
[docstrings](https://sienna-platform.github.io/InfrastructureSystems.jl/stable/docs_best_practices/how-to/write_docstrings_org_api/).
Docstrings cover every public-interface element, with
signatures and argument lists through `DocStringExtensions.TYPEDSIGNATURES`. Add "see also" links
between same-named methods. Most repositories keep the public and internals pages in
`docs/src/reference/`; PSY, PSI, and PSIP use `docs/src/api/`.

## Agents

Each repository defines two subagents, in `.claude/agents/` for Claude Code and in
`.opencode/agents/` for OpenCode:

- `sienna-dev` — implements one scoped task in one repository and reports against the definition
  of done. Use it when the main session coordinates and reviews.
- `sienna-reviewer` — reviews a diff against these rules and reports findings; it does not edit.

Both block `git commit` and `git push`.
