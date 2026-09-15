#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct PSS2B <: PSS
        input_code_1::Int
        remote_bus_control_1::Int
        input_code_2::Int
        remote_bus_control_2::Int
        M_rtf::Int
        N_rtf::Int
        Tw1::Float64
        Tw2::Float64
        T6::Float64
        Tw3::Float64
        Tw4::Float64
        T7::Float64
        Ks2::Float64
        Ks3::Float64
        T8::Float64
        T9::Float64
        Ks1::Float64
        T1::Float64
        T2::Float64
        T3::Float64
        T4::Float64
        T10::Float64
        T11::Float64
        Vs1_lim::Tuple{Float64, Float64}
        Vs2_lim::Tuple{Float64, Float64}
        Vst_lim::Tuple{Float64, Float64}
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.T}
        internal::InfrastructureSystemsInternal
    end

IEEE 421.5 2005 PSS2B IEEE Dual-Input Stabilizer Model

# Arguments
- `input_code_1::Int`: First Input Code for stabilizer, validation range: `(1, 6)`
- `remote_bus_control_1::Int`: First Input remote bus identification [`number`](@ref ACBus) for control. `0` identifies the local bus connected to this component
- `input_code_2::Int`: Second Input Code for stabilizer, validation range: `(1, 6)`
- `remote_bus_control_2::Int`: Second Input remote bus identification [`number`](@ref ACBus) for control. `0` identifies the local bus connected to this component
- `M_rtf::Int`: M parameter for ramp tracking filter, validation range: `(0, 8)`
- `N_rtf::Int`: N parameter for ramp tracking filter, validation range: `(0, 8)`
- `Tw1::Float64`: Time constant for first washout filter for first input, validation range: `(eps(), nothing)`
- `Tw2::Float64`: Time constant for second washout filter for first input, validation range: `(0, nothing)`
- `T6::Float64`: Time constant for low-pass filter for first input, validation range: `(0, nothing)`
- `Tw3::Float64`: Time constant for first washout filter for second input, validation range: `(eps(), nothing)`
- `Tw4::Float64`: Time constant for second washout filter for second input, validation range: `(0, nothing)`
- `T7::Float64`: Time constant for low-pass filter for second input, validation range: `(0, nothing)`
- `Ks2::Float64`: Gain for low-pass filter for second input, validation range: `(0, nothing)`
- `Ks3::Float64`: Gain for second input, validation range: `(0, nothing)`
- `T8::Float64`: Time constant for ramp tracking filter, validation range: `(0, nothing)`
- `T9::Float64`: Time constant for ramp tracking filter, validation range: `(eps(), nothing)`
- `Ks1::Float64`: Gain before lead-lag blocks, validation range: `(0, nothing)`
- `T1::Float64`: Time constant for first lead-lag block, validation range: `(0, nothing)`
- `T2::Float64`: Time constant for first lead-lag block, validation range: `(0, nothing)`
- `T3::Float64`: Time constant for second lead-lag block, validation range: `(0, nothing)`
- `T4::Float64`: Time constant for second lead-lag block, validation range: `(0, nothing)`
- `T10::Float64`: Time constant for third lead-lag block, validation range: `(0, nothing)`
- `T11::Float64`: Time constant for third lead-lag block, validation range: `(0, nothing)`
- `Vs1_lim::Tuple{Float64, Float64}`: First input limits `(Vs1_min, Vs1_max)`
- `Vs2_lim::Tuple{Float64, Float64}`: Second input limits `(Vs2_min, Vs2_max)`
- `Vst_lim::Tuple{Float64, Float64}`: PSS output limits `(Vst_min, Vst_max)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	x_p1: 1st washout 1st input, 
	x_p2: 2nd washout 1st input, 
	x_p3: transducer 1st input, 
	x_p4: 1st washout 2nd input, 
	x_p5: 2nd washout 2nd input, 
	x_p6: transducer 2nd input, 
	x_p7: ramp tracking filter state 1, 
	x_p8: ramp tracking filter state 2, 
	x_p9: ramp tracking filter state 3, 
	x_p10: ramp tracking filter state 4, 
	x_p11: ramp tracking filter state 5, 
	x_p12: ramp tracking filter state 6, 
	x_p13: ramp tracking filter state 7, 
	x_p14: ramp tracking filter state 8, 
	x_p15: 1st lead-lag, 
	x_p16: 2nd lead-lag, 
	x_p17: 3rd lead-lag,
- `n_states::Int`: (**Do not modify.**) IEEEST has 17 states
- `states_types::Vector{StateTypes.T}`: (**Do not modify.**) IEEEST has 17 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct PSS2B <: PSS
    "First Input Code for stabilizer"
    input_code_1::Int
    "First Input remote bus identification [`number`](@ref ACBus) for control. `0` identifies the local bus connected to this component"
    remote_bus_control_1::Int
    "Second Input Code for stabilizer"
    input_code_2::Int
    "Second Input remote bus identification [`number`](@ref ACBus) for control. `0` identifies the local bus connected to this component"
    remote_bus_control_2::Int
    "M parameter for ramp tracking filter"
    M_rtf::Int
    "N parameter for ramp tracking filter"
    N_rtf::Int
    "Time constant for first washout filter for first input"
    Tw1::Float64
    "Time constant for second washout filter for first input"
    Tw2::Float64
    "Time constant for low-pass filter for first input"
    T6::Float64
    "Time constant for first washout filter for second input"
    Tw3::Float64
    "Time constant for second washout filter for second input"
    Tw4::Float64
    "Time constant for low-pass filter for second input"
    T7::Float64
    "Gain for low-pass filter for second input"
    Ks2::Float64
    "Gain for second input"
    Ks3::Float64
    "Time constant for ramp tracking filter"
    T8::Float64
    "Time constant for ramp tracking filter"
    T9::Float64
    "Gain before lead-lag blocks"
    Ks1::Float64
    "Time constant for first lead-lag block"
    T1::Float64
    "Time constant for first lead-lag block"
    T2::Float64
    "Time constant for second lead-lag block"
    T3::Float64
    "Time constant for second lead-lag block"
    T4::Float64
    "Time constant for third lead-lag block"
    T10::Float64
    "Time constant for third lead-lag block"
    T11::Float64
    "First input limits `(Vs1_min, Vs1_max)`"
    Vs1_lim::Tuple{Float64, Float64}
    "Second input limits `(Vs2_min, Vs2_max)`"
    Vs2_lim::Tuple{Float64, Float64}
    "PSS output limits `(Vst_min, Vst_max)`"
    Vst_lim::Tuple{Float64, Float64}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	x_p1: 1st washout 1st input, 
	x_p2: 2nd washout 1st input, 
	x_p3: transducer 1st input, 
	x_p4: 1st washout 2nd input, 
	x_p5: 2nd washout 2nd input, 
	x_p6: transducer 2nd input, 
	x_p7: ramp tracking filter state 1, 
	x_p8: ramp tracking filter state 2, 
	x_p9: ramp tracking filter state 3, 
	x_p10: ramp tracking filter state 4, 
	x_p11: ramp tracking filter state 5, 
	x_p12: ramp tracking filter state 6, 
	x_p13: ramp tracking filter state 7, 
	x_p14: ramp tracking filter state 8, 
	x_p15: 1st lead-lag, 
	x_p16: 2nd lead-lag, 
	x_p17: 3rd lead-lag,"
    states::Vector{Symbol}
    "(**Do not modify.**) IEEEST has 17 states"
    n_states::Int
    "(**Do not modify.**) IEEEST has 17 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.T}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function PSS2B(input_code_1, remote_bus_control_1, input_code_2, remote_bus_control_2, M_rtf, N_rtf, Tw1, Tw2, T6, Tw3, Tw4, T7, Ks2, Ks3, T8, T9, Ks1, T1, T2, T3, T4, T10, T11, Vs1_lim, Vs2_lim, Vst_lim, ext=Dict{String, Any}(), )
    PSS2B(input_code_1, remote_bus_control_1, input_code_2, remote_bus_control_2, M_rtf, N_rtf, Tw1, Tw2, T6, Tw3, Tw4, T7, Ks2, Ks3, T8, T9, Ks1, T1, T2, T3, T4, T10, T11, Vs1_lim, Vs2_lim, Vst_lim, ext, [:x_p1, :x_p2, :x_p3, :x_p4, :x_p5, :x_p6, :x_p7, :x_p8, :x_p9, :x_p10, :x_p11, :x_p12, :x_p13, :x_p14, :x_p15, :x_p16, :x_p17], 17, [StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function PSS2B(; input_code_1, remote_bus_control_1, input_code_2, remote_bus_control_2, M_rtf, N_rtf, Tw1, Tw2, T6, Tw3, Tw4, T7, Ks2, Ks3, T8, T9, Ks1, T1, T2, T3, T4, T10, T11, Vs1_lim, Vs2_lim, Vst_lim, ext=Dict{String, Any}(), states=[:x_p1, :x_p2, :x_p3, :x_p4, :x_p5, :x_p6, :x_p7, :x_p8, :x_p9, :x_p10, :x_p11, :x_p12, :x_p13, :x_p14, :x_p15, :x_p16, :x_p17], n_states=17, states_types=[StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    PSS2B(input_code_1, remote_bus_control_1, input_code_2, remote_bus_control_2, M_rtf, N_rtf, Tw1, Tw2, T6, Tw3, Tw4, T7, Ks2, Ks3, T8, T9, Ks1, T1, T2, T3, T4, T10, T11, Vs1_lim, Vs2_lim, Vst_lim, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function PSS2B(::Nothing)
    PSS2B(;
        input_code_1=1,
        remote_bus_control_1=0,
        input_code_2=1,
        remote_bus_control_2=0,
        M_rtf=0,
        N_rtf=0,
        Tw1=0,
        Tw2=0,
        T6=0,
        Tw3=0,
        Tw4=0,
        T7=0,
        Ks2=0,
        Ks3=0,
        T8=0,
        T9=0,
        Ks1=0,
        T1=0,
        T2=0,
        T3=0,
        T4=0,
        T10=0,
        T11=0,
        Vs1_lim=(0.0, 0.0),
        Vs2_lim=(0.0, 0.0),
        Vst_lim=(0.0, 0.0),
        ext=Dict{String, Any}(),
    )
end

"""Get [`PSS2B`](@ref) `input_code_1`."""
get_input_code_1(value::PSS2B) = value.input_code_1
"""Get [`PSS2B`](@ref) `remote_bus_control_1`."""
get_remote_bus_control_1(value::PSS2B) = value.remote_bus_control_1
"""Get [`PSS2B`](@ref) `input_code_2`."""
get_input_code_2(value::PSS2B) = value.input_code_2
"""Get [`PSS2B`](@ref) `remote_bus_control_2`."""
get_remote_bus_control_2(value::PSS2B) = value.remote_bus_control_2
"""Get [`PSS2B`](@ref) `M_rtf`."""
get_M_rtf(value::PSS2B) = value.M_rtf
"""Get [`PSS2B`](@ref) `N_rtf`."""
get_N_rtf(value::PSS2B) = value.N_rtf
"""Get [`PSS2B`](@ref) `Tw1`."""
get_Tw1(value::PSS2B) = value.Tw1
"""Get [`PSS2B`](@ref) `Tw2`."""
get_Tw2(value::PSS2B) = value.Tw2
"""Get [`PSS2B`](@ref) `T6`."""
get_T6(value::PSS2B) = value.T6
"""Get [`PSS2B`](@ref) `Tw3`."""
get_Tw3(value::PSS2B) = value.Tw3
"""Get [`PSS2B`](@ref) `Tw4`."""
get_Tw4(value::PSS2B) = value.Tw4
"""Get [`PSS2B`](@ref) `T7`."""
get_T7(value::PSS2B) = value.T7
"""Get [`PSS2B`](@ref) `Ks2`."""
get_Ks2(value::PSS2B) = value.Ks2
"""Get [`PSS2B`](@ref) `Ks3`."""
get_Ks3(value::PSS2B) = value.Ks3
"""Get [`PSS2B`](@ref) `T8`."""
get_T8(value::PSS2B) = value.T8
"""Get [`PSS2B`](@ref) `T9`."""
get_T9(value::PSS2B) = value.T9
"""Get [`PSS2B`](@ref) `Ks1`."""
get_Ks1(value::PSS2B) = value.Ks1
"""Get [`PSS2B`](@ref) `T1`."""
get_T1(value::PSS2B) = value.T1
"""Get [`PSS2B`](@ref) `T2`."""
get_T2(value::PSS2B) = value.T2
"""Get [`PSS2B`](@ref) `T3`."""
get_T3(value::PSS2B) = value.T3
"""Get [`PSS2B`](@ref) `T4`."""
get_T4(value::PSS2B) = value.T4
"""Get [`PSS2B`](@ref) `T10`."""
get_T10(value::PSS2B) = value.T10
"""Get [`PSS2B`](@ref) `T11`."""
get_T11(value::PSS2B) = value.T11
"""Get [`PSS2B`](@ref) `Vs1_lim`."""
get_Vs1_lim(value::PSS2B) = value.Vs1_lim
"""Get [`PSS2B`](@ref) `Vs2_lim`."""
get_Vs2_lim(value::PSS2B) = value.Vs2_lim
"""Get [`PSS2B`](@ref) `Vst_lim`."""
get_Vst_lim(value::PSS2B) = value.Vst_lim
"""Get [`PSS2B`](@ref) `ext`."""
get_ext(value::PSS2B) = value.ext
"""Get [`PSS2B`](@ref) `states`."""
get_states(value::PSS2B) = value.states
"""Get [`PSS2B`](@ref) `n_states`."""
get_n_states(value::PSS2B) = value.n_states
"""Get [`PSS2B`](@ref) `states_types`."""
get_states_types(value::PSS2B) = value.states_types
"""Get [`PSS2B`](@ref) `internal`."""
get_internal(value::PSS2B) = value.internal

"""Set [`PSS2B`](@ref) `input_code_1`."""
set_input_code_1!(value::PSS2B, val) = value.input_code_1 = val
"""Set [`PSS2B`](@ref) `remote_bus_control_1`."""
set_remote_bus_control_1!(value::PSS2B, val) = value.remote_bus_control_1 = val
"""Set [`PSS2B`](@ref) `input_code_2`."""
set_input_code_2!(value::PSS2B, val) = value.input_code_2 = val
"""Set [`PSS2B`](@ref) `remote_bus_control_2`."""
set_remote_bus_control_2!(value::PSS2B, val) = value.remote_bus_control_2 = val
"""Set [`PSS2B`](@ref) `M_rtf`."""
set_M_rtf!(value::PSS2B, val) = value.M_rtf = val
"""Set [`PSS2B`](@ref) `N_rtf`."""
set_N_rtf!(value::PSS2B, val) = value.N_rtf = val
"""Set [`PSS2B`](@ref) `Tw1`."""
set_Tw1!(value::PSS2B, val) = value.Tw1 = val
"""Set [`PSS2B`](@ref) `Tw2`."""
set_Tw2!(value::PSS2B, val) = value.Tw2 = val
"""Set [`PSS2B`](@ref) `T6`."""
set_T6!(value::PSS2B, val) = value.T6 = val
"""Set [`PSS2B`](@ref) `Tw3`."""
set_Tw3!(value::PSS2B, val) = value.Tw3 = val
"""Set [`PSS2B`](@ref) `Tw4`."""
set_Tw4!(value::PSS2B, val) = value.Tw4 = val
"""Set [`PSS2B`](@ref) `T7`."""
set_T7!(value::PSS2B, val) = value.T7 = val
"""Set [`PSS2B`](@ref) `Ks2`."""
set_Ks2!(value::PSS2B, val) = value.Ks2 = val
"""Set [`PSS2B`](@ref) `Ks3`."""
set_Ks3!(value::PSS2B, val) = value.Ks3 = val
"""Set [`PSS2B`](@ref) `T8`."""
set_T8!(value::PSS2B, val) = value.T8 = val
"""Set [`PSS2B`](@ref) `T9`."""
set_T9!(value::PSS2B, val) = value.T9 = val
"""Set [`PSS2B`](@ref) `Ks1`."""
set_Ks1!(value::PSS2B, val) = value.Ks1 = val
"""Set [`PSS2B`](@ref) `T1`."""
set_T1!(value::PSS2B, val) = value.T1 = val
"""Set [`PSS2B`](@ref) `T2`."""
set_T2!(value::PSS2B, val) = value.T2 = val
"""Set [`PSS2B`](@ref) `T3`."""
set_T3!(value::PSS2B, val) = value.T3 = val
"""Set [`PSS2B`](@ref) `T4`."""
set_T4!(value::PSS2B, val) = value.T4 = val
"""Set [`PSS2B`](@ref) `T10`."""
set_T10!(value::PSS2B, val) = value.T10 = val
"""Set [`PSS2B`](@ref) `T11`."""
set_T11!(value::PSS2B, val) = value.T11 = val
"""Set [`PSS2B`](@ref) `Vs1_lim`."""
set_Vs1_lim!(value::PSS2B, val) = value.Vs1_lim = val
"""Set [`PSS2B`](@ref) `Vs2_lim`."""
set_Vs2_lim!(value::PSS2B, val) = value.Vs2_lim = val
"""Set [`PSS2B`](@ref) `Vst_lim`."""
set_Vst_lim!(value::PSS2B, val) = value.Vst_lim = val
"""Set [`PSS2B`](@ref) `ext`."""
set_ext!(value::PSS2B, val) = value.ext = val
"""Set [`PSS2B`](@ref) `states_types`."""
set_states_types!(value::PSS2B, val) = value.states_types = val
