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
		/datum/job/librarian,
		/datum/job/mommi,
		/datum/job/orderly,
		/datum/job/paramedic,
		/datum/job/rd,
		/datum/job/roboticist,
		/datum/job/scientist,
		/datum/job/xenoarchaeologist,
		/datum/job/xenobiologist,
		)

	center_x = 150
	center_y = 150
	planet_size = 140
	shuttle_call_label = "Begin Bluespace Jump"
	shuttle_cancel_label = "Cancel Bluespace Jump"

	event_whitelist = list(
		// Odyssey-native events
		/datum/event/micro_meteors,
		/datum/event/gib_storm,
		/datum/event/solar_flare,
		/datum/event/odyssey_carp_swarm,
		// Vanilla events with Odyssey overrides
		/datum/event/radiation_storm/odyssey,
		/datum/event/disease_outbreak/odyssey,
		/datum/event/viral_infection/odyssey,
		/datum/event/viral_outbreak/odyssey,
		/datum/event/ancientpod/odyssey,
		/datum/event/grid_check/odyssey,
		/datum/event/immovable_rod/odyssey,
		/datum/event/rogue_drone/odyssey,
		/datum/event/brand_intelligence/odyssey,
		/datum/event/old_vendotron_teleport/odyssey,
		// Vanilla events that work as-is
		/datum/event/organ_failure,
		/datum/event/mass_hallucination,
		/datum/event/pda_spam,
		/datum/event/money_lotto,
		/datum/event/money_hacker,
		/datum/event/profound_peace,
		/datum/event/hog/odyssey,
		/datum/event/ionstorm
	)

/datum/map/active/map_ruleset(var/datum/dynamic_ruleset/DR)
	if(ispath(DR.role_category,/datum/role/blob_overmind))
		return FALSE
	else if(ispath(DR.role_category,/datum/role/malfAI))
		return FALSE
	else if(ispath(DR.role_category,/datum/role/nuclear_operative))
		return FALSE
	return ..()

/datum/map/active/proc/get_ship_state()
	if(!ship_shuttle || !ship_shuttle.current_port)
		return 0
	var/datum/virtual_z/vz = ship_shuttle.current_port.get_virtual_z()
	if(!vz)
		return 0
	switch(vz.level_type)
		if(VZ_TRANSIT)
			return ODYSSEY_STATE_HYPERSPACE
		if(VZ_PARKING, VZ_SPACE)
			return ODYSSEY_STATE_DEEPSPACE
		if(VZ_PLANET)
			return ODYSSEY_STATE_PLANETSIDE
	return 0

/datum/map/active/proc/recently_on_planet()
	if(!ship_shuttle)
		return FALSE
	// Currently docked at a planet?
	if(ship_shuttle.current_port)
		var/datum/virtual_z/vz = ship_shuttle.current_port.get_virtual_z()
		if(vz && vz.level_type == VZ_PLANET)
			return TRUE
	// Or was within the last 15 minutes
	var/datum/shuttle/odyssey/O = ship_shuttle
	if(istype(O) && O.last_planet_dock_time && (world.time - O.last_planet_dock_time) < 15 MINUTES)
		return TRUE
	return FALSE

/datum/map/active/map_specific_event_checks(var/datum/event/E)
	var/required_state = 0
	if(istype(E, /datum/event/micro_meteors) || istype(E, /datum/event/gib_storm) || istype(E, /datum/event/immovable_rod/odyssey))
		required_state = ODYSSEY_STATE_HYPERSPACE
	else if(istype(E, /datum/event/solar_flare) || istype(E, /datum/event/radiation_storm/odyssey))
		required_state = ODYSSEY_STATE_HYPERSPACE | ODYSSEY_STATE_DEEPSPACE
	else if(istype(E, /datum/event/odyssey_carp_swarm) || istype(E, /datum/event/rogue_drone/odyssey))
		required_state = ODYSSEY_STATE_DEEPSPACE
	else if(istype(E, /datum/event/hog/odyssey))
		required_state = ODYSSEY_STATE_PLANETSIDE
	if(required_state && !(get_ship_state() & required_state))
		return 0
	return 1

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

/datum/command_alert/emergency_shuttle_called
	name = "Bluespace Jump Warning"
	alert_title = "Priority Announcement"
	force_report = 1
	alert = null
	justification = ""

/datum/command_alert/emergency_shuttle_called/announce()
	message = "The engines are charging in preparation for the Bluespace Jump. The ship will depart in [round(emergency_shuttle.timeleft()/60)] minutes."
	if(justification)
		message += " Justification: [justification]"
	..()

/datum/command_alert/emergency_shuttle_recalled
	name = "Bluespace Jump Cancelled"
	alert_title = "Priority Announcement"
	force_report = 1
	alert = null

/datum/command_alert/emergency_shuttle_recalled/announce()
	message = "The Bluespace Jump has been cancelled."
	..()

/datum/command_alert/emergency_shuttle_left
	name = "Bluespace Jump Initiated"
	alert_title = "Priority Announcement"
	force_report = 1

/datum/command_alert/emergency_shuttle_left/announce()
	message = "The Bluespace Jump has begun. Estimate [round(emergency_shuttle.timeleft()/60,1)] minutes until the NTEV Odyssey docks at Central Command."
	..()

////////////////////////////////////////////////////////////////
#undef OUTPOST_MAX_X
#undef OUTPOST_MAX_Y

#include "odyssey/areas.dm"
#include "odyssey/fixedvaults.dm"
#include "odyssey/shuttles.dm"
#include "odyssey/events.dm"
#include "odyssey/jobs.dm"
#include "odyssey.dmm"
#endif
