/obj/item/clothing/suit/leather
	name = "leather suit"
	desc = "Crafted from fresh leather, may not stop a bullet or a knife, but it's a template to build off of."
	icon_state = "suit_leather"
	item_state = "suit_leather"
	allowed = list(/obj/item/weapon/gun/energy, /obj/item/weapon/gun/projectile, /obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs)
	body_parts_covered = FULL_TORSO
	heat_conductivity = SNOWGEAR_HEAT_CONDUCTIVITY
	siemens_coefficient = 0.6
	armor = list(melee = 25, bullet = 20, laser = 20, energy = 15, bomb = 20, bio = 0, rad = 0)

/obj/item/clothing/suit/leather/attackby(obj/W, mob/user)
	if(istype (W, /obj/item/stack/sheet/animalhide))
		var/obj/item/stack/sheet/animalhide/S = W
		if(S.amount < 2)
			return ..()
		user.visible_message("<span class='notice'>[user] starts installing \the [S] into and onto \the [src].</span>", \
		"<span class='notice'>You start installing \the [S] into \the [src].</span>")
		if(do_after(user, src, 40) && S.use(2))
			if(istype (S, /obj/item/stack/sheet/animalhide/corgi))
				new/obj/item/clothing/suit/leather/corgi(get_turf(src))
				user.drop_item(src, force_drop = 1)
				qdel(src)
			if(istype (S, /obj/item/stack/sheet/animalhide/deer))
				new/obj/item/clothing/suit/leather/deer(get_turf(src))
				user.drop_item(src, force_drop = 1)
				qdel(src)
			if(istype (S, /obj/item/stack/sheet/animalhide/xeno))
				new/obj/item/clothing/suit/leather/xeno(get_turf(src))
				user.drop_item(src, force_drop = 1)
				qdel(src)


/obj/item/clothing/suit/leather/corgi
	name = "corgi-leather suit"
	desc = "You monster."
	icon_state = "suit_leather_corgi"
	item_state = "suit_leather_corgi"

/obj/item/clothing/suit/leather/deer
	name = "deer-leather suit"
	desc = "Coated in deer hide, smells just as bad as you'd think."
	icon_state = "suit_leather_deer"
	item_state = "suit_leather_deer"

/obj/item/clothing/suit/leather/xeno
	name = "xeno-hide suit"
	desc = "Like the aftermath of the bad end of 101 dalmations, but with less puppies and more xenomorph."
	icon_state = "suit_leather_xeno"
	item_state = "suit_leather_xeno"
	armor = list(melee = 40, bullet = 25, laser = 30, energy = 25, bomb = 15, bio = 20, rad = 20)

/obj/item/clothing/suit/leather/xeno/acidable()
	return 0