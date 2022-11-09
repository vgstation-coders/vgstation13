/datum/event/wallrot
	var/severity = 1

/datum/event/wallrot/can_start()
	return 30

/datum/event/wallrot/setup()
	announceWhen = rand(0, 300)
	endWhen = announceWhen + 1
	severity = rand(5, 10)

/datum/event/wallrot/announce()
	command_alert(/datum/command_alert/wall_fungi)

/datum/event/wallrot/can_start()
	for(var/area/A in the_station_areas)
		for(var/turf/T in A.get_area_turfs())
			if(istype(T,/turf/simulated/wall))
				return 1
	return 0

/datum/event/wallrot/start()
	spawn()
		for(var/i in 1 to severity)
			var/tries = 0
			while((!our_area || !(locate(/turf/simulated/wall) in our_area.get_area_turfs())) && tries < 100)
				var/area/our_area = pick(the_station_areas)
				tries++
			var/turf/center = null
			tries = 0
			while(!istype(center,/turf/simulated/wall) && tries < 100)
				center = pick(our_area.get_area_turfs())
				tries++

			if(center)
				// Make sure at least one piece of wall rots!
				center:rot()

				// Have a chance to rot lots of other walls.
				var/rotcount = 0
				for(var/turf/simulated/wall/W in range(5, center))
					if(prob(50))
						W:rot()
						rotcount++

					// Only rot up to severity walls
					if(rotcount >= severity)
						break
