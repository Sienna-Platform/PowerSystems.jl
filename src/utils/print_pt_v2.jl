function _make_backend_entry(backend::Val{T}) where {T}
    return backend
end

function _make_backend_entry(backend::Symbol)
    return Val(backend)
end

function _handle_kwargs(kwargs...)
    kwargs = Dict{Symbol, Any}(kwargs...)
    if haskey(kwargs, :stand_alone)
        kwargs[:standalone] = kwargs[:stand_alone]
        delete!(kwargs, :stand_alone)
    end
    backend_entry = pop!(kwargs, :backend, Val(:auto))
    kwargs[:backend] = _make_backend_entry(backend_entry)
    return kwargs
end

function show_system_table(io::IO, sys::System; kwargs...)
    header = ["Property", "Value"]
    num_components = get_num_components(sys)
    table = [
        "Name" isnothing(get_name(sys)) ? "" : get_name(sys)
        "Description" isnothing(get_description(sys)) ? "" : get_description(sys)
        "System Units Base" string(get_units_base(sys))
        "Base Power" string(_get_base_power(sys))
        "Base Frequency" string(get_frequency(sys))
        "Num Components" string(num_components)
    ]
    PrettyTables.pretty_table(
        io,
        table;
        header = header,
        title = "System",
        alignment = :l,
        _handle_kwargs(kwargs)...,
    )
    return
end

function show_components_table(io::IO, sys::System; kwargs...)
    header = ["Type", "Count"]
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
    static_data = Array{Any, 2}(undef, length(static_types), length(header))
    dynamic_data = Array{Any, 2}(undef, length(dynamic_types), length(header))

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
            header = header,
            title = "Static Components",
            alignment = :l,
            _handle_kwargs(kwargs)...,
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
            header = header,
            title = "Dynamic Components",
            alignment = :l,
            _handle_kwargs(kwargs)...,
        )
    end
end

function Base.show(io::IO, ::MIME"text/html", sys::System)
    show_system_table(io, sys; backend = :html, stand_alone = false)

    if get_num_components(sys) > 0
        show_components_table(
            io,
            sys;
            backend = Val(:html),
            tf = PrettyTables.tf_html_simple,
            standalone = false,
        )
    end

    println(io)
    IS.show_time_series_data(
        io,
        sys.data;
        backend = Val(:html),
        tf = PrettyTables.tf_html_simple,
        standalone = false,
    )
    return
end
