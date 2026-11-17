abstract type InverterComponent <: DynamicComponent end

"""
    mutable struct DynamicInverter{
        C <: Converter,
        AP <: ActivePowerControl,
        RP <: ReactivePowerControl,
        IC <: InnerControl,
        DC <: DCSource,
        RF <: ReferenceFrameRotation,
        F <: Filter,
        CL <: Union{Nothing, CurrentLimitation},
    } <: DynamicInjection
        name::String
        frequency_ref::Float64
        converter::C
        active_power_control::AP
        reactive_power_control::RP
        inner_control::IC
        dc_source::DC
        reference_frame_rotation::RF
        filter::F
        current_limitation::CL
        base_power::Float64
        n_states::Int
        states::Vector{Symbol}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A dynamic inverter with the necessary data for modeling the dynamic response of an inverter
in a phasor or electromagnetic transient simulation.

A dynamic inverter has 7 components: a [`Converter`](@ref), an [`ActivePowerControl`](@ref),
a [`ReactivePowerControl`](@ref), an [`InnerControl`](@ref), a [`DCSource`](@ref),
a [`ReferenceFrameRotation`](@ref) and a [`Filter`](@ref). A
[`CurrentLimitation`](@ref) is optional.

It must be attached to a
[`StaticInjection`](@ref) device using [`add_component!`](@ref add_component!(
    sys::System,
    dyn_injector::DynamicInjection,
    static_injector::StaticInjection;
    kwargs...,
)), which contains all the rest of the generator's data that isn't specific to its dynamic
response.

# Arguments
- `name::String`: Name of inverter.
- `frequency_ref::Float64`: Frequency reference set-point in Hz. Usually equal to the system frequency.
- `converter <: Converter`: Converter model for the PWM transformation.
- `active_power_control <: ActivePowerControl`: Outer-loop active power control model.
- `reactive_power_control <: ReactivePowerControl`: Outer-loop reactive power control model.
- `inner_control <: InnerControl`: An [InnerControl](@ref) controller model.
- `dc_source <: DCSource`: [DCSource](@ref) model.
- `reference_frame_rotation <: ReferenceFrameRotation`: a [`ReferenceFrameRotation`](@ref) (typically a PLL) model.
- `filter <: Filter`: [Filter](@ref) model.
- `current_limitation <: Union{nothing, CurrentLimitation}`: (default: nothing) Inner control [`CurrentLimitation`](@ref) model.
- `base_power::Float64`: (default: `100.0`) Base power of the unit (MVA) for [per unitization](@ref per_unit). Although this has a default, in almost all cases `base_power` should be updated to equal the `base_power` field of the [`StaticInjection`](@ref) device that this dynamic generator will be attached to.
- `n_states::Int`: (**Do not modify.**)  Number of states (will depend on the inputs above).
- `states::Vector{Symbol}`: (**Do not modify.**) Vector of states (will depend on the inputs above).
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct DynamicInverter{
    C <: Converter,
    AP <: ActivePowerControl,
    RP <: ReactivePowerControl,
    IC <: InnerControl,
    DC <: DCSource,
    RF <: ReferenceFrameRotation,
    F <: Filter,
    CL <: Union{Nothing, CurrentLimitation},
} <: DynamicInjection
    name::String
    frequency_ref::Float64
    converter::C
    active_power_control::AP
    reactive_power_control::RP
    inner_control::IC
    dc_source::DC
    reference_frame_rotation::RF
    filter::F
    current_limitation::CL
    base_power::Float64
    n_states::Int
    states::Vector{Symbol}
    ext::Dict{String, Any}
    internal::InfrastructureSystemsInternal
end

function DynamicInverter(
    name::String,
    frequency_ref::Float64,
    converter::C,
    active_power_control::AP,
    reactive_power_control::RP,
    inner_control::IC,
    dc_source::DC,
    reference_frame_rotation::RF,
    filter::F,
    current_limitation::CL = nothing,
    base_power::Float64 = 100.0,
    ext::Dict{String, Any} = Dict{String, Any}(),
) where {
    C <: Converter,
    AP <: ActivePowerControl,
    RP <: ReactivePowerControl,
    IC <: InnerControl,
    DC <: DCSource,
    RF <: ReferenceFrameRotation,
    F <: Filter,
    CL <: Union{Nothing, CurrentLimitation},
}
    n_states = _calc_n_states(
        converter,
        active_power_control,
        reactive_power_control,
        inner_control,
        dc_source,
        reference_frame_rotation,
        filter,
    )
    states = _calc_states(
        converter,
        active_power_control,
        reactive_power_control,
        inner_control,
        dc_source,
        reference_frame_rotation,
        filter,
    )

    return DynamicInverter{C, AP, RP, IC, DC, RF, F, CL}(
        name,
        frequency_ref,
        converter,
        active_power_control,
        reactive_power_control,
        inner_control,
        dc_source,
        reference_frame_rotation,
        filter,
        current_limitation,
        base_power,
        n_states,
        states,
        ext,
        InfrastructureSystemsInternal(),
    )
end

function DynamicInverter(;
    name::String,
    frequency_ref::Float64,
    converter::C,
    active_power_control::AP,
    reactive_power_control::RP,
    inner_control::IC,
    dc_source::DC,
    reference_frame_rotation::RF,
    filter::F,
    current_limitation::CL = nothing,
    base_power::Float64 = 100.0,
    n_states = _calc_n_states(
        converter,
        active_power_control,
        reactive_power_control,
        inner_control,
        dc_source,
        reference_frame_rotation,
        filter,
    ),
    states = _calc_states(
        converter,
        active_power_control,
        reactive_power_control,
        inner_control,
        dc_source,
        reference_frame_rotation,
        filter,
    ),
    ext::Dict{String, Any} = Dict{String, Any}(),
    internal = IS.InfrastructureSystemsInternal(),
) where {
    C <: Converter,
    AP <: ActivePowerControl,
    RP <: ReactivePowerControl,
    IC <: InnerControl,
    DC <: DCSource,
    RF <: ReferenceFrameRotation,
    F <: Filter,
    CL <: Union{Nothing, CurrentLimitation},
}
    return DynamicInverter(
        name,
        frequency_ref,
        converter,
        active_power_control,
        reactive_power_control,
        inner_control,
        dc_source,
        reference_frame_rotation,
        filter,
        current_limitation,
        base_power,
        n_states,
        states,
        ext,
        internal,
    )
end

get_name(device::DynamicInverter) = device.name
"""Get the frequency reference of a [`DynamicInverter`](@ref) in Hz."""
get_frequency_ref(device::DynamicInverter) = device.frequency_ref
get_ext(device::DynamicInverter) = device.ext
get_states(device::DynamicInverter) = device.states
get_n_states(device::DynamicInverter) = device.n_states
"""Get the [`Converter`](@ref) component of a [`DynamicInverter`](@ref)."""
get_converter(device::DynamicInverter) = device.converter
"""Get the [`ActivePowerControl`](@ref) component of a [`DynamicInverter`](@ref)."""
get_active_power_control(device::DynamicInverter) = device.active_power_control
"""Get the [`ReactivePowerControl`](@ref) component of a [`DynamicInverter`](@ref)."""
get_reactive_power_control(device::DynamicInverter) = device.reactive_power_control
"""Get the [`InnerControl`](@ref) component of a [`DynamicInverter`](@ref)."""
get_inner_control(device::DynamicInverter) = device.inner_control
"""Get the [`DCSource`](@ref) component of a [`DynamicInverter`](@ref)."""
get_dc_source(device::DynamicInverter) = device.dc_source
"""Get the [`ReferenceFrameRotation`](@ref) component of a [`DynamicInverter`](@ref)."""
get_reference_frame_rotation(device::DynamicInverter) = device.reference_frame_rotation
"""Get the [`Filter`](@ref) component of a [`DynamicInverter`](@ref)."""
get_filter(device::DynamicInverter) = device.filter
"""Get the [`CurrentLimitation`](@ref) component of a [`DynamicInverter`](@ref)."""
get_current_limitation(device::DynamicInverter) = device.current_limitation
_get_base_power(device::DynamicInverter) = device.base_power
get_internal(device::DynamicInverter) = device.internal
get_P_ref(value::DynamicInverter) = get_P_ref(get_active_power_control(value))
get_V_ref(value::DynamicInverter) = get_V_ref(get_reactive_power_control(value))

function _calc_n_states(
    converter,
    active_power_control,
    reactive_power_control,
    inner_control,
    dc_source,
    reference_frame_rotation,
    filter,
)
    return converter.n_states +
           active_power_control.n_states +
           reactive_power_control.n_states +
           inner_control.n_states +
           dc_source.n_states +
           reference_frame_rotation.n_states +
           filter.n_states
end

function _calc_states(
    converter,
    active_power_control,
    reactive_power_control,
    inner_control,
    dc_source,
    reference_frame_rotation,
    filter,
)
    return vcat(
        converter.states,
        active_power_control.states,
        reactive_power_control.states,
        inner_control.states,
        dc_source.states,
        reference_frame_rotation.states,
        filter.states,
    )
end

function get_REControlB_states(Q_Flag::Bool)
    if Q_Flag
        return [:Vt_filt, :ξ_icv]
    else
        return [:Vt_filt, :I_icv]
    end
end

function get_activeRETypeAB_states(Freq_Flag::Bool)
    if Freq_Flag
        return [:p_flt, :ξ_P, :p_ext, :p_ord], 4
    else
        return [:p_ord], 1
    end
end

function get_reactiveRETypeAB_states(Ref_Flag::Bool, PF_Flag::Bool, V_Flag::Bool)
    if !Ref_Flag
        if PF_Flag
            if V_Flag
                return [:pr_flt, :ξ_Q], 2
            else
                return [:pr_flt], 1
            end
        else
            if V_Flag
                return [:q_flt, :ξq_oc, :q_LL, :ξ_Q], 4
            else
                return [:q_flt, :ξq_oc, :q_LL], 3
            end
        end
    else
        if PF_Flag
            if V_Flag
                return [:pr_flt, :ξ_Q], 2
            else
                return [:pr_flt], 1
            end
        else
            if V_Flag
                return [:V_cflt, :ξq_oc, :q_LL, :ξ_Q], 4
            else
                return [:V_cflt, :ξq_oc, :q_LL], 3
            end
        end
    end
end
