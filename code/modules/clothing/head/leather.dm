/obj/item/clothing/head/leather
	name = "leather cap"
	desc = "Crafted by hand, should stop a good knock on the head, but don't expect much from a glorified old rugby helmet."
	flags = FPRINT
	icon_state = "helmet_leather"
	item_state = "helmet_leather"
	body_parts_covered = HEAD|EARS
	armor = list(melee = 30, bullet = 10, laser = 20, energy = 10, bomb = 20, bio = 0, rad = 0)
	heat_conductivity = SNOWGEAR_HEAT_CONDUCTIVITY
	siemens_coefficient = 0.6

/obj/item/clothing/head/leather/attackby(obj/W, mob/user)
	if(istype (W, /obj/item/stack/sheet/animalhide))
		var/obj/item/stack/sheet/animalhide/S = W
		if(S.amount < 2)
			return ..()
		user.visible_message("<span class='notice'>[user] starts installing \the [S] into and onto \the [src].</span>", \
		"<span class='notice'>You start installing \the [S] into \the [src].</span>")
		if(do_after(user, src, 40) && S.use(2))
			if(istype (S, /obj/item/stack/sheet/animalhide/corgi))
				new/obj/item/clothing/head/leather/corgi(get_turf(src))
				user.drop_item(src, force_drop = 1)
				qdel(src)
			if(istype (S, /obj/item/stack/sheet/animalhide/deer))
				new/obj/item/clothing/head/leather/deer(get_turf(src))
				user.drop_item(src, force_drop = 1)
				qdel(src)
			if(istype (S, /obj/item/stack/sheet/animalhide/xeno))
				new/obj/item/clothing/head/leather/xeno(get_turf(src))
				user.drop_item(src, force_drop = 1)
				qdel(src)

/obj/item/clothing/head/leather/corgi
	name = "corgi pelt hat"
	desc = "Who was a good boy?"
	icon_state = "helmet_leather_corgi"
	item_state = "helmet_leather_corgi"

/obj/item/clothing/head/leather/deer
	name = "deer pelt head cover"
	desc = "Made to help you blend in and stalk deer. Sadly lacking the horns."
	body_parts_covered = HEAD|EARS|MOUTH
	icon_state = "helmet_leather_deerNH"
	item_state = "helmet_leather_deerNH"

/obj/item/clothing/head/leather/deer/attackby(obj/W, mob/user)
	if(istype (W, /obj/item/antlers))
		to_chat(user, "You attach \the [W] to \the [src]")
		new/obj/item/clothing/head/leather/deer/horned(get_turf(src))
		user.drop_item(W, force_drop = 1)
		user.drop_item(src, force_drop = 1)
		qdel(W)
		qdel(src)

/obj/item/clothing/head/leather/deer/horned
	name = "horned deer pelt head cover"
	desc = "Made to help you blend in and stalk deer. Perfect for headbutting people with."
	icon_state = "helmet_leather_deer"
	item_state = "helmet_leather_deer"
	armor = list(melee = 35, bullet = 10, laser = 20, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/head/leather/xeno
	name = "xeno-hide helmet"
	desc = "A brutal attempt at using a brutal combatant as armor."
	icon_state = "helmet_leather_xeno"
	item_state = "helmet_leather_xeno"
	armor = list(melee = 40, bullet = 25, laser = 30, energy = 25, bomb = 15, bio = 20, rad = 20)

/obj/item/clothing/head/leather/xeno/acidable()
	return 0