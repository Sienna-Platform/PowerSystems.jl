#src execute = true

# # [Parsing Data](@id parsing)
#
# `PowerSystems.jl` supports the creation of a `System` from a variety of common data formats:
#
# - [MATPOWER](@ref pm_data) (code copied with permission from [`PowerModels.jl`](https://github.com/lanl-ansi/PowerModels.jl))
# - [PSS/e RAW Files](@ref pm_data) (code copied with permission from [`PowerModels.jl`](https://github.com/lanl-ansi/PowerModels.jl))
# - [PSS/e DYR Files](@ref dyr_data)
# - [PowerSystems table data (CSV Files)](@ref table_data)
#
# ## [MATPOWER / PSS/e](@id pm_data)
#
# The following code will create a System from a MATPOWER or PSS/e file:
#
# ```julia
# sys = System(joinpath(data_dir, "case5.m"))
# ```
#
# ## [PSS/e dynamic data parsing](@id dyr_data)
#
# PSS/e's dynamic model library is extensive, we currently support parsing a limited amount
# of models out of the box.
#
# | Machine models | AVR Models | Prime Movers | PSS models |
# |----------------|------------|--------------|------------|
# | GENSAE         | IEEET1     | HYGOV        | IEEEST     |
# | GENSAL         | ESDC1A     | IEEEG1       |            |
# | GENROE         | ESAC1A     | GGOV1        |            |
# | GENCLS         | ESST4B     |              |            |
# | GENROU         | EXAC2      |              |            |
# |                | EXPIC1     |              |            |
# |                | ESAC6A     |              |            |
# |                | EXAC1      |              |            |
# |                | SCRX       |              |            |
# |                | ESDC2A     |              |            |
#
# ### Creating a Dynamic System using .RAW and .DYR data
#
# A `PowerSystems.jl` system can be created using a .RAW and a .DYR file. In this example we will create the following three bus system using the following RAW file:
#
# ```raw
# 0, 100, 33, 0, 0, 60  / 24-Apr-2020 19:28:39 - MATPOWER 7.0.1-dev
#
#
#      101, 'BUS 1       ',       138, 3,    1,    1, 1,           1.02,        0,  1.1,  0.9,  1.1,  0.9
#      102, 'BUS 2       ',       138, 2,    1,    1, 1,           1.0142,           0,  1.1,  0.9,  1.1,  0.9
#      103, 'BUS 3       ',       138, 2,    1,    1, 1,           1.0059,           0,  1.1,  0.9,  1.1,  0.9
# 0 / END OF BUS DATA, BEGIN LOAD DATA
#      101,  1, 1,    1,    1,       100,       20, 0, 0, 0, 0, 1, 1, 0
#      102,  1, 1,    1,    1,       70,       10, 0, 0, 0, 0, 1, 1, 0
#      103,  1, 1,    1,    1,       50,       10, 0, 0, 0, 0, 1, 1, 0
# 0 / END OF LOAD DATA, BEGIN FIXED SHUNT DATA
# 0 / END OF FIXED SHUNT DATA, BEGIN GENERATOR DATA
#      101,  1,       20,         0,       100,      -100,    1.02, 0,     100, 0, 0, 0, 0, 1, 1, 100,       318,         0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1
#      102,  1,       100,         0,       100,      -100,   1.0142, 0,     100, 0, 0.7, 0, 0, 1, 1, 100,       318,         0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1
#      103,  1,       100,         0,       100,      -100,   1.0059, 0,     100, 0, 0.2, 0, 0, 1, 1, 100,       318,         0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1
# 0 / END OF GENERATOR DATA, BEGIN BRANCH DATA
#      101,      103, 1,  0.01000,     0.12,      0.0,     250,     250,     250, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1
#      101,      102, 1,  0.01000,     0.12,      0.0,     250,     250,     250, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1
#      102,      103, 1,  0.01000,     0.12,      0.0,     250,     250,     250, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1
# 0 / END OF BRANCH DATA, BEGIN TRANSFORMER DATA
# 0 / END OF TRANSFORMER DATA, BEGIN AREA DATA
# 0 / END OF AREA DATA, BEGIN TWO-TERMINAL DC DATA
# 0 / END OF TWO-TERMINAL DC DATA, BEGIN VOLTAGE SOURCE CONVERTER DATA
# 0 / END OF VOLTAGE SOURCE CONVERTER DATA, BEGIN IMPEDANCE CORRECTION DATA
# 0 / END OF IMPEDANCE CORRECTION DATA, BEGIN MULTI-TERMINAL DC DATA
# 0 / END OF MULTI-TERMINAL DC DATA, BEGIN MULTI-SECTION LINE DATA
# 0 / END OF MULTI-SECTION LINE DATA, BEGIN ZONE DATA
# 0 / END OF ZONE DATA, BEGIN INTER-AREA TRANSFER DATA
# 0 / END OF INTER-AREA TRANSFER DATA, BEGIN OWNER DATA
# 0 / END OF OWNER DATA, BEGIN FACTS CONTROL DEVICE DATA
# 0 / END OF FACTS CONTROL DEVICE DATA, BEGIN SWITCHED SHUNT DATA
# 0 / END OF SWITCHED SHUNT DATA, BEGIN GNE DEVICE DATA
# 0 / END OF GNE DEVICE DATA, BEGIN INDUCTION MACHINE DATA
# 0 / END OF INDUCTION MACHINE DATA
# Q
# ```
#
# This system is a three bus system with three generators, three loads and three branches. The dynamic data for the generators is provided in the DYR file:
#
# ```raw
#   101 'GENROE' 1   8.000000  0.030000  0.400000  0.050000  6.500000  0.000000  1.800000
#   1.700000  0.300000  0.550000  0.250000  0.200000  0.039200  0.267200  /
#   101 'ESST1A' 1   1  1  0.01  99  -99  1  10  1  1  200  0  4  -4  4  -4  0  0  1  0  3  /
#   102 'GENCLS' 1   0.0   0.0 /
#   103 'GENCLS' 1   3.1   2.0 /
# ```
#
# That assigns a GENROU generator and a ESST1A voltage regulator at the generator located at bus 101, while classic machine models for the generators located at bus 102 and 103.
#
# To create the system we can do it passing both files directories:
#
# ```@example raw_dyr_system
# using PowerSystems
# data_dir = "../../../data" # hide
# RAW_dir = joinpath(data_dir, "PSSE_test/ThreeBusNetwork.raw")
# DYR_dir = joinpath(data_dir, "PSSE_test/TestGENCLS.dyr")
# dyn_system = System(RAW_dir, DYR_dir, runchecks = false)
# ```
#
# ## [PowerSystems Table Data](@id table_data)
#
# This is a custom format that allows users to define power system component data
# by category and column with custom names, types, and units.
#
# ### Categories
#
# Components for each category must be defined in their own CSV file. The
# following categories are currently supported:
#
# - branch.csv
# - bus.csv (required)
#   - columns specifying `area` and `zone` will create a corresponding set of `Area` and `LoadZone` objects.
#   - columns specifying `max_active_power` or `max_reactive_power` will create `PowerLoad` objects when nonzero values are encountered and will contribute to the `peak_active_power` and `peak_reactive_power` values for the
#   corresponding `LoadZone` object.
# - dc_branch.csv
# - gen.csv
# - load.csv
# - reserves.csv
# - storage.csv
#
# These must reside in the directory passed when constructing PowerSystemTableData.
#
# ### [Adding Time Series Data](@id parsing_time_series)
#
# PowerSystems requires a metadata file that maps components to their time series
# data in order to be able to automatically construct time_series from raw data
# files. The following fields are required for each time array:
#
# - simulation:  User description of simulation
# - resolution:  Resolution of time series in seconds
# - module:  Module that defines the abstract type of the component
# - category:  Type of component. Must map to abstract types defined by the "module"
#   entry (Bus, ElectricLoad, Generator, LoadZone, Reserve)
# - component_name:  Name of component
# - name:  User-defined name for the time series data.
# - normalization_factor:  Controls normalization of the data. Use 1.0 for
#   pre-normalized data. Use 'Max' to divide the time series by the max value in the
#   column. Use any float for a custom scaling factor.
# - scaling_factor_multiplier_module:  Module that defines the accessor function for the
# scaling factor
# - scaling_factor_multiplier:  Accessor function of the scaling factor
# - data_file:  Path to the time series data file
#
# Notes:
#
# - The "module", "category", and "component_name" entries must be valid arguments to retrieve
# a component using `get_component(${module}.${category}, sys, $name)`.
# - The "scaling_factor_multiplier_module" and the "scaling_factor_multiplier" entries must
# be sufficient to return the scaling factor data using
# `${scaling_factor_multiplier_module}.${scaling_factor_multiplier}(component)`.
#
# PowerSystems supports this metadata in either CSV or JSON formats. Refer to
# [RTS_GMLC](https://github.com/GridMod/RTS-GMLC/blob/master/RTS_Data/FormattedData/SIIP/timeseries_pointers.json)
# for an example.
#
# #### Performance considerations
#
# By default PowerSystems stores time series data in HDF5 files. It does not keep
# all of the data in memory. This means that every time you access a time_series
# PowerSystems will have to read the data from storage, which will add latency. If
# you know ahead of time that all of your data will fit in memory then you can
# change this behavior by passing `time_series_in_memory = true` when you create
# the System.
#
# If the time series data is stored in HDF5 then PowerSystems will use the tmp filesystem by
# default. You can change this by passing `time_series_directory = X` when you create the
# System. This is required if the time series data is larger than the amount of tmp space
# available.
#
# ### Customization
#
# The tabular data parser in `PowerSystems.jl` can be customized to read a variety of
# datasets by configuring:
#
#  - [which type of generator (`<:Generator`) to create based on the fuel and prime mover specifications](@ref csv_genmap)
#  - [property names](@ref csv_columns), [units](@ref csv_units), and per units conversions](@ref csv_per_unit) in *.csv files
#
# Here is an example of how to construct a System with all customizations listed in this section:
#
# ```julia
# data_dir = "/data/my-data-dir"
# base_power = 100.0
# descriptors = "./user_descriptors.yaml"
# timeseries_metadata_file = "./timeseries_pointers.json"
# generator_mapping_file = "./generator_mapping.yaml"
# data = PowerSystemTableData(
#     data_dir,
#     base_power,
#     descriptors;
#     timeseries_metadata_file = timeseries_metadata_file,
#     generator_mapping_file = generator_mapping_file,
# )
# sys = System(data, time_series_in_memory = true)
# ```
#
# Examples configuration files can be found in the [RTS-GMLC](https://github.com/GridMod/RTS-GMLC/) repo:
#
#  - [user_descriptors.yaml](https://github.com/GridMod/RTS-GMLC/blob/master/RTS_Data/FormattedData/SIIP/user_descriptors.yaml)
#  - [generator_mapping.yaml](https://github.com/GridMod/RTS-GMLC/blob/master/RTS_Data/FormattedData/SIIP/generator_mapping.yaml)
#
# #### [CSV Data Configurations](@id csv_data)
#
# ##### [Custom construction of generators](@id csv_genmap)
#
# PowerSystems supports custom construction of subtypes of the abstract type Generator based
# on `fuel` and `type`. The parsing code detects these fields in the raw data and then
# constructs the concrete type listed in the passed generator mapping file. The default file
# is `src/parsers/generator_mapping.yaml`. You can override this behavior by specifying your
# own file when constructing PowerSystemTableData.
#
# ##### [Column names](@id csv_columns)
#
# PowerSystems provides am input mapping capability that allows you to keep your own
# column names.
#
# For example, when parsing raw data for a generator the code expects a column
# called `name`. If the raw data instead defines that column as `GEN UID` then
# you can change the `custom_name` field under the `generator` category to
# `GEN UID` in your YAML file.
#
# To enable the parsing of a custom set of csv files, you can generate a configuration
# file (such as `user_descriptors.yaml`) from the defaults, which are stored
# in `src/descriptors/power_system_inputs.json`.
#
# ```python
# python ./bin/generate_config_file.py ./user_descriptors.yaml
# ```
#
# Next, edit this file with your customizations.
#
# Note that the user-specific customizations are stored in YAML rather than JSON
# to allow for easier editing. The next few sections describe changes you can
# make to this YAML file.  Do not edit the default JSON file.
#
# A list of `PowerSystemTableData` accepted columns for each CSV is available
# [here](@ref tabledata_input_config).
#
# ##### [Per-unit conversion](@id csv_per_unit)
#
# For more info on the per-unit conventions in `PowerSystems.jl`, refer to the [per-unit
# section of the system documentation](@ref per_unit).
#
# PowerSystems defines whether it expects a column value to be per-unit system base,
# per-unit device base, or natural units in `power_system_inputs.json`
# ([see default values](@ref tabledata_input_config)). If it expects a
# per-unit convention that differs from your values then you can set the `unit_system` in
# `user_descriptors.yaml` and PowerSystems will automatically convert the values. For
# example, if you have a `max_active_power` value stored in natural units (MW), but
# `power_system_inputs.json` specifies `unit_system: device_base`, you can enter
# `unit_system: natural_units` in `user_descriptors.yaml` and PowerSystems will divide
# the value by the value of the corresponding entry in the column identified by the
# `base_reference` field in `power_system_inputs.json`. You can also override the
# `base_reference` setting by adding `base_reference: My Column` to make device base
# per-unit conversion by dividing the value by the entry in `My Column`. System base
# per-unit conversions always divide the value by the system `base_power` value
# instantiated when constructing a `System`.
#
# ##### [Unit conversion](@id csv_units)
#
# PowerSystems provides a limited set of unit conversions. For example, if
# `power_system_inputs.json` indicates that a value's unit is degrees but
# your values are in radians then you can set `unit: radian` in
# your YAML file. Other valid `unit` entries include `GW`, `GWh`, `MW`, `MWh`, `kW`,
# and `kWh`.
#

# ## [`PowerSystemTableData` Accepted CSV Columns](@id tabledata_input_config)
#
# The following tables describe default CSV column definitions accepted by the
# `PowerSystemeTableData` parser defined by `src/descriptors/power_system_inputs.json`:
#

using PowerSystems # hide
function create_md() # hide
    descriptor = PowerSystems._read_config_file(joinpath( # hide
        dirname(pathof(PowerSystems)), # hide
        "descriptors", # hide
        "power_system_inputs.json", # hide
    )) # hide
    columns = [ # hide
        "name", # hide
        "description", # hide
        "unit", # hide
        "unit_system", # hide
        "base_reference", # hide
        "default_value", # hide
        "value_options", # hide
        "value_range", # hide
    ] # hide
    header = "| " * join(columns, " | ") * " |\n" * repeat("|----", length(columns)) * "|\n" # hide
    s = "" # hide
    for (cat, items) in descriptor # hide
        csv = "" # hide
        for name in PowerSystems.INPUT_CATEGORY_NAMES # hide
            if name[2] == cat # hide
                csv = name[1] # hide
                break # hide
            end # hide
        end # hide
        csv == "" && continue # hide
        s = string(s, "### $csv.csv:\n\n") # hide
        s = string(s, header) # hide
        for item in items # hide
            extra_cols = setdiff(keys(item), columns) # hide
            if !isempty(extra_cols) # hide
                throw(@error "config file fields not included in header" extra_cols) # hide
            end # hide
            row = [] # hide
            for col in columns # hide
                val = string(get(item, col, " ")) # hide
                if col == "default_value" && val == " " # hide
                    val = "*REQUIRED*" # hide
                end # hide
                push!(row, val) # hide
            end # hide
            s = string(s, "|" * join(row, "|") * "|\n") # hide
        end # hide
        s = string(s, "\n") # hide
    end # hide
    s = replace(s, r"[_$]" => s"\\\g<0>"); # hide
    return s # hide
end # hide
txt = create_md(); # hide
fname = joinpath(dirname(dirname(pathof(PowerSystems))), "docs", "src", "modeler_guide", "generated_inputs_tables.md") # hide
open(fname, "w") do io # hide
      write(io, txt) # hide
end # hide
println(" "); # hide

# APPEND_MARKDOWN("docs/src/modeler_guide/generated_inputs_tables.md")
