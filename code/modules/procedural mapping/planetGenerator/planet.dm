//the random offset applied to square coordinates, causes intermingling at biome borders
#define BIOME_RANDOM_SQUARE_DRIFT 1

// Perlin noise value ranges
#define PERLIN_NOISE_MIN 0
#define PERLIN_NOISE_MAX 1

// Humidity thresholds
#define HUMIDITY_THRESHOLD_LOW 0.20
#define HUMIDITY_THRESHOLD_MEDIUM_LOW 0.40
#define HUMIDITY_THRESHOLD_MEDIUM_HIGH 0.60
#define HUMIDITY_THRESHOLD_HIGH 0.80

// Standard heat level thresholds (for surface biomes)
#define HEAT_THRESHOLD_COLD 0.20
#define HEAT_THRESHOLD_WARM 0.40
#define HEAT_THRESHOLD_TEMPERATE_LOW 0.60
#define HEAT_THRESHOLD_TEMPERATE_HIGH 0.65
#define HEAT_THRESHOLD_HOT 0.80

// Cave heat level thresholds
#define CAVE_HEAT_THRESHOLD_COLD 0.25
#define CAVE_HEAT_THRESHOLD_WARM 0.5
#define CAVE_HEAT_THRESHOLD_HOT 0.75


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
	var/area/planet/primary_area_type
	/// The area instance that will be used for all non-cave biomes.
	var/area/planet/primary_area

	/// The type of the area that will be used for all cave biomes.
	var/area/planet/cave_area_type = /area/planet/cave
	/// The area instance that will be used for all cave biomes.
	var/area/planet/cave_area

	/// Effectively a 2D array of biomes, organized by heat categories, then humidity.
	/// Note that the heat categories are NOT all equal-size.
	var/list/biome_table

	/// A 2D array of "cave" biomes that generate at "heights" above the mountain_height variable.
	/// Like normal biomes, they are organized by heat, then humidity; however, they do NOT
	/// use the same heat categories as the normal biome table does.
	var/list/cave_biome_table

	/// Perlin noise seed for height generation
	var/height_seed
	/// Perlin noise seed for humidity generation
	var/humidity_seed
	/// Perlin noise seed for heat/temperature generation
	var/heat_seed

	/// Cellular automaton output string used during cave generation
	var/cave_automaton_data

	/// Temporary list storing features created during population phase (cleared after use)
	var/list/created_features = list()
	/// Temporary list storing mobs created during population phase (cleared after use)
	var/list/created_mobs = list()

	/// Cache mapping turfs to their calculated biomes to avoid recalculation
	var/list/turf_biome_cache

	/// Merged loot table used for spawning loot on this planet
	var/datum/loot_table/planet_loot

	/// Number of gas vents present on the planet
	var/vent_count = 0

	/// Expanded weighted list of ruins for this planet's type
	var/list/weighted_ruin_list = list()
	var/spawned_story_ruin = FALSE

/datum/planetGenerator/New()
	// Initialize perlin noise seeds with random values
	height_seed = rand(0, 50000)
	humidity_seed = rand(0, 50000)
	heat_seed = rand(0, 50000)

	// Generate cellular automaton data for caves if they are enabled
	if(mountain_height < 1)
		cave_automaton_data = rustg_cnoise_generate("[initial_closed_chance]", "[smoothing_iterations]", "[birth_limit]", "[death_limit]", "[SECTOR_SIZE]", "[SECTOR_SIZE]")

	// Initialize area instances
	primary_area = new primary_area_type
	cave_area = new cave_area_type

	// Initialize the biome cache
	turf_biome_cache = list()

	vent_count = rand(0,5)
	return ..()

/datum/planetGenerator/proc/generate_turf(turf/gen_turf)
	var/area/turf_area = get_area(gen_turf)
	if(!(turf_area.flags & CAVES_ALLOWED))
		return

	var/datum/biome/turf_biome = get_biome(gen_turf)

	// Determine which area to use based on biome type
	var/area/used_area = istype(turf_biome, /datum/biome/cave) ? cave_area : primary_area
	turf_biome.generate_turf(gen_turf, used_area, cave_automaton_data)

/datum/planetGenerator/proc/populate_turf(turf/gen_turf, created_features, created_mobs, planet_loot, planet_faction = null)
	var/datum/biome/turf_biome = get_biome(gen_turf)
	turf_biome.populate_turf(gen_turf, created_features, created_mobs, planet_loot, planet_faction)

/datum/planetGenerator/proc/post_process(datum/allocation/allocation)
	if(vent_count <= 0)
		return
	var/checked_turfs = 0
	while(vent_count > 0)
		var/turf/unsimulated/T = pick(allocation.turfs)
		if(!istype(T))
			continue
		var/area/A = get_area(T)
		if(isopensurface(A) || (istype(A, /area/planet/cave) && !iswall(T)))
			var/datum/vent/newvent = new /datum/vent(T)
			vent_count -= 1
			allocation.ptype.vents += newvent
		checked_turfs++
		if(checked_turfs > 100) //arbitrary limit to prevent infinite loops
			break
	return

/// Gets the biome for a turf, using the cache if available, otherwise calculating and caching it.
/// Returns: The datum/biome for the given turf
/datum/planetGenerator/proc/get_biome(turf/a_turf)
	// Check cache first to avoid recalculation
	if(turf_biome_cache[a_turf])
		return turf_biome_cache[a_turf]

	// Apply random offset to coordinates to create fuzzy biome borders and hide perlin artifacts
	var/drift_x = (a_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
	var/drift_y = (a_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

	var/heat_level
	var/humidity_level

	var/datum/biome/sel_biome

	// Calculate humidity level from perlin noise
	var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]"))
	switch(humidity)
		if(PERLIN_NOISE_MIN to HUMIDITY_THRESHOLD_LOW)
			humidity_level = BIOME_LOWEST_HUMIDITY
		if(HUMIDITY_THRESHOLD_LOW to HUMIDITY_THRESHOLD_MEDIUM_LOW)
			humidity_level = BIOME_LOW_HUMIDITY
		if(HUMIDITY_THRESHOLD_MEDIUM_LOW to HUMIDITY_THRESHOLD_MEDIUM_HIGH)
			humidity_level = BIOME_MEDIUM_HUMIDITY
		if(HUMIDITY_THRESHOLD_MEDIUM_HIGH to HUMIDITY_THRESHOLD_HIGH)
			humidity_level = BIOME_HIGH_HUMIDITY
		if(HUMIDITY_THRESHOLD_HIGH to PERLIN_NOISE_MAX)
			humidity_level = BIOME_HIGHEST_HUMIDITY

	// Calculate heat level from perlin noise
	var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))

	// Calculate height to determine if this is a cave or surface biome
	var/height = text2num(rustg_noise_get_at_coordinates("[height_seed]", "[drift_x]", "[drift_y]"))
	var/is_cave = height > mountain_height

	if(!is_cave)
		// Surface biome heat calculation
		switch(heat)
			if(PERLIN_NOISE_MIN to HEAT_THRESHOLD_COLD)
				heat_level = BIOME_COLDEST
			if(HEAT_THRESHOLD_COLD to HEAT_THRESHOLD_WARM)
				heat_level = BIOME_COLD
			if(HEAT_THRESHOLD_WARM to HEAT_THRESHOLD_TEMPERATE_LOW)
				heat_level = BIOME_WARM
			if(HEAT_THRESHOLD_TEMPERATE_LOW to HEAT_THRESHOLD_TEMPERATE_HIGH)
				heat_level = BIOME_TEMPERATE
			if(HEAT_THRESHOLD_TEMPERATE_HIGH to HEAT_THRESHOLD_HOT)
				heat_level = BIOME_HOT
			if(HEAT_THRESHOLD_HOT to PERLIN_NOISE_MAX)
				heat_level = BIOME_HOTTEST

		sel_biome = SSmapping.biomes[biome_table[heat_level][humidity_level]]
	else
		// Cave biome heat calculation
		switch(heat)
			if(PERLIN_NOISE_MIN to CAVE_HEAT_THRESHOLD_COLD)
				heat_level = BIOME_COLDEST_CAVE
			if(CAVE_HEAT_THRESHOLD_COLD to CAVE_HEAT_THRESHOLD_WARM)
				heat_level = BIOME_COLD_CAVE
			if(CAVE_HEAT_THRESHOLD_WARM to CAVE_HEAT_THRESHOLD_HOT)
				heat_level = BIOME_WARM_CAVE
			if(CAVE_HEAT_THRESHOLD_HOT to PERLIN_NOISE_MAX)
				heat_level = BIOME_HOT_CAVE

		sel_biome = SSmapping.biomes[cave_biome_table[heat_level][humidity_level]]

	turf_biome_cache[a_turf] = sel_biome
	return sel_biome

#undef BIOME_RANDOM_SQUARE_DRIFT
#undef PERLIN_NOISE_MIN
#undef PERLIN_NOISE_MAX
#undef HUMIDITY_THRESHOLD_LOW
#undef HUMIDITY_THRESHOLD_MEDIUM_LOW
#undef HUMIDITY_THRESHOLD_MEDIUM_HIGH
#undef HUMIDITY_THRESHOLD_HIGH
#undef HEAT_THRESHOLD_COLD
#undef HEAT_THRESHOLD_WARM
#undef HEAT_THRESHOLD_TEMPERATE_LOW
#undef HEAT_THRESHOLD_TEMPERATE_HIGH
#undef HEAT_THRESHOLD_HOT
#undef CAVE_HEAT_THRESHOLD_COLD
#undef CAVE_HEAT_THRESHOLD_WARM
#undef CAVE_HEAT_THRESHOLD_HOT
