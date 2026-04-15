abstract type DynamicGeneratorComponent <: DynamicComponent end

"""
Supertype for all Automatic Voltage Regulator (AVR) models for
[`DynamicGenerator`](@ref) components.

Concrete subtypes include [`AVRFixed`](@ref), [`AVRSimple`](@ref), [`AVRTypeI`](@ref),
[`AVRTypeII`](@ref), [`IEEET1`](@ref), [`ESDC1A`](@ref), [`ESAC1A`](@ref),
[`SEXS`](@ref), [`SCRX`](@ref), and others.
"""
abstract type AVR <: DynamicGeneratorComponent end

"""
Supertype for all synchronous machine models for [`DynamicGenerator`](@ref) components.

Concrete subtypes include [`BaseMachine`](@ref), [`OneDOneQMachine`](@ref),
[`SauerPaiMachine`](@ref), [`MarconatoMachine`](@ref), [`RoundRotorMachine`](@ref),
[`SalientPoleMachine`](@ref), [`AndersonFouadMachine`](@ref), [`FullMachine`](@ref),
and others.
"""
abstract type Machine <: DynamicGeneratorComponent end

"""
Supertype for all Power System Stabilizer (PSS) models for
[`DynamicGenerator`](@ref) components.

Concrete subtypes include [`PSSFixed`](@ref), [`PSSSimple`](@ref), [`IEEEST`](@ref),
[`PSS2A`](@ref), [`PSS2B`](@ref), [`PSS2C`](@ref), [`STAB1`](@ref), and [`CSVGN1`](@ref).
"""
abstract type PSS <: DynamicGeneratorComponent end

"""
Supertype for all shaft and rotor models for [`DynamicGenerator`](@ref) components.

Concrete subtypes include [`SingleMass`](@ref) and [`FiveMassShaft`](@ref).
"""
abstract type Shaft <: DynamicGeneratorComponent end

"""
Supertype for all turbine governor models for [`DynamicGenerator`](@ref) components.

Concrete subtypes include [`TGFixed`](@ref), [`TGTypeI`](@ref), [`TGTypeII`](@ref),
[`GasTG`](@ref), [`GeneralGovModel`](@ref), [`HydroTurbineGov`](@ref),
[`IEEETurbineGov1`](@ref), [`SteamTurbineGov1`](@ref), [`DEGOV`](@ref),
[`DEGOV1`](@ref), and others.
"""
abstract type TurbineGov <: DynamicGeneratorComponent end

"""
Obtain coefficients (A, B) of the function Se(x) = B(x - A)^2/x for
Se(E1) = B(E1 - A)^2/E1 and Se(E2) = B(E2 - A)^2/E2
and uses the negative solution of the quadratic equation 
"""
function calculate_saturation_coefficients(
    E::Tuple{Float64, Float64},
    Se::Tuple{Float64, Float64},
)
    if ((E[1] == 0.0) || (E[2] == 0.0)) || ((Se[1] == 0.0) || (Se[2] == 0.0))
        return (0.0, 0.0)
    end
    if (E[2] <= E[1]) || (Se[2] <= Se[1])
        throw(
            IS.ConflictingInputsError(
                "E2 <= E1 or Se1 <= Se2. Saturation data is inconsistent.",
            ),
        )
    end
    A =
        (1.0 / (Se[2] * E[2] - Se[1] * E[1])) * (
            E[1] * E[2] * (Se[2] - Se[1]) -
            sqrt(E[1] * E[2] * Se[1] * Se[2] * (E[1] - E[2])^2)
        )
    B = Se[2] * E[2] / (E[2] - A)^2

    @assert abs(B - Se[1] * E[1] / (E[1] - A)^2) <= 1e-2
    return (A, B)
end

"""
Obtain coefficients for an AVR 
"""
function get_avr_saturation(E::Tuple{Float64, Float64}, Se::Tuple{Float64, Float64})
    return calculate_saturation_coefficients(E, Se)
end
