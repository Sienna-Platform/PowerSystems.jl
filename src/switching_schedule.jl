"""
Attribute that schedules the open or closed state of the switches it is attached to.

Switches that share a schedule follow one trajectory; a plan that moves switches in opposite
directions uses several attributes. A switch carrying a schedule is part of a model's base
network as closed, and is open at a time step when any of its schedules says so.

# Arguments
- `status_schedule::String`: Name of the time series, stored on this attribute, that carries
  the schedule. Values follow [`DiscreteControlledBranchStatus`](@ref): 1 = closed, 0 = open.
- `identifier::Union{Nothing, String}`: Optional user-supplied identifier, such as a switching plan id. `nothing` when not set.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct SwitchingSchedule <: SupplementalAttribute
    status_schedule::String
    identifier::Union{Nothing, String}
    internal::InfrastructureSystemsInternal
end

"""
    SwitchingSchedule(; status_schedule, identifier, internal)

Construct a [`SwitchingSchedule`](@ref).

# Arguments
- `status_schedule::String`: Name of the time series, stored on this attribute, that carries
  the schedule. Values: 1 = closed, 0 = open.
- `identifier::Union{Nothing, String}`: (default: `nothing`) Optional user-supplied identifier, such as a switching plan id.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function SwitchingSchedule(;
    status_schedule,
    identifier = nothing,
    internal = InfrastructureSystemsInternal(),
)
    return SwitchingSchedule(status_schedule, identifier, internal)
end

supports_time_series(::SwitchingSchedule) = true

"""Get `internal`."""
get_internal(x::SwitchingSchedule) = x.internal

"""Get [`SwitchingSchedule`](@ref) `status_schedule`."""
get_status_schedule(value::SwitchingSchedule) = value.status_schedule

"""
Get the optional user-supplied identifier of a [`SwitchingSchedule`](@ref). Returns
`nothing` when none was set.
"""
get_identifier(value::SwitchingSchedule) = value.identifier

function add_supplemental_attribute!(
    sys::System,
    component::DiscreteControlledACBranch,
    schedule::SwitchingSchedule,
)
    return IS.add_supplemental_attribute!(sys.data, component, schedule)
end

function add_supplemental_attribute!(
    ::System,
    component::Component,
    ::SwitchingSchedule,
)
    throw(
        ArgumentError(
            "A SwitchingSchedule can only be attached to a DiscreteControlledACBranch; " *
            "got $(typeof(component)) $(get_name(component)).",
        ),
    )
end
