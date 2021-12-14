/obj/machinery/computer/teleporter
	name = "Teleporter"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_state = "teleport"
	circuit = "/obj/item/weapon/circuitboard/teleporter"
	var/frequency = 1459
	var/obj/item/locked = null
	var/id = null
	var/one_time_use = 0 //Used for one-time-use teleport cards (such as clown planet coordinates.)
						 //Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.
	ghost_write=0

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/teleporter/New()
	. = ..()
	frequency = format_frequency(sanitize_frequency(frequency))
	id = "[rand(1000, 9999)]"

/obj/machinery/computer/teleporter/attackby(I as obj, mob/living/user as mob)
	if(..())
		return 1
	else if(istype(I, /obj/item/weapon/card/data/))
		var/obj/item/weapon/card/data/C = I
		if(stat & (NOPOWER|BROKEN) & (C.function != "teleporter"))
			src.attack_hand()

		var/obj/L = null

		for(var/obj/effect/landmark/sloc in landmarks_list)
			if(sloc.name != C.data)
				continue
			if(locate(/mob/living) in sloc.loc)
				continue
			L = sloc
			break

		if(!L)
			L = locate("landmark*[C.data]") // use old stype


		if(istype(L, /obj/effect/landmark/) && istype(L.loc, /turf))
			if(!user.drop_item(I))
				user << "<span class='warning'>You can't let go of \the [I]!</span>"
				return

			to_chat(usr, "You insert the coordinates into the machine.")
			to_chat(usr, "A message flashes across the screen reminding the traveller that the nuclear authentication disk is to remain on the station at all times.")
			qdel(I)

			say("Locked in")
			src.locked = L
			one_time_use = 1

			src.add_fingerprint(usr)
	return

/obj/machinery/computer/teleporter/examine(var/mob/user)
	..()
	if(locked)
		var/area/locked_area = get_area(locked)
		to_chat(user, "The destination is set to \"[locked_area.name]\".")

/obj/machinery/computer/teleporter/attack_paw(var/mob/user)
	src.attack_hand(user)

/obj/machinery/teleport/teleporter/attack_ai(var/mob/user)
	src.attack_hand(user)

/obj/machinery/computer/teleporter/attack_hand(var/mob/user)
	. = ..()
	if(.)
		user.unset_machine()
		return

	interact(user)

/obj/machinery/computer/teleporter/interact(var/mob/user)
	var/area/locked_area
	if(frequency)
		. = {"
		<b>Frequency:</b> <a href='?src=\ref[src];freq=1'>[frequency]</a><br><br>
		"}
	if(locked)
		locked_area = get_area(locked)
		if(!locked_area)
			locked = null

		if(locked) //If there's still a locked thing (incase it got cleared above)
			locked_area = get_area(locked)
			if(!locked_area)
				locked = null

			. += {"
			<b>Destination:</b> [sanitize(locked_area.name)]<br>
			<a href='?src=\ref[src];clear=1'>Clear destination</a><br>
			"}
	else
		. += {"
		<b>Destination unset!</b><br>
		"}

	. += {"
		<br><b>Available destinations:<b><br>
		<lu>
	"}

	var/list/dests = get_avail_dests()

	for(var/name in dests)
		. += {"
			<li><a href='?src=\ref[src];dest=[dests.Find(name)]'[dests[name] == locked ? " class='linkOn'" : ""]>[sanitize(name)]</a></li>
		"}

	. += "</lu>"

	var/datum/browser/popup = new(user, "teleporter_console", name, 250, 500, src)
	popup.set_content(.)
	popup.open()
	user.set_machine(src)

/obj/machinery/computer/teleporter/Topic(var/href, var/list/href_list)
	. = ..()
	if(.)
		return

	if(href_list["freq"])
		if(change_freq())
			say("Frequency set")
		updateUsrDialog()
		return 1

	if(href_list["clear"])
		locked = null
		updateUsrDialog()
		return 1

	if(href_list["dest"])
		var/list/dests = get_avail_dests()
		var/idx = clamp(text2num(href_list["dest"]), 1, dests.len)
		locked = dests[dests[idx]]
		say("Locked in")
		updateUsrDialog()
		return 1

/obj/machinery/computer/teleporter/proc/get_avail_dests()
	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/beacon/R in beacons)
		var/turf/T = get_turf(R)
		if(R.frequency != src.frequency)
			continue
		if (!T)
			continue
		if(T.z == map.zCentcomm || T.z > map.zLevels.len)
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R

	for (var/obj/item/weapon/implant/tracking/I in tracking_implants)
		if (!I.imp_in || !ismob(I.loc))
			continue
		else
			var/mob/M = I.loc
			if (M.stat == 2)
				if (M.timeofdeath + 6000 < world.time)
					continue
			var/turf/T = get_turf(M)
			if(!T)
				continue
			if(T.z == map.zCentcomm)
				continue
			var/tmpname = M.real_name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = I

	. = L

/obj/machinery/computer/teleporter/proc/change_freq(var/mob/user)
	var/newfreq = input("Input a new frequency for the teleporter", "Frequency", null) as null|num
	if(stat & (BROKEN|NOPOWER))
		return 0
	var/ghost_flags=0
	if(ghost_write)
		ghost_flags |= PERMIT_ALL
	if(!canGhostWrite(usr,src,"",ghost_flags))
		if(usr.restrained() || usr.lying || usr.stat)
			return 0
		if (!usr.dexterity_check())
			to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return 0
		if(!is_on_same_z(usr))
			to_chat(usr, "<span class='warning'>WARNING: Unable to interface with \the [src.name].</span>")
			return 0
		if(!is_in_range(usr))
			to_chat(usr, "<span class='warning'>WARNING: Connection failure. Reduce range.</span>")
			return 0
	else if(!newfreq)
		return 0

	frequency = format_frequency(sanitize_frequency(newfreq))
	return 1

/obj/machinery/computer/teleporter/verb/set_id(t as text)
	set category = "Object"
	set name = "Set teleporter ID"
	set src in oview(1)
	set desc = "ID Tag:"

	if(stat & (NOPOWER|BROKEN) || !istype(usr,/mob/living))
		return
	if (t)
		src.id = t
	return

/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/stationobjs.dmi'
	density = 1
	anchored = 1.0
	var/lockeddown = 0
	var/engaged = 0
	ghost_read=0 // #519
	ghost_write=0
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

/obj/machinery/teleport/hub
	name = "teleporter horizon generator"
	desc = "This generates the portal through which you step through to teleport elsewhere."
	icon_state = "tele0"
	//var/accurate = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/teleport_power_usage = 5000
	component_parts = newlist(
		/obj/item/weapon/circuitboard/telehub,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/capacitor/adv/super,
		/obj/item/weapon/stock_parts/capacitor/adv/super,
		/obj/item/weapon/stock_parts/capacitor/adv/super,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/subspace/treatment,
		/obj/item/weapon/stock_parts/subspace/crystal,
		/obj/item/weapon/stock_parts/subspace/crystal,
		/obj/item/weapon/stock_parts/subspace/transmitter,
		/obj/item/weapon/stock_parts/subspace/transmitter,
		/obj/item/weapon/stock_parts/subspace/transmitter,
		/obj/item/weapon/stock_parts/subspace/transmitter
	)
	density = 0

/obj/machinery/teleport/hub/RefreshParts()
	var/T = 1
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating-3
	teleport_power_usage = initial(teleport_power_usage)/T


/obj/machinery/teleport/hub/power_change()
	..()
	if(stat & (BROKEN|NOPOWER))
		engaged = 0
	update_icon()

/obj/machinery/teleport/hub/update_icon()
	if(stat & (BROKEN|NOPOWER) || !engaged)
		icon_state = "tele0"
		kill_light()
	else
		icon_state = "tele1"
		set_light(3, l_color = "#FFAA00")


/obj/machinery/teleport/hub/Crossed(AM as mob|obj)
	if(AM == src)
		return//DUH
	if(istype(AM,/obj/effect/beam))
		src.to_bump(AM)
		return
	spawn()
		if (src.engaged && teleport(AM))
			use_power(teleport_power_usage)


/obj/machinery/teleport/hub/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/item/projectile/beam))
		return 0
	else
		return ..()

/obj/machinery/teleport/hub/bullet_act(var/obj/item/projectile/Proj)
	var/atom/locked = get_target_lock()
	if(!locked)
		return PROJECTILE_COLLISION_MISS

	return PROJECTILE_COLLISION_PORTAL


/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj)
	var/atom/locked = get_target_lock()
	if(!locked)
		return FALSE
	if(get_turf(locked) == get_turf(src))
		to_chat(M, "<span class = 'notice'>The act of teleportation was so smooth, it feels like you didn't move at all!</span>")
		return FALSE
	if(istype(M, /atom/movable))
		do_teleport(M, locked)
		after_teleport()
	else
		spark(src, 5)

	return 1

/obj/machinery/teleport/hub/proc/get_target_lock()
	var/obj/machinery/teleport/station/st = locate(/obj/machinery/teleport/station, orange(1,src))
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, orange(1, st))
	if (!com)
		visible_message("<span class='warning'>Failure: Cannot identify linked computer.</span>")
		return
	if (!com.locked || com.locked.gcDestroyed)
		com.locked = null
		visible_message("<span class='warning'>Failure: Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	return com.locked

/obj/machinery/teleport/hub/proc/after_teleport()
	var/obj/machinery/teleport/station/st = locate(/obj/machinery/teleport/station, orange(1,src))
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, orange(1, st))
	if(com && com.one_time_use) //one-time-use cards
		com.one_time_use = 0
		com.locked = null

/obj/machinery/teleport/station
	name = "teleporter controller"
	desc = "This co-ordinates nearby teleporter horizon generators."
	icon_state = "controller"
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/teleport_power_usage = 5000
	component_parts = newlist(
		/obj/item/weapon/circuitboard/telestation,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/capacitor/adv/super,
		/obj/item/weapon/stock_parts/capacitor/adv/super,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/analyzer
	)

/obj/machinery/teleport/station/RefreshParts()
	var/T = 1
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating-3
	teleport_power_usage = initial(teleport_power_usage)/T

/obj/machinery/teleport/station/power_change()
	..()
	if(stat & (BROKEN|NOPOWER))
		disengage()
	update_icon()

/obj/machinery/teleport/station/update_icon()
	if(stat & NOPOWER)
		icon_state = "controller-p"
	else
		icon_state = "controller"

/obj/machinery/teleport/station/attackby(var/obj/item/weapon/W, var/mob/user as mob)
	if (..())
		return 1
	else
		src.attack_hand()

/obj/machinery/teleport/station/attack_paw(var/mob/user)
	src.attack_hand(user)

/obj/machinery/teleport/station/attack_ai(var/mob/user)
	src.attack_hand(user)

/obj/machinery/teleport/station/attack_hand(var/mob/user)
	if(engaged)
		src.disengage(user)
	else
		src.engage()

/obj/machinery/teleport/station/proc/engage()
	if(stat & (BROKEN|NOPOWER))
		return
	var/count = 0
	for(var/obj/machinery/teleport/hub/hub in orange(1, src))
		if(hub.stat & (BROKEN|NOPOWER))
			continue
		count++
		hub.engaged = 1
		hub.update_icon()
		use_power(teleport_power_usage)
	visible_message("<span class='notice'>[count] teleporter[count>1?"s":""] engaged!</span>", range = 2)
	src.add_fingerprint(usr)
	src.engaged = 1
	return

/obj/machinery/teleport/station/proc/disengage(mob/user)
	var/count = 0
	for(var/obj/machinery/teleport/hub/hub in orange(1, src))
		count++
		hub.engaged = 0
		hub.update_icon()
	visible_message("<span class='notice'>[count] teleporter[count>1?"s":""] disengaged!</span>", range = 2)
	if(user)
		src.add_fingerprint(user)
	src.engaged = 0
	return

///obj/machinery/teleport/station/verb/testfire()
	//set name = "Test Fire Teleporter"
	//set category = "Object"
	//set src in oview(1)

	//if(stat & (BROKEN|NOPOWER) || !istype(usr,/mob/living))
	//	return
	//for(var/obj/machinery/teleport/hub/hub in orange(1))
	//	engaged = 1
	//	var/wasaccurate = hub.accurate //let's make sure if you have a mapped in accurate tele that it stays that way
	//	hub.accurate = 1
	//	hub.engaged = 1
	//	hub.update_icon()
	//	visible_message("<span class='notice'>Test firing! Teleporter temporarily calibrated to be more accurate.</span>", range = 2)
	//	hub.teleport()
	//	use_power(teleport_power_usage)
	//	spawn(30)
	//		hub.accurate = wasaccurate
	//		visible_message("<span class='notice'>Test fire completed.</span>", range = 2)
	//src.add_fingerprint(usr)
	//return

/obj/machinery/teleport/hub/emergency
	name = "emergency horizon generator"
	desc = "This specialized horizon generator creates a portal, but always to the same place, and only becomes active during emergencies."
	machine_flags = SCREWTOGGLE | FIXED2WORK //cannot wrenchmove or crowdestroy
	var/emergency = FALSE //this will keep trying to re-engage it if power is lost then restored
	var/embeacon = null

/obj/machinery/teleport/hub/emergency/examine(mob/user)
	..()
	if(engaged && embeacon)
		to_chat(user,"<span class='danger'>Due to the alert, it is set to travel to [get_area(embeacon)].</span>")

/obj/machinery/teleport/hub/emergency/power_change()
	if(stat & (BROKEN|NOPOWER))
		engaged = FALSE
	else
		engaged = emergency
	update_icon()

/obj/machinery/teleport/hub/emergency/after_teleport()
	return

/obj/machinery/teleport/hub/emergency/process()
	return //this prevents us from being removed from machines

/obj/machinery/teleport/hub/emergency/get_target_lock()
	if(!embeacon)
		embeacon = pick(emergency_beacons)
	return embeacon

/obj/machinery/teleport/hub/emergency/proc/alarm(var/panic = FALSE)
	engaged = panic
	emergency = panic
	if(!embeacon)
		embeacon = pick(emergency_beacons)
	update_icon()

/obj/machinery/teleport/hub/emergency/attack_hand(mob/user)
	if(!embeacon)
		embeacon = pick(emergency_beacons)
		to_chat(user,"<span class='notice'>Target updated to [get_area(embeacon)].</span>")
		return
	else if(emergency_beacons.len > 1)
		var/list/L = emergency_beacons.Copy()
		L -= embeacon
		embeacon = pick(L)
		to_chat(user,"<span class='notice'>Target updated to [get_area(embeacon)].</span>")
		return
	else
		..()
