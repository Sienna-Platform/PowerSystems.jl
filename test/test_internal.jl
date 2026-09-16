import UUIDs

"""Recursively validates that a component and the components it holds have assigned ids."""
validate_ids(::Any) = true

function validate_ids(obj::Component)
    result = true
    if IS.get_id(obj) == IS.UNASSIGNED_ID
        result = false
        @error "component has an unassigned id" obj
    end

    for fieldname in fieldnames(typeof(obj))
        if !validate_ids(getfield(obj, fieldname))
            result = false
        end
    end

    return result
end

function validate_ids(obj::AbstractArray)
    result = true
    for elem in obj
        if !validate_ids(elem)
            result = false
        end
    end

    return result
end

function validate_ids(obj::AbstractDict)
    result = true
    for elem in values(obj)
        if !validate_ids(elem)
            result = false
        end
    end
    return result
end

@testset "Test internal values" begin
    sys_rts = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
    components = collect(get_components(Component, sys_rts))
    @test !isempty(components)
    @test all(validate_ids, components)
end

# Regression: the `Base.convert(::Type{E}, ::AbstractString)` methods are generated from
# `ENUMS`, so the list is stated once. Restating it by hand is what let `ReservoirDataType`
# and `UnitSystem` sit in `ENUMS` with no conversion method.
@testset "Every enum in ENUMS converts from its member name" begin
    for enum in PSY.ENUMS
        for member in instances(enum)
            name = string(member)
            @test convert(enum, name) == member
            # Lookup is case insensitive.
            @test convert(enum, lowercase(name)) == member
        end
        @test_throws ArgumentError convert(enum, "not_a_member_of_$(enum)")
    end
end

@testset "OperationalStates and CommitmentModes reject Bool" begin
    @test_throws ArgumentError PSY.OperationalStates(true)
    @test_throws ArgumentError PSY.OperationalStates(false)
    @test_throws ArgumentError convert(PSY.OperationalStates, true)
    @test_throws ArgumentError convert(PSY.OperationalStates, false)
    @test_throws ArgumentError PSY.CommitmentModes(true)
    @test_throws ArgumentError PSY.CommitmentModes(false)
    @test_throws ArgumentError convert(PSY.CommitmentModes, true)
    @test_throws ArgumentError convert(PSY.CommitmentModes, false)
end
