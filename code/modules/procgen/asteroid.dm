/datum/procedural_generator/asteroid
	name = "Asteroid"
	valid_map_sizes = list(PG_SMALL)
	weight = PG_ASTEROID_WEIGHT

	valid_altitudes = list(PG_HIGH_ALT)
	valid_water_levels = list(PG_NO_WATER)
	valid_biomes = list(PG_ASTEROID, PG_COMET)
	valid_atmospheres = list(PG_VACUUM)
	valid_civs = list(PG_UNEXPLORED)

/datum/procedural_generator/asteroid/generate_heightmap()
	var/wstring = rustg_worley_generate("20", "10", "50", "[map_size]", "2", "5")
	var/value
	var/noise_string
	for(var/i = 1 to map_size*map_size)
		value = text2num(wstring[i])
		noise_string += 6 * num2text(value)

	return noise_string
