//the core [tokamaka generator] big funky solenoid, it generates an EM field

/*
when the core is turned on, it generates [creates] an electromagnetic field
the em field attracts plasma, and suspends it in a controlled torus (doughnut) shape, oscillating around the core

the field strength is directly controllable by the user
field strength = sqrt(energy used by the field generator)

the size of the EM field = field strength / k
(k is an arbitrary constant to make the calculated size into tilewidths)

1 tilewidth = below 5T
3 tilewidth = between 5T and 12T
5 tilewidth = between 10T and 25T
7 tilewidth = between 20T and 50T
(can't go higher than 40T)

energy is added by a gyrotron, and lost when plasma escapes
energy transferred from the gyrotron beams is reduced by how different the frequencies are (closer frequencies = more energy transferred)

frequency = field strength * (stored energy / stored moles of plasma) * x
(where x is an arbitrary constant to make the frequency something realistic)
the gyrotron beams' frequency and energy are hardcapped low enough that they won't heat the plasma much

energy is generated in considerable amounts by fusion reactions from injected particles
fusion reactions only occur when the existing energy is above a certain level, and it's near the max operating level of the gyrotron. higher energy reactions only occur at higher energy levels
a small amount of energy constantly bleeds off in the form of radiation

the field is constantly pulling in plasma from the surrounding [local] atmosphere
at random intervals, the field releases a random percentage of stored plasma in addition to a percentage of energy as intense radiation

the amount of plasma is a percentage of the field strength, increased by frequency
*/

/*
- VALUES -

max volume of plasma storeable by the field = the total volume of a number of tiles equal to the (field tilewidth)^2

*/

/obj/machinery/power/rust_core
	name = "R-UST Mk 7 Tokamak core"
	desc = "An enormous solenoid for generating extremely high power electromagnetic fields."
	icon = 'icons/obj/machines/rust.dmi'
	icon_state = "core0"
	density = 1
	light_power_on = 2
	light_range_on = 3
	light_color = LIGHT_COLOR_BLUE

	var/obj/effect/rust_em_field/owned_field
	var/field_strength = MIN_FIELD_STR
	var/targeted_field_strength = MIN_FIELD_STR
	var/field_frequency = MIN_FIELD_FREQ
	var/attempt_activate = FALSE
	var/powered = 0
	var/last_power_request = 0
	var/last_power_received = 0

	use_power = MACHINE_POWER_USE_NONE
	power_priority = POWER_PRIORITY_POWER_EQUIPMENT
	monitoring_enabled = TRUE
	idle_power_usage = 50
	active_power_usage = MIN_FIELD_FREQ * RUST_CORE_STR_COST	//multiplied by field strength
	anchored = 0
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | WELD_FIXED | MULTITOOL_MENU

/obj/machinery/power/rust_core/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/rust_core,
		/obj/item/weapon/stock_parts/manipulator/nano/pico,
		/obj/item/weapon/stock_parts/manipulator/nano/pico,
		/obj/item/weapon/stock_parts/micro_laser/high/ultra,
		/obj/item/weapon/stock_parts/subspace/crystal,
		/obj/item/weapon/stock_parts/console_screen
	)

	if(ticker)
		initialize()

/obj/machinery/power/rust_core/Destroy()
	qdel(owned_field)
	..()

/obj/machinery/power/rust_core/initialize()
	if(!id_tag)
		assign_uid()
		id_tag = uid

/obj/machinery/power/rust_core/process()
	if(stat & BROKEN || state != 2 || (!powernet && active_power_usage))
		powered = 0
		Shutdown()
		return
	var/cur_satisfaction = get_satisfaction()
	var/power_received = last_power_request * cur_satisfaction
	add_load((attempt_activate || owned_field) ? active_power_usage : idle_power_usage)
	powered = power_received >= idle_power_usage
	if(!powered)
		Shutdown()
	else if(owned_field && power_received < MIN_FIELD_STR * RUST_CORE_STR_COST)
		Shutdown()
	else if(attempt_activate)
		if(owned_field)
			set_strength(round(power_received / RUST_CORE_STR_COST))
		else if(power_received >= MIN_FIELD_STR * RUST_CORE_STR_COST)
			set_strength(round(power_received / RUST_CORE_STR_COST))
			activate_field()
	last_power_request = (attempt_activate || owned_field) ? active_power_usage : idle_power_usage
	last_power_received = power_received

/obj/machinery/power/rust_core/weldToFloor(var/obj/item/tool/weldingtool/WT, mob/user)
	if(owned_field)
		to_chat(user, "<span class='warning'>Turn \the [src] off first!</span>")
		return -1

	if(..() == 1)
		switch(state)
			if(1)
				disconnect_from_network()
			if(2)
				connect_to_network()
		return 1
	return -1
/* //was this ever needed? The core lacks a direct interface
/obj/machinery/power/rust_core/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["str"])
		var/dif = text2num(href_list["str"])
		field_strength = min(max(field_strength + dif, MIN_FIELD_STR), MAX_FIELD_STR)
		active_power_usage = RUST_CORE_STR_COST * field_strength	//change to 500 later
		if(owned_field)
			owned_field.ChangeFieldStrength(field_strength)

	if(href_list["freq"])
		var/dif = text2num(href_list["freq"])
		field_frequency = min(max(field_frequency + dif, MIN_FIELD_FREQ), MAX_FIELD_FREQ)
		if(owned_field)
			owned_field.ChangeFieldFrequency(field_frequency)
*/
/obj/machinery/power/rust_core/proc/Startup()
	if(owned_field)
		return
	attempt_activate = TRUE
	. = 1

/obj/machinery/power/rust_core/proc/activate_field()
	if(owned_field)
		return
	owned_field = new(loc, src)
	owned_field.ChangeFieldStrength(field_strength)
	owned_field.ChangeFieldFrequency(field_frequency)
	set_light(light_range_on, light_power_on)
	icon_state = "core1"
	. = 1

/obj/machinery/power/rust_core/proc/Shutdown()
	attempt_activate = FALSE
	if(owned_field)
		icon_state = "core0"
		qdel(owned_field)
		set_light(0)

/obj/machinery/power/rust_core/proc/AddParticles(var/name, var/quantity = 1)
	if(owned_field)
		owned_field.AddParticles(name, quantity)
		. = 1

/obj/machinery/power/rust_core/bullet_act(var/obj/item/projectile/Proj)
	if(owned_field)
		. = owned_field.bullet_act(Proj)

/obj/machinery/power/rust_core/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
		<ul>
			<li>[format_tag("ID Tag","id_tag")]</li>
		</ul>
	"}

/obj/machinery/power/rust_core/proc/set_targeted_strength(var/value)
	value = clamp(value, MIN_FIELD_STR, MAX_FIELD_STR)
	targeted_field_strength = value
	active_power_usage = RUST_CORE_STR_COST * value

/obj/machinery/power/rust_core/proc/set_strength(var/value)
	value = clamp(value, MIN_FIELD_STR, MAX_FIELD_STR)
	field_strength = value
	if(owned_field)
		owned_field.ChangeFieldStrength(value)

/obj/machinery/power/rust_core/proc/set_frequency(var/value)
	value = clamp(value, MIN_FIELD_FREQ, MAX_FIELD_FREQ)
	field_frequency = value
	if(owned_field)
		owned_field.ChangeFieldFrequency(value)
