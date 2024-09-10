//Procedural celestial body generator
var/procgen_state = PG_INACTIVE
var/list/atmospheres = typesof(/datum/procedural_atmosphere) - /datum/procedural_atmosphere
var/list/biomes = typesof(/datum/procedural_biome) - /datum/procedural_biome
var/list/civilizations = typesof(/datum/procedural_civilization) - /datum/procedural_civilization

/datum/procedural_generator
	var/name
	var/list/valid_map_sizes = list()
	var/map_size // [100,200,300]
	var/heightmap_unfiltered
	var/heightmap

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
	heightmap_unfiltered = generate_heightmap()
	heightmap = filter_heightmap(heightmap_unfiltered)
	turfmap = build_turfmap()

	//Z-Level Mapping (high intensity)
	procgen_z = new /datum/zLevel/procgen
	map.addZLevel(procgen_z,procgen_z_id)
	var/strout
	var/row = 1
	for(var/i = 1 to length(heightmap))
		// var/turf/T = locate(i,j,procgen_z_id)
		// T.ChangeTurf(turfmap[i][j])
		strout += turfmap[i]
		if(!(i % map_size))
			row++
			strout += ";"
		else
			strout += ","
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
	var/list/filtered_string = list()
	for(var/i = 1 to length(input_string))
		var/checkval = text2num(input_string[i])
		var/newval
		if(checkval < water)
			newval = 0
		else if(checkval < altitude)
			newval = 1
		else
			newval = 2
		filtered_string += "[newval]"
	return filtered_string

/**
 * Outputs a turf matrix in list-of-list form using a heightmap.
 */
/datum/procedural_generator/proc/build_turfmap()
	var/list/turfs = list()
	for(var/i = 1 to length(heightmap))
		var/val = text2num(heightmap[i])
		var/list/row = list()
		var/turfstr
		switch(val)
			if(0)
				turfstr = "[biome.water_turf]"
			if(1)
				turfstr = "[pick(biome.floor_turfs)]"
			if(2)
				turfstr = "[pick(biome.wall_turfs)]"
			else
				CRASH("Heightmap corrupted - received [val], expected a number!")
		row += turfstr
		if(!(i % map_size))
			turfs += list(row)
			row = list()
	return turfs
