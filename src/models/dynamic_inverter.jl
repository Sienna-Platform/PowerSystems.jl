abstract type InverterComponent <: DynamicComponent end

"""
    mutable struct DynamicInverter{
        C <: Converter,
        O <: OuterControl,
        IC <: InnerControl,
        DC <: DCSource,
        P <: FrequencyEstimator,
        F <: Filter,
    } <: DynamicInjection
        name::String
        ω_ref::Float64
        converter::C
        outer_control::O
        inner_control::IC
        dc_source::DC
        freq_estimator::P
        filter::F
        limiter::Union{nothing, OutputCurrentLimiter}
        base_power::Float64
        n_states::Int
        states::Vector{Symbol}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A dynamic inverter with the necessary data for modeling the dynamic response of an inverter
in a phasor or electromagnetic transient simulation.

A dynamic inverter is composed by 6 components, namely a [Converter](@ref),
[Outer Loop Control](@ref OuterControl), [Inner Loop Control](@ref InnerControl),
a [DC Source](@ref DCSource), a [Frequency Estimator](@ref FrequencyEstimator) and a
[Filter](@ref).

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
- `ω_ref::Float64`: Frequency reference set-point in pu.
- `converter <: Converter`: Converter model for the PWM transformation.
- `outer_control <: OuterControl`: An [OuterControl](@ref) controller model.
- `inner_control <: InnerControl`: An [InnerControl](@ref) controller model.
- `dc_source <: DCSource`: [DCSource](@ref) model.
- `freq_estimator <: FrequencyEstimator`: a [FrequencyEstimator](@ref) (typically a [PLL](@ref P)) model.
- `filter <: Filter`: [Filter](@ref) model.
- `limiter <: Union{nothing, OutputCurrentLimiter}`: (default: nothing) Inner Control [Current Limiter](@ref OutputCurrentLimiter) model
- `base_power::Float64`: (default: `100.0`) Base power of the unit (MVA) for [per unitization](@ref per_unit). Although this has a default, in almost all cases `base_power` should be updated to equal the `base_power` field of the [`StaticInjection`](@ref) device that this dynamic generator will be attached to.
- `n_states::Int`: (**Do not modify.**)  Number of states (will depend on the inputs above).
- `states::Vector{Symbol}`: (**Do not modify.**) Vector of states (will depend on the inputs above).
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct DynamicInverter{
    C <: Converter,
    O <: OuterControl,
    IC <: InnerControl,
    DC <: DCSource,
    P <: FrequencyEstimator,
    F <: Filter,
    L <: Union{Nothing, OutputCurrentLimiter},
} <: DynamicInjection
    name::String
    ω_ref::Float64
    converter::C
    outer_control::O
    inner_control::IC
    dc_source::DC
    freq_estimator::P
    filter::F
    limiter::L
    base_power::Float64
    n_states::Int
    states::Vector{Symbol}
    ext::Dict{String, Any}
    internal::InfrastructureSystemsInternal
end

function DynamicInverter(
    name::String,
    ω_ref::Float64,
    converter::C,
    outer_control::O,
    inner_control::IC,
    dc_source::DC,
    freq_estimator::P,
    filter::F,
    limiter::L = nothing,
    base_power::Float64 = 100.0,
    ext::Dict{String, Any} = Dict{String, Any}(),
) where {
    C <: Converter,
    O <: OuterControl,
    IC <: InnerControl,
    DC <: DCSource,
    P <: FrequencyEstimator,
    F <: Filter,
    L <: Union{Nothing, OutputCurrentLimiter},
}
    n_states = _calc_n_states(
        converter,
        outer_control,
        inner_control,
        dc_source,
        freq_estimator,
        filter,
    )
    states = _calc_states(
        converter,
        outer_control,
        inner_control,
        dc_source,
        freq_estimator,
        filter,
    )

    return DynamicInverter{C, O, IC, DC, P, F, L}(
        name,
        ω_ref,
        converter,
        outer_control,
        inner_control,
        dc_source,
        freq_estimator,
        filter,
        limiter,
        base_power,
        n_states,
        states,
        ext,
        InfrastructureSystemsInternal(),
    )
end

function DynamicInverter(;
    name::String,
    ω_ref::Float64,
    converter::C,
    outer_control::O,
    inner_control::IC,
    dc_source::DC,
    freq_estimator::P,
    filter::F,
    limiter::L = nothing,
    base_power::Float64 = 100.0,
    n_states = _calc_n_states(
        converter,
        outer_control,
        inner_control,
        dc_source,
        freq_estimator,
        filter,
    ),
    states = _calc_states(
        converter,
        outer_control,
        inner_control,
        dc_source,
        freq_estimator,
        filter,
    ),
    ext::Dict{String, Any} = Dict{String, Any}(),
    internal = IS.InfrastructureSystemsInternal(),
) where {
    C <: Converter,
    O <: OuterControl,
    IC <: InnerControl,
    DC <: DCSource,
    P <: FrequencyEstimator,
    F <: Filter,
    L <: Union{Nothing, OutputCurrentLimiter},
}
    return DynamicInverter(
        name,
        ω_ref,
        converter,
        outer_control,
        inner_control,
        dc_source,
        freq_estimator,
        filter,
        limiter,
        base_power,
        n_states,
        states,
        ext,
        internal,
    )
end

function DynamicInverter(
    name::String,
    ω_ref::Float64,
    converter::C,
    active_power_control::AC,
    reactive_power_control::RC,
    inner_control::IC,
    dc_source::DC,
    freq_estimator::P,
    ac_filter::F,
) where {
    C <: Converter,
    AC <: ActivePowerControl,
    RC <: ReactivePowerControl,
    IC <: InnerControl,
    DC <: DCSource,
    P <: FrequencyEstimator,
    F <: Filter,
}
    outer_control = OuterControl(active_power_control, reactive_power_control)
    return DynamicInverter(
        name,
        ω_ref,
        converter,
        outer_control,
        inner_control,
        dc_source,
        freq_estimator,
        ac_filter,
    )
end

get_name(device::DynamicInverter) = device.name
get_ω_ref(device::DynamicInverter) = device.ω_ref
get_ext(device::DynamicInverter) = device.ext
get_states(device::DynamicInverter) = device.states
get_n_states(device::DynamicInverter) = device.n_states
"""Get the [`Converter`](@ref) component of a [`DynamicInverter`](@ref)."""
get_converter(device::DynamicInverter) = device.converter
"""Get the [`OuterControl`](@ref) component of a [`DynamicInverter`](@ref)."""
get_outer_control(device::DynamicInverter) = device.outer_control
"""Get the [`InnerControl`](@ref) component of a [`DynamicInverter`](@ref)."""
get_inner_control(device::DynamicInverter) = device.inner_control
"""Get the [`DCSource`](@ref) component of a [`DynamicInverter`](@ref)."""
get_dc_source(device::DynamicInverter) = device.dc_source
"""Get the [`FrequencyEstimator`](@ref) component of a [`DynamicInverter`](@ref)."""
get_freq_estimator(device::DynamicInverter) = device.freq_estimator
"""Get the [`Filter`](@ref) component of a [`DynamicInverter`](@ref)."""
get_filter(device::DynamicInverter) = device.filter
get_limiter(device::DynamicInverter) = device.limiter
get_base_power(device::DynamicInverter) = device.base_power
get_internal(device::DynamicInverter) = device.internal
get_P_ref(value::DynamicInverter) =
    get_P_ref(get_active_power_control(get_outer_control(value)))
get_V_ref(value::DynamicInverter) =
    get_V_ref(get_reactive_power_control(get_outer_control(value)))

set_base_power!(value::DynamicInverter, val) = value.base_power = val

function _calc_n_states(
    converter,
    outer_control,
    inner_control,
    dc_source,
    freq_estimator,
    filter,
)
    return converter.n_states +
           outer_control.n_states +
           inner_control.n_states +
           dc_source.n_states +
           freq_estimator.n_states +
           filter.n_states
end

function _calc_states(
    converter,
    outer_control,
    inner_control,
    dc_source,
    freq_estimator,
    filter,
)
    return vcat(
        converter.states,
        outer_control.states,
        inner_control.states,
        dc_source.states,
        freq_estimator.states,
        filter.states,
    )
end

function get_REControlB_states(Q_Flag::Int)
    if Q_Flag == 0
        return [:Vt_filt, :I_icv]
    elseif Q_Flag == 1
        return [:Vt_filt, :ξ_icv]
    else
        error("Unsupported value of Q_Flag")
    end
end

function get_activeRETypeAB_states(Freq_Flag::Int)
    if Freq_Flag == 1
        return [:p_flt, :ξ_P, :p_ext, :p_ord], 4
    elseif Freq_Flag == 0
        return [:p_ord], 1
    else
        error("Unsupported value of Freq_Flag")
    end
end

function get_reactiveRETypeAB_states(Ref_Flag::Int, PF_Flag::Int, V_Flag::Int)
    if (Ref_Flag == 0) && ((PF_Flag == 1) && (V_Flag == 1))
        return [:pr_flt, :ξ_Q], 2
    elseif (Ref_Flag == 0) && ((PF_Flag == 1) && (V_Flag == 0))
        return [:pr_flt], 1
    elseif (Ref_Flag == 0) && ((PF_Flag == 0) && (V_Flag == 1))
        return [:q_flt, :ξq_oc, :q_LL, :ξ_Q], 4
    elseif (Ref_Flag == 0) && ((PF_Flag == 0) && (V_Flag == 0))
        return [:q_flt, :ξq_oc, :q_LL], 3
    elseif (Ref_Flag == 1) && ((PF_Flag == 1) && (V_Flag == 1))
        return [:pr_flt, :ξ_Q], 2
    elseif (Ref_Flag == 1) && ((PF_Flag == 1) && (V_Flag == 0))
        return [:pr_flt], 1
    elseif (Ref_Flag == 1) && ((PF_Flag == 0) && (V_Flag == 1))
        return [:V_cflt, :ξq_oc, :q_LL, :ξ_Q], 4
    elseif (Ref_Flag == 1) && ((PF_Flag == 0) && (V_Flag == 0))
        return [:V_cflt, :ξq_oc, :q_LL], 3
    else
        error("Unsupported value of Ref_Flag, PF_Flag or V_Flag")
    end
end
