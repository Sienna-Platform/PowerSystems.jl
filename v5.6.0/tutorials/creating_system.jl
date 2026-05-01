# # Create and Explore a Power `System`
# Welcome to PowerSystems.jl!
# In this tutorial, we will create a power system and add some components to it,
# including some nodes, a transmission line, load, and both renewable
# and fossil fuel generators. Then we will retrieve data from the system and explore the
# system settings.

# ## Setup
# To get started, ensure you have followed the
# [installation instructions](https://nrel-sienna.github.io/Sienna/SiennaDocs/docs/build/how-to/install/).
# Start Julia from the command line if you haven't already:
# ```
# $ julia
# ```
# Load the PowerSystems.jl package:

using PowerSystems

# ## Creating a Power [`System`](@ref)
# In PowerSystems.jl, data is held in a [`System`](@ref) that holds all of the individual components
# along with some metadata about the power system itself.
# There are many ways to define a [`System`](@ref), but let's start with an empty system.
# All we need to define is a base power of 100 MVA for [per-unitization](@ref per_unit).

sys = System(100.0)

# Notice that this system is a 60 Hz system with a base power of 100 MVA.
# Now, let's add some components to our system.

# ## Adding Buses
# We'll start by creating some buses. By referring to the documentation for
# [ACBus](@ref), notice that we need define some basic data, including the bus's
# unique identifier and name, base voltage, and whether it's a [load, generator,
# or reference bus](@ref acbustypes_list).
# Let's start with a reference bus:

bus1 = ACBus(;
    number = 1,
    name = "bus1",
    available = true,
    bustype = ACBusTypes.REF,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.9, max = 1.05),
    base_voltage = 230.0,
);

# This bus is on a 230 kV AC transmission network, with an allowable voltage range of
# 0.9 to 1.05 p.u. We are assuming it is currently operating at 1.0 p.u. voltage and
# an angle of 0 radians. Notice that we've defined this bus as [reference bus or slack
# bus](@ref acbustypes_list), where it will be used for balancing power flow in power
# flow studies.
# Let's add this bus to our [`System`](@ref) with [`add_component!`](@ref add_component!(sys::System, component::Component; kwargs...)):

add_component!(sys, bus1)

# We can see the impact this has on the [`System`](@ref) simply by printing it:

sys

# Notice that [`System`](@ref) now shows a summary of components in the system. The table shows
# "[Static](@ref S) Components", which refers to steady state data used for power
# flow analysis or production cost modeling, as opposed to [Dynamic](@ref D) components
# which that can be used to define differential equations for transient simulations.
# Let's create a second bus:

bus2 = ACBus(;
    number = 2,
    name = "bus2",
    available = true,
    bustype = ACBusTypes.PV,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.9, max = 1.05),
    base_voltage = 230.0,
);

# Notice that we've defined this bus with [power and voltage variables](@ref acbustypes_list),
# suitable for power flow studies.
# Let's also add this to our [`System`](@ref):

add_component!(sys, bus2)

# Now, let's use [`show_components`](@ref) to quickly see some basic information about the buses:

show_components(sys, ACBus)

# ## Adding a Transmission Line
# Let's connect our buses. We'll add a transmission [`Line`](@ref) between `bus1` and `bus2`.
# !!! warning
#     When defining a line that isn't attached to a [`System`](@ref) yet, you must define the
#     thermal rating of the transmission line in per-unit using the base power of the
#     [`System`](@ref) you plan to connect it to -- in this case, 100 MVA.

line = Line(;
    name = "line1",
    available = true,
    active_power_flow = 0.0,
    reactive_power_flow = 0.0,
    arc = Arc(; from = bus1, to = bus2),
    r = 0.00281, # Per-unit
    x = 0.0281, # Per-unit
    b = (from = 0.00356, to = 0.00356), # Per-unit
    rating = 2.0, # Line rating of 200 MVA / System base of 100 MVA
    angle_limits = (min = -0.7, max = 0.7),
);

# Note that we also had to define an [`Arc`](@ref) in the process to define the connection between
# the two buses.
# Let's also add this to our [`System`](@ref):

add_component!(sys, line)

# Finally, let's check our [`System`](@ref) summary to see all the network topology components we have added
# are attached:

sys

# ## Adding Loads and Generators
# Now that our network topology is complete, we'll start adding components that [inject](@ref I) or
# withdraw power from the network.
# !!! warning
#     When you define components that aren't attached to a [`System`](@ref) yet, you must define
#     all fields related to power (with units such as MW, MVA, MVAR, or MW/min) in
#     per-unit using the `base_power` of the component (with the exception of `base_power`
#     itself, which is in MVA).
# We'll start with defining a 10 MW [load](@ref PowerLoad) to `bus2`:

load = PowerLoad(;
    name = "load1",
    available = true,
    bus = bus2,
    active_power = 0.5, # Per-unitized by device base_power
    reactive_power = 0.0, # Per-unitized by device base_power
    base_power = 10.0, # MVA
    max_active_power = 1.0, # 10 MW per-unitized by device base_power
    max_reactive_power = 0.0,
);

# Notice that we defined the `max_active_power`, which is 10 MW, as 1.0 in per-unit using the
# `base_power` of 10 MVA. We've also used the `bus2` component itself to define where this
# load is located in the network.
# Now add the load to the system:

add_component!(sys, load)

# Finally, we'll add two generators: one renewable and one thermal.
# We'll add a 5 MW solar power plant to `bus2`:

solar = RenewableDispatch(;
    name = "solar1",
    available = true,
    bus = bus2,
    active_power = 0.2, # Per-unitized by device base_power
    reactive_power = 0.0, # Per-unitized by device base_power
    rating = 1.0, # 5 MW per-unitized by device base_power
    prime_mover_type = PrimeMovers.PVe,
    reactive_power_limits = (min = 0.0, max = 0.05), # 0 MVAR to 0.25 MVAR per-unitized by device base_power
    power_factor = 1.0,
    operation_cost = RenewableGenerationCost(nothing),
    base_power = 5.0, # MVA
);

# Note that we've used a generic [renewable generator](@ref RenewableDispatch) to model
# solar, but we can specify that it is solar through the [prime mover](@ref pm_list).
# Finally, we'll also add a 30 MW gas [thermal generator](@ref ThermalStandard) to `bus1`
# because a slack bus require a controllable generator component:

gas = ThermalStandard(;
    name = "gas1",
    available = true,
    status = true,
    bus = bus1,
    active_power = 0.0, # Per-unitized by device base_power
    reactive_power = 0.0, # Per-unitized by device base_power
    rating = 1.0, # 30 MW per-unitized by device base_power
    active_power_limits = (min = 0.2, max = 1.0), # 6 MW to 30 MW per-unitized by device base_power
    reactive_power_limits = nothing, # Per-unitized by device base_power
    ramp_limits = (up = 0.2, down = 0.2), # 6 MW/min up or down, per-unitized by device base_power
    operation_cost = ThermalGenerationCost(nothing),
    base_power = 30.0, # MVA
    time_limits = (up = 8.0, down = 8.0), # Hours
    must_run = false,
    prime_mover_type = PrimeMovers.CC,
    fuel = ThermalFuels.NATURAL_GAS,
);

# This time, let's add these components to our [`System`](@ref) using [`add_components!`](@ref)
# to add them both at the same time:

add_components!(sys, [solar, gas])

# ## Explore the System and its Components
# Congratulations! You have built a power system including buses, a transmission line, a
# load, and different types of generators. Now let's take a look around.
# Remember that we can see a summary of our [`System`](@ref) using the print statement:

sys

# Now, let's double-check some of our data by retrieving it from the [`System`](@ref).
# Let's use [`show_components`](@ref) again to get an overview of our renewable generators:

show_components(sys, RenewableDispatch)

# We just have the one renewable generator named `solar1`. Use `get_component` to
# retrieve it by name:

retrieved_component = get_component(RenewableDispatch, sys, "solar1");

# Let's double-check what type of renewable generator this is using a `get_` function:

get_prime_mover_type(retrieved_component)

# Verify that this a `PVe`, or solar photovoltaic, generator.
# Let's also use a `get_` function to double-check where this generator is connected in the
# transmission network:

get_bus(retrieved_component)

# See that the generator's bus is linked to the actual `bus2` component in our [`System`](@ref).
# These "getter" functions are available for all the data fields in a component.
# !!! tip
#     **Always use the `get_*` functions to retrieve the data within a component.**
#     While in Julia a user can use `.` to access the fields of a component, we make no
#     guarantees on the stability of field names and locations. We do however promise to
#     keep the getter functions stable. PowerSystems.jl also does many internal data
#     calculations that the getter functions will properly handle for you, as you'll see
#     below.

# ## Changing [`System`](@ref) Per-Unit Settings
# Now, let's use a getter function to look up the solar generator's `rating`:

get_rating(retrieved_component)

# !!! tip "Important"
#     When we defined the solar generator, we defined the rating
#     as 1.0 per-unit with a device `base_power` of 5.0 MVA. Notice that the rating now reads
#     0.05. After we attached this component to our [`System`](@ref), its power data is being
#     returned to us in the [`System`](@ref)'s units base.
# Let's double-check the [`System`](@ref)'s units base:

get_units_base(sys)

# `SYSTEM_BASE` means all power-related (MW, MVA, MVAR, MW/min) component data in
# the [`System`](@ref), except for each component's `base_power`, is per-unitized by the
# system base power for consistency.
# Check the [`System`](@ref)'s base_power again:

get_base_power(sys)

# Notice that when we called `get_rating` above, the solar generator's rating, 5.0 MW,
# is being returned as 0.05 = (5 MVA)/(100 MVA) using the system base power.
# Instead of using the [`System`](@ref) base power, let's view everything in MW or MVA -- or what we
# call "NATURAL_UNITS" in PowerSystems.
# Change the [`System`](@ref)'s unit system:

set_units_base_system!(sys, "NATURAL_UNITS")

# Now retrieve the solar generator's rating again:

get_rating(retrieved_component)

# Notice that the value is now its "natural" value, 5.0 MVA.
# Finally, let's change the [`System`](@ref)'s unit system to the final option, "DEVICE_BASE":

set_units_base_system!(sys, "DEVICE_BASE")

# And retrieve the solar generator's rating once more:

get_rating(retrieved_component)

# See that now the data is now 1.0 (5.0 MVA per-unitized by the generator (i.e., the device's)
# `base_power` of 5.0 MVA), which is the format we used to originally define the device.
# As a shortcut to temporarily set the [`System`](@ref)'s unit system to a particular value, perform
# some action, and then automatically set it back to what it was before, we can use
# `with_units_base` and a [`do` block](https://docs.julialang.org/en/v1/manual/functions/#Do-Block-Syntax-for-Function-Arguments):

with_units_base(sys, "NATURAL_UNITS") do
    ## Everything inside this block will run as if the unit system were NATURAL_UNITS
    get_rating(retrieved_component)
end
get_units_base(sys)  # Unit system goes back to previous value when the block ends

# Recall that if you ever need to check a [`System`](@ref)'s settings, including the unit system being
# used by all the getter functions, you can always just print the [`System`](@ref):

sys

# See the units base is printed as one of the [`System`](@ref) properties.

# ## Next Steps
# In this tutorial, you manually created a power [`System`](@ref), added and then retrieved its components,
# and modified the [`System`](@ref) per-unit settings.
# Next, you might want to:
#   - [Add time series data to components in the `System`](@ref tutorial_time_series)
#   - [Add necessary data for dynamic simulations](@ref "Adding Data for Dynamic Simulations")
#   - Import a [`System`](@ref) [from an existing Matpower or PSSE file](@ref pm_data) or
#     [with PSSE dynamic data](@ref dyr_data) instead of creating it manually
#   - [Create your own `System` from .csv files instead of creating it manually](@ref system_from_csv)
#   - [Read more to understand per-unitization in PowerSystems.jl](@ref per_unit)
#   - See a workaround for how to [Add a Component in Natural Units](@ref)
