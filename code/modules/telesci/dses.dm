/*Deep Space Exploration System
	used like a sonar system, you ping it, it returns if it finds something with a ping, else a buzz

	POTENTIAL MODULES

 - Ping resonation locator
	-Tells the user the direction of the caught turf
 - Ping resonation logging
	-Logs the co-ordinates of the caught turf
 - ping resource resequencing
	-Pings now cost half
 - ping long-range listener
	-Ping range doubled
 - Auto ping system
	-DSES ping is now togglable, if on it pings every 1 SECOND

*/

/obj/item/device/dses
	name = "deep space exploration system"
	desc = "A GPS with a high-gain radio antenna and broadcaster for locating proximity objects in space, the explorers friend."
	icon_state = "dses"
	icon = 'icons/obj/telescience.dmi'
	var/obj/item/weapon/cell/C = null
	var/module_limit = 1
	var/list/module_list = list()
	var/list/locations = list()
	var/pulse_range = 25
	var/pulse_cost = 250
	var/pulse_between = 3 SECONDS
	var/last_pulse
	var/last_direction
	var/last_distance
	var/list/positive_locations = list()
	var/auto_pulse = 0

/obj/item/device/dses/attack_self(var/mob/user as mob)
	if(C)
		return menu_open(user)
	else
		to_chat(user, "<span class = 'notice'>The screen remains dark.</span>")
		return

/obj/item/device/dses/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/dses_module))
		install_module(W, user)
	if(istype(W, /obj/item/weapon/cell))
		if(C)
			to_chat(user, "<span class = 'notice'>There is already a cell installed.</span>")
		else
			if(user.drop_item(W, src))
				to_chat(user, "<span class = 'notice'>You install \the [W] into the battery slot.</span>")
				C = W
	..()

/obj/item/device/dses/proc/menu_open(var/mob/user as mob)
	var/obj/item/device/dses/t = ""
	if(C)
		if(!module_in_list("utoPNG"))
			t += "<BR><A href='?src=\ref[src];pulse=1'>Pulse</A> "
		else
			t += "<BR><A href='?src=\ref[src];tog_pulse=1'>Toggle Pulse:\[[auto_pulse]\]</A>"
		t += "<BR>Current cell charge: [C.charge]/[C.maxcharge]"
		t += "<BR>Current device statistics"
		t += "<BR>Pulse cost: [pulse_cost]"
		t += "<BR>Pulse range: [pulse_range]"
		if(module_in_list("dirGET"))
			t += "<BR><B>Last logged direction: [last_direction]</B>"
		if(module_in_list("getDST"))
			t += "<BR><B>Distance from previous ping: [last_distance]</B>"
		if(module_in_list("crdLOG") && positive_locations.len)
			t += "<BR>==Logged successful pings=="
			var/current_loc_itt
			for(var/atom/A in positive_locations)
				current_loc_itt ++
				t += "<BR>\the [A] in [A.loc] at [A.x-WORLD_X_OFFSET[A.z]] - [A.y-WORLD_Y_OFFSET[A.z]] - [A.z]"
				t += " === <A href='?src=\ref[src];wipe=[current_loc_itt]'>Wipe log</A>"
			t += "<BR><A href='?src=\ref[src];wipe=0'>Wipe All</A>"
		t += "<BR><B>Modules installed</B>"
		if(module_list.len)
			var/current_module_num = 0
			for(var/obj/item/weapon/dses_module/D in module_list)
				current_module_num ++
				t += "<BR>Module: [D.module_name]"
				t += "<BR><A href='?src=\ref[src];eject=[current_module_num]'>Eject Module</A>"
		else
			t += "<BR>No modules detected"
		t += "<BR>Module slots [module_list.len]/[module_limit]"
		t += "<BR><A href='?src=\ref[src];eject_cell=1'>Eject Cell</A>"
	else
		t += "<B>No cell detected.</B>"
	var/datum/browser/popup = new(user, "DSES", name, 300, 450)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/dses/Topic(href, href_list)
	..()
	usr.set_machine(src)
	if(href_list["pulse"])
		if (usr.get_active_hand() != src || usr.stat)
			to_chat(usr, "<span class = 'caution'>You need to have \the [src] in your hand to do that!</span>")
			return
		if(C.charge < pulse_cost)
			to_chat(usr, "<span class = 'caution'>\The [C] has insufficient charge to support another pulse.</span>")
			return
		handle_pulse(usr)

	else if(href_list["eject"])
		var/index = text2num(href_list["eject"])
		if(index && index <= module_list.len)
			var/obj/item/weapon/dses_module/D = module_list[index]
			uninstall_module(D, usr)
			D = null
	else if(href_list["wipe"])
		var/index = text2num(href_list["wipe"])
		if(index && index <= positive_locations.len)
			var/atom/A = positive_locations[index]
			positive_locations -= A
		else
			positive_locations = list()
	else if(href_list["tog_pulse"])
		auto_pulse = !auto_pulse
	else if(href_list["eject_cell"])
		if(C)
			C.forceMove(get_turf(src))
			C = null
			usr << browse(null, "window=DSES")
			return
	updateSelfDialog(usr)

/obj/item/device/dses/updateSelfDialog(mob/user)
	src.attack_self(user)

/obj/item/device/dses/process()
	if(auto_pulse && (!last_pulse || last_pulse <= world.time+pulse_between))
		handle_pulse()

/obj/item/device/dses/proc/handle_pulse(mob/user)
	if(!last_pulse || last_pulse <= world.time+pulse_between)
		var/atom/detected
		detected = pulse()

		if(!detected)
			if(user)
				to_chat(user, "<span class = 'warning'>No structures detected.</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 1, gas_modified = 0)
			return

		playsound(src, 'sound/machines/ping.ogg', 50, 1, gas_modified = 0)

		if(module_in_list("dirGET"))
			var/detect_dir = get_dir(src, detected)
			switch(detect_dir)
				if(1) last_direction = "North"
				if(2) last_direction = "South"
				if(4) last_direction = "East"
				if(5) last_direction = "North East"
				if(6) last_direction = "South East"
				if(8) last_direction = "West"
				if(9) last_direction = "North West"
				if(10) last_direction = "South West"

			if(user)
				to_chat(user, last_direction)

		if(module_in_list("crdLOG"))
			if(detected in positive_locations)
				positive_locations -= detected
			positive_locations += detected

		if(module_in_list("getDST"))
			last_distance = get_dist(get_turf(src), get_turf(detected))

/obj/item/device/dses/proc/pulse()
	var/list/can_see = range(pulse_range,get_turf(src))
	var/atom/detected
	if(C.use(pulse_cost))
		for(var/turf/T in can_see)
			var/new_detected
			if(istype(T, /turf/simulated) \
				|| istype(T, /turf/unsimulated))
				new_detected = T

			for(var/atom/A in T.contents)
				if(istype(A, /obj/structure/lattice) \
					|| istype(A, /obj/structure/window) \
					|| istype(A, /obj/structure/grille))
					new_detected = A

			if(new_detected && get_dist(get_turf(src), get_turf(new_detected)) < get_dist(get_turf(src), get_turf(detected))) //Always pick the closest one
				detected = new_detected
				new_detected = null

		last_pulse = world.time


	return detected

/obj/item/device/dses/proc/install_module(var/obj/item/weapon/dses_module/D, mob/user)
	if(module_list.len >= module_limit)
		to_chat(user, "<span class = 'notice'>Error: Module limit at or over capacity</span>")
		return
	if(user.drop_item(D, src))
		D.install(src)
		module_list += D
		to_chat(user, "<span class = 'notice'>Module installed.</span>")

/obj/item/device/dses/proc/uninstall_module(var/obj/item/weapon/dses_module/D, mob/user)
	D.uninstall(src)
	D.forceMove(get_turf(src))
	module_list -= D
	to_chat(user, "<span class = 'notice'>Module uninstalled.</span>")


/obj/item/device/dses/proc/module_in_list(var/module_name)

	for(var/obj/item/weapon/dses_module/D in module_list)
		if(D.module_name == module_name)
			return 1

	return 0




/obj/item/weapon/dses_module
	name = "generic DSES module"
	var/module_name = "fuckALL"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "circuitboard"
	desc = "This module doesn't seem to have any real purpose."

/obj/item/weapon/dses_module/proc/install(var/obj/item/device/dses/D)
	return

/obj/item/weapon/dses_module/proc/uninstall(var/obj/item/device/dses/D)
	return

/obj/item/weapon/dses_module/range_boost
	name = "DSES ping long-range listener"
	module_name = "rngBOOST"
	desc = "A high-gain amplifier circuit for a DSES receiver, effectively doubling the range."

/obj/item/weapon/dses_module/range_boost/install(var/obj/item/device/dses/D)
	D.pulse_range = D.pulse_range*2
	D.pulse_cost = D.pulse_cost*2

/obj/item/weapon/dses_module/range_boost/uninstall(var/obj/item/device/dses/D)
	D.pulse_range = D.pulse_range/2
	D.pulse_cost = D.pulse_cost/2

/obj/item/weapon/dses_module/cost_reduc
	name = "DSES ping resource optimizer"
	module_name = "chpPNG"
	desc = "Optimizes the cost of DSES pings, reducing the amount of energy needed per ping."

/obj/item/weapon/dses_module/cost_reduc/install(var/obj/item/device/dses/D)
	D.pulse_cost = D.pulse_cost/2

/obj/item/weapon/dses_module/cost_reduc/uninstall(var/obj/item/device/dses/D)
	D.pulse_cost = D.pulse_cost*2

/obj/item/weapon/dses_module/pulse_direction
	name = "DSES ping resonation locator"
	module_name = "dirGET"
	desc = "A much more sensitive listening system which can give a direction to a bounce-back ping."

/obj/item/weapon/dses_module/gps_logger
	name = "DSES ping resonance logger"
	module_name = "crdLOG"
	desc = "Basic memory unit for co-ordinating and logging the locations of succesful pings."

/obj/item/weapon/dses_module/ping_timer
	name = "DSES automated ping system"
	module_name = "utoPNG"
	desc = "Basic clock timer for automating the pinging system, turning it into a toggle."

/obj/item/weapon/dses_module/ping_timer/install(var/obj/item/device/dses/D)
	processing_objects.Add(D)

/obj/item/weapon/dses_module/ping_timer/uninstall(var/obj/item/device/dses/D)
	processing_objects.Remove(D)

/obj/item/weapon/dses_module/distance_get
	name = "DSES ping distance approximation system"
	module_name = "getDST"
	desc = "A small maths system that calculates signal decay between transmission and sending, to approximate distance."