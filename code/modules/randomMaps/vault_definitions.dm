var/list/existing_vaults = list()

/datum/map_element/vault
	type_abbreviation = "V"

	var/require_dungeons = 0 //If 1, don't spawn on maps without a dungeon location defined (see code/modules/randomMaps/dungeons.dm)

	var/list/exclusive_to_maps = list() //Only spawn on these maps (accepts nameShort and nameLong, for more info see maps/_map.dm). No effect if empty
	var/list/map_blacklist = list() //Don't spawn on these maps

	var/only_spawn_once = 1 //If 0, this vault can spawn multiple times on a single map

	var/base_turf_type = /turf/space //The "default" turf type that surrounds this vault. If it differs from the z-level's base turf type (for example if this vault is loaded on a snow map), all turfs of this type will be replaced with turfs of the z-level's base turf type

	var/spawn_cost = 3	//The amount of "points" a vault costs to spawn, much larger/complicated vaults costing more, with simpler costing less
	//Spawn cost's will be defined even if inheretence makes it redundant, this is because vault makers are often less experienced with code and so the clarity will help

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
	can_rotate = TRUE
	spawn_cost = 1

/datum/map_element/vault/asteroid_temple
	file_path = "maps/randomvaults/asteroid_temple.dmm"
	can_rotate = TRUE
	spawn_cost = 2

/datum/map_element/vault/asteroid_temple/initialize(list/objects)
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

/datum/map_element/vault/gingerbread_house
	file_path = "maps/randomvaults/gingerbread_house.dmm"
	can_rotate = TRUE
	spawn_cost = 4

/datum/map_element/vault/tommyboyasteroid
	file_path = "maps/randomvaults/tommyboyasteroid.dmm"
	can_rotate = TRUE
	spawn_cost = 1

/datum/map_element/vault/hivebot_factory
	file_path = "maps/randomvaults/hivebot_factory.dmm"
	can_rotate = TRUE
	spawn_cost = 3

/datum/map_element/vault/pretty_rad_clubhouse
	file_path = "maps/randomvaults/pretty_rad_clubhouse.dmm"
	can_rotate = TRUE
	spawn_cost = 2
/datum/map_element/vault/clown_base
	file_path = "maps/randomvaults/clown_base.dmm"
	can_rotate = TRUE
	spawn_cost = 3

/datum/map_element/vault/rust
	file_path = "maps/randomvaults/rust.dmm"
	can_rotate = TRUE
	spawn_cost = 2
/datum/map_element/vault/dance_revolution
	name = "Dance Dance Revolution"
	file_path = "maps/randomvaults/dance_revolution.dmm"
	var/obj/structure/dance_dance_revolution/machine
	spawn_cost = 2

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
	can_rotate = TRUE
	spawn_cost = 1

/datum/map_element/vault/oldarmory
	file_path = "maps/randomvaults/oldarmory.dmm"
	can_rotate = TRUE
	spawn_cost = 5

/datum/map_element/vault/spacepond
	file_path = "maps/randomvaults/spacepond.dmm"
	spawn_cost = 1

/datum/map_element/vault/spacepond/pre_load()
	load_dungeon(/datum/map_element/dungeon/wine_cellar,rotation)

/datum/map_element/dungeon/wine_cellar
	file_path = "maps/randomvaults/dungeons/wine_cellar.dmm"

/datum/map_element/vault/iou_vault
	file_path = "maps/randomvaults/iou_fort.dmm"
	can_rotate = TRUE
	spawn_cost = 1

/datum/map_element/vault/biodome
	file_path = "maps/randomvaults/biodome.dmm"
	spawn_cost = 2

/datum/map_element/vault/asteroids
	file_path = "maps/randomvaults/asteroids.dmm"
	can_rotate = TRUE
	spawn_cost = 2

/datum/map_element/vault/listening
	file_path = "maps/randomvaults/listening.dmm"
	spawn_cost = 3

/datum/map_element/vault/hivebot_crash
	file_path = "maps/randomvaults/hivebot_crash.dmm"
	can_rotate = TRUE
	spawn_cost = 1

/datum/map_element/vault/prison
	file_path = "maps/randomvaults/prison_ship.dmm"
	spawn_cost = 2

/datum/map_element/vault/prison/pre_load()
	load_dungeon(/datum/map_element/dungeon/prison,rotation)

/datum/map_element/dungeon/prison
	file_path = "maps/randomvaults/dungeons/prison.dmm"

/datum/map_element/vault/AIsat
	file_path = "maps/randomvaults/AIsat.dmm"
	can_rotate = TRUE
	spawn_cost = 1

/datum/map_element/vault/ejectedengine
	file_path = "maps/randomvaults/ejectedengine.dmm"
	can_rotate = TRUE
	spawn_cost = 3

/datum/map_element/vault/droneship
	file_path = "maps/randomvaults/droneship.dmm"
	spawn_cost = 3

/datum/map_element/vault/amelab
	file_path = "maps/randomvaults/amelab.dmm"
	spawn_cost = 3

/datum/map_element/vault/soulblade_sanctum
	file_path = "maps/randomvaults/soulblade_sanctum.dmm"
	spawn_cost = 3

/datum/map_element/vault/meteorlogical_station
	file_path = "maps/randomvaults/meteorlogical_station.dmm"
	spawn_cost = 4

/datum/map_element/vault/taxi_engi
	file_path = "maps/randomvaults/taxi_engineering.dmm"
	can_rotate = TRUE
	spawn_cost = 2

/datum/map_element/vault/ice_comet
	file_path = "maps/randomvaults/ice_comet.dmm"
	can_rotate = TRUE
	spawn_cost = 1

/datum/map_element/vault/research_facility
	file_path = "maps/randomvaults/research_facility.dmm"
	can_rotate = TRUE
	spawn_cost = 4

/datum/map_element/vault/zoo_truck
	file_path = "maps/randomvaults/zoo_truck.dmm"
	can_rotate = TRUE
	spawn_cost = 3

/datum/map_element/vault/syndiecargo
	file_path = "maps/randomvaults/syndiecargo.dmm"
	spawn_cost = 4

/datum/map_element/vault/black_site_prism
	file_path = "maps/randomvaults/black_site_prism.dmm"
	spawn_cost = 5

/datum/map_element/vault/skeleton_den
	file_path = "maps/randomvaults/rattlemebones.dmm"
	spawn_cost = 3

/datum/map_element/vault/beach_party
	file_path = "maps/randomvaults/beach_party.dmm"
	spawn_cost = 1

/datum/map_element/vault/zathura
	file_path = "maps/randomvaults/house.dmm"
	can_rotate = TRUE
	spawn_cost = 1

/datum/map_element/vault/spy_sat
	file_path = "maps/randomvaults/spy_satellite.dmm"
	spawn_cost = 3

/datum/map_element/vault/spy_sat/pre_load()
	load_dungeon(/datum/map_element/dungeon/satellite_deployment,rotation)

/datum/map_element/dungeon/satellite_deployment
	file_path = "maps/randomvaults/dungeons/satellite_deployment.dmm"

/datum/map_element/vault/ironchef
	file_path = "maps/randomvaults/ironchef.dmm"
	spawn_cost = 3

/datum/map_element/vault/assistantslair
	file_path = "maps/randomvaults/assistantslair.dmm"
	spawn_cost = 3

/datum/map_element/vault/asteroidfield
	file_path = "maps/randomvaults/asteroidfield.dmm"
	can_rotate = TRUE
	spawn_cost = 2

/datum/map_element/vault/clownroid
	file_path = "maps/randomvaults/clownroid.dmm"
	can_rotate = TRUE
	spawn_cost = 3

/datum/map_element/vault/goonesat
	file_path = "maps/randomvaults/goonesat.dmm"
	can_rotate = TRUE
	spawn_cost = 3

/datum/map_element/vault/podstation
	file_path = "maps/randomvaults/podstation.dmm"
	spawn_cost = 2

/datum/map_element/vault/mini_station
	file_path = "maps/randomvaults/mini_station.dmm"
	spawn_cost = 2

/datum/map_element/dungeon/habitation
	file_path = "maps/randomvaults/dungeons/habitation.dmm"

/datum/map_element/dungeon/research
	file_path = "maps/randomvaults/dungeons/research.dmm"

/datum/map_element/vault/fastfoodjoint
	name = "Fast food joint"
	file_path = "maps/randomvaults/fastfoodjoint.dmm"
	spawn_cost = 2

/datum/map_element/vault/laundromat
	file_path = "maps/randomvaults/laundromat.dmm"
	spawn_cost = 3

/datum/map_element/vault/laundromat/pre_load()
	load_dungeon(/datum/map_element/dungeon/laundromat_drug_lab,rotation)

/datum/map_element/dungeon/laundromat_drug_lab
	file_path = "maps/randomvaults/dungeons/laundromat_drug_lab.dmm"

/datum/map_element/vault/thestranger
	file_path = "maps/randomvaults/thestranger.dmm"
	spawn_cost = 2

/area/vault/thestranger
	name = "The Stranger"

/datum/map_element/vault/poddock_crash
	file_path = "maps/randomvaults/pod_dock_crash.dmm"
	spawn_cost = 1

/area/vault/dockruins
	name = "Ruined Pod Dock"

/datum/map_element/vault/radioactivedust
	file_path = "maps/randomvaults/ButtonPusher.dmm"
	spawn_cost = 2

/area/vault/radioactivelab
	name = "Material Synthesis Research"
	requires_power = 1

/area/vault/radioactivecatwalk
	name = "Research Laboratory Catwalk"
	dynamic_lighting = 0
