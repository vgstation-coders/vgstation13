/mob/living/simple_animal/hostile/gremlin/grinch
	name = "grinch"
	desc = "He's here to ruin Christmas."
	icon = 'icons/mob/critter.dmi'
	icon_state = "grinch"
	icon_living = "grinch"
	icon_dead = "grinch_dead"
	held_items = list(null, null)
	mob_bump_flag = PASSTABLE // Pass over everything
	mutations = list(M_CLUMSY)

	// -- Much more health than a regular gremlin.
	health = 125
	maxHealth = 125

	// -- They're not affected by overpressured atmos, but need O2 to survive

	min_oxy = 15
	max_oxy = 0
	min_tox = 0
	max_tox = 25
	min_co2 = 0
	max_co2 = 25
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 223	//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius

	var/list/obj/abstract/Overlays/obj_overlays[TOTAL_LAYERS]

// -- INVENTORY CODE --
// Stolen from advanced holograms
/mob/living/simple_animal/hostile/gremlin/grinch/New()
	. = ..()
	obj_overlays[BACK_LAYER]		= new /obj/abstract/Overlays/back_layer

/mob/living/simple_animal/hostile/gremlin/grinch/Login()
	..()
	if (client)
		for (var/obj/item/I in contents)
			client.screen |= I//fixes items disappearing from your inventory if you disconnect/reconnect

/mob/living/simple_animal/hostile/gremlin/grinch/u_equip(obj/item/W, dropped = 1)
	var/success = 0

	if(!W)
		return 0

	if (W == back)
		back = null
		success = 1
		update_inv_back()
		INVOKE_EVENT(src, /event/unequipped, W)
	else
		success = ..()

	if(success)
		if (W)
			if(client)
				client.screen -= W
			W.forceMove(loc)
			W.unequipped(src)
			if(dropped)
				W.dropped(src)
			if(W)
				W.reset_plane_and_layer()

	return success

/mob/living/simple_animal/hostile/gremlin/grinch/equip_to_slot(obj/item/W, slot, redraw_mob = 1)
	if(!istype(W))
		return

	if(src.is_holding_item(W))
		src.u_equip(W)

	switch (slot)
		if(slot_back)
			back = W
			update_inv_back(redraw_mob)

	W.hud_layerise()
	W.equipped(src, slot)
	W.forceMove(src)
	if(client)
		client.screen |= W

/mob/living/simple_animal/hostile/gremlin/grinch/generate_markov_chain() //replaces some words by HATE or CHRISTMAS, inspired by buttbottify()
	var/list/split_phrase = splittext(..()," ")
	var/list/prepared_words = split_phrase.Copy()
	var/i = rand(round(split_phrase.len / 10),round(split_phrase.len / 2))
	for(,i > 0,i--)
		if (!prepared_words.len)
			break
		var/word = pick(prepared_words)
		prepared_words -= word
		var/index = split_phrase.Find(word)

		split_phrase[index] = pick("HATE", "CHRISTMAS")
	return jointext(split_phrase," ")

// Return the item currently in the slot ID
/mob/living/simple_animal/hostile/gremlin/grinch/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
	return null

/mob/living/simple_animal/hostile/gremlin/grinch/show_inv(mob/living/carbon/user)
	user.set_machine(src)
	var/dat
	for(var/i = 1 to held_items.len) //Hands
		var/obj/item/I = held_items[i]
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"
	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[slot_back]'>[makeStrippingButton(back)]</A>"
	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}
	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/hostile/gremlin/grinch/update_inv_hand(index, var/update_icons = 1)
	if(!obj_overlays)
		return
	var/obj/abstract/Overlays/hand_layer/O = obj_overlays["[HAND_LAYER]-[index]"]
	if(!O)
		O = new /obj/abstract/Overlays/hand_layer
		obj_overlays["[HAND_LAYER]-[index]"] = O
	else
		overlays.Remove(O)
		O.overlays.len = 0
	var/obj/item/I = get_held_item_by_index(index)
	if(I && I.is_visible())
		var/t_state = I.item_state
		var/t_inhand_state = I.inhand_states[get_direction_by_index(index)]
		var/icon/check_dimensions = new(t_inhand_state)
		if(!t_state)
			t_state = I.icon_state
		O.name = "[index]"
		O.icon = t_inhand_state
		O.icon_state = t_state
		O.color = I.color
		O.pixel_x = -1*(check_dimensions.Width() - WORLD_ICON_SIZE)/2
		O.pixel_y = -1*(check_dimensions.Height() - WORLD_ICON_SIZE)/2
		O.layer = O.layer
		if(I.dynamic_overlay && I.dynamic_overlay["[HAND_LAYER]-[index]"])
			var/image/dyn_overlay = I.dynamic_overlay["[HAND_LAYER]-[index]"]
			O.overlays.Add(dyn_overlay)
		I.screen_loc = get_held_item_ui_location(index)
		overlays.Add(O)
	if(update_icons)
		update_icons()

/mob/living/simple_animal/hostile/gremlin/grinch/UnarmedAttack(var/atom/A)
	if(istype(A, /obj/machinery) || istype(A, /obj/structure))
		if(CanAttack(A))
			return ..()
	if(ismob(A))
		delayNextAttack(10)
	A.attack_hand(src)

/mob/living/simple_animal/hostile/gremlin/grinch/update_inv_back(var/update_icons=1)
	overlays -= obj_overlays[BACK_LAYER]
	if(back && back.is_visible())
		back.screen_loc = ui_back
		var/image/standing	= image("icon" = ((back.icon_override) ? back.icon_override : 'icons/mob/back.dmi'), "icon_state" = "[back.icon_state]")
		var/obj/abstract/Overlays/O = obj_overlays[BACK_LAYER]
		O.icon = standing
		O.icon_state = standing.icon_state
		O.overlays.len = 0
		if(back.dynamic_overlay)
			if(back.dynamic_overlay["[BACK_LAYER]"])
				var/image/dyn_overlay = back.dynamic_overlay["[BACK_LAYER]"]
				O.overlays += dyn_overlay
				O.icon = standing
		O.icon_state = standing.icon_state
		var/image/I = new()
		I.appearance = O.appearance
		I.plane = FLOAT_PLANE
		obj_overlays[BACK_LAYER] = I
		overlays += I

	if(update_icons)
		update_icons()


// -- Clearing of refs
/mob/living/simple_animal/hostile/gremlin/grinch/Destroy()
	back = null
	for (var/obj/item/O in held_items)
		O.dropped(src)
	. = ..()

/mob/living/simple_animal/hostile/gremlin/grinch/death(var/gibbed = FALSE)
	u_equip(back)
	for (var/obj/item/O in held_items)
		O.dropped(src)
	. = ..()


/mob/living/simple_animal/hostile/gremlin/grinch/Life()
	..()
	if (healths)
		switch(health)
			if(125 to INFINITY)
				healths.icon_state = "health0"
			if(100 to 125)
				healths.icon_state = "health1"
			if(75 to 100)
				healths.icon_state = "health2"
			if(50 to 75)
				healths.icon_state = "health3"
			if(25 to 50)
				healths.icon_state = "health4"
			if(0 to 25)
				healths.icon_state = "health5"
			else
				healths.icon_state = "health6"


/mob/living/simple_animal/hostile/gremlin/grinch/canEnterVentWith()
	var/list/allowed = ..()
	allowed += /obj/item/weapon/storage/backpack/santabag/grinch
	return allowed

/mob/living/simple_animal/hostile/gremlin/grinch/reagent_act(id, method, volume)
	switch(id)
		if(WATER, HOLYWATER, ICE) //Water causes gremlins to multiply
			return

	.=..()

/mob/living/simple_animal/hostile/gremlin/grinch/electrocute_act()
	return

/mob/living/simple_animal/hostile/gremlin/grinch/put_in_hand_check(obj/item/W, index)
	return 1

/mob/living/simple_animal/hostile/gremlin/grinch/attempt_suicide(forced = 0, suicide_set = 1)
	var/obj/item/held_item = get_active_hand()
	if(!held_item)
		held_item = get_inactive_hand()
	if (istype(held_item, /obj/item/weapon/storage/backpack/santabag/grinch))
		visible_message("<span class = 'danger'><b>\The [src] puts their bag on their head and stretches the bag around themselves. With a sudden snapping sound, the bag shrinks to its original size, leaving no trace of \the [src].</b></span>")
		drop_item(held_item)
		qdel(src)
	else
		..()

// -- Grinch items.

// Modified Santa Bag
/obj/item/weapon/storage/backpack/santabag/grinch
	name = "Grinch's bag"
	desc = "He's coming to steal your presents."
	item_state = "grinchbag0"
	icon_state = "grinchbag0"

/obj/item/weapon/storage/backpack/santabag/grinch/mob_can_equip(var/mob/M, slot, disable_warning = 0, automatic = 0)
	if (!..())
		return FALSE
	return isgrinch(M)

/obj/item/weapon/storage/backpack/santabag/grinch/attackby(obj/item/weapon/W, mob/user)
	var/list/recursive_list = recursive_type_check(W, /obj/item/weapon/storage/backpack/santabag)
	if(recursive_list.len)
		return
	return ..()
