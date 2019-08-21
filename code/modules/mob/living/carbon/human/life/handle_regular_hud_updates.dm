//Refer to life.dm for caller

/mob/living/carbon/human/handle_regular_hud_updates()
	if(!client)
		return 0

	change_sight(removing = BLIND)

	regular_hud_updates()

	update_action_buttons_icon()

	if(stat == UNCONSCIOUS && health <= config.health_threshold_crit)
		var/severity = 0
		switch(health)
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
		if(oxyloss)
			if(pain_numb)
				oxyloss = max((oxyloss - 20) / 2, 0) //Make the damage appear smaller than it really is
			var/severity = 0
			switch(oxyloss)
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
		var/hurtdamage = src.getBruteLoss() + src.getFireLoss() + damageoverlaytemp
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
	if(stat == DEAD)
		change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		if(!druggy)
			see_invisible = SEE_INVISIBLE_LEVEL_TWO
		if(healths)
			healths.icon_state = "health7" //DEAD healthmeter
		return
	else
		// Vampire bandaid. I'm sorry.
		// Rewrite idea : divide life() into organs (Eyes...) and have flags in the roles if they overwrite the functions of those organs.
		// Basically, the problem here is that abstract things (HUD icons) are handled as the same time as "organs" things (seeing in the dark.)
		var/datum/role/vampire/V = isvampire(src)
		if (V)
			var/i = 1
			for (var/image/I in V.cached_images)
				I.loc = null
				src.client.images -= I
			for (var/mob/living/carbon/C in view(7,src))
				var/obj/item/weapon/nullrod/N = locate(/obj/item/weapon/nullrod) in get_contents_in_object(C)
				if (N)
					if (i > V.cached_images.len)
						var/image/I = image('icons/mob/mob.dmi', loc = C, icon_state = "vampnullrod")
						I.plane = VAMP_ANTAG_HUD_PLANE
						V.cached_images += I
						src.client.images += I
					else
						V.cached_images[i].loc = C
						src.client.images += V.cached_images[i]
					i++

		if (!V || (!(VAMP_VISION in V.powers) && !(VAMP_MATURE in V.powers))) // Not a vampire, or a vampire but neither of the spells.
			change_sight(removing = SEE_MOBS)
		if (!V || !(VAMP_MATURE in V.powers))
			change_sight(removing = SEE_TURFS|SEE_OBJS)
			var/datum/organ/internal/eyes/E = src.internal_organs_by_name["eyes"]
			if(E)
				see_in_dark = E.see_in_dark

			see_invisible = see_in_dark > 2 ? SEE_INVISIBLE_LEVEL_ONE : SEE_INVISIBLE_LIVING

		// Moiving this "see invisble" thing here so that it can be overriden by xrays, vampires...
		if(glasses)
			handle_glasses_vision_updates(glasses)
		else if (!V)
			see_invisible = SEE_INVISIBLE_LIVING

		if(dna)
			switch(dna.mutantrace)
				if("slime")
					see_in_dark = 3
					see_invisible = SEE_INVISIBLE_LEVEL_ONE
				if("shadow")
					see_in_dark = 8
					see_invisible = SEE_INVISIBLE_LEVEL_ONE
		if(M_XRAY in mutations)
			change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
			see_in_dark = 8
			if(!druggy)
				see_invisible = min(SEE_INVISIBLE_LEVEL_TWO, see_invisible)
    // Legacy Cult
		if(seer == 1)
			var/obj/effect/rune_legacy/R = locate() in loc
			var/datum/faction/cult/narsie/blood_cult = find_active_faction_by_type(/datum/faction/cult/narsie)
			var/cultwords
			if (blood_cult)
				cultwords = blood_cult.cult_words
			else
				cultwords = null
			if(cultwords && R && R.word1 == cultwords["see"] && R.word2 == cultwords["hell"] && R.word3 == cultwords["join"])
				see_invisible = SEE_INVISIBLE_OBSERVER
			else
				see_invisible = SEE_INVISIBLE_LIVING
				seer = 0

		apply_vision_overrides()


		if(healths)
			healths.overlays.len = 0
			if (pain_numb)
				healths.icon_state = "health_numb"
			else
				var/ruptured = is_lung_ruptured()
				if(hal_screwyhud)
					for(var/i = 1; i <= 3; i++)
						healths.overlays.Add(pick(organ_damage_overlays))
				else
					for(var/datum/organ/external/e in organs)
						if(istype(e, /datum/organ/external/chest))
							if(ruptured)
								healths.overlays.Add(organ_damage_overlays["[e.name]_max"])
								continue
						var/total_damage = e.get_damage()
						if(!e.is_existing())
							healths.overlays.Add(organ_damage_overlays["[e.name]_gone"])
						else
							switch(total_damage)
								if(30 to INFINITY)
									healths.overlays.Add(organ_damage_overlays["[e.name]_max"])
								if(15 to 30)
									healths.overlays.Add(organ_damage_overlays["[e.name]_mid"])
								if(5 to 15)
									healths.overlays.Add(organ_damage_overlays["[e.name]_min"])
				switch(hal_screwyhud)
					if(1)
						healths.icon_state = "health6"
					if(2)
						healths.icon_state = "health7"
					else
						switch(health - halloss)
							if(100 to INFINITY)
								healths.icon_state = "health0"
							if(80 to 100)
								healths.icon_state = "health1"
							if(60 to 80)
								healths.icon_state = "health2"
							if(40 to 60)
								healths.icon_state = "health3"
							if(20 to 40)
								healths.icon_state = "health4"
							if(0 to 20)
								healths.icon_state = "health5"
							else
								healths.icon_state = "health6"

		if(nutrition_icon)
			switch(nutrition)
				if(450 to INFINITY)
					nutrition_icon.icon_state = "nutrition0"
				if(350 to 450)
					nutrition_icon.icon_state = "nutrition1"
				if(250 to 350)
					nutrition_icon.icon_state = "nutrition2"
				if(150 to 250)
					nutrition_icon.icon_state = "nutrition3"
				else
					nutrition_icon.icon_state = "nutrition4"

			if(ticker && ticker.hardcore_mode) //Hardcore mode: flashing nutrition indicator when starving!
				if(nutrition < STARVATION_MIN)
					nutrition_icon.icon_state = "nutrition5"

		if(pressure)
			pressure.icon_state = "pressure[pressure_alert]"

		update_pull_icon()
//			if(rest) //Not used with new UI
//				if(resting || lying || sleeping)		rest.icon_state = "rest1"
//				else									rest.icon_state = "rest0"
		if(toxin)
			if(hal_screwyhud == 4 || toxins_alert)
				toxin.icon_state = "tox1"
			else
				toxin.icon_state = "tox0"
		if(oxygen)
			if(hal_screwyhud == 3 || oxygen_alert)
				oxygen.icon_state = "oxy1"
			else
				oxygen.icon_state = "oxy0"
		if(fire)
			if(fire_alert)
				fire.icon_state = "fire[fire_alert]" //fire_alert is either 0 if no alert, 1 for cold and 2 for heat.
			else
				fire.icon_state = "fire0"

		if(bodytemp)
			if(has_reagent_in_blood(CAPSAICIN))
				bodytemp.icon_state = "temp4"
			else if(has_reagent_in_blood(FROSTOIL))
				bodytemp.icon_state = "temp-4"
			else if(!(get_thermal_loss(loc.return_air()) > 0.1) || bodytemperature > T0C + 50)
				switch(bodytemperature) //310.055 optimal body temp
					if(370 to INFINITY)
						bodytemp.icon_state = "temp4"
					if(350 to 370)
						bodytemp.icon_state = "temp3"
					if(335 to 350)
						bodytemp.icon_state = "temp2"
					if(320 to 335)
						bodytemp.icon_state = "temp1"
					if(305 to 320)
						bodytemp.icon_state = "temp0"
					if(303 to 305)
						bodytemp.icon_state = "temp-1"
					if(300 to 303)
						bodytemp.icon_state = "temp-2"
					if(290 to 295)
						bodytemp.icon_state = "temp-3"
					if(0   to 290)
						bodytemp.icon_state = "temp-4"
			else if(is_vessel_dilated() && undergoing_hypothermia() == MODERATE_HYPOTHERMIA)
				bodytemp.icon_state = "temp4" // yes, this is intentional - this is the cause of "paradoxical undressing", ie feeling 2hot when hypothermic
			else
				switch(get_thermal_loss(loc.return_air())) // How many degrees of celsius we are losing per tick.
					if(0.1 to 0.15)
						bodytemp.icon_state = "temp-1"
					if(0.15 to 0.2)
						bodytemp.icon_state = "temp-2"
					if(0.2 to 0.4)
						bodytemp.icon_state = "temp-3"
					if(0.4 to INFINITY)
						bodytemp.icon_state = "temp-4"

		if(disabilities & NEARSIGHTED)	//This looks meh but saves a lot of memory by not requiring to add var/prescription
			if(glasses)	//To every /obj/item
				var/obj/item/clothing/glasses/G = glasses
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
		if (istype(glasses, /obj/item/clothing/glasses/science))
			var/obj/item/clothing/glasses/science/S = glasses
			if (S.on)
				overlay_fullscreen("science", /obj/abstract/screen/fullscreen/science)
			else
				clear_fullscreen("science",0)
		else
			clear_fullscreen("science",0)

		var/masked = 0

		if(head)
			if(istype(head, /obj/item/clothing/head/welding) || istype(head, /obj/item/clothing/head/helmet/space/vox/civ/mushmen) || istype(head, /obj/item/clothing/head/helmet/space/unathi) || (/datum/action/item_action/toggle_helmet_mask in head.actions_types))
				var/enable_mask = TRUE

				var/datum/action/item_action/toggle_helmet_mask/action = locate(/datum/action/item_action/toggle_helmet_mask) in head.actions

				if(action)
					enable_mask = !action.up
				else if(istype(head, /obj/item/clothing/head/welding))
					var/obj/item/clothing/head/welding/O = head
					enable_mask = !O.up
				else if(istype(head, /obj/item/clothing/head/helmet/space/vox/civ/mushmen))
					var/obj/item/clothing/head/helmet/space/vox/civ/mushmen/O = head
					enable_mask = !O.up
				if(enable_mask && tinted_weldhelh)
					overlay_fullscreen("tint", /obj/abstract/screen/fullscreen/impaired, 2)
					masked = 1

		if(!masked && istype(glasses, /obj/item/clothing/glasses/welding) && !istype(glasses, /obj/item/clothing/glasses/welding/superior))
			var/obj/item/clothing/glasses/welding/O = glasses
			if(!O.up && tinted_weldhelh)
				overlay_fullscreen("tint", /obj/abstract/screen/fullscreen/impaired, 2)
				masked = 1

		var/clear_tint = !masked

		if(clear_tint)
			clear_fullscreen("tint")

		if(machine)
			if(!machine.check_eye(src))
				reset_view(null)
			if(iscamera(client.eye))
				var/obj/machinery/camera/C = client.eye
				change_sight(copying = C.vision_flags)

		else
			var/isRemoteObserve = 0
			if((M_REMOTE_VIEW in mutations) && remoteview_target)
				isRemoteObserve = 1
				//Is he unconscious or dead?
				if(remoteview_target.stat!=CONSCIOUS)
					to_chat(src, "<span class='warning'>Your psy-connection grows too faint to maintain!</span>")
					isRemoteObserve = 0

				//Does he have psy resist?
				if(M_PSY_RESIST in remoteview_target.mutations)
					to_chat(src, "<span class='warning'>Your mind is shut out!</span>")
					isRemoteObserve = 0

				//Not on the station or mining?
				var/turf/temp_turf = get_turf(remoteview_target)

				if(temp_turf && (temp_turf.z != map.zMainStation && temp_turf.z != map.zAsteroid) || remoteview_target.stat!=CONSCIOUS)
					to_chat(src, "<span class='warning'>Your psy-connection grows too faint to maintain!</span>")
					isRemoteObserve = 0
			if(!isRemoteObserve && client && !client.adminobs && !isTeleViewing(client.eye))
				remoteview_target = null
				reset_view(null)
	return 1
