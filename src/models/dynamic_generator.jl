"""
    mutable struct DynamicGenerator{
        M <: SynchronousMachineDynamics,
        S <: Shaft,
        A <: ExcitationSystemDynamics,
        TG <: TurbineGovernorDynamics,
        P <: PowerSystemStabilizerDynamics,
    } <: DynamicInjection
        name::String
        frequency_ref::Float64
        synchronous_machine_dynamics::M
        shaft::S
        excitation_system_dynamics::A
        turbine_governor_dynamics::TG
        power_system_stabilizer_dynamics::P
        base_power::Float64
        n_states::Int
        states::Vector{Symbol}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A dynamic generator with the necessary data for modeling the dynamic response of a generator
in a phasor or electromagnetic transient simulation.

A dynamic generator has 5 components: a [`SynchronousMachineDynamics`](@ref), a [`Shaft`](@ref),
an [`ExcitationSystemDynamics`](@ref), a [`TurbineGovernorDynamics`](@ref),
and a [`PowerSystemStabilizerDynamics`](@ref). It must be attached to a
[`StaticInjection`](@ref) device using [`add_component!`](@ref add_component!(
    sys::System,
    dyn_injector::DynamicInjection,
    static_injector::StaticInjection;
    kwargs...,
)), which contains all the rest of the generator's data that isn't specific to its dynamic
response.

# Arguments
- `name::String`: Name of generator.
- `frequency_ref::Float64`: Frequency reference set-point in Hz. Usually equal to the system frequency.
- `synchronous_machine_dynamics <: SynchronousMachineDynamics`: [`SynchronousMachineDynamics`](@ref) model for modeling the electro-magnetic phenomena.
- `shaft <: Shaft`: [Shaft](@ref) model for modeling the electro-mechanical phenomena.
- `excitation_system_dynamics <: ExcitationSystemDynamics`: [`ExcitationSystemDynamics`](@ref) model of the excitation system.
- `turbine_governor_dynamics <: TurbineGovernorDynamics`: [`TurbineGovernorDynamics`](@ref) model for mechanical power.
- `power_system_stabilizer_dynamics <: PowerSystemStabilizerDynamics`: [`PowerSystemStabilizerDynamics`](@ref) model.
- `base_power::Float64`: (default: `100.0`) Base power of the unit (MVA) for [per unitization](@ref per_unit). Although this has a default, in almost all cases `base_power` should be updated to equal the `base_power` field of the [`StaticInjection`](@ref) device that this dynamic generator will be attached to.
- `n_states::Int`: (**Do not modify.**)  Number of states (will depend on the inputs above).
- `states::Vector{Symbol}`: (**Do not modify.**) Vector of states (will depend on the inputs above).
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct DynamicGenerator{
    M <: SynchronousMachineDynamics,
    S <: Shaft,
    A <: ExcitationSystemDynamics,
    TG <: TurbineGovernorDynamics,
    P <: PowerSystemStabilizerDynamics,
} <: DynamicInjection
    name::String
    frequency_ref::Float64
    synchronous_machine_dynamics::M
    shaft::S
    excitation_system_dynamics::A
    turbine_governor_dynamics::TG
    power_system_stabilizer_dynamics::P
    base_power::Float64
    n_states::Int
    states::Vector{Symbol}
    ext::Dict{String, Any}
    internal::InfrastructureSystemsInternal
end

function DynamicGenerator(
    name::String,
    frequency_ref::Float64,
    synchronous_machine_dynamics::M,
    shaft::S,
    excitation_system_dynamics::A,
    turbine_governor_dynamics::TG,
    power_system_stabilizer_dynamics::P,
    base_power::Float64 = 100.0,
    ext::Dict{String, Any} = Dict{String, Any}(),
) where {
    M <: SynchronousMachineDynamics,
    S <: Shaft,
    A <: ExcitationSystemDynamics,
    TG <: TurbineGovernorDynamics,
    P <: PowerSystemStabilizerDynamics,
}
    n_states = _calc_n_states(
        synchronous_machine_dynamics,
        shaft,
        excitation_system_dynamics,
        turbine_governor_dynamics,
        power_system_stabilizer_dynamics,
    )
    states = _calc_states(
        synchronous_machine_dynamics,
        shaft,
        excitation_system_dynamics,
        turbine_governor_dynamics,
        power_system_stabilizer_dynamics,
    )

    return DynamicGenerator{M, S, A, TG, P}(
        name,
        frequency_ref,
        synchronous_machine_dynamics,
        shaft,
        excitation_system_dynamics,
        turbine_governor_dynamics,
        power_system_stabilizer_dynamics,
        base_power,
        n_states,
        states,
        ext,
        InfrastructureSystemsInternal(),
    )
end

function DynamicGenerator(;
    name::String,
    frequency_ref::Float64,
    synchronous_machine_dynamics::M,
    shaft::S,
    excitation_system_dynamics::A,
    turbine_governor_dynamics::TG,
    power_system_stabilizer_dynamics::P,
    base_power::Float64 = 100.0,
    n_states = _calc_n_states(
        synchronous_machine_dynamics,
        shaft,
        excitation_system_dynamics,
        turbine_governor_dynamics,
        power_system_stabilizer_dynamics,
    ),
    states = _calc_states(
        synchronous_machine_dynamics,
        shaft,
        excitation_system_dynamics,
        turbine_governor_dynamics,
        power_system_stabilizer_dynamics,
    ),
    ext::Dict{String, Any} = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
) where {
    M <: SynchronousMachineDynamics,
    S <: Shaft,
    A <: ExcitationSystemDynamics,
    TG <: TurbineGovernorDynamics,
    P <: PowerSystemStabilizerDynamics,
}
    return DynamicGenerator(
        name,
        frequency_ref,
        synchronous_machine_dynamics,
        shaft,
        excitation_system_dynamics,
        turbine_governor_dynamics,
        power_system_stabilizer_dynamics,
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
"""Get the frequency reference of a [`DynamicGenerator`](@ref) in Hz."""
get_frequency_ref(device::DynamicGenerator) = device.frequency_ref
"""Get the [`SynchronousMachineDynamics`](@ref) component of a [`DynamicGenerator`](@ref)."""
get_synchronous_machine_dynamics(device::DynamicGenerator) =
    device.synchronous_machine_dynamics
"""Get the [`Shaft`](@ref) component of a [`DynamicGenerator`](@ref)."""
get_shaft(device::DynamicGenerator) = device.shaft
"""Get the [`ExcitationSystemDynamics`](@ref) component of a [`DynamicGenerator`](@ref)."""
get_excitation_system_dynamics(device::DynamicGenerator) = device.excitation_system_dynamics
"""Get the [`TurbineGovernorDynamics`](@ref) component of a [`DynamicGenerator`](@ref)."""
get_turbine_governor_dynamics(device::DynamicGenerator) = device.turbine_governor_dynamics
"""Get the [`PowerSystemStabilizerDynamics`](@ref) component of a [`DynamicGenerator`](@ref)."""
get_power_system_stabilizer_dynamics(device::DynamicGenerator) =
    device.power_system_stabilizer_dynamics
_get_base_power(device::DynamicGenerator) = device.base_power
get_ext(device::DynamicGenerator) = device.ext
get_internal(device::DynamicGenerator) = device.internal
get_V_ref(value::DynamicGenerator) = get_V_ref(get_excitation_system_dynamics(value))
get_P_ref(value::DynamicGenerator) = get_P_ref(get_turbine_governor_dynamics(value))

function _calc_n_states(
    synchronous_machine_dynamics,
    shaft,
    excitation_system_dynamics,
    turbine_governor_dynamics,
    power_system_stabilizer_dynamics,
)
    return get_n_states(synchronous_machine_dynamics) +
           get_n_states(shaft) +
           get_n_states(excitation_system_dynamics) +
           get_n_states(turbine_governor_dynamics) +
           get_n_states(power_system_stabilizer_dynamics)
end

function _calc_states(
    synchronous_machine_dynamics,
    shaft,
    excitation_system_dynamics,
    turbine_governor_dynamics,
    power_system_stabilizer_dynamics,
)
    return vcat(
        get_states(synchronous_machine_dynamics),
        get_states(shaft),
        get_states(excitation_system_dynamics),
        get_states(turbine_governor_dynamics),
        get_states(power_system_stabilizer_dynamics),
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
Get the frequency droop parameter from the turbine governor of a [`DynamicGenerator`](@ref).
"""
function get_frequency_droop(dyn_gen::DynamicGenerator)
    return get_frequency_droop(get_turbine_governor_dynamics(dyn_gen))
end

function get_frequency_droop(::V) where {V <: TurbineGovernorDynamics}
    throw(
        ArgumentError(
            "get_frequency_droop not implemented for turbine governor $V.",
        ),
    )
end

get_frequency_droop(pm::DEGOV) = 1 / get_K(pm)
get_frequency_droop(pm::DEGOV1) = get_R(pm)
get_frequency_droop(pm::GasTG) = get_R(pm)
get_frequency_droop(pm::GeneralGovModel) = get_R(pm)
get_frequency_droop(pm::HydroTurbineGov) = get_R_BIG(pm)
get_frequency_droop(pm::IEEETurbineGov1) = 1 / get_K(pm)
get_frequency_droop(pm::PIDGOV) = 1 / get_Rperm(pm)
get_frequency_droop(pm::SteamTurbineGov1) = get_R(pm)
get_frequency_droop(pm::TGSimple) = 1 / d_t(pm)
get_frequency_droop(pm::TGTypeI) = get_R(pm)
get_frequency_droop(pm::TGTypeII) = get_R(pm)
get_frequency_droop(pm::WPIDHY) = 1 / get_reg(pm)
