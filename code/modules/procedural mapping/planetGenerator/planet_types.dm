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


/datum/planet_type/desert
	name = "deset planetoid"
	desc = "A very weak energy signal originating from a very hot and harsh planet."
	mapgen = /datum/planetGenerator/desert
	default_baseturf = /turf/simulated/floor/plating/ironsand
	ruin_type = RUINTYPE_LAVA
