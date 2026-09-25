# Tests for the EnergyReservoirStorage loss and ramp fields: `self_discharge`
# (dimensionless pu/hr leakage loss, issue #1683), `standing_loss` (constant
# standing-loss power in component-base pu, MVA unit system), and `ramp_limits`
# (which mimics the ThermalStandard MVA-based unit system).

# Minimal System + EnergyReservoirStorage at the requested component base so the
# ramp_limits unit conversions don't depend on PSB-built fixtures (mirrors
# `_sys_with_thermal` in common.jl).
function _sys_with_storage(;
    system_base = 100.0,
    component_base = 250.0,
    ramp_limits = nothing,
    standing_loss = 0.0,
)
    sys = System(system_base)
    bus = ACBus(;
        number = 1, name = "b1", available = true,
        bustype = ACBusTypes.REF, angle = 0.0, magnitude = 1.0,
        voltage_limits = (min = 0.9, max = 1.1), base_voltage = 138.0,
    )
    add_component!(sys, bus)
    storage = EnergyReservoirStorage(;
        name = "storage1", available = true, bus = bus,
        prime_mover_type = PrimeMovers.BA,
        storage_technology_type = StorageTech.OTHER_CHEM,
        storage_capacity = 1.0,
        storage_level_limits = (min = 0.0, max = 1.0),
        initial_storage_capacity_level = 0.5,
        rating = 1.0, active_power = 0.0,
        input_active_power_limits = (min = 0.0, max = 1.0),
        output_active_power_limits = (min = 0.0, max = 1.0),
        efficiency = (in = 0.9, out = 0.9),
        reactive_power = 0.0, reactive_power_limits = (min = -1.0, max = 1.0),
        base_power = component_base,
        ramp_limits = ramp_limits,
        standing_loss = standing_loss,
        input_basis = u"CU",
    )
    add_component!(sys, storage)
    return sys, storage
end

@testset "EnergyReservoirStorage self_discharge / ramp_limits defaults" begin
    s = EnergyReservoirStorage(nothing)
    @test get_self_discharge(s) == 0.0
    @test iszero(get_standing_loss(s, u"CU"))
    sys, storage = _sys_with_storage()
    @test isnothing(get_ramp_limits(storage, u"NU"))
    @test isnothing(get_ramp_limits(storage, u"SU/minute"))
    # An unset rate field has no units to get wrong: a bare `CU`/`SU`, rejected on a
    # field that is set, still passes through as `nothing` here.
    @test isnothing(get_ramp_limits(storage, u"CU"))
    @test isnothing(get_ramp_limits(storage, u"SU"))
    @test get_self_discharge(storage) == 0.0
    @test iszero(get_standing_loss(storage, u"SU"))
end

@testset "EnergyReservoirStorage self_discharge getter/setter" begin
    s = EnergyReservoirStorage(nothing)
    @test get_self_discharge(s) == 0.0
    set_self_discharge!(s, 0.02)
    @test get_self_discharge(s) == 0.02
end

@testset "EnergyReservoirStorage ramp_limits mimics ThermalStandard unit system" begin
    component_base = 250.0
    system_base = 100.0
    sys, storage =
        _sys_with_storage(;
            system_base,
            component_base,
            ramp_limits = (up = 0.5, down = 0.4),
        )

    # `ramp_limits` is a rate, so a relative target must name a time; a bare `CU`/`SU`
    # does not say per what time and is rejected.
    @test_throws ArgumentError get_ramp_limits(storage, u"CU")
    @test_throws ArgumentError get_ramp_limits(storage, u"SU")
    # …and the message names the field, as the setter's twin does, rather than the
    # engine-internal category constant.
    msg = try
        get_ramp_limits(storage, u"SU")
    catch e
        sprint(showerror, e)
    end
    @test occursin("`EnergyReservoirStorage`'s `ramp_limits`", msg)
    @test occursin("u\"CU/minute\"", msg)

    # Construction stores the raw value at the component base, per minute.
    ramp_du = get_ramp_limits(storage, u"CU/minute")
    @test ramp_du.up ≈ 0.5
    @test ramp_du.down ≈ 0.4

    # System base: CU * component_base / system_base, time unchanged.
    ramp_su = get_ramp_limits(storage, u"SU/minute")
    @test ramp_su.up ≈ 0.5 * component_base / system_base
    @test ramp_su.down ≈ 0.4 * component_base / system_base

    # Natural units: CU * component_base per minute.
    ramp_nu = get_ramp_limits(storage, u"NU/minute")
    @test ramp_nu.up ≈ 0.5 * component_base
    @test ramp_nu.down ≈ 0.4 * component_base
    @test get_ramp_limits(storage, u"MW/minute") == ramp_nu

    # The time axis converts independently of the power axis.
    @test get_ramp_limits(storage, u"CU/hr").up ≈ 0.5 * 60
    @test get_ramp_limits(storage, u"MW/hr").up ≈ 0.5 * component_base * 60

    # Nothing passthrough for the bare and `_unitful` companion, mirroring the
    # ThermalStandard contract in test_base_power.jl.
    set_ramp_limits!(storage, nothing)
    @test isnothing(get_ramp_limits(storage, u"NU"))
    @test isnothing(get_ramp_limits_unitful(storage, u"NU"))
end

@testset "EnergyReservoirStorage negative ramp_limits fails validation" begin
    sys = System(100.0; runchecks = false)
    bad = EnergyReservoirStorage(;
        name = "bad_storage", available = true, bus = ACBus(nothing),
        prime_mover_type = PrimeMovers.BA,
        storage_technology_type = StorageTech.OTHER_CHEM,
        storage_capacity = 1.0,
        storage_level_limits = (min = 0.0, max = 1.0),
        initial_storage_capacity_level = 0.5,
        rating = 1.0, active_power = 0.0,
        input_active_power_limits = (min = 0.0, max = 1.0),
        output_active_power_limits = (min = 0.0, max = 1.0),
        efficiency = (in = 0.9, out = 0.9),
        reactive_power = 0.0, reactive_power_limits = (min = -1.0, max = 1.0),
        base_power = 100.0,
        ramp_limits = (up = -10.0, down = -3.0),
        input_basis = u"CU",
    )
    @test_logs (:error, r"Invalid range") match_mode = :any @test_throws IS.InvalidValue PowerSystems.check_component(
        sys,
        bad,
    )
end

@testset "EnergyReservoirStorage standing_loss unit conversions" begin
    component_base = 250.0
    system_base = 100.0
    sys, storage =
        _sys_with_storage(; system_base, component_base, standing_loss = 0.02)

    # Construction stores the raw value at the component base (CU).
    @test get_standing_loss(storage, u"CU") ≈ 0.02

    # System base: CU * component_base / system_base.
    @test get_standing_loss(storage, u"SU") ≈ 0.02 * component_base / system_base

    # Natural units: CU * component_base.
    @test get_standing_loss(storage, u"NU") ≈ 0.02 * component_base

    # MW (Unitful domain target): bare number reads the same as NU.
    @test get_standing_loss(storage, u"MW") isa Float64
    @test get_standing_loss(storage, u"MW") ≈ 0.02 * component_base

    # `_unitful` companion returns a tagged quantity with the same magnitude.
    @test IS._strip_units(get_standing_loss_unitful(storage, u"SU")) ≈
          0.02 * component_base / system_base
    @test get_standing_loss_unitful(storage, u"MW") isa Unitful.Quantity
end

@testset "EnergyReservoirStorage standing_loss tagged setter" begin
    component_base = 250.0
    system_base = 100.0
    sys, storage = _sys_with_storage(; system_base, component_base)

    # Bare floats are rejected: units must be explicit.
    @test_throws ArgumentError set_standing_loss!(storage, 0.05)

    # SU-tagged input converts to the component base for storage.
    set_standing_loss!(storage, 0.05 * u"SU")
    @test get_standing_loss(storage, u"CU") ≈ 0.05 * system_base / component_base
    @test get_standing_loss(storage, u"SU") ≈ 0.05

    # CU-tagged input round-trips exactly.
    set_standing_loss!(storage, 0.02 * u"CU")
    @test get_standing_loss(storage, u"CU") ≈ 0.02
end

@testset "EnergyReservoirStorage negative standing_loss warns validation" begin
    sys = System(100.0; runchecks = false)
    bad = EnergyReservoirStorage(;
        name = "bad_storage", available = true, bus = ACBus(nothing),
        prime_mover_type = PrimeMovers.BA,
        storage_technology_type = StorageTech.OTHER_CHEM,
        storage_capacity = 1.0,
        storage_level_limits = (min = 0.0, max = 1.0),
        initial_storage_capacity_level = 0.5,
        rating = 1.0, active_power = 0.0,
        input_active_power_limits = (min = 0.0, max = 1.0),
        output_active_power_limits = (min = 0.0, max = 1.0),
        efficiency = (in = 0.9, out = 0.9),
        reactive_power = 0.0, reactive_power_limits = (min = -1.0, max = 1.0),
        base_power = 100.0,
        standing_loss = -0.1,
        input_basis = u"CU",
    )
    @test_logs (:warn, r"Invalid range") match_mode = :any PowerSystems.check_component(
        sys,
        bad,
    )
end

@testset "EnergyReservoirStorage standing_loss serialization round-trip" begin
    sys, storage = _sys_with_storage(; standing_loss = 0.03)
    sys2 = roundtrip_system(sys)
    storage2 = get_component(EnergyReservoirStorage, sys2, "storage1")
    @test get_standing_loss(storage2, u"CU") ≈ 0.03
end
