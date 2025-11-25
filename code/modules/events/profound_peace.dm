var/list/forms_of_nirvana = list("buddha","chill")
/datum/event/profound_peace
	announceWhen = 1
	startWhen = 1
	endWhen	= 120 //4 minutes
	var/list/participants = list()
	var/mode

/datum/event/profound_peace/can_start(var/list/active_with_role)
	return 20 * forms_of_nirvana.len

/datum/event/profound_peace/announce()
	command_alert(/datum/command_alert/nirvana)

/datum/event/profound_peace/setup()
	mode = pick_n_take(forms_of_nirvana)
	if(!mode)
		kill()
		qdel(src)
	for(var/mob/living/carbon/human/H in player_list)
		if(H.z != map.zMainStation)
			continue
		participants += H

/datum/event/profound_peace/start()
	for(var/mob/living/L in participants)
		L << 'sound/effects/gong-one.ogg'
		switch(mode)
			if("buddha")
				L.status_flags |= BUDDHAMODE
			if("chill")
				L.status_flags |= PACIFIED

/datum/event/profound_peace/end()
	for(var/mob/living/L in participants)
		L << 'sound/effects/gong-two.ogg'
		switch(mode)
			if("buddha")
				L.status_flags &= ~BUDDHAMODE
			if("chill")
				L.status_flags &= ~PACIFIED
