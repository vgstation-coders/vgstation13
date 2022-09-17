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

#define TRACKMODULE "crdLOG"
#define AUTOPINGMODULE "utoPNG"
#define GETDIRMODULE "dirGET"
#define GETDISTANCEMODULE "getDST"
#define RANGEDOUBLEMODULE "rngBOOST"
#define HALFCOSTMODULE "chpPNG"

/obj/item/device/dses
	name = "deep space exploration system"
	desc = "A GPS with a high-gain radio antenna and broadcaster for locating proximity objects in space, the explorers friend."
	icon_state = "dses"
	icon = 'icons/obj/telescience.dmi'
	var/obj/item/weapon/cell/C = null
	var/module_limit = 2 //So you can get a diverse-ish DSES instead of only ever using the directional module
	var/list/module_list = list()
	var/list/locations = list()
	var/pulse_range = 25
	var/pulse_cost = 250
	var/pulse_between = 3 SECONDS
	var/last_pulse = 0
	var/last_direction
	var/last_distance
	var/list/positive_locations = list()
	var/auto_pulse = 0
	origin_tech = list(Tc_BLUESPACE = 4, Tc_MAGNETS = 4)

/datum/dses_find
	var/name
	var/location_name
	var/x
	var/y
	var/z

/obj/item/device/dses/attack_self(var/mob/user)
	if(C)
		return menu_open(user)
	to_chat(user, "<span class = 'notice'>The screen remains dark, as no cell is installed.</span>")

/obj/item/device/dses/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/dses_module))
		install_module(W, user)
	if(istype(W, /obj/item/weapon/cell))
		if(C)
			to_chat(user, "<span class = 'notice'>There is already a cell installed.</span>")
		else
			if(user.drop_item(W, src))
				to_chat(user, "<span class = 'notice'>You install \the [W] into the battery slot.</span>")
				C = W
	..()

/obj/item/device/dses/proc/menu_open(var/mob/user)
	var/obj/item/device/dses/t = ""
	if(C)
		if(!module_in_list(AUTOPINGMODULE))
			t += "<BR><A href='?src=\ref[src];pulse=1'>Pulse</A> "
		else
			t += "<BR><A href='?src=\ref[src];tog_pulse=1'>Toggle Pulse: \[[auto_pulse]\]</A>"
		t += {"<BR>Current cell charge: [C.charge]/[C.maxcharge]
			<BR>Current device statistics
			<BR>Pulse cost: [pulse_cost]
			<BR>Pulse range: [pulse_range]"}
		if(module_in_list(GETDIRMODULE))
			t += "<BR>Last logged direction: [last_direction]"
		if(module_in_list(GETDISTANCEMODULE))
			t += "<BR>Distance from previous ping: [last_distance]"
		if(module_in_list(TRACKMODULE) && positive_locations.len)
			t += "<BR><HR>Logged successful pings</HR>"
			var/current_loc_itt
			for(var/datum/dses_find/D in positive_locations)
				current_loc_itt ++
				t += {"<BR>\the [D.name] in [D.location_name] at [D.x-WORLD_X_OFFSET[D.z]] - [D.y-WORLD_Y_OFFSET[D.z]] - [D.z]
				 : <A href='?src=\ref[src];wipe=[current_loc_itt]'>Wipe log</A>"}
			t += "<BR><A href='?src=\ref[src];wipe=0'>Wipe All</A>"
		t += "<BR><B><HR>Modules installed</HR></B>"
		if(module_list.len)
			var/current_module_num = 0
			for(var/obj/item/dses_module/D in module_list)
				current_module_num ++
				t += "<BR>Module: [D.module_name] <A href='?src=\ref[src];eject=[current_module_num]'>Eject Module</A>"
		else
			t += "<BR>No modules detected"
		t += "<BR>Module slots [module_list.len]/[module_limit]"
		t += "<BR><A href='?src=\ref[src];eject_cell=1'>Eject Cell</A>"
	else
		t += "<B>No cell detected.</B>"
	var/datum/browser/popup = new(user, "\ref[src]", name, 300, 450)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/dses/Topic(href, href_list)
	..()

	usr.set_machine(src)

	if (usr.get_active_hand() != src || usr.isUnconscious())
		to_chat(usr, "<span class = 'caution'>You need to have \the [src] in your hand to do that!</span>")
		return

	if(href_list["pulse"])
		if(C.charge < pulse_cost)
			to_chat(usr, "<span class = 'caution'>\The [C] has insufficient charge to support another pulse.</span>")
			return

		handle_pulse(usr)
		. = 1

	if(href_list["eject"])
		var/index = text2num(href_list["eject"])
		if(index && index <= module_list.len)
			var/obj/item/dses_module/D = module_list[index]
			uninstall_module(D, usr)
			D = null
			. = 1

	if(href_list["wipe"])
		var/index = text2num(href_list["wipe"])
		if(index && index <= positive_locations.len)
			var/datum/dses_find/D = positive_locations[index]
			positive_locations -= D
			qdel(D)
		else
			for(var/datum/dses_find/D in positive_locations)
				qdel(D)
			positive_locations = list()
		. = 1

	if(href_list["tog_pulse"])
		auto_pulse = !auto_pulse
		. = 1

	if(href_list["eject_cell"])
		if(C)
			usr.put_in_hands(C)
			C = null
			usr << browse(null, "window=\ref[src]")
			return

	if(.)
		updateSelfDialog(usr)


/obj/item/device/dses/process()
	if(auto_pulse && last_pulse <= world.time+pulse_between)
		handle_pulse()

/obj/item/device/dses/proc/handle_pulse(mob/user)
	if(last_pulse <= world.time+pulse_between)
		var/atom/detected = pulse()

		if(!detected)
			if(user)
				to_chat(user, "<span class = 'warning'>No structures detected.</span>")
				user.playsound_local(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1, gas_modified = 0)
			else
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1, gas_modified = 0, extrarange = -7)
			return
		if(user)
			user.playsound_local(get_turf(src), 'sound/machines/ping.ogg', 50, 1, gas_modified = 0)
		else
			playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1, gas_modified = 0, extrarange = -7)
		if(module_in_list(GETDIRMODULE))
			last_direction = dir2text(get_dir(src, detected))
			if(user)
				to_chat(user, last_direction)

		if(module_in_list(TRACKMODULE))
			var/datum/dses_find/D = new()
			D.name = detected.name
			D.x = detected.x
			D.y = detected.y
			D.z = detected.z
			D.location_name = detected.loc.name
			positive_locations += D

		if(module_in_list(GETDISTANCEMODULE))
			last_distance = get_dist(get_turf(src), get_turf(detected))

/obj/item/device/dses/proc/pulse()
	var/list/can_see = trange(pulse_range,get_turf(src))
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
					break

			if(new_detected && get_dist(get_turf(src), get_turf(new_detected)) < get_dist(get_turf(src), get_turf(detected))) //Always pick the closest one
				detected = new_detected
				new_detected = null

		last_pulse = world.time
	else
		if(auto_pulse)
			auto_pulse = 0

	return detected

/obj/item/device/dses/proc/install_module(var/obj/item/dses_module/D, mob/user)
	if(module_list.len >= module_limit)
		to_chat(user, "<span class = 'notice'>Error: Module limit at or over capacity</span>")
		return
	if(user.drop_item(D, src))
		D.install(src)
		module_list += D
		to_chat(user, "<span class = 'notice'>Module installed.</span>")

/obj/item/device/dses/proc/uninstall_module(var/obj/item/dses_module/D, mob/user)
	D.uninstall(src)
	user.put_in_hands(D)
	module_list -= D
	to_chat(user, "<span class = 'notice'>Module uninstalled.</span>")


/obj/item/device/dses/proc/module_in_list(var/module_name)

	for(var/obj/item/dses_module/D in module_list)
		if(D.module_name == module_name)
			return 1

	return 0




/obj/item/dses_module
	name = "generic DSES module"
	var/module_name = "nada"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "circuitboard"
	desc = "This module doesn't seem to have any real purpose."

/obj/item/dses_module/proc/install(var/obj/item/device/dses/D)
	return

/obj/item/dses_module/proc/uninstall(var/obj/item/device/dses/D)
	return

/obj/item/dses_module/range_boost
	name = "DSES ping long-range listener"
	module_name = RANGEDOUBLEMODULE
	desc = "A high-gain amplifier circuit for a DSES receiver, effectively doubling the range."
	origin_tech = list(Tc_BLUESPACE = 3)

/obj/item/dses_module/range_boost/install(var/obj/item/device/dses/D)
	D.pulse_range *=2
	D.pulse_cost *=2

/obj/item/dses_module/range_boost/uninstall(var/obj/item/device/dses/D)
	D.pulse_range /=2
	D.pulse_cost /=2

/obj/item/dses_module/cost_reduc
	name = "DSES ping resource optimizer"
	module_name = HALFCOSTMODULE
	desc = "Optimizes the cost of DSES pings, reducing the amount of energy needed per ping."
	origin_tech = list(Tc_POWERSTORAGE = 3)

/obj/item/dses_module/cost_reduc/install(var/obj/item/device/dses/D)
	D.pulse_cost /=2

/obj/item/dses_module/cost_reduc/uninstall(var/obj/item/device/dses/D)
	D.pulse_cost *=2

/obj/item/dses_module/pulse_direction
	name = "DSES ping resonation locator"
	module_name = GETDIRMODULE
	desc = "A much more sensitive listening system which can give a direction to a bounce-back ping."
	origin_tech = list(Tc_BLUESPACE = 3, Tc_MAGNETS = 3)

/obj/item/dses_module/gps_logger
	name = "DSES ping resonance logger"
	module_name = TRACKMODULE
	desc = "Basic memory unit for co-ordinating and logging the locations of succesful pings."
	origin_tech = list(Tc_PROGRAMMING = 3, Tc_MAGNETS = 2)

/obj/item/dses_module/ping_timer
	name = "DSES automated ping system"
	module_name = AUTOPINGMODULE
	desc = "Basic clock timer for automating the pinging system, turning it into a toggle."
	origin_tech = list(Tc_PROGRAMMING = 4, Tc_ENGINEERING = 3)

/obj/item/dses_module/ping_timer/install(var/obj/item/device/dses/D)
	processing_objects.Add(D)

/obj/item/dses_module/ping_timer/uninstall(var/obj/item/device/dses/D)
	processing_objects.Remove(D)

/obj/item/dses_module/distance_get
	name = "DSES ping distance approximation system"
	module_name = GETDISTANCEMODULE
	desc = "A small mathematic system that calculates signal decay between transmission and sending, to approximate distance."
	origin_tech = list(Tc_BLUESPACE = 4, Tc_MAGNETS = 3) 
