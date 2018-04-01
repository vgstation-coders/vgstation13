/obj/machinery/chem_heater
	name = "chemical heater"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_heater
	var/obj/item/reagent_containers/beaker = null
	var/target_temperature = 300
	var/heater_coefficient = 0.1
	var/on = FALSE

/obj/machinery/chem_heater/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_heater/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null
		update_icon()

/obj/machinery/chem_heater/update_icon()
	if(beaker)
		icon_state = "mixer1b"
	else
		icon_state = "mixer0b"

/obj/machinery/chem_heater/proc/eject_beaker(mob/user)
	if(beaker)
		beaker.forceMove(drop_location())
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(beaker)
		beaker = null
		update_icon()

/obj/machinery/chem_heater/RefreshParts()
	heater_coefficient = 0.1
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		heater_coefficient *= M.rating

/obj/machinery/chem_heater/process()
	..()
	if(stat & NOPOWER)
		return
	if(on)
		if(beaker)
			if(beaker.reagents.chem_temp > target_temperature)
				beaker.reagents.chem_temp += min(-1, (target_temperature - beaker.reagents.chem_temp) * heater_coefficient)
			if(beaker.reagents.chem_temp < target_temperature)
				beaker.reagents.chem_temp += max(1, (target_temperature - beaker.reagents.chem_temp) * heater_coefficient)

			beaker.reagents.chem_temp = round(beaker.reagents.chem_temp)
			beaker.reagents.handle_reactions()

/obj/machinery/chem_heater/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mixer0b", "mixer0b", I))
		return

	if(exchange_parts(user, I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(istype(I, /obj/item/reagent_containers) && !(I.flags_1 & ABSTRACT_1) && I.is_open_container())
		. = 1 //no afterattack
		if(beaker)
			to_chat(user, "<span class='warning'>A container is already loaded into [src]!</span>")
			return

		if(!user.transferItemToLoc(I, src))
			return
		beaker = I
		to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
		update_icon()
		return
	return ..()

/obj/machinery/chem_heater/on_deconstruction()
	eject_beaker()
	return ..()

/obj/machinery/chem_heater/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chem_heater", name, 275, 400, master_ui, state)
		ui.open()

/obj/machinery/chem_heater/ui_data()
	var/data = list()
	data["targetTemp"] = target_temperature
	data["isActive"] = on
	data["isBeakerLoaded"] = beaker ? 1 : 0

	data["currentTemp"] = beaker ? beaker.reagents.chem_temp : null
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null

	var beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents
	return data

/obj/machinery/chem_heater/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			. = TRUE
		if("temperature")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("New target temperature:", name, target_temperature) as num|null
				if(!isnull(target) && !..())
					. = TRUE
			else if(adjust)
				target = target_temperature + adjust
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = CLAMP(target, 0, 1000)
		if("eject")
			on = FALSE
			eject_beaker(usr)
			. = TRUE
