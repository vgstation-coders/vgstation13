/obj/item/weapon/dnascrambler
	name = "dna scrambler"
	desc = "An illegal genetic serum designed to randomize the user's identity."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "b10"

/obj/item/weapon/dnascrambler/attack(mob/M as mob, mob/user as mob)
	if(!M || !user)
		return

	if(!ishuman(M) || !ishuman(user))
		return

	if(M == user)
		user.visible_message("<span class='danger'>[user.name] injects \himself with [src]!</span>")
		src.injected(user,user)
	else
		user.visible_message("<span class='danger'>[user.name] is trying to inject [M.name] with [src]!</span>")
		if (do_mob(user,M,30))
			user.visible_message("<span class='danger'>[user.name] injects [M.name] with [src].</span>")
			src.injected(M, user)
		else
			to_chat(user, "<span class='warning'>You failed to inject [M.name].</span>")

/obj/item/weapon/dnascrambler/proc/injected(var/mob/living/carbon/target, var/mob/living/carbon/user)
	target.generate_name()
	target.real_name = target.name

	scramble(1, target, 100)

	log_attack("[key_name(user)] injected [key_name(target)] with the [name]")
	log_game("[key_name_admin(user)] injected [key_name_admin(target)] with the [name]")

	//We don't want to leave an obvious "used dna scrambler" behind, let's just create a harmless syringe.
	var/obj/item/weapon/reagent_containers/syringe/spent = new(get_turf(user))
	transfer_fingerprints(src, spent)

	user.drop_from_inventory(src)
	qdel(src)
