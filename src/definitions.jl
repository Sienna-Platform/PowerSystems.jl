const MinMax = NamedTuple{(:min, :max), Tuple{Float64, Float64}}
const UpDown = NamedTuple{(:up, :down), Tuple{Float64, Float64}}
const StartUpShutDown = NamedTuple{(:startup, :shutdown), Tuple{Float64, Float64}}
const FromTo = NamedTuple{(:from, :to), Tuple{Float64, Float64}}
const TurbinePump = NamedTuple{(:turbine, :pump), Tuple{Float64, Float64}}
# Exception to CamelCase convention for aliases due to confusssing reading of FromToToFrom
const FromTo_ToFrom = NamedTuple{(:from_to, :to_from), Tuple{Float64, Float64}}
"""
    StartUpStages

`NamedTuple{(:hot, :warm, :cold), NTuple{3, Float64}}` representing the start-up costs (\$)
for a multi-start thermal generator at each temperature stage:

- `hot`: cost when the unit is hot (shortest off-time)
- `warm`: cost when the unit is warm (medium off-time)
- `cold`: cost when the unit is cold (longest off-time)

For single-stage generators, only the `hot` field is meaningful. See also
[`single_start_up_to_stages`](@ref).
"""
const StartUpStages = NamedTuple{(:hot, :warm, :cold), NTuple{3, Float64}}

# Intended for use with generators that are not multi-start (e.g. ThermalStandard).
# Operators use `hot` when they don’t have multiple stages.
"Convert a single start-up cost value to a `StartUpStages`"
single_start_up_to_stages(start_up::Real) =
    (hot = Float64(start_up), warm = 0.0, cold = 0.0)

IS.@scoped_enum(GeneratorCostModels, PIECEWISE_LINEAR = 1, POLYNOMIAL = 2,)
@doc"
    GeneratorCostModel

Enumeration representing different cost models for generators in power system analysis.
" GeneratorCostModels

IS.@scoped_enum(AngleUnits, DEGREES = 1, RADIANS = 2,)
@doc"
AngleUnits

Enumeration of angular measurement units used throughout PowerSystems.jl.

- `DEGREES` (1): Angles expressed in degrees.
- `RADIANS` (2): Angles expressed in radians.

# Notes
When performing trigonometric calculations with Julia's built-in functions (`sin`, `cos`,
etc.), convert degrees to radians first (e.g., `θ * π/180`) if the unit is `DEGREES`.
" AngleUnits

IS.@scoped_enum(ACBusTypes, PQ = 1, PV = 2, REF = 3, ISOLATED = 4, SLACK = 5,)
@doc"
ACBusTypes

Enumeration of AC power system bus types (MATPOWER Table B-1).
Each variant corresponds to a standard bus classification used in power flow
and steady-state network models. Set on an [`ACBus`](@ref) via the `bustype` field.

- `PQ` (1): Load bus — active (P) and reactive (Q) power injections are specified;
    the bus voltage magnitude and angle are solved by the power-flow algorithm.
- `PV` (2): Generator bus — active power (P) and voltage magnitude (V) are
    specified; reactive power (Q) and voltage angle are solved.
- `REF` (3): Reference bus — provides a named reference for the system voltage
    angle; often used interchangeably with `SLACK` but kept separate for clarity.
- `ISOLATED` (4): Isolated bus — not connected to the main network; typically
    excluded from the global power-flow solution.
- `SLACK` (5): Slack bus — balances system active and reactive power mismatch and
    sets the reference voltage angle (typically one per connected network).

# Notes
- Numeric values follow the MATPOWER convention for bus type codes.
- Use the enum members (e.g., `ACBusTypes.PQ`, `ACBusTypes.SLACK`) when
    constructing or interpreting network data to ensure compatibility with
    MATPOWER-based data conventions.

# References
- [MATPOWER manual, Table B-1](http://www.pserc.cornell.edu/matpower/MATPOWER-manual.pdf)
" ACBusTypes

IS.@scoped_enum(
    LoadConformity,
    NON_CONFORMING = 0,
    CONFORMING = 1,
    UNDEFINED = 2,
)
@doc"
LoadConformity

WECC-defined enumeration for load conformity classification used in dynamic modeling.

Load conformity indicates whether a load follows system voltage and frequency variations
according to WECC modeling standards:

- `NON_CONFORMING` (0): Load that does not respond predictably to voltage and frequency
    changes, typically representing constant power loads or loads with complex controls.
- `CONFORMING` (1): Load that responds predictably to voltage and frequency variations,
    following standard load modeling practices for dynamic studies.
- `UNDEFINED` (2): Load conformity status is not specified or unknown.

# See Also
- [`MotorLoadTechnology`](@ref): Related enumeration for motor load technology
    classification.
" LoadConformity

# "From PSSE POM v33 Manual"
IS.@scoped_enum(
    FACTSOperationModes,
    OOS = 0, # out-of-service (i.e., Series and Shunt links open)
    NML = 1, # Normal mode of operation, where Series and Shunt links are operating.
    BYP = 2, # Series link is bypassed (i.e., like a zero impedance line) and Shunt link operates as a STATCOM.
)
@doc"
FACTSOperationModes

Enumeration of operational modes for FACTS (Flexible AC Transmission System) devices,
as defined in the PSS/E POM v33 Manual.

- `OOS` (0): Out-of-service — both Series and Shunt links are open.
- `NML` (1): Normal operation — both Series and Shunt links are active.
- `BYP` (2): Bypass mode — Series link is bypassed (acts as a zero-impedance line)
    and Shunt link operates as a STATCOM.

# References
- PSS/E Power Operations Manual v33, FACTS device specification.
" FACTSOperationModes

IS.@scoped_enum(
    DiscreteControlledBranchType,
    SWITCH = 0,
    BREAKER = 1,
    OTHER = 2,
)
@doc"
DiscreteControlledBranchType

Enumeration of discrete controlled branch device types.

- `SWITCH` (0): Switching device that can be opened or closed to connect or isolate a
    circuit segment.
- `BREAKER` (1): Circuit breaker capable of interrupting fault current.
- `OTHER` (2): Other discrete branch device not covered by the above categories.

# See Also
- [`DiscreteControlledACBranch`](@ref): Branch type that uses this enumeration.
- [`DiscreteControlledBranchStatus`](@ref): Enumeration of the open/closed status for
    these devices.
" DiscreteControlledBranchType

IS.@scoped_enum(
    DiscreteControlledBranchStatus,
    OPEN = 0,
    CLOSED = 1,
)
@doc"
DiscreteControlledBranchStatus

Enumeration describing the controlled (commanded) status of a branch device such as a
breaker or switch. Used with [`DiscreteControlledACBranch`](@ref).

- `OPEN` (0): The device is open (non-conducting).
- `CLOSED` (1): The device is closed (conducting).

# Notes
Represents the intended or commanded state used by control and protection logic; it may
differ from the actual measured/telemetry state during faults or failures.
" DiscreteControlledBranchStatus

IS.@scoped_enum(
    WindingCategory,
    TR2W_WINDING = 0,       # Transformer2W only winding associated with a TICT
    PRIMARY_WINDING = 1,    # Primary winding of Trasnformer3W associated with a TICT
    SECONDARY_WINDING = 2,  # Secondary winding of Trasnformer3W associated with a TICT
    TERTIARY_WINDING = 3,   # Tertiary winding of Trasnformer3W associated with a TICT
)
@doc"
WindingCategory

Enumeration of transformer winding roles used to interpret a
[`ImpedanceCorrectionData`](@ref) (Transformer Impedance Correction Table) association.

- `TR2W_WINDING` (0): The winding of a two-winding transformer connected to an
    [`ImpedanceCorrectionData`](@ref).
- `PRIMARY_WINDING` (1): Primary winding of a three-winding transformer connected to an
    [`ImpedanceCorrectionData`](@ref).
- `SECONDARY_WINDING` (2): Secondary winding of a three-winding transformer connected to
    an [`ImpedanceCorrectionData`](@ref).
- `TERTIARY_WINDING` (3): Tertiary winding of a three-winding transformer connected to an
    [`ImpedanceCorrectionData`](@ref).

# See Also
- [`ImpedanceCorrectionTransformerControlMode`](@ref): Enumeration of control modes used
    alongside winding impedance corrections.
" WindingCategory

IS.@scoped_enum(
    WindingGroupNumber,
    UNDEFINED = -99,
    GROUP_0 = 0, # 0 Degrees
    GROUP_1 = 1, # -30 Degrees
    GROUP_5 = 5, # -150 Degrees
    GROUP_6 = 6, # 180 Degrees
    GROUP_7 = 7, # 150 Degrees
    GROUP_11 = 11, # 30 Degrees
)
@doc"
WindingGroupNumber

Enumeration of transformer winding group numbers representing the phase displacement
between primary and secondary windings of three-phase transformers, per IEC 60076-1.

- `UNDEFINED` (-99): Winding group not specified.
- `GROUP_0` (0): 0° phase displacement (e.g., Yy0, Dd0, Dz0).
- `GROUP_1` (1): −30° phase displacement (e.g., Dy1, Yd1, Yz1).
- `GROUP_5` (5): −150° phase displacement (e.g., Dy5, Yd5, Yz5).
- `GROUP_6` (6): 180° phase displacement (e.g., Yy6, Dd6, Dz6).
- `GROUP_7` (7): 150° phase displacement (e.g., Dy7, Yd7, Yz7).
- `GROUP_11` (11): 30° phase displacement (e.g., Dy11, Yd11, Yz11).

# Notes
- Phase displacement is measured from primary to secondary winding; positive angles
    lead and negative angles lag.
- Clock notation: each clock hour represents 30°.

# References
- IEC 60076-1: Power transformers — General.
" WindingGroupNumber

IS.@scoped_enum(
    ImpedanceCorrectionTransformerControlMode,
    PHASE_SHIFT_ANGLE = 1,
    TAP_RATIO = 2,
)
@doc"
ImpedanceCorrectionTransformerControlMode

Enumeration of control modes for impedance correction in transformers, as defined
in the PSS/E transformer control specifications.

- `PHASE_SHIFT_ANGLE` (1): Impedance correction is applied as a function of the phase
    shift angle. Used for phase-shifting transformers that control active power flow.
- `TAP_RATIO` (2): Impedance correction is applied as a function of the tap ratio.
    Used for tap-changing transformers that control voltage magnitude.

# See Also
- [`ImpedanceCorrectionData`](@ref): Supplemental attribute that uses this control mode.
" ImpedanceCorrectionTransformerControlMode

IS.@scoped_enum(
    TransformerControlObjective, # COD1 or COD2 in PSS\e
    UNDEFINED = -99,
    VOLTAGE_DISABLED = -1,
    REACTIVE_POWER_FLOW_DISABLED = -2,
    ACTIVE_POWER_FLOW_DISABLED = -3,
    CONTROL_OF_DC_LINE_DISABLED = -4,
    ASYMMETRIC_ACTIVE_POWER_FLOW_DISABLED = -5,
    FIXED = 0,
    VOLTAGE = 1,
    REACTIVE_POWER_FLOW = 2,
    ACTIVE_POWER_FLOW = 3,
    CONTROL_OF_DC_LINE = 4,
    ASYMMETRIC_ACTIVE_POWER_FLOW = 5,
)
@doc"
    TransformerControlObjective

Enumeration of transformer control objectives based on PSS/E COD1 and COD2 fields.

This enumeration defines the control modes for transformer tap changers and phase shifters
as specified in the PSS/E-35 manual.

# Values
- `UNDEFINED = -99`: Undefined control objective
- `VOLTAGE_DISABLED = -1`: Voltage control disabled
- `REACTIVE_POWER_FLOW_DISABLED = -2`: Reactive power flow control disabled
- `ACTIVE_POWER_FLOW_DISABLED = -3`: Active power flow control disabled
- `CONTROL_OF_DC_LINE_DISABLED = -4`: DC line control disabled
- `ASYMMETRIC_ACTIVE_POWER_FLOW_DISABLED = -5`: Asymmetric active power flow control disabled
- `FIXED = 0`: Fixed tap position (no automatic control)
- `VOLTAGE = 1`: Voltage magnitude control at controlled bus
- `REACTIVE_POWER_FLOW = 2`: Reactive power flow control through the transformer
- `ACTIVE_POWER_FLOW = 3`: Active power flow control through the transformer
- `CONTROL_OF_DC_LINE = 4`: Control of DC transmission line
- `ASYMMETRIC_ACTIVE_POWER_FLOW = 5`: Asymmetric active power flow control

# Notes
Negative values indicate disabled control modes, while positive values represent active
control objectives. The `FIXED` mode (0) indicates manual tap position control without
automatic adjustment.
" TransformerControlObjective

IS.@scoped_enum(
    MotorLoadTechnology,
    INDUCTION = 1,
    SYNCHRONOUS = 2,
    UNDETERMINED = 3,
)
@doc"
MotorLoadTechnology

Enumeration of motor load technology types used in power system dynamic load modeling.

- `INDUCTION` (1): Induction motor, commonly used for general-purpose industrial
    applications.
- `SYNCHRONOUS` (2): Synchronous motor, used for constant-speed or power-factor
    correction applications.
- `UNDETERMINED` (3): Motor technology type is not specified or unknown.

# See Also
- [`LoadConformity`](@ref): Related enumeration for load conformity classification.
" MotorLoadTechnology

IS.@scoped_enum(
    PrimeMovers,
    BA = 1,  # Energy Storage, Battery
    BT = 2,  # Turbines Used in a Binary Cycle (including those used for geothermal applications)
    CA = 3,  # Combined-Cycle – Steam Part
    CC = 4,  # Combined-Cycle - Aggregated Plant *augmentation of EIA
    CE = 5,  # Energy Storage, Compressed Air
    CP = 6,  # Energy Storage, Concentrated Solar Power
    CS = 7,  # Combined-Cycle Single-Shaft Combustion turbine and steam turbine share a single generator
    CT = 8,  # Combined-Cycle Combustion Turbine Part
    ES = 9,  # Energy Storage, Other (Specify on Schedule 9, Comments)
    FC = 10,  # Fuel Cell
    FW = 11,  # Energy Storage, Flywheel
    GT = 12,  # Combustion (Gas) Turbine (including jet engine design)
    HA = 13,  # Hydrokinetic, Axial Flow Turbine
    HB = 14,  # Hydrokinetic, Wave Buoy
    HK = 15,  # Hydrokinetic, Other
    HY = 16,  # Hydraulic Turbine (including turbines associated with delivery of water by pipeline)
    IC = 17,  # Internal Combustion (diesel, piston, reciprocating) Engine
    PS = 18,  # Energy Storage, Reversible Hydraulic Turbine (Pumped Storage)
    OT = 19,  # Other – Specify on SCHEDULE 9.
    ST = 20,  # Steam Turbine (including nuclear, geothermal and solar steam; does not include combined-cycle turbine)
    PVe = 21,  # Photovoltaic *renaming from EIA PV to PVe to avoid conflict with BusType.PV
    WT = 22,  # Wind Turbine, Onshore
    WS = 23,  # Wind Turbine, Offshore
)
@doc"
PrimeMovers

Enumeration of prime mover types used in electric power generation, as defined by the
U.S. Energy Information Administration (EIA) Form 923 instructions.

Prime movers are the engines, turbines, water wheels, or similar machines that drive
electric generators or provide mechanical energy for other purposes.

# Notes
`PVe` is used for photovoltaic systems, renamed from the EIA code `PV` to avoid a
naming conflict with [`ACBusTypes`](@ref) `PV`.

# References
- [EIA Form 923 Instructions](https://www.eia.gov/survey/form/eia_923/instructions.pdf)

# See Also
- [`ThermalStandard`](@ref): Uses prime mover information for generator specifications.
- [`ThermalMultiStart`](@ref): Uses prime mover information for generator specifications.
" PrimeMovers

IS.@scoped_enum(
    ThermalFuels,
    COAL = 1,  # General Coal Category.
    ANTHRACITE_COAL = 2,# ANT
    BITUMINOUS_COAL = 3, # BIT
    LIGNITE_COAL = 4, # LIG
    SUBBITUMINOUS_COAL = 5, # SUB
    WASTE_COAL = 6, # WC # includes anthracite culm, bituminous gob, fine coal, lignite waste, waste coal
    REFINED_COAL = 7,  # RC # ncludes any coal which meets the IRS definition of refined coal [Notice 2010-54 or any superseding IRS notices]. Does not include coal processed by coal preparation plants.)
    SYNTHESIS_GAS_COAL = 8, # SGC
    DISTILLATE_FUEL_OIL = 9,  # DFO # includes Diesel, No. 1, No. 2, and No. 4
    JET_FUEL = 10, # JF
    KEROSENE = 11, # KER
    PETROLEUM_COKE = 12,  # PC
    RESIDUAL_FUEL_OIL = 13,  # RFO # includes No. 5, No. 6 Fuel Oils, and Bunker Oil
    PROPANE = 14, # PG # Propane, gaseous
    SYNTHESIS_GAS_PETROLEUM_COKE = 15,  # SGP
    WASTE_OIL = 16,  # WO # including crude oil, liquid butane, liquid propane, naphtha, oil waste, re-refined motor oil, sludge oil, tar oil, or other petroleum-based liquid wastes
    BLASTE_FURNACE_GAS = 17,  # BFG
    NATURAL_GAS = 18,  # NG    # Natural Gas
    OTHER_GAS = 19,  # OOG    # Other Gas and blast furnace gas
    NUCLEAR = 20,  # NUC # Nuclear Fission (Uranium, Plutonium, Thorium)
    AG_BYPRODUCT = 21,  # AB    # Agricultural Crop Byproducts/Straw/Energy Crops
    MUNICIPAL_WASTE = 22,  # MSW    # Municipal Solid Waste – Biogenic component
    OTHER_BIOMASS_SOLIDS = 23,  # OBS
    WOOD_WASTE_SOLIDS = 24,  # WDS # including paper 18 pellets, railroad ties, utility poles, wood chips, bark, and wood waste solid
    OTHER_BIOMASS_LIQUIDS = 26,  # OBL
    SLUDGE_WASTE = 27, # SLW
    BLACK_LIQUOR = 28, # BLQ
    WOOD_WASTE_LIQUIDS = 29, # WDL # includes red liquor, sludge wood, spent sulfite liquor, and other wood-based liquid. Excluding black liquour
    LANDFILL_GAS = 30, # LFG
    OTHEHR_BIOMASS_GAS = 31, # OBG # includes digester gas, methane, and other biomass gasses
    GEOTHERMAL = 32,  # GEO
    WASTE_HEAT = 33, # WH # WH should only be reported where the fuel source for the waste heat is undetermined, and for combined-cycle steam turbines that do not have supplemental firing.
    TIREDERIVED_FUEL = 34, # TDF
    OTHER = 35,  # OTH
)

@doc"
ThermalFuels

Enumeration of thermal fuel types, using EIA Form 923 fuel codes for standardized
reporting of fuel consumption in electric power generation.

Categories include: coal and coal-derived fuels, petroleum products, natural gas, nuclear,
biomass and waste-derived fuels, geothermal, and other thermal energy sources.

# Notes
`COAL` (general coal) and `GEOTHERMAL` codes are not directly from the current EIA 923
form but are retained for compatibility with older data.

# References
- [EIA Form 923 Instructions](https://www.eia.gov/survey/form/eia_923/instructions.pdf)

# See Also
- [`ThermalStandard`](@ref): Generator type that uses this fuel enumeration.
- [`ThermalMultiStart`](@ref): Generator type that uses this fuel enumeration.
- [`PrimeMovers`](@ref): Companion enumeration for generator prime mover type.
" ThermalFuels

IS.@scoped_enum(
    StorageTech,
    PTES = 1, # Pumped thermal energy storage
    LIB = 2, # LiON Battery
    LAB = 3, # Lead Acid Battery
    FLWB = 4, # Redox Flow Battery
    SIB = 5, # Sodium Ion Battery
    ZIB = 6, # Zinc Ion Battery,
    HGS = 7, # Hydrogen Gas Storage,
    LAES = 8, # Liquid Air Storage
    OTHER_CHEM = 9, # Chemmical Storage
    OTHER_MECH = 10, # Mechanical Storage
    OTHER_THERM = 11, # Thermal Storage
)
@doc"
StorageTech

Enumeration of energy storage technologies used in power system modeling.

- `PTES` (1): Pumped thermal energy storage.
- `LIB` (2): Lithium-ion battery.
- `LAB` (3): Lead-acid battery.
- `FLWB` (4): Redox flow battery.
- `SIB` (5): Sodium-ion battery.
- `ZIB` (6): Zinc-ion battery.
- `HGS` (7): Hydrogen gas storage.
- `LAES` (8): Liquid air energy storage.
- `OTHER_CHEM` (9): Other chemical storage technologies.
- `OTHER_MECH` (10): Other mechanical storage technologies.
- `OTHER_THERM` (11): Other thermal storage technologies.

# See Also
- [`EnergyReservoirStorage`](@ref): Storage component using this enumeration.
" StorageTech

IS.@scoped_enum(
    PumpHydroStatus,
    OFF = 0,
    GEN = 1,
    PUMP = -1,
)
@doc"
PumpHydroStatus

Operating status of a pumped‑storage hydro unit.

Values
- OFF = 0: Unit is idle — neither generating nor pumping.
- GEN = 1: Generating mode (turbine operation), producing active power.
- PUMP = -1: Pumping mode, consuming active power to store energy.

Notes
- The sign of the value reflects the net direction of active power (positive = generation, negative = pumping).
- Intended for use in scheduling, dispatch, and state-tracking of pumped‑storage units.
" PumpHydroStatus

IS.@scoped_enum(StateTypes, Differential = 1, Algebraic = 2, Hybrid = 3,)
@doc"
StateTypes

Enumeration of state variable types for dynamic components.

- `Differential` (1): State governed by a differential equation (evolves continuously
    in time).
- `Algebraic` (2): State determined by an algebraic constraint (no time derivative).
- `Hybrid` (3): State that can behave as either differential or algebraic depending on
    operating conditions.

# See Also
- [`DynamicComponent`](@ref): Abstract base type whose states are classified by this
    enumeration.
" StateTypes

IS.@scoped_enum(
    ReservoirDataType,
    USABLE_VOLUME = 1,
    TOTAL_VOLUME = 2,
    HEAD = 3,
    ENERGY = 4,
)
@doc"
ReservoirDataType

Enumeration of the quantity type used to represent the state of a [`HydroReservoir`](@ref).

- `USABLE_VOLUME` (1): Volume available for operations and dispatch (active storage),
    typically in cubic meters (m³).
- `TOTAL_VOLUME` (2): Total reservoir volume including dead and active storage, in m³.
- `HEAD` (3): Hydraulic head or water surface elevation relative to a datum, in meters (m).
- `ENERGY` (4): Stored or deliverable energy associated with the reservoir, in MWh or GWh.

# See Also
- [`ReservoirLocation`](@ref): Enumeration of reservoir location relative to the turbine.
" ReservoirDataType

IS.@scoped_enum(
    HydroTurbineType,
    UNKNOWN = 0,          # Default / unspecified
    PELTON = 1,           # Impulse turbine for high head
    FRANCIS = 2,          # Reaction turbine for medium head
    KAPLAN = 3,           # Propeller-type turbine for low head
    TURGO = 4,            # Impulse turbine similar to Pelton
    CROSSFLOW = 5,        # Banki-Michell (crossflow) turbine
    BULB = 6,             # Kaplan variation for very low head
    DERIAZ = 7,           # Diagonal flow turbine
    PROPELLER = 8,        # Simple propeller turbine
    OTHER = 9             # Catch-all for less common designs
)
@doc"
HydroTurbineType

Enumeration of hydroelectric turbine designs, used to classify hydro generating units
by operating head range and flow characteristics.

- `UNKNOWN` (0): Turbine type is not specified.
- `PELTON` (1): Impulse turbine for high-head, low-flow sites.
- `FRANCIS` (2): Reaction turbine, widely used for medium-head applications.
- `KAPLAN` (3): Adjustable-blade propeller turbine for low-head, high-flow sites.
- `TURGO` (4): Impulse turbine similar to Pelton but suitable for higher flow rates.
- `CROSSFLOW` (5): Banki-Michell (crossflow) impulse turbine, robust for small hydro.
- `BULB` (6): Compact Kaplan variant for low-head run-of-river plants.
- `DERIAZ` (7): Diagonal flow reaction turbine with variable pitch blades.
- `PROPELLER` (8): Fixed-blade propeller turbine.
- `OTHER` (9): Placeholder for less common or custom turbine designs.

# See Also
- [`HydroTurbine`](@ref): Hydro generator component using this enumeration.
" HydroTurbineType

IS.@scoped_enum(
    ReservoirLocation,
    HEAD = 1,
    TAIL = 2,
)
@doc"
ReservoirLocation

Enumeration representing the location of a [`HydroReservoir`](@ref) relative to its
associated turbine unit.

- `HEAD` (1): The reservoir is located upstream of the turbine (higher elevation).
- `TAIL` (2): The reservoir is located downstream of the turbine (lower elevation).

# See Also
- [`ReservoirDataType`](@ref): Enumeration of the quantity used to represent reservoir
    state.
" ReservoirLocation

IS.@scoped_enum(
    CombinedCycleConfiguration,
    SingleShaftCombustionSteam = 1,
    SeparateShaftCombustionSteam = 2,
    DoubleCombustionOneSteam = 3,
    TripleCombustionOneSteam = 4,
    Other = 5,
)
@doc"
    CombinedCycleConfiguration

Enumeration describing the physical layout of a combined cycle power plant.

- `SingleShaftCombustionSteam` (1): Single combustion turbine on a common shaft with one steam turbine.
- `SeparateShaftCombustionSteam` (2): One combustion turbine and one steam turbine on separate shafts.
- `DoubleCombustionOneSteam` (3): Two combustion turbines exhausting into one steam turbine.
- `TripleCombustionOneSteam` (4): Three combustion turbines exhausting into one steam turbine.
- `Other` (5): Any other combined cycle configuration not covered by the above values.

# See Also
- [`CombinedCycleBlock`](@ref): Plant attribute for combined cycle block-level configurations.
- [`CombinedCycleFractional`](@ref): Plant attribute for combined cycle fractional configurations.
" CombinedCycleConfigurationModule.CombinedCycleConfiguration

const PS_MAX_LOG = parse(Int, get(ENV, "PS_MAX_LOG", "50"))
const DEFAULT_BASE_MVA = 100.0

const POWER_SYSTEM_STRUCT_DESCRIPTOR_FILE =
    joinpath(dirname(pathof(PowerSystems)), "descriptors", "power_system_structs.json")

const DEFAULT_SYSTEM_FREQUENCY = 60.0

const INFINITE_TIME = 1e4
const START_COST = 1e8
const INFINITE_COST = 1e8
const INFINITE_BOUND = 1e6
const BRANCH_BUS_VOLTAGE_DIFFERENCE_TOL = 0.01

const PSSE_PARSER_TAP_RATIO_UBOUND = 1.5
const PSSE_PARSER_TAP_RATIO_LBOUND = 0.5
const PARSER_TAP_RATIO_CORRECTION_TOL = 1e-5

const ZERO_IMPEDANCE_REACTANCE_THRESHOLD = 1e-4

const WINDING_NAMES = Dict(
    WindingCategory.PRIMARY_WINDING => "primary",
    WindingCategory.SECONDARY_WINDING => "secondary",
    WindingCategory.TERTIARY_WINDING => "tertiary",
)

const TRANSFORMER3W_PARAMETER_NAMES = [
    "COD", "CONT", "NOMV", "WINDV", "RMA", "RMI",
    "NTP", "VMA", "VMI", "RATA", "RATB", "RATC",
]
