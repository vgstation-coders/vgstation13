/obj/item/weapon/card/debit
	name = "\improper debit card"
	desc = "A flimsy piece of plastic with cheap near field circuitry backed by digits representing funds in a bank account."
	icon = 'icons/obj/card.dmi'
	icon_state = "debit"
	melt_temperature = MELTPOINT_PLASTIC
	w_class = W_CLASS_TINY
	starting_materials = list(MAT_PLASTIC = 10)
	w_type = RECYK_MISC

/obj/item/weapon/card/debit/New(var/new_loc, var/account_number)
	. = ..(new_loc)
	associated_account_number = account_number

/obj/item/weapon/card/debit/examine(var/mob/user)
	. = ..()
	if(user.Adjacent(src) || istype(user, /mob/dead))
		if(associated_account_number)
			to_chat(user, "<span class='notice'>The account number on the card reads [associated_account_number].</span>")
		else
			to_chat(user, "<span class='warning'>The account number appears to be scratched off.</span>")

/obj/item/weapon/card/debit/attackby(var/obj/O, var/mob/user)
	. = ..()
	if(istype(O, /obj/item))
		var/obj/item/item = O
		if(item.sharpness_flags & SHARP_BLADE)
			user.visible_message("<span class='warning'>\The [user] cuts \the [src] with \the [item], destroying it.</span>", "<span class='warning'>You destroy \the [src] with \the [item]</span>", "You hear plastic being cut.")
			qdel(src)
			return
		else if(O.is_hot() >= MELTPOINT_PLASTIC)
			user.visible_message("<span class='warning'>\The [user] melts \the [src] with \the [item], destroying it.</span>", "<span class='warning'>You destroy \the [src] with \the [item]</span>")
			qdel(src)
			return
		

/obj/item/weapon/card/debit/trader/New(var/new_loc, var/account_number)
	if(!trader_account)
		trader_account = create_trader_account
	return ..(new_loc, trader_account.account_number)