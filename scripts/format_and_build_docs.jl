include("scripts/formatter/formatter_code.jl")
using Pkg
Pkg.activate("docs")
include("docs/make.jl")
