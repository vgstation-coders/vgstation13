//Vaults are structures that are randomly spawned as a part of the main map
//They're stored in maps/randomVaults/ as .dmm files

//HOW TO ADD YOUR OWN VAULTS:
//1. make a map in the maps/randomVaults/ folder (1 zlevel only please)
//2. add the map's name to the vault_map_names list
//3. the game will handle the rest

#define MINIMUM_VAULT_AMOUNT 1 //Amount of guaranteed vault spawns

//#define SPAWN_ALL_VAULTS //Uncomment to spawn all existing vaults (otherwise only some will spawn)!

//List of spawnable vaults is in code/modules/randomMaps/vault_definitions.dm

/area/random_vault
	name = "random vault area"
	desc = "Spawn a vault in there somewhere"
	icon_state = "random_vault"

//Because areas are shit and it's easier that way!

//Each of these areas can only create ONE vault. Only using /area/random_vault/v1 for the entire map will result in ONE vault being created.
//Placing them over (or even near) shuttle docking ports will sometimes result in a vault spawning on top of a shuttle docking port. This isn't a big problem, since
//shuttles can destroy the vaults, but it's better to avoid that
//If you want more vaults, feel free to add more subtypes of /area/random_vault. You don't have to add these subtypes to any lists or anything - just map it and the game will handle the rest.

//"/area/random_vault" DOESN'T spawn any vaults!!!
/area/random_vault/v1
/area/random_vault/v2
/area/random_vault/v3
/area/random_vault/v4
/area/random_vault/v5
/area/random_vault/v6
/area/random_vault/v7
/area/random_vault/v8
/area/random_vault/v9
/area/random_vault/v10

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

	var/list/list_of_vault_spawners = shuffle(typesof(/area/random_vault) - /area/random_vault)
	var/list/list_of_vaults = get_map_element_objects()

	var/failures = 0
	var/successes = 0
	var/vault_number = rand(MINIMUM_VAULT_AMOUNT, min(list_of_vaults.len, list_of_vault_spawners.len))

	#ifdef SPAWN_ALL_VAULTS
	#warning Spawning all vaults!
	vault_number = min(list_of_vaults.len, list_of_vault_spawners.len)
	#endif

	message_admins("<span class='info'>Spawning [vault_number] vaults (in [list_of_vault_spawners.len] areas)...</span>")

	for(var/T in list_of_vault_spawners) //Go through all subtypes of /area/random_vault
		var/area/A = locate(T) //Find the area

		if(!A || !A.contents.len) //Area is empty and doesn't exist - skip
			continue

		if(list_of_vaults.len > 0 && vault_number>0)
			vault_number--

			var/vault_x
			var/vault_y
			var/vault_z

			var/turf/TURF = get_turf(pick(A.contents))

			vault_x = TURF.x
			vault_y = TURF.y
			vault_z = TURF.z

			var/datum/map_element/vault/new_vault = pick(list_of_vaults) //Pick a random path from list_of_vaults (like /datum/vault/spacegym)

			if(new_vault.only_spawn_once)
				list_of_vaults.Remove(new_vault)

			if(new_vault.load(vault_x, vault_y, vault_z))
				message_admins("<span class='info'>Loaded [new_vault.file_path]: [formatJumpTo(locate(vault_x, vault_y, vault_z))].")
				successes++
			else
				message_admins("<span class='danger'>Can't find [new_vault.file_path]!</span>")
				failures++

		for(var/turf/TURF in A) //Replace all of the temporary areas with space
			space.contents.Add(TURF)
			TURF.change_area(A, space)

	message_admins("<span class='info'>Loaded [successes] vaults successfully, [failures] failures.</span>")


//Proc that populates a single area with many vaults, randomly
//A is the area OR a list of turfs where the placement happens
//map_element_objects is a list of vaults that have to be placed. Defaults to subtypes of /datum/map_element/vault (meaning all vaults are spawned)
//amount is number of vaults placed. If -1, it will place as many vaults as it can

//NOTE: Vaults may be placed partially outside of the area. Only the lower left corner is guaranteed to be in the area

/proc/populate_area_with_vaults(area/A, list/map_element_objects, amount = -1)
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

	message_admins("<span class='info'>Populating an area with [map_element_objects.len] vaults.")

	var/list/spawned = list()

	while(map_element_objects.len)
		var/datum/map_element/ME = pick(map_element_objects)
		map_element_objects.Remove(ME)

		if(!istype(ME))
			continue

		var/list/dimensions = ME.get_dimensions() //List with the element's width and height
		var/new_width = dimensions[1]
		var/new_height = dimensions[2]

		var/list/valid_spawn_points = area_turfs.Copy()

		for(var/datum/map_element/conflict in spawned)
			if(!valid_spawn_points.len)
				break
			if(!isturf(conflict.location))
				continue

			var/turf/T = conflict.location
			var/x1 = max(1, T.x - new_width - 1)
			var/y1 = max(1, T.y - new_height- 1)
			var/turf/t1 = locate(x1, y1, T.z)
			var/turf/t2 = locate(T.x + conflict.width, T.y + conflict.height, T.z)

			valid_spawn_points.Remove(block(t1, t2))

		if(!valid_spawn_points.len)
			continue

		var/turf/new_spawn_point = pick(valid_spawn_points)
		var/vault_x = new_spawn_point.x
		var/vault_y = new_spawn_point.y
		var/vault_z = new_spawn_point.z

		if(ME.load(vault_x, vault_y, vault_z))
			spawned.Add(ME)
			message_admins("<span class='info'>Loaded [ME.file_path]: [formatJumpTo(locate(vault_x, vault_y, vault_z))].")
		else
			message_admins("<span class='danger'>Can't find [ME.file_path]!</span>")
