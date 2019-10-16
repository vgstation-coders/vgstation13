//Vaults are structures that are randomly spawned as a part of the main map
//They're stored in maps/randomVaults/ as .dmm files

//HOW TO ADD YOUR OWN VAULTS:
//1. make a map in the maps/randomVaults/ folder (1 zlevel only please)
//2. add the map's name to the vault_map_names list
//3. the game will handle the rest

#define MINIMUM_VAULT_AMOUNT 5 //Amount of guaranteed vault spawns
#define MAXIMUM_VAULT_AMOUNT 15

#define MAX_VAULT_WIDTH  80 //Vaults bigger than that have a slight chance of overlapping with other vaults
#define MAX_VAULT_HEIGHT 80

//For the populate_area_with_vaults() proc
#define POPULATION_DENSE  1 //Performs large calculations to make vaults able to spawn right next to each other and not overlap. Recommended with smaller areas - may lag bigly in big areas
#define POPULATION_SCARCE 2 //Performs less calculations by cheating a bit and assuming that every vault's size is 100x100. Vaults are farther away from each other - recommended with big areas


//#define SPAWN_ALL_VAULTS //Uncomment to spawn every hecking vault in the game
//#define SPAWN_MAX_VAULTS //Uncomment to spawn as many vaults as the code supports

#ifdef SPAWN_MAX_VAULTS
#warn Spawning maximum amount of vaults!
#undef MINIMUM_VAULT_AMOUNT
#define MINIMUM_VAULT_AMOUNT MAXIMUM_VAULT_AMOUNT
#endif

//List of spawnable vaults is in code/modules/randomMaps/vault_definitions.dm

//This a random vault spawns somewhere in this area. Then this area is replaced with space!
/area/random_vault
	name = "random vault area"
	desc = "Spawn a vault in there somewhere"
	icon_state = "random_vault"
	flags = NO_PERSISTENCE|NO_PACIFICATION

/area/vault
	flags = NO_PERSISTENCE|NO_PACIFICATION

/proc/get_map_element_objects(base_type = /datum/map_element/vault)
	var/list/list_of_vaults = typesof(base_type) - base_type

	for(var/V in list_of_vaults) //Turn list of paths into list of objects
		list_of_vaults.Add(new V)
		list_of_vaults.Remove(V)

	//Compare all objects with the map and remove non-compactible ones
	for(var/datum/map_element/vault/V in list_of_vaults)
		//See code/modules/randomMaps/dungeons.dm
		if(V.require_dungeons && !dungeon_area)
			list_of_vaults.Remove(V)
			continue

		if(map.only_spawn_map_exclusive_vaults || V.exclusive_to_maps.len) //Remove this vault if it isn't exclusive to this map
			if(!V.exclusive_to_maps.Find(map.nameShort) && !V.exclusive_to_maps.Find(map.nameLong))
				list_of_vaults.Remove(V)
				continue

		if(V.map_blacklist.len)
			if(V.map_blacklist.Find(map.nameShort) || V.map_blacklist.Find(map.nameLong))
				list_of_vaults.Remove(V)
				continue

	return list_of_vaults

/proc/generate_vaults()
	var/area/space = get_space_area()

	var/list/list_of_vaults = get_map_element_objects()

	var/vault_number = rand(MINIMUM_VAULT_AMOUNT, min(list_of_vaults.len, MAXIMUM_VAULT_AMOUNT))

	#ifdef SPAWN_ALL_VAULTS
	#warn Spawning ALL vaults!
	vault_number = list_of_vaults.len
	#endif

	message_admins("<span class='info'>Spawning [vault_number] vaults in space!</span>")

	var/area/A = locate(/area/random_vault)
	var/result = populate_area_with_vaults(A, amount = vault_number, population_density = POPULATION_SCARCE)

	for(var/turf/TURF in A) //Replace all of the temporary areas with space
		TURF.set_area(space)

	message_admins("<span class='info'>Loaded [result] out of [vault_number] vaults.</span>")

/proc/generate_asteroid_secrets()
	var/list/list_of_surprises = get_map_element_objects(/datum/map_element/mining_surprise)

	var/surprise_number = rand(1, min(list_of_surprises.len, max_secret_rooms))

	var/result = populate_area_with_vaults(/area/mine/unexplored, list_of_surprises, surprise_number, filter_function=/proc/asteroid_can_be_placed)

	message_admins("<span class='info'>Loaded [result] out of [surprise_number] mining surprises.</span>")

/proc/asteroid_can_be_placed(var/datum/map_element/E, var/turf/start_turf)
	var/list/dimensions = E.get_dimensions()
	var/result = check_complex_placement(start_turf,dimensions[1], dimensions[2])
	return result
//Proc that populates a single area with many vaults, randomly
//A is the area OR a list of turfs where the placement happens
//map_element_objects is a list of vaults that have to be placed. Defaults to subtypes of /datum/map_element/vault (meaning all vaults are spawned)
//amount is the maximum amount of vaults placed. If -1, it will place as many vaults as it can
//POPULATION_DENSE is much more expensive and may lag with big areas
//POPULATION_SCARCE is cheaper but may not do the job as well
//NOTE: Vaults may be placed partially outside of the area. Only the lower left corner is guaranteed to be in the area

/proc/populate_area_with_vaults(area/A, list/map_element_objects, var/amount = -1, population_density = POPULATION_DENSE, filter_function)
	var/list/area_turfs

	if(ispath(A, /area))
		A = locate(A)
	if(isarea(A))
		area_turfs = A.get_turfs()
	else if(istype(A, /list))
		area_turfs = A
	ASSERT(area_turfs)

	if(!map_element_objects)
		map_element_objects = get_map_element_objects()

	message_admins("<span class='info'>Starting populating [isarea(A) ? "an area ([A])" : "a list of [area_turfs.len] turfs"] with vaults.")

	var/list/spawned = list()
	var/successes = 0

	while(map_element_objects.len)
		var/datum/map_element/ME = pick(map_element_objects)
		map_element_objects.Remove(ME)

		if(!istype(ME))
			continue

		var/list/dimensions = ME.get_dimensions() //List with the element's width and height

		var/new_width = dimensions[1]
		var/new_height = dimensions[2]

		var/list/valid_spawn_points
		switch(population_density)
			if(POPULATION_DENSE)
				//Copy the list of all turfs
				valid_spawn_points = area_turfs.Copy()

				//While going through every already spawned map element - remove all potential locations which would cause the new element to overlap the already spawned one
				for(var/datum/map_element/conflict in spawned)
					if(!valid_spawn_points.len)
						break
					if(!isturf(conflict.location))
						continue

					var/turf/T = conflict.location
					var/x1 = max(1, T.x - new_width - 1)
					var/y1 = max(1, T.y - new_height- 1)
					var/turf/t1 = locate(x1, y1, T.z) //Corner #1: Old vault's coordinates minus new vault's dimensions (width and height)
					var/turf/t2 = locate(T.x + conflict.width, T.y + conflict.height, T.z) //Corner #2: Old vault's coordinates plus old vault's dimensions

					//A rectangle defined by corners #1 and #2 is marked as invalid spawn area
					valid_spawn_points.Remove(block(t1, t2))

			if(POPULATION_SCARCE)
				//This method is much cheaper but results in less accuracy. Bad spawn areas will be removed later - when the new vault is created
				valid_spawn_points = area_turfs

		if(!valid_spawn_points.len)
			if(population_density == POPULATION_SCARCE)
				//Since POPULATION_SCARCE assumes that every vault is the same size, if we ran out of spawn points we know for sure that we can't create any more vaults
				message_admins("<span class='info'>Ran out of free space for vaults.</span>")
				break

			//POPULATION_DENSE respects every vault's true size, so it's possible that another vault may fit in there - continue trying to place vaults
			continue
		var/sanity = 0
		var/turf/new_spawn_point
		do
			sanity++
			new_spawn_point = pick(valid_spawn_points)
			valid_spawn_points.Remove(new_spawn_point)
			if(filter_function && !call(filter_function)(ME, new_spawn_point))
				new_spawn_point = null
				continue
			break
		while(sanity < 100)
		if(!new_spawn_point)
			continue
		var/vault_x = new_spawn_point.x
		var/vault_y = new_spawn_point.y
		var/vault_z = new_spawn_point.z

		if(population_density == POPULATION_SCARCE)
			var/turf/t1 = locate(max(1, vault_x - MAX_VAULT_WIDTH - 1), max(1, vault_y - MAX_VAULT_HEIGHT - 1), vault_z)
			var/turf/t2 = locate(vault_x + new_width, vault_y + new_height, vault_z)
			valid_spawn_points.Remove(block(t1, t2))

		if(ME.load(vault_x, vault_y, vault_z))
			spawned.Add(ME)
			message_admins("<span class='info'>Loaded [ME.file_path]: [formatJumpTo(locate(vault_x, vault_y, vault_z))].")

			successes++
			if(amount > 0)
				amount--

				if(amount == 0)
					break
		else
			message_admins("<span class='danger'>Can't find [ME.file_path]!</span>")

		sleep(-1)

	return successes

#undef POPULATION_DENSE
#undef POPULATION_SCARCE
