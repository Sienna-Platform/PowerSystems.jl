const _ENCODE_AS_ID = (
    Arc,
    Area,
    Bus,
    LoadZone,
    Topology,
    DynamicInjection,
    StaticInjection,
    HydroReservoir,
    Component,
    Vector{Service},
    Vector{Reserve},
    Vector{HydroUnit},
    Vector{Device},
    Vector{ACBus},
    Vector{TradingHub},
)

should_encode_as_id(val) = any(x -> val isa x, _ENCODE_AS_ID)
# The field's declared type may be nullable, so match against `Union{Nothing, x}`.
should_encode_as_id(::Type{T}) where {T} =
    any(x -> T <: Union{Nothing, x}, _ENCODE_AS_ID)

const _CONTAINS_SHOULD_ENCODE = Union{
    Component,
    MarketBidCost,
    MarketBidTimeSeriesCost,
    ImportExportCost,
    ImportExportTimeSeriesCost,
    TransformerCircuit,
}  # PSY types with fields that we should_encode_as_id

function IS.serialize(component::T) where {T <: _CONTAINS_SHOULD_ENCODE}
    @debug "serialize" _group = IS.LOG_GROUP_SERIALIZATION component T
    data = Dict{String, Any}()
    for name in fieldnames(T)
        val = serialize_id_handling(getfield(component, name))
        if name == :ext
            if !IS.is_ext_valid_for_serialization(val)
                error(
                    "component type=$T name=$(get_name(component)) has a value in its " *
                    "ext field that cannot be serialized.",
                )
            end
        end
        data[string(name)] = val
    end

    IS.add_serialization_metadata!(data, T)

    # Sets IS.CONSTRUCT_WITH_PARAMETERS_KEY so IS.get_type_from_serialization_metadata
    # reconstructs type parameters on deserialize. Needed because Reserve{T}/
    # OfflineReserve{U}/GroupReserve{T} are parametric families with no one clean shared
    # supertype to dispatch this on generically. IS's own serialization.jl labels this the
    # "workaround for PSY.Reserve subtypes".
    if T <: Reserve || T <: OfflineReserve || T <: GroupReserve
        data[IS.METADATA_KEY][IS.CONSTRUCT_WITH_PARAMETERS_KEY] = true
    end

    return data
end

"""
Serialize the value, encoding referenced components by their integer id where necessary.
"""
function serialize_id_handling(val)
    if should_encode_as_id(val)
        if val isa Array
            value = IS.get_id.(val)
        elseif val === nothing
            value = nothing
        else
            value = IS.get_id(val)
        end
    else
        value = val
    end

    return serialize(value)
end

function IS.deserialize(
    ::Type{T},
    data::Dict,
    component_cache::Dict,
) where {T <: _CONTAINS_SHOULD_ENCODE}
    @debug "deserialize Component" _group = IS.LOG_GROUP_SERIALIZATION T data
    vals = Dict{Symbol, Any}()
    for (name, type) in zip(fieldnames(T), fieldtypes(T))
        field_name = string(name)
        if haskey(data, field_name)
            val = data[field_name]
        else
            continue
        end
        if val isa Dict && haskey(val, IS.METADATA_KEY)
            vals[name] = deserialize_id_handling(
                IS.get_type_from_serialization_metadata(IS.get_serialization_metadata(val)),
                val,
                component_cache,
            )
        else
            vals[name] = deserialize_id_handling(type, val, component_cache)
        end
    end

    type = IS.get_type_from_serialization_metadata(data[IS.METADATA_KEY])
    _takes_input_basis(type) && return type(; vals..., input_basis = u"CU")
    return type(; vals...)
end

function IS.deserialize(::Type{Device}, data::Dict)
    error("This form of IS.deserialize is not supported for Devices")
    return
end

function _component_from_cache(id::Int, component_cache)
    return get(component_cache, id) do
        error(
            "id $id not found in component cache while deserializing system. \
             This may indicate that a component was removed improperly leaving an id \
             reference inside the top level component. This can happen when removing Arc, Area, ACBus or LoadZone \
             components for example. \
             Check the documentation for the `remove_component!` function and review your workflow. \
             ",
        )
    end
end

"""
Deserialize the value, converting referenced integer ids back to components where necessary.
"""
function deserialize_id_handling(field_type, val, component_cache)
    @debug "deserialize_id_handling" _group = IS.LOG_GROUP_SERIALIZATION field_type val
    if val === nothing
        value = val
    elseif should_encode_as_id(field_type)
        if field_type <: Vector
            _vals = field_type()
            sizehint!(_vals, length(val))
            for _val in val
                push!(_vals, _component_from_cache(Int(_val), component_cache))
            end
            value = _vals
        else
            value = _component_from_cache(Int(val), component_cache)
        end
    elseif field_type <: _CONTAINS_SHOULD_ENCODE
        value = IS.deserialize(field_type, val, component_cache)
    elseif field_type <: Union{Nothing, _CONTAINS_SHOULD_ENCODE}
        value = IS.deserialize(field_type.b, val, component_cache)
    elseif field_type <: InfrastructureSystemsType
        value = deserialize(field_type, val)
    elseif field_type isa Union && field_type.a <: Nothing && !(field_type.b <: Union)
        # Nothing has already been handled. Apply the second type as long as there isn't a
        # third. Julia appears to always put the Nothing in field a.
        value = deserialize(field_type.b, val)
    else
        value = deserialize(field_type, val)
    end

    return value
end
