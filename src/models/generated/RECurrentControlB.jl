#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct RECurrentControlB <: InnerControl
        Q_Flag::Int
        PQ_Flag::Int
        Vdip_lim::MinMax
        T_rv::Float64
        dbd_pnts::Tuple{Float64, Float64}
        K_qv::Float64
        Iqinj_lim::MinMax
        V_ref0::Float64
        K_vp::Float64
        K_vi::Float64
        T_iq::Float64
        I_max::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of the Inner Control part of the REECB model in PSS/E

# Arguments
- `Q_Flag::Int`: Q Flag used for I_qinj, validation range: `(0, 1)`
- `PQ_Flag::Int`: PQ Flag used for the Current Limit Logic, validation range: `(0, 1)`
- `Vdip_lim::MinMax`: Limits for Voltage Dip Logic `(Vdip, Vup)`
- `T_rv::Float64`: Voltage Filter Time Constant, validation range: `(0, nothing)`
- `dbd_pnts::Tuple{Float64, Float64}`: Voltage error deadband thresholds `(dbd1, dbd2)`
- `K_qv::Float64`: Reactive current injection gain during over and undervoltage conditions, validation range: `(0, nothing)`
- `Iqinj_lim::MinMax`: Limits for Iqinj `(I_qh1, I_ql1)`
- `V_ref0::Float64`: User defined reference. If 0, [`PowerSimulationsDynamics.jl`](https://sienna-platform.github.io/PowerSimulationsDynamics.jl/stable/) initializes to initial terminal voltage, validation range: `(0, nothing)`
- `K_vp::Float64`: Voltage regulator proportional gain (used when QFlag = 1), validation range: `(0, nothing)`
- `K_vi::Float64`: Voltage regulator integral gain (used when QFlag = 1), validation range: `(0, nothing)`
- `T_iq::Float64`: Time constant for low-pass filter for state q_V when QFlag = 0, validation range: `(0, nothing)`
- `I_max::Float64`: Maximum limit on total converter current, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the RECurrentControlB depends on the Flags
- `n_states::Int`: (**Do not modify.**) The states of the RECurrentControlB depends on the Flags
"""
mutable struct RECurrentControlB <: InnerControl
    "Q Flag used for I_qinj"
    Q_Flag::Int
    "PQ Flag used for the Current Limit Logic"
    PQ_Flag::Int
    "Limits for Voltage Dip Logic `(Vdip, Vup)`"
    Vdip_lim::MinMax
    "Voltage Filter Time Constant"
    T_rv::Float64
    "Voltage error deadband thresholds `(dbd1, dbd2)`"
    dbd_pnts::Tuple{Float64, Float64}
    "Reactive current injection gain during over and undervoltage conditions"
    K_qv::Float64
    "Limits for Iqinj `(I_qh1, I_ql1)`"
    Iqinj_lim::MinMax
    "User defined reference. If 0, [`PowerSimulationsDynamics.jl`](https://sienna-platform.github.io/PowerSimulationsDynamics.jl/stable/) initializes to initial terminal voltage"
    V_ref0::Float64
    "Voltage regulator proportional gain (used when QFlag = 1)"
    K_vp::Float64
    "Voltage regulator integral gain (used when QFlag = 1)"
    K_vi::Float64
    "Time constant for low-pass filter for state q_V when QFlag = 0"
    T_iq::Float64
    "Maximum limit on total converter current"
    I_max::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the RECurrentControlB depends on the Flags"
    states::Vector{Symbol}
    "(**Do not modify.**) The states of the RECurrentControlB depends on the Flags"
    n_states::Int
end

function RECurrentControlB(Q_Flag, PQ_Flag, Vdip_lim, T_rv, dbd_pnts, K_qv, Iqinj_lim, V_ref0, K_vp, K_vi, T_iq, I_max, ext=Dict{String, Any}(), )
    RECurrentControlB(Q_Flag, PQ_Flag, Vdip_lim, T_rv, dbd_pnts, K_qv, Iqinj_lim, V_ref0, K_vp, K_vi, T_iq, I_max, ext, PowerSystems.get_REControlB_states(Q_Flag), 2, )
end

function RECurrentControlB(; Q_Flag, PQ_Flag, Vdip_lim, T_rv, dbd_pnts, K_qv, Iqinj_lim, V_ref0, K_vp, K_vi, T_iq, I_max, ext=Dict{String, Any}(), states=PowerSystems.get_REControlB_states(Q_Flag), n_states=2, )
    RECurrentControlB(Q_Flag, PQ_Flag, Vdip_lim, T_rv, dbd_pnts, K_qv, Iqinj_lim, V_ref0, K_vp, K_vi, T_iq, I_max, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function RECurrentControlB(::Nothing)
    RECurrentControlB(;
        Q_Flag=0,
        PQ_Flag=0,
        Vdip_lim=(min=0.0, max=0.0),
        T_rv=0,
        dbd_pnts=(0.0, 0.0),
        K_qv=0,
        Iqinj_lim=(min=0.0, max=0.0),
        V_ref0=0,
        K_vp=0,
        K_vi=0,
        T_iq=0,
        I_max=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`RECurrentControlB`](@ref) `Q_Flag`."""
get_Q_Flag(value::RECurrentControlB) = value.Q_Flag
"""Get [`RECurrentControlB`](@ref) `PQ_Flag`."""
get_PQ_Flag(value::RECurrentControlB) = value.PQ_Flag
"""Get [`RECurrentControlB`](@ref) `Vdip_lim`."""
get_Vdip_lim(value::RECurrentControlB) = value.Vdip_lim
"""Get [`RECurrentControlB`](@ref) `T_rv`."""
get_T_rv(value::RECurrentControlB) = value.T_rv
"""Get [`RECurrentControlB`](@ref) `dbd_pnts`."""
get_dbd_pnts(value::RECurrentControlB) = value.dbd_pnts
"""Get [`RECurrentControlB`](@ref) `K_qv`."""
get_K_qv(value::RECurrentControlB) = value.K_qv
"""Get [`RECurrentControlB`](@ref) `Iqinj_lim`."""
get_Iqinj_lim(value::RECurrentControlB) = value.Iqinj_lim
"""Get [`RECurrentControlB`](@ref) `V_ref0`."""
get_V_ref0(value::RECurrentControlB) = value.V_ref0
"""Get [`RECurrentControlB`](@ref) `K_vp`."""
get_K_vp(value::RECurrentControlB) = value.K_vp
"""Get [`RECurrentControlB`](@ref) `K_vi`."""
get_K_vi(value::RECurrentControlB) = value.K_vi
"""Get [`RECurrentControlB`](@ref) `T_iq`."""
get_T_iq(value::RECurrentControlB) = value.T_iq
"""Get [`RECurrentControlB`](@ref) `I_max`."""
get_I_max(value::RECurrentControlB) = value.I_max
"""Get [`RECurrentControlB`](@ref) `ext`."""
get_ext(value::RECurrentControlB) = value.ext
"""Get [`RECurrentControlB`](@ref) `states`."""
get_states(value::RECurrentControlB) = value.states
"""Get [`RECurrentControlB`](@ref) `n_states`."""
get_n_states(value::RECurrentControlB) = value.n_states

"""Set [`RECurrentControlB`](@ref) `Q_Flag`."""
set_Q_Flag!(value::RECurrentControlB, val) = value.Q_Flag = val
"""Set [`RECurrentControlB`](@ref) `PQ_Flag`."""
set_PQ_Flag!(value::RECurrentControlB, val) = value.PQ_Flag = val
"""Set [`RECurrentControlB`](@ref) `Vdip_lim`."""
set_Vdip_lim!(value::RECurrentControlB, val) = value.Vdip_lim = val
"""Set [`RECurrentControlB`](@ref) `T_rv`."""
set_T_rv!(value::RECurrentControlB, val) = value.T_rv = val
"""Set [`RECurrentControlB`](@ref) `dbd_pnts`."""
set_dbd_pnts!(value::RECurrentControlB, val) = value.dbd_pnts = val
"""Set [`RECurrentControlB`](@ref) `K_qv`."""
set_K_qv!(value::RECurrentControlB, val) = value.K_qv = val
"""Set [`RECurrentControlB`](@ref) `Iqinj_lim`."""
set_Iqinj_lim!(value::RECurrentControlB, val) = value.Iqinj_lim = val
"""Set [`RECurrentControlB`](@ref) `V_ref0`."""
set_V_ref0!(value::RECurrentControlB, val) = value.V_ref0 = val
"""Set [`RECurrentControlB`](@ref) `K_vp`."""
set_K_vp!(value::RECurrentControlB, val) = value.K_vp = val
"""Set [`RECurrentControlB`](@ref) `K_vi`."""
set_K_vi!(value::RECurrentControlB, val) = value.K_vi = val
"""Set [`RECurrentControlB`](@ref) `T_iq`."""
set_T_iq!(value::RECurrentControlB, val) = value.T_iq = val
"""Set [`RECurrentControlB`](@ref) `I_max`."""
set_I_max!(value::RECurrentControlB, val) = value.I_max = val
"""Set [`RECurrentControlB`](@ref) `ext`."""
set_ext!(value::RECurrentControlB, val) = value.ext = val
