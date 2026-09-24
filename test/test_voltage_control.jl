using Test
using PowerSystems
import InfrastructureSystems as IS
const PSY = PowerSystems

# Fixtures for the remote and shared voltage control model: a handful of buses and the
# device types that regulate voltage to a setpoint. Every helper builds detached components;
# the tests decide what is attached, so a rule that fires on attachment can be observed.

_vc_bus(number, bustype; base_voltage = 138.0) = ACBus(;
    number = number, name = "bus$number", available = true, bustype = bustype,
    angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
    base_voltage = base_voltage,
)

function _vc_system()
    sys = System(100.0)
    buses = [
        _vc_bus(1, ACBusTypes.REF),
        _vc_bus(2, ACBusTypes.PV),
        _vc_bus(3, ACBusTypes.PQ),
        _vc_bus(4, ACBusTypes.PQ),
        _vc_bus(5, ACBusTypes.PV),
    ]
    foreach(b -> add_component!(sys, b), buses)
    return sys, buses
end

_vc_gen(name, bus; kwargs...) = ThermalStandard(;
    name = name, available = true, status = OperationalStates.ONLINE, bus = bus,
    active_power = 0.5, reactive_power = 0.1, rating = 1.0,
    active_power_limits = (min = 0.0, max = 1.0),
    reactive_power_limits = (min = -1.0, max = 1.0),
    ramp_limits = nothing, operation_cost = ThermalGenerationCost(nothing),
    base_power = 100.0, input_basis = CU, kwargs...,
)

_vc_condenser(name, bus; kwargs...) = SynchronousCondenser(;
    name = name, available = true, bus = bus, reactive_power = 0.0, rating = 1.0,
    reactive_power_limits = (min = -1.0, max = 1.0), base_power = 100.0,
    input_basis = CU, kwargs...,
)

_vc_shunt(name, bus; kwargs...) = SwitchedAdmittance(;
    name = name, available = true, bus = bus,
    control_mode = SwitchedAdmittanceControlMode.DISCRETE_VOLTAGE, kwargs...,
)

_vc_facts(name, bus; kwargs...) = FACTSControlDevice(;
    name = name, available = true, bus = bus, control_mode = FACTSOperationModes.NML,
    input_basis = CU, kwargs...,
)

_vc_vsc(name, arc; kwargs...) = TwoTerminalVSCLine(;
    name = name, available = true, arc = arc, active_power_flow = 0.5, rating = 2.0,
    active_power_limits_from = (min = -2.0, max = 2.0),
    active_power_limits_to = (min = -2.0, max = 2.0),
    ac_control_from = VSCACControlModes.AC_VOLTAGE,
    ac_control_to = VSCACControlModes.AC_VOLTAGE,
    rated_dc_voltage = 200.0, base_power = 100.0, input_basis = CU, kwargs...,
)

_vc_lcc(name, arc; kwargs...) = TwoTerminalLCCLine(;
    name = name, available = true, arc = arc, active_power_flow = 0.5, r = 0.01,
    transfer_setpoint = 0.5, scheduled_dc_voltage = 200.0, rectifier_bridges = 2,
    rectifier_delay_angle_limits = (min = 0.1, max = 0.5), rectifier_rc = 0.0,
    rectifier_xc = 0.1, rectifier_base_voltage = 138.0, inverter_bridges = 2,
    inverter_extinction_angle_limits = (min = 0.1, max = 0.5), inverter_rc = 0.0,
    inverter_xc = 0.1, inverter_base_voltage = 138.0, base_power = 100.0,
    input_basis = CU, kwargs...,
)

function _vc_transformer(name, arc; kwargs...)
    circuit = TransformerCircuit(;
        available = true, arc = arc, r = 0.01, x = 0.1, rating = 1.0,
        base_power = 100.0,
        base_voltage_primary = 138.0, base_voltage_secondary = 138.0, input_basis = CU,
        kwargs...,
    )
    return TwoWindingTransformer(; name = name, circuit = circuit, input_basis = CU)
end

"""Assert that `expr` throws `InvalidValue` after logging the error that explains why, so the
error log is accounted for rather than escaping to the test harness."""
macro test_invalid(expr)
    return quote
        @test_logs (:error,) match_mode = :any @test_throws IS.InvalidValue $(esc(expr))
    end
end

_vc_droop(name, bus; kwargs...) = VoltageDroopControl(;
    name = name, regulated_bus = bus,
    reactive_power_limits = (min = -50.0, max = 50.0), deadband_reactive_power = 0.0,
    deadband_voltage_limits = (min = 0.99, max = 1.01),
    voltage_limits = (min = 0.95, max = 1.05),
    kwargs...,
)

@testset "Voltage control enums and new fields" begin
    @test TransformerRegulatedBusSide.CONTROLLING_WINDING isa
          TransformerRegulatedBusSide.Value
    @test TransformerRegulatedBusSide.OPPOSITE_WINDING isa TransformerRegulatedBusSide.Value
    @test TransformerRegulatedBusSide.UNDEFINED isa TransformerRegulatedBusSide.Value
    @test VoltageControlTerminal.UNDEFINED isa VoltageControlTerminal.Value
    @test VoltageControlTerminal.FROM isa VoltageControlTerminal.Value
    @test VoltageControlTerminal.TO isa VoltageControlTerminal.Value

    for T in (
        ThermalStandard, ThermalMultiStart, RenewableDispatch, HydroDispatch, HydroTurbine,
        HydroPumpTurbine, EnergyReservoirStorage, SynchronousCondenser, Source,
    )
        device = T(nothing)
        @test isnothing(get_remote_regulated_bus(device))
        @test get_voltage_setpoint(device) == 1.0
        @test !hasfield(T, :rmpct)
    end
    for T in (SwitchedAdmittance, FACTSControlDevice, InterconnectingConverter)
        @test isnothing(get_remote_regulated_bus(T(nothing)))
        @test !hasfield(T, :regulated_bus_number)
        @test !hasfield(T, :remote_bus_control)
        @test !hasfield(T, :rmpct)
    end
    vsc = TwoTerminalVSCLine(nothing)
    @test isnothing(get_remote_regulated_bus_from(vsc))
    @test isnothing(get_remote_regulated_bus_to(vsc))
    @test !hasfield(TwoTerminalVSCLine, :rmpct_from)

    circuit = TransformerCircuit(nothing)
    @test isnothing(get_regulated_bus(circuit))
    @test get_regulated_bus_side(circuit) == TransformerRegulatedBusSide.UNDEFINED
    @test get_load_drop_compensation_r(circuit, CU) == 0.0
    @test get_load_drop_compensation_x(circuit, CU) == 0.0
    @test !hasfield(TransformerCircuit, :regulated_bus_number)

    lcc = TwoTerminalLCCLine(nothing)
    @test isnothing(get_rectifier_commutating_bus(lcc))
    @test isnothing(get_inverter_commutating_bus(lcc))
    @test isnothing(get_rectifier_tap_transformer(lcc))
    @test isnothing(get_inverter_tap_transformer(lcc))

    # reactive_power_required is a power-family field like ThermalStandard.reactive_power
    facts = FACTSControlDevice(nothing)
    set_reactive_power_required!(facts, 0.25 * CU)
    @test get_reactive_power_required(facts, CU) == 0.25
end

@testset "get_regulated_bus resolves droop, remote and own bus in order" begin
    sys, (b1, b2, b3, b4, b5) = _vc_system()
    gen = _vc_gen("g1", b2)
    add_component!(sys, gen)
    @test get_regulated_bus(gen) === b2

    set_remote_regulated_bus!(gen, b3)
    @test get_regulated_bus(gen) === b3

    droop = _vc_droop("droop", b4)
    add_supplemental_attribute!(sys, gen, droop)
    @test get_regulated_bus(gen) === b4
    set_available!(droop, false)
    @test get_regulated_bus(gen) === b3

    condenser = _vc_condenser("sc", b3; remote_regulated_bus = b4)
    add_component!(sys, condenser)
    @test get_regulated_bus(condenser) === b4
    shunt = _vc_shunt("sh", b3)
    add_component!(sys, shunt)
    @test get_regulated_bus(shunt) === b3

    arc = Arc(b2, b5)
    add_component!(sys, arc)
    vsc = _vc_vsc("vsc", arc; remote_regulated_bus_to = b3)
    add_component!(sys, vsc)
    @test get_regulated_bus_from(vsc) === b2
    @test get_regulated_bus_to(vsc) === b3
end

@testset "get_regulated_bus_side derives the side from the arc" begin
    b1 = _vc_bus(1, ACBusTypes.PQ)
    b2 = _vc_bus(2, ACBusTypes.PQ)
    b3 = _vc_bus(3, ACBusTypes.PQ)
    arc = Arc(b1, b2)
    circuit = TransformerCircuit(;
        available = true, arc = arc,
        control_objective = TransformerControlObjective.VOLTAGE,
        regulated_bus = b1, input_basis = CU,
    )
    @test get_regulated_bus_side(circuit) == TransformerRegulatedBusSide.CONTROLLING_WINDING
    set_regulated_bus!(circuit, b2)
    @test get_regulated_bus_side(circuit) == TransformerRegulatedBusSide.OPPOSITE_WINDING
    set_regulated_bus!(circuit, b3)
    @test get_regulated_bus_side(circuit) == TransformerRegulatedBusSide.UNDEFINED
    set_regulated_bus_side!(circuit, TransformerRegulatedBusSide.CONTROLLING_WINDING)
    @test get_regulated_bus_side(circuit) == TransformerRegulatedBusSide.CONTROLLING_WINDING
    set_regulated_bus!(circuit, nothing)
    set_regulated_bus_side!(circuit, TransformerRegulatedBusSide.UNDEFINED)
    @test get_regulated_bus_side(circuit) == TransformerRegulatedBusSide.UNDEFINED
end

@testset "VoltageDroopControl construction and curve ordering (R15)" begin
    bus = _vc_bus(4, ACBusTypes.PQ)
    droop = _vc_droop("droop", bus)
    @test get_name(droop) == "droop"
    @test get_available(droop)
    @test get_regulated_bus(droop) === bus
    @test get_reactive_power_limits(droop) == (min = -50.0, max = 50.0)
    @test get_deadband_reactive_power(droop) == 0.0
    @test get_deadband_voltage_limits(droop) == (min = 0.99, max = 1.01)
    @test get_voltage_limits(droop) == (min = 0.95, max = 1.05)
    @test isempty(get_weights(droop))
    @test isempty(get_terminals(droop))
    # A deadband of zero width is allowed.
    @test _vc_droop("flat", bus; deadband_voltage_limits = (min = 1.0, max = 1.0)) isa
          VoltageDroopControl

    @test_throws ArgumentError _vc_droop("q", bus; deadband_reactive_power = 50.0)
    @test_throws ArgumentError _vc_droop("q", bus; deadband_reactive_power = -50.0)
    @test_throws ArgumentError _vc_droop(
        "q",
        bus;
        reactive_power_limits = (min = 50.0, max = -50.0),
    )
    @test_throws ArgumentError _vc_droop(
        "v",
        bus;
        voltage_limits = (min = 0.95, max = 1.01),
    )
    @test_throws ArgumentError _vc_droop(
        "v",
        bus;
        deadband_voltage_limits = (min = 1.01, max = 0.99),
    )
    @test_throws ArgumentError _vc_droop(
        "v",
        bus;
        voltage_limits = (min = 0.99, max = 1.05),
    )
end

@testset "Voltage control membership rules (R7, R8, R9, R13)" begin
    sys, (b1, b2, b3, b4, b5) = _vc_system()
    g1 = _vc_gen("g1", b2; remote_regulated_bus = b3)
    g2 = _vc_gen("g2", b5; remote_regulated_bus = b3)
    sc = _vc_condenser("sc", b3)
    foreach(c -> add_component!(sys, c), (g1, g2, sc))

    sharing = ReactivePowerSharing(; name = "share3")
    add_supplemental_attribute!(sys, g1, sharing; weight = 0.4)
    add_supplemental_attribute!(sys, g2, sharing)
    add_supplemental_attribute!(sys, sc, sharing; weight = 2.0)
    @test get_weight(sharing, g1) == 0.4
    @test get_weight(sharing, g2) == 1.0
    @test get_weight(sharing, sc) == 2.0
    @test get_terminal(sharing, g1) == VoltageControlTerminal.UNDEFINED
    @test Set(get_name.(get_associated_components(sys, sharing))) == Set(["g1", "g2", "sc"])
    @test has_supplemental_attributes(g1, ReactivePowerSharing)

    # R9: weights are positive
    other = ReactivePowerSharing(; name = "other")
    g3 = _vc_gen("g3", b2)
    add_component!(sys, g3)
    @test_throws ArgumentError add_supplemental_attribute!(sys, g3, other; weight = 0.0)
    @test_throws ArgumentError add_supplemental_attribute!(sys, g3, other; weight = -1.0)
    @test !has_supplemental_attributes(g3, ReactivePowerSharing)

    # R7: one group of either kind per device
    @test_throws ArgumentError add_supplemental_attribute!(sys, g1, other)
    droop = _vc_droop("droop", b4)
    @test_throws ArgumentError add_supplemental_attribute!(sys, g1, droop)
    add_supplemental_attribute!(sys, g3, droop; weight = 0.5)
    @test get_weight(droop, g3) == 0.5
    @test_throws ArgumentError add_supplemental_attribute!(sys, g3, other)

    # R13: droop members are generators only
    sc2 = _vc_condenser("sc2", b4)
    add_component!(sys, sc2)
    @test_throws ArgumentError add_supplemental_attribute!(sys, sc2, droop)
    shunt = _vc_shunt("sh", b4)
    add_component!(sys, shunt)
    @test_throws ArgumentError add_supplemental_attribute!(sys, shunt, droop)
    # while any setpoint device may share
    add_supplemental_attribute!(sys, shunt, other)
    @test get_weight(other, shunt) == 1.0

    # removal clears the weight
    remove_supplemental_attribute!(sys, g1, sharing)
    @test !has_supplemental_attributes(g1, ReactivePowerSharing)
    @test !haskey(get_weights(sharing), IS.get_id(g1))
    add_supplemental_attribute!(sys, g1, other)
    @test get_weight(other, g1) == 1.0

    # R8: a two-terminal member names its terminal
    arc = Arc(b2, b5)
    add_component!(sys, arc)
    vsc = _vc_vsc("vsc", arc; remote_regulated_bus_from = b3)
    add_component!(sys, vsc)
    @test_throws ArgumentError add_supplemental_attribute!(sys, vsc, sharing)
    add_supplemental_attribute!(
        sys, vsc, sharing; weight = 0.3, terminal = VoltageControlTerminal.FROM,
    )
    @test get_weight(sharing, vsc) == 0.3
    @test get_terminal(sharing, vsc) == VoltageControlTerminal.FROM
    # the same terminal cannot join a second group, and the same group cannot hold both
    @test_throws ArgumentError add_supplemental_attribute!(
        sys, vsc, other; terminal = VoltageControlTerminal.FROM,
    )
    @test_throws ArgumentError add_supplemental_attribute!(
        sys, vsc, sharing; terminal = VoltageControlTerminal.TO,
    )
    # the other terminal may belong to another group
    add_supplemental_attribute!(sys, vsc, other; terminal = VoltageControlTerminal.TO)
    @test get_terminal(other, vsc) == VoltageControlTerminal.TO
    remove_supplemental_attribute!(sys, vsc, sharing)
    @test !haskey(get_terminals(sharing), IS.get_id(vsc))
    # a two-terminal line never joins a droop controller
    @test_throws ArgumentError add_supplemental_attribute!(
        sys, vsc, droop; terminal = VoltageControlTerminal.FROM,
    )
end

@testset "Single-device validation (R1, R2, R3, R6)" begin
    sys, (b1, b2, b3, b4, b5) = _vc_system()
    # R1: the remote bus is never the own bus
    @test_invalid add_component!(sys, _vc_gen("g", b2; remote_regulated_bus = b2))
    @test_invalid add_component!(sys, _vc_shunt("s", b3; remote_regulated_bus = b3))
    @test_invalid add_component!(sys, _vc_facts("f", b3; remote_regulated_bus = b3))
    arc = Arc(b2, b5)
    add_component!(sys, arc)
    @test_invalid add_component!(sys, _vc_vsc("v", arc; remote_regulated_bus_from = b2))
    @test_invalid add_component!(sys, _vc_vsc("v", arc; remote_regulated_bus_to = b5))

    # R2: the remote bus is attached
    detached = _vc_bus(99, ACBusTypes.PQ)
    @test_throws ArgumentError add_component!(
        sys,
        _vc_gen("g", b2; remote_regulated_bus = detached),
    )
    @test_throws ArgumentError add_component!(
        sys,
        _vc_vsc("v", arc; remote_regulated_bus_to = detached),
    )

    # R3: the regulated bus is not the reference bus, and a reference-bus unit has no remote bus
    @test_invalid add_component!(sys, _vc_gen("g", b2; remote_regulated_bus = b1))
    @test_invalid add_component!(sys, _vc_gen("g", b1; remote_regulated_bus = b3))
    @test_invalid add_component!(sys, _vc_facts("f", b3; remote_regulated_bus = b1))
    # shunt modes that track another device are exempt
    plant_shunt = _vc_shunt(
        "sp", b3; control_mode = SwitchedAdmittanceControlMode.DISCRETE_REACTIVE_PLANT,
        remote_regulated_bus = b1,
    )
    add_component!(sys, plant_shunt)
    @test get_remote_regulated_bus(plant_shunt) === b1
    @test_invalid add_component!(sys, _vc_shunt("sv", b3; remote_regulated_bus = b1))

    # a valid remote target attaches and is found by check_components
    gen = _vc_gen("g", b2; remote_regulated_bus = b3)
    add_component!(sys, gen)
    check_components(sys)
    set_remote_regulated_bus!(gen, b2)
    @test_invalid check_components(sys)
    set_remote_regulated_bus!(gen, b3)

    # R6: a remote-regulating unit whose own bus is not PV or REF only warns
    @test_logs (:warn, r"bus type") match_mode = :any add_component!(
        sys, _vc_gen("gpq", b4; remote_regulated_bus = b3),
    )
end

@testset "Transformer circuit control validation (R2, R4, R5)" begin
    sys, (b1, b2, b3, b4, b5) = _vc_system()
    arc = Arc(b2, b3)
    add_component!(sys, arc)
    # R4: regulated_bus is set exactly for the voltage objectives
    @test_invalid add_component!(
        sys,
        _vc_transformer("t", arc; control_objective = TransformerControlObjective.VOLTAGE),
    )
    @test_invalid add_component!(
        sys,
        _vc_transformer(
            "t", arc; control_objective = TransformerControlObjective.FIXED,
            regulated_bus = b3,
        ),
    )
    # R4: the side is stored exactly when the regulated bus is neither arc end
    @test_invalid add_component!(
        sys,
        _vc_transformer(
            "t", arc; control_objective = TransformerControlObjective.VOLTAGE,
            regulated_bus = b3,
            regulated_bus_side = TransformerRegulatedBusSide.OPPOSITE_WINDING,
        ),
    )
    @test_invalid add_component!(
        sys,
        _vc_transformer(
            "t", arc; control_objective = TransformerControlObjective.VOLTAGE,
            regulated_bus = b4,
        ),
    )
    remote = _vc_transformer(
        "t_remote", arc;
        control_objective = TransformerControlObjective.VOLTAGE_DISABLED,
        regulated_bus = b4,
        regulated_bus_side = TransformerRegulatedBusSide.OPPOSITE_WINDING,
    )
    add_component!(sys, remote)
    @test get_regulated_bus_side(get_circuit(remote)) ==
          TransformerRegulatedBusSide.OPPOSITE_WINDING
    local_t = _vc_transformer(
        "t_local", arc; control_objective = TransformerControlObjective.VOLTAGE,
        regulated_bus = b3,
    )
    add_component!(sys, local_t)
    @test get_regulated_bus_side(get_circuit(local_t)) ==
          TransformerRegulatedBusSide.OPPOSITE_WINDING
    check_components(sys)

    # R2: the regulated bus is attached
    detached = _vc_bus(99, ACBusTypes.PQ)
    @test_throws ArgumentError add_component!(
        sys,
        _vc_transformer(
            "t", arc; control_objective = TransformerControlObjective.VOLTAGE,
            regulated_bus = detached,
            regulated_bus_side = TransformerRegulatedBusSide.OPPOSITE_WINDING,
        ),
    )

    # R5: compensation without voltage control only warns
    @test_logs (:warn, r"load drop compensation") match_mode = :any add_component!(
        sys,
        _vc_transformer(
            "t_ldc", arc; control_objective = TransformerControlObjective.FIXED,
            load_drop_compensation_r = 0.01, load_drop_compensation_x = 0.02,
        ),
    )
end

@testset "LCC line reference validation (R2, R16, R17)" begin
    sys, (b1, b2, b3, b4, b5) = _vc_system()
    arc = Arc(b2, b3)
    tap_arc = Arc(b4, b5)
    foreach(a -> add_component!(sys, a), (arc, tap_arc))
    dc_tap = _vc_transformer(
        "dc_tap", tap_arc;
        control_objective = TransformerControlObjective.CONTROL_OF_DC_LINE,
    )
    plain = _vc_transformer("plain", tap_arc)
    foreach(t -> add_component!(sys, t), (dc_tap, plain))

    lcc = _vc_lcc(
        "lcc", arc; rectifier_commutating_bus = b4, inverter_commutating_bus = b5,
        rectifier_tap_transformer = dc_tap,
    )
    add_component!(sys, lcc)
    @test get_rectifier_commutating_bus(lcc) === b4
    @test get_rectifier_tap_transformer(lcc) === dc_tap

    # R17: a referenced tap transformer controls the DC line
    @test_invalid add_component!(
        sys, _vc_lcc("lcc_plain", arc; inverter_tap_transformer = plain),
    )
    # R16: a capacitor-commutated line carries none of the references
    @test_invalid add_component!(
        sys,
        _vc_lcc(
            "lcc_ccc", arc; rectifier_capacitor_reactance = 0.05,
            rectifier_commutating_bus = b4,
        ),
    )
    @test_invalid add_component!(
        sys,
        _vc_lcc(
            "lcc_ccc2", arc; inverter_capacitor_reactance = 0.05,
            inverter_tap_transformer = dc_tap,
        ),
    )
    # R2: references are attached
    detached_bus = _vc_bus(99, ACBusTypes.PQ)
    @test_throws ArgumentError add_component!(
        sys, _vc_lcc("lcc_d", arc; rectifier_commutating_bus = detached_bus),
    )
    detached_tap = _vc_transformer(
        "dt", tap_arc;
        control_objective = TransformerControlObjective.CONTROL_OF_DC_LINE,
    )
    @test_throws ArgumentError add_component!(
        sys, _vc_lcc("lcc_d2", arc; inverter_tap_transformer = detached_tap),
    )
end

@testset "Bus-wide voltage control checks (R10, R11, R12, R14)" begin
    sys, (b1, b2, b3, b4, b5) = _vc_system()
    g1 = _vc_gen("g1", b2; remote_regulated_bus = b3, voltage_setpoint = 1.02)
    g2 = _vc_gen("g2", b5; remote_regulated_bus = b3, voltage_setpoint = 1.02)
    foreach(c -> add_component!(sys, c), (g1, g2))

    # R11: two setpoint devices on one bus need one sharing group holding both
    @test_logs (:warn, r"share") match_mode = :any check(sys)
    sharing = ReactivePowerSharing(; name = "share3")
    add_supplemental_attribute!(sys, g1, sharing)
    @test_logs (:warn, r"share") match_mode = :any check(sys)
    add_supplemental_attribute!(sys, g2, sharing)
    @test_logs min_level = Logging.Warn check_voltage_control(sys)

    # R12: setpoints at one bus agree
    set_voltage_setpoint!(g2, 1.05)
    @test_logs (:warn, r"voltage_setpoint") match_mode = :any check(sys)
    set_voltage_setpoint!(g2, 1.02)

    # R10: a sharing group has two members that resolve to one bus
    lonely = ReactivePowerSharing(; name = "lonely")
    g3 = _vc_gen("g3", b2)
    add_component!(sys, g3)
    add_supplemental_attribute!(sys, g3, lonely)
    @test_logs (:warn, r"lonely") match_mode = :any check(sys)
    g4 = _vc_gen("g4", b5; remote_regulated_bus = b4)
    add_component!(sys, g4)
    add_supplemental_attribute!(sys, g4, lonely)
    @test_logs (:warn, r"lonely") match_mode = :any check(sys)
    remove_supplemental_attribute!(sys, g4, lonely)
    remove_supplemental_attribute!(sys, g3, lonely)

    # R14: nothing outside an available droop controller regulates its bus
    droop = _vc_droop("droop4", b4)
    add_supplemental_attribute!(sys, g3, droop)
    @test_logs (:warn, r"droop4") match_mode = :any check(sys)
    set_available!(droop, false)
    @test_logs min_level = Logging.Warn check_voltage_control(sys)
end

@testset "Voltage control survives the OpenAPI document round trip" begin
    sys, (b1, b2, b3, b4, b5) = _vc_system()
    g1 = _vc_gen("g1", b2; remote_regulated_bus = b3, voltage_setpoint = 1.03)
    g2 = _vc_gen("g2", b5; remote_regulated_bus = b3, voltage_setpoint = 1.03)
    g3 = _vc_gen("g3", b2)
    sc = _vc_condenser("sc", b4)
    shunt = _vc_shunt("sh", b4; remote_regulated_bus = b3)
    facts = _vc_facts("f", b4; remote_regulated_bus = b3, voltage_setpoint = 1.03)
    foreach(c -> add_component!(sys, c), (g1, g2, g3, sc, shunt, facts))
    set_reactive_power_required!(facts, 0.2 * SU)

    arc = Arc(b2, b5)
    tap_arc = Arc(b4, b5)
    lcc_arc = Arc(b3, b4)
    foreach(a -> add_component!(sys, a), (arc, tap_arc, lcc_arc))
    vsc = _vc_vsc("vsc", arc; remote_regulated_bus_from = b3, remote_regulated_bus_to = b4)
    add_component!(sys, vsc)
    remote_t = _vc_transformer(
        "t_remote", tap_arc; control_objective = TransformerControlObjective.VOLTAGE,
        regulated_bus = b3,
        regulated_bus_side = TransformerRegulatedBusSide.CONTROLLING_WINDING,
        load_drop_compensation_r = 0.01, load_drop_compensation_x = 0.02,
    )
    dc_tap = _vc_transformer(
        "dc_tap", tap_arc;
        control_objective = TransformerControlObjective.CONTROL_OF_DC_LINE,
    )
    foreach(t -> add_component!(sys, t), (remote_t, dc_tap))
    lcc = _vc_lcc(
        "lcc", lcc_arc; rectifier_commutating_bus = b2,
        inverter_tap_transformer = dc_tap,
    )
    add_component!(sys, lcc)

    sharing = ReactivePowerSharing(; name = "share3")
    add_supplemental_attribute!(sys, g1, sharing; weight = 0.6)
    add_supplemental_attribute!(sys, g2, sharing; weight = 0.4)
    add_supplemental_attribute!(sys, shunt, sharing; weight = 2.0)
    add_supplemental_attribute!(sys, facts, sharing)
    add_supplemental_attribute!(
        sys, vsc, sharing; weight = 0.25, terminal = VoltageControlTerminal.FROM,
    )
    droop = _vc_droop("droop4", b4; available = false, deadband_reactive_power = 5.0)
    add_supplemental_attribute!(sys, g3, droop; weight = 0.7)

    # The archive form writes on CU only, so it is exercised once.
    for (form, units) in ((:document, CU), (:document, NU), (:archive, CU))
        sys2 = roundtrip_system(sys; form = form, units = units)
        bus(number) = get_component(ACBus, sys2, "bus$number")
        g1_2 = get_component(ThermalStandard, sys2, "g1")
        @test get_remote_regulated_bus(g1_2) === bus(3)
        @test get_voltage_setpoint(g1_2) == 1.03
        @test isnothing(
            get_remote_regulated_bus(get_component(ThermalStandard, sys2, "g3")),
        )
        @test get_remote_regulated_bus(get_component(SwitchedAdmittance, sys2, "sh")) ===
              bus(3)
        facts2 = get_component(FACTSControlDevice, sys2, "f")
        @test get_remote_regulated_bus(facts2) === bus(3)
        @test get_reactive_power_required(facts2, SU) ≈ 0.2
        vsc2 = get_component(TwoTerminalVSCLine, sys2, "vsc")
        @test get_remote_regulated_bus_from(vsc2) === bus(3)
        @test get_remote_regulated_bus_to(vsc2) === bus(4)
        circuit2 = get_circuit(get_component(TwoWindingTransformer, sys2, "t_remote"))
        @test get_regulated_bus(circuit2) === bus(3)
        @test get_regulated_bus_side(circuit2) ==
              TransformerRegulatedBusSide.CONTROLLING_WINDING
        @test get_load_drop_compensation_r(circuit2, CU) ≈ 0.01
        @test get_load_drop_compensation_x(circuit2, CU) ≈ 0.02
        lcc2 = get_component(TwoTerminalLCCLine, sys2, "lcc")
        @test get_rectifier_commutating_bus(lcc2) === bus(2)
        @test isnothing(get_inverter_commutating_bus(lcc2))
        @test get_inverter_tap_transformer(lcc2) ===
              get_component(TwoWindingTransformer, sys2, "dc_tap")
        @test isnothing(get_rectifier_tap_transformer(lcc2))

        sharing2 = only(get_supplemental_attributes(ReactivePowerSharing, sys2))
        @test get_name(sharing2) == "share3"
        members = get_associated_components(sys2, sharing2)
        @test length(members) == 5
        @test get_weight(sharing2, g1_2) == 0.6
        @test get_weight(sharing2, get_component(ThermalStandard, sys2, "g2")) == 0.4
        @test get_weight(sharing2, get_component(SwitchedAdmittance, sys2, "sh")) == 2.0
        @test get_weight(sharing2, facts2) == 1.0
        @test get_weight(sharing2, vsc2) == 0.25
        @test get_terminal(sharing2, vsc2) == VoltageControlTerminal.FROM
        @test get_terminal(sharing2, g1_2) == VoltageControlTerminal.UNDEFINED

        droop2 = only(get_supplemental_attributes(VoltageDroopControl, sys2))
        @test !get_available(droop2)
        @test get_regulated_bus(droop2) === bus(4)
        @test get_reactive_power_limits(droop2) == (min = -50.0, max = 50.0)
        @test get_deadband_reactive_power(droop2) == 5.0
        @test get_deadband_voltage_limits(droop2) == (min = 0.99, max = 1.01)
        @test get_voltage_limits(droop2) == (min = 0.95, max = 1.05)
        g3_2 = get_component(ThermalStandard, sys2, "g3")
        @test only(get_associated_components(sys2, droop2)) === g3_2
        @test get_weight(droop2, g3_2) == 0.7
        set_available!(droop2, true)
        @test get_regulated_bus(g3_2) === bus(4)
    end
end
