"""
Supertype for outage contingencies representing planned or unplanned equipment outages.

Concrete subtypes include [`GeometricDistributionForcedOutage`](@ref),
[`PlannedOutage`](@ref), and [`FixedForcedOutage`](@ref).

# Interface for custom subtypes

Subtypes are expected to provide the following fields, or override the matching
accessors via multiple dispatch:

- `monitored_components::Vector{Base.UUID}` — UUIDs of devices whose
  post-contingency state should be modeled. The default
  [`get_monitored_components`](@ref) reads `value.monitored_components`; override
  it if your subtype does not carry the field directly.
- `internal::InfrastructureSystemsInternal` — accessed via `get_internal`.

The default [`supports_time_series`](@ref) returns `true`; override for custom
outage types that do not support time series.
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

# Public API for monitored_components accepts UUIDs or Devices interchangeably.
_as_uuid(uuid::Base.UUID) = uuid
_as_uuid(device::Device) = IS.get_uuid(device)

"""
Get the list of [`Device`](@ref) UUIDs whose post-contingency state should be modeled
when this outage occurs. PowerSystems does not assign meaning to an empty list;
downstream consumers (e.g., PowerSimulations) decide whether empty means "monitor
nothing" or "monitor everything".
"""
get_monitored_components(value::Outage) = value.monitored_components

"""
Replace the monitored-components list for an [`Outage`](@ref) with the contents
of `items`. Accepts any iterable whose elements are `Base.UUID` or
[`Device`](@ref) (e.g., a `Vector`, a generator, or the iterator returned by
[`get_components`](@ref)). Devices are converted to their UUIDs internally.
Pass an empty iterable (or call [`clear_monitored_components!`](@ref)) to
clear the list.
"""
function set_monitored_components!(value::Outage, items)
    empty!(value.monitored_components)
    for x in items
        push!(value.monitored_components, _as_uuid(x))
    end
    return value.monitored_components
end

"""
Empty the monitored-components list of an [`Outage`](@ref). Returns the (now empty)
underlying vector.
"""
function clear_monitored_components!(value::Outage)
    empty!(value.monitored_components)
    return value.monitored_components
end

"""
Append a `Base.UUID` or [`Device`](@ref) to the monitored-components list of
an [`Outage`](@ref). Duplicate UUIDs are ignored.
"""
function add_monitored_component!(value::Outage, x::Union{Base.UUID, Device})
    uuid = _as_uuid(x)
    if !(uuid in value.monitored_components)
        push!(value.monitored_components, uuid)
    end
    return value.monitored_components
end

"""
Append every element of `items` (each a `Base.UUID` or [`Device`](@ref)) to
the monitored-components list of an [`Outage`](@ref). Accepts any iterable, including
the iterator returned by [`get_components`](@ref). Duplicate UUIDs are ignored.
"""
function add_monitored_components!(value::Outage, items)
    for x in items
        add_monitored_component!(value, x)
    end
    return value.monitored_components
end

"""
Remove a `Base.UUID` or [`Device`](@ref) from the monitored-components list
of an [`Outage`](@ref). No-op when the entry is not present.
"""
function remove_monitored_component!(value::Outage, x::Union{Base.UUID, Device})
    uuid = _as_uuid(x)
    idx = findfirst(==(uuid), value.monitored_components)
    isnothing(idx) || deleteat!(value.monitored_components, idx)
    value.monitored_components
    return
end

"""
Remove every element of `items` (each a `Base.UUID` or [`Device`](@ref)) from
the monitored-components list of an [`Outage`](@ref). Accepts any iterable.
"""
function remove_monitored_components!(value::Outage, items)
    for x in items
        remove_monitored_component!(value, x)
    end
    value.monitored_components
    return
end

"""
Attribute that contains information regarding forced outages where the transition probabilities
are modeled with geometric distributions. The outage probabilities and recovery probabilities can be modeled as time
series.

# Arguments
- `mean_time_to_recovery::Float64`: Time elapsed to recovery after a failure in Milliseconds.
- `outage_transition_probability::Float64`: Characterizes the probability of failure (1 - p) in the geometric distribution.
- `monitored_components::Vector{Base.UUID}`: UUIDs of devices whose post-contingency state should be modeled when this outage occurs. Empty by default; semantics of an empty list are decided by the downstream consumer.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct GeometricDistributionForcedOutage <: UnplannedOutage
    mean_time_to_recovery::Float64
    outage_transition_probability::Float64
    monitored_components::Vector{Base.UUID}
    internal::InfrastructureSystemsInternal
end

"""
    GeometricDistributionForcedOutage(; mean_time_to_recovery, outage_transition_probability, monitored_components, internal)

Construct a [`GeometricDistributionForcedOutage`](@ref).

# Arguments
- `mean_time_to_recovery::Float64`: (default: `0.0`) Time elapsed to recovery after a failure in Milliseconds.
- `outage_transition_probability::Float64`: (default: `0.0`) Characterizes the probability of failure (1 - p) in the geometric distribution.
- `monitored_components`: (default: `Base.UUID[]`) Any iterable of `Base.UUID` or [`Device`](@ref). Devices are converted to their UUIDs internally.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function GeometricDistributionForcedOutage(;
    mean_time_to_recovery = 0.0,
    outage_transition_probability = 0.0,
    monitored_components = Base.UUID[],
    internal = InfrastructureSystemsInternal(),
)
    return GeometricDistributionForcedOutage(
        mean_time_to_recovery,
        outage_transition_probability,
        Base.UUID[_as_uuid(x) for x in monitored_components],
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
- `monitored_components::Vector{Base.UUID}`: UUIDs of devices whose post-contingency state should be modeled when this outage occurs. Empty by default; semantics of an empty list are decided by the downstream consumer.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct PlannedOutage <: Outage
    outage_schedule::String
    monitored_components::Vector{Base.UUID}
    internal::InfrastructureSystemsInternal
end

"""
    PlannedOutage(; outage_schedule, monitored_components, internal)

Construct a [`PlannedOutage`](@ref).

# Arguments
- `outage_schedule::String`: String name of the time series used for the scheduled outages
- `monitored_components`: (default: `Base.UUID[]`) Any iterable of `Base.UUID` or [`Device`](@ref). Devices are converted to their UUIDs internally.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function PlannedOutage(;
    outage_schedule,
    monitored_components = Base.UUID[],
    internal = InfrastructureSystemsInternal(),
)
    return PlannedOutage(
        outage_schedule,
        Base.UUID[_as_uuid(x) for x in monitored_components],
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
- `monitored_components::Vector{Base.UUID}`: UUIDs of devices whose post-contingency state should be modeled when this outage occurs. Empty by default; semantics of an empty list are decided by the downstream consumer.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct FixedForcedOutage <: UnplannedOutage
    outage_status::Float64
    monitored_components::Vector{Base.UUID}
    internal::InfrastructureSystemsInternal
end

"""
    FixedForcedOutage(; outage_status, monitored_components, internal)

Construct a [`FixedForcedOutage`](@ref).

# Arguments
- `outage_status::Float64`: The forced outage status in the model. 1 represents outaged and 0 represents available.
- `monitored_components`: (default: `Base.UUID[]`) Any iterable of `Base.UUID` or [`Device`](@ref). Devices are converted to their UUIDs internally.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function FixedForcedOutage(;
    outage_status,
    monitored_components = Base.UUID[],
    internal = InfrastructureSystemsInternal(),
)
    return FixedForcedOutage(
        outage_status,
        Base.UUID[_as_uuid(x) for x in monitored_components],
        internal,
    )
end

"""Get [`FixedForcedOutage`](@ref) `outage_status`."""
get_outage_status(value::FixedForcedOutage) = value.outage_status
