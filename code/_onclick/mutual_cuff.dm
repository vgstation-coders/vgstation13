/obj/item/weapon/handcuffs/proc/apply_mutual_cuffs(mob/target, mob/user)
	if (restraint_resist_time > 0)
		if (restraint_apply_check(target, user))
			return attempt_apply_mutual_restraints(target, user)

/obj/item/weapon/handcuffs/proc/attempt_apply_mutual_restraints(mob/living/carbon/C, mob/living/carbon/user)
	if(!istype(C) || !istype(user))
		return FALSE

	if(restraint_apply_sound)
		playsound(src, restraint_apply_sound, 30, 1, -2)
	user.visible_message("<span class='danger'>\The [user] is trying to restrain \the [C] and himself together with the \the [src]!</span>",
						 "<span class='danger'>You try to tether yourself with \the [C] using \the [src]!</span>")

	if(do_after(user, C, restraint_apply_time))
		if(C.handcuffed || C.mutual_handcuffs)
			to_chat(user, "<span class='notice'>\The [C] is already handcuffed.</span>")
			return FALSE
		feedback_add_details("handcuffs", "[name]")

		user.visible_message("<span class='danger'>\The [user] has restrained \the [C] together with \the [src]!</span>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has restrained [C.name] ([C.ckey]) with \the [src](mutual cuff).</font>")
		C.attack_log += text("\[[time_stamp()]\] <font color='red'>Restrained with \the [src] by [user.name] ([user.ckey])(mutual cuff)</font>")
		log_attack("[user.name] ([user.ckey]) has restrained [C.name] ([C.ckey]) with \the [src] (mutual cuff)")

		var/obj/item/weapon/handcuffs/cuffs = src
		if(istype(src, /obj/item/weapon/handcuffs/cyborg))
			cuffs = new /obj/item/weapon/handcuffs/cyborg(get_turf(user))
		else
			user.drop_from_inventory(cuffs)

		//don't mess up the order of the following code
		C.mutual_handcuffed_to = user
		user.mutual_handcuffed_to = C

		cuffs.mutual_handcuffed_mobs.Add(user)
		cuffs.mutual_handcuffed_mobs.Add(C)

		user.equip_to_slot(cuffs, slot_handcuffed)
		C.equip_to_slot(cuffs, slot_handcuffed)

		user.mutual_handcuffed_to_event_key = user.on_moved.Add(C, "on_mutual_cuffed_move")
		C.mutual_handcuffed_to_event_key = C.on_moved.Add(user, "on_mutual_cuffed_move")

		cuffs.on_restraint_apply(C)
		cuffs.on_restraint_apply(user)
		return TRUE

/obj/item/weapon/handcuffs/on_restraint_removal(mob/living/carbon/C)
	remove_mutual_cuff_events(C)
	. = FALSE

/obj/item/weapon/handcuffs/proc/remove_mutual_cuff_events(mob/living/carbon/C)
	var/mob/living/carbon/handcuffed_to = C.mutual_handcuffed_to

	if (C && handcuffed_to)
		C.on_moved.Remove(C.mutual_handcuffed_to_event_key)
		handcuffed_to.on_moved.Remove(handcuffed_to.mutual_handcuffed_to_event_key)

		handcuffed_to.mutual_handcuffed_to = null
		C.mutual_handcuffed_to = null

		//important to call this AFTER setting null to the prev values
		C.u_equip(src)
		handcuffed_to.u_equip(src)

/mob/living/carbon/proc/on_mutual_cuffed_move()
	if (mutual_handcuffed_to && !mutual_handcuffed_to.Adjacent(src)) 
		mutual_handcuffed_to.Slip(2, 3)
		src.Slip(2, 3)
		src.forceMove(mutual_handcuffed_to.loc)
		sleep(2) //sleep as not to get too many nested calls


	