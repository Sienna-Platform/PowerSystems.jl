"""
Set a single upstream turbine for a [`HydroReservoir`](@ref).
"""
function set_upstream_turbine!(reservoir::HydroReservoir, turbine::HydroUnit)
    set_upstream_turbines!(reservoir, [turbine])
    return
end

"""
Set a single downstream turbine for a [`HydroReservoir`](@ref).
"""
function set_downstream_turbine!(reservoir::HydroReservoir, turbine::HydroUnit)
    set_downstream_turbines!(reservoir, [turbine])
    return
end

function set_head_to_volume_factor!(reservoir::HydroReservoir, val::Float64)
    return set_head_to_volume_factor!(reservoir, LinearCurve(val))
end
