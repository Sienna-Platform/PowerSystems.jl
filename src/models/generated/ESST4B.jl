#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ESST4B <: AVR
        Tr::Float64
        K_pr::Float64
        K_ir::Float64
        Vr_lim::MinMax
        Ta::Float64
        K_pm::Float64
        K_im::Float64
        Vm_lim::MinMax
        Kg::Float64
        Kp::Float64
        Ki::Float64
        VB_max::Float64
        Kc::Float64
        Xl::Float64
        θp::Float64
        V_ref::Float64
        θp_rad::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

In these excitation systems, voltage (and also current in compounded systems) is transformed to an appropriate level. Rectifiers, either controlled or non-controlled, provide the necessary direct current for the generator field.
Parameters of IEEE Std 421.5 Type ST4B Excitacion System. ESST4B in PSSE and PSLF

# Arguments
- `Tr::Float64`: Regulator input filter time constant in s, validation range: `(0, 0.5)`
- `K_pr::Float64`: Regulator propotional gain, validation range: `(0, 75)`
- `K_ir::Float64`: Regulator integral gain, validation range: `(0, 75)`
- `Vr_lim::MinMax`: Voltage regulator limits (Vi_min, Vi_max)
- `Ta::Float64`: Voltage regulator time constant in s, validation range: `(0, 1)`
- `K_pm::Float64`: Voltage regulator proportional gain output, validation range: `(0, 1.2)`
- `K_im::Float64`: Voltage regulator integral gain output, validation range: `(0, 18)`
- `Vm_lim::MinMax`: Limits for inner loop output `(Vm_min, Vm_max)`
- `Kg::Float64`: Feedback gain constant of the inner loop field regulator, validation range: `(0, 1.1)`
- `Kp::Float64`: Potential circuit (voltage) gain coefficient, validation range: `(0, 10)`
- `Ki::Float64`: Compound circuit (current) gain coefficient, validation range: `(0, 1.1)`
- `VB_max::Float64`: Maximum available exciter voltage, validation range: `(1, 20)`
- `Kc::Float64`: Rectifier loading factor proportional to commutating reactance, validation range: `(0, 1)`
- `Xl::Float64`: Reactance associated with potential source, validation range: `(0, 0.5)`
- `θp::Float64`: Potential circuit phase angle (degrees), validation range: `(-90, 90)`
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `θp_rad::Float64`: (default: `θp*π*inv(180)`) (**Do not modify.**) Potential circuit phase angle (radians)
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	Vt: Sensed Terminal Voltage,
	Vr1: Regulator Integrator,
	Vr2: Regulator Output,
	Vm: Output integrator
- `n_states::Int`: (**Do not modify.**) ST4B has 4 states
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) ST4B has 4 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ESST4B <: AVR
    "Regulator input filter time constant in s"
    Tr::Float64
    "Regulator propotional gain"
    K_pr::Float64
    "Regulator integral gain"
    K_ir::Float64
    "Voltage regulator limits (Vi_min, Vi_max)"
    Vr_lim::MinMax
    "Voltage regulator time constant in s"
    Ta::Float64
    "Voltage regulator proportional gain output"
    K_pm::Float64
    "Voltage regulator integral gain output"
    K_im::Float64
    "Limits for inner loop output `(Vm_min, Vm_max)`"
    Vm_lim::MinMax
    "Feedback gain constant of the inner loop field regulator"
    Kg::Float64
    "Potential circuit (voltage) gain coefficient"
    Kp::Float64
    "Compound circuit (current) gain coefficient"
    Ki::Float64
    "Maximum available exciter voltage"
    VB_max::Float64
    "Rectifier loading factor proportional to commutating reactance"
    Kc::Float64
    "Reactance associated with potential source"
    Xl::Float64
    "Potential circuit phase angle (degrees)"
    θp::Float64
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "(**Do not modify.**) Potential circuit phase angle (radians)"
    θp_rad::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	Vt: Sensed Terminal Voltage,
	Vr1: Regulator Integrator,
	Vr2: Regulator Output,
	Vm: Output integrator"
    states::Vector{Symbol}
    "(**Do not modify.**) ST4B has 4 states"
    n_states::Int
    "(**Do not modify.**) ST4B has 4 states"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ESST4B(Tr, K_pr, K_ir, Vr_lim, Ta, K_pm, K_im, Vm_lim, Kg, Kp, Ki, VB_max, Kc, Xl, θp, V_ref=1.0, θp_rad=θp*π*inv(180), ext=Dict{String, Any}(), )
    ESST4B(Tr, K_pr, K_ir, Vr_lim, Ta, K_pm, K_im, Vm_lim, Kg, Kp, Ki, VB_max, Kc, Xl, θp, V_ref, θp_rad, ext, [:Vt, :Vr1, :Vr2, :Vm], 4, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], InfrastructureSystemsInternal(), )
end

function ESST4B(; Tr, K_pr, K_ir, Vr_lim, Ta, K_pm, K_im, Vm_lim, Kg, Kp, Ki, VB_max, Kc, Xl, θp, V_ref=1.0, θp_rad=θp*π*inv(180), ext=Dict{String, Any}(), states=[:Vt, :Vr1, :Vr2, :Vm], n_states=4, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], internal=InfrastructureSystemsInternal(), )
    ESST4B(Tr, K_pr, K_ir, Vr_lim, Ta, K_pm, K_im, Vm_lim, Kg, Kp, Ki, VB_max, Kc, Xl, θp, V_ref, θp_rad, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function ESST4B(::Nothing)
    ESST4B(;
        Tr=0,
        K_pr=0,
        K_ir=0,
        Vr_lim=(min=0.0, max=0.0),
        Ta=0,
        K_pm=0,
        K_im=0,
        Vm_lim=(min=0.0, max=0.0),
        Kg=0,
        Kp=0,
        Ki=0,
        VB_max=0,
        Kc=0,
        Xl=0,
        θp=0,
        V_ref=0,
        θp_rad=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ESST4B`](@ref) `Tr`."""
get_Tr(value::ESST4B) = value.Tr
"""Get [`ESST4B`](@ref) `K_pr`."""
get_K_pr(value::ESST4B) = value.K_pr
"""Get [`ESST4B`](@ref) `K_ir`."""
get_K_ir(value::ESST4B) = value.K_ir
"""Get [`ESST4B`](@ref) `Vr_lim`."""
get_Vr_lim(value::ESST4B) = value.Vr_lim
"""Get [`ESST4B`](@ref) `Ta`."""
get_Ta(value::ESST4B) = value.Ta
"""Get [`ESST4B`](@ref) `K_pm`."""
get_K_pm(value::ESST4B) = value.K_pm
"""Get [`ESST4B`](@ref) `K_im`."""
get_K_im(value::ESST4B) = value.K_im
"""Get [`ESST4B`](@ref) `Vm_lim`."""
get_Vm_lim(value::ESST4B) = value.Vm_lim
"""Get [`ESST4B`](@ref) `Kg`."""
get_Kg(value::ESST4B) = value.Kg
"""Get [`ESST4B`](@ref) `Kp`."""
get_Kp(value::ESST4B) = value.Kp
"""Get [`ESST4B`](@ref) `Ki`."""
get_Ki(value::ESST4B) = value.Ki
"""Get [`ESST4B`](@ref) `VB_max`."""
get_VB_max(value::ESST4B) = value.VB_max
"""Get [`ESST4B`](@ref) `Kc`."""
get_Kc(value::ESST4B) = value.Kc
"""Get [`ESST4B`](@ref) `Xl`."""
get_Xl(value::ESST4B) = value.Xl
"""Get [`ESST4B`](@ref) `θp`."""
get_θp(value::ESST4B) = value.θp
"""Get [`ESST4B`](@ref) `V_ref`."""
get_V_ref(value::ESST4B) = value.V_ref
"""Get [`ESST4B`](@ref) `θp_rad`."""
get_θp_rad(value::ESST4B) = value.θp_rad
"""Get [`ESST4B`](@ref) `ext`."""
get_ext(value::ESST4B) = value.ext
"""Get [`ESST4B`](@ref) `states`."""
get_states(value::ESST4B) = value.states
"""Get [`ESST4B`](@ref) `n_states`."""
get_n_states(value::ESST4B) = value.n_states
"""Get [`ESST4B`](@ref) `states_types`."""
get_states_types(value::ESST4B) = value.states_types
"""Get [`ESST4B`](@ref) `internal`."""
get_internal(value::ESST4B) = value.internal

"""Set [`ESST4B`](@ref) `Tr`."""
set_Tr!(value::ESST4B, val) = value.Tr = val
"""Set [`ESST4B`](@ref) `K_pr`."""
set_K_pr!(value::ESST4B, val) = value.K_pr = val
"""Set [`ESST4B`](@ref) `K_ir`."""
set_K_ir!(value::ESST4B, val) = value.K_ir = val
"""Set [`ESST4B`](@ref) `Vr_lim`."""
set_Vr_lim!(value::ESST4B, val) = value.Vr_lim = val
"""Set [`ESST4B`](@ref) `Ta`."""
set_Ta!(value::ESST4B, val) = value.Ta = val
"""Set [`ESST4B`](@ref) `K_pm`."""
set_K_pm!(value::ESST4B, val) = value.K_pm = val
"""Set [`ESST4B`](@ref) `K_im`."""
set_K_im!(value::ESST4B, val) = value.K_im = val
"""Set [`ESST4B`](@ref) `Vm_lim`."""
set_Vm_lim!(value::ESST4B, val) = value.Vm_lim = val
"""Set [`ESST4B`](@ref) `Kg`."""
set_Kg!(value::ESST4B, val) = value.Kg = val
"""Set [`ESST4B`](@ref) `Kp`."""
set_Kp!(value::ESST4B, val) = value.Kp = val
"""Set [`ESST4B`](@ref) `Ki`."""
set_Ki!(value::ESST4B, val) = value.Ki = val
"""Set [`ESST4B`](@ref) `VB_max`."""
set_VB_max!(value::ESST4B, val) = value.VB_max = val
"""Set [`ESST4B`](@ref) `Kc`."""
set_Kc!(value::ESST4B, val) = value.Kc = val
"""Set [`ESST4B`](@ref) `Xl`."""
set_Xl!(value::ESST4B, val) = value.Xl = val
"""Set [`ESST4B`](@ref) `θp`."""
set_θp!(value::ESST4B, val) = value.θp = val
"""Set [`ESST4B`](@ref) `V_ref`."""
set_V_ref!(value::ESST4B, val) = value.V_ref = val
"""Set [`ESST4B`](@ref) `θp_rad`."""
set_θp_rad!(value::ESST4B, val) = value.θp_rad = val
"""Set [`ESST4B`](@ref) `ext`."""
set_ext!(value::ESST4B, val) = value.ext = val
"""Set [`ESST4B`](@ref) `states_types`."""
set_states_types!(value::ESST4B, val) = value.states_types = val
