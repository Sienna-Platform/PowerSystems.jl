#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct HydroTurbineGov <: TurbineGovernorDynamics
        R_BIG::Float64
        R_SMALL::Float64
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
- `R_BIG::Float64`: Permanent droop, in pu., validation range: `(0, 0.1)`
- `R_SMALL::Float64`: Temporary droop, in pu., validation range: `(0, 2)`
- `Tr::Float64`: Governor time constant, validation range: `(0.0001, 30)`
- `Tf::Float64`: Filter Time constant, validation range: `(0.0001, 0.1)`
- `Tg::Float64`: Servo time constant, validation range: `(0.0001, 1)`
- `VELM::Float64`: gate velocity limit, validation range: `(0.0001, 0.3)`
- `gate_position_limits::MinMax`: Gate position limits
- `Tw::Float64`: water time constant, validation range: `(0.0001, 3)`
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
mutable struct HydroTurbineGov <: TurbineGovernorDynamics
    "Permanent droop, in pu."
    R_BIG::Float64
    "Temporary droop, in pu."
    R_SMALL::Float64
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

function HydroTurbineGov(R_BIG, R_SMALL, Tr, Tf, Tg, VELM, gate_position_limits, Tw, At, D_T, q_nl, P_ref=1.0, ext=Dict{String, Any}(), )
    HydroTurbineGov(R_BIG, R_SMALL, Tr, Tf, Tg, VELM, gate_position_limits, Tw, At, D_T, q_nl, P_ref, ext, [:x_g1, :x_g2, :x_g3, :x_g4], 4, [StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function HydroTurbineGov(; R_BIG, R_SMALL, Tr, Tf, Tg, VELM, gate_position_limits, Tw, At, D_T, q_nl, P_ref=1.0, ext=Dict{String, Any}(), states=[:x_g1, :x_g2, :x_g3, :x_g4], n_states=4, states_types=[StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    HydroTurbineGov(R_BIG, R_SMALL, Tr, Tf, Tg, VELM, gate_position_limits, Tw, At, D_T, q_nl, P_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function HydroTurbineGov(::Nothing)
    HydroTurbineGov(;
        R_BIG=0,
        R_SMALL=0,
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

"""Get [`HydroTurbineGov`](@ref) `R_BIG`."""
get_R_BIG(value::HydroTurbineGov) = value.R_BIG
"""Get [`HydroTurbineGov`](@ref) `R_SMALL`."""
get_R_SMALL(value::HydroTurbineGov) = value.R_SMALL
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

"""Set [`HydroTurbineGov`](@ref) `R_BIG`."""
set_R_BIG!(value::HydroTurbineGov, val) = value.R_BIG = val
"""Set [`HydroTurbineGov`](@ref) `R_SMALL`."""
set_R_SMALL!(value::HydroTurbineGov, val) = value.R_SMALL = val
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



function from_openapi(po::PD.HydroTurbineGov, refs::OpenAPIRefs)
    return HydroTurbineGov(;
        R_BIG = _wire_required(po.r_big, "HydroTurbineGov", "R_BIG"),
        R_SMALL = _wire_required(po.r_small, "HydroTurbineGov", "R_SMALL"),
        Tr = _wire_required(po.tr, "HydroTurbineGov", "Tr"),
        Tf = _wire_required(po.tf, "HydroTurbineGov", "Tf"),
        Tg = _wire_required(po.tg, "HydroTurbineGov", "Tg"),
        VELM = _wire_required(po.velm, "HydroTurbineGov", "VELM"),
        gate_position_limits = _or_default(po.gate_position_limits, nothing),
        Tw = _wire_required(po.tw, "HydroTurbineGov", "Tw"),
        At = _wire_required(po.at, "HydroTurbineGov", "At"),
        D_T = _wire_required(po.d_t, "HydroTurbineGov", "D_T"),
        q_nl = _wire_required(po.q_nl, "HydroTurbineGov", "q_nl"),
        P_ref = _or_default(po.p_ref, 1.0),
    )
end

function to_openapi(value::HydroTurbineGov, refs::OpenAPIRefs)
    return PD.HydroTurbineGov(;
        id = component_id(refs, value),
        r_big = get_R_BIG(value),
        r_small = get_R_SMALL(value),
        tr = get_Tr(value),
        tf = get_Tf(value),
        tg = get_Tg(value),
        velm = get_VELM(value),
        gate_position_limits = _minmax_po(get_gate_position_limits(value)),
        tw = get_Tw(value),
        at = get_At(value),
        d_t = get_D_T(value),
        q_nl = get_q_nl(value),
        p_ref = get_P_ref(value),
    )
end
