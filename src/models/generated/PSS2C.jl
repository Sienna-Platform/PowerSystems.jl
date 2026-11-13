#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct PSS2C <: PowerSystemStabilizerDynamics
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
        T12::Float64
        T13::Float64
        PSS_Hysteresis_param::Tuple{Float64, Float64}
        Xcomp::Float64
        Tcomp::Float64
        hysteresis_binary_logic::Int
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

IEEE 421.5 2016 PSS2C IEEE Dual-Input Stabilizer Model

# Arguments
- `input_code_1::Int`: First Input Code for stabilizer, validation range: `(1, 7)`
- `remote_bus_control_1::Int`: First Input remote bus identification [`number`](@ref ACBus) for control. `0` identifies the local bus connected to this component
- `input_code_2::Int`: Second Input Code for stabilizer, validation range: `(1, 6)`
- `remote_bus_control_2::Int`: Second Input remote bus identification [`number`](@ref ACBus) for control. `0` identifies the local bus connected to this component
- `M_rtf::Int`: M parameter for ramp tracking filter, validation range: `(0, 8)`
- `N_rtf::Int`: N parameter for ramp tracking filter, validation range: `(0, 8)`
- `Tw1::Float64`: Time constant for first washout filter for first input, validation range: `(0.0001, nothing)`
- `Tw2::Float64`: Time constant for second washout filter for first input, validation range: `(0, nothing)`
- `T6::Float64`: Time constant for low-pass filter for first input, validation range: `(0, nothing)`
- `Tw3::Float64`: Time constant for first washout filter for second input, validation range: `(0.0001, nothing)`
- `Tw4::Float64`: Time constant for second washout filter for second input, validation range: `(0, nothing)`
- `T7::Float64`: Time constant for low-pass filter for second input, validation range: `(0, nothing)`
- `Ks2::Float64`: Gain for low-pass filter for second input, validation range: `(0, nothing)`
- `Ks3::Float64`: Gain for second input, validation range: `(0, nothing)`
- `T8::Float64`: Time constant for ramp tracking filter, validation range: `(0, nothing)`
- `T9::Float64`: Time constant for ramp tracking filter, validation range: `(0.0001, nothing)`
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
- `T12::Float64`: Time constant for fourth lead-lag block, validation range: `(0, nothing)`
- `T13::Float64`: Time constant for fourth lead-lag block, validation range: `(0, nothing)`
- `PSS_Hysteresis_param::Tuple{Float64, Float64}`: PSS output hysteresis parameters `(PSSOFF, PSSON)`
- `Xcomp::Float64`: Stator Leakage Reactance, validation range: `(0, nothing)`
- `Tcomp::Float64`: Time measured with compensated frequency, validation range: `(0.0001, nothing)`
- `hysteresis_binary_logic::Int`: (default: `1`) Hysteresis memory variable
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
	x_p18: 4th lead-lag, 
	x_p19: washout block for compensated frequency,
- `n_states::Int`: (**Do not modify.**) IEEEST has 19 states
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) IEEEST has 19 [differential](@ref states_list) [states](@ref S)
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct PSS2C <: PowerSystemStabilizerDynamics
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
    "Time constant for fourth lead-lag block"
    T12::Float64
    "Time constant for fourth lead-lag block"
    T13::Float64
    "PSS output hysteresis parameters `(PSSOFF, PSSON)`"
    PSS_Hysteresis_param::Tuple{Float64, Float64}
    "Stator Leakage Reactance"
    Xcomp::Float64
    "Time measured with compensated frequency"
    Tcomp::Float64
    "Hysteresis memory variable"
    hysteresis_binary_logic::Int
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
	x_p17: 3rd lead-lag, 
	x_p18: 4th lead-lag, 
	x_p19: washout block for compensated frequency,"
    states::Vector{Symbol}
    "(**Do not modify.**) IEEEST has 19 states"
    n_states::Int
    "(**Do not modify.**) IEEEST has 19 [differential](@ref states_list) [states](@ref S)"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function PSS2C(input_code_1, remote_bus_control_1, input_code_2, remote_bus_control_2, M_rtf, N_rtf, Tw1, Tw2, T6, Tw3, Tw4, T7, Ks2, Ks3, T8, T9, Ks1, T1, T2, T3, T4, T10, T11, Vs1_lim, Vs2_lim, Vst_lim, T12, T13, PSS_Hysteresis_param, Xcomp, Tcomp, hysteresis_binary_logic=1, ext=Dict{String, Any}(), )
    PSS2C(input_code_1, remote_bus_control_1, input_code_2, remote_bus_control_2, M_rtf, N_rtf, Tw1, Tw2, T6, Tw3, Tw4, T7, Ks2, Ks3, T8, T9, Ks1, T1, T2, T3, T4, T10, T11, Vs1_lim, Vs2_lim, Vst_lim, T12, T13, PSS_Hysteresis_param, Xcomp, Tcomp, hysteresis_binary_logic, ext, [:x_p1, :x_p2, :x_p3, :x_p4, :x_p5, :x_p6, :x_p7, :x_p8, :x_p9, :x_p10, :x_p11, :x_p12, :x_p13, :x_p14, :x_p15, :x_p16, :x_p17, :x_p18, :x_p19], 19, [StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], InfrastructureSystemsInternal(), )
end

function PSS2C(; input_code_1, remote_bus_control_1, input_code_2, remote_bus_control_2, M_rtf, N_rtf, Tw1, Tw2, T6, Tw3, Tw4, T7, Ks2, Ks3, T8, T9, Ks1, T1, T2, T3, T4, T10, T11, Vs1_lim, Vs2_lim, Vst_lim, T12, T13, PSS_Hysteresis_param, Xcomp, Tcomp, hysteresis_binary_logic=1, ext=Dict{String, Any}(), states=[:x_p1, :x_p2, :x_p3, :x_p4, :x_p5, :x_p6, :x_p7, :x_p8, :x_p9, :x_p10, :x_p11, :x_p12, :x_p13, :x_p14, :x_p15, :x_p16, :x_p17, :x_p18, :x_p19], n_states=19, states_types=[StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential, StateTypes.Differential], internal=InfrastructureSystemsInternal(), )
    PSS2C(input_code_1, remote_bus_control_1, input_code_2, remote_bus_control_2, M_rtf, N_rtf, Tw1, Tw2, T6, Tw3, Tw4, T7, Ks2, Ks3, T8, T9, Ks1, T1, T2, T3, T4, T10, T11, Vs1_lim, Vs2_lim, Vst_lim, T12, T13, PSS_Hysteresis_param, Xcomp, Tcomp, hysteresis_binary_logic, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function PSS2C(::Nothing)
    PSS2C(;
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
        T12=0,
        T13=0,
        PSS_Hysteresis_param=(0.0, 0.0),
        Xcomp=0,
        Tcomp=0,
        hysteresis_binary_logic=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`PSS2C`](@ref) `input_code_1`."""
get_input_code_1(value::PSS2C) = value.input_code_1
"""Get [`PSS2C`](@ref) `remote_bus_control_1`."""
get_remote_bus_control_1(value::PSS2C) = value.remote_bus_control_1
"""Get [`PSS2C`](@ref) `input_code_2`."""
get_input_code_2(value::PSS2C) = value.input_code_2
"""Get [`PSS2C`](@ref) `remote_bus_control_2`."""
get_remote_bus_control_2(value::PSS2C) = value.remote_bus_control_2
"""Get [`PSS2C`](@ref) `M_rtf`."""
get_M_rtf(value::PSS2C) = value.M_rtf
"""Get [`PSS2C`](@ref) `N_rtf`."""
get_N_rtf(value::PSS2C) = value.N_rtf
"""Get [`PSS2C`](@ref) `Tw1`."""
get_Tw1(value::PSS2C) = value.Tw1
"""Get [`PSS2C`](@ref) `Tw2`."""
get_Tw2(value::PSS2C) = value.Tw2
"""Get [`PSS2C`](@ref) `T6`."""
get_T6(value::PSS2C) = value.T6
"""Get [`PSS2C`](@ref) `Tw3`."""
get_Tw3(value::PSS2C) = value.Tw3
"""Get [`PSS2C`](@ref) `Tw4`."""
get_Tw4(value::PSS2C) = value.Tw4
"""Get [`PSS2C`](@ref) `T7`."""
get_T7(value::PSS2C) = value.T7
"""Get [`PSS2C`](@ref) `Ks2`."""
get_Ks2(value::PSS2C) = value.Ks2
"""Get [`PSS2C`](@ref) `Ks3`."""
get_Ks3(value::PSS2C) = value.Ks3
"""Get [`PSS2C`](@ref) `T8`."""
get_T8(value::PSS2C) = value.T8
"""Get [`PSS2C`](@ref) `T9`."""
get_T9(value::PSS2C) = value.T9
"""Get [`PSS2C`](@ref) `Ks1`."""
get_Ks1(value::PSS2C) = value.Ks1
"""Get [`PSS2C`](@ref) `T1`."""
get_T1(value::PSS2C) = value.T1
"""Get [`PSS2C`](@ref) `T2`."""
get_T2(value::PSS2C) = value.T2
"""Get [`PSS2C`](@ref) `T3`."""
get_T3(value::PSS2C) = value.T3
"""Get [`PSS2C`](@ref) `T4`."""
get_T4(value::PSS2C) = value.T4
"""Get [`PSS2C`](@ref) `T10`."""
get_T10(value::PSS2C) = value.T10
"""Get [`PSS2C`](@ref) `T11`."""
get_T11(value::PSS2C) = value.T11
"""Get [`PSS2C`](@ref) `Vs1_lim`."""
get_Vs1_lim(value::PSS2C) = value.Vs1_lim
"""Get [`PSS2C`](@ref) `Vs2_lim`."""
get_Vs2_lim(value::PSS2C) = value.Vs2_lim
"""Get [`PSS2C`](@ref) `Vst_lim`."""
get_Vst_lim(value::PSS2C) = value.Vst_lim
"""Get [`PSS2C`](@ref) `T12`."""
get_T12(value::PSS2C) = value.T12
"""Get [`PSS2C`](@ref) `T13`."""
get_T13(value::PSS2C) = value.T13
"""Get [`PSS2C`](@ref) `PSS_Hysteresis_param`."""
get_PSS_Hysteresis_param(value::PSS2C) = value.PSS_Hysteresis_param
"""Get [`PSS2C`](@ref) `Xcomp`."""
get_Xcomp(value::PSS2C) = value.Xcomp
"""Get [`PSS2C`](@ref) `Tcomp`."""
get_Tcomp(value::PSS2C) = value.Tcomp
"""Get [`PSS2C`](@ref) `hysteresis_binary_logic`."""
get_hysteresis_binary_logic(value::PSS2C) = value.hysteresis_binary_logic
"""Get [`PSS2C`](@ref) `ext`."""
get_ext(value::PSS2C) = value.ext
"""Get [`PSS2C`](@ref) `states`."""
get_states(value::PSS2C) = value.states
"""Get [`PSS2C`](@ref) `n_states`."""
get_n_states(value::PSS2C) = value.n_states
"""Get [`PSS2C`](@ref) `states_types`."""
get_states_types(value::PSS2C) = value.states_types
"""Get [`PSS2C`](@ref) `internal`."""
get_internal(value::PSS2C) = value.internal

"""Set [`PSS2C`](@ref) `input_code_1`."""
set_input_code_1!(value::PSS2C, val) = value.input_code_1 = val
"""Set [`PSS2C`](@ref) `remote_bus_control_1`."""
set_remote_bus_control_1!(value::PSS2C, val) = value.remote_bus_control_1 = val
"""Set [`PSS2C`](@ref) `input_code_2`."""
set_input_code_2!(value::PSS2C, val) = value.input_code_2 = val
"""Set [`PSS2C`](@ref) `remote_bus_control_2`."""
set_remote_bus_control_2!(value::PSS2C, val) = value.remote_bus_control_2 = val
"""Set [`PSS2C`](@ref) `M_rtf`."""
set_M_rtf!(value::PSS2C, val) = value.M_rtf = val
"""Set [`PSS2C`](@ref) `N_rtf`."""
set_N_rtf!(value::PSS2C, val) = value.N_rtf = val
"""Set [`PSS2C`](@ref) `Tw1`."""
set_Tw1!(value::PSS2C, val) = value.Tw1 = val
"""Set [`PSS2C`](@ref) `Tw2`."""
set_Tw2!(value::PSS2C, val) = value.Tw2 = val
"""Set [`PSS2C`](@ref) `T6`."""
set_T6!(value::PSS2C, val) = value.T6 = val
"""Set [`PSS2C`](@ref) `Tw3`."""
set_Tw3!(value::PSS2C, val) = value.Tw3 = val
"""Set [`PSS2C`](@ref) `Tw4`."""
set_Tw4!(value::PSS2C, val) = value.Tw4 = val
"""Set [`PSS2C`](@ref) `T7`."""
set_T7!(value::PSS2C, val) = value.T7 = val
"""Set [`PSS2C`](@ref) `Ks2`."""
set_Ks2!(value::PSS2C, val) = value.Ks2 = val
"""Set [`PSS2C`](@ref) `Ks3`."""
set_Ks3!(value::PSS2C, val) = value.Ks3 = val
"""Set [`PSS2C`](@ref) `T8`."""
set_T8!(value::PSS2C, val) = value.T8 = val
"""Set [`PSS2C`](@ref) `T9`."""
set_T9!(value::PSS2C, val) = value.T9 = val
"""Set [`PSS2C`](@ref) `Ks1`."""
set_Ks1!(value::PSS2C, val) = value.Ks1 = val
"""Set [`PSS2C`](@ref) `T1`."""
set_T1!(value::PSS2C, val) = value.T1 = val
"""Set [`PSS2C`](@ref) `T2`."""
set_T2!(value::PSS2C, val) = value.T2 = val
"""Set [`PSS2C`](@ref) `T3`."""
set_T3!(value::PSS2C, val) = value.T3 = val
"""Set [`PSS2C`](@ref) `T4`."""
set_T4!(value::PSS2C, val) = value.T4 = val
"""Set [`PSS2C`](@ref) `T10`."""
set_T10!(value::PSS2C, val) = value.T10 = val
"""Set [`PSS2C`](@ref) `T11`."""
set_T11!(value::PSS2C, val) = value.T11 = val
"""Set [`PSS2C`](@ref) `Vs1_lim`."""
set_Vs1_lim!(value::PSS2C, val) = value.Vs1_lim = val
"""Set [`PSS2C`](@ref) `Vs2_lim`."""
set_Vs2_lim!(value::PSS2C, val) = value.Vs2_lim = val
"""Set [`PSS2C`](@ref) `Vst_lim`."""
set_Vst_lim!(value::PSS2C, val) = value.Vst_lim = val
"""Set [`PSS2C`](@ref) `T12`."""
set_T12!(value::PSS2C, val) = value.T12 = val
"""Set [`PSS2C`](@ref) `T13`."""
set_T13!(value::PSS2C, val) = value.T13 = val
"""Set [`PSS2C`](@ref) `PSS_Hysteresis_param`."""
set_PSS_Hysteresis_param!(value::PSS2C, val) = value.PSS_Hysteresis_param = val
"""Set [`PSS2C`](@ref) `Xcomp`."""
set_Xcomp!(value::PSS2C, val) = value.Xcomp = val
"""Set [`PSS2C`](@ref) `Tcomp`."""
set_Tcomp!(value::PSS2C, val) = value.Tcomp = val
"""Set [`PSS2C`](@ref) `hysteresis_binary_logic`."""
set_hysteresis_binary_logic!(value::PSS2C, val) = value.hysteresis_binary_logic = val
"""Set [`PSS2C`](@ref) `ext`."""
set_ext!(value::PSS2C, val) = value.ext = val
"""Set [`PSS2C`](@ref) `states_types`."""
set_states_types!(value::PSS2C, val) = value.states_types = val



function from_openapi(po::PD.PSS2C, refs::OpenAPIRefs)
    return PSS2C(;
        input_code_1 = _wire_required(po.input_code_1, "PSS2C", "input_code_1"),
        remote_bus_control_1 = _wire_required(po.remote_bus_control_1, "PSS2C", "remote_bus_control_1"),
        input_code_2 = _wire_required(po.input_code_2, "PSS2C", "input_code_2"),
        remote_bus_control_2 = _wire_required(po.remote_bus_control_2, "PSS2C", "remote_bus_control_2"),
        M_rtf = _wire_required(po.m_rtf, "PSS2C", "M_rtf"),
        N_rtf = _wire_required(po.n_rtf, "PSS2C", "N_rtf"),
        Tw1 = _wire_required(po.tw1, "PSS2C", "Tw1"),
        Tw2 = _wire_required(po.tw2, "PSS2C", "Tw2"),
        T6 = _wire_required(po.t6, "PSS2C", "T6"),
        Tw3 = _wire_required(po.tw3, "PSS2C", "Tw3"),
        Tw4 = _wire_required(po.tw4, "PSS2C", "Tw4"),
        T7 = _wire_required(po.t7, "PSS2C", "T7"),
        Ks2 = _wire_required(po.ks2, "PSS2C", "Ks2"),
        Ks3 = _wire_required(po.ks3, "PSS2C", "Ks3"),
        T8 = _wire_required(po.t8, "PSS2C", "T8"),
        T9 = _wire_required(po.t9, "PSS2C", "T9"),
        Ks1 = _wire_required(po.ks1, "PSS2C", "Ks1"),
        T1 = _wire_required(po.t1, "PSS2C", "T1"),
        T2 = _wire_required(po.t2, "PSS2C", "T2"),
        T3 = _wire_required(po.t3, "PSS2C", "T3"),
        T4 = _wire_required(po.t4, "PSS2C", "T4"),
        T10 = _wire_required(po.t10, "PSS2C", "T10"),
        T11 = _wire_required(po.t11, "PSS2C", "T11"),
        Vs1_lim = _wire_to_psy(Tuple{Float64, Float64}, po.vs1_lim),
        Vs2_lim = _wire_to_psy(Tuple{Float64, Float64}, po.vs2_lim),
        Vst_lim = _wire_to_psy(Tuple{Float64, Float64}, po.vst_lim),
        T12 = _wire_required(po.t12, "PSS2C", "T12"),
        T13 = _wire_required(po.t13, "PSS2C", "T13"),
        PSS_Hysteresis_param = _wire_to_psy(Tuple{Float64, Float64}, po.pss_hysteresis_param),
        Xcomp = _wire_required(po.xcomp, "PSS2C", "Xcomp"),
        Tcomp = _wire_required(po.tcomp, "PSS2C", "Tcomp"),
        hysteresis_binary_logic = _or_default(po.hysteresis_binary_logic, 1),
    )
end

function to_openapi(value::PSS2C, refs::OpenAPIRefs)
    return PD.PSS2C(;
        id = component_id(refs, value),
        input_code_1 = get_input_code_1(value),
        remote_bus_control_1 = get_remote_bus_control_1(value),
        input_code_2 = get_input_code_2(value),
        remote_bus_control_2 = get_remote_bus_control_2(value),
        m_rtf = get_M_rtf(value),
        n_rtf = get_N_rtf(value),
        tw1 = get_Tw1(value),
        tw2 = get_Tw2(value),
        t6 = get_T6(value),
        tw3 = get_Tw3(value),
        tw4 = get_Tw4(value),
        t7 = get_T7(value),
        ks2 = get_Ks2(value),
        ks3 = get_Ks3(value),
        t8 = get_T8(value),
        t9 = get_T9(value),
        ks1 = get_Ks1(value),
        t1 = get_T1(value),
        t2 = get_T2(value),
        t3 = get_T3(value),
        t4 = get_T4(value),
        t10 = get_T10(value),
        t11 = get_T11(value),
        vs1_lim = _psy_to_wire(get_Vs1_lim(value)),
        vs2_lim = _psy_to_wire(get_Vs2_lim(value)),
        vst_lim = _psy_to_wire(get_Vst_lim(value)),
        t12 = get_T12(value),
        t13 = get_T13(value),
        pss_hysteresis_param = _psy_to_wire(get_PSS_Hysteresis_param(value)),
        xcomp = get_Xcomp(value),
        tcomp = get_Tcomp(value),
        hysteresis_binary_logic = get_hysteresis_binary_logic(value),
    )
end
