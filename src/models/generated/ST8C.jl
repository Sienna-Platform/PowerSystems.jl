#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ST8C <: AVR
        OEL_Flag::Int
        UEL_Flag::Int
        SCL_Flag::Int
        SW1_Flag::Int
        Tr::Float64
        K_pr::Float64
        K_ir::Float64
        Vpi_lim::MinMax
        K_pa::Float64
        K_ia::Float64
        Va_lim::MinMax
        K_a::Float64
        T_a::Float64
        Vr_lim::MinMax
        K_f::Float64
        T_f::Float64
        K_c1::Float64
        K_p::Float64
        K_i1::Float64
        X_l::Float64
        θ_p::Float64
        VB1_max::Float64
        K_c2::Float64
        K_i2::Float64
        VB2_max::Float64
        V_ref::Float64
        Ifd_ref::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
        states_types::Vector{StateTypes.Value}
        internal::InfrastructureSystemsInternal
    end

In these excitation systems, voltage (and also current in compounded systems) is transformed to an appropriate level. Rectifiers, either controlled or non-controlled, provide the necessary direct current for the generator field.
Parameters of IEEE Std 421.5 Type ST8C Excitacion System. ST8C in PSSE and PSLF

# Arguments
- `OEL_Flag::Int`: OEL Flag for ST8C: <2: Summation at Voltage Error, 2: OEL takeover at gate, validation range: `(0, 2)`
- `UEL_Flag::Int`: UEL Flag for ST8C: <2: Summation at Voltage Error, 2: UEL takeover at gate, validation range: `(0, 2)`
- `SCL_Flag::Int`: SCL Flag for ST8C: <2: Summation at Voltage Error, 2: SCL Takeover at UEL and OEL gates, validation range: `(0, 2)`
- `SW1_Flag::Int`: SW1 Flag for Power Source Selector for ST8C: <2: Source from generator terminal voltage, 2: Independent power source, validation range: `(0, 2)`
- `Tr::Float64`: Regulator input filter time constant in seconds, validation range: `(0, nothing)`
- `K_pr::Float64`: Regulator proportional gain (pu), validation range: `(0, nothing)`
- `K_ir::Float64`: Regulator integral gain (pu), validation range: `(0, nothing)`
- `Vpi_lim::MinMax`: Regulator input limits (Vpi_min, Vpi_max)
- `K_pa::Float64`: Field current regulator proportional gain (pu), validation range: `(0, nothing)`
- `K_ia::Float64`: Field current regulator integral gain (pu), validation range: `(0, nothing)`
- `Va_lim::MinMax`: Field current regulator output limits (Va_min, Va_max)
- `K_a::Float64`: Field current regulator proportional gain (pu), validation range: `(0, nothing)`
- `T_a::Float64`: Controlled rectifier bridge equivalent time constant in seconds, validation range: `(0, nothing)`
- `Vr_lim::MinMax`: Voltage regulator limits (Vr_min, Vr_max)
- `K_f::Float64`: Exciter field current feedback gain (pu), validation range: `(0, nothing)`
- `T_f::Float64`: Field current feedback time constant in seconds, validation range: `(0, nothing)`
- `K_c1::Float64`: Rectifier loading factor proportional to commutating reactance (pu), validation range: `(0, nothing)`
- `K_p::Float64`: Potential circuit (voltage) gain coefficient (pu), validation range: `(0, nothing)`
- `K_i1::Float64`: Potential circuit (current) gain coefficient (pu), validation range: `(0, nothing)`
- `X_l::Float64`: Reactance associated with potential source (pu), validation range: `(0, nothing)`
- `θ_p::Float64`: Potential circuit phase angle (degrees), validation range: `(0, nothing)`
- `VB1_max::Float64`: Maximum available exciter voltage (pu), validation range: `(0, nothing)`
- `K_c2::Float64`: Rectifier loading factor proportional to commutating reactance (pu), validation range: `(0, nothing)`
- `K_i2::Float64`: Potential circuit (current) gain coefficient (pu), validation range: `(0, nothing)`
- `VB2_max::Float64`: Maximum available exciter voltage (pu), validation range: `(0, nothing)`
- `V_ref::Float64`: (default: `1.0`) Reference Voltage Set-point (pu), validation range: `(0, nothing)`
- `Ifd_ref::Float64`: (default: `1.0`) Reference Field Current Set-point (pu), validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	x_a1: Regulator Integrator state,
	x_a2: Field Current regulator state,
	x_a3: Controller rectifier bridge state,
	x_a4: Regulator Feedback state
- `n_states::Int`: (**Do not modify.**) ST8C has 5 states
- `states_types::Vector{StateTypes.Value}`: (**Do not modify.**) ST8C has 5 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ST8C <: AVR
    "OEL Flag for ST8C: <2: Summation at Voltage Error, 2: OEL takeover at gate"
    OEL_Flag::Int
    "UEL Flag for ST8C: <2: Summation at Voltage Error, 2: UEL takeover at gate"
    UEL_Flag::Int
    "SCL Flag for ST8C: <2: Summation at Voltage Error, 2: SCL Takeover at UEL and OEL gates"
    SCL_Flag::Int
    "SW1 Flag for Power Source Selector for ST8C: <2: Source from generator terminal voltage, 2: Independent power source"
    SW1_Flag::Int
    "Regulator input filter time constant in seconds"
    Tr::Float64
    "Regulator proportional gain (pu)"
    K_pr::Float64
    "Regulator integral gain (pu)"
    K_ir::Float64
    "Regulator input limits (Vpi_min, Vpi_max)"
    Vpi_lim::MinMax
    "Field current regulator proportional gain (pu)"
    K_pa::Float64
    "Field current regulator integral gain (pu)"
    K_ia::Float64
    "Field current regulator output limits (Va_min, Va_max)"
    Va_lim::MinMax
    "Field current regulator proportional gain (pu)"
    K_a::Float64
    "Controlled rectifier bridge equivalent time constant in seconds"
    T_a::Float64
    "Voltage regulator limits (Vr_min, Vr_max)"
    Vr_lim::MinMax
    "Exciter field current feedback gain (pu)"
    K_f::Float64
    "Field current feedback time constant in seconds"
    T_f::Float64
    "Rectifier loading factor proportional to commutating reactance (pu)"
    K_c1::Float64
    "Potential circuit (voltage) gain coefficient (pu)"
    K_p::Float64
    "Potential circuit (current) gain coefficient (pu)"
    K_i1::Float64
    "Reactance associated with potential source (pu)"
    X_l::Float64
    "Potential circuit phase angle (degrees)"
    θ_p::Float64
    "Maximum available exciter voltage (pu)"
    VB1_max::Float64
    "Rectifier loading factor proportional to commutating reactance (pu)"
    K_c2::Float64
    "Potential circuit (current) gain coefficient (pu)"
    K_i2::Float64
    "Maximum available exciter voltage (pu)"
    VB2_max::Float64
    "Reference Voltage Set-point (pu)"
    V_ref::Float64
    "Reference Field Current Set-point (pu)"
    Ifd_ref::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) are:
	Vm: Sensed terminal voltage,
	x_a1: Regulator Integrator state,
	x_a2: Field Current regulator state,
	x_a3: Controller rectifier bridge state,
	x_a4: Regulator Feedback state"
    states::Vector{Symbol}
    "(**Do not modify.**) ST8C has 5 states"
    n_states::Int
    "(**Do not modify.**) ST8C has 5 states"
    states_types::Vector{StateTypes.Value}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ST8C(OEL_Flag, UEL_Flag, SCL_Flag, SW1_Flag, Tr, K_pr, K_ir, Vpi_lim, K_pa, K_ia, Va_lim, K_a, T_a, Vr_lim, K_f, T_f, K_c1, K_p, K_i1, X_l, θ_p, VB1_max, K_c2, K_i2, VB2_max, V_ref=1.0, Ifd_ref=1.0, ext=Dict{String, Any}(), )
    ST8C(OEL_Flag, UEL_Flag, SCL_Flag, SW1_Flag, Tr, K_pr, K_ir, Vpi_lim, K_pa, K_ia, Va_lim, K_a, T_a, Vr_lim, K_f, T_f, K_c1, K_p, K_i1, X_l, θ_p, VB1_max, K_c2, K_i2, VB2_max, V_ref, Ifd_ref, ext, [:Vm, :x_a1, :x_a2, :x_a3, :x_a4], 5, [StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], InfrastructureSystemsInternal(), )
end

function ST8C(; OEL_Flag, UEL_Flag, SCL_Flag, SW1_Flag, Tr, K_pr, K_ir, Vpi_lim, K_pa, K_ia, Va_lim, K_a, T_a, Vr_lim, K_f, T_f, K_c1, K_p, K_i1, X_l, θ_p, VB1_max, K_c2, K_i2, VB2_max, V_ref=1.0, Ifd_ref=1.0, ext=Dict{String, Any}(), states=[:Vm, :x_a1, :x_a2, :x_a3, :x_a4], n_states=5, states_types=[StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid, StateTypes.Hybrid], internal=InfrastructureSystemsInternal(), )
    ST8C(OEL_Flag, UEL_Flag, SCL_Flag, SW1_Flag, Tr, K_pr, K_ir, Vpi_lim, K_pa, K_ia, Va_lim, K_a, T_a, Vr_lim, K_f, T_f, K_c1, K_p, K_i1, X_l, θ_p, VB1_max, K_c2, K_i2, VB2_max, V_ref, Ifd_ref, ext, states, n_states, states_types, internal, )
end

# Constructor for demo purposes; non-functional.
function ST8C(::Nothing)
    ST8C(;
        OEL_Flag=0,
        UEL_Flag=0,
        SCL_Flag=0,
        SW1_Flag=0,
        Tr=0,
        K_pr=0,
        K_ir=0,
        Vpi_lim=(min=0.0, max=0.0),
        K_pa=0,
        K_ia=0,
        Va_lim=(min=0.0, max=0.0),
        K_a=0,
        T_a=0,
        Vr_lim=(min=0.0, max=0.0),
        K_f=0,
        T_f=0,
        K_c1=0,
        K_p=0,
        K_i1=0,
        X_l=0,
        θ_p=0,
        VB1_max=0,
        K_c2=0,
        K_i2=0,
        VB2_max=0,
        V_ref=0,
        Ifd_ref=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ST8C`](@ref) `OEL_Flag`."""
get_OEL_Flag(value::ST8C) = value.OEL_Flag
"""Get [`ST8C`](@ref) `UEL_Flag`."""
get_UEL_Flag(value::ST8C) = value.UEL_Flag
"""Get [`ST8C`](@ref) `SCL_Flag`."""
get_SCL_Flag(value::ST8C) = value.SCL_Flag
"""Get [`ST8C`](@ref) `SW1_Flag`."""
get_SW1_Flag(value::ST8C) = value.SW1_Flag
"""Get [`ST8C`](@ref) `Tr`."""
get_Tr(value::ST8C) = value.Tr
"""Get [`ST8C`](@ref) `K_pr`."""
get_K_pr(value::ST8C) = value.K_pr
"""Get [`ST8C`](@ref) `K_ir`."""
get_K_ir(value::ST8C) = value.K_ir
"""Get [`ST8C`](@ref) `Vpi_lim`."""
get_Vpi_lim(value::ST8C) = value.Vpi_lim
"""Get [`ST8C`](@ref) `K_pa`."""
get_K_pa(value::ST8C) = value.K_pa
"""Get [`ST8C`](@ref) `K_ia`."""
get_K_ia(value::ST8C) = value.K_ia
"""Get [`ST8C`](@ref) `Va_lim`."""
get_Va_lim(value::ST8C) = value.Va_lim
"""Get [`ST8C`](@ref) `K_a`."""
get_K_a(value::ST8C) = value.K_a
"""Get [`ST8C`](@ref) `T_a`."""
get_T_a(value::ST8C) = value.T_a
"""Get [`ST8C`](@ref) `Vr_lim`."""
get_Vr_lim(value::ST8C) = value.Vr_lim
"""Get [`ST8C`](@ref) `K_f`."""
get_K_f(value::ST8C) = value.K_f
"""Get [`ST8C`](@ref) `T_f`."""
get_T_f(value::ST8C) = value.T_f
"""Get [`ST8C`](@ref) `K_c1`."""
get_K_c1(value::ST8C) = value.K_c1
"""Get [`ST8C`](@ref) `K_p`."""
get_K_p(value::ST8C) = value.K_p
"""Get [`ST8C`](@ref) `K_i1`."""
get_K_i1(value::ST8C) = value.K_i1
"""Get [`ST8C`](@ref) `X_l`."""
get_X_l(value::ST8C) = value.X_l
"""Get [`ST8C`](@ref) `θ_p`."""
get_θ_p(value::ST8C) = value.θ_p
"""Get [`ST8C`](@ref) `VB1_max`."""
get_VB1_max(value::ST8C) = value.VB1_max
"""Get [`ST8C`](@ref) `K_c2`."""
get_K_c2(value::ST8C) = value.K_c2
"""Get [`ST8C`](@ref) `K_i2`."""
get_K_i2(value::ST8C) = value.K_i2
"""Get [`ST8C`](@ref) `VB2_max`."""
get_VB2_max(value::ST8C) = value.VB2_max
"""Get [`ST8C`](@ref) `V_ref`."""
get_V_ref(value::ST8C) = value.V_ref
"""Get [`ST8C`](@ref) `Ifd_ref`."""
get_Ifd_ref(value::ST8C) = value.Ifd_ref
"""Get [`ST8C`](@ref) `ext`."""
get_ext(value::ST8C) = value.ext
"""Get [`ST8C`](@ref) `states`."""
get_states(value::ST8C) = value.states
"""Get [`ST8C`](@ref) `n_states`."""
get_n_states(value::ST8C) = value.n_states
"""Get [`ST8C`](@ref) `states_types`."""
get_states_types(value::ST8C) = value.states_types
"""Get [`ST8C`](@ref) `internal`."""
get_internal(value::ST8C) = value.internal

"""Set [`ST8C`](@ref) `OEL_Flag`."""
set_OEL_Flag!(value::ST8C, val) = value.OEL_Flag = val
"""Set [`ST8C`](@ref) `UEL_Flag`."""
set_UEL_Flag!(value::ST8C, val) = value.UEL_Flag = val
"""Set [`ST8C`](@ref) `SCL_Flag`."""
set_SCL_Flag!(value::ST8C, val) = value.SCL_Flag = val
"""Set [`ST8C`](@ref) `SW1_Flag`."""
set_SW1_Flag!(value::ST8C, val) = value.SW1_Flag = val
"""Set [`ST8C`](@ref) `Tr`."""
set_Tr!(value::ST8C, val) = value.Tr = val
"""Set [`ST8C`](@ref) `K_pr`."""
set_K_pr!(value::ST8C, val) = value.K_pr = val
"""Set [`ST8C`](@ref) `K_ir`."""
set_K_ir!(value::ST8C, val) = value.K_ir = val
"""Set [`ST8C`](@ref) `Vpi_lim`."""
set_Vpi_lim!(value::ST8C, val) = value.Vpi_lim = val
"""Set [`ST8C`](@ref) `K_pa`."""
set_K_pa!(value::ST8C, val) = value.K_pa = val
"""Set [`ST8C`](@ref) `K_ia`."""
set_K_ia!(value::ST8C, val) = value.K_ia = val
"""Set [`ST8C`](@ref) `Va_lim`."""
set_Va_lim!(value::ST8C, val) = value.Va_lim = val
"""Set [`ST8C`](@ref) `K_a`."""
set_K_a!(value::ST8C, val) = value.K_a = val
"""Set [`ST8C`](@ref) `T_a`."""
set_T_a!(value::ST8C, val) = value.T_a = val
"""Set [`ST8C`](@ref) `Vr_lim`."""
set_Vr_lim!(value::ST8C, val) = value.Vr_lim = val
"""Set [`ST8C`](@ref) `K_f`."""
set_K_f!(value::ST8C, val) = value.K_f = val
"""Set [`ST8C`](@ref) `T_f`."""
set_T_f!(value::ST8C, val) = value.T_f = val
"""Set [`ST8C`](@ref) `K_c1`."""
set_K_c1!(value::ST8C, val) = value.K_c1 = val
"""Set [`ST8C`](@ref) `K_p`."""
set_K_p!(value::ST8C, val) = value.K_p = val
"""Set [`ST8C`](@ref) `K_i1`."""
set_K_i1!(value::ST8C, val) = value.K_i1 = val
"""Set [`ST8C`](@ref) `X_l`."""
set_X_l!(value::ST8C, val) = value.X_l = val
"""Set [`ST8C`](@ref) `θ_p`."""
set_θ_p!(value::ST8C, val) = value.θ_p = val
"""Set [`ST8C`](@ref) `VB1_max`."""
set_VB1_max!(value::ST8C, val) = value.VB1_max = val
"""Set [`ST8C`](@ref) `K_c2`."""
set_K_c2!(value::ST8C, val) = value.K_c2 = val
"""Set [`ST8C`](@ref) `K_i2`."""
set_K_i2!(value::ST8C, val) = value.K_i2 = val
"""Set [`ST8C`](@ref) `VB2_max`."""
set_VB2_max!(value::ST8C, val) = value.VB2_max = val
"""Set [`ST8C`](@ref) `V_ref`."""
set_V_ref!(value::ST8C, val) = value.V_ref = val
"""Set [`ST8C`](@ref) `Ifd_ref`."""
set_Ifd_ref!(value::ST8C, val) = value.Ifd_ref = val
"""Set [`ST8C`](@ref) `ext`."""
set_ext!(value::ST8C, val) = value.ext = val
"""Set [`ST8C`](@ref) `states_types`."""
set_states_types!(value::ST8C, val) = value.states_types = val
