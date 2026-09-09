# Field-for-field tests for the OpenAPI export converters — the reverse of
# test_openapi_converters.jl/test_openapi_document.jl. Each per-type testset builds a PSY
# component directly (not via `from_openapi`), exports it, and asserts the resulting PO
# struct's fields, including the exact inverted unit-conversion numbers. The round-trip
# assertions follow the exact specification.

_export_bus(; number = 1, area = nothing, load_zone = nothing, bustype = ACBusTypes.REF) =
    ACBus(;
        number = number, name = "bus$number", available = true, bustype = bustype,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 138.0, area = area, load_zone = load_zone,
    )

"""
A `TwoTerminalVSCLine` on a 100 MVA / 200 kV DC base, with one converter on each DC control
mode so both `dc_setpoint` conversions are exercised at once, and a quadratic loss on the `to`
side to cover the second arm of the `Union{LinearCurve, QuadraticCurve}` field.
"""
_export_vsc(
    arc;
    ac_control_from = VSCACControlModes.AC_REACTIVE_POWER,
    ac_control_to = VSCACControlModes.AC_REACTIVE_POWER,
    dc_control_to = VSCDCControlModes.DC_VOLTAGE,
    rated_dc_voltage = 200.0,
    rated_ac_voltage_from = 0.0,
    rated_ac_voltage_to = 0.0,
) = TwoTerminalVSCLine(;
    name = "vsc1", available = true, arc = arc,
    active_power_flow = 0.5, rating = 2.0,
    active_power_limits_from = (min = -2.0, max = 2.0),
    active_power_limits_to = (min = -2.0, max = 2.0),
    g = 200.0, dc_current = 300.0, reactive_power_from = 0.1,
    dc_control_from = VSCDCControlModes.DC_POWER,
    ac_control_from = ac_control_from,
    dc_setpoint_from = 0.4, ac_setpoint_from = 0.95,
    rated_ac_voltage_from = rated_ac_voltage_from,
    converter_loss_from = LossCurve(LinearCurve(1.2, 0.5), NaturalUnit()),
    max_dc_current_from = 1000.0, rating_from = 2.0,
    reactive_power_limits_from = (min = -1.0, max = 1.0),
    power_factor_weighting_fraction_from = 0.5,
    voltage_limits_from = (min = 0.9, max = 1.1),
    dc_voltage_droop_from = 0.0, reactive_power_to = 0.2,
    dc_control_to = dc_control_to,
    ac_control_to = ac_control_to,
    dc_setpoint_to = 1.02, ac_setpoint_to = 0.98,
    rated_ac_voltage_to = rated_ac_voltage_to,
    converter_loss_to = LossCurve(QuadraticCurve(0.01, 1.1, 0.4), NaturalUnit()),
    max_dc_current_to = 1000.0, rating_to = 2.0,
    reactive_power_limits_to = (min = -1.0, max = 1.0),
    power_factor_weighting_fraction_to = 0.5,
    voltage_limits_to = (min = 0.9, max = 1.1),
    dc_voltage_droop_to = 0.0, rated_dc_voltage = rated_dc_voltage,
    remote_bus_control_from = nothing, remote_bus_control_to = 2,
    rmpct_from = 100.0, rmpct_to = 100.0, base_power = 100.0,
)

@testset "OpenAPI export converters: ACBus / Area / LoadZone / Arc" begin
    area = Area(; name = "area1", peak_active_power = 2.5, peak_reactive_power = 0.5)
    lz = LoadZone(; name = "lz1", peak_active_power = 2.5, peak_reactive_power = 0.5)
    bus1 = _export_bus(; number = 1, area = area, load_zone = lz)
    bus2 = _export_bus(; number = 2, area = area, load_zone = lz, bustype = ACBusTypes.PQ)

    sys = System(100.0)
    add_component!(sys, area)
    add_component!(sys, lz)
    add_component!(sys, bus1)
    add_component!(sys, bus2)
    arc = Arc(; from = bus1, to = bus2)
    add_component!(sys, arc)

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = area
    refs[2] = lz
    refs[3] = bus1
    refs[4] = bus2
    refs[5] = arc

    expected_peak(::DeviceBaseUnit, pu) = pu
    expected_peak(::NaturalUnit, pu) = pu * 100.0

    for val in (DU, NU)
        area_po = PSY.to_openapi(area, refs, val)
        @test area_po.id == 1
        @test area_po.name == "area1"
        @test area_po.peak_active_power == expected_peak(val, 2.5)
        @test area_po.peak_reactive_power == expected_peak(val, 0.5)
        @test area_po.load_response == 0.0
        @test area_po.power_units == PSY._power_units_string(val)

        lz_po = PSY.to_openapi(lz, refs, val)
        @test lz_po.peak_active_power == expected_peak(val, 2.5)
        @test lz_po.peak_reactive_power == expected_peak(val, 0.5)
        @test lz_po.power_units == PSY._power_units_string(val)

        bus_po = PSY.to_openapi(bus1, refs, val)
        @test bus_po.id == 3
        @test bus_po.number == 1
        @test bus_po.bustype == "REF"
        @test bus_po.area == 1
        @test bus_po.load_zone == 2

        arc_po = PSY.to_openapi(arc, refs, val)
        @test arc_po.from_id == 3
        @test arc_po.to_id == 4
    end
end

@testset "OpenAPI export converters: Line" begin
    bus1 = _export_bus(; number = 1)
    bus2 = _export_bus(; number = 2, bustype = ACBusTypes.PQ)
    arc = Arc(; from = bus1, to = bus2)
    line = Line(;
        name = "line1", available = true, active_power_flow = 0.1,
        reactive_power_flow = 0.02,
        arc = arc, r = 0.01, x = 0.1, b = (from = 0.001, to = 0.002), rating = 1.75,
        angle_limits = (min = -1.57, max = 1.57), rating_b = 1.75, rating_c = nothing,
        g = (from = 0.0, to = 0.0),
    )
    sys = System(100.0)
    add_component!(sys, bus1)
    add_component!(sys, bus2)
    add_component!(sys, arc)
    add_component!(sys, line)

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus1
    refs[2] = bus2
    refs[3] = arc
    refs[4] = line

    device_po = PSY.to_openapi(line, refs, DU)
    @test device_po.rating == 1.75
    @test device_po.active_power_flow == 0.1
    @test device_po.base_power == 100.0
    @test isnothing(device_po.rating_c)

    natural_po = PSY.to_openapi(line, refs, NU)
    @test natural_po.rating == 175.0
    @test natural_po.active_power_flow == 10.0
    @test natural_po.reactive_power_flow == 2.0
    @test natural_po.rating_b == 175.0
    @test isnothing(natural_po.rating_c)
    @test natural_po.r == 0.01
    @test natural_po.b.from == 0.001
    @test natural_po.base_power == PSY.get_base_power(refs)
end

@testset "OpenAPI export converters: TransformerCircuit / TwoWindingTransformer" begin
    bus1 = _export_bus(; number = 1)
    bus2 = _export_bus(; number = 2, bustype = ACBusTypes.PQ)
    arc = Arc(; from = bus1, to = bus2)
    circuit = TransformerCircuit(;
        available = true, arc = arc, tap = 1.0, α = 0.05, r = 0.01, x = 0.1,
        control_objective = TransformerControlObjective.UNDEFINED,
        regulated_bus_number = 0,
        control_limits = (min = 0.9, max = 1.1),
        controlled_quantity_limits = (min = 0.9, max = 1.1),
        number_of_tap_positions = 33, rating = 2.0, rating_b = nothing,
        rating_c = nothing,
        active_power_flow = 0.1, reactive_power_flow = 0.02, base_power = 50.0,
        base_voltage_primary = 138.0, base_voltage_secondary = 69.0,
    )
    xfmr = TwoWindingTransformer(;
        name = "xfmr1", circuit = circuit,
        magnetizing_shunt = Complex(0.01, 0.02),
        shunt_location = TwoWindingTransformerShuntLocation.PRIMARY,
    )
    sys = System(100.0)
    add_component!(sys, bus1)
    add_component!(sys, bus2)
    add_component!(sys, arc)
    add_component!(sys, xfmr)

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus1
    refs[2] = bus2
    refs[3] = arc
    refs[4] = circuit
    refs[5] = xfmr

    circuit_natural = PSY.to_openapi(circuit, refs, NU)
    @test circuit_natural.alpha == 0.05
    @test circuit_natural.r == 0.01
    @test circuit_natural.rating == 100.0
    @test isnothing(circuit_natural.rating_b)
    @test circuit_natural.active_power_flow == 5.0
    @test circuit_natural.control_objective == "UNDEFINED"
    @test circuit_natural.parameter_units == "COMPONENT_BASE"

    circuit_device = PSY.to_openapi(circuit, refs, DU)
    @test circuit_device.rating == 2.0
    @test circuit_device.active_power_flow == 0.1

    for val in (DU, NU)
        xfmr_po = PSY.to_openapi(xfmr, refs, val)
        @test xfmr_po.circuit == 4
        @test xfmr_po.magnetizing_shunt.real == 0.01
        @test xfmr_po.magnetizing_shunt.imag == 0.02
        @test xfmr_po.shunt_location == "PRIMARY"
    end
end

@testset "OpenAPI export converters: TransmissionInterface" begin
    bus1 = _export_bus(; number = 1)
    line = Line(;
        name = "line1", available = true, active_power_flow = 0.1,
        reactive_power_flow = 0.02, arc = Arc(; from = bus1, to = bus1), r = 0.01,
        x = 0.1, b = (from = 0.0, to = 0.0), rating = 1.0,
        angle_limits = (min = -1.57, max = 1.57),
    )
    tx = TransmissionInterface(; name = "iface1", available = true,
        active_power_flow_limits = (min = -10.0, max = 10.0),
        violation_penalty = 5000.0,
        direction_mapping = Dict("line1" => 1),
    )
    sys = System(100.0)
    add_component!(sys, bus1)
    add_component!(sys, get_arc(line))
    add_component!(sys, line)
    add_service!(sys, tx, [line])

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus1
    refs[2] = get_arc(line)
    refs[3] = line
    refs[4] = tx

    expected_limits(::DeviceBaseUnit) = (min = -10.0, max = 10.0)
    expected_limits(::NaturalUnit) = (min = -1000.0, max = 1000.0)

    for val in (DU, NU)
        tx_po = PSY.to_openapi(tx, refs, val)
        @test tx_po.id == 4
        limits = expected_limits(val)
        @test tx_po.active_power_flow_limits.min == limits.min
        @test tx_po.active_power_flow_limits.max == limits.max
        @test tx_po.violation_penalty == 5000.0
        @test tx_po.direction_mapping == Dict("line1" => 1)
        @test tx_po.power_units == PSY._power_units_string(val)

        # Round-trip: import(export(x)) == x.
        round_tripped = PSY.from_openapi(tx_po, refs, val)
        @test get_active_power_flow_limits(round_tripped, DU) ==
              get_active_power_flow_limits(tx, DU)
    end
end

@testset "OpenAPI export converters: ThreeWindingTransformer" begin
    bus1 = _export_bus(; number = 1)
    bus2 = _export_bus(; number = 2, bustype = ACBusTypes.PQ)
    bus3 = _export_bus(; number = 3, bustype = ACBusTypes.PQ)
    star = _export_bus(; number = 901, bustype = ACBusTypes.PQ)
    arc1 = Arc(; from = bus1, to = star)
    arc2 = Arc(; from = bus2, to = star)
    arc3 = Arc(; from = bus3, to = star)

    t3w = ThreeWindingTransformer(nothing)
    set_name!(t3w, "t3w1")
    set_arc!(get_primary_circuit(t3w), arc1)
    set_arc!(get_secondary_circuit(t3w), arc2)
    set_arc!(get_tertiary_circuit(t3w), arc3)
    foreach(c -> set_available!(c, true), get_circuits(t3w))
    set_star_bus!(t3w, star)
    set_r_12!(t3w, 0.01 * DU)
    set_x_12!(t3w, 0.1 * DU)
    set_r_23!(t3w, 0.015 * DU)
    set_x_23!(t3w, 0.15 * DU)
    set_r_31!(t3w, 0.02 * DU)
    set_x_31!(t3w, 0.2 * DU)
    set_base_power_12!(t3w, 100.0)
    set_base_power_23!(t3w, 100.0)
    set_base_power_31!(t3w, 100.0)
    set_magnetizing_shunt!(t3w, (0.03 + 0.0im) * DU)
    set_shunt_location!(t3w, ThreeWindingTransformerShuntLocation.STAR)

    sys = System(100.0)
    for b in (bus1, bus2, bus3, star)
        add_component!(sys, b)
    end
    foreach(a -> add_component!(sys, a), (arc1, arc2, arc3))
    add_component!(sys, t3w)

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus1
    refs[2] = bus2
    refs[3] = bus3
    refs[4] = star
    refs[5] = arc1
    refs[6] = arc2
    refs[7] = arc3
    refs[8] = get_primary_circuit(t3w)
    refs[9] = get_secondary_circuit(t3w)
    refs[10] = get_tertiary_circuit(t3w)
    refs[11] = t3w

    for val in (DU, NU)
        t3w_po = PSY.to_openapi(t3w, refs, val)
        @test t3w_po.primary_circuit == 8
        @test t3w_po.secondary_circuit == 9
        @test t3w_po.tertiary_circuit == 10
        @test t3w_po.star_bus == 4
        @test t3w_po.parameter_units == "COMPONENT_BASE"
        @test t3w_po.r_12 == 0.01
        @test t3w_po.r_31 == 0.02
        @test t3w_po.base_power_23 == 100.0
        @test t3w_po.admittance_units == "COMPONENT_BASE"
        @test t3w_po.magnetizing_shunt.real == 0.03
        @test t3w_po.shunt_location == "STAR"
    end
end

@testset "OpenAPI export converters: FixedAdmittance" begin
    bus1 = _export_bus(; number = 1)
    shunt = FixedAdmittance(;
        name = "shunt1", available = true, bus = bus1, Y = Complex(0.0, -1.0),
    )
    sys = System(100.0)
    add_component!(sys, bus1)
    add_component!(sys, shunt)

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus1
    refs[2] = shunt

    # The wire enum has no system-base member, so PSY's system-base pu Y rides as
    # COMPONENT_MVAR (MVAr at unity voltage) scaled by the document's system base —
    # the same value regardless of the document's unit_system.
    for val in (DU, NU)
        shunt_po = PSY.to_openapi(shunt, refs, val)
        @test shunt_po.id == 2
        @test shunt_po.bus == 1
        @test shunt_po.admittance_units == "COMPONENT_MVAR"
        @test shunt_po.Y.real == 0.0
        @test shunt_po.Y.imag == -100.0

        # Round-trip: import(export(x)) == x.
        round_tripped = PSY.from_openapi(shunt_po, refs, val)
        @test get_Y(round_tripped) == get_Y(shunt)
    end
end

@testset "OpenAPI export converters: TwoTerminalGenericHVDCLine" begin
    bus1 = _export_bus(; number = 1)
    bus2 = _export_bus(; number = 2, bustype = ACBusTypes.PQ)
    arc = Arc(; from = bus1, to = bus2)
    hvdc = TwoTerminalGenericHVDCLine(;
        name = "hvdc1", available = true, active_power_flow = 0.5, arc = arc,
        active_power_limits_from = (min = -1.0, max = 1.0),
        active_power_limits_to = (min = -1.0, max = 1.0),
        reactive_power_limits_from = (min = -0.5, max = 0.5),
        reactive_power_limits_to = (min = -0.5, max = 0.5),
        loss = LossCurve(LinearCurve(0.01, 0.0), NaturalUnit()),
    )
    sys = System(100.0)
    add_component!(sys, bus1)
    add_component!(sys, bus2)
    add_component!(sys, arc)
    add_component!(sys, hvdc)

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus1
    refs[2] = bus2
    refs[3] = arc
    refs[4] = hvdc

    natural_po = PSY.to_openapi(hvdc, refs, NU)
    @test natural_po.active_power_flow == 50.0
    @test natural_po.active_power_limits_from.min == -100.0
    @test natural_po.reactive_power_limits_to.max == 50.0
    @test natural_po.loss.value.function_data.value.proportional_term == 0.01

    device_po = PSY.to_openapi(hvdc, refs, DU)
    @test device_po.active_power_flow == 0.5
    @test device_po.active_power_limits_from.min == -1.0
end

@testset "OpenAPI export converters: TModelHVDCLine" begin
    # Exception among the branches: `active_power_flow`/`active_power_limits_from/to`
    # declare x-unit "MW" outright, fixed natural units with no `power_units` discriminator
    # and no `base_power` field — same posture as reserves' `requirement`. Both export
    # methods multiply by `get_base_power(refs)` and are identical; `base_current` (not a
    # power base) is `r`/`l`/`c`'s own anchor and rides through untouched.
    dcbus1 = DCBus(;
        number = 1, name = "dcbus1", available = true,
        magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1), base_voltage = 500.0,
    )
    dcbus2 = DCBus(;
        number = 2, name = "dcbus2", available = true,
        magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1), base_voltage = 500.0,
    )
    arc = Arc(; from = dcbus1, to = dcbus2)
    tmodel = TModelHVDCLine(;
        name = "tmodel1", available = true, active_power_flow = 0.5, arc = arc,
        r = 0.01, l = 0.02, c = 0.03,
        active_power_limits_from = (min = -1.0, max = 1.0),
        active_power_limits_to = (min = -1.0, max = 1.0),
        base_current = 200.0,
    )
    sys = System(250.0)
    add_component!(sys, dcbus1)
    add_component!(sys, dcbus2)
    add_component!(sys, arc)
    add_component!(sys, tmodel)

    refs = PSY.OpenAPIRefs(250.0)
    refs[1] = dcbus1
    refs[2] = dcbus2
    refs[3] = arc
    refs[4] = tmodel

    natural_po = PSY.to_openapi(tmodel, refs, NU)
    @test !hasfield(typeof(natural_po), :power_units)
    @test !hasfield(typeof(natural_po), :base_power)
    @test natural_po.active_power_flow == 125.0
    @test natural_po.active_power_limits_from.min == -250.0
    @test natural_po.active_power_limits_to.max == 250.0
    @test natural_po.base_current == 200.0

    device_po = PSY.to_openapi(tmodel, refs, DU)
    @test device_po.active_power_flow == 125.0
    @test device_po.active_power_limits_from.min == -250.0
    @test device_po.base_current == 200.0
end

@testset "OpenAPI export converters: AreaInterchange (generated import, hand-written export)" begin
    # Codegen emits only `from_openapi` (see export_generated_types.jl's header); `to_openapi`
    # for this newly openapi_type-annotated struct is hand-written here to match exactly
    # what such a generator would emit, same as every other generated-import type in
    # export_generated_types.jl.
    area1 = Area(; name = "area1")
    area2 = Area(; name = "area2")
    interchange = AreaInterchange(;
        name = "flow12", available = true, active_power_flow = 0.25,
        from_area = area1, to_area = area2,
        flow_limits = (from_to = 1.0, to_from = -1.0),
    )
    sys = System(100.0)
    add_component!(sys, area1)
    add_component!(sys, area2)
    add_component!(sys, interchange)

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = area1
    refs[2] = area2
    refs[3] = interchange

    device_po = PSY.to_openapi(interchange, refs, DU)
    @test device_po.active_power_flow == 0.25
    @test device_po.flow_limits.from_to == 1.0
    @test device_po.flow_limits.to_from == -1.0
    @test device_po.base_power == 100.0

    natural_po = PSY.to_openapi(interchange, refs, NU)
    @test natural_po.active_power_flow == 25.0
    @test natural_po.flow_limits.from_to == 100.0
    @test natural_po.flow_limits.to_from == -100.0
    @test natural_po.base_power == 100.0

    # Round trip through the generated `from_openapi` reproduces the original component.
    import_refs = PSY.OpenAPIRefs(100.0)
    import_refs[1] = area1
    import_refs[2] = area2
    reimported =
        PSY.from_openapi(device_po, import_refs, DU)
    @test get_active_power_flow(reimported, PSY.DU) ==
          get_active_power_flow(interchange, SU)
    @test get_flow_limits(reimported, PSY.DU) == get_flow_limits(interchange, SU)
end

@testset "OpenAPI export converters: ThermalStandard / PowerLoad" begin
    bus = _export_bus(; number = 1)
    cost = ThermalGenerationCost(;
        variable_operation_cost = CostCurve(;
            value_curve = InputOutputCurve(LinearFunctionData(10.0, 5.0)),
        ),
        fixed = 100.0, start_up = 200.0, shut_down = 50.0,
    )
    gen = ThermalStandard(;
        name = "gen1", available = true, status = true, bus = bus,
        active_power = 0.25, reactive_power = 0.05, rating = 0.5,
        active_power_limits = (min = 0.05, max = 0.5),
        reactive_power_limits = (min = -0.25, max = 0.25),
        ramp_limits = (up = 0.1, down = 0.1), operation_cost = cost, base_power = 200.0,
        time_limits = (up = 2.0, down = 2.0), must_run = false,
        prime_mover_type = PrimeMovers.OT, fuel = ThermalFuels.NATURAL_GAS,
        time_at_status = 100.0,
    )
    load = PowerLoad(;
        name = "load1", available = true, bus = bus, active_power = 0.3,
        reactive_power = 0.05,
        base_power = 100.0, max_active_power = 0.5, max_reactive_power = 0.1,
        conformity = LoadConformity.CONFORMING,
    )
    sys = System(100.0)
    add_component!(sys, bus)
    add_component!(sys, gen)
    add_component!(sys, load)

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus
    refs[2] = gen
    refs[3] = load

    gen_natural = PSY.to_openapi(gen, refs, NU)
    @test gen_natural.active_power == 50.0
    @test gen_natural.rating == 100.0
    @test gen_natural.active_power_limits.min == 10.0
    @test gen_natural.active_power_limits.max == 100.0
    @test gen_natural.prime_mover_type == "OT"
    @test gen_natural.fuel == "NATURAL_GAS"
    @test gen_natural.operation_cost.fixed == 100.0

    gen_device = PSY.to_openapi(gen, refs, DU)
    @test gen_device.active_power == 0.25
    @test gen_device.rating == 0.5

    load_natural = PSY.to_openapi(load, refs, NU)
    @test load_natural.active_power == 30.0
    @test load_natural.max_active_power == 50.0
    @test load_natural.conformity == "CONFORMING"

    load_device = PSY.to_openapi(load, refs, DU)
    @test load_device.active_power == 0.3
end

@testset "OpenAPI export converters: InterruptiblePowerLoad / ShiftablePowerLoad" begin
    bus = _export_bus(; number = 1)
    cost = LoadCost(CostCurve(LinearCurve(150.0)), 2400.0)
    iload = InterruptiblePowerLoad(
        "iload1", true, bus, 0.3, 0.05, 0.3, 0.05, 100.0, cost,
    )
    sload = ShiftablePowerLoad(
        "sload1", true, bus, 0.3, (min = 0.03, max = 0.3), 0.05, 0.3, 0.05, 100.0, 24,
        cost,
    )
    sys = System(100.0)
    add_component!(sys, bus)
    add_component!(sys, iload)
    add_component!(sys, sload)

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus
    refs[2] = iload
    refs[3] = sload

    iload_natural = PSY.to_openapi(iload, refs, NU)
    @test iload_natural.active_power == 30.0
    @test iload_natural.max_active_power == 30.0
    @test iload_natural.conformity == "UNDEFINED"
    @test iload_natural.operation_cost.fixed == 2400.0

    iload_device = PSY.to_openapi(iload, refs, DU)
    @test iload_device.active_power == 0.3

    sload_natural = PSY.to_openapi(sload, refs, NU)
    @test sload_natural.active_power == 30.0
    @test sload_natural.active_power_limits.min == 3.0
    @test sload_natural.active_power_limits.max == 30.0
    @test sload_natural.load_balance_time_horizon == 24

    sload_device = PSY.to_openapi(sload, refs, DU)
    @test sload_device.active_power_limits.min == 0.03
end

@testset "OpenAPI export converters: Hydro / Renewable / SynchronousCondenser / EnergyReservoirStorage" begin
    bus = _export_bus(; number = 1)
    hydro_cost = HydroGenerationCost(;
        fixed = 1.0,
        variable_operation_cost = CostCurve(;
            value_curve = InputOutputCurve(LinearFunctionData(1.0, 0.0)),
        ),
    )
    turbine = HydroTurbine(;
        name = "turb1", available = true, bus = bus, active_power = 0.2,
        reactive_power = 0.05,
        rating = 0.5, active_power_limits = (min = 0.0, max = 0.5),
        reactive_power_limits = (min = -0.2, max = 0.2), base_power = 100.0,
        operation_cost = hydro_cost, powerhouse_elevation = 100.0,
        ramp_limits = (up = 0.1, down = 0.1), time_limits = (up = 1.0, down = 1.0),
        outflow_limits = (min = 0.0, max = 500.0), efficiency = 0.9,
        turbine_type = HydroTurbineType.FRANCIS, conversion_factor = 1.0,
        prime_mover_type = PrimeMovers.HY, travel_time = 5.0,
    )
    ror = HydroDispatch(;
        name = "ror1", available = true, bus = bus, active_power = 0.15,
        reactive_power = 0.03,
        rating = 0.4, prime_mover_type = PrimeMovers.HY,
        active_power_limits = (min = 0.0, max = 0.4),
        reactive_power_limits = (min = -0.15, max = 0.15),
        ramp_limits = (up = 0.1, down = 0.1), time_limits = (up = 1.0, down = 1.0),
        base_power = 100.0, status = true, time_at_status = 50.0,
        operation_cost = hydro_cost,
    )
    ren_cost = RenewableGenerationCost(;
        variable_operation_cost = CostCurve(;
            value_curve = InputOutputCurve(LinearFunctionData(0.0, 0.0)),
        ),
    )
    wind = RenewableDispatch(;
        name = "wind1", available = true, bus = bus, active_power = 0.25,
        reactive_power = 0.05,
        rating = 0.5, prime_mover_type = PrimeMovers.WT,
        reactive_power_limits = (min = -0.2, max = 0.2), power_factor = 0.95,
        operation_cost = ren_cost, base_power = 100.0,
    )
    solar = RenewableNonDispatch(;
        name = "solar1", available = true, bus = bus, active_power = 0.15,
        reactive_power = 0.02,
        rating = 0.3, prime_mover_type = PrimeMovers.PVe, power_factor = 0.98,
        base_power = 100.0,
    )
    condenser = SynchronousCondenser(;
        name = "syncon1", available = true, bus = bus, reactive_power = 0.05,
        rating = 0.2,
        reactive_power_limits = (min = -0.2, max = 0.2), base_power = 100.0,
        active_power_losses = 0.01,
    )
    storage_cost = StorageCost(; fixed = 0.0, shut_down = 0.0, start_up = 0.0)
    storage = EnergyReservoirStorage(;
        name = "storage1", available = true, bus = bus,
        prime_mover_type = PrimeMovers.BA,
        storage_technology_type = StorageTech.LIB, storage_capacity = 2.0,
        storage_level_limits = (min = 0.0, max = 1.0),
        initial_storage_capacity_level = 0.5,
        rating = 0.5, active_power = 0.1,
        input_active_power_limits = (min = 0.0, max = 0.5),
        output_active_power_limits = (min = 0.0, max = 0.5),
        efficiency = (in = 0.9, out = 0.9),
        reactive_power = 0.025, reactive_power_limits = (min = -0.25, max = 0.25),
        base_power = 200.0, operation_cost = storage_cost, conversion_factor = 1.0,
        storage_target = 0.5, cycle_limits = 10000,
        ramp_limits = (up = 0.5, down = 0.5),
        self_discharge = 0.0, standing_loss = 0.01,
    )

    sys = System(100.0)
    add_component!(sys, bus)
    for c in (turbine, ror, wind, solar, condenser, storage)
        add_component!(sys, c)
    end

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus
    refs[2] = turbine
    refs[3] = ror
    refs[4] = wind
    refs[5] = solar
    refs[6] = condenser
    refs[7] = storage

    turbine_natural = PSY.to_openapi(turbine, refs, NU)
    @test turbine_natural.active_power == 20.0
    @test turbine_natural.rating == 50.0
    @test turbine_natural.turbine_type == "FRANCIS"
    @test turbine_natural.operation_cost.fixed == 1.0

    ror_natural = PSY.to_openapi(ror, refs, NU)
    @test ror_natural.active_power == 15.0
    @test ror_natural.rating == 40.0

    wind_natural = PSY.to_openapi(wind, refs, NU)
    @test wind_natural.active_power == 25.0
    @test wind_natural.rating == 50.0
    @test wind_natural.prime_mover_type == "WT"
    @test wind_natural.power_factor == 0.95

    solar_natural = PSY.to_openapi(solar, refs, NU)
    @test solar_natural.active_power == 15.0
    @test solar_natural.rating == 30.0

    condenser_natural = PSY.to_openapi(condenser, refs, NU)
    @test condenser_natural.reactive_power == 5.0
    @test condenser_natural.rating == 20.0
    @test condenser_natural.active_power_losses == 1.0

    storage_natural = PSY.to_openapi(storage, refs, NU)
    @test storage_natural.storage_capacity == 400.0
    @test storage_natural.rating == 100.0
    @test storage_natural.active_power == 20.0
    @test storage_natural.input_active_power_limits.max == 100.0
    @test storage_natural.reactive_power_limits.min == -50.0
    @test storage_natural.ramp_limits.up == 100.0
    @test storage_natural.standing_loss == 2.0
    @test storage_natural.storage_technology_type == "LIB"
    @test storage_natural.energy_units == "MWH"

    storage_device = PSY.to_openapi(storage, refs, DU)
    @test storage_device.storage_capacity == 2.0
    @test storage_device.rating == 0.5
end

@testset "OpenAPI export converters: HydroReservoir" begin
    bus = _export_bus(; number = 1)
    hydro_cost = HydroGenerationCost(;
        fixed = 1.0,
        variable_operation_cost = CostCurve(;
            value_curve = InputOutputCurve(LinearFunctionData(1.0, 0.0)),
        ),
    )
    turbine = HydroTurbine(;
        name = "turb1", available = true, bus = bus, active_power = 0.2,
        reactive_power = 0.05,
        rating = 0.5, active_power_limits = (min = 0.0, max = 0.5),
        reactive_power_limits = (min = -0.2, max = 0.2), base_power = 100.0,
        operation_cost = hydro_cost,
    )
    reservoir = HydroReservoir(;
        name = "reservoir1", available = true,
        storage_level_limits = (min = 0.0, max = 1000.0),
        initial_level = 0.5, spillage_limits = (min = 0.0, max = 100.0), inflow = 10.0,
        outflow = 8.0, level_targets = 0.6, intake_elevation = 50.0,
        head_to_volume_factor = LinearFunctionData(0.001, 0.0),
        upstream_turbines = PSY.HydroUnit[turbine],
        downstream_turbines = PSY.HydroUnit[],
        upstream_reservoirs = Device[],
        operation_cost = HydroReservoirCost(;
            level_shortage_cost = 1.0, level_surplus_cost = 2.0, spillage_cost = 3.0,
        ),
        evaporative_loss = 0.0, level_data_type = ReservoirDataType.USABLE_VOLUME,
    )
    reservoir_no_assoc = HydroReservoir(;
        name = "reservoir2", available = true,
        storage_level_limits = (min = 0.0, max = 1000.0),
        initial_level = 0.5, spillage_limits = nothing, inflow = 10.0, outflow = 8.0,
        level_targets = nothing, intake_elevation = 50.0,
        head_to_volume_factor = LinearFunctionData(0.001, 0.0),
        operation_cost = HydroReservoirCost(nothing),
    )

    sys = System(100.0)
    add_component!(sys, bus)
    add_component!(sys, turbine)
    add_component!(sys, reservoir)
    add_component!(sys, reservoir_no_assoc)

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus
    refs[2] = turbine
    refs[3] = reservoir
    refs[4] = reservoir_no_assoc

    for val in (DU, NU)
        po = PSY.to_openapi(reservoir, refs, val)
        @test po.initial_level == 500.0
        @test po.level_targets == 600.0
        @test po.inflow == 10.0
        @test po.upstream_turbines == [2]
        @test po.level_data_type == "USABLE_VOLUME"
        @test po.operation_cost.level_shortage_cost == 1.0

        po_empty = PSY.to_openapi(reservoir_no_assoc, refs, val)
        @test isnothing(po_empty.upstream_turbines)
        @test isnothing(po_empty.upstream_reservoirs)
        @test isnothing(po_empty.level_targets)
        @test isnothing(po_empty.spillage_limits)
    end
end

@testset "OpenAPI export converters: reserves" begin
    up_reserve = OnlineReserve{ReserveUp}(;
        name = "spin_up", available = true, time_frame = 10.0, requirement = 1.0,
        variable = PSY.ZERO_OFFER_CURVE, sustained_time = 60.0,
        max_output_fraction = 1.0,
        max_participation_factor = 1.0, deployed_fraction = 1.0,
    )
    down_reserve = OnlineReserve{ReserveDown}(;
        name = "spin_down", available = true, time_frame = 10.0, requirement = 0.5,
        sustained_time = 60.0, max_output_fraction = 1.0,
        max_participation_factor = 1.0,
        deployed_fraction = 1.0,
    )
    offline_reserve = OfflineReserve(;
        name = "nonspin", available = true, time_frame = 10.0, requirement = 0.5,
        sustained_time = 60.0, max_output_fraction = 1.0,
        max_participation_factor = 1.0,
        deployed_fraction = 1.0,
    )
    group =
        GroupReserve{ReserveUp}(; name = "group_up", available = true, requirement = 1.5)

    ordc_reserve = OnlineReserve{ReserveUp}(;
        name = "spin_ordc", available = true, time_frame = 10.0, requirement = 1.0,
        variable = CostCurve(;
            value_curve = IncrementalCurve(;
                function_data = PiecewiseStepData([0.0, 100.0], [10.0]),
                initial_input = 0.0,
            ),
        ),
        sustained_time = 60.0, max_output_fraction = 1.0,
        max_participation_factor = 1.0,
        deployed_fraction = 1.0,
    )

    sys = System(100.0)
    for r in (up_reserve, down_reserve, offline_reserve, group, ordc_reserve)
        add_component!(sys, r)
    end

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = up_reserve
    refs[2] = down_reserve
    refs[3] = offline_reserve
    refs[4] = group
    refs[5] = ordc_reserve

    up_natural = PSY.to_openapi(up_reserve, refs, NU)
    @test up_natural.requirement == 100.0
    @test up_natural.reserve_direction == "UP"
    @test isnothing(up_natural.variable)

    up_device = PSY.to_openapi(up_reserve, refs, DU)
    @test up_device.requirement == 100.0

    down_natural = PSY.to_openapi(down_reserve, refs, NU)
    @test down_natural.reserve_direction == "DOWN"

    offline_natural = PSY.to_openapi(offline_reserve, refs, NU)
    @test offline_natural.requirement == 50.0

    group_natural = PSY.to_openapi(group, refs, NU)
    @test group_natural.requirement == 150.0
    @test group_natural.reserve_direction == "UP"

    ordc_natural = PSY.to_openapi(ordc_reserve, refs, NU)
    @test !isnothing(ordc_natural.variable)
end

@testset "OpenAPI export: GroupReserve contributing services round-trip" begin
    contributing = OnlineReserve{ReserveUp}(;
        name = "spin_up_member", available = true, time_frame = 10.0,
        requirement = 1.0, variable = PSY.ZERO_OFFER_CURVE, sustained_time = 60.0,
        max_output_fraction = 1.0, max_participation_factor = 1.0,
        deployed_fraction = 1.0,
    )
    group = GroupReserve{ReserveUp}(;
        name = "group_up_member", available = true, requirement = 1.5,
    )
    sys = System(100.0)
    add_component!(sys, contributing)
    add_component!(sys, group)
    push!(get_contributing_services(group), contributing)

    # to_openapi's output is from_openapi's input directly: both sides speak SystemDocument,
    # so the round-trip needs no re-serialization through JSON.
    out = PSY.to_openapi(sys; power_units = :component_base)
    sys2 = PSY.from_openapi(System, out)
    group2 = only(get_components(GroupReserve, sys2))
    @test get_name.(get_contributing_services(group2)) == ["spin_up_member"]
end

@testset "OpenAPI export: TradingHub membership round-trip" begin
    sys, b1, b2, hub = _market_hub_fixture()

    out = PSY.to_openapi(sys; power_units = :component_base)
    sys2 = PSY.from_openapi(System, out)
    hub2 = only(get_components(TradingHub, sys2))
    @test get_name.(get_associated_buses(hub2)) == ["b1", "b2"]
end

@testset "OpenAPI import: duplicate trading hub bus association errors loudly" begin
    sys, b1, b2, hub = _market_hub_fixture()
    out = PSY.to_openapi(sys; power_units = :component_base)
    duplicate_row = deepcopy(first(out.trading_hub_associations))
    push!(out.trading_hub_associations, duplicate_row)
    @test_throws ArgumentError PSY.from_openapi(System, out)
end

@testset "OpenAPI document round trip: VirtualParticipant settlement point, hub association, hub bid" begin
    sys, b1, b2, hub = _market_hub_fixture()

    vp_hub = VirtualParticipant(; name = "vp_hub", available = true,
        max_supply = 100.0, max_demand = 50.0, operation_cost = MarketBidCost(nothing))
    add_component!(sys, vp_hub)
    add_trading_hub!(sys, vp_hub, hub)

    dates = collect(DateTime("2026-01-01T00:00:00"):Hour(1):DateTime("2026-01-01T01:00:00"))
    data = PiecewiseStepData.(
        [[0.0, 50.0, 100.0], [0.0, 50.0, 100.0]],
        [[25.0, 30.0], [26.0, 31.0]],
    )
    ta = TimeSeries.TimeArray(dates, data)
    hub_ts = SingleTimeSeries(; name = get_name(hub), data = ta)
    set_hub_bid!(sys, vp_hub, hub, hub_ts, IS.NaturalUnit())

    vp_nodal = VirtualParticipant(; name = "vp_nodal", available = true,
        settlement_point = b2, max_supply = 10.0, max_demand = 10.0,
        operation_cost = MarketBidCost(nothing))
    add_component!(sys, vp_nodal)

    mktempdir() do dir
        to_file(sys, dir; force = true)
        sys2 = from_file(System, dir)

        hub2 = only(get_components(TradingHub, sys2))
        vp_hub2 = get_component(VirtualParticipant, sys2, "vp_hub")
        @test get_name.(get_trading_hubs(vp_hub2)) == ["western_hub"]
        @test has_trading_hub(vp_hub2, hub2)
        hub_ts2 = get_time_series(SingleTimeSeries, vp_hub2, get_name(hub2))
        @test hub_ts2 isa SingleTimeSeries
        @test TimeSeries.values(get_data(hub_ts2)) == TimeSeries.values(ta)

        vp_nodal2 = get_component(VirtualParticipant, sys2, "vp_nodal")
        @test get_name(get_settlement_point(vp_nodal2)) == "b2"
        @test isempty(get_trading_hubs(vp_nodal2))
    end
end

@testset "OpenAPI document round trip: PointToPointBid bus-to-hub terminals, FIXED curve style" begin
    sys, b1, b2, hub = _market_hub_fixture()

    ptp = PointToPointBid(; name = "utc1", available = true, from = b1, to = hub,
        max_active_power = 50.0,
        spread_bid = MarketBidCost(; curve_style = CurveStyles.FIXED),
        price_limits = (min = -50.0, max = 50.0), linked_crr = "crr1")
    add_component!(sys, ptp)

    mktempdir() do dir
        to_file(sys, dir; force = true)
        sys2 = from_file(System, dir)

        ptp2 = get_component(PointToPointBid, sys2, "utc1")
        @test get_name(get_from(ptp2)) == "b1"
        @test get_name(get_to(ptp2)) == "western_hub"
        @test get_max_active_power(ptp2) == 50.0
        @test get_price_limits(ptp2) == (min = -50.0, max = 50.0)
        @test get_curve_style(get_spread_bid(ptp2)) == CurveStyles.FIXED
        @test get_linked_crr(ptp2) == "crr1"
    end
end

@testset "OpenAPI export: supplemental attribute converters" begin
    # The exporters read their own id back from `refs` via `component_id`, exactly like
    # the generated component exporters, so each attribute registers first.
    refs = PSY.OpenAPIRefs(100.0)
    emissions = EmissionsData(;
        name = "gen1_CO2", pollutant = PollutantType.CO2,
        emission_rate = IncrementalCurve(;
            function_data = LinearFunctionData(0.0, 1.5), initial_input = 0.0,
        ),
        basis = EmissionBasis.FUEL_INPUT, start_up_adder = 0.0, mass_unit = MassUnit.LB,
        energy_unit = EnergyUnit.MMBTU, gwp = 1.0, available = true,
    )
    refs[1] = emissions
    po = PSY.to_openapi(emissions, refs)
    @test po.id == 1
    @test po.pollutant == "CO2"
    @test po.basis == "FUEL_INPUT"
    @test po.mass_unit == "LB"
    @test po.energy_unit == "MMBTU"

    geo = GeographicInfo(;
        geo_json = Dict{String, Any}("type" => "Point", "coordinates" => [1.0, 2.0]),
    )
    refs[2] = geo
    geo_po = PSY.to_openapi(geo, refs)
    @test geo_po.geo_json["type"] == "Point"

    cc_block = CombinedCycleBlock(;
        name = "cc1",
        configuration = CombinedCycleConfiguration.SingleShaftCombustionSteam,
        heat_recovery_to_steam_factor = 0.5,
    )
    refs[3] = cc_block
    cc_po = PSY.to_openapi(cc_block, refs)
    @test cc_po.configuration == "SingleShaftCombustionSteam"
    @test cc_po.heat_recovery_to_steam_factor == 0.5

    plant = ThermalPowerPlant(; name = "plant1")
    refs[4] = plant
    plant_po = PSY.to_openapi(plant, refs)
    @test plant_po.name == "plant1"

    # Substation has no descriptor entry, so both directions are hand-written in
    # src/substation.jl.
    substation = Substation(; name = "SUB1", number = 7, grounding_resistance = 0.25)
    refs[5] = substation
    substation_po = PSY.to_openapi(substation, refs)
    @test substation_po.id == 5
    @test substation_po.name == "SUB1"
    @test substation_po.number == 7
    @test substation_po.grounding_resistance == 0.25
    reimported = PSY.from_openapi(substation_po, refs)
    @test get_name(reimported) == get_name(substation)
    @test get_number(reimported) == get_number(substation)
    @test get_grounding_resistance(reimported) == get_grounding_resistance(substation)
end

# ── Round-trip assertions ─────────────────────────────────────────────────────────

# Shared fixture from common.jl; SLACK exercises the bustype round trip asserted below,
# and the round-trip testset predates the FixedAdmittance row.

@testset "OpenAPI export: round-trip" begin
    doc = make_openapi_test_doc(; bus1_bustype = "SLACK", include_fixed_admittance = false)

    @testset "COMPONENT_BASE -> PSY -> COMPONENT_BASE is exact" begin
        device_doc = deepcopy(doc)
        set_all_power_units!(device_doc, "COMPONENT_BASE")
        sys = PSY.from_openapi(System, to_test_document(device_doc))
        out = PSY.to_openapi(sys; power_units = :component_base)
        gen_out = only(PSY.PD.get_components(out, "ThermalStandard"))
        @test gen_out.power_units == "COMPONENT_BASE"
        @test gen_out.active_power == 50.0
        @test gen_out.rating == 100.0
        gen_in = only(device_doc["components"]["ThermalStandard"])
        @test gen_out.active_power === gen_in["active_power"]
        @test gen_out.rating === gen_in["rating"]
    end

    @testset "NATURAL_UNITS -> PSY -> NATURAL_UNITS is approximate only" begin
        sys = PSY.from_openapi(System, to_test_document(doc))
        out = PSY.to_openapi(sys; power_units = :natural_units)
        gen_out = only(PSY.PD.get_components(out, "ThermalStandard"))
        @test gen_out.power_units == "NATURAL_UNITS"
        gen_in = only(doc["components"]["ThermalStandard"])
        @test gen_out.active_power ≈ gen_in["active_power"] rtol = 1e-15
        @test gen_out.rating ≈ gen_in["rating"] rtol = 1e-15
        load_out = only(PSY.PD.get_components(out, "PowerLoad"))
        load_in = only(doc["components"]["PowerLoad"])
        @test load_out.active_power ≈ load_in["active_power"] rtol = 1e-15
    end

    @testset "bustype SLACK round-trips as SLACK" begin
        sys = PSY.from_openapi(System, to_test_document(doc))
        out = PSY.to_openapi(sys; power_units = :natural_units)
        bus1_out = first(b for b in PSY.PD.get_components(out, "ACBus") if b.number == 1)
        @test bus1_out.bustype == "SLACK"
    end

    @testset "to_openapi with an unmapped power_units errors" begin
        sys = System(100.0)
        add_component!(sys, ACBus(nothing))
        @test_throws ErrorException PSY.to_openapi(sys; power_units = :bogus_units)
    end

    @testset "Line.base_power on export == get_base_power(sys) exactly" begin
        sys = System(100.0)
        bus1 = _export_bus(; number = 1)
        bus2 = _export_bus(; number = 2, bustype = ACBusTypes.PQ)
        add_component!(sys, bus1)
        add_component!(sys, bus2)
        arc = Arc(; from = bus1, to = bus2)
        add_component!(sys, arc)
        line = Line(;
            name = "line1", available = true, active_power_flow = 0.1,
            reactive_power_flow = 0.02, arc = arc, r = 0.01, x = 0.1,
            b = (from = 0.0, to = 0.0), rating = 1.0,
            angle_limits = (min = -1.57, max = 1.57),
        )
        add_component!(sys, line)
        out = PSY.to_openapi(sys; power_units = :natural_units)
        line_out = only(PSY.PD.get_components(out, "Line"))
        @test line_out.base_power == PSY.get_base_power(sys)
    end
end

@testset "OpenAPI export: fresh System (never round-tripped) is exportable" begin
    bus = _export_bus(; number = 1)
    sys = System(100.0)
    add_component!(sys, bus)
    load = PowerLoad(;
        name = "load1", available = true, bus = bus, active_power = 0.3,
        reactive_power = 0.05,
        base_power = 100.0, max_active_power = 0.5, max_reactive_power = 0.1,
    )
    add_component!(sys, load)

    out_device = PSY.to_openapi(sys; power_units = :component_base)
    load_out = only(PSY.PD.get_components(out_device, "PowerLoad"))
    @test load_out.power_units == "COMPONENT_BASE"
    @test load_out.active_power == 0.3

    out_natural = PSY.to_openapi(sys; power_units = :natural_units)
    load_out_nat = only(PSY.PD.get_components(out_natural, "PowerLoad"))
    @test load_out_nat.power_units == "NATURAL_UNITS"
    @test load_out_nat.active_power == 30.0
end

@testset "OpenAPI export: multi-type synthetic round trip (component + reserve + time series + attribute)" begin
    mktempdir() do dir
        area_po = PSY.PO.Area(;
            id = 1, name = "area1", peak_active_power = 100.0,
            peak_reactive_power = 20.0,
            load_response = 0.0, base_power = 100.0, power_units = "NATURAL_UNITS",
        )
        lz_po = PSY.PO.LoadZone(;
            id = 2, name = "lz1", peak_active_power = 100.0, peak_reactive_power = 20.0,
            base_power = 100.0, power_units = "NATURAL_UNITS",
        )
        bus1_po = PSY.PO.ACBus(;
            id = 3, number = 1, name = "bus1", available = true, bustype = "REF",
            angle = 0.0, magnitude = 1.0,
            voltage_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
            base_voltage = 138.0, area = 1, load_zone = 2,
        )
        bus2_po = PSY.PO.ACBus(;
            id = 4, number = 2, name = "bus2", available = true, bustype = "PQ",
            angle = 0.0, magnitude = 1.0,
            voltage_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
            base_voltage = 138.0, area = 1, load_zone = 2,
        )
        arc_po = PSY.PO.Arc(; id = 5, from_id = 3, to_id = 4)
        line_po = PSY.PO.Line(;
            id = 6, name = "line1", available = true, active_power_flow = 10.0,
            reactive_power_flow = 2.0, arc = 5, r = 0.01, x = 0.1, base_power = 100.0,
            power_units = "NATURAL_UNITS",
            b = PSY.IC.FromTo(; from = 0.0, to = 0.0), rating = 175.0,
            angle_limits = PSY.IC.MinMax(; min = -1.57, max = 1.57),
            g = PSY.IC.FromTo(; from = 0.0, to = 0.0),
        )
        load_po = PSY.PO.PowerLoad(;
            id = 7, name = "load1", available = true, bus = 4,
            active_power = 30.0, reactive_power = 5.0, base_power = 100.0,
            power_units = "NATURAL_UNITS",
            max_active_power = 50.0, max_reactive_power = 10.0,
            conformity = "CONFORMING",
        )
        reserve_po = PSY.PO.OnlineReserve(;
            id = 8, name = "spin_up", available = true, time_frame = 10.0,
            requirement = 100.0, variable = nothing, sustained_time = 60.0,
            max_output_fraction = 1.0, max_participation_factor = 1.0,
            deployed_fraction = 1.0, reserve_direction = "UP",
        )
        emissions_po = PSY.PO.EmissionsData(;
            id = 9, name = "load1_CO2", pollutant = "CO2",
            emission_rate = PSY.PC.ValueCurve(
                PSY.PC.IncrementalCurve(;
                    function_data = PSY.PC.IncrementalCurveFunctionData(
                        PSY.IC.LinearFunctionData(;
                            proportional_term = 0.0, constant_term = 1.5,
                        ),
                    ),
                    initial_input = 0.0,
                ),
            ),
            basis = "FUEL_INPUT", start_up_adder = 0.0, mass_unit = "LB",
            energy_unit = "MMBTU", gwp = 1.0, available = true,
        )
        doc = Dict{String, Any}(
            "components" => Dict{String, Any}(
                "Area" => [openapi_raw(area_po)],
                "LoadZone" => [openapi_raw(lz_po)],
                "ACBus" => [openapi_raw(bus1_po), openapi_raw(bus2_po)],
                "Arc" => [openapi_raw(arc_po)],
                "Line" => [openapi_raw(line_po)],
                "PowerLoad" => [openapi_raw(load_po)],
                "OnlineReserve" => [openapi_raw(reserve_po)],
            ),
            "supplemental_attributes" => [openapi_raw(emissions_po)],
            "supplemental_attribute_associations" => [
                Dict{String, Any}(
                    "attribute_id" => 9, "component_id" => 7,
                    "component_type" => "PowerLoad",
                    "attribute_type" => "EmissionsData",
                ),
            ],
            "plant_associations" => [],
            "combined_cycle_associations" => [],
            # Service membership: service_id names the service component (spin_up), entity_id
            # the contributing device (load1).
            "service_associations" => [
                Dict{String, Any}("service_id" => 8, "entity_id" => 7),
            ],
            "trading_hub_associations" => [],
            "time_series_associations" => [],
            "ext" => Dict{String, Any}(),
            "time_series_storage_file" => nothing,
        )

        sys = PSY.from_openapi(System, to_test_document(doc))
        load = get_component(PowerLoad, sys, "load1")
        ta = TimeSeries.TimeArray(
            [Dates.DateTime(2024, 1, 1, h) for h in 0:2], [0.5, 0.6, 0.7],
        )
        series = SingleTimeSeries(; name = "max_active_power", data = ta)
        add_time_series!(sys, load, series)

        ts_out_path = joinpath(dir, "export_time_series_storage.h5")
        out = PSY.to_openapi(
            sys;
            power_units = :natural_units,
            time_series_storage_path = ts_out_path,
        )

        @test only(PSY.PD.get_components(out, "Line")).power_units == "NATURAL_UNITS"
        @test length(PSY.PD.get_components(out, "ACBus")) == 2
        @test length(only(PSY.PD.get_components(out, "Line")) |> x -> [x]) == 1
        @test length(PSY.PD.get_components(out, "OnlineReserve")) == 1
        @test length(out.supplemental_attributes) == 1
        @test length(out.supplemental_attribute_associations) == 1
        assoc = only(out.supplemental_attribute_associations)
        @test assoc.attribute_type == "EmissionsData"
        @test length(out.service_associations) == 1
        service_assoc = only(out.service_associations)
        # A component's document id is its IS component id, so the membership row points at
        # the load by that id directly — no export-refs rebuild needed to resolve it.
        @test service_assoc.entity_id == IS.get_id(load)
        # The sidecar holds the values; the document lists one row per series so a consumer
        # can see what the bundle contains without opening the store.
        @test isfile(ts_out_path)
        # `.value` unwraps the oneOf: the discriminator selects one of the six concrete row
        # types, and the type itself carries the columns.
        ts_row = only(out.time_series_associations).value
        @test ts_row isa PSY.PTS.SingleTimeSeries
        @test ts_row.name == "max_active_power"
        @test ts_row.time_series_type == "SingleTimeSeries"
        @test ts_row.owner_category == "Component"
        @test ts_row.owner_type == "PowerLoad"
        @test ts_row.owner_id == IS.get_id(load)
        @test ts_row.resolution == "PT1H"
        @test ts_row.length == 3
        @test ts_row.element_type == "f64"
        # `uri`/`data_hash` are the store's own content hash, never a caller-supplied
        # locator.
        @test occursin(r"^[0-9a-f]{64}$", ts_row.uri)
        @test ts_row.data_hash == ts_row.uri
    end
end

@testset "OpenAPI export/import: forecast time series round trip" begin
    mktempdir() do dir
        bus = _export_bus(; number = 1)
        sys = System(100.0)
        add_component!(sys, bus)
        load = PowerLoad(;
            name = "load1", available = true, bus = bus, active_power = 0.3,
            reactive_power = 0.05,
            base_power = 100.0, max_active_power = 0.5, max_reactive_power = 0.1,
        )
        add_component!(sys, load)

        resolution = Dates.Hour(1)
        initial_timestamp = Dates.DateTime(2024, 1, 1, 0)
        sts = SingleTimeSeries(;
            name = "load_hist",
            data = TimeSeries.TimeArray(
                [initial_timestamp + resolution * (i - 1) for i in 1:4],
                [0.11, 0.12, 0.13, 0.14],
            ),
        )
        add_time_series!(sys, load, sts)
        transform_single_time_series!(sys, Dates.Hour(2), Dates.Hour(1))

        det_data = SortedDict(
            initial_timestamp + Dates.Hour(i - 1) => [0.1 * i, 0.2 * i] for i in 1:3
        )
        deterministic = Deterministic(;
            name = "max_active_power", data = det_data, resolution = resolution,
            interval = Dates.Hour(1),
        )
        add_time_series!(sys, load, deterministic)

        counts_before = get_time_series_counts(sys)
        @test counts_before.forecast_count == 2

        ts_out_path = joinpath(dir, "forecast_time_series_storage.h5")
        doc = PSY.to_openapi(
            sys; power_units = :component_base, time_series_storage_path = ts_out_path,
        )
        @test isfile(ts_out_path)
        # 3 rows: the "load_hist" SingleTimeSeries, the DeterministicSingleTimeSeries its
        # transform produced, and the real Deterministic. The forecast shape columns are
        # carried on the rows, not just in the sidecar's catalog.
        @test length(doc.time_series_associations) == 3
        rows = [a.value for a in doc.time_series_associations]
        det_row = only(filter(r -> r isa PSY.PTS.Deterministic, rows))
        # Durations carry the store's unit-style ISO-8601 spelling (`PT2H`), not the
        # seconds-only style (`PT7200S`).
        @test det_row.horizon == "PT2H"
        @test det_row.interval == "PT1H"
        @test det_row.count == 3
        # A forecast's shape is horizon/interval/count; `length` is not a column its type
        # declares, so it is absent rather than null.
        @test !hasfield(typeof(det_row), :length)
        dsts_row = only(filter(r -> r isa PSY.PTS.DeterministicSingleTimeSeries, rows))
        @test dsts_row.horizon == "PT2H"
        @test dsts_row.count == 3
        # The transform's derived forecast is its own stored type, so it does not collide
        # with the real Deterministic under the discriminator.
        @test dsts_row.time_series_type == "DeterministicSingleTimeSeries"

        sys2 = PSY.from_openapi(System, doc; time_series_storage_path = ts_out_path)
        load2 = get_component(PowerLoad, sys2, "load1")
        counts_after = get_time_series_counts(sys2)
        @test counts_after.forecast_count == 2

        det2 = get_time_series(Deterministic, load2, "max_active_power")
        @test get_horizon(det2) == Dates.Hour(2)
        @test IS.get_interval(det2) == Dates.Hour(1)
        @test IS.get_count(det2) == 3
        @test collect(values(get_data(det2))) == collect(values(det_data))

        dsts2 = get_time_series(DeterministicSingleTimeSeries, load2, "load_hist")
        @test get_horizon(dsts2) == Dates.Hour(2)
        @test IS.get_count(dsts2) == 3
        # `DeterministicSingleTimeSeries` is a query-only marker on the rust-backed store —
        # reads materialize a `Deterministic`, and there is no `get_single_time_series` to
        # unwrap. The array it is derived from is its own `SingleTimeSeries`.
        sts2 = get_time_series(SingleTimeSeries, load2, "load_hist")
        @test TimeSeries.values(get_data(sts2)) == [0.11, 0.12, 0.13, 0.14]
    end
end

@testset "OpenAPI export converters: TwoTerminalVSCLine" begin
    bus1 = _export_bus(; number = 1)
    bus2 = _export_bus(; number = 2, bustype = ACBusTypes.PQ)
    arc = Arc(; from = bus1, to = bus2)
    vsc = _export_vsc(arc)
    sys = System(100.0)
    for component in (bus1, bus2, arc, vsc)
        add_component!(sys, component)
    end

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus1
    refs[2] = bus2
    refs[3] = arc
    refs[4] = vsc

    natural_po = PSY.to_openapi(vsc, refs, NU)
    @test natural_po.active_power_flow == 50.0
    @test natural_po.rating == 200.0
    @test natural_po.active_power_limits_from.min == -200.0
    @test natural_po.reactive_power_limits_to.max == 100.0
    # DC_POWER setpoint scales with the other power fields; the voltage-regulating ones are
    # written per-unit as stored, tagged by `setpoint_voltage_units`.
    @test natural_po.dc_setpoint_from == 40.0
    @test natural_po.dc_setpoint_to == 1.02
    @test natural_po.setpoint_voltage_units == "COMPONENT_BASE"
    # pu → siemens against Ybase = 100 / 200^2.
    @test natural_po.g == 0.5
    @test natural_po.admittance_units == "NATURAL_UNITS"
    @test natural_po.voltage_units == "NATURAL_UNITS"
    @test natural_po.dc_control_to == "DC_VOLTAGE"
    @test natural_po.ac_control_from == "AC_REACTIVE_POWER"
    @test natural_po.converter_loss_to.function_data.value.quadratic_term == 0.01

    device_po = PSY.to_openapi(vsc, refs, DU)
    @test device_po.active_power_flow == 0.5
    @test device_po.active_power_limits_from.min == -2.0
    @test device_po.dc_setpoint_from == 0.4
    @test device_po.dc_setpoint_to == 1.02
    @test device_po.setpoint_voltage_units == "COMPONENT_BASE"
    @test device_po.g == 0.5
end

@testset "OpenAPI export converters: TwoTerminalVSCLine AC_VOLTAGE setpoint" begin
    bus1 = _export_bus(; number = 1)
    bus2 = _export_bus(; number = 2, bustype = ACBusTypes.PQ)
    arc = Arc(; from = bus1, to = bus2)
    vsc = _export_vsc(
        arc; ac_control_from = VSCACControlModes.AC_VOLTAGE,
        rated_ac_voltage_from = 230.0,
    )
    sys = System(100.0)
    for component in (bus1, bus2, arc, vsc)
        add_component!(sys, component)
    end

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus1
    refs[2] = bus2
    refs[3] = arc
    refs[4] = vsc

    # The setpoint is written per unit and the basis declared, so no base is needed to
    # export it; `rated_ac_voltage_from` rides along as the base an importer reading a
    # natural-units document divides by. Neither depends on the unit system, since both
    # are voltages, not power fields.
    natural_po = PSY.to_openapi(vsc, refs, NU)
    @test natural_po.ac_setpoint_from == 0.95
    @test natural_po.setpoint_voltage_units == "COMPONENT_BASE"
    @test natural_po.rated_ac_voltage_from == 230.0
    component_po = PSY.to_openapi(vsc, refs, DU)
    @test component_po.ac_setpoint_from == 0.95
    @test component_po.rated_ac_voltage_from == 230.0
end

@testset "OpenAPI export: TwoTerminalVSCLine survives a document round trip" begin
    for power_units in (:natural_units, :component_base)
        bus1 = _export_bus(; number = 1)
        bus2 = _export_bus(; number = 2, bustype = ACBusTypes.PQ)
        arc = Arc(; from = bus1, to = bus2)
        vsc = _export_vsc(arc)
        sys = System(100.0)
        for component in (bus1, bus2, arc, vsc)
            add_component!(sys, component)
        end

        dir = mktempdir()
        PSY.to_file(sys, dir; power_units = power_units, force = true)
        restored = get_component(TwoTerminalVSCLine, PSY.from_file(System, dir), "vsc1")
        for field in fieldnames(TwoTerminalVSCLine)
            field in (:internal, :arc, :services) && continue
            @test getfield(restored, field) == getfield(vsc, field)
        end
    end
end

@testset "OpenAPI export: TwoTerminalVSCLine AC voltage bases survive a document round trip" begin
    # `ac_control_*` on `AC_VOLTAGE` with a non-zero `rated_ac_voltage_from`/`_to`: the wire
    # row must carry both bases (not just convert the setpoints through them) for a
    # PSY→doc→PSY round trip to reproduce the same PSY values back.
    for power_units in (:natural_units, :component_base)
        bus1 = _export_bus(; number = 1)
        bus2 = _export_bus(; number = 2, bustype = ACBusTypes.PQ)
        arc = Arc(; from = bus1, to = bus2)
        vsc = _export_vsc(
            arc;
            ac_control_from = VSCACControlModes.AC_VOLTAGE,
            ac_control_to = VSCACControlModes.AC_VOLTAGE,
            rated_ac_voltage_from = 230.0,
            rated_ac_voltage_to = 225.0,
        )
        sys = System(100.0)
        for component in (bus1, bus2, arc, vsc)
            add_component!(sys, component)
        end

        dir = mktempdir()
        PSY.to_file(sys, dir; power_units = power_units, force = true)
        restored = get_component(TwoTerminalVSCLine, PSY.from_file(System, dir), "vsc1")
        for field in fieldnames(TwoTerminalVSCLine)
            field in (:internal, :arc, :services) && continue
            @test getfield(restored, field) == getfield(vsc, field)
        end
    end
end

@testset "OpenAPI export: TwoTerminalVSCLine unconvertible values error" begin
    bus1 = _export_bus(; number = 1)
    bus2 = _export_bus(; number = 2, bustype = ACBusTypes.PQ)
    arc = Arc(; from = bus1, to = bus2)
    refs = PSY.OpenAPIRefs(100.0)

    # A non-zero ac_setpoint_from with no AC voltage base (`rated_ac_voltage_from` unset,
    # the default) has nothing to be expressed against.
    ac_voltage = _export_vsc(arc; ac_control_from = VSCACControlModes.AC_VOLTAGE)
    refs[4] = ac_voltage
    @test_throws ErrorException PSY.to_openapi(ac_voltage, refs, NU)
end

@testset "OpenAPI export: TwoTerminalVSCLine tolerates a missing DC voltage base" begin
    # A non-zero `g` with `rated_dc_voltage == 0.0` has no DC voltage base to express it
    # against. Export no longer errors on this: it falls back to a base of 1, mirroring
    # import's own `_vsc_dc_base_voltage` fallback for `iszero(value)`.
    bus1 = _export_bus(; number = 1)
    bus2 = _export_bus(; number = 2, bustype = ACBusTypes.PQ)
    arc = Arc(; from = bus1, to = bus2)
    vsc =
        _export_vsc(arc; rated_dc_voltage = 0.0, dc_control_to = VSCDCControlModes.DC_POWER)
    sys = System(100.0)
    for component in (bus1, bus2, arc, vsc)
        add_component!(sys, component)
    end

    refs = PSY.OpenAPIRefs(100.0)
    refs[1] = bus1
    refs[2] = bus2
    refs[3] = arc
    refs[4] = vsc
    po = PSY.to_openapi(vsc, refs, NU)
    @test po.g isa Float64
    @test po.rated_dc_voltage == 0.0

    # NOT a lossless round trip: import's `_vsc_dc_base_voltage` only falls back to
    # `one(rated)` when the INCOMING value is itself zero. Here the exported `g` is
    # non-zero and `rated_dc_voltage` is still `0.0` in the document, so `from_file` still
    # hits import's `error(...)` branch — unchanged, correct, and out of scope. The two
    # fallbacks are symmetric only for the degenerate `g == 0.0` case, which never needed
    # tolerating in the first place.
    dir = mktempdir()
    PSY.to_file(sys, dir; power_units = :natural_units, force = true)
    @test_throws ErrorException PSY.from_file(System, dir)
end

_export_thermal_gen(bus; name = "gen1") = ThermalStandard(;
    name = name, available = true, status = true, bus = bus,
    active_power = 0.4, reactive_power = 0.01, rating = 0.5,
    prime_mover_type = PrimeMovers.ST, fuel = ThermalFuels.COAL,
    active_power_limits = (min = 0.0, max = 0.4),
    reactive_power_limits = (min = -0.3, max = 0.3),
    time_limits = nothing, ramp_limits = nothing,
    operation_cost = ThermalGenerationCost(CostCurve(LinearCurve(1400.0)), 0.0, 4.0, 2.0),
    base_power = 100.0,
)

@testset "OpenAPI export: time series owned by a supplemental attribute round-trips" begin
    # An attribute's document id is its own IS id, exactly like a component's, so the
    # sidecar catalog's owner id resolves back on import.
    mktempdir() do dir
        bus = _export_bus(; number = 1)
        gen = _export_thermal_gen(bus)
        sys = System(100.0)
        add_component!(sys, bus)
        add_component!(sys, gen)

        outage = GeometricDistributionForcedOutage(;
            mean_time_to_recovery = 1.0, outage_transition_probability = 0.5,
        )
        add_supplemental_attribute!(sys, gen, outage)

        ta = TimeSeries.TimeArray(
            [Dates.DateTime(2024, 1, 1, h) for h in 0:2], [0.1, 0.2, 0.3],
        )
        add_time_series!(sys, outage, SingleTimeSeries(; name = "outage_series", data = ta))

        ts_out_path = joinpath(dir, "attr_owned_series.h5")
        doc = PSY.to_openapi(
            sys; power_units = :component_base, time_series_storage_path = ts_out_path,
        )
        @test isfile(ts_out_path)
        ts_row = only(doc.time_series_associations).value
        @test ts_row.owner_category == "SupplementalAttribute"
        @test ts_row.owner_id == IS.get_id(outage)
        @test ts_row.name == "outage_series"

        sys2 = PSY.from_openapi(System, doc; time_series_storage_path = ts_out_path)
        gen2 = get_component(ThermalStandard, sys2, "gen1")
        outage2 = only(get_supplemental_attributes(GeometricDistributionForcedOutage, gen2))
        # The attribute's id is stable across the round trip, exactly like a component's.
        @test IS.get_id(outage2) == IS.get_id(outage)
        ts2 = get_time_series(SingleTimeSeries, outage2, "outage_series")
        @test TimeSeries.values(PSY.get_data(ts2)) == [0.1, 0.2, 0.3]
    end
end

@testset "OpenAPI export: time series on an unexportable (dynamics) owner warns and is dropped" begin
    mktempdir() do dir
        bus = _export_bus(; number = 1)
        static_gen = _export_thermal_gen(bus)
        dyn_gen = DynamicGenerator(;
            name = get_name(static_gen),
            ω_ref = 1.0,
            machine = BaseMachine(; R = 0.0, Xd_p = 0.2995, eq_p = 1.05),
            shaft = SingleMass(; H = 5.148, D = 2.0),
            avr = AVRFixed(; Vf = 1.05, V_ref = 1.0),
            prime_mover = TGFixed(; efficiency = 1.0),
            pss = PSSFixed(; V_pss = 0.0),
        )

        sys = System(100.0)
        add_component!(sys, bus)
        add_component!(sys, static_gen)
        add_component!(sys, dyn_gen, static_gen)

        ta = TimeSeries.TimeArray(
            [Dates.DateTime(2024, 1, 1, h) for h in 0:2], [0.1, 0.2, 0.3],
        )
        add_time_series!(sys, dyn_gen, SingleTimeSeries(; name = "dyn_series", data = ta))
        add_time_series!(
            sys, static_gen, SingleTimeSeries(; name = "static_series", data = ta),
        )

        ts_out_path = joinpath(dir, "dynamics_owner.h5")
        out = @test_logs(
            (:warn, r"omitting component type"),
            (:warn, r"omitting 1 time series row"),
            match_mode = :any,
            PSY.to_openapi(
                sys; power_units = :component_base,
                time_series_storage_path = ts_out_path,
            ),
        )
        # The sidecar still holds both series — only the document's description of the
        # dynamics-owned one is dropped, so the write itself is not blocked.
        @test isfile(ts_out_path)
        @test length(out.time_series_associations) == 1
        @test only(out.time_series_associations).value.name == "static_series"
    end
end

_cc_thermal_gen(bus, name, prime_mover) = ThermalStandard(;
    name = name, available = true, status = true, bus = bus,
    active_power = 0.0, reactive_power = 0.0, rating = 1.0,
    active_power_limits = (min = 0.0, max = 1.0),
    reactive_power_limits = (min = -1.0, max = 1.0), ramp_limits = nothing,
    operation_cost = ThermalGenerationCost(nothing), base_power = 100.0,
    time_limits = nothing, prime_mover_type = prime_mover,
    fuel = ThermalFuels.NATURAL_GAS,
)

"""The issue's MWE: a CT and a CA on the same bus, both members of one `CombinedCycleBlock`,
with the CT feeding two HRSGs (`hrsg_number = 1` and `hrsg_number = 2`)."""
function _build_combined_cycle_system()
    bus = _export_bus(; number = 1)
    ct = _cc_thermal_gen(bus, "CT", PrimeMovers.CT)
    ca = _cc_thermal_gen(bus, "CA", PrimeMovers.CA)
    sys = System(100.0)
    add_component!(sys, bus)
    add_component!(sys, ct)
    add_component!(sys, ca)
    block = CombinedCycleBlock(;
        name = "block",
        configuration = CombinedCycleConfiguration.DoubleCombustionOneSteam,
    )
    add_supplemental_attribute!(sys, ct, block; hrsg_number = 1)
    add_supplemental_attribute!(sys, ct, block; hrsg_number = 2)
    add_supplemental_attribute!(sys, ca, block; hrsg_number = 2)
    return sys, ct, ca, block
end

@testset "OpenAPI export: multi-HRSG combined cycle associations" begin
    sys, ct, ca, block = _build_combined_cycle_system()
    ct_id = IS.get_id(ct)
    ca_id = IS.get_id(ca)
    block_id = IS.get_id(block)

    doc = PSY.to_openapi(sys)
    @test length(doc.combined_cycle_associations) == 3
    ct_rows = filter(
        row -> row.entity_id == ct_id, doc.combined_cycle_associations,
    )
    ca_rows = filter(
        row -> row.entity_id == ca_id, doc.combined_cycle_associations,
    )
    @test length(ct_rows) == 2
    @test all(row -> row.plant_id == block_id && row.role == "CT", ct_rows)
    @test sort([row.hrsg_index for row in ct_rows]) == [1, 2]
    @test length(ca_rows) == 1
    @test only(ca_rows).plant_id == block_id
    @test only(ca_rows).role == "CA"
    @test only(ca_rows).hrsg_index == 2

    sys2 = PSY.from_openapi(System, doc)
    block2 = only(get_supplemental_attributes(CombinedCycleBlock, sys2))
    @test get_hrsg_ct_map(block2) == get_hrsg_ct_map(block)
    @test get_hrsg_ca_map(block2) == get_hrsg_ca_map(block)

    mktempdir() do dir
        PSY.to_file(sys, dir; force = true)
        sys3 = PSY.from_file(System, dir)
        block3 = only(get_supplemental_attributes(CombinedCycleBlock, sys3))
        @test get_hrsg_ct_map(block3) == get_hrsg_ct_map(block)
        @test get_hrsg_ca_map(block3) == get_hrsg_ca_map(block)
    end

    duplicate_row = deepcopy(first(ct_rows))
    push!(doc.combined_cycle_associations, duplicate_row)
    @test_throws ErrorException PSY.from_openapi(System, doc)
end

@testset "OpenAPI document round trip: feature-keyed time series" begin
    sys = System(100.0)
    bus = _export_bus(; number = 1)
    add_component!(sys, bus)
    zone = LoadZone(; name = "lz1", peak_active_power = 1.0, peak_reactive_power = 0.0)
    add_component!(sys, zone)
    stamps = collect(range(DateTime(2026, 1, 1); step = Hour(1), length = 3))
    for (number, value) in ((1, 0.25), (2, 0.75))
        ts = SingleTimeSeries(;
            name = "factor",
            data = TimeSeries.TimeArray(stamps, fill(value, 3)),
        )
        add_time_series!(sys, zone, ts; features = Dict("bus" => number))
    end
    mktempdir() do dir
        to_file(sys, dir; force = true)
        sys2 = from_file(System, dir)
        zone2 = get_component(LoadZone, sys2, "lz1")
        @test get_time_series_values(
            SingleTimeSeries, zone2, "factor"; features = Dict("bus" => 1),
        ) == fill(0.25, 3)
        @test get_time_series_values(
            SingleTimeSeries, zone2, "factor"; features = Dict("bus" => 2),
        ) == fill(0.75, 3)
    end
end
