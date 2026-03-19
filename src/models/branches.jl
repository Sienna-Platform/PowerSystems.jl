"""
    Branch

Supertype for all transmission branches in a power system.

Concrete subtypes include [`AreaInterchange`](@ref). Abstract subtypes include
[`ACBranch`](@ref) (AC transmission) and [`DCBranch`](@ref) (DC transmission).

See also: [`Device`](@ref), [`ACBranch`](@ref), [`DCBranch`](@ref)
"""
abstract type Branch <: Device end

"""
    ACBranch

Supertype for all AC branches connecting AC nodes ([`ACBus`](@ref)) or Areas.

Abstract subtypes include [`ACTransmission`](@ref) (AC transmission lines and transformers)
and [`TwoTerminalHVDC`](@ref) (two-terminal HVDC links between AC buses).

See also: [`Branch`](@ref), [`DCBranch`](@ref), [`ACTransmission`](@ref), [`TwoTerminalHVDC`](@ref)
"""
abstract type ACBranch <: Branch end

"""
    ACTransmission

Supertype for all AC transmission devices connecting AC nodes only.

Concrete subtypes include [`Line`](@ref), [`MonitoredLine`](@ref), and
[`DiscreteControlledACBranch`](@ref). Abstract subtypes include
[`TwoWindingTransformer`](@ref) and [`ThreeWindingTransformer`](@ref).

See also: [`ACBranch`](@ref), [`TwoWindingTransformer`](@ref), [`ThreeWindingTransformer`](@ref)
"""
abstract type ACTransmission <: ACBranch end

"""
    TwoWindingTransformer

Supertype for all two-winding transformer types.

Concrete subtypes include [`Transformer2W`](@ref), [`TapTransformer`](@ref), and
[`PhaseShiftingTransformer`](@ref).

See also: [`ACTransmission`](@ref), [`ThreeWindingTransformer`](@ref)
"""
abstract type TwoWindingTransformer <: ACTransmission end

"""
    ThreeWindingTransformer

Supertype for all three-winding transformer types.

Concrete subtypes include [`Transformer3W`](@ref) and [`PhaseShiftingTransformer3W`](@ref).

See also: [`ACTransmission`](@ref), [`TwoWindingTransformer`](@ref)
"""
abstract type ThreeWindingTransformer <: ACTransmission end

"""
    TwoTerminalHVDC

Supertype for all two-terminal HVDC transmission devices between AC buses.

Not to be confused with [`DCBranch`](@ref), which connects DC nodes. Concrete subtypes
include [`TwoTerminalGenericHVDCLine`](@ref), [`TwoTerminalLCCLine`](@ref), and
[`TwoTerminalVSCLine`](@ref).

See also: [`ACBranch`](@ref), [`DCBranch`](@ref)
"""
abstract type TwoTerminalHVDC <: ACBranch end

"""
    DCBranch

Supertype for all DC branches connecting DC nodes ([`DCBus`](@ref)) only.

Concrete subtypes include [`TModelHVDCLine`](@ref).

See also: [`Branch`](@ref), [`ACBranch`](@ref), [`TwoTerminalHVDC`](@ref)
"""
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
