/mob/living/silicon/pai/Life()
	if(timestopped)
		return 0 //under effects of time magick

	if (src.stat == 2)
		return

	handle_regular_status_updates()
	regular_hud_updates()
	if(src.secHUD)
		process_sec_hud(src)
	if(src.medHUD)
		process_med_hud(src)
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

/mob/living/silicon/pai/proc/handle_regular_status_updates()

	updatehealth()

	if(sleeping)
		Paralyse(3)
		sleeping--

	if(resting)
		Knockdown(5)

	if(health <= 0 && stat != 2) //die only once
		death()

	if (stat != 2) //Alive.
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
		stat = 2

	if (stuttering)
		stuttering--

	if (eye_blind)
		eye_blind--
		blinded = 1

	if (ear_deaf > 0)
		ear_deaf--
	if (say_mute > 0)
		say_mute--
	if (ear_damage < 25)
		ear_damage -= 0.05
		ear_damage = max(ear_damage, 0)

	if (sdisabilities & BLIND)
		blinded = 1
	if (sdisabilities & DEAF)
		ear_deaf = 1

	if (eye_blurry > 0)
		eye_blurry--
		eye_blurry = max(0, eye_blurry)

	if (druggy > 0)
		druggy--
		druggy = max(0, druggy)

	return 1
