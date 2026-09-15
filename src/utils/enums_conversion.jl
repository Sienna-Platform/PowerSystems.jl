const ENUMS = (
    AngleUnits.T,
    ACBusTypes.T,
    FACTSOperationModes.T,
    DiscreteControlledBranchType.T,
    DiscreteControlledBranchStatus.T,
    WindingCategory.T,
    ImpedanceCorrectionTransformerControlMode.T,
    GeneratorCostModels.T,
    PrimeMovers.T,
    StateTypes.T,
    ReservoirDataType.T,
    ReservoirLocation.T,
    ThermalFuels.T,
    UnitSystem.T,
    LoadConformity.T,
    HydroTurbineType.T,
    TransformerControlObjective.T,
    OperationalStates.T,
    CommitmentModes.T,
)

const ENUM_MAPPINGS = Dict(
    enum => Dict(normalize(string(v); casefold = true) => v for v in instances(enum))
    for enum in ENUMS
)

"""Get the enum value for the string. Case insensitive."""
function get_enum_value(enum, value::AbstractString)
    val = normalize(value; casefold = true)
    mapping = ENUM_MAPPINGS[enum]
    if !haskey(mapping, val)
        throw(ArgumentError("enum=$enum does not have value=$val"))
    end
    return mapping[val]
end

# String -> enum conversion for every member of `ENUMS`, so the list is stated once.
for enum in ENUMS
    @eval Base.convert(::Type{$enum}, val::AbstractString) = get_enum_value($enum, val)
end
