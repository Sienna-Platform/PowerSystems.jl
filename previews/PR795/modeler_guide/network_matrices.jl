# # Network Matrices

# `PowerSystems.jl` is able to build classic power systems modeling network matrices such as
# [Ybus](https://en.wikipedia.org/wiki/Nodal_admittance_matrix), [PTDF](https://www.powerworld.com/WebHelp/Content/MainDocumentation_HTML/Power_Transfer_Distribution_Factors.htm) and LODF

# Check section [Network Matrices](@ref net_mat) for more details

# ## Overview
#
# Network matrices are implemented in `PowerSystems.jl` as arrays that enable using Branch or Bus
# names as indexes to facilitate exploration and analysis. Ybus is stored as an SparseMatrix
# and the PTDF and LODF are stored as dense matrices. **Note*** Ybus is converted to a dense
# matrix for printing in the REPL,
# The network matrices code implements the Goderya algorithm to find islands.

using PowerSystems
const PSY = PowerSystems
DATA_DIR = "../../../data" #hide
system_data = System(joinpath(DATA_DIR, "matpower/case14.m"))

# ## Ybus
#
# The ybus can be calculated as follows:
ybus = Ybus(system_data)

# The matrix can be indexed using directly the bus numbers. In this example buses are numbered
# 1-14. However, in large systems buses don't usually follow sequential numbering. You can access
# the entries of the Ybus with direct indexing or using the buses.

ybus_entry = ybus[3,3]
#
bus3 = get_component(Bus, system_data, "Bus 3     HV")
ybus_entry = ybus[bus3, bus3]

# We recognize that many models require matrix operations. For those cases, you can access the
# sparse data as follows:

sparse_array = get_data(ybus)

# ## PTDF
#
# The PTDF matrix can be calculated as follows:
ptdf = PTDF(system_data)

# The entries of the matrix can also be indexed using the devices directly:
line = get_component(Line, system_data, "Bus 1     HV-Bus 2     HV-i_1")
bus = get_component(Bus, system_data, "Bus 3     HV")

ptdf_entry = ptdf[line, bus]

# Alternatively, the branch name and bus number can be used. For instance, for the same PTDF
# entry we can do:

ptdf_entry = ptdf["Bus 1     HV-Bus 2     HV-i_1", 3]

# PTDF also takes a vector of distributed slacks, for now this feature requires passing a
# vector of weights with the same number of elements are buses in the system. For more details
# check the API entry for [`PTDF`](@ref).

# In the same fashion as in the case of the Ybus, we recognize many models use matrix operations
# when using the PTDF matrix. The raw data is available using `get_data` and the lookup table
# between (names,numbers) and (i,j) matrix entries is available using [`get_lookup`](@ref)

branch_lookup, bus_lookup = get_lookup(ptdf);

# Branch lookup:

branch_lookup

# Bus Look up

bus_lookup

# ## LODF

# LODF and PTDF share the same characteristics in terms of indexing and calculation:

lodf = LODF(system_data)
