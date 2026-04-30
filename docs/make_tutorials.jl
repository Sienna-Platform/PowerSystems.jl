using Pkg
using Literate
using DataFrames
using PrettyTables

# Limit DataFrame rendering during docs generation to avoid huge literal outputs.
# Notes:
# - Environment-variable approaches tested (`DATAFRAMES_ROWS`, `DATAFRAMES_COLUMNS`,
#   `LINES`, `COLUMNS`) did not constrain DataFrames output in this pipeline.
# - We keep a docs-local Base.show override as a fallback and accept `kwargs...`
#   so explicit show(...; kwargs) calls do not error on unsupported keywords.
function _env_int(name::String, default::Int)
    parsed = tryparse(Int, get(ENV, name, string(default)))
    return something(parsed, default)
end

const _DF_MAX_ROWS = _env_int("SIENNA_DOCS_DF_MAX_ROWS", 10)
const _DF_MAX_COLS = _env_int("SIENNA_DOCS_DF_MAX_COLS", 80)

function Base.show(io::IO, mime::MIME"text/plain", df::DataFrame; kwargs...)
    # Keep docs output bounded while allowing explicit caller kwargs.
    PrettyTables.pretty_table(io, df;
        backend = :text,
        maximum_number_of_rows = _DF_MAX_ROWS,
        maximum_number_of_columns = _DF_MAX_COLS,
        show_omitted_cell_summary = true,
        compact_printing = false,
        limit_printing = true,
        kwargs...)
end

function Base.show(io::IO, mime::MIME"text/html", df::DataFrame; kwargs...)
    PrettyTables.pretty_table(io, df;
        backend = :html,
        maximum_number_of_rows = _DF_MAX_ROWS,
        maximum_number_of_columns = _DF_MAX_COLS,
        show_omitted_cell_summary = true,
        compact_printing = false,
        limit_printing = true,
        kwargs...)
end

# Remove previously generated tutorial artifacts so a docs build only reflects
# current source tutorials.
#
# Input:
# - dir: tutorial output directory that can contain generated_*.md/ipynb.
# Output:
# - Deletes matching files in-place and logs each deletion.
function clean_old_generated_files(dir::String)
    if !isdir(dir)
        @warn "Directory does not exist: $dir"
        return
    end
    generated_files = filter(
        f ->
            startswith(f, "generated_") &&
                (endswith(f, ".md") || endswith(f, ".ipynb")),
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

# Compute docs base URL from Documenter deploy context.
#
# Behavior:
# - previews/PR123 -> .../previews/PR123
# - dev (or custom DOCUMENTER_DEVURL) -> .../dev
# - tagged versions like v0.9 -> .../v0.9
# - fallback -> .../stable
#
# This keeps generated download/view-online links correct across preview, dev,
# tagged, and stable deployments.
function _compute_docs_base_url()
    base = "https://nrel-sienna.github.io/PowerSystems.jl"

    current_version = get(ENV, "DOCUMENTER_CURRENT_VERSION", "")

    # Preview builds (e.g. "previews/PR123")
    if startswith(current_version, "previews/PR")
        return "$base/$current_version"
    end

    # Dev builds
    if current_version == "dev"
        dev_suffix = get(ENV, "DOCUMENTER_DEVURL", "dev")
        return "$base/$dev_suffix"
    end

    # Tagged/versioned builds (e.g. "v0.9", "v1.2.3")
    if !isempty(current_version) && current_version != "stable"
        return "$base/$current_version"
    end

    # Default to stable
    return "$base/stable"
end

const _DOCS_BASE_URL = _compute_docs_base_url()

"""
Choose how tutorial download links are written in generated markdown.

- **Absolute** (under `_DOCS_BASE_URL/tutorials/`): CI / Documenter context (`GITHUB_ACTIONS` or
  non-empty `DOCUMENTER_CURRENT_VERSION`) so previews, `dev`, and versioned URLs match
  `_compute_docs_base_url()`.
- **Relative** (bare filenames): local/offline builds; files sit next to `generated_*.md`
  under `docs/src/tutorials/`.

Override: `SIENNA_DOCS_DOWNLOAD_LINKS`=`absolute` or `relative`.
"""
function _downloads_use_absolute_urls()
    o = get(ENV, "SIENNA_DOCS_DOWNLOAD_LINKS", "")
    o == "absolute" && return true
    o == "relative" && return false
    haskey(ENV, "GITHUB_ACTIONS") && return true
    !isempty(get(ENV, "DOCUMENTER_CURRENT_VERSION", "")) && return true
    return false
end

# Replace APPEND_MARKDOWN("path/to/file.md") placeholders with file contents.
#
# Sample input:
#   "Before\nAPPEND_MARKDOWN(\"docs/src/tutorials/_snippet.md\")\nAfter"
# Sample output:
#   "Before\n<contents of _snippet.md>\nAfter"
#
# Notes:
# - Uses a non-greedy-safe capture (`[^\"]*`) so multiple placeholders can be
#   replaced independently.
function insert_md(content)
    pattern = r"APPEND_MARKDOWN\(\"([^\"]*)\"\)"
    if occursin(pattern, content)
        content = replace(content, pattern => m -> read(m.captures[1], String))
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
    admonition_start =
        r"^# !!! (note|info|tip|warning|danger|compat|todo|details)(?:\s+\"([^\"]*)\")?\s*$"
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

# Inject a short "download tutorial files" sentence after the first markdown
# heading in generated tutorial pages.
#
# Sample input:
#   "# Title\nBody..."
# Sample output (conceptual):
#   "# Title\n\n*To follow along... [Julia script](.../tutorial.jl)...*\n\nBody..."
#
# Download links:
# - **Deployed / CI**: absolute URLs under `_DOCS_BASE_URL` when `_downloads_use_absolute_urls()` is true.
# - **Local**: bare filenames (siblings of `generated_*.md` in `docs/src/tutorials/`).
function add_download_links(content, jl_file, ipynb_file)
    script_link, notebook_link = if _downloads_use_absolute_urls()
        ("$_DOCS_BASE_URL/tutorials/$(jl_file)", "$_DOCS_BASE_URL/tutorials/$(ipynb_file)")
    else
        (jl_file, ipynb_file)
    end
    download_section = """

*To follow along, you can download this tutorial as a [Julia script (.jl)]($(script_link)) or [Jupyter notebook (.ipynb)]($(notebook_link)).*

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

# Insert a setup preface and captured `Pkg.status()` into the first markdown
# cell of a generated notebook, immediately after the first heading.
#
# Sample effect:
# - First markdown cell gains a "Set up" blockquote and an embedded code block
#   containing package versions from the docs build environment.
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
# Literate strips the backtick wrapper and outputs raw HTML; we match that multi-line block.
# Sample effect:
# - If a markdown cell contains one or more image fragments, append exactly one
#   "view online" fallback note at the end of that cell.
# - If the note already exists in the cell, no change is applied.
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
        # If the cell has any of the image shapes below, we append one "view online" note.
        # We build one alternation pattern from sub-patterns (each line is one case).
        #
        # HTML paragraph wrapping an <img> (Literate often emits <p>…<img>…</p>).
        #   <p[^>]*>     — opening <p> and attributes
        #   [\s\S]*?     — any chars, non-greedy, up to the first <img
        #   <img…</p>   — from <img through closing </p>
        p_with_img_pattern = r"<p[^>]*>[\s\S]*?<img[\s\S]*?</p>"
        # Documenter @raw html chunk that Literate inlines in the notebook (backticks removed in output).
        #   ```@raw html  — start marker
        #   [\s\S]*?     — block body, non-greedy
        #   ```          — end fence
        raw_html_block_pattern = r"```@raw html[\s\S]*?```"
        # Standard markdown image: ![alt text](url)
        #   !\[…\]  — alt in brackets;  \(…\)  — path in parens
        markdown_image_pattern = r"!\[[^\]]*\]\([^\)]*\)"
        # A bare <img ...> not already covered by the <p>…<img>…</p> case above.
        #   <img   — tag start;  [^>]*?  — attributes;  /?>  — self-closing or >
        standalone_img_pattern = r"<img[^>]*?/?>"
        # Union of the four cases: (?: A | B | C | D )
        image_fragment_pattern = Regex(
            "(?:" *
            p_with_img_pattern.pattern * "|" *
            raw_html_block_pattern.pattern * "|" *
            markdown_image_pattern.pattern * "|" *
            standalone_img_pattern.pattern * ")",
        )
        if occursin(image_fragment_pattern, text)
            text *= suffix
        end
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

# Generate tutorial markdown + notebook artifacts from literate .jl sources.
#
# Pipeline:
# 1) discover tutorial .jl files (excluding helper files starting with "_")
# 2) generate Documenter-flavored markdown with injected download links
# 3) generate notebook with admonition conversion, setup preface, and image note
function make_tutorials()
    tutorials_dir = abspath(joinpath(@__DIR__, "src", "tutorials"))
    # Exclude helper scripts that start with "_"
    if isdir(tutorials_dir)
        tutorial_files =
            filter(
                x -> endswith(x, ".jl") && !startswith(x, "_"),
                readdir(tutorials_dir),
            )
        if !isempty(tutorial_files)
            # Clean up old generated tutorial files
            tutorial_outputdir = tutorials_dir
            clean_old_generated_files(tutorial_outputdir)

            for file in tutorial_files
                @show file
                infile_path = joinpath(tutorials_dir, file)
                execute =
                    if occursin("EXECUTE = TRUE", uppercase(readline(infile_path)))
                        true
                    else
                        false
                    end

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
                    postprocess = nb ->
                        add_image_links(add_pkg_status_to_notebook(nb), outputfile))
            end
        end
    end
end
