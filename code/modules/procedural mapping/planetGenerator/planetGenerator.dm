/*
The Planet Generator module procedurally generates a new z-level with various features for exploration via the gateway.
Generation steps:
1. Generation is kicked off using the Gateway Horizon Scanner.
2. A new z-level is created and a planet type is picked (planetoid, asteroid, moon).
3. Each planet type has its own list of features defined in their respective files.
4. The features are randomly selected and placed on the planet using Perlin noise.
5. The planet is then populated with various objects, including ores, plants, and other entities.
6. Atmos is then assigned based on the planet type.
7. Finally, the planet is added to the map and made available for exploration.
*/

#define ATMOS_PLANETOID	0
#define ATMOS_ASTEROID	1
#define ATMOS_MOON		2

/datum/planetGenerator
	var/list/planet_types = list(
		/datum/planet/planetoid,
		/datum/planet/asteroid,
		/datum/planet/moon
	)

/datum/planet
	var/atmos_type
	var/chance_to_generate
	var/list/biomes = list()
