"""
    ReserveDirection

Abstract supertype used to specify if a [`Reserve`](@ref) is upwards, downwards, or symmetric.

Subtypes: [`ReserveUp`](@ref), [`ReserveDown`](@ref), [`ReserveSymmetric`](@ref)
"""
abstract type ReserveDirection end

"""
    ReserveUp

An upwards reserve to increase generation or reduce load.

Upwards reserves are used when total load exceeds its expected level,
typically due to forecast errors or contingencies.

A [`Reserve`](@ref) can be specified as a [`ReserveUp`](@ref) when it is defined.

See also: [`ReserveDown`](@ref), [`ReserveSymmetric`](@ref)
"""
abstract type ReserveUp <: ReserveDirection end

"""
    ReserveDown

A downwards reserve to decrease generation or increase load.

Downwards reserves are used when total load falls below its expected level,
typically due to forecast errors or contingencies.

A [`Reserve`](@ref) can be specified as a [`ReserveDown`](@ref) when it is defined.

See also: [`ReserveUp`](@ref), [`ReserveSymmetric`](@ref)
"""
abstract type ReserveDown <: ReserveDirection end

"""
    ReserveSymmetric

A symmetric reserve, procuring the same quantity (MW) of both upwards and downwards
reserves.

Unlike [`ReserveUp`](@ref) and [`ReserveDown`](@ref), which can be used to specify
different quantities of upwards and downwards reserves independently, `ReserveSymmetric`
requires equal procurement in both directions.

A [`Reserve`](@ref) can be specified as a [`ReserveSymmetric`](@ref) when it is defined.

See also: [`ReserveUp`](@ref), [`ReserveDown`](@ref)
"""
abstract type ReserveSymmetric <: ReserveDirection end

"""
    AbstractReserve

Supertype for all reserve products, both spinning and non-spinning.

Concrete subtypes include [`Reserve`](@ref) (parameterized by [`ReserveDirection`](@ref))
and [`ReserveNonSpinning`](@ref).
"""
abstract type AbstractReserve <: Service end

"""
    Reserve{T <: ReserveDirection}

Abstract parametric type for all reserve products, parameterized on direction
`T <: `[`ReserveDirection`](@ref).

Use the direction subtypes [`ReserveUp`](@ref), [`ReserveDown`](@ref), or
[`ReserveSymmetric`](@ref) to specify the direction of the reserve product, e.g.,
`ConstantReserve{ReserveUp}`.

See also: [`ConstantReserve`](@ref), [`VariableReserve`](@ref), [`ReserveDemandCurve`](@ref)
"""
abstract type Reserve{T <: ReserveDirection} <: AbstractReserve end

"""
    ReserveNonSpinning

Supertype for non-spinning (quick-start) reserve products.

Non-spinning reserves can be brought online within a short time but are not
currently synchronized to the grid. See also [`Reserve`](@ref) for spinning reserves.

Concrete subtypes include [`ConstantReserveNonSpinning`](@ref) and
[`VariableReserveNonSpinning`](@ref).
"""
abstract type ReserveNonSpinning <: AbstractReserve end
