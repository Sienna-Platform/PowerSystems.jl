# PowerSystems.jl

[![Main - CI](https://github.com/Sienna-Platform/PowerSystems.jl/workflows/Main%20-%20CI/badge.svg)](https://github.com/Sienna-Platform/PowerSystems.jl/actions/workflows/main-tests.yml)
[![codecov](https://codecov.io/gh/Sienna-Platform/PowerSystems.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Sienna-Platform/PowerSystems.jl)
[![Documentation](https://github.com/Sienna-Platform/PowerSystems.jl/actions/workflows/docs.yml/badge.svg)](https://nrel-sienna.github.io/PowerSystems.jl/stable/)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17703517.svg)](https://doi.org/10.5281/zenodo.17703517)
[<img src="https://img.shields.io/badge/slack-@Sienna/PSY-sienna.svg?logo=slack">](https://join.slack.com/t/nrel-sienna/shared_invite/zt-glam9vdu-o8A9TwZTZqqNTKHa7q3BpQ)
[![PowerSystems.jl Downloads](https://img.shields.io/badge/dynamic/json?url=http%3A%2F%2Fjuliapkgstats.com%2Fapi%2Fv1%2Ftotal_downloads%2FPowerSystems&query=total_requests&label=Downloads)](http://juliapkgstats.com/pkg/PowerSystems)


The `PowerSystems.jl` package provides a rigorous data model using Julia structures to enable power systems analysis and modeling. In addition to stand-alone system analysis tools and data model building, the `PowerSystems.jl` package is used as the foundational data container for the [PowerSimulations.jl](https://github.com/NREL/PowerSimulations.jl) and [PowerSimulationsDynamics.jl](https://github.com/Sienna-Platform/PowerSimulationsDynamics.jl) packages. `PowerSystems.jl` supports a limited number of data file formats for parsing.

## Version Advisory

- PowerSystems will work with Julia v1.6+.

## Device data enabled in PowerSystems

- Generators (Thermal, Renewable and Hydro)
- Transmission (Lines, and Transformers)
- Active Flow control devices (DC Lines and Phase Shifting Transformers)
- TwoTerminal and Multiterminal HVDC
- Topological elements (Buses, Arcs, Areas)
- Storage (Batteries)
- Load (Static, and Curtailable)
- Services (Reserves, Transfers)
- TimeSeries (Deterministic, Scenarios, Probabilistic)
- Dynamic Generators Models
- Dynamic Inverter Models

For information on using the package and a more extensive list of device data enabled, see the [stable documentation](https://nrel-sienna.github.io/PowerSystems.jl/stable/). Use the [in-development documentation](https://nrel-sienna.github.io/PowerSystems.jl/dev/) for the version of the documentation which contains the unreleased features.

## Parsing capabilities in PowerSystems

- MATPOWER CaseFormat
- PSS/e - PTI Format v30 (partial support), v33, v35 (.raw and .dyr files)
- [RTS-GMLC](https://github.com/GridMod/RTS-GMLC/tree/master/RTS_Data/SourceData) table data format

## Development

Contributions to the development and enhancement of PowerSystems are welcome. Please see
[CONTRIBUTING.md](https://github.com/NREL/PowerSystems.jl/blob/main/CONTRIBUTING.md) for
code contribution guidelines.

## Citing PowerSystems.jl

[Paper describing `PowerSystems.jl`](https://www.sciencedirect.com/science/article/pii/S2352711021000765)

```bibtex
@article{LARA2021100747,
  title = {PowerSystems.jl — A power system data management package for large scale modeling},
  journal = {SoftwareX},
  volume = {15},
  pages = {100747},
  year = {2021},
  issn = {2352-7110},
  doi = {https://doi.org/10.1016/j.softx.2021.100747},
  url = {https://www.sciencedirect.com/science/article/pii/S2352711021000765},
  author = {José Daniel Lara and Clayton Barrows and Daniel Thom and Dheepak Krishnamurthy and Duncan Callaway},
  keywords = {Power Systems, Julia, Energy}
}
```

## License

PowerSystems is released under a BSD [license](https://github.com/NREL/PowerSystems.jl/blob/main/LICENSE).
PowerSystems has been developed as part of the Scalable Integrated Infrastructure Planning (SIIP)
initiative at the U.S. Department of Energy's National Laboratory of the Rockies ([NLR](https://www.nlr.gov/), formerly NREL) Software Record SWR-23-105.
