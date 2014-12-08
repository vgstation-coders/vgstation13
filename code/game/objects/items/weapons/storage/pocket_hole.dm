/obj/item/weapon/storage/pocket_hole
	name = "pocket hole"
	desc = "A small rip in the fabric of reality. Keeps your credit cards in order, too."
	icon = 'icons/obj/storage.dmi'
	icon_state = "pocket_hole"
	w_class = 3.0

	max_w_class = 5
	max_combined_w_class = 0
	storage_slots = 21 //Totally overboard

/obj/item/weapon/storage/pocket_hole/attack_hand(mob/user as mob)
	if (user)
		src.orient2hud(user)
		if (user.s_active)
			user.s_active.close(user)
		src.show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
	src.add_fingerprint(user)
	return