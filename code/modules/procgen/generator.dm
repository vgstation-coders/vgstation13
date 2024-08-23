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
/proc/generate_voronoi(var/size,var/num_points, var/random_num = FALSE)
	size = clamp(size,10,500)
	if(!num_points || num_points <= 1 || random_num)
		num_points = rand(2,10)

	var/list/seeds = list()
	var/list/matrix = list()

	// Generate random seed points with unique group identifiers
	for (var/i = 1 to num_points)
		var/seed_x = rand(1, size)
		var/seed_y = rand(1, size)
		seeds += list(i = list("x" = seed_x, "y" = seed_y))

	// Initialize the map matrix
	for (var/x = 1 to size)
		var/list/row = list()
		for (var/y = 1 to size)
			row += 0 // Initialize with 0 (no group)
		matrix += row

	// Assign each cell in the grid to the nearest seed point
	for (var/x = 1 to size)
		for (var/y = 1 to size)
			var/nearest_seed = 0
			var/min_distance = size * size

			// Calculate the distance to each seed and find the closest one
			for (var/i in seeds)
				var/seed_x = seeds[i]["x"]
				var/seed_y = seeds[i]["y"]
				var/distance = (x - seed_x) ** 2 + (y - seed_y) ** 2

				if (distance < min_distance)
					min_distance = distance
					nearest_seed = i

			// Assign the group identifier to the matrix based on the nearest seed
			matrix[x][y] = nearest_seed

	return matrix


/datum/procgen
	var/name
	var/desc

/datum/procgen/generation
	var/datum/procgen/celestial_body/body
	var/datum/procgen/atmosphere/atmosphere
	var/preciptation
	var/temperature

/datum/procgen/generation/proc/generate()
	body = get_body_type()
	atmosphere = get_atmosphere(body)
	preciptation = get_precipitation(atmosphere)
	temperature = get_temperature()

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
