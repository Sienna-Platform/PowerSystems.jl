"""
    DynamicBranch

Extends an [`ACTransmission`](@ref) branch with the information required for dynamic modeling.

# Arguments
$(TYPEDFIELDS)
"""
mutable struct DynamicBranch <: ACTransmission
    "The static AC transmission branch that this struct extends with dynamic modeling data"
    branch::ACTransmission
    "Number of dynamic states"
    n_states::Int
    "Names of the dynamic states"
    states::Vector{Symbol}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::IS.InfrastructureSystemsInternal

    function DynamicBranch(branch, n_states, states, internal)
        @assert length(states) == n_states
        new(branch, n_states, states, internal)
    end
end

const DEFAULT_DYNAMIC_BRANCH_STATES = [:Il_R, :Il_I]

function DynamicBranch(
    branch::T;
    internal = IS.InfrastructureSystemsInternal(),
) where {T <: ACTransmission}
    states = DEFAULT_DYNAMIC_BRANCH_STATES
    n_states = length(states)
    return DynamicBranch(branch, n_states, states, internal)
end

function DynamicBranch(;
    branch,
    n_states = length(DEFAULT_DYNAMIC_BRANCH_STATES),
    states = DEFAULT_DYNAMIC_BRANCH_STATES,
    internal = IS.InfrastructureSystemsInternal(),
)
    return DynamicBranch(branch, n_states, states, internal)
end

function DynamicBranch(::Nothing)
    return DynamicBranch(Line(nothing))
end

"""Return the underlying [`ACTransmission`](@ref) branch of a [`DynamicBranch`](@ref)."""
get_branch(value::DynamicBranch) = value.branch
"""Return the number of dynamic states of a [`DynamicBranch`](@ref)."""
get_n_states(value::DynamicBranch) = value.n_states
"""Return the vector of dynamic state symbols of a [`DynamicBranch`](@ref)."""
get_states(value::DynamicBranch) = value.states
"""Return the [`InfrastructureSystemsInternal`](@ref) of a [`DynamicBranch`](@ref)."""
get_internal(value::DynamicBranch) = value.internal

get_name(value::DynamicBranch) = IS.get_name(value.branch)
"""Return `available` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_available(value::DynamicBranch) = get_available(value.branch)
"""Return `active_power_flow` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_active_power_flow(value::DynamicBranch) = get_active_power(value.branch)
"""Return `reactive_power_flow` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_reactive_power_flow(value::DynamicBranch) = get_reactive_power(value.branch)
"""Return the [`Arc`](@ref) from the underlying branch of a [`DynamicBranch`](@ref)."""
get_arc(value::DynamicBranch) = get_arc(value.branch)
"""Return resistance `r` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_r(value::DynamicBranch) = get_r(value.branch)
"""Return reactance `x` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_x(value::DynamicBranch) = get_x(value.branch)
"""Return susceptance `b` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_b(value::DynamicBranch) = get_b(value.branch)
"""Return the A-side `rating` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_rating(value::DynamicBranch) = get_rating(value.branch)
"""Return `angle_limits` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_angle_limits(value::DynamicBranch) = get_angle_limits(value.branch)
"""Return the B-side `rating` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_rating_b(value::DynamicBranch) = get_rating_b(value.branch)
"""Return the C-side `rating` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_rating_c(value::DynamicBranch) = get_rating_c(value.branch)
"""Return `services` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_services(value::DynamicBranch) = get_services(value.branch)
"""Return `ext` from the underlying branch of a [`DynamicBranch`](@ref)."""
get_ext(value::DynamicBranch) = get_ext(value.branch)

"""Set `available` on the underlying branch of a [`DynamicBranch`](@ref)."""
set_available!(value::DynamicBranch, val::Bool) = set_available!(value.branch, val)
"""Set `active_power_flow` on the underlying branch of a [`DynamicBranch`](@ref)."""
set_active_power_flow!(value::DynamicBranch, val::Float64) =
    set_active_power_flow!(value.branch, val)
"""Set `reactive_power_flow` on the underlying branch of a [`DynamicBranch`](@ref)."""
set_reactive_power_flow!(value::DynamicBranch, val::Float64) =
    set_reactive_power_flow!(value.branch, val)
"""Set the [`Arc`](@ref) on the underlying branch of a [`DynamicBranch`](@ref)."""
set_arc!(value::DynamicBranch, val::Arc) = set_arc!(value.branch, val)
"""Set resistance `r` on the underlying branch of a [`DynamicBranch`](@ref)."""
set_r!(value::DynamicBranch, val::Float64) = set_r!(value.branch, val)
"""Set reactance `x` on the underlying branch of a [`DynamicBranch`](@ref)."""
set_x!(value::DynamicBranch, val::Float64) = set_x!(value.branch, val)
"""Set susceptance `b` on the underlying branch of a [`DynamicBranch`](@ref)."""
set_b!(value::DynamicBranch, val) = set_b!(value.branch, val)
"""Set the `rating` on the underlying branch of a [`DynamicBranch`](@ref)."""
set_rating!(value::DynamicBranch, val::Float64) = set_rating!(value.branch, val)
"""Set `angle_limits` on the underlying branch of a [`DynamicBranch`](@ref)."""
set_angle_limits!(
    value::DynamicBranch,
    val::NamedTuple{(:min, :max), Tuple{Float64, Float64}},
) = set_angle_limits!(value.branch, val)
"""Set `services` on the underlying branch of a [`DynamicBranch`](@ref)."""
set_services!(value::DynamicBranch, val::Vector{Service}) = set_services!(value.branch, val)
"""Set `ext` on the underlying branch of a [`DynamicBranch`](@ref)."""
set_ext!(value::DynamicBranch, val::Dict{String, Any}) = set_ext!(value.branch, val)

"""Set the underlying [`ACTransmission`](@ref) branch of a [`DynamicBranch`](@ref)."""
set_branch!(value::DynamicBranch, val::ACTransmission) = value.branch = val
"""Set the number of dynamic states on a [`DynamicBranch`](@ref)."""
set_n_states!(value::DynamicBranch, val::Int) = value.n_states = val
"""Set the vector of dynamic state symbols on a [`DynamicBranch`](@ref)."""
set_states!(value::DynamicBranch, val::Vector{Symbol}) = value.states = val
