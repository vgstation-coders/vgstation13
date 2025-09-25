//the random offset applied to square coordinates, causes intermingling at biome borders
#define BIOME_RANDOM_SQUARE_DRIFT 1

/datum/planetGenerator
	/// Higher values of this variable result in larger biomes.
	var/perlin_zoom = 65

	/// If a turf's perlin-calculated "height" is above this value, a cave biome will be used to generate it.
	/// For best results, avoid values around 0.5; basic perlin noise can create noticeable straight-line artifacts
	/// around the midpoint value. A value of 1 or greater disables caves entirely.
	var/mountain_height = 0.85

	/// Chance for a cell in the cavegen cellular automaton to start closed
	var/initial_closed_chance = 45
	/// # of steps that the cellular automaton is run for
	var/smoothing_iterations = 20
	/// If an open (dead) cell has greater than this many neighbors, it become closed (alive).
	var/birth_limit = 4
	/// If a closed (alive) cell has fewer than this many neighbors, it will become open (dead).
	var/death_limit = 3

	/// The type of the area that will be used for all non-cave biomes.
	var/area/primary_area_type
	/// The area instance that will be used for all non-cave biomes.
	var/area/primary_area

	/// The type of the area that will be used for all cave biomes.
	var/area/cave_area_type = /area/planet/cave
	/// The area instance that will be used for all cave biomes.
	var/area/cave_area

	/// Effectively a 2D array of biomes, organized by heat categories, then humidity.
	/// Note that the heat categories are NOT all equal-size.
	var/list/biome_table

	/// A 2D array of "cave" biomes that generate at "heights" above the mountain_height variable.
	/// Like normal biomes, they are organized by heat, then humidity; however, they do NOT
	/// use the same heat categories as the normal biome table does.
	var/list/cave_biome_table

	// temporary internal vars for the perlin noise
	var/height_seed
	var/humidity_seed
	var/heat_seed

	// temporary internal var used during planet generation to store the output of the cave-automaton
	var/string_gen

	// temporary internal lists, storing created features / mobs to speedup spawning
	// it takes too long to look at nearby turfs, so we just store them and then
	// iterate through the list when we want to see if there is anything nearby.
	// yes, this does mean that creatures / features can spawn adjacent to ones mapped into ruins
	// this is unfortunate, but mostly irrelevant
	var/list/created_features
	var/list/created_mobs

	// Temporary associative list matching generated turfs to biomes. Used to get
	// a turf's biome for populating it without having to recalculate (which is impossible, due to drift)
	var/list/turf_biome_cache

	// Merged loot table this planet uses to spawn loot
	var/datum/loot_table/planet_loot

/datum/planetGenerator/New()
	// initialize the perlin seeds
	height_seed = rand(0, 50000)
	humidity_seed = rand(0, 50000)
	heat_seed = rand(0, 50000)
	if(mountain_height < 1)
		//Generate the raw CA data
		// This generates a CA for the entire game map, which is sort of inefficient, but not too big a deal.
		string_gen = rustg_cnoise_generate("[initial_closed_chance]", "[smoothing_iterations]", "[birth_limit]", "[death_limit]", "[100]", "[100]")
	primary_area = new primary_area_type
	cave_area = new cave_area_type

	turf_biome_cache = list()
	return ..()

/datum/planetGenerator/proc/generate_turfs(var/list/turfs)
	for(var/turf/T in turfs)
		generate_turf(T)
		CHECK_TICK

/datum/planetGenerator/proc/generate_turf(turf/gen_turf)
	var/area/A = get_area(gen_turf)
	if(!(A.flags & CAVES_ALLOWED))
		return

	var/datum/biome/turf_biome = get_biome(gen_turf)

	// using istype() here suuuuucks, i'm sorry.
	var/area/used_area = istype(turf_biome, /datum/biome/cave) ? cave_area : primary_area
	turf_biome.generate_turf(gen_turf, used_area, string_gen)

/datum/planetGenerator/proc/populate_turfs(var/list/turfs)
	created_features = list()
	created_mobs = list()
	for(var/turf/T in turfs)
		populate_turf(T)
		CHECK_TICK
	// clear the lists, so we don't get harddels
	created_features = null
	created_mobs = null

/datum/planetGenerator/proc/populate_turf(turf/gen_turf)
/* 	var/area/A = gen_turf.loc
	if(!(A.flags & CAVES_ALLOWED))
		return */

	var/datum/biome/turf_biome = get_biome(gen_turf)
	turf_biome.populate_turf(gen_turf, created_features, created_mobs, planet_loot)

/// Checks the turf biome cache for the biome of the passed turf; if none is found, it is generated.
/datum/planetGenerator/proc/get_biome(turf/a_turf)
	// if it's in the turf biome cache, just return that
	if(turf_biome_cache[a_turf])
		return turf_biome_cache[a_turf]

	// random offset coordinates to fuzz biome borders.
	// not actually huge on this for several reasons but it works alright to cover up small perlin artifacts
	var/drift_x = (a_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
	var/drift_y = (a_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

	var/heat_level
	var/humidity_level

	var/datum/biome/sel_biome

	// gets humidity
	var/humidity = rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]")
	switch(text2num(humidity))
		if(0 to 0.20)
			humidity_level = BIOME_LOWEST_HUMIDITY
		if(0.20 to 0.40)
			humidity_level = BIOME_LOW_HUMIDITY
		if(0.40 to 0.60)
			humidity_level = BIOME_MEDIUM_HUMIDITY
		if(0.60 to 0.80)
			humidity_level = BIOME_HIGH_HUMIDITY
		if(0.80 to 1)
			humidity_level = BIOME_HIGHEST_HUMIDITY

	// gets heat. we index the biome lists with heat first, but the one we use depends on the height
	// so we do the humidity first 'cause it's easier that way
	var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))

	// gets height
	if(text2num(rustg_noise_get_at_coordinates("[height_seed]", "[drift_x]", "[drift_y]")) <= mountain_height)
		switch(heat)
			if(0 to 0.20)
				heat_level = BIOME_COLDEST
			if(0.20 to 0.40)
				heat_level = BIOME_COLD
			if(0.40 to 0.60)
				heat_level = BIOME_WARM
			if(0.60 to 0.65)
				heat_level = BIOME_TEMPERATE
			if(0.65 to 0.80)
				heat_level = BIOME_HOT
			if(0.80 to 1)
				heat_level = BIOME_HOTTEST

		sel_biome = SSmapping.biomes[biome_table[heat_level][humidity_level]]
	else
		switch(heat)
			if(0 to 0.25)
				heat_level = BIOME_COLDEST_CAVE
			if(0.25 to 0.5)
				heat_level = BIOME_COLD_CAVE
			if(0.5 to 0.75)
				heat_level = BIOME_WARM_CAVE
			if(0.75 to 1)
				heat_level = BIOME_HOT_CAVE

		sel_biome = SSmapping.biomes[cave_biome_table[heat_level][humidity_level]]

	turf_biome_cache[a_turf] = sel_biome
	return sel_biome

/datum/planetGenerator/proc/setup_loot_tables(var/datum/planet_type/planet)
	var/list/loots = list()
	for(var/lt_type in subtypesof(/datum/loot_table))
		var/datum/loot_table/T = new lt_type
		if(T.loot_flags & planet.loot_type)
			loots += T
	var/datum/loot_table/merged_loot = merge_loot_table(arglist(loots))
	merged_loot.roll_mod = planet.loot_modifier
	planet_loot = merged_loot

#undef BIOME_RANDOM_SQUARE_DRIFT
