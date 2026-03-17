"""
    mutable struct SalientPoleExponential <: Machine
        base_machine::SalientPoleMachine
        saturation_coeffs::Tuple{Float64, Float64}

3-states salient-pole synchronous machine with exponential saturation:
IEEE Std 1110 §5.3.2 (Model 2.1). GENSAE in PSSE and PSLF.

# Arguments
$(TYPEDFIELDS)
"""
mutable struct SalientPoleExponential <: Machine
    "Salient Pole machine parameters"
    base_machine::SalientPoleMachine
    "Derived saturation coefficients for the exponential saturation model, computed from the `Se` input"
    saturation_coeffs::Tuple{Float64, Float64}
end
IS.@forward((SalientPoleExponential, :base_machine), SalientPoleMachine)

function SalientPoleExponential(
    R::Float64,
    Td0_p::Float64,
    Td0_pp::Float64,
    Tq0_pp::Float64,
    Xd::Float64,
    Xq::Float64,
    Xd_p::Float64,
    Xd_pp::Float64,
    Xl::Float64,
    Se::Tuple{Float64, Float64},
)
    saturation_coeffs = get_exponential_saturation(Se)
    return SalientPoleExponential(
        SalientPoleMachine(R, Td0_p, Td0_pp, Tq0_pp, Xd, Xq, Xd_p, Xd_pp, Xl, Se),
        saturation_coeffs,
    )
end

function SalientPoleExponential(; R, Td0_p, Td0_pp, Tq0_pp, Xd, Xq, Xd_p, Xd_pp, Xl, Se)
    return SalientPoleExponential(R, Td0_p, Td0_pp, Tq0_pp, Xd, Xq, Xd_p, Xd_pp, Xl, Se)
end

function SalientPoleExponential(::Nothing)
    return SalientPoleExponential(;
        R = 0.0,
        Td0_p = 0.0,
        Td0_pp = 0.0,
        Tq0_pp = 0.0,
        Xd = 0.0,
        Xq = 0.0,
        Xd_p = 0.0,
        Xd_pp = 0.0,
        Xl = 0.0,
        Se = (0.0, 0.0),
    )
end

get_base_machine(value::SalientPoleExponential) = value.base_machine
get_saturation_coeffs(value::SalientPoleExponential) = value.saturation_coeffs

set_base_machine!(value::SalientPoleExponential, val::SalientPoleMachine) =
    value.base_machine = val
set_saturation_coeffs!(value::SalientPoleExponential, val::Tuple{Float64, Float64}) =
    value.saturation_coeffs = val

function IS.deserialize_struct(::Type{SalientPoleExponential}, data::Dict)
    vals = IS.deserialize_to_dict(SalientPoleExponential, data)
    return SalientPoleExponential(vals[:base_machine], vals[:saturation_coeffs])
end
