#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct HydroTurbineGov <: TurbineGov
        R::Float64
        r::Float64
        Tr::Float64
        Tf::Float64
        Tg::Float64
        VELM::Float64
        gate_position_limits::MinMax
        Tw::Float64
        At::Float64
        D_T::Float64
        q_nl::Float64
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

Hydro Turbine-Governor

# Arguments
- `R::Float64`: Permanent droop parameter, validation range: `(0, 0.1)`
- `r::Float64`: Temporary Droop, validation range: `(0, 2)`
- `Tr::Float64`: Governor time constant, validation range: `(eps(), 30)`
- `Tf::Float64`: Filter Time constant, validation range: `(eps(), 0.1)`
- `Tg::Float64`: Servo time constant, validation range: `(eps(), 1)`
- `VELM::Float64`: gate velocity limit, validation range: `(eps(), 0.3)`
- `gate_position_limits::MinMax`: Gate position limits
- `Tw::Float64`: water time constant, validation range: `(eps(), 3)`
- `At::Float64`: Turbine gain, validation range: `(0.8, 1.5)`
- `D_T::Float64`: Turbine Damping, validation range: `(0, 0.5)`
- `q_nl::Float64`: No-power flow, validation range: `(0, nothing)`
- `P_ref::Float64`: (default: `1.0`) Reference Power Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the HydroTurbineGov model are:
	x_g1: filter_output,
	x_g2: desired gate, 
	x_g3: gate opening, 
	x_g4: turbine flow
- `n_states::Int`: (**Do not modify.**) HYGOV has 4 states
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) HYGOV has 4 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct HydroTurbineGov <: TurbineGov
    "Permanent droop parameter"
    R::Float64
    "Temporary Droop"
    r::Float64
    "Governor time constant"
    Tr::Float64
    "Filter Time constant"
    Tf::Float64
    "Servo time constant"
    Tg::Float64
    "gate velocity limit"
    VELM::Float64
    "Gate position limits"
    gate_position_limits::MinMax
    "water time constant"
    Tw::Float64
    "Turbine gain"
    At::Float64
    "Turbine Damping"
    D_T::Float64
    "No-power flow"
    q_nl::Float64
    "Reference Power Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the HydroTurbineGov model are:
	x_g1: filter_output,
	x_g2: desired gate, 
	x_g3: gate opening, 
	x_g4: turbine flow"
    states::Vector{Symbol}
    "(**Do not modify.**) HYGOV has 4 states"
    n_states::Int
    "(**Do not modify.**) HYGOV has 4 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function HydroTurbineGov(R, r, Tr, Tf, Tg, VELM, gate_position_limits, Tw, At, D_T, q_nl, P_ref=1.0, ext=Dict{String, Any}(), )
    HydroTurbineGov(R, r, Tr, Tf, Tg, VELM, gate_position_limits, Tw, At, D_T, q_nl, P_ref, ext, [:x_g1, :x_g2, :x_g3, :x_g4], 4, [StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function HydroTurbineGov(; R, r, Tr, Tf, Tg, VELM, gate_position_limits, Tw, At, D_T, q_nl, P_ref=1.0, ext=Dict{String, Any}(), states=[:x_g1, :x_g2, :x_g3, :x_g4], n_states=4, states_types=[StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    HydroTurbineGov(R, r, Tr, Tf, Tg, VELM, gate_position_limits, Tw, At, D_T, q_nl, P_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function HydroTurbineGov(::Nothing)
    HydroTurbineGov(;
        R=0,
        r=0,
        Tr=0,
        Tf=0,
        Tg=0,
        VELM=0,
        gate_position_limits=(min=0.0, max=0.0),
        Tw=0,
        At=0,
        D_T=0,
        q_nl=0,
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`HydroTurbineGov`](@ref) `R`."""
get_R(value::HydroTurbineGov) = value.R
"""Get [`HydroTurbineGov`](@ref) `r`."""
get_r(value::HydroTurbineGov) = value.r
"""Get [`HydroTurbineGov`](@ref) `Tr`."""
get_Tr(value::HydroTurbineGov) = value.Tr
"""Get [`HydroTurbineGov`](@ref) `Tf`."""
get_Tf(value::HydroTurbineGov) = value.Tf
"""Get [`HydroTurbineGov`](@ref) `Tg`."""
get_Tg(value::HydroTurbineGov) = value.Tg
"""Get [`HydroTurbineGov`](@ref) `VELM`."""
get_VELM(value::HydroTurbineGov) = value.VELM
"""Get [`HydroTurbineGov`](@ref) `gate_position_limits`."""
get_gate_position_limits(value::HydroTurbineGov) = value.gate_position_limits
"""Get [`HydroTurbineGov`](@ref) `Tw`."""
get_Tw(value::HydroTurbineGov) = value.Tw
"""Get [`HydroTurbineGov`](@ref) `At`."""
get_At(value::HydroTurbineGov) = value.At
"""Get [`HydroTurbineGov`](@ref) `D_T`."""
get_D_T(value::HydroTurbineGov) = value.D_T
"""Get [`HydroTurbineGov`](@ref) `q_nl`."""
get_q_nl(value::HydroTurbineGov) = value.q_nl
"""Get [`HydroTurbineGov`](@ref) `P_ref`."""
get_P_ref(value::HydroTurbineGov) = value.P_ref
"""Get [`HydroTurbineGov`](@ref) `ext`."""
get_ext(value::HydroTurbineGov) = value.ext
"""Get [`HydroTurbineGov`](@ref) `states`."""
get_states(value::HydroTurbineGov) = value.states
"""Get [`HydroTurbineGov`](@ref) `n_states`."""
get_n_states(value::HydroTurbineGov) = value.n_states
"""Get [`HydroTurbineGov`](@ref) `states_types`."""
get_states_types(value::HydroTurbineGov) = value.states_types
"""Get [`HydroTurbineGov`](@ref) `internal`."""
get_internal(value::HydroTurbineGov) = value.internal

"""Set [`HydroTurbineGov`](@ref) `R`."""
set_R!(value::HydroTurbineGov, val) = value.R = val
"""Set [`HydroTurbineGov`](@ref) `r`."""
set_r!(value::HydroTurbineGov, val) = value.r = val
"""Set [`HydroTurbineGov`](@ref) `Tr`."""
set_Tr!(value::HydroTurbineGov, val) = value.Tr = val
"""Set [`HydroTurbineGov`](@ref) `Tf`."""
set_Tf!(value::HydroTurbineGov, val) = value.Tf = val
"""Set [`HydroTurbineGov`](@ref) `Tg`."""
set_Tg!(value::HydroTurbineGov, val) = value.Tg = val
"""Set [`HydroTurbineGov`](@ref) `VELM`."""
set_VELM!(value::HydroTurbineGov, val) = value.VELM = val
"""Set [`HydroTurbineGov`](@ref) `gate_position_limits`."""
set_gate_position_limits!(value::HydroTurbineGov, val) = value.gate_position_limits = val
"""Set [`HydroTurbineGov`](@ref) `Tw`."""
set_Tw!(value::HydroTurbineGov, val) = value.Tw = val
"""Set [`HydroTurbineGov`](@ref) `At`."""
set_At!(value::HydroTurbineGov, val) = value.At = val
"""Set [`HydroTurbineGov`](@ref) `D_T`."""
set_D_T!(value::HydroTurbineGov, val) = value.D_T = val
"""Set [`HydroTurbineGov`](@ref) `q_nl`."""
set_q_nl!(value::HydroTurbineGov, val) = value.q_nl = val
"""Set [`HydroTurbineGov`](@ref) `P_ref`."""
set_P_ref!(value::HydroTurbineGov, val) = value.P_ref = val
"""Set [`HydroTurbineGov`](@ref) `ext`."""
set_ext!(value::HydroTurbineGov, val) = value.ext = val
"""Set [`HydroTurbineGov`](@ref) `states_types`."""
set_states_types!(value::HydroTurbineGov, val) = value.states_types = val
