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
        P_ref::Float64
        Q_ref::Float64
        V_ref::Float64
        frequency_ref::Float64
        is_filter_differential::Bool
        base_power::Float64
        ext::Dict{String, Any}
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
- `P_ref::Float64`: Reference active power (pu)
- `Q_ref::Float64`: Reference reactive power (pu)
- `V_ref::Float64`: Reference voltage (pu)
- `frequency_ref::Float64`: Reference frequency in Hz
- `is_filter_differential::Bool`: Boolean to decide if filter [states](@ref S) are differential or algebraic
- `base_power::Float64`: Base power of the unit (MVA) for [per unitization](@ref per_unit), validation range: `(0.0001, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
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
    "Reference active power (pu)"
    P_ref::Float64
    "Reference reactive power (pu)"
    Q_ref::Float64
    "Reference voltage (pu)"
    V_ref::Float64
    "Reference frequency in Hz"
    frequency_ref::Float64
    "Boolean to decide if filter [states](@ref S) are differential or algebraic"
    is_filter_differential::Bool
    "Base power of the unit (MVA) for [per unitization](@ref per_unit)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
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

function ActiveConstantPowerLoad(name, r_load, c_dc, rf, lf, cf, rg, lg, kp_pll, ki_pll, kpv, kiv, kpc, kic, P_ref, Q_ref, V_ref, frequency_ref, is_filter_differential, base_power, ext=Dict{String, Any}(), )
    ActiveConstantPowerLoad(name, r_load, c_dc, rf, lf, cf, rg, lg, kp_pll, ki_pll, kpv, kiv, kpc, kic, P_ref, Q_ref, V_ref, frequency_ref, is_filter_differential, base_power, ext, [:θ_pll, :ϵ_pll, :η, :v_dc, :γd, :γq, :ir_cnv, :ii_cnv, :vr_filter, :vi_filter, :ir_filter, :ii_filter], 12, InfrastructureSystemsInternal(), )
end

function ActiveConstantPowerLoad(; name, r_load, c_dc, rf, lf, cf, rg, lg, kp_pll, ki_pll, kpv, kiv, kpc, kic, P_ref, Q_ref, V_ref, frequency_ref, is_filter_differential, base_power, ext=Dict{String, Any}(), states=[:θ_pll, :ϵ_pll, :η, :v_dc, :γd, :γq, :ir_cnv, :ii_cnv, :vr_filter, :vi_filter, :ir_filter, :ii_filter], n_states=12, internal=InfrastructureSystemsInternal(), )
    ActiveConstantPowerLoad(name, r_load, c_dc, rf, lf, cf, rg, lg, kp_pll, ki_pll, kpv, kiv, kpc, kic, P_ref, Q_ref, V_ref, frequency_ref, is_filter_differential, base_power, ext, states, n_states, internal, )
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
        P_ref=0,
        Q_ref=0,
        V_ref=0,
        frequency_ref=0,
        is_filter_differential=false,
        base_power=100.0,
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
"""Get [`ActiveConstantPowerLoad`](@ref) `P_ref`."""
get_P_ref(value::ActiveConstantPowerLoad) = value.P_ref
"""Get [`ActiveConstantPowerLoad`](@ref) `Q_ref`."""
get_Q_ref(value::ActiveConstantPowerLoad) = value.Q_ref
"""Get [`ActiveConstantPowerLoad`](@ref) `V_ref`."""
get_V_ref(value::ActiveConstantPowerLoad) = value.V_ref
"""Get [`ActiveConstantPowerLoad`](@ref) `frequency_ref`."""
get_frequency_ref(value::ActiveConstantPowerLoad) = value.frequency_ref
"""Get [`ActiveConstantPowerLoad`](@ref) `is_filter_differential`."""
get_is_filter_differential(value::ActiveConstantPowerLoad) = value.is_filter_differential

_get_base_power(value::ActiveConstantPowerLoad) = value.base_power
"""Get [`ActiveConstantPowerLoad`](@ref) `ext`."""
get_ext(value::ActiveConstantPowerLoad) = value.ext
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
"""Set [`ActiveConstantPowerLoad`](@ref) `P_ref`."""
set_P_ref!(value::ActiveConstantPowerLoad, val) = value.P_ref = val
"""Set [`ActiveConstantPowerLoad`](@ref) `Q_ref`."""
set_Q_ref!(value::ActiveConstantPowerLoad, val) = value.Q_ref = val
"""Set [`ActiveConstantPowerLoad`](@ref) `V_ref`."""
set_V_ref!(value::ActiveConstantPowerLoad, val) = value.V_ref = val
"""Set [`ActiveConstantPowerLoad`](@ref) `frequency_ref`."""
set_frequency_ref!(value::ActiveConstantPowerLoad, val) = value.frequency_ref = val
"""Set [`ActiveConstantPowerLoad`](@ref) `is_filter_differential`."""
set_is_filter_differential!(value::ActiveConstantPowerLoad, val) = value.is_filter_differential = val
"""Set [`ActiveConstantPowerLoad`](@ref) `ext`."""
set_ext!(value::ActiveConstantPowerLoad, val) = value.ext = val



function from_openapi(po::PD.ActiveConstantPowerLoad, refs::OpenAPIRefs)
    return ActiveConstantPowerLoad(;
        name = _wire_required(po.name, "ActiveConstantPowerLoad", "name"),
        r_load = _wire_required(po.r_load, "ActiveConstantPowerLoad", "r_load"),
        c_dc = _wire_required(po.c_dc, "ActiveConstantPowerLoad", "c_dc"),
        rf = _wire_required(po.rf, "ActiveConstantPowerLoad", "rf"),
        lf = _wire_required(po.lf, "ActiveConstantPowerLoad", "lf"),
        cf = _wire_required(po.cf, "ActiveConstantPowerLoad", "cf"),
        rg = _wire_required(po.rg, "ActiveConstantPowerLoad", "rg"),
        lg = _wire_required(po.lg, "ActiveConstantPowerLoad", "lg"),
        kp_pll = _wire_required(po.kp_pll, "ActiveConstantPowerLoad", "kp_pll"),
        ki_pll = _wire_required(po.ki_pll, "ActiveConstantPowerLoad", "ki_pll"),
        kpv = _wire_required(po.kpv, "ActiveConstantPowerLoad", "kpv"),
        kiv = _wire_required(po.kiv, "ActiveConstantPowerLoad", "kiv"),
        kpc = _wire_required(po.kpc, "ActiveConstantPowerLoad", "kpc"),
        kic = _wire_required(po.kic, "ActiveConstantPowerLoad", "kic"),
        P_ref = _wire_required(po.p_ref, "ActiveConstantPowerLoad", "P_ref"),
        Q_ref = _wire_required(po.q_ref, "ActiveConstantPowerLoad", "Q_ref"),
        V_ref = _wire_required(po.v_ref, "ActiveConstantPowerLoad", "V_ref"),
        frequency_ref = _wire_required(po.frequency_ref, "ActiveConstantPowerLoad", "frequency_ref"),
        is_filter_differential = _wire_required(po.is_filter_differential, "ActiveConstantPowerLoad", "is_filter_differential"),
        base_power = _wire_required(po.base_power, "ActiveConstantPowerLoad", "base_power"),
    )
end

function to_openapi(value::ActiveConstantPowerLoad, refs::OpenAPIRefs)
    return PD.ActiveConstantPowerLoad(;
        id = component_id(refs, value),
        name = get_name(value),
        r_load = get_r_load(value),
        c_dc = get_c_dc(value),
        rf = get_rf(value),
        lf = get_lf(value),
        cf = get_cf(value),
        rg = get_rg(value),
        lg = get_lg(value),
        kp_pll = get_kp_pll(value),
        ki_pll = get_ki_pll(value),
        kpv = get_kpv(value),
        kiv = get_kiv(value),
        kpc = get_kpc(value),
        kic = get_kic(value),
        p_ref = get_P_ref(value),
        q_ref = get_Q_ref(value),
        v_ref = get_V_ref(value),
        frequency_ref = get_frequency_ref(value),
        is_filter_differential = get_is_filter_differential(value),
        base_power = _get_base_power(value),
    )
end
