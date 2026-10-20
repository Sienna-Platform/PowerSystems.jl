function _system_with_switch()
    sys = PSB.build_system(PSITestSystems, "c_sys5_uc"; add_forecasts = true)
    arc = get_arc(first(get_components(Line, sys)))
    switch = DiscreteControlledACBranch(nothing)
    switch.name = "sw1"
    switch.arc = arc
    switch.x = 0.0001
    add_component!(sys, switch)
    return sys, switch
end

@testset "SwitchingSchedule construction and accessors" begin
    sched = SwitchingSchedule(; status_schedule = "tie_plan")
    @test get_status_schedule(sched) == "tie_plan"
    @test isnothing(get_identifier(sched))
    @test supports_time_series(sched)
    @test !(SwitchingSchedule <: Contingency)
    tagged = SwitchingSchedule(; status_schedule = "tie_plan", identifier = "plan_7")
    @test get_identifier(tagged) == "plan_7"
end

@testset "SwitchingSchedule attaches only to switches" begin
    sys, switch = _system_with_switch()
    sched = SwitchingSchedule(; status_schedule = "tie_plan")
    add_supplemental_attribute!(sys, switch, sched)
    @test only(get_supplemental_attributes(SwitchingSchedule, switch)) === sched
    line = first(get_components(Line, sys))
    @test_throws ArgumentError add_supplemental_attribute!(
        sys,
        line,
        SwitchingSchedule(; status_schedule = "bad"),
    )
end

@testset "SwitchingSchedule time series and round trip" begin
    sys, switch = _system_with_switch()
    sched = SwitchingSchedule(; status_schedule = "tie_plan", identifier = "plan_7")
    add_supplemental_attribute!(sys, switch, sched)
    dates = collect(
        Dates.DateTime("2024-01-01T00:00:00"):Dates.Hour(1):Dates.DateTime(
            "2024-01-01T23:00:00",
        ),
    )
    values = Float64[mod(h, 2) for h in 0:23]
    add_time_series!(
        sys,
        sched,
        SingleTimeSeries(; name = "tie_plan", data = TimeSeries.TimeArray(dates, values)),
    )
    @test TimeSeries.values(get_time_series_array(SingleTimeSeries, sched, "tie_plan")) ==
          values

    sys2 = roundtrip_system(sys)
    sched2 = only(get_supplemental_attributes(SwitchingSchedule, sys2))
    @test get_status_schedule(sched2) == "tie_plan"
    @test get_identifier(sched2) == "plan_7"
    @test only(get_associated_components(sys2, sched2)) isa DiscreteControlledACBranch
    @test TimeSeries.values(get_time_series_array(SingleTimeSeries, sched2, "tie_plan")) ==
          values
end
