/datum/event/cult_eclipse
	endWhen = 30
	announceWhen = 5


/datum/event/cult_eclipse/can_start()
	return 0

/datum/event/cult_eclipse/announce()
	set_security_level("red")
	command_alert(/datum/command_alert/cult_eclipse_start)
	emergency_shuttle.force_shutdown()

/datum/event/cult_eclipse/end()
	SetUniversalState(/datum/universal_state)
	set_security_level("blue")
	command_alert(/datum/command_alert/cult_eclipse_end)
	emergency_shuttle.shutdown = 0
	ticker.StartThematic()


/datum/event/cult_eclipse/start()
	SetUniversalState(/datum/universal_state/eclipse)
	ticker.StartThematic("endgame")




////////////////////////////////////


/obj/effect/gateway/active/cult/eclipse
	luminosity=5
	light_color = LIGHT_COLOR_RED
	spawnable=list(
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,
		/mob/living/simple_animal/hostile/faithless/cult
	)
	var/list/spawned_mobs = list()

/obj/effect/gateway/active/cult/eclipse/Crossed()
	return


// Blood eclipse unversal state. It's a tamer version of the usual hell Universal state

/datum/universal_state/eclipse
	name = "Blood Eclipse"
	desc = "That's not good..."
	decay_rate = 0

/datum/universal_state/eclipse/OnTurfChange(var/turf/T)
	if(T.name == "space")
		T.overlays += image(icon = T.icon, icon_state = "hell01")
		T.underlays -= "hell01"
	else
		T.overlays -= image(icon = T.icon, icon_state = "hell01")

/datum/universal_state/eclipse/OnEnter()
	set background = 1

	var/datum/faction/bloodcult/B = locate(/datum/faction/bloodcult) in ticker.mode.factions
	if(B)
		B.update_cultist_uis()

	suspend_alert = 1
	convert_all_parallax()
	OverlayAndAmbientSet()

/datum/universal_state/eclipse/OnExit()
	suspend_alert = 0
	deconvert_all_parallax()
	CleanUp()

/datum/universal_state/eclipse/OverlayAndAmbientSet()
	set waitfor = FALSE

	for(var/datum/lighting_corner/C in global.all_lighting_corners)
		if (!C.active)
			continue

		C.update_lumcount(0.5, 0, 0)
		CHECK_TICK

/datum/universal_state/eclipse/proc/CleanUp()
	for(var/datum/lighting_corner/C in global.all_lighting_corners)
		if (!C.active)
			continue

		C.update_lumcount(-0.5, 0, 0)
		CHECK_TICK

/datum/universal_state/eclipse/proc/convert_all_parallax()
	for(var/client/C in clients)
		var/obj/abstract/screen/plane_master/parallax_spacemaster/PS = locate() in C.screen
		if(PS)
			convert_parallax(PS)
		CHECK_TICK

/datum/universal_state/eclipse/convert_parallax(obj/abstract/screen/plane_master/parallax_spacemaster/PS)
	PS.color = list(
	0,0,0,0,
	0,0,0,0,
	0,0,0,0,
	1,0,0,1)

/datum/universal_state/eclipse/proc/deconvert_all_parallax()
	for(var/client/C in clients)
		var/obj/abstract/screen/plane_master/parallax_spacemaster/PS = locate() in C.screen
		if(PS)
			deconvert_parallax(PS)
		CHECK_TICK

/datum/universal_state/eclipse/proc/deconvert_parallax(obj/abstract/screen/plane_master/parallax_spacemaster/PS)
	PS.color = list(
	0,0,0,0,
	0,0,0,0,
	0,0,0,0,
	1,1,1,1)