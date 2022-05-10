/datum/event/lights_on
	announceWhen = 1
	endWhen = 300

/datum/event/lights_on/can_start(var/list/active_with_role)
	if(player_list.len <= 6 && world.time > 15 MINUTES && active_with_role["Engineering"] <= 0)
		for(var/obj/machinery/power/battery/smes/S in smes_list)
			if(S.avail())
				return 0
		return 25
	return 0

/datum/event/lights_on/start()
	spawn()
		command_alert(/datum/command_alert/lights_on)

		make_doors_all_access(list(access_engine_minor))

/datum/event/lights_on/tick()
	for(var/obj/machinery/power/battery/smes/S in smes_list)
		if(S.avail() && S.z == map.zMainStation)
			S.charge = S.capacity
			S.output = 200000
			S.online = 1
			S.update_icon()
			S.power_change()

/datum/event/lights_on/announce()
	// Don't do anything, we want to pack the announcement with the actual event

/datum/event/lights_on/end()
	revoke_doors_all_access(list(access_engine_minor))
