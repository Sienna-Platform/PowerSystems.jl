using InteractiveUtils
import InfrastructureSystems as IS
import PowerSystems as PSY

function _clean_old_generated_files(dir::String)
    # Remove old generated_*.md files before creating new ones
    if !isdir(dir)
        @warn "Directory does not exist: $dir"
        return
    end
    generated_files = filter(f -> startswith(f, "generated_") && endswith(f, ".md"), readdir(dir))
    for file in generated_files
        rm(joinpath(dir, file), force=true)
        @info "Removed old generated file: $file"
    end
end

function _check_exception(T, exceptions::Vector)
    for type_exception in exceptions
        if T <: type_exception
            return true
        end
    end
    return false
end

function _write_first_level_markdown(c::String)
    file_name = "model_library/generated_$(c).md"
            open(joinpath("docs/src", file_name), "w") do io
                print(
                    io,
                    """
                    # $(c)

                    ```@autodocs
                    Modules = [PowerSystems]
                    Pages   = ["generated/$(c).jl"]
                    Order = [:type, :function]
                    Public = true
                    Private = false
                    ```
                    """,
                )
            end
    return file_name
end

function _write_second_level_markdown(input::DataType, subtypes::Vector{DataType}, exceptions)
    c = string(nameof(input))
    file_name = "model_library/generated_$(c).md"
            open(joinpath("docs/src", file_name), "w") do io
                print(io, "# $input\n\n")
                for T_ in subtypes
                    _check_exception(T_, exceptions) && continue
                    T = string(nameof(T_))
                    print(
                        io,
                        """
                        ## $(T)

                        ```@autodocs
                        Modules = [PowerSystems]
                        Pages   = ["/$(T).jl"]
                        Order = [:type, :function]
                        Public = true
                        Private = false
                        ```

                        """,
                    )
                end
            end
    return file_name
end

function make_dynamics_library!(model_library;
dyn_categories =[
    PSY.DynamicGeneratorComponent,
    PSY.DynamicInverterComponent,
],
exceptions = [],
manual_additions = Dict{String, Any}()
)
    for abstract_type in dyn_categories
        @info "Making entries for subtypes of $abstract_type"
        abstract_type_string = string(nameof(abstract_type))
        addition = Dict{String, Any}()
        internal_index = Any[]
        for c_ in subtypes(abstract_type)
            c_string = string(nameof(c_))
            _check_exception(c_, exceptions) && continue
            concretes = IS.get_all_concrete_subtypes(c_)
            file_name = _write_second_level_markdown(c_,
            concretes, exceptions)
            push!(internal_index, c_string => file_name)
        end
        push!(model_library, abstract_type_string => internal_index)
        if haskey(manual_additions, abstract_type_string)
            addition = get(manual_additions, abstract_type_string, nothing)
            push!(model_library[abstract_type_string], addition...)
        end
    end
end

function make_model_library(;
    categories = [],
    exceptions = [],
    manual_additions = Dict{String, Any}()
)
    # Clean up old generated files before creating new ones
    _clean_old_generated_files(joinpath("docs", "src", "model_library"))

    model_library = Dict{String, Any}()

    for abstract_type in categories
        @info "Making entries for subtypes of $abstract_type"
        internal_index = Any[]
        concrete = IS.get_all_concrete_subtypes(abstract_type)
        for c_ in concrete
            _check_exception(c_, exceptions) && continue
            c = string(nameof(c_))
            file_name = _write_first_level_markdown(c)
            push!(internal_index, c => file_name)
        end
        isempty(internal_index) && continue
        model_library[string(nameof(abstract_type))] = internal_index
    end

    make_dynamics_library!(model_library)

    for (k, v) in manual_additions
        if haskey(model_library, k)
            push!(model_library[k], v...)
        else
            model_library[k] = v
        end
    end

    return Any[p for p in model_library]
end
