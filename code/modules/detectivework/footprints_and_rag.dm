/mob
	var/bloody_hands = 0
	var/list/bloody_hands_data = list()
	var/track_blood = 0
	var/list/feet_blood_DNA
	var/feet_blood_color
	var/feet_blood_lum = 0
	var/track_blood_type

/obj/item/clothing/shoes
	var/track_blood = 0

/obj/item/weapon/reagent_containers/glass/rag
	name = "rag" //changed to "rag" from "damp rag" - Hinaichigo
	desc = "For cleaning up messes, you suppose."
	w_class = W_CLASS_TINY
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	item_state = new/icon("icon" = 'icons/mob/mask.dmi', "icon_state" = "rag")
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 5
	slot_flags = SLOT_MASK
	body_parts_covered = MOUTH
	goes_in_mouth = TRUE
	is_muzzle = MUZZLE_SOFT
	autoignition_temperature = AUTOIGNITION_FABRIC
	w_type = RECYK_FABRIC
	starting_materials = list(MAT_FABRIC = 50)
	var/mob/current_target = null

/obj/item/weapon/reagent_containers/glass/rag/robo
	name = "roborag"
	desc = "A non-detachable rag attached to a manipulator arm, for cleaning up messes."

/obj/item/weapon/reagent_containers/glass/rag/attack_self(mob/user as mob)
	return

/obj/item/weapon/reagent_containers/glass/rag/mop_act(obj/item/weapon/mop/M, mob/user)
	return 0

/obj/item/weapon/reagent_containers/glass/rag/attack(var/mob/living/M, var/mob/living/user, var/def_zone, var/allowsmother = TRUE, var/allowbandage = TRUE)
	if (!ismob(M))
		..()
	current_target = null
	if(allowsmother && user.zone_sel.selecting == "mouth" && ishuman(M))
		var/mob/living/carbon/human/H = M
		current_target = H
		var/self_smother = FALSE
		if (M == user)
			self_smother = TRUE//auto-asphyxiation?
		playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 0, -3)
		user.visible_message("<span class='warning'>\The [user] puts \a [src] over [self_smother ? "their own mouth" : "\the [M]'s mouth" ]!</span>", "<span class='warning'>You place \the [src] over [self_smother ? "your mouth" : "\the [M]'s mouth" ]!</span>")
		if(M.reagents && reagents.total_volume)
			if (do_after(user,H,1 SECONDS))//short, but combined with the time it takes to get grabbed you get enough time to react.
				var/smother_fail = FALSE
				if(H.species && H.species.flags & NO_BREATHE)//can they breath?
					smother_fail = TRUE
				if(H.wear_mask && H.wear_mask.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
					smother_fail = TRUE
				if(H.glasses && H.glasses.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
					smother_fail = TRUE
				if(H.head && H.head.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
					smother_fail = TRUE
				if (smother_fail)
					user.visible_message("<span class='warning'>\The [user] attempted to smother [self_smother ? "themselves" : "\the [M]"] with \the [src] but [self_smother ? "they were" : "the latter was"] unaffected!</span>", "<span class='warning'>You tried smother [self_smother ? "yourself" : "\the [M]"] with \the [src] but [self_smother ? "" : "they "]were unaffected due to either [self_smother ? "your" : "their "] clothing or [self_smother ? "your" : "their "] species!</span>")
				else
					user.visible_message("<span class='warning'>\The [M] has [self_smother ? "smothered themselves" : "been smothered by \the [user]"] with \the [src]!</span>", "<span class='warning'>You smother [self_smother ? "yourself" : "\the [M]"] with \the [src]!</span>", "You hear some struggling and muffled cries of surprise")
					reagents.trans_to(H, reagents.total_volume, log_transfer = TRUE, whodunnit = user)
			return 1
		else
			to_chat(user, "<span class='warning'>There is nothing on the rag to smother them with.</span>")
	else if(allowbandage)
		var/datum/organ/external/targetorgan = M.get_organ(user.zone_sel.selecting)
		var/list/bleeding_organs = M.get_bleeding_organs()
		if(targetorgan in bleeding_organs) //rags work as bandages
			if(targetorgan.open == 0)
				if(!targetorgan.bandage())
					to_chat(user, "<span class='warning'>The wounds on [M]'s [targetorgan.display_name] have already been bandaged.</span>")
					return 1
				else
					current_target = M
					user.visible_message("<span class='notice'>[user] uses \a [src] to stem the bleeding on [M]'s [targetorgan.display_name].</span>", \
					"<span class='notice'>You use your [src] to stem the bleeding on [M]'s [targetorgan.display_name].</span>")
					qdel(src)
			else
				to_chat(user, "<span class='notice'>[M]'s [targetorgan.display_name] is cut wide open, you'll need more than a rag!</span>")
				return

/obj/item/weapon/reagent_containers/glass/rag/robo/attack(var/mob/living/M, var/mob/living/user, var/def_zone)
	if(!isrobot(user))
		return ..()
	var/mob/living/silicon/robot/R = user
	if(R.emagged)
		. = ..(M, user, def_zone, allowsmother = TRUE, allowbandage = FALSE)
	else
		. = ..(M, user, def_zone, allowsmother = FALSE, allowbandage = FALSE)


/obj/item/weapon/reagent_containers/glass/rag/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (target == current_target)
		current_target = null
		return	//we are currently either bandaging them or smothering them
	current_target = null
	if(!user.is_holding_item(src))
		return  //we used the rag as a bandage
	if(!proximity_flag)
		return 0 // Not adjacent
	if (istype(target,/obj/structure/sink))
		return	// We're here to fill the rag, not use it pointlessly
	if(reagents.total_volume < 1)
		to_chat(user, "<span class='notice'>Your rag is dry!</span>")
		return
	user.visible_message("<span class='warning'>[user] begins to wipe down \the [target].</span>", "<span class='notice'>You begin to wipe down \the [target].</span>")
	if(do_after(user,target, 50))
		if(target)
			target.clean_blood()
			if(isturf(target))
				for(var/obj/effect/O in target)
					if(iscleanaway(O))
						qdel(O)
			reagents.remove_any(1)
			user.visible_message("<span class='notice'>[user] finishes wiping down \the [target].</span>", "<span class='notice'>You have finished wiping down \the [target]!</span>")

/obj/item/weapon/reagent_containers/glass/rag/process()
	//Reagents in the rag gradually get transferred into the wearer. Copied from cigs_lighters.dm.
	var/mob/living/M = get_holder_of_type(src, /mob/living)
	if(reagents && reagents.total_volume)	//Check if it has any reagents at all
		if(iscarbon(M) && ((src == M.wear_mask) || (loc == M.wear_mask))) //If it's in the human/monkey mouth, transfer reagents to the mob
			if(M.reagents.has_any_reagents(LEXORINS) || istype(M.loc, /obj/machinery/atmospherics/unary/cryo_cell))
				reagents.remove_any(REAGENTS_METABOLISM)
			else
				reagents.reaction(M, INGEST, amount_override = min(reagents.total_volume,0.5)/(reagents.reagent_list.len))
				reagents.trans_to(M, 0.5)
		else
			processing_objects.Remove(src)

/obj/item/weapon/reagent_containers/glass/rag/equipped(mob/living/carbon/human/H, equipped_slot)
	..()
	if(istype(H) && H.get_item_by_slot(slot_wear_mask) == src && equipped_slot != null && equipped_slot == slot_wear_mask)
		processing_objects.Add(src)

/obj/item/weapon/reagent_containers/glass/rag/unequipped(mob/living/carbon/human/user, from_slot = null)
	..()
	processing_objects.Remove(src)
