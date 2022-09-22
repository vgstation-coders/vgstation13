/obj/item/weapon/dnascrambler
	name = "dna scrambler"
	desc = "An illegal genetic serum designed to randomize the user's identity."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "b10"

/obj/item/weapon/dnascrambler/attack(var/mob/living/carbon/human/M, var/mob/living/carbon/human/user)
	if(!istype(M) || !istype(user))
		return

	if(M == user)
		user.visible_message("<span class='danger'>\The [user] injects \himself with [src]!</span>")
		src.injected(user,user)
	else
		user.visible_message("<span class='danger'>\The [user] is trying to inject \the [M] with [src]!</span>")
		if (do_mob(user,M,30))
			user.visible_message("<span class='danger'>\The [user] injects \the [M] with [src].</span>")
			src.injected(M, user)
		else
			to_chat(user, "<span class='warning'>You fail to inject \the [M].</span>")

/obj/item/weapon/dnascrambler/proc/injected(var/mob/living/carbon/target, var/mob/living/carbon/user)
	target.generate_name()

	scramble(1, target, 100)

	log_attack("[key_name(user)] injected [key_name(target)] with \the [src]")
	log_game("[key_name_admin(user)] injected [key_name_admin(target)] with \the [src]")

	user.drop_item(src, force_drop = 1)
	//We don't want to leave an obvious "used dna scrambler" behind, let's just create a harmless syringe.
	var/obj/item/weapon/reagent_containers/syringe/spent = new(get_turf(user))
	transfer_fingerprints(src, spent)
	user.put_in_hands(spent)

	qdel(src)
