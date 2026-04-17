""" Supertype for all generation technologies"""
abstract type Generator <: StaticInjection end
const Generators = Array{<:Generator, 1}

""" Supertype for all Hydropower generation technologies"""
abstract type HydroGen <: Generator end

""" Supertype for all Hydropower generation technologies that are represented as units (i.e. HydroTurbine and HydroPumpTurbine)"""
abstract type HydroUnit <: HydroGen end

"""
Supertype for all renewable generation technologies

Requires the implementation of `get_rating`and `get_power_factor` methods
"""
abstract type RenewableGen <: Generator end

""" Supertype for all Thermal generation technologies"""
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
Return the max active power for the Renewable Generation calculated as the `rating` * `power_factor`
"""
function get_max_active_power(d::T, units) where {T <: RenewableGen}
    return get_rating(d, units) * get_power_factor(d)
end

"""
Return the max reactive power for the Renewable Generation calculated as the `rating` * sin(acos(`power_factor`))
"""
function get_max_reactive_power(d::T, units) where {T <: RenewableGen}
    return get_rating(d, units) * sin(acos(get_power_factor(d)))
end
