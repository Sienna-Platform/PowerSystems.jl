#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct IEEETurbineGov1 <: TurbineGov
        K::Float64
        T1::Float64
        T2::Float64
        T3::Float64
        U0::Float64
        U_c::Float64
        valve_position_limits::MinMax
        T4::Float64
        K1::Float64
        K2::Float64
        T5::Float64
        K3::Float64
        K4::Float64
        T6::Float64
        K5::Float64
        K6::Float64
        T7::Float64
        K7::Float64
        K8::Float64
        P_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

IEEE Type 1 Speed-Governing Model

# Arguments
- `K::Float64`: Governor Gain, validation range: `(5, 30)`
- `T1::Float64`: Input Filter Lag, validation range: `(0, 5)`
- `T2::Float64`: Input Filter Lead, validation range: `(0, 10)`
- `T3::Float64`: Valve position Time Constant, validation range: `(eps(), 1)`
- `U0::Float64`: Maximum Valve Opening Rate, validation range: `(0.01, 0.03)`
- `U_c::Float64`: Maximum Valve closing rate, validation range: `(-0.3, 0)`
- `valve_position_limits::MinMax`: Valve position limits in MW
- `T4::Float64`: Time Constant inlet steam, validation range: `(0, 1)`
- `K1::Float64`: Fraction of high presure shaft power, validation range: `(-2, 1)`
- `K2::Float64`: Fraction of low presure shaft power, validation range: `(0, nothing)`
- `T5::Float64`: Time constant for second boiler pass, validation range: `(0, 10)`
- `K3::Float64`: Fraction of high presure shaft power second boiler pass, validation range: `(0, 0.5)`
- `K4::Float64`: Fraction of low presure shaft power second boiler pass, validation range: `(0, 0.5)`
- `T6::Float64`: Time constant for third boiler pass, validation range: `(0, 10)`
- `K5::Float64`: Fraction of high presure shaft power third boiler pass, validation range: `(0, 0.35)`
- `K6::Float64`: Fraction of low presure shaft power third boiler pass, validation range: `(0, 0.55)`
- `T7::Float64`: Time constant for fourth boiler pass, validation range: `(0, 10)`
- `K7::Float64`: Fraction of high presure shaft power fourth boiler pass, validation range: `(0, 0.3)`
- `K8::Float64`: Fraction of low presure shaft power fourth boiler pass, validation range: `(0, 0.3)`
- `P_ref::Float64`: (default: `1.0`) Reference Power Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the IEEETurbineGov model are:
	x_g1: First Governor integrator,
	x_g2: Governor output,
	x_g3: First Turbine integrator, 
	x_g4: Second Turbine Integrator, 
	x_g5: Third Turbine Integrator, 
	x_g6: Fourth Turbine Integrator, 
- `n_states::Int`: (**Do not modify.**) IEEEG1 has 6 states
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) IEEEG1 has 6 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct IEEETurbineGov1 <: TurbineGov
    "Governor Gain"
    K::Float64
    "Input Filter Lag"
    T1::Float64
    "Input Filter Lead"
    T2::Float64
    "Valve position Time Constant"
    T3::Float64
    "Maximum Valve Opening Rate"
    U0::Float64
    "Maximum Valve closing rate"
    U_c::Float64
    "Valve position limits in MW"
    valve_position_limits::MinMax
    "Time Constant inlet steam"
    T4::Float64
    "Fraction of high presure shaft power"
    K1::Float64
    "Fraction of low presure shaft power"
    K2::Float64
    "Time constant for second boiler pass"
    T5::Float64
    "Fraction of high presure shaft power second boiler pass"
    K3::Float64
    "Fraction of low presure shaft power second boiler pass"
    K4::Float64
    "Time constant for third boiler pass"
    T6::Float64
    "Fraction of high presure shaft power third boiler pass"
    K5::Float64
    "Fraction of low presure shaft power third boiler pass"
    K6::Float64
    "Time constant for fourth boiler pass"
    T7::Float64
    "Fraction of high presure shaft power fourth boiler pass"
    K7::Float64
    "Fraction of low presure shaft power fourth boiler pass"
    K8::Float64
    "Reference Power Set-point (pu)"
    P_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the IEEETurbineGov model are:
	x_g1: First Governor integrator,
	x_g2: Governor output,
	x_g3: First Turbine integrator, 
	x_g4: Second Turbine Integrator, 
	x_g5: Third Turbine Integrator, 
	x_g6: Fourth Turbine Integrator, "
    states::Vector{Symbol}
    "(**Do not modify.**) IEEEG1 has 6 states"
    n_states::Int
    "(**Do not modify.**) IEEEG1 has 6 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function IEEETurbineGov1(K, T1, T2, T3, U0, U_c, valve_position_limits, T4, K1, K2, T5, K3, K4, T6, K5, K6, T7, K7, K8, P_ref=1.0, ext=Dict{String, Any}(), )
    IEEETurbineGov1(K, T1, T2, T3, U0, U_c, valve_position_limits, T4, K1, K2, T5, K3, K4, T6, K5, K6, T7, K7, K8, P_ref, ext, [:x_g1, :x_g2, :x_g3, :x_g4, :x_g5, :x_g6], 6, [StateTypes.Differential, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], InfrastructureSystemsInternal(), )
end

function IEEETurbineGov1(; K, T1, T2, T3, U0, U_c, valve_position_limits, T4, K1, K2, T5, K3, K4, T6, K5, K6, T7, K7, K8, P_ref=1.0, ext=Dict{String, Any}(), states=[:x_g1, :x_g2, :x_g3, :x_g4, :x_g5, :x_g6], n_states=6, states_types=[StateTypes.Differential, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], internal=InfrastructureSystemsInternal(), )
    IEEETurbineGov1(K, T1, T2, T3, U0, U_c, valve_position_limits, T4, K1, K2, T5, K3, K4, T6, K5, K6, T7, K7, K8, P_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function IEEETurbineGov1(::Nothing)
    IEEETurbineGov1(;
        K=0,
        T1=0,
        T2=0,
        T3=0,
        U0=0,
        U_c=0,
        valve_position_limits=(min=0.0, max=0.0),
        T4=0,
        K1=0,
        K2=0,
        T5=0,
        K3=0,
        K4=0,
        T6=0,
        K5=0,
        K6=0,
        T7=0,
        K7=0,
        K8=0,
        P_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`IEEETurbineGov1`](@ref) `K`."""
get_K(value::IEEETurbineGov1) = value.K
"""Get [`IEEETurbineGov1`](@ref) `T1`."""
get_T1(value::IEEETurbineGov1) = value.T1
"""Get [`IEEETurbineGov1`](@ref) `T2`."""
get_T2(value::IEEETurbineGov1) = value.T2
"""Get [`IEEETurbineGov1`](@ref) `T3`."""
get_T3(value::IEEETurbineGov1) = value.T3
"""Get [`IEEETurbineGov1`](@ref) `U0`."""
get_U0(value::IEEETurbineGov1) = value.U0
"""Get [`IEEETurbineGov1`](@ref) `U_c`."""
get_U_c(value::IEEETurbineGov1) = value.U_c
"""Get [`IEEETurbineGov1`](@ref) `valve_position_limits`."""
get_valve_position_limits(value::IEEETurbineGov1) = value.valve_position_limits
"""Get [`IEEETurbineGov1`](@ref) `T4`."""
get_T4(value::IEEETurbineGov1) = value.T4
"""Get [`IEEETurbineGov1`](@ref) `K1`."""
get_K1(value::IEEETurbineGov1) = value.K1
"""Get [`IEEETurbineGov1`](@ref) `K2`."""
get_K2(value::IEEETurbineGov1) = value.K2
"""Get [`IEEETurbineGov1`](@ref) `T5`."""
get_T5(value::IEEETurbineGov1) = value.T5
"""Get [`IEEETurbineGov1`](@ref) `K3`."""
get_K3(value::IEEETurbineGov1) = value.K3
"""Get [`IEEETurbineGov1`](@ref) `K4`."""
get_K4(value::IEEETurbineGov1) = value.K4
"""Get [`IEEETurbineGov1`](@ref) `T6`."""
get_T6(value::IEEETurbineGov1) = value.T6
"""Get [`IEEETurbineGov1`](@ref) `K5`."""
get_K5(value::IEEETurbineGov1) = value.K5
"""Get [`IEEETurbineGov1`](@ref) `K6`."""
get_K6(value::IEEETurbineGov1) = value.K6
"""Get [`IEEETurbineGov1`](@ref) `T7`."""
get_T7(value::IEEETurbineGov1) = value.T7
"""Get [`IEEETurbineGov1`](@ref) `K7`."""
get_K7(value::IEEETurbineGov1) = value.K7
"""Get [`IEEETurbineGov1`](@ref) `K8`."""
get_K8(value::IEEETurbineGov1) = value.K8
"""Get [`IEEETurbineGov1`](@ref) `P_ref`."""
get_P_ref(value::IEEETurbineGov1) = value.P_ref
"""Get [`IEEETurbineGov1`](@ref) `ext`."""
get_ext(value::IEEETurbineGov1) = value.ext
"""Get [`IEEETurbineGov1`](@ref) `states`."""
get_states(value::IEEETurbineGov1) = value.states
"""Get [`IEEETurbineGov1`](@ref) `n_states`."""
get_n_states(value::IEEETurbineGov1) = value.n_states
"""Get [`IEEETurbineGov1`](@ref) `states_types`."""
get_states_types(value::IEEETurbineGov1) = value.states_types
"""Get [`IEEETurbineGov1`](@ref) `internal`."""
get_internal(value::IEEETurbineGov1) = value.internal

"""Set [`IEEETurbineGov1`](@ref) `K`."""
set_K!(value::IEEETurbineGov1, val) = value.K = val
"""Set [`IEEETurbineGov1`](@ref) `T1`."""
set_T1!(value::IEEETurbineGov1, val) = value.T1 = val
"""Set [`IEEETurbineGov1`](@ref) `T2`."""
set_T2!(value::IEEETurbineGov1, val) = value.T2 = val
"""Set [`IEEETurbineGov1`](@ref) `T3`."""
set_T3!(value::IEEETurbineGov1, val) = value.T3 = val
"""Set [`IEEETurbineGov1`](@ref) `U0`."""
set_U0!(value::IEEETurbineGov1, val) = value.U0 = val
"""Set [`IEEETurbineGov1`](@ref) `U_c`."""
set_U_c!(value::IEEETurbineGov1, val) = value.U_c = val
"""Set [`IEEETurbineGov1`](@ref) `valve_position_limits`."""
set_valve_position_limits!(value::IEEETurbineGov1, val) = value.valve_position_limits = val
"""Set [`IEEETurbineGov1`](@ref) `T4`."""
set_T4!(value::IEEETurbineGov1, val) = value.T4 = val
"""Set [`IEEETurbineGov1`](@ref) `K1`."""
set_K1!(value::IEEETurbineGov1, val) = value.K1 = val
"""Set [`IEEETurbineGov1`](@ref) `K2`."""
set_K2!(value::IEEETurbineGov1, val) = value.K2 = val
"""Set [`IEEETurbineGov1`](@ref) `T5`."""
set_T5!(value::IEEETurbineGov1, val) = value.T5 = val
"""Set [`IEEETurbineGov1`](@ref) `K3`."""
set_K3!(value::IEEETurbineGov1, val) = value.K3 = val
"""Set [`IEEETurbineGov1`](@ref) `K4`."""
set_K4!(value::IEEETurbineGov1, val) = value.K4 = val
"""Set [`IEEETurbineGov1`](@ref) `T6`."""
set_T6!(value::IEEETurbineGov1, val) = value.T6 = val
"""Set [`IEEETurbineGov1`](@ref) `K5`."""
set_K5!(value::IEEETurbineGov1, val) = value.K5 = val
"""Set [`IEEETurbineGov1`](@ref) `K6`."""
set_K6!(value::IEEETurbineGov1, val) = value.K6 = val
"""Set [`IEEETurbineGov1`](@ref) `T7`."""
set_T7!(value::IEEETurbineGov1, val) = value.T7 = val
"""Set [`IEEETurbineGov1`](@ref) `K7`."""
set_K7!(value::IEEETurbineGov1, val) = value.K7 = val
"""Set [`IEEETurbineGov1`](@ref) `K8`."""
set_K8!(value::IEEETurbineGov1, val) = value.K8 = val
"""Set [`IEEETurbineGov1`](@ref) `P_ref`."""
set_P_ref!(value::IEEETurbineGov1, val) = value.P_ref = val
"""Set [`IEEETurbineGov1`](@ref) `ext`."""
set_ext!(value::IEEETurbineGov1, val) = value.ext = val
"""Set [`IEEETurbineGov1`](@ref) `states_types`."""
set_states_types!(value::IEEETurbineGov1, val) = value.states_types = val
