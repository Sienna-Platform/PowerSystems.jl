#########################################################################
#                                                                       #
# This file provides functions for interfacing with Matlab .m files     #
#                                                                       #
#########################################################################

# this could benefit from a much more robust parser

export parse_matlab_file, parse_matlab_string

"""
Parse a MATLAB `.m` file into a `Dict`.
"""
function parse_matlab_file(file_string::String; kwargs...)
    data_string = read(open(file_string), String)
    return parse_matlab_string(data_string; kwargs...)
end

"""
Parse a MATLAB data string into a `Dict`, extracting function definitions and matrix
assignments.
"""
function parse_matlab_string(data_string::String; extended = false)
    data_lines = split(data_string, '\n')

    matlab_dict = Dict{String, Any}()
    struct_name = nothing
    function_name = nothing
    column_names = Dict{String, Any}()

    last_index = length(data_lines)
    index = 1
    while index <= last_index
        line = strip(data_lines[index])
        line = "$(line)"

        if length(line) <= 0 || strip(line)[1] == '%'
            index = index + 1
            continue
        end

        if occursin("function", line)
            func, value = _extract_matlab_assignment(line)
            struct_name = strip(replace(func, "function" => ""))
            function_name = value
        elseif occursin("=", line)
            if struct_name !== nothing && !occursin("$(struct_name).", line)
                @warn "assignments are expected to be made to \"$(struct_name)\" but given: $(line)"
            end

            if occursin("[", line)
                matrix_dict = _parse_matlab_matrix(data_lines, index)
                matlab_dict[matrix_dict["name"]] = matrix_dict["data"]
                if haskey(matrix_dict, "column_names")
                    column_names[matrix_dict["name"]] = matrix_dict["column_names"]
                end
                index = index + matrix_dict["line_count"] - 1
            elseif occursin("{", line)
                cell_dict = _parse_matlab_cells(data_lines, index)
                matlab_dict[cell_dict["name"]] = cell_dict["data"]
                if haskey(cell_dict, "column_names")
                    column_names[cell_dict["name"]] = cell_dict["column_names"]
                end
                index = index + cell_dict["line_count"] - 1
            else
                name, value = _extract_matlab_assignment(line)
                value = _type_value(value)
                matlab_dict[name] = value
            end
        else
            @error "Matlab parser skipping line number $(index) consisting of:\n  $(line)"
        end

        index += 1
    end

    if extended
        return matlab_dict, function_name, column_names
    else
        return matlab_dict
    end
end

"breaks up matlab strings of the form 'name = value;'"
function _extract_matlab_assignment(string::AbstractString)
    statement = split(string, ';')[1]
    statement_parts = split(statement, '=')
    @assert(length(statement_parts) == 2)
    name = strip(statement_parts[1])
    value = strip(statement_parts[2])
    return name, value
end

"Attempts to determine the type of a string extracted from a matlab file"
function _type_value(value_string::AbstractString)
    value_string = strip(value_string)

    if occursin("'", value_string) # value is a string
        value = strip(value_string, '\'')
    else
        # if value is a float
        if occursin(".", value_string) || occursin("e", value_string)
            value = check_type(Float64, value_string)
        else # otherwise assume it is an int
            value = check_type(Int, value_string)
        end
    end

    return value
end

"Attempts to determine the type of an array of strings extracted from a matlab file"
function _type_array(string_array::Vector{T}) where {T <: AbstractString}
    value_string = [strip(value_string) for value_string in string_array]

    return if any(occursin("'", value_string) for value_string in string_array)
        [strip(value_string, '\'') for value_string in string_array]
    elseif any(
        occursin(".", value_string) ||
        occursin("e", value_string) ||
        occursin("Inf", value_string) ||
        occursin("NaN", value_string) for value_string in string_array
    )
        [check_type(Float64, value_string) for value_string in string_array]
    else # otherwise assume it is an int
        [check_type(Int, value_string) for value_string in string_array]
    end
end

""
_parse_matlab_cells(lines, index) = _parse_matlab_data(lines, index, '{', '}')

""
_parse_matlab_matrix(lines, index) = _parse_matlab_data(lines, index, '[', ']')

""
function _parse_matlab_data(lines, index, start_char, end_char)
    last_index = length(lines)
    line_count = 0
    columns = -1

    @assert(occursin("=", lines[index + line_count]))
    matrix_assignment = split(lines[index + line_count], '%')[1]
    matrix_assignment = strip(matrix_assignment)

    @assert(occursin(".", matrix_assignment))
    matrix_assignment_parts = split(matrix_assignment, '=')
    matrix_name = strip(matrix_assignment_parts[1])

    matrix_assignment_rhs = ""
    if length(matrix_assignment_parts) > 1
        matrix_assignment_rhs = strip(matrix_assignment_parts[2])
    end

    line_count = line_count + 1
    matrix_body_lines = [matrix_assignment_rhs]
    found_close_bracket = occursin(string(end_char), matrix_assignment_rhs)

    while index + line_count < last_index && !found_close_bracket
        line = strip(lines[index + line_count])

        if length(line) == 0 || line[1] == '%'
            line_count += 1
            continue
        end

        line = strip(split(line, '%')[1])

        if occursin(string(end_char), line)
            found_close_bracket = true
        end

        push!(matrix_body_lines, line)

        line_count = line_count + 1
    end

    #print(matrix_body_lines)
    matrix_body_lines =
        [_add_line_delimiter(line, start_char, end_char) for line in matrix_body_lines]
    #print(matrix_body_lines)

    matrix_body = join(matrix_body_lines, ' ')
    matrix_body =
        strip(replace(strip(strip(matrix_body), start_char), "$(end_char);" => ""))
    matrix_body_rows = split(matrix_body, ';')
    matrix_body_rows = matrix_body_rows[1:(length(matrix_body_rows) - 1)]

    matrix = []
    for row in matrix_body_rows
        row_items = split_line(strip(row))
        #println(row_items)
        push!(matrix, row_items)
        if columns < 0
            columns = length(row_items)
        elseif columns != length(row_items)
            @error "matrix parsing error, inconsistent number of items in each row\n$(row)"
        end
    end

    rows = length(matrix)
    typed_columns = [_type_array([matrix[r][c] for r in 1:rows]) for c in 1:columns]
    for r in 1:rows
        matrix[r] = [typed_columns[c][r] for c in 1:columns]
    end

    matrix_dict = Dict("name" => matrix_name, "data" => matrix, "line_count" => line_count)

    if index > 1 && occursin("%column_names%", lines[index - 1])
        column_names_string = lines[index - 1]
        column_names_string = replace(column_names_string, "%column_names%" => "")
        column_names = split(column_names_string)
        if length(matrix[1]) != length(column_names)
            @error "column name parsing error, data rows $(length(matrix[1])), column names $(length(column_names)) \n$(column_names)"
        end
        for (c, column_name) in enumerate(column_names)
            if column_name == "index"
                @error "column name parsing error, \"index\" is a reserved column name \n$(column_names)"

                if !(typeof(typed_columns[c][1]) <: Int)
                    @error "the type of a column named \"index\" must be Int, but given $(typeof(typed_columns[c][1]))"
                end
            end
        end
        matrix_dict["column_names"] = column_names
    end

    return matrix_dict
end

""
function split_line(mp_line::AbstractString)
    tokens = []
    curr_token = ""
    is_curr_token_quote = false

    isquote(c) = (c == '\'' || c == '"')

    function _push_curr_token()
        if curr_pos <= length(mp_line)
            curr_token *= mp_line[curr_pos]
        end
        curr_token = strip(curr_token)
        if length(curr_token) > 0
            push!(tokens, curr_token)
        end
        curr_token = ""
        curr_pos += 1
        is_curr_token_quote = false
    end

    function _push_curr_char()
        curr_token *= mp_line[curr_pos]
        curr_pos += 1
    end

    curr_pos = 1
    while curr_pos <= length(mp_line)
        if is_curr_token_quote
            if mp_line[curr_pos] == curr_token[1]
                if mp_line[curr_pos - 1] == '\\'
                    # If we are inside a quote and we see slash-quote, we should
                    # treat the quote character as a regular character.
                    _push_curr_char()
                elseif curr_pos < length(mp_line) && mp_line[curr_pos + 1] == curr_token[1]
                    # If we are inside a quote, and we see two quotes in a row,
                    # we should append one of the quotes to the current
                    # token, then skip the other one.
                    curr_token *= mp_line[curr_pos]
                    curr_pos += 2
                else
                    # If we are inside a quote, and we see an unescaped quote char,
                    # then the quote is ending. We should push the current token.
                    _push_curr_token()
                end
            else
                # If we are inside a quote and we see a non-quote character,
                # we should append that character to the current token.
                _push_curr_char()
            end
        else
            if isspace(mp_line[curr_pos]) && !isspace(mp_line[curr_pos + 1])
                # If we are not inside a quote and we see a transition from
                # space to non-space character, then the current token is done.
                _push_curr_token()
            elseif isquote(mp_line[curr_pos])
                # If we are not inside a quote and we see a quote character,
                # then a new quote is starting. We should append the quote
                # character to the current token and switch to quote mode.
                curr_token = strip(curr_token * mp_line[curr_pos])
                is_curr_token_quote = true
                curr_pos += 1
            else
                # If we are not inside a quote and we see a regular character,
                # we should append that character to the current token.
                _push_curr_char()
            end
        end
    end
    _push_curr_token()
    return tokens
end

""
function _add_line_delimiter(mp_line::AbstractString, start_char, end_char)
    if strip(mp_line) == string(start_char)
        return mp_line
    end

    if !occursin(";", mp_line) && !occursin(string(end_char), mp_line)
        mp_line = "$(mp_line);"
    end

    if occursin(string(end_char), mp_line)
        prefix = strip(split(mp_line, end_char)[1])
        if length(prefix) > 0 && !occursin(";", prefix)
            mp_line = replace(mp_line, end_char => ";$(end_char)")
        end
    end

    return mp_line
end

"Checks if the given value is of a given type, if not tries to make it that type"
function check_type(typ, value)
    if isa(value, typ)
        return value
    elseif isa(value, String) || isa(value, SubString)
        try
            value = parse(typ, value)
            return value
        catch e
            @error "parsing error, the matlab string \"$(value)\" can not be parsed to $(typ) data"
            rethrow(e)
        end
    else
        try
            value = typ(value)
            return value
        catch e
            @error "parsing error, the matlab value $(value) of type $(typeof(value)) can not be parsed to $(typ) data"
            rethrow(e)
        end
    end
end
