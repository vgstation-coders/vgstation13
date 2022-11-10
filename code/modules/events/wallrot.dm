/datum/event/wallrot
	var/severity = 1

/datum/event/wallrot/setup()
	announceWhen = rand(0, 300)
	endWhen = announceWhen + 1
	severity = rand(5, 10)

/datum/event/wallrot/announce()
	command_alert(/datum/command_alert/wall_fungi)

/datum/event/wallrot/can_start()
	for(var/area/A in the_station_areas)
		if(locate(/turf/simulated/wall) in A)
			return 30
	return 0

/datum/event/wallrot/start()
	spawn()
		var/list/area/used_areas = list()
		var/list/turf/used_turfs = list()
		for(var/i in 1 to round(severity/2))
			var/tries = 0
			var/area/our_area = null
			while((!our_area || !(locate(/turf/simulated/wall) in get_area_turfs(our_area)) ||\
					(our_area in used_areas)) && tries < 100)
				our_area = pick(the_station_areas)
				tries++
			used_areas.Add(our_area)
			var/list/turf/simulated_area_turfs = list()
			for(var/turf/T in get_area_turfs(our_area))
				if(istype(T,/turf/simulated/wall))
					simulated_area_turfs.Add(T)
			if(simulated_area_turfs.len)
				var/turf/center = pick(simulated_area_turfs)
				if(center)
					// Make sure at least one piece of wall rots!
					if(!(center in used_turfs))
						center:rot()
						used_turfs.Add(center)

					// Have a chance to rot lots of other walls.
					var/rotcount = 0
					for(var/turf/simulated/wall/W in range(5, center))
						if(prob(50) && !(W in used_turfs))
							W:rot()
							used_turfs.Add(W)
							rotcount++

						// Only rot up to severity walls
						if(rotcount >= severity)
							break

					log_admin("A wall rot infestation has begun at [center] ([center.x],[center.y],[center.z]) affecting [rotcount] turfs.")
					message_admins("A wall rot infestation has begun at [formatJumpTo(center)] affecting [rotcount] turfs.")
