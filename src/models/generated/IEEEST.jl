#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct IEEEST <: PSS
        input_code::Int
        remote_bus_control::Int
        A1::Float64
        A2::Float64
        A3::Float64
        A4::Float64
        A5::Float64
        A6::Float64
        T1::Float64
        T2::Float64
        T3::Float64
        T4::Float64
        T5::Float64
        T6::Float64
        Ks::Float64
        Ls_lim::Tuple{Float64, Float64}
        Vcu::Float64
        Vcl::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.T}
        internal::InfrastructureSystemsInternal
    end

IEEE Stabilizing Model PSS. 

# Arguments
- `input_code::Int`: Code input for stabilizer, validation range: `(1, 6)`
- `remote_bus_control::Int`: ACBus identification [`number`](@ref ACBus) for control. `0` identifies the bus connected to this component
- `A1::Float64`: Filter coefficient, validation range: `(0, nothing)`
- `A2::Float64`: Filter coefficient, validation range: `(0, nothing)`
- `A3::Float64`: Filter coefficient, validation range: `(0, nothing)`
- `A4::Float64`: Filter coefficient, validation range: `(0, nothing)`
- `A5::Float64`: Filter coefficient, validation range: `(0, nothing)`
- `A6::Float64`: Filter coefficient, validation range: `(0, nothing)`
- `T1::Float64`: Time constant, validation range: `(0, 10)`
- `T2::Float64`: Time constant, validation range: `(0, 10)`
- `T3::Float64`: Time constant, validation range: `(0, 10)`
- `T4::Float64`: Time constant, validation range: `(0, 10)`
- `T5::Float64`: Time constant, validation range: `(0, 10)`
- `T6::Float64`: Time constant, validation range: `(eps(), 2.0)`
- `Ks::Float64`: Proportional gain, validation range: `(0, nothing)`
- `Ls_lim::Tuple{Float64, Float64}`: PSS output limits for regulator output `(Ls_min, Ls_max)`
- `Vcu::Float64`: Cutoff limiter upper bound, validation range: `(0, 1.25)`
- `Vcl::Float64`: Cutoff limiter lower bound, validation range: `(0, 1.0)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	x_p1: 1st filter integration,
	x_p2: 2nd filter integration, 
	x_p3: 3rd filter integration, 
	x_p4: 4rd filter integration, 
	x_p5: T1/T2 lead-lag integrator, 
	x_p6: T3/T4 lead-lag integrator, 
	:x_p7 last integer,
- `n_states::Int`: (**Do not modify.**) IEEEST has 7 states
- `states_types::Vector{StateTypes.T}`: (**Do not modify.**) IEEEST has 7 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct IEEEST <: PSS
    "Code input for stabilizer"
    input_code::Int
    "ACBus identification [`number`](@ref ACBus) for control. `0` identifies the bus connected to this component"
    remote_bus_control::Int
    "Filter coefficient"
    A1::Float64
    "Filter coefficient"
    A2::Float64
    "Filter coefficient"
    A3::Float64
    "Filter coefficient"
    A4::Float64
    "Filter coefficient"
    A5::Float64
    "Filter coefficient"
    A6::Float64
    "Time constant"
    T1::Float64
    "Time constant"
    T2::Float64
    "Time constant"
    T3::Float64
    "Time constant"
    T4::Float64
    "Time constant"
    T5::Float64
    "Time constant"
    T6::Float64
    "Proportional gain"
    Ks::Float64
    "PSS output limits for regulator output `(Ls_min, Ls_max)`"
    Ls_lim::Tuple{Float64, Float64}
    "Cutoff limiter upper bound"
    Vcu::Float64
    "Cutoff limiter lower bound"
    Vcl::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	x_p1: 1st filter integration,
	x_p2: 2nd filter integration, 
	x_p3: 3rd filter integration, 
	x_p4: 4rd filter integration, 
	x_p5: T1/T2 lead-lag integrator, 
	x_p6: T3/T4 lead-lag integrator, 
	:x_p7 last integer,"
    states::Vector{Symbol}
    "(**Do not modify.**) IEEEST has 7 states"
    n_states::Int
    "(**Do not modify.**) IEEEST has 7 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.T}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function IEEEST(input_code, remote_bus_control, A1, A2, A3, A4, A5, A6, T1, T2, T3, T4, T5, T6, Ks, Ls_lim, Vcu, Vcl, ext=Dict{String, Any}(), )
    IEEEST(input_code, remote_bus_control, A1, A2, A3, A4, A5, A6, T1, T2, T3, T4, T5, T6, Ks, Ls_lim, Vcu, Vcl, ext, [:x_p1, :x_p2, :x_p3, :x_p4, :x_p5, :x_p6, :x_p7], 7, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function IEEEST(; input_code, remote_bus_control, A1, A2, A3, A4, A5, A6, T1, T2, T3, T4, T5, T6, Ks, Ls_lim, Vcu, Vcl, ext=Dict{String, Any}(), states=[:x_p1, :x_p2, :x_p3, :x_p4, :x_p5, :x_p6, :x_p7], n_states=7, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    IEEEST(input_code, remote_bus_control, A1, A2, A3, A4, A5, A6, T1, T2, T3, T4, T5, T6, Ks, Ls_lim, Vcu, Vcl, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function IEEEST(::Nothing)
    IEEEST(;
        input_code=1,
        remote_bus_control=0,
        A1=0,
        A2=0,
        A3=0,
        A4=0,
        A5=0,
        A6=0,
        T1=0,
        T2=0,
        T3=0,
        T4=0,
        T5=0,
        T6=0,
        Ks=0,
        Ls_lim=(0.0, 0.0),
        Vcu=0,
        Vcl=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`IEEEST`](@ref) `input_code`."""
get_input_code(value::IEEEST) = value.input_code
"""Get [`IEEEST`](@ref) `remote_bus_control`."""
get_remote_bus_control(value::IEEEST) = value.remote_bus_control
"""Get [`IEEEST`](@ref) `A1`."""
get_A1(value::IEEEST) = value.A1
"""Get [`IEEEST`](@ref) `A2`."""
get_A2(value::IEEEST) = value.A2
"""Get [`IEEEST`](@ref) `A3`."""
get_A3(value::IEEEST) = value.A3
"""Get [`IEEEST`](@ref) `A4`."""
get_A4(value::IEEEST) = value.A4
"""Get [`IEEEST`](@ref) `A5`."""
get_A5(value::IEEEST) = value.A5
"""Get [`IEEEST`](@ref) `A6`."""
get_A6(value::IEEEST) = value.A6
"""Get [`IEEEST`](@ref) `T1`."""
get_T1(value::IEEEST) = value.T1
"""Get [`IEEEST`](@ref) `T2`."""
get_T2(value::IEEEST) = value.T2
"""Get [`IEEEST`](@ref) `T3`."""
get_T3(value::IEEEST) = value.T3
"""Get [`IEEEST`](@ref) `T4`."""
get_T4(value::IEEEST) = value.T4
"""Get [`IEEEST`](@ref) `T5`."""
get_T5(value::IEEEST) = value.T5
"""Get [`IEEEST`](@ref) `T6`."""
get_T6(value::IEEEST) = value.T6
"""Get [`IEEEST`](@ref) `Ks`."""
get_Ks(value::IEEEST) = value.Ks
"""Get [`IEEEST`](@ref) `Ls_lim`."""
get_Ls_lim(value::IEEEST) = value.Ls_lim
"""Get [`IEEEST`](@ref) `Vcu`."""
get_Vcu(value::IEEEST) = value.Vcu
"""Get [`IEEEST`](@ref) `Vcl`."""
get_Vcl(value::IEEEST) = value.Vcl
"""Get [`IEEEST`](@ref) `ext`."""
get_ext(value::IEEEST) = value.ext
"""Get [`IEEEST`](@ref) `states`."""
get_states(value::IEEEST) = value.states
"""Get [`IEEEST`](@ref) `n_states`."""
get_n_states(value::IEEEST) = value.n_states
"""Get [`IEEEST`](@ref) `states_types`."""
get_states_types(value::IEEEST) = value.states_types
"""Get [`IEEEST`](@ref) `internal`."""
get_internal(value::IEEEST) = value.internal

"""Set [`IEEEST`](@ref) `input_code`."""
set_input_code!(value::IEEEST, val) = value.input_code = val
"""Set [`IEEEST`](@ref) `remote_bus_control`."""
set_remote_bus_control!(value::IEEEST, val) = value.remote_bus_control = val
"""Set [`IEEEST`](@ref) `A1`."""
set_A1!(value::IEEEST, val) = value.A1 = val
"""Set [`IEEEST`](@ref) `A2`."""
set_A2!(value::IEEEST, val) = value.A2 = val
"""Set [`IEEEST`](@ref) `A3`."""
set_A3!(value::IEEEST, val) = value.A3 = val
"""Set [`IEEEST`](@ref) `A4`."""
set_A4!(value::IEEEST, val) = value.A4 = val
"""Set [`IEEEST`](@ref) `A5`."""
set_A5!(value::IEEEST, val) = value.A5 = val
"""Set [`IEEEST`](@ref) `A6`."""
set_A6!(value::IEEEST, val) = value.A6 = val
"""Set [`IEEEST`](@ref) `T1`."""
set_T1!(value::IEEEST, val) = value.T1 = val
"""Set [`IEEEST`](@ref) `T2`."""
set_T2!(value::IEEEST, val) = value.T2 = val
"""Set [`IEEEST`](@ref) `T3`."""
set_T3!(value::IEEEST, val) = value.T3 = val
"""Set [`IEEEST`](@ref) `T4`."""
set_T4!(value::IEEEST, val) = value.T4 = val
"""Set [`IEEEST`](@ref) `T5`."""
set_T5!(value::IEEEST, val) = value.T5 = val
"""Set [`IEEEST`](@ref) `T6`."""
set_T6!(value::IEEEST, val) = value.T6 = val
"""Set [`IEEEST`](@ref) `Ks`."""
set_Ks!(value::IEEEST, val) = value.Ks = val
"""Set [`IEEEST`](@ref) `Ls_lim`."""
set_Ls_lim!(value::IEEEST, val) = value.Ls_lim = val
"""Set [`IEEEST`](@ref) `Vcu`."""
set_Vcu!(value::IEEEST, val) = value.Vcu = val
"""Set [`IEEEST`](@ref) `Vcl`."""
set_Vcl!(value::IEEEST, val) = value.Vcl = val
"""Set [`IEEEST`](@ref) `ext`."""
set_ext!(value::IEEEST, val) = value.ext = val
"""Set [`IEEEST`](@ref) `states_types`."""
set_states_types!(value::IEEEST, val) = value.states_types = val
