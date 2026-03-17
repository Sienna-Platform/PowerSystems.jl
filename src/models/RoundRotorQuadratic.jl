"""
    mutable struct RoundRotorQuadratic <: Machine
        base_machine::RoundRotorMachine
        saturation_coeffs::Tuple{Float64, Float64}

4-states round-rotor synchronous machine with quadratic saturation:
IEEE Std 1110 §5.3.2 (Model 2.2). GENROU model in PSSE and PSLF.

# Arguments
$(TYPEDFIELDS)
"""
mutable struct RoundRotorQuadratic <: Machine
    "Round Rotor machine parameters"
    base_machine::RoundRotorMachine
    "Derived saturation coefficients for the quadratic saturation model, computed from the `Se` input"
    saturation_coeffs::Tuple{Float64, Float64}
end
IS.@forward((RoundRotorQuadratic, :base_machine), RoundRotorMachine)

function RoundRotorQuadratic(
    R::Float64,
    Td0_p::Float64,
    Td0_pp::Float64,
    Tq0_p::Float64,
    Tq0_pp::Float64,
    Xd::Float64,
    Xq::Float64,
    Xd_p::Float64,
    Xq_p::Float64,
    Xd_pp::Float64,
    Xl::Float64,
    Se::Tuple{Float64, Float64},
)
    saturation_coeffs = get_quadratic_saturation(Se)
    return RoundRotorQuadratic(
        RoundRotorMachine(
            R,
            Td0_p,
            Td0_pp,
            Tq0_p,
            Tq0_pp,
            Xd,
            Xq,
            Xd_p,
            Xq_p,
            Xd_pp,
            Xl,
            Se,
        ),
        saturation_coeffs,
    )
end

function RoundRotorQuadratic(;
    R,
    Td0_p,
    Td0_pp,
    Tq0_p,
    Tq0_pp,
    Xd,
    Xq,
    Xd_p,
    Xq_p,
    Xd_pp,
    Xl,
    Se,
)
    return RoundRotorQuadratic(
        R,
        Td0_p,
        Td0_pp,
        Tq0_p,
        Tq0_pp,
        Xd,
        Xq,
        Xd_p,
        Xq_p,
        Xd_pp,
        Xl,
        Se,
    )
end

function RoundRotorQuadratic(::Nothing)
    return RoundRotorQuadratic(;
        R = 0.0,
        Td0_p = 0.0,
        Td0_pp = 0.0,
        Tq0_p = 0.0,
        Tq0_pp = 0.0,
        Xd = 0.0,
        Xq = 0.0,
        Xd_p = 0.0,
        Xq_p = 0.0,
        Xd_pp = 0.0,
        Xl = 0.0,
        Se = (0.0, 0.0),
    )
end

get_base_machine(value::RoundRotorQuadratic) = value.base_machine
get_saturation_coeffs(value::RoundRotorQuadratic) = value.saturation_coeffs
set_base_machine!(value::RoundRotorQuadratic, val::RoundRotorMachine) =
    value.base_machine = val
set_saturation_coeffs!(value::RoundRotorQuadratic, val::Tuple{Float64, Float64}) =
    value.saturation_coeffs = val

function IS.deserialize_struct(::Type{RoundRotorQuadratic}, data::Dict)
    vals = IS.deserialize_to_dict(RoundRotorQuadratic, data)
    return RoundRotorQuadratic(vals[:base_machine], vals[:saturation_coeffs])
end
