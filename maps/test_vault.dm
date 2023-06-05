#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Vault test
//**************************************************************
/datum/zLevel/vault
	name = "vault land"
	movementJammed = 1
	base_turf = /turf/unsimulated/floor/grass

/datum/map/active
	nameShort = "test_vault"
	nameLong = "Vaults test"
	map_dir = "test_vault"
	zLevels = list(/datum/zLevel/vault)
	enabled_jobs = list(/datum/job/trader)
	zCentcomm = 1

/datum/map/active/map_specific_init()
	generate_mapvaults()

/datum/map/active/generate_mapvaults()
	for(var/datum/map_element/ME in get_map_elements_from_config())
		load_dungeon(ME)
		new /obj/item/beacon(ME.location)

/datum/map/active/proc/get_map_elements_from_config()
	var/list/vaults = list()
	var/list/Lines = file2list("config/testvaults.txt")
	for(var/line in Lines)
		if(!length(line))
			continue
		if(copytext(line,1,2) == "#")
			continue
		if(copytext(line,1,2) == "/" && ispath(text2path(line),/datum/map_element))
			var/ourpath = text2path(line)
			vaults += new ourpath
	if(!vaults.len)
		return get_map_element_objects()
	return vaults

////////////////////////////////////////////////////////////////
#include "test_vault.dmm"
#endif
