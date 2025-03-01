/datum/event/hog
	oneShot = TRUE

/datum/event/hog/can_start(var/list/active_with_role)
	if((active_with_role["Assistant"] > 4) || (active_with_role["Chef"] > 0))
		return 20
	return 0

/datum/event/hog/start()
	var/list/turf/simulated/floor/turfs = get_open_maintenance_turfs(5)
	if(turfs.len < 2) //Pick a turf to spawn at if we can
		message_admins("Aborted hog event. Couldn't find maintenance spaces.")
		return
	command_alert(/datum/command_alert/hog)
	var/mob/living/simple_animal/rampagingspacehog/ourhog = new(pick_n_take(turfs))
	message_admins("<span class='notice'>Event: hog spawned in at [ourhog.loc] <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[ourhog.x];Y=[ourhog.y];Z=[ourhog.z]'>(JMP)</a></span>")
	ourhog.homes += turfs //add the rest in too


