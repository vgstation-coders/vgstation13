/datum/procedural_generator/asteroid
	name = "Asteroid"
	valid_map_sizes = list(PG_SMALL)
	weight = PG_ASTEROID_WEIGHT
	stamp = 20

	valid_altitudes = list(PG_HIGH_ALT)
	valid_waters = list(PG_NO_WATER)
	valid_biomes = list(PG_ASTEROID, PG_COMET)
	valid_atmospheres = list(PG_VACUUM)
	valid_civs = list(PG_UNEXPLORED)
