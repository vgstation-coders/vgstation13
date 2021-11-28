/obj/structure/closet/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"

	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 2

	starting_materials = list(MAT_WOOD = 5*CC_PER_SHEET_MISC)
	var/mob_lock_type = /datum/locking_category/buckle/closet/coffin
	var/mob/living/mob_inside_thats_buckled = null


/obj/structure/closet/coffin/Destroy()
	if (mob_inside_thats_buckled)
		if (loc)
			mob_inside_thats_buckled.forceMove(loc)
	mob_inside_thats_buckled = null
	new /obj/item/stack/sheet/wood(loc,3) //This will result in 3 dropped if destroyed, or 5 if deconstructed
	if (is_locking(mob_lock_type)) //if someone is strapped in and this gets destroyed make them visible again
		var/mob/locked = get_locked(mob_lock_type)[1]
		locked.alphas["coffin_invis"] = 255
		locked.handle_alpha()
	..()

/obj/structure/closet/coffin/lock_atom(atom/movable/AM)
	. = ..()
	if(!.)
		return
	if(ismob(AM))
		var/mob/dude = AM
		dude.throw_alert(SCREEN_ALARM_BUCKLE, /obj/abstract/screen/alert/object/buckled/coffin, new_master = src)

/obj/structure/closet/coffin/unlock_atom(var/atom/movable/AM)
	if(current_glue_state != GLUE_STATE_NONE && ismob(AM))
		return FALSE
	. = ..()
	if(.)
		if(ismob(AM))
			var/mob/dude = AM
			dude.clear_alert(SCREEN_ALARM_BUCKLE)

/obj/structure/closet/coffin/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened

/datum/locking_category/buckle/closet/coffin
	flags = LOCKED_SHOULD_LIE


/obj/structure/closet/coffin/proc/has_locked_mobs()
	if (!is_locking(mob_lock_type))
		return FALSE
	var/mob/locked = get_locked(mob_lock_type)[1]
	return locked //no need to try to move if you are strapped in

/obj/structure/closet/coffin/MouseDropTo(atom/movable/O, mob/user, var/needs_opened = 1, var/show_message = 1, var/move_them = 1)
	if (is_locking(mob_lock_type))
		return 0
	. = ..()
	if (. && isliving(O))
		buckle_mob(O, user)

/obj/structure/closet/coffin/MouseDropFrom(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	unbuckle_to(over_location)

/obj/structure/closet/coffin/proc/unbuckle_to(var/turf/over_location)
	if (opened && !is_locking(mob_lock_type))
		return
	if (!opened && !mob_inside_thats_buckled)
		return
	if (!isliving(usr))
		return
	var/mob/living/user = usr
	if (user.incapacitated() || !Adjacent(user) || !over_location.Adjacent(user))
		return

	if (!opened)
		open(user)

	var/mob/living/occupant = get_locked(mob_lock_type)[1]

	if (manual_unbuckle(user))
		setDensity(FALSE)
		occupant.forceMove(over_location)

/obj/structure/closet/coffin/open(mob/user)
	. = ..()
	if (. && mob_inside_thats_buckled && (mob_inside_thats_buckled.loc == loc))
		buckle_mob(mob_inside_thats_buckled, user, FALSE)
	mob_inside_thats_buckled = null

/obj/structure/closet/coffin/close(mob/user)
	if(!opened)
		return 0
	if(!can_close())
		return 0

	if (is_locking(mob_lock_type))
		var/mob/living/occupant = get_locked(mob_lock_type)[1]
		unlock_atom(occupant)
		mob_inside_thats_buckled = occupant

	return ..()

/obj/structure/closet/coffin/relaymove(mob/user)
	if (has_locked_mobs())
		return
	..()

/obj/structure/closet/coffin/proc/manual_unbuckle(var/mob/user)
	if(user.size <= SIZE_TINY)
		to_chat(user, "<span class='warning'>You are too small to do that.</span>")
		return FALSE

	if(is_locking(mob_lock_type))
		add_fingerprint(user)

		var/mob/M = get_locked(mob_lock_type)[1]
		var/success = unlock_atom(M)

		if(M != user)
			if(!success)
				user.delayNextAttack(8)
				M.visible_message("<span class='warning'>[user] struggles in vain trying to pull [M] off \the [src].</span>")
				return FALSE
			M.visible_message(
				"<span class='notice'>[M] was unbuckled by [user]!</span>",
				"You were unbuckled from \the [src] by [user].",
				"You hear metal clanking.")
		else
			if(!success)
				user.delayNextAttack(8)
				M.visible_message("<span class='warning'>[user] struggles in vain trying to pull themselves off \the [src].</span>")
				return FALSE
			M.visible_message(
				"<span class='notice'>[M] unbuckled \himself!</span>",
				"You unbuckle yourself from \the [src].",
				"You hear metal clanking.")
		playsound(src, 'sound/misc/buckle_unclick.ogg', 50, 1)
		return TRUE

/obj/structure/closet/coffin/proc/buckle_mob(mob/M, mob/user, var/messages = TRUE)
	if(!Adjacent(user) || user.incapacitated() || istype(user, /mob/living/silicon/pai))
		return

	if(!ismob(M) || (M.loc != src.loc)  || M.locked_to)
		return

	for(var/mob/living/L in get_locked(mob_lock_type))
		to_chat(user, "<span class='warning'>Somebody else is already buckled into \the [src]!</span>")
		return

	if(user.size <= SIZE_TINY) //Fuck off mice
		to_chat(user, "<span class='warning'>You are too small to do that.</span>")
		return

	if(isanimal(M))
		if(M.size <= SIZE_TINY) //Fuck off mice
			to_chat(user, "<span class='warning'>The [M] is too small to buckle in.</span>")
			return

	if(istype(M, /mob/living/carbon/slime))
		to_chat(user, "<span class='warning'>The [M] is too squishy to buckle in.</span>")
		return

	if (messages)
		if(M == user)
			user.stop_pulling() // stop pulling whatever you are pulling if you buckle yourself in
			M.visible_message(\
				"<span class='notice'>\The [M] buckles in!</span>",\
				"You buckle yourself to [src].",\
				"You hear metal clanking.")
		else
			M.visible_message(\
				"<span class='notice'>\The [M] is buckled in to [src] by [user.name]!</span>",\
				"You are buckled in to [src] by [user.name].",\
				"You hear metal clanking.")

		playsound(src, 'sound/misc/buckle_click.ogg', 50, 1)
	add_fingerprint(user)

	lock_atom(M, mob_lock_type)
	if(M.pulledby) //start pulling the coffin if somebody was pulling the person inside before
		M.pulledby.start_pulling(src)
