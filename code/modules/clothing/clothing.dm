/obj/item/clothing
	name = "clothing"
	sterility = 5
	w_type = RECYK_FABRIC
	flammable = TRUE
	starting_materials = list(MAT_FABRIC = CC_PER_SHEET_FABRIC)
	var/list/species_restricted = null //Only these species can wear this kit.
	var/wizard_garb = 0 //Wearing this empowers a wizard.
	var/gentling //If TRUE, prevents the wearer from casting wizard spells.
	var/eyeprot = 0 //for head and eyewear
	var/nearsighted_modifier = 0 //positive values impair vision(welding goggles), negative values improve vision(prescription glasses)

	//temperatures in Kelvin. These default values won't affect protections in any way.
	var/cold_breath_protection = 300 //that cloth protects its wearer's breath from cold air down to that temperature
	var/hot_breath_protection = 300 //that cloth protects its wearer's breath from hot air up to that temperature

	var/cold_speed_protection = 300 //that cloth allows its wearer to keep walking at normal speed at lower temperatures

	var/list/obj/item/clothing/accessory/accessories = list()
	var/hidecount = 0
	var/extinguishingProb = 15

//Sound stuff
//sound_change flags are CLOTHING_SOUND_SCREAM and CLOTHING_SOUND_COUGH
//sound_priority are CLOTHING_SOUND_[level]_PRIORITY, replace [level] with LOW/MED/HIGH
	var/list/sound_change //Clothing can change audible emotes, this will determine what is affected
	var/sound_priority //The priority of the clothing when it comes to playing sounds, higher priority means it will always play first otherwise it will randomly pick
	var/list/sound_file //The actual files to be played, it will pick from the list
	var/list/sound_species_whitelist
	var/list/sound_genders_allowed //Checks for what gender it is allowed to play the sound for


	//used for dyeing
	var/list/dyeable_parts = list()
	var/list/dyed_parts = list()
	var/cloth_layer
	var/cloth_icon
	var/dye_base_iconstate_override
	var/dye_base_itemstate_override

	// Hood stuff. Moved to base clothing so it can be used by both uniforms and suits
	var/obj/item/clothing/head/hood // Headgear to be used as hood, if any.
									// Doesn't actually need a 'icons/mob/head.dmi' sprite if the hood_up_icon_state
									//  already provides the visuals for that (eg: most wintercoats in wintercoat.dm)
	var/is_hood_up = FALSE
	var/hood_suit_name = "coat" 	// What to call these garments when talking hood stuff. eg: coat, robes, hoodie...
	var/hood_down_icon_state = null // Defaults to the initial icon_state if not set
	var/hood_up_icon_state = null   // Defaults to the initial icon_state if not set
	var/force_hood = FALSE			// Automatically equips the hood when equipping the suit. Removing the hood will remove the suit.
	var/auto_hood = FALSE			// Automatically equips the hood when equipping the suit.

/obj/item/clothing/New()
	if (hood)
		hood.hood_suit = src
		if (!force_hood)
			actions_types |= list(/datum/action/item_action/toggle_hood)
		if (wizard_garb)
			hood.wizard_garb = TRUE
		if (!hood_down_icon_state)
			hood_down_icon_state = icon_state
		if (!hood_up_icon_state)
			hood_up_icon_state = icon_state
		icon_state = hood_down_icon_state
	..()
	update_icon()

/obj/item/clothing/Destroy()
	for(var/obj/item/clothing/accessory/A in accessories)
		accessories.Remove(A)
		qdel(A)
	if (hood)
		QDEL_NULL(hood)
	..()

/obj/item/clothing/update_icon()
	..()
	overlays.len = 0
	dynamic_overlay.len = 0
	var/image/dyn_overlay_worn
	var/image/dyn_overlay_left
	var/image/dyn_overlay_right

	if ((luminosity > 0) || (dyed_parts.len > 0))
		dyn_overlay_worn = image('icons/effects/32x32.dmi', src, "blank")
		dyn_overlay_left = image('icons/effects/32x32.dmi', src, "blank")
		dyn_overlay_right = image('icons/effects/32x32.dmi', src, "blank")

	if (luminosity > 0)
		update_moody_light_index("luminous_clothing", image_override = image(icon, src, icon_state))
		//dynamic in-hands moody lights
		var/image/worn_moody = image(cloth_icon, src, "[icon_state][(cloth_layer == UNIFORM_LAYER) ? "_s" : ""]")
		var/image/left_moody = image(inhand_states["left_hand"], src, item_state)
		var/image/right_moody = image(inhand_states["right_hand"], src, item_state)
		worn_moody.blend_mode = BLEND_ADD
		worn_moody.plane = LIGHTING_PLANE
		dyn_overlay_worn.overlays += worn_moody
		left_moody.blend_mode = BLEND_ADD
		left_moody.plane = LIGHTING_PLANE
		dyn_overlay_left.overlays += left_moody
		right_moody.blend_mode = BLEND_ADD
		right_moody.plane = LIGHTING_PLANE
		dyn_overlay_right.overlays += right_moody

	if (dyed_parts.len > 0)
		if (!cloth_layer || !cloth_icon)
			return
		for (var/part in dyed_parts)
			var/list/dye_data = dyed_parts[part]
			var/dye_color = dye_data[1]
			var/dye_alpha = dye_data[2]
			//TODO: dye_date[3] to allow glowing clothing?

			var/_state = dye_base_iconstate_override
			if (!_state)
				_state = icon_state
			var/image/object_overlay = image(icon, src, "[_state]-[part]")
			object_overlay.appearance_flags = RESET_COLOR
			object_overlay.color = dye_color
			object_overlay.alpha = dye_alpha
			overlays += object_overlay

			var/image/worn_overlay = image(cloth_icon, src, "[_state]-[part]")
			worn_overlay.appearance_flags = RESET_COLOR
			worn_overlay.color = dye_color
			worn_overlay.alpha = dye_alpha
			dyn_overlay_worn.overlays += worn_overlay

			_state = dye_base_itemstate_override
			if (!_state)
				_state = item_state
			if (!_state)
				_state = icon_state
			var/image/left_overlay = image(inhand_states["left_hand"], src, "[_state]-[part]")
			left_overlay.appearance_flags = RESET_COLOR
			left_overlay.color = dye_color
			left_overlay.alpha = dye_alpha
			dyn_overlay_left.overlays += left_overlay

			var/image/right_overlay = image(inhand_states["right_hand"], src, "[_state]-[part]")
			right_overlay.appearance_flags = RESET_COLOR
			right_overlay.color = dye_color
			right_overlay.alpha = dye_alpha
			dyn_overlay_right.overlays += right_overlay

	if ((luminosity > 0) || (dyed_parts.len > 0))
		dynamic_overlay["[cloth_layer]"] = dyn_overlay_worn
		dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = dyn_overlay_left
		dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = dyn_overlay_right

	set_blood_overlay()//re-applying blood stains
	if (on_fire && fire_overlay)
		overlays += fire_overlay


/obj/item/clothing/can_quick_store(var/obj/item/I)
	for(var/obj/item/clothing/accessory/storage/A in accessories)
		if(A.hold && A.hold.can_be_inserted(I,1))
			return 1
	for(var/obj/item/clothing/accessory/holster/A2 in accessories)
		if(!A2.holstered && A2.can_holster(I))
			return 1
	if(istype(I,/obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/A3 = I
		if(!check_accessory_overlap(A3) && A3.can_attach_to(src))
			return 1

/obj/item/clothing/quick_store(var/obj/item/I,mob/user)
	..()
	for(var/obj/item/clothing/accessory/storage/A in accessories)
		if(A.hold && A.hold.handle_item_insertion(I,0))
			return 1
	for(var/obj/item/clothing/accessory/holster/A2 in accessories)
		if(A2.holster(I,user))
			return 1
	if(istype(I,/obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/A3 = I
		if(user.drop_item(I, src))
			attach_accessory(A3,user)
			return 1

/obj/item/clothing/CtrlClick(var/mob/user)
	if(isturf(loc))
		return ..()
	if(isliving(user) && !user.incapacitated() && user.Adjacent(src) && accessories.len)
		removeaccessory()

/obj/item/clothing/examine(mob/user)
	..()
	for(var/obj/item/clothing/accessory/A in accessories)
		to_chat(user, "<span class='info'>\A [A] is clipped to it.</span>")

/obj/item/clothing/emp_act(severity)
	for(var/obj/item/clothing/accessory/accessory in accessories)
		accessory.emp_act(severity)
	..()

/obj/item/clothing/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/A = I
		if(check_accessory_overlap(A))
			to_chat(user, "<span class='notice'>You cannot attach more accessories of this type to [src].</span>")
			return
		if(!A.can_attach_to(src))
			to_chat(user, "<span class='notice'>\The [A] cannot be attached to [src].</span>")
			return
		if(user.drop_item(I, src))
			attach_accessory(A, user)
		return 1
	if(I.is_screwdriver(user))
		for(var/obj/item/clothing/accessory/accessory in priority_accessories())
			if(accessory.attackby(I, user))
				return 1
	for(var/obj/item/clothing/accessory/accessory in priority_accessories())
		if(accessory.attackby(I, user))
			return 1
	if(istype(I, /obj/item/painting_brush))
		var/obj/item/painting_brush/P = I
		if (P.paint_color)
			paint_act(P.paint_color,user)
		else
			to_chat(user, "<span class='warning'>There is no paint on \the [P].</span>")
		return 1
	if(istype(I, /obj/item/paint_roller))
		var/obj/item/paint_roller/P = I
		if (P.paint_color)
			paint_act(P.paint_color,user)
		else
			to_chat(user, "<span class='warning'>There is no paint on \the [P].</span>")
		return 1

	..()

/obj/item/clothing/attack_hand(mob/user)
	if(accessories.len && src.loc == user)
		var/list/delayed = list()
		for(var/obj/item/clothing/accessory/A in priority_accessories())
			switch(A.on_accessory_interact(user, 0))
				if(1)
					return 1
				if(-1)
					delayed.Add(A)
				else
					continue
		var/ignorecounter = 0
		for(var/obj/item/clothing/accessory/A in delayed)
			//if(A.ignoreinteract)
				//ignorecounter += 1
			ignorecounter += A.ignoreinteract
			if(!(A.ignoreinteract) && A.on_accessory_interact(user, 1))
				return 1
		if(ignorecounter == accessories.len)
			return ..()
		return
	return ..()

/obj/item/clothing/clean_act(var/cleanliness)
	..()
	if (cleanliness >= CLEANLINESS_BLEACH)
		dyed_parts.len = 0
		update_icon()
		if (ismob(loc))
			var/mob/M = loc
			M.update_inv_hands()

/obj/item/clothing/proc/togglehood()
	set name = "Toggle Hood"
	set category = "Object"
	set src in usr

	if (!hood)
		return

	if(usr.incapacitated())
		return

	toggle_hood(usr)

/obj/item/clothing/proc/toggle_hood(var/mob/wearer, var/mob/user)
	if(ismob(wearer))
		if (user && (user!=wearer))
			if(!is_hood_up && !wearer.get_item_by_slot(slot_head) && hood.mob_can_equip(wearer,slot_head))
				to_chat(user, "You put their hood up.")
				to_chat(wearer, "[user] puts your hood up.")
				hoodup(wearer)
			else if(wearer.get_item_by_slot(slot_head) == hood)
				hooddown(wearer)
				to_chat(user, "You put their hood down.")
				to_chat(wearer, "[user] puts your hood down.")
			else
				to_chat(user, "You try to put their hood up, but there is something in the way.")
				to_chat(wearer, "[user] tries in vain to put your hood up, but there is something in the way.")
				return
		else
			if(!is_hood_up && !wearer.get_item_by_slot(slot_head) && hood.mob_can_equip(wearer,slot_head))
				to_chat(wearer, "You put the hood up.")
				hoodup(wearer)
			else if(wearer.get_item_by_slot(slot_head) == hood)
				hooddown(wearer)
				to_chat(wearer, "You put the hood down.")
			else
				to_chat(wearer, "You try to put your hood up, but there is something in the way.")
				return
		wearer.update_inv_w_uniform()
	else if (istype(wearer, /obj/structure/mannequin))
		var/obj/structure/mannequin/mannequin = wearer
		if(!is_hood_up && !mannequin.clothing[SLOT_MANNEQUIN_HEAD])
			to_chat(user, "You put the hood up.")
			hoodup(wearer)
		else if(mannequin.clothing[SLOT_MANNEQUIN_HEAD] == hood)
			hooddown(wearer)
			to_chat(user, "You put the hood down.")
		else
			to_chat(user, "You try to put the hood up, but there is something in the way.")
			return

/obj/item/clothing/proc/hoodup(var/atom/movable/AM)
	if(istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		hood.dyed_parts = dyed_parts.Copy()
		hood.color = color
		hood.update_icon()
		H.equip_to_slot(hood, slot_head)
		icon_state = hood_up_icon_state
		is_hood_up = TRUE
		H.update_inv_w_uniform()
		H.update_inv_wear_suit()
	else if (istype(AM, /obj/structure/mannequin))
		var/obj/structure/mannequin/M = AM
		M.clothing[SLOT_MANNEQUIN_HEAD] = hood
		hood.mannequin_equip(M,SLOT_MANNEQUIN_HEAD)

/obj/item/clothing/proc/hooddown(var/atom/movable/AM, var/unequip = 1)
	if(istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		icon_state = hood_down_icon_state
		if(unequip)
			H.u_equip(H.head,0)
		is_hood_up = FALSE
		H.update_inv_w_uniform()
		H.update_inv_wear_suit()
	else if (istype(AM, /obj/structure/mannequin))
		var/obj/structure/mannequin/M = AM
		M.clothing[SLOT_MANNEQUIN_HEAD] = null
		hood.mannequin_unequip(M)

/obj/item/clothing/mannequin_unequip(var/obj/structure/mannequin/mannequin)
	if (hood && (mannequin.clothing[SLOT_MANNEQUIN_HEAD] == hood))
		hooddown(mannequin)

//for fabric clothing that can be fully dyed in a cauldron
/obj/item/clothing/dye_act(var/obj/structure/reagent_dispensers/cauldron/cauldron, var/mob/user)
	if (clothing_flags & COLORS_OVERLAY)
		var/dye_target = "full"
		var/list/actual_parts = list()
		var/list/choices = list("Full")
		if (dyeable_parts.len > 0)
			for (var/part in dyeable_parts)//doing some swapping so we get an easier list to read in-game
				var/part_proper_name = dyeable_part_to_name[part]
				choices += part_proper_name
				actual_parts[part_proper_name] = part
			dye_target = input("Which part do you want to dye?","Clothing Dyeing",1) as null|anything in choices
		if (!dye_target)
			return
		to_chat(user, "<span class='notice'>You begin dyeing \the [src][(dye_target != "Full") ? "'s [dye_target]" : ""].</span>")
		playsound(cauldron.loc, 'sound/effects/slosh.ogg', 25, 1)
		if (do_after(user, cauldron, 30))
			var/mixed_color = mix_color_from_reagents(cauldron.reagents.reagent_list, TRUE)
			var/mixed_alpha = mix_alpha_from_reagents(cauldron.reagents.reagent_list)
			if (mixed_color == "#FFFFFF")
				mixed_color = "#FEFEFE" //null color prevention
			if (!mixed_color)
				var/silent = FALSE
				for(var/datum/reagent/R in cauldron.reagents.reagent_list)
					if (R.id == BLEACH || R.id == ACETONE)
						silent = TRUE
						to_chat(user, "<span class='notice'>You wash off \the [src]'s colors.</span>")
					if (R.id == CLEANER)
						silent = TRUE
						to_chat(user, "<span class='notice'>You wash \the [src] clean.</span>")
					R.reaction_obj(src, R.volume)
				if (!silent)
					to_chat(user, "<span class='warning'>It seems that there are no pigments among the reagents in the cauldron.</span>")
				update_icon()
				user.update_inv_hands()
				return
			if (dye_target == "Full" || choices.len <= 1)
				dyed_parts.len = 0
				color = BlendRGB(color, mixed_color, mixed_alpha/255)
			else
				dyed_parts -= dye_target//moving the new layer on top
				dyed_parts[actual_parts[dye_target]] = list(mixed_color,mixed_alpha)//getting back the actual overlay name
			update_icon()
			user.update_inv_hands()
	else if (dyeable_parts.len > 0)
		to_chat(user, "<span class='warning'>Can't dye that, but you can probably apply some paint directly with a painting brush.</span>")
	else
		to_chat(user, "<span class='warning'>Can't dye that.</span>")
	return TRUE

//for clothing that gets color applied with a tool over certain parts
/obj/item/clothing/proc/paint_act(var/_color, var/mob/user)
	if (clothing_flags & COLORS_OVERLAY)
		to_chat(user, "<span class='warning'>Can't paint that directly, use a cauldron.</span>")
	else if (dyeable_parts.len > 0)
		var/dye_target = ""
		var/list/actual_parts = list()
		var/list/choices = list()
		if (dyeable_parts.len > 0)
			for (var/part in dyeable_parts)//doing some swapping so we get an easier list to read in-game
				var/part_proper_name = dyeable_part_to_name[part]
				choices += part_proper_name
				actual_parts[part_proper_name] = part
			dye_target = input("Which part do you want to paint?","Clothing Painting",1) as null|anything in choices
		if (!dye_target)
			return
		to_chat(user, "<span class='notice'>You begin painting \the [src][(dye_target != "Full") ? "'s [dye_target]" : ""].</span>")
		playsound(loc, "mop", 10, 1)
		if (do_after(user, src, 20))
			if (_color == "#FFFFFF")
				_color = "#FEFEFE" //null color prevention
			dyed_parts -= dye_target//moving the new layer on top
			dyed_parts[actual_parts[dye_target]] = list(_color,255)//getting back the actual overlay name
			update_icon()
			user.regenerate_icons()
	else
		to_chat(user, "<span class='warning'>Can't paint that.</span>")
	return TRUE

/obj/item/clothing/proc/attach_accessory(obj/item/clothing/accessory/accessory, mob/user)
	accessories += accessory
	accessory.forceMove(src)
	accessory.on_attached(src)
	update_verbs()
	if(user)
		to_chat(user, "<span class='notice'>You attach [accessory] to [src].</span>")
		accessory.add_fingerprint(user)
	if(iscarbon(loc))
		var/mob/living/carbon/carbon_wearer = loc
		carbon_wearer.update_inv_by_slot(slot_flags)

/obj/item/clothing/proc/priority_accessories()
	if(!accessories.len)
		return list()
	var/list/unorg = accessories
	var/list/prioritized = list()
	for(var/obj/item/clothing/accessory/holster/H in accessories)
		prioritized.Add(H)
	for(var/obj/item/clothing/accessory/storage/S in accessories)
		prioritized.Add(S)
	for(var/obj/item/clothing/accessory/armband/A in accessories)
		prioritized.Add(A)
	prioritized |= unorg
	return prioritized

/obj/item/clothing/proc/check_accessory_overlap(var/obj/item/clothing/accessory/accessory)
	if(!accessory)
		return

	for(var/obj/item/clothing/accessory/A in accessories)
		if(A.accessory_exclusion & accessory.accessory_exclusion)
			return 1

/obj/item/clothing/proc/remove_accessory(mob/user, var/obj/item/clothing/accessory/accessory)
	if(!accessory || !(accessory in accessories))
		return

	accessory.on_removed(user)
	accessories.Remove(accessory)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.update_inv_by_slot(slot_flags)
	update_verbs()

/obj/item/clothing/proc/get_accessory_by_exclusion(var/exclusion)
	for(var/obj/item/clothing/accessory/A in accessories)
		if(A.accessory_exclusion == exclusion)
			return A

/obj/item/clothing/verb/removeaccessory()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	if(usr.incapacitated())
		return

	if(!accessories.len)
		return
	var/obj/item/clothing/accessory/A
	if(accessories.len > 1)
		A = input("Select an accessory to remove from [src]") as anything in accessories
	else
		A = accessories[1]
	src.remove_accessory(usr,A)

/obj/item/clothing/proc/update_verbs()
	if(accessories.len)
		verbs |= /obj/item/clothing/verb/removeaccessory
	else
		verbs -= /obj/item/clothing/verb/removeaccessory

/obj/item/clothing/proc/is_worn_by(mob/user)
	if(user.is_wearing_item(src))
		return TRUE
	return FALSE

/obj/item/clothing/New() //so sorry
	..()
	update_verbs()

//BS12: Species-restricted clothing check.
/obj/item/clothing/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	. = ..() //Default return value. If 1, item can be equipped. If 0, it can't be.
	if(!.)
		return //Default return value is 0 - don't check for species

	switch(role_check(M))
		if(FALSE)
			return CANNOT_EQUIP
		if(ALWAYSTRUE)
			return CAN_EQUIP

	if(species_restricted && istype(M,/mob/living/carbon/human) && (slot != slot_l_store && slot != slot_r_store))

		var/wearable = null
		var/exclusive = null
		var/mob/living/carbon/human/H = M

		if("exclude" in species_restricted)
			exclusive = 1

		var/datum/species/base_species = H.species
		if(!base_species)
			return

		var/base_species_can_wear = 1 //If the body's main species can wear this

		if(exclusive)
			if(!species_restricted.Find(base_species.name))
				wearable = 1
			else
				base_species_can_wear = 0
		else
			if(species_restricted.Find(base_species.name))
				wearable = 1
			else
				base_species_can_wear = 0

		//Check ALL organs covered by the slot. If any of the organ's species can't wear this, return 0

		for(var/datum/organ/external/OE in get_organs_by_slot(slot, H)) //Go through all organs covered by the item
			if(!OE.species) //Species same as of the body
				if(!base_species_can_wear) //And the body's species can't wear
					wearable = 0
					break
				continue

			if(exclusive)
				if(!species_restricted.Find(OE.species.name))
					wearable = 1
				else
					to_chat(M, "<span class='warning'>Your misshapen [OE.display_name] prevents you from wearing \the [src].</span>")
					return CANNOT_EQUIP
			else
				if(species_restricted.Find(OE.species.name))
					wearable = 1
				else
					to_chat(M, "<span class='warning'>Your misshapen [OE.display_name] prevents you from wearing \the [src].</span>")
					return CANNOT_EQUIP

		if(!wearable) //But we are a species that CAN'T wear it (sidenote: slots 15 and 16 are pockets)
			to_chat(M, "<span class='warning'>Your species cannot wear [src].</span>")//Let us know
			return CANNOT_EQUIP

	//return ..()

/obj/item/clothing/proc/role_check(mob/user)
	if(!user || !user.mind || !user.mind.antag_roles.len)
		return TRUE //No roles to check
	for(var/datum/role/R in get_list_of_elements(user.mind.antag_roles))
		switch(R.can_wear(src))
			if(ALWAYSTRUE)
				return ALWAYSTRUE
			if(FALSE)
				return FALSE
			if(TRUE)
				continue
	return TRUE //All roles true? Return true.

/obj/item/clothing/before_stripped(mob/wearer as mob, mob/stripper as mob, slot)
	..()
	if(slot == slot_w_uniform) //this will cause us to drop our belt, ID, and pockets!
		for(var/slotID in list(slot_wear_id, slot_belt, slot_l_store, slot_r_store))
			var/obj/item/I = wearer.get_item_by_slot(slotID)
			if(I)
				I.stripped(wearer, stripper)

/obj/item/clothing/become_defective()
	if(!defective)
		..()
		for(var/A in armor)
			armor[A] -= rand(armor[A]/3, armor[A])

/obj/item/clothing/attack(var/mob/living/M, var/mob/living/user, def_zone, var/originator = null)
	if (!(iscarbon(user) && user.a_intent == I_HELP && (clothing_flags & CANEXTINGUISH) && ishuman(M) && M.on_fire))
		..()
	else
		var/mob/living/carbon/human/target = M
		if(isplasmaman(target)) // Cannot put out plasmamen, else they could just go around with a jumpsuit and not need a space suit.
			visible_message("<span class='warning'>\The [user] attempts to put out the fire on \the [target], but plasmafires are too hot. It is no use.</span>")
		else
			visible_message("<span class='warning'>\The [user] attempts to put out the fire on \the [target] with \the [src].</span>")
			if(prob(extinguishingProb))
				M.extinguish()
				visible_message("<span class='notice'>\The [user] puts out the fire on \the [target].</span>")
		return

/obj/item/clothing/proc/offenseTackleBonus()
	return

/obj/item/clothing/proc/defenseTackleBonus()
	return

/obj/item/clothing/proc/rangeTackleBonus()
	return

/* ========================================================================
								EARS
======================================================================== */
//Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	w_class = W_CLASS_TINY
	throwforce = 2
	slot_flags = SLOT_EARS
	cloth_layer = EARS_LAYER
	cloth_icon = 'icons/mob/ears.dmi'
	starting_materials = list(MAT_FABRIC = 750)

/obj/item/clothing/ears/attack_hand(mob/user as mob)
	if (!user)
		return

	if (src.loc != user || !istype(user,/mob/living/carbon/human))
		..()
		return

	var/mob/living/carbon/human/H = user
	if(H.ears != src)
		..()
		return

	if(!canremove)
		return

	var/obj/item/clothing/ears/O = src

	user.u_equip(src,0)

	if (O)
		user.put_in_hands(O)
		O.add_fingerprint(user)

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from both loud and quiet noises."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	slot_flags = SLOT_EARS

/* ========================================================================
								GLOVES
======================================================================== */
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = W_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/gloves.dmi', "right_hand" = 'icons/mob/in-hand/right/gloves.dmi')
	siemens_coefficient = 0.50
	sterility = 50
	var/wired = 0
	var/obj/item/weapon/cell/cell = 0
	var/cant_remove_cell = FALSE
	var/clipped = 0
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenges")
	species_restricted = list("exclude","Unathi","Tajaran","Muton")
	var/pickpocket = 0 //Master pickpocket?

	var/bonus_knockout = 0 //Knockout chance is multiplied by (1 + bonus_knockout) and is capped at 1/2. 0 = 1/12 chance, 1 = 1/6 chance, 2 = 1/4 chance, 3 = 1/3 chance, etc.
	var/damage_added = 0 //Added to unarmed damage, doesn't affect knockout chance
	var/sharpness_added = 0 //Works like weapon sharpness for unarmed attacks, affects bleeding and limb severing.
	var/hitsound_added = "punch"	//The sound that plays for an unarmed attack while wearing these gloves.

	var/attack_verb_override = "punches"

	var/transfer_blood = 0
	var/list/bloody_hands_data = list()
	cloth_layer = GLOVES_LAYER
	cloth_icon = 'icons/mob/hands.dmi'
	starting_materials = list(MAT_FABRIC = 938)

/obj/item/clothing/gloves/get_cell()
	return cell

/obj/item/clothing/gloves/emp_act(severity)
	if(cell)
		cell.charge -= 1000 / severity
		if (cell.charge < 0)
			cell.charge = 0
		if(cell.reliability != 100 && prob(50/severity))
			cell.reliability -= 10 / severity
	..()

/obj/item/clothing/gloves/proc/dexterity_check(mob/user) //Set wearer's dexterity to the value returned by this proc. Doesn't override death or brain damage, and should always return 1 (unless intended otherwise)
	return 1 //Setting this to 0 will make user NOT dexterious when wearing these gloves

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(var/atom/A, mob/user, proximity)
	return 0 // return 1 to cancel attack_hand()

/obj/item/clothing/gloves/proc/get_damage_added()
	return damage_added

/obj/item/clothing/gloves/proc/get_sharpness_added()
	return sharpness_added

/obj/item/clothing/gloves/proc/get_hitsound_added()
	return hitsound_added

/obj/item/clothing/gloves/proc/on_punch(mob/user, mob/victim)
	return

/obj/item/clothing/gloves/proc/on_wearer_threw_item(mob/user, atom/target, atom/movable/thrown)	//Called when the mob wearing the gloves successfully throws either something or nothing.
	return


/* ========================================================================
								HEAD
======================================================================== */
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	species_restricted = list("exclude","Muton")
	var/gave_out_gifts = FALSE //for snowman animation
	var/obj/item/clothing/head/on_top = null //for stacking
	var/stack_depth = 0
	var/vertical_offset = 0 //enables hats to go taller that the tile's boundaries
	var/blood_overlay_type = "hat"
	cloth_layer = HEAD_LAYER
	cloth_icon = 'icons/mob/head.dmi'
	starting_materials = list(MAT_FABRIC = 1875)

	var/obj/item/clothing/hood_suit = null // the suit this hood belongs to

/obj/item/clothing/head/Destroy()
	if(hood_suit)
		hood_suit.hood = null
		hood_suit = null
	..()

/obj/item/clothing/head/pickup(var/mob/living/carbon/human/user)
	if(hood_suit && istype(hood_suit) && (istype(hood_suit.loc, /obj/structure/mannequin)||(user.get_item_by_slot(slot_wear_suit) == hood_suit)||(user.get_item_by_slot(slot_w_uniform) == hood_suit)))
		hood_suit.hooddown(user, unequip = 0)
		user.drop_from_inventory(src)
		forceMove(hood_suit)
		if (hood_suit.force_hood)
			user.u_equip(hood_suit)
			user.put_in_hands(hood_suit)
		else
			to_chat(user, "You put the hood down.")

var/global/hatStacking = 0
var/global/maxStackDepth = 10

/client/proc/configHat()
	set name = "Configure Hat Stacking"
	set category = "Debug"

	. = (alert("Allow hats to stack?",,"Yes","No")=="Yes")
	if(.)
		hatStacking = 1
	else
		hatStacking = 0
	. = (input("Set stack limit. (1 to 100)"))
	. = text2num(.)
	if(isnum(.) && (. in 1 to 100))
		maxStackDepth = .
	else
		to_chat(usr, "That wasn't a valid number.")
	log_admin("[key_name(usr)] set hatStacking to [hatStacking].")
	message_admins("[key_name(usr)] set hatStacking to [hatStacking].")
	log_admin("[key_name(usr)] set maxStackDepth to [maxStackDepth].")
	message_admins("[key_name(usr)] set maxStackDepth to [maxStackDepth].")

/obj/item/clothing/head/attackby(obj/item/W, mob/user)
	if(hatStacking)
		if(on_top)
			on_top.attackby(W,user)
		else if(istype(W,/obj/item/clothing/head) && !istype(W,/obj/item/clothing/head/helmet))
			var/obj/item/clothing/head/hat = W
			if(stack_depth >= maxStackDepth)
				to_chat(user,"<span class='warning'>You cannot stack any higher than this!</span>")
			else if(user.drop_item(W))
				to_chat(user,"<span class='notice'>You add \the [hat] onto \the [src] and stack it in a towering pillar!</span>")
				stack_depth++
				hat.stack_depth = stack_depth
				W.forceMove(src)
				W.pixel_y += 4 * PIXEL_MULTIPLIER
				vis_contents.Add(W)
				on_top = hat
				user.update_inv_head()
				for(var/obj/item/clothing/head/above = on_top; above; above = above.on_top)
					above.stack_depth = stack_depth
	..()

/obj/item/clothing/head/attack_hand(mob/user)
	if(on_top)
		if(on_top.on_top)
			on_top.attack_hand(user)
		else
			to_chat(user,"You remove \the [on_top] from the towering pillar.")
			on_top.pixel_y = 0
			stack_depth--
			on_top.stack_depth = 0
			user.put_in_hands(on_top)
			vis_contents.Cut()
			on_top = null
			user.update_inv_head()
			for(var/obj/item/clothing/head/above = on_top; above; above = above.on_top)
				above.stack_depth = stack_depth
		return
	return ..()

/obj/item/clothing/head/description_hats()
	var/list/hat_names = list()
	for(var/obj/item/clothing/head/above = on_top; above; above = above.on_top)
		hat_names += above.name
	if(hat_names.len)
		return " It is piled underneath a [english_list(hat_names)]."

/obj/item/clothing/head/proc/bite_action(mob/target)
	return

/obj/item/proc/islightshielded() // So as to avoid unneeded casts.
	return FALSE


/* ========================================================================
								MASK
======================================================================== */
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = MOUTH
	slot_flags = SLOT_MASK
	species_restricted = list("exclude","Muton")
	var/can_flip = null
	var/is_flipped = 1
	var/ignore_flip = 0
	actions_types = list(/datum/action/item_action/toggle_mask)
	heat_conductivity = MASK_HEAT_CONDUCTIVITY
	cloth_layer = FACEMASK_LAYER
	cloth_icon = 'icons/mob/mask.dmi'
	starting_materials = list(MAT_FABRIC = 938)

/datum/action/item_action/toggle_mask
	name = "Toggle Mask"

/datum/action/item_action/toggle_mask/Trigger()
	var/obj/item/clothing/mask/T = target
	if(!istype(T))
		return
	T.togglemask()

/obj/item/clothing/mask/proc/togglemask()
	if(ignore_flip)
		return
	else
		if(usr.incapacitated())
			return
		if(!can_flip)
			to_chat(usr, "You try pushing \the [src] out of the way, but it is very uncomfortable and you look like a fool. You push it back into place.")
			return
		if(src.is_flipped == 2)
			src.icon_state = initial(icon_state)
			gas_transfer_coefficient = initial(gas_transfer_coefficient)
			permeability_coefficient = initial(permeability_coefficient)
			sterility = initial(sterility)
			flags = initial(flags)
			body_parts_covered = initial(body_parts_covered)
			to_chat(usr, "You push \the [src] back into place.")
			src.is_flipped = 1
		else
			src.icon_state = "[initial(icon_state)]_up"
			to_chat(usr, "You push \the [src] out of the way.")
			gas_transfer_coefficient = null
			permeability_coefficient = null
			sterility = 0
			flags = 0
			src.is_flipped = 2
			body_parts_covered &= ~(MOUTH|HEAD|BEARD|FACE)
		update_icon()
		usr.update_inv_wear_mask()
		usr.update_hair()
		usr.update_inv_glasses()

/obj/item/clothing/mask/New()
	if(!can_flip /*&& !istype(/obj/item/clothing/mask/gas/voice)*/) //the voice changer has can_flip = 1 anyways but it's worth noting that it exists if anybody changes this in the future
		actions_types = null
	..()

/obj/item/clothing/mask/attack_self()
	togglemask()


/* ========================================================================
								SHOES
======================================================================== */
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing

	var/obj/item/weapon/chain = null // handcuffs attached
	var/bonus_kick_damage = 0
	var/footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints //The type of footprint left by someone wearing these
	var/mag_slow = MAGBOOTS_SLOWDOWN_HIGH //how slow are they when the magpulse is on?

	siemens_coefficient = 0.9
	body_parts_covered = FEET
	slot_flags = SLOT_FEET
	heat_conductivity = SHOE_HEAT_CONDUCTIVITY
	permeability_coefficient = 0.50
	sterility = 50

	species_restricted = list("exclude","Unathi","Tajaran","Muton")
	var/step_sound = ""
	var/stepstaken = 1
	var/modulo_steps = 2 //if stepstaken is a multiplier of modulo_steps, play the sound. Does not work if modulo_steps < 1
	cloth_layer = SHOES_LAYER
	cloth_icon = 'icons/mob/feet.dmi'
	starting_materials = list(MAT_FABRIC = 1250)

	var/luminous_paint = FALSE

/obj/item/clothing/shoes/proc/step_action()
	stepstaken++
	if(step_sound != "" && ishuman(loc))
		var/mob/living/carbon/human/H = loc
		switch(H.m_intent)
			if("run")
				if(stepstaken % modulo_steps == 0)
					playsound(H, step_sound, 50, 1) // this will NEVER GET ANNOYING!
			if("walk")
				playsound(H, step_sound, 20, 1)

/obj/item/clothing/shoes/proc/on_kick(mob/living/user, mob/living/victim)
	return

/obj/item/clothing/shoes/defenseTackleBonus()
	if(clothing_flags & MAGPULSE)
		return 40

//Called from human_defense.dm proc foot_impact
/obj/item/clothing/shoes/proc/impact_dampen(atom/source, var/damage)
	return damage

/obj/item/clothing/shoes/kick_act(mob/living/carbon/human/user)
	if(user.equip_to_slot_if_possible(src, slot_shoes))
		user.visible_message("<span class='notice'>[user] kicks \the [src] and slips them on!</span>", "<span class='notice'>You kick \the [src] and slip them on!</span>")
	else
		..()

/obj/item/clothing/shoes/clean_blood()
	. = ..()
	track_blood = 0
	blood_color = null
	luminous_paint = FALSE

/obj/item/clothing/shoes/proc/togglemagpulse(var/mob/user = usr, var/override = FALSE)
	if(!override)
		if(user.isUnconscious())
			return
	if((clothing_flags & MAGPULSE))
		clothing_flags &= ~(NOSLIP | MAGPULSE)
		slowdown = NO_SLOWDOWN
		return 0
	else
		clothing_flags |= (NOSLIP | MAGPULSE)
		slowdown = mag_slow
		return 1


/* ========================================================================
								SUIT
======================================================================== */
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	flags = FPRINT
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/weapon/tank/emergency_plasma)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	slot_flags = SLOT_OCLOTHING
	heat_conductivity = ARMOUR_HEAT_CONDUCTIVITY
	body_parts_covered = ARMS|LEGS|FULL_TORSO
	var/blood_overlay_type = "suit"
	species_restricted = list("exclude","Muton")
	siemens_coefficient = 0.9
	clothing_flags = CANEXTINGUISH
	sterility = 30
	cloth_layer = SUIT_LAYER
	cloth_icon = 'icons/mob/suit.dmi'
	starting_materials = list(MAT_FABRIC = CC_PER_SHEET_FABRIC)

/obj/item/clothing/suit/togglehood()
	set name = "Toggle Hood"
	set category = "Object"
	set src in usr

	if (!hood)
		return

	if(usr.incapacitated())
		return

	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	if(user.get_item_by_slot(slot_wear_suit) != src)
		to_chat(user, "You have to put the [hood_suit_name] on first.")
		return
	if(!is_hood_up && !user.get_item_by_slot(slot_head) && hood.mob_can_equip(user,slot_head))
		to_chat(user, "You put the hood up.")
		hoodup(user)
	else if(user.get_item_by_slot(slot_head) == hood)
		hooddown(user)
		to_chat(user, "You put the hood down.")
	else
		to_chat(user, "You try to put your hood up, but there is something in the way.")
		return
	user.update_inv_wear_suit()

/obj/item/clothing/suit/attack_self()
	if (hood && !force_hood)
		togglehood()

/obj/item/clothing/equipped(var/mob/user, var/slot, hand_index = 0)
	..()
	if (hood && (force_hood || auto_hood) && !hand_index)
		if (auto_hood && (user.get_item_by_slot(slot_head) && user.get_item_by_slot(slot_head) != hood))
			return//we want to still be able to equip the suit even if the hood is blocked
		hoodup(user)

/obj/item/clothing/unequipped(var/mob/living/carbon/human/user)
	..()
	if(hood && istype(user) && user.get_item_by_slot(slot_head) == hood)
		hooddown(user)

/obj/item/clothing/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	. = ..()

	if (hood && force_hood && slot == slot_wear_suit)
		if (M.get_item_by_slot(slot_head) && M.get_item_by_slot(slot_head) != hood)
			to_chat(M, "You try to put the [hood_suit_name] on, but there is something in the way of its hood.")
			return FALSE
		else if (!hood.mob_can_equip(M, slot_head))
			return FALSE

/obj/item/clothing/suit/proc/vine_protected()
	return FALSE

/obj/item/clothing/suit/proc/Extinguish(var/mob/living/carbon/human/H)
	return

/obj/item/clothing/suit/proc/regulate_temp_of_wearer(var/mob/living/carbon/human/H)
	return

//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corresponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "Space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	pressure_resistance = 5 * ONE_ATMOSPHERE
	item_state = "space"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/spacesuits.dmi', "right_hand" = 'icons/mob/in-hand/right/spacesuits.dmi')
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	body_parts_covered = FULL_HEAD|HIDEHAIR
	body_parts_visible_override = EYES
	siemens_coefficient = 0.9
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	species_restricted = list("exclude","Diona","Muton")
	eyeprot = 1
	cold_breath_protection = 230
	sterility = 100
	species_fit = list(INSECT_SHAPED, VOX_SHAPED, GREY_SHAPED)
	flammable = FALSE


/obj/item/clothing/suit/space
	name = "Space suit"
	desc = "A suit that protects against low pressure environments. Has a big \"13\" on the back."
	icon_state = "space"
	item_state = "s_suit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/spacesuits.dmi', "right_hand" = 'icons/mob/in-hand/right/spacesuits.dmi')
	w_class = W_CLASS_LARGE//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = FPRINT
	pressure_resistance = 5 * ONE_ATMOSPHERE
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS|HIDETAIL
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/)
	slowdown = HARDSUIT_SLOWDOWN_BULKY
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	siemens_coefficient = 0.9
	species_restricted = list("exclude","Diona","Muton")
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	clothing_flags = CANEXTINGUISH
	sterility = 100
	species_fit = list(INSECT_SHAPED, VOX_SHAPED, GREY_SHAPED)
	flammable = FALSE

/* ========================================================================
								UNIFORMS
======================================================================== */
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = ARMS|LEGS|FULL_TORSO
	permeability_coefficient = 0.90
	flags = FPRINT
	slot_flags = SLOT_ICLOTHING
	heat_conductivity = JUMPSUIT_HEAT_CONDUCTIVITY
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	species_restricted = list("exclude","Muton")
	var/has_sensor = 1 //For the crew computer 2 = unable to change mode
	var/sensor_mode = 0
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/displays_id = 1
	clothing_flags = CANEXTINGUISH
	var/icon/jersey_overlays
	cloth_layer = UNIFORM_LAYER
	cloth_icon = 'icons/mob/uniform.dmi'
	starting_materials = list(MAT_FABRIC = CC_PER_SHEET_FABRIC)

// Associative list of exact type -> number
var/list/jersey_numbers = list()

/obj/item/clothing/under/togglehood()
	set name = "Toggle Hood"
	set category = "Object"
	set src in usr

	if (!hood)
		return

	if(usr.incapacitated())
		return

	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	if(user.get_item_by_slot(slot_w_uniform) != src)
		to_chat(user, "You have to put the [hood_suit_name] on first.")
		return
	if(!is_hood_up && !user.get_item_by_slot(slot_head) && hood.mob_can_equip(user,slot_head))
		to_chat(user, "You put the hood up.")
		hoodup(user)
	else if(user.get_item_by_slot(slot_head) == hood)
		hooddown(user)
		to_chat(user, "You put the hood down.")
	else
		to_chat(user, "You try to put your hood up, but there is something in the way.")
		return
	user.update_inv_w_uniform()

/obj/item/clothing/under/attack_self()
	if (hood && !force_hood)
		togglehood()

/obj/item/clothing/under/update_icon()
	..()
	if(jersey_overlays)
		var/number = jersey_numbers[type]++ % 99
		var/first_digit = num2text(round((number / 10) % 10))
		var/second_digit = num2text(round(number % 10))
		var/image/jersey_overlay = image(jersey_overlays, src, "[first_digit]-")
		jersey_overlay.overlays += image(jersey_overlays, src, second_digit)
		dynamic_overlay["[UNIFORM_LAYER]"] = jersey_overlay

/obj/item/clothing/under/examine(mob/user)
	..()
	var/mode
	switch(src.sensor_mode)
		if(0)
			mode = "Its sensors appear to be disabled."
		if(1)
			mode = "Its binary life sensors appear to be enabled."
		if(2)
			mode = "Its vital tracker appears to be enabled."
		if(3)
			mode = "Its vital tracker and tracking beacon appear to be enabled."
	to_chat(user, "<span class='info'>" + mode + "</span>")

/obj/item/clothing/under/emp_act(severity)
	..()
	sensor_mode = pick(0,1,2,3)

/obj/item/clothing/under/proc/set_sensors(mob/user as mob)
	if(user.incapacitated())
		return
	if(has_sensor >= 2)
		to_chat(user, "<span class='warning'>The controls are locked.</span>")
		return 0
	if(has_sensor <= 0)
		to_chat(user, "<span class='warning'>This suit does not have any sensors.</span>")
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(user.incapacitated())
		return
	if(get_dist(user, src) > 1)
		to_chat(user, "<span class='warning'>You have moved too far away.</span>")
		return
	sensor_mode = modes.Find(switchMode) - 1

	if(is_holder_of(user, src))
		switch(sensor_mode) //i'm sure there's a more compact way to write this but c'mon
			if(0)
				to_chat(user, "<span class='notice'>You disable your suit's remote sensing equipment.</span>")
			if(1)
				to_chat(user, "<span class='notice'>Your suit will now report whether you are live or dead.</span>")
			if(2)
				to_chat(user, "<span class='notice'>Your suit will now report your vital lifesigns.</span>")
			if(3)
				to_chat(user, "<span class='notice'>Your suit will now report your vital lifesigns as well as your coordinate position.</span>")
	else
		switch(sensor_mode)
			if(0)
				to_chat(user, "<span class='notice'>You disable the suit's remote sensing equipment.</span>")
			if(1)
				to_chat(user, "<span class='notice'>The suit sensors will now report whether the wearer is live or dead.</span>")
			if(2)
				to_chat(user, "<span class='notice'>The suit sensors will now report the wearer's vital lifesigns.</span>")
			if(3)
				to_chat(user, "<span class='notice'>The suit sensors will now report the wearer's vital lifesigns as well as their coordinate position.</span>")
	return switchMode

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)

/obj/item/clothing/under/AltClick()
	if(is_holder_of(usr, src))
		set_sensors(usr)
	else
		return ..()

/datum/action/item_action/toggle_minimap
	name = "Toggle Minimap"

/datum/action/item_action/toggle_minimap/Trigger()
	var/obj/item/clothing/under/T = target
	if(!istype(T))
		return
	for(var/obj/item/clothing/accessory/holomap_chip/HC in T.accessories)
		HC.togglemap()

/datum/action/item_action/target_appearance/check_watch
	name = "Check the Time"

/datum/action/item_action/target_appearance/check_watch/Trigger()
	var/obj/item/clothing/accessory/wristwatch/W = target
	if(!istype(W))
		return
	W.check_watch()

/obj/item/clothing/under/rank/New()
	. = ..()
	sensor_mode = pick(0, 1, 2, 3)


/* ========================================================================
								BACK
======================================================================== */
/obj/item/clothing/back
	name = "cape"
	w_class = W_CLASS_SMALL
	throwforce = 2
	slot_flags = SLOT_BACK
	starting_materials = list(MAT_FABRIC = CC_PER_SHEET_FABRIC)
