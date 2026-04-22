# A continuation of `get_components_interface.jl` to facilitate neater documentation of
# `ComponentSelector`. See the long comment at the top of that file.

# get_components
"""
Return the components of the [`System`](@ref) that make up the [`ComponentSelector`](@ref).
Optionally specify a filter function `scope_limiter` as the first argument to limit the
components that should be considered.

# Arguments

  - `scope_limiter::Union{Function, Nothing}`: see [`ComponentSelector`](@ref)
  - `selector::ComponentSelector`: the `ComponentSelector` whose components to retrieve
  - `sys::System`: the system from which to draw components
"""
get_components(
    scope_limiter::Union{Function, Nothing},
    selector::ComponentSelector,
    sys::System,
) =
    IS.get_components(scope_limiter, selector, sys)

"""
Return the components of the [`System`](@ref) that make up the [`ComponentSelector`](@ref).

# Arguments

  - `selector::ComponentSelector`: the `ComponentSelector` whose components to retrieve
  - `sys::System`: the system from which to draw components
"""
get_components(selector::ComponentSelector, sys::System) =
    IS.get_components(selector, sys)

# get_component
"""
Return the component of the [`System`](@ref) that makes up the
[`SingularComponentSelector`](@ref); `nothing` if there is none. Optionally specify a filter
function `scope_limiter` as the first argument to limit the components that should be
considered.

# Arguments

  - `scope_limiter::Union{Function, Nothing}`: see [`ComponentSelector`](@ref)
  - `selector::SingularComponentSelector`: the `SingularComponentSelector` whose component
    to retrieve
  - `sys::System`: the system from which to draw components
"""
get_component(
    scope_limiter::Union{Function, Nothing},
    selector::SingularComponentSelector,
    sys::System,
) =
    IS.get_component(scope_limiter, selector, sys)

"""
Return the component of the [`System`](@ref) that makes up the
[`SingularComponentSelector`](@ref); `nothing` if there is none.

# Arguments

  - `selector::SingularComponentSelector`: the `SingularComponentSelector` whose component to retrieve
  - `sys::System`: the system from which to draw components
"""
get_component(selector::SingularComponentSelector, sys::System) =
    IS.get_component(selector, sys)

# get_available_components
"""
Like [`get_components`](@ref get_components(
    scope_limiter::Union{Function, Nothing},
    selector::ComponentSelector,
    sys::System,
)) but only operates on components for which [`get_available`](@ref) is `true`.
"""
get_available_components(
    scope_limiter::Union{Function, Nothing},
    selector::ComponentSelector,
    sys::System,
) =
    IS.get_available_components(scope_limiter, selector::ComponentSelector, sys::System)

"""
Like [`get_components`](@ref get_components(selector::ComponentSelector, sys::System)) but
only operates on components for which [`get_available`](@ref) is `true`.
"""
get_available_components(selector::ComponentSelector, sys::System) =
    IS.get_available_components(selector::ComponentSelector, sys::System)

# get_available_component
"""
Like [`get_component`](@ref get_component(
    scope_limiter::Union{Function, Nothing},
    selector::IS.SingularComponentSelector,
    sys::System,
)) but only operates on components for which [`get_available`](@ref) is `true`.
"""
get_available_component(
    scope_limiter::Union{Function, Nothing},
    selector::IS.SingularComponentSelector,
    sys::System,
) =
    IS.get_available_component(scope_limiter, selector, sys)

"""
Like [`get_component`](@ref get_component(
    selector::IS.SingularComponentSelector,
    sys::System,
)) but only operates on components for which [`get_available`](@ref) is `true`.
"""
get_available_component(
    selector::IS.SingularComponentSelector,
    sys::System,
) =
    IS.get_available_component(selector, sys)

# get_groups
"""
Return the groups that make up the [`ComponentSelector`](@ref). Optionally specify a filter
function `scope_limiter` as the first argument to limit the components that should be
considered.

# Arguments

  - `scope_limiter::Union{Function, Nothing}`: see [`ComponentSelector`](@ref)
  - `selector::ComponentSelector`: the `ComponentSelector` whose groups to retrieve
  - `sys::System`: the system from which to draw components
"""
get_groups(
    scope_limiter::Union{Function, Nothing},
    selector::ComponentSelector,
    sys::System,
) =
    IS.get_groups(scope_limiter, selector, sys)

"""
Return the groups that make up the [`ComponentSelector`](@ref).

# Arguments

  - `selector::ComponentSelector`: the `ComponentSelector` whose groups to retrieve
  - `sys::System`: the system from which to draw components
"""
get_groups(selector::ComponentSelector, sys::System) =
    IS.get_groups(selector, sys)

# get_available_groups
"""
Like [`get_groups`](@ref get_groups(
    scope_limiter::Union{Function, Nothing},
    selector::ComponentSelector,
    sys::System,
)) but only operates on components for which [`get_available`](@ref) is `true`.
"""
get_available_groups(
    scope_limiter::Union{Function, Nothing},
    selector::ComponentSelector,
    sys::System,
) =
    IS.get_available_groups(scope_limiter, selector, sys)

"""
Like [`get_groups`](@ref get_groups(selector::ComponentSelector, sys::System)) but
only operates on components for which [`get_available`](@ref) is `true`.
"""
get_available_groups(selector::ComponentSelector, sys::System) =
    IS.get_available_groups(selector, sys)
