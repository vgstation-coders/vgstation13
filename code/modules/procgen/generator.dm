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
 * Outputs a heightmap in list-of-list form given map size.
 *
 *
 * Arguments:
 * * size - Map size (square) [10,world.maxx]
 */
/proc/generate_heightmap(size)
	var/seed = rand(1,100)
	var/noise_string1 = rustg_dbp_generate("[seed]","10","50","[size]","-1","0.01")
	seed = rand(1,100)
	var/noise_string2 = rustg_dbp_generate("[seed]","10","25","[size]","-1","0.01")
	var/number
	var/noise_string
	for(var/i = 1 to size*size)
		number = text2num(noise_string1[i]) - text2num(noise_string2[i])
		noise_string += num2text(number)
	var/list/noise_matrix = new/list(size,size)
	var/lastindex = 1
	for(var/j = 0 to size)
		var/list/row = new/list(size)
		for(var/k = 1 to size + 1)
			row += noise_string[lastindex]
			lastindex++
		noise_matrix += list(row)
	return noise_matrix

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
