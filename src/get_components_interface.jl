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
Return an iterator of components of a given `Type` from a [`System`](@ref).

`T` can be a concrete or abstract [`Component`](@ref) type from the [Type Tree](@ref).
Call collect on the result if an array is desired.

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
Return a vector of components that are attached to the supplemental attribute.

# Arguments
- `sys::System`: the `System` to search
- `attribute::SupplementalAttribute`: Only return components associated with this attribute.
- `component_type::Union{Nothing, <:Component}`: Optional type of the components to return.
  Can be concrete or abstract. If not provided, all components associated with the attribute
  will be returned.
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

"""
Return a vector of components that are associated to one or more supplemental attributes of
the given type.
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
Return an iterator of components of a given `Type` from a [`System`](@ref), using an
additional filter

`T` can be a concrete or abstract [`Component`](@ref) type from the [Type Tree](@ref).
Call collect on the result if an array is desired.

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
Get the component by UUID.
"""
get_component(sys::System, uuid::Base.UUID) = IS.get_component(sys, uuid)
get_component(sys::System, uuid::String) = IS.get_component(sys, uuid)

"""
Get the component of type T with name. Returns nothing if no component matches. If T is an abstract
type then the names of components across all subtypes of T must be unique.

See [`get_components_by_name`](@ref) for abstract types with non-unique names across subtypes.

Throws ArgumentError if T is not a concrete type and there is more than one component with
    requested name
"""
get_component(::Type{T}, sys::System, name::AbstractString) where {T <: Component} =
    IS.get_component(T, sys, name)

# get_available_components
"""
Like [`get_components`](@ref get_components(
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
    ) where {T <: Component}
) but returns only components that are [`get_available`](@ref).
```
"""
get_available_components(
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
) where {T <: Component} =
    IS.get_available_components(T, sys; subsystem_name = subsystem_name)

"""
Like [`get_associated_components`](@ref) but returns only components that are
[`get_available`](@ref).
"""
get_available_components(sys::System, attribute::SupplementalAttribute) =
    IS.get_available_components(sys, attribute)

"""
Like [`get_components`](@ref get_components(
    filter_func::Function,
    ::Type{T},
    sys::System;
    subsystem_name = nothing,
    ) where {T <: Component}
) but returns only components that are [`get_available`](@ref).
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
Get the available component by UUID.
"""
get_available_component(sys::System, uuid::Base.UUID) =
    IS.get_available_component(sys, uuid)
get_available_component(sys::System, uuid::String) = IS.get_available_component(sys, uuid)

"""
Like [`get_component`](@ref) but also returns `nothing` if the component is not [`get_available`](@ref).
"""
get_available_component(::Type{T}, sys::System, args...; kwargs...) where {T <: Component} =
    IS.get_available_component(T, sys, args...; kwargs...)
