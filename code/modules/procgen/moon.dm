/datum/procedural_generator/moon
	name = "Moon"
	valid_map_sizes = list(PG_SMALL, PG_MEDIUM)
	weight = PG_MOON_WEIGHT
	valid_altitudes = list(PG_LOW_ALT)
	valid_water_levels = list(PG_NO_WATER)
	valid_biomes = list(PG_PERMAFROST, PG_ICE_SHEET, PG_ROCK, PG_MAGMA, PG_ASH)
	valid_atmospheres = list(PG_VACUUM, PG_THIN)
	valid_civs = list(PG_UNEXPLORED, PG_YOUNG_CIV)

//Moons use pure worley noise with no cave or water generation.
/datum/procedural_generator/moon/generate_heightmap()
	var/wstring = rustg_worley_generate("20", "10", "50", "[map_size]", "2", "5")
	var/value
	var/noise_string
	for(var/i = 1 to map_size*map_size)
		value = text2num(wstring[i])
		noise_string += 6 * num2text(value)

	return noise_string
