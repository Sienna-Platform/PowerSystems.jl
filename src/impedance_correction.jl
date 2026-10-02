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
    attr = ImpedanceCorrectionData(
        table_number,
        tap_ratio_correction_curve,
        phase_angle_correction_curve,
        transformer_winding,
        transformer_control_mode,
        internal,
    )
    # Supplemental attributes have no attach-time validator, so the pairing rule runs here.
    errors, warnings = _mode_field_problems(
        "ImpedanceCorrectionData table $table_number", attr, :transformer_control_mode,
        IMPEDANCE_CORRECTION_CURVE_FIELDS,
    )
    for msg in warnings
        @warn msg maxlog = PS_MAX_LOG
    end
    isempty(errors) || throw(ArgumentError(join(errors, " ")))
    return attr
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
