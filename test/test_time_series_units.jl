@testset "Time series units labels" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, component_base = 250.0)
    bus = get_component(ACBus, sys, "b1")
    stamps = range(DateTime("2020-01-01"); step = Hour(1), length = 3)
    ta = TimeSeries.TimeArray(stamps, [0.2, 0.4, 0.8])
    series(name; kwargs...) = SingleTimeSeries(name, ta; kwargs...)
    read_ts(name, units; kwargs...) =
        get_time_series_values(SingleTimeSeries, gen, name, units; kwargs...)

    # CU: the base field is required, must match, and the owner must accept CU.
    cu = series("cu"; unit_system = IS.CU, quantity_kind = "active_power")
    @test_throws ArgumentError add_time_series!(sys, gen, cu)
    @test_throws ArgumentError add_time_series!(sys, gen, cu; base_field = :rating)
    @test_throws ArgumentError add_time_series!(sys, bus, cu; base_field = :base_power)
    add_time_series!(sys, gen, cu; base_field = :base_power)
    @test read_ts("cu", u"MW") ≈ [50.0, 100.0, 200.0]
    @test read_ts("cu", u"SU") ≈ [0.5, 1.0, 2.0]
    @test read_ts("cu", u"CU"; quantity = :ActivePower) ≈ [0.2, 0.4, 0.8]
    @test_throws ArgumentError read_ts("cu", u"CU"; quantity = :ReactivePower)

    # With CU, `units` may only restate the per-unit basis; a natural label contradicts it.
    for units in ("MW", "m^3/s", "kg")
        @test_throws ArgumentError add_time_series!(
            sys,
            gen,
            series("cu_$units"; unit_system = IS.CU, units = units,
                quantity_kind = "active_power");
            base_field = :base_power,
        )
    end
    add_time_series!(
        sys,
        gen,
        series("cu_explicit"; unit_system = IS.CU, units = "CU",
            quantity_kind = "active_power");
        base_field = :base_power,
    )
    @test read_ts("cu_explicit", u"MW") ≈ [50.0, 100.0, 200.0]
    @test_throws ArgumentError add_time_series!(
        sys,
        gen,
        series("cu_rate"; unit_system = IS.CU, units = "CU hr^-1",
            quantity_kind = "active_power");
        base_field = :base_power,
    )

    # Natural units: the dimension must match the quantity.
    add_time_series!(sys, gen, series("mw"; units = "MW", quantity_kind = "ActivePower"))
    @test read_ts("mw", u"CU") ≈ [0.2, 0.4, 0.8] ./ 250.0
    @test_throws ArgumentError add_time_series!(
        sys,
        gen,
        series("mw_cu_base"; units = "MW", quantity_kind = "ActivePower");
        base_field = :base_power,
    )
    @test_throws ArgumentError add_time_series!(
        sys,
        gen,
        series("mw_volume"; units = "MW", quantity_kind = "Volume"),
    )
    add_time_series!(
        sys,
        gen,
        series("flow"; units = "m^3/s", quantity_kind = "VolumeFlowRate"),
    )
    @test read_ts("flow", u"m^3/hr") ≈ [0.2, 0.4, 0.8] .* 3600

    # Quantities without a CU base, and quantities outside the vocabulary.
    @test_throws ArgumentError add_time_series!(
        sys,
        gen,
        series("cu_energy"; unit_system = IS.CU, quantity_kind = "energy");
        base_field = :base_power,
    )
    @test_throws ArgumentError add_time_series!(
        sys,
        gen,
        series("unknown"; units = "MW", quantity_kind = "Foo"),
    )

    # Unlabeled series still attach, but cannot be read in units.
    add_time_series!(sys, gen, series("bare"))
    @test_throws ArgumentError read_ts("bare", u"MW")
end

@testset "Time series units labels: CU of a storage capacity" begin
    sys, _ = _sys_with_thermal()
    bus = get_component(ACBus, sys, "b1")
    reservoir = HydroReservoir(nothing)
    set_storage_level_limits!(reservoir, (min = 0.0, max = 500.0))
    set_level_data_type!(reservoir, ReservoirDataType.ENERGY)
    add_component!(sys, reservoir)
    battery = EnergyReservoirStorage(nothing)
    set_bus!(battery, bus)
    set_storage_capacity!(battery, 4.0u"CU")
    set_conversion_factor!(battery, 1.0)
    add_component!(sys, battery)

    stamps = range(DateTime("2020-01-01"); step = Hour(1), length = 3)
    ta = TimeSeries.TimeArray(stamps, [0.2, 0.4, 0.8])
    level(quantity) =
        SingleTimeSeries(quantity, ta; unit_system = IS.CU, quantity_kind = quantity)
    read_ts(owner, name, units) =
        get_time_series_values(SingleTimeSeries, owner, name, units)

    energy = level("energy")
    @test_throws ArgumentError add_time_series!(
        sys,
        reservoir,
        energy;
        base_field = :base_power,
    )
    add_time_series!(sys, reservoir, energy; base_field = :storage_level_limits)
    @test read_ts(reservoir, "energy", u"MW*hr") ≈ [100.0, 200.0, 400.0]
    @test read_ts(reservoir, "energy", u"CU") ≈ [0.2, 0.4, 0.8]
    @test_throws Unitful.DimensionError read_ts(reservoir, "energy", u"SU")

    # A reservoir accounting in energy has no CU volume.
    @test_throws ArgumentError add_time_series!(
        sys,
        reservoir,
        level("volume");
        base_field = :storage_level_limits,
    )

    add_time_series!(sys, battery, energy; base_field = :storage_capacity)
    @test read_ts(battery, "energy", u"MW*hr") ≈ [80.0, 160.0, 320.0]
end

@testset "Time series units labels: power on generators, fluids on reservoirs" begin
    sys, _ = _sys_with_thermal()
    bus = get_component(ACBus, sys, "b1")
    hydro = HydroDispatch(nothing)
    set_bus!(hydro, bus)
    add_component!(sys, hydro)
    energy_reservoir = HydroReservoir(nothing)
    set_name!(energy_reservoir, "energy")
    set_storage_level_limits!(energy_reservoir, (min = 0.0, max = 500.0))
    set_level_data_type!(energy_reservoir, ReservoirDataType.ENERGY)
    add_component!(sys, energy_reservoir)
    head_reservoir = HydroReservoir(nothing)
    set_name!(head_reservoir, "head")
    set_storage_level_limits!(head_reservoir, (min = 280.0, max = 300.0))
    set_level_data_type!(head_reservoir, ReservoirDataType.HEAD)
    add_component!(sys, head_reservoir)

    stamps = range(DateTime("2020-01-01"); step = Hour(1), length = 3)
    ta = TimeSeries.TimeArray(stamps, [0.2, 0.4, 0.8])
    series(name; kwargs...) = SingleTimeSeries(name, ta; kwargs...)
    cu_flow(name, quantity) = series(name; unit_system = IS.CU, units = "CU hr^-1",
        quantity_kind = quantity)

    # A hydro generator takes power only.
    inflow = series("inflow"; units = "m^3/s", quantity_kind = "VolumeFlowRate")
    @test_throws ArgumentError add_time_series!(sys, hydro, inflow)
    add_time_series!(
        sys,
        hydro,
        series("max_active_power"; unit_system = IS.CU, quantity_kind = "active_power");
        base_field = :base_power,
    )

    # An energy reservoir's flows are power, per unit of capacity per hour.
    add_time_series!(
        sys,
        energy_reservoir,
        cu_flow("inflow", "ActivePower");
        base_field = :storage_level_limits,
    )
    @test get_time_series_values(SingleTimeSeries, energy_reservoir, "inflow", u"MW") ≈
          [100.0, 200.0, 400.0]
    @test_throws ArgumentError add_time_series!(
        sys,
        energy_reservoir,
        series("cu_power"; unit_system = IS.CU, quantity_kind = "ActivePower");
        base_field = :storage_level_limits,
    )
    @test_throws ArgumentError add_time_series!(
        sys,
        energy_reservoir,
        series("q"; units = "MVAr", quantity_kind = "ReactivePower"),
    )
    @test_throws ArgumentError add_time_series!(sys, energy_reservoir, inflow)

    # A head reservoir is natural units only.
    @test_throws ArgumentError add_time_series!(
        sys,
        head_reservoir,
        series("target"; unit_system = IS.CU, quantity_kind = "head");
        base_field = :storage_level_limits,
    )
    add_time_series!(
        sys,
        head_reservoir,
        series("target"; units = "m", quantity_kind = "Head"),
    )
    add_time_series!(sys, head_reservoir, inflow)
    @test get_time_series_values(SingleTimeSeries, head_reservoir, "inflow", u"m^3/hr") ≈
          [0.2, 0.4, 0.8] .* 3600

    # Series loaded without `add_time_series!` (the document import path) are checked too.
    IS.add_time_series!(
        sys.data,
        hydro,
        series("inflow"; units = "m^3/s",
            quantity_kind = "VolumeFlowRate"),
    )
    @test_throws ArgumentError PSY._check_all_time_series_labels(sys)
end

@testset "Time series units labels: CU of a reserve requirement" begin
    sys = System(100.0)
    reserve = OnlineReserve{ReserveUp}(nothing)
    add_service!(sys, reserve, Device[])
    set_requirement!(reserve, 0.5u"SU")
    stamps = range(DateTime("2020-01-01"); step = Hour(1), length = 3)
    ta = TimeSeries.TimeArray(stamps, [0.2, 0.4, 0.8])
    cu = SingleTimeSeries(
        "requirement",
        ta;
        unit_system = IS.CU,
        quantity_kind = "active_power",
    )
    read_ts(units) = get_time_series_values(SingleTimeSeries, reserve, "requirement", units)

    @test_throws ArgumentError add_time_series!(sys, reserve, cu; base_field = :base_power)
    add_time_series!(sys, reserve, cu; base_field = :requirement)
    @test read_ts(u"MW") ≈ [10.0, 20.0, 40.0]
    @test read_ts(u"SU") ≈ [0.1, 0.2, 0.4]
    @test read_ts(u"CU") ≈ [0.2, 0.4, 0.8]

    # Stored in natural units, CU still means a fraction of the 50 MW requirement.
    add_time_series!(
        sys,
        reserve,
        SingleTimeSeries("mw", ta .* 100.0; unit_system = IS.NU, units = "MW",
            quantity_kind = "active_power"),
    )
    read_mw(units) = get_time_series_values(SingleTimeSeries, reserve, "mw", units)
    @test read_mw(u"MW") ≈ [20.0, 40.0, 80.0]
    @test read_mw(u"CU") ≈ [0.4, 0.8, 1.6]
    @test read_mw(u"SU") ≈ [0.2, 0.4, 0.8]

    @test_throws ArgumentError add_time_series!(
        sys,
        reserve,
        SingleTimeSeries("q", ta; unit_system = IS.CU, quantity_kind = "reactive_power");
        base_field = :requirement,
    )
end
