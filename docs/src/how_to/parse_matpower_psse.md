# [Parsing MATPOWER or PSS/e Files](@id pm_data)

The following code will create a System from a MATPOWER .m or PSS/e .raw file:

```@repl m_system
using PowerSystems
file_dir = joinpath(pkgdir(PowerSystems), "docs", "src", "tutorials", "tutorials_data")
sys = System(joinpath(file_dir, "case5.m"))
```

Originally, the parsing code was copied with permission from
[`PowerModels.jl`](https://github.com/lanl-ansi/PowerModels.jl) but over the years the code base
has had some divergence due to the need to adapt it to for large industrial cases.

The PSSe parser tries to handle correctly all the gotchas that result from the diverse modeling practices transmission engineers employ. However, it is impossible to anticipate all possible variations.

PowerSystems.jl parsing code has been tested and developed using large cases from North America
like the Western Electricity Coordinating Council (WECC) planning case and the Multiregional Modeling Working Group (MMWG) base case models. This parser has also been adapted to load cases in Latin America and the Caribbean and as many of the open data sets available only.

## [Conventions when parsing MATPOWER or PSS/e Files](@id parse_conventions)

!!! Info

    In PowerSystems v5, the parsing conventions changed from those in PowerSystems v4. You might experience different behaviors when loading MATPOWER or PSS/e Files.

PowerSystems.jl utilizes a data model that bridges the gap between operational simulations, such as Production Cost Analysis, and electrical engineering simulations, including power flows. Given the different practices in these domains, there are several discrepancies in how to handle data and we have made changes to make the modeling compatible.

In PowerSystems v5, we have implemented the following conventions for parsing PSSe files:

  - **BusType correction**: If a bus has a value set to ISOLATED in PSSe, we will confirm that the bus is not entirely disconnected from the network. If the bus is disconnected, it will be set to ISOLATED and set the field available to false. However, if the bus is connected to a generator, we will infer a bus of type PV and set the field 'available' to false. This correction also applies to Matpower. For any other device connected to the bus, we will set it to PQ and set the 'available' field to false. Check [`Understanding ACBusTypes`](@ref bustypes) for a detailed explanation.
  - **Parsing Synchronous Condensers**: If a generator is connected to a PV Bus with activer power set to 0.0, it will be parsed as a [`SynchronousCondenser`](@ref). This prevents for generators to be modeled as dispatchable [`ThermalStandard`](@ref) when it doesn't apply.
  - **Reading and Storing Transformer Data**: The transformer data is always stored in the devices
    ' base. See [`Transformer per unit transformations`](@ref transformers_pu) for additional details.
  - **Transformer's Susceptance**: When reading from Matpower we split the transformer's susceptance evenly between the `from` and `to` ends to make it a closer approximation to the model in PSSe.
  - **Tap transformer settings automated fix**: When the tap values in the RAW file are not withing the ranges defined in the same entry, PSSe performs a correction to the data. However, this correction isn't stored back in the file. The tap correction is done internally and is not exported from PSSE. Changes are not reflected in the exported file.PowerSystems.jl will correct the tap setting **and change the field in the transformer struct.**
  - **Reading and Storing Multi-Section Line Data**: `PowerSystems.jl` does not have a explicit multi-section line object. These devices are parsed as individual lines and the "dummy buses" are added to the system. The additional data is stored in the [`Line`](@ref) `ext` field. Further network reductions are performed using [`PowerNetworkMatrices.jl`](https://nrel-sienna.github.io/PowerNetworkMatrices.jl/stable/).
  - **Reading [`GeographicInfo`](@ref) data from substations (PSSe v35 only)**: If the file contains a substation section. The coordinates will be automatically loaded as a [`GeographicInfo`](@ref) attribute and assigned to the relevant buses.
  - **Use [`InterruptibleStandardLoad`](@ref) (PSSe v35 only)**: In newer versions of PSSe there is a flag for interruptible. Since PowerSystems.jl already has structures to model controllable load like [`InterruptiblePowerLoad`](@ref) and [`ShiftablePowerLoad`](@ref) a new type is used when parsing from PSSe to account of the interruptible behavior in economic modeling.
  - **Treatment of conforming and non-conforming flags**: See the section [`Conforming and Non-Conforming Loads`](@ref conf_loads). PowerSystems.jl uses an enum to represent this data but it does not implement specific models for this behavior.
  - **Breakers and Switches**: From the perspective of PowerSystems.jl breakers and switches are modeled as [`DiscreteControlledACBranch`](@ref). We use an enum to separate between the two but from the data structure perspective both use the same object definition.
  - **Rate data correction**: For rates B and C are set as `nothing` if the value in the file is zero. On the other hand, for rating A, the value gets corrected. If the raw file is zero, then set up the rating to infinite bound first and then reduced according to the voltage values. This proceedure still can produce a large amount of warning for situations where a single line is used to model a double circuit or a whole transmission corridor.
  - **Motor Loads**: We included a new device for explictly modeling motor loads. However, PSSe doesn't support explicit representations of these loads. The parser will print a warning in the log when we detect conditions commonly associated to motor load representations but won't be able to capture it directly.

### Pending parsing challenges

  - Managing the new format for rate data. In the old PSSe versions, there was Rate A, Rate B and Rate C. However, in newer versions there are 12 possible rates open to intepretation by the modeler. it can still be interpreted as A, B or C rates or a rate per month. PSSe doesn't provide any metada to interpret the rating bands provided.
  - Detecting motor loads modeled as generators. Same as with the case for the negative loads, motors are known to be modeled as machines with negative injections (i.e., loads) to match modeling them in transient studies as machines.
  - Automated transformer direction swaping. See [`this issue`](https://github.com/NREL-Sienna/PowerSystems.jl/issues/1423)
  - Parsing outage data.

### See also:

  - Parsing [PSS/e .dyr Files](@ref dyr_data), which also includes an example of parsing a
    .raw file
  - [Build a `System` from CSV files](@ref system_from_csv)
  - Parsing [time series](@ref parsing_time_series)
