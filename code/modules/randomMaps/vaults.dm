//Vaults are structures that are randomly spawned as a part of the main map
//They're stored in maps/randomVaults/ as .dmm files

//HOW TO ADD YOUR OWN VAULTS:
//1. make a map in the maps/randomVaults/ folder (1 zlevel only please)
//2. add the map's name to the vault_map_names list
//3. the game will handle the rest

#define MINIMUM_VAULT_AMOUNT 5 //Amount of guaranteed vault spawns
#define MAXIMUM_VAULT_AMOUNT 15
#define VAULT_POINT_MULTIPLIER 3

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

	var/vault_number = (rand(MINIMUM_VAULT_AMOUNT, min(list_of_vaults.len, MAXIMUM_VAULT_AMOUNT)) * VAULT_POINT_MULTIPLIER)

	#ifdef SPAWN_ALL_VAULTS
	#warn Spawning ALL vaults!
	vault_number = list_of_vaults.len
	#endif

	message_admins("<span class='info'>Spawning [vault_number] vaults in space!</span>")

	var/area/A = locate(/area/random_vault)
	var/result = populate_area_with_vaults(A, amount = vault_number, population_density = POPULATION_SCARCE, filter_function=/proc/stay_in_vault_area)

	for(var/turf/TURF in A) //Replace all of the temporary areas with space
		TURF.set_area(space)

	message_admins("<span class='info'>Loaded [result] out of [vault_number] vaults.</span>")

/proc/generate_asteroid_secrets()
	var/list/list_of_surprises = get_map_element_objects(/datum/map_element/mining_surprise)

	var/surprise_number = rand(1, min(list_of_surprises.len, max_secret_rooms))

	var/result = populate_area_with_vaults(/area/mine/unexplored, list_of_surprises, surprise_number, filter_function=/proc/asteroid_can_be_placed, overwrites=TRUE)

	message_admins("<span class='info'>Loaded [result] out of [surprise_number] mining surprises.</span>")

/proc/generate_hoboshack()
	var/list/list_of_shacks = get_map_element_objects(/datum/map_element/hoboshack)

	var/result = populate_area_with_vaults(/area/mine/unexplored, list_of_shacks, 1, filter_function=/proc/asteroid_can_be_placed, overwrites=TRUE)

	message_admins("<span class='info'>Loaded space hobo shack [result ? "" : "un"]successfully.</span>")

/datum/map_element/dungeon/hell
	name = "HELL"
	file_path = "maps/misc/HELL.dmm"
	unique = TRUE

/datum/map_element/dungeon/hell/load(x, y, z, rotate=0, overwrite = FALSE, override_can_rotate = FALSE)
	. = ..()
	if(islist(.) && config.bans_shown_in_hell_limit)
		var/list/L = .
		var/list/turf/turfs = list()
		if(L.len)
			for(var/turf/spawned_turf in L)
				if(!spawned_turf.density)
					turfs += spawned_turf
			if(turfs.len)
				var/time2make = world.time
				var/database/db = ("players2.sqlite")
				var/database/query/select_query = new
				select_query.Add("SELECT ckey, reason FROM erro_ban WHERE bantype = 'PERMABAN' AND isnull(unbanned)")
				if(!select_query.Execute(db))
					qdel(select_query)
					message_admins("Banned player search error on populating hell: [select_query.ErrorMsg()]")
					log_sql("Error: [select_query.ErrorMsg()]")
					return

				var/bancount = 0
				while(select_query.NextRow() && bancount <= config.bans_shown_in_hell_limit)
					var/list/row = select_query.GetRowData()
					var/ckey = row[1]
					var/reason = row[2]
					var/mob/living/carbon/human/H = new(pick(turfs))
					H.quick_copy_prefs()
					H.flavor_text = "The soul of [ckey], damned to this realm for the following reason: [reason]"
					bancount++
				time2make = world.time - time2make
				log_admin("Hell was populated successfully with [bancount] banned players out of a max of [config.bans_shown_in_hell_limit] in [time2make/10] seconds.")
				message_admins("Hell was populated successfully with [bancount] banned players out of a max of [config.bans_shown_in_hell_limit] in [time2make/10] seconds.")

/mob/living/carbon/human/proc/quick_copy_prefs()
	var/list/preference_list = new
	var/database/query/check = new
	var/database/db = ("players2.sqlite")
	check.Add("SELECT player_ckey FROM players WHERE player_ckey = ? AND player_slot = ?", ckey, 1)
	if(check.Execute(db))
		if(!check.NextRow())
			message_admins("[ckey] had no character file to load")
			return
	else
		message_admins("Player appearance file check error: [check.ErrorMsg()]")
		log_sql("Error: [check.ErrorMsg()]")
		return
	var/database/query/q = new
	q.Add({"
		SELECT
			limbs.player_ckey,
			limbs.player_slot,
			limbs.l_arm,
			limbs.r_arm,
			limbs.l_leg,
			limbs.r_leg,
			limbs.l_foot,
			limbs.r_foot,
			limbs.l_hand,
			limbs.r_hand,
			limbs.heart,
			limbs.eyes,
			limbs.lungs,
			limbs.liver,
			limbs.kidneys,
			players.player_ckey,
			players.player_slot,
			players.real_name,
			players.random_name,
			players.random_body,
			players.gender,
			players.species,
			players.disabilities,
			body.player_ckey,
			body.player_slot,
			body.hair_red,
			body.hair_green,
			body.hair_blue,
			body.facial_red,
			body.facial_green,
			body.facial_blue,
			body.skin_tone,
			body.hair_style_name,
			body.facial_style_name,
			body.eyes_red,
			body.eyes_green,
			body.eyes_blue
		FROM
			players
		INNER JOIN
			limbs
		ON
			(
				players.player_ckey = limbs.player_ckey)
		AND (
				players.player_slot = limbs.player_slot)
		INNER JOIN
			jobs
		ON
			(
				limbs.player_ckey = jobs.player_ckey)
		AND (
				limbs.player_slot = jobs.player_slot)
		INNER JOIN
			body
		ON
			(
				jobs.player_ckey = body.player_ckey)
		AND (
				jobs.player_slot = body.player_slot)
		WHERE
			players.player_ckey = ?
		AND players.player_slot = ?"}, ckey, 1)
	if(q.Execute(db))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			for(var/a in row)
				preference_list[a] = row[a]
	else
		message_admins("Player appearance loading error: [q.ErrorMsg()]")
		log_sql("Error: [q.ErrorMsg()]")
		return
	name = preference_list && preference_list.len && preference_list["real_name"] ? preference_list["real_name"] : ckey
	real_name = name
	if(dna)
		dna.real_name = real_name
	if(preference_list && preference_list.len)
		var/disabilities = text2num(preference_list["disabilities"])
		if(!isnull(preference_list["species"]))
			set_species(preference_list["species"])
			var/datum/species/chosen_species = all_species[preference_list["species"]]
			if( (disabilities & DISABILITY_FLAG_FAT) && (chosen_species.anatomy_flags & CAN_BE_FAT) )
				mutations += M_FAT
		setGender(sanitize_gender(preference_list["gender"]))

		my_appearance.r_eyes = sanitize_integer(preference_list["eyes_red"], 0, 255)
		my_appearance.g_eyes = sanitize_integer(preference_list["eyes_green"], 0, 255)
		my_appearance.b_eyes = sanitize_integer(preference_list["eyes_blue"], 0, 255)

		my_appearance.r_hair = sanitize_integer(preference_list["hair_red"], 0, 255)
		my_appearance.g_hair = sanitize_integer(preference_list["hair_green"], 0, 255)
		my_appearance.b_hair = sanitize_integer(preference_list["hair_blue"], 0, 255)

		my_appearance.r_facial = sanitize_integer(preference_list["facial_red"], 0, 255)
		my_appearance.g_facial = sanitize_integer(preference_list["facial_green"], 0, 255)
		my_appearance.b_facial = sanitize_integer(preference_list["facial_blue"], 0, 255)

		my_appearance.s_tone = sanitize_integer(preference_list["skin_tone"], -185, 34)

		my_appearance.h_style = sanitize_inlist(preference_list["hair_style_name"], hair_styles_list)
		my_appearance.f_style = sanitize_inlist(preference_list["facial_style_name"], facial_hair_styles_list)

		dna.ResetUIFrom(src)

		if(disabilities & DISABILITY_FLAG_NEARSIGHTED)
			disabilities|=NEARSIGHTED
		if(disabilities & DISABILITY_FLAG_EPILEPTIC)
			disabilities|=EPILEPSY
		if(disabilities & DISABILITY_FLAG_EHS)
			disabilities|=ELECTROSENSE
		if(disabilities & DISABILITY_FLAG_DEAF)
			sdisabilities|=DEAF
		if(disabilities & DISABILITY_FLAG_BLIND)
			sdisabilities|=BLIND

		var/list/organ_data = list()
		organ_data[LIMB_LEFT_ARM] = preference_list[LIMB_LEFT_ARM]
		organ_data[LIMB_RIGHT_ARM] = preference_list[LIMB_RIGHT_ARM]
		organ_data[LIMB_LEFT_LEG] = preference_list[LIMB_LEFT_LEG]
		organ_data[LIMB_RIGHT_LEG] = preference_list[LIMB_RIGHT_LEG]
		organ_data[LIMB_LEFT_FOOT]= preference_list[LIMB_LEFT_FOOT]
		organ_data[LIMB_RIGHT_FOOT]= preference_list[LIMB_RIGHT_FOOT]
		organ_data[LIMB_LEFT_HAND]= preference_list[LIMB_LEFT_HAND]
		organ_data[LIMB_RIGHT_HAND]= preference_list[LIMB_RIGHT_HAND]
		organ_data["heart"] = preference_list["heart"]
		organ_data["eyes"] 	= preference_list["eyes"]
		organ_data["lungs"] = preference_list["lungs"]
		organ_data["kidneys"]=preference_list["kidneys"]
		organ_data["liver"] = preference_list["liver"]

		for(var/name in organ_data)
			var/datum/organ/external/O = organs_by_name[name]
			var/datum/organ/internal/I = internal_organs_by_name[name]
			var/status = organ_data[name]

			if(status == "amputated")
				O.status &= ~ORGAN_ROBOT
				O.status &= ~ORGAN_PEG
				O.amputated = 1
				O.status |= ORGAN_DESTROYED
				O.destspawn = 1
			else if(status == "cyborg")
				O.status &= ~ORGAN_PEG
				O.status |= ORGAN_ROBOT
			else if(status == "peg")
				O.status &= ~ORGAN_ROBOT
				O.status |= ORGAN_PEG
			else if(status == "assisted")
				I?.mechassist()
			else if(status == "mechanical")
				I?.mechanize()
			else
				continue

		regenerate_icons()

/proc/asteroid_can_be_placed(var/datum/map_element/E, var/turf/start_turf)
	if(!E.width || !E.height) //If the map element doesn't have its width/height calculated yet, do it now
		E.assign_dimensions()
	var/result = check_complex_placement(start_turf, E.width, E.height)
	return result

/proc/stay_in_vault_area(var/datum/map_element/E, var/turf/start_turf)
	if(!E.width || !E.height) //If the map element doesn't have its width/height calculated yet, do it now
		E.assign_dimensions()

	for(var/area/A in block(locate(start_turf.x, start_turf.y, start_turf.z), locate(start_turf.x+E.width, start_turf.y+E.height, start_turf.z)))
		if(!istype(A, /area/random_vault))
			return 0

	return start_turf && (start_turf.z <= map.zDeepSpace)

//Proc that populates a single area with many vaults, randomly
//A is the area OR a list of turfs where the placement happens
//map_element_objects is a list of vaults that have to be placed. Defaults to subtypes of /datum/map_element/vault (meaning all vaults are spawned)
//amount is the maximum amount of vaults placed. If -1, it will place as many vaults as it can
//POPULATION_DENSE is much more expensive and may lag with big areas
//POPULATION_SCARCE is cheaper but may not do the job as well
//NOTE: Vaults may be placed partially outside of the area. Only the lower left corner is guaranteed to be in the area

/proc/populate_area_with_vaults(area/A, list/map_element_objects, var/amount = -1, population_density = POPULATION_DENSE, filter_function, var/overwrites = FALSE)
	var/list/area_turfs

	if(ispath(A, /area))
		A = locate(A)
	if(isarea(A))
		area_turfs = A.contents.Copy()
	else if(istype(A, /list))
		area_turfs = A
	ASSERT(area_turfs)

	if(!map_element_objects)
		map_element_objects = get_map_element_objects()

	message_admins("<span class='info'>Starting populating [isarea(A) ? "an area ([A])" : "a list of [area_turfs.len] turfs"] with vaults.")

	var/list/spawned = list()
	var/successes = 0
	var/list/invalid_bounds = list() // Previously we just removed everything in these bounds from valid_spawn_points, which costed about a second or two during placement, now totally eliminated.

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
					invalid_bounds[t1] = t2

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
		var/filter_counter = 0
		do
			sanity++
			new_spawn_point = pick(valid_spawn_points)
			valid_spawn_points.Remove(new_spawn_point)
			var/inbounds = FALSE
			for(var/turf/start in invalid_bounds) // And begin the invalid bounds checking. Might look like extra work, but is much faster than just removing blocks of spawn points.
				var/turf/end = invalid_bounds[start]
				if(start && end && new_spawn_point.x >= start.x && new_spawn_point.y >= start.y && new_spawn_point.x <= end.x && new_spawn_point.y <= end.y)
					inbounds = TRUE
					break
			if(inbounds || (filter_function && !call(filter_function)(ME, new_spawn_point)))
				new_spawn_point = null
				filter_counter++
				continue
			break
		while(sanity < 100)
		message_admins("TESTING: Filtered [filter_counter] turfs.")
		if(!new_spawn_point)
			continue
		var/vault_x = new_spawn_point.x
		var/vault_y = new_spawn_point.y
		var/vault_z = new_spawn_point.z
		var/vault_rotate = (config.disable_vault_rotation || !ME.can_rotate) ? 0 : pick(0,90,180,270)

		if(population_density == POPULATION_SCARCE)
			var/turf/t1 = locate(max(1, vault_x - MAX_VAULT_WIDTH - 1), max(1, vault_y - MAX_VAULT_HEIGHT - 1), vault_z)
			var/turf/t2 = locate(vault_x + new_width, vault_y + new_height, vault_z)
			invalid_bounds[t1] = t2

		var/timestart = world.timeofday
		if(ME.load(vault_x, vault_y, vault_z, vault_rotate, overwrites))
			var/timetook2load = world.timeofday - timestart
			spawned.Add(ME)
			log_debug("Loaded [ME.file_path] in [timetook2load / 10] seconds at ([vault_x],[vault_y],[vault_z])[(config.disable_vault_rotation || !ME.can_rotate) ? "" : ", rotated by [vault_rotate] degrees"].",FALSE)
			message_admins("<span class='info'>Loaded [ME.file_path] in [timetook2load / 10] seconds: [formatJumpTo(locate(vault_x, vault_y, vault_z))] [(config.disable_vault_rotation || !ME.can_rotate) ? "" : ", rotated by [vault_rotate] degrees"].</span>")
			if(!ME.can_rotate)
				message_admins("<span class='info'>[ME.file_path] was not rotated, can_rotate was set to FALSE.</span>")
			else if(config.disable_vault_rotation)
				message_admins("<span class='info'>[ME.file_path] was not rotated, DISABLE_VAULT_ROTATION enabled in config.</span>")
			successes++
			if(amount > 0)	//Allowing overflow is intentional, ie: 1 point left and the last picked vault costs 4 points
				if(istype(ME, /datum/map_element/vault))
					var/datum/map_element/vault/VE = ME
					amount -= VE.spawn_cost
				else
					amount--
			if(amount <= 0)
				break
		else
			message_admins("<span class='danger'>Can't find [ME.file_path]!</span>")

		CHECK_TICK

	return successes

#undef POPULATION_DENSE
#undef POPULATION_SCARCE
