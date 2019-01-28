/datum/component/ai/revive
	var/time_of_death
	var/times_died
	var/revive_time = 30 SECONDS

/datum/component/ai/revive/RecieveSignal(var/message_type, var/list/args)
	switch(message_type)
		if(COMSIG_DEATH)
			time_of_death = world.time
			times_died++
		if(COMSIG_TICK)
			if(time_of_death && time_of_death+revive_time>=world.time)
				var/mob/living/M = container.holder
				M.adjustBruteLoss(-1*times_died)
				M.adjustToxLoss(-1*times_died)
				M.adjustOxyLoss(-1*times_died)
				M.updatehealth()
				if(M.stat == DEAD && M.health>50)
					M.stat = 0
					M.resurrect()