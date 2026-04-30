# Sienna Programming Practices

This document describes general programming practices and conventions that apply across all Sienna packages (PowerSystems.jl, PowerSimulations.jl, PowerFlows.jl, PowerNetworkMatrices.jl, InfrastructureSystems.jl, etc.).

## Performance Requirements

**Priority:** Critical. See the [Julia Performance Tips](https://docs.julialang.org/en/v1/manual/performance-tips/).

### Anti-Patterns to Avoid

#### Type instability

Functions must return consistent concrete types. Check with `@code_warntype`.

- Bad: `f(x) = x > 0 ? 1 : 1.0`
- Good: `f(x) = x > 0 ? 1.0 : 1.0`

#### Abstract field types

Struct fields must have concrete types or be parameterized.

- Bad: `struct Foo; data::AbstractVector; end`
- Good: `struct Foo{T<:AbstractVector}; data::T; end`

#### Untyped containers

- Bad: `Vector{Any}()`, `Vector{Real}()`
- Good: `Vector{Float64}()`, `Vector{Int}()`

#### Non-const globals

- Bad: `THRESHOLD = 0.5`
- Good: `const THRESHOLD = 0.5`

#### Unnecessary allocations

- Use views instead of copies (`@view`, `@views`)
- Pre-allocate arrays instead of `push!` in loops
- Use in-place operations (functions ending with `!`)

#### Captured variables

Avoid closures that capture variables causing boxing. Pass variables as function arguments instead.

#### Splatting penalty

Avoid splatting (`...`) in performance-critical code.

#### Abstract return types

Avoid returning `Union` types or abstract types.

#### Using `isa` in function logic

**ABSOLUTELY FORBIDDEN unless the user explicitly asks for it.** Never write code that uses `isa` checks for type-based branching. This is always wrong — use multiple dispatch instead.

- Bad: `if x isa Float64 ... elseif x isa Int ... end`
- Good: Use multiple dispatch with specific type signatures
- Bad: `function f(x); if x isa AbstractVector return sum(x) else return x end; end`
- Good: `f(x::AbstractVector) = sum(x); f(x::Number) = x`

**Why this matters:** `isa` checks force the compiler to handle multiple code paths at runtime, losing type information and preventing specialization. Multiple dispatch allows the compiler to generate optimized code for each type. Using `isa` is an anti-pattern that defeats Julia's core design.

### Best Practices

- Use `@inbounds` when bounds are verified
- Use broadcasting (dot syntax) for element-wise operations
- Avoid `try-catch` in hot paths
- Use function barriers to isolate type instability

> Apply these guidelines with judgment. Not every function is performance-critical. Focus optimization efforts on hot paths and frequently called code.

## Code Conventions

Style guide: <https://sienna-platform.github.io/InfrastructureSystems.jl/stable/style/>

Formatter (JuliaFormatter): Use the formatter script provided in each package.

Key rules:

- Constructors: use `function Foo()` not `Foo() = ...`
- Asserts: prefer `InfrastructureSystems.@assert_op` over `@assert`
- Globals: `UPPER_CASE` for constants
- Exports: all exports in main module file
- Comments: complete sentences, describe why not how

## Documentation Practices and Requirements

Framework: [Diataxis](https://diataxis.fr/)

Sienna guide: <https://sienna-platform.github.io/InfrastructureSystems.jl/stable/docs_best_practices/explanation/>

Docstring requirements:

- Scope: all elements of public interface (IS is selective about exports)
- Include: function signatures and arguments list
- Automation: `DocStringExtensions.TYPEDSIGNATURES` (`TYPEDFIELDS` used sparingly in IS)
- See also: add links for functions with same name (multiple dispatch)

API docs:

- Public: typically in `docs/src/api/public.md` using `@autodocs` with `Public=true, Private=false`
- Internals: typically in `docs/src/api/internals.md`

## Design Principles

- Elegance and concision in both interface and implementation
- Fail fast with actionable error messages rather than hiding problems
- Validate invariants explicitly in subtle cases
- Avoid over-adherence to backwards compatibility for internal helpers

## Contribution Workflow

Branch naming: `feature/description` or `fix/description`

1. Create feature branch
2. Follow style guide and run formatter
3. Ensure tests pass
4. Submit pull request

## AI Agent Guidance

**Key priorities:** Read existing patterns first, maintain consistency, use concrete types in hot paths, run formatter, add docstrings to public API, ensure tests pass.

**Critical rules:**
- Always use `julia --project=<env>` (never bare `julia`)
- **NEVER use `isa` in function logic** — use multiple dispatch instead. This is absolutely forbidden unless the user explicitly asks for it.
- Never edit auto-generated files directly
- Verify type stability with `@code_warntype` for performance-critical code
- Consider downstream package impact

## Julia Environment Best Practices

**CRITICAL:** Always use `julia --project=<env>` when running Julia code in Sienna repositories. **NEVER** use bare `julia` or `julia --project` without specifying the environment. Each package typically defines dependencies in `test/Project.toml` for testing.

Common patterns:

```sh
# Run tests (using test environment)
julia --project=test test/runtests.jl

# Run specific test
julia --project=test test/runtests.jl test_file_name

# Run expression
julia --project=test -e 'using PackageName; ...'

# Instantiate environment
julia --project=test -e 'using Pkg; Pkg.instantiate()'

# Build docs (using docs environment)
julia --project=docs docs/make.jl
```

**Why this matters:** Running without `--project=<env>` will fail because required packages won't be available in the default environment. The test/docs environments contain all necessary dependencies for their respective tasks.

## Troubleshooting

**Type instability**
- Symptom: Poor performance, many allocations
- Diagnosis: `@code_warntype` on suspect function
- Solution: See performance anti-patterns above

**Formatter fails**
- Symptom: Formatter command returns error
- Solution: Run the formatter script provided in the package (e.g., `julia -e 'include("scripts/formatter/formatter_code.jl")'`)

**Test failures**
- Symptom: Tests fail unexpectedly
- Solution: `julia --project=test -e 'using Pkg; Pkg.instantiate()'`
