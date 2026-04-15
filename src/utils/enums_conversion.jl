const ENUMS = (
    AngleUnits,
    ACBusTypes,
    FACTSOperationModes,
    DiscreteControlledBranchType,
    DiscreteControlledBranchStatus,
    WindingCategory,
    ImpedanceCorrectionTransformerControlMode,
    GeneratorCostModels,
    PrimeMovers,
    StateTypes,
    ReservoirDataType,
    ReservoirLocation,
    ThermalFuels,
    UnitSystem,
    LoadConformity,
    WindingGroupNumber,
    HydroTurbineType,
    TransformerControlObjective,
)

const ENUM_MAPPINGS = Dict()

for enum in ENUMS
    ENUM_MAPPINGS[enum] = Dict()
    for value in instances(enum)
        ENUM_MAPPINGS[enum][normalize(string(value); casefold = true)] = value
    end
end

"""Get the enum value for the string. Case insensitive."""
function get_enum_value(enum, value::AbstractString)
    if !haskey(ENUM_MAPPINGS, enum)
        throw(ArgumentError("enum=$enum is not valid"))
    end

    val = normalize(value; casefold = true)
    if !haskey(ENUM_MAPPINGS[enum], val)
        throw(ArgumentError("enum=$enum does not have value=$val"))
    end

    return ENUM_MAPPINGS[enum][val]
end

Base.convert(::Type{AngleUnits}, val::AbstractString) = get_enum_value(AngleUnits, val)
Base.convert(::Type{ACBusTypes}, val::AbstractString) = get_enum_value(ACBusTypes, val)
Base.convert(::Type{LoadConformity}, val::AbstractString) =
    get_enum_value(LoadConformity, val)
Base.convert(::Type{FACTSOperationModes}, val::AbstractString) =
    get_enum_value(FACTSOperationModes, val)
Base.convert(::Type{DiscreteControlledBranchType}, val::AbstractString) =
    get_enum_value(DiscreteControlledBranchType, val)
Base.convert(::Type{DiscreteControlledBranchStatus}, val::AbstractString) =
    get_enum_value(DiscreteControlledBranchStatus, val)
Base.convert(::Type{WindingCategory}, val::AbstractString) =
    get_enum_value(WindingCategory, val)
Base.convert(::Type{WindingGroupNumber}, val::AbstractString) =
    get_enum_value(WindingGroupNumber, val)
Base.convert(::Type{ImpedanceCorrectionTransformerControlMode}, val::AbstractString) =
    get_enum_value(ImpedanceCorrectionTransformerControlMode, val)
Base.convert(::Type{GeneratorCostModels}, val::AbstractString) =
    get_enum_value(GeneratorCostModels, val)
Base.convert(::Type{PrimeMovers}, val::AbstractString) = get_enum_value(PrimeMovers, val)
Base.convert(::Type{StateTypes}, val::AbstractString) = get_enum_value(StateTypes, val)
Base.convert(::Type{ThermalFuels}, val::AbstractString) = get_enum_value(ThermalFuels, val)
Base.convert(::Type{TransformerControlObjective}, val::AbstractString) =
    get_enum_value(TransformerControlObjective, val)
Base.convert(::Type{ReservoirLocation}, val::AbstractString) =
    get_enum_value(ReservoirLocation, val)
Base.convert(::Type{HydroTurbineType}, val::AbstractString) =
    get_enum_value(HydroTurbineType, val)
