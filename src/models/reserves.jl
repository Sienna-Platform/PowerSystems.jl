"""
Used to specify if a [`Reserve`](@ref) is upwards, downwards, or symmetric
"""
abstract type ReserveDirection end

"""
An upwards reserve to increase generation or reduce load

Upwards reserves are used when total load exceeds its expected level,
typically due to forecast errors or contingencies.

A [`Reserve`](@ref) can be specified as a `ReserveUp` when it is defined.
"""
abstract type ReserveUp <: ReserveDirection end

"""
A downwards reserve to decrease generation or increase load

Downwards reserves are used when total load falls below its expected level,
typically due to forecast errors or contingencies. Not work

A [`Reserve`](@ref) can be specified as a `ReserveDown` when it is defined.
"""
abstract type ReserveDown <: ReserveDirection end

"""
A symmetric reserve, procuring the same quantity (MW) of both upwards and downwards
reserves

A symmetric reserve is a special case. [`ReserveUp`](@ref) and [`ReserveDown`](@ref)
can be used individually to specify different quantities of upwards and downwards
reserves, respectively.

A [`Reserve`](@ref) can be specified as a `ReserveSymmetric` when it is defined.
"""
abstract type ReserveSymmetric <: ReserveDirection end

"""
Supertype for all reserve products, both spinning and non-spinning.

Concrete subtypes include [`Reserve`](@ref) (parameterized by [`ReserveDirection`](@ref))
and [`ReserveNonSpinning`](@ref).
"""
abstract type AbstractReserve <: Service end

"""
A reserve product to be able to respond to unexpected disturbances,
such as the sudden loss of a transmission line or generator.
"""
abstract type Reserve{T <: ReserveDirection} <: AbstractReserve end

"""
Supertype for non-spinning (quick-start) reserve products.

Non-spinning reserves can be brought online within a short time but are not
currently synchronized to the grid. See also [`Reserve`](@ref) for spinning reserves.

Concrete subtypes include [`ConstantReserveNonSpinning`](@ref) and
[`VariableReserveNonSpinning`](@ref).
"""
abstract type ReserveNonSpinning <: AbstractReserve end
