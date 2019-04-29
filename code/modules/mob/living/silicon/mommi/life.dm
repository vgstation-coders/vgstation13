/mob/living/silicon/robot/mommi/Life()
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
		update_action_buttons_icon()
		update_items()
	if (src.stat != DEAD) //still using power
		use_power()
		process_killswitch()
		process_locks()
	update_canmove()
	handle_beams()
	if(locked_to_z)
		check_locked_zlevel()
	var/datum/gas_mixture/environment = src.loc.return_air()
	handle_pressure_damage(environment)
	handle_heat_damage(environment)




/mob/living/silicon/robot/mommi/clamp_values()

//	SetStunned(min(stunned, 30))
	SetParalysis(min(paralysis, 30))
//	SetKnockdown(min(knockdown, 20))
	sleeping = 0
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)


/mob/living/silicon/robot/mommi/use_power()
	if(cell)
		if(cell.charge <= 0)
			uneq_all()
		else if (src.cell.charge <= MOMMI_LOW_POWER)
			uneq_all()
			cell.use(1)
		else
			if(sensor_mode)
				cell.use(5)
			if(tool_state)
				cell.use(5)
			cell.use(1)
			blinded = 0
			stat = 0
	else
		uneq_all()
		src.stat = 1


/mob/living/silicon/robot/mommi/handle_regular_status_updates()

	if(src.camera && !scrambledcodes)
		if(src.stat == 2 || wires.IsCameraCut())
			src.camera.status = 0
		else
			src.camera.status = 1

	health = maxHealth - (getOxyLoss() + getFireLoss() + getBruteLoss())

	if(getOxyLoss() > 50)
		Paralyse(3)

	if(src.sleeping)
		Paralyse(3)
		src.sleeping--

	if(src.resting)
		Knockdown(5)

	if(health <= 0 && src.stat != 2) //die only once
		gib()

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
	if (say_mute > 0)
		say_mute--
	if (src.ear_damage < 25)
		src.ear_damage -= 0.05
		src.ear_damage = max(src.ear_damage, 0)

	src.setDensity(!(src.lying))

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

	handle_dizziness()
	handle_jitteriness()

	return 1

/mob/living/silicon/robot/mommi/handle_regular_hud_updates()
	handle_sensor_modes()

	switch(sensor_mode)
		if(SEC_HUD)
			process_sec_hud(src, 1)
		if(MED_HUD)
			process_med_hud(src)

	if (src.healths)
		if (src.stat != DEAD)
			switch(health)
				if(60 to INFINITY)
					src.healths.icon_state = "health0"
				if(40 to 60)
					src.healths.icon_state = "health1"
				if(30 to 40)
					src.healths.icon_state = "health2"
				if(10 to 20)
					src.healths.icon_state = "health3"
				if(0 to 10)
					src.healths.icon_state = "health4"
				if(config.health_threshold_dead to 0)
					src.healths.icon_state = "health5"
				else
					src.healths.icon_state = "health6"
		else
			src.healths.icon_state = "health7"

	if(!can_see_static()) //what lets us avoid the overlay
		if(static_overlays && static_overlays.len)
			remove_static_overlays()

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

	if(bodytemp) //actually environment temperature but fuck it
		bodytemp.icon_state = "temp[temp_alert]"
	if(pressure)
		pressure.icon_state = "pressure[pressure_alert]"


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
			if(!client.adminobs && !isTeleViewing(client.eye))
				reset_view(null)

	return 1


// MoMMIs only have one hand.
/mob/living/silicon/robot/mommi/update_items()
	if (src.client)
		src.client.screen -= src.contents
		for(var/obj/I in src.contents)
			//if(I && !(istype(I,/obj/item/weapon/cell) || istype(I,/obj/item/device/radio)  || istype(I,/obj/machinery/camera) || istype(I,/obj/item/device/mmi)))
			if(I)
				// Make sure we're not showing any of our internal components, as that would be lewd.
				// This way of doing it ensures that shit we pick up will be visible, wheras shit inside of us isn't.
				if(I!=src.cell && I!=src.radio && I!=src.camera && I!=src.mmi)
					src.client.screen += I
	if(src.tool_state)
		src.tool_state:screen_loc = ui_inv2
	if(src.head_state)
		src.head_state:screen_loc = ui_monkey_mask

/mob/living/silicon/robot/mommi/update_canmove()
	canmove = !(paralysis || stunned || knockdown || locked_to || lockcharge || anchored)
	return canmove

/mob/living/silicon/robot/mommi/proc/check_locked_zlevel()
	if(!locked_to_z)
		return

	var/datum/zLevel/current_zlevel = get_z_level(src)
	if(!current_zlevel)
		return
	if(current_zlevel.z != locked_to_z)
		to_chat(src, "<span class='userdanger'>Your hardware detects that you have left your intended location. Initiating self-destruct.</span>")
		locked_to_z = 0
		spawn(rand(2,7) SECONDS)
			if(mmi) //no sneaking brains away
				qdel(mmi)
				mmi = null
			gib()


/mob/living/silicon/robot/mommi/handle_pressure_damage(datum/gas_mixture/environment)
	..()

/mob/living/silicon/robot/mommi/handle_heat_damage(datum/gas_mixture/environment)
	..()

#undef MOMMI_LOW_POWER
