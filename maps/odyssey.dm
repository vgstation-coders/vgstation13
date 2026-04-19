#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- NTEV Odyssey
//**************************************************************
#define OUTPOST_MAX_X 110
#define OUTPOST_MAX_Y 110

//Would you believe me if I told you I had to indent these lines to prevent a compiler warning?
	config.skip_fixedvault_generation = TRUE //this are overwritten by the map, so we need to skip them here to avoid generating vaults on top of the map's fixed vaults
	config.skip_vault_generation = TRUE //this too lol
	map.skip_hobo_shack = TRUE //no hobo shack on the outpost, sorry hobos
	config.skip_holominimap_generation = TRUE //no holomaps on the odyssey

/datum/map/active
	nameShort = "odyssey"
	nameLong = "NTEV Odyssey"
	map_dir = "odyssey"
	zLevels = list(/datum/zLevel/dynamic/odyssey) //YEEHAW VLEVEL TIME
	load_map_elements = list(
		/datum/map_element/fixedvault/centcomm,
		/datum/map_element/dungeon/mecha_graveyard
	)
	load_custom_fixedvaults = list(
		/datum/map_element/fixedvault/derelict,
		/datum/map_element/fixedvault/dj_sat,
		/datum/map_element/fixedvault/vox_parking,
		/datum/map_element/fixedvault/rendezvous
	)
	enabled_jobs = list(/datum/job/trader)
	disabled_jobs = list(
		/datum/job/ai,
		/datum/job/chaplain,
		/datum/job/chemist,
		/datum/job/cmo,
		/datum/job/detective,
		/datum/job/geneticist,
		/datum/job/hos,
		/datum/job/hydro,
		/datum/job/lawyer,
		/datum/job/librarian,
		/datum/job/mechanic,
		/datum/job/mommi,
		/datum/job/orderly,
		/datum/job/paramedic,
		/datum/job/qm,
		/datum/job/rd,
		/datum/job/roboticist,
		/datum/job/scientist,
		/datum/job/virologist,
		/datum/job/xenoarchaeologist,
		/datum/job/xenobiologist,
		)

	center_x = 150
	center_y = 150
	planet_size = 140
	shuttle_call_label = "Begin Bluespace Jump"
	shuttle_cancel_label = "Cancel Bluespace Jump"

/datum/map/active/map_ruleset(var/datum/dynamic_ruleset/DR)
	if(ispath(DR.role_category,/datum/role/blob_overmind))
		return FALSE
	else if(ispath(DR.role_category,/datum/role/malfAI))
		return FALSE
	else if(ispath(DR.role_category,/datum/role/nuclear_operative))
		return FALSE
	return ..()

/datum/zLevel/dynamic/odyssey
	name = "odyssey"

/datum/zLevel/dynamic/odyssey/post_mapload()
	var/datum/virtual_z/new_vz = new(src, OUTPOST_MAX_X, OUTPOST_MAX_Y, 1, 1, skip_turf_setup = FALSE)
	new_vz.id = 1
	new_vz.name = "Nanotrasen Outpost"
	new_vz.level_type = VZ_PLANET
	daynight_v_lvls += new_vz
	new_vz.gps_allowed = TRUE
	new_vz.teleJammed = VZ_TELEPORTATION_ALLOWED
	new_vz.bluespace_jammed = FALSE
	new_vz.movementJammed = TRUE
	new_vz.transitionLoops = FALSE
	new_vz.base_turf = /turf/unsimulated/floor/planetary/grass/jungle
	new_vz.base_area = /area/surface/nt_outpost
	new_vz.update_settings()
	map.vLevels |= new_vz

	for(var/obj/docking_port/destination/D in all_docking_ports)
		if(D.vz() == new_vz.id)
			D.base_turf_type = /turf/unsimulated/floor/planetary/concrete
			D.refill_area = /area/surface/nt_outpost
	SSmapping.queue_planets(3)

/datum/map/active/map_specific_init()
	// Replace the standard emergency shuttle controller with the Odyssey version
	if(emergency_shuttle)
		qdel(emergency_shuttle)
	emergency_shuttle = new /datum/emergency_shuttle/odyssey()

	for(var/datum/virtual_z/vz in daynight_v_lvls)
		if(vz.name == "Nanotrasen Outpost")
			var/datum/climate/C = SSweather.set_climate(/datum/climate/temperate, vz)
			vz.register_weather_turfs(C)
			break

////////////////////////////////////////////////////////////////
#undef OUTPOST_MAX_X
#undef OUTPOST_MAX_Y

#include "odyssey/areas.dm"
#include "odyssey/fixedvaults.dm"
#include "odyssey/shuttles.dm"
#include "odyssey/events.dm"
#include "odyssey.dmm"
#endif
