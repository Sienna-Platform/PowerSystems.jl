# The longstanding status quo in Sienna has been for `PSY.get_components` to be distinct
# from `IS.get_components`, mostly so that PowerSystems users aren't confused by all the
# InfrastructureSystems methods. This lack of a unified interface on "things with
# components" has begun to cause problems, most notably for ComponentSelector. Therefore,
# the new plan is:
#   1. Implement, wherever relevant, methods of the IS `get_components`-like functions
#      listed below on PSY data structures.
#   2. Add, in this file, methods of the PSY `get_components`-like functions that purely
#      redirect to the IS versions and have the documentation PSY users should see. Never
#      add actual functionality in these PSY methods; they must only redirect to the IS
#      versions. Purely to facilitate neater documentation, add `ComponentSelector`-related
#      methods in the follow-on file `component_selector_interface.jl` instead.
#   3. In downstream Sienna packages like PowerSimulations that seek to add their own
#      `get_components`-like methods on their own data structures that show up in
#      user-friendly documentation, do the same thing: add the implementation in the IS
#      method and add a PSY method that purely redirects.
#   4. Internal code designed to work with all "things with components" should use the IS
#      functions, not the PSY ones.

# This design preserves the simplified interface presented to the casual PSY user while
# allowing for better cross-package integration behind the scenes. It also enables a quick
# switch to a design where we no longer maintain two versions of each `get_components`-like
# function at the cost of slightly more confusing documentation -- simply import the IS
# versions into PowerSystems and delete this file (and analogous redirects in downstream
# packages). See https://github.com/NREL-Sienna/InfrastructureSystems.jl/issues/388.

# Here is the current list of "`get_components`-like functions" to which this plan applies:
#  - `get_components`
#  - `get_component`
#  - `get_available_components`
#  - `get_available_component`
#  - `get_groups`
#  - `get_available_groups`

# get_components
"""
    get_components(::Type{T}, sys::System; subsystem_name) where {T <: Component}

Return an iterator of components of type `T` from a [`System`](@ref).

`T` can be a concrete or abstract [`Component`](@ref) type from the [Type Tree](@ref).
Call `collect` on the result if an array is desired.

# Arguments
- `T`: The component type to retrieve. Can be concrete or abstract.
- `sys::System`: The system to search.
- `subsystem_name::Union{Nothing, String}`: (default: `nothing`) If provided, restrict
    results to the named subsystem.

# Examples
```julia
iter = get_components(ThermalStandard, sys)
iter = get_components(Generator, sys)
generators = collect(get_components(Generator, sys))
```

See also: [`iterate_components`](@ref), [`get_components` with a filter](@ref get_components(
    filter_func::Function,
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
) where {T <: Component}),
[`get_available_components`](@ref), [`get_buses`](@ref)
"""
get_components(::Type{T}, sys::System; subsystem_name = nothing) where {T <: Component} =
    IS.get_components(T, sys; subsystem_name = subsystem_name)

"""
    get_associated_components(sys::System, attribute::SupplementalAttribute; component_type)

Return a vector of components attached to the given supplemental attribute.

# Arguments
- `sys::System`: The system to search.
- `attribute::SupplementalAttribute`: The supplemental attribute whose associated components
    are returned.
- `component_type::Union{Nothing, Type{<:Component}}`: (default: `nothing`) If provided,
    only return components of this type. Can be concrete or abstract.

See also: [`get_associated_components(sys, attribute_type)`](@ref get_associated_components(
    sys::System,
    attribute_type::Type{<:SupplementalAttribute};
    component_type,
)), [`add_supplemental_attribute!`](@ref)
"""
function get_associated_components(
    sys::System,
    attribute::SupplementalAttribute;
    component_type::Union{Nothing, Type{<:Component}} = nothing,
)
    return IS.get_associated_components(
        sys.data,
        attribute;
        component_type = component_type,
    )
end

@deprecate get_components(sys::System, attribute::SupplementalAttribute) get_associated_components(
    sys,
    attribute,
)

"""
    get_associated_components(sys::System, attribute_type::Type{<:SupplementalAttribute}; component_type)

Return a vector of components that have at least one supplemental attribute of
`attribute_type` attached.

# Arguments
- `sys::System`: The system to search.
- `attribute_type::Type{<:SupplementalAttribute}`: The supplemental attribute type to
    filter by. Can be concrete or abstract.
- `component_type::Union{Nothing, Type{<:Component}}`: (default: `nothing`) If provided,
    only return components of this type. Can be concrete or abstract.

See also: [`get_associated_components(sys, attribute)`](@ref get_associated_components(
    sys::System,
    attribute::SupplementalAttribute;
    component_type,
)), [`add_supplemental_attribute!`](@ref)
"""
function get_associated_components(
    sys::System,
    attribute_type::Type{<:SupplementalAttribute};
    component_type::Union{Nothing, Type{<:Component}} = nothing,
)
    return IS.get_associated_components(
        sys.data,
        attribute_type;
        component_type = component_type,
    )
end

"""
    get_components(filter_func::Function, ::Type{T}, sys::System; subsystem_name) where {T <: Component}

Return an iterator of components of type `T` from a [`System`](@ref) that satisfy
`filter_func`.

`T` can be a concrete or abstract [`Component`](@ref) type from the [Type Tree](@ref).
Call `collect` on the result if an array is desired.

# Arguments
- `filter_func::Function`: A single-argument function returning `true` for components to
    include.
- `T`: The component type to retrieve. Can be concrete or abstract.
- `sys::System`: The system to search.
- `subsystem_name::Union{Nothing, String}`: (default: `nothing`) If provided, restrict
    results to the named subsystem.

# Examples
```julia
iter_coal = get_components(x -> get_fuel(x) == ThermalFuels.COAL, Generator, sys)
pv_gens =
    collect(get_components(x -> get_prime_mover_type(x) == PrimeMovers.PVe, Generator, sys))
```

See also: [`get_components`](@ref get_components(
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
) where {T <: Component}), [`get_available_components`](@ref),
[`get_buses`](@ref)
"""
get_components(
    filter_func::Function,
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
) where {T <: Component} =
    IS.get_components(filter_func, T, sys; subsystem_name = subsystem_name)

# get_component
"""
    get_component(sys::System, uuid::Union{Base.UUID, String})

Return the component with the given UUID, or `nothing` if not found.

# Arguments
- `sys::System`: The system to search.
- `uuid::Union{Base.UUID, String}`: The UUID of the component.

See also: [`get_component(T, sys, name)`](@ref get_component(
    ::Type{T},
    sys::System,
    name::AbstractString,
) where {T <: Component})
"""
get_component(sys::System, uuid::Base.UUID) = IS.get_component(sys, uuid)
get_component(sys::System, uuid::String) = IS.get_component(sys, uuid)

"""
    get_component(::Type{T}, sys::System, name::AbstractString) where {T <: Component}

Return the component of type `T` with the given name, or `nothing` if no match is found.

If `T` is an abstract type, names must be unique across all subtypes. Use
[`get_components_by_name`](@ref) when names are not unique across subtypes.

# Arguments
- `T`: The component type to retrieve. Can be concrete or abstract.
- `sys::System`: The system to search.
- `name::AbstractString`: The name of the component.

# Throws
- `ArgumentError`: if `T` is abstract and more than one component with the given name
    exists across subtypes.

See also: [`get_component(sys, uuid)`](@ref get_component(sys::System, uuid::Base.UUID)),
[`get_components_by_name`](@ref)
"""
get_component(::Type{T}, sys::System, name::AbstractString) where {T <: Component} =
    IS.get_component(T, sys, name)

# get_available_components
"""
    get_available_components(::Type{T}, sys::System; subsystem_name) where {T <: Component}

Return an iterator of available components of type `T` from a [`System`](@ref). A component
is available when [`get_available`](@ref) returns `true`. Equivalent to
[`get_components`](@ref) with a filter on availability.

`T` can be a concrete or abstract [`Component`](@ref) type from the [Type Tree](@ref).
Call `collect` on the result if an array is desired.

# Arguments
- `T`: The component type to retrieve. Can be concrete or abstract.
- `sys::System`: The system to search.
- `subsystem_name::Union{Nothing, String}`: (default: `nothing`) If provided, restrict
    results to the named subsystem.

# Examples
```julia
gens = get_available_components(ThermalStandard, sys)
gens = get_available_components(Generator, sys)
```

See also: [`get_components`](@ref get_components(
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
) where {T <: Component}), [`get_available`](@ref)
"""
get_available_components(
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
) where {T <: Component} =
    IS.get_available_components(T, sys; subsystem_name = subsystem_name)

"""
    get_available_components(sys::System, attribute::SupplementalAttribute)

Return an iterator of available components attached to a given supplemental attribute.
A component is available when [`get_available`](@ref) returns `true`.

# Arguments
- `sys::System`: The system to search.
- `attribute::SupplementalAttribute`: The supplemental attribute whose available associated
    components are returned.

See also: [`get_associated_components`](@ref), [`get_available`](@ref)
"""
get_available_components(sys::System, attribute::SupplementalAttribute) =
    IS.get_available_components(sys, attribute)

"""
    get_available_components(filter_func::Function, ::Type{T}, sys::System; subsystem_name) where {T <: Component}

Return an iterator of available components of type `T` that also satisfy `filter_func`.
A component is available when [`get_available`](@ref) returns `true`.

`T` can be a concrete or abstract [`Component`](@ref) type from the [Type Tree](@ref).
Call `collect` on the result if an array is desired.

# Arguments
- `filter_func::Function`: A single-argument function returning `true` for components to
    include.
- `T`: The component type to retrieve. Can be concrete or abstract.
- `sys::System`: The system to search.
- `subsystem_name::Union{Nothing, String}`: (default: `nothing`) If provided, restrict
    results to the named subsystem.

# Examples
```julia
gens = get_available_components(x -> get_fuel(x) == ThermalFuels.COAL, ThermalStandard, sys)
```

See also: [`get_components`](@ref get_components(
    filter_func::Function,
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
) where {T <: Component}), [`get_available`](@ref)
"""
get_available_components(
    filter_func::Function,
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
) where {T <: Component} =
    IS.get_available_components(filter_func, T, sys; subsystem_name = subsystem_name)

# get_available_component
"""
    get_available_component(sys::System, uuid::Union{Base.UUID, String})

Return the component with the given UUID if it is available, otherwise return `nothing`.
A component is available when [`get_available`](@ref) returns `true`.

# Arguments
- `sys::System`: The system to search.
- `uuid::Union{Base.UUID, String}`: The UUID of the component to retrieve.

See also: [`get_component(sys, uuid)`](@ref get_component(sys::System, uuid::Base.UUID)),
[`get_available`](@ref)
"""
get_available_component(sys::System, uuid::Base.UUID) =
    IS.get_available_component(sys, uuid)
get_available_component(sys::System, uuid::String) = IS.get_available_component(sys, uuid)

"""
    get_available_component(::Type{T}, sys::System, name::AbstractString) where {T <: Component}

Return the component of type `T` with the given name if it is available, otherwise return
`nothing`. A component is available when [`get_available`](@ref) returns `true`.

If `T` is an abstract type, names must be unique across all subtypes.

# Arguments
- `T`: The component type to retrieve. Can be concrete or abstract.
- `sys::System`: The system to search.
- `name::AbstractString`: The name of the component.

See also: [`get_component`](@ref), [`get_available`](@ref)
"""
get_available_component(::Type{T}, sys::System, args...; kwargs...) where {T <: Component} =
    IS.get_available_component(T, sys, args...; kwargs...)
