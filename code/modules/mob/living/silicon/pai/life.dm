/mob/living/silicon/pai/Life()
	if(timestopped)
		return 0 //under effects of time magick

	if (src.stat == 2)
		return

	handle_regular_status_updates()
	regular_hud_updates()

	if(silence_time)
		if(world.timeofday >= silence_time)
			silence_time = null
			to_chat(src, "<font color=green>Communication circuit reinitialized. Speech and messaging functionality restored.</font>")

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		health = maxHealth - getBruteLoss() - getFireLoss()

/mob/living/silicon/pai/check_dead()
	if(health <= 0 && !isDead()) //die only once
		death()
		return 1
	
/mob/living/silicon/pai/handle_regular_status_updates()
	. = ..()

	if(sleeping)
		Paralyse(3)
		sleeping--

	if(resting)
		Knockdown(5)

	if (stat != DEAD) //Alive.
		if (paralysis || stunned || knockdown) //Stunned etc.
			stat = 1
			if (stunned > 0)
				AdjustStunned(-1)
			if (knockdown > 0)
				AdjustKnockdown(-1)
			if (paralysis > 0)
				AdjustParalysis(-1)
				blinded = 1
			else
				blinded = 0

		else	//Not stunned.
			stat = 0

	else //Dead.
		blinded = 1
		stat = DEAD
		return 1