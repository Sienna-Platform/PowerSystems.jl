"""
Blanket coverage for the generated explicit-units accessors.

Every convertible field emits the same three or four methods from one template, so
a hand-written test per field would test the template 247 times over. Instead this
walks the descriptor -- the same source the generator reads -- and exercises each
generated method on a demo (`T(nothing)`) instance of its own struct. A field the
descriptor marks convertible but whose accessor was never emitted, or emitted with
the wrong arity, fails here rather than in whatever downstream code first calls it.

The fallbacks are exercised rather than the working accessors: they need no bases,
so a detached demo component is enough to reach every one of them.
"""

const DESCRIPTOR_FIELDS = JSON.parsefile(
    joinpath(@__DIR__, "..", "src", "descriptors", "power_system_structs.json"),
)["auto_generated_structs"]

"""Demo instance of a generated struct, or `nothing` when the descriptor gives it no
null values (`T(nothing)` is only emitted for structs that have them)."""
function _demo_component(item)
    name = Symbol(item["struct_name"])
    isdefined(PowerSystems, name) || return nothing
    T = getfield(PowerSystems, name)
    T isa Type || return nothing
    hasmethod(T, Tuple{Nothing}) || return nothing
    return try
        T(nothing)
    catch
        nothing
    end
end

@testset "Generated accessors: every convertible field reports its missing units" begin
    checked_structs = 0
    checked_fields = 0
    unreachable = String[]
    for item in DESCRIPTOR_FIELDS
        convertible = filter(f -> get(f, "needs_conversion", false), item["fields"])
        isempty(convertible) && continue
        comp = _demo_component(item)
        if isnothing(comp)
            push!(unreachable, item["struct_name"])
            continue
        end
        checked_structs += 1
        for field in convertible
            name = field["name"]
            checked_fields += 1
            # `exclude_getter`/`exclude_setter` mean the accessor is hand-written
            # with its own signature; the generator emits no fallback for it.
            if !get(field, "exclude_getter", false)
                getter = getfield(PowerSystems, Symbol("get_", name))
                unitful = getfield(PowerSystems, Symbol("get_", name, "_unitful"))
                @test_throws ArgumentError getter(comp)
                @test_throws ArgumentError unitful(comp)
            end
            if !get(field, "exclude_setter", false)
                setter = getfield(PowerSystems, Symbol("set_", name, "!"))
                @test_throws ArgumentError setter(comp, 1.0)
            end
        end
    end
    # Every struct carrying convertible fields is reachable through `T(nothing)`,
    # so the walk covers all of them; the floors catch a renamed descriptor key
    # silently reducing this file to zero assertions. Both numbers only grow as
    # convertible fields are added (35 structs / 191 fields at the time of writing).
    @test isempty(unreachable)
    @test checked_structs >= 35
    @test checked_fields >= 191

    # Spot-check that the coverage above is reaching the informative message and
    # not some unrelated `ArgumentError`.
    msg = try
        get_active_power(ThermalStandard(nothing))
    catch e
        sprint(showerror, e)
    end
    @test occursin("requires an explicit units argument", msg)
end
