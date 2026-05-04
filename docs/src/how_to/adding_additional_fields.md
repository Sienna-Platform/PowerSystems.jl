# [Add additional data to a component](@id additional_fields)

All `PowerSystems.jl` components have an `ext` field that contains an empty `Dictionary`.
This Dictionary is useful to contain additional required data where there is no need to
create new behaviors with that data. A simple example is the addition of geographic
information, if needed.

#### Example

```@setup generated_adding_additional_fields
using PowerSystems #hide
using PowerSystemCaseBuilder #hide
system = build_system(PSISystems, "modified_RTS_GMLC_DA_sys"); #hide
```

__Step 1:__ Use `get_ext` to get the `ext` field of the desired components and assign your data:

```@example generated_adding_additional_fields
for g in get_components(ThermalStandard, system)
    external_field = get_ext(g)
    external_field["my_data"] = 1.0
end
```

Here, we added additional data called `my_data` to the [`ThermalStandard`](@ref)
generators in a previously defined [`System`](@ref).

__Step 2:__ Retrieve your data using `get_ext` again

First, retrieve the first [`ThermalStandard`](@ref "ThermalStandard") generator:

```@example generated_adding_additional_fields
gen = collect(get_components(ThermalStandard, system))[1];
```

Then, retrieve `my_data` from the generator and verify it is 1.0, as assigned.

```@example generated_adding_additional_fields
retrieved_data = get_ext(gen)["my_data"]
```
