//Procedural celestial body generator

/**
 * Outputs a Voronoi Diagram in list-of-list form given map size and number of seed points.
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

/**
 * Outputs a Perlin Noise Matrix in list-of-list form given map size.
 *
 * Loosely based on: https://rtouti.github.io/graphics/perlin-noise-algorithm
 *
 * Arguments:
 * * size - Map size (square) [10,500]
 * * mod - Modifier (flat amplitude adjustment)
 */
/proc/generate_perlin_noise(size, mod = 0)
    var/list/noise_matrix = new/list(size,size)
    var/list/row
    var/noise_value
    var/max_noise = 100
    var/min_noise = -0.001

    // Frequency and amplitude settings for the noise generation
    var/frequency = 5 / size
    var/amplitude = 1.0

    // Generate raw Perlin noise values
    for (var/x = 1 to size)
        row = list()
        for (var/y = 1 to size)
            noise_value = PerlinNoise(x * frequency, y * frequency) * amplitude

            // Track the min and max values to normalize later
            if (noise_value > max_noise)
                max_noise = noise_value
            if (noise_value < min_noise)
                min_noise = noise_value
            row += noise_value
        noise_matrix += row

    // Normalize the noise values to the range of -10 to 10
    for (var/x = 1 to size)
        for (var/y = 1 to size)
            noise_matrix[x][y] |= Normalize(noise_matrix[x][y], min_noise, max_noise, -10, 10) + mod

    return noise_matrix

// Function to generate Perlin noise at a given coordinate
/proc/PerlinNoise(x, y)
    var/floor_x = floor(x)
    var/floor_y = floor(y)

    var/t_x = x - floor_x
    var/t_y = y - floor_y

    var/fade_x = Fade(t_x)
    var/fade_y = Fade(t_y)

    var/p1 = RandomGradient(floor_x, floor_y)
    var/p2 = RandomGradient(floor_x + 1, floor_y)
    var/p3 = RandomGradient(floor_x, floor_y + 1)
    var/p4 = RandomGradient(floor_x + 1, floor_y + 1)

    var/inter_x1 = p1 + fade_x * (p2 - p1)
    var/inter_x2 = p3 + fade_x * (p4 - p3)
    var/inter_y = inter_x1 + fade_y * (inter_x2 - inter_x1)

    return inter_y

// Fade function for Perlin noise smoothing
/proc/Fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)

// Evil fucking bit mixing function to return a random gradient at a given point
/proc/RandomGradient(x, y)
    var/hash = (x * 374761393 + y * 668265263) % 2147483647
    hash = (hash << 13) ^ hash
    return (1.0 - ((hash * (hash * hash * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0)

// Function to normalize a value from one range to another
/proc/Normalize(value, min_value, max_value, new_min, new_max)
    return ((value - min_value) / (max_value - min_value)) * (new_max - new_min) + new_min

/proc/spawn_space_object() //update with configurable inputs and a menu
	var/datum/procgen/generation/proc_gen = new
	SSprocgen.PG = proc_gen
	SSprocgen.flags -= SS_NO_FIRE
	SSprocgen.ignite()

/datum/procgen
	var/name
	var/desc
	var/map_size

	var/list/datum/procgen/space_object/space_objects
	var/list/datum/procgen/atmosphere/atmospheres
	var/list/datum/procgen/biome/biomes
	var/list/datum/procgen/civilization/civilizations

/datum/procgen/generation
	var/datum/procgen/space_object/space_obj
	var/datum/zLevel/procgen_z
	var/gen_state = PG_INACTIVE
	var/rows_completed = 0

//All lists are generated at runtime to assist in adding new content easier.
/datum/procgen/generation/New()
	space_objects = typesof(/datum/procgen/space_object) - /datum/procgen/space_object
	atmospheres = typesof(/datum/procgen/atmosphere) - /datum/procgen/atmosphere
	biomes = typesof(/datum/procgen/biome) - /datum/procgen/biome
	civilizations = typesof(/datum/procgen/civilization) - /datum/procgen/civilization
	gen_state = PG_INIT

/datum/procgen/Del()
	qdel(SSprocgen.PG)
	..()

/datum/procgen/generation/proc/generate()
	//Determine top-level celestial body characteristics
	var/space_obj_path = pick_space_object()
	space_obj = new space_obj_path
	message_admins("space_obj = [space_obj]")
	map_size = setup_zlevel()
	space_obj.map_size = map_size
	space_obj.padding = (PG_LARGE - map_size)/2
	space_obj.initialize_planet()

/datum/procgen/generation/proc/setup_zlevel()
	var/new_map_size = pick(space_obj.valid_map_sizes)
	message_admins("new_map_size = [new_map_size]")
	map.addZLevel(new /datum/zLevel/procgen, z_to_use = PG_Z, make_base_turf = TRUE)
	message_admins("map.zLevels.len = [map.zLevels.len]")
	procgen_z = map.zLevels[PG_Z]
	for(var/turf/T in block(locate(space_obj.padding + 1,space_obj.padding + 1,PG_Z),locate(space_obj.padding + new_map_size + 1,space_obj.padding + new_map_size + 1,PG_Z)))
		T.ChangeTurf(/turf/space)
	return new_map_size

/datum/procgen/generation/proc/pick_space_object()
	for(var/datum/procgen/space_object/S in space_objects)
		if(!S.weight || S.weight == 0)
			continue
		else
			space_objects += S
			space_objects[S] = S.weight
	if(!length(space_objects))
		CRASH("Failed to pick a space object to generate!")
	return pickweight(space_objects)

/datum/procgen/generation/proc/process()
	switch(gen_state)
		if(PG_INACTIVE)
			return
		if(PG_INIT)
			generate()
			gen_state = PG_MAPPING
		if(PG_MAPPING)
			if(rows_completed == map_size)
				//gen_state = PG_DECORATION
				gen_state = PG_INACTIVE
				return
			space_obj.build_map(rows_completed + 1)
			rows_completed++
		if(PG_DECORATION)
			//spawn decorations
		if(PG_POPULATION)
			//spawn mobs
		if(PG_LOOT)
			//spawn loot
