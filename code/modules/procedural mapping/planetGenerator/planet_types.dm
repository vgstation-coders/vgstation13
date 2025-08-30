/datum/planet_type
	///The name we show on examine
	var/name = "planet"
	///The description we show on examine
	var/desc = "A planet."
	///The ID  tag for the set of ruins this planet uses
	var/ruin_type = null
	///The mapgen we set when we are used
	var/mapgen = null
	///The fallback turf if mapgen fails.
	var/default_baseturf = null
	///Our weight when picking a new planet.
	var/weight = 40
	///Customizable planet names.
	var/planet_name

/datum/planet_type/beach
	name = "beach planetoid"
	desc = "The platonic ideal of vacation spots. Warm, comfortable temperatures, and a breathable atmosphere."
	mapgen = /datum/planetGenerator/beach
	default_baseturf = /turf/unsimulated/beach/sand
	ruin_type = RUINTYPE_BEACH

/datum/planet_type/desert
	name = "desert planetoid"
	desc = "A very weak energy signal originating from a very hot and harsh planet."
	mapgen = /datum/planetGenerator/desert
	default_baseturf = /turf/simulated/floor/plating/ironsand
	ruin_type = RUINTYPE_LAVA

/datum/planet_type/grass
	name = "grass planetoid"
	desc = "A temperate planet with a breathable atmosphere and abundant flora and fauna."
	mapgen = /datum/planetGenerator/grass
	default_baseturf = /turf/unsimulated/floor/grass
	ruin_type = RUINTYPE_LAVA

/datum/planet_type/jungle
	name = "jungle planetoid"
	desc = "A hot, humid planet teeming with exotic flora and fauna."
	mapgen = /datum/planetGenerator/jungle
	default_baseturf = /turf/unsimulated/floor/jungle/grass
	ruin_type = RUINTYPE_LAVA

/datum/planet_type/lava
	name = "lava planetoid"
	desc = "A planet rife with seismic and volcanic activity. High temperatures and dangerous xenofauna render it dangerous for the unprepared."
	mapgen = /datum/planetGenerator/lava
	default_baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava
	ruin_type = RUINTYPE_LAVA

/datum/planet_type/snow
	name = "frozen planetoid"
	desc = "A frozen planet covered in thick snow, thicker ice, and dangerous predators."
	mapgen = /datum/planetGenerator/snow
	default_baseturf = /turf/unsimulated/floor/snow
	ruin_type = RUINTYPE_SNOW

/datum/planet_type/xeno
	name = "unknown planetoid"
	desc = "A distress signal eminates from this planetoid."
	mapgen = /datum/planetGenerator/xeno
	default_baseturf = /turf/unsimulated/floor/grey_sand
	ruin_type = RUINTYPE_XENO
