#define VOX_END_AREA /area/shuttle/vox/station

var/global/datum/shuttle/vox/vox_shuttle = new

/datum/shuttle/vox
	var/returned_home = 0
	var/area/area_home

	cant_leave_zlevel = list()

/datum/shuttle/vox/has_defined_areas()
	return 1

/datum/shuttle/vox/initialize()
	if(!areas || !areas.len)
		area_home = locate(VOX_END_AREA) in areas

/datum/shuttle/vox/New()
	.=..()
	setup_everything(starting_area = /area/shuttle/vox/station, \
		all_areas=list(/area/shuttle/vox/station,
			/area/vox_station/northeast_solars,
			/area/vox_station/northwest_solars,
			/area/vox_station/southeast_solars,
			/area/vox_station/southwest_solars,
			/area/vox_station/mining), \
		name = "vox skipjack", transit_area = /area/vox_station/transit, cooldown = 460, delay = 260)

/datum/shuttle/vox/travel_to(var/area/target_area, var/mob/user)
	if(target_area == area_home)
		if(ticker && istype(ticker.mode, /datum/game_mode/heist))
			switch(alert(usr,"Returning to dark space will end your raid and report your success or failure. Are you sure?","Vox Skipjack","Yes","No"))
				if("Yes")
					var/location = get_turf(user)
					message_admins("[key_name_admin(user)] attempts to end the raid - [formatJumpTo(location)]")
					log_admin("[key_name(user)] attempts to end the raid - [formatLocation(location)]")
				if("No")
					return

	..()

/datum/shuttle/vox/complete_movement(var/area/target_area)
	..()
	if(istype(target_area, VOX_END_AREA))
		returned_home = 1

/obj/machinery/computer/shuttle_control/vox
	icon_state = "syndishuttle"

	req_access = list(access_syndicate)

	light_color = LIGHT_COLOR_RED


/obj/machinery/computer/shuttle_control/vox/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(vox_shuttle)
	.=..()

#undef VOX_END_AREA