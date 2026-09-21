const ENUMS = (
    AngleUnits.Value,
    ACBusTypes.Value,
    FACTSOperationModes.Value,
    DiscreteControlledBranchType.Value,
    DiscreteControlledBranchStatus.Value,
    WindingCategory.Value,
    ImpedanceCorrectionTransformerControlMode.Value,
    GeneratorCostModels.Value,
    PrimeMovers.Value,
    StateTypes.Value,
    ReservoirDataType.Value,
    ReservoirLocation.Value,
    ThermalFuels.Value,
    UnitSystem.Value,
    LoadConformity.Value,
    HydroTurbineType.Value,
    TransformerControlObjective.Value,
    OperationalStates.Value,
    CommitmentModes.Value,
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
