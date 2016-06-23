/mob/living/silicon/decoy/Life()
	if(timestopped) return 0 //under effects of time magick

	if (stat == 2)
		return
	else
		if (health <= config.health_threshold_dead && stat != 2)
			death()
			return


/mob/living/silicon/decoy/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
