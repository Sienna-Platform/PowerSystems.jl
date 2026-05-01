@info "Generating Validation Table"
function generate_validation_table(filepath::AbstractString)
    descriptor = InfrastructureSystems.read_validation_descriptor(
        joinpath(PSYPATH, "descriptors", "power_system_structs.json"),
    )
    open(filepath, "w") do io
        write(io, "# Data Requirements\n\n")
        write(
            io,
            "|  Struct Name  |  Field Name  |  DataType  |  Min  |  Max  |  Action  |\n",
        )
        write(
            io,
            "|---------------|--------------|------------|-------|-------|----------|\n",
        )
        for item in descriptor
            for field in item["fields"]
                write(io, "|$(item["struct_name"])|$(field["name"])|$(field["data_type"])|")
                if haskey(field, "valid_range")
                    if field["valid_range"] isa Dict
                        valid_min = field["valid_range"]["min"]
                        valid_max = field["valid_range"]["max"]
                        for value in (valid_min, valid_max)
                            write(io, isnothing(value) ? "null" : string(value))
                            write(io, "|")
                        end
                    else
                        write(io, "$(field["valid_range"])|$(field["valid_range"])|")
                    end
                else
                    write(io, "-|-")
                end
                if haskey(field, "validation_action")
                    write(io, "$(field["validation_action"])|\n")
                else
                    write(io, "|-\n")
                end
            end
        end
    end
end

generate_validation_table(joinpath(PSYPATH, "../docs/src/man/data_requirements_table.md"))
