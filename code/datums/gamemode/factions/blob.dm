//________________________________________________

/datum/faction/blob_conglomerate
	name = BLOBCONGLOMERATE
	ID = BLOBCONGLOMERATE
	logo_state = "blob-logo"
	roletype = /datum/role/blob_overmind
	initroletype = /datum/role/blob_overmind

/datum/faction/blob_conglomerate/check_win()
    // 1. - Did they take over the station ?

    // 2. - Are they dead ?
    for (var/datum/role/R in members)
        var/mob/M = R?.antag?.current
        if (istype(M) && !M.isDead())
            return FALSE

/datum/faction/blob_conglomerate/OnPostSetup()
    sleep(rand(600,1200))
    stage(0)

	sleep(rand(2000,2400))
	stage(1)

/datum/faction/blob_conglomerate/proc/stage(var/stage)
	switch(stage)
		if (0)
			biohazard_alert()
			return

		if (1)
			command_alert(/datum/command_alert/biohazard_station_lockdown)
			for(var/mob/M in player_list)
				var/T = M.loc
				if((istype(T, /turf/space)) || ((istype(T, /turf)) && (M.z!=1)))
					pre_escapees += M
			if(!mixed)
				send_intercept(1)
			outbreak = 1
			research_shuttle.lockdown = "Under directive 7-10, [station_name()] is quarantined until further notice." //LOCKDOWN THESE SHUTTLES
			mining_shuttle.lockdown = "Under directive 7-10, [station_name()] is quarantined until further notice."

		if (2)
			command_alert(/datum/command_alert/biohazard_station_nuke)
			for(var/mob/camera/blob/B in player_list)
				to_chat(B, "<span class='blob'>The beings intend to eliminate you with a final suicidal attack, you must stop them quickly or consume the station before this occurs!</span>")
			if(!mixed)
				send_intercept(2)