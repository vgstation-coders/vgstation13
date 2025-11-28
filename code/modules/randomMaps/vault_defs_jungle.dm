/*
===============================================
==vaults exclusive to junglestation's surface==
===============================================
*/
/datum/map_element/junglevault
	type_abbreviation = "JV"
	can_rotate=TRUE
	var/base_turf_type = /turf/unsimulated/floor/jungle/grass
	var/count=0 //how many are added to the list to pick from. spawn weights, also how many are allowed to be spawned.

/datum/map_element/junglevault/initialize(list/objects)
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

	
/datum/map_element/junglevault/test
	file_path = "maps/randomvaults/jungle/test.dmm"
	can_rotate=FALSE
	count=0
/datum/map_element/junglevault/test/load(var/vault_x, var/vault_y, var/vault_z, var/vault_rotate, var/overwrites)
	world.log << "test vault loaded at [vault_x], [vault_y], [vault_z]."
	message_admins("test vault loaded at [vault_x], [vault_y], [vault_z].")
	return ..()


/datum/map_element/junglevault/campfire
	file_path = "maps/randomvaults/jungle/campfire_s.dmm"
	count=6

/datum/map_element/junglevault/campfire_corpse
	file_path = "maps/randomvaults/jungle/campfire_s_deadguy.dmm"
	count=6

/datum/map_element/junglevault/abandoned_hut
	file_path = "maps/randomvaults/jungle/abandoned_hut.dmm"
	count=4

/datum/map_element/junglevault/logging
	file_path = "maps/randomvaults/jungle/logging.dmm"
	count=3

/datum/map_element/junglevault/crashed_tractor
	file_path = "maps/randomvaults/jungle/crashed_tractor.dmm"
	count=3

/datum/map_element/junglevault/bar
	file_path = "maps/randomvaults/jungle/bar.dmm"
	count=3

/datum/map_element/junglevault/sunbath
	file_path = "maps/randomvaults/jungle/sunbath.dmm"
	can_rotate = FALSE
	count=3
	
/datum/map_element/junglevault/deadhunter
	file_path = "maps/randomvaults/jungle/slain_hunter.dmm"
	count=3	
	
/datum/map_element/junglevault/zoo
	file_path = "maps/randomvaults/jungle/zoo.dmm"
	can_rotate = FALSE
	count=1		
	
/datum/map_element/junglevault/druid
	file_path = "maps/randomvaults/jungle/druids_shack.dmm"
	count=1		

/datum/map_element/junglevault/pond
	file_path = "maps/randomvaults/jungle/pond.dmm"
	can_rotate = FALSE
	count=4		
	
/datum/map_element/junglevault/witch
	file_path = "maps/randomvaults/jungle/alchemistwitch.dmm"
	count=1	

/datum/map_element/junglevault/taxidermy
	file_path = "maps/randomvaults/jungle/taxi.dmm"
	count=2	
	
/datum/map_element/junglevault/drunkard
	file_path = "maps/randomvaults/jungle/wasted.dmm"
	count=4
	
/datum/map_element/junglevault/podbaby
	file_path = "maps/randomvaults/jungle/podbaby.dmm"
	count=3

/datum/map_element/junglevault/j5a
	file_path = "maps/randomvaults/jungle/cheater.dmm"
	can_rotate = FALSE
	count=2