"""
    mutable struct RoundRotorExponential <: Machine
        base_machine::RoundRotorMachine
        saturation_coeffs::Tuple{Float64, Float64}

4-states round-rotor synchronous machine with exponential saturation:
IEEE Std 1110 §5.3.2 (Model 2.2). GENROE model in PSSE and PSLF.

# Arguments
$(TYPEDFIELDS)
"""
mutable struct RoundRotorExponential <: Machine
    "Round Rotor machine parameters"
    base_machine::RoundRotorMachine
    "Derived saturation coefficients for the exponential saturation model, computed from the `Se` input"
    saturation_coeffs::Tuple{Float64, Float64}
end

IS.@forward((RoundRotorExponential, :base_machine), RoundRotorMachine)

function RoundRotorExponential(
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
    saturation_coeffs = get_exponential_saturation(Se)
    return RoundRotorExponential(
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

function RoundRotorExponential(;
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
    return RoundRotorExponential(
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

function RoundRotorExponential(::Nothing)
    return RoundRotorExponential(;
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

get_base_machine(value::RoundRotorExponential) = value.base_machine
get_saturation_coeffs(value::RoundRotorExponential) = value.saturation_coeffs
set_base_machine!(value::RoundRotorExponential, val::RoundRotorMachine) =
    value.base_machine = val
set_saturation_coeffs!(value::RoundRotorExponential, val::Tuple{Float64, Float64}) =
    value.saturation_coeffs = val

function IS.deserialize_struct(::Type{RoundRotorExponential}, data::Dict)
    vals = IS.deserialize_to_dict(RoundRotorExponential, data)
    return RoundRotorExponential(vals[:base_machine], vals[:saturation_coeffs])
end
