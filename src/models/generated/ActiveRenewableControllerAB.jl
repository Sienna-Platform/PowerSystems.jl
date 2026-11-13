#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ActiveRenewableControllerAB <: ActivePowerControl
        bus_control::Int
        from_branch_control::Int
        to_branch_control::Int
        branch_id_control::Int
        Freq_Flag::Bool
        K_pg::Float64
        K_ig::Float64
        T_p::Float64
        fdbd_pnts::Tuple{Float64, Float64}
        fe_lim::MinMax
        P_lim::MinMax
        T_g::Float64
        D_dn::Float64
        D_up::Float64
        dP_lim::MinMax
        P_lim_inner::MinMax
        T_pord::Float64
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of Active Power Controller including REPCA1 and REECB1

# Arguments
- `bus_control::Int`: ACBus identification [`number`](@ref ACBus) for voltage control. `0` identifies the local bus connected to this component, validation range: `(0, nothing)`
- `from_branch_control::Int`: Monitored branch FROM bus number for line drop compensation (if 0 generator power will be used), validation range: `(0, nothing)`
- `to_branch_control::Int`: Monitored branch TO bus number for line drop compensation (if 0 generator power will be used), validation range: `(0, nothing)`
- `branch_id_control::Int`: Branch circuit id for line drop compensation. If 0, the generator power is used.
- `Freq_Flag::Bool`: Frequency Flag for REPCA1: `false`: disable, `true`: enable
- `K_pg::Float64`: Active power PI control proportional gain, validation range: `(0, nothing)`
- `K_ig::Float64`: Active power PI control integral gain, validation range: `(0, nothing)`
- `T_p::Float64`: Real power measurement filter time constant (s), validation range: `(0, nothing)`
- `fdbd_pnts::Tuple{Float64, Float64}`: Frequency error dead band thresholds `(fdbd1, fdbd2)`
- `fe_lim::MinMax`: Upper/Lower limit on frequency error `(fe_min, fe_max)`
- `P_lim::MinMax`: Upper/Lower limit on power reference `(P_min, P_max)`
- `T_g::Float64`: Power Controller lag time constant, validation range: `(0, nothing)`
- `D_dn::Float64`: Droop for over-frequency conditions, validation range: `(nothing, 0)`
- `D_up::Float64`: Droop for under-frequency conditions, validation range: `(0, nothing)`
- `dP_lim::MinMax`: Upper/Lower limit on power reference ramp rates`(dP_min, dP_max)`
- `P_lim_inner::MinMax`: Upper/Lower limit on power reference for REECB`(P_min_inner, P_max_inner)`
- `T_pord::Float64`: Power filter time constant REECB time constant, validation range: `(0, nothing)`
- `P_ref::Float64`: (default: `1.0`) Reference Power Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the ActiveRenewableControllerAB model depends on the Flag
- `n_states::Int`: (**Do not modify.**) The states of the ActiveRenewableControllerAB model depends on the Flag
"""
mutable struct ActiveRenewableControllerAB <: ActivePowerControl
    "ACBus identification [`number`](@ref ACBus) for voltage control. `0` identifies the local bus connected to this component"
    bus_control::Int
    "Monitored branch FROM bus number for line drop compensation (if 0 generator power will be used)"
    from_branch_control::Int
    "Monitored branch TO bus number for line drop compensation (if 0 generator power will be used)"
    to_branch_control::Int
    "Branch circuit id for line drop compensation. If 0, the generator power is used."
    branch_id_control::Int
    "Frequency Flag for REPCA1: `false`: disable, `true`: enable"
    Freq_Flag::Bool
    "Active power PI control proportional gain"
    K_pg::Float64
    "Active power PI control integral gain"
    K_ig::Float64
    "Real power measurement filter time constant (s)"
    T_p::Float64
    "Frequency error dead band thresholds `(fdbd1, fdbd2)`"
    fdbd_pnts::Tuple{Float64, Float64}
    "Upper/Lower limit on frequency error `(fe_min, fe_max)`"
    fe_lim::MinMax
    "Upper/Lower limit on power reference `(P_min, P_max)`"
    P_lim::MinMax
    "Power Controller lag time constant"
    T_g::Float64
    "Droop for over-frequency conditions"
    D_dn::Float64
    "Droop for under-frequency conditions"
    D_up::Float64
    "Upper/Lower limit on power reference ramp rates`(dP_min, dP_max)`"
    dP_lim::MinMax
    "Upper/Lower limit on power reference for REECB`(P_min_inner, P_max_inner)`"
    P_lim_inner::MinMax
    "Power filter time constant REECB time constant"
    T_pord::Float64
    "Reference Power Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the ActiveRenewableControllerAB model depends on the Flag"
    states::Vector{Symbol}
    "(**Do not modify.**) The states of the ActiveRenewableControllerAB model depends on the Flag"
    n_states::Int
end

function ActiveRenewableControllerAB(bus_control, from_branch_control, to_branch_control, branch_id_control, Freq_Flag, K_pg, K_ig, T_p, fdbd_pnts, fe_lim, P_lim, T_g, D_dn, D_up, dP_lim, P_lim_inner, T_pord, P_ref=1.0, ext=Dict{String, Any}(), )
    ActiveRenewableControllerAB(bus_control, from_branch_control, to_branch_control, branch_id_control, Freq_Flag, K_pg, K_ig, T_p, fdbd_pnts, fe_lim, P_lim, T_g, D_dn, D_up, dP_lim, P_lim_inner, T_pord, P_ref, ext, PowerSystems.get_activeRETypeAB_states(Freq_Flag)[1], PowerSystems.get_activeRETypeAB_states(Freq_Flag)[2], )
end

function ActiveRenewableControllerAB(; bus_control, from_branch_control, to_branch_control, branch_id_control, Freq_Flag, K_pg, K_ig, T_p, fdbd_pnts, fe_lim, P_lim, T_g, D_dn, D_up, dP_lim, P_lim_inner, T_pord, P_ref=1.0, ext=Dict{String, Any}(), states=PowerSystems.get_activeRETypeAB_states(Freq_Flag)[1], n_states=PowerSystems.get_activeRETypeAB_states(Freq_Flag)[2], )
    ActiveRenewableControllerAB(bus_control, from_branch_control, to_branch_control, branch_id_control, Freq_Flag, K_pg, K_ig, T_p, fdbd_pnts, fe_lim, P_lim, T_g, D_dn, D_up, dP_lim, P_lim_inner, T_pord, P_ref, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function ActiveRenewableControllerAB(::Nothing)
    ActiveRenewableControllerAB(;
        bus_control=0,
        from_branch_control=0,
        to_branch_control=0,
        branch_id_control=0,
        Freq_Flag=false,
        K_pg=0,
        K_ig=0,
        T_p=0,
        fdbd_pnts=(0.0, 0.0),
        fe_lim=(min=0.0, max=0.0),
        P_lim=(min=0.0, max=0.0),
        T_g=0,
        D_dn=0,
        D_up=0,
        dP_lim=(min=0.0, max=0.0),
        P_lim_inner=(min=0.0, max=0.0),
        T_pord=0,
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ActiveRenewableControllerAB`](@ref) `bus_control`."""
get_bus_control(value::ActiveRenewableControllerAB) = value.bus_control
"""Get [`ActiveRenewableControllerAB`](@ref) `from_branch_control`."""
get_from_branch_control(value::ActiveRenewableControllerAB) = value.from_branch_control
"""Get [`ActiveRenewableControllerAB`](@ref) `to_branch_control`."""
get_to_branch_control(value::ActiveRenewableControllerAB) = value.to_branch_control
"""Get [`ActiveRenewableControllerAB`](@ref) `branch_id_control`."""
get_branch_id_control(value::ActiveRenewableControllerAB) = value.branch_id_control
"""Get [`ActiveRenewableControllerAB`](@ref) `Freq_Flag`."""
get_Freq_Flag(value::ActiveRenewableControllerAB) = value.Freq_Flag
"""Get [`ActiveRenewableControllerAB`](@ref) `K_pg`."""
get_K_pg(value::ActiveRenewableControllerAB) = value.K_pg
"""Get [`ActiveRenewableControllerAB`](@ref) `K_ig`."""
get_K_ig(value::ActiveRenewableControllerAB) = value.K_ig
"""Get [`ActiveRenewableControllerAB`](@ref) `T_p`."""
get_T_p(value::ActiveRenewableControllerAB) = value.T_p
"""Get [`ActiveRenewableControllerAB`](@ref) `fdbd_pnts`."""
get_fdbd_pnts(value::ActiveRenewableControllerAB) = value.fdbd_pnts
"""Get [`ActiveRenewableControllerAB`](@ref) `fe_lim`."""
get_fe_lim(value::ActiveRenewableControllerAB) = value.fe_lim
"""Get [`ActiveRenewableControllerAB`](@ref) `P_lim`."""
get_P_lim(value::ActiveRenewableControllerAB) = value.P_lim
"""Get [`ActiveRenewableControllerAB`](@ref) `T_g`."""
get_T_g(value::ActiveRenewableControllerAB) = value.T_g
"""Get [`ActiveRenewableControllerAB`](@ref) `D_dn`."""
get_D_dn(value::ActiveRenewableControllerAB) = value.D_dn
"""Get [`ActiveRenewableControllerAB`](@ref) `D_up`."""
get_D_up(value::ActiveRenewableControllerAB) = value.D_up
"""Get [`ActiveRenewableControllerAB`](@ref) `dP_lim`."""
get_dP_lim(value::ActiveRenewableControllerAB) = value.dP_lim
"""Get [`ActiveRenewableControllerAB`](@ref) `P_lim_inner`."""
get_P_lim_inner(value::ActiveRenewableControllerAB) = value.P_lim_inner
"""Get [`ActiveRenewableControllerAB`](@ref) `T_pord`."""
get_T_pord(value::ActiveRenewableControllerAB) = value.T_pord
"""Get [`ActiveRenewableControllerAB`](@ref) `P_ref`."""
get_P_ref(value::ActiveRenewableControllerAB) = value.P_ref
"""Get [`ActiveRenewableControllerAB`](@ref) `ext`."""
get_ext(value::ActiveRenewableControllerAB) = value.ext
"""Get [`ActiveRenewableControllerAB`](@ref) `states`."""
get_states(value::ActiveRenewableControllerAB) = value.states
"""Get [`ActiveRenewableControllerAB`](@ref) `n_states`."""
get_n_states(value::ActiveRenewableControllerAB) = value.n_states

"""Set [`ActiveRenewableControllerAB`](@ref) `bus_control`."""
set_bus_control!(value::ActiveRenewableControllerAB, val) = value.bus_control = val
"""Set [`ActiveRenewableControllerAB`](@ref) `from_branch_control`."""
set_from_branch_control!(value::ActiveRenewableControllerAB, val) = value.from_branch_control = val
"""Set [`ActiveRenewableControllerAB`](@ref) `to_branch_control`."""
set_to_branch_control!(value::ActiveRenewableControllerAB, val) = value.to_branch_control = val
"""Set [`ActiveRenewableControllerAB`](@ref) `branch_id_control`."""
set_branch_id_control!(value::ActiveRenewableControllerAB, val) = value.branch_id_control = val
"""Set [`ActiveRenewableControllerAB`](@ref) `Freq_Flag`."""
set_Freq_Flag!(value::ActiveRenewableControllerAB, val) = value.Freq_Flag = val
"""Set [`ActiveRenewableControllerAB`](@ref) `K_pg`."""
set_K_pg!(value::ActiveRenewableControllerAB, val) = value.K_pg = val
"""Set [`ActiveRenewableControllerAB`](@ref) `K_ig`."""
set_K_ig!(value::ActiveRenewableControllerAB, val) = value.K_ig = val
"""Set [`ActiveRenewableControllerAB`](@ref) `T_p`."""
set_T_p!(value::ActiveRenewableControllerAB, val) = value.T_p = val
"""Set [`ActiveRenewableControllerAB`](@ref) `fdbd_pnts`."""
set_fdbd_pnts!(value::ActiveRenewableControllerAB, val) = value.fdbd_pnts = val
"""Set [`ActiveRenewableControllerAB`](@ref) `fe_lim`."""
set_fe_lim!(value::ActiveRenewableControllerAB, val) = value.fe_lim = val
"""Set [`ActiveRenewableControllerAB`](@ref) `P_lim`."""
set_P_lim!(value::ActiveRenewableControllerAB, val) = value.P_lim = val
"""Set [`ActiveRenewableControllerAB`](@ref) `T_g`."""
set_T_g!(value::ActiveRenewableControllerAB, val) = value.T_g = val
"""Set [`ActiveRenewableControllerAB`](@ref) `D_dn`."""
set_D_dn!(value::ActiveRenewableControllerAB, val) = value.D_dn = val
"""Set [`ActiveRenewableControllerAB`](@ref) `D_up`."""
set_D_up!(value::ActiveRenewableControllerAB, val) = value.D_up = val
"""Set [`ActiveRenewableControllerAB`](@ref) `dP_lim`."""
set_dP_lim!(value::ActiveRenewableControllerAB, val) = value.dP_lim = val
"""Set [`ActiveRenewableControllerAB`](@ref) `P_lim_inner`."""
set_P_lim_inner!(value::ActiveRenewableControllerAB, val) = value.P_lim_inner = val
"""Set [`ActiveRenewableControllerAB`](@ref) `T_pord`."""
set_T_pord!(value::ActiveRenewableControllerAB, val) = value.T_pord = val
"""Set [`ActiveRenewableControllerAB`](@ref) `P_ref`."""
set_P_ref!(value::ActiveRenewableControllerAB, val) = value.P_ref = val
"""Set [`ActiveRenewableControllerAB`](@ref) `ext`."""
set_ext!(value::ActiveRenewableControllerAB, val) = value.ext = val



function from_openapi(po::PD.ActiveRenewableControllerAB, refs::OpenAPIRefs)
    return ActiveRenewableControllerAB(;
        bus_control = _wire_required(po.bus_control, "ActiveRenewableControllerAB", "bus_control"),
        from_branch_control = _wire_required(po.from_branch_control, "ActiveRenewableControllerAB", "from_branch_control"),
        to_branch_control = _wire_required(po.to_branch_control, "ActiveRenewableControllerAB", "to_branch_control"),
        branch_id_control = _wire_required(po.branch_id_control, "ActiveRenewableControllerAB", "branch_id_control"),
        Freq_Flag = _wire_required(po.freq_flag, "ActiveRenewableControllerAB", "Freq_Flag"),
        K_pg = _wire_required(po.k_pg, "ActiveRenewableControllerAB", "K_pg"),
        K_ig = _wire_required(po.k_ig, "ActiveRenewableControllerAB", "K_ig"),
        T_p = _wire_required(po.t_p, "ActiveRenewableControllerAB", "T_p"),
        fdbd_pnts = _wire_to_psy(Tuple{Float64, Float64}, po.fdbd_pnts),
        fe_lim = _or_default(po.fe_lim, nothing),
        P_lim = _or_default(po.p_lim, nothing),
        T_g = _wire_required(po.t_g, "ActiveRenewableControllerAB", "T_g"),
        D_dn = _wire_required(po.d_dn, "ActiveRenewableControllerAB", "D_dn"),
        D_up = _wire_required(po.d_up, "ActiveRenewableControllerAB", "D_up"),
        dP_lim = _or_default(po.dp_lim, nothing),
        P_lim_inner = _or_default(po.p_lim_inner, nothing),
        T_pord = _wire_required(po.t_pord, "ActiveRenewableControllerAB", "T_pord"),
        P_ref = _or_default(po.p_ref, 1.0),
    )
end

function to_openapi(value::ActiveRenewableControllerAB, refs::OpenAPIRefs)
    return PD.ActiveRenewableControllerAB(;
        id = component_id(refs, value),
        bus_control = get_bus_control(value),
        from_branch_control = get_from_branch_control(value),
        to_branch_control = get_to_branch_control(value),
        branch_id_control = get_branch_id_control(value),
        freq_flag = get_Freq_Flag(value),
        k_pg = get_K_pg(value),
        k_ig = get_K_ig(value),
        t_p = get_T_p(value),
        fdbd_pnts = _psy_to_wire(PC.FdbdPnts, get_fdbd_pnts(value)),
        fe_lim = _minmax_po(get_fe_lim(value)),
        p_lim = _minmax_po(get_P_lim(value)),
        t_g = get_T_g(value),
        d_dn = get_D_dn(value),
        d_up = get_D_up(value),
        dp_lim = _minmax_po(get_dP_lim(value)),
        p_lim_inner = _minmax_po(get_P_lim_inner(value)),
        t_pord = get_T_pord(value),
        p_ref = get_P_ref(value),
    )
end
