# Type Tree

Here is the complete `PowerSystems.jl` type hierarchy:

```@example types
using PowerSystems #hide
import TypeTree: tt #hide
docs_dir = joinpath(pkgdir(PowerSystems), "docs", "src", "tutorials", "utils"); #hide
include(joinpath(docs_dir, "docs_utils.jl")); #hide
print(join(tt(PowerSystems.IS.InfrastructureSystemsType), "")) #hide
```
