//See maps/ruins for dmm's

/area/ruin
	name = "ruin"
	icon = 'icons/turf/areas.dmi'
	icon_state = "ruin"
	base_turf_type = /turf/unsimulated/floor/planetary/grass

/area/ruin/surface //allows daylight and weather
	name = "exposed ruin"
	icon_state = "ruin_exposed"

/datum/map_element/ruin
	var/ruin_type = RUIN_TYPE_GENERIC
	var/cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/initialize(list/objects)
	..(objects)
	existing_vaults.Add(src)

	for(var/turf/new_turf in objects)
		new_turf.turf_flags |= NO_MINIMAP

/proc/get_ruin_list(var/whitelist = 0, var/blacklist = 0)
	var/list/ruin_list = list()
	var/list/added_types = list()
	if(!whitelist && !blacklist)
		ruin_list = subtypesof(/datum/map_element/ruin)
		for(var/R in ruin_list)
			ruin_list.Add(new R)
			ruin_list.Remove(R)
	else if(whitelist)
		for(var/type_flag in SSmapping.ruins_by_type)
			var/numeric_flag = text2num(type_flag)
			if(whitelist & numeric_flag)
				var/list/types = SSmapping.ruins_by_type[type_flag]
				for(var/R_type in types)
					if(!(R_type in added_types))
						added_types += R_type
						ruin_list.Add(new R_type)
		if(blacklist)
			for(var/datum/map_element/ruin/R in ruin_list)
				var/skip = FALSE
				for(var/type_flag in SSmapping.ruins_by_type)
					var/numeric_flag = text2num(type_flag)
					if(blacklist & numeric_flag)
						var/list/types = SSmapping.ruins_by_type[type_flag]
						if(types.Find(R.type))
							skip = TRUE
							break
				if(skip)
					ruin_list.Remove(R)
	else if(blacklist)
		ruin_list = subtypesof(/datum/map_element/ruin)
		for(var/R in ruin_list)
			var/skip = FALSE
			for(var/type_flag in SSmapping.ruins_by_type)
				var/numeric_flag = text2num(type_flag)
				if(blacklist & numeric_flag)
					var/list/types = SSmapping.ruins_by_type[type_flag]
					if(types.Find(R))
						skip = TRUE
						break
			if(!skip)
				ruin_list.Add(new R)
			ruin_list.Remove(R)
	return ruin_list

/proc/weighted_ruin_list(var/list/ruins,var/type_flag,var/factor = 3)
	var/list/weighted_list = list()
	for(var/datum/map_element/ruin/R in ruins)
		var/list/filtered_ruin_list = SSmapping.ruins_by_type["[type_flag]"]
		if(filtered_ruin_list.Find(R.type))
			for(var/i = 0; i < factor; i++)
				weighted_list.Add(R)
		else
			weighted_list.Add(R)
	return weighted_list

/////////////////////////////////////////////////////
/////////////// RUIN DEFINITIONS ////////////////////
/////////////////////////////////////////////////////
/datum/map_element/ruin/digsite_ruin
	name="Abandoned Digsite"
	file_path = "maps/ruins/abandoned_digsite_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/abandoned_hut
	file_path = "maps/ruins/abandoned_hut.dmm"
//	count=4
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/witch
	file_path = "maps/ruins/alchemistwitch.dmm"
//	count=1
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/amelab
	file_path = "maps/ruins/amelab_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

// Too big for default 99x99 planets.
// /datum/map_element/ruin/assistantslair
// 	file_path = "maps/ruins/assistantslair_ruin.dmm"
// 	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
//  cost = RUIN_COST_HEAVY

/datum/map_element/ruin/asteroid_temple
	file_path = "maps/ruins/asteroid_temple_ruin.dmm"
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

/datum/map_element/ruin/bar
	file_path = "maps/ruins/bar.dmm"
//	count=3
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE|RUIN_TYPE_TROPICAL
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/mine_bar_ruin
	name = "The Buried Bar"
	desc = "A miner walks into a bar, Dusky says \"Sorry, you're too young to be served\"."
	file_path = "maps/ruins/bar2.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/bearcave
	file_path = "maps/ruins/bearcave.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/buriedbody
	file_path = "maps/ruins/buriedbody.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/bus_stop
	file_path = "maps/ruins/bus_stop.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW|RUIN_TYPE_URBAN
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/cabin
	file_path = "maps/ruins/cabin.dmm"
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/campfire
	file_path = "maps/ruins/campfire_s.dmm"
//	count=6
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/campfire_corpse
	file_path = "maps/ruins/campfire_s_deadguy.dmm"
//	count=6
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/j5a
	file_path = "maps/ruins/cheater.dmm"
	can_rotate = FALSE
//	count=2
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/construction_site
	file_path = "maps/ruins/construction_site.dmm"
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/crash
	file_path = "maps/ruins/crash.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_SNOW|RUIN_TYPE_URBAN|RUIN_TYPE_XENO
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/crashed_pod_ruin
	name="Crashed Pod"
	file_path = "maps/ruins/crashed_pod_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN|RUIN_TYPE_XENO
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/crashed_tractor
	file_path = "maps/ruins/crashed_tractor.dmm"
//	count=3
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/crashed_tradeship_ruin
	name="Crashed Tradeship"
	file_path = "maps/ruins/crashed_tradeship_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN|RUIN_TYPE_XENO
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/cultbase_ruin
	name = "Cult Base"
	desc = "An evil lurks within these walls."
	file_path = "maps/ruins/cultbase_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/dance_revolution
	name = "Dance Dance Revolution"
	file_path = "maps/ruins/dance_revolution_ruin.dmm"
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

/datum/map_element/ruin/deerfeeder
	file_path = "maps/ruins/deerfeeder.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/druid
	file_path = "maps/ruins/druids_shack.dmm"
//	count=1
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/fastfoodjoint
	name = "Fast food joint"
	file_path = "maps/ruins/fastfoodjoint_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/frozenpond
	file_path = "maps/ruins/frozenpond.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/geode_ruin
	name="Geode"
	file_path = "maps/ruins/geode_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/geysercluster
	file_path = "maps/ruins/geysercluster.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/greatwhite
	file_path = "maps/ruins/greatwhite.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/grove
	file_path = "maps/ruins/grove.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/guncache
	file_path = "maps/ruins/guncache.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/hotspring
	file_path = "maps/ruins/hotspring.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/zathura
	file_path = "maps/ruins/house_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/aliens_ruin
	name="Alien Hive"
	file_path = "maps/ruins/huggernest_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_URBAN|RUIN_TYPE_XENO
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/huntinggrounds
	file_path = "maps/ruins/huntinggrounds.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/ironchef
	file_path = "maps/ruins/ironchef_ruin.dmm"
	ruin_type = RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/kennel
	file_path = "maps/ruins/kennel.dmm"
	ruin_type = RUIN_TYPE_SNOW|RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/laundromat
	file_path = "maps/ruins/laundromat_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/laundromat/pre_load()
	load_dungeon(/datum/map_element/dungeon/laundromat_drug_lab,rotation)

/datum/map_element/ruin/logging
	file_path = "maps/ruins/logging.dmm"
//	count=3
	ruin_type = RUIN_TYPE_JUNGLE
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/lostsnowmobile
	file_path = "maps/ruins/lostsnowmobile.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/mine_patch
	file_path = "maps/ruins/mine_patch.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/podbaby
	file_path = "maps/ruins/podbaby.dmm"
//	count=3
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/podstation
	file_path = "maps/ruins/podstation_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/pond
	file_path = "maps/ruins/pond.dmm"
	can_rotate = FALSE
//	count=4
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_TROPICAL|RUIN_TYPE_JUNGLE|RUIN_TYPE_WET
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/pretty_rad_clubhouse
	file_path = "maps/ruins/pretty_rad_clubhouse_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/prison
	file_path = "maps/ruins/prison_ship_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/prison/pre_load()
	load_dungeon(/datum/map_element/dungeon/prison,rotation)

/datum/map_element/ruin/rockysnow
	file_path = "maps/ruins/rockysnow.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/santacabin
	file_path = "maps/ruins/santacabin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/deadhunter
	file_path = "maps/ruins/slain_hunter.dmm"
//	count=3
	ruin_type = RUIN_TYPE_JUNGLE
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/soulblade_sanctum
	file_path = "maps/ruins/soulblade_sanctum_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/spacegym
	file_path = "maps/ruins/spacegym_ruin.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_URBAN
	cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/spacepond
	file_path = "maps/ruins/spacepond_ruin.dmm"
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_TROPICAL|RUIN_TYPE_WET
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/spacepond/pre_load()
	load_dungeon(/datum/map_element/dungeon/wine_cellar,rotation)

/datum/map_element/ruin/sunbath
	file_path = "maps/ruins/sunbath.dmm"
	can_rotate = FALSE
//	count=3
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE|RUIN_TYPE_TROPICAL
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/taxidermy
	file_path = "maps/ruins/taxi.dmm"
//	count=2
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/thermalplant
	file_path = "maps/ruins/thermalplant.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_HEAVY

/datum/map_element/ruin/trees
	file_path = "maps/ruins/trees.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/unfrozen_pond
	file_path = "maps/ruins/unfrozen_pond.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/drunkard
	file_path = "maps/ruins/wasted.dmm"
//	count=4
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/witchsabbath
	file_path = "maps/ruins/witchsabbath.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/wolfcave
	file_path = "maps/ruins/wolfcave.dmm"
	can_rotate = TRUE
	ruin_type = RUIN_TYPE_SNOW
	cost = RUIN_COST_LIGHT

/datum/map_element/ruin/zoo
	file_path = "maps/ruins/zoo.dmm"
	can_rotate = FALSE
//	count=1
	ruin_type = RUIN_TYPE_GENERIC|RUIN_TYPE_JUNGLE|RUIN_TYPE_TROPICAL|RUIN_TYPE_URBAN
	cost = RUIN_COST_HEAVY
