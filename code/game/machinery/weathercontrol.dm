/obj/machinery/weathercontrol
	name = "weather control device"
	desc = "A device which uses weather control techniques such as cloud seeding to manipulate atmospheric conditions. It runs on bluespace crystals."
	icon = 'icons/obj/stationobjs_32x64.dmi'
	icon_state = "wcd0"
	use_power = MACHINE_POWER_USE_IDLE
	density = 1
	anchored = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	req_access = list(access_rnd)
	idle_power_usage = 100
	var/error_message = null
	var/efficiency_modifier = 0 //Subtract from crystal costs
	var/crystal_reserve = 0 //Powered by bluespace crystals, this represents how much.

/obj/machinery/weathercontrol/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/weathercontrol,
		/obj/item/weapon/cell/rad,
		/obj/item/weapon/stock_parts/matter_bin/adv/super/bluespace,
		/obj/item/weapon/stock_parts/micro_laser/high/ultra,
		/obj/item/weapon/stock_parts/micro_laser/high/ultra)
	RefreshParts()

/obj/machinery/weathercontrol/Destroy()
	if(crystal_reserve >= 300)
		new /obj/item/bluespace_crystal/flawless(loc)
	else
		while(crystal_reserve >= 3)
			new /obj/item/bluespace_crystal(loc)
			crystal_reserve -= 3
		while(crystal_reserve > 0)
			new /obj/item/bluespace_crystal/artificial(loc)
			crystal_reserve--
	..()

/obj/machinery/weathercontrol/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/ML in component_parts)
		T += ML.rating
	efficiency_modifier = (T/2)-3
	//Both tier 3: 0; one tier 4: 0.5, both tier 4: 1

/obj/machinery/weathercontrol/update_icon()
	icon_state = "wcd[crystal_reserve > 0]"

/obj/machinery/weathercontrol/attack_hand(mob/user)
	return ui_interact(user)

/obj/machinery/weathercontrol/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if (gcDestroyed || !get_turf(src) || !anchored)
		if(!ui)
			ui = nanomanager.get_open_ui(user, src, ui_key)
		if(ui)
			ui.close()
		return

	var/data[0]
	data["error"] = error_message

	if(map.climate)
		var/datum/climate/C = map.climate
		var/datum/weather/CW = C.current_weather
		var/forecast_dat
		for(var/datum/weather/W in C.forecasts)
			forecast_dat += "[W.name] "
		data["name"] = name
		data["currentweather"] = CW
		data["remaining_time"] = formatTimeDuration(CW.timeleft)
		data["forecast"] = forecast_dat
		data["crystals"] = crystal_reserve
	else
		data["error"] = "Error: No climate detected."

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "weathercontrol.tmpl", "Weather Control Device", 380, 250)
		ui.set_initial_data(data)
		ui.open()

#define DISRUPT_COST 1
#define INTENSIFY_COST 1
#define ABATE_COST 2

#define SUCCESS 1
#define NOFIRE 2
#define NEED_CRYSTALS -3
#define POWER_ERROR -4
/obj/machinery/weathercontrol/Topic(href, href_list)
	if(..())
		return
	if(usr.incapacitated() || (!Adjacent(usr)&&!isAdminGhost(usr)) || !usr.dexterity_check() || !map.climate)
		return
	if(!allowed(usr) && !emagged)
		to_chat(usr,"<span class='warning'>Access denied.</span>")
		return
	if(stat & (FORCEDISABLE|NOPOWER))
		return
	var/datum/climate/C = map.climate
	var/datum/weather/CW = C.current_weather

	var/feedback = NOFIRE
	var/usedcost = 0

	if(stat & (FORCEDISABLE|NOPOWER))
		feedback = POWER_ERROR
	else
		if(href_list["disrupt"])
			feedback = SUCCESS
			usedcost = DISRUPT_COST
			if(!burn_crystals(DISRUPT_COST))
				feedback = NEED_CRYSTALS
			else
				if(C.current_weather.next_weather.len < 2)
					feedback = CANNOT_CHANGE
				else
					CW.timeleft = min(1 MINUTES, CW.timeleft)
					C.forecast()
		if(href_list["intensify"])
			feedback = SUCCESS
			usedcost = INTENSIFY_COST
			if(!burn_crystals(INTENSIFY_COST))
				feedback = NEED_CRYSTALS
			else
				feedback = C.weather_shift(INTENSIFY)
		if(href_list["abate"])
			feedback = SUCCESS
			usedcost = ABATE_COST
			if(!burn_crystals(ABATE_COST))
				feedback = NEED_CRYSTALS
			else
				feedback = C.weather_shift(ABATE)

	var/soundpath = 'sound/machines/warning-buzzer.ogg'
	switch(feedback)
		if(POWER_ERROR)
			error_message = "Error: Unpowered."
		if(NEED_CRYSTALS)
			error_message = "Error: Refraction index low. Load new bluespace crystals."
		if(CANNOT_CHANGE)
			error_message = "Error: Cannot change weather."
			refund(usedcost)
		if(INVALID_STEP)
			error_message = "Error: Machine malfunction."
			refund(usedcost)
		if(FALSE)
			error_message = "Error: Weather already present."
			refund(usedcost)
		if(SUCCESS)
			error_message = "Success: Atmoforming climate."
			soundpath = 'sound/machines/hiss.ogg'
			anim(target = src, a_icon = 'icons/effects/224x224.dmi', a_icon_state = "weathermachinefire", offX = -96, offY = -96)
		if(NOFIRE)
			return
	playsound(src, soundpath, vol = 50, vary = FALSE)
	nanomanager.update_uis(src)
	update_icon()
	spawn(4 SECONDS)
		error_message = null
	return 1

/obj/machinery/weathercontrol/proc/burn_crystals(var/cost)
	var/tcost = cost - efficiency_modifier
	if(tcost>crystal_reserve)
		return FALSE
	crystal_reserve = max(0, crystal_reserve - tcost)
	return TRUE

/obj/machinery/weathercontrol/proc/refund(var/num)
	var/tnum = num - efficiency_modifier
	crystal_reserve += tnum

/obj/machinery/weathercontrol/attackby(var/obj/item/I, var/mob/user)
	..()
	if(istype(I, /obj/item/bluespace_crystal))
		var/obj/item/bluespace_crystal/B = I
		if(user.drop_item(B, src))
			crystal_reserve += B.blueChargeValue
			B.playtoolsound(src, 50)
			to_chat(user, "<span class='notice'>You insert \the [B] into \the [src].")
			nanomanager.update_uis(src)
			qdel(B)
			update_icon()