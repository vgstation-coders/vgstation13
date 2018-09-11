/mob
	var/bloody_hands = 0
	var/mob/living/carbon/human/bloody_hands_mob
	var/track_blood = 0
	var/list/feet_blood_DNA
	var/feet_blood_color
	var/track_blood_type

/obj/item/clothing/gloves
	var/transfer_blood = 0
	var/mob/living/carbon/human/bloody_hands_mob

/obj/item/clothing/shoes/
	var/track_blood = 0

/obj/item/weapon/reagent_containers/glass/rag
	name = "rag" //changed to "rag" from "damp rag" - Hinaichigo
	desc = "For cleaning up messes, you suppose."
	w_class = W_CLASS_TINY
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 5
	can_be_placed_into = null

/obj/item/weapon/reagent_containers/glass/rag/attack_self(mob/user as mob)
	return

/obj/item/weapon/reagent_containers/glass/rag/mop_act(obj/item/weapon/mop/M, mob/user)
	return 0

/obj/item/weapon/reagent_containers/glass/rag/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if (!ismob(M))
		..()
	if(user.zone_sel.selecting == "mouth")
		if(M.reagents && reagents.total_volume)
			user.visible_message("<span class='warning'>\The [M] has been smothered with \the [src] by \the [user]!</span>", "<span class='warning'>You smother \the [M] with \the [src]!</span>", "You hear some struggling and muffled cries of surprise")
			src.reagents.reaction(M, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return 1
	else		
		var/datum/organ/external/targetorgan = M.get_organ(user.zone_sel.selecting)
		var/list/bleeding_organs = M.get_bleeding_organs()
		if(targetorgan in bleeding_organs) //rags work as bandages
			if(targetorgan.open == 0)
				if(!targetorgan.bandage())
					to_chat(user, "<span class='warning'>The wounds on [M]'s [targetorgan.display_name] have already been bandaged.</span>")
					return 1
				else
					user.visible_message("<span class='notice'>[user] uses \a [src] to stem the bleeding on [M]'s [targetorgan.display_name].</span>", \
					"<span class='notice'>You use your [src] to stem the bleeding on [M]'s [targetorgan.display_name].</span>")
					qdel(src)
			else
				to_chat(user, "<span class='notice'>[M]'s [targetorgan.display_name] is cut wide open, you'll need more than a rag!</span>")
				return
		else
			..()

/obj/item/weapon/reagent_containers/glass/rag/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!user.is_holding_item(src))
		return  //we used the rag as a bandage
	if(!proximity_flag)
		return 0 // Not adjacent
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
	return