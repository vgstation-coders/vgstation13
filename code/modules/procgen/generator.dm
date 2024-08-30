//Procedural celestial body generator
var/global/procgen_state = PG_INACTIVE

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
		seeds += list(list(seed_x,seed_y))

	// Assign each cell in the grid to the nearest seed point
	for (var/y = 1 to size)
		for (var/x = 1 to size)
			var/nearest_seed_index = 0
			var/list/rdists = list()

			// Calculate the distance to each seed and find the closest one
			var/i = 0
			while(i++ < seeds.len)
				var/nearest_seed_x = seeds[i][1]
				var/nearest_seed_y = seeds[i][2]
				var/distance = sqrt((x - nearest_seed_x) ** 2 + (y - nearest_seed_y) ** 2)
				rdists += distance
			var/pot_min = min(rdists)
			nearest_seed_index = rdists.Find(pot_min)
			// Assign the group identifier to the matrix based on the nearest seed
			vo_matrix[y][x] = nearest_seed_index
			file("voronoi.txt") << "[nearest_seed_index],"
		file("voronoi.txt") << ";"
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
	var/max_noise = 1*(10**9)
	var/min_noise = -1*(10**9)

	// Frequency and amplitude settings for the noise generation
	var/frequency = 5.0 / size
	var/amplitude = 100.0

	var/list/mins = list()
	var/list/maxs = list()

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
			//message_admins("[noise_value]")
		mins += min(row)
		maxs += max(row)
		noise_matrix += list(row)

	// Normalize the noise values to the range of -10 to 10
	for (var/y = 1 to size)
		for (var/x = 1 to size)
			//noise_matrix[y][x] = normalize(noise_matrix[y][x], min(mins), max(maxs), -10, 10) + mod
			file("perlin.txt") << "[noise_matrix[y][x]],"
		file("perlin.txt") << ";"

	return noise_matrix

// Function to generate Perlin noise at a given coordinate
/proc/PerlinNoise(x, y)
    var/floor_x = floor(x)
    var/floor_y = floor(y)

    var/t_x = x - floor_x
    var/t_y = y - floor_y

    var/fade_x = Fade(t_x)
    var/fade_y = Fade(t_y)

    var/p1 = DotGridGradient(floor_x, floor_y, t_x, t_y)
    var/p2 = DotGridGradient(floor_x + 1, floor_y, t_x - 1, t_y)
    var/p3 = DotGridGradient(floor_x, floor_y + 1, t_x, t_y - 1)
    var/p4 = DotGridGradient(floor_x + 1, floor_y + 1, t_x - 1, t_y - 1)

    var/inter_x1 = mix(p1, p2, fade_x)
    var/inter_x2 = mix(p3, p4, fade_x)
    var/inter_y = mix(inter_x1, inter_x2, fade_y)

    return inter_y

// Fade function for Perlin noise smoothing
/proc/Fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)

/proc/DotGridGradient(ix, iy, x, y)
    var/gradient = RandomGradient(ix, iy)
    var/dx = x
    var/dy = y
    return (dx * gradient[1] + dy * gradient[2])

// Evil fucking bit mixing function to return a random gradient at a given point
/proc/RandomGradient(x, y)
    var/hash = (x * 374761393 + y * 668265263) % 0xFFFFFF
    hash = (hash << 13) & 0xFFFFFF
    hash = (hash * (hash * hash * 15731 + 789221) + 1376312589) & 0xFFFFFF

    var/direction = hash & 3
    if (direction == 0)
        return list(1.0, 0)  // Vector pointing to (1, 0)
    else if (direction == 1)
        return list(-1.0, 0)  // Vector pointing to (-1, 0)
    else if (direction == 2)
        return list(0, 1.0)  // Vector pointing to (0, 1)
    else
        return list(0, -1.0)  // Vector pointing to (0, -1)

/proc/spawn_space_object() //update with configurable inputs and a menu
	var/datum/procedural_generator/proc_gen = new
	SSprocgen.PG = proc_gen
	procgen_state = PG_INIT
	SSprocgen.can_fire = TRUE
	SSprocgen.ignite()

/datum/procedural_generator
	var/map_size
	var/rows_completed = 0

	var/list/datum/procedural_space_object/space_objects
	var/list/datum/procedural_atmosphere/atmospheres
	var/list/datum/procedural_biome/biomes
	var/list/datum/procedural_civilization/civilizations

	var/datum/procedural_space_object/space_obj
	var/datum/zLevel/procgen_z

//All lists are generated at runtime to assist in adding new content easier.
/datum/procedural_generator/New()
	space_objects = typesof(/datum/procedural_space_object) - /datum/procedural_space_object
	atmospheres = typesof(/datum/procedural_atmosphere) - /datum/procedural_atmosphere
	biomes = typesof(/datum/procedural_biome) - /datum/procedural_biome
	civilizations = typesof(/datum/procedural_civilization) - /datum/procedural_civilization

/datum/procgen/Del()
	qdel(SSprocgen.PG)
	..()

////////////////////////////////////////////////////////////////////////////////
// Initialization State - PG_INIT
////////////////////////////////////////////////////////////////////////////////

// Selects a space object, configures it, constructs the matrices used to map it, and spawns a zlevel of the appropriate size.
/datum/procedural_generator/proc/construct_space_obj()
	var/space_obj_path = pick_space_object()
	space_obj = new space_obj_path
	map_size = space_obj.get_map_size()
	space_obj.initialize_planet()
	setup_zlevel()
	procgen_state = PG_MAPPING

/datum/procedural_generator/proc/pick_space_object()
	for(var/datum/procedural_space_object/S in space_objects)
		if(!S.weight || S.weight == 0)
			continue
		else
			space_objects += S
			space_objects[S] = S.weight
	if(!length(space_objects))
		CRASH("Failed to pick a space object to generate!")
	return pickweight(space_objects)

/datum/procedural_generator/proc/setup_zlevel()
	map.addZLevel(new /datum/zLevel/procgen, z_to_use = PG_Z, make_base_turf = TRUE)
	procgen_z = map.zLevels[PG_Z]
	for(var/turf/T in block(locate(space_obj.padding + 1,space_obj.padding + 1,PG_Z),locate(space_obj.padding + map_size + 1,space_obj.padding + map_size + 1,PG_Z)))
		T.ChangeTurf(/turf/space)
	return


////////////////////////////////////////////////////////////////////////////////
// Mapping State - PG_MAPPING
////////////////////////////////////////////////////////////////////////////////
/datum/procedural_generator/proc/generate_map()
	rows_completed = space_obj.build_map(rows_completed + 1)
	if(rows_completed == map_size)
		procgen_state = PG_DECORATION
