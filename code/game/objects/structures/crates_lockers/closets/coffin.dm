/obj/structure/closet/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"

	starting_materials = list(MAT_WOOD = 5*CC_PER_SHEET_MISC)
	var/mob_lock_type = /datum/locking_category/buckle/closet/coffin


/obj/structure/closet/coffin/Destroy()
	new /obj/item/stack/sheet/wood(loc,3) //This will result in 3 dropped if destroyed, or 5 if deconstructed
	if (is_locking(mob_lock_type)) //if someone is strapped in and this gets destroyed make them visible again
		var/mob/locked = get_locked(mob_lock_type)[1]	
		locked.alphas["coffin_invis"] = 255
		locked.handle_alpha()
	..()

/obj/structure/closet/coffin/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened

/datum/locking_category/buckle/closet/coffin
	flags = LOCKED_SHOULD_LIE

/obj/structure/closet/coffin/attack_hand(mob/user)
	if (src.opened && has_locked_mobs())
		to_chat(user, "<span class='warning'>You cannot close the lid while somebody is buckled into the coffin.</span>")
		return
	..()
	handle_user_visibility()

/obj/structure/closet/coffin/proc/has_locked_mobs()
	if (!is_locking(mob_lock_type))
		return FALSE
	var/mob/locked = get_locked(mob_lock_type)[1]
	return locked //no need to try to move if you are strapped in

/obj/structure/closet/coffin/AltClick(mob/user)
	handle_buckle(user)

/obj/structure/closet/coffin/proc/handle_buckle(var/mob/user) //needs src.opened otherwise bugs might occur because closet eats the items when its closed
	if (src.opened && is_locking(mob_lock_type)) //only unbuckle if you are buckled in in the first place
		manual_unbuckle(user)
		setDensity(FALSE) //this is needed for some reason 
		return
	var/mob/closet_dweller = locate() in src.loc
	if (src.opened && closet_dweller) //buckle only the mob inside the closet
		buckle_mob(closet_dweller, user)

/obj/structure/closet/coffin/proc/handle_user_visibility() //after each open/close action assert the correct user visibility
	if (!is_locking(mob_lock_type))
		return
	var/mob/locked = get_locked(mob_lock_type)[1]	
	if (src.opened)  
		locked.alphas["coffin_invis"] = 255
		locked.handle_alpha()
	else 
		locked.alphas["coffin_invis"] = 1
		locked.handle_alpha()

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

/obj/structure/closet/coffin/proc/buckle_mob(mob/M, mob/user)
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

	if (!M.alphas["coffin_invis"])
		M.alphas.Add("coffin_invis")
		M.alphas["coffin_invis"] = 255

	lock_atom(M, mob_lock_type)
	if(M.pulledby) //start pulling the coffin if somebody was pulling the person inside before
		M.pulledby.start_pulling(src)
