"""
Abstract supertype used to specify if a [`Reserve`](@ref) is upwards, downwards, or symmetric.

Subtypes: [`ReserveUp`](@ref), [`ReserveDown`](@ref), [`ReserveSymmetric`](@ref)
"""
abstract type ReserveDirection end

"""
An upwards reserve to increase generation or reduce load

Upwards reserves are used when total load exceeds its expected level,
typically due to forecast errors or contingencies.

A [`Reserve`](@ref) can be specified as a [`ReserveUp`](@ref) when it is defined.

See also: [`ReserveDown`](@ref), [`ReserveSymmetric`](@ref)
"""
abstract type ReserveUp <: ReserveDirection end

"""
A downwards reserve to decrease generation or increase load

Downwards reserves are used when total load falls below its expected level,
typically due to forecast errors or contingencies.

A [`Reserve`](@ref) can be specified as a [`ReserveDown`](@ref) when it is defined.

See also: [`ReserveUp`](@ref), [`ReserveSymmetric`](@ref)
"""
abstract type ReserveDown <: ReserveDirection end

"""
A symmetric reserve, procuring the same quantity (MW) of both upwards and downwards
reserves

Unlike [`ReserveUp`](@ref) and [`ReserveDown`](@ref), which can be used to specify
different quantities of upwards and downwards reserves independently, `ReserveSymmetric`
requires equal procurement in both directions.

A [`Reserve`](@ref) can be specified as a [`ReserveSymmetric`](@ref) when it is defined.

See also: [`ReserveUp`](@ref), [`ReserveDown`](@ref)
"""
abstract type ReserveSymmetric <: ReserveDirection end
"""
Abstract supertype for all reserve products
"""
abstract type AbstractReserve <: Service end

"""
Abstract parametric type for all reserve products, parameterized on direction
`T <: `[`ReserveDirection`](@ref).

Use the direction subtypes [`ReserveUp`](@ref), [`ReserveDown`](@ref), or
[`ReserveSymmetric`](@ref) to specify the direction of the reserve product, e.g.,
`ConstantReserve{ReserveUp}`.

See also: [`ConstantReserve`](@ref), [`VariableReserve`](@ref), [`ReserveDemandCurve`](@ref)
"""
abstract type Reserve{T <: ReserveDirection} <: AbstractReserve end

"""
A non-spinning reserve product: capacity that is committed but not yet generating.

Non-spinning reserves can be brought online more slowly than spinning reserves and
typically have a longer response time requirement.
"""
abstract type ReserveNonSpinning <: AbstractReserve end
