#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct DEGOV1 <: TurbineGovernorDynamics
        droop_flag::Int
        T1::Float64
        T2::Float64
        T3::Float64
        K::Float64
        T4::Float64
        T5::Float64
        T6::Float64
        Td::Float64
        T_lim::Tuple{Float64, Float64}
        R::Float64
        Te::Float64
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters Woodward Diesel Governor Model. DEGOV1 in PSSE

# Arguments
- `droop_flag::Int`: Droop control Flag. 0 for throttle feedback and 1 for electric power feedback, validation range: `(0, 1)`
- `T1::Float64`: Governor mechanism time constant in s, validation range: `(0, 100.0)`
- `T2::Float64`: Turbine power time constant in s, validation range: `(0, 100.0)`
- `T3::Float64`: Turbine exhaust temperature time constant in s, validation range: `(0, 100.0)`
- `K::Float64`: Governor gain for actuator, validation range: `(0, 100.0)`
- `T4::Float64`: Governor lead time constant in s, validation range: `(0, 100.0)`
- `T5::Float64`: Governor lag time constant in s, validation range: `(0, 100.0)`
- `T6::Float64`: Actuator time constant in s, validation range: `(0, 100.0)`
- `Td::Float64`: Engine time delay in s, validation range: `(0, 100.0)`
- `T_lim::Tuple{Float64, Float64}`: Operational control limits on actuator (T_min, T_max)
- `R::Float64`: Steady state droop parameter, validation range: `(0, 100.0)`
- `Te::Float64`: Power transducer time constant in s, validation range: `(0, 100.0)`
- `P_ref::Float64`: (default: `1.0`) Reference Load Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the DEGOV1 model depends on the droop flag
- `n_states::Int`: (**Do not modify.**) The number of [states](@ref S) of the DEGOV1 model depends on the droop flag
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct DEGOV1 <: TurbineGovernorDynamics
    "Droop control Flag. 0 for throttle feedback and 1 for electric power feedback"
    droop_flag::Int
    "Governor mechanism time constant in s"
    T1::Float64
    "Turbine power time constant in s"
    T2::Float64
    "Turbine exhaust temperature time constant in s"
    T3::Float64
    "Governor gain for actuator"
    K::Float64
    "Governor lead time constant in s"
    T4::Float64
    "Governor lag time constant in s"
    T5::Float64
    "Actuator time constant in s"
    T6::Float64
    "Engine time delay in s"
    Td::Float64
    "Operational control limits on actuator (T_min, T_max)"
    T_lim::Tuple{Float64, Float64}
    "Steady state droop parameter"
    R::Float64
    "Power transducer time constant in s"
    Te::Float64
    "Reference Load Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the DEGOV1 model depends on the droop flag"
    states::Vector{Symbol}
    "(**Do not modify.**) The number of [states](@ref S) of the DEGOV1 model depends on the droop flag"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function DEGOV1(droop_flag, T1, T2, T3, K, T4, T5, T6, Td, T_lim, R, Te, P_ref=1.0, ext=Dict{String, Any}(), )
    DEGOV1(droop_flag, T1, T2, T3, K, T4, T5, T6, Td, T_lim, R, Te, P_ref, ext, PowerSystems.get_degov1_states(droop_flag)[1], PowerSystems.get_degov1_states(droop_flag)[2], InfrastructureSystemsInternal(), )
end

function DEGOV1(; droop_flag, T1, T2, T3, K, T4, T5, T6, Td, T_lim, R, Te, P_ref=1.0, ext=Dict{String, Any}(), states=PowerSystems.get_degov1_states(droop_flag)[1], n_states=PowerSystems.get_degov1_states(droop_flag)[2], internal=InfrastructureSystemsInternal(), )
    DEGOV1(droop_flag, T1, T2, T3, K, T4, T5, T6, Td, T_lim, R, Te, P_ref, ext, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function DEGOV1(::Nothing)
    DEGOV1(;
        droop_flag=0,
        T1=0,
        T2=0,
        T3=0,
        K=0,
        T4=0,
        T5=0,
        T6=0,
        Td=0,
        T_lim=(0.0, 0.0),
        R=0,
        Te=0,
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`DEGOV1`](@ref) `droop_flag`."""
get_droop_flag(value::DEGOV1) = value.droop_flag
"""Get [`DEGOV1`](@ref) `T1`."""
get_T1(value::DEGOV1) = value.T1
"""Get [`DEGOV1`](@ref) `T2`."""
get_T2(value::DEGOV1) = value.T2
"""Get [`DEGOV1`](@ref) `T3`."""
get_T3(value::DEGOV1) = value.T3
"""Get [`DEGOV1`](@ref) `K`."""
get_K(value::DEGOV1) = value.K
"""Get [`DEGOV1`](@ref) `T4`."""
get_T4(value::DEGOV1) = value.T4
"""Get [`DEGOV1`](@ref) `T5`."""
get_T5(value::DEGOV1) = value.T5
"""Get [`DEGOV1`](@ref) `T6`."""
get_T6(value::DEGOV1) = value.T6
"""Get [`DEGOV1`](@ref) `Td`."""
get_Td(value::DEGOV1) = value.Td
"""Get [`DEGOV1`](@ref) `T_lim`."""
get_T_lim(value::DEGOV1) = value.T_lim
"""Get [`DEGOV1`](@ref) `R`."""
get_R(value::DEGOV1) = value.R
"""Get [`DEGOV1`](@ref) `Te`."""
get_Te(value::DEGOV1) = value.Te
"""Get [`DEGOV1`](@ref) `P_ref`."""
get_P_ref(value::DEGOV1) = value.P_ref
"""Get [`DEGOV1`](@ref) `ext`."""
get_ext(value::DEGOV1) = value.ext
"""Get [`DEGOV1`](@ref) `states`."""
get_states(value::DEGOV1) = value.states
"""Get [`DEGOV1`](@ref) `n_states`."""
get_n_states(value::DEGOV1) = value.n_states
"""Get [`DEGOV1`](@ref) `internal`."""
get_internal(value::DEGOV1) = value.internal

"""Set [`DEGOV1`](@ref) `droop_flag`."""
set_droop_flag!(value::DEGOV1, val) = value.droop_flag = val
"""Set [`DEGOV1`](@ref) `T1`."""
set_T1!(value::DEGOV1, val) = value.T1 = val
"""Set [`DEGOV1`](@ref) `T2`."""
set_T2!(value::DEGOV1, val) = value.T2 = val
"""Set [`DEGOV1`](@ref) `T3`."""
set_T3!(value::DEGOV1, val) = value.T3 = val
"""Set [`DEGOV1`](@ref) `K`."""
set_K!(value::DEGOV1, val) = value.K = val
"""Set [`DEGOV1`](@ref) `T4`."""
set_T4!(value::DEGOV1, val) = value.T4 = val
"""Set [`DEGOV1`](@ref) `T5`."""
set_T5!(value::DEGOV1, val) = value.T5 = val
"""Set [`DEGOV1`](@ref) `T6`."""
set_T6!(value::DEGOV1, val) = value.T6 = val
"""Set [`DEGOV1`](@ref) `Td`."""
set_Td!(value::DEGOV1, val) = value.Td = val
"""Set [`DEGOV1`](@ref) `T_lim`."""
set_T_lim!(value::DEGOV1, val) = value.T_lim = val
"""Set [`DEGOV1`](@ref) `R`."""
set_R!(value::DEGOV1, val) = value.R = val
"""Set [`DEGOV1`](@ref) `Te`."""
set_Te!(value::DEGOV1, val) = value.Te = val
"""Set [`DEGOV1`](@ref) `P_ref`."""
set_P_ref!(value::DEGOV1, val) = value.P_ref = val
"""Set [`DEGOV1`](@ref) `ext`."""
set_ext!(value::DEGOV1, val) = value.ext = val



function from_openapi(po::PD.DEGOV1, refs::OpenAPIRefs)
    return DEGOV1(;
        droop_flag = _wire_required(po.droop_flag, "DEGOV1", "droop_flag"),
        T1 = _wire_required(po.t1, "DEGOV1", "T1"),
        T2 = _wire_required(po.t2, "DEGOV1", "T2"),
        T3 = _wire_required(po.t3, "DEGOV1", "T3"),
        K = _wire_required(po.k, "DEGOV1", "K"),
        T4 = _wire_required(po.t4, "DEGOV1", "T4"),
        T5 = _wire_required(po.t5, "DEGOV1", "T5"),
        T6 = _wire_required(po.t6, "DEGOV1", "T6"),
        Td = _wire_required(po.td, "DEGOV1", "Td"),
        T_lim = _wire_to_psy(Tuple{Float64, Float64}, po.t_lim),
        R = _wire_required(po.r, "DEGOV1", "R"),
        Te = _wire_required(po.te, "DEGOV1", "Te"),
        P_ref = _or_default(po.p_ref, 1.0),
    )
end

function to_openapi(value::DEGOV1, refs::OpenAPIRefs)
    return PD.DEGOV1(;
        id = component_id(refs, value),
        droop_flag = get_droop_flag(value),
        t1 = get_T1(value),
        t2 = get_T2(value),
        t3 = get_T3(value),
        k = get_K(value),
        t4 = get_T4(value),
        t5 = get_T5(value),
        t6 = get_T6(value),
        td = get_Td(value),
        t_lim = _psy_to_wire(get_T_lim(value)),
        r = get_R(value),
        te = get_Te(value),
        p_ref = get_P_ref(value),
    )
end
