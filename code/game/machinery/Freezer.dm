#define FREEZER_MIN_TEMPERATURE T0C - 200
#define FREEZER_MAX_TEMPERATURE T20C

/obj/machinery/atmospherics/unary/cold_sink/freezer
	name = "freezer"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "freezer_0"
	density = 1
	default_colour = "#0000b7"
	anchored = 1.0
	var/temp_offset = 0

	current_heat_capacity = 1000

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/list/rotate_verbs=list(
		/obj/machinery/atmospherics/unary/cold_sink/freezer/verb/rotate,
		/obj/machinery/atmospherics/unary/cold_sink/freezer/verb/rotate_ccw,
	)

/obj/machinery/atmospherics/unary/cold_sink/freezer/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/freezer,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

	if(anchored)
		verbs -= rotate_verbs

	initialize_directions = dir

/obj/machinery/atmospherics/unary/cold_sink/freezer/RefreshParts()
	var/lasercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating-1
	temp_offset = initial(temp_offset) - 5*lasercount

/obj/machinery/atmospherics/unary/cold_sink/freezer/update_icon()
	if(node1)
		if(on)
			icon_state = "freezer_1"
		else
			icon_state = "freezer"
	else
		icon_state = "freezer_0"
	..()

/obj/machinery/atmospherics/unary/cold_sink/freezer/crowbarDestroy(mob/user)
	if(on)
		to_chat(user, "You have to turn off \the [src]!")
		return
	return ..()

/obj/machinery/atmospherics/unary/cold_sink/freezer/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(on)
		to_chat(user, "You have to turn off \the [src]!")
		return
	return ..()

/obj/machinery/atmospherics/unary/cold_sink/freezer/wrenchAnchor(var/mob/user)
	if(on)
		to_chat(user, "You have to turn off \the [src] first!")
		return FALSE
	. = ..()
	if(!.)
		return
	if(anchored)
		verbs -= rotate_verbs
		initialize_directions = dir
		initialize()
		build_network()
		if (node1)
			node1.initialize()
			node1.build_network()
	else
		verbs += rotate_verbs
		if(node1)
			node1.disconnect(src)
			node1 = null
		if(network)
			qdel(network)
			network = null
		

/obj/machinery/atmospherics/unary/cold_sink/freezer/attack_hand(mob/user as mob)
	user.set_machine(src)
	var/temp_text = ""
	if(air_contents.temperature > (T0C - 20))
		temp_text = "<FONT color=red>[air_contents.temperature]</FONT>"
	else if(air_contents.temperature < (T0C - 20) && air_contents.temperature > (T0C - 100))
		temp_text = "<FONT color=black>[air_contents.temperature]</FONT>"
	else
		temp_text = "<FONT color=blue>[air_contents.temperature]</FONT>"

	var/dat = {"<B>Cryo gas cooling system</B><BR>
	Current status: [ on ? "<A href='?src=\ref[src];start=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];start=1'>On</A>"]<BR>
	Current gas temperature: [temp_text]<BR>
	Current air pressure: [air_contents.return_pressure()]<BR>
	Target gas temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
	"}

	user << browse(dat, "window=freezer;size=400x500")
	onclose(user, "freezer")

/obj/machinery/atmospherics/unary/cold_sink/freezer/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)
		if (href_list["start"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"turned [on?"off":"on"]"))
				return
			src.on = !src.on
			update_icon()
		if(href_list["temp"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"set temperature of"))
				return
			var/amount = text2num(href_list["temp"])
			if(amount > 0)
				src.current_temperature = min(FREEZER_MAX_TEMPERATURE, src.current_temperature+amount)
			else
				src.current_temperature = max((FREEZER_MIN_TEMPERATURE + temp_offset), src.current_temperature+amount)
	src.updateUsrDialog()
	src.add_fingerprint(usr)
	return

/obj/machinery/atmospherics/unary/cold_sink/freezer/process()
	..()
	src.updateUsrDialog()


/obj/machinery/atmospherics/unary/cold_sink/freezer/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, 270)
	return 1

/obj/machinery/atmospherics/unary/cold_sink/freezer/verb/rotate_ccw()
	set name = "Rotate Counter Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, 90)
	return 1

/obj/machinery/atmospherics/unary/cold_sink/freezer/exposed()
	return TRUE

/obj/machinery/atmospherics/unary/cold_sink/freezer/npc_tamper_act(mob/living/L)
	current_temperature = rand(FREEZER_MIN_TEMPERATURE + temp_offset, FREEZER_MAX_TEMPERATURE)
	src.on = rand(0,1)
	update_icon()

#undef FREEZER_MIN_TEMPERATURE
#undef FREEZER_MAX_TEMPERATURE

#define HEATER_MIN_TEMPERATURE T20C
#define HEATER_MAX_TEMPERATURE T20C + 280

/obj/machinery/atmospherics/unary/heat_reservoir/heater
	name = "heater"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "freezer_0"
	density = 1
	anchored = 1.0
	default_colour = "#b70000"
	current_heat_capacity = 1000
	var/temp_offset = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/list/rotate_verbs=list(
		/obj/machinery/atmospherics/unary/heat_reservoir/heater/verb/rotate,
		/obj/machinery/atmospherics/unary/heat_reservoir/heater/verb/rotate_ccw,
	)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/heater,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

	if(anchored)
		verbs -= rotate_verbs

	initialize_directions = dir

/obj/machinery/atmospherics/unary/heat_reservoir/heater/RefreshParts()
	var/lasercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating-1
	temp_offset = initial(temp_offset) + 5*lasercount

/obj/machinery/atmospherics/unary/heat_reservoir/heater/update_icon()
	if(node1)
		if(on)
			icon_state = "heater_1"
		else
			icon_state = "heater"
	else
		icon_state = "heater_0"
	..()
	return

/obj/machinery/atmospherics/unary/heat_reservoir/heater/crowbarDestroy(mob/user)
	if(on)
		to_chat(user, "You have to turn off \the [src]!")
		return
	return ..()

/obj/machinery/atmospherics/unary/heat_reservoir/heater/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(on)
		to_chat(user, "You have to turn off \the [src]!")
		return
	return ..()

/obj/machinery/atmospherics/unary/heat_reservoir/heater/wrenchAnchor(var/mob/user)
	if(on)
		to_chat(user, "You have to turn off \the [src] first!")
		return FALSE
	. = ..()
	if(!.)
		return
	if(anchored)
		verbs -= rotate_verbs
		initialize_directions = dir
		initialize()
		build_network()
		if (node1)
			node1.initialize()
			node1.build_network()
	else
		verbs += rotate_verbs
		if(node1)
			node1.disconnect(src)
			node1 = null
		if(network)
			qdel(network)
			network = null
		

/obj/machinery/atmospherics/unary/heat_reservoir/heater/attack_hand(mob/user as mob)
	user.set_machine(src)
	var/temp_text = ""
	if(air_contents.temperature > (T20C+40))
		temp_text = "<FONT color=red>[air_contents.temperature]</FONT>"
	else
		temp_text = "<FONT color=black>[air_contents.temperature]</FONT>"

	var/dat = {"<B>Heating system</B><BR>
	Current status: [ on ? "<A href='?src=\ref[src];start=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];start=1'>On</A>"]<BR>
	Current gas temperature: [temp_text]<BR>
	Current air pressure: [air_contents.return_pressure()]<BR>
	Target gas temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
	"}

	user << browse(dat, "window=heater;size=400x500")
	onclose(user, "heater")

/obj/machinery/atmospherics/unary/heat_reservoir/heater/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)
		if (href_list["start"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"turned [on?"off":"on"]"))
				return
			src.on = !src.on
			update_icon()
		if(href_list["temp"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"set temperature of"))
				return
			var/amount = text2num(href_list["temp"])
			if(amount > 0)
				src.current_temperature = min((HEATER_MAX_TEMPERATURE+temp_offset), src.current_temperature+amount)
			else
				src.current_temperature = max(HEATER_MIN_TEMPERATURE, src.current_temperature+amount)
	src.updateUsrDialog()
	src.add_fingerprint(usr)
	return

/obj/machinery/atmospherics/unary/heat_reservoir/heater/process()
	..()
	src.updateUsrDialog()


/obj/machinery/atmospherics/unary/heat_reservoir/heater/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, 270)
	return 1

/obj/machinery/atmospherics/unary/heat_reservoir/heater/verb/rotate_ccw()
	set name = "Rotate Counter Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, 90)
	return 1

/obj/machinery/atmospherics/unary/heat_reservoir/heater/exposed()
	return TRUE

/obj/machinery/atmospherics/unary/heat_reservoir/heater/npc_tamper_act(mob/living/L)
	current_temperature = rand(HEATER_MIN_TEMPERATURE, HEATER_MAX_TEMPERATURE+temp_offset)
	src.on = rand(0,1)
	update_icon()

#undef HEATER_MAX_TEMPERATURE
#undef HEATER_MIN_TEMPERATURE
