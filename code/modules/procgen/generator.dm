//Procedural celestial body generator
var/procgen_state = PG_INACTIVE
var/list/atmospheres = typesof(/datum/procedural_atmosphere) - /datum/procedural_atmosphere
var/list/biomes = typesof(/datum/procedural_biome) - /datum/procedural_biome
var/list/civilizations = typesof(/datum/procedural_civilization) - /datum/procedural_civilization

/datum/procedural_generator
	var/name
	var/list/valid_map_sizes = list()
	var/map_size // [100,200,300]
	var/heightmap_string
	var/list/heightmap_list

	var/weight //chance for this generator to be selected
	var/accuracy = 10 //best value for good-looking terrain
	var/stamp = 60 //how large the terrain features appear

	var/list/valid_waters = list()
	var/water
	var/list/valid_altitudes = list()
	var/altitude
	var/list/valid_biomes = list()
	var/datum/procedural_biome/biome
	var/list/valid_atmospheres = list()
	var/datum/procedural_atmosphere/atmosphere
	var/list/valid_civs = list()
	var/datum/procedural_civilization/civilization

	var/list/turfmap = list()
	var/area/procgen_area_type = /area/planet

	var/datum/zLevel/procgen/procgen_z
	var/procgen_z_id = 100

/datum/procedural_generator/New()
	//Map Definition (low intensity)
	map_size = pick(valid_map_sizes)
	water = pick(valid_waters)
	altitude = pick(valid_altitudes)
	var/biometype = pick(valid_biomes)
	biome = new biometype
	var/atmospheretype = pick(valid_atmospheres)
	atmosphere = new atmospheretype
	var/civtype = pick(valid_civs)
	civilization = new civtype

	//Map Creation (medium intensity)
	heightmap_string = generate_heightmap()
	heightmap_list = filter_heightmap(heightmap_string)
	turfmap = build_turfmap()

	//Z-Level Mapping (high intensity)
//	SSprocgen.PG = src
	procgen_z = new /datum/zLevel/procgen
	map.addZLevel(procgen_z,procgen_z_id)
	var/strout
	for(var/i = 1 to map_size)
		for(var/j = 1 to map_size)
			// var/turf/T = locate(i,j,procgen_z_id)
			// T.ChangeTurf(turfmap[i][j])
			strout += turfmap[i][j]
			if(i%map_size)
				strout += ","
			else
				strout += ";"
	rustg_file_write("[strout]","procedural_generator_debug.txt")

/**
 * Outputs a heightmap in string form.
 *
 *
 * Arguments:
 * * debug - Prints the string to a comma-separated text file in the server directory for visulization.
 */
/datum/procedural_generator/proc/generate_heightmap()
	var/seed = rand(1,100)
	var/cnoise = rustg_cnoise_generate("45","[stamp/3]","4","3","[map_size]","[map_size]")
	var/pnoise1 = rustg_dbp_generate("[seed]","[accuracy]","[stamp]","[map_size]","-1","0.01")
	var/pnoise2 = rustg_dbp_generate("[seed]","[accuracy]","[stamp/2]","[map_size]","-1","0.01")
	var/pnoise3 = rustg_dbp_generate("[seed]","[accuracy]","[stamp/4]","[map_size]","-1","0.01")
	var/pnoise4 = rustg_dbp_generate("[seed]","[accuracy]","[stamp/6]","[map_size]","-1","0.01")

	var/cave_threshold = 5
	var/value
	var/noise_string

	for(var/i = 1 to map_size*map_size)
		value = 4 * text2num(pnoise1[i]) + 2 * text2num(pnoise2[i]) + 2 * text2num(pnoise3[i]) + text2num(pnoise4[i])
		if(value > cave_threshold)
			value += 2 * (text2num(cnoise[i]) - 1)
		noise_string += num2text(value)

	return noise_string

// Clamps the heightmap values and outputs a list of lists.
// 0 - water
// 1 - floor
// 2 - turf
/datum/procedural_generator/proc/filter_heightmap(input_string)
	var/list/noise_matrix = new/list(map_size,map_size)
	var/list/row = list()
	for(var/i = 1 to length(input_string))
		var/newval
		switch(text2num(input_string[i]))
			// if(-10 to water - 1) FIX LATER
			// 	input_string[i] = 0
			// if(water to altitude - 1)
			// 	input_string[i] = 1
			// if(altitude to 10)
			// 	input_string[i] = 2
			if(0 to 1)
				newval = 0
			if(2 to 5)
				newval = 1
			if(6 to 9)
				newval = 2
		if(!(i % (map_size + 1)))
			noise_matrix += list(row)
			row = list()
		row += newval

	return noise_matrix

/**
 * Outputs a turf matrix in list-of-list form using a heightmap.
 */
/datum/procedural_generator/proc/build_turfmap()
	var/list/turfs = new/list(map_size,map_size)
	for(var/i = 1 to map_size)
		var/list/row = list()
		for(var/j = 1 to map_size)
			switch(heightmap_list[i][j])
				if(0)
					row += "[biome.water_turf]"
				if(1)
					row += "[pick(biome.floor_turfs)]"
				if(2)
					row += "[pick(biome.wall_turfs)]"
				else
					CRASH("Heightmap corrupted - incorrect value received!")
		turfs += row
	return turfs
