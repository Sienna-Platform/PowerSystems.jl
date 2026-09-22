# A serialized System is written as one of three forms, chosen by the extension of the path
# given to `to_file` — there is no `format` keyword:
#
#   - `case`         a directory of two members
#
#                        case/
#                          system.json      the OpenAPI document
#                          time_series.h5   the InfraStore arrays
#
#   - `case.json`    the same two members, named after the document and sitting beside it
#
#                        case.json          the OpenAPI document
#                        case.h5            the InfraStore arrays
#
#                    The sidecar takes the document's stem so several systems can share one
#                    directory; the document records only its basename, so the pair moves
#                    together.
#
#   - `case.sns`     four members, zipped into one file
#
#                        case.sns
#                          system.json
#                          time_series.h5
#                          time_series.h5.sqlite   InfraStore's own catalog
#                          sienna_extras.json
#
#                    Entries sit at the archive root rather than under a `case/` prefix.
#                    JSON members are deflated and the HDF5 one is stored uncompressed,
#                    HDF5 carrying its own compression already.
#
# Only the archive keeps InfraStore's `.sqlite`, which is what makes it lossless and
# Sienna-only; the document forms record the same rows in the document itself, which is what
# makes them readable by any client. `to_openapi(sys; write_catalog)` selects between them.

"""Archive extension. Passed to IS rather than owned by it, so PowerSystemsInvestmentsPortfolios
can use its own `.snp`."""
const SYSTEM_ARCHIVE_EXTENSION = ".sns"

"""Document member of a serialized System directory."""
const SYSTEM_DOCUMENT_FILE = "system.json"

"""HDF5 sidecar member of a serialized System directory."""
const TIME_SERIES_FILE = "time_series.h5"

"""InfraStore's catalog suffix."""
const TIME_SERIES_CATALOG_SUFFIX = ".sqlite"

"""InfraStore's SQLite catalog, beside the HDF5 sidecar.

Archive member only, but named here too so a document write clears it: its rows would
otherwise point into a sidecar that write just replaced.
"""
const TIME_SERIES_CATALOG_FILE = TIME_SERIES_FILE * TIME_SERIES_CATALOG_SUFFIX

"""
Archive member holding subsystem membership — the only System state the document cannot
represent. Masked components need no entry: `add_component!` re-masks them on read, and
recording them would give one truth two writers.
"""
const SIENNA_EXTRAS_FILE = "sienna_extras.json"

"""
Whether `sys` has any time series, and therefore needs a sidecar written.

A system with none gets no `time_series.h5` at all and a null `time_series_storage_file`,
rather than an empty HDF5 file that would imply the data went missing.
"""
has_time_series_data(sys::System) = !iszero(IS.get_num_time_series(sys.data))

"""
Warn when `sys` carries state a bare document cannot represent, so a round trip does not
silently drop it.

Called from both document forms and not from the archive, because the archive is the only
lossless one: [`SIENNA_EXTRAS_FILE`](@ref) carries what the document cannot. Frequency is in
neither list — it is an optional field of the document itself, so every form keeps it.
"""
function _warn_on_document_data_loss(sys::System)
    if !isempty(get_subsystems(sys))
        @warn "System has user-defined subsystems; an OpenAPI document does not represent " *
              "them, and they will not survive the round trip. Write a " *
              "$(SYSTEM_ARCHIVE_EXTENSION) archive to keep them."
    end
    return nothing
end

"""
$(TYPEDSIGNATURES)

Write `sienna_extras.json` into an already-built bundle directory.

Component ids are the document's own ids, so the two members agree without a translation
step: PSY sets each component to its document id before adding it on import. Ids are sorted
so the file is byte-reproducible for a given System.
"""
function _write_sienna_extras(sys::System, dir::AbstractString, pretty::Bool)
    subsystems = Dict(
        name => sort!(collect(get_component_ids(sys, name))) for
        name in get_subsystems(sys)
    )
    open(joinpath(dir, SIENNA_EXTRAS_FILE), "w") do io
        _print_extras(io, Dict("subsystems" => subsystems), pretty)
    end
    return nothing
end

"""Honor `to_file`'s `pretty` for this member too."""
function _print_extras(io::IO, extras::AbstractDict, pretty::Bool)
    if pretty
        JSON.print(io, extras, 2)
    else
        JSON.print(io, extras)
    end
    return nothing
end

"""
$(TYPEDSIGNATURES)

Apply `sienna_extras.json` to a System just built from the archive's document.

A reference to a component the document does not carry throws, naming the id: both members are
written together from one System, so a mismatch means a corrupt archive, not an old one.
"""
function _load_sienna_extras!(sys::System, dir::AbstractString)
    path = joinpath(dir, SIENNA_EXTRAS_FILE)
    if !isfile(path)
        throw(
            IS.DataFormatError(
                "$(SYSTEM_ARCHIVE_EXTENSION) archive is missing its $SIENNA_EXTRAS_FILE " *
                "member; it was not written by to_file(sys, \"...$(SYSTEM_ARCHIVE_EXTENSION)\")",
            ),
        )
    end
    extras = JSON.parsefile(path; dicttype = Dict{String, Any})
    for (name, ids) in extras["subsystems"]
        add_subsystem!(sys, name)
        for id in ids
            add_component_to_subsystem!(sys, name, IS.get_component(sys, Int(id)))
        end
    end
    return nothing
end

"""
$(TYPEDSIGNATURES)

Write `sys` to `path`. The extension of `path` chooses the form:

  - **no extension** — `path` is a directory; writes `system.json` + `time_series.h5` into it
    (the sidecar only when `sys` has time series), creating the directory if it is absent.
  - **`.json`** — `path` is the document itself; writes it plus a `.h5` sidecar taking the
    document's stem (`case.json` → `case.h5`) beside it. Several systems can therefore share
    one directory.
  - **`$(SYSTEM_ARCHIVE_EXTENSION)`** — writes those two plus `time_series.h5.sqlite`
    (InfraStore's own catalog) and `sienna_extras.json` into a temporary directory and zips
    it. Lossless; the document forms are not.

Any other extension is refused rather than guessed at. [`from_file`](@ref) reads each form
from the same extension.

# The `units` keyword

`units` selects the unit system every value is written on, and is passed through to
[`to_openapi`](@ref):

  - `CU` (default) writes each component's values on its own `base_power`. Nothing is
    converted, so the round trip is exact.
  - `NU` converts to physical units — MW, MVAr, MVA — which is what a reader outside Sienna
    generally wants.

`SU` throws; so does any unit system but `CU` with an archive path, which exists to avoid a
conversion pass.

A write is uniform, a read is not: PSY records no per-component unit system, so the choice
here applies to the whole document, while `from_openapi` honors whatever each component
records. A mixed-unit document from another client therefore reads back correctly.

Subsystems survive only the archive form; both document forms warn. Masked components always
round-trip.
"""
function to_file(
    sys::System,
    path::AbstractString;
    units::IS.AbstractUnitSystem = CU,
    force::Bool = false,
    pretty::Bool = false,
)
    ext = lowercase(splitext(path)[2])
    if ext == SYSTEM_ARCHIVE_EXTENSION
        _check_archive_units(units)
        # IS owns the container (write guards, compression); PSY supplies the extension and
        # what goes inside.
        IS.create_sienna_archive(path, SYSTEM_ARCHIVE_EXTENSION; force = force) do bundle
            _write_bundle(
                sys,
                joinpath(bundle, SYSTEM_DOCUMENT_FILE),
                joinpath(bundle, TIME_SERIES_FILE);
                units = CU,
                force = true,
                pretty = pretty,
                write_catalog = true,
            )
            _write_sienna_extras(sys, bundle, pretty)
        end
    elseif ext == ".json"
        _warn_on_document_data_loss(sys)
        _write_bundle(
            sys,
            path,
            string(splitext(path)[1], ".h5");
            units = units,
            force = force,
            pretty = pretty,
            write_catalog = false,
        )
    elseif isempty(ext)
        _warn_on_document_data_loss(sys)
        mkpath(path)
        _write_bundle(
            sys,
            joinpath(path, SYSTEM_DOCUMENT_FILE),
            joinpath(path, TIME_SERIES_FILE);
            units = units,
            force = force,
            pretty = pretty,
            write_catalog = false,
        )
    else
        error(
            "to_file: cannot tell from \"$path\" which form to write. Give a directory " *
            "(no extension), a .json document, or a $(SYSTEM_ARCHIVE_EXTENSION) archive.",
        )
    end
    @info "Serialized System to $path"
    return nothing
end

"""An archive is component-base only, so every other marker is refused by its own method
rather than by a narrowed signature — a marker added later lands on the error, not on a
silently accepted union."""
_check_archive_units(::ComponentBaseUnit) = nothing

function _check_archive_units(units::IS.AbstractUnitSystem)
    return error(
        "a $(SYSTEM_ARCHIVE_EXTENSION) archive only ever writes on CU (it is the cheapest " *
        "representation to produce); got units = $units",
    )
end

"""
Write the document at `document_path` and, when `sys` has time series, its sidecar at
`sidecar_path` — the one writer every form goes through.

Refuses to replace an existing file unless `force`. The catalog beside the sidecar is cleared
too even when this write produces none: its rows would otherwise point into the sidecar this
write replaces. Files are removed rather than truncated because `Hdf5TimeSeriesStorage`
appends to an existing file, which would leave orphaned series in the new bundle.
"""
function _write_bundle(
    sys::System,
    document_path::AbstractString,
    sidecar_path::AbstractString;
    units::IS.AbstractUnitSystem,
    force::Bool,
    pretty::Bool,
    write_catalog::Bool,
)
    dir = dirname(document_path)
    if !isempty(dir)
        mkpath(dir)
    end
    for target in (document_path, sidecar_path, sidecar_path * TIME_SERIES_CATALOG_SUFFIX)
        if isfile(target) && !force
            throw(
                IS.DataFormatError(
                    "$target already exists; pass force = true to overwrite it",
                ),
            )
        end
        rm(target; force = true)
    end
    # No sidecar at all for a System without time series, rather than an empty HDF5 file
    # that would suggest the data went missing.
    storage_path = nothing
    if has_time_series_data(sys)
        storage_path = sidecar_path
    end
    doc = to_openapi(
        sys;
        units = units,
        time_series_storage_path = storage_path,
        write_catalog = write_catalog,
    )
    PD.write_document(doc, document_path; pretty = pretty, force = force)
    return nothing
end

"""
$(TYPEDSIGNATURES)

Read a `System` written by [`to_file`](@ref). The extension of `path` chooses the form, exactly
as it does for `to_file`: no extension reads a bundle directory, `.json` a document, and
`$(SYSTEM_ARCHIVE_EXTENSION)` an archive. Anything else is refused.

The sidecar is located by the document's own `time_series_storage_file`, resolved relative to
the directory the document sits in — so a bundle stays readable after being moved or renamed. A
document that names a sidecar which is not present errors rather than yielding a system
silently missing its time series.

Of `System`'s keywords, `time_series_read_only` and `time_series_directory` are the two that
change how the bundle is *read*. Read-only opens the sidecar in place instead of copying it to
a working location first, **and rejects every later write to the time series store** — it is an
enforced mode, not only an I/O shortcut. `name`, `description` and `frequency` name document
fields, and a value passed here outranks the document's.

`system_kwargs` pass through to the `System` being built (`time_series_in_memory`,
`time_series_directory`, `runchecks`, ...).
"""
function from_file(path::AbstractString; system_kwargs...)
    ext = lowercase(splitext(path)[2])
    if ext == SYSTEM_ARCHIVE_EXTENSION
        return _from_archive(path; system_kwargs...)
    elseif ext == ".json"
        return _read_bundle(path; system_kwargs...)
    elseif isempty(ext)
        return _read_bundle(joinpath(path, SYSTEM_DOCUMENT_FILE); system_kwargs...)
    else
        throw(
            IS.DataFormatError(
                "from_file: cannot tell from \"$path\" which form to read. Give a bundle " *
                "directory (no extension), a .json document, or a " *
                "$(SYSTEM_ARCHIVE_EXTENSION) archive.",
            ),
        )
    end
end

"""
Unzip the archive under `time_series_directory` (so `/tmp` need not fit the `.h5`) and read it.

A read-only store opens the extracted sidecar in place, so the sidecar outlives this call and
only the consumed JSON members are removed here; otherwise the store has taken its own copy and
the whole extraction is removed.
"""
function _from_archive(path::AbstractString; system_kwargs...)
    if !isfile(path)
        throw(IS.DataFormatError("$path is not a $(SYSTEM_ARCHIVE_EXTENSION) archive file"))
    end
    tsdir = something(
        get(system_kwargs, :time_series_directory, nothing),
        get(ENV, IS.TIME_SERIES_DIRECTORY_ENV_VAR, tempdir()),
    )
    mkpath(tsdir)
    dir = IS.extract_sienna_archive(path; directory = mktempdir(tsdir))
    sys = _read_bundle(joinpath(dir, SYSTEM_DOCUMENT_FILE); system_kwargs...)
    _load_sienna_extras!(sys, dir)
    if get(system_kwargs, :time_series_read_only, false)
        for consumed in (SYSTEM_DOCUMENT_FILE, SIENNA_EXTRAS_FILE)
            rm(joinpath(dir, consumed); force = true)
        end
    else
        rm(dir; recursive = true)
    end
    return sys
end

"""Read the document at `document_path`, adopting the sidecar it names from beside it."""
function _read_bundle(document_path::AbstractString; system_kwargs...)
    if !isfile(document_path)
        throw(IS.DataFormatError("$document_path is not a serialized System document"))
    end
    doc = PD.read_document(document_path)
    dir = dirname(document_path)
    if isempty(dir)
        dir = "."
    end
    return from_openapi(
        System,
        doc;
        time_series_storage_path = _resolve_sidecar(doc, dir),
        system_kwargs...,
    )
end

"""
Absolute path of the sidecar the document names, or `nothing` when it names none.

Errors when the document names a file that is absent: the alternative is a `System` quietly
missing every time series the document declared.
"""
function _resolve_sidecar(doc::PD.SystemDocument, dir::AbstractString)
    named = PD.get_time_series_storage_file(doc)
    return _resolve_sidecar(named, dir)
end

_resolve_sidecar(::Nothing, ::AbstractString) = nothing

function _resolve_sidecar(named::AbstractString, dir::AbstractString)
    path = joinpath(dir, named)
    if !isfile(path)
        throw(
            IS.DataFormatError(
                "the document names time_series_storage_file=\"$named\" but $path does " *
                "not exist — refusing to build a System missing its time series",
            ),
        )
    end
    return path
end
