""" Supertype for all branches"""
abstract type Branch <: Device end

""" Supertype for all AC branches (branches connecting AC nodes or Areas)"""
abstract type ACBranch <: Branch end

""" Supertype for all AC transmission devices (devices connecting AC nodes only)"""
abstract type ACTransmission <: ACBranch end

""" Supertype for all Two Winding Transformer types"""
abstract type TwoWindingTransformer <: ACTransmission end

""" Supertype for all Three Winding Transformer types"""
abstract type ThreeWindingTransformer <: ACTransmission end

""" Supertype for all Two Terminal HVDC transmission devices between AC Buses. Not to be confused with [DCBranch](@ref)"""
abstract type TwoTerminalHVDC <: ACBranch end

""" Supertype for all DC branches (branches that connect only DC nodes)"""
abstract type DCBranch <: Branch end

"""
Return true since AC branches support services.

See also [`supports_services` for `Device`](@ref supports_services(::Device)),
[`supports_services` for `StaticInjection`](@ref supports_services(::StaticInjection)),
[`supports_services` for `HydroReservoir`](@ref supports_services(::HydroReservoir)),
[`supports_services` for `DynamicInjection`](@ref supports_services(::DynamicInjection)).
"""
function supports_services(::ACBranch)
    return true
end

"""
Return the "from" [`Bus`](@ref) of the branch.

# Arguments
- `b::Branch`: The branch.
"""
get_from_bus(b::Branch) = b.arc.from

"""
Return the "to" [`Bus`](@ref) of the branch.

# Arguments
- `b::Branch`: The branch.
"""
get_to_bus(b::Branch) = b.arc.to
