# Procedural Planet Generation System

This system allows for the creation of procedurally generated planets with customizable biomes, terrain, flora, fauna, and environmental features.

## Overview

The planet generation system uses Perlin noise and cellular automata to create diverse, varied planets with multiple biomes that blend naturally. Each planet type has both surface and cave biomes that are selected based on temperature and humidity values.

## How to Add a New Planet Type

### 1. Create a Planet Generator File

Create a new file in `code/modules/procedural mapping/planetGenerator/generators/` named after your planet type (e.g., `myplanet.dm`).

### 2. Define the Planet Generator

Create a new `/datum/planetGenerator` subtype:

```dm
/datum/planetGenerator/myplanet
	mountain_height = 0.8     // 0.0-1.0, higher = less caves
	perlin_zoom = 65          // Higher = larger biomes

	primary_area_type = /area/planet/myplanet

	biome_table = list(
		// Define biomes by temperature (rows) and humidity (columns)
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/myplanet/cold_dry,
			BIOME_LOW_HUMIDITY = /datum/biome/myplanet/cold,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/myplanet/cold_wet,
			BIOME_HIGH_HUMIDITY = /datum/biome/myplanet/cold_very_wet,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/myplanet/cold_wettest
		),
		BIOME_COLD = list(
			// ... similar structure
		),
		BIOME_WARM = list(
			// ... similar structure
		),
		BIOME_TEMPERATE = list(
			// ... similar structure
		),
		BIOME_HOT = list(
			// ... similar structure
		),
		BIOME_HOTTEST = list(
			// ... similar structure
		)
	)

	cave_biome_table = list(
		// Define cave biomes by temperature and humidity
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/myplanet/cold,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/myplanet,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/myplanet,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/myplanet/wet,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/myplanet/wettest
		),
		// ... BIOME_COLD_CAVE, BIOME_WARM_CAVE, BIOME_HOT_CAVE
	)
```

### 3. Define Surface Biomes

Each biome in your `biome_table` needs to be defined:

```dm
/datum/biome/myplanet
	open_turf_types = list(/turf/unsimulated/floor/planetary/myplanet = 1)

	flora_spawn_list = list(
		/obj/structure/flora/tree/palm = 5,
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/ausbushes/fullgrass = 15,
	)
	flora_spawn_chance = 25  // Percentage chance per tile

	mob_spawn_list = list(
		/mob/living/simple_animal/mouse = 20,
		/mob/living/simple_animal/rabbit = 30,
		/mob/living/simple_animal/hostile/bear = 5,
	)
	mob_spawn_chance = 2  // Percentage chance per tile

	feature_spawn_list = list(
		/obj/structure/geyser = 1,
		/obj/structure/flora/tree/dead/tall = 3,
	)
	feature_spawn_chance = 1  // Percentage chance per tile

	loot_spawners = list(
		/obj/abstract/loot_spawner/trash = 3,
		/obj/abstract/loot_spawner/food_or_drink = 2,
		/obj/abstract/loot_spawner/engineering = 1,
	)
	loot_spawn_chance = 1  // Percentage chance per tile
```

**Key Parameters:**
- `open_turf_types`: Weighted list of turfs this biome places
- `flora_spawn_list`: Weighted list of flora that can spawn
- `flora_spawn_chance`: Percentage (0-100) chance for flora to spawn on each tile
- `mob_spawn_list`: Weighted list of mobs that can spawn
- `mob_spawn_chance`: Percentage chance for mobs to spawn
- `feature_spawn_list`: Weighted list of features (large objects with distance restrictions)
- `feature_spawn_chance`: Percentage chance for features to spawn
- `loot_spawners`: Weighted list of loot spawner types
- `loot_spawn_chance`: Percentage chance for loot to spawn

### 4. Define Cave Biomes

Cave biomes extend `/datum/biome/cave` and require both open and closed turfs:

```dm
/datum/biome/cave/myplanet
	open_turf_types = list(/turf/unsimulated/floor/planetary/cave = 1)
	closed_turf_types = list(/turf/unsimulated/mineral/random/cave = 1)

	flora_spawn_list = list(
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/rock/pile = 5,
	)
	flora_spawn_chance = 10

	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/basilisk = 10,
		/mob/living/simple_animal/cockroach = 20,
	)
	mob_spawn_chance = 2

	loot_spawners = list(
		/obj/abstract/loot_spawner/medical = 2,
		/obj/abstract/loot_spawner/engineering = 2,
		/obj/abstract/loot_spawner/combat = 1,
	)
	loot_spawn_chance = 2  // Cave loot spawns more frequently
```

### 5. Register the Planet Type

Add an entry to `code/modules/procedural mapping/planetGenerator/planet_types.dm`:

```dm
/datum/planet_type/myplanet
	name = "my planet type"
	desc = "A description of your planet that players will see when examining it."
	mapgen = /datum/planetGenerator/myplanet
	default_baseturf = /turf/unsimulated/floor/planetary/myplanet
	loot_type = LOOT_TYPE_MYPLANET  // Define this constant if needed
	climate_type = CLIMATE_TEMPERATE  // Or another appropriate climate
	loot_modifier = 0  // Bonus added to loot rolls (0-20)
	icon_state = "earth"  // Icon from planet scanner icons
```

**Planet Type Parameters:**
- `name`: Internal name
- `desc`: Description shown to players
- `mapgen`: Your planet generator datum
- `default_baseturf`: Fallback turf if generation fails
- `loot_type`: Type of loot this planet spawns (optional)
- `climate_type`: Climate datum for temperature effects
- `loot_modifier`: Bonus value added to loot rolls (higher = better loot)
- `icon_state`: Icon shown in planet scanner UI

### 6. Create Required Turfs

Ensure all turf types referenced in your biomes exist. Create them if needed in the appropriate turf definition files.

### 7. Create Area Types

Define the area type(s) for your planet in `code/modules/procedural mapping/planetGenerator/area.dm`:

```dm
/area/planet/myplanet
	name = "My Planet Surface"
	icon_state = "explored"
	flags = CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED
```

## Biome Distribution

The system uses Perlin noise to generate temperature and humidity maps. Each tile's biome is selected from the `biome_table` based on:

**Temperature Bands (Surface):**
- BIOME_COLDEST: < 0.20
- BIOME_COLD: 0.20 - 0.40
- BIOME_WARM: 0.40 - 0.60
- BIOME_TEMPERATE: 0.60 - 0.65
- BIOME_HOT: 0.65 - 0.80
- BIOME_HOTTEST: > 0.80

**Humidity Bands:**
- BIOME_LOWEST_HUMIDITY: < 0.20
- BIOME_LOW_HUMIDITY: 0.20 - 0.40
- BIOME_MEDIUM_HUMIDITY: 0.40 - 0.60
- BIOME_HIGH_HUMIDITY: 0.60 - 0.80
- BIOME_HIGHEST_HUMIDITY: > 0.80

**Cave Temperature Bands:**
- BIOME_COLDEST_CAVE: < 0.25
- BIOME_COLD_CAVE: 0.25 - 0.50
- BIOME_WARM_CAVE: 0.50 - 0.75
- BIOME_HOT_CAVE: > 0.75

## Generation Parameters

### Planet Generator Variables

- `perlin_zoom` (default: 65): Controls biome size. Higher values = larger biomes
- `mountain_height` (default: 0.85): Threshold for cave generation (0.0-1.0). Higher = fewer caves. Set to 1.0+ to disable caves entirely
- `initial_closed_chance` (default: 45): Percentage of cave cells that start as walls in cellular automaton
- `smoothing_iterations` (default: 20): Number of cellular automaton passes for cave smoothing
- `birth_limit` (default: 4): Neighbors needed for an open cell to become a wall
- `death_limit` (default: 3): Minimum neighbors for a wall cell to stay solid

### Spawn Distribution

**Flora**: Spawn independently with no distance restrictions. Use for grass, bushes, rocks, etc.

**Features**: Large objects with distance restrictions. Features of the same type won't spawn within 7 tiles of each other. Use for geysers, large trees, etc.

**Mobs**:
- Hostile mobs won't spawn within 12 tiles of other hostile mobs or spawners
- Spawners won't spawn within 2 tiles of other spawners
- Peaceful mobs can spawn freely

**Loot**: Spawns on valid tiles with no distance restrictions. Cave loot is more common than surface loot.

## Examples

See existing planet types for reference:
- [grass.dm](planetGenerator/generators/grass.dm) - Temperate planet with varied biomes
- [beach.dm](planetGenerator/generators/beach.dm) - Tropical beach planet with ocean biomes
- [desert.dm](planetGenerator/generators/desert.dm) - Simple desert planet with minimal variation
- [snow.dm](planetGenerator/generators/snow.dm) - Frozen planet with ice biomes
- [lava.dm](planetGenerator/generators/lava.dm) - Volcanic planet with lava rivers

## Tips

1. **Start Simple**: Begin with a basic biome setup and add complexity gradually
2. **Balance Spawn Chances**: Keep spawn chances low (1-5%) for features and mobs to avoid overcrowding
3. **Test Cave Generation**: Adjust `mountain_height` to control how many caves generate
4. **Use Weighted Lists**: Higher weights = more common spawns. All lists are weighted
5. **Consider Performance**: Too many spawns can cause lag. Balance visual density with performance
6. **Reuse Biomes**: You can reference the same biome multiple times in your table for consistency
7. **Test All Biomes**: Make sure every combination in your biome_table is defined to avoid runtime errors

## Troubleshooting

**Issue**: Biomes all look the same
- **Solution**: Increase variety in your `biome_table` or lower `perlin_zoom` for smaller biomes

**Issue**: Too many/few caves
- **Solution**: Adjust `mountain_height` (higher = fewer caves)

**Issue**: Caves are too chaotic/smooth
- **Solution**: Adjust `smoothing_iterations`, `birth_limit`, and `death_limit`

**Issue**: Runtime errors during generation
- **Solution**: Ensure all biome paths in your tables are defined and all referenced turfs exist

**Issue**: Empty planet
- **Solution**: Check that spawn_chance values are set and spawn lists contain valid paths
