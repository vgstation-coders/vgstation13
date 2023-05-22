/mob/living/silicon/robot/handle_regular_hud_updates()
	handle_sensor_modes()

	regular_hud_updates() //Handles MED/SEC HUDs for borgs.
	switch(sensor_mode)
		if(SEC_HUD)
			process_sec_hud(src, 1)
		if(MED_HUD)
			process_med_hud(src)

	handle_health_hud()

	if(cell)
		var/cellcharge = cell.charge/cell.maxcharge
		switch(cellcharge)
			if(0.5 to INFINITY)
				clear_alert(SCREEN_ALARM_ROBOT_CELL)
			if(0.25 to 0.5)
				throw_alert(SCREEN_ALARM_ROBOT_CELL, /obj/abstract/screen/alert/robot/cell/low, 2)
			if(0 to 0.25)
				throw_alert(SCREEN_ALARM_ROBOT_CELL, /obj/abstract/screen/alert/robot/cell/low, 1)
			else
				throw_alert(SCREEN_ALARM_ROBOT_CELL, /obj/abstract/screen/alert/robot/cell/empty, 0)
	else
		throw_alert(SCREEN_ALARM_ROBOT_CELL, /obj/abstract/screen/alert/robot/cell)

	if(album_icon)
		album_icon.icon_state = "album[connected_ai ? "1":""]"

	if(on_fire && !(module && locate(/obj/item/borg/fire_shield, module.modules)))
		throw_alert(SCREEN_ALARM_FIRE, /obj/abstract/screen/alert/robot/fire)
	else
		clear_alert(SCREEN_ALARM_FIRE)

	if(lockdown)
		throw_alert(SCREEN_ALARM_ROBOT_LOCK, /obj/abstract/screen/alert/robot/locked)
	else
		clear_alert(SCREEN_ALARM_ROBOT_LOCK)

	if(modulelock)
		throw_alert(SCREEN_ALARM_ROBOT_MODULELOCK, /obj/abstract/screen/alert/robot/modulelocked)
	else
		clear_alert(SCREEN_ALARM_ROBOT_MODULELOCK)


	if(emagged || illegal_weapons)
		throw_alert(SCREEN_ALARM_ROBOT_HACK, /obj/abstract/screen/alert/robot/hacked)
	else
		clear_alert(SCREEN_ALARM_ROBOT_HACK)

	update_pull_icon()

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
			if(!(machine.check_eye(src)))
				reset_view(null)
		else
			if(client && !client.adminobs && !iscamera(client.eye) && !isTeleViewing(client.eye))
				reset_view(null)

	return TRUE

// This handles the pressure sensor hud element. Values based on human values.
/mob/living/silicon/robot/proc/handle_pressure_damage(datum/gas_mixture/environment)
	//by the power of Polymorph and Errorage
	var/localpressure = environment.return_pressure()
	var/adjusted_pressure = localpressure - ONE_ATMOSPHERE //REAL pressure
	if(localpressure)
		if(adjusted_pressure >= HAZARD_HIGH_PRESSURE)
			throw_alert(SCREEN_ALARM_PRESSURE, /obj/abstract/screen/alert/robot/pressure/high, 2)
		else if(localpressure >= WARNING_HIGH_PRESSURE && localpressure < WARNING_HIGH_PRESSURE)
			throw_alert(SCREEN_ALARM_PRESSURE, /obj/abstract/screen/alert/robot/pressure/high, 1)
		else if(localpressure <= WARNING_LOW_PRESSURE && localpressure > HAZARD_LOW_PRESSURE)
			throw_alert(SCREEN_ALARM_PRESSURE, /obj/abstract/screen/alert/robot/pressure/low, -1)
		else if(localpressure <= HAZARD_LOW_PRESSURE)
			throw_alert(SCREEN_ALARM_PRESSURE, /obj/abstract/screen/alert/robot/pressure/low, -2)
		else
			clear_alert(SCREEN_ALARM_PRESSURE)
	else //there ain't no air, we're in a vacuum
		throw_alert(SCREEN_ALARM_PRESSURE, /obj/abstract/screen/alert/robot/pressure/low, -2)

// This handles the temp sensor hud element
/mob/living/silicon/robot/proc/handle_heat_damage(datum/gas_mixture/environment)
	var/envirotemp = environment.return_temperature()
	if(environment)
		if(envirotemp)
			if (envirotemp >= 1000 ) //1000 is the heat_level_3 for humans
				throw_alert(SCREEN_ALARM_TEMPERATURE, /obj/abstract/screen/alert/robot/temp/hot, 2)
			else if (envirotemp >= BODYTEMP_HEAT_DAMAGE_LIMIT && envirotemp < 1000 )
				throw_alert(SCREEN_ALARM_TEMPERATURE, /obj/abstract/screen/alert/robot/temp/hot, 1)
			else if (envirotemp <= T0C && envirotemp > BODYTEMP_COLD_DAMAGE_LIMIT)
				throw_alert(SCREEN_ALARM_TEMPERATURE, /obj/abstract/screen/alert/robot/temp/cold, -1)
			else if (envirotemp <= BODYTEMP_COLD_DAMAGE_LIMIT ) //space is cold
				throw_alert(SCREEN_ALARM_TEMPERATURE, /obj/abstract/screen/alert/robot/temp/cold, -2)
			else
				clear_alert(SCREEN_ALARM_TEMPERATURE)
				return FALSE
	else //vacuums are cold
		throw_alert(SCREEN_ALARM_TEMPERATURE, /obj/abstract/screen/alert/robot/temp/cold, -2)

/mob/living/silicon/robot/proc/handle_health_hud()
	if(healths)
		if(!isDead())
			var/current_health = health/maxHealth
			if(current_health in config.health_threshold_dead to 0)
				healths.icon_state = "health5"
			else
				switch(current_health)
					if(0.9 to 1)
						healths.icon_state = "health0"
					if(0.75 to 0.9)
						healths.icon_state = "health1"
					if(0.5 to 0.75)
						healths.icon_state = "health2"
					if(0.25 to 0.5)
						healths.icon_state = "health3"
					if(0 to 0.25)
						healths.icon_state = "health4"
					else
						healths.icon_state = "health6"
		else
			healths.icon_state = "health7"
