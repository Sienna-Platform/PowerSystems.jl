#=
Units labels on time series (prototype for PowerSystems.jl#1807).

InfrastructureSystems stores a series' `units`, `quantity_kind` and `unit_system` labels
without interpreting them. This file gives them meaning: a closed quantity vocabulary,
validation when a series is attached, and a getter that converts to the caller's units the
way the generated field getters do.
=#

"""
Quantities a time series may declare. A `UnitCategory` entry can be stored per unit
on its owner's base power. A bare unit names a quantity's natural unit; such a quantity is
stored in natural units, or in CU of a storage capacity where `_cu_base_field` allows.
"""
const TIME_SERIES_QUANTITIES = Dict{Symbol, Any}(
    :ActivePower => ACTIVE_POWER,
    :ReactivePower => REACTIVE_POWER,
    :ApparentPower => APPARENT_POWER,
    :Energy => u"MW*hr",
    :Volume => u"m^3",
    :VolumeFlowRate => u"m^3/s",
    :Elevation => u"m",
    :Head => u"m",
)

# PSB and PTDP write snake case (`"active_power"`); the vocabulary is camel case.
_quantity_symbol(s::AbstractString) = Symbol(join(uppercasefirst.(split(s, '_'))))
_quantity_symbol(s::Symbol) = _quantity_symbol(string(s))

function _ts_quantity(labels)
    s = IS.get_quantity_kind(labels)
    isnothing(s) && return nothing
    q = _quantity_symbol(s)
    haskey(TIME_SERIES_QUANTITIES, q) || throw(
        ArgumentError(
            "unknown time series quantity \"$s\"; expected one of " *
            "$(sort!(collect(keys(TIME_SERIES_QUANTITIES))))",
        ),
    )
    return q
end

"""The reserves with a `requirement` field."""
const _RequirementReserve = Union{OnlineReserve, OfflineReserve, GroupReserve}

_is_per_unit(u::Unitful.Units) = any(
    d -> typeof(d).parameters[1] === :GenericComponentBase,
    typeof(Unitful.dimension(u)).parameters[1],
)

# A `units` string names the units outright (`"CU hr^-1"` for a CU flow). Without one,
# `unit_system = CU` means plain `u"CU"`, and so does a natural label beside it (`"MW"` with
# `CU`, which names the quantity's natural unit rather than the stored one).
function _ts_source_units(labels)
    is_cu = IS.get_unit_system(labels) isa IS.ComponentBaseUnit
    s = IS.get_units(labels)
    isnothing(s) && return is_cu ? u"CU" : nothing
    units = get(() -> Unitful.uparse(s), STRING_TO_UNIT, s)
    return (is_cu && !_is_per_unit(units)) ? u"CU" : units
end

"""
The level and flow quantities a reservoir's series may declare, by `level_data_type`. An
energy reservoir's flows are power.
"""
const _RESERVOIR_QUANTITIES = Dict(
    ReservoirDataType.USABLE_VOLUME => (level = :Volume, flow = :VolumeFlowRate),
    ReservoirDataType.TOTAL_VOLUME => (level = :Volume, flow = :VolumeFlowRate),
    ReservoirDataType.HEAD => (level = :Head, flow = :VolumeFlowRate),
    ReservoirDataType.ENERGY => (level = :Energy, flow = :ActivePower),
)
_reservoir_quantities(r::HydroReservoir) = _RESERVOIR_QUANTITIES[get_level_data_type(r)]

"""
Whether `owner` may carry a series of quantity `q` at all. Power belongs to generators and
fluids to reservoirs: a hydro generator takes power quantities only, and a reservoir only
the level and flow quantities of its `level_data_type`.
"""
_accepts_quantity(::Component, ::Symbol) = true
_accepts_quantity(::HydroGen, q::Symbol) =
    TIME_SERIES_QUANTITIES[q] isa AbstractPowerCategory
_accepts_quantity(r::HydroReservoir, q::Symbol) = q in _reservoir_quantities(r)

"""
How `owner` stores quantity `q` per unit: the field a CU series is a fraction of, and the
per-unit units it must be in (`u"CU"`, or `u"CU/hr"` for a flow, which is a fraction of the
capacity per hour). `nothing` when `q` is natural units only on `owner`. Services and
topology take natural units only, except a reserve's power, which is a fraction of its
`requirement`. A `HEAD` reservoir is natural units only too: head is not conserved and is
measured above sea level, so a fraction of it means nothing.
"""
_cu_rule(owner, q::Symbol) = _cu_rule(owner, TIME_SERIES_QUANTITIES[q])
_cu_rule(::Component, ::AbstractPowerCategory) = (:base_power, u"CU")
_cu_rule(::Union{Service, Topology}, ::AbstractPowerCategory) = nothing
_cu_rule(::_RequirementReserve, ::ActivePowerCategory) = (:requirement, u"CU")
_cu_rule(::Any, ::Any) = nothing
_cu_rule(::EnergyReservoirStorage, q::Symbol) =
    q === :Energy ? (:storage_capacity, u"CU") : nothing
function _cu_rule(r::HydroReservoir, q::Symbol)
    get_level_data_type(r) == ReservoirDataType.HEAD && return nothing
    quantities = _reservoir_quantities(r)
    q === quantities.level && return (:storage_level_limits, u"CU")
    q === quantities.flow && return (:storage_level_limits, u"CU/hr")
    return nothing
end

# 1.0 CU of a storage level, in natural units. `conversion_factor` turns a non-MWh medium
# (e.g. liters of hydrogen) into MWh.
_cu_capacity(s::EnergyReservoirStorage) =
    get_storage_capacity(s, u"MW") * get_conversion_factor(s) * u"MW*hr"
_cu_capacity(r::HydroReservoir) =
    get_storage_level_limits(r).max * TIME_SERIES_QUANTITIES[_reservoir_quantities(r).level]

_ts_natural_unit(cat::UnitCategory) = natural_unit(cat)
_ts_natural_unit(u::Unitful.Units) = u

"""
Check a series' units labels (a series or its metadata) against `owner`. Returns the field a
CU series is a fraction of, or `nothing` for a natural or unlabeled series.
"""
function _check_time_series_labels(owner::Component, labels)
    name = IS.get_name(labels)
    units = _ts_source_units(labels)
    q = _ts_quantity(labels)
    # ponytail: unlabeled series pass unchecked so PSB keeps building; require labels once
    # PSB and PTDP write them everywhere.
    isnothing(units) && isnothing(q) && return nothing
    isnothing(q) && throw(
        ArgumentError("time series \"$name\" declares units $units but no quantity"),
    )
    isnothing(units) && throw(
        ArgumentError("time series \"$name\" declares quantity $q but no units"),
    )
    _accepts_quantity(owner, q) || throw(
        ArgumentError("$(summary(owner)) does not take $q time series (\"$name\")"),
    )
    kind = TIME_SERIES_QUANTITIES[q]
    if !_is_per_unit(units)
        Unitful.dimension(units) == Unitful.dimension(_ts_natural_unit(kind)) || throw(
            ArgumentError(
                "time series \"$name\" declares quantity $q, which is measured in " *
                "$(_ts_natural_unit(kind)), but its units are $units",
            ),
        )
        return nothing
    end
    rule = _cu_rule(owner, q)
    isnothing(rule) && throw(
        ArgumentError(
            "$(summary(owner)) does not accept $q time series in CU; store \"$name\" in " *
            "natural units",
        ),
    )
    field, cu_units = rule
    Unitful.dimension(units) == Unitful.dimension(cu_units) || throw(
        ArgumentError(
            "time series \"$name\" is $q on $(summary(owner)), stored per unit in " *
            "$cu_units, but its units are $units",
        ),
    )
    hasfield(typeof(owner), field) || throw(
        ArgumentError("$(summary(owner)) has no `$field` for CU series \"$name\""),
    )
    return field
end

"""
Check a series' units labels against the component it is being attached to. `base_field`
names the owner field a CU series is a fraction of, and must match `_cu_rule`; it is
checked here and not stored.
"""
function _validate_time_series_labels(
    owner::Component,
    ts::TimeSeriesData,
    base_field::Union{Nothing, Symbol},
)
    expected = _check_time_series_labels(owner, ts)
    expected === base_field && return
    name = get_name(ts)
    isnothing(expected) && throw(
        ArgumentError("time series \"$name\": `base_field` applies to CU series only"),
    )
    throw(
        ArgumentError(
            "time series \"$name\" on $(summary(owner)) is a fraction of `$expected`; " *
            "pass `base_field = :$expected`",
        ),
    )
end

"""
Check the units labels of every series in `sys`. The document import path bulk-loads its
associations without `add_time_series!`, so it runs this once its components are built.
The base field is not stored, so only the labels themselves are checked.
"""
function _check_all_time_series_labels(sys::System)
    for component in get_components(Component, sys)
        has_time_series(component) || continue
        for md in list_time_series_metadata(component)
            _check_time_series_labels(component, md)
        end
    end
    return
end

# Every quantity in the vocabulary converts linearly, so one factor covers the whole series.
_ts_conversion_factor(c, cat::UnitCategory, from, to) =
    ustrip(to, convert_units(c, 1.0 * from, cat, to))
# Storage quantities, and a reservoir's power flows, are per unit of a capacity instead.
_ts_conversion_factor(c, ::Unitful.Units, from, to) =
    _capacity_conversion_factor(c, from, to)
_ts_conversion_factor(c::HydroReservoir, ::UnitCategory, from, to) =
    _capacity_conversion_factor(c, from, to)
# A reserve's CU is a fraction of its `requirement`, which the field getter reads in `to`.
function _ts_conversion_factor(r::_RequirementReserve, cat::UnitCategory, from, to)
    _is_per_unit(from) || return ustrip(to, convert_units(r, 1.0 * from, cat, to))
    _is_per_unit(to) && return ustrip(to, 1.0 * from)
    return get_requirement(r, to)
end

function _capacity_conversion_factor(c, from, to)
    (_is_per_unit(from) && !_is_per_unit(to)) || return ustrip(to, 1.0 * from)
    return ustrip(to, _cu_capacity(c) * (1.0 * from / u"CU"))
end

"""
    get_time_series_values(T, component, name, units; quantity = nothing, kwargs...)

Return the values of a time series converted to `units`: `u"CU"`, `u"SU"`, or a natural unit
such as `u"MW"`. The series must carry units labels. `quantity` (e.g. `:ActivePower`), when
given, must match the series' own, so a generic `u"CU"` read cannot mistake reactive power
for active power. The remaining keywords are those of the unitless method.
"""
function get_time_series_values(
    ::Type{T},
    component::Component,
    name::AbstractString,
    units::Unitful.Units;
    quantity::Union{Nothing, Symbol, AbstractString} = nothing,
    resolution::Union{Nothing, Dates.Period} = nothing,
    interval::Union{Nothing, Dates.Period} = nothing,
    start_time::Union{Nothing, Dates.DateTime} = nothing,
    len::Union{Nothing, Int} = nothing,
    features::Union{Nothing, Dict} = nothing,
) where {T <: TimeSeriesData}
    md = get_time_series_metadata(
        T,
        component,
        name;
        resolution = resolution,
        interval = interval,
        features = features,
    )
    q = _ts_quantity(md)
    source = _ts_source_units(md)
    (isnothing(q) || isnothing(source)) && throw(
        ArgumentError(
            "time series \"$name\" on $(summary(component)) has no units labels, so it " *
            "cannot be read in $units",
        ),
    )
    isnothing(quantity) || _quantity_symbol(quantity) === q ||
        throw(
            ArgumentError("time series \"$name\" is $q, not $quantity"),
        )
    values = IS.get_time_series_values(
        T,
        component,
        name;
        resolution = resolution,
        interval = interval,
        start_time = start_time,
        len = len,
        features = features,
    )
    return values .*
           _ts_conversion_factor(component, TIME_SERIES_QUANTITIES[q], source, units)
end
