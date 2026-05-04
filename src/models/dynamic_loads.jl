"""
Return the state names and count for a `GenericDER` model based on `Qref_Flag`.

# Arguments
- `Qref_Flag::Int`: Reactive power reference flag (1, 2, or 3).
"""
function get_GenericDER_states(Qref_Flag::Int)
    if Qref_Flag == 1
        return [:x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9], 9
    elseif Qref_Flag == 2 || Qref_Flag == 3
        return [:x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9], 8
    else
        error("Unsupported value of Qref_Flag")
    end
end

"""
Return the state names and count for an `AggregateDistributedGenerationA` model based on `Freq_Flag`.

# Arguments
- `Freq_Flag::Int`: Frequency flag (0 or 1).
"""
function get_AggregateDistributedGenerationA_states(Freq_Flag::Int)
    if Freq_Flag == 0
        return [:Vmeas, :Pmeas, :Q_V, :Iq, :Mult, :Fmeas, :Ip], 7
    elseif Freq_Flag == 1
        return [:Vmeas, :Pmeas, :Q_V, :Iq, :Mult, :Fmeas, :Power_PI, :dPord, :Pord, :Ip], 10
    else
        error("Unsupported value of Freq_Flag")
    end
end

"""
Calculate the torque constant `C` for an induction motor model from load-torque coefficients.

Throws an error if any of A, B, or C is negative (coefficients must be non-negative and sum to 1).

# Arguments
- `A::Float64`: Load torque coefficient for the constant component.
- `B::Float64`: Load torque coefficient for the speed-proportional component.
"""
function calculate_IM_torque_params(A::Float64, B::Float64)
    C = 1.0 - A - B
    if A < 0.0 || B < 0.0 || C < 0.0
        error(
            "Unsupported values of A = $(A), B = $(B) or C = $(C). A, B and C must be positive and add up to 1.0",
        )
    end
    return C
end
