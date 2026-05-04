@info "Generating Input Configuration Descriptor Table"
function create_md()
    descriptor = PowerSystems._read_config_file(
        joinpath(
            dirname(pathof(PowerSystems)),
            "descriptors",
            "power_system_inputs.json",
        ),
    )

    columns = [
        "name",
        "description",
        "unit",
        "unit_system",
        "base_reference",
        "default_value",
        "value_options",
        "value_range",
    ]
    header = "| " * join(columns, " | ") * " |\n" * repeat("|----", length(columns)) * "|\n"

    s = "## [`PowerSystemTableData` Accepted CSV Columns](@id tabledata_input_config) \n\n"
    s = string(
        s,
        "The following tables describe default CSV column definitions accepted by the ",
    )
    s = string(
        s,
        "`PowerSystemeTableData` parser defined by `src/descriptors/power_system_inputs.json`:\n\n",
    )
    for (cat, items) in descriptor
        csv = ""
        for name in PowerSystems.INPUT_CATEGORY_NAMES
            if name[2] == cat
                csv = name[1]
                break
            end
        end

        csv == "" && continue

        s = string(s, "### $csv.csv:\n\n")
        s = string(s, header)
        for item in items
            extra_cols = setdiff(keys(item), columns)
            if !isempty(extra_cols)
                # make sure that there aren't unexpected entries
                throw(@error "config file fields not included in header" extra_cols)
            end
            row = []
            for col in columns
                val = string(get(item, col, " "))
                if col == "default_value" && val == " "
                    val = "*REQUIRED*"
                end
                push!(row, val)
            end
            s = string(s, "|" * join(row, "|") * "|\n")
        end
        s = string(s, "\n")
    end
    s = replace(s, r"[_$]" => s"\\\g<0>")
    return s
end

txt = create_md()

open(
    "/Users/cbarrows/Documents/repos/PowerSystems.jl/docs/src/modeler_guide/markdown.txt",
    "w",
) do f
    write(f, txt)
end
