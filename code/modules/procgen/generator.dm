//Procedural celestial body generator

var/list/datum/zLevel/available_zlevels = list(
	/datum/zLevel/ProcGenL1,
	/datum/zLevel/ProcGenL2,
	/datum/zLevel/ProcGenM1,
	/datum/zLevel/ProcGenM2,
	/datum/zLevel/ProcGenM3,
	/datum/zLevel/ProcGenS1,
	/datum/zLevel/ProcGenS2,
	/datum/zLevel/ProcGenS3,
	/datum/zLevel/ProcGenS4,
	/datum/zLevel/ProcGenS5
)

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
	var/list/datum/procgen/space_object/space_objects
	var/list/datum/procgen/atmosphere/atmospheres
	var/list/datum/procgen/biome/biomes
	var/datum/procgen/space_object/space_obj
	var/map_size
	var/civilization

//All lists are generated at runtime to assist in adding new content easier.
/datum/procgen/New()
	space_objects = typesof(/datum/procgen/space_object) - /datum/procgen/space_object
	atmospheres = typesof(/datum/procgen/atmosphere) - /datum/procgen/atmosphere
	biomes = typesof(/datum/procgen/biome) - /datum/procgen/biome

/datum/procgen/generation/proc/generate()
	//Determine top-level celestial body characteristics
	map_size = pick_zlevel()
	space_obj = pick_space_object(map_size)
	space_obj.initialize_planet()
	space_obj.generate_biome_map(map_size)

/datum/procgen/generation/proc/pick_zlevel()
	var/list/available_maps = list()
// 	for(var/datum/zLevel/Z in available_zlevels)
// 		if(!Z)
// 			CRASH("Procedural generation attempted with no available maps!")
// 		else
// 			available_maps |= Z.x
	var/new_map_size
	var/i = 0
	while(!new_map_size)
		var/pot_map_size = pick(space_obj.valid_map_sizes)
		if(!(pot_map_size in available_maps))
			if(i>=20) //circuit breaker
				CRASH("Attempted to spawn an invalid space object given available map sizes.")
			else
				i++
				continue
		else
			new_map_size = pot_map_size
	return new_map_size

/datum/procgen/generation/proc/pick_space_object(var/list/map_sizes)
	var/list/datum/procgen/space_object/potential_objects = list()
	for(var/datum/procgen/space_object/S in space_objects)
		if(!S.weight || S.weight == 0)
			continue
		else
			var/valid_msize = FALSE
			for(var/msize in S.map_size)
				if(msize in map_sizes)
					valid_msize = TRUE
			if(valid_msize)
				space_objects += S
				space_objects[S] = S.weight
			else
				continue
	return pickweight(space_objects)
