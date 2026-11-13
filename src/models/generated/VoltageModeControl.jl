#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct VoltageModeControl <: InnerControl
        kpv::Float64
        kiv::Float64
        kffv::Float64
        rv::Float64
        lv::Float64
        kpc::Float64
        kic::Float64
        kffi::Float64
        active_damping_filter_frequency::Float64
        kad::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of an inner loop current control PID using virtual impedance based on ["A Virtual Synchronous Machine implementation for distributed control of power converters in SmartGrids."](https://doi.org/10.1016/j.epsr.2015.01.001)

# Arguments
- `kpv::Float64`: voltage controller proportional gain, validation range: `(0, nothing)`
- `kiv::Float64`: voltage controller integral gain, validation range: `(0, nothing)`
- `kffv::Float64`: Binary variable to enable feed-forward gain of voltage, validation range: `(0, nothing)`
- `rv::Float64`: virtual resistance, validation range: `(0, nothing)`
- `lv::Float64`: virtual inductance, validation range: `(0, nothing)`
- `kpc::Float64`: current controller proportional gain, validation range: `(0, nothing)`
- `kic::Float64`: current controller integral gain, validation range: `(0, nothing)`
- `kffi::Float64`: Binary variable to enable feed-forward gain of current, validation range: `(0, nothing)`
- `active_damping_filter_frequency::Float64`: Active damping filter cutoff frequency, in natural units in Hz, validation range: `(0, nothing)`
- `kad::Float64`: active damping gain, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the VoltageModeControl model are:
	ξd_ic: d-axis integrator state of the PI voltage controller,
	ξq_ic: q-axis integrator state of the PI voltage controller,
	γd_ic: d-axis integrator state of the PI current controller,
	γq_ic: q-axis integrator state of the PI current controller,
	ϕd_ic: d-axis low-pass filter of active damping,
	ϕq_ic: q-axis low-pass filter of active damping
- `n_states::Int`: (**Do not modify.**) VoltageModeControl has 6 states
"""
mutable struct VoltageModeControl <: InnerControl
    "voltage controller proportional gain"
    kpv::Float64
    "voltage controller integral gain"
    kiv::Float64
    "Binary variable to enable feed-forward gain of voltage"
    kffv::Float64
    "virtual resistance"
    rv::Float64
    "virtual inductance"
    lv::Float64
    "current controller proportional gain"
    kpc::Float64
    "current controller integral gain"
    kic::Float64
    "Binary variable to enable feed-forward gain of current"
    kffi::Float64
    "Active damping filter cutoff frequency, in natural units in Hz"
    active_damping_filter_frequency::Float64
    "active damping gain"
    kad::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the VoltageModeControl model are:
	ξd_ic: d-axis integrator state of the PI voltage controller,
	ξq_ic: q-axis integrator state of the PI voltage controller,
	γd_ic: d-axis integrator state of the PI current controller,
	γq_ic: q-axis integrator state of the PI current controller,
	ϕd_ic: d-axis low-pass filter of active damping,
	ϕq_ic: q-axis low-pass filter of active damping"
    states::Vector{Symbol}
    "(**Do not modify.**) VoltageModeControl has 6 states"
    n_states::Int
end

function VoltageModeControl(kpv, kiv, kffv, rv, lv, kpc, kic, kffi, active_damping_filter_frequency, kad, ext=Dict{String, Any}(), )
    VoltageModeControl(kpv, kiv, kffv, rv, lv, kpc, kic, kffi, active_damping_filter_frequency, kad, ext, [:ξd_ic, :ξq_ic, :γd_ic, :γq_ic, :ϕd_ic, :ϕq_ic], 6, )
end

function VoltageModeControl(; kpv, kiv, kffv, rv, lv, kpc, kic, kffi, active_damping_filter_frequency, kad, ext=Dict{String, Any}(), states=[:ξd_ic, :ξq_ic, :γd_ic, :γq_ic, :ϕd_ic, :ϕq_ic], n_states=6, )
    VoltageModeControl(kpv, kiv, kffv, rv, lv, kpc, kic, kffi, active_damping_filter_frequency, kad, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function VoltageModeControl(::Nothing)
    VoltageModeControl(;
        kpv=0,
        kiv=0,
        kffv=0,
        rv=0,
        lv=0,
        kpc=0,
        kic=0,
        kffi=0,
        active_damping_filter_frequency=0,
        kad=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`VoltageModeControl`](@ref) `kpv`."""
get_kpv(value::VoltageModeControl) = value.kpv
"""Get [`VoltageModeControl`](@ref) `kiv`."""
get_kiv(value::VoltageModeControl) = value.kiv
"""Get [`VoltageModeControl`](@ref) `kffv`."""
get_kffv(value::VoltageModeControl) = value.kffv
"""Get [`VoltageModeControl`](@ref) `rv`."""
get_rv(value::VoltageModeControl) = value.rv
"""Get [`VoltageModeControl`](@ref) `lv`."""
get_lv(value::VoltageModeControl) = value.lv
"""Get [`VoltageModeControl`](@ref) `kpc`."""
get_kpc(value::VoltageModeControl) = value.kpc
"""Get [`VoltageModeControl`](@ref) `kic`."""
get_kic(value::VoltageModeControl) = value.kic
"""Get [`VoltageModeControl`](@ref) `kffi`."""
get_kffi(value::VoltageModeControl) = value.kffi
"""Get [`VoltageModeControl`](@ref) `active_damping_filter_frequency`."""
get_active_damping_filter_frequency(value::VoltageModeControl) = value.active_damping_filter_frequency
"""Get [`VoltageModeControl`](@ref) `kad`."""
get_kad(value::VoltageModeControl) = value.kad
"""Get [`VoltageModeControl`](@ref) `ext`."""
get_ext(value::VoltageModeControl) = value.ext
"""Get [`VoltageModeControl`](@ref) `states`."""
get_states(value::VoltageModeControl) = value.states
"""Get [`VoltageModeControl`](@ref) `n_states`."""
get_n_states(value::VoltageModeControl) = value.n_states

"""Set [`VoltageModeControl`](@ref) `kpv`."""
set_kpv!(value::VoltageModeControl, val) = value.kpv = val
"""Set [`VoltageModeControl`](@ref) `kiv`."""
set_kiv!(value::VoltageModeControl, val) = value.kiv = val
"""Set [`VoltageModeControl`](@ref) `kffv`."""
set_kffv!(value::VoltageModeControl, val) = value.kffv = val
"""Set [`VoltageModeControl`](@ref) `rv`."""
set_rv!(value::VoltageModeControl, val) = value.rv = val
"""Set [`VoltageModeControl`](@ref) `lv`."""
set_lv!(value::VoltageModeControl, val) = value.lv = val
"""Set [`VoltageModeControl`](@ref) `kpc`."""
set_kpc!(value::VoltageModeControl, val) = value.kpc = val
"""Set [`VoltageModeControl`](@ref) `kic`."""
set_kic!(value::VoltageModeControl, val) = value.kic = val
"""Set [`VoltageModeControl`](@ref) `kffi`."""
set_kffi!(value::VoltageModeControl, val) = value.kffi = val
"""Set [`VoltageModeControl`](@ref) `active_damping_filter_frequency`."""
set_active_damping_filter_frequency!(value::VoltageModeControl, val) = value.active_damping_filter_frequency = val
"""Set [`VoltageModeControl`](@ref) `kad`."""
set_kad!(value::VoltageModeControl, val) = value.kad = val
"""Set [`VoltageModeControl`](@ref) `ext`."""
set_ext!(value::VoltageModeControl, val) = value.ext = val



function from_openapi(po::PD.VoltageModeControl, refs::OpenAPIRefs)
    return VoltageModeControl(;
        kpv = _wire_required(po.kpv, "VoltageModeControl", "kpv"),
        kiv = _wire_required(po.kiv, "VoltageModeControl", "kiv"),
        kffv = _wire_required(po.kffv, "VoltageModeControl", "kffv"),
        rv = _wire_required(po.rv, "VoltageModeControl", "rv"),
        lv = _wire_required(po.lv, "VoltageModeControl", "lv"),
        kpc = _wire_required(po.kpc, "VoltageModeControl", "kpc"),
        kic = _wire_required(po.kic, "VoltageModeControl", "kic"),
        kffi = _wire_required(po.kffi, "VoltageModeControl", "kffi"),
        active_damping_filter_frequency = _wire_required(po.active_damping_filter_frequency, "VoltageModeControl", "active_damping_filter_frequency"),
        kad = _wire_required(po.kad, "VoltageModeControl", "kad"),
    )
end

function to_openapi(value::VoltageModeControl, refs::OpenAPIRefs)
    return PD.VoltageModeControl(;
        id = component_id(refs, value),
        kpv = get_kpv(value),
        kiv = get_kiv(value),
        kffv = get_kffv(value),
        rv = get_rv(value),
        lv = get_lv(value),
        kpc = get_kpc(value),
        kic = get_kic(value),
        kffi = get_kffi(value),
        active_damping_filter_frequency = get_active_damping_filter_frequency(value),
        kad = get_kad(value),
    )
end
