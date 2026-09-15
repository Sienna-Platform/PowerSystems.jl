#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SCRX <: AVR
        Ta_Tb::Float64
        Tb::Float64
        K::Float64
        Te::Float64
        Efd_lim::MinMax
        switch::Int
        rc_rfd::Float64
        V_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.T}
        internal::InfrastructureSystemsInternal
    end

This exciter is based on an IEEE type SCRX solid state exciter.  The output field voltage is varied by a control system to maintain the system voltage at Vref.  Please note that this exciter model has no initialization capabilities - this means that it will respond to whatever inputs it receives regardless of the state of the machine model

# Arguments
- `Ta_Tb::Float64`: Lead input constant ratio, validation range: `(0.05, 0.3)`
- `Tb::Float64`: Lag input constant in s, validation range: `(5, 20)`
- `K::Float64`: Regulator Gain, validation range: `(20, 100)`
- `Te::Float64`: Regulator Time Constant, validation range: `(0, 1)`
- `Efd_lim::MinMax`: Field Voltage regulator limits (regulator output) (Efd_min, Efd_max)
- `switch::Int`: Switch, validation range: `(0, 1)`
- `rc_rfd::Float64`: Field current capability. Set = 0 for negative current capability. Typical value 10, validation range: `(0, 10)`
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vr1: First integrator,
	Vr2: Second integrator
- `n_states::Int`: (**Do not modify.**) SCRX has 2 states
- `states_types::Vector{StateTypes.T}`: (**Do not modify.**) SCRX has 2 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct SCRX <: AVR
    "Lead input constant ratio"
    Ta_Tb::Float64
    "Lag input constant in s"
    Tb::Float64
    "Regulator Gain"
    K::Float64
    "Regulator Time Constant"
    Te::Float64
    "Field Voltage regulator limits (regulator output) (Efd_min, Efd_max)"
    Efd_lim::MinMax
    "Switch"
    switch::Int
    "Field current capability. Set = 0 for negative current capability. Typical value 10"
    rc_rfd::Float64
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	Vr1: First integrator,
	Vr2: Second integrator"
    states::Vector{Symbol}
    "(**Do not modify.**) SCRX has 2 states"
    n_states::Int
    "(**Do not modify.**) SCRX has 2 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.T}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function SCRX(Ta_Tb, Tb, K, Te, Efd_lim, switch, rc_rfd, V_ref=1.0, ext=Dict{String, Any}(), )
    SCRX(Ta_Tb, Tb, K, Te, Efd_lim, switch, rc_rfd, V_ref, ext, [:Vr1, :Vr2], 2, [StateTypes.Differential, StateTypes.Hybrid], InfrastructureSystemsInternal(), )
end

function SCRX(; Ta_Tb, Tb, K, Te, Efd_lim, switch, rc_rfd, V_ref=1.0, ext=Dict{String, Any}(), states=[:Vr1, :Vr2], n_states=2, states_types=[StateTypes.Differential, StateTypes.Hybrid], internal=InfrastructureSystemsInternal(), )
    SCRX(Ta_Tb, Tb, K, Te, Efd_lim, switch, rc_rfd, V_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function SCRX(::Nothing)
    SCRX(;
        Ta_Tb=0,
        Tb=0,
        K=0,
        Te=0,
        Efd_lim=(min=0.0, max=0.0),
        switch=0,
        rc_rfd=0,
        V_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`SCRX`](@ref) `Ta_Tb`."""
get_Ta_Tb(value::SCRX) = value.Ta_Tb
"""Get [`SCRX`](@ref) `Tb`."""
get_Tb(value::SCRX) = value.Tb
"""Get [`SCRX`](@ref) `K`."""
get_K(value::SCRX) = value.K
"""Get [`SCRX`](@ref) `Te`."""
get_Te(value::SCRX) = value.Te
"""Get [`SCRX`](@ref) `Efd_lim`."""
get_Efd_lim(value::SCRX) = value.Efd_lim
"""Get [`SCRX`](@ref) `switch`."""
get_switch(value::SCRX) = value.switch
"""Get [`SCRX`](@ref) `rc_rfd`."""
get_rc_rfd(value::SCRX) = value.rc_rfd
"""Get [`SCRX`](@ref) `V_ref`."""
get_V_ref(value::SCRX) = value.V_ref
"""Get [`SCRX`](@ref) `ext`."""
get_ext(value::SCRX) = value.ext
"""Get [`SCRX`](@ref) `states`."""
get_states(value::SCRX) = value.states
"""Get [`SCRX`](@ref) `n_states`."""
get_n_states(value::SCRX) = value.n_states
"""Get [`SCRX`](@ref) `states_types`."""
get_states_types(value::SCRX) = value.states_types
"""Get [`SCRX`](@ref) `internal`."""
get_internal(value::SCRX) = value.internal

"""Set [`SCRX`](@ref) `Ta_Tb`."""
set_Ta_Tb!(value::SCRX, val) = value.Ta_Tb = val
"""Set [`SCRX`](@ref) `Tb`."""
set_Tb!(value::SCRX, val) = value.Tb = val
"""Set [`SCRX`](@ref) `K`."""
set_K!(value::SCRX, val) = value.K = val
"""Set [`SCRX`](@ref) `Te`."""
set_Te!(value::SCRX, val) = value.Te = val
"""Set [`SCRX`](@ref) `Efd_lim`."""
set_Efd_lim!(value::SCRX, val) = value.Efd_lim = val
"""Set [`SCRX`](@ref) `switch`."""
set_switch!(value::SCRX, val) = value.switch = val
"""Set [`SCRX`](@ref) `rc_rfd`."""
set_rc_rfd!(value::SCRX, val) = value.rc_rfd = val
"""Set [`SCRX`](@ref) `V_ref`."""
set_V_ref!(value::SCRX, val) = value.V_ref = val
"""Set [`SCRX`](@ref) `ext`."""
set_ext!(value::SCRX, val) = value.ext = val
"""Set [`SCRX`](@ref) `states_types`."""
set_states_types!(value::SCRX, val) = value.states_types = val
