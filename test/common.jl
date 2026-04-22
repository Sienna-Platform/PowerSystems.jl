import InfrastructureSystems
mutable struct TestDevice <: Device
    name::String
end

mutable struct TestRenDevice <: RenewableGen
    name::String
end

mutable struct TestInjector <: StaticInjection
    name::String
end

struct NonexistentComponent <: StaticInjection end

"""Return the first component of type component_type that matches the name of other."""
function get_component_by_name(sys::System, component_type, other::Component)
    for component in get_components(component_type, sys)
        if get_name(component) == get_name(other)
            return component
        end
    end

    error("Did not find component $component")
end

"""Return the Branch in the system that matches another by case-insensitive arc
names."""
function get_branch(sys::System, other::Branch)
    for branch in get_components(Branch, sys)
        if lowercase(other.arc.from.name) == lowercase(branch.arc.from.name) &&
           lowercase(other.arc.to.name) == lowercase(branch.arc.to.name)
            return branch
        end
    end

    error("Did not find branch with buses $(other.arc.from.name) ", "$(other.arc.to.name)")
end

function create_system_with_dynamic_inverter()
    nodes_OMIB = [
        ACBus(
            1, #number
            "Bus 1", #Name
            true, #available
            "REF", #ACBusType (REF, PV, PQ)
            0, #Angle in radians
            1.06, #Voltage in pu
            (min = 0.94, max = 1.06), #Voltage limits in pu
            69,
            nothing,
            nothing,
        ), #Base voltage in kV
        ACBus(
            2,
            "Bus 2",
            true,
            "PV",
            0,
            1.045,
            (min = 0.94, max = 1.06),
            69,
            nothing,
            nothing,
        ),
    ]

    battery = EnergyReservoirStorage(;
        name = "Battery",
        prime_mover_type = PrimeMovers.BA,
        storage_technology_type = StorageTech.OTHER_CHEM,
        available = true,
        bus = nodes_OMIB[2],
        initial_energy = 5.0,
        state_of_charge_limits = (min = 5.0, max = 100.0),
        rating = 0.0275, #Value in per_unit of the system
        active_power = 0.01375,
        input_active_power_limits = (min = 0.0, max = 50.0),
        output_active_power_limits = (min = 0.0, max = 50.0),
        reactive_power = 0.0,
        reactive_power_limits = (min = -50.0, max = 50.0),
        efficiency = (in = 0.80, out = 0.90),
        base_power = 100.0,
    )
    converter = AverageConverter(
        138.0, #Rated Voltage
        100.0,
    ) #Rated MVA

    branch_OMIB = [
        Line(
            "Line1", #name
            true, #available
            0.0, #active power flow initial condition (from-to)
            0.0, #reactive power flow initial condition (from-to)
            Arc(; from = nodes_OMIB[1], to = nodes_OMIB[2]), #Connection between buses
            0.01, #resistance in pu
            0.05, #reactance in pu
            (from = 0.0, to = 0.0), #susceptance in pu
            18.046, #rate in MW
            1.04,
        ),
    ]  #angle limits (-min and max)

    dc_source = FixedDCSource(1500.0) #Not in the original data, guessed.

    filt = LCLFilter(
        0.08, #Series inductance lf in pu
        0.003, #Series resitance rf in pu
        0.074, #Shunt capacitance cf in pu
        0.2, #Series reactance rg to grid connection (#Step up transformer or similar)
        0.01,
    ) #Series resistance lg to grid connection (#Step up transformer or similar)

    pll = KauraPLL(
        500.0, #ω_lp: Cut-off frequency for LowPass filter of PLL filter.
        0.084, #k_p: PLL proportional gain
        4.69,
    ) #k_i: PLL integral gain

    virtual_H = VirtualInertia(
        2.0, #Ta:: VSM inertia constant
        400.0, #kd:: VSM damping coefficient
        20.0, #kω:: Frequency droop gain in pu
        2 * pi * 50.0,
    ) #ωb:: Rated angular frequency

    Q_control = ReactivePowerDroop(
        0.2, #kq:: Reactive power droop gain in pu
        1000.0,
    ) #ωf:: Reactive power cut-off low pass filter frequency

    outer_control = OuterControl(virtual_H, Q_control)

    vsc = VoltageModeControl(
        0.59, #kpv:: Voltage controller proportional gain
        736.0, #kiv:: Voltage controller integral gain
        0.0, #kffv:: Binary variable enabling the voltage feed-forward in output of current controllers
        0.0, #rv:: Virtual resistance in pu
        0.2, #lv: Virtual inductance in pu
        1.27, #kpc:: Current controller proportional gain
        14.3, #kiv:: Current controller integral gain
        0.0, #kffi:: Binary variable enabling the current feed-forward in output of current controllers
        50.0, #ωad:: Active damping low pass filter cut-off frequency
        0.2,
    ) #kad:: Active damping gain

    sys = System(100.0)
    for bus in nodes_OMIB
        add_component!(sys, bus)
    end
    for lines in branch_OMIB
        add_component!(sys, lines)
    end
    add_component!(sys, battery)

    test_inverter = DynamicInverter(
        get_name(battery),
        1.0, #ω_ref
        converter, #Converter
        outer_control, #OuterControl
        vsc, #Voltage Source Controller
        dc_source, #DC Source
        pll, #Frequency Estimator
        filt,
    ) #Output Filter

    add_component!(sys, test_inverter, battery)

    return sys
end

"""
Create a system with supplemental attributes with the criteria below.

- Two GeographicInfo instances each assigned to multiple components.
- Two ThermalStandards each with two ForcedOutage instances and two PlannedOutage instances.
- Each outage has time series.
"""
function create_system_with_outages()
    sys = PSB.build_system(
        PSITestSystems,
        "c_sys5_uc";
        add_forecasts = true,
    )
    gens = collect(get_components(ThermalStandard, sys))
    gen1 = gens[1]
    gen2 = gens[2]
    geo1 = GeographicInfo(; geo_json = Dict("type" => "Point", "coordinates" => [1.0, 2.0]))
    geo2 = GeographicInfo(; geo_json = Dict("type" => "Point", "coordinates" => [3.0, 4.0]))
    begin_time_series_update(sys) do
        begin_supplemental_attributes_update(sys) do
            add_supplemental_attribute!(sys, gen1, geo1)
            add_supplemental_attribute!(sys, gen1.bus, geo1)
            add_supplemental_attribute!(sys, gen2, geo2)
            add_supplemental_attribute!(sys, gen2.bus, geo2)
            initial_time = Dates.DateTime("2020-01-01T00:00:00")
            end_time = Dates.DateTime("2020-01-01T23:00:00")
            dates = collect(initial_time:Dates.Hour(1):end_time)
            fo1 = GeometricDistributionForcedOutage(;
                mean_time_to_recovery = 1.0,
                outage_transition_probability = 0.5,
            )
            fo2 = GeometricDistributionForcedOutage(;
                mean_time_to_recovery = 2.0,
                outage_transition_probability = 0.5,
            )
            po1 = PlannedOutage(; outage_schedule = "1")
            po2 = PlannedOutage(; outage_schedule = "2")
            add_supplemental_attribute!(sys, gen1, fo1)
            add_supplemental_attribute!(sys, gen1, po1)
            add_supplemental_attribute!(sys, gen2, fo2)
            add_supplemental_attribute!(sys, gen2, po2)
            for (i, outage) in enumerate((fo1, fo2, po1, po2))
                data = collect(i:(i + 23))
                ta = TimeSeries.TimeArray(dates, data, ["1"])
                name = "ts_$(i)"
                ts = SingleTimeSeries(; name = name, data = ta)
                add_time_series!(sys, outage, ts)
            end
        end
    end

    return sys
end

# NOTE: This helper builds `test_RTS_GMLC_sys` which depends on PSY.PowerSystemTableData
# (removed in PSY 6). All callers are currently disabled until PSB no longer requires PSY parsers.
function create_system_with_subsystems()
    sys = PSB.build_system(
        PSITestSystems,
        "test_RTS_GMLC_sys";
        add_forecasts = true,
        time_series_read_only = false,
    )
    add_subsystem!(sys, "subsystem_1")
    for component in iterate_components(sys)
        add_component_to_subsystem!(sys, "subsystem_1", component)
    end

    # TODO: Replace with multiple valid subsystems
    return sys
end

function test_accessors(component)
    ps_type = typeof(component)

    for (field_name, field_type) in zip(fieldnames(ps_type), fieldtypes(ps_type))
        if field_name === :name
            func = getfield(InfrastructureSystems, Symbol("get_" * string(field_name)))
            _func! =
                getfield(InfrastructureSystems, Symbol("set_" * string(field_name) * "!"))
        else
            getter_name = Symbol("get_" * string(field_name))
            if !hasproperty(PowerSystems, getter_name)
                continue
            end
            func = getfield(PowerSystems, getter_name)
            if !hasmethod(func, (ps_type,))
                continue
            end
            setter_name = Symbol("set_" * string(field_name) * "!")
            # In some cases there is a getter but no setter.
            if hasproperty(PowerSystems, setter_name)
                _func! = getfield(PowerSystems, setter_name)
            else
                _func! = nothing
            end
        end

        val = func(component)
        @test val isa field_type
        try
            if typeof(val) == Float64 || typeof(val) == Int
                if !isnan(val)
                    aux = val + 1
                    if _func! !== nothing
                        _func!(component, aux)
                        @test func(component) == aux
                    end
                end
            elseif typeof(val) == String
                aux = val * "1"
                if _func! !== nothing
                    _func!(component, aux)
                    @test func(component) == aux
                end
            elseif typeof(val) == Bool
                aux = !val
                if _func! !== nothing
                    _func!(component, aux)
                    @test func(component) == aux
                end
            else
                _func! !== nothing && _func!(component, val)
            end
        catch MethodError
            continue
        end
    end
end

function validate_serialization(
    sys::System;
    time_series_read_only = false,
    runchecks = nothing,
    assign_new_uuids = false,
)
    if runchecks === nothing
        runchecks = PSY.get_runchecks(sys)
    end
    test_dir = mktempdir()
    orig_dir = pwd()
    cd(test_dir)

    try
        path = joinpath(test_dir, "test_system_serialization.json")
        @info "Serializing to $path"
        sys_ext = get_ext(sys)
        sys_ext["data"] = 5
        ext_test_bus_name = ""
        bus = collect(get_components(PSY.ACBus, sys))[1]
        ext_test_bus_name = PSY.get_name(bus)
        ext = PSY.get_ext(bus)
        ext["test_field"] = 1
        to_json(sys, path; force = true)

        data = open(path, "r") do io
            JSON3.read(io)
        end
        @test data["data_format_version"] == PSY.DATA_FORMAT_VERSION

        sys2 = System(
            path;
            time_series_read_only = time_series_read_only,
            runchecks = runchecks,
            assign_new_uuids = assign_new_uuids,
        )
        isempty(get_bus_numbers(sys2)) && return false
        sys_ext2 = get_ext(sys2)
        sys_ext2["data"] != 5 && return false
        bus = PSY.get_component(PSY.ACBus, sys2, ext_test_bus_name)
        ext = PSY.get_ext(bus)
        ext["test_field"] != 1 && return false
        return sys2, PSY.compare_values(sys, sys2; compare_uuids = !assign_new_uuids)
    finally
        cd(orig_dir)
    end
end
