
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
		//Now ignoring peg limb damage! Metal legs do not hurt!
		var/hurtdamage = (getBruteLoss(TRUE)*100/maxHealth) + (getFireLoss(TRUE)*100/maxHealth) + (damageoverlaytemp * 100 / maxHealth)
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
		filter_update_delay = -1

		var/impaired_vision = get_impaired_vision_range()
		if(impaired_vision > 0)
			enable_nearsightedness(impaired_vision)
		else if (perception_filters.enabled_filters & P_FILTER_IMPAIRED_VISION)
			disable_nearsightedness()

		if(eye_blurry)
			enable_blurriness(eye_blurry)
		else if (perception_filters.enabled_filters & P_FILTER_BLURRY_VISION)
			disable_blurriness()

		if(druggy)
			enable_druggy_overlays()
		else
			disable_druggy_overlays()

		if(has_reagent_in_blood(INCENSE_MOONFLOWERS))
			overlay_fullscreen("high_red", /obj/abstract/screen/fullscreen/high/red)
		else
			clear_fullscreen("high_red")
	else
		if (perception_filters.enabled_filters & P_FILTER_IMPAIRED_VISION)
			disable_nearsightedness()
		if (perception_filters.enabled_filters & P_FILTER_BLURRY_VISION)
			disable_blurriness()

/mob/living/proc/get_impaired_vision_range()
	var/_modifiers	= get_impaired_vision_modifiers()
	var/_total 		= _modifiers[1]
	var/_max_range 	= _modifiers[2]

	if (_total <= 0)
		return 0

	if (client && (client.view > 7))
		//impairement is capped at on players with extended view so that they can't see outside of the overlay
		_max_range -= (client.view - 7) / 10

	_total = clamp(_total, 1, _max_range)

	return _total


/mob/living/proc/get_impaired_vision_modifiers()//used by cyborgs and gondolas
	var/_total = 0

	if (blinded)
		_total = 10
	else
		_total += eye_blind

	return list(_total, 0, 10)

/mob/living/carbon/complex/martian/get_impaired_vision_modifiers()
	var/_total = 0
	var/_max_range = 10

	if (!blinded)
		if(head && istype(head, /obj/item/clothing))
			var/obj/item/clothing/hat = head
			_total += hat.nearsighted_modifier

		_total += eye_blind
	else
		_total = 10

	for(var/obj/item/W in held_items)
		if (istype(W, /obj/item/weapon/cane))
			_max_range = 9.333

	return list(_total, _max_range)

/mob/living/carbon/monkey/get_impaired_vision_modifiers()
	var/_total = 0
	var/_max_range = 10

	if (!blinded)
		if(hat && istype(hat, /obj/item/clothing))
			_total += hat.nearsighted_modifier

		if(glasses && istype(glasses, /obj/item/clothing))
			_total += abs(glasses.nearsighted_modifier)//monkeys cannot be nearsighted currently, so glasses always make them see blurry

		_total += eye_blind
	else
		_total = 10

	for(var/obj/item/W in held_items)
		if (istype(W, /obj/item/weapon/cane))
			_max_range = 9.333

	return list(_total, _max_range)

/mob/living/carbon/human/get_impaired_vision_modifiers()
	var/_total = 0
	var/_max_range = 10

	if (species.has_organ["eyes"])
		//Only species that are supposed to have eyes can be affected by nearsightedness and blindness
		//As well as by the items they're wearing

		var/datum/organ/internal/eyes/eyes = internal_organs_by_name["eyes"]

		if(!blinded)//automatically updated in handle_regular_status_updates. Checks for eyes that haven't been removed, as well as the BLIND disability
			_total += eye_blind//temporary blindness that decreases over time

			_total -= eyes.enhanced_vision//advanced eyes

			if (eyes.is_bruised())
				var/a = eyes.damage - eyes.min_bruised_damage
				var/b = eyes.min_broken_damage - eyes.min_bruised_damage
				//(+0) to (+10) depending on eye damage
				_total += 10 * (a / b)

			if(glasses && istype(glasses, /obj/item/clothing))
				if (!glasses.perfect_sight)//this will do for now to handle glasses that need to fit people regardless of eyesight
					//welding goggles worsen eyesight (+5)
					//prescription glasses enhance it (-3) but only if you are nearsighted (+3), otherwise they make YOU see blurry
					//TODO: have varying degrees of nearsightedness with stronger glasses. This operation already supports it.
					_total += abs(nearsightedness + glasses.nearsighted_modifier)
			else
				_total += nearsightedness


			if(head && istype(head, /obj/item/clothing))
				var/obj/item/clothing/hat = head//typecasting because we can have stuff other than actual hats on our heads
				//unathi helmet and welding helmet worsen eyesight (+5)
				_total += hat.nearsighted_modifier

		else
			//If you don't have eyes even though you're supposed to have eyes, you're just blind mate
			_total = 10

		//Whether you're blind or not however, holding a cane makes it so that you can always see on the tile adjacent to you
		for(var/obj/item/W in held_items)
			if (istype(W, /obj/item/weapon/cane))
				_max_range = 9.333

	return list(_total, _max_range)
