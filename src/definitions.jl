const MinMax = NamedTuple{(:min, :max), Tuple{Float64, Float64}}
const UpDown = NamedTuple{(:up, :down), Tuple{Float64, Float64}}
const StartUpShutDown = NamedTuple{(:startup, :shutdown), Tuple{Float64, Float64}}
const FromTo = NamedTuple{(:from, :to), Tuple{Float64, Float64}}
const TurbinePump = NamedTuple{(:turbine, :pump), Tuple{Float64, Float64}}
# Exception to CamelCase convention for aliases due to confusssing reading of FromToToFrom
const FromTo_ToFrom = NamedTuple{(:from_to, :to_from), Tuple{Float64, Float64}}
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

An enumeration of angular measurement units used throughout the PowerSystems package.

Values
- `DEGREES`: Angles expressed in degrees.
- `RADIANS`: Angles expressed in radians.

Usage
Use `AngleUnits` to make unit semantics explicit for functions, fields, and APIs that accept or return angular values. When performing trigonometric calculations with Base functions (`sin`, `cos`, etc.), convert degrees to radians (e.g., `θ * π/180`) if the unit is `DEGREES`.

Examples
julia> unit = AngleUnits.DEGREES
AngleUnits.DEGREES

julia> θ = 30.0
julia> θ_rad = unit == AngleUnits.DEGREES ? θ * (π/180) : θ
" AngleUnits

IS.@scoped_enum(ACBusTypes, PQ = 1, PV = 2, REF = 3, ISOLATED = 4, SLACK = 5,)
@doc"
ACBusTypes

Enumeration of AC power system bus types (MATPOWER Table B‑1).
Each variant corresponds to a standard bus classification used in power flow
and steady‑state network models:

- PQ (1): Load bus — active (P) and reactive (Q) power injections are specified;
    the bus voltage magnitude and angle are solved by the power‑flow algorithm.
- PV (2): Generator (PV) bus — active power (P) and voltage magnitude (V) are
    specified; reactive power (Q) and voltage angle are solved.
- REF (3): Reference bus — a named reference for the system voltage angle; often
    equivalent to a slack bus in semantics but provided separately for clarity.
- ISOLATED (4): Isolated bus — not connected to the main network (islanded or
    disconnected); typically excluded from the global power‑flow solution.
- SLACK (5): Slack bus — balances the system active and reactive power mismatch
    and sets the reference voltage angle (commonly one per connected network).

Notes
- Numeric values follow the MATPOWER convention for bus type codes.
- Use the enum members (e.g., `ACBusTypes.PQ`, `ACBusTypes.SLACK`) when
    constructing or interpreting network data structures to ensure clarity and
    compatibility with MATPOWER-based data conventions.

Reference: MATPOWER manual, Table B‑1 (http://www.pserc.cornell.edu/matpower/MATPOWER-manual.pdf).
" ACBusTypes

IS.@scoped_enum(
    LoadConformity,
    NON_CONFORMING = 0,
    CONFORMING = 1,
    UNDEFINED = 2,
)
@doc"""
    LoadConformity

WECC-defined enumeration for load conformity classification used in dynamic modeling.

Load conformity indicates whether a load follows system voltage and frequency variations
according to WECC modeling standards:

- `NON_CONFORMING = 0`: Load that does not respond predictably to voltage and frequency changes,
  typically representing constant power loads or loads with complex control systems
- `CONFORMING = 1`: Load that responds predictably to voltage and frequency variations,
  following standard load modeling practices for dynamic studies
- `UNDEFINED = 2`: Load conformity status is not specified or unknown

This classification is essential for WECC dynamic studies as it determines how loads are
modeled during system disturbances and stability analysis.
""" LoadConformity

# "From PSSE POM v33 Manual"
IS.@scoped_enum(
    FACTSOperationModes,
    OOS = 0, # out-of-service (i.e., Series and Shunt links open)
    NML = 1, # Normal mode of operation, where Series and Shunt links are operating.
    BYP = 2, # Series link is bypassed (i.e., like a zero impedance line) and Shunt link operates as a STATCOM.
)
@doc"
    FACTSOperationModes

Enumeration defining the operational modes for FACTS (Flexible AC Transmission System) devices.
Based on PSSE POM v33 Manual specifications.

# Values
- `OOS = 0`: Out-of-service mode where both Series and Shunt links are open
- `NML = 1`: Normal mode of operation where both Series and Shunt links are operating
- `BYP = 2`: Bypass mode where Series link is bypassed (acts like zero impedance line)
  and Shunt link operates as a STATCOM
" FACTSOperationModes

IS.@scoped_enum(
    DiscreteControlledBranchType,
    SWITCH = 0,
    BREAKER = 1,
    OTHER = 2,
)
@doc"
    DiscreteControlledBranchType

An enumeration representing different types of discrete controlled branches in power systems.

# Values
- `SWITCH = 0`: Represents a switch device that can be opened or closed
- `BREAKER = 1`: Represents a circuit breaker that can interrupt current flow
- `OTHER = 2`: Represents other types of discrete controlled branch devices
" DiscreteControlledBranchType

IS.@scoped_enum(
    DiscreteControlledBranchStatus,
    OPEN = 0,
    CLOSED = 1,
)
@doc"
DiscreteControlledBranchStatus

Enumeration describing the controlled (commanded) status of a branch device
(such as a breaker or a switch) in a power system model.

Values
- OPEN = 0: The device is open (interrupting state) — the branch is non-conducting.
- CLOSED = 1: The device is closed (conducting state) — the branch provides a normal conduction path.

Notes
- This enum represents the intended or commanded state used by control and protection
    logic; it may differ from actual measured/telemetry state during faults or failures.
- The integer encoding (0/1) is chosen for compact storage and interop with serialization
    or external data formats.
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

An enumeration representing different types of transformer windings used in power system analysis.
Reflects how to interpret the Transformer Impedance Correction Table (TICT) winding association as described in [`ImpedanceCorrectionData`](@ref).

# Values
- `TR2W_WINDING = 0`: Winding associated with a two-winding transformer (Transformer2W) connected to a tap-changing transformer's [`ImpedanceCorrectionData`](@ref)
- `PRIMARY_WINDING = 1`: Primary winding of a three-winding transformer (Transformer3W) associated with a [`ImpedanceCorrectionData`](@ref)
- `SECONDARY_WINDING = 2`: Secondary winding of a three-winding transformer (Transformer3W) associated with a [`ImpedanceCorrectionData`](@ref)
- `TERTIARY_WINDING = 3`: Tertiary winding of a three-winding transformer (Transformer3W) associated with a [`ImpedanceCorrectionData`](@ref)

This enumeration is used to categorize transformer windings based on their role and configuration
in the power system model, particularly in relation to tap-changing transformers.
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

Enumeration defining transformer winding group numbers based on IEC 60076-1 standard.
These numbers represent the phase displacement between primary and secondary windings
of three-phase transformers.

# Valid Values
- `UNDEFINED = -99`: Undefined or unspecified winding group
- `GROUP_0 = 0`: 0° phase displacement (Yy0, Dd0, Dz0)
- `GROUP_1 = 1`: -30° phase displacement (Yy1, Dd1, Dz1)
- `GROUP_5 = 5`: -150° phase displacement (Yy5, Dd5, Dz5)
- `GROUP_6 = 6`: 180° phase displacement (Yy6, Dd6, Dz6)
- `GROUP_7 = 7`: 150° phase displacement (Yy7, Dd7, Dz7)
- `GROUP_11 = 11`: 30° phase displacement (Yy11, Dd11, Dz11)

# Notes
The phase displacement is measured from the primary to secondary winding, with
positive angles representing a lead and negative angles representing a lag.
Clock notation follows the convention where each hour represents 30°.
" WindingGroupNumber

IS.@scoped_enum(
    ImpedanceCorrectionTransformerControlMode,
    PHASE_SHIFT_ANGLE = 1,
    TAP_RATIO = 2,
)
@doc"""
    ImpedanceCorrectionTransformerControlMode

Enumeration defining the control modes for impedance correction in transformers,
based on PSS/E transformer control definitions.

# Values
- `PHASE_SHIFT_ANGLE = 1`: Control mode for phase-shifting transformers where the
  impedance correction is applied based on the phase shift angle. Used when the
  transformer primarily controls power flow through phase angle adjustment.
- `TAP_RATIO = 2`: Control mode for tap-changing transformers where the impedance
  correction is applied based on the tap ratio. Used when the transformer primarily
  controls voltage magnitude through tap position changes.

# Notes
This enumeration corresponds to PSS/E transformer control field definitions for
determining how impedance corrections are calculated and applied in power flow
and dynamic simulation studies.
""" ImpedanceCorrectionTransformerControlMode

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

An enumeration representing different motor load technologies used in industrial applications.

# Values
- `INDUCTION`: Induction motor technology, commonly used for general-purpose applications
- `SYNCHRONOUS`: Synchronous motor technology, used for applications requiring constant speed
- `UNDETERMINED`: Motor technology type is not specified or unknown
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
electric generators or provide mechanical energy for other purposes. This enumeration
provides standardized codes for different types of prime movers used in power plants.

PVe is used for photovoltaic systems renaming from EIA PV to avoid conflict with BusType.PV

# References
- [EIA Form 923 Instructions](https://www.eia.gov/survey/form/eia_923/instructions.pdf)

# See Also
- [`ThermalStandard`](@ref): Uses prime mover information for generator specifications
- [`ThermalMultiStart`](@ref): Uses prime mover information for generator specifications
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

Enumeration of thermal fuel types based on AER (Aggregated Energy Reporting) fuel codes
as defined by the U.S. Energy Information Administration (EIA) Form 923.

The fuel codes represent standardized categories for reporting fuel consumption in
electric power generation, covering major thermal fuel types including:

- Coal and coal-derived fuels
- Natural gas and petroleum products
- Nuclear fuel
- Biomass and waste fuels
- Other thermal energy sources

Reference: EIA Form 923 Instructions (https://www.eia.gov/survey/form/eia_923/instructions.pdf)
General Coal and Geothermal codes not directly from the current EIA 923 form but kept for compatibility with older versions of the form.
See also: [`ThermalStandard`](@ref)
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

Enumeration of energy storage technologies used in power systems.

# Values
- `PTES`: Pumped thermal energy storage
- `LIB`: Lithium-ion Battery
- `LAB`: Lead Acid Battery
- `FLWB`: Redox Flow Battery
- `SIB`: Sodium Ion Battery
- `ZIB`: Zinc Ion Battery
- `HGS`: Hydrogen Gas Storage
- `LAES`: Liquid Air Energy Storage
- `OTHER_CHEM`: Chemical Storage (other than specified)
- `OTHER_MECH`: Mechanical Storage (other than specified)
- `OTHER_THERM`: Thermal Storage (other than specified)

This enumeration is used to classify different types of energy storage systems
based on their underlying technology and storage mechanism.
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

@doc """
Categorization of dynamic state variables.

# Values
- `Differential`: State governed by a differential equation
- `Algebraic`: State governed by an algebraic constraint
- `Hybrid`: State with both differential and algebraic aspects
""" StateTypes

IS.@scoped_enum(
    ReservoirDataType,
    USABLE_VOLUME = 1,
    TOTAL_VOLUME = 2,
    HEAD = 3,
    ENERGY = 4,
)
@doc"
ReservoirDataType

Enumeration of reservoir accounting unit classes.

This enum identifies the type of data recorded or tracked for a reservoir. Use these values when specifying
the kind of measurement or accounting quantity associated with a reservoir (for example in time series,
storage models, reporting, or data exchange).

Values
- USABLE_VOLUME: Volume available for operations and dispatch (active storage). Typically reported in cubic meters (m³) or other volumetric units.
- TOTAL_VOLUME: Total reservoir volume including dead and active storage. Reported in the same volumetric units as USABLE_VOLUME.
- HEAD: Hydraulic head or water surface elevation relative to a datum, typically reported in meters (m).
- ENERGY: Stored or deliverable energy associated with the reservoir (e.g., potential energy or expected generation), often expressed in MWh, GWh, or joules.
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

Enumeration of hydro turbine types supported in `PowerSystems.jl`.

This type is used to categorize hydroelectric generators by their
turbine design and operating head. It provides a standardized set
of turbine types to ensure consistent modeling and data handling
across different systems.

# Values
- `UNKNOWN`   : Default value when the turbine type is not specified.
- `PELTON`    : Impulse turbine, typically used for high-head, low-flow sites.
- `FRANCIS`   : Reaction turbine, widely used for medium-head applications.
- `KAPLAN`    : Adjustable-blade propeller turbine for low-head, high-flow sites.
- `TURGO`     : Impulse turbine similar to Pelton but suitable for higher flow rates.
- `CROSSFLOW` : Banki-Michell (crossflow) impulse turbine, robust for small hydro.
- `BULB`      : Compact Kaplan variant, typically installed in low-head run-of-river plants.
- `DERIAZ`    : Diagonal flow reaction turbine with variable pitch blades.
- `PROPELLER` : Fixed-blade propeller turbine, simpler than Kaplan but less efficient at part load.
- `OTHER`     : Placeholder for less common or custom turbine designs.
" HydroTurbineType

IS.@scoped_enum(
    ReservoirLocation,
    HEAD = 1,
    TAIL = 2,
)
@doc"
ReservoirLocation

Enumeration representing the location of a hydro reservoir relative to its associated turbine.

# Values
- `HEAD`: The reservoir is located upstream of the turbine, typically at a higher elevation.
- `TAIL`: The reservoir is located downstream of the turbine at a lower or same elevation.

" ReservoirLocation

IS.@scoped_enum(
    CombinedCycleConfiguration,
    SingleShaftCombustionSteam = 1,
    SeparateShaftCombustionSteam = 2,
    DoubleCombustionOneSteam = 3,
    TripleCombustionOneSteam = 4,
    Other = 5,
)

@doc """
Configuration types for combined cycle power plants.

# Values
- `SingleShaftCombustionSteam`: Single-shaft arrangement with one combustion and one steam turbine
- `SeparateShaftCombustionSteam`: Separate shafts for combustion and steam turbines
- `DoubleCombustionOneSteam`: Two combustion turbines feeding one steam turbine
- `TripleCombustionOneSteam`: Three combustion turbines feeding one steam turbine
- `Other`: Other combined cycle configuration
""" CombinedCycleConfiguration

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
