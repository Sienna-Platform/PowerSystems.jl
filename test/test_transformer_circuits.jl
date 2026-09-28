function _test_circuit(; base_power = 20.0, system_base = 100.0)
    arc = Arc(ACBus(nothing), ACBus(nothing))
    c = TransformerCircuit(;
        arc = arc,
        tap = 1.05,
        α = 0.0,
        available = true,
        r = 0.02,               # CU on the 20 MVA / 138 kV circuit base
        x = 0.1,
        rating = 0.5,           # CU: 0.5 * 20 MVA = 10 MVA
        rating_b = nothing,
        rating_c = nothing,
        active_power_flow = 0.1,
        reactive_power_flow = 0.05,
        base_power = base_power,
        base_voltage_primary = 138.0,
        input_basis = CU,
    )
    IS.set_base_value!(c, system_base)
    return c
end

@testset "TransformerCircuit plain accessors" begin
    c = _test_circuit()
    @test get_tap(c) == 1.05
    @test get_α(c) == 0.0
    @test get_available(c)
    @test get_control_objective(c) == TransformerControlObjective.UNDEFINED
    @test !has_control(c)
    @test get_base_power(c) == 20.0
    @test get_base_voltage_primary(c) == 138.0
    set_tap!(c, 1.0)
    @test get_tap(c) == 1.0
end

@testset "TransformerCircuit explicit-units getters use the circuit base" begin
    c = _test_circuit()
    @test get_rating(c, CU) ≈ 0.5
    @test get_rating(c, SU) ≈ 0.5 * 20.0 / 100.0
    @test get_rating(c, NU) ≈ 10.0
    @test get_active_power_flow(c, NU) ≈ 0.1 * 20.0
    @test isnothing(get_rating_b(c, SU))

    # Impedance (r/x): pu on circuit base_power referenced to base_voltage_primary.
    # Z_su = Z_du * (system_base / base_power); Z_nu = Z_du * (V² / base_power).
    @test get_r(c, CU) ≈ 0.02
    @test get_r(c, SU) ≈ 0.02 * (100.0 / 20.0)
    @test get_r(c, NU) ≈ 0.02 * (138.0^2 / 20.0)
    @test get_x(c, SU) ≈ 0.1 * (100.0 / 20.0)
end

@testset "TransformerCircuit tagged setters round-trip" begin
    c = _test_circuit()
    set_rating!(c, 0.2 * SU)              # 0.2 SU = 20 MVA = 1.0 CU
    @test get_rating(c, CU) ≈ 1.0
    set_active_power_flow!(c, 5.0 * CU)
    @test get_active_power_flow(c, CU) ≈ 5.0
    @test_throws ArgumentError set_rating!(c, 0.9)   # bare floats rejected

    # Ω input divides by the circuit impedance base V²/base_power.
    z_base = 138.0^2 / 20.0
    set_x!(c, 0.3 * z_base * u"Ω")
    @test get_x(c, CU) ≈ 0.3
    @test get_x(c, u"Ω") ≈ 0.3 * z_base
end

@testset "TransformerCircuit detached errors cleanly on SU" begin
    c = _test_circuit()
    IS.set_base_value!(c, nothing)
    @test get_rating(c, CU) ≈ 0.5          # CU needs no system base
    @test_throws ErrorException get_rating(c, SU)
end

@testset "predicates" begin
    c = _test_circuit()
    @test !is_phase_shifting(c)
    set_α!(c, 0.3)
    @test is_phase_shifting(c)
    set_α!(c, 0.0)
    set_control_objective!(c, TransformerControlObjective.ACTIVE_POWER_FLOW)
    @test is_phase_shifting(c)
    @test has_control(c)
    set_control_objective!(c, TransformerControlObjective.VOLTAGE)
    @test has_control(c)
    @test !is_phase_shifting(c)   # voltage control is not a phase shift
end

@testset "parent constructors" begin
    t2w = TwoWindingTransformer(nothing)
    @test get_shunt_location(t2w) == TwoWindingTransformerShuntLocation.PRIMARY
    t3w = ThreeWindingTransformer(nothing)
    @test get_shunt_location(t3w) == ThreeWindingTransformerShuntLocation.PRIMARY
end

function _test_t3w(; system_base = 100.0)
    t = ThreeWindingTransformer(nothing)
    PowerSystems.set_units_setting!(t, system_base)
    set_base_power_12!(t, 15.0)
    set_base_power_23!(t, 20.0)
    set_base_power_31!(t, 25.0)
    set_base_power!(get_primary_circuit(t), 15.0)
    set_base_power!(get_secondary_circuit(t), 20.0)
    set_base_power!(get_tertiary_circuit(t), 25.0)
    set_base_voltage_primary!(get_primary_circuit(t), 230.0)
    set_base_voltage_primary!(get_secondary_circuit(t), 138.0)
    set_base_voltage_primary!(get_tertiary_circuit(t), 69.0)
    return t
end

@testset "get_circuits and derived availability" begin
    t = _test_t3w()
    @test length(get_circuits(t)) == 3
    foreach(c -> set_available!(c, true), get_circuits(t))
    @test get_available(t)
    set_available!(get_secondary_circuit(t), false)
    @test get_available(t)                      # any-semantics
    foreach(c -> set_available!(c, false), get_circuits(t))
    @test !get_available(t)
    set_available!(t, true)                     # fan-out restore (documented asymmetry)
    @test all(get_available, get_circuits(t))

    t2 = TwoWindingTransformer(nothing)
    @test length(get_circuits(t2)) == 1
    set_available!(t2, true)
    @test get_available(t2) == get_available(get_circuit(t2))
end

@testset "pairwise impedance converts against pair base" begin
    t = _test_t3w()
    set_r_12!(t, 0.02 * CU)
    @test get_r_12(t, CU) ≈ 0.02
    # Independent derivation (not the engine under test): Zpu_su = Zpu_du * (Zbase_du / Zbase_su).
    # Zbase_du = V^2 / base_power_12 = V^2 / 15; Zbase_su = V^2 / system_base = V^2 / 100.
    # The base voltage V cancels in the ratio, leaving Zpu_su = Zpu_du * (system_base / base_power_12)
    # = 0.02 * (100.0 / 15.0).
    @test get_r_12(t, SU) ≈ 0.02 * (100.0 / 15.0)   # Zpu_su = Zpu_du * sb/db for impedance

    # Same derivation on the other two pairs, each against ITS OWN pair base —
    # catches a wrong-pair-base selection (e.g. r_23 accidentally using base_power_12).
    set_r_23!(t, 0.03 * CU)
    @test get_r_23(t, CU) ≈ 0.03
    @test get_r_23(t, SU) ≈ 0.03 * (100.0 / 20.0)   # base_power_23 = 20

    set_r_31!(t, 0.04 * CU)
    @test get_r_31(t, CU) ≈ 0.04
    @test get_r_31(t, SU) ≈ 0.04 * (100.0 / 25.0)   # base_power_31 = 25
    # r_31 is referenced to the TERTIARY circuit voltage (69 kV): NU uses that base.
    @test get_r_31(t, NU) ≈ 0.04 * (69.0^2 / 25.0)
end

@testset "units settings propagate to circuits" begin
    t = _test_t3w()
    @test !isnothing(IS.get_base_value(get_primary_circuit(t)))
    PowerSystems.set_units_setting!(t, nothing)
    @test isnothing(IS.get_base_value(get_primary_circuit(t)))
end

function _test_t2w(; system_base = 100.0)
    t = TwoWindingTransformer(nothing)
    PowerSystems.set_units_setting!(t, system_base)
    set_base_voltage_primary!(get_circuit(t), 138.0)
    return t
end

@testset "hand-written circuit setters propagate the units anchor" begin
    # set_circuit!/set_primary_circuit!/set_secondary_circuit!/set_tertiary_circuit!
    # are `exclude_setter: true` in the descriptor precisely because the
    # generated `value.circuit = val` form would install a circuit whose
    # `base_value` is stale (or nothing, if freshly constructed) relative to
    # the owning transformer's System. These setters must copy the parent's
    # current anchor onto the incoming circuit.
    t2 = _test_t2w()
    fresh_2w = TransformerCircuit(;
        available = true,
        arc = Arc(ACBus(nothing), ACBus(nothing)),
        rating = 0.5,
        base_power = 100.0,
        input_basis = CU,
    )
    @test isnothing(IS.get_base_value(fresh_2w))
    set_circuit!(t2, fresh_2w)
    @test get_circuit(t2) === fresh_2w
    @test IS.get_base_value(get_circuit(t2)) === IS.get_base_value(t2)
    @test get_rating(get_circuit(t2), SU) ≈ 0.5   # base_power == system_base here

    t3 = _test_t3w()
    fresh_3w = TransformerCircuit(;
        available = true,
        arc = Arc(ACBus(nothing), ACBus(nothing)),
        rating = 0.5,
        base_power = 15.0,
        input_basis = CU,
    )
    @test isnothing(IS.get_base_value(fresh_3w))
    set_primary_circuit!(t3, fresh_3w)
    @test get_primary_circuit(t3) === fresh_3w
    @test IS.get_base_value(get_primary_circuit(t3)) === IS.get_base_value(t3)
    @test get_rating(get_primary_circuit(t3), SU) ≈ 0.5 * 15.0 / 100.0
end

@testset "2W r/x forward to the circuit" begin
    t = _test_t2w()
    c = get_circuit(t)
    set_base_power!(c, 100.0)
    set_x!(t, 0.1 * CU)
    @test get_x(t, CU) ≈ 0.1
    @test get_x(t, CU) == get_x(c, CU)
    set_r!(t, 0.02 * CU)
    @test get_r(c, CU) ≈ 0.02
end

@testset "2W parent magnetizing_shunt units round-trip" begin
    # The magnetizing shunt is a parent field; its :siemens conversion resolves
    # bases through the 2W forwarding provider: component base = the circuit's
    # base_power, base voltage = the circuit's base_voltage_primary.
    t = _test_t2w()                       # system_base = 100.0, circuit V = 138.0
    set_base_power!(get_circuit(t), 20.0)
    set_magnetizing_shunt!(t, (0.05 + 0.0im) * CU)
    # Admittance: Y_su = Y_du * (base_power / system_base); Y_nu = Y_du * (base_power / V²).
    @test get_magnetizing_shunt(t, CU) ≈ 0.05
    @test get_magnetizing_shunt(t, SU) ≈ 0.05 * (20.0 / 100.0)
    @test get_magnetizing_shunt(t, NU) ≈ 0.05 * (20.0 / 138.0^2)
    # S input divides by the admittance base base_power/V².
    y_base = 20.0 / 138.0^2
    set_magnetizing_shunt!(t, (4.0 * y_base) * u"S")
    @test get_magnetizing_shunt(t, CU) ≈ 4.0
end

@testset "3W parent magnetizing_shunt uses base_power_12 and the primary base voltage" begin
    # The 3W magnetizing shunt is pu on base_power_12 (= 15) referenced to the
    # primary circuit's base voltage (= 230 kV) — the restored PairBase mapping.
    t = _test_t3w()                       # system_base = 100.0
    set_magnetizing_shunt!(t, (0.05 + 0.0im) * CU)
    @test get_magnetizing_shunt(t, CU) ≈ 0.05
    @test get_magnetizing_shunt(t, SU) ≈ 0.05 * (15.0 / 100.0)
    @test get_magnetizing_shunt(t, NU) ≈ 0.05 * (15.0 / 230.0^2)
    y_base = 15.0 / 230.0^2
    set_magnetizing_shunt!(t, (3.0 * y_base) * u"S")
    @test get_magnetizing_shunt(t, CU) ≈ 3.0
end

@testset "shunt location enums construct and serialize" begin
    @test string(TwoWindingTransformerShuntLocation.SPLIT) == "SPLIT"
    @test string(ThreeWindingTransformerShuntLocation.STAR) == "STAR"

    # Scoped enums serialize by name; the String constructor round-trips (incl. STAR).
    for loc in (
        TwoWindingTransformerShuntLocation.PRIMARY,
        TwoWindingTransformerShuntLocation.SECONDARY,
        TwoWindingTransformerShuntLocation.SPLIT,
    )
        @test TwoWindingTransformerShuntLocation.Value(string(loc)) == loc
    end
    @test ThreeWindingTransformerShuntLocation.Value("STAR") ==
          ThreeWindingTransformerShuntLocation.STAR
    @test ThreeWindingTransformerShuntLocation.Value("PRIMARY") ==
          ThreeWindingTransformerShuntLocation.PRIMARY
end

@testset "2W add_component!/remove_component! with runchecks on" begin
    sys = System(100.0)
    b1 = ACBus(nothing)
    b1.number = 1
    b1.name = "b1"
    b1.base_voltage = 230.0
    b2 = ACBus(nothing)
    b2.number = 2
    b2.name = "b2"
    b2.base_voltage = 138.0
    add_component!(sys, b1)
    add_component!(sys, b2)
    t = TwoWindingTransformer(nothing)
    t.name = "t2w1"
    c = get_circuit(t)
    set_arc!(c, Arc(b1, b2))
    set_rating!(c, 1.0 * CU)
    set_x!(t, 0.1 * CU)
    add_component!(sys, t)   # runchecks defaults to true; validation must pass
    @test get_component(TwoWindingTransformer, sys, "t2w1") !== nothing
    @test PSY.get_from_bus(t) === b1
    @test PSY.get_to_bus(t) === b2
    remove_component!(sys, t)
    @test get_component(TwoWindingTransformer, sys, "t2w1") === nothing
end

@testset "transformer serialization round-trip" begin
    sys = System(100.0)
    b1 = ACBus(nothing)
    set_name!(b1, "b1")
    set_number!(b1, 1)
    b2 = ACBus(nothing)
    set_name!(b2, "b2")
    set_number!(b2, 2)
    b3 = ACBus(nothing)
    set_name!(b3, "b3")
    set_number!(b3, 3)
    star = ACBus(nothing)
    set_name!(star, "star")
    set_number!(star, 901)
    for b in (b1, b2, b3, star)
        set_base_voltage!(b, 100.0)
        set_bustype!(b, ACBusTypes.PQ)
        add_component!(sys, b)
    end
    set_bustype!(b1, ACBusTypes.REF)
    arc12 = Arc(b1, b2)
    add_component!(sys, arc12)
    t2w = TwoWindingTransformer(nothing)
    set_name!(t2w, "t2w")
    c = get_circuit(t2w)
    set_arc!(c, arc12)
    set_tap!(c, 1.05)
    set_control_objective!(c, TransformerControlObjective.VOLTAGE)
    set_regulated_bus!(c, b2)
    set_control_limits!(c, (min = 0.9, max = 1.1))
    set_controlled_quantity_limits!(c, (min = 0.95, max = 1.05))
    set_number_of_tap_positions!(c, 33)
    set_available!(c, true)
    set_rating!(c, 1.0 * CU)   # check_rating_values requires a non-nothing `rating`
    # magnetizing_shunt and shunt_location are now transformer-level fields
    set_magnetizing_shunt!(t2w, (0.02 + 0.0im) * CU)
    set_shunt_location!(t2w, TwoWindingTransformerShuntLocation.SPLIT)
    add_component!(sys, t2w)

    a1 = Arc(b1, star)
    a2 = Arc(b2, star)
    a3 = Arc(b3, star)
    foreach(a -> add_component!(sys, a), (a1, a2, a3))
    t3w = ThreeWindingTransformer(nothing)
    set_name!(t3w, "t3w")
    set_arc!(get_primary_circuit(t3w), a1)
    set_arc!(get_secondary_circuit(t3w), a2)
    set_arc!(get_tertiary_circuit(t3w), a3)
    foreach(c -> set_available!(c, true), get_circuits(t3w))
    set_star_bus!(t3w, star)
    set_r_12!(t3w, 0.01 * CU)
    set_r_31!(t3w, 0.02 * CU)
    set_x_12!(t3w, 0.1 * CU)
    set_r_23!(t3w, 0.015 * CU)
    set_x_23!(t3w, 0.15 * CU)
    set_x_31!(t3w, 0.2 * CU)
    set_base_power_12!(t3w, 100.0)
    set_base_power_23!(t3w, 100.0)
    set_base_power_31!(t3w, 100.0)
    set_magnetizing_shunt!(t3w, (0.03 + 0.0im) * CU)
    set_shunt_location!(t3w, ThreeWindingTransformerShuntLocation.STAR)
    add_component!(sys, t3w)

    # Round-trip through a document (`ThreeWindingTransformer` is now in `DOCUMENT_PLAN`,
    # sharing the `TransformerCircuit` bucket with `TwoWindingTransformer`). UUIDs are not
    # preserved across the rebuild, so every check below compares objects resolved from
    # `sys2` against other objects resolved from `sys2` — never against the pre-round-trip
    # `sys`.
    sys2 = roundtrip_system(sys)
    t2w2 = get_component(TwoWindingTransformer, sys2, "t2w")
    c2 = get_circuit(t2w2)
    @test get_tap(c2) == 1.05
    # the full flat control block round-trips: scoped enum, both MinMax fields, and Ints
    @test get_control_objective(c2) == TransformerControlObjective.VOLTAGE
    @test get_control_limits(c2) == (min = 0.9, max = 1.1)
    @test get_controlled_quantity_limits(c2) == (min = 0.95, max = 1.05)
    @test get_number(get_regulated_bus(c2)) == 2
    @test get_regulated_bus_side(c2) == TransformerRegulatedBusSide.OPPOSITE_WINDING
    @test get_number_of_tap_positions(c2) == 33
    # parent-level shunt fields round-trip
    @test get_shunt_location(t2w2) == TwoWindingTransformerShuntLocation.SPLIT
    @test get_magnetizing_shunt(t2w2, CU) ≈ 0.02
    # arc resolved to the live Arc component in sys2 (id ref, not an inline copy)
    @test IS.get_id(get_arc(c2)) == IS.get_id(
        first(
            a for a in get_components(Arc, sys2) if
            get_number(get_from(a)) == 1 && get_number(get_to(a)) == 2
        ),
    )
    @test IS.get_base_value(c2) == 100.0   # repopulated on add during load
    t3w2 = get_component(ThreeWindingTransformer, sys2, "t3w")
    @test get_r_12(t3w2, CU) ≈ 0.01
    @test get_r_31(t3w2, CU) ≈ 0.02
    @test get_shunt_location(t3w2) == ThreeWindingTransformerShuntLocation.STAR
    @test get_magnetizing_shunt(t3w2, CU) ≈ 0.03
    # 3W refs also resolve to live components in sys2 (id refs, not inline copies)
    @test IS.get_id(get_star_bus(t3w2)) ==
          IS.get_id(get_component(ACBus, sys2, "star"))
    @test IS.get_id(get_arc(get_primary_circuit(t3w2))) == IS.get_id(
        first(
            a for a in get_components(Arc, sys2) if
            get_number(get_from(a)) == 1 && get_number(get_to(a)) == 901
        ),
    )
    @test IS.get_id(get_arc(get_secondary_circuit(t3w2))) == IS.get_id(
        first(
            a for a in get_components(Arc, sys2) if
            get_number(get_from(a)) == 2 && get_number(get_to(a)) == 901
        ),
    )
    @test IS.get_id(get_arc(get_tertiary_circuit(t3w2))) == IS.get_id(
        first(
            a for a in get_components(Arc, sys2) if
            get_number(get_from(a)) == 3 && get_number(get_to(a)) == 901
        ),
    )
    @test IS.get_base_value(get_primary_circuit(t3w2)) == 100.0   # repopulated on add during load
end
