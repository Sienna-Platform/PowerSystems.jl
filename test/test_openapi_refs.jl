@testset "OpenAPIRefs: setindex!/getindex hit and miss" begin
    refs = PSY.OpenAPIRefs()
    area = Area(;
        name = "area1",
        peak_active_power = 0.0,
        peak_reactive_power = 0.0,
        input_basis = u"CU",
    )
    refs[1] = area
    @test refs[1] === area
    @test PSY.has_ref(refs, 1)
    @test !PSY.has_ref(refs, 2)
    @test_throws ErrorException refs[2]
end

@testset "OpenAPIRefs: duplicate id rejected" begin
    refs = PSY.OpenAPIRefs()
    area1 = Area(;
        name = "a1",
        peak_active_power = 0.0,
        peak_reactive_power = 0.0,
        input_basis = u"CU",
    )
    area2 = Area(;
        name = "a2",
        peak_active_power = 0.0,
        peak_reactive_power = 0.0,
        input_basis = u"CU",
    )
    refs[1] = area1
    @test_throws ErrorException (refs[1] = area2)
    @test refs[1] === area1
end

@testset "OpenAPIRefs: component -> id reverse lookup" begin
    refs = PSY.OpenAPIRefs()
    area = Area(;
        name = "a1",
        peak_active_power = 0.0,
        peak_reactive_power = 0.0,
        input_basis = u"CU",
    )
    other = Area(;
        name = "a2",
        peak_active_power = 0.0,
        peak_reactive_power = 0.0,
        input_basis = u"CU",
    )
    refs[7] = area
    @test PSY.component_id(refs, area) == 7
    @test PSY.has_component_id(refs, area)
    @test !PSY.has_component_id(refs, other)
    @test_throws ErrorException PSY.component_id(refs, other)
end
