# Public API Reference

## Modeling

```@autodocs
Modules = [PowerSystems]
Pages   = ["PowerSystems.jl",
           "branches.jl",
           "components.jl",
           "injection.jl",
           "devices.jl",
           "loads.jl",
           "supplemental_constructors",
           "generation.jl",
           "reserves.jl",
           "storage.jl",
           "services.jl",
           "topological_elements.jl",
           "dynamic_models.jl",
           "static_models.jl",
           "subsystems.jl",
           "static_injection_subsystem.jl",
           "dynamic_models.jl",
           "operational_cost.jl",
           "cost_function_timeseries.jl",
           "definitions.jl"
           ]
Public = true
Private = false
```

## Supplemental Attributes

```@autodocs
Modules = [PowerSystems]
Pages   = ["outages.jl",
           "impedance_correction.jl",
           "plant_attribute.jl"
           ]
Public = true
Private = false
```

```@autodocs
Modules = [IS]
Pages   = ["geographic_supplemental_attribute.jl"
        ]
Order = [:type, :function]
Filter = t -> nameof(t) in names(PowerSystems)
```

## Operating Costs

```@autodocs
Modules = [IS]
Pages   = ["production_variable_cost_curve.jl",
            "cost_aliases.jl",
            "value_curve.jl",
           ]
Order = [:type, :function]
Filter = t -> nameof(t) in names(PowerSystems)
```

## Time Series

```@autodocs
Modules = [IS]
Pages   = ["abstract_time_series.jl",
           "deterministic.jl",
           "deterministic_single_time_series.jl",
           "probabilistic.jl",
           "scenarios.jl",
           "static_time_series.jl",
           "single_time_series.jl",
           "forecasts.jl",
           ]
Order = [:type, :function]
Filter = t -> nameof(t) in names(PowerSystems)
```

```@autodocs
Modules = [IS]
Pages   = ["time_series_cache.jl",
            "time_series_interface.jl",
            "time_series_structs.jl",
            "time_series_storage.jl",
            "time_series_parser.jl",
            "utils/print.jl"]
Order = [:type, :function]
Filter = t -> nameof(t) in names(PowerSystems)
```

## System

```@autodocs
Modules = [PowerSystems]
Pages   = ["get_components_interface.jl", "base.jl"]
Public = true
Private = false
Filter = t -> t ∈ [System]
```

```@autodocs
Modules = [PowerSystems]
Pages   = ["get_components_interface.jl", "base.jl"]
Public = true
Private = false
Filter = t -> t ∉ [System]
```

```@autodocs
Modules = [PowerSystems]
Pages   = ["utils/print.jl",
           "utils/generate_struct_files.jl"]
Public = true
Private = false
Filter = t -> t ∉ [System]
```

## Advanced Component Selection

The primary way to retrieve components in PowerSystems.jl is with the [`get_components`](@ref) and similar `get_*` methods above. The following `ComponentSelector` interface offers advanced, repeatable component selection primarily for multi-scenario post-processing analytics. See [`PowerAnalytics.jl`](https://nrel-sienna.github.io/PowerAnalytics.jl/stable/).

```@autodocs
Modules = [IS]
Pages   = ["component_selector.jl"]
Filter  = t -> !(t isa AbstractString) && nameof(t) in names(PowerSystems) && getproperty(PowerSystems, nameof(t)) === t && !(nameof(t) in [:SingularComponentSelector, :PluralComponentSelector, :DynamicallyGroupedComponentSelector, :subtype_to_string, :component_to_qualified_string])
```

```@autodocs
Modules = [PowerSystems]
Pages   = ["component_selector_interface.jl"]
Public  = true
Private = false
```

```@autodocs
Modules = [IS]
Pages   = ["component_selector.jl"]
Filter  = t -> !(t isa AbstractString) && nameof(t) in names(PowerSystems) && getproperty(PowerSystems, nameof(t)) === t && (nameof(t) in [:SingularComponentSelector, :PluralComponentSelector, :DynamicallyGroupedComponentSelector, :subtype_to_string, :component_to_qualified_string])
```

## Additional Component Methods

```@autodocs
Modules = [PowerSystems]
Pages   = ["supplemental_accessors.jl"]
Public = true
Private = false
```

## [Deprecated Methods](@id deprecated)

```@autodocs
Modules = [PowerSystems]
Pages   = ["deprecated.jl"]
Public = true
Private = false
```

## Parsing

```@autodocs
Modules = [PowerSystems]
Pages = ["parsers/power_system_table_data.jl",
         "parsers/power_models_data.jl",
         "parsers/TAMU_data.jl",
         "parsers/psse_dynamic_data.jl",
         "parsers/pm_io/common.jl"]
Public = true
Private = false
Filter = t -> t ∉ [System]
```

## [Logging](@id logging)

```@autodocs
Modules = [PowerSystems]
Pages = ["utils/logging.jl"]
Public = true
Private = false
```
