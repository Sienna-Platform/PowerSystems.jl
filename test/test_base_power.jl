@testset "Test zero base power correction" begin
    # The zero-base-power correction (and its warning) now happens inside the
    # parser packages; the invariant PSY cares about is that no component
    # arrives with a zero device base.
    sys = build_system(PSISystems, "RTS_GMLC_DA_sys"; force_build = true)
    for comp in get_components(PSY.SynchronousCondenser, sys)
        @test abs(get_base_power(comp, NU)) > eps()
    end
end

function thermal_with_base_power(bus::PSY.Bus, name::String, base_power::Float64)
    return ThermalStandard(;
        name = name,
        available = true,
        status = OperationalStates.ONLINE,
        bus = bus,
        active_power = 1.0,
        reactive_power = 0.0,
        rating = 2.0,
        active_power_limits = (min = 0, max = 2),
        reactive_power_limits = (min = -2, max = 2),
        ramp_limits = nothing,
        operation_cost = ThermalGenerationCost(nothing),
        base_power = base_power,
        time_limits = nothing,
        prime_mover_type = PrimeMovers.OT,
        fuel = ThermalFuels.OTHER,
        services = Device[],
        dynamic_injector = nothing,
        ext = Dict{String, Any}(),
    )
end

@testset "Test unit-aware get_base_power" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)
    device_base = PSY._get_base_power(gen)
    system_base = PSY._get_base_power(sys)
    @test device_base != system_base

    # base_power is always natural units: the 1-arg form returns the stored MVA.
    @test get_base_power(gen) isa Float64
    @test get_base_power(gen) ≈ device_base

    # Bare-number getter returns Float64 in the requested unit; companion
    # `_unitful` keeps the Unitful wrapper.
    @test get_base_power(gen, NU) isa Float64
    @test get_base_power(gen, NU) ≈ device_base
    bp_nu = get_base_power_unitful(gen, NU)
    @test bp_nu isa Unitful.Quantity
    @test Unitful.ustrip(bp_nu) ≈ device_base
    # Not double-wrapped: no `device_base * MVA * MVA`.
    @test Unitful.unit(bp_nu) == Unitful.unit(1.0 * MVA)
    # 1-arg unitful form mirrors `(c, NU)`.
    @test get_base_power_unitful(gen) ≈ bp_nu

    @test get_base_power(gen, MW) isa Float64
    @test get_base_power(gen, MW) ≈ device_base
    bp_mw = get_base_power_unitful(gen, MW)
    @test bp_mw isa Unitful.Quantity
    @test Unitful.ustrip(MW, bp_mw) ≈ device_base

    @test get_base_power(gen, MVA) ≈ device_base

    # Per-unit bases are circular for base_power and are rejected.
    @test_throws ArgumentError get_base_power(gen, SU)
    @test_throws ArgumentError get_base_power_unitful(gen, SU)
    @test_throws ArgumentError get_base_power(gen, DU)
    @test_throws ArgumentError get_base_power_unitful(gen, DU)
    # Non-power units fail dimensionally.
    @test_throws Unitful.DimensionError get_base_power(gen, kV)

    # Components with no base_power field fall back to the system base.
    bus = first(get_components(ACBus, sys))
    @test get_base_power(bus) ≈ system_base
    @test get_base_power(bus, NU) ≈ system_base
    @test get_base_power_unitful(bus, NU) isa Unitful.Quantity
    @test_throws ArgumentError get_base_power(bus, SU)

    # System-level getter mirrors the component version.
    @test get_base_power(sys) ≈ system_base
    @test get_base_power(sys, NU) ≈ system_base
    @test get_base_power_unitful(sys, NU) isa Unitful.Quantity
    @test_throws ArgumentError get_base_power(sys, SU)
    @test_throws ArgumentError get_base_power_unitful(sys, SU)
end

@testset "Generated getters: bare vs _unitful, NU path" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)
    device_base = PSY._get_base_power(gen)
    system_base = PSY._get_base_power(sys)
    p_du = PSY.get_value(gen, Val(:active_power), Val(:mva), DU) |> ustrip

    # Plain Float64 across all unit args.
    @test get_active_power(gen, NU) isa Float64
    @test get_active_power(gen, NU) ≈ p_du * device_base
    @test get_active_power(gen, MW) isa Float64
    @test get_active_power(gen, MW) ≈ p_du * device_base
    @test get_active_power(gen, SU) isa Float64
    @test get_active_power(gen, SU) ≈ p_du * device_base / system_base
    @test get_active_power(gen, DU) isa Float64
    @test get_active_power(gen, DU) ≈ p_du

    # `_unitful` companions retain wrappers.
    p_nu_u = get_active_power_unitful(gen, NU)
    @test p_nu_u isa Unitful.Quantity
    @test Unitful.unit(p_nu_u) == Unitful.unit(1.0 * MW)
    @test Unitful.ustrip(MW, p_nu_u) ≈ p_du * device_base

    @test get_active_power_unitful(gen, MW) isa Unitful.Quantity
    @test get_active_power_unitful(gen, SU) isa RelativeQuantity
    @test get_active_power_unitful(gen, DU) isa RelativeQuantity

    # Compound NamedTuple field (MinMax): bare strips per-element, unitful keeps.
    lim = get_active_power_limits(gen, NU)
    @test lim.min isa Float64 && lim.max isa Float64
    lim_u = get_active_power_limits_unitful(gen, NU)
    @test lim_u.min isa Unitful.Quantity && lim_u.max isa Unitful.Quantity

    # Nothing-valued field: both forms pass nothing through.
    set_ramp_limits!(gen, nothing)
    @test get_ramp_limits(gen, NU) === nothing
    @test get_ramp_limits_unitful(gen, NU) === nothing
end

@testset "Generated getters: omitting the units argument explains what to pass" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)

    for f in (get_active_power, get_active_power_unitful, get_rating, get_rating_unitful)
        @test_throws ArgumentError f(gen)
    end

    msg = try
        get_active_power(gen)
    catch e
        sprint(showerror, e)
    end
    # The message must name the getter, the field, the relative markers and the
    # field's natural unit; a bare MethodError names none of them.
    @test occursin("get_active_power", msg)
    @test occursin("active_power", msg)
    @test occursin("ThermalStandard", msg)
    for u in ("`DU`", "`SU`", "`NU`", "`MW`")
        @test occursin(u, msg)
    end
    @test occursin("get_active_power_unitful(component, units)", msg)

    # The `_unitful` companion points back at the bare getter, not at itself.
    msg_u = try
        get_active_power_unitful(gen)
    catch e
        sprint(showerror, e)
    end
    @test occursin("get_active_power(component, units)", msg_u)
    @test !occursin("_unitful_unitful", msg_u)

    # Impedance fields advertise their own natural unit.
    msg_x = try
        get_x(Line(nothing))
    catch e
        sprint(showerror, e)
    end
    @test occursin("`OHMS`", msg_x)
end

@testset "Generated setters: untagged values explain what to pass" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)

    # A bare float, a bare integer and an all-untagged compound are all rejected.
    @test_throws ArgumentError set_active_power!(gen, 0.5)
    @test_throws ArgumentError set_active_power!(gen, 1)
    @test_throws ArgumentError set_active_power_limits!(gen, (min = 0.0, max = 1.0))

    msg = try
        set_active_power!(gen, 0.5)
    catch e
        sprint(showerror, e)
    end
    @test occursin("set_active_power!", msg)
    @test occursin("active_power", msg)
    @test occursin("ThermalStandard", msg)
    for tag in ("`val * DU`", "`val * SU`", "`val * MW`")
        @test occursin(tag, msg)
    end
    # `NU` is a getter target only; there is no `val * NU`.
    @test !occursin("val * NU", msg)

    # A compound field spells out the per-element form.
    msg_c = try
        set_active_power_limits!(gen, (min = 0.0, max = 1.0))
    catch e
        sprint(showerror, e)
    end
    @test occursin("set_active_power_limits!", msg_c)
    @test occursin("min = 0.0 * DU", msg_c)

    # A partially tagged compound is caught one level down and still names the field.
    msg_p = try
        set_active_power_limits!(gen, (min = 0.0 * DU, max = 1.0))
    catch e
        sprint(showerror, e)
    end
    @test occursin("active_power_limits", msg_p)
    @test occursin("`val * DU`", msg_p)

    # Impedance setters advertise their own natural unit.
    msg_x = try
        set_x!(Line(nothing), 0.1)
    catch e
        sprint(showerror, e)
    end
    @test occursin("`val * OHMS`", msg_x)

    # The compound fallback exists only where a NamedTuple is a valid value: a
    # scalar field must not advertise one, or the error would tell the caller to
    # tag the elements of a value the field can never hold.
    minmax_t = NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    updown_t = NamedTuple{(:up, :down), Tuple{Float64, Float64}}
    # `hasmethod` would be true either way -- the generic `set_X!(value, val)`
    # takes anything -- so ask which method a NamedTuple actually selects.
    selected(f, t) = which(f, Tuple{ThermalStandard, t}).sig.parameters[3]
    @test selected(set_active_power!, minmax_t) === Any
    @test selected(set_rating!, minmax_t) === Any
    @test selected(set_active_power_limits!, minmax_t) <: NamedTuple
    @test selected(set_ramp_limits!, updown_t) <: NamedTuple
    # ...and it is keyed to that field's own element names.
    @test selected(set_active_power_limits!, updown_t) === Any

    # A `Complex` field is untagged in the same way a real one is.
    @test_throws ArgumentError set_magnetizing_shunt!(
        TwoWindingTransformer(nothing),
        0.1 + 0.2im,
    )

    # Tagged values still round-trip through every accepted form.
    set_active_power!(gen, 0.6 * DU)
    @test get_active_power(gen, DU) ≈ 0.6
    set_active_power!(gen, 0.3 * SU)
    @test get_active_power(gen, SU) ≈ 0.3
    set_active_power!(gen, 60.0 * MW)
    @test get_active_power(gen, MW) ≈ 60.0
    set_active_power_limits!(gen, (min = 0.0 * DU, max = 1.0 * DU))
    @test get_active_power_limits(gen, DU) == (min = 0.0, max = 1.0)
end

# The error messages name a natural unit per conversion category. That name is only
# useful if it is a symbol the caller actually has and the accessors actually take,
# so each case here reads the unit out of the message itself and round-trips it.
@testset "Suggested natural units are what the accessors accept" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)
    bus1 = get_component(ACBus, sys, "b1")
    bus2 = ACBus(;
        number = 2, name = "b2", available = true,
        bustype = ACBusTypes.PV, angle = 0.0, magnitude = 1.0,
        voltage_limits = (min = 0.9, max = 1.1), base_voltage = 138.0,
    )
    add_component!(sys, bus2)
    line = Line(;
        name = "l1", available = true, active_power_flow = 0.0,
        reactive_power_flow = 0.0, arc = Arc(; from = bus1, to = bus2),
        r = 0.01, x = 0.1, b = (from = 0.001, to = 0.001),
        rating = 2.0, angle_limits = (min = -1.0, max = 1.0),
    )
    add_component!(sys, line)

    # One field per conversion category: active, reactive and apparent power,
    # impedance, admittance. Voltage and current have no convertible fields --
    # `base_voltage` is stored natural and read with a plain one-argument getter --
    # so no message ever suggests a unit for them.
    cases = (
        (:mw, get_active_power, set_active_power!, gen),
        (:mvar, get_reactive_power, set_reactive_power!, gen),
        (:mva, get_rating, set_rating!, gen),
        (:ohm, get_x, set_x!, line),
        (:siemens, get_b, set_b!, line),
    )
    for (token, getter, setter, comp) in cases
        get_msg = try
            getter(comp)
        catch e
            sprint(showerror, e)
        end
        suggested = match(r"the natural unit `([^`]+)`", get_msg)
        @test suggested !== nothing
        name = Symbol(suggested.captures[1])

        # The suggestion must be a name the caller has from `using PowerSystems`.
        @test name in names(PowerSystems)
        units = getfield(PowerSystems, name)

        # The getter takes exactly what its message suggested...
        before = getter(comp, units)
        @test _unwrap_units(before) == before

        # ...and the setter takes `val * <that same unit>`, as its own message says.
        set_msg = try
            setter(comp, 1.0)
        catch e
            sprint(showerror, e)
        end
        @test occursin("`val * $name`", set_msg)
        setter(comp, before isa NamedTuple ? map(x -> x * units, before) : before * units)
        @test getter(comp, units) == before
    end

    # The suggested names are the `u"..."` literals, not separate constants, and a
    # unit named as a string is not accepted by either form.
    @test MW === Unitful.@u_str("MW")
    @test MVAr === Unitful.@u_str("MVAr")
    @test MVA === Unitful.@u_str("MVA")
    @test OHMS === Unitful.@u_str("Ω")
    @test SIEMENS === Unitful.@u_str("S")
    @test get_active_power(gen, Unitful.@u_str("MW")) == get_active_power(gen, MW)
    @test_throws MethodError get_active_power(gen, "MW")
end

# Regression guard for the explicit-units performance contract (PR #1695):
# the internal per-unit conversions must compile away so that a literal unit
# argument yields a type-stable, allocation-free `Float64`, and `ustrip` of the
# `_unitful` companion must be a no-op equal to the bare getter.
@testset "Generated getters: type-stable and allocation-free" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)

    # (1)+(4) Conversions compile away: each literal unit arg infers to Float64.
    for u in (SU, DU, NU, MW)
        @test (@inferred get_active_power(gen, u)) isa Float64
    end

    # (2) `ustrip` is a no-op equal to the bare getter for relative-unit wrappers.
    for u in (SU, DU, NU)
        wrapped = get_active_power_unitful(gen, u)
        @test (@inferred Unitful.ustrip(wrapped)) == get_active_power(gen, u)
    end

    # (3) A sum loop over the getter is allocation-free once compiled.
    gens = collect(get_components(ThermalStandard, sys))
    sum_strip(gs, u) = (s = 0.0; for g in gs
        s += Unitful.ustrip(get_active_power_unitful(g, u))
    end; s)
    for u in (SU, DU, NU)
        sum_strip(gens, u)  # warm up
        @test (@inferred sum_strip(gens, u)) isa Float64
        @test (@allocated sum_strip(gens, u)) == 0
    end
end

@testset "Unit-aware set_base_power!" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)
    system_base = PSY._get_base_power(sys)

    # Bare Float64 — interpreted and stored as MVA.
    set_base_power!(gen, 75.0)
    @test PSY._get_base_power(gen) ≈ 75.0
    @test get_base_power(gen) ≈ 75.0

    # Unitful.Quantity in MW (MVA and MW share dimensions; storage is MVA).
    set_base_power!(gen, 80.0 * MW)
    @test PSY._get_base_power(gen) ≈ 80.0

    # Unitful.Quantity in MVA.
    set_base_power!(gen, 90.0 * MVA)
    @test PSY._get_base_power(gen) ≈ 90.0

    # Per-unit bases are circular for base_power and are rejected.
    @test_throws ArgumentError set_base_power!(gen, 0.5 * SU)
    @test_throws ArgumentError set_base_power!(gen, 1.25 * SU)
    @test_throws ArgumentError set_base_power!(gen, 1.0 * DU)
    @test_throws ArgumentError set_base_power!(gen, 0.5 * DU)

    # Dimensionally wrong inputs fail at conversion time.
    @test_throws Unitful.DimensionError set_base_power!(gen, 1.0 * kV)
end

@testset "Plain get/set for ThreeWindingTransformer base_power_{12,23,31}" begin
    # base_power_12/23/31 are plain MVA `Float64` fields with no unit-conversion
    # path: a three-winding transformer has three independent per-pair bases, so
    # there is no single `base_power` to route through the MW/SU/DU-aware
    # component-level wrapper (contrast with `get_base_power`/`set_base_power!`
    # on ordinary components, and with the per-circuit `base_power` accessed via
    # `TransformerCircuit`, which is likewise plain).
    xfmr = ThreeWindingTransformer(nothing)
    for (setter, getter) in (
        (set_base_power_12!, get_base_power_12),
        (set_base_power_23!, get_base_power_23),
        (set_base_power_31!, get_base_power_31),
    )
        setter(xfmr, 75.0)
        @test getter(xfmr) ≈ 75.0
        setter(xfmr, 15.0)
        @test getter(xfmr) ≈ 15.0
    end
end

# Detached ThreeWindingTransformer with seeded units anchor (system base 100), distinct
# per-circuit/per-pair base powers (15/20/25 MVA), and base voltages (230/138/69 kV) —
# deliberately all different so a wrong-base selection is caught. Mirrors `_test_t3w`
# in test_transformer_circuits.jl.
function _make_test_3w_xfmr(; system_base = 100.0)
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
    return xfmr
end

@testset "3W magnetizing_shunt converts on the primary circuit base" begin
    xfmr = _make_test_3w_xfmr()                       # anchor 100; base_power_12 = 15
    set_base_power!(get_primary_circuit(xfmr), 50.0)  # decouple circuit base from pair base
    set_magnetizing_shunt!(xfmr, (1.0 + 0.0im) * DU)
    # SU must scale by the primary CIRCUIT base (50), not base_power_12 (15)
    @test real(get_magnetizing_shunt(xfmr, SU)) ≈ 1.0 * 50.0 / 100.0
end

@testset "Pairwise impedance getters on ThreeWindingTransformer use the pair base" begin
    # Regression guard for a silent units bug. The getters must honor the explicit
    # `units` argument and resolve the CORRECT pair base. Each pairwise impedance
    # has its own `base_power_XX` and is referenced to the FIRST-INDEX circuit's
    # base voltage (12 -> primary, 23 -> secondary, 31 -> tertiary).
    # Distinct per-pair bases catch a wrong-pair-base selection.
    system_base = 100.0
    xfmr = _make_test_3w_xfmr(; system_base = system_base)

    # (setter, getter, stored DU value, pair base power, reference base voltage)
    cases = (
        (set_r_12!, get_r_12, 0.01, 15.0, 230.0),
        (set_x_12!, get_x_12, 0.10, 15.0, 230.0),
        (set_r_23!, get_r_23, 0.02, 20.0, 138.0),
        (set_x_23!, get_x_23, 0.20, 20.0, 138.0),
        (set_r_31!, get_r_31, 0.03, 25.0, 69.0),
        (set_x_31!, get_x_31, 0.30, 25.0, 69.0),
    )
    for (setter, getter, dev_val, base_power, base_voltage) in cases
        setter(xfmr, dev_val * DU)  # seed device-base storage directly

        @test getter(xfmr, DU) ≈ dev_val
        # System base: Z_su = Z_du * (system_base / pair_base).
        @test getter(xfmr, SU) ≈ dev_val * (system_base / base_power)
        # The units argument must change the result (the bug made SU == DU).
        @test getter(xfmr, SU) != getter(xfmr, DU)
        # Natural units (Ω): Z_nu = Z_du * (V² / pair_base).
        @test getter(xfmr, NU) ≈ dev_val * (base_voltage^2 / base_power)
        # Cross-unit invariant: the physical Ω value is independent of which unit
        # system it is read through (this fails outright if `units` is ignored).
        @test getter(xfmr, NU) ≈ getter(xfmr, SU) * (base_voltage^2 / system_base)
    end
end

@testset "ThreeWindingTransformer Unitful-target getters use the correct bases" begin
    system_base = 100.0
    xfmr = _make_test_3w_xfmr(; system_base = system_base)
    primary = get_primary_circuit(xfmr)

    set_rating!(primary, 2.0 * DU)
    # MW must scale by the PRIMARY WINDING base (15), not the system base (100).
    @test get_rating(primary, MW) ≈ 2.0 * 15.0
    @test get_rating(primary, MW) ≈ get_rating(primary, NU)
    @test get_rating_unitful(primary, MW) isa Unitful.Quantity

    set_r_12!(xfmr, 0.01 * DU)
    # Ω target must agree with the NU path and use base_power_12 / primary voltage
    # (and must not crash looking for a single transformer-wide arc/base voltage).
    @test get_r_12(xfmr, OHMS) ≈ 0.01 * (230.0^2 / 15.0)
    @test get_r_12(xfmr, OHMS) ≈ get_r_12(xfmr, NU)

    # r_31/x_31 are referenced to the TERTIARY circuit voltage (69 kV), base_power_31 = 25.
    set_r_31!(xfmr, 0.02 * DU)
    @test get_r_31(xfmr, OHMS) ≈ 0.02 * (69.0^2 / 25.0)
    @test get_r_31(xfmr, OHMS) ≈ get_r_31(xfmr, NU)
end

@testset "ThreeWindingTransformer/TransformerCircuit setters round-trip against the correct base" begin
    system_base = 100.0
    xfmr = _make_test_3w_xfmr(; system_base = system_base)
    primary = get_primary_circuit(xfmr)
    secondary = get_secondary_circuit(xfmr)
    tertiary = get_tertiary_circuit(xfmr)

    # Power: MW input divides by the WINDING base, not the system base.
    set_rating!(primary, 30.0 * MW)
    @test get_rating(primary, DU) ≈ 2.0    # 30 MW / 15 MVA circuit base
    @test get_rating(primary, MW) ≈ 30.0
    # SU: 0.4 SU = 40 MW on the system base = 2.0 DU on the 20 MVA circuit.
    set_rating!(secondary, 0.4 * SU)
    @test get_rating(secondary, DU) ≈ 2.0
    @test get_rating(secondary, SU) ≈ 0.4
    # DU input is identity.
    set_rating!(tertiary, 1.5 * DU)
    @test get_rating(tertiary, DU) ≈ 1.5

    # Impedance: Ω divides by the pair impedance base V²/S (pair 12: primary base
    # voltage, base_power_12 = 15).
    z_base_12 = 230.0^2 / 15.0
    set_r_12!(xfmr, 0.01 * z_base_12 * OHMS)
    @test get_r_12(xfmr, DU) ≈ 0.01
    @test get_r_12(xfmr, OHMS) ≈ 0.01 * z_base_12
    # SU impedance on pair 23 (base_power_23 = 20): Z_du = Z_su * (pair_base / system_base).
    set_x_23!(xfmr, 0.6 * SU)
    @test get_x_23(xfmr, DU) ≈ 0.6 * (20.0 / system_base)
    @test get_x_23(xfmr, SU) ≈ 0.6

    # Ω impedance round-trip on pair 31 (tertiary voltage 69 kV, base_power_31 = 25).
    z_base_31 = 69.0^2 / 25.0
    set_x_31!(xfmr, 0.05 * z_base_31 * OHMS)
    @test get_x_31(xfmr, DU) ≈ 0.05
    @test get_x_31(xfmr, OHMS) ≈ 0.05 * z_base_31

    # Bare floats remain rejected.
    @test_throws ArgumentError set_rating!(primary, 1.0)
end

@testset "TwoWindingTransformer Ω/S set→get round-trip uses one base voltage" begin
    t2w = TwoWindingTransformer(nothing)  # circuit base_power = 100.0
    circuit = get_circuit(t2w)
    set_base_voltage_primary!(circuit, 230.0)
    # Arc endpoint voltage deliberately different from the circuit's base voltage:
    # both conversion directions must resolve the same voltage or the round-trip
    # drifts by (230/115)².
    set_base_voltage!(get_arc(t2w).from, 115.0)

    set_x!(t2w, 105.8 * OHMS)
    @test get_x(t2w, DU) ≈ 105.8 / (230.0^2 / 100.0)
    @test get_x(t2w, OHMS) ≈ 105.8

    y_nat = 3.0 * (100.0 / 230.0^2)
    set_magnetizing_shunt!(t2w, y_nat * SIEMENS)
    @test get_magnetizing_shunt(t2w, DU) ≈ 3.0
    @test get_magnetizing_shunt(t2w, SIEMENS) ≈ y_nat
end

@testset "Test adding component with zero base power" begin
    sys = build_system(PSISystems, "RTS_GMLC_DA_sys")
    bus = first(get_components(PSY.Bus, sys))
    gen = thermal_with_base_power(bus, "Test Gen with Zero Base Power", 0.0)
    @test_logs (:warn, "Invalid range") match_mode = :any add_component!(sys, gen)
    gen2 = thermal_with_base_power(bus, "Test Gen with Non-Zero Base Power", 100.0)
    @test_nowarn add_component!(sys, gen2)
end

@testset "pairwise impedance block is optional, all-or-none" begin
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
    function _pairwise_test_3w(name)
        t = ThreeWindingTransformer(nothing)
        set_name!(t, name)
        set_arc!(get_primary_circuit(t), a1)
        set_arc!(get_secondary_circuit(t), a2)
        set_arc!(get_tertiary_circuit(t), a3)
        foreach(c -> set_available!(c, true), get_circuits(t))
        set_star_bus!(t, star)
        return t
    end

    # (a) fully absent: (nothing)-constructed 3W now defaults the block to nothing
    t_bare = _pairwise_test_3w("t_bare")
    @test get_base_power_12(t_bare) === nothing
    add_component!(sys, t_bare)   # must not throw
    @test get_r_12(t_bare, SU) === nothing
    @test get_x_31(t_bare, DU) === nothing

    # (b) converting a real value against a missing base errors informatively
    t_partial = _pairwise_test_3w("t_partial")
    set_r_12!(t_partial, 0.01 * DU)   # DU-tagged set needs no base; block stays partial
    @test get_r_12(t_partial, DU) ≈ 0.01
    @test_throws ErrorException get_r_12(t_partial, SU)

    # (c) partial block rejected at add_component!
    @test_logs(
        (:error, r"partial pairwise impedance block"),
        match_mode = :any,
        @test_throws(IS.InvalidValue, add_component!(sys, t_partial))
    )

    # (d) full block still accepted, existing conversion behavior intact
    t_full = _pairwise_test_3w("t_full")
    set_base_power_12!(t_full, 15.0)
    set_base_power_23!(t_full, 20.0)
    set_base_power_31!(t_full, 25.0)
    for (setter, v) in (
        (set_r_12!, 0.01), (set_x_12!, 0.10),
        (set_r_23!, 0.02), (set_x_23!, 0.20),
        (set_r_31!, 0.03), (set_x_31!, 0.30),
    )
        setter(t_full, v * DU)
    end
    add_component!(sys, t_full)   # must not throw
    @test get_base_power_12(t_full) == 15.0
    @test get_r_12(t_full, SU) ≈ 0.01 * (100.0 / 15.0)
end

@testset "SystemBasePower components track the system base, not 100 MVA" begin
    system_base = 1000.0
    sys = System(system_base)
    b1 = ACBus(;
        number = 1, name = "b1", available = true,
        bustype = ACBusTypes.REF, angle = 0.0, magnitude = 1.0,
        voltage_limits = (min = 0.9, max = 1.1), base_voltage = 138.0,
    )
    b2 = ACBus(;
        number = 2, name = "b2", available = true,
        bustype = ACBusTypes.PQ, angle = 0.0, magnitude = 1.0,
        voltage_limits = (min = 0.9, max = 1.1), base_voltage = 138.0,
    )
    add_component!(sys, b1)
    add_component!(sys, b2)

    ln = Line(;
        name = "l1", available = true, active_power_flow = 0.0,
        reactive_power_flow = 0.0, arc = Arc(; from = b1, to = b2),
        r = 0.01, x = 0.1, b = (from = 0.0, to = 0.0), rating = 1.0,
        angle_limits = (min = -1.5, max = 1.5),
    )
    add_component!(sys, ln)

    area = Area(; name = "a1")
    add_component!(sys, area)

    # The descriptor's 100.0 default must not survive attachment: this is the
    # bug being pinned. Both Line and Area are among the 12 types whose
    # base_power field records the system base, not an independent device base.
    @test PSY._get_base_power(ln) == system_base
    @test PSY._get_base_power(area) == system_base

    # DU is a pass-through (unaffected by system base); SU must scale by the
    # true system base, not the stale 100.0 default.
    @test get_rating(ln, DU) ≈ 1.0
    @test get_rating(ln, SU) ≈ 1.0

    # set_base_power! is disallowed for SystemBasePower types: the field has no
    # meaning independent of the system it is attached to.
    @test_throws ErrorException set_base_power!(ln, 50.0)
    @test_throws ErrorException set_base_power!(area, 50.0)

    # A detached component of this kind keeps the descriptor default and errors
    # on any access that requires a defined system base, mirroring the behavior
    # of components with no base_power field at all.
    ln_detached = Line(;
        name = "l2", available = true, active_power_flow = 0.0,
        reactive_power_flow = 0.0, arc = Arc(ACBus(nothing), ACBus(nothing)),
        r = 0.01, x = 0.1, b = (from = 0.0, to = 0.0), rating = 1.0,
        angle_limits = (min = -1.5, max = 1.5),
    )
    @test PSY._get_base_power(ln_detached) == 100.0
    @test get_rating(ln_detached, DU) ≈ 1.0
    @test_throws ErrorException get_rating(ln_detached, SU)
    # Detached, `base_power` reads back whatever was stated (a document records it per
    # component); `add_component!` syncs it to the system base on attach. The wrong-base
    # risk is covered by the SU throw above, not by guarding this read.
    @test get_base_power(ln_detached) == 100.0
end
