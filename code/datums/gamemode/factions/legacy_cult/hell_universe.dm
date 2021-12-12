/*

In short:
 * Random area alarms
 * All areas jammed
 * Random gateways spawning hellmonsters (and turn people into cluwnes if ran into)
 * Broken APCs/Fire Alarms
 * Scary music
 * Random tiles changing to culty tiles.

*/
/datum/universal_state/hell
	name = "Hell Rising"
	desc = "OH FUCK OH FUCK OH FUCK"

	decay_rate = 5 // 5% chance of a turf decaying on lighting update/airflow (there's no actual tick for turfs)

/datum/universal_state/hell/OnShuttleCall(var/mob/user)
	return 1
	/*
	if(user)
		to_chat(user, "<span class='sinister'>All you hear on the frequency is static and panicked screaming. There will be no shuttle call today.</span>")
	return 0
	*/

/datum/universal_state/hell/DecayTurf(var/turf/T)
	if(!T.holy)
		T.cultify()
		for(var/obj/machinery/light/L in T.contents)
			new /obj/structure/cult_legacy/pylon(L.loc)
			qdel(L)
	return


/datum/universal_state/hell/OnTurfChange(var/turf/T)
	if(T.name == "space")
		T.overlays += image(icon = T.icon, icon_state = "hell01")
		T.underlays -= "hell01"
	else
		T.overlays -= image(icon = T.icon, icon_state = "hell01")

// Apply changes when entering state
/datum/universal_state/hell/OnEnter()
	set background = 1

	escape_list = get_area_turfs(locate(/area/hallway/secondary/exit))
	CHECK_TICK
	suspend_alert = 1

	convert_all_parallax()
	//separated into separate procs for profiling
	AreaSet()
	MiscSet()
	APCSet()
	KillMobs()
	OverlayAndAmbientSet()
	runedec += 9000	//basically removing the rune cap

	ticker.StartThematic("endgame")


/datum/universal_state/hell/proc/AreaSet()
	for(var/area/A in areas)
		if(!istype(A,/area) || isspace(A))
			continue

		// No cheating~
		A.jammed=2

		// Reset all alarms.
		A.fire     = null
		A.atmos    = 1
		A.atmosalm = 0
		A.poweralm = 1
		A.party    = null
		A.radalert = 0

/*
		// Slap random alerts on shit
		if(prob(25))
			switch(rand(1,4))
				if(1)
					A.fire=1
				if(2)
					A.atmosalm=1
				if(3)
					A.radalert=1
				if(4)
					A.party=1
*/

		A.updateicon()
		CHECK_TICK

/datum/universal_state/hell/OverlayAndAmbientSet()
	set waitfor = FALSE
	for(var/turf/T in world)
		if(istype(T, /turf/space))
			T.overlays += image(icon = T.icon, icon_state = "hell01")
		else
			if(!T.holy && prob(1) && T.z != map.zCentcomm)
				new /obj/effect/gateway/active/cult(T)
			T.underlays += "hell01"
		CHECK_TICK

/datum/universal_state/hell/proc/MiscSet()
	for (var/obj/machinery/firealarm/alm in machines)
		if (!(alm.stat & BROKEN))
			alm.ex_act(2)
		CHECK_TICK

/datum/universal_state/hell/proc/APCSet()
	for (var/obj/machinery/power/apc/APC in power_machines)
		var/area/this_area = get_area(APC)
		if (!(APC.stat & BROKEN) && !istype(this_area,/area/turret_protected/ai))
			APC.chargemode = 0
			if(APC.cell)
				APC.cell.charge = 0
			APC.emagged = 1
			APC.queue_icon_update()
		CHECK_TICK

/datum/universal_state/hell/proc/KillMobs()
	for(var/mob/living/simple_animal/M in mob_list)
		if(M && !M.client)
			M.death()
		CHECK_TICK

/datum/universal_state/hell/proc/convert_all_parallax()
	for(var/client/C in clients)
		var/obj/abstract/screen/plane_master/parallax_spacemaster/PS = locate() in C.screen
		if(PS)
			convert_parallax(PS)
		CHECK_TICK

/datum/universal_state/hell/convert_parallax(obj/abstract/screen/plane_master/parallax_spacemaster/PS)
	PS.color = list(
	0,0,0,0,
	0,0,0,0,
	0,0,0,0,
	1,0,0,1)
