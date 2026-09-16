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
# The archive's extra members are the difference between the forms, and the `.sqlite` one is a
# difference about **where the association tables live** rather than about compression:
#
#   `.sns` keeps InfraStore's `.sqlite`, so the store is restored from its own tables. It is the
#   lossless native form — the catalog holds columns the OpenAPI wire form has no field for —
#   and it is Sienna-only, since reading it means reading InfraStore's catalog. It also carries
#   `sienna_extras.json`, which is what makes it the only form that keeps subsystems.
#
#   The two document forms write the arrays alone and record the associations in the document's
#   own `time_series_associations` table, which `from_openapi` replays into a freshly minted
#   catalog. That is what makes them readable by any non-Julia client, and it bounds them by
#   what the wire form can express.
#
# `to_openapi(sys; write_catalog)` is the knob.

"""Extension of the archive form: **s**ienna, **s**ystem. PowerSystemsInvestmentsPortfolios
spells its own `.snp`, which is why the container in IS takes this from its caller rather
than owning one extension."""
const SYSTEM_ARCHIVE_EXTENSION = ".sns"

"""Document member of a serialized System directory."""
const SYSTEM_DOCUMENT_FILE = "system.json"

"""HDF5 sidecar member of a serialized System directory."""
const TIME_SERIES_FILE = "time_series.h5"

"""Suffix InfraStore gives its catalog: the sidecar's own name plus this. Named once so the
document forms, which name their sidecar after the document, derive the same path."""
const TIME_SERIES_CATALOG_SUFFIX = ".sqlite"

"""InfraStore's SQLite catalog, beside the HDF5 sidecar.

A member of a `:sienna` bundle and not of a `:json` one — that is the difference between the
formats. Named here either way, because a directory being overwritten is cleared of it: the
arrays-only write refuses to publish beside a catalog whose rows would then point into the
file it just replaced.
"""
const TIME_SERIES_CATALOG_FILE = TIME_SERIES_FILE * TIME_SERIES_CATALOG_SUFFIX

"""
Archive member holding the System state the OpenAPI document has no representation for.

Archive form only, and it holds exactly one thing: subsystem membership. Everything
else a System carries is either in the document already (frequency, so both formats keep it)
or derived from it on read — masked components are re-masked by
`handle_component_addition!(sys, ::StaticInjectionSubsystem)` when the owning
`StaticInjectionSubsystem` is added, so recording them would give one truth two writers.
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

Write the `:sienna` extras member into an already-built bundle directory.

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

"""Honor `to_file`'s `pretty` for this member too, so an archive is not half indented."""
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

Apply the `:sienna` extras member to a System just built from the bundle's document.

`IS.get_component(sys, id)` throws `ArgumentError` naming the id when the file references a
component the document does not carry, which is the right outcome: the two members are written
together from one System, so a mismatch means the archive is corrupt rather than merely old.
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
Clear the paths a write is about to publish, or refuse the write.

The catalog is listed even though neither document form writes one: an arrays-only write must
not publish beside a catalog left by an earlier archive-shaped write, whose rows would then
point into the file it just replaced.
"""
function _prepare_write_targets(paths, force::Bool)
    for path in paths
        if isfile(path) && !force
            throw(
                IS.DataFormatError(
                    "$path already exists; pass force = true to overwrite it",
                ),
            )
        end
        # Removed rather than truncated: Hdf5TimeSeriesStorage appends to an existing file,
        # so a stale sidecar would leave orphaned series behind in the new bundle.
        if force
            rm(path; force = true)
        end
    end
    return nothing
end

"""Create `dir` when it names one; a bare filename has no parent to create."""
function _ensure_parent_dir(dir::AbstractString)
    if !isempty(dir)
        mkpath(dir)
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

Any other extension is refused rather than guessed at.

# The `units` keyword

`units` is passed through to `to_openapi` and chooses the basis every value in the
document is written on:

  - `CU` (default) writes each component's values on its own `base_power`, the convention PSY
    stores natively. Nothing is converted, so the numbers on disk are the numbers in memory and
    the round trip is exact.
  - `NU` converts on the way out to physical units — MW, MVAr, MVA — which is what a reader
    outside Sienna generally wants.

Both are complete: any `System` exports either way, whatever it was built from. `SU` is refused,
having no representation in the wire enum. **An archive only ever writes `CU`** — that is the
representation PSY stores natively, so it costs no conversion pass over every component, and
the archive form is chosen specifically to be cheap to produce. Passing any other unit system
with a `$(SYSTEM_ARCHIVE_EXTENSION)` path throws rather than silently ignoring the keyword
or paying the conversion cost the form exists to avoid.

Note the asymmetry between writing and reading. **A write is uniform**: PSY does not track a
per-component basis, so the choice made here stamps every power-bearing blob in the document
with the same value. **A read is per component**: each blob is converted according to the unit
system it carries, so a document written by another client with a mixed basis is read back
correctly, and a blob missing the field is an error rather than a guess (see `from_openapi`).
Writing then reading therefore returns what you exported regardless of which basis you chose.

`sys.subsystems` has no representation in the document, so both document forms warn (they do
not error) when the System has any; an archive keeps them in `sienna_extras.json`. Masked
components need no such handling in any form — they are re-masked on read when their owning
`StaticInjectionSubsystem` is added.
"""
function to_file(
    sys::System,
    path::AbstractString;
    units::IS.AbstractUnitSystem = CU,
    force::Bool = false,
    pretty::Bool = false,
)
    # The unknown-extension case is refused here, before anything dispatches on the form: a
    # `Val`-style dispatch reached first would turn a typo'd extension into a `MethodError` on
    # an internal helper instead of this message.
    ext = lowercase(splitext(path)[2])
    if ext == SYSTEM_ARCHIVE_EXTENSION
        _check_archive_units(units)
        _to_file_sienna(sys, path; force = force, pretty = pretty)
    elseif ext == ".json"
        _warn_on_document_data_loss(sys)
        _to_file_document(sys, path; units = units, force = force, pretty = pretty)
    elseif isempty(ext)
        _warn_on_document_data_loss(sys)
        _to_file_directory(sys, path; units = units, force = force, pretty = pretty)
    else
        error(
            "to_file: cannot tell from \"$path\" which form to write. Give a directory " *
            "(no extension), a .json document, or a $(SYSTEM_ARCHIVE_EXTENSION) archive.",
        )
    end
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

"""Write the directory form: both members named by convention inside `dir`."""
function _to_file_directory(
    sys::System,
    dir::AbstractString;
    units::IS.AbstractUnitSystem,
    force::Bool,
    pretty::Bool,
    write_catalog::Bool = false,
)
    mkpath(dir)
    _prepare_write_targets(
        (
            joinpath(dir, SYSTEM_DOCUMENT_FILE),
            joinpath(dir, TIME_SERIES_FILE),
            joinpath(dir, TIME_SERIES_CATALOG_FILE),
        ),
        force,
    )
    _write_bundle(
        sys,
        joinpath(dir, SYSTEM_DOCUMENT_FILE),
        _sidecar_path_for_write(sys, joinpath(dir, TIME_SERIES_FILE));
        units = units,
        force = force,
        pretty = pretty,
        write_catalog = write_catalog,
    )
    @info "Serialized System to $dir"
    return nothing
end

"""Write the document form: the document at `path`, its sidecar beside it on the same stem."""
function _to_file_document(
    sys::System,
    path::AbstractString;
    units::IS.AbstractUnitSystem,
    force::Bool,
    pretty::Bool,
)
    _ensure_parent_dir(dirname(path))
    sidecar = _document_sidecar_path(path)
    _prepare_write_targets(
        (path, sidecar, sidecar * TIME_SERIES_CATALOG_SUFFIX),
        force,
    )
    _write_bundle(
        sys,
        path,
        _sidecar_path_for_write(sys, sidecar);
        units = units,
        force = force,
        pretty = pretty,
        write_catalog = false,
    )
    @info "Serialized System to $path"
    return nothing
end

"""
Build the document against `storage_path` and write it to `document_path`.

The one writer both document forms share: they differ only in where the two members sit, which
their callers have already resolved.
"""
function _write_bundle(
    sys::System,
    document_path::AbstractString,
    storage_path;
    units::IS.AbstractUnitSystem,
    force::Bool,
    pretty::Bool,
    write_catalog::Bool,
)
    doc = to_openapi(
        sys;
        units = units,
        time_series_storage_path = storage_path,
        write_catalog = write_catalog,
    )
    PD.write_document(doc, document_path; pretty = pretty, force = force)
    return nothing
end

"""The sidecar beside a `.json` document: its stem, with the HDF5 extension."""
_document_sidecar_path(path::AbstractString) = string(splitext(path)[1], ".h5")

function _to_file_sienna(
    sys::System,
    path::AbstractString;
    force::Bool,
    pretty::Bool,
)
    # `IS.create_sienna_archive` owns the container — the write guards and the compression —
    # but not the extension, which is PSY's and is passed in. What is PSY's is also only what
    # goes inside it.
    IS.create_sienna_archive(path, SYSTEM_ARCHIVE_EXTENSION; force = force) do bundle
        # The archive keeps InfraStore's own `.sqlite` — see the format notes at the top of
        # this file for why that is what makes `:sienna` the lossless one.
        _to_file_directory(
            sys,
            bundle;
            units = CU,
            force = true,
            pretty = pretty,
            write_catalog = true,
        )
        _write_sienna_extras(sys, bundle, pretty)
    end
    @info "Serialized System to $path"
    return nothing
end

"""The sidecar path a write should use, or `nothing` when `sys` has no time series to put in
one. The caller resolves *where* the sidecar goes; this decides only whether there is one."""
function _sidecar_path_for_write(sys::System, candidate::AbstractString)
    return _sidecar_path_for_write(Val(has_time_series_data(sys)), candidate)
end

_sidecar_path_for_write(::Val{false}, ::AbstractString) = nothing
_sidecar_path_for_write(::Val{true}, candidate::AbstractString) = candidate

"""
$(TYPEDSIGNATURES)

Read a `System` written by [`to_file`](@ref). The form is inferred from `path`: a directory
reads the directory form, a `.json` file reads the document form, and a
`$(SYSTEM_ARCHIVE_EXTENSION)` file reads the archive. Anything else is refused.

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
    if isdir(path)
        return _from_file_directory(path; system_kwargs...)
    elseif IS.is_sienna_archive(path, SYSTEM_ARCHIVE_EXTENSION)
        return _from_file_sienna(path; system_kwargs...)
    elseif lowercase(splitext(path)[2]) == ".json"
        return _from_file_document(path; system_kwargs...)
    else
        throw(
            IS.DataFormatError(
                "$path is not a serialized System: expected a bundle directory, a .json " *
                "document, or a $(SYSTEM_ARCHIVE_EXTENSION) archive",
            ),
        )
    end
end

"""Read the directory form, whose document member is named by convention."""
function _from_file_directory(dir::AbstractString; system_kwargs...)
    document_path = joinpath(dir, SYSTEM_DOCUMENT_FILE)
    if !isfile(document_path)
        throw(
            IS.DataFormatError(
                "$dir is not a serialized System bundle: no $SYSTEM_DOCUMENT_FILE in it",
            ),
        )
    end
    return _from_file_document(document_path; system_kwargs...)
end

"""
Read a document at an explicit path, sidecar and all.

The one reader every form goes through: the document records its sidecar's basename, so the
directory the document sits in is all that is needed to find it, whichever form put it there.
"""
function _from_file_document(document_path::AbstractString; system_kwargs...)
    if !isfile(document_path)
        throw(IS.DataFormatError("$document_path is not a file"))
    end
    doc = PD.read_document(document_path)
    dir = dirname(document_path)
    return from_openapi(
        System,
        doc;
        time_series_storage_path = _resolve_sidecar(doc, isempty(dir) ? "." : dir),
        system_kwargs...,
    )
end

function _from_file_sienna(path::AbstractString; system_kwargs...)
    tsdir = something(
        get(system_kwargs, :time_series_directory, nothing),
        get(ENV, IS.TIME_SERIES_DIRECTORY_ENV_VAR, tempdir()),
    )
    mkpath(tsdir)
    # Unzip here so /tmp doesn't have to fit the .h5.
    if get(system_kwargs, :time_series_read_only, false)
        # Store opens the sidecar in place; drop the JSONs once consumed.
        dir = IS.extract_sienna_archive(path; directory = mktempdir(tsdir))
        sys = _from_file_directory(dir; system_kwargs...)
        _load_sienna_extras!(sys, dir)
        for consumed in (SYSTEM_DOCUMENT_FILE, SIENNA_EXTRAS_FILE)
            rm(joinpath(dir, consumed); force = true)
        end
        return sys
    end
    # Store copies out; the whole extraction is scoped to this block.
    return mktempdir(tsdir) do dir
        IS.extract_sienna_archive(path; directory = dir)
        sys = _from_file_directory(dir; system_kwargs...)
        _load_sienna_extras!(sys, dir)
        return sys
    end
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
