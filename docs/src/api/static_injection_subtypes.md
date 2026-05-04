# StaticInjection Subtypes Comparison

This document summarizes the similarities and differences between [`StaticInjection`](@ref) subtypes in PowerSystems.jl, with emphasis on generators, loads, storage, and sources. Some control-related subtypes--like FACTS devices--are omitted from the below charts, simply because they have very little in common with the other subtypes. For all subtypes of [`StaticInjection`](@ref), see [Type Tree](@ref "Type Tree").

* * *

## Power Limits Fields Comparison

### Generators

| Type                           | `active_power_limits` | `max_active_power` | `reactive_power_limits` | `max_reactive_power` |
|:------------------------------ |:--------------------- |:------------------ |:----------------------- |:-------------------- |
| [`ThermalStandard`](@ref)      | ✅ `MinMax`            | ❌                  | ✅ `MinMax` (optional)   | ❌                    |
| [`ThermalMultiStart`](@ref)    | ✅ `MinMax`            | ❌                  | ✅ `MinMax` (optional)   | ❌                    |
| [`RenewableDispatch`](@ref)    | ❌                     | ❌ ¹                | ✅ `MinMax` (optional)   | ❌                    |
| [`RenewableNonDispatch`](@ref) | ❌                     | ❌                  | ❌                       | ❌                    |
| [`HydroDispatch`](@ref)        | ✅ `MinMax`            | ❌                  | ✅ `MinMax` (optional)   | ❌                    |
| [`HydroTurbine`](@ref)         | ✅ `MinMax`            | ❌                  | ✅ `MinMax` (optional)   | ❌                    |
| [`HydroPumpTurbine`](@ref)     | ✅ `MinMax`            | ❌                  | ✅ `MinMax` (optional)   | ❌                    |

### Loads

| Type                                | `active_power_limits` | `max_active_power` | `reactive_power_limits` | `max_reactive_power` |
|:----------------------------------- |:--------------------- |:------------------ |:----------------------- |:-------------------- |
| [`PowerLoad`](@ref)                 | ❌                     | ✅ `Float64`        | ❌                       | ✅ `Float64`          |
| [`StandardLoad`](@ref)              | ❌                     | ⊕                  | ❌                       | ⊕                    |
| [`ExponentialLoad`](@ref)           | ❌                     | ✅ `Float64`        | ❌                       | ✅ `Float64`          |
| [`MotorLoad`](@ref)                 | ❌                     | ✅ `Float64`        | ✅ `MinMax` (optional)   | ❌                    |
| [`InterruptiblePowerLoad`](@ref)    | ❌                     | ✅ `Float64`        | ❌                       | ✅ `Float64`          |
| [`InterruptibleStandardLoad`](@ref) | ❌                     | ⊕                  | ❌                       | ⊕                    |
| [`ShiftablePowerLoad`](@ref)        | ✅ `MinMax`            | ✅ `Float64`        | ❌                       | ✅ `Float64`          |

### Storage & Source

| Type                             | `active_power_limits` | `max_active_power` | `reactive_power_limits` | `max_reactive_power` |
|:-------------------------------- |:--------------------- |:------------------ |:----------------------- |:-------------------- |
| [`EnergyReservoirStorage`](@ref) | ❌ ²                   | ❌                  | ✅ `MinMax` (optional)   | ❌                    |
| [`Source`](@ref)                 | ✅ `MinMax`            | ❌                  | ✅ `MinMax` (optional)   | ❌                    |

¹ Uses `rating * power_factor` dynamically; no stored field

² EnergyReservoirStorage uses `input_active_power_limits` and `output_active_power_limits` instead

Here, "`MinMax` (optional)" means `Union{MinMax, Nothing}`, with `nothing` representing "no limits" and being the default.

⊕ = Split across 3 ZIP fields: `*_constant_*`, `*_impedance_*`, `*_current_*`

* * *

## Generator-Specific Fields

| Field              | Thermal* | [`RenewableDispatch`](@ref) | [`RenewableNonDispatch`](@ref) | [`HydroDispatch`](@ref) | [`HydroTurbine`](@ref) | [`HydroPumpTurbine`](@ref) |
|:------------------ |:-------- |:--------------------------- |:------------------------------ |:----------------------- |:---------------------- |:-------------------------- |
| `rating`           | ✅        | ✅                           | ✅                              | ✅                       | ✅                      | ✅                          |
| `prime_mover_type` | ✅        | ✅                           | ✅                              | ✅                       | ✅                      | ✅                          |
| `fuel`             | ✅        | ❌                           | ❌                              | ❌                       | ❌                      | ❌                          |
| `status`           | ✅        | ❌                           | ❌                              | ✅                       | ❌                      | ✅                          |
| `must_run`         | ✅        | ❌                           | ❌                              | ❌                       | ❌                      | ✅                          |
| `ramp_limits`      | ✅        | ❌                           | ❌                              | ✅                       | ✅                      | ✅                          |
| `time_limits`      | ✅        | ❌                           | ❌                              | ✅                       | ✅                      | ✅                          |
| `power_factor`     | ❌        | ✅                           | ✅                              | ❌                       | ❌                      | ❌                          |
| `efficiency`       | ❌        | ❌                           | ❌                              | ❌                       | ✅                      | ✅                          |
| `operation_cost`   | ✅        | ✅                           | ❌                              | ✅                       | ✅                      | ✅                          |

\* Thermal = [`ThermalStandard`](@ref), [`ThermalMultiStart`](@ref)

* * *

## Load-Specific Fields

| Field                   | [`PowerLoad`](@ref) | [`StandardLoad`](@ref) | [`ExponentialLoad`](@ref) | [`MotorLoad`](@ref) | Interruptible* | Shiftable |
|:----------------------- |:------------------- |:---------------------- |:------------------------- |:------------------- |:-------------- |:--------- |
| `active_power`          | ✅                   | ⊕                      | ✅                         | ✅                   | ✅              | ✅         |
| `reactive_power`        | ✅                   | ⊕                      | ✅                         | ✅                   | ✅              | ✅         |
| `conformity`            | ✅                   | ✅                      | ✅                         | ❌                   | ✅              | ❌         |
| `operation_cost`        | ❌                   | ❌                      | ❌                         | ❌                   | ✅              | ✅         |
| `rating`                | ❌                   | ❌                      | ❌                         | ✅                   | ❌              | ❌         |
| `α`, `β` (voltage exp.) | ❌                   | ❌                      | ✅                         | ❌                   | ❌              | ❌         |

\* Interruptible = [`InterruptiblePowerLoad`](@ref), [`InterruptibleStandardLoad`](@ref); Shiftable = [`ShiftablePowerLoad`](@ref)

* * *

## Universal Fields (All StaticInjection)

| Field              | Present in ALL |
|:------------------ |:-------------- |
| `name`             | ✅              |
| `available`        | ✅              |
| `bus`              | ✅              |
| `base_power`       | ✅              |
| `services`         | ✅              |
| `dynamic_injector` | ✅              |
| `ext`              | ✅              |
| `internal`         | ✅              |

* * *

## Operation Cost Types by Device

| Device Category            | Cost Type                                                    |
|:-------------------------- |:------------------------------------------------------------ |
| [`ThermalGen`](@ref)       | [`ThermalGenerationCost`](@ref) or [`MarketBidCost`](@ref)   |
| [`HydroGen`](@ref)         | [`HydroGenerationCost`](@ref) or [`MarketBidCost`](@ref)     |
| [`RenewableGen`](@ref)     | [`RenewableGenerationCost`](@ref) or [`MarketBidCost`](@ref) |
| [`ControllableLoad`](@ref) | [`LoadCost`](@ref) or [`MarketBidCost`](@ref)                |
| [`Storage`](@ref)          | [`StorageCost`](@ref) or [`MarketBidCost`](@ref)             |
| [`Source`](@ref)           | [`ImportExportCost`](@ref)                                   |

* * *
