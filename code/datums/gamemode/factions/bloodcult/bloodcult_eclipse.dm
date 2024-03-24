

/datum/eclipse_manager
	var/eclipse_start_time = 0
	var/eclipse_end_time = 0
	var/eclipse_duration = 0
	var/eclipse_problem_announcement //set on eclipse_start()

	//light dimming
	var/light_reduction = 0.5

	var/timestopped	//sigh

	var/delay_first_announcement = 10 SECONDS	//time after the eclipse starts before it gets announced
	var/delay_end_announcement = 5 SECONDS		//time after the eclipse end before an announcement confirms it has ended
	var/delay_problem_announcement = 3 MINUTES	//how long after the eclipse's supposed end will the crew be warned (in case the cult is extending the eclipse's duration)

	var/problem_announcement = FALSE

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
	eclipse_problem_announcement = eclipse_end_time + delay_problem_announcement

	processing_objects += src
	sun.eclipse = ECLIPSE_ONGOING
	sun.eclipse_rate = light_reduction
	update_station_lights()

	world << sound('sound/effects/wind/wind_5_1.ogg')

	spawn (delay_first_announcement)
		command_alert(/datum/command_alert/eclipse_start)

/datum/eclipse_manager/proc/process()
	if (world.time >= eclipse_end_time)

		var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
		if (!cult || (!cult.tear_ritual && !cult.bloodstone))
			eclipse_end()
		else if (!cult.overtime_announcement)
			cult.overtime_announcement = TRUE
			for (var/datum/role/cultist in cult.members)
				var/mob/M = cultist.antag.current
				to_chat(M, "<span class='sinister'>The Eclipse is entering overtime. Even though its time as run out, Nar-Sie won't let it end as long as the Tear Reality rune is still active, or the Blood Stone is still standing.</span>")
		else if (!problem_announcement && (world.time >= eclipse_problem_announcement))
			problem_announcement = TRUE
			command_alert(/datum/command_alert/eclipse_too_long)

/datum/eclipse_manager/proc/eclipse_end()
	processing_objects -= src

	if(universe.name == "Hell Rising")
		return

	sun.eclipse = ECLIPSE_OVER
	sun.eclipse_rate = 1
	update_station_lights()

	spawn(delay_end_announcement)
		command_alert(/datum/command_alert/eclipse_end)

/datum/eclipse_manager/proc/update_station_lights()
	for (var/datum/light_source/LS in all_light_sources)
		if (LS.top_atom.z == map.zMainStation)
			LS.force_update()
			CHECK_TICK
