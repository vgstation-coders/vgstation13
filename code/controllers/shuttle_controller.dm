// Controls the emergency shuttle


// these define the time taken for the shuttle to get to the station
// and the time before it leaves again
#define SHUTTLEARRIVETIME  600		// 10 minutes = 600 seconds
#define SHUTTLELEAVETIME   180		// 3 minutes = 180 seconds
#define SHUTTLETRANSITTIME 120		// 2 minutes = 120 seconds

var/global/datum/emergency_shuttle/emergency_shuttle

datum/emergency_shuttle
	var/alert = 0 //0 = emergency, 1 = crew cycle

	var/location = 0 //0 = in transit (or on standby), 1 = at the station, 2 = at centcom
	var/online = 0
	var/direction = 0 //-1 = going back to centcom (recalled), 0 = on standby, 1 = going to the station, 2 = in transit to centcom (not recalled)

	var/endtime			// timeofday that shuttle arrives
	var/timelimit //important when the shuttle gets called for more than shuttlearrivetime
		//timeleft = 360 //600
	var/fake_recall = 0 //Used in rounds to prevent "ON NOES, IT MUST [INSERT ROUND] BECAUSE SHUTTLE CAN'T BE CALLED"

	var/always_fake_recall = 0
	var/deny_shuttle = 0 //for admins not allowing it to be called.
	var/departed = 0

	var/shutdown = 0 // Completely shut down.

	var/can_recall = 1

	var/datum/shuttle/escape/shuttle

	var/list/escape_pods = list()

	var/voting_cache = 0

	var/warmup_sound = 0

	// call the shuttle
	// if not called before, set the endtime to T+600 seconds
	// otherwise if outgoing, switch to incoming

datum/emergency_shuttle/proc/incall(coeff = 1)
	if(shutdown)
		return
	if((!universe.OnShuttleCall(null) || deny_shuttle) && alert == 1) //crew transfer shuttle does not gets recalled by gamemode
		return
	if(endtime)
		setdirection(1)
	else
		settimeleft(SHUTTLEARRIVETIME*coeff)
		online = 1
		setdirection(1)
		if(always_fake_recall)
			fake_recall = rand(300,500)
	//turning on the red lights in hallways
	if(alert == 0)
		for(var/area/A in areas)
			if(istype(A, /area/hallway))
				A.readyalert()

datum/emergency_shuttle/proc/shuttlealert(var/X)
	if(shutdown)
		return
	alert = X


datum/emergency_shuttle/proc/recall()
	if(shutdown)
		return
	if(!can_recall)
		return
	if(direction == 1)
		var/timeleft = timeleft()
		if(alert == 0)
			if(timeleft >= 600)
				return
			captain_announce("The emergency shuttle has been recalled.")
			world << sound('sound/AI/shuttlerecalled.ogg')
			setdirection(-1)
			online = 1
			for(var/area/A in areas)
				if(istype(A, /area/hallway))
					A.readyreset()
			return
		else //makes it possible to send shuttle back.
			captain_announce("The shuttle has been recalled.")
			setdirection(-1)
			online = 1
			return

// returns the time (in seconds) before shuttle arrival
// note if direction = -1, gives a count-up to SHUTTLEARRIVETIME
datum/emergency_shuttle/proc/timeleft()
	if(online)
		var/timeleft = round((endtime - world.timeofday)/10 ,1)
		if(direction >= 0)
			return timeleft
		else
			return SHUTTLEARRIVETIME-timeleft
	else
		return SHUTTLEARRIVETIME

// sets the time left to a given delay (in seconds)
datum/emergency_shuttle/proc/settimeleft(var/delay)
	endtime = world.timeofday + delay * 10
	timelimit = delay

// sets the shuttle direction
// 1 = towards SS13, -1 = back to centcom
datum/emergency_shuttle/proc/setdirection(var/dirn)
	if(direction == dirn || !direction || !dirn)
		direction = dirn
		return
	direction = dirn
	// if changing direction, flip the timeleft by SHUTTLEARRIVETIME, unless changing from/to 0
	var/ticksleft = endtime - world.timeofday
	endtime = world.timeofday + (SHUTTLEARRIVETIME*10 - ticksleft)
	return

datum/emergency_shuttle/proc/move_pod(var/pod,var/destination)
	if (!pod || !destination || !(istype(pod, /datum/shuttle/escape)) || !escape_pods.Find(pod))
		return

	var/datum/shuttle/escape/S = pod
	switch(destination)
		if("station")
			if(!S.move_to_dock(S.dock_station, 0))
				message_admins("Warning: [S] failed to move to station.")
		if("centcom")
			if(!S.move_to_dock(S.dock_centcom, 0))
				message_admins("Warning: [S] failed to move to centcom.")
		if("transit")
			if(!S.move_to_dock(S.transit_port, 0))
				message_admins("Warning: [S] failed to move to transit.")
	spawn()
		for(var/obj/machinery/door/D in S.linked_area)
			if(destination == "transit")
				D.close()
			else
				D.open()

datum/emergency_shuttle/proc/force_shutdown()
	online=0
	shutdown=1

	if(direction == 2)
		location = 1

		//main shuttle
		if(shuttle && istype(shuttle,/datum/shuttle/escape))
			var/datum/shuttle/escape/E = shuttle
			E.open_all_doors()
			if(!E.move_to_dock(E.dock_station, 0, E.dir)) //Throw everything forward
				message_admins("WARNING: THE EMERGENCY SHUTTLE FAILED TO FIND THE STATION! PANIC PANIC PANIC")
		else
			message_admins("WARNING: THERE IS NO EMERGENCY SHUTTLE! PANIC")
			//move_pod(/area/shuttle/escape/transit,/area/shuttle/escape/station,NORTH,1)

		//pods
		for (var/pod in escape_pods)
			move_pod(pod, "station")

		online = 0


// "preload" the assets for when they're needed for the map vote.
datum/emergency_shuttle/proc/vote_preload()
	if (voting_cache)
		return
	voting_cache = 1
	if(config.map_voting && vote)
		for(var/client/C in clients)
			spawn
				vote.interface.sendAssets(C)

datum/emergency_shuttle/proc/hyperspace_sounds(var/phase)
	var/frequency = get_rand_frequency()

	switch (phase)
		if ("dock")
			for (var/mob/M in player_list)
				if(M && M.client)
					var/turf/M_turf = get_turf(M)
					if (M_turf.z == shuttle.dock_station.z)
						M.playsound_local(shuttle.dock_station, 'sound/machines/hyperspace_end.ogg', 75 - (get_dist(shuttle.dock_station,M_turf)*2), 1, frequency, falloff = 5)
		if ("begin")
			for (var/mob/M in player_list)
				if(M && M.client)
					var/turf/M_turf = get_turf(M)
					if (M_turf.z == shuttle.dock_station.z)
						M.playsound_local(shuttle.dock_station, 'sound/machines/hyperspace_begin.ogg', 75 - (get_dist(shuttle.dock_station,M_turf)*2), 1, frequency, falloff = 5)
		if ("progression")
			for (var/mob/M in player_list)
				if(M && M.client)
					var/turf/M_turf = get_turf(M)
					if (M_turf.z == shuttle.linked_port.z)
						M.playsound_local(shuttle.linked_port, 'sound/machines/hyperspace_progress.ogg', 75 - (get_dist(shuttle.linked_port,M_turf)*2), 1, frequency, falloff = 5)
		if ("end")
			for (var/mob/M in player_list)
				if(M && M.client)
					var/turf/M_turf = get_turf(M)
					if (M_turf.z == shuttle.linked_port.z)
						M.playsound_local(shuttle.linked_port, 'sound/machines/hyperspace_end.ogg', 75 - (get_dist(shuttle.linked_port,M_turf)*2), 1, frequency, falloff = 5)
					if (M_turf.z == shuttle.dock_centcom.z)
						M.playsound_local(shuttle.dock_centcom, 'sound/machines/hyperspace_end.ogg', 75 - (get_dist(shuttle.dock_centcom,M_turf)*2), 1, frequency, falloff = 5)

datum/emergency_shuttle/proc/shuttle_phase(var/phase, var/casual = 1)
	switch (phase)
		if ("station")
			location = 1

			if(shuttle && istype(shuttle,/datum/shuttle/escape))
				var/datum/shuttle/escape/E = shuttle
				E.open_all_doors()
				if(!E.move_to_dock(E.dock_station, 0, E.dir)) //Throw everything forward, on chance that there's anybody in the shuttle
					message_admins("WARNING: THE EMERGENCY SHUTTLE COULDN'T MOVE TO THE STATION! PANIC PANIC PANIC")
			else
				message_admins("WARNING: THERE IS NO EMERGENCY SHUTTLE! PANIC")

			if (!casual)
				settimeleft(SHUTTLELEAVETIME)
				send2mainirc("The Emergency Shuttle has docked with the station.")
				send2maindiscord("The **Emergency Shuttle** has docked with the station.")
				captain_announce("The Emergency Shuttle has docked with the station. You have [round(timeleft()/60,1)] minutes to board the Emergency Shuttle.")
				world << sound('sound/AI/shuttledock.ogg')
				/*
				if(universe.name == "Hell Rising")
					to_chat(world, "___________________________________________________________________")
					to_chat(world, "<span class='sinister' style='font-size:3'> A vile force of darkness is making its way toward the escape shuttle.</span>")
				*/
		if ("transit")
			location = 0 // in deep space

			for(var/obj/machinery/door/unpowered/shuttle/D in shuttle.linked_area)
				spawn(0)
					D.close()
					D.locked = 1

			if (casual)
				direction = 1
			else
				departed = 1 // It's going!
				direction = 2 // heading to centcom
				settimeleft(SHUTTLETRANSITTIME)

				// Shuttle Radio
				CallHook("EmergencyShuttleDeparture", list())

				captain_announce("The Emergency Shuttle has left the station. Estimate [round(timeleft()/60,1)] minutes until the shuttle docks at Central Command.")
				vote_preload()

			if(shuttle && istype(shuttle,/datum/shuttle/escape))
				var/datum/shuttle/escape/E = shuttle
				E.close_all_doors()

				for(var/obj/structure/shuttle/engine/propulsion/P in E.linked_area)
					spawn()
						P.shoot_exhaust(backward = 3)

				if(!E.move_to_dock(E.transit_port, 0, turn(E.dir,180))) //Throw everything backwards
					message_admins("WARNING: THE EMERGENCY SHUTTLE COULDN'T MOVE TO TRANSIT! PANIC PANIC PANIC")
			else
				message_admins("WARNING: THERE IS NO EMERGENCY SHUTTLE! PANIC")
			hyperspace_sounds("progression")


		if ("centcom")
			if (casual)
				location = 0
				direction = 0
			else
				vote_preload()
				location = 2

			if(shuttle && istype(shuttle,/datum/shuttle/escape))
				var/datum/shuttle/escape/E = shuttle
				E.open_all_doors()
				if(!E.move_to_dock(E.dock_centcom, 0, E.dir)) //Throw everything forward
					message_admins("WARNING: THE EMERGENCY SHUTTLE COULDN'T MOVE TO CENTCOMM! PANIC PANIC PANIC")
			else
				message_admins("WARNING: THERE IS NO EMERGENCY SHUTTLE! PANIC")

			online = 0

datum/emergency_shuttle/proc/process()
	if(!online || shutdown)
		return

	var/timeleft = timeleft()
	if(timeleft > 1e5)		// midnight rollover protection
		timeleft = 0
	if(timeleft < 0)		// Sanity
		timeleft = 0

	if(timeleft > 6)
		warmup_sound = 0

	switch(location)
		if(0)

			/* --- Shuttle is in transit toward centcom --- */
			if(direction == 2)
				for(var/obj/structure/shuttle/engine/propulsion/P in shuttle.linked_area)
					spawn()
						P.shoot_exhaust(backward = 3)
				if(timeleft>0)
					return 0

				/* --- Shuttle has arrived at centcom --- */
				else



					//main shuttle
					shuttle_phase("centcom",0)

					//pods
					for (var/pod in escape_pods)
						move_pod(pod, "centcom")

					hyperspace_sounds("end")
					return 1

			/* --- Shuttle has docked centcom after being recalled --- */
			if(timeleft>timelimit)
				online = 0
				direction = 0
				endtime = null

				return 0

			else if((fake_recall != 0) && (timeleft <= fake_recall))
				recall()
				fake_recall = 0
				return 0

			/* --- Shuttle has docked with the station - begin countdown to transit --- */
			else if(timeleft <= 0)
				hyperspace_sounds("dock")
				shuttle_phase("station",0)
				return 1

		if(1)
			if(timeleft <= 6 && !warmup_sound)
				warmup_sound = 1
				hyperspace_sounds("begin")
			// Just before it leaves, close the damn doors!
			if(timeleft == 2 || timeleft == 1)
				for(var/obj/machinery/door/unpowered/shuttle/D in shuttle.linked_area)
					spawn(0)
						D.close()
						D.locked = 1
				for(var/obj/structure/shuttle/engine/propulsion/P in shuttle.linked_area)
					spawn()
						P.shoot_exhaust(backward = 3)

			if(timeleft>0)
				return 0

			/* --- Shuttle leaves the station, enters transit --- */
			else

				//main shuttle
				shuttle_phase ("transit",0)

				hyperspace_sounds("transit")

				//pods
				for (var/pod in escape_pods)
					move_pod(pod, "transit")


				return 1

		else
			return 1

/proc/shuttle_autocall()
	if (emergency_shuttle.departed)
		return

	if (emergency_shuttle.location == SHUTTLE_ON_STATION)
		return

	emergency_shuttle.incall(2)
	log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
	message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.", 1)
	captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
	world << sound('sound/AI/shuttlecalled.ogg')
