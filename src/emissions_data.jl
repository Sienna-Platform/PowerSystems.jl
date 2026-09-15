"""
    EmissionsData(; name, pollutant, emission_rate, basis, energy_unit, ...)

A [supplemental attribute](@ref supplemental_attributes) describing the emission of a single pollutant from a
host component. Combines pollutant identity (CO2, NOx, etc.) with an emission rate
expressed as a [`ValueCurve`](@ref) (supporting constant, linear, or piecewise
relationships between fuel consumption / power output and emissions). One `EmissionsData`
instance can be attached to one or many components via [`add_supplemental_attribute!`](@ref).

# Arguments
- `name::String`: Identifier for this emissions attribute.
- `pollutant::PollutantType.T`: Scoped enum (CO2, CO2E, CH4, N2O, NOX, SO2, PM25, PM10, HG, HAP, CUSTOM).
- `emission_rate::ValueCurve`: Emission rate as a [`ValueCurve`](@ref), typically an
    [`IncrementalCurve`](@ref). A convenience constructor accepts a `Real` scalar, which
    is wrapped in an `IncrementalCurve` with constant rate.
- `basis::EmissionBasis.T`: FUEL_INPUT (mass per unit of heat input) or POWER_OUTPUT (mass per unit of electrical output).
- `energy_unit::EnergyUnit.T`: Energy unit for the rate denominator (MMBTU, GJ, or MWH). Must be consistent with `basis`.
- `start_up_adder::Float64`: (default: `0.0`) Per-start emission pulse, in `mass_unit`.
- `mass_unit::MassUnit.T`: (default: `MassUnit.KG`) KG, LB, SHORT_TON, METRIC_TON.
- `gwp::Float64`: (default: `1.0`) GWP100 multiplier for CO2-equivalent reporting.
- `available::Bool`: (default: `true`) Whether this attribute is active.
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) Extra metadata dictionary.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference.
"""
mutable struct EmissionsData <: SupplementalAttribute
    name::String
    pollutant::PollutantType.T
    emission_rate::IS.ValueCurve
    basis::EmissionBasis.T
    start_up_adder::Float64
    mass_unit::MassUnit.T
    energy_unit::EnergyUnit.T
    gwp::Float64
    available::Bool
    ext::Dict{String, Any}
    internal::InfrastructureSystemsInternal
end

# Validation helpers (shared between constructor and setters)
function _validate_nonneg_finite(val::Real, field::String)
    if !isfinite(val) || val < 0.0
        throw(ArgumentError("$field must be finite and >= 0.0, got $val"))
    end
end

function _validate_basis_energy_unit(basis::EmissionBasis.T, energy_unit::EnergyUnit.T)
    if basis == EmissionBasis.FUEL_INPUT
        if energy_unit != EnergyUnit.MMBTU && energy_unit != EnergyUnit.GJ
            throw(
                ArgumentError(
                    "energy_unit must be MMBTU or GJ when basis is FUEL_INPUT, got $energy_unit",
                ),
            )
        end
    elseif basis == EmissionBasis.POWER_OUTPUT
        if energy_unit != EnergyUnit.MWH
            throw(
                ArgumentError(
                    "energy_unit must be MWH when basis is POWER_OUTPUT, got $energy_unit",
                ),
            )
        end
    else
        throw(
            ArgumentError(
                "unhandled EmissionBasis $basis; update _validate_basis_energy_unit",
            ),
        )
    end
end

# Emission-rate helpers (shared between constructor and setters)

"""Wrap a scalar emission rate in a constant-rate `IncrementalCurve` after validation."""
function _emission_rate_curve(val::Real)
    _validate_nonneg_finite(val, "emission_rate")
    return IS.IncrementalCurve(LinearFunctionData(0.0, Float64(val)), nothing, nothing)
end

"""
Validate that an `emission_rate` [`ValueCurve`](@ref) holds only finite coefficients and
non-negative rate values (the rate at zero input and every tabulated rate must be `>= 0`).
"""
function _validate_emission_rate_curve(curve::IS.ValueCurve)
    _validate_emission_rate_function_data(get_function_data(curve))
    return
end

function _validate_emission_rate_function_data(fd::LinearFunctionData)
    _validate_nonneg_finite(get_constant_term(fd), "emission_rate (rate at zero input)")
    isfinite(get_proportional_term(fd)) || throw(
        ArgumentError(
            "emission_rate slope must be finite, got $(get_proportional_term(fd))",
        ),
    )
    return
end

function _validate_emission_rate_function_data(fd::QuadraticFunctionData)
    _validate_nonneg_finite(get_constant_term(fd), "emission_rate (rate at zero input)")
    for term in (get_proportional_term(fd), get_quadratic_term(fd))
        isfinite(term) ||
            throw(ArgumentError("emission_rate coefficients must be finite, got $term"))
    end
    return
end

function _validate_emission_rate_function_data(
    fd::Union{PiecewiseLinearData, PiecewiseStepData},
)
    for r in get_y_coords(fd)
        _validate_nonneg_finite(r, "emission_rate")
    end
    return
end

# Safe fallback for any future FunctionData subtype not enumerated above.
_validate_emission_rate_function_data(::IS.FunctionData) = nothing

"""
    EmissionsData(; name, pollutant, emission_rate, basis, energy_unit, ...)

Construct an [`EmissionsData`](@ref) with validation.

`emission_rate` can be any [`ValueCurve`](@ref) (e.g., `IncrementalCurve`,
`InputOutputCurve`) or a scalar `Real` value (which is automatically wrapped in an
`IncrementalCurve` with constant rate).
"""
function EmissionsData(;
    name::AbstractString,
    pollutant::PollutantType.T,
    emission_rate::Union{Real, IS.ValueCurve},
    basis::EmissionBasis.T,
    energy_unit::EnergyUnit.T,
    start_up_adder::Real = 0.0,
    mass_unit::MassUnit.T = MassUnit.KG,
    gwp::Real = 1.0,
    available::Bool = true,
    ext::Dict{String, Any} = Dict{String, Any}(),
    internal::InfrastructureSystemsInternal = InfrastructureSystemsInternal(),
)
    _validate_nonneg_finite(start_up_adder, "start_up_adder")
    _validate_nonneg_finite(gwp, "gwp")

    # Validate basis/energy_unit combination
    _validate_basis_energy_unit(basis, energy_unit)

    # Normalize emission_rate to a validated ValueCurve
    if emission_rate isa Real
        rate = _emission_rate_curve(emission_rate)
    else
        _validate_emission_rate_curve(emission_rate)
        rate = emission_rate
    end

    return EmissionsData(
        String(name),
        pollutant,
        rate,
        basis,
        Float64(start_up_adder),
        mass_unit,
        energy_unit,
        Float64(gwp),
        available,
        ext,
        internal,
    )
end

# IS integration
supports_time_series(::EmissionsData) = false

"""Get [`EmissionsData`](@ref) `name`."""
get_name(value::EmissionsData) = value.name
"""Get [`EmissionsData`](@ref) `pollutant`."""
get_pollutant(value::EmissionsData) = value.pollutant
"""Get [`EmissionsData`](@ref) `emission_rate`."""
get_emission_rate(value::EmissionsData) = value.emission_rate
"""Get [`EmissionsData`](@ref) `basis`."""
get_basis(value::EmissionsData) = value.basis
"""Get [`EmissionsData`](@ref) `start_up_adder`."""
get_start_up_adder(value::EmissionsData) = value.start_up_adder
"""Get [`EmissionsData`](@ref) `mass_unit`."""
get_mass_unit(value::EmissionsData) = value.mass_unit
"""Get [`EmissionsData`](@ref) `energy_unit`."""
get_energy_unit(value::EmissionsData) = value.energy_unit
"""Get [`EmissionsData`](@ref) `gwp`."""
get_gwp(value::EmissionsData) = value.gwp
"""Get [`EmissionsData`](@ref) `available`."""
get_available(value::EmissionsData) = value.available
"""Get [`EmissionsData`](@ref) `ext`."""
get_ext(value::EmissionsData) = value.ext
"""Get [`EmissionsData`](@ref) `internal`."""
get_internal(value::EmissionsData) = value.internal

"""Set [`EmissionsData`](@ref) `emission_rate` with a [`ValueCurve`](@ref)."""
function set_emission_rate!(value::EmissionsData, val::IS.ValueCurve)
    _validate_emission_rate_curve(val)
    value.emission_rate = val
    return
end

"""Set [`EmissionsData`](@ref) `emission_rate` with a scalar (wraps in `IncrementalCurve` with constant rate)."""
function set_emission_rate!(value::EmissionsData, val::Real)
    value.emission_rate = _emission_rate_curve(val)
    return
end

"""Set [`EmissionsData`](@ref) `start_up_adder`."""
function set_start_up_adder!(value::EmissionsData, val::Real)
    _validate_nonneg_finite(val, "start_up_adder")
    value.start_up_adder = Float64(val)
    return
end

"""Set [`EmissionsData`](@ref) `available`."""
function set_available!(value::EmissionsData, val::Bool)
    value.available = val
    return
end

"""Set [`EmissionsData`](@ref) `gwp`."""
function set_gwp!(value::EmissionsData, val::Real)
    _validate_nonneg_finite(val, "gwp")
    value.gwp = Float64(val)
    return
end

"""Set [`EmissionsData`](@ref) `pollutant`."""
function set_pollutant!(value::EmissionsData, val::PollutantType.T)
    value.pollutant = val
    return
end

"""Set [`EmissionsData`](@ref) `mass_unit`."""
function set_mass_unit!(value::EmissionsData, val::MassUnit.T)
    value.mass_unit = val
    return
end

"""
Set [`EmissionsData`](@ref) `basis`, validating it against the current `energy_unit`. To
switch between FUEL_INPUT and POWER_OUTPUT (which also requires changing `energy_unit`),
use [`set_basis_and_energy_unit!`](@ref) instead.
"""
function set_basis!(value::EmissionsData, val::EmissionBasis.T)
    _validate_basis_energy_unit(val, value.energy_unit)
    value.basis = val
    return
end

"""Set [`EmissionsData`](@ref) `energy_unit`, validating it against the current `basis`."""
function set_energy_unit!(value::EmissionsData, val::EnergyUnit.T)
    _validate_basis_energy_unit(value.basis, val)
    value.energy_unit = val
    return
end

"""
Set [`EmissionsData`](@ref) `basis` and `energy_unit` together, validating the combination.
This is the supported way to retarget an attribute between FUEL_INPUT and POWER_OUTPUT,
since neither field can be changed individually without transiently violating the
basis/energy_unit invariant.
"""
function set_basis_and_energy_unit!(
    value::EmissionsData,
    basis::EmissionBasis.T,
    energy_unit::EnergyUnit.T,
)
    _validate_basis_energy_unit(basis, energy_unit)
    value.basis = basis
    value.energy_unit = energy_unit
    return
end
