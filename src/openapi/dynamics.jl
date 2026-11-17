# Hand-written (not generated): the dynamics converters whose PSY shape differs from their
# wire shape, and the document-level glue for the dynamics types. The 91 leaf types are
# generated (`openapi_dynamic` in the descriptor). Included after the dynamics types, which the
# earlier openapi files precede.

# ── import ───────────────────────────────────────────────────────────────────────
# Function blocks and dynamic injections are top-level document components. An injection
# names its blocks by id; the static device names the injection in `dynamic_injector`. The
# 91 leaf types are generated (`openapi_dynamic` in the descriptor). Only the types whose PSY
# shape differs from their wire shape are written here.

# A saturation machine wraps a base machine block: the wire gives two components, the
# saturation block naming the base machine by id. `saturation_coeffs` is derived from the base
# machine's `Se`, but it is read back from the wire so a document value is never recomputed.
for (saturation_type, base_type) in (
    (:RoundRotorQuadratic, :RoundRotorMachine),
    (:RoundRotorExponential, :RoundRotorMachine),
    (:SalientPoleQuadratic, :SalientPoleMachine),
    (:SalientPoleExponential, :SalientPoleMachine),
)
    @eval begin
        function from_openapi(po::PD.$saturation_type, refs::OpenAPIRefs)
            return $saturation_type(
                resolve_ref(refs, po.base_machine, $base_type),
                _wire_to_psy(Tuple{Float64, Float64}, po.saturation_coeffs),
            )
        end

        _merge_doc_ext!(::$saturation_type, ::AbstractDict) = nothing
    end
end

function from_openapi(po::PD.DynamicGenerator, refs::OpenAPIRefs)
    return DynamicGenerator(;
        name = po.name,
        frequency_ref = po.frequency_ref,
        synchronous_machine_dynamics = resolve_ref(
            refs, po.synchronous_machine_dynamics, SynchronousMachineDynamics,
        ),
        shaft = resolve_ref(refs, po.shaft, Shaft),
        excitation_system_dynamics = resolve_ref(
            refs, po.excitation_system_dynamics, ExcitationSystemDynamics,
        ),
        turbine_governor_dynamics = resolve_ref(
            refs, po.turbine_governor_dynamics, TurbineGovernorDynamics,
        ),
        power_system_stabilizer_dynamics = resolve_ref(
            refs, po.power_system_stabilizer_dynamics, PowerSystemStabilizerDynamics,
        ),
        base_power = po.base_power,
    )
end

function from_openapi(po::PD.DynamicInverter, refs::OpenAPIRefs)
    return DynamicInverter(;
        name = po.name,
        frequency_ref = po.frequency_ref,
        converter = resolve_ref(refs, po.converter, Converter),
        active_power_control = resolve_ref(
            refs, po.active_power_control, ActivePowerControl,
        ),
        reactive_power_control = resolve_ref(
            refs, po.reactive_power_control, ReactivePowerControl,
        ),
        inner_control = resolve_ref(refs, po.inner_control, InnerControl),
        dc_source = resolve_ref(refs, po.dc_source, DCSource),
        reference_frame_rotation = resolve_ref(
            refs, po.reference_frame_rotation, ReferenceFrameRotation,
        ),
        filter = resolve_ref(refs, po.filter, Filter),
        current_limitation = resolve_ref(refs, po.current_limitation, CurrentLimitation),
        base_power = po.base_power,
    )
end

# ── export ───────────────────────────────────────────────────────────────────────
# Mirror of the dynamics section of import_handwritten.jl. Every block is registered in
# `refs` under its own id before any of these run (`_register_dynamic_blocks!`).

for saturation_type in (
    :RoundRotorQuadratic,
    :RoundRotorExponential,
    :SalientPoleQuadratic,
    :SalientPoleExponential,
)
    @eval begin
        function to_openapi(value::$saturation_type, refs::OpenAPIRefs)
            return PD.$saturation_type(;
                id = component_id(refs, value),
                base_machine = component_id(refs, get_base_machine(value)),
                saturation_coeffs = _psy_to_wire(get_saturation_coeffs(value)),
            )
        end

        _export_ext!(::PC.SystemDocument, ::Int, ::$saturation_type) = nothing
    end
end

function to_openapi(value::DynamicGenerator, refs::OpenAPIRefs)
    return PD.DynamicGenerator(;
        id = component_id(refs, value),
        name = get_name(value),
        frequency_ref = get_frequency_ref(value),
        synchronous_machine_dynamics = component_id(
            refs, get_synchronous_machine_dynamics(value),
        ),
        shaft = component_id(refs, get_shaft(value)),
        excitation_system_dynamics = component_id(
            refs, get_excitation_system_dynamics(value),
        ),
        turbine_governor_dynamics = component_id(
            refs, get_turbine_governor_dynamics(value),
        ),
        power_system_stabilizer_dynamics = component_id(
            refs, get_power_system_stabilizer_dynamics(value),
        ),
        base_power = get_base_power(value),
    )
end

function to_openapi(value::DynamicInverter, refs::OpenAPIRefs)
    return PD.DynamicInverter(;
        id = component_id(refs, value),
        name = get_name(value),
        frequency_ref = get_frequency_ref(value),
        converter = component_id(refs, get_converter(value)),
        active_power_control = component_id(refs, get_active_power_control(value)),
        reactive_power_control = component_id(refs, get_reactive_power_control(value)),
        inner_control = component_id(refs, get_inner_control(value)),
        dc_source = component_id(refs, get_dc_source(value)),
        reference_frame_rotation = component_id(
            refs, get_reference_frame_rotation(value),
        ),
        filter = component_id(refs, get_filter(value)),
        current_limitation = _component_id_optional(refs, get_current_limitation(value)),
        base_power = get_base_power(value),
    )
end

"""A component with no dynamics converter is a gap to close, not a component to drop."""
function to_openapi(value::Union{DynamicInjection, DynamicComponent}, ::OpenAPIRefs)
    return error(
        "to_openapi: no OpenAPI converter for $(typeof(value)) — every dynamics " *
        "component must be exported, not skipped",
    )
end
