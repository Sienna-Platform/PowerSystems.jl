using Documenter, PowerSystems
import DataStructures: OrderedDict
using Literate
using DocumenterInterLinks
using DocumenterMermaid


links = InterLinks(
    "InfrastructureSystems" => "https://sienna-platform.github.io/InfrastructureSystems.jl/stable/",
    # Sometimes IS docstrings @extref to PSY, and sometimes those IS docstrings are included
    # in the PSY reference, so we can have PSY @extref-ing to itself:
    "PowerSystems" => "https://sienna-platform.github.io/PowerSystems.jl/stable/",
)

# This is a fallback for the docstrings that are referenced within IS docstrings
fallbacks = ExternalFallbacks(
    "add_supplemental_attribute!" => "@extref InfrastructureSystems.add_supplemental_attribute!",
    "remove_supplemental_attribute!" => "@extref InfrastructureSystems.remove_supplemental_attribute!",
    "ComponentContainer" => "@extref InfrastructureSystems.ComponentContainer",
    "ComponentUUIDs" => "@extref InfrastructureSystems.ComponentUUIDs",
    "InfrastructureSystemsComponent" => "@extref InfrastructureSystems.InfrastructureSystemsComponent",
    "InfrastructureSystemsInternal" => "@extref InfrastructureSystems.InfrastructureSystemsInternal",
    "PiecewiseLinearData" => "@extref InfrastructureSystems.PiecewiseLinearData",
    "SupplementalAttributeAssociations" => "@extref InfrastructureSystems.SupplementalAttributeAssociations",
    "SupplementalAttributeManager" => "@extref InfrastructureSystems.SupplementalAttributeManager",
    "SystemData" => "@extref InfrastructureSystems.SystemData",
    "TimeSeriesManager" => "@extref InfrastructureSystems.TimeSeriesManager",
    "TimeSeriesMetadata" => "@extref InfrastructureSystems.TimeSeriesMetadata",
    "TimeSeriesStorage" => "@extref InfrastructureSystems.TimeSeriesStorage",
    "get_uuid" => "@extref InfrastructureSystems.get_uuid",
)

# Replace DocumenterMermaid's loader script (issue #1812). Mermaid's bundle contains UMD code
# that registers with Documenter's RequireJS when it sees the global `define`, which breaks
# Mermaid itself everywhere and, in Safari, KaTeX too. So wait until RequireJS has finished
# loading (the `load` event), then hide `define` while Mermaid imports and renders.
function Documenter.HTMLWriter.domify(
    ::Documenter.HTMLWriter.DCtx,
    ::DocumenterMermaid.MarkdownAST.Node,
    ::DocumenterMermaid.MermaidScriptBlock,
)
    Documenter.DOM.@tags script
    script[:type => "module"]("""
    await new Promise(r => document.readyState === 'complete' ? r() : addEventListener('load', r));
    const amdDefine = window.define;
    window.define = undefined;
    try {
        const { default: mermaid } = await import('$(DocumenterMermaid.MERMAID)');
        mermaid.initialize({ startOnLoad: false, theme: "neutral" });
        await mermaid.run();
    } finally {
        window.define = amdDefine;
    }
    """)
end

# This is commented out because the output is not user-friendly. Deliberation on how to best
# communicate this information to users is ongoing.
#include(joinpath(@__DIR__, "src", "generate_validation_table.jl"))
include(joinpath(@__DIR__, "make_model_library.jl"))
include(joinpath(@__DIR__, "make_tutorials.jl"))

pages = OrderedDict(
        "Welcome Page" => "index.md",
        "Tutorials" =>  Any[
            "Create and Explore a Power `System`" => "tutorials/generated_creating_system.md",
            "Manipulating Data Sets" => "tutorials/generated_manipulating_datasets.md",
            "Working with Time Series" => "tutorials/generated_working_with_time_series.md",
            "Adding Data for Dynamic Simulations" => "tutorials/generated_add_dynamic_data.md",
        ],
        "How to..." =>  Any[
            "...import data" => Any[
                "Parse a MATPOWER or PSS/e file" => "how_to/parse_matpower_psse.md",
                "Parse PSS/e dynamic data" => "how_to/parse_dynamic_data.md",
                "Build a `System` using .csv files" => "how_to/build_system_with_files.md",
                "Save and read data with a JSON" => "how_to/serialize_data.md",
            ],
            "...add a component using natural units (MW)" => "how_to/add_component_natural_units.md",
            "...add time-series data" => Any[
                "Parse time series data from .csv files" => "how_to/parse_ts_from_csvs.md",
                "Improve performance with time series data" => "how_to/improve_ts_performance.md",
            ],
            "...add cost data" => Any[
                "Add an Operating Cost" => "how_to/add_cost_curve.md",
                "Add a market bid" => "how_to/market_bid_cost.md",
                "Add costs for imported/exported power" => "how_to/create_system_with_source_import_export_cost.md",
                "Add time series fuel costs" => "how_to/add_fuel_curve_timeseries.md",

            ],
            "...add supplemental data beyond component fields" => Any[
                "Attach supplemental data to components" => "how_to/add_supplemental_attributes.md",
                "Query contextual data on a system" => "how_to/use_supplemental_attributes.md",
                "Group generators into plants" => "how_to/group_generators_into_plants.md",
                "Model Outages" => "how_to/model_outages.md",
                "Add emissions to generators" => "how_to/add_emissions_to_generators.md",
                "Add custom data to a component" => "how_to/adding_additional_fields.md",
            ],
            "...read component values in different unit systems" => "how_to/convert_unit_systems.md",
            "...use subsystems" => "how_to/use_subsystems.md",
            "...use context managers for bulk operations" => "how_to/use_context_managers.md",
            "...customize or add a new Type" => "how_to/add_new_types.md",
            "...link hydro reservoirs and turbines" => "how_to/link_hydro_reservoirs_to_turbines.md",
            "...convert transformer impedances between per-unit bases" => "how_to/convert_transformer_impedance.md",
            "...use PowerSystems.jl with JuMP.jl" => "how_to/jump.md",
            "...reduce REPL printing" => "how_to/reduce_repl_printing.md",
            "...update to a new `PowerSystems.jl` version" => Any[
                "Migrate from version 4.0 to 5.0" => "how_to/migrating_to_psy5.md",
            ],
        ],
        "Explanation" =>
            Any[
            "explanation/system.md",
            "explanation/type_structure.md",
            "explanation/buses_type_explanation.md",
            "explanation/per_unit.md",
            "explanation/power_concepts.md",
            "explanation/time_series.md",
            "explanation/dynamic_data.md",
            "explanation/three_winding_transformers.md",
            "explanation/supplemental_attributes.md",
            "explanation/conforming_and_non_conforming_loads.md",
            "explanation/grouping_generators_into_plants.md",
            "explanation/hydro_reservoir_topology.md",
            "explanation/emissions_metadata.md",
            "explanation/outage_and_contingency_data.md",
            ],
        "Model Library" => Any[],
        "Reference" =>
            Any["Public API" => "reference/public.md",
            "Glossary and Acronyms" => "reference/glossary.md",
            "Type Tree" => "reference/type_tree.md",
            "`ValueCurve` Options" => "reference/valuecurve_options.md",
            "Supported PSS/e Models" => "reference/psse_models.md",
            "Comparison of Load, Generator, and Storage Types" => "reference/static_injection_subtypes.md",
            "Citation" => "reference/citation.md",
            "Developers" => ["Developer Guidelines" => "reference/developer_guidelines.md",
            "Internals" => "reference/internal.md"]
            ]
)

pages["Model Library"] = make_model_library(
     categories = [
        Topology,
        StaticInjection,
        Service,
        Branch,
        DynamicInjection,
    ],
    exceptions = [PSY.DynamicComponent,
                  PSY.ActivePowerControl,
                  PSY.ReactivePowerControl,
                  PSY.DynamicBranch,
                  PSY.HybridSystem,
                  PSY.OperationalCost,
                  PSY.DynamicInverter,
                  PSY.DynamicGenerator,
                  ],
    manual_additions =
        Dict("Service" => ["Reserves" => "model_library/reserves.md"],
        "StaticInjection" => ["HybridSystem" => "model_library/hybrid_system.md"],
        "DynamicInjection" => ["Dynamic Inverter" => "model_library/dynamic_inverter.md",
        "Dynamic Generator" => "model_library/dynamic_generator.md",
        ],
        "Branch" => ["Dynamic Lines" => "model_library/dynamic_branch.md"],
        "Operating Costs" => ["ThermalGenerationCost" =>"model_library/thermal_generation_cost.md",
        "HydroGenerationCost" =>"model_library/hydro_generation_cost.md",
        "HydroReservoirCost" =>"model_library/hydro_reservoir_cost.md",
        "RenewableGenerationCost" =>"model_library/renewable_generation_cost.md",
        "StorageCost" =>"model_library/storage_cost.md",
        "LoadCost" =>"model_library/load_cost.md",
        "MarketBidCost" =>"model_library/market_bid_cost.md",
        "ImportExportCost" =>"model_library/import_export_cost.md",
        "OfferCurveCost" =>"model_library/offer_curve_cost.md"],
        "HydroReservoir" => "model_library/hydro_reservoir.md",
        )
)

# clean_old_generated_files and insert_md are now defined in make_tutorials.jl
# They are used here for other sections (Model Library, Explanation, How to...)

# This code performs the automated addition of Literate - Generated Markdowns. The desired
# section name should be the name of the file for instance network_matrices.jl -> Network Matrices
julia_file_filter = x -> occursin(".jl", x)
folders = Dict(
    "Model Library" => filter(julia_file_filter, readdir("docs/src/model_library")),
    "Explanation" => filter(julia_file_filter, readdir("docs/src/explanation")),
    "How to..." => filter(julia_file_filter, readdir("docs/src/how_to")),
)

# Clean up old generated files in folders before Literate generates new ones
# Note: model_library is cleaned by make_model_library.jl before it generates files,
# so we only clean explanation and how_to directories here
for (section, folder) in folders
    # Skip model_library as it's already cleaned by make_model_library()
    section == "Model Library" && continue
    section_folder_name = lowercase(replace(section, " " => "_"))
    outputdir = joinpath(pwd(), "docs", "src", "$section_folder_name")
    clean_old_generated_files(outputdir)
end


# Process other sections (Model Library, Explanation, How to...)
for (section, folder) in folders
    for file in folder
        @show file
        section_folder_name = lowercase(replace(section, " " => "_"))
        inputfile = joinpath("$section_folder_name", "$file")
        infile_path = joinpath(pwd(), "docs", "src", inputfile)
        execute = occursin("EXECUTE = TRUE", uppercase(readline(infile_path))) ? true : false
        execute && include(infile_path)
        
        outputdir = joinpath(pwd(), "docs", "src", "$section_folder_name")
        outputfile = string("generated_", replace("$file", ".jl" => ""))
        
        # Generate markdown
        Literate.markdown(infile_path,
                          outputdir;
                          name = outputfile,
                          credit = false,
                          flavor = Literate.DocumenterFlavor(),
                          documenter = true,
                          postprocess = insert_md,
                          execute = execute)
        
        subsection = titlecase(replace(split(file, ".")[1], "_" => " "))
        push!(pages[section], ("$subsection" =>  joinpath("$section_folder_name", "$(outputfile).md")))
    end
end

# Process tutorials separately with Literate
make_tutorials()

makedocs(
    modules = [PowerSystems],
    format = Documenter.HTML(
        prettyurls = haskey(ENV, "GITHUB_ACTIONS"),
        size_threshold = nothing,),
    sitename = "PowerSystems.jl",
    authors = "Jose Daniel Lara, Daniel Thom, Kate Doubleday, Rodrigo Henriquez-Auba, and Clayton Barrows",
    pages = Any[p for p in pages],
    draft = false,
    plugins = [links, fallbacks],
)

deploydocs(
    repo = "github.com/Sienna-Platform/PowerSystems.jl.git",
    target = "build",
    branch = "gh-pages",
    devbranch = "main",
    devurl = "dev",
    push_preview=true,
    versions = ["stable" => "v^", "v#.#"],
)
