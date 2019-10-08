/obj/structure/coatrack
	name = "Coat Rack"
	desc = "For a detective to hang his coat and hat."
	icon = 'icons/obj/coatrack.dmi'
	icon_state = "coatrack"
	density = 1
	anchored = 0
	pressure_resistance = ONE_ATMOSPHERE*5
	flags = FPRINT
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3
	var/obj/item/clothing/suit/suit = null
	var/obj/item/clothing/head/hat = null

	var/list/allowed_suits = list(
		/obj/item/clothing/suit/storage/det_suit,
		/obj/item/clothing/suit/storage/forensics,
		/obj/item/clothing/suit/storage/labcoat,
		/obj/item/clothing/suit/storage/wintercoat,
		/obj/item/clothing/suit/armor/hos,
		/obj/item/clothing/suit/storage/draculacoat,
		/obj/item/clothing/suit/raincoat,
		/obj/item/clothing/suit/storage/capjacket,
		/obj/item/clothing/suit/pirate,
		/obj/item/clothing/suit/storage/trader
		)
	var/list/allowed_hats = list(
		/obj/item/clothing/head/det_hat,
		/obj/item/clothing/head/caphat,
		/obj/item/clothing/head/centhat,
		/obj/item/clothing/head/beret,
		/obj/item/clothing/head/that,
		/obj/item/clothing/head/flatcap,
		/obj/item/clothing/head/hgpiratecap,
		/obj/item/clothing/head/helmet/tactical/warden,
		/obj/item/clothing/head/helmet/tactical/HoS,
		)

/obj/structure/coatrack/attack_hand(mob/user)
	if(suit)
		to_chat(user, "<span class='notice'>You pick up \the [suit] from \the [src]</span>")
		playsound(src, "rustle", 50, 1, -5)
		suit.forceMove(get_turf(src))
		if(!user.get_active_hand())
			user.put_in_hands(suit)
		suit = null
		update_icon()
		return

	if(hat)
		to_chat(user, "<span class='notice'>You pick up \the [hat] from \the [src]</span>")
		playsound(src, "rustle", 50, 1, -5)
		hat.forceMove(get_turf(src))
		if(!user.get_active_hand())
			user.put_in_hands(hat)
		hat = null
		update_icon()
		return

/obj/structure/coatrack/attackby(obj/item/C, mob/user)
	if (istype(C, /obj/item/clothing/suit) && !suit && is_type_in_list(C, allowed_suits))
		if(user.drop_item(C, src))
			to_chat(user, "<span class='notice'>You place your [C] on \the [src]</span>")
			playsound(src, "rustle", 50, 1, -5)
			suit = C
			update_icon()
	else if (istype(C, /obj/item/clothing/head) && !hat && is_type_in_list(C, allowed_hats))
		if(user.drop_item(C, src))
			to_chat(user, "<span class='notice'>You place your [C] on \the [src]</span>")
			playsound(src, "rustle", 50, 1, -5)
			hat = C
			update_icon()
	else if(iswrench(C))
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		getFromPool(/obj/item/stack/sheet/wood, get_turf(src), 2)
		qdel(src)//the hat and suit on the coat rack are automatically dropped by Destroy()
	else
		return ..()

/obj/structure/coatrack/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return

/obj/structure/coatrack/Destroy()
	if(loc)
		if(suit)
			suit.forceMove(loc)
		if(hat)
			hat.forceMove(loc)
	..()

/obj/structure/coatrack/update_icon()
	overlays.len = 0
	if(suit)
		overlays += image(icon,"coat-[suit.icon_state]")
	if(hat)
		var/image/I = image('icons/mob/head.dmi', hat.icon_state, dir = SOUTH)
		var/matrix/M = matrix()
		M.Turn(90)
		M.Translate(-9,6)
		I.transform = M
		overlays += I

/obj/structure/coatrack/full

/obj/structure/coatrack/full/New()
	..()
	suit = new/obj/item/clothing/suit/storage/det_suit(src)
	hat = new/obj/item/clothing/head/det_hat(src)
	update_icon()
