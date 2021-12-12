/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/abstract = FALSE
	var/item_state = null
	var/list/inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	var/r_speed = 1.0
	var/health = null
	var/hitsound = null
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/armor_penetration = 0 // Chance from 0 to 100 to reduce absorb by one, and then rolls the same value. Check living_defense.dm

	var/w_class = W_CLASS_MEDIUM
	var/attack_delay = 10 //Delay between attacking with this item, in 1/10s of a second (default = 1 second)

	flags = FPRINT
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	var/clothing_flags = 0
	var/obj/item/offhand/wielded = null
	pass_flags = PASSTABLE
	pressure_resistance = 5
//	causeerrorheresoifixthis
	var/obj/item/master = null//apparently used by device assemblies to track the object they are attached to.

	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/heat_conductivity = 0.5 // how conductive an item is to heat a player (ie how quickly someone will lose heat) on a scale of 0 - 1. - 1 is fully conductive, 0 is fully insulative, this is a range, not binary.
	//If this is set, The item will make an action button on the player's HUD when picked up.

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/_color = null
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	var/body_parts_visible_override = 0 //for when you want specific parts to be visible while covered (and not all of them), same flags as above.
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit) - 0 is not conductive, 1 is conductive - this is a range, not binary
	var/slowdown = NO_SLOWDOWN // How much each piece of clothing is slowing you down. Works as a MULTIPLIER, i.e. 0.8 slowdown makes you go 20% faster, 1.5 slowdown makes you go 50% slower.

	var/canremove = TRUE //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	var/cant_remove_msg = " cannot be taken off!"
	var/cant_drop = FALSE //If 1, can't drop it from hands!
	var/cant_drop_msg = " sticks to your hand!"
	var/laying_pickup = FALSE //Allows things to be placed in hands while the owner of those hands is laying

	var/list/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/armor_absorb = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

	var/list/allowed = null //suit storage stuff.
	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.
	var/list/species_fit = null //This object has a different appearance when worn by these species
	var/nonplant_seed_type

	var/list/attack_verb // used in attack() to say how something was attacked "[x] [z.attack_verb] [y] with [z]". Present tense.

	var/shrapnel_amount = 0 // How many pieces of shrapnel it disintegrates into.
	var/shrapnel_type = null
	var/shrapnel_size = 1
	var/list/actions = list() //list of /datum/action's that this item has.
	var/list/actions_types = list() //list of paths of action datums to give to the item on New().

	var/vending_cat = null// subcategory for vending machines.
	var/list/dynamic_overlay[0] //For items which need to slightly alter their on-mob appearance while being worn.
	var/restraint_resist_time = 0	//When set, allows the item to be applied as restraints, which take this amount of time to resist out of
	var/restraint_apply_time = 3 SECONDS
	var/icon/wear_override = null //Worn state override used when wearing this object on your head/uniform/glasses/etc slot, for making a more procedurally generated icon
	var/hides_identity = HIDES_IDENTITY_DEFAULT
	var/datum/daemon/daemon

	var/list/datum/disease2/disease/virus2 = list()
	var/sterility = 0// 0 to 100. increase chances of preventing disease spread.
	var/image/pathogen

	var/list/toolsounds = null //The sound(s) it makes when used as a tool.
	var/toolspeed = 1 //When this item is used as a tool, multiply the delay of its do_after by this much.

	var/crit_chance = CRIT_CHANCE_RANGED
	var/crit_chance_melee = CRIT_CHANCE_MELEE

	var/datum/speech_filter/speech_filter

/obj/item/proc/return_thermal_protection()
	return return_cover_protection(body_parts_covered) * (1 - heat_conductivity)

/obj/item/New()
	..()
	for(var/path in actions_types)
		new path(src)

/obj/item/Destroy()
	infected_items -= src
	if (pathogen)
		for (var/mob/L in science_goggles_wearers)
			if (L.client)
				L.client.images -= pathogen
		pathogen = null

	if(istype(loc, /mob))
		var/mob/H = loc
		H.drop_from_inventory(src) // items at the very least get unequipped from their mob before being deleted
	for(var/x in actions)
		qdel(x)
	..()


	/* Species-specific sprite sheets for inventory sprites
	Works similarly to worn sprite_sheets, except the alternate sprites are used when the clothing/refit_for_species() proc is called.
	*/
	//var/list/sprite_sheets_obj = null

/obj/item/acid_melt()
	if (acidable())
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(loc)
		I.desc = "Looks like this was \a [src] some time ago."
		qdel(src)

/obj/item/device
	icon = 'icons/obj/device.dmi'

/obj/item/proc/is_hidden_identity()
	switch(hides_identity)
		if(HIDES_IDENTITY_ALWAYS)
			return TRUE
		if(HIDES_IDENTITY_DEFAULT)
			return is_slot_hidden(body_parts_covered, HIDEFACE)

// Generalising these for all items
/obj/item/suicide_act(var/mob/living/user)
	if (is_sharp())
		if(w_class >= W_CLASS_MEDIUM)
			to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>", \
							"<span class='danger'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>"))
		else
			to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
							"<span class='danger'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
							"<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"))
		if(sharpness_flags & HOT_EDGE)
			return(SUICIDE_ACT_FIRELOSS|SUICIDE_ACT_BRUTELOSS)
		else
			return SUICIDE_ACT_BRUTELOSS
	else if (is_hot())
		user.visible_message("<span class='danger'>[user] is immolating \himself with \the [src]! It looks like \he's trying to commit suicide.</span>")
		user.IgniteMob()
		return SUICIDE_ACT_FIRELOSS
	else if (force >= 10)
		user.visible_message("<span class='danger'>[user] is bludgeoning \himself with \the [src]! It looks like \he's trying to commit suicide.</span>")
		return SUICIDE_ACT_BRUTELOSS

/obj/item/ex_act(severity)
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
		else
	return

/obj/item/blob_act()
	..()
	qdel(src)

/obj/item/Topic(href, href_list)
	.=..()
	if(href_list["close"])
		return

	if(usr.incapacitated())
		return TRUE
	if (!usr.dexterity_check())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return TRUE
	if (!in_range(src, usr))
		return TRUE

	add_fingerprint(usr)
	add_hiddenprint(usr)
	return FALSE

/obj/item/proc/restock() //used for borg recharging
	return

/obj/item/proc/SlipDropped(var/mob/living/user, var/slip_dir, var/slipperiness = TURF_WET_WATER)
	return

/obj/item/projectile_check()
	return PROJREACT_OBJS

/proc/wclass2text(w_class)
	switch(w_class)
		if(W_CLASS_TINY)
			return "tiny"
		if(W_CLASS_SMALL)
			return "small"
		if(W_CLASS_MEDIUM)
			return "normal-sized"
		if(W_CLASS_LARGE)
			return "bulky"
		if(W_CLASS_HUGE to INFINITY)
			return "huge"

/obj/item/examine(mob/user, var/size = "", var/show_name = TRUE)
	if(!size)
		size = wclass2text(w_class)

	//if (clumsy_check(usr) && prob(50)) t = "funny-looking"
	var/pronoun
	if (gender == PLURAL)
		pronoun = "They are"
	else
		pronoun = "It is"
	size = " [pronoun] a [size] item."
	..(user, size, show_name)
	if(price && price > 0)
		to_chat(user, "You read '[price] space bucks' on the tag.")
	if((cant_drop != FALSE) && user.is_holding_item(src)) //Item can't be dropped, and is either in left or right hand!
		to_chat(user, "<span class='danger'>It's stuck to your hands!</span>")
	if(daemon && daemon.flags & DAEMON_EXAMINE)
		daemon.examine(user)


/obj/item/attack_ai(mob/user as mob)
	..()
	if(isMoMMI(user))
		var/in_range = in_range(src, user) || loc == user
		if(in_range)
			if(src == user:tool_state)
				return FALSE
			attack_hand(user)
	else if(isrobot(user))
		if(!istype(loc, /obj/item/weapon/robot_module))
			return
		var/mob/living/silicon/robot/R = user
		R.activate_module(src)
		R.hud_used.update_robot_modules_display()

/obj/item/attack_hand(var/mob/user)
	if (!user)
		return

	if (istype(loc, /obj/item/weapon/storage))
		//If the item is in a storage item, take it out.
		var/obj/item/weapon/storage/S = loc
		if(!S.remove_from_storage(src, user))
			return

	throwing = FALSE
	if (loc == user)
		if(src == user.get_inactive_hand())
			if(flags & TWOHANDABLE)
				return wield(user)
			if(!user.put_in_hand_check(src, user.get_active_hand()))
				return
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(!canremove)
			to_chat(user, "<span class='notice'>\The [src][cant_remove_msg]</span>")
			return

		user.u_equip(src,FALSE)
	else
		if(isliving(loc))
			return
		//user.next_move = max(user.next_move+2,world.time + 2)
	add_fingerprint(user)
	if(can_pickup(user) && !user.put_in_active_hand(src))
		forceMove(get_turf(user))

	//transfers diseases between the mob and the item
	disease_contact(user)

/obj/item/requires_dexterity(mob/user)
	return TRUE

/obj/item/attack_paw(var/mob/user)
	attack_hand(user)

/obj/item/proc/talk_into(var/datum/speech/speech, var/channel=null)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

/obj/item/proc/dropped(mob/user as mob)
	reset_plane_and_layer()
	if(wielded)
		unwield(user)
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(user)

///called when an item is stripped off by another person, called BEFORE it is dropped. return 1 to prevent it from actually being stripped.
/obj/item/proc/before_stripped(mob/wearer as mob, mob/stripper as mob, slot)
	if(slot in list(slot_l_store, slot_r_store)) //is in pockets
		on_found(wearer, stripper)

///called when an item is stripped off by another person, called AFTER it is on the ground
/obj/item/proc/stripped(mob/wearer as mob, mob/stripper as mob, slot)
	return unequipped(wearer)

// called just as an item is picked up (loc is not yet changed). return 1 to prevent the item from being actually picked up.
/obj/item/proc/prepickup(mob/user)
	return

// called after an item is picked up (loc has already changed)
/obj/item/proc/pickup(mob/user)
	return

// called before an item is passed to another person through the give proc - TRUE allows the give, see carbon/give.dm
/obj/item/proc/pregive(mob/living/carbon/giver, mob/living/carbon/receiver)
	return TRUE

// called while an item is passed to another person through the give proc - TRUE allows the give, see carbon/give.dm
/obj/item/proc/on_give(mob/living/carbon/giver, mob/living/carbon/receiver)
	return TRUE

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/S as obj)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/S as obj)
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/wearer, mob/finder)
	return

// have your item's MouseDropFrom call this if mouse-dropping is the default way of picking up your item, such as a paper bin or a deck of card
/obj/item/proc/MouseDropPickUp(atom/over_object)
	var/mob/user = usr
	if(user.incapacitated() || (!ishigherbeing(user) && !isrobot(user)))
		return
	if(Adjacent(user) || is_holder_of(user, src))
		if(!istype(user, /mob/living/carbon/slime) && !istype(user, /mob/living/simple_animal))
			if(istype(over_object,/obj/abstract/screen/inventory)) //We're being dragged into the user's UI...
				var/obj/abstract/screen/inventory/OI = over_object

				if(OI.hand_index && user.put_in_hand_check(src, OI.hand_index))
					if(istype(loc, /obj/item/weapon/storage))
						var/obj/item/weapon/storage/bag = loc
						bag.remove_from_storage(src)
					user.u_equip(src, 0)
					user.put_in_hand(OI.hand_index, src)
					mouse_opacity = 1
					src.add_fingerprint(user)

			else if(istype(over_object,/mob/living)) //We're being dragged on a living mob's sprite...
				if(user == over_object) //It's the user!
					if( !user.get_active_hand() )		//if active hand is empty
						if(istype(loc, /obj/item/weapon/storage))
							var/obj/item/weapon/storage/bag = loc
							bag.remove_from_storage(src)
						user.put_in_hands(src)
						user.visible_message("<span class='notice'>[user] picks up the [src].</span>", "<span class='notice'>You pick up \the [src].</span>")
						mouse_opacity = 1
	else
		to_chat(user, "<span class='warning'>You can't reach it from here.</span>")

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(var/mob/user, var/slot, hand_index = 0)
	if(cant_drop) //Item can't be dropped
		if(hand_index) //Item was equipped in a hand slot
			to_chat(user, "<span class='notice'>\The [src][cant_drop_msg]</span>")
	for(var/X in actions)
		var/datum/action/A = X
		if(item_action_slot_check(slot, user)) //some items only give their actions buttons when in a specific slot.
			A.Grant(user)
	return

/obj/item/proc/item_action_slot_check(slot, mob/user)
	return 1

// called after an item is unequipped or stripped
/obj/item/proc/unequipped(mob/user, var/from_slot = null)
	for(var/x in actions)
		var/datum/action/A = x
		A.Remove(user)
	return

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	if(!slot)
		return CANNOT_EQUIP
	if(!M)
		return CANNOT_EQUIP

	if(wielded)
		if(!disable_warning)
			if(flags & MUSTTWOHAND)
				M.show_message("\The [src] is too cumbersome to carry in anything other than your hands.")
			else
				M.show_message("You have to unwield \the [wielded.wielding] first.")
		return CANNOT_EQUIP

	if(cant_drop > 0)
		if(!disable_warning)
			to_chat(M, "<span class='danger'>It's stuck to your hands!</span>")
		return CANNOT_EQUIP

	if(ishuman(M)) //Crimes Against OOP: This is first on the list if anybody ever feels like unfucking inventorycode
		//START HUMAN
		var/mob/living/carbon/human/H = M

		if(istype(src, /obj/item/clothing/under) || istype(src, /obj/item/clothing/suit))
			if(M_FAT in H.mutations)
				//testing("[M] TOO FAT TO WEAR [src]!")
				if(!(clothing_flags & ONESIZEFITSALL))
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You're too fat to wear the [name].</span>")
					return CANNOT_EQUIP

			for(var/datum/organ/external/OE in get_organs_by_slot(slot, H))
				if(!OE.species) //Organ has same species as body
					if(H.species.anatomy_flags & IS_BULKY && !(clothing_flags & ONESIZEFITSALL)) //Use the body's base species
						if(!disable_warning)
							to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky exterior!</span>")
						return CANNOT_EQUIP
				else //Organ's species is different from body
					if(OE.species.anatomy_flags & IS_BULKY && !(clothing_flags & ONESIZEFITSALL))
						if(!disable_warning)
							to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky exterior!</span>")
						return CANNOT_EQUIP

		switch(slot)
			if(slot_wear_mask)
				if( !(slot_flags & SLOT_MASK) )
					return CANNOT_EQUIP

				for(var/datum/organ/external/OE in get_organs_by_slot(slot, H))
					if(!OE.species) //Organ has same species as body
						if(H.species.anatomy_flags & IS_BULKY && !(clothing_flags & ONESIZEFITSALL)) //Use the body's base species
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your thick head!</span>")
							return CANNOT_EQUIP
					else //Organ's species is different from body
						if(OE.species.anatomy_flags & IS_BULKY && !(clothing_flags & ONESIZEFITSALL))
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your thick head!</span>")
							return CANNOT_EQUIP

				if(H.wear_mask)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.wear_mask.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_back)
				if( !(slot_flags & SLOT_BACK) )
					return CANNOT_EQUIP
				if(H.back)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.back.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_wear_suit)
				if( !(slot_flags & SLOT_OCLOTHING) )
					return CANNOT_EQUIP

				for(var/datum/organ/external/OE in get_organs_by_slot(slot, H))
					if(!OE.species) //Organ has same species as body
						if(H.species.anatomy_flags & IS_BULKY && !(clothing_flags & ONESIZEFITSALL)) //Use the body's base species
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky exterior!</span>")
							return CANNOT_EQUIP
					else //Organ's species is different from body
						if(OE.species.anatomy_flags & IS_BULKY && !(clothing_flags & ONESIZEFITSALL))
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky exterior!</span>")
							return CANNOT_EQUIP

				if(H.wear_suit)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.wear_suit.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_gloves)
				if( !(slot_flags & SLOT_GLOVES) )
					return CANNOT_EQUIP

				for(var/datum/organ/external/OE in get_organs_by_slot(slot, H))
					if(!OE.species) //Organ has same species as body
						if(H.species.anatomy_flags & IS_BULKY && !(clothing_flags & ONESIZEFITSALL)) //Use the body's base species
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky fingers!</span>")
							return CANNOT_EQUIP
					else //Organ's species is different from body
						if(OE.species.anatomy_flags & IS_BULKY && !(clothing_flags & ONESIZEFITSALL))
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky fingers!</span>")
							return CANNOT_EQUIP

				if(H.gloves)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.gloves.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_shoes)
				if( !(slot_flags & SLOT_FEET) )
					return CANNOT_EQUIP

				for(var/datum/organ/external/OE in get_organs_by_slot(slot, H))
					if(!OE.species) //Organ has same species as body
						if(H.species.anatomy_flags & IS_BULKY && !(clothing_flags & ONESIZEFITSALL)) //Use the body's base species
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky feet!</span>")
							return CANNOT_EQUIP
					else //Organ's species is different from body
						if(OE.species.anatomy_flags & IS_BULKY && !(clothing_flags & ONESIZEFITSALL))
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky feet!</span>")
							return CANNOT_EQUIP

				if(H.shoes)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.shoes.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_belt)
				if(!H.w_uniform && !isbelt(src))
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_BELT) )
					return CANNOT_EQUIP
				if(H.belt)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.belt.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_glasses)
				if( !(slot_flags & SLOT_EYES) )
					return CANNOT_EQUIP
				if(H.glasses)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.glasses.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_head)
				if( !(slot_flags & SLOT_HEAD) )
					return CANNOT_EQUIP
				if(H.head)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.head.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP

			if(slot_ears)
				if( !(slot_flags & SLOT_EARS) )
					return CANNOT_EQUIP
				if(H.ears)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.ears.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			/* In case it's ever unfucked.
			if(slot_ears)
				if( !(slot_flags & SLOT_EARS) )
					return CANNOT_EQUIP
				if( (slot_flags & SLOT_TWOEARS) && H.r_ear )
					return CANNOT_EQUIP
				if(H.l_ear)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.l_ear.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				if( w_class < W_CLASS_SMALL	)
					return CAN_EQUIP
				return CAN_EQUIP
			if(slot_r_ear)
				if( !(slot_flags & SLOT_EARS) )
					return CANNOT_EQUIP
				if( (slot_flags & SLOT_TWOEARS) && H.l_ear )
					return CANNOT_EQUIP
				if(H.r_ear)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.r_ear.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				if( w_class < W_CLASS_SMALL )
					return CAN_EQUIP
				return CAN_EQUIP
			*/
			if(slot_w_uniform)
				if( !(slot_flags & SLOT_ICLOTHING) )
					return CANNOT_EQUIP
				if(H.w_uniform)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.w_uniform.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_wear_id)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_ID) )
					return CANNOT_EQUIP
				if(H.wear_id)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.wear_id.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_l_store)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return CANNOT_EQUIP
				if(slot_flags & SLOT_DENYPOCKET)
					return
				if(automatic)
					if(H.l_store)
						return CANNOT_EQUIP
					else if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
						return CAN_EQUIP
				else if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
					if(H.l_store)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CAN_EQUIP
			if(slot_r_store)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return CANNOT_EQUIP
				if(slot_flags & SLOT_DENYPOCKET)
					return
				if(automatic)
					if(H.r_store)
						return CANNOT_EQUIP
					else if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
						return CAN_EQUIP
				else if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
					if(H.r_store)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CAN_EQUIP
			if(slot_s_store)
				if(!H.wear_suit)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a suit before you can attach this [name].</span>")
					return CANNOT_EQUIP
				if(!H.wear_suit.allowed)
					if(!disable_warning)
						to_chat(usr, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
					return CANNOT_EQUIP
				if(w_class > W_CLASS_MEDIUM && !H.wear_suit.allowed.len)
					if(!disable_warning)
						to_chat(usr, "The [name] is too big to attach.")
					return CANNOT_EQUIP
				if( istype(src, /obj/item/device/pda) || istype(src, /obj/item/weapon/pen) || is_type_in_list(src, H.wear_suit.allowed) )
					if(H.s_store)
						if(automatic)
							if(H.check_for_open_slot(src))
								return CANNOT_EQUIP
						if(H.s_store.canremove)
							return CAN_EQUIP_BUT_SLOT_TAKEN
						else
							return CANNOT_EQUIP
					else
						return CAN_EQUIP
				return CANNOT_EQUIP
			if(slot_handcuffed)
				if(H.handcuffed)
					return CANNOT_EQUIP
				if (H.mutual_handcuffs)
					return CANNOT_EQUIP
				if(!istype(src, /obj/item/weapon/handcuffs))
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_legcuffed)
				if(H.legcuffed)
					return CANNOT_EQUIP
				if(!istype(src, /obj/item/weapon/legcuffs))
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_in_backpack)
				if (H.back && istype(H.back, /obj/item/weapon/storage/backpack))
					var/obj/item/weapon/storage/backpack/B = H.back
					if(!B.storage_slots && w_class <= B.fits_max_w_class)
						return CAN_EQUIP
					if(B.contents.len < B.storage_slots && w_class <= B.fits_max_w_class)
						return CAN_EQUIP
				return CANNOT_EQUIP
		return CANNOT_EQUIP //Unsupported slot
		//END HUMAN

	else if(ismonkey(M))
		//START MONKEY
		var/mob/living/carbon/monkey/MO = M
		switch(slot)
			if(slot_head)
				if(!MO.canWearHats)
					return CANNOT_EQUIP
				if(MO.hat)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_HEAD) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_wear_mask)
				if(!MO.canWearMasks)
					return CANNOT_EQUIP
				if(MO.wear_mask)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_MASK) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_glasses)
				if(!MO.canWearGlasses)
					return CANNOT_EQUIP
				if(MO.glasses)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_EYES) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_w_uniform)
				if(!MO.canWearClothes)
					return CANNOT_EQUIP
				if(MO.uniform)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_ICLOTHING) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_back)
				if(!MO.canWearBack)
					return CANNOT_EQUIP
				if(MO.back)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_BACK) )
					return CANNOT_EQUIP
				return CAN_EQUIP
		return CANNOT_EQUIP //Unsupported slot
		//END MONKEY

	else if(isalienadult(M))
		//START ALIEN HUMANOID
		var/mob/living/carbon/alien/humanoid/AH = M
		switch(slot)
			if(slot_l_store)
				if(slot_flags & SLOT_DENYPOCKET)
					return CANNOT_EQUIP
				if(AH.l_store)
					return CANNOT_EQUIP
				if( !(w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET)) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_r_store)
				if(slot_flags & SLOT_DENYPOCKET)
					return CANNOT_EQUIP
				if(AH.r_store)
					return CANNOT_EQUIP
				if( !(w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET)) )
					return CANNOT_EQUIP
				return CAN_EQUIP
		return CANNOT_EQUIP //Unsupported slot
		//END ALIEN HUMANOID

	else if(ishologram(M))
		//START HOLOGRAM
		var/mob/living/simple_animal/hologram/advanced/HM = M
		switch(slot)
			if(slot_head)
				if(HM.head)
					return CANNOT_EQUIP
				if(!(slot_flags & SLOT_HEAD) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_w_uniform)
				if(HM.w_uniform)
					return CANNOT_EQUIP
				if(!(slot_flags & SLOT_ICLOTHING) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_wear_suit)
				if(HM.wear_suit)
					return CANNOT_EQUIP
				if(!(slot_flags & SLOT_OCLOTHING) )
					return CANNOT_EQUIP
				return CAN_EQUIP
		return CANNOT_EQUIP //Unsupported slot
		//END HOLOGRAM

	else if(isMoMMI(M))
		//START MOMMI ALSO THIS SO FUCKING SILLY
		var/mob/living/silicon/robot/mommi/MoM = M
		switch(slot)
			if(slot_head)
				if(MoM.head_state)
					return CANNOT_EQUIP
				return CAN_EQUIP
		return CANNOT_EQUIP //Unsupported slot
		//END MOMMI

	else if(ismartian(M))
		//why
		var/mob/living/carbon/complex/martian/MA = M
		switch(slot)
			if(slot_head)
				if(MA.head)
					return CANNOT_EQUIP
				return CAN_EQUIP

		return CANNOT_EQUIP

	else if(isgrinch(M))
		//START GRINCH
		var/mob/living/simple_animal/hostile/gremlin/grinch/G = M
		switch(slot)
			if(slot_back)
				if(G.back)
					return CANNOT_EQUIP
				if(!(slot_flags & SLOT_BACK) )
					return CANNOT_EQUIP
				return CAN_EQUIP
		return CANNOT_EQUIP //Unsupported slot
		//END GRINCH

/obj/item/can_pickup(mob/living/user, var/actually_picking_up = TRUE, var/silent = FALSE)
	if(!(user) || !isliving(user)) //BS12 EDIT
		return FALSE
	if(actually_picking_up && prepickup(user))
		return FALSE
	if(user.incapacitated() || !Adjacent(user))
		return FALSE
	if((!iscarbon(user) && !isMoMMI(user)) && !ishologram(user) && !isgrinch(user) || isbrain(user)) //Is not a carbon being, MoMMI, advanced hologram, or is a brain
		if(!silent)
			to_chat(user, "You can't pick things up!")
		return FALSE
	if(anchored) //Object isn't anchored
		if(!silent)
			to_chat(user, "<span class='warning'>You can't pick that up!</span>")
		return FALSE
	if(!istype(loc, /turf) && !is_holder_of(user, src)) //Object is not on a turf
		if(!silent)
			to_chat(user, "<span class='warning'>You can't pick that up!</span>")
		return FALSE
	return TRUE

/obj/item/verb_pickup(mob/living/user)
	//set src in oview(1)
	//set category = "Object"
	//set name = "Pick up"

	if(!can_pickup(user))
		return FALSE

	if(user.get_active_hand())
		to_chat(user, "<span class='warning'>Your [user.get_index_limb_name(user.active_hand)] is full.</span>")
		return

	//All checks are done, time to pick it up!
	if(isMoMMI(user))
		// Otherwise, we get MoMMIs changing their own laws.
		if(istype(src,/obj/item/weapon/aiModule))
			to_chat(src, "<span class='warning'>Your firmware prevents you from picking up [src]!</span>")
			return
		if(user.get_active_hand() == null)
			user.put_in_hands(src)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/h_user = user
		if(h_user.can_use_hand())
			attack_hand(h_user)
		else
			attack_stump(h_user)
	if(istype(user, /mob/living/carbon/alien))
		attack_alien(user)
	if(istype(user, /mob/living/carbon/monkey))
		attack_paw(user)
	return

//Used in twohanding
/obj/item/proc/wield(mob/user, var/inactive = FALSE)
	if(!user.can_wield(src))
		user.show_message("You can't wield \the [src] as it's too heavy.")
		return

	if(!wielded)
		wielded = new /obj/item/offhand

		//Long line ahead, let's break that up!
		//
		//((user.get_active_hand() in list(null, src)) && user.put_in_inactive_hand(wielded))
		//By default this proc assumes that the wielded item is held in the ACTIVE hand!
		//(user.get_active_hand() in list(null, src)) is the part which checks whether the ACTIVE hand is either nothing, or the wielded item. Otherwise, abort!

		//The second half is the same, except that the proc assumes that the wielded item is held in the INACTIVE hand. So the INACTIVE hand is checked for holding either nothing or wielded item.
		//if(((user.get_active_hand() in list(null, src)) && user.put_in_inactive_hand(wielded)) || (!inactive && ((user.get_inactive_hand() in list(null, src)) && user.put_in_active_hand(wielded))))

		for(var/i = TRUE to user.held_items.len)
			if(user.held_items[i])
				continue
			if(user.active_hand == i)
				continue

			if(user.put_in_hand(i, wielded))
				wielded.attach_to(src)
				update_wield(user)
				return TRUE

		unwield(user)
		return

/obj/item/proc/unwield(mob/user)
	if(flags & MUSTTWOHAND && !(M_STRONG in user.mutations) && (src in user))
		user.drop_from_inventory(src)
	if(istype(wielded))
		wielded.wielding = null
		user.u_equip(wielded,1)
		if(wielded)
			qdel(wielded)
			wielded = null
	update_wield(user)

/obj/item/proc/update_wield(mob/user)

/obj/item/proc/IsShield()
	return FALSE

//Called when the item blocks an attack. Return 1 to stop the hit, return 0 to let the hit go through
/obj/item/proc/on_block(damage, atom/movable/blocked)
	if(ismob(loc))
		if (IsShield() < blocked.ignore_blocking)
			return FALSE
		if (prob(50 - round(damage / 3)))
			visible_message("<span class='borange'>[loc] blocks \the [blocked] with \the [src]!</span>")
			if(ismovable(blocked))
				var/atom/movable/M = blocked
				M.throwing = FALSE
			return TRUE

	return FALSE

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)


	var/mob/living/carbon/human/H = M
	if(istype(H))
		var/obj/item/eye_protection = H.get_body_part_coverage(EYES)
		if(eye_protection)
			to_chat(user, "<span class='warning'>You're going to need to remove that [eye_protection] first.</span>")
			return

	var/mob/living/carbon/monkey/Mo = M
	if(istype(Mo) && ( \
			(Mo.wear_mask && Mo.wear_mask.body_parts_covered & EYES) \
		))
		// you can't stab someone in the eyes wearing a mask!
		to_chat(user, "<span class='warning'>You're going to need to remove that mask first.</span>")
		return

	if(!M.has_eyes())
		to_chat(user, "<span class='warning'>You cannot locate any eyes on [M]!</span>")
		return

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [name] (INTENT: [uppertext(user.a_intent)])</font>"
	msg_admin_attack("ATTACK: [user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)])") //BS12 EDIT ALG
	log_attack("<font color='red'> [user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)])</font>")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user
		M.assaulted_by(user)

	add_fingerprint(user)
	//if(clumsy_check(user) && prob(50))
	//	M = user
		/*
		to_chat(M, "<span class='warning'>You stab yourself in the eye.</span>")
		M.sdisabilities |= BLIND
		M.AdjustKnockdown(4)
		M.adjustBruteLoss(10)
		*/

	if(istype(M, /mob/living/carbon/human))

		var/datum/organ/internal/eyes/eyes = H.internal_organs_by_name["eyes"]

		if(M != user)
			user.do_attack_animation(M, src)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("<span class='danger'>[user] stabs [M] in the eye with \the [src].</span>", 1)
			to_chat(M, "<span class='userdanger'>[user] stabs you in the eye with \the [src]!</span>")
			to_chat(user, "<span class='attack'>You stab [M] in the eye with \the [src]!</span>")
		else
			user.visible_message( \
				"<span class='attack'>[user] stabs themself with \the [src]!</span>", \
				"<span class='userdanger'>You stab yourself in the eyes with \the [src]!</span>" \
			)

		eyes.damage += rand(3,4)
		if(eyes.damage >= eyes.min_bruised_damage)
			if(M.stat != 2)
				if(eyes.robotic <= 1) //robot eyes bleeding might be a bit silly
					to_chat(M, "<span class='warning'>Your eyes start to bleed profusely!</span>")
			if(prob(50))
				if(M.stat != 2)
					to_chat(M, "<span class='warning'>You drop what you're holding and clutch at your eyes!</span>")
					M.drop_item()
				M.eye_blurry += 10
				M.Paralyse(1)
				M.Knockdown(4)
				M.Stun(4)
			if (eyes.damage >= eyes.min_broken_damage)
				if(M.stat != 2)
					to_chat(M, "<span class='warning'>You go blind!</span>")
		var/datum/organ/external/affecting = M:get_organ(LIMB_HEAD)
		if(affecting.take_damage(7))
			M:UpdateDamageIcon(1)
	else
		M.take_organ_damage(7)
	M.eye_blurry += rand(3,4)
	return

/obj/item/clean_blood()
	. = ..()
	remove_disease2()
	if (blood_overlay)
		overlays.Remove(blood_overlay)
	if (had_blood)
		clear_luminol()
	if (istype(src, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = src
		G.transfer_blood = 0


/obj/item/add_blood(var/mob/living/carbon/human/M)
	if (!..())
		return FALSE

	//if we haven't made our blood_overlay already
	if(!blood_overlays[type])
		generate_blood_overlay()

	if(!blood_overlay)
		blood_overlay = blood_overlays[type]
	else
		overlays.Remove(blood_overlay)

	//apply the blood-splatter overlay if it isn't already in there, else it updates it.
	blood_overlay.color = blood_color
	overlays += blood_overlay
	//if this blood isn't already in the list, add it
	if(!M)
		return

	if (M.virus2?.len)
		var/list/blood_diseases = filter_disease_by_spread(M.virus2,required = SPREAD_BLOOD)
		if (blood_diseases?.len)
			for (var/ID in blood_diseases)
				var/datum/disease2/disease/D = blood_diseases[ID]
				infect_disease2(D, notes="(Blood, coming from [M])")
				if (isliving(loc))
					var/mob/living/L = loc
					infection_attempt(L,D)//Wear gloves when doing surgery or beating that catbeast to death!

	if(blood_DNA[M.dna.unique_enzymes])
		return FALSE //already bloodied with this blood. Cannot add more.
	blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	had_blood = TRUE
	return TRUE //we applied blood to the item


/obj/item/add_blood_from_data(var/list/blood_data)
	if (!..())
		return FALSE

	//if we haven't made our blood_overlay already
	if(!blood_overlays[type])
		generate_blood_overlay()

	if(!blood_overlay)
		blood_overlay = blood_overlays[type]
	else
		overlays.Remove(blood_overlay)

	//apply the blood-splatter overlay if it isn't already in there, else it updates it.
	blood_overlay.color = blood_color
	overlays += blood_overlay
	//if this blood isn't already in the list, add it
	if(!blood_data)
		return

	if (length(blood_data["virus2"]))
		var/list/blood_diseases = filter_disease_by_spread(blood_data["virus2"],required = SPREAD_BLOOD)
		if (blood_diseases?.len)
			for (var/ID in blood_diseases)
				var/datum/disease2/disease/D = blood_diseases[ID]
				infect_disease2(D, notes="(Blood, coming from a blood splattering)")
				if (isliving(loc))
					var/mob/living/L = loc
					infection_attempt(L,D)//Wear gloves when doing surgery or beating that catbeast to death!

	if(blood_DNA[blood_data["blood_DNA"]])
		return FALSE //already bloodied with this blood. Cannot add more.
	blood_DNA[blood_data["blood_DNA"]] = blood_data["blood_type"]
	had_blood = TRUE
	return TRUE //we applied blood to the item



var/global/list/image/blood_overlays = list()
/obj/item/proc/generate_blood_overlay()
	if(blood_overlays[type])
		return

	var/icon/I = new /icon(icon, icon_state)
	I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
	I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant

	var/image/img = image(I)
	img.name = "blood_overlay"
	blood_overlays[type] = img

/obj/item/apply_luminol()
	if(!..())
		return FALSE
	if(!blood_overlays[type]) //Blood overlay generation if it lacks one.
		generate_blood_overlay()
	if(blood_overlay)
		overlays.Remove(blood_overlay)
	else
		blood_overlay = blood_overlays[type]
	var/image/luminol_overlay = blood_overlay
	luminol_overlay.color = LIGHT_COLOR_CYAN
	overlays += luminol_overlay
	var/obj/effect/decal/cleanable/blueglow/BG
	if(istype(had_blood,/obj/effect/decal/cleanable/blueglow))
		BG = had_blood
		BG.set_light(1,2,LIGHT_COLOR_BLUE)
	else
		had_blood = null
		BG = new /obj/effect/decal/cleanable/blueglow(src)
		had_blood = BG

/obj/item/clear_luminol()
	if(!..())
		return FALSE
	if(istype(had_blood,/obj/effect/decal/cleanable/blueglow))
		var/obj/effect/decal/cleanable/blueglow/BG
		BG = had_blood
		BG.kill_light()

/obj/item/proc/showoff(mob/user)
	if(abstract)
		return

	for (var/mob/M in view(user))
		M.show_message("[user] holds up [src]. <a HREF='?src=\ref[M];lookitem=\ref[src]'>Take a closer look.</a>",1)

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	if(attack_delayer.blocked())
		return
	delayNextAttack(SHOW_HELD_ITEM_AND_POINTING_DELAY)

	var/obj/item/I = get_active_hand()
	if(I)
		I.showoff(src)

// /vg/ Affects wearers.
/obj/item/proc/OnMobLife(var/mob/holder)
	return

/obj/item/proc/OnMobDeath(var/mob/holder)
	return

//handling the pulling of the item for singularity
/obj/item/singularity_pull(S, current_size)
	if(flags & INVULNERABLE)
		return
	spawn(0) //this is needed or multiple items will be thrown sequentially and not simultaneously
		if(anchored)
			if(current_size >= STAGE_FIVE)
				anchored = FALSE
			else
				return
		if(current_size >= STAGE_FOUR)
			//throw_at(S, 14, 3)
			step_towards(src,S)
			sleep(1)
			step_towards(src,S)
		else if(current_size > STAGE_ONE)
			step_towards(src,S)
		else
			..()

//Gets the rating of the item, used in stuff like machine construction.
/obj/item/proc/get_rating()
	return FALSE

// Like the above, but used for RPED sorting of parts.
/obj/item/proc/rped_rating()
	return get_rating()

/obj/item/kick_act(mob/living/carbon/human/H) //Kick items around!
	if(anchored || w_class > W_CLASS_MEDIUM + H.get_strength())
		H.visible_message("<span class='danger'>[H] attempts to kick \the [src]!</span>", "<span class='danger'>You attempt to kick \the [src]!</span>")
		if(prob(70))
			if(H.foot_impact(src,rand(1,4)))
				to_chat(H, "<span class='danger'>Dumb move! You strain a muscle.</span>")
		return

	var/kick_dir = get_dir(H, src)
	if(H.loc == loc)
		kick_dir = H.dir

	var/turf/T = get_edge_target_turf(loc, kick_dir)

	var/kick_power = max((H.get_strength() * 10 - (w_class ** 2)), 1) //The range of the kick is (strength)*10. Strength ranges from 1 to 3, depending on the kicker's genes. Range is reduced by w_class^2, and can't be reduced below 1.

	H.visible_message("<span class='danger'>[H] kicks \the [src]!</span>", "<span class='danger'>You kick \the [src]!</span>")

	if(kick_power > 6) //Fly in an arc!
		spawn()
			var/original_pixel_y = pixel_y
			animate(src, pixel_y = original_pixel_y + WORLD_ICON_SIZE, time = 10, easing = CUBIC_EASING)

			while(loc)
				if(!throwing)
					animate(src, pixel_y = original_pixel_y, time = 5, easing = ELASTIC_EASING)
					break
				sleep(5)

	Crossed(H) //So you can't kick shards while naked without suffering
	throw_at(T, kick_power, 1)

/obj/item/animationBolt(var/mob/firer)
	new /mob/living/simple_animal/hostile/mimic/copy(loc, src, firer, duration=SPELL_ANIMATION_TTL)

/obj/item/proc/is_worn(mob/user)
	var/mob/living/carbon/monkey/Mo = user
	var/mob/living/carbon/human/H = user

	if(!istype(H) && !istype(Mo))
		return FALSE
	var/mob/M = user
	for(var/bit = 0 to 15)
		bit = 1 << bit
		if(bit & slot_flags)
			if(M.get_item_by_flag(bit) == src)
				return TRUE

/obj/item/proc/get_shrapnel_projectile()
	if(shrapnel_type)
		return new shrapnel_type(src)
	else
		return FALSE


// IMPORTANT DISTINCTION FROM MouseWheel:
//   This one gets called when the player scrolls his mouse while this is in their active hand!
/obj/item/proc/MouseWheeled(var/mob/user, var/delta_x, var/delta_y, var/params)
	return

/obj/item/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"health",
		"canremove",
		"cant_drop")

	reset_vars_after_duration(resettable_vars, duration)

	spawn(duration + 1)
		hud_layerise()

/obj/item/proc/restraint_apply_intent_check(mob/user)
	if(user.a_intent == I_GRAB)
		return TRUE

/obj/item/proc/restraint_apply_check(mob/living/carbon/M, mob/user)
	if(!istype(M))
		return

	if(!restraint_apply_intent_check(user))
		return

	if(!user.dexterity_check())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(M.handcuffed)
		return

	M.attack_log += text("\[[time_stamp()]] <span style='color: orange'>Has been restrained (attempt) by [user.name] ([user.ckey]) with \the [src].</span>")
	user.attack_log += text("\[[time_stamp()]] <span style='color: red'>Attempted to restrain [M.name] ([M.ckey]) with \the [src].</span>")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user
		M.assaulted_by(user)

	log_attack("[user.name] ([user.ckey]) Attempted to restrain [M.name] ([M.ckey]) with \the [src].")
	return TRUE

/obj/item/proc/attempt_apply_restraints(mob/living/carbon/C, mob/user)
	if(!istype(C)) //Sanity doesn't hurt, right ?
		return FALSE

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if (!H.has_organ_for_slot(slot_handcuffed))
			to_chat(user, "<span class='danger'>\The [C] needs at least two wrists before you can cuff them together!</span>")
			return FALSE

	playtoolsound(src, 30, TRUE, -2)

	user.visible_message("<span class='danger'>[user] is trying to restrain \the [C] with \the [src]!</span>",
						 "<span class='danger'>You try to restrain \the [C] with \the [src]!</span>")

	if(do_after(user, C, restraint_apply_time))
		if(C.handcuffed || C.mutual_handcuffs)
			to_chat(user, "<span class='notice'>\The [C] is already handcuffed.</span>")
			return FALSE
		feedback_add_details("handcuffs", "[name]")

		if(clumsy_check(user) && prob(50))
			to_chat(user, "<span class='warning'>Uh... how is this done?!</span>")
			C = user

		user.visible_message("<span class='danger'>\The [user] has restrained \the [C] with \the [src]!</span>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has restrained [C.name] ([C.ckey]) with \the [src].</font>")
		C.attack_log += text("\[[time_stamp()]\] <font color='red'>Restrained with \the [src] by [user.name] ([user.ckey])</font>")
		log_attack("[user.name] ([user.ckey]) has restrained [C.name] ([C.ckey]) with \the [src]")

		var/obj/item/cuffs = src
		if(istype(src, /obj/item/weapon/handcuffs/cyborg)) //There's GOT to be a better way to check for this.
			cuffs = new /obj/item/weapon/handcuffs/cyborg(get_turf(user))
		else
			user.drop_from_inventory(cuffs)
		C.equip_to_slot(cuffs, slot_handcuffed)
		cuffs.on_restraint_apply(C)
		var/list/findcuffs = get_contents_in_object(user,/obj/item/device/law_planner)
		for(var/obj/item/device/law_planner/LP in findcuffs)
			LP.handcuff_signal()
		return TRUE

/obj/item/proc/on_restraint_removal(var/mob/living/carbon/C) //Needed for syndicuffs
	return

/obj/item/proc/on_restraint_apply(var/mob/living/carbon/C)
	return

//Called when user clicks on an object while looking through a camera (passed to the proc as [eye])
/obj/item/proc/remote_attack(atom/target, mob/user, atom/movable/eye)
	return

/obj/item/proc/recyclable(var/obj/machinery/r_n_d/fabricator/F) //Called by RnD machines, for added object-specific sanity.
	return TRUE

/obj/item/proc/on_mousedrop_to_inventory_slot()
	return

/obj/item/proc/stealthy(var/mob/living/carbon/human/H)
	return H.isGoodPickpocket()

/obj/item/proc/can_be_stored(var/obj/item/weapon/storage/S)
	return TRUE

/obj/item/MouseDropFrom(var/obj/over_object)
	if(istype(loc, /obj/item/weapon/storage) && !usr.incapacitated()) //This is the code for re-ordering items inside a storage item via mouse drag and drop.
		if(loc == over_object.loc) //Swapping to another object in the same storage item
			var/obj/item/weapon/storage/storageobj = loc
			if(usr in storageobj.is_seeing)
				//Almost none of BYOND's list procs work with contents because contents is a snowflake list and BYOND hates you, so enter the kludge.
				//And yes, this is Lummox-sanctioned kludge: http://www.byond.com/forum/?post=271125
				var/temp_index = storageobj.contents.Find(over_object)
				var/list/temp_contents = storageobj.contents.Copy()
				temp_contents -= src
				temp_contents.Insert(temp_index, src)
				storageobj.contents = temp_contents
				storageobj.refresh_all()
				return
		else if(istype(over_object, /obj/abstract/screen/storage)) //Drag and dropped to an empty slot inside the storage item
			//Since contents are always ordered to the left we assume the user wants to move this item to the rightmost slot possible.
			var/obj/abstract/screen/storage/screenobj = over_object
			var/obj/item/weapon/storage/storageobj = screenobj.master
			if(storageobj == loc && (usr in storageobj.is_seeing))
				//If anybody knows a better way to move ourselves to the end of a list, that actually works with BYOND's finickity handling of the contents list, then you are a greater man than I
				storageobj.contents -= src
				storageobj.contents += src
				storageobj.refresh_all()
				return
	if(!istype(over_object, /obj/abstract/screen/inventory))
		return ..()
	if(!ishuman(usr) && !ismonkey(usr))
		return ..()
	if(!usr.is_wearing_item(src) || !canremove)
		return ..()
	if(usr.incapacitated())
		return ..()

	var/obj/abstract/screen/inventory/OI = over_object
	on_mousedrop_to_inventory_slot()

	if(OI.hand_index && usr.put_in_hand_check(src, OI.hand_index) && !src.prepickup(usr))
		usr.u_equip(src, TRUE)
		usr.put_in_hand(OI.hand_index, src)
		add_fingerprint(usr)

/obj/item/proc/pre_throw()
	return

/**
	Attempt to heat this object from a presumed heat source.
	@args:
		A: Atom: The source of the heat
		user: mob: Whomever may be trying to heat this object

	@return:
		TRUE if succesful
		FALSE if not succesful
		NULL if override not defined
**/
/obj/item/proc/attempt_heating(atom/A, mob/user)
	return

/obj/item/proc/recharger_process(var/obj/machinery/recharger/charger)
	return

/obj/item/proc/is_screwdriver(var/mob/user)
	return FALSE

/obj/item/proc/is_wrench(var/mob/user)
	return FALSE

/obj/item/proc/is_wirecutter(var/mob/user)
	return FALSE

/obj/item/proc/is_multitool(var/mob/user)
	return FALSE

/obj/item/proc/mannequin_equip(var/obj/structure/mannequin/mannequin,var/slot,var/hand_slot)
	return

/obj/item/proc/mannequin_unequip(var/obj/structure/mannequin/mannequin)
	return

//This proc will be called when the person holding or equipping it talks.
/obj/item/proc/affect_speech(var/datum/speech/speech, var/mob/living/L)
	if(speech_filter)
		speech.message = speech_filter.FilterSpeech(speech.message)
	return

/obj/item/gen_quality(var/modifier = 0, var/min_quality = 0, var/datum/material/mat)
	..()
	var/processed_name = lowertext(mat? mat.processed_name : material_type.processed_name)
	var/to_icon_state = "[initial(icon_state)]_[processed_name]_[quality]"
	if(has_icon(inhand_states[inhand_states[1]], to_icon_state))
		item_state = to_icon_state

/obj/item/dorfify(var/datum/material/mat, var/additional_quality, var/min_quality)
	.=..()
	if(. && material_type)
		armor["melee"] = min(90, armor["melee"]*(material_type.armor_mod*(quality/B_AVERAGE)))
		armor["bullet"] = min(90, armor["bullet"]*(material_type.armor_mod*(quality/B_AVERAGE)))
		armor["laser"] = min(90, armor["laser"]*(material_type.armor_mod*(quality/B_AVERAGE)))

/////// DISEASE STUFF //////////////////////////////////////////////////////////////////////////

/obj/item/clothing/suitable_colony()
	return pressure_resistance > ONE_ATMOSPHERE

//Called by attack_hand(), transfers diseases between the mob and the item
/obj/item/proc/disease_contact(var/mob/living/M,var/bodypart = null)
	//first let's try to infect them with our viruses
	for (var/ID in virus2)
		var/datum/disease2/disease/D = virus2[ID]
		infection_attempt(M,D,bodypart)

	if (!bodypart)//no bodypart specified? that should mean we're being held.
		bodypart = HANDS
	//secondly, do they happen to carry contact-spreading viruses themselves?
	var/list/contact_diseases = filter_disease_by_spread(M.virus2,required = SPREAD_CONTACT | SPREAD_COLONY)
	if (contact_diseases?.len)
		//if so are their hands protected?
		var/block = M.check_contact_sterility(bodypart)
		for (var/ID in contact_diseases)
			var/datum/disease2/disease/D = contact_diseases[ID]
			if(attempt_colony(src,D,"from being touched by [M]"))
			else if(!block)
				infect_disease2(D, notes="(Contact, from being touched by [M])")

	//spreading of blood-spreading diseases to items is handled by add_blood()

//Called by disease_contact(), trying to infect people who pick us up
/obj/item/proc/infection_attempt(var/mob/living/perp,var/datum/disease2/disease/D,var/bodypart = null)
	if (!istype(D))
		return
	if(attempt_colony(perp,D,"from picking up \a [src]"))
		return
	if (src in perp.held_items)
		bodypart = HANDS
	if (bodypart)
		var/block = perp.check_contact_sterility(bodypart)
		var/bleeding = perp.check_bodypart_bleeding(bodypart)
		if (!block)
			if (D.spread & SPREAD_CONTACT)
				perp.infect_disease2(D, notes="(Contact, from picking up \a [src])")
			else if (bleeding && (D.spread & SPREAD_BLOOD))//if we're covered with a blood-spreading disease, we may infect people with bleeding hands.
				perp.infect_disease2(D, notes="(Blood, from picking up \a [src])")

/obj/item/proc/playtoolsound(atom/A, var/volume = 75, vary = TRUE, extrarange = null)
	if(A && toolsounds)
		var/tool_sound = pick(toolsounds)
		playsound(A, tool_sound, volume, TRUE, vary)

/obj/item/proc/NoiseDampening()	// checked on headwear by flashbangs
	return FALSE
