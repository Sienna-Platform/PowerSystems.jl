import DataFrames
import Dates
import TimeSeries

function verify_time_series(sys::System, num_initial_times, num_time_series, len)
    total_time_series = 0
    all_time_series = get_time_series_multiple(sys)
    for time_series in all_time_series
        if length(time_series) != len
            @error "length doesn't match" length(time_series) len
            return false
        end
        total_time_series += 1
    end

    if num_time_series != total_time_series
        @error "num_time_series doesn't match" num_time_series total_time_series
        return false
    end

    return true
end

@testset "Test read_time_series_file_metadata" begin
    for file in ["timeseries_pointers.json", "timeseries_pointers.csv"]
        filename = joinpath(RTS_GMLC_DIR, file)
        all_time_series = IS.read_time_series_file_metadata(filename)
        @test length(all_time_series) == 260

        for time_series in all_time_series
            @test isfile(time_series.data_file)
        end
    end
end

@testset "Test time_series normalization" begin
    component_name = "122_HYDRO_1"
    timeseries_file = joinpath(
        RTS_GMLC_DIR,
        "RTS_GMLC_forecasts",
        "gen",
        "Hydro",
        "DAY_AHEAD_hydro.csv",
    )
    gen = ThermalStandard(nothing)
    gen.name = component_name
    resolution = Dates.Hour(1)

    # Parse the file directly in order to compare values.
    ts_base = SingleTimeSeries(component_name, timeseries_file, gen, resolution)
    timeseries = get_data(ts_base)
    max_value = maximum(TimeSeries.values(timeseries))

    file_metadata = IS.TimeSeriesFileMetadata(;
        simulation = "DAY_AHEAD",
        category = "Generator",
        component_name = "122_HYDRO_1",
        name = "active_power",
        normalization_factor = 1.0,
        data_file = timeseries_file,
        percentiles = [],
        resolution = resolution,
        time_series_type_module = "InfrastructureSystems",
        time_series_type = "SingleTimeSeries",
    )

    # Test code path where no normalization occurs.
    sys = PSB.build_system(PSB.MatpowerTestSystems, "matpower_RTS_GMLC_sys")
    add_time_series!(sys, [file_metadata])
    verify_time_series(sys, 1, 1, 24)
    time_series = collect(get_time_series_multiple(sys))[1]
    @test TimeSeries.values(time_series.data) == TimeSeries.values(timeseries)

    # Test code path where timeseries is normalized by dividing by the max value.
    file_metadata.normalization_factor = "Max"
    sys = PSB.build_system(PSB.MatpowerTestSystems, "matpower_RTS_GMLC_sys")
    add_time_series!(sys, [file_metadata])
    verify_time_series(sys, 1, 1, 24)
    time_series = collect(get_time_series_multiple(sys))[1]
    @test TimeSeries.values(time_series.data) == TimeSeries.values(timeseries ./ max_value)

    # Test code path where timeseries is normalized by dividing by a custom value.
    nf = 95.0
    file_metadata.normalization_factor = nf
    sys = PSB.build_system(PSB.MatpowerTestSystems, "matpower_RTS_GMLC_sys")
    add_time_series!(sys, [file_metadata])
    verify_time_series(sys, 1, 1, 24)
    time_series = collect(get_time_series_multiple(sys))[1]
    @test TimeSeries.values(time_series.data) == TimeSeries.values(timeseries ./ nf)
end

@testset "Test single time_series addition" begin
    component_name = "122_HYDRO_1"
    name = "active_power"
    timeseries_file = joinpath(
        RTS_GMLC_DIR,
        "RTS_GMLC_forecasts",
        "gen",
        "Hydro",
        "DAY_AHEAD_hydro.csv",
    )
    resolution = Dates.Hour(1)

    # Test with a filename.
    sys = PSB.build_system(PSB.MatpowerTestSystems, "matpower_RTS_GMLC_sys")
    component = get_component(HydroDispatch, sys, component_name)
    ts = SingleTimeSeries(
        name,
        timeseries_file,
        component,
        resolution;
        normalization_factor = 1.0,
    )
    ta = get_data(ts)
    add_time_series!(sys, component, ts)
    verify_time_series(sys, 1, 1, 24)
    time_series = collect(get_time_series_multiple(sys))[1]
    @test TimeSeries.timestamp(get_data(time_series)) == TimeSeries.timestamp(ta)
    @test TimeSeries.values(get_data(time_series)) == TimeSeries.values(ta)

    # Test with TimeSeries.TimeArray.
    sys = PSB.build_system(PSB.MatpowerTestSystems, "matpower_RTS_GMLC_sys")
    component = get_component(HydroDispatch, sys, component_name)
    ts = SingleTimeSeries(name, ta; normalization_factor = 1.0)
    add_time_series!(sys, component, ts)
    verify_time_series(sys, 1, 1, 24)
    time_series = collect(get_time_series_multiple(sys))[1]
    @test TimeSeries.values(get_data(time_series)) == TimeSeries.values(ta)

    # Test with DataFrames.DataFrame.
    sys = PSB.build_system(PSB.MatpowerTestSystems, "matpower_RTS_GMLC_sys")
    component = get_component(HydroDispatch, sys, component_name)
    df = DataFrames.DataFrame(ta)
    ts = SingleTimeSeries(name, df; normalization_factor = 1.0)
    add_time_series!(sys, component, ts)
    verify_time_series(sys, 1, 1, 24)
    time_series = collect(get_time_series_multiple(sys))[1]
end

@testset "TimeSeriesData data matpower" begin
    sys = PSB.build_system(PSB.MatpowerTestSystems, "matpower_case5_re_sys")
    file_metadata = joinpath(DATA_DIR, "5-Bus", "5bus_ts", "timeseries_pointers_da.json")
    add_time_series!(sys, file_metadata)
    @test verify_time_series(sys, 1, 5, 24)

    # Add the same files.
    # This will fail because the component-name pairs will be duplicated.
    @test_throws ArgumentError add_time_series!(sys, file_metadata)

    file_metadata = joinpath(DATA_DIR, "5-Bus", "5bus_ts", "timeseries_pointers_rt.json")

    # sys = System(PowerFlowFileParser.PowerModelsData(joinpath(MATPOWER_DIR, "case5_re.m")))
    sys = PSB.build_system(PSB.MatpowerTestSystems, "matpower_case5_re_sys")
    add_time_series!(sys, file_metadata)
    @test verify_time_series(sys, 1, 5, 288)
end
