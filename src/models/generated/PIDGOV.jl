#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct PIDGOV <: TurbineGov
        feedback_flag::Int
        Rperm::Float64
        T_reg::Float64
        Kp::Float64
        Ki::Float64
        Kd::Float64
        Ta::Float64
        Tb::Float64
        D_turb::Float64
        gate_openings::Tuple{Float64, Float64, Float64}
        power_gate_openings::Tuple{Float64, Float64, Float64}
        G_lim::MinMax
        A_tw::Float64
        Tw::Float64
        V_lim::MinMax
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.T}
        internal::InfrastructureSystemsInternal
    end

Hydro Turbine-Governor with PID controller.

# Arguments
- `feedback_flag::Int`: Feedback signal for governor droop: 0 for electrical power, and 1 for gate position., validation range: `(0, 1)`
- `Rperm::Float64`: Speed permanent droop parameter, validation range: `(0, nothing)`
- `T_reg::Float64`: Speed detector time constant, validation range: `(0, nothing)`
- `Kp::Float64`: Governor proportional gain, validation range: `(0, nothing)`
- `Ki::Float64`: Governor integral gain, validation range: `(0, nothing)`
- `Kd::Float64`: Governor derivative gain, validation range: `(0, nothing)`
- `Ta::Float64`: Governor derivative time constant, validation range: `(0, nothing)`
- `Tb::Float64`: Gate-servo time constant, validation range: `(0, nothing)`
- `D_turb::Float64`: Turbine damping factor, validation range: `(0, nothing)`
- `gate_openings::Tuple{Float64, Float64, Float64}`: Gate-opening speed at different loads
- `power_gate_openings::Tuple{Float64, Float64, Float64}`: Power at gate_openings
- `G_lim::MinMax`: Minimum/Maximum Gate openings `(G_min, G_max)`.
- `A_tw::Float64`: Factor multiplying Tw, validation range: `(eps(), nothing)`
- `Tw::Float64`: Water inertia time constant, sec, validation range: `(eps(), nothing)`
- `V_lim::MinMax`: Gate opening velocity limits `(G_min, G_max)`.
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
mutable struct PIDGOV <: TurbineGov
    "Feedback signal for governor droop: 0 for electrical power, and 1 for gate position."
    feedback_flag::Int
    "Speed permanent droop parameter"
    Rperm::Float64
    "Speed detector time constant"
    T_reg::Float64
    "Governor proportional gain"
    Kp::Float64
    "Governor integral gain"
    Ki::Float64
    "Governor derivative gain"
    Kd::Float64
    "Governor derivative time constant"
    Ta::Float64
    "Gate-servo time constant"
    Tb::Float64
    "Turbine damping factor"
    D_turb::Float64
    "Gate-opening speed at different loads"
    gate_openings::Tuple{Float64, Float64, Float64}
    "Power at gate_openings"
    power_gate_openings::Tuple{Float64, Float64, Float64}
    "Minimum/Maximum Gate openings `(G_min, G_max)`."
    G_lim::MinMax
    "Factor multiplying Tw"
    A_tw::Float64
    "Water inertia time constant, sec"
    Tw::Float64
    "Gate opening velocity limits `(G_min, G_max)`."
    V_lim::MinMax
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

function PIDGOV(feedback_flag, Rperm, T_reg, Kp, Ki, Kd, Ta, Tb, D_turb, gate_openings, power_gate_openings, G_lim, A_tw, Tw, V_lim, P_ref=1.0, ext=Dict{String, Any}(), )
    PIDGOV(feedback_flag, Rperm, T_reg, Kp, Ki, Kd, Ta, Tb, D_turb, gate_openings, power_gate_openings, G_lim, A_tw, Tw, V_lim, P_ref, ext, [:x_g1, :x_g2, :x_g3, :x_g4, :x_g5, :x_g6, :x_g7], 7, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], InfrastructureSystemsInternal(), )
end

function PIDGOV(; feedback_flag, Rperm, T_reg, Kp, Ki, Kd, Ta, Tb, D_turb, gate_openings, power_gate_openings, G_lim, A_tw, Tw, V_lim, P_ref=1.0, ext=Dict{String, Any}(), states=[:x_g1, :x_g2, :x_g3, :x_g4, :x_g5, :x_g6, :x_g7], n_states=7, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], internal=InfrastructureSystemsInternal(), )
    PIDGOV(feedback_flag, Rperm, T_reg, Kp, Ki, Kd, Ta, Tb, D_turb, gate_openings, power_gate_openings, G_lim, A_tw, Tw, V_lim, P_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function PIDGOV(::Nothing)
    PIDGOV(;
        feedback_flag=1,
        Rperm=0,
        T_reg=0,
        Kp=0,
        Ki=0,
        Kd=0,
        Ta=0,
        Tb=0,
        D_turb=0,
        gate_openings=(0.0, 0.0, 0.0),
        power_gate_openings=(0.0, 0.0, 0.0),
        G_lim=(min=0.0, max=0.0),
        A_tw=0,
        Tw=0,
        V_lim=(min=0.0, max=0.0),
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`PIDGOV`](@ref) `feedback_flag`."""
get_feedback_flag(value::PIDGOV) = value.feedback_flag
"""Get [`PIDGOV`](@ref) `Rperm`."""
get_Rperm(value::PIDGOV) = value.Rperm
"""Get [`PIDGOV`](@ref) `T_reg`."""
get_T_reg(value::PIDGOV) = value.T_reg
"""Get [`PIDGOV`](@ref) `Kp`."""
get_Kp(value::PIDGOV) = value.Kp
"""Get [`PIDGOV`](@ref) `Ki`."""
get_Ki(value::PIDGOV) = value.Ki
"""Get [`PIDGOV`](@ref) `Kd`."""
get_Kd(value::PIDGOV) = value.Kd
"""Get [`PIDGOV`](@ref) `Ta`."""
get_Ta(value::PIDGOV) = value.Ta
"""Get [`PIDGOV`](@ref) `Tb`."""
get_Tb(value::PIDGOV) = value.Tb
"""Get [`PIDGOV`](@ref) `D_turb`."""
get_D_turb(value::PIDGOV) = value.D_turb
"""Get [`PIDGOV`](@ref) `gate_openings`."""
get_gate_openings(value::PIDGOV) = value.gate_openings
"""Get [`PIDGOV`](@ref) `power_gate_openings`."""
get_power_gate_openings(value::PIDGOV) = value.power_gate_openings
"""Get [`PIDGOV`](@ref) `G_lim`."""
get_G_lim(value::PIDGOV) = value.G_lim
"""Get [`PIDGOV`](@ref) `A_tw`."""
get_A_tw(value::PIDGOV) = value.A_tw
"""Get [`PIDGOV`](@ref) `Tw`."""
get_Tw(value::PIDGOV) = value.Tw
"""Get [`PIDGOV`](@ref) `V_lim`."""
get_V_lim(value::PIDGOV) = value.V_lim
"""Get [`PIDGOV`](@ref) `P_ref`."""
get_P_ref(value::PIDGOV) = value.P_ref
"""Get [`PIDGOV`](@ref) `ext`."""
get_ext(value::PIDGOV) = value.ext
"""Get [`PIDGOV`](@ref) `states`."""
get_states(value::PIDGOV) = value.states
"""Get [`PIDGOV`](@ref) `n_states`."""
get_n_states(value::PIDGOV) = value.n_states
"""Get [`PIDGOV`](@ref) `states_types`."""
get_states_types(value::PIDGOV) = value.states_types
"""Get [`PIDGOV`](@ref) `internal`."""
get_internal(value::PIDGOV) = value.internal

"""Set [`PIDGOV`](@ref) `feedback_flag`."""
set_feedback_flag!(value::PIDGOV, val) = value.feedback_flag = val
"""Set [`PIDGOV`](@ref) `Rperm`."""
set_Rperm!(value::PIDGOV, val) = value.Rperm = val
"""Set [`PIDGOV`](@ref) `T_reg`."""
set_T_reg!(value::PIDGOV, val) = value.T_reg = val
"""Set [`PIDGOV`](@ref) `Kp`."""
set_Kp!(value::PIDGOV, val) = value.Kp = val
"""Set [`PIDGOV`](@ref) `Ki`."""
set_Ki!(value::PIDGOV, val) = value.Ki = val
"""Set [`PIDGOV`](@ref) `Kd`."""
set_Kd!(value::PIDGOV, val) = value.Kd = val
"""Set [`PIDGOV`](@ref) `Ta`."""
set_Ta!(value::PIDGOV, val) = value.Ta = val
"""Set [`PIDGOV`](@ref) `Tb`."""
set_Tb!(value::PIDGOV, val) = value.Tb = val
"""Set [`PIDGOV`](@ref) `D_turb`."""
set_D_turb!(value::PIDGOV, val) = value.D_turb = val
"""Set [`PIDGOV`](@ref) `gate_openings`."""
set_gate_openings!(value::PIDGOV, val) = value.gate_openings = val
"""Set [`PIDGOV`](@ref) `power_gate_openings`."""
set_power_gate_openings!(value::PIDGOV, val) = value.power_gate_openings = val
"""Set [`PIDGOV`](@ref) `G_lim`."""
set_G_lim!(value::PIDGOV, val) = value.G_lim = val
"""Set [`PIDGOV`](@ref) `A_tw`."""
set_A_tw!(value::PIDGOV, val) = value.A_tw = val
"""Set [`PIDGOV`](@ref) `Tw`."""
set_Tw!(value::PIDGOV, val) = value.Tw = val
"""Set [`PIDGOV`](@ref) `V_lim`."""
set_V_lim!(value::PIDGOV, val) = value.V_lim = val
"""Set [`PIDGOV`](@ref) `P_ref`."""
set_P_ref!(value::PIDGOV, val) = value.P_ref = val
"""Set [`PIDGOV`](@ref) `ext`."""
set_ext!(value::PIDGOV, val) = value.ext = val
"""Set [`PIDGOV`](@ref) `states_types`."""
set_states_types!(value::PIDGOV, val) = value.states_types = val
