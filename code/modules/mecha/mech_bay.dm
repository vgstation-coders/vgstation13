/obj/machinery/mech_bay_recharge_floor
	name = "Mech Bay Recharge Station"
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_floor"
	var/obj/machinery/mech_bay_recharge_port/recharge_port
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	var/obj/recharging_mecha = null
	var/capacitor_max = 0 //How much can be stored
	var/capacitor_stored = 0 //How much is presently stored
	layer = ABOVE_TILE_LAYER
	plane = ABOVE_TURF_PLANE
	anchored = 1
	density = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY

/obj/machinery/mech_bay_recharge_floor/New()
	..()
	component_parts = newlist(/obj/item/weapon/circuitboard/mech_bay_recharge_station,
								/obj/item/weapon/stock_parts/scanning_module,
								/obj/item/weapon/stock_parts/capacitor,
								/obj/item/weapon/stock_parts/capacitor)

	update_moody_light('icons/lighting/moody_lights.dmi', "overlay_recharge_floor")

/obj/machinery/mech_bay_recharge_floor/RefreshParts()
	var/capcount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/capacitor))
			capcount += SP.rating-1
	capacitor_max = initial(capacitor_max)+(capcount * 750)

/obj/machinery/mech_bay_recharge_floor/process()
	..()
	if(recharge_port&&recharging_mecha&&capacitor_stored)
		if(!recharge_console)
			recharge_port.stop_charge()
			return
		if(src in get_step(recharge_port, recharge_port.dir).contents)
			var/obj/item/weapon/cell/C = recharging_mecha.get_cell()
			C.give(capacitor_stored)
			capacitor_stored = 0
	else if(capacitor_stored<capacitor_max && recharge_port && !recharging_mecha)
		var/delta = min(recharge_port.pr_recharger.max_charge,capacitor_max-capacitor_stored)
		use_power(delta*150)
		capacitor_stored += delta

/obj/machinery/mech_bay_recharge_floor/Crossed(var/atom/A)
	. = ..()
	var/obj/O
	if(istype(A, /obj/mecha))
		O = A
	else if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.head && istype(H.head,/obj/item/clothing/head/helmet/stun))
			O = H.head
	if(!O)
		return

	to_mech(O,"<b>Initializing power control devices.</b>")

	if(recharge_console && recharge_port)
		if(src in get_step(recharge_port,recharge_port.dir).contents)//double check the port to make sure its still facing the station.
			recharging_mecha = O
			recharge_console.mecha_in(O)
			return
		else
			to_mech(O,"<span class='rose'>Power port orientation improper. Terminating.</span>")
	else if(!recharge_console)
		to_mech(O,"<span class='rose'>Control console not found. Terminating.</span>")
	else if(!recharge_port)
		to_mech(O,"<span class='rose'>Power port not found. Terminating.</span>")

/obj/machinery/mech_bay_recharge_floor/Uncrossed(atom)
	. = ..()
	if(atom == recharging_mecha)
		recharging_mecha = null
		if(recharge_console)
			recharge_console.mecha_out()
	else if(ishuman(atom))
		var/mob/living/carbon/human/C = atom
		if(C.head == recharging_mecha)
			recharging_mecha = null
			if(recharge_console)
				recharge_console.mecha_out()

/obj/machinery/mech_bay_recharge_floor/examine(mob/user)
	. = ..()
	if(recharge_port)
		var/direction = get_dir_as_string(recharge_port)
		to_chat(user,"<span class='notice'>Linked to \the [recharge_port] at the [uppertext(direction)].</span>")
	if(recharge_console)
		var/direction = get_dir_as_string(recharge_console)
		to_chat(user,"<span class='notice'>Linked to \the [recharge_console] at the [uppertext(direction)].</span>")

/obj/machinery/mech_bay_recharge_floor/proc/locate_and_link_port()
	if(recharge_port)//we already have a port
		return 0
	for(var/obj/machinery/mech_bay_recharge_port/potential_recharge_port in range(1,src))
		if(!potential_recharge_port.anchored)
			continue
		if(potential_recharge_port.recharge_floor) //it is already linked to another floor. do not link to it.
			continue
		potential_recharge_port.force_cardinal_dir()
		if(src in get_step(potential_recharge_port, potential_recharge_port.dir).contents) 	//check if dir of recharge port matches mechbay floor
			recharge_port = potential_recharge_port
			recharge_port.recharge_floor = src
			recharge_port.recharge_console = recharge_console
			recharge_console.recharge_port = recharge_port
			return 1
	return 0

/obj/machinery/mech_bay_recharge_floor/proc/delink_devices()
	if(recharge_port)
		recharge_port.recharge_floor = null
		recharge_port = null
	if(recharge_console)
		recharge_console.recharge_floor = null
		recharge_console = null

/obj/machinery/mech_bay_recharge_floor/Destroy()
	delink_devices()
	..()

/obj/machinery/mech_bay_recharge_port
	name = "Mech Bay Power Port"
	density = 1
	anchored = 1
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_port"
	verb_rotates = TRUE
	alt_click_rotates = TRUE
	var/obj/machinery/mech_bay_recharge_floor/recharge_floor
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	var/datum/global_iterator/mech_bay_recharger/pr_recharger

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | SHUTTLEWRENCH

/obj/machinery/mech_bay_recharge_port/New()
	..()

	component_parts = newlist(/obj/item/weapon/circuitboard/mech_bay_power_port,
								/obj/item/weapon/stock_parts/micro_laser,
								/obj/item/weapon/stock_parts/micro_laser,
								/obj/item/weapon/stock_parts/console_screen)

	pr_recharger = new /datum/global_iterator/mech_bay_recharger(null,0)

	RefreshParts()
	return

/obj/machinery/mech_bay_recharge_port/RefreshParts()
	var/lasercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating-1
	set_voltage(450+lasercount*100)

/obj/machinery/mech_bay_recharge_port/proc/start_charge(var/obj/recharging_mecha)
	if(stat&(NOPOWER|BROKEN|FORCEDISABLE))
		to_mech(recharging_mecha,"<span class='rose'>Power port not responding. Terminating.</span>")
		return 0
	else
		var/obj/item/weapon/cell/C = recharging_mecha.get_cell()
		if(C)
			to_mech(recharging_mecha,"Now charging...")
			pr_recharger.start(list(src, recharging_mecha))
			return 1
		else
			return 0

/obj/machinery/mech_bay_recharge_port/proc/stop_charge()
	if(recharge_console)
		recharge_console.charging = FALSE
		recharge_console.update_icon()
	pr_recharger.stop()
	return

/obj/machinery/mech_bay_recharge_port/proc/active()
	if(pr_recharger.active())
		return 1
	else
		return 0

/obj/machinery/mech_bay_recharge_port/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			pr_recharger.stop()
	return

/obj/machinery/mech_bay_recharge_port/proc/set_voltage(new_voltage)
	if(new_voltage && isnum(new_voltage))
		pr_recharger.max_charge = new_voltage
		return 1
	else
		return 0

/obj/machinery/mech_bay_recharge_port/update_icon()
	. = ..()
	icon_state = "[initial(icon_state)][anchored? "":"-unwrenched"]"

/obj/machinery/mech_bay_recharge_port/wrenchAnchor()
	. = ..()
	update_icon()
	if(!anchored)
		stop_charge()
		delink_devices()

/obj/machinery/mech_bay_recharge_port/examine(mob/user)
	. = ..()
	if(recharge_floor)
		var/direction = get_dir_as_string(recharge_floor)
		to_chat(user,"<span class='notice'>Linked to \the [recharge_floor] at the [uppertext(direction)].</span>")
	if(recharge_console)
		var/direction = get_dir_as_string(recharge_console)
		to_chat(user,"<span class='notice'>Linked to \the [recharge_console] at the [uppertext(direction)].</span>")

/obj/machinery/mech_bay_recharge_port/Destroy()
	delink_devices()
	..()

/obj/machinery/mech_bay_recharge_port/proc/delink_devices()
	if(recharge_floor)
		recharge_floor.recharge_port = null
		recharge_floor = null
	if(recharge_console)
		recharge_console.recharge_port = null
		recharge_console = null

/obj/machinery/mech_bay_recharge_port/proc/locate_and_link_station()
	if(recharge_floor) // we already have a station
		return 0
	force_cardinal_dir()
	for(var/obj/machinery/mech_bay_recharge_floor/potential_recharge_floor in get_step(src,dir))
		if(!potential_recharge_floor.anchored)
			continue
		if(potential_recharge_floor.recharge_port) //it is already linked
			continue
		recharge_floor = potential_recharge_floor
		recharge_floor.recharge_port = src
		recharge_floor.recharge_console = recharge_console
		recharge_console.recharge_floor = recharge_floor
		return 1
	return 0

/datum/global_iterator/mech_bay_recharger
	delay = 20
	var/max_charge = 450
	check_for_null = 0 //since port.stop_charge() must be called. The checks are made in process()

/datum/global_iterator/mech_bay_recharger/process(var/obj/machinery/mech_bay_recharge_port/port, var/obj/O)
	if(!port)
		return 0
	if(O && (port.recharge_floor in get_turf(O)))
		var/obj/item/weapon/cell/C = O.get_cell()
		if(!C)
			return
		var/delta = min(max_charge, C.maxcharge - C.charge)
		if(delta>0)
			C.give(delta)
			port.use_power(delta*150)
		else
			to_mech(O,"<span class='notice'><b>Fully charged.</b></span>")
			port.stop_charge()
	else
		port.stop_charge()


/proc/to_mech(var/obj/O, var/chat)
	if(istype(O, /obj/mecha))
		var/obj/mecha/M = O
		M.occupant_message(chat)
	else if(isliving(O.loc))
		to_chat(O.loc,chat)

/obj/machinery/computer/mech_bay_power_console
	name = "Mech Bay Power Control Console"
	density = 1
	anchored = 1
	icon = 'icons/obj/computer.dmi'
	icon_state = "recharge_comp"
	circuit = "/obj/item/weapon/circuitboard/mech_bay_power_console"
	var/autostart = 1
	var/voltage = 45
	var/obj/machinery/mech_bay_recharge_floor/recharge_floor
	var/obj/machinery/mech_bay_recharge_port/recharge_port

	light_color = LIGHT_COLOR_PINK

	var/charging = FALSE

/obj/machinery/computer/mech_bay_power_console/proc/mecha_in(var/obj/O)
	if(stat&(FORCEDISABLE|NOPOWER|BROKEN))
		to_mech(O,"<span class='rose'>Control console not responding. Terminating...</span>")
		return
	if(recharge_port && autostart)
		charging = recharge_port.start_charge(O)
		update_icon()

/obj/machinery/computer/mech_bay_power_console/proc/mecha_out()
	if(recharge_port)
		recharge_port.stop_charge()

/obj/machinery/computer/mech_bay_power_console/power_change()
	..()
	if(stat & (BROKEN|NOPOWER))
		if(recharge_port)
			recharge_port.stop_charge()

/obj/machinery/computer/mech_bay_power_console/update_icon()
	..()
	if(!(stat & (FORCEDISABLE|BROKEN|NOPOWER)))
		if(charging)
			icon_state = "recharge_comp-charging"

/obj/machinery/computer/mech_bay_power_console/set_broken()
	. = ..()
	if(.)
		if(recharge_port)
			recharge_port.stop_charge()

/obj/machinery/computer/mech_bay_power_console/attack_hand(mob/user as mob)
	if(..())
		return
	if(!stat && Adjacent(user) || istype(user, /mob/living/silicon))
		return interact(user)

/obj/machinery/computer/mech_bay_power_console/interact(mob/user as mob)
	user.set_machine(src)
	var/output = "<html><head><title>[src.name]</title></head><body>"
	if(!recharge_floor)
		output += "<span class='rose'>Mech Bay Recharge Station not initialized.</span><br>"
	else
		output += {"<b>Mech Bay Recharge Station Data:</b><div style='margin-left: 15px;'>
						<b>Mecha: </b>[recharge_floor.recharging_mecha||"None"]<br>"}
		if(recharge_floor.recharging_mecha)
			var/obj/item/weapon/cell/C = recharge_floor.recharging_mecha.get_cell()
			output += "<b>Cell charge: </b>[isnull(C)?"No powercell found":"[C.charge]/[C.maxcharge]"]<br>"
		output += "</div>"
	if(!recharge_port)
		output += "<span class='rose'>Mech Bay Power Port not initialized.</span><br>"
	else if(!recharge_floor || !(recharge_floor in get_step(recharge_port,recharge_port.dir)))
		output += "<span class='rose'>Mech Bay Power Port misaligned. Realign manually then perform Device Link protocol.</span><br>"
	else
		output += "<b>Mech Bay Power Port Status: </b>[recharge_port.active()?"Now charging":"On hold"]<br>"

	if(!recharge_floor || !recharge_port)
		output += "</ul><A href='?src=\ref[src];device_linkage=1'>Link Devices to Console</A>"
	if(recharge_floor || recharge_port)
		output += "</ul><A href='?src=\ref[src];delink_devices=1'>Delink Devices</A>"
	output += "</ body></html>"
	user << browse(output, "window=mech_bay_console")
	onclose(user, "mech_bay_console")

/obj/machinery/computer/mech_bay_power_console/Topic(href,href_list)
	..()
	if ((!Adjacent(usr) && !istype(usr,/mob/living/silicon/) )|| usr.incapacitated())
		usr << browse(null, "window=mech_bay_console")
		return
	if(href_list["device_linkage"])
		if(recharge_floor && recharge_port)
			say("Device Linkage failed. This console is already linked to a Port and Station. Unlink it before reinitiating linkage protocol.")
			updateUsrDialog()
			return
		//we've previously linked to a port or floor, but they're missing a valid candidate. lets run a check to see if one is present.
		if(recharge_floor && !recharge_port) //we seem to have a floor, but no port.
			if(recharge_floor.recharge_port) //our floor has a port but we don't. we'll take theirs
				recharge_port = recharge_floor.recharge_port
				recharge_port.recharge_console = src
				say("Station and Port successfully linked.")
				updateUsrDialog()
				return
			if (recharge_floor.locate_and_link_port()) //the target will search for a port
				say("Station and Port successfully linked.")
				updateUsrDialog()
				return
			say("Valid Port not found.")
			updateUsrDialog()
			return
		if(recharge_port && !recharge_floor)//we seem to have a port, but no floor.
			if(recharge_port.recharge_floor)//our port has a floor but we don't. we'll take theirs
				recharge_floor = recharge_port.recharge_floor
				recharge_floor.recharge_console = src
			if(recharge_port.locate_and_link_station())
				say("Port and Station succesfully linked.")
				updateUsrDialog()
				return
			say("Valid Station not found.")
			updateUsrDialog()
			return
		//we have no port or station linked, therefore choose a direction and begin device linkage.
		var/inputdir
		switch(input(usr, "Which direction are you linking to?","Mech-Console Linkage Menu","SOUTH") in list("NORTH","EAST","SOUTH","WEST"))
			if("NORTH")
				inputdir =NORTH
			if("SOUTH")
				inputdir =SOUTH
			if("EAST")
				inputdir =EAST
			if("WEST")
				inputdir =WEST
		device_linkage(inputdir)
		updateUsrDialog()
		return
	if(href_list["delink_devices"]) //not working some reaseon
		master_delink_devices()
		updateUsrDialog()

/obj/machinery/computer/mech_bay_power_console/proc/device_linkage(var/direction)
	//targetting station
	for(var/obj/machinery/mech_bay_recharge_floor/rc_floor in get_step(src,direction).contents)
		if(!rc_floor.recharge_console)  //only link to it if it is not currently linked to some other console
			recharge_floor = rc_floor
			recharge_floor.recharge_console = src
			if(recharge_floor.recharge_port)//it's already linked to a port.
				recharge_port = recharge_floor.recharge_port
				recharge_port.recharge_console = src
				say("Port and Station successfully linked to Console.")
				return 1
			if(recharge_floor.locate_and_link_port()) //have the station try to find a valid port and link to it
				say("Station and Port successfully linked to Console.")
				return 1
			say("Station found, but valid port candidate not found. Please make adjustments and reinitiate linkage protocol.")
			return 0
	//targetting port
	for(var/obj/machinery/mech_bay_recharge_port/rc_port in get_step(src,direction).contents)
		if(!rc_port.recharge_console && rc_port.anchored) //same as above. don't link if its already linked to something or unwrenched
			recharge_port = rc_port
			recharge_port.recharge_console = src
			if(recharge_port.recharge_floor)//it's already linked to a floor.
				recharge_floor = recharge_port.recharge_floor
				recharge_floor.recharge_console = src
				say("Port and Station successfully linked to Console.")
				return 1
			if(recharge_port.locate_and_link_station())//have the port try to find a valid station and link to it
				say("Port and Station successfully linked to Console.")
				return 1
			say("Port found, but valid station candidate not found. Please make adjustments and reinitiate linkage protocol.")
			return 0
	say("No valid candidates found in that direction.")
	return 0

/obj/machinery/computer/mech_bay_power_console/examine(mob/user)
	. = ..()
	if(recharge_floor)
		var/direction = get_dir_as_string(recharge_floor)
		to_chat(user,"<span class='notice'>Linked to \the [recharge_floor] at the [uppertext(direction)].</span>")
	if(recharge_port)
		var/direction = get_dir_as_string(recharge_port)
		to_chat(user,"<span class='notice'>Linked to \the [recharge_port] at the [uppertext(direction)].</span>")


/obj/machinery/computer/mech_bay_power_console/wrenchAnchor()
	. = ..()
	if(!anchored)
		if(recharge_floor)
			recharge_floor.recharge_console = null
			recharge_floor = null
		if(recharge_port)
			recharge_port.stop_charge()
			recharge_port.recharge_console = null
			recharge_port = null

/obj/machinery/computer/mech_bay_power_console/proc/master_delink_devices()
	if(recharge_floor)
		recharge_floor.delink_devices()
	if(recharge_port)
		recharge_port.delink_devices()

/obj/machinery/computer/mech_bay_power_console/Destroy()
	master_delink_devices()
	..()

//for mappers. these subclasses will attempt to automatically link to recharge stations on spawn in that direction.
/obj/machinery/computer/mech_bay_power_console/autolink_north/New()
	. = ..()
	device_linkage(NORTH)

/obj/machinery/computer/mech_bay_power_console/autolink_south/New()
	. = ..()
	device_linkage(SOUTH)

/obj/machinery/computer/mech_bay_power_console/autolink_east/New()
	. = ..()
	device_linkage(EAST)

/obj/machinery/computer/mech_bay_power_console/autolink_west/New()
	. = ..()
	device_linkage(WEST)
