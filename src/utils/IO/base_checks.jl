function orderedlimits(
    limits::Union{NamedTuple{(:min, :max), Tuple{Float64, Float64}}, Nothing},
    limitsname::String,
)
    if isa(limits, Nothing)
        @info "'$limitsname' limits defined as nothing"
    else
        if limits.max < limits.min
            throw(DataFormatError("$limitsname limits not in ascending order"))
        end
    end

    return limits
end
