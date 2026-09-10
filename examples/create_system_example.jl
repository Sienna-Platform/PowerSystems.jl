#=
Example script demonstrating how to create a PowerSystems.System
with various component types including ACBus, ThermalStandard, and TwoTerminalHVDC.
=#

using PowerSystems

const PSY = PowerSystems

# Create a new System with 100 MVA base power
sys = System(100.0; name = "Example Power System", frequency = 60.0)

# =============================================================================
# Create ACBus components
# =============================================================================

bus1 = ACBus(;
    number = 1,
    name = "Slack Bus",
    available = true,
    bustype = ACBusTypes.SLACK,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.95, max = 1.05),
    base_voltage = 230.0,  # kV
    area = nothing,
    load_zone = nothing,
)

bus2 = ACBus(;
    number = 2,
    name = "Gen Bus 2",
    available = true,
    bustype = ACBusTypes.PV,
    angle = 0.0,
    magnitude = 1.02,
    voltage_limits = (min = 0.95, max = 1.05),
    base_voltage = 230.0,
)

bus3 = ACBus(;
    number = 3,
    name = "Load Bus",
    available = true,
    bustype = ACBusTypes.PQ,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.95, max = 1.05),
    base_voltage = 230.0,
)

bus4 = ACBus(;
    number = 4,
    name = "HVDC Terminal Bus",
    available = true,
    bustype = ACBusTypes.PQ,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.95, max = 1.05),
    base_voltage = 345.0,  # Higher voltage for HVDC terminal
)

# Add buses to system
for bus in [bus1, bus2, bus3, bus4]
    add_component!(sys, bus)
end

# =============================================================================
# Create ThermalStandard generators
# =============================================================================

# Cost function for gas turbine
gas_cost = ThermalGenerationCost(;
    variable = CostCurve(QuadraticCurve(0.001, 25.0, 0.0)),  # $/MWh quadratic
    fixed = 150.0,      # $/hour
    start_up = 1000.0,  # $ per start
    shut_down = 100.0,  # $ per shutdown
)

thermal_gen1 = ThermalStandard(;
    name = "Gas Turbine 1",
    available = true,
    status = OperationalStates.ONLINE,
    bus = bus1,
    active_power = 150.0,      # MW
    reactive_power = 20.0,     # MVAR
    rating = 200.0,            # MVA
    active_power_limits = (min = 50.0, max = 200.0),
    reactive_power_limits = (min = -100.0, max = 100.0),
    ramp_limits = (up = 50.0, down = 50.0),  # MW/min
    operation_cost = gas_cost,
    base_power = 100.0,
    time_limits = (up = 4.0, down = 2.0),    # hours
    prime_mover_type = PrimeMovers.CT,   # Combustion Turbine
    fuel = ThermalFuels.NATURAL_GAS,
)

# Cost function for coal plant (piecewise linear)
coal_cost = ThermalGenerationCost(;
    variable = CostCurve(LinearCurve(22.0)),  # $/MWh linear
    fixed = 200.0,
    start_up = (hot = 800.0, warm = 1200.0, cold = 2000.0),  # Multi-stage startup
    shut_down = 150.0,
)

thermal_gen2 = ThermalStandard(;
    name = "Coal Plant 1",
    available = true,
    status = true,
    bus = bus2,
    active_power = 300.0,
    reactive_power = 50.0,
    rating = 400.0,
    active_power_limits = (min = 100.0, max = 400.0),
    reactive_power_limits = (min = -150.0, max = 150.0),
    ramp_limits = (up = 20.0, down = 20.0),  # Slower ramp for coal
    operation_cost = coal_cost,
    base_power = 100.0,
    time_limits = (up = 8.0, down = 8.0),    # Longer min up/down times
    prime_mover_type = PrimeMovers.ST,   # Steam Turbine
    fuel = ThermalFuels.COAL,
)

# Add generators to system
add_component!(sys, thermal_gen1)
add_component!(sys, thermal_gen2)

# =============================================================================
# Create AC transmission lines
# =============================================================================

line1 = Line(;
    name = "Line 1-3",
    available = true,
    active_power_flow = 0.0,
    reactive_power_flow = 0.0,
    arc = Arc(bus1, bus3),
    r = 0.01,   # per unit resistance
    x = 0.1,    # per unit reactance
    b = (from = 0.02, to = 0.02),  # per unit susceptance
    rating = 200.0,  # MVA
    angle_limits = (min = -0.7, max = 0.7),  # radians
)

line2 = Line(;
    name = "Line 2-3",
    available = true,
    active_power_flow = 0.0,
    reactive_power_flow = 0.0,
    arc = Arc(bus2, bus3),
    r = 0.015,
    x = 0.12,
    b = (from = 0.015, to = 0.015),
    rating = 150.0,
    angle_limits = (min = -0.7, max = 0.7),
)

add_component!(sys, line1)
add_component!(sys, line2)

# =============================================================================
# Create TwoTerminalHVDC line
# =============================================================================

hvdc_line = TwoTerminalGenericHVDCLine(;
    name = "HVDC Link 3-4",
    available = true,
    active_power_flow = 100.0,  # MW flowing on the line
    arc = Arc(bus3, bus4),
    active_power_limits_from = (min = -500.0, max = 500.0),
    active_power_limits_to = (min = -500.0, max = 500.0),
    reactive_power_limits_from = (min = -200.0, max = 200.0),
    reactive_power_limits_to = (min = -200.0, max = 200.0),
    loss = LinearCurve(0.02),  # 2% loss coefficient
)

add_component!(sys, hvdc_line)

# =============================================================================
# Create loads
# =============================================================================

load1 = PowerLoad(;
    name = "Load at Bus 3",
    available = true,
    bus = bus3,
    active_power = 250.0,   # MW
    reactive_power = 50.0,  # MVAR
    base_power = 100.0,
    max_active_power = 300.0,
    max_reactive_power = 100.0,
)

load2 = PowerLoad(;
    name = "Load at Bus 4",
    available = true,
    bus = bus4,
    active_power = 150.0,
    reactive_power = 30.0,
    base_power = 100.0,
    max_active_power = 200.0,
    max_reactive_power = 80.0,
)

add_component!(sys, load1)
add_component!(sys, load2)

# =============================================================================
# Create a renewable generator
# =============================================================================

renewable_cost = RenewableGenerationCost(;
    variable = CostCurve(LinearCurve(0.0)),  # Zero marginal cost
    curtailment_cost = CostCurve(LinearCurve(50.0)),  # $/MWh curtailment penalty
)

wind_gen = RenewableDispatch(;
    name = "Wind Farm 1",
    available = true,
    bus = bus4,
    active_power = 80.0,
    reactive_power = 0.0,
    rating = 100.0,
    prime_mover_type = PrimeMovers.WT,
    reactive_power_limits = (min = -30.0, max = 30.0),
    power_factor = 1.0,
    operation_cost = renewable_cost,
    base_power = 100.0,
)

add_component!(sys, wind_gen)

# =============================================================================
# Create a battery storage system
# =============================================================================

storage_cost = StorageCost(;
    charge_variable_cost = CostCurve(LinearCurve(5.0)),
    discharge_variable_cost = CostCurve(LinearCurve(5.0)),
    fixed = 10.0,
    start_up = 0.0,
    shut_down = 0.0,
    energy_shortage_cost = 1000.0,
    energy_surplus_cost = 0.0,
)

battery = EnergyReservoirStorage(;
    name = "Battery 1",
    available = true,
    bus = bus3,
    prime_mover_type = PrimeMovers.BA,
    storage_technology_type = StorageTech.OTHER_CHEM,
    storage_capacity = 400.0,  # MWh
    storage_level_limits = (min = 0.1, max = 0.9),  # State of charge limits
    initial_storage_capacity_level = 0.5,  # 50% initial SOC
    rating = 100.0,  # MW
    active_power = 0.0,
    input_active_power_limits = (min = 0.0, max = 100.0),
    output_active_power_limits = (min = 0.0, max = 100.0),
    efficiency = (in = 0.92, out = 0.92),
    reactive_power = 0.0,
    reactive_power_limits = (min = -50.0, max = 50.0),
    base_power = 100.0,
    operation_cost = storage_cost,
)

add_component!(sys, battery)

# =============================================================================
# Display system summary
# =============================================================================

println("\n" * "="^60)
println("System Summary")
println("="^60)
println(sys)

println("\n" * "="^60)
println("Component Counts")
println("="^60)
for type in (
    ACBus,
    ThermalStandard,
    Line,
    TwoTerminalGenericHVDCLine,
    PowerLoad,
    RenewableDispatch,
    EnergyReservoirStorage,
)
    println(rpad(string(nameof(type)) * ":", 28), length(get_components(type, sys)))
end

println("\n" * "="^60)
println("Thermal Generators")
println("="^60)
for gen in get_components(ThermalStandard, sys)
    active_power = get_active_power(gen, NU)
    println("  $(get_name(gen)): $active_power at $(get_name(get_bus(gen)))")
end

println("\n" * "="^60)
println("HVDC Lines")
println("="^60)
for hvdc in get_components(TwoTerminalHVDC, sys)
    println("  $(get_name(hvdc)): $(get_name(get_arc(hvdc)))")
end

# =============================================================================
# Optional: Save system to JSON
# =============================================================================

# Uncomment to save the system
# to_json(sys, "example_system.json")
# println("\nSystem saved to example_system.json")
