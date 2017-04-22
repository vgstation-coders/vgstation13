/* Morgue stuff
 * Contains:
 *		Morgue
 *		Morgue trays
 *		Creamatorium
 *		Creamatorium trays
 */

/*
 * Morgue
 */

/obj/structure/morgue
	name = "morgue"
	desc = "Used to keep bodies in until someone fetches them."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	dir = EAST
	density = 1
	var/obj/structure/m_tray/connected = null
	anchored = 1.0

/obj/structure/morgue/proc/update()
	if(connected)
		icon_state = "morgue0"
	else
		if(contents.len > 0)
			var/list/inside = recursive_type_check(src, /mob)
			if(!inside.len)
				icon_state = "morgue3" // no mobs at all, but objects inside
			else
				for(var/mob/living/body in inside)
					if(body && body.client && !body.suiciding)
						icon_state = "morgue4" // clone that mofo
						return
				icon_state = "morgue2" // dead no-client mob
		else
			icon_state = "morgue1"

/obj/structure/morgue/examine(mob/user)
	..()
	switch(icon_state)
		if("morgue2")
			to_chat(user, "<span class='info'>\The [src]'s light display indicates there is an unrecoverable corpse inside.</span>")
		if("morgue3")
			to_chat(user, "<span class='info'>\The [src]'s light display indicates there are items inside.</span>")
		if("morgue4")
			to_chat(user, "<span class='info'>\The [src]'s light display indicates there is a potential clone candidate inside.</span>")

/obj/structure/morgue/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A in src)
				A.forceMove(src.loc)
				A.ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A in src)
					A.forceMove(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(5))
				for(var/atom/movable/A in src)
					A.forceMove(src.loc)
					A.ex_act(severity)
				qdel(src)
				return

/obj/structure/morgue/alter_health() //???????????????
	return src.loc

/obj/structure/morgue/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/morgue/attack_hand(mob/user as mob)
	if (connected)
		close_up()
	else
		open_up()
	src.add_fingerprint(user)
	update()
	return

/obj/structure/morgue/proc/open_up()
	playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
	connected = new /obj/structure/m_tray(loc)
	connected.layer = OBJ_LAYER
	step(connected, src.dir)
	var/turf/T = get_step(src, src.dir)
	if(T.contents.Find(connected))
		src.connected.connected = src //like a dog chasing it's own tail
		src.icon_state = "morgue0"
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(src.connected.loc)
		connected.icon_state = "morguet"
		connected.dir = src.dir
	else
		qdel(connected)
		connected = null

/obj/structure/morgue/proc/close_up()
	if(!connected)
		return
	for(var/atom/movable/A as mob|obj in connected.loc)
		if(istype(A, /mob/living/simple_animal/sculpture)) //I have no shame. Until someone rewrites this shitcode extroadinaire, I'll just snowflake over it
			continue
		if(!A.anchored)
			A.forceMove(src)
			if(ismob(A))
				var/mob/M = A
				if(M.mind && !M.client) //!M.client = mob has ghosted out of their body
					var/mob/dead/observer/ghost = get_ghost_from_mind(M.mind)
					if(ghost && ghost.client)
						to_chat(ghost, "<span class='interface'><span class='big bold'>Your corpse has been placed into a morgue tray.</span> \
							Re-entering your corpse will cause the tray's lights to turn green, which will let people know you're still there, and just maybe improve your chances of being revived. No promises.</span>")
	qdel(connected)

/obj/structure/morgue/attackby(P as obj, mob/user as mob)
	if(iscrowbar(P)&&!contents.len)
		if(do_after(user, src,50))
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			new /obj/structure/closet/body_bag(src.loc)
			new /obj/item/stack/sheet/metal(src.loc,5)
			qdel(src)
	if(iswrench(P))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(dir==4)
			dir=8
		else
			dir=4
	if (istype(P, /obj/item/weapon/pen))
		set_tiny_label(user, " - '", "'")
	src.add_fingerprint(user)

/obj/structure/morgue/relaymove(mob/user as mob)
	if (user.isUnconscious())
		return
	open_up()

/obj/structure/morgue/on_login(var/mob/M)
	update()
	if(M.mind && !M.client) //!M.client = mob has ghosted out of their body
		var/mob/dead/observer/ghost = get_ghost_from_mind(M.mind)
		if(ghost && ghost.client)
			to_chat(ghost, "<span class='interface'><span class='big bold'>Your corpse has been placed into a morgue tray.</span> \
				Re-entering your corpse will cause the tray's lights to turn green, which will let people know you're still there, and just maybe improve your chances of being revived. No promises.</span>")

/obj/structure/morgue/on_logout(var/mob/M)
	update()

/obj/structure/morgue/Destroy()
	. = ..()
	if(connected)
		qdel(connected) //references get cleared in the tray's Destroy()

/*
 * Morgue tray
 */
/obj/structure/m_tray
	name = "morgue tray"
	desc = "Apply corpse before closing."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morguet"
	density = 1
	var/obj/structure/morgue/connected = null
	anchored = 1.0

/obj/structure/m_tray/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if (istype(mover, /obj/item/weapon/dummy))
		return 1
	else
		return ..()

/obj/structure/m_tray/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/m_tray/attack_hand(mob/user as mob)
	if(connected)
		connected.close_up()
	else
		qdel(src) //this should not happen but if it does happen we should not be here

/obj/structure/m_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!istype(O) || O.anchored || !Adjacent(user) || !Adjacent(O) || user.contents.Find(O))
		return
	if (!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	O.forceMove(src.loc)
	if (user != O)
		visible_message("<span class='warning'>[user] stuffs [O] into [src]!</span>")

/obj/structure/m_tray/Destroy()
	. = ..()
	if(connected)
		connected.connected = null
		connected.update()
		connected = null

/*
 * Crematorium
 */

/obj/structure/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema1"
	density = 1
	var/obj/structure/c_tray/connected = null
	anchored = 1.0
	var/cremating = 0
	var/id = 1
	var/locked = 0

/obj/structure/crematorium/proc/update()
	if (cremating)
		icon_state = "crema_active"
		return

	if (contents.len > 0)
		icon_state = "crema2"
	else
		icon_state = "crema1"

/obj/structure/crematorium/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(src.loc)
				ex_act(severity)
			qdel(src)
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					ex_act(severity)
				qdel(src)
		if(3.0)
			if (prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					ex_act(severity)
				qdel(src)

/obj/structure/crematorium/alter_health()
	return src.loc

/obj/structure/crematorium/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/crematorium/attack_hand(mob/user as mob)
//	if (cremating) AWW MAN! THIS WOULD BE SO MUCH MORE FUN ... TO WATCH
//		user.show_message("<span class='warning'>Uh-oh, that was a bad idea.</span>", 1)
//		to_chat(usr, "Uh-oh, that was a bad idea.")
//		src:loc:poison += 20000000
//		src:loc:firelevel = src:loc:poison
//		return
	if (cremating)
		to_chat(usr, "<span class='warning'>It's locked.</span>")
		return
	if ((src.connected) && (src.locked == 0))
		for(var/atom/movable/A as mob|obj in src.connected.loc)
			if (!( A.anchored ))
				A.forceMove(src)
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		qdel(src.connected)
		src.connected = null
	else if (src.locked == 0)
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		src.connected = new /obj/structure/c_tray( src.loc )
		step(src.connected, SOUTH)
		src.connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, SOUTH)
		if (T.contents.Find(src.connected))
			src.connected.connected = src
			src.icon_state = "crema0"
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(src.connected.loc)
			src.connected.icon_state = "cremat"
		else
			qdel(src.connected)
			src.connected = null
	src.add_fingerprint(user)
	update()

/obj/structure/crematorium/attackby(P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/pen))
		set_tiny_label(user, " - '", "'")
	src.add_fingerprint(user)

/obj/structure/crematorium/relaymove(mob/user as mob)
	if (user.stat || locked)
		return
	src.connected = new /obj/structure/c_tray( src.loc )
	step(src.connected, SOUTH)
	src.connected.layer = OBJ_LAYER
	var/turf/T = get_step(src, SOUTH)
	if (T.contents.Find(src.connected))
		src.connected.connected = src
		src.icon_state = "crema0"
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(src.connected.loc)
			//Foreach goto(106)
		src.connected.icon_state = "cremat"
	else
		qdel(src.connected)
		src.connected = null

/obj/structure/crematorium/proc/cremate(mob/user)
//	for(var/obj/machinery/crema_switch/O in src) //trying to figure a way to call the switch, too drunk to sort it out atm
//		if(var/on == 1)
//		return
	if(cremating)
		return //don't let you cremate something twice or w/e

	if(contents.len <= 0)
		for (var/mob/M in viewers(src))
			M.show_message("<span class='warning'>You hear a hollow crackle.</span>", 1)
			return

	else
		var/inside = get_contents_in_object(src)

		if (locate(/obj/item/weapon/disk/nuclear) in inside)
			to_chat(user, "<SPAN CLASS='warning'>You get the feeling that you shouldn't cremate one of the items in the cremator.</SPAN>")
			return
		if(locate(/mob/living/simple_animal/sculpture) in inside)
			to_chat(user, "<span class='warning'>You try to toggle the crematorium on, but all you hear is scrapping stone.</span>")
			return
		for (var/mob/M in viewers(src))
			if(!M.hallucinating())
				M.show_message("<span class='warning'>You hear a roar as the crematorium activates.</span>", 1)
			else
				M.show_message("<span class='notice'>You hear chewing as the crematorium consumes its meal.</span>", 1)
				M << 'sound/items/eatfood.ogg'

		locked = 1
		cremating = 1
		update()

		for (var/mob/living/M in inside)
			if (M.stat!=2)
				M.emote("scream",,, 1)
			//Logging for this causes runtimes resulting in the cremator locking up. Commenting it out until that's figured out.
			//M.attack_log += "\[[time_stamp()]\] Has been cremated by <b>[user]/[user.ckey]</b>" //No point in this when the mob's about to be qdeleted
			//user.attack_log +="\[[time_stamp()]\] Cremated <b>[M]/[M.ckey]</b>"
			//log_attack("\[[time_stamp()]\] <b>[user]/[user.ckey]</b> cremated <b>[M]/[M.ckey]</b>")
			M.death(1)
			M.ghostize()
			qdel(M)
			M = null

		for (var/obj/O in inside) //obj instead of obj/item so that bodybags and ashes get destroyed. We dont want tons and tons of ash piling up
			qdel(O)

		inside = null

		new /obj/effect/decal/cleanable/ash(src)
		sleep(30)
		cremating = 0
		update()
		locked = 0
		playsound(get_turf(src), 'sound/machines/ding.ogg', 50, 1)


/*
 * Crematorium tray
 */
/obj/structure/c_tray
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "cremat"
	density = 1
	var/obj/structure/crematorium/connected = null
	anchored = 1.0

/obj/structure/c_tray/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if (istype(mover, /obj/item/weapon/dummy))
		return 1
	else
		return ..()

/obj/structure/c_tray/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/c_tray/attack_hand(mob/user as mob)
	if (src.connected)
		for(var/atom/movable/A as mob|obj in src.loc)
			if (!( A.anchored ))
				A.forceMove(src.connected)
		src.connected.connected = null
		src.connected.update()
		add_fingerprint(user)
		//SN src = null
		qdel(src)

/obj/structure/c_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return
	if (!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	O.forceMove(src.loc)
	if (user != O)
		for(var/mob/B in viewers(user, 3))
			if ((B.client && !( B.blinded )))
				to_chat(B, text("<span class='warning'>[] stuffs [] into []!</span>", user, O, src))

/obj/machinery/crema_switch/attack_hand(mob/user as mob)
	if (allowed(user))
		for (var/obj/structure/crematorium/C in world)
			if (C.id == id)
				C.cremate(user)
	else
		to_chat(user, "<SPAN CLASS='alert'>Access denied.</SPAN>")
