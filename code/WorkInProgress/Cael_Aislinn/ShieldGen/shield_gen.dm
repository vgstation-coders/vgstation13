#define MIN_FIELD_RADIUS 1
#define MAX_FIELD_RADIUS 100

#define MIN_STRENGTHEN_RATE 0
#define MAX_STRENGTHEN_RATE 3

#define MIN_FIELD_STRENGTH_CAP 0
#define MAX_FIELD_STRENGTH_CAP 1000

//renwicks: fictional unit to describe shield strength
//a small meteor hit will deduct 1 renwick of strength from that shield tile
//light explosion range will do 1 renwick's damage
//medium explosion range will do 2 renwick's damage
//heavy explosion range will do 3 renwick's damage
//explosion damage is cumulative. if a tile is in range of light, medium and heavy damage, it will take a hit from all three

/obj/machinery/shield_gen
	name = "\improper Starscreen shield generator"
	desc = "Generates a box-shaped wall of energy when active."
	icon = 'code/WorkInProgress/Cael_Aislinn/ShieldGen/shielding.dmi'
	icon_state = "generator_regular_off"
	req_one_access = list(access_security, access_engine) // For locking/unlocking controls
	density = 1
	anchored = TRUE
	use_power = 1			//0 use nothing
							//1 use idle power
							//2 use active power
	idle_power_usage = 20
	active_power_usage = 100
	machine_flags = EMAGGABLE | SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	var/active = FALSE
	var/field_radius = 3
	var/list/field = list()
	var/locked = FALSE
	var/average_field_strength = 0
	var/strengthen_rate = 0.2
	var/max_strengthen_rate = 1
	var/obj/machinery/shield_capacitor/owned_capacitor
	var/field_strength_cap = 100
	var/time_since_fail = 100
	var/energy_conversion_rate = 0.01	//how many renwicks per watt?
	var/board_path = /obj/item/weapon/circuitboard/shield_gen // overridden by subtype
	var/icon_prefix = "regular" // used in update_icon and animations

/obj/machinery/shield_gen/New()
	spawn(10)
		find_capacitor()
	..()

	component_parts = newlist(
		board_path,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/subspace/transmitter,
		/obj/item/weapon/stock_parts/subspace/crystal,
		/obj/item/weapon/stock_parts/subspace/amplifier,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/shield_gen/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/Ma in component_parts)
		T += Ma.rating - 1
		energy_conversion_rate = (initial(energy_conversion_rate)+(T * 0.01))
		max_strengthen_rate = (initial(max_strengthen_rate)+(T))

/obj/machinery/shield_gen/Destroy()
	..()
	owned_capacitor = null
	destroy_field()

/obj/machinery/shield_gen/proc/find_capacitor()
	for(var/obj/machinery/shield_capacitor/possible_capacitor in range(1, src))
		if(get_dir(possible_capacitor, src) == possible_capacitor.dir)
			owned_capacitor = possible_capacitor
			break

/obj/machinery/shield_gen/proc/toggle_lock(var/mob/user)
	locked = !locked
	if(user)
		to_chat(user, "\The [src]'s controls are now [locked ? "locked" : "unlocked"].")
	nanomanager.update_uis(src)

/obj/machinery/shield_gen/emag(var/mob/user)
	if(prob(75))
		toggle_lock(user)
		spark(src, 5)
		return 1
	else
		if(user)
			to_chat(user, "You fail to hack \the [src]'s controls.")
	playsound(src, 'sound/effects/sparks4.ogg', 75, 1)

/obj/machinery/shield_gen/wrenchAnchor(var/mob/user)
	. = ..()
	if(!.)
		return
	if(anchored)
		find_capacitor()
	else if(owned_capacitor)
		owned_capacitor = null
	nanomanager.update_uis(src)

/obj/machinery/shield_gen/attackby(var/obj/item/W, var/mob/user)
	if(..())
		return 1
	else if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(check_access(W))
			toggle_lock(user)
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/shield_gen/attack_hand(var/mob/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/machinery/shield_gen/ui_interact(var/mob/user, var/ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	var/data[0]
	data["locked"] = locked && !issilicon(user) && !isAdminGhost(user)
	data["capacitor"] = !!owned_capacitor
	data["active"] = active
	data["stability"] = time_since_fail > 2
	data["field_radius"] = field_radius
	data["average_field_strength"] = average_field_strength
	data["field_strength_cap"] = field_strength_cap
	data["percentage_strength"] = field_strength_cap ? 100 * average_field_strength / field_strength_cap : "NA"
	data["strengthen_rate"] = strengthen_rate
	data["upkeep_energy"] = field.len * average_field_strength / energy_conversion_rate
	data["additional_energy_required"] = field.len * strengthen_rate / energy_conversion_rate

	data["min_field_radius"] = MIN_FIELD_RADIUS
	data["max_field_radius"] = MAX_FIELD_RADIUS
	data["min_strengthen_rate"] = MIN_STRENGTHEN_RATE
	data["max_strengthen_rate"] = MAX_STRENGTHEN_RATE
	data["min_field_strength_cap"] = MIN_FIELD_STRENGTH_CAP
	data["max_field_strength_cap"] = MAX_FIELD_STRENGTH_CAP

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "shield_gen.tmpl", name, 500, 450)
		ui.set_initial_data(data)
		ui.set_auto_update(TRUE)
		ui.open()

/obj/machinery/shield_gen/process()
	if(active && field.len)
		var/stored_renwicks = 0
		var/target_field_strength = min(strengthen_rate + max(average_field_strength, 0), field_strength_cap)
		if(owned_capacitor)
			var/required_energy = field.len * target_field_strength / energy_conversion_rate
			var/assumed_charge = min(owned_capacitor.stored_charge, required_energy)
			stored_renwicks = assumed_charge * energy_conversion_rate
			owned_capacitor.stored_charge -= assumed_charge

		time_since_fail++

		average_field_strength = 0
		target_field_strength = stored_renwicks / field.len

		for(var/obj/effect/energy_field/E in field)
			if(stored_renwicks)
				var/strength_change = target_field_strength - E.strength
				if(strength_change > stored_renwicks)
					strength_change = stored_renwicks
				if(E.strength < 0)
					E.strength = 0
				else
					E.Strengthen(strength_change)

				stored_renwicks -= strength_change

				average_field_strength += E.strength
			else
				E.Strengthen(-E.strength)

		average_field_strength /= field.len
		if(average_field_strength < 0)
			time_since_fail = 0
	else
		average_field_strength = 0

/obj/machinery/shield_gen/Topic(href, href_list[])
	if(..())
		return 0
	if(href_list["toggle_active"])
		toggle()
	else if(href_list["adjust_field_radius"])
		field_radius = Clamp(field_radius + text2num(href_list["adjust_field_radius"]), MIN_FIELD_RADIUS, MAX_FIELD_RADIUS)
	else if(href_list["adjust_strengthen_rate"])
		strengthen_rate = Clamp(strengthen_rate + text2num(href_list["adjust_strengthen_rate"]), MIN_STRENGTHEN_RATE, MAX_STRENGTHEN_RATE)
	else if(href_list["adjust_field_strength_cap"])
		field_strength_cap = Clamp(field_strength_cap + text2num(href_list["adjust_field_strength_cap"]), MIN_FIELD_STRENGTH_CAP, MAX_FIELD_STRENGTH_CAP)
	return 1

/obj/machinery/shield_gen/update_icon()
	icon_state = "generator_[icon_prefix]_[active ? "on" : "off"]"

/obj/machinery/shield_gen/power_change()
	. = ..()
	update_icon()

/obj/machinery/shield_gen/ex_act(var/severity)
	stop()
	if (prob(severity))
		field_radius = rand(MIN_FIELD_RADIUS, MAX_FIELD_RADIUS)
	if (prob(severity))
		strengthen_rate = rand(MIN_STRENGTHEN_RATE, MAX_STRENGTHEN_RATE)
	if (prob(severity))
		field_strength_cap = rand(MIN_FIELD_STRENGTH_CAP, MAX_FIELD_STRENGTH_CAP)
	return ..()

/obj/machinery/shield_gen/proc/start()
	if(active)
		return

	flick("generator_[icon_prefix]_start", src)

	var/list/covered_turfs = get_shielded_turfs()
	var/turf/T = get_turf(src)
	if(T in covered_turfs)
		covered_turfs.Remove(T)
	for(var/turf/O in covered_turfs)
		var/obj/effect/energy_field/E = new(O)
		field.Add(E)
	del covered_turfs
	visible_message("<span class='notice'>\The [src] starts up, emitting a heavy droning noise.</span>", "<span class='notice'>You hear heavy droning start up.</span>")
	active = TRUE

/obj/machinery/shield_gen/proc/destroy_field()
	for(var/obj/effect/energy_field/D in field)
		field.Remove(D)
		qdel(D)
		D = null

/obj/machinery/shield_gen/proc/stop()
	if(!active)
		return

	flick("generator_[icon_prefix]_stop", src)

	destroy_field()
	visible_message("<span class='notice'>\The [src] shuts down, the droning noise fading out.</span>", "<span class='notice'>You hear heavy droning fade out.</span>")
	active = FALSE

/obj/machinery/shield_gen/proc/toggle()
	active ? stop() : start()
	power_change()

//grab the border tiles in a circle around this machine
/obj/machinery/shield_gen/proc/get_shielded_turfs()
	var/list/out = list()
	for(var/turf/T in trange(field_radius, src))
		if(get_dist(src,T) == field_radius)
			out.Add(T)
	return out

/obj/machinery/shield_gen/kick_act()
	..()
	if(stat & (NOPOWER|BROKEN))
		active = FALSE
		return
	if(prob(50))
		active = !active

/obj/machinery/shield_gen/npc_tamper_act(var/mob/living/L)
	field_radius = rand(MIN_FIELD_RADIUS, MAX_FIELD_RADIUS)
	strengthen_rate = rand(MIN_STRENGTHEN_RATE, MAX_STRENGTHEN_RATE)
	field_strength_cap = rand(MIN_FIELD_STRENGTH_CAP, MAX_FIELD_STRENGTH_CAP)
	if(prob(50))
		toggle()

#undef MIN_FIELD_RADIUS
#undef MAX_FIELD_RADIUS

#undef MIN_STRENGTHEN_RATE
#undef MAX_STRENGTHEN_RATE

#undef MIN_FIELD_STRENGTH_CAP
#undef MAX_FIELD_STRENGTH_CAP
