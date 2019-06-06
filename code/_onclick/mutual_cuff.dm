/datum/mutual_cuff_other_players
	var/is_selecting_other_player = FALSE
	var/mob/living/carbon/first_player_to_cuff = null
	var/mob/living/carbon/second_player_to_cuff = null
	var/last_call = 0

/obj/item/weapon/handcuffs/proc/apply_mutual_cuffs(mob/target, mob/user)
	if (restraint_resist_time > 0)
		if (restraint_apply_check(target, user))
			return attempt_apply_mutual_restraints(target, user)

/datum/mutual_cuff_other_players/proc/reset_vars()
	is_selecting_other_player = FALSE
	first_player_to_cuff = null
	second_player_to_cuff = null
	last_call = 0

/datum/mutual_cuff_other_players/proc/apply_mutual_cuffs_from_third_player(var/mob/target, var/mob/user, var/obj/item/weapon/handcuffs/handcuffs)
	//2. this gets executed on the second cycle
	if (is_selecting_other_player)
		//2. second player is set and checks are made if the first player is still in range
		second_player_to_cuff = target
		if (!first_player_to_cuff || !user.Adjacent(first_player_to_cuff))
			reset_vars()
			to_chat(user, "<span class='warning'>\The [first_player_to_cuff] is too far away.</span>")
			return
		if (handcuffs.restraint_resist_time > 0)
			//2. if all is well the first player gets cuffed to the second one
			if (handcuffs.restraint_apply_check(first_player_to_cuff, user) && handcuffs.restraint_apply_check(second_player_to_cuff, user))
				var/result = handcuffs.attempt_apply_mutual_restraints_from_third_player(first_player_to_cuff, second_player_to_cuff, user)
				reset_vars()
				return result
		return

	//1. selecting is set to true so next time this method is called only the above logic executes
	is_selecting_other_player = TRUE
	//1. the first player to cuff is set
	first_player_to_cuff = target
	to_chat(user, "<span class='notice'>Select another player to handcuff them to \the [first_player_to_cuff].</span>")
	user.visible_message("<span class='danger'>\The [user] is trying to restrain \the [first_player_to_cuff] with the \the [handcuffs]!</span>")
	//1. if the timer has passed without a second player being selected, then everything resets
	if(do_after(user, target, handcuffs.restraint_apply_time))
		//1. if second player has been selected don't do anything
		if (second_player_to_cuff)
			return
		to_chat(user, "<span class='warning'>No other target selected.</span>")
		reset_vars()
		return

/obj/item/weapon/handcuffs/proc/attempt_apply_mutual_restraints_from_third_player(mob/living/carbon/first, mob/living/carbon/second, mob/living/carbon/third)
	if(!istype(first) || !istype(second) || !istype(third))
		return FALSE

	if(restraint_apply_sound)
		playsound(src, restraint_apply_sound, 30, 1, -2)
	third.visible_message("<span class='danger'>\The [third] is trying to restrain \the [first] and \the [second] together with the \the [src]!</span>",
						 "<span class='danger'>You try to tether \the [first] and \the [second] using \the [src]!</span>")

	if(do_after(third, second, restraint_apply_time))
		//2. another range check just to be sure
		if (!first || !third.Adjacent(first))
			to_chat(third, "<span class='warning'>\The [first] is too far away.</span>")
			return
		if(first.handcuffed || first.mutual_handcuffs || second.handcuffed || second.mutual_handcuffs)
			to_chat(third, "<span class='warning'>One of the them is already handcuffed.</span>")
			return FALSE
		feedback_add_details("handcuffs", "[name]")

		third.visible_message("<span class='danger'>\The [third] has restrained \the [first] and \the [second] together with \the [src]!</span>")
		third.attack_log += text("\[[time_stamp()]\] <font color='red'>Has restrained [first.name] ([first.ckey]) and the \the [second.name] ([second.key]) with \the [src](mutual cuff).</font>")
		first.attack_log += text("\[[time_stamp()]\] <font color='red'>Restrained with \the [src] by [third.name] ([third.ckey])(mutual cuff)</font>")
		second.attack_log += text("\[[time_stamp()]\] <font color='red'>Restrained with \the [src] by [third.name] ([third.ckey])(mutual cuff)</font>")
		log_attack("key_name(third) has restrained key_name(first) and key_name(second) with \the [src] (mutual cuff)")

		var/obj/item/weapon/handcuffs/cuffs = src

		third.drop_from_inventory(cuffs)
		handle_mutual_cuff_event_logic(first, second, cuffs)
	
		return TRUE

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
		log_attack("key_name(user) has restrained [C.name] ([C.ckey]) with \the [src] (mutual cuff)")

		var/obj/item/weapon/handcuffs/cuffs = src

		user.drop_from_inventory(cuffs)

		handle_mutual_cuff_event_logic(C, user, cuffs)
		return TRUE

/obj/item/weapon/handcuffs/proc/handle_mutual_cuff_event_logic(var/mob/living/carbon/first, var/mob/living/carbon/second, var/obj/item/weapon/handcuffs/cuffs)
	//don't mess up the order of the following code
	first.mutual_handcuffed_to = second
	second.mutual_handcuffed_to = first

	cuffs.mutual_handcuffed_mobs.Add(second)
	cuffs.mutual_handcuffed_mobs.Add(first)

	second.equip_to_slot(cuffs, slot_handcuffed)
	first.equip_to_slot(cuffs, slot_handcuffed)

	second.mutual_handcuffed_to_event_key = second.on_moved.Add(first, "on_mutual_cuffed_move")
	first.mutual_handcuffed_to_event_key = first.on_moved.Add(second, "on_mutual_cuffed_move")

	cuffs.on_restraint_apply(first)
	cuffs.on_restraint_apply(second)

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
	if (mutual_handcuffed_to && !mutual_handcuffed_to.Adjacent(src) && (world.time > mutual_cuff_other_players.last_call + 2)) 
		mutual_handcuffed_to.Slip(2, 3)
		src.Slip(2, 3)
		src.forceMove(mutual_handcuffed_to.loc)
		//last_call as not to get too many nested calls
		mutual_cuff_other_players.last_call = world.time

	