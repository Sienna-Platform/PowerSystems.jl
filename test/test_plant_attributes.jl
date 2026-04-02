using Test
using PowerSystems
using InfrastructureSystems
import InfrastructureSystems as IS
import JSON3
import PowerSystemCaseBuilder as PSB
const PSY = PowerSystems

include("common.jl")

@testset "Test plant attributes" begin
    @testset "ThermalPowerPlant construction and basic accessors" begin
        plant = ThermalPowerPlant(name = "Coal Plant A")
        @test get_name(plant) == "Coal Plant A"
    end

    @testset "HydroPowerPlant construction and basic accessors" begin
        plant = HydroPowerPlant(name = "Hydro Dam 1")
        @test get_name(plant) == "Hydro Dam 1"
    end

    @testset "RenewablePowerPlant construction and basic accessors" begin
        plant = RenewablePowerPlant(name = "Wind Farm A")
        @test get_name(plant) == "Wind Farm A"
    end

    @testset "CombinedCycleBlock construction and basic accessors" begin
        cc_block = CombinedCycleBlock(
            name = "CC Block 1",
            configuration = CombinedCycleConfiguration.SingleShaftCombustionSteam,
            heat_recovery_to_steam_factor = 0.85,
        )
        @test get_name(cc_block) == "CC Block 1"
        @test get_configuration(cc_block) ==
              CombinedCycleConfiguration.SingleShaftCombustionSteam
        @test get_heat_recovery_to_steam_factor(cc_block) == 0.85
    end

    @testset "Add and remove ThermalGen to/from ThermalPowerPlant" begin
        sys = System(100.0)

        # Create buses
        bus1 = ACBus(nothing)
        bus1.name = "bus1"
        bus1.number = 1
        bus1.bustype = ACBusTypes.REF
        add_component!(sys, bus1)

        bus2 = ACBus(nothing)
        bus2.name = "bus2"
        bus2.number = 2
        add_component!(sys, bus2)

        # Create thermal generators
        gen1 = ThermalStandard(nothing)
        gen1.bus = bus1
        gen1.name = "thermal_gen1"
        add_component!(sys, gen1)

        gen2 = ThermalStandard(nothing)
        gen2.bus = bus2
        gen2.name = "thermal_gen2"
        add_component!(sys, gen2)

        # Create thermal power plant
        plant = ThermalPowerPlant(name = "Coal Plant")

        # Add generators to plant with shaft numbers
        add_supplemental_attribute!(sys, gen1, plant; shaft_number = 1)
        add_supplemental_attribute!(sys, gen2, plant; shaft_number = 2)

        # Verify shaft mappings
        shaft_map = get_shaft_map(plant)
        @test length(shaft_map) == 2
        @test length(shaft_map[1]) == 1
        @test length(shaft_map[2]) == 1
        @test shaft_map[1][1] == IS.get_uuid(gen1)
        @test shaft_map[2][1] == IS.get_uuid(gen2)

        # Verify reverse mappings
        reverse_map = get_reverse_shaft_map(plant)
        @test reverse_map[IS.get_uuid(gen1)] == 1
        @test reverse_map[IS.get_uuid(gen2)] == 2

        # Verify supplemental attributes are attached
        @test has_supplemental_attributes(gen1)
        @test has_supplemental_attributes(gen2)
        attrs1 = get_supplemental_attributes(ThermalPowerPlant, gen1)
        @test length(collect(attrs1)) == 1
        @test collect(attrs1)[1] == plant

        # Test multiple generators on same shaft
        gen3 = ThermalStandard(nothing)
        gen3.bus = bus1
        gen3.name = "thermal_gen3"
        add_component!(sys, gen3)
        add_supplemental_attribute!(sys, gen3, plant; shaft_number = 1)

        @test length(shaft_map[1]) == 2
        @test shaft_map[1][2] == IS.get_uuid(gen3)

        # Remove generator from plant
        remove_supplemental_attribute!(sys, gen1, plant)
        @test !haskey(reverse_map, IS.get_uuid(gen1))
        @test length(shaft_map[1]) == 1
        @test shaft_map[1][1] == IS.get_uuid(gen3)

        # Remove last generator from shaft
        remove_supplemental_attribute!(sys, gen3, plant)
        @test !haskey(shaft_map, 1)
        @test !haskey(reverse_map, IS.get_uuid(gen3))

        # Test error when removing non-existent generator
        @test_throws IS.ArgumentError remove_supplemental_attribute!(sys, gen1, plant)
    end

    @testset "Get components in shaft" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        # Create thermal generators
        gen1 = ThermalStandard(nothing)
        gen1.bus = bus
        gen1.name = "gen1"
        add_component!(sys, gen1)

        gen2 = ThermalStandard(nothing)
        gen2.bus = bus
        gen2.name = "gen2"
        add_component!(sys, gen2)

        gen3 = ThermalStandard(nothing)
        gen3.bus = bus
        gen3.name = "gen3"
        add_component!(sys, gen3)

        # Create plant with generators on different shafts
        plant = ThermalPowerPlant(name = "Test Plant")
        add_supplemental_attribute!(sys, gen1, plant; shaft_number = 1)
        add_supplemental_attribute!(sys, gen2, plant; shaft_number = 1)
        add_supplemental_attribute!(sys, gen3, plant; shaft_number = 2)

        # Test getting components in shaft 1
        shaft1_components = get_components_in_shaft(sys, plant, 1)
        @test length(shaft1_components) == 2
        shaft1_names = Set([get_name(c) for c in shaft1_components])
        @test "gen1" in shaft1_names
        @test "gen2" in shaft1_names

        # Test getting components in shaft 2
        shaft2_components = get_components_in_shaft(sys, plant, 2)
        @test length(shaft2_components) == 1
        @test get_name(shaft2_components[1]) == "gen3"

        # Test error for non-existent shaft
        @test_throws IS.ArgumentError get_components_in_shaft(sys, plant, 99)
    end

    @testset "Get components in penstock" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        # Create hydro generators
        turb1 = HydroTurbine(nothing)
        turb1.bus = bus
        turb1.name = "turb1"
        add_component!(sys, turb1)

        turb2 = HydroTurbine(nothing)
        turb2.bus = bus
        turb2.name = "turb2"
        add_component!(sys, turb2)

        pump = HydroPumpTurbine(nothing)
        pump.bus = bus
        pump.name = "pump1"
        add_component!(sys, pump)

        # Create plant with generators on different penstocks
        plant = HydroPowerPlant(name = "Hydro Plant")
        add_supplemental_attribute!(sys, turb1, plant, 1)
        add_supplemental_attribute!(sys, turb2, plant, 1)
        add_supplemental_attribute!(sys, pump, plant, 2)

        # Test getting components in penstock 1
        penstock1_components = get_components_in_penstock(sys, plant, 1)
        @test length(penstock1_components) == 2
        penstock1_names = Set([get_name(c) for c in penstock1_components])
        @test "turb1" in penstock1_names
        @test "turb2" in penstock1_names

        # Test getting components in penstock 2
        penstock2_components = get_components_in_penstock(sys, plant, 2)
        @test length(penstock2_components) == 1
        @test get_name(penstock2_components[1]) == "pump1"

        # Test error for non-existent penstock
        @test_throws IS.ArgumentError get_components_in_penstock(sys, plant, 99)
    end

    @testset "Get components in PCC" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        # Create renewable generators and storage
        wind1 = RenewableDispatch(nothing)
        wind1.bus = bus
        wind1.name = "wind1"
        add_component!(sys, wind1)

        solar = RenewableNonDispatch(nothing)
        solar.bus = bus
        solar.name = "solar1"
        add_component!(sys, solar)

        battery = EnergyReservoirStorage(nothing)
        battery.bus = bus
        battery.name = "battery1"
        add_component!(sys, battery)

        # Create plant with components on different PCCs
        plant = RenewablePowerPlant(name = "Renewable Plant")
        add_supplemental_attribute!(sys, wind1, plant, 1)
        add_supplemental_attribute!(sys, battery, plant, 1)
        add_supplemental_attribute!(sys, solar, plant, 2)

        # Test getting components in PCC 1
        pcc1_components = get_components_in_pcc(sys, plant, 1)
        @test length(pcc1_components) == 2
        pcc1_names = Set([get_name(c) for c in pcc1_components])
        @test "wind1" in pcc1_names
        @test "battery1" in pcc1_names

        # Test getting components in PCC 2
        pcc2_components = get_components_in_pcc(sys, plant, 2)
        @test length(pcc2_components) == 1
        @test get_name(pcc2_components[1]) == "solar1"

        # Test error for non-existent PCC
        @test_throws IS.ArgumentError get_components_in_pcc(sys, plant, 99)
    end

    @testset "Add and remove HydroGen to/from HydroPowerPlant" begin
        sys = System(100.0)

        # Create buses
        bus1 = ACBus(nothing)
        bus1.name = "bus1"
        bus1.number = 1
        bus1.bustype = ACBusTypes.REF
        add_component!(sys, bus1)

        bus2 = ACBus(nothing)
        bus2.name = "bus2"
        bus2.number = 2
        add_component!(sys, bus2)

        # Create hydro generators
        gen1 = HydroTurbine(nothing)
        gen1.bus = bus1
        gen1.name = "hydro_gen1"
        add_component!(sys, gen1)

        gen2 = HydroPumpTurbine(nothing)
        gen2.bus = bus2
        gen2.name = "hydro_gen2"
        add_component!(sys, gen2)

        # Create hydro power plant
        plant = HydroPowerPlant(name = "Hydro Dam")

        # Add generators to plant with penstock numbers
        add_supplemental_attribute!(sys, gen1, plant, 1)
        add_supplemental_attribute!(sys, gen2, plant, 2)

        # Verify penstock mappings
        penstock_map = get_penstock_map(plant)
        @test length(penstock_map) == 2
        @test penstock_map[1][1] == IS.get_uuid(gen1)
        @test penstock_map[2][1] == IS.get_uuid(gen2)

        # Verify reverse mappings
        reverse_map = get_reverse_penstock_map(plant)
        @test reverse_map[IS.get_uuid(gen1)] == 1
        @test reverse_map[IS.get_uuid(gen2)] == 2

        # Remove generator from plant
        remove_supplemental_attribute!(sys, gen1, plant)
        @test !haskey(reverse_map, IS.get_uuid(gen1))
        @test !haskey(penstock_map, 1)

        # Test error for HydroDispatch
        hydro_dispatch = HydroDispatch(nothing)
        hydro_dispatch.bus = bus1
        hydro_dispatch.name = "hydro_dispatch"
        add_component!(sys, hydro_dispatch)

        @test_throws IS.ArgumentError add_supplemental_attribute!(
            sys,
            hydro_dispatch,
            plant,
            1,
        )
    end

    @testset "Add and remove RenewableGen to/from RenewablePowerPlant" begin
        sys = System(100.0)

        # Create buses
        bus1 = ACBus(nothing)
        bus1.name = "bus1"
        bus1.number = 1
        bus1.bustype = ACBusTypes.REF
        add_component!(sys, bus1)

        bus2 = ACBus(nothing)
        bus2.name = "bus2"
        bus2.number = 2
        add_component!(sys, bus2)

        # Create renewable generators
        gen1 = RenewableDispatch(nothing)
        gen1.bus = bus1
        gen1.name = "wind_gen1"
        add_component!(sys, gen1)

        gen2 = RenewableNonDispatch(nothing)
        gen2.bus = bus2
        gen2.name = "solar_gen2"
        add_component!(sys, gen2)

        # Create storage
        storage = EnergyReservoirStorage(nothing)
        storage.bus = bus1
        storage.name = "battery1"
        add_component!(sys, storage)

        # Create renewable power plant
        plant = RenewablePowerPlant(name = "Renewable Farm")

        # Add generators to plant with PCC numbers
        add_supplemental_attribute!(sys, gen1, plant, 1)
        add_supplemental_attribute!(sys, gen2, plant, 2)
        add_supplemental_attribute!(sys, storage, plant, 1)

        # Verify PCC mappings
        pcc_map = get_pcc_map(plant)
        @test length(pcc_map) == 2
        @test length(pcc_map[1]) == 2  # gen1 and storage on same PCC
        @test length(pcc_map[2]) == 1
        @test IS.get_uuid(gen1) in pcc_map[1]
        @test IS.get_uuid(storage) in pcc_map[1]
        @test pcc_map[2][1] == IS.get_uuid(gen2)

        # Verify reverse mappings
        reverse_map = get_reverse_pcc_map(plant)
        @test reverse_map[IS.get_uuid(gen1)] == 1
        @test reverse_map[IS.get_uuid(gen2)] == 2
        @test reverse_map[IS.get_uuid(storage)] == 1

        # Remove generator from plant
        remove_supplemental_attribute!(sys, gen1, plant)
        @test !haskey(reverse_map, IS.get_uuid(gen1))
        @test length(pcc_map[1]) == 1
        @test pcc_map[1][1] == IS.get_uuid(storage)

        # Remove storage
        remove_supplemental_attribute!(sys, storage, plant)
        @test !haskey(pcc_map, 1)
        @test !haskey(reverse_map, IS.get_uuid(storage))
    end

    @testset "Serialization and deserialization of ThermalPowerPlant" begin
        sys = System(100.0)

        # Create bus and generator
        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        gen1 = ThermalStandard(nothing)
        gen1.bus = bus
        gen1.name = "thermal_gen1"
        add_component!(sys, gen1)

        gen2 = ThermalStandard(nothing)
        gen2.bus = bus
        gen2.name = "thermal_gen2"
        add_component!(sys, gen2)

        # Create and add plant
        plant = ThermalPowerPlant(name = "Coal Plant")
        add_supplemental_attribute!(sys, gen1, plant; shaft_number = 1)
        add_supplemental_attribute!(sys, gen2, plant; shaft_number = 2)

        # Serialize and deserialize
        sys2, result = validate_serialization(sys)
        @test result

        # Verify plant is preserved
        gen1_restored = get_component(ThermalStandard, sys2, "thermal_gen1")
        gen2_restored = get_component(ThermalStandard, sys2, "thermal_gen2")
        @test has_supplemental_attributes(gen1_restored)
        @test has_supplemental_attributes(gen2_restored)

        attrs = get_supplemental_attributes(ThermalPowerPlant, gen1_restored)
        plant_restored = collect(attrs)[1]
        @test get_name(plant_restored) == "Coal Plant"

        # Verify mappings are preserved
        shaft_map = get_shaft_map(plant_restored)
        reverse_map = get_reverse_shaft_map(plant_restored)
        @test length(shaft_map) == 2
        @test length(reverse_map) == 2
        @test reverse_map[IS.get_uuid(gen1_restored)] == 1
        @test reverse_map[IS.get_uuid(gen2_restored)] == 2
    end

    @testset "Serialization and deserialization of HydroPowerPlant" begin
        sys = System(100.0)

        # Create bus and generator
        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        gen1 = HydroTurbine(nothing)
        gen1.bus = bus
        gen1.name = "hydro_gen1"
        add_component!(sys, gen1)

        gen2 = HydroTurbine(nothing)
        gen2.bus = bus
        gen2.name = "hydro_gen2"
        add_component!(sys, gen2)

        # Create and add plant
        plant = HydroPowerPlant(name = "Hydro Dam")
        add_supplemental_attribute!(sys, gen1, plant, 1)
        add_supplemental_attribute!(sys, gen2, plant, 2)

        # Serialize and deserialize
        sys2, result = validate_serialization(sys)
        @test result

        # Verify plant is preserved
        gen1_restored = get_component(HydroTurbine, sys2, "hydro_gen1")
        attrs = get_supplemental_attributes(HydroPowerPlant, gen1_restored)
        plant_restored = collect(attrs)[1]
        @test get_name(plant_restored) == "Hydro Dam"

        # Verify mappings are preserved
        penstock_map = get_penstock_map(plant_restored)
        reverse_map = get_reverse_penstock_map(plant_restored)
        @test length(penstock_map) == 2
        @test length(reverse_map) == 2
    end

    @testset "Serialization and deserialization of RenewablePowerPlant" begin
        sys = System(100.0)

        # Create bus and generator
        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        gen1 = RenewableDispatch(nothing)
        gen1.bus = bus
        gen1.name = "wind_gen1"
        add_component!(sys, gen1)

        storage = EnergyReservoirStorage(nothing)
        storage.bus = bus
        storage.name = "battery1"
        add_component!(sys, storage)

        # Create and add plant
        plant = RenewablePowerPlant(name = "Wind Farm")
        add_supplemental_attribute!(sys, gen1, plant, 1)
        add_supplemental_attribute!(sys, storage, plant, 1)

        # Serialize and deserialize
        sys2, result = validate_serialization(sys)
        @test result

        # Verify plant is preserved
        gen1_restored = get_component(RenewableDispatch, sys2, "wind_gen1")
        attrs = get_supplemental_attributes(RenewablePowerPlant, gen1_restored)
        plant_restored = collect(attrs)[1]
        @test get_name(plant_restored) == "Wind Farm"

        # Verify mappings are preserved
        pcc_map = get_pcc_map(plant_restored)
        reverse_map = get_reverse_pcc_map(plant_restored)
        @test length(pcc_map) == 1
        @test length(pcc_map[1]) == 2  # Both generator and storage on same PCC
        @test length(reverse_map) == 2
    end

    @testset "Add and remove ThermalGen to/from CombinedCycleBlock" begin
        sys = System(100.0)

        bus1 = ACBus(nothing)
        bus1.name = "bus1"
        bus1.number = 1
        bus1.bustype = ACBusTypes.REF
        add_component!(sys, bus1)

        bus2 = ACBus(nothing)
        bus2.name = "bus2"
        bus2.number = 2
        add_component!(sys, bus2)

        # Create thermal generators with appropriate prime mover types
        ct_gen = ThermalStandard(nothing)
        ct_gen.bus = bus1
        ct_gen.name = "ct_gen1"
        ct_gen.prime_mover_type = PrimeMovers.CT
        add_component!(sys, ct_gen)

        ca_gen = ThermalStandard(nothing)
        ca_gen.bus = bus2
        ca_gen.name = "ca_gen1"
        ca_gen.prime_mover_type = PrimeMovers.CA
        add_component!(sys, ca_gen)

        # Create combined cycle block
        cc_block = CombinedCycleBlock(
            name = "CC Block 1",
            configuration = CombinedCycleConfiguration.SeparateShaftCombustionSteam,
            heat_recovery_to_steam_factor = 0.75,
        )

        # Add generators with HRSG numbers (prime mover type is read from component)
        add_supplemental_attribute!(
            sys, ct_gen, cc_block; hrsg_number = 1,
        )
        add_supplemental_attribute!(
            sys, ca_gen, cc_block; hrsg_number = 1,
        )

        # Verify HRSG CT mappings
        hrsg_ct_map = get_hrsg_ct_map(cc_block)
        @test length(hrsg_ct_map) == 1
        @test length(hrsg_ct_map[1]) == 1
        @test hrsg_ct_map[1][1] == IS.get_uuid(ct_gen)

        # Verify HRSG CA mappings
        hrsg_ca_map = get_hrsg_ca_map(cc_block)
        @test length(hrsg_ca_map) == 1
        @test length(hrsg_ca_map[1]) == 1
        @test hrsg_ca_map[1][1] == IS.get_uuid(ca_gen)

        # Verify reverse CT mapping
        ct_hrsg_map = get_ct_hrsg_map(cc_block)
        @test ct_hrsg_map[IS.get_uuid(ct_gen)] == [1]

        # Verify reverse CA mapping
        ca_hrsg_map = get_ca_hrsg_map(cc_block)
        @test ca_hrsg_map[IS.get_uuid(ca_gen)] == [1]

        # Verify supplemental attributes are attached
        @test has_supplemental_attributes(ct_gen)
        @test has_supplemental_attributes(ca_gen)

        # Test multiple CTs on same HRSG
        ct_gen2 = ThermalStandard(nothing)
        ct_gen2.bus = bus1
        ct_gen2.name = "ct_gen2"
        ct_gen2.prime_mover_type = PrimeMovers.CT
        add_component!(sys, ct_gen2)
        add_supplemental_attribute!(
            sys, ct_gen2, cc_block; hrsg_number = 1,
        )
        @test length(hrsg_ct_map[1]) == 2
        @test hrsg_ct_map[1][2] == IS.get_uuid(ct_gen2)

        # Remove generator from block
        remove_supplemental_attribute!(sys, ct_gen, cc_block)
        @test !haskey(ct_hrsg_map, IS.get_uuid(ct_gen))
        @test length(hrsg_ct_map[1]) == 1
        @test hrsg_ct_map[1][1] == IS.get_uuid(ct_gen2)

        # Remove last CT generator from HRSG 1
        remove_supplemental_attribute!(sys, ct_gen2, cc_block)
        @test !haskey(hrsg_ct_map, 1)
        @test !haskey(ct_hrsg_map, IS.get_uuid(ct_gen2))

        # Test error when removing non-existent generator
        @test_throws IS.ArgumentError remove_supplemental_attribute!(
            sys, ct_gen, cc_block,
        )
    end

    @testset "CombinedCycleBlock rejects invalid PrimeMover types" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        cc_block = CombinedCycleBlock(
            name = "CC Block Invalid",
            configuration = CombinedCycleConfiguration.SingleShaftCombustionSteam,
        )

        # Invalid prime mover types should throw (only CT and CA are valid)
        for (i, pm) in enumerate([
            PrimeMovers.GT,
            PrimeMovers.ST,
            PrimeMovers.WT,
            PrimeMovers.CC,
            PrimeMovers.CS,
        ])
            gen = ThermalStandard(nothing)
            gen.bus = bus
            gen.name = "gen_invalid_$i"
            gen.prime_mover_type = pm
            add_component!(sys, gen)
            @test_throws IS.ArgumentError add_supplemental_attribute!(
                sys, gen, cc_block; hrsg_number = 1,
            )
        end

        # Valid prime mover types should not throw (CT and CA only)
        ct_gen = ThermalStandard(nothing)
        ct_gen.bus = bus
        ct_gen.name = "gen_ct"
        ct_gen.prime_mover_type = PrimeMovers.CT
        add_component!(sys, ct_gen)
        add_supplemental_attribute!(
            sys, ct_gen, cc_block; hrsg_number = 1,
        )

        ca_gen = ThermalStandard(nothing)
        ca_gen.bus = bus
        ca_gen.name = "gen_ca"
        ca_gen.prime_mover_type = PrimeMovers.CA
        add_component!(sys, ca_gen)
        add_supplemental_attribute!(
            sys, ca_gen, cc_block; hrsg_number = 1,
        )

        @test length(get_hrsg_ct_map(cc_block)) == 1
        @test length(get_hrsg_ca_map(cc_block)) == 1
    end

    @testset "Serialization and deserialization of CombinedCycleBlock" begin
        sys = System(100.0)

        # Create bus and generators with appropriate prime mover types
        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        ct_gen = ThermalStandard(nothing)
        ct_gen.bus = bus
        ct_gen.name = "cc_ct_gen1"
        ct_gen.prime_mover_type = PrimeMovers.CT
        add_component!(sys, ct_gen)

        ca_gen = ThermalStandard(nothing)
        ca_gen.bus = bus
        ca_gen.name = "cc_ca_gen1"
        ca_gen.prime_mover_type = PrimeMovers.CA
        add_component!(sys, ca_gen)

        # Create and add combined cycle block with HRSG mappings
        cc_block = CombinedCycleBlock(
            name = "CC Block 1",
            configuration = CombinedCycleConfiguration.SeparateShaftCombustionSteam,
            heat_recovery_to_steam_factor = 0.75,
        )
        add_supplemental_attribute!(
            sys, ct_gen, cc_block; hrsg_number = 1,
        )
        add_supplemental_attribute!(
            sys, ca_gen, cc_block; hrsg_number = 1,
        )

        # Serialize and deserialize
        sys2, result = validate_serialization(sys)
        @test result

        # Verify block is preserved
        ct_gen_restored = get_component(ThermalStandard, sys2, "cc_ct_gen1")
        @test has_supplemental_attributes(ct_gen_restored)
        attrs = get_supplemental_attributes(CombinedCycleBlock, ct_gen_restored)
        cc_block_restored = collect(attrs)[1]
        @test get_name(cc_block_restored) == "CC Block 1"
        @test get_configuration(cc_block_restored) ==
              CombinedCycleConfiguration.SeparateShaftCombustionSteam
        @test get_heat_recovery_to_steam_factor(cc_block_restored) == 0.75

        # Verify HRSG mappings are preserved
        hrsg_ct_map = get_hrsg_ct_map(cc_block_restored)
        hrsg_ca_map = get_hrsg_ca_map(cc_block_restored)
        ct_hrsg_map = get_ct_hrsg_map(cc_block_restored)
        ca_hrsg_map = get_ca_hrsg_map(cc_block_restored)
        @test length(hrsg_ct_map) == 1
        @test length(hrsg_ca_map) == 1
        @test length(ct_hrsg_map) == 1
        @test length(ca_hrsg_map) == 1

        ct_gen_restored_uuid = IS.get_uuid(ct_gen_restored)
        ca_gen_restored = get_component(ThermalStandard, sys2, "cc_ca_gen1")
        ca_gen_restored_uuid = IS.get_uuid(ca_gen_restored)

        @test ct_hrsg_map[ct_gen_restored_uuid] == [1]
        @test ca_hrsg_map[ca_gen_restored_uuid] == [1]
        @test ct_gen_restored_uuid in hrsg_ct_map[1]
        @test ca_gen_restored_uuid in hrsg_ca_map[1]
    end

    @testset "Duplicate generator rejection for ThermalPowerPlant" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        gen = ThermalStandard(nothing)
        gen.bus = bus
        gen.name = "gen1"
        add_component!(sys, gen)

        plant = ThermalPowerPlant(name = "Plant")
        add_supplemental_attribute!(sys, gen, plant; shaft_number = 1)

        # Adding the same generator again should throw
        @test_throws IS.ArgumentError add_supplemental_attribute!(
            sys, gen, plant; shaft_number = 1,
        )
        # Also rejects with a different shaft number
        @test_throws IS.ArgumentError add_supplemental_attribute!(
            sys, gen, plant; shaft_number = 2,
        )

        # Maps should be unchanged after rejected adds
        @test length(get_shaft_map(plant)) == 1
        @test length(get_shaft_map(plant)[1]) == 1
        @test get_reverse_shaft_map(plant)[IS.get_uuid(gen)] == 1
    end

    @testset "Duplicate generator rejection for HydroPowerPlant" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        turb = HydroTurbine(nothing)
        turb.bus = bus
        turb.name = "turb1"
        add_component!(sys, turb)

        plant = HydroPowerPlant(name = "Hydro Plant")
        add_supplemental_attribute!(sys, turb, plant, 1)

        # Adding the same turbine again should throw
        @test_throws IS.ArgumentError add_supplemental_attribute!(sys, turb, plant, 1)
        @test_throws IS.ArgumentError add_supplemental_attribute!(sys, turb, plant, 2)

        # Maps should be unchanged
        @test length(get_penstock_map(plant)) == 1
        @test length(get_penstock_map(plant)[1]) == 1
        @test get_reverse_penstock_map(plant)[IS.get_uuid(turb)] == 1
    end

    @testset "Duplicate generator rejection for RenewablePowerPlant" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        wind = RenewableDispatch(nothing)
        wind.bus = bus
        wind.name = "wind1"
        add_component!(sys, wind)

        plant = RenewablePowerPlant(name = "Renewable Plant")
        add_supplemental_attribute!(sys, wind, plant, 1)

        # Adding the same generator again should throw
        @test_throws IS.ArgumentError add_supplemental_attribute!(sys, wind, plant, 1)
        @test_throws IS.ArgumentError add_supplemental_attribute!(sys, wind, plant, 2)

        # Maps should be unchanged
        @test length(get_pcc_map(plant)) == 1
        @test length(get_pcc_map(plant)[1]) == 1
        @test get_reverse_pcc_map(plant)[IS.get_uuid(wind)] == 1
    end

    @testset "Duplicate generator rejection for CombinedCycleBlock" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        ct_gen = ThermalStandard(nothing)
        ct_gen.bus = bus
        ct_gen.name = "ct_gen1"
        ct_gen.prime_mover_type = PrimeMovers.CT
        add_component!(sys, ct_gen)

        ca_gen = ThermalStandard(nothing)
        ca_gen.bus = bus
        ca_gen.name = "ca_gen1"
        ca_gen.prime_mover_type = PrimeMovers.CA
        add_component!(sys, ca_gen)

        cc_block = CombinedCycleBlock(
            name = "CC Block",
            configuration = CombinedCycleConfiguration.SeparateShaftCombustionSteam,
        )

        add_supplemental_attribute!(sys, ct_gen, cc_block; hrsg_number = 1)
        add_supplemental_attribute!(sys, ca_gen, cc_block; hrsg_number = 1)

        # Adding the same CT again should throw
        @test_throws IS.ArgumentError add_supplemental_attribute!(
            sys, ct_gen, cc_block; hrsg_number = 1,
        )
        @test_throws IS.ArgumentError add_supplemental_attribute!(
            sys, ct_gen, cc_block; hrsg_number = 2,
        )

        # Adding the same CA again should throw
        @test_throws IS.ArgumentError add_supplemental_attribute!(
            sys, ca_gen, cc_block; hrsg_number = 1,
        )
        @test_throws IS.ArgumentError add_supplemental_attribute!(
            sys, ca_gen, cc_block; hrsg_number = 2,
        )

        # Maps should be unchanged after rejected adds
        hrsg_ct_map = get_hrsg_ct_map(cc_block)
        hrsg_ca_map = get_hrsg_ca_map(cc_block)
        ct_hrsg_map = get_ct_hrsg_map(cc_block)
        ca_hrsg_map = get_ca_hrsg_map(cc_block)
        @test length(hrsg_ct_map) == 1
        @test length(hrsg_ct_map[1]) == 1
        @test length(hrsg_ca_map) == 1
        @test length(hrsg_ca_map[1]) == 1
        @test ct_hrsg_map[IS.get_uuid(ct_gen)] == [1]
        @test ca_hrsg_map[IS.get_uuid(ca_gen)] == [1]
    end

    @testset "Multiple plants per generator" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        gen = ThermalStandard(nothing)
        gen.bus = bus
        gen.name = "thermal_gen1"
        add_component!(sys, gen)

        # Add multiple plant attributes to same generator
        plant1 = ThermalPowerPlant(name = "Plant A")
        plant2 = ThermalPowerPlant(name = "Plant B")

        add_supplemental_attribute!(sys, gen, plant1; shaft_number = 1)
        add_supplemental_attribute!(sys, gen, plant2; shaft_number = 1)

        # Verify both plants are attached
        attrs = get_supplemental_attributes(ThermalPowerPlant, gen)
        plants = collect(attrs)
        @test length(plants) == 2
        plant_names = Set([get_name(p) for p in plants])
        @test "Plant A" in plant_names
        @test "Plant B" in plant_names

        # Remove one plant
        remove_supplemental_attribute!(sys, gen, plant1)
        attrs = get_supplemental_attributes(ThermalPowerPlant, gen)
        @test length(collect(attrs)) == 1
        @test get_name(collect(attrs)[1]) == "Plant B"
    end

    @testset "Empty plant serialization" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        gen = ThermalStandard(nothing)
        gen.bus = bus
        gen.name = "thermal_gen1"
        add_component!(sys, gen)

        # Create empty plant (no generators added yet)
        plant = ThermalPowerPlant(name = "Empty Plant")
        IS.add_supplemental_attribute!(sys.data, gen, plant)

        # Serialize and deserialize
        sys2, result = validate_serialization(sys)
        @test result

        # Verify empty plant is preserved
        gen_restored = get_component(ThermalStandard, sys2, "thermal_gen1")
        attrs = get_supplemental_attributes(ThermalPowerPlant, gen_restored)
        plant_restored = collect(attrs)[1]
        @test get_name(plant_restored) == "Empty Plant"
        @test isempty(get_shaft_map(plant_restored))
        @test isempty(get_reverse_shaft_map(plant_restored))
    end

    @testset "Plant attributes with case builder system and full serialization cycle" begin
        # Load a system from case builder
        sys = PSB.build_system(PSB.PSITestSystems, "c_sys5")

        # Get thermal generators
        thermal_gens = collect(get_components(ThermalStandard, sys))
        @test length(thermal_gens) >= 2

        # Create thermal power plant and add generators
        thermal_plant = ThermalPowerPlant(name = "Test Coal Plant")
        add_supplemental_attribute!(sys, thermal_gens[1], thermal_plant; shaft_number = 1)
        add_supplemental_attribute!(sys, thermal_gens[2], thermal_plant; shaft_number = 2)

        # Verify plant is attached
        @test has_supplemental_attributes(thermal_gens[1])
        attrs = get_supplemental_attributes(ThermalPowerPlant, thermal_gens[1])
        @test length(collect(attrs)) == 1
        @test get_name(collect(attrs)[1]) == "Test Coal Plant"

        # Get renewable generators if available
        renewable_gens = collect(get_components(RenewableGen, sys))
        if length(renewable_gens) >= 1
            # Create renewable power plant
            renewable_plant = RenewablePowerPlant(name = "Test Wind Farm")
            add_supplemental_attribute!(sys, renewable_gens[1], renewable_plant, 1)

            # Verify plant is attached
            @test has_supplemental_attributes(renewable_gens[1])
        end

        # Test to_json serialization
        test_dir = mktempdir()
        json_path = joinpath(test_dir, "system_with_plants.json")

        try
            # Serialize using to_json
            to_json(sys, json_path; force = true)
            @test isfile(json_path)

            # Verify JSON file contains plant data
            json_data = open(json_path, "r") do io
                JSON3.read(io)
            end
            @test haskey(json_data, "data_format_version")
            @test json_data["data_format_version"] == PSY.DATA_FORMAT_VERSION

            # Test System(file) constructor
            sys_loaded = System(json_path)

            # Verify system loaded correctly
            @test get_base_power(sys_loaded) == get_base_power(sys)
            @test length(get_components(ThermalStandard, sys_loaded)) ==
                  length(thermal_gens)

            # Verify thermal power plant is preserved
            gen1_loaded = get_component(
                ThermalStandard,
                sys_loaded,
                get_name(thermal_gens[1]),
            )
            @test gen1_loaded !== nothing
            @test has_supplemental_attributes(gen1_loaded)

            attrs_loaded = get_supplemental_attributes(ThermalPowerPlant, gen1_loaded)
            plant_loaded = collect(attrs_loaded)[1]
            @test get_name(plant_loaded) == "Test Coal Plant"

            # Verify shaft mappings are preserved
            shaft_map = get_shaft_map(plant_loaded)
            reverse_map = get_reverse_shaft_map(plant_loaded)
            @test length(shaft_map) == 2
            @test length(reverse_map) == 2

            gen1_uuid = IS.get_uuid(gen1_loaded)
            gen2_loaded = get_component(
                ThermalStandard,
                sys_loaded,
                get_name(thermal_gens[2]),
            )
            gen2_uuid = IS.get_uuid(gen2_loaded)

            @test reverse_map[gen1_uuid] == 1
            @test reverse_map[gen2_uuid] == 2
            @test gen1_uuid in shaft_map[1]
            @test gen2_uuid in shaft_map[2]

            # Verify renewable plant if it was added
            if length(renewable_gens) >= 1
                ren1_loaded = get_component(
                    RenewableGen,
                    sys_loaded,
                    get_name(renewable_gens[1]),
                )
                @test has_supplemental_attributes(ren1_loaded)

                ren_attrs = get_supplemental_attributes(RenewablePowerPlant, ren1_loaded)
                ren_plant_loaded = collect(ren_attrs)[1]
                @test get_name(ren_plant_loaded) == "Test Wind Farm"

                pcc_map = get_pcc_map(ren_plant_loaded)
                @test length(pcc_map) == 1
                @test IS.get_uuid(ren1_loaded) in pcc_map[1]
            end

            # Test that we can serialize the loaded system again (round-trip)
            json_path2 = joinpath(test_dir, "system_roundtrip.json")
            to_json(sys_loaded, json_path2; force = true)
            @test isfile(json_path2)

            # Load the round-trip system
            sys_roundtrip = System(json_path2)
            @test get_base_power(sys_roundtrip) == get_base_power(sys)

            # Verify plant still exists after round-trip
            gen1_rt = get_component(
                ThermalStandard,
                sys_roundtrip,
                get_name(thermal_gens[1]),
            )
            @test has_supplemental_attributes(gen1_rt)
            attrs_rt = get_supplemental_attributes(ThermalPowerPlant, gen1_rt)
            @test get_name(collect(attrs_rt)[1]) == "Test Coal Plant"

        finally
            # Clean up temporary files
            rm(test_dir; recursive = true, force = true)
        end
    end

    @testset "CombinedCycleFractional construction and basic accessors" begin
        cc_frac = CombinedCycleFractional(
            name = "CC Frac 1",
            configuration = CombinedCycleConfiguration.SingleShaftCombustionSteam,
        )
        @test get_name(cc_frac) == "CC Frac 1"
        @test get_configuration(cc_frac) ==
              CombinedCycleConfiguration.SingleShaftCombustionSteam
        @test isempty(get_operation_exclusion_map(cc_frac))
        @test isempty(get_inverse_operation_exclusion_map(cc_frac))
    end

    @testset "Add and remove ThermalGen to/from CombinedCycleFractional" begin
        sys = System(100.0)

        bus1 = ACBus(nothing)
        bus1.name = "bus1"
        bus1.number = 1
        bus1.bustype = ACBusTypes.REF
        add_component!(sys, bus1)

        bus2 = ACBus(nothing)
        bus2.name = "bus2"
        bus2.number = 2
        add_component!(sys, bus2)

        # Create thermal generators with CC prime mover type
        cc_gen1 = ThermalStandard(nothing)
        cc_gen1.bus = bus1
        cc_gen1.name = "cc_gen1"
        cc_gen1.prime_mover_type = PrimeMovers.CC
        add_component!(sys, cc_gen1)

        cc_gen2 = ThermalStandard(nothing)
        cc_gen2.bus = bus2
        cc_gen2.name = "cc_gen2"
        cc_gen2.prime_mover_type = PrimeMovers.CC
        add_component!(sys, cc_gen2)

        # Create combined cycle fractional plant
        cc_frac = CombinedCycleFractional(
            name = "CC Frac 1",
            configuration = CombinedCycleConfiguration.SeparateShaftCombustionSteam,
        )

        # Add generators with exclusion group numbers
        add_supplemental_attribute!(
            sys, cc_gen1, cc_frac; exclusion_group = 1,
        )
        add_supplemental_attribute!(
            sys, cc_gen2, cc_frac; exclusion_group = 1,
        )

        # Verify exclusion mappings
        excl_map = get_operation_exclusion_map(cc_frac)
        @test length(excl_map) == 1
        @test length(excl_map[1]) == 2
        @test IS.get_uuid(cc_gen1) in excl_map[1]
        @test IS.get_uuid(cc_gen2) in excl_map[1]

        # Verify inverse mappings
        inv_map = get_inverse_operation_exclusion_map(cc_frac)
        @test length(inv_map) == 2
        @test inv_map[IS.get_uuid(cc_gen1)] == 1
        @test inv_map[IS.get_uuid(cc_gen2)] == 1

        # Verify supplemental attributes are attached
        @test has_supplemental_attributes(cc_gen1)
        @test has_supplemental_attributes(cc_gen2)

        # Test multiple exclusion groups
        cc_gen3 = ThermalStandard(nothing)
        cc_gen3.bus = bus1
        cc_gen3.name = "cc_gen3"
        cc_gen3.prime_mover_type = PrimeMovers.CC
        add_component!(sys, cc_gen3)
        add_supplemental_attribute!(
            sys, cc_gen3, cc_frac; exclusion_group = 2,
        )
        @test length(excl_map) == 2
        @test length(excl_map[2]) == 1
        @test excl_map[2][1] == IS.get_uuid(cc_gen3)

        # Remove generator from plant
        remove_supplemental_attribute!(sys, cc_gen1, cc_frac)
        @test length(excl_map[1]) == 1
        @test excl_map[1][1] == IS.get_uuid(cc_gen2)

        # Remove last generator from group 1
        remove_supplemental_attribute!(sys, cc_gen2, cc_frac)
        @test !haskey(excl_map, 1)

        # Test error when removing non-existent generator
        @test_throws IS.ArgumentError remove_supplemental_attribute!(
            sys, cc_gen1, cc_frac,
        )
    end

    @testset "CombinedCycleFractional rejects invalid PrimeMover types" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        cc_frac = CombinedCycleFractional(
            name = "CC Frac Invalid",
            configuration = CombinedCycleConfiguration.SingleShaftCombustionSteam,
        )

        # Invalid prime mover types should throw (only CC is valid)
        for (i, pm) in enumerate([
            PrimeMovers.GT,
            PrimeMovers.ST,
            PrimeMovers.WT,
            PrimeMovers.CT,
            PrimeMovers.CA,
        ])
            gen = ThermalStandard(nothing)
            gen.bus = bus
            gen.name = "gen_invalid_$i"
            gen.prime_mover_type = pm
            add_component!(sys, gen)
            @test_throws IS.ArgumentError add_supplemental_attribute!(
                sys, gen, cc_frac; exclusion_group = 1,
            )
        end

        # Valid prime mover type (CC only)
        cc_gen = ThermalStandard(nothing)
        cc_gen.bus = bus
        cc_gen.name = "gen_cc"
        cc_gen.prime_mover_type = PrimeMovers.CC
        add_component!(sys, cc_gen)
        add_supplemental_attribute!(
            sys, cc_gen, cc_frac; exclusion_group = 1,
        )
        @test length(get_operation_exclusion_map(cc_frac)) == 1
    end

    @testset "Get components in exclusion group" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        # Create CC generators
        gen1 = ThermalStandard(nothing)
        gen1.bus = bus
        gen1.name = "cc_gen1"
        gen1.prime_mover_type = PrimeMovers.CC
        add_component!(sys, gen1)

        gen2 = ThermalStandard(nothing)
        gen2.bus = bus
        gen2.name = "cc_gen2"
        gen2.prime_mover_type = PrimeMovers.CC
        add_component!(sys, gen2)

        gen3 = ThermalStandard(nothing)
        gen3.bus = bus
        gen3.name = "cc_gen3"
        gen3.prime_mover_type = PrimeMovers.CC
        add_component!(sys, gen3)

        # Create plant with generators in different exclusion groups
        cc_frac = CombinedCycleFractional(
            name = "CC Frac Test",
            configuration = CombinedCycleConfiguration.SeparateShaftCombustionSteam,
        )
        add_supplemental_attribute!(sys, gen1, cc_frac; exclusion_group = 1)
        add_supplemental_attribute!(sys, gen2, cc_frac; exclusion_group = 1)
        add_supplemental_attribute!(sys, gen3, cc_frac; exclusion_group = 2)

        # Test getting components in exclusion group 1
        group1_components = get_components_in_exclusion_group(sys, cc_frac, 1)
        @test length(group1_components) == 2
        group1_names = Set([get_name(c) for c in group1_components])
        @test "cc_gen1" in group1_names
        @test "cc_gen2" in group1_names

        # Test getting components in exclusion group 2
        group2_components = get_components_in_exclusion_group(sys, cc_frac, 2)
        @test length(group2_components) == 1
        @test get_name(group2_components[1]) == "cc_gen3"

        # Test error for non-existent exclusion group
        @test_throws IS.ArgumentError get_components_in_exclusion_group(sys, cc_frac, 99)
    end

    @testset "Duplicate generator rejection for CombinedCycleFractional" begin
        sys = System(100.0)

        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        cc_gen = ThermalStandard(nothing)
        cc_gen.bus = bus
        cc_gen.name = "cc_gen1"
        cc_gen.prime_mover_type = PrimeMovers.CC
        add_component!(sys, cc_gen)

        cc_frac = CombinedCycleFractional(
            name = "CC Frac",
            configuration = CombinedCycleConfiguration.SeparateShaftCombustionSteam,
        )

        add_supplemental_attribute!(sys, cc_gen, cc_frac; exclusion_group = 1)

        # Adding the same generator again should throw
        @test_throws IS.ArgumentError add_supplemental_attribute!(
            sys, cc_gen, cc_frac; exclusion_group = 1,
        )
        # Also rejects with a different exclusion group
        @test_throws IS.ArgumentError add_supplemental_attribute!(
            sys, cc_gen, cc_frac; exclusion_group = 2,
        )

        # Maps should be unchanged after rejected adds
        excl_map = get_operation_exclusion_map(cc_frac)
        @test length(excl_map) == 1
        @test length(excl_map[1]) == 1
    end

    @testset "Serialization and deserialization of CombinedCycleFractional" begin
        sys = System(100.0)

        # Create bus and generators with CC prime mover type
        bus = ACBus(nothing)
        bus.name = "bus1"
        bus.number = 1
        bus.bustype = ACBusTypes.REF
        add_component!(sys, bus)

        cc_gen1 = ThermalStandard(nothing)
        cc_gen1.bus = bus
        cc_gen1.name = "cc_frac_gen1"
        cc_gen1.prime_mover_type = PrimeMovers.CC
        add_component!(sys, cc_gen1)

        cc_gen2 = ThermalStandard(nothing)
        cc_gen2.bus = bus
        cc_gen2.name = "cc_frac_gen2"
        cc_gen2.prime_mover_type = PrimeMovers.CC
        add_component!(sys, cc_gen2)

        # Create and add combined cycle fractional plant
        cc_frac = CombinedCycleFractional(
            name = "CC Frac 1",
            configuration = CombinedCycleConfiguration.SeparateShaftCombustionSteam,
        )
        add_supplemental_attribute!(sys, cc_gen1, cc_frac; exclusion_group = 1)
        add_supplemental_attribute!(sys, cc_gen2, cc_frac; exclusion_group = 2)

        # Serialize and deserialize
        sys2, result = validate_serialization(sys)
        @test result

        # Verify plant is preserved
        gen1_restored = get_component(ThermalStandard, sys2, "cc_frac_gen1")
        @test has_supplemental_attributes(gen1_restored)
        attrs = get_supplemental_attributes(CombinedCycleFractional, gen1_restored)
        cc_frac_restored = collect(attrs)[1]
        @test get_name(cc_frac_restored) == "CC Frac 1"
        @test get_configuration(cc_frac_restored) ==
              CombinedCycleConfiguration.SeparateShaftCombustionSteam

        # Verify exclusion mappings are preserved
        excl_map = get_operation_exclusion_map(cc_frac_restored)
        inv_map = get_inverse_operation_exclusion_map(cc_frac_restored)
        @test length(excl_map) == 2
        @test length(inv_map) == 2

        gen1_restored_uuid = IS.get_uuid(gen1_restored)
        gen2_restored = get_component(ThermalStandard, sys2, "cc_frac_gen2")
        gen2_restored_uuid = IS.get_uuid(gen2_restored)

        @test gen1_restored_uuid in excl_map[1]
        @test gen2_restored_uuid in excl_map[2]
    end
end
