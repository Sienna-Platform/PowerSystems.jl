
"""
The magnitudes a field's displayed value must contribute to the custom output.

`_show_accessor_value` hands back relative quantities, whose `string` spells the unit marker
(`"-0.15 SU"`), while the display spells the same number as `"-0.15 p.u. ... in system base"`.
Asserting on magnitudes keeps the check on the values rather than on one spelling of the units,
and covers `MinMax`-typed fields, whose value is a NamedTuple of them.
"""
_display_magnitudes(x::RelativeQuantity) = [string(ustrip(x))]
_display_magnitudes(x::NamedTuple) =
    collect(Iterators.flatten(_display_magnitudes(v) for v in values(x)))
_display_magnitudes(x) = [string(x)]

function are_type_and_fields_in_output(obj::T) where {T <: Component}
    match = true
    normal = repr(obj)
    io = IOBuffer()
    show(io, "text/plain", obj)
    custom = String(take!(io))
    fields = fieldnames(T)

    # Type must always be present. name should be also, if the type defines it.
    #for text in (normal, custom)
    for text in (custom,)
        if !occursin(string(T), text)
            @error "type name is not in output" string(T) text
            match = false
        end
        if :name in fields
            if !occursin(obj.name, text)
                @error "name is not in output" name text
                match = false
            end
        end
    end

    for (name, type) in zip(fields, fieldtypes(T))
        val = getfield(obj, name)
        if val === nothing || type <: IS.InfrastructureSystemsInternal
            continue
        end

        # The show method resolves each field's displayed value through
        # `_show_accessor_value` (unit-bearing, e.g. "0.55 SU"; for a
        # `MinMax`-typed field, a NamedTuple of unit-bearing values). Reuse it
        # here instead of re-deriving the value from the plain getter, whose
        # `_strip_units` fully strips nested NamedTuple elements and would
        # otherwise disagree with the suffixed value the custom output shows.
        getter_name = Symbol("get_$name")
        display_val = if hasproperty(PowerSystems, getter_name)
            getter_func = getproperty(PowerSystems, getter_name)
            try
                PowerSystems._show_accessor_value(getter_func, obj)
            catch
                val
            end
        else
            val
        end

        actual_type = typeof(display_val)
        if actual_type <: IS.InfrastructureSystemsType
            expected = [string(actual_type)]
        elseif actual_type <: Vector{<:Service}
            expected = [string(actual_type)]
        elseif actual_type <: Vector{<:IS.InfrastructureSystemsType}
            expected = [string(actual_type)]
        elseif display_val isa Unitful.Quantity
            expected = [string(Unitful.ustrip(display_val))]
        else
            expected = _display_magnitudes(display_val)
        end

        for want in expected
            if !occursin(want, custom)
                @error "field's value is not in custom output" name want custom
                match = false
            end
        end
    end

    return match
end

@testset "Test printing of system and components" begin
    sys = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    @test are_type_and_fields_in_output(iterate(get_components(ACBus, sys))[1])
    @test are_type_and_fields_in_output(iterate(get_components(Generator, sys))[1])
    @test are_type_and_fields_in_output(iterate(get_components(ThermalGen, sys))[1])
    @test are_type_and_fields_in_output(iterate(get_components(Branch, sys))[1])
    @test are_type_and_fields_in_output(iterate(get_components(ElectricLoad, sys))[1])

    io = IOBuffer()
    component = first(get_components(ThermalGen, sys))
    show(io, "text/plain", component)
    text = String(take!(io))
    expected_sa = string(has_supplemental_attributes(component))
    expected_ts = string(has_time_series(component))
    @test occursin("has_supplemental_attributes: $expected_sa", text)
    @test occursin("has_time_series: $expected_ts", text)

    # Just make sure nothing blows up.
    for component in iterate_components(sys)
        print(devnull, component)
        print(devnull, MIME"text/plain")
        @test !isempty(summary(component))
    end
    for time_series in get_time_series_multiple(sys)
        show(devnull, time_series)
        show(devnull, MIME"text/plain")
        @test !isempty(summary(time_series))
    end

    @test !isempty(summary(sys))

    @test isnothing(show(IOBuffer(), "text/plain", sys))
    @test isnothing(show(IOBuffer(), "text/html", sys))
    @test isnothing(show_components(IOBuffer(), sys, RenewableNonDispatch))
    @test isnothing(show_components(IOBuffer(), sys, RenewableNonDispatch, [:rating]))
    @test isnothing(
        show_components(
            IOBuffer(),
            sys,
            RenewableNonDispatch,
            Dict("ts" => x -> has_time_series(x)),
        ),
    )
end

@testset "Test show units: attached vs detached component" begin
    # device_base=250, system_base=100, active_power=0.5 (stored in DU) gives
    # three distinguishable numeric values across the unit systems:
    #   DU: 0.5, SU: 1.25, NU: 125.0
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)
    io = IOBuffer()
    show(io, "text/plain", gen)
    attached_out = String(take!(io))
    @test occursin("active_power: 1.25", attached_out)
    @test !occursin("active_power: 125.0", attached_out)
    @test !occursin("active_power: 0.5", attached_out)

    bus = first(get_components(ACBus, sys))
    detached = ThermalStandard(;
        name = "detached", available = true, status = OperationalStates.ONLINE,
        bus = bus,
        active_power = 0.5, reactive_power = 0.1, rating = 1.0,
        active_power_limits = (min = 0.0, max = 1.0),
        reactive_power_limits = (min = -1.0, max = 1.0),
        ramp_limits = nothing,
        operation_cost = ThermalGenerationCost(nothing),
        base_power = 250.0,
    )
    io = IOBuffer()
    @test_logs (:warn, r"not attached to a System") show(io, "text/plain", detached)
    detached_out = String(take!(io))
    @test occursin("active_power: 125.0", detached_out)
    @test !occursin("active_power: 1.25", detached_out)
    @test !occursin("active_power: 0.5", detached_out)
end

@testset "Test detached component: SU getter/setter errors, DU/NU OK" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)
    bus = first(get_components(ACBus, sys))
    detached = ThermalStandard(;
        name = "detached", available = true, status = OperationalStates.ONLINE,
        bus = bus,
        active_power = 0.5, reactive_power = 0.1, rating = 1.0,
        active_power_limits = (min = 0.0, max = 1.0),
        reactive_power_limits = (min = -1.0, max = 1.0),
        ramp_limits = nothing,
        operation_cost = ThermalGenerationCost(nothing),
        base_power = 250.0,
    )

    # Getters: SU errors, DU/NU work.
    @test_throws Exception get_active_power(detached, SU)
    @test get_active_power(detached, DU) ≈ 0.5
    @test get_active_power(detached, NU) ≈ 125.0
    @test_throws Exception get_active_power_unitful(detached, SU)
    @test get_active_power_unitful(detached, DU) isa RelativeQuantity
    @test get_active_power_unitful(detached, NU) isa Unitful.Quantity

    # Setters: SU errors, DU/NU work.
    @test_throws Exception set_active_power!(detached, 1.0 * SU)
    set_active_power!(detached, 0.4 * DU)
    @test get_active_power(detached, DU) ≈ 0.4
    set_active_power!(detached, 100.0 * MW)
    @test get_active_power(detached, NU) ≈ 100.0
end

@testset "Test printing of non-PowerSystems struct" begin
    struct MyComponent <: Component
        name::String
        internal::IS.InfrastructureSystemsInternal
    end

    PSY.get_internal(x::MyComponent) = x.internal
    PSY.get_name(x::MyComponent) = string(x.name)

    component = MyComponent("component1", IS.InfrastructureSystemsInternal())
    @test isnothing(show(IOBuffer(), component))
    @test isnothing(show(IOBuffer(), "text/plain", component))
end

@testset "REPL display of detached components never errors" begin
    line = Line(nothing)
    @test repr(MIME"text/plain"(), line) isa String
    @test repr(MIME"text/plain"(), [line]) isa String
    res = OnlineReserve{ReserveUp}(nothing)
    @test repr(MIME"text/plain"(), res) isa String
end

@testset "display_units_arg resolves for parametric struct types" begin
    @test IS.display_units_arg(get_requirement, OnlineReserve{ReserveUp}) === IS.SU
    @test IS.display_units_arg(get_requirement_unitful, OnlineReserve{ReserveUp}) ===
          IS.SU
end

@testset "rating fields default to device-base display, unlike other converted fields" begin
    # `rating`/`rating_primary`/`rating_secondary`/`rating_tertiary` fields default to
    # DU regardless of System attachment (issue #1128); other `needs_conversion` fields
    # keep the SU default (which falls back to NU when unattached, see the
    # "Test show units" testset below).
    rating_getters = [
        (Line, get_rating),
        (MonitoredLine, get_rating),
        (TwoTerminalVSCLine, get_rating),
        (RenewableDispatch, get_rating),
        (ThermalStandard, get_rating),
        (EnergyReservoirStorage, get_rating),
        # Rating fields on TwoWindingTransformer/ThreeWindingTransformer live entirely on
        # the (sub-object) TransformerCircuit -- neither transformer parent has a scalar
        # `rating` field of its own, so there is no `(T, getter)` pair to add for them here.
        (TransformerCircuit, get_rating),
        (TransformerCircuit, get_rating_b),
        (TransformerCircuit, get_rating_c),
    ]
    for (T, getter) in rating_getters
        @test IS.display_units_arg(getter, T) === IS.DU
        unitful_getter =
            getproperty(PowerSystems, Symbol(string(nameof(getter)), "_unitful"))
        @test IS.display_units_arg(unitful_getter, T) === IS.DU
    end

    non_rating_getters = [
        (ThermalStandard, get_active_power),
        (ThermalStandard, get_reactive_power),
        (Line, get_r),
    ]
    for (T, getter) in non_rating_getters
        @test IS.display_units_arg(getter, T) === IS.SU
    end
end

@testset "IS.unitful_variant resolves the _unitful companion" begin
    @test IS.unitful_variant(get_rating) === get_rating_unitful
    # No `_unitful` companion registered for `get_name`: falls back to the
    # getter itself rather than erroring.
    @test IS.unitful_variant(get_name) === get_name
end

@testset "_show_accessor_value returns unit-tagged values" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)

    # rating: always DU, regardless of System attachment.
    rating_val = PowerSystems._show_accessor_value(get_rating, gen)
    @test rating_val isa RelativeQuantity
    @test rating_val == 1.0 * DU

    # active_power: attached defaults to SU.
    active_power_val = PowerSystems._show_accessor_value(get_active_power, gen)
    @test active_power_val isa RelativeQuantity
    @test active_power_val == 1.25 * SU

    # An explicit `units` override takes precedence over the trait default.
    forced_val = PowerSystems._show_accessor_value(get_active_power, gen; units = MW)
    @test forced_val isa Unitful.Quantity
    @test Unitful.ustrip(forced_val) ≈ 125.0

    # Fields without a units trait (e.g. get_name) ignore `units` entirely.
    @test PowerSystems._show_accessor_value(get_name, gen; units = MW) == "g1"
end

@testset "show_component prints explicit unit suffixes" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)

    # The verbose display spells `SU`/`DU` out; only terse contexts keep the tags.
    attached_out = sprint(show_component, gen)
    @test occursin("active_power: 1.25 p.u. in system base", attached_out)
    @test occursin("rating: 1.0 p.u. in component base", attached_out)
    # Compound fields state their shared base once, after the tuple, rather than
    # repeating it per element.
    @test occursin(
        "active_power_limits: (min = 0.0 p.u., max = 2.5 p.u.) in system base",
        attached_out,
    )

    io = IOBuffer()
    show_component(io, gen; units = MW)
    forced_out = String(take!(io))
    @test occursin("active_power: 125.0 MW", forced_out)
    @test occursin("rating: 250.0 MW", forced_out)

    bus = first(get_components(ACBus, sys))
    detached = ThermalStandard(;
        name = "detached", available = true, status = OperationalStates.ONLINE,
        bus = bus,
        active_power = 0.5, reactive_power = 0.1, rating = 1.0,
        active_power_limits = (min = 0.0, max = 1.0),
        reactive_power_limits = (min = -1.0, max = 1.0),
        ramp_limits = nothing,
        operation_cost = ThermalGenerationCost(nothing),
        base_power = 250.0,
    )
    detached_out = sprint(show_component, detached)
    @test occursin("active_power: 125.0 MW", detached_out) # SU fails, falls back to NU
    # Reactive power reads in MVAr and the apparent-power `rating` in MVA, not MW.
    @test occursin("reactive_power: 25.0 MVAr", detached_out)
    @test occursin("rating: 1.0 p.u. in component base", detached_out) # DU regardless of attachment
    @test occursin("base_power: 250.0 MVA", detached_out)

    # An explicit override that fails (SU on an unattached component) errors
    # rather than silently falling back to NU/DU.
    @test_throws Exception show_component(devnull, detached; units = SU)
end

@testset "show_components preserves caller column order and honors units kwarg" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)

    # Column order must reflect the caller's Vector, not alphabetical order
    # (which would put active_power before reactive_power/rating).
    io = IOBuffer()
    show_components(io, sys, ThermalStandard, [:reactive_power, :rating, :active_power])
    text = String(take!(io))
    reactive_idx = first(findfirst("reactive_power", text))
    rating_idx = first(findfirst("rating", text))
    active_idx = first(findlast("active_power", text))
    @test reactive_idx < rating_idx < active_idx

    io2 = IOBuffer()
    show_components(io2, sys, ThermalStandard, [:rating, :active_power]; units = MW)
    text2 = String(take!(io2))
    @test occursin("250.0 MW", text2)
    @test occursin("125.0 MW", text2)

    # Dict-form additional_columns are unaffected by the units kwarg machinery.
    io3 = IOBuffer()
    show_components(
        io3,
        sys,
        ThermalStandard,
        Dict("doubled" => x -> 2 * get_rating(x, DU)),
    )
    text3 = String(take!(io3))
    @test occursin("2.0", text3)
end

@testset "show_components accepts per-column units" begin
    sys, gen = _sys_with_thermal(; system_base = 100.0, device_base = 250.0)

    io = IOBuffer()
    show_components(
        io,
        sys,
        ThermalStandard,
        [:active_power, :rating];
        units = Dict(:active_power => MW, :rating => DU),
    )
    text = String(take!(io))
    @test occursin("125.0 MW", text)
    @test occursin("1.0 DU", text)

    # A column absent from the mapping keeps its own `display_units_arg` default
    # (SU for active_power) rather than inheriting a neighbour's unit.
    io2 = IOBuffer()
    show_components(io2, sys, ThermalStandard, [:active_power, :rating];
        units = Dict(:rating => MW))
    text2 = String(take!(io2))
    @test occursin("1.25 SU", text2)
    @test occursin("250.0 MW", text2)

    # NamedTuple mappings work the same way.
    io3 = IOBuffer()
    show_components(io3, sys, ThermalStandard, [:active_power, :rating];
        units = (active_power = DU, rating = MW))
    text3 = String(take!(io3))
    @test occursin("0.5 DU", text3)
    @test occursin("250.0 MW", text3)
end

@testset "dynamic models display in component base" begin
    machine = BaseMachine(nothing)
    machine_out = sprint(show, MIME"text/plain"(), machine)
    # Field-by-field, not the default single-line struct dump.
    @test occursin("BaseMachine:", machine_out)
    @test occursin("\n   R: ", machine_out)
    @test occursin("p.u. on the parent device's base power", machine_out)

    dyn = DynamicGenerator(
        "dyn", 1.0, BaseMachine(nothing), FiveMassShaft(nothing),
        AVRFixed(nothing), TGFixed(nothing), PSSFixed(nothing),
    )
    dyn_out = sprint(show_component, dyn)
    @test occursin("in p.u. on the component base of 100.0 MVA", dyn_out)

    # Static components get no such footer: their fields carry their own units.
    _, gen = _sys_with_thermal()
    @test !occursin("p.u. on the component base", sprint(show_component, gen))
end
