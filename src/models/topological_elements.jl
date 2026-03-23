"""
Abstract supertype for network topology elements.

Subtypes: [`AggregationTopology`](@ref) (e.g., [`Area`](@ref), [`LoadZone`](@ref)),
[`Bus`](@ref) (e.g., [`ACBus`](@ref), [`DCBus`](@ref)), and [`Arc`](@ref)
"""
abstract type Topology <: Component end

"""
Abstract supertype for geographical or electrical aggregation regions.

Subtypes: [`Area`](@ref), [`LoadZone`](@ref)

See also: [`Topology`](@ref)
"""
abstract type AggregationTopology <: Topology end

supports_time_series(::AggregationTopology) = true

"""
Abstract supertype for all bus types in a power system network.

Subtypes: [`ACBus`](@ref), [`DCBus`](@ref)

See also: [`Arc`](@ref), [`Topology`](@ref)
"""
abstract type Bus <: Topology end

"""
Abstract interface method — return the accessor function to call on an [`ACBus`](@ref)
to retrieve its [`AggregationTopology`](@ref) value for subtype `T`.

Throws an error if not implemented for `T`. Concrete subtypes of [`AggregationTopology`](@ref)
must provide a method for this function.

See also: [`get_area`](@ref), [`get_load_zone`](@ref)
"""
function get_aggregation_topology_accessor(::Type{T}) where {T <: AggregationTopology}
    error("get_aggregation_topology_accessor must be implemented for $T")
    return
end

function check_bus_params(
    number,
    name,
    available,
    bustype,
    angle,
    voltage,
    voltage_limits,
    base_voltage,
    area,
    load_zone,
    ext,
    internal,
)
    if !isnothing(bustype)
        if bustype == ACBusTypes.SLACK
            bustype = ACBusTypes.REF
            @debug "Changed bus type from SLACK to" _group = IS.LOG_GROUP_SYSTEM bustype
            #elseif bustype == BusTypes.ISOLATED
            #    throw(DataFormatError("isolated buses are not supported; name=$name"))
        end
    end

    return number,
    name,
    available,
    bustype,
    angle,
    voltage,
    voltage_limits,
    base_voltage,
    area,
    load_zone,
    ext,
    internal
end
