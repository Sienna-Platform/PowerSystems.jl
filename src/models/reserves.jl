"""
Used to specify if a [`Reserve`](@ref) is upwards, downwards, or symmetric
"""
abstract type ReserveDirection end

"""
An upwards reserve to increase generation or reduce load

Upwards reserves are used when total load exceeds its expected level,
typically due to forecast errors or contingencies.

A [`Reserve`](@ref) can be specified as a `ReserveUp` when it is defined.
"""
abstract type ReserveUp <: ReserveDirection end

"""
A downwards reserve to decrease generation or increase load

Downwards reserves are used when total load falls below its expected level,
typically due to forecast errors or contingencies. Not work

A [`Reserve`](@ref) can be specified as a `ReserveDown` when it is defined.
"""
abstract type ReserveDown <: ReserveDirection end

"""
A symmetric reserve, procuring the same quantity (MW) of both upwards and downwards
reserves

A symmetric reserve is a special case. [`ReserveUp`](@ref) and [`ReserveDown`](@ref)
can be used individually to specify different quantities of upwards and downwards
reserves, respectively.

A [`Reserve`](@ref) can be specified as a `ReserveSymmetric` when it is defined.
"""
abstract type ReserveSymmetric <: ReserveDirection end

"""
Supertype for all reserve products: spinning, non-spinning, and service-aggregating groups.

Subtypes are [`Reserve`](@ref) (parameterized by [`ReserveDirection`](@ref), for spinning
products), [`OfflineReserve`](@ref) (non-spinning, upward only), and [`GroupReserve`](@ref)
(a demand over the awards of other reserves; it carries no device-side fields and no
contributing devices of its own).
"""
abstract type AbstractReserve <: Service end

"""
A reserve product to be able to respond to unexpected disturbances,
such as the sudden loss of a transmission line or generator.
"""
abstract type Reserve{T <: ReserveDirection} <: AbstractReserve end

"""
$(TYPEDEF)
$(TYPEDFIELDS)

A reserve product provided by devices already synchronized with the system.

The procurement requirement is static unless a `"requirement"` time series is attached, in which
case `requirement` acts as the scaling factor. Attach an Operating Reserve Demand Curve through
`variable` to price the requirement rather than enforce it; [`has_demand_curve`](@ref) reports
whether one is present.

The `ReserveDirection` must be specified as [`ReserveUp`](@ref), [`ReserveDown`](@ref), or
[`ReserveSymmetric`](@ref).
"""
mutable struct OnlineReserve{T <: ReserveDirection, U <: IS.AbstractUnitSystem} <:
               Reserve{T}
    "Name of the component"
    name::String
    "Indicator of whether the component is connected and online"
    available::Bool
    "The saturation time frame in minutes to provide reserve contribution"
    time_frame::Float64
    "The required quantity of the product in p.u. ([`SYSTEM_BASE`](@ref per_unit)), scaled by a `\"requirement\"` time series when one is attached"
    requirement::Float64
    # TODO DISCUSS: the ORDC `variable` is a Union of a static and a time-series-backed CostCurve
    # (absorbing the retired ReserveDemandCurve / ReserveDemandTimeSeriesCurve). Revisit later.
    "Operating reserve demand curve (static or time-series-backed). `ZERO_OFFER_CURVE` means no curve is defined"
    variable::Union{
        CostCurve{PiecewiseIncrementalCurve, U},
        CostCurve{<:TimeSeriesPiecewiseIncrementalCurve, U},
    }
    "The time in minutes reserve contribution must be sustained at a specified level"
    sustained_time::Float64
    "The maximum fraction of each device's output that can be assigned to the service"
    max_output_fraction::Float64
    "The maximum portion [0, 1.0] of the reserve that can be contributed per device"
    max_participation_factor::Float64
    "Fraction of service procurement that is assumed to be actually deployed"
    deployed_fraction::Float64
    "An extra dictionary for users to add metadata that are not used in simulation"
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function OnlineReserve{T}(
    name,
    available,
    time_frame,
    requirement = 0.0,
    variable = ZERO_OFFER_CURVE,
    sustained_time = 60.0,
    max_output_fraction = 1.0,
    max_participation_factor = 1.0,
    deployed_fraction = 0.0,
    ext = Dict{String, Any}(),
) where {T <: ReserveDirection}
    U = typeof(get_power_units(variable))
    return OnlineReserve{T, U}(
        name, available, time_frame, requirement, variable, sustained_time,
        max_output_fraction, max_participation_factor, deployed_fraction, ext,
        InfrastructureSystemsInternal(),
    )
end

function OnlineReserve{T}(;
    name,
    available,
    time_frame,
    requirement = 0.0,
    variable = ZERO_OFFER_CURVE,
    sustained_time = 60.0,
    max_output_fraction = 1.0,
    max_participation_factor = 1.0,
    deployed_fraction = 0.0,
    ext = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
) where {T <: ReserveDirection}
    U = typeof(get_power_units(variable))
    return OnlineReserve{T, U}(
        name, available, time_frame, requirement, variable, sustained_time,
        max_output_fraction, max_participation_factor, deployed_fraction, ext, internal,
    )
end

# Deserialization resolves `OnlineReserve{T, U}` from metadata and calls it with kwargs.
function OnlineReserve{T, U}(;
    name,
    available,
    time_frame,
    requirement = 0.0,
    variable = ZERO_OFFER_CURVE,
    sustained_time = 60.0,
    max_output_fraction = 1.0,
    max_participation_factor = 1.0,
    deployed_fraction = 0.0,
    ext = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
) where {T <: ReserveDirection, U <: IS.AbstractUnitSystem}
    return OnlineReserve{T, U}(
        name, available, time_frame, requirement, variable, sustained_time,
        max_output_fraction, max_participation_factor, deployed_fraction, ext, internal,
    )
end

# Constructor for demo purposes; non-functional.
function OnlineReserve{T}(::Nothing) where {T <: ReserveDirection}
    return OnlineReserve{T}(;
        name = "init",
        available = false,
        time_frame = 0.0,
        requirement = 0.0,
        variable = ZERO_OFFER_CURVE,
        sustained_time = 0.0,
        max_output_fraction = 1.0,
        max_participation_factor = 1.0,
        deployed_fraction = 0.0,
    )
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)

A non-spinning reserve product from devices not currently synchronized with the system but able to
come online quickly.

Upward only, so unlike [`OnlineReserve`](@ref) there is no `ReserveDirection` parameter.
"""
mutable struct OfflineReserve{U <: IS.AbstractUnitSystem} <: AbstractReserve
    "Name of the component"
    name::String
    "Indicator of whether the component is connected and online"
    available::Bool
    "The saturation time frame in minutes to provide reserve contribution"
    time_frame::Float64
    "The required quantity of the product in p.u. ([`SYSTEM_BASE`](@ref per_unit)), scaled by a `\"requirement\"` time series when one is attached"
    requirement::Float64
    # TODO DISCUSS: see OnlineReserve.variable - the ORDC is a Union of a static and a
    # time-series-backed CostCurve. Revisit later.
    "Operating reserve demand curve (static or time-series-backed). `ZERO_OFFER_CURVE` means no curve is defined"
    variable::Union{
        CostCurve{PiecewiseIncrementalCurve, U},
        CostCurve{<:TimeSeriesPiecewiseIncrementalCurve, U},
    }
    "The time in minutes reserve contribution must be sustained at a specified level"
    sustained_time::Float64
    "The maximum fraction of each device's output that can be assigned to the service"
    max_output_fraction::Float64
    "The maximum portion [0, 1.0] of the reserve that can be contributed per device"
    max_participation_factor::Float64
    "Fraction of service procurement that is assumed to be actually deployed"
    deployed_fraction::Float64
    "An extra dictionary for users to add metadata that are not used in simulation"
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function OfflineReserve(
    name,
    available,
    time_frame,
    requirement = 0.0,
    variable = ZERO_OFFER_CURVE,
    sustained_time = 60.0,
    max_output_fraction = 1.0,
    max_participation_factor = 1.0,
    deployed_fraction = 0.0,
    ext = Dict{String, Any}(),
)
    U = typeof(get_power_units(variable))
    return OfflineReserve{U}(
        name, available, time_frame, requirement, variable, sustained_time,
        max_output_fraction, max_participation_factor, deployed_fraction, ext,
        InfrastructureSystemsInternal(),
    )
end

function OfflineReserve(;
    name,
    available,
    time_frame,
    requirement = 0.0,
    variable = ZERO_OFFER_CURVE,
    sustained_time = 60.0,
    max_output_fraction = 1.0,
    max_participation_factor = 1.0,
    deployed_fraction = 0.0,
    ext = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
)
    U = typeof(get_power_units(variable))
    return OfflineReserve{U}(
        name, available, time_frame, requirement, variable, sustained_time,
        max_output_fraction, max_participation_factor, deployed_fraction, ext, internal,
    )
end

# Deserialization resolves `OfflineReserve{U}` from metadata and calls it with kwargs.
function OfflineReserve{U}(;
    name,
    available,
    time_frame,
    requirement = 0.0,
    variable = ZERO_OFFER_CURVE,
    sustained_time = 60.0,
    max_output_fraction = 1.0,
    max_participation_factor = 1.0,
    deployed_fraction = 0.0,
    ext = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
) where {U <: IS.AbstractUnitSystem}
    return OfflineReserve{U}(
        name, available, time_frame, requirement, variable, sustained_time,
        max_output_fraction, max_participation_factor, deployed_fraction, ext, internal,
    )
end

# Constructor for demo purposes; non-functional.
function OfflineReserve(::Nothing)
    return OfflineReserve(;
        name = "init",
        available = false,
        time_frame = 0.0,
        requirement = 0.0,
        variable = ZERO_OFFER_CURVE,
        sustained_time = 0.0,
        max_output_fraction = 1.0,
        max_participation_factor = 1.0,
        deployed_fraction = 0.0,
    )
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)

A reserve product met by a group of individual reserves.

The group requirement is additional to each member's own requirement, and a device contributing to
a member reserve also counts toward the group. Attach an Operating Reserve Demand Curve through
`variable` to price the group requirement rather than enforce it, exactly as for
[`OnlineReserve`](@ref); [`has_demand_curve`](@ref) reports whether one is present. This is what
makes an ELASTIC group (one demand curve met by the awards of several sub-products) representable.

The `ReserveDirection` must be specified as [`ReserveUp`](@ref), [`ReserveDown`](@ref), or
[`ReserveSymmetric`](@ref).
"""
mutable struct GroupReserve{T <: ReserveDirection, U <: IS.AbstractUnitSystem} <:
               AbstractReserve
    "Name of the component"
    name::String
    "Indicator of whether the component is connected and online"
    available::Bool
    "The value of required reserves in p.u. ([`SYSTEM_BASE`](@ref per_unit))"
    requirement::Float64
    # TODO DISCUSS: see OnlineReserve.variable - the ORDC is a Union of a static and a
    # time-series-backed CostCurve. Revisit later.
    "Operating reserve demand curve for the group (static or time-series-backed). `ZERO_OFFER_CURVE` means no curve is defined"
    variable::Union{
        CostCurve{PiecewiseIncrementalCurve, U},
        CostCurve{<:TimeSeriesPiecewiseIncrementalCurve, U},
    }
    "An extra dictionary for users to add metadata that are not used in simulation"
    ext::Dict{String, Any}
    "Services that contribute to this group requirement"
    contributing_services::Vector{Service}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function GroupReserve{T}(
    name,
    available,
    requirement,
    variable = ZERO_OFFER_CURVE,
    ext = Dict{String, Any}(),
    contributing_services = Vector{Service}(),
) where {T <: ReserveDirection}
    U = typeof(get_power_units(variable))
    return GroupReserve{T, U}(
        name, available, requirement, variable, ext, contributing_services,
        InfrastructureSystemsInternal(),
    )
end

function GroupReserve{T}(;
    name,
    available,
    requirement,
    variable = ZERO_OFFER_CURVE,
    ext = Dict{String, Any}(),
    contributing_services = Vector{Service}(),
    internal = InfrastructureSystemsInternal(),
) where {T <: ReserveDirection}
    U = typeof(get_power_units(variable))
    return GroupReserve{T, U}(
        name, available, requirement, variable, ext, contributing_services, internal,
    )
end

# Deserialization resolves `GroupReserve{T, U}` from metadata and calls it with kwargs.
function GroupReserve{T, U}(;
    name,
    available,
    requirement,
    variable = ZERO_OFFER_CURVE,
    ext = Dict{String, Any}(),
    contributing_services = Vector{Service}(),
    internal = InfrastructureSystemsInternal(),
) where {T <: ReserveDirection, U <: IS.AbstractUnitSystem}
    return GroupReserve{T, U}(
        name, available, requirement, variable, ext, contributing_services, internal,
    )
end

# Constructor for demo purposes; non-functional.
function GroupReserve{T}(::Nothing) where {T <: ReserveDirection}
    return GroupReserve{T}(;
        name = "init",
        available = false,
        requirement = 0.0,
        variable = ZERO_OFFER_CURVE,
        ext = Dict{String, Any}(),
        contributing_services = Vector{Service}(),
    )
end

# OnlineReserve and OfflineReserve share this exact field set; each accessor is defined
# once over the two-member union rather than duplicated per type. GroupReserve (different
# fields) keeps its own block below.
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `name`."""
get_name(value::Union{OnlineReserve, OfflineReserve}) = value.name
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `available`."""
get_available(value::Union{OnlineReserve, OfflineReserve}) = value.available
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `time_frame`."""
get_time_frame(value::Union{OnlineReserve, OfflineReserve}) = value.time_frame
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `requirement` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`). For the unit-bearing value see [`get_requirement_unitful`](@ref)."""
get_requirement(value::Union{OnlineReserve, OfflineReserve}, units) =
    IS._strip_units(get_value(value, Val(:requirement), Val(:mw), units))
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `requirement` as a unit-bearing quantity in the requested `units`. For a bare number see [`get_requirement`](@ref)."""
get_requirement_unitful(value::Union{OnlineReserve, OfflineReserve}, units) =
    get_value(value, Val(:requirement), Val(:mw), units)
# Must be `::Type{<:...}`: the fully-parameterized spelling would not match the partially
# applied `OnlineReserve{ReserveUp}` UnionAll that callers actually write.
IS.display_units_arg(
    ::typeof(get_requirement),
    ::Type{<:Union{OnlineReserve, OfflineReserve}},
) =
    u"SU"
IS.display_units_arg(
    ::typeof(get_requirement_unitful),
    ::Type{<:Union{OnlineReserve, OfflineReserve}},
) = u"SU"
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `variable`."""
get_variable(value::Union{OnlineReserve, OfflineReserve}) = value.variable
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `sustained_time`."""
get_sustained_time(value::Union{OnlineReserve, OfflineReserve}) = value.sustained_time
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `max_output_fraction`."""
get_max_output_fraction(value::Union{OnlineReserve, OfflineReserve}) =
    value.max_output_fraction
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `max_participation_factor`."""
get_max_participation_factor(value::Union{OnlineReserve, OfflineReserve}) =
    value.max_participation_factor
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `deployed_fraction`."""
get_deployed_fraction(value::Union{OnlineReserve, OfflineReserve}) = value.deployed_fraction
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `ext`."""
get_ext(value::Union{OnlineReserve, OfflineReserve}) = value.ext
"""Get [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `internal`."""
get_internal(value::Union{OnlineReserve, OfflineReserve}) = value.internal

"""Set [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `available`."""
set_available!(value::Union{OnlineReserve, OfflineReserve}, val) = value.available = val
"""Set [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `time_frame`."""
set_time_frame!(value::Union{OnlineReserve, OfflineReserve}, val) = value.time_frame = val
"""Set [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `requirement`."""
set_requirement!(value::Union{OnlineReserve, OfflineReserve}, val) =
    value.requirement = set_value(value, Val(:requirement), val, Val(:mw))
"""Set [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `variable`."""
set_variable!(value::Union{OnlineReserve, OfflineReserve}, val) = value.variable = val
"""Set [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `sustained_time`."""
set_sustained_time!(value::Union{OnlineReserve, OfflineReserve}, val) =
    value.sustained_time = val
"""Set [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `max_output_fraction`."""
set_max_output_fraction!(value::Union{OnlineReserve, OfflineReserve}, val) =
    value.max_output_fraction = val
"""Set [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `max_participation_factor`."""
set_max_participation_factor!(value::Union{OnlineReserve, OfflineReserve}, val) =
    value.max_participation_factor = val
"""Set [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `deployed_fraction`."""
set_deployed_fraction!(value::Union{OnlineReserve, OfflineReserve}, val) =
    value.deployed_fraction = val
"""Set [`OnlineReserve`](@ref)/[`OfflineReserve`](@ref) `ext`."""
set_ext!(value::Union{OnlineReserve, OfflineReserve}, val) = value.ext = val

"""Get [`GroupReserve`](@ref) `name`."""
get_name(value::GroupReserve) = value.name
"""Get [`GroupReserve`](@ref) `available`."""
get_available(value::GroupReserve) = value.available
"""Get [`GroupReserve`](@ref) `requirement` as a bare number in the requested `units` (e.g. `u"SU"`, `u"CU"`). For the unit-bearing value see [`get_requirement_unitful`](@ref)."""
get_requirement(value::GroupReserve, units) =
    IS._strip_units(get_value(value, Val(:requirement), Val(:mw), units))
"""Get [`GroupReserve`](@ref) `requirement` as a unit-bearing quantity in the requested `units`. For a bare number see [`get_requirement`](@ref)."""
get_requirement_unitful(value::GroupReserve, units) =
    get_value(value, Val(:requirement), Val(:mw), units)
IS.display_units_arg(::typeof(get_requirement), ::Type{<:GroupReserve}) = u"SU"
IS.display_units_arg(::typeof(get_requirement_unitful), ::Type{<:GroupReserve}) = u"SU"
"""Get [`GroupReserve`](@ref) `variable` (its operating reserve demand curve)."""
get_variable(value::GroupReserve) = value.variable
"""Get [`GroupReserve`](@ref) `ext`."""
get_ext(value::GroupReserve) = value.ext
"""Get [`GroupReserve`](@ref) `contributing_services`."""
get_contributing_services(value::GroupReserve) = value.contributing_services
"""Get [`GroupReserve`](@ref) `internal`."""
get_internal(value::GroupReserve) = value.internal

"""Set [`GroupReserve`](@ref) `available`."""
set_available!(value::GroupReserve, val) = value.available = val
"""Set [`GroupReserve`](@ref) `requirement`."""
set_requirement!(value::GroupReserve, val) =
    value.requirement = set_value(value, Val(:requirement), val, Val(:mw))
"""Set [`GroupReserve`](@ref) `variable` (its operating reserve demand curve)."""
set_variable!(value::GroupReserve, val) = value.variable = val
"""Set [`GroupReserve`](@ref) `ext`."""
set_ext!(value::GroupReserve, val) = value.ext = val
"""Set [`GroupReserve`](@ref) `contributing_services`."""
set_contributing_services!(value::GroupReserve, val) = value.contributing_services = val

"""
Return whether an Operating Reserve Demand Curve is defined on `reserve`.

`false` means `variable` holds the `ZERO_OFFER_CURVE` sentinel. A curve priced at zero spans a
nonzero quantity range and reads `true`.

Accepts a [`GroupReserve`](@ref) as well: a group carries its own curve, which is what distinguishes
an ELASTIC group (priced by the curve) from a fixed-requirement one.
"""
function has_demand_curve(reserve::AbstractReserve)
    return !_is_zero_offer_curve(get_variable(reserve))
end

function _is_zero_offer_curve(curve::CostCurve{PiecewiseIncrementalCurve})
    x_coords = get_x_coords(get_function_data(curve))
    return iszero(last(x_coords) - first(x_coords))
end

# The `ZERO_OFFER_CURVE` sentinel is a static curve, so a time-series-backed curve is always a
# real demand curve.
_is_zero_offer_curve(::CostCurve{<:TimeSeriesPiecewiseIncrementalCurve}) = false
