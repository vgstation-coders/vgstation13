var/bomb_set
var/obj/item/weapon/disk/nuclear/nukedisk

/obj/machinery/nuclearbomb
	name = "\improper Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = 1
	var/deployable = 0.0
	var/extended = 0.0
	var/timeleft = 60.0
	var/timing = 0.0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0.0
	var/safety = 1.0
	var/obj/item/weapon/disk/nuclear/auth = null
	var/removal_stage = 0 // 0 is no removal, 1 is covers removed, 2 is covers open,
	                      // 3 is sealant open, 4 is unwrenched, 5 is removed from bolts.
	flags = FPRINT
	use_power = 0

/obj/machinery/nuclearbomb/New()
	..()
	r_code = "[rand(10000, 99999.0)]"//Creates a random code upon object spawn.

/obj/machinery/nuclearbomb/process()
	if (src.timing)
		bomb_set = 1 //So long as there is one nuke timing, it means one nuke is armed.
		src.timeleft--
		if (src.timeleft <= 0)
			explode()
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				src.attack_hand(M)
	return

/obj/machinery/nuclearbomb/attackby(obj/item/weapon/O as obj, mob/user as mob)
	if (src.extended)
		if (istype(O, /obj/item/weapon/disk/nuclear))
			usr.drop_item(O, src, force_drop = 1)
			src.auth = O
			src.add_fingerprint(user)
			return

	if (src.anchored)
		switch(removal_stage)
			if(0)
				if(iswelder(O))

					var/obj/item/weapon/weldingtool/WT = O
					user.visible_message("[user] starts cutting loose the anchoring bolt covers on [src].", "You start cutting loose the anchoring bolt covers with [O]...")

					if(WT.do_weld(user, src, 40, 5))
						if(gcDestroyed)
							return
						user.visible_message("[user] cuts through the bolt covers on [src].", "You cut through the bolt cover.")
						removal_stage = 1
				return

			if(1)
				if(istype(O,/obj/item/weapon/crowbar))
					user.visible_message("[user] starts forcing open the bolt covers on [src].", "You start forcing open the anchoring bolt covers with [O]...")

					if(do_after(user,  src, 15))
						if(!src || !user)
							return
						user.visible_message("[user] forces open the bolt covers on [src].", "You force open the bolt covers.")
						removal_stage = 2
				return

			if(2)
				if(iswelder(O))

					var/obj/item/weapon/weldingtool/WT = O
					user.visible_message("[user] starts cutting apart the anchoring system sealant on [src].", "You start cutting apart the anchoring system's sealant with [O]...")

					if(WT.do_weld(user, src, 40, 5))
						if(gcDestroyed)
							return
						user.visible_message("[user] cuts apart the anchoring system sealant on [src].", "You cut apart the anchoring system's sealant.")
						removal_stage = 3
				return

			if(3)
				if(istype(O,/obj/item/weapon/wrench))

					user.visible_message("[user] begins unwrenching the anchoring bolts on [src].", "You begin unwrenching the anchoring bolts...")

					if(do_after(user, src, 50))
						if(!src || !user)
							return
						user.visible_message("[user] unwrenches the anchoring bolts on [src].", "You unwrench the anchoring bolts.")
						removal_stage = 4
				return

			if(4)
				if(istype(O,/obj/item/weapon/crowbar))

					user.visible_message("[user] begins lifting [src] off of the anchors.", "You begin lifting the device off the anchors...")

					if(do_after(user, src, 80))
						if(!src || !user)
							return
						user.visible_message("[user] crowbars [src] off of the anchors. It can now be moved.", "You jam the crowbar under the nuclear device and lift it off its anchors. You can now move it!")
						anchored = 0
						removal_stage = 5
				return
	..()

/obj/machinery/nuclearbomb/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/nuclearbomb/attack_ghost(mob/user as mob) //prevents ghosts from deploying the nuke
	if (src.extended) //if the nuke is set
		return attack_hand(user) //continue as normal
	return 0 //otherwise nothing

/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
	if (src.extended)
		user.set_machine(src)
		var/dat = text("<TT><B>Nuclear Fission Explosive</B><BR>\nAuth. Disk: <A href='?src=\ref[];auth=1'>[]</A><HR>", src, (src.auth ? "++++++++++" : "----------"))
		if (src.auth)
			if (src.yes_code)
				dat += text("\n<B>Status</B>: []-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] <A href='?src=\ref[];timer=1'>Toggle</A><BR>\nTime: <A href='?src=\ref[];time=-10'>-</A> <A href='?src=\ref[];time=-1'>-</A> [] <A href='?src=\ref[];time=1'>+</A> <A href='?src=\ref[];time=10'>+</A><BR>\n<BR>\nSafety: [] <A href='?src=\ref[];safety=1'>Toggle</A><BR>\nAnchor: [] <A href='?src=\ref[];anchor=1'>Toggle</A><BR>\n", (src.timing ? "Func/Set" : "Functional"), (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src, src, src, src.timeleft, src, src, (src.safety ? "On" : "Off"), src, (src.anchored ? "Engaged" : "Off"), src)
			else
				dat += text("\n<B>Status</B>: Auth. S2-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\n[] Safety: Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
		else
			if (src.timing)
				dat += text("\n<B>Status</B>: Set-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\nSafety: [] Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
			else
				dat += text("\n<B>Status</B>: Auth. S1-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\nSafety: [] Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
		var/message = "AUTH"
		if (src.auth)
			message = text("[]", src.code)
			if (src.yes_code)
				message = "*****"
		dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)
		user << browse(dat, "window=nuclearbomb;size=300x400")
		onclose(user, "nuclearbomb")
	else if (src.deployable)
		if(removal_stage < 5)
			src.anchored = 1
			visible_message("<span class='notice'>With a steely snap, bolts slide out of [src] and anchor it to the flooring!</span>")
		else
			visible_message("<span class='notice'>\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
		flick("nuclearbombc", src)
		src.icon_state = "nuclearbomb1"
		src.extended = 1
	return

/obj/machinery/nuclearbomb/verb/make_deployable()
	set category = "Object"
	set name = "Make Deployable"
	set src in oview(1)

	if (!usr || usr.lying || usr.isUnconscious())
		return
	if (!usr.dexterity_check())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if (src.deployable)
		to_chat(usr, "<span class='notice'>You close several panels to make [src] undeployable.</span>")
		src.deployable = 0
	else
		to_chat(usr, "<span class='notice'>You adjust some panels to make [src] deployable.</span>")
		src.deployable = 1

/obj/machinery/nuclearbomb/Topic(href, href_list)
	if(..())
		return 1
	if (!usr.canmove || usr.stat || usr.restrained())
		return
	if (!usr.dexterity_check())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1
	if (istype(src.loc, /turf))
		usr.set_machine(src)
		if (href_list["auth"])
			if (src.auth)
				src.auth.forceMove(src.loc)
				src.yes_code = 0
				src.auth = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/disk/nuclear))
					usr.drop_item(I, src, force_drop = 1) //FORCE DROP for balance reasons
					src.auth = I
		if (src.auth)
			if (href_list["type"])
				if (href_list["type"] == "E")
					if (src.code == src.r_code)
						src.yes_code = 1
						src.code = null
					else
						src.code = "ERROR"
				else
					if (href_list["type"] == "R")
						src.yes_code = 0
						src.code = null
					else
						src.code += text("[]", href_list["type"])
						if (length(src.code) > 5)
							src.code = "ERROR"
			if (src.yes_code)
				if (href_list["time"])
					var/time = text2num(href_list["time"])
					src.timeleft += time
					src.timeleft = min(max(round(src.timeleft), 60), 600)
				if (href_list["timer"])
					if (src.timing == -1.0)
						return
					if (src.safety)
						to_chat(usr, "<span class='warning'>The safety is still on.</span>")
						return
					src.timing = !( src.timing )
					if (src.timing)
						src.icon_state = "nuclearbomb2"
						if(!src.safety)
							bomb_set = 1//There can still be issues with this reseting when there are multiple bombs. Not a big deal tho for Nuke/N
						else
							bomb_set = 0
					else
						src.icon_state = "nuclearbomb1"
						bomb_set = 0
						score["nukedefuse"] = min(src.timeleft, score["nukedefuse"])
				if (href_list["safety"])
					src.safety = !( src.safety )
					if(safety)
						src.timing = 0
						bomb_set = 0
						score["nukedefuse"] = min(src.timeleft, score["nukedefuse"])
				if (href_list["anchor"])

					if(removal_stage == 5)
						src.anchored = 0
						visible_message("<span class='warning'>\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
						return

					src.anchored = !( src.anchored )
					if(src.anchored)
						visible_message("<span class='warning'>With a steely snap, bolts slide out of [src] and anchor it to the flooring.</span>")
						playsound(src,'sound/effects/bolt.ogg', 70, 1)
					else
						visible_message("<span class='warning'>The anchoring bolts slide back into the depths of [src].</span>")

		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				src.attack_hand(M)
	else
		usr << browse(null, "window=nuclearbomb")
		return
	return


/obj/machinery/nuclearbomb/ex_act(severity)
	return

/obj/machinery/nuclearbomb/blob_act()
	return

#define NUKERANGE 80
/obj/machinery/nuclearbomb/proc/explode()
	if (src.safety)
		src.timing = 0
		return
	src.timing = -1.0
	src.yes_code = 0
	src.safety = 1
	src.icon_state = "nuclearbomb3"
	playsound(src,'sound/machines/Alarm.ogg',100,0,5)
	if (ticker)
		ticker.explosion_in_progress = 1
	sleep(100)

	enter_allowed = 0

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	explosion(bomb_location, 30, 60, 120, 120, 10)
	if( bomb_location && (bomb_location.z == map.zMainStation) )
		var/map_center_x = world.maxx * 0.5
		var/map_center_y = world.maxy * 0.5

		if( (bomb_location.x < (map_center_x-NUKERANGE)) || (bomb_location.x > (map_center_x+NUKERANGE)) || (bomb_location.y < (map_center_y-NUKERANGE)) || (bomb_location.y > (map_center_y+NUKERANGE)) )
			off_station = 1
	else
		off_station = 2
	forceMove(null)
	ticker.station_explosion_cinematic(off_station,null)
	ticker.explosion_in_progress = FALSE
	to_chat(world, "<B>The station was destroyed by the nuclear blast!</B>")

	ticker.station_was_nuked = (off_station<2)	//offstation==1 is a draw. the station becomes irradiated and needs to be evacuated.
													//kinda shit but I couldn't  get permission to do what I wanted to do.
	SSpersistence_map.setSavingFilth(FALSE)
	stat_collection.nuked++

/obj/machinery/nuclearbomb/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"deployable",
		"extended",
		"timeleft",
		"timing",
		"safety")

	reset_vars_after_duration(resettable_vars, duration)

/obj/machinery/nuclearbomb/isacidhardened() // Requires Aliens to channel acidspit on the nuke.
	return TRUE
/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "disk_nuke"
	flags = FPRINT | TIMELESS
	var/respawned = 0

/obj/item/weapon/disk/nuclear/New()
	..()
	if(!nukedisk)
		nukedisk = src
	processing_objects.Add(src)

/obj/item/weapon/disk/nuclear/Destroy()
	processing_objects.Remove(src)
	..()
	replace_disk()

/**
 * NOTE: Don't change it to Destroy().
 */
/obj/item/weapon/disk/nuclear/Del()
	processing_objects.Remove(src)
	replace_disk()
	..()

/obj/item/weapon/disk/nuclear/proc/replace_disk()
	if(blobstart.len > 0 && !respawned && (nukedisk == src))
		var/picked_turf = get_turf(pick(blobstart))
		var/picked_area = formatLocation(picked_turf)
		var/log_message = "[type] has been destroyed. Creating one at"
		log_game("[log_message] [picked_area]")
		message_admins("[log_message] [formatJumpTo(picked_turf, picked_area)]")
		nukedisk = new /obj/item/weapon/disk/nuclear(picked_turf)
		respawned = 1

/obj/item/weapon/disk/nuclear/process()
	var/turf/T = get_turf(src)
	if(!T)
		var/atom/A
		for(A=src, A && A.loc && !isturf(A.loc), A=A.loc);  // semicolon is for the empty statement
		message_admins("\The [src] ended up in nullspace somehow, and has been replaced.[loc ? " It was contained in [A] when it was nullspaced." : ""]")
		qdel(src)
	if(T.z != map.zMainStation && T.z != map.zCentcomm)
		var/atom/A
		for(A=src, A && A.loc && !isturf(A.loc), A=A.loc);  // semicolon is for the empty statement
		message_admins("\The [src] ended up in a non-authorised z-Level somehow, and has been replaced.[loc ? " It was contained in [A] when it was moved." : ""]")
		qdel(src)
