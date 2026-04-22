import UUIDs

"""Recursively validates that the object and fields have UUIDs."""
function validate_uuids(obj::T) where {T}
    if !(obj isa Component)
        return true
    end

    result = true
    if !(IS.get_uuid(obj) isa Base.UUID)
        result = false
        @error "object does not have a UUID" obj
    end

    for fieldname in fieldnames(T)
        val = getfield(obj, fieldname)
        if !validate_uuids(val)
            result = false
        end
    end

    return result
end

function validate_uuids(obj::T) where {T <: AbstractArray}
    result = true
    for elem in obj
        if !validate_uuids(elem)
            result = false
        end
    end

    return result
end

function validate_uuids(obj::T) where {T <: AbstractDict}
    result = true
    for elem in values(obj)
        if !validate_uuids(elem)
            result = false
        end
    end
    return result
end

# TODO: re-enable once PowerSystemCaseBuilder no longer relies on PSY parsers
# (PSB.build_system uses PSY.PowerSystemTableData internally for test_RTS_GMLC_sys).
# @testset "Test internal values" begin
#     sys_rts = PSB.build_system(PSITestSystems, "test_RTS_GMLC_sys")
#     @test validate_uuids(sys_rts)
# end
