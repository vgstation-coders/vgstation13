/obj/machinery/stasis_bed
	name = "stasis bed"
	desc = "A bed designed for long-term cryogenic stasis. Those who enter are not expected to return."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "body_scanner_0-r"
	density = TRUE
	anchored = TRUE
	var/mob/living/occupant = null

/obj/machinery/stasis_bed/Destroy()
	if(occupant)
		go_out()
	return ..()

/obj/machinery/stasis_bed/update_icon()
	if(occupant)
		icon_state = "body_scanner_1-r"
	else
		icon_state = "body_scanner_0-r"

/obj/machinery/stasis_bed/MouseDropTo(atom/movable/O, mob/user)
	if(!ismob(O))
		return
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O))
		return
	if(user.incapacitated() || user.lying)
		return
	if(!Adjacent(user) || !user.Adjacent(src))
		return

	var/mob/living/L = O
	if(!istype(L))
		return

	put_mob(L, user)

/obj/machinery/stasis_bed/proc/put_mob(mob/living/L, mob/user)
	if(!istype(L))
		return
	if(istype(L, /mob/living/simple_animal) || istype(L, /mob/living/silicon))
		to_chat(user, "<span class='warning'>\The [src] is not designed for this type of occupant.</span>")
		return
	if(L.anchored)
		return
	if(occupant)
		to_chat(user, "<span class='notice'>\The [src] is already occupied!</span>")
		return

	if(L != user && !L.client)
		var/warn = alert(user, "[L] has no active client. Placing a disconnected player into cryogenic stasis will permanently remove their character and belongings. Doing this maliciously against another player's wishes will lead to a ban. Are you sure you want to continue?", "Warning: Clientless Occupant", "Yes", "No")
		if(warn != "Yes")
			return
		if(occupant || !Adjacent(user) || !user.Adjacent(L) || L.anchored)
			return

	if(user.pulling == L)
		user.stop_pulling()
	L.forceMove(src)
	L.reset_view()
	occupant = L
	add_fingerprint(user)
	update_icon()

	if(L == user)
		visible_message("<span class='notice'>[user] climbs into \the [src].</span>")
	else
		visible_message("<span class='notice'>[user] places [L] into \the [src].</span>")

	if(L.client)
		var/confirm = alert(L, "Are you sure you want to enter cryogenic stasis? Your character and belongings will be permanently removed.", "Confirm Stasis", "Yes", "No")
		if(confirm != "Yes")
			go_out()
			return
		if(occupant != L)
			return
		message_admins("[key_name_admin(L)] has ended their round via \a [src] ([formatJumpTo(src, "JMP")]).")
		log_game("[key_name(L)] has ended their round via \a [src] at [x],[y],[z].")
		enter_stasis()
	else
		message_admins("[key_name_admin(user)] has placed clientless player [key_name_admin(L)] into \a [src] ([formatJumpTo(src, "JMP")]).")
		log_game("[key_name(user)] has placed clientless player [key_name(L)] into \a [src] at [x],[y],[z].")
		enter_stasis()

/obj/machinery/stasis_bed/proc/enter_stasis()
	if(!occupant)
		return
	visible_message("<span class='notice'>[occupant] enters cryogenic stasis, fading from the world...</span>")
	if(occupant.mind && occupant.mind.assigned_role && job_master)
		var/datum/job/J = job_master.GetJob(occupant.mind.assigned_role)
		if(J && J.current_positions > 0)
			J.current_positions--
	occupant.ghostize(0)
	qdel(occupant)
	occupant = null
	update_icon()

/obj/machinery/stasis_bed/proc/go_out()
	if(!occupant)
		return
	occupant.forceMove(loc)
	occupant.reset_view()
	occupant = null
	update_icon()

/obj/machinery/stasis_bed/attack_hand(mob/user)
	if(!occupant)
		to_chat(user, "<span class='notice'>\The [src] is unoccupied.</span>")
		return
	var/mob/living/old_occupant = occupant
	go_out()
	if(old_occupant == user)
		visible_message("<span class='notice'>[user] climbs out of \the [src].</span>")
	else
		visible_message("<span class='notice'>[user] removes [old_occupant] from \the [src].</span>")
