/obj/item/seeing_stone
	name = "seeing stone"
	desc = "Made from an enchanted mineral, peering through the lens in this stone is like looking into the Veil itself."
	icon_state = "seeing_stone"
	w_class = W_CLASS_TINY
	var/using = FALSE
	var/event_key

/obj/item/seeing_stone/attack_self(mob/user)
	..()
	if(using)
		stop_using(user)
	else
		start_using(user)

/obj/item/seeing_stone/proc/mob_moved(var/list/event_args, var/mob/holder)
	if(using)
		stop_using(holder)

/obj/item/seeing_stone/proc/start_using(mob/user)
	event_key = user.on_moved.Add(src, "mob_moved")
	user.visible_message("\The [user] holds \the [src] up to \his eye.","You hold \the [src] up to your eye.")
	user.see_invisible = INVISIBILITY_MAXIMUM
	user.see_invisible_override = INVISIBILITY_MAXIMUM
	if(user && user.client)
		var/client/C = user.client
		C.color = list(
						0.8,0,	0,	0,
						0.8,0,	0,	0,
				 		1,	0,	0,	0)
	using = TRUE

/obj/item/seeing_stone/proc/stop_using(mob/user)
	user.on_moved.Remove(event_key)
	user.visible_message("\The [user] lowers \the [src].","You lower \the [src].")
	user.see_invisible = initial(user.see_invisible)
	user.see_invisible_override = 0
	if(user && user.client)
		var/client/C = user.client
		C.color = initial(C.color)
	using = FALSE

/obj/item/red_ribbon_arm
	name = "\improper Red Ribbon Arm"
	desc = "It almost seems as though it's alive."
	icon_state = "red_ribbon_arm"
	w_class = W_CLASS_MEDIUM
	slot_flags = SLOT_BELT

/obj/item/red_ribbon_arm/equipped(mob/living/carbon/human/H, equipped_slot)
	..()
	if(istype(H) && H.get_item_by_slot(slot_belt) == src && equipped_slot != null && equipped_slot == slot_belt)
		H.set_hand_amount(H.held_items.len + 1)

/obj/item/red_ribbon_arm/unequipped(mob/living/carbon/human/user, var/from_slot = null)
	..()
	if(from_slot == slot_belt && istype(user))
		user.set_hand_amount(user.held_items.len - 1)


/obj/item/folded_bag
	name = "folded plastic bag"
	desc = "A neatly folded-up plastic bag, making it easier to store."
	icon_state = "folded_bag"
	w_class = W_CLASS_TINY

/obj/item/folded_bag/attack_self(mob/user)
	to_chat(user, "<span class = 'notice'>You unfold \the [src].</span>")
	var/bag = new/obj/item/weapon/storage/bag/plasticbag(user.loc)
	user.u_equip(src)
	transfer_fingerprints_to(bag)
	user.put_in_hands(bag)
	qdel(src)