# Hand-written (not generated): the reverse of src/openapi/import_handwritten.jl — PSY →
# PO for the types whose `from_openapi` had to be hand-written: abstract-typed references,
# fields with no device-level `base_power`, unclassifiable field kinds, a PSY/PO field-name
# mismatch, semantic (not unit) conversions, and the parametric reserves — see that file's
# header for the full reasoning per type, unchanged here.
#
# Reuses `_minmax_po*`/`_updown_po*`/`_fromto_po`/`_scale_optional_po` from
# export_generated_types.jl (included first) rather than redefining them.

# ── Arc ─────────────────────────────────────────────────────────────────────────
# No unit-converted fields; both unit-system methods identical (mirrors import).

function to_openapi(arc::Arc, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.Arc(;
        id = component_id(refs, arc),
        from_id = component_id(refs, get_from(arc)),
        to_id = component_id(refs, get_to(arc)),
    )
end

function to_openapi(arc::Arc, refs::OpenAPIRefs, ::NaturalUnit)
    return to_openapi(arc, refs, CU)
end

# ── Area / LoadZone ─────────────────────────────────────────────────────────────
# peak_active_power/peak_reactive_power are discriminated by `power_units` like every other
# power-family field: COMPONENT_BASE writes the pu value as-is, NATURAL_UNITS multiplies by
# `get_base_power(refs)`. `load_response` has no `conversion_unit` and passes through
# unconverted in both.

function to_openapi(area::Area, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.Area(;
        id = component_id(refs, area),
        name = get_name(area),
        peak_active_power = get_peak_active_power(area, u"SU"),
        peak_reactive_power = get_peak_reactive_power(area, u"SU"),
        load_response = get_load_response(area),
        base_power = get_base_power(refs),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(area::Area, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.Area(;
        id = component_id(refs, area),
        name = get_name(area),
        peak_active_power = get_peak_active_power(area, u"SU") * get_base_power(refs),
        peak_reactive_power = get_peak_reactive_power(area, u"SU") * get_base_power(refs),
        load_response = get_load_response(area),
        base_power = get_base_power(refs),
        power_units = _power_units_string(NU),
    )
end

function to_openapi(lz::LoadZone, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.LoadZone(;
        id = component_id(refs, lz),
        name = get_name(lz),
        peak_active_power = get_peak_active_power(lz, u"SU"),
        peak_reactive_power = get_peak_reactive_power(lz, u"SU"),
        base_power = get_base_power(refs),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(lz::LoadZone, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.LoadZone(;
        id = component_id(refs, lz),
        name = get_name(lz),
        peak_active_power = get_peak_active_power(lz, u"SU") * get_base_power(refs),
        peak_reactive_power = get_peak_reactive_power(lz, u"SU") * get_base_power(refs),
        base_power = get_base_power(refs),
        power_units = _power_units_string(NU),
    )
end

# ── TransmissionInterface ───────────────────────────────────────────────────────
# `active_power_flow_limits` is discriminated by `power_units` like every other power-family
# field, mirroring Area/LoadZone above. `violation_penalty`/`direction_mapping` have no
# `conversion_unit` and pass through unconverted in both.

function to_openapi(tx::TransmissionInterface, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.TransmissionInterface(;
        id = component_id(refs, tx),
        name = get_name(tx),
        available = get_available(tx),
        active_power_flow_limits = _minmax_po(get_active_power_flow_limits(tx, u"SU")),
        violation_penalty = get_violation_penalty(tx),
        direction_mapping = PO.TransmissionInterfaceDirectionMapping(;
            additional_properties = get_direction_mapping(tx),
        ),
        base_power = get_base_power(refs),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(tx::TransmissionInterface, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.TransmissionInterface(;
        id = component_id(refs, tx),
        name = get_name(tx),
        available = get_available(tx),
        active_power_flow_limits = _minmax_po_scaled(
            get_active_power_flow_limits(tx, u"SU"),
            get_base_power(refs),
        ),
        violation_penalty = get_violation_penalty(tx),
        direction_mapping = PO.TransmissionInterfaceDirectionMapping(;
            additional_properties = get_direction_mapping(tx),
        ),
        base_power = get_base_power(refs),
        power_units = _power_units_string(NU),
    )
end

# ── Line ────────────────────────────────────────────────────────────────────────
# `r`/`x`/`b`/`g` are pu on system base already (identity in both methods). `rating`/
# `rating_b`/`rating_c`/`active_power_flow`/`reactive_power_flow` are pu on system base in PSY;
# `base_power` on export is `get_base_power(refs)` exactly — the document's per-line
# base_power is the denormalized system base, not reconstructed.

function to_openapi(line::Line, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.Line(;
        id = component_id(refs, line),
        name = get_name(line),
        available = get_available(line),
        active_power_flow = get_active_power_flow(line, u"SU"),
        reactive_power_flow = get_reactive_power_flow(line, u"SU"),
        arc = component_id(refs, get_arc(line)),
        r = get_r(line, u"SU"),
        x = get_x(line, u"SU"),
        base_power = get_base_power(refs),
        b = _fromto_po(get_b(line, u"SU")),
        rating = get_rating(line, u"SU"),
        rating_b = _optional_to_wire(get_rating_b(line, u"SU")),
        rating_c = _optional_to_wire(get_rating_c(line, u"SU")),
        angle_limits = _minmax_po(get_angle_limits(line)),
        g = _fromto_po(get_g(line, u"SU")),
        operational_flow_limit = _operational_flow_limit_po_optional(
            get_operational_flow_limit(line, u"SU"),
        ),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(line::Line, refs::OpenAPIRefs, ::NaturalUnit)
    sbp = get_base_power(refs)
    return PO.Line(;
        id = component_id(refs, line),
        name = get_name(line),
        available = get_available(line),
        active_power_flow = get_active_power_flow(line, u"SU") * sbp,
        reactive_power_flow = get_reactive_power_flow(line, u"SU") * sbp,
        arc = component_id(refs, get_arc(line)),
        r = get_r(line, u"SU"),
        x = get_x(line, u"SU"),
        base_power = sbp,
        b = _fromto_po(get_b(line, u"SU")),
        rating = get_rating(line, u"SU") * sbp,
        rating_b = _scale_optional_po(get_rating_b(line, u"SU"), sbp),
        rating_c = _scale_optional_po(get_rating_c(line, u"SU"), sbp),
        angle_limits = _minmax_po(get_angle_limits(line)),
        g = _fromto_po(get_g(line, u"SU")),
        operational_flow_limit = _operational_flow_limit_po_scaled_optional(
            get_operational_flow_limit(line, u"SU"), sbp,
        ),
        power_units = _power_units_string(NU),
    )
end

# ── HybridSystem ────────────────────────────────────────────────────────────────
# Component base. The four subcomponent references are optional on the PSY side, so they go
# through `_component_id_optional`. `reserves`-style membership does not apply here; the
# subcomponents are genuine fields.

function to_openapi(hyb::HybridSystem, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.HybridSystem(;
        id = component_id(refs, hyb),
        name = get_name(hyb),
        available = get_available(hyb),
        status = PO.OperationalStates(string(get_status(hyb))),
        bus = component_id(refs, get_bus(hyb)),
        active_power = get_active_power(hyb, u"CU"),
        reactive_power = get_reactive_power(hyb, u"CU"),
        base_power = _get_base_power(hyb),
        operation_cost = convert_cost_to_openapi(get_operation_cost(hyb)),
        thermal_unit = _component_id_optional(refs, get_thermal_unit(hyb)),
        electric_load = _component_id_optional(refs, get_electric_load(hyb)),
        storage = _component_id_optional(refs, get_storage(hyb)),
        renewable_unit = _component_id_optional(refs, get_renewable_unit(hyb)),
        interconnection_impedance = _complex_number_po(
            get_interconnection_impedance(hyb),
        ),
        interconnection_rating = get_interconnection_rating(hyb, u"CU"),
        input_active_power_limits = _minmax_po_optional(
            get_input_active_power_limits(hyb, u"CU"),
        ),
        output_active_power_limits = _minmax_po_optional(
            get_output_active_power_limits(hyb, u"CU"),
        ),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(hyb, u"CU")),
        interconnection_efficiency = _inout_po_optional(
            get_interconnection_efficiency(hyb),
        ),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(hyb::HybridSystem, refs::OpenAPIRefs, ::NaturalUnit)
    dbp = _get_base_power(hyb)
    return PO.HybridSystem(;
        id = component_id(refs, hyb),
        name = get_name(hyb),
        available = get_available(hyb),
        status = PO.OperationalStates(string(get_status(hyb))),
        bus = component_id(refs, get_bus(hyb)),
        active_power = get_active_power(hyb, u"CU") * dbp,
        reactive_power = get_reactive_power(hyb, u"CU") * dbp,
        base_power = dbp,
        operation_cost = convert_cost_to_openapi(get_operation_cost(hyb)),
        thermal_unit = _component_id_optional(refs, get_thermal_unit(hyb)),
        electric_load = _component_id_optional(refs, get_electric_load(hyb)),
        storage = _component_id_optional(refs, get_storage(hyb)),
        renewable_unit = _component_id_optional(refs, get_renewable_unit(hyb)),
        interconnection_impedance = _complex_number_po(
            get_interconnection_impedance(hyb),
        ),
        interconnection_rating = _scale_optional_po(
            get_interconnection_rating(hyb, u"CU"), dbp,
        ),
        input_active_power_limits = _minmax_po_scaled_optional(
            get_input_active_power_limits(hyb, u"CU"), dbp,
        ),
        output_active_power_limits = _minmax_po_scaled_optional(
            get_output_active_power_limits(hyb, u"CU"), dbp,
        ),
        reactive_power_limits = _minmax_po_scaled_optional(
            get_reactive_power_limits(hyb, u"CU"), dbp,
        ),
        interconnection_efficiency = _inout_po_optional(
            get_interconnection_efficiency(hyb),
        ),
        power_units = _power_units_string(NU),
    )
end

# ── Source ──────────────────────────────────────────────────────────────────────
# Component base: the MVA/MW fields multiply back by the source's own `base_power`, not the
# document system base.

function to_openapi(src::Source, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.Source(;
        id = component_id(refs, src),
        name = get_name(src),
        available = get_available(src),
        bus = component_id(refs, get_bus(src)),
        active_power = get_active_power(src, u"CU"),
        reactive_power = get_reactive_power(src, u"CU"),
        active_power_limits = _minmax_po(get_active_power_limits(src, u"CU")),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(src, u"CU")),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r_th = get_R_th(src),
        x_th = get_X_th(src),
        internal_voltage = get_internal_voltage(src, u"CU"),
        internal_angle = get_internal_angle(src),
        base_voltage = _optional_to_wire(get_base_voltage(src)),
        base_power = _get_base_power(src),
        operation_cost = PO.SourceOperationCost(
            convert_cost_to_openapi(get_operation_cost(src)),
        ),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(src::Source, refs::OpenAPIRefs, ::NaturalUnit)
    dbp = _get_base_power(src)
    return PO.Source(;
        id = component_id(refs, src),
        name = get_name(src),
        available = get_available(src),
        bus = component_id(refs, get_bus(src)),
        active_power = get_active_power(src, u"CU") * dbp,
        reactive_power = get_reactive_power(src, u"CU") * dbp,
        active_power_limits = _minmax_po_scaled(get_active_power_limits(src, u"CU"), dbp),
        reactive_power_limits = _minmax_po_scaled_optional(
            get_reactive_power_limits(src, u"CU"), dbp,
        ),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r_th = get_R_th(src),
        x_th = get_X_th(src),
        internal_voltage = get_internal_voltage(src, u"CU"),
        internal_angle = get_internal_angle(src),
        base_voltage = _optional_to_wire(get_base_voltage(src)),
        base_power = dbp,
        operation_cost = PO.SourceOperationCost(
            convert_cost_to_openapi(get_operation_cost(src)),
        ),
        power_units = _power_units_string(NU),
    )
end

# ── TModelHVDCLine ──────────────────────────────────────────────────────────────
# `active_power_flow`/`operational_flow_limit` declare x-unit "MW"
# outright — fixed natural units, no `power_units` discriminator on this PO struct (see the
# schema and import_handwritten.jl's header on this exact point) — so they multiply by
# `get_base_power(refs)` in both methods, same posture as reserves' `requirement`. Both
# methods are therefore identical, hence the trivial `CU` delegate below. `r`/`l`/`c` are
# stored in ohm/H/F and `base_current` in A, so all pass through.

function to_openapi(line::TModelHVDCLine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    sbp = get_base_power(refs)
    return PO.TModelHVDCLine(;
        id = component_id(refs, line),
        name = get_name(line),
        available = get_available(line),
        active_power_flow = get_active_power_flow(line, u"SU") * sbp,
        arc = component_id(refs, get_arc(line)),
        base_current = get_base_current(line),
        r = get_r(line),
        l = get_l(line),
        c = get_c(line),
        operational_flow_limit = _operational_flow_limit_po_scaled_optional(
            get_operational_flow_limit(line, u"SU"), sbp,
        ),
    )
end

function to_openapi(line::TModelHVDCLine, refs::OpenAPIRefs, ::NaturalUnit)
    return to_openapi(line, refs, CU)
end

# ── InterconnectingConverter ────────────────────────────────────────────────────
# Component base for the power fields. `dc_current`/`max_dc_current` (A), the voltage fields (kV)
# and `dc_voltage_droop` (kV/MW) are natural and pass through in both methods.

function to_openapi(conv::InterconnectingConverter, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.InterconnectingConverter(;
        id = component_id(refs, conv),
        name = get_name(conv),
        available = get_available(conv),
        bus = component_id(refs, get_bus(conv)),
        dc_bus = component_id(refs, get_dc_bus(conv)),
        active_power = get_active_power(conv, u"CU"),
        rating = get_rating(conv, u"CU"),
        active_power_limits = _minmax_po(get_active_power_limits(conv, u"CU")),
        base_power = _get_base_power(conv),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(conv, u"CU")),
        dc_current = get_dc_current(conv),
        max_dc_current = get_max_dc_current(conv),
        loss_function = _hvdc_loss_to_openapi(get_loss_function(conv)),
        dc_control = PO.VSCDCControlModes(string(get_dc_control(conv))),
        ac_control = PO.VSCACControlModes(string(get_ac_control(conv))),
        dc_power_setpoint = _optional_to_wire(get_dc_power_setpoint(conv, u"CU")),
        dc_voltage_setpoint = _optional_to_wire(get_dc_voltage_setpoint(conv)),
        power_factor_setpoint = _optional_to_wire(get_power_factor_setpoint(conv)),
        ac_voltage_setpoint = _optional_to_wire(get_ac_voltage_setpoint(conv)),
        dc_voltage_droop = get_dc_voltage_droop(conv),
        remote_bus_control = get_remote_bus_control(conv),
        power_factor_weighting_fraction = get_power_factor_weighting_fraction(conv),
        voltage_limits = _minmax_po(get_voltage_limits(conv)),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(conv::InterconnectingConverter, refs::OpenAPIRefs, ::NaturalUnit)
    dbp = _get_base_power(conv)
    return PO.InterconnectingConverter(;
        id = component_id(refs, conv),
        name = get_name(conv),
        available = get_available(conv),
        bus = component_id(refs, get_bus(conv)),
        dc_bus = component_id(refs, get_dc_bus(conv)),
        active_power = get_active_power(conv, u"CU") * dbp,
        rating = get_rating(conv, u"CU") * dbp,
        active_power_limits = _minmax_po_scaled(get_active_power_limits(conv, u"CU"), dbp),
        base_power = dbp,
        reactive_power_limits = _minmax_po_scaled_optional(
            get_reactive_power_limits(conv, u"CU"), dbp,
        ),
        dc_current = get_dc_current(conv),
        max_dc_current = get_max_dc_current(conv),
        loss_function = _hvdc_loss_to_openapi(get_loss_function(conv)),
        dc_control = PO.VSCDCControlModes(string(get_dc_control(conv))),
        ac_control = PO.VSCACControlModes(string(get_ac_control(conv))),
        dc_power_setpoint = _scale_optional_po(get_dc_power_setpoint(conv, u"CU"), dbp),
        dc_voltage_setpoint = _optional_to_wire(get_dc_voltage_setpoint(conv)),
        power_factor_setpoint = _optional_to_wire(get_power_factor_setpoint(conv)),
        ac_voltage_setpoint = _optional_to_wire(get_ac_voltage_setpoint(conv)),
        dc_voltage_droop = get_dc_voltage_droop(conv),
        remote_bus_control = get_remote_bus_control(conv),
        power_factor_weighting_fraction = get_power_factor_weighting_fraction(conv),
        voltage_limits = _minmax_po(get_voltage_limits(conv)),
        power_units = _power_units_string(NU),
    )
end

# ── GenericArcImpedance ─────────────────────────────────────────────────────────
# `parameter_units` is stated rather than derived: the import side only accepts
# "COMPONENT_BASE", so that is what export writes.

function to_openapi(branch::GenericArcImpedance, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.GenericArcImpedance(;
        id = component_id(refs, branch),
        name = get_name(branch),
        available = get_available(branch),
        active_power_flow = get_active_power_flow(branch, u"SU"),
        reactive_power_flow = get_reactive_power_flow(branch, u"SU"),
        operational_flow_limit = _operational_flow_limit_po_optional(
            get_operational_flow_limit(branch, u"SU"),
        ),
        arc = component_id(refs, get_arc(branch)),
        base_power = get_base_power(refs),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r = get_r(branch, u"SU"),
        x = get_x(branch, u"SU"),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(branch::GenericArcImpedance, refs::OpenAPIRefs, ::NaturalUnit)
    sbp = get_base_power(refs)
    return PO.GenericArcImpedance(;
        id = component_id(refs, branch),
        name = get_name(branch),
        available = get_available(branch),
        active_power_flow = get_active_power_flow(branch, u"SU") * sbp,
        reactive_power_flow = get_reactive_power_flow(branch, u"SU") * sbp,
        operational_flow_limit = _operational_flow_limit_po_scaled_optional(
            get_operational_flow_limit(branch, u"SU"), sbp,
        ),
        arc = component_id(refs, get_arc(branch)),
        base_power = sbp,
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r = get_r(branch, u"SU"),
        x = get_x(branch, u"SU"),
        power_units = _power_units_string(NU),
    )
end

# ── DiscreteControlledACBranch ───────────────────────────────────────────────────
# `active_power_flow`/`reactive_power_flow`/`r`/`x` are declared `SU` (system base), `rating`
# is declared `CU` — numerically identical for this type since `add_component!` keeps its
# `base_power` synced to the System's, but the identity accessor for each field must still
# match its own declared tier.

function to_openapi(
    branch::DiscreteControlledACBranch,
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
)
    return PO.DiscreteControlledACBranch(;
        id = component_id(refs, branch),
        name = get_name(branch),
        available = get_available(branch),
        active_power_flow = get_active_power_flow(branch, u"SU"),
        reactive_power_flow = get_reactive_power_flow(branch, u"SU"),
        arc = component_id(refs, get_arc(branch)),
        base_power = _get_base_power(branch),
        r = get_r(branch, u"SU"),
        x = get_x(branch, u"SU"),
        rating = get_rating(branch, u"CU"),
        discrete_branch_type = PO.DiscreteControlledACBranchDiscreteBranchType(
            string(get_discrete_branch_type(
                branch,
            )),
        ),
        branch_status = PO.DiscreteControlledACBranchBranchStatus(
            string(get_branch_status(branch)),
        ),
        normal_branch_status = PO.DiscreteControlledACBranchNormalBranchStatus(
            string(get_normal_branch_status(
                branch,
            )),
        ),
        operational_flow_limit = _operational_flow_limit_po_optional(
            get_operational_flow_limit(branch, u"SU"),
        ),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(branch::DiscreteControlledACBranch, refs::OpenAPIRefs, ::NaturalUnit)
    bp = _get_base_power(branch)
    return PO.DiscreteControlledACBranch(;
        id = component_id(refs, branch),
        name = get_name(branch),
        available = get_available(branch),
        active_power_flow = get_active_power_flow(branch, u"SU") * bp,
        reactive_power_flow = get_reactive_power_flow(branch, u"SU") * bp,
        arc = component_id(refs, get_arc(branch)),
        base_power = bp,
        r = get_r(branch, u"SU"),
        x = get_x(branch, u"SU"),
        rating = get_rating(branch, u"CU") * bp,
        discrete_branch_type = PO.DiscreteControlledACBranchDiscreteBranchType(
            string(get_discrete_branch_type(
                branch,
            )),
        ),
        branch_status = PO.DiscreteControlledACBranchBranchStatus(
            string(get_branch_status(branch)),
        ),
        normal_branch_status = PO.DiscreteControlledACBranchNormalBranchStatus(
            string(get_normal_branch_status(
                branch,
            )),
        ),
        operational_flow_limit = _operational_flow_limit_po_scaled_optional(
            get_operational_flow_limit(branch, u"SU"), bp,
        ),
        power_units = _power_units_string(NU),
    )
end

# ── TransformerCircuit ──────────────────────────────────────────────────────────
# `r`/`x` are pu on the circuit's own `base_power` and identity in both marker methods
# (`parameter_units` is always emitted as "COMPONENT_BASE", the only basis this pass implements
# on either side). `rating`/`rating_b`/`rating_c`/`active_power_flow`/`reactive_power_flow`
# scale by the circuit's own `base_power` under NATURAL_UNITS only.
# Reached only via its owning `TwoWindingTransformer`'s `to_openapi` — never a standalone
# System component (no `addable` entry of its own), so this method is called directly on the
# `TransformerCircuit` object the document walk already resolved to an id.

function to_openapi(circuit::TransformerCircuit, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.TransformerCircuit(;
        id = component_id(refs, circuit),
        available = get_available(circuit),
        arc = component_id(refs, get_arc(circuit)),
        tap = get_tap(circuit),
        alpha = get_α(circuit),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r = get_r(circuit, u"CU"),
        x = get_x(circuit, u"CU"),
        control_objective = PO.TransformerControlObjective(
            string(get_control_objective(
                circuit,
            )),
        ),
        regulated_bus_number = get_regulated_bus_number(circuit),
        tap_ratio_limits = _minmax_po_optional(get_tap_ratio_limits(circuit)),
        phase_angle_limits = _minmax_po_optional(get_phase_angle_limits(circuit)),
        controlled_voltage_limits =
        _minmax_po_optional(get_controlled_voltage_limits(circuit)),
        controlled_reactive_power_flow_limits =
        _minmax_po_optional(get_controlled_reactive_power_flow_limits(circuit, u"CU")),
        controlled_active_power_flow_limits =
        _minmax_po_optional(get_controlled_active_power_flow_limits(circuit, u"CU")),
        number_of_tap_positions = get_number_of_tap_positions(circuit),
        rating = get_rating(circuit, u"CU"),
        rating_b = _optional_to_wire(get_rating_b(circuit, u"CU")),
        rating_c = _optional_to_wire(get_rating_c(circuit, u"CU")),
        active_power_flow = get_active_power_flow(circuit, u"CU"),
        reactive_power_flow = get_reactive_power_flow(circuit, u"CU"),
        base_power = get_base_power(circuit),
        base_voltage_primary = _optional_to_wire(get_base_voltage_primary(circuit)),
        base_voltage_secondary = _optional_to_wire(get_base_voltage_secondary(circuit)),
        operational_flow_limit = _operational_flow_limit_po_optional(
            get_operational_flow_limit(circuit, u"CU"),
        ),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(circuit::TransformerCircuit, refs::OpenAPIRefs, ::NaturalUnit)
    dbp = get_base_power(circuit)
    return PO.TransformerCircuit(;
        id = component_id(refs, circuit),
        available = get_available(circuit),
        arc = component_id(refs, get_arc(circuit)),
        tap = get_tap(circuit),
        alpha = get_α(circuit),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r = get_r(circuit, u"CU"),
        x = get_x(circuit, u"CU"),
        control_objective = PO.TransformerControlObjective(
            string(get_control_objective(
                circuit,
            )),
        ),
        regulated_bus_number = get_regulated_bus_number(circuit),
        tap_ratio_limits = _minmax_po_optional(get_tap_ratio_limits(circuit)),
        phase_angle_limits = _minmax_po_optional(get_phase_angle_limits(circuit)),
        controlled_voltage_limits =
        _minmax_po_optional(get_controlled_voltage_limits(circuit)),
        controlled_reactive_power_flow_limits = _minmax_po_scaled_optional(
            get_controlled_reactive_power_flow_limits(circuit, u"CU"), dbp,
        ),
        controlled_active_power_flow_limits = _minmax_po_scaled_optional(
            get_controlled_active_power_flow_limits(circuit, u"CU"), dbp,
        ),
        number_of_tap_positions = get_number_of_tap_positions(circuit),
        rating = get_rating(circuit, u"CU") * dbp,
        rating_b = _scale_optional_po(get_rating_b(circuit, u"CU"), dbp),
        rating_c = _scale_optional_po(get_rating_c(circuit, u"CU"), dbp),
        active_power_flow = get_active_power_flow(circuit, u"CU") * dbp,
        reactive_power_flow = get_reactive_power_flow(circuit, u"CU") * dbp,
        base_power = dbp,
        base_voltage_primary = _optional_to_wire(get_base_voltage_primary(circuit)),
        base_voltage_secondary = _optional_to_wire(get_base_voltage_secondary(circuit)),
        operational_flow_limit = _operational_flow_limit_po_scaled_optional(
            get_operational_flow_limit(circuit, u"CU"), dbp,
        ),
        power_units = _power_units_string(NU),
    )
end

# ── TwoWindingTransformer ───────────────────────────────────────────────────────
# `magnetizing_shunt` is pu on the circuit's `base_power` and identity in both document unit
# systems (mirrors import).

function to_openapi(xfmr::TwoWindingTransformer, refs::OpenAPIRefs, ::ComponentBaseUnit)
    circuit = get_circuit(xfmr)
    shunt = get_magnetizing_shunt(xfmr, u"CU")
    return PO.TwoWindingTransformer(;
        id = component_id(refs, xfmr),
        name = get_name(xfmr),
        circuit = component_id(refs, circuit),
        admittance_units = PO.AdmittanceUnitBasis("COMPONENT_BASE"),
        magnetizing_shunt = _complex_number_po(shunt),
        shunt_location = PO.TwoWindingTransformerShuntLocation(
            string(get_shunt_location(
                xfmr,
            )),
        ),
    )
end

function to_openapi(xfmr::TwoWindingTransformer, refs::OpenAPIRefs, ::NaturalUnit)
    return to_openapi(xfmr, refs, CU)
end

# ── ThreeWindingTransformer ──────────────────────────────────────────────────────
# Mirrors TwoWindingTransformer's `magnetizing_shunt` handling exactly. The pairwise
# impedances and their base powers are identity in CU (mirrors import); `parameter_units`/
# `admittance_units` are always emitted as "COMPONENT_BASE", the only basis implemented on either
# side. `primary_circuit`/`secondary_circuit`/`tertiary_circuit`/`star_bus` resolve via
# `component_id` because the circuits are registered as standalone document rows by
# `_plan_components` (export_document.jl), matching how import consumes them.

function to_openapi(xfmr::ThreeWindingTransformer, refs::OpenAPIRefs, ::ComponentBaseUnit)
    shunt = get_magnetizing_shunt(xfmr, u"CU")
    return PO.ThreeWindingTransformer(;
        id = component_id(refs, xfmr),
        name = get_name(xfmr),
        primary_circuit = component_id(refs, get_primary_circuit(xfmr)),
        secondary_circuit = component_id(refs, get_secondary_circuit(xfmr)),
        tertiary_circuit = component_id(refs, get_tertiary_circuit(xfmr)),
        star_bus = component_id(refs, get_star_bus(xfmr)),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r_12 = _optional_to_wire(get_r_12(xfmr, u"CU")),
        x_12 = _optional_to_wire(get_x_12(xfmr, u"CU")),
        r_23 = _optional_to_wire(get_r_23(xfmr, u"CU")),
        x_23 = _optional_to_wire(get_x_23(xfmr, u"CU")),
        r_31 = _optional_to_wire(get_r_31(xfmr, u"CU")),
        x_31 = _optional_to_wire(get_x_31(xfmr, u"CU")),
        base_power_12 = _optional_to_wire(get_base_power_12(xfmr)),
        base_power_23 = _optional_to_wire(get_base_power_23(xfmr)),
        base_power_31 = _optional_to_wire(get_base_power_31(xfmr)),
        admittance_units = PO.AdmittanceUnitBasis("COMPONENT_BASE"),
        magnetizing_shunt = _complex_number_po(shunt),
        shunt_location = PO.ThreeWindingTransformerShuntLocation(
            string(get_shunt_location(
                xfmr,
            )),
        ),
    )
end

function to_openapi(xfmr::ThreeWindingTransformer, refs::OpenAPIRefs, ::NaturalUnit)
    return to_openapi(xfmr, refs, CU)
end

# ── FixedAdmittance ─────────────────────────────────────────────────────────────
# `Y` is stored in PSY as pu on the system base, but the wire enum has no system-base
# member: `ShuntAdmittanceUnitBasis` is `NATURAL_UNITS`/`COMPONENT_MVAR` only, because a shunt
# has no device MVA rating of its own. Export therefore states `COMPONENT_MVAR` (MVAr at unity
# voltage) and multiplies by `get_base_power(refs)`, exactly inverting the `COMPONENT_MVAR`
# division in `_fixed_admittance_pu`, in both methods.

function to_openapi(shunt::FixedAdmittance, refs::OpenAPIRefs, ::ComponentBaseUnit)
    y = get_Y(shunt) * get_base_power(refs)
    return PO.FixedAdmittance(;
        id = component_id(refs, shunt),
        name = get_name(shunt),
        available = get_available(shunt),
        bus = component_id(refs, get_bus(shunt)),
        admittance_units = PO.ShuntAdmittanceUnitBasis("COMPONENT_MVAR"),
        y = _complex_number_po(y),
        # FixedAdmittance's base_power_kind is SystemBasePower (components.jl): the field is
        # kept in sync by add_component!, not authoritative on its own, so read `refs`'s
        # anchor (per `openapi_export_base_source` in generate_structs.jl), same as `y` above.
        base_power = get_base_power(refs),
    )
end

function to_openapi(shunt::FixedAdmittance, refs::OpenAPIRefs, ::NaturalUnit)
    return to_openapi(shunt, refs, CU)
end

# ── SwitchedAdmittance ────────────────────────────────────────────────────────────
# Mirrors `FixedAdmittance`: `Y_increase` and `solved_admittance` are fixed-natural
# COMPONENT_MVAR-on-system-base in both methods, so `NaturalUnit` delegates to
# `ComponentBaseUnit`.

_switched_admittance_solved_po(value, base_power) =
    isnothing(value) ? nothing : value * base_power

function to_openapi(shunt::SwitchedAdmittance, refs::OpenAPIRefs, ::ComponentBaseUnit)
    base_power = get_base_power(refs)
    y_increase = [
        _complex_number_po(v * base_power) for v in get_Y_increase(shunt)
    ]
    return PO.SwitchedAdmittance(;
        id = component_id(refs, shunt),
        name = get_name(shunt),
        available = get_available(shunt),
        bus = component_id(refs, get_bus(shunt)),
        admittance_units = PO.ShuntAdmittanceUnitBasis("COMPONENT_MVAR"),
        number_engaged = get_number_engaged(shunt),
        number_of_steps = get_number_of_steps(shunt),
        y_increase = y_increase,
        solved_admittance = _switched_admittance_solved_po(
            get_solved_admittance(shunt),
            base_power,
        ),
        voltage_limits = _minmax_po_optional(get_voltage_limits(shunt)),
        reactive_power_range_limits =
        _minmax_po_optional(get_reactive_power_range_limits(shunt)),
        control_mode = PO.SwitchedAdmittanceControlMode(string(get_control_mode(shunt))),
        regulated_bus_number = get_regulated_bus_number(shunt),
    )
end

function to_openapi(shunt::SwitchedAdmittance, refs::OpenAPIRefs, ::NaturalUnit)
    return to_openapi(shunt, refs, CU)
end

# ── FACTSControlDevice ────────────────────────────────────────────────────────────
# `max_shunt_current`/`max_reactive_power` are discriminated by `power_units` like every other
# power-family field: COMPONENT_BASE writes the pu value as-is, NATURAL_UNITS multiplies by the
# device's own `base_power`. `voltage_setpoint` is always exported as "COMPONENT_BASE" (the only
# basis import implements).

function to_openapi(device::FACTSControlDevice, refs::OpenAPIRefs, ::ComponentBaseUnit)
    control_mode = get_control_mode(device)
    return PO.FACTSControlDevice(;
        id = component_id(refs, device),
        name = get_name(device),
        available = get_available(device),
        bus = component_id(refs, get_bus(device)),
        control_mode = if isnothing(control_mode)
            nothing
        else
            PO.FACTSControlDeviceControlMode(string(control_mode))
        end,
        voltage_setpoint_units = PO.VoltageUnitBasis("COMPONENT_BASE"),
        voltage_setpoint = get_voltage_setpoint(device),
        max_shunt_current = get_max_shunt_current(device, u"SU"),
        reactive_power_required = get_reactive_power_required(device),
        max_reactive_power = get_max_reactive_power(device, u"SU"),
        shunt_control_type = PO.FACTSControlDeviceShuntControlType(
            string(get_shunt_control_type(
                device,
            )),
        ),
        regulated_bus_number = get_regulated_bus_number(device),
        base_power = _get_base_power(device),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(device::FACTSControlDevice, refs::OpenAPIRefs, ::NaturalUnit)
    base_power = _get_base_power(device)
    control_mode = get_control_mode(device)
    return PO.FACTSControlDevice(;
        id = component_id(refs, device),
        name = get_name(device),
        available = get_available(device),
        bus = component_id(refs, get_bus(device)),
        control_mode = if isnothing(control_mode)
            nothing
        else
            PO.FACTSControlDeviceControlMode(string(control_mode))
        end,
        voltage_setpoint_units = PO.VoltageUnitBasis("COMPONENT_BASE"),
        voltage_setpoint = get_voltage_setpoint(device),
        max_shunt_current = get_max_shunt_current(device, u"SU") * base_power,
        reactive_power_required = get_reactive_power_required(device),
        max_reactive_power = get_max_reactive_power(device, u"SU") * base_power,
        shunt_control_type = PO.FACTSControlDeviceShuntControlType(
            string(get_shunt_control_type(
                device,
            )),
        ),
        regulated_bus_number = get_regulated_bus_number(device),
        base_power = base_power,
        power_units = _power_units_string(NU),
    )
end

# ── TwoTerminalGenericHVDCLine ──────────────────────────────────────────────────
# No component base; power fields fall back to the document-level system base
# (`get_base_power(refs)`), same fallback reserves use. `loss` dispatches on PSY's two allowed
# `ValueCurve` shapes (`InputOutputCurve` for a linear loss, `IncrementalCurve` for a piecewise
# incremental one) — the import converter only implements the linear case, but PSY's own field
# type allows both (a `System` built directly, not round-tripped, may hold either), so export
# supports both rather than narrowing to what import currently reads.

# The schemas' `LossCurve` records the basis in its own required `power_units`, so the curve
# travels on whatever basis PSY holds it and import reads the same field back (`_hvdc_loss`).
function _hvdc_loss_to_openapi(loss::AnyLossCurve)
    return PC.LossCurve(;
        power_units = _power_units_string(get_power_units(loss)),
        value_curve = PC.LossValueCurve(
            convert_cost_to_openapi(loss_curve_to_openapi(loss)),
        ),
    )
end

function to_openapi(
    hvdc::TwoTerminalGenericHVDCLine,
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
)
    return PO.TwoTerminalGenericHVDCLine(;
        id = component_id(refs, hvdc),
        name = get_name(hvdc),
        available = get_available(hvdc),
        active_power_flow = get_active_power_flow(hvdc, u"SU"),
        arc = component_id(refs, get_arc(hvdc)),
        rating = get_rating(hvdc, u"SU"),
        reactive_power_limits_from = _minmax_po(
            get_reactive_power_limits_from(hvdc, u"SU"),
        ),
        reactive_power_limits_to = _minmax_po(get_reactive_power_limits_to(hvdc, u"SU")),
        rating_from = get_rating_from(hvdc, u"SU"),
        rating_to = get_rating_to(hvdc, u"SU"),
        loss = _hvdc_loss_to_openapi(get_loss(hvdc)),
        base_power = get_base_power(refs),
        operational_flow_limit = _operational_flow_limit_po_optional(
            get_operational_flow_limit(hvdc, u"SU"),
        ),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(
    hvdc::TwoTerminalGenericHVDCLine,
    refs::OpenAPIRefs,
    ::NaturalUnit,
)
    sbp = get_base_power(refs)
    return PO.TwoTerminalGenericHVDCLine(;
        id = component_id(refs, hvdc),
        name = get_name(hvdc),
        available = get_available(hvdc),
        active_power_flow = get_active_power_flow(hvdc, u"SU") * sbp,
        arc = component_id(refs, get_arc(hvdc)),
        rating = get_rating(hvdc, u"SU") * sbp,
        reactive_power_limits_from =
        _minmax_po_scaled(get_reactive_power_limits_from(hvdc, u"SU"), sbp),
        reactive_power_limits_to = _minmax_po_scaled(
            get_reactive_power_limits_to(hvdc, u"SU"),
            sbp,
        ),
        rating_from = get_rating_from(hvdc, u"SU") * sbp,
        rating_to = get_rating_to(hvdc, u"SU") * sbp,
        loss = _hvdc_loss_to_openapi(get_loss(hvdc)),
        base_power = sbp,
        operational_flow_limit = _operational_flow_limit_po_scaled_optional(
            get_operational_flow_limit(hvdc, u"SU"), sbp,
        ),
        power_units = _power_units_string(NU),
    )
end

# ── TwoTerminalLCCLine ────────────────────────────────────────────────────────────
# Impedances (ohm), voltages (kV) and `current_transfer_setpoint` (A) are stored natural and pass
# through in both methods. Only `active_power_flow`/`rating*`/`reactive_power_limits_*`/
# `power_transfer_setpoint`/`operational_flow_limit` are discriminated by `power_units`,
# multiplying by `base_power` under `NaturalUnit`.

function to_openapi(lcc::TwoTerminalLCCLine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    base_power = _get_base_power(lcc)
    return PO.TwoTerminalLCCLine(;
        id = component_id(refs, lcc),
        name = get_name(lcc),
        available = get_available(lcc),
        arc = component_id(refs, get_arc(lcc)),
        active_power_flow = get_active_power_flow(lcc, u"SU"),
        rating = get_rating(lcc, u"SU"),
        r = get_r(lcc),
        power_transfer_setpoint = _optional_to_wire(
            get_power_transfer_setpoint(lcc, u"SU"),
        ),
        current_transfer_setpoint = _optional_to_wire(get_current_transfer_setpoint(lcc)),
        scheduled_dc_voltage = get_scheduled_dc_voltage(lcc),
        rectifier_bridges = get_rectifier_bridges(lcc),
        rectifier_delay_angle_limits = _minmax_po(get_rectifier_delay_angle_limits(lcc)),
        rectifier_rc = get_rectifier_rc(lcc),
        rectifier_xc = get_rectifier_xc(lcc),
        rectifier_base_voltage = get_rectifier_base_voltage(lcc),
        inverter_bridges = get_inverter_bridges(lcc),
        inverter_extinction_angle_limits = _minmax_po(
            get_inverter_extinction_angle_limits(lcc),
        ),
        inverter_rc = get_inverter_rc(lcc),
        inverter_xc = get_inverter_xc(lcc),
        inverter_base_voltage = get_inverter_base_voltage(lcc),
        control_mode = PO.LCCControlMode(string(get_control_mode(lcc))),
        switch_mode_voltage = get_switch_mode_voltage(lcc),
        compounding_resistance = get_compounding_resistance(lcc),
        min_compounding_voltage = get_min_compounding_voltage(lcc),
        rectifier_transformer_ratio = get_rectifier_transformer_ratio(lcc),
        rectifier_tap_setting = get_rectifier_tap_setting(lcc),
        rectifier_tap_limits = _minmax_po(get_rectifier_tap_limits(lcc)),
        rectifier_tap_step = get_rectifier_tap_step(lcc),
        rectifier_delay_angle = get_rectifier_delay_angle(lcc),
        rectifier_capacitor_reactance = get_rectifier_capacitor_reactance(lcc),
        inverter_transformer_ratio = get_inverter_transformer_ratio(lcc),
        inverter_tap_setting = get_inverter_tap_setting(lcc),
        inverter_tap_limits = _minmax_po(get_inverter_tap_limits(lcc)),
        inverter_tap_step = get_inverter_tap_step(lcc),
        inverter_extinction_angle = get_inverter_extinction_angle(lcc),
        inverter_capacitor_reactance = get_inverter_capacitor_reactance(lcc),
        reactive_power_limits_from = _minmax_po(get_reactive_power_limits_from(lcc, u"SU")),
        reactive_power_limits_to = _minmax_po(get_reactive_power_limits_to(lcc, u"SU")),
        rating_from = get_rating_from(lcc, u"SU"),
        rating_to = get_rating_to(lcc, u"SU"),
        loss = _hvdc_loss_to_openapi(get_loss(lcc)),
        base_power = base_power,
        operational_flow_limit = _operational_flow_limit_po_optional(
            get_operational_flow_limit(lcc, u"SU"),
        ),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(lcc::TwoTerminalLCCLine, refs::OpenAPIRefs, ::NaturalUnit)
    base_power = _get_base_power(lcc)
    return PO.TwoTerminalLCCLine(;
        id = component_id(refs, lcc),
        name = get_name(lcc),
        available = get_available(lcc),
        arc = component_id(refs, get_arc(lcc)),
        active_power_flow = get_active_power_flow(lcc, u"SU") * base_power,
        rating = get_rating(lcc, u"SU") * base_power,
        r = get_r(lcc),
        power_transfer_setpoint =
        _scale_optional_po(get_power_transfer_setpoint(lcc, u"SU"), base_power),
        current_transfer_setpoint = _optional_to_wire(get_current_transfer_setpoint(lcc)),
        scheduled_dc_voltage = get_scheduled_dc_voltage(lcc),
        rectifier_bridges = get_rectifier_bridges(lcc),
        rectifier_delay_angle_limits = _minmax_po(get_rectifier_delay_angle_limits(lcc)),
        rectifier_rc = get_rectifier_rc(lcc),
        rectifier_xc = get_rectifier_xc(lcc),
        rectifier_base_voltage = get_rectifier_base_voltage(lcc),
        inverter_bridges = get_inverter_bridges(lcc),
        inverter_extinction_angle_limits = _minmax_po(
            get_inverter_extinction_angle_limits(lcc),
        ),
        inverter_rc = get_inverter_rc(lcc),
        inverter_xc = get_inverter_xc(lcc),
        inverter_base_voltage = get_inverter_base_voltage(lcc),
        control_mode = PO.LCCControlMode(string(get_control_mode(lcc))),
        switch_mode_voltage = get_switch_mode_voltage(lcc),
        compounding_resistance = get_compounding_resistance(lcc),
        min_compounding_voltage = get_min_compounding_voltage(lcc),
        rectifier_transformer_ratio = get_rectifier_transformer_ratio(lcc),
        rectifier_tap_setting = get_rectifier_tap_setting(lcc),
        rectifier_tap_limits = _minmax_po(get_rectifier_tap_limits(lcc)),
        rectifier_tap_step = get_rectifier_tap_step(lcc),
        rectifier_delay_angle = get_rectifier_delay_angle(lcc),
        rectifier_capacitor_reactance = get_rectifier_capacitor_reactance(lcc),
        inverter_transformer_ratio = get_inverter_transformer_ratio(lcc),
        inverter_tap_setting = get_inverter_tap_setting(lcc),
        inverter_tap_limits = _minmax_po(get_inverter_tap_limits(lcc)),
        inverter_tap_step = get_inverter_tap_step(lcc),
        inverter_extinction_angle = get_inverter_extinction_angle(lcc),
        inverter_capacitor_reactance = get_inverter_capacitor_reactance(lcc),
        reactive_power_limits_from = _minmax_po_scaled(
            get_reactive_power_limits_from(lcc, u"SU"),
            base_power,
        ),
        reactive_power_limits_to = _minmax_po_scaled(
            get_reactive_power_limits_to(lcc, u"SU"),
            base_power,
        ),
        rating_from = get_rating_from(lcc, u"SU") * base_power,
        rating_to = get_rating_to(lcc, u"SU") * base_power,
        loss = _hvdc_loss_to_openapi(get_loss(lcc)),
        base_power = base_power,
        operational_flow_limit = _operational_flow_limit_po_scaled_optional(
            get_operational_flow_limit(lcc, u"SU"), base_power,
        ),
        power_units = _power_units_string(NU),
    )
end

# ── TwoTerminalVSCLine ──────────────────────────────────────────────────────────
# The power-family fields and `dc_power_setpoint_*` multiply by `base_power` under `NaturalUnit`
# only. `g` (S), `voltage_limits_*` (kV), the currents (A) and `dc_voltage_droop_*` (kV/MW) are
# stored natural and pass through. The voltage setpoints are stored per unit of the rated
# voltage the wire does not carry, so they multiply back to kV (`_vsc_setpoint_to_wire`).

"""A setpoint stored per unit of `rated` kV, written as kV; `nothing` is absent on the wire."""
_vsc_setpoint_to_wire(_vsc, ::Nothing, _rated, _field, _rated_field) = IC.ABSENT
function _vsc_setpoint_to_wire(vsc, value, rated, field, rated_field)
    if iszero(rated)
        error(
            "TwoTerminalVSCLine \"$(get_name(vsc))\": $field is $value but $rated_field " *
            "is 0.0, so there is no voltage base to convert it against; set $rated_field",
        )
    end
    return value * rated
end

"""`nothing` is absent on the wire; a present value scales by `power_base`."""
_optional_scaled_to_wire(::Nothing, _power_base) = IC.ABSENT
_optional_scaled_to_wire(value, power_base) = value * power_base

function to_openapi(
    vsc::TwoTerminalVSCLine,
    refs::OpenAPIRefs,
    unit::Union{ComponentBaseUnit, NaturalUnit},
)
    base_power = _get_base_power(vsc)
    power_base = _power_base(base_power, unit)
    rated_dc_voltage = get_rated_dc_voltage(vsc)
    rated_ac_voltage_from = get_rated_ac_voltage_from(vsc)
    rated_ac_voltage_to = get_rated_ac_voltage_to(vsc)
    return PO.TwoTerminalVSCLine(;
        id = component_id(refs, vsc),
        name = get_name(vsc),
        available = get_available(vsc),
        arc = component_id(refs, get_arc(vsc)),
        active_power_flow = get_active_power_flow(vsc, u"SU") * power_base,
        rating = get_rating(vsc, u"SU") * power_base,
        g = get_g(vsc),
        dc_current = get_dc_current(vsc),
        reactive_power_from = get_reactive_power_from(vsc, u"SU") * power_base,
        dc_control_from = PO.VSCDCControlModes(string(get_dc_control_from(vsc))),
        ac_control_from = PO.VSCACControlModes(string(get_ac_control_from(vsc))),
        dc_power_setpoint_from = _optional_scaled_to_wire(
            get_dc_power_setpoint_from(vsc, u"SU"), power_base,
        ),
        dc_voltage_setpoint_from = _vsc_setpoint_to_wire(
            vsc, get_dc_voltage_setpoint_from(vsc), rated_dc_voltage,
            "dc_voltage_setpoint_from", "rated_dc_voltage",
        ),
        power_factor_setpoint_from = _optional_to_wire(get_power_factor_setpoint_from(vsc)),
        ac_voltage_setpoint_from = _vsc_setpoint_to_wire(
            vsc, get_ac_voltage_setpoint_from(vsc), rated_ac_voltage_from,
            "ac_voltage_setpoint_from", "rated_ac_voltage_from",
        ),
        rated_ac_voltage_from = rated_ac_voltage_from,
        converter_loss_from = _hvdc_loss_to_openapi(get_converter_loss_from(vsc)),
        max_dc_current_from = get_max_dc_current_from(vsc),
        rating_from = get_rating_from(vsc, u"SU") * power_base,
        reactive_power_limits_from = _minmax_po_scaled(
            get_reactive_power_limits_from(vsc, u"SU"), power_base,
        ),
        power_factor_weighting_fraction_from =
        get_power_factor_weighting_fraction_from(vsc),
        voltage_limits_from = _minmax_po(get_voltage_limits_from(vsc)),
        dc_voltage_droop_from = get_dc_voltage_droop_from(vsc),
        reactive_power_to = get_reactive_power_to(vsc, u"SU") * power_base,
        dc_control_to = PO.VSCDCControlModes(string(get_dc_control_to(vsc))),
        ac_control_to = PO.VSCACControlModes(string(get_ac_control_to(vsc))),
        dc_power_setpoint_to = _optional_scaled_to_wire(
            get_dc_power_setpoint_to(vsc, u"SU"), power_base,
        ),
        dc_voltage_setpoint_to = _vsc_setpoint_to_wire(
            vsc, get_dc_voltage_setpoint_to(vsc), rated_dc_voltage,
            "dc_voltage_setpoint_to", "rated_dc_voltage",
        ),
        power_factor_setpoint_to = _optional_to_wire(get_power_factor_setpoint_to(vsc)),
        ac_voltage_setpoint_to = _vsc_setpoint_to_wire(
            vsc, get_ac_voltage_setpoint_to(vsc), rated_ac_voltage_to,
            "ac_voltage_setpoint_to", "rated_ac_voltage_to",
        ),
        rated_ac_voltage_to = rated_ac_voltage_to,
        converter_loss_to = _hvdc_loss_to_openapi(get_converter_loss_to(vsc)),
        max_dc_current_to = get_max_dc_current_to(vsc),
        rating_to = get_rating_to(vsc, u"SU") * power_base,
        reactive_power_limits_to = _minmax_po_scaled(
            get_reactive_power_limits_to(vsc, u"SU"), power_base,
        ),
        power_factor_weighting_fraction_to = get_power_factor_weighting_fraction_to(vsc),
        voltage_limits_to = _minmax_po(get_voltage_limits_to(vsc)),
        dc_voltage_droop_to = get_dc_voltage_droop_to(vsc),
        rated_dc_voltage = rated_dc_voltage,
        remote_bus_control_from = get_remote_bus_control_from(vsc),
        remote_bus_control_to = get_remote_bus_control_to(vsc),
        base_power = base_power,
        operational_flow_limit = _operational_flow_limit_po_scaled_optional(
            get_operational_flow_limit(vsc, u"SU"), power_base,
        ),
        power_units = _power_units_string(unit),
    )
end

# ── HydroReservoir ──────────────────────────────────────────────────────────────
# No unit-converted fields; both unit-system methods identical (mirrors import).
# `initial_level`/`level_targets` are the one real conversion, inverting `_level_fraction`:
# fraction-of-`storage_level_limits.max` in PSY -> absolute in the document.
# `upstream_turbines`/`downstream_turbines`/`upstream_reservoirs`: PSY always holds a (possibly
# empty) vector; an empty vector reverses to `nothing` (the same absence `_hydro_units`/
# `_reservoir_devices` map `nothing` *to* on import — the natural inverse of that default).

function _level_absolute(::Nothing, ::Real)
    return IC.ABSENT
end

function _level_absolute(fraction, max_level::Real)
    return fraction * max_level
end

function _hydro_unit_ids(refs::OpenAPIRefs, units::AbstractVector)
    if isempty(units)
        return IC.ABSENT
    end
    return Int[component_id(refs, u) for u in units]
end

function to_openapi(res::HydroReservoir, refs::OpenAPIRefs, ::ComponentBaseUnit)
    limits = get_storage_level_limits(res)
    return PO.HydroReservoir(;
        id = component_id(refs, res),
        name = get_name(res),
        available = get_available(res),
        storage_level_limits = _minmax_po(limits),
        initial_level = _level_absolute(get_initial_level(res), limits.max),
        spillage_limits = _minmax_po_optional(get_spillage_limits(res)),
        inflow = get_inflow(res),
        outflow = get_outflow(res),
        level_targets = _level_absolute(get_level_targets(res), limits.max),
        intake_elevation = get_intake_elevation(res),
        head_to_volume_factor = IC.FunctionData(
            convert_cost_to_openapi(get_head_to_volume_factor(res)),
        ),
        upstream_turbines = _hydro_unit_ids(refs, get_upstream_turbines(res)),
        downstream_turbines = _hydro_unit_ids(refs, get_downstream_turbines(res)),
        upstream_reservoirs = _hydro_unit_ids(refs, get_upstream_reservoirs(res)),
        operation_cost = PO.HydroReservoirOperationCost(
            convert_cost_to_openapi(get_operation_cost(res)),
        ),
        evaporative_loss = get_evaporative_loss(res),
        level_data_type = PO.HydroReservoirLevelDataType(string(get_level_data_type(res))),
    )
end

function to_openapi(res::HydroReservoir, refs::OpenAPIRefs, ::NaturalUnit)
    return to_openapi(res, refs, CU)
end

# ── EnergyReservoirStorage ──────────────────────────────────────────────────────
# `storage_capacity` scales like any other component-base field even though it is an energy
# quantity (MWh), matching import's own rule for uniform division. `storage_level_limits`,
# `initial_storage_capacity_level`, `efficiency`, `conversion_factor`, `storage_target`,
# `self_discharge` are dimensionless and pass through in both methods. `energy_units` is always
# emitted as "MWH" (the only basis implemented on either side, per import's
# `_check_energy_units`).

function to_openapi(storage::EnergyReservoirStorage, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.EnergyReservoirStorage(;
        id = component_id(refs, storage),
        name = get_name(storage),
        available = get_available(storage),
        bus = component_id(refs, get_bus(storage)),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(storage))),
        storage_technology_type = PO.StorageTech(
            string(get_storage_technology_type(
                storage,
            )),
        ),
        storage_capacity = get_storage_capacity(storage, u"CU"),
        energy_units = PO.EnergyUnitBasis("MWH"),
        storage_level_limits = _minmax_po(get_storage_level_limits(storage)),
        initial_storage_capacity_level = get_initial_storage_capacity_level(storage),
        rating = get_rating(storage, u"CU"),
        active_power = get_active_power(storage, u"CU"),
        input_active_power_limits = _minmax_po(
            get_input_active_power_limits(storage, u"CU"),
        ),
        output_active_power_limits = _minmax_po(
            get_output_active_power_limits(storage, u"CU"),
        ),
        efficiency = _inout_po(get_efficiency(storage)),
        reactive_power = get_reactive_power(storage, u"CU"),
        reactive_power_limits = _minmax_po_optional(
            get_reactive_power_limits(storage, u"CU"),
        ),
        base_power = _get_base_power(storage),
        operation_cost = PO.EnergyReservoirStorageOperationCost(
            convert_cost_to_openapi(get_operation_cost(storage)),
        ),
        conversion_factor = get_conversion_factor(storage),
        storage_target = get_storage_target(storage),
        cycle_limits = get_cycle_limits(storage),
        ramp_limits = _updown_po_optional(get_ramp_limits(storage, u"CU/minute")),
        self_discharge = get_self_discharge(storage),
        standing_loss = get_standing_loss(storage, u"CU"),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(
    storage::EnergyReservoirStorage,
    refs::OpenAPIRefs,
    ::NaturalUnit,
)
    base = _get_base_power(storage)
    return PO.EnergyReservoirStorage(;
        id = component_id(refs, storage),
        name = get_name(storage),
        available = get_available(storage),
        bus = component_id(refs, get_bus(storage)),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(storage))),
        storage_technology_type = PO.StorageTech(
            string(get_storage_technology_type(
                storage,
            )),
        ),
        storage_capacity = get_storage_capacity(storage, u"CU") * base,
        energy_units = PO.EnergyUnitBasis("MWH"),
        storage_level_limits = _minmax_po(get_storage_level_limits(storage)),
        initial_storage_capacity_level = get_initial_storage_capacity_level(storage),
        rating = get_rating(storage, u"CU") * base,
        active_power = get_active_power(storage, u"CU") * base,
        input_active_power_limits =
        _minmax_po_scaled(get_input_active_power_limits(storage, u"CU"), base),
        output_active_power_limits =
        _minmax_po_scaled(get_output_active_power_limits(storage, u"CU"), base),
        efficiency = _inout_po(get_efficiency(storage)),
        reactive_power = get_reactive_power(storage, u"CU") * base,
        reactive_power_limits =
        _minmax_po_scaled_optional(get_reactive_power_limits(storage, u"CU"), base),
        base_power = base,
        operation_cost = PO.EnergyReservoirStorageOperationCost(
            convert_cost_to_openapi(get_operation_cost(storage)),
        ),
        conversion_factor = get_conversion_factor(storage),
        storage_target = get_storage_target(storage),
        cycle_limits = get_cycle_limits(storage),
        ramp_limits = _updown_po_scaled_optional(
            get_ramp_limits(storage, u"CU/minute"),
            base,
        ),
        self_discharge = get_self_discharge(storage),
        standing_loss = get_standing_loss(storage, u"CU") * base,
        power_units = _power_units_string(NU),
    )
end

# ── Reserves: OnlineReserve, OfflineReserve, GroupReserve ───────────────────────
# `reserve_direction` resolves from the `T` type parameter through a literal table (the
# reverse of `RESERVE_DIRECTION`; direction is not a codegen case). `requirement`'s schema
# declares x-unit "MW" outright (see import_handwritten.jl's header on this exact point), so it
# multiplies by `get_base_power(refs)` in both methods — a reserve has no base of its own.
# `variable` (the Operating Reserve Demand Curve) goes through
# `convert_reserve_variable_to_openapi` (already handles the `ZERO_OFFER_CURVE` → `nothing`
# default).

const RESERVE_DIRECTION_TO_STRING = _invert(RESERVE_DIRECTION)

function to_openapi(
    reserve::OnlineReserve{T, U},
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
) where {T <: ReserveDirection, U}
    return PO.OnlineReserve(;
        id = component_id(refs, reserve),
        name = get_name(reserve),
        available = get_available(reserve),
        time_frame = get_time_frame(reserve),
        requirement = get_requirement(reserve, u"SU") * get_base_power(refs),
        variable = convert_reserve_variable_to_openapi(reserve),
        sustained_time = get_sustained_time(reserve),
        max_output_fraction = get_max_output_fraction(reserve),
        max_participation_factor = get_max_participation_factor(reserve),
        deployed_fraction = get_deployed_fraction(reserve),
        reserve_direction = PO.ReserveDirection(RESERVE_DIRECTION_TO_STRING[T]),
    )
end

function to_openapi(
    reserve::OnlineReserve{T, U},
    refs::OpenAPIRefs,
    ::NaturalUnit,
) where {T <: ReserveDirection, U}
    return to_openapi(reserve, refs, CU)
end

function to_openapi(
    reserve::OfflineReserve{U},
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
) where {U}
    return PO.OfflineReserve(;
        id = component_id(refs, reserve),
        name = get_name(reserve),
        available = get_available(reserve),
        time_frame = get_time_frame(reserve),
        requirement = get_requirement(reserve, u"SU") * get_base_power(refs),
        variable = convert_reserve_variable_to_openapi(reserve),
        sustained_time = get_sustained_time(reserve),
        max_output_fraction = get_max_output_fraction(reserve),
        max_participation_factor = get_max_participation_factor(reserve),
        deployed_fraction = get_deployed_fraction(reserve),
    )
end

function to_openapi(
    reserve::OfflineReserve{U},
    refs::OpenAPIRefs,
    ::NaturalUnit,
) where {U}
    return to_openapi(reserve, refs, CU)
end

function to_openapi(
    reserve::GroupReserve{T},
    refs::OpenAPIRefs,
    ::ComponentBaseUnit,
) where {T <: ReserveDirection}
    return PO.GroupReserve(;
        id = component_id(refs, reserve),
        name = get_name(reserve),
        available = get_available(reserve),
        requirement = get_requirement(reserve, u"SU") * get_base_power(refs),
        variable = convert_reserve_variable_to_openapi(reserve),
        reserve_direction = PO.ReserveDirection(RESERVE_DIRECTION_TO_STRING[T]),
    )
end

function to_openapi(
    reserve::GroupReserve{T},
    refs::OpenAPIRefs,
    ::NaturalUnit,
) where {T <: ReserveDirection}
    return to_openapi(reserve, refs, CU)
end
