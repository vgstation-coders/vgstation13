//Refer to life.dm for caller

/mob/living/carbon/human/handle_regular_hud_updates()
	if(!client)
		return 0

	change_sight(removing = BLIND)

	regular_hud_updates()

	update_action_buttons_icon()

	standard_damage_overlay_updates()

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
						I.plane = ABOVE_LIGHTING_PLANE
						V.cached_images += I
						src.client.images += I
					else
						V.cached_images[i].loc = C
						src.client.images += V.cached_images[i]
					i++

		if (!V || !V.is_mature_or_has_vision()) // Not a vampire, or a vampire but neither of the spells.
			change_sight(removing = SEE_MOBS)
		if (!V || !(locate(/datum/power/vampire/mature) in V.current_powers))
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
		if(M_THERMALS in mutations)
			change_sight(adding = SEE_MOBS)
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
							if(105 to INFINITY)
								healths.icon_state = "health0"
							if(104)
								healths.icon_state = "health104"
							if(100 to 103)
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


		if(has_reagent_in_blood(CAPSAICIN))
			temperature_alert = TEMP_ALARM_HEAT_STRONG
		if(has_reagent_in_blood(ZAMSPICYTOXIN))
			temperature_alert = TEMP_ALARM_HEAT_STRONG
		else if(has_reagent_in_blood(FROSTOIL))
			temperature_alert = TEMP_ALARM_COLD_STRONG
		else if(!(get_thermal_loss(loc.return_air()) > 0.1) || bodytemperature > T0C + 50)
			switch(bodytemperature) //310.055 optimal body temp
				if(370 to INFINITY)
					temperature_alert = TEMP_ALARM_HEAT_STRONG
				if(350 to 370)
					temperature_alert = TEMP_ALARM_HEAT_MILD
				if(335 to 350)
					temperature_alert = TEMP_ALARM_HEAT_WEAK
				if(320 to 335)
					temperature_alert = TEMP_ALARM_SAFE
				if(305 to 320)
					temperature_alert = TEMP_ALARM_SAFE
				if(303 to 305)
					temperature_alert = TEMP_ALARM_SAFE
				if(300 to 303)
					temperature_alert = TEMP_ALARM_COLD_WEAK
				if(290 to 295)
					temperature_alert = TEMP_ALARM_COLD_MILD
				if(0   to 290)
					temperature_alert = TEMP_ALARM_COLD_STRONG
		else if(is_vessel_dilated() && undergoing_hypothermia() == MODERATE_HYPOTHERMIA)
			temperature_alert = TEMP_ALARM_HEAT_STRONG // yes, this is intentional - this is the cause of "paradoxical undressing", ie feeling 2hot when hypothermic
		else
			switch(get_thermal_loss(loc.return_air())) // How many degrees of celsius we are losing per tick.
				if(0.1 to 0.15)
					temperature_alert = TEMP_ALARM_SAFE
				if(0.15 to 0.2)
					temperature_alert = TEMP_ALARM_COLD_WEAK
				if(0.2 to 0.4)
					temperature_alert = TEMP_ALARM_COLD_MILD
				if(0.4 to INFINITY)
					temperature_alert = TEMP_ALARM_COLD_STRONG


		if(pressure_alert)
			throw_alert(SCREEN_ALARM_PRESSURE, pressure_alert < 0 ? /obj/abstract/screen/alert/carbon/pressure/low : /obj/abstract/screen/alert/carbon/pressure/high, pressure_alert)
		else
			clear_alert(SCREEN_ALARM_PRESSURE)
		if(hal_screwyhud == 3 || oxygen_alert)
			throw_alert(SCREEN_ALARM_BREATH, /obj/abstract/screen/alert/carbon/breath)
		else
			clear_alert(SCREEN_ALARM_BREATH)
		if(hal_screwyhud == 4 || toxins_alert)
			throw_alert(SCREEN_ALARM_TOXINS, /obj/abstract/screen/alert/tox)
		else
			clear_alert(SCREEN_ALARM_TOXINS)
		if(fire_alert)
			throw_alert(SCREEN_ALARM_FIRE, fire_alert == 1 ? /obj/abstract/screen/alert/carbon/burn/ice : /obj/abstract/screen/alert/carbon/burn/fire, fire_alert) //fire_alert is either 0 if no alert, 1 for cold and 2 for heat.
		else
			clear_alert(SCREEN_ALARM_FIRE)
		if(temperature_alert)
			throw_alert(SCREEN_ALARM_TEMPERATURE, temperature_alert < 0 ? /obj/abstract/screen/alert/carbon/temp/cold : /obj/abstract/screen/alert/carbon/temp/hot, temperature_alert)
		else
			clear_alert(SCREEN_ALARM_TEMPERATURE)
		if(sleeping)
			throw_alert(SCREEN_ALARM_SLEEP, /obj/abstract/screen/alert/carbon/i_slep)
		else
			clear_alert(SCREEN_ALARM_SLEEP)
		switch(nutrition)
			if(450 to INFINITY)
				throw_alert(SCREEN_ALARM_FOOD, /obj/abstract/screen/alert/carbon/food/fat, 0)
			if(250 to 450)
				clear_alert(SCREEN_ALARM_FOOD)
			if(150 to 250)
				throw_alert(SCREEN_ALARM_FOOD, /obj/abstract/screen/alert/carbon/food/hungry, 3)
			else
				throw_alert(SCREEN_ALARM_FOOD, /obj/abstract/screen/alert/carbon/food/starving, 4)
		if(ticker && ticker.hardcore_mode) //Hardcore mode: flashing nutrition indicator when starving!
			if(nutrition < STARVATION_MIN)
				throw_alert(SCREEN_ALARM_FOOD, /obj/abstract/screen/alert/carbon/food/starving, 5)

		update_pull_icon()

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
			if(istype(head, /obj/item/clothing/head/welding) || istype(head, /obj/item/clothing/head/helmet/space/unathi) || (/datum/action/item_action/toggle_helmet_mask in head.actions_types))
				var/enable_mask = TRUE

				var/datum/action/item_action/toggle_helmet_mask/action = locate(/datum/action/item_action/toggle_helmet_mask) in head.actions

				if(action)
					enable_mask = !action.up
				else if(istype(head, /obj/item/clothing/head/welding))
					var/obj/item/clothing/head/welding/O = head
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
