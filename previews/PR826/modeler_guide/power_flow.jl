# # Power Flow

# `PowerSystems.jl` provides the capability to run a power flow with the intention of
# providing a valid initial AC operating point to the system.

# The power flow tool is not meant for analytics where the principal goal is to determine
# if the system has settings that produce a feasible AC solution. This power flow routine
# does not check for reactive power limits or other limiting mechanisms in the grid, and can
# therefore be used to check for solver convergence - making no guarantees
# of the solution feasibility.

# The power flow solver uses [NLsolve.jl](https://github.com/JuliaNLSolvers/NLsolve.jl) under
# the hood and takes any keyword argument accepted by NLsolve. The solver uses the current
# operating point in the buses to provide the initial guess.

# **Limitations**: The PowerFlow solver doesn't support systems with HVDC lines or
# Phase Shifting transformers yet. The power flow solver can't handle systems with islands.

# Check section [Power Flow](@ref pf) for detailed usage instructions

using PowerSystems
const PSY = PowerSystems

DATA_DIR = "../../../data" #hide
system_data = System(joinpath(DATA_DIR, "matpower/case14.m"))

# `PowerSystems.jl` has two modes of using the power flow solver.

# 1. Solving the power flow for the current operating point in the system.
#    Takes the data in the buses, the `active_power` and `reactive_power` fields
#    in the static injection devices. Returns a dictionary with results in a DataFrame that
#    can be exported or manipulated as needed.
#
# 2. Solves the power flow and updated the devices in the system to the operating condition.
#    This model will update the values of magnitudes and angles in the system's buses. It
#    also updates the active and reactive power flows in the branches and devices connected
#    to PV buses. It also updates the active and reactive power of the injection devices
#    connected to the Slack bus, and updates only the reactive power of the injection devices
#    connected to PV buses. If multiple devices are connected to the same bus, the power is 
#    divided proportional to the base power.
#    This utility is useful to initialize systems before serializing or checking the
#    addition of new devices is still AC feasible.

# Solving the power  flow with mode 1:

results = solve_powerflow(system_data)
results["bus_results"]

# Solving the power  flow with mode 2:

# Before running the power flow command these are the values of the
# voltages:

for b in get_components(Bus, system_data)
    println("$(get_name(b)) - Magnitude $(get_magnitude(b)) - Angle (rad) $(get_angle(b))")
end

# [`solve_powerflow!`](@ref) return true or false to signal the successful result of the power
# flow. This enables the integration of a power flow into functions and use the return as check.
# For instance, initializing dynamic simulations. Also, because [`solve_powerflow!`](@ref) uses
# [NLsolve.jl](https://github.com/JuliaNLSolvers/NLsolve.jl) all the parameters used for NLsolve
# are also available for [`solve_powerflow!`](@ref)

solve_powerflow!(system_data; finite_diff = true, method = :newton)

# After running the power flow command this are the values of the
# voltages:

for b in get_components(Bus, system_data)
    println("$(get_name(b)) - Magnitude $(get_magnitude(b)) - Angle (rad) $(get_angle(b))")
end
