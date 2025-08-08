/datum/event/rogue_drone
	startWhen = 5
	endWhen = 450
	var/list/drones_list = list()

/datum/event/rogue_drone/can_start()
	return 25

/datum/event/rogue_drone/start()
	if(zlevel == map.zMainStation)
		//spawn them at the same place as carp
		var/list/possible_spawns = list()
		for(var/obj/effect/landmark/C in landmarks_list)
			if(C.name == "carpspawn")
				possible_spawns.Add(C)

		//25% chance for this to be a false alarm
		var/num
		if(prob(25))
			num = 0
		else
			num = rand(2,6)
		for(var/i in 1 to num)
			var/mob/living/simple_animal/hostile/retaliate/malf_drone/rogue/D = new(get_turf(pick(possible_spawns)))
			D.from_event = src
			drones_list.Add(D)
	else
		var/area/A
		for(var/area/A2 in areas)
			if(isspace(A2))
				A = A2
				break
		var/list/area_turfs_copy = A.area_turfs.Copy()
		for(var/i in 1 to rand(2,6))
			var/turf/spaceturf
			do
				spaceturf = pick_n_take(area_turfs_copy)
			while(spaceturf.z != zlevel || spaceturf.type != /turf/space)
			var/mob/living/simple_animal/hostile/retaliate/malf_drone/rogue/D = new(spaceturf)
			D.from_event = src
			drones_list.Add(D)
	var/drone_logs = "Spawned drones from rogue event: "
	for(var/mob/living/simple_animal/hostile/retaliate/malf_drone/rogue/D in drones_list)
		drone_logs += "[formatJumpTo(D)], "
	log_debug(drone_logs)


/datum/event/rogue_drone/announce()
	if(..())
		command_alert(/datum/command_alert/rogue_drone)

/datum/event/rogue_drone/tick()
	return

/datum/event/rogue_drone/end()
	var/num_recovered = 0
	for(var/mob/living/simple_animal/hostile/retaliate/malf_drone/rogue/D in drones_list)
		spark(D, 3, FALSE)
		D.z = map.zCentcomm
		D.has_loot = 0

		qdel(D) // Drone deletion handles removal from drones list
		num_recovered++

	if(zlevel == map.zMainStation)
		if(num_recovered > drones_list.len * 0.75)
			command_alert(/datum/command_alert/drones_recovered)
		else
			command_alert(/datum/command_alert/drones_recovered/failure)
