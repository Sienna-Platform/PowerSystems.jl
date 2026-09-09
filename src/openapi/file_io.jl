# A serialized System is written as either:
#
#   - format = :json     a directory of two members
#
#                            case/
#                              system.json      the OpenAPI document
#                              time_series.h5   the InfraStore arrays
#
#   - format = :sienna   three members, tar+gzip'd into one `.sn` file
#
#                            case.sn
#                              system.json
#                              time_series.h5
#                              time_series.h5.sqlite   InfraStore's own catalog
#
#                        Entries sit at the archive root rather than under a `case/` prefix,
#                        because `Tar.create` archives a directory's contents, not the
#                        directory itself.
#
# The third member is the difference between the formats, and it is a difference about
# **where the association tables live** rather than about compression:
#
#   :sienna keeps InfraStore's `.sqlite`, so the store is restored from its own tables. It
#   is the lossless native format — the catalog holds columns the OpenAPI wire form has no
#   field for — and it is Sienna-only, since reading it means reading InfraStore's catalog.
#
#   :json writes the arrays alone and records the associations in the document's own
#   `time_series_associations` table, which `from_openapi` replays into a freshly minted
#   catalog. That is what makes it two files any non-Julia reader can consume, and it is
#   bounded by what the wire form can express.
#
# `to_openapi(sys; write_catalog)` is the knob.
#
# The document records only the sidecar's basename, so the pair moves together.

"""Document member of a serialized System directory."""
const SYSTEM_DOCUMENT_FILE = "system.json"

"""HDF5 sidecar member of a serialized System directory."""
const TIME_SERIES_FILE = "time_series.h5"

"""InfraStore's SQLite catalog, beside the HDF5 sidecar.

A member of a `:sienna` bundle and not of a `:json` one — that is the difference between the
formats. Named here either way, because a directory being overwritten is cleared of it: the
arrays-only write refuses to publish beside a catalog whose rows would then point into the
file it just replaced.
"""
const TIME_SERIES_CATALOG_FILE = TIME_SERIES_FILE * ".sqlite"

"""
Archive member holding the System state the OpenAPI document has no representation for.

`format = :sienna` only, and it holds exactly one thing: subsystem membership. Everything
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
Warn when `sys` carries state `format = :json` cannot represent, so a round trip does not
silently drop it.

Called only from the `:json` branch, because it is the only lossy format:
[`SIENNA_EXTRAS_FILE`](@ref) carries what the document cannot. Frequency is in neither list —
it is an optional field of the document itself, so both formats keep it.
"""
function _warn_on_bundle_data_loss(sys::System)
    if !isempty(get_subsystems(sys))
        @warn "System has user-defined subsystems; format = :json does not represent " *
              "them, and they will not survive the round trip. Use format = :sienna to " *
              "keep them."
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

"""Honour `to_file`'s `pretty` for this member too, so a bundle is not half indented."""
_print_extras(io::IO, extras::AbstractDict, pretty::Bool) =
    pretty ? JSON.print(io, extras, 2) : JSON.print(io, extras)

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
                "$(IS.SIENNA_ARCHIVE_EXTENSION) archive is missing its $SIENNA_EXTRAS_FILE " *
                "member; it was not written by to_file(...; format = :sienna)",
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

function _prepare_bundle_dir(dir::AbstractString, force::Bool)
    if !isdir(dir)
        mkpath(dir)
        return nothing
    end
    for member in (SYSTEM_DOCUMENT_FILE, TIME_SERIES_FILE, TIME_SERIES_CATALOG_FILE)
        path = joinpath(dir, member)
        if isfile(path) && !force
            throw(
                IS.DataFormatError(
                    "$path already exists; pass force = true to overwrite the bundle",
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

"""
$(TYPEDSIGNATURES)

Write `sys` to `path`.

# The `format` keyword

  - `:json` (default) — `path` is a directory; writes `system.json` + `time_series.h5` into it
    (the sidecar only when `sys` has time series). The document carries the store's
    association rows, so no SQLite catalog is written.
  - `:sienna` — `path` is a single file (conventionally ending `.sn`); writes those two plus
    `time_series.h5.sqlite` (InfraStore's own catalog) and `sienna_extras.json` into a
    temporary directory and archives it with `Tar` + gzip. Lossless; `:json` is not.

# The `unit_system` keyword

`unit_system` is passed through to [`to_openapi`](@ref) (as its `power_units` keyword — that
function's own name is unchanged; it predates and is independent of this keyword) and chooses
the basis every value in the document is written on:

  - `:component_base` (default) writes each component's values on its own `base_power`, the
    convention PSY stores natively. Nothing is converted, so the numbers on disk are the
    numbers in memory and the round trip is exact.
  - `:natural_units` converts on the way out to physical units — MW, MVAr, MVA — which is
    what a reader outside Sienna generally wants.

Both are complete: any `System` exports either way, whatever it was built from. **`format =
:sienna` only ever writes `:component_base`** — that is the representation PSY stores natively,
so it costs no conversion pass over every component, and the archive format is chosen
specifically to be cheap to produce. Passing `unit_system = :natural_units` (or anything other
than `:component_base`) together with `format = :sienna` throws rather than silently ignoring
the keyword or paying the conversion cost the format exists to avoid.

Note the asymmetry between writing and reading `:json`. **A write is uniform**: PSY does not
track a per-component basis, so the choice made here stamps every power-bearing blob in the
document with the same value. **A read is per component**: each blob is converted according to
the unit system it carries, so a document written by another client with a mixed basis is read
back correctly, and a blob missing the field is an error rather than a guess (see
`from_openapi`). Writing then reading therefore returns what you exported regardless of which
basis you chose.

`sys.subsystems` has no representation in the document, so `format = :json` warns (does not
error) when the System has any; `format = :sienna` keeps them in `sienna_extras.json`. Masked
components need no such handling either way — they are re-masked on read when their owning
`StaticInjectionSubsystem` is added.
"""
function to_file(
    sys::System,
    path::AbstractString;
    format::Symbol = :json,
    unit_system::Symbol = :component_base,
    force::Bool = false,
    pretty::Bool = false,
)
    if format === :json
        _warn_on_bundle_data_loss(sys)
        _to_file_json(sys, path; unit_system = unit_system, force = force, pretty = pretty)
    elseif format === :sienna
        if unit_system !== :component_base
            error(
                "format = :sienna only ever writes :component_base (it is the cheapest " *
                "representation to produce); got unit_system = $unit_system",
            )
        end
        _to_file_sienna(sys, path; force = force, pretty = pretty)
    else
        error("format = $format is not supported. Use :json or :sienna.")
    end
    return nothing
end

function _to_file_json(
    sys::System,
    dir::AbstractString;
    unit_system::Symbol,
    force::Bool,
    pretty::Bool,
    write_catalog::Bool = false,
)
    _prepare_bundle_dir(dir, force)
    storage_path = _sidecar_path_for_write(sys, dir)
    doc = to_openapi(
        sys;
        power_units = unit_system,
        time_series_storage_path = storage_path,
        write_catalog = write_catalog,
    )
    PD.write_document(
        doc,
        joinpath(dir, SYSTEM_DOCUMENT_FILE);
        pretty = pretty,
        force = force,
    )
    @info "Serialized System to $dir"
    return nothing
end

function _to_file_sienna(
    sys::System,
    path::AbstractString;
    force::Bool,
    pretty::Bool,
)
    # `IS.create_sienna_archive` owns the container — the extension rule, the guards, and the
    # compression. What is PSY's is only what goes inside it.
    IS.create_sienna_archive(path; force = force) do bundle
        # The archive keeps InfraStore's own `.sqlite` — see the format notes at the top of
        # this file for why that is what makes `:sienna` the lossless one.
        _to_file_json(
            sys,
            bundle;
            unit_system = :component_base,
            force = true,
            pretty = pretty,
            write_catalog = true,
        )
        _write_sienna_extras(sys, bundle, pretty)
    end
    @info "Serialized System to $path"
    return nothing
end

function _sidecar_path_for_write(sys::System, dir::AbstractString)
    return _sidecar_path_for_write(Val(has_time_series_data(sys)), dir)
end

_sidecar_path_for_write(::Val{false}, ::AbstractString) = nothing
_sidecar_path_for_write(::Val{true}, dir::AbstractString) = joinpath(dir, TIME_SERIES_FILE)

"""
$(TYPEDSIGNATURES)

Read a `System` written by [`to_file`](@ref). `path` may be a `:json`-format directory or a
`:sienna` `.sn` archive — the format is inferred from `path` (a directory, or a `.sn` file).

The sidecar is located by the document's own `time_series_storage_file`, resolved relative to
the bundle directory — so a bundle stays readable after being moved or renamed. A document that
names a sidecar which is not present errors rather than yielding a system silently missing its
time series.

Of `System`'s keywords, `time_series_read_only` and `time_series_directory` are the two that
change how the bundle is *read* — read-only opens the sidecar in place, otherwise it is copied
to a working location first. `name`, `description` and `frequency` name document fields, and a
value passed here outranks the document's.

`system_kwargs` pass through to the `System` being built (`time_series_in_memory`,
`time_series_directory`, `runchecks`, ...).
"""
function from_file(path::AbstractString; system_kwargs...)
    if isdir(path)
        return _from_file_json(path; system_kwargs...)
    elseif IS.is_sienna_archive(path)
        return _from_file_sienna(path; system_kwargs...)
    else
        throw(
            IS.DataFormatError(
                "$path is not a serialized System bundle directory or a " *
                "$(IS.SIENNA_ARCHIVE_EXTENSION) archive",
            ),
        )
    end
end

function _from_file_json(dir::AbstractString; system_kwargs...)
    document_path = joinpath(dir, SYSTEM_DOCUMENT_FILE)
    if !isfile(document_path)
        throw(
            IS.DataFormatError(
                "$dir is not a serialized System bundle: no $SYSTEM_DOCUMENT_FILE in it",
            ),
        )
    end
    doc = PD.read_document(document_path)
    return from_openapi(
        System,
        doc;
        time_series_storage_path = _resolve_sidecar(doc, dir),
        system_kwargs...,
    )
end

function _from_file_sienna(path::AbstractString; system_kwargs...)
    # The extracted directory outlives this call, which `time_series_read_only = true` needs:
    # IS then opens the extracted sidecar in place rather than copying it out first.
    dir = IS.extract_sienna_archive(path)
    sys = _from_file_json(dir; system_kwargs...)
    _load_sienna_extras!(sys, dir)
    return sys
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
