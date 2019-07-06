/obj/item/weapon/thermometer
	name = "thermometer"
	desc = "A device that measures temperature using the expansion of mercury when exposed to heat."
	icon = 'icons/obj/items.dmi'
	icon_state = "therm_mercury"
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = W_CLASS_TINY
	starting_materials = list(MAT_GLASS = 500)
	w_type = RECYK_GLASS
	melt_temperature = MELTPOINT_GLASS
	origin_tech = Tc_BIOTECH + "=2"

	var/last_temperature
	var/last_temperature_string

/obj/item/weapon/thermometer/New()
	..()
	initial_thermometer()

/obj/item/weapon/thermometer/proc/initial_thermometer()
	create_reagents(5)
	reagents.add_reagent(MERCURY, 5)

/obj/item/weapon/thermometer/update_icon()
	if(last_temperature >= 373.15)
		icon_state = "therm_mercury_high"
	else if(last_temperature <= 273.15)
		icon_state = "therm_mercury_low"
	else
		icon_state = "therm_mercury"

/obj/item/weapon/thermometer/proc/crit_fail(mob/living/carbon/human/C, mob/user)
	user.visible_message("<span class = 'attack'>\The [user] smashes \the [src] over \the [C]'s head!</span>",\
			"<span class = 'warning'>You smash \the [src] over \the [C]'s head.</span>")
	splash_sub(reagents, C, -1, user)
	user.drop_item(src)
	playsound(src, "shatter", 70, 1)
	new /obj/item/weapon/broken_thermometer(get_turf(src))
	qdel(src)

/obj/item/weapon/thermometer/preattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return

	if(istype(target, /obj/machinery/bunsen_burner))
		var/obj/machinery/bunsen_burner/B = target
		if(B.held_container)
			target = B.held_container
	if(istype(target, /obj/machinery/chemheater))
		var/obj/machinery/chemheater/H = target
		if(H.held_container)
			target = H.held_container
	if(istype(target, /obj/machinery/chemcooler))
		var/obj/machinery/chemcooler/C = target
		if(C.held_container)
			target = C.held_container

	if(!target.reagents)
		return

	if(ismob(target))
		var/mob/living/carbon/human/C = target
		if(user.a_intent != I_HELP) //Fuck!
			crit_fail(C, user)
		else
			if(user.zone_sel.selecting == "mouth" && !C.check_body_part_coverage(MOUTH))
				visible_message("<span class = 'notice'>\The [user] starts taking \the [C]'s temperature using \the [src].</span>",\
				"<span class = 'notice'>You start taking the temperature of \the [user].</span>")
				if(do_after(user, src, 20))
					last_temperature_string = measure_human_temperature(C)
					update_icon()
					to_chat(user, "<span class = 'notice'>The temperature reads: [last_temperature_string]</span>")
		return 1

	to_chat(user, "<span class = 'notice'>You measure the temperature of \the [target] with \the [src].</span>")
	last_temperature_string = measure_obj_temperature(target)
	update_icon()
	to_chat(user, "<span class = 'notice'>The temperature reads: [last_temperature_string]</span>")

	return 1

/obj/item/weapon/thermometer/attack_self(mob/user)
	to_chat(user, "<span class = 'notice'>Last recorded temperature: [last_temperature_string]</span>")

/obj/item/weapon/thermometer/proc/measure_human_temperature(mob/living/carbon/human/C)
	last_temperature = C.bodytemperature
	return "[round(last_temperature-273.15,5)] C"

/obj/item/weapon/thermometer/proc/measure_obj_temperature(obj/target)
	last_temperature = target.reagents.chem_temp
	return "[round(last_temperature-273.15, 5)] C"

/obj/item/weapon/thermometer/electronic
	name = "electronic thermometer"
	desc = "An electronic thermal probe, boasting greater precision and less mercury than its analogue counterparts."
	icon_state = "therm_digi_1"
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_BIOTECH + "=3"

	starting_materials = list(MAT_IRON = 1000, MAT_GLASS = 400)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_GLASS

/obj/item/weapon/thermometer/electronic/initial_thermometer()
	return

/obj/item/weapon/thermometer/electronic/update_icon()
	return

/obj/item/weapon/thermometer/electronic/crit_fail()
	return

/obj/item/weapon/thermometer/electronic/measure_human_temperature(mob/living/carbon/human/C)
	last_temperature = C.bodytemperature
	return "[last_temperature-273.15] C"

/obj/item/weapon/thermometer/electronic/measure_obj_temperature(obj/target)
	last_temperature = target.reagents.chem_temp
	return "[last_temperature-273.15] C"


/obj/item/weapon/broken_thermometer
	name = "broken thermometer"
	desc = "Once used to measure temperature, now it just grows cold."
	icon = 'icons/obj/items.dmi'
	icon_state = "therm_mercury_broke"
	force = 9.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	sharpness = 0.8 //same as glass shards
	sharpness_flags = SHARP_TIP
	w_class = W_CLASS_TINY
	attack_verb = list("stabs", "slashes", "attacks")
	starting_materials = list(MAT_GLASS = 500)
	melt_temperature = MELTPOINT_GLASS
	w_type=RECYK_GLASS
	hitsound = 'sound/weapons/bladeslice.ogg'
	
/obj/item/weapon/thermometer/byond
	desc = "A device that measures temperature using the expansion of blood when exposed to heat. There's an imprint on the glass that says \"Made in BYOND\"."
	icon_state = "therm_byond"

/obj/item/weapon/thermometer/byond/initial_thermometer()
	create_reagents(5)
	reagents.add_reagent(BLOOD, 5)

/obj/item/weapon/thermometer/byond/update_icon()
	if(last_temperature >= 373.15)
		icon_state = "therm_byond_high"
	else if(last_temperature <= 273.15)
		icon_state = "therm_byond_low"
	else
		icon_state = "therm_byond"