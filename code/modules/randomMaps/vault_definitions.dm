var/list/existing_vaults = list()

/datum/map_element/vault
	type_abbreviation = "V"

	var/require_dungeons = 0 //If 1, don't spawn on maps without a dungeon location defined (see code/modules/randomMaps/dungeons.dm)

	var/list/exclusive_to_maps = list() //Only spawn on these maps (accepts nameShort and nameLong, for more info see maps/_map.dm). No effect if empty
	var/list/map_blacklist = list() //Don't spawn on these maps

	var/only_spawn_once = 1 //If 0, this vault can spawn multiple times on a single map

	var/base_turf_type = /turf/space //The "default" turf type that surrounds this vault. If it differs from the z-level's base turf type (for example if this vault is loaded on a snow map), all turfs of this type will be replaced with turfs of the z-level's base turf type

/datum/map_element/vault/initialize(list/objects)
	..(objects)
	existing_vaults.Add(src)

	var/zlevel_base_turf_type = get_base_turf(location.z)
	if(!zlevel_base_turf_type)
		zlevel_base_turf_type = /turf/space

	for(var/turf/new_turf in objects)
		if(new_turf.type == base_turf_type) //New turf is vault's base turf
			if(new_turf.type != zlevel_base_turf_type) //And vault's base turf differs from zlevel's base turf
				new_turf.ChangeTurf(zlevel_base_turf_type)

		new_turf.turf_flags |= NO_MINIMAP //Makes the spawned turfs invisible on minimaps

//How to create a new vault:
//1) create a map in maps/randomVaults/
//2) create a new subtype of /datum/map_element/vault/ (look below for an example) and set its file_path to your map's file path (including the file extension, which is most likely ".dmm")
//3) if you're an advanced user, feel free to play around with other variables

/datum/map_element/vault/icetruck_crash
	file_path = "maps/randomvaults/icetruck_crash.dmm"

/datum/map_element/vault/asteroid_temple
	file_path = "maps/randomvaults/asteroid_temple.dmm"

/datum/map_element/vault/tommyboyasteroid
	file_path = "maps/randomvaults/tommyboyasteroid.dmm"

/datum/map_element/vault/hivebot_factory
	file_path = "maps/randomvaults/hivebot_factory.dmm"

/datum/map_element/vault/clown_base
	file_path = "maps/randomvaults/clown_base.dmm"

/datum/map_element/vault/rust
	file_path = "maps/randomvaults/rust.dmm"

/datum/map_element/vault/dance_revolution
	name = "Dance Dance Revolution"
	file_path = "maps/randomvaults/dance_revolution.dmm"
	var/obj/structure/dance_dance_revolution/machine

/datum/map_element/vault/dance_revolution/initialize(list/objects)
	.=..()

	machine = track_atom(locate(/obj/structure/dance_dance_revolution) in objects)

/datum/map_element/vault/dance_revolution/process_scoreboard()
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

/datum/map_element/vault/spacegym
	file_path = "maps/randomvaults/spacegym.dmm"

/datum/map_element/vault/oldarmory
	file_path = "maps/randomvaults/oldarmory.dmm"

/datum/map_element/vault/spacepond
	file_path = "maps/randomvaults/spacepond.dmm"

/datum/map_element/vault/spacepond/initialize(list/objects)
	..()

	load_dungeon(/datum/map_element/dungeon/wine_cellar)

/datum/map_element/dungeon/wine_cellar
	file_path = "maps/randomvaults/dungeons/wine_cellar.dmm"

/datum/map_element/vault/iou_vault
	file_path = "maps/randomvaults/iou_fort.dmm"

/datum/map_element/vault/biodome
	file_path = "maps/randomvaults/biodome.dmm"

/datum/map_element/vault/iou_vault
	file_path = "maps/randomvaults/iou_fort.dmm"

/datum/map_element/vault/asteroids
	file_path = "maps/randomvaults/asteroids.dmm"

/datum/map_element/vault/listening
	file_path = "maps/randomvaults/listening.dmm"

/datum/map_element/vault/hivebot_crash
	file_path = "maps/randomvaults/hivebot_crash.dmm"

/datum/map_element/vault/brokeufo
	file_path = "maps/randomvaults/brokeufo.dmm"

/datum/map_element/vault/prison
	file_path = "maps/randomvaults/prison_ship.dmm"

/datum/map_element/vault/prison/pre_load()
	load_dungeon(/datum/map_element/dungeon/prison)

/datum/map_element/dungeon/prison
	file_path = "maps/randomvaults/dungeons/prison.dmm"

/datum/map_element/vault/AIsat
	file_path = "maps/randomvaults/AIsat.dmm"

/datum/map_element/vault/ejectedengine
	file_path = "maps/randomvaults/ejectedengine.dmm"

/datum/map_element/vault/droneship
	file_path = "maps/randomvaults/droneship.dmm"

/datum/map_element/vault/meteorlogical_station
	file_path = "maps/randomvaults/meteorlogical_station.dmm"

/datum/map_element/vault/taxi_engi
	file_path = "maps/randomvaults/taxi_engineering.dmm"

/datum/map_element/vault/lightspeedship
	file_path = "maps/randomvaults/lightspeedship.dmm"

/datum/map_element/vault/ice_comet
	file_path = "maps/randomvaults/ice_comet.dmm"

/datum/map_element/vault/research_facility
	file_path = "maps/randomvaults/research_facility.dmm"

/datum/map_element/vault/zoo_truck
	file_path = "maps/randomvaults/zoo_truck.dmm"

/datum/map_element/vault/syndiecargo
	file_path = "maps/randomvaults/syndiecargo.dmm"

/datum/map_element/vault/skeleton_den
	file_path = "maps/randomvaults/rattlemebones.dmm"

/datum/map_element/vault/beach_party
	file_path = "maps/randomvaults/beach_party.dmm"

/datum/map_element/vault/zathura
	file_path = "maps/randomvaults/house.dmm"

/datum/map_element/vault/spy_sat
	file_path = "maps/randomvaults/spy_satellite.dmm"

/datum/map_element/vault/spy_sat/pre_load()
	load_dungeon(/datum/map_element/dungeon/satellite_deployment)

/datum/map_element/dungeon/satellite_deployment
	file_path = "maps/randomvaults/dungeons/satellite_deployment.dmm"

/datum/map_element/vault/ironchef
	file_path = "maps/randomvaults/ironchef.dmm"

/datum/map_element/vault/assistantslair
	file_path = "maps/randomvaults/assistantslair.dmm"

/datum/map_element/vault/asteroidfield
	file_path = "maps/randomvaults/asteroidfield.dmm"


/datum/map_element/vault/sokoban
	file_path = "maps/randomvaults/sokoban_entrance.dmm"

	var/list/available_levels = list(
	"maps/randomvaults/dungeons/sokoban/A.dmm",
	"maps/randomvaults/dungeons/sokoban/B.dmm",
	"maps/randomvaults/dungeons/sokoban/C.dmm",
	"maps/randomvaults/dungeons/sokoban/D.dmm",
	"maps/randomvaults/dungeons/sokoban/E.dmm",
	)

	var/level_amount = 3

	var/list/available_endings = list(
	"maps/randomvaults/dungeons/sokoban/END1.dmm"
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

/datum/map_element/dungeon/sokoban_level/initialize(list/objects)
	.=..()

	for(var/obj/structure/ladder/sokoban/ladder in objects)
		//Entrance ladders are connected to previous level's exit ladder
		if(istype(ladder, /obj/structure/ladder/sokoban/entrance))
			ladder.id = "sokoban-[depth]"
			ladder.height = 1
		//Exit ladders are connected to next level's entrance ladder
		else if(istype(ladder, /obj/structure/ladder/sokoban/exit))
			ladder.id = "sokoban-[depth+1]"
			ladder.height = 0

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
