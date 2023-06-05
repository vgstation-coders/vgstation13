/datum/event/powercreeper

/datum/event/powercreeper/can_start(var/list/active_with_role)
	if(active_with_role["Engineer"] > 1 && active_with_role.len > 6)
		return 15
	return 0

/datum/event/powercreeper/start()
	spawn()
		var/list/turf/simulated/floor/turfs = list() //list of all the empty floor turfs in the hallway areas
		for(var/areapath in subtypesof(/area/engineering))
			var/area/A = locate(areapath)
			for(var/turf/simulated/floor/F in A.contents)
				if(!is_blocked_turf(F))
					turfs += F

		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/simulated/floor/T = pick(turfs)

			new /obj/structure/cable/powercreeper(T)

			message_admins("<span class='notice'>Event: powercreeper spawned at [T.loc] <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a></span>")
			return
		message_admins("<span class='notice'>Event: powercreeper failed to find a viable turf.</span>")
