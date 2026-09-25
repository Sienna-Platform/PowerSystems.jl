# Hand-written behavior for the descriptor-generated `TransformerCircuit`.

has_control(w::TransformerCircuit) =
    get_control_objective(w) != TransformerControlObjective.UNDEFINED

const _PHASE_SHIFT_OBJECTIVES = (
    TransformerControlObjective.ACTIVE_POWER_FLOW,
    TransformerControlObjective.ACTIVE_POWER_FLOW_DISABLED,
    TransformerControlObjective.ASYMMETRIC_ACTIVE_POWER_FLOW,
    TransformerControlObjective.ASYMMETRIC_ACTIVE_POWER_FLOW_DISABLED,
)

"""
    is_phase_shifting(w::TransformerCircuit)

`true` if the circuit has a nonzero phase-shift angle or an active-power control objective.
This is the canonical predicate; downstream packages must not re-derive it from raw fields.
"""
function is_phase_shifting(w::TransformerCircuit)
    !iszero(get_α(w)) && return true
    return get_control_objective(w) in _PHASE_SHIFT_OBJECTIVES
end

Base.summary(
    w::TransformerCircuit,
) = "TransformerCircuit($(summary(get_from(get_arc(w)))) → $(summary(get_to(get_arc(w)))))"

# Stores its units anchor directly rather than through an `InfrastructureSystemsInternal`, so
# the generic `get_internal` forwarding in IS does not apply.
IS.get_base_value(w::TransformerCircuit) = w.base_value
function IS.set_base_value!(w::TransformerCircuit, val::Union{Float64, Nothing})
    w.base_value = val
    return
end

get_circuits(t::TwoWindingTransformer) = (get_circuit(t),)
get_circuits(t::ThreeWindingTransformer) =
    (get_primary_circuit(t), get_secondary_circuit(t), get_tertiary_circuit(t))

# The circuit fields are `exclude_setter: true` in the descriptor: codegen's plain
# `value.circuit = val` would leave the new circuit with a stale or missing `base_value`, and
# its explicit-units getters would then silently misbehave.
"""Set [`TwoWindingTransformer`](@ref) `circuit`, propagating this transformer's units anchor to the new circuit."""
function set_circuit!(t::TwoWindingTransformer, w::TransformerCircuit)
    setfield!(t, :circuit, w)
    IS.set_base_value!(w, IS.get_base_value(t))
    return
end

"""Set [`ThreeWindingTransformer`](@ref) `primary_circuit`, propagating this transformer's units anchor to the new circuit."""
function set_primary_circuit!(t::ThreeWindingTransformer, w::TransformerCircuit)
    setfield!(t, :primary_circuit, w)
    IS.set_base_value!(w, IS.get_base_value(t))
    return
end

"""Set [`ThreeWindingTransformer`](@ref) `secondary_circuit`, propagating this transformer's units anchor to the new circuit."""
function set_secondary_circuit!(t::ThreeWindingTransformer, w::TransformerCircuit)
    setfield!(t, :secondary_circuit, w)
    IS.set_base_value!(w, IS.get_base_value(t))
    return
end

"""Set [`ThreeWindingTransformer`](@ref) `tertiary_circuit`, propagating this transformer's units anchor to the new circuit."""
function set_tertiary_circuit!(t::ThreeWindingTransformer, w::TransformerCircuit)
    setfield!(t, :tertiary_circuit, w)
    IS.set_base_value!(w, IS.get_base_value(t))
    return
end

"""
    get_available(t)

A transformer is available if any of its circuits is available; there is no parent-level
stored flag. Note that `set_available!(t, true)` re-energizes ALL circuits, including any
that were individually out beforehand, so read-then-write is lossy.
"""
get_available(t::Union{TwoWindingTransformer, ThreeWindingTransformer}) =
    any(get_available, get_circuits(t))

function set_available!(
    t::Union{TwoWindingTransformer, ThreeWindingTransformer},
    val::Bool,
)
    foreach(w -> set_available!(w, val), get_circuits(t))
    return val
end

is_phase_shifting(t::Union{TwoWindingTransformer, ThreeWindingTransformer}) =
    any(is_phase_shifting, get_circuits(t))

# Without these overrides the generic `InfrastructureSystemsType` path would serialize
# `arc::Arc` inline instead of as an id reference, and read-back would error: `Arc`'s
# `Bus`-typed fields are abstract, so `fieldnames` on them fails. `TransformerCircuit` is in
# `_CONTAINS_SHOULD_ENCODE` (`serialization.jl`) for the same reason. `base_value` is runtime
# state repopulated by `add_component!`, so it must never be serialized.
function IS.serialize(w::TransformerCircuit)
    data = Dict{String, Any}()
    for name in fieldnames(TransformerCircuit)
        name === :base_value && continue
        data[string(name)] = serialize_id_handling(getfield(w, name))
    end
    IS.add_serialization_metadata!(data, TransformerCircuit)
    return data
end

function IS.deserialize(
    ::Type{TransformerCircuit},
    data::Dict,
    component_cache::Dict,
)
    vals = Dict{Symbol, Any}()
    for (fname, ftype) in
        zip(fieldnames(TransformerCircuit), fieldtypes(TransformerCircuit))
        fname === :base_value && continue
        vals[fname] = deserialize_id_handling(ftype, data[string(fname)], component_cache)
    end
    return TransformerCircuit(; vals..., base_value = nothing, input_basis = u"CU")
end
