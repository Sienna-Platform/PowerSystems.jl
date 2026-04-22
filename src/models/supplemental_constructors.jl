"""
Construct a [`Line`](@ref) accepting `angle_limits` as a `Float64`, converting it to a
symmetric `(min = -angle_limits, max = angle_limits)` named tuple.
"""
function Line(
    name,
    available::Bool,
    active_power_flow::Float64,
    reactive_power_flow::Float64,
    arc::Arc,
    r,
    x,
    b,
    rating,
    angle_limits::Float64,
)
    return Line(
        name,
        available,
        active_power_flow,
        reactive_power_flow,
        arc::Arc,
        r,
        x,
        b,
        rating,
        (min = -angle_limits, max = angle_limits),
    )
end

"""
Construct an [`ACBus`](@ref) with `bustype` specified as a `String` for legacy compatibility.

The string is converted to the corresponding [`ACBusTypes`](@ref) enum value.
"""
function ACBus(
    number,
    name,
    available,
    bustype::String,
    angle,
    voltage,
    voltage_limits,
    base_voltage,
    area,
    load_zone;
    ext = Dict{String, Any}(),
)
    return ACBus(
        number,
        name,
        available,
        get_enum_value(ACBusTypes, bustype),
        angle,
        voltage,
        voltage_limits,
        base_voltage,
        area,
        load_zone,
        ext,
        InfrastructureSystemsInternal(),
    )
end

"""
Construct a [`DiscreteControlledACBranch`](@ref) with enum types specified as strings for legacy compatibility.

The `discrete_branch_type` and `branch_status` strings are converted to the corresponding
[`DiscreteControlledBranchType`](@ref) and [`DiscreteControlledBranchStatus`](@ref) enum values.
"""
function DiscreteControlledACBranch(
    name,
    available,
    arc,
    active_power_flow,
    reactive_power_flow,
    r,
    x,
    rating,
    discrete_branch_type::String,
    branch_status::String,
    ext = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
)
    return DiscreteControlledACBranch(
        name,
        available,
        arc,
        active_power_flow,
        reactive_power_flow,
        r,
        x,
        rating,
        get_enum_value(DiscreteControlledBranchType, discrete_branch_type),
        get_enum_value(DiscreteControlledBranchStatus, branch_status),
        ext,
        internal,
    )
end

"""
Construct a [`FACTSControlDevice`](@ref) with `control_mode` specified as a string.

The string is converted to the corresponding [`FACTSOperationModes`](@ref) enum value.
"""
function FACTSControlDevice(
    name,
    available,
    bus,
    control_mode::String,
    voltage_setpoint,
    max_shunt_current,
    reactive_power_required,
    services = Device[],
    dynamic_injector = nothing,
    ext = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
)
    return FACTSControlDevice(
        name,
        available,
        bus,
        get_enum_value(FACTSOperationModes, control_mode),
        voltage_setpoint,
        max_shunt_current,
        reactive_power_required,
        services,
        dynamic_injector,
        ext,
        internal,
    )
end

"""
Construct a [`ConstantReserve`](@ref) from a `contributingdevices` iterator, collecting it into a vector.
"""
function ConstantReserve(
    name,
    contributingdevices::IS.FlattenIteratorWrapper,
    timeframe,
    requirement,
    time_series,
    internal,
)
    return ConstantReserve(
        name,
        collect(contributingdevices),
        timeframe,
        requirement,
        time_series,
        internal,
    )
end

"""
Construct an [`EnergyReservoirStorage`](@ref) without an explicit operational cost.

Uses a default [`StorageCost`](@ref) when `operation_cost` is `nothing`.
"""
function EnergyReservoirStorage(
    name::AbstractString,
    available::Bool,
    bus,
    prime_mover_type,
    storage_technology_type,
    storage_capacity,
    storage_level_limits,
    initial_storage_capacity_level,
    rating,
    active_power,
    input_active_power_limits,
    output_active_power_limits,
    efficiency,
    reactive_power,
    reactive_power_limits,
    base_power,
    ::Nothing,
    services = Device[],
    dynamic_injector = nothing,
    ext = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
)
    EnergyReservoirStorage(
        name,
        available,
        bus,
        prime_mover_type,
        storage_technology_type,
        storage_capacity,
        storage_level_limits,
        initial_storage_capacity_level,
        rating,
        active_power,
        input_active_power_limits,
        output_active_power_limits,
        efficiency,
        reactive_power,
        reactive_power_limits,
        base_power,
        StorageCost();
        services = services,
        dynamic_injector = dynamic_injector,
        ext = ext,
        internal = internal,
    )
end
