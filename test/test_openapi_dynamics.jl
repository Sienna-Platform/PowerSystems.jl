# OpenAPI round trips for dynamics: System -> SystemDocument -> System. Every dynamic
# injection and every function block it names must come back field for field.

const DYN_DESCRIPTOR = JSON.parsefile(PSY.POWER_SYSTEM_STRUCT_DESCRIPTOR_FILE)

"""Field equality, recursing into dynamics objects. `internal` holds the id, which is checked
separately."""
_dyn_same(a, b) = isequal(a, b)
function _dyn_same(a::Union{PSY.DynamicComponent, PSY.DynamicInjection}, b)
    typeof(a) == typeof(b) || return false
    return all(
        _dyn_same(getfield(a, f), getfield(b, f)) for f in fieldnames(typeof(a)) if
        f !== :internal
    )
end

_dyn_bus() = ACBus(;
    input_basis = u"CU", number = 1, name = "bus1", available = true,
    bustype = ACBusTypes.REF, angle = 0.0, magnitude = 1.0,
    voltage_limits = (min = 0.9, max = 1.1), base_voltage = 138.0,
)

_dyn_static(bus, name; base_power = 100.0) = ThermalStandard(;
    name = name, available = true, status = OperationalStates.ONLINE, bus = bus,
    active_power = 0.4, reactive_power = 0.01, rating = 0.5,
    prime_mover_type = PrimeMovers.ST, fuel = ThermalFuels.COAL,
    active_power_limits = (min = 0.0, max = 0.4),
    reactive_power_limits = (min = -0.3, max = 0.3),
    time_limits = nothing, ramp_limits = nothing,
    operation_cost = ThermalGenerationCost(CostCurve(LinearCurve(1400.0)), 0.0, 4.0, 2.0),
    base_power = base_power, input_basis = u"CU",
)

"""A system holding one thermal device per entry of `injections`, each with its injection."""
function _dyn_system(injections; base_power = 100.0)
    sys = System(100.0)
    bus = _dyn_bus()
    add_component!(sys, bus)
    for dyn in injections
        static = _dyn_static(bus, get_name(dyn); base_power = base_power)
        add_component!(sys, static)
        add_component!(sys, dyn, static; skip_validation = true)
    end
    return sys
end

"""Assert `sys2` holds a dynamic injection equal to every one in `sys`, with the same id."""
function _test_dynamics_round_trip(sys, sys2)
    for dyn in get_components(PSY.DynamicInjection, sys)
        name = get_name(dyn)
        dyn2 = get_dynamic_injector(get_component(ThermalStandard, sys2, name))
        @test !isnothing(dyn2)
        @test _dyn_same(dyn, dyn2)
        @test IS.get_id(dyn) == IS.get_id(dyn2)
    end
    @test length(get_components(PSY.DynamicInjection, sys)) ==
          length(get_components(PSY.DynamicInjection, sys2))
end

function _file_round_trip(sys; kwargs...)
    dir = mktempdir()
    PSY.to_file(sys, dir; units = CU, force = true)
    return PSY.from_file(dir; kwargs...)
end

# `X(nothing)` builds a zeroed block. Each constructor field then gets a distinct value, so a
# converter that swaps or drops fields cannot pass on zeros. Derived fields are left to the
# constructor.
_perturb(x::Float64, k) = x + 0.001 * k
_perturb(x::Union{Int, Bool, String, Dict}, k) = x
_perturb(x::NamedTuple, k) = map(v -> _perturb(v, k), x)
_perturb(x::NTuple{N, Float64}, k) where {N} = ntuple(i -> _perturb(x[i], k * i), Val(N))
_perturb(x::Vector, k) = [_perturb(v, k) for v in x]

function _constructor_fields(::Type{T}) where {T}
    for item in DYN_DESCRIPTOR["auto_generated_structs"]
        if item["struct_name"] == string(nameof(T))
            return [
                Symbol(f["name"]) for
                f in item["fields"] if
                !haskey(f, "internal_default") && f["name"] != "internal"
            ]
        end
    end
    return nothing
end

"""A `T` whose constructor fields are all distinct, or the zeroed `T(nothing)` when `T` is not
in the descriptor."""
_distinct(::Type{T}, ::Nothing) where {T} = T(nothing)
function _distinct(::Type{T}, fields::Vector{Symbol}) where {T}
    base = T(nothing)
    values = (; (f => _perturb(getfield(base, f), k) for (k, f) in enumerate(fields))...)
    return T(; values...)
end
_distinct(::Type{T}) where {T} = _distinct(T, _constructor_fields(T))

# One injection per block, the other slots at their defaults. The slot follows the block's
# supertype.
_gen(; machine, shaft, avr, tg, pss, name = "g") = DynamicGenerator(;
    name = name, frequency_ref = 60.0, synchronous_machine_dynamics = machine,
    shaft = shaft, excitation_system_dynamics = avr, turbine_governor_dynamics = tg,
    power_system_stabilizer_dynamics = pss,
)

_default_generator_blocks() = (
    machine = BaseMachine(nothing), shaft = SingleMass(nothing),
    avr = AVRFixed(nothing),
    tg = TGFixed(nothing), pss = PSSFixed(nothing),
)

_with_block(name, b::PSY.SynchronousMachineDynamics) =
    _gen(; _default_generator_blocks()..., machine = b, name = name)
_with_block(name, b::PSY.Shaft) =
    _gen(; _default_generator_blocks()..., shaft = b, name = name)
_with_block(name, b::PSY.ExcitationSystemDynamics) =
    _gen(; _default_generator_blocks()..., avr = b, name = name)
_with_block(name, b::PSY.TurbineGovernorDynamics) =
    _gen(; _default_generator_blocks()..., tg = b, name = name)
_with_block(name, b::PSY.PowerSystemStabilizerDynamics) =
    _gen(; _default_generator_blocks()..., pss = b, name = name)

_inv(; name = "i", limiter = nothing, kwargs...) = DynamicInverter(;
    name = name, frequency_ref = 60.0,
    converter = AverageConverter(nothing),
    active_power_control = VirtualInertia(nothing),
    reactive_power_control = ReactivePowerDroop(nothing),
    inner_control = VoltageModeControl(nothing),
    dc_source = FixedDCSource(nothing),
    reference_frame_rotation = KauraPLL(nothing),
    filter = LCLFilter(nothing),
    current_limitation = limiter,
    kwargs...,
)

_with_block(name, b::PSY.Converter) = _inv(; name = name, converter = b)
_with_block(name, b::PSY.ActivePowerControl) = _inv(; name = name, active_power_control = b)
_with_block(name, b::PSY.ReactivePowerControl) =
    _inv(; name = name, reactive_power_control = b)
_with_block(name, b::PSY.InnerControl) = _inv(; name = name, inner_control = b)
_with_block(name, b::PSY.DCSource) = _inv(; name = name, dc_source = b)
_with_block(name, b::PSY.ReferenceFrameRotation) =
    _inv(; name = name, reference_frame_rotation = b)
_with_block(name, b::PSY.Filter) = _inv(; name = name, filter = b)
_with_block(name, b::PSY.CurrentLimitation) = _inv(; name = name, limiter = b)

@testset "OpenAPI dynamics: every function block round trips" begin
    blocks = [_distinct(T) for T in PSY.DYNAMIC_BLOCK_TYPES]
    @test length(blocks) == length(PSY.DYNAMIC_BLOCK_TYPES)
    injections =
        [_with_block("inj_$(i)_$(nameof(typeof(b)))", b) for (i, b) in enumerate(blocks)]
    sys = _dyn_system(injections)
    @test all(PSY.is_document_exportable, injections)

    # Through JSON, which validates every block against its schema. Compiling 87 injection
    # types dominates the time, so the in-memory path is left to the other testsets.
    _test_dynamics_round_trip(sys, _file_round_trip(sys))
end

@testset "OpenAPI dynamics: every injection leaf type round trips" begin
    leaves = IS.get_all_concrete_subtypes(PSY.DynamicInjection)
    @test length(leaves) == 8
    injections = PSY.DynamicInjection[]
    for T in leaves
        dyn = _distinct(T)
        PSY.set_name!(dyn, "leaf_$(nameof(T))")
        push!(injections, dyn)
    end
    sys = _dyn_system(injections)
    doc = PSY.to_openapi(sys)
    _test_dynamics_round_trip(sys, PSY.from_openapi(System, doc))
    _test_dynamics_round_trip(sys, _file_round_trip(sys))
end

@testset "OpenAPI dynamics: DynamicGenerator with each machine family" begin
    se = (0.1, 0.5)
    round_rotor = (
        R = 0.0, Td0_p = 7.4, Td0_pp = 0.03, Tq0_p = 0.06, Tq0_pp = 0.033, Xd = 0.8979,
        Xq = 0.646, Xd_p = 0.2995, Xq_p = 0.646, Xd_pp = 0.23, Xl = 0.1, Se = se,
    )
    salient = (
        R = 0.0, Td0_p = 7.4, Td0_pp = 0.03, Tq0_pp = 0.033, Xd = 0.8979, Xq = 0.646,
        Xd_p = 0.2995, Xd_pp = 0.23, Xl = 0.1, Se = se,
    )
    full = (
        R = 0.003, R_f = 0.0006, R_1d = 0.0284, R_1q = 0.0062, L_d = 1.81, L_q = 1.76,
        L_ad = 1.66, L_aq = 1.61, L_f1d = 1.66, L_ff = 1.825, L_1d = 0.1713,
        L_1q = 0.7525,
    )
    machines = Any[
        BaseMachine(; R = 0.0, Xd_p = 0.2995, eq_p = 1.05),
        OneDOneQMachine(;
            R = 0.0, Xd = 0.8979, Xq = 0.646, Xd_p = 0.2995, Xq_p = 0.04, Td0_p = 7.4,
            Tq0_p = 0.033,
        ),
        SauerPaiMachine(;
            R = 0.0, Xd = 0.920, Xq = 0.130, Xd_p = 0.300, Xq_p = 0.228, Xd_pp = 0.220,
            Xq_pp = 0.290, Xl = 0.1, Td0_p = 5.2, Tq0_p = 0.85, Td0_pp = 0.029,
            Tq0_pp = 0.034,
        ),
        AndersonFouadMachine(;
            R = 0.0, Xd = 0.8979, Xq = 0.646, Xd_p = 0.2995, Xq_p = 0.646, Xd_pp = 0.23,
            Xq_pp = 0.4, Td0_p = 7.4, Tq0_p = 0.01, Td0_pp = 0.03, Tq0_pp = 0.033,
        ),
        SimpleFullMachine(; full...),
        FullMachine(; full...),
        RoundRotorMachine(; round_rotor...),
        SalientPoleMachine(; salient...),
        RoundRotorQuadratic(; round_rotor...),
        RoundRotorExponential(; round_rotor...),
        SalientPoleQuadratic(; salient...),
        SalientPoleExponential(; salient...),
    ]
    injections = [
        _gen(;
            _default_generator_blocks()...,
            machine = m,
            name = "mach_$(nameof(typeof(m)))",
        ) for m in machines
    ]
    sys = _dyn_system(injections)
    doc = PSY.to_openapi(sys)

    # A saturation machine is two components: the base machine and a block naming it.
    for (saturation, base) in (
        ("RoundRotorQuadratic", "RoundRotorMachine"),
        ("RoundRotorExponential", "RoundRotorMachine"),
        ("SalientPoleQuadratic", "SalientPoleMachine"),
        ("SalientPoleExponential", "SalientPoleMachine"),
    )
        po = only(PSY.PC.get_components(doc, saturation))
        base_ids = Set(Int(b.id) for b in PSY.PC.get_components(doc, base))
        @test Int(po.base_machine) in base_ids
        @test length(po.saturation_coeffs) == 2
    end
    # 2 plain round rotor + 2 salient pole machines are the saturation bases, plus the two
    # standalone ones.
    @test length(PSY.PC.get_components(doc, "RoundRotorMachine")) == 3
    @test length(PSY.PC.get_components(doc, "SalientPoleMachine")) == 3

    _test_dynamics_round_trip(sys, PSY.from_openapi(System, doc))
    _test_dynamics_round_trip(sys, _file_round_trip(sys))
end

@testset "OpenAPI dynamics: DynamicInverter with every block" begin
    inverter = DynamicInverter(;
        name = "inverter",
        frequency_ref = 50.0,
        converter = _distinct(AverageConverter),
        active_power_control = _distinct(ActivePowerDroop),
        reactive_power_control = _distinct(ReactivePowerPI),
        inner_control = _distinct(CurrentModeControl),
        dc_source = _distinct(ZeroOrderBESS),
        reference_frame_rotation = _distinct(ReducedOrderPLL),
        filter = _distinct(LCFilter),
        current_limitation = _distinct(HybridOutputCurrentLimiter),
    )
    no_limiter = _inv(; name = "no_limiter")
    sys = _dyn_system([inverter, no_limiter])
    doc = PSY.to_openapi(sys)

    po = first(
        p for p in PSY.PC.get_components(doc, "DynamicInverter") if p.name == "inverter"
    )
    @test po.frequency_ref == 50.0
    @test po.base_power == 100.0
    @test !isnothing(po.current_limitation)
    no_limiter_po = first(
        p for p in PSY.PC.get_components(doc, "DynamicInverter") if p.name == "no_limiter"
    )
    @test no_limiter_po.current_limitation isa PSY.IC.Absent

    _test_dynamics_round_trip(sys, PSY.from_openapi(System, doc))
    _test_dynamics_round_trip(sys, _file_round_trip(sys))
end

@testset "OpenAPI dynamics: dynamic_injector link and loud errors" begin
    sys = _dyn_system([_gen(; _default_generator_blocks()..., name = "g1")])
    doc = PSY.to_openapi(sys)
    dyn_po = only(PSY.PC.get_components(doc, "DynamicGenerator"))
    static_po = only(PSY.PC.get_components(doc, "ThermalStandard"))
    @test static_po.dynamic_injector == dyn_po.id
    @test dyn_po.synchronous_machine_dynamics in
          Set(Int(b.id) for b in PSY.PC.get_components(doc, "BaseMachine"))

    # An injection no static device names.
    doc.components["ThermalStandard"][1] =
        PSY._po_with(static_po; dynamic_injector = PSY.IC.ABSENT)
    @test_throws ErrorException PSY.from_openapi(System, doc)

    # Two bases cannot be held.
    doc = PSY.to_openapi(sys)
    doc.components["DynamicGenerator"][1] = PSY._po_with(dyn_po; base_power = 50.0)
    @test_throws ErrorException PSY.from_openapi(System, doc)
end
