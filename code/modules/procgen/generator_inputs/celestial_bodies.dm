/datum/procgen/space_object
	var/list/valid_atmospheres = list()
	var/datum/procgen/atmosphere/atmos
	var/list/valid_biomes = list()
	var/weight
	var/list/valid_map_sizes = list()
	var/heightmap_amplification = 0 //how likely this planet is to be mountainous

	var/list/voronoi_matrix = list()

/datum/procgen/space_object/proc/initialize_planet()
	atmos = get_atmosphere()

/datum/procgen/space_object/proc/get_atmosphere()
	var/datum/procgen/atmosphere/A = pick(valid_atmospheres)
	A.initialize_atmosphere()
	return A

/datum/procgen/space_object/proc/generate_biome_map(var/m_size)
	var/num_seeds
	switch(m_size)
		if(PG_SMALL)
			num_seeds = rand(2,4)
		if(PG_MEDIUM)
			num_seeds = rand(3,8)
		if(PG_LARGE)
			num_seeds = rand(4,16)
	voronoi_matrix = generate_voronoi(m_size,num_seeds)
	label_biomes()

/datum/procgen/space_object/proc/label_biomes()
    var/list/id_to_biome_map = list()
    var/list/available_biomes = valid_biomes.Copy()

    for (var/id in unique_ids(voronoi_matrix))
        var/biome = pick(available_biomes)
        id_to_biome_map[id] = biome

    // Replace each ID in the matrix with the corresponding name
    for (var/x = 1 to length(voronoi_matrix))
        for (var/y = 1 to length(voronoi_matrix[x]))
            var/id = voronoi_matrix[x][y]
            voronoi_matrix[x][y] = id_to_biome_map[id]

/datum/procgen/space_object/proc/unique_ids(voronoi_matrix)
    var/list/ids = list()

    for (var/x = 1 to length(voronoi_matrix))
        for (var/y = 1 to length(voronoi_matrix[x]))
            var/id = voronoi_matrix[x][y]
            if (!ids[id]) // Add the ID only if it's not already in the list
                ids += id
    return ids

/datum/procgen/space_object/asteroids
	name = "Asteroid Field"
	desc = "One or more asteroids floating through space."
	valid_atmospheres = list(PG_VACUUM)
	valid_biomes = list(PG_ASTEROID, PG_COMET)
	weight = PG_ASTEROID_WEIGHT
	valid_map_sizes = list(PG_SMALL)
	heightmap_amplification = PG_HIGH_ALT

/datum/procgen/space_object/moon
	name = "Moon"
	desc = "A lifeless mass of rock, lava, or ice."
	valid_atmospheres = list(PG_VACUUM, PG_THIN)
	valid_biomes = list(PG_PERMAFROST, PG_ICE_SHEET, PG_ROCK, PG_MAGMA, PG_ASH)
	weight = PG_MOON_WEIGHT
	valid_map_sizes = list(PG_SMALL, PG_MEDIUM)
	heightmap_amplification = PG_LOW_ALT

/datum/procgen/space_object/planet
	name = "Planet"
	desc = "A planet which may contain an atmosphere, flora, and fauna."
	valid_atmospheres = list(PG_THIN, PG_BREATHABLE)
	valid_biomes = list(PG_PERMAFROST, PG_ICE_SHEET, PG_TUNDRA, PG_FOREST, PG_PLAINS, PG_SHRUBLAND, PG_SWAMPLAND, PG_RAINFOREST, PG_SAVANNA, PG_DESERT, PG_MAGMA, PG_ASH)
	weight = PG_PLANET_WEIGHT
	valid_map_sizes = list(PG_MEDIUM, PG_LARGE)
	heightmap_amplification = PG_MED_ALT

/datum/procgen/space_object/xeno
	name = "Xeno Planet"
	desc = "A planet which may contain a toxic atmosphere along with mysterious flora and fauna."
	valid_atmospheres = list(PG_BREATHABLE, PG_TOXIC)
	valid_biomes = list()
	weight = PG_XENO_WEIGHT
	valid_map_sizes = list(PG_MEDIUM, PG_LARGE)
	heightmap_amplification = PG_MED_ALT
