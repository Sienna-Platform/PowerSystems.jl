# Field-for-field tests for the generated and hand-written OpenAPI import converters.
# Each testset builds a PO struct with known kwargs and asserts the resulting PSY component,
# including the exact unit-conversion numbers.

"""Return a copy of `po` (an immutable `Base.@kwdef` struct) with the given fields
overridden."""
function _po_with(po; overrides...)
    fields = fieldnames(typeof(po))
    current = NamedTuple{fields}(getfield.(Ref(po), fields))
    merged = merge(current, NamedTuple(overrides))
    return typeof(po)(; merged...)
end

_bus_po(id; area = 1, load_zone = 2, bustype = "REF") = PSY.PO.ACBus(;
    id = id, number = id, name = "bus$id", available = true,
    bustype = PSY.PC.ACBusType(bustype),
    angle = 0.0, magnitude = 1.0,
    voltage_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
    base_voltage = 138.0, area = area, load_zone = load_zone,
)

"""A LINEAR `InputOutputCurve`, the shape every `converter_loss`/`loss` field carries."""
_io_curve(proportional_term, constant_term) = PSY.PC.InputOutputCurve(;
    function_data = PSY.PC.InputOutputCurveFunctionData(
        PSY.IC.LinearFunctionData(;
            proportional_term = proportional_term,
            constant_term = constant_term,
        ),
    ),
)

"""A `LossCurve` on the given basis wrapping a LINEAR `InputOutputCurve` — the wire shape
`converter_loss_from`/`converter_loss_to`/`loss` fields carry."""
_loss_curve_po(proportional_term, constant_term; power_units = "NATURAL_UNITS") =
    PSY.PC.LossCurve(;
        power_units = PSY.IC.UnitSystem(power_units),
        value_curve = PSY.PC.LossValueCurve(_io_curve(proportional_term, constant_term)),
    )

"""
A `TwoTerminalVSCLine` PO struct on the DC_POWER/AC_REACTIVE_POWER branches, which are the
only ones every field of has a faithful conversion. Freshly built per call, with any field
overridable by keyword, since the PO struct is immutable.
"""
function _vsc_po_minimal(; overrides...)
    defaults = (
        id = 20, name = "vsc1", available = true, arc = 10,
        active_power_flow = 50.0, rating = 200.0,
        active_power_limits_from = PSY.IC.MinMax(; min = -200.0, max = 200.0),
        active_power_limits_to = PSY.IC.MinMax(; min = -200.0, max = 200.0),
        admittance_units = PSY.PO.AdmittanceUnitBasis("NATURAL_UNITS"), g = 0.5,
        dc_current = 300.0, reactive_power_from = 10.0,
        dc_control_from = PSY.PO.VSCDCControlModes("DC_POWER"),
        ac_control_from = PSY.PO.VSCACControlModes("AC_REACTIVE_POWER"),
        dc_setpoint_from = 40.0, ac_setpoint_from = 0.95,
        converter_loss_from = _loss_curve_po(1.2, 0.5),
        max_dc_current_from = 1000.0, rating_from = 200.0,
        reactive_power_limits_from = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        power_factor_weighting_fraction_from = 0.5,
        voltage_units = PSY.PO.VoltageUnitBasis("NATURAL_UNITS"),
        setpoint_voltage_units = PSY.PO.VoltageUnitBasis("NATURAL_UNITS"),
        voltage_limits_from = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        dc_voltage_droop_from = 0.0, reactive_power_to = 20.0,
        dc_control_to = PSY.PO.VSCDCControlModes("DC_POWER"),
        ac_control_to = PSY.PO.VSCACControlModes("AC_REACTIVE_POWER"),
        dc_setpoint_to = 40.0, ac_setpoint_to = 0.98,
        converter_loss_to = _loss_curve_po(1.1, 0.4),
        max_dc_current_to = 1000.0, rating_to = 200.0,
        reactive_power_limits_to = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        power_factor_weighting_fraction_to = 0.5,
        voltage_limits_to = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        dc_voltage_droop_to = 0.0, rated_dc_voltage = 200.0,
        remote_bus_control_from = nothing, remote_bus_control_to = 4,
        rmpct_from = 100.0, rmpct_to = 100.0, base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    merged = merge(defaults, NamedTuple(overrides))
    return PSY.PO.TwoTerminalVSCLine(; merged...)
end

function _refs_with_area_bus(; base_power = 100.0)
    refs = PSY.OpenAPIRefs(base_power)
    area_po = PSY.PO.Area(;
        id = 1, name = "area1", peak_active_power = 100.0, peak_reactive_power = 20.0,
        load_response = 0.0, base_power = base_power,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    lz_po = PSY.PO.LoadZone(;
        id = 2, name = "lz1", peak_active_power = 100.0, peak_reactive_power = 20.0,
        base_power = base_power,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    refs[1] = PSY.from_openapi(area_po, refs, NU)
    refs[2] = PSY.from_openapi(lz_po, refs, NU)
    refs[3] = PSY.from_openapi(_bus_po(3), refs, NU)
    refs[4] = PSY.from_openapi(_bus_po(4; bustype = "PQ"), refs, NU)
    return refs
end

@testset "OpenAPI converters: ACBus" begin
    refs = _refs_with_area_bus()
    bus_po = _bus_po(5)
    bus_device = PSY.from_openapi(bus_po, refs, CU)
    bus_natural = PSY.from_openapi(bus_po, refs, NU)

    for bus in (bus_device, bus_natural)
        @test get_number(bus) == 5
        @test get_name(bus) == "bus5"
        @test get_bustype(bus) == ACBusTypes.REF
        @test get_base_voltage(bus) == 138.0
        @test get_area(bus) === refs[1]
        @test get_load_zone(bus) === refs[2]
    end

    # SLACK is a distinct area-slack marker, not the system REF: the converter must not
    # collapse it.
    slack_po = _bus_po(6; bustype = "SLACK")
    slack_bus = PSY.from_openapi(slack_po, refs, NU)
    @test get_bustype(slack_bus) == ACBusTypes.SLACK

    @test_throws ErrorException PSY.from_openapi(_bus_po(7; area = 999), refs, NU
    )
end

@testset "OpenAPI converters: Arc" begin
    refs = _refs_with_area_bus()
    arc_po = PSY.PO.Arc(; id = 10, from_id = 3, to_id = 4)
    for val in (CU, NU)
        arc = PSY.from_openapi(arc_po, refs, val)
        @test get_from(arc) === refs[3]
        @test get_to(arc) === refs[4]
    end
    @test_throws ErrorException PSY.from_openapi(
        PSY.PO.Arc(; id = 11, from_id = 999, to_id = 4),
        refs,
        NU,
    )
end

@testset "OpenAPI converters: Area / LoadZone (power_units-discriminated peak conversion)" begin
    # x-unit for peak_active_power/peak_reactive_power is MW/MVAr (SiennaSchemas
    # Operations/Topology/{Area,LoadZone}.json), discriminated per blob by `power_units`
    # like every other power-family field: COMPONENT_BASE passes through pu, NATURAL_UNITS
    # divides by the blob's own `base_power`.
    refs = PSY.OpenAPIRefs(100.0)

    area_po_du = PSY.PO.Area(;
        id = 1, name = "area_du", peak_active_power = 2.5,
        peak_reactive_power = 0.5, load_response = 12.5, base_power = 100.0,
        power_units = PSY.IC.UnitSystem("COMPONENT_BASE"),
    )
    lz_po_du = PSY.PO.LoadZone(;
        id = 2, name = "lz_du", peak_active_power = 2.5, peak_reactive_power = 0.5,
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("COMPONENT_BASE"),
    )
    sys_du = System(100.0)
    area_du = PSY.from_openapi(area_po_du, refs, CU)
    add_component!(sys_du, area_du)
    lz_du = PSY.from_openapi(lz_po_du, refs, CU)
    add_component!(sys_du, lz_du)
    @test get_peak_active_power(area_du, SU) == 2.5
    @test get_peak_reactive_power(area_du, SU) == 0.5
    @test get_load_response(area_du) == 12.5
    @test get_peak_active_power(lz_du, SU) == 2.5
    @test get_peak_reactive_power(lz_du, SU) == 0.5
    @test get_base_power(area_du) == 100.0
    @test get_base_power(lz_du) == 100.0

    area_po_nu = PSY.PO.Area(;
        id = 3, name = "area_nu", peak_active_power = 250.0,
        peak_reactive_power = 50.0, load_response = 12.5, base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    lz_po_nu = PSY.PO.LoadZone(;
        id = 4, name = "lz_nu", peak_active_power = 250.0, peak_reactive_power = 50.0,
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    sys_nu = System(100.0)
    area_nu = PSY.from_openapi(area_po_nu, refs, NU)
    add_component!(sys_nu, area_nu)
    lz_nu = PSY.from_openapi(lz_po_nu, refs, NU)
    add_component!(sys_nu, lz_nu)
    @test get_peak_active_power(area_nu, SU) == 2.5
    @test get_peak_reactive_power(area_nu, SU) == 0.5
    @test get_peak_active_power(lz_nu, SU) == 2.5
    @test get_peak_reactive_power(lz_nu, SU) == 0.5

    # A blob whose own `base_power` differs from the System's is honored exactly.
    area_po_explicit = PSY.PO.Area(;
        id = 5, name = "area_explicit", peak_active_power = 250.0,
        peak_reactive_power = 50.0, load_response = 12.5, base_power = 250.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    area_explicit = PSY.from_openapi(area_po_explicit, refs, NU)
    @test get_base_power(area_explicit) == 250.0

    # `base_power`/`power_units` are non-defaulted fields on the wire type itself —
    # omitting either fails at construction, not at `from_openapi`.
    @test_throws UndefKeywordError PSY.PO.Area(;
        id = 6, name = "area_missing_base", peak_active_power = 250.0,
        peak_reactive_power = 50.0, load_response = 12.5,
    )
end

@testset "OpenAPI converters: TransmissionInterface (power_units-discriminated conversion)" begin
    # x-unit for active_power_flow_limits is MW (SiennaSchemas
    # Operations/Service/TransmissionInterface.json), discriminated by `power_units` like
    # Area/LoadZone's peak fields above. `direction_mapping::Dict{String, Int}` still blocks
    # codegen.
    refs = PSY.OpenAPIRefs(100.0)

    tx_po_du = PSY.PO.TransmissionInterface(;
        id = 1, name = "iface_du", available = true,
        active_power_flow_limits = PSY.IC.MinMax(; min = -10.0, max = 10.0),
        violation_penalty = 5000.0,
        direction_mapping = PSY.PO.TransmissionInterfaceDirectionMapping(;
            additional_properties = Dict{String, Int64}("line1" => 1, "line2" => -1),
        ),
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("COMPONENT_BASE"),
    )
    tx_du = PSY.from_openapi(tx_po_du, refs, CU)
    add_component!(System(100.0), tx_du)
    @test get_active_power_flow_limits(tx_du, SU) == (min = -10.0, max = 10.0)
    @test get_violation_penalty(tx_du) == 5000.0
    @test get_direction_mapping(tx_du) == Dict("line1" => 1, "line2" => -1)
    @test get_base_power(tx_du) == 100.0

    tx_po_nu = PSY.PO.TransmissionInterface(;
        id = 2, name = "iface_nu", available = true,
        active_power_flow_limits = PSY.IC.MinMax(; min = -1000.0, max = 1000.0),
        violation_penalty = 5000.0,
        direction_mapping = PSY.PO.TransmissionInterfaceDirectionMapping(;
            additional_properties = Dict{String, Int64}("line1" => 1, "line2" => -1),
        ),
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    tx_nu = PSY.from_openapi(tx_po_nu, refs, NU)
    add_component!(System(100.0), tx_nu)
    @test get_active_power_flow_limits(tx_nu, SU) == (min = -10.0, max = 10.0)
    @test get_base_power(tx_nu) == 100.0

    # `base_power`/`power_units` are non-defaulted fields on the wire type itself —
    # omitting either fails at construction, not at `from_openapi`.
    @test_throws UndefKeywordError PSY.PO.TransmissionInterface(;
        id = 3, name = "iface_missing_base", available = true,
        active_power_flow_limits = PSY.IC.MinMax(; min = -1000.0, max = 1000.0),
        violation_penalty = 5000.0,
        direction_mapping = PSY.PO.TransmissionInterfaceDirectionMapping(;
            additional_properties = Dict{String, Int64}(),
        ),
    )
end

@testset "OpenAPI converters: Line" begin
    refs = _refs_with_area_bus()
    arc_po = PSY.PO.Arc(; id = 10, from_id = 3, to_id = 4)
    arc = PSY.from_openapi(arc_po, refs, NU)
    refs[10] = arc

    line_po = PSY.PO.Line(;
        id = 20, name = "line1", available = true,
        active_power_flow = 10.0, reactive_power_flow = 2.0, arc = 10,
        r = 0.01, x = 0.1, base_power = 100.0,
        b = PSY.IC.FromTo(; from = 0.001, to = 0.002),
        rating = 175.0, rating_b = 175.0, rating_c = nothing,
        angle_limits = PSY.IC.MinMax(; min = -1.57, max = 1.57),
        g = PSY.IC.FromTo(; from = 0.0, to = 0.0),
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )

    sys = System(100.0)
    add_component!(sys, refs[1])
    add_component!(sys, refs[2])
    add_component!(sys, refs[3])
    add_component!(sys, refs[4])

    line_natural = PSY.from_openapi(line_po, refs, NU)
    add_component!(sys, line_natural)
    @test get_rating(line_natural, SU) == 1.75
    @test get_active_power_flow(line_natural, SU) == 0.1
    @test get_reactive_power_flow(line_natural, SU) == 0.02
    @test get_rating_b(line_natural, SU) == 1.75
    @test isnothing(get_rating_c(line_natural, SU))
    @test get_r(line_natural, SU) == 0.01
    @test get_x(line_natural, SU) == 0.1
    @test get_b(line_natural, SU) == (from = 0.001, to = 0.002)
    # Line's own `base_power` is now a real PSY field, not just
    # a document-only per-line value read through `sbp`.
    @test get_base_power(line_natural) == 100.0

    line_po_device = PSY.PO.Line(;
        id = 21, name = "line2", available = true,
        active_power_flow = 10.0, reactive_power_flow = 2.0, arc = 10,
        r = 0.01, x = 0.1, base_power = 100.0,
        b = PSY.IC.FromTo(; from = 0.001, to = 0.002),
        rating = 175.0, rating_b = 175.0, rating_c = nothing,
        angle_limits = PSY.IC.MinMax(; min = -1.57, max = 1.57),
        g = PSY.IC.FromTo(; from = 0.0, to = 0.0),
        power_units = PSY.IC.UnitSystem("COMPONENT_BASE"),
    )
    line_device = PSY.from_openapi(line_po_device, refs, CU)
    add_component!(sys, line_device)
    @test get_rating(line_device, SU) == 175.0
    @test get_active_power_flow(line_device, SU) == 10.0
    @test get_reactive_power_flow(line_device, SU) == 2.0
    @test get_r(line_device, SU) == 0.01
    @test get_x(line_device, SU) == 0.1
    @test get_b(line_device, SU) == (from = 0.001, to = 0.002)
    @test get_base_power(line_device) == 100.0

    # `base_power`/`power_units` are non-defaulted fields on the wire type itself —
    # omitting either fails at construction, not at `from_openapi`.
    @test_throws UndefKeywordError PSY.PO.Line(;
        id = 22, name = "line3", available = true,
        active_power_flow = 10.0, reactive_power_flow = 2.0, arc = 10,
        r = 0.01, x = 0.1,
        b = PSY.IC.FromTo(; from = 0.001, to = 0.002),
        rating = 175.0, rating_b = 175.0, rating_c = nothing,
        angle_limits = PSY.IC.MinMax(; min = -1.57, max = 1.57),
        g = PSY.IC.FromTo(; from = 0.0, to = 0.0),
    )

    # `b`/`g` are `Absent`-by-omission on the wire (unlike `Line`'s other required fields
    # above); PSY has no `Union{Nothing, ...}` slot for either, so a document that omits them
    # must still build a zero-shunt `Line` rather than erroring on `Absent.from`.
    line_po_no_shunts = PSY.PO.Line(;
        id = 23, name = "line4", available = true,
        active_power_flow = 10.0, reactive_power_flow = 2.0, arc = 10,
        r = 0.01, x = 0.1, base_power = 100.0,
        rating = 175.0, rating_b = nothing, rating_c = nothing,
        angle_limits = PSY.IC.MinMax(; min = -1.57, max = 1.57),
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    for val in (CU, NU)
        line_no_shunts = PSY.from_openapi(line_po_no_shunts, refs, val)
        @test get_b(line_no_shunts, CU) == (from = 0.0, to = 0.0)
        @test get_g(line_no_shunts, CU) == (from = 0.0, to = 0.0)
    end
end

@testset "OpenAPI converters: TransformerCircuit / TwoWindingTransformer" begin
    refs = _refs_with_area_bus()
    arc_po = PSY.PO.Arc(; id = 10, from_id = 3, to_id = 4)
    refs[10] = PSY.from_openapi(arc_po, refs, NU)

    circuit_po = PSY.PO.TransformerCircuit(;
        id = 20, available = true, arc = 10, tap = 1.0, alpha = 0.05,
        parameter_units = PSY.PO.ImpedanceUnitBasis("COMPONENT_BASE"), r = 0.01,
        x = 0.1,
        control_objective = PSY.PO.TransformerControlObjective("UNDEFINED"),
        regulated_bus_number = 0,
        control_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        controlled_quantity_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        number_of_tap_positions = 33,
        rating = 100.0, rating_b = nothing, rating_c = nothing,
        active_power_flow = 5.0, reactive_power_flow = 1.0,
        base_power = 50.0, base_voltage_primary = 138.0, base_voltage_secondary = 69.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    circuit_natural =
        PSY.from_openapi(circuit_po, refs, NU)
    @test get_α(circuit_natural) == 0.05
    @test get_r(circuit_natural, CU) == 0.01
    @test get_x(circuit_natural, CU) == 0.1
    @test get_rating(circuit_natural, CU) == 2.0
    @test isnothing(get_rating_b(circuit_natural, CU))
    @test get_active_power_flow(circuit_natural, CU) == 0.1
    @test get_reactive_power_flow(circuit_natural, CU) == 0.02
    @test get_control_objective(circuit_natural) == TransformerControlObjective.UNDEFINED

    circuit_device =
        PSY.from_openapi(circuit_po, refs, CU)
    @test get_rating(circuit_device, CU) == 100.0
    @test get_active_power_flow(circuit_device, CU) == 5.0
    @test get_reactive_power_flow(circuit_device, CU) == 1.0

    bad_circuit_po = PSY.PO.TransformerCircuit(;
        id = 21, available = true, arc = 10, tap = 1.0, alpha = 0.0,
        parameter_units = PSY.PO.ImpedanceUnitBasis("NATURAL_UNITS"), r = 0.01, x = 0.1,
        control_objective = PSY.PO.TransformerControlObjective("UNDEFINED"),
        regulated_bus_number = 0,
        control_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        controlled_quantity_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        number_of_tap_positions = 33,
        rating = nothing, rating_b = nothing, rating_c = nothing,
        active_power_flow = 0.0, reactive_power_flow = 0.0,
        base_power = 50.0, base_voltage_primary = 138.0, base_voltage_secondary = 69.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    @test_throws ErrorException PSY.from_openapi(bad_circuit_po, refs, NU
    )

    refs[20] = circuit_natural
    xfmr_po = PSY.PO.TwoWindingTransformer(;
        id = 30, name = "xfmr1", circuit = 20,
        admittance_units = PSY.PO.AdmittanceUnitBasis("COMPONENT_BASE"),
        magnetizing_shunt = PSY.IC.ComplexNumber(; real = 0.01, imag = 0.02),
        shunt_location = PSY.PO.TwoWindingTransformerShuntLocation("PRIMARY"),
    )
    for val in (CU, NU)
        xfmr = PSY.from_openapi(xfmr_po, refs, val)
        @test get_magnetizing_shunt(xfmr, CU) == Complex(0.01, 0.02)
        @test get_shunt_location(xfmr) == TwoWindingTransformerShuntLocation.PRIMARY
        @test get_circuit(xfmr) === circuit_natural
    end

    bad_xfmr_po = PSY.PO.TwoWindingTransformer(;
        id = 31, name = "xfmr2", circuit = 20,
        admittance_units = PSY.PO.AdmittanceUnitBasis("COMPONENT_MVAR"),
        magnetizing_shunt = PSY.IC.ComplexNumber(; real = 0.0, imag = 0.0),
        shunt_location = PSY.PO.TwoWindingTransformerShuntLocation("PRIMARY"),
    )
    @test_throws ErrorException PSY.from_openapi(bad_xfmr_po, refs, CU
    )

    # `control_limits`/`controlled_quantity_limits` (`TransformerCircuit`) and
    # `magnetizing_shunt` (`TwoWindingTransformer`) are `Absent`-by-omission on the wire but
    # PSY declares real defaults for all three — a document omitting them must still build,
    # not error on `Absent.min`/`Absent.real`.
    circuit_po_no_limits = PSY.PO.TransformerCircuit(;
        id = 24, available = true, arc = 10, tap = 1.0, alpha = 0.05,
        parameter_units = PSY.PO.ImpedanceUnitBasis("COMPONENT_BASE"), r = 0.01,
        x = 0.1,
        control_objective = PSY.PO.TransformerControlObjective("UNDEFINED"),
        regulated_bus_number = 0,
        number_of_tap_positions = 33,
        rating = 100.0, rating_b = nothing, rating_c = nothing,
        active_power_flow = 5.0, reactive_power_flow = 1.0,
        base_power = 50.0, base_voltage_primary = 138.0, base_voltage_secondary = 69.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    for val in (CU, NU)
        circuit_no_limits = PSY.from_openapi(circuit_po_no_limits, refs, val)
        @test get_control_limits(circuit_no_limits) == (min = 0.9, max = 1.1)
        @test get_controlled_quantity_limits(circuit_no_limits) == (min = 0.9, max = 1.1)
    end

    xfmr_po_no_shunt = PSY.PO.TwoWindingTransformer(;
        id = 32, name = "xfmr3", circuit = 20,
        admittance_units = PSY.PO.AdmittanceUnitBasis("COMPONENT_BASE"),
        shunt_location = PSY.PO.TwoWindingTransformerShuntLocation("PRIMARY"),
    )
    for val in (CU, NU)
        xfmr_no_shunt = PSY.from_openapi(xfmr_po_no_shunt, refs, val)
        @test get_magnetizing_shunt(xfmr_no_shunt, CU) == Complex(0.0, 0.0)
    end
end

@testset "OpenAPI converters: ThreeWindingTransformer" begin
    refs = _refs_with_area_bus()
    star_po = _bus_po(5; area = 1, load_zone = 2, bustype = "PQ")
    refs[5] = PSY.from_openapi(star_po, refs, NU)

    arc1_po = PSY.PO.Arc(; id = 10, from_id = 3, to_id = 5)
    arc2_po = PSY.PO.Arc(; id = 11, from_id = 4, to_id = 5)
    arc3_po = PSY.PO.Arc(; id = 12, from_id = 3, to_id = 5)
    refs[10] = PSY.from_openapi(arc1_po, refs, NU)
    refs[11] = PSY.from_openapi(arc2_po, refs, NU)
    refs[12] = PSY.from_openapi(arc3_po, refs, NU)

    _circuit_po(id, arc) = PSY.PO.TransformerCircuit(;
        id = id, available = true, arc = arc, tap = 1.0, alpha = 0.0,
        parameter_units = PSY.PO.ImpedanceUnitBasis("COMPONENT_BASE"), r = 0.001,
        x = 0.01,
        control_objective = PSY.PO.TransformerControlObjective("UNDEFINED"),
        regulated_bus_number = 0,
        control_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        controlled_quantity_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        number_of_tap_positions = 33,
        rating = 100.0, rating_b = nothing, rating_c = nothing,
        active_power_flow = 0.0, reactive_power_flow = 0.0,
        base_power = 100.0, base_voltage_primary = 138.0,
        base_voltage_secondary = 138.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    refs[20] = PSY.from_openapi(_circuit_po(20, 10), refs, NU
    )
    refs[21] = PSY.from_openapi(_circuit_po(21, 11), refs, NU
    )
    refs[22] = PSY.from_openapi(_circuit_po(22, 12), refs, NU
    )

    t3w_po = PSY.PO.ThreeWindingTransformer(;
        id = 30, name = "t3w1", primary_circuit = 20, secondary_circuit = 21,
        tertiary_circuit = 22, star_bus = 5,
        parameter_units = PSY.PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r_12 = 0.01, x_12 = 0.1, r_23 = 0.015, x_23 = 0.15, r_31 = 0.02, x_31 = 0.2,
        base_power_12 = 100.0, base_power_23 = 100.0, base_power_31 = 100.0,
        admittance_units = PSY.PO.AdmittanceUnitBasis("COMPONENT_BASE"),
        magnetizing_shunt = PSY.IC.ComplexNumber(; real = 0.03, imag = 0.0),
        shunt_location = PSY.PO.ThreeWindingTransformerShuntLocation("STAR"),
    )
    for val in (CU, NU)
        t3w = PSY.from_openapi(t3w_po, refs, val)
        @test get_primary_circuit(t3w) === refs[20]
        @test get_secondary_circuit(t3w) === refs[21]
        @test get_tertiary_circuit(t3w) === refs[22]
        @test get_star_bus(t3w) === refs[5]
        @test get_r_12(t3w, CU) == 0.01
        @test get_x_12(t3w, CU) == 0.1
        @test get_r_23(t3w, CU) == 0.015
        @test get_r_31(t3w, CU) == 0.02
        @test get_base_power_12(t3w) == 100.0
        @test get_magnetizing_shunt(t3w, CU) == Complex(0.03, 0.0)
        @test get_shunt_location(t3w) == ThreeWindingTransformerShuntLocation.STAR
    end

    bad_t3w_po = PSY.PO.ThreeWindingTransformer(;
        id = 31, name = "t3w2", primary_circuit = 20, secondary_circuit = 21,
        tertiary_circuit = 22, star_bus = 5,
        parameter_units = PSY.PO.ImpedanceUnitBasis("NATURAL_UNITS"),
        admittance_units = PSY.PO.AdmittanceUnitBasis("COMPONENT_BASE"),
        magnetizing_shunt = PSY.IC.ComplexNumber(; real = 0.0, imag = 0.0),
        shunt_location = PSY.PO.ThreeWindingTransformerShuntLocation("STAR"),
    )
    @test_throws ErrorException PSY.from_openapi(bad_t3w_po, refs, CU
    )

    # `magnetizing_shunt` is `Absent`-by-omission but PSY defaults it to `0.0`; a document
    # omitting it must still build rather than erroring on `Absent.real`.
    t3w_po_no_shunt = PSY.PO.ThreeWindingTransformer(;
        id = 32, name = "t3w3", primary_circuit = 20, secondary_circuit = 21,
        tertiary_circuit = 22, star_bus = 5,
        parameter_units = PSY.PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r_12 = 0.01, x_12 = 0.1, r_23 = 0.015, x_23 = 0.15, r_31 = 0.02, x_31 = 0.2,
        base_power_12 = 100.0, base_power_23 = 100.0, base_power_31 = 100.0,
        admittance_units = PSY.PO.AdmittanceUnitBasis("COMPONENT_BASE"),
        shunt_location = PSY.PO.ThreeWindingTransformerShuntLocation("STAR"),
    )
    for val in (CU, NU)
        t3w_no_shunt = PSY.from_openapi(t3w_po_no_shunt, refs, val)
        @test get_magnetizing_shunt(t3w_no_shunt, CU) == Complex(0.0, 0.0)
    end

    # `r_12`/`x_12`/`r_23`/`x_23`/`r_31`/`x_31`/`base_power_12`/`_23`/`_31` are all
    # `Absent`-by-omission (the pairwise measured-impedance block is optional and must be set
    # together or not at all) but PSY declares `nothing` as each one's default — a document
    # omitting the whole block must still build rather than assigning `Absent` straight into a
    # `Union{Nothing, Float64}` field.
    t3w_po_no_pairwise = PSY.PO.ThreeWindingTransformer(;
        id = 33, name = "t3w4", primary_circuit = 20, secondary_circuit = 21,
        tertiary_circuit = 22, star_bus = 5,
        parameter_units = PSY.PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        admittance_units = PSY.PO.AdmittanceUnitBasis("COMPONENT_BASE"),
        magnetizing_shunt = PSY.IC.ComplexNumber(; real = 0.0, imag = 0.0),
        shunt_location = PSY.PO.ThreeWindingTransformerShuntLocation("STAR"),
    )
    for val in (CU, NU)
        t3w_no_pairwise = PSY.from_openapi(t3w_po_no_pairwise, refs, val)
        @test isnothing(get_r_12(t3w_no_pairwise, CU))
        @test isnothing(get_x_12(t3w_no_pairwise, CU))
        @test isnothing(get_r_23(t3w_no_pairwise, CU))
        @test isnothing(get_x_23(t3w_no_pairwise, CU))
        @test isnothing(get_r_31(t3w_no_pairwise, CU))
        @test isnothing(get_x_31(t3w_no_pairwise, CU))
        @test isnothing(get_base_power_12(t3w_no_pairwise))
        @test isnothing(get_base_power_23(t3w_no_pairwise))
        @test isnothing(get_base_power_31(t3w_no_pairwise))
    end
end

@testset "OpenAPI converters: ThermalStandard" begin
    refs = _refs_with_area_bus()
    cost_po = PSY.PC.ThermalGenerationCost(;
        cost_type = "THERMAL",
        fixed = 100.0, shut_down = 50.0,
        start_up = PSY.PC.ThermalGenerationCostStartUp(200.0),
        variable_operation_cost = PSY.PC.ProductionVariableCostCurve(
            PSY.PC.CostCurve(;
                power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
                value_curve = PSY.PC.ValueCurve(
                    PSY.PC.InputOutputCurve(;
                        function_data = PSY.PC.InputOutputCurveFunctionData(
                            PSY.IC.LinearFunctionData(;
                                proportional_term = 10.0, constant_term = 5.0,
                            ),
                        ),
                    ),
                ),
                vom_cost = PSY.PC.InputOutputCurve(;
                    function_data = PSY.PC.InputOutputCurveFunctionData(
                        PSY.IC.LinearFunctionData(;
                            proportional_term = 0.0, constant_term = 0.0,
                        ),
                    ),
                ),
            ),
        ),
    )
    thermal_po = PSY.PO.ThermalStandard(;
        id = 20, name = "gen1", available = true,
        status = PSY.PO.OperationalStates("ONLINE"), bus = 3,
        active_power = 50.0, reactive_power = 10.0, rating = 100.0,
        active_power_limits = PSY.IC.MinMax(; min = 10.0, max = 100.0),
        reactive_power_limits = PSY.IC.MinMax(; min = -50.0, max = 50.0),
        ramp_limits = PSY.IC.UpDown(; up = 20.0, down = 20.0),
        operation_cost = PSY.PO.ThermalStandardOperationCost(cost_po),
        base_power = 200.0,
        time_limits = PSY.IC.UpDown(; up = 2.0, down = 2.0),
        prime_mover_type = PSY.PC.PrimeMovers("OT"),
        fuel = PSY.PC.ThermalFuels("NATURAL_GAS"),
        time_at_status = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )

    gen_natural = PSY.from_openapi(thermal_po, refs, NU)
    @test get_active_power(gen_natural, CU) == 0.25
    @test get_reactive_power(gen_natural, CU) == 0.05
    @test get_rating(gen_natural, CU) == 0.5
    @test get_active_power_limits(gen_natural, CU) == (min = 0.05, max = 0.5)
    @test get_reactive_power_limits(gen_natural, CU) == (min = -0.25, max = 0.25)
    @test get_ramp_limits(gen_natural, CU / u"minute") == (up = 0.1, down = 0.1)
    @test get_prime_mover_type(gen_natural) == PrimeMovers.OT
    @test get_fuel(gen_natural) == ThermalFuels.NATURAL_GAS
    @test get_fixed(get_operation_cost(gen_natural)) == 100.0
    @test get_bus(gen_natural) === refs[3]
    @test get_status(gen_natural) == OperationalStates.ONLINE
    @test get_commitment_mode(gen_natural) == CommitmentModes.COMMITTED

    gen_device = PSY.from_openapi(thermal_po, refs, CU)
    @test get_active_power(gen_device, CU) == 50.0
    @test get_rating(gen_device, CU) == 100.0
    @test get_active_power_limits(gen_device, CU) == (min = 10.0, max = 100.0)
end

@testset "OpenAPI converters: PowerLoad" begin
    refs = _refs_with_area_bus()
    load_po = PSY.PO.PowerLoad(;
        id = 20, name = "load1", available = true, bus = 4,
        active_power = 30.0, reactive_power = 5.0, base_power = 100.0,
        max_active_power = 50.0, max_reactive_power = 10.0,
        conformity = PSY.PO.LoadConformity("CONFORMING"),
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    load_natural = PSY.from_openapi(load_po, refs, NU)
    @test get_active_power(load_natural, CU) == 0.3
    @test get_reactive_power(load_natural, CU) == 0.05
    @test get_max_active_power(load_natural, CU) == 0.5
    @test get_max_reactive_power(load_natural, CU) == 0.1
    @test get_conformity(load_natural) == LoadConformity.CONFORMING
    @test get_bus(load_natural) === refs[4]

    load_device = PSY.from_openapi(load_po, refs, CU)
    @test get_active_power(load_device, CU) == 30.0
    @test get_max_active_power(load_device, CU) == 50.0
end

@testset "OpenAPI converters: InterruptiblePowerLoad / ShiftablePowerLoad" begin
    refs = _refs_with_area_bus()
    cost_po = PSY.PC.LoadCost(;
        cost_type = "LOAD",
        fixed = 2400.0,
        variable_operation_cost = PSY.PC.CostCurve(;
            power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
            value_curve = PSY.PC.ValueCurve(
                PSY.PC.InputOutputCurve(;
                    function_data = PSY.PC.InputOutputCurveFunctionData(
                        PSY.IC.LinearFunctionData(;
                            proportional_term = 150.0, constant_term = 0.0,
                        ),
                    ),
                ),
            ),
            vom_cost = PSY.PC.InputOutputCurve(;
                function_data = PSY.PC.InputOutputCurveFunctionData(
                    PSY.IC.LinearFunctionData(;
                        proportional_term = 0.0,
                        constant_term = 0.0,
                    ),
                ),
            ),
        ),
    )
    iload_po = PSY.PO.InterruptiblePowerLoad(;
        id = 20, name = "iload1", available = true, bus = 4,
        active_power = 30.0, reactive_power = 5.0, max_active_power = 30.0,
        max_reactive_power = 5.0, base_power = 100.0,
        operation_cost = PSY.PO.InterruptiblePowerLoadOperationCost(cost_po),
        conformity = PSY.PO.LoadConformity("CONFORMING"),
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    iload_natural =
        PSY.from_openapi(iload_po, refs, NU)
    @test get_active_power(iload_natural, CU) == 0.3
    @test get_max_active_power(iload_natural, CU) == 0.3
    @test get_conformity(iload_natural) == LoadConformity.CONFORMING
    @test get_bus(iload_natural) === refs[4]
    @test get_fixed(get_operation_cost(iload_natural)) == 2400.0

    iload_device =
        PSY.from_openapi(iload_po, refs, CU)
    @test get_active_power(iload_device, CU) == 30.0

    sload_po = PSY.PO.ShiftablePowerLoad(;
        id = 21, name = "sload1", available = true, bus = 4,
        active_power = 30.0,
        active_power_limits = PSY.IC.MinMax(; min = 3.0, max = 30.0),
        reactive_power = 5.0, max_active_power = 30.0, max_reactive_power = 5.0,
        base_power = 100.0, load_balance_time_horizon = 24,
        operation_cost = PSY.PO.ShiftablePowerLoadOperationCost(cost_po),
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    sload_natural =
        PSY.from_openapi(sload_po, refs, NU)
    @test get_active_power(sload_natural, CU) == 0.3
    @test get_active_power_limits(sload_natural, CU) == (min = 0.03, max = 0.3)
    @test get_load_balance_time_horizon(sload_natural) == 24
    @test get_bus(sload_natural) === refs[4]

    sload_device =
        PSY.from_openapi(sload_po, refs, CU)
    @test get_active_power_limits(sload_device, CU) == (min = 3.0, max = 30.0)
end

@testset "OpenAPI converters: FixedAdmittance" begin
    refs = _refs_with_area_bus(; base_power = 100.0)

    # COMPONENT_MVAR divides by the document's system base: G = 0.0, B = -100.0 MVAr.
    mvar_po = PSY.PO.FixedAdmittance(;
        id = 20, name = "shunt1", available = true, bus = 4,
        admittance_units = PSY.PO.ShuntAdmittanceUnitBasis("COMPONENT_MVAR"),
        y = PSY.IC.ComplexNumber(; real = 0.0, imag = -100.0),
        base_power = 100.0,
    )
    for val in (CU, NU)
        shunt = PSY.from_openapi(mvar_po, refs, val)
        @test get_Y(shunt) == Complex(0.0, -1.0)
        @test get_bus(shunt) === refs[4]
        @test get_available(shunt)
    end

    # Round-trip on the COMPONENT_MVAR wire contract: import(export(x)) == x.
    registered = PSY.from_openapi(mvar_po, refs, CU)
    refs[20] = registered
    for val in (CU, NU)
        exported = PSY.to_openapi(registered, refs, val)
        @test exported.admittance_units.value == "COMPONENT_MVAR"
        @test exported.y.imag == -100.0
        round_tripped = PSY.from_openapi(exported, refs, val)
        @test get_Y(round_tripped) == get_Y(registered)
        @test get_name(round_tripped) == get_name(registered)
        @test get_bus(round_tripped) === get_bus(registered)
    end

    # NATURAL_UNITS (physical siemens) is not implemented.
    bad_po = PSY.PO.FixedAdmittance(;
        id = 22, name = "shunt3", available = true, bus = 4,
        admittance_units = PSY.PO.ShuntAdmittanceUnitBasis("NATURAL_UNITS"),
        y = PSY.IC.ComplexNumber(; real = 0.0, imag = 0.0),
        base_power = 100.0,
    )
    @test_throws ErrorException PSY.from_openapi(bad_po, refs, CU
    )
end

@testset "OpenAPI converters: HydroTurbine / HydroReservoir / HydroDispatch" begin
    refs = _refs_with_area_bus()
    hydro_cost_po = PSY.PC.HydroGenerationCost(;
        cost_type = "HYDRO_GEN",
        fixed = 1.0,
        variable_operation_cost = PSY.PC.ProductionVariableCostCurve(
            PSY.PC.CostCurve(;
                power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
                value_curve = PSY.PC.ValueCurve(
                    PSY.PC.InputOutputCurve(;
                        function_data = PSY.PC.InputOutputCurveFunctionData(
                            PSY.IC.LinearFunctionData(;
                                proportional_term = 1.0, constant_term = 0.0,
                            ),
                        ),
                    ),
                ),
                vom_cost = _io_curve(0.0, 0.0),
            ),
        ),
    )
    turbine_po = PSY.PO.HydroTurbine(;
        id = 20, name = "turb1", available = true, bus = 3,
        active_power = 20.0, reactive_power = 5.0, rating = 50.0,
        active_power_limits = PSY.IC.MinMax(; min = 0.0, max = 50.0),
        reactive_power_limits = PSY.IC.MinMax(; min = -20.0, max = 20.0),
        base_power = 100.0,
        operation_cost = PSY.PO.HydroTurbineOperationCost(hydro_cost_po),
        powerhouse_elevation = 100.0,
        ramp_limits = PSY.IC.UpDown(; up = 10.0, down = 10.0),
        time_limits = PSY.IC.UpDown(; up = 1.0, down = 1.0),
        outflow_limits = PSY.IC.MinMax(; min = 0.0, max = 500.0),
        efficiency = 0.9, turbine_type = PSY.PO.HydroTurbineTurbineType("FRANCIS"),
        conversion_factor = 1.0,
        prime_mover_type = PSY.PC.PrimeMovers("HY"), travel_time = 5.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    turbine = PSY.from_openapi(turbine_po, refs, NU)
    @test get_active_power(turbine, CU) == 0.2
    @test get_rating(turbine, CU) == 0.5
    @test get_turbine_type(turbine) == HydroTurbineType.FRANCIS
    @test get_fixed(get_operation_cost(turbine)) == 1.0
    refs[20] = turbine

    reservoir_po = PSY.PO.HydroReservoir(;
        id = 21, name = "reservoir1", available = true,
        storage_level_limits = PSY.IC.MinMax(; min = 0.0, max = 1000.0),
        initial_level = 500.0,
        spillage_limits = PSY.IC.MinMax(; min = 0.0, max = 100.0),
        inflow = 10.0, outflow = 8.0, level_targets = 600.0,
        intake_elevation = 50.0,
        head_to_volume_factor = PSY.IC.FunctionData(
            PSY.IC.LinearFunctionData(; proportional_term = 0.001, constant_term = 0.0),
        ),
        upstream_turbines = [20], downstream_turbines = Int[],
        upstream_reservoirs = Int[],
        operation_cost = PSY.PO.HydroReservoirOperationCost(
            PSY.PC.HydroReservoirCost(;
                cost_type = "HYDRO_RES",
                level_shortage_cost = 1.0, level_surplus_cost = 2.0, spillage_cost = 3.0,
            ),
        ),
        evaporative_loss = 0.0,
        level_data_type = PSY.PO.HydroReservoirLevelDataType("USABLE_VOLUME"),
    )
    reservoirs = HydroReservoir[]
    for val in (CU, NU)
        reservoir = PSY.from_openapi(reservoir_po, refs, val)
        # Absolute -> fraction-of-max, identical in both unit systems (semantic, not unit).
        @test get_initial_level(reservoir) == 0.5
        @test get_level_targets(reservoir) == 0.6
        @test get_inflow(reservoir) == 10.0
        # `upstream_turbines` is a `defer_ref!` closure until `resolve_deferred_refs!` runs
        # (see OpenAPIRefs) — the reservoir converts before its turbines can be relied on to
        # have registered, so it must not resolve eagerly.
        @test get_upstream_turbines(reservoir) == PSY.HydroUnit[]
        @test get_level_shortage_cost(get_operation_cost(reservoir)) == 1.0
        @test get_level_data_type(reservoir) == ReservoirDataType.USABLE_VOLUME
        push!(reservoirs, reservoir)
    end

    # A HydroReservoir carrying upstream_turbines=null, upstream_reservoirs=null, and a
    # populated downstream_turbines — a legitimate absence of association, not malformed
    # input. Must yield empty vectors, not a `MethodError: length(::Nothing)`.
    reservoir_head_po = PSY.PO.HydroReservoir(;
        id = 23, name = "reservoir_head", available = true,
        storage_level_limits = PSY.IC.MinMax(; min = 0.0, max = 1000.0),
        initial_level = 500.0,
        spillage_limits = PSY.IC.MinMax(; min = 0.0, max = 100.0),
        inflow = 10.0, outflow = 8.0, level_targets = 600.0,
        intake_elevation = 50.0,
        head_to_volume_factor = PSY.IC.FunctionData(
            PSY.IC.LinearFunctionData(; proportional_term = 0.001, constant_term = 0.0),
        ),
        upstream_turbines = nothing, downstream_turbines = [20],
        upstream_reservoirs = nothing,
        operation_cost = PSY.PO.HydroReservoirOperationCost(
            PSY.PC.HydroReservoirCost(;
                cost_type = "HYDRO_RES",
                level_shortage_cost = 1.0, level_surplus_cost = 2.0, spillage_cost = 3.0,
            ),
        ),
        evaporative_loss = 0.0,
        level_data_type = PSY.PO.HydroReservoirLevelDataType("USABLE_VOLUME"),
    )
    reservoir_heads = HydroReservoir[]
    for val in (CU, NU)
        reservoir_head = PSY.from_openapi(reservoir_head_po, refs, val)
        @test get_upstream_turbines(reservoir_head) == PSY.HydroUnit[]
        @test get_upstream_reservoirs(reservoir_head) == Device[]
        @test get_downstream_turbines(reservoir_head) == PSY.HydroUnit[]
        push!(reservoir_heads, reservoir_head)
    end

    # Draining the deferred queue is what actually resolves the turbine references above.
    PSY.resolve_deferred_refs!(refs)
    @test isempty(refs.deferred_refs)
    for reservoir in reservoirs
        @test get_upstream_turbines(reservoir) == [turbine]
    end
    for reservoir_head in reservoir_heads
        @test get_upstream_turbines(reservoir_head) == PSY.HydroUnit[]
        @test get_upstream_reservoirs(reservoir_head) == Device[]
        @test get_downstream_turbines(reservoir_head) == [turbine]
    end

    # A zero-capacity placeholder reservoir (the tail of an unmodeled pumped-storage pair).
    # The absolute -> fraction conversion divides by `storage_level_limits.max`, so this must
    # not come back as 0/0 = NaN: a NaN field silently poisons the system and only surfaces
    # later as a JSON write failure.
    reservoir_tail_po = PSY.PO.HydroReservoir(;
        id = 24, name = "reservoir_tail", available = true,
        storage_level_limits = PSY.IC.MinMax(; min = 0.0, max = 0.0),
        initial_level = 0.0,
        spillage_limits = nothing,
        inflow = 0.0, outflow = 0.0, level_targets = nothing,
        intake_elevation = 0.0,
        head_to_volume_factor = PSY.IC.FunctionData(
            PSY.IC.LinearFunctionData(; proportional_term = 0.0, constant_term = 0.0),
        ),
        upstream_turbines = [20], downstream_turbines = Int[],
        upstream_reservoirs = Int[],
        operation_cost = PSY.PO.HydroReservoirOperationCost(
            PSY.PC.HydroReservoirCost(;
                cost_type = "HYDRO_RES",
                level_shortage_cost = 0.0, level_surplus_cost = 0.0, spillage_cost = 0.0,
            ),
        ),
        evaporative_loss = 0.0,
        level_data_type = PSY.PO.HydroReservoirLevelDataType("ENERGY"),
    )
    for val in (CU, NU)
        reservoir_tail = PSY.from_openapi(reservoir_tail_po, refs, val)
        @test !isnan(get_initial_level(reservoir_tail))
        @test iszero(get_initial_level(reservoir_tail))
    end

    # Zero capacity but a nonzero level is contradictory, not a placeholder: the fraction is
    # undefined, so it must fail loudly rather than import a NaN.
    bad_reservoir_po = PSY.PO.HydroReservoir(;
        id = 25, name = "reservoir_bad", available = true,
        storage_level_limits = PSY.IC.MinMax(; min = 0.0, max = 0.0),
        initial_level = 500.0,
        spillage_limits = nothing,
        inflow = 0.0, outflow = 0.0, level_targets = nothing,
        intake_elevation = 0.0,
        head_to_volume_factor = PSY.IC.FunctionData(
            PSY.IC.LinearFunctionData(; proportional_term = 0.0, constant_term = 0.0),
        ),
        upstream_turbines = [20], downstream_turbines = Int[],
        upstream_reservoirs = Int[],
        operation_cost = PSY.PO.HydroReservoirOperationCost(
            PSY.PC.HydroReservoirCost(;
                cost_type = "HYDRO_RES",
                level_shortage_cost = 0.0, level_surplus_cost = 0.0, spillage_cost = 0.0,
            ),
        ),
        evaporative_loss = 0.0,
        level_data_type = PSY.PO.HydroReservoirLevelDataType("ENERGY"),
    )
    @test_throws ErrorException PSY.from_openapi(bad_reservoir_po, refs, CU)

    ror_po = PSY.PO.HydroDispatch(;
        id = 22, name = "ror1", available = true, bus = 3,
        active_power = 15.0, reactive_power = 3.0, rating = 40.0,
        prime_mover_type = PSY.PC.PrimeMovers("HY"),
        active_power_limits = PSY.IC.MinMax(; min = 0.0, max = 40.0),
        reactive_power_limits = PSY.IC.MinMax(; min = -15.0, max = 15.0),
        ramp_limits = PSY.IC.UpDown(; up = 10.0, down = 10.0),
        time_limits = PSY.IC.UpDown(; up = 1.0, down = 1.0),
        base_power = 100.0, status = PSY.PO.OperationalStates("ONLINE"),
        time_at_status = 50.0,
        operation_cost = PSY.PO.HydroDispatchOperationCost(hydro_cost_po),
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    ror_natural = PSY.from_openapi(ror_po, refs, NU)
    @test get_active_power(ror_natural, CU) == 0.15
    @test get_rating(ror_natural, CU) == 0.4
    ror_device = PSY.from_openapi(ror_po, refs, CU)
    @test get_active_power(ror_device, CU) == 15.0
end

@testset "OpenAPI converters: RenewableDispatch / RenewableNonDispatch / SynchronousCondenser" begin
    refs = _refs_with_area_bus()
    ren_cost_po = PSY.PC.RenewableGenerationCost(;
        cost_type = "RENEWABLE",
        fixed = 0.0,
        variable_operation_cost = PSY.PC.CostCurve(;
            power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
            value_curve = PSY.PC.ValueCurve(
                PSY.PC.InputOutputCurve(;
                    function_data = PSY.PC.InputOutputCurveFunctionData(
                        PSY.IC.LinearFunctionData(;
                            proportional_term = 0.0, constant_term = 0.0,
                        ),
                    ),
                ),
            ),
            vom_cost = _io_curve(0.0, 0.0),
        ),
    )
    wind_po = PSY.PO.RenewableDispatch(;
        id = 20, name = "wind1", available = true, bus = 4,
        active_power = 25.0, reactive_power = 5.0, rating = 50.0,
        prime_mover_type = PSY.PC.PrimeMovers("WT"),
        reactive_power_limits = PSY.IC.MinMax(; min = -20.0, max = 20.0),
        power_factor = 0.95,
        operation_cost = PSY.PO.RenewableDispatchOperationCost(ren_cost_po),
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    wind = PSY.from_openapi(wind_po, refs, NU)
    @test get_active_power(wind, CU) == 0.25
    @test get_rating(wind, CU) == 0.5
    @test get_prime_mover_type(wind) == PrimeMovers.WT
    @test get_power_factor(wind) == 0.95

    solar_po = PSY.PO.RenewableNonDispatch(;
        id = 21, name = "solar1", available = true, bus = 4,
        active_power = 15.0, reactive_power = 2.0, rating = 30.0,
        prime_mover_type = PSY.PC.PrimeMovers("PVe"), power_factor = 0.98,
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    solar = PSY.from_openapi(solar_po, refs, NU)
    @test get_active_power(solar, CU) == 0.15
    @test get_rating(solar, CU) == 0.3

    condenser_po = PSY.PO.SynchronousCondenser(;
        id = 22, name = "syncon1", available = true, bus = 3,
        reactive_power = 5.0, rating = 20.0,
        reactive_power_limits = PSY.IC.MinMax(; min = -20.0, max = 20.0),
        base_power = 100.0, active_power_losses = 1.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    condenser =
        PSY.from_openapi(condenser_po, refs, NU)
    @test get_reactive_power(condenser, CU) == 0.05
    @test get_rating(condenser, CU) == 0.2
    @test get_active_power_losses(condenser, CU) == 0.01
end

@testset "OpenAPI converters: EnergyReservoirStorage" begin
    refs = _refs_with_area_bus()
    storage_cost_po = PSY.PC.StorageCost(;
        cost_type = "STORAGE",
        charge_variable_cost = nothing, discharge_variable_cost = nothing,
        fixed = 0.0, shut_down = 0.0, start_up = PSY.PC.StorageCostStartUp(0.0),
        energy_shortage_cost = 0.0, energy_surplus_cost = 0.0,
    )
    storage_po = PSY.PO.EnergyReservoirStorage(;
        id = 20, name = "storage1", available = true, bus = 4,
        prime_mover_type = PSY.PC.PrimeMovers("BA"),
        storage_technology_type = PSY.PC.StorageTech("LIB"),
        storage_capacity = 400.0, energy_units = PSY.PO.EnergyUnitBasis("MWH"),
        storage_level_limits = PSY.IC.MinMax(; min = 0.0, max = 1.0),
        initial_storage_capacity_level = 0.5,
        rating = 100.0, active_power = 20.0,
        input_active_power_limits = PSY.IC.MinMax(; min = 0.0, max = 100.0),
        output_active_power_limits = PSY.IC.MinMax(; min = 0.0, max = 100.0),
        efficiency = PSY.IC.InOut(; in = 0.9, out = 0.9),
        reactive_power = 5.0,
        reactive_power_limits = PSY.IC.MinMax(; min = -50.0, max = 50.0),
        base_power = 200.0,
        operation_cost = PSY.PO.EnergyReservoirStorageOperationCost(storage_cost_po),
        conversion_factor = 1.0, storage_target = 0.5, cycle_limits = 10000,
        ramp_limits = PSY.IC.UpDown(; up = 100.0, down = 100.0),
        self_discharge = 0.0, standing_loss = 2.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    storage_natural =
        PSY.from_openapi(storage_po, refs, NU)
    @test get_storage_capacity(storage_natural, CU) == 2.0
    @test get_rating(storage_natural, CU) == 0.5
    @test get_active_power(storage_natural, CU) == 0.1
    @test get_input_active_power_limits(storage_natural, CU) == (min = 0.0, max = 0.5)
    @test get_output_active_power_limits(storage_natural, CU) == (min = 0.0, max = 0.5)
    @test get_reactive_power_limits(storage_natural, CU) == (min = -0.25, max = 0.25)
    @test get_ramp_limits(storage_natural, CU / u"minute") == (up = 0.5, down = 0.5)
    @test get_standing_loss(storage_natural, CU) == 0.01
    @test get_storage_technology_type(storage_natural) == StorageTech.LIB
    @test get_storage_level_limits(storage_natural) == (min = 0.0, max = 1.0)

    storage_device =
        PSY.from_openapi(storage_po, refs, CU)
    @test get_storage_capacity(storage_device, CU) == 400.0
    @test get_rating(storage_device, CU) == 100.0

    # An omitted basis selector takes the schema default.
    storage_po_no_units =
        _po_with(storage_po; id = 22, name = "storage3", energy_units = PSY.IC.ABSENT)
    for val in (CU, NU)
        storage_no_units = PSY.from_openapi(storage_po_no_units, refs, val)
        @test get_storage_technology_type(storage_no_units) == StorageTech.LIB
    end

    bad_storage_po = PSY.PO.EnergyReservoirStorage(;
        id = 21, name = "storage2", available = true, bus = 4,
        prime_mover_type = PSY.PC.PrimeMovers("BA"),
        storage_technology_type = PSY.PC.StorageTech("LIB"),
        storage_capacity = 400.0, energy_units = PSY.PO.EnergyUnitBasis("MWMIN"),
        storage_level_limits = PSY.IC.MinMax(; min = 0.0, max = 1.0),
        initial_storage_capacity_level = 0.5,
        rating = 100.0, active_power = 20.0,
        input_active_power_limits = PSY.IC.MinMax(; min = 0.0, max = 100.0),
        output_active_power_limits = PSY.IC.MinMax(; min = 0.0, max = 100.0),
        efficiency = PSY.IC.InOut(; in = 0.9, out = 0.9),
        reactive_power = 5.0,
        reactive_power_limits = PSY.IC.MinMax(; min = -50.0, max = 50.0),
        base_power = 200.0,
        operation_cost = PSY.PO.EnergyReservoirStorageOperationCost(storage_cost_po),
        conversion_factor = 1.0, storage_target = 0.5, cycle_limits = 10000,
        ramp_limits = PSY.IC.UpDown(; up = 100.0, down = 100.0),
        self_discharge = 0.0, standing_loss = 2.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    @test_throws ErrorException PSY.from_openapi(bad_storage_po, refs, NU
    )
end

@testset "OpenAPI converters: TwoTerminalGenericHVDCLine" begin
    refs = _refs_with_area_bus(; base_power = 100.0)
    arc_po = PSY.PO.Arc(; id = 10, from_id = 3, to_id = 4)
    refs[10] = PSY.from_openapi(arc_po, refs, NU)

    hvdc_po = PSY.PO.TwoTerminalGenericHVDCLine(;
        id = 20, name = "hvdc1", available = true, active_power_flow = 50.0, arc = 10,
        active_power_limits_from = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        active_power_limits_to = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        reactive_power_limits_from = PSY.IC.MinMax(; min = -50.0, max = 50.0),
        reactive_power_limits_to = PSY.IC.MinMax(; min = -50.0, max = 50.0),
        loss = PSY.PC.LossCurve(;
            power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
            value_curve = PSY.PC.LossValueCurve(
                PSY.PC.InputOutputCurve(;
                    curve_type = "INPUT_OUTPUT",
                    function_data = PSY.PC.InputOutputCurveFunctionData(
                        PSY.IC.LinearFunctionData(;
                            proportional_term = 0.01,
                            constant_term = 0.0,
                        ),
                    ),
                ),
            ),
        ),
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    sys = System(100.0)
    add_component!(sys, refs[1])
    add_component!(sys, refs[2])
    add_component!(sys, refs[3])
    add_component!(sys, refs[4])

    hvdc_natural =
        PSY.from_openapi(hvdc_po, refs, NU)
    add_component!(sys, hvdc_natural)
    @test get_active_power_flow(hvdc_natural, SU) == 0.5
    @test get_active_power_limits_from(hvdc_natural, SU) == (min = -1.0, max = 1.0)
    @test get_reactive_power_limits_to(hvdc_natural, SU) == (min = -0.5, max = 0.5)
    @test get_loss(hvdc_natural) == LossCurve(LinearCurve(0.01, 0.0), NaturalUnit())
    @test get_base_power(hvdc_natural) == 100.0

    # The loss keeps the basis its blob states instead of being rebuilt as natural units.
    hvdc_po_cu_loss = PSY.PO.TwoTerminalGenericHVDCLine(;
        id = 22, name = "hvdc_cu_loss", available = true, active_power_flow = 50.0,
        arc = 10,
        active_power_limits_from = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        active_power_limits_to = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        reactive_power_limits_from = PSY.IC.MinMax(; min = -50.0, max = 50.0),
        reactive_power_limits_to = PSY.IC.MinMax(; min = -50.0, max = 50.0),
        loss = _loss_curve_po(0.01, 0.0; power_units = "COMPONENT_BASE"),
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    @test get_loss(PSY.from_openapi(hvdc_po_cu_loss, refs, NU)) ==
          LossCurve(LinearCurve(0.01, 0.0), ComponentBaseUnit())

    # A blob omitting the required `base_power` cannot even be built: under OpenAPI.jl 1.x the
    # generated struct enforces the schema's `required` list, so the omission is caught at
    # construction instead of reaching `from_openapi`. `_require_base_power` still guards the
    # converter for blobs that arrive from elsewhere.
    @test_throws UndefKeywordError PSY.PO.TwoTerminalGenericHVDCLine(;
        id = 25, name = "hvdc_missing_base", available = true, active_power_flow = 50.0,
        arc = 10,
        active_power_limits_from = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        active_power_limits_to = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        reactive_power_limits_from = PSY.IC.MinMax(; min = -50.0, max = 50.0),
        reactive_power_limits_to = PSY.IC.MinMax(; min = -50.0, max = 50.0),
    )

    hvdc_po_device = PSY.PO.TwoTerminalGenericHVDCLine(;
        id = 21, name = "hvdc2", available = true, active_power_flow = 50.0, arc = 10,
        active_power_limits_from = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        active_power_limits_to = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        reactive_power_limits_from = PSY.IC.MinMax(; min = -50.0, max = 50.0),
        reactive_power_limits_to = PSY.IC.MinMax(; min = -50.0, max = 50.0),
        loss = PSY.PC.LossCurve(;
            power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
            value_curve = PSY.PC.LossValueCurve(
                PSY.PC.InputOutputCurve(;
                    curve_type = "INPUT_OUTPUT",
                    function_data = PSY.PC.InputOutputCurveFunctionData(
                        PSY.IC.LinearFunctionData(;
                            proportional_term = 0.01,
                            constant_term = 0.0,
                        ),
                    ),
                ),
            ),
        ),
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("COMPONENT_BASE"),
    )
    hvdc_device = PSY.from_openapi(hvdc_po_device,
        refs,
        CU,
    )
    add_component!(sys, hvdc_device)
    @test get_active_power_flow(hvdc_device, SU) == 50.0
    @test get_active_power_limits_from(hvdc_device, SU) == (min = -100.0, max = 100.0)
    @test get_base_power(hvdc_device) == 100.0
end

@testset "OpenAPI converters: TModelHVDCLine" begin
    # Exception among the branches: no `power_units` discriminator and no `base_power` at
    # all — `active_power_flow`/`active_power_limits_from/to` are fixed natural units (MW),
    # same posture as reserves' `requirement`, so import always divides by
    # `get_base_power(refs)`; `base_current`, not a power base, is `r`/`l`/`c`'s own anchor.
    # Self-interpretability: the physical MW value must survive regardless of which system
    # base the blob is imported into (100.0 here, 250.0 below) — there is no recorded base
    # on the wire to go stale.
    function _tmodel_refs_with_dcbuses(base_power)
        refs = PSY.OpenAPIRefs(base_power)
        dcbus_from_po = PSY.PO.DCBus(;
            id = 30, number = 30, name = "dcbus30", available = true,
            magnitude = 1.0, voltage_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
            base_voltage = 500.0,
        )
        dcbus_to_po = PSY.PO.DCBus(;
            id = 31, number = 31, name = "dcbus31", available = true,
            magnitude = 1.0, voltage_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
            base_voltage = 500.0,
        )
        refs[30] = PSY.from_openapi(dcbus_from_po, refs)
        refs[31] = PSY.from_openapi(dcbus_to_po, refs)
        arc_po = PSY.PO.Arc(; id = 32, from_id = 30, to_id = 31)
        refs[32] = PSY.from_openapi(arc_po, refs, NU)
        return refs
    end

    tmodel_po = PSY.PO.TModelHVDCLine(;
        id = 33, name = "tmodel1", available = true, active_power_flow = 125.0,
        arc = 32,
        parameter_units = PSY.PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        base_current = 200.0,
        r = 0.01, l = 0.02, c = 0.03,
        active_power_limits_from = PSY.IC.MinMax(; min = -250.0, max = 250.0),
        active_power_limits_to = PSY.IC.MinMax(; min = -250.0, max = 250.0),
    )
    @test !hasfield(PSY.PO.TModelHVDCLine, :power_units)
    @test !hasfield(PSY.PO.TModelHVDCLine, :base_power)

    refs_100 = _tmodel_refs_with_dcbuses(100.0)
    sys_100 = System(100.0)
    add_component!(sys_100, refs_100[30])
    add_component!(sys_100, refs_100[31])
    tmodel_100 = PSY.from_openapi(tmodel_po, refs_100)
    add_component!(sys_100, tmodel_100)
    @test get_active_power_flow(tmodel_100, u"MW") == 125.0
    @test get_active_power_limits_from(tmodel_100, u"MW") == (min = -250.0, max = 250.0)
    @test get_base_current(tmodel_100) == 200.0

    # Default import kwarg is 100.0 (see `from_openapi(::Type{System}, doc)`); a mismatched
    # target base (250.0 here) must still recover the same physical MW value.
    refs_250 = _tmodel_refs_with_dcbuses(250.0)
    sys_250 = System(250.0)
    add_component!(sys_250, refs_250[30])
    add_component!(sys_250, refs_250[31])
    tmodel_250 = PSY.from_openapi(tmodel_po, refs_250)
    add_component!(sys_250, tmodel_250)
    @test get_active_power_flow(tmodel_250, u"MW") == 125.0
    @test get_active_power_limits_to(tmodel_250, u"MW") == (min = -250.0, max = 250.0)

    # The schema default `NATURAL_UNITS` is unimplemented here, so omission errors.
    tmodel_po_no_units =
        _po_with(tmodel_po; id = 34, name = "tmodel2", parameter_units = PSY.IC.ABSENT)
    @test_throws ErrorException PSY.from_openapi(tmodel_po_no_units, refs_100)
end

@testset "OpenAPI converters: SwitchedAdmittance" begin
    refs = _refs_with_area_bus(; base_power = 100.0)

    # `admittance_limits` is `Absent`-by-omission but PSY defaults it to `(min=1.0, max=1.0)`
    # (a dimensionless multiplier bound, not a raw admittance) — a document omitting it must
    # still build rather than erroring on `Absent.min`.
    sh_po = PSY.PO.SwitchedAdmittance(;
        id = 20, name = "sw1", available = true, bus = 4,
        admittance_units = PSY.PO.ShuntAdmittanceUnitBasis("COMPONENT_MVAR"),
        y_increase = [PSY.IC.ComplexNumber(; real = 0.0, imag = -10.0)],
        solved_admittance = nothing,
    )
    for val in (CU, NU)
        sh = PSY.from_openapi(sh_po, refs, val)
        @test get_admittance_limits(sh) == (min = 1.0, max = 1.0)
    end

    # `y_increase` and `solved_admittance` are both `Absent`-by-omission; PSY defaults them to
    # an empty vector and `nothing` respectively — a document omitting either must still build
    # rather than erroring on `iterate(::Absent)`/`Absent / base_power`.
    sh_po_no_optional = PSY.PO.SwitchedAdmittance(;
        id = 21, name = "sw2", available = true, bus = 4,
        admittance_units = PSY.PO.ShuntAdmittanceUnitBasis("COMPONENT_MVAR"),
    )
    for val in (CU, NU)
        sh_no_optional = PSY.from_openapi(sh_po_no_optional, refs, val)
        @test get_Y_increase(sh_no_optional) == ComplexF64[]
        @test isnothing(get_solved_admittance(sh_no_optional))
    end

    sh_po_no_units =
        _po_with(sh_po; id = 22, name = "sw3", admittance_units = PSY.IC.ABSENT)
    for val in (CU, NU)
        sh_no_units = PSY.from_openapi(sh_po_no_units, refs, val)
        @test get_admittance_limits(sh_no_units) == (min = 1.0, max = 1.0)
    end
end

@testset "OpenAPI converters: TwoTerminalLCCLine" begin
    refs = _refs_with_area_bus(; base_power = 100.0)
    arc_po = PSY.PO.Arc(; id = 10, from_id = 3, to_id = 4)
    refs[10] = PSY.from_openapi(arc_po, refs, NU)

    # `rectifier_tap_limits`/`inverter_tap_limits`/`active_power_limits_from`/
    # `active_power_limits_to`/`reactive_power_limits_from`/`reactive_power_limits_to` are all
    # `Absent`-by-omission but PSY declares a real default for each — a document omitting them
    # must still build rather than erroring on `Absent.min`.
    lcc_po = PSY.PO.TwoTerminalLCCLine(;
        id = 20, name = "lcc1", available = true, arc = 10,
        active_power_flow = 50.0, r = 0.01, transfer_setpoint = 50.0, power_mode = true,
        scheduled_dc_voltage = 200.0,
        rectifier_bridges = 2, rectifier_rc = 0.001, rectifier_xc = 0.01,
        rectifier_base_voltage = 138.0, rectifier_capacitor_reactance = 0.0,
        rectifier_delay_angle_limits = PSY.IC.MinMax(; min = 0.0, max = 1.0),
        inverter_bridges = 2, inverter_rc = 0.001, inverter_xc = 0.01,
        inverter_base_voltage = 138.0, inverter_capacitor_reactance = 0.0,
        inverter_extinction_angle_limits = PSY.IC.MinMax(; min = 0.0, max = 1.0),
        compounding_resistance = 0.0,
        parameter_units = PSY.PO.ImpedanceUnitBasis("NATURAL_UNITS"),
        dc_voltage_units = PSY.PO.VoltageUnitBasis("NATURAL_UNITS"),
        loss = _loss_curve_po(0.01, 0.0),
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    for val in (CU, NU)
        lcc = PSY.from_openapi(lcc_po, refs, val)
        @test get_rectifier_tap_limits(lcc) == (min = 0.51, max = 1.5)
        @test get_inverter_tap_limits(lcc) == (min = 0.51, max = 1.5)
        @test get_active_power_limits_from(lcc, CU) == (min = 0.0, max = 0.0)
        @test get_active_power_limits_to(lcc, CU) == (min = 0.0, max = 0.0)
        @test get_reactive_power_limits_from(lcc, CU) == (min = 0.0, max = 0.0)
        @test get_reactive_power_limits_to(lcc, CU) == (min = 0.0, max = 0.0)
    end

    # `compounding_resistance`/`rectifier_capacitor_reactance`/`inverter_capacitor_reactance`
    # are `Absent`-by-omission but PSY defaults each to `0.0` ohm — a document omitting them
    # must still build rather than erroring inside `_lcc_ohm_to_pu`. `power_mode` is likewise
    # `Absent`-by-omission with a PSY default of `true`; the `NaturalUnit` method reads it
    # through `Val(...)` when picking `transfer_setpoint`'s unit, so an omitted `power_mode`
    # must still resolve to the `ActivePower` (MW) branch rather than erroring on `Val(Absent)`.
    lcc_po_no_optional = PSY.PO.TwoTerminalLCCLine(;
        id = 21, name = "lcc2", available = true, arc = 10,
        active_power_flow = 50.0, r = 0.01, transfer_setpoint = 50.0,
        scheduled_dc_voltage = 200.0,
        rectifier_bridges = 2, rectifier_rc = 0.001, rectifier_xc = 0.01,
        rectifier_base_voltage = 138.0,
        rectifier_delay_angle_limits = PSY.IC.MinMax(; min = 0.0, max = 1.0),
        inverter_bridges = 2, inverter_rc = 0.001, inverter_xc = 0.01,
        inverter_base_voltage = 138.0,
        inverter_extinction_angle_limits = PSY.IC.MinMax(; min = 0.0, max = 1.0),
        parameter_units = PSY.PO.ImpedanceUnitBasis("NATURAL_UNITS"),
        dc_voltage_units = PSY.PO.VoltageUnitBasis("NATURAL_UNITS"),
        loss = _loss_curve_po(0.01, 0.0),
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    lcc_device_no_optional = PSY.from_openapi(lcc_po_no_optional, refs, CU)
    @test get_compounding_resistance(lcc_device_no_optional) == 0.0
    @test get_rectifier_capacitor_reactance(lcc_device_no_optional) == 0.0
    @test get_inverter_capacitor_reactance(lcc_device_no_optional) == 0.0
    @test get_power_mode(lcc_device_no_optional)
    @test get_transfer_setpoint(lcc_device_no_optional) == 50.0

    lcc_natural_no_optional = PSY.from_openapi(lcc_po_no_optional, refs, NU)
    @test get_compounding_resistance(lcc_natural_no_optional) == 0.0
    @test get_rectifier_capacitor_reactance(lcc_natural_no_optional) == 0.0
    @test get_inverter_capacitor_reactance(lcc_natural_no_optional) == 0.0
    @test get_power_mode(lcc_natural_no_optional)
    @test get_transfer_setpoint(lcc_natural_no_optional) == 0.5
    @test get_transfer_setpoint(lcc_natural_no_optional, NU) ≈ 50.0
    @test get_transfer_setpoint(lcc_natural_no_optional, CU) ≈ 0.5
    # Current mode stores Amperes, which no power base converts.
    lcc_current = PSY.from_openapi(
        _po_with(lcc_po_no_optional; id = 23, name = "lcc_current", power_mode = false),
        refs,
        NU,
    )
    @test get_transfer_setpoint(lcc_current) == 50.0
    @test get_transfer_setpoint(lcc_current, NU) == 50.0
    @test get_transfer_setpoint(lcc_current, SU) == 50.0

    lcc_po_no_units = _po_with(
        lcc_po_no_optional;
        id = 22, name = "lcc3",
        parameter_units = PSY.IC.ABSENT,
        dc_voltage_units = PSY.IC.ABSENT,
    )
    for val in (CU, NU)
        lcc_no_units = PSY.from_openapi(lcc_po_no_units, refs, val)
        @test get_r(lcc_no_units) > 0.0
    end
end

@testset "OpenAPI converters: Source" begin
    refs = _refs_with_area_bus(; base_power = 100.0)

    # `R_th`/`X_th` are `Absent`-by-omission on the wire; the PSY-side code previously read
    # `po.R_th`/`po.X_th` — a case mismatch with the generated `r_th`/`x_th` field names — so
    # every `Source` import threw `FieldError` regardless of whether either was omitted.
    # `base_voltage` is the same "raw `Absent` passthrough" bug as `R_th`/`X_th`, on the field
    # right below them in this same function.
    source_po = PSY.PO.Source(;
        id = 20, name = "src1", available = true, bus = 4,
        parameter_units = PSY.PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        active_power_limits = PSY.IC.MinMax(; min = -10.0, max = 10.0),
        base_power = 100.0,
        operation_cost = PSY.PO.SourceOperationCost(
            PSY.PC.ImportExportCost(;
                energy_export_weekly_limit = 1e9,
                energy_import_weekly_limit = 1e9,
                import_offer_curves = nothing,
                export_offer_curves = nothing,
            ),
        ),
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    for val in (CU, NU)
        src = PSY.from_openapi(source_po, refs, val)
        @test get_R_th(src) == 0.0
        @test get_X_th(src) == 0.0
        @test isnothing(get_base_voltage(src))
    end

    source_po_no_units =
        _po_with(source_po; id = 21, name = "src2", parameter_units = PSY.IC.ABSENT)
    for val in (CU, NU)
        src_no_units = PSY.from_openapi(source_po_no_units, refs, val)
        @test get_R_th(src_no_units) == 0.0
    end
end

@testset "OpenAPI converters: InterconnectingConverter" begin
    refs = _refs_with_area_bus(; base_power = 100.0)
    dcbus_po = PSY.PO.DCBus(;
        id = 30, number = 30, name = "dcbus30", available = true,
        magnitude = 1.0, voltage_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        base_voltage = 500.0,
    )
    refs[30] = PSY.from_openapi(dcbus_po, refs)

    # `loss_function` is `Absent`-by-omission; the PSY-side code called
    # `_vsc_converter_loss(convert_cost(po.loss_function))` directly on the wire's `LossCurve`
    # instead of `_vsc_loss` (which unwraps `.value_curve` and checks `power_units` first, the
    # way `TwoTerminalVSCLine.converter_loss_from/to` already do), so every
    # `InterconnectingConverter` import threw `convert_cost: unmapped variant LossCurve`
    # regardless of whether `loss_function` was omitted. `remote_bus_control` is the same "raw
    # `Absent` passthrough" bug as `Source.base_voltage`, a few fields below `loss_function`.
    ic_po = PSY.PO.InterconnectingConverter(;
        id = 20, name = "ic1", available = true, bus = 4, dc_bus = 30,
        active_power = 10.0, rating = 100.0,
        active_power_limits = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        base_power = 100.0,
        voltage_setpoint_units = PSY.PO.VoltageUnitBasis("COMPONENT_BASE"),
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    for val in (CU, NU)
        ic = PSY.from_openapi(ic_po, refs, val)
        @test get_loss_function(ic) == LossCurve(LinearCurve(0.0), NaturalUnit())
        @test isnothing(get_remote_bus_control(ic))
        @test get_voltage_limits(ic) == (min = 0.0, max = 999.9)
    end

    # A quadratic `loss_function` authored on the component base keeps that basis.
    ic_po_cu_loss = PSY.PO.InterconnectingConverter(;
        id = 21, name = "ic_cu_loss", available = true, bus = 4, dc_bus = 30,
        active_power = 10.0, rating = 100.0,
        active_power_limits = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        base_power = 100.0,
        voltage_setpoint_units = PSY.PO.VoltageUnitBasis("COMPONENT_BASE"),
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
        loss_function = PSY.PC.LossCurve(;
            power_units = PSY.IC.UnitSystem("COMPONENT_BASE"),
            value_curve = PSY.PC.LossValueCurve(
                PSY.PC.InputOutputCurve(;
                    curve_type = "INPUT_OUTPUT",
                    function_data = PSY.PC.InputOutputCurveFunctionData(
                        PSY.IC.QuadraticFunctionData(;
                            quadratic_term = 0.01,
                            proportional_term = 0.01,
                            constant_term = 0.0,
                        ),
                    ),
                ),
            ),
        ),
    )
    @test get_loss_function(PSY.from_openapi(ic_po_cu_loss, refs, NU)) ==
          LossCurve(QuadraticCurve(0.01, 0.01, 0.0), ComponentBaseUnit())

    ic_po_no_units =
        _po_with(ic_po; id = 21, name = "ic2", voltage_setpoint_units = PSY.IC.ABSENT)
    for val in (CU, NU)
        ic_no_units = PSY.from_openapi(ic_po_no_units, refs, val)
        @test get_loss_function(ic_no_units) == LossCurve(LinearCurve(0.0), NaturalUnit())
    end
end

@testset "OpenAPI converters: AreaInterchange (generated)" begin
    # First type to carry `openapi_type` while sharing the "no device `base_power`"
    # shape that previously forced Area/LoadZone/TransmissionInterface/Line/
    # TwoTerminalGenericHVDCLine to be hand-written — closed at the codegen level by
    # giving `AreaInterchange` its own `base_power` field rather than hand-writing a ninth
    # copy of the fallback. Also exercises the `FromTo_ToFrom` compound alias
    # (`from_to`/`to_from`), the first struct to combine it with `openapi_type`.
    refs = _refs_with_area_bus()
    # `_refs_with_area_bus` only registers one `Area` (id 1) and one `LoadZone` (id 2); a
    # second `Area` is needed since AreaInterchange's `to_area` is typed `Area`, not `LoadZone`.
    area2_po = PSY.PO.Area(;
        id = 20, name = "area2", peak_active_power = 50.0, peak_reactive_power = 10.0,
        load_response = 0.0, base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    refs[20] = PSY.from_openapi(area2_po, refs, NU)

    interchange_po = PSY.PO.AreaInterchange(;
        id = 10, name = "flow12", available = true, active_power_flow = 25.0,
        from_area = 1, to_area = 20,
        flow_limits = PSY.IC.FromToToFrom(; from_to = 100.0, to_from = -100.0),
        base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )
    device = PSY.from_openapi(interchange_po, refs, CU)
    @test get_active_power_flow(device, PSY.CU) == 25.0
    @test get_flow_limits(device, PSY.CU) == (from_to = 100.0, to_from = -100.0)
    @test get_from_area(device) === refs[1]
    @test get_to_area(device) === refs[20]
    @test get_base_power(device) == 100.0

    natural = PSY.from_openapi(interchange_po, refs, NU)
    @test get_active_power_flow(natural, PSY.CU) == 0.25
    @test get_flow_limits(natural, PSY.CU) == (from_to = 1.0, to_from = -1.0)
    @test get_base_power(natural) == 100.0

    @test_throws ErrorException PSY.from_openapi(
        PSY.PO.AreaInterchange(;
            id = 11, name = "bad", available = true, active_power_flow = 1.0,
            from_area = 999, to_area = 20,
            flow_limits = PSY.IC.FromToToFrom(; from_to = 0.0, to_from = 0.0),
            base_power = 100.0,
            power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
        ),
        refs,
        CU,
    )
end

@testset "OpenAPI converters: Substation (hand-written, no descriptor entry)" begin
    refs = PSY.OpenAPIRefs(100.0)
    po =
        PSY.PO.Substation(; id = 30, name = "SUB1", number = 7, grounding_resistance = 0.25)
    attr = PSY.from_openapi(po, refs)
    @test get_name(attr) == "SUB1"
    @test get_number(attr) == 7
    @test get_grounding_resistance(attr) == 0.25

    # `grounding_resistance` has a PSY-side default (0.1) but no wire-side default: the PO
    # struct declares it a plain `Float64` with no `Absent`/`Nothing` variant, so omitting it
    # fails at construction rather than falling back inside `from_openapi`.
    @test_throws UndefKeywordError PSY.PO.Substation(; id = 31, name = "SUB2", number = 8)
end

@testset "OpenAPI converters: reserves" begin
    refs = PSY.OpenAPIRefs(100.0)
    sys = System(100.0)

    online_po = PSY.PO.OnlineReserve(;
        id = 1, name = "spin_up", available = true, time_frame = 10.0,
        requirement = 100.0, variable = nothing, sustained_time = 60.0,
        max_output_fraction = 1.0, max_participation_factor = 1.0,
        deployed_fraction = 1.0, reserve_direction = PSY.PO.ReserveDirection("UP"),
    )
    online_natural = PSY.from_openapi(online_po, refs, NU)
    add_component!(sys, online_natural)
    @test online_natural isa OnlineReserve{ReserveUp}
    @test get_requirement(online_natural, SU) == 1.0
    @test get_variable(online_natural) == PSY.ZERO_OFFER_CURVE

    online_po_device = PSY.PO.OnlineReserve(;
        id = 1, name = "spin_up_device", available = true, time_frame = 10.0,
        requirement = 100.0, variable = nothing, sustained_time = 60.0,
        max_output_fraction = 1.0, max_participation_factor = 1.0,
        deployed_fraction = 1.0, reserve_direction = PSY.PO.ReserveDirection("UP"),
    )
    online_device =
        PSY.from_openapi(online_po_device, refs, CU)
    add_component!(sys, online_device)
    @test get_requirement(online_device, SU) == 1.0

    down_po = PSY.PO.OnlineReserve(;
        id = 2, name = "spin_down", available = true, time_frame = 10.0,
        requirement = 50.0, variable = nothing, sustained_time = 60.0,
        max_output_fraction = 1.0, max_participation_factor = 1.0,
        deployed_fraction = 1.0, reserve_direction = PSY.PO.ReserveDirection("DOWN"),
    )
    @test PSY.from_openapi(down_po, refs, NU) isa
          OnlineReserve{ReserveDown}

    sym_po = PSY.PO.OnlineReserve(;
        id = 3, name = "spin_sym", available = true, time_frame = 10.0,
        requirement = 50.0, variable = nothing, sustained_time = 60.0,
        max_output_fraction = 1.0, max_participation_factor = 1.0,
        deployed_fraction = 1.0,
        reserve_direction = PSY.PO.ReserveDirection("SYMMETRIC"),
    )
    @test PSY.from_openapi(sym_po, refs, NU) isa
          OnlineReserve{ReserveSymmetric}

    # The PO layer's own OpenAPI-generated enum validation rejects an unmapped
    # reserve_direction before construction even completes.
    @test_throws Exception PSY.PO.OnlineReserve(;
        id = 4, name = "bogus", available = true, time_frame = 10.0,
        requirement = 50.0, variable = nothing, sustained_time = 60.0,
        max_output_fraction = 1.0, max_participation_factor = 1.0,
        deployed_fraction = 1.0, reserve_direction = "BOGUS",
    )
    # The converter's own direction table errors loudly too, exercised directly since a
    # real PO struct can never carry a value outside its own enum whitelist.
    @test_throws ErrorException PSY._resolve_reserve_direction("BOGUS", "test")

    ordc_po = PSY.PC.CostCurve(;
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
        value_curve = PSY.PC.ValueCurve(
            PSY.PC.IncrementalCurve(;
                function_data = PSY.PC.IncrementalCurveFunctionData(
                    PSY.IC.PiecewiseStepData(; x_coords = [0.0, 100.0], y_coords = [10.0]),
                ),
                initial_input = 0.0,
            ),
        ),
        vom_cost = PSY.PC.InputOutputCurve(;
            function_data = PSY.PC.InputOutputCurveFunctionData(
                PSY.IC.LinearFunctionData(; proportional_term = 0.0, constant_term = 0.0),
            ),
        ),
    )
    ordc_reserve_po = PSY.PO.OnlineReserve(;
        id = 5, name = "spin_ordc", available = true, time_frame = 10.0,
        requirement = 100.0, variable = ordc_po, sustained_time = 60.0,
        max_output_fraction = 1.0, max_participation_factor = 1.0,
        deployed_fraction = 1.0, reserve_direction = PSY.PO.ReserveDirection("UP"),
    )
    ordc_reserve =
        PSY.from_openapi(ordc_reserve_po, refs, NU)
    @test get_variable(ordc_reserve) isa CostCurve{PiecewiseIncrementalCurve}

    offline_po = PSY.PO.OfflineReserve(;
        id = 6, name = "nonspin", available = true, time_frame = 10.0,
        requirement = 50.0, variable = nothing, sustained_time = 60.0,
        max_output_fraction = 1.0, max_participation_factor = 1.0,
        deployed_fraction = 1.0,
    )
    offline_natural =
        PSY.from_openapi(offline_po, refs, NU)
    add_component!(sys, offline_natural)
    @test get_requirement(offline_natural, SU) == 0.5

    offline_po_device = PSY.PO.OfflineReserve(;
        id = 6, name = "nonspin_device", available = true, time_frame = 10.0,
        requirement = 50.0, variable = nothing, sustained_time = 60.0,
        max_output_fraction = 1.0, max_participation_factor = 1.0,
        deployed_fraction = 1.0,
    )
    offline_device =
        PSY.from_openapi(offline_po_device, refs, CU)
    add_component!(sys, offline_device)
    @test get_requirement(offline_device, SU) == 0.5

    group_po = PSY.PO.GroupReserve(;
        id = 7, name = "group_up", available = true, requirement = 150.0,
        reserve_direction = PSY.PO.ReserveDirection("UP"),
    )
    group_natural = PSY.from_openapi(group_po, refs, NU)
    add_component!(sys, group_natural)
    @test group_natural isa GroupReserve{ReserveUp}
    @test get_requirement(group_natural, SU) == 1.5

    group_po_device = PSY.PO.GroupReserve(;
        id = 7, name = "group_up_device", available = true, requirement = 150.0,
        reserve_direction = PSY.PO.ReserveDirection("UP"),
    )
    group_device = PSY.from_openapi(group_po_device, refs, CU)
    add_component!(sys, group_device)
    @test get_requirement(group_device, SU) == 1.5
end

@testset "OpenAPI converters: TwoTerminalVSCLine" begin
    refs = _refs_with_area_bus(; base_power = 100.0)
    arc_po = PSY.PO.Arc(; id = 10, from_id = 3, to_id = 4)
    refs[10] = PSY.from_openapi(arc_po, refs, NU)

    # rated_dc_voltage = 200 kV on a 100 MVA base ⇒ Ybase = 100/200^2 = 0.0025 S,
    # so g = 0.5 S is 200.0 pu, and a 204 kV DC setpoint is 1.02 pu.
    vsc_po = PSY.PO.TwoTerminalVSCLine(;
        id = 20, name = "vsc1", available = true, arc = 10,
        active_power_flow = 50.0, rating = 200.0,
        active_power_limits_from = PSY.IC.MinMax(; min = -200.0, max = 200.0),
        active_power_limits_to = PSY.IC.MinMax(; min = -200.0, max = 200.0),
        admittance_units = PSY.PO.AdmittanceUnitBasis("NATURAL_UNITS"), g = 0.5,
        dc_current = 300.0, reactive_power_from = 10.0,
        dc_control_from = PSY.PO.VSCDCControlModes("DC_POWER"),
        ac_control_from = PSY.PO.VSCACControlModes("AC_REACTIVE_POWER"),
        dc_setpoint_from = 40.0, ac_setpoint_from = 0.95,
        converter_loss_from = _loss_curve_po(1.2, 0.5),
        max_dc_current_from = 1000.0, rating_from = 200.0,
        reactive_power_limits_from = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        power_factor_weighting_fraction_from = 0.5,
        voltage_units = PSY.PO.VoltageUnitBasis("NATURAL_UNITS"),
        # NATURAL_UNITS: `dc_setpoint_to` below is kV, divided by `rated_dc_voltage`.
        setpoint_voltage_units = PSY.PO.VoltageUnitBasis("NATURAL_UNITS"),
        voltage_limits_from = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        dc_voltage_droop_from = 0.0, reactive_power_to = 20.0,
        dc_control_to = PSY.PO.VSCDCControlModes("DC_VOLTAGE"),
        ac_control_to = PSY.PO.VSCACControlModes("AC_REACTIVE_POWER"),
        dc_setpoint_to = 204.0, ac_setpoint_to = 0.98,
        converter_loss_to = _loss_curve_po(1.1, 0.4),
        max_dc_current_to = 1000.0, rating_to = 200.0,
        reactive_power_limits_to = PSY.IC.MinMax(; min = -100.0, max = 100.0),
        power_factor_weighting_fraction_to = 0.5,
        voltage_limits_to = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        dc_voltage_droop_to = 0.0, rated_dc_voltage = 200.0,
        remote_bus_control_from = nothing, remote_bus_control_to = 4,
        rmpct_from = 100.0, rmpct_to = 100.0, base_power = 100.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )

    sys = System(100.0)
    for id in (1, 2, 3, 4)
        add_component!(sys, refs[id])
    end
    add_component!(sys, refs[10])

    natural = PSY.from_openapi(vsc_po, refs, NU)
    add_component!(sys, natural)
    @test get_active_power_flow(natural, SU) == 0.5
    @test get_rating(natural, SU) == 2.0
    @test get_active_power_limits_from(natural, SU) == (min = -2.0, max = 2.0)
    @test get_reactive_power_limits_to(natural, SU) == (min = -1.0, max = 1.0)
    # DC_POWER setpoint is a power field: divides under NaturalUnit only.
    @test get_dc_setpoint_from(natural) == 0.4
    # DC_VOLTAGE setpoint is kV → pu of rated_dc_voltage, in both unit systems.
    @test get_dc_setpoint_to(natural) == 1.02
    # Siemens → pu is governed by admittance_units, not the document unit system.
    @test get_g(natural) == 200.0
    # Amperes, dimensionless, and kV fields have no base to convert against.
    @test get_dc_current(natural) == 300.0
    @test get_ac_setpoint_from(natural) == 0.95
    @test get_voltage_limits_from(natural) == (min = 0.9, max = 1.1)
    @test get_rated_dc_voltage(natural) == 200.0
    @test isnothing(get_remote_bus_control_from(natural))
    @test get_remote_bus_control_to(natural) == 4
    @test get_converter_loss_from(natural) ==
          LossCurve(LinearCurve(1.2, 0.5), NaturalUnit())

    vsc_po2 = _po_with(vsc_po; id = 21, name = "vsc2")
    device = PSY.from_openapi(vsc_po2, refs, CU)
    add_component!(sys, device)
    @test get_active_power_flow(device, SU) == 50.0
    @test get_active_power_limits_from(device, SU) == (min = -200.0, max = 200.0)
    @test get_dc_setpoint_from(device) == 40.0
    @test get_dc_setpoint_to(device) == 1.02
    @test get_g(device) == 200.0

    # `reactive_power_limits_from`/`_to` and `voltage_limits_from`/`_to` are
    # `Absent`-by-omission on the wire but PSY declares real defaults for all four; a document
    # omitting them must still build rather than erroring on `Absent.min`.
    vsc_po_no_limits = _po_with(
        vsc_po;
        id = 22, name = "vsc3",
        reactive_power_limits_from = PSY.IC.ABSENT,
        reactive_power_limits_to = PSY.IC.ABSENT,
        voltage_limits_from = PSY.IC.ABSENT,
        voltage_limits_to = PSY.IC.ABSENT,
    )
    for val in (CU, NU)
        vsc_no_limits = PSY.from_openapi(vsc_po_no_limits, refs, val)
        @test get_reactive_power_limits_from(vsc_no_limits, CU) == (min = 0.0, max = 0.0)
        @test get_reactive_power_limits_to(vsc_no_limits, CU) == (min = 0.0, max = 0.0)
        @test get_voltage_limits_from(vsc_no_limits) == (min = 0.0, max = 999.9)
        @test get_voltage_limits_to(vsc_no_limits) == (min = 0.0, max = 999.9)
    end

    vsc_po_no_voltage_units =
        _po_with(vsc_po; id = 23, name = "vsc4", voltage_units = PSY.IC.ABSENT)
    for val in (CU, NU)
        vsc_no_voltage_units = PSY.from_openapi(vsc_po_no_voltage_units, refs, val)
        @test get_voltage_limits_from(vsc_no_voltage_units) == (min = 0.9, max = 1.1)
    end

    # `dc_setpoint_to` scales by `setpoint_voltage_units`.
    vsc_po_no_setpoint_units =
        _po_with(vsc_po; id = 24, name = "vsc5", setpoint_voltage_units = PSY.IC.ABSENT)
    for val in (CU, NU)
        vsc_no_setpoint_units = PSY.from_openapi(vsc_po_no_setpoint_units, refs, val)
        @test get_dc_setpoint_to(vsc_no_setpoint_units) == 1.02
    end

    vsc_po_no_admittance_units =
        _po_with(vsc_po; id = 25, name = "vsc6", admittance_units = PSY.IC.ABSENT)
    for val in (CU, NU)
        vsc_no_admittance_units = PSY.from_openapi(vsc_po_no_admittance_units, refs, val)
        @test get_g(vsc_no_admittance_units) == 200.0
    end
end

@testset "OpenAPI converters: TwoTerminalVSCLine AC_VOLTAGE setpoint under COMPONENT_BASE" begin
    refs = _refs_with_area_bus(; base_power = 100.0)
    refs[10] =
        PSY.from_openapi(PSY.PO.Arc(; id = 10, from_id = 3, to_id = 4), refs, NU)

    # `setpoint_voltage_units = COMPONENT_BASE` means `ac_setpoint_from` is already per-unit
    # of the converter's own AC base voltage — PSY's own convention — so it passes through
    # unscaled with no `rated_ac_voltage_from` needed. This is what
    # PowerFlowFileParser's PSS/E reader writes for every VSC line (`make_vscline!`).
    vsc_po = _vsc_po_minimal(;
        ac_control_from = PSY.PO.VSCACControlModes("AC_VOLTAGE"),
        ac_setpoint_from = 1.03,
        setpoint_voltage_units = PSY.PO.VoltageUnitBasis("COMPONENT_BASE"),
    )

    natural = PSY.from_openapi(vsc_po, refs, NU)
    @test get_ac_setpoint_from(natural) == 1.03
    @test get_rated_ac_voltage_from(natural) == 0.0

    vsc_po2 = _po_with(vsc_po; id = 22, name = "vsc3")
    device = PSY.from_openapi(vsc_po2, refs, CU)
    @test get_ac_setpoint_from(device) == 1.03
end

@testset "OpenAPI converters: TwoTerminalVSCLine AC_VOLTAGE setpoint under NATURAL_UNITS" begin
    refs = _refs_with_area_bus(; base_power = 100.0)
    refs[10] =
        PSY.from_openapi(PSY.PO.Arc(; id = 10, from_id = 3, to_id = 4), refs, NU)

    # `setpoint_voltage_units = NATURAL_UNITS` (the schema default) means `ac_setpoint_from`
    # is kV, converted through `rated_ac_voltage_from` — the AC-side counterpart of
    # `rated_dc_voltage`, now a real wire-row field PowerFlowFileParser's `make_vscline!`
    # writes from the terminal's own RAW bus base voltage — exactly like `dc_setpoint_*`'s
    # DC-voltage branches convert through `rated_dc_voltage`.
    vsc_po = _vsc_po_minimal(;
        ac_control_from = PSY.PO.VSCACControlModes("AC_VOLTAGE"),
        ac_setpoint_from = 234.6,
        rated_ac_voltage_from = 230.0,
        setpoint_voltage_units = PSY.PO.VoltageUnitBasis("NATURAL_UNITS"),
    )

    for val in (NU, CU)
        vsc = PSY.from_openapi(vsc_po, refs, val)
        @test get_rated_ac_voltage_from(vsc) == 230.0
        @test get_ac_setpoint_from(vsc) == 234.6 / 230.0
    end
end

@testset "OpenAPI converters: TwoTerminalVSCLine quadratic converter loss" begin
    refs = _refs_with_area_bus(; base_power = 100.0)
    refs[10] =
        PSY.from_openapi(PSY.PO.Arc(; id = 10, from_id = 3, to_id = 4), refs, NU)
    vsc_po = _vsc_po_minimal(;
        converter_loss_to = PSY.PC.LossCurve(;
            power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
            value_curve = PSY.PC.LossValueCurve(
                PSY.PC.InputOutputCurve(;
                    function_data = PSY.PC.InputOutputCurveFunctionData(
                        PSY.IC.QuadraticFunctionData(;
                            quadratic_term = 0.01, proportional_term = 1.1,
                            constant_term = 0.4,
                        ),
                    ),
                ),
            ),
        ),
    )
    vsc = PSY.from_openapi(vsc_po, refs, NU)
    @test get_converter_loss_to(vsc) ==
          LossCurve(QuadraticCurve(0.01, 1.1, 0.4), NaturalUnit())
end

@testset "OpenAPI converters: TwoTerminalVSCLine setpoint_voltage_units selects the basis" begin
    refs = _refs_with_area_bus(; base_power = 100.0)
    refs[10] =
        PSY.from_openapi(PSY.PO.Arc(; id = 10, from_id = 3, to_id = 4), refs, NU)

    # NATURAL_UNITS: kV in the document, divided by the base each side is expressed against —
    # `rated_dc_voltage` (200.0) on the DC side, `rated_ac_voltage_from` (138.0) on the AC side.
    natural = _vsc_po_minimal(;
        setpoint_voltage_units = PSY.PO.VoltageUnitBasis("NATURAL_UNITS"),
        dc_control_to = PSY.PO.VSCDCControlModes("DC_VOLTAGE"),
        dc_setpoint_to = 204.0,
        ac_control_from = PSY.PO.VSCACControlModes("AC_VOLTAGE"),
        ac_setpoint_from = 141.45,
        rated_ac_voltage_from = 138.0,
    )
    vsc_natural = PSY.from_openapi(natural, refs, NU)
    @test get_dc_setpoint_to(vsc_natural) == 204.0 / 200.0
    @test get_ac_setpoint_from(vsc_natural) == 141.45 / 138.0

    # COMPONENT_BASE: already the per-unit PSY stores, so both pass through untouched.
    device = _vsc_po_minimal(;
        setpoint_voltage_units = PSY.PO.VoltageUnitBasis("COMPONENT_BASE"),
        dc_control_to = PSY.PO.VSCDCControlModes("DC_VOLTAGE"),
        dc_setpoint_to = 1.02,
        ac_control_from = PSY.PO.VSCACControlModes("AC_VOLTAGE"),
        ac_setpoint_from = 1.025,
    )
    vsc_device = PSY.from_openapi(device, refs, NU)
    @test get_dc_setpoint_to(vsc_device) == 1.02
    @test get_ac_setpoint_from(vsc_device) == 1.025

    # A basis outside the schema's two never reaches PSY, which is why
    # `_check_vsc_setpoint_voltage_units` only ever sees a legal value. Under OpenAPI.jl 1.x
    # the generated structs are immutable and each enum is its own wrapper type validating in
    # its constructor, so the rejection happens at construction rather than on assignment.
    @test_throws ArgumentError PSY.PO.VoltageUnitBasis("SYSTEM_BASE")
end

@testset "OpenAPI converters: TwoTerminalVSCLine unconvertible inputs error" begin
    refs = _refs_with_area_bus(; base_power = 100.0)
    refs[10] =
        PSY.from_openapi(PSY.PO.Arc(; id = 10, from_id = 3, to_id = 4), refs, NU)

    # An AC_VOLTAGE setpoint under NATURAL_UNITS (the schema default) is kV, converted
    # through `rated_ac_voltage_from` — but `_vsc_po_minimal` leaves it at `0.0`
    # (unspecified), so there is still no base to convert this particular value against. See
    # the "setpoint_voltage_units selects the basis" testset above for the case where a base
    # IS given.
    ac_voltage = _vsc_po_minimal(;
        ac_control_from = PSY.PO.VSCACControlModes("AC_VOLTAGE"),
    )
    @test_throws ErrorException PSY.from_openapi(ac_voltage, refs, NU)

    # Only NATURAL_UNITS is implemented for either unit-basis selector.
    bad_admittance = _vsc_po_minimal(;
        admittance_units = PSY.PO.AdmittanceUnitBasis("COMPONENT_BASE"),
    )
    @test_throws ErrorException PSY.from_openapi(bad_admittance,
        refs,
        NU,
    )

    bad_voltage = _vsc_po_minimal(;
        voltage_units = PSY.PO.VoltageUnitBasis("COMPONENT_BASE"),
    )
    @test_throws ErrorException PSY.from_openapi(bad_voltage, refs, NU)

    # A non-zero g with no DC voltage base is unconvertible; a zero one is not.
    no_base = _vsc_po_minimal(; rated_dc_voltage = 0.0, g = 0.5)
    @test_throws ErrorException PSY.from_openapi(no_base, refs, NU)

    no_base_zero_g = _po_with(no_base; g = 0.0)
    @test iszero(get_g(PSY.from_openapi(no_base_zero_g, refs, NU)))
end

@testset "OpenAPI converters: InterruptibleStandardLoad (generated)" begin
    # Same ZIP fields as StandardLoad plus an `operation_cost`, which is what kept it off
    # the generated path until its descriptor gained `openapi_type`.
    refs = _refs_with_area_bus(; base_power = 100.0)
    load_po = PSY.PO.InterruptibleStandardLoad(;
        id = 30, name = "load1", available = true, bus = 3, base_power = 100.0,
        operation_cost = PSY.PO.InterruptibleStandardLoadOperationCost(
            PSY.PC.LoadCost(;
                cost_type = "LOAD",
                fixed = 2400.0,
                variable_operation_cost = PSY.PC.CostCurve(;
                    power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
                    value_curve = PSY.PC.ValueCurve(_io_curve(150.0, 0.0)),
                    vom_cost = _io_curve(0.0, 0.0),
                ),
            ),
        ),
        conformity = PSY.PO.LoadConformity("CONFORMING"),
        constant_active_power = 50.0, constant_reactive_power = 10.0,
        impedance_active_power = 20.0, impedance_reactive_power = 5.0,
        current_active_power = 30.0, current_reactive_power = 7.0,
        max_constant_active_power = 60.0, max_constant_reactive_power = 12.0,
        max_impedance_active_power = 25.0, max_impedance_reactive_power = 6.0,
        max_current_active_power = 35.0, max_current_reactive_power = 8.0,
        power_units = PSY.IC.UnitSystem("NATURAL_UNITS"),
    )

    natural = PSY.from_openapi(load_po, refs, NU)
    @test get_bus(natural) === refs[3]
    @test get_constant_active_power(natural, CU) == 0.5
    @test get_impedance_reactive_power(natural, CU) == 0.05
    @test get_max_current_active_power(natural, CU) == 0.35
    @test get_conformity(natural) == LoadConformity.CONFORMING

    device = PSY.from_openapi(load_po, refs, CU)
    @test get_constant_active_power(device, CU) == 50.0
    @test get_max_current_active_power(device, CU) == 35.0
end
