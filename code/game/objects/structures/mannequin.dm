
/////////////////////////////////////////////////////////MANNEQUINS//////////////////////////////////////////////////////////
//Basically statues that you can dress up.

/obj/structure/mannequin
	name = "human marble mannequin"
	desc = "You almost feel like it's going to come alive any second."
	icon = 'icons/obj/mannequin.dmi'
	icon_state="mannequin_marble_human"
	density = 1
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	layer = VEHICLE_LAYER
	var/datum/species/species
	var/species_type = /datum/species/human //TODO: mannequin for other races
	var/fat = 0
	var/primitive = 0
	var/list/clothing = list()
	var/list/obj/item/held_items = list(null, null)
	var/clothing_offset_x = 0
	var/clothing_offset_y = 3*PIXEL_MULTIPLIER
	var/health = 90
	var/maxHealth = 90

	//for mappers, with love
	var/mapping_uniform = null
	var/mapping_shoes = null
	var/mapping_gloves = null
	var/mapping_ears = null
	var/mapping_suit = null
	var/mapping_glasses = null
	var/mapping_hat = null
	var/mapping_belt = null
	var/mapping_mask = null
	var/mapping_back = null
	var/mapping_id = null

	var/mapping_hand_right = null
	var/mapping_hand_left = null

/obj/structure/mannequin/New()
	..()

	species = new species_type()

	clothing = list(
		SLOT_MANNEQUIN_ICLOTHING,
		SLOT_MANNEQUIN_FEET,
		SLOT_MANNEQUIN_GLOVES,
		SLOT_MANNEQUIN_EARS,
		SLOT_MANNEQUIN_OCLOTHING,
		SLOT_MANNEQUIN_EYES,
		SLOT_MANNEQUIN_BELT,
		SLOT_MANNEQUIN_MASK,
		SLOT_MANNEQUIN_HEAD,
		SLOT_MANNEQUIN_BACK,
		SLOT_MANNEQUIN_ID,
		)
	checkMappingWear()


/obj/structure/mannequin/Destroy()
	for(var/cloth in clothing)
		if(clothing[cloth])
			var/obj/item/cloth_to_drop = clothing[cloth]
			cloth_to_drop.forceMove(loc)
			clothing[cloth] = null
	for(var/item in held_items)
		if(held_items[item])
			var/obj/item/item_to_drop = held_items[item]
			item_to_drop.forceMove(loc)
			held_items[item] = null
	..()


/obj/structure/mannequin/MouseDrop(var/mob/M)
	..()
	if(M != usr)
		return
	if(!Adjacent(M))
		return
	if(istype(M,/mob/living/silicon/ai))
		return
	show_inv(M)


/obj/structure/mannequin/attack_hand(var/mob/living/user)
	if(user.a_intent == I_HURT)
		user.delayNextAttack(8)
		user.visible_message("<span class='danger'>[user.name] punches \the [src]!</span>", "<span class='danger'>You punch \the [src]!</span>")
		getDamage(rand(1,7) * (user.get_strength() - 1))
	else
		show_inv(user)


/obj/structure/mannequin/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H.name] kicks \the [src]!</span>", "<span class='danger'>You kick \the [src]!</span>")

	var/damage = rand(1,7) * (H.get_strength() - 1)
	var/obj/item/clothing/shoes/S = H.shoes
	if(istype(S))
		damage += S.bonus_kick_damage

	getDamage(damage)



/obj/structure/mannequin/attack_animal(var/mob/living/simple_animal/user)
	if(user.melee_damage_upper > 0)
		user.visible_message("<span class='danger'>\The [user] [user.attacktext] \the [src]!</span>", "<span class='danger'>You [user.attacktext] \the [src]!</span>")
		getDamage(rand(user.melee_damage_upper, user.melee_damage_upper))



/obj/structure/displaycase/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/structure/mannequin/attackby(var/obj/item/weapon/W,var/mob/user)
	if(iswrench(W))
		return wrenchAnchor(user, 50)

	attack_hand(user)


/obj/structure/mannequin/examine(mob/user)
	..()
	var/msg = ""
	if(clothing[SLOT_MANNEQUIN_ICLOTHING])
		var/obj/item/clothing/under/w_uniform = clothing[SLOT_MANNEQUIN_ICLOTHING]
		if(w_uniform.blood_DNA && w_uniform.blood_DNA.len)
			msg += "<span class='warning'>It's wearing [bicon(w_uniform)] [w_uniform.gender==PLURAL?"some":"a"] blood-stained [w_uniform.name]![w_uniform.description_accessories()]</span>\n"
		else
			msg += "It's wearing [bicon(w_uniform)] \a [w_uniform].[w_uniform.description_accessories()]\n"

	if(clothing[SLOT_MANNEQUIN_HEAD])
		var/obj/item/head = clothing[SLOT_MANNEQUIN_HEAD]
		if(head.blood_DNA && head.blood_DNA.len)
			msg += "<span class='warning'>It's wearing [bicon(head)] [head.gender==PLURAL?"some":"a"] blood-stained [head.name] on its head![head.description_accessories()]</span>\n"
		else
			msg += "It's wearing [bicon(head)] \a [head] on its head.[head.description_accessories()]\n"

	if(clothing[SLOT_MANNEQUIN_OCLOTHING])
		var/obj/item/wear_suit = clothing[SLOT_MANNEQUIN_OCLOTHING]
		if(wear_suit.blood_DNA && wear_suit.blood_DNA.len)
			msg += "<span class='warning'>It's wearing [bicon(wear_suit)] [wear_suit.gender==PLURAL?"some":"a"] blood-stained [wear_suit.name]![wear_suit.description_accessories()]</span>\n"
		else
			msg += "It's wearing [bicon(wear_suit)] \a [wear_suit].[wear_suit.description_accessories()]\n"

	if(clothing[SLOT_MANNEQUIN_BACK])
		var/obj/item/back = clothing[SLOT_MANNEQUIN_BACK]
		if(back.blood_DNA && back.blood_DNA.len)
			msg += "<span class='warning'>It has [bicon(back)] [back.gender==PLURAL?"some":"a"] blood-stained [back] on its back![back.description_accessories()]</span>\n"
		else
			msg += "It has [bicon(back)] \a [back] on its back.[back.description_accessories()]\n"

	for(var/obj/item/I in held_items)
		if(I.blood_DNA && I.blood_DNA.len)
			msg += "<span class='warning'>I's holding [bicon(I)] [I.gender==PLURAL?"some":"a"] blood-stained [I.name] in its [get_index_limb_name(is_holding_item(I))]!</span>\n"
		else
			msg += "It's holding [bicon(I)] \a [I] in its [get_index_limb_name(is_holding_item(I))].\n"

	if(clothing[SLOT_MANNEQUIN_GLOVES])
		var/obj/item/gloves = clothing[SLOT_MANNEQUIN_GLOVES]
		if(gloves.blood_DNA && gloves.blood_DNA.len)
			msg += "<span class='warning'>It has [bicon(gloves)] [gloves.gender==PLURAL?"some":"a"] blood-stained [gloves.name] on its hands![gloves.description_accessories()]</span>\n"
		else
			msg += "It has [bicon(gloves)] \a [gloves] on its hands.[gloves.description_accessories()]\n"

	if(clothing[SLOT_MANNEQUIN_BELT])
		var/obj/item/belt = clothing[SLOT_MANNEQUIN_BELT]
		if(belt.blood_DNA && belt.blood_DNA.len)
			msg += "<span class='warning'>It has [bicon(belt)] [belt.gender==PLURAL?"some":"a"] blood-stained [belt.name] about its waist![belt.description_accessories()]</span>\n"
		else
			msg += "It has [bicon(belt)] \a [belt] about its waist.[belt.description_accessories()]\n"

	if(clothing[SLOT_MANNEQUIN_FEET])
		var/obj/item/shoes = clothing[SLOT_MANNEQUIN_FEET]
		if(shoes.blood_DNA && shoes.blood_DNA.len)
			msg += "<span class='warning'>It's wearing [bicon(shoes)] [shoes.gender==PLURAL?"some":"a"] blood-stained [shoes.name] on its feet![shoes.description_accessories()]</span>\n"
		else
			msg += "It's wearing [bicon(shoes)] \a [shoes] on its feet.[shoes.description_accessories()]\n"

	if(clothing[SLOT_MANNEQUIN_MASK])
		var/obj/item/wear_mask = clothing[SLOT_MANNEQUIN_MASK]
		if(wear_mask.blood_DNA && wear_mask.blood_DNA.len)
			msg += "<span class='warning'>It has [bicon(wear_mask)] [wear_mask.gender==PLURAL?"some":"a"] blood-stained [wear_mask.name] on its face![wear_mask.description_accessories()]</span>\n"
		else
			msg += "It has [bicon(wear_mask)] \a [wear_mask] on its face.[wear_mask.description_accessories()]\n"

	if(clothing[SLOT_MANNEQUIN_EYES])
		var/obj/item/glasses = clothing[SLOT_MANNEQUIN_EYES]
		if(glasses.blood_DNA && glasses.blood_DNA.len)
			msg += "<span class='warning'>It has [bicon(glasses)] [glasses.gender==PLURAL?"some":"a"] blood-stained [glasses] covering its eyes![glasses.description_accessories()]</span>\n"
		else
			msg += "It has [bicon(glasses)] \a [glasses] covering its eyes.[glasses.description_accessories()]\n"

	if(clothing[SLOT_MANNEQUIN_EARS])
		var/obj/item/ears = clothing[SLOT_MANNEQUIN_EARS]
		msg += "It has [bicon(ears)] \a [ears] on its ears.[ears.description_accessories()]\n"

	if(clothing[SLOT_MANNEQUIN_ID])
		var/obj/item/wear_id = clothing[SLOT_MANNEQUIN_ID]
		msg += "It's wearing [bicon(wear_id)] \a [wear_id].\n"

	to_chat(user, msg)


/obj/structure/mannequin/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				getDamage(30)
			else
				getDamage(20)
		if (3)
			if (prob(50))
				getDamage(10)


/obj/structure/mannequin/bullet_act(var/obj/item/projectile/Proj)
	getDamage(Proj.damage)
	..()


/obj/structure/mannequin/blob_act()
	if (prob(75))
		breakDown()
	else
		getDamage(30)



/obj/structure/mannequin/Topic(href, href_list)
	..()
	if(usr.incapacitated() || !Adjacent(usr) || !iscarbon(usr))
		return
	var/mob/living/carbon/user = usr

	if(href_list["hands"])
		var/obj/item/item_in_hand = usr.get_active_hand()
		var/hand_index = text2num(href_list["hands"])
		if(!item_in_hand)
			if(get_held_item_by_index(hand_index))
				var/obj/item/I = held_items[hand_index]
				user.put_in_hands(I)
				held_items[hand_index] = null
				to_chat(user, "<span class='info'>You pick up \the [I] from \the [src].</span>")
		else
			if(get_held_item_by_index(hand_index))
				user.drop_from_inventory(item_in_hand)
				item_in_hand.forceMove(src)
				var/obj/item/I = held_items[hand_index]
				user.put_in_hands(I)
				held_items[hand_index] = item_in_hand
				to_chat(user, "<span class='info'>You switch \the [item_in_hand] and \the [I] on the [src].</span>")
			else
				user.drop_from_inventory(item_in_hand)
				item_in_hand.forceMove(src)
				held_items[hand_index] = item_in_hand
				to_chat(user, "<span class='info'>You place \the [item_in_hand] on \the [src].</span>")

	else if(href_list["item"])
		var/obj/item/item_in_hand = usr.get_active_hand()
		var/item_slot = href_list["item"]
		if(!item_in_hand)
			if(clothing[item_slot])
				var/obj/item/I = clothing[item_slot]
				user.put_in_hands(I)
				clothing[item_slot] = null
				add_fingerprint(user)
				to_chat(user, "<span class='info'>You pick up \the [I] from \the [src].</span>")
		else
			if(clothing[item_slot])
				if(canEquip(user, item_slot,item_in_hand))
					user.drop_from_inventory(item_in_hand)
					item_in_hand.forceMove(src)
					var/obj/item/I = clothing[item_slot]
					user.put_in_hands(I)
					clothing[item_slot] = item_in_hand
					add_fingerprint(user)
					to_chat(user, "<span class='info'>You switch \the [item_in_hand] and \the [I] on the [src].</span>")
				else
					return
			else
				if(canEquip(user, item_slot,item_in_hand))
					user.drop_from_inventory(item_in_hand)
					item_in_hand.forceMove(src)
					clothing[item_slot] = item_in_hand
					add_fingerprint(user)
					to_chat(user, "<span class='info'>You place \the [item_in_hand] on \the [src].</span>")
				else
					return

	update_icon()
	show_inv(user)


/obj/structure/mannequin/proc/getDamage(var/damage)
	health -= damage
	healthCheck()


/obj/structure/mannequin/proc/healthCheck()
	if (src.health <= 0)
		visible_message("\The [src] collapses.")
		breakDown()


/obj/structure/mannequin/proc/breakDown()
	getFromPool(/obj/effect/decal/cleanable/dirt,loc)
	qdel(src)



////////////////HANDS STUFF//////////////////
/obj/structure/mannequin/proc/get_item_offset_by_index(index)//Will come to use when we get multi-handed mannequins
	return list()

/obj/structure/mannequin/proc/get_held_item_by_index(index)
	if(!is_valid_hand_index(index))
		return null

	return held_items[index]

/obj/structure/mannequin/proc/get_index_limb_name(var/index)
	switch(index)
		if(GRASP_LEFT_HAND)
			return "left hand"
		if(GRASP_RIGHT_HAND)
			return "right hand"

	return "hand"

/obj/structure/mannequin/proc/is_holding_item(item)
	return held_items.Find(item)

/obj/structure/mannequin/proc/get_direction_by_index(index)
	if(index % 2 == GRASP_RIGHT_HAND)
		return "right_hand"
	else
		return "left_hand"
////////////////HANDS STUFF END//////////////////

/obj/structure/mannequin/proc/show_inv(var/mob/user)
	var/dat

	for(var/i = 1 to held_items.len)
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(get_held_item_by_index(i))]</A><BR>"

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_BACK]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_BACK])]</A>"
	dat += "<BR>"
	dat += "<BR><B>Head:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_HEAD]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_HEAD])]</A>"
	dat += "<BR><B>Mask:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_MASK]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_MASK])]</A>"
	dat += "<BR><B>Eyes:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_EYES]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_EYES])]</A>"
	if(!primitive)
		dat += "<BR><B>Ears:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_EARS]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_EARS])]</A>"
	dat += "<BR>"
	if(!primitive)
		dat += "<BR><B>Exosuit:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_OCLOTHING]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_OCLOTHING])]</A>"
		dat += "<BR><B>Shoes:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_FEET]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_FEET])]</A>"
		dat += "<BR><B>Gloves:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_GLOVES]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_GLOVES])]</A>"
	dat += "<BR><B>Uniform:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_ICLOTHING]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_ICLOTHING])]</A>"
	if(!primitive)
		dat += "<BR><B>Belt:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_BELT]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_BELT])]</A>"
		dat += "<BR><B>ID:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_ID]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_ID])]</A>"
	dat += "<BR>"
	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mannequin\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()


/obj/structure/mannequin/proc/canEquip(var/mob/user, var/item_slot, var/obj/item/itemToCheck)
	if((fat && ((item_slot == SLOT_MANNEQUIN_ICLOTHING) || (item_slot == SLOT_MANNEQUIN_OCLOTHING))) || ((species.flags & IS_BULKY) && ((item_slot == SLOT_MANNEQUIN_ICLOTHING) || (item_slot == SLOT_MANNEQUIN_OCLOTHING) || (item_slot == SLOT_MANNEQUIN_FEET) || (item_slot == SLOT_MANNEQUIN_GLOVES) || (item_slot == SLOT_MANNEQUIN_MASK))))
		if(!(itemToCheck.flags & ONESIZEFITSALL))
			if(user)
				to_chat(user, "<span class='warning'>\The [src] is too large for \the [itemToCheck]</span>")
			return 0

	var/inv_slot

	switch(item_slot)
		if(SLOT_MANNEQUIN_ICLOTHING)
			inv_slot = SLOT_ICLOTHING
		if(SLOT_MANNEQUIN_FEET)
			inv_slot = SLOT_FEET
		if(SLOT_MANNEQUIN_GLOVES)
			inv_slot = SLOT_GLOVES
		if(SLOT_MANNEQUIN_EARS)
			inv_slot = SLOT_EARS
		if(SLOT_MANNEQUIN_OCLOTHING)
			inv_slot = SLOT_OCLOTHING
		if(SLOT_MANNEQUIN_EYES)
			inv_slot = SLOT_EYES
		if(SLOT_MANNEQUIN_BELT)
			inv_slot = SLOT_BELT
		if(SLOT_MANNEQUIN_MASK)
			inv_slot = SLOT_MASK
		if(SLOT_MANNEQUIN_HEAD)
			inv_slot = SLOT_HEAD
		if(SLOT_MANNEQUIN_BACK)
			inv_slot = SLOT_BACK
		if(SLOT_MANNEQUIN_ID)
			inv_slot = SLOT_ID

	if(itemToCheck.slot_flags & inv_slot)
		return 1

	if(user)
		to_chat(user, "<span class='warning'>\The [itemToCheck] doesn't fit there.</span>")
	return 0

/obj/structure/mannequin/update_icon()
	..()
	overlays.len = 0
	var/obj/Overlays/O = getFromPool(/obj/Overlays/)
	O.layer = FLOAT_LAYER
	O.overlays.len = 0

	update_icon_slot(O,SLOT_MANNEQUIN_ICLOTHING)
	update_icon_slot(O,SLOT_MANNEQUIN_FEET)
	update_icon_slot(O,SLOT_MANNEQUIN_GLOVES)
	update_icon_slot(O,SLOT_MANNEQUIN_EARS)
	update_icon_slot(O,SLOT_MANNEQUIN_OCLOTHING)
	update_icon_slot(O,SLOT_MANNEQUIN_EYES)
	update_icon_slot(O,SLOT_MANNEQUIN_BELT)
	update_icon_slot(O,SLOT_MANNEQUIN_MASK)
	update_icon_slot(O,SLOT_MANNEQUIN_HEAD)
	update_icon_slot(O,SLOT_MANNEQUIN_BACK)
	update_icon_slot(O,SLOT_MANNEQUIN_ID)

	for(var/i in 1 to held_items.len)
		update_icon_hand(O,i)

	var/image/I = new()
	I.appearance = O.appearance
	I.plane = FLOAT_PLANE
	I.pixel_x = clothing_offset_x
	I.pixel_y = clothing_offset_y
	overlays += I
	returnToPool(O)

/obj/structure/mannequin/proc/update_icon_slot(var/obj/Overlays/O, var/slot)
	var/obj/item/clothing/clothToUpdate = clothing[slot]
	if(clothToUpdate)
		var/t_state = clothToUpdate._color
		if(!t_state)
			t_state = clothToUpdate.icon_state

		var/image/I

		switch(slot)
			if(SLOT_MANNEQUIN_ICLOTHING,SLOT_MANNEQUIN_OCLOTHING)
				if(fat || species.flags & IS_BULKY)
					if(clothToUpdate.flags&ONESIZEFITSALL)
						I = image(get_fat_icons(slot), "[t_state]_s")
				else if(primitive)
					t_state = clothToUpdate.item_state
					if(!t_state)
						t_state = clothToUpdate.icon_state
					I = image(get_primitive_icons(slot), "[t_state]")
				else
					I = image(get_slot_icons(slot), "[t_state][(slot == SLOT_MANNEQUIN_ICLOTHING) ? "_s" : ""]")
			else
				if(primitive)
					I = image(get_primitive_icons(slot), t_state)
				else if(clothToUpdate.icon_override)
					I = image(clothToUpdate.icon_override, t_state)
				else
					I = image(get_slot_icons(slot), t_state)

		if(species.name in clothToUpdate.species_fit)
			var/icon/species_icon = get_species_icons(slot)
			if(species_icon)
				I.icon = species_icon

		if(clothToUpdate.icon_override)
			I.icon	= clothToUpdate.icon_override

		O.overlays += I

		if(clothToUpdate.dynamic_overlay)
			if(clothToUpdate.dynamic_overlay["[get_dynamic_layer(slot)]"])
				var/image/dyn_overlay = clothToUpdate.dynamic_overlay["[get_dynamic_layer(slot)]"]
				O.overlays += dyn_overlay

		if(clothToUpdate.blood_DNA && clothToUpdate.blood_DNA.len)
			var/bloodsies_state = get_bloodsies_state(clothToUpdate,slot)
			if(bloodsies_state)
				var/image/bloodsies	= image('icons/effects/blood.dmi', bloodsies_state)
				bloodsies.color		= clothToUpdate.blood_color
				O.overlays += bloodsies

		clothToUpdate.generate_accessory_overlays(O)

/obj/structure/mannequin/proc/update_icon_hand(var/obj/Overlays/O,var/index)
	var/obj/item/heldItem = get_held_item_by_index(index)

	if(heldItem)
		var/t_state = heldItem.item_state
		var/t_inhand_state = heldItem.inhand_states[get_direction_by_index(index)]
		var/icon/check_dimensions = new(t_inhand_state)
		if(!t_state)
			t_state = heldItem.icon_state

		var/image/I  = image(t_inhand_state, t_state)
		I.pixel_x = -1*(check_dimensions.Width() - WORLD_ICON_SIZE)/2
		I.pixel_y = -1*(check_dimensions.Height() - WORLD_ICON_SIZE)/2

		var/list/offsets = get_item_offset_by_index(index)

		I.pixel_x += offsets["x"]
		I.pixel_y += offsets["y"]

		if(heldItem.dynamic_overlay && heldItem.dynamic_overlay["[HAND_LAYER]-[index]"])
			var/image/dyn_overlay = heldItem.dynamic_overlay["[HAND_LAYER]-[index]"]
			O.overlays += dyn_overlay

		O.overlays += I

/obj/structure/mannequin/proc/get_slot_icons(var/slot)
	switch(slot)
		if(SLOT_MANNEQUIN_ICLOTHING)
			return 'icons/mob/uniform.dmi'
		if(SLOT_MANNEQUIN_FEET)
			return 'icons/mob/feet.dmi'
		if(SLOT_MANNEQUIN_GLOVES)
			return 'icons/mob/hands.dmi'
		if(SLOT_MANNEQUIN_EARS)
			return 'icons/mob/ears.dmi'
		if(SLOT_MANNEQUIN_OCLOTHING)
			return 'icons/mob/suit.dmi'
		if(SLOT_MANNEQUIN_EYES)
			return 'icons/mob/eyes.dmi'
		if(SLOT_MANNEQUIN_BELT)
			return 'icons/mob/belt.dmi'
		if(SLOT_MANNEQUIN_MASK)
			return 'icons/mob/mask.dmi'
		if(SLOT_MANNEQUIN_HEAD)
			return 'icons/mob/head.dmi'
		if(SLOT_MANNEQUIN_BACK)
			return 'icons/mob/back.dmi'
		if(SLOT_MANNEQUIN_ID)
			return 'icons/mob/ids.dmi'
		else
			return null

/obj/structure/mannequin/proc/get_primitive_icons(var/slot)
	switch(slot)
		if(SLOT_MANNEQUIN_ICLOTHING)
			return 'icons/mob/monkey.dmi'
		if(SLOT_MANNEQUIN_FEET)
			return 'icons/mob/feet.dmi'
		if(SLOT_MANNEQUIN_GLOVES)
			return 'icons/mob/hands.dmi'
		if(SLOT_MANNEQUIN_EARS)
			return 'icons/mob/ears.dmi'
		if(SLOT_MANNEQUIN_OCLOTHING)
			return 'icons/mob/suit.dmi'
		if(SLOT_MANNEQUIN_EYES)
			return 'icons/mob/monkey_eyes.dmi'
		if(SLOT_MANNEQUIN_BELT)
			return 'icons/mob/belt.dmi'
		if(SLOT_MANNEQUIN_MASK)
			return 'icons/mob/monkey.dmi'
		if(SLOT_MANNEQUIN_HEAD)
			return 'icons/mob/monkey_head.dmi'
		if(SLOT_MANNEQUIN_BACK)
			return 'icons/mob/back.dmi'
		if(SLOT_MANNEQUIN_ID)
			return 'icons/mob/ids.dmi'
		else
			return null

/obj/structure/mannequin/proc/get_species_icons(var/slot)
	switch(slot)
		if(SLOT_MANNEQUIN_ICLOTHING)
			return species.uniform_icons
		if(SLOT_MANNEQUIN_FEET)
			return species.shoes_icons
		if(SLOT_MANNEQUIN_GLOVES)
			return species.gloves_icons
		if(SLOT_MANNEQUIN_EARS)
			return species.ears_icons
		if(SLOT_MANNEQUIN_OCLOTHING)
			return species.wear_suit_icons
		if(SLOT_MANNEQUIN_EYES)
			return species.glasses_icons
		if(SLOT_MANNEQUIN_BELT)
			return species.belt_icons
		if(SLOT_MANNEQUIN_MASK)
			return species.wear_mask_icons
		if(SLOT_MANNEQUIN_HEAD)
			return species.head_icons
		if(SLOT_MANNEQUIN_BACK)
			return species.back_icons
		else
			return null

/obj/structure/mannequin/proc/get_fat_icons(var/slot)
	switch(slot)
		if(SLOT_MANNEQUIN_ICLOTHING)
			return species.fat_uniform_icons
		if(SLOT_MANNEQUIN_OCLOTHING)
			return species.fat_wear_suit_icons
		else
			return null

/obj/structure/mannequin/proc/get_dynamic_layer(var/slot)
	switch(slot)
		if(SLOT_MANNEQUIN_ICLOTHING)
			return UNIFORM_LAYER
		if(SLOT_MANNEQUIN_FEET)
			return SHOES_LAYER
		if(SLOT_MANNEQUIN_GLOVES)
			return GLOVES_LAYER
		if(SLOT_MANNEQUIN_EARS)
			return EARS_LAYER
		if(SLOT_MANNEQUIN_OCLOTHING)
			return SUIT_LAYER
		if(SLOT_MANNEQUIN_EYES)
			return GLASSES_LAYER
		if(SLOT_MANNEQUIN_BELT)
			return BELT_LAYER
		if(SLOT_MANNEQUIN_MASK)
			return FACEMASK_LAYER
		if(SLOT_MANNEQUIN_HEAD)
			return HEAD_LAYER
		if(SLOT_MANNEQUIN_BACK)
			return BACK_LAYER
		if(SLOT_MANNEQUIN_ID)
			return ID_LAYER
		else
			return null

/obj/structure/mannequin/proc/get_bloodsies_state(var/obj/item/bloodied,var/slot)
	switch(slot)
		if(SLOT_MANNEQUIN_ICLOTHING)
			return "uniformblood"
		if(SLOT_MANNEQUIN_FEET)
			return "shoeblood"
		if(SLOT_MANNEQUIN_GLOVES)
			return "bloodyhands"
		if(SLOT_MANNEQUIN_OCLOTHING)
			var/obj/item/clothing/suit/C = bloodied
			return "[C.blood_overlay_type]blood"
		if(SLOT_MANNEQUIN_MASK)
			return "maskblood"
		if(SLOT_MANNEQUIN_HEAD)
			return "helmetblood"
		else
			return null

/obj/structure/mannequin/proc/checkMappingWear()
	if(mapping_uniform)
		var/obj/item/clothToWear = new mapping_uniform(src)
		if(canEquip(null, SLOT_MANNEQUIN_ICLOTHING, clothToWear))
			clothing[SLOT_MANNEQUIN_ICLOTHING] = clothToWear
		else
			qdel(clothToWear)
	if(mapping_shoes)
		var/obj/item/clothToWear = new mapping_shoes(src)
		if(canEquip(null, SLOT_MANNEQUIN_FEET, clothToWear))
			clothing[SLOT_MANNEQUIN_FEET] = clothToWear
		else
			qdel(clothToWear)
	if(mapping_gloves)
		var/obj/item/clothToWear = new mapping_gloves(src)
		if(canEquip(null, SLOT_MANNEQUIN_GLOVES, clothToWear))
			clothing[SLOT_MANNEQUIN_GLOVES] = clothToWear
		else
			qdel(clothToWear)
	if(mapping_ears)
		var/obj/item/clothToWear = new mapping_ears(src)
		if(canEquip(null, SLOT_MANNEQUIN_EARS, clothToWear))
			clothing[SLOT_MANNEQUIN_EARS] = clothToWear
		else
			qdel(clothToWear)
	if(mapping_suit)
		var/obj/item/clothToWear = new mapping_suit(src)
		if(canEquip(null, SLOT_MANNEQUIN_OCLOTHING, clothToWear))
			clothing[SLOT_MANNEQUIN_OCLOTHING] = clothToWear
		else
			qdel(clothToWear)
	if(mapping_glasses)
		var/obj/item/clothToWear = new mapping_glasses(src)
		if(canEquip(null, SLOT_MANNEQUIN_EYES, clothToWear))
			clothing[SLOT_MANNEQUIN_EYES] = clothToWear
		else
			qdel(clothToWear)
	if(mapping_belt)
		var/obj/item/clothToWear = new mapping_belt(src)
		if(canEquip(null, SLOT_MANNEQUIN_BELT, clothToWear))
			clothing[SLOT_MANNEQUIN_BELT] = clothToWear
		else
			qdel(clothToWear)
	if(mapping_hat)
		var/obj/item/clothToWear = new mapping_hat(src)
		if(canEquip(null, SLOT_MANNEQUIN_HEAD, clothToWear))
			clothing[SLOT_MANNEQUIN_HEAD] = clothToWear
		else
			qdel(clothToWear)
	if(mapping_mask)
		var/obj/item/clothToWear = new mapping_mask(src)
		if(canEquip(null, SLOT_MANNEQUIN_MASK, clothToWear))
			clothing[SLOT_MANNEQUIN_MASK] = clothToWear
		else
			qdel(clothToWear)
	if(mapping_back)
		var/obj/item/clothToWear = new mapping_back(src)
		if(canEquip(null, SLOT_MANNEQUIN_BACK, clothToWear))
			clothing[SLOT_MANNEQUIN_BACK] = clothToWear
		else
			qdel(clothToWear)
	if(mapping_id)
		var/obj/item/clothToWear = new mapping_id(src)
		if(canEquip(null, SLOT_MANNEQUIN_ID, clothToWear))
			clothing[SLOT_MANNEQUIN_ID] = clothToWear
		else
			qdel(clothToWear)

	if(mapping_hand_right)
		var/obj/item/clothToWear = new mapping_hand_right(src)
		held_items[GRASP_RIGHT_HAND] = clothToWear
	if(mapping_hand_left)
		var/obj/item/clothToWear = new mapping_hand_left(src)
		held_items[GRASP_LEFT_HAND] = clothToWear

	update_icon()


/obj/structure/mannequin/proc/spin()
	change_dir(turn(dir, 90))

/obj/structure/mannequin/verb/rotate_mannequin()
	set name = "Rotate Mannequin"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return

	if(anchored)
		return

	if(usr.isUnconscious() || usr.restrained())
		return

	spin()


/obj/structure/mannequin/fat
	name = "fat human marble mannequin"
	icon_state="mannequin_marble_fat_human"
	fat = 1

/obj/structure/mannequin/vox
	name = "vox marble mannequin"
	icon_state="mannequin_marble_vox"
	species_type = /datum/species/vox

/obj/structure/mannequin/monkey
	name = "monkey marble mannequin"
	icon_state="mannequin_marble_monkey"
	primitive = 1
	clothing_offset_y = -5*PIXEL_MULTIPLIER

/obj/structure/mannequin/wood
	name = "human wooden mannequin"
	desc = "This should look great in a visual arts workshop."
	icon_state="mannequin_wooden_human"
	health = 30
	maxHealth = 30

/obj/structure/mannequin/wood/breakDown()
	getFromPool(/obj/item/stack/sheet/wood, loc, 5)//You get half the materials used to make a block back
	..()

/obj/structure/mannequin/wood/fat
	name = "fat human wooden mannequin"
	icon_state="mannequin_wooden_fat_human"
	fat = 1

/obj/structure/mannequin/wood/vox
	name = "vox wooden mannequin"
	icon_state="mannequin_wooden_vox"
	species_type = /datum/species/vox

/obj/structure/mannequin/wood/monkey
	name = "monkey wooden mannequin"
	icon_state="mannequin_wooden_monkey"
	primitive = 1
	clothing_offset_y = -5*PIXEL_MULTIPLIER



/////////////////////////////////////////////////////////BLOCKS//////////////////////////////////////////////////////////
//Use a chisel on those to sculpt them into mannequins.

/obj/structure/block
	name = "marble block"
	desc = "Grab your chisel and get to work!"
	anchored = 0
	density = 1
	icon = 'icons/obj/mannequin.dmi'
	icon_state = "marble"
	var/time_to_sculpt = 200
	var/list/available_sculptures = list(
		"human"		=	/obj/structure/mannequin,
		"fat human"	=	/obj/structure/mannequin/fat,
		"monkey"	=	/obj/structure/mannequin/monkey,
		"vox"		=	/obj/structure/mannequin/vox,
		)


/obj/structure/block/attackby(var/obj/item/weapon/W,var/mob/user)
	if(iswrench(W))
		return wrenchAnchor(user, 50)
	else if(istype(W, /obj/item/weapon/chisel))

		var/chosen_sculpture = input("Choose a sculpture type.", "[name]") as null|anything in available_sculptures

		if(!chosen_sculpture || !Adjacent(user))
			return

		user.visible_message("[user.name] starts sculpting \the [src] with a passion!","You start sculpting \the [src] with a passion!","You hear a repeated knocking sound.")
		var/turf/T=get_turf(src)

		if(do_after(user, src, time_to_sculpt))
			getFromPool(/obj/effect/decal/cleanable/dirt,T)
			var/mannequin_type = available_sculptures[chosen_sculpture]
			var/obj/structure/mannequin/M = new mannequin_type(T)
			M.anchored = anchored
			M.add_fingerprint(user)
			user.visible_message("[user.name] finishes \the [M].","You finish \the [M].")
			qdel(src)
		return 1
	else
		..()


/obj/structure/block/wood
	name = "wooden block"
	icon_state = "wooden"
	time_to_sculpt = 100
	available_sculptures = list(
		"human"		=	/obj/structure/mannequin/wood,
		"fat human"	=	/obj/structure/mannequin/wood/fat,
		"monkey"	=	/obj/structure/mannequin/wood/monkey,
		"vox"		=	/obj/structure/mannequin/wood/vox,
		)







/////////////////////////////////////////////////////////CYBER MANNEQUIN//////////////////////////////////////////////////////////
//Mannequin meets Display Case.

/obj/structure/mannequin/cyber
	name = "human cyber mannequin"
	desc = "Holy shit."
	icon = 'icons/obj/mannequin_64x64.dmi'
	icon_state="mannequin_cyber_human"
	pixel_x = -1*(WORLD_ICON_SIZE/2)
	clothing_offset_x = 16*PIXEL_MULTIPLIER
	clothing_offset_y = 7*PIXEL_MULTIPLIER
	health = 150
	maxHealth = 150
	var/shield = 50
	var/maxShield = 50
	var/destroyed = 0
	var/locked = 0

/obj/structure/mannequin/cyber/New()
	..()
	update_icon()

/obj/structure/mannequin/cyber/breakDown()
	getFromPool(/obj/item/stack/sheet/metal, loc, 5)//You get half the materials used to make a mannequin frame back.
	var/parts_list = list(
		/obj/item/robot_parts/head,
		/obj/item/robot_parts/chest,
		/obj/item/robot_parts/r_leg,
		/obj/item/robot_parts/l_leg,
		/obj/item/robot_parts/r_arm,
		/obj/item/robot_parts/l_arm,
		/obj/item/robot_parts/l_arm,
		)

	for(var/part in parts_list)
		if(prob(40))//And 40% chance to get each robot limb back.
			new part(loc)

	if(prob(40))
		var/obj/item/weapon/circuitboard/airlock/C = new(loc)
		C.one_access=!(req_access && req_access.len>0)
		if(!C.one_access)
			C.conf_access=req_access
		else
			C.conf_access=req_one_access

	qdel(src)


/obj/structure/mannequin/cyber/ex_act(severity)
	switch(severity)
		if (1)
			if(destroyed)
				qdel(src)
			else
				destroyed = 1
				getFromPool(/obj/item/weapon/shard, loc)
				playsound(get_turf(src), "shatter", 100, 1)
				shield = 0
				update_icon()
		if (2)
			if (prob(50))
				getDamage(30)
			else
				getDamage(20)
		if (3)
			if (prob(50))
				getDamage(10)

/obj/structure/mannequin/cyber/getDamage(var/damage)
	if(destroyed || !locked)
		health -= damage
	else
		shield -= damage
	healthCheck()

/obj/structure/mannequin/cyber/blob_act()
	if(!destroyed && locked)
		getDamage(30)
	else if (prob(75))
		breakDown()
	else
		getDamage(30)

/obj/structure/mannequin/cyber/healthCheck()
	if(!destroyed)
		if(health <= 100)
			destroyed = 1
			locked = 0
			getFromPool(/obj/item/weapon/shard, loc)
			playsound(get_turf(src), "shatter", 100, 1)
			update_icon()
		else
			playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
	else
		if(health <= 0)
			visible_message("\The [src] collapses.")
			breakDown()

/obj/structure/mannequin/cyber/attackby(var/obj/item/weapon/W,var/mob/user)
	if(istype(W, /obj/item/weapon/card/id))
		if(destroyed)
			to_chat(user, "<span class='warning'>There is no longer any lock to toggle.</span>")
		else
			var/obj/item/weapon/card/id/I=W
			if(!check_access(I))
				to_chat(user, "<span class='rose'>Access denied.</span>")
				return
			locked = !locked
			if(!locked)
				to_chat(user, "[bicon(src)] <span class='notice'>\The [src] clicks as locks release, and it slowly opens for you.</span>")
			else
				to_chat(user, "[bicon(src)] <span class='notice'>You close \the [src] and swipe your card, locking it.</span>")
			update_icon()
	else if(iscrowbar(W) && (!locked || destroyed))
		user.visible_message("[user.name] pries \the [src] apart.", \
			"You pry \the [src] apart.", \
			"You hear something pop.")
		var/turf/T=get_turf(src)
		playsound(T, 'sound/items/Crowbar.ogg', 50, 1)

		if(do_after(user, src, 100))
			var/obj/item/weapon/circuitboard/airlock/C = new(src)
			C.one_access=!(req_access && req_access.len>0)

			if(!C.one_access)
				C.conf_access=req_access
			else
				C.conf_access=req_one_access

			if(!destroyed)
				getFromPool(/obj/item/stack/sheet/glass/glass, T, 1)

			C.forceMove(T)

			var/obj/structure/mannequin_frame/new_frame = new(T)
			new_frame.icon_state = "mannequin_cyber_human"
			new_frame.overlays |= image(icon, "lightout")
			new_frame.construct = new /datum/construction/mannequin(new_frame)
			qdel(src)

	else if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent == I_HELP)
		if(locked)
			to_chat(user, "<span class='warning'>You need to open the shield before you can fix the mannequin.</span>")
		else
			if(health >= maxHealth)
				to_chat(user, "<span class='warning'>Nothing to fix here!</span>")
				return
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(5))
				playsound(loc, 'sound/items/Welder.ogg', 50, 1)
				health = min(health + 20, maxHealth)
				to_chat(user, "<span class='notice'>You fix some of the dents on \the [src]!</span>")
			else
				to_chat(user, "<span class='warning'>Need more welding fuel!</span>")
				return

	else if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent == I_HELP)
		if(locked)
			to_chat(user, "<span class='warning'>You need to open the shield before you can fix the mannequin.</span>")
		else
			if(health >= maxHealth)
				to_chat(user, "<span class='warning'>Nothing to fix here!</span>")
				return
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(5))
				playsound(loc, 'sound/items/Welder.ogg', 50, 1)
				health = min(health + 20, maxHealth)
				to_chat(user, "<span class='notice'>You fix some of the dents on \the [src]!</span>")
			else
				to_chat(user, "<span class='warning'>Need more welding fuel!</span>")
				return

	else if(istype(W, /obj/item/device/silicate_sprayer))
		if(!locked)
			to_chat(user, "<span class='warning'>You need to lock the shield before you can fix it.</span>")
		else
			if(shield >= maxShield)
				to_chat(user, "<span class='warning'>Nothing to fix here!</span>")
				return
			var/obj/item/device/silicate_sprayer/SS = W
			if(SS.get_amount() >= 5)
				SS.remove_silicate(5)
				playsound(loc, 'sound/effects/refill.ogg', 50, 1)
				shield = min(shield + 20, maxShield)
				to_chat(user, "<span class='notice'>You fix some of the dents on \the [src]'s shield!</span>")
			else
				to_chat(user, "<span class='warning'>Need more silicate!</span>")
				return

	else if(user.a_intent == I_HURT)
		user.delayNextAttack(8)
		getDamage(W.force)
		user.visible_message("<span class='danger'>[user.name] [W.attack_verb] \the [src]!</span>", "<span class='danger'>You [W.attack_verb] \the [src]!</span>")
	else
		return ..()

/obj/structure/mannequin/cyber/update_icon()
	overlays.len = 0
	..()
	if(destroyed)
		overlays |= image(icon, "mannequin_cover_broken")
	else if(locked)
		overlays |= image(icon, "mannequin_cover")


/obj/structure/mannequin/cyber/attack_hand(var/mob/living/user)
	if(destroyed)
		show_inv(user)
	else if(locked)
		if(user.a_intent == I_HURT)
			user.delayNextAttack(8)
			user.visible_message("<span class='danger'>[user.name] punches \the [src]!</span>", "<span class='danger'>You punch \the [src]!</span>", "You hear glass crack.")
			getDamage(rand(1,7) * (user.get_strength() - 1))
		else
			to_chat(user,"<span class='notice'>You gently run your hands over \the [src] in appreciation of its contents.</span>")
	else
		..()


/obj/structure/mannequin/cyber/kick_act(mob/living/carbon/human/H)
	if(locked)
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 100, 1)
	..()


/obj/structure/mannequin/cyber/examine(mob/user)
	..()
	if(destroyed)
		to_chat(user, "Its glass shield has been shattered.")

/obj/structure/mannequin/cyber/broken
	health = 100
	destroyed = 1





/////////////////////////////////////////////////////////MANNEQUIN FRAME//////////////////////////////////////////////////////////
//Used to build cyber mannequins.

/obj/structure/mannequin_frame
	name = "human cyber mannequin frame"
	desc = "Lots of work just to display some clothes."
	icon = 'icons/obj/mannequin_64x64.dmi'
	icon_state="mannequin_cyber_human_frame"
	pixel_x = -1*(WORLD_ICON_SIZE/2)
	anchored = 0
	density = 0
	var/datum/construction/construct

/obj/structure/mannequin_frame/New()
	..()
	construct = new /datum/construction/mannequin_frame(src)

/obj/structure/mannequin_frame/attackby(var/obj/item/W, var/mob/user)
	if(!construct || !construct.action(W, user))
		..()

/datum/construction/mannequin_frame/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
	holder.overlays += image(holder.icon, used_atom.icon_state)
	qdel (used_atom)
	used_atom = null
	return 1

/datum/construction/mannequin_frame/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)

/datum/construction/mannequin_frame
	steps = list(
				list(Co_KEY=/obj/item/robot_parts/head),
				list(Co_KEY=/obj/item/robot_parts/chest),
				list(Co_KEY=/obj/item/robot_parts/r_leg),
				list(Co_KEY=/obj/item/robot_parts/l_leg),
				list(Co_KEY=/obj/item/robot_parts/r_arm),
				list(Co_KEY=/obj/item/robot_parts/l_arm)
				)

/datum/construction/mannequin_frame/spawn_result(mob/user as mob)
	var/obj/structure/mannequin_frame/const_holder = holder
	const_holder.construct = new /datum/construction/mannequin(const_holder)
	const_holder.overlays.len = 0
	const_holder.icon_state = "mannequin_cyber_human"
	const_holder.overlays |= icon(const_holder.icon, "lightout")
	qdel(src)

/datum/construction/mannequin

/datum/construction/mannequin
	result = /obj/structure/mannequin/cyber
	var/base_icon = "station_map_frame"

	steps = list(
		list(
			Co_DESC="The frame needs a glass shield.",
			Co_KEY=/obj/item/stack/sheet/glass/glass,
			Co_AMOUNT = 1,
			Co_VIS_MSG = "{USER} install{s} the glass shield to {HOLDER}.",
			Co_DELAY = 20
			),
		list(
			Co_DESC="The frame needs an airlock circuitboard.",
			Co_KEY=/obj/item/weapon/circuitboard/airlock,
			Co_AMOUNT = 1,
			Co_VIS_MSG = "{USER} install{s} the circuitboard into {HOLDER}.",
			)
		)

/datum/construction/mannequin/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	if(istype(used_atom, /obj/item/weapon/circuitboard/airlock))
		var/obj/item/weapon/circuitboard/airlock/circuit = used_atom
		var/obj/structure/mannequin_frame/const_holder = holder
		if(circuit.one_access)
			const_holder.req_access = null
			const_holder.req_one_access = circuit.conf_access
		else
			const_holder.req_access = circuit.conf_access
			const_holder.req_one_access = null

		const_holder.icon_state = "mannequin_cyber_human"
		const_holder.overlays -= icon(const_holder.icon, "lightout")

	return 1

/datum/construction/mannequin/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/mannequin/spawn_result(mob/user as mob)
	if(result)
		testing("[user] finished a [result]!")

		var/obj/structure/mannequin_frame/const_holder = holder
		var/obj/structure/mannequin/cyber/C = new result(get_turf(holder))
		C.anchored = 0
		C.req_access = const_holder.req_access
		C.req_one_access = const_holder.req_one_access

		qdel (holder)
		holder = null

	feedback_inc("cyber_mannequin_created",1)
