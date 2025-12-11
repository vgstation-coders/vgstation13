//See maps/ruins for dmm's

/area/ruin
	name = "ruin"
	icon = 'icons/turf/areas.dmi'
	icon_state = "ruin"

/area/exposed_ruin //allows daylight and weather
	name = "exposed ruin"
	icon_state = "ruin_exposed"

/datum/map_element/ruin/geode_ruin
	name="Geode"
	file_path = "maps/ruins/geode_ruin.dmm"
	can_rotate = TRUE

/datum/map_element/ruin/crashed_tradeship_ruin
	name="Crashed Tradeship"
	file_path = "maps/ruins/crashed_tradeship_ruin.dmm"
	can_rotate = TRUE

/datum/map_element/ruin/crashed_pod_ruin
	name="Crashed Pod"
	file_path = "maps/ruins/crashed_pod_ruin.dmm"
	can_rotate = TRUE

/datum/map_element/ruin/digsite_ruin
	name="Abandoned Digsite"
	file_path = "maps/ruins/abandoned_digsite_ruin.dmm"

/datum/map_element/ruin/aliens_ruin
	name="Alien Hive"
	file_path = "maps/ruins/huggernest_ruin.dmm"
	can_rotate = TRUE

/datum/map_element/ruin/mine_bar_ruin
	name = "The Buried Bar"
	desc = "A miner walks into a bar, Dusky says \"Sorry, you're too young to be served\"."

	file_path = "maps/ruins/bar_ruin.dmm"

/datum/map_element/ruin/cultbase_ruin
	name = "Cult Base"
	desc = "An evil lurks within these walls."

	file_path = "maps/ruins/cultbase_ruin.dmm"

/datum/map_element/ruin/asteroid_temple
	file_path = "maps/ruins/asteroid_temple_ruin.dmm"
	can_rotate = TRUE

/datum/map_element/ruin/asteroid_temple/initialize(list/objects)
	..(objects)

	var/list/all_spawns = list()
	for(var/obj/effect/landmark/catechizer_spawn/S in objects)
		all_spawns.Add(S)

	var/obj/effect/true_spawn = pick(all_spawns)
	all_spawns.Remove(true_spawn)

	var/obj/item/weapon/melee/morningstar/catechizer/original = new(get_turf(true_spawn))
	qdel(true_spawn)
	for(var/obj/effect/S in all_spawns)
		new /mob/living/simple_animal/hostile/mimic/crate/item(get_turf(S), original) //Make copies
		qdel(S)

/datum/map_element/ruin/pretty_rad_clubhouse
	file_path = "maps/ruins/pretty_rad_clubhouse_ruin.dmm"
	can_rotate = TRUE

/datum/map_element/ruin/dance_revolution
	name = "Dance Dance Revolution"
	file_path = "maps/ruins/dance_revolution_ruin.dmm"
	var/obj/structure/dance_dance_revolution/machine

/datum/map_element/ruin/dance_revolution/initialize(list/objects)
	.=..()
	machine = track_atom(locate(/obj/structure/dance_dance_revolution) in objects)

/datum/map_element/ruin/dance_revolution/process_scoreboard()
	var/list/L = list()

	if(!machine)
		L += "The game has been destroyed!"
	else if(machine.wins || machine.attempts)
		L += "[machine.attempts] attempts have been made in total."
		L += "Of them, [machine.wins] were successful."
		if(machine.winner)
			L += "The first dancer to successfully finish the game was [machine.winner]."
		else
			L += "Nobody was good enough to finish the game."

	return L

/datum/map_element/ruin/spacegym
	file_path = "maps/ruins/spacegym_ruin.dmm"
	can_rotate = TRUE

/datum/map_element/ruin/spacepond
	file_path = "maps/ruins/spacepond_ruin.dmm"

/datum/map_element/ruin/spacepond/pre_load()
	load_dungeon(/datum/map_element/dungeon/wine_cellar,rotation)

/datum/map_element/ruin/prison
	file_path = "maps/ruins/prison_ship_ruin.dmm"

/datum/map_element/ruin/prison/pre_load()
	load_dungeon(/datum/map_element/dungeon/prison,rotation)

/datum/map_element/ruin/amelab
	file_path = "maps/ruins/amelab_ruin.dmm"

/datum/map_element/ruin/soulblade_sanctum
	file_path = "maps/ruins/soulblade_sanctum_ruin.dmm"

/datum/map_element/ruin/zathura
	file_path = "maps/ruins/house_ruin.dmm"
	can_rotate = TRUE

/datum/map_element/ruin/ironchef
	file_path = "maps/ruins/ironchef_ruin.dmm"

/datum/map_element/ruin/assistantslair
	file_path = "maps/ruins/assistantslair_ruin.dmm"

/datum/map_element/ruin/podstation
	file_path = "maps/ruins/podstation_ruin.dmm"

/datum/map_element/ruin/fastfoodjoint
	name = "Fast food joint"
	file_path = "maps/ruins/fastfoodjoint_ruin.dmm"

/datum/map_element/ruin/laundromat
	file_path = "maps/ruins/laundromat_ruin.dmm"

/datum/map_element/ruin/laundromat/pre_load()
	load_dungeon(/datum/map_element/dungeon/laundromat_drug_lab,rotation)
