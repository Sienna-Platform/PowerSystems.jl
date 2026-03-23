"""
Add a new subsystem to the system.

Subsystems are named groupings of components within a [`System`](@ref), useful for
representing e.g., regional partitions or study areas. Components must be added
separately via [`add_component_to_subsystem!`](@ref).

Throws `ArgumentError` if the maximum number of subsystems has been reached.

See also: [`remove_subsystem!`](@ref), [`get_subsystems`](@ref)
"""
function add_subsystem!(sys::System, subsystem_name::AbstractString)
    _check_num_subsystems(sys)
    IS.add_subsystem!(sys.data, subsystem_name)
end

"""
Return the number of subsystems stored in the system.

See also: [`get_subsystems`](@ref), [`add_subsystem!`](@ref)
"""
get_num_subsystems(sys::System) = IS.get_num_subsystems(sys.data)

"""
Return an iterator of subsystem name strings stored in the system.

See also: [`add_subsystem!`](@ref), [`get_num_subsystems`](@ref), [`get_subsystem_components`](@ref)
"""
get_subsystems(sys::System) = IS.get_subsystems(sys.data)

"""
Remove a subsystem from the system.

Throws `ArgumentError` if the subsystem name is not stored.

See also: [`add_subsystem!`](@ref), [`get_subsystems`](@ref)
"""
remove_subsystem!(sys::System, subsystem_name::AbstractString) =
    IS.remove_subsystem!(sys.data, subsystem_name)

"""
Return true if the system has one or more subsystems.

See also: [`get_subsystems`](@ref), [`add_subsystem!`](@ref)
"""
function has_subsystems(sys::System)
    for _ in get_subsystems(sys)
        return true
    end

    return false
end

"""
Add a component to a subsystem.

The subsystem must already exist (see [`add_subsystem!`](@ref)). If the component is a
[`StaticInjectionSubsystem`](@ref), all of its subcomponents are also added.

Throws `ArgumentError` if the subsystem name is not stored.

See also: [`remove_component_from_subsystem!`](@ref), [`get_subsystem_components`](@ref)
"""
function add_component_to_subsystem!(
    sys::System,
    subsystem_name::AbstractString,
    component::Component,
)
    IS.add_component_to_subsystem!(sys.data, subsystem_name, component)
    handle_component_addition_to_subsystem!(sys, subsystem_name, component)
    return
end

"""
Peforms component-type-specific postprocessing when a component is added to a subsystem.
"""
handle_component_addition_to_subsystem!(
    ::System,
    subsystem_name::AbstractString,
    ::Component,
) = nothing

"""
Peforms component-type-specific postprocessing when a component is removed from a subsystem.
"""
handle_component_removal_from_subsystem!(
    ::System,
    subsystem_name::AbstractString,
    ::Component,
) = nothing

function handle_component_addition_to_subsystem!(
    sys::System,
    subsystem_name::AbstractString,
    component::StaticInjectionSubsystem,
)
    for subcomponent in get_subcomponents(component)
        if !is_assigned_to_subsystem(sys, subcomponent, subsystem_name)
            add_component_to_subsystem!(sys, subsystem_name, subcomponent)
        end
    end
end

function handle_component_removal_from_subsystem!(
    sys::System,
    subsystem_name::AbstractString,
    component::StaticInjectionSubsystem,
)
    for subcomponent in get_subcomponents(component)
        if is_assigned_to_subsystem(sys, subcomponent, subsystem_name)
            remove_component_from_subsystem!(sys, subsystem_name, subcomponent)
        end
    end
end

"""
Return an iterator of all components in the subsystem.

Throws `ArgumentError` if the subsystem name is not stored.

See also: [`add_component_to_subsystem!`](@ref), [`get_subsystems`](@ref)
"""
get_subsystem_components(sys::System, subsystem_name::AbstractString) =
    IS.get_subsystem_components(sys.data, subsystem_name)

"""
Remove a component from a subsystem.

If the component is a [`StaticInjectionSubsystem`](@ref), all of its subcomponents are
also removed from the subsystem.

Throws `ArgumentError` if the subsystem name or component is not stored.

See also: [`add_component_to_subsystem!`](@ref), [`get_subsystem_components`](@ref)
"""
function remove_component_from_subsystem!(
    sys::System,
    subsystem_name::AbstractString,
    component::Component,
)
    IS.remove_component_from_subsystem!(sys.data, subsystem_name, component)
    handle_component_removal_from_subsystem!(sys, subsystem_name, component)
    return
end

remove_component_from_subsystems!(
    sys::System,
    component::Component,
) = remove_component_from_subsystems!(sys.data, component)

"""
Return true if the component is assigned to the subsystem.

See also: [`is_assigned_to_subsystem`](@ref), [`get_subsystem_components`](@ref), [`add_component_to_subsystem!`](@ref)
"""
has_component(
    sys::System,
    subsystem_name::AbstractString,
    component::Component,
) = IS.has_component(sys.data, subsystem_name, component)

"""
Return a `Vector` of subsystem name strings that contain the component.

See also: [`is_assigned_to_subsystem`](@ref), [`add_component_to_subsystem!`](@ref)
"""
get_assigned_subsystems(
    sys::System,
    component::Component,
) = IS.get_assigned_subsystems(sys.data, component)

"""
Return true if the component is assigned to any subsystem.

See also: [`is_assigned_to_subsystem(sys, component, subsystem_name)`](@ref is_assigned_to_subsystem(::System, ::Component, ::AbstractString)),
[`get_assigned_subsystems`](@ref)
"""
is_assigned_to_subsystem(sys::System, component::Component) =
    IS.is_assigned_to_subsystem(sys.data, component)

"""
Return true if the component is assigned to the named subsystem.

See also: [`is_assigned_to_subsystem(sys, component)`](@ref is_assigned_to_subsystem(::System, ::Component)),
[`get_assigned_subsystems`](@ref)
"""
is_assigned_to_subsystem(
    sys::System,
    component::Component,
    subsystem_name::AbstractString,
) = IS.is_assigned_to_subsystem(sys.data, component, subsystem_name)

# Utility function, not for export
get_component_uuids(sys::System, subsystem_name::AbstractString) =
    IS.get_component_uuids(sys.data, subsystem_name)

function check_subsystems(sys::System, component::Component)
    _check_arc_consistency(sys, component)
    _check_branch_consistency(sys, component)
    _check_device_service_consistency(sys, component)
    _check_subcomponent_consistency(sys, component)
    _check_topological_consistency(sys, component)
    return
end

function _check_num_subsystems(sys::System)
    num_buses = length(sys.bus_numbers)
    if get_num_subsystems(sys) >= num_buses
        throw(
            IS.InvalidValue(
                "The number of subsystems cannot exceed the number of buses: $num_buses",
            ),
        )
    end
end

_check_arc_consistency(::System, ::Component) = nothing
_check_branch_consistency(::System, ::Component) = nothing
_check_device_service_consistency(::System, ::Component) = nothing
_check_subcomponent_consistency(::System, ::Component) = nothing

function _check_arc_consistency(sys::System, arc::Arc)
    msg = "An arc must be assigned to the same subystems as its buses."
    _check_subsystem_assignments(sys, arc, get_from(arc), msg; symmetric_diff = false)
    _check_subsystem_assignments(sys, arc, get_to(arc), msg; symmetric_diff = false)
end

function _check_branch_consistency(sys::System, branch::Branch)
    msg = "A branch must be assigned to the same subystems as its arc."
    _check_subsystem_assignments(sys, branch, get_arc(branch), msg; symmetric_diff = true)
end

function _check_branch_consistency(
    sys::System,
    branch::ThreeWindingTransformer,
)
    msg = "A branch must be assigned to the same subystems as its arc."
    arcs = [
        get_primary_star_arc(branch),
        get_secondary_star_arc(branch),
        get_tertiary_star_arc(branch),
    ]
    for arc in arcs
        _check_subsystem_assignments(sys, branch, arc, msg; symmetric_diff = true)
    end
end

function _check_branch_consistency(sys::System, branch::AreaInterchange)
    msg = "An area interchange must be assigned to the same subystems as its areas."
    _check_subsystem_assignments(
        sys,
        branch,
        get_from_area(branch),
        msg;
        symmetric_diff = false,
    )
    _check_subsystem_assignments(
        sys,
        branch,
        get_to_area(branch),
        msg;
        symmetric_diff = false,
    )
end

function _check_subcomponent_consistency(sys::System, component::StaticInjectionSubsystem)
    for subcomponent in get_subcomponents(component)
        _check_subsystem_assignments(
            sys,
            component,
            subcomponent,
            "StaticInjectionSubsystems and their subcomponents be assigned to the same subsystems.";
            symmetric_diff = true,
        )
    end
end

function _check_topological_consistency(sys::System, component::Component)
    for name in fieldnames(typeof(component))
        val = getproperty(component, name)
        if val isa Topology
            _check_subsystem_assignments(
                sys,
                component,
                val,
                "A component must be assigned to at least one subsystem as its topological component(s).";
                symmetric_diff = false,
            )
        end
    end
end

function _check_device_service_consistency(sys::System, device::Device)
    if !supports_services(device)
        return
    end
    for service in get_services(device)
        _check_subsystem_assignments(
            sys,
            device,
            service,
            "A service must be assigned to the same subsystems as its contributing devices.";
            symmetric_diff = true,
        )
    end
    return
end

function _check_subsystem_assignments(
    sys::System,
    component1::Component,
    component2::Component,
    message::AbstractString;
    symmetric_diff::Bool,
)
    subsys1 = get_assigned_subsystems(sys, component1)
    subsys2 = get_assigned_subsystems(sys, component2)
    diff_method = symmetric_diff ? symdiff : setdiff
    diff = diff_method(subsys1, subsys2)
    if !isempty(diff)
        throw(
            IS.InvalidValue(
                message *
                "$(summary(component1)): $subsys1 " *
                "$(summary(component2)): $subsys2 " *
                "diff: $diff",
            ),
        )
    end
end
