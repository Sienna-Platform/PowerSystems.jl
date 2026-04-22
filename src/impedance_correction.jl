"""
    struct ImpedanceCorrectionData <: SupplementalAttribute
        table_number::Int64
        impedance_correction_curve::PiecewiseLinearData
        transformer_winding::WindingCategory
        transformer_control_mode::ImpedanceCorrectionTransformerControlMode
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute representing a single row of a Transformer Impedance Correction
Table (TICT). Adjusts transformer impedance as a piecewise-linear function of tap ratio
or phase shift angle.

# Arguments
- `table_number::Int64`: Row number of the TICT, used to link this correction entry to a
    specific transformer component.
- `impedance_correction_curve::`[`PiecewiseLinearData`](@extref InfrastructureSystems.PiecewiseLinearData):
    Piecewise-linear function defining impedance correction intervals as a function of tap
    ratio or phase shift angle.
- `transformer_winding::`[`WindingCategory`](@ref): Winding of the transformer this
    correction entry is associated with.
- `transformer_control_mode::`[`ImpedanceCorrectionTransformerControlMode`](@ref): Control
    mode determining whether correction is applied based on tap ratio or phase shift angle.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal
    reference.

# See Also
- [`WindingCategory`](@ref): Enumeration of transformer winding roles.
- [`ImpedanceCorrectionTransformerControlMode`](@ref): Enumeration of impedance correction
    control modes.
"""
struct ImpedanceCorrectionData <: SupplementalAttribute
    table_number::Int64
    impedance_correction_curve::PiecewiseLinearData
    transformer_winding::WindingCategory
    transformer_control_mode::ImpedanceCorrectionTransformerControlMode
    internal::InfrastructureSystemsInternal
end

"""
    ImpedanceCorrectionData(; table_number, impedance_correction_curve, transformer_winding, transformer_control_mode, internal)

Construct an [`ImpedanceCorrectionData`](@ref).

# Arguments
- `table_number::Int64`: Row number of the TICT, used to link this correction entry to a
    specific transformer component.
- `impedance_correction_curve::`[`PiecewiseLinearData`](@extref InfrastructureSystems.PiecewiseLinearData):
    Piecewise-linear function defining impedance correction intervals as a function of tap
    ratio or phase shift angle.
- `transformer_winding::`[`WindingCategory`](@ref): Winding of the transformer this
    correction entry is associated with.
- `transformer_control_mode::`[`ImpedanceCorrectionTransformerControlMode`](@ref): Control
    mode determining whether correction is applied based on tap ratio or phase shift angle.
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`)
    (**Do not modify.**) PowerSystems.jl internal reference.
"""
function ImpedanceCorrectionData(;
    table_number,
    impedance_correction_curve,
    transformer_winding,
    transformer_control_mode,
    internal = InfrastructureSystemsInternal(),
)
    return ImpedanceCorrectionData(
        table_number,
        impedance_correction_curve,
        transformer_winding,
        transformer_control_mode,
        internal,
    )
end

"""Return the `table_number` field of [`ImpedanceCorrectionData`](@ref)."""
get_table_number(value::ImpedanceCorrectionData) = value.table_number
"""Return the `impedance_correction_curve` field of [`ImpedanceCorrectionData`](@ref)."""
get_impedance_correction_curve(value::ImpedanceCorrectionData) =
    value.impedance_correction_curve
"""Return the `transformer_winding` field of [`ImpedanceCorrectionData`](@ref)."""
get_transformer_winding(value::ImpedanceCorrectionData) = value.transformer_winding
"""Return the `transformer_control_mode` field of [`ImpedanceCorrectionData`](@ref)."""
get_transformer_control_mode(value::ImpedanceCorrectionData) =
    value.transformer_control_mode
"""Return the `internal` field of [`ImpedanceCorrectionData`](@ref)."""
get_internal(value::ImpedanceCorrectionData) = value.internal
