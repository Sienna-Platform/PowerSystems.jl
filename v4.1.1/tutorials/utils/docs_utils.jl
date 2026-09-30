"""
`print_struct()`

Prints the definition of a struct.
"""
function print_struct(type)
    mutable = ismutable(type) ? "mutable" : ""
    println("$mutable struct $type")
    for (fn, ft) in zip(fieldnames(type), fieldtypes(type))
        println("    $fn::$ft")
    end
    println("end")
end