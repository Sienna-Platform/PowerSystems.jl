
### Utility Functions needed for the construction of the Power System, mostly used for consistency checking ####

"""
Sum a getter over components in MW, returning `zero(MW_ACCUMULATOR_TYPE)` if empty.
"""
function _sum_or_zero(getter::Function, components)
    if isempty(components)
        return zero(MW_ACCUMULATOR_TYPE)
    else
        return sum(c -> getter(c, MW), components)
    end
end

## Check that all the buses have a type defintion and that bus types are consistent with generator connections ##

function buscheck(sys::System)
    buses = get_components(ACBus, sys)
    for b in buses
        b_type = get_bustype(b)
        if isnothing(b_type)
            @warn "Bus/Nodes data does not contain information to build an a network" maxlog =
                10
        end
    end
    return
end

## Slack Bus Definition ##

function slack_bus_check(buses)
    slack = -9
    for b in buses
        if b.bustype == ACBusTypes.REF
            slack = b.number
            break
        end
    end
    if slack == -9
        @error "Model doesn't contain a slack bus"
    end
    return
end

# TODO: Check for islanded Buses

# check for minimum timediff
function minimumtimestep(time_series::Array{T}) where {T <: TimeSeriesData}
    if length(time_series[1].data) > 1
        timeseries = time_series[1].data
        n = length(timeseries) - 1
        ts = []
        for i in 1:n
            push!(
                ts,
                TimeSeries.timestamp(timeseries)[n + 1] -
                TimeSeries.timestamp(timeseries)[n],
            )
        end
        return minimum(ts)
    else
        ts = Dates.Dates.Minute(1)
        return ts
    end
end

function critical_components_check(sys::System)
    critical_component_types = [ACBus, Generator, ElectricLoad]
    for component_type in critical_component_types
        components = get_available_components(component_type, sys)
        if length(components) == 0
            @warn "There are no $(component_type) Components in the System"
        end
    end
end

"""
    adequacy_check(sys::System)

Checks the system for sum(generator ratings) >= sum(load ratings).

# Arguments
- `sys::System`: system
"""
function adequacy_check(sys::System)
    gen = total_capacity_rating(sys)
    load = total_load_rating(sys)
    load > gen && @warn "System peak load ($load) exceeds total capacity capability ($gen)."
    return
end

"""
    total_load_rating(sys::System)

Sum of load ratings.

# Arguments
- `sys::System`: system
"""
function total_load_rating(sys::System)
    sl = _sum_or_zero(get_max_active_power, get_available_components(StaticLoad, sys))
    @debug "System has $sl MW of StaticLoad" _group = IS.LOG_GROUP_SYSTEM_CHECKS
    # Total load calculation for admittances assumes P = Real(V^2*Y) with V=1.0
    fa_loads = get_available_components(FixedAdmittance, sys)
    fa =
        if isempty(fa_loads)
            zero(MW_ACCUMULATOR_TYPE)
        else
            sum(real.(1.0 .* get_Y.(fa_loads))) * _get_base_power(sys) * MW
        end
    @debug "System has $fa MW of FixedAdmittance" _group = IS.LOG_GROUP_SYSTEM_CHECKS
    sa_loads = get_available_components(SwitchedAdmittance, sys)
    sa =
        if isempty(sa_loads)
            zero(MW_ACCUMULATOR_TYPE)
        else
            sum(real.(1.0 .* get_Y.(sa_loads))) * _get_base_power(sys) * MW
        end
    @debug "System has $sa MW of SwitchedAdmittance" _group = IS.LOG_GROUP_SYSTEM_CHECKS
    total_load = sl + fa + sa
    @debug "Total System Load: $total_load" _group = IS.LOG_GROUP_SYSTEM_CHECKS
    return total_load
end

"""
    total_capacity_rating(sys::System)

Sum of system generator and storage ratings.

# Arguments
- `sys::System`: system
"""
function total_capacity_rating(sys::System)
    total = zero(MW_ACCUMULATOR_TYPE)
    for component_type in (Generator, Storage)
        component_total =
            _sum_or_zero(get_rating, get_available_components(component_type, sys))
        @debug "total rating for $component_type = $component_total" _group =
            IS.LOG_GROUP_SYSTEM_CHECKS
        total += component_total
    end

    @debug "Total System capacity: $total" _group = IS.LOG_GROUP_SYSTEM_CHECKS
    return total
end
