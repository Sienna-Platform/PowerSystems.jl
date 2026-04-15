"""
    mutable struct DynamicGenerator{
        M <: Machine,
        S <: Shaft,
        A <: AVR,
        TG <: TurbineGov,
        P <: PSS,
    } <: DynamicInjection
        name::String
        ω_ref::Float64
        machine::M
        shaft::S
        avr::A
        prime_mover::TG
        pss::P
        base_power::Float64
        n_states::Int
        states::Vector{Symbol}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A dynamic generator with the necessary data for modeling the dynamic response of a generator
in a phasor or electromagnetic transient simulation.

Dynamic generator is composed by 5 components, namely a [Machine](@ref), a [Shaft](@ref),
an Automatic Voltage Regulator ([AVR](@ref)), a
[Prime Mover and Turbine Governor](@ref "TurbineGov"),
and Power System Stabilizer ([PSS](@ref)). It must be attached to a
[`StaticInjection`](@ref) device using [`add_component!`](@ref add_component!(
    sys::System,
    dyn_injector::DynamicInjection,
    static_injector::StaticInjection;
    kwargs...,
)), which contains all the rest of the generator's data that isn't specific to its dynamic
response.

# Arguments
- `name::String`: Name of generator.
- `ω_ref::Float64`: Frequency reference set-point in pu.
- `machine <: Machine`: [Machine](@ref) model for modeling the electro-magnetic phenomena.
- `shaft <: Shaft`: [Shaft](@ref) model for modeling the electro-mechanical phenomena.
- `avr <: AVR`: [AVR](@ref) model of the excitacion system.
- `prime_mover <: TurbineGov`: [Prime Mover and Turbine Governor model](@ref "TurbineGov") for mechanical power.
- `pss <: PSS`: [PSS](@ref) model.
- `base_power::Float64`: (default: `100.0`) Base power of the unit (MVA) for [per unitization](@ref per_unit). Although this has a default, in almost all cases `base_power` should be updated to equal the `base_power` field of the [`StaticInjection`](@ref) device that this dynamic generator will be attached to.
- `n_states::Int`: (**Do not modify.**)  Number of states (will depend on the inputs above).
- `states::Vector{Symbol}`: (**Do not modify.**) Vector of states (will depend on the inputs above).
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct DynamicGenerator{
    M <: Machine,
    S <: Shaft,
    A <: AVR,
    TG <: TurbineGov,
    P <: PSS,
} <: DynamicInjection
    name::String
    ω_ref::Float64
    machine::M
    shaft::S
    avr::A
    prime_mover::TG
    pss::P
    base_power::Float64
    n_states::Int
    states::Vector{Symbol}
    ext::Dict{String, Any}
    internal::InfrastructureSystemsInternal
end

function DynamicGenerator(
    name::String,
    ω_ref::Float64,
    machine::M,
    shaft::S,
    avr::A,
    prime_mover::TG,
    pss::P,
    base_power::Float64 = 100.0,
    ext::Dict{String, Any} = Dict{String, Any}(),
) where {M <: Machine, S <: Shaft, A <: AVR, TG <: TurbineGov, P <: PSS}
    n_states = _calc_n_states(machine, shaft, avr, prime_mover, pss)
    states = _calc_states(machine, shaft, avr, prime_mover, pss)

    return DynamicGenerator{M, S, A, TG, P}(
        name,
        ω_ref,
        machine,
        shaft,
        avr,
        prime_mover,
        pss,
        base_power,
        n_states,
        states,
        ext,
        InfrastructureSystemsInternal(),
    )
end

function DynamicGenerator(;
    name::String,
    ω_ref::Float64,
    machine::M,
    shaft::S,
    avr::A,
    prime_mover::TG,
    pss::P,
    base_power::Float64 = 100.0,
    n_states = _calc_n_states(machine, shaft, avr, prime_mover, pss),
    states = _calc_states(machine, shaft, avr, prime_mover, pss),
    ext::Dict{String, Any} = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
) where {M <: Machine, S <: Shaft, A <: AVR, TG <: TurbineGov, P <: PSS}
    return DynamicGenerator(
        name,
        ω_ref,
        machine,
        shaft,
        avr,
        prime_mover,
        pss,
        base_power,
        n_states,
        states,
        ext,
        internal,
    )
end

get_name(device::DynamicGenerator) = device.name
get_states(device::DynamicGenerator) = device.states
get_n_states(device::DynamicGenerator) = device.n_states
get_ω_ref(device::DynamicGenerator) = device.ω_ref
"""Get the [`Machine`](@ref) component of a [`DynamicGenerator`](@ref)."""
get_machine(device::DynamicGenerator) = device.machine
"""Get the [`Shaft`](@ref) component of a [`DynamicGenerator`](@ref)."""
get_shaft(device::DynamicGenerator) = device.shaft
"""Get the [`AVR`](@ref) component of a [`DynamicGenerator`](@ref)."""
get_avr(device::DynamicGenerator) = device.avr
"""Get the [`TurbineGov`](@ref) (prime mover) component of a [`DynamicGenerator`](@ref)."""
get_prime_mover(device::DynamicGenerator) = device.prime_mover
"""Get the [`PSS`](@ref) component of a [`DynamicGenerator`](@ref)."""
get_pss(device::DynamicGenerator) = device.pss
get_base_power(device::DynamicGenerator) = device.base_power
get_ext(device::DynamicGenerator) = device.ext
get_internal(device::DynamicGenerator) = device.internal
get_V_ref(value::DynamicGenerator) = get_V_ref(get_avr(value))
get_P_ref(value::DynamicGenerator) = get_P_ref(get_prime_mover(value))

set_base_power!(value::DynamicGenerator, val) = value.base_power = val

function _calc_n_states(machine, shaft, avr, prime_mover, pss)
    return get_n_states(machine) +
           get_n_states(shaft) +
           get_n_states(avr) +
           get_n_states(prime_mover) +
           get_n_states(pss)
end

function _calc_states(machine, shaft, avr, prime_mover, pss)
    return vcat(
        get_states(machine),
        get_states(shaft),
        get_states(avr),
        get_states(prime_mover),
        get_states(pss),
    )
end

function get_degov1_states(droop_flag::Int)
    if droop_flag == 0
        return [:x_g1, :x_g2, :x_g3, :x_g4, :x_g5], 5
    elseif droop_flag == 1
        return [:x_g1, :x_g2, :x_g3, :x_g4, :x_g5, :x_g6], 6
    else
        error("Unsupported value of droop_flag on DEGOV1")
    end
end

"""
Get the frequency droop parameter from the prime mover of a [`DynamicGenerator`](@ref).
"""
function get_frequency_droop(dyn_gen::DynamicGenerator)
    return get_frequency_droop(get_prime_mover(dyn_gen))
end

function get_frequency_droop(::V) where {V <: TurbineGov}
    throw(
        ArgumentError(
            "get_frequency_droop not implemented for prime mover $V.",
        ),
    )
end

get_frequency_droop(pm::DEGOV) = 1 / get_K(pm)
get_frequency_droop(pm::DEGOV1) = get_R(pm)
get_frequency_droop(pm::GasTG) = get_R(pm)
get_frequency_droop(pm::GeneralGovModel) = get_R(pm)
get_frequency_droop(pm::HydroTurbineGov) = get_R(pm)
get_frequency_droop(pm::IEEETurbineGov1) = 1 / get_K(pm)
get_frequency_droop(pm::PIDGOV) = 1 / get_Rperm(pm)
get_frequency_droop(pm::SteamTurbineGov1) = get_R(pm)
get_frequency_droop(pm::TGSimple) = 1 / d_t(pm)
get_frequency_droop(pm::TGTypeI) = get_R(pm)
get_frequency_droop(pm::TGTypeII) = get_R(pm)
get_frequency_droop(pm::WPIDHY) = 1 / get_reg(pm)
