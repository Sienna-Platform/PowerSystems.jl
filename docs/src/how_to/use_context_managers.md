# Use Context Managers for Efficient Bulk Operations

`PowerSystems.jl` provides several "context manager" functions that help you perform bulk
operations more efficiently and safely. These functions temporarily change system settings or
optimize batch operations, then automatically restore the original state when complete.

Context managers in PowerSystems follow a pattern similar to `Logging.with_logger` in Julia.
They accept a function (typically as a `do` block) that executes with modified settings,
ensuring cleanup even if errors occur.

## Available Context Managers

PowerSystems provides three main context managers:

 1. [`with_units_base`](@ref) - Temporarily change unit system for getting/setting component data
 2. [`begin_supplemental_attributes_update`](@ref) - Optimize bulk addition/removal of supplemental attributes
 3. [`begin_time_series_update`](@ref) - Optimize bulk addition of time series data

## Using `with_units_base`

The [`with_units_base`](@ref) function temporarily changes the [unit system](@ref per_unit)
for a `System` or `Component`, executes your code, then automatically restores the original
unit system. This is useful when you need to retrieve or set values in a specific unit system
without permanently changing the system's configuration.

!!! note

    You can specify the unit system using either the `UnitSystem` enum (e.g.,
    `UnitSystem.NATURAL_UNITS`) or a string (e.g., `"NATURAL_UNITS"`). Both forms are
    supported and equivalent.

### Example: Getting Component Data in Natural Units

```julia
using PowerSystems
using PowerSystemCaseBuilder

# Load a system
sys = build_system(PSISystems, "c_sys5_pjm")
gen = first(get_components(ThermalStandard, sys))

# Get active power in natural units (MW) regardless of system's unit base
active_power_mw = with_units_base(sys, UnitSystem.NATURAL_UNITS) do
    get_active_power(gen)
end

# The system's unit base is automatically restored after the block
```

### Example: Setting Multiple Component Values in Natural Units

```julia
# Temporarily change units to add/modify multiple components in natural units
with_units_base(sys, "NATURAL_UNITS") do
    for gen in get_components(ThermalStandard, sys)
        # Set values in MW, MVA, etc.
        set_active_power!(gen, 150.0)  # MW
        set_rating!(gen, 200.0)        # MVA
    end
end

# System automatically returns to original unit base
```

### Component-Level Context Manager

You can also use `with_units_base` on individual components:

```julia
active_power_mw = with_units_base(gen, UnitSystem.NATURAL_UNITS) do
    get_active_power(gen)
end
```

!!! tip

    The `with_units_base` context manager is particularly useful when you need to work with
    data in natural units (MW, MVA, etc.) while keeping your system configured in per-unit
    for optimization or simulation purposes.

## Using `begin_supplemental_attributes_update`

The [`begin_supplemental_attributes_update`](@ref) function optimizes performance when adding
or removing many supplemental attributes. It batches operations together, reducing overhead
from repeated index updates.

If an error occurs during the update, all changes are automatically reverted, ensuring data
consistency.

### Example: Adding Multiple Supplemental Attributes

```julia
using PowerSystems

# Define some supplemental attributes (e.g., outage data)
outage1 = FixedForcedOutage(;
    mean_time_to_recovery = 8.0,
    mean_time_to_failure = 1000.0,
)

outage2 = FixedForcedOutage(;
    mean_time_to_recovery = 12.0,
    mean_time_to_failure = 800.0,
)

# Get components to attach attributes to
gen1 = get_component(ThermalStandard, sys, "322_CT_6")
gen2 = get_component(ThermalStandard, sys, "323_CC_1")

# Use context manager for efficient bulk addition
begin_supplemental_attributes_update(sys) do
    add_supplemental_attribute!(sys, gen1, outage1)
    add_supplemental_attribute!(sys, gen2, outage2)
    # Add many more attributes...
end
```

### Example: Bulk Operations with Error Handling

```julia
# If an error occurs, all changes are automatically reverted
try
    begin_supplemental_attributes_update(sys) do
        add_supplemental_attribute!(sys, component1, attribute1)
        add_supplemental_attribute!(sys, component2, attribute2)
        # ... more operations ...
        error("Something went wrong!")  # All changes will be reverted
    end
catch e
    @warn "Operation failed, changes were reverted" exception=e
end
```

!!! note

    Without using this context manager, each individual call to
    `add_supplemental_attribute!` updates internal indexes separately, which can be slow
    when adding many attributes. The context manager batches all updates together for
    better performance.

## Using `begin_time_series_update`

The [`begin_time_series_update`](@ref) function optimizes performance when adding many time
series arrays by keeping the HDF5 file open and batching SQLite database operations. This
reduces the overhead of repeatedly opening/closing files and performing individual database
transactions.

If an error occurs during the update, changes are automatically reverted.

!!! note

    This context manager is not necessary for in-memory time series stores, only for
    HDF5-backed storage.

### Example: Adding Multiple Time Series

```julia
using PowerSystems
using Dates

# Create time series data
resolution = Dates.Hour(1)
data = Dict(
    DateTime("2020-01-01T00:00:00") => ones(24),
    DateTime("2020-01-02T00:00:00") => ones(24) * 1.1,
)

# Get components
generators = collect(get_components(ThermalStandard, sys))

# Use context manager for efficient bulk addition
begin_time_series_update(sys) do
    for (i, gen) in enumerate(generators)
        forecast = Deterministic(
            "max_active_power",
            data,
            resolution;
            scaling_factor_multiplier = get_max_active_power,
        )
        add_time_series!(sys, gen, forecast)
    end
end
```

### Example: Adding Time Series from Multiple Sources

```julia
# When you have time series data from multiple sources
begin_time_series_update(sys) do
    for component in get_components(Generator, sys)
        # Create time series data specific to each component
        # (In practice, this might come from CSV files, databases, or other sources)
        component_data = Dict(
            DateTime("2020-01-01T00:00:00") => rand(24),
            DateTime("2020-01-02T00:00:00") => rand(24),
        )

        forecast = Deterministic(
            "max_active_power",
            component_data,
            resolution;
            scaling_factor_multiplier = get_max_active_power,
        )
        add_time_series!(sys, component, forecast)
    end
end
```

!!! tip

    When adding thousands of time series arrays, using `begin_time_series_update` can
    provide significant performance improvements by reducing file I/O and database
    transaction overhead.

## Best Practices

 1. **Always use context managers for bulk operations**: When adding multiple supplemental
    attributes or time series, use the appropriate context manager to improve performance.

 2. **Automatic cleanup**: Context managers ensure cleanup happens even if errors occur, so
    your system state remains consistent.

 3. **Nested context managers**: You can nest context managers if needed:

    ```julia
    with_units_base(sys, "NATURAL_UNITS") do
        begin_time_series_update(sys) do
            # Add time series with natural unit scaling factors
            for gen in get_components(Generator, sys)
                # ... add time series ...
            end
        end
    end
    ```

 4. **Error handling**: The context managers automatically handle cleanup, but you can still
    use `try-catch` blocks for application-specific error handling:

    ```julia
    try
        begin_time_series_update(sys) do
            # ... operations ...
        end
    catch e
        @error "Time series update failed" exception=e
        # Handle application-specific recovery
    end
    ```

## See Also

  - [Per-unit Conventions](@ref per_unit) - Learn more about unit systems
  - [Supplemental Attributes](@ref supplemental_attributes) - Details on supplemental attribute usage
  - [Working with Time Series Data](@ref tutorial_time_series) - Tutorial on time series handling
  - [Improve Performance with Time Series Data](@ref) - Additional time series performance tips
