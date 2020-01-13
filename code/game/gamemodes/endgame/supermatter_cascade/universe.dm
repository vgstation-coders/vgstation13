
/datum/universal_state/supermatter_cascade
  name = "Supermatter Cascade"
  desc = "Unknown harmonance affecting universal substructure, converting nearby matter to supermatter."

  decay_rate = 5 // 5% chance of a turf decaying on lighting update (there's no actual tick for turfs). Code that triggers this is lighting_overlays.dm, line #62.

	// RGB, [0,1]
	//var/list/LUMCOUNT_CASCADE=list(0.5,0,0)

/datum/universal_state/supermatter_cascade/OnShuttleCall(var/mob/user)
	if(user)
		if(user.hallucinating())
			var/msg = pick("your mother and father arguing","a smooth jazz tune","somebody speaking [pick("french","siik'tajr","gibberish")]","[pick("somebody","your parents","a gorilla","a man","a woman")] making [pick("chicken","cow","train","duck","cat","dog","strange","funny")] sounds")
			to_chat(user, "<span class='sinister'>All you hear on the frequency is [msg]. There will be no shuttle call today.</span>")
		else
			to_chat(user, "<span class='sinister'>All you hear on the frequency is static and panicked screaming. There will be no shuttle call today.</span>")
	return 0

/datum/universal_state/supermatter_cascade/OnTurfChange(var/turf/T)
	if(T.name == "space")
		T.overlays += image(icon = T.icon, icon_state = "end01")
		T.underlays -= "end01"
	else
		T.overlays -= image(icon = T.icon, icon_state = "end01")

/datum/universal_state/supermatter_cascade/DecayTurf(var/turf/T)
	if(istype(T,/turf/simulated/wall))
		var/turf/simulated/wall/W=T
		W.melt()
		return
	if(istype(T,/turf/simulated/floor))
		var/turf/simulated/floor/F=T
		// Burnt?
		if(!F.burnt)
			F.burn_tile()
		else
			if(!istype(F,/turf/simulated/floor/plating))
				F.break_tile_to_plating()
		return

// Apply changes when entering state
/datum/universal_state/supermatter_cascade/OnEnter()
	set background = 1
	to_chat(world, "<span class='sinister' style='font-size:22pt'>You are blinded by a brilliant flash of energy.</span>")

	world << sound('sound/effects/cascade.ogg')

	for(var/mob/M in player_list)
		if(istype(M, /mob/living))
			var/mob/living/L = M
			L.flash_eyes(visual = 1)

	if(emergency_shuttle.direction==2)
		captain_announce("The emergency shuttle has returned due to bluespace distortion.")

	emergency_shuttle.force_shutdown()

	suspend_alert = 1

	AreaSet()
	MiscSet()
	APCSet()
	OverlayAndAmbientSet()

	// Disable Nar-Sie.
	//ticker.mode.eldergod=0
	// TODO: If Nar-Sie is present, have it say "Well fuck this" and leave, for shits and giggles.

	ticker.StartThematic("endgame")

	//PlayerSet()
	CHECK_TICK
	if(!endgame_exits.len)
		message_admins("<span class='warning'><font size=7>SOMEBODY DIDNT PUT ENDGAME EXITS FOR THIS FUCKING MAP: [map.nameLong]</span></font>")
	else
		new /obj/machinery/singularity/narsie/large/exit(pick(endgame_exits))

	spawn(rand(30,60) SECONDS)
		command_alert(/datum/command_alert/supermatter_cascade)

		for(var/obj/machinery/computer/shuttle_control/C in machines)
			if(istype(C.shuttle,/datum/shuttle/mining) || istype(C.shuttle,/datum/shuttle/research))
				C.req_access = null

		sleep(5 MINUTES)
		ticker.declare_completion()
		ticker.station_explosion_cinematic(0,null) // TODO: Custom cinematic

		to_chat(world, "<B>Resetting in 30 seconds!</B>")

		feedback_set_details("end_error","Universe ended")

		if(blackbox)
			blackbox.save_all_data_to_sql()

		if (watchdog.waiting)
			to_chat(world, "<span class='notice'><B>Server will shut down for an automatic update in a few seconds.</B></span>")
			watchdog.signal_ready()
			return
		sleep(300)
		log_game("Rebooting due to universal collapse")
		CallHook("Reboot",list())
		world.Reboot()
		return

/datum/universal_state/supermatter_cascade/proc/AreaSet()
	for(var/area/ca in areas)
		var/area/A=get_area(ca)
		if(!istype(A,/area) || isspace(A) || istype(A,/area/beach))
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

		A.updateicon()
		CHECK_TICK

/datum/universal_state/supermatter_cascade/OverlayAndAmbientSet()
	set waitfor = FALSE
	convert_all_parallax()
	for(var/turf/T in world)
		if(istype(T, /turf/space))
			T.overlays += image(icon = T.icon, icon_state = "end01")
		else
			if(T.z != map.zCentcomm)
				T.underlays += "end01"
		CHECK_TICK

	// This ends up looking like shit.  - N3X
	/*
	for(var/datum/lighting_corner/C in global.all_lighting_corners)
		if (!C.active)
			continue

		if(C.z != map.zCentcomm)
			C.update_lumcount(LUMCOUNT_CASCADE[1], LUMCOUNT_CASCADE[2], LUMCOUNT_CASCADE[3])
		CHECK_TICK
	*/

/datum/universal_state/supermatter_cascade/proc/convert_all_parallax()
	for(var/client/C in clients)
		var/obj/abstract/screen/plane_master/parallax_spacemaster/PS = locate() in C.screen
		if(PS)
			convert_parallax(PS)
		CHECK_TICK

/datum/universal_state/supermatter_cascade/convert_parallax(obj/abstract/screen/plane_master/parallax_spacemaster/PS)
	PS.color = list(
	0,0,0,0,
	0,0,0,0,
	0,0,0,0,
	0,0.4,1,1) // Looks like RGBA? Currently #0066FF

/datum/universal_state/supermatter_cascade/proc/MiscSet()
	for (var/obj/machinery/firealarm/alm in machines)
		if (!(alm.stat & BROKEN))
			alm.ex_act(2)
		CHECK_TICK

/datum/universal_state/supermatter_cascade/proc/APCSet()
	for (var/obj/machinery/power/apc/APC in power_machines)
		if (!(APC.stat & BROKEN) && !APC.is_critical)
			APC.chargemode = 0
			if(APC.cell)
				APC.cell.charge = 0
			APC.emagged = 1
			APC.queue_icon_update()
		CHECK_TICK
