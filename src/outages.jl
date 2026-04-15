"""
Supertype for outage contingencies representing planned or unplanned equipment outages.

Concrete subtypes include [`GeometricDistributionForcedOutage`](@ref),
[`PlannedOutage`](@ref), and [`FixedForcedOutage`](@ref).
"""
abstract type Outage <: Contingency end

abstract type UnplannedOutage <: Outage end

"""
All PowerSystems [Outage](@ref) types support time series. This can be overridden for custom 
outage types that do not support time series.
"""
supports_time_series(::Outage) = true

"""Get `internal`."""
get_internal(x::Outage) = x.internal

"""
Attribute that contains information regarding forced outages where the transition probabilities
are modeled with geometric distributions. The outage probabilities and recovery probabilities can be modeled as time
series.

# Arguments
- `mean_time_to_recovery::Float64`: Time elapsed to recovery after a failure in Milliseconds.
- `outage_transition_probability::Float64`: Characterizes the probability of failure (1 - p) in the geometric distribution.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct GeometricDistributionForcedOutage <: UnplannedOutage
    mean_time_to_recovery::Float64
    outage_transition_probability::Float64
    internal::InfrastructureSystemsInternal
end

"""
    GeometricDistributionForcedOutage(; mean_time_to_recovery, outage_transition_probability, internal)

Construct a [`GeometricDistributionForcedOutage`](@ref).

# Arguments
- `mean_time_to_recovery::Float64`: (default: `0.0`) Time elapsed to recovery after a failure in Milliseconds.
- `outage_transition_probability::Float64`: (default: `0.0`) Characterizes the probability of failure (1 - p) in the geometric distribution.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function GeometricDistributionForcedOutage(;
    mean_time_to_recovery = 0.0,
    outage_transition_probability = 0.0,
    internal = InfrastructureSystemsInternal(),
)
    return GeometricDistributionForcedOutage(
        mean_time_to_recovery,
        outage_transition_probability,
        internal,
    )
end

"""Get [`GeometricDistributionForcedOutage`](@ref) `time_to_recovery`."""
get_mean_time_to_recovery(value::GeometricDistributionForcedOutage) =
    value.mean_time_to_recovery
"""Get [`GeometricDistributionForcedOutage`](@ref) `outage_transition_probability`."""
get_outage_transition_probability(value::GeometricDistributionForcedOutage) =
    value.outage_transition_probability

"""
Attribute that contains information regarding planned outages.

# Arguments
- `outage_schedule::String`: String name of the time series used for the scheduled outages
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct PlannedOutage <: Outage
    outage_schedule::String
    internal::InfrastructureSystemsInternal
end

"""
    PlannedOutage(; outage_schedule, internal)

Construct a [`PlannedOutage`](@ref).

# Arguments
- `outage_schedule::String`: String name of the time series used for the scheduled outages
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function PlannedOutage(;
    outage_schedule,
    internal = InfrastructureSystemsInternal(),
)
    return PlannedOutage(
        outage_schedule,
        internal,
    )
end

"""Get [`PlannedOutage`](@ref) `outage_schedule`."""
get_outage_schedule(value::PlannedOutage) = value.outage_schedule

"""
Attribute that contains the representation of the status of the component forced outage.
The time series data for fixed outages can be obtained from the simulation of a stochastic process or historical information.

# Arguments
- `outage_status::Float64`: The forced outage status in the model. 1 represents outaged and 0 represents available.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct FixedForcedOutage <: UnplannedOutage
    outage_status::Float64
    internal::InfrastructureSystemsInternal
end

"""
    FixedForcedOutage(; outage_status, internal)

Construct a [`FixedForcedOutage`](@ref).

# Arguments
- `outage_status::Float64`: The forced outage status in the model. 1 represents outaged and 0 represents available.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function FixedForcedOutage(;
    outage_status,
    internal = InfrastructureSystemsInternal(),
)
    return FixedForcedOutage(outage_status, internal)
end

"""Get [`FixedForcedOutage`](@ref) `outage_status`."""
get_outage_status(value::FixedForcedOutage) = value.outage_status
