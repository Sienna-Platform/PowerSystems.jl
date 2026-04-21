#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ActiveConstantPowerLoad <: DynamicInjection
        name::String
        r_load::Float64
        c_dc::Float64
        rf::Float64
        lf::Float64
        cf::Float64
        rg::Float64
        lg::Float64
        kp_pll::Float64
        ki_pll::Float64
        kpv::Float64
        kiv::Float64
        kpc::Float64
        kic::Float64
        base_power::Float64
        ext::Dict{String, Any}
        P_ref::Float64
        Q_ref::Float64
        V_ref::Float64
        ω_ref::Float64
        is_filter_differential::Int
        states::Vector{Symbol}
        n_states::Int
        internal::InfrastructureSystemsInternal
    end

Parameters of 12-[states](@ref S) active power load based on the paper, ["Dynamic Stability of a Microgrid With an Active Load."](https://doi.org/10.1109/TPEL.2013.2241455)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `r_load::Float64`: DC-side resistor, validation range: `(0, nothing)`
- `c_dc::Float64`: DC-side capacitor, validation range: `(0, nothing)`
- `rf::Float64`: Converter side filter resistance, validation range: `(0, nothing)`
- `lf::Float64`: Converter side filter inductance, validation range: `(0, nothing)`
- `cf::Float64`: AC Converter filter capacitance, validation range: `(0, nothing)`
- `rg::Float64`: Network side filter resistance, validation range: `(0, nothing)`
- `lg::Float64`: Network side filter inductance, validation range: `(0, nothing)`
- `kp_pll::Float64`: Proportional constant for PI-PLL block, validation range: `(0, nothing)`
- `ki_pll::Float64`: Integral constant for PI-PLL block, validation range: `(0, nothing)`
- `kpv::Float64`: Proportional constant for Voltage Control block, validation range: `(0, nothing)`
- `kiv::Float64`: Integral constant for Voltage Control block, validation range: `(0, nothing)`
- `kpc::Float64`: Proportional constant for Current Control block, validation range: `(0, nothing)`
- `kic::Float64`: Integral constant for Current Control block, validation range: `(0, nothing)`
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `P_ref::Float64`: Reference active power (pu)
- `Q_ref::Float64`: Reference reactive power (pu)
- `V_ref::Float64`: Reference voltage (pu)
- `ω_ref::Float64`: Reference frequency (pu)
- `is_filter_differential::Int`: Boolean to decide if filter [states](@ref S) are differential or algebraic
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) are:
	θ_pll: PLL deviation angle, 
	ϵ_pll: PLL integrator state, 
	η: DC-voltage controller integrator state, 
	v_dc: DC voltage at the capacitor, 
	γd: d-axis Current controller integrator state, 
	γq: q-axis Current controller integrator state, 
	ir_cnv: Real current out of the converter,
	ii_cnv: Imaginary current out of the converter,
	vr_filter: Real voltage at the filter's capacitor,
	vi_filter: Imaginary voltage at the filter's capacitor,
	ir_filter: Real current out of the filter,
	ii_filter: Imaginary current out of the filter
- `n_states::Int`: (**Do not modify.**) ActiveConstantPowerLoad has 12 states
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct ActiveConstantPowerLoad <: DynamicInjection
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "DC-side resistor"
    r_load::Float64
    "DC-side capacitor"
    c_dc::Float64
    "Converter side filter resistance"
    rf::Float64
    "Converter side filter inductance"
    lf::Float64
    "AC Converter filter capacitance"
    cf::Float64
    "Network side filter resistance"
    rg::Float64
    "Network side filter inductance"
    lg::Float64
    "Proportional constant for PI-PLL block"
    kp_pll::Float64
    "Integral constant for PI-PLL block"
    ki_pll::Float64
    "Proportional constant for Voltage Control block"
    kpv::Float64
    "Integral constant for Voltage Control block"
    kiv::Float64
    "Proportional constant for Current Control block"
    kpc::Float64
    "Integral constant for Current Control block"
    kic::Float64
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "Reference active power (pu)"
    P_ref::Float64
    "Reference reactive power (pu)"
    Q_ref::Float64
    "Reference voltage (pu)"
    V_ref::Float64
    "Reference frequency (pu)"
    ω_ref::Float64
    "Boolean to decide if filter [states](@ref S) are differential or algebraic"
    is_filter_differential::Int
    "(**Do not modify.**) The [states](@ref S) are:
	θ_pll: PLL deviation angle, 
	ϵ_pll: PLL integrator state, 
	η: DC-voltage controller integrator state, 
	v_dc: DC voltage at the capacitor, 
	γd: d-axis Current controller integrator state, 
	γq: q-axis Current controller integrator state, 
	ir_cnv: Real current out of the converter,
	ii_cnv: Imaginary current out of the converter,
	vr_filter: Real voltage at the filter's capacitor,
	vi_filter: Imaginary voltage at the filter's capacitor,
	ir_filter: Real current out of the filter,
	ii_filter: Imaginary current out of the filter"
    states::Vector{Symbol}
    "(**Do not modify.**) ActiveConstantPowerLoad has 12 states"
    n_states::Int
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function ActiveConstantPowerLoad(name, r_load, c_dc, rf, lf, cf, rg, lg, kp_pll, ki_pll, kpv, kiv, kpc, kic, base_power, ext=Dict{String, Any}(), )
    ActiveConstantPowerLoad(name, r_load, c_dc, rf, lf, cf, rg, lg, kp_pll, ki_pll, kpv, kiv, kpc, kic, base_power, ext, 1.0, 1.0, 1.0, 1.0, 1, [:θ_pll, :ϵ_pll, :η, :v_dc, :γd, :γq, :ir_cnv, :ii_cnv, :vr_filter, :vi_filter, :ir_filter, :ii_filter], 12, InfrastructureSystemsInternal(), )
end

function ActiveConstantPowerLoad(; name, r_load, c_dc, rf, lf, cf, rg, lg, kp_pll, ki_pll, kpv, kiv, kpc, kic, base_power, ext=Dict{String, Any}(), P_ref=1.0, Q_ref=1.0, V_ref=1.0, ω_ref=1.0, is_filter_differential=1, states=[:θ_pll, :ϵ_pll, :η, :v_dc, :γd, :γq, :ir_cnv, :ii_cnv, :vr_filter, :vi_filter, :ir_filter, :ii_filter], n_states=12, internal=InfrastructureSystemsInternal(), )
    ActiveConstantPowerLoad(name, r_load, c_dc, rf, lf, cf, rg, lg, kp_pll, ki_pll, kpv, kiv, kpc, kic, base_power, ext, P_ref, Q_ref, V_ref, ω_ref, is_filter_differential, states, n_states, internal, )
end

# Constructor for demo purposes; non-functional.
function ActiveConstantPowerLoad(::Nothing)
    ActiveConstantPowerLoad(;
        name="init",
        r_load=0,
        c_dc=0,
        rf=0,
        lf=0,
        cf=0,
        rg=0,
        lg=0,
        kp_pll=0,
        ki_pll=0,
        kpv=0,
        kiv=0,
        kpc=0,
        kic=0,
        base_power=100,
        ext=Dict{String, Any}(),
    )
end

"""Get [`ActiveConstantPowerLoad`](@ref) `name`."""
get_name(value::ActiveConstantPowerLoad) = value.name
"""Get [`ActiveConstantPowerLoad`](@ref) `r_load`."""
get_r_load(value::ActiveConstantPowerLoad) = value.r_load
"""Get [`ActiveConstantPowerLoad`](@ref) `c_dc`."""
get_c_dc(value::ActiveConstantPowerLoad) = value.c_dc
"""Get [`ActiveConstantPowerLoad`](@ref) `rf`."""
get_rf(value::ActiveConstantPowerLoad) = value.rf
"""Get [`ActiveConstantPowerLoad`](@ref) `lf`."""
get_lf(value::ActiveConstantPowerLoad) = value.lf
"""Get [`ActiveConstantPowerLoad`](@ref) `cf`."""
get_cf(value::ActiveConstantPowerLoad) = value.cf
"""Get [`ActiveConstantPowerLoad`](@ref) `rg`."""
get_rg(value::ActiveConstantPowerLoad) = value.rg
"""Get [`ActiveConstantPowerLoad`](@ref) `lg`."""
get_lg(value::ActiveConstantPowerLoad) = value.lg
"""Get [`ActiveConstantPowerLoad`](@ref) `kp_pll`."""
get_kp_pll(value::ActiveConstantPowerLoad) = value.kp_pll
"""Get [`ActiveConstantPowerLoad`](@ref) `ki_pll`."""
get_ki_pll(value::ActiveConstantPowerLoad) = value.ki_pll
"""Get [`ActiveConstantPowerLoad`](@ref) `kpv`."""
get_kpv(value::ActiveConstantPowerLoad) = value.kpv
"""Get [`ActiveConstantPowerLoad`](@ref) `kiv`."""
get_kiv(value::ActiveConstantPowerLoad) = value.kiv
"""Get [`ActiveConstantPowerLoad`](@ref) `kpc`."""
get_kpc(value::ActiveConstantPowerLoad) = value.kpc
"""Get [`ActiveConstantPowerLoad`](@ref) `kic`."""
get_kic(value::ActiveConstantPowerLoad) = value.kic

_get_base_power(value::ActiveConstantPowerLoad) = value.base_power
"""Get [`ActiveConstantPowerLoad`](@ref) `ext`."""
get_ext(value::ActiveConstantPowerLoad) = value.ext
"""Get [`ActiveConstantPowerLoad`](@ref) `P_ref`."""
get_P_ref(value::ActiveConstantPowerLoad) = value.P_ref
"""Get [`ActiveConstantPowerLoad`](@ref) `Q_ref`."""
get_Q_ref(value::ActiveConstantPowerLoad) = value.Q_ref
"""Get [`ActiveConstantPowerLoad`](@ref) `V_ref`."""
get_V_ref(value::ActiveConstantPowerLoad) = value.V_ref
"""Get [`ActiveConstantPowerLoad`](@ref) `ω_ref`."""
get_ω_ref(value::ActiveConstantPowerLoad) = value.ω_ref
"""Get [`ActiveConstantPowerLoad`](@ref) `is_filter_differential`."""
get_is_filter_differential(value::ActiveConstantPowerLoad) = value.is_filter_differential
"""Get [`ActiveConstantPowerLoad`](@ref) `states`."""
get_states(value::ActiveConstantPowerLoad) = value.states
"""Get [`ActiveConstantPowerLoad`](@ref) `n_states`."""
get_n_states(value::ActiveConstantPowerLoad) = value.n_states
"""Get [`ActiveConstantPowerLoad`](@ref) `internal`."""
get_internal(value::ActiveConstantPowerLoad) = value.internal

"""Set [`ActiveConstantPowerLoad`](@ref) `r_load`."""
set_r_load!(value::ActiveConstantPowerLoad, val) = value.r_load = val
"""Set [`ActiveConstantPowerLoad`](@ref) `c_dc`."""
set_c_dc!(value::ActiveConstantPowerLoad, val) = value.c_dc = val
"""Set [`ActiveConstantPowerLoad`](@ref) `rf`."""
set_rf!(value::ActiveConstantPowerLoad, val) = value.rf = val
"""Set [`ActiveConstantPowerLoad`](@ref) `lf`."""
set_lf!(value::ActiveConstantPowerLoad, val) = value.lf = val
"""Set [`ActiveConstantPowerLoad`](@ref) `cf`."""
set_cf!(value::ActiveConstantPowerLoad, val) = value.cf = val
"""Set [`ActiveConstantPowerLoad`](@ref) `rg`."""
set_rg!(value::ActiveConstantPowerLoad, val) = value.rg = val
"""Set [`ActiveConstantPowerLoad`](@ref) `lg`."""
set_lg!(value::ActiveConstantPowerLoad, val) = value.lg = val
"""Set [`ActiveConstantPowerLoad`](@ref) `kp_pll`."""
set_kp_pll!(value::ActiveConstantPowerLoad, val) = value.kp_pll = val
"""Set [`ActiveConstantPowerLoad`](@ref) `ki_pll`."""
set_ki_pll!(value::ActiveConstantPowerLoad, val) = value.ki_pll = val
"""Set [`ActiveConstantPowerLoad`](@ref) `kpv`."""
set_kpv!(value::ActiveConstantPowerLoad, val) = value.kpv = val
"""Set [`ActiveConstantPowerLoad`](@ref) `kiv`."""
set_kiv!(value::ActiveConstantPowerLoad, val) = value.kiv = val
"""Set [`ActiveConstantPowerLoad`](@ref) `kpc`."""
set_kpc!(value::ActiveConstantPowerLoad, val) = value.kpc = val
"""Set [`ActiveConstantPowerLoad`](@ref) `kic`."""
set_kic!(value::ActiveConstantPowerLoad, val) = value.kic = val
"""Set [`ActiveConstantPowerLoad`](@ref) `base_power`."""
set_base_power!(value::ActiveConstantPowerLoad, val) = value.base_power = val
"""Set [`ActiveConstantPowerLoad`](@ref) `ext`."""
set_ext!(value::ActiveConstantPowerLoad, val) = value.ext = val
"""Set [`ActiveConstantPowerLoad`](@ref) `P_ref`."""
set_P_ref!(value::ActiveConstantPowerLoad, val) = value.P_ref = val
"""Set [`ActiveConstantPowerLoad`](@ref) `Q_ref`."""
set_Q_ref!(value::ActiveConstantPowerLoad, val) = value.Q_ref = val
"""Set [`ActiveConstantPowerLoad`](@ref) `V_ref`."""
set_V_ref!(value::ActiveConstantPowerLoad, val) = value.V_ref = val
"""Set [`ActiveConstantPowerLoad`](@ref) `ω_ref`."""
set_ω_ref!(value::ActiveConstantPowerLoad, val) = value.ω_ref = val
"""Set [`ActiveConstantPowerLoad`](@ref) `is_filter_differential`."""
set_is_filter_differential!(value::ActiveConstantPowerLoad, val) = value.is_filter_differential = val
