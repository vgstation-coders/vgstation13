/obj/item/finfant
	name = "finfant"
	desc = "Often believed to be a type of space fish, finfants are actually an arthropodal larva. Upon being introduced to a more evolutionarily blessed species they will enter a dormant pupa lifestage, using this time to re-orient their DNA to match the imprinted species."
	icon = ''
	icon_state = ""
	w_class = W_CLASS_SMALL
	var/list/illegalCopy = list(
		/mob/living/carbon/human/dummy,
	)

/obj/item/finfant/preattack(var/atom/A, var/mob/user, var/proximity_flag)
	if(isliving(A))
		var/mob/living/toCopy = A
		to_chat(user, "<span class='notice'>You gently press \the [src] against [toCopy].</span>")
		if(do_after(user, toCopy, 3 SECONDS))
			if(is_type_in_list(toCopy, illegalCopy) || is_type_in_list(toCopy, blacklisted_mobs))
				to_chat(user, "<span class='notice'>\The [src] recoils away from \the [toCopy]!</span>")
				return
			to_chat(user, "<span class='notice'>\The [src] begins buzzing and shivering.</span>")
			spawn(1 SECONDS)
				becomeEgg(toCopy)

/obj/item/finfant/proc/becomeEgg(mob/living/toCopy)
	var/obj/item/weapon/reagent_containers/food/snacks/egg/finfant/pupa = new /obj/item/weapon/reagent_containers/food/snacks/egg/finfant(src.loc)
	pupa.hatch_type = toCopy
	user.drop_item(src)
	user.put_in_hands(pupa)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/finfant
	name = "finfant pupa"
	desc = "Similar enough to an egg."
	icon_state = "finfant_pupa"
	can_color = FALSE
