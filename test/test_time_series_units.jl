@testset "Time series units labels" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, component_base = 250.0)
    bus = get_component(ACBus, sys, "b1")
    stamps = range(DateTime("2020-01-01"); step = Hour(1), length = 3)
    ta = TimeSeries.TimeArray(stamps, [0.2, 0.4, 0.8])
    series(name; kwargs...) = SingleTimeSeries(name, ta; kwargs...)
    cu_series(name; kwargs...) =
        series(name; quantity_kind = "active_power", per_unit_of = "base_power", kwargs...)
    read_ts(name, units; kwargs...) =
        get_time_series_values(SingleTimeSeries, gen, name, units; kwargs...)

    # CU: per_unit_of is required, must match, and the owner must accept CU.
    @test_throws ArgumentError add_time_series!(
        sys,
        gen,
        cu_series("cu"; per_unit_of = nothing),
    )
    @test_throws ArgumentError add_time_series!(
        sys,
        gen,
        cu_series("cu"; per_unit_of = "rating"),
    )
    @test_throws ArgumentError add_time_series!(sys, bus, cu_series("cu"))
    add_time_series!(sys, gen, cu_series("cu"))
    @test read_ts("cu", u"MW") ≈ [50.0, 100.0, 200.0]
    @test read_ts("cu", u"SU") ≈ [0.5, 1.0, 2.0]
    @test read_ts("cu", u"CU"; quantity = :ActivePower) ≈ [0.2, 0.4, 0.8]
    ta_mw = get_time_series_array(SingleTimeSeries, gen, "cu", u"MW")
    @test TimeSeries.timestamp(ta_mw) == collect(stamps)
    @test TimeSeries.values(ta_mw) ≈ [50.0, 100.0, 200.0]

    # A forecast reads one window, converted the same way.
    t0 = first(stamps)
    fc = Deterministic(
        "fc", Dict(t0 => [0.1, 0.2], t0 + Hour(1) => [0.3, 0.4]), Hour(1);
        quantity_kind = "active_power", per_unit_of = "base_power",
    )
    add_time_series!(sys, gen, fc)
    @test get_time_series_values(
        Deterministic,
        gen,
        "fc",
        u"MW";
        start_time = t0 + Hour(1),
    ) ≈
          [75.0, 100.0]
    fc_mw = get_time_series_array(Deterministic, gen, "fc", u"MW";
        start_time = t0 + Hour(1), len = 1)
    @test TimeSeries.timestamp(fc_mw) == [t0 + Hour(1)]
    @test TimeSeries.values(fc_mw) ≈ [75.0]
    @test_throws ArgumentError get_time_series_array(
        SingleTimeSeries, gen, "cu", u"CU"; quantity = :ReactivePower)
    @test_throws ArgumentError read_ts("cu", u"CU"; quantity = :ReactivePower)
    # The label is stored with the series.
    @test IS.get_per_unit_of(get_time_series(SingleTimeSeries, gen, "cu")) == "base_power"

    # With CU, `units` may only restate the per-unit basis; a natural label contradicts it.
    for units in ("MW", "m^3/s", "kg")
        @test_throws ArgumentError add_time_series!(sys, gen, cu_series("cu_$units"; units))
    end
    add_time_series!(sys, gen, cu_series("cu_explicit"; units = "CU"))
    @test read_ts("cu_explicit", u"MW") ≈ [50.0, 100.0, 200.0]
    # Per-unit units without per_unit_of name no base.
    @test_throws ArgumentError add_time_series!(
        sys,
        gen,
        series("nu_cu"; units = "CU", quantity_kind = "active_power"),
    )
    @test_throws ArgumentError add_time_series!(
        sys,
        gen,
        cu_series("cu_rate"; units = "CU hr^-1"),
    )

    # Natural units: the dimension must match the quantity, and per_unit_of is CU only.
    add_time_series!(sys, gen, series("mw"; units = "MW", quantity_kind = "ActivePower"))
    @test read_ts("mw", u"CU") ≈ [0.2, 0.4, 0.8] ./ 250.0
    @test read_ts("mw", u"NU") ≈ [0.2, 0.4, 0.8]
    @test read_ts("cu", u"NU") ≈ [50.0, 100.0, 200.0]
    # An owner without a `base_power` field has no CU base, on attach or on read.
    shunt = SwitchedAdmittance(nothing)
    set_name!(shunt, "shunt")
    set_bus!(shunt, bus)
    add_component!(sys, shunt)
    @test_throws ArgumentError add_time_series!(sys, shunt, cu_series("cu"))
    add_time_series!(sys, shunt, series("mw"; units = "MW", quantity_kind = "ActivePower"))
    @test_throws ArgumentError get_time_series_values(SingleTimeSeries, shunt, "mw", u"CU")
    @test_throws ArgumentError add_time_series!(
        sys,
        gen,
        series("mw_per_unit_of"; units = "MW", quantity_kind = "ActivePower",
            per_unit_of = "base_power"),
    )
    @test_throws ArgumentError add_time_series!(sys, gen,
        series("bare_per_unit_of"; per_unit_of = "base_power"))
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
    @test_throws ArgumentError add_time_series!(sys, gen,
        cu_series("cu_energy"; quantity_kind = "energy"))
    @test_throws ArgumentError add_time_series!(
        sys,
        gen,
        series("unknown"; units = "MW", quantity_kind = "Foo"),
    )

    # A transaction block checks the labels too, for single and bulk adds.
    txn_cu = cu_series("txn_cu"; per_unit_of = nothing)
    @test_throws ArgumentError time_series_transaction(
        txn -> add_time_series!(txn, gen, txn_cu),
        sys,
    )
    @test_throws ArgumentError time_series_transaction(
        txn -> add_time_series!(txn, [gen], txn_cu),
        sys,
    )
    @test !has_time_series(gen, SingleTimeSeries, "txn_cu")
    time_series_transaction(sys) do txn
        add_time_series!(txn, gen, cu_series("txn_cu"))
        add_time_series!(txn, [gen], cu_series("txn_cu_vec"))
    end
    @test read_ts("txn_cu", u"MW") ≈ [50.0, 100.0, 200.0]
    @test read_ts("txn_cu_vec", u"MW") ≈ [50.0, 100.0, 200.0]

    # The bulk add checks every component, from any iterable, single-pass ones included.
    @test_throws ArgumentError add_time_series!(sys, [gen], txn_cu)
    for (name, owners) in (
        ("bulk_vec", [gen]),
        ("bulk_iter", get_components(ThermalStandard, sys)),
        ("bulk_stateful", Iterators.Stateful([gen])),
    )
        keys = add_time_series!(sys, owners, cu_series(name))
        @test length(keys) == 1
        @test read_ts(name, u"MW") ≈ [50.0, 100.0, 200.0]
    end
    @test_throws ArgumentError add_time_series!(
        sys,
        ThermalStandard[],
        cu_series("bulk_empty"),
    )

    # Unlabeled series still attach, but cannot be read in units.
    add_time_series!(sys, gen, series("bare"))
    @test_throws ArgumentError read_ts("bare", u"MW")
end

@testset "Time series units labels: CU of a battery's capacity" begin
    sys, _ = _sys_with_thermal()
    bus = get_component(ACBus, sys, "b1")
    battery = EnergyReservoirStorage(nothing)
    set_bus!(battery, bus)
    set_storage_capacity!(battery, 4.0u"CU")
    set_conversion_factor!(battery, 1.0)
    add_component!(sys, battery)

    stamps = range(DateTime("2020-01-01"); step = Hour(1), length = 3)
    ta = TimeSeries.TimeArray(stamps, [0.2, 0.4, 0.8])
    read_ts(name, units) = get_time_series_values(SingleTimeSeries, battery, name, units)

    energy(per_unit_of) =
        SingleTimeSeries("energy", ta; quantity_kind = "energy", per_unit_of = per_unit_of)
    @test_throws ArgumentError add_time_series!(sys, battery, energy("base_power"))
    add_time_series!(sys, battery, energy("storage_capacity"))
    @test read_ts("energy", u"MW*hr") ≈ [80.0, 160.0, 320.0]
    @test read_ts("energy", u"CU") ≈ [0.2, 0.4, 0.8]
    # Energy reads in SU*hr, on the 100 MVA system base; plain SU is a power.
    @test read_ts("energy", u"SU*hr") ≈ [0.8, 1.6, 3.2]

    # Stored in natural units, read in CU: a fraction of the 400 MWh capacity.
    mwh = SingleTimeSeries("mwh", ta .* 1000.0; units = "MW*hr",
        quantity_kind = "energy")
    add_time_series!(sys, battery, mwh)
    @test read_ts("mwh", u"CU") ≈ [0.5, 1.0, 2.0]

    # A battery's power follows the device rule: CU of its base_power.
    battery_base = get_base_power(battery, u"NU")
    add_time_series!(
        sys,
        battery,
        SingleTimeSeries("p", ta; quantity_kind = "active_power",
            per_unit_of = "base_power"),
    )
    @test read_ts("p", u"MW") ≈ [0.2, 0.4, 0.8] .* battery_base
    add_time_series!(
        sys,
        battery,
        SingleTimeSeries("p_mw", ta; units = "MW",
            quantity_kind = "active_power"),
    )
    @test read_ts("p_mw", u"CU") ≈ [0.2, 0.4, 0.8] ./ battery_base
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
    read_ts(owner, name, units) =
        get_time_series_values(SingleTimeSeries, owner, name, units)

    # A hydro generator takes power only.
    inflow = series("inflow"; units = "m^3/s", quantity_kind = "VolumeFlowRate")
    @test_throws ArgumentError add_time_series!(sys, hydro, inflow)
    add_time_series!(
        sys,
        hydro,
        series("max_active_power"; quantity_kind = "active_power",
            per_unit_of = "base_power"),
    )

    # A reservoir is natural units only, levels and flows alike, whatever it accounts in.
    for (owner, quantity) in
        ((energy_reservoir, "energy"), (energy_reservoir, "ActivePower"),
        (head_reservoir, "head"), (head_reservoir, "VolumeFlowRate"))
        for per_unit_of in (nothing, "storage_level_limits", "base_power")
            cu = series("cu_$quantity"; quantity_kind = quantity,
                per_unit_of = per_unit_of)
            @test_throws ArgumentError add_time_series!(sys, owner, cu)
        end
    end

    # An energy reservoir's levels are energy and its flows power.
    add_time_series!(sys, energy_reservoir,
        series("level"; units = "MW*hr", quantity_kind = "energy"))
    add_time_series!(sys, energy_reservoir,
        series("inflow"; units = "MW", quantity_kind = "ActivePower"))
    @test read_ts(energy_reservoir, "level", u"MW*hr") ≈ [0.2, 0.4, 0.8]
    @test read_ts(energy_reservoir, "inflow", u"kW") ≈ [200.0, 400.0, 800.0]
    # On the 100 MVA system base: SU*hr for the level, SU for the flow.
    @test read_ts(energy_reservoir, "level", u"SU*hr") ≈ [0.2, 0.4, 0.8] ./ 100
    @test read_ts(energy_reservoir, "inflow", u"SU") ≈ [0.2, 0.4, 0.8] ./ 100
    # No CU base on a reservoir, so nothing reads as a fraction of its 500 MWh.
    @test_throws ArgumentError read_ts(energy_reservoir, "level", u"CU")
    @test_throws ArgumentError read_ts(energy_reservoir, "inflow", u"CU")
    @test_throws ArgumentError add_time_series!(
        sys,
        energy_reservoir,
        series("q"; units = "MVAr", quantity_kind = "ReactivePower"),
    )
    @test_throws ArgumentError add_time_series!(sys, energy_reservoir, inflow)

    add_time_series!(
        sys,
        head_reservoir,
        series("target"; units = "m", quantity_kind = "Head"),
    )
    add_time_series!(sys, head_reservoir, inflow)
    @test read_ts(head_reservoir, "inflow", u"m^3/hr") ≈ [0.2, 0.4, 0.8] .* 3600
    @test_throws ArgumentError read_ts(head_reservoir, "target", u"CU")
    # Water has no system base.
    @test_throws Unitful.DimensionError read_ts(head_reservoir, "inflow", u"SU")

    # IS's own add runs the same check.
    bad_inflow = series("inflow"; units = "m^3/s", quantity_kind = "VolumeFlowRate")
    @test_throws ArgumentError IS.add_time_series!(sys.data, hydro, bad_inflow)
    # Series loaded straight into the store (the document import path) are checked too.
    IS.infrastore_add_time_series!(sys.data.time_series_manager, hydro, bad_inflow)
    @test_throws ArgumentError PSY._check_all_time_series_labels(sys)
end

@testset "Time series units labels: a reserve requirement is natural units only" begin
    sys = System(100.0)
    reserve = OnlineReserve{ReserveUp}(nothing)
    add_service!(sys, reserve, Device[])
    set_requirement!(reserve, 0.5u"SU")
    stamps = range(DateTime("2020-01-01"); step = Hour(1), length = 3)
    ta = TimeSeries.TimeArray(stamps, [0.2, 0.4, 0.8])
    read_ts(units) = get_time_series_values(SingleTimeSeries, reserve, "requirement", units)

    for per_unit_of in (nothing, "requirement", "base_power")
        cu = SingleTimeSeries(
            "requirement",
            ta;
            quantity_kind = "active_power",
            per_unit_of = per_unit_of,
        )
        @test_throws ArgumentError add_time_series!(sys, reserve, cu)
    end

    add_time_series!(
        sys,
        reserve,
        SingleTimeSeries("requirement", ta .* 100.0; units = "MW",
            quantity_kind = "active_power"),
    )
    @test read_ts(u"MW") ≈ [20.0, 40.0, 80.0]
    @test read_ts(u"SU") ≈ [0.2, 0.4, 0.8]
    # Not even as a fraction of the 50 MW requirement.
    @test_throws ArgumentError read_ts(u"CU")
end

@testset "Time series units labels: per_unit_of survives every file form" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, component_base = 250.0)
    stamps = range(DateTime("2020-01-01"); step = Hour(1), length = 3)
    add_time_series!(
        sys,
        gen,
        SingleTimeSeries("cu", TimeSeries.TimeArray(stamps, [0.2, 0.4, 0.8]);
            quantity_kind = "active_power", per_unit_of = "base_power",
        ),
    )
    mktempdir() do dir
        for path in ("case", "case.json", "case.sns")
            to_file(sys, joinpath(dir, path))
            # Importing checks the stored labels, per_unit_of included.
            sys2 = from_file(joinpath(dir, path))
            gen2 = get_component(ThermalStandard, sys2, get_name(gen))
            ts = get_time_series(SingleTimeSeries, gen2, "cu")
            @test IS.get_per_unit_of(ts) == "base_power"
            @test get_time_series_values(SingleTimeSeries, gen2, "cu", u"MW") ≈
                  [50.0, 100.0, 200.0]
            IS.close!(IS.get_data_store(sys2.data.time_series_manager))
        end
    end
end
