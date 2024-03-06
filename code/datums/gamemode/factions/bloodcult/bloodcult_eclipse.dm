

/datum/eclipse_manager
	var/eclipse_start_time = 0
	var/eclipse_end_time = 0
	var/eclipse_duration = 0

	//light dimming
	var/min_rate = 0.5
	var/max_rate = 0.9
	var/update = 0

	var/timestopped

/proc/eclipse_trigger_cult()
	if (!sun || !sun.eclipse_manager)
		return
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!cult)
		return
	sun.eclipse_manager.eclipse_start(cult.eclipse_window)

/proc/eclipse_trigger_random()
	if (!sun || !sun.eclipse_manager)
		return
	sun.eclipse_manager.eclipse_start(rand(8 MINUTES, 12 MINUTES))

/datum/eclipse_manager/proc/eclipse_start(var/duration)
	eclipse_start_time = world.time
	eclipse_duration = duration
	eclipse_end_time = eclipse_start_time + eclipse_duration

	processing_objects += src
	world << sound('sound/effects/wind/wind_5_1.ogg')
	sun.eclipse = ECLIPSE_ONGOING
	update_station_lights()

	spawn (5 SECONDS)
		command_alert(/datum/command_alert/eclipse_start)

/datum/eclipse_manager/proc/process()
	update--
	if (update<=0)
		update = 5

		sun.eclipse_rate = min_rate + (max_rate - min_rate)/2 + ((max_rate - min_rate)/2 * cos((180 * (world.time - eclipse_start_time)) / eclipse_duration))
		//TODONEXT: Fix that, it's fading out over the entire eclipse duration

		update_station_lights()


/datum/eclipse_manager/proc/eclipse_end()
	processing_objects -= src
	sun.eclipse = ECLIPSE_OVER
	update_station_lights()

	spawn(5 SECONDS)
		command_alert(/datum/command_alert/eclipse_end)

/datum/eclipse_manager/proc/update_station_lights()
	for (var/datum/light_source/LS in all_light_sources)
		if (LS.top_atom.z == map.zMainStation)
			LS.force_update()
			CHECK_TICK
