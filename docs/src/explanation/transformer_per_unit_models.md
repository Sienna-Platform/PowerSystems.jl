# [Transformer per unit transformations](@id transformers_pu)

The per-unit (p.u.) system is a fundamental tool in power system analysis, especially when dealing with transformers. It simplifies calculations by normalizing all quantities (voltage, current, power, impedance) to a common base. This effectively "retains" the ideal transformer from the circuit diagram because the per-unit impedance of a transformer remains the same when referred from one side to the other. This page is not a comprehensive guide on transformer per-unit calculations, a more in depth explanation can be found in [`this link`](https://en.wikipedia.org/wiki/Per-unit_system) or basic power system literature.

For a step-by-step guide to establishing base values and converting transformer impedances
to a new per-unit base, see
[Convert Transformer Impedances Between Per-Unit Bases](@ref).

!!! note

    The return value of the getter functions, e.g., [`get_x`](@ref) for the transformer impedances will perform the transformations following the convention in [`Per-unit Conventions`](@ref per_unit).
