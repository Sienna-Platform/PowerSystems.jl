#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TransformerCircuit <: DeviceParameter
        available::Bool
        arc::Arc
        tap::Float64
        α::Float64
        r::Float64
        x::Float64
        control_objective::TransformerControlObjective
        regulated_bus_number::Int
        control_limits::MinMax
        controlled_quantity_limits::MinMax
        number_of_tap_positions::Int
        rating::Union{Nothing, Float64}
        rating_b::Union{Nothing, Float64}
        rating_c::Union{Nothing, Float64}
        active_power_flow::Float64
        reactive_power_flow::Float64
        base_power::Float64
        base_voltage_primary::Union{Nothing, Float64}
        base_voltage_secondary::Union{Nothing, Float64}
        base_value::Union{Nothing, Float64}
    end

The data defining one modeled arc of a transformer.

A [`TwoWindingTransformer`](@ref) has one circuit; a [`ThreeWindingTransformer`](@ref) has three, each connecting a terminal bus to the star bus. Circuit `available` is the single source of truth for availability; the owning transformer derives its availability from its circuits. `r`/`x` are the circuit impedance (for a two-winding transformer, the series impedance; for a three-winding transformer, the star-leg equivalent), in pu (device base) on `base_power` referenced to `base_voltage_primary`. `rating`/`rating_b`/`rating_c` and the flow fields are stored in device base per unit on `base_power` (MVA). Tap-changer / phase-shifter control is described by the flat control fields: `control_objective = UNDEFINED` means the circuit has no control block. `base_voltage_primary`/`base_voltage_secondary` are the two terminal-side base voltages in kV. For a [`TwoWindingTransformer`](@ref), the single circuit's `base_power` is the transformer's device base.

# Arguments
- `available::Bool`: Indicator of whether this circuit is connected and online. Circuit availability is the single source of truth; the owning transformer derives its availability from its circuits
- `arc::Arc`: An [`Arc`](@ref) defining this circuit `from` a terminal bus `to` the transformer's other terminal or star bus
- `tap::Float64`: (default: `1.0`) Normalized tap changer position for voltage control, varying between 0 and 2, with 1 centered at the nominal voltage
- `α::Float64`: (default: `0.0`) Initial condition of phase shift (radians) across this circuit
- `r::Float64`: (default: `0.0`) Circuit resistance in pu (device base on `base_power`) referenced to `base_voltage_primary`. For a two-winding transformer this is the series impedance; for a three-winding transformer it is the star-leg equivalent, validation range: `(-2, 4)`
- `x::Float64`: (default: `0.0`) Circuit reactance in pu (device base on `base_power`) referenced to `base_voltage_primary`. For a two-winding transformer this is the series impedance; for a three-winding transformer it is the star-leg equivalent, validation range: `(-2, 4)`
- `control_objective::TransformerControlObjective`: (default: `TransformerControlObjective.UNDEFINED`) Tap-changer / phase-shifter control objective. `UNDEFINED` means this circuit has no control block. See [`TransformerControlObjective`](@ref)
- `regulated_bus_number::Int`: (default: `0`) Controlled bus number; the sign indicates the regulation side
- `control_limits::MinMax`: (default: `(min=0.9, max=1.1)`) Control band: tap-ratio bounds for voltage/reactive-power control or phase-angle bounds (rad) for active-power control
- `controlled_quantity_limits::MinMax`: (default: `(min=0.9, max=1.1)`) Controlled-quantity band: pu voltage / MVAr / MW bounds depending on `control_objective`
- `number_of_tap_positions::Int`: (default: `33`) Number of tap positions
- `rating::Union{Nothing, Float64}`: (default: `nothing`) Thermal rating (MVA) stored in device base per unit on `base_power`
- `rating_b::Union{Nothing, Float64}`: (default: `nothing`) Second current rating; entered in MVA.
- `rating_c::Union{Nothing, Float64}`: (default: `nothing`) Third current rating; entered in MVA.
- `active_power_flow::Float64`: (default: `0.0`) Initial condition of active power flow through this circuit (MW)
- `reactive_power_flow::Float64`: (default: `0.0`) Initial condition of reactive power flow through this circuit (MVAR)
- `base_power::Float64`: (default: `100.0`) Base power (MVA) for [per unitization](@ref per_unit) of this circuit
- `base_voltage_primary::Union{Nothing, Float64}`: (default: `nothing`) Primary (from) terminal-side base voltage in kV; the reference voltage for this circuit's per-unit impedance, validation range: `(0, nothing)`
- `base_voltage_secondary::Union{Nothing, Float64}`: (default: `nothing`) Secondary (to) terminal-side base voltage in kV. For a three-winding transformer this defaults to the primary base voltage at parse time, validation range: `(0, nothing)`
- `base_value::Union{Nothing, Float64}`: (**Do not modify.**) System base power (MVA) anchor for explicit-units conversion; populated when the owning transformer is attached to a System
"""
mutable struct TransformerCircuit <: DeviceParameter
    "Indicator of whether this circuit is connected and online. Circuit availability is the single source of truth; the owning transformer derives its availability from its circuits"
    available::Bool
    "An [`Arc`](@ref) defining this circuit `from` a terminal bus `to` the transformer's other terminal or star bus"
    arc::Arc
    "Normalized tap changer position for voltage control, varying between 0 and 2, with 1 centered at the nominal voltage"
    tap::Float64
    "Initial condition of phase shift (radians) across this circuit"
    α::Float64
    "Circuit resistance in pu (device base on `base_power`) referenced to `base_voltage_primary`. For a two-winding transformer this is the series impedance; for a three-winding transformer it is the star-leg equivalent"
    r::Float64
    "Circuit reactance in pu (device base on `base_power`) referenced to `base_voltage_primary`. For a two-winding transformer this is the series impedance; for a three-winding transformer it is the star-leg equivalent"
    x::Float64
    "Tap-changer / phase-shifter control objective. `UNDEFINED` means this circuit has no control block. See [`TransformerControlObjective`](@ref)"
    control_objective::TransformerControlObjective
    "Controlled bus number; the sign indicates the regulation side"
    regulated_bus_number::Int
    "Control band: tap-ratio bounds for voltage/reactive-power control or phase-angle bounds (rad) for active-power control"
    control_limits::MinMax
    "Controlled-quantity band: pu voltage / MVAr / MW bounds depending on `control_objective`"
    controlled_quantity_limits::MinMax
    "Number of tap positions"
    number_of_tap_positions::Int
    "Thermal rating (MVA) stored in device base per unit on `base_power`"
    rating::Union{Nothing, Float64}
    "Second current rating; entered in MVA."
    rating_b::Union{Nothing, Float64}
    "Third current rating; entered in MVA."
    rating_c::Union{Nothing, Float64}
    "Initial condition of active power flow through this circuit (MW)"
    active_power_flow::Float64
    "Initial condition of reactive power flow through this circuit (MVAR)"
    reactive_power_flow::Float64
    "Base power (MVA) for [per unitization](@ref per_unit) of this circuit"
    base_power::Float64
    "Primary (from) terminal-side base voltage in kV; the reference voltage for this circuit's per-unit impedance"
    base_voltage_primary::Union{Nothing, Float64}
    "Secondary (to) terminal-side base voltage in kV. For a three-winding transformer this defaults to the primary base voltage at parse time"
    base_voltage_secondary::Union{Nothing, Float64}
    "(**Do not modify.**) System base power (MVA) anchor for explicit-units conversion; populated when the owning transformer is attached to a System"
    base_value::Union{Nothing, Float64}
end

function TransformerCircuit(available, arc, tap=1.0, α=0.0, r=0.0, x=0.0, control_objective=TransformerControlObjective.UNDEFINED, regulated_bus_number=0, control_limits=(min=0.9, max=1.1), controlled_quantity_limits=(min=0.9, max=1.1), number_of_tap_positions=33, rating=nothing, rating_b=nothing, rating_c=nothing, active_power_flow=0.0, reactive_power_flow=0.0, base_power=100.0, base_voltage_primary=nothing, base_voltage_secondary=nothing, )
    TransformerCircuit(available, arc, tap, α, r, x, control_objective, regulated_bus_number, control_limits, controlled_quantity_limits, number_of_tap_positions, rating, rating_b, rating_c, active_power_flow, reactive_power_flow, base_power, base_voltage_primary, base_voltage_secondary, nothing, )
end

function TransformerCircuit(; available, arc, tap=1.0, α=0.0, r=0.0, x=0.0, control_objective=TransformerControlObjective.UNDEFINED, regulated_bus_number=0, control_limits=(min=0.9, max=1.1), controlled_quantity_limits=(min=0.9, max=1.1), number_of_tap_positions=33, rating=nothing, rating_b=nothing, rating_c=nothing, active_power_flow=0.0, reactive_power_flow=0.0, base_power=100.0, base_voltage_primary=nothing, base_voltage_secondary=nothing, base_value=nothing, )
    TransformerCircuit(available, arc, tap, α, r, x, control_objective, regulated_bus_number, control_limits, controlled_quantity_limits, number_of_tap_positions, rating, rating_b, rating_c, active_power_flow, reactive_power_flow, base_power, base_voltage_primary, base_voltage_secondary, base_value, )
end

# Constructor for demo purposes; non-functional.
function TransformerCircuit(::Nothing)
    TransformerCircuit(;
        available=false,
        arc=Arc(ACBus(nothing), ACBus(nothing)),
        tap=1.0,
        α=0.0,
        r=0.0,
        x=0.0,
        control_objective=TransformerControlObjective.UNDEFINED,
        regulated_bus_number=0,
        control_limits=(min=0.9, max=1.1),
        controlled_quantity_limits=(min=0.9, max=1.1),
        number_of_tap_positions=33,
        rating=nothing,
        rating_b=nothing,
        rating_c=nothing,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        base_power=100.0,
        base_voltage_primary=nothing,
        base_voltage_secondary=nothing,
    )
end

"""Get [`TransformerCircuit`](@ref) `available`."""
get_available(value::TransformerCircuit) = value.available
"""Get [`TransformerCircuit`](@ref) `arc`."""
get_arc(value::TransformerCircuit) = value.arc
"""Get [`TransformerCircuit`](@ref) `tap`."""
get_tap(value::TransformerCircuit) = value.tap
"""Get [`TransformerCircuit`](@ref) `α`."""
get_α(value::TransformerCircuit) = value.α
"""Get [`TransformerCircuit`](@ref) `r` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_r_unitful`](@ref)."""
get_r(value::TransformerCircuit, units) = InfrastructureSystems._strip_units(get_value(value, Val(:r), Val(:ohm), units))
"""Get [`TransformerCircuit`](@ref) `r` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_r`](@ref)."""
get_r_unitful(value::TransformerCircuit, units) = get_value(value, Val(:r), Val(:ohm), units)
get_r(value::TransformerCircuit) = _units_arg_required(get_r, value, :r, Val(:ohm))
get_r_unitful(value::TransformerCircuit) = _units_arg_required(get_r_unitful, value, :r, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_r), ::Type{TransformerCircuit}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_r_unitful), ::Type{TransformerCircuit}) = InfrastructureSystems.SU
"""Get [`TransformerCircuit`](@ref) `x` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_x_unitful`](@ref)."""
get_x(value::TransformerCircuit, units) = InfrastructureSystems._strip_units(get_value(value, Val(:x), Val(:ohm), units))
"""Get [`TransformerCircuit`](@ref) `x` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_x`](@ref)."""
get_x_unitful(value::TransformerCircuit, units) = get_value(value, Val(:x), Val(:ohm), units)
get_x(value::TransformerCircuit) = _units_arg_required(get_x, value, :x, Val(:ohm))
get_x_unitful(value::TransformerCircuit) = _units_arg_required(get_x_unitful, value, :x, Val(:ohm))
InfrastructureSystems.display_units_arg(::typeof(get_x), ::Type{TransformerCircuit}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_x_unitful), ::Type{TransformerCircuit}) = InfrastructureSystems.SU
"""Get [`TransformerCircuit`](@ref) `control_objective`."""
get_control_objective(value::TransformerCircuit) = value.control_objective
"""Get [`TransformerCircuit`](@ref) `regulated_bus_number`."""
get_regulated_bus_number(value::TransformerCircuit) = value.regulated_bus_number
"""Get [`TransformerCircuit`](@ref) `control_limits`."""
get_control_limits(value::TransformerCircuit) = value.control_limits
"""Get [`TransformerCircuit`](@ref) `controlled_quantity_limits`."""
get_controlled_quantity_limits(value::TransformerCircuit) = value.controlled_quantity_limits
"""Get [`TransformerCircuit`](@ref) `number_of_tap_positions`."""
get_number_of_tap_positions(value::TransformerCircuit) = value.number_of_tap_positions
"""Get [`TransformerCircuit`](@ref) `rating` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_unitful`](@ref)."""
get_rating(value::TransformerCircuit, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating), Val(:mva), units))
"""Get [`TransformerCircuit`](@ref) `rating` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating`](@ref)."""
get_rating_unitful(value::TransformerCircuit, units) = get_value(value, Val(:rating), Val(:mva), units)
get_rating(value::TransformerCircuit) = _units_arg_required(get_rating, value, :rating, Val(:mva))
get_rating_unitful(value::TransformerCircuit) = _units_arg_required(get_rating_unitful, value, :rating, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating), ::Type{TransformerCircuit}) = InfrastructureSystems.DU
InfrastructureSystems.display_units_arg(::typeof(get_rating_unitful), ::Type{TransformerCircuit}) = InfrastructureSystems.DU
"""Get [`TransformerCircuit`](@ref) `rating_b` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_b_unitful`](@ref)."""
get_rating_b(value::TransformerCircuit, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating_b), Val(:mva), units))
"""Get [`TransformerCircuit`](@ref) `rating_b` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating_b`](@ref)."""
get_rating_b_unitful(value::TransformerCircuit, units) = get_value(value, Val(:rating_b), Val(:mva), units)
get_rating_b(value::TransformerCircuit) = _units_arg_required(get_rating_b, value, :rating_b, Val(:mva))
get_rating_b_unitful(value::TransformerCircuit) = _units_arg_required(get_rating_b_unitful, value, :rating_b, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating_b), ::Type{TransformerCircuit}) = InfrastructureSystems.DU
InfrastructureSystems.display_units_arg(::typeof(get_rating_b_unitful), ::Type{TransformerCircuit}) = InfrastructureSystems.DU
"""Get [`TransformerCircuit`](@ref) `rating_c` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_rating_c_unitful`](@ref)."""
get_rating_c(value::TransformerCircuit, units) = InfrastructureSystems._strip_units(get_value(value, Val(:rating_c), Val(:mva), units))
"""Get [`TransformerCircuit`](@ref) `rating_c` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_rating_c`](@ref)."""
get_rating_c_unitful(value::TransformerCircuit, units) = get_value(value, Val(:rating_c), Val(:mva), units)
get_rating_c(value::TransformerCircuit) = _units_arg_required(get_rating_c, value, :rating_c, Val(:mva))
get_rating_c_unitful(value::TransformerCircuit) = _units_arg_required(get_rating_c_unitful, value, :rating_c, Val(:mva))
InfrastructureSystems.display_units_arg(::typeof(get_rating_c), ::Type{TransformerCircuit}) = InfrastructureSystems.DU
InfrastructureSystems.display_units_arg(::typeof(get_rating_c_unitful), ::Type{TransformerCircuit}) = InfrastructureSystems.DU
"""Get [`TransformerCircuit`](@ref) `active_power_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_active_power_flow_unitful`](@ref)."""
get_active_power_flow(value::TransformerCircuit, units) = InfrastructureSystems._strip_units(get_value(value, Val(:active_power_flow), Val(:mw), units))
"""Get [`TransformerCircuit`](@ref) `active_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_active_power_flow`](@ref)."""
get_active_power_flow_unitful(value::TransformerCircuit, units) = get_value(value, Val(:active_power_flow), Val(:mw), units)
get_active_power_flow(value::TransformerCircuit) = _units_arg_required(get_active_power_flow, value, :active_power_flow, Val(:mw))
get_active_power_flow_unitful(value::TransformerCircuit) = _units_arg_required(get_active_power_flow_unitful, value, :active_power_flow, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow), ::Type{TransformerCircuit}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_active_power_flow_unitful), ::Type{TransformerCircuit}) = InfrastructureSystems.SU
"""Get [`TransformerCircuit`](@ref) `reactive_power_flow` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_reactive_power_flow_unitful`](@ref)."""
get_reactive_power_flow(value::TransformerCircuit, units) = InfrastructureSystems._strip_units(get_value(value, Val(:reactive_power_flow), Val(:mvar), units))
"""Get [`TransformerCircuit`](@ref) `reactive_power_flow` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_reactive_power_flow`](@ref)."""
get_reactive_power_flow_unitful(value::TransformerCircuit, units) = get_value(value, Val(:reactive_power_flow), Val(:mvar), units)
get_reactive_power_flow(value::TransformerCircuit) = _units_arg_required(get_reactive_power_flow, value, :reactive_power_flow, Val(:mvar))
get_reactive_power_flow_unitful(value::TransformerCircuit) = _units_arg_required(get_reactive_power_flow_unitful, value, :reactive_power_flow, Val(:mvar))
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_flow), ::Type{TransformerCircuit}) = InfrastructureSystems.SU
InfrastructureSystems.display_units_arg(::typeof(get_reactive_power_flow_unitful), ::Type{TransformerCircuit}) = InfrastructureSystems.SU
"""Get [`TransformerCircuit`](@ref) `base_power`."""
get_base_power(value::TransformerCircuit) = value.base_power
"""Get [`TransformerCircuit`](@ref) `base_voltage_primary`."""
get_base_voltage_primary(value::TransformerCircuit) = value.base_voltage_primary
"""Get [`TransformerCircuit`](@ref) `base_voltage_secondary`."""
get_base_voltage_secondary(value::TransformerCircuit) = value.base_voltage_secondary

_get_base_value(value::TransformerCircuit) = value.base_value

"""Set [`TransformerCircuit`](@ref) `available`."""
set_available!(value::TransformerCircuit, val) = value.available = val
"""Set [`TransformerCircuit`](@ref) `arc`."""
set_arc!(value::TransformerCircuit, val) = value.arc = val
"""Set [`TransformerCircuit`](@ref) `tap`."""
set_tap!(value::TransformerCircuit, val) = value.tap = val
"""Set [`TransformerCircuit`](@ref) `α`."""
set_α!(value::TransformerCircuit, val) = value.α = val
"""Set [`TransformerCircuit`](@ref) `r`."""
set_r!(value::TransformerCircuit, val) = value.r = set_value(value, Val(:r), val, Val(:ohm))
set_r!(value::TransformerCircuit, val::_UntaggedNumber) = _units_tag_required(set_r!, value, :r, Val(:ohm), val)
"""Set [`TransformerCircuit`](@ref) `x`."""
set_x!(value::TransformerCircuit, val) = value.x = set_value(value, Val(:x), val, Val(:ohm))
set_x!(value::TransformerCircuit, val::_UntaggedNumber) = _units_tag_required(set_x!, value, :x, Val(:ohm), val)
"""Set [`TransformerCircuit`](@ref) `control_objective`."""
set_control_objective!(value::TransformerCircuit, val) = value.control_objective = val
"""Set [`TransformerCircuit`](@ref) `regulated_bus_number`."""
set_regulated_bus_number!(value::TransformerCircuit, val) = value.regulated_bus_number = val
"""Set [`TransformerCircuit`](@ref) `control_limits`."""
set_control_limits!(value::TransformerCircuit, val) = value.control_limits = val
"""Set [`TransformerCircuit`](@ref) `controlled_quantity_limits`."""
set_controlled_quantity_limits!(value::TransformerCircuit, val) = value.controlled_quantity_limits = val
"""Set [`TransformerCircuit`](@ref) `number_of_tap_positions`."""
set_number_of_tap_positions!(value::TransformerCircuit, val) = value.number_of_tap_positions = val
"""Set [`TransformerCircuit`](@ref) `rating`."""
set_rating!(value::TransformerCircuit, val) = value.rating = set_value(value, Val(:rating), val, Val(:mva))
set_rating!(value::TransformerCircuit, val::_UntaggedNumber) = _units_tag_required(set_rating!, value, :rating, Val(:mva), val)
"""Set [`TransformerCircuit`](@ref) `rating_b`."""
set_rating_b!(value::TransformerCircuit, val) = value.rating_b = set_value(value, Val(:rating_b), val, Val(:mva))
set_rating_b!(value::TransformerCircuit, val::_UntaggedNumber) = _units_tag_required(set_rating_b!, value, :rating_b, Val(:mva), val)
"""Set [`TransformerCircuit`](@ref) `rating_c`."""
set_rating_c!(value::TransformerCircuit, val) = value.rating_c = set_value(value, Val(:rating_c), val, Val(:mva))
set_rating_c!(value::TransformerCircuit, val::_UntaggedNumber) = _units_tag_required(set_rating_c!, value, :rating_c, Val(:mva), val)
"""Set [`TransformerCircuit`](@ref) `active_power_flow`."""
set_active_power_flow!(value::TransformerCircuit, val) = value.active_power_flow = set_value(value, Val(:active_power_flow), val, Val(:mw))
set_active_power_flow!(value::TransformerCircuit, val::_UntaggedNumber) = _units_tag_required(set_active_power_flow!, value, :active_power_flow, Val(:mw), val)
"""Set [`TransformerCircuit`](@ref) `reactive_power_flow`."""
set_reactive_power_flow!(value::TransformerCircuit, val) = value.reactive_power_flow = set_value(value, Val(:reactive_power_flow), val, Val(:mvar))
set_reactive_power_flow!(value::TransformerCircuit, val::_UntaggedNumber) = _units_tag_required(set_reactive_power_flow!, value, :reactive_power_flow, Val(:mvar), val)
"""Set [`TransformerCircuit`](@ref) `base_power`."""
set_base_power!(value::TransformerCircuit, val) = value.base_power = val
"""Set [`TransformerCircuit`](@ref) `base_voltage_primary`."""
set_base_voltage_primary!(value::TransformerCircuit, val) = value.base_voltage_primary = val
"""Set [`TransformerCircuit`](@ref) `base_voltage_secondary`."""
set_base_voltage_secondary!(value::TransformerCircuit, val) = value.base_voltage_secondary = val
