/datum/planet_type
	///The name we show on examine
	var/name = "planet"
	///The description we show on examine
	var/desc = "A planet."
	///The ID tag for the set of ruins and loot tables this planet uses
	var/ruin_type = null
	///The mapgen we set when we are used
	var/mapgen = null
	///The fallback turf if mapgen fails.
	var/default_baseturf = null
	///Our weight when picking a new planet.
	var/weight = 40
	///Customizable planet names.
	var/planet_name
	// The type of loot this planet can spawn
	var/loot_type
	//Climate datum
	var/datum/climate/climate
	var/climate_type = CLIMATE_NONE
	//Value that gets added to loot rolls on this planet.
	var/loot_modifier = 0

/datum/planet_type/New()
	..()
	if(climate_type)
		climate = new climate_type

/datum/planet_type/beach
	name = "beach planetoid"
	desc = "The platonic ideal of vacation spots. Warm, comfortable temperatures, and a breathable atmosphere."
	mapgen = /datum/planetGenerator/beach
	default_baseturf = /turf/unsimulated/beach/sand
	ruin_type = RUINTYPE_BEACH
	loot_type = LOOT_TYPE_BEACH
	climate_type = CLIMATE_TROPICAL

/datum/planet_type/desert
	name = "desert planetoid"
	desc = "A very weak energy signal originating from a very hot and harsh planet."
	mapgen = /datum/planetGenerator/desert
	default_baseturf = /turf/simulated/floor/plating/ironsand
	ruin_type = RUINTYPE_LAVA
	loot_type = LOOT_TYPE_DESERT
	climate_type = CLIMATE_DESERT
	loot_modifier = 5

/datum/planet_type/grass
	name = "grass planetoid"
	desc = "A temperate planet with a breathable atmosphere and abundant flora and fauna."
	mapgen = /datum/planetGenerator/grass
	default_baseturf = /turf/unsimulated/floor/grass
	ruin_type = RUINTYPE_LAVA
	loot_type = LOOT_TYPE_GRASS
	climate_type = CLIMATE_TEMPERATE

/datum/planet_type/jungle
	name = "jungle planetoid"
	desc = "A hot, humid planet teeming with exotic flora and fauna."
	mapgen = /datum/planetGenerator/jungle
	default_baseturf = /turf/unsimulated/floor/jungle/grass
	ruin_type = RUINTYPE_LAVA
	loot_type = LOOT_TYPE_JUNGLE
	climate_type = CLIMATE_TROPICAL
	loot_modifier = 10

/datum/planet_type/lava
	name = "lava planetoid"
	desc = "A planet rife with seismic and volcanic activity. High temperatures and dangerous xenofauna render it dangerous for the unprepared."
	mapgen = /datum/planetGenerator/lava
	default_baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava
	ruin_type = RUINTYPE_LAVA
	loot_type = LOOT_TYPE_LAVA
	climate_type = CLIMATE_LAVA
	loot_modifier = 15

/datum/planet_type/snow
	name = "frozen planetoid"
	desc = "A frozen planet covered in thick snow, thicker ice, and dangerous predators."
	mapgen = /datum/planetGenerator/snow
	default_baseturf = /turf/unsimulated/floor/snow
	ruin_type = RUINTYPE_SNOW
	loot_type = LOOT_TYPE_SNOW
	climate_type = CLIMATE_ARCTIC
	loot_modifier = 5

/datum/planet_type/urban
	name = "wasteland planetoid"
	desc = "A desolate, toxic world littered with the remnants of a long-gone civilization and the conflict that ended it."
	mapgen = /datum/planetGenerator/urban
	default_baseturf = /turf/unsimulated/wasteland
	ruin_type = RUINTYPE_URBAN
	loot_type = LOOT_TYPE_URBAN
	climate_type = CLIMATE_DESERT
	loot_modifier = 10

/datum/planet_type/xeno
	name = "unknown planetoid"
	desc = "A distress signal eminates from this planetoid."
	mapgen = /datum/planetGenerator/xeno
	default_baseturf = /turf/unsimulated/floor/grey_sand
	ruin_type = RUINTYPE_XENO
	loot_type = LOOT_TYPE_XENO
	climate_type = CLIMATE_XENO
	loot_modifier = 20
