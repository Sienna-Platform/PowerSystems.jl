#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct WPIDHY <: TurbineGov
        T_reg::Float64
        reg::Float64
        Kp::Float64
        Ki::Float64
        Kd::Float64
        Ta::Float64
        Tb::Float64
        V_lim::MinMax
        G_lim::MinMax
        Tw::Float64
        P_lim::MinMax
        D::Float64
        gate_openings::Tuple{Float64, Float64, Float64}
        power_gate_openings::Tuple{Float64, Float64, Float64}
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.T}
        internal::InfrastructureSystemsInternal
    end

Woodward PID Hydro Governor

# Arguments
- `T_reg::Float64`: Input time constant of the governor in s, validation range: `(0, nothing)`
- `reg::Float64`: Input governor gain, validation range: `(0, nothing)`
- `Kp::Float64`: Governor proportional gain, validation range: `(0, nothing)`
- `Ki::Float64`: Governor integral gain, validation range: `(0, nothing)`
- `Kd::Float64`: Governor derivative gain, validation range: `(0, nothing)`
- `Ta::Float64`: Governor derivative/high-frequency time constant, validation range: `(0, nothing)`
- `Tb::Float64`: Gate-servo time constant, validation range: `(0, nothing)`
- `V_lim::MinMax`: Gate opening velocity limits `(G_min, G_max)`.
- `G_lim::MinMax`: Minimum/Maximum Gate velocity `(G_min, G_max)`.
- `Tw::Float64`: Water inertia time constant, sec, validation range: `(eps(), nothing)`
- `P_lim::MinMax`: Minimum/Maximum Gate openings `(P_min, P_max)`.
- `D::Float64`: Turbine damping coefficient, validation range: `(0, nothing)`
- `gate_openings::Tuple{Float64, Float64, Float64}`: Gate-opening speed at different loads
- `power_gate_openings::Tuple{Float64, Float64, Float64}`: Power at gate_openings
- `P_ref::Float64`: (default: `1.0`) Reference Power Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the PIDGOV model are:
	x_g1: Filtered input measurement,
	x_g2: PI block internal state,
	x_g3: First regulator state, 
	x_g4: Derivative block internal state, 
	x_g5: Second regulator state, 
	x_g6: Gate position state, 
	x_g7: Water inertia state
- `n_states::Int`: (**Do not modify.**) PIDGOV has 7 states
- `states_types::Vector{StateTypes.T}`: (**Do not modify.**) PIDGOV has 7 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct WPIDHY <: TurbineGov
    "Input time constant of the governor in s"
    T_reg::Float64
    "Input governor gain"
    reg::Float64
    "Governor proportional gain"
    Kp::Float64
    "Governor integral gain"
    Ki::Float64
    "Governor derivative gain"
    Kd::Float64
    "Governor derivative/high-frequency time constant"
    Ta::Float64
    "Gate-servo time constant"
    Tb::Float64
    "Gate opening velocity limits `(G_min, G_max)`."
    V_lim::MinMax
    "Minimum/Maximum Gate velocity `(G_min, G_max)`."
    G_lim::MinMax
    "Water inertia time constant, sec"
    Tw::Float64
    "Minimum/Maximum Gate openings `(P_min, P_max)`."
    P_lim::MinMax
    "Turbine damping coefficient"
    D::Float64
    "Gate-opening speed at different loads"
    gate_openings::Tuple{Float64, Float64, Float64}
    "Power at gate_openings"
    power_gate_openings::Tuple{Float64, Float64, Float64}
    "Reference Power Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the PIDGOV model are:
	x_g1: Filtered input measurement,
	x_g2: PI block internal state,
	x_g3: First regulator state, 
	x_g4: Derivative block internal state, 
	x_g5: Second regulator state, 
	x_g6: Gate position state, 
	x_g7: Water inertia state"
    states::Vector{Symbol}
    "(**Do not modify.**) PIDGOV has 7 states"
    n_states::Int
    "(**Do not modify.**) PIDGOV has 7 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.T}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function WPIDHY(T_reg, reg, Kp, Ki, Kd, Ta, Tb, V_lim, G_lim, Tw, P_lim, D, gate_openings, power_gate_openings, P_ref=1.0, ext=Dict{String, Any}(), )
    WPIDHY(T_reg, reg, Kp, Ki, Kd, Ta, Tb, V_lim, G_lim, Tw, P_lim, D, gate_openings, power_gate_openings, P_ref, ext, [:x_g1, :x_g2, :x_g3, :x_g4, :x_g5, :x_g6, :x_g7], 7, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], InfrastructureSystemsInternal(), )
end

function WPIDHY(; T_reg, reg, Kp, Ki, Kd, Ta, Tb, V_lim, G_lim, Tw, P_lim, D, gate_openings, power_gate_openings, P_ref=1.0, ext=Dict{String, Any}(), states=[:x_g1, :x_g2, :x_g3, :x_g4, :x_g5, :x_g6, :x_g7], n_states=7, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], internal=InfrastructureSystemsInternal(), )
    WPIDHY(T_reg, reg, Kp, Ki, Kd, Ta, Tb, V_lim, G_lim, Tw, P_lim, D, gate_openings, power_gate_openings, P_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function WPIDHY(::Nothing)
    WPIDHY(;
        T_reg=0,
        reg=0,
        Kp=0,
        Ki=0,
        Kd=0,
        Ta=0,
        Tb=0,
        V_lim=(min=0.0, max=0.0),
        G_lim=(min=0.0, max=0.0),
        Tw=0,
        P_lim=(min=0.0, max=0.0),
        D=0,
        gate_openings=(0.0, 0.0, 0.0),
        power_gate_openings=(0.0, 0.0, 0.0),
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`WPIDHY`](@ref) `T_reg`."""
get_T_reg(value::WPIDHY) = value.T_reg
"""Get [`WPIDHY`](@ref) `reg`."""
get_reg(value::WPIDHY) = value.reg
"""Get [`WPIDHY`](@ref) `Kp`."""
get_Kp(value::WPIDHY) = value.Kp
"""Get [`WPIDHY`](@ref) `Ki`."""
get_Ki(value::WPIDHY) = value.Ki
"""Get [`WPIDHY`](@ref) `Kd`."""
get_Kd(value::WPIDHY) = value.Kd
"""Get [`WPIDHY`](@ref) `Ta`."""
get_Ta(value::WPIDHY) = value.Ta
"""Get [`WPIDHY`](@ref) `Tb`."""
get_Tb(value::WPIDHY) = value.Tb
"""Get [`WPIDHY`](@ref) `V_lim`."""
get_V_lim(value::WPIDHY) = value.V_lim
"""Get [`WPIDHY`](@ref) `G_lim`."""
get_G_lim(value::WPIDHY) = value.G_lim
"""Get [`WPIDHY`](@ref) `Tw`."""
get_Tw(value::WPIDHY) = value.Tw
"""Get [`WPIDHY`](@ref) `P_lim`."""
get_P_lim(value::WPIDHY) = value.P_lim
"""Get [`WPIDHY`](@ref) `D`."""
get_D(value::WPIDHY) = value.D
"""Get [`WPIDHY`](@ref) `gate_openings`."""
get_gate_openings(value::WPIDHY) = value.gate_openings
"""Get [`WPIDHY`](@ref) `power_gate_openings`."""
get_power_gate_openings(value::WPIDHY) = value.power_gate_openings
"""Get [`WPIDHY`](@ref) `P_ref`."""
get_P_ref(value::WPIDHY) = value.P_ref
"""Get [`WPIDHY`](@ref) `ext`."""
get_ext(value::WPIDHY) = value.ext
"""Get [`WPIDHY`](@ref) `states`."""
get_states(value::WPIDHY) = value.states
"""Get [`WPIDHY`](@ref) `n_states`."""
get_n_states(value::WPIDHY) = value.n_states
"""Get [`WPIDHY`](@ref) `states_types`."""
get_states_types(value::WPIDHY) = value.states_types
"""Get [`WPIDHY`](@ref) `internal`."""
get_internal(value::WPIDHY) = value.internal

"""Set [`WPIDHY`](@ref) `T_reg`."""
set_T_reg!(value::WPIDHY, val) = value.T_reg = val
"""Set [`WPIDHY`](@ref) `reg`."""
set_reg!(value::WPIDHY, val) = value.reg = val
"""Set [`WPIDHY`](@ref) `Kp`."""
set_Kp!(value::WPIDHY, val) = value.Kp = val
"""Set [`WPIDHY`](@ref) `Ki`."""
set_Ki!(value::WPIDHY, val) = value.Ki = val
"""Set [`WPIDHY`](@ref) `Kd`."""
set_Kd!(value::WPIDHY, val) = value.Kd = val
"""Set [`WPIDHY`](@ref) `Ta`."""
set_Ta!(value::WPIDHY, val) = value.Ta = val
"""Set [`WPIDHY`](@ref) `Tb`."""
set_Tb!(value::WPIDHY, val) = value.Tb = val
"""Set [`WPIDHY`](@ref) `V_lim`."""
set_V_lim!(value::WPIDHY, val) = value.V_lim = val
"""Set [`WPIDHY`](@ref) `G_lim`."""
set_G_lim!(value::WPIDHY, val) = value.G_lim = val
"""Set [`WPIDHY`](@ref) `Tw`."""
set_Tw!(value::WPIDHY, val) = value.Tw = val
"""Set [`WPIDHY`](@ref) `P_lim`."""
set_P_lim!(value::WPIDHY, val) = value.P_lim = val
"""Set [`WPIDHY`](@ref) `D`."""
set_D!(value::WPIDHY, val) = value.D = val
"""Set [`WPIDHY`](@ref) `gate_openings`."""
set_gate_openings!(value::WPIDHY, val) = value.gate_openings = val
"""Set [`WPIDHY`](@ref) `power_gate_openings`."""
set_power_gate_openings!(value::WPIDHY, val) = value.power_gate_openings = val
"""Set [`WPIDHY`](@ref) `P_ref`."""
set_P_ref!(value::WPIDHY, val) = value.P_ref = val
"""Set [`WPIDHY`](@ref) `ext`."""
set_ext!(value::WPIDHY, val) = value.ext = val
"""Set [`WPIDHY`](@ref) `states_types`."""
set_states_types!(value::WPIDHY, val) = value.states_types = val
