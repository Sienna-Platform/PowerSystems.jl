@testset "Bus Constructors" begin
    tBus = ACBus(nothing)
    tLoadZone = LoadZone(nothing)

    bus = ACBus(
        1,
        "test",
        true,
        ACBusTypes.SLACK,
        0.0,
        0.0,
        (min = 0.0, max = 0.0),
        nothing,
        nothing,
        nothing,
    )

    @test PowerSystems.get_bustype(bus) == ACBusTypes.REF
end

@testset "Generation Constructors" begin
    for T in InteractiveUtils.subtypes(PSY.OperationalCost)
        isabstracttype(T) || (@test T(nothing) isa IS.InfrastructureSystemsType)
    end
    # TODO add concrete subtypes of ProductionVariableCostCurve?

    tThermalGen = ThermalStandard(nothing)
    @test tThermalGen isa PowerSystems.Component
    tHydroDispatch = HydroDispatch(nothing)
    @test tHydroDispatch isa PowerSystems.Component
    tRenewableNonDispatch = RenewableNonDispatch(nothing)
    @test tRenewableNonDispatch isa PowerSystems.Component
    tRenewableDispatch = RenewableDispatch(nothing)
    @test tRenewableDispatch isa PowerSystems.Component
    tRenewableDispatch = RenewableDispatch(nothing)
    @test tRenewableDispatch isa PowerSystems.Component
    tTurbine = HydroTurbine(nothing)
    @test tTurbine isa PowerSystems.Component
    tReservoir = HydroReservoir(nothing)
    @test tReservoir isa PowerSystems.Component
end

@testset "Source Constructors" begin
    tSource = Source(nothing)
    @test tSource isa PowerSystems.Component
end

@testset "Storage Constructors" begin
    tStorage = EnergyReservoirStorage(nothing)
    @test tStorage isa PowerSystems.Component
end

@testset "Load Constructors" begin
    tPowerLoad = PowerLoad(nothing)
    @test tPowerLoad isa PowerSystems.Component
    tStandardLoad = StandardLoad(nothing)
    @test tStandardLoad isa PowerSystems.Component
    tPowerLoad = PowerLoad("init", true, ACBus(nothing), 0.0, 0.0, 100.0, 0.0, 0.0)
    @test tPowerLoad isa PowerSystems.Component
    tLoad = InterruptiblePowerLoad(nothing)
    @test tLoad isa PowerSystems.Component
    tShiftableLoad = ShiftablePowerLoad(nothing)
    @test tShiftableLoad isa PowerSystems.Component
    tInterruptibleStandardLoad = InterruptibleStandardLoad(nothing)
    @test tInterruptibleStandardLoad isa PowerSystems.Component
end

@testset "Branch Constructors" begin
    tLine = Line(nothing)
    @test tLine isa PowerSystems.Component
    tMonitoredLine = MonitoredLine(nothing)
    @test tMonitoredLine isa PowerSystems.Component
    tTwoTerminalGenericHVDCLine = TwoTerminalGenericHVDCLine(nothing)
    @test tTwoTerminalGenericHVDCLine isa PowerSystems.Component
    tTwoTerminalLCCLine = TwoTerminalLCCLine(nothing)
    @test tTwoTerminalLCCLine isa PowerSystems.Component
    tTwoTerminalVSCLine = TwoTerminalVSCLine(nothing)
    @test tTwoTerminalVSCLine isa PowerSystems.Component
    tTransformer2W = Transformer2W(nothing)
    @test tTransformer2W isa PowerSystems.Component
    tTapTransformer = TapTransformer(nothing)
    @test tTapTransformer isa PowerSystems.Component
    tPhaseShiftingTransformer = PhaseShiftingTransformer(nothing)
    @test tPhaseShiftingTransformer isa PowerSystems.Component
    tTransformer3W = Transformer3W(nothing)
    @test tTransformer3W isa PowerSystems.Component
    tPhaseShiftingTransformer3W = PhaseShiftingTransformer3W(nothing)
    @test tPhaseShiftingTransformer3W isa PowerSystems.Component
    tGenericArcImpedance = GenericArcImpedance(nothing)
    @test tGenericArcImpedance isa PowerSystems.Component
end

@testset "Service Constructors" begin
    tConstantReserve = ConstantReserve{ReserveUp}(nothing)
    @test tConstantReserve isa PowerSystems.Service
    tVariableReserve = VariableReserve{ReserveDown}(nothing)
    @test tVariableReserve isa PowerSystems.Service
end

@testset "TimeSeriesData Constructors" begin
    tg = RenewableNonDispatch(nothing)
    data = PowerSystems.TimeSeries.TimeArray(
        [DateTime("01-01-01"), DateTime("01-01-01") + Hour(1)],
        [1.0, 1.0],
    )
    #SingleTimeSeries Tests
    ts = SingleTimeSeries("scalingfactor", Hour(1), DateTime("01-01-01"), 24)
    @test ts isa PowerSystems.TimeSeriesData
    ts = SingleTimeSeries(; name = "scalingfactor", data = data)
    @test ts isa PowerSystems.TimeSeriesData

    #Probabilistic Tests
    data = SortedDict(
        DateTime("01-01-01") => [1.0 1.0; 2.0 2.0],
        DateTime("01-01-01") + Hour(1) => [1.0 1.0; 2.0 2.0],
    )
    ts = Probabilistic("scalingfactor", data, [0.5, 0.5], Hour(1))
    @test ts isa PowerSystems.TimeSeriesData
    ts = Probabilistic(;
        name = "scalingfactor",
        percentiles = [1.0, 1.0],
        data = data,
        resolution = Hour(1),
    )
    @test ts isa PowerSystems.TimeSeriesData
    ##Scenario Tests
    ts = Scenarios("scalingfactor", data, Hour(1))
    @test ts isa PowerSystems.TimeSeriesData
end
