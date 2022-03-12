/datum/objective/time_agent_extract
	name = "extract through anomaly"
	var/obj/effect/anomaly
	var/extracted = FALSE

/datum/objective/time_agent_extract/PostAppend()
	if(time_anomaly_list.len == 0)
		var/list/potential_locations = list()
		for(var/area/maintenance/A in areas)
			potential_locations.Add(A)
		var/placed = FALSE
		while(!placed && potential_locations.len)
			var/area/maintenance/A = pick(potential_locations)
			potential_locations.Remove(A)
			for(var/turf/simulated/floor/F in A.contents)
				if(!F.has_dense_content())
					anomaly = new /obj/effect/time_anomaly(F)
					placed = TRUE
					break
	else
		anomaly = time_anomaly_list[1]
	for(var/obj/item/weapon/pinpointer/advpinpointer/time_agent/TAP in pinpointer_list)
		if(anomaly)
			TAP.target = anomaly
	explanation_text = format_explanation()
	return TRUE

/datum/objective/time_agent_extract/IsFulfilled()
	.=..()
	if(extracted)
		return TRUE

/datum/objective/time_agent_extract/format_explanation()
	return "Escape through \the [anomaly], located in [format_text(get_area(anomaly).name)] ([anomaly.x-WORLD_X_OFFSET[anomaly.z]], [anomaly.y-WORLD_Y_OFFSET[anomaly.z]], [anomaly.z]). Use your jump charge to activate it."

/obj/effect/time_anomaly
	name = "anomaly"
	desc = "A hole in time and space.<br><span class = 'sinister'>Looking into it is like looking at a picture of yourself looking at a picture of yourself ad infinitum. Looking further, you swear one or two turn their head to look back at you.</span>"
	icon = 'icons/effects/effects.dmi'
	icon_state = "time_anomaly"
	anchored = 1
	mouse_opacity = 1
	flags = TIMELESS
	var/last_effect

/obj/effect/time_anomaly/New()
	..()
	processing_objects.Add(src)
	last_effect = world.time
	playsound(loc, 'sound/effects/portal_open.ogg', 60, 1)
	set_light(3, l_color = LIGHT_COLOR_CYAN)
	time_anomaly_list += src

/obj/effect/time_anomaly/process()
	if(world.time >= last_effect+30 SECONDS)
		last_effect = world.time
		if(prob(60))
			timestop(src, rand(5,15) SECONDS, rand(3, 7))
		else
			past_rift(src, rand(7, 15) SECONDS, rand(3, 5))

/obj/effect/time_anomaly/Destroy()
	playsound(loc,'sound/effects/portal_close.ogg',60,1)
	time_anomaly_list -= src
	..()
