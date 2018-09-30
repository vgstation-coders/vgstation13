/obj/item/gum
	name = "chewing gum"
	desc = "A delicious treat."
	icon = 'icons/obj/items.dmi'
	icon_state = "gum_wrapped"
	w_class = W_CLASS_TINY
	var/wrapped = TRUE
	var/chewed = FALSE
	var/chem_volume = 35
	var/replacement_chem_volume = 15
	var/image/color_overlay
	var/atom/target = null

/obj/item/gum/New()
	..()
	flags |= NOREACT //so it doesn't react until you chew it
	create_reagents(chem_volume)
	reagents.add_reagent(SUGAR, chem_volume)	//very sweet
	color_overlay = image('icons/obj/items.dmi', src, "gum_chewed_full")

/obj/item/gum/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/gum/examine(mob/user)
	..()
	if(chewed)
		to_chat(user, "\The [src] looks chewed up.")

/obj/item/gum/update_icon()
	if(wrapped)
		icon_state = "gum_wrapped"
	else if(!chewed)
		icon_state = "gum"
	else
		overlays.len = 0
		icon_state = "gum_chewed_empty"
		if(reagents.total_volume)
			color_overlay.alpha = 255 * (reagents.total_volume / chem_volume)
			overlays += color_overlay

/obj/item/gum/equipped(mob/M, slot)
	var/mob/living/carbon/C = M
	if(!istype(C))
		return
	if(slot == slot_wear_mask)
		chew(C)

/obj/item/gum/attack(mob/M, mob/user, def_zone)
	return

/obj/item/gum/preattack(atom/A, mob/user, proximity_flag, click_parameters)
	if (!proximity_flag)
		return 0
	return ..()

/obj/item/gum/afterattack(obj/item/weapon/reagent_containers/glass/glass, mob/user, flag)
	..()
	if(wrapped)
		return
	if(istype(glass))	//You can dip gum into beakers and beaker subtypes
		if(transfer_some_reagents(glass))	//If reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [glass].</span>")
		else	//If not, either the beaker was empty, or the gum was full
			if(!glass.reagents.total_volume) //Only show an explicit message if the beaker was empty, you can't tell gum is "full"
				to_chat(user, "<span class='warning'>\The [glass] is empty.</span>")
				return

/obj/item/gum/proc/transfer_some_reagents(obj/item/weapon/reagent_containers/R, var/amount, var/log = FALSE, var/user)
	if(!amount)
		amount = replacement_chem_volume
	reagents.remove_reagent(SUGAR, amount)
	var/transferred = R.reagents.trans_to(src, amount, log_transfer = log, whodunnit = user)
	if(transferred)
		replacement_chem_volume = max(0, replacement_chem_volume - transferred)
		return transferred

/obj/item/gum/proc/explode(var/location)
	if(!target)
		target = get_holder_at_turf_level(src)
	if(!target)
		target = src
	if(location)
		explosion(location, -1, -1, 2, 3)
	if(target)
		if (istype(target, /turf/simulated/wall))
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else
			target.ex_act(1)
		if(isobj(target))
			if(target)
				qdel(target)
				target = null
	qdel(src)

/obj/item/gum/proc/chew(mob/user)
	if(!chewed)
		flags &= ~NOREACT //Allow reagents to react after being chewed
		reagents.handle_reactions()
		processing_objects.Add(src)
		chewed = TRUE
	user.visible_message("\The [user] puts \the [src] in \his mouth.","You start chewing \the [src].")
	update_icon()

/obj/item/gum/process()
	var/mob/living/M = get_holder_of_type(src,/mob/living)
	if(reagents && reagents.total_volume)	//Check if it has any reagents at all
		if(iscarbon(M) && ((src == M.wear_mask) || (loc == M.wear_mask))) //If it's in the human/monkey mouth, transfer reagents to the mob
			if(M.reagents.has_reagent(LEXORIN) || M_NO_BREATH in M.mutations || istype(M.loc, /obj/machinery/atmospherics/unary/cryo_cell))
				reagents.remove_any(REAGENTS_METABOLISM)
			else
				if(prob(25)) //So it's not an instarape in case of acid
					reagents.reaction(M, INGEST)
				reagents.trans_to(M, 1)
		else //Else just remove some of the reagents
			reagents.remove_any(REAGENTS_METABOLISM)
	else
		if(ismob(loc))
			to_chat(M, "<span class='notice'>Your [name] has lost all flavor.</span>")
		processing_objects.Remove(src)
	update_icon()

/obj/item/gum/attack_self(mob/user)
	if(wrapped)
		unwrap(user)
	else
		user.equip_to_slot_if_possible(src, slot_wear_mask, disable_warning = TRUE)
	return ..()

/obj/item/gum/proc/unwrap(mob/user)
	user.visible_message("\The [user] unwraps \the [src].","You unwrap \the [src].")
	slot_flags = SLOT_MASK
	wrapped = FALSE
	update_icon()

/obj/item/gum/Crossed(mob/living/carbon/human/AM)
	if(chewed)
		if(istype(AM))
			if(AM.locked_to) //Mob is locked to something, so it's not actually stepping on the gum
				return
			if(AM.flying)
				return
			else
				gum_shoes(AM)
	..()

/obj/item/gum/proc/gum_shoes(mob/living/carbon/human/H)	//make this explode
	if(!istype(H))
		return
	if(H.shoes)
		var/obj/item/clothing/shoes/S = H.shoes
		if(!blood_overlays[S.type]) //If there isn't a precreated blood overlay make one
			S.generate_blood_overlay()
		if(S.blood_overlay != null) // Just if(blood_overlay) doesn't work.  Have to use isnull here.
			S.overlays.Remove(S.blood_overlay)
		else
			S.blood_overlay = blood_overlays[S.type]
		S.blood_overlay.color = "#FFB2C4"
		S.overlays += S.blood_overlay
		S.blood_color = "#FFB2C4"
		H.update_inv_shoes(1)
	else
		H.feet_blood_color = "#FFB2C4"
	to_chat(H, "<span class='warning'>As you step in \the [src], it sticks to your [H.shoes ? H.shoes.name : "feet"]!</span>")
	qdel(src)

// Explosive gums
/obj/item/gum/explosive
	var/explosion_timer = 5 SECONDS

/obj/item/gum/explosive/preattack(atom/A, mob/user, proximity_flag, click_parameters)
	if (!proximity_flag)
		return 0
	if (chewed)
		if(ismob(A) || istype(A, /turf/unsimulated) || istype(A, /turf/simulated/shuttle) || istype(A, /obj/item/weapon/storage/))
			return
		target = A

		if(user.Adjacent(target))
			if(!user.drop_item(src))
				to_chat(user, "<span class='danger'>\The [src] is stuck to your hands!</span>")
				target = user
				user.drop_item(src, force_drop = 1)
			else
				user.visible_message("\The [user] sticks \his [name] to \the [target].","You stick your [name] to \the [target].")

			forceMove(null)

			add_gamelogs(user, "planted explosive [name] on [target.name]", tp_link = TRUE)
			return 1
	return ..()

/obj/item/gum/explosive/chew()
	. = ..()
	spawn(explosion_timer)
		if(target)
			explode(get_turf(target))
		else
			explode(get_turf(src))

/obj/item/gum/explosive/gum_shoes(mob/living/carbon/human/H)
	. = ..()
	forceMove(null)
	target = H

/obj/item/gum/on_syringe_injection(var/mob/user, var/obj/item/weapon/reagent_containers/syringe/tool)
	if(replacement_chem_volume <= 0)
		to_chat(user, "<span class='warning'>\The [src] is full.</span>")
		return INJECTION_RESULT_FAIL
	var/tx_amount = min(tool.amount_per_transfer_from_this, tool.reagents.total_volume)
	tx_amount = transfer_some_reagents(tool, tx_amount, TRUE, user)
	to_chat(user, "<span class='notice'>You inject [tx_amount] units of the solution. \The [tool] now contains [tool.reagents.total_volume] units.</span>")
	return INJECTION_RESULT_SUCCESS_BUT_SKIP_REAGENT_TRANSFER
