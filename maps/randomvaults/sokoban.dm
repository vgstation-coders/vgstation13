

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

	//List of all dungeons linked to this
	var/list/loaded_levels = list()

	//List of all teleporters in all the dungeons. Used for tracking cheating/completion
	var/list/teleporters = list()

	var/cheated = FALSE
	var/winner_name = "" //Name displayed on the scoreboard


/datum/map_element/vault/sokoban/process_scoreboard()
	var/list/L = list()

	if(cheated)
		L += "[winner_name ? winner_name : "Somebody"] cheated, destroying the reward."
	else
		if(winner_name)
			L += "[winner_name] had successfully completed the puzzle, and claimed the reward."

	return L

/datum/map_element/vault/sokoban/pre_load()
	//Load random levels
	for(var/i = 1 to level_amount)
		var/datum/map_element/dungeon/sokoban_level/SL = new /datum/map_element/dungeon/sokoban_level

		SL.depth = i
		SL.file_path = pick_n_take(src.available_levels) //No duplicate levels
		SL.parent = src

		load_dungeon(SL)
		loaded_levels.Add(SL)

	//Load ending
	var/datum/map_element/dungeon/sokoban_level/END = new /datum/map_element/dungeon/sokoban_level

	END.depth = level_amount+1
	END.file_path = pick(src.available_endings)
	END.parent = src

	load_dungeon(END)
	loaded_levels.Add(END)

/datum/map_element/vault/sokoban/proc/on_cheat()
	for(var/datum/map_element/dungeon/sokoban_level/L in loaded_levels)
		if(L.reward)
			var/turf/current_loc = get_turf(L.reward)
			//Don't destroy the reward if it has been picked up
			if(current_loc != L.reward_turf)
				continue

			var/obj/item/toy/figure/clown/cheater_trophy = new /obj/item/toy/figure/clown(current_loc)
			cheater_trophy.name = "cheater's trophy"
			cheater_trophy.desc = "No prize for you!"

			qdel(L.reward)
			L.reward = null

	if(!cheated)
		if(usr)
			to_chat(usr, "<span class='userdanger'>Cheater!</span>")

		cheated = TRUE
		winner_name = "[usr] ([usr.key])"

/datum/map_element/vault/sokoban/proc/mark_winner()
	//Check if the 'winner' bypassed any teleporters. If they did, they're a cheater
	for(var/obj/structure/sokoban_teleporter/T in teleporters)
		if(T.active || !isturf(T.loc))
			on_cheat()
			return

	if(usr && !winner_name)
		winner_name = "[usr] ([usr.key])"

		to_chat(usr, "<b>You've completed Sokoban. Congratulations!</b>")

///////===========SOKOBAN LEVELS============

/datum/map_element/dungeon/sokoban_level
	var/datum/map_element/vault/sokoban/parent

	var/depth = 0

	//Objects that step on teleporters get teleported here
	var/turf/jail_turf

	var/atom/movable/reward
	var/turf/reward_turf //If there's a reward, this is the turf on which it was originally placed

/datum/map_element/dungeon/sokoban_level/initialize(list/objects)
	.=..()

	for(var/obj/structure/closet/crate/sokoban/crate in objects)
		//check_cheat performs some additional checks first, and only then marks the user as a cheater
		crate.on_destroyed.Add(crate, "check_cheat")
		crate.on_moved.Add(crate, "check_cheat")
		crate.parent = src.parent

	for(var/obj/structure/sokoban_teleporter/teleporter in objects)
		//Teleporters are supposed to be unmovable, so if they're moved or deleted - it's guaranteed cheating
		teleporter.on_destroyed.Add(parent, "on_cheat")
		teleporter.on_moved.Add(parent, "on_cheat")

		if(parent)
			parent.teleporters.Add(teleporter)

	for(var/obj/structure/ladder/sokoban/ladder in objects)
		//Entrance ladders are connected to previous level's exit ladder
		if(istype(ladder, /obj/structure/ladder/sokoban/entrance))
			ladder.id = "sokoban-[depth]"
			ladder.height = 1
		//Exit ladders are connected to next level's entrance ladder
		else if(istype(ladder, /obj/structure/ladder/sokoban/exit))
			ladder.id = "sokoban-[depth+1]"
			ladder.height = 0

	reward = track_atom(locate(/obj/item/clothing/suit/armor/laserproof/advanced) in objects)
	if(reward)
		reward_turf = get_turf(reward)
		reward.on_moved.Add(parent, "mark_winner")

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

	var/shipped = FALSE //Crate put on a teleporter

	var/datum/map_element/vault/sokoban/parent

/obj/structure/closet/crate/sokoban/proc/check_cheat()
	if(shipped)
		return //Teleported crates can be destroyed safely

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
		var/obj/structure/closet/crate/sokoban/S = AM
		S.shipped = TRUE

		qdel(S)
		visible_message("<span class='notice'>\The [src] shuts down!</span>")
		active = FALSE
		icon_state = "pad-offline"
	else if(istype(AM) && !isobserver(AM))
		var/turf/jail = get_turf(locate(/obj/effect/landmark/sokoban_jail) in landmarks_list)
		if(jail)
			AM.forceMove(jail)
		//Teleport this bitch to jail


/obj/structure/ladder/sokoban
	id = "sokoban-1" //Don't change this!

//Beginning of each level
/obj/structure/ladder/sokoban/entrance

//End of each level
/obj/structure/ladder/sokoban/exit

//Players who step on teleporters are dropped here
/obj/effect/landmark/sokoban_jail

///////LORE///////
/obj/item/weapon/paper/sokoban
	name = "paper- 'The Puzzle'"
	info = {" This is some sort of a cruel joke. They know they can't fire me, so they're trying to make me quit on my own. The quartermaster built some sort of a puzzle for me to solve. I fucking hate puzzles.
 <br><br>
 Apparently I have to put a crate on each of the twelve teleporters. Sounds easy enough, right? Well, he took away my forklift for 'maintenance', and coated every crate with lube, making them impossible to pull. The only way to move them is to push them from behind. If one of them gets stuck in a corner? Tough luck.
 <br>
 He also forbade using wrapping paper or any method of crate moving other than pushing. This is embarrassing and I feel utterly humiliated.
 <br><br>
 Did I mention that he is holding my invention, my prototype Vest of Reflection, hostage? He told me that if I were to break any of the rules, "something might happen to it"?
 So if I make one wrong move, my life's work will be destroyed.
 <br>
 I have until the end of the day to sort the crates out. I don't know if I can do this. I probably can't. Goodbye, cruel world.
 "}
