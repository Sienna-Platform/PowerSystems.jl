# # Adding additional fields
#
# All components currently implemented in `PowerSystems.jl` have an `ext` field that contains
# an empty `Dictionary`. This empty dictionary can be accessed with the method `get_ext`.
# shows an example of adding additional data to the [`ThermalStandard`](@ref) structs for other
# modeling requirements.

# This method is useful if there is no requirement to create new behaviours for components of
# a particular type but additional fields are required. A simple example is the addition of geographic information if needed.

using PowerSystems
const PSY = PowerSystems

DATA_DIR = "../../../data" #hide
system = System(joinpath(DATA_DIR, "matpower/case5_re.m"))

for g in get_components(ThermalStandard, system)
    external_field = get_ext(g)
    external_field["my_data"] = 1.0
end

gen_alta = get_component(ThermalStandard, system, "Alta")

my_data = get_ext(gen_alta)["my_data"]
