//Procedural celestial body generator

/**
 * Outputs a Voronoi Diagram in matrix form given map size and number of seed points.
 *
 * http://pcg.wikidot.com/pcg-algorithm:voronoi-diagram
 *
 * Arguments:
 * * size - Map size (square) [10,500]
 * * num_points - Total number of distinct zones [0,size**2]. For more realistic maps, use values less than 10.
 * * random_num - Use a random number of a seed points [TRUE,FALSE]
 */
/proc/generate_voronoi(var/size, var/num_points, var/random_num = FALSE)
	size = clamp(size,10,500)
	if(!num_points || num_points <= 1 || random_num)
		num_points = rand(2,10)

	var/list/seeds = list()
	var/list/vo_matrix = new/list(size,size)

	// Generate random seed points with unique group identifiers
	for (var/i = 1 to num_points)
		var/seed_x = rand(1, size)
		var/seed_y = rand(1, size)
		seeds += list("id" = i, "x" = seed_x, "y" = seed_y)

	// Assign each cell in the grid to the nearest seed point
	for (var/x = 1 to size)
		for (var/y = 1 to size)
			var/nearest_seed_id = 0
			var/min_distance = size * size

			// Calculate the distance to each seed and find the closest one
			for (var/seed in seeds)
				var/seed_x = seeds["x"]
				var/seed_y = seeds["y"]
				var/distance = (x - seed_x) ** 2 + (y - seed_y) ** 2

				if (distance < min_distance)
					min_distance = distance
					nearest_seed_id = seeds["id"]

			// Assign the group identifier to the matrix based on the nearest seed
			vo_matrix[x][y] |= nearest_seed_id
	return vo_matrix

/datum/procgen
	var/name
	var/desc

/datum/procgen/generation
	var/datum/procgen/celestial_body/body
	var/datum/procgen/atmosphere/atmosphere
	var/preciptation
	var/temperature
	var/civilization

/datum/procgen/generation/proc/generate()
	//Determine top-level celestial body characteristics
	body = get_body_type()
	atmosphere = get_atmosphere(body)
	preciptation = get_precipitation(atmosphere)
	temperature = get_temperature()
	civilization = get_civilization(body)

	//Determine map size and generate a Voronoi Diagram sized to fit the map.
	var/new_map_size = pick(body.map_size)
	var/num_seeds
	switch(new_map_size)
		if(PG_SMALL)
			num_seeds = rand(2,4)
		if(PG_MEDIUM)
			num_seeds = rand(3,8)
		if(PG_LARGE)
			num_seeds = rand(4,16)
	var/list/voronoi_matrix = generate_voronoi(new_map_size,num_seeds)

	///build_map()
		//Select an available z-level to use.
		//Spawn areas for each biome in accordance with the Voronoi Diagram.
		//Spawn base turfs within each biome.
		//Spawn solid walls within each biome, if applicable.
		//Apply biome smoothening.
		//Carve out caves or clearings irrespective of biome borders.

	///decorate_map()
		//Spawn biome-specific plants and decorations.

	///populate_map()
		//Spawn mobs
		//Maybe tie into civilization level?
		//Maybe add danger level?

	//spawn_loot()
		//spawn items in accordance with civilization level, both on the ground and in containers

	//generate_vaults()
		//spawn pre-existing vaults on the map

/datum/procgen/generation/proc/get_body_type()
	var/list/datum/procgen/celestial_body/potential_bodies = list()
	for(var/datum/procgen/celestial_body/B in celestial_bodies)
		if(!B.weight || B.weight == 0)
			continue
		else
			potential_bodies += B
			potential_bodies[B] = B.weight
	return pickweight(potential_bodies)

/datum/procgen/generation/proc/get_atmosphere(var/datum/procgen/celestial_body/B)
	return pick(B.body_atmospheres)

/datum/procgen/generation/proc/get_precipitation(var/datum/procgen/celestial_body/B)
	return pick(B.body_precipitation)

/datum/procgen/generation/proc/get_temperature()
	return pick(PG_FROZEN,PG_COLD,PG_BRISK,PG_TEMPERATE,PG_WARM,PG_HOT,PG_LAVA)

/datum/procgen/generation/proc/get_civilization(var/datum/procgen/celestial_body/B)
	var/civ_out
	var/list/datum/procgen/civilization/potential_civs = list()
	if(istype(B, PG_ASTEROID) || istype(B, PG_MOON))
		civ_out = PG_UNEXPLORED
	else
		for(var/datum/procgen/civilization/C in civilizations)
			if(!C.weight || C.weight == 0)
				continue
			else
				potential_civs += C
				potential_civs[C] = C.weight
		civ_out = pickweight(potential_civs)
	return civ_out
