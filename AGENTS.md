# AGENTS.md — PowerSystems

PowerSystems is the power-system data model: the `System` container, the generated component types, explicit-units accessors, and the OpenAPI file I/O. It is part of the psy6 / Sienna 1.0 line, a breaking rewrite of the Sienna stack.

This file serves agents other than Claude Code, such as OpenCode. Claude Code loads the same
instructions from `.claude/` by itself.

## Load these first

`opencode.json` loads the first two files when OpenCode starts in this repository. When you start in
a parent folder, read them yourself before you edit anything.

1. `.claude/CLAUDE.md` — the guide for this repository: architecture, invariants, gotchas, and the verified commands.
2. `.claude/Sienna.md` — the rules for every Sienna psy6 repository.
3. The `sienna-dev` skill (`.claude/skills/sienna-dev/`) — the stack, the data pipeline, the glossary, and the psy5 → psy6 map. Load it before cross-package work or a port from psy5.

## Rules that always apply

These summarize `.claude/Sienna.md`; that file and the repository guide win where they say more.

- State the repository, branch, and checkout path before you edit. Never assume the branch.
- Never commit, stage, or push unless the user asks. Leave changes unstaged; use `git add -N` for
  new files. Never commit files in `.claude/plans/`.
- A function with no caller in this repository is not dead code. Before you remove, rename, or
  narrow anything, grep every sibling Sienna repository's `src/` and `test/`.
- No compat shims, deprecation aliases, or changelog entries. Fix the callers.
- No version or compat bumps in any `Project.toml`.
- Never hand-edit generated code. Edit the descriptor or schema and regenerate.
- Explicit units: getters on convertible fields take the unit (`u"SU"` in build code); setters take
  tagged values.
- Never add a silent failure. Error loudly with the type, name, and expectation.
- Use multiple dispatch, not `isa`/`<:` branching.

## Commands

The verified commands for this repository, including the test filter syntax, are in
`.claude/CLAUDE.md`. The common pattern:

```sh
julia --project -e 'using PowerSystems'                     # compile-check after each edit
julia --project=test test/runtests.jl                 # full test suite
julia --project=docs docs/make.jl                     # docs build
julia --project=scripts/formatter -e 'include("scripts/formatter/formatter_code.jl")'
```

A task is done when it compiles, the full suite passes (report the count), the formatter ran, and
the docs build if the public API changed.

## Agents

- `sienna-dev` — implements one scoped task and reports against the definition of done.
- `sienna-reviewer` — reviews a diff against the Sienna rules; it does not edit.

OpenCode reads them from `.opencode/agents/`; Claude Code from `.claude/agents/`.
