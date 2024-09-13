//Procedural celestial body generator
var/procgen_state = PG_INACTIVE
var/list/atmospheres = typesof(/datum/procedural_atmosphere) - /datum/procedural_atmosphere
var/list/biomes = typesof(/datum/procedural_biome) - /datum/procedural_biome
var/list/civilizations = typesof(/datum/procedural_civilization) - /datum/procedural_civilization

/datum/procedural_generator
	var/name
	var/list/valid_map_sizes = list()
	var/map_size // [100,200,300]
	var/seed

	var/weight //chance for this generator to be selected

	var/water_threshold = 0.3
	var/cave_threshold = 0.7
	var/ore_threshold = 0.5

	var/list/valid_water_levels = list()
	var/water_level
	var/list/valid_altitudes = list()
	var/altitude
	var/list/valid_biomes = list()
	var/datum/procedural_biome/biome
	var/list/valid_atmospheres = list()
	var/datum/procedural_atmosphere/atmosphere
	var/list/valid_civs = list()
	var/datum/procedural_civilization/civilization

	var/area/procgen_area_type = /area/planet

	var/turfs_remaining = 0
	var/current_row = 1
	var/rows_per_tick = 1 //how many rows do we gen at once
	var/datum/zLevel/procgen/procgen_z

	var/list/esoteric_ores = list(
		/turf/unsimulated/mineral/mythril,
		/turf/unsimulated/mineral/molitz,
		/turf/unsimulated/mineral/cerenkite,
		/turf/unsimulated/mineral/cobryl,
		/turf/unsimulated/mineral/mauxite,
		/turf/unsimulated/mineral/telecrystal,
		/turf/unsimulated/mineral/uqill,
		/turf/unsimulated/mineral/cytine,
		/turf/unsimulated/mineral/erebite,
		/turf/unsimulated/mineral/syreline,
		/turf/unsimulated/mineral/bohrum,
		/turf/unsimulated/mineral/claretine,
		/turf/unsimulated/mineral/char,
		/turf/unsimulated/mineral/pharosium
	)
	var/list/rare_ores = list(
		/turf/unsimulated/mineral/phazon,
		/turf/unsimulated/mineral/clown
	)
	var/list/standard_ores = list(
		/turf/unsimulated/mineral/plasma,
		/turf/unsimulated/mineral/gold,
		/turf/unsimulated/mineral/silver,
		/turf/unsimulated/mineral/diamond,
		/turf/unsimulated/mineral/iron,
		/turf/unsimulated/mineral/uranium,
	)

/datum/procedural_generator/New()
	//Map Definition
	//map_size = pick(valid_map_sizes) DEBUG
	map_size = PG_SMALL
	turfs_remaining = map_size ** map_size
	switch(map_size)
		if(PG_SMALL)
			rows_per_tick = 3
		if(PG_MEDIUM)
			rows_per_tick = 2
		if(PG_LARGE)
			rows_per_tick = 1

	seed = rand(1,1000)

	water_level = pick(valid_water_levels)
	if(water_level == PG_NO_WATER)
		water_threshold = 0
	altitude = pick(valid_altitudes)
	var/biometype = pick(valid_biomes)
	biome = new biometype
	var/atmospheretype = pick(valid_atmospheres)
	atmosphere = new atmospheretype
	var/civtype = pick(valid_civs)
	civilization = new civtype
	world.maxz += 1
	map.addZLevel(new /datum/zLevel/procgen,world.maxz,TRUE,TRUE)
	procgen_z = world.maxz
	message_admins("Z-level [procgen_z] prepared for a [src.name] of size [map_size]x[map_size].")
	log_admin("Z-level [procgen_z] prepared for a [src.name] of size [map_size]x[map_size].")

//Top-level map gen proc
/datum/procedural_generator/proc/process(var/turf/T)
	if(!T || !istype(T))
		return
	var/turf/newT = gen_turf(T)
	set_air(newT)
	if(isfloor(newT))
		if(!spawn_decorations(newT))
			spawn_mobs(newT)
		spawn_loot(newT)
	turfs_remaining--

/datum/procedural_generator/proc/gen_turf(var/turf/T)
	var/turf/newturftype
	var/noiseval = text2num(rustg_noise_get_at_coordinates("[seed]", "[T.x]", "[T.y]"))
	if(noiseval < water_threshold)
		newturftype = biome.water_turf //TODO: procedural beaches
	else if(noiseval < cave_threshold)
		newturftype = pick(biome.floor_turfs)
	else
		var/ore_noiseval = text2num(rustg_noise_get_at_coordinates("[seed + rand(1,1000)]", "[T.x]", "[T.y]"))
		if(ore_noiseval > ore_threshold)
			newturftype = spawn_ores(T)
		else
			newturftype = pick(biome.wall_turfs)
	var/turf/nT = T.ChangeTurf(newturftype)
	return nT

/datum/procedural_generator/proc/spawn_ores(var/turf/T)
	var/turf/unsimulated/mineral/nT
	if(T.x != 1) //check left turf for ore
		var/turf/unsimulated/mineral/LT = locate(T.x-1,T.y)
		if(istype(LT))
			nT = LT.type
	if(!nT && T.y != 1) //check up turf for ore
		var/turf/unsimulated/mineral/UT = locate(T.x,T.y-1)
		if(istype(UT))
			nT = UT.type
	if(!nT && T.x != 1 && T.y != 1) //check diagonal left turf for ore
		var/turf/unsimulated/mineral/ULT = locate(T.x-1,T.y-1)
		if(istype(ULT))
			nT = ULT.type
	if(!nT) //if no neighbors have ore, pick an ore to spawn
		if(prob(10))
			nT = pick(rare_ores)
		else if(prob(25))
			nT = pick(esoteric_ores)
		else
			nT = pick(standard_ores)
	return nT

/datum/procedural_generator/proc/set_air(var/turf/T)
/datum/procedural_generator/proc/spawn_decorations(var/turf/T)
/datum/procedural_generator/proc/spawn_mobs(var/turf/T)
/datum/procedural_generator/proc/spawn_loot(var/turf/T)
