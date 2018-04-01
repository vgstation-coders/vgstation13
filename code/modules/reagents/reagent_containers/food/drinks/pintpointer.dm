/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer
	name = "\improper Pintpointer"
	desc = "An attempt to create a navigation system which even a drunk spaceman can use."
	icon_state = "pintdist5"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	item_state = "electronic"
	var/mob/creator
	var/smashed

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer/New()
	..()
	update_icon()
	processing_objects.Add(src)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer/process()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer/update_icon()
	var/dist = calculate_distance()
	icon_state = "pintdist[dist]"

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer/proc/calculate_distance()
	if(!creator)
		return round(reagents.total_volume/10)
	else if(creator.gcDestroyed)
		creator = null
		return .()
	switch(get_dist(get_turf(src),creator))
		if(-1 to 8)
			. = 5
		if(9 to 16)
			. = 4
		if(17 to 24)
			. = 3
		if(25 to 32)
			. = 2
		if(33 to 40)
			. = 1
		if(41 to INFINITY)
			. = 0

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer/on_reagent_change()
	update_icon()
	if(reagents.get_master_reagent_id() != PINTPOINTER && !smashed)
		var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/D = new (get_turf(src))
		reagents.trans_to(D, reagents.total_volume)
		qdel(src)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer/Destroy()
	creator = null
	processing_objects.Remove(src)
	..()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer/smash(mob/living/M, mob/living/user)
	smashed = TRUE
	..()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer/throw_impact(atom/hit_atom)
	smashed = TRUE
	..()