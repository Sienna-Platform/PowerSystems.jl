"""
Attribute that contains information regarding the Impedance Correction Table (ICT) rows defined in the Table.

Exactly one correction curve is populated, selected by `transformer_control_mode`:
`tap_ratio_correction_curve` spans off-nominal turns ratio and `phase_angle_correction_curve`
spans phase-shift angle (rad). The other curve is `nothing`.

# Arguments
- `table_number::Int64`: Row number of the ICT to be linked with a specific Transformer component.
- `tap_ratio_correction_curve::Union{Nothing, PiecewiseLinearData}`: Impedance correction factor over tap ratio (x axis dimensionless, y axis a multiplier on the winding impedance). Populated when `transformer_control_mode` is `TAP_RATIO`.
- `phase_angle_correction_curve::Union{Nothing, PiecewiseLinearData}`: Impedance correction factor over phase-shift angle (x axis in rad, y axis a multiplier on the winding impedance). Populated when `transformer_control_mode` is `PHASE_SHIFT_ANGLE`.
- `transformer_winding::`[`WindingCategory`](@ref): Indicates the winding to which the ICT is linked to for a Transformer component.
- `transformer_control_mode::`[`ImpedanceCorrectionTransformerControlMode`](@ref): Defines the control modes of the Transformer, whether is for off-nominal turns ratio or phase angle shifts.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems internal reference
"""
struct ImpedanceCorrectionData <: SupplementalAttribute
    table_number::Int64
    tap_ratio_correction_curve::Union{Nothing, PiecewiseLinearData}
    phase_angle_correction_curve::Union{Nothing, PiecewiseLinearData}
    transformer_winding::WindingCategory.Value
    transformer_control_mode::ImpedanceCorrectionTransformerControlMode.Value
    internal::InfrastructureSystemsInternal
end

"""
    ImpedanceCorrectionData(; table_number, tap_ratio_correction_curve, phase_angle_correction_curve, transformer_winding, transformer_control_mode, internal)

Construct an [`ImpedanceCorrectionData`](@ref). The curve `transformer_control_mode` selects
must be given; a populated curve the mode does not select is kept with a warning.

# Arguments
- `table_number::Int64`: Row number of the ICT to be linked with a specific Transformer component.
- `tap_ratio_correction_curve::Union{Nothing, PiecewiseLinearData}`: (default: `nothing`) Impedance correction factor over tap ratio. Required when `transformer_control_mode` is `TAP_RATIO`.
- `phase_angle_correction_curve::Union{Nothing, PiecewiseLinearData}`: (default: `nothing`) Impedance correction factor over phase-shift angle (rad). Required when `transformer_control_mode` is `PHASE_SHIFT_ANGLE`.
- `transformer_winding::`[`WindingCategory`](@ref): Indicates the winding to which the ICT is linked to for a Transformer component.
- `transformer_control_mode::`[`ImpedanceCorrectionTransformerControlMode`](@ref): Defines the control modes of the Transformer, whether is for off-nominal turns ratio or phase angle shifts.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystems internal reference
"""
function ImpedanceCorrectionData(;
    table_number,
    tap_ratio_correction_curve = nothing,
    phase_angle_correction_curve = nothing,
    transformer_winding,
    transformer_control_mode,
    internal = InfrastructureSystemsInternal(),
)
    check_correction_curves(
        table_number,
        transformer_control_mode,
        tap_ratio_correction_curve,
        phase_angle_correction_curve,
    )
    return ImpedanceCorrectionData(
        table_number,
        tap_ratio_correction_curve,
        phase_angle_correction_curve,
        transformer_winding,
        transformer_control_mode,
        internal,
    )
end

"""The curve field `mode` selects. Exhaustive over the enum: an unhandled member errors."""
function correction_curve_field(mode::ImpedanceCorrectionTransformerControlMode.Value)
    if mode == ImpedanceCorrectionTransformerControlMode.TAP_RATIO
        return :tap_ratio_correction_curve
    elseif mode == ImpedanceCorrectionTransformerControlMode.PHASE_SHIFT_ANGLE
        return :phase_angle_correction_curve
    end
    error("unhandled ImpedanceCorrectionTransformerControlMode $mode")
end

# Supplemental attributes have no attach-time validator hook, so the pairing rule runs in the
# keyword constructor: the selected curve is required, the other one warns when populated.
function check_correction_curves(table_number, mode, tap_curve, angle_curve)
    selected = correction_curve_field(mode)
    curves =
        (tap_ratio_correction_curve = tap_curve, phase_angle_correction_curve = angle_curve)
    for (name, curve) in pairs(curves)
        if name == selected
            isnothing(curve) && throw(
                ArgumentError(
                    "ImpedanceCorrectionData table $table_number: transformer_control_mode = $mode " *
                    "requires $name, which is nothing",
                ),
            )
        elseif !isnothing(curve)
            @warn "ImpedanceCorrectionData table $table_number: $name is populated but " *
                  "transformer_control_mode = $mode does not use it." maxlog = PS_MAX_LOG
        end
    end
    return
end

"""Get [`ImpedanceCorrectionData`](@ref) `table_number`."""
get_table_number(value::ImpedanceCorrectionData) = value.table_number
"""Get [`ImpedanceCorrectionData`](@ref) `tap_ratio_correction_curve`."""
get_tap_ratio_correction_curve(value::ImpedanceCorrectionData) =
    value.tap_ratio_correction_curve
"""Get [`ImpedanceCorrectionData`](@ref) `phase_angle_correction_curve`."""
get_phase_angle_correction_curve(value::ImpedanceCorrectionData) =
    value.phase_angle_correction_curve
"""Get [`ImpedanceCorrectionData`](@ref) `transformer_winding`."""
get_transformer_winding(value::ImpedanceCorrectionData) = value.transformer_winding
"""Get [`ImpedanceCorrectionData`](@ref) `transformer_control_mode`."""
get_transformer_control_mode(value::ImpedanceCorrectionData) =
    value.transformer_control_mode
"""Get [`ImpedanceCorrectionData`](@ref) `internal`."""
get_internal(value::ImpedanceCorrectionData) = value.internal
