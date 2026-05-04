"""
    mutable struct SalientPoleQuadratic <: Machine
        base_machine::SalientPoleMachine
        saturation_coeffs::Tuple{Float64, Float64}

3-states salient-pole synchronous machine with quadratic saturation:
IEEE Std 1110 §5.3.2 (Model 2.1). GENSAL in PSSE and PSLF.

# Arguments
$(TYPEDFIELDS)
"""
mutable struct SalientPoleQuadratic <: Machine
    "Salient Pole machine parameters"
    base_machine::SalientPoleMachine
    "Derived saturation coefficients for the quadratic saturation model, computed from the `Se` input"
    saturation_coeffs::Tuple{Float64, Float64}
end
IS.@forward((SalientPoleQuadratic, :base_machine), SalientPoleMachine)

function SalientPoleQuadratic(
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
    saturation_coeffs = get_quadratic_saturation(Se)
    return SalientPoleQuadratic(
        SalientPoleMachine(R, Td0_p, Td0_pp, Tq0_pp, Xd, Xq, Xd_p, Xd_pp, Xl, Se),
        saturation_coeffs,
    )
end

function SalientPoleQuadratic(; R, Td0_p, Td0_pp, Tq0_pp, Xd, Xq, Xd_p, Xd_pp, Xl, Se)
    return SalientPoleQuadratic(R, Td0_p, Td0_pp, Tq0_pp, Xd, Xq, Xd_p, Xd_pp, Xl, Se)
end

function SalientPoleQuadratic(::Nothing)
    return SalientPoleQuadratic(;
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

get_base_machine(value::SalientPoleQuadratic) = value.base_machine
get_saturation_coeffs(value::SalientPoleQuadratic) = value.saturation_coeffs
set_base_machine!(value::SalientPoleQuadratic, val::SalientPoleMachine) =
    value.base_machine = val
set_saturation_coeffs!(value::SalientPoleQuadratic, val::Tuple{Float64, Float64}) =
    value.saturation_coeffs = val

function IS.deserialize_struct(::Type{SalientPoleQuadratic}, data::Dict)
    vals = IS.deserialize_to_dict(SalientPoleQuadratic, data)
    return SalientPoleQuadratic(vals[:base_machine], vals[:saturation_coeffs])
end
