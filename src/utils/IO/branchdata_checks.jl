
function sanitize_component!(line::Union{MonitoredLine, Line}, sys::System)
    sanitize_angle_limits!(line)
    return
end

function validate_component_with_system(line::Union{MonitoredLine, Line}, sys::System)
    is_valid = true
    if !check_endpoint_voltages(line)
        is_valid = false
    elseif !correct_rate_limits!(line)
        is_valid = false
    end
    return is_valid
end

function sanitize_angle_limits!(line::Union{Line, MonitoredLine})
    max_limit = pi / 2
    min_limit = -pi / 2

    orderedlimits(line.angle_limits, "Angles")

    if (line.angle_limits.max / max_limit > 3) ||
       (-1 * line.angle_limits.min / max_limit > 3)
        @warn "The angle limits provided is larger than 3π/2 radians.\n " *
              "PowerSystems inferred the data provided in degrees and will transform it to radians" _group =
            IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG

        if line.angle_limits.max / max_limit >= 0.99
            line.angle_limits = (
                min = line.angle_limits.min,
                max = min(line.angle_limits.max * (π / 180), max_limit),
            )
        else
            line.angle_limits =
                (min = line.angle_limits.min, max = min(line.angle_limits.max, max_limit))
        end

        if (-1 * line.angle_limits.min / max_limit > 0.99)
            line.angle_limits = (
                min = max(line.angle_limits.min * (π / 180), min_limit),
                max = line.angle_limits.max,
            )
        else
            line.angle_limits =
                (min = max(line.angle_limits.min, min_limit), max = line.angle_limits.max)
        end
    else
        if line.angle_limits.max >= max_limit && line.angle_limits.min <= min_limit
            line.angle_limits = (min = min_limit, max = max_limit)
        elseif line.angle_limits.max >= max_limit && line.angle_limits.min >= min_limit
            line.angle_limits = (min = line.angle_limits.min, max = max_limit)
        elseif line.angle_limits.max <= max_limit && line.angle_limits.min <= min_limit
            line.angle_limits = (min = min_limit, max = line.angle_limits.max)
        elseif line.angle_limits.max == 0.0 && line.angle_limits.min == 0.0
            line.angle_limits = (min = min_limit, max = max_limit)
        end
    end
    return
end

# Building Synthetic Power Transmission Networks of Many Voltage Levels, Spanning Multiple Areas
# https://scholarspace.manoa.hawaii.edu/server/api/core/bitstreams/47b28d1e-7019-415f-9a88-e1ed37556342/content
# https://www.mdpi.com/1996-1073/10/8/1233/htm
const MVA_LIMITS_LINES = Dict(
    69.0 => (min = 12.0, max = 115.0),
    115.0 => (min = 92.0, max = 255.0),
    138.0 => (min = 141.0, max = 344.0),
    161.0 => (min = 176.0, max = 410.0),
    230.0 => (min = 327.0, max = 797.0),
    345.0 => (min = 897.0, max = 1494.0),
    500.0 => (min = 1732.0, max = 3464.0))

# Building Synthetic Power Transmission Networks of Many Voltage Levels, Spanning Multiple Areas
# https://scholarspace.manoa.hawaii.edu/server/api/core/bitstreams/47b28d1e-7019-415f-9a88-e1ed37556342/content
# https://www.mdpi.com/1996-1073/10/8/1233/htm
const MVA_LIMITS_TRANSFORMERS = Dict(
    69.0 => (min = 7.0, max = 115.0),
    115.0 => (min = 17.0, max = 140.0),
    138.0 => (min = 15.0, max = 239.0),
    161.0 => (min = 30.0, max = 276.0),
    230.0 => (min = 50.0, max = 470.0),
    345.0 => (min = 160.0, max = 702.0),
    500.0 => (min = 150.0, max = 1383.0),
    765.0 => (min = 2200.0, max = 6900.0), # This value is 3x the SIL value from https://neos-guide.org/wp-content/uploads/2022/04/line_flow_approximation.pdf
)

function check_rating_values(line::Union{Line, MonitoredLine})
    arc = get_arc(line)
    vrated = get_base_voltage(get_to(arc))
    voltage_levels = collect(keys(MVA_LIMITS_LINES))
    closestV_ix = findmin(abs.(voltage_levels .- vrated))
    closest_v_level = voltage_levels[closestV_ix[2]]
    closest_rate_range = MVA_LIMITS_LINES[closest_v_level]
    component_base_power = _get_base_power(line)

    for field in (:rating, :rating_b, :rating_c)
        rating_value = getfield(line, field)
        if isnothing(rating_value)
            @assert field ∈ (:rating_b, :rating_c)
            continue
        end
        rating_mva = rating_value * component_base_power
        if rating_mva >= 2.0 * closest_rate_range.max
            @warn "$(field) $(round(rating_mva; digits=2)) MVA for $(get_name(line)) is 2x larger than the max expected rating $(closest_rate_range.max) MVA for Line at a $(closest_v_level) kV Voltage level." _group =
                IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
        elseif rating_mva >= closest_rate_range.max || rating_mva <= closest_rate_range.min
            @info "$(field) $(round(rating_mva; digits=2)) MVA for $(get_name(line)) is outside the expected range $(closest_rate_range) MVA for Line at a $(closest_v_level) kV Voltage level." _group =
                IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
        end
    end

    return true
end

"""
Calculates the line rating based on the formula for the maximum transfer limit over an impedance
"""
function line_rating_calculation(l::Union{Line, MonitoredLine})
    theta_max = max(abs(l.angle_limits.min), abs(l.angle_limits.max))

    g = l.r / (l.r^2 + l.x^2)
    b = -l.x / (l.r^2 + l.x^2)
    y_mag = sqrt(g^2 + b^2)

    from_voltage_limits = get_voltage_limits(get_arc(l).from)
    to_voltage_limits = get_voltage_limits(get_arc(l).to)

    fr_vmin = isnothing(from_voltage_limits) ? 0.9 : from_voltage_limits.min
    to_vmin = isnothing(to_voltage_limits) ? 0.9 : to_voltage_limits.min

    c_max = sqrt(fr_vmin^2 + to_vmin^2 - 2 * fr_vmin * to_vmin * cos(theta_max))
    new_rate = y_mag * max(fr_vmin, to_vmin) * c_max

    return new_rate
end

function correct_rate_limits!(branch::Union{Line, MonitoredLine})
    theoretical_line_rate_pu = line_rating_calculation(branch)
    for field in [:rating, :rating_b, :rating_c]
        rating_value = getfield(branch, field)
        if isnothing(rating_value)
            @assert field ∈ [:rating_b, :rating_c]
            continue
        end
        if rating_value < 0.0
            @error "PowerSystems does not support negative line rates for \
                    $(summary(branch)) $(field): $(rating_value)." _group =
                IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
            return false
        end
        if rating_value == INFINITE_BOUND
            @warn "Data for branch $(summary(branch)) $(field) is set to INFINITE_BOUND. \
                PowerSystems will set a rate from line parameters to $(theoretical_line_rate_pu)" _group =
                IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
            setfield!(branch, field, theoretical_line_rate_pu)
        end
    end

    return check_rating_values(branch)
end

function check_endpoint_voltages(line::Union{Line, MonitoredLine})
    is_valid = true
    arc = get_arc(line)
    from_voltage = get_base_voltage(get_from(arc))
    to_voltage = get_base_voltage(get_to(arc))
    percent_difference = abs(from_voltage - to_voltage) / ((from_voltage + to_voltage) / 2)
    if percent_difference > BRANCH_BUS_VOLTAGE_DIFFERENCE_TOL
        is_valid = false
        @error "Voltage endpoints of $(get_name(line)) have more than $(BRANCH_BUS_VOLTAGE_DIFFERENCE_TOL*100)% difference, cannot create Line. /
        Check if the data corresponds to transformer data."
    end

    return is_valid
end

const TYPICAL_XFRM_REACTANCE = (min = 0.05, max = 0.2) # per-unit

# `valid_range`s for `tap`/`α`/`base_voltage`. These fields live on
# `TransformerCircuit`, which is not a `Component` added to the system's `Components`
# container, so IS's generic `validate_fields` (which only recurses into
# `Union{Nothing, InfrastructureSystemsType}`-typed fields, not sub-structs stored
# directly) never reaches them. They are validated here, on the
# `validate_component_with_system` path for the owning transformer(s).
const CIRCUIT_TAP_LIMITS = (min = 0.0, max = 2.0)
const CIRCUIT_ANGLE_LIMITS = (min = -1.571, max = 1.571)

function check_circuit_values(circuit::TransformerCircuit, xfrm_name::AbstractString)
    is_valid = true

    tap = get_tap(circuit)
    if tap < CIRCUIT_TAP_LIMITS.min || tap > CIRCUIT_TAP_LIMITS.max
        @error "Circuit tap $(tap) for transformer $(xfrm_name) is outside the valid range $(CIRCUIT_TAP_LIMITS)." _group =
            IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
        is_valid = false
    end

    α = get_α(circuit)
    if α < CIRCUIT_ANGLE_LIMITS.min || α > CIRCUIT_ANGLE_LIMITS.max
        @warn "Circuit phase shift α $(α) (radians) for transformer $(xfrm_name) is outside the typical range $(CIRCUIT_ANGLE_LIMITS)." _group =
            IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
    end

    for (field, base_voltage) in (
        (:base_voltage_primary, get_base_voltage_primary(circuit)),
        (:base_voltage_secondary, get_base_voltage_secondary(circuit)),
    )
        if base_voltage !== nothing && base_voltage <= 0
            @error "Circuit $(field) $(base_voltage) for transformer $(xfrm_name) must be positive." _group =
                IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
            is_valid = false
        end
    end

    control_limits = get_control_limits(circuit)
    if control_limits.min > control_limits.max
        @error "Circuit control_limits.min $(control_limits.min) exceeds max $(control_limits.max) for transformer $(xfrm_name)." _group =
            IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
        is_valid = false
    end

    controlled_quantity_limits = get_controlled_quantity_limits(circuit)
    if controlled_quantity_limits.min > controlled_quantity_limits.max
        @error "Circuit controlled_quantity_limits.min $(controlled_quantity_limits.min) exceeds max $(controlled_quantity_limits.max) for transformer $(xfrm_name)." _group =
            IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
        is_valid = false
    end

    if get_number_of_tap_positions(circuit) < 0
        @error "Circuit number_of_tap_positions $(get_number_of_tap_positions(circuit)) for transformer $(xfrm_name) must be non-negative." _group =
            IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
        is_valid = false
    end

    return is_valid
end

function validate_component_with_system(
    xfrm::TwoWindingTransformer,
    sys::System,
)
    is_valid_reactance = check_transformer_reactance(xfrm)
    is_valid_rating = check_rating_values(xfrm)
    is_valid_circuit = check_circuit_values(get_circuit(xfrm), get_name(xfrm))
    return is_valid_reactance && is_valid_rating && is_valid_circuit
end

const _PAIRWISE_IMPEDANCE_FIELDS = (
    :r_12, :x_12, :r_23, :x_23, :r_31, :x_31,
    :base_power_12, :base_power_23, :base_power_31,
)

# The pairwise block is carried verbatim from source data or absent entirely; a partial block
# has no defined conversion (impedances without their base) and is always a data error.
function check_pairwise_impedance_block(xfrm::ThreeWindingTransformer)
    missing_fields = [f for f in _PAIRWISE_IMPEDANCE_FIELDS if isnothing(getfield(xfrm, f))]
    isempty(missing_fields) && return true
    length(missing_fields) == length(_PAIRWISE_IMPEDANCE_FIELDS) && return true
    @error "ThreeWindingTransformer $(get_name(xfrm)) has a partial pairwise impedance " *
           "block; missing $(missing_fields). Set all of " *
           "$(collect(_PAIRWISE_IMPEDANCE_FIELDS)) or none." _group =
        IS.LOG_GROUP_PARSING
    return false
end

function validate_component_with_system(
    xfrm::ThreeWindingTransformer,
    sys::System,
)
    is_valid = check_pairwise_impedance_block(xfrm)
    for circuit in get_circuits(xfrm)
        if !check_circuit_values(circuit, get_name(xfrm))
            is_valid = false
        end
    end
    return is_valid
end

function check_rating_values(xfrm::TwoWindingTransformer)
    arc = get_arc(xfrm)
    v_from = get_base_voltage(get_from(arc))
    v_to = get_base_voltage(get_to(arc))
    vrated = maximum([v_from, v_to])
    voltage_levels = collect(keys(MVA_LIMITS_TRANSFORMERS))
    closestV_ix = findmin(abs.(voltage_levels .- vrated))
    closest_v_level = voltage_levels[closestV_ix[2]]
    closest_rate_range = MVA_LIMITS_TRANSFORMERS[closest_v_level]
    component_base_power = _get_base_power(xfrm)
    # The rate is in device pu; rating fields are stored on the circuit.
    circuit = get_circuit(xfrm)
    for field in [:rating, :rating_b, :rating_c]
        rating_value = getfield(circuit, field)
        if isnothing(rating_value)
            @assert field ∈ [:rating_b, :rating_c]
            continue
        end
        if rating_value < 0.0
            @error "PowerSystems does not support negative transformer rates for \
                    $(summary(xfrm)) $(field): $(rating_value)." _group =
                IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
            return false
        end
        if (rating_value * component_base_power >= 2.0 * closest_rate_range.max)
            @warn "$(field) $(round(rating_value*component_base_power; digits=2)) MVA for $(get_name(xfrm)) is 2x larger than the max expected rating $(closest_rate_range.max) MVA for Transformer at a $(closest_v_level) kV Voltage level." _group =
                IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
        elseif (rating_value * component_base_power >= closest_rate_range.max) ||
               (rating_value * component_base_power <= closest_rate_range.min)
            @info "$(field) $(round(rating_value*component_base_power; digits=2)) MVA for $(get_name(xfrm)) is outside the expected range $(closest_rate_range) MVA for Transformer at a $(closest_v_level) kV Voltage level." _group =
                IS.LOG_GROUP_PARSING maxlog = PS_MAX_LOG
        end
    end
    return true
end

function check_transformer_reactance(
    xfrm::TwoWindingTransformer,
)
    x_pu = get_x(get_circuit(xfrm), CU)
    if x_pu < TYPICAL_XFRM_REACTANCE.min
        @warn "Transformer $(get_name(xfrm)) per-unit reactance $(x_pu) is lower than the typical range $(TYPICAL_XFRM_REACTANCE). \
            Check if the reactance source data is correct." _group = IS.LOG_GROUP_PARSING maxlog =
            PS_MAX_LOG
    end
    if x_pu > TYPICAL_XFRM_REACTANCE.max
        @warn "Transformer $(get_name(xfrm)) per-unit reactance $(x_pu) is higher than the typical range $(TYPICAL_XFRM_REACTANCE). \
            Check if the reactance source data is correct." _group = IS.LOG_GROUP_PARSING maxlog =
            PS_MAX_LOG
    end
    return true
end
