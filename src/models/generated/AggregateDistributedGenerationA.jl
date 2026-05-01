#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct AggregateDistributedGenerationA <: DynamicInjection
        name::String
        Pf_Flag::Int
        Freq_Flag::Int
        PQ_Flag::Int
        Gen_Flag::Int
        Vtrip_Flag::Int
        Ftrip_Flag::Int
        T_rv::Float64
        Trf::Float64
        dbd_pnts::Tuple{Float64, Float64}
        K_qv::Float64
        Tp::Float64
        T_iq::Float64
        D_dn::Float64
        D_up::Float64
        fdbd_pnts::Tuple{Float64, Float64}
        fe_lim::MinMax
        P_lim::MinMax
        dP_lim::MinMax
        Tpord::Float64
        Kpg::Float64
        Kig::Float64
        I_max::Float64
        vl_pnts::Vector{Tuple{Float64,Float64}}
        vh_pnts::Vector{Tuple{Float64,Float64}}
        Vrfrac::Float64
        fl::Float64
        fh::Float64
        tfl::Float64
        tfh::Float64
        Tg::Float64
        rrpwr::Float64
        Tv::Float64
        Vpr::Float64
        Iq_lim::MinMax
        V_ref::Float64
        Pfa_ref::Float64
        ω_ref::Float64
        Q_ref::Float64
        P_ref::Float64
        base_power::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of the DERA1 model in PSS/E

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `Pf_Flag::Int`: Flag for Power Factor Control, validation range: `(0, 1)`
- `Freq_Flag::Int`: Flag to enable/disable frequency control, validation range: `(0, 1)`
- `PQ_Flag::Int`: Flag used to enforce maximum current, validation range: `(0, 1)`
- `Gen_Flag::Int`: Flag to specify generator or storage, validation range: `(0, 1)`
- `Vtrip_Flag::Int`: Flag to enable/disable voltage trip logic, validation range: `(0, 1)`
- `Ftrip_Flag::Int`: Flag to enable/disable frequency trip logic, validation range: `(0, 1)`
- `T_rv::Float64`: Voltage measurement transducer time constant, validation range: `(0, nothing)`
- `Trf::Float64`: Frequency measurement transducer time constant, validation range: `(0, nothing)`
- `dbd_pnts::Tuple{Float64, Float64}`: Voltage deadband thresholds `(dbd1, dbd2)`
- `K_qv::Float64`: Proportional voltage control gain (pu), validation range: `(0, nothing)`
- `Tp::Float64`: Power measurement transducer time constant, validation range: `(0, nothing)`
- `T_iq::Float64`: Time constant for low-pass filter for state q_V when QFlag = 0, validation range: `(0, nothing)`
- `D_dn::Float64`: Reciprocal of droop for over-frequency conditions (>0) (pu), validation range: `(0, nothing)`
- `D_up::Float64`: Reciprocal of droop for under-frequency conditions <=0) (pu), validation range: `(0, nothing)`
- `fdbd_pnts::Tuple{Float64, Float64}`: Frequency control deadband thresholds `(fdbd1, fdbd2)`
- `fe_lim::MinMax`: Frequency error limits (femin, femax)
- `P_lim::MinMax`: Power limits (Pmin, Pmax)
- `dP_lim::MinMax`: Power reference ramp rate limits (dPmin, dPmax)
- `Tpord::Float64`: Power filter time constant, validation range: `(0, nothing)`
- `Kpg::Float64`: PI controller proportional gain (pu), validation range: `(0, nothing)`
- `Kig::Float64`: PI controller integral gain (pu), validation range: `(0, nothing)`
- `I_max::Float64`: Maximum limit on total converter current (pu), validation range: `(0, nothing)`
- `vl_pnts::Vector{Tuple{Float64,Float64}}`: Low voltage cutout points `[(tv10, vl0), (tv11, vl1)]`
- `vh_pnts::Vector{Tuple{Float64,Float64}}`: High voltage cutout points `[(tvh0, vh0), (tvh1, vh1)]`
- `Vrfrac::Float64`: Fraction of device that recovers after voltage comes back to within vl1 < V < vh1 (0 <= Vrfrac <= 1), validation range: `(0, 1)`
- `fl::Float64`: Inverter frequency break-point for low frequency cut-out (Hz), validation range: `(0, nothing)`
- `fh::Float64`: Inverter frequency break-point for high frequency cut-out (Hz), validation range: `(0, nothing)`
- `tfl::Float64`: Low frequency cut-out timer corresponding to frequency fl (s), validation range: `(0, nothing)`
- `tfh::Float64`: High frequency cut-out timer corresponding to frequency fh (s), validation range: `(0, nothing)`
- `Tg::Float64`: Current control time constant (to represent behavior of inner control loops) (> 0) (s), validation range: `(0, nothing)`
- `rrpwr::Float64`: Ramp rate for real power increase following a fault (pu/s), validation range: `(0, nothing)`
- `Tv::Float64`: Time constant on the output of the multiplier (s), validation range: `(0, nothing)`
- `Vpr::Float64`: Voltage below which frequency tripping is disabled (pu), validation range: `(0, nothing)`
- `Iq_lim::MinMax`: Reactive current injection limits (Iqll, Iqhl)
- `V_ref::Float64`: (default: `1.0`) User defined voltage reference. If 0, [`PowerSimulationsDynamics.jl`](https://sienna-platform.github.io/PowerSimulationsDynamics.jl/stable/) initializes to initial terminal voltage, validation range: `(0, nothing)`
- `Pfa_ref::Float64`: (default: `0.0`) Reference power factor, validation range: `(0, nothing)`
- `ω_ref::Float64`: (default: `1.0`) Reference Frequency (pu), validation range: `(0, nothing)`
- `Q_ref::Float64`: (default: `0.0`) Reference reactive power, in pu, validation range: `(0, nothing)`
- `P_ref::Float64`: (default: `1.0`) Reference active power, in pu, validation range: `(0, nothing)`
- `base_power::Float64`: (default: `100.0`) Base power (MVA) for [per unitization](@ref per_unit)
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of AggregateDistributedGenerationA depends on the Flags
- `n_states::Int`: (**Do not modify.**) The states of AggregateDistributedGenerationA depends on the Flags
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct AggregateDistributedGenerationA <: DynamicInjection
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Flag for Power Factor Control"
    Pf_Flag::Int
    "Flag to enable/disable frequency control"
    Freq_Flag::Int
    "Flag used to enforce maximum current"
    PQ_Flag::Int
    "Flag to specify generator or storage"
    Gen_Flag::Int
    "Flag to enable/disable voltage trip logic"
    Vtrip_Flag::Int
    "Flag to enable/disable frequency trip logic"
    Ftrip_Flag::Int
    "Voltage measurement transducer time constant"
    T_rv::Float64
    "Frequency measurement transducer time constant"
    Trf::Float64
    "Voltage deadband thresholds `(dbd1, dbd2)`"
    dbd_pnts::Tuple{Float64, Float64}
    "Proportional voltage control gain (pu)"
    K_qv::Float64
    "Power measurement transducer time constant"
    Tp::Float64
    "Time constant for low-pass filter for state q_V when QFlag = 0"
    T_iq::Float64
    "Reciprocal of droop for over-frequency conditions (>0) (pu)"
    D_dn::Float64
    "Reciprocal of droop for under-frequency conditions <=0) (pu)"
    D_up::Float64
    "Frequency control deadband thresholds `(fdbd1, fdbd2)`"
    fdbd_pnts::Tuple{Float64, Float64}
    "Frequency error limits (femin, femax)"
    fe_lim::MinMax
    "Power limits (Pmin, Pmax)"
    P_lim::MinMax
    "Power reference ramp rate limits (dPmin, dPmax)"
    dP_lim::MinMax
    "Power filter time constant"
    Tpord::Float64
    "PI controller proportional gain (pu)"
    Kpg::Float64
    "PI controller integral gain (pu)"
    Kig::Float64
    "Maximum limit on total converter current (pu)"
    I_max::Float64
    "Low voltage cutout points `[(tv10, vl0), (tv11, vl1)]`"
    vl_pnts::Vector{Tuple{Float64,Float64}}
    "High voltage cutout points `[(tvh0, vh0), (tvh1, vh1)]`"
    vh_pnts::Vector{Tuple{Float64,Float64}}
    "Fraction of device that recovers after voltage comes back to within vl1 < V < vh1 (0 <= Vrfrac <= 1)"
    Vrfrac::Float64
    "Inverter frequency break-point for low frequency cut-out (Hz)"
    fl::Float64
    "Inverter frequency break-point for high frequency cut-out (Hz)"
    fh::Float64
    "Low frequency cut-out timer corresponding to frequency fl (s)"
    tfl::Float64
    "High frequency cut-out timer corresponding to frequency fh (s)"
    tfh::Float64
    "Current control time constant (to represent behavior of inner control loops) (> 0) (s)"
    Tg::Float64
    "Ramp rate for real power increase following a fault (pu/s)"
    rrpwr::Float64
    "Time constant on the output of the multiplier (s)"
    Tv::Float64
    "Voltage below which frequency tripping is disabled (pu)"
    Vpr::Float64
    "Reactive current injection limits (Iqll, Iqhl)"
    Iq_lim::MinMax
    "User defined voltage reference. If 0, [`PowerSimulationsDynamics.jl`](https://sienna-platform.github.io/PowerSimulationsDynamics.jl/stable/) initializes to initial terminal voltage"
    V_ref::Float64
    "Reference power factor"
    Pfa_ref::Float64
    "Reference Frequency (pu)"
    ω_ref::Float64
    "Reference reactive power, in pu"
    Q_ref::Float64
    "Reference active power, in pu"
    P_ref::Float64
    "Base power (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of AggregateDistributedGenerationA depends on the Flags"
    states::Vector{Symbol}
    "(**Do not modify.**) The states of AggregateDistributedGenerationA depends on the Flags"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function AggregateDistributedGenerationA(name, Pf_Flag, Freq_Flag, PQ_Flag, Gen_Flag, Vtrip_Flag, Ftrip_Flag, T_rv, Trf, dbd_pnts, K_qv, Tp, T_iq, D_dn, D_up, fdbd_pnts, fe_lim, P_lim, dP_lim, Tpord, Kpg, Kig, I_max, vl_pnts, vh_pnts, Vrfrac, fl, fh, tfl, tfh, Tg, rrpwr, Tv, Vpr, Iq_lim, V_ref=1.0, Pfa_ref=0.0, ω_ref=1.0, Q_ref=0.0, P_ref=1.0, base_power=100.0, ext=Dict{String, Any}(), )
    AggregateDistributedGenerationA(name, Pf_Flag, Freq_Flag, PQ_Flag, Gen_Flag, Vtrip_Flag, Ftrip_Flag, T_rv, Trf, dbd_pnts, K_qv, Tp, T_iq, D_dn, D_up, fdbd_pnts, fe_lim, P_lim, dP_lim, Tpord, Kpg, Kig, I_max, vl_pnts, vh_pnts, Vrfrac, fl, fh, tfl, tfh, Tg, rrpwr, Tv, Vpr, Iq_lim, V_ref, Pfa_ref, ω_ref, Q_ref, P_ref, base_power, ext, PowerSystems.get_AggregateDistributedGenerationA_states(Freq_Flag)[1], PowerSystems.get_AggregateDistributedGenerationA_states(Freq_Flag)[2], InfrastructureSystemsInternal(), )
end

function AggregateDistributedGenerationA(; name, Pf_Flag, Freq_Flag, PQ_Flag, Gen_Flag, Vtrip_Flag, Ftrip_Flag, T_rv, Trf, dbd_pnts, K_qv, Tp, T_iq, D_dn, D_up, fdbd_pnts, fe_lim, P_lim, dP_lim, Tpord, Kpg, Kig, I_max, vl_pnts, vh_pnts, Vrfrac, fl, fh, tfl, tfh, Tg, rrpwr, Tv, Vpr, Iq_lim, V_ref=1.0, Pfa_ref=0.0, ω_ref=1.0, Q_ref=0.0, P_ref=1.0, base_power=100.0, ext=Dict{String, Any}(), states=PowerSystems.get_AggregateDistributedGenerationA_states(Freq_Flag)[1], n_states=PowerSystems.get_AggregateDistributedGenerationA_states(Freq_Flag)[2], internal=InfrastructureSystemsInternal(), )
    AggregateDistributedGenerationA(name, Pf_Flag, Freq_Flag, PQ_Flag, Gen_Flag, Vtrip_Flag, Ftrip_Flag, T_rv, Trf, dbd_pnts, K_qv, Tp, T_iq, D_dn, D_up, fdbd_pnts, fe_lim, P_lim, dP_lim, Tpord, Kpg, Kig, I_max, vl_pnts, vh_pnts, Vrfrac, fl, fh, tfl, tfh, Tg, rrpwr, Tv, Vpr, Iq_lim, V_ref, Pfa_ref, ω_ref, Q_ref, P_ref, base_power, ext, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function AggregateDistributedGenerationA(::Nothing)
    AggregateDistributedGenerationA(;
        name="init",
        Pf_Flag=0,
        Freq_Flag=0,
        PQ_Flag=0,
        Gen_Flag=0,
        Vtrip_Flag=0,
        Ftrip_Flag=0,
        T_rv=0,
        Trf=0,
        dbd_pnts=(0.0, 0.0),
        K_qv=0,
        Tp=0,
        T_iq=0,
        D_dn=0,
        D_up=0,
        fdbd_pnts=(0.0, 0.0),
        fe_lim=(min=0.0, max=0.0),
        P_lim=(min=0.0, max=0.0),
        dP_lim=(min=0.0, max=0.0),
        Tpord=0,
        Kpg=0,
        Kig=0,
        I_max=0,
        vl_pnts=[(0.0, 0.0), (0.0, 0.0)],
        vh_pnts=[(0.0, 0.0), (0.0, 0.0)],
        Vrfrac=0,
        fl=0,
        fh=0,
        tfl=0,
        tfh=0,
        Tg=0,
        rrpwr=0,
        Tv=0,
        Vpr=0,
        Iq_lim=(min=0.0, max=0.0),
        V_ref=0,
        Pfa_ref=0,
        ω_ref=0,
        Q_ref=0,
        P_ref=0,
        base_power=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`AggregateDistributedGenerationA`](@ref) `name`."""
get_name(value::AggregateDistributedGenerationA) = value.name
"""Get [`AggregateDistributedGenerationA`](@ref) `Pf_Flag`."""
get_Pf_Flag(value::AggregateDistributedGenerationA) = value.Pf_Flag
"""Get [`AggregateDistributedGenerationA`](@ref) `Freq_Flag`."""
get_Freq_Flag(value::AggregateDistributedGenerationA) = value.Freq_Flag
"""Get [`AggregateDistributedGenerationA`](@ref) `PQ_Flag`."""
get_PQ_Flag(value::AggregateDistributedGenerationA) = value.PQ_Flag
"""Get [`AggregateDistributedGenerationA`](@ref) `Gen_Flag`."""
get_Gen_Flag(value::AggregateDistributedGenerationA) = value.Gen_Flag
"""Get [`AggregateDistributedGenerationA`](@ref) `Vtrip_Flag`."""
get_Vtrip_Flag(value::AggregateDistributedGenerationA) = value.Vtrip_Flag
"""Get [`AggregateDistributedGenerationA`](@ref) `Ftrip_Flag`."""
get_Ftrip_Flag(value::AggregateDistributedGenerationA) = value.Ftrip_Flag
"""Get [`AggregateDistributedGenerationA`](@ref) `T_rv`."""
get_T_rv(value::AggregateDistributedGenerationA) = value.T_rv
"""Get [`AggregateDistributedGenerationA`](@ref) `Trf`."""
get_Trf(value::AggregateDistributedGenerationA) = value.Trf
"""Get [`AggregateDistributedGenerationA`](@ref) `dbd_pnts`."""
get_dbd_pnts(value::AggregateDistributedGenerationA) = value.dbd_pnts
"""Get [`AggregateDistributedGenerationA`](@ref) `K_qv`."""
get_K_qv(value::AggregateDistributedGenerationA) = value.K_qv
"""Get [`AggregateDistributedGenerationA`](@ref) `Tp`."""
get_Tp(value::AggregateDistributedGenerationA) = value.Tp
"""Get [`AggregateDistributedGenerationA`](@ref) `T_iq`."""
get_T_iq(value::AggregateDistributedGenerationA) = value.T_iq
"""Get [`AggregateDistributedGenerationA`](@ref) `D_dn`."""
get_D_dn(value::AggregateDistributedGenerationA) = value.D_dn
"""Get [`AggregateDistributedGenerationA`](@ref) `D_up`."""
get_D_up(value::AggregateDistributedGenerationA) = value.D_up
"""Get [`AggregateDistributedGenerationA`](@ref) `fdbd_pnts`."""
get_fdbd_pnts(value::AggregateDistributedGenerationA) = value.fdbd_pnts
"""Get [`AggregateDistributedGenerationA`](@ref) `fe_lim`."""
get_fe_lim(value::AggregateDistributedGenerationA) = value.fe_lim
"""Get [`AggregateDistributedGenerationA`](@ref) `P_lim`."""
get_P_lim(value::AggregateDistributedGenerationA) = value.P_lim
"""Get [`AggregateDistributedGenerationA`](@ref) `dP_lim`."""
get_dP_lim(value::AggregateDistributedGenerationA) = value.dP_lim
"""Get [`AggregateDistributedGenerationA`](@ref) `Tpord`."""
get_Tpord(value::AggregateDistributedGenerationA) = value.Tpord
"""Get [`AggregateDistributedGenerationA`](@ref) `Kpg`."""
get_Kpg(value::AggregateDistributedGenerationA) = value.Kpg
"""Get [`AggregateDistributedGenerationA`](@ref) `Kig`."""
get_Kig(value::AggregateDistributedGenerationA) = value.Kig
"""Get [`AggregateDistributedGenerationA`](@ref) `I_max`."""
get_I_max(value::AggregateDistributedGenerationA) = value.I_max
"""Get [`AggregateDistributedGenerationA`](@ref) `vl_pnts`."""
get_vl_pnts(value::AggregateDistributedGenerationA) = value.vl_pnts
"""Get [`AggregateDistributedGenerationA`](@ref) `vh_pnts`."""
get_vh_pnts(value::AggregateDistributedGenerationA) = value.vh_pnts
"""Get [`AggregateDistributedGenerationA`](@ref) `Vrfrac`."""
get_Vrfrac(value::AggregateDistributedGenerationA) = value.Vrfrac
"""Get [`AggregateDistributedGenerationA`](@ref) `fl`."""
get_fl(value::AggregateDistributedGenerationA) = value.fl
"""Get [`AggregateDistributedGenerationA`](@ref) `fh`."""
get_fh(value::AggregateDistributedGenerationA) = value.fh
"""Get [`AggregateDistributedGenerationA`](@ref) `tfl`."""
get_tfl(value::AggregateDistributedGenerationA) = value.tfl
"""Get [`AggregateDistributedGenerationA`](@ref) `tfh`."""
get_tfh(value::AggregateDistributedGenerationA) = value.tfh
"""Get [`AggregateDistributedGenerationA`](@ref) `Tg`."""
get_Tg(value::AggregateDistributedGenerationA) = value.Tg
"""Get [`AggregateDistributedGenerationA`](@ref) `rrpwr`."""
get_rrpwr(value::AggregateDistributedGenerationA) = value.rrpwr
"""Get [`AggregateDistributedGenerationA`](@ref) `Tv`."""
get_Tv(value::AggregateDistributedGenerationA) = value.Tv
"""Get [`AggregateDistributedGenerationA`](@ref) `Vpr`."""
get_Vpr(value::AggregateDistributedGenerationA) = value.Vpr
"""Get [`AggregateDistributedGenerationA`](@ref) `Iq_lim`."""
get_Iq_lim(value::AggregateDistributedGenerationA) = value.Iq_lim
"""Get [`AggregateDistributedGenerationA`](@ref) `V_ref`."""
get_V_ref(value::AggregateDistributedGenerationA) = value.V_ref
"""Get [`AggregateDistributedGenerationA`](@ref) `Pfa_ref`."""
get_Pfa_ref(value::AggregateDistributedGenerationA) = value.Pfa_ref
"""Get [`AggregateDistributedGenerationA`](@ref) `ω_ref`."""
get_ω_ref(value::AggregateDistributedGenerationA) = value.ω_ref
"""Get [`AggregateDistributedGenerationA`](@ref) `Q_ref`."""
get_Q_ref(value::AggregateDistributedGenerationA) = value.Q_ref
"""Get [`AggregateDistributedGenerationA`](@ref) `P_ref`."""
get_P_ref(value::AggregateDistributedGenerationA) = value.P_ref
"""Get [`AggregateDistributedGenerationA`](@ref) `base_power`."""
get_base_power(value::AggregateDistributedGenerationA) = value.base_power
"""Get [`AggregateDistributedGenerationA`](@ref) `ext`."""
get_ext(value::AggregateDistributedGenerationA) = value.ext
"""Get [`AggregateDistributedGenerationA`](@ref) `states`."""
get_states(value::AggregateDistributedGenerationA) = value.states
"""Get [`AggregateDistributedGenerationA`](@ref) `n_states`."""
get_n_states(value::AggregateDistributedGenerationA) = value.n_states
"""Get [`AggregateDistributedGenerationA`](@ref) `internal`."""
get_internal(value::AggregateDistributedGenerationA) = value.internal

"""Set [`AggregateDistributedGenerationA`](@ref) `Pf_Flag`."""
set_Pf_Flag!(value::AggregateDistributedGenerationA, val) = value.Pf_Flag = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Freq_Flag`."""
set_Freq_Flag!(value::AggregateDistributedGenerationA, val) = value.Freq_Flag = val
"""Set [`AggregateDistributedGenerationA`](@ref) `PQ_Flag`."""
set_PQ_Flag!(value::AggregateDistributedGenerationA, val) = value.PQ_Flag = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Gen_Flag`."""
set_Gen_Flag!(value::AggregateDistributedGenerationA, val) = value.Gen_Flag = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Vtrip_Flag`."""
set_Vtrip_Flag!(value::AggregateDistributedGenerationA, val) = value.Vtrip_Flag = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Ftrip_Flag`."""
set_Ftrip_Flag!(value::AggregateDistributedGenerationA, val) = value.Ftrip_Flag = val
"""Set [`AggregateDistributedGenerationA`](@ref) `T_rv`."""
set_T_rv!(value::AggregateDistributedGenerationA, val) = value.T_rv = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Trf`."""
set_Trf!(value::AggregateDistributedGenerationA, val) = value.Trf = val
"""Set [`AggregateDistributedGenerationA`](@ref) `dbd_pnts`."""
set_dbd_pnts!(value::AggregateDistributedGenerationA, val) = value.dbd_pnts = val
"""Set [`AggregateDistributedGenerationA`](@ref) `K_qv`."""
set_K_qv!(value::AggregateDistributedGenerationA, val) = value.K_qv = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Tp`."""
set_Tp!(value::AggregateDistributedGenerationA, val) = value.Tp = val
"""Set [`AggregateDistributedGenerationA`](@ref) `T_iq`."""
set_T_iq!(value::AggregateDistributedGenerationA, val) = value.T_iq = val
"""Set [`AggregateDistributedGenerationA`](@ref) `D_dn`."""
set_D_dn!(value::AggregateDistributedGenerationA, val) = value.D_dn = val
"""Set [`AggregateDistributedGenerationA`](@ref) `D_up`."""
set_D_up!(value::AggregateDistributedGenerationA, val) = value.D_up = val
"""Set [`AggregateDistributedGenerationA`](@ref) `fdbd_pnts`."""
set_fdbd_pnts!(value::AggregateDistributedGenerationA, val) = value.fdbd_pnts = val
"""Set [`AggregateDistributedGenerationA`](@ref) `fe_lim`."""
set_fe_lim!(value::AggregateDistributedGenerationA, val) = value.fe_lim = val
"""Set [`AggregateDistributedGenerationA`](@ref) `P_lim`."""
set_P_lim!(value::AggregateDistributedGenerationA, val) = value.P_lim = val
"""Set [`AggregateDistributedGenerationA`](@ref) `dP_lim`."""
set_dP_lim!(value::AggregateDistributedGenerationA, val) = value.dP_lim = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Tpord`."""
set_Tpord!(value::AggregateDistributedGenerationA, val) = value.Tpord = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Kpg`."""
set_Kpg!(value::AggregateDistributedGenerationA, val) = value.Kpg = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Kig`."""
set_Kig!(value::AggregateDistributedGenerationA, val) = value.Kig = val
"""Set [`AggregateDistributedGenerationA`](@ref) `I_max`."""
set_I_max!(value::AggregateDistributedGenerationA, val) = value.I_max = val
"""Set [`AggregateDistributedGenerationA`](@ref) `vl_pnts`."""
set_vl_pnts!(value::AggregateDistributedGenerationA, val) = value.vl_pnts = val
"""Set [`AggregateDistributedGenerationA`](@ref) `vh_pnts`."""
set_vh_pnts!(value::AggregateDistributedGenerationA, val) = value.vh_pnts = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Vrfrac`."""
set_Vrfrac!(value::AggregateDistributedGenerationA, val) = value.Vrfrac = val
"""Set [`AggregateDistributedGenerationA`](@ref) `fl`."""
set_fl!(value::AggregateDistributedGenerationA, val) = value.fl = val
"""Set [`AggregateDistributedGenerationA`](@ref) `fh`."""
set_fh!(value::AggregateDistributedGenerationA, val) = value.fh = val
"""Set [`AggregateDistributedGenerationA`](@ref) `tfl`."""
set_tfl!(value::AggregateDistributedGenerationA, val) = value.tfl = val
"""Set [`AggregateDistributedGenerationA`](@ref) `tfh`."""
set_tfh!(value::AggregateDistributedGenerationA, val) = value.tfh = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Tg`."""
set_Tg!(value::AggregateDistributedGenerationA, val) = value.Tg = val
"""Set [`AggregateDistributedGenerationA`](@ref) `rrpwr`."""
set_rrpwr!(value::AggregateDistributedGenerationA, val) = value.rrpwr = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Tv`."""
set_Tv!(value::AggregateDistributedGenerationA, val) = value.Tv = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Vpr`."""
set_Vpr!(value::AggregateDistributedGenerationA, val) = value.Vpr = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Iq_lim`."""
set_Iq_lim!(value::AggregateDistributedGenerationA, val) = value.Iq_lim = val
"""Set [`AggregateDistributedGenerationA`](@ref) `V_ref`."""
set_V_ref!(value::AggregateDistributedGenerationA, val) = value.V_ref = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Pfa_ref`."""
set_Pfa_ref!(value::AggregateDistributedGenerationA, val) = value.Pfa_ref = val
"""Set [`AggregateDistributedGenerationA`](@ref) `ω_ref`."""
set_ω_ref!(value::AggregateDistributedGenerationA, val) = value.ω_ref = val
"""Set [`AggregateDistributedGenerationA`](@ref) `Q_ref`."""
set_Q_ref!(value::AggregateDistributedGenerationA, val) = value.Q_ref = val
"""Set [`AggregateDistributedGenerationA`](@ref) `P_ref`."""
set_P_ref!(value::AggregateDistributedGenerationA, val) = value.P_ref = val
"""Set [`AggregateDistributedGenerationA`](@ref) `base_power`."""
set_base_power!(value::AggregateDistributedGenerationA, val) = value.base_power = val
"""Set [`AggregateDistributedGenerationA`](@ref) `ext`."""
set_ext!(value::AggregateDistributedGenerationA, val) = value.ext = val
