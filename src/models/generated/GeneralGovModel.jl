#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct GeneralGovModel <: TurbineGov
        Rselect::Int
        fuel_flag::Int
        R::Float64
        Tpelec::Float64
        speed_error_signal::MinMax
        Kp_gov::Float64
        Ki_gov::Float64
        Kd_gov::Float64
        Td_gov::Float64
        valve_position_limits::MinMax
        T_act::Float64
        K_turb::Float64
        Wf_nl::Float64
        Tb::Float64
        Tc::Float64
        T_eng::Float64
        Tf_load::Float64
        Kp_load::Float64
        Ki_load::Float64
        Ld_ref::Float64
        Dm::Float64
        R_open::Float64
        R_close::Float64
        Ki_mw::Float64
        A_set::Float64
        Ka::Float64
        Ta::Float64
        T_rate::Float64
        db::Float64
        Tsa::Float64
        Tsb::Float64
        R_lim::UpDown
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.T}
        internal::InfrastructureSystemsInternal
    end

GE General Governor/Turbine Model. The GeneralGovModel (GGOV1) model is a general purpose governor model used for a variety of prime movers controlled by proportional-integral-derivative (PID) governors including gas turbines

# Arguments
- `Rselect::Int`: Feedback signal for governor droop, validation range: `(-2, 1)`
- `fuel_flag::Int`: Flag Switch for fuel source characteristic, validation range: `(0, 1)`
- `R::Float64`: Speed droop parameter, validation range: `(eps(), nothing)`
- `Tpelec::Float64`: Electrical power transducer time constant, seconds, validation range: `(eps(), nothing)`
- `speed_error_signal::MinMax`: Speed error signal limits
- `Kp_gov::Float64`: Governor proportional gain, validation range: `(0, nothing)`
- `Ki_gov::Float64`: Governor integral gain, validation range: `(0, nothing)`
- `Kd_gov::Float64`: Governor derivative gain, validation range: `(0, nothing)`
- `Td_gov::Float64`: Governor derivative time constant, validation range: `(0, nothing)`
- `valve_position_limits::MinMax`: Valve position limits
- `T_act::Float64`: Actuator time constant, validation range: `(0, nothing)`
- `K_turb::Float64`: Turbine gain, validation range: `(0, nothing)`
- `Wf_nl::Float64`: No load fuel flow, pu, validation range: `(0, nothing)`
- `Tb::Float64`: Turbine lag time constant, sec, validation range: `(0, nothing)`
- `Tc::Float64`: Turbine lead time constant, sec, validation range: `(0, nothing)`
- `T_eng::Float64`: Transport lag time constant for diesel engine, sec, validation range: `(0, nothing)`
- `Tf_load::Float64`: Load limiter time constant, validation range: `(0, nothing)`
- `Kp_load::Float64`: Load limiter proportional gain for PI controller, validation range: `(0, nothing)`
- `Ki_load::Float64`: Load integral gain for PI controller, validation range: `(0, nothing)`
- `Ld_ref::Float64`: Load limiter integral gain for PI controller, validation range: `(0, nothing)`
- `Dm::Float64`: Mechanical damping coefficient, pu, validation range: `(0, nothing)`
- `R_open::Float64`: Maximum valve opening rate, pu/sec, validation range: `(0, nothing)`
- `R_close::Float64`: Maximum valve closing rate, pu/sec, validation range: `(0, nothing)`
- `Ki_mw::Float64`: Power controller (reset) gain, validation range: `(0, nothing)`
- `A_set::Float64`: Acceleration limiter setpoint, pu/sec, validation range: `(0, nothing)`
- `Ka::Float64`: Acceleration limiter gain, validation range: `(0, nothing)`
- `Ta::Float64`: Acceleration limiter time constant , validation range: `(eps(), nothing)`
- `T_rate::Float64`: Turbine rating, validation range: `(0, nothing)`
- `db::Float64`: Speed governor deadband, validation range: `(0, nothing)`
- `Tsa::Float64`: Temperature detection lead time constant, validation range: `(0, nothing)`
- `Tsb::Float64`: Temperature detection lag time constant, validation range: `(0, nothing)`
- `R_lim::UpDown`: Maximum rate of load increase
- `P_ref::Float64`: (default: `1.0`) Reference Power Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the GGOV1 model are:
	Pe: Machine Electrical Power Measurement,
	x_g1: Governor differential control,
	x_g2: Governor integral control, 
	x_g3: Turbine actuator, 
	x_g4: Turbine Lead-Lag, 
	x_g5: Turbine load limiter measurement, 
	x_g6: Turbine Load Limiter Integral Control, 
	x_g7: Supervisory Load Control, 
	x_g8: Acceleration Control, 
	x_g9 Temperature Detection Lead - Lag:
- `n_states::Int`: (**Do not modify.**) GeneralGovModel has 10 states
- `states_types::Vector{StateTypes.T}`: (**Do not modify.**) GGOV1 has 10 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct GeneralGovModel <: TurbineGov
    "Feedback signal for governor droop"
    Rselect::Int
    "Flag Switch for fuel source characteristic"
    fuel_flag::Int
    "Speed droop parameter"
    R::Float64
    "Electrical power transducer time constant, seconds"
    Tpelec::Float64
    "Speed error signal limits"
    speed_error_signal::MinMax
    "Governor proportional gain"
    Kp_gov::Float64
    "Governor integral gain"
    Ki_gov::Float64
    "Governor derivative gain"
    Kd_gov::Float64
    "Governor derivative time constant"
    Td_gov::Float64
    "Valve position limits"
    valve_position_limits::MinMax
    "Actuator time constant"
    T_act::Float64
    "Turbine gain"
    K_turb::Float64
    "No load fuel flow, pu"
    Wf_nl::Float64
    "Turbine lag time constant, sec"
    Tb::Float64
    "Turbine lead time constant, sec"
    Tc::Float64
    "Transport lag time constant for diesel engine, sec"
    T_eng::Float64
    "Load limiter time constant"
    Tf_load::Float64
    "Load limiter proportional gain for PI controller"
    Kp_load::Float64
    "Load integral gain for PI controller"
    Ki_load::Float64
    "Load limiter integral gain for PI controller"
    Ld_ref::Float64
    "Mechanical damping coefficient, pu"
    Dm::Float64
    "Maximum valve opening rate, pu/sec"
    R_open::Float64
    "Maximum valve closing rate, pu/sec"
    R_close::Float64
    "Power controller (reset) gain"
    Ki_mw::Float64
    "Acceleration limiter setpoint, pu/sec"
    A_set::Float64
    "Acceleration limiter gain"
    Ka::Float64
    "Acceleration limiter time constant "
    Ta::Float64
    "Turbine rating"
    T_rate::Float64
    "Speed governor deadband"
    db::Float64
    "Temperature detection lead time constant"
    Tsa::Float64
    "Temperature detection lag time constant"
    Tsb::Float64
    "Maximum rate of load increase"
    R_lim::UpDown
    "Reference Power Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the GGOV1 model are:
	Pe: Machine Electrical Power Measurement,
	x_g1: Governor differential control,
	x_g2: Governor integral control, 
	x_g3: Turbine actuator, 
	x_g4: Turbine Lead-Lag, 
	x_g5: Turbine load limiter measurement, 
	x_g6: Turbine Load Limiter Integral Control, 
	x_g7: Supervisory Load Control, 
	x_g8: Acceleration Control, 
	x_g9 Temperature Detection Lead - Lag:"
    states::Vector{Symbol}
    "(**Do not modify.**) GeneralGovModel has 10 states"
    n_states::Int
    "(**Do not modify.**) GGOV1 has 10 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.T}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function GeneralGovModel(Rselect, fuel_flag, R, Tpelec, speed_error_signal, Kp_gov, Ki_gov, Kd_gov, Td_gov, valve_position_limits, T_act, K_turb, Wf_nl, Tb, Tc, T_eng, Tf_load, Kp_load, Ki_load, Ld_ref, Dm, R_open, R_close, Ki_mw, A_set, Ka, Ta, T_rate, db, Tsa, Tsb, R_lim, P_ref=1.0, ext=Dict{String, Any}(), )
    GeneralGovModel(Rselect, fuel_flag, R, Tpelec, speed_error_signal, Kp_gov, Ki_gov, Kd_gov, Td_gov, valve_position_limits, T_act, K_turb, Wf_nl, Tb, Tc, T_eng, Tf_load, Kp_load, Ki_load, Ld_ref, Dm, R_open, R_close, Ki_mw, A_set, Ka, Ta, T_rate, db, Tsa, Tsb, R_lim, P_ref, ext, [:Pe, :x_g1, :x_g2, :x_g3, :x_g4, :x_g5, :x_g6, :x_g7, :x_g8, :x_g9], 10, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential, StateTypes.Hybrid], InfrastructureSystemsInternal(), )
end

function GeneralGovModel(; Rselect, fuel_flag, R, Tpelec, speed_error_signal, Kp_gov, Ki_gov, Kd_gov, Td_gov, valve_position_limits, T_act, K_turb, Wf_nl, Tb, Tc, T_eng, Tf_load, Kp_load, Ki_load, Ld_ref, Dm, R_open, R_close, Ki_mw, A_set, Ka, Ta, T_rate, db, Tsa, Tsb, R_lim, P_ref=1.0, ext=Dict{String, Any}(), states=[:Pe, :x_g1, :x_g2, :x_g3, :x_g4, :x_g5, :x_g6, :x_g7, :x_g8, :x_g9], n_states=10, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential, StateTypes.Hybrid], internal=InfrastructureSystemsInternal(), )
    GeneralGovModel(Rselect, fuel_flag, R, Tpelec, speed_error_signal, Kp_gov, Ki_gov, Kd_gov, Td_gov, valve_position_limits, T_act, K_turb, Wf_nl, Tb, Tc, T_eng, Tf_load, Kp_load, Ki_load, Ld_ref, Dm, R_open, R_close, Ki_mw, A_set, Ka, Ta, T_rate, db, Tsa, Tsb, R_lim, P_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function GeneralGovModel(::Nothing)
    GeneralGovModel(;
        Rselect=1,
        fuel_flag=0,
        R=0,
        Tpelec=0,
        speed_error_signal=(min=0.0, max=0.0),
        Kp_gov=0,
        Ki_gov=0,
        Kd_gov=0,
        Td_gov=0,
        valve_position_limits=(min=0.0, max=0.0),
        T_act=0,
        K_turb=0,
        Wf_nl=0,
        Tb=0,
        Tc=0,
        T_eng=0,
        Tf_load=0,
        Kp_load=0,
        Ki_load=0,
        Ld_ref=0,
        Dm=0,
        R_open=0,
        R_close=0,
        Ki_mw=0,
        A_set=0,
        Ka=0,
        Ta=0,
        T_rate=0,
        db=0,
        Tsa=0,
        Tsb=0,
        R_lim=(up = 0.0, down = 0.0),
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`GeneralGovModel`](@ref) `Rselect`."""
get_Rselect(value::GeneralGovModel) = value.Rselect
"""Get [`GeneralGovModel`](@ref) `fuel_flag`."""
get_fuel_flag(value::GeneralGovModel) = value.fuel_flag
"""Get [`GeneralGovModel`](@ref) `R`."""
get_R(value::GeneralGovModel) = value.R
"""Get [`GeneralGovModel`](@ref) `Tpelec`."""
get_Tpelec(value::GeneralGovModel) = value.Tpelec
"""Get [`GeneralGovModel`](@ref) `speed_error_signal`."""
get_speed_error_signal(value::GeneralGovModel) = value.speed_error_signal
"""Get [`GeneralGovModel`](@ref) `Kp_gov`."""
get_Kp_gov(value::GeneralGovModel) = value.Kp_gov
"""Get [`GeneralGovModel`](@ref) `Ki_gov`."""
get_Ki_gov(value::GeneralGovModel) = value.Ki_gov
"""Get [`GeneralGovModel`](@ref) `Kd_gov`."""
get_Kd_gov(value::GeneralGovModel) = value.Kd_gov
"""Get [`GeneralGovModel`](@ref) `Td_gov`."""
get_Td_gov(value::GeneralGovModel) = value.Td_gov
"""Get [`GeneralGovModel`](@ref) `valve_position_limits`."""
get_valve_position_limits(value::GeneralGovModel) = value.valve_position_limits
"""Get [`GeneralGovModel`](@ref) `T_act`."""
get_T_act(value::GeneralGovModel) = value.T_act
"""Get [`GeneralGovModel`](@ref) `K_turb`."""
get_K_turb(value::GeneralGovModel) = value.K_turb
"""Get [`GeneralGovModel`](@ref) `Wf_nl`."""
get_Wf_nl(value::GeneralGovModel) = value.Wf_nl
"""Get [`GeneralGovModel`](@ref) `Tb`."""
get_Tb(value::GeneralGovModel) = value.Tb
"""Get [`GeneralGovModel`](@ref) `Tc`."""
get_Tc(value::GeneralGovModel) = value.Tc
"""Get [`GeneralGovModel`](@ref) `T_eng`."""
get_T_eng(value::GeneralGovModel) = value.T_eng
"""Get [`GeneralGovModel`](@ref) `Tf_load`."""
get_Tf_load(value::GeneralGovModel) = value.Tf_load
"""Get [`GeneralGovModel`](@ref) `Kp_load`."""
get_Kp_load(value::GeneralGovModel) = value.Kp_load
"""Get [`GeneralGovModel`](@ref) `Ki_load`."""
get_Ki_load(value::GeneralGovModel) = value.Ki_load
"""Get [`GeneralGovModel`](@ref) `Ld_ref`."""
get_Ld_ref(value::GeneralGovModel) = value.Ld_ref
"""Get [`GeneralGovModel`](@ref) `Dm`."""
get_Dm(value::GeneralGovModel) = value.Dm
"""Get [`GeneralGovModel`](@ref) `R_open`."""
get_R_open(value::GeneralGovModel) = value.R_open
"""Get [`GeneralGovModel`](@ref) `R_close`."""
get_R_close(value::GeneralGovModel) = value.R_close
"""Get [`GeneralGovModel`](@ref) `Ki_mw`."""
get_Ki_mw(value::GeneralGovModel) = value.Ki_mw
"""Get [`GeneralGovModel`](@ref) `A_set`."""
get_A_set(value::GeneralGovModel) = value.A_set
"""Get [`GeneralGovModel`](@ref) `Ka`."""
get_Ka(value::GeneralGovModel) = value.Ka
"""Get [`GeneralGovModel`](@ref) `Ta`."""
get_Ta(value::GeneralGovModel) = value.Ta
"""Get [`GeneralGovModel`](@ref) `T_rate`."""
get_T_rate(value::GeneralGovModel) = value.T_rate
"""Get [`GeneralGovModel`](@ref) `db`."""
get_db(value::GeneralGovModel) = value.db
"""Get [`GeneralGovModel`](@ref) `Tsa`."""
get_Tsa(value::GeneralGovModel) = value.Tsa
"""Get [`GeneralGovModel`](@ref) `Tsb`."""
get_Tsb(value::GeneralGovModel) = value.Tsb
"""Get [`GeneralGovModel`](@ref) `R_lim`."""
get_R_lim(value::GeneralGovModel) = value.R_lim
"""Get [`GeneralGovModel`](@ref) `P_ref`."""
get_P_ref(value::GeneralGovModel) = value.P_ref
"""Get [`GeneralGovModel`](@ref) `ext`."""
get_ext(value::GeneralGovModel) = value.ext
"""Get [`GeneralGovModel`](@ref) `states`."""
get_states(value::GeneralGovModel) = value.states
"""Get [`GeneralGovModel`](@ref) `n_states`."""
get_n_states(value::GeneralGovModel) = value.n_states
"""Get [`GeneralGovModel`](@ref) `states_types`."""
get_states_types(value::GeneralGovModel) = value.states_types
"""Get [`GeneralGovModel`](@ref) `internal`."""
get_internal(value::GeneralGovModel) = value.internal

"""Set [`GeneralGovModel`](@ref) `Rselect`."""
set_Rselect!(value::GeneralGovModel, val) = value.Rselect = val
"""Set [`GeneralGovModel`](@ref) `fuel_flag`."""
set_fuel_flag!(value::GeneralGovModel, val) = value.fuel_flag = val
"""Set [`GeneralGovModel`](@ref) `R`."""
set_R!(value::GeneralGovModel, val) = value.R = val
"""Set [`GeneralGovModel`](@ref) `Tpelec`."""
set_Tpelec!(value::GeneralGovModel, val) = value.Tpelec = val
"""Set [`GeneralGovModel`](@ref) `speed_error_signal`."""
set_speed_error_signal!(value::GeneralGovModel, val) = value.speed_error_signal = val
"""Set [`GeneralGovModel`](@ref) `Kp_gov`."""
set_Kp_gov!(value::GeneralGovModel, val) = value.Kp_gov = val
"""Set [`GeneralGovModel`](@ref) `Ki_gov`."""
set_Ki_gov!(value::GeneralGovModel, val) = value.Ki_gov = val
"""Set [`GeneralGovModel`](@ref) `Kd_gov`."""
set_Kd_gov!(value::GeneralGovModel, val) = value.Kd_gov = val
"""Set [`GeneralGovModel`](@ref) `Td_gov`."""
set_Td_gov!(value::GeneralGovModel, val) = value.Td_gov = val
"""Set [`GeneralGovModel`](@ref) `valve_position_limits`."""
set_valve_position_limits!(value::GeneralGovModel, val) = value.valve_position_limits = val
"""Set [`GeneralGovModel`](@ref) `T_act`."""
set_T_act!(value::GeneralGovModel, val) = value.T_act = val
"""Set [`GeneralGovModel`](@ref) `K_turb`."""
set_K_turb!(value::GeneralGovModel, val) = value.K_turb = val
"""Set [`GeneralGovModel`](@ref) `Wf_nl`."""
set_Wf_nl!(value::GeneralGovModel, val) = value.Wf_nl = val
"""Set [`GeneralGovModel`](@ref) `Tb`."""
set_Tb!(value::GeneralGovModel, val) = value.Tb = val
"""Set [`GeneralGovModel`](@ref) `Tc`."""
set_Tc!(value::GeneralGovModel, val) = value.Tc = val
"""Set [`GeneralGovModel`](@ref) `T_eng`."""
set_T_eng!(value::GeneralGovModel, val) = value.T_eng = val
"""Set [`GeneralGovModel`](@ref) `Tf_load`."""
set_Tf_load!(value::GeneralGovModel, val) = value.Tf_load = val
"""Set [`GeneralGovModel`](@ref) `Kp_load`."""
set_Kp_load!(value::GeneralGovModel, val) = value.Kp_load = val
"""Set [`GeneralGovModel`](@ref) `Ki_load`."""
set_Ki_load!(value::GeneralGovModel, val) = value.Ki_load = val
"""Set [`GeneralGovModel`](@ref) `Ld_ref`."""
set_Ld_ref!(value::GeneralGovModel, val) = value.Ld_ref = val
"""Set [`GeneralGovModel`](@ref) `Dm`."""
set_Dm!(value::GeneralGovModel, val) = value.Dm = val
"""Set [`GeneralGovModel`](@ref) `R_open`."""
set_R_open!(value::GeneralGovModel, val) = value.R_open = val
"""Set [`GeneralGovModel`](@ref) `R_close`."""
set_R_close!(value::GeneralGovModel, val) = value.R_close = val
"""Set [`GeneralGovModel`](@ref) `Ki_mw`."""
set_Ki_mw!(value::GeneralGovModel, val) = value.Ki_mw = val
"""Set [`GeneralGovModel`](@ref) `A_set`."""
set_A_set!(value::GeneralGovModel, val) = value.A_set = val
"""Set [`GeneralGovModel`](@ref) `Ka`."""
set_Ka!(value::GeneralGovModel, val) = value.Ka = val
"""Set [`GeneralGovModel`](@ref) `Ta`."""
set_Ta!(value::GeneralGovModel, val) = value.Ta = val
"""Set [`GeneralGovModel`](@ref) `T_rate`."""
set_T_rate!(value::GeneralGovModel, val) = value.T_rate = val
"""Set [`GeneralGovModel`](@ref) `db`."""
set_db!(value::GeneralGovModel, val) = value.db = val
"""Set [`GeneralGovModel`](@ref) `Tsa`."""
set_Tsa!(value::GeneralGovModel, val) = value.Tsa = val
"""Set [`GeneralGovModel`](@ref) `Tsb`."""
set_Tsb!(value::GeneralGovModel, val) = value.Tsb = val
"""Set [`GeneralGovModel`](@ref) `R_lim`."""
set_R_lim!(value::GeneralGovModel, val) = value.R_lim = val
"""Set [`GeneralGovModel`](@ref) `P_ref`."""
set_P_ref!(value::GeneralGovModel, val) = value.P_ref = val
"""Set [`GeneralGovModel`](@ref) `ext`."""
set_ext!(value::GeneralGovModel, val) = value.ext = val
"""Set [`GeneralGovModel`](@ref) `states_types`."""
set_states_types!(value::GeneralGovModel, val) = value.states_types = val
