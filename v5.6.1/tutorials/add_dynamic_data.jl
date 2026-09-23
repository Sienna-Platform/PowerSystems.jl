# # Adding Data for Dynamic Simulations
# In this tutorial, we are going to add dynamic data to a power [`System`](@ref), including
# a dynamic generator suitable for phasor-type simulations, as well as a dynamic inverter
# and dynamic lines necessary for more complex EMT (electro-magnetic transient)
# simulations.
# To run a dynamic simulation in Sienna\Dyn using
# [`PowerSimulationsDynamics.jl`](https://nrel-sienna.github.io/PowerSimulationsDynamics.jl/stable/),
# two data layers are required:
#  1. A base layer of [static](@ref S) components, which includes the data needed to run a
#     power flow problem
#  2. An additional layer of [dynamic](@ref D) components, which define differential equations
#     to run a transient simulation
# We'll define these two layers sequentially.

# ## Defining the Static Data Layer
# Instead of defining the static data in the [`System`](@ref) manually, we will load an existing three-bus system using
# [`PowerSystemCaseBuilder.jl`](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl)
# to use as a starting point.
# Start by importing these packages:

using PowerSystems
using PowerSystemCaseBuilder
import PowerSystems as PSY;

# To create the system, load pre-existing data for a 3-bus system using
# `PowerSystemCaseBuilder.jl`:

threebus_sys = build_system(PSIDSystems, "3 Bus Inverter Base")

# See that there is a table of "[Static](@ref S) Components", which contains the
# steady state data needed for power flow analysis, but no "[Dynamic](@ref D)" data
# yet to define the differential equations for transient simulations.
# Let's view the generators in the system with [`show_components`](@ref),
# including which bus they are connected at:

show_components(ThermalStandard, threebus_sys, [:bus])

# Notice that there are generators connected at Buses 2 and 3, but not Bus 1.
# Now, we are going to add the data needed to run an EMT simulation.
# We will add an infinite voltage source to Bus 1, which is the last component we
# need to complete the static data layer. Then, we will add a dynamic
# generator or inverter model to the two generators, as well as adding dynamic lines.

# ## Add an Infinite Voltage Source
# Add a infinite voltage source with small impedance to Bus 1 (the reference bus).
# First, retrieve the reference bus using [`get_components`](@ref):

slack_bus = first(get_components(x -> get_bustype(x) == ACBusTypes.REF, Bus, threebus_sys))

# Notice we filtered by the [bus type](@ref acbustypes_list) to get the bus(es) we wanted.
# Next, manually define a [`Source`](@ref):

inf_source = Source(;
    name = "InfBus", #name
    available = true, #availability
    active_power = 0.0,
    reactive_power = 0.0,
    bus = slack_bus, #bus
    R_th = 0.0, #Rth
    X_th = 5e-6, #Xth
);

# And add it to the system:

add_component!(threebus_sys, inf_source)

# This completes the first layer of [static](@ref S) data, using components similar to those
# we added manually in the [Create and Explore a Power `System`](@ref) tutorial.

# ## Adding a Dynamic Generator
# Now, we will connect a classic machine model to the generator at bus 102.
# Dynamic generator devices
# are composed by 5 components: a [Machine](@ref Machine),
# [Shaft](@ref Shaft), [Automatic Voltage Regulator](@ref AVR) (AVR),
# [Power System Stabilizer](@ref PSS) (PSS), and
# [Prime Mover and Turbine Governor](@ref TurbineGov).
# For each of those 5 components, we will select a specific model that defines the data and
# differential equations for that component,
# and then use those 5 components to define the complete dynamic generator.
# ```@raw html
# <img src="../../assets/gen_metamodel.png" width="75%"/>
# ```
# !!! note
#     When defining dynamic data, by convention `PowerSystems.jl` assumes that all data is
#     in [`DEVICE_BASE`](@ref per_unit).
# First, define a [Machine](@ref Machine) that describes the stator electro-magnetic dynamics:

machine_oneDoneQ = OneDOneQMachine(;
    R = 0.0,
    Xd = 1.3125,
    Xq = 1.2578,
    Xd_p = 0.1813,
    Xq_p = 0.25,
    Td0_p = 5.89,
    Tq0_p = 0.6,
)

# Notice that we selected a specific model, [`OneDOneQMachine`](@ref), with the parameters
# tailored to a One-d-one-q dynamic machine model.
# Next, define a specific [Shaft](@ref Shaft) model, [`SingleMass`](@ref) that describes the
# rotor electro-mechanical dynamics:

shaft_no_damping = SingleMass(;
    H = 3.01, #(M = 6.02 -> H = M/2)
    D = 0.0,
)

# Represent the electromotive dynamics of the AVR controller using a specific
# [Automatic Voltage Regulator](@ref AVR) model, [`AVRTypeI`](@ref):

avr_type1 = AVRTypeI(; # Type I: Resembles a DC1 AVR
    Ka = 20.0,
    Ke = 0.01,
    Kf = 0.063,
    Ta = 0.2,
    Te = 0.314,
    Tf = 0.35,
    Tr = 0.001,
    Va_lim = (min = -5.0, max = 5.0),
    Ae = 0.0039, #1st ceiling coefficient
    Be = 1.555, #2nd ceiling coefficient
)

# Define a fixed efficiency [Prime Mover and Turbine Governor](@ref TurbineGov) with
# [`TGFixed`](@ref):

tg_none = TGFixed(; efficiency = 1.0) # No Turbine Governor

# See that we are modeling a machine that does not include a Turbine Governor
# (or PSS below), but you must define components for them to build a
# complete machine model.
# Similarly, define a PSS using [`PSSFixed`](@ref), which is used to describe the stabilization
# signal for the AVR:

pss_none = PSSFixed(; V_pss = 0.0) # No PSS

# Now, we are ready to add a dynamic generator to the static
# generator at bus 102. First, let's get that static generator:

static_gen = get_component(Generator, threebus_sys, "generator-102-1")

# Notice that its `dynamic_injector` field is currently `nothing`.
# Use its name and the 5 components above to define its [`DynamicGenerator`](@ref) model:

dynamic_gen = DynamicGenerator(;
    name = get_name(static_gen),
    ω_ref = 1.0, # frequency reference set-point
    machine = machine_oneDoneQ,
    shaft = shaft_no_damping,
    avr = avr_type1,
    prime_mover = tg_none,
    pss = pss_none,
)

# See that the specific component models that we selected and defined above were used to
# specify the states needed to model this generator in a dynamic simulation.
# Finally, use the dynamic version of [`add_component!`](@ref add_component!(
# sys::System,
# dyn_injector::DynamicInjection,
# static_injector::StaticInjection;
# kwargs...,
# )) to add this data to the [`System`](@ref):

add_component!(threebus_sys, dynamic_gen, static_gen)

# Notice that unlike static components, which are just added to the [`System`](@ref),
# this dynamic component is added to a specific static component within the [`System`](@ref).
# !!! tip
#     To define identical dynamic devices for multiple generators at once, define the pieces of the
#     generator model as *functions*, such as:
#     ```
#     avr_type1() = AVRTypeI(...
#     ```
#     When called in the [`DynamicGenerator`](@ref) constructor, this will create a new AVR for each generator, so
#     they are different in memory. Later, if you decide to modify the AVR parameters for
#     a specific generator, it will not modify the AVR in another generator.
# Recall that you can print the system to see a summary of its data:

threebus_sys

# See that a new table has been added: "Dynamic Components."
# Also, print the static generator to double-check the dynamic layer has been added:

static_gen

# Verify that `dynamic_injector` now contains our dynamic generator model.
# Up to this point, you have added the dynamic data necessary to do a phaser-type simulation,
# which focuses on machine behavior. Now we will also add dynamic inverters and lines to enable
# EMT simulations.

# ## Adding a Dynamic Inverter
# Next we will connect a Virtual Synchronous Generator Inverter at bus 103.
# An inverter is composed of [Converter](@ref), [OuterControl](@ref), [InnerControl](@ref),
# [DCSource](@ref), [FrequencyEstimator](@ref), and [Filter](@ref) components:
# ```@raw html
# <img src="../../assets/inv_metamodel.png" width="75%"/>
# ```
# As we did for the generator, we will define each of these six components with a specific
# model, which defines its differential equations.
# First, define an [`AverageConverter`](@ref) as the specific model for the [Converter](@ref)
# component:

converter_high_power() = AverageConverter(;
    rated_voltage = 138.0,
    rated_current = 100.0,
)

# Recall from the tip above that we can define these components as *functions* instead of
# objects for reusability across multiple generators, and notice that that is what we have
# done here.
# Define [OuterControl](@ref) using [Virtual Inertia](@ref) for the active power control and
# [ReactivePowerDroop](@ref) for the reactive power control:

outer_control() = OuterControl(
    VirtualInertia(; Ta = 2.0, kd = 400.0, kω = 20.0),
    ReactivePowerDroop(; kq = 0.2, ωf = 1000.0),
)

# Define an [InnerControl](@ref) as a Voltage+Current Controller with Virtual Impedance,
# using [`VoltageModeControl`](@ref):

inner_control() = VoltageModeControl(;
    kpv = 0.59,     #Voltage controller proportional gain
    kiv = 736.0,    #Voltage controller integral gain
    kffv = 0.0,     #Binary variable enabling voltage feed-forward in current controllers
    rv = 0.0,       #Virtual resistance in pu
    lv = 0.2,       #Virtual inductance in pu
    kpc = 1.27,     #Current controller proportional gain
    kic = 14.3,     #Current controller integral gain
    kffi = 0.0,     #Binary variable enabling the current feed-forward in output of current controllers
    ωad = 50.0,     #Active damping low pass filter cut-off frequency
    kad = 0.2,      #Active damping gain
)

# Define a [`FixedDCSource`](@ref) for the [DCSource](@ref):

dc_source_lv() = FixedDCSource(; voltage = 600.0)

# Define a [FrequencyEstimator](@ref) as a phase-locked loop (PLL) using [`KauraPLL`](@ref):

pll() = KauraPLL(;
    ω_lp = 500.0, #Cut-off frequency for LowPass filter of PLL filter.
    kp_pll = 0.084,  #PLL proportional gain
    ki_pll = 4.69,   #PLL integral gain
)

# Finally, define an [`LCLFilter`](@ref) for the [Filter](@ref):

filt() = LCLFilter(;
    lf = 0.08,
    rf = 0.003,
    cf = 0.074,
    lg = 0.2,
    rg = 0.01,
)

# Now, use those six functions to define a complete dynamic inverter
# by getting the static component at bus 103:

gen_103 = get_component(Generator, threebus_sys, "generator-103-1");

# using it and our six functions to define a [`DynamicInverter`](@ref):

dynamic_inv = DynamicInverter(;
    name = get_name(gen_103),
    ω_ref = 1.0, # frequency reference set-point
    converter = converter_high_power(),
    outer_control = outer_control(),
    inner_control = inner_control(),
    dc_source = dc_source_lv(),
    freq_estimator = pll(),
    filter = filt(),
)

# and adding it to the [`System`](@ref):

add_component!(threebus_sys, dynamic_inv, gen_103)

# Both generators have now been updated with dynamic data. Let's complete the [`System`](@ref)
# updates by adding dynamic lines.

# ## Adding Dynamic Lines
# !!! warning
#     A [`System`](@ref) must have at least two buses and one branch to run a dynamic simulation in
#     [`PowerSimulationsDynamics.jl`](https://nrel-sienna.github.io/PowerSimulationsDynamics.jl/stable/).
# Let's review the AC branches currently in the system:

get_components(ACBranch, threebus_sys)

# Notice that we have three static [`Line`](@ref) components.
# Let's also print the first line to review its format:

first(get_components(Line, threebus_sys))

# See that these components do not have the fields for dynamic modeling, such as fields for
# different [states](@ref S).
# Let's update that by cycling through these lines and using [`DynamicBranch`](@ref) to extend
# each static line with the necessary fields:

for l in get_components(Line, threebus_sys)
    ## create a dynamic branch
    dyn_branch = DynamicBranch(l)
    ## add dynamic branch to the system, replacing the static branch
    add_component!(threebus_sys, dyn_branch)
end

# Take a look at the AC branches in the system again:

branches = get_components(ACBranch, threebus_sys)

# Notice that now there are 3 [`DynamicBranch`](@ref) components instead of the `Line` components.
# Let's take a look by printing the first one:

first(branches)

# Observe that this is a wrapper around the static data, with the additional states
# data for dynamic modeling.
# Finally, let's print the [`System`](@ref) again to summarize our additions:

threebus_sys

# Verify that the additions were successful, with an added voltage [`Source`](@ref), [`DynamicBranch`](@ref)es
# replacing the static [`Line`](@ref), and two new dynamic components with the generator and inverter models.

# ## Next Steps
# In this tutorial, you have updated a static system with a second dynamic data layer.
# The data you added can enable a phasor-based simulation using the dynamic generator, or
# a more complex EMT simulation with the additional dynamic inverter and dynamic lines.
# Next, you might like to:
#   - Read more about the static and dynamic data layers and the dynamic data format in
#     [Dynamic Devices](@ref).
#   - Review the specific subsystem models available in `PowerSystems.jl` for [Machine](@ref),
#     [Shaft](@ref), [AVR](@ref), [PSS](@ref),
#     [Prime Mover and Turbine Governor](@ref TurbineGov), [Converter](@ref),
#     [OuterControl](@ref), [InnerControl](@ref), [DCSource](@ref),
#     [FrequencyEstimator](@ref), and [Filter](@ref) components
#   - Explore [`PowerSimulationsDynamics.jl`](https://nrel-sienna.github.io/PowerSimulationsDynamics.jl/stable/)
#     for dynamics modeling in Sienna\Dyn
