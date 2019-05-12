/obj/structure/bed/guillotine
	name = "guillotine"
	icon = 'icons/obj/structures.dmi'
	icon_state = "guillotine_open"
	desc = "The most efficient way to remove one's head from one's shoulders."
	density = 1
	plane = ABOVE_HUMAN_PLANE
	layer = VEHICLE_LAYER
	mob_lock_type = /datum/locking_category/buckle/guillotine
	var/open = TRUE
	var/bladedown = FALSE
	var/mob/living/carbon/human/victim

/obj/structure/bed/guillotine/cultify()
	return

/obj/structure/bed/guillotine/New()
	..()
	verbs -= /obj/structure/bed/guillotine/verb/open_stocks

/obj/structure/bed/guillotine/Destroy()
	if(victim)
		qdel(victim)
		victim = null
	..()

/obj/structure/bed/guillotine/update_icon()
	if(open)
		icon_state = "guillotine_open"
	else
		icon_state = "guillotine_closed"
	if(bladedown)
		icon_state = "[icon_state]_bladedown"
	update_victim()

/obj/structure/bed/guillotine/proc/update_victim()
	overlays.len = 0
	if(!victim || bladedown)
		return
	if(victim.organs_by_name)
		var/datum/organ/external/head/HD = victim.get_organ(LIMB_HEAD)
		if(istype(HD) && ~HD.status & ORGAN_DESTROYED)
			var/image/victim_head = new
			victim_head.appearance = victim.appearance
			victim_head.transform = matrix()
			victim_head.dir = SOUTH
			var/icon/victim_head_icon = getFlatIcon(victim_head, cache = 0, exact = 1)
			victim_head_icon.Crop(1,23,32,32)
			victim_head.overlays.len = 0
			victim_head.underlays.len = 0
			victim_head.icon = victim_head_icon
			victim_head.layer = layer+1
			victim_head.plane = plane+1
			victim_head.pixel_x = 0
			victim_head.pixel_y = 4 * PIXEL_MULTIPLIER
			overlays += victim_head.appearance

/datum/locking_category/buckle/guillotine
	pixel_x_offset = -1 * PIXEL_MULTIPLIER
	pixel_y_offset = -8 * PIXEL_MULTIPLIER
	flags = CANT_BE_MOVED_BY_LOCKED_MOBS

/obj/structure/bed/guillotine/manual_unbuckle(mob/user)
	if(!is_locking(mob_lock_type))
		return

	if(user.size <= SIZE_TINY)
		to_chat(user, "<span class='warning'>You are too small to do that.</span>")
		return

	var/mob/M = get_locked(mob_lock_type)[1]
	if(M != user)
		if(!open)
			to_chat(user, "<span class='warning'>You can't pull \the [M] out of \the [src] while its stocks are closed.</span>")
			return
		else
			add_attacklogs(user, M, "unbuckled from a guillotine. (@[user.x], [user.y], [user.z])", src, admin_warn = FALSE)
			M.visible_message("<span class='notice'>\The [user] pulls [M] out of \the [src]!</span>",\
								"[user] pulls you out of \the [src].")
	else
		if(open)
			M.visible_message("<span class='notice'>\The [M] climbs out of \the [src].</span>",\
								"You climb out of \the [src].")
		else
			return
	unlock_atom(M)

	add_fingerprint(user)

/obj/structure/bed/guillotine/buckle_mob(mob/M, mob/user, var/do_after_done = FALSE)
	if(!Adjacent(user) || user.incapacitated() || istype(user, /mob/living/silicon/pai) || user == victim)
		return

	if(!ismob(M) || !M.Adjacent(user)  || M.locked_to)
		return

	if(!anchored)
		to_chat(user, "<span class='warning'>\The [src] needs to be anchored first.</span>")
		return
	if(bladedown)
		if(M == user)
			to_chat(user, "<span class='warning'>You can't fit into \the [src] while the blade is down.</span>")
		else
			to_chat(user, "<span class='warning'>You can't fit \the [M] into \the [src] while the blade is down.</span>")
		return
	if(!open)
		if(M == user)
			to_chat(user, "<span class='warning'>You can't climb into \the [src] while its stocks are closed.</span>")
		else
			to_chat(user, "<span class='warning'>You can't place \the [M] into \the [src] while its stocks are closed.</span>")
		return

	for(var/mob/living/L in get_locked(mob_lock_type))
		if(L.stat)
			to_chat(user, "<span class='warning'>There is still a body inside \the [src].</span>")
		else
			to_chat(user, "<span class='warning'>There is already someone inside \the [src].</span>")
		return

	if(user.size <= SIZE_TINY) //Fuck off mice
		to_chat(user, "<span class='warning'>You are too small to do that.</span>")
		return

	if(!ishuman(M))
		return

	if(M == user)
		M.visible_message("<span class='notice'>\The [M] climbs into \the [src]!</span>",\
							"You climb into \the [src].")
	else
		add_attacklogs(user, M, "dragged to a guillotine. (@[user.x], [user.y], [user.z])", src, admin_warn = FALSE)
		if(do_after_done)
			add_attacklogs(user, M, "SUCCESFULLY dragged and bucked to a guillotine. (@[user.x], [user.y], [user.z])", src, admin_warn = TRUE)
			M.visible_message("<span class='warning'>\The [M] is placed in \the [src] by \the [user]!</span>",\
								"<span class='danger'>You are placed in \the [src] by \the [user].</span>")
		else
			M.visible_message("<span class='warning'>\The [user] begins placing \the [M] into \the [src]...</span>",\
								"<span class='danger'>\The [user] begins placing you into \the [src]...</span>")
			if(do_after(user, M, 50))
				if(user.Adjacent(src))
					return .(M, user, TRUE)
				else
					return
			else
				return
	add_fingerprint(user)

	lock_atom(M, mob_lock_type)

/obj/structure/bed/guillotine/lock_atom(var/atom/movable/AM, var/datum/locking_category/category = /datum/locking_category)
	. = ..()
	if(.)
		victim = AM
		AM.dir = NORTH
		var/matrix/M = matrix()
		M.Turn(180)
		M.Scale(1,0.5)
		AM.transform = M
		update_icon()

/obj/structure/bed/guillotine/unlock_atom(var/atom/movable/AM)
	. = ..()
	if(.)
		AM.dir = SOUTH
		var/matrix/M = AM.transform
		M.Turn(180)
		if(!victim.lying)
			M.Scale(1,2)
		AM.transform = M
		victim = null
		update_icon()

/obj/structure/bed/guillotine/attackby(obj/item/weapon/W, mob/user)
	if(user == victim)
		return
	if(iswrench(W))
		wrenchAnchor(user)

/obj/structure/bed/guillotine/wrenchAnchor(var/mob/user)
	if(victim)
		to_chat(user, "<span class='warning'>You can't unsecure \the [src] from the floor while someone's inside it!</span>")
		return FALSE
	. = ..()

/obj/structure/bed/guillotine/AltClick(var/mob/user)
	if(!Adjacent(user) || user.incapacitated() || istype(user, /mob/living/silicon/pai) || user == victim)	//same restrictions as putting someone into it
		return
	if(bladedown)
		tie_blade(user)
	else
		untie_blade(user)

/obj/structure/bed/guillotine/proc/tie_blade(mob/user)
	user.visible_message("<span class='notice'>\The [user] ties \the [src]'s blade back into place.</span>",\
							"You tie \the [src]'s blade back into place.")
	bladedown = FALSE
	update_icon()

/obj/structure/bed/guillotine/proc/untie_blade(mob/user)
	user.attack_log += "\[[time_stamp()]\] [key_name(user)] has started to execute [key_name(victim)] with \the [src]."
	victim.attack_log += "\[[time_stamp()]\] [key_name(user)] has started to execute [key_name(victim)] with \the [src]."
	message_admins("\[[time_stamp()]\] [key_name(user)] has started to execute [key_name(victim)] with \the [src]. @[formatJumpTo(src)]")
	user.visible_message("<span class='danger'>\The [user] begins untying the rope holding \the [src]'s blade!</span>",\
							"You begin untying the rope holding \the [src]'s blade.")
	if(do_after(user, src, 100))
		update_icon()
		var/current_icon_state = icon_state
		icon_state = "[icon_state]_bladedown"
		flick("[current_icon_state]_dropping_1", src)
		spawn(4)
			if(victim)
				add_attacklogs(user, victim, "executed with a guillotine.", src, admin_warn = TRUE)
				if(victim.organs_by_name)
					var/datum/organ/external/head/H = victim.get_organ(LIMB_HEAD)
					if(istype(H) && ~H.status & ORGAN_DESTROYED)
						H.droplimb(1)
						playsound(src, 'sound/weapons/bloodyslice.ogg', 100, 1)
						blood_splatter(get_turf(src),victim,1)
			bladedown = TRUE
			update_icon()
			flick("[current_icon_state]_dropping_2", src)

/obj/structure/bed/guillotine/verb/close_stocks()
	set name = "Close stocks"
	set category = "Object"
	set src in range(1)

	var/mob/M = usr
	if(!M.Adjacent(src))
		return
	if(!M.dexterity_check())
		to_chat(usr, "You don't have the dexterity to do this!")
		return
	if(M.incapacitated())
		to_chat(M, "You can't do that while you're incapacitated!")
		return

	M.visible_message("<span class='warning'>\The [M] closes \the [src]'s stocks.</span>",\
						"You close \the [src]'s stocks.")
	open = FALSE
	update_icon()
	verbs -= /obj/structure/bed/guillotine/verb/close_stocks
	verbs += /obj/structure/bed/guillotine/verb/open_stocks

/obj/structure/bed/guillotine/verb/open_stocks()
	set name = "Open stocks"
	set category = "Object"
	set src in range(1)

	var/mob/M = usr
	if(!M.Adjacent(src))
		return
	if(!M.dexterity_check())
		to_chat(usr, "You don't have the dexterity to do this!")
		return
	if(M.incapacitated())
		to_chat(M, "You can't do that while you're incapacitated!")
		return
	if(M == victim)
		to_chat(M, "You can't open \the [src]'s stocks while you're inside them!")
		return

	M.visible_message("<span class='notice'>\The [M] opens \the [src]'s stocks.</span>",\
						"You open \the [src]'s stocks.")
	open = TRUE
	update_icon()
	verbs -= /obj/structure/bed/guillotine/verb/open_stocks
	verbs += /obj/structure/bed/guillotine/verb/close_stocks