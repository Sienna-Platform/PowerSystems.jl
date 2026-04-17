
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

        # The show method uses getters, which may return unit-bearing values
        # (e.g. "0.55 SU"). Call the getter (if any) for the displayed value
        # and extract its numeric part for the occursin check.
        getter_name = Symbol("get_$name")
        display_val = if hasproperty(PowerSystems, getter_name)
            try
                getproperty(PowerSystems, getter_name)(obj)
            catch
                val
            end
        else
            val
        end

        actual_type = typeof(display_val)
        if actual_type <: IS.InfrastructureSystemsType
            expected = string(actual_type)
        elseif actual_type <: Vector{<:Service}
            expected = string(actual_type)
        elseif actual_type <: Vector{<:IS.InfrastructureSystemsType}
            expected = string(actual_type)
        elseif display_val isa Unitful.Quantity
            expected = string(Unitful.ustrip(display_val))
        elseif display_val isa RelativeQuantity
            expected = string(ustrip(display_val))
        else
            expected = string(display_val)
        end

        if !occursin(expected, custom)
            @error "field's value is not in custom output" name expected custom
            match = false
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
