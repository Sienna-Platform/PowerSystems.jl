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
        peak_active_power = get_peak_active_power(area, SU),
        peak_reactive_power = get_peak_reactive_power(area, SU),
        load_response = get_load_response(area),
        base_power = get_base_power(refs),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(area::Area, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.Area(;
        id = component_id(refs, area),
        name = get_name(area),
        peak_active_power = get_peak_active_power(area, SU) * get_base_power(refs),
        peak_reactive_power = get_peak_reactive_power(area, SU) * get_base_power(refs),
        load_response = get_load_response(area),
        base_power = get_base_power(refs),
        power_units = _power_units_string(NU),
    )
end

function to_openapi(lz::LoadZone, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.LoadZone(;
        id = component_id(refs, lz),
        name = get_name(lz),
        peak_active_power = get_peak_active_power(lz, SU),
        peak_reactive_power = get_peak_reactive_power(lz, SU),
        base_power = get_base_power(refs),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(lz::LoadZone, refs::OpenAPIRefs, ::NaturalUnit)
    return PO.LoadZone(;
        id = component_id(refs, lz),
        name = get_name(lz),
        peak_active_power = get_peak_active_power(lz, SU) * get_base_power(refs),
        peak_reactive_power = get_peak_reactive_power(lz, SU) * get_base_power(refs),
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
        active_power_flow_limits = _minmax_po(get_active_power_flow_limits(tx, SU)),
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
            get_active_power_flow_limits(tx, SU),
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
        active_power_flow = get_active_power_flow(line, SU),
        reactive_power_flow = get_reactive_power_flow(line, SU),
        arc = component_id(refs, get_arc(line)),
        r = get_r(line, SU),
        x = get_x(line, SU),
        base_power = get_base_power(refs),
        b = _fromto_po(get_b(line, SU)),
        rating = get_rating(line, SU),
        rating_b = _optional_to_wire(get_rating_b(line, SU)),
        rating_c = _optional_to_wire(get_rating_c(line, SU)),
        angle_limits = _minmax_po(get_angle_limits(line)),
        g = _fromto_po(get_g(line, SU)),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(line::Line, refs::OpenAPIRefs, ::NaturalUnit)
    sbp = get_base_power(refs)
    return PO.Line(;
        id = component_id(refs, line),
        name = get_name(line),
        available = get_available(line),
        active_power_flow = get_active_power_flow(line, SU) * sbp,
        reactive_power_flow = get_reactive_power_flow(line, SU) * sbp,
        arc = component_id(refs, get_arc(line)),
        r = get_r(line, SU),
        x = get_x(line, SU),
        base_power = sbp,
        b = _fromto_po(get_b(line, SU)),
        rating = get_rating(line, SU) * sbp,
        rating_b = _scale_optional_po(get_rating_b(line, SU), sbp),
        rating_c = _scale_optional_po(get_rating_c(line, SU), sbp),
        angle_limits = _minmax_po(get_angle_limits(line)),
        g = _fromto_po(get_g(line, SU)),
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
        active_power = get_active_power(hyb, CU),
        reactive_power = get_reactive_power(hyb, CU),
        base_power = _get_base_power(hyb),
        operation_cost = convert_cost_to_openapi(get_operation_cost(hyb)),
        thermal_unit = _component_id_optional(refs, get_thermal_unit(hyb)),
        electric_load = _component_id_optional(refs, get_electric_load(hyb)),
        storage = _component_id_optional(refs, get_storage(hyb)),
        renewable_unit = _component_id_optional(refs, get_renewable_unit(hyb)),
        interconnection_impedance = _complex_number_po(
            get_interconnection_impedance(hyb),
        ),
        interconnection_rating = get_interconnection_rating(hyb, CU),
        input_active_power_limits = _minmax_po_optional(
            get_input_active_power_limits(hyb, CU),
        ),
        output_active_power_limits = _minmax_po_optional(
            get_output_active_power_limits(hyb, CU),
        ),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(hyb, CU)),
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
        active_power = get_active_power(hyb, CU) * dbp,
        reactive_power = get_reactive_power(hyb, CU) * dbp,
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
            get_interconnection_rating(hyb, CU), dbp,
        ),
        input_active_power_limits = _minmax_po_scaled_optional(
            get_input_active_power_limits(hyb, CU), dbp,
        ),
        output_active_power_limits = _minmax_po_scaled_optional(
            get_output_active_power_limits(hyb, CU), dbp,
        ),
        reactive_power_limits = _minmax_po_scaled_optional(
            get_reactive_power_limits(hyb, CU), dbp,
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
        remote_regulated_bus_id = _component_id_optional(
            refs,
            get_remote_regulated_bus(src),
        ),
        voltage_setpoint_units = PO.VoltageUnitBasis("COMPONENT_BASE"),
        voltage_setpoint = get_voltage_setpoint(src),
        active_power = get_active_power(src, CU),
        reactive_power = get_reactive_power(src, CU),
        active_power_limits = _minmax_po(get_active_power_limits(src, CU)),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(src, CU)),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r_th = get_R_th(src),
        x_th = get_X_th(src),
        internal_voltage = get_internal_voltage(src),
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
        remote_regulated_bus_id = _component_id_optional(
            refs,
            get_remote_regulated_bus(src),
        ),
        voltage_setpoint_units = PO.VoltageUnitBasis("COMPONENT_BASE"),
        voltage_setpoint = get_voltage_setpoint(src),
        active_power = get_active_power(src, CU) * dbp,
        reactive_power = get_reactive_power(src, CU) * dbp,
        active_power_limits = _minmax_po_scaled(get_active_power_limits(src, CU), dbp),
        reactive_power_limits = _minmax_po_scaled_optional(
            get_reactive_power_limits(src, CU), dbp,
        ),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r_th = get_R_th(src),
        x_th = get_X_th(src),
        internal_voltage = get_internal_voltage(src),
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
# `active_power_flow`/`active_power_limits_from`/`active_power_limits_to` declare x-unit "MW"
# outright — fixed natural units, no `power_units` discriminator on this PO struct (see the
# schema and import_handwritten.jl's header on this exact point) — so they multiply by
# `get_base_power(refs)` in both methods, same posture as reserves' `requirement`. Both
# methods are therefore identical, hence the trivial `CU` delegate below. `base_current` is
# written back untouched, being the anchor for `r`/`l`/`c` rather than for power.

function to_openapi(line::TModelHVDCLine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    sbp = get_base_power(refs)
    return PO.TModelHVDCLine(;
        id = component_id(refs, line),
        name = get_name(line),
        available = get_available(line),
        active_power_flow = get_active_power_flow(line, SU) * sbp,
        arc = component_id(refs, get_arc(line)),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        base_current = get_base_current(line),
        r = get_r(line),
        l = get_l(line),
        c = get_c(line),
        active_power_limits_from = _minmax_po_scaled(
            get_active_power_limits_from(line, SU), sbp,
        ),
        active_power_limits_to = _minmax_po_scaled(
            get_active_power_limits_to(line, SU), sbp,
        ),
    )
end

function to_openapi(line::TModelHVDCLine, refs::OpenAPIRefs, ::NaturalUnit)
    return to_openapi(line, refs, CU)
end

# ── InterconnectingConverter ────────────────────────────────────────────────────
# Component base throughout, `dc_current`/`max_dc_current` included — the descriptor tags those
# `:mva`, so they scale with the rest rather than against a current base.

function to_openapi(conv::InterconnectingConverter, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.InterconnectingConverter(;
        id = component_id(refs, conv),
        name = get_name(conv),
        available = get_available(conv),
        bus = component_id(refs, get_bus(conv)),
        dc_bus = component_id(refs, get_dc_bus(conv)),
        active_power = get_active_power(conv, CU),
        rating = get_rating(conv, CU),
        active_power_limits = _minmax_po(get_active_power_limits(conv, CU)),
        base_power = _get_base_power(conv),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(conv, CU)),
        dc_current = get_dc_current(conv, CU),
        max_dc_current = get_max_dc_current(conv, CU),
        loss_function = _hvdc_loss_to_openapi(get_loss_function(conv)),
        dc_control = PO.VSCDCControlModes(string(get_dc_control(conv))),
        ac_control = PO.VSCACControlModes(string(get_ac_control(conv))),
        voltage_setpoint_units = PO.VoltageUnitBasis("COMPONENT_BASE"),
        dc_setpoint = get_dc_setpoint(conv),
        ac_setpoint = get_ac_setpoint(conv),
        dc_voltage_droop = get_dc_voltage_droop(conv),
        remote_regulated_bus_id = _component_id_optional(
            refs,
            get_remote_regulated_bus(conv),
        ),
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
        active_power = get_active_power(conv, CU) * dbp,
        rating = get_rating(conv, CU) * dbp,
        active_power_limits = _minmax_po_scaled(get_active_power_limits(conv, CU), dbp),
        base_power = dbp,
        reactive_power_limits = _minmax_po_scaled_optional(
            get_reactive_power_limits(conv, CU), dbp,
        ),
        dc_current = get_dc_current(conv, CU) * dbp,
        max_dc_current = get_max_dc_current(conv, CU) * dbp,
        loss_function = _hvdc_loss_to_openapi(get_loss_function(conv)),
        dc_control = PO.VSCDCControlModes(string(get_dc_control(conv))),
        ac_control = PO.VSCACControlModes(string(get_ac_control(conv))),
        voltage_setpoint_units = PO.VoltageUnitBasis("COMPONENT_BASE"),
        dc_setpoint = get_dc_setpoint(conv),
        ac_setpoint = get_ac_setpoint(conv),
        dc_voltage_droop = get_dc_voltage_droop(conv),
        remote_regulated_bus_id = _component_id_optional(
            refs,
            get_remote_regulated_bus(conv),
        ),
        power_factor_weighting_fraction = get_power_factor_weighting_fraction(conv),
        voltage_limits = _minmax_po(get_voltage_limits(conv)),
        power_units = _power_units_string(NU),
    )
end

# ── MonitoredLine ───────────────────────────────────────────────────────────────
# Mirrors `Line` above field for field, plus `flow_limits`, which scales with `rating`.

function to_openapi(line::MonitoredLine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.MonitoredLine(;
        id = component_id(refs, line),
        name = get_name(line),
        available = get_available(line),
        active_power_flow = get_active_power_flow(line, SU),
        reactive_power_flow = get_reactive_power_flow(line, SU),
        arc = component_id(refs, get_arc(line)),
        r = get_r(line, SU),
        x = get_x(line, SU),
        base_power = get_base_power(refs),
        b = _fromto_po(get_b(line, SU)),
        flow_limits = _fromto_tofrom_po(get_flow_limits(line, SU)),
        rating = get_rating(line, SU),
        rating_b = _optional_to_wire(get_rating_b(line, SU)),
        rating_c = _optional_to_wire(get_rating_c(line, SU)),
        angle_limits = _minmax_po(get_angle_limits(line)),
        g = _fromto_po(get_g(line, SU)),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(line::MonitoredLine, refs::OpenAPIRefs, ::NaturalUnit)
    sbp = get_base_power(refs)
    return PO.MonitoredLine(;
        id = component_id(refs, line),
        name = get_name(line),
        available = get_available(line),
        active_power_flow = get_active_power_flow(line, SU) * sbp,
        reactive_power_flow = get_reactive_power_flow(line, SU) * sbp,
        arc = component_id(refs, get_arc(line)),
        r = get_r(line, SU),
        x = get_x(line, SU),
        base_power = sbp,
        b = _fromto_po(get_b(line, SU)),
        flow_limits = _fromto_tofrom_po_scaled(get_flow_limits(line, SU), sbp),
        rating = get_rating(line, SU) * sbp,
        rating_b = _scale_optional_po(get_rating_b(line, SU), sbp),
        rating_c = _scale_optional_po(get_rating_c(line, SU), sbp),
        angle_limits = _minmax_po(get_angle_limits(line)),
        g = _fromto_po(get_g(line, SU)),
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
        active_power_flow = get_active_power_flow(branch, SU),
        reactive_power_flow = get_reactive_power_flow(branch, SU),
        max_flow = get_max_flow(branch, SU),
        arc = component_id(refs, get_arc(branch)),
        base_power = get_base_power(refs),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r = get_r(branch, SU),
        x = get_x(branch, SU),
        power_units = _power_units_string(CU),
    )
end

function to_openapi(branch::GenericArcImpedance, refs::OpenAPIRefs, ::NaturalUnit)
    sbp = get_base_power(refs)
    return PO.GenericArcImpedance(;
        id = component_id(refs, branch),
        name = get_name(branch),
        available = get_available(branch),
        active_power_flow = get_active_power_flow(branch, SU) * sbp,
        reactive_power_flow = get_reactive_power_flow(branch, SU) * sbp,
        max_flow = get_max_flow(branch, SU) * sbp,
        arc = component_id(refs, get_arc(branch)),
        base_power = sbp,
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r = get_r(branch, SU),
        x = get_x(branch, SU),
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
        active_power_flow = get_active_power_flow(branch, SU),
        reactive_power_flow = get_reactive_power_flow(branch, SU),
        arc = component_id(refs, get_arc(branch)),
        base_power = _get_base_power(branch),
        r = get_r(branch, SU),
        x = get_x(branch, SU),
        rating = get_rating(branch, CU),
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
        power_units = _power_units_string(CU),
    )
end

function to_openapi(branch::DiscreteControlledACBranch, refs::OpenAPIRefs, ::NaturalUnit)
    bp = _get_base_power(branch)
    return PO.DiscreteControlledACBranch(;
        id = component_id(refs, branch),
        name = get_name(branch),
        available = get_available(branch),
        active_power_flow = get_active_power_flow(branch, SU) * bp,
        reactive_power_flow = get_reactive_power_flow(branch, SU) * bp,
        arc = component_id(refs, get_arc(branch)),
        base_power = bp,
        r = get_r(branch, SU),
        x = get_x(branch, SU),
        rating = get_rating(branch, CU) * bp,
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

"""A nullable enum on the wire: `nothing` stays `Absent`, else the PO wrapper of its name."""
_optional_enum_po(::Type, ::Nothing) = IC.ABSENT
_optional_enum_po(::Type{T}, value) where {T} = T(string(value))

function to_openapi(circuit::TransformerCircuit, refs::OpenAPIRefs, ::ComponentBaseUnit)
    return PO.TransformerCircuit(;
        id = component_id(refs, circuit),
        available = get_available(circuit),
        arc = component_id(refs, get_arc(circuit)),
        tap = get_tap(circuit),
        alpha = get_α(circuit),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r = get_r(circuit, CU),
        x = get_x(circuit, CU),
        control_objective = PO.TransformerControlObjective(
            string(get_control_objective(
                circuit,
            )),
        ),
        regulated_bus_id = _component_id_optional(refs, get_regulated_bus(circuit)),
        regulated_bus_side = PO.TransformerRegulatedBusSide(
            string(_get_regulated_bus_side(circuit)),
        ),
        load_drop_compensation_r = get_load_drop_compensation_r(circuit, CU),
        load_drop_compensation_x = get_load_drop_compensation_x(circuit, CU),
        control_limits = _minmax_po(get_control_limits(circuit)),
        controlled_quantity_limits = _minmax_po(get_controlled_quantity_limits(circuit)),
        number_of_tap_positions = get_number_of_tap_positions(circuit),
        rating = _optional_to_wire(get_rating(circuit, CU)),
        rating_b = _optional_to_wire(get_rating_b(circuit, CU)),
        rating_c = _optional_to_wire(get_rating_c(circuit, CU)),
        active_power_flow = get_active_power_flow(circuit, CU),
        reactive_power_flow = get_reactive_power_flow(circuit, CU),
        base_power = get_base_power(circuit),
        base_voltage_primary = _optional_to_wire(get_base_voltage_primary(circuit)),
        base_voltage_secondary = _optional_to_wire(get_base_voltage_secondary(circuit)),
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
        r = get_r(circuit, CU),
        x = get_x(circuit, CU),
        control_objective = PO.TransformerControlObjective(
            string(get_control_objective(
                circuit,
            )),
        ),
        regulated_bus_id = _component_id_optional(refs, get_regulated_bus(circuit)),
        regulated_bus_side = PO.TransformerRegulatedBusSide(
            string(_get_regulated_bus_side(circuit)),
        ),
        load_drop_compensation_r = get_load_drop_compensation_r(circuit, CU),
        load_drop_compensation_x = get_load_drop_compensation_x(circuit, CU),
        control_limits = _minmax_po(get_control_limits(circuit)),
        controlled_quantity_limits = _minmax_po(get_controlled_quantity_limits(circuit)),
        number_of_tap_positions = get_number_of_tap_positions(circuit),
        rating = _scale_optional_po(get_rating(circuit, CU), dbp),
        rating_b = _scale_optional_po(get_rating_b(circuit, CU), dbp),
        rating_c = _scale_optional_po(get_rating_c(circuit, CU), dbp),
        active_power_flow = get_active_power_flow(circuit, CU) * dbp,
        reactive_power_flow = get_reactive_power_flow(circuit, CU) * dbp,
        base_power = dbp,
        base_voltage_primary = _optional_to_wire(get_base_voltage_primary(circuit)),
        base_voltage_secondary = _optional_to_wire(get_base_voltage_secondary(circuit)),
        power_units = _power_units_string(NU),
    )
end

# ── TwoWindingTransformer ───────────────────────────────────────────────────────
# `magnetizing_shunt` is pu on the circuit's `base_power` and identity in both document unit
# systems (mirrors import).

function to_openapi(xfmr::TwoWindingTransformer, refs::OpenAPIRefs, ::ComponentBaseUnit)
    circuit = get_circuit(xfmr)
    shunt = get_magnetizing_shunt(xfmr, CU)
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
    shunt = get_magnetizing_shunt(xfmr, CU)
    return PO.ThreeWindingTransformer(;
        id = component_id(refs, xfmr),
        name = get_name(xfmr),
        primary_circuit = component_id(refs, get_primary_circuit(xfmr)),
        secondary_circuit = component_id(refs, get_secondary_circuit(xfmr)),
        tertiary_circuit = component_id(refs, get_tertiary_circuit(xfmr)),
        star_bus = component_id(refs, get_star_bus(xfmr)),
        parameter_units = PO.ImpedanceUnitBasis("COMPONENT_BASE"),
        r_12 = _optional_to_wire(get_r_12(xfmr, CU)),
        x_12 = _optional_to_wire(get_x_12(xfmr, CU)),
        r_23 = _optional_to_wire(get_r_23(xfmr, CU)),
        x_23 = _optional_to_wire(get_x_23(xfmr, CU)),
        r_31 = _optional_to_wire(get_r_31(xfmr, CU)),
        x_31 = _optional_to_wire(get_x_31(xfmr, CU)),
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
        admittance_limits = _minmax_po(get_admittance_limits(shunt)),
        control_mode = PO.SwitchedAdmittanceControlMode(string(get_control_mode(shunt))),
        remote_regulated_bus_id = _component_id_optional(
            refs, get_remote_regulated_bus(shunt),
        ),
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
        max_shunt_current = get_max_shunt_current(device, SU),
        reactive_power_required = get_reactive_power_required(device, SU),
        max_reactive_power = get_max_reactive_power(device, SU),
        shunt_control_type = PO.FACTSControlDeviceShuntControlType(
            string(get_shunt_control_type(
                device,
            )),
        ),
        remote_regulated_bus_id = _component_id_optional(
            refs, get_remote_regulated_bus(device),
        ),
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
        max_shunt_current = get_max_shunt_current(device, SU) * base_power,
        reactive_power_required = get_reactive_power_required(device, SU) * base_power,
        max_reactive_power = get_max_reactive_power(device, SU) * base_power,
        shunt_control_type = PO.FACTSControlDeviceShuntControlType(
            string(get_shunt_control_type(
                device,
            )),
        ),
        remote_regulated_bus_id = _component_id_optional(
            refs, get_remote_regulated_bus(device),
        ),
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
        active_power_flow = get_active_power_flow(hvdc, SU),
        arc = component_id(refs, get_arc(hvdc)),
        active_power_limits_from = _minmax_po(get_active_power_limits_from(hvdc, SU)),
        active_power_limits_to = _minmax_po(get_active_power_limits_to(hvdc, SU)),
        reactive_power_limits_from = _minmax_po(get_reactive_power_limits_from(hvdc, SU)),
        reactive_power_limits_to = _minmax_po(get_reactive_power_limits_to(hvdc, SU)),
        loss = _hvdc_loss_to_openapi(get_loss(hvdc)),
        base_power = get_base_power(refs),
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
        active_power_flow = get_active_power_flow(hvdc, SU) * sbp,
        arc = component_id(refs, get_arc(hvdc)),
        active_power_limits_from = _minmax_po_scaled(
            get_active_power_limits_from(hvdc, SU),
            sbp,
        ),
        active_power_limits_to = _minmax_po_scaled(
            get_active_power_limits_to(hvdc, SU),
            sbp,
        ),
        reactive_power_limits_from =
        _minmax_po_scaled(get_reactive_power_limits_from(hvdc, SU), sbp),
        reactive_power_limits_to = _minmax_po_scaled(
            get_reactive_power_limits_to(hvdc, SU),
            sbp,
        ),
        loss = _hvdc_loss_to_openapi(get_loss(hvdc)),
        base_power = sbp,
        power_units = _power_units_string(NU),
    )
end

# ── TwoTerminalLCCLine ────────────────────────────────────────────────────────────
# Always exports "NATURAL_UNITS" for `parameter_units`/`dc_voltage_units` (the only basis
# implemented), so `r`/`rectifier_rc`/`rectifier_xc`/`rectifier_capacitor_reactance`/
# `inverter_rc`/`inverter_xc`/`inverter_capacitor_reactance`/`compounding_resistance` convert
# pu → ohms in BOTH methods identically — the PROVISIONAL `scheduled_dc_voltage`-based Zbase for
# `r`/`compounding_resistance` (see import_handwritten.jl's header on this exact point) applies
# here too. Only `active_power_flow`/`active_power_limits_*`/`reactive_power_limits_*`/
# `transfer_setpoint` (when `power_mode`) are discriminated by `power_units`, multiplying by
# `base_power` under `NaturalUnit`. Voltage/angle/ratio/tap/bridge fields have no unit-aware
# getter on the PSY side (plain field access) and pass through unconverted.

_lcc_pu_to_ohm(pu, base_voltage, base_power) = pu * (base_voltage^2 / base_power)

_lcc_transfer_setpoint_to_openapi(transfer_setpoint, ::Val{true}, base_power) =
    transfer_setpoint * base_power
_lcc_transfer_setpoint_to_openapi(transfer_setpoint, ::Val{false}, _base_power) =
    transfer_setpoint

function to_openapi(lcc::TwoTerminalLCCLine, refs::OpenAPIRefs, ::ComponentBaseUnit)
    base_power = _get_base_power(lcc)
    rbv = get_rectifier_base_voltage(lcc)
    ibv = get_inverter_base_voltage(lcc)
    dcv = get_scheduled_dc_voltage(lcc)
    return PO.TwoTerminalLCCLine(;
        id = component_id(refs, lcc),
        name = get_name(lcc),
        available = get_available(lcc),
        arc = component_id(refs, get_arc(lcc)),
        active_power_flow = get_active_power_flow(lcc, SU),
        parameter_units = PO.ImpedanceUnitBasis("NATURAL_UNITS"),
        r = _lcc_pu_to_ohm(get_r(lcc), dcv, base_power),
        transfer_setpoint = get_transfer_setpoint(lcc),
        dc_voltage_units = PO.VoltageUnitBasis("NATURAL_UNITS"),
        scheduled_dc_voltage = dcv,
        rectifier_bridges = get_rectifier_bridges(lcc),
        rectifier_delay_angle_limits = _minmax_po(get_rectifier_delay_angle_limits(lcc)),
        rectifier_rc = _lcc_pu_to_ohm(get_rectifier_rc(lcc), rbv, base_power),
        rectifier_xc = _lcc_pu_to_ohm(get_rectifier_xc(lcc), rbv, base_power),
        rectifier_base_voltage = rbv,
        inverter_bridges = get_inverter_bridges(lcc),
        inverter_extinction_angle_limits = _minmax_po(
            get_inverter_extinction_angle_limits(lcc),
        ),
        inverter_rc = _lcc_pu_to_ohm(get_inverter_rc(lcc), ibv, base_power),
        inverter_xc = _lcc_pu_to_ohm(get_inverter_xc(lcc), ibv, base_power),
        inverter_base_voltage = ibv,
        power_mode = get_power_mode(lcc),
        switch_mode_voltage = get_switch_mode_voltage(lcc),
        compounding_resistance = _lcc_pu_to_ohm(
            get_compounding_resistance(lcc),
            dcv,
            base_power,
        ),
        min_compounding_voltage = get_min_compounding_voltage(lcc),
        rectifier_transformer_ratio = get_rectifier_transformer_ratio(lcc),
        rectifier_tap_setting = get_rectifier_tap_setting(lcc),
        rectifier_tap_limits = _minmax_po(get_rectifier_tap_limits(lcc)),
        rectifier_tap_step = get_rectifier_tap_step(lcc),
        rectifier_delay_angle = get_rectifier_delay_angle(lcc),
        rectifier_capacitor_reactance = _lcc_pu_to_ohm(
            get_rectifier_capacitor_reactance(lcc), rbv, base_power,
        ),
        inverter_transformer_ratio = get_inverter_transformer_ratio(lcc),
        inverter_tap_setting = get_inverter_tap_setting(lcc),
        inverter_tap_limits = _minmax_po(get_inverter_tap_limits(lcc)),
        inverter_tap_step = get_inverter_tap_step(lcc),
        inverter_extinction_angle = get_inverter_extinction_angle(lcc),
        inverter_capacitor_reactance = _lcc_pu_to_ohm(
            get_inverter_capacitor_reactance(lcc), ibv, base_power,
        ),
        rectifier_commutating_bus_id = _component_id_optional(
            refs, get_rectifier_commutating_bus(lcc),
        ),
        inverter_commutating_bus_id = _component_id_optional(
            refs, get_inverter_commutating_bus(lcc),
        ),
        rectifier_tap_transformer_id = _component_id_optional(
            refs, get_rectifier_tap_transformer(lcc),
        ),
        inverter_tap_transformer_id = _component_id_optional(
            refs, get_inverter_tap_transformer(lcc),
        ),
        active_power_limits_from = _minmax_po(get_active_power_limits_from(lcc, SU)),
        active_power_limits_to = _minmax_po(get_active_power_limits_to(lcc, SU)),
        reactive_power_limits_from = _minmax_po(get_reactive_power_limits_from(lcc, SU)),
        reactive_power_limits_to = _minmax_po(get_reactive_power_limits_to(lcc, SU)),
        loss = _hvdc_loss_to_openapi(get_loss(lcc)),
        base_power = base_power,
        power_units = _power_units_string(CU),
    )
end

function to_openapi(lcc::TwoTerminalLCCLine, refs::OpenAPIRefs, ::NaturalUnit)
    base_power = _get_base_power(lcc)
    rbv = get_rectifier_base_voltage(lcc)
    ibv = get_inverter_base_voltage(lcc)
    dcv = get_scheduled_dc_voltage(lcc)
    return PO.TwoTerminalLCCLine(;
        id = component_id(refs, lcc),
        name = get_name(lcc),
        available = get_available(lcc),
        arc = component_id(refs, get_arc(lcc)),
        active_power_flow = get_active_power_flow(lcc, SU) * base_power,
        parameter_units = PO.ImpedanceUnitBasis("NATURAL_UNITS"),
        r = _lcc_pu_to_ohm(get_r(lcc), dcv, base_power),
        transfer_setpoint = _lcc_transfer_setpoint_to_openapi(
            get_transfer_setpoint(lcc), Val(get_power_mode(lcc)), base_power,
        ),
        dc_voltage_units = PO.VoltageUnitBasis("NATURAL_UNITS"),
        scheduled_dc_voltage = dcv,
        rectifier_bridges = get_rectifier_bridges(lcc),
        rectifier_delay_angle_limits = _minmax_po(get_rectifier_delay_angle_limits(lcc)),
        rectifier_rc = _lcc_pu_to_ohm(get_rectifier_rc(lcc), rbv, base_power),
        rectifier_xc = _lcc_pu_to_ohm(get_rectifier_xc(lcc), rbv, base_power),
        rectifier_base_voltage = rbv,
        inverter_bridges = get_inverter_bridges(lcc),
        inverter_extinction_angle_limits = _minmax_po(
            get_inverter_extinction_angle_limits(lcc),
        ),
        inverter_rc = _lcc_pu_to_ohm(get_inverter_rc(lcc), ibv, base_power),
        inverter_xc = _lcc_pu_to_ohm(get_inverter_xc(lcc), ibv, base_power),
        inverter_base_voltage = ibv,
        power_mode = get_power_mode(lcc),
        switch_mode_voltage = get_switch_mode_voltage(lcc),
        compounding_resistance = _lcc_pu_to_ohm(
            get_compounding_resistance(lcc),
            dcv,
            base_power,
        ),
        min_compounding_voltage = get_min_compounding_voltage(lcc),
        rectifier_transformer_ratio = get_rectifier_transformer_ratio(lcc),
        rectifier_tap_setting = get_rectifier_tap_setting(lcc),
        rectifier_tap_limits = _minmax_po(get_rectifier_tap_limits(lcc)),
        rectifier_tap_step = get_rectifier_tap_step(lcc),
        rectifier_delay_angle = get_rectifier_delay_angle(lcc),
        rectifier_capacitor_reactance = _lcc_pu_to_ohm(
            get_rectifier_capacitor_reactance(lcc), rbv, base_power,
        ),
        inverter_transformer_ratio = get_inverter_transformer_ratio(lcc),
        inverter_tap_setting = get_inverter_tap_setting(lcc),
        inverter_tap_limits = _minmax_po(get_inverter_tap_limits(lcc)),
        inverter_tap_step = get_inverter_tap_step(lcc),
        inverter_extinction_angle = get_inverter_extinction_angle(lcc),
        inverter_capacitor_reactance = _lcc_pu_to_ohm(
            get_inverter_capacitor_reactance(lcc), ibv, base_power,
        ),
        rectifier_commutating_bus_id = _component_id_optional(
            refs, get_rectifier_commutating_bus(lcc),
        ),
        inverter_commutating_bus_id = _component_id_optional(
            refs, get_inverter_commutating_bus(lcc),
        ),
        rectifier_tap_transformer_id = _component_id_optional(
            refs, get_rectifier_tap_transformer(lcc),
        ),
        inverter_tap_transformer_id = _component_id_optional(
            refs, get_inverter_tap_transformer(lcc),
        ),
        active_power_limits_from = _minmax_po_scaled(
            get_active_power_limits_from(lcc, SU),
            base_power,
        ),
        active_power_limits_to = _minmax_po_scaled(
            get_active_power_limits_to(lcc, SU),
            base_power,
        ),
        reactive_power_limits_from = _minmax_po_scaled(
            get_reactive_power_limits_from(lcc, SU),
            base_power,
        ),
        reactive_power_limits_to = _minmax_po_scaled(
            get_reactive_power_limits_to(lcc, SU),
            base_power,
        ),
        loss = _hvdc_loss_to_openapi(get_loss(lcc)),
        base_power = base_power,
        power_units = _power_units_string(NU),
    )
end

# ── TwoTerminalVSCLine ──────────────────────────────────────────────────────────
# Always exports "NATURAL_UNITS" for `admittance_units`/`voltage_units` (the only basis
# implemented), so `g` converts pu → siemens in BOTH methods. Only the power-family fields and
# `dc_setpoint_*`'s `DC_POWER` branch are discriminated by `power_units`, multiplying by
# `base_power` under `NaturalUnit`.
# `voltage_limits_*`, `dc_voltage_droop_*`, the current fields, the weighting
# fractions, and `rated_dc_voltage`/`rated_ac_voltage_from`/`rated_ac_voltage_to` pass through —
# see import_handwritten.jl's header for why each one is left alone. The voltage-regulating
# `dc_setpoint_*`/`ac_setpoint_*` branches also pass through unconverted (PSY stores them
# per-unit), tagged `setpoint_voltage_units = "COMPONENT_BASE"` — a lossless export that needs no AC
# voltage base; import resolves the `AC_VOLTAGE` kV basis from `rated_ac_voltage_from`/
# `rated_ac_voltage_to` on the row itself.

"""pu → siemens via `Ybase = base_power / rated_dc_voltage^2` (kV, MVA)."""
function _vsc_pu_to_siemens(vsc::TwoTerminalVSCLine, base_power)
    g = get_g(vsc)
    base_voltage = _vsc_export_dc_base_voltage(vsc, g, "g")
    return g / (base_voltage^2 / base_power)
end

"""Mirrors import's `_vsc_dc_base_voltage`, but unlike it, never errors: a `0.0` rating
falls back to `one(rated)` regardless of `value`, so export always succeeds."""
function _vsc_export_dc_base_voltage(vsc::TwoTerminalVSCLine, value, field::AbstractString)
    rated = get_rated_dc_voltage(vsc)
    if !iszero(rated)
        return rated
    end
    # FIXME: rated_dc_voltage == 0.0 here is indistinguishable from "unspecified" because (a)
    # the parsers may not be populating it and (b) it is a plain Float64, not nullable, so
    # there is no explicit-null way to say "no base" in the schema. Until one of those is
    # fixed, fall back to one(rated), same as import's own fallback for iszero(value) — the
    # emitted siemens value is not physically meaningful while the base is unset, and a
    # non-zero value only round-trips as far as export; import's unchanged error branch
    # still rejects re-importing it.
    return one(rated)
end

_vsc_dc_setpoint_to_openapi(
    _vsc, setpoint, ::Val{VSCDCControlModes.DC_POWER}, base_power, ::NaturalUnit,
) = setpoint * base_power
_vsc_dc_setpoint_to_openapi(
    _vsc, setpoint, ::Val{VSCDCControlModes.DC_POWER}, _base_power, ::ComponentBaseUnit,
) = setpoint
_vsc_dc_setpoint_to_openapi(
    _vsc, setpoint, ::Val{VSCDCControlModes.DC_VOLTAGE}, _bp, _unit,
) = setpoint
_vsc_dc_setpoint_to_openapi(
    _vsc, setpoint, ::Val{VSCDCControlModes.DC_VOLTAGE_DROOP}, _bp, _unit,
) = setpoint

_vsc_ac_setpoint_to_openapi(_vsc, setpoint, ::Val{VSCACControlModes.AC_REACTIVE_POWER}) =
    setpoint
_vsc_ac_setpoint_to_openapi(_vsc, setpoint, ::Val{VSCACControlModes.AC_VOLTAGE}) = setpoint

"""The shared body of both unit-system methods; only `unit` decides the power scaling."""
function _two_terminal_vsc_line_to_openapi(vsc::TwoTerminalVSCLine, refs::OpenAPIRefs, unit)
    base_power = _get_base_power(vsc)
    dc_control_from = get_dc_control_from(vsc)
    dc_control_to = get_dc_control_to(vsc)
    ac_control_from = get_ac_control_from(vsc)
    ac_control_to = get_ac_control_to(vsc)
    return PO.TwoTerminalVSCLine(;
        id = component_id(refs, vsc),
        name = get_name(vsc),
        available = get_available(vsc),
        arc = component_id(refs, get_arc(vsc)),
        active_power_flow = _vsc_power_to_openapi(
            get_active_power_flow(vsc, SU), base_power, unit,
        ),
        rating = _vsc_power_to_openapi(get_rating(vsc, SU), base_power, unit),
        active_power_limits_from = _vsc_minmax_to_openapi(
            get_active_power_limits_from(vsc, SU), base_power, unit,
        ),
        active_power_limits_to = _vsc_minmax_to_openapi(
            get_active_power_limits_to(vsc, SU), base_power, unit,
        ),
        admittance_units = PO.AdmittanceUnitBasis("NATURAL_UNITS"),
        g = _vsc_pu_to_siemens(vsc, base_power),
        dc_current = get_dc_current(vsc),
        reactive_power_from = _vsc_power_to_openapi(
            get_reactive_power_from(vsc, SU), base_power, unit,
        ),
        dc_control_from = PO.VSCDCControlModes(string(dc_control_from)),
        ac_control_from = PO.VSCACControlModes(string(ac_control_from)),
        dc_setpoint_from = _vsc_dc_setpoint_to_openapi(
            vsc, get_dc_setpoint_from(vsc), Val(dc_control_from), base_power, unit,
        ),
        ac_setpoint_from = _vsc_ac_setpoint_to_openapi(
            vsc, get_ac_setpoint_from(vsc), Val(ac_control_from),
        ),
        rated_ac_voltage_from = get_rated_ac_voltage_from(vsc),
        converter_loss_from = _hvdc_loss_to_openapi(get_converter_loss_from(vsc)),
        max_dc_current_from = get_max_dc_current_from(vsc),
        rating_from = _vsc_power_to_openapi(get_rating_from(vsc, SU), base_power, unit),
        reactive_power_limits_from = _vsc_minmax_to_openapi(
            get_reactive_power_limits_from(vsc, SU), base_power, unit,
        ),
        power_factor_weighting_fraction_from =
        get_power_factor_weighting_fraction_from(vsc),
        voltage_units = PO.VoltageUnitBasis("NATURAL_UNITS"),
        setpoint_voltage_units = PO.VoltageUnitBasis("COMPONENT_BASE"),
        voltage_limits_from = _minmax_po(get_voltage_limits_from(vsc)),
        dc_voltage_droop_from = get_dc_voltage_droop_from(vsc),
        reactive_power_to = _vsc_power_to_openapi(
            get_reactive_power_to(vsc, SU), base_power, unit,
        ),
        dc_control_to = PO.VSCDCControlModes(string(dc_control_to)),
        ac_control_to = PO.VSCACControlModes(string(ac_control_to)),
        dc_setpoint_to = _vsc_dc_setpoint_to_openapi(
            vsc, get_dc_setpoint_to(vsc), Val(dc_control_to), base_power, unit,
        ),
        ac_setpoint_to = _vsc_ac_setpoint_to_openapi(
            vsc, get_ac_setpoint_to(vsc), Val(ac_control_to),
        ),
        rated_ac_voltage_to = get_rated_ac_voltage_to(vsc),
        converter_loss_to = _hvdc_loss_to_openapi(get_converter_loss_to(vsc)),
        max_dc_current_to = get_max_dc_current_to(vsc),
        rating_to = _vsc_power_to_openapi(get_rating_to(vsc, SU), base_power, unit),
        reactive_power_limits_to = _vsc_minmax_to_openapi(
            get_reactive_power_limits_to(vsc, SU), base_power, unit,
        ),
        power_factor_weighting_fraction_to = get_power_factor_weighting_fraction_to(vsc),
        voltage_limits_to = _minmax_po(get_voltage_limits_to(vsc)),
        dc_voltage_droop_to = get_dc_voltage_droop_to(vsc),
        rated_dc_voltage = get_rated_dc_voltage(vsc),
        remote_regulated_bus_id_from = _component_id_optional(
            refs, get_remote_regulated_bus_from(vsc),
        ),
        remote_regulated_bus_id_to = _component_id_optional(
            refs, get_remote_regulated_bus_to(vsc),
        ),
        base_power = base_power,
        power_units = _power_units_string(unit),
    )
end

_vsc_power_to_openapi(value, base_power, ::NaturalUnit) = value * base_power
_vsc_power_to_openapi(value, _base_power, ::ComponentBaseUnit) = value

_vsc_minmax_to_openapi(m, base_power, ::NaturalUnit) = _minmax_po_scaled(m, base_power)
_vsc_minmax_to_openapi(m, _base_power, ::ComponentBaseUnit) = _minmax_po(m)

to_openapi(vsc::TwoTerminalVSCLine, refs::OpenAPIRefs, unit::ComponentBaseUnit) =
    _two_terminal_vsc_line_to_openapi(vsc, refs, unit)

to_openapi(vsc::TwoTerminalVSCLine, refs::OpenAPIRefs, unit::NaturalUnit) =
    _two_terminal_vsc_line_to_openapi(vsc, refs, unit)

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
        remote_regulated_bus_id = _component_id_optional(
            refs, get_remote_regulated_bus(storage),
        ),
        voltage_setpoint_units = PO.VoltageUnitBasis("COMPONENT_BASE"),
        voltage_setpoint = get_voltage_setpoint(storage),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(storage))),
        storage_technology_type = PO.StorageTech(
            string(get_storage_technology_type(
                storage,
            )),
        ),
        storage_capacity = get_storage_capacity(storage, CU),
        energy_units = PO.EnergyUnitBasis("MWH"),
        storage_level_limits = _minmax_po(get_storage_level_limits(storage)),
        initial_storage_capacity_level = get_initial_storage_capacity_level(storage),
        rating = get_rating(storage, CU),
        active_power = get_active_power(storage, CU),
        input_active_power_limits = _minmax_po(get_input_active_power_limits(storage, CU)),
        output_active_power_limits = _minmax_po(
            get_output_active_power_limits(storage, CU),
        ),
        efficiency = _inout_po(get_efficiency(storage)),
        reactive_power = get_reactive_power(storage, CU),
        reactive_power_limits = _minmax_po_optional(get_reactive_power_limits(storage, CU)),
        base_power = _get_base_power(storage),
        operation_cost = PO.EnergyReservoirStorageOperationCost(
            convert_cost_to_openapi(get_operation_cost(storage)),
        ),
        conversion_factor = get_conversion_factor(storage),
        storage_target = get_storage_target(storage),
        cycle_limits = get_cycle_limits(storage),
        ramp_limits = _updown_po_optional(get_ramp_limits(storage, CU / u"minute")),
        self_discharge = get_self_discharge(storage),
        standing_loss = get_standing_loss(storage, CU),
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
        remote_regulated_bus_id = _component_id_optional(
            refs, get_remote_regulated_bus(storage),
        ),
        voltage_setpoint_units = PO.VoltageUnitBasis("COMPONENT_BASE"),
        voltage_setpoint = get_voltage_setpoint(storage),
        prime_mover_type = PO.PrimeMovers(string(get_prime_mover_type(storage))),
        storage_technology_type = PO.StorageTech(
            string(get_storage_technology_type(
                storage,
            )),
        ),
        storage_capacity = get_storage_capacity(storage, CU) * base,
        energy_units = PO.EnergyUnitBasis("MWH"),
        storage_level_limits = _minmax_po(get_storage_level_limits(storage)),
        initial_storage_capacity_level = get_initial_storage_capacity_level(storage),
        rating = get_rating(storage, CU) * base,
        active_power = get_active_power(storage, CU) * base,
        input_active_power_limits =
        _minmax_po_scaled(get_input_active_power_limits(storage, CU), base),
        output_active_power_limits =
        _minmax_po_scaled(get_output_active_power_limits(storage, CU), base),
        efficiency = _inout_po(get_efficiency(storage)),
        reactive_power = get_reactive_power(storage, CU) * base,
        reactive_power_limits =
        _minmax_po_scaled_optional(get_reactive_power_limits(storage, CU), base),
        base_power = base,
        operation_cost = PO.EnergyReservoirStorageOperationCost(
            convert_cost_to_openapi(get_operation_cost(storage)),
        ),
        conversion_factor = get_conversion_factor(storage),
        storage_target = get_storage_target(storage),
        cycle_limits = get_cycle_limits(storage),
        ramp_limits = _updown_po_scaled_optional(
            get_ramp_limits(storage, CU / u"minute"),
            base,
        ),
        self_discharge = get_self_discharge(storage),
        standing_loss = get_standing_loss(storage, CU) * base,
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
        requirement = get_requirement(reserve, SU) * get_base_power(refs),
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
        requirement = get_requirement(reserve, SU) * get_base_power(refs),
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
        requirement = get_requirement(reserve, SU) * get_base_power(refs),
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
