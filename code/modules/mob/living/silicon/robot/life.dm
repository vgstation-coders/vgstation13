/mob/living/silicon/robot/Life()
	if(timestopped)
		return FALSE //under effects of time magick
	if(monkeyizing)
		return

	blinded = null

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
	var/datum/gas_mixture/environment = loc.return_air()
	handle_pressure_damage(environment)
	handle_heat_damage(environment)
	if(spell_masters && spell_masters.len)
		for(var/obj/abstract/screen/movable/spell_master/spell_master in spell_masters)
			spell_master.update_spells(0, src)

/mob/living/silicon/robot/proc/clamp_values()
	SetParalysis(min(paralysis, 30))
	sleeping = 0
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)

/mob/living/silicon/robot/proc/use_power()
	if(is_component_functioning("power cell") && cell)
		if(cell.charge <= 0)
			uneq_all()
		else
			if(module_state_1)
				cell.use(3)
			if(module_state_2)
				cell.use(3)
			if(module_state_3)
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
	if(camera && !scrambledcodes)
		if(isDead() || wires.IsCameraCut())
			camera.status = FALSE
		else
			camera.status = TRUE

	updatehealth()

	if(sleeping)
		Paralyse(3)
		sleeping--

	if(resting)
		Knockdown(5)

	if(health <= 0 && !isDead()) //die only once
		death()

	if(!isDead()) //Alive.
		if(paralysis || stunned || knockdown) //Stunned etc.
			stat = UNCONSCIOUS
			if(stunned > 0)
				AdjustStunned(-1)
			if(knockdown > 0)
				AdjustKnockdown(-1)
			if(paralysis > 0)
				AdjustParalysis(-1)
				blinded = TRUE
			else
				blinded = FALSE

		else	//Not stunned.
			stat = CONSCIOUS

	else //Dead.
		blinded = TRUE
		stat = DEAD

	if(stuttering)
		stuttering--

	if(eye_blind)
		eye_blind--
		blinded = TRUE

	if(ear_deaf)
		ear_deaf--
	if(ear_damage < 25)
		ear_damage -= 0.05
		ear_damage = max(ear_damage, 0)

	src.setDensity(!(src.lying))

	if((sdisabilities & BLIND))
		blinded = TRUE
	if((sdisabilities & DEAF))
		ear_deaf = TRUE

	if(eye_blurry)
		eye_blurry--
		eye_blurry = max(0, eye_blurry)

	if(druggy)
		druggy--
		druggy = max(0, druggy)

	handle_dizziness()
	handle_jitteriness()

	if(!is_component_functioning("radio"))
		radio.on = FALSE
	else
		radio.on = TRUE

	if(is_component_functioning("camera"))
		blinded = FALSE
	else
		blinded = TRUE

	return TRUE

/mob/living/silicon/robot/proc/handle_sensor_modes()
	change_sight(removing = SEE_TURFS|SEE_MOBS|SEE_OBJS|BLIND)
	if(client)
		client.color = initial(client.color)
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	if(isDead())
		change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else
		if(M_XRAY in mutations || sight_mode & BORGXRAY)
			change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_LEVEL_TWO
		if((sight_mode & BORGTHERM) || sensor_mode == THERMAL_VISION)
			change_sight(adding = SEE_MOBS)
			see_in_dark = 4
			see_invisible = SEE_INVISIBLE_MINIMUM
		if(sensor_mode == NIGHT)
			see_invisible = SEE_INVISIBLE_MINIMUM
			see_in_dark = 8
			if(client)
				client.color = list(0.33,0.33,0.33,0,
									0.33,0.33,0.33,0,
				 					0.33,0.33,0.33,0,
				 					0,0,0,1,
				 					-0.2,0,-0.2,0)
		if((sight_mode & BORGMESON) || (sensor_mode == MESON_VISION))
			change_sight(adding = SEE_TURFS)
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_MINIMUM


/mob/living/silicon/robot/handle_regular_hud_updates()
	handle_sensor_modes()

	regular_hud_updates() //Handles MED/SEC HUDs for borgs.
	switch(sensor_mode)
		if(SEC_HUD)
			process_sec_hud(src, 1)
		if(MED_HUD)
			process_med_hud(src)

	if(healths)
		if(!isDead())
			switch(health)
				if(200 to INFINITY)
					healths.icon_state = "health0"
				if(150 to 200)
					healths.icon_state = "health1"
				if(100 to 150)
					healths.icon_state = "health2"
				if(50 to 100)
					healths.icon_state = "health3"
				if(0 to 50)
					healths.icon_state = "health4"
				if(config.health_threshold_dead to 0)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(cells)
		if(cell)
			var/cellcharge = cell.charge/cell.maxcharge
			switch(cellcharge)
				if(0.75 to INFINITY)
					cells.icon_state = "charge4"
				if(0.5 to 0.75)
					cells.icon_state = "charge3"
				if(0.25 to 0.5)
					cells.icon_state = "charge2"
				if(0 to 0.25)
					cells.icon_state = "charge1"
				else
					cells.icon_state = "charge0"
		else
			cells.icon_state = "charge-empty"

	if(bodytemp) //actually environment temperature but fuck it
		bodytemp.icon_state = "temp[temp_alert]"
	if(pressure)
		pressure.icon_state = "pressure[pressure_alert]"
	if(album_icon)
		album_icon.icon_state = "album[connected_ai ? "1":""]"

	update_pull_icon()

	fire.icon_state = "fire[on_fire ? 1 : 0]"

	if(eye_blind || blinded)
		overlay_fullscreen("blind", /obj/abstract/screen/fullscreen/blind)
	else
		clear_fullscreen("blind")
	if(disabilities & NEARSIGHTED)
		overlay_fullscreen("impaired", /obj/abstract/screen/fullscreen/impaired)
	else
		clear_fullscreen("impaired")
	if(eye_blurry)
		overlay_fullscreen("blurry", /obj/abstract/screen/fullscreen/blurry)
	else
		clear_fullscreen("blurry")
	if(druggy)
		overlay_fullscreen("high", /obj/abstract/screen/fullscreen/high)
	else
		clear_fullscreen("high")

	if(!isDead())
		if(machine)
			if(!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(client && !client.adminobs && !iscamera(client.eye) && !isTeleViewing(client.eye))
				reset_view(null)

	return TRUE

/mob/living/silicon/robot/proc/update_items()
	if(client)
		client.screen -= contents
		for(var/obj/I in contents)
			if(I && !(istype(I,/obj/item/weapon/cell) || istype(I,/obj/item/device/radio)  || istype(I,/obj/machinery/camera) || istype(I,/obj/item/device/mmi)))
				client.screen += I
	if(module_state_1)
		module_state_1:screen_loc = ui_inv1
	if(module_state_2)
		module_state_2:screen_loc = ui_inv2
	if(module_state_3)
		module_state_3:screen_loc = ui_inv3
	updateicon()

/mob/living/silicon/robot/proc/process_killswitch()
	if(killswitch)
		killswitch_time --
		if(killswitch_time <= 0)
			if(client)
				to_chat(src, "<span class='warning'><B>Killswitch Activated</span>")
			killswitch = 0
			spawn(5)
				gib()

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
	if(locate(/obj/item/borg/fire_shield, module.modules))
		return
	..()

//Robots on fire
/mob/living/silicon/robot/handle_fire()
	if(..())
		return
	adjustFireLoss(3)
	return

/mob/living/silicon/robot/update_fire()
	overlays -= image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing")
	if(on_fire)
		overlays += image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing")
	update_icons()
	return

/mob/living/silicon/robot/update_canmove()
	if(paralysis || stunned || knockdown || locked_to || lockcharge)
		canmove = FALSE
	else
		canmove = TRUE
	return canmove

// This handles the pressure sensor hud element. Values based on human values.
/mob/living/silicon/robot/proc/handle_pressure_damage(datum/gas_mixture/environment)
	//by the power of Polymorph and Errorage
	var/localpressure = environment.return_pressure()
	var/adjusted_pressure = localpressure - ONE_ATMOSPHERE //REAL pressure
	if(localpressure)
		if(adjusted_pressure >= HAZARD_HIGH_PRESSURE)
			pressure_alert = 2
		else if(localpressure >= WARNING_HIGH_PRESSURE && localpressure < WARNING_HIGH_PRESSURE)
			pressure_alert = 1
		else if(localpressure <= WARNING_LOW_PRESSURE && localpressure > HAZARD_LOW_PRESSURE)
			pressure_alert = -1
		else if(localpressure <= HAZARD_LOW_PRESSURE)
			pressure_alert = -2
		else
			pressure_alert = 0
	else //there ain't no air, we're in a vacuum
		pressure_alert = -2

// This handles the temp sensor hud element
/mob/living/silicon/robot/proc/handle_heat_damage(datum/gas_mixture/environment)
	var/envirotemp = environment.return_temperature()
	if(environment)
		if(envirotemp)
			if (envirotemp >= 1000 ) //1000 is the heat_level_3 for humans
				temp_alert = 2
			else if (envirotemp >= BODYTEMP_HEAT_DAMAGE_LIMIT && envirotemp < 1000 )
				temp_alert = 1
			else if (envirotemp <= T0C && envirotemp > BODYTEMP_COLD_DAMAGE_LIMIT)
				temp_alert = -1
			else if (envirotemp <= BODYTEMP_COLD_DAMAGE_LIMIT ) //space is cold
				temp_alert = -2
			else
				temp_alert = 0
				return 0
	else //vacuums are cold
		temp_alert = -2
