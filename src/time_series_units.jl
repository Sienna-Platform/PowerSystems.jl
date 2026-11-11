#=
Units labels on time series (prototype for PowerSystems.jl#1807).

InfrastructureSystems stores a series' `units`, `quantity_kind` and `per_unit_of` labels
without interpreting them, and derives `unit_system` from them (CU with `per_unit_of`, NU
with only `units`). This file gives them meaning: a closed quantity vocabulary,
validation when a series is attached, and a getter that converts to the caller's units the
way the generated field getters do.
=#

"""
Quantities a time series may declare. A `UnitCategory` entry is a power; a bare unit names a
quantity's natural unit. Which of them may be stored in CU, and of what, is
`_per_unit_of`.
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

_is_per_unit(u::Unitful.Units)::Bool = any(
    d -> typeof(d).parameters[1] === :GenericComponentBase,
    typeof(Unitful.dimension(u)).parameters[1],
)

# A `units` string names the units outright. Without one, a series with `per_unit_of` (IS
# derives CU from it) is plain `u"CU"`. The basis and the units must agree: CU takes
# per-unit units, NU natural ones.
function _ts_source_units(labels::Union{TimeSeriesData, IS.TimeSeriesMetadata})
    name = IS.get_name(labels)
    is_cu = IS.get_unit_system(labels) isa IS.ComponentBaseUnit
    s = IS.get_units(labels)
    isnothing(s) && return is_cu ? u"CU" : nothing
    units = get(() -> Unitful.uparse(s), STRING_TO_UNIT, s)::Unitful.Units
    is_cu == _is_per_unit(units) && return units
    is_cu && throw(
        ArgumentError(
            "time series \"$name\" declares per_unit_of but units $units; with " *
            "per_unit_of, units must be CU or unset",
        ),
    )
    throw(
        ArgumentError(
            "time series \"$name\" declares per-unit units $units but no per_unit_of",
        ),
    )
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
_accepts_quantity(::HydroGen, q::Symbol) = _is_power(q)
_accepts_quantity(r::HydroReservoir, q::Symbol) = q in _reservoir_quantities(r)

"""
The field a CU series of quantity `q` on `owner` is a fraction of, or `nothing` when `q` is
natural units only there. Only two things take CU: a device's power, a fraction of its
`base_power`, and a battery's stored energy, a fraction of its `storage_capacity`.
Everything else is natural units only: reservoirs (levels and flows alike), services,
topology, and any owner without a `base_power` field.
"""
_per_unit_of(::T, q::Symbol) where {T <: Component} =
    _is_power(q) && hasfield(T, :base_power) ? :base_power : nothing
_per_unit_of(::Union{Service, Topology, HydroReservoir}, ::Symbol) = nothing
_per_unit_of(::EnergyReservoirStorage, q::Symbol) =
    q === :Energy ? :storage_capacity : _is_power(q) ? :base_power : nothing

_is_power(q::Symbol) = TIME_SERIES_QUANTITIES[q] isa AbstractPowerCategory

# 1.0 CU of a battery's stored energy, in MWh. `conversion_factor` turns a non-MWh medium
# (e.g. liters of hydrogen) into MWh.
_cu_capacity(s::EnergyReservoirStorage) =
    get_storage_capacity(s, u"MW") * get_conversion_factor(s) * u"MW*hr"

_ts_natural_unit(cat::UnitCategory) = natural_unit(cat)
_ts_natural_unit(u::Unitful.Units) = u

"""
Check a series' units labels (a series or its metadata) against `owner`, when it is attached
and again when a system is read back. A CU series (one with `per_unit_of`) must name the
field `_per_unit_of` says it is a fraction of; it is redundant with that rule, but makes the
stored series say what it is a fraction of without anyone knowing the rule.
"""
function _check_time_series_labels(
    owner::Component,
    labels::Union{TimeSeriesData, IS.TimeSeriesMetadata},
)
    name = IS.get_name(labels)
    per_unit_of = IS.get_per_unit_of(labels)
    units = _ts_source_units(labels)
    q = _ts_quantity(labels)
    # ponytail: unlabeled series pass unchecked so PSB keeps building; require labels once
    # PSB and PTDP write them everywhere.
    isnothing(units) && isnothing(q) && return
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
        return
    end
    field = _per_unit_of(owner, q)
    isnothing(field) && throw(
        ArgumentError(
            "$(summary(owner)) does not accept $q time series in CU; store \"$name\" in " *
            "natural units",
        ),
    )
    units == u"CU" || throw(
        ArgumentError(
            "time series \"$name\" is $q on $(summary(owner)), stored in CU, but its " *
            "units are $units",
        ),
    )
    per_unit_of == string(field) && return
    throw(
        ArgumentError(
            "time series \"$name\" on $(summary(owner)) is a fraction of `$field`, not " *
            "`$per_unit_of`",
        ),
    )
end

# IS calls this before every series is attached: each add, direct, bulk or in a transaction,
# and each copy (with the source's metadata).
IS.check_time_series_owner(
    owner::Component,
    labels::Union{TimeSeriesData, IS.TimeSeriesMetadata},
) = _check_time_series_labels(owner, labels)

"""
Check the units labels of every series in `sys`. The document import path bulk-loads its
associations without `add_time_series!`, so it runs this once its components are built.
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
# `convert_units` resolves a generic `u"NU"` to the natural unit, so strip what it returns
# rather than converting back to `to`.
_ts_conversion_factor(c, cat::UnitCategory, from, to) =
    ustrip(convert_units(c, 1.0 * from, cat, to))
# A battery's energy is per unit of its capacity instead. A reservoir has no `base_power`, so
# its power flows (an energy reservoir's) also go through natural units.
_ts_conversion_factor(c, ::Unitful.Units, from, to) =
    _capacity_conversion_factor(c, from, to)
_ts_conversion_factor(c::HydroReservoir, ::UnitCategory, from, to) =
    _capacity_conversion_factor(c, from, to)

# Both sides go through natural units: CU is that much of the capacity, and SU
# (SU*hr for energy) that much of the system base in MW. Water quantities have no SU, so
# reading one in SU fails on its dimension.
_capacity_conversion_factor(c, from, to) =
    Unitful.uconvert(Unitful.NoUnits, _in_natural_units(c, from) / _in_natural_units(c, to))

function _in_natural_units(c, u)
    _is_per_unit(u) && return _cu_capacity(c) * (1.0 * u / u"CU")
    _is_system_base(u) && return _get_system_base_power(c) * u"MW" * (1.0 * u / u"SU")
    return 1.0 * u
end

_is_system_base(u::Unitful.Units) = any(
    d -> typeof(d).parameters[1] === :GenericSystemBase,
    typeof(Unitful.dimension(u)).parameters[1],
)

# Check that the series named `name` can be read in `units`, and return the factor that
# converts its stored values there.
function _ts_read_factor(
    ::Type{T},
    component::Component,
    name::AbstractString,
    units::Unitful.Units,
    quantity,
    resolution,
    interval,
    features,
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
    _is_per_unit(units) && isnothing(_per_unit_of(component, q)) &&
        throw(
            ArgumentError(
                "$(summary(component)) has no CU base for $q, so \"$name\" cannot be read " *
                "in $units; read it in natural units",
            ),
        )
    return _ts_conversion_factor(
        component,
        TIME_SERIES_QUANTITIES[q],
        source,
        units,
    )::Float64
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
    factor = _ts_read_factor(
        T, component, name, units, quantity, resolution, interval, features)
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
    return values .* factor
end

"""
    get_time_series_array(T, component, name, units; quantity = nothing, kwargs...)

Return a time series as a `TimeArray` with its values converted to `units`, as
[`get_time_series_values`](@ref) does with the same arguments.
"""
function get_time_series_array(
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
    factor = _ts_read_factor(
        T, component, name, units, quantity, resolution, interval, features)
    ta = IS.get_time_series_array(
        T,
        component,
        name;
        resolution = resolution,
        interval = interval,
        start_time = start_time,
        len = len,
        features = features,
    )
    return TimeSeries.TimeArray(TimeSeries.timestamp(ta), TimeSeries.values(ta) .* factor)
end
