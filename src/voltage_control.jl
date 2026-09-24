"""
Supertype for the supplemental attributes that group devices holding the voltage at one bus:
[`VoltageDroopControl`](@ref) and [`ReactivePowerSharing`](@ref).

Membership is recorded on the group as a map from member id to its relative reactive power
weight, plus the converter terminal for a two-terminal member ([`TwoTerminalVSCLine`](@ref)).
The OpenAPI document and SiennaGridDB carry the same relation as `voltage_control_associations`
rows. A device, or one converter of a two-terminal line, belongs to at most one group of either
kind.
"""
abstract type VoltageControlGroup <: SupplementalAttribute end

"""Get `internal`."""
get_internal(x::VoltageControlGroup) = x.internal

"""
Generators that regulate voltage to a setpoint and can therefore hold a `remote_regulated_bus`
and join a [`VoltageDroopControl`](@ref). [`RenewableNonDispatch`](@ref) is a fixed injection
with no voltage control and is not one of them.
"""
const VoltageControlGenerator = Union{ThermalGen, HydroGen, RenewableDispatch}

"""
Devices that regulate voltage to a setpoint at a single bus and can therefore hold a
`remote_regulated_bus` and join a [`ReactivePowerSharing`](@ref) group.
"""
const VoltageControlDevice = Union{
    VoltageControlGenerator,
    EnergyReservoirStorage,
    SynchronousCondenser,
    Source,
    SwitchedAdmittance,
    FACTSControlDevice,
    InterconnectingConverter,
}

"""
Attribute to represent a voltage droop controller (PSS/E voltage droop control): a set of
generators jointly regulating the reactive power at one bus along a Q–V characteristic.

While the controller is available its `regulated_bus` overrides each member's own target and
their `voltage_setpoint` is ignored; while it is unavailable the members fall back to their
own targets. The characteristic holds `reactive_power_limits.max` below `voltage_limits.min`,
ramps to `deadband_reactive_power` at `deadband_voltage_limits.min`, holds it through
`deadband_voltage_limits.max`, ramps to `reactive_power_limits.min` at `voltage_limits.max`,
and holds it above. Reactive powers are in MVAr; voltages are per-unit of the regulated bus
`base_voltage`. Members are generators only; see [`add_supplemental_attribute!`](@ref).

# Arguments
- `name::String`: Name of the controller
- `available::Bool`: Whether the controller is in service (PSS/E `STATUS`)
- `regulated_bus::ACBus`: Bus whose reactive power the controller regulates
- `reactive_power_limits::MinMax`: Reactive power held below `voltage_limits.min` (`max`, PSS/E `QMAX`) and above `voltage_limits.max` (`min`, PSS/E `QMIN`), in MVAr
- `deadband_reactive_power::Float64`: Reactive power held inside the voltage deadband (PSS/E `QDB`), in MVAr; strictly between the two limits
- `deadband_voltage_limits::MinMax`: Voltage band inside which the controller holds `deadband_reactive_power` (PSS/E `VDBLOW`/`VDBHIGH`), per-unit
- `voltage_limits::MinMax`: Voltages at which the characteristic reaches the two reactive power limits (PSS/E `VLOW`/`VHIGH`), per-unit
- `weights::Dict{Int, Float64}`: Member id to relative reactive power weight
- `terminals::Dict{Int, VoltageControlTerminal.Value}`: Member id to converter terminal, for two-terminal members only
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
mutable struct VoltageDroopControl <: VoltageControlGroup
    name::String
    available::Bool
    regulated_bus::ACBus
    reactive_power_limits::MinMax
    deadband_reactive_power::Float64
    deadband_voltage_limits::MinMax
    voltage_limits::MinMax
    weights::Dict{Int, Float64}
    terminals::Dict{Int, VoltageControlTerminal.Value}
    internal::InfrastructureSystemsInternal

    function VoltageDroopControl(
        name,
        available,
        regulated_bus,
        reactive_power_limits,
        deadband_reactive_power,
        deadband_voltage_limits,
        voltage_limits,
        weights,
        terminals,
        internal,
    )
        _check_droop_curve(
            name,
            reactive_power_limits,
            deadband_reactive_power,
            deadband_voltage_limits,
            voltage_limits,
        )
        return new(
            name,
            available,
            regulated_bus,
            reactive_power_limits,
            deadband_reactive_power,
            deadband_voltage_limits,
            voltage_limits,
            weights,
            terminals,
            internal,
        )
    end
end

"""
    VoltageDroopControl(; name, regulated_bus, reactive_power_limits, deadband_reactive_power, deadband_voltage_limits, voltage_limits, available, weights, terminals, internal)

Construct a [`VoltageDroopControl`](@ref). Throws `ArgumentError` when the Q–V characteristic
is not ordered: `reactive_power_limits.max > deadband_reactive_power >
reactive_power_limits.min` and `voltage_limits.max > deadband_voltage_limits.max >=
deadband_voltage_limits.min > voltage_limits.min`.
"""
function VoltageDroopControl(;
    name::String,
    regulated_bus::ACBus,
    reactive_power_limits::MinMax,
    deadband_reactive_power::Float64,
    deadband_voltage_limits::MinMax,
    voltage_limits::MinMax,
    available::Bool = true,
    weights::AbstractDict = Dict{Int, Float64}(),
    terminals::AbstractDict = Dict{Int, VoltageControlTerminal.Value}(),
    internal::InfrastructureSystemsInternal = InfrastructureSystemsInternal(),
)
    return VoltageDroopControl(
        name,
        available,
        regulated_bus,
        reactive_power_limits,
        deadband_reactive_power,
        deadband_voltage_limits,
        voltage_limits,
        Dict{Int, Float64}(weights),
        Dict{Int, VoltageControlTerminal.Value}(terminals),
        internal,
    )
end

"""Rule R15: the Q–V characteristic is ordered."""
function _check_droop_curve(
    name,
    reactive_power_limits::MinMax,
    deadband_reactive_power::Float64,
    deadband_voltage_limits::MinMax,
    voltage_limits::MinMax,
)
    if !(
        reactive_power_limits.max > deadband_reactive_power >
        reactive_power_limits.min
    )
        throw(
            ArgumentError(
                "VoltageDroopControl $name needs reactive_power_limits.max > " *
                "deadband_reactive_power > reactive_power_limits.min; got " *
                "$(reactive_power_limits.max) > $deadband_reactive_power > " *
                "$(reactive_power_limits.min)",
            ),
        )
    end
    if !(
        voltage_limits.max > deadband_voltage_limits.max >=
        deadband_voltage_limits.min > voltage_limits.min
    )
        throw(
            ArgumentError(
                "VoltageDroopControl $name needs voltage_limits.max > " *
                "deadband_voltage_limits.max >= deadband_voltage_limits.min > " *
                "voltage_limits.min; got $(voltage_limits.max) > " *
                "$(deadband_voltage_limits.max) >= $(deadband_voltage_limits.min) > " *
                "$(voltage_limits.min)",
            ),
        )
    end
    return
end

"""Get [`VoltageDroopControl`](@ref) `name`."""
get_name(value::VoltageDroopControl) = value.name
"""Get [`VoltageDroopControl`](@ref) `available`."""
get_available(value::VoltageDroopControl) = value.available
"""Get [`VoltageDroopControl`](@ref) `regulated_bus`."""
get_regulated_bus(value::VoltageDroopControl) = value.regulated_bus
"""Get [`VoltageDroopControl`](@ref) `reactive_power_limits` (MVAr)."""
get_reactive_power_limits(value::VoltageDroopControl) = value.reactive_power_limits
"""Get [`VoltageDroopControl`](@ref) `deadband_reactive_power` (MVAr)."""
get_deadband_reactive_power(value::VoltageDroopControl) = value.deadband_reactive_power
"""Get [`VoltageDroopControl`](@ref) `deadband_voltage_limits` (per-unit)."""
get_deadband_voltage_limits(value::VoltageDroopControl) = value.deadband_voltage_limits
"""Get [`VoltageDroopControl`](@ref) `voltage_limits` (per-unit)."""
get_voltage_limits(value::VoltageDroopControl) = value.voltage_limits
"""Get [`VoltageDroopControl`](@ref) `weights`."""
get_weights(value::VoltageDroopControl) = value.weights
"""Get [`VoltageDroopControl`](@ref) `terminals`."""
get_terminals(value::VoltageDroopControl) = value.terminals

"""Set [`VoltageDroopControl`](@ref) `available`."""
set_available!(value::VoltageDroopControl, val::Bool) = value.available = val
"""Set [`VoltageDroopControl`](@ref) `regulated_bus`."""
set_regulated_bus!(value::VoltageDroopControl, val::ACBus) = value.regulated_bus = val

"""
Attribute grouping the setpoint voltage regulating devices that hold the voltage at one bus,
so the reactive power required there can be split between them.

The members' shares are their weights, each divided by the sum over the members in service
(PSS/E `RMPCT`). The regulated bus is not stored: every member already resolves to the same
bus (see [`get_regulated_bus`](@ref)). A bus regulated by two or more setpoint devices has
exactly one sharing group containing all of them; a lone device has none. Members can be any
[`VoltageControlDevice`](@ref) or a converter of a [`TwoTerminalVSCLine`](@ref).

# Arguments
- `name::String`: Name of the sharing group
- `weights::Dict{Int, Float64}`: Member id to relative reactive power weight
- `terminals::Dict{Int, VoltageControlTerminal.Value}`: Member id to converter terminal, for two-terminal members only
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct ReactivePowerSharing <: VoltageControlGroup
    name::String
    weights::Dict{Int, Float64}
    terminals::Dict{Int, VoltageControlTerminal.Value}
    internal::InfrastructureSystemsInternal
end

"""
    ReactivePowerSharing(; name, weights, terminals, internal)

Construct a [`ReactivePowerSharing`](@ref).
"""
function ReactivePowerSharing(;
    name::String,
    weights::AbstractDict = Dict{Int, Float64}(),
    terminals::AbstractDict = Dict{Int, VoltageControlTerminal.Value}(),
    internal::InfrastructureSystemsInternal = InfrastructureSystemsInternal(),
)
    return ReactivePowerSharing(
        name,
        Dict{Int, Float64}(weights),
        Dict{Int, VoltageControlTerminal.Value}(terminals),
        internal,
    )
end

"""Get [`ReactivePowerSharing`](@ref) `name`."""
get_name(value::ReactivePowerSharing) = value.name
"""Get [`ReactivePowerSharing`](@ref) `weights`."""
get_weights(value::ReactivePowerSharing) = value.weights
"""Get [`ReactivePowerSharing`](@ref) `terminals`."""
get_terminals(value::ReactivePowerSharing) = value.terminals

"""
Relative reactive power weight of `component` in `group`. Throws `ArgumentError` when the
component is not a member.
"""
function get_weight(group::VoltageControlGroup, component::Component)
    id = IS.get_id(component)
    haskey(group.weights, id) || throw(
        ArgumentError(
            "$(summary(component)) is not a member of $(nameof(typeof(group))) $(get_name(group))",
        ),
    )
    return group.weights[id]
end

"""
Converter terminal of `component`'s membership in `group`: `nothing` for a single-bus member.
"""
get_terminal(group::VoltageControlGroup, component::Component) =
    get(group.terminals, IS.get_id(component), nothing)

# ── regulated-bus resolution ──────────────────────────────────────────────────────

"""
The bus `device` regulates: the `regulated_bus` of an available [`VoltageDroopControl`](@ref)
it belongs to, otherwise its `remote_regulated_bus`, otherwise its own `bus`.
"""
function get_regulated_bus(device::VoltageControlDevice)
    for group in get_supplemental_attributes(VoltageDroopControl, device)
        get_available(group) && return get_regulated_bus(group)
    end
    remote = get_remote_regulated_bus(device)
    isnothing(remote) && return get_bus(device)
    return remote
end

"""The bus the `from` converter of `line` regulates: `remote_regulated_bus_from`, otherwise
the arc's `from` bus."""
function get_regulated_bus_from(line::TwoTerminalVSCLine)
    remote = get_remote_regulated_bus_from(line)
    isnothing(remote) && return get_from(get_arc(line))
    return remote
end

"""The bus the `to` converter of `line` regulates: `remote_regulated_bus_to`, otherwise the
arc's `to` bus."""
function get_regulated_bus_to(line::TwoTerminalVSCLine)
    remote = get_remote_regulated_bus_to(line)
    isnothing(remote) && return get_to(get_arc(line))
    return remote
end

"""
Side of the controlling winding on which the regulated bus of `circuit` lies: the stored value
when the regulated bus is neither end of the arc, [`CONTROLLING_WINDING`](@ref
TransformerRegulatedBusSide) when it is the arc's `from` bus and [`OPPOSITE_WINDING`](@ref
TransformerRegulatedBusSide) when it is the `to` bus. `nothing` without a regulated bus, or
when a regulated bus off the arc has no stored side.
"""
function get_regulated_bus_side(circuit::TransformerCircuit)
    side = _get_regulated_bus_side(circuit)
    isnothing(side) || return side
    bus = get_regulated_bus(circuit)
    isnothing(bus) && return nothing
    arc = get_arc(circuit)
    bus === get_from(arc) && return TransformerRegulatedBusSide.CONTROLLING_WINDING
    bus === get_to(arc) && return TransformerRegulatedBusSide.OPPOSITE_WINDING
    return nothing
end

# ── membership ────────────────────────────────────────────────────────────────────

"""Whether `component` regulates voltage to a setpoint in its current control mode, and so
counts as a setpoint device for the bus-wide checks."""
_is_setpoint_device(::StaticInjection) = false
_is_setpoint_device(device::VoltageControlDevice) =
    get_bustype(get_bus(device)) in (ACBusTypes.PV, ACBusTypes.REF)
_is_setpoint_device(shunt::SwitchedAdmittance) =
    get_control_mode(shunt) in (
        SwitchedAdmittanceControlMode.DISCRETE_VOLTAGE,
        SwitchedAdmittanceControlMode.CONTINUOUS_VOLTAGE,
    )
function _is_setpoint_device(device::FACTSControlDevice)
    mode = get_control_mode(device)
    return !isnothing(mode) && mode != FACTSOperationModes.OOS
end
_is_setpoint_device(converter::InterconnectingConverter) =
    get_ac_control(converter) == VSCACControlModes.AC_VOLTAGE

"""Rule R9: member weights are positive."""
function _check_weight(group::VoltageControlGroup, component, weight::Float64)
    weight > 0.0 || throw(
        ArgumentError(
            "$(summary(component)) cannot join $(nameof(typeof(group))) " *
            "$(get_name(group)) with weight $weight; weights must be greater than 0",
        ),
    )
    return
end

"""Rule R7: a device belongs to at most one voltage control group of either kind."""
function _check_single_group(component::Component, group::VoltageControlGroup)
    for existing in get_supplemental_attributes(VoltageControlGroup, component)
        throw(
            ArgumentError(
                "$(summary(component)) already belongs to $(nameof(typeof(existing))) " *
                "$(get_name(existing)); a device belongs to at most one voltage control " *
                "group, so it cannot join $(nameof(typeof(group))) $(get_name(group))",
            ),
        )
    end
    return
end

"""Rule R7 for a two-terminal member: each converter terminal belongs to at most one group,
and one group cannot hold both terminals of one line."""
function _check_single_group(
    line::TwoTerminalVSCLine,
    group::VoltageControlGroup,
    terminal::VoltageControlTerminal.Value,
)
    id = IS.get_id(line)
    haskey(group.terminals, id) && throw(
        ArgumentError(
            "$(summary(line)) already belongs to $(nameof(typeof(group))) " *
            "$(get_name(group)) through its $(group.terminals[id]) converter; a group " *
            "holds at most one converter of a line",
        ),
    )
    for existing in get_supplemental_attributes(VoltageControlGroup, line)
        get(existing.terminals, id, nothing) == terminal && throw(
            ArgumentError(
                "the $terminal converter of $(summary(line)) already belongs to " *
                "$(nameof(typeof(existing))) $(get_name(existing)); a converter belongs " *
                "to at most one voltage control group",
            ),
        )
    end
    return
end

function _attach_to_group!(
    sys::System,
    component::Component,
    group::VoltageControlGroup,
    weight::Float64,
    terminal::Union{Nothing, VoltageControlTerminal.Value},
)
    id = IS.get_id(component)
    IS.add_supplemental_attribute!(sys.data, component, group)
    group.weights[id] = weight
    isnothing(terminal) || (group.terminals[id] = terminal)
    return
end

"""
    add_supplemental_attribute!(sys::System, component::VoltageControlDevice, group::ReactivePowerSharing; weight = 1.0)

Make `component` a member of the sharing group with relative reactive power `weight`. Throws
`ArgumentError` when the weight is not positive or the device already belongs to a voltage
control group.
"""
function add_supplemental_attribute!(
    sys::System,
    component::VoltageControlDevice,
    group::ReactivePowerSharing;
    weight::Float64 = 1.0,
)
    _check_weight(group, component, weight)
    _check_single_group(component, group)
    _attach_to_group!(sys, component, group, weight, nothing)
    return
end

"""
    add_supplemental_attribute!(sys::System, component::VoltageControlGenerator, group::VoltageDroopControl; weight = 1.0)

Make `component` a member of the droop controller with relative reactive power `weight`.
Only generators can be members. Throws `ArgumentError` when the weight is not positive or the
generator already belongs to a voltage control group.
"""
function add_supplemental_attribute!(
    sys::System,
    component::VoltageControlGenerator,
    group::VoltageDroopControl;
    weight::Float64 = 1.0,
)
    _check_weight(group, component, weight)
    _check_single_group(component, group)
    _attach_to_group!(sys, component, group, weight, nothing)
    return
end

"""Rule R13: droop members are generators only."""
function add_supplemental_attribute!(
    ::System,
    component::Component,
    group::VoltageDroopControl;
    kwargs...,
)
    throw(
        ArgumentError(
            "$(summary(component)) cannot join VoltageDroopControl $(get_name(group)); " *
            "only generators can be members of a voltage droop controller",
        ),
    )
end

"""
    add_supplemental_attribute!(sys::System, line::TwoTerminalVSCLine, group::ReactivePowerSharing; terminal, weight = 1.0)

Make one converter of `line`, named by `terminal`, a member of the sharing group with relative
reactive power `weight`. Throws `ArgumentError` when the weight is not positive, the terminal
already belongs to a group, or the group already holds the line's other converter.
"""
function add_supplemental_attribute!(
    sys::System,
    line::TwoTerminalVSCLine,
    group::ReactivePowerSharing;
    terminal::Union{Nothing, VoltageControlTerminal.Value} = nothing,
    weight::Float64 = 1.0,
)
    isnothing(terminal) && throw(
        ArgumentError(
            "$(summary(line)) joins $(nameof(typeof(group))) $(get_name(group)) through " *
            "one converter; pass terminal = VoltageControlTerminal.FROM or .TO",
        ),
    )
    _check_weight(group, line, weight)
    _check_single_group(line, group, terminal)
    _attach_to_group!(sys, line, group, weight, terminal)
    return
end

"""
    remove_supplemental_attribute!(sys::System, component::Component, group::VoltageControlGroup)

Remove `component` from the voltage control group, dropping its weight and terminal.
"""
function remove_supplemental_attribute!(
    sys::System,
    component::Component,
    group::VoltageControlGroup,
)
    IS.remove_supplemental_attribute!(sys.data, component, group)
    id = IS.get_id(component)
    delete!(group.weights, id)
    delete!(group.terminals, id)
    return
end

# ── single-component validation ───────────────────────────────────────────────────

"""Rules R1 and R3 for a device with one remote regulated bus."""
function _validate_remote_regulated_bus(device::VoltageControlDevice)
    remote = get_remote_regulated_bus(device)
    isnothing(remote) && return true
    bus = get_bus(device)
    if remote === bus
        @error "$(summary(device)) names its own bus $(get_name(bus)) as " *
               "remote_regulated_bus; local regulation is spelled `nothing`" _group =
            IS.LOG_GROUP_SYSTEM_CHECKS
        return false
    end
    _regulates_another_device(device) && return true
    if get_bustype(remote) == ACBusTypes.REF
        @error "$(summary(device)) regulates the reference bus $(get_name(remote)); the " *
               "reference bus cannot be a remote regulated bus" _group =
            IS.LOG_GROUP_SYSTEM_CHECKS
        return false
    end
    if get_bustype(bus) == ACBusTypes.REF
        @error "$(summary(device)) sits on the reference bus $(get_name(bus)) and cannot " *
               "regulate another bus" _group = IS.LOG_GROUP_SYSTEM_CHECKS
        return false
    end
    return true
end

"""Switched shunt modes that track another device's reactive power name that device's bus,
so the reference-bus rule does not apply to them."""
_regulates_another_device(::VoltageControlDevice) = false
_regulates_another_device(shunt::SwitchedAdmittance) =
    get_control_mode(shunt) in (
        SwitchedAdmittanceControlMode.DISCRETE_REACTIVE_PLANT,
        SwitchedAdmittanceControlMode.DISCRETE_REACTIVE_VSC,
        SwitchedAdmittanceControlMode.DISCRETE_ADMITTANCE_REMOTE,
    )

"""Rule R6: a remote-regulating unit whose own bus is not PV or REF only warns."""
function _warn_remote_bus_type(
    device::Union{
        VoltageControlGenerator,
        EnergyReservoirStorage,
        SynchronousCondenser,
        Source,
    },
)
    remote = get_remote_regulated_bus(device)
    isnothing(remote) && return
    bustype = get_bustype(get_bus(device))
    if bustype ∉ (ACBusTypes.PV, ACBusTypes.REF)
        @warn "$(summary(device)) regulates bus $(get_name(remote)) but its own bus " *
              "$(get_name(get_bus(device))) has bus type $bustype; only a PV or REF bus type " *
              "marks the unit as voltage regulating" _group = IS.LOG_GROUP_SYSTEM_CHECKS
    end
    return
end
_warn_remote_bus_type(::VoltageControlDevice) = nothing

function validate_component(device::VoltageControlDevice)
    is_valid = _validate_remote_regulated_bus(device)
    is_valid && _warn_remote_bus_type(device)
    return is_valid
end

function _validate_vsc_remote_bus(line::TwoTerminalVSCLine, remote, own, side)
    isnothing(remote) && return true
    if remote === own
        @error "$(summary(line)) names its own $side bus $(get_name(own)) as " *
               "remote_regulated_bus_$side; local regulation is spelled `nothing`" _group =
            IS.LOG_GROUP_SYSTEM_CHECKS
        return false
    end
    if get_bustype(remote) == ACBusTypes.REF
        @error "$(summary(line)) regulates the reference bus $(get_name(remote)) from its " *
               "$side converter; the reference bus cannot be a remote regulated bus" _group =
            IS.LOG_GROUP_SYSTEM_CHECKS
        return false
    end
    return true
end

function validate_component(line::TwoTerminalVSCLine)
    arc = get_arc(line)
    from_valid =
        _validate_vsc_remote_bus(
            line,
            get_remote_regulated_bus_from(line),
            get_from(arc),
            "from",
        )
    to_valid =
        _validate_vsc_remote_bus(line, get_remote_regulated_bus_to(line), get_to(arc), "to")
    return from_valid && to_valid
end

const _VOLTAGE_OBJECTIVES = (
    TransformerControlObjective.VOLTAGE,
    TransformerControlObjective.VOLTAGE_DISABLED,
)

"""Rules R4 and R5 for one transformer circuit; `owner` names the transformer in messages."""
function _validate_circuit_control(circuit::TransformerCircuit, owner::AbstractString)
    objective = get_control_objective(circuit)
    bus = get_regulated_bus(circuit)
    side = _get_regulated_bus_side(circuit)
    regulates_voltage = objective in _VOLTAGE_OBJECTIVES
    if regulates_voltage && isnothing(bus)
        @error "$owner circuit has control_objective $objective but no regulated_bus" _group =
            IS.LOG_GROUP_SYSTEM_CHECKS
        return false
    end
    if !regulates_voltage && !isnothing(bus)
        @error "$owner circuit has control_objective $objective, which regulates no " *
               "voltage, but names regulated_bus $(get_name(bus))" _group =
            IS.LOG_GROUP_SYSTEM_CHECKS
        return false
    end
    if !isnothing(bus)
        arc = get_arc(circuit)
        on_arc = bus === get_from(arc) || bus === get_to(arc)
        if on_arc && !isnothing(side)
            @error "$owner circuit regulates its own bus $(get_name(bus)); " *
                   "regulated_bus_side follows from the arc and must be `nothing`" _group =
                IS.LOG_GROUP_SYSTEM_CHECKS
            return false
        end
        if !on_arc && isnothing(side)
            @error "$owner circuit regulates bus $(get_name(bus)), which is neither end " *
                   "of its arc; regulated_bus_side must say which winding it lies beyond" _group =
                IS.LOG_GROUP_SYSTEM_CHECKS
            return false
        end
    elseif !isnothing(side)
        @error "$owner circuit has regulated_bus_side $side but no regulated_bus" _group =
            IS.LOG_GROUP_SYSTEM_CHECKS
        return false
    end
    if !regulates_voltage && !iszero(get_load_drop_compensation(circuit, CU))
        @warn "$owner circuit has a non-zero load_drop_compensation but control_objective " *
              "$objective regulates no voltage; the compensation is ignored" _group =
            IS.LOG_GROUP_SYSTEM_CHECKS
    end
    return true
end

validate_component(transformer::TwoWindingTransformer) =
    _validate_circuit_control(get_circuit(transformer), summary(transformer))

function validate_component(transformer::ThreeWindingTransformer)
    is_valid = true
    for circuit in get_circuits(transformer)
        is_valid &= _validate_circuit_control(circuit, summary(transformer))
    end
    return is_valid
end

"""Whether `line` is capacitor commutated: either converter has a commutating capacitor."""
_is_capacitor_commutated(line::TwoTerminalLCCLine) =
    !iszero(get_rectifier_capacitor_reactance(line)) ||
    !iszero(get_inverter_capacitor_reactance(line))

"""Rule R17: a referenced tap transformer controls the DC line."""
function _validate_lcc_tap_transformer(line::TwoTerminalLCCLine, transformer, side)
    isnothing(transformer) && return true
    objective = get_control_objective(get_circuit(transformer))
    if objective != TransformerControlObjective.CONTROL_OF_DC_LINE
        @error "$(summary(line)) names $(summary(transformer)) as its $side tap " *
               "transformer, but its control_objective is $objective rather than " *
               "CONTROL_OF_DC_LINE" _group = IS.LOG_GROUP_SYSTEM_CHECKS
        return false
    end
    return true
end

function validate_component(line::TwoTerminalLCCLine)
    references = (
        get_rectifier_commutating_bus(line),
        get_inverter_commutating_bus(line),
        get_rectifier_tap_transformer(line),
        get_inverter_tap_transformer(line),
    )
    if _is_capacitor_commutated(line) && any(!isnothing, references)
        @error "$(summary(line)) is capacitor commutated, so its commutating bus and tap " *
               "transformer references must be `nothing`" _group =
            IS.LOG_GROUP_SYSTEM_CHECKS
        return false
    end
    rectifier_valid =
        _validate_lcc_tap_transformer(
            line,
            get_rectifier_tap_transformer(line),
            "rectifier",
        )
    inverter_valid =
        _validate_lcc_tap_transformer(line, get_inverter_tap_transformer(line), "inverter")
    return rectifier_valid && inverter_valid
end

# ── attachment checks (rule R2) ───────────────────────────────────────────────────

_throw_if_reference_not_attached(::Nothing, ::System) = nothing
_throw_if_reference_not_attached(component::Component, sys::System) =
    throw_if_not_attached(component, sys)

function check_attached_buses(sys::System, component::VoltageControlDevice)
    throw_if_not_attached(get_bus(component), sys)
    _throw_if_reference_not_attached(get_remote_regulated_bus(component), sys)
    return
end

function check_attached_buses(sys::System, component::InterconnectingConverter)
    throw_if_not_attached(get_bus(component), sys)
    throw_if_not_attached(get_dc_bus(component), sys)
    _throw_if_reference_not_attached(get_remote_regulated_bus(component), sys)
    return
end

function check_attached_buses(sys::System, line::TwoTerminalVSCLine)
    throw_if_not_attached(get_from_bus(line), sys)
    throw_if_not_attached(get_to_bus(line), sys)
    _throw_if_reference_not_attached(get_remote_regulated_bus_from(line), sys)
    _throw_if_reference_not_attached(get_remote_regulated_bus_to(line), sys)
    return
end

function check_attached_buses(sys::System, transformer::TwoWindingTransformer)
    throw_if_not_attached(get_from_bus(transformer), sys)
    throw_if_not_attached(get_to_bus(transformer), sys)
    _throw_if_reference_not_attached(get_regulated_bus(get_circuit(transformer)), sys)
    return
end

function check_attached_buses(sys::System, line::TwoTerminalLCCLine)
    throw_if_not_attached(get_from_bus(line), sys)
    throw_if_not_attached(get_to_bus(line), sys)
    _throw_if_reference_not_attached(get_rectifier_commutating_bus(line), sys)
    _throw_if_reference_not_attached(get_inverter_commutating_bus(line), sys)
    _throw_if_reference_not_attached(get_rectifier_tap_transformer(line), sys)
    _throw_if_reference_not_attached(get_inverter_tap_transformer(line), sys)
    return
end

# ── bus-wide checks (rules R10, R11, R12, R14), run once from check(sys) ───────────

"""The setpoint of a device compared across the devices regulating one bus, in per-unit of
that bus; `nothing` for a device that holds a band rather than a setpoint."""
_setpoint_for_comparison(device::VoltageControlDevice) = get_voltage_setpoint(device)
_setpoint_for_comparison(::SwitchedAdmittance) = nothing
_setpoint_for_comparison(converter::InterconnectingConverter) = get_ac_setpoint(converter)

"""Setpoint devices that regulate voltage right now, grouped by the bus they resolve to,
skipping members of an available droop controller (their target is the controller's)."""
function _setpoint_devices_by_bus(sys::System)
    by_bus = Dict{ACBus, Vector{Tuple{Component, Union{Nothing, Float64}}}}()
    for device in get_available_components(StaticInjection, sys)
        _is_setpoint_device(device) || continue
        any(get_available, get_supplemental_attributes(VoltageDroopControl, device)) &&
            continue
        push!(
            get!(
                by_bus,
                get_regulated_bus(device),
                Tuple{Component, Union{Nothing, Float64}}[],
            ),
            (device, _setpoint_for_comparison(device)),
        )
    end
    for line in get_available_components(TwoTerminalVSCLine, sys)
        if get_ac_control_from(line) == VSCACControlModes.AC_VOLTAGE
            push!(
                get!(
                    by_bus,
                    get_regulated_bus_from(line),
                    Tuple{Component, Union{Nothing, Float64}}[],
                ),
                (line, get_ac_setpoint_from(line)),
            )
        end
        if get_ac_control_to(line) == VSCACControlModes.AC_VOLTAGE
            push!(
                get!(
                    by_bus,
                    get_regulated_bus_to(line),
                    Tuple{Component, Union{Nothing, Float64}}[],
                ),
                (line, get_ac_setpoint_to(line)),
            )
        end
    end
    return by_bus
end

_member_names(sys::System, group::VoltageControlGroup) =
    join(sort!([get_name(c) for c in get_associated_components(sys, group)]), ", ")

"""
Warn about voltage control arrangements that no single component can see: a sharing group
without two members on one bus (R10), a bus held by several setpoint devices without one
sharing group covering all of them (R11), setpoint devices on one bus that disagree on the
setpoint (R12), and a setpoint device outside an available droop controller holding that
controller's bus (R14). One pass over the devices, grouped by the bus they resolve to.
"""
function check_voltage_control(sys::System)
    by_bus = _setpoint_devices_by_bus(sys)
    for group in get_supplemental_attributes(ReactivePowerSharing, sys)
        members = get_associated_components(sys, group)
        if length(members) < 2
            @warn "ReactivePowerSharing $(get_name(group)) has $(length(members)) member(s); " *
                  "a sharing group splits the reactive power of at least two devices" _group =
                IS.LOG_GROUP_SYSTEM_CHECKS
            continue
        end
        buses = Set{ACBus}()
        for member in members
            union!(buses, _member_regulated_buses(member, group))
        end
        if length(buses) != 1
            @warn "ReactivePowerSharing $(get_name(group)) members $(_member_names(sys, group)) " *
                  "resolve to $(length(buses)) different buses; all members of a sharing " *
                  "group hold the voltage at one bus" _group = IS.LOG_GROUP_SYSTEM_CHECKS
        end
    end
    for (bus, entries) in by_bus
        length(entries) >= 2 || continue
        names = join(sort!([get_name(first(e)) for e in entries]), ", ")
        groups = Set{ReactivePowerSharing}()
        covered = true
        for (device, _) in entries
            device_groups = get_supplemental_attributes(ReactivePowerSharing, device)
            isempty(device_groups) && (covered = false)
            union!(groups, device_groups)
        end
        if !covered || length(groups) != 1
            @warn "bus $(get_name(bus)) is regulated by $names, which do not share one " *
                  "ReactivePowerSharing group; devices holding one bus must share its " *
                  "reactive power through exactly one group" _group =
                IS.LOG_GROUP_SYSTEM_CHECKS
        end
        setpoints = unique(s for (_, s) in entries if !isnothing(s))
        if length(setpoints) > 1
            @warn "bus $(get_name(bus)) is regulated by $names with different " *
                  "voltage_setpoint values $(sort!(setpoints)); devices holding one bus " *
                  "must agree on its voltage" _group = IS.LOG_GROUP_SYSTEM_CHECKS
        end
    end
    for droop in get_supplemental_attributes(VoltageDroopControl, sys)
        get_available(droop) || continue
        bus = get_regulated_bus(droop)
        outsiders = get(by_bus, bus, nothing)
        isnothing(outsiders) && continue
        names = join(sort!([get_name(first(e)) for e in outsiders]), ", ")
        @warn "VoltageDroopControl $(get_name(droop)) regulates bus $(get_name(bus)), which " *
              "$names also hold to a setpoint; a droop-controlled bus has no other setpoint " *
              "devices" _group = IS.LOG_GROUP_SYSTEM_CHECKS
    end
    return
end

"""The buses `member` regulates within `group`: one for a single-bus device, the terminal's
bus for a two-terminal line."""
_member_regulated_buses(member::VoltageControlDevice, ::VoltageControlGroup) =
    (get_regulated_bus(member),)
function _member_regulated_buses(line::TwoTerminalVSCLine, group::VoltageControlGroup)
    terminal = get_terminal(group, line)
    terminal == VoltageControlTerminal.FROM && return (get_regulated_bus_from(line),)
    return (get_regulated_bus_to(line),)
end
