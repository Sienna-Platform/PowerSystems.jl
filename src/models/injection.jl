"""
Set the dynamic injector for a static injection device.

Passes `nothing` to remove an existing dynamic injector from the device. Throws
`ArgumentError` if the device already has a dynamic injector and a non-`nothing` value
is provided.

# Arguments
- `static_injector::StaticInjection`: The static injection device.
- `dynamic_injector::Union{Nothing, DynamicInjection}`: The dynamic injector to set,
  or `nothing` to remove it.

See also: [`get_dynamic_injector`](@ref)
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
