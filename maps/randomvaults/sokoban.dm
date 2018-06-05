/datum/map_element/vault/sokoban
	name = "Sokoban"
	file_path = "maps/randomvaults/sokoban_entrance.dmm"

	var/list/available_levels = list(
	"maps/randomvaults/dungeons/sokoban/A.dmm",
	"maps/randomvaults/dungeons/sokoban/B.dmm",
	"maps/randomvaults/dungeons/sokoban/C.dmm",
	"maps/randomvaults/dungeons/sokoban/D.dmm",
	"maps/randomvaults/dungeons/sokoban/E.dmm"
	)

	var/level_amount = 3

	var/list/available_endings = list(
	"maps/randomvaults/dungeons/sokoban/END_1.dmm",
	"maps/randomvaults/dungeons/sokoban/END_2.dmm"
	)

	var/list/loaded_levels = list()

/datum/map_element/vault/sokoban/pre_load()
	//Load random levels
	for(var/i = 1 to level_amount)
		var/datum/map_element/dungeon/sokoban_level/SL = new /datum/map_element/dungeon/sokoban_level

		SL.depth = i
		SL.file_path = pick_n_take(src.available_levels) //No duplicate levels

		load_dungeon(SL)
		loaded_levels.Add(SL)

	//Load ending
	var/datum/map_element/dungeon/sokoban_level/END = new /datum/map_element/dungeon/sokoban_level

	END.depth = level_amount+1
	END.file_path = pick(src.available_endings)

	load_dungeon(END)
	loaded_levels.Add(END)


/datum/map_element/dungeon/sokoban_level
	var/depth = 0

	//Objects that step on teleporters get teleported here
	var/turf/jail_turf
	var/atom/movable/reward

/datum/map_element/dungeon/sokoban_level/initialize(list/objects)
	.=..()

	for(var/obj/structure/closet/crate/sokoban/crate in objects)
		crate.on_destroyed.Add(crate, "check_cheat")
		crate.on_moved.Add(crate, "check_cheat")
		crate.parent = src

	for(var/obj/structure/ladder/sokoban/ladder in objects)
		//Entrance ladders are connected to previous level's exit ladder
		if(istype(ladder, /obj/structure/ladder/sokoban/entrance))
			ladder.id = "sokoban-[depth]"
			ladder.height = 1
		//Exit ladders are connected to next level's entrance ladder
		else if(istype(ladder, /obj/structure/ladder/sokoban/exit))
			ladder.id = "sokoban-[depth+1]"
			ladder.height = 0

	reward = locate(/obj/item/clothing/suit/armor/laserproof/advanced) in objects

/datum/map_element/dungeon/sokoban_level/proc/on_cheat()
	if(reward)
		var/obj/item/toy/figure/clown/cheater_trophy = new /obj/item/toy/figure/clown(get_turf(level.reward))
		cheater_trophy.name = "cheater's trophy"
		cheater_trophy.desc = "Cheated at Sokoban!"

		qdel(level.reward)
		level.reward = null

		if(usr)
			to_chat(usr, "<span class='userdanger'>Cheater!</span>")

/*
This ladder stuff looks confusing, so here's an illustration!!!

*====ENTRANCE VAULT=====*
  ladder:           id "sokoban-1" -|
                    height 0        |
*=======LEVEL 1=========*           |
  entrance ladder:  id "sokoban-1" -|
                    height 1

  exit ladder:      id "sokoban-2" --
                    height 0        |
*=======LEVEL 2=========*           |
  entrance ladder:  id "sokoban-2" --
                    height 1

  exit ladder:      id "sokoban-3" --
                    height 0        |
*=======LEVEL 3=========*           |
  entrance ladder:  id "sokoban-3" --
                    height 1

......................
......And so on!......
*/

///////===========OBJECTS===========

//Entrance vault
/area/vault/sokoban
	dynamic_lighting = TRUE
	mysterious = TRUE

//Other levels
/area/vault/sokoban/level
	dynamic_lighting = FALSE //No lighting + transparent walls to make it less confusing
	mysterious = FALSE

//Crate
//- can't be opened or pulled
/obj/structure/closet/crate/sokoban
	desc = "A very heavy, tamperproof crate. A thin coating of space lube allows it to be slid around on the floor effortlessly, despite its massive weight. Unfortunately, this means it can't be grabbed at all."

	var/datum/map_element/dungeon/sokoban/parent

/obj/structure/closet/crate/sokoban/proc/check_cheat()
	var/cheated = FALSE

	if(!isturf(loc))
		cheated = TRUE

	if(parent && cheated)
		parent.on_cheat()

/obj/structure/closet/crate/sokoban/can_open()
	return FALSE

/obj/structure/closet/crate/sokoban/on_pull_start(mob/living/L)
	to_chat(L, "<span class='warning'>\The [src]'s smooth and slippery surface makes grabbing it impossible.</span>")
	L.stop_pulling()

//Teleporter
/obj/structure/sokoban_teleporter
	name = "warehouse telepad"
	desc = "A bluespace telepad used for teleporting crates to the drop point."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"

	plane = ABOVE_TURF_PLANE
	layer = ABOVE_TILE_LAYER

	anchored = TRUE
	density = FALSE

	var/active = TRUE

/obj/structure/sokoban_teleporter/Cross(atom/movable/AM)
	.=..()

	if(!active)
		return

	flick("pad-beam", src)

	if(istype(AM, /obj/structure/closet/crate/sokoban))
		qdel(AM)
		visible_message("<span class='notice'>\The [src] shuts down!</span>")
		active = FALSE
		icon_state = "pad-offline"
	else if(istype(AM))
		var/turf/jail = get_turf(locate(/obj/effect/landmark/sokoban_jail) in landmarks_list)
		if(jail)
			AM.forceMove(jail)
		//Teleport away


/obj/structure/ladder/sokoban
	id = "sokoban-1" //Don't change this!

/obj/structure/ladder/sokoban/entrance

/obj/structure/ladder/sokoban/exit

//Players who step on teleporters are dropped here
/obj/effect/landmark/sokoban_jail
