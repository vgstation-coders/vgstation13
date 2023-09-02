/obj/item/seeing_stone
	name = "seeing stone"
	desc = "Made from an enchanted mineral, peering through the lens in this stone is like looking into the Veil itself."
	icon_state = "seeing_stone"
	w_class = W_CLASS_TINY
	var/using = FALSE

/obj/item/seeing_stone/attack_self(mob/user)
	..()
	if(using)
		stop_using(user)
	else
		start_using(user)

/obj/item/seeing_stone/proc/mob_moved(atom/movable/mover)
	if(using)
		stop_using(mover)

/obj/item/seeing_stone/proc/start_using(mob/user)
	user.register_event(/event/moved, src, nameof(src::mob_moved()))
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
	user.unregister_event(/event/moved, src, nameof(src::mob_moved()))
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
	canremove = 0
	cant_remove_msg = " is fused to your body!"
	autoignition_temperature = AUTOIGNITION_FABRIC

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
	starting_materials = list(MAT_PLASTIC = 3*CC_PER_SHEET_PLASTIC)//Same as plastic bag
	w_type = RECYK_PLASTIC
	autoignition_temperature = AUTOIGNITION_PLASTIC

/obj/item/folded_bag/attack_self(mob/user)
	to_chat(user, "<span class = 'notice'>You unfold \the [src].</span>")
	var/bag = new/obj/item/weapon/storage/bag/plasticbag(user.loc)
	user.u_equip(src)
	transfer_fingerprints_to(bag)
	user.put_in_hands(bag)
	qdel(src)

/obj/item/gingerbread_egg
	name = "fresh gingerbread eggsac"
	desc = "This one's still warm."
	icon_state = "gingerbread_egg"
	var/candy_delay = 900
	var/last_candy_time

/obj/item/gingerbread_egg/attack_self(mob/user)
	add_fingerprint(user)
	candy_spawn(user)

/obj/item/gingerbread_egg/proc/candy_spawn(var/mob/user)
	if(world.time - last_candy_time >= candy_delay)
		last_candy_time = world.time
		playsound(user, 'sound/effects/squelch1.ogg', 25, 1)
		switch(rand(1,10))
			if(1,2)
				new /obj/item/weapon/reagent_containers/food/snacks/candy_cane(get_turf(user))
			if(3,4)
				new /obj/item/weapon/reagent_containers/food/snacks/gingerbread_man(get_turf(user))
			if(5 to 9)
				for(var/i in 1 to 10)
					new /obj/item/stack/sheet/mineral/gingerbread(get_turf(user))
			if(10)
				new /mob/living/simple_animal/hostile/ginger/gingerbomination(get_turf(user))
	else
		to_chat(user, "<span class='warning'>The sugars in the egg haven't finished caramelizing.</span>")

/obj/item/spring
	name = "spring"
	icon = 'icons/obj/weaponsmithing.dmi'
	icon_state = "spring"
	desc = "A piece of woven metal capable of high elasticity."
	w_type = RECYK_METAL
	starting_materials = list(MAT_IRON = 1 * CC_PER_SHEET_METAL)
