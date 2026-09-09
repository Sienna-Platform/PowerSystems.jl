
"""
PSY-owned struct code generator (forked from InfrastructureSystems.jl's
`generate_structs.jl`). Self-contained: it emits Julia source as text and declares its own
imports, so it has no dependency on PowerSystems' own types. `generate_structs`/
`test_generated_structs` are dev-tool entry points, not part of PSY's public `get_*`/
`set_*` surface — call them module-qualified, `PowerSystems.StructGeneration.generate_structs(...)`,
never exported from `PowerSystems`.
"""
module StructGeneration

import JSON
import InfrastructureSystems
const IS = InfrastructureSystems
const MU = IS.Mustache
import InfrastructureSystems: DataFormatError

# Convertible fields also get fallback accessor methods for the calls that omit the
# units — a one-argument getter, and setters taking an untagged number or an
# all-untagged compound. They route to `_units_arg_required`/`_units_tag_required`
# (hand-written, `src/models/components.jl`), which name the accessor, the field and
# the units that would have worked. Without them, `get_active_power(gen)` and
# `set_active_power!(gen, 1)` raise bare `MethodError`s that list signatures but never
# say what a valid unit is.
const STRUCT_TEMPLATE = """
#=
This file is auto-generated. Do not edit.
=#

#! format: off

\"\"\"
    mutable struct {{struct_name}}{{#parametric}}{T <: {{parametric}}}{{/parametric}} <: {{supertype}}
        {{#parameters}}
        {{name}}::{{{data_type}}}
        {{/parameters}}
    end

{{#docstring}}{{{docstring}}}{{/docstring}}

# Arguments
{{#parameters}}
- `{{name}}::{{{data_type}}}`:{{#default}} (default: `{{{default}}}`){{/default}}{{#comment}} {{{comment}}}{{/comment}}{{#valid_range}}, validation range: `{{{valid_range}}}`{{/valid_range}}
{{/parameters}}
\"\"\"
mutable struct {{struct_name}}{{#parametric}}{T <: {{parametric}}}{{/parametric}} <: {{supertype}}
    {{#parameters}}
    {{#comment}}"{{{comment}}}"\n    {{/comment}}{{name}}::{{{data_type}}}
    {{/parameters}}
    {{#inner_constructor_check}}

    function {{struct_name}}({{#parameters}}{{name}}, {{/parameters}})
        ({{#parameters}}{{name}}, {{/parameters}}) = {{inner_constructor_check}}(
            {{#parameters}}
            {{name}},
            {{/parameters}}
        )
        new({{#parameters}}{{name}}, {{/parameters}})
    end
    {{/inner_constructor_check}}
end

{{#needs_positional_constructor}}
function {{constructor_func}}({{#parameters}}{{^internal_default}}{{name}}{{#default}}={{default}}{{/default}}, {{/internal_default}}{{/parameters}}){{{closing_constructor_text}}}
    {{constructor_func}}({{#parameters}}{{^internal_default}}{{name}}, {{/internal_default}}{{/parameters}}{{#parameters}}{{#internal_default}}{{{internal_default}}}, {{/internal_default}}{{/parameters}})
end
{{/needs_positional_constructor}}

function {{constructor_func}}(; {{#parameters}}{{name}}{{#kwarg_value}}{{{kwarg_value}}}{{/kwarg_value}}, {{/parameters}}){{{closing_constructor_text}}}
    {{constructor_func}}({{#parameters}}{{name}}, {{/parameters}})
end

{{#has_null_values}}
# Constructor for demo purposes; non-functional.
function {{constructor_func}}(::Nothing){{{closing_constructor_text}}}
    {{constructor_func}}(;
        {{#parameters}}
        {{^internal_default}}
        {{name}}={{#quotes}}"{{null_value}}"{{/quotes}}{{^quotes}}{{null_value}}{{/quotes}},
        {{/internal_default}}
        {{/parameters}}
    )
end

{{/has_null_values}}
{{#accessors}}
{{#needs_conversion}}
{{#create_docstring}}\"\"\"Get [`{{struct_name}}`](@ref) `{{name}}` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`{{accessor}}_unitful`](@ref).\"\"\"{{/create_docstring}}
{{accessor}}(value::{{struct_name}}, units) = InfrastructureSystems._strip_units(get_value(value, Val(:{{name}}), Val({{conversion_unit}}), units))
{{#create_docstring}}\"\"\"Get [`{{struct_name}}`](@ref) `{{name}}` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`{{accessor}}`](@ref).\"\"\"{{/create_docstring}}
{{accessor}}_unitful(value::{{struct_name}}, units) = get_value(value, Val(:{{name}}), Val({{conversion_unit}}), units)
{{accessor}}(value::{{struct_name}}) = _units_arg_required({{accessor}}, value, :{{name}}, Val({{conversion_unit}}))
{{accessor}}_unitful(value::{{struct_name}}) = _units_arg_required({{accessor}}_unitful, value, :{{name}}, Val({{conversion_unit}}))
InfrastructureSystems.display_units_arg(::typeof({{accessor}}), ::{{units_type_sig}}){{#units_bound}} where {T <: {{units_bound}}}{{/units_bound}} = InfrastructureSystems.{{display_units}}
InfrastructureSystems.display_units_arg(::typeof({{accessor}}_unitful), ::{{units_type_sig}}){{#units_bound}} where {T <: {{units_bound}}}{{/units_bound}} = InfrastructureSystems.{{display_units}}
{{/needs_conversion}}
{{^needs_conversion}}
{{#create_docstring}}\"\"\"Get [`{{struct_name}}`](@ref) `{{name}}`.\"\"\"{{/create_docstring}}
{{accessor}}(value::{{struct_name}}) = value.{{name}}
{{/needs_conversion}}
{{/accessors}}

{{#setters}}
{{#needs_conversion}}
{{#create_docstring}}\"\"\"Set [`{{struct_name}}`](@ref) `{{name}}`.\"\"\"{{/create_docstring}}
{{setter}}(value::{{struct_name}}, val) = value.{{name}} = set_value(value, Val(:{{name}}), val, Val({{conversion_unit}}))
{{setter}}(value::{{struct_name}}, val::_UntaggedNumber) = _units_tag_required({{setter}}, value, :{{name}}, Val({{conversion_unit}}), val)
{{#compound_untagged}}
{{setter}}(value::{{struct_name}}, val::{{{compound_untagged}}}) = _units_tag_required({{setter}}, value, :{{name}}, Val({{conversion_unit}}), val)
{{/compound_untagged}}
{{/needs_conversion}}
{{^needs_conversion}}
{{#create_docstring}}\"\"\"Set [`{{struct_name}}`](@ref) `{{name}}`.\"\"\"{{/create_docstring}}
{{setter}}(value::{{struct_name}}, val) = value.{{name}} = val
{{/needs_conversion}}
{{/setters}}

{{#custom_code}}
{{{custom_code}}}
{{/custom_code}}

{{#openapi_type}}
function from_openapi(po::{{{openapi_po_type}}}, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return {{struct_name}}(;
        {{#openapi_kwargs_device}}
        {{name}} = {{{expr}}},
        {{/openapi_kwargs_device}}
    )
end

function from_openapi(po::{{{openapi_po_type}}}, refs::OpenAPIRefs, ::NaturalUnit)
    return {{struct_name}}(;
        {{#openapi_kwargs_natural}}
        {{name}} = {{{expr}}},
        {{/openapi_kwargs_natural}}
    )
end

{{#has_power_units}}
function from_openapi(po::{{{openapi_po_type}}}, refs::OpenAPIRefs)
    return from_openapi(po, refs, _power_units_marker("{{struct_name}}", po.id, po.power_units))
end
{{/has_power_units}}
{{^has_power_units}}
function from_openapi(po::{{{openapi_po_type}}}, refs::OpenAPIRefs)
    return from_openapi(po, refs, DU)
end
{{/has_power_units}}

function to_openapi(value::{{struct_name}}, refs::OpenAPIRefs, ::DeviceBaseUnit)
    return PO.{{struct_name}}(;
        {{#openapi_export_kwargs_device}}
        {{name}} = {{{expr}}},
        {{/openapi_export_kwargs_device}}
    )
end

function to_openapi(value::{{struct_name}}, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.{{struct_name}}(;
        {{#openapi_export_kwargs_natural}}
        {{name}} = {{{expr}}},
        {{/openapi_export_kwargs_natural}}
    )
end
{{/openapi_type}}
"""

# ──────────────────────────────────────────────────────────────────────────────────────
# OpenAPI converter generation, both directions.
#
# A descriptor entry carrying a top-level `openapi_type` key gets `from_openapi` and
# `to_openapi` methods appended to its generated file, one per unit system
# (`DeviceBaseUnit` pass-through, `NaturalUnit` with conversion arithmetic
# inlined, using the same `IS.RelativeUnits` singleton markers as the rest of PSY's
# explicit-units engine). `from_openapi` builds a PSY component from a PO (OpenAPI model)
# struct's fields; `to_openapi` builds a PO struct from the PSY component's `get_*`
# accessors — the same field classification run in the opposite direction. The generic
# `from_openapi`/`to_openapi` functions, `OpenAPIRefs`, `convert_cost`/
# `convert_cost_to_openapi`, and the PO/PC modules are all defined in PowerSystems, not
# here — this generator only emits methods that compile against them.
#
# `from_openapi` dispatches on the PO type. It does not take the PSY type as a leading
# `::Type{...}`: the PO type already determines it (the mapping is one-to-one across every
# `DOCUMENT_PLAN` entry, asserted by the "converters match the declared pair" testset in
# test_openapi_document.jl), so the argument
# was redundant, and for the three reserve types — whose PSY types are `UnionAll` — it did
# not pin the return type either. Naming `PO` here costs the generator nothing: the export
# half already emits `PO.<struct_name>` constructors, and `PowerSystems` declares `const
# PO` before the generated files are included.
#
# A descriptor entry without `openapi_type` never reaches any function below — every one
# is only called from `compute_openapi_converter!`/`compute_openapi_export_converter!`,
# themselves only called when `haskey(item, "openapi_type")`.
# ──────────────────────────────────────────────────────────────────────────────────────

# `reserves` is AGC's regulated-reserve list: like `services`, it is membership, carried by
# the document's `service_associations` rows and filled in by the association loader — never
# an inline field on one side. `buses` and `trading_hubs` are TradingHub's and
# VirtualParticipant's analogous membership lists, carried by `trading_hub_associations`
# instead.
const OPENAPI_SKIP_FIELDS = Set([
    "ext",
    "internal",
    "services",
    "dynamic_injector",
    "reserves",
    "buses",
    "trading_hubs",
])
# Abstract reference types that are not themselves generated structs: `bare in struct_names`
# misses them, so without this the classifier falls through to `:enum`.
const OPENAPI_REFERENCE_TYPES = Set(["Topology", "Component"])
const OPENAPI_SCALAR_TYPES = Set(["Float64", "Int", "Int32", "Int64", "String", "Bool"])
const OPENAPI_COMPOUND_MEMBERS = Dict(
    "MinMax" => ("min", "max"),
    "UpDown" => ("up", "down"),
    "FromTo" => ("from", "to"),
    "InOut" => ("in", "out"),
    "FromTo_ToFrom" => ("from_to", "to_from"),
    "StartUpShutDown" => ("startup", "shutdown"),
    "StartUpStages" => ("hot", "warm", "cold"),
    "TurbinePump" => ("turbine", "pump"),
)
# The three power tokens share one per-unit base (S_base) and so one conversion
# rule; they differ only in the natural unit the units engine prints them as.
const OPENAPI_CONVERSION_KINDS = Dict(
    ":mw" => :power,
    ":mvar" => :power,
    ":mva" => :power,
    ":ohm" => :impedance,
    ":siemens" => :admittance,
)

"""
Export-direction PO constructor helpers for each compound alias (`src/openapi/
export_generated_types.jl`), keyed by `(required, optional, required_scaled,
optional_scaled)`. A `nothing` entry means no such helper exists — `PowerSystems`
has never needed one for that combination — so a struct that would require it raises
in [`openapi_export_compound_exprs`](@ref) rather than emitting a call to a function
that does not exist.
"""
const OPENAPI_EXPORT_COMPOUND_CTORS = Dict(
    "MinMax" => (
        required = "_minmax_po", optional = "_minmax_po_optional",
        required_scaled = "_minmax_po_scaled",
        optional_scaled = "_minmax_po_scaled_optional",
    ),
    "UpDown" => (
        required = nothing, optional = "_updown_po_optional",
        required_scaled = nothing, optional_scaled = "_updown_po_scaled_optional",
    ),
    "FromTo_ToFrom" => (
        required = "_fromto_tofrom_po", optional = nothing,
        required_scaled = "_fromto_tofrom_po_scaled", optional_scaled = nothing,
    ),
    "StartUpShutDown" => (
        required = nothing, optional = "_startup_shutdown_po_optional",
        required_scaled = nothing,
        optional_scaled = "_startup_shutdown_po_scaled_optional",
    ),
    "StartUpStages" => (
        required = nothing, optional = "_startup_stages_po_optional",
        required_scaled = nothing, optional_scaled = nothing,
    ),
    # `HydroPumpTurbine`'s three `TurbinePump` fields (efficiency, transition_time,
    # minimum_time) are all required and none carry a conversion, so only the plain
    # constructor exists.
    "TurbinePump" => (
        required = "_turbinepump_po", optional = nothing,
        required_scaled = nothing, optional_scaled = nothing,
    ),
)

"""Split `Union{Nothing, X}` into `(X, true)`; any other type string is `(type, false)`."""
function openapi_strip_nullable(data_type::AbstractString)
    m = match(r"^Union\{Nothing,\s*(.+)\}$", data_type)
    if isnothing(m)
        return (data_type, false)
    end
    return (String(m.captures[1]), true)
end

"""
Classify one field's role in an OpenAPI converter. Returns `(kind, bare, nullable)` with
`kind` one of `:skip`, `:cost`, `:scalar`, `:compound`, `:reference`, `:enum`.

Raises `DataFormatError` — never returns a partial/guessed classification — when `bare`
is neither a scalar, a known compound alias, a component struct defined in this same
descriptor, nor a plausible bare enum type identifier (e.g. `Complex{Float64}`,
`Tuple{...}`, a `Union` of concrete curve types all fail this last check).
"""
function openapi_classify_field(struct_name, field, struct_names)
    name = field["name"]
    if name in OPENAPI_SKIP_FIELDS
        return (:skip, field["data_type"], false)
    end
    if name in ("operation_cost", "spread_bid")
        return (:cost, field["data_type"], false)
    end
    bare, nullable = openapi_strip_nullable(field["data_type"])
    if bare in OPENAPI_SCALAR_TYPES
        return (:scalar, bare, nullable)
    end
    if haskey(OPENAPI_COMPOUND_MEMBERS, bare)
        return (:compound, bare, nullable)
    end
    if bare in struct_names || bare in OPENAPI_REFERENCE_TYPES
        return (:reference, bare, nullable)
    end
    if !occursin(r"^[A-Za-z_][A-Za-z0-9_]*$", bare)
        throw(
            DataFormatError(
                "openapi_type=$struct_name field=$name data_type=$(field["data_type"]) " *
                "has no determinable OpenAPI converter kind (not scalar, compound, a " *
                "component reference, or a plausible scoped-enum type name)",
            ),
        )
    end
    return (:enum, bare, nullable)
end

"""
Validate a field's optional `openapi_unit` override. Only `"pu"` is recognized: it means
the OpenAPI document already carries this field per-unit (its schema `x-unit` is `pu`, not
a natural unit), so a `conversion_unit`-driven division/multiplication would double-convert
it — e.g. `Line.r`/`x`/`b`/`g`, which carry `needs_conversion` + `:ohm`/`:siemens` for PSY's
own SU/DU accessor machinery, but are pu in the document. SiennaSchemas' parity checker is
the intended place to cross-check `"pu"` against the schema's declared `x-unit`; this
generator only recognizes the one value and raises on anything else — never guesses.

Returns `true` when the override applies (skip the conversion arithmetic in both unit-system
methods), `false` when the key is absent. Runs — and can raise — regardless of the field's
converter `kind`; only `:scalar`/`:compound` fields act on a `true` result.
"""
function openapi_validate_unit_override(struct_name, field)
    if !haskey(field, "openapi_unit")
        return false
    end
    value = field["openapi_unit"]
    if value != "pu"
        throw(
            DataFormatError(
                "struct=$struct_name field=$(field["name"]) has unmapped " *
                "openapi_unit=$value (only \"pu\" is supported)",
            ),
        )
    end
    return true
end

"""
`openapi_unit` and `openapi_export_base_kind` are only meaningful on a struct carrying
`openapi_type` — nothing reads them otherwise, so either is stray descriptor noise rather
than a silent no-op. Runs for every item, regardless of annotation; only raises when one of
these (brand new, opt-in) keys is actually present, so an unannotated entry without them is
untouched.
"""
function openapi_check_no_orphan_unit!(item)
    if haskey(item, "openapi_type")
        return nothing
    end
    struct_name = item["struct_name"]
    if haskey(item, "openapi_export_base_kind")
        throw(
            DataFormatError(
                "struct=$struct_name has openapi_export_base_kind=" *
                "$(item["openapi_export_base_kind"]) but no openapi_type; " *
                "openapi_export_base_kind is only meaningful on an annotated struct",
            ),
        )
    end
    for field in item["fields"]
        if haskey(field, "openapi_unit")
            throw(
                DataFormatError(
                    "struct=$struct_name field=$(field["name"]) has openapi_unit=" *
                    "$(field["openapi_unit"]) but the struct has no openapi_type; " *
                    "openapi_unit is only meaningful on an annotated struct",
                ),
            )
        end
    end
    return nothing
end

"""
Classify the natural-units conversion rule for a scalar/compound field from the existing
`needs_conversion` + `conversion_unit` descriptor keys. Returns `:none`, `:power`,
`:impedance`, or `:admittance`.
"""
function openapi_natural_conversion(struct_name, field)
    if !get(field, "needs_conversion", false)
        return :none
    end
    conversion_unit = get(field, "conversion_unit", nothing)
    kind = get(OPENAPI_CONVERSION_KINDS, conversion_unit, nothing)
    if isnothing(kind)
        throw(
            DataFormatError(
                "openapi_type=$struct_name field=$(field["name"]) has needs_conversion=true " *
                "with an unmapped conversion_unit=$conversion_unit",
            ),
        )
    end
    return kind
end

"""
Whether an annotated struct has at least one field in the `:power` conversion family
(`needs_conversion=true` with `conversion_unit` one of `:mw`/`:mvar`/`:mva` — the wire's
`power_units` discriminator only ever governs that family, never `:ohm`/`:siemens`
impedance/admittance fields). Determines whether the generated PO struct carries a
`power_units` member: mechanically derived from the descriptor rather than a maintained
list, so it can never drift from the fields that are actually emitted.
"""
function openapi_has_power_units(item)
    for field in item["fields"]
        get(field, "needs_conversion", false) || continue
        get(field, "conversion_unit", nothing) in (":mw", ":mvar", ":mva") && return true
    end
    return false
end

"""
S_base/Z_base source expressions for the conversion arithmetic, requiring the struct's
own `base_power`/`base_voltage` fields (`S_base = po.base_power`;
`Z_base = V_base^2 / S_base`). Resolving `V_base` through a component reference
(e.g. `Line` → its arc's from-bus) is not implemented in this generator pass; raise
rather than guess.
"""
function openapi_base_exprs(struct_name, field_name, conversion, field_names)
    if conversion == :power
        if !("base_power" in field_names)
            throw(
                DataFormatError(
                    "openapi_type=$struct_name field=$field_name needs S_base for a " *
                    ":power conversion but the struct has no base_power field",
                ),
            )
        end
        return (s_base = "po.base_power", z_base = nothing)
    end
    if conversion in (:impedance, :admittance)
        if !("base_power" in field_names) || !("base_voltage" in field_names)
            throw(
                DataFormatError(
                    "openapi_type=$struct_name field=$field_name needs V_base/S_base for " *
                    "a $conversion conversion but the struct has no base_voltage/base_power " *
                    "field on itself; resolving V_base through a component reference is " *
                    "not implemented in this generator pass",
                ),
            )
        end
        return (s_base = "po.base_power", z_base = "(po.base_voltage^2 / po.base_power)")
    end
    return (s_base = nothing, z_base = nothing)
end

"""Operator and base expression for one `conversion` kind: power divides by S_base,
impedance divides by Z_base, admittance multiplies by Z_base."""
function openapi_conversion_op_base(conversion, bases)
    if conversion == :power
        return ("/", bases.s_base)
    end
    if conversion == :impedance
        return ("/", bases.z_base)
    end
    return ("*", bases.z_base)
end

"""
The name this field carries on the PO side, which is its PSY name unless the descriptor
states otherwise with `openapi_name`.

The two diverge when PSY uses an identifier the schema cannot: `ExponentialLoad`'s `α`/`β`
are `alpha`/`beta` in the JSON. The override lives on the field rather than being inferred
(e.g. by transliterating Greek) so the mapping is stated once, in the descriptor, and any
future divergence is declared rather than guessed.
"""
openapi_po_field_name(field) = get(field, "openapi_name", field["name"])

"""Wrap `body` in the nothing-guard emitted for a nullable PO field."""
function openapi_nullable_wrap(field_name, body)
    return "(if isnothing(po.$field_name); nothing; else; $body; end)"
end

"""Device-base is always pass-through; only the natural-units expression varies with
`conversion`. A nullable field with a real conversion needs a nothing-guard; a nullable
field with no conversion does not since scalar field access on `nothing` is never attempted."""
function openapi_scalar_exprs(field_name, conversion, nullable, bases)
    device = "po.$field_name"
    if conversion == :none
        return (device, device)
    end
    op, base = openapi_conversion_op_base(conversion, bases)
    scaled = "po.$field_name $op $base"
    if !nullable
        return (device, scaled)
    end
    return (device, openapi_nullable_wrap(field_name, scaled))
end

"""
Import-direction extraction helper for each compound alias
(`src/openapi/import_generated_types.jl`).

One name per alias, unlike [`OPENAPI_EXPORT_COMPOUND_CTORS`](@ref)'s four: the
required/optional split is dispatch on `::Nothing` and the natural-units split is the
`op`/`base` arity, so the four shapes collapse into one symbol here.
"""
const OPENAPI_IMPORT_COMPOUND_EXTRACTORS = Dict(
    "MinMax" => "_minmax_from_po",
    "UpDown" => "_updown_from_po",
    "FromTo" => "_fromto_from_po",
    "InOut" => "_inout_from_po",
    "FromTo_ToFrom" => "_fromto_tofrom_from_po",
    "StartUpShutDown" => "_startup_shutdown_from_po",
    "StartUpStages" => "_startup_stages_from_po",
    "TurbinePump" => "_turbinepump_from_po",
)

"""Compound fields always get member-rebuilt in both methods — the PO struct's compound
type is never PSY's `NamedTuple` alias, so even device-base is not a bare `po.<name>`
passthrough (mirrors `minmax`/`updown`/`fromto` in the reference).

The rebuild goes through the alias' extraction helper rather than inline `po.<name>.<m>`
member access: the PO struct declares every compound field as bare `Any`, so inline
access is a dynamic `getproperty` chain. The helper dispatches on the `PC` struct once
and reads concrete fields after that. Its `::Nothing` methods also absorb the
nothing-guard a nullable compound used to need in *both* directions, so `nullable` no
longer changes the emitted expression."""
function openapi_compound_exprs(field_name, bare, members, conversion, nullable, bases)
    extractor = OPENAPI_IMPORT_COMPOUND_EXTRACTORS[bare]
    device = "$extractor(po.$field_name)"
    if conversion == :none
        return (device, device)
    end
    op, base = openapi_conversion_op_base(conversion, bases)
    return (device, "$extractor(po.$field_name, ($op), $base)")
end

"""
Compute and attach the OpenAPI import-direction converter data for one annotated
descriptor entry (mutates `item`). Only called when `haskey(item, "openapi_type")`; a
descriptor entry without that key never reaches this function.
"""
function compute_openapi_converter!(item, struct_names)
    struct_name = item["struct_name"]
    if haskey(item, "parametric")
        throw(
            DataFormatError(
                "openapi_type=$struct_name is parametric ($(item["parametric"])); " *
                "parametric OpenAPI converters are not implemented in this generator pass",
            ),
        )
    end
    field_names = Set(f["name"] for f in item["fields"])
    kwargs_device = Vector{Dict{String, String}}()
    kwargs_natural = Vector{Dict{String, String}}()

    for field in item["fields"]
        name = field["name"]
        po_name = openapi_po_field_name(field)
        kind, bare, nullable = openapi_classify_field(struct_name, field, struct_names)
        pu_override = openapi_validate_unit_override(struct_name, field)
        if kind == :skip
            continue
        end
        if kind == :cost
            # `convert_cost` has 20-odd return types and the PO cost is a `oneOf` wrapper
            # whose `.value` is `Any`, so the call infers as `Any`. The descriptor states
            # the field's PSY type — assert it, so the constructor is handed something
            # bounded and a cost that converts to the wrong family fails here.
            expr = "convert_cost(po.$po_name)::$bare"
            push!(kwargs_device, Dict("name" => name, "expr" => expr))
            push!(kwargs_natural, Dict("name" => name, "expr" => expr))
            continue
        end
        if kind == :reference
            # `resolve_ref`, not `refs[...]`: a schema-optional reference the document omits
            # arrives as `nothing`, and indexing cannot express that (`refs[nothing]` is a
            # MethodError). The helper returns `nothing` for an absent reference and still
            # errors on one that names an unregistered id. The third argument is the PSY
            # type the descriptor declares, which `refs`' `Dict{Int, Any}` cannot supply.
            expr = "resolve_ref(refs, po.$po_name, $bare)"
            push!(kwargs_device, Dict("name" => name, "expr" => expr))
            push!(kwargs_natural, Dict("name" => name, "expr" => expr))
            continue
        end
        if kind == :enum
            # `@scoped_enum` types construct straight from the document's string
            # (`ACBusTypes("PV")`), so no per-enum lookup table is emitted.
            expr = "$bare(po.$po_name)"
            push!(kwargs_device, Dict("name" => name, "expr" => expr))
            push!(kwargs_natural, Dict("name" => name, "expr" => expr))
            continue
        end
        conversion = if pu_override
            :none
        else
            openapi_natural_conversion(struct_name, field)
        end
        bases = openapi_base_exprs(struct_name, name, conversion, field_names)
        if kind == :scalar
            device, natural = openapi_scalar_exprs(po_name, conversion, nullable, bases)
        else
            members = OPENAPI_COMPOUND_MEMBERS[bare]
            device, natural =
                openapi_compound_exprs(po_name, bare, members, conversion, nullable, bases)
        end
        push!(kwargs_device, Dict("name" => name, "expr" => device))
        push!(kwargs_natural, Dict("name" => name, "expr" => natural))
    end

    item["openapi_po_type"] = "PO." * item["openapi_type"]
    item["openapi_kwargs_device"] = kwargs_device
    item["openapi_kwargs_natural"] = kwargs_natural
    return nothing
end

# ──────────────────────────────────────────────────────────────────────────────────────
# OpenAPI export-direction (`to_openapi`) converter generation — the inverse of
# `compute_openapi_converter!` above. Shares its field classification
# (`openapi_classify_field`), unit-override validation (`openapi_validate_unit_override`),
# natural-units conversion rule (`openapi_natural_conversion`), and compound-member table
# (`OPENAPI_COMPOUND_MEMBERS`), so a field's role can never disagree between directions.
# Builds a PO struct from the PSY component's own `get_*` accessors rather than a PSY
# component from a PO struct's fields, and multiplies by the S_base/Z_base anchor where
# `from_openapi` divides.
# ──────────────────────────────────────────────────────────────────────────────────────

"""
Where an exported struct reads its S_base anchor, and which unit system it requests the
convertible field in. Every annotated struct reads its own `_get_base_power` in device
units (`DU`) — the default, `openapi_export_base_kind` absent or `"device"`. A struct whose
`base_power_kind` (`src/models/components.jl`) is `SystemBasePower` is the exception: its own
`base_power` field is not the per-unit anchor for a directly-constructed, unattached
component (`add_component!` is what keeps it synced to the system base), so it must read the
document-level anchor instead (`get_base_power(refs)`, unit system `SU`) — set
`openapi_export_base_kind: "system"` on that struct's descriptor entry to opt in.
"""
function openapi_export_base_source(item)
    kind = get(item, "openapi_export_base_kind", "device")
    if kind == "device"
        return (unit_arg = "DU", base_expr = "_get_base_power(value)")
    end
    if kind == "system"
        return (unit_arg = "SU", base_expr = "get_base_power(refs)")
    end
    throw(
        DataFormatError(
            "openapi_type=$(item["struct_name"]) has unmapped openapi_export_base_kind=" *
            "$kind (only \"device\" or \"system\" are supported)",
        ),
    )
end

"""The PSY-side accessor name for one field: the public `get_X`, unless the descriptor
marks the field `exclude_getter`, in which case only the internal `_get_X` exists."""
function openapi_export_getter_name(field)
    if get(field, "exclude_getter", false)
        return "_get_" * field["name"]
    end
    return "get_" * field["name"]
end

"""
S_base/Z_base source expressions for the export-direction conversion arithmetic — mirrors
`openapi_base_exprs`, reading the PSY component's own getters (`base_source.base_expr` for
S_base, `get_base_voltage(value)` for V_base) instead of the PO struct's raw fields. Raises
under the same conditions as the import side: `:power` needs `base_power` on the struct;
`:impedance`/`:admittance` also need `base_voltage`.
"""
function openapi_export_base_exprs(
    struct_name,
    field_name,
    conversion,
    field_names,
    base_source,
)
    if conversion == :power
        if !("base_power" in field_names)
            throw(
                DataFormatError(
                    "openapi_type=$struct_name field=$field_name needs S_base for a " *
                    ":power export conversion but the struct has no base_power field",
                ),
            )
        end
        return (s_base = base_source.base_expr, z_base = nothing)
    end
    if conversion in (:impedance, :admittance)
        if !("base_power" in field_names) || !("base_voltage" in field_names)
            throw(
                DataFormatError(
                    "openapi_type=$struct_name field=$field_name needs V_base/S_base for " *
                    "a $conversion export conversion but the struct has no base_voltage/" *
                    "base_power field on itself; resolving V_base through a component " *
                    "reference is not implemented in this generator pass",
                ),
            )
        end
        z_base = "(get_base_voltage(value)^2 / $(base_source.base_expr))"
        return (s_base = base_source.base_expr, z_base = z_base)
    end
    return (s_base = nothing, z_base = nothing)
end

"""Operator and base expression for one `conversion` kind, export direction — the inverse
of `openapi_conversion_op_base`: power and impedance multiply (device pu * base = natural
value, undoing the import side's divide), admittance divides (undoing import's multiply)."""
function openapi_export_conversion_op_base(conversion, bases)
    if conversion == :power
        return ("*", bases.s_base)
    end
    if conversion == :impedance
        return ("*", bases.z_base)
    end
    return ("/", bases.z_base)
end

"""Device-base/natural-units export expressions for one non-`base_power` scalar field.
Device is `get_X(value)` with no conversion, or `get_X(value, unit_arg)` under a real
conversion; natural additionally combines with the S_base/Z_base anchor and is otherwise
identical to device (mirrors `openapi_scalar_exprs`, inverted). A nullable field scales
through `_scale_optional_po`, which only multiplies — so a nullable field under
`:admittance` (a divide) raises rather than guessing; no annotated struct today has one."""
function openapi_export_scalar_exprs(
    struct_name,
    field_name,
    conversion,
    nullable,
    getter,
    bases,
    unit_arg,
)
    if conversion == :none
        expr = "$getter(value)"
        return (expr, expr)
    end
    device = "$getter(value, $unit_arg)"
    op, base = openapi_export_conversion_op_base(conversion, bases)
    if !nullable
        return (device, "$device $op $base")
    end
    if op != "*"
        throw(
            DataFormatError(
                "openapi_type=$struct_name field=$field_name is a nullable scalar with a " *
                "$conversion export conversion (a divide); not implemented in this " *
                "generator's export pass — _scale_optional_po only multiplies",
            ),
        )
    end
    return (device, "_scale_optional_po($device, $base)")
end

"""The PO constructor to call for a compound field in the COMPONENT_BASE method: the
`optional` variant when the field is nullable, `required` otherwise."""
function openapi_export_compound_ctor_device(ctors, nullable)
    if nullable
        return ctors.optional
    end
    return ctors.required
end

"""The PO constructor to call for a compound field in the NATURAL_UNITS method: same as
COMPONENT_BASE when there is no conversion to apply, otherwise the `_scaled` sibling."""
function openapi_export_compound_ctor_natural(ctors, nullable, conversion)
    if conversion == :none
        return openapi_export_compound_ctor_device(ctors, nullable)
    end
    if nullable
        return ctors.optional_scaled
    end
    return ctors.required_scaled
end

"""Device-base/natural-units export expressions for one compound field (mirrors
`openapi_compound_exprs`, inverted). Every `_scaled`/`_scaled_optional` compound helper in
`src/openapi/export_generated_types.jl` only multiplies, so `:power`/`:impedance` (both
multiply on export) are implemented but `:admittance` (a divide) raises — no annotated
struct today has an admittance compound field. Only the compound aliases with a matching
entry in [`OPENAPI_EXPORT_COMPOUND_CTORS`](@ref) are supported; both raise rather than
guess."""
function openapi_export_compound_exprs(
    struct_name,
    field_name,
    bare,
    conversion,
    nullable,
    getter,
    bases,
    unit_arg,
)
    if conversion == :admittance
        throw(
            DataFormatError(
                "openapi_type=$struct_name field=$field_name is a compound field with a " *
                ":admittance export conversion (a divide); not implemented in this " *
                "generator's export pass — the compound PO constructors only multiply",
            ),
        )
    end
    ctors = get(OPENAPI_EXPORT_COMPOUND_CTORS, bare, nothing)
    if isnothing(ctors)
        throw(
            DataFormatError(
                "openapi_type=$struct_name field=$field_name has compound type $bare with " *
                "no export converter helper registered in OPENAPI_EXPORT_COMPOUND_CTORS",
            ),
        )
    end
    device_ctor = openapi_export_compound_ctor_device(ctors, nullable)
    natural_ctor = openapi_export_compound_ctor_natural(ctors, nullable, conversion)
    if isnothing(device_ctor) || isnothing(natural_ctor)
        variant = "required"
        if nullable
            variant = "optional"
        end
        throw(
            DataFormatError(
                "openapi_type=$struct_name field=$field_name has no $variant export " *
                "converter for compound type $bare with conversion=$conversion",
            ),
        )
    end
    if conversion == :none
        device_getter = "$getter(value)"
        device = "$device_ctor($device_getter)"
        return (device, device)
    end
    device_getter = "$getter(value, $unit_arg)"
    device = "$device_ctor($device_getter)"
    _, base = openapi_export_conversion_op_base(conversion, bases)
    natural = "$natural_ctor($device_getter, $base)"
    return (device, natural)
end

"""
Compute and attach the OpenAPI export-direction converter data for one annotated
descriptor entry (mutates `item`). Only called when `haskey(item, "openapi_type")`.
"""
function compute_openapi_export_converter!(item, struct_names)
    struct_name = item["struct_name"]
    if haskey(item, "parametric")
        throw(
            DataFormatError(
                "openapi_type=$struct_name is parametric ($(item["parametric"])); " *
                "parametric OpenAPI export converters are not implemented in this " *
                "generator pass",
            ),
        )
    end
    field_names = Set(f["name"] for f in item["fields"])
    kwargs_device = Vector{Dict{String, String}}()
    kwargs_natural = Vector{Dict{String, String}}()
    # `id` is not a descriptor field — it is the reflexive lookup registered by the document
    # walk before `to_openapi` is ever called (see the header comment in `src/openapi/
    # export_generated_types.jl`) — so it is prepended directly rather than discovered by
    # iterating `item["fields"]`.
    push!(kwargs_device, Dict("name" => "id", "expr" => "component_id(refs, value)"))
    push!(kwargs_natural, Dict("name" => "id", "expr" => "component_id(refs, value)"))
    base_source = nothing

    for field in item["fields"]
        # The emitted kwarg is the PO field name, which `openapi_name` may override.
        name = openapi_po_field_name(field)
        kind, bare, nullable = openapi_classify_field(struct_name, field, struct_names)
        pu_override = openapi_validate_unit_override(struct_name, field)
        if kind == :skip
            continue
        end
        if kind == :cost
            getter = "$(openapi_export_getter_name(field))(value)"
            expr = "convert_cost_to_openapi($getter)"
            push!(kwargs_device, Dict("name" => name, "expr" => expr))
            push!(kwargs_natural, Dict("name" => name, "expr" => expr))
            continue
        end
        if kind == :reference
            getter = "$(openapi_export_getter_name(field))(value)"
            if nullable
                expr = "_component_id_optional(refs, $getter)"
            else
                expr = "component_id(refs, $getter)"
            end
            push!(kwargs_device, Dict("name" => name, "expr" => expr))
            push!(kwargs_natural, Dict("name" => name, "expr" => expr))
            continue
        end
        if kind == :enum
            # `string` on a `@scoped_enum` yields the document's exact spelling, the
            # inverse of the import direction's `EnumType(po.field)` constructor.
            expr = "string($(openapi_export_getter_name(field))(value))"
            push!(kwargs_device, Dict("name" => name, "expr" => expr))
            push!(kwargs_natural, Dict("name" => name, "expr" => expr))
            continue
        end
        if name == "base_power"
            if isnothing(base_source)
                base_source = openapi_export_base_source(item)
            end
            push!(kwargs_device, Dict("name" => name, "expr" => base_source.base_expr))
            push!(kwargs_natural, Dict("name" => name, "expr" => base_source.base_expr))
            continue
        end
        conversion = if pu_override
            :none
        else
            openapi_natural_conversion(struct_name, field)
        end
        bases = (s_base = nothing, z_base = nothing)
        unit_arg = nothing
        if conversion != :none
            if isnothing(base_source)
                base_source = openapi_export_base_source(item)
            end
            unit_arg = base_source.unit_arg
            bases = openapi_export_base_exprs(
                struct_name,
                name,
                conversion,
                field_names,
                base_source,
            )
        end
        getter = openapi_export_getter_name(field)
        if kind == :scalar
            device, natural = openapi_export_scalar_exprs(
                struct_name, name, conversion, nullable, getter, bases, unit_arg,
            )
        else
            device, natural = openapi_export_compound_exprs(
                struct_name, name, bare, conversion, nullable, getter, bases, unit_arg,
            )
        end
        push!(kwargs_device, Dict("name" => name, "expr" => device))
        push!(kwargs_natural, Dict("name" => name, "expr" => natural))
    end

    if get(item, "has_power_units", false)
        push!(
            kwargs_device,
            Dict("name" => "power_units", "expr" => "_power_units_string(DU)"),
        )
        push!(
            kwargs_natural,
            Dict("name" => "power_units", "expr" => "_power_units_string(NU)"),
        )
    end

    item["openapi_export_kwargs_device"] = kwargs_device
    item["openapi_export_kwargs_natural"] = kwargs_natural
    return nothing
end

"""The element names of each compound field type, matching the `set_value` methods in
`src/models/components.jl`. A convertible field of one of these types accepts a
`NamedTuple` value; every other convertible field is scalar and does not."""
const COMPOUND_FIELD_KEYS = Dict(
    "MinMax" => "(:min, :max)",
    "UpDown" => "(:up, :down)",
    "FromTo" => "(:from, :to)",
    "FromTo_ToFrom" => "(:from_to, :to_from)",
    "StartUpShutDown" => "(:startup, :shutdown)",
)

"""The `NamedTuple` signature whose elements are all untagged numbers, for a convertible
field of a compound type — the setter fallback that reports the missing units. Returns an
empty string for a scalar field, so no `NamedTuple` method is emitted for one."""
function compound_untagged_signature(data_type::AbstractString)
    base_type = replace(data_type, r"^Union\{Nothing, *(.*)\}$" => s"\1")
    keys = get(COMPOUND_FIELD_KEYS, base_type, nothing)
    isnothing(keys) && return ""
    return "NamedTuple{$keys, <:Tuple{Vararg{_UntaggedNumber}}}"
end

function read_json_data(filename::String)
    return open(filename) do io
        data = JSON.parse(io; dicttype = Dict{String, Any})
        if data isa Array
            return data
        elseif data isa Dict && haskey(data, "auto_generated_structs")
            return data["auto_generated_structs"]
        else
            throw(DataFormatError("$filename has invalid format"))
        end
    end
end

function generate_structs(directory, data::Vector; print_results = true)
    struct_names = Vector{String}()
    unique_accessor_functions = Set{String}()
    unique_setter_functions = Set{String}()
    openapi_struct_names = Set(it["struct_name"] for it in data)

    for item in data
        openapi_check_no_orphan_unit!(item)
        has_internal = false
        accessors = Vector{Dict}()
        setters = Vector{Dict}()
        item["has_null_values"] = true
        has_non_default_values = false

        item["constructor_func"] = item["struct_name"]
        item["closing_constructor_text"] = ""
        if haskey(item, "parametric")
            item["constructor_func"] *= "{T}"
            item["closing_constructor_text"] = " where T <: $(item["parametric"])"
        end

        parameters = Vector{Dict}()
        for field in item["fields"]
            param = field
            param["struct_name"] = item["struct_name"]
            if haskey(param, "valid_range")
                if typeof(param["valid_range"]) == Dict{String, Any}
                    min = param["valid_range"]["min"]
                    max = param["valid_range"]["max"]
                    param["valid_range"] = "($min, $max)"
                elseif typeof(param["valid_range"]) == String
                    param["valid_range"] = param["valid_range"]
                end
            end
            if haskey(param, "default")
                param["default"] = string(param["default"])
            end
            push!(parameters, param)

            # Allow accessor functions to be re-implemented from another module.
            # If this key is defined then the accessor function will not be exported.
            # Example:  get_name is defined in InfrastructureSystems and re-implemented in
            # PowerSystems.
            if haskey(param, "accessor_module")
                accessor_module = param["accessor_module"] * "."
                create_docstring = false
            else
                accessor_module = ""
                create_docstring = true
            end
            accessor_name = accessor_module * "get_" * param["name"]
            setter_name = accessor_module * "set_" * param["name"] * "!"
            conversion_unit = get(param, "conversion_unit", "nothing")
            include_getter = !get(param, "exclude_getter", false)
            if include_getter
                push!(
                    accessors,
                    Dict(
                        "name" => param["name"],
                        "accessor" => accessor_name,
                        "create_docstring" => create_docstring,
                        "needs_conversion" => get(param, "needs_conversion", false),
                        "conversion_unit" => conversion_unit,
                        # Units argument used when displaying the field (tables, REPL);
                        # override per field in the descriptor with "display_units".
                        "display_units" => get(param, "display_units", "SU"),
                        # The units trait dispatches on the component's concrete
                        # type, so parametric structs need the `Type{Name{T}} where`
                        # form (`Type{Name}` is the UnionAll and never matches a
                        # concrete `Name{...}`); concrete structs use the exact form.
                        "units_type_sig" => if haskey(item, "parametric")
                            "Type{$(item["struct_name"]){T}}"
                        else
                            "Type{$(item["struct_name"])}"
                        end,
                        # The bound is substituted inside a literal `where {T <: …}`
                        # template fragment (values get HTML-escaped; literals don't).
                        "units_bound" => get(item, "parametric", false),
                    ),
                )
            else
                internal_name = "_get_" * param["name"]
                push!(
                    accessors,
                    Dict(
                        "name" => param["name"],
                        "accessor" => internal_name,
                        "create_docstring" => false,
                        "needs_conversion" => false,
                        "conversion_unit" => "nothing",
                    ),
                )
            end
            include_setter = !get(param, "exclude_setter", false)
            if include_setter
                push!(
                    setters,
                    Dict(
                        "name" => param["name"],
                        "setter" => setter_name,
                        "data_type" => param["data_type"],
                        "create_docstring" => create_docstring,
                        "needs_conversion" => get(param, "needs_conversion", false),
                        "conversion_unit" => conversion_unit,
                        "compound_untagged" => compound_untagged_signature(
                            param["data_type"],
                        ),
                    ),
                )
            end
            if field["name"] != "internal" && accessor_module == ""
                # exclude_getter/exclude_setter mean "hand-written elsewhere" (e.g.
                # unit-aware accessors with different signatures), not "nonexistent" —
                # always export the public name.
                push!(unique_accessor_functions, accessor_name)
                push!(unique_setter_functions, setter_name)
                # Export the `_unitful` companion only when the getter is actually
                # generated. `exclude_getter` fields emit only the private `_get_X`
                # (needs_conversion forced false) and have both `get_X` and
                # `get_X_unitful` hand-written, so exporting on needs_conversion alone
                # would export a symbol this generator never defined.
                if include_getter && get(param, "needs_conversion", false)
                    push!(unique_accessor_functions, accessor_name * "_unitful")
                end
            end

            param["kwarg_value"] = ""
            if !isnothing(get(param, "default", nothing))
                param["kwarg_value"] = "=" * param["default"]
            elseif !isnothing(get(param, "internal_default", nothing))
                param["kwarg_value"] = "=" * string(param["internal_default"])
                has_internal = true
                continue
            else
                has_non_default_values = true
            end

            # This controls whether a demo constructor will be generated.
            if isnothing(get(param, "null_value", nothing)) &&
               isnothing(get(param, "default", nothing))
                item["has_null_values"] = false
            else
                if isnothing(get(param, "null_value", nothing))
                    item["null_value"] = param["default"]
                end
                if param["data_type"] == "String"
                    param["quotes"] = true
                end
            end
        end

        item["parameters"] = parameters
        item["accessors"] = accessors
        item["setters"] = setters
        # If all parameters have defaults then the positional constructor will
        # collide with the kwarg constructor.
        item["needs_positional_constructor"] = has_internal && has_non_default_values

        if haskey(item, "openapi_type")
            item["has_power_units"] = openapi_has_power_units(item)
            compute_openapi_converter!(item, openapi_struct_names)
            compute_openapi_export_converter!(item, openapi_struct_names)
        end

        filename = joinpath(directory, item["struct_name"] * ".jl")
        open(filename, "w") do io
            write(io, strip(MU.render(STRUCT_TEMPLATE, item)))
            write(io, "\n")
            push!(struct_names, item["struct_name"])
        end

        if print_results
            println("Wrote $filename")
        end
    end

    accessors = sort!(collect(unique_accessor_functions))
    setters = sort!(collect(unique_setter_functions))
    filename = joinpath(directory, "includes.jl")
    open(filename, "w") do io
        for name in struct_names
            write(io, "include(\"$name.jl\")\n")
        end
        write(io, "\n")

        for accessor in accessors
            write(io, "export $accessor\n")
        end
        for setter in setters
            write(io, "export $setter\n")
        end
        if print_results
            println("Wrote $filename")
        end
    end
end

function generate_structs(
    input_file::AbstractString,
    output_directory::AbstractString;
    print_results = true,
)
    # Include each generated file.
    if !isdir(output_directory)
        mkdir(output_directory)
    end

    data = read_json_data(input_file)
    generate_structs(output_directory, data; print_results = print_results)
    return
end

"""
Return true if the structs defined in `existing_dir` match structs freshly generated from
`descriptor_file`.
"""
function test_generated_structs(descriptor_file, existing_dir)
    output_dir = mktempdir()

    generate_structs(descriptor_file, output_dir; print_results = false)

    matched = true
    for (file1, file2) in zip(readdir(output_dir), readdir(existing_dir))
        path1 = joinpath(output_dir, file1)
        path2 = joinpath(existing_dir, file2)
        for (line1, line2) in zip(readlines(path1), readlines(path2))
            # Note: must strip the line endings.
            line1 = strip(line1)
            line2 = strip(line2)
            if line1 != line2
                @error "Generated structs do not match descriptor file" file1 line1 line2
                matched = false
                # Every line will now fail. Trying to use system utilities like diff didn't
                # work well across platforms.
                break
            end
        end
    end

    rm(output_dir; recursive = true)
    return matched
end

end # module StructGeneration
