# The predefined table format recipes for HTML output got removed in PT v3.
# This is the CSS recipe copie from PT v2 for simple HTML tables.
const tf_html_simple = PrettyTables.HtmlTableFormat(;
    css = """
    table, td, th {
        border-collapse: collapse;
        font-family: sans-serif;
    }

    td, th {
        border-bottom: 0;
        padding: 4px
    }

    tr:nth-child(odd) {
        background: #eee;
    }

    tr:nth-child(even) {
        background: #fff;
    }

    tr.header {
        background: #fff !important;
        font-weight: bold;
    }

    tr.subheader {
        background: #fff !important;
        color: dimgray;
    }

    tr.headerLastRow {
        border-bottom: 2px solid black;
    }

    th.rowNumber, td.rowNumber {
        text-align: right;
    }
    """,
)

function show_system_table(io::IO, sys::System; kwargs...)
    column_labels = ["Property", "Value"]
    num_components = get_num_components(sys)
    table = [
        "Name" isnothing(get_name(sys)) ? "" : get_name(sys)
        "Description" isnothing(get_description(sys)) ? "" : get_description(sys)
        "System Units Base" string(get_units_base(sys))
        "Base Power" string(get_base_power(sys))
        "Base Frequency" string(get_frequency(sys))
        "Num Components" string(num_components)
    ]
    PrettyTables.pretty_table(
        io,
        table;
        column_labels = column_labels,
        title = "System",
        alignment = :l,
        kwargs...,
    )
    return
end

function show_components_table(io::IO, sys::System; kwargs...)
    column_labels = ["Type", "Count"]
    components = sys.data.components

    static_types = Vector{DataType}()
    dynamic_types = Vector{DataType}()
    for component_type in keys(components.data)
        if component_type <: DynamicInjection
            push!(dynamic_types, component_type)
        else
            push!(static_types, component_type)
        end
    end
    static_data = Array{Any, 2}(undef, length(static_types), length(column_labels))
    dynamic_data = Array{Any, 2}(undef, length(dynamic_types), length(column_labels))

    static_type_names = [(IS.strip_module_name(x), x) for x in static_types]
    sort!(static_type_names; by = x -> x[1])
    for (i, (type_name, type)) in enumerate(static_type_names)
        vals = components.data[type]
        static_data[i, 1] = type_name
        static_data[i, 2] = length(vals)
    end

    if !isempty(static_types)
        println(io)
        PrettyTables.pretty_table(
            io,
            static_data;
            column_labels = column_labels,
            title = "Static Components",
            alignment = :l,
            kwargs...,
        )
    end

    dynamic_type_names = [(IS.strip_module_name(x), x) for x in dynamic_types]
    sort!(dynamic_type_names; by = x -> x[1])
    for (i, (type_name, type)) in enumerate(dynamic_type_names)
        vals = components.data[type]
        dynamic_data[i, 1] = type_name
        dynamic_data[i, 2] = length(vals)
    end

    if !isempty(dynamic_types)
        println(io)
        PrettyTables.pretty_table(
            io,
            dynamic_data;
            column_labels = column_labels,
            title = "Dynamic Components",
            alignment = :l,
            kwargs...,
        )
    end
end

function Base.show(io::IO, ::MIME"text/html", sys::System)
    show_system_table(io, sys; backend = :html, stand_alone = false)

    if get_num_components(sys) > 0
        show_components_table(
            io,
            sys;
            backend = :html,
            table_format = tf_html_simple,
            stand_alone = false,
        )
    end

    println(io)
    IS.show_time_series_data(
        io,
        sys.data;
        backend = :html,
        table_format = tf_html_simple,
        stand_alone = false,
    )
    return
end
