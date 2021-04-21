/**
	Plate Carrier armor.
		Armor that accepts an armored plate, that takes the brunt of the damage and steadily ablates to nothing.
*/

/obj/item/clothing/suit/armor/plate_carrier
	name = "tactical plate carrier"
	desc = "A vest designed to comfortably hold interchangable armor plates."
	icon_state = "tactical_armor"
	item_state = "tactical_armor"
	species_fit = list(INSECT_SHAPED)
	var/obj/item/weapon/armor_plate/P

/obj/item/clothing/suit/armor/plate_carrier/get_armor(var/type)
	var/armor_value = armor[type]
	if(P)
		armor_value = armor[type] <= 0 ? P.armor[type] : clamp((armor[type]+P.armor[type])/2, armor[type], 100)
	return armor_value

/obj/item/clothing/suit/armor/plate_carrier/get_armor_absorb(var/type)
	var/armor_value = armor_absorb[type]
	if(P)
		armor_value = armor_absorb[type] <= 0 ? P.armor_absorb[type] : clamp((armor_absorb[type]+P.armor_absorb[type])/2, armor_absorb[type], 100)
	return armor_value

/obj/item/clothing/suit/armor/plate_carrier/equipped(var/mob/user, var/slot)
	..()
	if(slot == slot_wear_suit)
		user.lazy_register_event(/lazy_event/on_damaged, src, .proc/handle_user_damage)


/obj/item/clothing/suit/armor/plate_carrier/unequipped(mob/user, var/from_slot = null)
	if(from_slot == slot_wear_suit)
		user.lazy_unregister_event(/lazy_event/on_damaged, src, .proc/handle_user_damage)
	..()

/obj/item/clothing/suit/armor/plate_carrier/attack_self(mob/user)
	if(P)
		user.put_in_hands(P)
		P = null

/obj/item/clothing/suit/armor/plate_carrier/attackby(obj/item/W,mob/user)
	..()
	if(istype(W, /obj/item/weapon/armor_plate))
		if(P)
			to_chat(user, "<span class = 'notice'>There is already \a [P] installed on \the [src].</span>")
			return
		if(user.drop_item(W, src))
			P = W
			to_chat(user, "<span class = 'notice'>You install \the [W] into \the [src].</span>")

/obj/item/clothing/suit/armor/plate_carrier/examine(mob/user)
	..()
	if(P)
		to_chat(user, "<span class = 'notice'>It has \a [P] attached to it. <a HREF='?src=\ref[user];lookitem=\ref[P]'>Take a closer look.</a></span>")

/obj/item/clothing/suit/armor/plate_carrier/proc/handle_user_damage(kind, amount)
	if(!P)
		return
	if(amount <= 0)
		return

	P.receive_damage(kind, amount)
	if(P.gcDestroyed)
		P = null

/obj/item/clothing/suit/armor/plate_carrier/security
	name = "security plate armor"
	desc = "A robust vest designed to comfortably hold interchangable armor plates."
	icon_state = "security_armor"
	item_state = "security_armor"
	species_fit = list(INSECT_SHAPED)
	armor = list(melee = 10, bullet = 15, laser = 25, energy = 15, bomb = 5, bio = 0, rad = 0)

/obj/item/weapon/armor_plate
	icon = 'icons/obj/items.dmi'
	icon_state = "plate_1"
	name = "ceramic armor plate"
	desc = "A generic armor plate for use in plate carriers."
	health = 5
	armor = list(melee = 25, bullet = 90, laser = 90, energy = 10, bomb = 25, bio = 0, rad = 0)
	armor_absorb = list(melee = 25, bullet = 5, laser = 60, energy = -5, bomb = 0, bio = 0, rad = 0)


/obj/item/weapon/armor_plate/proc/receive_damage(var/type, var/amount)
	if(type == BRUTE || type == BURN)
		health -= amount
	playsound(src, 'sound/effects/Glasshit.ogg', 70, 1)
	if(health <= 0)
		visible_message("<span class = 'warning'>\The [src] breaks apart!</span>")
		var/turf/T = get_turf(src)
		playsound(T, "shatter", 70, 1)
		new /obj/effect/decal/cleanable/dirt(T)
		if(prob(75))
			var/obj/item/weapon/shard/shrapnel/S = new(T)
			S.name = "[src] shrapnel"
			S.desc = "[S.desc] It looks like it's from \a [src]."
		qdel(src)

/obj/item/weapon/armor_plate/examine(var/mob/user)
	..()
	switch(health)
		if(initial(health) to initial(health)/2)
			to_chat(user, "<span class = 'notice'>\The [src] is hard.</span>")
		if(initial(health)/2-1 to initial(health)/4)
			to_chat(user, "<span class = 'warning'>\The [src] is brittle.</span>")
		if(initial(health)/4-1 to 0)
			to_chat(user, "<span class = 'warning'>\The [src] is falling apart!</span>")

/obj/item/weapon/armor_plate/bullet_resistant
	name = "plasteel armor plate"
	desc = "An armor plate for use in plate carriers. This one is optimized for impact negation."
	icon_state = "plate_2"
	health = 15
	armor = list(melee = 50, bullet = 90, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)
	armor_absorb = list(melee = 25, bullet = 20, laser = 10, energy = -5, bomb = 35, bio = 0, rad = 0)

/obj/item/weapon/armor_plate/laser_resistant
	name = "ablated ceramite armor plate"
	desc = "An armor plate for use in plate carriers. This one is optimized for heat dissipation."
	icon_state = "plate_3"
	health = 20
	armor = list(melee = 10, bullet = 10, laser = 90, energy = 50, bomb = 0, bio = 0, rad = 0)
	armor_absorb = list(melee = 25, bullet = 20, laser = 20, energy = -5, bomb = 0, bio = 0, rad = 0)
