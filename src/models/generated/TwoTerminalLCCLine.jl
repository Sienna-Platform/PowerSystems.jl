#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TwoTerminalLCCLine <: TwoTerminalHVDC
        name::String
        available::Bool
        arc::Arc
        active_power_flow::Float64
        r::Float64
        transfer_setpoint::Float64
        scheduled_dc_voltage::Float64
        rectifier_bridges::Int
        rectifier_delay_angle_limits::MinMax
        rectifier_rc::Float64
        rectifier_xc::Float64
        rectifier_base_voltage::Float64
        inverter_bridges::Int
        inverter_extinction_angle_limits::MinMax
        inverter_rc::Float64
        inverter_xc::Float64
        inverter_base_voltage::Float64
        power_mode::Bool
        switch_mode_voltage::Float64
        compounding_resistance::Float64
        min_compounding_voltage::Float64
        rectifier_transformer_ratio::Float64
        rectifier_tap_setting::Float64
        rectifier_tap_limits::MinMax
        rectifier_tap_step::Float64
        rectifier_delay_angle::Float64
        rectifier_capacitor_reactance::Float64
        inverter_transformer_ratio::Float64
        inverter_tap_setting::Float64
        inverter_tap_limits::MinMax
        inverter_tap_step::Float64
        inverter_extinction_angle::Float64
        inverter_capacitor_reactance::Float64
        active_power_limits_from::MinMax
        active_power_limits_to::MinMax
        reactive_power_limits_from::MinMax
        reactive_power_limits_to::MinMax
        loss::Union{LinearCurve, PiecewiseIncrementalCurve}
        services::Vector{Service}
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A Non-Capacitor Line Commutated Converter (LCC)-HVDC transmission line.

As implemented in PSS/E.

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `arc::Arc`: An [`Arc`](@ref) defining this line `from` a rectifier bus `to` an inverter bus. The rectifier bus must be specified in the `from` bus and inverter bus in the `to` bus.
- `active_power_flow::Float64`: Initial condition of active power flow on the line (MW)
- `r::Float64`: Series resistance of the DC line in pu ([`SYSTEM_BASE`](@ref per_unit))
- `transfer_setpoint::Float64`: Desired set-point of power. If `power_mode = true` this value is in MW units, and if `power_mode = false` is in Amperes units. This parameter must not be specified in per-unit. A positive value represents the desired consumed power at the rectifier bus, while a negative value represents the desired power at the inverter bus (i.e. the absolute value of `transfer_setpoint` is the generated power at the inverter bus).
- `scheduled_dc_voltage::Float64`: Scheduled compounded DC voltage in kV. By default this parameter is the scheduled DC voltage in the inverter bus This parameter must not be specified in per-unit.
- `rectifier_bridges::Int`: Number of bridges in series in the rectifier side.
- `rectifier_delay_angle_limits::MinMax`: Minimum and maximum rectifier firing delay angle (α) (radians)
- `rectifier_rc::Float64`: Rectifier commutating transformer resistance per bridge in system p.u. ([`SYSTEM_BASE`](@ref per_unit))
- `rectifier_xc::Float64`: Rectifier commutating transformer reactance per bridge in system p.u. ([`SYSTEM_BASE`](@ref per_unit))
- `rectifier_base_voltage::Float64`: Rectifier primary base AC voltage in kV, entered in kV.
- `inverter_bridges::Int`: Number of bridges in series in the inverter side.
- `inverter_extinction_angle_limits::MinMax`: Minimum and maximum inverter extinction angle (γ) (radians)
- `inverter_rc::Float64`: Inverter commutating transformer resistance per bridge in system p.u. ([`SYSTEM_BASE`](@ref per_unit))
- `inverter_xc::Float64`: Inverter commutating transformer reactance per bridge in system p.u. ([`SYSTEM_BASE`](@ref per_unit))
- `inverter_base_voltage::Float64`: Inverter primary base AC voltage in kV, entered in kV.
- `power_mode::Bool`: (default: `true`) Boolean flag to identify if the LCC line is in power mode or current mode. If `power_mode = true`, setpoint values must be specified in MW, and if `power_mode = false` setpoint values must be specified in Amperes.
- `switch_mode_voltage::Float64`: (default: `0.0`) Mode switch DC voltage, in kV. This parameter must not be added in per-unit. If LCC line is in power mode control, and DC voltage falls below this value, the line switch to current mode control.
- `compounding_resistance::Float64`: (default: `0.0`) Compounding Resistance, in ohms. This parameter is for control of the DC voltage in the rectifier or inverter end. For inverter DC voltage control, the paremeter is set to zero; for rectifier DC voltage control, the paremeter is set to the DC line resistance; otherwise, set to a fraction of the DC line resistance.
- `min_compounding_voltage::Float64`: (default: `0.0`) Minimum compounded voltage, in kV. This parameter must not be added in per-unit. Only used in constant gamma operation (γ_min = γ_max), and the AC transformer is used to control the DC voltage.
- `rectifier_transformer_ratio::Float64`: (default: `1.0`) Rectifier transformer ratio between the primary and secondary side AC voltages.
- `rectifier_tap_setting::Float64`: (default: `1.0`) Rectifier transformer tap setting.
- `rectifier_tap_limits::MinMax`: (default: `(min=0.51, max=1.5)`) Minimum and maximum rectifier tap limits as a ratio between the primary and secondary side AC voltages.
- `rectifier_tap_step::Float64`: (default: `0.00625`) Rectifier transformer tap step value
- `rectifier_delay_angle::Float64`: (default: `0.0`) Rectifier firing delay angle (α).
- `rectifier_capacitor_reactance::Float64`: (default: `0.0`) Commutating rectifier capacitor reactance magnitude per bridge, in system p.u. ([`SYSTEM_BASE`](@ref per_unit)).
- `inverter_transformer_ratio::Float64`: (default: `1.0`) Inverter transformer ratio between the primary and secondary side AC voltages.
- `inverter_tap_setting::Float64`: (default: `1.0`) Inverter transformer tap setting.
- `inverter_tap_limits::MinMax`: (default: `(min=0.51, max=1.5)`) Minimum and maximum inverter tap limits as a ratio between the primary and secondary side AC voltages.
- `inverter_tap_step::Float64`: (default: `0.00625`) Inverter transformer tap step value.
- `inverter_extinction_angle::Float64`: (default: `0.0`) Inverter extinction angle (γ).
- `inverter_capacitor_reactance::Float64`: (default: `0.0`) Commutating inverter capacitor reactance magnitude per bridge, in system p.u. ([`SYSTEM_BASE`](@ref per_unit)).
- `active_power_limits_from::MinMax`: (default: `(min=0.0, max=0.0)`) Minimum and maximum active power flows to the FROM node (MW)
- `active_power_limits_to::MinMax`: (default: `(min=0.0, max=0.0)`) Minimum and maximum active power flows to the TO node (MW)
- `reactive_power_limits_from::MinMax`: (default: `(min=0.0, max=0.0)`) Minimum and maximum reactive power limits to the FROM node (MVAR)
- `reactive_power_limits_to::MinMax`: (default: `(min=0.0, max=0.0)`) Minimum and maximum reactive power limits to the TO node (MVAR)
- `loss::Union{LinearCurve, PiecewiseIncrementalCurve}`: (default: `LinearCurve(0.0)`) A generic loss model coefficients. It accepts a linear model with a constant loss (MW) and a proportional loss rate (MW of loss per MW of flow). It also accepts a Piecewise loss, with N segments to specify different proportional losses for different segments.
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct TwoTerminalLCCLine <: TwoTerminalHVDC
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "An [`Arc`](@ref) defining this line `from` a rectifier bus `to` an inverter bus. The rectifier bus must be specified in the `from` bus and inverter bus in the `to` bus."
    arc::Arc
    "Initial condition of active power flow on the line (MW)"
    active_power_flow::Float64
    "Series resistance of the DC line in pu ([`SYSTEM_BASE`](@ref per_unit))"
    r::Float64
    "Desired set-point of power. If `power_mode = true` this value is in MW units, and if `power_mode = false` is in Amperes units. This parameter must not be specified in per-unit. A positive value represents the desired consumed power at the rectifier bus, while a negative value represents the desired power at the inverter bus (i.e. the absolute value of `transfer_setpoint` is the generated power at the inverter bus)."
    transfer_setpoint::Float64
    "Scheduled compounded DC voltage in kV. By default this parameter is the scheduled DC voltage in the inverter bus This parameter must not be specified in per-unit."
    scheduled_dc_voltage::Float64
    "Number of bridges in series in the rectifier side."
    rectifier_bridges::Int
    "Minimum and maximum rectifier firing delay angle (α) (radians)"
    rectifier_delay_angle_limits::MinMax
    "Rectifier commutating transformer resistance per bridge in system p.u. ([`SYSTEM_BASE`](@ref per_unit))"
    rectifier_rc::Float64
    "Rectifier commutating transformer reactance per bridge in system p.u. ([`SYSTEM_BASE`](@ref per_unit))"
    rectifier_xc::Float64
    "Rectifier primary base AC voltage in kV, entered in kV."
    rectifier_base_voltage::Float64
    "Number of bridges in series in the inverter side."
    inverter_bridges::Int
    "Minimum and maximum inverter extinction angle (γ) (radians)"
    inverter_extinction_angle_limits::MinMax
    "Inverter commutating transformer resistance per bridge in system p.u. ([`SYSTEM_BASE`](@ref per_unit))"
    inverter_rc::Float64
    "Inverter commutating transformer reactance per bridge in system p.u. ([`SYSTEM_BASE`](@ref per_unit))"
    inverter_xc::Float64
    "Inverter primary base AC voltage in kV, entered in kV."
    inverter_base_voltage::Float64
    "Boolean flag to identify if the LCC line is in power mode or current mode. If `power_mode = true`, setpoint values must be specified in MW, and if `power_mode = false` setpoint values must be specified in Amperes."
    power_mode::Bool
    "Mode switch DC voltage, in kV. This parameter must not be added in per-unit. If LCC line is in power mode control, and DC voltage falls below this value, the line switch to current mode control."
    switch_mode_voltage::Float64
    "Compounding Resistance, in ohms. This parameter is for control of the DC voltage in the rectifier or inverter end. For inverter DC voltage control, the paremeter is set to zero; for rectifier DC voltage control, the paremeter is set to the DC line resistance; otherwise, set to a fraction of the DC line resistance."
    compounding_resistance::Float64
    "Minimum compounded voltage, in kV. This parameter must not be added in per-unit. Only used in constant gamma operation (γ_min = γ_max), and the AC transformer is used to control the DC voltage."
    min_compounding_voltage::Float64
    "Rectifier transformer ratio between the primary and secondary side AC voltages."
    rectifier_transformer_ratio::Float64
    "Rectifier transformer tap setting."
    rectifier_tap_setting::Float64
    "Minimum and maximum rectifier tap limits as a ratio between the primary and secondary side AC voltages."
    rectifier_tap_limits::MinMax
    "Rectifier transformer tap step value"
    rectifier_tap_step::Float64
    "Rectifier firing delay angle (α)."
    rectifier_delay_angle::Float64
    "Commutating rectifier capacitor reactance magnitude per bridge, in system p.u. ([`SYSTEM_BASE`](@ref per_unit))."
    rectifier_capacitor_reactance::Float64
    "Inverter transformer ratio between the primary and secondary side AC voltages."
    inverter_transformer_ratio::Float64
    "Inverter transformer tap setting."
    inverter_tap_setting::Float64
    "Minimum and maximum inverter tap limits as a ratio between the primary and secondary side AC voltages."
    inverter_tap_limits::MinMax
    "Inverter transformer tap step value."
    inverter_tap_step::Float64
    "Inverter extinction angle (γ)."
    inverter_extinction_angle::Float64
    "Commutating inverter capacitor reactance magnitude per bridge, in system p.u. ([`SYSTEM_BASE`](@ref per_unit))."
    inverter_capacitor_reactance::Float64
    "Minimum and maximum active power flows to the FROM node (MW)"
    active_power_limits_from::MinMax
    "Minimum and maximum active power flows to the TO node (MW)"
    active_power_limits_to::MinMax
    "Minimum and maximum reactive power limits to the FROM node (MVAR)"
    reactive_power_limits_from::MinMax
    "Minimum and maximum reactive power limits to the TO node (MVAR)"
    reactive_power_limits_to::MinMax
    "A generic loss model coefficients. It accepts a linear model with a constant loss (MW) and a proportional loss rate (MW of loss per MW of flow). It also accepts a Piecewise loss, with N segments to specify different proportional losses for different segments."
    loss::Union{LinearCurve, PiecewiseIncrementalCurve}
    "Services that this device contributes to"
    services::Vector{Service}
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TwoTerminalLCCLine(name, available, arc, active_power_flow, r, transfer_setpoint, scheduled_dc_voltage, rectifier_bridges, rectifier_delay_angle_limits, rectifier_rc, rectifier_xc, rectifier_base_voltage, inverter_bridges, inverter_extinction_angle_limits, inverter_rc, inverter_xc, inverter_base_voltage, power_mode=true, switch_mode_voltage=0.0, compounding_resistance=0.0, min_compounding_voltage=0.0, rectifier_transformer_ratio=1.0, rectifier_tap_setting=1.0, rectifier_tap_limits=(min=0.51, max=1.5), rectifier_tap_step=0.00625, rectifier_delay_angle=0.0, rectifier_capacitor_reactance=0.0, inverter_transformer_ratio=1.0, inverter_tap_setting=1.0, inverter_tap_limits=(min=0.51, max=1.5), inverter_tap_step=0.00625, inverter_extinction_angle=0.0, inverter_capacitor_reactance=0.0, active_power_limits_from=(min=0.0, max=0.0), active_power_limits_to=(min=0.0, max=0.0), reactive_power_limits_from=(min=0.0, max=0.0), reactive_power_limits_to=(min=0.0, max=0.0), loss=LinearCurve(0.0), services=Device[], ext=Dict{String, Any}(), )
    TwoTerminalLCCLine(name, available, arc, active_power_flow, r, transfer_setpoint, scheduled_dc_voltage, rectifier_bridges, rectifier_delay_angle_limits, rectifier_rc, rectifier_xc, rectifier_base_voltage, inverter_bridges, inverter_extinction_angle_limits, inverter_rc, inverter_xc, inverter_base_voltage, power_mode, switch_mode_voltage, compounding_resistance, min_compounding_voltage, rectifier_transformer_ratio, rectifier_tap_setting, rectifier_tap_limits, rectifier_tap_step, rectifier_delay_angle, rectifier_capacitor_reactance, inverter_transformer_ratio, inverter_tap_setting, inverter_tap_limits, inverter_tap_step, inverter_extinction_angle, inverter_capacitor_reactance, active_power_limits_from, active_power_limits_to, reactive_power_limits_from, reactive_power_limits_to, loss, services, ext, InfrastructureSystemsInternal(), )
end

function TwoTerminalLCCLine(; name, available, arc, active_power_flow, r, transfer_setpoint, scheduled_dc_voltage, rectifier_bridges, rectifier_delay_angle_limits, rectifier_rc, rectifier_xc, rectifier_base_voltage, inverter_bridges, inverter_extinction_angle_limits, inverter_rc, inverter_xc, inverter_base_voltage, power_mode=true, switch_mode_voltage=0.0, compounding_resistance=0.0, min_compounding_voltage=0.0, rectifier_transformer_ratio=1.0, rectifier_tap_setting=1.0, rectifier_tap_limits=(min=0.51, max=1.5), rectifier_tap_step=0.00625, rectifier_delay_angle=0.0, rectifier_capacitor_reactance=0.0, inverter_transformer_ratio=1.0, inverter_tap_setting=1.0, inverter_tap_limits=(min=0.51, max=1.5), inverter_tap_step=0.00625, inverter_extinction_angle=0.0, inverter_capacitor_reactance=0.0, active_power_limits_from=(min=0.0, max=0.0), active_power_limits_to=(min=0.0, max=0.0), reactive_power_limits_from=(min=0.0, max=0.0), reactive_power_limits_to=(min=0.0, max=0.0), loss=LinearCurve(0.0), services=Device[], ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    TwoTerminalLCCLine(name, available, arc, active_power_flow, r, transfer_setpoint, scheduled_dc_voltage, rectifier_bridges, rectifier_delay_angle_limits, rectifier_rc, rectifier_xc, rectifier_base_voltage, inverter_bridges, inverter_extinction_angle_limits, inverter_rc, inverter_xc, inverter_base_voltage, power_mode, switch_mode_voltage, compounding_resistance, min_compounding_voltage, rectifier_transformer_ratio, rectifier_tap_setting, rectifier_tap_limits, rectifier_tap_step, rectifier_delay_angle, rectifier_capacitor_reactance, inverter_transformer_ratio, inverter_tap_setting, inverter_tap_limits, inverter_tap_step, inverter_extinction_angle, inverter_capacitor_reactance, active_power_limits_from, active_power_limits_to, reactive_power_limits_from, reactive_power_limits_to, loss, services, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function TwoTerminalLCCLine(::Nothing)
    TwoTerminalLCCLine(;
        name="init",
        available=false,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        active_power_flow=0.0,
        r=0.0,
        transfer_setpoint=0.0,
        scheduled_dc_voltage=0.0,
        rectifier_bridges=0,
        rectifier_delay_angle_limits=(min=0.0, max=0.0),
        rectifier_rc=0.0,
        rectifier_xc=0.0,
        rectifier_base_voltage=0.0,
        inverter_bridges=0,
        inverter_extinction_angle_limits=(min=0.0, max=0.0),
        inverter_rc=0.0,
        inverter_xc=0.0,
        inverter_base_voltage=0.0,
        power_mode=false,
        switch_mode_voltage=0.0,
        compounding_resistance=0.0,
        min_compounding_voltage=0.0,
        rectifier_transformer_ratio=0.0,
        rectifier_tap_setting=0.0,
        rectifier_tap_limits=(min=0.0, max=0.0),
        rectifier_tap_step=0.0,
        rectifier_delay_angle=0.0,
        rectifier_capacitor_reactance=0.0,
        inverter_transformer_ratio=0.0,
        inverter_tap_setting=0.0,
        inverter_tap_limits=(min=0.0, max=0.0),
        inverter_tap_step=0.0,
        inverter_extinction_angle=0.0,
        inverter_capacitor_reactance=0.0,
        active_power_limits_from=(min=0.0, max=0.0),
        active_power_limits_to=(min=0.0, max=0.0),
        reactive_power_limits_from=(min=0.0, max=0.0),
        reactive_power_limits_to=(min=0.0, max=0.0),
        loss=LinearCurve(0.0),
        services=Device[],
        ext=Dict{String, Any}(),
    )
end

"""Get [`TwoTerminalLCCLine`](@ref) `name`."""
get_name(value::TwoTerminalLCCLine) = value.name
"""Get [`TwoTerminalLCCLine`](@ref) `available`."""
get_available(value::TwoTerminalLCCLine) = value.available
"""Get [`TwoTerminalLCCLine`](@ref) `arc`."""
get_arc(value::TwoTerminalLCCLine) = value.arc
"""Get [`TwoTerminalLCCLine`](@ref) `active_power_flow`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_active_power_flow(value::TwoTerminalLCCLine) = get_value(value, Val(:active_power_flow), Val(:mva), DEFAULT_UNITS)
get_active_power_flow(value::TwoTerminalLCCLine, units) = get_value(value, Val(:active_power_flow), Val(:mva), units)
"""Get [`TwoTerminalLCCLine`](@ref) `r`."""
get_r(value::TwoTerminalLCCLine) = value.r
"""Get [`TwoTerminalLCCLine`](@ref) `transfer_setpoint`."""
get_transfer_setpoint(value::TwoTerminalLCCLine) = value.transfer_setpoint
"""Get [`TwoTerminalLCCLine`](@ref) `scheduled_dc_voltage`."""
get_scheduled_dc_voltage(value::TwoTerminalLCCLine) = value.scheduled_dc_voltage
"""Get [`TwoTerminalLCCLine`](@ref) `rectifier_bridges`."""
get_rectifier_bridges(value::TwoTerminalLCCLine) = value.rectifier_bridges
"""Get [`TwoTerminalLCCLine`](@ref) `rectifier_delay_angle_limits`."""
get_rectifier_delay_angle_limits(value::TwoTerminalLCCLine) = value.rectifier_delay_angle_limits
"""Get [`TwoTerminalLCCLine`](@ref) `rectifier_rc`."""
get_rectifier_rc(value::TwoTerminalLCCLine) = value.rectifier_rc
"""Get [`TwoTerminalLCCLine`](@ref) `rectifier_xc`."""
get_rectifier_xc(value::TwoTerminalLCCLine) = value.rectifier_xc
"""Get [`TwoTerminalLCCLine`](@ref) `rectifier_base_voltage`."""
get_rectifier_base_voltage(value::TwoTerminalLCCLine) = value.rectifier_base_voltage
"""Get [`TwoTerminalLCCLine`](@ref) `inverter_bridges`."""
get_inverter_bridges(value::TwoTerminalLCCLine) = value.inverter_bridges
"""Get [`TwoTerminalLCCLine`](@ref) `inverter_extinction_angle_limits`."""
get_inverter_extinction_angle_limits(value::TwoTerminalLCCLine) = value.inverter_extinction_angle_limits
"""Get [`TwoTerminalLCCLine`](@ref) `inverter_rc`."""
get_inverter_rc(value::TwoTerminalLCCLine) = value.inverter_rc
"""Get [`TwoTerminalLCCLine`](@ref) `inverter_xc`."""
get_inverter_xc(value::TwoTerminalLCCLine) = value.inverter_xc
"""Get [`TwoTerminalLCCLine`](@ref) `inverter_base_voltage`."""
get_inverter_base_voltage(value::TwoTerminalLCCLine) = value.inverter_base_voltage
"""Get [`TwoTerminalLCCLine`](@ref) `power_mode`."""
get_power_mode(value::TwoTerminalLCCLine) = value.power_mode
"""Get [`TwoTerminalLCCLine`](@ref) `switch_mode_voltage`."""
get_switch_mode_voltage(value::TwoTerminalLCCLine) = value.switch_mode_voltage
"""Get [`TwoTerminalLCCLine`](@ref) `compounding_resistance`."""
get_compounding_resistance(value::TwoTerminalLCCLine) = value.compounding_resistance
"""Get [`TwoTerminalLCCLine`](@ref) `min_compounding_voltage`."""
get_min_compounding_voltage(value::TwoTerminalLCCLine) = value.min_compounding_voltage
"""Get [`TwoTerminalLCCLine`](@ref) `rectifier_transformer_ratio`."""
get_rectifier_transformer_ratio(value::TwoTerminalLCCLine) = value.rectifier_transformer_ratio
"""Get [`TwoTerminalLCCLine`](@ref) `rectifier_tap_setting`."""
get_rectifier_tap_setting(value::TwoTerminalLCCLine) = value.rectifier_tap_setting
"""Get [`TwoTerminalLCCLine`](@ref) `rectifier_tap_limits`."""
get_rectifier_tap_limits(value::TwoTerminalLCCLine) = value.rectifier_tap_limits
"""Get [`TwoTerminalLCCLine`](@ref) `rectifier_tap_step`."""
get_rectifier_tap_step(value::TwoTerminalLCCLine) = value.rectifier_tap_step
"""Get [`TwoTerminalLCCLine`](@ref) `rectifier_delay_angle`."""
get_rectifier_delay_angle(value::TwoTerminalLCCLine) = value.rectifier_delay_angle
"""Get [`TwoTerminalLCCLine`](@ref) `rectifier_capacitor_reactance`."""
get_rectifier_capacitor_reactance(value::TwoTerminalLCCLine) = value.rectifier_capacitor_reactance
"""Get [`TwoTerminalLCCLine`](@ref) `inverter_transformer_ratio`."""
get_inverter_transformer_ratio(value::TwoTerminalLCCLine) = value.inverter_transformer_ratio
"""Get [`TwoTerminalLCCLine`](@ref) `inverter_tap_setting`."""
get_inverter_tap_setting(value::TwoTerminalLCCLine) = value.inverter_tap_setting
"""Get [`TwoTerminalLCCLine`](@ref) `inverter_tap_limits`."""
get_inverter_tap_limits(value::TwoTerminalLCCLine) = value.inverter_tap_limits
"""Get [`TwoTerminalLCCLine`](@ref) `inverter_tap_step`."""
get_inverter_tap_step(value::TwoTerminalLCCLine) = value.inverter_tap_step
"""Get [`TwoTerminalLCCLine`](@ref) `inverter_extinction_angle`."""
get_inverter_extinction_angle(value::TwoTerminalLCCLine) = value.inverter_extinction_angle
"""Get [`TwoTerminalLCCLine`](@ref) `inverter_capacitor_reactance`."""
get_inverter_capacitor_reactance(value::TwoTerminalLCCLine) = value.inverter_capacitor_reactance
"""Get [`TwoTerminalLCCLine`](@ref) `active_power_limits_from`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_active_power_limits_from(value::TwoTerminalLCCLine) = get_value(value, Val(:active_power_limits_from), Val(:mva), DEFAULT_UNITS)
get_active_power_limits_from(value::TwoTerminalLCCLine, units) = get_value(value, Val(:active_power_limits_from), Val(:mva), units)
"""Get [`TwoTerminalLCCLine`](@ref) `active_power_limits_to`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_active_power_limits_to(value::TwoTerminalLCCLine) = get_value(value, Val(:active_power_limits_to), Val(:mva), DEFAULT_UNITS)
get_active_power_limits_to(value::TwoTerminalLCCLine, units) = get_value(value, Val(:active_power_limits_to), Val(:mva), units)
"""Get [`TwoTerminalLCCLine`](@ref) `reactive_power_limits_from`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_reactive_power_limits_from(value::TwoTerminalLCCLine) = get_value(value, Val(:reactive_power_limits_from), Val(:mva), DEFAULT_UNITS)
get_reactive_power_limits_from(value::TwoTerminalLCCLine, units) = get_value(value, Val(:reactive_power_limits_from), Val(:mva), units)
"""Get [`TwoTerminalLCCLine`](@ref) `reactive_power_limits_to`. Returns value in DEFAULT_UNITS (system base per-unit)."""
get_reactive_power_limits_to(value::TwoTerminalLCCLine) = get_value(value, Val(:reactive_power_limits_to), Val(:mva), DEFAULT_UNITS)
get_reactive_power_limits_to(value::TwoTerminalLCCLine, units) = get_value(value, Val(:reactive_power_limits_to), Val(:mva), units)
"""Get [`TwoTerminalLCCLine`](@ref) `loss`."""
get_loss(value::TwoTerminalLCCLine) = value.loss
"""Get [`TwoTerminalLCCLine`](@ref) `services`."""
get_services(value::TwoTerminalLCCLine) = value.services
"""Get [`TwoTerminalLCCLine`](@ref) `ext`."""
get_ext(value::TwoTerminalLCCLine) = value.ext
"""Get [`TwoTerminalLCCLine`](@ref) `internal`."""
get_internal(value::TwoTerminalLCCLine) = value.internal

"""Set [`TwoTerminalLCCLine`](@ref) `available`."""
set_available!(value::TwoTerminalLCCLine, val) = value.available = val
"""Set [`TwoTerminalLCCLine`](@ref) `arc`."""
set_arc!(value::TwoTerminalLCCLine, val) = value.arc = val
"""Set [`TwoTerminalLCCLine`](@ref) `active_power_flow`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_flow!(value::TwoTerminalLCCLine, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mva))
"""Set [`TwoTerminalLCCLine`](@ref) `r`."""
set_r!(value::TwoTerminalLCCLine, val) = value.r = val
"""Set [`TwoTerminalLCCLine`](@ref) `transfer_setpoint`."""
set_transfer_setpoint!(value::TwoTerminalLCCLine, val) = value.transfer_setpoint = val
"""Set [`TwoTerminalLCCLine`](@ref) `scheduled_dc_voltage`."""
set_scheduled_dc_voltage!(value::TwoTerminalLCCLine, val) = value.scheduled_dc_voltage = val
"""Set [`TwoTerminalLCCLine`](@ref) `rectifier_bridges`."""
set_rectifier_bridges!(value::TwoTerminalLCCLine, val) = value.rectifier_bridges = val
"""Set [`TwoTerminalLCCLine`](@ref) `rectifier_delay_angle_limits`."""
set_rectifier_delay_angle_limits!(value::TwoTerminalLCCLine, val) = value.rectifier_delay_angle_limits = val
"""Set [`TwoTerminalLCCLine`](@ref) `rectifier_rc`."""
set_rectifier_rc!(value::TwoTerminalLCCLine, val) = value.rectifier_rc = val
"""Set [`TwoTerminalLCCLine`](@ref) `rectifier_xc`."""
set_rectifier_xc!(value::TwoTerminalLCCLine, val) = value.rectifier_xc = val
"""Set [`TwoTerminalLCCLine`](@ref) `rectifier_base_voltage`."""
set_rectifier_base_voltage!(value::TwoTerminalLCCLine, val) = value.rectifier_base_voltage = val
"""Set [`TwoTerminalLCCLine`](@ref) `inverter_bridges`."""
set_inverter_bridges!(value::TwoTerminalLCCLine, val) = value.inverter_bridges = val
"""Set [`TwoTerminalLCCLine`](@ref) `inverter_extinction_angle_limits`."""
set_inverter_extinction_angle_limits!(value::TwoTerminalLCCLine, val) = value.inverter_extinction_angle_limits = val
"""Set [`TwoTerminalLCCLine`](@ref) `inverter_rc`."""
set_inverter_rc!(value::TwoTerminalLCCLine, val) = value.inverter_rc = val
"""Set [`TwoTerminalLCCLine`](@ref) `inverter_xc`."""
set_inverter_xc!(value::TwoTerminalLCCLine, val) = value.inverter_xc = val
"""Set [`TwoTerminalLCCLine`](@ref) `inverter_base_voltage`."""
set_inverter_base_voltage!(value::TwoTerminalLCCLine, val) = value.inverter_base_voltage = val
"""Set [`TwoTerminalLCCLine`](@ref) `power_mode`."""
set_power_mode!(value::TwoTerminalLCCLine, val) = value.power_mode = val
"""Set [`TwoTerminalLCCLine`](@ref) `switch_mode_voltage`."""
set_switch_mode_voltage!(value::TwoTerminalLCCLine, val) = value.switch_mode_voltage = val
"""Set [`TwoTerminalLCCLine`](@ref) `compounding_resistance`."""
set_compounding_resistance!(value::TwoTerminalLCCLine, val) = value.compounding_resistance = val
"""Set [`TwoTerminalLCCLine`](@ref) `min_compounding_voltage`."""
set_min_compounding_voltage!(value::TwoTerminalLCCLine, val) = value.min_compounding_voltage = val
"""Set [`TwoTerminalLCCLine`](@ref) `rectifier_transformer_ratio`."""
set_rectifier_transformer_ratio!(value::TwoTerminalLCCLine, val) = value.rectifier_transformer_ratio = val
"""Set [`TwoTerminalLCCLine`](@ref) `rectifier_tap_setting`."""
set_rectifier_tap_setting!(value::TwoTerminalLCCLine, val) = value.rectifier_tap_setting = val
"""Set [`TwoTerminalLCCLine`](@ref) `rectifier_tap_limits`."""
set_rectifier_tap_limits!(value::TwoTerminalLCCLine, val) = value.rectifier_tap_limits = val
"""Set [`TwoTerminalLCCLine`](@ref) `rectifier_tap_step`."""
set_rectifier_tap_step!(value::TwoTerminalLCCLine, val) = value.rectifier_tap_step = val
"""Set [`TwoTerminalLCCLine`](@ref) `rectifier_delay_angle`."""
set_rectifier_delay_angle!(value::TwoTerminalLCCLine, val) = value.rectifier_delay_angle = val
"""Set [`TwoTerminalLCCLine`](@ref) `rectifier_capacitor_reactance`."""
set_rectifier_capacitor_reactance!(value::TwoTerminalLCCLine, val) = value.rectifier_capacitor_reactance = val
"""Set [`TwoTerminalLCCLine`](@ref) `inverter_transformer_ratio`."""
set_inverter_transformer_ratio!(value::TwoTerminalLCCLine, val) = value.inverter_transformer_ratio = val
"""Set [`TwoTerminalLCCLine`](@ref) `inverter_tap_setting`."""
set_inverter_tap_setting!(value::TwoTerminalLCCLine, val) = value.inverter_tap_setting = val
"""Set [`TwoTerminalLCCLine`](@ref) `inverter_tap_limits`."""
set_inverter_tap_limits!(value::TwoTerminalLCCLine, val) = value.inverter_tap_limits = val
"""Set [`TwoTerminalLCCLine`](@ref) `inverter_tap_step`."""
set_inverter_tap_step!(value::TwoTerminalLCCLine, val) = value.inverter_tap_step = val
"""Set [`TwoTerminalLCCLine`](@ref) `inverter_extinction_angle`."""
set_inverter_extinction_angle!(value::TwoTerminalLCCLine, val) = value.inverter_extinction_angle = val
"""Set [`TwoTerminalLCCLine`](@ref) `inverter_capacitor_reactance`."""
set_inverter_capacitor_reactance!(value::TwoTerminalLCCLine, val) = value.inverter_capacitor_reactance = val
"""Set [`TwoTerminalLCCLine`](@ref) `active_power_limits_from`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_limits_from!(value::TwoTerminalLCCLine, val) = value.active_power_limits_from = set_value(value, Val(:active_power_limits_from), val, Val(:mva))
"""Set [`TwoTerminalLCCLine`](@ref) `active_power_limits_to`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_active_power_limits_to!(value::TwoTerminalLCCLine, val) = value.active_power_limits_to = set_value(value, Val(:active_power_limits_to), val, Val(:mva))
"""Set [`TwoTerminalLCCLine`](@ref) `reactive_power_limits_from`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power_limits_from!(value::TwoTerminalLCCLine, val) = value.reactive_power_limits_from = set_value(value, Val(:reactive_power_limits_from), val, Val(:mva))
"""Set [`TwoTerminalLCCLine`](@ref) `reactive_power_limits_to`. Value must have units (e.g., `30.0MW`, `0.5DU`)."""
set_reactive_power_limits_to!(value::TwoTerminalLCCLine, val) = value.reactive_power_limits_to = set_value(value, Val(:reactive_power_limits_to), val, Val(:mva))
"""Set [`TwoTerminalLCCLine`](@ref) `loss`."""
set_loss!(value::TwoTerminalLCCLine, val) = value.loss = val
"""Set [`TwoTerminalLCCLine`](@ref) `services`."""
set_services!(value::TwoTerminalLCCLine, val) = value.services = val
"""Set [`TwoTerminalLCCLine`](@ref) `ext`."""
set_ext!(value::TwoTerminalLCCLine, val) = value.ext = val
