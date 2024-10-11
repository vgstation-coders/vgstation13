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
	slimeadd_message = "You add the slime extract to the fuel port"
	slimes_accepted = SLIME_RED
	slimeadd_success_message = "It feels full now"
	ghost_read = 0
	is_cooktop = TRUE

/////////////////////Cooking stuff

/obj/machinery/bunsen_burner/can_cook()
	return (heating == BUNSEN_ON)

/obj/machinery/bunsen_burner/on_cook_start()
	update_icon()

/obj/machinery/bunsen_burner/on_cook_stop()
	update_icon()

/obj/machinery/bunsen_burner/render_cookvessel(offset_x = 2, offset_y = 12)
	..()
	if(cookvessel || held_container)
		adjust_particles(PVAR_POSITION, list(offset_x,offset_y))
	else
		adjust_particles(PVAR_POSITION, 0)

/obj/machinery/bunsen_burner/cook_temperature()
	var/temperature = get_max_temperature()
	if(isnull(temperature))
		return ..() //Sanity in case the burner runs out of fuel before this is called.
	return temperature

/obj/machinery/bunsen_burner/cook_energy()
	var/cook_energy = get_thermal_transfer() * (SS_WAIT_FAST_OBJECTS / SS_WAIT_MACHINERY)
	if(isnull(cook_energy))
		return ..() //Sanity in case the burner runs out of fuel before this is called.
	return cook_energy

/////////////////////

/obj/machinery/bunsen_burner/slime_act(primarytype, mob/user)
	. = ..()
	if(primarytype == SLIME_RED && .)
		reagents.clear_reagents()
		reagents.add_reagent(GLYCEROL, 250)

/obj/machinery/bunsen_burner/splashable()
	return FALSE

/obj/machinery/bunsen_burner/table_shift()
	pixel_y = 6

/obj/machinery/bunsen_burner/table_unshift()
	pixel_y = 0

/obj/machinery/bunsen_burner/New()
	..()
	processing_objects.Remove(src)
	create_reagents(250)

	if(ticker)
		initialize()

/obj/machinery/bunsen_burner/mapping/New()
	..()
	reagents.add_reagent(GLYCEROL, 250)

/obj/machinery/bunsen_burner/Destroy()
	if(held_container)
		adjust_particles(PVAR_POSITION, 0)
		held_container.forceMove(get_turf(src))
		held_container = null
	processing_objects.Remove(src)
	set_light(0)
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
		to_chat(user, "<span class='info'>It is holding \a [held_container]:</span>")
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
			if(W.is_cookvessel)
				add_fingerprint(user)
				//if it is a cooking vessel, we do want to call afterattack() so that it gets added properly
			else if(!held_container && user.drop_item(W, src))
				W.adjust_particles(PVAR_POSITION, list(2,12))
				W.link_particles(src)
				to_chat(user, "<span class='notice'>You put [W] onto \the [src].</span>")
				add_fingerprint(user)
				load_item(W)
				return 1 //otherwise avoid afterattack() being called
	if(W.is_wrench(user))
		user.visible_message("<span class = 'warning'>[user] starts to deconstruct \the [src]!</span>","<span class = 'notice'>You start to deconstruct \the [src].</span>")
		if(do_after(user, src, 5 SECONDS))
			W.playtoolsound(src, 50)
			drop_stack(sheet_type, loc, rand(3,4), user)
			qdel(src)
	else
		..()

/obj/machinery/bunsen_burner/proc/load_item(obj/item/weapon/W)
	held_container = W
	update_icon()

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

		if(reagents.is_empty())
			try_refill_nearby()

		for(var/possible_fuel in possible_fuels)
			if(reagents.has_reagent(possible_fuel) || (possible_fuel == GLYCEROL && (has_slimes & SLIME_RED)))
				var/list/fuel_stats = possible_fuels[possible_fuel]
				max_temperature = fuel_stats["max_temperature"]
				thermal_energy_transfer = fuel_stats["thermal_energy_transfer"]
				consumption_rate = fuel_stats["consumption_rate"]
				unsafety = has_slimes & SLIME_RED ? fuel_stats["unsafety"] : 0
				o2_consumption = has_slimes & SLIME_RED ? fuel_stats["o2_cons"] : 0
				co2_consumption = has_slimes & SLIME_RED ? fuel_stats["co2_cons"] : 0

				if(!(possible_fuel == GLYCEROL && (has_slimes & SLIME_RED)) && reagents.has_reagent(possible_fuel))
					reagents.remove_reagent(possible_fuel, consumption_rate)
				if(held_container)
					if(!cookvessel) //Cooking vessels are heated differently.
						held_container.reagents.heating(thermal_energy_transfer, max_temperature)
					update_icon()
				G.adjust_multi(
					GAS_OXYGEN, -o2_consumption,
					GAS_CARBON, -co2_consumption)
				if(prob(unsafety) && T)
					try_hotspot_expose(max_temperature, SMALL_FLAME,0)
				break

		if(!max_temperature)
			visible_message("<span class = 'warning'>\The [src] splutters out from lack of fuel.</span>","<span class = 'warning'>You hear something cough.</span>")
			toggle()

	if(!heating || heating == BUNSEN_OPEN)
		processing_objects.Remove(src)
		set_light(0)

/obj/machinery/bunsen_burner/proc/get_max_temperature()
	var/max_temperature
	for(var/possible_fuel in possible_fuels)
		if(reagents.has_reagent(possible_fuel))
			var/list/fuel_stats = possible_fuels[possible_fuel]
			max_temperature = fuel_stats["max_temperature"]
			break
	return max_temperature

/obj/machinery/bunsen_burner/proc/get_thermal_transfer()
	var/thermal_transfer
	for(var/possible_fuel in possible_fuels)
		if(reagents.has_reagent(possible_fuel))
			var/list/fuel_stats = possible_fuels[possible_fuel]
			thermal_transfer = fuel_stats["thermal_transfer"]
			break
	return thermal_transfer

/obj/machinery/bunsen_burner/proc/try_refill_nearby()
	for(var/obj/machinery/chem_dispenser/CD in view(1))
		if(CD.energy > 0.5)
			reagents.add_reagent(ETHANOL, 5)
			CD.energy -= 0.5
			return //Got a machine that's not empty? Exit.
	for(var/obj/structure/reagent_dispensers/fueltank/FT in view(1))
		if(FT.reagents.trans_id_to(src, FUEL, 5))
			return //Got something from the dispenser? Exit.


/obj/machinery/bunsen_burner/update_icon()
	icon_state = "bunsen[heating]"
	overlays.Cut()
	if(held_container)
		var/image/I = image("icon"=held_container, "layer"=FLOAT_LAYER, "pixel_x" = 2 * PIXEL_MULTIPLIER, "pixel_y" = 22 * PIXEL_MULTIPLIER - empty_Y_space(new /icon(held_container.icon, held_container.icon_state)))
		var/image/I2 = image("icon"=src.icon, icon_state ="bunsen_prong", "layer"=FLOAT_LAYER)
		overlays += I
		overlays += I2
	render_cookvessel()

/obj/machinery/bunsen_burner/attack_ghost()
	return

/obj/machinery/bunsen_burner/attack_hand(mob/user)
	if(cookvessel)
		..()
	else if(held_container)
		to_chat(user, "<span class='notice'>You remove \the [held_container] from \the [src].</span>")
		adjust_particles(PVAR_POSITION, 0)
		remove_particles()
		held_container.forceMove(src.loc)
		held_container.attack_hand(user)
		held_container = null
		add_fingerprint(user)
		update_icon()
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
	set_light(heating)
	if(heating == BUNSEN_ON)
		processing_objects.Add(src)
	else
		processing_objects.Remove(src)


/obj/machinery/bunsen_burner/AltClick(mob/user)
	if((!user.Adjacent(src) || user.incapacitated()) && !isAdminGhost(user))
		return ..()

	var/list/choices = list(
		list("Turn On/Off", (heating == BUNSEN_ON ? "radial_off" : "radial_on")),
		list("Toggle Fuelport", (heating == BUNSEN_OPEN ? "radial_lock" : "radial_unlock")),
		list("Examine", "radial_examine")
	)

	var/task = show_radial_menu(usr,loc,choices,custom_check = new /callback(src, nameof(src::radial_check()), user))
	if(!radial_check(user))
		return

	switch(task)
		if("Turn On/Off")
			verb_toggle()
		if("Toggle Fuelport")
			verb_toggle_fuelport()
		if("Examine")
			user.examination(src)

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


/obj/machinery/bunsen_burner/mapped/New()
	..()
	desc = "[initial(desc)] Perfect for keeping your coffee hot."
	var/obj/item/weapon/reagent_containers/food/drinks/mug/coffeemug = new /obj/item/weapon/reagent_containers/food/drinks/mug
	coffeemug.reagents.add_reagent(COFFEE, 30)
	load_item(coffeemug)


#undef BUNSEN_OPEN
#undef BUNSEN_OFF
#undef BUNSEN_ON
