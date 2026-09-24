# Tests of the power-domain unit machinery: categories, convert_units across
# per-unit/natural-unit boundaries, serialization, and custom Unitful units.
# The generic `u"CU"`/`u"SU"`/`u"NU"` and `resolve_per_unit` are tested in IS
# (test/test_relative_units.jl) since they are domain-agnostic.

import Unitful
using Unitful: @u_str

# Mock components so we can exercise convert_units without building a full System.
struct MockGen
    active_power::Float64
    base_power::Float64
end

struct MockLine
    r::Float64
    x::Float64
end

PSY._get_component_base_power(g::MockGen) = g.base_power
PSY._get_system_base_power(::MockGen) = 100.0
PSY.get_base_voltage(::MockGen) = 230.0

PSY._get_component_base_power(::MockLine) = 100.0
PSY._get_system_base_power(::MockLine) = 100.0
PSY.get_base_voltage(::MockLine) = 230.0

@testset "Unit categories" begin
    @test natural_unit(ACTIVE_POWER) == u"MW"
    @test natural_unit(REACTIVE_POWER) == u"MVAr"
    @test natural_unit(APPARENT_POWER) == u"MVA"
    @test natural_unit(IMPEDANCE) == u"Ω"
    @test natural_unit(ADMITTANCE) == u"S"
    @test natural_unit(VOLTAGE) == u"kV"
    @test natural_unit(CURRENT) == u"kA"
end

@testset "Unit categories compose from their base exponents" begin
    gen = MockGen(0.6, 50.0)

    # A category is a natural unit plus the exponents of the power and voltage bases,
    # so the derived quantities are *computed* rather than declared: every hardcoded
    # category below must equal the composition it is physically defined as.
    for (derived, hardcoded) in (
        (VOLTAGE^Val(2) / ACTIVE_POWER, IMPEDANCE),
        (ACTIVE_POWER / VOLTAGE^Val(2), ADMITTANCE),
        (ACTIVE_POWER / VOLTAGE, CURRENT),
    )
        @test base_value(gen, derived) ≈ base_value(gen, hardcoded)
        @test system_base_value(gen, derived) ≈ system_base_value(gen, hardcoded)
        @test PSY._cu_to_su_ratio(gen, derived) ≈ PSY._cu_to_su_ratio(gen, hardcoded)
        # The derived natural unit is spelled differently (kV² MW⁻¹ vs Ω) but must be
        # the same physical unit, which is what makes `uconvert` on it correct.
        @test Unitful.uconvert(
            natural_unit(hardcoded),
            1.0 * natural_unit(derived),
        ) ≈ 1.0 * natural_unit(hardcoded)
    end

    # Multiplication is the inverse of division: current × voltage is power.
    @test base_value(gen, CURRENT * VOLTAGE) ≈ base_value(gen, ACTIVE_POWER)
end

@testset "Unit categories: zero exponents never touch an unused base" begin
    # `_checked_base_voltage` errors when the base voltage is unset, so a category with
    # a voltage exponent of zero must not reach it. A getter that never needs the base
    # voltage has to work on a component that has none.
    struct NoVoltage end
    PSY._get_component_base_power(::NoVoltage) = 50.0
    PSY._get_system_base_power(::NoVoltage) = 100.0
    PSY.get_base_voltage(::NoVoltage) = nothing

    nv = NoVoltage()
    @test base_value(nv, ACTIVE_POWER) == 50.0
    @test system_base_value(nv, ACTIVE_POWER) == 100.0
    @test PSY._cu_to_su_ratio(nv, VOLTAGE) == 1.0   # P == 0: no base power read either
    @test_throws ErrorException base_value(nv, IMPEDANCE)
end

@testset "per_unit_table: per-unit units, natural base and residual per category" begin
    for (cat, cu, su, natural, residual) in (
        (ACTIVE_POWER, PSY.CUp, PSY.SUp, u"MW", Unitful.NoUnits),
        (REACTIVE_POWER, PSY.CUp, PSY.SUp, u"MVAr", Unitful.NoUnits),
        (VOLTAGE, PSY.CUv, PSY.CUv, u"kV", Unitful.NoUnits),
        (IMPEDANCE, PSY.CUz, PSY.SUz, u"Ω", Unitful.NoUnits),
        (ADMITTANCE, PSY.CUy, PSY.SUy, u"S", Unitful.NoUnits),
        (CURRENT, PSY.CUi, PSY.SUi, u"kA", Unitful.NoUnits),
        (PSY.ACTIVE_POWER_CHANGE_RATE, PSY.CUp, PSY.SUp, u"MW", u"minute^-1"),
    )
        @test PSY.per_unit_table(cat) == (cu, su, natural, residual)
    end
    # A composed category finds its alias too: voltage² / power is impedance.
    @test PSY.per_unit_table(VOLTAGE^Val(2) / ACTIVE_POWER)[1] == PSY.CUz
end

@testset "Per-unit values of different kinds do not add" begin
    gen = MockGen(0.6, 50.0)
    p = convert_units(gen, 0.5u"CU", ACTIVE_POWER, u"SU")
    x = convert_units(gen, 0.01u"CU", IMPEDANCE, u"SU")
    @test Unitful.unit(p) == PSY.SUp
    @test Unitful.unit(x) == PSY.SUz
    @test_throws Unitful.DimensionError x + p
    # Nor do the same kind on different bases.
    @test_throws Unitful.DimensionError p +
                                        convert_units(gen, 0.5u"CU", ACTIVE_POWER, u"CU")
    # Per-unit physics still composes: I² · Z is a per-unit power.
    i = convert_units(gen, 1.2u"CU", CURRENT, u"SU")
    @test Unitful.dimension(i^2 * x) == Unitful.dimension(p)
end

@testset "Rate categories: a per-unit target must name a time" begin
    gen = MockGen(0.6, 50.0)   # 50 MVA component, 100 MVA system
    cat = PSY.ACTIVE_POWER_CHANGE_RATE
    v = 0.1u"CU/minute"         # stored: 0.1 CU per minute

    @test natural_unit(cat) == u"MW" / u"minute"
    # The power axis per-unitizes exactly as a plain power does; time has no base.
    @test base_value(gen, cat) == base_value(gen, ACTIVE_POWER)
    @test system_base_value(gen, cat) == system_base_value(gen, ACTIVE_POWER)

    # Natural units: Unitful does the power and time conversion together.
    @test convert_units(gen, v, cat, u"MW/minute") ≈ 5.0u"MW/minute"
    @test convert_units(gen, v, cat, u"MW/hr") ≈ 300.0u"MW/hr"
    @test convert_units(gen, v, cat, u"NU/minute") ≈ 5.0u"MW/minute"

    # Per-unit bases per unit time: both axes move independently.
    @test convert_units(gen, v, cat, u"CU/minute") ≈ 0.1 * PSY.CUp / u"minute"
    @test convert_units(gen, v, cat, u"CU/hr") ≈ 6.0 * PSY.CUp / u"hr"
    @test convert_units(gen, v, cat, u"SU/minute") ≈ 0.05 * PSY.SUp / u"minute"
    @test convert_units(gen, v, cat, u"SU/hr") ≈ 3.0 * PSY.SUp / u"hr"

    # Every spelling of the same rate stores the same number.
    for q in (5.0u"MW/minute", 300.0u"MW/hr", 0.1u"CU/minute", 6.0u"CU/hr",
        0.05u"SU/minute", 6.0 * PSY.CUp / u"hr")
        @test PSY._to_stored(gen, q, cat) ≈ 0.1
    end

    # A bare per-unit base names no time, so it is not a complete target…
    @test_throws ArgumentError convert_units(gen, v, cat, u"CU")
    @test_throws ArgumentError convert_units(gen, v, cat, u"SU")
    @test_throws ArgumentError PSY._to_stored(gen, 0.1u"CU", cat)
    # …and a time is meaningless on a quantity that is not a rate.
    @test_throws ArgumentError convert_units(gen, 0.6u"CU", ACTIVE_POWER, u"CU/hr")
    # A plain power unit has the wrong dimension.
    @test_throws Unitful.DimensionError convert_units(gen, v, cat, u"MW")
end

@testset "Unit categories print by name" begin
    @test sprint(show, ACTIVE_POWER) == "ACTIVE_POWER"
    @test sprint(show, IMPEDANCE) == "IMPEDANCE"
    # A composed category has no name; it reports its unit and exponents instead.
    @test occursin("UnitCategory", sprint(show, VOLTAGE^Val(2) / ACTIVE_POWER))
end

@testset "base_value and system_base_value" begin
    gen = MockGen(0.6, 50.0)  # 50 MVA device, 100 MVA system

    @test base_value(gen, ACTIVE_POWER) == 50.0
    @test system_base_value(gen, ACTIVE_POWER) == 100.0

    # Impedance: V² / S
    @test base_value(gen, IMPEDANCE) ≈ 230.0^2 / 50.0
    @test system_base_value(gen, IMPEDANCE) ≈ 230.0^2 / 100.0

    # Admittance: S / V²
    @test base_value(gen, ADMITTANCE) ≈ 50.0 / 230.0^2
    @test system_base_value(gen, ADMITTANCE) ≈ 100.0 / 230.0^2

    @test base_value(gen, VOLTAGE) == 230.0
    @test system_base_value(gen, VOLTAGE) == 230.0
end

@testset "convert_units: component base → other" begin
    gen = MockGen(0.6, 50.0)   # 50 MVA component, 100 MVA system

    @test convert_units(gen, 0.6u"CU", ACTIVE_POWER, u"MW") ≈ 30.0u"MW"
    @test convert_units(gen, 0.6u"CU", ACTIVE_POWER, u"SU") ≈ 0.3 * PSY.SUp
    @test convert_units(gen, 0.6u"CU", ACTIVE_POWER, u"CU") ≈ 0.6 * PSY.CUp
    @test convert_units(gen, 0.6u"CU", ACTIVE_POWER, u"NU") ≈ 30.0u"MW"
end

@testset "convert_units: system base → other" begin
    gen = MockGen(0.6, 50.0)

    @test convert_units(gen, 0.3u"SU", ACTIVE_POWER, u"MW") ≈ 30.0u"MW"
    @test convert_units(gen, 0.3u"SU", ACTIVE_POWER, u"CU") ≈ 0.6 * PSY.CUp
    @test convert_units(gen, 0.3u"SU", ACTIVE_POWER, u"SU") ≈ 0.3 * PSY.SUp
end

@testset "convert_units: natural → per-unit" begin
    gen = MockGen(0.6, 50.0)

    @test convert_units(gen, 30.0u"MW", ACTIVE_POWER, u"CU") ≈ 0.6 * PSY.CUp
    @test convert_units(gen, 30.0u"MW", ACTIVE_POWER, u"SU") ≈ 0.3 * PSY.SUp
    @test convert_units(gen, 30000.0u"kW", ACTIVE_POWER, u"CU") ≈ 0.6 * PSY.CUp
end

@testset "convert_units: resolved per-unit units in and out" begin
    gen = MockGen(0.6, 50.0)
    # A value carrying the resolved units (what a getter returns) converts like the
    # generic spelling.
    @test convert_units(gen, 0.6 * PSY.CUp, ACTIVE_POWER, u"MW") ≈ 30.0u"MW"
    @test convert_units(gen, 0.6 * PSY.CUp, ACTIVE_POWER, PSY.SUp) ≈ 0.3 * PSY.SUp
end

@testset "convert_units: impedance" begin
    line = MockLine(0.01, 0.1)
    z_base = 230.0^2 / 100.0

    @test convert_units(line, 0.01u"CU", IMPEDANCE, u"Ω") ≈ (0.01 * z_base) * u"Ω"
    # component base == system base, so the CU → SU ratio is 1.0
    @test convert_units(line, 0.01u"CU", IMPEDANCE, u"SU") ≈ 0.01 * PSY.SUz
    @test Unitful.unit(convert_units(line, 0.01u"CU", IMPEDANCE, u"NU")) == u"Ω"
end

@testset "convert_units: nothing passthrough" begin
    gen = MockGen(0.6, 50.0)
    @test convert_units(gen, nothing, ACTIVE_POWER, u"MW") === nothing
end

@testset "convert_units: round-trip consistency" begin
    gen = MockGen(0.6, 50.0)
    for to in (u"MW", u"SU", u"NU")
        there = convert_units(gen, 0.6u"CU", ACTIVE_POWER, to)
        @test convert_units(gen, there, ACTIVE_POWER, u"CU") ≈ 0.6 * PSY.CUp
    end
end

@testset "convert_units: complex support" begin
    line = MockLine(0.01, 0.1)

    # ratio is 1.0 since component base == system base
    for z in (0.01 + 0.1im, ComplexF32(0.01, 0.1), Complex(1, 2))
        @test Unitful.ustrip(convert_units(line, z * u"CU", IMPEDANCE, u"SU")) ≈ z
    end
end

@testset "Serialization: per-unit quantities" begin
    for (q, unit) in (
        (0.6 * PSY.CUp, "CUp"),
        (0.3 * PSY.SUp, "SUp"),
        (0.01 * PSY.CUz, "CUz"),
    )
        d = PSY.serialize_quantity(q)
        @test d["value"] == Unitful.ustrip(q)
        @test d["unit"] == unit
        @test PSY.deserialize_quantity(d) == q
    end

    q = (0.01 + 0.1im) * PSY.SUz
    d = PSY.serialize_quantity(q)
    @test d["value"]["re"] == 0.01
    @test d["value"]["im"] == 0.1
    @test d["unit"] == "SUz"
    @test PSY.deserialize_quantity(d) == q
end

@testset "Serialization: Unitful Quantity" begin
    q = 30.0u"MW"
    d = PSY.serialize_quantity(q)
    @test d["value"] == 30.0
    @test d["unit"] == "MW"
    @test PSY.deserialize_quantity(d) ≈ q

    q = 529.0u"Ω"
    d = PSY.serialize_quantity(q)
    @test d["value"] == 529.0
    @test d["unit"] == "Ω"
    @test PSY.deserialize_quantity(d) ≈ q
end

@testset "Serialization: compound units do not follow the platform" begin
    # Unitful renders exponents with Unicode superscripts or ASCII carets depending on
    # `ENV["UNITFUL_FANCY_EXPONENTS"]`, whose default is true on macOS and false
    # elsewhere. A system serialized on one platform has to read back on another, so
    # `unit_to_string` must not inherit that -- and both spellings must parse.
    rate = u"MW" / u"minute"
    restore = get(ENV, "UNITFUL_FANCY_EXPONENTS", nothing)
    try
        for fancy in ("true", "false")
            ENV["UNITFUL_FANCY_EXPONENTS"] = fancy
            @test PSY.unit_to_string(rate) == "MW minute^-1"
            @test PSY.serialize_quantity(6.0 * rate)["unit"] == "MW minute^-1"
        end
    finally
        if isnothing(restore)
            delete!(ENV, "UNITFUL_FANCY_EXPONENTS")
        else
            (ENV["UNITFUL_FANCY_EXPONENTS"] = restore)
        end
    end

    # Both spellings deserialize, so a file written by an older macOS build still reads.
    for spelling in ("MW minute^-1", "MW minute\u207b\u00b9", "MW/minute", "MW/min")
        @test PSY.string_to_unit(spelling) == rate
    end

    # A per-unit rate pins its spelling the same way.
    d = PSY.serialize_quantity(6.0 * PSY.CUp / u"hr")
    @test d == Dict("value" => 6.0, "unit" => "CUp hr^-1")
    @test PSY.deserialize_quantity(d) == 6.0 * PSY.CUp / u"hr"
end

@testset "Serialization: JSON string round-trip" begin
    q = 0.3 * PSY.SUp
    json = JSON.json(PSY.serialize_quantity(q))
    @test PSY.deserialize_quantity(json) == q

    q = 30.0u"MW"
    json = JSON.json(PSY.serialize_quantity(q))
    @test PSY.deserialize_quantity(json) ≈ q
end

@testset "_cu_to_su_ratio agrees with base_value ratio for every category" begin
    gen = MockGen(0.6, 50.0)  # 50 MVA component base, 100 MVA system base, 230 kV
    for cat in (
        ACTIVE_POWER,
        REACTIVE_POWER,
        APPARENT_POWER,
        IMPEDANCE,
        ADMITTANCE,
        VOLTAGE,
        CURRENT,
    )
        @test PSY._cu_to_su_ratio(gen, cat) ≈
              base_value(gen, cat) / system_base_value(gen, cat)
    end
end

@testset "Ω/S getters error when base voltage is missing" begin
    line = Line(nothing)  # demo line: buses carry base_voltage = nothing
    @test_throws ErrorException get_x(line, u"Ω")
    @test_throws ErrorException get_b(line, u"S")
end

@testset "Custom Unitful units" begin
    @test 1.0u"MVAr" == 1.0u"MW"  # same dimension
    @test 1.0u"MVA" == 1.0u"MW"
    @test sprint(show, 1.0u"MVAr") == "1.0 MVAr"
    @test sprint(show, 1.0u"MVA") == "1.0 MVA"
end

@testset "natural-unit getters distinguish active/reactive/apparent power" begin
    _, gen = _sys_with_thermal(; system_base = 100.0, component_base = 250.0)

    # All three share one per-unit base and differ only in the natural unit they
    # carry, so the numbers match while the units do not.
    @test Unitful.unit(get_active_power_unitful(gen, u"NU")) == u"MW"
    @test Unitful.unit(get_reactive_power_unitful(gen, u"NU")) == u"MVAr"
    @test Unitful.unit(get_rating_unitful(gen, u"NU")) == u"MVA"
    @test get_rating(gen, u"NU") ≈ get_rating(gen, u"CU") * 250.0

    limits = get_reactive_power_limits_unitful(gen, u"NU")
    @test Unitful.unit(limits.min) == u"MVAr"
    @test Unitful.unit(limits.max) == u"MVAr"

    # Setters accept any power-dimensioned unit; the category only picks how a
    # value reads back, not how it is stored.
    set_reactive_power!(gen, 25.0 * u"MVAr")
    @test get_reactive_power(gen, u"CU") ≈ 0.1
    @test get_reactive_power(gen, u"NU") ≈ 25.0
end

@testset "base_value lifecycle" begin
    # sys_a: 100 MVA base; gen stored at component base (250 MVA default from _sys_with_thermal)
    sys_a, gen = _sys_with_thermal()
    p_a = get_active_power(gen, u"SU")

    remove_component!(sys_a, gen)
    @test_throws ErrorException get_active_power(gen, u"SU")

    # Transfer to sys_b (50 MVA base). Same stored CU value ⇒ SU value doubles.
    sys_b = System(50.0)
    bus_b = ACBus(;
        number = 1, name = "b1", available = true,
        bustype = ACBusTypes.REF, angle = 0.0, magnitude = 1.0,
        voltage_limits = (min = 0.9, max = 1.1), base_voltage = 138.0,
    )
    add_component!(sys_b, bus_b)
    set_bus!(gen, bus_b)
    add_component!(sys_b, gen)
    @test get_active_power(gen, u"SU") ≈ 2.0 * p_a
end

@testset "deepcopy preserves each component's base value" begin
    sys, gen = _sys_with_thermal()

    sys2 = deepcopy(sys)
    gen2 = get_component(ThermalStandard, sys2, get_name(gen))
    @test IS.get_base_value(gen2) == sys2.base_power
    @test IS.get_base_value(gen2) == IS.get_base_value(gen)
end

@testset "deserialized components carry the system's base value" begin
    sys, gen = _sys_with_thermal()
    sys2 = roundtrip_system(sys)
    gen2 = get_component(ThermalStandard, sys2, get_name(gen))
    @test IS.get_base_value(gen2) == sys2.base_power
    @test get_active_power(gen2, u"SU") ≈ get_active_power(gen, u"SU")
end

@testset "HybridSystem attach/detach propagates base value to subcomponents" begin
    sys = System(100.0)
    bus = ACBus(;
        number = 1, name = "b1", available = true,
        bustype = ACBusTypes.REF, angle = 0.0, magnitude = 1.0,
        voltage_limits = (min = 0.9, max = 1.1), base_voltage = 138.0,
    )
    add_component!(sys, bus)
    h_sys = HybridSystem(;
        name = "h1", available = true, status = OperationalStates.ONLINE, bus = bus,
        active_power = 1.0, reactive_power = 1.0,
        thermal_unit = ThermalStandard(nothing),
        electric_load = PowerLoad(nothing),
        storage = EnergyReservoirStorage(nothing),
        renewable_unit = RenewableDispatch(nothing),
        base_power = 100.0,
        operation_cost = MarketBidCost(nothing),
        input_basis = u"CU",
    )
    subcomponents = collect(get_subcomponents(h_sys))
    @test length(subcomponents) == 4
    add_component!(sys, h_sys)
    @test all(c -> IS.get_base_value(c) !== nothing, subcomponents)

    remove_component!(sys, h_sys)
    @test all(c -> IS.get_base_value(c) === nothing, subcomponents)
end

@testset "convert_units rejects per-unit targets with the wrong residual" begin
    sys, gen = _sys_with_thermal()
    @test_throws ArgumentError convert_units(gen, 0.5u"CU", ACTIVE_POWER, u"CU/hr")
    @test_throws ArgumentError convert_units(gen, 0.5u"CU/hr", ACTIVE_POWER, u"MW")
    # Two generic units say nothing about which base the field is on.
    @test_throws ArgumentError convert_units(gen, 0.5u"CU", ACTIVE_POWER, u"CU*SU")
end

# Build a minimal System + Line (100 MVA base, 138 kV buses) for impedance/
# admittance inference tests. rating_b is set to a non-nothing value so
# get_rating_b returns Float64 (the small-union contract under test).
function _sys_with_line()
    sys = System(100.0)
    bus_from = ACBus(;
        number = 1, name = "f1", available = true,
        bustype = ACBusTypes.REF, angle = 0.0, magnitude = 1.0,
        voltage_limits = (min = 0.9, max = 1.1), base_voltage = 138.0,
    )
    bus_to = ACBus(;
        number = 2, name = "t1", available = true,
        bustype = ACBusTypes.PQ, angle = 0.0, magnitude = 1.0,
        voltage_limits = (min = 0.9, max = 1.1), base_voltage = 138.0,
    )
    add_component!(sys, bus_from)
    add_component!(sys, bus_to)
    line = Line(;
        name = "l1", available = true,
        active_power_flow = 0.0, reactive_power_flow = 0.0,
        arc = Arc(; from = bus_from, to = bus_to),
        r = 0.01, x = 0.05,
        b = (from = 0.01, to = 0.01),
        rating = 1.0,
        angle_limits = (min = -0.7, max = 0.7),
        rating_b = 0.9,
        input_basis = u"CU",
    )
    add_component!(sys, line)
    return sys, line
end

# Local copy of the ThreeWindingTransformer fixture from test_base_power.jl
# (`_make_test_3w_xfmr` / `_test_t3w`), reproduced here so test_units.jl remains
# self-contained when run in isolation (test_base_power.jl is included first
# alphabetically in the full suite, but the name-filter run — `julia
# --project=test test/runtests.jl test_units` — only includes test_units.jl
# itself).
function _local_make_test_3w_xfmr(; system_base = 100.0)
    xfmr = ThreeWindingTransformer(nothing)
    PowerSystems.set_units_setting!(xfmr, system_base)
    set_base_power_12!(xfmr, 15.0)
    set_base_power_23!(xfmr, 20.0)
    set_base_power_31!(xfmr, 25.0)
    set_base_power!(get_primary_circuit(xfmr), 15.0)
    set_base_power!(get_secondary_circuit(xfmr), 20.0)
    set_base_power!(get_tertiary_circuit(xfmr), 25.0)
    set_base_voltage_primary!(get_primary_circuit(xfmr), 230.0)
    set_base_voltage_primary!(get_secondary_circuit(xfmr), 138.0)
    set_base_voltage_primary!(get_tertiary_circuit(xfmr), 69.0)
    set_r_12!(xfmr, 0.01 * u"CU")
    set_r_23!(xfmr, 0.02 * u"CU")
    return xfmr
end

@testset "getter chain is inferable per unit-system marker" begin
    sys, gen = _sys_with_thermal()
    sys_l, line = _sys_with_line()
    xfmr3w = _local_make_test_3w_xfmr()

    # power category (Val{:mva})
    @inferred get_active_power(gen, u"SU")
    @inferred get_active_power(gen, u"CU")
    @inferred get_active_power(gen, u"NU")
    @inferred get_active_power_unitful(gen, u"SU")
    @test Unitful.unit(get_active_power_unitful(gen, u"SU")) == PSY.SUp

    # impedance / admittance categories (Val{:ohm} / Val{:siemens})
    @inferred get_r(line, u"SU")
    @inferred get_x(line, u"CU")
    @inferred get_b(line, u"SU")

    # compound NamedTuple fields
    @inferred get_active_power_limits(gen, u"SU")

    # Union{Nothing, Float64} descriptor field: small-union return is the contract
    # rating_b is set to 0.9 in _sys_with_line so the non-nothing branch executes
    @inferred Union{Nothing, Float64} get_rating_b(line, u"SU")

    # three-winding pairwise bases (PairBase engine); r_12/r_23 are now
    # Union{Nothing, Float64} descriptor fields (optional pairwise block)
    @inferred Union{Nothing, Float64} get_r_12(xfmr3w, u"SU")
    @inferred Union{Nothing, Float64} get_r_23(xfmr3w, u"CU")

    # setter chain: returns the stored CU Float64
    @inferred set_active_power!(gen, 0.4 * u"SU")
end

# NOTE: three testsets were dropped here as part of this merge, because each exercised a
# mechanism the other branch removed. Neither is a regression in coverage of live code:
#
#  - "conversions ignore the display unit_system" and "_set_units_base! errors on detached
#    component" (from feat/rust-time-series-store) drove `set_units_base_system!` /
#    `with_units_base`, i.e. the stateful units system that psy6 retired in "remove last
#    pieces of stateful units system". Unit selection is now an explicit per-call argument
#    (`get_active_power(gen, u"SU")`), which the testsets above already cover.
#
#  - "time series multiplier units default to SU" (from psy6) drove a per-series multiplier
#    and the `units` kwarg on `get_time_series_values`, both of which this branch removed.
#    Time series now store actual per-device quantities, so there is no multiplier to
#    resolve.

@testset "TransformerCircuit base_value anchor lifecycle" begin
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

    # detached: no anchor, SU conversion refuses
    for w in get_circuits(t3w)
        @test IS.get_base_value(w) === nothing
    end
    @test_throws ErrorException get_r(get_primary_circuit(t3w), u"SU")

    add_component!(sys, t3w)
    for w in get_circuits(t3w)
        @test IS.get_base_value(w) == 100.0
    end

    # set_circuit! propagates the anchor onto a replacement circuit
    new_circuit = TransformerCircuit(nothing)
    set_arc!(new_circuit, a1)
    set_available!(new_circuit, true)
    @test IS.get_base_value(new_circuit) === nothing
    set_primary_circuit!(t3w, new_circuit)
    @test IS.get_base_value(new_circuit) == 100.0

    # anchor is never serialized; it is repopulated on attach during load
    sys2 = roundtrip_system(sys)
    t2 = only(get_components(ThreeWindingTransformer, sys2))
    for w in get_circuits(t2)
        @test IS.get_base_value(w) == 100.0
    end

    # detach clears the anchor on every circuit
    remove_component!(sys, t3w)
    for w in get_circuits(t3w)
        @test IS.get_base_value(w) === nothing
    end
end

@testset "TransformerCircuit base_value anchor lifecycle" begin
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

    # detached: no anchor, SU conversion refuses
    for w in get_circuits(t3w)
        @test IS.get_base_value(w) === nothing
    end
    @test_throws ErrorException get_r(get_primary_circuit(t3w), u"SU")

    add_component!(sys, t3w)
    for w in get_circuits(t3w)
        @test IS.get_base_value(w) == 100.0
    end

    # set_circuit! propagates the anchor onto a replacement circuit
    new_circuit = TransformerCircuit(nothing)
    set_arc!(new_circuit, a1)
    set_available!(new_circuit, true)
    @test IS.get_base_value(new_circuit) === nothing
    set_primary_circuit!(t3w, new_circuit)
    @test IS.get_base_value(new_circuit) == 100.0

    # The anchor is never serialized; `add_component!` repopulates it, which is what this
    # checks.
    t2 = only(get_components(ThreeWindingTransformer, sys))
    for w in get_circuits(t2)
        @test IS.get_base_value(w) == 100.0
    end

    # detach clears the anchor on every circuit
    remove_component!(sys, t3w)
    for w in get_circuits(t3w)
        @test IS.get_base_value(w) === nothing
    end
end

@testset "kwarg constructors read bare numbers in input_basis" begin
    bus = ACBus(nothing)
    thermal(basis; kwargs...) = ThermalStandard(;
        name = "g", available = true, status = PSY.OperationalStates.OFFLINE, bus = bus,
        active_power = 50.0, reactive_power = 0.0, rating = 100.0,
        active_power_limits = (min = 0.0, max = 100.0), reactive_power_limits = nothing,
        ramp_limits = (up = 10.0, down = 10.0),
        operation_cost = ThermalGenerationCost(nothing), base_power = 200.0,
        input_basis = basis, kwargs...,
    )

    gen = thermal(u"NU")
    @test get_active_power(gen, u"CU") == 0.25
    @test get_active_power_limits(gen, u"CU") == (min = 0.0, max = 0.5)
    @test get_ramp_limits(gen, u"CU/minute") == (up = 0.05, down = 0.05)

    gen = thermal(u"CU")
    @test get_active_power(gen, u"CU") == 50.0
    @test get_ramp_limits(gen, u"CU/minute") == (up = 10.0, down = 10.0)

    # A tagged value keeps its own units, whatever input_basis says.
    gen = thermal(u"CU"; active_power = 50.0u"MW",
        ramp_limits = (up = 0.6 * u"CU/hr", down = 600.0u"MW/hr"))
    @test get_active_power(gen, u"CU") == 0.25
    @test get_ramp_limits(gen, u"CU/minute").up ≈ 0.01
    @test get_ramp_limits(gen, u"CU/minute").down ≈ 0.05

    @test_throws ArgumentError thermal(u"SU")
    @test_throws ErrorException thermal(u"CU"; active_power = 0.5 * u"SU")  # no system base yet
    @inferred thermal(u"NU")

    # Ω converts via the arc's base voltage.
    b1 = ACBus(nothing)
    set_base_voltage!(b1, 230.0)
    line = Line(;
        name = "l", available = true, active_power_flow = 0.0,
        reactive_power_flow = 0.0,
        arc = Arc(b1, b1), r = 5.29u"Ω", x = 0.1, b = (from = 0.0, to = 0.0),
        rating = 1.0, angle_limits = (min = -1.0, max = 1.0), input_basis = u"CU",
    )
    @test get_r(line, u"CU") ≈ 0.01
    @test get_x(line, u"CU") == 0.1
end
