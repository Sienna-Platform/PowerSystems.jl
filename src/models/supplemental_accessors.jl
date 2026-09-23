
"""
Return the appropriate accessor function for the given aggregation topology type.
For [`Area`](@ref) types, returns [`get_area`](@ref); for [`LoadZone`](@ref) types, returns [`get_load_zone`](@ref).
"""
get_aggregation_topology_accessor(::Type{Area}) = get_area
"""
Return the appropriate accessor function for the given aggregation topology type.
For [`Area`](@ref) types, returns [`get_area`](@ref); for [`LoadZone`](@ref) types, returns [`get_load_zone`](@ref).
"""
get_aggregation_topology_accessor(::Type{LoadZone}) = get_load_zone

"""
Set the [`LoadZone`](@ref) for an [`ACBus`](@ref).
"""
set_load_zone!(bus::ACBus, load_zone::LoadZone) = bus.load_zone = load_zone
"""
Set the [`Area`](@ref) for an [`ACBus`](@ref).
"""
set_area!(bus::ACBus, area::Area) = bus.area = area

"""
Remove the aggregation topology in a [`ACBus`](@ref) by setting the corresponding field to `nothing`.
"""
_remove_aggregration_topology!(bus::ACBus, ::LoadZone) = bus.load_zone = nothing
_remove_aggregration_topology!(bus::ACBus, ::Area) = bus.area = nothing

"""
    get_base_voltage(line::Union{Line, MonitoredLine})

Return the base voltage (kV) of a [`Line`](@ref) or [`MonitoredLine`](@ref) by reading the
`base_voltage` from both endpoints of the line's [`Arc`](@ref).

If the two bus voltages are identical, that value is returned directly. If they differ but
are within `BRANCH_BUS_VOLTAGE_DIFFERENCE_TOL` (percent), the value with fewer significant
figures is returned (i.e., the rounder number). If the difference exceeds the tolerance, an
error is thrown.
"""
function get_base_voltage(line::Union{Line, MonitoredLine})
    v_from = get_base_voltage(get_from_bus(line))
    v_to = get_base_voltage(get_to_bus(line))
    v_from == v_to && return v_from
    percent_diff = abs(v_from - v_to) / ((v_from + v_to) / 2)
    if percent_diff > BRANCH_BUS_VOLTAGE_DIFFERENCE_TOL
        error(
            "Bus voltage mismatch on $(get_name(line)): " *
            "from=$(v_from) kV, to=$(v_to) kV exceeds " *
            "$(BRANCH_BUS_VOLTAGE_DIFFERENCE_TOL * 100)% tolerance.",
        )
    end
    return _select_fewer_significant_figures(v_from, v_to)
end

"""
Select the value with fewer significant figures (the "rounder" number),
comparing the coarsest decimal granularity at which each value is exactly
representable. Purely numeric — this sits on conversion paths, so no string
round-trips.
"""
function _select_fewer_significant_figures(a::Float64, b::Float64)
    ga = _decimal_granularity(a)
    gb = _decimal_granularity(b)
    ga < gb && return a
    gb < ga && return b
    return max(a, b)
end

# Smallest digit count `d` such that `round(v; digits = d) == v`; lower means
# coarser (rounder) numbers.
function _decimal_granularity(v::Float64)
    for d in -6:10
        round(v; digits = d) == v && return d
    end
    return 11
end

"""
    get_high_voltage(t::TwoWindingTransformer)

Return the high-side base voltage (kV) of a [`TwoWindingTransformer`](@ref) as the
maximum of the circuit's primary and secondary base voltages.
"""
function get_high_voltage(t::TwoWindingTransformer)
    circuit = get_circuit(t)
    return max(get_base_voltage_primary(circuit), get_base_voltage_secondary(circuit))
end

"""
    get_low_voltage(t::TwoWindingTransformer)

Return the low-side base voltage (kV) of a [`TwoWindingTransformer`](@ref) as the
minimum of the circuit's primary and secondary base voltages.
"""
function get_low_voltage(t::TwoWindingTransformer)
    circuit = get_circuit(t)
    return min(get_base_voltage_primary(circuit), get_base_voltage_secondary(circuit))
end

"""
Return the max active power for a device with explicit units specified.
"""
function get_max_active_power(d::T, units) where {T <: StaticInjection}   # units untyped deliberately: typed UnitArg is dispatch-ambiguous vs generated per-type methods (untyped units); fix belongs in the IS codegen template
    return get_active_power_limits(d, units).max
end

"""
Return the max reactive power for a device with explicit units specified.
"""
function get_max_reactive_power(d::T, units) where {T <: StaticInjection}   # units untyped deliberately: see get_max_active_power note above
    limits = get_reactive_power_limits(d, units)
    isnothing(limits) && return Inf
    return limits.max
end

"""
Return the max reactive power for a [`RenewableDispatch`](@ref) generator calculated as the `rating` * `power_factor` if
the field `reactive_power_limits` is `nothing`
"""
function get_max_reactive_power(d::RenewableDispatch, units::UnitArg)
    limits = get_reactive_power_limits(d, units)
    if isnothing(limits)
        return get_rating(d, units) * sin(acos(get_power_factor(d)))
    end
    return limits.max
end

"""
Generic fallback function for getting active power limits. Throws `ArgumentError` for devices
that don't implement this function.
"""
get_active_power_limits(::T, _) where {T <: Device} =
    throw(ArgumentError("get_active_power_limits not implemented for $T"))
"""
Generic fallback function for getting reactive power limits. Throws `ArgumentError` for devices
that don't implement this function.
"""
get_reactive_power_limits(::T, _) where {T <: Device} =
    throw(ArgumentError("get_reactive_power_limits not implemented for $T"))
"""
Generic fallback function for getting device rating. Throws `ArgumentError` for devices
that don't implement this function.
"""
get_rating(::T, _) where {T <: Device} =
    throw(ArgumentError("get_rating not implemented for $T"))
"""
Generic fallback function for getting power factor. Throws `ArgumentError` for devices
that don't implement this function.
"""
get_power_factor(::T) where {T <: Device} =
    throw(ArgumentError("get_power_factor not implemented for $T"))

"""
Calculate the maximum active power for a [`StandardLoad`](@ref) or [`InterruptibleStandardLoad`](@ref)
    with explicit units specified.
"""
function get_max_active_power(
    d::Union{InterruptibleStandardLoad, StandardLoad},
    units::UnitArg,
)
    total_load = get_max_constant_active_power(d, units)
    total_load += get_max_impedance_active_power(d, units)
    total_load += get_max_current_active_power(d, units)
    return total_load
end

"""
Get the maximum storage capacity for HydroReservoir.
"""
function get_max_storage_level(reservoir::HydroReservoir)
    return get_storage_level_limits(reservoir).max
end

"""
Get the flow limits from source [`Area`](@ref) to destination [`Area`](@ref) for an [`AreaInterchange`](@ref), in the specified `units`.
"""
function get_from_to_flow_limit(a::AreaInterchange, units::UnitArg)
    return get_flow_limits(a, units).from_to
end
"""
Get the flow limits from destination [`Area`](@ref) to source [`Area`](@ref) for an [`AreaInterchange`](@ref), in the specified `units`.
"""
function get_to_from_flow_limit(a::AreaInterchange, units::UnitArg)
    return get_flow_limits(a, units).to_from
end

"""
Get the minimum active power flow limit for a [`TransmissionInterface`](@ref), in the specified `units`.
"""
function get_min_active_power_flow_limit(tx::TransmissionInterface, units::UnitArg)
    return get_active_power_flow_limits(tx, units).min
end

"""
Get the maximum active power flow limit for a [`TransmissionInterface`](@ref), in the specified `units`.
"""
function get_max_active_power_flow_limit(tx::TransmissionInterface, units::UnitArg)
    return get_active_power_flow_limits(tx, units).max
end

"""
Get the [`TwoTerminalLCCLine`](@ref) `transfer_setpoint` in the specified `units`. In power mode
(`power_mode = true`) it is converted from the component base like any power field (`SU`, `CU`,
`NU` for MW); in current mode it is Amperes and is returned unchanged.
"""
function get_transfer_setpoint(lcc::TwoTerminalLCCLine, units::UnitArg)
    if get_power_mode(lcc)
        return IS._strip_units(get_value(lcc, Val(:transfer_setpoint), Val(:mw), units))
    end
    return get_transfer_setpoint(lcc)
end

function supports_services(::AreaInterchange)
    return true
end

# supports_active_power overrides for types without controllable active power
supports_active_power(::SynchronousCondenser) = false

# supports_reactive_power overrides for types without controllable reactive power
supports_reactive_power(::InterconnectingConverter) = false

# A shunt-admittance component counts as power support only above an absolute
# threshold, so negligible admittances do not force their host bus to be kept.
_nonzero_admittance(x::Real) = abs(x) > ZERO_ADMITTANCE_THRESHOLD

# FixedAdmittance supports active power via conductance
# (real(Y)) and reactive power via susceptance (imag(Y)), so capability is
# parameter-dependent rather than a fixed type property.
supports_active_power(d::FixedAdmittance) = _nonzero_admittance(real(get_Y(d)))
supports_reactive_power(d::FixedAdmittance) = _nonzero_admittance(imag(get_Y(d)))

# SwitchedAdmittance has no fixed admittance: it shifts admittance only via the
# per-block switchable steps, so capability is any block with steps and an
# above-threshold increment in the relevant component. `solved_admittance` is a
# susceptance, so it can additionally establish reactive support.
function supports_active_power(d::SwitchedAdmittance)
    return any(
        n > 0 && _nonzero_admittance(real(yi))
        for (n, yi) in zip(get_number_of_steps(d), get_Y_increase(d))
    )
end

function supports_reactive_power(d::SwitchedAdmittance)
    solved = get_solved_admittance(d)
    !isnothing(solved) && _nonzero_admittance(solved) && return true
    return any(
        n > 0 && _nonzero_admittance(imag(yi))
        for (n, yi) in zip(get_number_of_steps(d), get_Y_increase(d))
    )
end

# FACTSControlDevice reactive power and voltage control depend on control_mode.
# control_mode is nothing for uninitialized devices (e.g. FACTSControlDevice(nothing)).
_facts_is_active(d::FACTSControlDevice) =
    (mode = get_control_mode(d); !isnothing(mode) && mode != FACTSOperationModes.OOS)

# In NML mode both Series and Shunt links operate, enabling active power control.
# In BYP mode the Series link is bypassed and the Shunt acts as a STATCOM (reactive only).
function supports_active_power(d::FACTSControlDevice)
    mode = get_control_mode(d)
    return !isnothing(mode) && mode == FACTSOperationModes.NML
end

supports_reactive_power(d::FACTSControlDevice) = _facts_is_active(d)

# supports_voltage_control overrides for types that can control voltage
supports_voltage_control(::Generator) = true
supports_voltage_control(::Source) = true
supports_voltage_control(::Storage) = true
supports_voltage_control(::StaticInjectionSubsystem) = true

supports_voltage_control(d::FACTSControlDevice) = _facts_is_active(d)

function supports_voltage_control(d::SynchronousCondenser)
    bustype = get_bustype(get_bus(d))
    return bustype ∈ (ACBusTypes.PV, ACBusTypes.REF, ACBusTypes.SLACK)
end

function set_units_setting!(
    value::HybridSystem,
    settings::Union{Float64, Nothing},
)
    IS.set_base_value!(value, settings)
    for component in get_subcomponents(value)
        IS.set_base_value!(component, settings)
    end
    return
end

function set_units_setting!(
    t::Union{TwoWindingTransformer, ThreeWindingTransformer},
    value::Union{Float64, Nothing},
)
    IS.set_base_value!(t, value)
    for w in get_circuits(t)
        IS.set_base_value!(w, value)
    end
    return
end

"""
Return an iterator over the subcomponents in the HybridSystem.

# Examples
```julia
for subcomponent in get_subcomponents(hybrid_sys)
    @show subcomponent
end
subcomponents = collect(get_subcomponents(hybrid_sys))
```
"""
function get_subcomponents(hybrid::HybridSystem)
    return (
        sc for sc in (
            hybrid.thermal_unit,
            hybrid.electric_load,
            hybrid.storage,
            hybrid.renewable_unit,
        ) if !isnothing(sc)
    )
end
