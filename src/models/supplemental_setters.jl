"""
Set a single upstream turbine for a [`HydroReservoir`](@ref).

This is a convenience wrapper around `set_upstream_turbines!` for the single-turbine case.

# Arguments
- `reservoir::HydroReservoir`: The hydro reservoir.
- `turbine::HydroUnit`: The turbine to set as the upstream unit.

See also: [`set_downstream_turbine!`](@ref), [`get_upstream_turbines`](@ref)
"""
function set_upstream_turbine!(reservoir::HydroReservoir, turbine::HydroUnit)
    set_upstream_turbines!(reservoir, [turbine])
    return
end

"""
Set a single downstream turbine for a [`HydroReservoir`](@ref).

This is a convenience wrapper around `set_downstream_turbines!` for the single-turbine case.

# Arguments
- `reservoir::HydroReservoir`: The hydro reservoir.
- `turbine::HydroUnit`: The turbine to set as the downstream unit.

See also: [`set_upstream_turbine!`](@ref), [`get_downstream_turbines`](@ref)
"""
function set_downstream_turbine!(reservoir::HydroReservoir, turbine::HydroUnit)
    set_downstream_turbines!(reservoir, [turbine])
    return
end

function set_head_to_volume_factor!(reservoir::HydroReservoir, val::Float64)
    return set_head_to_volume_factor!(reservoir, LinearCurve(val))
end
