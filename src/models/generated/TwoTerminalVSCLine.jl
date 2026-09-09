#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TwoTerminalVSCLine <: TwoTerminalHVDC
        name::String
        available::Bool
        arc::Arc
        active_power_flow::Float64
        rating::Float64
        active_power_limits_from::MinMax
        active_power_limits_to::MinMax
        g::Float64
        dc_current::Float64
        reactive_power_from::Float64
        dc_control_from::VSCDCControlModes
        ac_control_from::VSCACControlModes
        dc_setpoint_from::Float64
        ac_setpoint_from::Float64
        rated_ac_voltage_from::Float64
        converter_loss_from::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{QuadraticCurve}}
        max_dc_current_from::Float64
        rating_from::Float64
        reactive_power_limits_from::MinMax
        power_factor_weighting_fraction_from::Float64
        voltage_limits_from::MinMax
        dc_voltage_droop_from::Float64
        reactive_power_to::Float64
        dc_control_to::VSCDCControlModes
        ac_control_to::VSCACControlModes
        dc_setpoint_to::Float64
        ac_setpoint_to::Float64
        rated_ac_voltage_to::Float64
        converter_loss_to::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{QuadraticCurve}}
        max_dc_current_to::Float64
        rating_to::Float64
        reactive_power_limits_to::MinMax
        power_factor_weighting_fraction_to::Float64
        voltage_limits_to::MinMax
        dc_voltage_droop_to::Float64
        rated_dc_voltage::Float64
        remote_bus_control_from::Union{Nothing, Int}
        remote_bus_control_to::Union{Nothing, Int}
        rmpct_from::Float64
        rmpct_to::Float64
        services::Vector{Service}
        base_power::Float64
        ext::Dict{String, Any}
        internal::InfrastructureSystemsInternal
    end

A High Voltage Voltage-Source Converter DC line, which must be connected to an [`ACBus`](@ref) on each end.

This model is appropriate for operational simulations with a linearized DC power flow approximation with losses using a voltage-current model. For modeling a DC network, see [`TModelHVDCLine`](@ref)

# Arguments
- `name::String`: Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations
- `arc::Arc`: An [`Arc`](@ref) defining this line `from` a bus `to` another bus
- `active_power_flow::Float64`: Initial condition of active power flowing from the from-bus to the to-bus in DC.
- `rating::Float64`: Maximum output power rating of the converter (MVA), validation range: `(0, nothing)`
- `active_power_limits_from::MinMax`: Minimum and maximum active power flows to the FROM node (MW)
- `active_power_limits_to::MinMax`: Minimum and maximum active power flows to the TO node (MW)
- `g::Float64`: (default: `0.0`) Series conductance of the DC line in pu ([`SYSTEM_BASE`](@ref per_unit))
- `dc_current::Float64`: (default: `0.0`) DC current (A) on the converter flowing in the DC line, from `from` bus to `to` bus.
- `reactive_power_from::Float64`: (default: `0.0`) Initial condition of reactive power flowing into the from-bus.
- `dc_control_from::VSCDCControlModes`: (default: `VSCDCControlModes.DC_VOLTAGE`) DC-side control mode of the `from` converter; see [`VSCDCControlModes`](@ref).
- `ac_control_from::VSCACControlModes`: (default: `VSCACControlModes.AC_VOLTAGE`) AC-side control mode of the `from` converter; see [`VSCACControlModes`](@ref).
- `dc_setpoint_from::Float64`: (default: `0.0`) Converter DC setpoint on the `from` bus converter, in per-unit. For a DC-voltage-controlling mode (`dc_control_from` is `DC_VOLTAGE` or `DC_VOLTAGE_DROOP`) this is the DC-side voltage in per-unit of `rated_dc_voltage`. For `DC_POWER` this is the active-power demand in per-unit ([`SYSTEM_BASE`](@ref per_unit)); positive means the converter supplies power to the AC network at the `from` bus, negative means it withdraws.
- `ac_setpoint_from::Float64`: (default: `1.0`) Converter AC setpoint in the `from` bus converter. When `ac_control_from` is `AC_VOLTAGE` this is the AC voltage on the AC side of the converter, in per-unit of `rated_ac_voltage_from`. When `ac_control_from` is `AC_REACTIVE_POWER`, this value is the power factor setpoint.
- `rated_ac_voltage_from::Float64`: (default: `0.0`) Rated (base) AC voltage at the `from` converter's AC terminal in kV. Used as the AC voltage base for interpreting `ac_setpoint_from` when `ac_control_from` is `AC_VOLTAGE`; `0.0` means unspecified (the setpoint is taken as per-unit directly).
- `converter_loss_from::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{QuadraticCurve}}`: (default: `LossCurve(LinearCurve(0.0), NaturalUnit())`) Loss model coefficients in the `from` bus converter. It accepts a linear model or quadratic. Same converter data is used in both ends.
- `max_dc_current_from::Float64`: (default: `1e8`) Maximum stable dc current limits (A).
- `rating_from::Float64`: (default: `1e8`) Converter rating in MVA in the `from` bus.
- `reactive_power_limits_from::MinMax`: (default: `(min=0.0, max=0.0)`) Limits on the Reactive Power at the `from` side.
- `power_factor_weighting_fraction_from::Float64`: (default: `1.0`) Power weighting factor fraction used in reducing the active power order and either the reactive power order when the converter rating is violated. When is 0.0, only the active power is reduced; when is 1.0, only the reactive power is reduced; otherwise, a weighted reduction of both active and reactive power is applied., validation range: `(0, 1)`
- `voltage_limits_from::MinMax`: (default: `(min=0.0, max=999.9)`) Limits on the Voltage at the DC `from` Bus in [per unit](@ref per_unit.
- `dc_voltage_droop_from::Float64`: (default: `0.0`) DC-voltage droop gain on the `from` converter, used when `dc_control_from` is `DC_VOLTAGE_DROOP`: `V_dc = dc_setpoint_from + dc_voltage_droop_from * P_c` (with `P_c` the converter's AC-side active-power injection).
- `reactive_power_to::Float64`: (default: `0.0`) Initial condition of reactive power flowing into the to-bus.
- `dc_control_to::VSCDCControlModes`: (default: `VSCDCControlModes.DC_VOLTAGE`) DC-side control mode of the `to` converter; see [`VSCDCControlModes`](@ref).
- `ac_control_to::VSCACControlModes`: (default: `VSCACControlModes.AC_VOLTAGE`) AC-side control mode of the `to` converter; see [`VSCACControlModes`](@ref).
- `dc_setpoint_to::Float64`: (default: `0.0`) Converter DC setpoint on the `to` bus converter, in per-unit. For a DC-voltage-controlling mode (`dc_control_to` is `DC_VOLTAGE` or `DC_VOLTAGE_DROOP`) this is the DC-side voltage in per-unit of `rated_dc_voltage`. For `DC_POWER` this is the active-power demand in per-unit ([`SYSTEM_BASE`](@ref per_unit)); positive means the converter supplies power to the AC network at the `to` bus, negative means it withdraws.
- `ac_setpoint_to::Float64`: (default: `1.0`) Converter AC setpoint in the `to` bus converter. When `ac_control_to` is `AC_VOLTAGE` this is the AC voltage on the AC side of the converter, in per-unit of `rated_ac_voltage_to`. When `ac_control_to` is `AC_REACTIVE_POWER`, this value is the power factor setpoint.
- `rated_ac_voltage_to::Float64`: (default: `0.0`) Rated (base) AC voltage at the `to` converter's AC terminal in kV. Used as the AC voltage base for interpreting `ac_setpoint_to` when `ac_control_to` is `AC_VOLTAGE`; `0.0` means unspecified (the setpoint is taken as per-unit directly).
- `converter_loss_to::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{QuadraticCurve}}`: (default: `LossCurve(LinearCurve(0.0), NaturalUnit())`) Loss model coefficients in the `to` bus converter. It accepts a linear model or quadratic. Same converter data is used in both ends.
- `max_dc_current_to::Float64`: (default: `1e8`) Maximum stable dc current limits (A).
- `rating_to::Float64`: (default: `1e8`) Converter rating in MVA in the `to` bus.
- `reactive_power_limits_to::MinMax`: (default: `(min=0.0, max=0.0)`) Limits on the Reactive Power at the `to` side.
- `power_factor_weighting_fraction_to::Float64`: (default: `1.0`) Power weighting factor fraction used in reducing the active power order and either the reactive power order when the converter rating is violated. When is 0.0, only the active power is reduced; when is 1.0, only the reactive power is reduced; otherwise, a weighted reduction of both active and reactive power is applied., validation range: `(0, 1)`
- `voltage_limits_to::MinMax`: (default: `(min=0.0, max=999.9)`) Limits on the Voltage at the DC `to` Bus.
- `dc_voltage_droop_to::Float64`: (default: `0.0`) DC-voltage droop gain on the `to` converter, used when `dc_control_to` is `DC_VOLTAGE_DROOP`: `V_dc = dc_setpoint_to + dc_voltage_droop_to * P_c` (with `P_c` the converter's AC-side active-power injection).
- `rated_dc_voltage::Float64`: (default: `0.0`) Rated (base) DC voltage of the link in kV. Used as the DC voltage base for interpreting DC-voltage setpoints; `0.0` means unspecified (DC-voltage setpoints are taken as per-unit directly).
- `remote_bus_control_from::Union{Nothing, Int}`: (default: `nothing`) Number of the AC bus whose voltage the `from` converter regulates when `ac_control_from` is `AC_VOLTAGE`; `nothing` regulates its own terminal bus., validation range: `(1, nothing)`
- `remote_bus_control_to::Union{Nothing, Int}`: (default: `nothing`) Number of the AC bus whose voltage the `to` converter regulates when `ac_control_to` is `AC_VOLTAGE`; `nothing` regulates its own terminal bus., validation range: `(1, nothing)`
- `rmpct_from::Float64`: (default: `100.0`) Percent of the total MVAr required to hold the voltage at the bus regulated by the `from` converter that is contributed by this converter.
- `rmpct_to::Float64`: (default: `100.0`) Percent of the total MVAr required to hold the voltage at the bus regulated by the `to` converter that is contributed by this converter.
- `services::Vector{Service}`: (default: `Device[]`) Services that this device contributes to
- `base_power::Float64`: (default: `100.0`) System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA), validation range: `(0.0001, nothing)`
- `ext::Dict{String, Any}`: (default: `Dict{String, Any}()`) An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation.
- `internal::InfrastructureSystemsInternal`: (**Do not modify.**) PowerSystems.jl internal reference
"""
mutable struct TwoTerminalVSCLine <: TwoTerminalHVDC
    "Name of the component. Components of the same type (e.g., `PowerLoad`) must have unique names, but components of different types (e.g., `PowerLoad` and `ACBus`) can have the same name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`). Unavailable components are excluded during simulations"
    available::Bool
    "An [`Arc`](@ref) defining this line `from` a bus `to` another bus"
    arc::Arc
    "Initial condition of active power flowing from the from-bus to the to-bus in DC."
    active_power_flow::Float64
    "Maximum output power rating of the converter (MVA)"
    rating::Float64
    "Minimum and maximum active power flows to the FROM node (MW)"
    active_power_limits_from::MinMax
    "Minimum and maximum active power flows to the TO node (MW)"
    active_power_limits_to::MinMax
    "Series conductance of the DC line in pu ([`SYSTEM_BASE`](@ref per_unit))"
    g::Float64
    "DC current (A) on the converter flowing in the DC line, from `from` bus to `to` bus."
    dc_current::Float64
    "Initial condition of reactive power flowing into the from-bus."
    reactive_power_from::Float64
    "DC-side control mode of the `from` converter; see [`VSCDCControlModes`](@ref)."
    dc_control_from::VSCDCControlModes
    "AC-side control mode of the `from` converter; see [`VSCACControlModes`](@ref)."
    ac_control_from::VSCACControlModes
    "Converter DC setpoint on the `from` bus converter, in per-unit. For a DC-voltage-controlling mode (`dc_control_from` is `DC_VOLTAGE` or `DC_VOLTAGE_DROOP`) this is the DC-side voltage in per-unit of `rated_dc_voltage`. For `DC_POWER` this is the active-power demand in per-unit ([`SYSTEM_BASE`](@ref per_unit)); positive means the converter supplies power to the AC network at the `from` bus, negative means it withdraws."
    dc_setpoint_from::Float64
    "Converter AC setpoint in the `from` bus converter. When `ac_control_from` is `AC_VOLTAGE` this is the AC voltage on the AC side of the converter, in per-unit of `rated_ac_voltage_from`. When `ac_control_from` is `AC_REACTIVE_POWER`, this value is the power factor setpoint."
    ac_setpoint_from::Float64
    "Rated (base) AC voltage at the `from` converter's AC terminal in kV. Used as the AC voltage base for interpreting `ac_setpoint_from` when `ac_control_from` is `AC_VOLTAGE`; `0.0` means unspecified (the setpoint is taken as per-unit directly)."
    rated_ac_voltage_from::Float64
    "Loss model coefficients in the `from` bus converter. It accepts a linear model or quadratic. Same converter data is used in both ends."
    converter_loss_from::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{QuadraticCurve}}
    "Maximum stable dc current limits (A)."
    max_dc_current_from::Float64
    "Converter rating in MVA in the `from` bus."
    rating_from::Float64
    "Limits on the Reactive Power at the `from` side."
    reactive_power_limits_from::MinMax
    "Power weighting factor fraction used in reducing the active power order and either the reactive power order when the converter rating is violated. When is 0.0, only the active power is reduced; when is 1.0, only the reactive power is reduced; otherwise, a weighted reduction of both active and reactive power is applied."
    power_factor_weighting_fraction_from::Float64
    "Limits on the Voltage at the DC `from` Bus in [per unit](@ref per_unit."
    voltage_limits_from::MinMax
    "DC-voltage droop gain on the `from` converter, used when `dc_control_from` is `DC_VOLTAGE_DROOP`: `V_dc = dc_setpoint_from + dc_voltage_droop_from * P_c` (with `P_c` the converter's AC-side active-power injection)."
    dc_voltage_droop_from::Float64
    "Initial condition of reactive power flowing into the to-bus."
    reactive_power_to::Float64
    "DC-side control mode of the `to` converter; see [`VSCDCControlModes`](@ref)."
    dc_control_to::VSCDCControlModes
    "AC-side control mode of the `to` converter; see [`VSCACControlModes`](@ref)."
    ac_control_to::VSCACControlModes
    "Converter DC setpoint on the `to` bus converter, in per-unit. For a DC-voltage-controlling mode (`dc_control_to` is `DC_VOLTAGE` or `DC_VOLTAGE_DROOP`) this is the DC-side voltage in per-unit of `rated_dc_voltage`. For `DC_POWER` this is the active-power demand in per-unit ([`SYSTEM_BASE`](@ref per_unit)); positive means the converter supplies power to the AC network at the `to` bus, negative means it withdraws."
    dc_setpoint_to::Float64
    "Converter AC setpoint in the `to` bus converter. When `ac_control_to` is `AC_VOLTAGE` this is the AC voltage on the AC side of the converter, in per-unit of `rated_ac_voltage_to`. When `ac_control_to` is `AC_REACTIVE_POWER`, this value is the power factor setpoint."
    ac_setpoint_to::Float64
    "Rated (base) AC voltage at the `to` converter's AC terminal in kV. Used as the AC voltage base for interpreting `ac_setpoint_to` when `ac_control_to` is `AC_VOLTAGE`; `0.0` means unspecified (the setpoint is taken as per-unit directly)."
    rated_ac_voltage_to::Float64
    "Loss model coefficients in the `to` bus converter. It accepts a linear model or quadratic. Same converter data is used in both ends."
    converter_loss_to::Union{AnyLossCurve{LinearCurve}, AnyLossCurve{QuadraticCurve}}
    "Maximum stable dc current limits (A)."
    max_dc_current_to::Float64
    "Converter rating in MVA in the `to` bus."
    rating_to::Float64
    "Limits on the Reactive Power at the `to` side."
    reactive_power_limits_to::MinMax
    "Power weighting factor fraction used in reducing the active power order and either the reactive power order when the converter rating is violated. When is 0.0, only the active power is reduced; when is 1.0, only the reactive power is reduced; otherwise, a weighted reduction of both active and reactive power is applied."
    power_factor_weighting_fraction_to::Float64
    "Limits on the Voltage at the DC `to` Bus."
    voltage_limits_to::MinMax
    "DC-voltage droop gain on the `to` converter, used when `dc_control_to` is `DC_VOLTAGE_DROOP`: `V_dc = dc_setpoint_to + dc_voltage_droop_to * P_c` (with `P_c` the converter's AC-side active-power injection)."
    dc_voltage_droop_to::Float64
    "Rated (base) DC voltage of the link in kV. Used as the DC voltage base for interpreting DC-voltage setpoints; `0.0` means unspecified (DC-voltage setpoints are taken as per-unit directly)."
    rated_dc_voltage::Float64
    "Number of the AC bus whose voltage the `from` converter regulates when `ac_control_from` is `AC_VOLTAGE`; `nothing` regulates its own terminal bus."
    remote_bus_control_from::Union{Nothing, Int}
    "Number of the AC bus whose voltage the `to` converter regulates when `ac_control_to` is `AC_VOLTAGE`; `nothing` regulates its own terminal bus."
    remote_bus_control_to::Union{Nothing, Int}
    "Percent of the total MVAr required to hold the voltage at the bus regulated by the `from` converter that is contributed by this converter."
    rmpct_from::Float64
    "Percent of the total MVAr required to hold the voltage at the bus regulated by the `to` converter that is contributed by this converter."
    rmpct_to::Float64
    "Services that this device contributes to"
    services::Vector{Service}
    "System base power for per-unitization of this component's per-unit fields, recorded per component in lieu of a system-level table (MVA)"
    base_power::Float64
    "An [*ext*ra dictionary](@ref additional_fields) for users to add metadata that are not used in simulation."
    ext::Dict{String, Any}
    "(**Do not modify.**) PowerSystems.jl internal reference"
    internal::InfrastructureSystemsInternal
end

function TwoTerminalVSCLine(name, available, arc, active_power_flow, rating, active_power_limits_from, active_power_limits_to, g=0.0, dc_current=0.0, reactive_power_from=0.0, dc_control_from=VSCDCControlModes.DC_VOLTAGE, ac_control_from=VSCACControlModes.AC_VOLTAGE, dc_setpoint_from=0.0, ac_setpoint_from=1.0, rated_ac_voltage_from=0.0, converter_loss_from=LossCurve(LinearCurve(0.0), NaturalUnit()), max_dc_current_from=1e8, rating_from=1e8, reactive_power_limits_from=(min=0.0, max=0.0), power_factor_weighting_fraction_from=1.0, voltage_limits_from=(min=0.0, max=999.9), dc_voltage_droop_from=0.0, reactive_power_to=0.0, dc_control_to=VSCDCControlModes.DC_VOLTAGE, ac_control_to=VSCACControlModes.AC_VOLTAGE, dc_setpoint_to=0.0, ac_setpoint_to=1.0, rated_ac_voltage_to=0.0, converter_loss_to=LossCurve(LinearCurve(0.0), NaturalUnit()), max_dc_current_to=1e8, rating_to=1e8, reactive_power_limits_to=(min=0.0, max=0.0), power_factor_weighting_fraction_to=1.0, voltage_limits_to=(min=0.0, max=999.9), dc_voltage_droop_to=0.0, rated_dc_voltage=0.0, remote_bus_control_from=nothing, remote_bus_control_to=nothing, rmpct_from=100.0, rmpct_to=100.0, services=Device[], base_power=100.0, ext=Dict{String, Any}(), )
    TwoTerminalVSCLine(name, available, arc, active_power_flow, rating, active_power_limits_from, active_power_limits_to, g, dc_current, reactive_power_from, dc_control_from, ac_control_from, dc_setpoint_from, ac_setpoint_from, rated_ac_voltage_from, converter_loss_from, max_dc_current_from, rating_from, reactive_power_limits_from, power_factor_weighting_fraction_from, voltage_limits_from, dc_voltage_droop_from, reactive_power_to, dc_control_to, ac_control_to, dc_setpoint_to, ac_setpoint_to, rated_ac_voltage_to, converter_loss_to, max_dc_current_to, rating_to, reactive_power_limits_to, power_factor_weighting_fraction_to, voltage_limits_to, dc_voltage_droop_to, rated_dc_voltage, remote_bus_control_from, remote_bus_control_to, rmpct_from, rmpct_to, services, base_power, ext, InfrastructureSystemsInternal(), )
end

function TwoTerminalVSCLine(; name, available, arc, active_power_flow, rating, active_power_limits_from, active_power_limits_to, g=0.0, dc_current=0.0, reactive_power_from=0.0, dc_control_from=VSCDCControlModes.DC_VOLTAGE, ac_control_from=VSCACControlModes.AC_VOLTAGE, dc_setpoint_from=0.0, ac_setpoint_from=1.0, rated_ac_voltage_from=0.0, converter_loss_from=LossCurve(LinearCurve(0.0), NaturalUnit()), max_dc_current_from=1e8, rating_from=1e8, reactive_power_limits_from=(min=0.0, max=0.0), power_factor_weighting_fraction_from=1.0, voltage_limits_from=(min=0.0, max=999.9), dc_voltage_droop_from=0.0, reactive_power_to=0.0, dc_control_to=VSCDCControlModes.DC_VOLTAGE, ac_control_to=VSCACControlModes.AC_VOLTAGE, dc_setpoint_to=0.0, ac_setpoint_to=1.0, rated_ac_voltage_to=0.0, converter_loss_to=LossCurve(LinearCurve(0.0), NaturalUnit()), max_dc_current_to=1e8, rating_to=1e8, reactive_power_limits_to=(min=0.0, max=0.0), power_factor_weighting_fraction_to=1.0, voltage_limits_to=(min=0.0, max=999.9), dc_voltage_droop_to=0.0, rated_dc_voltage=0.0, remote_bus_control_from=nothing, remote_bus_control_to=nothing, rmpct_from=100.0, rmpct_to=100.0, services=Device[], base_power=100.0, ext=Dict{String, Any}(), internal=InfrastructureSystemsInternal(), )
    TwoTerminalVSCLine(name, available, arc, active_power_flow, rating, active_power_limits_from, active_power_limits_to, g, dc_current, reactive_power_from, dc_control_from, ac_control_from, dc_setpoint_from, ac_setpoint_from, rated_ac_voltage_from, converter_loss_from, max_dc_current_from, rating_from, reactive_power_limits_from, power_factor_weighting_fraction_from, voltage_limits_from, dc_voltage_droop_from, reactive_power_to, dc_control_to, ac_control_to, dc_setpoint_to, ac_setpoint_to, rated_ac_voltage_to, converter_loss_to, max_dc_current_to, rating_to, reactive_power_limits_to, power_factor_weighting_fraction_to, voltage_limits_to, dc_voltage_droop_to, rated_dc_voltage, remote_bus_control_from, remote_bus_control_to, rmpct_from, rmpct_to, services, base_power, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function TwoTerminalVSCLine(::Nothing)
    TwoTerminalVSCLine(;
        name="init",
        available=false,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        active_power_flow=0.0,
        rating=0.0,
        active_power_limits_from=(min=0.0, max=0.0),
        active_power_limits_to=(min=0.0, max=0.0),
        g=0.0,
        dc_current=0.0,
        reactive_power_from=0.0,
        dc_control_from=VSCDCControlModes.DC_VOLTAGE,
        ac_control_from=VSCACControlModes.AC_VOLTAGE,
        dc_setpoint_from=0.0,
        ac_setpoint_from=0.0,
        rated_ac_voltage_from=0.0,
        converter_loss_from=LossCurve(LinearCurve(0.0), NaturalUnit()),
        max_dc_current_from=0.0,
        rating_from=0.0,
        reactive_power_limits_from=(min=0.0, max=0.0),
        power_factor_weighting_fraction_from=0.0,
        voltage_limits_from=(min=0.0, max=0.0),
        dc_voltage_droop_from=0.0,
        reactive_power_to=0.0,
        dc_control_to=VSCDCControlModes.DC_VOLTAGE,
        ac_control_to=VSCACControlModes.AC_VOLTAGE,
        dc_setpoint_to=0.0,
        ac_setpoint_to=0.0,
        rated_ac_voltage_to=0.0,
        converter_loss_to=LossCurve(LinearCurve(0.0), NaturalUnit()),
        max_dc_current_to=0.0,
        rating_to=0.0,
        reactive_power_limits_to=(min=0.0, max=0.0),
        power_factor_weighting_fraction_to=0.0,
        voltage_limits_to=(min=0.0, max=0.0),
        dc_voltage_droop_to=0.0,
        rated_dc_voltage=0.0,
        remote_bus_control_from=nothing,
        remote_bus_control_to=nothing,
        rmpct_from=100.0,
        rmpct_to=100.0,
        services=Device[],
        base_power=100.0,
        ext=Dict{String, Any}(),
    )
end

"""Get [`TwoTerminalVSCLine`](@ref) `name`."""
get_name(value::TwoTerminalVSCLine) = value.name
"""Get [`TwoTerminalVSCLine`](@ref) `available`."""
get_available(value::TwoTerminalVSCLine) = value.available
"""Get [`TwoTerminalVSCLine`](@ref) `arc`."""
get_arc(value::TwoTerminalVSCLine) = value.arc
"""Get [`TwoTerminalVSCLine`](@ref) `active_power_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_flow_unitful`](@ref)."""
get_active_power_flow(value::TwoTerminalVSCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_flow), Val(:mw), units))
"""Get [`TwoTerminalVSCLine`](@ref) `active_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_flow`](@ref)."""
get_active_power_flow_unitful(value::TwoTerminalVSCLine, units) = get_value(value, Val(:active_power_flow), Val(:mw), units)
get_active_power_flow(value::TwoTerminalVSCLine) = _units_arg_required(get_active_power_flow, value, :active_power_flow, Val(:mw))
get_active_power_flow_unitful(value::TwoTerminalVSCLine) = _units_arg_required(get_active_power_flow_unitful, value, :active_power_flow, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_unitful), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalVSCLine`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::TwoTerminalVSCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`TwoTerminalVSCLine`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::TwoTerminalVSCLine, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::TwoTerminalVSCLine) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::TwoTerminalVSCLine) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.DU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.DU
"""Get [`TwoTerminalVSCLine`](@ref) `active_power_limits_from` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_limits_from_unitful`](@ref)."""
get_active_power_limits_from(value::TwoTerminalVSCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits_from), Val(:mw), units))
"""Get [`TwoTerminalVSCLine`](@ref) `active_power_limits_from` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_limits_from`](@ref)."""
get_active_power_limits_from_unitful(value::TwoTerminalVSCLine, units) = get_value(value, Val(:active_power_limits_from), Val(:mw), units)
get_active_power_limits_from(value::TwoTerminalVSCLine) = _units_arg_required(get_active_power_limits_from, value, :active_power_limits_from, Val(:mw))
get_active_power_limits_from_unitful(value::TwoTerminalVSCLine) = _units_arg_required(get_active_power_limits_from_unitful, value, :active_power_limits_from, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_from), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_from_unitful), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalVSCLine`](@ref) `active_power_limits_to` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_limits_to_unitful`](@ref)."""
get_active_power_limits_to(value::TwoTerminalVSCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_limits_to), Val(:mw), units))
"""Get [`TwoTerminalVSCLine`](@ref) `active_power_limits_to` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_limits_to`](@ref)."""
get_active_power_limits_to_unitful(value::TwoTerminalVSCLine, units) = get_value(value, Val(:active_power_limits_to), Val(:mw), units)
get_active_power_limits_to(value::TwoTerminalVSCLine) = _units_arg_required(get_active_power_limits_to, value, :active_power_limits_to, Val(:mw))
get_active_power_limits_to_unitful(value::TwoTerminalVSCLine) = _units_arg_required(get_active_power_limits_to_unitful, value, :active_power_limits_to, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_to), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_limits_to_unitful), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalVSCLine`](@ref) `g`."""
get_g(value::TwoTerminalVSCLine) = value.g
"""Get [`TwoTerminalVSCLine`](@ref) `dc_current`."""
get_dc_current(value::TwoTerminalVSCLine) = value.dc_current
"""Get [`TwoTerminalVSCLine`](@ref) `reactive_power_from` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_from_unitful`](@ref)."""
get_reactive_power_from(value::TwoTerminalVSCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_from), Val(:mvar), units))
"""Get [`TwoTerminalVSCLine`](@ref) `reactive_power_from` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_from`](@ref)."""
get_reactive_power_from_unitful(value::TwoTerminalVSCLine, units) = get_value(value, Val(:reactive_power_from), Val(:mvar), units)
get_reactive_power_from(value::TwoTerminalVSCLine) = _units_arg_required(get_reactive_power_from, value, :reactive_power_from, Val(:mvar))
get_reactive_power_from_unitful(value::TwoTerminalVSCLine) = _units_arg_required(get_reactive_power_from_unitful, value, :reactive_power_from, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_from), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_from_unitful), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalVSCLine`](@ref) `dc_control_from`."""
get_dc_control_from(value::TwoTerminalVSCLine) = value.dc_control_from
"""Get [`TwoTerminalVSCLine`](@ref) `ac_control_from`."""
get_ac_control_from(value::TwoTerminalVSCLine) = value.ac_control_from
"""Get [`TwoTerminalVSCLine`](@ref) `dc_setpoint_from`."""
get_dc_setpoint_from(value::TwoTerminalVSCLine) = value.dc_setpoint_from
"""Get [`TwoTerminalVSCLine`](@ref) `ac_setpoint_from`."""
get_ac_setpoint_from(value::TwoTerminalVSCLine) = value.ac_setpoint_from
"""Get [`TwoTerminalVSCLine`](@ref) `rated_ac_voltage_from`."""
get_rated_ac_voltage_from(value::TwoTerminalVSCLine) = value.rated_ac_voltage_from
"""Get [`TwoTerminalVSCLine`](@ref) `converter_loss_from`."""
get_converter_loss_from(value::TwoTerminalVSCLine) = value.converter_loss_from
"""Get [`TwoTerminalVSCLine`](@ref) `max_dc_current_from`."""
get_max_dc_current_from(value::TwoTerminalVSCLine) = value.max_dc_current_from
"""Get [`TwoTerminalVSCLine`](@ref) `rating_from` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_from_unitful`](@ref)."""
get_rating_from(value::TwoTerminalVSCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating_from), Val(:mva), units))
"""Get [`TwoTerminalVSCLine`](@ref) `rating_from` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating_from`](@ref)."""
get_rating_from_unitful(value::TwoTerminalVSCLine, units) = get_value(value, Val(:rating_from), Val(:mva), units)
get_rating_from(value::TwoTerminalVSCLine) = _units_arg_required(get_rating_from, value, :rating_from, Val(:mva))
get_rating_from_unitful(value::TwoTerminalVSCLine) = _units_arg_required(get_rating_from_unitful, value, :rating_from, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating_from), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_rating_from_unitful), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalVSCLine`](@ref) `reactive_power_limits_from` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_from_unitful`](@ref)."""
get_reactive_power_limits_from(value::TwoTerminalVSCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits_from), Val(:mvar), units))
"""Get [`TwoTerminalVSCLine`](@ref) `reactive_power_limits_from` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_limits_from`](@ref)."""
get_reactive_power_limits_from_unitful(value::TwoTerminalVSCLine, units) = get_value(value, Val(:reactive_power_limits_from), Val(:mvar), units)
get_reactive_power_limits_from(value::TwoTerminalVSCLine) = _units_arg_required(get_reactive_power_limits_from, value, :reactive_power_limits_from, Val(:mvar))
get_reactive_power_limits_from_unitful(value::TwoTerminalVSCLine) = _units_arg_required(get_reactive_power_limits_from_unitful, value, :reactive_power_limits_from, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_from), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_from_unitful), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalVSCLine`](@ref) `power_factor_weighting_fraction_from`."""
get_power_factor_weighting_fraction_from(value::TwoTerminalVSCLine) = value.power_factor_weighting_fraction_from
"""Get [`TwoTerminalVSCLine`](@ref) `voltage_limits_from`."""
get_voltage_limits_from(value::TwoTerminalVSCLine) = value.voltage_limits_from
"""Get [`TwoTerminalVSCLine`](@ref) `dc_voltage_droop_from`."""
get_dc_voltage_droop_from(value::TwoTerminalVSCLine) = value.dc_voltage_droop_from
"""Get [`TwoTerminalVSCLine`](@ref) `reactive_power_to` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_to_unitful`](@ref)."""
get_reactive_power_to(value::TwoTerminalVSCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_to), Val(:mvar), units))
"""Get [`TwoTerminalVSCLine`](@ref) `reactive_power_to` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_to`](@ref)."""
get_reactive_power_to_unitful(value::TwoTerminalVSCLine, units) = get_value(value, Val(:reactive_power_to), Val(:mvar), units)
get_reactive_power_to(value::TwoTerminalVSCLine) = _units_arg_required(get_reactive_power_to, value, :reactive_power_to, Val(:mvar))
get_reactive_power_to_unitful(value::TwoTerminalVSCLine) = _units_arg_required(get_reactive_power_to_unitful, value, :reactive_power_to, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_to), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_to_unitful), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalVSCLine`](@ref) `dc_control_to`."""
get_dc_control_to(value::TwoTerminalVSCLine) = value.dc_control_to
"""Get [`TwoTerminalVSCLine`](@ref) `ac_control_to`."""
get_ac_control_to(value::TwoTerminalVSCLine) = value.ac_control_to
"""Get [`TwoTerminalVSCLine`](@ref) `dc_setpoint_to`."""
get_dc_setpoint_to(value::TwoTerminalVSCLine) = value.dc_setpoint_to
"""Get [`TwoTerminalVSCLine`](@ref) `ac_setpoint_to`."""
get_ac_setpoint_to(value::TwoTerminalVSCLine) = value.ac_setpoint_to
"""Get [`TwoTerminalVSCLine`](@ref) `rated_ac_voltage_to`."""
get_rated_ac_voltage_to(value::TwoTerminalVSCLine) = value.rated_ac_voltage_to
"""Get [`TwoTerminalVSCLine`](@ref) `converter_loss_to`."""
get_converter_loss_to(value::TwoTerminalVSCLine) = value.converter_loss_to
"""Get [`TwoTerminalVSCLine`](@ref) `max_dc_current_to`."""
get_max_dc_current_to(value::TwoTerminalVSCLine) = value.max_dc_current_to
"""Get [`TwoTerminalVSCLine`](@ref) `rating_to` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_to_unitful`](@ref)."""
get_rating_to(value::TwoTerminalVSCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating_to), Val(:mva), units))
"""Get [`TwoTerminalVSCLine`](@ref) `rating_to` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating_to`](@ref)."""
get_rating_to_unitful(value::TwoTerminalVSCLine, units) = get_value(value, Val(:rating_to), Val(:mva), units)
get_rating_to(value::TwoTerminalVSCLine) = _units_arg_required(get_rating_to, value, :rating_to, Val(:mva))
get_rating_to_unitful(value::TwoTerminalVSCLine) = _units_arg_required(get_rating_to_unitful, value, :rating_to, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating_to), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_rating_to_unitful), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalVSCLine`](@ref) `reactive_power_limits_to` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_limits_to_unitful`](@ref)."""
get_reactive_power_limits_to(value::TwoTerminalVSCLine, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_limits_to), Val(:mvar), units))
"""Get [`TwoTerminalVSCLine`](@ref) `reactive_power_limits_to` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_limits_to`](@ref)."""
get_reactive_power_limits_to_unitful(value::TwoTerminalVSCLine, units) = get_value(value, Val(:reactive_power_limits_to), Val(:mvar), units)
get_reactive_power_limits_to(value::TwoTerminalVSCLine) = _units_arg_required(get_reactive_power_limits_to, value, :reactive_power_limits_to, Val(:mvar))
get_reactive_power_limits_to_unitful(value::TwoTerminalVSCLine) = _units_arg_required(get_reactive_power_limits_to_unitful, value, :reactive_power_limits_to, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_to), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_limits_to_unitful), ::Type{TwoTerminalVSCLine}) = InfrastructureSystems.SU
"""Get [`TwoTerminalVSCLine`](@ref) `power_factor_weighting_fraction_to`."""
get_power_factor_weighting_fraction_to(value::TwoTerminalVSCLine) = value.power_factor_weighting_fraction_to
"""Get [`TwoTerminalVSCLine`](@ref) `voltage_limits_to`."""
get_voltage_limits_to(value::TwoTerminalVSCLine) = value.voltage_limits_to
"""Get [`TwoTerminalVSCLine`](@ref) `dc_voltage_droop_to`."""
get_dc_voltage_droop_to(value::TwoTerminalVSCLine) = value.dc_voltage_droop_to
"""Get [`TwoTerminalVSCLine`](@ref) `rated_dc_voltage`."""
get_rated_dc_voltage(value::TwoTerminalVSCLine) = value.rated_dc_voltage
"""Get [`TwoTerminalVSCLine`](@ref) `remote_bus_control_from`."""
get_remote_bus_control_from(value::TwoTerminalVSCLine) = value.remote_bus_control_from
"""Get [`TwoTerminalVSCLine`](@ref) `remote_bus_control_to`."""
get_remote_bus_control_to(value::TwoTerminalVSCLine) = value.remote_bus_control_to
"""Get [`TwoTerminalVSCLine`](@ref) `rmpct_from`."""
get_rmpct_from(value::TwoTerminalVSCLine) = value.rmpct_from
"""Get [`TwoTerminalVSCLine`](@ref) `rmpct_to`."""
get_rmpct_to(value::TwoTerminalVSCLine) = value.rmpct_to
"""Get [`TwoTerminalVSCLine`](@ref) `services`."""
get_services(value::TwoTerminalVSCLine) = value.services

_get_base_power(value::TwoTerminalVSCLine) = value.base_power
"""Get [`TwoTerminalVSCLine`](@ref) `ext`."""
get_ext(value::TwoTerminalVSCLine) = value.ext
"""Get [`TwoTerminalVSCLine`](@ref) `internal`."""
get_internal(value::TwoTerminalVSCLine) = value.internal

"""Set [`TwoTerminalVSCLine`](@ref) `available`."""
set_available!(value::TwoTerminalVSCLine, val) = value.available = val
"""Set [`TwoTerminalVSCLine`](@ref) `arc`."""
set_arc!(value::TwoTerminalVSCLine, val) = value.arc = val
"""Set [`TwoTerminalVSCLine`](@ref) `active_power_flow`."""
set_active_power_flow!(value::TwoTerminalVSCLine, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mw))
set_active_power_flow!(value::TwoTerminalVSCLine, val::_UntaggedNumber) = _units_tag_required(set_active_power_flow!, value, :active_power_flow, Val(:mw), val)
"""Set [`TwoTerminalVSCLine`](@ref) `rating`."""
set_rating!(value::TwoTerminalVSCLine, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::TwoTerminalVSCLine, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`TwoTerminalVSCLine`](@ref) `active_power_limits_from`."""
set_active_power_limits_from!(value::TwoTerminalVSCLine, val) = value.active_power_limits_from = set_value(value, Val(:active_power_limits_from), val, Val(:mw))
set_active_power_limits_from!(value::TwoTerminalVSCLine, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits_from!, value, :active_power_limits_from, Val(:mw), val)
set_active_power_limits_from!(value::TwoTerminalVSCLine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits_from!, value, :active_power_limits_from, Val(:mw), val)
"""Set [`TwoTerminalVSCLine`](@ref) `active_power_limits_to`."""
set_active_power_limits_to!(value::TwoTerminalVSCLine, val) = value.active_power_limits_to = set_value(value, Val(:active_power_limits_to), val, Val(:mw))
set_active_power_limits_to!(value::TwoTerminalVSCLine, val::_UntaggedNumber) = _units_tag_required(set_active_power_limits_to!, value, :active_power_limits_to, Val(:mw), val)
set_active_power_limits_to!(value::TwoTerminalVSCLine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_active_power_limits_to!, value, :active_power_limits_to, Val(:mw), val)
"""Set [`TwoTerminalVSCLine`](@ref) `g`."""
set_g!(value::TwoTerminalVSCLine, val) = value.g = val
"""Set [`TwoTerminalVSCLine`](@ref) `dc_current`."""
set_dc_current!(value::TwoTerminalVSCLine, val) = value.dc_current = val
"""Set [`TwoTerminalVSCLine`](@ref) `reactive_power_from`."""
set_reactive_power_from!(value::TwoTerminalVSCLine, val) = value.reactive_power_from = set_value(value, Val(:reactive_power_from), val, Val(:mvar))
set_reactive_power_from!(value::TwoTerminalVSCLine, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_from!, value, :reactive_power_from, Val(:mvar), val)
"""Set [`TwoTerminalVSCLine`](@ref) `dc_control_from`."""
set_dc_control_from!(value::TwoTerminalVSCLine, val) = value.dc_control_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `ac_control_from`."""
set_ac_control_from!(value::TwoTerminalVSCLine, val) = value.ac_control_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `dc_setpoint_from`."""
set_dc_setpoint_from!(value::TwoTerminalVSCLine, val) = value.dc_setpoint_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `ac_setpoint_from`."""
set_ac_setpoint_from!(value::TwoTerminalVSCLine, val) = value.ac_setpoint_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `rated_ac_voltage_from`."""
set_rated_ac_voltage_from!(value::TwoTerminalVSCLine, val) = value.rated_ac_voltage_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `converter_loss_from`."""
set_converter_loss_from!(value::TwoTerminalVSCLine, val) = value.converter_loss_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `max_dc_current_from`."""
set_max_dc_current_from!(value::TwoTerminalVSCLine, val) = value.max_dc_current_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `rating_from`."""
set_rating_from!(value::TwoTerminalVSCLine, val) = value.rating_from = set_value(value, Val(:rating_from), val, Val(:mva))
set_rating_from!(value::TwoTerminalVSCLine, val::_UntaggedNumber) = _units_tag_required(set_rating_from!, value, :rating_from, Val(:mva), val)
"""Set [`TwoTerminalVSCLine`](@ref) `reactive_power_limits_from`."""
set_reactive_power_limits_from!(value::TwoTerminalVSCLine, val) = value.reactive_power_limits_from = set_value(value, Val(:reactive_power_limits_from), val, Val(:mvar))
set_reactive_power_limits_from!(value::TwoTerminalVSCLine, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits_from!, value, :reactive_power_limits_from, Val(:mvar), val)
set_reactive_power_limits_from!(value::TwoTerminalVSCLine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits_from!, value, :reactive_power_limits_from, Val(:mvar), val)
"""Set [`TwoTerminalVSCLine`](@ref) `power_factor_weighting_fraction_from`."""
set_power_factor_weighting_fraction_from!(value::TwoTerminalVSCLine, val) = value.power_factor_weighting_fraction_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `voltage_limits_from`."""
set_voltage_limits_from!(value::TwoTerminalVSCLine, val) = value.voltage_limits_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `dc_voltage_droop_from`."""
set_dc_voltage_droop_from!(value::TwoTerminalVSCLine, val) = value.dc_voltage_droop_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `reactive_power_to`."""
set_reactive_power_to!(value::TwoTerminalVSCLine, val) = value.reactive_power_to = set_value(value, Val(:reactive_power_to), val, Val(:mvar))
set_reactive_power_to!(value::TwoTerminalVSCLine, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_to!, value, :reactive_power_to, Val(:mvar), val)
"""Set [`TwoTerminalVSCLine`](@ref) `dc_control_to`."""
set_dc_control_to!(value::TwoTerminalVSCLine, val) = value.dc_control_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `ac_control_to`."""
set_ac_control_to!(value::TwoTerminalVSCLine, val) = value.ac_control_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `dc_setpoint_to`."""
set_dc_setpoint_to!(value::TwoTerminalVSCLine, val) = value.dc_setpoint_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `ac_setpoint_to`."""
set_ac_setpoint_to!(value::TwoTerminalVSCLine, val) = value.ac_setpoint_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `rated_ac_voltage_to`."""
set_rated_ac_voltage_to!(value::TwoTerminalVSCLine, val) = value.rated_ac_voltage_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `converter_loss_to`."""
set_converter_loss_to!(value::TwoTerminalVSCLine, val) = value.converter_loss_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `max_dc_current_to`."""
set_max_dc_current_to!(value::TwoTerminalVSCLine, val) = value.max_dc_current_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `rating_to`."""
set_rating_to!(value::TwoTerminalVSCLine, val) = value.rating_to = set_value(value, Val(:rating_to), val, Val(:mva))
set_rating_to!(value::TwoTerminalVSCLine, val::_UntaggedNumber) = _units_tag_required(set_rating_to!, value, :rating_to, Val(:mva), val)
"""Set [`TwoTerminalVSCLine`](@ref) `reactive_power_limits_to`."""
set_reactive_power_limits_to!(value::TwoTerminalVSCLine, val) = value.reactive_power_limits_to = set_value(value, Val(:reactive_power_limits_to), val, Val(:mvar))
set_reactive_power_limits_to!(value::TwoTerminalVSCLine, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_limits_to!, value, :reactive_power_limits_to, Val(:mvar), val)
set_reactive_power_limits_to!(value::TwoTerminalVSCLine, val::NamedTuple{(:min, :max), <:Tuple{Vararg{_UntaggedNumber}}}) = _units_tag_required(set_reactive_power_limits_to!, value, :reactive_power_limits_to, Val(:mvar), val)
"""Set [`TwoTerminalVSCLine`](@ref) `power_factor_weighting_fraction_to`."""
set_power_factor_weighting_fraction_to!(value::TwoTerminalVSCLine, val) = value.power_factor_weighting_fraction_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `voltage_limits_to`."""
set_voltage_limits_to!(value::TwoTerminalVSCLine, val) = value.voltage_limits_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `dc_voltage_droop_to`."""
set_dc_voltage_droop_to!(value::TwoTerminalVSCLine, val) = value.dc_voltage_droop_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `rated_dc_voltage`."""
set_rated_dc_voltage!(value::TwoTerminalVSCLine, val) = value.rated_dc_voltage = val
"""Set [`TwoTerminalVSCLine`](@ref) `remote_bus_control_from`."""
set_remote_bus_control_from!(value::TwoTerminalVSCLine, val) = value.remote_bus_control_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `remote_bus_control_to`."""
set_remote_bus_control_to!(value::TwoTerminalVSCLine, val) = value.remote_bus_control_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `rmpct_from`."""
set_rmpct_from!(value::TwoTerminalVSCLine, val) = value.rmpct_from = val
"""Set [`TwoTerminalVSCLine`](@ref) `rmpct_to`."""
set_rmpct_to!(value::TwoTerminalVSCLine, val) = value.rmpct_to = val
"""Set [`TwoTerminalVSCLine`](@ref) `services`."""
set_services!(value::TwoTerminalVSCLine, val) = value.services = val
"""Set [`TwoTerminalVSCLine`](@ref) `ext`."""
set_ext!(value::TwoTerminalVSCLine, val) = value.ext = val
