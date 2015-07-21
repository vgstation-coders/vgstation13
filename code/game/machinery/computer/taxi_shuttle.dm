////////////////////
// TAXI SHUTTLES  //
////////////////////

var/global/list/taxi_computers = list()

/obj/machinery/computer/taxi_shuttle
	name = "taxi shuttle terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list(access_taxi)

	var/datum/shuttle/taxi/shuttle //The shuttle this computer is connected to

	var/id_tag = ""
	var/letter = ""
	var/list/connected_buttons = list()

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/taxi_shuttle/New()
	..()
	taxi_computers += src

/obj/machinery/computer/taxi_shuttle/Destroy()
	taxi_computers -= src
	connected_buttons = list()
	..()


/obj/machinery/computer/taxi_shuttle/update_icon()
	..()
	icon_state = "syndishuttle"

/obj/machinery/computer/taxi_shuttle/proc/taxi_move_to(var/obj/structure/docking_port/destination/destination, var/wait_time)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/computer/taxi_shuttle/proc/taxi_move_to() called tick#: [world.time]")
	if(shuttle.moving)
		return
	if(!shuttle.can_move())
		return
	broadcast("[capitalize(shuttle.name)] will move in [wait_time / 10] second\s.")

	sleep(wait_time)

	shuttle.move_to_dock(destination)

	if(shuttle.destination_port)
		return 1

/obj/machinery/computer/taxi_shuttle/proc/broadcast(var/message = "")
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/computer/taxi_shuttle/proc/broadcast() called tick#: [world.time]")
	if(message)
		src.visible_message("\icon [src]" + message)
	else
		return
	for(var/obj/machinery/door_control/taxi/TB in connected_buttons)
		TB.visible_message("\icon [TB]" + message)

/obj/machinery/computer/taxi_shuttle/attackby(obj/item/I as obj, mob/user as mob)
	if(..())
		return 1
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle/attack_hand(mob/user as mob)

	user.set_machine(src)

	var/dat = ""
	if(allowed(user))
		dat = {"[shuttle.current_port ? "Location: [shuttle.current_port.areaname]" : "Location: UNKNOWN"]<br>
		Ready to move[shuttle.can_move() ? ": now" : " in [max(round((shuttle.last_moved + shuttle.cooldown - world.time) * 0.1), 0)] seconds"]<br><br>
		<a href='?src=\ref[src];med_sili=1'>Medical and Silicon Station</a><br>
		<a href='?src=\ref[src];engi_cargo=1'>Engineering and Cargo Station</a><br>
		<a href='?src=\ref[src];sec_sci=1'>Security and Science Station</a><br>
		[emagged ? "<a href='?src=\ref[src];abandoned=1'>Abandoned Station</a><br>" : ""]"}
	else
		dat = {"[shuttle.current_port ? "Location: [shuttle.current_port.areaname]" : "Location: UNKNOWN"]<br>
		Ready to move[shuttle.can_move() ? ": now" : " in [max(round((shuttle.last_moved + shuttle.cooldown - world.time) * 0.1), 0)] seconds"]<br><br>
		<a href='?src=\ref[src];unauthmed_sili=1'>Medical and Silicon Station</a><br>
		<a href='?src=\ref[src];unauthengi_cargo=1'>Engineering and Cargo Station</a><br>
		<a href='?src=\ref[src];unauthsec_sci=1'>Security and Science Station</a><br>
		[emagged ? "<a href='?src=\ref[src];unauthabandoned=1'>Abandoned Station</a><br>" : ""]"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/taxi_shuttle/emag(mob/user)
	if(!emagged)
		emagged = 1
		req_access = list()
		return 1
	return 0

/obj/machinery/computer/taxi_shuttle/power_change()
	return

/obj/machinery/computer/taxi_shuttle/Topic(href, href_list)
	if(..())	return 1
	var/mob/user = usr

	user.set_machine(src)

	for(var/place in href_list)
		if(href_list[place])
			if(copytext(place, 1, 7) == "unauth") // if it's unauthorised, we take longer
				callTo(copytext(place, 7), shuttle.move_time_no_access)
			else
				callTo(place, shuttle.move_time_access) //otherwise, double quick time

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/taxi_shuttle/proc/callTo(var/place = "", var/wait_time)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/computer/taxi_shuttle/proc/callTo() called tick#: [world.time]")
	switch(place)
		if("med_sili")
			if (taxi_move_to(shuttle.dock_medical_silicon, wait_time))
				return 1
		if("engi_cargo")
			if (taxi_move_to(shuttle.dock_engineering_cargo, wait_time))
				return 1
		if("sec_sci")
			if (taxi_move_to(shuttle.dock_security_science, wait_time))
				return 1
		if("abandoned")
			if (taxi_move_to(shuttle.dock_abandoned, wait_time))
				return 1
	return

/obj/machinery/computer/taxi_shuttle/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")


////////////////////
// TAXI SHUTTLE A //
////////////////////
/obj/machinery/computer/taxi_shuttle/taxi_a
	name = "taxi shuttle terminal A"
	id_tag = "taxi_a"
	letter = "A"

/obj/machinery/computer/taxi_shuttle/taxi_a/New()
	..()
	shuttle = taxi_a

////////////////////
// TAXI SHUTTLE B //
////////////////////

/obj/machinery/computer/taxi_shuttle/taxi_b
	name = "taxi shuttle terminal B"
	id_tag = "taxi_b"
	letter = "B"

/obj/machinery/computer/taxi_shuttle/taxi_b/New()
	..()
	shuttle = taxi_b