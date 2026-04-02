# Welcome to PowerSystems.jl

```@meta
CurrentModule = PowerSystems
```

!!! tip "Announcement"

    PowerSystems.jl upgraded to version 5.0 in November 2025, which included breaking changes.
    Visit the [v5.0 migration guide](@ref psy5_migration) for information on
    how to update your existing code from version 4.0.

## About

`PowerSystems.jl` is part of the National Laboratory of the Rockies'
[Sienna ecosystem](https://www.nlr.gov/analysis/sienna.html), an open source framework for
scheduling problems and dynamic simulations for power systems. The Sienna ecosystem can be
[found on github](https://github.com/NREL-Sienna/Sienna). It contains three applications:

  - [Sienna\Data](https://github.com/NREL-Sienna/Sienna?tab=readme-ov-file#siennadata) enables
    efficient data input, analysis, and transformation
  - [Sienna\Ops](https://github.com/NREL-Sienna/Sienna?tab=readme-ov-file#siennaops) enables
    enables system scheduling simulations by formulating and solving optimization problems
  - [Sienna\Dyn](https://github.com/NREL-Sienna/Sienna?tab=readme-ov-file#siennadyn) enables
    system transient analysis including small signal stability and full system dynamic
    simulations

Each application uses multiple packages in the [`Julia`](http://www.julialang.org)
programming language.

`PowerSystems.jl` is the foundation of Sienna\Data, and it is used with all three
applications. It provides a rigorous
data model using Julia structures to enable power systems modeling. `PowerSystems.jl` is
agnostic to a specific mathematical model and can be used for many model categories.

`PowerSystems.jl` provides tools to prepare and process data useful
for electric energy systems modeling. This package serves two purposes:

 1. It facilitates the development and open sharing of large data sets for Power Systems modeling
 2. It provides a data model that imposes discipline on model specification, addressing the challenge of design and terminology choices when sharing code and data.

The main features include:

  - Comprehensive and extensible library of data structures for electric systems modeling.
  - Large scale data set development tools based on common text based data formats
    (PSS/e `.raw` and `.dyr`, and `MATPOWER`) and configurable tabular data (e.g. CSV)
    parsing capabilities.
  - Optimized container for component data and time series supporting serialization to
    portable file formats and configurable validation routines.

## How To Use This Documentation

There are five main sections containing different information:

  - **Tutorials** - Detailed walk-throughs to help you *learn* how to use
    `PowerSystems.jl`
  - **How to...** - Directions to help *guide* your work for a particular task
  - **Explanation** - Additional details and background information to help you *understand*
    `PowerSystems.jl`, its structure, and how it works behind the scenes
  - **Reference** - Technical references and API for a quick *look-up* during your work
  - **Model Library** - Technical references of the data types and their functions that
    `PowerSystems.jl` uses to model power system components

`PowerSystems.jl` strives to follow the [Diataxis](https://diataxis.fr/) documentation
framework.

## Installation and Quick Links

  - [Sienna installation page](https://nrel-sienna.github.io/Sienna/SiennaDocs/docs/build/how-to/install/):
    Instructions to install `PowerSystems.jl` and other Sienna packages

!!! note

    `PowerSystems.jl` uses [`InfrastructureSystems.jl`](https://nrel-sienna.github.io/InfrastructureSystems.jl/stable/) as a utility library. Many methods are re-exported from `InfrastructureSystems.jl`.
    For most users there is no need to import `InfrastructureSystems.jl`.

  - [Sienna Documentation Hub](https://nrel-sienna.github.io/Sienna/SiennaDocs/docs/build/index.html):
    Links to other Sienna packages' documentation
