#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct GenericDER <: DynamicInjection
        name::String
        Qref_Flag::Int
        PQ_Flag::Int
        Gen_Flag::Int
        PerOp_Flag::Int
        Recon_Flag::Int
        Trv::Float64
        VV_pnts::NamedTuple{(:V1, :V2, :V3, :V4), Tuple{Float64, Float64, Float64, Float64}}
        Q_lim::MinMax
        Tp::Float64
        e_lim::MinMax
        Kpq::Float64
        Kiq::Float64
        Iqr_lim::MinMax
        I_max::Float64
        Tg::Float64
        kWh_Cap::Float64
        SOC_ini::Float64
        SOC_lim::MinMax
        Trf::Float64
        fdbd_pnts::NamedTuple{(:fdbd1, :fdbd2), Tuple{Float64, Float64}}
        D_dn::Float64
        D_up::Float64
        fe_lim::MinMax
        Kpp::Float64
        Kip::Float64
        P_lim::MinMax
        dP_lim::MinMax
        T_pord::Float64
        rrpwr::Float64
        VRT_pnts::NamedTuple{(:vrt1, :vrt2, :vrt3, :vrt4, :vrt5), Tuple{Float64, Float64, Float64, Float64, Float64}}
        TVRT_pnts::NamedTuple{(:tvrt1, :tvrt2, :tvrt3), Tuple{Float64, Float64, Float64}}
        tV_delay::Float64
        VES_lim::MinMax
        FRT_pnts::NamedTuple{(:frt1, :frt2, :frt3, :frt4), Tuple{Float64, Float64, Float64, Float64}}
        TFRT_pnts::NamedTuple{(:tfrt1, :tfrt2), Tuple{Float64, Float64}}
        tF_delay::Float64
        FES_lim::MinMax
        Pfa_ref::Float64
        Q_ref::Float64
        P_ref::Float64
        base_power::Float64
        states::Vector{Symbol}
        n_states::Int
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

Parameters of a Generic Distributed Energy Resource Model. Based on ["Modeling Framework and Coordination of DER and Flexible Loads for Ancillary Service Provision."](http://hdl.handle.net/10125/70994)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `Qref_Flag::Int`: Reactive Power Control Mode. 1 VoltVar Control, 2 Constant Q Control, 3 Constant PF Control, validation range: `(1, 3)`
- `PQ_Flag::Int`: Active and reactive power priority mode. 0 for Q priority, 1 for P priority, validation range: `(0, 1)`
- `Gen_Flag::Int`: Define generator or storage system. 0 unit is a storage device, 1 unit is a generator, validation range: `(0, 1)`
- `PerOp_Flag::Int`: Defines operation of permisible region in VRT characteristic. 0 for cease, 1 for continuous operation, validation range: `(0, 1)`
- `Recon_Flag::Int`: Defines if DER can reconnect after voltage ride-through disconnection, validation range: `(0, 1)`
- `Trv::Float64`: Voltage measurement transducer's time constant, in s, validation range: `(0, nothing)`
- `VV_pnts::NamedTuple{(:V1, :V2, :V3, :V4), Tuple{Float64, Float64, Float64, Float64}}`: Y-axis Volt-var curve points (V1,V2,V3,V4)
- `Q_lim::MinMax`: Reactive power limits in pu (Q_min, Q_max)
- `Tp::Float64`: Power measurement transducer's time constant, in s, validation range: `(0, nothing)`
- `e_lim::MinMax`: Error limit in PI controller for q control (e_min, e_max)
- `Kpq::Float64`: PI controller proportional gain for q control, validation range: `(0, nothing)`
- `Kiq::Float64`: PI controller integral gain for q control, validation range: `(0, nothing)`
- `Iqr_lim::MinMax`: Limit on rate of change for reactive current (pu/s) (Iqr_min, Iqr_max)
- `I_max::Float64`: Max. inverter's current, validation range: `(0, nothing)`
- `Tg::Float64`: Current control's time constant, in s, validation range: `(0, nothing)`
- `kWh_Cap::Float64`: BESS capacity in kWh, validation range: `(0, nothing)`
- `SOC_ini::Float64`: Initial state of charge (SOC) in pu, validation range: `(0, 1)`
- `SOC_lim::MinMax`: Battery's SOC limits (SOC_min, SOC_max)
- `Trf::Float64`: Time constant to estimate system frequency, in s, validation range: `(0, nothing)`
- `fdbd_pnts::NamedTuple{(:fdbd1, :fdbd2), Tuple{Float64, Float64}}`: Frequency error dead band thresholds `(fdbd1, fdbd2)`
- `D_dn::Float64`: reciprocal of droop for over-frequency conditions, in pu, validation range: `(0, nothing)`
- `D_up::Float64`: reciprocal of droop for under-frequency conditions, in pu, validation range: `(0, nothing)`
- `fe_lim::MinMax`: Frequency error limits in pu (fe_min, fe_max)
- `Kpp::Float64`: PI controller proportional gain for p control, validation range: `(0, nothing)`
- `Kip::Float64`: PI controller integral gain for p control, validation range: `(0, nothing)`
- `P_lim::MinMax`: Active power limits in pu (P_min, P_max)
- `dP_lim::MinMax`: Ramp rate limits for active power in pu/s (dP_min, dP_max)
- `T_pord::Float64`: Power filter time constant in s, validation range: `(0, nothing)`
- `rrpwr::Float64`: Ramp rate for real power increase following a fault, in pu/s, validation range: `(0, nothing)`
- `VRT_pnts::NamedTuple{(:vrt1, :vrt2, :vrt3, :vrt4, :vrt5), Tuple{Float64, Float64, Float64, Float64, Float64}}`: Voltage ride through v points (vrt1,vrt2,vrt3,vrt4,vrt5)
- `TVRT_pnts::NamedTuple{(:tvrt1, :tvrt2, :tvrt3), Tuple{Float64, Float64, Float64}}`: Voltage ride through time points (tvrt1,tvrt2,tvrt3)
- `tV_delay::Float64`: Time delay for reconnection after voltage ride-through disconnection, validation range: `(0, nothing)`
- `VES_lim::MinMax`: Min and max voltage for entering service (VES_min,VES_max)
- `FRT_pnts::NamedTuple{(:frt1, :frt2, :frt3, :frt4), Tuple{Float64, Float64, Float64, Float64}}`: Frequency ride through v points (frt1,frt2,frt3,frt4)
- `TFRT_pnts::NamedTuple{(:tfrt1, :tfrt2), Tuple{Float64, Float64}}`: Frequency ride through time points (tfrt1,tfrt2)
- `tF_delay::Float64`: Time delay for reconnection after frequency ride-through disconnection, validation range: `(0, nothing)`
- `FES_lim::MinMax`: Min and max frequency for entering service (FES_min,FES_max)
- `Pfa_ref::Float64`: (default: `0.0`) Reference power factor, validation range: `(0, nothing)`
- `Q_ref::Float64`: (default: `0.0`) Reference reactive power, in pu, validation range: `(0, nothing)`
- `P_ref::Float64`: (default: `1.0`) Reference active power, in pu, validation range: `(0, nothing)`
- `base_power::Float64`: (default: `100.0`) Base power of the unit (MVA) for [per unitization](@ref per_unit)
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of GenericDER depend on the Flags
- `n_states::Int`: (**Do not modify.**) The [states](@ref S) of GenericDER depend on the Flags
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct GenericDER <: DynamicInjection
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Reactive Power Control Mode. 1 VoltVar Control, 2 Constant Q Control, 3 Constant PF Control"
    Qref_Flag::Int
    "Active and reactive power priority mode. 0 for Q priority, 1 for P priority"
    PQ_Flag::Int
    "Define generator or storage system. 0 unit is a storage device, 1 unit is a generator"
    Gen_Flag::Int
    "Defines operation of permisible region in VRT characteristic. 0 for cease, 1 for continuous operation"
    PerOp_Flag::Int
    "Defines if DER can reconnect after voltage ride-through disconnection"
    Recon_Flag::Int
    "Voltage measurement transducer's time constant, in s"
    Trv::Float64
    "Y-axis Volt-var curve points (V1,V2,V3,V4)"
    VV_pnts::NamedTuple{(:V1, :V2, :V3, :V4), Tuple{Float64, Float64, Float64, Float64}}
    "Reactive power limits in pu (Q_min, Q_max)"
    Q_lim::MinMax
    "Power measurement transducer's time constant, in s"
    Tp::Float64
    "Error limit in PI controller for q control (e_min, e_max)"
    e_lim::MinMax
    "PI controller proportional gain for q control"
    Kpq::Float64
    "PI controller integral gain for q control"
    Kiq::Float64
    "Limit on rate of change for reactive current (pu/s) (Iqr_min, Iqr_max)"
    Iqr_lim::MinMax
    "Max. inverter's current"
    I_max::Float64
    "Current control's time constant, in s"
    Tg::Float64
    "BESS capacity in kWh"
    kWh_Cap::Float64
    "Initial state of charge (SOC) in pu"
    SOC_ini::Float64
    "Battery's SOC limits (SOC_min, SOC_max)"
    SOC_lim::MinMax
    "Time constant to estimate system frequency, in s"
    Trf::Float64
    "Frequency error dead band thresholds `(fdbd1, fdbd2)`"
    fdbd_pnts::NamedTuple{(:fdbd1, :fdbd2), Tuple{Float64, Float64}}
    "reciprocal of droop for over-frequency conditions, in pu"
    D_dn::Float64
    "reciprocal of droop for under-frequency conditions, in pu"
    D_up::Float64
    "Frequency error limits in pu (fe_min, fe_max)"
    fe_lim::MinMax
    "PI controller proportional gain for p control"
    Kpp::Float64
    "PI controller integral gain for p control"
    Kip::Float64
    "Active power limits in pu (P_min, P_max)"
    P_lim::MinMax
    "Ramp rate limits for active power in pu/s (dP_min, dP_max)"
    dP_lim::MinMax
    "Power filter time constant in s"
    T_pord::Float64
    "Ramp rate for real power increase following a fault, in pu/s"
    rrpwr::Float64
    "Voltage ride through v points (vrt1,vrt2,vrt3,vrt4,vrt5)"
    VRT_pnts::NamedTuple{(:vrt1, :vrt2, :vrt3, :vrt4, :vrt5), Tuple{Float64, Float64, Float64, Float64, Float64}}
    "Voltage ride through time points (tvrt1,tvrt2,tvrt3)"
    TVRT_pnts::NamedTuple{(:tvrt1, :tvrt2, :tvrt3), Tuple{Float64, Float64, Float64}}
    "Time delay for reconnection after voltage ride-through disconnection"
    tV_delay::Float64
    "Min and max voltage for entering service (VES_min,VES_max)"
    VES_lim::MinMax
    "Frequency ride through v points (frt1,frt2,frt3,frt4)"
    FRT_pnts::NamedTuple{(:frt1, :frt2, :frt3, :frt4), Tuple{Float64, Float64, Float64, Float64}}
    "Frequency ride through time points (tfrt1,tfrt2)"
    TFRT_pnts::NamedTuple{(:tfrt1, :tfrt2), Tuple{Float64, Float64}}
    "Time delay for reconnection after frequency ride-through disconnection"
    tF_delay::Float64
    "Min and max frequency for entering service (FES_min,FES_max)"
    FES_lim::MinMax
    "Reference power factor"
    Pfa_ref::Float64
    "Reference reactive power, in pu"
    Q_ref::Float64
    "Reference active power, in pu"
    P_ref::Float64
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "(**Do not modify.**) The [states](@ref S) of GenericDER depend on the Flags"
    states::Vector{Symbol}
    "(**Do not modify.**) The [states](@ref S) of GenericDER depend on the Flags"
    n_states::Int
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function GenericDER(name, Qref_Flag, PQ_Flag, Gen_Flag, PerOp_Flag, Recon_Flag, Trv, VV_pnts, Q_lim, Tp, e_lim, Kpq, Kiq, Iqr_lim, I_max, Tg, kWh_Cap, SOC_ini, SOC_lim, Trf, fdbd_pnts, D_dn, D_up, fe_lim, Kpp, Kip, P_lim, dP_lim, T_pord, rrpwr, VRT_pnts, TVRT_pnts, tV_delay, VES_lim, FRT_pnts, TFRT_pnts, tF_delay, FES_lim, Pfa_ref=0.0, Q_ref=0.0, P_ref=1.0, base_power=100.0, ext=Dict{String, Any}(), )
    GenericDER(name, Qref_Flag, PQ_Flag, Gen_Flag, PerOp_Flag, Recon_Flag, Trv, VV_pnts, Q_lim, Tp, e_lim, Kpq, Kiq, Iqr_lim, I_max, Tg, kWh_Cap, SOC_ini, SOC_lim, Trf, fdbd_pnts, D_dn, D_up, fe_lim, Kpp, Kip, P_lim, dP_lim, T_pord, rrpwr, VRT_pnts, TVRT_pnts, tV_delay, VES_lim, FRT_pnts, TFRT_pnts, tF_delay, FES_lim, Pfa_ref, Q_ref, P_ref, base_power, ext, PowerSystems.get_GenericDER_states(Qref_Flag)[1], PowerSystems.get_GenericDER_states(Qref_Flag)[2], InfrastructureSystemsInternal(), )
end

function GenericDER(; name, Qref_Flag, PQ_Flag, Gen_Flag, PerOp_Flag, Recon_Flag, Trv, VV_pnts, Q_lim, Tp, e_lim, Kpq, Kiq, Iqr_lim, I_max, Tg, kWh_Cap, SOC_ini, SOC_lim, Trf, fdbd_pnts, D_dn, D_up, fe_lim, Kpp, Kip, P_lim, dP_lim, T_pord, rrpwr, VRT_pnts, TVRT_pnts, tV_delay, VES_lim, FRT_pnts, TFRT_pnts, tF_delay, FES_lim, Pfa_ref=0.0, Q_ref=0.0, P_ref=1.0, base_power=100.0, states=PowerSystems.get_GenericDER_states(Qref_Flag)[1], n_states=PowerSystems.get_GenericDER_states(Qref_Flag)[2], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    GenericDER(name, Qref_Flag, PQ_Flag, Gen_Flag, PerOp_Flag, Recon_Flag, Trv, VV_pnts, Q_lim, Tp, e_lim, Kpq, Kiq, Iqr_lim, I_max, Tg, kWh_Cap, SOC_ini, SOC_lim, Trf, fdbd_pnts, D_dn, D_up, fe_lim, Kpp, Kip, P_lim, dP_lim, T_pord, rrpwr, VRT_pnts, TVRT_pnts, tV_delay, VES_lim, FRT_pnts, TFRT_pnts, tF_delay, FES_lim, Pfa_ref, Q_ref, P_ref, base_power, states, n_states, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function GenericDER(::Nothing)
    GenericDER(;
        name="init",
        Qref_Flag=1,
        PQ_Flag=0,
        Gen_Flag=0,
        PerOp_Flag=0,
        Recon_Flag=0,
        Trv=0,
        VV_pnts=(V1=0.0, V2=0.0, V3=0.0, V4=0.0),
        Q_lim=(min=0.0, max=0.0),
        Tp=0,
        e_lim=(min=0.0, max=0.0),
        Kpq=0,
        Kiq=0,
        Iqr_lim=(min=0.0, max=0.0),
        I_max=0,
        Tg=0,
        kWh_Cap=0,
        SOC_ini=0,
        SOC_lim=(min=0.0, max=0.0),
        Trf=0,
        fdbd_pnts=(fdbd1=0.0, fdbd2=0.0),
        D_dn=0,
        D_up=0,
        fe_lim=(min=0.0, max=0.0),
        Kpp=0,
        Kip=0,
        P_lim=(min=0.0, max=0.0),
        dP_lim=(min=0.0, max=0.0),
        T_pord=0,
        rrpwr=0,
        VRT_pnts=(vrt1=0.0, vrt2=0.0, vrt3=0.0, vrt4=0.0, vrt5=0.0),
        TVRT_pnts=(tvrt1=0.0, tvrt2=0.0, tvrt3=0.0),
        tV_delay=0,
        VES_lim=(min=0.0, max=0.0),
        FRT_pnts=(frt1=0.0, frt2=0.0, frt3=0.0, frt4=0.0),
        TFRT_pnts=(tfrt1=0.0, tfrt2=0.0),
        tF_delay=0,
        FES_lim=(min=0.0, max=0.0),
        Pfa_ref=0,
        Q_ref=0,
        P_ref=0,
        base_power=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`GenericDER`](@ref) `name`."""
get_name(value::GenericDER) = value.name
"""Get [`GenericDER`](@ref) `Qref_Flag`."""
get_Qref_Flag(value::GenericDER) = value.Qref_Flag
"""Get [`GenericDER`](@ref) `PQ_Flag`."""
get_PQ_Flag(value::GenericDER) = value.PQ_Flag
"""Get [`GenericDER`](@ref) `Gen_Flag`."""
get_Gen_Flag(value::GenericDER) = value.Gen_Flag
"""Get [`GenericDER`](@ref) `PerOp_Flag`."""
get_PerOp_Flag(value::GenericDER) = value.PerOp_Flag
"""Get [`GenericDER`](@ref) `Recon_Flag`."""
get_Recon_Flag(value::GenericDER) = value.Recon_Flag
"""Get [`GenericDER`](@ref) `Trv`."""
get_Trv(value::GenericDER) = value.Trv
"""Get [`GenericDER`](@ref) `VV_pnts`."""
get_VV_pnts(value::GenericDER) = value.VV_pnts
"""Get [`GenericDER`](@ref) `Q_lim`."""
get_Q_lim(value::GenericDER) = value.Q_lim
"""Get [`GenericDER`](@ref) `Tp`."""
get_Tp(value::GenericDER) = value.Tp
"""Get [`GenericDER`](@ref) `e_lim`."""
get_e_lim(value::GenericDER) = value.e_lim
"""Get [`GenericDER`](@ref) `Kpq`."""
get_Kpq(value::GenericDER) = value.Kpq
"""Get [`GenericDER`](@ref) `Kiq`."""
get_Kiq(value::GenericDER) = value.Kiq
"""Get [`GenericDER`](@ref) `Iqr_lim`."""
get_Iqr_lim(value::GenericDER) = value.Iqr_lim
"""Get [`GenericDER`](@ref) `I_max`."""
get_I_max(value::GenericDER) = value.I_max
"""Get [`GenericDER`](@ref) `Tg`."""
get_Tg(value::GenericDER) = value.Tg
"""Get [`GenericDER`](@ref) `kWh_Cap`."""
get_kWh_Cap(value::GenericDER) = value.kWh_Cap
"""Get [`GenericDER`](@ref) `SOC_ini`."""
get_SOC_ini(value::GenericDER) = value.SOC_ini
"""Get [`GenericDER`](@ref) `SOC_lim`."""
get_SOC_lim(value::GenericDER) = value.SOC_lim
"""Get [`GenericDER`](@ref) `Trf`."""
get_Trf(value::GenericDER) = value.Trf
"""Get [`GenericDER`](@ref) `fdbd_pnts`."""
get_fdbd_pnts(value::GenericDER) = value.fdbd_pnts
"""Get [`GenericDER`](@ref) `D_dn`."""
get_D_dn(value::GenericDER) = value.D_dn
"""Get [`GenericDER`](@ref) `D_up`."""
get_D_up(value::GenericDER) = value.D_up
"""Get [`GenericDER`](@ref) `fe_lim`."""
get_fe_lim(value::GenericDER) = value.fe_lim
"""Get [`GenericDER`](@ref) `Kpp`."""
get_Kpp(value::GenericDER) = value.Kpp
"""Get [`GenericDER`](@ref) `Kip`."""
get_Kip(value::GenericDER) = value.Kip
"""Get [`GenericDER`](@ref) `P_lim`."""
get_P_lim(value::GenericDER) = value.P_lim
"""Get [`GenericDER`](@ref) `dP_lim`."""
get_dP_lim(value::GenericDER) = value.dP_lim
"""Get [`GenericDER`](@ref) `T_pord`."""
get_T_pord(value::GenericDER) = value.T_pord
"""Get [`GenericDER`](@ref) `rrpwr`."""
get_rrpwr(value::GenericDER) = value.rrpwr
"""Get [`GenericDER`](@ref) `VRT_pnts`."""
get_VRT_pnts(value::GenericDER) = value.VRT_pnts
"""Get [`GenericDER`](@ref) `TVRT_pnts`."""
get_TVRT_pnts(value::GenericDER) = value.TVRT_pnts
"""Get [`GenericDER`](@ref) `tV_delay`."""
get_tV_delay(value::GenericDER) = value.tV_delay
"""Get [`GenericDER`](@ref) `VES_lim`."""
get_VES_lim(value::GenericDER) = value.VES_lim
"""Get [`GenericDER`](@ref) `FRT_pnts`."""
get_FRT_pnts(value::GenericDER) = value.FRT_pnts
"""Get [`GenericDER`](@ref) `TFRT_pnts`."""
get_TFRT_pnts(value::GenericDER) = value.TFRT_pnts
"""Get [`GenericDER`](@ref) `tF_delay`."""
get_tF_delay(value::GenericDER) = value.tF_delay
"""Get [`GenericDER`](@ref) `FES_lim`."""
get_FES_lim(value::GenericDER) = value.FES_lim
"""Get [`GenericDER`](@ref) `Pfa_ref`."""
get_Pfa_ref(value::GenericDER) = value.Pfa_ref
"""Get [`GenericDER`](@ref) `Q_ref`."""
get_Q_ref(value::GenericDER) = value.Q_ref
"""Get [`GenericDER`](@ref) `P_ref`."""
get_P_ref(value::GenericDER) = value.P_ref

_get_base_power(value::GenericDER) = value.base_power
"""Get [`GenericDER`](@ref) `states`."""
get_states(value::GenericDER) = value.states
"""Get [`GenericDER`](@ref) `n_states`."""
get_n_states(value::GenericDER) = value.n_states
"""Get [`GenericDER`](@ref) `ext`."""
get_ext(value::GenericDER) = value.ext
"""Get [`GenericDER`](@ref) `internal`."""
get_internal(value::GenericDER) = value.internal

"""Set [`GenericDER`](@ref) `Qref_Flag`."""
set_Qref_Flag!(value::GenericDER, val) = value.Qref_Flag = val
"""Set [`GenericDER`](@ref) `PQ_Flag`."""
set_PQ_Flag!(value::GenericDER, val) = value.PQ_Flag = val
"""Set [`GenericDER`](@ref) `Gen_Flag`."""
set_Gen_Flag!(value::GenericDER, val) = value.Gen_Flag = val
"""Set [`GenericDER`](@ref) `PerOp_Flag`."""
set_PerOp_Flag!(value::GenericDER, val) = value.PerOp_Flag = val
"""Set [`GenericDER`](@ref) `Recon_Flag`."""
set_Recon_Flag!(value::GenericDER, val) = value.Recon_Flag = val
"""Set [`GenericDER`](@ref) `Trv`."""
set_Trv!(value::GenericDER, val) = value.Trv = val
"""Set [`GenericDER`](@ref) `VV_pnts`."""
set_VV_pnts!(value::GenericDER, val) = value.VV_pnts = val
"""Set [`GenericDER`](@ref) `Q_lim`."""
set_Q_lim!(value::GenericDER, val) = value.Q_lim = val
"""Set [`GenericDER`](@ref) `Tp`."""
set_Tp!(value::GenericDER, val) = value.Tp = val
"""Set [`GenericDER`](@ref) `e_lim`."""
set_e_lim!(value::GenericDER, val) = value.e_lim = val
"""Set [`GenericDER`](@ref) `Kpq`."""
set_Kpq!(value::GenericDER, val) = value.Kpq = val
"""Set [`GenericDER`](@ref) `Kiq`."""
set_Kiq!(value::GenericDER, val) = value.Kiq = val
"""Set [`GenericDER`](@ref) `Iqr_lim`."""
set_Iqr_lim!(value::GenericDER, val) = value.Iqr_lim = val
"""Set [`GenericDER`](@ref) `I_max`."""
set_I_max!(value::GenericDER, val) = value.I_max = val
"""Set [`GenericDER`](@ref) `Tg`."""
set_Tg!(value::GenericDER, val) = value.Tg = val
"""Set [`GenericDER`](@ref) `kWh_Cap`."""
set_kWh_Cap!(value::GenericDER, val) = value.kWh_Cap = val
"""Set [`GenericDER`](@ref) `SOC_ini`."""
set_SOC_ini!(value::GenericDER, val) = value.SOC_ini = val
"""Set [`GenericDER`](@ref) `SOC_lim`."""
set_SOC_lim!(value::GenericDER, val) = value.SOC_lim = val
"""Set [`GenericDER`](@ref) `Trf`."""
set_Trf!(value::GenericDER, val) = value.Trf = val
"""Set [`GenericDER`](@ref) `fdbd_pnts`."""
set_fdbd_pnts!(value::GenericDER, val) = value.fdbd_pnts = val
"""Set [`GenericDER`](@ref) `D_dn`."""
set_D_dn!(value::GenericDER, val) = value.D_dn = val
"""Set [`GenericDER`](@ref) `D_up`."""
set_D_up!(value::GenericDER, val) = value.D_up = val
"""Set [`GenericDER`](@ref) `fe_lim`."""
set_fe_lim!(value::GenericDER, val) = value.fe_lim = val
"""Set [`GenericDER`](@ref) `Kpp`."""
set_Kpp!(value::GenericDER, val) = value.Kpp = val
"""Set [`GenericDER`](@ref) `Kip`."""
set_Kip!(value::GenericDER, val) = value.Kip = val
"""Set [`GenericDER`](@ref) `P_lim`."""
set_P_lim!(value::GenericDER, val) = value.P_lim = val
"""Set [`GenericDER`](@ref) `dP_lim`."""
set_dP_lim!(value::GenericDER, val) = value.dP_lim = val
"""Set [`GenericDER`](@ref) `T_pord`."""
set_T_pord!(value::GenericDER, val) = value.T_pord = val
"""Set [`GenericDER`](@ref) `rrpwr`."""
set_rrpwr!(value::GenericDER, val) = value.rrpwr = val
"""Set [`GenericDER`](@ref) `VRT_pnts`."""
set_VRT_pnts!(value::GenericDER, val) = value.VRT_pnts = val
"""Set [`GenericDER`](@ref) `TVRT_pnts`."""
set_TVRT_pnts!(value::GenericDER, val) = value.TVRT_pnts = val
"""Set [`GenericDER`](@ref) `tV_delay`."""
set_tV_delay!(value::GenericDER, val) = value.tV_delay = val
"""Set [`GenericDER`](@ref) `VES_lim`."""
set_VES_lim!(value::GenericDER, val) = value.VES_lim = val
"""Set [`GenericDER`](@ref) `FRT_pnts`."""
set_FRT_pnts!(value::GenericDER, val) = value.FRT_pnts = val
"""Set [`GenericDER`](@ref) `TFRT_pnts`."""
set_TFRT_pnts!(value::GenericDER, val) = value.TFRT_pnts = val
"""Set [`GenericDER`](@ref) `tF_delay`."""
set_tF_delay!(value::GenericDER, val) = value.tF_delay = val
"""Set [`GenericDER`](@ref) `FES_lim`."""
set_FES_lim!(value::GenericDER, val) = value.FES_lim = val
"""Set [`GenericDER`](@ref) `Pfa_ref`."""
set_Pfa_ref!(value::GenericDER, val) = value.Pfa_ref = val
"""Set [`GenericDER`](@ref) `Q_ref`."""
set_Q_ref!(value::GenericDER, val) = value.Q_ref = val
"""Set [`GenericDER`](@ref) `P_ref`."""
set_P_ref!(value::GenericDER, val) = value.P_ref = val
"""Set [`GenericDER`](@ref) `ext`."""
set_ext!(value::GenericDER, val) = value.ext = val
