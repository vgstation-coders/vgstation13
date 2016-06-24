/mob/living/silicon/robot/mommi/Life()
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
	update_canmove()
	handle_beams()




/mob/living/silicon/robot/mommi/clamp_values()

//	SetStunned(min(stunned, 30))
	SetParalysis(min(paralysis, 30))
//	SetWeakened(min(weakened, 20))
	sleeping = 0
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)


/mob/living/silicon/robot/mommi/use_power()
	if(cell)
		if(cell.charge <= 0)
			uneq_all()
		else if (cell.charge <= MOMMI_LOW_POWER)
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
		stat = 1


/mob/living/silicon/robot/mommi/handle_regular_status_updates()

	if(camera && !scrambledcodes)
		if(stat == 2 || wires.IsCameraCut())
			camera.status = 0
		else
			camera.status = 1

	health = maxHealth - (getOxyLoss() + getFireLoss() + getBruteLoss())

	if(getOxyLoss() > 50) Paralyse(3)

	if(sleeping)
		Paralyse(3)
		sleeping--

	if(resting)
		Weaken(5)

	if(health <= 0 && stat != 2) //die only once
		gib()

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

	return 1
/
/mob/living/silicon/robot/mommi/handle_regular_hud_updates()
	handle_sensor_modes()

	switch(sensor_mode)
		if(SEC_HUD)
			process_sec_hud(src, 1)
		if(MED_HUD)
			process_med_hud(src)

	if (healths)
		if (stat != DEAD)
			switch(health)
				if(60 to INFINITY)
					healths.icon_state = "health0"
				if(40 to 60)
					healths.icon_state = "health1"
				if(30 to 40)
					healths.icon_state = "health2"
				if(10 to 20)
					healths.icon_state = "health3"
				if(0 to 10)
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

	if(!can_see_static()) //what lets us avoid the overlay
		if(static_overlays && static_overlays.len)
			remove_static_overlays()

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
			if(!client.adminobs && !isTeleViewing(client.eye))
				reset_view(null)

	return 1


// MoMMIs only have one hand.
/mob/living/silicon/robot/mommi/update_items()
	if (client)
		client.screen -= contents
		for(var/obj/I in contents)
			//if(I && !(istype(I,/obj/item/weapon/cell) || istype(I,/obj/item/device/radio)  || istype(I,/obj/machinery/camera) || istype(I,/obj/item/device/mmi)))
			if(I)
				// Make sure we're not showing any of our internal components, as that would be lewd.
				// This way of doing it ensures that shit we pick up will be visible, wheras shit inside of us isn't.
				if(I!=cell && I!=radio && I!=camera && I!=mmi)
					client.screen += I
	if(tool_state)
		tool_state:screen_loc = ui_inv2
	if(head_state)
		head_state:screen_loc = ui_monkey_mask

/mob/living/silicon/robot/mommi/update_canmove()
	canmove = !(paralysis || stunned || weakened || locked_to || lockcharge || anchored)
	return canmove

#undef MOMMI_LOW_POWER
