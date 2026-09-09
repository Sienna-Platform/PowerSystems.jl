# BEGIN 4.0.0  deprecations
export TwoTerminalHVDCLine

# These shims predate `loss` being a `LossCurve`, and their whole purpose is to accept the
# old spellings, so a bare `ValueCurve` is still taken here and wrapped on the natural-units
# basis -- the basis the old field's MW-denominated docstring always described.
_deprecated_hvdc_loss(loss::AnyLossCurve) = loss
_deprecated_hvdc_loss(curve::ValueCurve) = LossCurve(curve, NaturalUnit())

"""
Deprecated method for the old TwoTerminalHVDCLine that returns the new TwoTerminalGenericHVDCLine.
This constructor is used for some backward compatibility and will be removed in a future version.
"""
function TwoTerminalHVDCLine(
    name,
    available,
    active_power_flow,
    arc,
    active_power_limits_from,
    active_power_limits_to,
    reactive_power_limits_from,
    reactive_power_limits_to,
    loss::NamedTuple{(:l0, :l1), Tuple{Float64, Float64}},
    services,
    ext,
    internal,
)
    new_loss = LossCurve(LinearCurve(loss.l0, loss.l1), NaturalUnit())
    @warn(
        "The TwoTerminalHVDCLine constructor is deprecated. Use TwoTerminalGenericHVDCLine instead. \
         This constructor will be removed in a future version.",)
    TwoTerminalGenericHVDCLine(;
        name = name,
        available = available,
        active_power_flow = active_power_flow,
        arc = arc,
        active_power_limits_from = active_power_limits_from,
        active_power_limits_to = active_power_limits_to,
        reactive_power_limits_from = reactive_power_limits_from,
        reactive_power_limits_to = reactive_power_limits_to,
        loss = new_loss,
        services = services,
        ext = ext,
        internal = internal,
    )
end

"""
Deprecated method for the old TwoTerminalHVDCLine that returns the new [`TwoTerminalGenericHVDCLine`](@ref).
This constructor is used for some backward compatibility and will be removed in a future version.
"""
function TwoTerminalHVDCLine(
    name,
    available,
    active_power_flow,
    arc,
    active_power_limits_from,
    active_power_limits_to,
    reactive_power_limits_from,
    reactive_power_limits_to,
    loss::NamedTuple{(:l0, :l1), Tuple{Float64, Float64}},
    services = Device[],
    ext = Dict{String, Any}(),
)
    @warn(
        "The TwoTerminalHVDCLine constructor is deprecated. Use TwoTerminalGenericHVDCLine instead. \
         This constructor will be removed in a future version.",)
    new_loss = LossCurve(LinearCurve(loss.l0, loss.l1), NaturalUnit())
    TwoTerminalGenericHVDCLine(;
        name = name,
        available = available,
        active_power_flow = active_power_flow,
        arc = arc,
        active_power_limits_from = active_power_limits_from,
        active_power_limits_to = active_power_limits_to,
        reactive_power_limits_from = reactive_power_limits_from,
        reactive_power_limits_to = reactive_power_limits_to,
        loss = new_loss,
        services = services,
        ext = ext,
        internal = InfrastructureSystemsInternal(),
    )
end

"""
Deprecated method for the old TwoTerminalHVDCLine that returns the new [`TwoTerminalGenericHVDCLine`](@ref).
This constructor is used for some backward compatibility and will be removed in a future version.
"""
function TwoTerminalHVDCLine(
    name,
    available,
    active_power_flow,
    arc,
    active_power_limits_from,
    active_power_limits_to,
    reactive_power_limits_from,
    reactive_power_limits_to,
    loss::Union{LinearCurve, PiecewiseIncrementalCurve},
    services = Device[],
    ext = Dict{String, Any}(),
)
    @warn(
        "The TwoTerminalHVDCLine constructor is deprecated. Use TwoTerminalGenericHVDCLine instead. \
         This constructor will be removed in a future version.",)
    return TwoTerminalGenericHVDCLine(;
        name = name,
        available = available,
        active_power_flow = active_power_flow,
        arc = arc,
        active_power_limits_from = active_power_limits_from,
        active_power_limits_to = active_power_limits_to,
        reactive_power_limits_from = reactive_power_limits_from,
        reactive_power_limits_to = reactive_power_limits_to,
        loss = _deprecated_hvdc_loss(loss),
        services = services,
        ext = ext,
        internal = InfrastructureSystemsInternal(),
    )
end

"""
Deprecated method for the old TwoTerminalHVDCLine that returns the new [`TwoTerminalGenericHVDCLine`](@ref).
This constructor is used for some backward compatibility and will be removed in a future version.
"""
function TwoTerminalHVDCLine(
    name,
    available,
    active_power_flow,
    arc,
    active_power_limits_from,
    active_power_limits_to,
    reactive_power_limits_from,
    reactive_power_limits_to,
    loss = LinearCurve(0.0),
    services = Device[],
    ext = Dict{String, Any}(),
)
    @warn(
        "The TwoTerminalHVDCLine constructor is deprecated. Use TwoTerminalGenericHVDCLine instead. \
         This constructor will be removed in a future version.",)
    TwoTerminalGenericHVDCLine(;
        name = name,
        available = available,
        active_power_flow = active_power_flow,
        arc = arc,
        active_power_limits_from = active_power_limits_from,
        active_power_limits_to = active_power_limits_to,
        reactive_power_limits_from = reactive_power_limits_from,
        reactive_power_limits_to = reactive_power_limits_to,
        loss = _deprecated_hvdc_loss(loss),
        services = services,
        ext = ext,
        internal = InfrastructureSystemsInternal(),
    )
end

"""
Deprecated method for the old TwoTerminalHVDCLine that returns the new [`TwoTerminalGenericHVDCLine`](@ref).
This constructor is used for some backward compatibility and will be removed in a future version.
"""
function TwoTerminalHVDCLine(;
    name,
    available,
    active_power_flow,
    arc,
    active_power_limits_from,
    active_power_limits_to,
    reactive_power_limits_from,
    reactive_power_limits_to,
    loss = LinearCurve(0.0),
    services = Device[],
    ext = Dict{String, Any}(),
    internal = InfrastructureSystemsInternal(),
)
    @warn(
        "The TwoTerminalHVDCLine constructor is deprecated. Use TwoTerminalGenericHVDCLine instead. \
         This constructor will be removed in a future version.",)
    TwoTerminalGenericHVDCLine(;
        name = name,
        available = available,
        active_power_flow = active_power_flow,
        arc = arc,
        active_power_limits_from = active_power_limits_from,
        active_power_limits_to = active_power_limits_to,
        reactive_power_limits_from = reactive_power_limits_from,
        reactive_power_limits_to = reactive_power_limits_to,
        loss = _deprecated_hvdc_loss(loss),
        services = services,
        ext = ext,
        internal = internal,
    )
end

# BEGIN 5.x deprecations: TwoTerminalVSCLine Bool control accessors -> control-mode enums
#
# PSY <= 5.11 modeled VSC converter control with four `Bool` fields
# (`dc_voltage_control_*`, `ac_voltage_control_*`). They were replaced by the richer
# `dc_control_*::VSCDCControlModes` / `ac_control_*::VSCACControlModes` enums (the latter
# adds the `DC_VOLTAGE_DROOP` mode). The accessor shims below map the pre-5.x `Bool`
# getters onto the enums; a `Bool` only distinguishes the two voltage-control values and
# cannot express `DC_VOLTAGE_DROOP`. The pre-5.x keyword constructor cannot be shimmed:
# Julia forbids overwriting the generated keyword constructor during precompilation, so
# callers must move to the `*_control_*` enum keywords.

"""
Deprecated. Use [`get_dc_control_from`](@ref); returns `true` when the `from` converter
regulates DC voltage (`VSCDCControlModes.DC_VOLTAGE`).
"""
function get_dc_voltage_control_from(value::TwoTerminalVSCLine)
    @warn "`get_dc_voltage_control_from` deprecated; use `get_dc_control_from`." maxlog = 1
    return get_dc_control_from(value) == VSCDCControlModes.DC_VOLTAGE
end

"""
Deprecated. Use [`get_dc_control_to`](@ref); returns `true` when the `to` converter
regulates DC voltage (`VSCDCControlModes.DC_VOLTAGE`).
"""
function get_dc_voltage_control_to(value::TwoTerminalVSCLine)
    @warn "`get_dc_voltage_control_to` deprecated; use `get_dc_control_to`." maxlog = 1
    return get_dc_control_to(value) == VSCDCControlModes.DC_VOLTAGE
end

"""
Deprecated. Use [`get_ac_control_from`](@ref); returns `true` when the `from` converter
regulates AC voltage (`VSCACControlModes.AC_VOLTAGE`).
"""
function get_ac_voltage_control_from(value::TwoTerminalVSCLine)
    @warn "`get_ac_voltage_control_from` deprecated; use `get_ac_control_from`." maxlog = 1
    return get_ac_control_from(value) == VSCACControlModes.AC_VOLTAGE
end

"""
Deprecated. Use [`get_ac_control_to`](@ref); returns `true` when the `to` converter
regulates AC voltage (`VSCACControlModes.AC_VOLTAGE`).
"""
function get_ac_voltage_control_to(value::TwoTerminalVSCLine)
    @warn "`get_ac_voltage_control_to` deprecated; use `get_ac_control_to`." maxlog = 1
    return get_ac_control_to(value) == VSCACControlModes.AC_VOLTAGE
end
