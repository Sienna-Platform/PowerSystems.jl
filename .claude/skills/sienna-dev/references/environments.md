# psy6 environments, testing, and troubleshooting

## Environments

- **No workspace env.** The psy6 root has no `Project.toml`, `Manifest.toml`, or `wire_psy6.jl`.
  Compile-check and test from each package's own environments.
- **Per-package `Pkg.test()` honors that package's own `[sources]` git pins.**
  To test against local checkouts, temporarily repoint that repo's `test/Project.toml` `[sources]`
  to local paths, and restore before finishing. A dev'd dependency's own `[sources]` pins are
  ignored by a parent env — only the active project's count.
- Run tests with `julia --project=test`, docs with `--project=docs`, and the formatter with
  `--project=scripts/formatter`. Never run bare `julia`.
- Do not `Pkg.develop` into an environment that carries `[sources]` git pins: it re-resolves and
  can pull a mismatched PSY/IS pair from the registry. `test/Project.toml` already pins what it needs.
- Compile-check after each edit from the package env (`julia --project -e 'using PackageName'`)
  before moving on.
- Python tooling: use `python3`, never `python`. The venv at the psy6 workspace root is `.venv`.
  `just` is installed; prefer the recipes in a repo's `.justfile`.

```sh
julia --project=test test/runtests.jl                    # full suite
julia --project=test -e 'using Pkg; Pkg.instantiate()'   # instantiate test env
julia --project=docs docs/make.jl                        # build docs
```

## Test runners differ per repo

- **ReTest** (IS, IOM, PSIP): `runtests.jl` includes the test module and calls `run_tests()`; filters
  match **testset names**, not file names.
- **`@includetests` file stems** (PSY, PSB, PFFP, PTDP, PSU): `julia --project=test test/runtests.jl test_plant_attributes`.
- **ParallelTestRunner** (POM, PNM, PF): each top-level `test/test_*.jl` runs in its own Malt worker, in a
  fresh module rather than `Main`. Supports `--jobs=N` and `--list`.

See each repo's `.claude/CLAUDE.md` for its exact verified commands — they are not guessable.

## PSB cache

PowerSystemCaseBuilder has **no version-aware invalidation**. Clear `data/serialized_system/` after
any PSY change, or pass `force_build=true`. The CaseData artifact download can flake — retry once.

Tests that mutate a PSB-built system must `deepcopy` first; read-only tests must not.

## Troubleshooting

- **Tests fail unexpectedly / packages missing** → re-instantiate:
  `julia --project=test -e 'using Pkg; Pkg.instantiate()'`.
- **Poor performance, many allocations** → `@code_warntype` on the suspect function.
- **`UndefVarError` during precompile for a symbol that "should" exist** → mismatched upstream
  branch in a dev checkout; verify the upstream repo is on its psy6-line branch (IS→`IS4`,
  PSY/PNM/PF/PSB/PFFP/PTDP→`psy6`, IOM/PSU→`main`).
- **A PSB-built system deserializes strangely after a PSY change** → stale cache; clear
  `data/serialized_system/`.
- **Wrong magnitudes (rating², limits, objective) after a refactor** → units first; audit every
  `PSY.get_*` on a convertible field for its explicit unit argument.
- **Package registry unreachable (HTTP 403)** → prefix commands with `JULIA_PKG_SERVER=`.
