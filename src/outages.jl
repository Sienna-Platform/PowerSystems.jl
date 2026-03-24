abstract type Outage <: Contingency end

abstract type UnplannedOutage <: Outage end

supports_time_series(::Outage) = true

"""Get `internal`."""
get_internal(x::Outage) = x.internal

"""
    struct GeometricDistributionForcedOutage <: UnplannedOutage
        mean_time_to_recovery::Float64
        outage_transition_probability::Float64
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute for unplanned forced outages with transition probabilities modeled
by geometric distributions. Both the outage probability and the recovery probability can
vary over time and be attached as time series data.

# Arguments
- `mean_time_to_recovery::Float64`: Expected time elapsed to recovery after a failure, in
    milliseconds.
- `outage_transition_probability::Float64`: Per-timestep probability of failure;
    parameterizes the geometric distribution as `(1 - p)`.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal
    reference.

# See Also
- [`FixedForcedOutage`](@ref): Unplanned outage type with a fixed (deterministic) outage
    status.
- [`PlannedOutage`](@ref): Scheduled outage type driven by a time series.
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
- `mean_time_to_recovery::Float64`: (default: `0.0`) Expected time elapsed to recovery
    after a failure, in milliseconds.
- `outage_transition_probability::Float64`: (default: `0.0`) Per-timestep probability of
    failure; parameterizes the geometric distribution as `(1 - p)`.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`)
    (**Do not modify.**) PowerSystems.jl internal reference.
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

"""Get [`GeometricDistributionForcedOutage`](@ref) `mean_time_to_recovery`."""
get_mean_time_to_recovery(value::GeometricDistributionForcedOutage) =
    value.mean_time_to_recovery
"""Get [`GeometricDistributionForcedOutage`](@ref) `outage_transition_probability`."""
get_outage_transition_probability(value::GeometricDistributionForcedOutage) =
    value.outage_transition_probability

"""
    struct PlannedOutage <: Outage
        outage_schedule::String
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute for planned (scheduled) outages. The outage schedule is stored as
a time series identified by the `outage_schedule` name string.

# Arguments
- `outage_schedule::String`: Name of the time series containing the outage schedule.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal
    reference.

# See Also
- [`GeometricDistributionForcedOutage`](@ref): Unplanned outage type with geometric
    distribution transition probabilities.
- [`FixedForcedOutage`](@ref): Unplanned outage type with a fixed outage status.
"""
struct PlannedOutage <: Outage
    outage_schedule::String
    internal::InfrastructureSystemsInternal
end

"""
    PlannedOutage(; outage_schedule, internal)

Construct a [`PlannedOutage`](@ref).

# Arguments
- `outage_schedule::String`: Name of the time series containing the outage schedule.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`)
    (**Do not modify.**) PowerSystems.jl internal reference.
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
    struct FixedForcedOutage <: UnplannedOutage
        outage_status::Float64
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute for forced outages with a deterministic (fixed) outage status.
The status value can be derived from stochastic process simulations or historical data,
and may vary over time via attached time series data.

# Arguments
- `outage_status::Float64`: Forced outage status of the component: `1.0` indicates
    outaged (unavailable), `0.0` indicates available.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal
    reference.

# See Also
- [`GeometricDistributionForcedOutage`](@ref): Unplanned outage type with geometric
    distribution transition probabilities.
- [`PlannedOutage`](@ref): Scheduled outage type driven by a time series.
"""
struct FixedForcedOutage <: UnplannedOutage
    outage_status::Float64
    internal::InfrastructureSystemsInternal
end

"""
    FixedForcedOutage(; outage_status, internal)

Construct a [`FixedForcedOutage`](@ref).

# Arguments
- `outage_status::Float64`: Forced outage status of the component: `1.0` indicates
    outaged (unavailable), `0.0` indicates available.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`)
    (**Do not modify.**) PowerSystems.jl internal reference.
"""
function FixedForcedOutage(;
    outage_status,
    internal = InfrastructureSystemsInternal(),
)
    return FixedForcedOutage(outage_status, internal)
end

"""Get [`FixedForcedOutage`](@ref) `outage_status`."""
get_outage_status(value::FixedForcedOutage) = value.outage_status
