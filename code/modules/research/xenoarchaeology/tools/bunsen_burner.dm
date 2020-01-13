#define BUNSEN_ON 1
#define BUNSEN_OFF 0
#define BUNSEN_OPEN -1
/obj/machinery/bunsen_burner
	name = "bunsen burner"
	desc = "A fuel-consuming device designed for bringing chemical mixtures to boil."
	icon = 'icons/obj/device.dmi'
	icon_state = "bunsen0"
	pass_flags = PASSTABLE
	var/heating = BUNSEN_OFF //whether the bunsen is turned on
	var/obj/item/weapon/reagent_containers/held_container
	var/list/possible_fuels = list(
		PLASMA = list(
				"max_temperature" = TEMPERATURE_PLASMA,
				"thermal_energy_transfer" = 9000,
				"consumption_rate" = 0.1,
				"o2_cons" = 0.01,
				"co2_cons" = 0,
				"unsafety" = 0),
		GLYCEROL = list(
				"max_temperature" = 1833.15,
				"thermal_energy_transfer" = 6000,
				"consumption_rate" = 0.25,
				"o2_cons" = 0.05,
				"co2_cons" = -0.025,
				"unsafety" = 5),
		FUEL = list(
				"max_temperature" = TEMPERATURE_WELDER,
				"thermal_energy_transfer" = 5400,
				"consumption_rate" = 0.5,
				"o2_cons" = 0.2,
				"co2_cons" = -0.2,
				"unsafety" = 25),
		ETHANOL = list(
				"max_temperature" = 1833.15,
				"thermal_energy_transfer" = 3900,
				"consumption_rate" = 0.5,
				"o2_cons" = 0.08,
				"co2_cons" = -0.04,
				"unsafety" = 10))
	ghost_read = 0

/obj/machinery/bunsen_burner/New()
	..()
	processing_objects.Remove(src)
	create_reagents(250)

/obj/machinery/bunsen_burner/Destroy()
	if(held_container)
		held_container.forceMove(get_turf(src))
		held_container = null
	processing_objects.Remove(src)
	..()

/obj/machinery/bunsen_burner/examine(mob/user)
	..()
	switch(heating)
		if(BUNSEN_ON)
			to_chat(user, "<span class = 'notice'>\The [src] is on.</span>")
		if(BUNSEN_OPEN)
			to_chat(user, "<span class = 'notice'>\The [src]'s fuel port is open.</span>")
	reagents.get_examine(user)
	if(held_container)
		to_chat(user, "<span class='info'>It is holding a:</span>")
		held_container.examine(user)

/obj/machinery/bunsen_burner/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/R = W
		if(heating == BUNSEN_OPEN && R.is_open_container())
			for(var/possible_fuel in possible_fuels)
				if(R.reagents.has_reagent(possible_fuel) && (reagents.has_reagent(possible_fuel) || !reagents.reagent_list.len))
					var/reagent_transfer = R.reagents.trans_id_to(src, possible_fuel, 10)
					if(reagent_transfer)
						to_chat(user, "<span class='notice'>You transfer [reagent_transfer]u of [possible_fuel] from \the [R] to \the [src]</span>")
						add_fingerprint(user)
						return
		else
			if(!held_container && user.drop_item(W, src))
				to_chat(user, "<span class='notice'>You put \the [held_container] onto \the [src].</span>")
				add_fingerprint(user)
				load_item(W)
				return 1 // avoid afterattack() being called
	if(W.is_wrench(user))
		user.visible_message("<span class = 'warning'>[user] starts to deconstruct \the [src]!</span>","<span class = 'notice'>You start to deconstruct \the [src].</span>")
		if(do_after(user, src, 5 SECONDS))
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			drop_stack(sheet_type, loc, rand(3,4), user)
			qdel(src)
	else
		..()

/obj/machinery/bunsen_burner/proc/load_item(obj/item/weapon/W)
	held_container = W
	var/image/I = image("icon"=W, "layer"=FLOAT_LAYER, "pixel_x" = 2 * PIXEL_MULTIPLIER, "pixel_y" = 22 * PIXEL_MULTIPLIER - empty_Y_space(new /icon(W.icon, W.icon_state)))
	var/image/I2 = image("icon"=src.icon, icon_state ="bunsen_prong", "layer"=FLOAT_LAYER)
	overlays += I
	overlays += I2

/obj/machinery/bunsen_burner/process()
	if(heating == BUNSEN_ON)
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/G = T.return_air()
		if(!G || G.molar_density(GAS_OXYGEN) < 0.1 / CELL_VOLUME)
			visible_message("<span class = 'warning'>\The [src] splutters out from lack of oxygen.</span>","<span class = 'warning'>You hear something cough.</span>")
			toggle()
			return

		var/max_temperature
		var/thermal_energy_transfer
		var/consumption_rate
		var/unsafety = 0 //Possibility it lights things on its turf
		var/o2_consumption
		var/co2_consumption

		for(var/possible_fuel in possible_fuels)
			if(reagents.has_reagent(possible_fuel))
				var/list/fuel_stats = possible_fuels[possible_fuel]
				max_temperature = fuel_stats["max_temperature"]
				thermal_energy_transfer = fuel_stats["thermal_energy_transfer"]
				consumption_rate = fuel_stats["consumption_rate"]
				unsafety = fuel_stats["unsafety"]
				o2_consumption = fuel_stats["o2_cons"]
				co2_consumption = fuel_stats["co2_cons"]

				reagents.remove_reagent(possible_fuel, consumption_rate)
				if(held_container)
					held_container.reagents.heating(thermal_energy_transfer, max_temperature)
				G.adjust_multi(
					GAS_OXYGEN, -o2_consumption,
					GAS_CARBON, -co2_consumption)
				if(prob(unsafety) && T)
					T.hotspot_expose(max_temperature, 5)
				break

		if(!max_temperature)
			visible_message("<span class = 'warning'>\The [src] splutters out from lack of fuel.</span>","<span class = 'warning'>You hear something cough.</span>")
			toggle()

	if(!heating || heating == BUNSEN_OPEN)
		processing_objects.Remove(src)

/obj/machinery/bunsen_burner/update_icon()
	icon_state = "bunsen[heating]"

/obj/machinery/bunsen_burner/attack_ghost()
	return

/obj/machinery/bunsen_burner/attack_hand(mob/user)
	if(held_container)
		overlays = null
		to_chat(user, "<span class='notice'>You remove \the [held_container] from \the [src].</span>")
		held_container.forceMove(src.loc)
		held_container.attack_hand(user)
		held_container = null
		add_fingerprint(user)
	else
		toggle()

/obj/machinery/bunsen_burner/verb/verb_toggle()
	set src in view(1)
	set name = "Toggle bunsen burner"
	set category = "Object"

	if ((!usr.Adjacent(src) || usr.incapacitated()) && !isAdminGhost(usr))
		return

	toggle()

/obj/machinery/bunsen_burner/proc/toggle()
	if(heating == BUNSEN_OPEN)
		if(usr)
			to_chat(usr, "<span class = 'warning'>Close the fuel port first!</span>")
		return
	heating = !heating
	update_icon()
	if(heating == BUNSEN_ON)
		processing_objects.Add(src)
	else
		processing_objects.Remove(src)


/obj/machinery/bunsen_burner/AltClick()
	if((!usr.Adjacent(src) || usr.incapacitated()) && !isAdminGhost(usr))
		return ..()

	var/list/choices = list(
		list("Turn On/Off", (heating == BUNSEN_ON ? "radial_off" : "radial_on")),
		list("Toggle Fuelport", (heating == BUNSEN_OPEN ? "radial_lock" : "radial_unlock")),
		list("Examine", "radial_examine")
	)
	var/event/menu_event = new(owner = usr)
	menu_event.Add(src, "radial_check_handler")

	var/task = show_radial_menu(usr,loc,choices,custom_check = menu_event)
	if(!radial_check(usr))
		return

	switch(task)
		if("Turn On/Off")
			verb_toggle()
		if("Toggle Fuelport")
			verb_toggle_fuelport()
		if("Examine")
			usr.examination(src)

/obj/machinery/bunsen_burner/proc/radial_check_handler(list/arguments)
	var/event/E = arguments["event"]
	return radial_check(E.holder)

/obj/machinery/bunsen_burner/proc/radial_check(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/machinery/bunsen_burner/verb/verb_toggle_fuelport()
	set src in view(1)
	set name = "Toggle Bunsen burner fuelport"
	set category = "Object"

	if((!usr.Adjacent(src) || usr.incapacitated()) && !isAdminGhost(usr))
		return

	toggle_fuelport(usr)

/obj/machinery/bunsen_burner/proc/toggle_fuelport(mob/user)
	switch(heating)
		if(BUNSEN_ON)
			to_chat(user, "<span class = 'warning'>Turn \the [src] off first!</span>")
			return
		if(BUNSEN_OFF)
			heating = BUNSEN_OPEN
			to_chat(user, "<span class = 'warning'>You open the fuel port on \the [src].</span>")
		if(BUNSEN_OPEN)
			heating = BUNSEN_OFF
			to_chat(user, "<span class = 'warning'>You close the fuel port on \the [src].</span>")


/obj/machinery/bunsen_burner/mapped //for the sci break room


obj/machinery/bunsen_burner/mapped/New()
	..()
	desc = "[initial(desc)] Perfect for keeping your coffee hot."
	var/obj/item/weapon/reagent_containers/food/drinks/mug/coffeemug = new /obj/item/weapon/reagent_containers/food/drinks/mug
	coffeemug.reagents.add_reagent(COFFEE, 30)
	load_item(coffeemug)


#undef BUNSEN_OPEN
#undef BUNSEN_OFF
#undef BUNSEN_ON
