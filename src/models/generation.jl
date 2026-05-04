"""
    Generator

Supertype for all generation technologies.

Abstract subtypes include [`HydroGen`](@ref), [`RenewableGen`](@ref), and
[`ThermalGen`](@ref).

See also: [`StaticInjection`](@ref), [`HydroGen`](@ref), [`RenewableGen`](@ref), [`ThermalGen`](@ref)
"""
abstract type Generator <: StaticInjection end
const Generators = Array{<:Generator, 1}

"""
    HydroGen

Supertype for all hydropower generation technologies.

The abstract subtype [`HydroUnit`](@ref) covers turbine-based units
([`HydroTurbine`](@ref), [`HydroPumpTurbine`](@ref)). The concrete subtype
[`HydroDispatch`](@ref) also inherits directly from `HydroGen`.

See also: [`Generator`](@ref), [`HydroUnit`](@ref), [`HydroReservoir`](@ref)
"""
abstract type HydroGen <: Generator end

"""
    HydroUnit

Supertype for all hydropower generation technologies represented as turbine-based units.

Concrete subtypes include [`HydroTurbine`](@ref) and [`HydroPumpTurbine`](@ref).

See also: [`HydroGen`](@ref), [`HydroReservoir`](@ref)
"""
abstract type HydroUnit <: HydroGen end

"""
    RenewableGen

Supertype for all renewable generation technologies.

Concrete subtypes include [`RenewableDispatch`](@ref) and [`RenewableNonDispatch`](@ref).
All subtypes must implement `get_rating` and `get_power_factor` methods.

See also: [`Generator`](@ref), [`ThermalGen`](@ref)
"""
abstract type RenewableGen <: Generator end

"""
    ThermalGen

Supertype for all thermal generation technologies.

Concrete subtypes include [`ThermalStandard`](@ref) and [`ThermalMultiStart`](@ref).

See also: [`Generator`](@ref), [`HydroGen`](@ref), [`RenewableGen`](@ref)
"""
abstract type ThermalGen <: Generator end

function IS.get_limits(
    valid_range::Union{NamedTuple{(:min, :max)}, NamedTuple{(:max, :min)}},
    unused::T,
) where {T <: Generator}
    # Gets min and max value defined for a field,
    # e.g. "valid_range": {"min":-1.571, "max":1.571}.
    return (min = valid_range.min, max = valid_range.max, zero = 0.0)
end

"""
Return the maximum active power for a [`RenewableGen`](@ref) in per unit on the device base,
calculated as [`get_rating`](@ref) × [`get_power_factor`](@ref).

# Arguments
- `d::RenewableGen`: The renewable generation device.

See also: [`get_max_reactive_power`](@ref get_max_reactive_power(d::RenewableGen))
"""
function get_max_active_power(d::RenewableGen)
    return get_rating(d) * get_power_factor(d)
end

"""
Return the maximum reactive power for a [`RenewableGen`](@ref) in per unit on the device base,
calculated as [`get_rating`](@ref) × sin(acos([`get_power_factor`](@ref))).

# Arguments
- `d::RenewableGen`: The renewable generation device.

See also: [`get_max_active_power`](@ref get_max_active_power(d::RenewableGen))
"""
function get_max_reactive_power(d::RenewableGen)
    return get_rating(d) * sin(acos(get_power_factor(d)))
end
