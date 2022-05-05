#define KEYCARD_DIFFICULTY_EASY "easy"
#define KEYCARD_DIFFICULTY_NORMAL "normal"
#define KEYCARD_DIFFICULTY_HARD "hard"

#define RED_KEYCARD_IN 1
#define BLUE_KEYCARD_IN 2
#define YELLOW_KEYCARD_IN 4

/datum/map_element/vault/keycards
	name = "Keycard-gate vault entrance"
	file_path = "maps/randomvaults/keycard_entrance.dmm"
	can_rotate = FALSE // It has dungeons, which don't rotate well for now
	var/difficulty = KEYCARD_DIFFICULTY_NORMAL
	var/datum/map_element/dungeon/keycard_vault/thevault

/datum/map_element/vault/keycards/pre_load()
	difficulty = pick(KEYCARD_DIFFICULTY_EASY,KEYCARD_DIFFICULTY_NORMAL,KEYCARD_DIFFICULTY_HARD)
	thevault = new /datum/map_element/dungeon/keycard_vault
	thevault.file_path = "maps/randomvaults/dungeons/keycard_vault_[difficulty].dmm"
	thevault.parent = src
	load_dungeon(thevault,rotation)
	var/static/list/keycard_find_types = list(
		KEYCARD_DIFFICULTY_EASY = /datum/map_element/keycard_find_easy,
		KEYCARD_DIFFICULTY_NORMAL = /datum/map_element/keycard_find_normal,
		KEYCARD_DIFFICULTY_HARD = /datum/map_element/keycard_find_hard,
	)
	var/vault_type = keycard_find_types[difficulty]
	var/list/list_of_vaults = get_map_element_objects(vault_type)
	var/area/A = locate(/area/random_vault)
	populate_area_with_vaults(A, list_of_vaults, 3, population_density = POPULATION_SCARCE, filter_function=/proc/stay_in_vault_area)
	var/list/keycard_landmarks = list()
	for(var/obj/effect/landmark/keycard/KC in landmarks_list)
		if(KC.name == "keycard-[difficulty]")
			keycard_landmarks.Add(KC)
	var/static/list/keycard_types = list(/obj/item/keycard/red,/obj/item/keycard/blue,/obj/item/keycard/yellow)
	for(var/key_type in keycard_types)
		var/obj/effect/landmark/keycard/LM = pick_n_take(keycard_landmarks)
		ASSERT(LM)
		new key_type(get_turf(LM))
		qdel(LM)

/datum/map_element/dungeon/keycard_vault
	name = "Keycard-gate vault proper"
	file_path = "maps/randomvaults/dungeons/keycard_vault_normal.dmm"
	var/datum/map_element/vault/keycards/parent

/datum/map_element/keycard_find_easy
	name = "Easy difficulty keycard find"

/datum/map_element/keycard_find_easy/type1
	file_path = "maps/misc/keycard_find_easy1.dmm"

/datum/map_element/keycard_find_easy/type2
	file_path = "maps/misc/keycard_find_easy2.dmm"

/datum/map_element/keycard_find_easy/type3
	file_path = "maps/misc/keycard_find_easy3.dmm"

/datum/map_element/keycard_find_normal
	name = "Normal difficulty keycard find"

/datum/map_element/keycard_find_normal/type1
	file_path = "maps/misc/keycard_find_normal1.dmm"

/datum/map_element/keycard_find_normal/type2
	file_path = "maps/misc/keycard_find_normal2.dmm"

/datum/map_element/keycard_find_normal/type3
	file_path = "maps/misc/keycard_find_normal3.dmm"

/datum/map_element/keycard_find_hard
	name = "Hard difficulty keycard find"

/datum/map_element/keycard_find_hard/type1
	file_path = "maps/misc/keycard_find_hard1.dmm"

/datum/map_element/keycard_find_hard/type2
	file_path = "maps/misc/keycard_find_hard2.dmm"

/datum/map_element/keycard_find_hard/type3
	file_path = "maps/misc/keycard_find_hard3.dmm"

/area/vault/keycard
	dynamic_lighting = FALSE // Area portals don't look good in this for now
	mysterious = TRUE

/obj/machinery/door/airlock/highsecurity/keycard
	name = "\improper Keycard-Gated Airlock"
	icon = 'icons/obj/doors/keycarddoor.dmi'
	var/keycard_status = 0

/obj/machinery/door/airlock/highsecurity/keycard/bump_open(mob/living/user)
	if(keycard_status == RED_KEYCARD_IN | BLUE_KEYCARD_IN | YELLOW_KEYCARD_IN)
		..()
	else
		denied()

//No getting around the keycard system
/obj/machinery/door/airlock/highsecurity/keycard/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/keycard))
		var/obj/item/keycard/K = I
		if(K.insert_type && !(keycard_status & K.insert_type))
			keycard_status |= K.insert_type
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			to_chat(user,"<span class='notice'>You insert \the [K] into \the [src]")
			overlays.Add(image(icon = src.icon, icon_state = K.name))
			qdel(K)
	add_fingerprint(user)
	return

/obj/machinery/door/airlock/highsecurity/keycard/ex_act(severity)
	return

/obj/machinery/door/airlock/highsecurity/keycard/emp_act(severity)
	return

/obj/machinery/door/airlock/highsecurity/keycard/emag_act()
	return

/obj/machinery/door/airlock/highsecurity/keycard/mech_drill_act(severity, child)
	return

/obj/machinery/door/airlock/highsecurity/keycard/singularity_act()
	return

/obj/machinery/door/airlock/highsecurity/keycard/singularity_pull(S, current_size, repel)
	return

/obj/machinery/door/airlock/highsecurity/keycard/horror_force(mob/living/carbon/human/H)
	return

/obj/machinery/door/airlock/highsecurity/keycard/blob_act()
	return

/obj/item/keycard
	name = "mysterious keycard"
	desc = "A keycard for opening a door somewhere"
	icon = 'icons/obj/device.dmi'
	icon_state = "keycard"
	var/insert_type = 0 // What kind of bitflag does this access on the door?

// Don't lose it
/obj/item/keycard/ex_act(severity)
	return

/obj/item/keycard/mech_drill_act(severity, child)
	return

/obj/item/keycard/singularity_act()
	return

/obj/item/keycard/blob_act()
	return

/obj/item/keycard/red
	name = "red keycard"
	insert_type = RED_KEYCARD_IN
	color = "#FF0000"

/obj/item/keycard/blue
	name = "blue keycard"
	insert_type = BLUE_KEYCARD_IN
	color = "#0000FF"

/obj/item/keycard/yellow
	name = "yellow keycard"
	insert_type = YELLOW_KEYCARD_IN
	color = "#FFFF00"

/obj/effect/landmark/keycard
	name = "keycard-normal"

/obj/effect/landmark/keycard/easy
	name = "keycard-easy"

/obj/effect/landmark/keycard/hard
	name = "keycard-hard"

#undef KEYCARD_DIFFICULTY_EASY
#undef KEYCARD_DIFFICULTY_NORMAL
#undef KEYCARD_DIFFICULTY_HARD

#undef RED_KEYCARD_IN
#undef BLUE_KEYCARD_IN
#undef YELLOW_KEYCARD_IN
