# Tests for the EnergyReservoirStorage loss and ramp fields: `self_discharge`
# (dimensionless pu/hr leakage loss, issue #1683), `standing_loss` (constant
# standing-loss power in device-base pu, MVA unit system), and `ramp_limits`
# (which mimics the ThermalStandard MVA-based unit system).

# Minimal System + EnergyReservoirStorage at the requested device base so the
# ramp_limits unit conversions don't depend on PSB-built fixtures (mirrors
# `_sys_with_thermal` in common.jl).
function _sys_with_storage(;
    system_base = 100.0,
    device_base = 250.0,
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
        base_power = device_base,
        ramp_limits = ramp_limits,
        standing_loss = standing_loss,
    )
    add_component!(sys, storage)
    return sys, storage
end

@testset "EnergyReservoirStorage self_discharge / ramp_limits defaults" begin
    s = EnergyReservoirStorage(nothing)
    @test get_self_discharge(s) == 0.0
    @test iszero(get_standing_loss(s, DU))
    sys, storage = _sys_with_storage()
    @test isnothing(get_ramp_limits(storage, NU))
    @test isnothing(get_ramp_limits(storage, SU))
    @test get_self_discharge(storage) == 0.0
    @test iszero(get_standing_loss(storage, SU))
end

@testset "EnergyReservoirStorage self_discharge getter/setter" begin
    s = EnergyReservoirStorage(nothing)
    @test get_self_discharge(s) == 0.0
    set_self_discharge!(s, 0.02)
    @test get_self_discharge(s) == 0.02
end

@testset "EnergyReservoirStorage ramp_limits mimics ThermalStandard unit system" begin
    device_base = 250.0
    system_base = 100.0
    sys, storage =
        _sys_with_storage(; system_base, device_base, ramp_limits = (up = 0.5, down = 0.4))

    # Construction stores the raw value at the device base (DU).
    ramp_du = get_ramp_limits(storage, DU)
    @test ramp_du.up ≈ 0.5
    @test ramp_du.down ≈ 0.4

    # System base: DU * device_base / system_base.
    ramp_su = get_ramp_limits(storage, SU)
    @test ramp_su.up ≈ 0.5 * device_base / system_base
    @test ramp_su.down ≈ 0.4 * device_base / system_base

    # Natural units: DU * device_base.
    ramp_nu = get_ramp_limits(storage, NU)
    @test ramp_nu.up ≈ 0.5 * device_base
    @test ramp_nu.down ≈ 0.4 * device_base

    # Nothing passthrough for the bare and `_unitful` companion, mirroring the
    # ThermalStandard contract in test_base_power.jl.
    set_ramp_limits!(storage, nothing)
    @test isnothing(get_ramp_limits(storage, NU))
    @test isnothing(get_ramp_limits_unitful(storage, NU))
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
    )
    @test_logs (:error, r"Invalid range") match_mode = :any @test_throws IS.InvalidValue PowerSystems.check_component(
        sys,
        bad,
    )
end

@testset "EnergyReservoirStorage standing_loss unit conversions" begin
    device_base = 250.0
    system_base = 100.0
    sys, storage =
        _sys_with_storage(; system_base, device_base, standing_loss = 0.02)

    # Construction stores the raw value at the device base (DU).
    @test get_standing_loss(storage, DU) ≈ 0.02

    # System base: DU * device_base / system_base.
    @test get_standing_loss(storage, SU) ≈ 0.02 * device_base / system_base

    # Natural units: DU * device_base.
    @test get_standing_loss(storage, NU) ≈ 0.02 * device_base

    # MW (Unitful domain target): bare number reads the same as NU.
    @test get_standing_loss(storage, u"MW") isa Float64
    @test get_standing_loss(storage, u"MW") ≈ 0.02 * device_base

    # `_unitful` companion returns a tagged quantity with the same magnitude.
    @test IS._strip_units(get_standing_loss_unitful(storage, SU)) ≈
          0.02 * device_base / system_base
    @test get_standing_loss_unitful(storage, u"MW") isa Unitful.Quantity
end

@testset "EnergyReservoirStorage standing_loss tagged setter" begin
    device_base = 250.0
    system_base = 100.0
    sys, storage = _sys_with_storage(; system_base, device_base)

    # Bare floats are rejected: units must be explicit.
    @test_throws ArgumentError set_standing_loss!(storage, 0.05)

    # SU-tagged input converts to the device base for storage.
    set_standing_loss!(storage, 0.05 * SU)
    @test get_standing_loss(storage, DU) ≈ 0.05 * system_base / device_base
    @test get_standing_loss(storage, SU) ≈ 0.05

    # DU-tagged input round-trips exactly.
    set_standing_loss!(storage, 0.02 * DU)
    @test get_standing_loss(storage, DU) ≈ 0.02
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
    @test get_standing_loss(storage2, DU) ≈ 0.03
end
