#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct GasTG <: TurbineGov
        R::Float64
        T1::Float64
        T2::Float64
        T3::Float64
        AT::Float64
        Kt::Float64
        V_lim::Tuple{Float64, Float64}
        D_turb::Float64
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.T}
        internal::InfrastructureSystemsInternal
    end

Parameters of Gas Turbine-Governor. GAST in PSSE and GAST_PTI in PowerWorld

# Arguments
- `R::Float64`: Speed droop parameter, validation range: `(eps(), 0.1)`
- `T1::Float64`: Governor time constant in s, validation range: `(eps(), 0.5)`
- `T2::Float64`: Combustion chamber time constant, validation range: `(eps(), 0.5)`
- `T3::Float64`: Load limit time constant (exhaust gas measurement time), validation range: `(eps(), 5)`
- `AT::Float64`: Ambient temperature load limit, validation range: `(0, 1)`
- `Kt::Float64`: Load limit feedback gain, validation range: `(0, 5)`
- `V_lim::Tuple{Float64, Float64}`: Operational control limits on fuel valve opening (V_min, V_max)
- `D_turb::Float64`: Speed damping coefficient of gas turbine rotor, validation range: `(0, 0.5)`
- `P_ref::Float64`: (default: `1.0`) Reference Load Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the GAST model are:
	x_g1: Fuel valve opening,
	x_g2: Fuel flow,
	x_g3: Exhaust temperature load
- `n_states::Int`: (**Do not modify.**) GasTG has 3 states
- `states_types::Vector{StateTypes.T}`: (**Do not modify.**) GAST has 3 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct GasTG <: TurbineGov
    "Speed droop parameter"
    R::Float64
    "Governor time constant in s"
    T1::Float64
    "Combustion chamber time constant"
    T2::Float64
    "Load limit time constant (exhaust gas measurement time)"
    T3::Float64
    "Ambient temperature load limit"
    AT::Float64
    "Load limit feedback gain"
    Kt::Float64
    "Operational control limits on fuel valve opening (V_min, V_max)"
    V_lim::Tuple{Float64, Float64}
    "Speed damping coefficient of gas turbine rotor"
    D_turb::Float64
    "Reference Load Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the GAST model are:
	x_g1: Fuel valve opening,
	x_g2: Fuel flow,
	x_g3: Exhaust temperature load"
    states::Vector{Symbol}
    "(**Do not modify.**) GasTG has 3 states"
    n_states::Int
    "(**Do not modify.**) GAST has 3 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.T}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function GasTG(R, T1, T2, T3, AT, Kt, V_lim, D_turb, P_ref=1.0, ext=Dict{String, Any}(), )
    GasTG(R, T1, T2, T3, AT, Kt, V_lim, D_turb, P_ref, ext, [:x_g1, :x_g2, :x_g3], 3, [StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function GasTG(; R, T1, T2, T3, AT, Kt, V_lim, D_turb, P_ref=1.0, ext=Dict{String, Any}(), states=[:x_g1, :x_g2, :x_g3], n_states=3, states_types=[StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    GasTG(R, T1, T2, T3, AT, Kt, V_lim, D_turb, P_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function GasTG(::Nothing)
    GasTG(;
        R=0,
        T1=0,
        T2=0,
        T3=0,
        AT=0,
        Kt=0,
        V_lim=(0.0, 0.0),
        D_turb=0,
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`GasTG`](@ref) `R`."""
get_R(value::GasTG) = value.R
"""Get [`GasTG`](@ref) `T1`."""
get_T1(value::GasTG) = value.T1
"""Get [`GasTG`](@ref) `T2`."""
get_T2(value::GasTG) = value.T2
"""Get [`GasTG`](@ref) `T3`."""
get_T3(value::GasTG) = value.T3
"""Get [`GasTG`](@ref) `AT`."""
get_AT(value::GasTG) = value.AT
"""Get [`GasTG`](@ref) `Kt`."""
get_Kt(value::GasTG) = value.Kt
"""Get [`GasTG`](@ref) `V_lim`."""
get_V_lim(value::GasTG) = value.V_lim
"""Get [`GasTG`](@ref) `D_turb`."""
get_D_turb(value::GasTG) = value.D_turb
"""Get [`GasTG`](@ref) `P_ref`."""
get_P_ref(value::GasTG) = value.P_ref
"""Get [`GasTG`](@ref) `ext`."""
get_ext(value::GasTG) = value.ext
"""Get [`GasTG`](@ref) `states`."""
get_states(value::GasTG) = value.states
"""Get [`GasTG`](@ref) `n_states`."""
get_n_states(value::GasTG) = value.n_states
"""Get [`GasTG`](@ref) `states_types`."""
get_states_types(value::GasTG) = value.states_types
"""Get [`GasTG`](@ref) `internal`."""
get_internal(value::GasTG) = value.internal

"""Set [`GasTG`](@ref) `R`."""
set_R!(value::GasTG, val) = value.R = val
"""Set [`GasTG`](@ref) `T1`."""
set_T1!(value::GasTG, val) = value.T1 = val
"""Set [`GasTG`](@ref) `T2`."""
set_T2!(value::GasTG, val) = value.T2 = val
"""Set [`GasTG`](@ref) `T3`."""
set_T3!(value::GasTG, val) = value.T3 = val
"""Set [`GasTG`](@ref) `AT`."""
set_AT!(value::GasTG, val) = value.AT = val
"""Set [`GasTG`](@ref) `Kt`."""
set_Kt!(value::GasTG, val) = value.Kt = val
"""Set [`GasTG`](@ref) `V_lim`."""
set_V_lim!(value::GasTG, val) = value.V_lim = val
"""Set [`GasTG`](@ref) `D_turb`."""
set_D_turb!(value::GasTG, val) = value.D_turb = val
"""Set [`GasTG`](@ref) `P_ref`."""
set_P_ref!(value::GasTG, val) = value.P_ref = val
"""Set [`GasTG`](@ref) `ext`."""
set_ext!(value::GasTG, val) = value.ext = val
"""Set [`GasTG`](@ref) `states_types`."""
set_states_types!(value::GasTG, val) = value.states_types = val
