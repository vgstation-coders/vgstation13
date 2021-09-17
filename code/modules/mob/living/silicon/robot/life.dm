/mob/living/silicon/robot/Life()
	if(timestopped)
		return FALSE //under effects of time magick
	if(monkeyizing)
		return

	blinded = FALSE

	//Status updates, death etc.
	clamp_values()
	handle_regular_status_updates()

	if(client)
		handle_regular_hud_updates()
		update_action_buttons_icon()
		update_items()

	if(!isDead()) //still using power
		use_power()
		process_killswitch()
		process_locks()

	update_canmove()
	handle_fire()
	handle_beams()

	if(loc)
		var/datum/gas_mixture/environment = loc.return_air()
		handle_pressure_damage(environment)
		handle_heat_damage(environment)

	if(spell_masters && spell_masters.len)
		for(var/obj/abstract/screen/movable/spell_master/spell_master in spell_masters)
			spell_master.update_spells(0, src)

	if(locked_to_z)
		check_locked_zlevel()

/mob/living/silicon/robot/proc/clamp_values()
	SetParalysis(min(paralysis, 30))
	sleeping = 0
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)

/mob/living/silicon/robot/proc/use_power()
	if(cell && is_component_functioning("power cell"))
		if(cell.charge <= 0)
			uneq_all()
		else
			if(cell.charge <= ROBOT_LOW_POWER)
				uneq_all()
				cell.use(1)
			else
				for(var/M in get_all_slots())
					cell.use(3)

			for(var/V in components)
				var/datum/robot_component/C = components[V]
				C.consume_power()

			if(!is_component_functioning("actuator"))
				Paralyse(3)

			stat = CONSCIOUS
	else
		uneq_all()

		if(station_holomap)
			if(station_holomap.watching_mob)
				station_holomap.stopWatching()

		stat = UNCONSCIOUS


/mob/living/silicon/robot/proc/handle_regular_status_updates()
	updatehealth()

	if(sleeping)
		Paralyse(3)
		sleeping = max(sleeping-1, 0)

	if(resting)
		Knockdown(5)
	setDensity(!(lying))

	if(health <= 0 && !isDead()) //die only once
		death()

	if(!isDead()) //Alive.
		blinded = !(paralysis || is_component_functioning("camera"))
		stat = !(paralysis || stunned || knockdown) ? CONSCIOUS : UNCONSCIOUS
	else //Dead.
		blinded = TRUE
		stat = DEAD

	if(stunned > 0)
		AdjustStunned(-1)
	if(knockdown > 0)
		AdjustKnockdown(-1)
	if(paralysis > 0)
		AdjustParalysis(-1)
	if(stuttering)
		stuttering = max(stuttering-1, 0)
	if(eye_blind)
		eye_blind = max(eye_blind-1,0)
	if(ear_deaf)
		ear_deaf = max(ear_deaf-1,0)
	if(ear_damage < 25)
		ear_damage = max(ear_damage-0.05, 0)
	if((sdisabilities & DEAF))
		ear_deaf = TRUE

	if(eye_blurry)
		eye_blurry = max(eye_blurry-1,0)
	if(druggy)
		druggy = max(druggy-1,0)

	if(jitteriness)
		jitteriness = max(jitteriness-1,0)
	handle_jitteriness()
	if(dizziness)
		dizziness = max(0, dizziness - 1)
	handle_dizziness()

	if(camera && !scrambledcodes)
		camera.status = !(isDead() || wires.IsCameraCut())
	if(radio)
		radio.on = is_component_functioning("radio")

	return TRUE

/mob/living/silicon/robot/proc/handle_sensor_modes()
	change_sight(removing = SEE_TURFS|SEE_MOBS|SEE_OBJS|BLIND)
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	see_in_dark = 8

	if(client)
		client.color = initial(client.color)

	if(isDead())
		change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
		return

	switch(sensor_mode)
		if(NIGHT)
			if(client)
				client.color = list(0.33,0.33,0.33,0,
									0.33,0.33,0.33,0,
			 						0.33,0.33,0.33,0,
				 					0,0,0,1,
				 					-0.2,0,-0.2,0)
			see_invisible = SEE_INVISIBLE_MINIMUM
			dark_plane.alphas["robot_night_vision"] = 255
			dark_plane.alphas -= "robot_mesons"
			dark_plane.alphas -= "robot_thermal"
		if(MESON_VISION)
			change_sight(adding = SEE_TURFS)
			see_invisible = SEE_INVISIBLE_MINIMUM
			dark_plane.alphas["robot_mesons"] = 255
			dark_plane.alphas -= "robot_night_vision"
			dark_plane.alphas -= "robot_thermal"
		if(THERMAL_VISION)
			change_sight(adding = SEE_MOBS)
			see_invisible = SEE_INVISIBLE_MINIMUM
			dark_plane.alphas["robot_thermal"] = 255
			dark_plane.alphas -= "robot_mesons"
			dark_plane.alphas -= "robot_night_vision"
			see_in_dark = 4
		else // nothing
			dark_plane.alphas -= "robot_night_vision"
			dark_plane.alphas -= "robot_mesons"
			dark_plane.alphas -= "robot_thermal"

	check_dark_vision()

/mob/living/silicon/robot/proc/process_killswitch()
	if(scrambledcodes)
		return
	if(cyborg_detonation_time != 0 && world.time >= cyborg_detonation_time)
		self_destruct()

/mob/living/silicon/robot/proc/process_locks()
	if(modulelock)
		if(uneq_all())
			to_chat(src, "<span class='alert' style=\"font-family:Courier\">Module unequipped.</span>")
		modulelock_time --
		if(modulelock_time <= 0)
			if(client)
				to_chat(src, "<span class='info' style=\"font-family:Courier\"><B>Module lock timed out!</span>")
			modulelock = FALSE
			modulelock_time = 120

/mob/living/silicon/robot/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!module)
		..()
		return
	if(module && locate(/obj/item/borg/fire_shield, module.modules))
		return
	..()

//Robots on fire
/mob/living/silicon/robot/handle_fire()
	if(..())
		return
	adjustFireLoss(3)

/mob/living/silicon/robot/update_fire()
	overlays -= image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing")
	if(on_fire)
		overlays += image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing")
	update_icons()

/mob/living/silicon/robot/update_canmove()
	canmove = !(paralysis || stunned || knockdown || locked_to || lockdown || anchored)
	return canmove

/mob/living/silicon/robot/proc/check_locked_zlevel()
	if(!locked_to_z)
		return

	var/datum/zLevel/current_zlevel = get_z_level(src)
	if(!current_zlevel)
		return
	if(current_zlevel.z != locked_to_z)
		to_chat(src, "<span class='userdanger'>Your hardware detects that you have left your intended location. Initiating self-destruct.</span>")
		spawn(rand(2,7) SECONDS)
			if(mmi) //no sneaking brains away
				qdel(mmi)
				mmi = null
			gib()
