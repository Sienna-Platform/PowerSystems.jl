import InfrastructureSystems
import Unitful
# PSY no longer exports `ustrip`; Unitful's generic handles both quantity kinds
# (PSY extends it for `RelativeQuantity`).
using Unitful: ustrip

# Strip unit wrappers so accessor return values can be compared against the
# raw struct field type. Compound values (NamedTuple of units) are unwrapped
# element-wise.
_unwrap_units(x) = x
_unwrap_units(x::RelativeQuantity) = ustrip(x)
_unwrap_units(x::Unitful.Quantity) = Unitful.ustrip(x)
_unwrap_units(x::NamedTuple) = map(_unwrap_units, x)

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

"""Build a minimal `System` + `ThermalStandard` with the requested device base
so unit-conversion tests don't depend on PSB-built fixtures."""
function _sys_with_thermal(; system_base = 100.0, device_base = 250.0)
    sys = System(system_base)
    bus = ACBus(;
        number = 1, name = "b1", available = true,
        bustype = ACBusTypes.REF, angle = 0.0, magnitude = 1.0,
        voltage_limits = (min = 0.9, max = 1.1), base_voltage = 138.0,
    )
    add_component!(sys, bus)
    gen = ThermalStandard(;
        name = "g1", available = true, status = true, bus = bus,
        active_power = 0.5, reactive_power = 0.1, rating = 1.0,
        active_power_limits = (min = 0.0, max = 1.0),
        reactive_power_limits = (min = -1.0, max = 1.0),
        ramp_limits = nothing,
        operation_cost = ThermalGenerationCost(nothing),
        base_power = device_base,
    )
    add_component!(sys, gen)
    return sys, gen
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
    time_series_transaction(sys) do txn
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
                add_time_series!(txn, outage, ts)
            end
        end
    end

    return sys
end

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

        # Unit-aware getters are tagged via `display_units_arg`. For unattached
        # test components, call with `DU` (device base) so the SU conversion
        # path — which needs system attachment — is skipped. Getters tagged `NU`
        # (e.g. `get_base_power`, which is only meaningful in natural units and
        # rejects `DU`/`SU`) are called with their own `NU` tag instead.
        units_arg = IS.display_units_arg(func, ps_type)
        val = if ismissing(units_arg)
            func(component)
        elseif units_arg == NU
            func(component, NU)
        else
            func(component, DU)
        end
        # Getters now wrap values (e.g. `0.5 SU` instead of raw `0.5`), so
        # compare the unwrapped value's type to `field_type`.
        @test _unwrap_units(val) isa field_type
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

"""
Round-trip `sys` through a `to_file`/`from_file` bundle (`format = :json`, default) or archive
(`format = :sienna`) and return the rebuilt system.

The serde itself is tested once, in `test_openapi_file_io.jl`. Use this only where a test needs
a restored system to check that some *component* survives conversion. A document carries
component ids rather than UUIDs and does not carry component `ext`, so neither survives.
`format = :sienna` only ever writes `:component_base`, same as `to_file` itself — passing a
non-default `unit_system` with it throws.
"""
function roundtrip_system(
    sys::System;
    format::Symbol = :json,
    unit_system::Symbol = :component_base,
    kwargs...,
)
    dir = mktempdir()
    if format === :json
        bundle = joinpath(dir, "case")
        to_file(sys, bundle; unit_system = unit_system, force = true)
        return from_file(bundle; kwargs...)
    elseif format === :sienna
        archive = joinpath(dir, "case.sn")
        to_file(sys, archive; format = :sienna, unit_system = unit_system, force = true)
        return from_file(archive; kwargs...)
    else
        error("format = $format is not supported")
    end
end

"""Round-trip a PO/PC struct through JSON, the same shape `JSON.parsefile` would hand to
`PowerCoreOpenAPIModels.document_from_json` — avoids hand-writing nested `oneOf` cost-curve
JSON."""
openapi_raw(po) = JSON.parse(JSON.json(po); dicttype = Dict{String, Any})

"""
Parse a JSON-shaped test document into the `SystemDocument` `from_openapi` takes.

The fixtures build plain `Dict`s because that is the shape a document has on disk and it is
easy to mutate for negative tests; this is the same step `from_file` performs via
`read_document`.
"""
to_test_document(doc::AbstractDict) = PSY.PD.document_from_json(doc)

"""
Errors a malformed document can raise.

Which one fires depends on where the defect is caught: `PowerCoreOpenAPIModels` raises
`DocumentFormatError` for structural problems it can see on its own (an unregistered type name,
an unresolved id, a duplicate id), while PowerSystems `error()`s for semantic ones only it can
judge (a component type with no converter, an unmapped time series type or multiplier).
"""
const DocumentError = Union{ErrorException, PSY.IC.DocumentFormatError}

"""A minimal, internally-consistent OpenAPI document: Area/LoadZone, two buses, an arc, a
thermal generator with a real cost curve, a load, and an online reserve the generator
contributes to. Shared by test_openapi_document.jl and test_openapi_export.jl;
`bus1_bustype = "SLACK"` exercises SLACK surviving the round trip as a distinct enum value,
and `include_fixed_admittance = false` drops the shunt row the export round-trip
predates."""
function make_openapi_test_doc(;
    bus1_bustype = "REF",
    include_fixed_admittance = true,
)
    area_po = PSY.PO.Area(;
        id = 1, name = "area1", peak_active_power = 100.0, peak_reactive_power = 20.0,
        load_response = 0.0, base_power = 100.0, power_units = "NATURAL_UNITS",
    )
    lz_po = PSY.PO.LoadZone(;
        id = 2, name = "lz1", peak_active_power = 100.0, peak_reactive_power = 20.0,
        base_power = 100.0, power_units = "NATURAL_UNITS",
    )
    bus1_po = PSY.PO.ACBus(;
        id = 3, number = 1, name = "bus1", available = true, bustype = bus1_bustype,
        angle = 0.0, magnitude = 1.0,
        voltage_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        base_voltage = 138.0, area = 1, load_zone = 2,
    )
    bus2_po = PSY.PO.ACBus(;
        id = 4, number = 2, name = "bus2", available = true, bustype = "PQ",
        angle = 0.0, magnitude = 1.0,
        voltage_limits = PSY.IC.MinMax(; min = 0.9, max = 1.1),
        base_voltage = 138.0, area = 1, load_zone = 2,
    )
    arc_po = PSY.PO.Arc(; id = 5, from_id = 3, to_id = 4)

    cost_po = PSY.PC.ThermalGenerationCost(;
        fixed = 100.0, shut_down = 50.0, start_up = 200.0,
        variable_operation_cost = PSY.PC.ProductionVariableCostCurve(
            PSY.PC.CostCurve(;
                power_units = "NATURAL_UNITS",
                value_curve = PSY.PC.ValueCurve(
                    PSY.PC.InputOutputCurve(;
                        function_data = PSY.PC.InputOutputCurveFunctionData(
                            PSY.IC.LinearFunctionData(;
                                proportional_term = 10.0, constant_term = 5.0,
                            ),
                        ),
                    ),
                ),
            ),
        ),
    )
    thermal_po = PSY.PO.ThermalStandard(;
        id = 6, name = "gen1", available = true, status = true, bus = 4,
        active_power = 50.0, reactive_power = 10.0, rating = 100.0,
        active_power_limits = PSY.IC.MinMax(; min = 10.0, max = 100.0),
        reactive_power_limits = PSY.IC.MinMax(; min = -50.0, max = 50.0),
        ramp_limits = PSY.IC.UpDown(; up = 20.0, down = 20.0),
        operation_cost = cost_po, base_power = 100.0, power_units = "NATURAL_UNITS",
        time_limits = PSY.IC.UpDown(; up = 2.0, down = 2.0),
        must_run = false, prime_mover_type = "OT", fuel = "NATURAL_GAS",
        time_at_status = 100.0,
    )
    load_po = PSY.PO.PowerLoad(;
        id = 7, name = "load1", available = true, bus = 4,
        active_power = 30.0, reactive_power = 5.0, base_power = 100.0,
        power_units = "NATURAL_UNITS",
        max_active_power = 50.0, max_reactive_power = 10.0, conformity = "CONFORMING",
    )
    reserve_po = PSY.PO.OnlineReserve(;
        id = 8, name = "spin_up", available = true, time_frame = 10.0,
        requirement = 100.0, variable = nothing, sustained_time = 60.0,
        max_output_fraction = 1.0, max_participation_factor = 1.0,
        deployed_fraction = 1.0, reserve_direction = "UP",
    )

    components = Dict{String, Any}(
        "Area" => [openapi_raw(area_po)],
        "LoadZone" => [openapi_raw(lz_po)],
        "ACBus" => [openapi_raw(bus1_po), openapi_raw(bus2_po)],
        "Arc" => [openapi_raw(arc_po)],
        "ThermalStandard" => [openapi_raw(thermal_po)],
        "PowerLoad" => [openapi_raw(load_po)],
        "OnlineReserve" => [openapi_raw(reserve_po)],
    )
    if include_fixed_admittance
        shunt_po = PSY.PO.FixedAdmittance(;
            id = 9, name = "shunt1", available = true, bus = 4,
            admittance_units = "COMPONENT_MVAR",
            Y = PSY.IC.ComplexNumber(; real = 0.0, imag = -50.0),
        )
        components["FixedAdmittance"] = [openapi_raw(shunt_po)]
    end

    # Every field the SystemDocument schema marks required is present, including the empty
    # ones: a real producer always emits all of them, so a fixture that omits some would let
    # a reader regress into tolerating incomplete documents.
    return Dict{String, Any}(
        "components" => components,
        "supplemental_attributes" => [],
        "supplemental_attribute_associations" => [],
        "plant_associations" => [],
        "combined_cycle_associations" => [],
        # Service membership: service_id names the service component (spin_up), entity_id
        # the contributing device (gen1).
        "service_associations" => [
            Dict{String, Any}("service_id" => 8, "entity_id" => 6),
        ],
        "trading_hub_associations" => [],
        "time_series_associations" => [],
        "ext" => Dict{String, Any}(),
        "time_series_storage_file" => nothing,
    )
end

"""Stamp `power_units` to `value` on every raw component row in a JSON-shaped test document
that carries the field (rows of types without a `power_units` member are left alone)."""
function set_all_power_units!(doc::AbstractDict, value::AbstractString)
    for rows in values(doc["components"])
        for row in rows
            haskey(row, "power_units") && (row["power_units"] = value)
        end
    end
    return doc
end

"""
A small System exercising every member of a serialized bundle: topology, an injector, a
supplemental attribute, and (unless `with_time_series = false`) a time series so the HDF5
sidecar is written.

Shared by test_openapi_file_io.jl.
"""
function _file_io_fixture(; with_time_series = true)
    sys = System(100.0)
    PSY.set_name!(sys, "bundle-fixture")
    PSY.set_description!(sys, "round-trip check")

    area = Area(nothing)
    area.name = "a1"
    add_component!(sys, area)
    zone = LoadZone(nothing)
    zone.name = "z1"
    add_component!(sys, zone)

    bus = ACBus(nothing)
    bus.name = "b1"
    bus.number = 1
    bus.bustype = ACBusTypes.REF
    bus.base_voltage = 230.0
    bus.area = area
    bus.load_zone = zone
    add_component!(sys, bus)

    gen = ThermalStandard(nothing)
    set_bus!(gen, bus)
    gen.name = "g1"
    add_component!(sys, gen)

    add_supplemental_attribute!(
        sys,
        gen,
        EmissionsData(;
            name = "g1_CO2", pollutant = PollutantType.CO2,
            emission_rate = IncrementalCurve(;
                function_data = LinearFunctionData(0.0, 1.5), initial_input = 0.0,
            ),
            basis = EmissionBasis.FUEL_INPUT, start_up_adder = 0.0,
            mass_unit = MassUnit.LB, energy_unit = EnergyUnit.MMBTU, gwp = 1.0,
            available = true,
        ),
    )

    if with_time_series
        add_time_series!(
            sys,
            gen,
            SingleTimeSeries(
                "max_active_power",
                TimeSeries.TimeArray(
                    collect(
                        Dates.DateTime(2024, 1, 1):Dates.Hour(1):Dates.DateTime(
                            2024, 1, 1, 5,
                        ),
                    ),
                    collect(0.1:0.1:0.6),
                ),
            ),
        )
    end
    return sys
end

"""Fresh 100 MVA system with two attached buses (`b1` REF, `b2` PV) and a `TradingHub`
named `western_hub` over both. Returns `(sys, b1, b2, hub)`."""
function _market_hub_fixture()
    sys = System(100.0)
    b1 = ACBus(; number = 1, name = "b1", available = true, bustype = ACBusTypes.REF,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 230.0)
    b2 = ACBus(; number = 2, name = "b2", available = true, bustype = ACBusTypes.PV,
        angle = 0.0, magnitude = 1.0, voltage_limits = (min = 0.9, max = 1.1),
        base_voltage = 230.0)
    add_component!(sys, b1)
    add_component!(sys, b2)
    hub = TradingHub(; name = "western_hub", buses = [b1, b2])
    add_component!(sys, hub)
    return (sys, b1, b2, hub)
end
