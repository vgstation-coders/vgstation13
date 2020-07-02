/datum/event/rogue_drone
	startWhen = 5
	endWhen = 450
	var/list/drones_list = list()

/datum/event/rogue_drone/can_start()
	return 25

/datum/event/rogue_drone/start()
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
	for(var/i=0, i<num, i++)
		var/mob/living/simple_animal/hostile/retaliate/malf_drone/D = new(get_turf(pick(possible_spawns)))
		D.from_event = src
		drones_list.Add(D)
		if(prob(25))
			D.disabled = rand(15, 60)

/datum/event/rogue_drone/announce()
	command_alert(/datum/command_alert/rogue_drone)

/datum/event/rogue_drone/tick()
	return

/datum/event/rogue_drone/end()
	var/num_recovered = 0
	for(var/mob/living/simple_animal/hostile/retaliate/malf_drone/D in drones_list)
		spark(D, 3, FALSE)
		D.z = map.zCentcomm
		D.has_loot = 0

		qdel(D) // Drone deletion handles removal from drones list
		num_recovered++

	if(num_recovered > drones_list.len * 0.75)
		command_alert(/datum/command_alert/drones_recovered)
	else
		command_alert(/datum/command_alert/drones_recovered/failure)
