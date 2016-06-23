/mob/living/silicon/robot/Life()
	set invisibility = 0
	//set background = 1
	if(timestopped) return 0 //under effects of time magick

	if (monkeyizing)
		return

	blinded = null

	//Status updates, death etc.
	clamp_values()
	handle_regular_status_updates()

	if(client)
		handle_regular_hud_updates()
		update_items()
	if (stat != DEAD) //still using power
		use_power()
		process_killswitch()
		process_locks()
		if(module)
			module.recharge_consumable(src)
	update_canmove()
	handle_fire()
	handle_beams()

/mob/living/silicon/robot/proc/clamp_values()

//	SetStunned(min(stunned, 30))
	SetParalysis(min(paralysis, 30))
//	SetWeakened(min(weakened, 20))
	sleeping = 0
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)

/mob/living/silicon/robot/proc/use_power()


	if (is_component_functioning("power cell") && cell)
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

			stat = 0
	else
		uneq_all()
		stat = 1


/mob/living/silicon/robot/proc/handle_regular_status_updates()


	if(camera && !scrambledcodes)
		if(stat == 2 || wires.IsCameraCut())
			camera.status = 0
		else
			camera.status = 1

	updatehealth()

	if(sleeping)
		Paralyse(3)
		sleeping--

	if(resting)
		Weaken(5)

	if(health <= 0 && stat != 2) //die only once
		death()

	if (stat != 2) //Alive.
		if (paralysis || stunned || weakened) //Stunned etc.
			stat = 1
			if (stunned > 0)
				AdjustStunned(-1)
			if (weakened > 0)
				AdjustWeakened(-1)
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

	if (stuttering) stuttering--

	if (eye_blind)
		eye_blind--
		blinded = 1

	if (ear_deaf > 0) ear_deaf--
	if (ear_damage < 25)
		ear_damage -= 0.05
		ear_damage = max(ear_damage, 0)

	density = !( lying )

	if ((sdisabilities & BLIND))
		blinded = 1
	if ((sdisabilities & DEAF))
		ear_deaf = 1

	if (eye_blurry > 0)
		eye_blurry--
		eye_blurry = max(0, eye_blurry)

	if (druggy > 0)
		druggy--
		druggy = max(0, druggy)

	if(!is_component_functioning("radio"))
		radio.on = 0
	else
		radio.on = 1

	if(is_component_functioning("camera"))
		blinded = 0
	else
		blinded = 1


	return 1

/mob/living/silicon/robot/proc/handle_sensor_modes()
	sight &= ~SEE_MOBS
	sight &= ~SEE_TURFS
	sight &= ~SEE_OBJS
	sight &= ~BLIND
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	if (stat == DEAD)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else
		if (M_XRAY in mutations || sight_mode & BORGXRAY)
			sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_LEVEL_TWO
		if ((sight_mode & BORGTHERM) || sensor_mode == THERMAL_VISION)
			sight |= SEE_MOBS
			see_in_dark = 4
			see_invisible = SEE_INVISIBLE_MINIMUM
		if (sensor_mode == NIGHT)
			see_invisible = SEE_INVISIBLE_MINIMUM
			see_in_dark = 8
		if ((sight_mode & BORGMESON) || (sensor_mode == MESON_VISION))
			sight |= SEE_TURFS
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_MINIMUM


/mob/living/silicon/robot/proc/handle_regular_hud_updates()
	handle_sensor_modes()
	/*if (stat == 2 || M_XRAY in mutations || sight_mode & BORGXRAY)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
	else if ((sight_mode & BORGMESON  || sensor_mode == MESON_VISION) && sight_mode & BORGTHERM)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
	else if (sight_mode & BORGMESON  || sensor_mode == MESON_VISION)
		sight |= SEE_TURFS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
	else if (sight_mode & BORGTHERM)
		sight |= SEE_MOBS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if (stat != 2)
		sight &= ~SEE_MOBS
		sight &= ~SEE_TURFS
		sight &= ~SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO*/

	regular_hud_updates() //Handles MED/SEC HUDs for borgs.
	switch(sensor_mode)
		if (SEC_HUD)
			process_sec_hud(src, 1)
		if (MED_HUD)
			process_med_hud(src)

	/*switch(sensor_mode)
		if (SEC_HUD)
			process_sec_hud(src, 1)
		if (MED_HUD)
			process_med_hud(src)*/

	if (healths)
		if (stat != 2)
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

	if (syndicate && client)
		if(ticker.mode.name == "traitor")
			for(var/datum/mind/tra in ticker.mode.traitors)
				if(tra.current)
					var/I = image('icons/mob/mob.dmi', loc = tra.current, icon_state = "traitor")
					client.images += I
		if(connected_ai)
			connected_ai.connected_robots -= src
			connected_ai = null
		if(mind)
			if(!mind.special_role)
				mind.special_role = "traitor"
				ticker.mode.traitors += mind

	if (cells)
		if (cell)
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

	if(bodytemp)
		switch(bodytemperature) //310.055 optimal body temp
			if(335 to INFINITY)
				bodytemp.icon_state = "temp2"
			if(320 to 335)
				bodytemp.icon_state = "temp1"
			if(300 to 320)
				bodytemp.icon_state = "temp0"
			if(260 to 300)
				bodytemp.icon_state = "temp-1"
			else
				bodytemp.icon_state = "temp-2"


	update_pull_icon()
//Oxygen and fire does nothing yet!!
//	if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
//	if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"

	if(eye_blind || blinded)
		overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
	else
		clear_fullscreen("blind")
	if (disabilities & NEARSIGHTED)
		overlay_fullscreen("impaired", /obj/screen/fullscreen/impaired)
	else
		clear_fullscreen("impaired")
	if (eye_blurry)
		overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
	else
		clear_fullscreen("blurry")
	if (druggy)
		overlay_fullscreen("high", /obj/screen/fullscreen/high)
	else
		clear_fullscreen("high")

	if (stat != 2)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(client && !client.adminobs && !iscamera(client.eye) && !isTeleViewing(client.eye))
				reset_view(null)

	return 1

/mob/living/silicon/robot/proc/update_items()
	if (client)
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
	if(weapon_lock)
		uneq_all()
		weaponlock_time --
		if(weaponlock_time <= 0)
			if(client)
				to_chat(src, "<span class='warning'><B>Weapon Lock Timed Out!</span>")
			weapon_lock = 0
			weaponlock_time = 120

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

/mob/living/silicon/robot/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()

//Robots on fire

/mob/living/silicon/robot/update_canmove()
	if(paralysis || stunned || weakened || locked_to || lockcharge) canmove = 0
	else canmove = 1
	return canmove
