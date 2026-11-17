function get_GenericDER_states(Qref_Flag::Int)
    if Qref_Flag == 1
        return [:x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9], 9
    elseif Qref_Flag == 2 || Qref_Flag == 3
        return [:x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9], 8
    else
        error("Unsupported value of Qref_Flag")
    end
end

function get_AggregateDistributedGenerationA_states(Freq_Flag::Bool)
    if Freq_Flag
        return [:Vmeas, :Pmeas, :Q_V, :Iq, :Mult, :Fmeas, :Power_PI, :dPord, :Pord, :Ip], 10
    else
        return [:Vmeas, :Pmeas, :Q_V, :Iq, :Mult, :Fmeas, :Ip], 7
    end
end

function calculate_IM_torque_params(A::Float64, B::Float64)
    C = 1.0 - A - B
    if A < 0.0 || B < 0.0 || C < 0.0
        error(
            "Unsupported values of A = $(A), B = $(B) or C = $(C). A, B and C must be positive and add up to 1.0",
        )
    end
    return C
end
