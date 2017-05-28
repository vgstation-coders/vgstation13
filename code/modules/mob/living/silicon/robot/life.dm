/mob/living/silicon/robot/Life()
	set invisibility = 0
	//set background = 1
	if(timestopped)
		return 0 //under effects of time magick

	if (src.monkeyizing)
		return

	src.blinded = null

	//Status updates, death etc.
	clamp_values()
	handle_regular_status_updates()

	if(client)
		handle_regular_hud_updates()
		update_action_buttons()
		update_items()
	if (src.stat != DEAD) //still using power
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
//	SetKnockdown(min(knockdown, 20))
	sleeping = 0
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)

/mob/living/silicon/robot/proc/use_power()


	if (is_component_functioning("power cell") && cell)
		if(src.cell.charge <= 0)
			uneq_all()
		else
			if(src.module_state_1)
				src.cell.use(3)
			if(src.module_state_2)
				src.cell.use(3)
			if(src.module_state_3)
				src.cell.use(3)

			for(var/V in components)
				var/datum/robot_component/C = components[V]
				C.consume_power()

			if(!is_component_functioning("actuator"))
				Paralyse(3)

			src.stat = 0
	else
		uneq_all()
		src.stat = 1


/mob/living/silicon/robot/proc/handle_regular_status_updates()


	if(src.camera && !scrambledcodes)
		if(src.stat == 2 || wires.IsCameraCut())
			src.camera.status = 0
		else
			src.camera.status = 1

	updatehealth()

	if(src.sleeping)
		Paralyse(3)
		src.sleeping--

	if(src.resting)
		Knockdown(5)

	if(health <= 0 && src.stat != 2) //die only once
		death()

	if (src.stat != 2) //Alive.
		if (src.paralysis || src.stunned || src.knockdown) //Stunned etc.
			src.stat = 1
			if (src.stunned > 0)
				AdjustStunned(-1)
			if (src.knockdown > 0)
				AdjustKnockdown(-1)
			if (src.paralysis > 0)
				AdjustParalysis(-1)
				src.blinded = 1
			else
				src.blinded = 0

		else	//Not stunned.
			src.stat = 0

	else //Dead.
		src.blinded = 1
		src.stat = 2

	if (src.stuttering)
		src.stuttering--

	if (src.eye_blind)
		src.eye_blind--
		src.blinded = 1

	if (src.ear_deaf > 0)
		src.ear_deaf--
	if (src.ear_damage < 25)
		src.ear_damage -= 0.05
		src.ear_damage = max(src.ear_damage, 0)

	src.density = !( src.lying )

	if ((src.sdisabilities & BLIND))
		src.blinded = 1
	if ((src.sdisabilities & DEAF))
		src.ear_deaf = 1

	if (src.eye_blurry > 0)
		src.eye_blurry--
		src.eye_blurry = max(0, src.eye_blurry)

	if (src.druggy > 0)
		src.druggy--
		src.druggy = max(0, src.druggy)

	if(!is_component_functioning("radio"))
		radio.on = 0
	else
		radio.on = 1

	if(is_component_functioning("camera"))
		src.blinded = 0
	else
		src.blinded = 1


	return 1

/mob/living/silicon/robot/proc/handle_sensor_modes()
	change_sight(removing = SEE_TURFS|SEE_MOBS|SEE_OBJS|BLIND)
	if(client)
		client.color = initial(client.color)
	src.see_in_dark = 8
	src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
	if (src.stat == DEAD)
		change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
		src.see_in_dark = 8
		src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else
		if (M_XRAY in mutations || src.sight_mode & BORGXRAY)
			change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
			src.see_in_dark = 8
			src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		if ((src.sight_mode & BORGTHERM) || sensor_mode == THERMAL_VISION)
			change_sight(adding = SEE_MOBS)
			src.see_in_dark = 4
			src.see_invisible = SEE_INVISIBLE_MINIMUM
		if (sensor_mode == NIGHT)
			see_invisible = SEE_INVISIBLE_MINIMUM
			see_in_dark = 8
			if(client)
				client.color = list(0.33,0.33,0.33,0,
									0.33,0.33,0.33,0,
				 					0.33,0.33,0.33,0,
				 					0,0,0,1,
				 					-0.2,0,-0.2,0)
		if ((src.sight_mode & BORGMESON) || (sensor_mode == MESON_VISION))
			change_sight(adding = SEE_TURFS)
			src.see_in_dark = 8
			see_invisible = SEE_INVISIBLE_MINIMUM


/mob/living/silicon/robot/proc/handle_regular_hud_updates()
	handle_sensor_modes()

	regular_hud_updates() //Handles MED/SEC HUDs for borgs.
	switch(sensor_mode)
		if (SEC_HUD)
			process_sec_hud(src, 1)
		if (MED_HUD)
			process_med_hud(src)

	if (src.healths)
		if (src.stat != 2)
			switch(health)
				if(200 to INFINITY)
					src.healths.icon_state = "health0"
				if(150 to 200)
					src.healths.icon_state = "health1"
				if(100 to 150)
					src.healths.icon_state = "health2"
				if(50 to 100)
					src.healths.icon_state = "health3"
				if(0 to 50)
					src.healths.icon_state = "health4"
				if(config.health_threshold_dead to 0)
					src.healths.icon_state = "health5"
				else
					src.healths.icon_state = "health6"
		else
			src.healths.icon_state = "health7"

	if (src.syndicate && src.client)
		if(ticker.mode.name == "traitor")
			for(var/datum/mind/tra in ticker.mode.traitors)
				if(tra.current)
					var/I = image('icons/mob/mob.dmi', loc = tra.current, icon_state = "traitor")
					src.client.images += I
		if(src.connected_ai)
			src.connected_ai.connected_robots -= src
			src.connected_ai = null
		if(src.mind)
			if(!src.mind.special_role)
				src.mind.special_role = "traitor"
				ticker.mode.traitors += src.mind

	if (src.cells)
		if (src.cell)
			var/cellcharge = src.cell.charge/src.cell.maxcharge
			switch(cellcharge)
				if(0.75 to INFINITY)
					src.cells.icon_state = "charge4"
				if(0.5 to 0.75)
					src.cells.icon_state = "charge3"
				if(0.25 to 0.5)
					src.cells.icon_state = "charge2"
				if(0 to 0.25)
					src.cells.icon_state = "charge1"
				else
					src.cells.icon_state = "charge0"
		else
			src.cells.icon_state = "charge-empty"

	if(bodytemp)
		switch(src.bodytemperature) //310.055 optimal body temp
			if(335 to INFINITY)
				src.bodytemp.icon_state = "temp2"
			if(320 to 335)
				src.bodytemp.icon_state = "temp1"
			if(300 to 320)
				src.bodytemp.icon_state = "temp0"
			if(260 to 300)
				src.bodytemp.icon_state = "temp-1"
			else
				src.bodytemp.icon_state = "temp-2"


	update_pull_icon()
//Oxygen and fire does nothing yet!!
//	if (src.oxygen) src.oxygen.icon_state = "oxy[src.oxygen_alert ? 1 : 0]"
//	if (src.fire) src.fire.icon_state = "fire[src.fire_alert ? 1 : 0]"

	if(src.eye_blind || blinded)
		overlay_fullscreen("blind", /obj/abstract/screen/fullscreen/blind)
	else
		clear_fullscreen("blind")
	if (src.disabilities & NEARSIGHTED)
		overlay_fullscreen("impaired", /obj/abstract/screen/fullscreen/impaired)
	else
		clear_fullscreen("impaired")
	if (src.eye_blurry)
		overlay_fullscreen("blurry", /obj/abstract/screen/fullscreen/blurry)
	else
		clear_fullscreen("blurry")
	if (src.druggy)
		overlay_fullscreen("high", /obj/abstract/screen/fullscreen/high)
	else
		clear_fullscreen("high")

	if (src.stat != 2)
		if (src.machine)
			if (!( src.machine.check_eye(src) ))
				src.reset_view(null)
		else
			if(client && !client.adminobs && !iscamera(client.eye) && !isTeleViewing(client.eye))
				reset_view(null)

	return 1

/mob/living/silicon/robot/proc/update_items()
	if (src.client)
		src.client.screen -= src.contents
		for(var/obj/I in src.contents)
			if(I && !(istype(I,/obj/item/weapon/cell) || istype(I,/obj/item/device/radio)  || istype(I,/obj/machinery/camera) || istype(I,/obj/item/device/mmi)))
				src.client.screen += I
	if(src.module_state_1)
		src.module_state_1:screen_loc = ui_inv1
	if(src.module_state_2)
		src.module_state_2:screen_loc = ui_inv2
	if(src.module_state_3)
		src.module_state_3:screen_loc = ui_inv3
	updateicon()

/mob/living/silicon/robot/proc/process_killswitch()
	if(killswitch)
		killswitch_time --
		if(killswitch_time <= 0)
			if(src.client)
				to_chat(src, "<span class='warning'><B>Killswitch Activated</span>")
			killswitch = 0
			spawn(5)
				gib()

/mob/living/silicon/robot/proc/process_locks()
	if(weapon_lock)
		uneq_all()
		weaponlock_time --
		if(weaponlock_time <= 0)
			if(src.client)
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
	if(paralysis || stunned || knockdown || locked_to || lockcharge)
		canmove = 0
	else
		canmove = 1
	return canmove
