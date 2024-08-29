/datum/procedural_space_object
	var/weight //chance for this object to be spawned

	var/list/valid_map_sizes = list()
	var/map_size

	var/list/valid_atmospheres = list()
	var/datum/procedural_atmosphere/atmos
	var/list/valid_biomes = list()
	var/list/valid_civs = list()
	var/datum/procedural_civilization/civ

	var/padding
	var/heightmap_amplification = 0 //how likely this planet is to be mountainous
	var/list/voronoi_matrix = list() //biome map
	var/list/noise_matrix = list() //base heightmap
//	var/list/heightmap = list() //heightmap blended with biome map

/datum/procedural_space_object/proc/initialize_planet()
	atmos = get_atmosphere()
	voronoi_matrix = generate_biome_map()
	noise_matrix = generate_heightmap()
	civ = colonize()

/datum/procedural_space_object/proc/get_atmosphere()
	var/atmospath = pick(valid_atmospheres)
	var/datum/procedural_atmosphere/A = new atmospath
	A.initialize_atmosphere()
	return A

/datum/procedural_space_object/proc/generate_biome_map()
	var/num_seeds
	var/list/vmatrix = list()
	switch(map_size)
		if(PG_SMALL)
			num_seeds = rand(2,4)
		if(PG_MEDIUM)
			num_seeds = rand(3,8)
		if(PG_LARGE)
			num_seeds = rand(4,16)
	vmatrix = generate_voronoi(map_size,num_seeds)
	message_admins("vmatrix length: [vmatrix.len]")
	return label_biomes(vmatrix)

/datum/procedural_space_object/proc/generate_heightmap()
	return generate_perlin_noise(map_size, heightmap_amplification)
//	noise_matrix = generate_perlin_noise(map_size, heightmap_amplification)
//	filter_heightmap() //modifies the heightmap to better fit different biomes

/datum/procedural_space_object/proc/colonize()
	var/list/civs = list()
	for(var/civpath in valid_civs)
		var/datum/procedural_civilization/C = new civpath
		if(!C.weight || C.weight == 0)
			continue
		else
			civs += C
			civs[C] = C.weight
	if(!length(civs))
		CRASH("Failed to pick a civilization level!")
	return pickweight(civs)

/datum/procedural_space_object/proc/label_biomes(var/list/vmatrix)
	var/list/id_to_biome_map = list()
	var/list/available_biomes = valid_biomes.Copy()
	var/list/ids = unique_ids(vmatrix)
	id_to_biome_map.len = ids.len
	for (var/id in ids)
		var/biome = pick(available_biomes)
		id_to_biome_map[id] = biome

	// Replace each ID in the matrix with the corresponding name
	for (var/x = 1 to length(vmatrix))
		for (var/y = 1 to length(vmatrix[x]))
			var/id = vmatrix[x][y]
			vmatrix[x][y] |= id_to_biome_map[id]
	return vmatrix

/datum/procedural_space_object/proc/unique_ids(voronoi_matrix)
    var/list/ids = list()

    for (var/x = 1 to length(voronoi_matrix))
        for (var/y = 1 to length(voronoi_matrix[x]))
            var/id = voronoi_matrix[x][y]
            if (!ids.Find(id)) // Add the ID only if it's not already in the list
                ids += id
    return ids

/datum/procedural_space_object/proc/build_map(var/row_index)
	var/i = 1
	var/list/turf/updated_turfs = list()
	var/turf/new_turf
//	var/area/new_area
	while(i <= map_size)
		for(var/turf/T in locate(padding + i,row_index,PG_Z))
			var/datum/procedural_biome/B = voronoi_matrix[i][row_index]
			var/heightmap_val = noise_matrix[i][row_index]
			if(!B || !istype(B))
				CRASH("Failed to build map: missing biome!")
			new_turf = B.choose_turf(heightmap_val)
			T.ChangeTurf(new_turf, tell_universe = FALSE)
			updated_turfs |= T
//	new_area = B.choose_area() //TODO
//	new_area.add_turfs(updated_turfs)
		if(i > 500) //circuit breaker
			break
		i++

/datum/procedural_space_object/asteroids // One or more asteroids floating through space.
	valid_atmospheres = list(PG_VACUUM)
	valid_biomes = list(PG_ASTEROID, PG_COMET)
	weight = PG_ASTEROID_WEIGHT
	valid_map_sizes = list(PG_SMALL)
	heightmap_amplification = PG_HIGH_ALT
	valid_civs = list(PG_UNEXPLORED)

/datum/procedural_space_object/moon // A lifeless mass of rock, lava, or ice.
	valid_atmospheres = list(PG_VACUUM, PG_THIN)
	valid_biomes = list(PG_PERMAFROST, PG_ICE_SHEET, PG_ROCK, PG_MAGMA, PG_ASH)
	weight = PG_MOON_WEIGHT
	valid_map_sizes = list(PG_SMALL, PG_MEDIUM)
	heightmap_amplification = PG_LOW_ALT
	valid_civs = list(PG_UNEXPLORED, PG_YOUNG_CIV)

/datum/procedural_space_object/planet // A planet which may contain an atmosphere, flora, and fauna.
	valid_atmospheres = list(PG_THIN, PG_BREATHABLE)
	valid_biomes = list(PG_PERMAFROST, PG_ICE_SHEET, PG_TUNDRA, PG_FOREST, PG_PLAINS, PG_SHRUBLAND, PG_SWAMPLAND, PG_RAINFOREST, PG_SAVANNA, PG_DESERT, PG_MAGMA, PG_ASH)
	weight = PG_PLANET_WEIGHT
	valid_map_sizes = list(PG_MEDIUM, PG_LARGE)
	heightmap_amplification = PG_MED_ALT
	valid_civs = list(PG_UNEXPLORED, PG_YOUNG_CIV, PG_OLD_CIV, PG_FUTURE_CIV)

/datum/procedural_space_object/xeno // A planet which may contain a toxic atmosphere along with mysterious flora and fauna.
	valid_atmospheres = list(PG_BREATHABLE, PG_TOXIC)
	valid_biomes = list(PG_PERMAFROST, PG_ICE_SHEET, PG_TUNDRA, PG_FOREST, PG_PLAINS, PG_SHRUBLAND, PG_SWAMPLAND, PG_RAINFOREST, PG_SAVANNA, PG_DESERT, PG_MAGMA, PG_ASH) //TODO: update with xeno biomes
	weight = PG_XENO_WEIGHT
	valid_map_sizes = list(PG_MEDIUM, PG_LARGE)
	heightmap_amplification = PG_MED_ALT
	valid_civs = list(PG_UNEXPLORED, PG_YOUNG_CIV, PG_OLD_CIV, PG_FUTURE_CIV)
