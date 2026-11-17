#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct CurrentModeControl <: InnerControl
        kpc::Float64
        kic::Float64
        kffv::Float64
        ext::Dict{String, Any}
        states::Vector{Symbol}
        n_states::Int
    end

Parameters of an inner loop proportional integral (PI) current control based on ["Reduced-order Structure-preserving Model for Parallel-connected Three-phase Grid-tied Inverters."](https://doi.org/10.1109/COMPEL.2017.8013389)

# Arguments
- `kpc::Float64`: Current controller proportional gain, validation range: `(0, nothing)`
- `kic::Float64`: Current controller integral gain, validation range: `(0, nothing)`
- `kffv::Float64`: Gain to enable feed-forward gain of voltage, validation range: `(0, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `states::Vector{Symbol}`: (**Do not modify.**) The [states](@ref S) of the CurrentModeControl model are:
	γd_ic: d-axis integrator state of the PI current controller,
	γq_ic: q-axis integrator state of the PI current controller
- `n_states::Int`: (**Do not modify.**) CurrentControl has 2 states
"""
mutable struct CurrentModeControl <: InnerControl
    "Current controller proportional gain"
    kpc::Float64
    "Current controller integral gain"
    kic::Float64
    "Gain to enable feed-forward gain of voltage"
    kffv::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) The [states](@ref S) of the CurrentModeControl model are:
	γd_ic: d-axis integrator state of the PI current controller,
	γq_ic: q-axis integrator state of the PI current controller"
    states::Vector{Symbol}
    "(**Do not modify.**) CurrentControl has 2 states"
    n_states::Int
end

function CurrentModeControl(kpc, kic, kffv, ext=Dict{String, Any}(), )
    CurrentModeControl(kpc, kic, kffv, ext, [:γd_ic, :γq_ic], 2, )
end

function CurrentModeControl(; kpc, kic, kffv, ext=Dict{String, Any}(), states=[:γd_ic, :γq_ic], n_states=2, )
    CurrentModeControl(kpc, kic, kffv, ext, states, n_states, )
end

# Constructor for demo purposes; non-functional.
function CurrentModeControl(::Nothing)
    CurrentModeControl(;
        kpc=0,
        kic=0,
        kffv=0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`CurrentModeControl`](@ref) `kpc`."""
get_kpc(value::CurrentModeControl) = value.kpc
"""Get [`CurrentModeControl`](@ref) `kic`."""
get_kic(value::CurrentModeControl) = value.kic
"""Get [`CurrentModeControl`](@ref) `kffv`."""
get_kffv(value::CurrentModeControl) = value.kffv
"""Get [`CurrentModeControl`](@ref) `ext`."""
get_ext(value::CurrentModeControl) = value.ext
"""Get [`CurrentModeControl`](@ref) `states`."""
get_states(value::CurrentModeControl) = value.states
"""Get [`CurrentModeControl`](@ref) `n_states`."""
get_n_states(value::CurrentModeControl) = value.n_states

"""Set [`CurrentModeControl`](@ref) `kpc`."""
set_kpc!(value::CurrentModeControl, val) = value.kpc = val
"""Set [`CurrentModeControl`](@ref) `kic`."""
set_kic!(value::CurrentModeControl, val) = value.kic = val
"""Set [`CurrentModeControl`](@ref) `kffv`."""
set_kffv!(value::CurrentModeControl, val) = value.kffv = val
"""Set [`CurrentModeControl`](@ref) `ext`."""
set_ext!(value::CurrentModeControl, val) = value.ext = val



function from_openapi(po::PD.CurrentModeControl, refs::OpenAPIRefs)
    return CurrentModeControl(;
        kpc = _wire_required(po.kpc, "CurrentModeControl", "kpc"),
        kic = _wire_required(po.kic, "CurrentModeControl", "kic"),
        kffv = _wire_required(po.kffv, "CurrentModeControl", "kffv"),
    )
end

function to_openapi(value::CurrentModeControl, refs::OpenAPIRefs)
    return PD.CurrentModeControl(;
        id = component_id(refs, value),
        kpc = get_kpc(value),
        kic = get_kic(value),
        kffv = get_kffv(value),
    )
end
