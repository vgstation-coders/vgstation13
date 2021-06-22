
/mob/living/proc/standard_damage_overlay_updates()
	if(!client)
		return 0

	var/health_percent = health * 100 / maxHealth

	if(stat == UNCONSCIOUS && health_percent <= config.health_threshold_crit)
		var/severity = 0
		switch(health_percent)
			if(-20 to -10)
				severity = 1
			if(-30 to -20)
				severity = 2
			if(-40 to -30)
				severity = 3
			if(-50 to -40)
				severity = 4
			if(-60 to -50)
				severity = 5
			if(-70 to -60)
				severity = 6
			if(-80 to -70)
				severity = 7
			if(-90 to -80)
				severity = 8
			if(-95 to -90)
				severity = 9
			if(-INFINITY to -95)
				severity = 10
		overlay_fullscreen("crit", /obj/abstract/screen/fullscreen/crit, severity)
	else
		clear_fullscreen("crit")
		var/oxyloss_percent =  oxyloss * 100 / maxHealth
		if (istype(src,/mob/living/simple_animal) || istype(src,/mob/living/carbon/slime))
			oxyloss_percent = (100 - health_percent)/2
		if(oxyloss_percent)
			if(pain_numb)
				oxyloss_percent = max((oxyloss_percent - 20) / 2, 0) //Make the damage appear smaller than it really is
			var/severity = 0
			switch(oxyloss_percent)
				if(10 to 20)
					severity = 1
				if(20 to 25)
					severity = 2
				if(25 to 30)
					severity = 3
				if(30 to 35)
					severity = 4
				if(35 to 40)
					severity = 5
				if(40 to 45)
					severity = 6
				if(45 to INFINITY)
					severity = 7
			overlay_fullscreen("oxy", /obj/abstract/screen/fullscreen/oxy, severity)
		else
			clear_fullscreen("oxy")
		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = (getBruteLoss()*100/maxHealth) + (getFireLoss()*100/maxHealth) + (damageoverlaytemp * 100 / maxHealth)
		if (istype(src,/mob/living/simple_animal) || istype(src,/mob/living/carbon/slime))
			hurtdamage = (100 - health_percent) + (damageoverlaytemp * 100 / maxHealth)
		damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
		if(hurtdamage)
			if(pain_numb)
				hurtdamage = max((hurtdamage - 20) / 2, 0) //Make the damage appear smaller than it really is
			var/severity = 0
			switch(hurtdamage)
				if(5 to 15)
					severity = 1
				if(15 to 30)
					severity = 2
				if(30 to 45)
					severity = 3
				if(45 to 70)
					severity = 4
				if(70 to 85)
					severity = 5
				if(85 to INFINITY)
					severity = 6
			overlay_fullscreen("brute", /obj/abstract/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")
			//damageoverlay.overlays += I
		if(pain_numb)
			overlay_fullscreen("numb", /obj/abstract/screen/fullscreen/numb)
		else
			clear_fullscreen("numb")

	if(stat != DEAD)
		if(disabilities & NEARSIGHTED)	//This looks meh but saves a lot of memory by not requiring to add var/prescription
			if (ishuman(src))
				var/mob/living/carbon/human/H = src
				if(H.glasses)	//To every /obj/item
					var/obj/item/clothing/glasses/G = H.glasses
					if(!G.prescription)
						overlay_fullscreen("nearsighted", /obj/abstract/screen/fullscreen/impaired, 1)
					else
						clear_fullscreen("nearsighted")
			else
				overlay_fullscreen("nearsighted", /obj/abstract/screen/fullscreen/impaired, 1)
		else
			clear_fullscreen("nearsighted")
		if(eye_blind || blinded)
			overlay_fullscreen("blind", /obj/abstract/screen/fullscreen/blind)
		else
			clear_fullscreen("blind")
		if(eye_blurry)
			overlay_fullscreen("blurry", /obj/abstract/screen/fullscreen/blurry)
		else
			clear_fullscreen("blurry")
		if(druggy)
			overlay_fullscreen("high", /obj/abstract/screen/fullscreen/high)
		else
			clear_fullscreen("high")
		if(has_reagent_in_blood(INCENSE_MOONFLOWERS))
			overlay_fullscreen("high_red", /obj/abstract/screen/fullscreen/high/red)
		else
			clear_fullscreen("high_red")
