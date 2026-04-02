using Pkg
using Literate
using DataFrames
using PrettyTables

# Override show for DataFrames to limit output size during doc builds
# This ensures large DataFrames are truncated when displayed as expression results in @example blocks
# Explicit show() calls in tutorials with their own arguments are NOT affected (they use their own kwargs)
# We override both text/plain and text/html since Documenter may use either
# 
# Strategy: Call PrettyTables.pretty_table directly with explicit row/column limits.
# This bypasses DataFrames' default display logic and gives us full control.

function Base.show(io::IO, mime::MIME"text/plain", df::DataFrame)
    # Call PrettyTables directly with row/column limits
    # This ensures only 10 rows are shown regardless of DataFrame size
    PrettyTables.pretty_table(io, df;
        backend = :text,
        maximum_number_of_rows = 10,
        maximum_number_of_columns = 80,
        show_omitted_cell_summary = true,
        compact_printing = false,
        limit_printing = true)
end

function Base.show(io::IO, mime::MIME"text/html", df::DataFrame)
    # For HTML output (which Documenter prefers for large outputs)
    # Use PrettyTables HTML backend with explicit row/column limits
    PrettyTables.pretty_table(io, df;
        backend = :html,
        maximum_number_of_rows = 10,
        maximum_number_of_columns = 80,
        show_omitted_cell_summary = true,
        compact_printing = false,
        limit_printing = true)
end

# Function to clean up old generated files
function clean_old_generated_files(dir::String)
    if !isdir(dir)
        @warn "Directory does not exist: $dir"
        return
    end
    generated_files = filter(
        f -> startswith(f, "generated_") && (endswith(f, ".md") || endswith(f, ".ipynb")),
        readdir(dir),
    )
    for file in generated_files
        rm(joinpath(dir, file); force = true)
        @info "Removed old generated file: $file"
    end
end

#########################################################
# Literate post-processing functions for tutorial generation
#########################################################

# postprocess function to insert md
function insert_md(content)
    m = match(r"APPEND_MARKDOWN\(\"(.*)\"\)", content)
    if !isnothing(m)
        md_content = read(m.captures[1], String)
        content = replace(content, r"APPEND_MARKDOWN\(\"(.*)\"\)" => md_content)
    end
    return content
end

# Default display titles for Documenter admonition types when no custom title is given.
# See https://documenter.juliadocs.org/stable/showcase/#Admonitions
const _ADMONITION_DISPLAY_NAMES = Dict{String, String}(
    "note" => "Note",
    "info" => "Info",
    "tip" => "Tip",
    "warning" => "Warning",
    "danger" => "Danger",
    "compat" => "Compat",
    "todo" => "TODO",
    "details" => "Details",
)

# Preprocess Literate source to convert Documenter-style admonitions into Jupyter-friendly
# blockquotes. Used only for notebook output; markdown keeps `!!! type` and is rendered by
# Documenter. Admonitions are not recognized by common mark or Jupyter; see
# https://fredrikekre.github.io/Literate.jl/v2/tips/#admonitions-compatibility
function preprocess_admonitions_for_notebook(str::AbstractString)
    lines = split(str, '\n'; keepempty = true)
    out = String[]
    i = 1
    n = length(lines)
    admonition_start = r"^# !!! (note|info|tip|warning|danger|compat|todo|details)(?:\s+\"([^\"]*)\")?\s*$"
    content_line = r"^#     (.*)$"  # Documenter admonition body: # then 4 spaces
    blank_comment = r"^#\s*$"      # # or # with only spaces

    while i <= n
        line = lines[i]
        m = match(admonition_start, line)
        if m !== nothing
            typ = lowercase(m.captures[1])
            custom_title = m.captures[2]
            title = if custom_title !== nothing && !isempty(custom_title)
                custom_title
            else
                get(_ADMONITION_DISPLAY_NAMES, typ, titlecase(typ))
            end
            push!(out, "# > *$(title)*")
            push!(out, "# >")
            i += 1
            # Consume blank comment lines and content lines
            while i <= n
                l = lines[i]
                if match(blank_comment, l) !== nothing
                    push!(out, "# >")
                    i += 1
                elseif (cm = match(content_line, l)) !== nothing
                    push!(out, "# > " * cm.captures[1])
                    i += 1
                else
                    break
                end
            end
            continue
        end
        push!(out, line)
        i += 1
    end
    return join(out, '\n')
end

# Function to add download links to generated markdown
function add_download_links(content, jl_file, ipynb_file)
    # Add download links at the top of the file after the first heading
    download_section = """

*To follow along, you can download this tutorial as a [Julia script (.jl)]($(jl_file)) or [Jupyter notebook (.ipynb)]($(ipynb_file)).*

"""
    # Insert after the first heading (which should be the title)
    # Match the first heading line and replace it with heading + download section
    m = match(r"^(#+ .+)$"m, content)
    if m !== nothing
        heading = m.match
        content = replace(content, r"^(#+ .+)$"m => heading * download_section; count = 1)
    end
    return content
end

# Function to add Pkg.status() to notebook within the first markdown cell
function add_pkg_status_to_notebook(nb::Dict)
    cells = get(nb, "cells", [])
    if isempty(cells)
        return nb
    end

    # Find the first markdown cell
    first_markdown_idx = nothing
    for (i, cell) in enumerate(cells)
        if get(cell, "cell_type", "") == "markdown"
            first_markdown_idx = i
            break
        end
    end

    if first_markdown_idx === nothing
        return nb  # No markdown cell found, return unchanged
    end

    first_cell = cells[first_markdown_idx]
    cell_source = get(first_cell, "source", [])

    # Convert source array to string to find the first heading
    source_text = join(cell_source)

    # Find the first heading (lines starting with #)
    heading_pattern = r"^(#+\s+.+?)$"m
    heading_match = match(heading_pattern, source_text)

    if heading_match === nothing
        return nb  # No heading found, return unchanged
    end

    # Capture Pkg.status() output at build time
    io = IOBuffer()
    Pkg.status(; io = io)
    pkg_status_output = String(take!(io))

    # Create the content to insert: blockquote "Set up" with setup instructions and pkg.status()
    # Blockquote title and body; hyperlinks for IJulia and create an environment
    preface_lines = [
        "\n",
        "> **Set up**\n",
        ">\n",
        "> To run this notebook, first install the Julia kernel for Jupyter Notebooks using [IJulia](https://julialang.github.io/IJulia.jl/stable/manual/installation/), then [create an environment](https://pkgdocs.julialang.org/v1/environments/) for this tutorial with the packages listed with `using <PackageName>` further down.\n",
        ">\n",
        "> This tutorial has demonstrated compatibility with these package versions. If you run into any errors, first check your package versions for consistency using `Pkg.status()`.\n",
        ">\n",
    ]

    # Format Pkg.status() output as a code block inside the blockquote
    pkg_status_lines = split(pkg_status_output, '\n'; keepempty = true)
    pkg_status_block = [" > ```\n"]
    for line in pkg_status_lines
        push!(pkg_status_block, " > " * line * "\n")
    end
    push!(pkg_status_block, " > ```\n", "\n")

    # Find the first heading line in the source array
    heading_line_idx = nothing
    for (i, line) in enumerate(cell_source)
        if match(heading_pattern, line) !== nothing
            heading_line_idx = i
            break
        end
    end

    if heading_line_idx === nothing
        return nb  # Couldn't find heading line
    end

    # Build new source array
    new_source = String[]
    # Add all lines up to and including the heading line
    for i in 1:heading_line_idx
        push!(new_source, cell_source[i])
    end

    # Add the preface and pkg.status content right after the heading
    append!(new_source, preface_lines)
    append!(new_source, pkg_status_block)

    # Add all remaining lines after the heading
    for i in (heading_line_idx + 1):length(cell_source)
        push!(new_source, cell_source[i])
    end

    # Update the cell source
    first_cell["source"] = new_source
    cells[first_markdown_idx] = first_cell

    nb["cells"] = cells
    return nb
end

# Add italicized "view online" comment after each image from ```@raw html ... ``` (or
# the raw HTML / markdown form Literate writes). Used as a postprocess in Literate.notebook.
# Expects _DOCS_BASE_URL to be defined by the includer (e.g. in make.jl).
# Literate strips the backtick wrapper and outputs raw HTML; we match that multi-line block.
function add_image_links(nb::Dict, outputfile_base::AbstractString)
    tutorial_url = "$_DOCS_BASE_URL/tutorials/$(outputfile_base)/"
    msg = "_If image is not available when viewing in a Jupyter notebook, view the tutorial online [here]($tutorial_url)._"
    cells = get(nb, "cells", [])
    for (idx, cell) in enumerate(cells)
        get(cell, "cell_type", "") != "markdown" && continue
        source = get(cell, "source", [])
        isempty(source) && continue
        text = join(source)
        # Check if this cell already has the "view online" message to avoid duplicates
        contains(text, "If image is not available when viewing in a Jupyter notebook") &&
            continue
        suffix = "\n\n" * msg * "\n"
        append_after = m -> string(m) * suffix
        # Use a single non-overlapping regex to match image-containing fragments:
        # - <p...>...<img...>...</p> (Literate raw HTML paragraphs)
        # - ```@raw html ... ``` blocks
        # - Markdown images ![...](...)
        # - standalone <img> tags (only if not already matched by <p> wrapper)
        text = replace(
            text,
            r"(?:<p[^>]*>[\s\S]*?<img[\s\S]*?</p>|```@raw html[\s\S]*?```|!\[[^\]]*\]\([^\)]*\)|<img[^>]*?/?>)" =>
                append_after,
        )
        # Convert back to notebook source array (lines, last without trailing \n if non-empty)
        lines = split(text, "\n"; keepempty = true)
        new_source = String[]
        for i in 1:length(lines)
            if i < length(lines)
                push!(new_source, lines[i] * "\n")
            else
                isempty(lines[i]) || push!(new_source, lines[i])
            end
        end
        cell["source"] = new_source
        cells[idx] = cell
    end
    nb["cells"] = cells
    return nb
end

#########################################################
# Process tutorials with Literate
#########################################################

# Markdown files are postprocessed to add download links for the Julia script and Jupyter notebook
# Jupyter notebooks are postprocessed to add image links and pkg.status()
function make_tutorials()
    # Exclude helper scripts that start with "_"
    if isdir("docs/src/tutorials")
        tutorial_files =
            filter(
                x -> occursin(".jl", x) && !startswith(x, "_"),
                readdir("docs/src/tutorials"),
            )
        if !isempty(tutorial_files)
            # Clean up old generated tutorial files
            tutorial_outputdir = joinpath(pwd(), "docs", "src", "tutorials")
            clean_old_generated_files(tutorial_outputdir)

            for file in tutorial_files
                @show file
                infile_path = joinpath(pwd(), "docs", "src", "tutorials", file)
                execute =
                    if occursin("EXECUTE = TRUE", uppercase(readline(infile_path)))
                        true
                    else
                        false
                    end
                execute && include(infile_path)

                outputfile = string("generated_", replace("$file", ".jl" => ""))

                # Generate markdown
                Literate.markdown(infile_path,
                    tutorial_outputdir;
                    name = outputfile,
                    credit = false,
                    flavor = Literate.DocumenterFlavor(),
                    documenter = true,
                    postprocess = (
                        content -> add_download_links(
                            insert_md(content),
                            file,
                            string(outputfile, ".ipynb"),
                        )
                    ),
                    execute = execute)

                # Generate notebook (chain add_image_links after add_pkg_status_to_notebook).
                # preprocess_admonitions_for_notebook converts Documenter admonitions to blockquotes
                # so they render in Jupyter; markdown output keeps !!! style for Documenter.
                Literate.notebook(infile_path,
                    tutorial_outputdir;
                    name = outputfile,
                    credit = false,
                    execute = false,
                    preprocess = preprocess_admonitions_for_notebook,
                    postprocess = nb -> add_image_links(add_pkg_status_to_notebook(nb), outputfile))
            end
        end
    end
end
