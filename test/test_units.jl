# Tests of the power-domain unit machinery: categories, convert_units across
# per-unit/natural-unit boundaries, serialization, and custom Unitful units.
# The RelativeQuantity arithmetic/comparison/display tests live in IS
# (test/test_relative_units.jl) since those types are domain-agnostic.

import Unitful
using Unitful: @u_str

# Mock components so we can exercise convert_units without building a full System.
struct MockGen
    active_power::Float64
    base_power::Float64
end

struct MockLine
    r::Float64
    x::Float64
end

PSY.get_device_base_power(g::MockGen) = g.base_power
PSY.get_system_base_power(::MockGen) = 100.0
PSY.get_base_voltage(::MockGen) = 230.0

PSY.get_device_base_power(::MockLine) = 100.0
PSY.get_system_base_power(::MockLine) = 100.0
PSY.get_base_voltage(::MockLine) = 230.0

@testset "Unit categories" begin
    @test natural_unit(POWER) == u"MW"
    @test natural_unit(IMPEDANCE) == u"Ω"
    @test natural_unit(ADMITTANCE) == u"S"
    @test natural_unit(VOLTAGE) == u"kV"
    @test natural_unit(CURRENT) == u"kA"
end

@testset "base_value and system_base_value" begin
    gen = MockGen(0.6, 50.0)  # 50 MVA device, 100 MVA system

    @test base_value(gen, POWER) == 50.0
    @test system_base_value(gen, POWER) == 100.0

    # Impedance: V² / S
    @test base_value(gen, IMPEDANCE) ≈ 230.0^2 / 50.0
    @test system_base_value(gen, IMPEDANCE) ≈ 230.0^2 / 100.0

    # Admittance: S / V²
    @test base_value(gen, ADMITTANCE) ≈ 50.0 / 230.0^2
    @test system_base_value(gen, ADMITTANCE) ≈ 100.0 / 230.0^2

    @test base_value(gen, VOLTAGE) == 230.0
    @test system_base_value(gen, VOLTAGE) == 230.0
end

@testset "convert_units: DU → other" begin
    gen = MockGen(0.6, 50.0)

    result = convert_units(gen, 0.6, POWER, DU, MW)
    @test result isa Unitful.Quantity
    @test Unitful.ustrip(result) ≈ 30.0

    result = convert_units(gen, 0.6, POWER, DU, SU)
    @test result isa RelativeQuantity{Float64, SystemBaseUnit}
    @test ustrip(result) ≈ 0.3

    result = convert_units(gen, 0.6, POWER, DU, DU)
    @test ustrip(result) ≈ 0.6

    result = convert_units(gen, 0.6, POWER, DU, Float64)
    @test result isa Float64
    @test result ≈ 0.3
end

@testset "convert_units: SU → other" begin
    gen = MockGen(0.6, 50.0)

    result = convert_units(gen, 0.3, POWER, SU, MW)
    @test Unitful.ustrip(result) ≈ 30.0

    result = convert_units(gen, 0.3, POWER, SU, DU)
    @test ustrip(result) ≈ 0.6

    result = convert_units(gen, 0.3, POWER, SU, SU)
    @test ustrip(result) ≈ 0.3
end

@testset "convert_units: natural → per-unit" begin
    gen = MockGen(0.6, 50.0)

    result = convert_units(gen, 30.0MW, POWER, MW, DU)
    @test ustrip(result) ≈ 0.6

    result = convert_units(gen, 30.0MW, POWER, MW, SU)
    @test ustrip(result) ≈ 0.3
end

@testset "convert_units: impedance" begin
    line = MockLine(0.01, 0.1)
    z_base = 230.0^2 / 100.0

    result = convert_units(line, 0.01, IMPEDANCE, DU, OHMS)
    @test Unitful.ustrip(result) ≈ 0.01 * z_base

    # device base == system base, so DU → Float64 ratio = 1.0
    result = convert_units(line, 0.01, IMPEDANCE, DU, Float64)
    @test result ≈ 0.01
end

@testset "convert_units: nothing passthrough" begin
    gen = MockGen(0.6, 50.0)
    @test convert_units(gen, nothing, POWER, DU, MW) === nothing
end

@testset "convert_units: round-trip consistency" begin
    gen = MockGen(0.6, 50.0)
    original = 0.6

    mw = convert_units(gen, original, POWER, DU, MW)
    back = convert_units(gen, mw, POWER, MW, DU)
    @test ustrip(back) ≈ original

    su = convert_units(gen, original, POWER, DU, SU)
    back = convert_units(gen, ustrip(su), POWER, SU, DU)
    @test ustrip(back) ≈ original
end

@testset "convert_units: ComplexF64 support" begin
    line = MockLine(0.01, 0.1)
    z = 0.01 + 0.1im

    result = convert_units(line, z, IMPEDANCE, DU, Float64)
    @test result isa ComplexF64
    @test result ≈ z  # ratio is 1.0 since device == system base
end

@testset "convert_units: NU (natural units)" begin
    gen = MockGen(0.6, 50.0)

    result = convert_units(gen, 0.6, POWER, DU, NU)
    @test result isa Unitful.Quantity
    @test Unitful.ustrip(result) ≈ 30.0

    result = convert_units(gen, 0.01, IMPEDANCE, DU, NU)
    @test Unitful.dimension(Unitful.unit(result)) == Unitful.dimension(u"Ω")

    result = convert_units(gen, 30.0MW, POWER, NU, DU)
    @test ustrip(result) ≈ 0.6
end

@testset "Serialization: RelativeQuantity" begin
    q = 0.6DU
    d = PSY.serialize_quantity(q)
    @test d["value"] == 0.6
    @test d["unit"] == "DU"
    @test PSY.deserialize_quantity(d) == q

    q = 0.3SU
    d = PSY.serialize_quantity(q)
    @test d["value"] == 0.3
    @test d["unit"] == "SU"
    @test PSY.deserialize_quantity(d) == q

    q = (0.01 + 0.1im) * SU
    d = PSY.serialize_quantity(q)
    @test d["value"]["re"] == 0.01
    @test d["value"]["im"] == 0.1
    @test d["unit"] == "SU"
    @test PSY.deserialize_quantity(d) == q
end

@testset "Serialization: Unitful Quantity" begin
    q = 30.0MW
    d = PSY.serialize_quantity(q)
    @test d["value"] == 30.0
    @test d["unit"] == "MW"
    @test PSY.deserialize_quantity(d) ≈ q

    q = 529.0OHMS
    d = PSY.serialize_quantity(q)
    @test d["value"] == 529.0
    @test d["unit"] == "Ω"
    @test PSY.deserialize_quantity(d) ≈ q
end

@testset "Serialization: JSON string round-trip" begin
    q = 0.3SU
    json = JSON3.write(PSY.serialize_quantity(q))
    @test PSY.deserialize_quantity(json) == q

    q = 30.0MW
    json = JSON3.write(PSY.serialize_quantity(q))
    @test PSY.deserialize_quantity(json) ≈ q
end

@testset "Custom Unitful units" begin
    @test 1.0Mvar == 1.0u"MW"  # same dimension
    @test 1.0MVA == 1.0u"MW"
    @test sprint(show, 1.0Mvar) == "1.0 Mvar"
    @test sprint(show, 1.0MVA) == "1.0 MVA"
end
