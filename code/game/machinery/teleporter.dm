/obj/machinery/computer/teleporter
	name = "\improper Teleporter"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_state = "teleport"
	circuit = "/obj/item/weapon/circuitboard/teleporter"
	var/obj/item/locked = null
	var/id = null
	var/one_time_use = 0 //Used for one-time-use teleport cards (such as clown planet coordinates.)
						 //Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.
	ghost_read=0 // #430
	ghost_write=0

	l_color = "#0000FF"

/obj/machinery/computer/teleporter/New()
	. = ..()
	id = "[rand(1000, 9999)]"

/obj/machinery/computer/teleporter/attackby(I as obj, mob/living/user as mob)
	if(istype(I, /obj/item/weapon/card/data/))
		var/obj/item/weapon/card/data/C = I
		if(stat & (NOPOWER|BROKEN) & (C.function != "teleporter"))
			src.attack_hand()

		var/obj/L = null

		for(var/obj/effect/landmark/sloc in landmarks_list)
			if(sloc.name != C.data) continue
			if(locate(/mob/living) in sloc.loc) continue
			L = sloc
			break

		if(!L)
			L = locate("landmark*[C.data]") // use old stype


		if(istype(L, /obj/effect/landmark/) && istype(L.loc, /turf))
			usr.visible_message("<span class='warning'>[user] enters coordinates into the machine!</span>", "<span class='notice'>You enter coordinates into the machine.</span>")
			usr << "<span class='notice'>A message flashes across the screen reminding the traveller that the nuclear authentication disk is to remain on the station at all times.</span>"
			user.drop_item()
			del(I)

			visible_message("<span class='notice'>Locked In</span>")
			src.locked = L
			one_time_use = 1

			src.add_fingerprint(usr)
	else
		..()

	return

/obj/machinery/computer/teleporter/attack_paw(var/mob/user)
	src.attack_hand(user)

/obj/machinery/teleport/station/attack_ai(var/mob/user)
	src.attack_hand(user)

/obj/machinery/computer/teleporter/attack_hand(var/mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/device/radio/beacon/R in world)
		var/turf/T = get_turf(R)
		if (!T)
			continue
		if(T.z == 2 || T.z > 7)
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R

	for (var/obj/item/weapon/implant/tracking/I in world)
		if (!I.implanted || !ismob(I.loc))
			continue
		else
			var/mob/M = I.loc
			if (M.stat == 2)
				if (M.timeofdeath + 6000 < world.time)
					continue
			var/turf/T = get_turf(M)
			if(T)	continue
			if(T.z == 2)	continue
			var/tmpname = M.real_name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = I

	var/desc = input("Please select a location to lock in.", "Locking Computer") in L
	src.locked = L[desc]
	for(var/mob/O in hearers(src, null))
		O.show_message("\blue Locked In", 2)
	src.add_fingerprint(usr)
	return

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

/proc/find_loc(obj/R as obj)
	if (!R)	return null
	var/turf/T = R.loc
	while(!istype(T, /turf))
		T = T.loc
		if(!T || istype(T, /area))	return null
	return T

/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/stationobjs.dmi'
	density = 1
	anchored = 1.0
	var/lockeddown = 0
	ghost_read=0 // #519
	ghost_write=0


/obj/machinery/teleport/hub
	name = "\improper teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	var/accurate = 0
	var/opened = 0.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000

/obj/machinery/teleport/hub/attackby(obj/item/weapon/O as obj, mob/user as mob)
	if (istype(O, /obj/item/weapon/screwdriver))
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
		if (!opened)
			src.opened = 1
			user.visible_message("<span class='warning'>[user] opens [src]'s maintenance hatch!</span>", "<span class='notice'>You open [src]'s maintenance hatch.</span>")
		else
			src.opened = 0
			user.visible_message("<span class='warning'>[user] closes [src]'s maintenance hatch!</span>", "<span class='notice'>You close [src]'s maintenance hatch.</span>")
			return 1
	else if(istype(O, /obj/item/weapon/crowbar))
		if (opened)
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			user.visible_message("<span class='warning'>[user] begins to remove the circuits from [src]!</span>", "<span class='notice'>You begin to remove the circuits from [src].</span>")
			if(do_after(user,50))
				user.visible_message("<span class='warning'>[user] removes the circuits from [src]!</span>", "<span class='notice'>You remove the circuits from [src].</span>")
				var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				M.state = 2
				M.icon_state = "box_1"
				for(var/obj/I in component_parts)
					if(I.reliability != 100 && crit_fail)
						I.crit_fail = 1
					I.loc = src.loc
				del(src)
				return 1

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/teleport/hub/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/telehub,
		/obj/item/weapon/stock_parts/scanning_module/phasic,
		/obj/item/weapon/stock_parts/scanning_module/phasic,
		/obj/item/weapon/stock_parts/capacitor/super,
		/obj/item/weapon/stock_parts/capacitor/super,
		/obj/item/weapon/stock_parts/capacitor/super,
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

	RefreshParts()

/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	spawn()
		if (src.icon_state == "tele1")
			teleport(M)
			use_power(5000)
	return

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj)
	var/atom/l = src.loc
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(l.x - 2, l.y, l.z))
	if (!com)
		return
	if (!com.locked)
		visible_message("<span class='warning'>Failure: Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	if (istype(M, /atom/movable))
		if(prob(5) && !accurate) //oh dear a problem, put em in deep space
			do_teleport(M, locate(rand((2*TRANSITIONEDGE), world.maxx - (2*TRANSITIONEDGE)), rand((2*TRANSITIONEDGE), world.maxy - (2*TRANSITIONEDGE)), 3), 2)
		else
			do_teleport(M, com.locked) //dead-on precision

		if(com.one_time_use) //Make one-time-use cards only usable one time!
			com.one_time_use = 0
			com.locked = null
	else
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		visible_message("<span class='notice'>Test fire completed.</span>")
	return

/obj/machinery/teleport/station
	name = "\improper station"
	desc = "It's the station thingy of the teleport thingy." //seriously, wtf.
	icon_state = "controller"
	var/active = 0
	var/engaged = 0
	var/opened = 0.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000


/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
obj/machinery/teleport/station/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/telestation,
		/obj/item/weapon/stock_parts/scanning_module/phasic,
		/obj/item/weapon/stock_parts/scanning_module/phasic,
		/obj/item/weapon/stock_parts/capacitor/super,
		/obj/item/weapon/stock_parts/capacitor/super,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/analyzer
	)

	RefreshParts()

/obj/machinery/teleport/station/attackby(var/obj/item/weapon/W, var/mob/user as mob)
	if (istype(W, /obj/item/weapon/screwdriver))
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
		if (!opened)
			src.opened = 1
			user.visible_message("<span class='warning'>[user] opens [src]'s maintenance hatch!</span>", "<span class='notice'>You open [src]'s maintenance hatch.</span>")
		else
			src.opened = 0
			user.visible_message("<span class='warning'>[user] closes [src]'s maintenance hatch!</span>", "<span class='notice'>You close [src]'s maintenance hatch.</span>")
			return 1
	else if(istype(W, /obj/item/weapon/crowbar))
		if (opened)
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			user.visible_message("<span class='warning'>[user] begins to remove the circuits from [src]!</span>", "<span class='notice'>You begin to remove the circuits from [src].</span>")
			if(do_after(user,50))
				user.visible_message("<span class='warning'>[user] removes the circuits from [src]!</span>", "<span class='notice'>You remove the circuits from [src].</span>")
				var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				M.state = 2
				M.icon_state = "box_1"
				for(var/obj/I in component_parts)
					if(I.reliability != 100 && crit_fail)
						I.crit_fail = 1
					I.loc = src.loc
				del(src)
				return 1
	else src.attack_hand()

/obj/machinery/teleport/station/attack_paw(var/mob/user)
	src.attack_hand(user)

/obj/machinery/teleport/station/attack_ai(var/mob/user)
	src.attack_hand(user)

/obj/machinery/teleport/station/attack_hand(var/mob/user)
	if(engaged)
		src.disengage()
	else
		src.engage()

/obj/machinery/teleport/station/proc/engage()
	if(stat & (BROKEN|NOPOWER))
		return

	var/atom/l = src.loc
	var/atom/com = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (com)
		com.icon_state = "tele1"
		use_power(5000)
		visible_message("<span class='notice'>Teleporter engaged!</span>")
	src.add_fingerprint(usr)
	src.engaged = 1
	return

/obj/machinery/teleport/station/proc/disengage()
	if(stat & (BROKEN|NOPOWER))
		return

	var/atom/l = src.loc
	var/atom/com = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (com)
		com.icon_state = "tele0"
		visible_message("<span class='notice'>Teleporter disengaged!</span>")
	src.add_fingerprint(usr)
	src.engaged = 0
	return

/obj/machinery/teleport/station/verb/testfire()
	set name = "Test Fire Teleporter"
	set category = "Object"
	set src in oview(1)

	if(stat & (BROKEN|NOPOWER) || !istype(usr,/mob/living))
		return

	var/atom/l = src.loc
	var/obj/machinery/teleport/hub/com = locate(/obj/machinery/teleport/hub, locate(l.x + 1, l.y, l.z))
	if (com && !active)
		active = 1
		visible_message("<span class='notice'>Test firing!</span>")
		com.teleport()
		use_power(5000)

		spawn(30)
			active=0

	src.add_fingerprint(usr)
	return

/obj/machinery/teleport/station/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "controller-p"
		var/obj/machinery/teleport/hub/com = locate(/obj/machinery/teleport/hub, locate(x + 1, y, z))
		if(com)
			com.icon_state = "tele0"
	else
		icon_state = "controller"


/obj/effect/laser/Bump()
	src.range--
	return

/obj/effect/laser/Move()
	src.range--
	return

/atom/proc/laserhit(L as obj)
	return 1
