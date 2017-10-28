/*	Halloween Rising
*		Kill the lights, kill the power, ruin the APCs
*		Shuttle is called for 10 minutes
*		Sprinkle the station with monsters of halloween variety (Vampires, mummies, zombies, etc.)
*		Have some area-specific monsters, such as the Poutine Titan for the kitchen
*/

/datum/universal_state/halloween
	name = "All Hallows Eve"
	desc = "Double, double toil and Trouble. Fire burn and Cauldron bubble."

	decay_rate = 0

/datum/universal_state/halloween/OnShuttleCall(var/mob/user)
	return 1

/datum/universal_state/halloween/DecayTurf(var/turf/T)
	if(!T.holy)
		T.cultify()
		for(var/obj/machinery/light/L in T.contents)
			L.broken()

/datum/universal_state/halloween/OnTurfChange(var/turf/T)
	if(T.name == "space")
		T.overlays += image(icon = T.icon, icon_state = "hell01")
		T.underlays -= "hell01"
	else
		T.overlays -= image(icon = T.icon, icon_state = "hell01")

/datum/universal_state/halloween/OnEnter()
	set background = 1
	/*
	if(emergency_shuttle.direction==2)
		captain_announce("The emergency shuttle has returned due to bluespace distortion.")

	emergency_shuttle.force_shutdown()
	*/

	escape_list = get_area_turfs(locate(/area/hallway/secondary/exit))
	CHECK_TICK
	suspend_alert = 1

	convert_all_parallax()
	//separated into separate procs for profiling
	AreaSet()
	MiscSet()
	APCSet()
	OverlayAndAmbientSet()

	ticker.StartThematic("endgame")


/datum/universal_state/halloween/proc/AreaSet()
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
		A.updateicon()
		CHECK_TICK


/datum/universal_state/halloween/OverlayAndAmbientSet()
	set waitfor = FALSE
	for(var/turf/T in world)
		if(istype(T, /turf/space))
			T.overlays += image(icon = T.icon, icon_state = "hell01")
		else
			if(!T.holy && prob(5) && T.z == STATION_Z && istype(T, /turf/simulated/floor))
				new /obj/effect/gravestone/halloween(T)
			T.underlays += "hell01"
		CHECK_TICK

	for(var/datum/lighting_corner/C in global.all_lighting_corners)
		if (!C.active)
			continue

		C.update_lumcount(0.5, 0, 0)
		CHECK_TICK

/datum/universal_state/halloween/proc/MiscSet()
	for (var/obj/machinery/firealarm/alm in machines)
		if (!(alm.stat & BROKEN))
			alm.ex_act(2)
		CHECK_TICK

/datum/universal_state/halloween/proc/APCSet()
	for (var/obj/machinery/power/apc/APC in power_machines)
		if (!(APC.stat & BROKEN) && !istype(APC.areaMaster,/area/turret_protected/ai))
			APC.chargemode = 0
			if(APC.cell)
				APC.cell.charge = 0
			APC.emagged = 1
			APC.queue_icon_update()
		CHECK_TICK

/datum/universal_state/halloween/proc/convert_all_parallax()
	for(var/client/C in clients)
		var/obj/abstract/screen/plane_master/parallax_spacemaster/PS = locate() in C.screen
		if(PS)
			convert_parallax(PS)
		CHECK_TICK

/datum/universal_state/halloween/convert_parallax(obj/abstract/screen/plane_master/parallax_spacemaster/PS)
	PS.color = list(
	0,0,0,0,
	0,0,0,0,
	0,0,0,0,
	1,0,0,1)
