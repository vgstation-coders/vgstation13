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
	var/open_icon_state = "morgue0"
	dir = EAST
	density = 1
	var/obj/structure/m_tray/connected = null
	var/traytype = /obj/structure/m_tray
	var/alerts_inside = TRUE
	var/deconstructable = TRUE
	anchored = 1.0
	light_power = 0.5
	light_range = 1

/obj/structure/morgue/New()
	..()
	morgue_list += src
	update_icon()

/obj/structure/morgue/Destroy()
	..()
	morgue_list -= src

/obj/structure/morgue/update_icon()
	update_moody_light('icons/lighting/moody_lights.dmi', "overlay_morgue")
	if(connected)
		icon_state = "morgue0"
		return
	if(!contents.len)
		icon_state = "morgue1"
		return
	var/list/inside = recursive_type_check(src, /mob)
	if(!inside.len)
		icon_state = "morgue3" // no mobs at all, but objects inside
		return
	var/body_revivable = 0
	for(var/mob/living/body in inside)
		if(body.mind && body.mind.suiciding)
			continue
		if(body && body.client)
			icon_state = "morgue4" // clone that mofo
			return
		var/mob/dead/observer/ghost = mind_can_reenter(body.mind)
		if(ghost && ghost.get_top_transmogrification())
			body_revivable = 1
			icon_state = "morgue5" //dead and ghosted, but revivable if he re-enters body

	if(!body_revivable)
		icon_state = "morgue2" // dead no-client mob

/obj/structure/morgue/proc/update()
	update_icon()
	var/area/this_area = get_area(src)
	for(var/obj/machinery/holosign/morgue/sign in holosigns)
		var/area/sign_area = get_area(sign)
		if(this_area != sign_area)
			continue
		if(sign.should_update)
			continue
		sign.should_update = TRUE
		processing_objects += sign

/obj/structure/morgue/examine(mob/user)
	..()
	switch(icon_state)
		if("morgue2")
			to_chat(user, "<span class='info'>\The [src]'s light display indicates there is an unrecoverable corpse inside.</span>")
		if("morgue3")
			to_chat(user, "<span class='info'>\The [src]'s light display indicates there are items inside.</span>")
		if("morgue4")
			to_chat(user, "<span class='info'>\The [src]'s light display indicates there is a revivable body inside.</span>")
		if("morgue5")
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

/obj/structure/morgue/attack_robot(mob/living/silicon/robot/user)
	if(HAS_MODULE_QUIRK(user, MODULE_CAN_HANDLE_MEDICAL))
		attack_hand(user)

/obj/structure/morgue/attack_hand(mob/user as mob)
	if (connected)
		close_up()
	else
		open_up()
	src.add_fingerprint(user)
	update()
	return

/datum/locking_category/morgue_tray

/obj/structure/morgue/proc/open_up()
	playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
	connected = new traytype(loc)
	step(connected, src.dir)
	var/turf/T = get_step(src, src.dir)
	if(T.contents.Find(connected))
		src.connected.connected = src //like a dog chasing it's own tail
		lock_atom(connected, /datum/locking_category/morgue_tray)
		src.icon_state = open_icon_state
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(src.connected.loc)
		connected.dir = src.dir
	else
		QDEL_NULL(connected)

/obj/structure/morgue/proc/close_up()
	if(!connected)
		return
	for(var/atom/movable/A as mob|obj in connected.loc)
		if(istype(A, /mob/living/simple_animal/scp_173)) //I have no shame. Until someone rewrites this shitcode extroadinaire, I'll just snowflake over it
			continue
		if(!A.anchored)
			A.forceMove(src)	
	unlock_atom(connected)			
	QDEL_NULL(connected)
	
	if(alerts_inside)
		for(var/mob/M in recursive_type_check(src, /mob))
			if(M.mind && !M.client) //!M.client = mob has ghosted out of their body
				var/mob/dead/observer/ghost = mind_can_reenter(M.mind)
				if(ghost)
					var/mob/ghostmob = ghost.get_top_transmogrification()
					if(ghostmob)
						to_chat(ghostmob, "<span class='interface'><span class='big bold'>Your corpse has been placed into a morgue tray.</span> \
							Re-entering your corpse will cause the tray's lights to turn green, which will let people know you're still there, and just maybe improve your chances of being revived. No promises.</span>")

/obj/structure/morgue/attackby(obj/item/P, mob/user)
	if(deconstructable)
		if(iscrowbar(P))
			user.visible_message("<span class='notice'>\The [user] begins dismantling \the [src].</span>", "<span class='notice'>You begin dismantling \the [src].</span>")
			if(do_after(user, src, 50))
				user.visible_message("<span class='notice'>\The [user] dismantles \the [src].</span>", "<span class='notice'>You dismantle \the [src].</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				new /obj/structure/closet/body_bag(src.loc)
				new /obj/item/stack/sheet/metal(src.loc, 5)
				for (var/atom/movable/content in contents)
					content.forceMove(src.loc)
				qdel(src)
		if(P.is_wrench(user))
			P.playtoolsound(src, 50)
			if(dir == 4)
				dir = 8
			else
				dir = 4
	if (istype(P, /obj/item/weapon/pen))
		set_tiny_label(user, " - '", "'", maxlength=32)
	src.add_fingerprint(user)

/obj/structure/morgue/relaymove(mob/user as mob)
	if (user.isUnconscious())
		return
	open_up()

/obj/structure/morgue/on_login(var/mob/M)
	if(alerts_inside)
		update()
		if(M.mind && !M.client) //!M.client = mob has ghosted out of their body
			var/mob/dead/observer/ghost = mind_can_reenter(M.mind)
			if(ghost)
				var/mob/ghostmob = ghost.get_top_transmogrification()
				if(ghostmob)
					to_chat(ghostmob, "<span class='interface'><span class='big bold'>Your corpse has been placed into a morgue tray.</span> \
						Re-entering your corpse will cause the tray's lights to turn green, which will let people know you're still there, and just maybe improve your chances of being revived. No promises.</span>")

/obj/structure/morgue/on_logout(var/mob/M)
	if(alerts_inside)
		spawn(1) //delay here because the ghostmob doesn't exist immediately after ghosting
			update()

/obj/structure/morgue/Destroy()
	if(connected)
		unlock_atom(connected)
		qdel(connected)
	. = ..()

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
	layer = TABLE_LAYER

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

/obj/structure/m_tray/attack_robot(mob/living/silicon/robot/user)
	if(HAS_MODULE_QUIRK(user, MODULE_CAN_HANDLE_MEDICAL))
		attack_hand(user)

/obj/structure/m_tray/MouseDropTo(atom/movable/O as mob|obj, mob/user as mob)
	if (!istype(O) || O.anchored || !user.Adjacent(O) || !user.Adjacent(src) || user.contents.Find(O))
		return
	if (!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	if (!iscarbon(user) && !isrobot(user))
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

/obj/structure/morgue/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	icon_state = "crema1"
	open_icon_state = "crema0"
	traytype = /obj/structure/m_tray/crematorium
	light_power = 0
	light_range = 0
	alerts_inside = FALSE
	deconstructable = FALSE
	var/cremating = 0
	var/id = 1
	var/locked = 0

/obj/structure/morgue/crematorium/update_icon()
	return

/obj/structure/morgue/crematorium/update()
	if (cremating)
		icon_state = "crema_active"
		return
	if (contents.len > 0)
		icon_state = "crema2"
	else
		icon_state = "crema1"

/obj/structure/morgue/crematorium/attack_hand(mob/user as mob)
//	if (cremating) AWW MAN! THIS WOULD BE SO MUCH MORE FUN ... TO WATCH
//		user.show_message("<span class='warning'>Uh-oh, that was a bad idea.</span>", 1)
//		to_chat(usr, "Uh-oh, that was a bad idea.")
//		src:loc:poison += 20000000
//		src:loc:firelevel = src:loc:poison
//		return
	if (cremating)
		to_chat(usr, "<span class='warning'>It's locked.</span>")
		return
	..()

/obj/structure/morgue/crematorium/proc/cremate(mob/user)
//	for(var/obj/machinery/crema_switch/O in src) //trying to figure a way to call the switch, too drunk to sort it out atm
//		if(var/on == 1)
//		return
	if(cremating)
		return //don't let you cremate something twice or w/e

	if(contents.len <= 0)
		visible_message("<span class='warning'>You hear a hollow crackle.</span>")
		return

	else
		var/inside = get_contents_in_object(src)

		if (locate(/obj/item/weapon/disk/nuclear) in inside)
			to_chat(user, "<SPAN CLASS='warning'>You get the feeling that you shouldn't cremate one of the items in the cremator.</SPAN>")
			return
		if(locate(/mob/living/simple_animal/scp_173) in inside)
			to_chat(user, "<span class='warning'>You try to toggle the crematorium on, but all you hear is scraping stone.</span>")
			return
		visible_message("<span class='warning'>You hear a roar as the crematorium activates.</span>", drugged_message = "<span class='notice'>You hear chewing as the crematorium consumes its meal.</span>")
		for (var/mob/M in viewers(src))
			if(M.hallucinating())
				M << 'sound/items/eatfood.ogg'

		cremating = 1
		update()

		for (var/mob/living/M in inside)
			if (M.stat!=2)
				M.audible_scream()
			//Logging for this causes runtimes resulting in the cremator locking up. Commenting it out until that's figured out.
			//M.attack_log += "\[[time_stamp()]\] Has been cremated by <b>[user]/[user.ckey]</b>" //No point in this when the mob's about to be qdeleted
			//user.attack_log +="\[[time_stamp()]\] Cremated <b>[M]/[M.ckey]</b>"
			//log_attack("\[[time_stamp()]\] <b>[user]/[user.ckey]</b> cremated <b>[M]/[M.ckey]</b>")
			M.death(1)
			M.ghostize()
			QDEL_NULL(M)

		for (var/obj/O in inside) //obj instead of obj/item so that bodybags and ashes get destroyed. We dont want tons and tons of ash piling up
			qdel(O)

		inside = null

		new /obj/effect/decal/cleanable/ash(src)
		sleep(30)
		cremating = 0
		update()
		playsound(src, 'sound/machines/ding.ogg', 50, 1)


/*
 * Crematorium tray
 */
/obj/structure/m_tray/crematorium
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon_state = "cremat"

/obj/machinery/crema_switch/attack_hand(mob/user as mob)
	if (allowed(user))
		playsound(src,'sound/misc/click.ogg',30,0,-1)
		for (var/obj/structure/morgue/crematorium/C in morgue_list)
			if (C.id == id)
				C.cremate(user)
	else
		playsound(src,'sound/machines/denied.ogg',30,0,-1)
		to_chat(user, "<SPAN CLASS='alert'>Access denied.</SPAN>")
