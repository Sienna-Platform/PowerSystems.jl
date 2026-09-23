# # Power Flow

# `PowerSystems.jl` provides the capability to run a power flow with the intention of providing a valid initial AC operating point to the system. It is not meant as an analytics tool; the main issue is to determine if the system has feasible AC data.

# The power flow solver uses [NLsolve.jl](https://github.com/JuliaNLSolvers/NLsolve.jl) under the hood and takes any keyword argument accepted by NLsolve

# ```@autodocs
# Modules = [PowerSystems]
# Pages = ["power_flow.jl"]
# Private = false
# ```
