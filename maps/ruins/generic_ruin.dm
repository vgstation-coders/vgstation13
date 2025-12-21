/datum/map_element/ruin/digsite_ruin
	name="Abandoned Digsite"
	file_path = "maps/ruins/generic/abandoned_digsite_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/amelab
	file_path = "maps/ruins/generic/amelab_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

// Too big for default 99x99 planets.
// /datum/map_element/ruin/assistantslair
// 	file_path = "maps/ruins/generic/assistantslair_ruin.dmm"
// 	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
//  cost = RUIN_COST_HEAVY

/datum/map_element/ruin/asteroid_temple
	file_path = "maps/ruins/generic/asteroid_temple_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_MEDIUM

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

/datum/map_element/ruin/mine_bar_ruin
	name = "The Buried Bar"
	desc = "A miner walks into a bar, Dusky says \"Sorry, you're too young to be served\"."
	file_path = "maps/ruins/generic/bar2.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/crash
	file_path = "maps/ruins/generic/crash.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_SNOW|RUIN_TYPE_URBAN|RUIN_TYPE_XENO
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/crashed_pod_ruin
	name="Crashed Pod"
	file_path = "maps/ruins/generic/crashed_pod_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN|RUIN_TYPE_XENO
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/crashed_tradeship_ruin
	name="Crashed Tradeship"
	file_path = "maps/ruins/generic/crashed_tradeship_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN|RUIN_TYPE_XENO
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/cultbase_ruin
	name = "Cult Base"
	desc = "An evil lurks within these walls."
	file_path = "maps/ruins/generic/cultbase_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/dance_revolution
	name = "Dance Dance Revolution"
	file_path = "maps/ruins/generic/dance_revolution_ruin.dmm"
	var/obj/structure/dance_dance_revolution/machine
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

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

/datum/map_element/ruin/fastfoodjoint
	name = "Fast food joint"
	file_path = "maps/ruins/generic/fastfoodjoint_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/geode_ruin
	name="Geode"
	file_path = "maps/ruins/generic/geode_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/zathura
	file_path = "maps/ruins/generic/house_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/kennel
	file_path = "maps/ruins/generic/kennel.dmm"
	ruin_type = RUIN_TYPE_SNOW|RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/laundromat
	file_path = "maps/ruins/generic/laundromat_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/laundromat/pre_load()
	load_dungeon(/datum/map_element/dungeon/laundromat_drug_lab,rotation)

/datum/map_element/ruin/podstation
	file_path = "maps/ruins/generic/podstation_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/pretty_rad_clubhouse
	file_path = "maps/ruins/generic/pretty_rad_clubhouse_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/prison
	file_path = "maps/ruins/generic/prison_ship_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/prison/pre_load()
	load_dungeon(/datum/map_element/dungeon/prison,rotation)

/datum/map_element/ruin/soulblade_sanctum
	file_path = "maps/ruins/generic/soulblade_sanctum_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/spacegym
	file_path = "maps/ruins/generic/spacegym_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/spacepond
	file_path = "maps/ruins/generic/spacepond_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_TROPICAL|RUIN_TYPE_WET
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/spacepond/pre_load()
	load_dungeon(/datum/map_element/dungeon/wine_cellar,rotation)
