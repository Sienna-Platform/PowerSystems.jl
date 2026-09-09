
const SKIP_PM_VALIDATION = false

const SYSTEM_KWARGS = Set((
    :config_path,
    :frequency,
    :internal,
    :runchecks,
    :time_series_directory,
    :time_series_in_memory,
    :time_series_read_only,
    :enable_compression,
    :compression,
    :name,
    :description,
))

mutable struct SystemMetadata <: IS.InfrastructureSystemsType
    name::Union{Nothing, String}
    description::Union{Nothing, String}
    uuid::Base.UUID
end

SystemMetadata(name, description) = SystemMetadata(name, description, IS.make_uuid())

# The System UUID is an identity, so a system deserialized with assign_new_ids still
# compares equal to the original unless compare_ids is requested.
function IS.compare_values(
    match_fn::Union{Function, Nothing},
    x::SystemMetadata,
    y::SystemMetadata;
    compare_ids = false,
    exclude = Set{Symbol}(),
)
    match = true
    for name in fieldnames(SystemMetadata)
        name in exclude && continue
        name == :uuid && !compare_ids && continue
        val1 = getfield(x, name)
        val2 = getfield(y, name)
        if !_fetch_match_fn(match_fn)(val1, val2)
            @error "SystemMetadata field=$name does not match" val1 val2
            match = false
        end
    end
    return match
end

"""
A power system

`System` is the main data container in `PowerSystems.jl`, including basic metadata (base
power, frequency), components (network topology, loads, generators, and services), and
time series data.

```julia
System(base_power)
System(base_power, buses, components...)
System(base_power, buses, generators, loads, branches, storage, services; kwargs...)
System(base_power, buses, generators, loads; kwargs...)
System(file; kwargs...)  # file must be a JSON file
System(; kwargs...)
```

# Arguments
- `base_power::Float64`: the base power value for the system
- `buses::Vector{ACBus}`: an array of buses
- `components...`: Each element (e.g., `buses`, `generators`, ...) must be an iterable
    containing subtypes of `Component`.
- `file::AbstractString`: Path to a PowerSystems JSON file ending with .json

# Keyword arguments
- `name::String`: System name.
- `description::String`: System description.
- `frequency::Float64`: (default = 60.0) Operating frequency (Hz).
- `runchecks::Bool`: Run available checks on input fields and when add_component! is called.
  Throws InvalidValue if an error is found.
- `time_series_in_memory::Bool=false`: Store time series data in memory instead of on disk.
- `time_series_directory::Union{Nothing, String}`: Directory for the time series storage
    files. Defaults to the tmp file system.
- `time_series_read_only::Bool=false`: Open the time series store in read-only mode.
    This is useful for reading time series data without modifying it.
- `enable_compression::Bool=false`: Enable compression of time series data.
- `compression::CompressionSettings`: Allows customization of the compression settings.
- `config_path::String`: specify path to validation config file
- `internal::IS.InfrastructureSystemsInternal`: Internal structure for [`InfrastructureSystems.jl`](https://nrel-sienna.github.io/InfrastructureSystems.jl/stable/). This is used only during JSON de-seralization, do not pass it when building a `System` manually.

By default, time series data is stored on disk (as an HDF5 file with a sidecar SQLite
catalog) in the tmp file system to prevent large datasets from overwhelming system memory
(see [Data Storage](@ref)).
**If the system's time series data will be larger than the amount of tmp space available**, use the
`time_series_directory` parameter to change its location.
You can also override the location by setting the environment
variable `SIENNA_TIME_SERIES_DIRECTORY` to another directory.

Compression is not enabled by default, but you can enable
it with `enable_compression` to get significant storage savings at the cost of CPU time.
[`CompressionSettings`](@ref) can be used to customize the compression.

If you know that your dataset will fit in your computer's memory, then you can increase
performance by storing it in memory with `time_series_in_memory`.

# Examples
```julia
sys = System(100.0; name = "My Power System")
sys = System(100.0; name = "My Power System", description = "System corresponds to scenario A")
sys = System(path_to_my_json_file)
sys = System(100.0; enable_compression = true)
sys = System(100.0; compression = CompressionSettings(
    enabled = true,
    type = CompressionTypes.DEFLATE,
    level = 3,
    shuffle = true)
)
sys = System(100.0; time_series_in_memory = true)
```
"""
struct System <: IS.ComponentContainer
    data::IS.SystemData
    frequency::Float64 # [Hz]
    bus_numbers::Set{Int}
    runchecks::Base.RefValue{Bool}
    base_power::Float64
    time_series_directory::Union{Nothing, String}
    metadata::SystemMetadata
    internal::IS.InfrastructureSystemsInternal

    function System(
        data,
        base_power::Float64,
        internal::IS.InfrastructureSystemsInternal;
        runchecks = true,
        frequency = DEFAULT_SYSTEM_FREQUENCY,
        time_series_directory = nothing,
        name = nothing,
        description = nothing,
        uuid = IS.make_uuid(),
        kwargs...,
    )
        # Note to devs: if you add parameters to kwargs then consider whether they need
        # special handling in the deserialization function in this file.
        # See deserialize for System.

        # Implement a strict check here to make sure that SYSTEM_KWARGS can be used
        # elsewhere.
        unsupported = setdiff(keys(kwargs), SYSTEM_KWARGS)
        !isempty(unsupported) && error("Unsupported kwargs = $unsupported")
        bus_numbers = Set(get_number.(IS.get_components(ACBus, data)))
        return new(
            data,
            frequency,
            bus_numbers,
            Base.RefValue{Bool}(runchecks),
            base_power,
            time_series_directory,
            SystemMetadata(name, description, uuid),
            internal,
        )
    end
end

function System(data, base_power::Number, internal; kwargs...)
    return System(data, Float64(base_power), internal; kwargs...)
end

"""Construct an empty `System`. Useful for building a System while parsing raw data."""
function System(base_power::Number; kwargs...)
    return System(_create_system_data_from_kwargs(; kwargs...), base_power; kwargs...)
end

"""Construct a `System` from `InfrastructureSystems.SystemData`"""
function System(
    data,
    base_power::Number;
    internal = IS.InfrastructureSystemsInternal(),
    kwargs...,
)
    return System(data, base_power, internal; kwargs...)
end

"""
System constructor when components are constructed externally.
"""
function System(base_power::Float64, buses::Vector{ACBus}, components...; kwargs...)
    data = _create_system_data_from_kwargs(; kwargs...)
    sys = System(data, base_power; kwargs...)

    for bus in buses
        add_component!(sys, bus)
    end

    for component in Iterators.flatten(components)
        add_component!(sys, component)
    end

    if get(kwargs, :runchecks, true)
        check(sys)
    end

    return sys
end

"""Constructs a non-functional System for demo purposes."""
function System(
    ::Nothing;
    buses = [
        ACBus(;
            number = 0,
            name = "init",
            bustype = ACBusTypes.REF,
            available = true,
            angle = 0.0,
            magnitude = 0.0,
            voltage_limits = (min = 0.0, max = 0.0),
            base_voltage = nothing,
            area = nothing,
            load_zone = nothing,
            ext = Dict{String, Any}(),
        ),
    ],
    generators = [ThermalStandard(nothing), RenewableNonDispatch(nothing)],
    loads = [PowerLoad(nothing)],
    branches = nothing,
    storage = nothing,
    base_power::Float64 = 100.0,
    services = nothing,
    kwargs...,
)
    for component in Iterators.flatten((generators, loads))
        if get_name(component) == "init"
            set_bus!(component, first(buses))
        end
    end
    _services = isnothing(services) ? [] : services
    _branches = isnothing(branches) ? [] : branches
    _storage = isnothing(storage) ? [] : storage
    return System(
        base_power,
        buses,
        generators,
        loads,
        _branches,
        _storage,
        _services;
        kwargs...,
    )
end

"""
`System(::AbstractString)` no longer constructs a System — it always errors, pointing at the
supported alternative. Use [`from_file`](@ref) to read a serialized `System` bundle/archive, or
PowerSystems.jl's `PowerFlowFileParser.jl` companion package to parse a Matpower/PSSE file.
"""
function System(file_path::AbstractString; kwargs...)
    ext = lowercase(splitext(file_path)[2])
    if ext == ".json"
        throw(
            DataFormatError(
                "System($(repr(file_path))) no longer deserializes a system. The old " *
                "single-file native JSON format has no reader anymore. from_file reads a " *
                "bundle directory or a $SIENNA_ARCHIVE_EXTENSION archive written by to_file — " *
                "a single .json path is neither. A system serialized in the old format must " *
                "be rebuilt from source and re-serialized with the current to_file.",
            ),
        )
    elseif ext in (".raw", ".m")
        throw(
            DataFormatError(
                "PowerSystems.jl no longer parses $ext files. Use PowerFlowFileParser.jl to " *
                "parse this file into a System.",
            ),
        )
    else
        throw(
            DataFormatError(
                "$(repr(file_path)) is not a supported way to construct a System. Use " *
                "from_file for a serialized bundle/archive, or PowerFlowFileParser.jl for a " *
                "Matpower/PSSE file.",
            ),
        )
    end
end

"""
Construct a System from a subsystem of an existing system.

# Arguments
- `sys::System`: the base system from which the subsystems are derived
- `subsystem::String`: the name of the subsystem to extract from the original system

# Keyword arguments
- `runchecks::Bool`: (default = true) whether to run system validation checks.
"""
function from_subsystem(sys::System, subsystem::AbstractString; runchecks = true)
    if !in(subsystem, get_subsystems(sys))
        error("subsystem = $subsystem is not stored")
    end

    # It would be faster to create an empty system and then populate it with deep copies of
    # each component in the subsystem. That is not implemented because
    # 1. The performance loss should not be too large.
    # 2. We haven't yet implemented deepcopy(Component).
    # 3. There is extra code complexity in adding copied components in the correct order
    #    as well as copying time series data.
    new_sys = deepcopy(sys)
    filter_components_by_subsystem!(new_sys, subsystem; runchecks = runchecks)

    # Regenerate both identities so the derived system does not alias the filtered one.
    assign_new_uuid!(new_sys)
    for component in get_components(Component, new_sys)
        IS.assign_new_id!(new_sys, component)
    end

    return new_sys
end

"""
Filter out all components that are not part of the subsystem.
"""
function filter_components_by_subsystem!(
    sys::System,
    subsystem::AbstractString;
    runchecks = true,
)
    component_ids = get_component_ids(sys, subsystem)
    for component in get_components(Component, sys)
        if !in(IS.get_id(component), component_ids)
            remove_component!(sys, component)
        end
    end

    for component in IS.get_masked_components(Component, sys.data)
        if !in(IS.get_id(component), component_ids)
            IS.remove_masked_component!(sys.data, component)
        end
    end

    if runchecks
        check(sys)
        check_components(sys)
    end
end

"""
Return the internal of the system
"""
IS.get_internal(sys::System) = sys.internal

"""
Return a user-modifiable dictionary to store extra information.
"""
get_ext(sys::System) = IS.get_ext(sys.internal)

"""
Unitless system base power (MVA) — internal anchor for unit conversion.
"""
_get_base_power(sys::System) = sys.base_power

"""
Return the system's base power as a bare `Float64` in natural units (MVA).

Like the component accessor, `base_power` is always natural units: an optional
units argument must be `NU` or a power-dimensioned `Unitful` unit (e.g. `MW`,
`MVA`). Per-unit bases (`SU`, `DU`) and non-power units error. For the
unit-bearing value see [`get_base_power_unitful`](@ref).
"""
get_base_power(sys::System) = _get_base_power(sys)
get_base_power(sys::System, u) = IS._strip_units(get_base_power_unitful(sys, u))

"""
Return the system's base power as a unit-bearing quantity. See
[`get_base_power`](@ref) for a bare number.
"""
get_base_power_unitful(sys::System) = _get_base_power(sys) * MVA
get_base_power_unitful(sys::System, ::NaturalUnit) = _get_base_power(sys) * MVA
get_base_power_unitful(sys::System, u::Unitful.Units) =
    Unitful.uconvert(u, _get_base_power(sys) * MVA)
get_base_power_unitful(sys::System, u::AbstractRelativeUnit) =
    _base_power_units_error(u)

"""
Return the system's frequency.
"""
get_frequency(sys::System) = sys.frequency

"""
Clear any value stored in ext.
"""
clear_ext!(sys::System) = IS.clear_ext!(sys.internal)

"""
Return true if checks are enabled on the system.
"""
get_runchecks(sys::System) = sys.runchecks[]

"""
Enable or disable system checks.
Applies to component addition as well as overall system consistency.
"""
function set_runchecks!(sys::System, value::Bool)
    sys.runchecks[] = value
    @info "Set runchecks to $value"
end

function set_units_setting!(
    component::Component,
    value::Union{Float64, Nothing},
)
    IS.set_base_value!(component, value)
    return
end

function has_units_setting(component::T) where {T <: Component}
    return !isnothing(IS.get_base_value(component))
end

"""
Set the name of the system.
"""
set_name!(sys::System, name::AbstractString) = sys.metadata.name = name

"""
Get the name of the system.
"""
get_name(sys::System) = sys.metadata.name

"""
Get the UUID of the system. Unlike components and supplemental attributes (which are
identified by an integer id), the `System` retains a UUID for identity.
"""
get_system_uuid(sys::System) = sys.metadata.uuid

"""
Assign a new UUID to the system's identity.
"""
function assign_new_uuid!(sys::System)
    sys.metadata.uuid = IS.make_uuid()
    return
end

"""
Set the description of the system.
"""
set_description!(sys::System, description::AbstractString) =
    sys.metadata.description = description

"""
Get the description of the system.
"""
get_description(sys::System) = sys.metadata.description

"""
Add a component to the system.

A component cannot be added to more than one `System`.
Throws ArgumentError if the component's name is already stored for its concrete type.
Throws ArgumentError if any Component-specific rule is violated.
Throws InvalidValue if any of the component's field values are outside of defined valid
range.

# Examples
```julia
sys = System(100.0)

# Add a single component.
add_component!(sys, bus)

# Add many at once.
buses = [bus1, bus2, bus3]
generators = [gen1, gen2, gen3]
foreach(x -> add_component!(sys, x), Iterators.flatten((buses, generators)))
```

See also [`add_components!`](@ref).
"""
function add_component!(
    sys::System,
    component::T;
    skip_validation = false,
    kwargs...,
) where {T <: Component}
    set_units_setting!(component, sys.base_power)
    _sync_base_power!(base_power_kind(component), component, sys.base_power)

    check_topology(sys, component)
    check_component_addition(sys, component; kwargs...)

    deserialization_in_progress = _is_deserialization_in_progress(sys)
    if !deserialization_in_progress
        # Services are attached to devices at deserialization time.
        check_for_services_on_addition(sys, component)
    end

    skip_validation = _validate_or_skip!(sys, component, skip_validation)
    _kwargs = Dict(k => v for (k, v) in kwargs if k !== :static_injector)
    IS.add_component!(
        sys.data,
        component;
        allow_existing_time_series = deserialization_in_progress,
        skip_validation = skip_validation,
        _kwargs...,
    )

    if !deserialization_in_progress
        # Whatever this may change should have been validated above in
        # check_component_addition, so this should not fail.
        # Doesn't run at deserialization time because the changes made by this function
        # occurred when the original addition ran and do not apply to that scenario.
        handle_component_addition!(sys, component; kwargs...)
        # Special condition required to populate the bus numbers in the system after
    elseif component isa Bus
        handle_component_addition!(sys, component; kwargs...)
    end

    return
end

"""
Add many components to the system at once.

A component cannot be added to more than one `System`.
Throws ArgumentError if the component's name is already stored for its concrete type.
Throws ArgumentError if any Component-specific rule is violated.
Throws InvalidValue if any of the component's field values are outside of defined valid
range.

# Examples
```julia
sys = System(100.0)

buses = [bus1, bus2, bus3]
generators = [gen1, gen2, gen3]
add_components!(sys, Iterators.flatten((buses, generators))
```
"""
function add_components!(sys::System, components)
    foreach(x -> add_component!(sys, x), components)
    return
end

"""
Add a dynamic injector to the system.

A component cannot be added to more than one `System`.
Throws ArgumentError if the name does not match the `static_injector` name.
Throws ArgumentError if the `static_injector` is not attached to the system.

All rules for the generic `add_component!` method also apply.
"""
function add_component!(
    sys::System,
    dyn_injector::DynamicInjection,
    static_injector::StaticInjection;
    kwargs...,
)
    add_component!(sys, dyn_injector; static_injector = static_injector, kwargs...)
    return
end

"""
Replace the dynamic injector in a static component.

Safely removes the old dynamic injector from the system if no other component references it.
If another component references the old dynamic injector, it is kept in the system and an
info message is logged.

Throws ArgumentError if the static injector is not attached to the system.
Throws ArgumentError if the static injector does not have a dynamic injector.
Throws ArgumentError if the new dynamic injector name does not match the static injector name.
"""
function replace_dynamic_injector!(
    sys::System,
    static_injector::StaticInjection,
    new_dynamic_injector::DynamicInjection,
)
    throw_if_not_attached(static_injector, sys)

    old_dynamic_injector = get_dynamic_injector(static_injector)
    if isnothing(old_dynamic_injector)
        throw(
            ArgumentError(
                "$(get_name(static_injector)) does not have a dynamic injector to replace",
            ),
        )
    end

    if get_name(new_dynamic_injector) != get_name(static_injector)
        throw(
            ArgumentError(
                "new_dynamic_injector must have the same name as the static_injector",
            ),
        )
    end

    # Unlink old dynamic injector from this static component
    set_dynamic_injector!(static_injector, nothing)

    # Check if any other static injector in the system references the old dynamic injector
    is_referenced_elsewhere = false
    for si in get_components(StaticInjection, sys)
        si === static_injector && continue
        dyn = get_dynamic_injector(si)
        if dyn === old_dynamic_injector
            is_referenced_elsewhere = true
            break
        end
    end

    if is_referenced_elsewhere
        @info "The dynamic injector $(get_name(old_dynamic_injector)) is referenced by " *
              "another component and will not be removed from the system."
    else
        # Safely remove old dynamic injector from the system
        _handle_component_removal_common!(old_dynamic_injector)
        IS.remove_component!(sys.data, old_dynamic_injector)
    end

    # Add the new dynamic injector, linked to the static component
    add_component!(sys, new_dynamic_injector, static_injector)

    return
end

function _add_service!(
    sys::System,
    service::Service,
    contributing_devices;
    skip_validation = false,
    kwargs...,
)
    skip_validation = _validate_or_skip!(sys, service, skip_validation)
    for device in contributing_devices
        device_type = typeof(device)
        if !(device_type <: Device)
            throw(ArgumentError("contributing_devices must be of type Device"))
        end
        throw_if_not_attached(device, sys)
    end

    set_units_setting!(service, sys.base_power)
    # Since this isn't atomic, order is important. Add to system before adding to devices.
    IS.add_component!(sys.data, service; skip_validation = skip_validation, kwargs...)

    for device in contributing_devices
        add_service_internal!(device, service)
    end
end

function _validate_types_for_interface(sys::System, contributing_devices)
    device_types = Set{DataType}()
    for device in contributing_devices
        device_type = typeof(device)
        if !(device_type <: Branch)
            throw(ArgumentError("contributing_devices must be of type Branch"))
        end
        push!(device_types, device_type)
        throw_if_not_attached(device, sys)
    end
    if length(device_types) > 1 && AreaInterchange in device_types
        throw(
            ArgumentError(
                "contributing_devices can't mix AreaInterchange with other Branch types",
            ),
        )
    end
    return
end

function _validate_types_for_agc(contributing_devices)
    for device in contributing_devices
        device_type = typeof(device)
        if !(device_type <: Reserve)
            throw(ArgumentError("contributing_devices of AGC must be of type Reserve"))
        end
    end
    return
end

function _add_service!(
    sys::System,
    service::TransmissionInterface,
    contributing_devices;
    skip_validation = false,
    kwargs...,
)
    skip_validation = _validate_or_skip!(sys, service, skip_validation)
    _validate_types_for_interface(sys, contributing_devices)
    set_units_setting!(service, sys.base_power)
    # Since this isn't atomic, order is important. Add to system before adding to devices.
    IS.add_component!(sys.data, service; skip_validation = skip_validation, kwargs...)

    for device in contributing_devices
        add_service_internal!(device, service)
    end
end

function _add_service!(
    sys::System,
    service::AGC,
    contributing_devices;
    skip_validation = false,
    kwargs...,
)
    skip_validation = _validate_or_skip!(sys, service, skip_validation)
    _validate_types_for_agc(contributing_devices)
    set_units_setting!(service, sys.base_power)
    # Since this isn't atomic, order is important. Add to system before adding to devices.
    IS.add_component!(sys.data, service; skip_validation = skip_validation, kwargs...)

    for device in contributing_devices
        add_service_internal!(service, device)
    end
end

"""
Similar to [`add_component!`](@ref) but for services.

# Arguments
- `sys::System`: system
- `service::Service`: service to add
- `contributing_devices`: Must be an iterable of type Device
"""
function add_service!(sys::System, service::Service, contributing_devices; kwargs...)
    _add_service!(sys, service, contributing_devices; kwargs...)
    return
end

"""
Similar to [`add_component!`](@ref) but for services.

# Arguments
- `sys::System`: system
- `service::Service`: service to add
- `contributing_device::Device`: Valid Device
"""
function add_service!(sys::System, service::Service, contributing_device::Device; kwargs...)
    _add_service!(sys, service, [contributing_device]; kwargs...)
    return
end

"""
Similar to [`add_service!`](@ref) but for Service and Device already stored in the system.
Performs validation checks on the device and the system

# Arguments
- `device::Device`: Device
- `service::Service`: Service
- `sys::System`: system
"""
function add_service!(device::Device, service::Service, sys::System)
    throw_if_not_attached(service, sys)
    throw_if_not_attached(device, sys)
    add_service_internal!(device, service)
    return
end

_reject_hub_addition(::Nothing, vp::VirtualParticipant) = nothing

function _reject_hub_addition(settlement_point::Topology, vp::VirtualParticipant)
    throw(
        ArgumentError(
            "$(get_name(vp)) cannot set both settlement_point " *
            "($(get_name(settlement_point))) and trading_hubs; choose one location mode",
        ),
    )
end

"""
Associate `hub` with `vp`. Both must already be attached to `sys`.
"""
function add_trading_hub!(sys::System, vp::VirtualParticipant, hub::TradingHub)
    throw_if_not_attached(vp, sys)
    throw_if_not_attached(hub, sys)
    _reject_hub_addition(get_settlement_point(vp), vp)
    add_trading_hub_internal!(vp, hub)
    return
end

"""
Return the `VirtualParticipant`s in `sys` associated with `hub`.
"""
function get_contributing_virtuals(sys::System, hub::TradingHub)
    return [
        vp for vp in get_components(VirtualParticipant, sys) if has_trading_hub(vp, hub)
    ]
end

"""
Similar to [`add_component!`](@ref) but for GroupReserve.

# Arguments
- `sys::System`: system
- `service::GroupReserve`: service to add
"""
function add_service!(
    sys::System,
    service::GroupReserve;
    skip_validation = false,
    kwargs...,
)
    skip_validation = _validate_or_skip!(sys, service, skip_validation)

    for _service in get_contributing_services(service)
        throw_if_not_attached(_service, sys)
    end

    set_units_setting!(service, sys.base_power)
    IS.add_component!(sys.data, service; skip_validation = skip_validation, kwargs...)
    return
end

"""Set GroupReserve contributing_services with check"""
function set_contributing_services!(
    sys::System,
    service::GroupReserve,
    val::Vector{<:Service},
)
    for _service in val
        throw_if_not_attached(_service, sys)
    end
    service.contributing_services = val
    return
end

"""
Similar to [`add_component!`](@ref) but for GroupReserve.

# Arguments
- `sys::System`: system
- `service::GroupReserve`: service to add
- `contributing_services`: contributing services to the group
"""
function add_service!(
    sys::System,
    service::GroupReserve,
    contributing_services::Vector{<:Service};
    skip_validation = false,
    kwargs...,
)
    skip_validation = _validate_or_skip!(sys, service, skip_validation)
    set_contributing_services!(sys, service, contributing_services)

    set_units_setting!(service, sys.base_power)
    IS.add_component!(sys.data, service; skip_validation = skip_validation, kwargs...)
    return
end

"""
Open a batch of time series work and run `func` on it, inside a store transaction.

Call `add_time_series!` on the yielded transaction and the additions are buffered and
written as one bulk call, which is much faster than adding them one at a time.

The block is also a transaction. If it throws, everything it did is rolled back —
including removals, which are irreversible outside a block. Blocks nest
innermost-first.

An open block holds the store's write lock, so gather your data first and keep the
block to the writes.

# Examples
```julia
# Assume there is a system with an array of Components and SingleTimeSeries
# stored in the variables components and single_time_series, respectively
time_series_transaction(sys) do txn
    for (component, ts) in zip(components, single_time_series)
        add_time_series!(txn, component, ts)
    end
end
```
"""
function time_series_transaction(func::Function, sys::System; kwargs...)
    return IS.time_series_transaction(func, sys.data; kwargs...)
end

"""
Iterates over all components.

# Examples
```julia
for component in iterate_components(sys)
    @show component
end
```

See also: [`get_components`](@ref)
"""
function iterate_components(sys::System)
    return IS.iterate_components(sys.data)
end

"""
Remove all components from the system.
"""
function clear_components!(sys::System)
    return IS.clear_components!(sys.data)
end

"""
Remove all components of type T from the system.

Throws ArgumentError if the type is not stored.
"""
# the argument order in this function is un-julian and should be deprecated in 2.0
function remove_components!(::Type{T}, sys::System) where {T <: Component}
    return remove_components!(sys, T)
end

"""
Remove all components of type `T` from the system.

Throws `ArgumentError` if the type is not stored.
"""
function remove_components!(sys::System, ::Type{T}) where {T <: Component}
    components = IS.remove_components!(T, sys.data)
    for component in components
        handle_component_removal!(sys, component)
    end
    return components
end

"""
Remove all components of type `T` that match `filter_func` from the system.
"""
function remove_components!(
    filter_func::Function,
    sys::System,
    ::Type{T},
) where {T <: Component}
    components = collect(get_components(filter_func, T, sys))
    for component in components
        remove_component!(sys, component)
    end
    return components
end

"""
Set the name for a component that is attached to the system.
"""
set_name!(sys::System, component::Component, name::AbstractString) =
    set_name!(sys.data, component, name)

"""
Set the name of a component.

Throws an exception if the component is attached to a system.
"""
function set_name!(component::Component, name::AbstractString)
    # The units setting is nothing until the component is attached to the system.
    if has_units_setting(component)
        # This is not allowed because components are stored in the system in a Dict
        # keyed by name.
        error(
            "The component is attached to a system. " *
            "Call set_name!(system, component, name) instead.",
        )
    end

    component.name = name
end

function clear_units!(component::Component)
    set_units_setting!(component, nothing)
    return
end

"""
Remove a component from the system by its value.

Throws ArgumentError if the component is not stored.
"""
function remove_component!(sys::System, component::T) where {T <: Component}
    check_component_removal(sys, component)
    IS.remove_component!(sys.data, component)
    handle_component_removal!(sys, component)
    return
end

"""
Throws ArgumentError if a PowerSystems rule blocks removal from the system.
"""
function check_component_removal(sys::System, service::Service)
    groupservices = get_components(GroupReserve, sys)
    for groupservice in groupservices
        if service ∈ get_contributing_services(groupservice)
            throw(
                ArgumentError(
                    "service $(get_name(service)) cannot be removed with an attached GroupReserve",
                ),
            )
        end
    end
    return
end

function check_component_removal(sys::System, service::GroupReserve)
    return
end

"""
Remove a component from the system by its name.

Throws ArgumentError if the component is not stored.
"""
function remove_component!(
    ::Type{T},
    sys::System,
    name::AbstractString,
) where {T <: Component}
    component = IS.remove_component!(T, sys.data, name)
    handle_component_removal!(sys, component)
    return
end

"""
Check to see if the component of type T exists.
"""
function has_components(sys::System, T::Type{<:Component})
    return IS.has_components(sys.data.components, T)
end

"""
Check to see if the component of type T with name exists.
"""
function has_component(sys::System, T::Type{<:Component}, name::AbstractString)
    return IS.has_component(sys.data, T, name)
end

has_component(T::Type{<:Component}, sys::System, name::AbstractString) =
    has_component(sys, T, name)

"""
Get the component of type T with name. Returns nothing if no component matches. If T is an abstract
type then the names of components across all subtypes of T must be unique.

See [`get_components_by_name`](@ref) for abstract types with non-unique names across subtypes.

Throws ArgumentError if T is not a concrete type and there is more than one component with
    requested name
"""
function IS.get_component(
    ::Type{T},
    sys::System,
    name::AbstractString,
) where {T <: Component}
    return IS.get_component(T, sys.data, name)
end

"""
Return an iterator of components of a given `Type` from a [`System`](@ref).

`T` can be a concrete or abstract [`Component`](@ref) type from the [Type Tree](@ref).
Call collect on the result if an array is desired.

# Examples
```julia
iter = get_components(ThermalStandard, sys)
iter = get_components(Generator, sys)
generators = collect(get_components(Generator, sys))
```

See also: [`iterate_components`](@ref), [`get_components` with a filter](@ref get_components(
    filter_func::Function,
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
) where {T <: Component}),
[`get_available_components`](@ref), [`get_buses`](@ref)
"""
function IS.get_components(
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
) where {T <: Component}
    return IS.get_components(T, sys.data; subsystem_name = subsystem_name)
end

function IS.get_components(
    filter_func::Function,
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
) where {T <: Component}
    return IS.get_components(filter_func, T, sys.data; subsystem_name = subsystem_name)
end

"""
Get the component by integer id.
"""
IS.get_component(sys::System, id::Int) = IS.get_component(sys.data, id)

"""
Assign a new id to a component, updating every reference to its old one.
"""
IS.assign_new_id!(sys::System, x::Component) = IS.assign_new_id!(sys.data, x)

function _get_components_by_name(abstract_types, data::IS.SystemData, name::AbstractString)
    _components = []
    for subtype in abstract_types
        component = IS.get_component(subtype, data, name)
        if !isnothing(component)
            push!(_components, component)
        end
    end

    return _components
end

"""
Get the components of abstract type T with name. Note that PowerSystems enforces unique
names on each concrete type but not across concrete types.

See [`get_component`](@ref) if the concrete type is known.

Throws ArgumentError if T is not an abstract type.
"""
function get_components_by_name(
    ::Type{T},
    sys::System,
    name::AbstractString,
) where {T <: Component}
    return IS.get_components_by_name(T, sys.data, name)
end

"""
Return true if the component is attached to the system.
"""
function is_attached(component::T, sys::System) where {T <: Component}
    existing_component = get_component(T, sys, get_name(component))
    isnothing(existing_component) && return false
    return component === existing_component
end

"""
Throws ArgumentError if the component is not attached to the system.
"""
function throw_if_not_attached(component::Component, sys::System)
    if !is_attached(component, sys)
        throw(ArgumentError("$(summary(component)) is not attached to the system"))
    end
end

"""
Return a vector of devices contributing to the service.
"""
function get_contributing_devices(sys::System, service::T) where {T <: Service}
    throw_if_not_attached(service, sys)
    return [
        x for x in get_components(supports_services, Device, sys) if has_service(x, service)
    ]
end

"""
Return a vector of devices contributing to the service.
"""
function get_contributing_devices(sys::System, service::TransmissionInterface)
    throw_if_not_attached(service, sys)
    return [x for x in get_components(Branch, sys) if has_service(x, service)]
end

"""
Container associating a [`Service`](@ref) with the [`Device`](@ref) components that
contribute to it.
"""
struct ServiceContributingDevices
    service::Service
    contributing_devices::Vector{Device}
end

const ServiceContributingDevicesKey = NamedTuple{(:type, :name), Tuple{DataType, String}}
const ServiceContributingDevicesMapping =
    Dict{ServiceContributingDevicesKey, ServiceContributingDevices}

struct AGCContributingReserves
    agc::AGC
    contributing_reserves::Vector{Reserve}
end

const AGCContributingReservesKey = NamedTuple{(:type, :name), Tuple{DataType, String}}
const AGCContributingReservesMapping =
    Dict{AGCContributingReservesKey, AGCContributingReserves}

"""
Returns a ServiceContributingDevices object.
"""
function _get_contributing_devices(sys::System, service::T) where {T <: Service}
    id = IS.get_id(service)
    devices = ServiceContributingDevices(service, Vector{Device}())
    for device in get_components(Device, sys)
        if supports_services(device)
            for _service in get_services(device)
                if IS.get_id(_service) == id
                    push!(devices.contributing_devices, device)
                    break
                end
            end
        end
    end
    return devices
end

"""
Returns a ServiceContributingDevices object.
"""
function _get_contributing_devices(sys::System, service::TransmissionInterface)
    id = IS.get_id(service)
    devices = ServiceContributingDevices(service, Vector{Device}())
    for device in get_components(Branch, sys)
        if supports_services(device)
            for _service in get_services(device)
                if IS.get_id(_service) == id
                    push!(devices.contributing_devices, device)
                    break
                end
            end
        end
    end
    return devices
end

"""
Return an instance of AGCContributingReservesMapping.
"""
function get_contributing_reserve_mapping(sys::System)
    agcs = AGCContributingReservesMapping()
    for agc in get_components(AGC, sys)
        key = AGCContributingReservesKey((typeof(agc), get_name(agc)))
        agcs[key] = AGCContributingReserves(agc, get_reserves(agc))
    end
    return agcs
end

"""
Return an instance of ServiceContributingDevicesMapping.
"""
function get_contributing_device_mapping(sys::System)
    services = ServiceContributingDevicesMapping()
    for service in get_components(Service, sys)
        key = ServiceContributingDevicesKey((typeof(service), get_name(service)))
        services[key] = _get_contributing_devices(sys, service)
    end

    return services
end

"""
Return a vector of connected head reservoirs to the turbine. Reservoirs that have the turbine in their downstream_turbines field are head reservoirs of such turbine.
"""
function get_connected_head_reservoirs(sys::System, turbine::T) where {T <: HydroUnit}
    throw_if_not_attached(turbine, sys)
    return [
        x for x in get_components(HydroReservoir, sys) if has_downstream_turbine(x, turbine)
    ]
end

"""
Return a vector of connected tail reservoirs to the turbine. Reservoirs that have the turbine in their upstream_turbines field are tail reservoirs of such turbine.
"""
function get_connected_tail_reservoirs(sys::System, turbine::T) where {T <: HydroUnit}
    throw_if_not_attached(turbine, sys)
    return [
        x for x in get_components(HydroReservoir, sys) if has_upstream_turbine(x, turbine)
    ]
end

"""
Container associating a hydro turbine with its connected [`Device`](@ref) components
(e.g., [`HydroReservoir`](@ref) units).
"""
struct TurbineConnectedDevices
    turbine::HydroUnit
    connected_devices::Vector{Device}
end

const TurbineConnectedDevicesKey = NamedTuple{(:type, :name), Tuple{DataType, String}}
const TurbineConnectedDevicesMapping =
    Dict{TurbineConnectedDevicesKey, TurbineConnectedDevices}

"""
Returns a TurbineConnectedDevices object.
"""
function _get_connected_head_devices(sys::System, turbine::T) where {T <: HydroUnit}
    id = IS.get_id(turbine)
    devices = TurbineConnectedDevices(turbine, Vector{Device}())
    for device in get_components(HydroReservoir, sys)
        # Only add reservoirs that have the turbine in their downstream_turbines field
        # That is, those reservoirs are a head reservoir to that turbine
        for _turbine in get_downstream_turbines(device)
            if IS.get_id(_turbine) == id
                push!(devices.connected_devices, device)
                break
            end
        end
    end
    return devices
end

"""
Returns a TurbineConnectedDevices object.
"""
function _get_connected_tail_devices(sys::System, turbine::T) where {T <: HydroUnit}
    id = IS.get_id(turbine)
    devices = TurbineConnectedDevices(turbine, Vector{Device}())
    for device in get_components(HydroReservoir, sys)
        # Only add reservoirs that have the turbine in their upstream_turbines field
        # That is, those reservoirs are a tail reservoir to that turbine
        for _turbine in get_upstream_turbines(device)
            if IS.get_id(_turbine) == id
                push!(devices.connected_devices, device)
                break
            end
        end
    end
    return devices
end

"""
Return an instance of TurbineConnectedDevicesMapping.
"""
function get_turbine_head_reservoirs_mapping(sys::System)
    turbine_mapping = TurbineConnectedDevicesMapping()
    for turbine in get_components(HydroUnit, sys)
        key = TurbineConnectedDevicesKey((typeof(HydroUnit), get_name(turbine)))
        turbine_mapping[key] = _get_connected_head_devices(sys, turbine)
    end

    return turbine_mapping
end

"""
Return an instance of TurbineConnectedDevicesMapping.
"""
function get_turbine_tail_reservoirs_mapping(sys::System)
    turbine_mapping = TurbineConnectedDevicesMapping()
    for turbine in get_components(HydroUnit, sys)
        key = TurbineConnectedDevicesKey((typeof(HydroUnit), get_name(turbine)))
        turbine_mapping[key] = _get_connected_tail_devices(sys, turbine)
    end

    return turbine_mapping
end

"""
Return a vector of components with buses in the [`AggregationTopology`](@ref).
"""
function get_components_in_aggregation_topology(
    ::Type{T},
    sys::System,
    aggregator::AggregationTopology,
) where {T <: StaticInjection}
    buses = Set{String}((get_name(x) for x in get_buses(sys, aggregator)))
    components = Vector{T}()
    for component in get_components(T, sys)
        bus = get_bus(component)
        bus_name = get_name(bus)
        if bus_name in buses
            push!(components, component)
        end
    end

    return components
end

"Return whether the given component's bus is in the [`AggregationTopology`](@ref)"
function is_component_in_aggregation_topology(
    comp::Component,
    aggregator::T,
) where {T <: AggregationTopology}
    accessor = get_aggregation_topology_accessor(T)
    return IS.get_id(accessor(get_bus(comp))) == IS.get_id(aggregator)
end

"""
Return a mapping of [`AggregationTopology`](@ref) name to vector of [`ACBus`](@ref)es within it.
"""
function get_aggregation_topology_mapping(
    ::Type{T},
    sys::System,
) where {T <: AggregationTopology}
    mapping = Dict{String, Vector{ACBus}}()
    accessor_func = get_aggregation_topology_accessor(T)
    for bus in get_components(ACBus, sys)
        aggregator = accessor_func(bus)
        name = get_name(aggregator)
        buses = get(mapping, name, nothing)
        if isnothing(buses)
            mapping[name] = Vector{ACBus}([bus])
        else
            push!(buses, bus)
        end
    end

    return mapping
end

"""
Return a vector of buses contained within an [`AggregationTopology`](@ref).

# Examples
```julia
area = get_component(Area, system, "my_area"); # Get an Area named my_area
area_buses = get_buses(system, area)
```
"""
function get_buses(sys::System, aggregator::AggregationTopology)
    return _get_buses(sys.data, aggregator)
end

function _get_buses(data::IS.SystemData, aggregator::T) where {T <: AggregationTopology}
    accessor_func = get_aggregation_topology_accessor(T)
    buses = Vector{ACBus}()
    for bus in IS.get_components(ACBus, data)
        _aggregator = accessor_func(bus)
        if !isnothing(_aggregator) && IS.get_id(_aggregator) == IS.get_id(aggregator)
            push!(buses, bus)
        end
    end

    return buses
end

"""
Add time series data to a component. Assign optional features to differentiate time series
of the same type with the same name but with different data.

Returns a key that can later be used to retrieve the time series data.

Throws ArgumentError if the component is not stored in the system.

# Examples
```julia
ts1 = Deterministic(
    name = "max_active_power",
    data = deterministic_data,
    resolution = Dates.Hour(1),
)
ts2 = SingleTimeSeries(
    name = "max_active_power",
    data = time_array_1,
)
ts3 = SingleTimeSeries(
    name = "max_active_power",
    data = time_array_2,
)
key1 = add_time_series!(system, component, ts1)
key2 = add_time_series!(system, component, ts2; features = Dict("scenario" => "high"))
key3 = add_time_series!(system, component, ts3; features = Dict("scenario" => "low"))
ts1_b = get_time_series(component, key1)
ts2_b = get_time_series(component, key2)
ts3_b = get_time_series(component, key3)
```
"""
function add_time_series!(
    sys::System,
    component::Component,
    time_series::TimeSeriesData;
    features::Union{Nothing, Dict} = nothing,
)
    return IS.add_time_series!(sys.data, component, time_series; features = features)
end

"""
Add time series data to a supplemental attribute. Mirrors the `Component` method above;
see [`remove_time_series!`](@ref) for the existing precedent of a supplemental attribute
owner on the time series API. The attribute must already be attached to `sys` via
[`add_supplemental_attribute!`](@ref).

Throws ArgumentError if the attribute is not stored in the system.
"""
function add_time_series!(
    sys::System,
    attribute::SupplementalAttribute,
    time_series::TimeSeriesData;
    features::Union{Nothing, Dict} = nothing,
)
    return IS.add_time_series!(sys.data, attribute, time_series; features = features)
end

"""
Add the same time series data to multiple components.

This function stores a single copy of the data. Each component will store a reference to
that data. This is significantly more efficent than calling `add_time_series!` for each
component individually with the same data because in this case, only one time series
array is stored. Each component gets its own association, so this returns a `Vector` of
keys, one per component, in the order of `components`.

Throws ArgumentError if a component is not stored in the system.
"""
function add_time_series!(
    sys::System,
    components,
    time_series::TimeSeriesData;
    features::Union{Nothing, Dict} = nothing,
)
    return IS.add_time_series!(sys.data, components, time_series; features = features)
end

#=
# TODO 1.0: do we need this functionality? not currently present in IS
"""
Return a vector of time series data from a metadata file.

# Arguments
- `data::SystemData`: system
- `metadata_file::AbstractString`: path to metadata file
- `resolution::{Nothing, Dates.Period}`: skip data that doesn't match this resolution

See InfrastructureSystems.TimeSeriesFileMetadata for description of what the file
should contain.
"""
function make_time_series(sys::System, metadata_file::AbstractString; resolution = nothing)
    return IS.make_time_series(
        sys.data,
        metadata_file,
        PowerSystems;
        resolution = resolution,
    )
end

"""
Return a vector of time series data from a vector of TimeSeriesFileMetadata values.

# Arguments
- `data::SystemData`: system
- `timeseries_metadata::Vector{TimeSeriesFileMetadata}`: metadata values
- `resolution::{Nothing, Dates.Period}`: skip data that doesn't match this resolution
"""
function make_time_series(
    sys::System,
    metadata::Vector{IS.TimeSeriesFileMetadata};
    resolution = nothing,
)
    return IS.make_time_series!(sys.data, metadata; resolution = resolution)
end
=#

"""
Return the compression settings used for system data such as time series arrays.
"""
get_compression_settings(sys::System) = IS.get_compression_settings(sys.data)

"""
Return the initial times for all forecasts. Use `resolution` and/or `interval` keyword
arguments to filter when multiple forecast groups exist.
"""
get_forecast_initial_times(sys::System; kwargs...) =
    IS.get_forecast_initial_times(sys.data; kwargs...)

"""
Return the window count for all forecasts. Use `resolution` and/or `interval` keyword
arguments to filter when multiple forecast groups exist.
"""
get_forecast_window_count(sys::System; kwargs...) =
    IS.get_forecast_window_count(sys.data; kwargs...)

"""
Return the horizon for all forecasts. Use `resolution` and/or `interval` keyword
arguments to filter when multiple forecast groups exist.
"""
get_forecast_horizon(sys::System; kwargs...) =
    IS.get_forecast_horizon(sys.data; kwargs...)

"""
Return the initial timestamp for all forecasts. Use `resolution` and/or `interval` keyword
arguments to filter when multiple forecast groups exist.
"""
get_forecast_initial_timestamp(sys::System; kwargs...) =
    IS.get_forecast_initial_timestamp(sys.data; kwargs...)

"""
Return the forecast interval. Use `resolution` and/or `interval` keyword arguments to
select which forecast group to query when multiple exist.
"""
get_forecast_interval(sys::System; kwargs...) =
    IS.get_forecast_interval(sys.data; kwargs...)

"""
Build a `ForecastReader` over every forecast in the system of `time_series_type`.
`resolution` is required and pins the reader to one forecast resolution; `name` and
`features` further narrow the match.

Drive the reader with `read_forecast_window!` and read each entry with
`get_forecast_window`. Forecasts that share an underlying array are read from storage
once per timestamp regardless of how many components reference them — see
[`get_time_series_array_groups`](@ref).
"""
build_forecast_reader(
    sys::System,
    ::Type{T};
    resolution::Dates.Period,
    name::Union{Nothing, AbstractString} = nothing,
    features::Union{Nothing, Dict} = nothing,
) where {T <: Forecast} =
    IS.build_forecast_reader(
        sys.data,
        T;
        resolution = resolution,
        name = name,
        features = features,
    )

"""
Build a `StaticTimeSeriesReader` over every `SingleTimeSeries` in the system.
`resolution` is required and pins the reader to one resolution; `name` and
`features` further narrow the match.

Drive the reader with `read_static_time_series_values!` and read each entry with
`get_static_time_series_value`. Series with the same element type are packed into one
columnar group and served by a single storage read per timestamp.
"""
build_static_time_series_reader(
    sys::System;
    resolution::Dates.Period,
    name::Union{Nothing, AbstractString} = nothing,
    features::Union{Nothing, Dict} = nothing,
) =
    IS.build_static_time_series_reader(
        sys.data;
        resolution = resolution,
        name = name,
        features = features,
    )

"""
Return a sorted Vector of distinct resolutions for all time series of the given type
(or all types).
"""
get_time_series_resolutions(
    sys::System;
    time_series_type::Union{Type{<:TimeSeriesData}, Nothing} = nothing,
) = IS.get_time_series_resolutions(sys.data; time_series_type = time_series_type)

"""
Return an iterator of time series attached to components in the system.

Note that passing a filter function can be much slower than the other filtering parameters
because it reads time series data from media.

Call `collect` on the result to get an array.

# Arguments
- `sys::System`: system
- `filter_func = nothing`: Only return time series for which this returns true.
- `type = nothing`: Only return time series with this type.
- `name = nothing`: Only return time series matching this value.
- `resolution = nothing`: Only return time series matching this resolution.
- `interval = nothing`: Only return time series matching this interval.

# Examples
```julia
for time_series in get_time_series_multiple(sys)
    @show time_series
end

ts = collect(get_time_series_multiple(sys; type = SingleTimeSeries))
```
"""
function IS.get_time_series_multiple(
    sys::System,
    filter_func = nothing;
    type = nothing,
    name = nothing,
    resolution = nothing,
    interval = nothing,
)
    # Resolve the owners before opening the Channel: a Channel wraps whatever its body
    # throws in a TaskFailedException, which would bury the orphaned-owner ArgumentError
    # IS raises for a component removed with `remove_time_series = false`.
    owners = collect(
        IS.iterate_components_with_time_series(sys.data; time_series_type = type),
    )
    Channel{TimeSeriesData}() do channel
        for component in owners
            for time_series in get_time_series_multiple(
                component,
                filter_func;
                type = type,
                name = name,
                resolution = resolution,
                interval = interval,
            )
                put!(channel, time_series)
            end
        end
    end
end

"""
Clear all time series data from the system.

If you are storing time series data on disk, this removes every association and frees the
underlying arrays in place; it does not shrink the `.h5` file. Call
[`compact_time_series!`](@ref) to reclaim that space.
"""
function clear_time_series!(sys::System)
    return IS.clear_time_series!(sys.data)
end

"""
Reclaim the space that removed time series left behind, returning an
`InfraStore.CompactionReport` (`slots_reclaimed`, `feature_sets_reclaimed`,
`timestamp_sets_reclaimed`, `bytes_reclaimed`).

Removing time series does not shrink on-disk storage; this is what reclaims it.
"""
function compact_time_series!(sys::System)
    return IS.compact_time_series!(sys.data)
end

"""
Remove the time series data for a component or supplemental attribute and time series type.

Use `resolution`, `interval`, and `features` keyword arguments to disambiguate when multiple
time series of the same type and name exist with different resolutions, intervals, or
user-defined feature tags.
"""
function remove_time_series!(
    sys::System,
    ::Type{T},
    owner::Union{Component, SupplementalAttribute},
    name::String;
    resolution::Union{Nothing, Dates.Period} = nothing,
    interval::Union{Nothing, Dates.Period} = nothing,
    features::Union{Nothing, Dict} = nothing,
) where {T <: TimeSeriesData}
    return IS.remove_time_series!(
        sys.data,
        T,
        owner,
        name;
        resolution = resolution,
        interval = interval,
        features = features,
    )
end

"""
Remove all the time series data for a time series type.

See also: [`clear_time_series!`](@ref)

Removal drops the arrays but does not shrink on-disk storage; call
[`compact_time_series!`](@ref) to reclaim that space.
"""
function remove_time_series!(
    sys::System,
    ::Type{T};
    resolution::Union{Nothing, Dates.Period} = nothing,
    interval::Union{Nothing, Dates.Period} = nothing,
) where {T <: TimeSeriesData}
    return IS.remove_time_series!(sys.data, T; resolution = resolution, interval = interval)
end

"""
Transform all instances of [`SingleTimeSeries`](@ref) in a `System` to
[`DeterministicSingleTimeSeries`](@ref)

This can be used to generate a perfect forecast from historical measurements or realizations
when actual forecasts are unavailable, without unnecessarily duplicating data.

If all `SingleTimeSeries` instances cannot be transformed then none will be.

By default, any existing `DeterministicSingleTimeSeries` forecasts will be deleted before the
transform (`delete_existing = true`). Set `delete_existing = false` to preserve existing
`DeterministicSingleTimeSeries`; entries with matching name, resolution, features, horizon,
and interval are skipped, allowing multiple calls with different resolutions to coexist.

# Arguments
- `sys::System`: System containing the components.
- `horizon::Dates.Period`: desired [horizon](@ref H) of each forecast [window](@ref W)
- `interval::Dates.Period`: desired [interval](@ref I) between forecast [windows](@ref W)
- `resolution::Union{Nothing, Dates.Period} = nothing`: If set, only transform time series
   with this resolution.
- `delete_existing::Bool = true`: If `true`, delete all existing
   `DeterministicSingleTimeSeries` before transforming.
"""
function transform_single_time_series!(
    sys::System,
    horizon::Dates.Period,
    interval::Dates.Period;
    resolution::Union{Nothing, Dates.Period} = nothing,
    delete_existing::Bool = true,
)
    IS.transform_single_time_series!(
        sys.data,
        IS.DeterministicSingleTimeSeries,
        horizon,
        interval;
        resolution = resolution,
        delete_existing = delete_existing,
    )
    return
end

"""
Add a supplemental attribute to the component. The attribute may already be attached to a
different component.
"""
function add_supplemental_attribute!(
    sys::System,
    component::Component,
    attribute::IS.SupplementalAttribute,
)
    return IS.add_supplemental_attribute!(sys.data, component, attribute)
end

function add_supplemental_attribute!(
    sys::System,
    component::Component,
    outage::Outage,
)
    if get_runchecks(sys)
        for id in get_monitored_components(outage)
            comp = IS.get_component(sys, id)  # throws ArgumentError on miss
            if !(comp isa Device)
                throw(
                    ArgumentError(
                        "monitored_components on $(typeof(outage)) references id " *
                        "$(id), which resolves to $(typeof(comp)); only " *
                        "Device subtypes are allowed",
                    ),
                )
            end
        end
    end
    return IS.add_supplemental_attribute!(sys.data, component, outage)
end

"""
Begin an update of supplemental attributes. Use this function when adding
or removing many supplemental attributes in order to improve performance.

If an error occurs during the update, changes will be reverted.

# Examples
```julia
begin_supplemental_attributes_update(sys) do
    add_supplemental_attribute!(sys, component1, attribute1)
    add_supplemental_attribute!(sys, component2, attribute2)
end
```
"""
begin_supplemental_attributes_update(func::Function, sys::System) =
    IS.begin_supplemental_attributes_update(func, sys.data.supplemental_attribute_manager)

"""
Remove the supplemental attribute from the component. The attribute will be removed from the
system if it is not attached to any other component.
"""
function remove_supplemental_attribute!(
    sys::System,
    component::Component,
    attribute::IS.SupplementalAttribute,
)
    return IS.remove_supplemental_attribute!(sys.data, component, attribute)
end

"""
Remove all supplemental attributes with the given type from the system.
"""
function remove_supplemental_attributes!(
    ::Type{T},
    sys::System,
) where {T <: IS.SupplementalAttribute}
    return IS.remove_supplemental_attributes!(sys.data, T)
end

"""
Returns an iterator of supplemental attributes. T can be concrete or abstract.
Call collect on the result if an array is desired.

# Examples
```julia
iter = get_supplemental_attributes(GeometricDistributionForcedOutage, sys)
iter = get_supplemental_attributes(Outage, sys)
iter = get_supplemental_attributes(x -> get_mean_time_to_recovery(x) ==  >= 0.5, GeometricDistributionForcedOutage, sys)
outages = get_supplemental_attributes(GeometricDistributionForcedOutage, sys) do outage
    get_mean_time_to_recovery(x) ==  >= 0.5
end
outages = collect(get_supplemental_attributes(GeometricDistributionForcedOutage, sys))
```

See also: [`iterate_supplemental_attributes`](@ref)
"""
function get_supplemental_attributes(
    filter_func::Function,
    ::Type{T},
    sys::System,
) where {T <: IS.SupplementalAttribute}
    return IS.get_supplemental_attributes(filter_func, T, sys.data)
end

function get_supplemental_attributes(
    ::Type{T},
    sys::System,
) where {T <: IS.SupplementalAttribute}
    return IS.get_supplemental_attributes(T, sys.data)
end

"""
    get_associated_supplemental_attributes(obj)

Retrieves supplemental attributes associated with the given object.

This function extracts and returns additional metadata or auxiliary information
that is linked to the specified object, typically used for extended functionality
or configuration purposes.

# Arguments
- `obj`: The object for which to retrieve associated supplemental attributes

# Returns
- Collection of supplemental attributes associated with the input object

# Examples
```julia
gen_attr_pairs = get_component_supplemental_attribute_pairs(
    GeometricDistributionForcedOutage,
    ThermalStandard,
    sys,
)
for (gen, attr) in gen_attr_pairs
    @show summary(gen) summary(attr)
end

my_generators = [gen1, gen2, gen3]
gen_attr_pairs_limited = get_component_supplemental_attribute_pairs(
    GeometricDistributionForcedOutage,
    ThermalStandard,
    sys,
    components = my_generators,
)
for (gen, attr) in gen_attr_pairs_limited
    @show summary(gen) summary(attr)
end
```
"""
function get_associated_supplemental_attributes(
    sys::System,
    ::Type{T};
    attribute_type::Union{Nothing, Type{<:IS.SupplementalAttribute}} = nothing,
) where {T <: IS.InfrastructureSystemsComponent}
    return IS.get_associated_supplemental_attributes(
        sys.data,
        T;
        attribute_type = attribute_type,
    )
end

"""
Return the supplemental attribute with the given integer id.

Throws ArgumentError if the attribute is not stored.
"""
function get_supplemental_attribute(sys::System, id::Int)
    return IS.get_supplemental_attribute(sys.data, id)
end

"""
Iterates over all supplemental_attributes.

# Examples
```julia
for supplemental_attribute in iterate_supplemental_attributes(sys)
    @show supplemental_attribute
end
```

See also: [`get_supplemental_attributes`](@ref)
"""
function iterate_supplemental_attributes(sys::System)
    return IS.iterate_supplemental_attributes(sys.data)
end

"""
Return a vector of NamedTuples with pairs of components and supplemental attributes that
are associated with each other. Limit by `components` and `attributes` if provided.

The return type is `NamedTuple{(:component, :supplemental_attribute), Tuple{T, U}}[]`
where `T` is the component type and `U` is the supplemental attribute type.

# Arguments
- `sys::System`: System containing the components and attributes.
- `::Type{T}`: Type of the components to filter by. Can be concrete or abstract.
- `::Type{U}`: Type of the supplemental attributes to filter by. Can be concrete or abstract.
- `components`: Optional iterable. If set, filter pairs where the component is in this
  iterable.
- `attributes`: Optional iterable. If set, filter pairs where the supplemental attribute is
  in this iterable.

# Examples
```julia
gen_attr_pairs = get_component_supplemental_attribute_pairs(
    GeometricDistributionForcedOutage,
    ThermalStandard,
    sys,
)
for (gen, attr) in gen_attr_pairs
    @show summary(gen) summary(attr)
end

my_generators = [gen1, gen2, gen3]
gen_attr_pairs_limited = get_component_supplemental_attribute_pairs(
    GeometricDistributionForcedOutage,
    ThermalStandard,
    sys,
    components = my_generators,
)
for (gen, attr) in gen_attr_pairs_limited
    @show summary(gen) summary(attr)
end
```
"""
function get_component_supplemental_attribute_pairs(
    ::Type{T},
    ::Type{U},
    sys::System;
    components = nothing,
    attributes = nothing,
) where {T <: Component, U <: SupplementalAttribute}
    return IS.get_component_supplemental_attribute_pairs(
        T,
        U,
        sys.data;
        components = components,
        attributes = attributes,
    )
end

"""
Sanitize component values.
"""
sanitize_component!(component::Component, sys::System) = true

"""
Validate the component fields using only those fields. Refer to
[`validate_component_with_system`](@ref) to use other System data for the
validation.

Return true if the instance is valid.
"""
validate_component(component::Component) = true

"""
Validate a component against System data. Return true if the instance is valid.

Refer to [`validate_component`](@ref) if the validation logic only requires data contained
within the instance.
"""
validate_component_with_system(component::Component, sys::System) = true

Base.@deprecate validate_struct(sys::System, component::Component) validate_component_with_system(
    component,
    sys,
) false

# Keeps the code working with IS.
IS.validate_struct(component::Component) = validate_component(component)

"""
Check system consistency and validity.
"""
function check(sys::System)
    buses = get_components(ACBus, sys)
    slack_bus_check(buses)
    buscheck(sys)
    critical_components_check(sys)
    adequacy_check(sys)
    check_subsystems(sys)
    return
end

# Subsystem assignment is all-or-none across the system.
function _check_uniform_subsystem_assignment(sys::System)
    must_be_assigned_to_subsystem = false
    for (i, component) in enumerate(iterate_components(sys))
        is_assigned = is_assigned_to_subsystem(sys, component)
        if i == 1
            must_be_assigned_to_subsystem = is_assigned
        elseif is_assigned != must_be_assigned_to_subsystem
            throw(
                IS.InvalidValue(
                    "If any component is assigned to a subsystem then all " *
                    "components must be assigned to a subsystem.",
                ),
            )
        end
    end
    return
end

"""
Check the consistency of subsystems.
"""
function check_subsystems(sys::System)
    _check_uniform_subsystem_assignment(sys)
    for component in iterate_components(sys)
        check_subsystems(sys, component)
    end
    return
end

"""
Check the values of all components. See [`check_component`](@ref) for exceptions thrown.
"""
function check_components(sys::System; check_masked_components = true)
    _check_uniform_subsystem_assignment(sys)
    for component in iterate_components(sys)
        check_component(sys, component)
    end

    if check_masked_components
        for component in IS.get_masked_components(Component, sys.data)
            check_component(sys, component)
        end
    end
end

"""
Check the values of components of a given abstract or concrete type.
See [`check_component`](@ref) for exceptions thrown.
"""
function check_components(
    sys::System,
    ::Type{T};
    check_masked_components = true,
) where {T <: Component}
    for component in get_components(T, sys)
        check_component(sys, component)
    end

    if check_masked_components
        for component in IS.get_masked_components(T, sys.data)
            check_component(sys, component)
        end
    end
end

"""
Check the values of each component in an iterable of components.
See [`check_component`](@ref) for exceptions thrown.
"""
function check_components(sys::System, components)
    for component in components
        check_component(sys, component)
    end
end

"""
Check the values of a component.

Throws InvalidValue if any of the component's field values are outside of defined valid
range or if the custom validate method for the type fails its check.
"""
function check_component(sys::System, component::Component)
    if !validate_component_with_system(component, sys)
        throw(IS.InvalidValue("Invalid value for $(summary(component))"))
    end
    IS.check_component(sys.data, component)
    return
end

"""
Check that all AC transmission [`Line`](@ref) and [`MonitoredLine`](@ref) components
have valid rate values relative to their own device base power.

Returns `true` if all values are valid, `false` otherwise.
"""
function check_ac_transmission_rate_values(sys::System)
    is_valid = true
    for line in
        Iterators.flatten((get_components(Line, sys), get_components(MonitoredLine, sys)))
        if !check_rating_values(line)
            is_valid = false
        end
    end
    return is_valid
end

"""
Return [`ACBus`](@ref) with `name`.
"""
function get_bus(sys::System, name::AbstractString)
    return get_component(ACBus, sys, name)
end

"""
Return [`ACBus`](@ref) with `bus_number`.
"""
function get_bus(sys::System, bus_number::Int)
    for bus in get_components(ACBus, sys)
        if bus.number == bus_number
            return bus
        end
    end

    return nothing
end

"""
Return [`ACBus`](@ref)es from a set of identification `number`s

# Examples
```julia
# View all the bus ID numbers in the System
get_number.(get_components(ACBus, system))
# Select a subset
buses_by_ID = get_buses(system, Set(101:110))
```
"""
function get_buses(sys::System, bus_numbers::Set{Int})
    buses = Vector{ACBus}()
    for bus in get_components(ACBus, sys)
        if bus.number in bus_numbers
            push!(buses, bus)
        end
    end

    return buses
end

"""
Return all the device types in the system. It does not return component types or masked components.
"""
function get_existing_device_types(sys::System)
    device_types = Vector{DataType}()
    for component_type in keys(sys.data.components.data)
        if component_type <: Device
            push!(device_types, component_type)
        end
    end
    return device_types
end

"""
Return all the component types in the system. It does not return masked components.
"""
function get_existing_component_types(sys::System)
    return collect(keys(sys.data.components.data))
end

function _is_deserialization_in_progress(sys::System)
    ext = get_ext(sys)
    return get(ext, "deserialization_in_progress", false)
end

check_for_services_on_addition(sys::System, component::Component) = nothing

function check_for_services_on_addition(sys::System, component::T) where {T <: Device}
    if supports_services(component) && length(get_services(component)) > 0
        throw(
            ArgumentError(
                "type $(IS.strip_module_name(string(T))) cannot be added with services",
            ),
        )
    end
    return
end

function check_topology(sys::System, component::AreaInterchange)
    throw_if_not_attached(get_from_area(component), sys)
    throw_if_not_attached(get_to_area(component), sys)
    return
end

function check_topology(sys::System, component::Component)
    check_attached_buses(sys, component)
    return
end

"""
Throws ArgumentError if any bus attached to the component is invalid.
"""
check_attached_buses(sys::System, component::Component) = nothing

function check_attached_buses(sys::System, component::StaticInjection)
    throw_if_not_attached(get_bus(component), sys)
    return
end

function check_attached_buses(sys::System, component::Branch)
    throw_if_not_attached(get_from_bus(component), sys)
    throw_if_not_attached(get_to_bus(component), sys)
    return
end

function check_attached_buses(
    sys::System,
    component::ThreeWindingTransformer,
)
    bus_primary = get_from(get_arc(get_primary_circuit(component)))
    bus_secondary = get_from(get_arc(get_secondary_circuit(component)))
    bus_tertiary = get_from(get_arc(get_tertiary_circuit(component)))
    star_bus = get_star_bus(component)
    throw_if_not_attached(bus_primary, sys)
    throw_if_not_attached(bus_secondary, sys)
    throw_if_not_attached(bus_tertiary, sys)
    throw_if_not_attached(star_bus, sys)
    return
end

function check_attached_buses(sys::System, component::Arc)
    throw_if_not_attached(get_from(component), sys)
    throw_if_not_attached(get_to(component), sys)
    return
end

function check_attached_buses(sys::System, component::TradingHub)
    for bus in get_associated_buses(component)
        throw_if_not_attached(bus, sys)
    end
    return
end

"""
Throws ArgumentError if a PowerSystems rule blocks addition to the system.

This method is tied with handle_component_addition!. If the methods are re-implemented for
a subtype then whatever is added in handle_component_addition! must be checked here.
"""
check_component_addition(sys::System, component::Component; kwargs...) = nothing

"""
Throws ArgumentError if a PowerSystems rule blocks removal from the system.
"""
check_component_removal(sys::System, component::Component) = nothing

function check_component_removal(sys::System, static_injector::StaticInjection)
    if get_dynamic_injector(static_injector) !== nothing
        name = get_name(static_injector)
        throw(ArgumentError("$name cannot be removed with an attached dynamic injector"))
    end
end

function check_component_removal(sys::System, area::Area)
    for interchange in get_components(AreaInterchange, sys)
        if area in [get_from_area(interchange), get_to_area(interchange)]
            throw(
                ArgumentError(
                    "Area $(summary(area)) cannot be removed with attached AreaInterchange: $(summary(interchange))",
                ),
            )
        end
    end
    _check_vp_settlement_removal(sys, area)
    return
end

"""
Throws ArgumentError if any `VirtualParticipant` settles at `topology`.
"""
function _check_vp_settlement_removal(sys::System, topology::Topology)
    for vp in get_components(VirtualParticipant, sys)
        if get_settlement_point(vp) === topology
            throw(
                ArgumentError(
                    "$(summary(topology)) cannot be removed while $(summary(vp)) " *
                    "settles there",
                ),
            )
        end
    end
    return
end

function check_component_removal(sys::System, topology::Topology)
    _check_vp_settlement_removal(sys, topology)
    return
end

function check_component_removal(sys::System, bus::ACBus)
    for hub in get_components(TradingHub, sys)
        if bus in get_associated_buses(hub)
            throw(
                ArgumentError(
                    "$(summary(bus)) cannot be removed with attached TradingHub: " *
                    "$(summary(hub))",
                ),
            )
        end
    end
    _check_vp_settlement_removal(sys, bus)
    return
end

function check_component_removal(sys::System, hub::TradingHub)
    for ptp in get_components(PointToPointBid, sys)
        if get_from(ptp) === hub || get_to(ptp) === hub
            throw(
                ArgumentError(
                    "$(summary(hub)) cannot be removed with attached PointToPointBid: " *
                    "$(summary(ptp))",
                ),
            )
        end
    end
    return
end

"""
Refer to docstring for check_component_addition!
"""
handle_component_addition!(sys::System, component::Component; kwargs...) = nothing

handle_component_removal!(sys::System, component::Component) = nothing

function check_component_addition(sys::System, branch::AreaInterchange; kwargs...)
    throw_if_not_attached(get_from_area(branch), sys)
    throw_if_not_attached(get_to_area(branch), sys)
    return
end

function check_component_addition(sys::System, branch::Branch; kwargs...)
    arc = get_arc(branch)
    throw_if_not_attached(get_from(arc), sys)
    throw_if_not_attached(get_to(arc), sys)
    return
end

function check_component_addition(
    sys::System,
    component::ThreeWindingTransformer;
    kwargs...,
)
    bus_primary = get_from(get_arc(get_primary_circuit(component)))
    bus_secondary = get_from(get_arc(get_secondary_circuit(component)))
    bus_tertiary = get_from(get_arc(get_tertiary_circuit(component)))
    star_bus = get_star_bus(component)
    throw_if_not_attached(bus_primary, sys)
    throw_if_not_attached(bus_secondary, sys)
    throw_if_not_attached(bus_tertiary, sys)
    throw_if_not_attached(star_bus, sys)
    return
end

function check_component_addition(sys::System, dyn_injector::DynamicInjection; kwargs...)
    if _is_deserialization_in_progress(sys)
        # Ordering of component addition makes these checks impossible.
        return
    end

    static_injector = get(kwargs, :static_injector, nothing)
    if static_injector === nothing
        throw(
            ArgumentError("static_injector must be passed when adding a DynamicInjection"),
        )
    end

    if get_name(dyn_injector) != get_name(static_injector)
        throw(
            ArgumentError(
                "static_injector must have the same name as the DynamicInjection",
            ),
        )
    end

    throw_if_not_attached(static_injector, sys)
    return
end

function check_component_addition(sys::System, bus::Bus; kwargs...)
    number = get_number(bus)
    if number in sys.bus_numbers
        throw(ArgumentError("bus number $number is already stored in the system"))
    end

    area = get_area(bus)
    if !isnothing(area)
        throw_if_not_attached(area, sys)
    end

    load_zone = get_load_zone(bus)
    if !isnothing(load_zone)
        throw_if_not_attached(load_zone, sys)
    end
end

function _check_vp_location(sys::System, ::VirtualParticipant, ::Nothing, hubs)
    for hub in hubs
        throw_if_not_attached(hub, sys)
    end
    return nothing
end

function _check_vp_location(
    sys::System,
    vp::VirtualParticipant,
    settlement_point::Topology,
    hubs,
)
    if !isempty(hubs)
        throw(
            ArgumentError(
                "$(get_name(vp)) cannot set both settlement_point " *
                "($(get_name(settlement_point))) and trading_hubs; choose one location mode",
            ),
        )
    end
    throw_if_not_attached(settlement_point, sys)
    return nothing
end

"""
Throws ArgumentError if `vp` sets both `settlement_point` and `trading_hubs`, or if a set
`settlement_point` is not attached to `sys`. Hub attachment is not checked here: hubs may be
associated after `add_component!`, like services.
"""
function check_component_addition(sys::System, vp::VirtualParticipant; kwargs...)
    _check_vp_location(sys, vp, get_settlement_point(vp), get_trading_hubs(vp))
    return
end

"""
Throws ArgumentError if `ptp`'s `from`/`to` terminals are not a Topology or a TradingHub, if
they are identical, or if either is not attached to `sys`.
"""
function check_component_addition(sys::System, ptp::PointToPointBid; kwargs...)
    from = get_from(ptp)
    to = get_to(ptp)
    _check_ptp_terminal(from)
    _check_ptp_terminal(to)
    if from === to
        throw(ArgumentError("PointToPointBid $(get_name(ptp)) has identical terminals"))
    end
    throw_if_not_attached(from, sys)
    throw_if_not_attached(to, sys)
    return
end

function handle_component_addition!(sys::System, bus::Bus; kwargs...)
    number = get_number(bus)
    if number in sys.bus_numbers
        throw(ArgumentError("bus number $number is already stored"))
    end
    push!(sys.bus_numbers, number)
    return
end

function handle_component_addition!(sys::System, component::Branch; kwargs...)
    _handle_branch_addition_common!(sys, component)
    return
end

function handle_component_addition!(sys::System, dyn_injector::DynamicInjection; kwargs...)
    static_injector = kwargs[:static_injector]
    static_base_power = _get_base_power(static_injector)
    set_base_power!(dyn_injector, static_base_power)
    set_dynamic_injector!(static_injector, dyn_injector)
    return
end

function handle_component_addition!(
    sys::System,
    subsystem::StaticInjectionSubsystem;
    kwargs...,
)
    for subcomponent in get_subcomponents(subsystem)
        if is_attached(subcomponent, sys)
            IS.mask_component!(sys.data, subcomponent)
            copy_subcomponent_time_series!(subsystem, subcomponent)
        else
            IS.add_masked_component!(sys.data, subcomponent)
        end
    end
end

function _handle_branch_addition_common!(sys::System, component::Branch)
    # If this arc is already attached to the system, assign it to the branch.
    # Else, add it to the system.
    arc = get_arc(component)
    _arc = get_component(Arc, sys, get_name(arc))
    if isnothing(_arc)
        add_component!(sys, arc)
    else
        set_arc!(component, _arc)
    end
    return
end

function _handle_branch_addition_common!(
    sys::System,
    component::ThreeWindingTransformer,
)
    # If this arc is already attached to the system, assign it to the 3W XFRM.
    # Else, add it to the system.
    circuits = [
        get_primary_circuit(component),
        get_secondary_circuit(component),
        get_tertiary_circuit(component),
    ]
    for circuit in circuits
        arc = get_arc(circuit)
        _arc = get_component(Arc, sys, get_name(arc))
        if isnothing(_arc)
            add_component!(sys, arc)
        else
            set_arc!(circuit, _arc)
        end
    end
    return
end

_handle_branch_addition_common!(sys::System, component::AreaInterchange) = nothing

"""
Throws ArgumentError if the bus number is not stored in the system.
"""
function handle_component_removal!(sys::System, bus::Bus)
    _handle_component_removal_common!(bus)
    number = get_number(bus)
    if !(number in sys.bus_numbers)
        throw(ArgumentError("bus number $number is not stored"))
    end
    pop!(sys.bus_numbers, number)
    return
end

function handle_component_removal!(sys::System, device::Device)
    _handle_component_removal_common!(device)
    # This may have to be refactored if handle_component_removal! needs to be implemented
    # for a subtype.
    clear_services!(device)
    return
end

function handle_component_removal!(sys::System, service::Service)
    _handle_component_removal_common!(service)
    for device in get_components(Device, sys)
        if !supports_services(device)
            continue
        end
        _remove_service!(device, service)
    end
end

function handle_component_removal!(sys::System, hub::TradingHub)
    _handle_component_removal_common!(hub)
    for vp in get_components(VirtualParticipant, sys)
        _remove_trading_hub!(vp, hub)
    end
end

function handle_component_removal!(sys::System, component::StaticInjectionSubsystem)
    _handle_component_removal_common!(component)
    subcomponents = collect(get_subcomponents(component))
    for subcomponent in subcomponents
        clear_units!(subcomponent)
        IS.remove_masked_component!(sys.data, subcomponent)
    end
end

function handle_component_removal!(sys::System, value::T) where {T <: AggregationTopology}
    _handle_component_removal_common!(value)
    for device in get_components(ACBus, sys)
        if get_aggregation_topology_accessor(T)(device) == value
            _remove_aggregration_topology!(device, value)
        end
    end
end

function handle_component_removal!(sys::System, dyn_injector::DynamicInjection)
    _handle_component_removal_common!(dyn_injector)
    injectors = get_components_by_name(StaticInjection, sys, get_name(dyn_injector))
    found = false
    for static_injector in injectors
        _dyn_injector = get_dynamic_injector(static_injector)
        _dyn_injector === nothing && continue
        if _dyn_injector === dyn_injector
            @assert !found
            set_dynamic_injector!(static_injector, nothing)
            found = true
        end
    end

    @assert found
end

function _handle_component_removal_common!(component)
    clear_units!(component)
end

"""
Return a sorted vector of bus numbers in the system.
"""
function get_bus_numbers(sys::System)
    return sort(collect(sys.bus_numbers))
end

_fetch_match_fn(match_fn::Function) = match_fn
_fetch_match_fn(::Nothing) = IS.isequivalent

function IS.compare_values(
    match_fn::Union{Function, Nothing},
    x::T,
    y::T;
    compare_ids = false,
    exclude = Set{Symbol}(),
) where {T <: Union{StaticInjection, DynamicInjection}}
    # Must implement this method because a device of one of these subtypes might have a
    # reference to its counterpart, and vice versa, and so infinite recursion will occur
    # in the default function.
    match = true
    for name in fieldnames(T)
        name in exclude && continue
        val1 = getfield(x, name)
        val2 = getfield(y, name)
        if val1 isa StaticInjection || val2 isa DynamicInjection
            if !compare_ids
                name1 = get_name(val1)
                name2 = get_name(val2)
                if !_fetch_match_fn(match_fn)(name1, name2)
                    @error "values do not match" T name name1 name2
                    match = false
                end
            else
                id1 = IS.get_id(val1)
                id2 = IS.get_id(val2)
                if id1 != id2
                    @error "values do not match" T name id1 id2
                    match = false
                end
            end
        elseif !isempty(fieldnames(typeof(val1)))
            if !IS.compare_values(
                match_fn,
                val1,
                val2;
                compare_ids = compare_ids,
                exclude = exclude,
            )
                @error "values do not match" T name val1 val2
                match = false
            end
        elseif val1 isa AbstractArray
            if !IS.compare_values(
                match_fn,
                val1,
                val2;
                compare_ids = compare_ids,
                exclude = exclude,
            )
                match = false
            end
        else
            if !_fetch_match_fn(match_fn)(val1, val2)
                @error "values do not match" T name val1 val2
                match = false
            end
        end
    end

    return match
end

function _create_system_data_from_kwargs(;
    time_series_in_memory = false,
    time_series_directory = nothing,
    compression = nothing,
    enable_compression = false,
    config_path = POWER_SYSTEM_STRUCT_DESCRIPTOR_FILE,
    kwargs...,
)
    if isnothing(compression)
        compression = IS.CompressionSettings(; enabled = enable_compression)
    end

    return IS.SystemData(;
        validation_descriptor_file = config_path,
        time_series_in_memory = time_series_in_memory,
        time_series_directory = time_series_directory,
        compression = compression,
    )
end

"""
Converts a Line component to a MonitoredLine component and replaces the original in the
system
"""
function convert_component!(
    sys::System,
    line::Line,
    linetype::Type{MonitoredLine};
    kwargs...,
)
    new_line = linetype(
        line.name,
        line.available,
        line.active_power_flow,
        line.reactive_power_flow,
        line.arc,
        line.r,
        line.x,
        line.b,
        (from_to = line.rating, to_from = line.rating),
        line.rating,
        line.angle_limits,
        line.rating_b,
        line.rating_c,
        line.g,
        line.services,
        line.base_power,
        line.ext,
        _copy_internal_for_conversion(line),
    )
    IS.assign_new_id!(sys, line)
    add_component!(sys, new_line)
    copy_time_series!(new_line, line)
    # TODO: PSY4
    # copy_supplemental_attibutes!(new_line, line)
    remove_component!(sys, line)
    return
end

"""
Converts a MonitoredLine component to a Line component and replaces the original in the
system.
"""
function convert_component!(
    sys::System,
    line::MonitoredLine,
    linetype::Type{Line};
    kwargs...,
)
    force = get(kwargs, :force, false)
    if force
        @warn("Possible data loss converting from $(typeof(line)) to $linetype")
    else
        error(
            "Possible data loss converting from $(typeof(line)) to $linetype, add `force = true` to convert anyway.",
        )
    end

    new_line = linetype(
        line.name,
        line.available,
        line.active_power_flow,
        line.reactive_power_flow,
        line.arc,
        line.r,
        line.x,
        line.b,
        line.rating,
        line.angle_limits,
        line.rating_b,
        line.rating_c,
        line.g,
        line.services,
        line.base_power,
        line.ext,
        _copy_internal_for_conversion(line),
    )
    IS.assign_new_id!(sys, line)
    add_component!(sys, new_line)
    copy_time_series!(new_line, line)
    # TODO: PSY4
    # copy_supplemental_attibutes!(new_line, line)
    remove_component!(sys, line)
    return
end

"""
Converts a PowerLoad component to a StandardLoad component and replaces the original in the
system. Does not set any fields in StandardLoad that lack a PowerLoad equivalent.
"""
function convert_component!(
    sys::System,
    old_load::PowerLoad,
    new_type::Type{StandardLoad};
    kwargs...,
)
    # Raw device-base values: struct fields are stored in device base (Float64);
    # we copy the underlying field directly to avoid SU-conversion round-tripping.
    new_load = new_type(;
        name = get_name(old_load),
        available = get_available(old_load),
        bus = get_bus(old_load),
        base_power = _get_base_power(old_load),
        constant_active_power = old_load.active_power,
        constant_reactive_power = old_load.reactive_power,
        max_constant_active_power = old_load.max_active_power,
        max_constant_reactive_power = old_load.max_reactive_power,
        conformity = get_conformity(old_load),
        dynamic_injector = get_dynamic_injector(old_load),
        internal = _copy_internal_for_conversion(old_load),
        services = Device[],
    )
    IS.assign_new_id!(sys, old_load)
    add_component!(sys, new_load)
    copy_time_series!(new_load, old_load)
    # TODO: PSY4
    # copy_supplemental_attibutes!(new_line, line)
    for service in get_services(old_load)
        add_service!(new_load, service, sys)
    end
    remove_component!(sys, old_load)
end

"""
Set the number of a bus.
"""
function set_bus_number!(sys::System, bus::Bus, number::Int)
    throw_if_not_attached(bus, sys)

    orig = get_number(bus)
    if number == orig
        return
    end

    if number in sys.bus_numbers
        throw(ArgumentError("bus number $number is already stored in the system"))
    end

    set_number!(bus, number)
    replace!(sys.bus_numbers, orig => number)
    return
end

function set_number!(bus::ACBus, number::Int)
    Base.depwarn(
        "This method will be removed in v5.0 because its use breaks system consistency" *
        "checks. Please call `set_bus_number!(::System, bus, number)` instead.",
        :set_number!,
    )
    bus.number = number
    return
end

# Use this function to avoid deepcopy of shared_system_references.
function _copy_internal_for_conversion(component::Component)
    internal = get_internal(component)
    return InfrastructureSystemsInternal(;
        id = internal.id,
        base_value = IS.get_base_value(internal),
        shared_system_references = nothing,
        ext = deepcopy(internal.ext),
    )
end

function _validate_or_skip!(sys, component, skip_validation)
    if skip_validation && get_runchecks(sys)
        @warn(
            "skip_validation is deprecated; construct System with runchecks = true or call set_runchecks!. Disabling System.runchecks"
        )
        set_runchecks!(sys, false)
    end

    # Always skip if system checks are disabled.
    if !skip_validation && !get_runchecks(sys)
        skip_validation = true
    end

    if !skip_validation
        sanitize_component!(component, sys)
        if !validate_component_with_system(component, sys)
            throw(IS.InvalidValue("Invalid value for $(summary(component))"))
        end
    end

    return skip_validation
end

"""
Returns counts of time series including attachments to components and supplemental
attributes.
"""
get_time_series_counts(sys::System) = IS.get_time_series_counts(sys.data)

"""
Group the time series in the system by the array they are stored in. Returns a `Dict`
mapping each content hash to the `(owner, key)` pairs that resolve to that one array.

By default only the arrays referenced more than once are returned, which identifies the
time series that share data, such as those added with
`add_time_series!(sys, components, time_series)`. Pass `only_shared = false` to get every
stored array.

See also `get_time_series_hash` for the hash of a single `(owner, key)` pair.
"""
get_time_series_array_groups(sys::System; only_shared = true) =
    IS.get_time_series_array_groups(sys.data; only_shared = only_shared)

"""
Checks time series in the system for inconsistencies.

For SingleTimeSeries, returns a Tuple of initial_timestamp and length.
Consistency is required per resolution; when the system stores SingleTimeSeries
at more than one resolution, pass `resolution` to name the grid to check and
return.

This is a no-op for subtypes of Forecast because those are already guaranteed to be
consistent.

Throws InfrastructureSystems.InvalidValue if any time series is inconsistent.
"""
function check_time_series_consistency(
    sys::System,
    ::Type{T};
    resolution::Union{Nothing, Dates.Period} = nothing,
) where {T <: TimeSeriesData}
    return IS.check_time_series_consistency(sys.data, T; resolution = resolution)
end

stores_time_series_in_memory(sys::System) = IS.stores_time_series_in_memory(sys.data)

"""
Make a `deepcopy` of a [`System`](@ref) more quickly by skipping the copying of time
series and/or supplemental attributes.

# Arguments

  - `data::System`: the `System` to copy
  - `skip_time_series::Bool = true`: whether to skip copying time series
  - `skip_supplemental_attributes::Bool = true`: whether to skip copying supplemental
    attributes

Note that setting both `skip_time_series` and `skip_supplemental_attributes` to `false`
results in the same behavior as `deepcopy` with no performance improvement.
"""
function fast_deepcopy_system(
    sys::System;
    skip_time_series::Bool = true,
    skip_supplemental_attributes::Bool = true,
)
    new_data = IS.fast_deepcopy_system(
        sys.data;
        skip_time_series = skip_time_series,
        skip_supplemental_attributes = skip_supplemental_attributes,
    )
    new_sys = System(
        new_data,
        sys.base_power,
        deepcopy(sys.internal);
        runchecks = deepcopy(sys.runchecks[]),
        frequency = deepcopy(sys.frequency),
        time_series_directory = deepcopy(sys.time_series_directory),
        name = deepcopy(sys.metadata.name),
        description = deepcopy(sys.metadata.description))
    return new_sys
end

"""
Return a DataFrame with the number of static time series for components and supplemental
attributes.
"""
function get_static_time_series_summary_table(sys::System)
    return IS.get_static_time_series_summary_table(sys.data)
end

"""
Return a DataFrame with the number of forecasts for components and supplemental
attributes.
"""
function get_forecast_summary_table(sys::System)
    return IS.get_forecast_summary_table(sys.data)
end

IS.get_base_component_type(sys::System) = Component
