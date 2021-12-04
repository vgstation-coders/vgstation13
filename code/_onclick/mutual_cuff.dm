//first second and third can be different if one player is trying to cuff two others, or third can be equal to first or second if one player is cuffing himself to another
/obj/item/weapon/handcuffs/proc/apply_mutual_cuffs(mob/first, mob/second, mob/third)
	if (restraint_resist_time > 0)
		if (restraint_apply_check(first, second))
			return attempt_apply_mutual_restraints(first, second, third)


/obj/item/weapon/handcuffs/proc/attempt_apply_mutual_restraints(mob/living/carbon/first, mob/living/carbon/second, mob/living/carbon/third)
	if(!istype(first) || !istype(second) || !istype(third))
		return FALSE

	playtoolsound(src, 30, TRUE, -2)

	third.visible_message("<span class='danger'>\The [third] is trying to restrain \the [first] and \the [second] together with the \the [src]!</span>",
						 "<span class='danger'>You try to tether \the [first] and \the [second] using \the [src]!</span>")

	if(do_after(third, second, restraint_apply_time))
		if (!first || !third.Adjacent(first) || !second || !second.Adjacent(third))
			to_chat(third, "<span class='warning'>The target is too far away.</span>")
			return
		if(first.handcuffed || first.mutual_handcuffs || second.handcuffed || second.mutual_handcuffs)
			to_chat(third, "<span class='warning'>One of the them is already handcuffed.</span>")
			return FALSE
		feedback_add_details("handcuffs", "[name]")

		var/key_name_first = key_name(first)
		var/key_name_second = key_name(second)
		var/key_name_third = key_name(third)

		third.visible_message("<span class='danger'>\The [third] has restrained \the [first] and \the [second] together with \the [src]!</span>")
		third.attack_log += text("\[[time_stamp()]\] <font color='red'>Has restrained \the [key_name_first] and the \the [key_name_second] with \the [src](mutual cuff).</font>")
		first.attack_log += text("\[[time_stamp()]\] <font color='red'>Restrained with \the [src] by \the [key_name_third] (mutual cuff)</font>")
		second.attack_log += text("\[[time_stamp()]\] <font color='red'>Restrained with \the [src] by \the [key_name_third] (mutual cuff)</font>")
		log_attack("\The [key_name_third] has restrained \the [key_name_first] and \the [key_name_second] with \the [src] (mutual cuff)")

		var/obj/item/weapon/handcuffs/cuffs = src

		third.drop_from_inventory(cuffs)
		handle_mutual_cuff_event_logic(first, second, cuffs)
		return TRUE

/obj/item/weapon/handcuffs/proc/handle_mutual_cuff_event_logic(var/mob/living/carbon/first, var/mob/living/carbon/second, var/obj/item/weapon/handcuffs/cuffs)
	//don't mess up the order of the following code
	first.mutual_handcuffed_to = second
	second.mutual_handcuffed_to = first

	cuffs.mutual_handcuffed_mobs.Add(second)
	cuffs.mutual_handcuffed_mobs.Add(first)

	second.equip_to_slot(cuffs, slot_handcuffed)
	first.equip_to_slot(cuffs, slot_handcuffed)

	first.register_event(/event/z_transition, first, /mob/living/carbon/proc/z_transition_bringalong)
	second.register_event(/event/z_transition, second, /mob/living/carbon/proc/z_transition_bringalong)

	first.register_event(/event/post_z_transition, first, /mob/living/carbon/proc/post_z_transition_bringalong)
	second.register_event(/event/post_z_transition, second, /mob/living/carbon/proc/post_z_transition_bringalong)

	second.register_event(/event/moved, first, /mob/living/carbon/proc/on_mutual_cuffed_move)
	first.register_event(/event/moved, second, /mob/living/carbon/proc/on_mutual_cuffed_move)

	cuffs.on_restraint_apply(first)
	cuffs.on_restraint_apply(second)

/obj/item/weapon/handcuffs/on_restraint_removal(mob/living/carbon/C)
	remove_mutual_cuff_events(C)
	. = FALSE

/obj/item/weapon/handcuffs/proc/remove_mutual_cuff_events(mob/living/carbon/C)
	var/mob/living/carbon/handcuffed_to = C.mutual_handcuffed_to

	if (C && handcuffed_to)
		//remove from the list of cuffed mobs in the handcuff datum
		mutual_handcuffed_mobs.Remove(C)
		mutual_handcuffed_mobs.Remove(handcuffed_to)

		//remove from the event
		C.unregister_event(/event/moved, C, /mob/living/carbon/proc/on_mutual_cuffed_move)
		handcuffed_to.unregister_event(/event/moved, handcuffed_to, /mob/living/carbon/proc/on_mutual_cuffed_move)

		C.unregister_event(/event/z_transition, C, /mob/living/carbon/proc/z_transition_bringalong)
		handcuffed_to.unregister_event(/event/z_transition, handcuffed_to, /mob/living/carbon/proc/z_transition_bringalong)

		C.unregister_event(/event/post_z_transition, C, /mob/living/carbon/proc/post_z_transition_bringalong)
		handcuffed_to.unregister_event(/event/post_z_transition, handcuffed_to, /mob/living/carbon/proc/post_z_transition_bringalong)

		//reset the mob's vars
		handcuffed_to.mutual_handcuffed_to = null
		C.mutual_handcuffed_to = null

		//important to call this AFTER setting null to the prev values
		C.u_equip(src)
		handcuffed_to.u_equip(src)

/mob/living/carbon/proc/on_mutual_cuffed_move(atom/movable/mover)
	if (!isturf(loc) || (mutual_handcuffed_to && get_dist(mutual_handcuffed_to, src) > 3)) // We moved to a mech, a sleeper, or a locker, or got teleported
		var/obj/item/weapon/handcuffs/H = mutual_handcuffs
		if (!istype(H))
			return
		H.visible_message("<span class='warning'>\The [H] breaks!</span>")
		qdel(H)
		return
	if (mutual_handcuffed_to && !mutual_handcuffed_to.Adjacent(src) && (world.time > mutual_handcuff_forcemove_time + 2))
		mutual_handcuffed_to.Slip(2, 3)
		src.Slip(2, 3)
		src.forceMove(get_turf(mutual_handcuffed_to))
		//if pulling somebody who is buckled force them out of the buckled structure
		var/obj/structure/bed/locked_to = src.locked_to
		if (locked_to && istype(locked_to))
			locked_to.manual_unbuckle(src)
		//last_call as not to get too many nested calls
		mutual_handcuff_forcemove_time = world.time

/mob/living/carbon/proc/z_transition_bringalong(var/mob/user, var/from_z, var/to_z)
	if (mutual_handcuffed_to)
		// Remove the ability to bring his buddy, since his buddy already brought him here
		mutual_handcuffed_to.unregister_event(/event/z_transition, mutual_handcuffed_to, /mob/living/carbon/proc/z_transition_bringalong)
		mutual_handcuffed_to.unregister_event(/event/post_z_transition, mutual_handcuffed_to, /mob/living/carbon/proc/post_z_transition_bringalong)
		mutual_handcuffed_to.unregister_event(/event/moved, mutual_handcuffed_to, /mob/living/carbon/proc/on_mutual_cuffed_move)

/mob/living/carbon/proc/post_z_transition_bringalong(var/mob/user, var/from_z, var/to_z)
	if (mutual_handcuffed_to)
		// Re-adds the events on the fly once the transition is done.
		mutual_handcuffed_to.forceMove(get_turf(src))
		mutual_handcuffed_to.register_event(/event/z_transition, mutual_handcuffed_to, /mob/living/carbon/proc/z_transition_bringalong)
		mutual_handcuffed_to.register_event(/event/post_z_transition, mutual_handcuffed_to, /mob/living/carbon/proc/post_z_transition_bringalong)
		mutual_handcuffed_to.register_event(/event/moved, mutual_handcuffed_to, /mob/living/carbon/proc/on_mutual_cuffed_move)
