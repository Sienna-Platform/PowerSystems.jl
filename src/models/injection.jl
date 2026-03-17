"""
Set the dynamic injector for a static injection device.

This method is for internal use only.

# Arguments
- `static_injector::StaticInjection`: The static injection device.
- `dynamic_injector::Union{Nothing, DynamicInjection}`: The dynamic injector to set,
  or `nothing` to remove it.
"""
function set_dynamic_injector!(
    static_injector::StaticInjection,
    dynamic_injector::Union{Nothing, DynamicInjection},
)
    current_dynamic_injector = get_dynamic_injector(static_injector)
    if !isnothing(current_dynamic_injector) && !isnothing(dynamic_injector)
        throw(
            ArgumentError(
                "cannot assign a dynamic injector on a device that already has one",
            ),
        )
    end

    # All of these types implement this field.
    static_injector.dynamic_injector = dynamic_injector
    return
end
