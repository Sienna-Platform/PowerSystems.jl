# [Parsing PSS/e dynamic data](@id dyr_data)

A `PowerSystems.jl` system can be created using a .RAW and a .DYR file. For a complete list of supported models in `PowerSystems.jl` version 5.0, including machine models, AVR models, turbine governors, PSS models, inverter models, and additional models, see the [Supported PSS/e Models](@ref psse_models_ref) reference page.

In this example we will create a three bus system from these example files:

```@example raw_dyr_system
using PowerSystems
file_dir = joinpath(pkgdir(PowerSystems), "docs", "src", "tutorials", "tutorials_data")
RAW_dir = joinpath(file_dir, "ThreeBusNetwork.raw")
DYR_dir = joinpath(file_dir, "TestGENCLS.dyr")
```

The data in the RAW file defines a three bus system with three generators, three loads and
three branches:

```raw
0, 100, 33, 0, 0, 60  / 24-Apr-2020 19:28:39 - MATPOWER 7.0.1-dev


     101, 'BUS 1       ',       138, 3,    1,    1, 1,           1.02,        0,  1.1,  0.9,  1.1,  0.9
     102, 'BUS 2       ',       138, 2,    1,    1, 1,           1.0142,           0,  1.1,  0.9,  1.1,  0.9
     103, 'BUS 3       ',       138, 2,    1,    1, 1,           1.0059,           0,  1.1,  0.9,  1.1,  0.9
0 / END OF BUS DATA, BEGIN LOAD DATA
     101,  1, 1,    1,    1,       100,       20, 0, 0, 0, 0, 1, 1, 0
     102,  1, 1,    1,    1,       70,       10, 0, 0, 0, 0, 1, 1, 0
     103,  1, 1,    1,    1,       50,       10, 0, 0, 0, 0, 1, 1, 0
0 / END OF LOAD DATA, BEGIN FIXED SHUNT DATA
0 / END OF FIXED SHUNT DATA, BEGIN GENERATOR DATA
     101,  1,       20,         0,       100,      -100,    1.02, 0,     100, 0, 0, 0, 0, 1, 1, 100,       318,         0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1
     102,  1,       100,         0,       100,      -100,   1.0142, 0,     100, 0, 0.7, 0, 0, 1, 1, 100,       318,         0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1
     103,  1,       100,         0,       100,      -100,   1.0059, 0,     100, 0, 0.2, 0, 0, 1, 1, 100,       318,         0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1
0 / END OF GENERATOR DATA, BEGIN BRANCH DATA
     101,      103, 1,  0.01000,     0.12,      0.0,     250,     250,     250, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1
     101,      102, 1,  0.01000,     0.12,      0.0,     250,     250,     250, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1
     102,      103, 1,  0.01000,     0.12,      0.0,     250,     250,     250, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1
0 / END OF BRANCH DATA, BEGIN TRANSFORMER DATA
0 / END OF TRANSFORMER DATA, BEGIN AREA DATA
0 / END OF AREA DATA, BEGIN TWO-TERMINAL DC DATA
0 / END OF TWO-TERMINAL DC DATA, BEGIN VOLTAGE SOURCE CONVERTER DATA
0 / END OF VOLTAGE SOURCE CONVERTER DATA, BEGIN IMPEDANCE CORRECTION DATA
0 / END OF IMPEDANCE CORRECTION DATA, BEGIN MULTI-TERMINAL DC DATA
0 / END OF MULTI-TERMINAL DC DATA, BEGIN MULTI-SECTION LINE DATA
0 / END OF MULTI-SECTION LINE DATA, BEGIN ZONE DATA
0 / END OF ZONE DATA, BEGIN INTER-AREA TRANSFER DATA
0 / END OF INTER-AREA TRANSFER DATA, BEGIN OWNER DATA
0 / END OF OWNER DATA, BEGIN FACTS CONTROL DEVICE DATA
0 / END OF FACTS CONTROL DEVICE DATA, BEGIN SWITCHED SHUNT DATA
0 / END OF SWITCHED SHUNT DATA, BEGIN GNE DEVICE DATA
0 / END OF GNE DEVICE DATA, BEGIN INDUCTION MACHINE DATA
0 / END OF INDUCTION MACHINE DATA
Q
```

The dynamic data for the generators is provided in the DYR file:

```raw
  101 'GENROE' 1   8.000000  0.030000  0.400000  0.050000  6.500000  0.000000  1.800000
  1.700000  0.300000  0.550000  0.250000  0.200000  0.039200  0.267200  /
  101 'ESST1A' 1   1  1  0.01  99  -99  1  10  1  1  200  0  4  -4  4  -4  0  0  1  0  3  /
  102 'GENCLS' 1   0.0   0.0 /
  103 'GENCLS' 1   3.1   2.0 /
```

That assigns a GENROU generator and a ESST1A voltage regulator at the generator located at bus 101, while classic machine models for the generators located at bus 102 and 103.

To create the [`System`](@ref) in `PowerSystems.jl`, we pass both files directories:

```@example raw_dyr_system
dyn_system = System(RAW_dir, DYR_dir; runchecks = false)
```

# Common Issue: Unique Bus Names

Please note that while PSS/e does not enforce unique bus names, `PowerSystems.jl` does. To reparse bus names to comply with this requirement the `bus_name_formatter` *kwarg  can be used in `System()` as shown in the example below:

```@example raw_dyr_system
dyn_system = System(
    RAW_dir,
    DYR_dir;
    bus_name_formatter = x -> strip(string(x["name"])) * "-" * string(x["index"]),
)
```

In this example the anonymous function `x -> strip(string(x["name"])) * "-" * string(x["index"])` takes the bus name and index from PSSe and concatenates them to produce the name.

### See also:

  - Parsing [Matpower or PSS/e RAW Files](@ref pm_data)
  - [Build a `System` from CSV files](@ref system_from_csv)
  - Parsing [time series](@ref parsing_time_series)
