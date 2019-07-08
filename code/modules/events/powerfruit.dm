/datum/event/powerfruit

/datum/event/powerfruit/start()
	spawn()
		var/list/turf/simulated/floor/turfs = list() //list of all the empty floor turfs in the hallway areas
		for(var/areapath in typesof(/area/hallway))
			var/area/A = locate(areapath)
			for(var/turf/simulated/floor/F in A.contents)
				if(!is_blocked_turf(F))
					turfs += F

		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/simulated/floor/T = pick(turfs)

			var/obj/structure/cable/powerfruit/PF = new(T)
			PF.process()

			message_admins("<span class='notice'>Event: Powerfruit spawned at [T.loc] <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a></span>")
			return
		message_admins("<span class='notice'>Event: Powerfruit failed to find a viable turf.</span>")
